-- Loader.lua - Main entry point for Strategies X
if getgenv().StrategiesXLoader then
    return
end

getgenv().ExecDis = true

-- Check if required functions are available
local hasFileFunctions = readfile and writefile and isfile
if not hasFileFunctions then
    warn("Exploit is missing file functions. Some features may not work properly.")
end

-- Create necessary folders (with error handling)
local function createFolders()
    if not hasFileFunctions then return end
    
    local success, err = pcall(function()
        if not isfolder("StrategiesX") then
            makefolder("StrategiesX")
        end
        if not isfolder("StrategiesX/UserLogs") then
            makefolder("StrategiesX/UserLogs")
        end
        if not isfolder("StrategiesX/UserConfig") then
            makefolder("StrategiesX/UserConfig")
        end
    end)
    
    if not success then
        warn("Failed to create folders: " .. tostring(err))
    end
end

createFolders()

-- Utility functions
getgenv().WriteFile = function(check, name, location, str)
    if not check or not hasFileFunctions then return end
    if type(name) ~= "string" then error("Argument 2 must be a string") end
    if not type(location) == "string" then location = "" end
    if not isfolder(location) then pcall(makefolder, location) end
    if type(str) ~= "string" then error("Argument 4 must be a string") end
    
    pcall(writefile, location.."/"..name..".txt", str)
end

getgenv().AppendFile = function(check, name, location, str)
    if not check or not hasFileFunctions then return end
    if type(name) ~= "string" then error("Argument 2 must be a string") end
    if not type(location) == "string" then location = "" end
    if not isfolder(location) then pcall(makefolder, location) end
    if type(str) ~= "string" then error("Argument 4 must be a string") end
    
    if pcall(isfile, location.."/"..name..".txt") then
        pcall(appendfile, location.."/"..name..".txt", str)
    else
        pcall(writefile, location.."/"..name..".txt", str)
    end
end

local writelog = function(...)
    local TableText = {...}
    task.spawn(function()
        if not game:GetService("Players").LocalPlayer then
            repeat task.wait() until game:GetService("Players").LocalPlayer
        end
        for i,v in next, TableText do
            if type(v) ~= "string" then
                TableText[i] = tostring(v)
            end
        end
        local Text = table.concat(TableText, " ")
        print(Text)
        return WriteFile(true, game:GetService("Players").LocalPlayer.Name.."'s log", "StrategiesX/UserLogs", tostring(Text))
    end)
end

local appendlog = function(...)
    local TableText = {...}
    task.spawn(function()
        if not game:GetService("Players").LocalPlayer then
            repeat task.wait() until game:GetService("Players").LocalPlayer
        end
        for i,v in next, TableText do
            if type(v) ~= "string" then
                TableText[i] = tostring(v)
            end
        end
        local Text = table.concat(TableText, " ")
        print(Text)
        return AppendFile(true, game:GetService("Players").LocalPlayer.Name.."'s log", "StrategiesX/UserLogs", tostring(Text).."\n")
    end)
end

