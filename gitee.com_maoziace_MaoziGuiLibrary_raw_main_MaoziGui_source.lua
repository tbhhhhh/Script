-- MaoziGui - 一个美观现代的Roblox GUI库
-- 作者: Maozi
-- 版本: 1.0.0

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local MaoziGui = {}
MaoziGui.__index = MaoziGui

-- 颜色主题
MaoziGui.Theme = {
    Primary = Color3.fromRGB(65, 105, 225),    -- 皇家蓝
    Secondary = Color3.fromRGB(70, 130, 180),  -- 钢蓝色
    Background = Color3.fromRGB(20, 20, 30),   -- 深蓝黑色
    Text = Color3.fromRGB(240, 240, 240),      -- 白色文本
    Success = Color3.fromRGB(46, 204, 113),    -- 成功绿色
    Warning = Color3.fromRGB(241, 196, 15),    -- 警告黄色
    Error = Color3.fromRGB(231, 76, 60),       -- 错误红色
    Highlight = Color3.fromRGB(100, 140, 250)  -- 高亮蓝色
}

-- 动画配置
MaoziGui.Animation = {
    TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    HoverTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

-- 基础字体和尺寸
MaoziGui.Font = Enum.Font.GothamSemibold
MaoziGui.TextSize = 14

-- 初始化库
function MaoziGui.new()
    local self = setmetatable({}, MaoziGui)
    
    -- 创建主屏幕GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MaoziGui"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- 处理Core GUI是否可用
    pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- 组件容器
    self.Components = {}
    self.NotificationQueue = {}
    
    -- 初始化动画系统
    self:SetupAnimationSystem()
    
    return self
end

-- 设置动画系统
function MaoziGui:SetupAnimationSystem()
    self.AnimationConnection = RunService.RenderStepped:Connect(function()
        for _, component in pairs(self.Components) do
            if component.Update then
                component:Update()
            end
        end
    end)
end

-- 创建通用的圆角边框
function MaoziGui:CreateRoundedFrame(name, size, position, color, parent, cornerRadius)
    cornerRadius = cornerRadius or UDim.new(0, 8)
    
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = cornerRadius
    corner.Parent = frame
    
    return frame
end

-- 创建阴影效果
function MaoziGui:AddShadow(frame, shadowTransparency)
    shadowTransparency = shadowTransparency or 0.5
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 35, 1, 35)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Image = "rbxassetid://7912134082"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = shadowTransparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(95, 95, 205, 205)
    shadow.Parent = frame
    
    return shadow
end

