local Maze = {
    TILE_SIZE = 16,
    TILE_DATA = {},
    TILE_WIDTH = 35,
    TILE_HEIGHT = 35,
}

-- Variables

local wallSprite

-- Global Functions

function Maze.load()
    wallSprite = love.graphics.newImage("assets/sprites/structure/bluebox.png")
end

function Maze.generateMaze()
    -- fill the map with walls (1) and empty spaces (0)
    for y = 1, Maze.TILE_HEIGHT do
        Maze.TILE_DATA[y] = {}
        for x = 1, Maze.TILE_WIDTH do
            Maze.TILE_DATA[y][x] = 1
        end
    end

    -- carve out paths
    for y = 2, Maze.TILE_HEIGHT - 1, 2 do
        for x = 2, Maze.TILE_WIDTH - 1, 2 do
            Maze.TILE_DATA[y][x] = 0

            -- randomly carve a path from this cell
            local directions = {}
            if x > 2 then table.insert(directions, "west") end
            if y > 2 then table.insert(directions, "north") end

            if #directions > 0 then
                local dir = directions[love.math.random(1, #directions)]
                if dir == "west" then
                    Maze.TILE_DATA[y][x - 1] = 0
                elseif dir == "north" then
                    Maze.TILE_DATA[y - 1][x] = 0
                end
            end
        end
    end

    -- ensure the starting position is walkable
    Maze.TILE_DATA[2][2] = 0
end

function Maze.isWalkable(gridX, gridY)
    if Maze.TILE_DATA[gridY] and Maze.TILE_DATA[gridY][gridX] then
        return Maze.TILE_DATA[gridY][gridX] == 0
    end
    return false
end

function Maze.draw()
    love.graphics.setColor(1, 1, 1)
    for y = 1, Maze.TILE_HEIGHT do
        for x = 1, Maze.TILE_WIDTH do
            if Maze.TILE_DATA[y][x] == 1 then
                love.graphics.draw(wallSprite, (x - 1) * Maze.TILE_SIZE, (y - 1) * Maze.TILE_SIZE)
            end
        end
    end
end

return Maze
