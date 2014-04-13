local h, w = display.pixelWidth, display.pixelHeight
if (w == 1024 and h == 768) or (w == 960 and h == 640) or (w == 1136 and h == 640) or (w == 2048 and h == 1536) or (w == 1280 and h == 720) or (w == 480 and h == 320) then
    while w > 700 do
        w = w * 0.5
        h = h * 0.5
    end
    w, h = h, w
else
    w = 320
    h = 480
end
application = {
	content = {
        width = w,
		height = h,
		scale = 'letterbox',
		fps = 60,
		imageSuffix = {
			['@2x'] = 1.2
		}
	},
}