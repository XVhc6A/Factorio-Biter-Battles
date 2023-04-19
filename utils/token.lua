local Token = {}

local tokens = {}

local counter = 0

--- Assigns a unquie id for the given var.
-- This function cannot be called after on_init() or on_load() has run as that is a desync risk.
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:7')
-- Typically this is used to register functions, so the id can be stored in the global table
-- instead of the function. This is becasue closures cannot be safely stored in the global table.
-- @param  var<any>
-- @return number the unique token for the variable.
function Token.register(var)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:12')
	if _LIFECYCLE == 8 then
		error("Calling Token.register after on_init() or on_load() has run is a desync risk.", 2)
	end

	counter = counter + 1

	tokens[counter] = var

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:21')
	return counter
end

function Token.get(token_id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:24')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:25')
	return tokens[token_id]
end

global.tokens = {}

function Token.register_global(var)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:30')
	local c = #global.tokens + 1

	global.tokens[c] = var

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:35')
	return c
end

function Token.get_global(token_id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:38')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:39')
	return global.tokens[token_id]
end

function Token.set_global(token_id, var)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:42')
	global.tokens[token_id] = var
end

local uid_counter = 100

function Token.uid()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:48')
	uid_counter = uid_counter + 1

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:51')
	return uid_counter
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/token.lua:54')
return Token
