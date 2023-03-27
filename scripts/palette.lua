modApi:addPalette({
		ID = "truelch_DieselPunk",
		Name = "Diesel Punk",
		Image = "img/units/player/gunship_ns.png",
		PlateHighlight = { 220, 250, 200 },	--lights
		PlateLight     = { 128, 100,  97 },	--main highlight
		PlateMid       = {  81,  54,  47 },	--main light
		PlateDark      = {  40,  25,  25 },	--main mid
		PlateOutline   = {  38,  31,  35 },	--main dark
		PlateShadow    = {  34,  38,  37 },	--metal dark
		BodyColor      = {  47,  51,  48 },	--metal mid
		BodyHighlight  = { 119, 141, 145 },	--metal light
})
modApi:getPaletteImageOffset("truelch_DieselPunk")

--[[
local mod = modApi:getCurrentMod()
local palette = {
	id = mod.id,
	name = "Diesel Punk", 
	image = "img/units/player/gunship_ns.png",
	colorMap = {
		lights =         { 220, 250, 200 }, --PlateHighlight
		main_highlight = { 128, 100,  97 }, --PlateLight
		main_light =     {  81,  54,  47 }, --PlateMid
		main_mid =       {  40,  25,  25 }, --PlateDark
		main_dark =      {  38,  31,  35 }, --PlateOutline
		metal_light =    { 119, 141, 145 }, --BodyHighlight
		metal_mid =      {  66,  81,  77 }, --BodyColor
		metal_dark =     {  34,  38,  37 }, --PlateShadow
	},
}
modApi:addPalette(palette)
]]

--Lighter Diesel Punk
--[[
	colorMap = {
		lights =         { 220, 250, 200 }, --PlateHighlight
		main_highlight = { 145, 126, 122 }, --PlateLight
		main_light =     { 105,  70,  60 }, --PlateMid
		main_mid =       {  65,  30,  30 }, --PlateDark
		main_dark =      {  38,  31,  35 }, --PlateOutline
		metal_light =    { 119, 141, 145 }, --BodyHighlight
		metal_mid =      {  66,  81,  77 }, --BodyColor
		metal_dark =     {  34,  38,  37 }, --PlateShadow
	},
}
]]

--Atom Punk palette
--[[
	colorMap = {
		lights =         { 200, 200, 200 }, --PlateHighlight
		main_highlight = { 175, 150, 125 }, --PlateLight
		main_light =     { 100,  75,  50 }, --PlateMid
		main_mid =       {  45,  30,  10 }, --PlateDark
		main_dark =      {  15,  15,  15 }, --PlateOutline
		metal_light =    { 165, 150, 135 }, --BodyHighlight
		metal_mid =      { 105,  70,  60 }, --BodyColor
		metal_dark =     {  65,  30,  30 }, --PlateShadow
	},
]]

--Steam Punk palette
--[[
	colorMap = {
		lights =         { 200, 200, 200 }, --PlateHighlight
		main_highlight = { 175, 150, 125 }, --PlateLight
		main_light =     { 125, 100,  75 }, --PlateMid
		main_mid =       {  50,  35,  15 }, --PlateDark
		main_dark =      {  15,  15,  15 }, --PlateOutline
		metal_light =    { 160, 150, 135 }, --BodyHighlight
		metal_mid =      { 100, 100,  90 }, --BodyColor
		metal_dark =     {  60,  60,  60 }, --PlateShadow
	},
]]