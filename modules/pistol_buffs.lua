local Event = require("utils.event")

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:2')
	if not event.cause then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:4')
		return
	end
	if not event.cause.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:7')
		return
	end
	if event.cause.name ~= "character" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:10')
		return
	end
	if event.damage_type.name ~= "physical" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:13')
		return
	end

	local player = event.cause
	if player.shooting_state.state == defines.shooting.not_shooting then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:18')
		return
	end
	local weapon = player.get_inventory(defines.inventory.character_guns)[player.selected_gun_index]
	local ammo = player.get_inventory(defines.inventory.character_ammo)[player.selected_gun_index]
	if not weapon.valid_for_read or not ammo.valid_for_read then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:23')
		return
	end
	if weapon.name ~= "pistol" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:26')
		return
	end
	if
		ammo.name ~= "firearm-magazine"
		and ammo.name ~= "piercing-rounds-magazine"
		and ammo.name ~= "uranium-rounds-magazine"
	then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:33')
		return
	end
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/pistol_buffs.lua:36')
		return
	end
	event.entity.damage(event.final_damage_amount * 3, player.force, "impact", player)
end

Event.add(defines.events.on_entity_damaged, on_entity_damaged)
