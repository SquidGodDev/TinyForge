require "scenes.furnace"
require "scenes.home"
require "scenes.anvil"
require "scenes.grindstone"
require "scenes.finalResult"
require "scenes.menu"
require "scenes.lossScreen"
require "scenes.winScreen"

Timer = require "classes.timer"

coins = 30
selectedMetal = "copper"
unlockedMetal = 1

furnaceScore = 1
anvilScore = 1
grindstoneScore = 1

furnaceTutorial = true
anvilTutorial = true
grindstoneTutorial = true

questActive = false
questCompleted = false
questNumber = 1
timeUntilNextQuest = 1
fulfilledOrders = 0

local transitionTimer = Timer.new()

local scene = nil
local scale = 5

local transitionTime = 0.5
local transitionAmount = { 0 }
local transitionMax = 400
local transitioning = false

function change_scene(s)
    if transitioning then
        return
    end

    transitioning = true
    transitionAmount = { 0 }
    transitionTimer:tween(transitionTime, transitionAmount, { transitionMax }, 'out-quad', function()
        scene = s
        scene.load()
        transitionAmount = { transitionMax }
        transitionTimer:tween(transitionTime, transitionAmount, { 0 }, 'in-quad', function()
            transitioning = false
        end)
    end)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.window.setMode(400*scale, 240*scale)
    font18 = love.graphics.newFont("assets/art/fonts/PixeloidSans.ttf", 18)
    font9 = love.graphics.newFont("assets/art/fonts/PixeloidSans.ttf", 9)
    
    scene = anvil
    scene.load()
end

function love.draw()
    love.graphics.scale(scale, scale)
    if scene ~= nil then
        scene.draw()
    end
    drawTransition()
end

function love.update(dt) 
    transitionTimer:update(dt)
    if scene ~= nil and not transitioning then
        scene.update(dt)
    end
end

function love.keypressed(key)
    if not transitioning then
        scene.keypressed(key)
    end
end

function love.keyreleased(key)
    if not transitioning then
        scene.keyreleased(key)
    end
end

function drawTransition()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, transitionAmount[1], 240)
    love.graphics.setColor(1, 1, 1)
end

function completeQuest()

end