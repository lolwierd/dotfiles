import { exec } from "node:child_process";
import { basename } from "node:path";
import { promisify } from "node:util";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import { CustomEditor, type ExtensionAPI, type ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const execAsync = promisify(exec);

const EXTENSION_ID = "atelier";
const THEME_DARK = "introspective-ink";
const THEME_LIGHT = "introspective-paper";
const POLL_MS = 2500;
const CLOCK_TICK_MS = 1000;

const ANSI = {
	accent: "\x1b[38;2;209;154;102m",
	dim: "\x1b[2m",
	reset: "\x1b[0m",
};

let chromeEnabled = true;
let autoThemeEnabled = process.platform === "darwin";
let themePoller: ReturnType<typeof setInterval> | null = null;
let lastSystemDark: boolean | undefined;
let chromeLayoutMounted = false;
let editorMounted = false;

let turns = 0;
let inFlight = false;
let usage = { input: 0, output: 0, cost: 0, cacheRead: 0, cacheWrite: 0 };
let liveUsage: { input: number; output: number; cost: number; cacheRead: number; cacheWrite: number } | null = null;
let activeProvider = "";
let activeModel = "";
let activeContextWindow = 0;
let activeCwd = "";
let sessionStartedAt = Date.now();
let currentTurnStartedAt: number | null = null;
let lastTurnDurationMs = 0;

type TokenEstimateMethod = "tiktoken" | "est";
type TokenEstimate = { count: number; method: TokenEstimateMethod };

let tiktokenModule: Record<string, unknown> | null = null;
let tiktokenLoadStarted = false;
const tokenEncoderCache = new Map<string, unknown>();
let lastTokenEstimateModel = "";
let lastTokenEstimateText = "";
let lastTokenEstimateResult: TokenEstimate = { count: 0, method: "est" };

const estimateTokensCheap = (text: string): number => {
	const trimmed = text.trim();
	if (!trimmed) return 0;
	return Math.max(1, Math.round(trimmed.length / 4));
};

const normalizeModelId = (modelId: string): string => {
	const trimmed = modelId.trim().toLowerCase();
	if (!trimmed) return "";
	const slash = trimmed.lastIndexOf("/");
	return slash >= 0 ? trimmed.slice(slash + 1) : trimmed;
};

const fallbackEncodingForModel = (modelId: string): "o200k_base" | "cl100k_base" | null => {
	const normalized = normalizeModelId(modelId);
	if (!normalized) return null;
	if (
		normalized.includes("gpt-5") ||
		normalized.includes("gpt-4o") ||
		normalized.includes("gpt-4.1") ||
		normalized.startsWith("o1") ||
		normalized.startsWith("o3") ||
		normalized.startsWith("o4")
	) {
		return "o200k_base";
	}
	if (normalized.includes("gpt-4") || normalized.includes("gpt-3.5")) {
		return "cl100k_base";
	}
	return null;
};

const ensureTokenizerLoaded = async () => {
	if (tiktokenLoadStarted) return;
	tiktokenLoadStarted = true;
	try {
		tiktokenModule = (await import("js-tiktoken")) as Record<string, unknown>;
	} catch {
		tiktokenModule = null;
	}
};

const getTiktokenEncoder = (modelId: string): { encode: (text: string) => number[] } | null => {
	if (!tiktokenModule) return null;
	const normalized = normalizeModelId(modelId);
	if (!normalized) return null;

	const cached = tokenEncoderCache.get(normalized);
	if (cached) return cached as { encode: (text: string) => number[] };

	const encodingForModel = tiktokenModule.encodingForModel as ((name: string) => unknown) | undefined;
	const getEncoding = tiktokenModule.getEncoding as ((name: string) => unknown) | undefined;

	if (typeof encodingForModel === "function") {
		try {
			const encoder = encodingForModel(normalized) as { encode: (text: string) => number[] };
			tokenEncoderCache.set(normalized, encoder);
			return encoder;
		} catch {
			// fallback below
		}
	}

	const fallbackEncoding = fallbackEncodingForModel(normalized);
	if (fallbackEncoding && typeof getEncoding === "function") {
		try {
			const encoder = getEncoding(fallbackEncoding) as { encode: (text: string) => number[] };
			tokenEncoderCache.set(normalized, encoder);
			return encoder;
		} catch {
			return null;
		}
	}

	return null;
};

const estimatePromptTokens = (text: string, modelId: string): TokenEstimate => {
	const trimmed = text.trim();
	if (!trimmed) {
		lastTokenEstimateModel = modelId;
		lastTokenEstimateText = "";
		lastTokenEstimateResult = { count: 0, method: "est" };
		return lastTokenEstimateResult;
	}

	if (lastTokenEstimateModel === modelId && lastTokenEstimateText === trimmed) {
		return lastTokenEstimateResult;
	}

	const encoder = getTiktokenEncoder(modelId);
	if (encoder) {
		try {
			lastTokenEstimateModel = modelId;
			lastTokenEstimateText = trimmed;
			lastTokenEstimateResult = { count: encoder.encode(trimmed).length, method: "tiktoken" };
			return lastTokenEstimateResult;
		} catch {
			// fallback below
		}
	}

	lastTokenEstimateModel = modelId;
	lastTokenEstimateText = trimmed;
	lastTokenEstimateResult = { count: estimateTokensCheap(trimmed), method: "est" };
	return lastTokenEstimateResult;
};

const formatDuration = (ms: number): string => {
	const totalSeconds = Math.max(0, Math.floor(ms / 1000));
	const hours = Math.floor(totalSeconds / 3600);
	const minutes = Math.floor((totalSeconds % 3600) / 60);
	const seconds = totalSeconds % 60;

	if (hours > 0) return `${hours}:${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
	return `${minutes}:${seconds.toString().padStart(2, "0")}`;
};

const getCurrentTurnDurationMs = (): number => {
	if (!currentTurnStartedAt) return 0;
	return Date.now() - currentTurnStartedAt;
};

const getSessionDurationMs = (): number => Math.max(0, Date.now() - sessionStartedAt);

class AtelierEditor extends CustomEditor {
	constructor(tui: ConstructorParameters<typeof CustomEditor>[0], theme: ConstructorParameters<typeof CustomEditor>[1], keybindings: ConstructorParameters<typeof CustomEditor>[2]) {
		super(tui, theme, keybindings);
		this.setPaddingX(2);
	}

	render(width: number): string[] {
		const base = super.render(width);
		const text = this.getText();
		const tokenEstimate = estimatePromptTokens(text, activeModel);
		const tokenLabel = tokenEstimate.method === "tiktoken" ? `${tokenEstimate.count} tok` : `~${tokenEstimate.count} tok`;
		const methodLabel = tokenEstimate.method === "tiktoken" ? "tt" : "est";
		const turnTimeLabel = inFlight && currentTurnStartedAt ? `turn ${formatDuration(getCurrentTurnDurationMs())}` : lastTurnDurationMs > 0 ? `last ${formatDuration(lastTurnDurationMs)}` : "turn --";
		const titleLeft = `${ANSI.accent}prompt${ANSI.reset}${ANSI.dim} ${tokenLabel} · ${methodLabel} · ${turnTimeLabel}${ANSI.reset}`;
		const titleRight = activeCwd ? `${ANSI.dim}cwd ${activeCwd}${ANSI.reset}` : "";
		const title = titleRight ? joinLR(titleLeft, titleRight, width) : titleLeft;
		return [truncateToWidth(title, width), ...base];
	}
}

const formatCount = (n: number): string => {
	if (n < 1_000) return `${n}`;
	if (n < 1_000_000) return `${(n / 1_000).toFixed(1)}k`;
	return `${(n / 1_000_000).toFixed(1)}m`;
};

const formatProviderModel = (provider?: string, modelId?: string): string => {
	const p = (provider || "").trim();
	const m = (modelId || "").trim();
	if (!m) return "no-model";
	if (m.includes("/")) return m;
	return p ? `${p}/${m}` : m;
};

const renderThinkingLevel = (theme: { fg: (color: string, text: string) => string }, thinking: string): string => {
	switch (thinking.toLowerCase()) {
		case "off":
			return theme.fg("thinkingOff", thinking);
		case "minimal":
			return theme.fg("thinkingMinimal", thinking);
		case "low":
			return theme.fg("thinkingLow", thinking);
		case "medium":
			return theme.fg("thinkingMedium", thinking);
		case "high":
			return theme.fg("thinkingHigh", thinking);
		case "xhigh":
			return theme.fg("thinkingXhigh", thinking);
		default:
			return theme.fg("muted", thinking);
	}
};

const joinLR = (left: string, right: string, width: number): string => {
	const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
	return truncateToWidth(`${left}${pad}${right}`, width);
};

const recalcSessionStats = (ctx: ExtensionContext) => {
	let input = 0;
	let output = 0;
	let cost = 0;
	let cacheRead = 0;
	let cacheWrite = 0;
	let assistantMessages = 0;

	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		assistantMessages++;
		const msg = entry.message as AssistantMessage;
		input += msg.usage.input;
		output += msg.usage.output;
		cost += msg.usage.cost.total;
		cacheRead += msg.usage.cacheRead;
		cacheWrite += msg.usage.cacheWrite;
	}

	turns = assistantMessages;
	usage = { input, output, cost, cacheRead, cacheWrite };
};

const getSystemDarkMode = async (): Promise<boolean | undefined> => {
	if (process.platform !== "darwin") return undefined;
	try {
		const { stdout } = await execAsync(
			"osascript -e 'tell application \"System Events\" to tell appearance preferences to return dark mode'",
		);
		return stdout.trim() === "true";
	} catch {
		return undefined;
	}
};

const setThemeByName = (ctx: ExtensionContext, name: string): boolean => {
	const result = ctx.ui.setTheme(name);
	if (!result.success) {
		ctx.ui.notify(`Failed to switch theme: ${result.error}`, "error");
		return false;
	}
	return true;
};

const stopThemePolling = () => {
	if (themePoller) {
		clearInterval(themePoller);
		themePoller = null;
	}
};

const syncThemeToSystem = async (ctx: ExtensionContext) => {
	if (!ctx.hasUI || !autoThemeEnabled || process.platform !== "darwin") return;
	const isDark = await getSystemDarkMode();
	if (isDark === undefined) return;
	if (lastSystemDark === isDark) return;

	lastSystemDark = isDark;
	setThemeByName(ctx, isDark ? THEME_DARK : THEME_LIGHT);
};

const startThemePolling = (ctx: ExtensionContext) => {
	stopThemePolling();
	if (!ctx.hasUI || !autoThemeEnabled || process.platform !== "darwin") return;

	void syncThemeToSystem(ctx);
	themePoller = setInterval(() => {
		void syncThemeToSystem(ctx);
	}, POLL_MS);
};

const getHeaderResources = (pi: ExtensionAPI, ctx: ExtensionContext) => {
	const commands = pi.getCommands();
	const skills = new Set<string>();
	const extensions = new Set<string>();

	for (const command of commands) {
		if (command.source === "skill") {
			skills.add(command.name.replace(/^skill:/, ""));
		}
		if (command.source === "extension") {
			if (command.path) {
				const base = basename(command.path).replace(/\.(ts|js|mts|cts|mjs|cjs)$/i, "");
				extensions.add(base);
			} else {
				extensions.add(command.name);
			}
		}
	}

	const themes = ctx.ui.getAllThemes().map((theme) => theme.name).sort((a, b) => a.localeCompare(b));
	return {
		skills: Array.from(skills).sort((a, b) => a.localeCompare(b)),
		extensions: Array.from(extensions).sort((a, b) => a.localeCompare(b)),
		themes,
	};
};

const clearChrome = (ctx: ExtensionContext) => {
	if (!ctx.hasUI) return;
	ctx.ui.setHeader(undefined);
	ctx.ui.setFooter(undefined);
	ctx.ui.setStatus(EXTENSION_ID, undefined);
	ctx.ui.setWidget(`${EXTENSION_ID}-top`, undefined);
	ctx.ui.setWidget(`${EXTENSION_ID}-bottom`, undefined, { placement: "belowEditor" });
	ctx.ui.setEditorComponent(undefined);
	chromeLayoutMounted = false;
	editorMounted = false;
};

const applyChrome = (pi: ExtensionAPI, ctx: ExtensionContext) => {
	if (!ctx.hasUI || !chromeEnabled) return;
	activeCwd = ctx.cwd;

	if (!chromeLayoutMounted) {
		const resourceData = getHeaderResources(pi, ctx);

		ctx.ui.setHeader((_tui, theme) => ({
		render(width: number): string[] {
			const model = formatProviderModel(activeProvider || ctx.model?.provider, activeModel || ctx.model?.id);
			const thinking = pi.getThinkingLevel();
			const sessionName = pi.getSessionName() || "unnamed-session";
			const resourcesExpanded = ctx.ui.getToolsExpanded();
			const resourcesHint = resourcesExpanded ? "Ctrl+O hide resources" : "Ctrl+O show resources";

			const lines = [
				truncateToWidth(theme.fg("accent", theme.bold("pi atelier")), width),
				truncateToWidth(
					`${theme.fg("muted", sessionName)}${theme.fg("dim", " · ")}${theme.fg("muted", model)}${theme.fg("dim", " · thinking:")}${theme.fg("accent", thinking)}${theme.fg("dim", ` · ${resourcesHint}`)}`,
					width,
				),
			];

			if (resourcesExpanded) {
				const skills = resourceData.skills.length ? resourceData.skills.join(", ") : "none";
				const extensions = resourceData.extensions.length ? resourceData.extensions.join(", ") : "none";
				const themes = resourceData.themes.length ? resourceData.themes.join(", ") : "none";
				lines.push(truncateToWidth(`${theme.fg("dim", "[Skills]")} ${theme.fg("muted", skills)}`, width));
				lines.push(truncateToWidth(`${theme.fg("dim", "[Extensions]")} ${theme.fg("muted", extensions)}`, width));
				lines.push(truncateToWidth(`${theme.fg("dim", "[Themes]")} ${theme.fg("muted", themes)}`, width));
			}

			return lines;
		},
		invalidate() {},
	}));

	ctx.ui.setFooter((tui, theme, footerData) => {
		const unsub = footerData.onBranchChange(() => tui.requestRender());
		const ticker = setInterval(() => tui.requestRender(), CLOCK_TICK_MS);
		return {
			dispose() {
				unsub();
				clearInterval(ticker);
			},
			invalidate() {},
			render(width: number): string[] {
				const branch = footerData.getGitBranch();
				const thinking = pi.getThinkingLevel();
				const contextUsage = ctx.getContextUsage();
				const contextWindow = Number(contextUsage?.contextWindow ?? activeContextWindow ?? 0);
				const contextLabel = (() => {
					const percent = contextUsage?.percent;
					const windowLabel = Number.isFinite(contextWindow) && contextWindow > 0 ? formatCount(Math.round(contextWindow)) : "?";
					if (percent !== null && percent !== undefined && Number.isFinite(percent)) {
						return `${percent.toFixed(1)}%/${windowLabel}`;
					}
					if (windowLabel !== "?") return `?/${windowLabel}`;
					return "?";
				})();
				const sessionLabel = formatDuration(getSessionDurationMs());

				const providerModel = formatProviderModel(activeProvider || ctx.model?.provider, activeModel || ctx.model?.id);
				const slash = providerModel.indexOf("/");
				const providerLabel = slash > 0 ? providerModel.slice(0, slash) : "";
				const modelLabel = slash > 0 ? providerModel.slice(slash + 1) : providerModel;
				const modelDisplay = providerLabel
					? `${theme.fg("dim", providerLabel)}${theme.fg("muted", "/")}${theme.fg("accent", modelLabel)}`
					: theme.fg("accent", modelLabel);
				const thinkingDisplay = renderThinkingLevel(theme, thinking);
				const pulseOn = Math.floor(Date.now() / CLOCK_TICK_MS) % 2 === 0;
				const statusDisplay = inFlight
					? pulseOn
						? theme.fg("accent", "thinking")
						: theme.fg("muted", "thinking")
					: theme.fg("dim", "idle");
				const footerRight = `${modelDisplay}${theme.fg("dim", " · ")}${thinkingDisplay}${branch ? `${theme.fg("dim", " (")}${theme.fg("muted", branch)}${theme.fg("dim", ")")}` : ""}${theme.fg("dim", " · ")}${statusDisplay}`;

				const live = liveUsage ?? { input: 0, output: 0, cost: 0, cacheRead: 0, cacheWrite: 0 };
				const totalInput = usage.input + live.input;
				const totalOutput = usage.output + live.output;
				const totalCost = usage.cost + live.cost;
				const totalCacheRead = usage.cacheRead + live.cacheRead;
				const totalCacheWrite = usage.cacheWrite + live.cacheWrite;

				const stats = `↑${formatCount(totalInput)} ↓${formatCount(totalOutput)} $${totalCost.toFixed(3)} · turns:${turns} · ctx:${contextLabel} · session:${sessionLabel}`;
				const footerLeft = theme.fg("dim", stats);

				return [joinLR(footerLeft, footerRight, width)];
			},
		};
	});
		chromeLayoutMounted = true;
	}

	if (!editorMounted) {
		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			const editor = new AtelierEditor(tui, theme, keybindings);
			editor.borderColor = (text: string) => {
				const isBashMode = editor.getText().trimStart().startsWith("!");
				if (isBashMode) {
					return ctx.ui.theme.getBashModeBorderColor()(text);
				}
				return ctx.ui.theme.getThinkingBorderColor(pi.getThinkingLevel())(text);
			};
			return editor;
		});
		editorMounted = true;
	}
};

const setChrome = (pi: ExtensionAPI, ctx: ExtensionContext, enabled: boolean) => {
	chromeEnabled = enabled;
	if (chromeEnabled) {
		recalcSessionStats(ctx);
		chromeLayoutMounted = false;
		editorMounted = false;
		applyChrome(pi, ctx);
	} else {
		clearChrome(ctx);
	}
};

export default function atelierChrome(pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		activeProvider = ctx.model?.provider || activeProvider;
		activeModel = ctx.model?.id || activeModel;
		activeContextWindow = ctx.model?.contextWindow || activeContextWindow;
		activeCwd = ctx.cwd;
		sessionStartedAt = Date.now();
		currentTurnStartedAt = null;
		lastTurnDurationMs = 0;
		inFlight = false;
		void ensureTokenizerLoaded();
		recalcSessionStats(ctx);
		startThemePolling(ctx);
		chromeLayoutMounted = false;
		editorMounted = false;
		if (chromeEnabled) {
			applyChrome(pi, ctx);
		}
	});

	pi.on("session_switch", async (_event, ctx) => {
		activeProvider = ctx.model?.provider || activeProvider;
		activeModel = ctx.model?.id || activeModel;
		activeContextWindow = ctx.model?.contextWindow || activeContextWindow;
		activeCwd = ctx.cwd;
		sessionStartedAt = Date.now();
		currentTurnStartedAt = null;
		lastTurnDurationMs = 0;
		inFlight = false;
		void ensureTokenizerLoaded();
		recalcSessionStats(ctx);
		chromeLayoutMounted = false;
		editorMounted = false;
		if (chromeEnabled) {
			applyChrome(pi, ctx);
		}
		if (autoThemeEnabled) void syncThemeToSystem(ctx);
	});

	pi.on("model_select", async (event, ctx) => {
		activeProvider = event.model.provider;
		activeModel = event.model.id;
		activeContextWindow = event.model.contextWindow || activeContextWindow;
		void ensureTokenizerLoaded();
		if (chromeEnabled) applyChrome(pi, ctx);
	});

	pi.on("agent_start", async (_event, ctx) => {
		inFlight = true;
		currentTurnStartedAt = Date.now();
		liveUsage = null;
		if (chromeEnabled) applyChrome(pi, ctx);
	});

	pi.on("message_update", async (event, ctx) => {
		if (event.message.role !== "assistant") return;
		const msg = event.message as AssistantMessage;
		liveUsage = {
			input: msg.usage.input,
			output: msg.usage.output,
			cost: msg.usage.cost.total,
			cacheRead: msg.usage.cacheRead,
			cacheWrite: msg.usage.cacheWrite,
		};
		if (chromeEnabled) applyChrome(pi, ctx);
	});

	pi.on("turn_end", async (_event, ctx) => {
		liveUsage = null;
		recalcSessionStats(ctx);
		if (chromeEnabled) applyChrome(pi, ctx);
	});

	pi.on("agent_end", async (_event, ctx) => {
		if (currentTurnStartedAt) {
			lastTurnDurationMs = Date.now() - currentTurnStartedAt;
			currentTurnStartedAt = null;
		}
		inFlight = false;
		liveUsage = null;
		recalcSessionStats(ctx);
		if (chromeEnabled) applyChrome(pi, ctx);
	});

	pi.on("session_shutdown", () => {
		stopThemePolling();
	});

	pi.registerCommand("atelier", {
		description: "Manage atelier UI and theme automation",
		handler: async (args, ctx) => {
			const cmd = (args || "").trim().toLowerCase();

			if (!cmd || cmd === "status") {
				const autoLabel = autoThemeEnabled && process.platform === "darwin" ? "on" : "off";
				const resourcesShown = ctx.ui.getToolsExpanded();
				ctx.ui.notify(
					`atelier: ${chromeEnabled ? "on" : "off"}, resources: ${resourcesShown ? "shown" : "hidden"}, auto-theme: ${autoLabel}`,
					"info",
				);
				return;
			}

			if (cmd === "on") {
				setChrome(pi, ctx, true);
				ctx.ui.notify("Atelier chrome enabled", "info");
				return;
			}

			if (cmd === "off") {
				setChrome(pi, ctx, false);
				ctx.ui.notify("Atelier chrome disabled", "info");
				return;
			}

			if (cmd === "night" || cmd === "dark") {
				autoThemeEnabled = false;
				stopThemePolling();
				if (setThemeByName(ctx, THEME_DARK)) ctx.ui.notify(`Theme set to ${THEME_DARK} (auto-theme paused)`, "info");
				return;
			}

			if (cmd === "day" || cmd === "light") {
				autoThemeEnabled = false;
				stopThemePolling();
				if (setThemeByName(ctx, THEME_LIGHT)) ctx.ui.notify(`Theme set to ${THEME_LIGHT} (auto-theme paused)`, "info");
				return;
			}

			if (cmd === "auto on" || cmd === "auto-on") {
				if (process.platform !== "darwin") {
					ctx.ui.notify("Auto theme currently supports macOS only", "warning");
					return;
				}
				autoThemeEnabled = true;
				lastSystemDark = undefined;
				startThemePolling(ctx);
				ctx.ui.notify("Auto theme enabled (macOS appearance sync)", "info");
				return;
			}

			if (cmd === "auto off" || cmd === "auto-off") {
				autoThemeEnabled = false;
				stopThemePolling();
				ctx.ui.notify("Auto theme disabled", "info");
				return;
			}

			ctx.ui.notify("Usage: /atelier [status|on|off|day|night|auto on|auto off]", "warning");
		},
	});
}
