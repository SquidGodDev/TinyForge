local Object = require "classes.classic"
ScoreController = Object:extend()

function ScoreController:new(count, x, y)
    self.count = count
    self.x = x
    self.y = y
    self.ASprite = love.graphics.newImage("assets/art/UI/result/A.png")
    self.BSprite = love.graphics.newImage("assets/art/UI/result/B.png")
    self.CSprite = love.graphics.newImage("assets/art/UI/result/C.png")
    self.XSprite = love.graphics.newImage("assets/art/UI/result/X.png")
    self.CheckSprite = love.graphics.newImage("assets/art/UI/result/Check.png")
    self.redSprite = love.graphics.newImage("assets/art/UI/result/red.png")
    self.yellowSprite = love.graphics.newImage("assets/art/UI/result/yellow.png")
    self.greenSprite = love.graphics.newImage("assets/art/UI/result/green.png")
    
    self.ScoreBackground = love.graphics.newImage("assets/art/UI/result/ScoreBackground.png")
    self.scores = {}
    self.scoreTotal = 0
end

function ScoreController:draw()
    local offset = 33
    for i=0, self.count - 1, 1 do
        love.graphics.draw(self.ScoreBackground, self.x + offset * i, self.y)
    end
    for i, score in ipairs(self.scores) do
        love.graphics.draw(score, self.x + offset * (i - 1), self.y)
    end
end

function ScoreController:addLetterScore(letter)
    if letter == 'A' then
        table.insert(self.scores, self.ASprite)
    elseif letter == 'B' then
        table.insert(self.scores, self.BSprite)
    elseif letter == 'C' then
        table.insert(self.scores, self.CSprite)
    else
        error()
    end
end

function ScoreController:addColorScore(color)
    if color == 'red' then
        table.insert(self.scores, self.redSprite)
    elseif color == 'yellow' then
        table.insert(self.scores, self.yellowSprite)
        self.scoreTotal = self.scoreTotal + 1
    elseif color == 'green' then
        table.insert(self.scores, self.greenSprite)
        self.scoreTotal = self.scoreTotal + 2
    else
        error()
    end
end

function ScoreController:addCheck()
    table.insert(self.scores, self.CheckSprite)
end

function ScoreController:addX()
    table.insert(self.scores, self.XSprite)
    self.scoreTotal = self.scoreTotal - 1
end

function ScoreController:getAggregateScore()
    return self.scoreTotal
end

function ScoreController:isFull()
    return #self.scores == self.count
end