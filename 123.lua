-- JJSploit-скрипт для Blox Fruits с дебагом:
-- собирает и показывает уровень, стили, мечи, оружие, фрукты, аксессуары и материалы
-- агрегация одинаковых предметов, вывод в TextBox (Ctrl+A → Ctrl+C)
-- ДЕБАГ ВЕРСИЯ: поиск категорий в соседних лейблах + детальная отладка
-- НОВОЕ: отправка данных через HttpGet

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local player            = Players.LocalPlayer

-- Настройки сервера (IP сервера)
local SERVER_URL = "http://194.59.186.230:3000/api/data"

-- === АВТОМАТИЧЕСКИЙ ЗАПУСК ПО ДОСТИЖЕНИЮ 2650 ЛВЛ ===
local PANEL_SHOWN = false

-- Создаём индикатор уровня
local function createLevelIndicator()
    local indicatorGui = Instance.new("ScreenGui", player.PlayerGui)
    indicatorGui.Name = "LevelIndicatorGui"
    indicatorGui.ResetOnSpawn = false
    
    local indicator = Instance.new("Frame", indicatorGui)
    indicator.Size = UDim2.new(0, 300, 0, 60)
    indicator.Position = UDim2.new(0.5, -150, 0.5, -30) -- Центр экрана
    indicator.BackgroundColor3 = Color3.new(0, 0, 0)
    indicator.BackgroundTransparency = 0.3
    indicator.BorderSizePixel = 0
    
    -- Закругляем углы
    local corner = Instance.new("UICorner", indicator)
    corner.CornerRadius = UDim.new(0, 8)
    
    local titleLabel = Instance.new("TextLabel", indicator)
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔄 Автоскрипт активен"
    titleLabel.TextColor3 = Color3.new(0, 1, 0) -- Зеленый
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local levelLabel = Instance.new("TextLabel", indicator)
    levelLabel.Size = UDim2.new(1, 0, 0, 35)
    levelLabel.Position = UDim2.new(0, 0, 0, 25)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Загрузка..."
    levelLabel.TextColor3 = Color3.new(1, 1, 1)
    levelLabel.Font = Enum.Font.SourceSans
    levelLabel.TextSize = 11
    levelLabel.TextXAlignment = Enum.TextXAlignment.Center
    levelLabel.TextWrapped = true
    
    return indicatorGui, levelLabel
end

-- Обновляем индикатор уровня
local function updateLevelIndicator(levelLabel, currentLevel)
    if currentLevel and tonumber(currentLevel) then
        local level = tonumber(currentLevel)
        local needed = 2650
        
        if level >= needed then
            levelLabel.Text = string.format("🎯 Уровень: %d\n✅ Запуск скрипта!", level)
            levelLabel.TextColor3 = Color3.new(0, 1, 0) -- Зеленый
        else
            local remaining = needed - level
            levelLabel.Text = string.format("📊 Уровень: %d / %d\n⏳ Осталось: %d лвл", level, needed, remaining)
            levelLabel.TextColor3 = Color3.new(1, 1, 0) -- Желтый
        end
    else
        levelLabel.Text = "❌ Не удалось получить уровень"
        levelLabel.TextColor3 = Color3.new(1, 0, 0) -- Красный
    end
end

-- Ждём появления объекта
local function waitForChild(parent, name, timeout)
    timeout = timeout or 10
    local t = 0
    while t < timeout and not parent:FindFirstChild(name) do
        t = t + task.wait()
    end
    return parent:FindFirstChild(name)
end

