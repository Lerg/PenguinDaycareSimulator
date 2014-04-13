local app = require('lib.app')

local scene = storyboard.newScene()

local function newSlideView(params)
    local slideView = display.newGroup()

    slideView.slides = {}
    slideView.dots = {}
    slideView.currentSlide = 1
    function slideView:addSlide(group)
        table.insert(self.slides, group)
        self:insert(group)
    end

    function slideView:gotoSlide(ind)
        local slidetime = 500
        if ind > 1 then
            for i = 1, ind - 1 do
                transition.to(self.slides[i], {time = slidetime, x = _L - (_R - _L) * 0.5, transition = easing.outExpo})
                self.dots[i].isVisible = false
            end
        end
        transition.to(self.slides[ind], {time = slidetime, x = _CX, transition = easing.outExpo})
        self.dots[ind].isVisible = true
        if ind < #self.slides then
            for i = ind + 1, #self.slides do
                transition.to(self.slides[i], {time = slidetime, x = _R + (_R - _L) * 0.5, transition = easing.outExpo})
                self.dots[i].isVisible = false
            end
        end
    end

    function slideView:next()
        if self.currentSlide < #self.slides then
            self.currentSlide = self.currentSlide + 1
        else
            self.currentSlide = 1
        end
        self:gotoSlide(self.currentSlide)
    end

    function slideView:prev()
        if self.currentSlide > 1 then
            self.currentSlide = self.currentSlide - 1
        else
            self.currentSlide = #self.slides
        end
        self:gotoSlide(self.currentSlide)
    end

    function slideView:touch(event)
        if event.phase == 'began' then
            display.getCurrentStage():setFocus(self)
            self.isFocus = true
        elseif self.isFocus then
            if event.phase == 'moved' then
                if self.lastSwipe == event.id then return true end
                local d = event.x - event.xStart
                if math.abs(d) > 50 then
                    self.lastSwipe = event.id
                    if d > 0 then
                        self:prev()
                    else
                        self:next()
                    end
                end
            else
                self.isFocus = false
                display.getCurrentStage():setFocus(nil)
                if self.lastSwipe ~= event.id and math.abs(event.x - event.xStart) < 5 then
                    params.onRelease(self.currentSlide)
                end
            end
        end
        return true
    end
    slideView:addEventListener('touch')
    function slideView:makeDots()
        local spacing = 20
        for i = 1, #self.slides do
            app.newImage('images/dot-off.png', {g = self, w = 16, h = 16, x = _CX + (i - 0.5 - #self.slides * 0.5) * spacing, y = params.dots_y})
            table.insert(self.dots, app.newImage('images/dot.png', {g = self, w = 16, h = 16, x = _CX + (i - 0.5 - #self.slides * 0.5) * spacing, y = params.dots_y}))
        end
    end

    params.g:insert(slideView)
    slideView.x, slideView.y = params.x, params.y
    return slideView
end

function scene:createScene(event)
    local group = self.view

    self.backButton = app.newButton{g = group, x = _L + 10, y = _T + 10, w = 48, h = 32, rp = 'TopLeft',
        text = 'Back',
        fontSize = 14,
        onRelease = function()
            storyboard.gotoScene('scenes.menu', {effect = 'slideRight', time = app.duration})
        end}

    local function gotoPenguin(ind)
        storyboard.gotoScene('scenes.penguin', {effect = 'slideLeft', time = app.duration, params = ind})
    end
    local slideView = newSlideView{g = group, x = 0, y = _CY, dots_y = 180, onRelease = gotoPenguin}
    for i = 1, #app.api.penguins do
        local p = app.api.penguins[i]
        local slide = display.newGroup()
        app.newImage('images/popup.png', {g = slide, w = 300, h = 335})
        app.newImage('images/penguins/' .. p.id .. '.png', {g = slide, w = 200, h = 256})
        app.newText{g = slide, x = 0, y = -140, text = p.name, size = 18, color = 'white'}
        app.newText{g = slide, x = 0, y = 140, text = p.bio, size = 14, color = 'white', w = 220, align = 'center'}
        slideView:addSlide(slide)
    end

    slideView:makeDots()
    slideView:gotoSlide(1)
end

function scene:backPressed()
    self.backButton._view.onRelease()
end

scene:addEventListener('createScene')
return scene

