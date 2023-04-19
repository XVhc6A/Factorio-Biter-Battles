--biters make comic like text sounds when they damage something -- mewmew

local event = require("utils.event")
local math_random = math.random

local strings = {
	"delicious!",
	"yum",
	"yum",
	"crunch",
	"crunch",
	"chomp",
	"chomp",
	"chow",
	"chow",
	"nibble",
	"nibble",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
	"nom",
}
local size_of_strings = #strings

local whitelist = {
	["small-biter"] = true,
	["medium-biter"] = true,
	["big-biter"] = true,
	["behemoth-biter"] = true,
}

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_noms_you.lua:49')
	if not event.cause then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_noms_you.lua:51')
		return
	end
	if not event.cause.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_noms_you.lua:54')
		return
	end
	if not whitelist[event.cause.name] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_noms_you.lua:57')
		return
	end
	if math_random(1, 5) == 1 then
		event.cause.surface.create_entity({
			name = "flying-text",
			position = event.cause.position,
			text = strings[math_random(1, size_of_strings)],
			color = { r = math_random(130, 170), g = math_random(130, 170), b = 130 },
		})
	end
end

event.add(defines.events.on_entity_damaged, on_entity_damaged)
