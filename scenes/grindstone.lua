require "scenes.finalResult"
require "assets.dialog"
local Dialove = require('Dialove')

local dialogManager
local showDialog = false

local Timer = require "classes.timer"

grindstone = {}

local grindstoneSfx, sharpeningSfx, risingSfx, buzzerSfx, successSfx, dingSfx
local risingVolume = { 1 }

local scoreController, resultDisplay

local particleSystem

local background, grindstoneForeground, grindstoneBackground, sword, stand
local barBackground, cursor
local grindstoneRotation, grindstoneRotationSpeed = 0, 2

local swordOffseted = false
local swordPosBase, swordMoveTime = 150, 3
local swordPos = { swordPosBase }

local yellowRange = 80
local greenRange = 40
local zoneCenter

local cursorMax, cursorPos = 319, 0
local cursorSpeed = 0
local maxCursorSpeed, cursorAcceleration, cursorDeceleration = 4, 3, 5

local showingResults = false
local inputReceived = false
local spacePressed = false
local accelerating = false

function grindstone.load()
    setGrindstoneDifficulty()

    dialogManager = Dialove.init({
        font = font9,
        viewportW = 400,
        viewportH = 240,
    })
    
    if grindstoneTutorial then
        dialogManager:show(dialog["grindstoneTutorial"])
        showDialog = true
        grindstoneTutorial = false
    end

    buzzerSfx = love.audio.newSource("assets/sfx/buzzer.wav", "static")
    successSfx = love.audio.newSource("assets/sfx/fanfare.wav", "static")
    dingSfx = love.audio.newSource("assets/sfx/ding.wav", "static")
    grindstoneSfx = love.audio.newSource("assets/sfx/grindstone.wav", "static")
    grindstoneSfx:setLooping(true)
    grindstoneSfx:play()
    sharpeningSfx = love.audio.newSource("assets/sfx/sharpening.wav", "static")
    risingSfx = love.audio.newSource("assets/sfx/rising.wav", "static")
    risingVolume = { 1 }

    background = love.graphics.newImage("assets/art/UI/grindstone/background.png")
    grindstoneForeground = love.graphics.newImage("assets/art/UI/grindstone/grindstoneForeground.png")
    grindstoneBackground = love.graphics.newImage("assets/art/UI/grindstone/grindstoneBackground.png")
    sword = love.graphics.newImage("assets/art/UI/grindstone/sharpeningSword.png")
    stand = love.graphics.newImage("assets/art/UI/grindstone/grindstoneStand.png")
    
    meterBackground = love.graphics.newImage("assets/art/UI/anvil/barBackground.png")
    cursor = love.graphics.newImage("assets/art/UI/anvil/cursor.png")
    
    Timer.clear()
    initializeGrindParticles()
    moveSword()
    Timer.every(swordMoveTime, moveSword)

    resetGrindstone()

    scoreController = ScoreController(3, 290, 25)

    resultDisplay = ResultDisplay(finalResult)
end

function grindstone.draw()
    love.graphics.draw(background, 0, 0)
    local grindstoneOffset = 130 / 2
    love.graphics.draw(grindstoneBackground, 84 + grindstoneOffset, 17 + grindstoneOffset, grindstoneRotation, 1, 1, grindstoneOffset, grindstoneOffset)
    love.graphics.draw(grindstoneForeground, 70 + grindstoneOffset, 22 + grindstoneOffset, grindstoneRotation, 1, 1, grindstoneOffset, grindstoneOffset)
    love.graphics.draw(stand, 19, 76)
    love.graphics.draw(sword, swordPos[1], 37)
    love.graphics.draw(particleSystem, 197, 71)
    drawMeter()
    drawGrindstoneCursor()
    scoreController:draw()
    resultDisplay:draw(home)
    dialogManager:draw()
end

function grindstone.update(dt)
    Timer.update(dt)
    particleSystem:update(dt)
    updateGrindstoneCursor(dt)
    grindstoneRotation = grindstoneRotation + grindstoneRotationSpeed * dt
    resultDisplay:update(dt)
    dialogManager:update(dt)
    risingSfx:setVolume(risingVolume[1])
end

function grindstone.keypressed(key)
    if showDialog then
        if key == "return" then
            if dialogManager:getActiveDialog().done then
                dialogManager:pop()
                showDialog = false
            else
                dialogManager:complete()
            end
        end
        return
    end
end

function grindstone.keyreleased(key)
end

function setGrindstoneDifficulty()
    if selectedMetal == "copper" then
        yellowRange = 110
        greenRange = 70
        cursorAcceleration = 3
        cursorDeceleration = 7
    elseif selectedMetal == "bronze" then
        yellowRange = 95
        greenRange = 55
        cursorAcceleration = 3
        cursorDeceleration = 6
    elseif selectedMetal == "iron" then
        yellowRange = 80
        greenRange = 40
        cursorAcceleration = 3
        cursorDeceleration = 5
    elseif selectedMetal == "steel" then
        yellowRange = 65
        greenRange = 25
        cursorAcceleration = 3
        cursorDeceleration = 4
    elseif selectedMetal == "gold" then
        yellowRange = 50
        greenRange = 10
        cursorAcceleration = 3
        cursorDeceleration = 3
    end
