local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =============================================
-- CUSTOM THEMES (super easy to expand!)
-- =============================================
-- To add a new theme:
-- 1. Create a new table like DeterminationTheme or HateTheme below
-- 2. Add it to ThemeMap with the exact name you want in the dropdown
-- 3. Add the name to the dropdown Options list in the Config tab
-- Everything uses full Rayfield theme tables → changes **ALL** colors (buttons, toggles, sliders, tabs, background, text, notifications, etc.)

local DeterminationTheme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(18, 18, 18),
    Topbar = Color3.fromRGB(28, 28, 28),
    Shadow = Color3.fromRGB(10, 10, 10),
    NotificationBackground = Color3.fromRGB(22, 22, 22),
    NotificationActionsBackground = Color3.fromRGB(35, 35, 35),
    TabBackground = Color3.fromRGB(28, 28, 28),
    TabStroke = Color3.fromRGB(80, 0, 0),
    TabBackgroundSelected = Color3.fromRGB(55, 10, 10),
    TabTextColor = Color3.fromRGB(240, 240, 240),
    SelectedTabTextColor = Color3.fromRGB(255, 90, 90),
    ElementBackground = Color3.fromRGB(28, 28, 28),
    ElementBackgroundHover = Color3.fromRGB(40, 20, 20),
    SecondaryElementBackground = Color3.fromRGB(20, 20, 20),
    ElementStroke = Color3.fromRGB(70, 0, 0),
    SecondaryElementStroke = Color3.fromRGB(50, 0, 0),
    SliderBackground = Color3.fromRGB(45, 0, 0),
    SliderProgress = Color3.fromRGB(190, 40, 40),   -- bright, vibrant red (not dark!)
    SliderStroke = Color3.fromRGB(210, 60, 60),
    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(170, 20, 20),
    ToggleDisabled = Color3.fromRGB(90, 90, 90),
    ToggleEnabledStroke = Color3.fromRGB(200, 50, 50),
    ToggleDisabledStroke = Color3.fromRGB(110, 110, 110),
    ToggleEnabledOuterStroke = Color3.fromRGB(150, 0, 0),
    ToggleDisabledOuterStroke = Color3.fromRGB(70, 70, 70),
    DropdownSelected = Color3.fromRGB(45, 15, 15),
    DropdownUnselected = Color3.fromRGB(28, 28, 28),
    InputBackground = Color3.fromRGB(28, 28, 28),
    InputStroke = Color3.fromRGB(70, 0, 0),
    PlaceholderColor = Color3.fromRGB(170, 170, 170)
}

local HateTheme = {
    TextColor = Color3.fromRGB(235, 235, 235),
    Background = Color3.fromRGB(10, 0, 18),
    Topbar = Color3.fromRGB(15, 0, 25),
    Shadow = Color3.fromRGB(5, 0, 10),
    NotificationBackground = Color3.fromRGB(12, 0, 22),
    NotificationActionsBackground = Color3.fromRGB(18, 0, 28),
    TabBackground = Color3.fromRGB(15, 0, 25),
    TabStroke = Color3.fromRGB(40, 0, 55),
    TabBackgroundSelected = Color3.fromRGB(30, 0, 40),
    TabTextColor = Color3.fromRGB(235, 235, 235),
    SelectedTabTextColor = Color3.fromRGB(180, 80, 220),
    ElementBackground = Color3.fromRGB(15, 0, 25),
    ElementBackgroundHover = Color3.fromRGB(22, 0, 35),
    SecondaryElementBackground = Color3.fromRGB(10, 0, 18),
    ElementStroke = Color3.fromRGB(45, 0, 60),
    SecondaryElementStroke = Color3.fromRGB(35, 0, 48),
    SliderBackground = Color3.fromRGB(20, 0, 32),
    SliderProgress = Color3.fromRGB(90, 10, 140),
    SliderStroke = Color3.fromRGB(110, 20, 160),
    ToggleBackground = Color3.fromRGB(18, 0, 28),
    ToggleEnabled = Color3.fromRGB(75, 0, 115),
    ToggleDisabled = Color3.fromRGB(75, 75, 75),
    ToggleEnabledStroke = Color3.fromRGB(100, 0, 150),
    ToggleDisabledStroke = Color3.fromRGB(95, 95, 95),
    ToggleEnabledOuterStroke = Color3.fromRGB(17, 0, 31),
    ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 55),
    DropdownSelected = Color3.fromRGB(25, 0, 38),
    DropdownUnselected = Color3.fromRGB(15, 0, 25),
    InputBackground = Color3.fromRGB(15, 0, 25),
    InputStroke = Color3.fromRGB(45, 0, 60),
    PlaceholderColor = Color3.fromRGB(160, 160, 160)
}

