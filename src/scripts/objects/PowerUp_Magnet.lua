local PowerUp_Magnet = {
    sprites = {
        ["Static"] = love.graphics.newImage("assets/sprites/collectibles/power ups/magnet/magnet.png"),
    }
}
PowerUp_Magnet.__index = PowerUp_Magnet

-- Dependencies

local Maze = require("scripts.components.Maze")

-- Global Functions

function PowerUp_Magnet.new(gridX, gridY, tileSize)
    local self = setmetatable({}, PowerUp_Magnet)
    self.type = "magnet"

    self.gridX = gridX
    self.gridY = gridY

    self.x = (gridX - 1) * tileSize + (tileSize / 2)
    self.y = (gridY - 1) * tileSize + (tileSize / 2)

    self.sprite = PowerUp_Magnet.sprites["Static"]

    return self
end

function PowerUp_Magnet:draw()
    local sprite = self.sprite

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY)
end

function PowerUp_Magnet:collected()
    print("Magnet collected")
end

return PowerUp_Magnet
