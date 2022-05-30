return {
    onsets = {
        "k", "g", "m", "n", "r", "l", "t", "d", "s", "b", "v", "h", "p",
        "vr", "rl", "rv", "tr", "st", "nv", "nt",
    },
    nuclei = {
        "a", "e", "i", "o",
    },
    banned = {
        openclose = {
            {"o", "i"},
            {"b", "d"},
        },
        endings = {
            "o", "e",
            "k", "g",
            "b", "s",
            "m", "h",
            "p",
        },
        specific = {
            ["a"] = {
                near = {"h"},
                far  = {"a"},
            },
            ["e"] = {
                far  = {"e"},
            },
            ["i"] = {
                far  = {"i"},
            },
            ["o"] = {
                near = {"o"},
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
            ["p"] = {
                near = {"p"},
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
            ["v"] = {
                near = {"o"},
            },
            ["vr"] = {
                all  = {"v"},
            }
        },
    },
}