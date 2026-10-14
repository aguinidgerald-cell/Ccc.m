-- ========================================================
-- 🛒 NEXUS OS - ULTRA DYNAMIC SHOP & PET MARKETPLACE
-- Repository File: shop.lua
-- Features: Full ItemConfig Scraper, Mode Selector (Drop vs Inventory)
-- ========================================================

local NexusOS = getgenv().NexusOS
if not NexusOS then return end

local phoneFrame = NexusOS.phoneFrame
local db = NexusOS.db
local saveDatabase = NexusOS.saveDatabase
local getCurrentUser = NexusOS.getCurrentUser
local showHome = NexusOS.showHome

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Check User Data
local currentUser = getCurrentUser()
if not currentUser or not db.users[currentUser] then return end
local userData = db.users[currentUser]

if not userData.points then userData.points = 500 end
if not userData.genSpeedLvl then userData.genSpeedLvl = 1 end
if not userData.genAmountLvl then userData.genAmountLvl = 1 end
if not userData.inventory then userData.inventory = {} end

-- Remote Events for Dropping
local CoinMarketRE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Coin"):WaitForChild("CoinMarketRE")
local DropRE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PickAndDrop"):WaitForChild("PickAndDropRE")
local ItemConfig = require(ReplicatedStorage.ModuleScripts.ItemConfig)

-- App Main Container
local gameFrame = Instance.new("Frame")
gameFrame.Name = "NexusShopApp"
gameFrame.Size = UDim2.new(1, 0, 1, -40)
gameFrame.Position = UDim2.new(0, 0, 0, 30)
gameFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
gameFrame.ClipsDescendants = true
gameFrame.ZIndex = 51
gameFrame.Parent = phoneFrame

-- HUD Bar (Points & Mode Selector)
local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(1, -20, 0, 52)
hudFrame.Position = UDim2.new(0, 10, 0, 8)
hudFrame.BackgroundColor3 = Color3.fromRGB(22, 28, 44)
hudFrame.ZIndex = 52
hudFrame.Parent = gameFrame
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 8)

local pointsText = Instance.new("TextLabel")
pointsText.Size = UDim2.new(0, 140, 0, 20)
pointsText.Position = UDim2.new(0, 8, 0, 4)
pointsText.BackgroundTransparency = 1
pointsText.TextColor3 = Color3.fromRGB(255, 215, 0)
pointsText.TextSize = 11
pointsText.Font = Enum.Font.GothamBold
pointsText.Text = "💎 POINTS: " .. userData.points
pointsText.TextXAlignment = Enum.TextXAlignment.Left
pointsText.ZIndex = 53
pointsText.Parent = hudFrame

local timerText = Instance.new("TextLabel")
timerText.Size = UDim2.new(0, 140, 0, 16)
timerText.Position = UDim2.new(0, 8, 0, 26)
timerText.BackgroundTransparency = 1
timerText.TextColor3 = Color3.fromRGB(0, 255, 180)
timerText.TextSize = 9
timerText.Font = Enum.Font.Code
timerText.Text = "⏳ Next Drop: 59s"
timerText.TextXAlignment = Enum.TextXAlignment.Left
timerText.ZIndex = 53
timerText.Parent = hudFrame

-- Mode Switcher Button (Drop vs Inventory)
local currentMode = "DROP" -- "DROP" or "INVENTORY"
local modeToggleBtn = Instance.new("TextButton")
modeToggleBtn.Size = UDim2.new(0, 110, 0, 24)
modeToggleBtn.Position = UDim2.new(1, -118, 0, 22)
modeToggleBtn.BackgroundColor3 = Color3.fromRGB(210, 105, 30)
modeToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeToggleBtn.TextSize = 9
modeToggleBtn.Font = Enum.Font.GothamBold
modeToggleBtn.Text = "📦 MODE: AUTO-DROP"
modeToggleBtn.ZIndex = 53
modeToggleBtn.Parent = hudFrame
Instance.new("UICorner", modeToggleBtn).CornerRadius = UDim.new(0, 6)

