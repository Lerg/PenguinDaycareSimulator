local app = require('lib.app')

local scene = storyboard.newScene()

function scene:createScene (event)
    local group = self.view

    app.newText{g = group, text = 'Penguin Daycare', size = 32, x = _CX, y = _CY - 150}
    app.newText{g = group, text = 'Simulator', size = 32, x = _CX, y = _CY - 110}

    local pleaseWait = app.newText{g = group, text = 'Please Wait', size = 16, x = _CX, y = _CY}
    local button = app.newButton{g = group, x = _CX, y = _CY,
        text = 'Enter the Daycare',
        onRelease = function()
            storyboard.gotoScene('scenes.choose', {effect = 'slideLeft', time = app.duration})
        end}
    button.isVisible = false

    app.api:getPenguins(function()
            pleaseWait.isVisible = false
            button.isVisible = true
        end)
end

function scene:didExitScene()
    local previous_scene = storyboard.getPrevious()
    if previous_scene then
        storyboard.removeScene(previous_scene)
    end
end

scene:addEventListener('didExitScene')
scene:addEventListener('createScene')
return scene

