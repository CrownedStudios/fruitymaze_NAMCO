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

local Player = require("scripts.objects.Player")

local SpriteAnimator = require("scripts.util.SpriteAnimator")

-- Global Functions

function PowerUp_Speed.new(worldX, worldY, tileSize)
    local self = setmetatable({}, PowerUp_Speed)
    self.type = "magnet"

    self.x = worldX
    self.y = worldY
    self.tileSize = tileSize

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

    local ox = sprite:getWidth() / 2
    local oy = sprite:getHeight() / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY, ox, oy)
end

function PowerUp_Speed:collected()
    Player.AddSpeed()
end

return PowerUp_Speed