-- 创建窗口组件
function MaoziGui:CreateWindow(name, size)
    local window = {}
    window.__index = window
    setmetatable(window, {
        __index = self
    })
    
    -- 默认尺寸
    size = size or UDim2.new(0, 500, 0, 350)
    
    -- 创建主窗口框架
    window.Frame = self:CreateRoundedFrame(name, size, UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2), self.Theme.Background, self.ScreenGui)
    window.Frame.ZIndex = 10
    window.Frame.ClipsDescendants = true -- 默认开启裁剪，防止内容溢出
    window.Frame.Active = true
    
    -- 添加阴影
    self:AddShadow(window.Frame, 0.4)
    
    -- 窗口标题栏
    window.TitleBar = self:CreateRoundedFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.Theme.Primary, window.Frame)
    window.TitleBar.ZIndex = 11
    
    -- 只需要上边角为圆角
    local topOnlyCorner = Instance.new("UICorner")
    topOnlyCorner.CornerRadius = UDim.new(0, 8)
    topOnlyCorner.Parent = window.TitleBar
    
    -- 添加标题文本
    window.TitleText = Instance.new("TextLabel")
    window.TitleText.Name = "Title"
    window.TitleText.BackgroundTransparency = 1
    window.TitleText.Position = UDim2.new(0, 15, 0, 0)
    window.TitleText.Size = UDim2.new(1, -110, 1, 0) -- 修改尺寸以适应最小化按钮
    window.TitleText.Font = self.Font
    window.TitleText.TextSize = self.TextSize + 2
    window.TitleText.TextColor3 = self.Theme.Text
    window.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    window.TitleText.Text = name
    window.TitleText.ZIndex = 12
    window.TitleText.Parent = window.TitleBar
    
    -- 添加最小化按钮
    window.MinimizeButton = Instance.new("TextButton")
    window.MinimizeButton.Name = "MinimizeButton"
    window.MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
    window.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    window.MinimizeButton.BackgroundColor3 = self.Theme.Secondary
    window.MinimizeButton.Text = "-"
    window.MinimizeButton.Font = self.Font
    window.MinimizeButton.TextSize = 20
    window.MinimizeButton.TextColor3 = self.Theme.Text
    window.MinimizeButton.ZIndex = 12
    window.MinimizeButton.Parent = window.TitleBar
    
    -- 添加按钮圆角
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = window.MinimizeButton
    
    -- 添加关闭按钮
    window.CloseButton = Instance.new("TextButton")
    window.CloseButton.Name = "CloseButton"
    window.CloseButton.Position = UDim2.new(1, -35, 0, 5)
    window.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    window.CloseButton.BackgroundColor3 = self.Theme.Error
    window.CloseButton.Text = "X"
    window.CloseButton.Font = self.Font
    window.CloseButton.TextSize = 16
    window.CloseButton.TextColor3 = self.Theme.Text
    window.CloseButton.ZIndex = 12
    window.CloseButton.Parent = window.TitleBar
    
    -- 添加按钮圆角
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = window.CloseButton
    
    -- 内容容器
    window.ContentFrame = Instance.new("ScrollingFrame")
    window.ContentFrame.Name = "Content"
    window.ContentFrame.BackgroundTransparency = 1
    window.ContentFrame.Position = UDim2.new(0, 0, 0, 45)
    window.ContentFrame.Size = UDim2.new(1, 0, 1, -75) -- 减少高度以适应分页按钮
    window.ContentFrame.ScrollBarThickness = 4
    window.ContentFrame.ScrollBarImageColor3 = self.Theme.Secondary
    window.ContentFrame.BottomImage = "rbxassetid://7445543667"
    window.ContentFrame.MidImage = "rbxassetid://7445543667"
    window.ContentFrame.TopImage = "rbxassetid://7445543667"
    window.ContentFrame.ZIndex = 11
    window.ContentFrame.Parent = window.Frame
    
    -- 分页按钮容器
    window.PageButtonsFrame = Instance.new("Frame")
    window.PageButtonsFrame.Name = "PageButtons"
    window.PageButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
    window.PageButtonsFrame.Position = UDim2.new(0, 0, 1, -30)
    window.PageButtonsFrame.BackgroundTransparency = 1
    window.PageButtonsFrame.ZIndex = 11
    window.PageButtonsFrame.Parent = window.Frame
    
    -- 分页数据
    window.Pages = {}
    window.CurrentPage = 1
    window.PageButtons = {}
    
    -- 自动布局
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = window.ContentFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = window.ContentFrame
    
    -- 分页按钮自动布局
    local pageButtonsLayout = Instance.new("UIListLayout")
    pageButtonsLayout.Padding = UDim.new(0, 5)
    pageButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    pageButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    pageButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageButtonsLayout.Parent = window.PageButtonsFrame
    
    -- 设置自动更新内容尺寸
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)
    end)
    
    -- 最小化功能
    window.Minimized = false
    
    -- 最小化按钮功能
    window.MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(window.MinimizeButton, self.Animation.HoverTweenInfo, {BackgroundColor3 = self.Theme.Highlight, TextColor3 = self.Theme.Text}):Play()
    end)
    
    window.MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(window.MinimizeButton, self.Animation.HoverTweenInfo, {BackgroundColor3 = self.Theme.Secondary, TextColor3 = self.Theme.Text}):Play()
    end)
    
    window.MinimizeButton.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)
    
    -- 可拖动功能
    local dragging, dragInput, dragStart, startPos
    
    window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    window.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- 关闭按钮功能
    window.CloseButton.MouseEnter:Connect(function()
        TweenService:Create(window.CloseButton, self.Animation.HoverTweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 100, 100), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    window.CloseButton.MouseLeave:Connect(function()
        TweenService:Create(window.CloseButton, self.Animation.HoverTweenInfo, {BackgroundColor3 = self.Theme.Error, TextColor3 = self.Theme.Text}):Play()
    end)
    
    window.CloseButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- 关闭窗口函数
    function window:Destroy()
        -- 窗口关闭动画
        local closeTween = TweenService:Create(self.Frame, self.Animation.TweenInfo, {
            Size = UDim2.new(0, self.Frame.AbsoluteSize.X, 0, 0),
            Position = UDim2.new(self.Frame.Position.X.Scale, self.Frame.Position.X.Offset, 
                                 self.Frame.Position.Y.Scale, self.Frame.Position.Y.Offset + self.Frame.AbsoluteSize.Y/2)
        })
        
        closeTween:Play()
        closeTween.Completed:Connect(function()
            self.Frame:Destroy()
        end)
    end
    
    -- 切换最小化状态函数
    function window:ToggleMinimize()
        self.Minimized = not self.Minimized
        
        local targetSize
        if self.Minimized then
            -- 保存当前尺寸用于恢复
            self.OriginalSize = self.Frame.Size
            
            -- 先隐藏内容，防止内容显示在标题栏中
            self.ContentFrame.Visible = false
            self.PageButtonsFrame.Visible = false
            
            -- 确保内容不会溢出（虽然默认就是true，这里为了明确）
            self.Frame.ClipsDescendants = true
            
            -- 延迟一帧后再改变尺寸，确保内容已经隐藏
            RunService.RenderStepped:Wait()
            targetSize = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, 40)
        else
            targetSize = self.OriginalSize or UDim2.new(0, 500, 0, 350)
        end
        
        -- 动画过渡
        local sizeTween = TweenService:Create(self.Frame, self.Animation.TweenInfo, {
            Size = targetSize
        })
        
        sizeTween:Play()
        
        -- 更新内容可见性
        if not self.Minimized then
            sizeTween.Completed:Connect(function()
                self.ContentFrame.Visible = true
                self.PageButtonsFrame.Visible = true
            end)
        end
    end
    
    -- 添加页面函数
    function window:AddPage(name)
        -- 创建新页面容器
        local page = {}
        page.Name = name
        page.Elements = {}
        page.Container = Instance.new("Frame")
        page.Container.Name = "Page_" .. name
        page.Container.Size = UDim2.new(1, 0, 1, 0)
        page.Container.BackgroundTransparency = 1
        page.Container.Parent = self.ContentFrame
        
        -- 把页面添加到页面列表
        table.insert(self.Pages, page)
        
        -- 如果是第一个页面，显示它
        if #self.Pages == 1 then
            page.Container.Visible = true
        else
            page.Container.Visible = false
        end
        
        -- 创建页面按钮
        local pageIndex = #self.Pages
        local pageButton = Instance.new("TextButton")
        pageButton.Name = "PageButton_" .. name
        pageButton.Size = UDim2.new(0, 70, 0, 25)
        pageButton.BackgroundColor3 = pageIndex == self.CurrentPage and self.Theme.Primary or self.Theme.Secondary
        pageButton.Text = name
        pageButton.TextColor3 = self.Theme.Text
        pageButton.Font = self.Font
        pageButton.TextSize = self.TextSize - 2
        pageButton.ZIndex = 12
        pageButton.Parent = self.PageButtonsFrame
        
        -- 添加圆角
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = pageButton
        
        -- 点击切换页面
        pageButton.MouseButton1Click:Connect(function()
            self:SwitchPage(pageIndex)
        end)
        
        -- 添加到按钮列表
        self.PageButtons[pageIndex] = pageButton
        
        -- 更新分页按钮布局
        self:UpdatePageButtons()
        
        return page.Container
    end
    
    -- 切换页面函数
    function window:SwitchPage(pageIndex)
        if pageIndex < 1 or pageIndex > #self.Pages then return end
        
        -- 切换页面可见性
        for i, page in ipairs(self.Pages) do
            page.Container.Visible = i == pageIndex
        end
        
        -- 更新按钮样式
        for i, button in pairs(self.PageButtons) do
            button.BackgroundColor3 = i == pageIndex and self.Theme.Primary or self.Theme.Secondary
        end
        
        -- 更新当前页面索引
        self.CurrentPage = pageIndex
    end
    
    -- 更新分页按钮
    function window:UpdatePageButtons()
        -- 如果只有一个或没有页面，隐藏分页按钮
        if #self.Pages <= 1 then
            self.PageButtonsFrame.Visible = false
            self.ContentFrame.Size = UDim2.new(1, 0, 1, -45) -- 恢复内容区域大小
        else
            self.PageButtonsFrame.Visible = true
            self.ContentFrame.Size = UDim2.new(1, 0, 1, -75) -- 减小内容区域以适应分页按钮
        end
    end
    
    -- 把窗口添加到组件容器
    table.insert(self.Components, window)
    
    return window
