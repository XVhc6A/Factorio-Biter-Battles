local Global = require("utils.global")
local Color = require("utils.color_presets")
local Event = require("utils.event")

local this = {
	data = {},
}
local Public = {}

Global.register(this, function(tbl)
	this = tbl
end)

local space = {
	minimal_height = 10,
	top_padding = 0,
	bottom_padding = 0,
}

local function get_player_data(player, remove)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:19')
	if remove and this.data[player.index] then
		this.data[player.index] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:22')
		return
	end
	if not this.data[player.index] then
		this.data[player.index] = {}
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:27')
	return this.data[player.index]
end

local function addStyle(guiIn, styleIn)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:30')
	for k, v in pairs(styleIn) do
		guiIn.style[k] = v
	end
end

local function adjustSpace(guiIn)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:36')
	addStyle(guiIn.add({ type = "line", direction = "horizontal" }), space)
end

local function validate_object(obj)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:40')
	if not obj then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:42')
		return false
	end
	if not obj.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:45')
		return false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:47')
	return true
end

local function player_opened(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:50')
	local data = get_player_data(player)

	if not data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:54')
		return false
	end

	local opened = data.player_opened

	if not validate_object(opened) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:60')
		return false
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:63')
	return true, opened
end

local function last_tab(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:66')
	local data = get_player_data(player)

	if not data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:70')
		return false
	end

	local tab = data.last_tab
	if not tab then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:75')
		return false
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:78')
	return true, tab
end

local function validate_player(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:81')
	if not player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:83')
		return false
	end
	if not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:86')
		return false
	end
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:89')
		return false
	end
	if not player.connected then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:92')
		return false
	end
	if not game.players[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:95')
		return false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:97')
	return true
end

local function close_player_inventory(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:100')
	local data = get_player_data(player)

	if not data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:104')
		return
	end

	local gui = player.gui.screen

	if not validate_object(gui) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:110')
		return
	end

	local element = gui.inventory_gui

	if not validate_object(element) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:116')
		return
	end

	element.destroy()
	get_player_data(player, true)
end

local function redraw_inventory(gui, source, target, caption, panel_type)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:123')
	gui.clear()

	local items_table = gui.add({ type = "table", column_count = 11 })
	local types = game.item_prototypes

	local screen = source.gui.screen

	if not validate_object(screen) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:132')
		return
	end

	local inventory_gui = screen.inventory_gui

	inventory_gui.caption = "Inventory of " .. target.name

	for name, opts in pairs(panel_type) do
		local flow = items_table.add({ type = "flow" })
		flow.style.vertical_align = "bottom"

		local button = flow.add({
			type = "sprite-button",
			sprite = "item/" .. name,
			number = opts,
			name = name,
			tooltip = types[name].localised_name,
			style = "slot_button",
		})
		button.enabled = false

		if caption == "Armor" then
			if target.get_inventory(5)[1].grid then
				local p_armor = target.get_inventory(5)[1].grid.get_contents()
				for k, v in pairs(p_armor) do
					local armor_gui = flow.add({
						type = "sprite-button",
						sprite = "item/" .. k,
						number = v,
						name = k,
						tooltip = types[name].localised_name,
						style = "slot_button",
					})
					armor_gui.enabled = false
				end
			end
		end
	end
end

local function add_inventory(panel, source, target, caption, panel_type)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:172')
	local data = get_player_data(source)
	data.panel_type = data.panel_type or {}
	local pane_name = panel.add({ type = "tab", caption = caption, name = caption })
	local scroll_pane = panel.add({
		type = "scroll-pane",
		name = caption .. "tab",
		direction = "vertical",
		vertical_scroll_policy = "always",
		horizontal_scroll_policy = "never",
	})
	scroll_pane.style.maximal_height = 200
	scroll_pane.style.horizontally_stretchable = true
	scroll_pane.style.minimal_height = 200
	scroll_pane.style.right_padding = 0
	panel.add_tab(pane_name, scroll_pane)

	data.panel_type[caption] = panel_type

	redraw_inventory(scroll_pane, source, target, caption, panel_type)
end

local function open_inventory(source, target)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:194')
	if not validate_player(source) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:196')
		return
	end

	if not validate_player(target) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:200')
		return
	end

	local screen = source.gui.screen

	if not validate_object(screen) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:206')
		return
	end

	local inventory_gui = screen.inventory_gui
	if inventory_gui then
		close_player_inventory(source)
	end

	local frame = screen.add({
		type = "frame",
		caption = "Inventory",
		direction = "vertical",
		name = "inventory_gui",
	})

	if not validate_object(frame) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:222')
		return
	end

	frame.auto_center = true
	source.opened = frame
	frame.style.minimal_width = 500
	frame.style.minimal_height = 250

	adjustSpace(frame)

	local panel = frame.add({ type = "tabbed-pane", name = "tabbed_pane" })
	panel.selected_tab_index = 1

	local data = get_player_data(source)

	data.player_opened = target
	data.last_tab = "Main"

	local main = target.get_main_inventory().get_contents()
	local armor = target.get_inventory(defines.inventory.character_armor).get_contents()
	local guns = target.get_inventory(defines.inventory.character_guns).get_contents()
	local ammo = target.get_inventory(defines.inventory.character_ammo).get_contents()
	local trash = target.get_inventory(defines.inventory.character_trash).get_contents()

	local types = {
		["Main"] = main,
		["Armor"] = armor,
		["Guns"] = guns,
		["Ammo"] = ammo,
		["Trash"] = trash,
	}

	for k, v in pairs(types) do
		if v ~= nil then
			add_inventory(panel, source, target, k, v)
		end
	end
end

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:261')
	local player = game.players[event.player_index]

	local element = event.element

	if not element or not element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:267')
		return
	end

	local types = {
		["Main"] = true,
		["Armor"] = true,
		["Guns"] = true,
		["Ammo"] = true,
		["Trash"] = true,
	}

	local name = element.name

	if not types[name] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:281')
		return
	end

	local data = get_player_data(player)
	if not data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:286')
		return
	end

	data.last_tab = name

	local valid, target = player_opened(player)
	if valid then
		local main = target.get_main_inventory().get_contents()
		local armor = target.get_inventory(defines.inventory.character_armor).get_contents()
		local guns = target.get_inventory(defines.inventory.character_guns).get_contents()
		local ammo = target.get_inventory(defines.inventory.character_ammo).get_contents()
		local trash = target.get_inventory(defines.inventory.character_trash).get_contents()

		local target_types = {
			["Main"] = main,
			["Armor"] = armor,
			["Guns"] = guns,
			["Ammo"] = ammo,
			["Trash"] = trash,
		}
		local frame = Public.get_active_frame(player)
		local panel_type = target_types[name]

		redraw_inventory(frame, player, target, name, panel_type)
	end
end
local function gui_closed(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:312')
	local player = game.players[event.player_index]

	local type = event.gui_type

	if type == defines.gui_type.custom then
		local data = get_player_data(player)
		if not data then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:320')
			return
		end
		close_player_inventory(player)
	end
end

local function on_pre_player_left_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:326')
	local player = game.players[event.player_index]
	close_player_inventory(player)
end

local function update_gui()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:331')
	for _, player in pairs(game.connected_players) do
		local valid, target = player_opened(player)
		local success, tab = last_tab(player)

		if valid then
			if success then
				local main = target.get_main_inventory().get_contents()
				local armor = target.get_inventory(defines.inventory.character_armor).get_contents()
				local guns = target.get_inventory(defines.inventory.character_guns).get_contents()
				local ammo = target.get_inventory(defines.inventory.character_ammo).get_contents()
				local trash = target.get_inventory(defines.inventory.character_trash).get_contents()

				local types = {
					["Main"] = main,
					["Armor"] = armor,
					["Guns"] = guns,
					["Ammo"] = ammo,
					["Trash"] = trash,
				}

				local frame = Public.get_active_frame(player)
				local panel_type = types[tab]
				if frame then
					if frame.name == tab .. "tab" then
						redraw_inventory(frame, player, target, tab, panel_type)
					end
				end
			end
		else
			close_player_inventory(player)
		end
	end
end

commands.add_command("inventory", "Opens a players inventory!", function(cmd)
	local player = game.player

	if validate_player(player) then
		if not cmd.parameter then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:371')
			return
		end
		local target_player = game.players[cmd.parameter]

		if target_player == player then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:376')
			return player.print("Cannot open self.", Color.warning)
		end

		local valid, opened = player_opened(player)
		if valid then
			if target_player == opened then
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:382')
				return player.print("You are already viewing this players inventory.", Color.warning)
			end
		end

		if validate_player(target_player) then
			open_inventory(player, target_player)
		else
			player.print("Please type a name of a player who is connected.", Color.warning)
		end
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:392')
		return
	end
end)

function Public.get_active_frame(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:396')
	if not player.gui.screen.inventory_gui then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:398')
		return false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:400')
	return player.gui.screen.inventory_gui.tabbed_pane.tabs[player.gui.screen.inventory_gui.tabbed_pane.selected_tab_index].content
end

function Public.get(key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:403')
	if key then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:405')
		return this[key]
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:407')
		return this
	end
end

Event.add(defines.events.on_player_main_inventory_changed, update_gui)
Event.add(defines.events.on_gui_closed, gui_closed)
Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_pre_player_left_game, on_pre_player_left_game)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/show_inventory.lua:416')
return Public
