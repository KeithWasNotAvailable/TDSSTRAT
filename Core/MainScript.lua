-- Main script that loads all custom components
local function loadModule(name)
    local success, result = pcall(function()
        return loadfile(name)()
    end)
    
    if not success then
        warn("Failed to load " .. name .. ": " .. result)
        return nil
    end
    
    return result
end

-- Initialize global variables
getgenv().StratXLibrary = {
    UtilitiesConfig = {
        Camera = 2,
        LowGraphics = false,
        BypassGroup = false,
        AutoBuyMissing = false,
        AutoPickups = false,
        RestartMatch = false,
        TowersPreview = false,
        AutoSkip = false,
        UseTimeScale = false,
        PreferMatchmaking = false,
        Webhook = {
            Enabled = false,
            Link = "",
            HideUser = false,
            UseNewFormat = false,
            PlayerInfo = true,
            GameInfo = true,
            TroopsInfo = true,
            DisableCustomLog = true,
        },
    },
    TowerInfo = {},
    TowersContained = {Index = 0},
    ActionInfo = {
        ["Place"] = {0,0},
        ["Upgrade"] = {0,0},
        ["Sell"] = {0,0},
        ["Skip"] = {0,0},
        ["Ability"] = {0,0},
        ["Target"] = {0,0},
        ["AutoChain"] = {0,0},
        ["SellAllFarms"] = {0,0},
        ["Option"] = {0,0},
    },
    RestartCount = 0,
    CurrentCount = 0,
    Global = {Map = {}},
    UI = {},
    Functions = {}
}

-- Load all custom modules
local ConvertFunc = loadModule("ConvertFunc.lua")
local CustomUI = loadModule("CustomUI.lua")
local CustomConsole = loadModule("CustomConsole.lua")
local Logger = loadModule("Logger.lua")

-- Load function modules
getgenv().Functions = {}
Functions.Ability = loadModule("Functions/Ability.lua")
Functions.AutoChain = loadModule("Functions/AutoChain.lua")
Functions.Loadout = loadModule("Functions/Loadout.lua")
Functions.Map = loadModule("Functions/Map.lua")
Functions.Mode = loadModule("Functions/Mode.lua")
Functions.Option = loadModule("Functions/Option.lua")
Functions.Place = loadModule("Functions/Place.lua")
Functions.Sell = loadModule("Functions/Sell.lua")
Functions.SellAllFarms = loadModule("Functions/SellAllFarms.lua")
Functions.Skip = loadModule("Functions/Skip.lua")
Functions.Target = loadModule("Functions/Target.lua")
Functions.Upgrade = loadModule("Functions/Upgrade.lua")

-- Load feature modules
local FreeCam = loadModule("Features/FreeCam.lua")
local JoinLessServer = loadModule("Features/JoinLessServer.lua")
local LowGraphics = loadModule("Features/LowGraphics.lua")
local Webhook = loadModule("Features/Webhook.lua")
local Tutorial = loadModule("Features/Tutorial.lua")

-- Initialize logging system
_G.TDSLogger = Logger:Create()
LogInfo("TDS Script loaded successfully!", "System")

-- Create main UI
local mainWindow = CustomUI:CreateWindow("TDS Script")
mainWindow:Section("Main Features")
mainWindow:Button("Start Script", function()
    LogInfo("Script started!", "System")
end)

mainWindow:Button("Load Strat", function()
    LogInfo("Strat loaded!", "System")
end)

mainWindow:Toggle("Auto Farm", false, function(state)
    LogInfo("Auto Farm: " .. tostring(state), "Settings")
end)

mainWindow:Section("Utilities")
mainWindow:Toggle("Auto Skip", true, function(state)
    LogInfo("Auto Skip: " .. tostring(state), "Settings")
end)

mainWindow:Toggle("Low Graphics", false, function(state)
    LogInfo("Low Graphics: " .. tostring(state), "Settings")
    if LowGraphics then
        LowGraphics(state)
    end
end)

mainWindow:Dropdown("Camera Mode", {"Normal", "Follow", "Free"}, function(option)
    LogInfo("Camera mode: " .. option, "Settings")
end)

-- Add logger controls to UI
mainWindow:Section("Logging")
mainWindow:Button("Show Logs", function()
    if _G.TDSLogger and _G.TDSLogger.GUI then
        _G.TDSLogger.GUI.Enabled = true
        LogInfo("Logger window shown", "System")
    else
        _G.TDSLogger = Logger:Create()
        LogInfo("Logger initialized and shown", "System")
    end
end)

mainWindow:Button("Hide Logs", function()
    if _G.TDSLogger and _G.TDSLogger.GUI then
        _G.TDSLogger.GUI.Enabled = false
        LogInfo("Logger window hidden", "System")
    end
end)

mainWindow:Button("Clear Logs", function()
    if _G.TDSLogger then
        for _, child in ipairs(_G.TDSLogger.LogContent:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        _G.TDSLogger.LogCount = 0
        _G.TDSLogger.StatsText.Text = "Total Logs: 0 | Last Action: Cleared"
        LogInfo("Logs cleared", "System")
    end
end)

-- Initialize the script
LogInfo("TDS Script initialization complete!", "System")

-- Example of how to use the logger in functions
LogInfo("All modules loaded successfully", "System")
LogSuccess("Ready to start Tower Defense Simulator", "System")
