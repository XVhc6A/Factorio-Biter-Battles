-- rocket launch always yields space science -- by mewmew

local event = require("utils.event")

local function on_rocket_launched(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocket_launch_always_yields_science.lua:4')
	local rocket_inventory = event.rocket.get_inventory(defines.inventory.rocket)
	if rocket_inventory.get_item_count("satellite") > 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocket_launch_always_yields_science.lua:7')
		return
	end
	local rocket_silo_inventory = event.rocket_silo.get_inventory(defines.inventory.rocket_silo_result)
	rocket_silo_inventory.insert({ name = "space-science-pack", count = 1000 })
end

event.add(defines.events.on_rocket_launched, on_rocket_launched)
