local Player = {
    animations = {},
    sprites = {
        ["Normal"] = {
            ["Up"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/up_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk/up_2.png"),
            },
            ["Down"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/down_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk/down_2.png"),
            },
            ["Left"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/left_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk/left_2.png"),
            },
            ["Right"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/right_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk/right_2.png"),
            },

            ["UpRight"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/upright_1.png"),
            },
            ["UpLeft"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/upleft_1.png"),
            },
            ["DownRight"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/downright_1.png"),
            },
            ["DownLeft"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk/downleft_1.png"),
            },
        },
        ["Scared"] = {
            ["Up"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/up_scared_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk scared/up_scared_2.png"),
            },
            ["Down"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/down_scared_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk scared/down_scared_2.png"),
            },
            ["Left"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/left_scared_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk scared/left_scared_2.png"),
            },
            ["Right"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/right_scared_1.png"),
                love.graphics.newImage("assets/sprites/characters/player/walk scared/right_scared_2.png"),
            },

            ["UpRight"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/upright_scared_1.png"),
            },
            ["UpLeft"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/upleft_scared_1.png"),
            },
            ["DownRight"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/downright_scared_1.png"),
            },
            ["DownLeft"] = {
                love.graphics.newImage("assets/sprites/characters/player/walk scared/downleft_scared_1.png"),
            },
        }
    },

    gridX = 2,
    gridY = 2,

    currentDir = "right",
    intendedDir = "right",

    moveSpeed_Normal = 90, -- pixels per second
    moveSpeed_Speed = 160, -- pixels per second

    hasSpeed = false,
    hasMagnet = false,
    hasGhost = false,

    setSpeedTimer = 15,
    setMagnetTimer = 15,
    setGhostTimer = 10,

    hasSpawned = false,
    hasMoved = false,
    playerLocked = false,
}

-- Dependencies

local Maze = require("scripts.components.Maze")

local SpriteAnimator = require("scripts.util.SpriteAnimator")

-- Global Functions

function Player.load()
    Player.moveSpeed = Player.moveSpeed_Normal

    Player.visualX = (Player.gridX - 1) * Maze.TILE_SIZE
    Player.visualY = (Player.gridY - 1) * Maze.TILE_SIZE

    Player.speedTimer = Player.setSpeedTimer
    Player.magnetTimer = Player.setMagnetTimer
    Player.ghostTimer = Player.setGhostTimer

    Player.animations["up"] = SpriteAnimator.new(Player.sprites["Normal"]["Up"], 0.15)
    Player.animations["down"] = SpriteAnimator.new(Player.sprites["Normal"]["Down"], 0.15)
    Player.animations["left"] = SpriteAnimator.new(Player.sprites["Normal"]["Left"], 0.15)
    Player.animations["right"] = SpriteAnimator.new(Player.sprites["Normal"]["Right"], 0.15)

    Player.animations["upright"] = SpriteAnimator.new(Player.sprites["Normal"]["UpRight"], 0.15)
    Player.animations["upleft"] = SpriteAnimator.new(Player.sprites["Normal"]["UpLeft"], 0.15)
    Player.animations["downright"] = SpriteAnimator.new(Player.sprites["Normal"]["DownRight"], 0.15)
    Player.animations["downleft"] = SpriteAnimator.new(Player.sprites["Normal"]["DownLeft"], 0.15)
end

local function canPassThrough(targetGridX, targetGridY)
    if Player.hasGhost then
        return true
    end
    return Maze.isWalkable(targetGridX, targetGridY)
end

function Player.update(dt)
    if not Player.hasSpawned then
        return
    end

    if Player.hasSpeed then
        Player.speedTimer = Player.speedTimer - dt
        if Player.speedTimer <= 0 then
            Player.RemoveSpeed()
        end
    end
    if Player.hasMagnet then
        Player.magnetTimer = Player.magnetTimer - dt
        if Player.magnetTimer <= 0 then
            Player.RemoveMagnet()
        end
    end
    if Player.hasGhost then
        Player.ghostTimer = Player.ghostTimer - dt
        if Player.ghostTimer <= 0 then
            if Maze.isWalkable(Player.gridX, Player.gridY) then
                Player.RemoveGhost()
            else
                Player.ghostTimer = 0
            end
        end
    end

    -- 1. Capture player intent instantly from input
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        Player.intendedDir = "left"
        Player.hasMoved = true
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        Player.intendedDir = "right"
        Player.hasMoved = true
    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        Player.intendedDir = "up"
        Player.hasMoved = true
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        Player.intendedDir = "down"
        Player.hasMoved = true
    end

    if not Player.playerLocked then
        if Player.hasMoved then
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

                if canPassThrough(Player.gridX + dx, Player.gridY + dy) then
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

                    if canPassThrough(Player.gridX + dx, Player.gridY + dy) then
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
        end

        for _, animation in pairs(Player.animations) do
            animation:update(dt)
        end
    end
end

function Player.draw()
    if not Player.hasSpawned then
        return
    end

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
        if Player.currentDir == "left" then
            state = "left"
        elseif Player.currentDir == "right" then
            state = "right"
        elseif Player.currentDir == "up" then
            state = "up"
        elseif Player.currentDir == "down" then
            state = "down"
        end
    end

    local activeAnimation = Player.animations[state] or Player.animations["right"]
    local sprite = activeAnimation:getCurrentFrame()

    local scaleX = Maze.TILE_SIZE / sprite:getWidth()
    local scaleY = Maze.TILE_SIZE / sprite:getHeight()

    if Player.hasGhost then
        love.graphics.setColor(1, 1, 1, 0.85)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.draw(sprite, Player.visualX, Player.visualY, 0, scaleX, scaleY)
    love.graphics.setColor(1, 1, 1, 1)
end

function Player.Spawn()
    local startGridX, startGridY = math.floor(Maze.TILE_WIDTH / 2), math.floor(Maze.TILE_HEIGHT / 2)

    local foundEmptySpot = false
    for radius = 0, 5 do
        for dy = -radius, radius do
            for dx = -radius, radius do
                local checkX = startGridX + dx
                local checkY = startGridY + dy

                if Maze.isWalkable(checkX, checkY) then
                    startGridX, startGridY = checkX, checkY
                    foundEmptySpot = true
                    break
                end
            end
            if foundEmptySpot then break end
        end
        if foundEmptySpot then break end
    end

    Player.gridX = startGridX
    Player.gridY = startGridY

    Player.visualX = (Player.gridX - 1) * Maze.TILE_SIZE
    Player.visualY = (Player.gridY - 1) * Maze.TILE_SIZE

    Player.hasSpawned = true
    Player.hasMoved = false
end

function Player.Lock()
    Player.playerLocked = true
end

function Player.Unlock()
    Player.playerLocked = false
end

function Player.AddSpeed()
    Player.hasSpeed = true
    Player.speedTimer = Player.setSpeedTimer
    Player.moveSpeed = Player.moveSpeed_Speed
end

function Player.RemoveSpeed()
    Player.hasSpeed = false
    Player.moveSpeed = Player.moveSpeed_Normal
end

function Player.AddMagnet()
    Player.hasMagnet = true
    Player.magnetTimer = Player.setMagnetTimer
end

function Player.RemoveMagnet()
    Player.hasMagnet = false
end

function Player.AddGhost()
    Player.hasGhost = true
    Player.ghostTimer = Player.setGhostTimer
end

function Player.RemoveGhost()
    Player.hasGhost = false
end

return Player
