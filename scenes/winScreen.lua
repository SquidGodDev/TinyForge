winScreen = {}

local background
local winSfx

function winScreen.load()
    background = love.graphics.newImage("assets/art/UI/winLoseScreens/winScreen.png")
    winSfx = love.audio.newSource("assets/sfx/winJingle.wav", "static")
    winSfx:play()
end

function winScreen.draw()
    love.graphics.draw(background, 0, 0)
end

function winScreen.update(dt)
end

function winScreen.keypressed(key)
    if key == "return" then
        change_scene(menu)
    end
end

function winScreen.keyreleased(key)
end