require "classes.animationController"
require "classes.scoreController"
require "classes.resultDisplay"
require "scenes.anvil"
require "assets.dialog"
local Dialove = require('Dialove')

local dialogManager
local showDialog = false

local Timer = require "classes.timer"

furnace = {}

local fireSfx, risingSfx, successSfx, buzzerSfx
local risingVolume = { 1 }
local risingTimer
local barWasInFire = false

local animationController, scoreController, resultDisplay

local stopped = false

local fireMeter, fireBar, fire, heatMeter, metalBar
local metalBarPosBase, metalBarMoveTime = 156, 3
local metalBarPos = { metalBarPosBase }
local metalBarOffseted = false

local maxFire = 214 - 2
local firePos = { maxFire / 2 }
-- Difficulty adjustment: fireMoveTime
local fireMoveTime = 1.5
local fireIsMoving = false

-- Difficulty adjustment: fireBarSize
local fireBarPos, fireBarSize = 0, 20
local maxFireBar

-- Difficulty adjustment: fireBarAcceleration, fireBarDeceleration
local fireBarAcceleration = 3
local fireBarDeceleration = 3
local fireBarMaxSpeed = 5
local fireBarSpeed = 0

-- Difficulty adjustment: heatGainVelocity, heatLossVelocity
local maxHeat = 213
local heatLevel = maxHeat / 2
local heatGainVelocity = 20
local heatLossVelocity = 10

function furnace.load()
    setFurnaceDifficulty()
    resetFurnace()

    dialogManager = Dialove.init({
        font = font9,
        viewportW = 400,
        viewportH = 240,
    })
    
    if furnaceTutorial then
        dialogManager:show(dialog["furnaceTutorial"])
        stopped = true
        showDialog = true
        furnaceTutorial = false
    end
    
    fireMeter = love.graphics.newImage("assets/art/UI/furnace/fireMeter.png")
    fire = love.graphics.newImage("assets/art/UI/furnace/fire.png")
    heatMeter = love.graphics.newImage("assets/art/UI/furnace/heatMeter.png")
    metalBar = love.graphics.newImage("assets/art/UI/furnace/hotMetal.png")

    local furnaceSpritesheet = love.graphics.newImage("assets/art/UI/furnace/furnace.png")
    animationController = AnimationController()
    animationController:newAnimation(furnaceSpritesheet, 400, 240, 1, 0, 0)
    
    scoreController = ScoreController(3, 20, 20)

    resultDisplay = ResultDisplay(anvil)

    Timer.clear()
    moveMetalBar()
    Timer.every(metalBarMoveTime, moveMetalBar)

    fireSfx = love.audio.newSource("assets/sfx/fire.mp3", "static")
    fireSfx:setLooping(true)
    fireSfx:play()
    risingSfx = love.audio.newSource("assets/sfx/rising.wav", "static")
    risingTimer = Timer.new()
    barWasInFire = false
    successSfx = love.audio.newSource("assets/sfx/fanfare.wav", "static")
    buzzerSfx = love.audio.newSource("assets/sfx/buzzer.wav", "static")
end

function resetFurnace()
    maxFireBar = maxFire - fireBarSize * 2
    stopped = false
    fireIsMoving = false
    fireBarSpeed = 0
    heatLevel = maxHeat / 2
end

function furnace.draw()
    animationController:draw()
    love.graphics.draw(fireMeter, 334, 12)
    love.graphics.draw(heatMeter, 364, 12)
    drawFireBar()
    drawFire()
    drawHeatLevel()
    love.graphics.draw(metalBar, metalBarPos[1], 173)
    scoreController:draw()
    resultDisplay:draw(anvil)
    dialogManager:draw()
end

function furnace.update(dt)
    animationController:update(dt)
    Timer.update(dt)
    risingTimer:update(dt)
    updateFireBar(dt)
    updateFire(dt)
    updateHeat(dt)
    resultDisplay:update(dt)
    dialogManager:update(dt)
end

function furnace.keypressed(key)
    if showDialog then
        if key == "return" then
            if dialogManager:getActiveDialog().done then
                dialogManager:pop()
                showDialog = false
                stopped = false
            else
                dialogManager:complete()
            end
        end
        return
    end
end

function furnace.keyreleased(key)
end

