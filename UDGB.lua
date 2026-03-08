local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =============================================
-- THEMES LIBRARY (super easy to add more!)
-- Just copy one block, change the name and colors, then add the name to themeList below.
-- No other code changes needed. Clean & efficient.
-- =============================================
local Themes = {
    Determination = {
        TextColor = Color3.fromRGB(255, 240, 240),
        Background = Color3.fromRGB(45, 22, 22),      -- Much brighter than before
        Topbar = Color3.fromRGB(65, 28, 28),
        Shadow = Color3.fromRGB(25, 8, 8),
        NotificationBackground = Color3.fromRGB(55, 25, 25),
        NotificationActionsBackground = Color3.fromRGB(75, 35, 35),
        TabBackground = Color3.fromRGB(55, 25, 25),
        TabStroke = Color3.fromRGB(95, 35, 35),
        TabBackgroundSelected = Color3.fromRGB(200, 45, 45),
        TabTextColor = Color3.fromRGB(255, 230, 230),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(60, 28, 28),
        ElementBackgroundHover = Color3.fromRGB(75, 35, 35),
        SecondaryElementBackground = Color3.fromRGB(40, 18, 18),
        ElementStroke = Color3.fromRGB(110, 40, 40),
        SecondaryElementStroke = Color3.fromRGB(75, 30, 30),
        SliderBackground = Color3.fromRGB(70, 30, 30),
        SliderProgress = Color3.fromRGB(210, 55, 55),
        SliderStroke = Color3.fromRGB(235, 80, 80),
        ToggleBackground = Color3.fromRGB(50, 22, 22),
        ToggleEnabled = Color3.fromRGB(190, 40, 40),
        ToggleDisabled = Color3.fromRGB(95, 40, 40),
        ToggleEnabledStroke = Color3.fromRGB(225, 70, 70),
        ToggleDisabledStroke = Color3.fromRGB(120, 50, 50),
        ToggleEnabledOuterStroke = Color3.fromRGB(255, 110, 110),
        ToggleDisabledOuterStroke = Color3.fromRGB(70, 30, 30),
        DropdownSelected = Color3.fromRGB(180, 20, 20),
        DropdownUnselected = Color3.fromRGB(50, 22, 22),
        InputBackground = Color3.fromRGB(50, 22, 22),
        InputStroke = Color3.fromRGB(100, 40, 40),
        PlaceholderColor = Color3.fromRGB(200, 130, 130)
    },
    HATE = {
        TextColor = Color3.fromRGB(230, 210, 255),
        Background = Color3.fromRGB(12, 5, 22),
        Topbar = Color3.fromRGB(22, 8, 32),
        Shadow = Color3.fromRGB(5, 0, 12),
        NotificationBackground = Color3.fromRGB(20, 8, 30),
        NotificationActionsBackground = Color3.fromRGB(35, 12, 45),
        TabBackground = Color3.fromRGB(25, 8, 35),
        TabStroke = Color3.fromRGB(45, 12, 55),
        TabBackgroundSelected = Color3.fromRGB(85, 0, 130),
        TabTextColor = Color3.fromRGB(240, 200, 255),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(22, 8, 30),
        ElementBackgroundHover = Color3.fromRGB(32, 12, 42),
        SecondaryElementBackground = Color3.fromRGB(12, 5, 22),
        ElementStroke = Color3.fromRGB(55, 15, 70),
        SecondaryElementStroke = Color3.fromRGB(35, 10, 50),
        SliderBackground = Color3.fromRGB(32, 12, 42),
        SliderProgress = Color3.fromRGB(110, 0, 160),
        SliderStroke = Color3.fromRGB(140, 20, 190),
        ToggleBackground = Color3.fromRGB(18, 7, 27),
        ToggleEnabled = Color3.fromRGB(95, 0, 145),
        ToggleDisabled = Color3.fromRGB(60, 25, 70),
        ToggleEnabledStroke = Color3.fromRGB(125, 15, 175),
        ToggleDisabledStroke = Color3.fromRGB(80, 35, 90),
        ToggleEnabledOuterStroke = Color3.fromRGB(155, 35, 200),
        ToggleDisabledOuterStroke = Color3.fromRGB(45, 15, 55),
        DropdownSelected = Color3.fromRGB(17, 0, 31),
        DropdownUnselected = Color3.fromRGB(22, 8, 30),
        InputBackground = Color3.fromRGB(18, 7, 27),
        InputStroke = Color3.fromRGB(55, 15, 70),
        PlaceholderColor = Color3.fromRGB(160, 110, 200)
    }
    -- ADD NEW THEME HERE ↓ (copy-paste the block above and change name + colors)
    -- ExampleNew = { ... your colors ... },
}

local themeList = {"Determination", "HATE"} -- Add new theme name here to show in dropdown (order matters)