end

-- 创建按钮组件
function MaoziGui:CreateButton(parent, text, callback)
    local button = {}
    button.__index = button
    setmetatable(button, {
        __index = self
    })
    
    -- 创建按钮框架
    button.Frame = self:CreateRoundedFrame("Button", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.Theme.Secondary, parent)
    button.Frame.ZIndex = 12
    
    -- 创建按钮文本
    button.Text = Instance.new("TextLabel")
    button.Text.Name = "ButtonText"
    button.Text.BackgroundTransparency = 1
    button.Text.Size = UDim2.new(1, 0, 1, 0)
    button.Text.Font = self.Font
    button.Text.TextSize = self.TextSize
    button.Text.TextColor3 = self.Theme.Text
    button.Text.Text = text
    button.Text.ZIndex = 13
    button.Text.Parent = button.Frame
    
    -- 点击效果
    local buttonEffect = Instance.new("Frame")
    buttonEffect.Name = "Effect"
    buttonEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buttonEffect.BackgroundTransparency = 1
    buttonEffect.Size = UDim2.new(1, 0, 1, 0)
    buttonEffect.ZIndex = 13
    buttonEffect.Parent = button.Frame
    
    local effectCorner = Instance.new("UICorner")
    effectCorner.CornerRadius = UDim.new(0, 8)
    effectCorner.Parent = buttonEffect
    
    -- 按钮点击和悬停效果
    button.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- 点击动画
            TweenService:Create(button.Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -4, 0, 36),
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
            
            TweenService:Create(buttonEffect, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.8
            }):Play()
            
            if callback then
                callback()
            end
        end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            -- 悬停动画
            TweenService:Create(button.Frame, self.Animation.HoverTweenInfo, {
                BackgroundColor3 = self.Theme.Highlight
            }):Play()
        end
    end)
    
    button.Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- 恢复原始大小
            TweenService:Create(button.Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 40),
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            TweenService:Create(buttonEffect, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)
    
    button.Frame.MouseLeave:Connect(function()
        -- 鼠标离开时恢复颜色
        TweenService:Create(button.Frame, self.Animation.HoverTweenInfo, {
            BackgroundColor3 = self.Theme.Secondary
        }):Play()
        
        -- 如果正在点击状态被打断，恢复大小
        TweenService:Create(button.Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        TweenService:Create(buttonEffect, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    return button
end

-- 创建开关组件
function MaoziGui:CreateToggle(parent, text, default, callback)
    local toggle = {}
    toggle.__index = toggle
    setmetatable(toggle, {
        __index = self
    })
    
    -- 默认状态
    toggle.Enabled = default or false
    
    -- 创建开关框架
    toggle.Frame = self:CreateRoundedFrame("Toggle", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.Theme.Background, parent)
    toggle.Frame.ZIndex = 12
    toggle.Frame.BackgroundTransparency = 0.6
    
    -- 创建开关文本
    toggle.Text = Instance.new("TextLabel")
    toggle.Text.Name = "ToggleText"
    toggle.Text.BackgroundTransparency = 1
    toggle.Text.Position = UDim2.new(0, 10, 0, 0)
    toggle.Text.Size = UDim2.new(1, -60, 1, 0)
    toggle.Text.Font = self.Font
    toggle.Text.TextSize = self.TextSize
    toggle.Text.TextColor3 = self.Theme.Text
    toggle.Text.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Text.Text = text
    toggle.Text.ZIndex = 13
    toggle.Text.Parent = toggle.Frame
    
    -- 创建开关按钮背景
    toggle.SwitchBg = self:CreateRoundedFrame("SwitchBackground", UDim2.new(0, 40, 0, 20), UDim2.new(1, -50, 0.5, -10), Color3.fromRGB(60, 60, 70), toggle.Frame, UDim.new(1, 0))
    toggle.SwitchBg.ZIndex = 13
    
    -- 创建开关按钮滑块
    toggle.Switch = self:CreateRoundedFrame("Switch", UDim2.new(0, 16, 0, 16), UDim2.new(0, 2, 0.5, -8), Color3.fromRGB(200, 200, 200), toggle.SwitchBg, UDim.new(1, 0))
    toggle.Switch.ZIndex = 14
    
    -- 初始化开关状态
    if toggle.Enabled then
        toggle.SwitchBg.BackgroundColor3 = self.Theme.Success
        toggle.Switch.Position = UDim2.new(1, -18, 0.5, -8)
    end
    
    -- 开关点击功能
    toggle.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle.Enabled = not toggle.Enabled
            
            if toggle.Enabled then
                -- 开启动画
                TweenService:Create(toggle.SwitchBg, self.Animation.TweenInfo, {
                    BackgroundColor3 = self.Theme.Success
                }):Play()
                
                TweenService:Create(toggle.Switch, self.Animation.TweenInfo, {
                    Position = UDim2.new(1, -18, 0.5, -8)
                }):Play()
            else
                -- 关闭动画
                TweenService:Create(toggle.SwitchBg, self.Animation.TweenInfo, {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                }):Play()
                
                TweenService:Create(toggle.Switch, self.Animation.TweenInfo, {
                    Position = UDim2.new(0, 2, 0.5, -8)
                }):Play()
            end
            
            if callback then
                callback(toggle.Enabled)
            end
        end
    end)
    
    -- 悬停效果
    toggle.Frame.MouseEnter:Connect(function()
        TweenService:Create(toggle.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.4
        }):Play()
    end)
    
    toggle.Frame.MouseLeave:Connect(function()
        TweenService:Create(toggle.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.6
        }):Play()
    end)
    
    -- 更新值方法
    function toggle:SetValue(value)
        self.Enabled = value
        
        if value then
            TweenService:Create(self.SwitchBg, MaoziGui.Animation.TweenInfo, {
                BackgroundColor3 = MaoziGui.Theme.Success
            }):Play()
            
            TweenService:Create(self.Switch, MaoziGui.Animation.TweenInfo, {
                Position = UDim2.new(1, -18, 0.5, -8)
            }):Play()
        else
            TweenService:Create(self.SwitchBg, MaoziGui.Animation.TweenInfo, {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
            
            TweenService:Create(self.Switch, MaoziGui.Animation.TweenInfo, {
                Position = UDim2.new(0, 2, 0.5, -8)
            }):Play()
        end
        
        if callback then
            callback(value)
        end
    end
    
    -- 获取值方法
    function toggle:GetValue()
        return self.Enabled
    end
    
    return toggle
end

-- 创建滑块组件
function MaoziGui:CreateSlider(parent, text, min, max, default, callback)
    local slider = {}
    slider.__index = slider
    setmetatable(slider, {
        __index = self
    })
    
    -- 默认值和范围
    min = min or 0
    max = max or 100
    default = default or min
    slider.Min = min
    slider.Max = max
    slider.Value = math.clamp(default, min, max)
    
    -- 创建滑块框架
    slider.Frame = self:CreateRoundedFrame("Slider", UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0), self.Theme.Background, parent)
    slider.Frame.ZIndex = 12
    slider.Frame.BackgroundTransparency = 0.6
    
    -- 创建滑块文本
    slider.Text = Instance.new("TextLabel")
    slider.Text.Name = "SliderText"
    slider.Text.BackgroundTransparency = 1
    slider.Text.Position = UDim2.new(0, 10, 0, 0)
    slider.Text.Size = UDim2.new(1, -20, 0, 30)
    slider.Text.Font = self.Font
    slider.Text.TextSize = self.TextSize
    slider.Text.TextColor3 = self.Theme.Text
    slider.Text.TextXAlignment = Enum.TextXAlignment.Left
    slider.Text.Text = text
    slider.Text.ZIndex = 13
    slider.Text.Parent = slider.Frame
    
    -- 创建滑块值显示
    slider.ValueLabel = Instance.new("TextLabel")
    slider.ValueLabel.Name = "ValueLabel"
    slider.ValueLabel.BackgroundTransparency = 1
    slider.ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    slider.ValueLabel.Size = UDim2.new(0, 40, 0, 30)
    slider.ValueLabel.Font = self.Font
    slider.ValueLabel.TextSize = self.TextSize
    slider.ValueLabel.TextColor3 = self.Theme.Text
    slider.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    slider.ValueLabel.Text = tostring(slider.Value) .. "%"
    slider.ValueLabel.ZIndex = 13
    slider.ValueLabel.Parent = slider.Frame
    
    -- 创建滑块轨道
    slider.SliderBg = self:CreateRoundedFrame("SliderBackground", UDim2.new(1, -20, 0, 10), UDim2.new(0, 10, 0, 40), Color3.fromRGB(60, 60, 70), slider.Frame, UDim.new(1, 0))
    slider.SliderBg.ZIndex = 13
    
    -- 创建滑块填充
    slider.SliderFill = self:CreateRoundedFrame("SliderFill", UDim2.new((slider.Value - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), self.Theme.Primary, slider.SliderBg, UDim.new(1, 0))
    slider.SliderFill.ZIndex = 14
    
    -- 创建滑块手柄
    slider.SliderHandle = self:CreateRoundedFrame("SliderHandle", UDim2.new(0, 16, 0, 16), UDim2.new((slider.Value - min) / (max - min), -8, 0.5, -8), Color3.fromRGB(240, 240, 240), slider.SliderBg, UDim.new(1, 0))
    slider.SliderHandle.ZIndex = 15
    
    -- 添加拖动阴影
    self:AddShadow(slider.SliderHandle, 0.7)
    
    -- 滑块拖动功能
    local isDragging = false
    
    slider.SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            slider:UpdateValue(input.Position.X)
        end
    end)
    
    slider.SliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            slider:UpdateValue(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    -- 悬停效果
    slider.Frame.MouseEnter:Connect(function()
        TweenService:Create(slider.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.4
        }):Play()
    end)
    
    slider.Frame.MouseLeave:Connect(function()
        TweenService:Create(slider.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.6
        }):Play()
    end)
    
    -- 更新滑块值的方法
    function slider:UpdateValue(mouseX)
        -- 获取滑块轨道的相对位置
        local sliderPosition = slider.SliderBg.AbsolutePosition.X
        local sliderWidth = slider.SliderBg.AbsoluteSize.X
        
        -- 计算鼠标位置相对于滑块的百分比
        local percentage = math.clamp((mouseX - sliderPosition) / sliderWidth, 0, 1)
        
        -- 计算实际值
        local value = min + ((max - min) * percentage)
        -- 如果是整数范围，则取整
        if math.floor(min) == min and math.floor(max) == max then
            value = math.floor(value + 0.5)
        else
            -- 保留一位小数
            value = math.floor(value * 10 + 0.5) / 10
        end
        
        -- 更新值
        slider.Value = value
        
        -- 更新UI
        slider.ValueLabel.Text = tostring(value) .. "%"
        slider.SliderFill:TweenSize(UDim2.new(percentage, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        slider.SliderHandle:TweenPosition(UDim2.new(percentage, -8, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        
        -- 触发回调
        if callback then
            callback(value)
        end
    end
    
    -- 设置值方法
    function slider:SetValue(value)
        value = math.clamp(value, self.Min, self.Max)
        local percentage = (value - self.Min) / (self.Max - self.Min)
        
        -- 更新值
        self.Value = value
        
        -- 更新UI
        self.ValueLabel.Text = tostring(value) .. "%"
        self.SliderFill:TweenSize(UDim2.new(percentage, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        self.SliderHandle:TweenPosition(UDim2.new(percentage, -8, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        
        -- 触发回调
        if callback then
            callback(value)
        end
    end
    
    -- 获取值方法
    function slider:GetValue()
        return self.Value
    end
    
    return slider
end

-- 创建文本输入框
function MaoziGui:CreateTextBox(parent, text, placeholderText, callback)
    local textbox = {}
    textbox.__index = textbox
    setmetatable(textbox, {
        __index = self
    })
    
    -- 创建输入框框架
    textbox.Frame = self:CreateRoundedFrame("TextBox", UDim2.new(1, 0, 0, 70), UDim2.new(0, 0, 0, 0), self.Theme.Background, parent)
    textbox.Frame.ZIndex = 12
    textbox.Frame.BackgroundTransparency = 0.6
    
    -- 创建输入框标签文本
    textbox.Label = Instance.new("TextLabel")
    textbox.Label.Name = "TextBoxLabel"
    textbox.Label.BackgroundTransparency = 1
    textbox.Label.Position = UDim2.new(0, 10, 0, 0)
    textbox.Label.Size = UDim2.new(1, -20, 0, 30)
    textbox.Label.Font = self.Font
    textbox.Label.TextSize = self.TextSize
    textbox.Label.TextColor3 = self.Theme.Text
    textbox.Label.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Label.Text = text
    textbox.Label.ZIndex = 13
    textbox.Label.Parent = textbox.Frame
    
    -- 创建输入框背景
    textbox.TextBoxBg = self:CreateRoundedFrame("TextBoxBackground", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 35), Color3.fromRGB(50, 50, 60), textbox.Frame)
    textbox.TextBoxBg.ZIndex = 13
    
    -- 创建实际的输入框
    textbox.InputBox = Instance.new("TextBox")
    textbox.InputBox.Name = "Input"
    textbox.InputBox.BackgroundTransparency = 1
    textbox.InputBox.Position = UDim2.new(0, 10, 0, 0)
    textbox.InputBox.Size = UDim2.new(1, -20, 1, 0)
    textbox.InputBox.Font = self.Font
    textbox.InputBox.TextSize = self.TextSize
    textbox.InputBox.TextColor3 = self.Theme.Text
    textbox.InputBox.PlaceholderText = placeholderText or "输入文本..."
    textbox.InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    textbox.InputBox.Text = ""
    textbox.InputBox.ClearTextOnFocus = false
    textbox.InputBox.ZIndex = 14
    textbox.InputBox.Parent = textbox.TextBoxBg
    
    -- 聚焦和输入效果
    textbox.InputBox.Focused:Connect(function()
        TweenService:Create(textbox.TextBoxBg, self.Animation.TweenInfo, {
            BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        }):Play()
    end)
    
    textbox.InputBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textbox.TextBoxBg, self.Animation.TweenInfo, {
            BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        }):Play()
        
        if callback then
            callback(textbox.InputBox.Text, enterPressed)
        end
    end)
    
    -- 悬停效果
    textbox.Frame.MouseEnter:Connect(function()
        TweenService:Create(textbox.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.4
        }):Play()
    end)
    
    textbox.Frame.MouseLeave:Connect(function()
        TweenService:Create(textbox.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.6
        }):Play()
    end)
    
    -- 设置文本方法
    function textbox:SetText(text)
        self.InputBox.Text = text
    end
    
    -- 获取文本方法
    function textbox:GetText()
        return self.InputBox.Text
    end
    
    return textbox
end

-- 创建下拉菜单组件
function MaoziGui:CreateDropdown(parent, text, options, default, callback)
    local dropdown = {}
    dropdown.__index = dropdown
    setmetatable(dropdown, {
        __index = self
    })
    
    -- 选项设置
    dropdown.Options = options or {}
    dropdown.SelectedOption = default or (options and options[1] or "")
    dropdown.IsOpen = false
    dropdown.OptionButtons = {}
    
    -- 创建下拉菜单框架
    dropdown.Frame = self:CreateRoundedFrame("Dropdown", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.Theme.Background, parent)
    dropdown.Frame.ZIndex = 12
    dropdown.Frame.BackgroundTransparency = 0.6
    dropdown.Frame.ClipsDescendants = true
    
    -- 创建下拉菜单文本
    dropdown.Text = Instance.new("TextLabel")
    dropdown.Text.Name = "DropdownLabel"
    dropdown.Text.BackgroundTransparency = 1
    dropdown.Text.Position = UDim2.new(0, 10, 0, 0)
    dropdown.Text.Size = UDim2.new(1, -45, 0, 40)
    dropdown.Text.Font = self.Font
    dropdown.Text.TextSize = self.TextSize
    dropdown.Text.TextColor3 = self.Theme.Text
    dropdown.Text.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.Text.Text = text
    dropdown.Text.ZIndex = 13
    dropdown.Text.Parent = dropdown.Frame
    
    -- 创建选择指示器
    dropdown.Selected = Instance.new("TextLabel")
    dropdown.Selected.Name = "Selected"
    dropdown.Selected.BackgroundTransparency = 1
    dropdown.Selected.Position = UDim2.new(1, -130, 0, 0)
    dropdown.Selected.Size = UDim2.new(0, 100, 0, 40)
    dropdown.Selected.Font = self.Font
    dropdown.Selected.TextSize = self.TextSize
    dropdown.Selected.TextColor3 = self.Theme.Primary
    dropdown.Selected.TextXAlignment = Enum.TextXAlignment.Right
    dropdown.Selected.Text = dropdown.SelectedOption
    dropdown.Selected.ZIndex = 13
    dropdown.Selected.Parent = dropdown.Frame
    
    -- 创建下拉箭头
    dropdown.Arrow = Instance.new("ImageLabel")
    dropdown.Arrow.Name = "Arrow"
    dropdown.Arrow.BackgroundTransparency = 1
    dropdown.Arrow.Position = UDim2.new(1, -35, 0, 5)
    dropdown.Arrow.Size = UDim2.new(0, 30, 0, 30)
    dropdown.Arrow.Image = "rbxassetid://7072706620"
    dropdown.Arrow.ImageColor3 = self.Theme.Text
    dropdown.Arrow.ZIndex = 13
    dropdown.Arrow.Parent = dropdown.Frame
    
    -- 创建选项容器
    dropdown.OptionsFrame = self:CreateRoundedFrame("Options", UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 40), self.Theme.Background, dropdown.Frame)
    dropdown.OptionsFrame.ZIndex = 14
    dropdown.OptionsFrame.BackgroundTransparency = 0.2
    
    -- 设置最大选项数量和选项创建
    local MAX_VISIBLE_OPTIONS = 5
    local optionHeight = 30
    
    -- 生成选项函数
    function dropdown:GenerateOptions()
        -- 清除旧选项
        for _, button in pairs(dropdown.OptionButtons) do
            button:Destroy()
        end
        dropdown.OptionButtons = {}
        
        -- 如果没有选项，则返回
        if #self.Options == 0 then
            return
        end
        
        -- 计算适当的选项框高度
        local optionsCount = math.min(#self.Options, MAX_VISIBLE_OPTIONS)
        local totalHeight = optionsCount * optionHeight
        
        -- 更新选项框尺寸
        if self.IsOpen then
            self.OptionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        else
            self.OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
        end
        
        -- 如果关闭，则不显示选项
        if not self.IsOpen then
            return
        end
        
        -- 创建选项按钮
        for i, option in ipairs(self.Options) do
            local button = Instance.new("TextButton")
            button.Name = "Option_" .. i
            button.Size = UDim2.new(1, 0, 0, optionHeight)
            button.Position = UDim2.new(0, 0, 0, (i-1) * optionHeight)
            button.BackgroundTransparency = 0.9
            button.BackgroundColor3 = self.Theme.Secondary
            button.Font = self.Font
            button.TextSize = self.TextSize
            button.TextColor3 = self.Theme.Text
            button.Text = option
            button.TextXAlignment = Enum.TextXAlignment.Center
            button.ZIndex = 15
            button.Parent = self.OptionsFrame
            
            -- 选项悬停效果
            button.MouseEnter:Connect(function()
                TweenService:Create(button, self.Animation.HoverTweenInfo, {
                    BackgroundTransparency = 0.5
                }):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, self.Animation.HoverTweenInfo, {
                    BackgroundTransparency = 0.9
                }):Play()
            end)
            
            -- 选项点击功能
            button.MouseButton1Click:Connect(function()
                self:SelectOption(option)
            end)
            
            table.insert(self.OptionButtons, button)
        end
    end
    
    -- 选择选项功能
    function dropdown:SelectOption(option)
        self.SelectedOption = option
        self.Selected.Text = option
        
        -- 关闭下拉菜单
        self:Toggle(false)
        
        -- 触发回调
        if callback then
            callback(option)
        end
    end
    
    -- 切换下拉菜单功能
    function dropdown:Toggle(state)
        if state == nil then
            state = not self.IsOpen
        end
        
        self.IsOpen = state
        
        -- 更新箭头旋转
        TweenService:Create(self.Arrow, self.Animation.TweenInfo, {
            Rotation = self.IsOpen and 180 or 0
        }):Play()
        
        -- 更新框架大小
        if self.IsOpen then
            local optionsCount = math.min(#self.Options, MAX_VISIBLE_OPTIONS)
            local targetHeight = 40 + (optionsCount * optionHeight)
            
            self.Frame:TweenSize(
                UDim2.new(1, 0, 0, targetHeight),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quart,
                0.3,
                true
            )
            
            -- 生成选项
            self:GenerateOptions()
        else
            self.Frame:TweenSize(
                UDim2.new(1, 0, 0, 40),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quart,
                0.3,
                true
            )
            
            -- 清除选项
            spawn(function()
                wait(0.3)
                if not self.IsOpen then
                    self:GenerateOptions()
                end
            end)
        end
    end
    
    -- 点击下拉菜单
    dropdown.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dropdown:Toggle()
        end
    end)
    
    -- 悬停效果
    dropdown.Frame.MouseEnter:Connect(function()
        TweenService:Create(dropdown.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.4
        }):Play()
    end)
    
    dropdown.Frame.MouseLeave:Connect(function()
        TweenService:Create(dropdown.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.6
        }):Play()
    end)
    
    -- 设置选项方法
    function dropdown:SetOptions(newOptions)
        self.Options = newOptions or {}
        self.SelectedOption = self.Options[1] or ""
        self.Selected.Text = self.SelectedOption
        self:GenerateOptions()
    end
    
    -- 设置选择的选项
    function dropdown:SetValue(value)
        if table.find(self.Options, value) then
            self.SelectedOption = value
            self.Selected.Text = value
        end
    end
    
    -- 获取选择的选项
    function dropdown:GetValue()
        return self.SelectedOption
    end
    
    return dropdown
