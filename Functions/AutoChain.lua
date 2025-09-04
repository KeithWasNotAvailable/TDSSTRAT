local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

function Chain(Tower)
    local towerInstance = workspace:FindFirstChild("Tower_" .. Tower) or Instance.new("Part")
    if towerInstance then
        RemoteFunction:InvokeServer("Troops","Abilities","Activate",{
            ["Troop"] = towerInstance,
            ["Name"] = "Call Of Arms"
        })
        task.wait(10)
    end
end

return function(self, p1)
    local tableinfo = p1
    local Tower1,Tower2,Tower3 = tableinfo["TowerIndex1"], tableinfo["TowerIndex2"], tableinfo["TowerIndex3"]
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false 
    
    if not CheckPlace() then
        return
    end
    
    SetActionInfo("AutoChain","Total")
    
    task.spawn(function()
        if not TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"]) then
            return
        end
        
        if not TowersCheckHandler(Tower1,Tower2,Tower3) then
            return
        end
        
        -- Initialize towers if needed
        if not _G.StratXLibrary.TowersContained[Tower1] then
            _G.StratXLibrary.TowersContained[Tower1] = {AutoChain = true}
        else
            _G.StratXLibrary.TowersContained[Tower1].AutoChain = true
        end
        
        if not _G.StratXLibrary.TowersContained[Tower2] then
            _G.StratXLibrary.TowersContained[Tower2] = {AutoChain = true}
        else
            _G.StratXLibrary.TowersContained[Tower2].AutoChain = true
        end
        
        if not _G.StratXLibrary.TowersContained[Tower3] then
            _G.StratXLibrary.TowersContained[Tower3] = {AutoChain = true}
        else
            _G.StratXLibrary.TowersContained[Tower3].AutoChain = true
        end
        
        local TowerType = {
            [Tower1] = GetTypeIndex(nil, Tower1),
            [Tower2] = GetTypeIndex(nil, Tower2),
            [Tower3] = GetTypeIndex(nil, Tower3),
        }
        
        for i,v in next, TowerType do
            if not v:match("Commander") then
                ConsoleError("Troop Index: "..v.." Is Not A Commander!")
                return
            end
        end
        
        SetActionInfo("AutoChain")
        ConsoleInfo("Enabled AutoChain For Towers Index: "..Tower1..", "..Tower2..", "..Tower3..", Types: \""..TowerType[Tower1].."\",  \""..TowerType[Tower2].."\", \""..TowerType[Tower3]..
        "\" (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..")")
        
        while true do
            if not _G.StratXLibrary.TowersContained[Tower1] or not _G.StratXLibrary.TowersContained[Tower1].AutoChain then
                ConsoleInfo("Disabled AutoChain For Towers Index: "..Tower1..", "..Tower2..", "..Tower3)
                break
            end
            Chain(Tower1)
            
            if not _G.StratXLibrary.TowersContained[Tower2] or not _G.StratXLibrary.TowersContained[Tower2].AutoChain then
                ConsoleInfo("Disabled AutoChain For Towers Index: "..Tower1..", "..Tower2..", "..Tower3)
                break
            end
            Chain(Tower2)
            
            if not _G.StratXLibrary.TowersContained[Tower3] or not _G.StratXLibrary.TowersContained[Tower3].AutoChain then
                ConsoleInfo("Disabled AutoChain For Towers Index: "..Tower1..", "..Tower2..", "..Tower3)
                break
            end
            Chain(Tower3)
            
            task.wait()
        end
    end)
end
