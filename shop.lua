-- ========================================================
-- 🛒 NEXUS MARKETPLACE DIRECTORY (FULL SCRAPER & SELLER)
-- Repository File: shop.lua
-- Features: Full Item Scraper (Norm/Gold/Rainbow/Color) + Direct Drop + Sell Panel
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

local currentUser = getCurrentUser()
if not currentUser or not db.users[currentUser] then return end
local userData = db.users[currentUser]

if not userData.points then userData.points = 500 end
if not userData.genSpeedLvl then userData.genSpeedLvl = 1 end
if not userData.genAmountLvl then userData.genAmountLvl = 1 end

local CoinMarketRE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Coin"):WaitForChild("CoinMarketRE")
local DropRE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PickAndDrop"):WaitForChild("PickAndDropRE")
local ItemConfig = require(ReplicatedStorage.ModuleScripts.ItemConfig)

-- App Main Frame Container
local gameFrame = Instance.new("Frame")
gameFrame.Name = "NexusMarketplaceApp"
gameFrame.Size = UDim2.new(1, 0, 1, -40)
gameFrame.Position = UDim2.new(0, 0, 0, 30)
gameFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
gameFrame.ClipsDescendants = true
gameFrame.ZIndex = 51
gameFrame.Parent = phoneFrame

-- Top Navigation / Header
local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(1, -20, 0, 48)
hudFrame.Position = UDim2.new(0, 10, 0, 8)
hudFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
hudFrame.ZIndex = 52
hudFrame.Parent = gameFrame
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 8)

local pointsText = Instance.new("TextLabel")
pointsText.Size = UDim2.new(0, 120, 0, 18)
pointsText.Position = UDim2.new(0, 8, 0, 4)
pointsText.BackgroundTransparency = 1
pointsText.TextColor3 = Color3.fromRGB(255, 215, 0)
pointsText.TextSize = 10
pointsText.Font = Enum.Font.GothamBold
pointsText.Text = "💎 BONUS: " .. userData.points
pointsText.TextXAlignment = Enum.TextXAlignment.Left
pointsText.ZIndex = 53
pointsText.Parent = hudFrame

local timerText = Instance.new("TextLabel")
timerText.Size = UDim2.new(0, 120, 0, 16)
timerText.Position = UDim2.new(0, 8, 0, 24)
timerText.BackgroundTransparency = 1
timerText.TextColor3 = Color3.fromRGB(0, 255, 180)
timerText.TextSize = 9
timerText.Font = Enum.Font.Code
timerText.Text = "⏳ Next Bonus: 59s"
timerText.TextXAlignment = Enum.TextXAlignment.Left
timerText.ZIndex = 53
timerText.Parent = hudFrame

-- Mode Tabs (DROPPER vs SELLER)
local shopTabBtn = Instance.new("TextButton")
shopTabBtn.Size = UDim2.new(0, 55, 0, 26)
shopTabBtn.Position = UDim2.new(1, -122, 0, 11)
shopTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
shopTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shopTabBtn.TextSize = 8
shopTabBtn.Font = Enum.Font.GothamBold
shopTabBtn.Text = "📦 DROP"
shopTabBtn.ZIndex = 53
shopTabBtn.Parent = hudFrame
Instance.new("UICorner", shopTabBtn).CornerRadius = UDim.new(0, 6)

local sellTabBtn = Instance.new("TextButton")
sellTabBtn.Size = UDim2.new(0, 55, 0, 26)
sellTabBtn.Position = UDim2.new(1, -62, 0, 11)
sellTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
sellTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sellTabBtn.TextSize = 8
sellTabBtn.Font = Enum.Font.GothamBold
sellTabBtn.Text = "💰 SELL"
sellTabBtn.ZIndex = 53
sellTabBtn.Parent = hudFrame
Instance.new("UICorner", sellTabBtn).CornerRadius = UDim.new(0, 6)

-- PAGE 1: DROPPER SHOP VIEW
local shopContainer = Instance.new("Frame")
shopContainer.Size = UDim2.new(1, 0, 1, -56)
shopContainer.Position = UDim2.new(0, 0, 0, 56)
shopContainer.BackgroundTransparency = 1
shopContainer.ZIndex = 52
shopContainer.Parent = gameFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 28)
searchBox.Position = UDim2.new(0, 10, 0, 6)
searchBox.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
searchBox.PlaceholderText = "Search Item, Golden, or Rainbow... 🔍"
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 10
searchBox.Font = Enum.Font.Gotham
searchBox.Text = ""
searchBox.ZIndex = 53
searchBox.Parent = shopContainer
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, -20, 1, -80)
shopScroll.Position = UDim2.new(0, 10, 0, 40)
shopScroll.BackgroundTransparency = 1
shopScroll.ScrollBarThickness = 4
shopScroll.ZIndex = 53
shopScroll.Parent = shopContainer

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 135, 0, 48)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.Parent = shopScroll

-- PAGE 2: MANUAL SELLER PANEL
local sellContainer = Instance.new("Frame")
sellContainer.Size = UDim2.new(1, 0, 1, -56)
sellContainer.Position = UDim2.new(0, 0, 0, 56)
sellContainer.BackgroundTransparency = 1
sellContainer.Visible = false
sellContainer.ZIndex = 52
sellContainer.Parent = gameFrame

