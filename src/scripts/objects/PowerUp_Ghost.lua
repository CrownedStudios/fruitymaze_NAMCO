local PowerUp_Ghost = {
    sprites = {
        ["Static"] = love.graphics.newImage("assets/sprites/collectibles/power ups/ghost/ghost.png"),
    }
}
PowerUp_Ghost.__index = PowerUp_Ghost

-- Dependencies

local Maze = require("scripts.components.Maze")

-- Global Functions

function PowerUp_Ghost.new(gridX, gridY, tileSize)
    local self = setmetatable({}, PowerUp_Ghost)
    self.type = "magnet"

    self.gridX = gridX
    self.gridY = gridY

    self.x = (gridX - 1) * tileSize + (tileSize / 2)
    self.y = (gridY - 1) * tileSize + (tileSize / 2)

    self.sprite = PowerUp_Ghost.sprites["Static"]

    return self
end

function PowerUp_Ghost:draw()
    local sprite = self.sprite

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY)
end

function PowerUp_Ghost:collected()
    print("PowerUp_Ghost collected")
end

return PowerUp_Ghost
