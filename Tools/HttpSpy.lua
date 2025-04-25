if getgenv().Loaded then
    warn("HttpSpy is already running!")
    return
else
    getgenv().Loaded = true
    print("HttpSpy Enabled")
end

local config = {
    methods = {
        HttpGet = true,
        HttpGetAsync = true,
        HttpPost = true,
        HttpPostAsync = true,
        GetObjects = true,
        Request = true
    },
    BlockWebhook = true
}
local methods = config.methods

local serialize = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Tools/Serialize.lua"))()
local clonef = clonefunction or function(a) return a end
local date = clonef(os.date)
local isfile = clonef(isfile)
local writefile = clonef(writefile)
local appendfile = clonef(appendfile)
local newcclosure = clonef(newcclosure)
local checkcaller = clonef(checkcaller)
local format = clonef(string.format)
local match = clonef(string.match)
local getnamecallmethod = clonef(getnamecallmethod)

local logname = format("%s.%s_log.txt", date("%m"), date("%d"))
if not isfile(logname) then writefile(logname, "") end

local function printf(...)
    appendfile(logname, ...)
end

printf(date("%H:%M\n\n"))

local nilfunc = function() end

local HttpFunction = {
    HttpGet = game.HttpGet or nilfunc,
    HttpGetAsync = game.HttpGetAsync or nilfunc,
    HttpPost = game.HttpPost or nilfunc,
    HttpPostAsync = game.HttpPostAsync or nilfunc,
    GetObjects = game.GetObjects or nilfunc
}

local HttpMethod = function(self, method, ...)
    local url = ({...})[1]
    printf(format("game:%s(%s)\n\n", method, serialize(...)))
    if config.BlockWebhook and match(url, "webhook") then
        printf("Successfully blocked webhook url: "..url.."\n\n")
        return
    end
    return HttpFunction[method](self, ...)
end

local oldnamecall
oldnamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	if checkcaller() and methods[method] then
        return HttpMethod(self, method, ...)
	end
	return oldnamecall(self, ...)
end))

local oldindex
oldindex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if checkcaller() and self == game and methods[key] then
        return newcclosure(function(self, ...)
            return HttpMethod(self, key, ...)
        end)
    end
    return oldindex(self, key)
end))

local oldrequest
oldrequest = hookfunction(request, newcclosure(function(data)
    if methods.Request then
        printf("request("..serialize(data)..")\n\n")
    end
    if config.BlockWebhook and match(data.Url, "webhook") then
        printf("Successfully blocked webhook url: "..data.Url.."\n\n")
        return
    end
    return oldrequest(data)
end))
