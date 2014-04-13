local _M = {}

_M.deviceID = system.getInfo('deviceID')

if system.getInfo('environment') ~= 'simulator' then
    io.output():setvbuf('no')
else
    _M.isSimulator = true
end
local platform = system.getInfo('platformName')
if platform == 'Android' then
    _M.isAndroid = true
elseif platform == 'iPhone OS' then
    _M.isiOS = true
end

_M.store = system.getInfo('targetAppStore')

if _M.isSimulator then
    -- Prevent global missuse
    local mt = getmetatable(_G)
    if mt == nil then
      mt = {}
      setmetatable(_G, mt)
    end

    mt.__declared = {}

    mt.__newindex = function (t, n, v)
      if not mt.__declared[n] then
        local w = debug.getinfo(2, 'S').what
        if w ~= 'main' and w ~= 'C' then
          error('assign to undeclared variable \'' .. n .. '\'', 2)
        end
        mt.__declared[n] = true
      end
      rawset(t, n, v)
    end

    mt.__index = function (t, n)
      if not mt.__declared[n] and debug.getinfo(2, 'S').what ~= 'C' then
        error('variable \'' .. n .. '\' is not declared', 2)
      end
      return rawget(t, n)
    end
end

_W = display.contentWidth
_H = display.contentHeight
_T = display.screenOriginY -- Top
_L = display.screenOriginX -- Left
_R = display.viewableContentWidth - _L -- Right
_B = display.viewableContentHeight - _T-- Bottom
_CX = math.floor(_W / 2)
_CY = math.floor(_H / 2)
_SW = _R - _L
_SH = _B - _T

local _COLORS = {}
_COLORS['white'] = {1, 1, 1}
_COLORS['grey'] = {0.6, 0.6, 0.6}
_COLORS['black'] = {0, 0, 0}

_COLORS['red'] = {1, 0, 0}
_COLORS['green'] = {0, 1, 0}
_COLORS['blue'] = {0, 0, 1}

_COLORS['yellow'] = {1, 1, 0}
_COLORS['cyan'] = {0, 1, 1}
_COLORS['magenta'] = {1, 0, 1}

local _AUDIO = {}
_AUDIO['button'] = 'sounds/button.wav'
_AUDIO['swipe'] = 'sounds/swipe.wav'
_AUDIO['wrong'] = 'sounds/wrong.wav'
_AUDIO['correct'] = 'sounds/correct.wav'
_AUDIO['pop'] = 'sounds/pop.wav'

local ext = '.m4a'
if _M.isAndroid or _M.isSimulator then
    ext = '.ogg'
end

_AUDIO['music'] = 'sounds/music' .. ext

local mCeil = math.ceil
local mFloor = math.floor
local mAbs = math.abs
local mAtan2 = math.atan2
local mSin = math.sin
local mCos = math.cos
local mPi = math.pi
local mSqrt = math.sqrt
local mRandom = math.random
local tInsert = table.insert
local tRemove = table.remove
local tForEach = table.foreach
local tShuffle = table.shuffle
local sSub = string.sub
local sLower = string.lower

_M.duration = 200

-- Set reference point
function _M.setRP (object, ref_point)
    ref_point = sLower(ref_point)
    if ref_point == 'topleft' then
        object.anchorX, object.anchorY = 0, 0
    elseif ref_point == 'topright' then
        object.anchorX, object.anchorY = 1, 0
    elseif ref_point == 'topcenter' then
        object.anchorX, object.anchorY = 0.5, 0
    elseif ref_point == 'bottomleft' then
        object.anchorX, object.anchorY = 0, 1
    elseif ref_point == 'bottomright' then
        object.anchorX, object.anchorY = 1, 1
    elseif ref_point == 'bottomcenter' then
        object.anchorX, object.anchorY = 0.5, 1
    elseif ref_point == 'centerleft' then
        object.anchorX, object.anchorY = 0, 0.5
    elseif ref_point == 'centerright' then
        object.anchorX, object.anchorY = 1, 0.5
    elseif ref_point == 'center' then
        object.anchorX, object.anchorY = 0.5, 0.5
    end
end

function _M.setFillColor (object, color)
    if type(color) == 'string' then
        color = _COLORS[color]
    end
    object:setFillColor(color[1], color[2], color[3])
end

function _M.setStrokeColor (object, color)
    if type(color) == 'string' then
        color = _COLORS[color]
    end
    local color = table.copy(color)
    if not color[4] then color[4] = 255 end
    object:setStrokeColor(color[1], color[2], color[3], color[4])
end

function _M.setColor (object, color)
    if type(color) == 'string' then
        color = _COLORS[color]
    end
    local color = table.copy(color)
    if not color[4] then color[4] = 255 end
    object:setFillColor(color[1], color[2], color[3], color[4])
end

function _M.newImage(filename, params)
    params = params or {}
    local w, h = params.w or _W, params.h or _H
    local image = display.newImageRect(filename, params.dir or system.ResourceDirectory, w, h)
    if not image then return end
    if params.rp then
        _M.setRP(image, params.rp)
    end
    image.x = params.x or 0
    image.y = params.y or 0
    if params.g then
        params.g:insert(image)
    end
    return image
end

function _M.newText(params)
    params = params or {}
    local text
    if params.align then
        text = display.newText{text = params.text or '',
            x = params.x or 0, y = params.y or 0,
            width = params.w, height = params.h or (params.w and 0),
            font = params.font or _M.font,
            fontSize = params.size or 16,
            align = params.align or 'center'}
    elseif params.w then
        text = display.newEmbossedText(params.text or '', 0, 0, params.w, params.h or 0, params.font or _M.font, params.size or 16)
    elseif params.flat then
        text = display.newText(params.text or '', 0, 0, params.font or _M.font, params.size or 16)
    else
        text = display.newEmbossedText(params.text or '', 0, 0, params.font or _M.font, params.size or 16)
    end
    if params.rp then
        _M.setRP(text, params.rp)
    end
    text.x = params.x or 0
    text.y = params.y or 0
    if params.g then
        params.g:insert(text)
    end
    params.color = params.color or 'grey'
    if params.color then
        _M.setColor(text, params.color)
    end
    return text
