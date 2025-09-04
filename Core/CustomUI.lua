-- Custom UI Library (No external dependencies)
local CustomUI = {}
CustomUI.__index = CustomUI

-- Colors
CustomUI.Colors = {
    Background = Color3.fromRGB(30, 30, 40),
    Header = Color3.fromRGB(25, 25, 35),
    Button = Color3.fromRGB(45, 45, 55),
    ButtonHover = Color3.fromRGB(55, 55, 65),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 120, 215),
    Section = Color3.fromRGB(40, 40, 50)
}

function CustomUI:CreateWindow(title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomTDSGUI"
    screenGui.Parent = game.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = self.Colors.Header
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "TDS Script"
    titleLabel.TextColor3 = self.Colors.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = self.Colors.Text
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -10, 1, -50)
    contentFrame.Position = UDim2.new(0, 5, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 5
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = contentFrame
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local window = {
        GUI = screenGui,
        Frame = mainFrame,
        Content = contentFrame
    }
    
    setmetatable(window, self)
    
    function window:Button(text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = self.Colors.Button
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = self.Colors.Text
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.Parent = self.Content
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        
        button.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.ButtonHover}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.Button}):Play()
        end)
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    function window:Toggle(text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = self.Content
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = self.Colors.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.25, 0, 0, 25)
        toggle.Position = UDim2.new(0.75, 0, 0, 2.5)
        toggle.BackgroundColor3 = default and self.Colors.Accent or Color3.fromRGB(80, 80, 80)
        toggle.BorderSizePixel = 0
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = self.Colors.Text
        toggle.Font = Enum.Font.Gotham
        toggle.TextSize = 12
        toggle.Parent = frame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = toggle
        
        toggle.MouseButton1Click:Connect(function()
            local newState = not (toggle.Text == "ON")
            toggle.Text = newState and "ON" or "OFF"
            toggle.BackgroundColor3 = newState and self.Colors.Accent or Color3.fromRGB(80, 80, 80)
            if callback then callback(newState) end
        end)
        
        return toggle
    end
    
    function window:Label(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = self.Colors.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = self.Content
        
        return label
    end
    
    function window:Section(text)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = self.Colors.Section
        frame.BorderSizePixel = 0
        frame.Parent = self.Content
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = self.Colors.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = frame
        
        return label
    end
    
    function window:Dropdown(text, options, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = self.Content
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = self.Colors.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(0.25, 0, 0, 25)
        dropdown.Position = UDim2.new(0.75, 0, 0, 2.5)
        dropdown.BackgroundColor3 = self.Colors.Button
        dropdown.BorderSizePixel = 0
        dropdown.Text = options[1] or "Select"
        dropdown.TextColor3 = self.Colors.Text
        dropdown.Font = Enum.Font.Gotham
        dropdown.TextSize = 12
        dropdown.Parent = frame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = dropdown
        
        local dropdownOpen = false
        local dropdownFrame
        
        dropdown.MouseButton1Click:Connect(function()
            if dropdownOpen then
                if dropdownFrame then
                    dropdownFrame:Destroy()
                    dropdownFrame = nil
                end
                dropdownOpen = false
            else
                dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(0.25, 0, 0, #options * 25)
                dropdownFrame.Position = UDim2.new(0.75, 0, 0, 30)
                dropdownFrame.BackgroundColor3 = self.Colors.Background
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ZIndex = 5
                dropdownFrame.Parent = frame
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = dropdownFrame
                
                local layout = Instance.new("UIListLayout")
                layout.Parent = dropdownFrame
                
                for _, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 25)
                    optionButton.BackgroundColor3 = self.Colors.Button
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = self.Colors.Text
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.TextSize = 12
                    optionButton.Parent = dropdownFrame
                    
                    optionButton.MouseButton1Click:Connect(function()
                        dropdown.Text = option
                        if callback then callback(option) end
                        dropdownFrame:Destroy()
                        dropdownOpen = false
                    end)
                end
                
                dropdownOpen = true
            end
        end)
        
        return dropdown
    end
    
    return window
end

return CustomUI
