VERSION = "1.0.0"

local micro = import("micro")
local buffer = import("micro/buffer")

local REBASE_FT = "git-rebase-todo"

-- Single key -> the action word it sets on the current commit line.
local ACTION_KEYS = {
    p = "pick",
    r = "reword",
    e = "edit",
    s = "squash",
    f = "fixup",
    d = "drop",
}

-- Leading words (full or abbreviated) that mark an editable commit line.
local COMMIT_ACTIONS = {
    pick = true, p = true, reword = true, r = true, edit = true, e = true,
    squash = true, s = true, fixup = true, f = true, drop = true, d = true,
}

function replaceAction(line, newAction)
    local leading = line:match("^%s*")
    local trimmed = line:sub(#leading + 1)
    if trimmed == "" or trimmed:sub(1, 1) == "#" then
        return line
    end
    local firstWord = trimmed:match("^%S+")
    if not COMMIT_ACTIONS[firstWord] then
        return line
    end
    return leading .. newAction .. trimmed:sub(#firstWord + 1)
end

local function isCommitLine(line)
    local trimmed = line:match("^%s*(%S*)")
    return COMMIT_ACTIONS[trimmed] == true
end

local function isRebaseTodo(bp)
    return bp.Buf.Settings["filetype"] == REBASE_FT
end

local function moveDown(bp)
    if bp.Cursor.Y < bp.Buf:LinesNum() - 1 then
        bp.Cursor.Y = bp.Cursor.Y + 1
    end
    bp.Cursor.X = 0
    bp.Cursor:Relocate()
    bp.Cursor:StoreVisualX()
end

local function setAction(bp, action)
    local y = bp.Cursor.Y
    local line = bp.Buf:Line(y)
    local replaced = replaceAction(line, action)
    if replaced ~= line then
        bp.Buf:Replace(buffer.Loc(0, y), buffer.Loc(#line, y), replaced)
    end
    moveDown(bp)
end

local function killLine(bp)
    local y = bp.Cursor.Y
    if not isCommitLine(bp.Buf:Line(y)) then
        return
    end
    if y < bp.Buf:LinesNum() - 1 then
        bp.Buf:Remove(buffer.Loc(0, y), buffer.Loc(0, y + 1))
    else
        bp.Buf:Remove(buffer.Loc(0, y), buffer.Loc(#bp.Buf:Line(y), y))
    end
    bp.Cursor.X = 0
    bp.Cursor:Relocate()
    bp.Cursor:StoreVisualX()
end

function preRune(bp, r)
    if not isRebaseTodo(bp) then
        return true
    end
    if r == "k" then
        killLine(bp)
        return false
    end
    local action = ACTION_KEYS[r]
    if action then
        setAction(bp, action)
        return false
    end
    return true
end
