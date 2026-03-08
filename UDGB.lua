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

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Undertale Dungeons Go Beyond v1.4.3",
    Icon = 0,
    LoadingTitle = "Assisting tools for the newest version of Undertale Dungeons",
    LoadingSubtitle = "Made by Heli",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "UDGB"
    },
    ToggleUIKeybind = "K"
})

Rayfield:Notify({
   Title = "Game Detected!!",
   Content = "The GUI is now loading!!",
   Duration = 6.5
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
local player = Players.LocalPlayer
local UseSpellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UseSpell")
local ForceCastEnabled = false
local slotMap = {
    [Enum.KeyCode.One] = 1, [Enum.KeyCode.Q] = 1,
    [Enum.KeyCode.Two] = 2, [Enum.KeyCode.E] = 2,
    [Enum.KeyCode.Three] = 3, [Enum.KeyCode.R] = 3,
    [Enum.KeyCode.Four] = 4, [Enum.KeyCode.F] = 4,
}
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
-- TELEPORT TAB (Lobby or In-game)
-- =============================================
local placeId = game.PlaceId
if placeId == 17387762301 then
    TeleportTab:CreateSection("(Dungeon Starter) Lobby")
    -- REJOIN = FORCED FRESH SERVER (exactly your working method)
    TeleportTab:CreateButton({
        Name = "Rejoin (New Server)",
        Callback = function()
            Rayfield:Notify({
                Title = "Joining Fresh Server",
                Content = "Forcing a completely new server (this bypasses started dungeon kick)...",
                Duration = 5,
                Image = "refresh-cw"
            })
            local PlaceId = game.PlaceId
            player:Kick("\nRejoining to fresh server...")
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
            Rayfield:Notify({
                Title = "Joining Fresh Server",
                Content = "Forcing a completely new server (this bypasses started dungeon kick)...",
                Duration = 5,
                Image = "refresh-cw"
            })
            local PlaceId = game.PlaceId
            player:Kick("\nRejoining to fresh server...")
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
SpellsTab:CreateSection("Casting Improvements")
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
Rayfield:LoadConfiguration()
