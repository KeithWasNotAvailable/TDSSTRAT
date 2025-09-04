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

-- Load all custom modules (no external dependencies)
local ConvertFunc = loadModule("ConvertFunc.lua")
local FreeCam = loadModule("FreeCam.lua")
local JoinLessServer = loadModule("JoinLessServer.lua")
local LowGraphics = loadModule("LowGraphics.lua")
local CustomUI = loadModule("CustomUI.lua")
local CustomConsole = loadModule("CustomConsole.lua")
local Webhook = loadModule("Webhook.lua")
local Tutorial = loadModule("Tutorial.lua")

-- Initialize custom console
_G.CustomConsole = CustomConsole:Create()
ConsoleInfo("TDS Script loaded successfully!")

-- Create main UI
local mainWindow = CustomUI:CreateWindow("TDS Script")
mainWindow:Section("Main Features")
mainWindow:Button("Start Script", function()
    ConsoleInfo("Script started!")
end)

mainWindow:Button("Load Strat", function()
    ConsoleInfo("Strat loaded!")
end)

mainWindow:Toggle("Auto Farm", false, function(state)
    ConsoleInfo("Auto Farm: " .. tostring(state))
end)

mainWindow:Section("Utilities")
mainWindow:Toggle("Auto Skip", true, function(state)
    ConsoleInfo("Auto Skip: " .. tostring(state))
end)

mainWindow:Toggle("Low Graphics", false, function(state)
    ConsoleInfo("Low Graphics: " .. tostring(state))
    if LowGraphics then
        LowGraphics(state)
    end
end)

mainWindow:Dropdown("Camera Mode", {"Normal", "Follow", "Free"}, function(option)
    ConsoleInfo("Camera mode: " .. option)
end)

-- Initialize the script
ConsoleInfo("TDS Script initialization complete!")