local Window = Rayfield:CreateWindow({
    Name = "SpellForge Hub v1.4",
    Icon = 0,
    LoadingTitle = "SpellForge Hub",
    LoadingSubtitle = "Advanced Spell Tools",
    Theme = Themes.Determination, -- Default = Determination (now much brighter!)
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
-- SHARED SERVICES & VARIABLES (unchanged)
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

local selectedDungeon = ""
local selectedModifiers = {}
local isSoloEnabled = true
local playerCount = 1

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
-- TELEPORT TAB (unchanged)
-- =============================================
local placeId = game.PlaceId
if placeId == 17387762301 then
    TeleportTab:CreateSection("Lobby")
    TeleportTab:CreateDropdown({
        Name = "Dungeons",
        Options = dungeonOptions,
        CurrentOption = dungeonOptions[1] and {dungeonOptions[1]} or {},
        MultipleOptions = false,
        Flag = "DungeonsDropdown",
        Callback = function(Options)
            selectedDungeon = (Options[1] or ""):gsub(" %(Might not work%)", "")
        end,
    })
    TeleportTab:CreateToggle({ Name = "Is Solo", CurrentValue = true, Flag = "IsSolo", Callback = function(Value) isSoloEnabled = Value end })
    TeleportTab:CreateDropdown({
        Name = "Modifiers (Warning: Doesn't work for every dungeon)",
        Options = modifierOptions,
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "ModifiersDropdown",
        Callback = function(Options) selectedModifiers = Options end,
    })
    TeleportTab:CreateButton({ Name = "Start Dungeon", Callback = function()
        if selectedDungeon == "" then
            Rayfield:Notify({Title = "Error", Content = "Select a dungeon first!", Duration = 5, Image = "alert-triangle"})
            return
        end
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StartDungeon"):FireServer(selectedDungeon, isSoloEnabled, selectedModifiers or {})
        Rayfield:Notify({Title = "Dungeon Started", Content = "Launching " .. selectedDungeon, Duration = 5, Image = "play"})
    end})
elseif placeId == 17616779267 then
    TeleportTab:CreateSection("In-game")
    TeleportTab:CreateButton({
        Name = "Rejoin (New Server)",
        Callback = function()
            Rayfield:Notify({Title = "Joining Fresh Server", Content = "Forcing a completely new server...", Duration = 5, Image = "refresh-cw"})
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
        Flag = "DungeonsDropdown",
        Callback = function(Options)
            selectedDungeon = (Options[1] or ""):gsub(" %(Might not work%)", "")
        end,
    })
    TeleportTab:CreateSlider({ Name = "Player Count", Range = {1, 4}, Increment = 1, CurrentValue = 1, Flag = "PlayerCount", Callback = function(Value) playerCount = Value end })
    TeleportTab:CreateDropdown({
        Name = "Modifiers (Warning: Doesn't work for every dungeon)",
        Options = modifierOptions,
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "ModifiersDropdown",
        Callback = function(Options) selectedModifiers = Options end,
    })
    TeleportTab:CreateButton({ Name = "Set Dungeon", Callback = function()
        if selectedDungeon == "" then
            Rayfield:Notify({Title = "Error", Content = "Select a dungeon first!", Duration = 5, Image = "alert-triangle"})
            return
        end
        ReplicatedStorage:WaitForChild("SetDungeon"):FireServer({selectedDungeon, playerCount, selectedModifiers or {}})
        Rayfield:Notify({Title = "Dungeon Set", Content = "Sent: " .. selectedDungeon .. " (" .. playerCount .. " players)", Duration = 5, Image = "play"})
    end})
else
    TeleportTab:CreateSection("Teleport Tools")
    TeleportTab:CreateParagraph({Title = "Place Not Supported", Content = "Only works on PlaceId 17387762301 (lobby) or 17616779267 (in-game)."})
end

-- =============================================
-- SPELLS TAB (unchanged)
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
    if spellObj then UseSpellRemote:FireServer(spellObj) end
end)
SpellsTab:CreateToggle({
    Name = "Force Spell Cast (Soul Bypass)",
    CurrentValue = false,
    Flag = "ForceSpellCast",
    Callback = function(Value)
        ForceCastEnabled = Value
        if Value then Rayfield:Notify({Title = "Force Spell Cast", Content = "Soul requirements bypassed.\nUse 1/Q • 2/E • 3/R • 4/F", Duration = 5, Image = "zap"}) end
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
        if Value then
            pcall(function() queueFunction([[loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()]]) end)
            Rayfield:Notify({Title = "Queued!", Content = "Script will auto-run after any teleport.", Duration = 6, Image = "refresh-cw"})
        end
    end,
})

ConfigTab:CreateSection("Themes")
local ThemesDropdown = ConfigTab:CreateDropdown({
    Name = "UI Theme",
    Options = themeList,
    CurrentOption = {"Determination"},
    MultipleOptions = false,
    Flag = "SelectedTheme",
    Callback = function(Options)
        local selected = Options[1]
        if Themes[selected] then
            Window.ModifyTheme(Themes[selected]) -- Fixed: dot notation + table support (now works live)
            Rayfield:Notify({Title = "Theme Changed", Content = selected .. " theme applied.", Duration = 4, Image = "palette"})
        end
    end,
})

Rayfield:LoadConfiguration()

-- =============================================
-- POST-LOAD FIXES
-- =============================================
-- Apply saved theme correctly on script start
if Rayfield.Flags.SelectedTheme then
    local saved = Rayfield.Flags.SelectedTheme[1]
    if Themes[saved] then
        Window.ModifyTheme(Themes[saved])
    end
end

-- Auto Execute now always re-queues on every run if enabled (persistent across teleports)
if Rayfield.Flags.AutoExecuteTeleport then
    pcall(function()
        queueFunction([[loadstring(game:HttpGet('https://raw.githubusercontent.com/MikeGames573/MySCPTs/refs/heads/main/UDGB.lua'))()]])
    end)
end
