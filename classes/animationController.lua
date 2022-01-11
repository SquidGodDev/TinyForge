local Object = require "classes.classic"
AnimationController = Object:extend()

function AnimationController:new()
    self.animations = {}
end

function AnimationController:update(dt)
    for key, animation in pairs(self.animations) do
        animation.currentTime = animation.currentTime + dt
        if animation.currentTime >= animation.duration then
            animation.currentTime = animation.currentTime - animation.duration
        end
    end
end

function AnimationController:draw()
    for key, animation in pairs(self.animations) do
        local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
        love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], animation.x, animation.y)
    end
end

function AnimationController:newAnimation(image, width, height, duration, x, y)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}
    animation.x = x
    animation.y = y

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    table.insert(self.animations, animation)
end