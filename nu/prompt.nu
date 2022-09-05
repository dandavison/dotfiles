# This file contains an example nushell prompt, making use of the async-git-prompt module.
use async-git-prompt.nu *

def prompt-concat [parts: table] {
    $parts
    | where (not ($it.text | empty?))
    | each { |it| $"($it.color)($it.text)" }
    | str collect ' '
}

def prompt-git-branch [] {
    do -i { git rev-parse --abbrev-ref HEAD | str trim -r}
}

def prompt-create-left-prompt [] {
    let pwd = ($env.PWD | str replace $env.HOME '~')
    prompt-concat [
        {text: $pwd, color: (ansi green_bold)}
        {text: (prompt-git-branch), color: (ansi blue_bold)}
        {text: (async-git-prompt-string), color: (ansi green_bold)}
    ]
}

def prompt-create-right-prompt [] {
    $nothing
}

let-env PROMPT_COMMAND = { prompt-create-left-prompt }
let-env PROMPT_COMMAND_RIGHT = { prompt-create-right-prompt }
let-env PROMPT_INDICATOR = { $" (ansi green_bold)〉" }
