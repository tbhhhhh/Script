--I decided to open source because lol

if _G.Loaded then
    warn("请勿重复加载")
    return
else
    _G.Loaded = true
    game.StarterGui:SetCore("SendNotification", {
        Title = "HttpSpy已开启",
        Text = "作者：外星人",
		Duration = 5
    })
end

local methods = {
    HttpGet = true,
    HttpGetAsync = true,
    HttpPost = true,
    HttpPostAsync = true,
    GetObjects = true
}

local appendfileF = clonefunction(appendfile)
local logname = string.format("%s.%s_log.txt", os.date("%m"), os.date("%d"))

if not isfile(logname) then writefile(logname, "") end

local function printf(...)
    appendfileF(logname, ...)
end

printf(os.date("%H:%M\n\n"))

local nilfunc = function() end

local HttpFunction = {
    HttpGet = game.HttpGet or nilfunc,
    HttpGetAsync = game.HttpGetAsync or nilfunc,
    HttpPost = game.HttpPost or nilfunc,
    HttpPostAsync = game.HttpPostAsync or nilfunc,
    GetObjects = game.GetObjects or nilfunc
}

local HttpMethod = newcclosure(function(self, method, url, ...)
    printf(string.format("%s: %s\n\n", method, url))
    return HttpFunction[method](self, url, ...)
end)

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
        return function(self, ...)
            return HttpMethod(self, key, ...)
        end
    end
    return oldindex(self, key)
end))
