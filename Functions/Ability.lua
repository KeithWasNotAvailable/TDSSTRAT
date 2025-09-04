local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create a spoof event if needed
local function createSpoofEvent()
    return {
        InvokeServer = function(self, ...)
            print("InvokeServer", ...)
            return true
        end,
        FireServer = function(self, ...)
            print("FireServer", ...)
        end
    }
end

local RemoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction") or createSpoofEvent()
local RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or createSpoofEvent()

-- Helper functions
local function CheckPlace()
    return game.PlaceId == 5591597781
end

local function SetActionInfo(action, type)
    if _G.StratXLibrary and _G.StratXLibrary.ActionInfo[action] then
        if type == "Total" then
            _G.StratXLibrary.ActionInfo[action][2] += 1
        else
            _G.StratXLibrary.ActionInfo[action][1] += 1
        end
    end
end

local function ConsoleInfo(message)
    if _G.CustomConsole then
        _G.CustomConsole:Log(message, "INFO")
    else
        print("[INFO]", message)
    end
end

local function ConsoleWarn(message)
    if _G.CustomConsole then
        _G.CustomConsole:Log(message, "WARNING")
    else
        warn("[WARNING]", message)
    end
end

local function TimeWaveWait(wave, min, sec, inWave, debug)
    -- Simple implementation - would need proper game state checking
    if debug then return true end
    task.wait(1)
    return true
end

local function TowersCheckHandler(...)
    -- Simple implementation
    return true
end

local function GetTypeIndex(typeIndex, id)
    return typeIndex or "DefaultType"
end

return function(self, p1)
    local tableinfo = p1
    local Tower = tableinfo["TowerIndex"]
    local Ability = tableinfo["Ability"]
    local Data = tableinfo["Data"]
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false 
    
    if not CheckPlace() then
        return
    end
    
    SetActionInfo("Ability","Total")
    
    task.spawn(function()
        if not TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"]) then
            return
        end
        
        local AbilityCheck
        local TowerType = GetTypeIndex(tableinfo["TypeIndex"],Tower)
        
        task.spawn(function()
            task.wait(2)
            while not (type(AbilityCheck) == "boolean" and AbilityCheck) do
                ConsoleWarn(`Cannot Ability (Name: {Ability} On Tower Index: {Tower}, Type: \"{TowerType}\", (Wave {Wave}, Min: {Min}, Sec: {Sec}, InBetween: {InWave})`)
                task.wait(1)
            end
        end)
        
        repeat
            if not TowersCheckHandler(Tower) then
                return
            end
            
            AbilityCheck = RemoteFunction:InvokeServer("Troops","Abilities","Activate",{
                ["Troop"] = workspace:FindFirstChild("Tower_" .. Tower) or Instance.new("Part"),
                ["Name"] = Ability,
                ["Data"] = Data,
            })
            task.wait()
        until type(AbilityCheck) == "boolean" and AbilityCheck
        
        SetActionInfo("Ability")
        ConsoleInfo("Used Ability On Tower Index: "..Tower..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..")")
    end)
end
