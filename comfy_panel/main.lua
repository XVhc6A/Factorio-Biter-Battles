--[[
Comfy Panel

To add a tab, insert into the "comfy_panel_tabs" table.

Example: comfy_panel_tabs["mapscores"] = {gui = draw_map_scores, admin = false}
if admin = true, then tab is visible only for admins (usable for map-specific settings)

draw_map_scores would be a function with the player and the frame as arguments
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:8')

]]
local event = require("utils.event")
require("utils.gui_styles")
comfy_panel_tabs = {}

local Public = {}

function Public.get_tabs(data)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:17')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:18')
	return comfy_panel_tabs
end

function Public.comfy_panel_clear_left_gui(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:21')
	for _, child in pairs(player.gui.left.children) do
		child.visible = false
	end
end

function Public.comfy_panel_restore_left_gui(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:27')
	for _, child in pairs(player.gui.left.children) do
		child.visible = true
	end
end

function Public.comfy_panel_clear_screen_gui(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:33')
	for _, child in pairs(player.gui.screen.children) do
		child.destroy()
	end
end

function Public.comfy_panel_restore_screen_gui(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:39')
	for _, child in pairs(player.gui.screen.children) do
		child.visible = true
	end
end

function Public.comfy_panel_get_active_frame(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:45')
	if not player.gui.left.comfy_panel then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:47')
		return false
	end
	if not player.gui.left.comfy_panel.tabbed_pane.selected_tab_index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:50')
		return player.gui.left.comfy_panel.tabbed_pane.tabs[1].content
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:52')
	return player.gui.left.comfy_panel.tabbed_pane.tabs[player.gui.left.comfy_panel.tabbed_pane.selected_tab_index].content
end

function Public.comfy_panel_refresh_active_tab(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:55')
	local frame = Public.comfy_panel_get_active_frame(player)
	if not frame then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:58')
		return
	end
	comfy_panel_tabs[frame.name].gui(player, frame)
end

local function top_button(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:63')
	if player.gui.top["comfy_panel_top_button"] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:65')
		return
	end
	local button =
		player.gui.top.add({ type = "sprite-button", name = "comfy_panel_top_button", sprite = "item/raw-fish" })
	element_style({ element = button, x = 38, y = 38, pad = -2 })
end

local function main_frame(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:72')
	local tabs = comfy_panel_tabs
	Public.comfy_panel_clear_left_gui(player)

	local frame = player.gui.left.add({ type = "frame", name = "comfy_panel" })
	frame.style.margin = 6

	local tabbed_pane = frame.add({ type = "tabbed-pane", name = "tabbed_pane" })

	for name, func in pairs(tabs) do
		if func.admin == true then
			if player.admin then
				local tab = tabbed_pane.add({ type = "tab", caption = name })
				local frame = tabbed_pane.add({ type = "frame", name = name, direction = "vertical" })
				frame.style.minimal_height = 480
				frame.style.maximal_height = 480
				frame.style.minimal_width = 800
				frame.style.maximal_width = 800
				tabbed_pane.add_tab(tab, frame)
			end
		else
			local tab = tabbed_pane.add({ type = "tab", caption = name })
			local frame = tabbed_pane.add({ type = "frame", name = name, direction = "vertical" })
			frame.style.minimal_height = 480
			frame.style.maximal_height = 480
			frame.style.minimal_width = 800
			frame.style.maximal_width = 800
			tabbed_pane.add_tab(tab, frame)
		end
	end

	local tab = tabbed_pane.add({ type = "tab", name = "comfy_panel_close", caption = "X" })
	tab.style.maximal_width = 32
	local frame = tabbed_pane.add({ type = "frame", name = name, direction = "vertical" })
	tabbed_pane.add_tab(tab, frame)

	for _, child in pairs(tabbed_pane.children) do
		child.style.padding = 8
		child.style.left_padding = 2
		child.style.right_padding = 2
	end

	Public.comfy_panel_refresh_active_tab(player)
end

function Public.comfy_panel_call_tab(player, name)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:117')
	main_frame(player)
	local tabbed_pane = player.gui.left.comfy_panel.tabbed_pane
	for key, v in pairs(tabbed_pane.tabs) do
		if v.tab.caption == name then
			tabbed_pane.selected_tab_index = key
			Public.comfy_panel_refresh_active_tab(player)
		end
	end
end

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:128')
	top_button(game.players[event.player_index])
end

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:132')
	if not event.element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:134')
		return
	end
	if not event.element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:137')
		return
	end
	local player = game.players[event.player_index]

	if event.element.name == "comfy_panel_top_button" then
		if player.gui.left.comfy_panel then
			player.gui.left.comfy_panel.destroy()
			Public.comfy_panel_restore_left_gui(player)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:145')
			return
		else
			Public.comfy_panel_clear_screen_gui(player)
			main_frame(player)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:149')
			return
		end
	end

	if event.element.caption == "X" and event.element.name == "comfy_panel_close" then
		player.gui.left.comfy_panel.destroy()
		Public.comfy_panel_restore_left_gui(player)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:156')
		return
	end

	if not event.element.caption then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:160')
		return
	end
	if event.element.type ~= "tab" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:163')
		return
	end
	Public.comfy_panel_refresh_active_tab(player)
end

event.add(defines.events.on_player_joined_game, on_player_joined_game)
event.add(defines.events.on_gui_click, on_gui_click)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/comfy_panel/main.lua:171')
return Public
