local Public = {}

local locale_string = { "", "[PRINT] ", nil }

function print(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/print_override.lua:4')
	locale_string[3] = str
	log(locale_string)
end

local raw_print = print
Public.raw_print = raw_print

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/print_override.lua:12')
return Public
