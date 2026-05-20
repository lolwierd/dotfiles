/**
 * excloud-params
 *
 * Apply custom sampling parameters (temperature, top_p, etc.) only for
 * Excloud-hosted models (model id ends with ":excloud").
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const EXCLOUD_PARAMS = {
  temperature: 0.6,
  top_p: 0.95,
  top_k: 20,
  min_p: 0.0,
  presence_penalty: 0.0,
  repetition_penalty: 1.0,
} as const;

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event, ctx) => {
    // Only apply for models whose id ends with ":excloud"
    if (!ctx.model?.id?.endsWith(":excloud")) {
      return;
    }
    return { ...event.payload, ...EXCLOUD_PARAMS };
  });
}
