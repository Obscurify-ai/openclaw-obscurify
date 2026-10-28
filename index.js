// Obscurify.ai model provider for OpenClaw.
// Obscurify.ai (https://obscurify.ai) is a privacy-focused, OpenAI-compatible API, so the
// provider uses OpenClaw's openai-completions transport. The model list comes live from the
// public /v1/models catalog; decision models, which only answer structured questions, are left out.
import { defineSingleProviderPluginEntry } from "openclaw/plugin-sdk/provider-entry";
import { applyModelCompatPatch } from "openclaw/plugin-sdk/provider-model-shared";
import manifest from "./openclaw.plugin.json" with { type: "json" };

export default defineSingleProviderPluginEntry({
  id: "obscurify",
  name: "Obscurify.ai Provider",
  description: "Obscurify.ai model provider plugin",
  manifest,
  provider: {
    label: "Obscurify.ai",
    docsPath: "https://github.com/Obscurify-ai/openclaw-obscurify#readme",
    aliases: ["obscurify-ai"],
    manifestAuth: {
      noteTitle: "Obscurify.ai",
      noteMessage: [
        "Obscurify.ai: private AI with zero-data-retention routes and no-email accounts.",
        "Create an account at https://obscurify.ai/?utm_source=openclaw and add a balance,",
        "then click Show API Key on https://obscurify.ai/account.",
      ].join("\n"),
    },
    catalog: {
      discoveryMode: "strict",
      allowExplicitBaseUrl: true,
      liveModelDiscovery: {
        // The catalog is public; no key is sent when listing models.
        authentication: "none",
        acceptUnknownModel: ({ record }) => record?.decisions !== true,
      },
    },
    // Obscurify.ai reports token usage in streams when asked (stream_options.include_usage).
    normalizeResolvedModel: ({ model }) =>
      model.api === "openai-completions"
        ? applyModelCompatPatch(model, {
            supportsUsageInStreaming: model.compat?.supportsUsageInStreaming ?? true,
          })
        : model,
  },
});
