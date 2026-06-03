local Window = {}

-- Dependencies

local Maze = require("scripts.components.Maze")
local Player = require("scripts.objects.Player")

-- Variables

local VIRTUAL_WIDTH = 304
local VIRTUAL_HEIGHT = 352

local gameCanvas
local canvasX, canvasY, canvasScale = 0, 0, 1

-- Global Functions

function Window.load()
    -- create canvas for virtual resolution
    gameCanvas = love.graphics.newCanvas(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    Window.calculateScale()

    FONT = love.graphics.newFont('assets/fonts/emulogic.ttf', 8)
    love.graphics.setFont(FONT)
end

function Window.calculateScale()
    local windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()

    canvasScale = math.min(windowW / VIRTUAL_WIDTH, windowH / VIRTUAL_HEIGHT)

    canvasScale = math.floor(canvasScale)
    if canvasScale < 1 then canvasScale = 1 end

    canvasX = (windowW - VIRTUAL_WIDTH * canvasScale) / 2
    canvasY = (windowH - VIRTUAL_HEIGHT * canvasScale) / 2
end

function Window.draw()
    -- Render things at low-res inside the canvas box
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0)

    -- --- HEADER ---
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("1UP", 16, 6)
    love.graphics.print("00", 16, 16)

    love.graphics.printf("HIGH SCORE", 0, 6, VIRTUAL_WIDTH, "center")
    love.graphics.printf("99990", 0, 16, VIRTUAL_WIDTH, "center")

    -- --- PLAYFIELD ---
    love.graphics.push()
    love.graphics.translate(0, 32) -- Shifted down by 32 low-res pixels
    Maze.draw()
    Player.draw()
    love.graphics.pop()

    -- --- FOOTER ---
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("LIVES: 3", 16, VIRTUAL_HEIGHT - 16)

    -- Draw everything scaled up sharply onto the main desktop screen
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, canvasX, canvasY, 0, canvasScale, canvasScale)
end

return Window
