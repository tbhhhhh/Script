local Bypass

local isAdonis = false

for _, v in pairs(getreg()) do
    if typeof(v) == "thread" then
        local source = debug.info(v, 1, "s")
        if not source then continue end
        if source:match("%.Core.Anti") or source:match("%.Plugins.Anti_Cheat") then
            isAdonis = true
        end
        if source:match("%.BAC_") then
            Bypass = "BAC"
            coroutine.close(v)
        end
    end
end

if not isAdonis then
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

task.wait(2)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(...)
    if tostring(getcallingscript()) == "CameraModule" then return OldNamecall(...) end --idk why this errors
    local success, result = pcall(OldNamecall, ...)
    if not checkcaller() and not success then
        Bypass = "AntiHook"
        print(debug.traceback("namecall"))
        return coroutine.yield()
    end
    return result
end)

repeat task.wait() until Bypass

return Bypass
