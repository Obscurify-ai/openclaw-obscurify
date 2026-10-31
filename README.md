# Obscurify.ai provider for OpenClaw

An [OpenClaw](https://github.com/openclaw/openclaw) plugin that adds [Obscurify.ai](https://obscurify.ai/?utm_source=openclaw) as a model provider. After you install it, **Obscurify.ai** shows up in onboarding and in the model picker, and models are addressed as `obscurify/<lab>/<model>`, for example `obscurify/deepseek/deepseek-v4-flash`.

Obscurify.ai is a privacy-focused, OpenAI-compatible API to 200+ models (GPT, Claude, Gemini, DeepSeek, GLM, Kimi, Qwen, Llama and more). Text requests only use zero-data-retention routes, prompts and responses aren't stored on its servers, and accounts are a random account number with no email.

## Install

```sh
openclaw plugins install clawhub:@obscurify/openclaw-provider
```

That installs from [ClawHub](https://clawhub.ai). Without the `clawhub:` prefix, recent OpenClaw looks on npm and asks for `--force`, because npm sources are outside ClawHub's review. The same package is on npm: `openclaw plugins install npm:@obscurify/openclaw-provider --force`.

Needs OpenClaw 2026.10.8 or newer.

## Get an API key

1. Create an account at [obscurify.ai](https://obscurify.ai/?utm_source=openclaw). You get a random account number: no email, no password.
2. Add a balance. The API works on every plan with a positive balance. Frontier models need the Casual plan or higher, and uncensored models need Pro.
3. On [obscurify.ai/account](https://obscurify.ai/account), click **Show API Key** and copy the `sk-obs1_...` key.

## Configure

Choose **Obscurify.ai** in `openclaw onboard`, or pass the key directly:

```sh
openclaw onboard --auth-choice obscurify-api-key --obscurify-api-key sk-obs1_...
```

The plugin also reads `OBSCURIFY_API_KEY` from the environment.

```sh
openclaw models list --all --provider obscurify --refresh
openclaw models set obscurify/deepseek/deepseek-v4-flash
openclaw agent --local --model obscurify/z-ai/glm-5.3 --thinking low --message "Hello"
```

## What it does

- **Model list:** comes live from Obscurify.ai's public `GET https://obscurify.ai/v1/models` (no key sent). Decision models, which only answer structured questions, are left out. Five models ship as a static fallback with prices: DeepSeek V4 Flash (default), GLM 5.3, Kimi K2 0905, Qwen3 Coder 480B and Llama 3.3 70B.
- **Chat:** goes through OpenClaw's OpenAI-compatible transport to `https://obscurify.ai/v1`, with streaming, tool calls, reasoning (`--thinking`) and token usage in streams.
- **What it doesn't do:** no background processes, no telemetry, no file access. Requests cost money from your Obscurify.ai balance at each model's price ([obscurify.ai/model_cards](https://obscurify.ai/model_cards?utm_source=openclaw)).

## Tested

With OpenClaw 2026.10.8 on Linux (2026-10-28), using a Pay As You Go key, via `scripts/e2e.sh`:

- installed the packed plugin
- listed 303 models
- `openclaw agent --local` answered on Llama 3.3 70B
- on DeepSeek V4 Flash with `--thinking low`, the agent wrote a file through its tools

## License

MIT
