local Bypass

local isAdonis = true
local isBAC = false

for _, v in pairs(getreg()) do
    if typeof(v) == "thread" then
        local source = debug.info(v, 1, "s")
        if not source then continue end
        if source:find(".Core.Anti") or source:find(".Plugins.Anti_Cheat") then
            isAdonis = true
        end
        if source:find(".BAC_") then
            isBAC = true
        end
    end
end

if not isAdonis then --fuck adonis
    local gf
    gf = hookfunction(getrenv().getfenv, function(...)
        local level = ...
        if not checkcaller() and typeof(level) == "number" then
            Bypass = "getfenv"
            print(debug.traceback("getfenv"))
            return coroutine.yield()
        end
        return gf(...)
    end)
end

if isBAC then
    local cw
    cw = hookfunction(getrenv().coroutine.wrap, function(...)
        if tostring(getcallingscript()) == "BAC_" then
            Bypass = "BAC"
            return coroutine.yield()
        end
        return cw(...)
    end)
end
task.wait(2)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(...)
    if checkcaller() then return OldNamecall(...) end
    local success, result = pcall(OldNamecall, ...)
    if not success then
        Bypass = "AntiHook"
        print(debug.traceback("namecall"))
        hookmetamethod(game, "__namecall", OldNamecall)
        return coroutine.yield()
    end
    return result
end)

repeat task.wait() until Bypass

return Bypass
