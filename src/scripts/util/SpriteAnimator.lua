local SpriteAnimator = {}

-- Global Functions

function SpriteAnimator.new(spritesList, animationSpd)
    local anim = {
        frames = spritesList,
        speed = animationSpd or 0.2,
        timer = 0,
        currentFrame = 1,
        isPlaying = true,
    }

    function anim:update(dt)
        if not self.isPlaying or #self.frames <= 1 then return end

        self.timer = self.timer + dt
        if self.timer >= self.speed then
            self.timer = self.timer - self.speed
            self.currentFrame = self.currentFrame + 1

            if self.currentFrame > #self.frames then
                self.currentFrame = 1
            end
        end
    end

    function anim:getCurrentFrame()
        return self.frames[self.currentFrame]
    end

    function anim:reset()
        self.currentFrame = 1
        self.timer = 0
    end

    function anim:play() self.isPlaying = true end

    function anim:pause() self.isPlaying = false end

    return anim
end

return SpriteAnimator
