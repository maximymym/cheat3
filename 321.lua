-- JJSploit-скрипт для Blox Fruits:
-- собирает и показывает уровень, стили, мечи, оружие, фрукты, аксессуары и материалы
-- агрегация одинаковых предметов, вывод в TextBox (Ctrl+A → Ctrl+C)
-- НОВОЕ: отправка данных через HttpGet

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local player            = Players.LocalPlayer

local SERVER_URL = "http://194.59.186.230:3000/api/data"
local PANEL_SHOWN = false

local function createLevelIndicator()
    local indicatorGui = Instance.new("ScreenGui", player.PlayerGui)
    indicatorGui.Name = "LevelIndicatorGui"
    indicatorGui.ResetOnSpawn = false
    local indicator = Instance.new("Frame", indicatorGui)
    indicator.Size = UDim2.new(0, 300, 0, 60)
    indicator.Position = UDim2.new(0.5, -150, 0.33, -30)
    indicator.BackgroundColor3 = Color3.new(0, 0, 0)
    indicator.BackgroundTransparency = 0.3
    indicator.BorderSizePixel = 0
    local corner = Instance.new("UICorner", indicator)
    corner.CornerRadius = UDim.new(0, 8)
    local titleLabel = Instance.new("TextLabel", indicator)
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔄 Автоскрипт активен"
    titleLabel.TextColor3 = Color3.new(0, 1, 0)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    local levelLabel = Instance.new("TextLabel", indicator)
    levelLabel.Size = UDim2.new(1, 0, 0, 35)
    levelLabel.Position = UDim2.new(0, 0, 0, 25)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Загрузка..."
    levelLabel.TextColor3 = Color3.new(1, 1, 1)
    levelLabel.Font = Enum.Font.SourceSans
    levelLabel.TextSize = 22
    levelLabel.TextXAlignment = Enum.TextXAlignment.Center
    levelLabel.TextWrapped = true
    return indicatorGui, levelLabel
end

local function updateLevelIndicator(levelLabel, currentLevel)
    if currentLevel and tonumber(currentLevel) then
        local level = tonumber(currentLevel)
        local needed = 2650
        if level >= needed then
            levelLabel.Text = string.format("🎯 Уровень: %d\n✅ Запуск скрипта!", level)
            levelLabel.TextColor3 = Color3.new(0, 1, 0)
        else
            local remaining = needed - level
            levelLabel.Text = string.format("📊 Уровень: %d / %d\n⏳ Осталось: %d лвл", level, needed, remaining)
            levelLabel.TextColor3 = Color3.new(1, 1, 0)
        end
    else
        levelLabel.Text = "❌ Не удалось получить уровень"
        levelLabel.TextColor3 = Color3.new(1, 0, 0)
    end
end

local function waitForChild(parent, name, timeout)
    timeout = timeout or 10
    local t = 0
    while t < timeout and not parent:FindFirstChild(name) do
        t = t + task.wait()
    end
    return parent:FindFirstChild(name)
end

local function urlEncode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c) 
            return string.format("%%%02X", string.byte(c)) 
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function sendDataToServer(data)
    local success, result = pcall(function()
        local params = {
            "player=" .. urlEncode(player.Name),
            "level=" .. urlEncode(tostring(data.level)),
            "styles=" .. urlEncode(data.styles),
            "swords=" .. urlEncode(data.swords),
            "guns=" .. urlEncode(data.guns),
            "fruits=" .. urlEncode(data.fruits),
            "accessories=" .. urlEncode(data.accessories),
            "materials=" .. urlEncode(data.materials)
        }
        local url = SERVER_URL .. "?" .. table.concat(params, "&")
        local response = game:HttpGet(url, true)
        print("Raw server response:", response)
        local ok, responseData = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if not ok then
            warn("sendDataToServer: invalid JSON, raw response:", response)
            responseData = { raw = response }
        end
        return {
            success = true,
            message = "Данные отправлены успешно!",
            serverResponse = responseData,
            url = url
        }
    end)
    if success then
        return result
    else
        return {
            success = false,
            message = "Ошибка отправки: " .. tostring(result),
            error = result
        }
    end
end

