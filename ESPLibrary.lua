if getgenv().ESPLibrary then
    return getgenv().ESPLibrary
end

local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Library = {
    ESP = {},
    ESPFolder = Instance.new("Folder", CoreGui),
    ShowDistance = true,
    MaxDistance = math.huge
}
Library.ESPFolder.Name = "ESPFolder"
Library.Highlight = function(object, name, color, size, tag)
    local ESP = {
        Index = #Library.ESP+1,
        Object = object,
        Name = name,
        Tag = tag
    }
    local BillboardGui = Instance.new("BillboardGui", Library.ESPFolder)
    BillboardGui.Name = tag
    BillboardGui.Enabled = true
    BillboardGui.ResetOnSpawn = false
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.Adornee = object
    BillboardGui.StudsOffset = Vector3.new(0, 0, 0)
    
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    TextLabel.Size = UDim2.new(0, 200, 0, 50)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextWrapped = true
    TextLabel.RichText = true
    TextLabel.TextStrokeTransparency = 0
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name
    TextLabel.TextColor3 = color
    TextLabel.TextSize = size
    
    local UIStroke = Instance.new("UIStroke", TextLabel)
    UIStroke.Thickness = 1
    
    local Highlight = Instance.new("Highlight", BillboardGui)
    Highlight.Adornee = object
    Highlight.FillColor = color
    Highlight.OutlineColor = color
    Highlight.FillTransparency = 0.65
    Highlight.OutlineTransparency = 0
    
    ESP.BillboardGui = BillboardGui
    ESP.TextLabel = TextLabel
    ESP.UIStroke = UIStroke
    ESP.Highlight = Highlight
    
    function ESP:Destroy()
        BillboardGui:Destroy()
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
    for _, v in pairs(Library.ESP) do
        if v.Tag == tag then
            v:Destroy()
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, v in pairs(Library.ESP) do
        local TargetPosition = v.Object:GetPivot().Position
        local ScreenPosition, OnScreen = Camera:WorldToScreenPoint(TargetPosition)
        
        v:ToggleVisibility(OnScreen)
        if not OnScreen then return end
        
        local Distance = LP:DistanceFromCharacter(TargetPosition)
        if Distance > Library.MaxDistance then
            v:ToggleVisibility(false)
            return
        end
        
        if Library.ShowDistance then
            v.TextLabel.Text = ("%s\n[%s]"):format(v.Name, math.floor(Distance))
        else
            v.TextLabel.Text = v.Name
        end
    end
end)

getgenv().ESPLibrary = Library
return Library