-- Navigation Tabs
local shopTabBtn = Instance.new("TextButton")
shopTabBtn.Size = UDim2.new(0, 55, 0, 20)
shopTabBtn.Position = UDim2.new(1, -118, 0, 0)
shopTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
shopTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shopTabBtn.TextSize = 8
shopTabBtn.Font = Enum.Font.GothamBold
shopTabBtn.Text = "🛒 SHOP"
shopTabBtn.ZIndex = 53
shopTabBtn.Parent = hudFrame
Instance.new("UICorner", shopTabBtn).CornerRadius = UDim.new(0, 4)

local upgTabBtn = Instance.new("TextButton")
upgTabBtn.Size = UDim2.new(0, 52, 0, 20)
upgTabBtn.Position = UDim2.new(1, -60, 0, 0)
upgTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
upgTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upgTabBtn.TextSize = 8
upgTabBtn.Font = Enum.Font.GothamBold
upgTabBtn.Text = "⚡ UPGRADE"
upgTabBtn.ZIndex = 53
upgTabBtn.Parent = hudFrame
Instance.new("UICorner", upgTabBtn).CornerRadius = UDim.new(0, 4)

-- Search Box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 28)
searchBox.Position = UDim2.new(0, 10, 0, 66)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 32, 50)
searchBox.PlaceholderText = "Search pets / items..."
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 10
searchBox.Font = Enum.Font.Gotham
searchBox.Text = ""
searchBox.ZIndex = 52
searchBox.Parent = gameFrame
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

-- View 1: SHOP CONTAINER (Scrolling Frame)
local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, -20, 1, -135)
shopScroll.Position = UDim2.new(0, 10, 0, 100)
shopScroll.BackgroundTransparency = 1
shopScroll.ScrollBarThickness = 4
shopScroll.ZIndex = 52
shopScroll.Parent = gameFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 135, 0, 50)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.Parent = shopScroll

-- View 2: UPGRADES CONTAINER
local upgContainer = Instance.new("Frame")
upgContainer.Size = UDim2.new(1, -20, 1, -135)
upgContainer.Position = UDim2.new(0, 10, 0, 100)
upgContainer.BackgroundTransparency = 1
upgContainer.Visible = false
upgContainer.ZIndex = 52
upgContainer.Parent = gameFrame

-- Speed Upgrade Box
local speedBox = Instance.new("Frame")
speedBox.Size = UDim2.new(1, 0, 0, 60)
speedBox.Position = UDim2.new(0, 0, 0, 10)
speedBox.BackgroundColor3 = Color3.fromRGB(25, 32, 50)
speedBox.ZIndex = 53
speedBox.Parent = upgContainer
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

local speedLbl = Instance.new("TextLabel")
speedLbl.Size = UDim2.new(0, 160, 0, 25)
speedLbl.Position = UDim2.new(0, 10, 0, 8)
speedLbl.BackgroundTransparency = 1
speedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLbl.TextSize = 10
speedLbl.Font = Enum.Font.GothamBold
speedLbl.Text = "⚡ GENERATOR SPEED"
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.ZIndex = 54
speedLbl.Parent = speedBox

local speedSub = Instance.new("TextLabel")
speedSub.Size = UDim2.new(0, 160, 0, 18)
speedSub.Position = UDim2.new(0, 10, 0, 32)
speedSub.BackgroundTransparency = 1
speedSub.TextColor3 = Color3.fromRGB(0, 220, 255)
speedSub.TextSize = 9
speedSub.Font = Enum.Font.Code
speedSub.Text = "LVL: " .. userData.genSpeedLvl .. " (Faster Timer)"
speedSub.TextXAlignment = Enum.TextXAlignment.Left
speedSub.ZIndex = 54
speedSub.Parent = speedBox

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, 85, 0, 38)
speedBtn.Position = UDim2.new(1, -95, 0, 11)
speedBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextSize = 9
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Text = "UPGRADE\n💎 " .. (userData.genSpeedLvl * 50)
speedBtn.ZIndex = 54
speedBtn.Parent = speedBox
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