local ThemeMap = {
    Determination = DeterminationTheme,
    HATE = HateTheme,
    Default = "Default"
}

local Window = Rayfield:CreateWindow({
    Name = "SpellForge Hub",
    Icon = 0,
    LoadingTitle = "SpellForge Hub",
    LoadingSubtitle = "Advanced Spell Tools",
    Theme = DeterminationTheme, -- Default theme (Determination)
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SpellForge",
        FileName = "SpellSettings"
    },
    ToggleUIKeybind = "K"
})

local TeleportTab = Window:CreateTab("Teleport", "home")
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

-- Queue function (used for auto-execute persistence)
local queueFunction = queue_on_teleport or (syn and syn.queue_on_teleport) or function() end

-- =============================================
-- TELEPORT TAB (Lobby or In-game)
-- =============================================
local placeId = game.PlaceId
if placeId == 17387762301 then
    TeleportTab:CreateSection("Lobby")
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
        Name = "Is Solo",
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
    TeleportTab:CreateSection("In-game")
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
            TeleportService:Teleport(PlaceId)
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
-- CONFIG TAB (clean & organized)
-- =============================================
ConfigTab:CreateSection("Script Settings")

local AutoExecuteToggle = ConfigTab:CreateToggle({
    Name = "Auto Execute on Teleport",
    CurrentValue = false,
    Flag = "AutoExecuteTeleport",
    Callback = function(Value)
        if Value then
            pcall(function()
                queueFunction([[
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()
                ]])
            end)
            Rayfield:Notify({Title = "Queued!", Content = "Script will auto-run after any teleport.", Duration = 6, Image = "refresh-cw"})
        end
    end,
})

ConfigTab:CreateSection("Appearance")

local ThemeDropdown = ConfigTab:CreateDropdown({
    Name = "Theme",
    Options = {"Determination", "HATE", "Default"},
    CurrentOption = {"Determination"},
    MultipleOptions = false,
    Flag = "SelectedTheme",
    Callback = function(Options)
        local themeName = Options[1] or "Determination"
        local themeValue = ThemeMap[themeName]
        if themeValue then
            Window:ModifyTheme(themeValue)
            Rayfield:Notify({
                Title = "Theme Updated",
                Content = "Switched to " .. themeName .. " (full UI refresh)",
                Duration = 4,
                Image = "palette"
            })
        end
    end,
})

-- =============================================
-- LOAD CONFIG + APPLY PERSISTENT SETTINGS
-- =============================================
Rayfield:LoadConfiguration()

-- Apply saved theme (works even after teleport / re-execute)
if ThemeDropdown.CurrentOption and #ThemeDropdown.CurrentOption > 0 then
    local savedThemeName = ThemeDropdown.CurrentOption[1]
    local savedTheme = ThemeMap[savedThemeName]
    if savedTheme then
        Window:ModifyTheme(savedTheme)
    end
end

-- Auto Execute now persists correctly (queues every time the script runs IF toggled ON)
if AutoExecuteToggle.CurrentValue then
    pcall(function()
        queueFunction([[
            loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()
        ]])
    end)
end
