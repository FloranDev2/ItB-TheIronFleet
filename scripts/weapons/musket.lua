--------------------------------------------------- IMPORTATIONS ---------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]

--Paths
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

--Libs
local mark = require(scriptPath.."/mark/mark")
--LOG("mark: " .. tostring(mark))

--------------------------------------------------- UTILITY / LOCAL FUNCTIONS ---------------------------------------------------
local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_TheIronFleet == nil then
        mission.truelch_TheIronFleet = {}
    end

    return mission.truelch_TheIronFleet
end


--------------------------------------------------- WEAPON ---------------------------------------------------

truelch_Musket = TankDefault:new{
	Name = "Musket Shot",
	Description = "Fires a metal slug fitted with a radio transmitter, marking the target. Deals 1 additional damage against marked targets.",
	--Shop
	Class = "Science",
	PowerCost = 0,
	Rarity = 3,
	--Art
	Icon = "weapons/musket.png",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
	--Upgrades
	Upgrades = 1,
	UpgradeList = { "+1 Damage" },
	UpgradeCost = { 1 },
	--Limited range projectile
	ZoneTargeting = ZONE_DIR,
	ProjectileArt = "effects/tif_shot_metal_slug",
	--Gameplay
	Damage = 1,
	BonusDamage = 1,
	Range = 4,
	--TipImage
	TipMarkedPoints = { --[[Point(2, 1)]] }, --For the second shot?
	TipImage = {
		Unit   = Point(2, 3),
		Enemy  = Point(2, 1),
		Target = Point(2, 1),
	}
}

function truelch_Musket:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		local dirPoints = {}
		for i = 1, self.Range do
			local curr = Point(point + DIR_VECTORS[dir] * i)

			if Board:IsValid(curr) then
				table.insert(dirPoints, curr)
			end

			local pawn = Board:GetPawn(curr)			

			if pawn ~= nil or Board:IsBlocked(curr, PATH_PROJECTILE) or not Board:IsValid(curr) or i == self.Range then
			    for _, dirPoint in pairs(dirPoints) do
			    	ret:push_back(dirPoint)
			    end
			    break
			end
		end
	end

	if Board:IsTipImage() then
	    for _, point in pairs(self.TipMarkedPoints) do
	    	Board:AddAnimation(point, "truelch_tip_mark_medium", 2)
    	end
	end

	return ret
end

--Custom projectile end, taking account of the range
function MusketGetProjectileEnd(p1, p2, range)
	profile = PATH_PROJECTILE
	local direction = GetDirection(p2 - p1)

	local target = p1
	local curr = p1

	for i = 1, range do
		curr = Point(p1 + DIR_VECTORS[direction] * i)
		if Board:IsValid(curr) then
			target = curr
		end

		local pawn = Board:GetPawn(curr)

		if pawn ~= nil or Board:IsBlocked(curr, PATH_PROJECTILE) or not Board:IsValid(curr) or i == range then
		    break
		end
	end
	
	return target
end


function truelch_Musket:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local target = MusketGetProjectileEnd(p1, p2, self.Range)

	--Bonus damage on already marked enemies
	local damage = self.Damage	
	local pawn = Board:GetPawn(target)
	if pawn ~= nil and mark:isPawnMarked(pawn) then
		damage = damage + self.BonusDamage
		LOG("Damage increased!")
	end
	
	local spaceDamage = SpaceDamage(target, damage)

	--Show mark (only tip image)
	if Board:IsTipImage() then
		spaceDamage.sImageMark = "combat/icons/truelch_mark_weapon_mark.png"

		--fake mark icon
		local fakeMarkIcon = SpaceDamage(p2, 0)
		fakeMarkIcon.sAnimation = "truelch_tip_mark_short"
		ret:AddDamage(fakeMarkIcon)
	end

	--Mark the target
	if mark:canMark(target) then
		mark:markEnemy(ret, spaceDamage, pawn)
	end
	
	--Add
	ret:AddProjectile(spaceDamage, self.ProjectileArt, FULL_DELAY)

	return ret
end


truelch_Musket_A = truelch_Musket:new{
	UpgradeDescription = "Increases the damage dealt by 1.",
	Damage = 2,
}