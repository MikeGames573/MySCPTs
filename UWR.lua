local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

JusticePower = 10

local Window = Rayfield:CreateWindow({
   Name = "Undertale: Wave Rush - Ultimate GUI",
   LoadingTitle = "Undertale: Wave Rush - Ultimate Fucker",
   LoadingSubtitle = "by Heli",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "UT WR", -- Create a custom folder for your hub/game
      FileName = "Main Save"
   },
   Discord = {
      Enabled = false,
      Invite = "sirius", -- The Discord invite code, do not include discord.gg/
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Undertale: Wave Rush - Ultimate GUI",
      Subtitle = "Key System",
      Note = "This is a test, the key is 'SUS1010' ",
      FileName = "SiriusKey",
      SaveKey = true,
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = "SUS1010"
   }
})

local Tab = Window:CreateTab("Main", 4483362458)
local Tab2 = Window:CreateTab("Soul Modifiers", 13780996931)

local Section = Tab:CreateSection("Main")

--[[Rayfield:Notify({
   Title = "Notification Title",
   Content = "Notification Content",
   Duration = 6.5,
   Image = 4483362458,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Okay!",
         Callback = function()
         print("The user tapped Okay!")
      end
   },
},
})]]

local Button = Tab:CreateButton({
   Name = "No Cooldown (It includes Kindness Heal)",
   Callback = function()
    local a
    a = hookfunc(wait, function(b) b = nil return a(b) end)
   end,
})

local Section = Tab:CreateSection("TP (Your weapon must be equipped)")

local Button = Tab:CreateButton({
   Name = "Full TP Bar",
   Callback = function()
      local weapon = game:GetService("Players").LocalPlayer.Weapon.Value
      for i = 1, 25 do
         game:GetService("Players").LocalPlayer.Character[weapon].ServerWeapon.DamageEvent:FireServer()
      end
   end,
})

local Keybind = Tab:CreateKeybind({
   Name = "Full TP Bar",
   CurrentKeybind = "L",
   HoldToInteract = false,
   Flag = "Full TP Bar Bind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Keybind)
      local weapon = game:GetService("Players").LocalPlayer.Weapon.Value
      for i = 1, 25 do
         game:GetService("Players").LocalPlayer.Character[weapon].ServerWeapon.DamageEvent:FireServer()
      end
   end,
})

local Section = Tab2:CreateSection("Justice (Justice Power Above 5 will shot it behind you)")

local Slider = Tab2:CreateSlider({
   Name = "Justice Power",
   Range = {0, 1000},
   Increment = 1,
   Suffix = "Justice Spam Power",
   CurrentValue = 10,
   Flag = "JP", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      JusticePower = Value
   end,
})

local Keybind = Tab2:CreateKeybind({
   Name = "Justice Spam (Hold)",
   CurrentKeybind = "H",
   HoldToInteract = true,
   Flag = "Justice Spam", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Keybind)
      game:GetService("Players").LocalPlayer.Character.Justice.ShootEvent:FireServer(JusticePower)
   end,
})

local Section = Tab2:CreateSection("Kindness")


local Keybind = Tab2:CreateKeybind({
   Name = "Heal All",
   CurrentKeybind = "H",
   HoldToInteract = false,
   Flag = "KindHeal", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Keybind)
      local players = game:GetService("Players")
   local args = {[1] = {}}
   for _, player in ipairs(players:GetPlayers()) do
      table.insert(args[1], player.Character.Humanoid)
   end
   players.LocalPlayer.Character.Kindness.HealEvent:FireServer(unpack(args))
   end,
})

local Keybind = Tab2:CreateKeybind({
   Name = "Shield",
   CurrentKeybind = "J",
   HoldToInteract = false,
   Flag = "Shield", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Keybind)
      game:GetService("Players").LocalPlayer.Character.Kindness.ShieldEvent:FireServer()
   end,
})
