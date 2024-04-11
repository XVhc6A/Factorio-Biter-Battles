local AntiGrief = require "antigrief"

local Public = {}

---@class HistoryFilterOptionDefinition
---@field above_title string
---@field gui_definition table<string, any>
---@field post_define function(lge=LuaGuiElement)

---@class HistoryFilterOptionGuiElements
---@field history LuaGuiElement
---@field search_player LuaGuiElement
---@field search_event LuaGuiElement
---@field filter_by_gps LuaGuiElement
---@field clear_gps LuaGuiElement


local histories_dict = {
	[1] = { history = "mining", name = "Mining History" },
	[2] = { history = "belt_mining", name = "Belt Mining History" },
	[3] = { history = "capsule", name = "Capsule History" },
	[4] = { history = "friendly_fire", name = "Friendly Fire History" },
	[5] = { history = "landfill", name = "Landfill History" },
	[6] = { history = "corpse", name = "Corpse Looting History" },
	[7] = { history = "cancel_crafting", name = "Cancel Crafting History" }
}

---@param parent LuaGuiElement
---@param prefix string
---@return HistoryFilterOptionGuiElements
local function create_histories_user_input_bar(parent, prefix)
	local history_filter_gui_elements = {}

	---@type HistoryFilterOptionDefinition[]
	local history_filter_options = {
		{
			above_title = "Choose history",
			gui_definition = {
				type = "drop-down",
				name = prefix .. "history_select",
				items = (function ()
					local ret = {}
					for _, v in pairs(histories_dict) do
						table.insert(ret, v.name)
					end
					return ret
				end)(),
				selected_index = 1,
			},
			post_define = function (lge)
				history_filter_gui_elements["history"] = lge
			end,
		},
		{
			above_title = "Search player",
			gui_definition = {
				type = "textfield",
				name = prefix .. "player_search_text"
			},
			post_define = function (lge)
				lge.style.width = 180
				history_filter_gui_elements["search_player"] = lge
			end
		},
		{
			above_title = "Search event",
			gui_definition = {
				type = "textfield",
				name = prefix .. "event_search_text"
			},
			post_define = function (lge)
				lge.style.width = 180
				history_filter_gui_elements["search_event"] = lge
			end
		},
		{
			above_title = "Search by gps",
			gui_definition = {
				type = "flow",
				direction = "horizontal",
				name = prefix .. "gps"
			},
			post_define = function (lge)
				local filter_by_gps = lge.add({
					type = "button",
					name = prefix .. "filter_by_gps",
					caption = "Filter by GPS",
					tooltip =
					"Click this button and then ping on map to filter history"
				})
				history_filter_gui_elements["filter_by_gps"] = filter_by_gps
				local clear_gps = lge.add({ type = "button", name = prefix .. "clear_gps", caption = "Clear GPS" })
				history_filter_gui_elements["clear_gps"] = clear_gps
			end
		}
	}
	local user_input_bar = parent.add({ type = "table", name = "history_headers", column_count = #history_filter_options })

	for _, v in pairs(history_filter_options) do
		user_input_bar.add({ type = "label", caption = v.above_title })
	end
	for _, v in pairs(history_filter_options) do
		local lge = user_input_bar.add(v.gui_definition)
		v.post_define(lge)
	end
	return history_filter_gui_elements
end


--Headers captions
local history_headers = {
	[1] = "Time",
	[2] = "Player name",
	[3] = "Event",
	[4] = "Location"
}
local symbol_asc = "▲"
local symbol_desc = "▼"
local header_modifier = {
	["time_asc"] = function (h) h[1] = symbol_asc .. h[1] end,
	["time_desc"] = function (h) h[1] = symbol_desc .. h[1] end,
	["name_asc"] = function (h) h[2] = symbol_asc .. h[2] end,
	["name_desc"] = function (h) h[2] = symbol_desc .. h[2] end,
	["event_asc"] = function (h) h[3] = symbol_asc .. h[3] end,
	["event_desc"] = function (h) h[3] = symbol_desc .. h[3] end
}

---@param parent LuaGuiElement
---@param sort_by string
---@return LuaGuiElement
local function create_histories_table_from_scratch(parent, sort_by)
	local radius = 10
	local histories = AntiGrief.get("histories")
	local antigrief_histories = histories[histories_dict[1].history]
	header_modifier[sort_by](history_headers)

	--Headers
	local column_widths = { 80, 200, 300, 100 }
	for k, v in pairs(history_headers) do
		local h = parent.history_headers.add { type = "label", caption = v, name = v }
		h.style.width = column_widths[k]
		h.style.font = "default-bold"
		h.style.font_color = { r = 0.98, g = 0.66, b = 0.22 }
	end

	--Scroll panel
	if not parent.history_scroll then
		parent.add { type = "scroll-pane", name = "history_scroll", direction = "vertical", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto" }.style.height = 330
	end

	--History table in panel
	if parent.history_scroll.history_table then
		parent.history_scroll.history_table.clear()
	else
		parent.history_scroll.add { type = "table", name = "history_table", column_count = #history_headers }
	end

	local temp = {}
	if not antigrief_histories then return end
	-- filtering the history
	for k, v in pairs(antigrief_histories) do
		if v ~= 0 then
			if gps_position and distance(gps_position, v.position) > radius then
				goto CONTINUE
			end
			if player_name_search and not contains_text(v.player_name, nil, player_name_search) then
				goto CONTINUE
			end
			if event_search and not contains_text(v.event, nil, event_search) then
				goto CONTINUE
			end
			table.insert(temp, v)
		end
		::CONTINUE::
	end
	table.sort(temp, comparators[sort_by])

	for k, v in pairs(temp) do
		local hours = math.floor(v.time / 216000)
		local minutes = math.floor((v.time - hours * 216000) / 3600)
		local formatted_time = hours .. ":" .. minutes
		frame.history_scroll.history_table.add { type = "label", caption = formatted_time }.style.width = column_widths
			[1]
		frame.history_scroll.history_table.add { type = "label", caption = v.player_name }.style.width = column_widths
			[2]
		frame.history_scroll.history_table.add { type = "label", caption = v.event }.style.width = column_widths[3]
		frame.history_scroll.history_table.add { type = "label", name = "coords_" .. k, caption = v.position.x .. " , " .. v.position.y }.style.width =
			column_widths[4]
	end
end

---@param parent LuaGuiElement
---@param handlers table<defines.events, table<string, function>>
---@param prefix string
---@param history_filter_gui_elements HistoryFilterOptionGuiElements
---@return LuaGuiElement
local function handle_filter_by_gps_click(parent, handlers, prefix, history_filter_gui_elements)
	local filter_by_gps_click_name =  prefix .."_filter_by_gps_click"
	handlers[defines.events.on_gui_click][ filter_by_gps_click_name] = function ()
	end
end

---@param parent LuaGuiElement
---@param handlers table<defines.events, table<string, function>>
---@param prefix string
---@param history_filter_gui_elements HistoryFilterOptionGuiElements
---@return LuaGuiElement
local function create_histories_table_handlers(parent, handlers, prefix, history_filter_gui_elements)
	if parent.history_headers then
		parent.history_headers.clear()
	end


	local histories_table = parent.add({ type = "table", name = "history_headers", column_count = #history_headers })
	create_histories_table_from_scratch(histories_table, "time_desc")
end

---@param tabbed_pane LuaGuiElement
---@param handlers table<defines.events, table<string, function>>
---@param prefix string
function Public.add_to_tabbed_pane(tabbed_pane, prefix, handlers)
	local parent_frame = tabbed_pane.add({
		type = "frame"
	})
	local history_filter_gui_elements = create_histories_user_input_bar(parent_frame, prefix)
	local history_table = create_histories_table_handlers(parent_frame, handlers, prefix, history_filter_gui_elements)
	local tab = tabbed_pane.add({ type = "tab", caption = "Histories" })
	tabbed_pane.add_tab(tab, parent_frame)
end

return Public
