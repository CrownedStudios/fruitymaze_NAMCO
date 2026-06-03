local Fruit = {
    fruitTypes = { "Cherry", "Orange", "Grape" },
    fruitSprites = {
        ["Cherry"] = {
            ["Static"] = love.graphics.newImage("assets/sprites/collectibles/fruits/cherry/cherry.png"),
            ["Glitch"] = {
                love.graphics.newImage("assets/sprites/collectibles/fruits/cherry/cherry.png"),
                love.graphics.newImage("assets/sprites/collectibles/fruits/cherry/cherry_glitch_1.png"),
                love.graphics.newImage("assets/sprites/collectibles/fruits/cherry/cherry_glitch_2.png"),
            },
        },

        ["Orange"] = {
            ["Static"] = love.graphics.newImage("assets/sprites/collectibles/fruits/orange/orange.png"),
            ["Glitch"] = {
                love.graphics.newImage("assets/sprites/collectibles/fruits/orange/orange.png"),
                love.graphics.newImage("assets/sprites/collectibles/fruits/orange/orange_glitch.png"),
            },
        },

        ["Grape"] = {
            ["Static"] = love.graphics.newImage("assets/sprites/collectibles/fruits/grape/grape.png"),
            ["Glitch"] = {
                love.graphics.newImage("assets/sprites/collectibles/fruits/grape/grape.png"),
                love.graphics.newImage("assets/sprites/collectibles/fruits/grape/grape_glitch_1.png"),
                love.graphics.newImage("assets/sprites/collectibles/fruits/grape/grape_glitch_2.png"),
            },
        },
    }
}
Fruit.__index = Fruit

-- Dependencies

local Maze = require("scripts.components.Maze")

local SpriteAnimator = require("scripts.util.SpriteAnimator")

-- Local Functions

local function chooseRandomFruit()
    return Fruit.fruitTypes[math.random(#Fruit.fruitTypes)]
end

-- Global Functions

function Fruit.new(worldX, worldY, tileSize)
    local self = setmetatable({}, Fruit)
    self.type = "fruit"
    self.fruitType = chooseRandomFruit()

    self.x = worldX
    self.y = worldY
    self.tileSize = tileSize

    self.isGlitched = false

    self.sprite = Fruit.fruitSprites[self.fruitType]["Static"]
    self.spriteAnimator = SpriteAnimator.new(Fruit.fruitSprites[self.fruitType]["Glitch"], math.random(0.2, 0.6))

    return self
end

function Fruit:update(dt)
    if self.isGlitched then
        self.spriteAnimator:update(dt)
    end
end

function Fruit:draw()
    local activeAnimation = self.spriteAnimator
    local sprite = self.isGlitched and activeAnimation:getCurrentFrame() or self.sprite

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    local ox = sprite:getWidth() / 2
    local oy = sprite:getHeight() / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY, ox, oy)
end

function Fruit:collected()
    print("Fruit collected!")
end

return Fruit
