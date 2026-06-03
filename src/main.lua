-- Dependencies

local Window = require("scripts.util.Window")
local Game = require("scripts.components.Game")
local Maze = require("scripts.components.Maze")
local Player = require("scripts.objects.Player")

-- Global Functions

function love.load()
    love.graphics.setDefaultFilter('nearest')

    -- initialize modules
    Window.load()
    Game.load()
    Maze.load()
    Player.load()

    -- initialize game state
    Game.StartGame()
end

function love.resize(w, h)
    Window.calculateScale()
end

function love.update(dt)
    Game.update(dt)
    Player.update(dt)
end

function love.draw()
    Window.draw()
end
