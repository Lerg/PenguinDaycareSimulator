local app = require('lib.app')

local scene = storyboard.newScene()

function scene:createScene(event)
    local group = self.view
    local background = app.newImage('images/background.jpg', {g = group, w = 384, h = 640, x = _CX, y = _CY})

    self.backButton = app.newButton{g = group, x = _L + 10, y = _T + 10, w = 48, h = 32, rp = 'TopLeft',
        text = 'Back',
        fontSize = 14,
        onRelease = function()
            storyboard.gotoScene('scenes.choose', {effect = 'slideRight', time = app.duration})
        end}

    local ind = event.params
    local p = app.api.penguins[ind]

    local visitsLabel = app.newText{g = group, x = _CX, y = _T + 50, text = 'Visits: ' .. p.visit_count, size = 18, color = 'white'}
    local fishLabel = app.newText{g = group, x = _CX, y = _T + 70, text = 'Fish: ' .. p.fish_count, size = 18, color = 'white'}
    local bellyrubsLabel = app.newText{g = group, x = _CX, y = _T + 90, text = 'Belly rubs: ' .. p.bellyrub_count, size = 18, color = 'white'}
    local penguin = app.newImage('images/penguins/' .. p.id .. '.png', {g = group, w = 200, h = 256, x = _CX, y = _CY - 25})

    app.newButton{g = group, x = _CX - 80, y = _B - 50, w = 128, h = 48,
        text = 'Fish',
        fontSize = 14,
        onRelease = function()
            local fish = app.newImage('images/fish.png', {g = group, x = penguin.x, y = penguin.y + 200, w = 512, h = 188})
            fish.alpha = 0.8
            transition.to(fish, {time = 400, alpha = 1, y = penguin.y, xScale = 0.1, yScale = 0.1, transition = easing.outExpo, onComplete = function(obj)
                    transition.to(fish, {time = 400, alpha = 0, onComplete = function(obj)
                            display.remove(obj)
                        end})
                end})
            app.api:sendFish(p.id)
            p.fish_count = p.fish_count + 1
            fishLabel:setText('Fish: ' .. p.fish_count)
        end}

    app.newButton{g = group, x = _CX + 80, y = _B - 50, w = 128, h = 48,
        text = 'Belly rub',
        fontSize = 14,
        onRelease = function()
            local hand = app.newImage('images/hand.png', {g = group, x = penguin.x - 40, y = penguin.y + 30, w = 80, h = 80, rp = 'TopLeft'})
            transition.to(hand, {time = 1200, x = penguin.x + 40, transition = easing.swing3(easing.outQuad), onComplete = function(obj)
                    display.remove(obj)
                end})
            app.api:sendBellyrub(p.id)
            p.bellyrub_count = p.bellyrub_count + 1
            bellyrubsLabel:setText('Belly rubs: ' .. p.bellyrub_count)
        end}

    app.api:sendVisit(p.id)
    p.visit_count = p.visit_count + 1
    visitsLabel:setText('Visits: ' .. p.visit_count)
end

function scene:backPressed()
    self.backButton._view.onRelease()
end

function scene:didExitScene()
    local previous_scene = storyboard.getPrevious()
    if previous_scene then
        storyboard.removeScene(previous_scene)
    end
end

scene:addEventListener('createScene')
scene:addEventListener('didExitScene')
return scene

