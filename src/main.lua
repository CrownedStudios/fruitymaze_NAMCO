-- Dependencies

local Window = require("scripts.util.Window")

local Game = require("scripts.components.Game")
local Player = require("scripts.objects.Player")

local DiscordRPC = require("scripts.util.DiscordRPC")

-- Global Functions

function love.load()
    love.graphics.setDefaultFilter('nearest')

    -- initialize modules
    DiscordRPC.load()

    Window.load()
    Game.load()
    Player.load()

    -- initialize game state
    Game.StartGame()
end

function love.quit()
    DiscordRPC.shutdown()
    return false
end

function love.resize(w, h)
    Window.calculateScale()
end

function love.update(dt)
    Game.update(dt)
    DiscordRPC.update(dt)
end

function love.draw()
    Window.draw(love.timer.getDelta())
    DiscordRPC.draw()
end

function love.keypressed(key)
    if key == "r" then
        Game.StartGame(true)
    end
end