-- Amount Upgrade Box
local amountBox = Instance.new("Frame")
amountBox.Size = UDim2.new(1, 0, 0, 60)
amountBox.Position = UDim2.new(0, 0, 0, 80)
amountBox.BackgroundColor3 = Color3.fromRGB(25, 32, 50)
amountBox.ZIndex = 53
amountBox.Parent = upgContainer
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 8)

local amountLbl = Instance.new("TextLabel")
amountLbl.Size = UDim2.new(0, 160, 0, 25)
amountLbl.Position = UDim2.new(0, 10, 0, 8)
amountLbl.BackgroundTransparency = 1
amountLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
amountLbl.TextSize = 10
amountLbl.Font = Enum.Font.GothamBold
amountLbl.Text = "💰 POINTS AMOUNT"
amountLbl.TextXAlignment = Enum.TextXAlignment.Left
amountLbl.ZIndex = 54
amountLbl.Parent = amountBox

local amountSub = Instance.new("TextLabel")
amountSub.Size = UDim2.new(0, 160, 0, 18)
amountSub.Position = UDim2.new(0, 10, 0, 32)
amountSub.BackgroundTransparency = 1
amountSub.TextColor3 = Color3.fromRGB(255, 215, 0)
amountSub.TextSize = 9
amountSub.Font = Enum.Font.Code
amountSub.Text = "LVL: " .. userData.genAmountLvl .. " (+" .. (10 * userData.genAmountLvl) .. " Pts)"
amountSub.TextXAlignment = Enum.TextXAlignment.Left
amountSub.ZIndex = 54
amountSub.Parent = amountBox

local amountBtn = Instance.new("TextButton")
amountBtn.Size = UDim2.new(0, 85, 0, 38)
amountBtn.Position = UDim2.new(1, -95, 0, 11)
amountBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
amountBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
amountBtn.TextSize = 9
amountBtn.Font = Enum.Font.GothamBold
amountBtn.Text = "UPGRADE\n💎 " .. (userData.genAmountLvl * 60)
amountBtn.ZIndex = 54
amountBtn.Parent = amountBox
Instance.new("UICorner", amountBtn).CornerRadius = UDim.new(0, 6)

-- Switch Modes Handler
modeToggleBtn.Activated:Connect(function()
    if currentMode == "DROP" then
        currentMode = "INVENTORY"
        modeToggleBtn.Text = "📦 MODE: TO INVENTORY"
        modeToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
    else
        currentMode = "DROP"
        modeToggleBtn.Text = "📦 MODE: AUTO-DROP"
        modeToggleBtn.BackgroundColor3 = Color3.fromRGB(210, 105, 30)
    end
end)

-- Tab Switch Handler
shopTabBtn.Activated:Connect(function()
    shopScroll.Visible = true
    searchBox.Visible = true
    upgContainer.Visible = false
    shopTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
    upgTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
end)

upgTabBtn.Activated:Connect(function()
    shopScroll.Visible = false
    searchBox.Visible = false
    upgContainer.Visible = true
    upgTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
    shopTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
end)

-- Upgrade Actions
speedBtn.Activated:Connect(function()
    local cost = userData.genSpeedLvl * 50
    if userData.points >= cost and userData.genSpeedLvl < 10 then
        userData.points = userData.points - cost
        userData.genSpeedLvl = userData.genSpeedLvl + 1
        saveDatabase(db)
        pointsText.Text = "💎 POINTS: " .. userData.points
        speedSub.Text = "LVL: " .. userData.genSpeedLvl .. " (Faster Timer)"
        speedBtn.Text = "UPGRADE\n💎 " .. (userData.genSpeedLvl * 50)
    end
end)

amountBtn.Activated:Connect(function()
    local cost = userData.genAmountLvl * 60
    if userData.points >= cost then
        userData.points = userData.points - cost
        userData.genAmountLvl = userData.genAmountLvl + 1
        saveDatabase(db)
        pointsText.Text = "💎 POINTS: " .. userData.points
        amountSub.Text = "LVL: " .. userData.genAmountLvl .. " (+" .. (10 * userData.genAmountLvl) .. " Pts)"
        amountBtn.Text = "UPGRADE\n💎 " .. (userData.genAmountLvl * 60)
    end
end)

