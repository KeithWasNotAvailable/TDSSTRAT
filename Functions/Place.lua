local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function createSpoofEvent()
    return {
        InvokeServer = function(self, ...)
            print("InvokeServer", ...)
            return workspace:FindFirstChild("Tower_1") or Instance.new("Part")
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

local function StackPosition(Position, SkipCheck)
    return Vector3.new(0, 0, 0)
end

local function DebugTower(Object, Color)
    return {Enabled = true}
end

return function(self, p1)
    local tableinfo = p1
    local Tower = tableinfo["TowerName"]
    local Position = tableinfo["Position"] or Vector3.new(0,0,0)
    local Rotation = tableinfo["Rotation"] or CFrame.new(0,0,0)
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false
    
    if not CheckPlace() then
        return
    end
    
    SetActionInfo("Place","Total")
    _G.StratXLibrary.TowersContained.Index += 1
    local TempNum = _G.StratXLibrary.TowersContained.Index
    
    _G.StratXLibrary.TowersContained[TempNum] = {
        ["TowerName"] = Tower,
        ["Placed"] = false,
        ["TypeIndex"] = "Nil",
        ["Position"] = Position + StackPosition(Position),
        ["Rotation"] = Rotation,
        ["OldPosition"] = Position,
        ["PassedTimer"] = false,
    }

    local CurrentCount = _G.StratXLibrary.CurrentCount
    local TowerTable = _G.StratXLibrary.TowersContained[TempNum]
    
    task.spawn(function()
        if not TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"]) then
            return
        end
        
        TowerTable.PassedTimer = true
        local PlaceCheck
        
        task.delay(45, function()
            if type(PlaceCheck) ~= "Instance" then
                if (type(PlaceCheck) == "string" and PlaceCheck == "Game is over!") or CurrentCount ~= _G.StratXLibrary.RestartCount then
                    return
                end
                ConsoleError("Tower Index: "..TempNum..", Type: \""..Tower.."\" Hasn't Been Placed In The Last 45 Seconds.")
            end
        end)
        
        repeat
            if CurrentCount ~= _G.StratXLibrary.RestartCount then
                return
            end
            
            PlaceCheck = RemoteFunction:InvokeServer("Troops","Place",Tower,{
                ["Position"] = TowerTable.Position,
                ["Rotation"] = TowerTable.Rotation
            })
            task.wait()
        until type(PlaceCheck) == "Instance"
        
        PlaceCheck.Name = TempNum
        local TowerInfo = _G.StratXLibrary.TowerInfo[Tower] or {[2] = 0}
        TowerInfo[2] += 1
        PlaceCheck:SetAttribute("TypeIndex", Tower.." "..tostring(TowerInfo[2]))
        
        TowerTable.Instance = PlaceCheck
        TowerTable.TypeIndex = PlaceCheck:GetAttribute("TypeIndex")
        TowerTable.Placed = true
        TowerTable.Target = "First"
        TowerTable.Upgrade = 0
        
        local TowerType = "DefaultType"
        SetActionInfo("Place")
        local StackingCheck = (TowerTable.Position - TowerTable.OldPosition).magnitude > 1
        
        ConsoleInfo(`Placed {Tower} Index: {PlaceCheck.Name}, Type: \"{TowerType}\", (Wave {Wave}, Min: {Min}, Sec: {Sec}, InBetween: {InWave}) {if StackingCheck then ", Stacked Position" else ", Original Position"}`)
    end)
end
