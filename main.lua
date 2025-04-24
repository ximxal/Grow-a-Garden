-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").GameEvents
local player = Players.LocalPlayer
local backpack = player:FindFirstChild("Backpack")
local remote = ReplicatedStorage:FindFirstChild("Plant_RE")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage.GameEvents
local Player = game.Players.LocalPlayer
local ShecklesCount = Player.leaderstats.Sheckles
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").GameEvents
local player = Players.LocalPlayer
local backpack = player:FindFirstChild("Backpack")
local teleportBackPosition = nil

-- Variables
local autoBuyRobuxSeeds = false
local autoBuyAllSeeds = false
local autoBuySpecificSeed = false
local selectedSeedName = nil
local sellWhenFull = false
local autoSell = false

-- Kavo UI Setup
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Grow A Garden | Ultryn Hub", "DarkTheme")

-- Tabs
local mainTab = Window:NewTab("Farm")
local sellSection = mainTab:NewSection("Selling")


local function teleportAndSell()
    local originalPosition = player.Character and player.Character.HumanoidRootPart.Position
    local tutorialPoint = workspace.Tutorial_Points:FindFirstChild("Tutorial_Point_2")
    
    if tutorialPoint then
        -- Save current position
        teleportBackPosition = originalPosition
        
        -- Teleport to Tutorial Point
        player.Character:SetPrimaryPartCFrame(tutorialPoint.CFrame)
        task.wait(0.1)
        -- Fire the remote to sell
        ReplicatedStorage:FindFirstChild("Sell_Inventory"):FireServer()

        -- Wait 1 second at the sell point
        task.wait(1)  -- Wait for 1 second before teleporting back

        -- Teleport back to the original position
        if teleportBackPosition then
            player.Character:SetPrimaryPartCFrame(CFrame.new(teleportBackPosition))
        end
    end
end

-- Auto Sell based on Backpack Space
task.spawn(function()
    while task.wait() do
        if autoSell then
            local holdableCount = 0
            for _, item in ipairs(backpack:GetChildren()) do
                if item:GetAttribute("ITEM_TYPE") == "Holdable" then
                    holdableCount = holdableCount + 1
                end
            end

            -- Sell When Full (Max Backpack Space)
            if sellWhenFull then
                local notificationUI = player:FindFirstChild("PlayerGui"):FindFirstChild("Top_Notification")
                local notificationFrame = notificationUI and notificationUI:FindFirstChild("Frame")
                local notification = notificationFrame and notificationFrame:FindFirstChild("Notification_UI")
                if notification and notification:GetAttribute("OG") == "Max backpack space! Go sell!" then
                    teleportAndSell()  -- Trigger teleportation and selling
                end
            end
        end
    end
end)

-- Auto Sell every 5 seconds (if not waiting for full)
task.spawn(function()
    while task.wait(5) do
        if autoSell and not sellWhenFull then
            teleportAndSell()  -- Trigger teleportation and selling every 5 seconds
        end
    end
end) 

sellSection:NewButton("Sell Inventory", "Click to sell your inventory", function()
    teleportAndSell()
end)

local mainTab = Window:NewTab("Seeds")
local dupeSection = mainTab:NewSection("Dupe Seeds")
dupeSection:NewButton("Buy/Dupe Robux Seeds", "It can work again when the shop resets.", function()
    for i = 1, 5 do
        ReplicatedStorage.EasterShopService:FireServer("PurchaseSeed", i)
    end
end)
dupeSection:NewToggle("Auto Buy/Dupe Robux Seeds", "It can work again when the shop resets.", function(v)
    autoBuyRobuxSeeds = v
end)

-- Seed Buying Section
local seedSection = mainTab:NewSection("Seed Buying")

-- Function to fetch seed names
local function getAvailableSeedNames()
    local shopUI = player:FindFirstChild("PlayerGui"):FindFirstChild("Seed_Shop")
    if not shopUI then return {} end

    local names = {}
    local scroll = shopUI.Frame.ScrollingFrame
    for _, item in pairs(scroll:GetChildren()) do
        if item:IsA("Frame") and not item.Name:match("_Padding$") then
            table.insert(names, item.Name)
        end
    end
    return names
end