local function showPanelAndScan()
    if PANEL_SHOWN then return end
    PANEL_SHOWN = true
    
    -- Удаляем индикатор уровня
    local indicatorGui = player.PlayerGui:FindFirstChild("LevelIndicatorGui")
    if indicatorGui then indicatorGui:Destroy() end
    
    -- Удаляем старое окно, если есть
    local old = player.PlayerGui:FindFirstChild("StatsGui")
    if old then old:Destroy() end
    
    -- Создаём новое окно отчёта
    local statsGui = Instance.new("ScreenGui", player.PlayerGui)
    statsGui.Name = "StatsGui"
    statsGui.ResetOnSpawn = false
    
    local bg = Instance.new("Frame", statsGui)
    bg.Size               = UDim2.new(0, 650, 0, 570)
    bg.Position           = UDim2.new(0, 10, 0, 10)
    bg.BackgroundColor3   = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.6
    bg.BorderSizePixel    = 0
    
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
    box.Name             = "ReportBox"
    box.Size             = UDim2.new(1, -20, 1, -60)
    box.Position         = UDim2.new(0, 10, 0, 50)
    box.BackgroundColor3 = Color3.new(1, 1, 1)
    box.TextColor3       = Color3.new(0, 0, 0)
    box.TextWrapped      = true
    box.ClearTextOnFocus = false
    box.TextEditable     = false
    box.TextXAlignment   = Enum.TextXAlignment.Left
    box.TextYAlignment   = Enum.TextYAlignment.Top
    box.Text             = "Загружается..."
    
    -- Сканируем инвентарь и обновляем отчёт
    box.Text = buildReport()
    
    -- Через 10 секунд отправляем на сервер
    task.spawn(function()
        task.wait(10)
        if debugInfo.lastInventoryData then
            local result = sendDataToServer(debugInfo.lastInventoryData)
            if result.success then
                statusLabel.Text = "✅ " .. result.message
                statusLabel.TextColor3 = Color3.new(0, 1, 0)
                sendButton.BackgroundColor3 = Color3.new(0, 1, 0)
                sendButton.Text = "✅ Отправлено"
            else
                statusLabel.Text = "❌ " .. result.message
                statusLabel.TextColor3 = Color3.new(1, 0, 0)
                sendButton.BackgroundColor3 = Color3.new(1, 0, 0)
                sendButton.Text = "❌ Ошибка"
            end
        end
    end)
    
    -- Оставляем ручную отправку на всякий случай
    sendButton.MouseButton1Click:Connect(function()
        statusLabel.Text = "📤 Отправка данных..."
        statusLabel.TextColor3 = Color3.new(1, 1, 0)
        sendButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        sendButton.Text = "⏳ Отправка..."
        
        if not debugInfo.lastInventoryData then
            statusLabel.Text = "❌ Нет данных для отправки! Обновите инвентарь."
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
            sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
            sendButton.Text = "📤 Отправить"
            return
        end
        
        local result = sendDataToServer(debugInfo.lastInventoryData)
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

-- Следим за уровнем игрока
local function watchLevelAndRun()
    local data = waitForChild(player, "Data", 15)
    if not data then 
        -- Если не удалось получить данные, показываем индикатор с ошибкой
        local indicatorGui, levelLabel = createLevelIndicator()
        levelLabel.Text = "❌ Ошибка получения данных"
        levelLabel.TextColor3 = Color3.new(1, 0, 0)
        return 
    end
    
    local lvlO = data:FindFirstChild("Level")
    if not lvlO then 
        -- Если не удалось найти уровень, показываем индикатор с ошибкой
        local indicatorGui, levelLabel = createLevelIndicator()
        levelLabel.Text = "❌ Уровень не найден"
        levelLabel.TextColor3 = Color3.new(1, 0, 0)
        return 
    end
    
    -- Создаём индикатор уровня
    local indicatorGui, levelLabel = createLevelIndicator()
    
    -- Обновляем индикатор с текущим уровнем
    updateLevelIndicator(levelLabel, lvlO.Value)
    
    -- Если уже достигнут уровень, сразу запускаем через 2 секунды (чтобы пользователь увидел финальное сообщение)
    if tonumber(lvlO.Value) and tonumber(lvlO.Value) >= 2650 then
        task.wait(2)
        showPanelAndScan()
        return
    end
    
    -- Подписываемся на изменение уровня
    lvlO:GetPropertyChangedSignal("Value"):Connect(function()
        updateLevelIndicator(levelLabel, lvlO.Value)
        
        if tonumber(lvlO.Value) and tonumber(lvlO.Value) >= 2650 then
            -- Показываем финальное сообщение на 2 секунды, затем запускаем
            task.wait(2)
            showPanelAndScan()
        end
    end)
end

-- ЗАПУСКАЕМ ОТСЛЕЖИВАНИЕ УРОВНЯ СРАЗУ
task.spawn(function()
    -- Сначала создаем тестовый индикатор чтобы убедиться что GUI работает
    local testGui = Instance.new("ScreenGui", player.PlayerGui)
    testGui.Name = "TestGui"
    testGui.ResetOnSpawn = false
    
    local testFrame = Instance.new("Frame", testGui)
    testFrame.Size = UDim2.new(0, 200, 0, 50)
    testFrame.Position = UDim2.new(0.5, -100, 0.5, -25) -- Центр экрана
    testFrame.BackgroundColor3 = Color3.new(1, 0, 0) -- Красный фон
    testFrame.BorderSizePixel = 0
    
    local testLabel = Instance.new("TextLabel", testFrame)
    testLabel.Size = UDim2.new(1, 0, 1, 0)
    testLabel.Position = UDim2.new(0, 0, 0, 0)
    testLabel.BackgroundTransparency = 1
    testLabel.Text = "🔧 ТЕСТ: Скрипт работает!"
    testLabel.TextColor3 = Color3.new(1, 1, 1)
    testLabel.Font = Enum.Font.SourceSansBold
    testLabel.TextSize = 10
    testLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Удаляем тестовый индикатор через 5 секунд
    task.wait(5)
    testGui:Destroy()
    
    -- Теперь запускаем основную логику
    watchLevelAndRun()
end)

-- Событие открытия/закрытия инвентаря
local toggleInv = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToggleInventoryWindow")

-- GUI инвентаря
local invGui    = player:WaitForChild("PlayerGui"):WaitForChild("Main")
local scrolling = invGui.InventoryContainer.Right.Content.ScrollingFrame
local frame     = scrolling.Frame

-- Параметры
local canvasStep   = 550
local totalPages   = 10
local slotsPerPage = 16

-- Дебаг информация
local debugInfo = {
    foundFields = {},
    notFoundFields = {},
    itemsProcessed = 0,
    categoriesFound = 0,
    neighborsChecked = 0,
    lastSendResult = nil
}

-- Функция для URL-кодирования
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

-- Функция для отправки данных на сервер
local function sendDataToServer(data)
    local success, result = pcall(function()
        -- Подготавливаем URL с параметрами
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
        
        -- Отправляем GET запрос
        local response = game:HttpGet(url, true)
        
        -- Пытаемся распарсить ответ
        local responseData = HttpService:JSONDecode(response)
        
        return {
            success = true,
            message = "Данные отправлены успешно!",
            serverResponse = responseData,
            url = url
        }
    end)
    
    if success then
        debugInfo.lastSendResult = result
        return result
    else
        local errorResult = {
            success = false,
            message = "Ошибка отправки: " .. tostring(result),
            error = result
        }
        debugInfo.lastSendResult = errorResult
        return errorResult
    end
end

-- Функция для дебаг-вывода структуры объекта
local function debugObject(obj, name, depth)
    depth = depth or 0
    if depth > 3 then return end -- Ограничиваем глубину
    
    local indent = string.rep("  ", depth)
    local info = string.format("%s%s (%s)", indent, name, obj.ClassName)
    
    if obj:IsA("TextLabel") or obj:IsA("TextBox") then
        info = info .. string.format(" [Text: '%s']", obj.Text or "")
    end
    
    if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
        info = info .. string.format(" [Value: '%s']", tostring(obj.Value))
    end
    
    return info
end

-- Уровень
local function getLevel()
    local data = waitForChild(player, "Data", 15)
    local lvlO = data and data:FindFirstChild("Level")
    return lvlO and lvlO.Value or "?"
end

-- Стили боя
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

-- Расширенный поиск категорий в соседних элементах
local function scanCategoryWithNeighbors(targetCategory)
    local found = {}
    local debugItems = {}
    local itemLocations = {} -- Для отслеживания где найдены предметы
    local uniqueItems = {} -- Для отслеживания уникальных предметов
    local allFoundCategories = {} -- Для отслеживания всех найденных категорий
    
    -- Сбрасываем счетчики для этого сканирования
    debugInfo.itemsProcessed = 0
    debugInfo.categoriesFound = 0
    debugInfo.neighborsChecked = 0
    
    -- открыть инвентарь
    toggleInv:Fire()
    task.wait(0.5)
    -- сброс прокрутки на первую страницу
    scrolling.CanvasPosition = Vector2.new(0, 0)
    task.wait(0.1)
    
    -- по страницам
    for page = 0, totalPages - 1 do
        -- прокрутка на нужную страницу
        scrolling.CanvasPosition = Vector2.new(0, canvasStep * page)
        task.wait(0.15)
        
        for i = 1, slotsPerPage do
            local slot = frame:FindFirstChild(tostring(i))
            if slot and slot:FindFirstChild("Filled") then
                local filled = slot.Filled
                debugInfo.itemsProcessed = debugInfo.itemsProcessed + 1
                
                local itemName = "Неизвестный предмет"
                local itemCategory = ""
                local itemCount = 1 -- По умолчанию 1
                local debugItem = {
                    slotNum = i,
                    page = page,
                    name = itemName,
                    category = itemCategory,
                    count = itemCount,
                    foundFields = {},
                    structure = {},
                    isDuplicate = false
                }
                
                -- Получаем имя предмета
                local info = filled:FindFirstChild("ItemInformation")
                if info then
                    local nmObj = info:FindFirstChild("ItemName")
                    if nmObj then
                        itemName = nmObj.Text
                        debugItem.name = itemName
                        table.insert(debugItem.foundFields, "ItemName: " .. itemName)
                    end
                    
                    -- ИСПРАВЛЕНО: Ищем категорию в ItemLine1
                    local line1Obj = info:FindFirstChild("ItemLine1")
                    if line1Obj then
                        local line1Text = line1Obj.Text or ""
                        if line1Text ~= "" then
                            itemCategory = line1Text
                            debugItem.category = itemCategory
                            table.insert(debugItem.foundFields, "Category in ItemLine1: " .. itemCategory)
                            
                            -- Записываем все найденные категории
                            if not allFoundCategories[line1Text] then
                                allFoundCategories[line1Text] = {}
                            end
                            table.insert(allFoundCategories[line1Text], itemName)
                        end
                    end
                    
                    -- НОВОЕ: Получаем количество из Counter
                    local counterObj = info:FindFirstChild("Counter")
                    if counterObj then
                        table.insert(debugItem.foundFields, "Counter found: " .. counterObj.ClassName)
                        
                        -- Ищем количество в Counter
                        local foundCountInCounter = false
                        for _, counterChild in ipairs(counterObj:GetChildren()) do
                            if counterChild:IsA("TextLabel") then
                                local counterText = counterChild.Text or ""
                                if counterText ~= "" and counterText:match("%d+") then
                                    itemCount = tonumber(counterText:match("%d+")) or 1
                                    debugItem.count = itemCount
                                    table.insert(debugItem.foundFields, "Count in Counter TextLabel: " .. itemCount)
                                    foundCountInCounter = true
                                    break
                                end
                            end
                        end
                        
                        -- Если не нашли в детях, попробуем в самом Counter
                        if not foundCountInCounter and counterObj:IsA("TextLabel") then
                            local counterText = counterObj.Text or ""
                            if counterText ~= "" and counterText:match("%d+") then
                                itemCount = tonumber(counterText:match("%d+")) or 1
                                debugItem.count = itemCount
                                table.insert(debugItem.foundFields, "Count in Counter itself: " .. itemCount)
                                foundCountInCounter = true
                            end
                        end
                        
                        if not foundCountInCounter then
                            table.insert(debugItem.foundFields, "Counter found but no count extracted, using default: 1")
                        end
                    else
                        table.insert(debugItem.foundFields, "No Counter found, using default count: 1")
                    end
                    
                    -- НОВОЕ: Принудительно устанавливаем количество = 1 для мечей и аксессуаров
                    if itemCategory ~= "" then
                        local lowerCategory = itemCategory:lower()
                        if lowerCategory:find("sword") or lowerCategory:find("accessory") or 
                           lowerCategory:find("weapon") or lowerCategory:find("melee") or lowerCategory:find("gun") then
                            local originalCount = itemCount
                            itemCount = 1
                            debugItem.count = 1
                            table.insert(debugItem.foundFields, string.format("ПРИНУДИТЕЛЬНО: %s всегда 1 шт. (было: %d)", 
                                itemCategory, originalCount))
                        end
                    end
                    
                    -- Дебаг: выводим всю структуру ItemInformation
                    for _, child in ipairs(info:GetChildren()) do
                        local childInfo = debugObject(child, child.Name, 0)
                        table.insert(debugItem.structure, childInfo)
                        
                        -- Для Counter показываем также его детей
                        if child.Name == "Counter" then
                            for _, grandChild in ipairs(child:GetChildren()) do
                                local grandChildInfo = debugObject(grandChild, grandChild.Name, 1)
                                table.insert(debugItem.structure, "  " .. grandChildInfo)
                            end
                        end
                        
                        -- Дополнительно: пробуем найти категорию в других полях (фоллбэк)
                        if itemCategory == "" and (child.Name:lower():find("category") or child.Name:lower():find("type")) then
                            local catValue = child.Text or child.Value or ""
                            if catValue ~= "" then
                                itemCategory = catValue
                                debugItem.category = itemCategory
                                table.insert(debugItem.foundFields, "Category in " .. child.Name .. ": " .. itemCategory)
                            end
                        end
                    end
                end
                
                -- НОВОЕ: Ищем категорию в соседних элементах (siblings) - только если не найдена в ItemLine1
                if itemCategory == "" then
                    debugInfo.neighborsChecked = debugInfo.neighborsChecked + 1
                    
                    for _, sibling in ipairs(filled:GetChildren()) do
                        if sibling ~= info then -- Не сам ItemInformation
                            local siblingInfo = debugObject(sibling, sibling.Name, 0)
                            table.insert(debugItem.structure, "SIBLING: " .. siblingInfo)
                            
                            -- Проверяем, может ли этот sibling быть категорией
                            if sibling:IsA("TextLabel") then
                                local text = sibling.Text or ""
                                if text ~= "" and text ~= itemName then
                                    -- Проверяем, похоже ли это на категорию
                                    local lowerText = text:lower()
                                    if lowerText:find("sword") or lowerText:find("gun") or lowerText:find("fruit") or 
                                       lowerText:find("accessory") or lowerText:find("material") or lowerText:find("weapon") then
                                        itemCategory = text
                                        debugItem.category = itemCategory
                                        table.insert(debugItem.foundFields, "Category in sibling TextLabel: " .. itemCategory)
                                    end
                                end
                            end
                            
                            -- Также проверяем детей sibling'а
                            for _, grandchild in ipairs(sibling:GetChildren()) do
                                if grandchild:IsA("TextLabel") then
                                    local gcText = grandchild.Text or ""
                                    if gcText ~= "" and gcText ~= itemName then
                                        local lowerGcText = gcText:lower()
                                        if lowerGcText:find("sword") or lowerGcText:find("gun") or lowerGcText:find("fruit") or 
                                           lowerGcText:find("accessory") or lowerGcText:find("material") or lowerGcText:find("weapon") then
                                            itemCategory = gcText
                                            debugItem.category = itemCategory
                                            table.insert(debugItem.foundFields, "Category in sibling child: " .. itemCategory)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Проверяем соответствие целевой категории
                local isMatch = false
                if itemCategory ~= "" then
                    debugInfo.categoriesFound = debugInfo.categoriesFound + 1
                    isMatch = itemCategory:lower():find(targetCategory:lower())
                    table.insert(debugItem.foundFields, string.format("Category match check: '%s' contains '%s'? %s", 
                        itemCategory:lower(), targetCategory:lower(), isMatch and "YES" or "NO"))
                else
                    -- Фоллбэк: поиск по имени предмета
                    isMatch = itemName:lower():find(targetCategory:lower())
                    if isMatch then
                        table.insert(debugItem.foundFields, "Matched by name fallback")
                    else
                        table.insert(debugItem.foundFields, "No match by name fallback")
                    end
                end
                
                if isMatch and itemName ~= "" then
                    -- ИСПРАВЛЕНО: Проверяем на дубликаты только по имени предмета
                    local uniqueKey = itemName -- Уникальный ключ: только имя
                    
                    if uniqueItems[uniqueKey] then
                        -- Это дубликат!
                        debugItem.isDuplicate = true
                        table.insert(debugItem.foundFields, "ДУБЛИКАТ: игнорируем")
                    else
                        -- Это уникальный предмет
                        uniqueItems[uniqueKey] = true
                        
                        -- Отслеживаем где найдены предметы для дебага
                        if not itemLocations[itemName] then
                            itemLocations[itemName] = {}
                        end
                        table.insert(itemLocations[itemName], {
                            page = page,
                            slot = i,
                            count = itemCount,
                            isUnique = true
                        })
                        
                        -- Добавляем предмет с правильным количеством
                        local itemWithCount = {name = itemName, count = itemCount}
                        table.insert(found, itemWithCount)
                        debugItem.matched = true
                        table.insert(debugItem.foundFields, "УНИКАЛЬНЫЙ: добавлен в результат")
                    end
                    
                    -- Отслеживаем все вхождения для дебага (включая дубликаты)
                    if not itemLocations[itemName] then
                        itemLocations[itemName] = {}
                    end
                    if debugItem.isDuplicate then
                        table.insert(itemLocations[itemName], {
                            page = page,
                            slot = i,
                            count = itemCount,
                            isUnique = false
                        })
                    end
                else
                    debugItem.matched = false
                end
                
                -- ИЗМЕНЕНО: Добавляем в дебаг ВСЕ предметы, не только совпадающие
                table.insert(debugItems, debugItem)
            end
        end
    end
    
    -- закрыть инвентарь
    toggleInv:Fire()
    
    -- Сохраняем дебаг информацию
    debugInfo.lastScanCategory = targetCategory
    debugInfo.lastScanItems = debugItems
    debugInfo.itemLocations = itemLocations
    debugInfo.allFoundCategories = allFoundCategories
    
    return found
end

-- Аггрегируем одинаковые (Имя × Кол-во) - ОБНОВЛЕНО для работы с объектами
local function aggregate(list)
    local counts = {}
    local aggregationDebug = {} -- Для дебаг информации
    
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
            table.insert(aggregationDebug, string.format("Добавили к %s: +%d = %d", name, count, counts[name]))
        else
            counts[name] = count
            table.insert(aggregationDebug, string.format("Новый предмет %s: %d", name, count))
        end
    end
    
    -- Сохраняем дебаг информацию об агрегации
    debugInfo.lastAggregation = {
        inputCount = #list,
        debug = aggregationDebug,
        finalCounts = counts
    }
    
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

-- Получатели категорий
local function getGuiSwords()      return aggregate(scanCategoryWithNeighbors("sword"))      end
local function getGuiGuns()        return aggregate(scanCategoryWithNeighbors("gun"))        end
local function getGuiFruits()      return aggregate(scanCategoryWithNeighbors("fruit"))      end
local function getGuiAccessories() return aggregate(scanCategoryWithNeighbors("accessory")) end
local function getGuiMaterials()   return aggregate(scanCategoryWithNeighbors("material"))   end

-- Генерация дебаг отчёта
local function generateDebugReport()
    local debugLines = {
        "=== ДЕБАГ ИНФОРМАЦИЯ ===",
        string.format("Обработано предметов: %d", debugInfo.itemsProcessed),
        string.format("Найдено категорий: %d", debugInfo.categoriesFound),
        string.format("Проверено соседних элементов: %d", debugInfo.neighborsChecked),
        "",
        "=== ДЕТАЛИ ПОСЛЕДНЕГО СКАНИРОВАНИЯ ===",
        string.format("Искали категорию: %s", debugInfo.lastScanCategory or "нет"),
        ""
    }
    
    -- Добавляем информацию о последней отправке
    if debugInfo.lastSendResult then
        table.insert(debugLines, "=== ПОСЛЕДНЯЯ ОТПРАВКА ===")
        table.insert(debugLines, string.format("Статус: %s", debugInfo.lastSendResult.success and "✅ УСПЕШНО" or "❌ ОШИБКА"))
        table.insert(debugLines, string.format("Сообщение: %s", debugInfo.lastSendResult.message))
        if debugInfo.lastSendResult.url then
            table.insert(debugLines, string.format("URL: %s", debugInfo.lastSendResult.url))
        end
        if debugInfo.lastSendResult.serverResponse then
            table.insert(debugLines, string.format("Ответ сервера: %s", HttpService:JSONEncode(debugInfo.lastSendResult.serverResponse)))
        end
        if debugInfo.lastSendResult.error then
            table.insert(debugLines, string.format("Ошибка: %s", tostring(debugInfo.lastSendResult.error)))
        end
        table.insert(debugLines, "")
    end
    
    -- Добавляем информацию о всех найденных категориях
    if debugInfo.allFoundCategories then
        table.insert(debugLines, "=== ВСЕ НАЙДЕННЫЕ КАТЕГОРИИ ===")
        for category, items in pairs(debugInfo.allFoundCategories) do
            table.insert(debugLines, string.format("📂 Категория '%s':", category))
            for _, itemName in ipairs(items) do
                table.insert(debugLines, string.format("   • %s", itemName))
            end
            table.insert(debugLines, "")
        end
    end
    
    -- Добавляем информацию о местоположении предметов
    if debugInfo.itemLocations then
        table.insert(debugLines, "=== МЕСТОПОЛОЖЕНИЕ ПРЕДМЕТОВ ===")
        for itemName, locations in pairs(debugInfo.itemLocations) do
            table.insert(debugLines, string.format("📋 %s:", itemName))
            local totalCount = 0
            local uniqueCount = 0
            local duplicateCount = 0
            
            for _, location in ipairs(locations) do
                local status = ""
                if location.isUnique == true then
                    status = "✅ УНИКАЛЬНЫЙ"
                    uniqueCount = uniqueCount + 1
                    totalCount = totalCount + location.count
                elseif location.isUnique == false then
                    status = "❌ ДУБЛИКАТ"
                    duplicateCount = duplicateCount + 1
                else
                    status = "❓ НЕИЗВЕСТНО"
                end
                
                table.insert(debugLines, string.format("   • Стр.%d Слот %d: %d шт. %s", 
                    location.page, location.slot, location.count, status))
            end
            
            table.insert(debugLines, string.format("   ИТОГО: %d шт. (уникальных: %d, дубликатов: %d)", 
                totalCount, uniqueCount, duplicateCount))
            table.insert(debugLines, "")
        end
    end
    
    if debugInfo.lastScanItems then
        table.insert(debugLines, "=== ДЕТАЛИ СЛОТОВ ===")
        for _, item in ipairs(debugInfo.lastScanItems) do
            local slotStatus = ""
            if item.isDuplicate then
                slotStatus = " ❌ ДУБЛИКАТ"
            elseif item.matched then
                slotStatus = " ✅ УНИКАЛЬНЫЙ"
            end
            
            table.insert(debugLines, string.format("📦 Слот %d (стр.%d): %s%s", 
                item.slotNum, item.page, item.name, slotStatus))
            table.insert(debugLines, string.format("   Категория: %s", item.category ~= "" and item.category or "НЕ НАЙДЕНА"))
            table.insert(debugLines, string.format("   Количество: %d", item.count or 1))
            table.insert(debugLines, string.format("   Совпадение: %s", item.matched and "ДА" or "НЕТ"))
            
            if #item.foundFields > 0 then
                table.insert(debugLines, "   Найденные поля:")
                for _, field in ipairs(item.foundFields) do
                    table.insert(debugLines, "     • " .. field)
                end
            end
            
            if #item.structure > 0 then
                table.insert(debugLines, "   Структура:")
                for _, struct in ipairs(item.structure) do
                    table.insert(debugLines, "     " .. struct)
                end
            end
            
            table.insert(debugLines, "")
        end
    end
    
    -- Добавляем дебаг информацию об агрегации
    if debugInfo.lastAggregation then
        table.insert(debugLines, "=== ДЕБАГ АГРЕГАЦИИ ===")
        table.insert(debugLines, string.format("Входящих предметов: %d", debugInfo.lastAggregation.inputCount))
        table.insert(debugLines, "")
        
        if debugInfo.lastAggregation.debug then
            table.insert(debugLines, "Процесс агрегации:")
            for _, debugMsg in ipairs(debugInfo.lastAggregation.debug) do
                table.insert(debugLines, "  • " .. debugMsg)
            end
            table.insert(debugLines, "")
        end
        
        if debugInfo.lastAggregation.finalCounts then
            table.insert(debugLines, "Итоговые количества:")
            for name, count in pairs(debugInfo.lastAggregation.finalCounts) do
                table.insert(debugLines, string.format("  • %s: %d", name, count))
            end
            table.insert(debugLines, "")
        end
    end
    
    return table.concat(debugLines, "\n")
end

-- Собираем отчёт
local function buildReport()
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
    
    -- Сохраняем последние данные для отправки
    debugInfo.lastInventoryData = {
        level = lvl,
        styles = #styles>0 and table.concat(styles, ", ") or "нет",
        swords = #swords>0 and table.concat(swords, ", ") or "нет",
        guns = #guns>0 and table.concat(guns, ", ") or "нет",
        fruits = #fruits>0 and table.concat(fruits, ", ") or "нет",
        accessories = #accs>0 and table.concat(accs, ", ") or "нет",
        materials = #mats>0 and table.concat(mats, ", ") or "нет"
    }
    
    return table.concat(lines, "\n")
end

-- Функция для обновления отчета после отправки
local function updateReportAfterSend(success, message)
    local currentReport = box.Text
    local lines = {}
    
    -- Разбиваем текущий отчет на строки
    for line in currentReport:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    -- Убираем старые статусы отправки
    local cleanLines = {}
    for _, line in ipairs(lines) do
        if not line:find("📤") and not line:find("✅") and not line:find("❌") then
            table.insert(cleanLines, line)
        end
    end
    
    -- Добавляем новый статус
    table.insert(cleanLines, "")
    if success then
        table.insert(cleanLines, "✅ Данные успешно отправлены на сервер!")
        table.insert(cleanLines, "🌐 Смотрите на: http://194.59.186.230:3000")
    else
        table.insert(cleanLines, "❌ Ошибка отправки: " .. message)
        table.insert(cleanLines, "🔄 Попробуйте ещё раз")
    end
    
    box.Text = table.concat(cleanLines, "\n")
end

-- Обработчик кнопки отправки
-- sendButton.MouseButton1Click:Connect(function()
--     statusLabel.Text = "📤 Отправка данных..."
--     statusLabel.TextColor3 = Color3.new(1, 1, 0) -- Желтый цвет
--     sendButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5) -- Серый цвет
--     sendButton.Text = "⏳ Отправка..."
    
--     -- Проверяем наличие данных
--     if not debugInfo.lastInventoryData then
--         statusLabel.Text = "❌ Нет данных для отправки! Обновите инвентарь."
--         statusLabel.TextColor3 = Color3.new(1, 0, 0)
--         sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
--         sendButton.Text = "📤 Отправить"
--         return
--     end
    
--     -- Отправляем данные
--     local result = sendDataToServer(debugInfo.lastInventoryData)
    
--     if result.success then
--         statusLabel.Text = "✅ " .. result.message
--         statusLabel.TextColor3 = Color3.new(0, 1, 0) -- Зеленый цвет
--         sendButton.BackgroundColor3 = Color3.new(0, 1, 0) -- Зеленый цвет
--         sendButton.Text = "✅ Отправлено"
        
--         -- Через 3 секунды возвращаем обычный вид
--         task.wait(3)
--         sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
--         sendButton.Text = "📤 Отправить"
--         statusLabel.Text = "Готов к отправке"
--         statusLabel.TextColor3 = Color3.new(1, 1, 1)
--         updateReportAfterSend(true, result.message)
--     else
--         statusLabel.Text = "❌ " .. result.message
--         statusLabel.TextColor3 = Color3.new(1, 0, 0) -- Красный цвет
--         sendButton.BackgroundColor3 = Color3.new(1, 0, 0) -- Красный цвет
--         sendButton.Text = "❌ Ошибка"
        
--         -- Через 5 секунд возвращаем обычный вид
--         task.wait(5)
--         sendButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
--         sendButton.Text = "📤 Отправить"
--         statusLabel.Text = "Готов к отправке"
--         statusLabel.TextColor3 = Color3.new(1, 1, 1)
--         updateReportAfterSend(false, result.message)
--     end
-- end)

-- Вывод и копирование в GUI
-- box.Text = buildReport() 
