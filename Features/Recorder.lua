-- Recorder.lua
local Recorder = {}
Recorder.__index = Recorder

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Recorder:StartRecording()
    self.Recording = true
    self.Actions = {}
    self.StartTime = os.time()
    
    print("Recording started...")
    
    -- Hook into game actions
    self:HookRemoteEvents()
end

function Recorder:StopRecording()
    self.Recording = false
    print("Recording stopped. Total actions:", #self.Actions)
    self:GenerateScript()
end

function Recorder:HookRemoteEvents()
    local remoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction")
    local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent")
    
    if remoteFunction then
        local oldInvoke = remoteFunction.InvokeServer
        remoteFunction.InvokeServer = function(self, ...)
            local args = {...}
            if self.Recording and args[1] == "Troops" then
                self:RecordAction("TroopAction", args)
            end
            return oldInvoke(self, ...)
        end
    end
end

function Recorder:RecordAction(actionType, data)
    if not self.Recording then return end
    
    local action = {
        Type = actionType,
        Data = data,
        Timestamp = os.time() - self.StartTime,
        Wave = --[[Get current wave]],
        Time = --[[Get game time]]
    }
    
    table.insert(self.Actions, action)
    print("Recorded action:", actionType)
end

function Recorder:GenerateScript()
    local scriptText = "-- Auto-generated Strat\n"
    scriptText = scriptText .. "local TDS = loadstring(game:HttpGet('https://raw.githubusercontent.com/your-username/TDS-Scripts/main/Loader.lua'))()\n\n"
    
    for _, action in ipairs(self.Actions) do
        if action.Type == "TroopAction" then
            local actionType = action.Data[2]
            if actionType == "Place" then
                scriptText = scriptText .. string.format("TDS:Place('%s', %.2f, %.2f, %.2f, %d, %.1f)\n",
                    action.Data[3], -- troop name
                    math.random() * 10, math.random() * 10, math.random() * 10, -- position
                    action.Wave or 1, -- wave
                    action.Timestamp -- time
                )
            elseif actionType == "Upgrade" then
                scriptText = scriptText .. string.format("TDS:Upgrade(%d, %d, %.1f)\n",
                    action.Data[4].Troop.Name, -- tower index
                    action.Data[4].Path, -- path
                    action.Timestamp -- time
                )
            end
        end
    end
    
    -- Save to file
    writefile("TDS-Scripts/RecordedStrat.lua", scriptText)
    print("Script generated: RecordedStrat.lua")
end

return Recorder
