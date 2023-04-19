local Token = require("utils.token")
local Event = require("utils.event")
local Global = require("utils.global")

local tostring = tostring
local next = next

local Gui = {}

local data = {}
local element_map = {}

Gui.token = Global.register({ data = data, element_map = element_map }, function(tbl)
	data = tbl.data
	element_map = tbl.element_map
end)

local top_elements = {}
local on_visible_handlers = {}
local on_pre_hidden_handlers = {}

function Gui.uid_name()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:21')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:22')
	return tostring(Token.uid())
end

function Gui.uid()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:25')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:26')
	return Token.uid()
end

-- Associates data with the LuaGuiElement. If data is nil then removes the data
function Gui.set_data(element, value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:30')
	local player_index = element.player_index
	local values = data[player_index]

	if value == nil then
		if not values then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:36')
			return
		end

		values[element.index] = nil

		if next(values) == nil then
			data[player_index] = nil
		end
	else
		if not values then
			values = {}
			data[player_index] = values
		end

		values[element.index] = value
	end
end
local set_data = Gui.set_data

-- Gets the Associated data with this LuaGuiElement if any.
function Gui.get_data(element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:56')
	local player_index = element.player_index

	local values = data[player_index]
	if not values then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:61')
		return nil
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:64')
	return values[element.index]
end

local remove_data_recursively
-- Removes data associated with LuaGuiElement and its children recursively.
function Gui.remove_data_recursively(element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:69')
	set_data(element, nil)

	local children = element.children

	if not children then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:75')
		return
	end

	for _, child in next, children do
		if child.valid then
			remove_data_recursively(child)
		end
	end
end
remove_data_recursively = Gui.remove_data_recursively

local remove_children_data
function Gui.remove_children_data(element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:87')
	local children = element.children

	if not children then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:91')
		return
	end

	for _, child in next, children do
		if child.valid then
			set_data(child, nil)
			remove_children_data(child)
		end
	end
end
remove_children_data = Gui.remove_children_data

function Gui.destroy(element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:103')
	remove_data_recursively(element)
	element.destroy()
end

function Gui.clear(element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:108')
	remove_children_data(element)
	element.clear()
end

local function clear_invalid_data()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:113')
	for _, player in pairs(game.connected_players) do
		local player_index = player.index
		local values = data[player_index]
		if values then
			for _, element in next, values do
				if type(element) == "table" then
					for key, obj in next, element do
						if type(obj) == "table" and obj.valid ~= nil then
							if not obj.valid then
								element[key] = nil
							end
						end
					end
				end
			end
		end
	end
end
Event.on_nth_tick(300, clear_invalid_data)

local function handler_factory(event_id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:134')
	local handlers

	local function on_event(event)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:137')
		local element = event.element
		if not element or not element.valid then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:140')
			return
		end

		local handler = handlers[element.name]
		if not handler then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:145')
			return
		end

		local player = game.get_player(event.player_index)
		if not player or not player.valid then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:150')
			return
		end
		event.player = player

		handler(event)
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:157')
	return function(element_name, handler)
		if not handlers then
			handlers = {}
			Event.add(event_id, on_event)
		end

		handlers[element_name] = handler
	end
end

local function custom_handler_factory(handlers)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:167')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:168')
	return function(element_name, handler)
		handlers[element_name] = handler
	end
end

local function custom_raise(handlers, element, player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:173')
	local handler = handlers[element.name]
	if not handler then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:176')
		return
	end

	handler({ element = element, player = player })
end

-- Register a handler for the on_gui_checked_state_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_checked_state_changed = handler_factory(defines.events.on_gui_checked_state_changed)

-- Register a handler for the on_gui_click event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_click = handler_factory(defines.events.on_gui_click)

-- Register a handler for the on_gui_closed event for a custom LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_custom_close = handler_factory(defines.events.on_gui_closed)

-- Register a handler for the on_gui_elem_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_elem_changed = handler_factory(defines.events.on_gui_elem_changed)

-- Register a handler for the on_gui_selection_state_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_selection_state_changed = handler_factory(defines.events.on_gui_selection_state_changed)

-- Register a handler for the on_gui_text_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_text_changed = handler_factory(defines.events.on_gui_text_changed)

-- Register a handler for the on_gui_value_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_value_changed = handler_factory(defines.events.on_gui_value_changed)

-- Register a handler for when the player shows the top LuaGuiElements with element_name.
-- Assuming the element_name has been added with Gui.allow_player_to_toggle_top_element_visibility.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_player_show_top = custom_handler_factory(on_visible_handlers)

-- Register a handler for when the player hides the top LuaGuiElements with element_name.
-- Assuming the element_name has been added with Gui.allow_player_to_toggle_top_element_visibility.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_pre_player_hide_top = custom_handler_factory(on_pre_hidden_handlers)

if _DEBUG then
	local concat = table.concat

	local names = {}
	Gui.names = names

	function Gui.uid_name()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:244')
		local info = debug.getinfo(2, "Sl")
		local filepath = info.source:match("^.+/currently%-playing/(.+)$"):sub(1, -5)
		local line = info.currentline

		local token = tostring(Token.uid())

		local name = concat({ token, " - ", filepath, ":line:", line })
		names[token] = name

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:254')
		return token
	end

	function Gui.set_data(element, value)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:257')
		local player_index = element.player_index
		local values = data[player_index]

		if value == nil then
			if not values then
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:263')
				return
			end

			local index = element.index
			values[index] = nil
			element_map[index] = nil

			if next(values) == nil then
				data[player_index] = nil
			end
		else
			if not values then
				values = {}
				data[player_index] = values
			end

			local index = element.index
			values[index] = value
			element_map[index] = element
		end
	end
	set_data = Gui.set_data

	function Gui.data()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:286')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:287')
		return data
	end

	function Gui.element_map()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:290')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:291')
		return element_map
	end
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/gui.lua:295')
return Gui
