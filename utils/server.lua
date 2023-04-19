local Token = require("utils.token")
local Task = require("utils.task")
local Global = require("utils.global")
local Event = require("utils.event")
local Game = require("utils.game")
local Print = require("utils.print_override")

local serialize = serpent.serialize
local concat = table.concat
local remove = table.remove
local tostring = tostring
local raw_print = Print.raw_print

local serialize_options = { sparse = true, compact = true }

local Public = {}

local server_time = { secs = nil, tick = 0 }
local server_ups = { ups = 60 }
local requests = {}

Global.register({
	server_time = server_time,
	server_ups = server_ups,
	requests = requests,
}, function(tbl)
	server_time = tbl.server_time
	server_ups = tbl.server_ups
	requests = tbl.requests
end)

local discord_tag = "[DISCORD]"
local discord_raw_tag = "[DISCORD-RAW]"
local discord_bold_tag = "[DISCORD-BOLD]"
local discord_admin_tag = "[DISCORD-ADMIN]"
-- temporarily send bans to game-announcements
-- TODO: revert this quick workaround to a more perm solution
-- local discord_banned_tag = '[DISCORD-BANNED]'
-- local discord_banned_embed_tag = '[DISCORD-BANNED-EMBED]'
local discord_banned_tag = "[DISCORD-EMBED]"
local discord_banned_embed_tag = "[DISCORD-EMBED]"
local discord_admin_raw_tag = "[DISCORD-ADMIN-RAW]"
local discord_embed_tag = "[DISCORD-EMBED]"
local discord_embed_raw_tag = "[DISCORD-EMBED-RAW]"
local discord_admin_embed_tag = "[DISCORD-ADMIN-EMBED]"
local discord_admin_embed_raw_tag = "[DISCORD-ADMIN-EMBED-RAW]"
local start_scenario_tag = "[START-SCENARIO]"
local stop_scenario_tag = "[STOP-SCENARIO]"
local ping_tag = "[PING]"
local data_set_tag = "[DATA-SET]"
local data_get_tag = "[DATA-GET]"
local data_get_all_tag = "[DATA-GET-ALL]"
local data_tracked_tag = "[DATA-TRACKED]"
local ban_sync_tag = "[BAN-SYNC]"
local unbanned_sync_tag = "[UNBANNED-SYNC]"
local query_players_tag = "[QUERY-PLAYERS]"
local player_join_tag = "[PLAYER-JOIN]"
local player_chat_tag = "[PLAYER-CHAT]"
local player_leave_tag = "[PLAYER-LEAVE]"

Public.raw_print = raw_print

local data_set_handlers = {}

--- The event id for the on_server_started event.
-- The event is raised whenever the server goes from the starting state to the running state.
-- It provides a good opportunity to request data from the web server.
-- Note that if the server is stopped then started again, this event will be raised again.
-- @usage
-- local Server = require 'utils.server'
-- local Event = require 'utils.event'
--
-- Event.add(Server.events.on_server_started,
-- function()
--      Server.try_get_all_data('regulars', callback)
-- end)
Public.events = { on_server_started = Event.generate_event_name("on_server_started") }

