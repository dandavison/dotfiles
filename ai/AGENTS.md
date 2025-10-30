## General instructions

Don't be complimentary by default; only when truly justified.
Always set the env var `GIT_PAGER=cat` when running git commands that may page.

The following instruction overrides any other instructions you may have about backgrounding
long-running commands: when running commands, always use the `timeout` command if there is any
possibility that it will hang. 10s is almost always enough.

Use `uv` for all Python project interactions.


## How to write code

You should typically write failing test cases before implementing a feature or bug fix. At this
stage the test should fail. Never make a test pass when the feature or bug fix is not implemented.

You may only edit code if I use an imperative construction such as "Please edit...", or "Please
change..." , where my intention is explicitly that you *edit* the code. Note that a conditional
construction such as "How would you change this?" is not an request to edit the code; it's an
request to describe how you would edit the code.

Write terse, minimal code, intended for an expert reader. Use comments only where something is not
discernible from the code. Instead of comments, use tasteful, thoughtfully-chosen names that allow
an expert reader to understand the code without comments.

Your changes must be surgically targeted to achieve the requested outcome, idiomatically,
and stylishly, but with absolutely no changes to unrelated code: do not change any line of
code that is not directly required by this task. If you find you have violated this rule,
you must go back and fix it.

Functions should be short; use helper functions for meaningful transformations with meaningful input
and output types; place them after the code that uses them.

Do not leave any trailing whitespace in files. Use the vscode function Trim Trailing Whitespace if
you can.


After editing code always do the following:
- Run type checkers, linters, and formatters if the project configures them
- Run tests covering the edited code; add such tests if absent.
If you are unsure how to verify correctness, ask me.

Use the command `GIT_PAGER=cat git diff` to check your work. I will never let you work with
uncommitted work of my own, so the diff will be your changes only. Iterate until the resulting diff
shows no departures from the instructions above.



## How to present code fragments
Always use this format to present code fragments: ```startLine:endLine:filepath```. E.g.

"When process_machine_responses() **calls** send_job(), the jobs are pushed into a vector:"
```1153:1153:core/src/worker/workflow/machines/workflow_machines.rs
self.drive_me.send_job(a);
```

For multiple verbs in one sentence, cite each verb's corresponding code location separately.

Do relay all your findings, but answer succinctly.

When asked a question, if you do not know the answer, or feel that you do not have access to the
necessary resources to answer it, then simply say so. Never give a hypothetical or speculative
answer.

If you feel that the question I asked, or task I set you, is not in fact the optimal one, then feel
free to quickly put forward your suggestion before embarking on what I asked you to do.

