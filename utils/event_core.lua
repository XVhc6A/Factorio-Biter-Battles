-- This module exists to break the circular dependency between event.lua and global.lua.
-- It is not expected that any user code would require this module instead event.lua should be required.

local Public = {}

local init_event_name = -1
local load_event_name = -2

-- map of event_name to handlers[]
local event_handlers = {}
-- map of nth_tick to handlers[]
local on_nth_tick_event_handlers = {}

--[[ local interface = {
    get_handler = function()
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:14')
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:15')
        return event_handlers
    end
}

if not remote.interfaces['interface'] then
    remote.add_interface('interface', interface)
end ]]
local pcall = pcall
local log = log
local script_on_event = script.on_event
local script_on_nth_tick = script.on_nth_tick

local call_handlers
if _DEBUG then
	function call_handlers(handlers, event)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:29')
		if not handlers then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:31')
			return log("Handlers was nil!")
		end
		for i = 1, #handlers do
			local handler = handlers[i]
			handler(event)
		end
	end
else
	function call_handlers(handlers, event)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:39')
		if not handlers then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:41')
			return log("Handlers was nil!")
		end
		for i = 1, #handlers do
			local handler = handlers[i]
			local success, error = pcall(handler, event)
			if not success then
				log(error)
			end
		end
	end
end

local function on_event(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:53')
	local handlers = event_handlers[event.name]
	if not handlers then
		handlers = event_handlers[event.input_name]
	end
	call_handlers(handlers, event)
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:61')
	_LIFECYCLE = 5 -- on_init
	local handlers = event_handlers[init_event_name]
	call_handlers(handlers)

	event_handlers[init_event_name] = nil
	event_handlers[load_event_name] = nil

	_LIFECYCLE = 8 -- Runtime
end

local function on_load()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:72')
	_LIFECYCLE = 6 -- on_load
	local handlers = event_handlers[load_event_name]
	call_handlers(handlers)

	event_handlers[init_event_name] = nil
	event_handlers[load_event_name] = nil

	_LIFECYCLE = 8 -- Runtime
end

local function on_nth_tick_event(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:83')
	local handlers = on_nth_tick_event_handlers[event.nth_tick]
	call_handlers(handlers, event)
end

--- Do not use this function, use Event.add instead as it has safety checks.
function Public.add(event_name, handler)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:89')
	local handlers = event_handlers[event_name]
	if not handlers then
		event_handlers[event_name] = { handler }
		script_on_event(event_name, on_event)
	else
		table.insert(handlers, handler)
		if #handlers == 1 then
			script_on_event(event_name, on_event)
		end
	end
end

--- Do not use this function, use Event.on_init instead as it has safety checks.
function Public.on_init(handler)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:103')
	local handlers = event_handlers[init_event_name]
	if not handlers then
		event_handlers[init_event_name] = { handler }
		script.on_init(on_init)
	else
		table.insert(handlers, handler)
		if #handlers == 1 then
			script.on_init(on_init)
		end
	end
end

--- Do not use this function, use Event.on_load instead as it has safety checks.
function Public.on_load(handler)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:117')
	local handlers = event_handlers[load_event_name]
	if not handlers then
		event_handlers[load_event_name] = { handler }
		script.on_load(on_load)
	else
		table.insert(handlers, handler)
		if #handlers == 1 then
			script.on_load(on_load)
		end
	end
end

--- Do not use this function, use Event.on_nth_tick instead as it has safety checks.
function Public.on_nth_tick(tick, handler)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:131')
	local handlers = on_nth_tick_event_handlers[tick]
	if not handlers then
		on_nth_tick_event_handlers[tick] = { handler }
		script_on_nth_tick(tick, on_nth_tick_event)
	else
		table.insert(handlers, handler)
		if #handlers == 1 then
			script_on_nth_tick(tick, on_nth_tick_event)
		end
	end
end

function Public.get_event_handlers()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:144')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:145')
	return event_handlers
end

function Public.get_on_nth_tick_event_handlers()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:148')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:149')
	return on_nth_tick_event_handlers
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/event_core.lua:152')
return Public
