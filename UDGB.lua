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
    Name = "Undertale Dungeons Go Beyond v1.6.1",
    Icon = 0,
    LoadingTitle = "Undertale Dungeons Go Beyond v1.6.1",
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
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local UseSpellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UseSpell")
local ForceCastEnabled = false
local slotMap = {
    [Enum.KeyCode.One] = 1, [Enum.KeyCode.Q] = 1,
    [Enum.KeyCode.Two] = 2, [Enum.KeyCode.E] = 2,
    [Enum.KeyCode.Three] = 3, [Enum.KeyCode.R] = 3,
    [Enum.KeyCode.Four] = 4, [Enum.KeyCode.F] = 4,
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ChangeSoulRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChangeSoul")
local SoulsFolder = ReplicatedStorage:WaitForChild("Souls")

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

local ShowCooldownTextEnabled = false
local spellCDTimes = {}
local SpellsFrame = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpellsFrame", true)
if not SpellsFrame then
    SpellsFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("Inventory", 5):FindFirstChild("SpellsFrame", true)
end

local function HandleSpellCast(_, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    local slot = slotMap[inputObject.KeyCode]
    if not slot then return Enum.ContextActionResult.Pass end

    local spellObj
    pcall(function()
        spellObj = require(ReplicatedStorage.Modules.Inventory).GetEqSpell(player, slot)
    end)
    if not spellObj then return Enum.ContextActionResult.Pass end

    if ForceCastLowerCooldownEnabled then
        ChangeSoulRemote:InvokeServer(SoulsFolder.Patience, 1)
        ChangeSoulRemote:InvokeServer(SoulsFolder.Patience, 2)
        UseSpellRemote:FireServer(spellObj)
        task.wait(0.05)
        ChangeSoulRemote:InvokeServer(SoulsFolder.Determination, 1)
        ChangeSoulRemote:InvokeServer(SoulsFolder.Hate, 2)
    elseif ForceCastEnabled then
        UseSpellRemote:FireServer(spellObj)
    else
        return Enum.ContextActionResult.Pass
    end

    -- VISUAL + TRACK (igual ao jogo normal)
    local spellFrame = SpellsFrame and SpellsFrame:FindFirstChild(tostring(slot))
    if spellFrame then
        spellFrame.Frame.Size = UDim2.new(1,0,-1,0)
        spellFrame.Cooldown.Value = true

        local cd = require(ReplicatedStorage.Modules.Inventory).GetSpellCooldown(player, spellObj) -- EXATO como o UseSpell normal
        spellCDTimes[slot] = {start = tick(), duration = cd}

        local tween = TweenService:Create(spellFrame.Frame, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,0)})
        tween:Play()
    end

    return Enum.ContextActionResult.Sink
end

if SpellsFrame then
    for i = 1,4 do
        local frame = SpellsFrame:FindFirstChild(tostring(i))
        if frame then
            frame.Cooldown.Changed:Connect(function()
                if frame.Cooldown.Value == true then
                    local spellObj = require(ReplicatedStorage.Modules.Inventory).GetEqSpell(player, i)
                    if spellObj then
                        local cd = require(ReplicatedStorage.Modules.Inventory).GetSpellCooldown(player, spellObj)
                        spellCDTimes[i] = {start = tick(), duration = cd}
                    end
                end
            end)
        end
    end
end


-- Bind permanente das teclas (só 1 vez)
ContextActionService:BindAction(
	"ForceSpellCastOverride",
	HandleSpellCast,
	false,
	Enum.KeyCode.One, Enum.KeyCode.Q,
	Enum.KeyCode.Two, Enum.KeyCode.E,
	Enum.KeyCode.Three, Enum.KeyCode.R,
	Enum.KeyCode.Four, Enum.KeyCode.F
)
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
	Name = "Force Spell Cast (Soul bypass, lower cooldown)",
	CurrentValue = false,
	Flag = "ForceSpellCastLowerCD",
	Callback = function(Value)
		ForceCastLowerCooldownEnabled = Value
		if Value then
				Rayfield:Notify({Title = "Force Spell Cast", Content = "Soul requirements bypassed and cooldown lowered.\nUse 1/Q • 2/E • 3/R • 4/F", Duration = 5, Image = "zap"})
		end
	end,
})

SpellsTab:CreateToggle({
    Name = "Show Real-Time",
    CurrentValue = false,
    Flag = "ShowCooldownText",
    Callback = function(v)
        ShowCooldownTextEnabled = v
        if v and SpellsFrame then
            task.spawn(function()
                while ShowCooldownTextEnabled do
                    for i = 1,4 do
                        local frame = SpellsFrame:FindFirstChild(tostring(i))
                        if frame and frame.Cooldown.Value and spellCDTimes[i] then
                            local rem = spellCDTimes[i].duration - (tick() - spellCDTimes[i].start)
                            if rem > 0 then
                                if not frame:FindFirstChild("CDText") then
                                    local txt = Instance.new("TextLabel")
                                    txt.Name = "CDText"
                                    txt.Size = UDim2.new(1,0,0.4,0)
                                    txt.Position = UDim2.new(0,0,-0.45,0)
                                    txt.BackgroundTransparency = 1
                                    txt.TextColor3 = Color3.new(1,1,0)
                                    txt.TextStrokeTransparency = 0
                                    txt.Font = Enum.Font.GothamBold
                                    txt.TextSize = 18
                                    txt.Parent = frame
                                end
                                frame.CDText.Text = string.format("%.1fs", rem)
                            elseif frame:FindFirstChild("CDText") then
                                frame.CDText:Destroy()
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
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
