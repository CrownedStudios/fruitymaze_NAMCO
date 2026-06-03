local Game = {}

-- Dependencies

local Maze = require("scripts.components.Maze")
local Collectibles = require("scripts.components.Collectibles")

local Player = require("scripts.objects.Player")

-- Global Functions

function Game.load()
    -- any game-wide initialization can go here
end

function Game.update(dt)
    Collectibles.update(dt)

    local playerCenterX = Player.visualX + 8
    local playerCenterY = Player.visualY + 8
    Collectibles.checkCollision(playerCenterX, playerCenterY, 8)
end

function Game.StartGame()
    Maze.generateMaze()
    Collectibles.generateCollectibles(9, 5)
    Player.Spawn()
end

return Game
