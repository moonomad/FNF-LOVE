local PauseSubState = SubState:extend()

function PauseSubState:new()
    PauseSubState.super.new(self)

    self.menuItems = {"Resume", "Restart Song", "Exit to menu"}
    self.curSelected = 1

    self.bgColor = {0, 0, 0, 0.5}

    self.music = game.sound.play(paths.getMusic('breakfast'), 0, true)

    self.grpShitMenu = Group()
    self:add(self.grpShitMenu)

    for i = 0, #self.menuItems - 1 do
        local item =
            Alphabet(0, 70 * i + 30, self.menuItems[i + 1], true, false)
        item.isMenuItem = true
        item.targetY = i
        self.grpShitMenu:add(item)
    end

    self:changeSelection()
end

function PauseSubState:update(dt)
    if self.music:getVolume() < 0.5 then
        self.music:setVolume(self.music:getVolume() + 0.01 * dt)
    end
    PauseSubState.super.update(self, dt)

    if controls:pressed('ui_up') then self:changeSelection(-1) end
    if controls:pressed('ui_down') then self:changeSelection(1) end

    if controls:pressed('accept') then
        local daChoice = self.menuItems[self.curSelected]

        switch(daChoice, {
            ["Resume"] = function() self:close() end,
            ["Restart Song"] = function() switchState(PlayState()) end,
            ["Exit to menu"] = function()
                switchState(FreeplayState())
            end
        })
    end
end

function PauseSubState:changeSelection(huh)
    if huh == nil then huh = 0 end

    game.sound.play(paths.getSound('scrollMenu'))
    self.curSelected = self.curSelected + huh

    if self.curSelected > #self.menuItems then
        self.curSelected = 1
    elseif self.curSelected < 1 then
        self.curSelected = #self.menuItems
    end

    local bullShit = 0

    for _, item in ipairs(self.grpShitMenu.members) do
        item.targetY = bullShit - (self.curSelected - 1)
        bullShit = bullShit + 1

        item.alpha = 0.6

        if item.targetY == 0 then item.alpha = 1 end
    end
end

function PauseSubState:close()
    self.music:release()
    PauseSubState.super.close(self)
end

return PauseSubState