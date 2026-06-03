local PowerUp_Magnet = {
    sprites = {
        ["Static"] = love.graphics.newImage("assets/sprites/collectibles/power ups/magnet/magnet.png"),
    }
}
PowerUp_Magnet.__index = PowerUp_Magnet

-- Dependencies

local Maze = require("scripts.components.Maze")

local Player = require("scripts.objects.Player")

-- Global Functions

function PowerUp_Magnet.new(worldX, worldY, tileSize)
    local self = setmetatable({}, PowerUp_Magnet)
    self.type = "magnet"

    self.x = worldX
    self.y = worldY
    self.tileSize = tileSize

    self.sprite = PowerUp_Magnet.sprites["Static"]

    return self
end

function PowerUp_Magnet:draw()
    local sprite = self.sprite

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    local ox = sprite:getWidth() / 2
    local oy = sprite:getHeight() / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY, ox, oy)
end

function PowerUp_Magnet:collected()
    Player.AddMagnet()
end

return PowerUp_Magnet