local function showPanelAndScan()
    if PANEL_SHOWN then return end
    PANEL_SHOWN = true
    local indicatorGui = player.PlayerGui:FindFirstChild("LevelIndicatorGui")
    if indicatorGui then indicatorGui:Destroy() end
    local old = player.PlayerGui:FindFirstChild("StatsGui")
    if old then old:Destroy() end
    local statsGui = Instance.new("ScreenGui", player.PlayerGui)
    statsGui.Name = "StatsGui"
    statsGui.ResetOnSpawn = false
    local bg = Instance.new("Frame", statsGui)
    bg.Size = UDim2.new(0, 650, 0, 570)
    bg.Position = UDim2.new(0, 10, 0, 10)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.6
    bg.BorderSizePixel = 0
    local sendButton = Instance.new("TextButton", bg)
    sendButton.Size = UDim2.new(0, 120, 0, 30)
    sendButton.Position = UDim2.new(0, 10, 0, 10)
    sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
    sendButton.TextColor3 = Color3.new(1, 1, 1)
    sendButton.Text = "📤 Отправить"
    sendButton.Font = Enum.Font.SourceSansBold
    sendButton.TextSize = 14
    sendButton.BorderSizePixel = 0
    local statusLabel = Instance.new("TextLabel", bg)
    statusLabel.Size = UDim2.new(0, 500, 0, 30)
    statusLabel.Position = UDim2.new(0, 140, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Text = "Готов к отправке"
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", bg)
    box.Name = "ReportBox"
    box.Size = UDim2.new(1, -20, 1, -60)
    box.Position = UDim2.new(0, 10, 0, 50)
    box.BackgroundColor3 = Color3.new(1, 1, 1)
    box.TextColor3 = Color3.new(0, 0, 0)
    box.TextWrapped = true
    box.ClearTextOnFocus = false
    box.TextEditable = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Text = "Загружается..."
    box.Text = buildReport()
    sendButton.MouseButton1Click:Connect(function()
        statusLabel.Text = "📤 Отправка данных..."
        statusLabel.TextColor3 = Color3.new(1, 1, 0)
        sendButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        sendButton.Text = "⏳ Отправка..."
        if not lastInventoryData then
            statusLabel.Text = "❌ Нет данных для отправки! Обновите инвентарь."
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
            sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
            sendButton.Text = "📤 Отправить"
            return
        end
        local result = sendDataToServer(lastInventoryData)
        if result.success then
            statusLabel.Text = "✅ " .. result.message
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
            sendButton.BackgroundColor3 = Color3.new(0, 1, 0)
            sendButton.Text = "✅ Отправлено"
            task.wait(3)
            sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
            sendButton.Text = "📤 Отправить"
            statusLabel.Text = "Готов к отправке"
            statusLabel.TextColor3 = Color3.new(1, 1, 1)
        else
            statusLabel.Text = "❌ " .. result.message
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
            sendButton.BackgroundColor3 = Color3.new(1, 0, 0)
            sendButton.Text = "❌ Ошибка"
            task.wait(5)
            sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
            sendButton.Text = "📤 Отправить"
            statusLabel.Text = "Готов к отправке"
            statusLabel.TextColor3 = Color3.new(1, 1, 1)
        end
    end)
end

local toggleInv
local function getToggleInv()
    if toggleInv then return toggleInv end
    toggleInv = ReplicatedStorage
        :WaitForChild("Events", 10)
        :WaitForChild("ToggleInventoryWindow", 10)
    return toggleInv
end

local function watchLevelAndRun()
    local data = waitForChild(player, "Data", 15)
    if not data then 
        local indicatorGui, levelLabel = createLevelIndicator()
        levelLabel.Text = "❌ Ошибка получения данных"
        levelLabel.TextColor3 = Color3.new(1, 0, 0)
        return 
    end
    local lvlO = data:FindFirstChild("Level")
    if not lvlO then 
        local indicatorGui, levelLabel = createLevelIndicator()
        levelLabel.Text = "❌ Уровень не найден"
        levelLabel.TextColor3 = Color3.new(1, 0, 0)
        return 
    end
    local indicatorGui, levelLabel = createLevelIndicator()
    updateLevelIndicator(levelLabel, lvlO.Value)
    if tonumber(lvlO.Value) and tonumber(lvlO.Value) >= 2650 then
        task.wait(2)
        showPanelAndScan()
        return
    end
    lvlO:GetPropertyChangedSignal("Value"):Connect(function()
        updateLevelIndicator(levelLabel, lvlO.Value)
        if tonumber(lvlO.Value) and tonumber(lvlO.Value) >= 2650 then
            task.wait(2)
            showPanelAndScan()
        end
    end)
end

task.spawn(function()
    local testGui = Instance.new("ScreenGui", player.PlayerGui)
    testGui.Name = "TestGui"
    testGui.ResetOnSpawn = false
    local testFrame = Instance.new("Frame", testGui)
    testFrame.Size = UDim2.new(0, 200, 0, 50)
    testFrame.Position = UDim2.new(0.5, -100, 0.33, -25)
    testFrame.BackgroundColor3 = Color3.new(1, 0, 0)
    testFrame.BorderSizePixel = 0
    local testLabel = Instance.new("TextLabel", testFrame)
    testLabel.Size = UDim2.new(1, 0, 1, 0)
    testLabel.Position = UDim2.new(0, 0, 0, 0)
    testLabel.BackgroundTransparency = 1
    testLabel.Text = "🔧 ТЕСТ: Скрипт работает!"
    testLabel.TextColor3 = Color3.new(1, 1, 1)
    testLabel.Font = Enum.Font.SourceSansBold
    testLabel.TextSize = 20
    testLabel.TextXAlignment = Enum.TextXAlignment.Center
    task.wait(5)
    testGui:Destroy()
    watchLevelAndRun()
end)

local invGui    = player:WaitForChild("PlayerGui"):WaitForChild("Main")
local scrolling = invGui.InventoryContainer.Right.Content.ScrollingFrame
local frame     = scrolling.Frame
local canvasStep   = 550
local totalPages   = 10
local slotsPerPage = 16

local function getLevel()
    local data = waitForChild(player, "Data", 15)
    local lvlO = data and data:FindFirstChild("Level")
    return lvlO and lvlO.Value or "?"
end

local function getFightingStyles()
    local out = {}
    local function scan(cont)
        for _, tool in ipairs(cont:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name
                if n ~= "Blox Fruit" and not n:lower():find("sword") then
                    table.insert(out, n)
                end
            end
        end
    end
    scan(player.Backpack)
    if player.Character then scan(player.Character) end
    table.sort(out)
    return out
end

local function scanCategoryWithNeighbors(targetCategory)
    local invGui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
    if not invGui then return {} end
    local inventoryContainer = invGui:FindFirstChild("InventoryContainer")
    if not inventoryContainer then return {} end
    local right = inventoryContainer:FindFirstChild("Right")
    if not right then return {} end
    local content = right:FindFirstChild("Content")
    if not content then return {} end
    local scrolling = content:FindFirstChild("ScrollingFrame")
    if not scrolling then return {} end
    local frame = scrolling:FindFirstChild("Frame")
    if not frame then return {} end
    local found = {}
    local uniqueItems = {}
    local invEvent = getToggleInv()
    if invEvent then invEvent:Fire() end
    task.wait(0.5)
    scrolling.CanvasPosition = Vector2.new(0, 0)
    task.wait(0.1)
    for page = 0, totalPages - 1 do
        scrolling.CanvasPosition = Vector2.new(0, canvasStep * page)
        task.wait(0.15)
        for i = 1, slotsPerPage do
            local slot = frame:FindFirstChild(tostring(i))
            if slot and slot:FindFirstChild("Filled") then
                local filled = slot.Filled
                local itemName = "Неизвестный предмет"
                local itemCategory = ""
                local itemCount = 1
                local info = filled:FindFirstChild("ItemInformation")
                if info then
                    local nmObj = info:FindFirstChild("ItemName")
                    if nmObj then
                        itemName = nmObj.Text
                    end
                    local line1Obj = info:FindFirstChild("ItemLine1")
                    if line1Obj then
                        local line1Text = line1Obj.Text or ""
                        if line1Text ~= "" then
                            itemCategory = line1Text
                        end
                    end
                    local counterObj = info:FindFirstChild("Counter")
                    if counterObj then
                        for _, counterChild in ipairs(counterObj:GetChildren()) do
                            if counterChild:IsA("TextLabel") then
                                local counterText = counterChild.Text or ""
                                if counterText ~= "" and counterText:match("%d+") then
                                    itemCount = tonumber(counterText:match("%d+")) or 1
                                    break
                                end
                            end
                        end
                        if counterObj:IsA("TextLabel") then
                            local counterText = counterObj.Text or ""
                            if counterText ~= "" and counterText:match("%d+") then
                                itemCount = tonumber(counterText:match("%d+")) or 1
                            end
                        end
                    end
                    if itemCategory ~= "" then
                        local lowerCategory = itemCategory:lower()
                        if lowerCategory:find("sword") or lowerCategory:find("accessory") or 
                           lowerCategory:find("weapon") or lowerCategory:find("melee") or lowerCategory:find("gun") then
                            itemCount = 1
                        end
                    end
                end
                if itemCategory == "" then
                    for _, sibling in ipairs(filled:GetChildren()) do
                        if sibling ~= info then
                            if sibling:IsA("TextLabel") then
                                local text = sibling.Text or ""
                                if text ~= "" and text ~= itemName then
                                    local lowerText = text:lower()
                                    if lowerText:find("sword") or lowerText:find("gun") or lowerText:find("fruit") or 
                                       lowerText:find("accessory") or lowerText:find("material") or lowerText:find("weapon") then
                                        itemCategory = text
                                    end
                                end
                            end
                            for _, grandchild in ipairs(sibling:GetChildren()) do
                                if grandchild:IsA("TextLabel") then
                                    local gcText = grandchild.Text or ""
                                    if gcText ~= "" and gcText ~= itemName then
                                        local lowerGcText = gcText:lower()
                                        if lowerGcText:find("sword") or lowerGcText:find("gun") or lowerGcText:find("fruit") or 
                                           lowerGcText:find("accessory") or lowerGcText:find("material") or lowerGcText:find("weapon") then
                                            itemCategory = gcText
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                local isMatch = false
                if itemCategory ~= "" then
                    isMatch = itemCategory:lower():find(targetCategory:lower())
                else
                    isMatch = itemName:lower():find(targetCategory:lower())
                end
                if isMatch and itemName ~= "" then
                    local uniqueKey = itemName
                    if not uniqueItems[uniqueKey] then
                        uniqueItems[uniqueKey] = true
                        local itemWithCount = {name = itemName, count = itemCount}
                        table.insert(found, itemWithCount)
                    end
                end
            end
        end
    end
    local invEvent = getToggleInv()
    if invEvent then invEvent:Fire() end
    return found
end

local function aggregate(list)
    local counts = {}
    for _, item in ipairs(list) do
        local name = ""
        local count = 1
        if type(item) == "table" then
            name = item.name
            count = item.count
        else
            name = item
            count = 1
        end
        if counts[name] then
            counts[name] = counts[name] + count
        else
            counts[name] = count
        end
    end
    local out = {}
    for name, cnt in pairs(counts) do
        if cnt > 1 then
            table.insert(out, ("%s ×%d"):format(name, cnt))
        else
            table.insert(out, name)
        end
    end
    table.sort(out)
    return out
end

local function getGuiSwords()      return aggregate(scanCategoryWithNeighbors("sword"))      end
local function getGuiGuns()        return aggregate(scanCategoryWithNeighbors("gun"))        end
local function getGuiFruits()      return aggregate(scanCategoryWithNeighbors("fruit"))      end
local function getGuiAccessories() return aggregate(scanCategoryWithNeighbors("accessory")) end
local function getGuiMaterials()   return aggregate(scanCategoryWithNeighbors("material"))   end

lastInventoryData = nil
local dataSent = false -- флаг для предотвращения повторной отправки
function buildReport()
    local lvl    = getLevel()
    local styles = getFightingStyles()
    local swords = getGuiSwords()
    local guns   = getGuiGuns()
    local fruits = getGuiFruits()
    local accs   = getGuiAccessories()
    local mats   = getGuiMaterials()
    local lines = {
        "=== ИНВЕНТАРЬ ===",
        ("🆙 Уровень: %s"):format(lvl),
        ("🤜 Стили боя: %s"):format(#styles>0 and table.concat(styles, ", ") or "нет"),
        ("🗡 Мечи: %s"):format(#swords>0 and table.concat(swords, ", ") or "нет"),
        ("🔫 Оружие: %s"):format(#guns>0 and table.concat(guns, ", ") or "нет"),
        ("🍉 Фрукты: %s"):format(#fruits>0 and table.concat(fruits, ", ") or "нет"),
        ("👑 Аксессуары: %s"):format(#accs>0 and table.concat(accs, ", ") or "нет"),
        ("🛠 Материалы: %s"):format(#mats>0 and table.concat(mats, ", ") or "нет"),
        "",
        "📤 Данные готовы к отправке на сервер!"
    }
    lastInventoryData = {
        level = lvl,
        styles = #styles>0 and table.concat(styles, ", ") or "нет",
        swords = #swords>0 and table.concat(swords, ", ") or "нет",
        guns = #guns>0 and table.concat(guns, ", ") or "нет",
        fruits = #fruits>0 and table.concat(fruits, ", ") or "нет",
        accessories = #accs>0 and table.concat(accs, ", ") or "нет",
        materials = #mats>0 and table.concat(mats, ", ") or "нет"
    }
    -- Автоматическая отправка данных, если еще не отправляли
    if not dataSent then
        dataSent = true
        task.spawn(function()
            local result = sendDataToServer(lastInventoryData)
            print("[Автоотправка] Результат:", result and result.message or "нет ответа")
        end)
    end
    return table.concat(lines, "\n")
end 
