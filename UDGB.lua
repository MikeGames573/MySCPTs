local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =============================================
-- CUSTOM THEMES (super easy to extend!)
-- Just add a new entry to the Themes table below.
-- Custom themes = full table, built-in themes = string name.
-- =============================================
local BaseTheme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(34, 34, 34),
    Shadow = Color3.fromRGB(20, 20, 20),
    NotificationBackground = Color3.fromRGB(20, 20, 20),
    NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
    TabBackground = Color3.fromRGB(80, 80, 80),
    TabStroke = Color3.fromRGB(85, 85, 85),
    TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
    TabTextColor = Color3.fromRGB(240, 240, 240),
    SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
    ElementStroke = Color3.fromRGB(50, 50, 50),
    SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
            
    SliderBackground = Color3.fromRGB(50, 138, 220),
    SliderProgress = Color3.fromRGB(50, 138, 220),
    SliderStroke = Color3.fromRGB(58, 163, 255),
    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(0, 146, 214),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
    ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
    ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
    ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
    DropdownSelected = Color3.fromRGB(40, 40, 40),
    DropdownUnselected = Color3.fromRGB(30, 30, 30),
    InputBackground = Color3.fromRGB(30, 30, 30),
    InputStroke = Color3.fromRGB(65, 65, 65),
    PlaceholderColor = Color3.fromRGB(178, 178, 178)
}

local DeterminationTheme = table.clone(BaseTheme)
DeterminationTheme.SliderBackground = Color3.fromRGB(150, 0, 0)
DeterminationTheme.SliderProgress = Color3.fromRGB(150, 0, 0)
DeterminationTheme.SliderStroke = Color3.fromRGB(200, 50, 50)
DeterminationTheme.ToggleEnabled = Color3.fromRGB(150, 0, 0)
DeterminationTheme.ToggleEnabledStroke = Color3.fromRGB(200, 50, 50)

local HATETheme = table.clone(BaseTheme)
HATETheme.SliderBackground = Color3.fromRGB(90, 0, 140)
HATETheme.SliderProgress = Color3.fromRGB(90, 0, 140)
HATETheme.SliderStroke = Color3.fromRGB(130, 30, 180)
HATETheme.ToggleEnabled = Color3.fromRGB(90, 0, 140)
HATETheme.ToggleEnabledStroke = Color3.fromRGB(130, 30, 180)

local Themes = {
    Determination = DeterminationTheme,
    HATE = HATETheme,
    Default = "Default",
    AmberGlow = "AmberGlow",
    Amethyst = "Amethyst",
    Bloom = "Bloom",
    DarkBlue = "DarkBlue",
    Green = "Green",
    Light = "Light",
    Ocean = "Ocean",
    Serenity = "Serenity",
}

-- Create window with Determination as DEFAULT theme
local Window = Rayfield:CreateWindow({
    Name = "SpellForge Hub",
    Icon = 0,
    LoadingTitle = "SpellForge Hub",
    LoadingSubtitle = "Advanced Spell Tools",
    Theme = Themes.Determination, -- Determination is now the default
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
-- CONFIG TAB
-- =============================================
ConfigTab:CreateSection("Script Settings")

local queueFunction = queue_on_teleport or (syn and syn.queue_on_teleport) or function() end

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

-- Dynamic theme list (add more in the Themes table above and it auto-appears here)
local themeOptions = {}
for themeName in pairs(Themes) do
    table.insert(themeOptions, themeName)
end
table.sort(themeOptions)

local ThemeDropdown = ConfigTab:CreateDropdown({
    Name = "UI Theme",
    Options = themeOptions,
    CurrentOption = {"Determination"},
    MultipleOptions = false,
    Flag = "SelectedTheme",
    Callback = function(Options)
        local selected = Options[1]
        if Themes[selected] then
            Window:ModifyTheme(Themes[selected])
            Rayfield:Notify({
                Title = "Theme Changed",
                Content = "Switched to " .. selected .. " (beautifully organized & clean)",
                Duration = 3,
                Image = "palette"
            })
        end
    end,
})

-- =============================================
-- FINAL CONFIG LOADING + AUTO-EXECUTE FIX
-- =============================================
Rayfield:LoadConfiguration()

-- Apply saved theme after config loads (so it persists across teleports)
local savedThemeName = ThemeDropdown.CurrentOption and ThemeDropdown.CurrentOption[1] or "Determination"
if Themes[savedThemeName] then
    Window:ModifyTheme(Themes[savedThemeName])
end

-- Auto Execute now ALWAYS works when toggled on
-- (even after teleport — the toggle state is saved and re-queues instantly)
if AutoExecuteToggle.CurrentValue then
    pcall(function()
        queueFunction([[
            loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()
        ]])
    end)
end
