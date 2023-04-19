local colors = {}

for x = 1, 100, 1 do
	colors[#colors + 1] = { r = 1, g = x * 0.01, b = 0 }
end

for x = 100, 0, -1 do
	colors[#colors + 1] = { r = x * 0.01, g = 1, b = 0 }
end

for x = 1, 100, 1 do
	colors[#colors + 1] = { r = 0, g = 1, b = x * 0.01 }
end

for x = 100, 0, -1 do
	colors[#colors + 1] = { r = 0, g = x * 0.01, b = 1 }
end

for x = 1, 100, 1 do
	colors[#colors + 1] = { r = x * 0.01, g = 0, b = 1 }
end

for x = 100, 0, -1 do
	colors[#colors + 1] = { r = 1, g = 0, b = x * 0.01 }
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/tools/rainbow_colors.lua:26')
return colors
