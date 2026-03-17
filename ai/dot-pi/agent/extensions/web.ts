import { StringEnum } from "@mariozechner/pi-ai";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateHead,
	type TruncationResult,
	type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import * as cheerio from "cheerio";
import Exa from "exa-js";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import TurndownService from "turndown";

const WEBFETCH_MAX_RESPONSE_SIZE = 5 * 1024 * 1024;
const WEBFETCH_DEFAULT_TIMEOUT_MS = 30_000;
const WEBFETCH_MAX_TIMEOUT_MS = 120_000;
const WEBFETCH_USER_AGENT = "opencode/1.0";

const WEBSEARCH_DEFAULT_NUM_RESULTS = 8;
const WEBSEARCH_MAX_NUM_RESULTS = 25;
const WEBSEARCH_DEFAULT_MAX_TOKENS = 25_000;
const WEBSEARCH_MAX_MAX_TOKENS = 100_000;
const APPROX_CHARS_PER_TOKEN = 4;
const MIN_CHARS_PER_RESULT = 1_500;
const MAX_CHARS_PER_RESULT = 10_000;

const WebFetchParams = Type.Object({
	url: Type.String({ description: "The URL to fetch content from" }),
	format: StringEnum(["text", "markdown", "html"] as const, {
		description: "The format to return the content in (text, markdown, or html)",
	}),
	timeout: Type.Optional(Type.Number({ description: "Optional timeout in seconds (max 120)" })),
});

const WebSearchParams = Type.Object({
	query: Type.String({ description: "Search query" }),
	num_results: Type.Optional(Type.Number({ description: "Optional number of results to return (default 8, max 25)" })),
	search_domain_filter: Type.Optional(
		Type.Array(Type.String(), {
			description:
				"Optional list of domains to include or exclude. Include with 'example.com', exclude with '-example.com'.",
		}),
	),
	search_language_filter: Type.Optional(
		Type.Array(Type.String(), {
			description:
				"Optional ISO 639-1 language codes to bias the query toward, e.g. ['en', 'fr'].",
		}),
	),
	search_after_date: Type.Optional(
		Type.String({ description: "Optional published-after date. Accepts YYYY-MM-DD or MM/DD/YYYY." }),
	),
	search_before_date: Type.Optional(
		Type.String({ description: "Optional published-before date. Accepts YYYY-MM-DD or MM/DD/YYYY." }),
	),
	country: Type.Optional(Type.String({ description: "Optional 2-letter ISO country code, e.g. US" })),
	max_tokens: Type.Optional(
		Type.Number({ description: "Approximate total token budget across fetched result text (default 25000, max 100000)" }),
	),
});

type ToolTextResult = {
	text: string;
	truncation?: TruncationResult;
	fullOutputPath?: string;
};

function clampTimeout(timeoutSeconds: number | undefined): number {
	if (!timeoutSeconds || !Number.isFinite(timeoutSeconds) || timeoutSeconds <= 0) {
		return WEBFETCH_DEFAULT_TIMEOUT_MS;
	}
	return Math.min(timeoutSeconds * 1000, WEBFETCH_MAX_TIMEOUT_MS);
}

function combineSignals(signal: AbortSignal | undefined, timeoutMs: number): AbortSignal {
	const timeoutSignal = AbortSignal.timeout(timeoutMs);
	if (!signal) return timeoutSignal;
	if (typeof AbortSignal.any === "function") {
		return AbortSignal.any([signal, timeoutSignal]);
	}
	if (signal.aborted) return signal;
	return timeoutSignal;
}

async function readResponseWithLimit(response: Response, maxBytes: number): Promise<string> {
	const body = response.body;
	if (!body) return "";

	const reader = body.getReader();
	let total = 0;
	const chunks: Buffer[] = [];

	while (true) {
		const { value, done } = await reader.read();
		if (done) break;
		if (!value) continue;

		const chunk = Buffer.from(value);
		const remaining = maxBytes - total;
		if (remaining <= 0) break;

		if (chunk.length <= remaining) {
			chunks.push(chunk);
			total += chunk.length;
		} else {
			chunks.push(chunk.subarray(0, remaining));
			total += remaining;
			break;
		}
	}

	return Buffer.concat(chunks).toString("utf8");
}

function extractTextFromHTML(html: string): string {
	const $ = cheerio.load(html);
	return $.root()
		.text()
		.split(/\s+/)
		.filter(Boolean)
		.join(" ");
}

function convertHTMLToMarkdown(html: string): string {
	const turndownService = new TurndownService();
	return turndownService.turndown(html);
}

function writeFullOutputToTempFile(prefix: string, output: string): string {
	const dir = mkdtempSync(join(tmpdir(), `${prefix}-`));
	const file = join(dir, "output.txt");
	writeFileSync(file, output, "utf8");
	return file;
}

