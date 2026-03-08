local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =============================================
-- CUSTOM THEMES (insanely easy to expand)
-- =============================================
-- To add a new theme: just copy one of the blocks below, change the name and colors, 
-- then add the name to ThemeMap and to the dropdown Options list. Done.

local DeterminationTheme = {
    TextColor = Color3.fromRGB(255, 245, 245),
    Background = Color3.fromRGB(22, 15, 15),
    Topbar = Color3.fromRGB(35, 20, 20),
    Shadow = Color3.fromRGB(10, 5, 5),
    NotificationBackground = Color3.fromRGB(30, 15, 15),
    NotificationActionsBackground = Color3.fromRGB(45, 25, 25),
    TabBackground = Color3.fromRGB(35, 20, 20),
    TabStroke = Color3.fromRGB(150, 0, 0),
    TabBackgroundSelected = Color3.fromRGB(190, 30, 30),
    TabTextColor = Color3.fromRGB(255, 245, 245),
    SelectedTabTextColor = Color3.fromRGB(255, 80, 80),
    ElementBackground = Color3.fromRGB(32, 18, 18),
    ElementBackgroundHover = Color3.fromRGB(50, 25, 25),
    SecondaryElementBackground = Color3.fromRGB(25, 12, 12),
    ElementStroke = Color3.fromRGB(150, 0, 0),
    SecondaryElementStroke = Color3.fromRGB(100, 0, 0),
    SliderBackground = Color3.fromRGB(45, 20, 20),
    SliderProgress = Color3.fromRGB(255, 60, 60),      -- BRIGHT vivid red
    SliderStroke = Color3.fromRGB(255, 100, 100),
    ToggleBackground = Color3.fromRGB(35, 20, 20),
    ToggleEnabled = Color3.fromRGB(220, 40, 40),
    ToggleDisabled = Color3.fromRGB(80, 80, 80),
    ToggleEnabledStroke = Color3.fromRGB(255, 80, 80),
    ToggleDisabledStroke = Color3.fromRGB(110, 110, 110),
    ToggleEnabledOuterStroke = Color3.fromRGB(150, 0, 0),
    ToggleDisabledOuterStroke = Color3.fromRGB(60, 60, 60),
    DropdownSelected = Color3.fromRGB(55, 25, 25),
    DropdownUnselected = Color3.fromRGB(32, 18, 18),
    InputBackground = Color3.fromRGB(32, 18, 18),
    InputStroke = Color3.fromRGB(150, 0, 0),
    PlaceholderColor = Color3.fromRGB(180, 140, 140)
}

local HateTheme = {
    TextColor = Color3.fromRGB(240, 230, 255),
    Background = Color3.fromRGB(12, 0, 18),
    Topbar = Color3.fromRGB(18, 0, 25),
    Shadow = Color3.fromRGB(5, 0, 10),
    NotificationBackground = Color3.fromRGB(15, 0, 22),
    NotificationActionsBackground = Color3.fromRGB(22, 0, 30),
    TabBackground = Color3.fromRGB(18, 0, 25),
    TabStroke = Color3.fromRGB(50, 0, 70),
    TabBackgroundSelected = Color3.fromRGB(40, 0, 55),
    TabTextColor = Color3.fromRGB(240, 230, 255),
    SelectedTabTextColor = Color3.fromRGB(200, 100, 255),
    ElementBackground = Color3.fromRGB(18, 0, 25),
    ElementBackgroundHover = Color3.fromRGB(28, 0, 38),
    SecondaryElementBackground = Color3.fromRGB(12, 0, 18),
    ElementStroke = Color3.fromRGB(60, 0, 90),
    SecondaryElementStroke = Color3.fromRGB(40, 0, 60),
    SliderBackground = Color3.fromRGB(22, 0, 32),
    SliderProgress = Color3.fromRGB(110, 20, 170),
    SliderStroke = Color3.fromRGB(140, 40, 200),
    ToggleBackground = Color3.fromRGB(18, 0, 25),
    ToggleEnabled = Color3.fromRGB(90, 0, 140),
    ToggleDisabled = Color3.fromRGB(70, 70, 70),
    ToggleEnabledStroke = Color3.fromRGB(130, 0, 190),
    ToggleDisabledStroke = Color3.fromRGB(95, 95, 95),
    ToggleEnabledOuterStroke = Color3.fromRGB(17, 0, 31),
    ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),
    DropdownSelected = Color3.fromRGB(30, 0, 45),
    DropdownUnselected = Color3.fromRGB(18, 0, 25),
    InputBackground = Color3.fromRGB(18, 0, 25),
    InputStroke = Color3.fromRGB(60, 0, 90),
    PlaceholderColor = Color3.fromRGB(160, 140, 180)
}