end

-- 创建通知系统
function MaoziGui:CreateNotification(title, text, notificationType, duration)
    local notification = {}
    notification.__index = notification
    
    -- 默认值
    notificationType = notificationType or "Info" -- Info, Success, Warning, Error
    duration = duration or 3 -- 秒
    
    -- 设置通知类型颜色
    local notificationColor
    if notificationType == "Success" then
        notificationColor = self.Theme.Success
    elseif notificationType == "Warning" then
        notificationColor = self.Theme.Warning
    elseif notificationType == "Error" then
        notificationColor = self.Theme.Error
    else
        notificationColor = self.Theme.Primary
    end
    
    -- 创建通知框架
    notification.Frame = self:CreateRoundedFrame("Notification", UDim2.new(0, 300, 0, 80), UDim2.new(1, -320, 0.8, 0), self.Theme.Background, self.ScreenGui)
    notification.Frame.ZIndex = 100
    
    -- 添加阴影
    self:AddShadow(notification.Frame, 0.3)
    
    -- 创建通知标题
    notification.Title = Instance.new("TextLabel")
    notification.Title.Name = "Title"
    notification.Title.BackgroundTransparency = 1
    notification.Title.Position = UDim2.new(0, 15, 0, 10)
    notification.Title.Size = UDim2.new(1, -25, 0, 25)
    notification.Title.Font = self.Font
    notification.Title.TextSize = self.TextSize + 2
    notification.Title.TextColor3 = notificationColor
    notification.Title.TextXAlignment = Enum.TextXAlignment.Left
    notification.Title.Text = title
    notification.Title.ZIndex = 102
    notification.Title.Parent = notification.Frame
    
    -- 创建通知内容
    notification.Content = Instance.new("TextLabel")
    notification.Content.Name = "Content"
    notification.Content.BackgroundTransparency = 1
    notification.Content.Position = UDim2.new(0, 15, 0, 35)
    notification.Content.Size = UDim2.new(1, -25, 0, 35)
    notification.Content.Font = self.Font
    notification.Content.TextSize = self.TextSize
    notification.Content.TextColor3 = self.Theme.Text
    notification.Content.TextXAlignment = Enum.TextXAlignment.Left
    notification.Content.TextWrapped = true
    notification.Content.Text = text
    notification.Content.ZIndex = 102
    notification.Content.Parent = notification.Frame
    
    -- 创建通知图标
    notification.Icon = Instance.new("ImageLabel")
    notification.Icon.Name = "Icon"
    notification.Icon.BackgroundTransparency = 1
    notification.Icon.Position = UDim2.new(1, -45, 0, 10)
    notification.Icon.Size = UDim2.new(0, 30, 0, 30)
    notification.Icon.ZIndex = 102
    notification.Icon.Parent = notification.Frame
    
    -- 根据通知类型设置图标
    if notificationType == "Success" then
        notification.Icon.Image = "rbxassetid://7072707515" -- 成功图标
    elseif notificationType == "Warning" then
        notification.Icon.Image = "rbxassetid://7072714816" -- 警告图标
    elseif notificationType == "Error" then
        notification.Icon.Image = "rbxassetid://7072718266" -- 错误图标
    else
        notification.Icon.Image = "rbxassetid://7072717958" -- 信息图标
    end
    notification.Icon.ImageColor3 = notificationColor
    
    -- 添加通知到队列
    table.insert(self.NotificationQueue, notification)
    
    -- 更新通知位置
    self:UpdateNotificationsPosition()
    
    -- 动画进入
    notification.Frame.Position = UDim2.new(1, 20, 0.8, 0)
    TweenService:Create(notification.Frame, self.Animation.TweenInfo, {
        Position = UDim2.new(1, -320, 0.8, 0)
    }):Play()
    
    -- 设置自动消失
    spawn(function()
        wait(duration)
        self:RemoveNotification(notification)
    end)
    
    return notification