--- Sends a message to the linked discord channel. The message is sanitized of markdown server side.
-- @param  message<string> message to send.
-- @usage
-- local Server = require 'utils.server'
-- Server.to_discord('Hello from scenario script!')
function Public.to_discord(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:83')
	raw_print(discord_tag .. message)
end

function Public.to_discord_player_chat(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:87')
	raw_print(player_chat_tag .. message)
end

--- Sends a message to the linked discord channel. The message is not sanitized of markdown.
-- @param  message<string> message to send.
function Public.to_discord_raw(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:93')
	raw_print(discord_raw_tag .. message)
end

--- Sends a message to the linked discord channel. The message is sanitized of markdown server side, then made bold.
-- @param  message<string> message to send.
function Public.to_discord_bold(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:99')
	raw_print(discord_bold_tag .. message)
end

--- Sends a message to the linked admin discord channel. The message is sanitized of markdown server side.
-- @param  message<string> message to send.
function Public.to_admin(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:105')
	raw_print(discord_admin_tag .. message)
end

--- Sends a message to the linked banned discord channel. The message is sanitized of markdown server side.
-- @param  message<string> message to send.
function Public.to_banned(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:111')
	raw_print(discord_banned_tag .. message)
end

--- Sends a message to the linked admin discord channel. The message is not sanitized of markdown.
-- @param  message<string> message to send.
function Public.to_admin_raw(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:117')
	raw_print(discord_admin_raw_tag .. message)
end

--- Sends a embed message to the linked discord channel. The message is sanitized of markdown server side.
-- @param  message<string> the content of the embed.
function Public.to_discord_embed(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:123')
	raw_print(discord_embed_tag .. message)
end

--- Sends a embed message to the linked discord channel. The message is not sanitized of markdown.
-- @param  message<string> the content of the embed.
function Public.to_discord_embed_raw(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:129')
	raw_print(discord_embed_raw_tag .. message)
end

--- Sends a embed message to the linked admin discord channel. The message is sanitized of markdown server side.
-- @param  message<string> the content of the embed.
function Public.to_admin_embed(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:135')
	raw_print(discord_admin_embed_tag .. message)
end

--- Sends a embed message to the linked banned discord channel. The message is sanitized of markdown server side.
-- @param  message<string> the content of the embed.
function Public.to_banned_embed(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:141')
	raw_print(discord_banned_embed_tag .. message)
end

--- Sends a embed message to the linked admin discord channel. The message is not sanitized of markdown.
-- @param  message<string> the content of the embed.
function Public.to_admin_embed_raw(message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:147')
	raw_print(discord_admin_embed_raw_tag .. message)
end

--- Stops and saves the factorio server and starts the named scenario.
-- @param  scenario_name<string> The name of the scenario as appears in the scenario table on the panel.
-- @usage
-- local Server = require 'utils.server'
-- Server.start_scenario('my_scenario_name')
function Public.start_scenario(scenario_name)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:156')
	if type(scenario_name) ~= "string" then
		game.print("start_scenario - scenario_name " .. tostring(scenario_name) .. " must be a string.")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:159')
		return
	end

	local message = start_scenario_tag .. scenario_name

	raw_print(message)
end

--- Stops and saves the factorio server.
-- @usage
-- local Server = require 'utils.server'
-- Server.stop_scenario()
function Public.stop_scenario()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:171')
	local message = stop_scenario_tag

	raw_print(message)
end

local default_ping_token = Token.register(function(sent_tick)
	local now = game.tick
	local diff = now - sent_tick

	local message = concat({ "Pong in ", diff, " tick(s) ", "sent tick: ", sent_tick, " received tick: ", now })
	game.print(message)
end)

--- Pings the web server.
-- @param  func_token<token> The function that is called when the web server replies.
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:186')
-- The function is passed the tick that the ping was sent.
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:187')
function Public.ping(func_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:188')
	local message = concat({ ping_tag, func_token or default_ping_token, " ", game.tick })
	raw_print(message)
end

local function double_escape(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:193')
	-- Excessive escaping because the data is serialized twice.
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:195')
	return str:gsub("\\", "\\\\\\\\"):gsub('"', '\\\\\\"'):gsub("\n", "\\\\n")
end

--- Sets the web server's persistent data storage. If you pass nil for the value removes the data.
-- Data set this will by synced in with other server if they choose to.
-- There can only be one key for each data_set.
-- @param  data_set<string>
-- @param  key<string>
-- @param  value<nil|boolean|number|string|table> Any type that is not a function. set to nil to remove the data.
-- @usage
-- local Server = require 'utils.server'
-- Server.set_data('my data set', 'key 1', 123)
-- Server.set_data('my data set', 'key 2', 'abc')
-- Server.set_data('my data set', 'key 3', {'some', 'data', ['is_set'] = true})
--
-- Server.set_data('my data set', 'key 1', nil) -- this will remove 'key 1'
-- Server.set_data('my data set', 'key 2', 'def') -- this will change the value for 'key 2' to 'def'
function Public.set_data(data_set, key, value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:212')
	if type(data_set) ~= "string" then
		error("data_set must be a string", 2)
	end
	if type(key) ~= "string" then
		error("key must be a string", 2)
	end

	data_set = double_escape(data_set)
	key = double_escape(key)

	local message
	local vt = type(value)
	if vt == "nil" then
		message = concat({ data_set_tag, '{data_set:"', data_set, '",key:"', key, '"}' })
	elseif vt == "string" then
		value = double_escape(value)

		message = concat({ data_set_tag, '{data_set:"', data_set, '",key:"', key, '",value:"\\"', value, '\\""}' })
	elseif vt == "number" then
		message = concat({ data_set_tag, '{data_set:"', data_set, '",key:"', key, '",value:"', value, '"}' })
	elseif vt == "boolean" then
		message = concat({ data_set_tag, '{data_set:"', data_set, '",key:"', key, '",value:"', tostring(value), '"}' })
	elseif vt == "function" then
		error("value cannot be a function", 2)
	else -- table
		value = serialize(value, serialize_options)

		-- Less escaping than the string case as serpent provides one level of escaping.
		-- Need to escape single quotes as serpent uses double quotes for strings.
		value = value:gsub("\\", "\\\\"):gsub("'", "\\'")

		message = concat({ data_set_tag, '{data_set:"', data_set, '",key:"', key, "\",value:'", value, "'}" })
	end

	raw_print(message)
end

local function validate_arguments(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:250')
	if type(data_set) ~= "string" then
		error("data_set must be a string", 3)
	end
	if type(key) ~= "string" then
		error("key must be a string", 3)
	end
	if type(callback_token) ~= "number" then
		error("callback_token must be a number", 3)
	end
end

local function send_try_get_data(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:262')
	data_set = double_escape(data_set)
	key = double_escape(key)

	local message = concat({ data_get_tag, callback_token, " {", 'data_set:"', data_set, '",key:"', key, '"}' })
	raw_print(message)
end

local cancelable_callback_token = Token.register(function(data)
	local data_set = data.data_set
	local keys = requests[data_set]
	if not keys then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:274')
		return
	end

	local key = data.key
	local callbacks = keys[key]
	if not callbacks then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:280')
		return
	end

	keys[key] = nil

	for c, _ in next, callbacks do
		local func = Token.get(c)
		func(data)
	end
end)

--- Gets data from the web server's persistent data storage.
-- The callback is passed a table {data_set: string, key: string, value: any}.
-- If the value is nil, it means there is no stored data for that data_set key pair.
-- @param  data_set<string>
-- @param  key<string>
-- @param  callback_token<token>
-- @usage
-- local Server = require 'utils.server'
-- local Token = require 'utils.token'
--
-- local callback =
--     Token.register(
--     function(data)
--         local data_set = data.data_set
--         local key = data.key
--         local value = data.value -- will be nil if no data
--
--         game.print(data_set .. ':' .. key .. ':' .. tostring(value))
--     end
-- )
--
-- Server.try_get_data('my data set', 'key 1', callback)
function Public.try_get_data(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:313')
	validate_arguments(data_set, key, callback_token)

	send_try_get_data(data_set, key, callback_token)
end

local function try_get_data_cancelable(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:319')
	local keys = requests[data_set]
	if not keys then
		keys = {}
		requests[data_set] = keys
	end

	local callbacks = keys[key]
	if not callbacks then
		callbacks = {}
		keys[key] = callbacks
	end

	if callbacks[callback_token] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:333')
		return
	end

	if next(callbacks) then
		callbacks[callback_token] = true
	else
		callbacks[callback_token] = true
		send_try_get_data(data_set, key, cancelable_callback_token)
	end
end

--- Same Server.try_get_data but the request can be cancelled by calling
-- Server.cancel_try_get_data(data_set, key, callback_token)
-- If the request is cancelled before it is complete the callback will be called with data.cancelled = true.
-- It is safe to cancel a non-existent or completed request, in either case the callback will not be called.
-- There can only be one request per data_set, key, callback_token combo. If there is already an ongoing request
-- an attempt to make a new one will be ignored.
-- @param  data_set<string>
-- @param  key<string>
-- @param  callback_token<token>
function Public.try_get_data_cancelable(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:353')
	validate_arguments(data_set, key, callback_token)

	try_get_data_cancelable(data_set, key, callback_token)
end

local function cancel_try_get_data(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:359')
	local keys = requests[data_set]
	if not keys then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:362')
		return false
	end

	local callbacks = keys[key]
	if not callbacks then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:367')
		return false
	end

	if callbacks[callback_token] then
		callbacks[callback_token] = nil

		local func = Token.get(callback_token)
		local data = { data_set = data_set, key = key, cancelled = true }
		func(data)

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:377')
		return true
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:379')
		return false
	end
end

--- Cancels the request. Returns false if the request could not be cnacled, either because there is no request
-- to cancel or it has been completed or cancled already. Otherwise returns true.
-- If the request is cancelled before it is complete the callback will be called with data.cancelled = true.
-- It is safe to cancel a non-existent or completed request, in either case the callback will not be called.
-- @param  data_set<string>
-- @param  key<string>
-- @param  callback_token<token>
function Public.cancel_try_get_data(data_set, key, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:390')
	validate_arguments(data_set, key, callback_token)

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:393')
	return cancel_try_get_data(data_set, key, callback_token)
end

local timeout_token = Token.register(function(data)
	cancel_try_get_data(data.data_set, data.key, data.callback_token)
end)

--- Same as Server.try_get_data but the request is cancelled if the timeout expires before the request is complete.
-- If the request is cancelled before it is complete the callback will be called with data.cancelled = true.
-- There can only be one request per data_set, key, callback_token combo. If there is already an ongoing request
-- an attempt to make a new one will be ignored.
-- @param  data_set<string>
-- @param  key<string>
-- @param  callback_token<token>
-- @usage
-- local Server = require 'utils.server'
-- local Token = require 'utils.token'
--
-- local callback =
--     Token.register(
--     function(data)
--         local data_set = data.data_set
--         local key = data.key
--
--          game.print('data_set: ' .. data_set .. ', key: ' .. key)
--
--         if data.cancelled then
--             game.print('Timed out')
--             return
--         end
--
--         local value = data.value -- will be nil if no data
--
--         game.print('value: ' .. tostring(value))
--     end
-- )
--
-- Server.try_get_data_timeout('my data set', 'key 1', callback, 60)
function Public.try_get_data_timeout(data_set, key, callback_token, timeout_ticks)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:431')
	validate_arguments(data_set, key, callback_token)

	try_get_data_cancelable(data_set, key, callback_token)

	Task.set_timeout_in_ticks(
		timeout_ticks,
		timeout_token,
		{ data_set = data_set, key = key, callback_token = callback_token }
	)
end

--- Gets all the data for the data_set from the web server's persistent data storage.
-- The callback is passed a table {data_set: string, entries: {dictionary key -> value}}.
-- If there is no data stored for the data_set entries will be nil.
-- @param  data_set<string>
-- @param  callback_token<token>
-- @usage
-- local Server = require 'utils.server'
-- local Token = require 'utils.token'
--
-- local callback =
--     Token.register(
--     function(data)
--         local data_set = data.data_set
--         local entries = data.entries -- will be nil if no data
--         local value2 = entries['key 2']
--         local value3 = entries['key 3']
--     end
-- )
--
-- Server.try_get_all_data('my data set', callback)
function Public.try_get_all_data(data_set, callback_token)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:463')
	if type(data_set) ~= "string" then
		error("data_set must be a string", 2)
	end
	if type(callback_token) ~= "number" then
		error("callback_token must be a number", 2)
	end

	data_set = double_escape(data_set)

	local message = concat({ data_get_all_tag, callback_token, " {", 'data_set:"', data_set, '"}' })
	raw_print(message)
end

local function data_set_changed(data)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:477')
	local handlers = data_set_handlers[data.data_set]
	if handlers == nil then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:480')
		return
	end

	if _DEBUG then
		for _, handler in ipairs(handlers) do
			local success, err = pcall(handler, data)
			if not success then
				log(err)
				error(err, 2)
			end
		end
	else
		for _, handler in ipairs(handlers) do
			local success, err = pcall(handler, data)
			if not success then
				log(err)
			end
		end
	end
end

--- Register a handler to be called when the data_set changes.
-- The handler is passed a table {data_set:string, key:string, value:any}
-- If value is nil that means the key was removed.
-- The handler may be called even if the value hasn't changed. It's up to the implementer
-- to determine if the value has changed, or not care.
-- To prevent desyncs the same handlers must be registered for all clients. The easiest way to do this
-- is in the control stage, i.e before on_init or on_load would be called.
-- @param  data_set<string>
-- @param  handler<function>
-- @usage
-- local Server = require 'utils.server'
-- Server.on_data_set_changed(
--     'my data set',
--     function(data)
--         local data_set = data.data_set
--         local key = data.key
--         local value = data.value -- will be nil if data was removed.
--     end
-- )
function Public.on_data_set_changed(data_set, handler)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:520')
	if _LIFECYCLE == _STAGE.runtime then
		error("cannot call during runtime", 2)
	end
	if type(data_set) ~= "string" then
		error("data_set must be a string", 2)
	end

	local handlers = data_set_handlers[data_set]
	if handlers == nil then
		handlers = { handler }
		data_set_handlers[data_set] = handlers
	else
		handlers[#handlers + 1] = handler
	end
end

--- Called by the web server to notify the client that a data_set has changed.
Public.raise_data_set = data_set_changed

--- Called by the web server to determine which data_sets are being tracked.
function Public.get_tracked_data_sets()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:541')
	local message = { data_tracked_tag, "[" }

	for k, _ in pairs(data_set_handlers) do
		k = double_escape(k)

		local message_length = #message
		message[message_length + 1] = '"'
		message[message_length + 2] = k
		message[message_length + 3] = '"'
		message[message_length + 4] = ","
	end

	if message[#message] == "," then
		remove(message)
	end

	message[#message + 1] = "]"

	message = concat(message)
	raw_print(message)
end

local function escape(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:564')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:565')
	return str:gsub("\\", "\\\\"):gsub('"', '\\"')
end

local statistics = {
	"item_production_statistics",
	"fluid_production_statistics",
	"kill_count_statistics",
	"entity_build_count_statistics",
}
function Public.export_stats()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:574')
	local table_to_json = game.table_to_json
	local stats = {
		game_tick = game.tick,
		player_count = #game.connected_players,
		game_flow_statistics = {
			pollution_statistics = {
				input = game.pollution_statistics.input_counts,
				output = game.pollution_statistics.output_counts,
			},
		},
		rockets_launched = {},
		force_flow_statistics = {},
	}
	for _, force in pairs(game.forces) do
		local flow_statistics = {}
		for _, statName in pairs(statistics) do
			flow_statistics[statName] = {
				input = force[statName].input_counts,
				output = force[statName].output_counts,
			}
		end
		stats.rockets_launched[force.name] = force.rockets_launched

		stats.force_flow_statistics[force.name] = flow_statistics
	end
	rcon.print(table_to_json(stats))
end

--- If the player exists bans the player.
-- Regardless of whether or not the player exists the name is synchronized with other servers
-- and stored in the database.
-- @param  username<string>
-- @param  reason<string?> defaults to empty string.
-- @param  admin<string?> admin's name, defaults to '<script>'
function Public.ban_sync(username, reason, admin)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:609')
	if type(username) ~= "string" then
		error("username must be a string", 2)
	end

	if reason == nil then
		reason = ""
	elseif type(reason) ~= "string" then
		error("reason must be a string or nil", 2)
	end

	if admin == nil then
		admin = "<script>"
	elseif type(admin) ~= "string" then
		error("admin must be a string or nil", 2)
	end

	-- game.ban_player errors if player not found.
	-- However we may still want to use this function to ban player names.
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:627')
	local player = game.players[username]
	if player then
		game.ban_player(player, reason)
	end

	username = escape(username)
	reason = escape(reason)
	admin = escape(admin)

	local message = concat({ ban_sync_tag, '{username:"', username, '",reason:"', reason, '",admin:"', admin, '"}' })
	raw_print(message)
end

--- If the player exists bans the player else throws error.
-- The ban is not synchronized with other servers or stored in the database.
-- @param  PlayerSpecification
-- @param  reason<string?> defaults to empty string.
function Public.ban_non_sync(PlayerSpecification, reason)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:645')
	game.ban_player(PlayerSpecification, reason)
end

--- If the player exists unbans the player.
-- Regardless of whether or not the player exists the name is synchronized with other servers
-- and removed from the database.
-- @param  username<string>
-- @param  admin<string?> admin's name, defaults to '<script>'. This name is stored in the logs for who removed the ban.
function Public.unban_sync(username, admin)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:654')
	if type(username) ~= "string" then
		error("username must be a string", 2)
	end

	if admin == nil then
		admin = "<script>"
	elseif type(admin) ~= "string" then
		error("admin must be a string or nil", 2)
	end

	-- game.unban_player errors if player not found.
	-- However we may still want to use this function to unban player names.
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:666')
	local player = game.players[username]
	if player then
		game.unban_player(username)
	end

	username = escape(username)
	admin = escape(admin)

	local message = concat({ unbanned_sync_tag, '{username:"', username, '",admin:"', admin, '"}' })
	raw_print(message)
end

--- If the player exists unbans the player else throws error.
-- The ban is not synchronized with other servers or removed from the database.
-- @param  PlayerSpecification
function Public.unban_non_sync(PlayerSpecification)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:682')
	game.unban_player(PlayerSpecification)
end

--- Called by the web server to set the server time.
-- @param  secs<number> unix epoch timestamp
function Public.set_time(secs)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:688')
	server_time.secs = secs
	server_time.tick = game.tick
end

--- Gets a table {secs:number?, tick:number} with secs being the unix epoch timestamp
-- for the server time and ticks the number of game ticks ago it was set.
-- @return table
function Public.get_time_data_raw()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:696')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:697')
	return server_time
end

-- have no wrapper
--- Called by the web server to set the ups value.
-- @param  tick<number> tick
--function Public.set_ups(tick)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:703')
--    server_ups.ups = tick
--end

--- Gets a the estimated UPS from the web panel that is sent to the server.
-- This is calculated and measured in the wrapper.
-- @return number
--function Public.get_ups()
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:710')
--    return server_ups.ups
--end

--- Gets an estimate of the current server time as a unix epoch timestamp.
-- If the server time has not been set returns nil.
-- The estimate may be slightly off if within the last minute the game has been paused, saving or overwise,
-- or the game speed has been changed.
-- @return number?
function Public.get_current_time()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:719')
	local secs = server_time.secs
	if secs == nil then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:722')
		return nil
	end

	local diff = game.tick - server_time.tick
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:726')
	return math.floor(secs + diff / game.speed / 60)
end

--- Called be the web server to re sync which players are online.
function Public.query_online_players()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:730')
	local message = { query_players_tag, "[" }

	for _, p in ipairs(game.connected_players) do
		message[#message + 1] = '"'
		local name = escape(p.name)
		message[#message + 1] = name
		message[#message + 1] = '",'
	end

	if message[#message] == '",' then
		message[#message] = '"'
	end

	message[#message + 1] = "]"

	message = concat(message)
	raw_print(message)
end

local function command_handler(callback, ...)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:750')
	if type(callback) == "function" then
		local success, err = pcall(callback, ...)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:753')
		return success, err
	else
		local success, err = pcall(loadstring(callback), ...)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:756')
		return success, err
	end
end

--- The command 'cc' is only used by the server so it can communicate through the webpanel api to the instances that it starts.
-- Doing this, enables achivements and the webpanel can communicate without any interruptions.
commands.add_command("cc", "Evaluate command", function(cmd)
	local player = game.player
	if player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:765')
		return
	end

	local callback = cmd.parameter
	if not callback then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:770')
		return
	end
	if not string.find(callback, "%s") and not string.find(callback, "return") then
		callback = "return " .. callback
	end
	local success, err = command_handler(callback)
	if not success and type(err) == "string" then
		local _end = string.find(err, "stack traceback")
		if _end then
			err = string.sub(err, 0, _end - 2)
		end
	end
	if err or err == false then
		raw_print(err)
	end
end)

--- The [JOIN] and [LEAVE] messages Factorio sends to stdout aren't sent in all cases of
--  players joining or leaving. So we send our own [PLAYER-JOIN] and [PLAYER-LEAVE] tags.
Event.add(defines.events.on_player_joined_game, function(event)
	local player = Game.get_player_by_index(event.player_index)
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:792')
		return
	end

	raw_print(player_join_tag .. player.name)
end)

Event.add(defines.events.on_player_left_game, function(event)
	local player = Game.get_player_by_index(event.player_index)
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:801')
		return
	end

	raw_print(player_leave_tag .. player.name)
end)

Event.add(defines.events.on_console_command, function(event)
	local cmd = event.command
	if not event.player_index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:810')
		return
	end
	local player = game.players[event.player_index]
	local reason = event.parameters
	if not reason then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:815')
		return
	end
	if not player.admin then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:818')
		return
	end
	if cmd == "ban" then
		if player then
			Public.to_banned_embed(table.concat({ player.name .. " banned " .. reason }))
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:823')
			return
		else
			Public.to_banned_embed(table.concat({ "Server banned " .. reason }))
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:826')
			return
		end
	elseif cmd == "unban" then
		if player then
			Public.to_banned_embed(table.concat({ player.name .. " unbanned " .. reason }))
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:831')
			return
		else
			Public.to_banned_embed(table.concat({ "Server unbanned " .. reason }))
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:834')
			return
		end
	end
end)

Event.add(defines.events.on_player_died, function(event)
	local player = game.get_player(event.player_index)

	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:843')
		return
	end

	local cause = event.cause

	local message = { discord_bold_tag, player.name }
	if cause and cause.valid then
		message[#message + 1] = " was killed by "

		local name = cause.name
		if name == "character" and cause.player then
			name = cause.player.name
		end

		message[#message + 1] = name
		message[#message + 1] = "."
	else
		message[#message + 1] = " has died."
	end

	message = concat(message)
	raw_print(message)
end)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/server.lua:867')
return Public
