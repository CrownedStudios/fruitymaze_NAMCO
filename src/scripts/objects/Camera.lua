local Camera = {
    x = 0,
    y = 0,
    viewportWidth = 432,
    viewportHeight = 304,
    zoom = 2,

    lerpSpeed = 10,
}

-- Global Functions

function Camera.lookAt(targetX, targetY, tileAssetSize, dt)
    local zoomedWidth = Camera.viewportWidth / Camera.zoom
    local zoomedHeight = Camera.viewportHeight / Camera.zoom

    local halfViewX = (zoomedWidth / 2) - (tileAssetSize / 2)
    local halfViewY = (zoomedHeight / 2) - (tileAssetSize / 2)

    local idealX = targetX - halfViewX
    local idealY = targetY - halfViewY

    Camera.x = Camera.x + (idealX - Camera.x) * Camera.lerpSpeed * dt
    Camera.y = Camera.y + (idealY - Camera.y) * Camera.lerpSpeed * dt
end

function Camera.clamp(mapWidth, mapHeight, tileAssetSize)
    local zoomedWidth = Camera.viewportWidth / Camera.zoom
    local zoomedHeight = Camera.viewportHeight / Camera.zoom

    local maxScrollX = (mapWidth * tileAssetSize) - zoomedWidth
    local maxScrollY = (mapHeight * tileAssetSize) - zoomedHeight

    Camera.x = math.max(0, math.min(Camera.x, maxScrollX))
    Camera.y = math.max(0, math.min(Camera.y, maxScrollY))
end

function Camera.attach()
    love.graphics.push()
    love.graphics.scale(Camera.zoom, Camera.zoom)
    love.graphics.translate(-math.floor(Camera.x), -math.floor(Camera.y))
end

function Camera.detach()
    love.graphics.pop()
end

return Camera