function setFurnaceDifficulty()
    if selectedMetal == "copper" then
        fireBarSize = 30
        fireMoveTime = 1.5
        heatGainVelocity = 20
        heatLossVelocity = 10
    elseif selectedMetal == "bronze" then
        fireBarSize = 25
        fireMoveTime = 1.4
        heatGainVelocity = 20
        heatLossVelocity = 10
    elseif selectedMetal == "iron" then
        fireBarSize = 20
        fireMoveTime = 1.3
        heatGainVelocity = 20
        heatLossVelocity = 10
    elseif selectedMetal == "steel" then
        fireBarSize = 15
        fireMoveTime = 1.2
        heatGainVelocity = 20
        heatLossVelocity = 10
    elseif selectedMetal == "gold" then
        fireBarSize = 10
        fireMoveTime = 1.1
        heatGainVelocity = 20
        heatLossVelocity = 10
    end
end

function updateFireBar(dt)
    if stopped then
        return
    end

    if love.keyboard.isDown("space") then
        fireBarSpeed = fireBarSpeed + dt * fireBarAcceleration
        if fireBarSpeed >= fireBarMaxSpeed then
            fireBarSpeed = fireBarMaxSpeed
        end
    else
        fireBarSpeed = fireBarSpeed - dt * fireBarDeceleration
        if fireBarSpeed <= -fireBarMaxSpeed then
            fireBarSpeed = -fireBarMaxSpeed
        end
    end
    fireBarPos = fireBarPos - fireBarSpeed
    if fireBarPos >= maxFireBar then
        fireBarPos = maxFireBar
        fireBarSpeed = 0
    elseif fireBarPos <= 0 then
        fireBarPos = 0
        fireBarSpeed = 0
    end
end

function updateFire(dt)
    if stopped then
        return
    end

    if not fireIsMoving then
        fireIsMoving = true
        Timer.script(moveFire)
    end
end

function moveFire()
    if stopped then
        return
    end

    local randomPos = love.math.random(0, maxFire)
    Timer.tween(fireMoveTime, firePos, {randomPos}, 'in-out-cubic', function()
        local waitTime = love.math.random(0, 10) / 10
        Timer.after(waitTime, function()
            fireIsMoving = false
        end)
    end)
end

function updateHeat(dt)
    if stopped then
        return
    end

    risingSfx:setVolume(risingVolume[1])

    if barInFire() then
        heatLevel = heatLevel + heatGainVelocity * dt
        risingVolume = { 1 }
        risingTimer:clear()
        risingSfx:play()
        barWasInFire = true
    else
        heatLevel = heatLevel - heatLossVelocity * dt
        if barWasInFire then
            barWasInFire = false
            risingTimer:tween(1, risingVolume, { 0 }, 'linear', function()
                risingSfx:stop()
            end)
        end
    end
    if heatLevel >= maxHeat then
        heatLevel = maxHeat
        heatFull()
    elseif heatLevel <= 0 then
        heatLevel = 0
        heatEmpty()
    end
end

function barInFire()
    if firePos[1] <= fireBarPos + fireBarSize * 2 and firePos[1] >= fireBarPos then
        return true
    end
    return false
end

function heatFull()
    stopped = true
    Timer.clear()
    resultDisplay:setScore(getResult())
    stopFurnaceAudio()
    successSfx:play()
end

function heatEmpty()
    scoreController:addX()
    heatLevel = maxHeat / 2
    buzzerSfx:play()
    if scoreController:isFull() then
        stopped = true
        Timer.clear()
        resultDisplay:setScore('F')
        stopFurnaceAudio()
    end
end

function stopFurnaceAudio()
    fireSfx:stop()
    risingSfx:stop()
end

function getResult()
    local aggregateScore = scoreController:getAggregateScore()
    if aggregateScore == 0 then
        furnaceScore = 2
        return 'A'
    elseif aggregateScore == -1 then
        furnaceScore = 1
        return 'B'
    else
        furnaceScore = 0
        return 'C'
    end
end

function drawFireBar()
    love.graphics.setColor(86/255, 86/255, 123/255)
    love.graphics.rectangle("fill", 336, fireBarPos + 14, 20, fireBarSize * 2, 2, 2)
    love.graphics.setColor(1, 1, 1)
end

function drawFire()
    love.graphics.draw(fire, 337, firePos[1])
end

function drawHeatLevel()
    love.graphics.setColor(232/255, 68/255, 68/255)
    love.graphics.rectangle("fill", 365, 13 + maxHeat - heatLevel, 8, heatLevel)
    love.graphics.setColor(1, 1, 1)
end

function moveMetalBar()
    local newPos = metalBarPosBase
    local offset = 10
    if not metalBarOffseted then
        newPos = newPos + offset
    end
    metalBarOffseted = not metalBarOffseted
    Timer.tween(metalBarMoveTime, metalBarPos, { newPos }, 'in-out-quad')
end