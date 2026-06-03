local Maze = {
    TILE_SIZE = 16,
    TILE_WIDTH = 35,
    TILE_HEIGHT = 35,

    GRID = {},
    SPRITE_GRID = {},
}

-- Variables

local wallSprites = {
    ["Horizontal Between"] = love.graphics.newImage("assets/sprites/structure/wall_horizontal_between.png"),
    ["Vertical Between"] = love.graphics.newImage("assets/sprites/structure/wall_vertical_between.png"),

    ["Horizontal End Right"] = love.graphics.newImage("assets/sprites/structure/wall_horizontal_end_right.png"),
    ["Horizontal End Left"] = love.graphics.newImage("assets/sprites/structure/wall_horizontal_end_left.png"),

    ["Vertical End Up"] = love.graphics.newImage("assets/sprites/structure/wall_vertical_end_up.png"),
    ["Vertical End Down"] = love.graphics.newImage("assets/sprites/structure/wall_vertical_end_down.png"),

    ["Corner Upper Left"] = love.graphics.newImage("assets/sprites/structure/wall_corner_upperleft.png"),
    ["Corner Upper Right"] = love.graphics.newImage("assets/sprites/structure/wall_corner_upperright.png"),
    ["Corner Lower Left"] = love.graphics.newImage("assets/sprites/structure/wall_corner_lowerleft.png"),
    ["Corner Lower Right"] = love.graphics.newImage("assets/sprites/structure/wall_corner_lowerright.png"),

    ["Intersection Up"] = love.graphics.newImage("assets/sprites/structure/wall_intersection_up.png"),
    ["Intersection Down"] = love.graphics.newImage("assets/sprites/structure/wall_intersection_down.png"),
    ["Intersection Left"] = love.graphics.newImage("assets/sprites/structure/wall_intersection_left.png"),
    ["Intersection Right"] = love.graphics.newImage("assets/sprites/structure/wall_intersection_right.png"),
    ["Intersection All"] = love.graphics.newImage("assets/sprites/structure/wall_intersection_all.png"),
}

-- Local Functions

local function isWall(x, y)
    if x < 1 or x > Maze.TILE_WIDTH or y < 1 or y > Maze.TILE_HEIGHT then
        return false
    end
    return Maze.GRID[y] and Maze.GRID[y][x] == 1
end

-- Global Functions

function Maze.generateMaze()
    Maze.GRID = {}

    -- fill the map with walls (1) and empty spaces (0)
    for y = 1, Maze.TILE_HEIGHT do
        Maze.GRID[y] = {}
        for x = 1, Maze.TILE_WIDTH do
            Maze.GRID[y][x] = 1
        end
    end

    -- carve out paths
    for y = 2, Maze.TILE_HEIGHT - 1, 2 do
        for x = 2, Maze.TILE_WIDTH - 1, 2 do
            Maze.GRID[y][x] = 0

            -- randomly carve a path from this cell
            local directions = {}
            if x > 2 then table.insert(directions, "west") end
            if y > 2 then table.insert(directions, "north") end

            if #directions > 0 then
                local dir = directions[love.math.random(1, #directions)]
                if dir == "west" then
                    Maze.GRID[y][x - 1] = 0
                elseif dir == "north" then
                    Maze.GRID[y - 1][x] = 0
                end
            end
        end
    end

    Maze.calculateAutotiles()
end

function Maze.calculateAutotiles()
    Maze.SPRITE_GRID = {}

    for y = 1, Maze.TILE_HEIGHT do
        Maze.SPRITE_GRID[y] = {}
        for x = 1, Maze.TILE_WIDTH do
            if isWall(x, y) then
                -- check neighbors to form the adjacency mask
                local u = isWall(x, y - 1)
                local d = isWall(x, y + 1)
                local l = isWall(x - 1, y)
                local r = isWall(x + 1, y)

                local spriteKey = nil

                -- 4-Way intersections
                if u and d and l and r then
                    spriteKey = "Intersection All"

                    -- 3-Way intersections (t-junctions)
                elseif l and r and d and not u then
                    spriteKey = "Intersection Down"
                elseif l and r and u and not d then
                    spriteKey = "Intersection Up"
                elseif u and d and r and not l then
                    spriteKey = "Intersection Right"
                elseif u and d and l and not r then
                    spriteKey = "Intersection Left"

                    -- 2-Way corners
                elseif l and d and not u and not r then
                    spriteKey = "Corner Upper Right"
                elseif r and d and not u and not l then
                    spriteKey = "Corner Upper Left"
                elseif l and u and not d and not r then
                    spriteKey = "Corner Lower Right"
                elseif r and u and not d and not l then
                    spriteKey = "Corner Lower Left"

                    -- straight channels (Between)
                elseif l and r then
                    spriteKey = "Horizontal Between"
                elseif u and d then
                    spriteKey = "Vertical Between"

                    -- dead end caps (1 Neighbor or lone Wall element)
                elseif l then
                    spriteKey = "Horizontal End Right" -- Connected to left, caps off on the right
                elseif r then
                    spriteKey = "Horizontal End Left"  -- Connected to right, caps off on the left
                elseif u then
                    spriteKey = "Vertical End Down"    -- Connected to top, caps off on the bottom
                elseif d then
                    spriteKey = "Vertical End Up"      -- Connected to bottom, caps off on the top
                else
                    spriteKey = "Intersection All"     -- Solid block fallback
                end

                Maze.SPRITE_GRID[y][x] = spriteKey
            end
        end
    end
end

function Maze.draw()
    for y = 1, Maze.TILE_HEIGHT do
        for x = 1, Maze.TILE_WIDTH do
            local spriteKey = Maze.SPRITE_GRID[y] and Maze.SPRITE_GRID[y][x]
            if spriteKey and wallSprites[spriteKey] then
                local drawX = (x - 1) * Maze.TILE_SIZE
                local drawY = (y - 1) * Maze.TILE_SIZE

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(wallSprites[spriteKey], drawX, drawY)
            end
        end
    end
end

function Maze.isWalkable(x, y)
    if x < 1 or x > Maze.TILE_WIDTH or y < 1 or y > Maze.TILE_HEIGHT then
        return false
    end
    return Maze.GRID[y] and Maze.GRID[y][x] == 0
end

return Maze
