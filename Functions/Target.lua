local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function createSpoofEvent()
    return {
        InvokeServer = function(self, ...)
            print("InvokeServer", ...)
            return true
        end
    }
end

local RemoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction") or createSpoofEvent()

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

local function TimeWaveWait(wave, min, sec, inWave, debug)
    if debug then return true end
    task.wait(1)
    return true
end

local function TowersCheckHandler(...)
    return true
end

local function GetTypeIndex(typeIndex, id)
    return typeIndex or "DefaultType"
end

return function(self, p1)
    local tableinfo = p1
    local Tower = tableinfo["TowerIndex"]
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false 
    local Target = tableinfo["Target"]
    
    if not CheckPlace() then
        return
    end
    
    SetActionInfo("Target","Total")
    
    task.spawn(function()
        if not TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"]) then
            return
        end
        
        if not TowersCheckHandler(Tower) then
            return
        end
        
        RemoteFunction:InvokeServer("Troops","Target","Set",{
            ["Troop"] = workspace:FindFirstChild("Tower_" .. Tower) or Instance.new("Part"),
            ["Target"] = Target,
        })
        
        local TowerType = GetTypeIndex(tableinfo["TypeIndex"],Tower)
        SetActionInfo("Target")
        
        ConsoleInfo("Changed Target To: "..Target..", Tower Index: "..Tower..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..")")
    end)
end
