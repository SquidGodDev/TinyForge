require "scenes.home"
require "assets.quests"

local Timer = require "classes.timer"

finalResult = {}

local background
local copperSprite, bronzeSprite, ironSprite, steelSprite, goldSprite

local coinSfx

local metalImage, gradeImage
local swordGrade, coinsEarned
local coinsEarnedDisplay
local lastCoinAmount

local earningsDict = {
    copper = 15,
    bronze = 27,
    iron = 40,
    steel = 55,
    gold = 70
}

local earningsVariance = {
    copper = 2,
    bronze = 3,
    iron = 4,
    steel = 5,
    gold = 8
}

function finalResult.load()
    Timer.clear()
    background = love.graphics.newImage("assets/art/UI/finalResult/finalResultBackground.png")
    copper = love.graphics.newImage("assets/art/UI/finalResult/copper.png")
    bronze = love.graphics.newImage("assets/art/UI/finalResult/bronze.png")
    iron = love.graphics.newImage("assets/art/UI/finalResult/iron.png")
    steel = love.graphics.newImage("assets/art/UI/finalResult/steel.png")
    gold = love.graphics.newImage("assets/art/UI/finalResult/gold.png")

    metalImage = love.graphics.newImage("assets/art/UI/finalResult/"..selectedMetal..".png")

    coinSfx = love.audio.newSource("assets/sfx/coin.wav", "static")

    coinsEarnedDisplay = { 0 }
    lastCoinAmount = 0
    calculateEarnings()
    Timer.tween(1, coinsEarnedDisplay, { coinsEarned }, 'out-quad', function()
        coinsEarnedDisplay = { coinsEarned }
    end)

    updateQuest()
end

function finalResult.draw()
    love.graphics.draw(background, 0, 0)
    local coinsEarnedDisplayFloor = math.floor(coinsEarnedDisplay[1])
    local coinsEarnedText = love.graphics.newText(font18, tostring(coinsEarnedDisplayFloor)..'g')
    love.graphics.setColor(255/255, 125/255, 0/255)
    love.graphics.draw(coinsEarnedText, 224, 126)
    love.graphics.setColor(1, 1, 1)
    drawMetal()
    drawGrade()
    if questCompleted then
        drawQuestCompleted()
    end
end

function finalResult.update(dt)
    local coinsEarnedDisplayFloor = math.floor(coinsEarnedDisplay[1])
    if lastCoinAmount ~= coinsEarnedDisplayFloor then
        coinSfx:stop()
        coinSfx:play()
    end
    lastCoinAmount = coinsEarnedDisplayFloor
    
    Timer.update(dt)
end

function finalResult.keypressed(key)
    local coinsEarnedDisplayFloor = math.floor(coinsEarnedDisplay[1])
    if coinsEarnedDisplayFloor ~= coinsEarned then
        return
    end

    if key == "return" then
        change_scene(home)
    end
end

function finalResult.keyreleased(key)
end

function calculateEarnings()
    local scoreSum = furnaceScore + anvilScore + grindstoneScore
    local earningsCenter = earningsDict[selectedMetal]
    local earningsVariance = earningsVariance[selectedMetal]
    coinsEarned = love.math.random(earningsCenter - earningsVariance, earningsCenter + earningsVariance)
    
    if scoreSum <= 1 then
        swordGrade = 'C'
        gradeImage = love.graphics.newImage("assets/art/UI/result/C.png")
    elseif scoreSum <= 4 then
        swordGrade = 'B'
        gradeImage = love.graphics.newImage("assets/art/UI/result/B.png")
        coinsEarned = math.ceil(coinsEarned * 1.2)
    else
        swordGrade = 'A'
        gradeImage = love.graphics.newImage("assets/art/UI/result/A.png")
        coinsEarned = math.ceil(coinsEarned * 1.4)
    end
    
    coins = coins + coinsEarned
end

function drawMetal()
    love.graphics.draw(metalImage, 150, 82)
end

function drawGrade()    
    love.graphics.draw(gradeImage, 167 - 4, 51 - 2)
end

function drawQuestCompleted()
    local questCompleteImage = love.graphics.newImage("assets/art/UI/finalResult/questComplete.png")
    love.graphics.draw(questCompleteImage, 123, 159)
end

function updateQuest()
    if not questActive then
        return
    end

    local curQuest = quests[questNumber]
    local questMaterial = curQuest.requiredMaterial
    if questMaterial ~= selectedMetal then
        return
    end

    local questGrade = curQuest.requiredGrade
    if questGrade == 'C' then
        fulfilledOrders = fulfilledOrders + 1
    elseif questGrade == 'B' then
        if swordGrade == 'B' or swordGrade == 'A' then
            fulfilledOrders = fulfilledOrders + 1
        end
    elseif questGrade == 'A' then
        if swordGrade == 'A' then
            fulfilledOrders = fulfilledOrders + 1
        end
    end
    if fulfilledOrders >= curQuest.requiredNumber then
        questCompleted = true
    end
end