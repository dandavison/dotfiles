-- Standalone unit test for the pure replaceAction logic in ../rebase.lua.
-- Run: lua tests/replaceAction_test.lua   (from the plugin directory)
-- Stubs micro's `import` so rebase.lua loads outside the editor.

local here = arg[0]:match("(.*/)") or "./"

import = function(_)
    return setmetatable({}, { __index = function() return function() end end })
end
dofile(here .. "../rebase.lua")

local failures = 0
local function eq(got, want, name)
    if got ~= want then
        failures = failures + 1
        print(string.format("FAIL %s\n  got:  %q\n  want: %q", name, got, want))
    else
        print("ok   " .. name)
    end
end

eq(replaceAction("pick abc1234 Fix bug", "squash"), "squash abc1234 Fix bug", "pick to squash")
eq(replaceAction("pick abc1234 Fix bug", "fixup"), "fixup abc1234 Fix bug", "pick to fixup")
eq(replaceAction("pick abc1234 Fix bug", "reword"), "reword abc1234 Fix bug", "pick to reword")
eq(replaceAction("pick abc1234 Fix bug", "edit"), "edit abc1234 Fix bug", "pick to edit")
eq(replaceAction("pick abc1234 Fix bug", "drop"), "drop abc1234 Fix bug", "pick to drop")
eq(replaceAction("squash abc1234 Fix bug", "pick"), "pick abc1234 Fix bug", "squash back to pick")
eq(replaceAction("p abc1234 Fix bug", "squash"), "squash abc1234 Fix bug", "abbreviated to full")
eq(replaceAction("pick abc1234 Fix bug", "pick"), "pick abc1234 Fix bug", "idempotent pick")
eq(replaceAction("# This is a comment", "squash"), "# This is a comment", "comment unchanged")
eq(replaceAction("", "squash"), "", "empty unchanged")
eq(replaceAction("exec make test", "squash"), "exec make test", "exec unchanged")
eq(replaceAction("break", "squash"), "break", "break unchanged")
eq(replaceAction("fixup def5678 Add feature", "edit"), "edit def5678 Add feature", "fixup to edit")
eq(replaceAction("pick abc1234 Fix the bug in the parser", "reword"),
    "reword abc1234 Fix the bug in the parser", "message with spaces preserved")

if failures > 0 then
    print(string.format("\n%d test(s) failed", failures))
    os.exit(1)
end
print("\nall tests passed")
