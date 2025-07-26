if getgenv().ESPLibrary then
    return getgenv().ESPLibrary
end

local cloneref = cloneref or function(a) return a end
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

local function FindPrimaryPart(instance)
    return (instance:IsA("Model") and instance.PrimaryPart or nil)
        or instance:FindFirstChildWhichIsA("BasePart")
        or instance:FindFirstChildWhichIsA("UnionOperation")
        or instance
end

local Library = {
    ESP = {},
    Tags = {},
    Connections = {},
    ESPFolder = Instance.new("Folder", CoreGui),
    DefaultSettings = {
        Name = "Unnamed",
        Color = Color3.new(1, 1, 1),
        TextSize = 15,
        Tag = "DefaultTag",
        ShowTextLabel = true,
        ShowHighlight = true,
        ShowDistance = true,
        MaxDistance = math.huge,
    }
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
    
    assert(espSettings.Object, "missing esp object")
    for i, v in pairs(Library.DefaultSettings) do
        if espSettings[i] == nil then
            espSettings[i] = v
        end
    end
    
    local ESP = {
        Index = #Library.ESP+1,
        Settings = espSettings,
        Instances = {}
    }
    ESP.Instances.Folder = Instance.new("Folder", Library.ESPFolder)
    ESP.Instances.Folder.Name = ESP.Settings.Tag
    
    if Library.Tags[ESP.Settings.Tag] == nil then
        Library.Tags[ESP.Settings.Tag] = true
    end
    
    local BillboardGui
    local TextLabel
    if ESP.Settings.ShowTextLabel then
        BillboardGui = Instance.new("BillboardGui", ESP.Instances.Folder)
        BillboardGui.Name = ESP.Settings.Tag
        BillboardGui.Enabled = false
        BillboardGui.ResetOnSpawn = false
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Size = UDim2.new(0, 200, 0, 50)
        BillboardGui.Adornee = ESP.Settings.Object
        BillboardGui.StudsOffset = Vector3.new(0, 0, 0)
        
        TextLabel = Instance.new("TextLabel", BillboardGui)
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.TextWrapped = true
        TextLabel.RichText = true
        TextLabel.TextStrokeTransparency = 0.5
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = ESP.Settings.Name
        TextLabel.TextColor3 = ESP.Settings.Color
        TextLabel.TextSize = ESP.Settings.TextSize
        Instance.new("UIStroke", TextLabel)
        
        ESP.Instances.BillboardGui = BillboardGui
        ESP.Instances.TextLabel = TextLabel
    end
    
    local Highlight
    if ESP.Settings.ShowHighlight then
        Highlight = Instance.new("Highlight", ESP.Instances.Folder)
        Highlight.Adornee = nil
        Highlight.FillColor = ESP.Settings.Color
        Highlight.OutlineColor = ESP.Settings.Color
        Highlight.FillTransparency = 0.65
        Highlight.OutlineTransparency = 0
        
        ESP.Instances.Highlight = Highlight
    end
    
    function ESP:Update(newSettings)
        for i, v in pairs(newSettings) do
            ESP.Settings[i] = v
            if TextLabel then
                TextLabel.TextColor3 = ESP.Settings.Color
                TextLabel.TextSize = ESP.Settings.TextSize
            end
            if Highlight then
                Highlight.FillColor = ESP.Settings.Color
                Highlight.OutlineColor = ESP.Settings.Color
            end
        end
    end
    
    function ESP:Destroy()
        ESP.Instances.Folder:Destroy()
        Library.ESP[ESP.Index] = nil
    end
    
    function ESP:ToggleVisibility(Value)
        if BillboardGui then
            BillboardGui.Enabled = Value
        end
        if Highlight then
            Highlight.Adornee = Value and ESP.Settings.Object or nil
        end
    end
    ESP:ToggleVisibility(Library.Tags[ESP.Settings.Tag])

    Library.ESP[ESP.Index] = ESP
    return ESP
end

Library.SetEnabled = function(tag, value)
    Library.Tags[tag] = value
end

Library.ForEachTag = function(tag, callback)
    for _, ESP in pairs(Library.ESP) do
        if ESP.Settings.Tag == tag then
            callback(ESP)
        end
    end
end

Library.UpdateESP = function(tag, newSettings)
    Library.ForEachTag(tag, function(ESP)
        ESP:Update(newSettings)
    end)
end

Library.Clear = function(tag)
    Library.ForEachTag(tag, function(ESP)
        ESP:Destroy()
    end)
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
        if not Library.Tags[ESP.Settings.Tag] then
            ESP:ToggleVisibility(false)
            continue
        end
        
        if not ESP.Settings.ModelRoot then
            ESP.Settings.ModelRoot = FindPrimaryPart(ESP.Settings.Object)
        end
        local TargetPosition = ESP.Settings.ModelRoot:GetPivot().Position
        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(TargetPosition)
        ESP:ToggleVisibility(OnScreen)
        if not OnScreen then continue end
        
        local Distance = GetDistance(TargetPosition)
        if Distance > ESP.Settings.MaxDistance then
            ESP:ToggleVisibility(false)
            continue
        end
        
        if ESP.Settings.ShowTextLabel then
            if ESP.Settings.ShowDistance then
                ESP.Instances.TextLabel.Text = ("%s\n[%s]"):format(ESP.Settings.Name, math.floor(Distance))
            else
                ESP.Instances.TextLabel.Text = ESP.Settings.Name
            end
        end
    end
end))

getgenv().ESPLibrary = Library
return Library
