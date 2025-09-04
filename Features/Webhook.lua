local SendRequest = http_request or request or HttpPost or syn.request
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MatchGui = LocalPlayer.PlayerGui:WaitForChild("ReactGameRewards"):WaitForChild("Frame"):WaitForChild("gameOver") -- end result
local Info = MatchGui:WaitForChild("content"):WaitForChild("info")
local Stats = Info.stats
local Rewards = Info:WaitForChild("rewards")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Executor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "???"
local UtilitiesConfig = StratXLibrary.UtilitiesConfig
local PlayerInfo = StratXLibrary.UI.PlayerInfo.Property

local CommaText = function(string)
	local String = tostring(string):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
	return String
end

local TimeFormat = function(string)
	local Time = string.gsub(string,"%D+",":"):gsub(".?$","")
	return Time
end

local function CheckTower()
	local str = ""
	local TowerInfo = StratXLibrary.TowerInfo or {}
	for i,v in next, TowerInfo do
		str = `{str}\n{v[3]}: {v[2]}`
	end
	return str
end

local CheckColor = {
	["TRIUMPH!"] = tonumber(65280),
	["YOU LOST"] = tonumber(16711680),
	[true] = tonumber(65280),
	[false] = tonumber(16711680),
}

local Identifier = {
	["rbxassetid://17429548305"] = "Supply Drop",
	["rbxassetid://17448596007"] = "Airstrike",
	["rbxassetid://17429541513"] = "Barricade",
	["rbxassetid://17429537022"] = "Blizzard Bomb",
	["rbxassetid://17438487774"] = "Cooldown Flag",
	["rbxassetid://17438486138"] = "Damage Flag",
	["rbxassetid://17430416205"] = "Flash Bang",
	["rbxassetid://17429533728"] = "Grenade",
	["rbxassetid://17437703262"] = "Molotov",
	["rbxassetid://17448596749"] = "Napalm Strike",
	["rbxassetid://17430415569"] = "Nuke",
	["rbxassetid://124568805305441"] = "Pumpkin Bomb",
	["rbxassetid://17438486690"] = "Range Flag",
	["rbxassetid://114595010548022"] = "Sugar Rush",
	["rbxassetid://128078447476652"] = "Turkey Leg",
	["rbxassetid://17448597451"] = "UAV",
	["rbxassetid://7610093373"] = "Winter Storm",
	["rbxassetid://5870325376"] = "Coins",
	["rbxassetid://5870383867"] = "Gems",
	["rbxassetid://18493073533"] = "Spin Tickets",
	["rbxassetid://17447507910"] = "Timescale Tickets",
	["rbxassetid://18557179994"] = "Revive Tickets",
}

function NewWebhook(Link)
	local Data = {
		WebhookLink = Link,
		WebhookData = {
			embeds = {}
		}
	}

	local Webhook = {}

	function Webhook.AddMessage(Message)
		if Message then
			Data.WebhookData.content = Message
		end
		return Webhook
	end

	function Webhook.Profile(Username, Avatar)
		Username = Username or "Not Specified"
		Avatar = Avatar or ""

		Data.WebhookData.username = Username
		Data.WebhookData.avatar_url = Avatar

		return Webhook
	end

	function Webhook:CreateEmbed()
		local NewEmbed = {}
		table.insert(Data.WebhookData.embeds, NewEmbed)
		local EmbedFunctions = {}

		function EmbedFunctions.AddTitle(title)
			if title then
				NewEmbed.title = title
			end
			return EmbedFunctions
		end

		function EmbedFunctions.AddDescription(description)
			if description then
				NewEmbed.description = description
			end
			return EmbedFunctions
		end

		function EmbedFunctions.AddColor(Color)
			Color = Color or "#00ff52"
			NewEmbed.color = Color
			return EmbedFunctions
		end

		function EmbedFunctions.AddAuthor(Name, Link, Icon)
			NewEmbed.author = {}
			if Name then
				NewEmbed.author.name = Name
			end
			if Link then
				NewEmbed.author.url = Link
			end
			if Icon then
				NewEmbed.author.icon_url = Icon
			end
			return EmbedFunctions
		end

		function EmbedFunctions.AddField(Name, Value, Inline)
			NewEmbed.fields = NewEmbed.fields or {}
			local Field = {}
			Field["name"] = Name
			Field["value"] = Value
			if Inline ~= nil then
				Field["inline"] = Inline
			else
				Field["inline"] = true
			end
			table.insert(NewEmbed.fields, Field)
			return EmbedFunctions
		end

		function EmbedFunctions.AddImage(Link)
			NewEmbed.image = {}
			if Link then
				NewEmbed.image.url = Link
			end
			return EmbedFunctions
		end

		function EmbedFunctions.AddThumbnail(Link)
			NewEmbed.thumbnail = {}
			if Link then
				NewEmbed.thumbnail.url = Link
			end
			return EmbedFunctions
		end

		function EmbedFunctions.AddFooter(Text, Icon)
			NewEmbed.footer = {}
			if Text then
				NewEmbed.footer.text = Text
			end
			if Icon then
				NewEmbed.footer.icon_url = Icon
		