end

-- 更新通知位置
function MaoziGui:UpdateNotificationsPosition()
    local spacing = 10 -- 通知之间的间距
    local totalHeight = 0
    
    for i = #self.NotificationQueue, 1, -1 do
        local notification = self.NotificationQueue[i]
        local height = notification.Frame.AbsoluteSize.Y
        
        TweenService:Create(notification.Frame, self.Animation.TweenInfo, {
            Position = UDim2.new(1, -320, 0.8, -(totalHeight))
        }):Play()
        
        totalHeight = totalHeight + height + spacing
    end
end

-- 移除通知
function MaoziGui:RemoveNotification(notification)
    -- 动画退出
    TweenService:Create(notification.Frame, self.Animation.TweenInfo, {
        Position = UDim2.new(1, 20, notification.Frame.Position.Y.Scale, notification.Frame.Position.Y.Offset),
        Transparency = 1
    }):Play()
    
    -- 从队列中移除
    for i, notif in ipairs(self.NotificationQueue) do
        if notif == notification then
            table.remove(self.NotificationQueue, i)
            break
        end
    end
    
    -- 清理通知
    spawn(function()
        wait(0.5)
        notification.Frame:Destroy()
    end)
    
    -- 更新其它通知的位置
    self:UpdateNotificationsPosition()
