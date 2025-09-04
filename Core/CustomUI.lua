getgenv().CustomUI = loadCustomUI()

if CustomUI then
    -- Create the main window
    local mainWindow = CustomUI:CreateWindow("Strategies X")
    
    -- Add tabs or sections
    mainWindow:Section("Main Controls")
    mainWindow:Button("Start Script", function()
        print("Script started!")
    end)
    
    mainWindow:Button("Stop Script", function()
        print("Script stopped!")
    end)
    
    mainWindow:Section("Settings")
    mainWindow:Toggle("Auto Farm", false, function(state)
        print("Auto Farm:", state)
    end)
    
    mainWindow:Toggle("Auto Upgrade", true, function(state)
        print("Auto Upgrade:", state)
    end)
end
