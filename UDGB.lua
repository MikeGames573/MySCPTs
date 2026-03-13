-- Allowed place IDs
local allowedPlaces = {
    [17616779267] = true,
    [17387762301] = true
}

-- Exit early if not in allowed place
if not allowedPlaces[game.PlaceId] then
    notify("Game not detected, script not loading!!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/RF%20(No%20blotware%20edition).lua'))()
local Window = Rayfield:CreateWindow({
    Name = "Undertale Dungeons Go Beyond v1.6.1b",
    Icon = 0,
    LoadingTitle = "Undertale Dungeons Go Beyond v1.6.1b",
    LoadingSubtitle = "Made by Heli",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "UDGB"
    },
    ToggleUIKeybind = "K"
})

local TeleportTab = Window:CreateTab("Main", "home")
local SpellsTab = Window:CreateTab("Spells", "sparkles")
local ConfigTab = Window:CreateTab("Config", "settings")
-- =============================================
-- SHARED SERVICES & VARIABLES
-- =============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local UseSpellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UseSpell")
local ChangeSoulRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChangeSoul")
local SoulsFolder = ReplicatedStorage:WaitForChild("Souls")
local ForceCastEnabled = false
local LowCooldownEnabled = false
local slotMap = {
    [Enum.KeyCode.One] = 1, [Enum.KeyCode.Q] = 1,
    [Enum.KeyCode.Two] = 2, [Enum.KeyCode.E] = 2,
    [Enum.KeyCode.Three] = 3, [Enum.KeyCode.R] = 3,
    [Enum.KeyCode.Four] = 4, [Enum.KeyCode.F] = 4,
}

local selectedTrinkets = {}
local trinketSpamConnection = nil
local trinketOptions = {}
pcall(function()
	local trinketsFolder = player:WaitForChild("Trinkets", 5) -- waits up to 5 seconds (safe for both lobby & in-game)
	if trinketsFolder then
		for _, child in ipairs(trinketsFolder:GetChildren()) do
			if child:IsA("Folder") then
				table.insert(trinketOptions, child.Name)
			end
		end
	end
end)

local inHook = false
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	if inHook then
		return oldNamecall(self, ...)
	end

	if not LowCooldownEnabled then
		return oldNamecall(self, ...)
	end

	local method = getnamecallmethod()
	if self == UseSpellRemote and method == "FireServer" then
		inHook = true

		pcall(function()
			ChangeSoulRemote:InvokeServer(SoulsFolder:WaitForChild("Patience"), 1)
			ChangeSoulRemote:InvokeServer(SoulsFolder:WaitForChild("Patience"), 2)
		end)

		local result = oldNamecall(self, ...)

		pcall(function()
			ChangeSoulRemote:InvokeServer(SoulsFolder:WaitForChild("Determination"), 1)
			ChangeSoulRemote:InvokeServer(SoulsFolder:WaitForChild("Hate"), 2)
		end)

		inHook = false
		return result
	end

	inHook = false
	return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Shared variables
