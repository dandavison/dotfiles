# pi

`models.json` → `~/.pi/agent/models.json`. Adds provider `mlx`, pointing at a local
OpenAI-compatible server; no other provider is configured, so a model must be named.

```bash
mlx-serve                                                    # first, in its own pane
pi --model mlx/mlx-community/Qwen3.6-35B-A3B-4bit            # or /model, interactively
pi --model mlx/mlx-community/Qwen3.6-35B-A3B-4bit -p "..."   # one-shot
senderos agent                                               # the same, knowing senderos
```

Skills and `AGENTS.md` come from `~/.agents`, which pi discovers by itself.

`compat.supportsDeveloperRole` and `supportsReasoningEffort` are off: `mlx_lm.server`
understands neither.
