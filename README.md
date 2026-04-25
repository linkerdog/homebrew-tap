# linkerdog/homebrew-tap

Homebrew tap for AgentHub release binaries.

## Install

```bash
brew tap linkerdog/homebrew-tap
brew install linkerdog/homebrew-tap/agenthub
```

This formula installs:

- `agenthub`
- `agenthub-codex-acp`

## Run as a service

```bash
brew services start linkerdog/homebrew-tap/agenthub
```

AgentHub reads runtime config from `~/.agenthub/config.toml`.

Minimal example:

```toml
[server]
listen = "0.0.0.0:8080"
```

Then open `http://localhost:8080`.