local controlPanel = Instance.new("Frame")
controlPanel.Size = UDim2.new(1, -20, 0, 250)
controlPanel.Position = UDim2.new(0, 10, 0, 10)
controlPanel.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
controlPanel.ZIndex = 53
controlPanel.Parent = sellContainer
Instance.new("UICorner", controlPanel).CornerRadius = UDim.new(0, 8)

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, 0, 0, 30)
panelTitle.Position = UDim2.new(0, 0, 0, 5)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "⚡ INSTANT PET SELLER CONTROL"
panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 10
panelTitle.ZIndex = 54
panelTitle.Parent = controlPanel

local sellNameInput = Instance.new("TextBox")
sellNameInput.Size = UDim2.new(1, -20, 0, 35)
sellNameInput.Position = UDim2.new(0, 10, 0, 40)
sellNameInput.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
sellNameInput.PlaceholderText = "Pet Name (e.g. Dog, Golden Slime)... 🐾"
sellNameInput.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
sellNameInput.Text = ""
sellNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
sellNameInput.Font = Enum.Font.Gotham
sellNameInput.TextSize = 10
sellNameInput.ZIndex = 54
sellNameInput.Parent = controlPanel
Instance.new("UICorner", sellNameInput).CornerRadius = UDim.new(0, 6)

local sellAmountInput = Instance.new("TextBox")
sellAmountInput.Size = UDim2.new(1, -20, 0, 35)
sellAmountInput.Position = UDim2.new(0, 10, 0, 85)
sellAmountInput.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
sellAmountInput.PlaceholderText = "Amount to Sell (e.g. 1, 10, 100)... 🔢"
sellAmountInput.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
sellAmountInput.Text = ""
sellAmountInput.TextColor3 = Color3.fromRGB(0, 255, 100)
sellAmountInput.Font = Enum.Font.GothamBold
sellAmountInput.TextSize = 10
sellAmountInput.ZIndex = 54
sellAmountInput.Parent = controlPanel
Instance.new("UICorner", sellAmountInput).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 9
statusLabel.ZIndex = 54
statusLabel.Parent = controlPanel

local fireSellBtn = Instance.new("TextButton")
fireSellBtn.Size = UDim2.new(1, -20, 0, 40)
fireSellBtn.Position = UDim2.new(0, 10, 0, 165)
fireSellBtn.BackgroundColor3 = Color3.fromRGB(210, 35, 35)
fireSellBtn.Text = "💥 EXECUTE INSTANT SELL 💥"
fireSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fireSellBtn.Font = Enum.Font.GothamBold
fireSellBtn.TextSize = 10
fireSellBtn.ZIndex = 54
fireSellBtn.Parent = controlPanel
Instance.new("UICorner", fireSellBtn).CornerRadius = UDim.new(0, 6)

-- Tab Switch Handler
shopTabBtn.Activated:Connect(function()
    shopContainer.Visible = true
    sellContainer.Visible = false
    shopTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
    sellTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
end)

sellTabBtn.Activated:Connect(function()
    shopContainer.Visible = false
    sellContainer.Visible = true
    sellTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
    shopTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
end)

-- Fast Unthrottled Drop Logic
local function triggerSpawnDrop(id)
    task.spawn(function()
        pcall(CoinMarketRE.FireServer, CoinMarketRE, "purchase", tonumber(id), 1)
        pcall(DropRE.FireServer, DropRE, "TakeTool", tonumber(id), true)
        pcall(DropRE.FireServer, DropRE, "Drop")
    end)
end

-- Data Scraping Engine (Norm, Golden, Rainbow, Color)
local loadedItems = {}

