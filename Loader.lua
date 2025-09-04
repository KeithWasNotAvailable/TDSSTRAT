-- TDS Script Loader - Main Entry Point
if game.PlaceId ~= 3260590327 and game.PlaceId ~= 5591597781 then 
    return 
end

if getgenv().StrategiesXLoader then
    return
end

getgenv().ExecDis = true

-- Store settings in a persistent global table
if not getgenv().TDSConfig then
    getgenv().TDSConfig = {
        Record = false,
        Replay = false,
        Webhook = ""
    }
end

-- Apply any pre-set values
if getgenv().Record ~= nil then
    getgenv().TDSConfig.Record = getgenv().Record
end
if getgenv().Replay ~= nil then
    getgenv().TDSConfig.Replay = getgenv().Replay
end
if getgenv().Webhook ~= nil then
    getgenv().TDSConfig.Webhook = getgenv().Webhook
end

if getgenv().Config then
    return
end

local OldTime = os.clock()

-- Create necessary folders
if not isfolder("TDS-Scripts") then
    makefolder("TDS-Scripts")
    makefolder("TDS-Scripts/UserLogs")
    makefolder("TDS-Scripts/UserConfig")
elseif not isfolder("TDS-Scripts/UserLogs") then
    makefolder("TDS-Scripts/UserLogs")
elseif not isfolder("TDS-Scripts/UserConfig") then
    makefolder("TDS-Scripts/UserConfig")
end

-- File utility functions
getgenv().WriteFile = function(check, name, location, str)
    if not check then
        return
    end
    if type(name) == "string" then
        if not type(location) == "string" then
            location = ""
        end
        if not isfolder(location) then
            makefolder(location)
        end
        if type(str) ~= "string" then
            error("Argument 4 must be a string, got " .. type(str))
        end
        writefile(location.."/"..name..".txt", str)
    else
        error("Argument 2 must be a string, got " .. type(name))
    end
end

getgenv().AppendFile = function(check, name, location, str)
    if not check then
        return
    end
    if type(name) == "string" then
        if not type(location) == "string" then
            location = ""
        end
        if not isfolder(location) then
            WriteFile(check, name, location, str)
        end
        if type(str) ~= "string" then
            error("Argument 4 must be a string, got " .. type(str))
        end
        if isfile(location.."/"..name..".txt") then
            appendfile(location.."/"..name..".txt", str)
        else
            WriteFile(check, name, location, str)
        end
    else
        error("Argument 2 must be a string, got " .. type(name))
    end
end

-- Logging functions
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
        return WriteFile(true, game:GetService("Players").LocalPlayer.Name.."'s log", "TDS-Scripts/UserLogs", Text)
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
        return AppendFile(true, game:GetService("Players").LocalPlayer.Name.."'s log", "TDS-Scripts/UserLogs", Text.."\n")
    end
end

-- List of external URLs to block/redirect
local BlockedURLs = {
    "https://raw.githubusercontent.com/banbuskox/dfhtyxvzexrxgfdzgzfdvfdz/main/ckmhjvskfkmsStratFun2",
    "https://raw.githubusercontent.com/wxzex/mmsautostratcontinuation/main/autostratscode.txt",
    "https://raw.githubusercontent.com/banbuskox/dfhtyxvzexrxgfdzgzfdvfdz/main/asjhxnjfdStratFunJoin"
}

-- Hook metamethod to block external requests
local OldNamecall
OldNamecall = hookmetamethod(game, '__namecall', function(...)
    local Self, Args = (...), ({select(2, ...)})
    
    if getnamecallmethod() == 'HttpGet' then
        if table.find(BlockedURLs, Args[1]) then
            -- Block these requests completely
            appendlog("BLOCKED external request to: " .. Args[1])
            return "" -- Return empty string instead of making the request
        end
    elseif getnamecallmethod() == 'Kick' then
        -- Prevent kicking
        appendlog("Kick attempt blocked")
        return nil
    end
    
    return OldNamecall(..., unpack(Args))
end)

-- Hook function to block external requests
local OldHook
OldHook = hookfunction(game.HttpGet, function(Self, Url, ...)
    if table.find(BlockedURLs, Url) then
        appendlog("BLOCKED external request to: " .. Url)
        return "" -- Return empty string
    end
    
    return OldHook(Self, Url, ...)
end)

-- Initialize loader
getgenv().StrategiesXLoader = true

-- Write initial log
writelog("--------------------------- TDS Script Loader ---------------------------",
    "\nLoader initialized at: " .. os.date("%X %x"),
    "\nPlayer: " .. game:GetService("Players").LocalPlayer.Name,
    "\nPlace: " .. game.PlaceId,
    "\nExecutor: " .. (identifyexecutor and identifyexecutor() or "Unknown"),
    "\nSettings: Record=" .. tostring(getgenv().TDSConfig.Record) .. 
    ", Replay=" .. tostring(getgenv().TDSConfig.Replay) .. 
    ", Webhook=" .. tostring(getgenv().TDSConfig.Webhook ~= ""),
    "\nBlocked URLs: " .. #BlockedURLs,
    "\n-----------------------------------------------------------------------------"
)

appendlog("TDS Script Loader initialized in " .. string.format("%.3f", os.clock() - OldTime) .. " seconds")

-- Load main script
appendlog("Loading main script...")

-- Set webhook if provided
if getgenv().TDSConfig.Webhook and getgenv().TDSConfig.Webhook ~= "" then
    appendlog("Webhook URL configured: " .. getgenv().TDSConfig.Webhook)
end

-- Load the main script
local mainScript = loadfile("TDS-Scripts/Core/MainScript.lua")
if mainScript then
    mainScript()
    
    -- Auto-start recording if enabled
    if getgenv().TDSConfig.Record then
        appendlog("Auto-record enabled - starting recording...")
        task.wait(2) -- Wait for everything to load
        
        if _G.Recorder then
            _G.Recorder:StartRecording()
            appendlog("Auto-recording started")
        else
            appendlog("ERROR: Recorder not found for auto-record")
        end
    end
    
    -- Auto-replay if enabled
    if getgenv().TDSConfig.Replay then
        appendlog("Auto-replay enabled - checking for recorded strat...")
        task.wait(2)
        
        if isfile("TDS-Scripts/RecordedStrat.lua") then
            appendlog("Found recorded strat - executing...")
            local success, err = pcall(function()
                loadfile("TDS-Scripts/RecordedStrat.lua")()
            end)
            if success then
                appendlog("Recorded strat executed successfully")
            else
                appendlog("ERROR executing recorded strat: " .. tostring(err))
            end
        else
            appendlog("No recorded strat found for auto-replay")
        end
    end
    
else
    appendlog("ERROR: Failed to load MainScript.lua")
    appendlog("Error: " .. tostring(mainScript))
end