function truncateToolOutput(prefix: string, output: string): ToolTextResult {
	const truncation = truncateHead(output, {
		maxLines: DEFAULT_MAX_LINES,
		maxBytes: DEFAULT_MAX_BYTES,
	});

	if (!truncation.truncated) {
		return { text: truncation.content };
	}

	const fullOutputPath = writeFullOutputToTempFile(prefix, output);
	let text = truncation.content;
	text += `\n\n[Output truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines`;
	text += ` (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}).`;
	text += ` Full output saved to: ${fullOutputPath}]`;

	return {
		text,
		truncation,
		fullOutputPath,
	};
}

function parseFlexibleDate(value: string | undefined): string | undefined {
	if (!value) return undefined;
	const trimmed = value.trim();
	if (!trimmed) return undefined;
	if (/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) return trimmed;

	const usMatch = trimmed.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
	if (!usMatch) return undefined;
	const [, month, day, year] = usMatch;
	return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
}

function splitDomainFilters(filters: string[] | undefined): { includeDomains: string[]; excludeDomains: string[] } {
	const includeDomains: string[] = [];
	const excludeDomains: string[] = [];

	for (const raw of filters ?? []) {
		const value = raw.trim();
		if (!value) continue;
		if (value.startsWith("-")) {
			excludeDomains.push(value.slice(1));
		} else {
			includeDomains.push(value);
		}
	}

	return { includeDomains, excludeDomains };
}

function buildLanguageBiasedQuery(query: string, languages: string[] | undefined): string {
	const normalized = (languages ?? []).map((item) => item.trim().toLowerCase()).filter(Boolean);
	if (normalized.length === 0) return query;
	return `${query} (${normalized.map((lang) => `language:${lang}`).join(" OR ")})`;
}

function clampNumResults(value: number | undefined): number {
	if (!value || !Number.isFinite(value) || value <= 0) return WEBSEARCH_DEFAULT_NUM_RESULTS;
	return Math.min(Math.floor(value), WEBSEARCH_MAX_NUM_RESULTS);
}

function clampMaxTokens(value: number | undefined): number {
	if (!value || !Number.isFinite(value) || value <= 0) return WEBSEARCH_DEFAULT_MAX_TOKENS;
	return Math.min(Math.floor(value), WEBSEARCH_MAX_MAX_TOKENS);
}

function charsPerResult(maxTokens: number, numResults: number): number {
	const approx = Math.floor((maxTokens * APPROX_CHARS_PER_TOKEN) / Math.max(numResults, 1));
	return Math.max(MIN_CHARS_PER_RESULT, Math.min(MAX_CHARS_PER_RESULT, approx));
}