local function createGridCard(name, id, tagType)
    if loadedItems[tostring(id)] then return end
    loadedItems[tostring(id)] = {id = id, name = name, type = tagType}

    local card = Instance.new("Frame")
    card.Name = name:lower() .. " " .. tagType:lower()
    card.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
    card.ZIndex = 54
    card.Parent = shopScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -6, 0, 22)
    label.Position = UDim2.new(0, 3, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = "[" .. tagType .. "] " .. name
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.TextSize = 8
    label.ZIndex = 55
    label.Parent = card

    if tagType:find("GOLD") then
        label.TextColor3 = Color3.fromRGB(255, 215, 0)
    elseif tagType:find("RAINBOW") or tagType:find("COLOR") then
        label.TextColor3 = Color3.fromRGB(255, 100, 255)
    else
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
    end

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(1, -8, 0, 18)
    dropBtn.Position = UDim2.new(0, 4, 1, -20)
    dropBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
    dropBtn.Text = "DROP SPAWN 💥"
    dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropBtn.Font = Enum.Font.GothamBold
    dropBtn.TextSize = 8
    dropBtn.ZIndex = 55
    dropBtn.Parent = card
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

    dropBtn.Activated:Connect(function()
        triggerSpawnDrop(id)
        dropBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        dropBtn.Text = "DROPPING..."
        task.wait(0.2)
        dropBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
        dropBtn.Text = "DROP SPAWN 💥"
    end)
end

-- Populate Items from Module
pcall(function()
    for _, item in pairs(ItemConfig.NORMAL_ITEM_LIST or {}) do
        if item and item.Id then createGridCard(item.Name or "Item", item.Id, "NORM") end
    end
    for _, goods in pairs(ItemConfig.COLORED_SHOP_GOODS_LIST or {}) do
        if goods and goods.goodsContent and goods.goodsContent.ItemId then
            local itemId = goods.goodsContent.ItemId
            local itemData = ItemConfig:getItemById(tonumber(itemId))
            if itemData and itemData.Id then createGridCard(itemData.Name or "Colored Item", itemData.Id, "COLOR") end
        end
    end

    local ranges = {
        {min = 1, max = 600, tag = "NORM"},
        {min = 20000, max = 20600, tag = "GOLDEN"},
        {min = 30000, max = 30600, tag = "RAINBOW"}
    }

    task.spawn(function()
        for _, range in ipairs(ranges) do
            for i = range.min, range.max do
                pcall(function()
                    local rawItem = ItemConfig:getItemById(i)
                    if rawItem and rawItem.Id and not loadedItems[tostring(rawItem.Id)] then
                        local currentTag = range.tag
                        if rawItem.Name and rawItem.Name:lower():find("gold") then currentTag = "GOLDEN"
                        elseif rawItem.Name and rawItem.Name:lower():find("rainbow") then currentTag = "RAINBOW" end
                        createGridCard(rawItem.Name or ("Pet #" .. tostring(i)), rawItem.Id, currentTag)
                    end
                end)
            end
            task.wait(0.01)
        end
    end)
end)

shopScroll.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    shopScroll.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = searchBox.Text:lower()
    for _, child in ipairs(shopScroll:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = (query == "" or child.Name:find(query, 1, true)) ~= nil
        end
    end
end)

-- Execute Sell Action Logic
fireSellBtn.Activated:Connect(function()
    local rawQuery = sellNameInput.Text:lower()
    local sellAmount = tonumber(sellAmountInput.Text) or 1

    if rawQuery == "" then
        statusLabel.Text = "❌ Error: Type a pet name!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end

    local targetType = nil
    if rawQuery:find("norm") or rawQuery:find("normal") then targetType = "NORM" rawQuery = rawQuery:gsub("normal", ""):gsub("norm", "")
    elseif rawQuery:find("color") or rawQuery:find("colored") then targetType = "COLOR" rawQuery = rawQuery:gsub("colored", ""):gsub("color", "")
    elseif rawQuery:find("gold") or rawQuery:find("golden") then targetType = "GOLDEN" rawQuery = rawQuery:gsub("golden", ""):gsub("gold", "")
    elseif rawQuery:find("rain") or rawQuery:find("rainbow") then targetType = "RAINBOW" rawQuery = rawQuery:gsub("rainbow", ""):gsub("rain", "") end

    local petName = rawQuery:match("^%s*(.-)%s*$")
    local bestMatch = nil

    if targetType then
        for id, data in pairs(loadedItems) do
            if data.name:lower() == petName and data.type == targetType then bestMatch = data break end
        end
    else
        for id, data in pairs(loadedItems) do
            if data.name:lower() == petName and data.type == "NORM" then bestMatch = data break end
        end
        if not bestMatch then
            for id, data in pairs(loadedItems) do
                if data.name:lower() == petName and data.type == "COLOR" then bestMatch = data break end
            end
        end
    end

    if not bestMatch then
        for id, data in pairs(loadedItems) do
            if data.name:lower():find(petName, 1, true) then
                if targetType and data.type == targetType then bestMatch = data break
                elseif not targetType and data.type == "NORM" then bestMatch = data break end
            end
        end
    end

    if bestMatch then
        statusLabel.Text = "🔄 Selling: [" .. bestMatch.type .. "] " .. bestMatch.name .. " x" .. tostring(sellAmount) .. "..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

        pcall(function()
            CoinMarketRE:FireServer("sell", tonumber(bestMatch.id), sellAmount)
        end)

        task.wait(0.3)
        statusLabel.Text = "✅ Success: Sold " .. bestMatch.name .. " (ID: " .. tostring(bestMatch.id) .. ")"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        statusLabel.Text = "❌ Error: Pet not found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- Passive Point Timer Loop
local isAppRunning = true
task.spawn(function()
    while gameFrame and gameFrame.Parent and isAppRunning do
        local maxTime = math.max(10, 59 - (userData.genSpeedLvl * 5))
        for t = maxTime, 0, -1 do
            if not gameFrame or not gameFrame.Parent or not isAppRunning then break end
            timerText.Text = "⏳ Next Bonus: " .. t .. "s"
            task.wait(1)
        end

        if gameFrame and gameFrame.Parent and isAppRunning do
            userData.points = userData.points + (10 * userData.genAmountLvl)
            saveDatabase(db)
            pointsText.Text = "💎 BONUS: " .. userData.points
        end
    end
end)

-- Navigation Home
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
    
