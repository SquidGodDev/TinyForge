lossScreen = {}

local background
local loseSfx

function lossScreen.load()
    background = love.graphics.newImage("assets/art/UI/winLoseScreens/loseScreen.png")
    loseSfx = love.audio.newSource("assets/sfx/loseJingle.wav", "static")
    loseSfx:play()
end

function lossScreen.draw()
    love.graphics.draw(background, 0, 0)
end

function lossScreen.update(dt)
end

function lossScreen.keypressed(key)
    if key == "return" then
        change_scene(menu)
    end
end

function lossScreen.keyreleased(key)
end