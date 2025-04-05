local CoreGui = cloneref(game:GetService("CoreGui"))

local Library = {
    ESPFolder = Instance.new("Folder", CoreGui)
}
Library.ESPFolder.Name = "ESPFolder"
Library.Highlight = function(child, name, color, size, tag)
    local BillboardGui = Instance.new("BillboardGui", Library.ESPFolder)
    BillboardGui.Name = tag
    BillboardGui.Enabled = true
    BillboardGui.ResetOnSpawn = false
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.Adornee = child
    
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    TextLabel.Size = UDim2.new(0, 200, 0, 50)
    TextLabel.Position = UDim2.new(0, 0, 0, -20)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextWrapped = true
    TextLabel.RichText = true
    TextLabel.TextStrokeTransparency = 0
    TextLabel.BackgroundTransparency = 1
    
    TextLabel.Text = name
    TextLabel.TextColor3 = color
    TextLabel.TextSize = size
    
    local UIStroke = Instance.new("UIStroke", TextLabel)
    UIStroke.Thickness = 0.75
    
    local Highlight = Instance.new("Highlight", BillboardGui)
    Highlight.Adornee = child
    Highlight.FillColor = color
    Highlight.OutlineColor = color
    Highlight.FillTransparency = 0.7
    Highlight.OutlineTransparency = 0
    
    return BillboardGui
end

Library.Clear = function(tag)
    for _, v in pairs(Library.ESPFolder:GetChildren()) do
        if v.Name == tag then
            v:Destroy()
        end
    end
end

getgenv().ESPLibrary = Library
return Library
