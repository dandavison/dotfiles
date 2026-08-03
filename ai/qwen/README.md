# qwen-code

`settings.json` → `~/.qwen/settings.json`. Points qwen at the same local
OpenAI-compatible server as pi, as its default model, so it needs no flags.

```bash
mlx-serve                                    # first, in its own pane
qwen                                         # interactive
qwen -p "..."                                # one-shot, answers and exits
qwen -i "..."                                # first message, then interactive
senderos agent --with qwen                   # the same, knowing senderos
```

Skills and `AGENTS.md` come from `~/.agents`, which qwen discovers by itself.

Auth is `security.auth.selectedType: openai` with the key and base URL alongside it;
no `~/.qwen/.env` is needed. The key is a placeholder the server ignores.
