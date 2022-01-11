require "scenes.home"

local Object = require "classes.classic"
ResultDisplay = Object:extend()

function ResultDisplay:new(nextScene)
    self.x = 128
    self.y = 65
    self.result = nil
    self.background = love.graphics.newImage("assets/art/UI/result/ResultBackground.png")
    self.ASprite = love.graphics.newImage("assets/art/UI/result/A.png")
    self.BSprite = love.graphics.newImage("assets/art/UI/result/B.png")
    self.CSprite = love.graphics.newImage("assets/art/UI/result/C.png")
    self.FSprite = love.graphics.newImage("assets/art/UI/result/F.png")

    self.nextScene = nextScene
end

function ResultDisplay:draw()
    if self.result ~= nil then
        love.graphics.draw(self.background, self.x, self.y)
        love.graphics.draw(self.result, self.x + 94, self.y + 42)
    end
end

function ResultDisplay:update(dt)
    if love.keyboard.isDown("return") and self.result ~= nil then
        change_scene(self.nextScene)
    end
end

function ResultDisplay:setScore(score)
    if score == 'A' then
        self.result = self.ASprite
    elseif score == 'B' then
        self.result = self.BSprite
    elseif score == 'C' then
        self.result = self.CSprite
    elseif score == 'F' then
        self.background = love.graphics.newImage("assets/art/UI/result/ResultBackgroundFail.png")
        self.result = self.FSprite
        self:setNextSceneToHome()
    else
        error()
    end
end

function ResultDisplay:setNextSceneToHome()
    self.nextScene = home
end