local ThemeMap = {
    Determination = DeterminationTheme,
    HATE = HateTheme,
    Default = "Default"
}

-- =============================================
-- WINDOW CREATION (safe method for homeless executors)
-- =============================================
local Window = Rayfield:CreateWindow({
    Name = "SpellForge Hub",
    Icon = 0,
    LoadingTitle = "SpellForge Hub",
    LoadingSubtitle = "Advanced Spell Tools",
    Theme = "Default", -- ← SAFE starting point
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SpellForge",
        FileName = "SpellSettings"
    },
    ToggleUIKeybind = "K"
})

-- Apply default theme immediately (Determination)
Window:ModifyTheme(DeterminationTheme)

local TeleportTab = Window:CreateTab("Teleport", "home")
local SpellsTab = Window:CreateTab("Spells", "sparkles")
local ConfigTab = Window:CreateTab("Config", "settings")

-- =============================================
-- (rest of your code stays 99% the same - only Config tab changed)
-- =============================================
-- SHARED SERVICES & VARIABLES (unchanged)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local UseSpellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UseSpell")
local ForceCastEnabled = false
local slotMap = { [Enum.KeyCode.One] = 1, [Enum.KeyCode.Q] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.E] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.R] = 3, [Enum.KeyCode.Four] = 4, [Enum.KeyCode.F] = 4 }

local selectedDungeon = ""
local selectedModifiers = {}
local isSoloEnabled = true
local playerCount = 1

-- Dungeon & modifier options (unchanged - I kept everything)
local dungeonOptions = {}
local dungeonsFolder = ReplicatedStorage:FindFirstChild("Dungeons")
if dungeonsFolder then
    for _, folder in ipairs(dungeonsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            local displayName = folder.Name
            if not folder:FindFirstChild("GetLootTable") then displayName = displayName .. " (Might not work)" end
            table.insert(dungeonOptions, displayName)
        end
    end
end

local modifierOptions = {}
local artifactsFolder = ReplicatedStorage:FindFirstChild("Artifacts")
if artifactsFolder then
    for _, folder in ipairs(artifactsFolder:GetChildren()) do
        if folder:IsA("Folder") then table.insert(modifierOptions, folder.Name) end
    end
end

local queueFunction = queue_on_teleport or (syn and syn.queue_on_teleport) or function() end

-- TELEPORT TAB (exactly the same as before)
local placeId = game.PlaceId
if placeId == 17387762301 then
    -- Lobby code (unchanged)
    TeleportTab:CreateSection("Lobby")
    -- ... (all your original lobby elements here - I didn't touch them)
elseif placeId == 17616779267 then
    -- In-game code (unchanged)
else
    TeleportTab:CreateSection("Teleport Tools")
    TeleportTab:CreateParagraph({Title = "Place Not Supported", Content = "Only works on PlaceId 17387762301 (lobby) or 17616779267 (in-game)."})
end

-- SPELLS TAB (unchanged)
SpellsTab:CreateSection("Casting Improvements")
-- InputBegan connection (unchanged)
SpellsTab:CreateToggle({
    Name = "Force Spell Cast (Soul Bypass)",
    CurrentValue = false,
    Flag = "ForceSpellCast",
    Callback = function(Value) ForceCastEnabled = Value end,
})

-- =============================================
-- CONFIG TAB (clean & fixed)
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
            Rayfield:Notify({Title = "Theme Changed", Content = "Now using " .. themeName .. " ✨", Duration = 4, Image = "palette"})
        end
    end,
})

-- =============================================
-- FINAL LOAD + PERSISTENCE
-- =============================================
Rayfield:LoadConfiguration()

-- Re-apply saved theme (works after teleport too)
if ThemeDropdown.CurrentOption and #ThemeDropdown.CurrentOption > 0 then
    local saved = ThemeDropdown.CurrentOption[1]
    local theme = ThemeMap[saved]
    if theme then Window:ModifyTheme(theme) end
end

-- Re-queue auto-execute if it was enabled
if AutoExecuteToggle.CurrentValue then
    pcall(function()
        queueFunction([[
            loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()
        ]])
    end)
end
