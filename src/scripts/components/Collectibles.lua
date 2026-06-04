local Collectibles = {
    ITEMS = {},
    TILE_SIZE = 16
}

-- Dependencies

local Maze = require("scripts.components.Maze")

local Player = require("scripts.objects.Player")

local Fruit = require("scripts.objects.Fruit")
local PowerUp_Magnet = require("scripts.objects.PowerUp_Magnet")
local PowerUp_Ghost = require("scripts.objects.PowerUp_Ghost")
local PowerUp_Speed = require("scripts.objects.PowerUp_Speed")

-- Global Functions

function Collectibles.generateCollectibles(yellowCount, redCount)
    Collectibles.ITEMS = {}

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

    local function getCenterPos(gridX, gridY)
        local worldX = (gridX - 1) * Collectibles.TILE_SIZE + (Collectibles.TILE_SIZE / 2)
        local worldY = (gridY - 1) * Collectibles.TILE_SIZE + (Collectibles.TILE_SIZE / 2)

        return worldX, worldY
    end

    local deadEndIndex = 1

    for i = 1, redCount do
        if deadEndIndex <= #deadEnds then
            local tile = deadEnds[deadEndIndex]
            local wx, wy = getCenterPos(tile.x, tile.y)

            local isMagnet = math.random() > 0.4
            table.insert(Collectibles.ITEMS,
                isMagnet and PowerUp_Magnet.new(wx, wy, Collectibles.TILE_SIZE) or
                PowerUp_Ghost.new(wx, wy, Collectibles.TILE_SIZE))
            deadEndIndex = deadEndIndex + 1
        end
    end
    for i = 1, yellowCount do
        if deadEndIndex <= #deadEnds then
            local tile = deadEnds[deadEndIndex]
            local wx, wy = getCenterPos(tile.x, tile.y)
            table.insert(Collectibles.ITEMS, PowerUp_Speed.new(wx, wy, Collectibles.TILE_SIZE))
            deadEndIndex = deadEndIndex + 1
        end
    end
    for i = deadEndIndex, #deadEnds do
        local tile = deadEnds[i]
        local wx, wy = getCenterPos(tile.x, tile.y)
        table.insert(Collectibles.ITEMS, Fruit.new(wx, wy, Collectibles.TILE_SIZE))
    end

    local fruitSpacing = 1
    local stepCounter = 0
    for _, tile in ipairs(openTiles) do
        if stepCounter == 0 then
            local wx, wy = getCenterPos(tile.x, tile.y)
            table.insert(Collectibles.ITEMS, Fruit.new(wx, wy, Collectibles.TILE_SIZE))
        end

        stepCounter = (stepCounter + 1) % fruitSpacing
    end
end

function Collectibles.checkCollision(playerX, playerY, pickupRadius)
    local radius = pickupRadius or 8

    local playerCenterX = playerX + (Maze.TILE_SIZE / 2)
    local playerCenterY = playerY + (Maze.TILE_SIZE / 2)

    for i = #Collectibles.ITEMS, 1, -1 do
        local item = Collectibles.ITEMS[i]
        local dx = playerX - item.x
        local dy = playerY - item.y

        if math.sqrt(dx * dx + dy * dy) < radius then
            if item.collected then
                item:collected()
            end
            table.remove(Collectibles.ITEMS, i)
        end
    end

    return nil
end

function Collectibles.update(dt)
    local playerCenterX = Player.visualX + (Maze.TILE_SIZE / 2)
    local playerCenterY = Player.visualY + (Maze.TILE_SIZE / 2)

    local magnetRange = 100
    local pullSpeed = 150
    local returnSpeed = 120

    for _, item in ipairs(Collectibles.ITEMS) do
        if item.type == "fruit" then
            local dx = playerCenterX - item.x
            local dy = playerCenterY - item.y
            local distance = math.sqrt(dx * dx + dy * dy)

            -- State A: Under magnet attraction influence
            if Player.hasMagnet and distance < magnetRange and distance > 0 then
                item.x = item.x + (dx / distance) * pullSpeed * dt
                item.y = item.y + (dy / distance) * pullSpeed * dt

                -- Flag this item as currently "displaced" by a magnet
                item.wasPulled = true

                -- State B: Magnet just shut off, recalculate a safe local home where it dropped!
            elseif item.wasPulled then
                item.wasPulled = false -- Reset flag so this only triggers once

                -- Convert its current loose pixel spot to a 1-based grid position
                local gx = math.floor(item.x / Maze.TILE_SIZE) + 1
                local gy = math.floor(item.y / Maze.TILE_SIZE) + 1

                -- If it's in an open pathway, anchor it right here!
                if Maze.isWalkable(gx, gy) then
                    item.homeX = (gx - 1) * Maze.TILE_SIZE + (Maze.TILE_SIZE / 2)
                    item.homeY = (gy - 1) * Maze.TILE_SIZE + (Maze.TILE_SIZE / 2)
                else
                    -- If it stopped mid-wall, find the absolute closest open tile to settle in
                    local minDistance = 999999
                    for dy = -1, 1 do
                        for dx = -1, 1 do
                            if Maze.isWalkable(gx + dx, gy + dy) then
                                local wx = (gx + dx - 1) * Maze.TILE_SIZE + (Maze.TILE_SIZE / 2)
                                local wy = (gy + dy - 1) * Maze.TILE_SIZE + (Maze.TILE_SIZE / 2)
                                local dist = math.sqrt((item.x - wx) ^ 2 + (item.y - wy) ^ 2)
                                if dist < minDistance then
                                    minDistance = dist
                                    item.homeX = wx
                                    item.homeY = wy
                                end
                            end
                        end
                    end
                end

                -- State C: Smoothly settle into whatever its active home anchor is
            elseif item.homeX and item.homeY then
                local hdx = item.homeX - item.x
                local hdy = item.homeY - item.y
                local homeDist = math.sqrt(hdx * hdx + hdy * hdy)

                if homeDist > 0.5 then
                    item.x = item.x + (hdx / homeDist) * returnSpeed * dt
                    item.y = item.y + (hdy / homeDist) * returnSpeed * dt
                else
                    item.x = item.homeX
                    item.y = item.homeY
                end
            end
        end

        if item.update then
            item:update(dt)
        end
    end
end

function Collectibles.draw()
    for _, item in ipairs(Collectibles.ITEMS) do
        item:draw()
    end
    love.graphics.setColor(1, 1, 1)
end

return Collectibles
