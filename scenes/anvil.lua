require "scenes.grindstone"
require "assets.dialog"
local Dialove = require('Dialove')

local dialogManager
local showDialog = false

local Timer = require "classes.timer"

anvil = {}

local scoreController, resultDisplay

local background, barBackground, hammer, cursor
local particleSystem

local hammerSfx, hammerBackgroundSfx, fireSfx, successSfx, buzzerSfx

local hammerRotation = { 0 }

local cursorMax = 319
local cursorPos = 0

local yellowRange = 100
local greenRange = 50
local zoneCenter

local cursorMoving = true
local cursorMovingRight = true
local cursorSpeed = 500

local showingScore = false

function anvil.load()
    setAnvilDifficulty()
    dialogManager = Dialove.init({
        font = font9,
        viewportW = 400,
        viewportH = 240,
    })
    
    if anvilTutorial then
        dialogManager:show(dialog["anvilTutorial"])
        showDialog = true
        anvilTutorial = false
    end

    --background = love.graphics.newImage("assets/art/UI/anvil/anvilBackground.png")
    background = love.graphics.newImage("assets/art/UI/anvil/anvilYellowBackground.png")
    barBackground = love.graphics.newImage("assets/art/UI/anvil/barBackground.png")
    hammer = love.graphics.newImage("assets/art/UI/anvil/hammer.png")
    cursor = love.graphics.newImage("assets/art/UI/anvil/cursor.png")

    hammerSfx = love.audio.newSource("assets/sfx/hammer.wav", "static")
    hammerBackgroundSfx = love.audio.newSource("assets/sfx/hammerBackground.wav", "static")
    successSfx = love.audio.newSource("assets/sfx/fanfare.wav", "static")
    buzzerSfx = love.audio.newSource("assets/sfx/buzzer.wav", "static")
    fireSfx = love.audio.newSource("assets/sfx/fire.mp3", "static")
    fireSfx:setLooping(true)
    fireSfx:setVolume(0.7)
    fireSfx:setPitch(0.5)
    fireSfx:play()

    hammerRotation = { 0 }
    Timer.clear()
    Timer.tween(0.8, hammerRotation, { 1.5708 }, "out-quad", function()
        Timer.tween(0.15, hammerRotation, { 0 }, "linear", function()
            particleSystem:emit(100)
            hammerBackgroundSfx:play()
        end)
    end)
    Timer.every(1.5, function()
        Timer.tween(0.8, hammerRotation, { 1.5708 }, "out-quad", function()
            Timer.tween(0.15, hammerRotation, { 0 }, "linear", function()
                particleSystem:emit(100)
                hammerBackgroundSfx:play()
            end)
        end)
    end)

    resetAnvil()
    
    initializeSparkParticles()

    scoreController = ScoreController(3, 20, 20)

    resultDisplay = ResultDisplay(grindstone)
end

function anvil.draw()
    love.graphics.draw(background, 0, 0)
    --love.graphics.draw(barBackground, 38, 194)
    love.graphics.draw(hammer, 191+60, 55+15, hammerRotation[1], 1, 1, 60, 15)
    love.graphics.draw(particleSystem, 198, 85)
    --drawZones()
    --drawAnvilCursor()
    --scoreController:draw()
    --resultDisplay:draw()
    --dialogManager:draw()
end

function anvil.update(dt)
    Timer.update(dt)
    particleSystem:update(dt)
    updateAnvilCursor(dt)
    checkCursor()
    resultDisplay:update(dt)
    dialogManager:update(dt)
end

function anvil.keypressed(key)
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

function anvil.keyreleased(key)
end

function updateAnvilCursor(dt)
    if not cursorMoving then
        return
    end

    if cursorPos <= 0 then
        cursorMovingRight = true
    elseif cursorPos >= cursorMax then
        cursorMovingRight = false
    end

    if cursorMovingRight then
        cursorPos = cursorPos + cursorSpeed * dt
    else
        cursorPos = cursorPos - cursorSpeed * dt
    end
end

function checkCursor()
    if showingScore or showDialog then
        return
    end

    if love.keyboard.isDown("space") then
        cursorMoving = false
        showingScore = true
        hammerSfx:play()
    else
        return
    end

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

    if scoreController:isFull() then
        resultDisplay:setScore(getHammerScore())
        stopAnvilAudio()
    else
        Timer.after(1, function() 
            resetAnvil()
        end)
    end
end

function stopAnvilAudio()
    fireSfx:stop()
end

function resetAnvil()
    randomizeAnvilZoneCenter()
    cursorMoving = true
    showingScore = false
    cursorPos = 0
end

function randomizeAnvilZoneCenter()
    local zoneCenterMin = yellowRange
    local zoneCenterMax = cursorMax - yellowRange + 1
    zoneCenter = love.math.random(zoneCenterMin, zoneCenterMax)
end

function setAnvilDifficulty()
    if selectedMetal == "copper" then
        yellowRange = 90
        greenRange = 50
        cursorSpeed = 300
    elseif selectedMetal == "bronze" then
        yellowRange = 80
        greenRange = 40
        cursorSpeed = 450
    elseif selectedMetal == "iron" then
        yellowRange = 80
        greenRange = 40
        cursorSpeed = 600
    elseif selectedMetal == "steel" then
        yellowRange = 60
        greenRange = 25
        cursorSpeed = 750
    elseif selectedMetal == "gold" then
        yellowRange = 50
        greenRange = 10
        cursorSpeed = 900
    end
end

function getHammerScore()
    local aggregateScore = scoreController:getAggregateScore()

    if aggregateScore == 0 then
        buzzerSfx:play()
        return 'F'
    elseif aggregateScore <=2 then
        anvilScore = 0
        successSfx:play()
        return 'C'
    elseif aggregateScore <=4 then
        anvilScore = 1
        successSfx:play()
        return 'B'
    else
        anvilScore = 2
        successSfx:play()
        return 'A'
    end
end

function initializeSparkParticles()
    local spark = love.graphics.newImage("assets/art/UI/anvil/spark.png")
    particleSystem = love.graphics.newParticleSystem(spark, 100)
    particleSystem:setParticleLifetime(1, 1.5)
    particleSystem:setEmissionRate(0)
    particleSystem:setSizeVariation(1)

    particleSystem:setEmissionArea("uniform", 3, 3, 0.785398, false)
    particleSystem:setSpread(0.8)
    particleSystem:setSpinVariation(1)
	particleSystem:setLinearAcceleration(-20, 250, 20, 250)
    particleSystem:setSpeed(-120, -110)
    particleSystem:setDirection(1.5708)
    particleSystem:setSizes(1,0)
end

function drawZones()
    local zoneHeight = 27

    local barX, barY = 38 + 2, 194 + 2
    local yellowZoneX = zoneCenter - yellowRange + barX
    local greenZoneX = zoneCenter - greenRange + barX

    love.graphics.setColor(255/255, 184/255, 0/255)
    love.graphics.rectangle("fill", yellowZoneX, barY, yellowRange * 2, zoneHeight)
    love.graphics.setColor(60/255, 171/255, 47/255)
    love.graphics.rectangle("fill", greenZoneX, barY, greenRange * 2, zoneHeight)
    love.graphics.setColor(1, 1, 1)
end

function drawAnvilCursor()
    local cursorY = 194 + 2 + 1
    local cursorX = 38 + 2 + cursorPos - 2
    love.graphics.draw(cursor, cursorX, cursorY)
end