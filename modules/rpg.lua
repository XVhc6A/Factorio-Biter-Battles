--[[
Character Experience Gain RPG by MewMew

STRENGTH > character_inventory_slots_bonus , character_mining_speed_modifier

MAGIC >	character_build_distance_bonus, character_item_drop_distance_bonus, character_reach_distance_bonus,
				character_item_pickup_distance_bonus, character_loot_pickup_distance_bonus,

DEXTERITY > character_running_speed_modifier, character_crafting_speed_modifier

VITALITY > character_health_bonus

Modified by Gerkiz *-*
]]

require("player_modifiers")

local math_random = math.random
local math_sqrt = math.sqrt
local math_floor = math.floor
local Global = require("utils.global")
local Tabs = require("comfy_panel.main")
local P = require("player_modifiers")
local visuals_delay = 1800
local level_up_floating_text_color = { 0, 205, 0 }
local xp_floating_text_color = { 157, 157, 157 }
local experience_levels = { 0 }
for a = 1, 9999, 1 do
	experience_levels[#experience_levels + 1] = experience_levels[#experience_levels] + a * 8
end
local gain_info_tooltip = "XP gain from mining, moving, crafting, repairing and combat."

local rpg_t = {}
local rpg_frame_icons = {
	"entity/small-worm-turret",
	"entity/medium-worm-turret",
	"entity/big-worm-turret",
	"entity/behemoth-worm-turret",
	"entity/small-biter",
	"entity/small-biter",
	"entity/small-spitter",
	"entity/medium-biter",
	"entity/medium-biter",
	"entity/medium-spitter",
	"entity/big-biter",
	"entity/big-biter",
	"entity/big-spitter",
	"entity/behemoth-biter",
	"entity/behemoth-biter",
	"entity/behemoth-spitter",
}

Global.register({ rpg_t = rpg_t, rpg_frame_icons = rpg_frame_icons }, function(tbl)
	rpg_t = tbl.rpg_t
	rpg_frame_icons = tbl.rpg_frame_icons
end)

local Public = {}

function Public.get_table()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:59')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:60')
	return rpg_t
end

local classes = {
	["engineer"] = "ENGINEER",
	["strength"] = "MINER",
	["magic"] = "SORCERER",
	["dexterity"] = "ROGUE",
	["vitality"] = "TANK",
}

local xp_yield = {
	["behemoth-biter"] = 16,
	["behemoth-spitter"] = 16,
	["behemoth-worm-turret"] = 64,
	["big-biter"] = 8,
	["big-spitter"] = 8,
	["big-worm-turret"] = 48,
	["biter-spawner"] = 64,
	["character"] = 16,
	["gun-turret"] = 8,
	["laser-turret"] = 16,
	["medium-biter"] = 4,
	["medium-spitter"] = 4,
	["medium-worm-turret"] = 32,
	["small-biter"] = 1,
	["small-spitter"] = 1,
	["small-worm-turret"] = 16,
	["spitter-spawner"] = 64,
}

local enemy_types = {
	["unit"] = true,
	["unit-spawner"] = true,
	["turret"] = true,
}

