local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local dieselPunk = modApi:getPaletteImageOffset("truelch_DieselPunk")

local files = {
	"airship.png",
	"airship_a.png",
	"airship_w.png",
	"airship_w_broken.png",
	"airship_broken.png",
	"airship_ns.png",
	"airship_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, mechPath..file)
end

local a = ANIMS
a.airship =         a.MechUnit:new{Image = "units/player/airship.png",          PosX = -28, PosY = -5 }
--was -24 / -5
a.airshipa =        a.MechUnit:new{Image = "units/player/airship_a.png",        PosX = -28, PosY = -10, NumFrames = 8, Time = 0.4 --[[Lengths = { 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4 },]] }
a.airshipw =        a.MechUnit:new{Image = "units/player/airship_w.png",        PosX = -28, PosY = 4 }
a.airship_broken =  a.MechUnit:new{Image = "units/player/airship_broken.png",   PosX = -28, PosY = -5 }
a.airshipw_broken = a.MechUnit:new{Image = "units/player/airship_w_broken.png", PosX = -28, PosY = -5 }
a.airship_ns =      a.MechIcon:new{Image = "units/player/airship_ns.png" }


AirshipMech = Pawn:new{
	Name = "Airship Mech",
	Class = "Ranged",

	Health = 2,
	MoveSpeed = 2,
	Massive = true,
	Flying = true,

	Explodes = true, --Machin's proposition lmao I love that

	LargeShield = true, --I want to test that!

	Image = "airship",	
	ImageOffset = dieselPunk,
	
	SkillList = { "truelch_FighterStrafe", },

	SoundLocation = "/mech/flying/jet_mech/", 
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}