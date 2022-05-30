#!/usr/bin/lua

local WIDTH, HEIGHT = 8, 12

local onsets = {
    "k", "g", "m", "n", "r", "l", "t", "d", "s", "b", "v", "h",
    "vr", "rl", "tr", "st", "nv"
}

local nuclei = {
    "a", "e", "i", "o"
}

local vvv = {
    ["g"] = "k",
    ["k"] = "g",
    ["t"] = "d",
    ["d"] = "t",
}

local function checker(val, word)
    if #word == 0 then
        if #val > 1 then
            return false
        end
    end

    if (word[#word - 1] or 1) == val or (word[#word] or 2) == val then
        return false
    end

    if vvv[(word[#word - 1] or 1)] == val or vvv[(word[#word] or 2)] == val then
        return false
    end

    if val == "m" then
        if table.contains(word, val) then
            return false
        end

        if table.contains(word, "h") then
            return false
        end
    elseif val == "h" then
        if table.contains(word, "m") then
            return false
        end
    elseif val == "k" then
        if (word[#word - 1] or 1) == "h" or (word[#word] or 2) == "h" then
            return false
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

        if word[#word] == "o" or word[#word] == "e" then
            table.remove(word, #word)
        end

        if word[#word] == "k" or word[#word] == "g" then
            table.remove(word, #word)
        end

        if word[#word] == "b" then
            table.remove(word, #word)
        end

        if word[#word] == "s" then
            table.remove(word, #word)
        end

        if word[#word] == "h" then
            table.remove(word, #word)
        end

        if #(word[#word] or "!!") > 1 then
            table.remove(word, #word)
        end

        if word[1] == "o" or word[#word] == "i" then
            table.remove(word, 1)
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

math.randomseed(os.time())

for y = 1, HEIGHT do
    local line = ""

    for x = 1, WIDTH do
        local gen

        repeat
            gen = word()
        until not blacklist[gen]

        blacklist[gen] = true
        line = line .. string.format("%-13s", gen)
    end

    print(line)
end