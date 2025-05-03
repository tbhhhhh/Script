if getgenv().ESPLibrary then
    return getgenv().ESPLibrary
end

local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LP = Players.LocalPlayer
local character = LP.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local function GetDistance(position)
	if rootPart then
	    return (rootPart.Position - position).Magnitude
	elseif Camera then
	    return (Camera.CFrame.Position - position).Magnitude
	end
	return 9e9
end

local Library = {
    ESP = {},
    Connections = {},
    ESPFolder = Instance.new("Folder", CoreGui),
    ShowDistance = true,
    MaxDistance = math.huge
}

Library.ESPFolder.Name = "ESPFolder"
Library.Add = function(...)
    local espSettings
    if typeof(...) == "table" then
        espSettings = ...
    else
        local object, name, color, size, tag = ...
        espSettings = {Object = object,Name = name,Color = color,TextSize = size,Tag = tag}
    end
    if espSettings.ShowDistance == nil then espSettings.ShowDistance = Library.ShowDistance end
    if not espSettings.MaxDistance then espSettings.MaxDistance = Library.MaxDistance end
    
    local ESP = {
        Index = #Library.ESP+1,
        Settings = espSettings,
        Instances = {}
    }
    
    local BillboardGui = Instance.new("BillboardGui", Library.ESPFolder)
    BillboardGui.Name = ESP.Settings.Tag
    BillboardGui.Enabled = true
    BillboardGui.ResetOnSpawn = false
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.Adornee = ESP.Settings.Object
    BillboardGui.StudsOffset = Vector3.new(0, 0, 0)
    
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    TextLabel.Size = UDim2.new(0, 200, 0, 50)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextWrapped = true
    TextLabel.RichText = true
    TextLabel.TextStrokeTransparency = 0
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = ESP.Settings.Name
    TextLabel.TextColor3 = ESP.Settings.Color
    TextLabel.TextSize = ESP.Settings.TextSize
    
    local UIStroke = Instance.new("UIStroke", TextLabel)
    UIStroke.Thickness = 1
    
    local Highlight = Instance.new("Highlight", BillboardGui)
    Highlight.Adornee = ESP.Settings.Object
    Highlight.FillColor = ESP.Settings.Color
    Highlight.OutlineColor = ESP.Settings.Color
    Highlight.FillTransparency = 0.65
    Highlight.OutlineTransparency = 0
    
    ESP.Instances.BillboardGui = BillboardGui
    ESP.Instances.TextLabel = TextLabel
    ESP.Instances.UIStroke = UIStroke
    ESP.Instances.Highlight = Highlight
    
    function ESP:Destroy()
        if BillboardGui then BillboardGui:Destroy() end
        Library.ESP[ESP.Index] = nil
    end
    
    function ESP:ToggleVisibility(Value)
		BillboardGui.Enabled = Value
		Highlight.Adornee = Value and object or nil
	end
    
    Library.ESP[ESP.Index] = ESP
    return ESP
end

Library.Clear = function(tag)
    for _, ESP in pairs(Library.ESP) do
        if ESP.Settings.Tag == tag then
            ESP:Destroy()
        end
    end
end

Library.Destroy = function()
    Library.ESPFolder:Destroy()
    for _, v in pairs(Library.Connections) do
        v:Disconnect()
    end
    table.clear(Library)
    getgenv().ESPLibrary = nil
end

table.insert(Library.Connections, LP.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    rootPart = character:WaitForChild("HumanoidRootPart")
end))

table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
    for _, ESP in pairs(Library.ESP) do
        if not ESP.Settings.Object or not ESP.Settings.Object.Parent then
			ESP:Destroy()
			continue
		end
        
        local TargetPosition = ESP.Settings.Object:GetPivot().Position
        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(TargetPosition)
        
        ESP:ToggleVisibility(OnScreen)
        if not OnScreen then continue end
        
        local Distance = GetDistance(TargetPosition)
        if Distance > ESP.Settings.MaxDistance then
            ESP:ToggleVisibility(false)
            continue
        end
        
        if ESP.Settings.ShowDistance then
            ESP.Instances.TextLabel.Text = ("%s\n[%s]"):format(ESP.Settings.Name, math.floor(Distance))
        else
            ESP.Instances.TextLabel.Text = ESP.Settings.Name
        end
    end
end))

getgenv().ESPLibrary = Library
return Library
