local event = require("utils.event")

local function get_empty_hotbar_slot(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:2')
	for i = 1, 20, 1 do
		local item = player.get_quick_bar_slot(i)
		if not item then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:6')
			return i
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:9')
	return false
end

local function is_item_already_present_in_hotbar(player, item)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:12')
	for i = 1, 20, 1 do
		local prototype = player.get_quick_bar_slot(i)
		if prototype then
			if item == prototype.name then
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:17')
				return true
			end
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:21')
	return false
end

local function set_hotbar(player, item)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:24')
	if not game.entity_prototypes[item] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:26')
		return
	end
	if not game.recipe_prototypes[item] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:29')
		return
	end
	local slot_index = get_empty_hotbar_slot(player)
	if not slot_index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:33')
		return
	end
	if is_item_already_present_in_hotbar(player, item) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:36')
		return
	end
	player.set_quick_bar_slot(slot_index, item)
end

local function on_player_fast_transferred(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:41')
	if not global.auto_hotbar_enabled[event.player_index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:43')
		return
	end
	local player = game.players[event.player_index]
	for name, count in pairs(player.get_main_inventory().get_contents()) do
		set_hotbar(player, name)
	end
end

local function on_player_crafted_item(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:51')
	if not global.auto_hotbar_enabled[event.player_index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:53')
		return
	end
	set_hotbar(game.players[event.player_index], event.item_stack.name)
end

local function on_picked_up_item(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:58')
	if not global.auto_hotbar_enabled[event.player_index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:60')
		return
	end
	set_hotbar(game.players[event.player_index], event.item_stack.name)
end

local function on_player_mined_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:65')
	if not global.auto_hotbar_enabled[event.player_index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:67')
		return
	end
	set_hotbar(game.players[event.player_index], event.entity.name)
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/autohotbar.lua:72')
	global.auto_hotbar_enabled = {}
end

event.on_init(on_init)
event.add(defines.events.on_player_fast_transferred, on_player_fast_transferred)
event.add(defines.events.on_player_crafted_item, on_player_crafted_item)
event.add(defines.events.on_picked_up_item, on_picked_up_item)
event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