end

-- 创建标签组件
function MaoziGui:CreateLabel(parent, text, textSize)
    local label = {}
    label.__index = label
    setmetatable(label, {
        __index = self
    })
    
    -- 创建标签框架
    label.Frame = Instance.new("Frame")
    label.Frame.Name = "Label"
    label.Frame.Size = UDim2.new(1, 0, 0, 30)
    label.Frame.BackgroundTransparency = 1
    label.Frame.Parent = parent
    
    -- 创建标签文本
    label.Text = Instance.new("TextLabel")
    label.Text.Name = "LabelText"
    label.Text.BackgroundTransparency = 1
    label.Text.Size = UDim2.new(1, 0, 1, 0)
    label.Text.Font = self.Font
    label.Text.TextSize = textSize or self.TextSize
    label.Text.TextColor3 = self.Theme.Text
    label.Text.TextXAlignment = Enum.TextXAlignment.Left
    label.Text.Text = text
    label.Text.Parent = label.Frame
    
    -- 设置文本方法
    function label:SetText(newText)
        self.Text.Text = newText
    end
    
    -- 设置颜色方法
    function label:SetColor(color)
        self.Text.TextColor3 = color
    end
    
    return label
end

-- 创建分割线组件
function MaoziGui:CreateDivider(parent, color)
    local divider = {}
    divider.__index = divider
    setmetatable(divider, {
        __index = self
    })
    
    color = color or self.Theme.Secondary
    
    -- 创建分割线框架
    divider.Frame = Instance.new("Frame")
    divider.Frame.Name = "Divider"
    divider.Frame.Size = UDim2.new(1, -30, 0, 1)
    divider.Frame.Position = UDim2.new(0, 15, 0, 0)
    divider.Frame.BackgroundColor3 = color
    divider.Frame.BackgroundTransparency = 0.5
    divider.Frame.BorderSizePixel = 0
    divider.Frame.Parent = parent
    
    -- 设置颜色方法
    function divider:SetColor(newColor)
        self.Frame.BackgroundColor3 = newColor
    end
    
    return divider
