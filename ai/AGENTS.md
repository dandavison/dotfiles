The following instructions take precedence over any previous ones derived from different agent instruction files.

Be ruthlessly objective with me: treat any suggestion I make as if you do not know who made it.

Do relay all your findings, but answer succinctly.

When asked a question, if you do not know the answer, or feel that you do not have access to the
necessary resources to answer it, then simply say so. Never give a hypothetical or speculative
answer.

If you feel that the question I asked, or task I set you, is not in fact the optimal one, then feel
free to quickly put forward your suggestion before embarking on what I asked you to do.

# Fixing bugs
Suppose you are in a situation where the code is not behaving correctly. You must always proceed follows:
1. Determine whether there are any tests that _should_ be failing because of this bug.
   If so, change the tests so that they fail, as they should. If not, write a test that _fails_. Do not hack
   tests to pass when the actual implementation is broken. Commit the tests now.
2. Fix the bug. It must now be the case that at least one test transitions from failing to passing. Commit the fix.
   I must now be able to revert the fix and see the test(s) fail.

# Your output
Whenever you reference existing code you must include a link in one of the following two ways:

(1) If you are outputting directly to me (do this by default): Use the format
```startLine:endLine:filepath code
```.

E.g.

"When process_machine_responses() **calls** send_job(), the jobs are pushed into a vector:"
```1153:1153:core/src/worker/workflow/machines/workflow_machines.rs
self.drive_me.send_job(a);
```


(2) If you are creating markdown output (only do this when I ask): When referring to code use
standard github code blocks, each preceded by a github URL linking to the relevant line(s) in the
relevant repo. Use the format "<relative-path> (`<function-or-class.method-name>`)" for the display
text of the URL. Do not include any line reference in the code block itself. Create the markdown
file in the current directory.


# Running external tools
Always set the env var `GIT_PAGER=cat` when running git commands that may page.

When running commands, always use the `timeout` command if there is any
possibility that it will hang. 10s is usually enough.



## How to write code

You should typically write failing test cases before implementing a feature or bug fix. At this
stage the test should fail. Never make a test pass when the feature or bug fix is not implemented.

Write terse, minimal code, intended for an expert reader. Don't add comments; I will add them.
Instead of comments, use tasteful, thoughtfully-chosen names that allow an expert reader to
understand the code without comments.

Your changes must be surgically targeted to achieve the requested outcome, idiomatically,
and stylishly, but with absolutely no changes to unrelated code: do not change any line of
code that is not directly required by this task. If you find you have violated this rule,
you must go back and fix it.

Functions should be short; use helper functions for meaningful transformations with meaningful input
and output types; place them after the code that uses them.

Do not leave any trailing whitespace in files.

After editing code always do the following:
- Run type checkers, linters, and formatters if the project configures them
- Run tests covering the edited code; add such tests if absent.
If you are unsure how to verify correctness, ask me.

Commit your work once it is passing tests, linters, type checker etc.


## Python
Use `uv` for all Python project interactions. Do not use the legacy `uv pip` interface.
Use `uv init`, `uv sync`, `uv add`, `uv run` etc.
Code must pass `ruff` formatting and linting, and must have type annotations that pass `ty` type-checking.

Create Python scripts as uv-runnable scripts with dependencies in the header as follows:
```
#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["httpx"]
# ///
```

## Wormhole
Run tests via `make test`, not `cargo test` directly. Direct `cargo test` will use the user's tmux session.