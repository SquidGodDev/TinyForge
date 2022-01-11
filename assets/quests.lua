love.graphics.setDefaultFilter("nearest", "nearest", 1)

quests = {
    {
        requiredGrade = 'C',
        requiredMaterial = "copper",
        requiredNumber = 1,
        introduction = {
            text = "Blacksmith! We're being attacked by monsters, and I'm missing a sword! Can you make 1 COPPER sword of at least C-Grade to help me fight them off?",
            title = "Village Knight",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_18.png")
        },
        response = {
            text = "Thank you, blacksmith! I can push the monsters back with this!",
            title = "Village Knight",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_18.png")
        }
    },
    {
        requiredGrade = 'A',
        requiredMaterial = "copper",
        requiredNumber = 2,
        introduction = {
            text = "Blacksmith! The monsters have come back with stronger units, and now we need 2 COPPER swords of A-Grade for my fellow knights to fight them off!",
            title = "Village Knight",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_18.png")
        },
        response = {
            text = "Blacksmith, your excellent craftmanship has brought peace to our humble village. We managed to harvest BRONZE metal from the armor of the monsters.",
            title = "Village Knight",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_18.png")
        },
        rewardLevel = 2
    },
    {
        requiredGrade = 'A',
        requiredMaterial = "bronze",
        requiredNumber = 1,
        introduction = {
            text = "I would love to buy my son a nice, A-Grade BRONZE sword for his birthday. Do you think that would be possible?",
            title = "Local Merchant",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_13.png")
        },
        response = {
            text = "Wow, this is incredible! What immaculate craftmanship. My son is sure to be delighted.",
            title = "Local Merchant",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_13.png")
        }
    },
    {
        requiredGrade = 'B',
        requiredMaterial = "bronze",
        requiredNumber = 2,
        introduction = {
            text = "My buddy and I are going to go adventuring, and we hear you're pretty good. We need 2 B-Grade BRONZE swords. Nothing too fancy, but not too shabby either.",
            title = "Burly Adventurer",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_36.png")
        },
        response = {
            text = "I've went through many swords in my lifetime, but I've never had one weighted this well. Here's some IRON from the caves, I think you can make good use of it.",
            title = "Burly Adventurer",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_36.png")
        },
        rewardLevel = 3
    },
    {
        requiredGrade = 'C',
        requiredMaterial = "iron",
        requiredNumber = 2,
        introduction = {
            text = "I'm a knight from a neighboring village, and I've heard word of a skilled blacksmith. I'm looking for 2 C-Grade IRON swords for our garrison.",
            title = "Neighboring Knight",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_14.png")
        },
        response = {
            text = "So, the rumors were true! A human blacksmith on par with the legendary blacksmiths of the swamp. I will be following your career closely.",
            title = "Neighboring Knight",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_14.png")
        }
    },
    {
        requiredGrade = 'A',
        requiredMaterial = "iron",
        requiredNumber = 1,
        introduction = {
            text = "I am a lord from a neighboring town, and I require your finest A-Grade IRON sword. I pay handsomely, of course.",
            title = "Neighboring Lord",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_15.png")
        },
        response = {
            text = "Incredible - a swamp level blacksmith in my backyard! Never did I believe I would witness this in my lifetime. Please take this STEEL, we have no blacksmiths that can make use of this material.",
            title = "Neighboring Lord",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_15.png")
        },
        rewardLevel = 4
    },
    {
        requiredGrade = 'B',
        requiredMaterial = "steel",
        requiredNumber = 1,
        introduction = {
            text = "How long since I've set foot in a human village... Only steel can cut through our skin, so I require a B-Grade STEEL sword.",
            title = "Rock Gremlin",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_29.png")
        },
        response = {
            text = "A human made this? Our blacksmiths should be ashamed...",
            title = "Rock Gremlin",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_29.png")
        }
    },
    {
        requiredGrade = 'A',
        requiredMaterial = "steel",
        requiredNumber = 2,
        introduction = {
            text = "Blacksmith, make for me 2 A-Grade STEEL swords - I wish to sell your wares.",
            title = "Traveling Merchant",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_24.png")
        },
        response = {
            text = "I'm traveling to the Swamp Kingdom next - prepare yourself, they will hear of this. Take this GOLD, you will need it.",
            title = "Traveling Merchant",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_24.png")
        },
        rewardLevel = 5
    },
    {
        requiredGrade = 'C',
        requiredMaterial = "gold",
        requiredNumber = 1,
        introduction = {
            text = "Hello, fellow blacksmith. They consider me to be one of the legendary blacksmiths of the Swamp Kingdom. A human, unbelievable. Can you even make a C-Grade GOLD sword?",
            title = "Swamp Blacksmith",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_23.png")
        },
        response = {
            text = "I'm impressed you've gotten here, but there is still one last challenge you must complete...",
            title = "Swamp Blacksmith",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_23.png")
        }
    },
    {
        requiredGrade = 'A',
        requiredMaterial = "gold",
        requiredNumber = 2,
        introduction = {
            text = "It is I, King of the Swamp. I will not have you beating our blacksmiths. I shall give an impossible challenge - make not 1, but 2 A-Grade GOLD swords.",
            title = "King of the Swamp",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_12.png")
        },
        response = {
            text = "Incredible... We admit defeat. Please, teach us your ways.",
            title = "King of the Swamp",
            image = love.graphics.newImage("assets/art/portraits/2 Portraits with back/Icons_12.png")
        },
        rewardLevel = 6
    },
}