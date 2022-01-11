love.graphics.setDefaultFilter("nearest", "nearest", 1)
dialog = {
    introduction = {
        text = "Welcome to your first day as a blacksmith! Press ENTER on the copper to buy it and start forging your first sword!",
        title = "Master Blacksmith",
        image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_01.png")
    },
    furnaceTutorial = {
        text = "Welcome to the forge! Heat the metal by keeping the bar over the fire icon. You can move the bar up by holding SPACE and let it fall by releasing SPACE. Fill up the heat bar to the right. If the heat falls to 0, you get an X. 3 X's and you fail.",
        title = "Master Blacksmith",
        image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_01.png")
    },
    anvilTutorial = {
        text = "Welcome to the anvil! Hammer the sword by pressing space right as the marker is over the green zone. Strike 3 times in total! How well you do on each strike determines your hammering score.",
        title = "Master Blacksmith",
        image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_01.png")
    },
    grindstoneTutorial = {
        text = "Welcome to the grindstone! Sharpen the sword perfectly by holding SPACE and letting go. The marker slides to a stop. Get the marker right in the green zone!",
        title = "Master Blacksmith",
        image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_01.png")
    },
    loss = {
        text = "Looks like you ran out of money... Tough being a blacksmith.",
        title = "Master Blacksmith",
        image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_01.png")
    }
}