local Bar = Object:extend()

function Bar:new(x, y, width, height, maxValue, color, filledBar, opColor)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 20
    self.maxValue = maxValue or 100
    self.value = self.maxValue
    self.color = color or {255, 0, 0}
    self.opColor = opColor or {0, 255, 0}
    self.flipX = false
    self.filledBar = filledBar or false
    self.camera = nil
    self.fillWidth = self.width - ((self.value / self.maxValue) * self.width)
end

function Bar:setValue(value)
    self.value = math.min(math.max(value, 0), self.maxValue)
end

function Bar:setCamera(camera) self.camera = camera end

function Bar:screenCenter(axes)
    if axes == nil then axes = "xy" end
    if axes:find("x") then self.x = (push.getWidth() - self.width) * 0.5 end
    if axes:find("y") then self.y = (push.getHeight() - self.height) * 0.5 end
    return self
end

function Bar:draw()
    if self.camera then self.camera:attach() end

    self.fillWidth = self.width - ((self.value / self.maxValue) * self.width)

    if self.filledBar then
        love.graphics.setColor(self.flipX and self.color or self.opColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end

    love.graphics.setColor(self.flipX and self.opColor or self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.fillWidth, self.height)

    if self.camera then self.camera:detach() end
    love.graphics.setColor(1, 1, 1)
end

return Bar