-- Dynamic Item Loader from ItemConfig
local loadedItems = {}

local function createShopItemCard(name, id, price)
    if loadedItems[tostring(id)] then return end
    loadedItems[tostring(id)] = true

    local card = Instance.new("Frame")
    card.Name = name:lower()
    card.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
    card.ZIndex = 53
    card.Parent = shopScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -6, 0, 20)
    title.Position = UDim2.new(0, 3, 0, 2)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 8
    title.Font = Enum.Font.GothamBold
    title.Text = name
    title.TextWrapped = true
    title.ZIndex = 54
    title.Parent = card

    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(1, -8, 0, 20)
    buyBtn.Position = UDim2.new(0, 4, 1, -22)
    buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyBtn.TextSize = 8
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.Text = "BUY 💎" .. price
    buyBtn.ZIndex = 54
    buyBtn.Parent = card
    Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 4)

    buyBtn.Activated:Connect(function()
        if userData.points >= price then
            userData.points = userData.points - price
            saveDatabase(db)
            pointsText.Text = "💎 POINTS: " .. userData.points

            if currentMode == "DROP" then
                pcall(function()
                    CoinMarketRE:FireServer("purchase", id, 1)
                    DropRE:FireServer("TakeTool", id, true)
                    DropRE:FireServer("Drop")
                end)
            else
                table.insert(userData.inventory, {name = name, id = id})
                saveDatabase(db)
            end
        end
    end)
end

-- Load from ItemConfig Database
pcall(function()
    for _, item in pairs(ItemConfig.NORMAL_ITEM_LIST or {}) do
        if item and item.Id and item.Name then
            createShopItemCard(item.Name, item.Id, 100)
        end
    end
    for _, goods in pairs(ItemConfig.COLORED_SHOP_GOODS_LIST or {}) do
        if goods and goods.goodsContent and goods.goodsContent.ItemId then
            local itemId = goods.goodsContent.ItemId
            local itemData = ItemConfig:getItemById(tonumber(itemId))
            if itemData and itemData.Id and itemData.Name then
                createShopItemCard("✨ " .. itemData.Name, itemData.Id, 250)
            end
        end
    end
end)

shopScroll.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    shopScroll.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
end)

-- Search Filtering
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = searchBox.Text:lower()
    for _, child in ipairs(shopScroll:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = (query == "" or child.Name:find(query, 1, true)) ~= nil
        end
    end
end)

-- Passive Points Generator Loop
local isAppRunning = true
task.spawn(function()
    while gameFrame and gameFrame.Parent and isAppRunning do
        local maxTime = math.max(10, 59 - (userData.genSpeedLvl * 5))
        for t = maxTime, 0, -1 do
            if not gameFrame or not gameFrame.Parent or not isAppRunning then break end
            timerText.Text = "⏳ Next Drop: " .. t .. "s"
            task.wait(1)
        end

        if gameFrame and gameFrame.Parent and isAppRunning then
            local gained = 10 * userData.genAmountLvl
            userData.points = userData.points + gained
            saveDatabase(db)
            pointsText.Text = "💎 POINTS: " .. userData.points
        end
    end
end)

-- Home Button
local backToHome = Instance.new("TextButton")
backToHome.Size = UDim2.new(1, -40, 0, 26)
backToHome.Position = UDim2.new(0, 20, 1, -32)
backToHome.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
backToHome.TextColor3 = Color3.fromRGB(255, 255, 255)
backToHome.TextSize = 10
backToHome.Font = Enum.Font.GothamBold
backToHome.Text = "🏠 HOME SCREEN"
backToHome.ZIndex = 60
backToHome.Parent = gameFrame
Instance.new("UICorner", backToHome).CornerRadius = UDim.new(0, 8)

backToHome.Activated:Connect(function()
    isAppRunning = false
    gameFrame:Destroy()
    showHome()
end)
