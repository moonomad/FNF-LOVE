local SoundTray = {
	bars = {},
	game = {width = 0, height = 0},
	box = {x = 0, y = -75, width = 194, height = 72},
	text = {x = 0, y = 0, text = "Volume: 100%"},
	bar = {x = 0, y = 30, width = 8 * 10 + 20}
}
-- manually calculed cuz me lazy, needs change
-- 8 is the width, 10 the quantity
-- 20 is space - width * quantity
-- - Vi

local clock = 0
local DEFAULT_VOLUME = 10
local prev = DEFAULT_VOLUME

function SoundTray.init(width, height)
	SoundTray.game.width = width
	SoundTray.game.height = height
end

function SoundTray.new(font)
	SoundTray.visible = false
	SoundTray.silent = false

	SoundTray.text.font = font or love.graphics.newFont(22)

	for i = 1, 10 do
		local bar = {
			space = 10,
			x = i - 1,
			y = 20,
			width = 8,
			height = -(i * 2.5),
			visible = true
		}
		table.insert(SoundTray.bars, bar)
	end

	SoundTray.throttles = {}
	SoundTray.throttles.up = Throttle:make({controls.down, controls, "volume_up"})
	SoundTray.throttles.down = Throttle:make({controls.down, controls, "volume_down"})

	SoundTray.adjust()
end

function SoundTray.adjust()
	SoundTray.text.width = SoundTray.text.font:getWidth(SoundTray.text.text)
	SoundTray.box.x = (SoundTray.game.width - SoundTray.box.width) / 2
	SoundTray.bar.x = (SoundTray.game.width - SoundTray.bar.width) / 2
	SoundTray.text.x = (SoundTray.game.width - SoundTray.text.width) / 2
	SoundTray.text.y = SoundTray.box.y + SoundTray.box.height - SoundTray.text.font:getHeight() - 5
	SoundTray.bar.y = SoundTray.box.y + 34
end

function SoundTray:resize(width, height)
	self.game.width = width
	self.game.height = height
	SoundTray.adjust()
end

function SoundTray:update(dt)
	if self.visible then
		clock = clock + dt
		if self.box.y <= -72 then
			self.visible = false
			clock = 0
		end
	end

	if self.throttles.up:check() then
		self:adjustVolume(1)
	elseif self.throttles.down:check() then
		self:adjustVolume(-1)
	elseif controls:pressed("volume_mute") then
		self:toggleMute()
	end

	if clock >= 2 then
		self.box.y = math.lerp(-80, self.box.y, math.exp(-dt * 6))
	else
		self.box.y = math.lerp(22, self.box.y, math.exp(-dt * 14))
	end
	self.adjust()
end

local n = DEFAULT_VOLUME

function SoundTray:adjustVolume(amount)
	self.visible = true
	clock = 0

	local newVolume = n + amount
	newVolume = math.max(0, math.min(10, newVolume))

	game.sound.setVolume(newVolume / 10)
	game.sound.setMute(newVolume == 0)
	if not self.silent then game.sound.play(paths.getSound("beep")) end

	self.text.text = "Volume: " .. newVolume * 10 .. "%"

	for i, bar in ipairs(SoundTray.bars) do
		bar.visible = (i <= newVolume)
	end

	prev = n
	n = newVolume
end

function SoundTray:toggleMute()
	game.sound.setMute(not game.sound.__mute)
	if not game.sound.__mute then
		self:adjustVolume(prev > 0 and prev or 1)
	else
		self:adjustVolume(-n)
	end
end

function SoundTray:__render()
	local r, g, b, a = love.graphics.getColor()
	local font = love.graphics.getFont()

	if self.visible then
		local color = Color.fromRGB(28, 26, 40)
		love.graphics.setColor(color[1], color[2], color[3], 0.8)
		love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.width, self.box.height, 10, 10, 20)
		love.graphics.setColor(Color.fromRGB(130, 135, 174))
		love.graphics.rectangle("line", self.box.x, self.box.y, self.box.width, self.box.height, 10, 10, 20)

		love.graphics.setColor(1, 1, 1, 0.2)

		for _, bar in ipairs(SoundTray.bars) do
			love.graphics.rectangle("fill", self.bar.x + (bar.x * bar.space), self.bar.y,
				bar.width, bar.height)
		end

		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(self.text.font)
		love.graphics.print(self.text.text, self.text.x, self.text.y)

		for _, bar in ipairs(SoundTray.bars) do
			if bar.visible then
				love.graphics.rectangle("fill", self.bar.x + (bar.x * bar.space), self.bar.y,
					bar.width, bar.height)
			end
		end
	end

	love.graphics.setColor(r, g, b, a)
	love.graphics.setFont(font)
end

return SoundTray