-- Custom UI Library (replacement for Sigmanic's UI)
local function createCustomUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StrategiesXUI"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.BorderSizePixel = 0
    title.Text = "Strategies X"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = title
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local tabButtons = Instance.new("Frame")
    tabButtons.Name = "TabButtons"
    tabButtons.Size = UDim2.new(1, 0, 0, 40)
    tabButtons.Position = UDim2.new(0, 0, 0, 40)
    tabButtons.BackgroundTransparency = 1
    tabButtons.Parent = mainFrame
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 5
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = contentFrame
    
    local tabs = {}
    local currentTab = nil
    
    local function createTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "TabButton"
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Position = UDim2.new(0, (#tabs * 100), 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        tabButton.BorderSizePixel = 0
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabButtons
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "TabContent"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        local tabListLayout = Instance.new("UIListLayout")
        tabListLayout.Padding = UDim.new(0, 10)
        tabListLayout.Parent = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Visible = false
                for _, btn in pairs(tabButtons:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    end
                end
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            currentTab = tabContent
        end)
        
        tabs[name] = tabContent
        
        if #tabs == 1 then
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            tabContent.Visible = true
            currentTab = tabContent
        end
        
        return tabContent
    end
    
    local function createSection(parent, titleText)
        local section = Instance.new("Frame")
        section.Name = "Section"
        section.Size = UDim2.new(1, 0, 0, 0)
        section.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        section.BorderSizePixel = 0
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.Parent = parent
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 6)
        sectionCorner.Parent = section
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "SectionTitle"
        sectionTitle.Size = UDim2.new(1, -20, 0, 30)
        sectionTitle.Position = UDim2.new(0, 10, 0, 5)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = titleText
        sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        sectionTitle.TextSize = 16
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = section
        
        local sectionContent = Instance.new("Frame")
        sectionContent.Name = "SectionContent"
        sectionContent.Size = UDim2.new(1, -20, 0, 0)
        sectionContent.Position = UDim2.new(0, 10, 0, 35)
        sectionContent.BackgroundTransparency = 1
        sectionContent.AutomaticSize = Enum.AutomaticSize.Y
        sectionContent.Parent = section
        
        local sectionListLayout = Instance.new("UIListLayout")
        sectionListLayout.Padding = UDim.new(0, 8)
        sectionListLayout.Parent = sectionContent
        
        return sectionContent
    end
    
    local function createButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.Parent = parent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    local function createToggle(parent, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = text .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 30)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        toggleLabel.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.TextSize = 14
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 50, 0, 25)
        toggleButton.Position = UDim2.new(1, -50, 0.5, -12.5)
        toggleButton.BackgroundColor3 = default and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(80, 80, 100)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = default and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 12
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 12)
        toggleCorner.Parent = toggleButton
        
        toggleButton.MouseButton1Click:Connect(function()
            local newState = not (toggleButton.Text == "ON")
            toggleButton.BackgroundColor3 = newState and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(80, 80, 100)
            toggleButton.Text = newState and "ON" or "OFF"
            if callback then callback(newState) end
        end)
        
        return toggleFrame
    end
    
    local function createLabel(parent, text)
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        
        return label
    end
    
    -- Create tabs
    local mainTab = createTab("Main")
    local utilitiesTab = createTab("Utilities")
    local settingsTab = createTab("Settings")
    
    -- Main tab content
    local mainSection = createSection(mainTab, "Strategies X")
    createLabel(mainSection, "Version: 1.0.0")
    createLabel(mainSection, "Place: " .. (game.PlaceId == 5591597781 and "Ingame" or "Lobby"))
    
    local loadoutSection = createSection(mainTab, "Loadout Status")
    createLabel(loadoutSection, "Troop 1: Empty")
    createLabel(loadoutSection, "Troop 2: Empty")
    createLabel(loadoutSection, "Troop 3: Empty")
    createLabel(loadoutSection, "Troop 4: Empty")
    createLabel(loadoutSection, "Troop 5: Empty")
    
    -- Utilities tab content
    local gameSection = createSection(utilitiesTab, "Game Settings")
    createToggle(gameSection, "Rejoin Lobby After Match", true, function(state) end)
    createToggle(gameSection, "Show Towers Preview", false, function(state) end)
    createButton(gameSection, "Teleport Back To Platform", function() end)
    createToggle(gameSection, "Use Timescale", false, function(state) end)
    
    local cameraSection = createSection(utilitiesTab, "Camera Settings")
    createButton(cameraSection, "Normal Camera", function() end)
    createButton(cameraSection, "Follow Enemies", function() end)
    createButton(cameraSection, "Free Camera", function() end)
    
    -- Settings tab content
    local webhookSection = createSection(settingsTab, "Webhook Settings")
    createToggle(webhookSection, "Enabled", false, function(state) end)
    createToggle(webhookSection, "Apply New Format", false, function(state) end)
    createLabel(webhookSection, "Webhook Link:")
    createToggle(webhookSection, "Hide Username", false, function(state) end)
    
    local universalSection = createSection(settingsTab, "Universal Settings")
    createToggle(universalSection, "Prefer Matchmaking", false, function(state) end)
    createToggle(universalSection, "Auto Skip Wave", false, function(state) end)
    createToggle(universalSection, "Low Graphics Mode", false, function(state) end)
    createToggle(universalSection, "Bypass Group Checking", false, function(state) end)
    createToggle(universalSection, "Auto Buy Missing Tower", false, function(state) end)
    createToggle(universalSection, "Auto Restart When Lose", false, function(state) end)
    createButton(universalSection, "Rejoin To Lobby", function() end)
    
    -- Make the UI draggable
    local dragging = false
    local dragInput, dragStart, startPos

    title.InputBegan:Connect(function(input)
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

    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return {
        MainTab = mainTab,
        UtilitiesTab = utilitiesTab,
        SettingsTab = settingsTab,
        CreateSection = createSection,
        CreateButton = createButton,
        CreateToggle = createToggle,
        CreateLabel = createLabel
    }
end

-- Initialize the UI
getgenv().CustomUI = createCustomUI()

getgenv().StrategiesXLoader = true

-- Load the main script
local success, err = pcall(function()
    -- This would load your main script, but since Sigmanic's is gone
    -- you'll need to replace this with your own implementation
    appendlog("Loading main script...")
    
    -- Placeholder for your main script loading logic
    -- You'll need to implement this based on your needs
end)

if not success then
    warn("Failed to load main script: " .. tostring(err))
end

appendlog("Strategies X Loader Loaded")
