local ComboPanel = require("maps.biter_battles_v2.guiv2.combo_panel.main")
-- local ComboPanel = require("maps.biter_battles_v2.guiv2.combo_panel.main")

local Public = {}

---@type table<defines.events, table<string, function>>
local gui_element_event_handlers = {
	[defines.events.on_gui_leave] = {},
	[defines.events.on_gui_selection_state_changed] = {},
	[defines.events.on_gui_hover] = {},
	[defines.events.on_gui_click] = {},
	[defines.events.on_gui_closed] = {},
	[defines.events.on_gui_opened] = {},
	[defines.events.on_gui_confirmed] = {},
	[defines.events.on_gui_elem_changed] = {},
	[defines.events.on_gui_text_changed] = {},
	[defines.events.on_gui_value_changed] = {},
	[defines.events.on_gui_location_changed] = {},
	[defines.events.on_gui_selected_tab_changed] = {},
	[defines.events.on_gui_switch_state_changed] = {},
	[defines.events.on_gui_checked_state_changed] = {},
}

---@class Guiv2ElementPair
---@field tab LuaGuiElement
---@field frame LuaGuiElement

---@param event_type defines.events
---@param lge_name string
---@return boolean
function Public.handle_event(event_type, lge_name)
	---TODO this should be globals per player maybe?
	local handler = gui_element_event_handlers[event_type[lge_name]
	if handler then
		handler()
		return true
	end
	return false
end

---@param parent_lge LuaGuiElement
function Public.create_master_gui(parent_lge)
	local vertical_flow = parent_lge.add({
		type = "flow",
		direction = "vertical"
	})
	local tab_flow = vertical_flow.add({
		type = "flow",
		direction = "vertical"
	})
	tab_flow.style.height = 48
	local frame_flow = vertical_flow.add({
		type = "flow",
		direction = "vertical"
	})
	local master_prefix = "bbv2_guiv2"
	---@type Guiv2ElementPair[]
	local tabs_and_frames = {
		ComboPanel.add_tab_frame_and_handlers(
			tab_flow,
			frame_flow,
			master_prefix .. "_combo_panel",
			gui_element_event_handlers
		),
	}

	for _, taf in pairs(tabs_and_frames) do
		taf.tab.toggled = false
		taf.frame.visible = false
		gui_element_event_handlers[taf.tab.name] = function ()
			taf.tab.toggled = not taf.tab.toggled
			if taf.tab.toggled then
				taf.frame.visible = true
				for _, taf_ in pairs(tabs_and_frames) do
					if taf_.tab.name ~= taf.tab.name then
						taf_.frame.visible = false
						taf_.tab.toggled = false
					end
				end
			else
				taf.frame.visible = false
			end
		end
	end




	-- local tabbed_pane = parent_lge.add({ type = "tabbed-pane", name = "tabbed_pane" })
	-- --tabbed_pane.style.margin = 8
	--
	-- local f1 = tabbed_pane.add({ type = "flow" })
	-- local t1 = tabbed_pane.add({
	-- 	type = "tab",
	-- })
	-- t1.style.margin = 0
	-- t1.style.padding = 0
	-- t1.style.minimal_width = 64
	-- t1.style.minimal_height = 64
	-- local sprite = t1.add({
	-- 	type = "sprite",
	-- 	sprite = "item/iron-plate",
	-- })
	--
	-- sprite.style.height = 64
	-- sprite.style.width = 64
	-- sprite.style.stretch_image_to_widget_size = true
	--
	-- --t1.sprite = "item/copper-plate"
	-- tabbed_pane.add_tab(t1, f1)
	-- -- tabbed_pane.
	--
	-- local f2 = tabbed_pane.add({ type = "flow" })
	-- local t2 = tabbed_pane.add({
	-- 	type = "tab",
	-- })
	-- t2.style.margin = 0
	-- t2.style.padding = 0
	-- t2.style.minimal_width = 64
	-- t2.style.minimal_height = 64
	--
	-- local subflow = t2.add({
	-- 	type = "flow",
	-- })
	--
	-- local sprite2 = subflow.add({
	-- 	type = "label",
	-- 	caption = "XY",
	-- })
	-- -- 	type = "sprite",
	-- -- 	sprite = "item/wood",
	-- -- })
	-- sprite2.style.horizontal_align = "center"
	-- sprite2.style.vertical_align = "center"
	-- subflow.style.padding = 0
	-- subflow.style.horizontal_align = "right"
	-- subflow.style.vertical_align = "center"
	-- subflow.style.horizontally_stretchable = true
	-- subflow.style.vertically_stretchable = true
	--
	-- t2.style.padding = 0
	-- t2.style.horizontal_align = "right"
	-- t2.style.vertical_align = "center"
	-- t2.style.horizontally_stretchable = true
	-- t2.style.minimal_width = 200
	-- t2.style.vertically_stretchable = true
	-- t2.style.horizontal_align = "center"
	-- t2.style.vertical_align = "center"

	-- sprite.style.height = 32
	-- sprite.style.width = 32
	-- sprite.style.stretch_image_to_widget_size = true

	--t1.sprite = "item/copper-plate"

	--	local titlebar_flow = frame.add({
	--		type = "flow",
	--	})
	--	titlebar_flow.drag_target = frame
	--	titlebar_flow.style.horizontally_stretchable = true
	--	titlebar_flow.style.horizontal_spacing = 8
	--
	--	local titlebar_label = titlebar_flow.add({
	--		type = "label",
	--		style = "frame_title",
	--		caption = "Draggable frame",
	--		ignored_by_interaction = true,
	--	})
	--	titlebar_label.drag_target = frame
	--	local titlebar_dragger = titlebar_flow.add({
	--		type = "empty-widget",
	--		style = "draggable_space_header",
	--		ignored_by_interaction=true,
	--	})
	--	titlebar_dragger.style.horizontally_stretchable = true
	--	titlebar_dragger.style.height = 24
	--	titlebar_dragger.style.right_margin = 4
	--
	--    -- frame.style.margin = 6
	--	---@param frame_in LuaGuiElement
	--	local function set_frame_style (frame_in)
	--		frame_in.style.minimal_height = 480
	--		frame_in.style.maximal_height = 480
	--		frame_in.style.minimal_width = 800
	--		frame_in.style.maximal_width = 800
	--	end
	-- local tabbed_pane = frame.add({ type = "tabbed-pane", name = "tabbed_pane" })
	--	local close_button = titlebar_flow.add({
	--		type = "sprite-button",
	--		name = "skldafjlkajfdl",
	--		style = "frame_action_button",
	--		sprite = "utility/close_white",
	--		hovered_sprite = "utility/close_black",
	--		clicked_sprite = "utility/close_black",
	--	})
	--	local close_handler = function ()
	--		tabbed_pane.visible = not tabbed_pane.visible
	--	end
	--	Public.add_element("skldafjlkajfdl", close_handler)
end

return Public
