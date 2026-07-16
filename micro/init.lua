local micro = import("micro")
local clip  = import("micro/clipboard")
local shell = import("micro/shell")
local util  = import("micro/util")
local time  = import("time")

-- Files run as `uv` scripts start with `#!/usr/bin/env -S uv run --script`; this
-- is Python, but the file usually has no `.py` extension and the shebang ends in
-- neither `python` nor `python3`, so micro's built-in detector leaves it unknown.
function onBufferOpen(buf)
    if buf.Settings["filetype"] == "unknown" and buf:Line(0):match("^#!.*uv run") then
        buf:SetOptionNative("filetype", "python")
    end
    return true
end

-- cmd-o: jump to the current line of the current file in the active editor
-- (cursor, code, etc.) via wormhole. Cursor.Y is 0-indexed; editors are 1-indexed.
function openInWormhole(bp)
    local target = bp.Buf.AbsPath .. ":" .. (bp.Cursor.Y + 1)
    local out, err = shell.ExecCommand("wormhole", "open", target)
    if err ~= nil then
        micro.InfoBar():Error("wormhole open failed: " .. (out ~= "" and out or tostring(err)))
    end
    return true
end

-- Emacs-style kill-line (Ctrl-k): cut from the cursor to the end of the line,
-- or, when already at the end of the line, cut the newline joining the next
-- line. So on a non-empty line one Ctrl-k clears to EOL and a second removes the
-- now-empty line. Consecutive kills accumulate into a single clipboard entry, so
-- killing a line's contents and then its newline yanks back as the whole line.
local lastKill = nil -- exact text this plugin last wrote to the clipboard

function killLine(bp)
    local c = bp.Cursor
    local killed
    if c.X < util.CharacterCountInString(bp.Buf:Line(c.Y)) then
        bp:SelectToEndOfLine()
        killed = util.String(c:GetSelection())
        c:DeleteSelection()
        c:ResetSelection()
    elseif c.Y < bp.Buf:LinesNum() - 1 then
        killed = "\n"
        bp:Delete() -- deletes the newline, joining the next line
    else
        return true -- end of buffer: nothing to kill
    end

    -- Accumulate only if nothing else touched the clipboard since our last kill.
    local prev = clip.Read(clip.ClipboardReg)
    if prev ~= lastKill then
        prev = ""
    end
    lastKill = prev .. killed
    clip.Write(lastKill, clip.ClipboardReg)

    bp:Relocate()
    return true
end

-- A paste leaves the clipboard text unchanged, so the content heuristic can't
-- see it; reset accumulation explicitly (emacs ends a kill sequence on yank).
function onPaste(bp)
    lastKill = nil
    return true
end

-- Copy/cut confirmation messages ("Copied selection", etc.) never expire on
-- their own. This clears them: after MESSAGE_TTL seconds normally, or instantly
-- when SUPPRESS_COPY_MESSAGES is true.
local SUPPRESS_COPY_MESSAGES = false
local MESSAGE_TTL = 4 -- seconds

local function handleCopyMessage()
    if SUPPRESS_COPY_MESSAGES then
        micro.InfoBar():Message("")
        return
    end
    local msg = micro.InfoBar().Msg
    micro.After(MESSAGE_TTL * time.Second, function()
        -- only clear if a newer message hasn't replaced ours
        if micro.InfoBar().Msg == msg then
            micro.InfoBar():Message("")
        end
    end)
end

function onCopy(bp)     handleCopyMessage() return true end
function onCopyLine(bp) handleCopyMessage() return true end
function onCut(bp)      handleCopyMessage() return true end
function onCutLine(bp)  handleCopyMessage() return true end
