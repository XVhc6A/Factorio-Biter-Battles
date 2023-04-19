local function on_chunk_generated(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/terrain_layouts/biters_and_resources_east.lua:0')
	if event.area.left_top.x > -256 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/terrain_layouts/biters_and_resources_east.lua:2')
		return
	end
	for _, e in
		pairs(
			event.surface.find_entities_filtered({ area = event.area, type = { "resource", "unit-spawner", "turret" } })
		)
	do
		e.destroy()
	end
end

local event = require("utils.event")
event.add(defines.events.on_chunk_generated, on_chunk_generated)
