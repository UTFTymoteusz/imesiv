#!/usr/bin/lua

getmetatable('').__index = function(str, i) return string.sub(str, i, i) end

local options = {
    _NAME = "imesiv",
    ["w"] = {
        format = "number",
        key    = "width",
        desc   = "Specifies the width of the output grid.",
        alias  = {"width"},
    },
    ["h"] = {
        format = "number",
        key    = "height",
        desc   = "Specifies the height of the output grid.",
        alias  = {"height"},
    },
    ["l"] = {
        format = "switch",
        key    = "list",
        desc   = "Changes the output to a simple list instead of a grid.",
        alias  = {"list"},
    },
    ["c"] = {
        format = "number",
        key    = "count",
        desc   = "Specifies the count of words.",
        alias  = {"count"},
    },
    ["C"] = {
        format = "switch",
        key    = "capitalize",
        desc   = "Capitalizes the first letter of every word.",
        alias  = {"capitalize"},
    },
    ["nofilter"] = {
        format = "switch",
        key    = "nofilter",
        desc   = "Disables any word filters.",
    },
    ["s"] = {
        format = "number",
        key    = "minsyllables",
        desc   = "Specifies the minimum amount of syllables in every word.",
    },
    ["S"] = {
        format = "number",
        key    = "maxsyllables",
        desc   = "Specifies the maximum amount of syllables in every word.",
    },
}

local config = {
    width  = 8,
    height = 12,
}

local opt      = require("opt")
local arg      = opt.parse(config, options)
local language = require("defs/" .. (arg[1] or "genesiv"))

local function anycmp(a, b)
    if not a then
        return false
    end

    for i = 1, #a do
        if a[i] == b then
            return true
        end
    end

    for i = 1, #b do
        if b[i] == a then
            return true
        end
    end

    return false
end

local function checker(val, word)
    if #word == 0 then
        if #val > 1 then
            return false
        end
    end

    if not table.contains(language.nuclei, val) and (anycmp(word[#word - 1], val) or anycmp(word[#word - 0], val)) then
        return false
    end

    if language.banned.specific[val] then
        local specific = language.banned.specific[val]

        if specific.all then
            for _, v in pairs(specific.all) do
                if table.contains(word, v) then
                    return false
                end
            end
        end

        if specific.near then
            for _, v in pairs(specific.near) do
                if (word[#word - 1] or 1) == v or (word[#word] or 2) == v then
                    return false
                end
            end
        end

        if specific.far then
            for _, v in pairs(specific.far) do
                if (word[#word - 3] or 1) == v or (word[#word - 2] or 2) == v then
                    return false
                end
            end
        end
    end

    if #val > 1 then
        if table.contains(word, val) then
            return false
        end

        if #(word[#word - 1] or "!") > 1 or #(word[#word] or "!") > 1 then
            return false
        end
    end

    return true
end

function table.contains(tbl, val)
    for k, v in pairs(tbl) do
        if v == val then
            return true
        end
    end

    return false
end

function table.wordRandom(tbl, word)
    if not word then
        return tbl[math.random(1, #tbl)]
    end

    local r
    repeat
        r = table.wordRandom(tbl)
    until checker(r, word)

    return r
end

local function syllable(word)
    return table.wordRandom(language.onsets, word), table.wordRandom(language.nuclei, word)
end

local function word()
    ::again::
    local word = {}

    if math.random() <= 0.50 then
        table.insert(word, table.wordRandom(language.nuclei))
    else
        local a, b = syllable(word, {})

        table.insert(word, a)
        table.insert(word, b)
    end

    local minsyb, maxsyb = config.minsyllables or 2, config.maxsyllables or 4
    local r     = math.random()
    local count = minsyb + math.floor(math.pow(r, 3) * (maxsyb - minsyb) + 0.50)

    for i = 2, count do
        local a, b = syllable(word)
        
        table.insert(word, a)
        table.insert(word, b)
    end

    local len
    repeat
        len = #word

        if table.contains(language.banned.endings, word[#word]) then
            table.remove(word, #word)
        end

        if #(word[#word] or "!!") > 1 then
            table.remove(word, #word)
        end

        for _, pair in pairs(language.banned.openclose) do
            if word[1] == pair[1] or word[#word] == pair[2] then
                goto again
            end
        end
    until len == #word

    if #word < 4 then
        goto again
    end

    if table.contains(language.nuclei, word[#word]) and word[#word] ~= "i" then
        if math.random() <= 0.33 then
            table.insert(word, #word, "i")
        end
    end

    return table.concat(word, "")
end

local blacklist = {}
local list      = {}

math.randomseed(os.time())

if not config.count then
    config.count = config.width * config.height
end

for i = 1, config.count do
    local gen
    repeat
        gen = word()
    until config.nofilter or not blacklist[gen]

    blacklist[gen] = true
    table.insert(list, gen)
end

if config.capitalize then
    for k, v in pairs(list) do
        list[k] = string.upper(string.sub(v, 1, 1)) .. string.sub(v, 2)
    end
end

if config.list then
    for k, v in pairs(list) do
        io.write(v)
        io.write(" ")
    end
else
    local index = 1

    while true do
        local line = ""

        for x = 1, config.width do
            if not list[index] then
                break
            end

            line  = line .. string.format("%-13s", list[index])
            index = index + 1
        end

        if #line > 0 then
            print(line)
        else
            break
        end
    end
end