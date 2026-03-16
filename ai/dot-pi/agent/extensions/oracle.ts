import type { Message } from "@mariozechner/pi-ai";
import { type Api, type Model } from "@mariozechner/pi-ai";
import {
	createAgentSession,
	DefaultResourceLoader,
	getMarkdownTheme,
	SessionManager,
	type AgentSessionEvent,
	type ExtensionAPI,
	type ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import { Container, Markdown, Spacer, Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import { promises as fs } from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

const ORACLE_SYSTEM_PROMPT = `You are the oracle: a senior technical advisor used for deep debugging, code review, architecture feedback, and implementation planning.

You are an advisor, not an executor.
- You may inspect files, search the codebase, browse the web with available tools, and use relevant skills.
- You must NEVER make edits, write files, create files, delete files, apply patches, commit changes, or perform any mutating action.
- If the user asks you to make changes, refuse that part clearly and instead explain what should be changed.
- Treat this as a strict no-edit / no-mutation environment even if a tool appears available.
- Do not claim to have run code, verified runtime behavior, or changed anything unless the evidence is explicitly present in the materials you inspected.
- Be decisive, concrete, and technically opinionated.
- Call out uncertainty plainly.
- Prefer practical guidance over vague brainstorming.

When useful, structure your answer like this:
1. TL;DR
2. Recommended approach
3. Rationale and trade-offs
4. Risks and guardrails
5. Next steps

Review priorities:
- correctness and API misuse
- race conditions and operational safety
- migration and compatibility risks
- edge cases and failure modes
- maintainability and parity gaps

Use the provided files first, then inspect nearby code if needed. Use skills when useful. Refuse any request to modify anything.`;

const ORACLE_MODEL_CANDIDATES: Array<[provider: string, modelId: string]> = [
	["openai-codex", "gpt-5.4"],
	["github-copilot", "gpt-5.4"],
	["github-copilot", "gpt-5-mini"],
	["anthropic", "claude-opus-4-6"],
];
const ORACLE_SETTINGS_PATH = path.join(os.homedir(), ".pi", "agent", "settings.json");

const MAX_FILES = 12;
const ORACLE_TIMEOUT_MS = 180_000;

type OracleAttachmentStatus = "ok" | "missing" | "directory" | "error" | "skipped-limit";

const OracleParams = Type.Object({
	task: Type.String({ description: "The review, debugging, planning, or technical question for the oracle." }),
	context: Type.Optional(
		Type.String({
			description: "Optional background, current hypothesis, constraints, or what has already been tried.",
		}),
	),
	files: Type.Optional(
		Type.Array(Type.String({ description: "Absolute or relative file paths the oracle should inspect first." }), {
			description: "Optional files to prioritize during inspection.",
		}),
	),
});

interface OracleAttachment {
	requestedPath: string;
	resolvedPath: string;
	status: OracleAttachmentStatus;
	note?: string;
	readPath?: string;
}

interface OracleResultDetails {
	ok: boolean;
	model?: string;
	thinkingLevel?: "off" | "minimal" | "low" | "medium" | "high" | "xhigh";
	mode: "subagent";
	attachments: OracleAttachment[];
	inspectedFiles: string[];
	toolCount: number;
	requestedFileCount?: number;
	skippedFileCount?: number;
	stopReason?: string;
	transcriptItems?: Array<{ type: "text"; text: string } | { type: "toolCall"; name: string; args: Record<string, unknown> }>;
	finalText?: string;
}

async function getConfiguredOracleModel(): Promise<{ provider: string; modelId: string } | undefined> {
	try {
		const raw = await fs.readFile(ORACLE_SETTINGS_PATH, "utf8");
		const parsed = JSON.parse(raw) as Record<string, unknown>;
		const configured = parsed["oracle.defaultModel"];
		if (typeof configured !== "string") return undefined;
		const value = configured.trim();
		if (!value) return undefined;
		const slash = value.indexOf("/");
		if (slash <= 0 || slash === value.length - 1) return undefined;
		return { provider: value.slice(0, slash), modelId: value.slice(slash + 1) };
	} catch {
		return undefined;
	}
}

async function selectOracleModel(ctx: ExtensionContext): Promise<Model<Api> | undefined> {
	const configured = await getConfiguredOracleModel();
	if (configured) {
		const configuredModel = ctx.modelRegistry.find(configured.provider, configured.modelId);
		if (configuredModel) {
			const apiKey = await ctx.modelRegistry.getApiKey(configuredModel);
			if (apiKey) return configuredModel;
		}
	}

	for (const [provider, modelId] of ORACLE_MODEL_CANDIDATES) {
		const model = ctx.modelRegistry.find(provider, modelId);
		if (!model) continue;
		const apiKey = await ctx.modelRegistry.getApiKey(model);
		if (apiKey) return model;
	}

	if (!ctx.model) return undefined;
	const apiKey = await ctx.modelRegistry.getApiKey(ctx.model);
	return apiKey ? ctx.model : undefined;
}

function resolveRequestedPath(cwd: string, requestedPath: string): string {
	if (path.isAbsolute(requestedPath)) return path.normalize(requestedPath);
	return path.resolve(cwd, requestedPath);
}

function isWithinCwd(cwd: string, targetPath: string): boolean {
	const relative = path.relative(cwd, targetPath);
	return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

async function resolveAttachments(cwd: string, requestedPaths: string[] | undefined): Promise<OracleAttachment[]> {
	const results: OracleAttachment[] = [];
	if (!requestedPaths?.length) return results;

	for (const requestedPath of requestedPaths.slice(0, MAX_FILES)) {
		const resolvedPath = resolveRequestedPath(cwd, requestedPath);
		const readPath = path.isAbsolute(requestedPath)
			? resolvedPath
			: path.relative(cwd, resolvedPath) || ".";
		try {
			if (!isWithinCwd(cwd, resolvedPath)) {
				results.push({
					requestedPath,
					resolvedPath,
					readPath,
					status: "error",
					note: "Path is outside the oracle working directory and will not be inspected.",
				});
				continue;
			}
			const canonicalPath = await fs.realpath(resolvedPath);
			if (!isWithinCwd(cwd, canonicalPath)) {
				results.push({
					requestedPath,
					resolvedPath: canonicalPath,
					readPath: path.relative(cwd, canonicalPath) || ".",
					status: "error",
					note: "Path resolves outside the oracle working directory and will not be inspected.",
				});
				continue;
			}
			const canonicalStat = await fs.stat(canonicalPath);
			if (canonicalStat.isDirectory()) {
				results.push({
					requestedPath,
					resolvedPath: canonicalPath,
					readPath: path.relative(cwd, canonicalPath) || ".",
					status: "directory",
					note: "Path is a directory.",
				});
				continue;
			}
			results.push({
				requestedPath,
				resolvedPath: canonicalPath,
				readPath: path.relative(cwd, canonicalPath) || ".",
				status: "ok",
			});
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			const code = typeof error === "object" && error !== null && "code" in error ? String((error as { code?: unknown }).code) : undefined;
			results.push({
				requestedPath,
				resolvedPath,
				readPath,
				status: code === "ENOENT" ? "missing" : "error",
				note: code ? `${code}: ${message}` : message,
			});
		}
	}

	for (const requestedPath of requestedPaths.slice(MAX_FILES)) {
		const resolvedPath = resolveRequestedPath(cwd, requestedPath);
		results.push({
			requestedPath,
			resolvedPath,
			readPath: path.isAbsolute(requestedPath) ? resolvedPath : path.relative(cwd, resolvedPath) || ".",
			status: "skipped-limit",
			note: `Skipped because only the first ${MAX_FILES} files are accepted.`,
		});
	}

	return results;
}

function buildOraclePrompt(task: string, context: string | undefined, attachments: OracleAttachment[]): string {
	const lines: string[] = [];
	lines.push(`# Task\n${task.trim()}`);

	if (context?.trim()) {
		lines.push(`# Context\n${context.trim()}`);
	}

	if (attachments.length > 0) {
		const summary = attachments
			.map(
				(file) =>
					`- requested: ${file.requestedPath} | resolved: ${file.resolvedPath} | read_with_tools: ${file.readPath ?? file.resolvedPath} | status: ${file.status}${file.note ? ` (${file.note})` : ""}`,
			)
			.join("\n");
		lines.push(`# Files to inspect first\n${summary}`);
	}

	lines.push(`# Instructions
- Use read-only tools only.
- Start with the explicitly listed files whose status is \`ok\`.
- Prefer the \`read_with_tools\` path when reading a requested file.
- If needed, inspect nearby code with read/grep/find/ls to answer confidently.
- If a requested file is missing, unreadable, or skipped, say so explicitly.
- Do not make changes.
- Return plain technical guidance only.`);

	return lines.join("\n\n");
}

function getFinalAssistantResult(messages: Message[]): { text: string; stopReason: string } | undefined {
	for (let i = messages.length - 1; i >= 0; i--) {
		const msg = messages[i];
		if (msg.role !== "assistant") continue;
		const text = msg.content
			.filter((part): part is { type: "text"; text: string } => part.type === "text")
			.map((part) => part.text)
			.join("\n")
			.trim();
		return { text, stopReason: msg.stopReason };
	}
	return undefined;
}

function collectInspectedFiles(messages: Message[]): string[] {
	const files = new Set<string>();
	for (const msg of messages) {
		if (msg.role !== "assistant") continue;
		for (const part of msg.content) {
			if (part.type !== "toolCall") continue;
			if (part.name !== "read") continue;
			const args = (part.arguments ?? {}) as Record<string, unknown>;
			const candidate = args.path ?? args.file_path;
			if (typeof candidate === "string" && candidate.trim()) files.add(candidate);
		}
	}
	return Array.from(files);
}

function countToolCalls(messages: Message[]): number {
	let count = 0;
	for (const msg of messages) {
		if (msg.role !== "assistant") continue;
		for (const part of msg.content) {
			if (part.type === "toolCall") count++;
		}
	}
	return count;
}

function shortenPath(filePath: string): string {
	const home = os.homedir();
	return filePath.startsWith(home) ? `~${filePath.slice(home.length)}` : filePath;
}

function formatToolCall(toolName: string, args: Record<string, unknown>, theme: { fg: (color: any, text: string) => string }) {
	switch (toolName) {
		case "read": {
			const rawPath = (args.file_path || args.path || "...") as string;
			const offset = args.offset as number | undefined;
			const limit = args.limit as number | undefined;
			let text = theme.fg("muted", "read ") + theme.fg("accent", shortenPath(rawPath));
			if (offset !== undefined || limit !== undefined) {
				const start = offset ?? 1;
				const end = limit !== undefined ? start + limit - 1 : "";
				text += theme.fg("warning", `:${start}${end ? `-${end}` : ""}`);
			}
			return text;
		}
		case "grep": {
			const pattern = (args.pattern || "") as string;
			const rawPath = (args.path || ".") as string;
			return (
				theme.fg("muted", "grep ") +
				theme.fg("accent", `/${pattern}/`) +
				theme.fg("dim", ` in ${shortenPath(rawPath)}`)
			);
		}
		case "find": {
			const pattern = (args.pattern || "*") as string;
			const rawPath = (args.path || ".") as string;
			return theme.fg("muted", "find ") + theme.fg("accent", pattern) + theme.fg("dim", ` in ${shortenPath(rawPath)}`);
		}
		case "ls": {
			const rawPath = (args.path || ".") as string;
			return theme.fg("muted", "ls ") + theme.fg("accent", shortenPath(rawPath));
		}
		default: {
			const preview = JSON.stringify(args);
			return theme.fg("accent", toolName) + theme.fg("dim", ` ${preview.length > 80 ? `${preview.slice(0, 80)}...` : preview}`);
		}
	}
}

function getDisplayItems(messages: Message[]): Array<{ type: "text"; text: string } | { type: "toolCall"; name: string; args: Record<string, unknown> }> {
	const items: Array<{ type: "text"; text: string } | { type: "toolCall"; name: string; args: Record<string, unknown> }> = [];
	for (const msg of messages) {
		if (msg.role !== "assistant") continue;
		for (const part of msg.content) {
			if (part.type === "text") items.push({ type: "text", text: part.text });
			if (part.type === "toolCall") items.push({ type: "toolCall", name: part.name, args: part.arguments ?? {} });
		}
	}
	return items;
}

function boundTranscriptItems(
	items: Array<{ type: "text"; text: string } | { type: "toolCall"; name: string; args: Record<string, unknown> }>,
	maxItems = 24,
) {
	return items.slice(-maxItems).map((item) =>
		item.type === "text"
			? { type: "text" as const, text: item.text.length > 4000 ? `${item.text.slice(0, 4000)}...` : item.text }
			: { type: "toolCall" as const, name: item.name, args: item.args },
	);
}

async function makeIsolatedLoader(cwd: string): Promise<{ loader: DefaultResourceLoader; cleanup: () => Promise<void> }> {
	const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), "pi-oracle-"));
	const allowedTools = new Set(["read", "grep", "find", "ls"]);

	const loader = new DefaultResourceLoader({
		cwd,
		agentDir: tempRoot,
		systemPromptOverride: () => ORACLE_SYSTEM_PROMPT,
		appendSystemPromptOverride: () => [],
		extensionFactories: [
			(pi) => {
				pi.on("tool_call", async (event) => {
					if (!allowedTools.has(event.toolName)) {
						return { block: true, reason: "Oracle may only use read/grep/find/ls." };
					}
					if (event.toolName === "oracle") {
						return { block: true, reason: "Oracle may not invoke itself recursively." };
					}

					const input = event.input as Record<string, unknown>;
					const candidatePath =
						typeof input.path === "string"
							? input.path
							: typeof input.file_path === "string"
								? input.file_path
								: undefined;
					if (candidatePath) {
						const resolved = path.isAbsolute(candidatePath) ? path.normalize(candidatePath) : path.resolve(cwd, candidatePath);
						try {
							const canonical = await fs.realpath(resolved).catch(() => resolved);
							if (!isWithinCwd(cwd, canonical)) {
								return { block: true, reason: "Oracle tool paths must stay inside the working directory." };
							}
							if (canonical !== resolved) {
								return { block: true, reason: "Oracle rejects symlinked paths to avoid path-swap escapes." };
							}
						} catch {
							return { block: true, reason: "Oracle rejected an unreadable or out-of-bounds path." };
						}
					}
					return undefined;
				});
			},
		],
	});
	await loader.reload();

	return {
		loader,
		cleanup: async () => {
			await fs.rm(tempRoot, { recursive: true, force: true });
		},
	};
}