local selectedDungeon = ""
local selectedModifiers = {}
local isSoloEnabled = true
local playerCount = 1
-- Build options
local dungeonOptions = {}
local dungeonsFolder = ReplicatedStorage:FindFirstChild("Dungeons")
if dungeonsFolder then
    for _, folder in ipairs(dungeonsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            local displayName = folder.Name
            if not folder:FindFirstChild("GetLootTable") then
                displayName = displayName .. " (Might not work)"
            end
            table.insert(dungeonOptions, displayName)
        end
    end
end
local modifierOptions = {}
local artifactsFolder = ReplicatedStorage:FindFirstChild("Artifacts")
if artifactsFolder then
    for _, folder in ipairs(artifactsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            table.insert(modifierOptions, folder.Name)
        end
    end
end
-- =============================================
-- MAIN TAB
-- =============================================
SpellsTab:CreateSection("Trinket Spam Test")

-- Dropdown: gets every folder name from player.Trinkets and allows multiple selection
SpellsTab:CreateDropdown({
	Name = "Select Trinkets (Multiple)",
	Options = trinketOptions,
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "SelectedTrinkets",
	Callback = function(Options)
		selectedTrinkets = Options
	end,
})

-- Toggle: "Trinket Spam test" - NO Flag so it NEVER saves to config
-- Default = off
-- When ON: equips the selected trinkets in a cycle, every single frame (Heartbeat), zero delay, no lag
local trinketSpamToggle
trinketSpamToggle = SpellsTab:CreateToggle({
	Name = "Trinket Spam test",
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			-- Safety: can't turn on with nothing selected
			if #selectedTrinkets == 0 then
				Rayfield:Notify({
					Title = "Trinket Spam",
					Content = "Select at least one trinket first!",
					Duration = 5,
					Image = "alert-triangle"
				})
				trinketSpamToggle:Set(false)
				return
			end

			-- Start infinite frame-by-frame spam
			if trinketSpamConnection then
				trinketSpamConnection:Disconnect()
			end

			local index = 1
			trinketSpamConnection = RunService.Heartbeat:Connect(function()
				local count = #selectedTrinkets
				if count > 0 then
					-- Safe cycling even if selection changes mid-spam
					index = ((index - 1) % count) + 1
					local trinketName = selectedTrinkets[index]

					local trinketsFolder = player:FindFirstChild("Trinkets")
					if trinketsFolder then
						local trinket = trinketsFolder:FindFirstChild(trinketName)
						if trinket then
							local args = { trinket } -- exact same format you showed
							ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipTrinket"):FireServer(unpack(args))
						end
					end

					index = index + 1
				end
			end)
		else
			-- Turn off
			if trinketSpamConnection then
				trinketSpamConnection:Disconnect()
				trinketSpamConnection = nil
			end
		end
	end,
})
local placeId = game.PlaceId
if placeId == 17387762301 then
    TeleportTab:CreateSection("(Dungeon Starter) Lobby")
    -- REJOIN = FORCED FRESH SERVER (exactly your working method)
    TeleportTab:CreateButton({
        Name = "Rejoin (New Server)",
        Callback = function()
            local PlaceId = game.PlaceId
            player:Kick("\nRejoining...")
            task.wait(1)
            TeleportService:Teleport(PlaceId) -- No JobId = Roblox gives you a brand new server
        end,
    })
    TeleportTab:CreateDropdown({
        Name = "Dungeons",
        Options = dungeonOptions,
        CurrentOption = dungeonOptions[1] and {dungeonOptions[1]} or {},
        MultipleOptions = false,
        Callback = function(Options)
            local display = Options[1] or ""
            selectedDungeon = display:gsub(" %(Might not work%)", "")
        end,
    })
    TeleportTab:CreateToggle({
        Name = "Is Solo (Can bypass level limit if activated)",
        CurrentValue = true,
        Flag = "IsSolo",
        Callback = function(Value)
            isSoloEnabled = Value
        end,
    })
    TeleportTab:CreateDropdown({
        Name = "Modifiers (Warning: Doesn't work for every dungeon)",
        Options = modifierOptions,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(Options)
            selectedModifiers = Options
        end,
    })
    TeleportTab:CreateButton({
        Name = "Start Dungeon",
        Callback = function()
            if selectedDungeon == "" then
                Rayfield:Notify({Title = "Error", Content = "Select a dungeon first!", Duration = 5, Image = "alert-triangle"})
                return
            end
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StartDungeon"):FireServer(selectedDungeon, isSoloEnabled, selectedModifiers or {})
            Rayfield:Notify({Title = "Dungeon Started", Content = "Launching " .. selectedDungeon, Duration = 5, Image = "play"})
        end,
    })
elseif placeId == 17616779267 then
    TeleportTab:CreateSection("(Dungeon Starter) In-game")
    -- REJOIN = FORCED FRESH SERVER (exactly your working method)
    TeleportTab:CreateButton({
        Name = "Rejoin (New Server)",
        Callback = function()
            local PlaceId = game.PlaceId
            player:Kick("\nRejoining...")
            task.wait(1)
            TeleportService:Teleport(PlaceId) -- No JobId = Roblox gives you a brand new server
        end,
    })
    TeleportTab:CreateDropdown({
        Name = "Dungeons",
        Options = dungeonOptions,
        CurrentOption = dungeonOptions[1] and {dungeonOptions[1]} or {},
        MultipleOptions = false,
        Callback = function(Options)
            local display = Options[1] or ""
            selectedDungeon = display:gsub(" %(Might not work%)", "")
        end,
    })
    TeleportTab:CreateSlider({
        Name = "Player Count",
        Range = {1, 4},
        Increment = 1,
        CurrentValue = 1,
        Flag = "PlayerCount",
        Callback = function(Value)
            playerCount = Value
        end,
    })
    TeleportTab:CreateDropdown({
        Name = "Modifiers (Warning: Doesn't work for every dungeon)",
        Options = modifierOptions,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(Options)
            selectedModifiers = Options
        end,
    })
    TeleportTab:CreateButton({
        Name = "Set Dungeon",
        Callback = function()
            if selectedDungeon == "" then
                Rayfield:Notify({Title = "Error", Content = "Select a dungeon first!", Duration = 5, Image = "alert-triangle"})
                return
            end
            ReplicatedStorage:WaitForChild("SetDungeon"):FireServer({selectedDungeon, playerCount, selectedModifiers or {}})
            Rayfield:Notify({Title = "Dungeon Set", Content = "Sent: " .. selectedDungeon .. " (" .. playerCount .. " players)", Duration = 5, Image = "play"})
        end,
    })
else
    TeleportTab:CreateSection("Teleport Tools")
    TeleportTab:CreateParagraph({Title = "Place Not Supported", Content = "Only works on PlaceId 17387762301 (lobby) or 17616779267 (in-game)."})
end
-- =============================================
-- SPELLS TAB
-- =============================================
SpellsTab:CreateSection("Spell Modifiers")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not ForceCastEnabled or gameProcessed then return end
    local slot = slotMap[input.KeyCode]
    if not slot then return end
    local spellObj
    pcall(function()
        local InventoryModule = require(ReplicatedStorage.Modules.Inventory)
        spellObj = InventoryModule.GetEqSpell(player, slot)
    end)
    if spellObj then
        UseSpellRemote:FireServer(spellObj)
    end
end)
SpellsTab:CreateToggle({
    Name = "Force Spell Cast (Soul Bypass)",
    CurrentValue = false,
    Flag = "ForceSpellCast",
    Callback = function(Value)
        ForceCastEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Force Spell Cast", Content = "Soul requirements bypassed.\nUse 1/Q • 2/E • 3/R • 4/F", Duration = 5, Image = "zap"})
        end
    end,
})

SpellsTab:CreateToggle({
	Name = "Low Cooldown Spells",
	CurrentValue = false,
	Flag = "LowCooldownSpell", -- novo flag (salva no config corretamente)
	Callback = function(Value)
		LowCooldownEnabled = Value
		if Value then
			Rayfield:Notify({
				Title = "Low Cooldown Spell",
				Content = "This is a test for lowering the spells cooldown, may not work",
				Duration = 6,
				Image = "zap"
			})
		end
	end,
})
-- =============================================
-- CONFIG TAB
-- =============================================
ConfigTab:CreateSection("Script Settings")
local queueFunction = queue_on_teleport or (syn and syn.queue_on_teleport) or function() end
ConfigTab:CreateToggle({
    Name = "Auto Execute on Teleport",
    CurrentValue = false,
    Flag = "AutoExecuteTeleport",
    Callback = function(Value)
        if Value and (placeId == 17616779267 or placeId == 17387762301) then
            pcall(function()
                queueFunction([[
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()
                ]])
            end)
            Rayfield:Notify({Title = "Queued!", Content = "Script will auto-run after any teleport.", Duration = 6, Image = "refresh-cw"})
        end
    end,
})
ConfigTab:CreateLabel(
	"⚠️ DESTROYS RAYFIELD COMPLETELY", 
	"alert-triangle", 
	Color3.fromRGB(255, 0, 0), 
	false
)
ConfigTab:CreateButton({
	Name = "Destroy Rayfield",
	Callback = function()
		Rayfield:Notify({
			Title = "Rayfield Destroyed",
			Content = "Interface completely removed.\nScript will no longer show until re-executed.",
			Duration = 5,
			Image = "trash-2"
		})
		
		task.wait(1) -- small delay so you can see the notification
		Rayfield:Destroy() -- This completely erases the entire Rayfield UI, all tabs, sections, toggles, connections, and memory traces
	end,
})
Rayfield:LoadConfiguration()
