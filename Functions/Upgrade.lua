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

local function ConsoleError(message)
    if _G.CustomConsole then
        _G.CustomConsole:Log(message, "ERROR")
    else
        warn("[ERROR]", message)
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
    local Path = tableinfo["PathTarget"]
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false 
    
    if not CheckPlace() then
        return
    end
    
    local CurrentCount = _G.StratXLibrary.CurrentCount
    SetActionInfo("Upgrade","Total")
    
    task.spawn(function()
        local TimerCheck = TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"])
        if not TimerCheck then
            return
        end
        
        local UpgradeCheck, SkipCheck
        task.delay(50, function()
            SkipCheck = true
        end)
        
        repeat
            if not TowersCheckHandler(Tower) then
                return
            end
            
            UpgradeCheck = RemoteFunction:InvokeServer("Troops","Upgrade","Set",{
                ["Troop"] = workspace:FindFirstChild("Tower_" .. Tower) or Instance.new("Part"),
                ["Path"] = Path
            })
            task.wait()
        until UpgradeCheck or SkipCheck
        
        local TowerType = GetTypeIndex(tableinfo["TypeIndex"],Tower)
        
        if CurrentCount ~= _G.StratXLibrary.RestartCount then
            return
        end
        
        if SkipCheck and not UpgradeCheck then
            ConsoleError("Failed To Upgrade Tower Index: "..Tower..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..")")
            return
        end
        
        SetActionInfo("Upgrade")
        ConsoleInfo("Upgraded Tower Index: "..Tower..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..")")
    end)
end
