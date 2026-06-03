local Game = {}

-- Dependencies

local Maze = require("scripts.components.Maze")
local Player = require("scripts.objects.Player")

-- Global Functions

function Game.load()
    -- any game-wide initialization can go here
end

function Game.update(dt)
    -- any game-wide updates can go here
end

function Game.draw()
    -- any game-wide drawing can go here
end

function Game.keypressed(key)
    if key == "r" then
        Game.StartGame()
    end
end

function Game.StartGame()
    Maze.generateMaze()
    Player.gridX = 2
    Player.gridY = 2
    Player.visualX = (Player.gridX - 1) * Maze.TILE_SIZE
    Player.visualY = (Player.gridY - 1) * Maze.TILE_SIZE
end

return Game
