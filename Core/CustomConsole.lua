-- Custom Console Library (No external dependencies)
local CustomConsole = {}
CustomConsole.__index = CustomConsole

function CustomConsole:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomConsole"
    screenGui.Parent = game.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "ConsoleFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -300, 1, -320)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Console"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -25, 0, 2.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeButton
    
    local consoleOutput = Instance.new("ScrollingFrame")
    consoleOutput.Name = "Output"
    consoleOutput.Size = UDim2.new(1, -10, 1, -40)
    consoleOutput.Position = UDim2.new(0, 5, 0, 35)
    consoleOutput.BackgroundTransparency = 1
    consoleOutput.BorderSizePixel = 0
    consoleOutput.ScrollBarThickness = 5
    consoleOutput.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleOutput.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = consoleOutput
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
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
    
    local console = {
        GUI = screenGui,
        Output = consoleOutput
    }
    
    setmetatable(console, self)
    
    function console:Log(message, messageType)
        messageType = messageType or "INFO"
        
        local color
        if messageType == "INFO" then
            color = Color3.fromRGB(255, 255, 255)
        elseif messageType == "WARNING" then
            color = Color3.fromRGB(255, 200, 0)
        elseif messageType == "ERROR" then
            color = Color3.fromRGB(255, 50, 50)
        else
            color = Color3.fromRGB(200, 200, 200)
        end
        
        local timestamp = os.date("%X")
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = string.format("[%s] [%s] %s", timestamp, messageType, tostring(message))
        label.TextColor3 = color
        label.Font = Enum.Font.RobotoMono
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextWrapped = true
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.Parent = self.Output
        
        -- Auto-scroll to bottom
        game:GetService("RunService").Heartbeat:Wait()
        self.Output.CanvasPosition = Vector2.new(0, self.Output.CanvasPosition.Y + 1000)
    end
    
    function console:Clear()
        for _, child in ipairs(self.Output:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end
    
    return console
end

-- Global functions
getgenv().ConsolePrint = function(message, messageType)
    if not _G.CustomConsole then
        _G.CustomConsole = CustomConsole:Create()
    end
    _G.CustomConsole:Log(message, messageType)
end

getgenv().ConsoleInfo = function(message)
    ConsolePrint(message, "INFO")
end

getgenv().ConsoleWarn = function(message)
    ConsolePrint(message, "WARNING")
end

getgenv().ConsoleError = function(message)
    ConsolePrint(message, "ERROR")
end

return CustomConsole