end

function updateGrindstoneCursor(dt)
    if showingResults or showDialog then
        return
    end

    if not inputReceived then
        if love.keyboard.isDown("space") then
            spacePressed = true
            inputReceived = true
            risingVolume = { 1 }
            risingSfx:play()

        else
            return
        end
    end

    if spacePressed then
        if love.keyboard.isDown("space") then
            accelerating = true
        else
            spacePressed = false
            accelerating = false
            Timer.tween(1, risingVolume, { 0 }, 'linear', function()
                risingSfx:stop()
            end)
        end
    end

    if accelerating then
        cursorSpeed = cursorSpeed + cursorAcceleration * dt
    else
        cursorSpeed = cursorSpeed - cursorDeceleration * dt
    end
    if cursorSpeed <= 0 then
        cursorSpeed = 0
        dingSfx:play()
        updateResults()
    elseif cursorSpeed >= maxCursorSpeed then
        cursorSpeed = maxCursorSpeed
    end

    cursorPos = cursorPos + cursorSpeed
    if cursorPos >= cursorMax then
        cursorPos = cursorMax
        updateResults()
    end
end

function updateResults()
    local yellowMin = zoneCenter - yellowRange
    local yellowMax = yellowMin + yellowRange * 2
    local greenMin = zoneCenter - greenRange
    local greenMax = greenMin + greenRange * 2
    if cursorPos >= greenMin and cursorPos <= greenMax then
        scoreController:addColorScore('green')
    elseif cursorPos >= yellowMin and cursorPos <= yellowMax then
        scoreController:addColorScore('yellow')
    else
        scoreController:addColorScore('red')
    end

    showingResults = true

    if scoreController:isFull() then
        resultDisplay:setScore(getGrindstoneScore())
        stopGrindstoneAudio()
    else
        Timer.after(1, function()
            resetGrindstone()
        end)
    end
end

function stopGrindstoneAudio()
    grindstoneSfx:stop()
    risingSfx:stop()
end

function resetGrindstone()
    initalizeZoneCenter()
    cursorPos = 0
    cursorSpeed = 0
    spacePressed = false
    inputReceived = false
    accelerating = false
    showingResults = false
end

function getGrindstoneScore()
    local aggregateScore = scoreController:getAggregateScore()

    if aggregateScore == 0 then
        buzzerSfx:play()
        return 'F'
    elseif aggregateScore <=2 then
        grindstoneScore = 0
        successSfx:play()
        return 'C'
    elseif aggregateScore <=4 then
        grindstoneScore = 1
        successSfx:play()
        return 'B'
    else
        grindstoneScore = 2
        successSfx:play()
        return 'A'
    end
end

function moveSword()
    local newPos = swordPosBase
    local offset = 15
    if not swordOffseted then
        newPos = newPos + offset
        particleSystem:setEmissionRate(30)
        sharpeningSfx:play()
        Timer.after(1, function()
            particleSystem:setEmissionRate(0)
        end)
    end
    swordOffseted = not swordOffseted
    Timer.tween(swordMoveTime, swordPos, { newPos }, 'in-out-quad')
end

function drawGrindstoneCursor()
    local cursorY = 197 + 2 + 1
    local cursorX = 38 + 2 + cursorPos - 2
    love.graphics.draw(cursor, cursorX, cursorY)
end

function drawMeter()
    love.graphics.draw(meterBackground, 38, 197)
    local zoneHeight = 27

    local barX, barY = 38 + 2, 197 + 2
    local yellowZoneX = zoneCenter - yellowRange + barX
    local greenZoneX = zoneCenter - greenRange + barX

    love.graphics.setColor(255/255, 184/255, 0/255)
    love.graphics.rectangle("fill", yellowZoneX, barY, yellowRange * 2, zoneHeight)
    love.graphics.setColor(60/255, 171/255, 47/255)
    love.graphics.rectangle("fill", greenZoneX, barY, greenRange * 2, zoneHeight)
    love.graphics.setColor(1, 1, 1)
end

function initalizeZoneCenter()
    local zoneCenterMin = yellowRange
    local zoneCenterMax = cursorMax - yellowRange + 1
    zoneCenter = love.math.random(zoneCenterMin, zoneCenterMax)
end

function initializeGrindParticles()
    local spark = love.graphics.newImage("assets/art/UI/anvil/spark.png")
    particleSystem = love.graphics.newParticleSystem(spark, 100)
    particleSystem:setParticleLifetime(1, 1.5)
    particleSystem:setSizeVariation(1)

    particleSystem:setEmissionArea("uniform", 3, 3, 0.785398, false)
    particleSystem:setSpread(0.8)
    particleSystem:setSpinVariation(1)
	particleSystem:setLinearAcceleration(-20, 250, 20, 250)
    particleSystem:setSpeed(-120, -110)
    particleSystem:setDirection(1.5708)
    particleSystem:setSizes(1,0)
end