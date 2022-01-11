require "assets.quests"
require "assets.dialog"
local Dialove = require('Dialove')
local Timer = require "classes.timer"

home = {}

local dialogManager

local showDialog = true
local curDialog = dialog["introduction"]

local background, cursor, coin
local cursorVisible = true

local keyIsPressed = false

local purchaseSfx, buzzerSfx, selectSfx

local metalDict = {
    "copper",
    "bronze",
    "iron",
    "steel",
    "gold"
}

local costDict = {
    copper = 10,
    bronze = 20,
    iron = 30,
    steel = 40,
    gold = 50
}

local currentCursorPos, maxCursorPos = 1, #metalDict

local gameIsWon = false

function home.load()
    purchaseSfx = love.audio.newSource("assets/sfx/CashRegisterChing.wav", "static")
    buzzerSfx = love.audio.newSource("assets/sfx/buzzer.wav", "static")
    selectSfx = love.audio.newSource("assets/sfx/select.wav", "static")

    dialogManager = Dialove.init({
        font = font9,
        viewportW = 400,
        viewportH = 240,
    })
    
    local curQuest = quests[questNumber]
    if questActive and questCompleted then
        curDialog = curQuest.response
        if curQuest.rewardLevel ~= nil then
            if curQuest.rewardLevel >= 6 then
                home.winGame()
            else
                unlockedMetal = curQuest.rewardLevel
            end
        end
        showDialog = true
        questActive = false
        questCompleted = false
        fulfilledOrders = 0
        questNumber = questNumber + 1
        timeUntilNextQuest = 0
    else
        if timeUntilNextQuest == 0 then
            showDialog = true
            questActive = true
            curDialog = curQuest.introduction
            timeUntilNextQuest = timeUntilNextQuest - 1
        else
            timeUntilNextQuest = timeUntilNextQuest - 1
        end
    end

    if coins < 10 then
        showDialog = true
        curDialog = dialog["loss"]
    end

    if showDialog then
        dialogManager:show(curDialog)
    end

    Timer.clear()

    background = love.graphics.newImage("assets/art/UI/home/home.png")
    cursor = love.graphics.newImage("assets/art/UI/home/cursor.png")
    coin = love.graphics.newImage("assets/art/UI/home/coin.png")

    maxCursorPos = unlockedMetal
    cursorVisible = true
    Timer.every(1, function()
        cursorVisible = false
        Timer.after(0.3, function()
            cursorVisible = true
        end)
    end)
end

function home.draw()
    love.graphics.draw(background, 0, 0)
    home.drawCursor()
    home.drawCoins()
    home.drawPrices()
    home.drawQuest()
    dialogManager:draw()
end

function home.update(dt)
    Timer.update(dt)
    dialogManager:update(dt)
end

function home.keypressed(key)
    if showDialog then
        if key == "return" then
            if dialogManager:getActiveDialog().done then
                dialogManager:pop()
                showDialog = false
                if gameIsWon then
                    change_scene(winScreen)
                elseif coins < 10 then
                    change_scene(lossScreen)
                end
            else
                dialogManager:complete()
            end
        end
        return
    end

    local curMetalCost = costDict[selectedMetal]
    if key == "return" then
        if coins >= curMetalCost then
            coins = coins - curMetalCost
            purchaseSfx:play()
            change_scene(furnace)
            return
        else
            buzzerSfx:play()
            return
        end
    end

    if keyIsPressed then
        return
    end

    if key == "up" then
        keyIsPressed = true
        currentCursorPos = currentCursorPos - 1
        selectSfx:play()
    elseif key == "down" then
        keyIsPressed = true
        currentCursorPos = currentCursorPos + 1
        selectSfx:play()
    end
    
    if currentCursorPos >= maxCursorPos then
        currentCursorPos = maxCursorPos
    elseif currentCursorPos <= 1 then
        currentCursorPos = 1
    end

    selectedMetal = metalDict[currentCursorPos]
end

function home.keyreleased(key)
    keyIsPressed = false
end

function home.drawCursor()
    if cursorVisible then
        local cursorX = 154
        local cursorY = 40 + 32 * (currentCursorPos - 1)
        love.graphics.draw(cursor, cursorX, cursorY)
    end
end

function home.drawCoins()
    local coinX, coinY = 370, 10
    love.graphics.draw(coin, coinX, coinY)
    local coinText = love.graphics.newText(font18, tostring(coins))
    local textWidth = coinText:getWidth()
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(coinText, coinX - textWidth - 5, coinY)
    love.graphics.setColor(1, 1, 1)
end

function home.drawPrices()
    for i=1,unlockedMetal do 
        local curMetal = metalDict[i]
        local curCostStr = tostring(costDict[curMetal])
        local curMetalUpperCase = curMetal:sub(1,1):upper()..curMetal:sub(2)
        local metalImage = love.graphics.newImage("assets/art/UI/finalResult/"..curMetal..".png")
        local baseX, baseY, yOffset = 162, 47, 32
        love.graphics.draw(metalImage, baseX, baseY + yOffset * (i - 1))
        love.graphics.setColor(0, 0, 0)
        local priceText = love.graphics.newText(font9, curMetalUpperCase.." - "..curCostStr.."g")
        local textX = baseX + 94 - priceText:getWidth()
        love.graphics.draw(priceText, textX, baseY + 3 + yOffset * (i - 1))
        love.graphics.setColor(1, 1, 1)
    end
end

function home.drawQuest()
    if not questActive then
        return
    end

    local curQuest = quests[questNumber]
    local questBackground = love.graphics.newImage("assets/art/UI/home/questBackground.png")
    local questPortrait = curQuest.introduction.image
    local questMaterial = curQuest.requiredMaterial
    local questNumber = curQuest.requiredNumber
    local questGrade = curQuest.requiredGrade
    local questMaterialImage = love.graphics.newImage("assets/art/UI/finalResult/"..questMaterial..".png")
    local questGradeImage = love.graphics.newImage("assets/art/UI/result/"..questGrade..".png")
    local questNumberText = love.graphics.newText(font9, tostring(fulfilledOrders).." / "..tostring(questNumber))

    love.graphics.draw(questBackground, 293, 28)
    love.graphics.draw(questPortrait, 323, 71)
    love.graphics.draw(questMaterialImage, 349, 116)
    love.graphics.draw(questGradeImage, 350, 144)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(questNumberText, 351, 194)
    love.graphics.setColor(1, 1, 1)
end

function home.winGame()
    gameIsWon = true
end