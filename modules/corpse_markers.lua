local function draw_map_tag(surface, force, position)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:0')
	force.add_chart_tag(surface, { icon = { type = "item", name = "heavy-armor" }, position = position, text = "   " })
end

local function is_tag_valid(tag)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:4')
	if not tag.icon then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:6')
		return
	end
	if tag.icon.type ~= "item" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:9')
		return
	end
	if tag.icon.name ~= "heavy-armor" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:12')
		return
	end
	if tag.text ~= "   " then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:15')
		return
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:17')
	return true
end

local function get_corpse_force(corpse)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:20')
	if corpse.character_corpse_player_index then
		if game.players[corpse.character_corpse_player_index] then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:23')
			return game.players[corpse.character_corpse_player_index].force
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:26')
	return game.forces.neutral
end

local function destroy_all_tags()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:29')
	for _, force in pairs(game.forces) do
		for _, surface in pairs(game.surfaces) do
			for _, tag in pairs(force.find_chart_tags(surface)) do
				if is_tag_valid(tag) then
					tag.destroy()
				end
			end
		end
	end
end

local function redraw_all_tags()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:41')
	for _, surface in pairs(game.surfaces) do
		for _, corpse in pairs(surface.find_entities_filtered({ name = "character-corpse" })) do
			draw_map_tag(corpse.surface, get_corpse_force(corpse), corpse.position)
		end
	end
end

local function find_and_destroy_tag(corpse)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:49')
	local force = get_corpse_force(corpse)
	for _, tag in
		pairs(force.find_chart_tags(corpse.surface, {
			{ corpse.position.x - 0.1, corpse.position.y - 0.1 },
			{ corpse.position.x + 0.1, corpse.position.y + 0.1 },
		}))
	do
		if is_tag_valid(tag) then
			tag.destroy()
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:59')
			return true
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:62')
	return false
end

local function on_player_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:65')
	local player = game.players[event.player_index]
	draw_map_tag(player.surface, player.force, player.position)
end

local function on_character_corpse_expired(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:70')
	if find_and_destroy_tag(event.corpse) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:72')
		return
	end
	destroy_all_tags()
	redraw_all_tags()
end

local function on_pre_player_mined_item(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:78')
	if event.entity.name ~= "character-corpse" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:80')
		return
	end
	if find_and_destroy_tag(event.entity) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/corpse_markers.lua:83')
		return
	end
	destroy_all_tags()
	redraw_all_tags()
end

local event = require("utils.event")
event.add(defines.events.on_player_died, on_player_died)
event.add(defines.events.on_character_corpse_expired, on_character_corpse_expired)
event.add(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
