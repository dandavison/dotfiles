local micro = import("micro")
local utf8 = import("unicode/utf8")

-- Emacs-style kill-line: cut from cursor to end of line; when already at end
-- of line, delete the newline to join the next line. So on a non-empty line,
-- one Ctrl-k clears to EOL and a second removes the now-empty line.
function killLine(bp)
    local c = bp.Cursor
    local line = bp.Buf:Line(c.Y)
    if c.X < utf8.RuneCountInString(line) then
        bp:SelectToEndOfLine()
        bp:Cut()
    else
        bp:Delete()
    end
    return true
end
