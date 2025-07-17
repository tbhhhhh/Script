local Games = {
    [2440500124] = "Doors",
    [5877971206] = "FPE-S",
    [3085257211] = "彩虹朋友",
    [4777817887] = "刀刃球",
    [2820580801] = "俄亥俄州",
    [770538576] = "海战",
    [93740418] = "极限捉迷藏",
    [73885730] = "监狱人生",
    [1430007363] = "奶奶",
    [66654135] = "破坏者谜团2",
    [4367208330] = "压力",
    [210851291] = "造船寻宝",
    [65241] = "自然灾害"
}

if not ({...})[1] then
    if Games[game.GameId] then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/"..Games[game.GameId]..".lua"))()
    else
        local cloneref = cloneref or function(a) return a end
        local gethui = gethui or function()
            return cloneref(game:GetService("CoreGui"))
        end
        local message = Instance.new("Message", gethui())
        message.Text = "此游戏不受支持"
        task.wait(2)
        message:destroy()
    end
end

return Games
