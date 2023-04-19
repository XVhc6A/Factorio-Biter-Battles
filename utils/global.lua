local Event = require("utils.event_core")
local Token = require("utils.token")

local Global = {}
local concat = table.concat

local names = {}
Global.names = names

function Global.register(tbl, callback)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/global.lua:9')
	if _LIFECYCLE ~= _STAGE.control then
		error("can only be called during the control stage", 2)
	end

	local filepath = debug.getinfo(2, "S").source:match("^.+/currently%-playing/(.+)$"):sub(1, -5)
	local token = Token.register_global(tbl)

	names[token] = concat({ token, " - ", filepath })

	Event.on_load(function()
		callback(Token.get_global(token))
	end)

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/global.lua:23')
	return token
end

function Global.register_init(tbl, init_handler, callback)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/global.lua:26')
	if _LIFECYCLE ~= _STAGE.control then
		error("can only be called during the control stage", 2)
	end
	local filepath = debug.getinfo(2, "S").source:match("^.+/currently%-playing/(.+)$"):sub(1, -5)
	local token = Token.register_global(tbl)

	names[token] = concat({ token, " - ", filepath })

	Event.on_init(function()
		init_handler(tbl)
		callback(tbl)
	end)

	Event.on_load(function()
		callback(Token.get_global(token))
	end)

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/global.lua:44')
	return token
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/global.lua:47')
return Global
