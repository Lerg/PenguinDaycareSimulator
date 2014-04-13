display.setStatusBar(display.HiddenStatusBar)

audio = require('audio')
widget = require('widget')
widget.setTheme('widget_theme_ios')
storyboard = require('storyboard')
json = require('json')

-- Various utility functions
local app = require('lib.app')
app.api = require('lib.api')
require('lib.utils')

app.name = 'Penguin Daycare Simulator'
app.font = native.systemFont
app.fontbold = native.systemFontBold

app.iOSID = ''
app.androidID = 'com.spiralcodestudio.penguins'

if audio.supportsSessionProperty then
    audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

if app.isAndroid then
    Runtime:addEventListener('key', function (event)
            if event.keyName == 'back' and event.phase == 'down' then
                local scene = storyboard.getScene(storyboard.getCurrentSceneName())
                if scene and type(scene.backPressed) == 'function' then
                    scene:backPressed()
                    return true
                end
            end
        end)
end
if app.isSimulator then
    Runtime:addEventListener('key', function (event)
            if event.phase == 'down' then
                local scene = storyboard.getScene(storyboard.getCurrentSceneName())
                if event.keyName == 's' then
                    if scene and scene.view then
                        display.save(scene.view, display.pixelHeight .. 'x' .. display.pixelWidth .. '_' .. math.floor(system.getTimer()) .. '.png')
                        return true
                    end
                end
            end
        end)
end

local function main()
    math.randomseed(os.time())
    display.setDefault('background', 1, 1, 1)
    storyboard.gotoScene('scenes.menu')
end
main()
