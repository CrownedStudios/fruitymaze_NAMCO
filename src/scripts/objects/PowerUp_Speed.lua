local PowerUp_Speed = {
    sprites = {
        ["Static"] = love.graphics.newImage("assets/sprites/collectibles/power ups/speed/speed.png"),
        ["Glitch"] = {
            love.graphics.newImage("assets/sprites/collectibles/power ups/speed/speed.png"),
            love.graphics.newImage("assets/sprites/collectibles/power ups/speed/speed_glitch_1.png"),
            love.graphics.newImage("assets/sprites/collectibles/power ups/speed/speed_glitch_2.png"),
            love.graphics.newImage("assets/sprites/collectibles/power ups/speed/speed_glitch_3.png"),
            love.graphics.newImage("assets/sprites/collectibles/power ups/speed/speed_glitch_4.png"),
        },
    }
}
PowerUp_Speed.__index = PowerUp_Speed

-- Dependencies

local Maze = require("scripts.components.Maze")

local Player = require("scripts.objects.player")

local SpriteAnimator = require("scripts.util.SpriteAnimator")

-- Global Functions

function PowerUp_Speed.new(gridX, gridY, tileSize)
    local self = setmetatable({}, PowerUp_Speed)
    self.type = "magnet"

    self.gridX = gridX
    self.gridY = gridY

    self.x = (gridX - 1) * tileSize + (tileSize / 2)
    self.y = (gridY - 1) * tileSize + (tileSize / 2)

    self.isGlitched = false

    self.sprite = PowerUp_Speed.sprites["Static"]
    self.spriteAnimator = SpriteAnimator.new(PowerUp_Speed.sprites["Glitch"], math.random(0.2, 0.6))

    return self
end

function PowerUp_Speed:update(dt)
    if self.isGlitched then
        self.spriteAnimator:update(dt)
    end
end

function PowerUp_Speed:draw()
    local activeAnimation = self.spriteAnimator
    local sprite = self.isGlitched and activeAnimation:getCurrentFrame() or self.sprite

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY)
end

function PowerUp_Speed:collected()
    Player.AddSpeed()
end

return PowerUp_Speed