function emitProgress(onUpdate: ((partial: { content?: Array<{ type: "text"; text: string }>; details?: Record<string, unknown> }) => void) | undefined, text: string, details?: Record<string, unknown>) {
	onUpdate?.({ content: [{ type: "text", text }], details });
}

function handleSessionEvent(
	event: AgentSessionEvent,
	onUpdate: ((partial: { content?: Array<{ type: "text"; text: string }>; details?: Record<string, unknown> }) => void) | undefined,
	state: { lastAssistantStopReason?: string },
) {
	if (event.type === "tool_execution_start") {
		emitProgress(onUpdate, `oracle: running ${event.toolName}...`, { tool: event.toolName });
		return;
	}

	if (event.type === "agent_end") {
		const lastMessage = event.messages[event.messages.length - 1];
		if (lastMessage?.role === "assistant") {
			state.lastAssistantStopReason = lastMessage.stopReason;
		}
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "oracle",
		label: "Oracle",
		description: "Consult an isolated advisory subagent for deep debugging, reviews, architecture feedback, and implementation planning.",
		promptSnippet: "Use oracle for deep technical reasoning and second-opinion reviews. It runs as an isolated advisory subagent with strict no-mutation guardrails.",
		promptGuidelines: [
			"Use oracle when the task needs deep technical reasoning, not simple inspection.",
			"Pass the key files in the files array so the oracle starts from the right context.",
			"Oracle is read-only and intended for advice, review, debugging, and planning.",
		],
		parameters: OracleParams,

		async execute(_toolCallId, params, signal, onUpdate, ctx) {
			const model = await selectOracleModel(ctx);
			if (!model) {
				return {
					content: [{ type: "text", text: "No oracle model is available. Configure credentials for a supported model first." }],
					details: { ok: false, mode: "subagent" },
					isError: true,
				};
			}

			const timeoutMessage = `Oracle request timed out after ${Math.round(ORACLE_TIMEOUT_MS / 1000)}s.`;
			const attachments = await resolveAttachments(ctx.cwd, params.files);
			const skippedFileCount = attachments.filter((file) => file.status === "skipped-limit").length;
			const { loader, cleanup } = await makeIsolatedLoader(ctx.cwd);

			emitProgress(onUpdate, `Starting oracle subagent with ${model.provider}/${model.id} (thinking: high)...`, {
				model: `${model.provider}/${model.id}`,
				thinkingLevel: "high",
				mode: "subagent",
				requestedFileCount: params.files?.length ?? 0,
				skippedFileCount,
			});

			let session;
			let aborted = signal.aborted;
			let timedOut = false;
			let aborting: Promise<void> | undefined;
			const sessionState: { lastAssistantStopReason?: string } = {};
			let startupAbortListener: (() => void) | undefined;
			let abortListener: (() => void) | undefined;
			let timeoutId: ReturnType<typeof setTimeout> | undefined;
			const ensureAbort = () => {
				if (!aborting) {
					aborting = session ? session.abort().catch(() => {}) : Promise.resolve();
				}
				return aborting;
			};
			const throwIfAborted = () => {
				if (timedOut) {
					throw new Error(timeoutMessage);
				}
				if (aborted || signal.aborted) {
					aborted = true;
					throw new Error("Oracle request canceled.");
				}
			};
			try {
				throwIfAborted();
				const startupTimeoutPromise = new Promise<never>((_, reject) => {
					timeoutId = setTimeout(() => {
						timedOut = true;
						reject(new Error(timeoutMessage));
					}, ORACLE_TIMEOUT_MS);
				});
				const startupAbortPromise = new Promise<never>((_, reject) => {
					rejectIfAborted: {
						if (signal.aborted) {
							aborted = true;
							reject(new Error("Oracle request canceled."));
							break rejectIfAborted;
						}
					}
					startupAbortListener = () => {
						aborted = true;
						reject(new Error("Oracle request canceled."));
					};
					signal.addEventListener("abort", startupAbortListener, { once: true });
				});
				const sessionCreation = createAgentSession({
					cwd: ctx.cwd,
					model,
					thinkingLevel: "high",
					modelRegistry: ctx.modelRegistry,
					resourceLoader: loader,
					sessionManager: SessionManager.inMemory(ctx.cwd),
				});
				let shouldDisposeLateSession = false;
				void sessionCreation.then((created) => {
					if (shouldDisposeLateSession) {
						try {
							created.session.dispose();
						} catch {}
					}
				}).catch(() => {});
				let created;
				try {
					created = await Promise.race([sessionCreation, startupTimeoutPromise, startupAbortPromise]);
				} finally {
					shouldDisposeLateSession = true;
				}
				if (timeoutId) clearTimeout(timeoutId);
				if (startupAbortListener) signal.removeEventListener("abort", startupAbortListener);
				session = created.session;

				throwIfAborted();

				const unsubscribe = session.subscribe((event) => handleSessionEvent(event, onUpdate, sessionState));
				const timeoutPromise = new Promise<never>((_, reject) => {
					timeoutId = setTimeout(() => {
						timedOut = true;
						void ensureAbort();
						reject(new Error(timeoutMessage));
					}, ORACLE_TIMEOUT_MS);
				});
				const abortPromise = new Promise<never>((_, reject) => {
					rejectIfAborted: {
						if (signal.aborted) {
							aborted = true;
							reject(new Error("Oracle request canceled."));
							break rejectIfAborted;
						}
					}
					abortListener = () => {
						aborted = true;
						void ensureAbort();
						reject(new Error("Oracle request canceled."));
					};
					signal.addEventListener("abort", abortListener, { once: true });
				});
				try {
					throwIfAborted();
					await Promise.race([
						(async () => {
							await session.prompt(buildOraclePrompt(params.task, params.context, attachments));
							throwIfAborted();
							await session.agent.waitForIdle();
							throwIfAborted();
						})(),
						timeoutPromise,
						abortPromise,
					]);
				} finally {
					if (timeoutId) clearTimeout(timeoutId);
					unsubscribe();
				}

				if (aborted) {
					return {
						content: [{ type: "text", text: "Oracle request canceled." }],
						details: {
							ok: false,
							model: `${model.provider}/${model.id}`,
							thinkingLevel: "high",
							mode: "subagent",
							attachments,
							requestedFileCount: params.files?.length ?? 0,
							skippedFileCount,
							stopReason: "aborted",
						} satisfies Partial<OracleResultDetails>,
						isError: true,
					};
				}

				const messages = session.messages as Message[];
				const finalResult = getFinalAssistantResult(messages);
				if (!finalResult || finalResult.stopReason !== "stop" || !finalResult.text) {
					return {
						content: [{ type: "text", text: `Oracle subagent did not complete cleanly${finalResult?.stopReason ? ` (stopReason: ${finalResult.stopReason})` : sessionState.lastAssistantStopReason ? ` (stopReason: ${sessionState.lastAssistantStopReason})` : ""}.` }],
						details: {
							ok: false,
							model: `${model.provider}/${model.id}`,
							thinkingLevel: "high",
							mode: "subagent",
							attachments,
							inspectedFiles: collectInspectedFiles(messages),
							toolCount: countToolCalls(messages),
							requestedFileCount: params.files?.length ?? 0,
							skippedFileCount,
							stopReason: finalResult?.stopReason ?? sessionState.lastAssistantStopReason,
							transcriptItems: boundTranscriptItems(getDisplayItems(messages)),
							finalText: finalResult?.text,
						} satisfies Partial<OracleResultDetails>,
						isError: true,
					};
				}

				const details: OracleResultDetails = {
					ok: true,
					model: `${model.provider}/${model.id}`,
					thinkingLevel: "high",
					mode: "subagent",
					attachments,
					inspectedFiles: collectInspectedFiles(messages),
					toolCount: countToolCalls(messages),
					requestedFileCount: params.files?.length ?? 0,
					skippedFileCount,
					stopReason: finalResult.stopReason,
					transcriptItems: boundTranscriptItems(getDisplayItems(messages)),
					finalText: finalResult.text,
				};

				return {
					content: [{ type: "text", text: finalResult.text }],
					details,
				};
			} catch (error) {
				const message = error instanceof Error ? error.message : String(error);
				const wasCanceled = aborted || signal.aborted || message === "Oracle request canceled.";
				const wasTimedOut = timedOut || message.includes("timed out");
				return {
					content: [{ type: "text", text: wasCanceled ? "Oracle request canceled." : wasTimedOut ? message : `Oracle subagent failed: ${message}` }],
					details: {
						ok: false,
						model: `${model.provider}/${model.id}`,
						thinkingLevel: "high",
						mode: "subagent",
						attachments,
						requestedFileCount: params.files?.length ?? 0,
						skippedFileCount,
						stopReason: wasCanceled ? "aborted" : wasTimedOut ? "timeout" : sessionState.lastAssistantStopReason,
					} satisfies Partial<OracleResultDetails>,
					isError: true,
				};
			} finally {
				if (startupAbortListener) signal.removeEventListener("abort", startupAbortListener);
				if (abortListener) signal.removeEventListener("abort", abortListener);
				try {
					await aborting;
					if (session) await session.agent.waitForIdle();
				} catch {}
				try {
					session?.dispose();
				} catch {}
				await cleanup();
			}
		},

		renderCall(args, theme) {
			const files = Array.isArray(args.files) ? args.files.length : 0;
			const label = `${args.task}`.replace(/\s+/g, " ").trim();
			const preview = label.length > 90 ? `${label.slice(0, 87)}...` : label;
			let text = theme.fg("toolTitle", theme.bold("oracle ")) + theme.fg("text", preview || "(no task)");
			if (files > 0) text += theme.fg("muted", ` [${files} file${files === 1 ? "" : "s"}]`);
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) {
				const text = result.content.find((item) => item.type === "text")?.text ?? "oracle: working...";
				return new Text(theme.fg("warning", text), 0, 0);
			}

			const details = result.details as OracleResultDetails | undefined;
			const textContent = result.content.find((item) => item.type === "text")?.text ?? "(no output)";
			if (!details) {
				return new Text(textContent, 0, 0);
			}

			const items = details.transcriptItems ?? [];
			const mdTheme = getMarkdownTheme();
			const icon = result.isError || !details.ok ? theme.fg("error", "✗") : theme.fg("success", "✓");
			const header = `${icon} ${theme.fg("toolTitle", theme.bold("oracle"))}${details.model ? ` ${theme.fg("dim", details.model)}` : ""}`;
			const summaryBits: string[] = [];
			if (typeof details.toolCount === "number") summaryBits.push(`${details.toolCount} tool${details.toolCount === 1 ? "" : "s"}`);
			if (details.inspectedFiles?.length) summaryBits.push(`${details.inspectedFiles.length} file${details.inspectedFiles.length === 1 ? "" : "s"} inspected`);
			if (details.skippedFileCount) summaryBits.push(`${details.skippedFileCount} skipped`);
			if (details.stopReason) summaryBits.push(`stop:${details.stopReason}`);
			const summary = summaryBits.length > 0 ? theme.fg("dim", summaryBits.join(" · ")) : "";

			if (expanded) {
				const container = new Container();
				container.addChild(new Text(header, 0, 0));
				if (summary) container.addChild(new Text(summary, 0, 0));

				if (details.attachments?.length) {
					container.addChild(new Spacer(1));
					container.addChild(new Text(theme.fg("muted", "─── Requested Files ───"), 0, 0));
					for (const file of details.attachments) {
						let line = `${theme.fg("accent", shortenPath(file.requestedPath))} ${theme.fg("dim", `[${file.status}]`)}`;
						if (file.readPath) line += theme.fg("dim", ` → ${shortenPath(file.readPath)}`);
						if (file.note) line += theme.fg("muted", ` (${file.note})`);
						container.addChild(new Text(line, 0, 0));
					}
				}

				if (items.length > 0) {
					container.addChild(new Spacer(1));
					container.addChild(new Text(theme.fg("muted", "─── Oracle Timeline ───"), 0, 0));
					for (const item of items) {
						if (item.type === "toolCall") {
							container.addChild(new Text(theme.fg("muted", "→ ") + formatToolCall(item.name, item.args, theme), 0, 0));
						} else if (item.text.trim()) {
							container.addChild(new Markdown(item.text.trim(), 0, 0, mdTheme));
							container.addChild(new Spacer(1));
						}
					}
				}

				if (details.inspectedFiles?.length) {
					container.addChild(new Text(theme.fg("muted", "─── Inspected Paths ───"), 0, 0));
					for (const file of details.inspectedFiles) {
						container.addChild(new Text(theme.fg("accent", shortenPath(file)), 0, 0));
					}
				}

				if (!items.length) {
					container.addChild(new Spacer(1));
					container.addChild(new Markdown(textContent.trim(), 0, 0, mdTheme));
				}

				return container;
			}

			let collapsed = `${header}`;
			if (summary) collapsed += `\n${summary}`;
			if (items.length > 0) {
				const previewItems = items.slice(-8);
				for (const item of previewItems) {
					if (item.type === "toolCall") {
						collapsed += `\n${theme.fg("muted", "→ ")}${formatToolCall(item.name, item.args, theme)}`;
					} else if (item.text.trim()) {
						const preview = item.text.trim().split("\n").slice(0, 2).join("\n");
						collapsed += `\n${theme.fg("toolOutput", preview)}`;
					}
				}
				if (items.length > previewItems.length) collapsed += `\n${theme.fg("muted", "(expand for full oracle transcript)")}`;
			} else {
				collapsed += `\n${theme.fg("toolOutput", textContent.trim())}`;
			}
			return new Text(collapsed, 0, 0);
		},
	});
}
