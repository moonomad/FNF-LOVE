io.stdout:setvbuf("no")

Application = { meta = require "project" }

require "loxel"

Timer = require "lib.timer"

Discord = require "funkin.backend.discord"

WindowDialogue = require "lib.windows.dialogue"
paths = require "funkin.paths"
util = require "funkin.util"

ClientPrefs = require "funkin.backend.clientprefs"
Script = require "funkin.backend.script"
ScriptsHandler = require "funkin.backend.scriptshandler"
Conductor = require "funkin.backend.conductor"
Note = require "funkin.gameplay.ui.note"
NoteSplash = require "funkin.gameplay.ui.notesplash"
Receptor = require "funkin.gameplay.ui.receptor"
Stage = require "funkin.gameplay.stage"
Character = require "funkin.gameplay.character"
MenuCharacter = require "funkin.ui.menucharacter"
MenuItem = require "funkin.ui.menuitem"
Alphabet = require "funkin.ui.alphabet"
HealthIcon = require "funkin.gameplay.ui.healthicon"
BackgroundGirls = require "funkin.gameplay.backgroundgirls"
ParallaxImage = require "loxel.effects.parallax"

TitleState = require "funkin.states.title"
MainMenuState = require "funkin.states.mainmenu"
StoryMenuState = require "funkin.states.storymenu"
FreeplayState = require "funkin.states.freeplay"
PlayState = require "funkin.states.play"

GameOverSubstate = require "funkin.substates.gameover"

OptionsState = require "funkin.states.options.options"

CharacterEditor = require "funkin.states.editors.character"
ChartingState = require "funkin.states.editors.charting"

function love.run()
    local _, _, flags = love.window.getMode()
    love.FPScap, love.unfocusedFPScap = math.max(flags.refreshrate, 120), 8

    love.graphics.clear(0, 0, 0, 0, false, false)
    love.graphics.present()

    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end

    collectgarbage()
    collectgarbage("stop")

    local firstTime, fullGC, focused, dt = true, true, false, 0
    return function()
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" and (not love.quit or not love.quit()) then
                    return a or 0
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        focused = firstTime or not love.window or love.window.hasFocus()
        dt = love.timer and love.timer.step() or 0

        if focused then
            if love.update then love.update(dt) end

            if love.graphics and love.graphics.isActive() then
                love.graphics.origin()
                love.graphics.clear(love.graphics.getBackgroundColor())
                if love.draw then love.draw() end

                local stats = love.graphics.getStats()
                love.graphics.printf("FPS: " ..
                                         math.min(love.timer.getFPS(),
                                                  love.FPScap) .. "\nVRAM: " ..
                                         math.countbytes(stats.texturememory) ..
                                         "\nDRAWS: " .. stats.drawcalls, 6, 6,
                                     300, "left", 0)

                love.graphics.present()
            end
        end

        if love.timer then
            love.timer.sleep(1 /
                                 (focused and love.FPScap or
                                     love.unfocusedFPScap) - dt)
        end

        if focused then
            collectgarbage("step")
            fullGC = true
        elseif fullGC then
            collectgarbage()
            fullGC = false
        end

        firstTime = false
    end
end

-- Gets the current device
---@return string -- The current device. 'Desktop' or 'Mobile'
function love.system.getDevice()
    if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
        return "Mobile"
    elseif love.system.getOS() == "OS X" or love.system.getOS() == "Windows"
        or love.system.getOS() == "Linux" then
        return "Desktop"
    end

    return ""
end

function love.load()
    -- for the joystick, i'll remake it later
    controls = (require "lib.baton").new({
        controls = table.clone(ClientPrefs.controls)
    })

    game.init(TitleState)

    if love.system.getDevice() == "Desktop" then Discord.init() end
end

function love.resize(w, h) game.resize(w, h) end

function love.keypressed(...)
    controls:onKeyPress(...)
    game.keypressed(...)
end
function love.keyreleased(...)
    controls:onKeyRelease(...)
    game.keyreleased(...)
end
function love.textinput(text) game.textinput(text) end

function love.wheelmoved(x, y) game.wheelmoved(x, y) end
function love.mousemoved(x, y) game.mousemoved(x, y) end
function love.mousepressed(x, y, button) game.mousepressed(x, y, button) end
function love.mousereleased(x, y, button) game.mousereleased(x, y, button) end

function love.update(dt)
    dt = math.min(dt, 1 / 30) -- temporary workaround until we can detect when freezes started smh

    Timer.update(dt)
    controls:update()

    game.update(dt)

    if love.system.getDevice() == "Desktop" then Discord.update() end
end

function love.draw() game.draw() end

function love.focus(f) game.focus(f) end

function love.quit() Discord.shutdown() end