end

-- 创建进度条组件
function MaoziGui:CreateProgressBar(parent, text, initialValue)
    local progressBar = {}
    progressBar.__index = progressBar
    setmetatable(progressBar, {
        __index = self
    })
    
    initialValue = initialValue or 0
    progressBar.Value = math.clamp(initialValue, 0, 100)
    
    -- 创建进度条框架
    progressBar.Frame = self:CreateRoundedFrame("ProgressBar", UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 0), self.Theme.Background, parent)
    progressBar.Frame.ZIndex = 12
    progressBar.Frame.BackgroundTransparency = 0.6
    
    -- 创建进度条文本
    progressBar.Text = Instance.new("TextLabel")
    progressBar.Text.Name = "ProgressText"
    progressBar.Text.BackgroundTransparency = 1
    progressBar.Text.Position = UDim2.new(0, 10, 0, 0)
    progressBar.Text.Size = UDim2.new(1, -60, 0, 25)
    progressBar.Text.Font = self.Font
    progressBar.Text.TextSize = self.TextSize
    progressBar.Text.TextColor3 = self.Theme.Text
    progressBar.Text.TextXAlignment = Enum.TextXAlignment.Left
    progressBar.Text.Text = text
    progressBar.Text.ZIndex = 13
    progressBar.Text.Parent = progressBar.Frame
    
    -- 创建进度条值显示
    progressBar.ValueLabel = Instance.new("TextLabel")
    progressBar.ValueLabel.Name = "ValueLabel"
    progressBar.ValueLabel.BackgroundTransparency = 1
    progressBar.ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    progressBar.ValueLabel.Size = UDim2.new(0, 40, 0, 25)
    progressBar.ValueLabel.Font = self.Font
    progressBar.ValueLabel.TextSize = self.TextSize
    progressBar.ValueLabel.TextColor3 = self.Theme.Text
    progressBar.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    progressBar.ValueLabel.Text = tostring(progressBar.Value) .. "%"
    progressBar.ValueLabel.ZIndex = 13
    progressBar.ValueLabel.Parent = progressBar.Frame
    
    -- 创建进度条背景
    progressBar.BarBg = self:CreateRoundedFrame("ProgressBackground", UDim2.new(1, -20, 0, 15), UDim2.new(0, 10, 0, 30), Color3.fromRGB(60, 60, 70), progressBar.Frame, UDim.new(1, 0))
    progressBar.BarBg.ZIndex = 13
    
    -- 创建进度条填充
    progressBar.BarFill = self:CreateRoundedFrame("ProgressFill", UDim2.new(progressBar.Value/100, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.Theme.Primary, progressBar.BarBg, UDim.new(1, 0))
    progressBar.BarFill.ZIndex = 14
    
    -- 悬停效果
    progressBar.Frame.MouseEnter:Connect(function()
        TweenService:Create(progressBar.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.4
        }):Play()
    end)
    
    progressBar.Frame.MouseLeave:Connect(function()
        TweenService:Create(progressBar.Frame, self.Animation.HoverTweenInfo, {
            BackgroundTransparency = 0.6
        }):Play()
    end)
    
    -- 设置值方法
    function progressBar:SetValue(value)
        self.Value = math.clamp(value, 0, 100)
        self.ValueLabel.Text = tostring(self.Value) .. "%"
        
        -- 更新进度条动画
        TweenService:Create(self.BarFill, self.Animation.TweenInfo, {
            Size = UDim2.new(self.Value/100, 0, 1, 0)
        }):Play()
        
        -- 根据值改变颜色
        local color
        if self.Value < 30 then
            color = self.Theme.Error
        elseif self.Value < 70 then
            color = self.Theme.Warning
        else
            color = self.Theme.Success
        end
        
        TweenService:Create(self.BarFill, self.Animation.TweenInfo, {
            BackgroundColor3 = color
        }):Play()
    end
    
    -- 获取值方法
    function progressBar:GetValue()
        return self.Value
    end
    
    -- 初始化颜色
    if progressBar.Value < 30 then
        progressBar.BarFill.BackgroundColor3 = self.Theme.Error
    elseif progressBar.Value < 70 then
        progressBar.BarFill.BackgroundColor3 = self.Theme.Warning
    else
        progressBar.BarFill.BackgroundColor3 = self.Theme.Success
    end
    
    return progressBar
end

-- 清理函数
function MaoziGui:Destroy()
    -- 断开所有连接
    if self.AnimationConnection then
        self.AnimationConnection:Disconnect()
    end
    
    -- 清理所有组件
    for _, component in pairs(self.Components) do
        if component.Frame and component.Frame:IsA("GuiObject") then
            component.Frame:Destroy()
        end
    end
    
    -- 清理所有通知
    for _, notification in pairs(self.NotificationQueue) do
        if notification.Frame and notification.Frame:IsA("GuiObject") then
            notification.Frame:Destroy()
        end
    end
    
    -- 清理主屏幕GUI
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    -- 清空表格
    self.Components = {}
    self.NotificationQueue = {}
end

-- 加载主题函数
function MaoziGui:LoadTheme(theme)
    if type(theme) ~= "table" then
        return
    end
    
    -- 更新主题颜色
    for key, color in pairs(theme) do
        if self.Theme[key] then
            self.Theme[key] = color
        end
    end
end

-- 返回库
return MaoziGui