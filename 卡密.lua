--https://raw.githubusercontent.com/cikeV/EUJAN/main/MOJSN.lua
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 20)
FrameCorner.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextScaled = true
Close.TextColor3 = Color3.fromRGB(150, 150, 150)
Close.Parent = Frame
Close.MouseButton1Click:Connect(function()
   ScreenGui:Destroy()
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0.05, 0)
Title.Text = "◈刺客卡密校验系统◈"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = Frame

local Instructions = Instance.new("TextLabel")
Instructions.Size = UDim2.new(1, 0, 0, 30)
Instructions.Position = UDim2.new(0, 0, 0.2, 0)
Instructions.Text = "刺客Q群555251172\n卡密在群公告获取"
Instructions.TextSize = 13
Instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
Instructions.BackgroundTransparency = 1
Instructions.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.8, 0, 0.2, -10)
TextBox.Position = UDim2.new(0.1, 0, 0.4, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextBox.PlaceholderText = "请输入你的卡密"
TextBox.Text = ""
TextBox.TextSize = 18
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Parent = Frame

local TextBoxCorner = Instance.new("UICorner")
TextBoxCorner.CornerRadius = UDim.new(0, 10)
TextBoxCorner.Parent = TextBox

local GetKey = Instance.new("TextButton")
GetKey.Size = UDim2.new(0.6, 0, 0.15, 0)
GetKey.Position = UDim2.new(0.2, 0, 0.7, 0)
GetKey.BackgroundColor3 = Color3.fromRGB(54, 181, 0)
GetKey.Text = "检查卡密"
GetKey.TextSize = 18
GetKey.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKey.Parent = Frame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 10)
GetKeyCorner.Parent = GetKey

GetKey.MouseButton1Click:Connect(function()
    if TextBox.Text=="2B93-A80D-3E5E-C50D" then
    ScreenGui:Destroy()
    game.StarterGui:SetCore("SendNotification",{Title="卡密系统",Text="卡密校验成功",Icon="rbxassetid://15512382151"})
    game.StarterGui:SetCore("SendNotification",{Title="卡密系统",Text="正在初始",Icon="rbxassetid://15512382151"})
        game.StarterGui:SetCore("SendNotification",{Title="卡密系统",Text="正在为您打开刺客免费版…",Icon="rbxassetid://15512382151"})

msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-欢迎使用刺客免费版-"
wait(2)
msg:remove()
wait(2)

msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-支持游戏 DOORS 极速传奇 忍者传奇 监狱人生 战争大亨 造船寻宝 伐木大亨 兵工厂 通用功能-"
wait(5)
msg:remove()
wait(5)

------
if game.PlaceId == 6839171747 then --doors
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开DOORS-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/WDQi/00SFPro00/main/MS.txt"))()
------
elseif game.PlaceId == 286090429 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开兵工厂-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E5%85%B5%E5%B7%A5.lua"))()
------
elseif game.PlaceId == 3101667897 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开极速传奇-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E6%9E%81%E9%80%9F.lua"))()
------
elseif game.PlaceId == 3956818381 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开忍者传奇-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E5%BF%8D%E8%80%85.lua"))()
-----
elseif game.PlaceId == 155615604 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开监狱人生-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E7%9B%91%E7%8B%B1.lua"))()
-----
elseif game.PlaceId == 4639625707 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开战争大亨-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E6%88%98%E4%BA%89.lua"))()
-----
elseif game.PlaceId == 537413528 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开造船寻宝-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E9%80%A0%E8%88%B9.lua"))()
-----
elseif game.PlaceId == 2474168535 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开一路向西-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E4%B8%80%E8%B7%AF.lua"))()
-----
elseif game.PlaceId == 13822889 then
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开伐木大亨-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E4%BC%90%E6%9C%A8.lua"))()
-----
else---通用
msg = Instance.new("Message")
msg.Parent = game.Workspace
msg.Text = "-正在打开通用功能-"
wait(2)
msg:remove()
wait(2)
loadstring(game:HttpGet("https://raw.github.com/cikeV/-/main/%E9%80%9A%E7%94%A8.lua"))()
end
    else
    game.StarterGui:SetCore("SendNotification",{Title="卡密系统",Text="卡密错误",Icon="rbxassetid://15512382151"})
        --错误
    end
end)