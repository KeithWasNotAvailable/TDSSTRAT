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

-- Initialize global variables with proper config reading
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
            Enabled = (getgenv().TDSConfig and getgenv().TDSConfig.Webhook and getgenv().TDSConfig.Webhook ~= "") or false,
            Link = (getgenv().TDSConfig and getgenv().TDSConfig.Webhook) or "",
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
local Recorder = loadModule("Features/Recorder.lua")

-- Initialize logging system
_G.TDSLogger = Logger:Create()

-- Initialize Recorder
_G.Recorder = Recorder:Create()

-- Create main UI (simplified)
local mainWindow = CustomUI:CreateWindow("TDS Script")
mainWindow:Section("Main Features")
mainWindow:Button("Start Script", function()
    if _G.TDSLogger then
        _G.TDSLogger:AddLog("Script started!", "INFO", "System")
    end
end)

mainWindow:Button("Load Strat", function()
    if _G.TDSLogger then
        _G.TDSLogger:AddLog("Strat loaded!", "INFO", "System")
    end
end)

mainWindow:Section("Utilities")
mainWindow:Toggle("Auto Skip", true, function(state)
    if _G.TDSLogger then
        _G.TDSLogger:AddLog("Auto Skip: " .. tostring(state), "INFO", "Settings")
    end
end)

-- Log settings that were loaded
if _G.TDSLogger then
    _G.TDSLogger:AddLog("TDS Script loaded successfully!", "SUCCESS", "System")
    _G.TDSLogger:AddLog("Recorder system initialized", "INFO", "System")
    _G.TDSLogger:AddLog("Settings - Record: " .. tostring(getgenv().TDSConfig and getgenv().TDSConfig.Record or false) .. 
                       ", Replay: " .. tostring(getgenv().TDSConfig and getgenv().TDSConfig.Replay or false) .. 
                       ", Webhook: " .. tostring(getgenv().TDSConfig and getgenv().TDSConfig.Webhook and getgenv().TDSConfig.Webhook ~= ""), "INFO", "System")
    _G.TDSLogger:AddLog("All modules loaded successfully - Ready to play!", "SUCCESS", "System")
end

-- Auto-start recording if enabled in config
task.spawn(function()
    if getgenv().TDSConfig and getgenv().TDSConfig.Record then
        task.wait(3) -- Wait for game to load
        if _G.Recorder then
            _G.Recorder:StartRecording()
            if _G.TDSLogger then
                _G.TDSLogger:AddLog("Auto-recording started", "INFO", "Recorder")
            end
        end
    end
end)
