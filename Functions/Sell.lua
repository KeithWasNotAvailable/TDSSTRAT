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
    
    if not CheckPlace() then
        return
    end
    
    for i = 1, #Tower do
        SetActionInfo("Sell","Total")
    end
    
    task.spawn(function()
        if not TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"]) then
            return
        end
        
        for i,v in next, Tower do
            task.spawn(function()
                local SoldCheck
                repeat
                    if not TowersCheckHandler(v) then
                        return
                    end
                    
                    SoldCheck = RemoteFunction:InvokeServer("Troops","Sell",{
                        ["Troop"] = workspace:FindFirstChild("Tower_" .. v) or Instance.new("Part")
                    })
                    task.wait()
                until SoldCheck or not workspace:FindFirstChild("Tower_" .. v)
                
                local TowerType = GetTypeIndex(tableinfo["TypeIndex"],v)
                SetActionInfo("Sell")
                
                ConsoleInfo((not SoldCheck and "Already " or "").."Sold Tower Index: "..v..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..")")
            end)
        end
    end)
end
