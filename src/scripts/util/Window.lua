local Window = {
    windowScale = 1,
}

-- Dependencies

local Camera = require("scripts.objects.Camera")

local Maze = require("scripts.components.Maze")
local Collectibles = require("scripts.components.Collectibles")

local Player = require("scripts.objects.Player")

-- Variables

local VIEWPORT_WIDTH = 512
local VIEWPORT_HEIGHT = 480

local gameCanvas
local canvasX, canvasY = 0, 0

-- Global Functions

function Window.load()
    FONT = love.graphics.newFont('assets/fonts/emulogic.ttf', 8)
    love.graphics.setFont(FONT)

    local totalCanvasWidth = VIEWPORT_WIDTH + 32
    local totalCanvasHeight = VIEWPORT_HEIGHT + 32 + 16
    gameCanvas = love.graphics.newCanvas(totalCanvasWidth, totalCanvasHeight)

    Window.setWindowScale(1)
end

function Window.calculateScale()
    local windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()

    local virtualPadding = 30
    local scale = Window.windowScale

    local totalCanvasWidth = VIEWPORT_WIDTH * scale
    local totalCanvasHeight = (VIEWPORT_HEIGHT + 32 + 16) * scale

    canvasX = (windowW - totalCanvasWidth) / 2
    canvasY = (windowH - totalCanvasHeight) / 2
end

function Window.draw(dt)
    local totalCanvasHeight = VIEWPORT_HEIGHT + 32 + 16

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0)

    -- --- STATIC HEADER ---
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("1UP", 16, 6)
    love.graphics.print("00", 16, 16)

    love.graphics.printf("HIGH SCORE", 0, 6, VIEWPORT_WIDTH, "center")
    love.graphics.printf("99990", 0, 16, VIEWPORT_WIDTH, "center")

    -- --- PLAYFIELD AREA ---
    love.graphics.push()
    love.graphics.translate(0, 32) -- Push entire board under header

    -- Keep pixels cropped into playfield bounds (1:1 canvas coordinates)
    love.graphics.setScissor(0, 32, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

    -- Update camera parameters through its clean module interface
    Camera.lookAt(Player.visualX, Player.visualY, Maze.TILE_SIZE, dt or 0.016)
    Camera.clamp(Maze.TILE_WIDTH, Maze.TILE_HEIGHT, Maze.TILE_SIZE)

    -- Activate camera world shifting matrix
    Camera.attach()
    Maze.draw()
    Collectibles.draw()
    Player.draw()
    Camera.detach()

    love.graphics.setScissor() -- Clear the clip box cleanly
    love.graphics.pop()

    -- --- STATIC FOOTER ---
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("LIVES: 3", 16, totalCanvasHeight - 16)

    -- Output to parent screen layout
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, canvasX, canvasY, 0, Window.windowScale, Window.windowScale)
end

function Window.setWindowGeometry(width, height, flags)
    local success = love.window.setMode(width, height, flags)
    if success then
        Window.calculateScale()
    end
    return success
end

function Window.setWindowScale(scale)
    Window.windowScale = scale

    local totalVirtualWidth = VIEWPORT_WIDTH + 32
    local totalVirtualHeight = VIEWPORT_HEIGHT + 32 + 16

    local virtualPadding = 50

    local targetWidth = (totalVirtualWidth + (virtualPadding * 2)) * scale
    local targetHeight = (totalVirtualHeight + (virtualPadding * 2)) * scale


    local success = Window.setWindowGeometry(targetWidth, targetHeight)
    if not success then
        print("Failed to set window geometry for scale " .. scale)
    end
end

return Window
