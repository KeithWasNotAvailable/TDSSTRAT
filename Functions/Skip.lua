local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

return function(self, p1)
    local tableinfo = p1
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false
    
    if not CheckPlace() then
        return
    end
    
    SetActionInfo("Skip","Total")
    
    task.spawn(function()
        if not TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"]) then
            return
        end
        
        local SkipCheck
        repeat
            SkipCheck = RemoteFunction:InvokeServer("Voting", "Skip")
            task.wait()
        until SkipCheck
        
        SetActionInfo("Skip")
        ConsoleInfo(`Skipped Wave {Wave} (Min: {Min}, Sec: {Sec}, InBetween: {InWave})`)
    end)
end