-- Dropdown (placed before toggles)
task.spawn(function()
    repeat task.wait() until player:FindFirstChild("PlayerGui"):FindFirstChild("Seed_Shop")
    local names = getAvailableSeedNames()

    seedSection:NewDropdown("Select Seed", "Choose a seed to auto-buy", names, function(option)
        selectedSeedName = option
    end)

    seedSection:NewToggle("Auto Buy Selected Seed", "Automatically buys only the selected seed", function(v)
        autoBuySpecificSeed = v
    end)

    seedSection:NewToggle("Auto Buy All Seeds", "Automatically buys all seeds that are in stock", function(v)
        autoBuyAllSeeds = v
    end)
end)

-- Auto Buy Function
local function autoBuySeedsFunction()
    local shopUI = player:FindFirstChild("PlayerGui"):FindFirstChild("Seed_Shop")
    if not shopUI then return end

    local scroll = shopUI.Frame.ScrollingFrame
    for _, item in pairs(scroll:GetChildren()) do
        if item:IsA("Frame") and not item.Name:match("_Padding$") then
            local mainFrame = item:FindFirstChild("Main_Frame")
            if mainFrame then
                local stockTextLabel = mainFrame:FindFirstChild("Stock_Text")
                if stockTextLabel then
                    local stock = tonumber(stockTextLabel.Text:match("X(%d+) Stock"))
                    if stock and stock > 0 then
                        if autoBuyAllSeeds then
                            ReplicatedStorage:FindFirstChild("BuySeedStock"):FireServer(item.Name)
                        end
                        if autoBuySpecificSeed and selectedSeedName == item.Name then
                            ReplicatedStorage:FindFirstChild("BuySeedStock"):FireServer(item.Name)
                        end
                    end
                end
            end
        end
    end
end

-- Auto Buy Loop
task.spawn(function()
    while task.wait(0.2) do
        if autoBuyRobuxSeeds then
            for i = 1, 5 do
                ReplicatedStorage.EasterShopService:FireServer("PurchaseSeed", i)
            end
        end

        if autoBuyAllSeeds or (autoBuySpecificSeed and selectedSeedName) then
            autoBuySeedsFunction()
        end
    end
end)


-- Telport Section
local mainTab = Window:NewTab("Telport")
local TelportSection = mainTab:NewSection("Shop Telport")
TelportSection:NewButton("Telport to Seeds Shop", "Telport to Seeds Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(61.5781898, 2.99999976, -27.0039692, 0.0014313946, 5.60769529e-08, -0.999998987, -5.49141939e-12, 1, 5.60770026e-08, 0.999998987, -7.47769069e-11, 0.0014313946)
end)

TelportSection:NewButton("Telport to Sell Shop", "Telport to Sell Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(61.5854721, 2.99999976, 0.426784277, -1.378715e-16, -7.03739573e-08, -1, -9.38462572e-11, 1, -7.03739573e-08, 1, 9.38462572e-11, -1.44475829e-16)
end)

TelportSection:NewButton("Telport to Gear Shop", "Telport to Gear Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-261.908142, 2.99999976, -1.13766003, 0.0191389415, 2.93067259e-08, 0.999816835, 2.4820217e-08, 1, -2.97872145e-08, -0.999816835, 2.53857664e-08, 0.0191389415)
end)

TelportSection:NewButton("Telport to Quest Shop", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-261.800446, 2.99999976, -26.5069656, 0.00727188261, 1.00639088e-08, 0.999973536, -1.91540099e-08, 1, -9.92488491e-09, -0.999973536, -1.90813303e-08, 0.00727188261)
end)

local TelportSection = mainTab:NewSection("Garden Telport")
TelportSection:NewButton("Telport to Garden 1", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Farm.Farm.Spawn_Point.CFrame
end)
TelportSection:NewButton("Telport to Garden 2", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Farm:GetChildren()[6].Spawn_Point.CFrame
end)
TelportSection:NewButton("Telport to Garden 3", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Farm:GetChildren()[2].Spawn_Point.CFrame
end)
TelportSection:NewButton("Telport to Garden 4", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Farm:GetChildren()[3].Spawn_Point.CFrame
end)
TelportSection:NewButton("Telport to Garden 5", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Farm:GetChildren()[4].Spawn_Point.CFrame
end)
TelportSection:NewButton("Telport to Garden 6", "Telport to Quest Shop", function(v)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Farm:GetChildren()[5].Spawn_Point.CFrame
end)
