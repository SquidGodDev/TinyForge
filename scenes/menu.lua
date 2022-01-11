menu = {}

local background

local gameStartSfx

function menu.load()
    background = love.graphics.newImage("assets/art/UI/menu/menu.png")
    gameStartSfx = love.audio.newSource("assets/sfx/gameStart.ogg", "static")
end

function menu.draw()
    love.graphics.draw(background, 0, 0)
end

function menu.update(dt)
end

function menu.keypressed(key)
    if key == "return" then
        resetGame()
        gameStartSfx:play()
        change_scene(home)
    end
end

function menu.keyreleased(key)
end

function resetGame()
    coins = 30
    selectedMetal = "copper"
    unlockedMetal = 5
    questNumber = 1
    timeUntilNextQuest = 1
    fulfilledOrders = 0
end