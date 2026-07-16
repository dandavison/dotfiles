-- Standalone unit test for the pure reflow logic in ../fillparagraph.lua.
-- Run: lua tests/reflow_test.lua   (from the plugin directory)
-- Stubs micro's `import` so fillparagraph.lua loads outside the editor.

local here = arg[0]:match("(.*/)") or "./"

import = function(_)
    return setmetatable({}, { __index = function() return function() end end })
end
dofile(here .. "../fillparagraph.lua")

local failures = 0
local function eq(got, want, name)
    if got ~= want then
        failures = failures + 1
        print(string.format("FAIL %s\n  got:  %q\n  want: %q", name, got, want))
    else
        print("ok   " .. name)
    end
end

local function eqLines(got, want, name)
    eq(table.concat(got, "\n"), table.concat(want, "\n"), name)
end

eqLines(reflowLines({ "one two three four five" }, 20),
    { "one two three four", "five" }, "basic wrap")

eqLines(reflowLines({ "  one two three four five" }, 20),
    { "  one two three four", "  five" }, "plain indent kept on continuation")

eqLines(reflowLines({ "- alpha beta gamma delta" }, 15),
    { "- alpha beta", "  gamma delta" }, "bullet hanging indent")

eqLines(reflowLines({ "1. alpha beta gamma" }, 12),
    { "1. alpha", "   beta", "   gamma" }, "numbered hanging indent")

eqLines(reflowLines({ "- aa bb cc", "- dd ee ff" }, 8),
    { "- aa bb", "  cc", "- dd ee", "  ff" }, "tight list, two paragraphs")

eqLines(reflowLines({ "one two", "", "three four" }, 100),
    { "one two", "", "three four" }, "blank line preserved")

eqLines(reflowLines({ "supercalifragilistic and" }, 10),
    { "supercalifragilistic", "and" }, "over-long word never broken")

local lines = { "a", "b", "", "- c", "c cont", "- d" }
local function eqBounds(idx, wantPs, wantPe, name)
    local ps, pe = paragraphBounds(lines, idx)
    eq(ps, wantPs, name .. " ps")
    eq(pe, wantPe, name .. " pe")
end
eqBounds(2, 1, 2, "paragraphBounds idx=2")
eqBounds(5, 4, 5, "paragraphBounds idx=5")
eqBounds(6, 6, 6, "paragraphBounds idx=6")

if failures > 0 then
    print(string.format("\n%d test(s) failed", failures))
    os.exit(1)
end
print("\nall tests passed")