local function level_up_effects(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:97')
	local position = { x = player.position.x - 0.75, y = player.position.y - 1 }
	player.surface.create_entity({
		name = "flying-text",
		position = position,
		text = "+LVL ",
		color = level_up_floating_text_color,
	})
	local b = 0.75
	for a = 1, 5, 1 do
		local p = {
			(position.x + 0.4) + (b * -1 + math_random(0, b * 20) * 0.1),
			position.y + (b * -1 + math_random(0, b * 20) * 0.1),
		}
		player.surface.create_entity({
			name = "flying-text",
			position = p,
			text = "✚",
			color = { 255, math_random(0, 100), 0 },
		})
	end
	player.play_sound({ path = "utility/achievement_unlocked", volume_modifier = 0.40 })
end

local function get_melee_modifier(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:121')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:122')
	return (rpg_t[player.index].strength - 10) * 0.10
end

local function get_life_on_hit(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:125')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:126')
	return (rpg_t[player.index].vitality - 10) * 0.4
end

local function get_one_punch_chance(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:129')
	if rpg_t[player.index].strength < 100 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:131')
		return 0
	end
	local chance = math.round(rpg_t[player.index].strength * 0.01, 1)
	if chance > 100 then
		chance = 100
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:137')
	return chance
end

local function draw_gui_char_button(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:140')
	if player.gui.top.rpg then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:142')
		return
	end
	local b = player.gui.top.add({ type = "sprite-button", name = "rpg", caption = "CHAR" })
	b.style.font_color = { 165, 165, 165 }
	b.style.font = "heading-1"
	b.style.minimal_height = 38
	b.style.minimal_width = 60
	b.style.padding = 0
	b.style.margin = 0
end

local function update_char_button(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:153')
	if not player.gui.top.rpg then
		draw_gui_char_button(player)
	end
	if rpg_t[player.index].points_to_distribute > 0 then
		player.gui.top.rpg.style.font_color = { 245, 0, 0 }
	else
		player.gui.top.rpg.style.font_color = { 175, 175, 175 }
	end
end

local function update_player_stats(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:164')
	local player_modifiers = P.get_table()
	local strength = rpg_t[player.index].strength - 10
	player_modifiers[player.index].character_inventory_slots_bonus["rpg"] = math.round(strength * 0.2, 3)
	player_modifiers[player.index].character_mining_speed_modifier["rpg"] = math.round(strength * 0.008, 3)

	local magic = rpg_t[player.index].magic - 10
	local v = magic * 0.15
	player_modifiers[player.index].character_build_distance_bonus["rpg"] = math.round(v, 3)
	player_modifiers[player.index].character_item_drop_distance_bonus["rpg"] = math.round(v, 3)
	player_modifiers[player.index].character_reach_distance_bonus["rpg"] = math.round(v, 3)
	player_modifiers[player.index].character_loot_pickup_distance_bonus["rpg"] = math.round(v * 0.5, 3)
	player_modifiers[player.index].character_item_pickup_distance_bonus["rpg"] = math.round(v * 0.25, 3)
	player_modifiers[player.index].character_resource_reach_distance_bonus["rpg"] = math.round(v * 0.15, 3)

	local dexterity = rpg_t[player.index].dexterity - 10
	player_modifiers[player.index].character_running_speed_modifier["rpg"] = math.round(dexterity * 0.002, 3)
	player_modifiers[player.index].character_crafting_speed_modifier["rpg"] = math.round(dexterity * 0.015, 3)

	player_modifiers[player.index].character_health_bonus["rpg"] =
		math.round((rpg_t[player.index].vitality - 10) * 6, 3)

	P.update_player_modifiers(player)
end

local function get_class(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:189')
	local average = (
		rpg_t[player.index].strength
		+ rpg_t[player.index].magic
		+ rpg_t[player.index].dexterity
		+ rpg_t[player.index].vitality
	) / 4
	local high_attribute = 0
	local high_attribute_name = ""
	for _, attribute in pairs({ "strength", "magic", "dexterity", "vitality" }) do
		if rpg_t[player.index][attribute] > high_attribute then
			high_attribute = rpg_t[player.index][attribute]
			high_attribute_name = attribute
		end
	end
	if high_attribute < average + average * 0.25 then
		high_attribute_name = "engineer"
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:207')
	return classes[high_attribute_name]
end

local function add_gui_description(element, value, width)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:210')
	local e = element.add({ type = "label", caption = value })
	e.style.single_line = false
	e.style.maximal_width = width
	e.style.minimal_width = width
	e.style.maximal_height = 40
	e.style.minimal_height = 38
	e.style.font = "default-bold"
	e.style.font_color = { 175, 175, 200 }
	e.style.horizontal_align = "right"
	e.style.vertical_align = "center"
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:221')
	return e
end

local function add_gui_stat(element, value, width)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:224')
	local e = element.add({ type = "sprite-button", caption = value })
	e.style.maximal_width = width
	e.style.minimal_width = width
	e.style.maximal_height = 38
	e.style.minimal_height = 38
	e.style.font = "default-bold"
	e.style.font_color = { 222, 222, 222 }
	e.style.horizontal_align = "center"
	e.style.vertical_align = "center"
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:234')
	return e
end

local function add_gui_increase_stat(element, name, player, width)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:237')
	local sprite = "virtual-signal/signal-red"
	local symbol = "✚"
	if rpg_t[player.index].points_to_distribute <= 0 then
		sprite = "virtual-signal/signal-black"
	end
	local e = element.add({ type = "sprite-button", name = name, caption = symbol, sprite = sprite })
	e.style.maximal_height = 38
	e.style.minimal_height = 38
	e.style.maximal_width = 38
	e.style.minimal_width = 38
	e.style.font = "default-large-semibold"
	e.style.font_color = { 0, 0, 0 }
	e.style.horizontal_align = "center"
	e.style.vertical_align = "center"
	e.style.padding = 0
	e.style.margin = 0
	e.tooltip = "Rightclick to allocate 5 points."

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:256')
	return e
end

local function add_separator(element, width)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:259')
	local e = element.add({ type = "line" })
	e.style.maximal_width = width
	e.style.minimal_width = width
	e.style.minimal_height = 12
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:264')
	return e
end

local function draw_gui(player, forced)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:267')
	if not forced then
		if rpg_t[player.index].gui_refresh_delay > game.tick then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:270')
			return
		end
	end

	Tabs.comfy_panel_clear_left_gui(player)

	if player.gui.left.rpg then
		player.gui.left.rpg.destroy()
	end
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:280')
		return
	end

	local frame = player.gui.left.add({ type = "frame", name = "rpg", direction = "vertical" })
	frame.style.maximal_width = 425
	frame.style.minimal_width = 425
	frame.style.margin = 6

	add_separator(frame, 400)

	local t = frame.add({ type = "table", column_count = 2 })
	local e = add_gui_stat(t, player.name, 200)
	e.style.font_color = player.chat_color
	e.style.font = "default-large-bold"
	local e = add_gui_stat(t, get_class(player), 200)
	e.style.font = "default-large-bold"

	add_separator(frame, 400)

	local t = frame.add({ type = "table", column_count = 4 })
	t.style.cell_padding = 1

	add_gui_description(t, "LEVEL", 80)
	add_gui_stat(t, rpg_t[player.index].level, 80)

	add_gui_description(t, "EXPERIENCE", 100)
	local e = add_gui_stat(t, math.floor(rpg_t[player.index].xp), 125)
	e.tooltip = gain_info_tooltip

	add_gui_description(t, " ", 75)
	add_gui_description(t, " ", 75)

	add_gui_description(t, "NEXT LEVEL", 100)
	local e = add_gui_stat(t, experience_levels[rpg_t[player.index].level + 1], 125)
	e.tooltip = gain_info_tooltip

	add_separator(frame, 400)

	local t = frame.add({ type = "table", column_count = 2 })
	local tt = t.add({ type = "table", column_count = 3 })
	tt.style.cell_padding = 1
	local w1 = 85
	local w2 = 63

	local tip = "Increases inventory slots and mining speed.\nIncreases melee damage."
	local e = add_gui_description(tt, "STRENGTH", w1)
	e.tooltip = tip
	local e = add_gui_stat(tt, rpg_t[player.index].strength, w2)
	e.tooltip = tip
	add_gui_increase_stat(tt, "strength", player)

	local tip = "Increases reach distance."
	local e = add_gui_description(tt, "MAGIC", w1)
	e.tooltip = tip
	local e = add_gui_stat(tt, rpg_t[player.index].magic, w2)
	e.tooltip = tip
	add_gui_increase_stat(tt, "magic", player)

	local tip = "Increases running and crafting speed."
	local e = add_gui_description(tt, "DEXTERITY", w1)
	e.tooltip = tip
	local e = add_gui_stat(tt, rpg_t[player.index].dexterity, w2)
	e.tooltip = tip
	add_gui_increase_stat(tt, "dexterity", player)

	local tip = "Increases health.\nIncreases melee life on-hit."
	local e = add_gui_description(tt, "VITALITY", w1)
	e.tooltip = tip
	local e = add_gui_stat(tt, rpg_t[player.index].vitality, w2)
	e.tooltip = tip
	add_gui_increase_stat(tt, "vitality", player)

	add_gui_description(tt, "POINTS TO\nDISTRIBUTE", w1)
	local e = add_gui_stat(tt, rpg_t[player.index].points_to_distribute, w2)
	e.style.font_color = { 200, 0, 0 }
	add_gui_description(tt, " ", w2)

	add_gui_description(tt, " ", w1)
	add_gui_description(tt, " ", w2)
	add_gui_description(tt, " ", w2)

	add_gui_description(tt, "LIFE", w1)
	add_gui_stat(tt, math.floor(player.character.health), w2)
	add_gui_stat(
		tt,
		math.floor(
			player.character.prototype.max_health + player.character_health_bonus + player.force.character_health_bonus
		),
		w2
	)

	local shield = 0
	local shield_max = 0
	local i = player.character.get_inventory(defines.inventory.character_armor)
	if not i.is_empty() then
		if i[1].grid then
			shield = math.floor(i[1].grid.shield)
			shield_max = math.floor(i[1].grid.max_shield)
		end
	end
	add_gui_description(tt, "SHIELD", w1)
	add_gui_stat(tt, shield, w2)
	add_gui_stat(tt, shield_max, w2)

	local tt = t.add({ type = "table", column_count = 3 })
	tt.style.cell_padding = 1
	local w0 = 2
	local w1 = 80
	local w2 = 80

	add_gui_description(tt, " ", w0)
	add_gui_description(tt, "MINING\nSPEED", w1)
	local value = (player.force.manual_mining_speed_modifier + player.character_mining_speed_modifier + 1) * 100 .. "%"
	add_gui_stat(tt, value, w2)

	add_gui_description(tt, " ", w0)
	add_gui_description(tt, "SLOT\nBONUS", w1)
	local value = "+ " .. player.force.character_inventory_slots_bonus + player.character_inventory_slots_bonus
	add_gui_stat(tt, value, w2)

	add_gui_description(tt, " ", w0)
	add_gui_description(tt, "MELEE\nDAMAGE", w1)
	local value = 100 * (1 + get_melee_modifier(player)) .. "%"
	local e = add_gui_stat(tt, value, w2)
	e.tooltip = "Life on-hit: "
		.. get_life_on_hit(player)
		.. "\nOne punch chance: "
		.. get_one_punch_chance(player)
		.. "%"

	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10
	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10
	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10

	local value = "+ " .. (player.force.character_reach_distance_bonus + player.character_reach_distance_bonus)
	local tooltip = ""
	tooltip = tooltip .. "Reach distance bonus: " .. player.character_reach_distance_bonus
	tooltip = tooltip .. "\nBuild distance bonus: " .. player.character_build_distance_bonus
	tooltip = tooltip .. "\nItem drop distance bonus: " .. player.character_item_drop_distance_bonus
	tooltip = tooltip .. "\nLoot pickup distance bonus: " .. player.character_loot_pickup_distance_bonus
	tooltip = tooltip .. "\nItem pickup distance bonus: " .. player.character_item_pickup_distance_bonus
	tooltip = tooltip .. "\nResource reach distance bonus: " .. player.character_resource_reach_distance_bonus
	add_gui_description(tt, " ", w0)
	local e = add_gui_description(tt, "REACH\nDISTANCE", w1)
	e.tooltip = tooltip
	local e = add_gui_stat(tt, value, w2)
	e.tooltip = tooltip

	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10
	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10
	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10

	add_gui_description(tt, " ", w0)
	add_gui_description(tt, "CRAFTING\nSPEED", w1)
	local value = (player.force.manual_crafting_speed_modifier + player.character_crafting_speed_modifier + 1) * 100
		.. "%"
	add_gui_stat(tt, value, w2)

	add_gui_description(tt, " ", w0)
	add_gui_description(tt, "RUNNING\nSPEED", w1)
	local value = (player.force.character_running_speed_modifier + player.character_running_speed_modifier + 1) * 100
		.. "%"
	add_gui_stat(tt, value, w2)

	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10
	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10
	local e = add_gui_description(tt, "", w0)
	e.style.maximal_height = 10

	add_gui_description(tt, " ", w0)
	add_gui_description(tt, "HEALTH\nBONUS", w1)
	local value = "+ " .. (player.force.character_health_bonus + player.character_health_bonus)
	add_gui_stat(tt, value, w2)

	add_separator(frame, 400)
	local t = frame.add({ type = "table", column_count = 14 })
	for i = 1, 14, 1 do
		local e = t.add({ type = "sprite", sprite = rpg_frame_icons[i] })
		e.style.maximal_width = 24
		e.style.maximal_height = 24
		e.style.padding = 0
	end
	add_separator(frame, 400)

	rpg_t[player.index].gui_refresh_delay = game.tick + 60
	update_char_button(player)
end

local function draw_level_text(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:476')
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:478')
		return
	end

	if rpg_t[player.index].text then
		rendering.destroy(rpg_t[player.index].text)
		rpg_t[player.index].text = nil
	end

	local players = {}
	for _, p in pairs(game.players) do
		if p.index ~= player.index then
			players[#players + 1] = p.index
		end
	end
	if #players == 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:493')
		return
	end

	rpg_t[player.index].text = rendering.draw_text({
		text = "lvl " .. rpg_t[player.index].level,
		surface = player.surface,
		target = player.character,
		target_offset = { 0, -3.25 },
		color = {
			r = player.color.r * 0.6 + 0.25,
			g = player.color.g * 0.6 + 0.25,
			b = player.color.b * 0.6 + 0.25,
			a = 1,
		},
		players = players,
		scale = 1.00,
		font = "default-large-semibold",
		alignment = "center",
		scale_with_zoom = false,
	})
end

local function level_up(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:515')
	local distribute_points_gain = 0
	for i = rpg_t[player.index].level + 1, #experience_levels, 1 do
		if rpg_t[player.index].xp > experience_levels[i] then
			rpg_t[player.index].level = i
			distribute_points_gain = distribute_points_gain + 5
		else
			break
		end
	end
	if distribute_points_gain == 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:526')
		return
	end
	draw_level_text(player)
	rpg_t[player.index].points_to_distribute = rpg_t[player.index].points_to_distribute + distribute_points_gain
	update_char_button(player)
	table.shuffle_table(rpg_frame_icons)
	if player.gui.left.rpg then
		draw_gui(player, true)
	end
	level_up_effects(player)
end

local function gain_xp(player, amount)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:538')
	amount = math.round(amount, 2)
	rpg_t[player.index].xp = rpg_t[player.index].xp + amount
	rpg_t[player.index].xp_since_last_floaty_text = rpg_t[player.index].xp_since_last_floaty_text + amount
	if player.gui.left.rpg then
		draw_gui(player, false)
	end
	if not experience_levels[rpg_t[player.index].level + 1] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:546')
		return
	end
	if rpg_t[player.index].xp >= experience_levels[rpg_t[player.index].level + 1] then
		level_up(player)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:550')
		return
	end
	if rpg_t[player.index].last_floaty_text > game.tick then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:553')
		return
	end
	player.create_local_flying_text({
		text = "+" .. rpg_t[player.index].xp_since_last_floaty_text .. " xp",
		position = player.position,
		color = xp_floating_text_color,
		time_to_live = 120,
		speed = 2,
	})
	rpg_t[player.index].xp_since_last_floaty_text = 0
	rpg_t[player.index].last_floaty_text = game.tick + visuals_delay
end

function Public.rpg_reset_player(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:566')
	if player.gui.left.rpg then
		player.gui.left.rpg.destroy()
	end
	if not player.character then
		player.set_controller({ type = defines.controllers.god })
		player.create_character()
	end
	rpg_t[player.index] = {
		level = 1,
		xp = 0,
		strength = 10,
		magic = 10,
		dexterity = 10,
		vitality = 10,
		points_to_distribute = 0,
		last_floaty_text = visuals_delay,
		xp_since_last_floaty_text = 0,
		rotated_entity_delay = 0,
		gui_refresh_delay = 0,
		last_mined_entity_position = { x = 0, y = 0 },
	}
	draw_gui_char_button(player)
	draw_level_text(player)
	update_char_button(player)
	update_player_stats(player)
end

function Public.rpg_reset_all_players()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:594')
	for _, p in pairs(game.players) do
		rpg_t[p.index] = nil
	end
	for _, p in pairs(game.connected_players) do
		Public.rpg_reset_player(p)
	end
end

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:603')
	if not event.element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:605')
		return
	end
	if not event.element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:608')
		return
	end
	local element = event.element

	if element.type ~= "sprite-button" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:613')
		return
	end

	if element.caption == "CHAR" then
		if element.name == "rpg" then
			local player = game.players[event.player_index]
			if player.gui.left.rpg then
				player.gui.left.rpg.destroy()
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:621')
				return
			end
			draw_gui(player, true)
		end
	end

	if element.caption ~= "✚" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:628')
		return
	end
	if element.sprite ~= "virtual-signal/signal-red" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:631')
		return
	end

	local index = element.name
	local player = game.players[event.player_index]
	if not rpg_t[player.index][index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:637')
		return
	end
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:640')
		return
	end

	if event.button == defines.mouse_button_type.right then
		for a = 1, 5, 1 do
			if rpg_t[player.index].points_to_distribute <= 0 then
				draw_gui(player, true)
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:647')
				return
			end
			rpg_t[player.index].points_to_distribute = rpg_t[player.index].points_to_distribute - 1
			rpg_t[player.index][index] = rpg_t[player.index][index] + 1
			update_player_stats(player)
		end
		draw_gui(player, true)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:654')
		return
	end

	if rpg_t[player.index].points_to_distribute <= 0 then
		draw_gui(player, true)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:659')
		return
	end
	rpg_t[player.index].points_to_distribute = rpg_t[player.index].points_to_distribute - 1
	rpg_t[player.index][index] = rpg_t[player.index][index] + 1
	update_player_stats(player)
	draw_gui(player, true)
end

local function train_type_cause(cause)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:667')
	local players = {}
	if cause.train.passengers then
		for _, player in pairs(cause.train.passengers) do
			players[#players + 1] = player
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:674')
	return players
end

local get_cause_player = {
	["character"] = function(cause)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:678')
		if not cause.player then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:680')
			return
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:682')
		return { cause.player }
	end,
	["combat-robot"] = function(cause)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:684')
		if not cause.last_user then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:686')
			return
		end
		if not game.players[cause.last_user.index] then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:689')
			return
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:691')
		return { game.players[cause.last_user.index] }
	end,
	["car"] = function(cause)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:693')
		local players = {}
		local driver = cause.get_driver()
		if driver then
			if driver.player then
				players[#players + 1] = driver.player
			end
		end
		local passenger = cause.get_passenger()
		if passenger then
			if passenger.player then
				players[#players + 1] = passenger.player
			end
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:707')
		return players
	end,
	["locomotive"] = train_type_cause,
	["cargo-wagon"] = train_type_cause,
	["artillery-wagon"] = train_type_cause,
	["fluid-wagon"] = train_type_cause,
}

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:715')
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:717')
		return
	end

	--Grant XP for hand placed land mines
	if event.entity.last_user then
		if event.entity.type == "land-mine" then
			if event.cause then
				if event.cause.valid then
					if event.cause.force.index == event.entity.force.index then
						log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:726')
						return
					end
				end
			end
			gain_xp(event.entity.last_user, 1)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:731')
			return
		end
	end

	if not event.cause then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:736')
		return
	end
	if not event.cause.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:739')
		return
	end
	if event.cause.force.index == event.entity.force.index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:742')
		return
	end
	if not get_cause_player[event.cause.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:745')
		return
	end

	local players = get_cause_player[event.cause.type](event.cause)
	if not players then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:750')
		return
	end
	if not players[1] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:753')
		return
	end

	--Grant modified XP for health boosted units
	if global.biter_health_boost then
		if enemy_types[event.entity.type] then
			for _, player in pairs(players) do
				if xp_yield[event.entity.name] then
					gain_xp(player, xp_yield[event.entity.name] * global.biter_health_boost)
				else
					gain_xp(player, 0.5 * global.biter_health_boost)
				end
			end
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:766')
			return
		end
	end

	--Grant normal XP
	for _, player in pairs(players) do
		if xp_yield[event.entity.name] then
			gain_xp(player, xp_yield[event.entity.name])
		else
			gain_xp(player, 0.5)
		end
	end
end

--Melee damage modifier
local function one_punch(character, target, damage)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:781')
	local base_vector = { target.position.x - character.position.x, target.position.y - character.position.y }

	local vector = { base_vector[1], base_vector[2] }
	vector[1] = vector[1] * 1000
	vector[2] = vector[2] * 1000

	character.surface.create_entity({
		name = "flying-text",
		position = { character.position.x + base_vector[1] * 0.5, character.position.y + base_vector[2] * 0.5 },
		text = "ONE PUNCH",
		color = { 255, 0, 0 },
	})
	character.surface.create_entity({ name = "blood-explosion-huge", position = target.position })
	character.surface.create_entity({
		name = "big-artillery-explosion",
		position = { target.position.x + vector[1] * 0.5, target.position.y + vector[2] * 0.5 },
	})

	if math.abs(vector[1]) > math.abs(vector[2]) then
		local d = math.abs(vector[1])
		if math.abs(vector[1]) > 0 then
			vector[1] = vector[1] / d
		end
		if math.abs(vector[2]) > 0 then
			vector[2] = vector[2] / d
		end
	else
		local d = math.abs(vector[2])
		if math.abs(vector[2]) > 0 then
			vector[2] = vector[2] / d
		end
		if math.abs(vector[1]) > 0 and d > 0 then
			vector[1] = vector[1] / d
		end
	end

	vector[1] = vector[1] * 1.5
	vector[2] = vector[2] * 1.5

	local a = 0.25

	for i = 1, 16, 1 do
		for x = i * -1 * a, i * a, 1 do
			for y = i * -1 * a, i * a, 1 do
				local p = { character.position.x + x + vector[1] * i, character.position.y + y + vector[2] * i }
				character.surface.create_trivial_smoke({ name = "train-smoke", position = p })
				for _, e in pairs(character.surface.find_entities({ { p[1] - a, p[2] - a }, { p[1] + a, p[2] + a } })) do
					if e.valid then
						if e.health then
							if e.destructible and e.minable and e.force.index ~= 3 then
								if e.force.index ~= character.force.index then
									e.health = e.health - damage * 0.05
									if e.health <= 0 then
										e.die(e.force.name, character)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:847')
	if not event.cause then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:849')
		return
	end
	if not event.cause.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:852')
		return
	end
	if event.cause.force.index == 2 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:855')
		return
	end
	if event.cause.name ~= "character" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:858')
		return
	end
	if event.damage_type.name ~= "physical" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:861')
		return
	end
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:864')
		return
	end
	if
		event.cause.get_inventory(defines.inventory.character_ammo)[event.cause.selected_gun_index].valid_for_read
		and event.cause.get_inventory(defines.inventory.character_guns)[event.cause.selected_gun_index].valid_for_read
	then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:870')
		return
	end
	if not event.cause.player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:873')
		return
	end

	--Grant the player life-on-hit.
	event.cause.health = event.cause.health + get_life_on_hit(event.cause.player)

	--Calculate modified damage.
	local damage = event.original_damage_amount + event.original_damage_amount * get_melee_modifier(event.cause.player)
	if event.entity.prototype.resistances then
		if event.entity.prototype.resistances.physical then
			damage = damage - event.entity.prototype.resistances.physical.decrease
			damage = damage - damage * event.entity.prototype.resistances.physical.percent
		end
	end
	damage = math.round(damage, 3)
	if damage < 1 then
		damage = 1
	end

	--Cause a one punch.
	if math_random(0, 999) < get_one_punch_chance(event.cause.player) * 10 then
		one_punch(event.cause, event.entity, damage)
		if event.entity.valid then
			event.entity.die(event.entity.force.name, event.cause)
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:898')
		return
	end

	--Floating messages and particle effects.
	if math_random(1, 7) == 1 then
		damage = damage * math_random(250, 350) * 0.01
		event.cause.surface.create_entity({
			name = "flying-text",
			position = event.entity.position,
			text = "‼" .. math.floor(damage),
			color = { 255, 0, 0 },
		})
		event.cause.surface.create_entity({ name = "blood-explosion-huge", position = event.entity.position })
	else
		damage = damage * math_random(100, 125) * 0.01
		event.cause.player.create_local_flying_text({
			text = math.floor(damage),
			position = event.entity.position,
			color = { 150, 150, 150 },
			time_to_live = 90,
			speed = 2,
		})
	end

	--Handle the custom health pool of the biter health booster, if it is used in the map.
	if global.biter_health_boost then
		local health_pool = global.biter_health_boost_units[event.entity.unit_number]
		if health_pool then
			health_pool[1] = health_pool[1] + event.final_damage_amount
			health_pool[1] = health_pool[1] - damage

			--Set entity health relative to health pool
			event.entity.health = health_pool[1] * health_pool[2]

			if health_pool[1] <= 0 then
				global.biter_health_boost_units[event.entity.unit_number] = nil
				event.entity.die(event.entity.force.name, event.cause)
			end
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:936')
			return
		end
	end

	--Handle vanilla damage.
	event.entity.health = event.entity.health + event.final_damage_amount
	event.entity.health = event.entity.health - damage
	if event.entity.health <= 0 then
		event.entity.die(event.entity.force.name, event.cause)
	end
end

local function on_player_repaired_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:948')
	if math_random(1, 4) ~= 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:950')
		return
	end
	local player = game.players[event.player_index]
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:954')
		return
	end
	gain_xp(player, 0.40)
end

local function on_player_rotated_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:959')
	local player = game.players[event.player_index]
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:962')
		return
	end
	if rpg_t[player.index].rotated_entity_delay > game.tick then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:965')
		return
	end
	rpg_t[player.index].rotated_entity_delay = game.tick + 20
	gain_xp(player, 0.20)
end

local function on_player_changed_position(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:971')
	if math_random(1, 64) ~= 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:973')
		return
	end
	local player = game.players[event.player_index]
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:977')
		return
	end
	if player.character.driving then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:980')
		return
	end
	gain_xp(player, 1.0)
end

local building_and_mining_blacklist = {
	["tile-ghost"] = true,
	["entity-ghost"] = true,
	["item-entity"] = true,
}

local function on_pre_player_mined_item(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:991')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:994')
		return
	end
	if building_and_mining_blacklist[entity.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:997')
		return
	end
	if entity.force.index ~= 3 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1000')
		return
	end
	local player = game.players[event.player_index]

	if
		rpg_t[player.index].last_mined_entity_position.x == event.entity.position.x
		and rpg_t[player.index].last_mined_entity_position.y == event.entity.position.y
	then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1008')
		return
	end
	rpg_t[player.index].last_mined_entity_position.x = entity.position.x
	rpg_t[player.index].last_mined_entity_position.y = entity.position.y

	local distance_multiplier = math_floor(math_sqrt(entity.position.x ^ 2 + entity.position.y ^ 2)) * 0.0005 + 1

	local xp_amount
	if entity.type == "resource" then
		xp_amount = 0.5 * distance_multiplier
	else
		xp_amount = (1.5 + event.entity.prototype.max_health * 0.0035) * distance_multiplier
	end

	gain_xp(player, xp_amount)
end

local function on_player_crafted_item(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1025')
	if not event.recipe.energy then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1027')
		return
	end
	local player = game.players[event.player_index]
	gain_xp(player, event.recipe.energy * 0.20)
end

local function on_player_respawned(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1033')
	local player = game.players[event.player_index]
	if not rpg_t[player.index] then
		Public.rpg_reset_player(player)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1037')
		return
	end
	update_player_stats(player)
	draw_level_text(player)
end

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1043')
	local player = game.players[event.player_index]
	if not rpg_t[player.index] then
		Public.rpg_reset_player(player)
	end
	for _, p in pairs(game.connected_players) do
		draw_level_text(p)
	end
	draw_gui_char_button(player)
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1053')
		return
	end
	update_player_stats(player)
end

local function on_init(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1058')
	table.shuffle_table(rpg_frame_icons)
end

local event = require("utils.event")
event.on_init(on_init)
event.add(defines.events.on_entity_damaged, on_entity_damaged)
event.add(defines.events.on_entity_died, on_entity_died)
event.add(defines.events.on_gui_click, on_gui_click)
event.add(defines.events.on_player_changed_position, on_player_changed_position)
event.add(defines.events.on_player_crafted_item, on_player_crafted_item)
event.add(defines.events.on_player_joined_game, on_player_joined_game)
event.add(defines.events.on_player_repaired_entity, on_player_repaired_entity)
event.add(defines.events.on_player_respawned, on_player_respawned)
event.add(defines.events.on_player_rotated_entity, on_player_rotated_entity)
event.add(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg.lua:1075')
return Public
