function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    PlayerSprites = {
        left = love.graphics.newImage("assets/sprites/characters/player/walk/left_1.png"),
        right = love.graphics.newImage("assets/sprites/characters/player/walk/right_1.png"),
    }

    PlayerDirection = "right"

    TILE_SIZE = 32
    TILE_MAP = {
        {1, 1, 1, 1, 1, 1, 1, 1},
        {1, 0, 0, 0, 0, 1, 0, 1},
        {1, 0, 1, 1, 0, 1, 0, 1},
        {1, 0, 0, 1, 0, 0, 0, 1},
        {1, 1, 1, 1, 1, 1, 1, 1}
    }

    PlayerGridX = 2
    PlayerGridY = 2

    PlayerVisualX = (PlayerGridX - 1) * TILE_SIZE
    PlayerVisualY = (PlayerGridY - 1) * TILE_SIZE
    MoveSpeed = 5
end

function IsWalkable(gridX, gridY)
    if TILE_MAP[gridY] and TILE_MAP[gridY][gridX] then
        return TILE_MAP[gridY][gridX] == 0
    end
    return false
end

function love.update(dt)
    local currentTargetX = (PlayerGridX - 1) * TILE_SIZE
    local currentTargetY = (PlayerGridY - 1) * TILE_SIZE

    if PlayerVisualX == currentTargetX and PlayerVisualY == currentTargetY then
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            if IsWalkable(PlayerGridX - 1, PlayerGridY) then
                PlayerGridX = PlayerGridX - 1
                PlayerDirection = "left"
            end
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            if IsWalkable(PlayerGridX + 1, PlayerGridY) then
                PlayerGridX = PlayerGridX + 1
                PlayerDirection = "right"
            end
        elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
            if IsWalkable(PlayerGridX, PlayerGridY - 1) then
                PlayerGridY = PlayerGridY - 1
            end
        elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
            if IsWalkable(PlayerGridX, PlayerGridY + 1) then
                PlayerGridY = PlayerGridY + 1
            end
        end
    end

    -- 2. Smoothly slide the visual sprite toward its logical grid position
    local targetX = (PlayerGridX - 1) * TILE_SIZE
    local targetY = (PlayerGridY - 1) * TILE_SIZE

    -- Using Linear Interpolation (lerp) for smooth arcade-style sliding
    PlayerVisualX = PlayerVisualX + (targetX - PlayerVisualX) * MoveSpeed * dt
    PlayerVisualY = PlayerVisualY + (targetY - PlayerVisualY) * MoveSpeed * dt

    -- Snap to target if very close to prevent endless microscopic sliding
    if math.abs(targetX - PlayerVisualX) < 0.5 then PlayerVisualX = targetX end
    if math.abs(targetY - PlayerVisualY) < 0.5 then PlayerVisualY = targetY end
end

function love.draw()
    for row = 1, #TILE_MAP do
        for col = 1, #TILE_MAP[row] do
            if TILE_MAP[row][col] == 1 then
                love.graphics.setColor(0.1, 0.4, 0.1) -- Dark Green for walls
                love.graphics.rectangle("fill", (col - 1) * TILE_SIZE, (row - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
    love.graphics.setColor(1, 1, 1) -- Reset color to white for sprites

    -- Draw the player sprite facing the correct way at its visual position
    local activeSprite = PlayerSprites[PlayerDirection]
    
    -- Scale the sprite to fit your TILE_SIZE if needed
    local scaleX = TILE_SIZE / activeSprite:getWidth()
    local scaleY = TILE_SIZE / activeSprite:getHeight()
    
    love.graphics.draw(activeSprite, PlayerVisualX, PlayerVisualY, 0, scaleX, scaleY)
end