local Graphic = {}

local optionsVar = {
    {'fps', 'FPS', false, 'number', {30, 250}},
    {'antialiasing', 'Antialiasing', false, 'boolean'},
    {'shader', 'Shader', false, 'boolean'}
}

local curSelected = 1
local stringSelected = 1

function Graphic.add(options)
    local graphicTab = Group()
    graphicTab.name = 'Graphic'

    for i, daOption in ipairs(optionsVar) do
        local daGroup = Group()

        local yPos = (i * 45) + 80
        local control = Text(145, yPos, daOption[2],
                             paths.getFont('phantommuff.ttf', 30), {1, 1, 1})
        daGroup:add(control)

        local realvalue = ClientPrefs.data[daOption[1]]
        if type(realvalue) == "boolean" then
            if realvalue then
                realvalue = "enabled"
            else
                realvalue = "disabled"
            end
        end
        local value = daOption[3] and '< ' .. tostring(realvalue)
                        .. ' >' or tostring(realvalue)
        local valueTxt = Text(382, yPos, value,
                              paths.getFont('phantommuff.ttf', 30), {1, 1, 1})
        daGroup:add(valueTxt)

        graphicTab:add(daGroup)
    end

    local linesGroup = Group()
    linesGroup.name = graphicTab.name

    local lines = Sprite(370, 117):make(2, game.height * 0.72,
                                            {255, 255, 255})
    lines.alpha = 0.5
    linesGroup:add(lines)
    options.spriteGroup:add(linesGroup)

    options.allTabs:add(graphicTab)
end

function Graphic.selectOption(id, selected)
    game.sound.play(paths.getSound('scrollMenu'))
    for i, daOption in ipairs(optionsVar) do
        if i == id then
            daOption[3] = (selected ~= nil and selected or false)
            curSelected = id

            if daOption[4] == 'string' then
                stringSelected = table.find(daOption[5], ClientPrefs.data[daOption[1]])
            end
        end
    end
end

function Graphic.changeSelection(huh)
    if huh == nil then huh = 0 end
    game.sound.play(paths.getSound('scrollMenu'))

    local selectedOption = optionsVar[curSelected]
    local optionData = selectedOption[1]
    local optionType = selectedOption[4]
    if optionType == 'boolean' then
        ClientPrefs.data[optionData] = not ClientPrefs.data[optionData]
    elseif optionType == 'string' then
        local stringVal = selectedOption[5]

        stringSelected = stringSelected + huh

        if stringSelected > #stringVal then
            stringSelected = 1
        elseif stringSelected < 1 then
            stringSelected = #stringVal
        end

        ClientPrefs.data[optionData] = stringVal[stringSelected]
    elseif optionType == 'number' then
        local minVal = selectedOption[5][1]
        local maxVal = selectedOption[5][2]

        ClientPrefs.data[optionData] = ClientPrefs.data[optionData] + huh

        if ClientPrefs.data[optionData] > maxVal then
            ClientPrefs.data[optionData] = maxVal
        elseif ClientPrefs.data[optionData] < minVal then
            ClientPrefs.data[optionData] = minVal
        end
    end
end

return Graphic