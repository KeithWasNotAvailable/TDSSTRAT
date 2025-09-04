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
        if not isfolder("StrategiesX/Recordings") then
            makefolder("StrategiesX/Recordings")
        end
        if not isfolder("TDS-Scripts") then
            makefolder("TDS-Scripts")
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

-- Load your existing CustomUI and Logger
local function loadCustomUI()
    local success, err = pcall(function()
        if isfile("CustomUI.lua") then
            local customUIModule = loadfile("CustomUI.lua")()
            return customUIModule.new() -- Create a new instance
        else
            error("CustomUI.lua not found")
        end
    end)
    
    if not success then
        warn("Failed to load CustomUI: " .. tostring(err))
        return nil
    end
    return success
end

local function loadLogger()
    local success, err = pcall(function()
        if isfile("Logger.lua") then
            return loadfile("Logger.lua")()
        else
            error("Logger.lua not found")
        end
    end)
    
    if not success then
        warn("Failed to load Logger: " .. tostring(err))
        return nil
    end
    return success
end

-- Load Recorder
local function loadRecorder()
    local success, err = pcall(function()
        if isfile("Recorder.lua") then
            local recorderModule = loadfile("Recorder.lua")()
            return recorderModule.new() -- Create a new instance
        else
            error("Recorder.lua not found")
        end
    end)
    
    if not success then
        warn("Failed to load Recorder: " .. tostring(err))
        return nil
    end
    return success
end

-- Initialize your existing systems
getgenv().CustomUI = loadCustomUI()
getgenv().Logger = loadLogger()
getgenv().Recorder = loadRecorder()

if not CustomUI then
    -- Fallback basic UI if CustomUI fails to load
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StrategiesXUIFallback"
    screenGui.Parent = game:GetService("CoreGui")
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 50)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = "Strategies X Loaded\n(CustomUI failed to load)"
    textLabel.TextWrapped = true
    textLabel.Parent = screenGui
end

if not Logger then
    -- Fallback if Logger fails to load
    getgenv().Logger = {
        Info = function(...) print("[INFO]", ...) end,
        Warn = function(...) warn("[WARN]", ...) end,
        Error = function(...) warn("[ERROR]", ...) end
    }
end

-- Create UI with recorder functionality
local function createRecorderUI()
    if not CustomUI then return end
    
    local mainWindow = CustomUI:CreateWindow("Strategies X")
    
    -- Main tab
    mainWindow:Section("Strategies X")
    mainWindow:Label("Version: 1.0.0")
    
    local placeId = game.PlaceId
    local placeName = placeId == 3260590327 and "Lobby" or (placeId == 5591597781 and "Ingame" or "Unknown")
    mainWindow:Label("Place: " .. placeName)
    
    mainWindow:Section("Loadout Status")
    mainWindow:Label("Troop 1: Empty")
    mainWindow:Label("Troop 2: Empty")
    mainWindow:Label("Troop 3: Empty")
    mainWindow:Label("Troop 4: Empty")
    mainWindow:Label("Troop 5: Empty")
    
    -- Recorder tab
    mainWindow:Section("Recorder")
    if Recorder then
        mainWindow:Button("Start Recording", function()
            if Recorder.StartRecording then
                Recorder:StartRecording()
                mainWindow:Label("Status: Recording...")
            else
                warn("Recorder.StartRecording function not found")
            end
        end)
        
        mainWindow:Button("Stop Recording", function()
            if Recorder.StopRecording then
                Recorder:StopRecording()
                mainWindow:Label("Status: Stopped")
            else
                warn("Recorder.StopRecording function not found")
            end
        end)
        
        mainWindow:Label("Status: Ready")
    else
        mainWindow:Label("Recorder not available")
    end
    
    -- Settings tab
    mainWindow:Section("Settings")
    mainWindow:Toggle("Auto Farm", false, function(state)
        Logger.Info("Auto Farm: " .. tostring(state))
    end)
    
    mainWindow:Toggle("Auto Upgrade", true, function(state)
        Logger.Info("Auto Upgrade: " .. tostring(state))
    end)
    
    mainWindow:Toggle("Low Graphics Mode", false, function(state)
        Logger.Info("Low Graphics Mode: " .. tostring(state))
    end)
    
    mainWindow:Button("Save Settings", function()
        Logger.Info("Settings saved")
    end)
end

-- Main initialization
local function initializeMainSystem()
    Logger.Info("Initializing Strategies X...")
    
    -- Check if we're in the right game
    local validPlaceIds = {3260590327, 5591597781} -- TDS place IDs
    local isValidPlace = false
    for _, id in ipairs(validPlaceIds) do
        if game.PlaceId == id then
            isValidPlace = true
            break
        end
    end
    
    if not isValidPlace then
        Logger.Warn("Not in Tower Defense Simulator. Script may not work properly.")
        return
    end
    
    -- Load configuration if exists
    local config = {}
    if hasFileFunctions and isfile("StrategiesX/UserConfig/config.json") then
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("StrategiesX/UserConfig/config.json"))
        end)
        if success then
            config = result
            Logger.Info("Loaded user configuration")
        end
    end
    
    -- Create the UI
    createRecorderUI()
    
    -- Set up event handlers and main functionality
    Logger.Info("Setting up event handlers...")
    
    -- Placeholder for your main game logic
    -- You would implement your TDS automation here
    
    Logger.Info("Strategies X initialized successfully!")
end

-- Start the main system
local success, err = pcall(initializeMainSystem)
if not success then
    Logger.Error("Failed to initialize main system: " .. tostring(err))
end

getgenv().StrategiesXLoader = true
Logger.Info("Strategies X Loader Loaded")
