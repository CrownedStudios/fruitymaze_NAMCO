local Player = {
    animations = {},

    gridX = 2,
    gridY = 2,

    currentDir = "right",
    intendedDir = "right",

    moveSpeed = 90 -- pixels per second,
}

-- Dependencies

local Maze = require("scripts.components.Maze")
local SpriteAnimator = require("scripts.util.SpriteAnimator")

-- Global Functions

function Player.load()
    Player.visualX = (Player.gridX - 1) * Maze.TILE_SIZE
    Player.visualY = (Player.gridY - 1) * Maze.TILE_SIZE

    local framesLeft = {
        love.graphics.newImage("assets/sprites/characters/player/walk/left_1.png"),
        love.graphics.newImage("assets/sprites/characters/player/walk/left_2.png")
    }

    local framesRight = {
        love.graphics.newImage("assets/sprites/characters/player/walk/right_1.png"),
        love.graphics.newImage("assets/sprites/characters/player/walk/right_2.png")
    }
    local framesUpRight = {
        love.graphics.newImage("assets/sprites/characters/player/walk/upright_1.png"),
    }

    local framesUpLeft = {
        love.graphics.newImage("assets/sprites/characters/player/walk/upleft_1.png"),
    }

    local framesDownRight = {
        love.graphics.newImage("assets/sprites/characters/player/walk/downright_1.png"),
    }

    local framesDownLeft = {
        love.graphics.newImage("assets/sprites/characters/player/walk/downleft_1.png"),
    }

    Player.animations["left"] = SpriteAnimator.new(framesLeft, 0.15)
    Player.animations["right"] = SpriteAnimator.new(framesRight, 0.15)
    Player.animations["upright"] = SpriteAnimator.new(framesUpRight, 0.15)
    Player.animations["upleft"] = SpriteAnimator.new(framesUpLeft, 0.15)
    Player.animations["downright"] = SpriteAnimator.new(framesDownRight, 0.15)
    Player.animations["downleft"] = SpriteAnimator.new(framesDownLeft, 0.15)
end

function Player.update(dt)
    -- 1. Capture player intent instantly from input
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        Player.intendedDir = "left"
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        Player.intendedDir = "right"
    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        Player.intendedDir = "up"
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        Player.intendedDir = "down"
    end

    -- Calculate our exact destination in pixels
    local targetX = (Player.gridX - 1) * Maze.TILE_SIZE
    local targetY = (Player.gridY - 1) * Maze.TILE_SIZE

    -- 2. Check if the player is perfectly aligned with their target tile
    if Player.visualX == targetX and Player.visualY == targetY then
        -- Try to turn in the INTENDED direction first
        local dx, dy = 0, 0
        if Player.intendedDir == "left" then
            dx = -1
        elseif Player.intendedDir == "right" then
            dx = 1
        elseif Player.intendedDir == "up" then
            dy = -1
        elseif Player.intendedDir == "down" then
            dy = 1
        end

        if Maze.isWalkable(Player.gridX + dx, Player.gridY + dy) then
            Player.currentDir = Player.intendedDir
            Player.gridX = Player.gridX + dx
            Player.gridY = Player.gridY + dy
        else
            -- Otherwise, try to keep moving straight
            dx, dy = 0, 0
            if Player.currentDir == "left" then
                dx = -1
            elseif Player.currentDir == "right" then
                dx = 1
            elseif Player.currentDir == "up" then
                dy = -1
            elseif Player.currentDir == "down" then
                dy = 1
            end

            if Maze.isWalkable(Player.gridX + dx, Player.gridY + dy) then
                Player.gridX = Player.gridX + dx
                Player.gridY = Player.gridY + dy
            end
        end
    end

    -- Recalculate target position after potentially updating grid coordinates
    targetX = (Player.gridX - 1) * Maze.TILE_SIZE
    targetY = (Player.gridY - 1) * Maze.TILE_SIZE

    -- Move X visually
    if Player.visualX < targetX then
        Player.visualX = math.min(Player.visualX + Player.moveSpeed * dt, targetX)
    elseif Player.visualX > targetX then
        Player.visualX = math.max(Player.visualX - Player.moveSpeed * dt, targetX)
    end

    -- Move Y visually
    if Player.visualY < targetY then
        Player.visualY = math.min(Player.visualY + Player.moveSpeed * dt, targetY)
    elseif Player.visualY > targetY then
        Player.visualY = math.max(Player.visualY - Player.moveSpeed * dt, targetY)
    end

    for _, animation in pairs(Player.animations) do
        animation:update(dt)
    end
end

function Player.draw()
    local state = "right"

    -- check combinations for diagonal facing states
    if (Player.currentDir == "right" and Player.intendedDir == "up") or
        (Player.currentDir == "up" and Player.intendedDir == "right") then
        state = "upright"
    elseif (Player.currentDir == "left" and Player.intendedDir == "up") or
        (Player.currentDir == "up" and Player.intendedDir == "left") then
        state = "upleft"
    elseif (Player.currentDir == "right" and Player.intendedDir == "down") or
        (Player.currentDir == "down" and Player.intendedDir == "right") then
        state = "downright"
    elseif (Player.currentDir == "left" and Player.intendedDir == "down") or
        (Player.currentDir == "down" and Player.intendedDir == "left") then
        state = "downleft"
    else
        -- if not angling into a turn, just use standard straight directions
        if Player.currentDir == "left" then
            state = "left"
        elseif Player.currentDir == "right" then
            state = "right"
            -- if moving straight up/down with no side intent, default to side sprites
        elseif Player.currentDir == "up" then
            state = "right"
        elseif Player.currentDir == "down" then
            state = "right"
        end
    end

    local activeAnimation = Player.animations[state] or Player.animations["right"]
    local sprite = activeAnimation:getCurrentFrame()

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, Player.visualX, Player.visualY, 0, scaleX, scaleY)
end

return Player
