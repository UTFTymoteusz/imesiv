local lib = {}

function lib.find(arg, short, options)
    local opts = {}
    
    if short then
        for i = 1, #arg do
            if not options[arg[i]] then
                io.stderr:write(string.format("%s: invalid option -- '%s' (try '--help')\n", options._NAME, arg[i]))
                os.exit(1)
            end

            opts[arg[i]] = options[arg[i]]
        end
    else
        for i = 1, #arg do
            if arg == "help" then
                return nil
            end

            if not options[arg] then
                io.stderr:write(string.format("%s: invalid option -- '%s' (try '--help')\n", options._NAME, arg))
                os.exit(1)
            end

            opts[arg] = options[arg]
        end
    end

    return opts
end

function lib.parseOption(config, a, b, options, name, option)
    local consume = false

    if option.format and option.format ~= "switch" then
        consume = true
    end

    if not option.format or option.format == "switch" then
        config[option.key] = true
    elseif option.format == "number" then
        local num = tonumber(b)

        if not num then
            io.stderr:write(string.format("%s: option requires a number -- '%s'\n", options._NAME, name))
            os.exit(1)
        end

        config[option.key] = num
    end

    return consume
end

function lib.fixOptions(options)
    local foptions = {}

    for k, v in pairs(options) do
        if type(v) == "table" then
            foptions[k] = v

            if v.alias then
                for c, w in pairs(v.alias) do 
                    foptions[w] = v
                end

                table.sort(v.alias)
            end
        end
    end

    foptions._NAME = options._NAME

    return foptions
end

function lib.help(options)
    local nameLen = 0
    local keys    = {}

    for k, v in pairs(options) do
        if type(v) == "table" then
            local len = #k + 2 + 2 + (#k > 1 and 2 or 1)

            if v.alias then
                for c, w in pairs(v.alias) do    
                    len = len + #w + 2
                end
            end

            len     = len - 2
            nameLen = math.max(nameLen, len + 2)
        end
    end

    for k, v in pairs(options) do
        table.insert(keys, k)
    end

    table.sort(keys, function(a, b)
        local a = (#a > 1 and ("--" .. a) or ("-" .. a))
        local b = (#b > 1 and ("--" .. b) or ("-" .. b))

        return a < b
    end)

    for i = 1, #keys do
        local k, v = keys[i], options[keys[i]]

        if type(v) == "table" then
            local key = (#k > 1 and ("--" .. k) or ("-" .. k))

            if v.alias then
                for c, w in pairs(v.alias) do    
                    key = key .. ", "
                    key = key .. (#w > 1 and ("--" .. w) or ("-" .. w))
                end
            end

            print(string.format("%-" .. nameLen .. "s%s", key, v.desc))
        end
    end
end

function lib.parse(config, options)
    local foptions = lib.fixOptions(options)
    local index    = 0

    for i = 1, #arg + 2 do
        index = index + 1

        if not arg[index] then
            break
        end

        local opts = nil

        if string.sub(arg[index], 1, 2) == "--" then
            local x = string.sub(arg[index], 3)
            opts    = lib.find(x, false, foptions)
        elseif string.sub(arg[index], 1, 1) == "-" then
            local x = string.sub(arg[index], 2)
            opts    = lib.find(x, true, foptions)
        else
            break
        end

        if opts then
            local consume = false

            for k, v in pairs(opts) do
                if lib.parseOption(config, arg[index + 0], arg[index + 1], foptions, k, v) then
                    consume = true
                end
            end

            if consume then
                index = index + 1
            end
        else
            if arg[index] == "--help" then
                lib.help(options)
                os.exit(0)
            end
        end
    end

    local argv = {}

    for i = 1, #arg do
        argv[i] = arg[i + index - 1]
    end

    return argv
end

return lib