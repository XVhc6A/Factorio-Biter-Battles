local Public = {}

local function get_sorted_score()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:2')
	local list = {}
	for player_index, score_points in pairs(global.custom_highscore.score_list) do
		table.insert(list, { name = game.players[player_index].name, points = score_points })
	end
	local list_size = #list
	if list_size == 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:9')
		return list
	end
	table.sort(list, function(a, b)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:12')
		return a.points > b.points
	end)
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:14')
	return list
end

local score_list = function(player, frame)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:17')
	local highscore = global.custom_highscore

	frame.clear()
	frame.style.padding = 4
	frame.style.margin = 0

	local line = frame.add({ type = "line" })
	line.style.top_margin = 4
	line.style.bottom_margin = 4

	local scroll_pane = frame.add({
		type = "scroll-pane",
		name = "scroll_pane",
		direction = "vertical",
		horizontal_scroll_policy = "never",
		vertical_scroll_policy = "auto",
	})
	scroll_pane.style.minimal_width = 780
	scroll_pane.style.maximal_height = 360
	scroll_pane.style.minimal_height = 360

	local t = scroll_pane.add({ type = "table", column_count = 3 })

	local label = t.add({ type = "label", caption = "#" })
	label.style.minimal_width = 30
	label.style.font = "heading-2"
	label.style.padding = 3
	local label = t.add({ type = "label", caption = "Player:" })
	label.style.minimal_width = 160
	label.style.font = "heading-2"
	label.style.padding = 3
	local label = t.add({ type = "label", caption = global.custom_highscore.description })
	label.style.minimal_width = 160
	label.style.font = "heading-2"
	label.style.padding = 3

	for key, score in pairs(get_sorted_score()) do
		local label = t.add({ type = "label", caption = key })
		label.style.font = "heading-2"
		label.style.padding = 1
		local label = t.add({ type = "label", caption = score.name })
		label.style.font = "heading-2"
		label.style.padding = 1
		label.style.font_color = game.players[score.name].chat_color
		local label = t.add({ type = "label", caption = score.points })
		label.style.font = "heading-2"
		label.style.padding = 1
	end
end

function Public.set_score_description(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:68')
	global.custom_highscore.description = str
end

function Public.set_score(player, count)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:72')
	local score_list = global.custom_highscore.score_list
	score_list[player.index] = count
end

function Public.get_score(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:77')
	local score_list = global.custom_highscore.score_list
	if not score_list[player.index] then
		score_list[player.index] = 0
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:82')
	return score_list[player.index]
end

function Public.reset_score()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:85')
	global.custom_highscore = {
		description = "Won rounds:",
		score_list = {},
	}
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:92')
	global.custom_highscore = {
		description = "Won rounds:",
		score_list = {},
	}
end

comfy_panel_tabs["Map Scores"] = { gui = score_list, admin = false }

local event = require("utils.event")
event.on_init(on_init)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/map_score.lua:104')
return Public
