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

local function GetTowersInfo()
    -- Mock function - would need proper implementation
    return {
        Scout = {Equipped = true, GoldenPerks = false},
        Sniper = {Equipped = true, GoldenPerks = false},
        Demoman = {Equipped = true, GoldenPerks = false},
        Medic = {Equipped = true, GoldenPerks = false},
        Minigunner = {Equipped = true, GoldenPerks = false}
    }
end

function SetUIText(name,string)
    if _G.StratXLibrary and _G.StratXLibrary.UI and _G.StratXLibrary.UI[name] then
        _G.StratXLibrary.UI[name]:SetText(string)
    else
        print(name,":",string)
    end
end

return function(self, p1)
    local tableinfo = p1
    local TotalTowers = tableinfo
    local GoldenTowers = tableinfo["Golden"] or {}
    local LoadoutProps = self.Loadout or {}
    local AllowEquip = tableinfo["AllowEquip"] or false
    local SkipCheck = tableinfo["SkipCheck"] or false
    LoadoutProps.AllowTeleport = type(LoadoutProps.AllowTeleport) == "boolean" and LoadoutProps.AllowTeleport or false
    
    local TroopsOwned = GetTowersInfo()
    
    for i,v in next, LoadoutProps do
        if type(v) == "thread" then
            task.cancel(v)
        end
    end

    if CheckPlace() then
        for i,v in ipairs(TotalTowers) do
            if not (TroopsOwned[v] and TroopsOwned[v].Equipped) then
                ConsoleInfo(`Tower "{v}" Didn't Equipped. Rejoining To Lobby`)
                task.wait(1)
                TeleportService:Teleport(3260590327, LocalPlayer)
                return
            end
        end
        ConsoleInfo("Loadout Selected: \""..table.concat(TotalTowers, "\", \"").."\"")
        return
    end

    LoadoutProps.Task = task.spawn(function()
        if not SkipCheck then
            local MissingTowers = {}
            for i,v in ipairs(TotalTowers) do
                if not TroopsOwned[v] then
                    table.insert(MissingTowers,v)
                end
            end
            
            if #MissingTowers ~= 0 then
                LoadoutProps.AllowTeleport = false
                repeat
                    TroopsOwned = GetTowersInfo()
                    for i,v in next, MissingTowers do
                        if not TroopsOwned[v] then
                            local BoughtCheck, BoughtMsg = RemoteFunction:InvokeServer("Shop", "Purchase", "tower",v)
                            if BoughtCheck or (type(BoughtMsg) == "string" and string.find(BoughtMsg,"Player already has tower")) then
                                print(v..": Bought")
                            else
                                print(v..": Need to purchase")
                            end
                        else
                            MissingTowers[i] = nil
                        end
                    end
                    task.wait(.5)
                until #MissingTowers == 0
            end
        end
        
        LoadoutProps.AllowTeleport = true
        
        if AllowEquip then
            local TroopsOwned = GetTowersInfo()
            for i,v in next, TroopsOwned do
                if v.Equipped then
                    RemoteEvent:FireServer("Inventory","Unequip","Tower",i)
                end
            end

            for i,v in ipairs(TotalTowers) do
                RemoteEvent:FireServer("Inventory", "Equip", "tower",v)
                local GoldenCheck = table.find(GoldenTowers,v)
                if _G.StratXLibrary.UI and _G.StratXLibrary.UI.TowersStatus and _G.StratXLibrary.UI.TowersStatus[i] then
                    _G.StratXLibrary.UI.TowersStatus[i].Text = (GoldenCheck and "[Golden] " or "")..v
                end
                
                if TroopsOwned[v].GoldenPerks and not GoldenCheck then
                    RemoteEvent:FireServer("Inventory", "Unequip", "Golden", v)
                elseif GoldenCheck then
                    RemoteEvent:FireServer("Inventory", "Equip", "Golden", v)
                end
            end
            
            ConsoleInfo("Loadout Selected: \""..table.concat(TotalTowers, "\", \"").."\"")
        end
    end)
end
