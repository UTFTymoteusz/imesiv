#!/usr/bin/lua

getmetatable('').__index = function(str, i) return string.sub(str, i, i) end

local WIDTH, HEIGHT = 8, 12

local onsets = {
    "k", "g", "m", "n", "r", "l", "t", "d", "s", "b", "v", "h",
    "vr", "rl", "tr", "st", "nv", "fl"
}

local nuclei = {
    "a", "e", "i", "o"
}

local banned = {
    openclose = {
        {"o", "i"},
        {"b", "d"},
    },
    endings = {
        "o", "e",
        "k", "g",
        "b", "s",
        "m", "h"
    },
    specific = {
        ["o"] = {
            far  = {"o"},
        },
        ["m"] = {
            all  = {"m", "h"},
        },
        ["n"] = {
            near = {"h"},
        },
        ["h"] = {
            near = {"d", "g", "b"},
            all  = {"m"},
        },
        ["k"] = {
            near = {"h", "g", "b"},
        },
        ["g"] = {
            all  = {"g"},
            near = {"d", "k"},
        },
        ["t"] = {
            near = {"d"},
        },
        ["d"] = {
            near = {"t", "g"},
        },
        ["b"] = {
            near = {"d"},
        },
        ["r"] = {
            near = {"s"},
            far  = {"r", "l"},
        },
        ["l"] = {
            near = {"h"},
            far  = {"l", "r"},
        },
        ["vr"] = {
            all  = {"v"},
        }
    },
}

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

    if anycmp(word[#word - 1], val) or anycmp(word[#word - 0], val) then
        return false
    end

    if banned.specific[val] then
        local specific = banned.specific[val]

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
    return table.wordRandom(onsets, word), table.wordRandom(nuclei, word)
end

local function word()
    ::again::
    local word = {}

    if math.random() <= 0.50 then
        table.insert(word, table.wordRandom(nuclei))
    else
        local a, b = syllable(word, {})

        table.insert(word, a)
        table.insert(word, b)
    end

    local r = math.random()
    local count
    do 
        if r < 0.65 then
            count = 2
        elseif r < 0.85 then
            count = 3
        else
            count = 4
        end
    end

    for i = 2, count do
        local a, b = syllable(word)
        
        table.insert(word, a)
        table.insert(word, b)
    end

    if math.random() <= 0.33 then
        table.insert(word, table.wordRandom(onsets, word))
    end

    local len
    repeat
        len = #word

        if table.contains(banned.endings, word[#word]) then
            table.remove(word, #word)
        end

        if #(word[#word] or "!!") > 1 then
            table.remove(word, #word)
        end

        for _, pair in pairs(banned.openclose) do
            if word[1] == pair[1] or word[#word] == pair[2] then
                goto again
            end
        end
    until len == #word

    if #word < 4 then
        goto again
    end

    if table.contains(nuclei, word[#word]) and word[#word] ~= "i" then
        if math.random() <= 0.33 then
            table.insert(word, #word, "i")
        end
    end

    return table.concat(word, "")
end

local blacklist = {}
local list      = {}

math.randomseed(os.time())

for i = 1, WIDTH * HEIGHT do
    local gen
    repeat
        gen = word()
    until not blacklist[gen]

    blacklist[gen] = true
    table.insert(list, gen)
end

local index = 1

for y = 1, HEIGHT do
    local line = ""

    for x = 1, WIDTH do
        line  = line .. string.format("%-13s", list[index])
        index = index + 1
    end

    print(line)
end