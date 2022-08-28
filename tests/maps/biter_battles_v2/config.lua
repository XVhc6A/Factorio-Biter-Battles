local bb_config = require "maps.biter_battles_v2.config"

test("check config", function()
	print("checking config???")
    assert.not_equal(bb_config.bitera_area_distance, 55)
    assert.are_equal(bb_config.bitera_area_distance, 512)
    assert.are_equal(game.surfaces[1].name, "bb0")
	print("end checking config???")
end)

