M = {}

function M.preinit ()
	if script.active_mods.testorio then
		require("__testorio__.init")({"tests/maps/biter_battles_v2/config"}) -- a list of test files (require paths)
		local mod_under_test = remote.call("testorio", "runTests")
	end
end

function M.starttests()
	if script.active_mods.testorio then
		require("__testorio__.init")({"tests/maps/biter_battles_v2/config"}) -- a list of test files (require paths)
		local mod_under_test = remote.call("testorio", "runTests")
	end
end

return M
