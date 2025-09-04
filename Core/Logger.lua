-- Advanced Logging System for TDS Script
local Logger = {}
Logger.__index = Logger

-- Log levels
Logger.Levels = {
    INFO = {Color = Color3.fromRGB(255, 255, 255), Prefix = "INFO"},
    WARNING = {Color = Color3.fromRGB(255, 200, 0), Prefix = "WARN"},
    ERROR = {Color = Color3.fromRGB(255, 50, 50), Prefix = "ERROR"},
    SUCCESS = {Color = Color3.fromRGB(0, 255, 0), Prefix = "SUCCESS"},
    DEBUG = {Color = Color3.fromRGB(100, 100, 255), Prefix = "DEBUG"}
}

function Logger:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TDSLogger"
    screenGui.Parent = game.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "LoggerFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "TDS Script Logger - Match Events"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Controls
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0, 60, 0, 25)
    clearButton.Position = UDim2.new(1, -70, 0, 7.5)
    clearButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    clearButton.BorderSizePixel = 0
    clearButton.Text = "Clear"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.Font = Enum.Font.Gotham
    clearButton.TextSize = 12
    clearButton.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -35, 0, 7.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = header
    
    -- Log content
    local logContent = Instance.new("ScrollingFrame")
    logContent.Name = "LogContent"
    logContent.Size = UDim2.new(1, -10, 1, -50)
    logContent.Position = UDim2.new(0, 5, 0, 45)
    logContent.BackgroundTransparency = 1
    logContent.BorderSizePixel = 0
    logContent.ScrollBarThickness = 5
    logContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logContent.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = logContent
    
    -- Stats bar
    local statsBar = Instance.new("Frame")
    statsBar.Name = "StatsBar"
    statsBar.Size = UDim2.new(1, 0, 0, 25)
    statsBar.Position = UDim2.new(0, 0, 1, -25)
    statsBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    statsBar.BorderSizePixel = 0
    statsBar.Parent = mainFrame
    
    local statsText = Instance.new("TextLabel")
    statsText.Name = "StatsText"
    statsText.Size = UDim2.new(1, -10, 1, 0)
    statsText.Position = UDim2.new(0, 5, 0, 0)
    statsText.BackgroundTransparency = 1
    statsText.Text = "Total Logs: 0 | Last Action: None"
    statsText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 12
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.Parent = statsBar
    
    -- Button corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = clearButton
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeButton
    
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
    
    -- Button functionality
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        for _, child in ipairs(logContent:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        statsText.Text = "Total Logs: 0 | Last Action: Cleared"
    end)
    
    local logger = {
        GUI = screenGui,
        LogContent = logContent,
        StatsText = statsText,
        LogCount = 0,
        LastAction = "None"
    }
    
    setmetatable(logger, self)
    
    function logger:AddLog(message, level, category)
        level = level or "INFO"
        category = category or "General"
        
        local levelConfig = self.Levels[level:upper()] or self.Levels.INFO
        local timestamp = os.date("%H:%M:%S")
        
        local logEntry = Instance.new("TextLabel")
        logEntry.Size = UDim2.new(1, 0, 0, 20)
        logEntry.BackgroundTransparency = 1
        logEntry.Text = string.format("[%s] [%s] [%s] %s", timestamp, levelConfig.Prefix, category, tostring(message))
        logEntry.TextColor3 = levelConfig.Color
        logEntry.Font = Enum.Font.RobotoMono
        logEntry.TextSize = 12
        logEntry.TextXAlignment = Enum.TextXAlignment.Left
        logEntry.TextYAlignment = Enum.TextYAlignment.Top
        logEntry.TextWrapped = true
        logEntry.AutomaticSize = Enum.AutomaticSize.Y
        logEntry.Parent = self.LogContent
        
        self.LogCount += 1
        self.LastAction = message
        self.StatsText.Text = string.format("Total Logs: %d | Last Action: %s", self.LogCount, self.LastAction)
        
        -- Auto-scroll to bottom
        task.wait()
        self.LogContent.CanvasPosition = Vector2.new(0, self.LogContent.AbsoluteCanvasSize.Y)
    end
    
    -- Specific log types for TDS actions
    function logger:TowerPlaced(towerName, position, wave, time)
        self:AddLog(string.format("Placed %s at %s (Wave %d, Time: %s)", towerName, tostring(position), wave, time), "SUCCESS", "Tower")
    end
    
    function logger:TowerUpgraded(towerName, path, level, wave)
        self:AddLog(string.format("Upgraded %s to %s path level %d (Wave %d)", towerName, path, level, wave), "INFO", "Upgrade")
    end
    
    function logger:TowerSold(towerName, wave)
        self:AddLog(string.format("Sold %s (Wave %d)", towerName, wave), "WARNING", "Sell")
    end
    
    function logger:AbilityUsed(towerName, abilityName, wave)
        self:AddLog(string.format("Used %s ability on %s (Wave %d)", abilityName, towerName, wave), "INFO", "Ability")
    end
    
    function logger:WaveSkipped(wave)
        self:AddLog(string.format("Skipped Wave %d", wave), "INFO", "Wave")
    end
    
    function logger:TargetChanged(towerName, target, wave)
        self:AddLog(string.format("Changed %s target to %s (Wave %d)", towerName, target, wave), "INFO", "Target")
    end
    
    function logger:GameEvent(event, details)
        self:AddLog(string.format("%s: %s", event, details), "INFO", "Game")
    end
    
    function logger:ErrorOccurred(errorMsg, context)
        self:AddLog(string.format("Error in %s: %s", context, errorMsg), "ERROR", "Error")
    end
    
    function logger:MatchStarted(map, mode, difficulty)
        self:AddLog(string.format("Match started - Map: %s, Mode: %s, Difficulty: %s", map, mode, difficulty), "SUCCESS", "Match")
    end
    
    function logger:MatchEnded(result, wavesCompleted, time)
        self:AddLog(string.format("Match %s - Waves: %d, Time: %s", result, wavesCompleted, time), "INFO", "Match")
    end
    
    return logger
end

-- Global functions
getgenv().CreateLogger = function()
    if not _G.TDSLogger then
        _G.TDSLogger = Logger:Create()
    end
    return _G.TDSLogger
end

getgenv().LogInfo = function(message, category)
    if _G.TDSLogger then
        _G.TDSLogger:AddLog(message, "INFO", category)
    end
end

getgenv().LogWarning = function(message, category)
    if _G.TDSLogger then
        _G.TDSLogger:AddLog(message, "WARNING", category)
    end
end

getgenv().LogError = function(message, category)
    if _G.TDSLogger then
        _G.TDSLogger:AddLog(message, "ERROR", category)
    end
end

getgenv().LogSuccess = function(message, category)
    if _G.TDSLogger then
        _G.TDSLogger:AddLog(message, "SUCCESS", category)
    end
end

return Logger
