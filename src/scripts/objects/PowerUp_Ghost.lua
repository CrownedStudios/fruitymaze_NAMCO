local PowerUp_Ghost = {
    sprites = {
        ["Static"] = love.graphics.newImage("assets/sprites/collectibles/power ups/ghost/ghost.png"),
    }
}
PowerUp_Ghost.__index = PowerUp_Ghost

-- Dependencies

local Maze = require("scripts.components.Maze")

local Player = require("scripts.objects.Player")

-- Global Functions

function PowerUp_Ghost.new(worldX, worldY, tileSize)
    local self = setmetatable({}, PowerUp_Ghost)
    self.type = "magnet"

    self.x = worldX
    self.y = worldY
    self.tileSize = tileSize

    self.sprite = PowerUp_Ghost.sprites["Static"]

    return self
end

function PowerUp_Ghost:draw()
    local sprite = self.sprite

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    local ox = sprite:getWidth() / 2
    local oy = sprite:getHeight() / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY, ox, oy)
end

function PowerUp_Ghost:collected()
    Player.AddGhost()
end

return PowerUp_Ghost
