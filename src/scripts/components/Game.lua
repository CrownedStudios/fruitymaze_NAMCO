local Game = {
    state = "PLAYING",
    stateTimer = 0,
    showText = ""
}

-- Dependencies

local DiscordRPC = require("scripts.util.DiscordRPC")

local Maze = require("scripts.components.Maze")
local Collectibles = require("scripts.components.Collectibles")

local Player = require("scripts.objects.Player")

-- Global Functions

function Game.load()
    -- any game-wide initialization can go here
end

function Game.update(dt)
    if Game.stateTimer > 0 then
        Game.stateTimer = Game.stateTimer - dt
    end

    if Game.state == "INTERMISSION_START" then
        if Game.stateTimer <= 0 then
            Player.Spawn()

            Game.state = "INTERMISSION_SPAWN"
            Game.stateTimer = 1.5
            Game.showText = "READY!"
        end
    elseif Game.state == "INTERMISSION_SPAWN" then
        if Game.stateTimer <= 0 then
            DiscordRPC.updateStatus("Playing", "Arcade Mode", 1, 1, true)
            Player.Unlock()

            Game.state = "PLAYING"
            Game.showText = ""
        end
    elseif Game.state == "PLAYING" then
        Player.update(dt)

        Collectibles.update(dt)
        local playerCenterX = Player.visualX + 8
        local playerCenterY = Player.visualY + 8
        Collectibles.checkCollision(playerCenterX, playerCenterY, 8)
    end
end

function Game.getIntermissionText()
    return Game.showText
end

function Game.StartGame(short)
    Maze.generateMaze()
    Collectibles.generateCollectibles(10, 7)

    DiscordRPC.updateStatus("Intermission", "Arcade Mode", nil, nil, true)
    if short == true then
        Player.Lock()
        Player.Spawn()

        Game.state = "INTERMISSION_SPAWN"
        Game.stateTimer = 1.5
        Game.showText = "PLAYER 1 READY!"

        -- play music
    else
        Player.Lock()

        Game.state = "INTERMISSION_START"
        Game.stateTimer = 2.0
        Game.showText = "PLAYER 1"

        -- play music
    end
end

return Game
