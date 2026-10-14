-- ========================================================
-- 🛒 NEXUS MARKETPLACE DIRECTORY (FIXED)
-- Repository File: shop.lua
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

local gameFrame = Instance.new("Frame")
gameFrame.Name = "NexusMarketplaceApp"
gameFrame.Size = UDim2.new(1, 0, 1, -40)
gameFrame.Position = UDim2.new(0, 0, 0, 30)
gameFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
gameFrame.ClipsDescendants = true
gameFrame.ZIndex = 51
gameFrame.Parent = phoneFrame

local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(1, -20, 0, 48)
hudFrame.Position = UDim2.new(0, 10, 0, 8)
hudFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
hudFrame.ZIndex = 52
hudFrame.Parent = gameFrame
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 8)

local pointsText = Instance.new("TextLabel")
pointsText.Size = UDim2.new(0, 130, 0, 18)
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
timerText.Size = UDim2.new(0, 130, 0, 16)
timerText.Position = UDim2.new(0, 8, 0, 24)
timerText.BackgroundTransparency = 1
timerText.TextColor3 = Color3.fromRGB(0, 255, 180)
timerText.TextSize = 9
timerText.Font = Enum.Font.Code
timerText.Text = "⏳ Next Bonus: 59s"
timerText.TextXAlignment = Enum.TextXAlignment.Left
timerText.ZIndex = 53
timerText.Parent = hudFrame

local shopTabBtn = Instance.new("TextButton")
shopTabBtn.Size = UDim2.new(0, 60, 0, 26)
shopTabBtn.Position = UDim2.new(1, -130, 0, 11)
shopTabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
shopTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shopTabBtn.TextSize = 9
shopTabBtn.Font = Enum.Font.GothamBold
shopTabBtn.Text = "📦 DROPPER"
shopTabBtn.ZIndex = 53
shopTabBtn.Parent = hudFrame
Instance.new("UICorner", shopTabBtn).CornerRadius = UDim.new(0, 6)

local upgTabBtn = Instance.new("TextButton")
upgTabBtn.Size = UDim2.new(0, 60, 0, 26)
upgTabBtn.Position = UDim2.new(1, -65, 0, 11)
upgTabBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
upgTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upgTabBtn.TextSize = 9
upgTabBtn.Font = Enum.Font.GothamBold
upgTabBtn.Text = "⚡ UPGRADE"
upgTabBtn.ZIndex = 53
upgTabBtn.Parent = hudFrame
Instance.new("UICorner", upgTabBtn).CornerRadius = UDim.new(0, 6)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 28)
searchBox.Position = UDim2.new(0, 10, 0, 62)
searchBox.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
searchBox.PlaceholderText = "Search Item, Golden, or Rainbow... 🔍"
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 10
searchBox.Font = Enum.Font.Gotham
searchBox.Text = ""
searchBox.ZIndex = 52
searchBox.Parent = gameFrame
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, -20, 1, -130)
shopScroll.Position = UDim2.new(0, 10, 0, 96)
shopScroll.BackgroundTransparency = 1
shopScroll.ScrollBarThickness = 4
shopScroll.ZIndex = 52
shopScroll.Parent = gameFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 135, 0, 48)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.Parent = shopScroll

local upgContainer = Instance.new("Frame")
upgContainer.Size = UDim2.new(1, -20, 1, -130)
upgContainer.Position = UDim2.new(0, 10, 0, 96)
upgContainer.BackgroundTransparency = 1
upgContainer.Visible = false
upgContainer.ZIndex = 52
upgContainer.Parent = gameFrame

local speedBox = Instance.new("Frame")
speedBox.Size = UDim2.new(1, 0, 0, 55)
speedBox.Position = UDim2.new(0, 0, 0, 10)
speedBox.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
speedBox.ZIndex = 53
speedBox.Parent = upgContainer
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

local speedSub = Instance.new("TextLabel")
speedSub.Size = UDim2.new(0, 150, 0, 35)
speedSub.Position = UDim2.new(0, 10, 0, 10)
speedSub.BackgroundTransparency = 1
speedSub.TextColor3 = Color3.fromRGB(0, 220, 255)
speedSub.TextSize = 9
speedSub.Font = Enum.Font.GothamBold
speedSub.Text = "⚡ TIMER SPEED\nLVL: " .. userData.genSpeedLvl
speedSub.TextXAlignment = Enum.TextXAlignment.Left
speedSub.ZIndex = 54
speedSub.Parent = speedBox

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, 80, 0, 32)
speedBtn.Position = UDim2.new(1, -90, 0, 11)
speedBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextSize = 8
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Text = "UPGRADE\n💎 " .. (userData.genSpeedLvl * 50)
speedBtn.ZIndex = 54
speedBtn.Parent = speedBox
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

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

speedBtn.Activated:Connect(function()
    local cost = userData.genSpeedLvl * 50
    if userData.points >= cost and userData.genSpeedLvl < 10 then
        userData.points = userData.points - cost
        userData.genSpeedLvl = userData.genSpeedLvl + 1
        saveDatabase(db)
        pointsText.Text = "💎 BONUS: " .. userData.points
        speedSub.Text = "⚡ TIMER SPEED\nLVL: " .. userData.genSpeedLvl
        speedBtn.Text = "UPGRADE\n💎 " .. (userData.genSpeedLvl * 50)
    end
end)

local function triggerSpawnDrop(id)
    task.spawn(function()
        pcall(CoinMarketRE.FireServer, CoinMarketRE, "purchase", tonumber(id), 1)
        pcall(DropRE.FireServer, DropRE, "TakeTool", tonumber(id), true)
        pcall(DropRE.FireServer, DropRE, "Drop")
    end)
end

local loadedItems = {}

local function createGridCard(name, id, tagType)
    if loadedItems[tostring(id)] then return end
    loadedItems[tostring(id)] = true

    local card = Instance.new("Frame")
    card.Name = name:lower() .. " " .. tagType:lower()
    card.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
    card.ZIndex = 53
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
    label.ZIndex = 54
    label.Parent = card

    if tagType:find("GOLD") then label.TextColor3 = Color3.fromRGB(255, 215, 0)
    elseif tagType:find("RAINBOW") or tagType:find("COLOR") then label.TextColor3 = Color3.fromRGB(255, 100, 255)
    else label.TextColor3 = Color3.fromRGB(230, 230, 230) end

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(1, -8, 0, 18)
    dropBtn.Position = UDim2.new(0, 4, 1, -20)
    dropBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
    dropBtn.Text = "DROP SPAWN 💥"
    dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropBtn.Font = Enum.Font.GothamBold
    dropBtn.TextSize = 8
    dropBtn.ZIndex = 54
    dropBtn.Parent = card
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

    dropBtn.Activated:Connect(function()
        triggerSpawnDrop(id)
        dropBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        dropBtn.Text = "DROPPING..."
        task.wait(0.3)
        dropBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
        dropBtn.Text = "DROP SPAWN 💥"
    end)
end

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

local isAppRunning = true
task.spawn(function()
    while gameFrame and gameFrame.Parent and isAppRunning do
        local maxTime = math.max(10, 59 - (userData.genSpeedLvl * 5))
        for t = maxTime, 0, -1 do
            if not gameFrame or not gameFrame.Parent or not isAppRunning then break end
            timerText.Text = "⏳ Next Bonus: " .. t .. "s"
            task.wait(1)
        end

        if gameFrame and gameFrame.Parent and isAppRunning then
            userData.points = userData.points + (10 * userData.genAmountLvl)
            saveDatabase(db)
            pointsText.Text = "💎 BONUS: " .. userData.points
        end
    end
end)

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
