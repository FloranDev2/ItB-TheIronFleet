local mod = {
	id = "truelch_TheIronFleet",
	name = "Iron Fleet",
	icon = "img/mod_icon.png",
	version = "1.0.2",
	modApiVersion = "2.9.2",
	--gameVersion = "1.2.88",
    dependencies = {
		memedit = "1.0.4",
        modApiExt = "1.21",
    }	
}

function mod:init()
	--Palette
	require(self.scriptPath .. "palette")

	--Mark mechanic
	require(self.scriptPath .. "mark/mark")

	--Achievements
	require(self.scriptPath .. "achievements")

	--Mechs
	require(self.scriptPath .. "mechs/gunship")
	require(self.scriptPath .. "mechs/airship")
	require(self.scriptPath .. "mechs/designator")	

	--Need to move all images importations to a separate file to keep things clean
	--Weapons' images
	modApi:appendAsset("img/weapons/fighter_strafe.png",      self.resourcePath .. "img/weapons/fighter_strafe.png")
	modApi:appendAsset("img/weapons/musket.png",              self.resourcePath .. "img/weapons/musket.png")
	modApi:appendAsset("img/weapons/rotary_cannon.png",       self.resourcePath .. "img/weapons/rotary_cannon.png")
	modApi:appendAsset("img/weapons/surveillance_radar.png",  self.resourcePath .. "img/weapons/surveillance_radar.png")

	--Effects
	modApi:appendAsset("img/effects/tif_shot_metal_slug_R.png",  self.resourcePath .. "img/effects/tif_shot_metal_slug_R.png")
	modApi:appendAsset("img/effects/tif_shot_metal_slug_U.png",  self.resourcePath .. "img/effects/tif_shot_metal_slug_U.png")
	modApi:appendAsset("img/effects/tif_shotup_missile.png",     self.resourcePath .. "img/effects/tif_shotup_missile.png")
	modApi:appendAsset("img/effects/tif_biplane.png",            self.resourcePath .. "img/effects/tif_biplane.png")

	--Sweep effect
	modApi:appendAsset("img/combat/icons/truelch_radar_sweep_1.png",self.resourcePath.."img/combat/icons/truelch_radar_sweep_1.png")
		Location["combat/icons/truelch_radar_sweep_1.png"] = Point(-85, -41)
	modApi:appendAsset("img/combat/icons/truelch_radar_sweep_2.png",self.resourcePath.."img/combat/icons/truelch_radar_sweep_2.png")
		Location["combat/icons/truelch_radar_sweep_2.png"] = Point(-85, -41)

	--Regular weapons
	require(self.scriptPath .. "/weapons/fighter_strafe")
	require(self.scriptPath .. "/weapons/rotary_cannon")
	require(self.scriptPath .. "/weapons/musket")
	require(self.scriptPath .. "/weapons/surveillance_radar")

	--Animations
	require(self.scriptPath .. "animations")

	--Weapon deck
	modApi:addWeaponDrop("truelch_FighterStrafe")
	modApi:addWeaponDrop("truelch_RotaryCannon")
	modApi:addWeaponDrop("truelch_Musket")
	modApi:addWeaponDrop("truelch_SurveillanceRadar")
end

function mod:load(options, version)
	modApi:addSquad(	
		{
			id = "truelch_TheIronFleet",
			"Iron Fleet",
			"GunshipMech",
			"AirshipMech",
			"DesignatorMech",
		},
		"Iron Fleet",
		"A mix of technology from varying ages creating a great air-supremacy force.",
		self.resourcePath .. "img/squad_icon.png"
	)
end

return mod