export default function webTools(pi: ExtensionAPI) {
	pi.registerTool({
		name: "webfetch",
		label: "Web Fetch",
		description: `Fetches content from a URL and returns it in the specified format.

WHEN TO USE THIS TOOL:
- Use when you need to download content from a URL
- Helpful for retrieving documentation, API responses, or web content
- Useful for getting external information to assist with tasks

HOW TO USE:
- Provide the URL to fetch content from
- Specify the desired output format (text, markdown, or html)
- Optionally set a timeout for the request

FEATURES:
- Supports three output formats: text, markdown, and html
- Automatically handles HTTP redirects
- Sets reasonable timeouts to prevent hanging
- Validates input parameters before making requests

LIMITATIONS:
- Maximum response size is 5MB
- Only supports HTTP and HTTPS protocols
- Cannot handle authentication or cookies
- Some websites may block automated requests
- Output returned to the model is additionally truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}

TIPS:
- Use text format for plain text content or simple API responses
- Use markdown format for content that should be rendered with formatting
- Use html format when you need the raw HTML structure
- Set appropriate timeouts for potentially slow websites`,
		promptSnippet: "Fetch URL contents as text, markdown, or raw HTML.",
		promptGuidelines: [
			"Use webfetch when the user provides a URL or when you need the exact contents of a specific page.",
			"Prefer format='markdown' for docs/articles, format='text' for plain extraction, and format='html' only when raw markup matters.",
		],
		parameters: WebFetchParams,
		async execute(_toolCallId, params, signal) {
			if (!params.url) {
				return {
					content: [{ type: "text", text: "URL parameter is required" }],
					details: { ok: false, error: "missing_url" },
				};
			}

			if (!params.url.startsWith("http://") && !params.url.startsWith("https://")) {
				return {
					content: [{ type: "text", text: "URL must start with http:// or https://" }],
					details: { ok: false, error: "invalid_url" },
				};
			}

			const timeoutMs = clampTimeout(params.timeout);
			const response = await fetch(params.url, {
				method: "GET",
				headers: {
					"user-agent": WEBFETCH_USER_AGENT,
				},
				signal: combineSignals(signal, timeoutMs),
			});

			if (response.status !== 200) {
				return {
					content: [{ type: "text", text: `Request failed with status code: ${response.status}` }],
					details: { ok: false, status: response.status, url: params.url },
				};
			}

			const content = await readResponseWithLimit(response, WEBFETCH_MAX_RESPONSE_SIZE);
			const contentType = response.headers.get("content-type") ?? "";
			let output = content;

			switch (params.format) {
				case "text":
					if (contentType.includes("text/html")) {
						output = extractTextFromHTML(content);
					}
					break;
				case "markdown":
					if (contentType.includes("text/html")) {
						output = convertHTMLToMarkdown(content);
					} else {
						output = `\`\`\`\n${content}\n\`\`\``;
					}
					break;
				case "html":
					output = content;
					break;
			}

			const truncated = truncateToolOutput("pi-webfetch", output);
			return {
				content: [{ type: "text", text: truncated.text }],
				details: {
					ok: true,
					url: params.url,
					format: params.format,
					contentType,
					timeoutMs,
					truncation: truncated.truncation,
					fullOutputPath: truncated.fullOutputPath,
				},
			};
		},
	});

	pi.registerTool({
		name: "websearch",
		label: "Web Search",
		description: `Search the web using Exa AI and return current, content-rich results.

WHEN TO USE THIS TOOL:
- Use when you need up-to-date internet information
- Use when the user asks for recent news, current docs, live web facts, or broad discovery
- Use before webfetch when you need to discover the right pages first

HOW TO USE:
- Provide a search query
- Optionally limit results, domains, dates, country, or languages
- Fetches text from the most relevant pages and returns a compact result set

FEATURES:
- Real web search backed by Exa
- Domain include/exclude filters
- Published date filters
- Country bias
- Returns extracted page text for the top results
- Output returned to the model is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}

LIMITATIONS:
- Requires EXA_API_KEY in the environment
- Language filtering is applied as query bias, not a hard API filter
- Output quality depends on Exa coverage and the target pages
- Some sites may have limited extracted text`,
		promptSnippet: "Search the live web for current information and return extracted content from top results.",
		promptGuidelines: [
			"Use websearch for current or broad internet research; use webfetch once you know the exact URL to inspect.",
			"If the user needs authoritative details, search first and then fetch the most relevant pages directly.",
		],
		parameters: WebSearchParams,
		async execute(_toolCallId, params) {
			const apiKey = process.env.EXA_API_KEY?.trim();
			if (!apiKey) {
				return {
					content: [{ type: "text", text: "EXA_API_KEY is not set" }],
					details: { ok: false, error: "missing_exa_api_key" },
				};
			}

			const numResults = clampNumResults(params.num_results);
			const maxTokens = clampMaxTokens(params.max_tokens);
			const { includeDomains, excludeDomains } = splitDomainFilters(params.search_domain_filter);
			const startPublishedDate = parseFlexibleDate(params.search_after_date);
			const endPublishedDate = parseFlexibleDate(params.search_before_date);
			const query = buildLanguageBiasedQuery(params.query, params.search_language_filter);
			const maxCharacters = charsPerResult(maxTokens, numResults);

			const exa = new Exa(apiKey);
			const result = await exa.search(query, {
				numResults,
				...(includeDomains.length > 0 ? { includeDomains } : {}),
				...(excludeDomains.length > 0 ? { excludeDomains } : {}),
				...(startPublishedDate ? { startPublishedDate } : {}),
				...(endPublishedDate ? { endPublishedDate } : {}),
				...(params.country?.trim() ? { userLocation: params.country.trim().toUpperCase() } : {}),
				contents: {
					text: { maxCharacters },
				},
			});

			const lines: string[] = [];
			lines.push("# Web Search Results");
			lines.push("");
			lines.push(`Query: ${params.query}`);
			lines.push(`Returned: ${result.results.length} result${result.results.length === 1 ? "" : "s"}`);
			lines.push("");

			for (const [index, item] of result.results.entries()) {
				lines.push(`## Result ${index + 1}: ${item.title || item.url}`);
				lines.push(`URL: ${item.url}`);
				if (item.publishedDate) lines.push(`Published: ${item.publishedDate}`);
				if (item.author) lines.push(`Author: ${item.author}`);
				if (item.text) {
					lines.push("");
					lines.push(item.text.trim());
				}
				lines.push("");
			}

			if (result.results.length === 0) {
				lines.push("No results found.");
			}

			const rendered = lines.join("\n").trim();
			const truncated = truncateToolOutput("pi-websearch", rendered);

			return {
				content: [{ type: "text", text: truncated.text }],
				details: {
					ok: true,
					query: params.query,
					executedQuery: query,
					numResults,
					maxTokens,
					maxCharacters,
					includeDomains,
					excludeDomains,
					startPublishedDate,
					endPublishedDate,
					country: params.country?.trim()?.toUpperCase(),
					results: result.results.map((item) => ({
						title: item.title,
						url: item.url,
						publishedDate: item.publishedDate,
						author: item.author,
					})),
					truncation: truncated.truncation,
					fullOutputPath: truncated.fullOutputPath,
				},
			};
		},
	});
}
