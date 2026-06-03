local Collectibles = {
    items = {},
    TILE_SIZE = 16
}

-- Dependencies

local Maze = require("scripts.components.Maze")

local Fruit = require("scripts.objects.Fruit")

local PowerUp_Magnet = require("scripts.objects.PowerUp_Magnet")
local PowerUp_Ghost = require("scripts.objects.PowerUp_Ghost")
local PowerUp_Speed = require("scripts.objects.PowerUp_Speed")

-- Global Functions

function Collectibles.generateCollectibles(yellowCount, redCount)
    Collectibles.items = {}

    local openTiles = {}
    local deadEnds = {}

    for y = 1, Maze.TILE_HEIGHT do
        for x = 1, Maze.TILE_WIDTH do
            if Maze.isWalkable(x, y) then
                local neighbors = 0
                if Maze.isWalkable(x + 1, y) then neighbors = neighbors + 1 end
                if Maze.isWalkable(x - 1, y) then neighbors = neighbors + 1 end
                if Maze.isWalkable(x, y + 1) then neighbors = neighbors + 1 end
                if Maze.isWalkable(x, y - 1) then neighbors = neighbors + 1 end

                local tileData = { x = x, y = y }
                if neighbors == 1 then
                    table.insert(deadEnds, tileData)
                else
                    table.insert(openTiles, tileData)
                end
            end
        end
    end

    -- shuffle dead ends list to make power-up selection random
    for i = #deadEnds, 2, -1 do
        local j = math.random(i)
        deadEnds[i], deadEnds[j] = deadEnds[j], deadEnds[i]
    end

    local deadEndIndex = 1

    for i = 1, redCount do
        if deadEndIndex <= #deadEnds then
            local tile = deadEnds[deadEndIndex]

            local isMagnet = math.random() > 0.4
            table.insert(Collectibles.items,
                isMagnet and PowerUp_Magnet.new(tile.x, tile.y, Collectibles.TILE_SIZE) or
                PowerUp_Ghost.new(tile.x, tile.y, Collectibles.TILE_SIZE))
            deadEndIndex = deadEndIndex + 1
        end
    end

    for i = 1, yellowCount do
        if deadEndIndex <= #deadEnds then
            local tile = deadEnds[deadEndIndex]
            table.insert(Collectibles.items, PowerUp_Speed.new(tile.x, tile.y, Collectibles.TILE_SIZE))
            deadEndIndex = deadEndIndex + 1
        end
    end

    for i = deadEndIndex, #deadEnds do
        local tile = deadEnds[i]
        table.insert(Collectibles.items, Fruit.new(tile.x, tile.y, Collectibles.TILE_SIZE))
    end

    for _, tile in ipairs(openTiles) do
        table.insert(Collectibles.items, Fruit.new(tile.x, tile.y, Collectibles.TILE_SIZE))
    end
end

function Collectibles.checkCollision(playerX, playerY, pickupRadius)
    local radius = pickupRadius or 8

    for i = #Collectibles.items, 1, -1 do
        local item = Collectibles.items[i]
        local dx = playerX - item.x
        local dy = playerY - item.y

        if math.sqrt(dx * dx + dy * dy) < radius then
            if item.collected then
                item:collected()
            end
            table.remove(Collectibles.items, i)
        end
    end

    return nil
end

function Collectibles.update(dt)
    for _, item in ipairs(Collectibles.items) do
        if item.update then
            item:update(dt)
        end
    end
end

function Collectibles.draw()
    for _, item in ipairs(Collectibles.items) do
        item:draw() -- Call the individual object's draw function directly!
    end
    love.graphics.setColor(1, 1, 1)
end

return Collectibles
