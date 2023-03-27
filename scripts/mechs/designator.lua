local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

local files = {
	"designator.png",
	"designator_a.png",
	"designator_w.png",
	"designator_w_broken.png",
	"designator_broken.png",
	"designator_ns.png",
	"designator_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.designator =         a.MechUnit:new{Image = "units/player/designator.png",          PosX = -18, PosY = -7 } --doesn't seem to change anything?
a.designatora =        a.MechUnit:new{Image = "units/player/designator_a.png",        PosX = -18, PosY = -7, NumFrames = 4 }
a.designatorw =        a.MechUnit:new{Image = "units/player/designator_w.png",        PosX = -18, PosY = 1 }
a.designator_broken =  a.MechUnit:new{Image = "units/player/designator_broken.png",   PosX = -18, PosY = -7 }
a.designatorw_broken = a.MechUnit:new{Image = "units/player/designator_w_broken.png", PosX = -18, PosY = 1 }
a.designator_ns =      a.MechIcon:new{Image = "units/player/designator_ns.png", } 


DesignatorMech = Pawn:new{
	Name = "Designator Mech",
	Class = "Science",

	Health = 2,
	MoveSpeed = 4,
	Massive = true,
	
	Image = "designator",
	ImageOffset = imageOffset,
	
	SkillList = { "truelch_Musket", "truelch_SurveillanceRadar" },

	--"/mech/prime/punch_mech/"
	SoundLocation = "/mech/prime/inferno_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}