end

function _M.newButton(params)
    local button = widget.newButton {
        width = params.w or 200, height = params.h or 60,
        defaultFile = params.image or 'images/button.png',
        overFile = params.imageOver or 'images/button-over.png',
        label = params.text,
        labelColor = params.fontColor or {default = {1, 1, 1}, over = {1, 1, 1}},
        fontSize = params.fontSize or 18,
        onPress = params.onPress,
        onRelease = params.onRelease,
        onEvent = params.onEvent}
    button.x, button.y = params.x or 0, params.y or 0
    if params.rp then
        _M.setRP(button, params.rp)
    end
    params.g:insert(button)
    return button
end

function _M.alert(txt)
    if type(txt) == 'string' then
        native.showAlert(_M.name, txt, {'OK'}, function() end)
    end
end

function _M.returnTrue(obj)
    if obj then
        local function rt() return true end
        obj:addEventListener('touch', rt)
        obj:addEventListener('tap', rt)
        obj.isHitTestable = true
    else
        return true
    end
end

_M.loadedSounds = {}
function _M:loadSound (sound_type)
    if not self.loadedSounds[sound_type] then
        local filename = _AUDIO[sound_type]
        self.loadedSounds[sound_type] = audio.loadSound(filename)
    end
    return self.loadedSounds[sound_type]
end

local audioChannel, otherAudioChannel, currentSong, curAudio, prevAudio = 1
audio.crossFadeBackground = function (path, force)
    if _M.music_on then
        local musicPath = _AUDIO[path]
        if currentSong == musicPath and audio.getVolume{channel = audioChannel} > 0.1 and not force then return false end
        audio.fadeOut({channel=audioChannel, time=1000})
        if audioChannel==1 then audioChannel,otherAudioChannel=2,1 else audioChannel,otherAudioChannel=1,2 end
        audio.setVolume( 0.5, {channel = audioChannel})
        curAudio = audio.loadStream( musicPath )
        audio.play(curAudio, {channel=audioChannel, loops=-1, fadein=1000})
        prevAudio = curAudio
        currentSong = musicPath
        audio.currentBackgroundChannel = audioChannel
    end
end
audio.reserveChannels(2)
audio.currentBackgroundChannel = 1

audio.playSFX = function (snd, params)
    if _M.sound_on then
        local channel
        if type(snd) == 'string' then channel=audio.play(audio.loadSound(_AUDIO[snd]), params)
        else channel=audio.play(snd, params) end
        audio.setVolume(1, {channel = channel})
        return channel
    end
end

function _M.initUser(t)
    _M.user = json.decode(_M.readFile('user.txt'))
    if not _M.user then
        _M.user = t
        _M.saveUser()
    end
end

function _M.saveUser()
    _M.saveFile('user.txt', json.encode(_M.user))
end

function _M.setLocals()
    local locals = {_W = _W, _H = _H, _L = _L, _R = _R, _T = _T, _B = _B, _CX = _CX, _CY = _CY, _SW = _SW, _SH = _SH}
    local i = 1
    repeat
        local k, v = debug.getlocal(2, i)
        if k then
            if v == nil then
                if not locals[k] then
                    print('No value for a local variable: ' .. k)
                else
                    debug.setlocal(2, i, locals[k])
                end
            end
            i = i + 1
        end
    until nil == k
end

function _M.nextFrame(f)
    timer.performWithDelay(1, f)
end
function _M.enterFrame()
    for i = 1, #_M.enterFrameFunctions do
        _M.enterFrameFunctions[i]()
    end
end
function _M.eachFrame(f)
    if not _M.enterFrameFunctions then
        _M.enterFrameFunctions = {}
        Runtime:addEventListener('enterFrame', _M.enterFrame)
    end
    table.insert(_M.enterFrameFunctions, f)
    return f
end
function _M.eachFrameRemove(f)
    if not f or not _M.enterFrameFunctions then return end
    local ind = table.indexOf(_M.enterFrameFunctions, f)
    if ind then
        table.remove(_M.enterFrameFunctions, ind)
        if #_M.enterFrameFunctions == 0 then
            Runtime:removeEventListener('enterFrame', _M.enterFrame)
            _M.enterFrameFunctions = nil
        end
    end
end

-- Fix problem that finalize event is not called for children objects when group is removed
local function finalize(g)
    for i = 1, g.numChildren do
        if g[i]._tableListeners and g[i]._tableListeners.finalize then
            for j = 1, #g[i]._tableListeners.finalize do
                g[i]._tableListeners.finalize[j]:dispatchEvent{name = 'finalize', target = g[i]}
            end
        end
        if g[i]._functionListeners and g[i]._functionListeners.finalize then
            for j = 1, #g[i]._functionListeners.finalize do
                g[i]._functionListeners.finalize[j]({name = 'finalize', target = g[i]})
            end
        end
        if g[i].insert then
            finalize(g[i])
        end
    end
end
local newGroup = display.newGroup
function display.newGroup()
    local g = newGroup()
    local removeSelf = g.removeSelf
    g.removeSelf = function()
            finalize(g)
            removeSelf(g)
        end
    return g
end

function _M.newBanner(g)
    local banner = _M.newImage('images/banner.png', {g = g, w = _SW, h = _M.bannerH, x = 0, y = _B, rp = 'BottomLeft'})
    return banner
end

return _M
