VERSION = "1.0.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local util = import("micro/util")

-- Prose filetypes we reflow. Every recognized programming language has its own
-- filetype and is thus skipped. "unknown" covers extension-less notes. Easily edited.
local FILL_FILETYPES = { unknown=true, text=true, markdown=true, ["git-commit"]=true,
                         gitcommit=true, rst=true, asciidoc=true, org=true, tex=true, mail=true }

local function isBlank(line)
    return line:match("^%s*$") ~= nil
end

-- List marker: bullet (-,*,+) or numbered (1. 1)). Requires trailing space(s) so
-- *emphasis*, **bold**, and -5 don't get mistaken for markers.
function parseListItem(line)
    local lead, marker, gap, rest = line:match("^(%s*)([%-%*%+])(%s+)(.*)$")
    if not lead then
        lead, marker, gap, rest = line:match("^(%s*)(%d+[%.%)])(%s+)(.*)$")
    end
    if not lead then
        return nil
    end
    return lead, marker, gap, rest
end

local function defaultWidth(s)
    if utf8 and utf8.len then
        return utf8.len(s) or #s
    end
    return #s
end

-- Greedily wraps one paragraph's lines into `out`, hanging-indenting continuation
-- lines under a list marker if present.
local function wrapParagraph(out, para, width, strwidth)
    local firstPrefix, contPrefix, firstContent
    local lead, marker, gap, rest = parseListItem(para[1])
    if lead then
        firstPrefix = lead .. marker .. gap
        contPrefix = string.rep(" ", strwidth(firstPrefix))
        firstContent = rest
    else
        firstPrefix = para[1]:match("^%s*")
        contPrefix = firstPrefix
        firstContent = para[1]:sub(#firstPrefix + 1)
    end

    local words = {}
    for w in firstContent:gmatch("%S+") do
        words[#words + 1] = w
    end
    for i = 2, #para do
        for w in para[i]:gmatch("%S+") do
            words[#words + 1] = w
        end
    end

    if #words == 0 then
        out[#out + 1] = (firstPrefix:gsub("%s+$", ""))
        return
    end

    local prefix = firstPrefix
    local cur, curw = {}, 0
    for _, word in ipairs(words) do
        local ww = strwidth(word)
        if #cur == 0 then
            cur[1] = word
            curw = strwidth(prefix) + ww
        elseif curw + 1 + ww <= width then
            cur[#cur + 1] = word
            curw = curw + 1 + ww
        else
            out[#out + 1] = prefix .. table.concat(cur, " ")
            prefix = contPrefix
            cur = { word }
            curw = strwidth(prefix) + ww
        end
    end
    out[#out + 1] = prefix .. table.concat(cur, " ")
end

-- Reflows `lines` (1-indexed array), preserving blank lines and starting a new
-- paragraph at each list item so tight lists fill per-item.
function reflowLines(lines, width, strwidth)
    strwidth = strwidth or defaultWidth
    local out = {}
    local i = 1
    while i <= #lines do
        if isBlank(lines[i]) then
            out[#out + 1] = lines[i]
            i = i + 1
        else
            local para = { lines[i] }
            i = i + 1
            while i <= #lines and not isBlank(lines[i]) and not parseListItem(lines[i]) do
                para[#para + 1] = lines[i]
                i = i + 1
            end
            wrapParagraph(out, para, width, strwidth)
        end
    end
    return out
end

-- Finds the paragraph containing 1-indexed `idx`: the contiguous non-blank block
-- around it, split at list-item boundaries. Returns 1-indexed inclusive bounds.
function paragraphBounds(lines, idx)
    if isBlank(lines[idx]) then
        return nil
    end
    local bs, be = idx, idx
    while bs > 1 and not isBlank(lines[bs - 1]) do
        bs = bs - 1
    end
    while be < #lines and not isBlank(lines[be + 1]) do
        be = be + 1
    end
    local ps = bs
    for k = bs + 1, idx do
        if parseListItem(lines[k]) then
            ps = k
        end
    end
    local pe = be
    for k = idx + 1, be do
        if parseListItem(lines[k]) then
            pe = k - 1
            break
        end
    end
    return ps, pe
end

-- Known limitation: no awareness of markdown fenced/indented code blocks or
-- blockquotes; the filetype allowlist is the only code-avoidance.
function fillParagraph(bp)
    local ft = bp.Buf.Settings["filetype"]
    if not FILL_FILETYPES[ft] then
        micro.InfoBar():Message("fillparagraph: skipping filetype '" .. tostring(ft) .. "'")
        return true
    end
    local width = tonumber(bp.Buf.Settings["fillparagraph.width"]) or 100

    local lines = {}
    for y = 0, bp.Buf:LinesNum() - 1 do
        lines[y + 1] = bp.Buf:Line(y)
    end

    local startY, endY
    if bp.Cursor:HasSelection() then
        local a, b = bp.Cursor.CurSelection[1], bp.Cursor.CurSelection[2]
        local topY, botY, botX
        if a.Y <= b.Y then
            topY, botY, botX = a.Y, b.Y, b.X
        else
            topY, botY, botX = b.Y, a.Y, a.X
        end
        if botX == 0 and botY > topY then
            botY = botY - 1
        end
        startY, endY = topY, botY
    else
        local ps, pe = paragraphBounds(lines, bp.Cursor.Y + 1)
        if not ps then
            return true
        end
        startY, endY = ps - 1, pe - 1
    end

    local region = {}
    for y = startY + 1, endY + 1 do
        region[#region + 1] = lines[y]
    end
    local original = table.concat(region, "\n")
    local wrapped = table.concat(reflowLines(region, width, util.CharacterCountInString), "\n")

    if wrapped ~= original then
        bp.Buf:Replace(buffer.Loc(0, startY), buffer.Loc(util.CharacterCountInString(lines[endY + 1]), endY), wrapped)
    end

    bp.Cursor:ResetSelection()
    bp.Cursor.Y = math.min(startY, bp.Buf:LinesNum() - 1)
    bp.Cursor.X = 0
    bp.Cursor:Relocate()
    bp.Cursor:StoreVisualX()
    return true
end

function init()
    config.RegisterCommonOption("fillparagraph", "width", 100)
    config.MakeCommand("fillparagraph", fillParagraph, config.NoComplete)
end
