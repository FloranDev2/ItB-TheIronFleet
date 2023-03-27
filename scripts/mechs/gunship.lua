local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .."img/mechs/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
--local imageOffset = modApi:getPaletteImageOffset(mod.id)
local dieselPunk = modApi:getPaletteImageOffset("truelch_DieselPunk")

local files = {
	"gunship.png",
	"gunship_a.png",
	"gunship_w.png",
	"gunship_w_broken.png",
	"gunship_broken.png",
	"gunship_ns.png",
	"gunship_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.gunship =         a.MechUnit:new{Image = "units/player/gunship.png",          PosX = -25, PosY = -6 }
a.gunshipa =        a.MechUnit:new{Image = "units/player/gunship_a.png",        PosX = -25, PosY = -6, NumFrames = 4, Time = 0.8 }
a.gunshipw =        a.MechUnit:new{Image = "units/player/gunship_w.png",        PosX = -25, PosY = -6 }
a.gunship_broken =  a.MechUnit:new{Image = "units/player/gunship_broken.png",   PosX = -25, PosY = -9 }
a.gunshipw_broken = a.MechUnit:new{Image = "units/player/gunship_w_broken.png", PosX = -25, PosY = -6 }
a.gunship_ns =      a.MechIcon:new{Image = "units/player/gunship_ns.png" }


GunshipMech = Pawn:new{
	Name = "Gunship Mech",
	Class = "Brute",

	Health = 2,
	MoveSpeed = 3,
	Massive = true,
	Flying = true,
	
	Image = "gunship",
	ImageOffset = dieselPunk, --imageOffset,
	
	SkillList = { "truelch_RotaryCannon", --[["debugBoard"]] },

	--"/mech/science/superman_mech/"
	--"/mech/brute/needle_mech/"
	SoundLocation = "/support/support_drone/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}