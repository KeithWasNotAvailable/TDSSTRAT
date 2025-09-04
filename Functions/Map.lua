local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

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

local function GetTowersInfo()
    return {
        Scout = {Equipped = true, GoldenPerks = false},
        Sniper = {Equipped = true, GoldenPerks = false},
        Demoman = {Equipped = true, GoldenPerks = false},
        Medic = {Equipped = true, GoldenPerks = false},
        Minigunner = {Equipped = true, GoldenPerks = false}
    }
end

local SpecialGameMode = {
    ["Pizza Party"] = {mode = "halloween", challenge = "PizzaParty"},
    ["Badlands II"] = {mode = "badlands", challenge = "Badlands"},
    ["Polluted Wastelands II"] = {mode = "polluted", challenge = "PollutedWasteland"},
    ["Failed Gateway"] = {mode = "halloween2024", difficulty = "Act1", night = 1},
    ["The Nightmare Realm"] = {mode = "halloween2024", difficulty = "Act2", night = 2},
    ["Containment"] = {mode = "halloween2024", difficulty = "Act3", night = 3},
    ["Pls Donate"] = {mode = "plsDonate", difficulty = "PlsDonateHard"},
    ["Outpost 32"] = {mode = "frostInvasion", difficulty = "Hard"},
    ["Classic Candy Cane Lane"] = {mode = "Event", part = "ClassicRobloxPart1"},
    ["Classic Winter"] = {mode = "Event", part = "ClassicRobloxPart2"},
    ["Classic Forest Camp"] = {mode = "Event", part = "ClassicRobloxPart3"},
    ["Classic Island Chaos"] = {mode = "Event", part = "ClassicRobloxPart4"},
    ["Classic Castle"] = {mode = "Event", part = "ClassicRobloxPart5"},
}

local ElevatorSettings = {
    ["Survival"] = {Enabled = false, ChangeMap = true, JoinMap = true, WaitTimeToChange = .1, WaitTimeToJoin = .25},
    ["Hardcore"] = {Enabled = false, ChangeMap = true, JoinMap = true, WaitTimeToChange = 4.2, WaitTimeToJoin = 1.7},
    ["Tutorial"] = {Enabled = false},
    ["Halloween2024"] = {Enabled = false},
    ["PlsDonate"] = {Enabled = false},
    ["Event"] = {Enabled = false},
    ["FrostInvasion"] = {Enabled = false}
}

return function(self, p1)
    local tableinfo = p1
    local MapName = tableinfo["Map"]
    local Solo = tableinfo["Solo"]
    local Mode = tableinfo["Mode"]
    local Difficulty = tableinfo["Difficulty"]
    
    local MapGlobal = _G.StratXLibrary.Global.Map
    tableinfo.Index = self.Index
    local NameTable = MapName..":"..Mode
    ElevatorSettings[Mode].Enabled = true
    MapGlobal[NameTable] = tableinfo
    
    if MapGlobal.Active then
        print("One-time Execution")
        return
    end
    
    MapGlobal.Active = true
    
    for i,v in next, MapGlobal do
        if type(v) == "thread" then
            task.cancel(v)
        elseif type(v) == "RBXScriptConnection" then
            v:Disconnect()
            RemoteFunction:InvokeServer("Elevators", "Leave")
        end
    end
    
    MapGlobal.JoiningCheck = false
    MapGlobal.ChangeCheck = false
    
    task.spawn(function()
        if CheckPlace() then
            local RSMode = ReplicatedStorage:WaitForChild("State"):WaitForChild("Mode")
            local RSMap = ReplicatedStorage:WaitForChild("State"):WaitForChild("Map")
            
            repeat task.wait() until RSMap.Value and type(RSMap.Value) == "string" and RSMode.Value
            
            local GameMapName = RSMap.Value
            local GameMode = RSMode.Value
            local MapTable = MapGlobal[GameMapName..":"..GameMode]
            
            if not MapTable then
                ConsoleError("Wrong Map Selected: "..GameMapName..", ".."Mode: "..GameMode)
                task.wait(3)
                TeleportService:Teleport(3260590327, LocalPlayer)
                return
            end
            
            ConsoleInfo("Map Selected: "..GameMapName..", ".."Mode: "..Mode..", ".."Solo Only: "..tostring(Solo))
            return
        end
        
        if MapName == "Tutorial" then
            ConsoleInfo("Teleporting To Tutorial Mode")
            RemoteEvent:FireServer("Tutorial", "Start")
            return
        end
        
        if SpecialGameMode[MapName] then
            local SpecialTable = SpecialGameMode[MapName]
            ConsoleInfo("Special Gamemode Found. Checking Loadout")
            
            local Strat = _G.StratXLibrary.Strat[self.Index]
            if Strat.Loadout and not Strat.Loadout.AllowTeleport then
                repeat task.wait() until Strat.Loadout.AllowTeleport
            end
            
            local LoadoutInfo = Strat.Loadout.Lists[#Strat.Loadout.Lists]
            LoadoutInfo.AllowEquip = true
            LoadoutInfo.SkipCheck = true
            
            ConsoleInfo("Loadout Selecting")
            _G.Functions.Loadout(Strat, LoadoutInfo)
            task.wait(2)
            
            ConsoleInfo("Teleporting to Special Gamemode")
            RemoteFunction:InvokeServer("Multiplayer","single_create")
            
            if SpecialTable.mode == "halloween2024" then
                RemoteFunction:InvokeServer("Multiplayer","v2:start",{
                    ["difficulty"] = SpecialTable.difficulty,
                    ["night"] = SpecialTable.night,
                    ["count"] = 1,
                    ["mode"] = SpecialTable.mode,
                })
            elseif SpecialTable.mode == "frostInvasion" then
                RemoteFunction:InvokeServer("Multiplayer","v2:start",{
                    ["difficulty"] = SpecialTable.difficulty,
                    ["mode"] = SpecialTable.mode,
                    ["count"] = 1,
                })
            elseif SpecialTable.mode == "plsDonate" then
                RemoteFunction:InvokeServer("Multiplayer","v2:start",{
                    ["difficulty"] = SpecialTable.difficulty,
                    ["count"] = 1,
                    ["mode"] = SpecialTable.mode,
                })
            elseif SpecialTable.mode == "Event" then
                RemoteFunction:InvokeServer("EventMissions","Start", SpecialTable.part)
            else
                RemoteFunction:InvokeServer("Multiplayer","v2:start",{
                    ["count"] = 1,
                    ["mode"] = SpecialTable.mode,
                    ["challenge"] = SpecialTable.challenge,
                })
            end
            
            ConsoleInfo("Using MatchMaking To Teleport To Special GameMode: "..SpecialTable.mode)
            return
        end
        
        ConsoleInfo("Map function completed for: "..MapName)
    end)
end
