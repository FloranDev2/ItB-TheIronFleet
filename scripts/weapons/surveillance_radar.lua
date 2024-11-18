--------------------------------------------------- IMPORTATIONS ---------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local mark = require(scriptPath.."/mark/mark")

--------------------------------------------------- CONSTANTS ---------------------------------------------------

--Remove mark after it has been used?
local CONSUME_MARK = false

--Or should I just read a parameter in the weapon?
local MARK_BONUS_DMG_1 = 1 --0 --truelch_SurveillanceRadar, truelch_SurveillanceRadar_A
local MARK_BONUS_DMG_2 = 2 --1 --truelch_SurveillanceRadar_B, truelch_SurveillanceRadar_AB


--------------------------------------------------- UTILITY / LOCAL FUNCTIONS ---------------------------------------------------

local sweepAnimVersion --1: new / 2: old
modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end
	local options = mod_loader.currentModContent[id].options
	sweepAnimVersion = options["option_sweepAnimVersion"].value
	--LOG("----- sweepAnimVersion: " .. tostring(sweepAnimVersion) .. ", type: " .. tostring(type(sweepAnimVersion)))
end)

local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

local function missionData()
    local mission = GetCurrentMission()

    --Test
    if mission == nil then
    	return nil
    end

    if mission.truelch_TheIronFleet == nil then
        mission.truelch_TheIronFleet = {}
    end

    return mission.truelch_TheIronFleet
end


--------------------------------------------------- WEAPON ---------------------------------------------------

truelch_SurveillanceRadar = Skill:new{
	Name = "Surveillance Radar",
	Description = "Marks all adjacent enemies.",
	--Shop
	Class = "Science",
	PowerCost = 0, --AE version
	Rarity = 3,
	--Art
	Icon = "weapons/surveillance_radar.png",
	SweepSound = "/weapons/airstrike",
	SweepAnim = "truelch_sweep_1",
	SweepAnimOld = "truelch_sweep_old_1",
	--Upgrades
	Upgrades = 2,
	UpgradeList = { "+1 Range", "+1 Mark Damage" },
	UpgradeCost = { 2, 3 },
	--Gameplay
	Limited = 1,
	MarkBonusDamage = 0,
	Range = 1,
	--TipImage
	TipMarkedPoints = { }, --No points!
	TipStrafeStarts = { Point(2, 2) },
	TipStrafeDir = DIR_UP,
	TipStrafeDamage = 1,
	TipIndex = 0, --0: sweep / 1: fake strafe attack
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 2),
		Mountain = Point(2, 1),
		Friendly = Point(3, 3),
		Target = Point(2, 2),
	}
}


function truelch_SurveillanceRadar:GetTargetArea(point)
	local ret = PointList()

	local size = self.Range
	local center = point
	
	local corner = center - Point(size, size)
	
	local p = Point(corner)
		
	for i = 0, ((size*2+1)*(size*2+1)) do
		local diff = center - p
		local dist = math.abs(diff.x) + math.abs(diff.y)
		if Board:IsValid(p) and dist <= size then
			ret:push_back(p)
		end
		p = p + VEC_RIGHT
		if math.abs(p.x - corner.x) == (size*2+1) then
			p.x = p.x - (size*2+1)
			p = p + VEC_DOWN
		end
	end

	--Show marked enemies
	if Board:IsTipImage() then
	    for _, point in pairs(self.TipMarkedPoints) do
	    	if self.TipIndex == 1 then --hopefully that'll make it!
	    		Board:AddAnimation(point, "truelch_tip_mark_medium", 2)
	    	end
    	end
    	--Change friend look
    	local friend = Board:GetPawn(Point(3,3))
    	friend:SetCustomAnim("airship")
	end
	
	return ret
end


--Sweep effect

local function SweepEffect(ret, p1, sweepAnim, sweepSound)	
	local dam = SpaceDamage(p1, 0)
	dam.sAnimation = sweepAnim
	dam.sSound = sweepSound
	ret:AddDamage(dam)
	return ret
end


--Normal effect

function truelch_SurveillanceRadar:NormalEffect(ret, p1, p2)
	--Radar anim
	local sweepAnim = self.SweepAnim
	if sweepAnimVersion == 2 then
		--LOG("[NORMAL] switch to old anim!")
		sweepAnim = self.SweepAnimOld
	end
	--LOG("[NORMAL] ---------> sweepAnim: " .. sweepAnim)
	SweepEffect(ret, p1, self.SweepAnim, self.SweepSound)

	local size = self.Range
	local center = p1
	
	local corner = center - Point(size, size)
	
	local p = Point(corner)
		
	for i = 0, ((size*2+1)*(size*2+1)) do
		local diff = center - p
		local dist = math.abs(diff.x) + math.abs(diff.y)
		--if Board:IsValid(p) and dist <= size and mark:canMark(p) then
		if Board:IsValid(p) and dist <= size then
			ret:AddBounce(p, -2)
			if mark:canMark(p) then
				--mark here
				local pawn = Board:GetPawn(p)
				local damage = SpaceDamage(p, 0)
				mark:markEnemy(ret, damage, pawn)
				ret:AddDamage(damage)
			end
		end
		p = p + VEC_RIGHT
		if math.abs(p.x - corner.x) == (size*2+1) then
			p.x = p.x - (size*2+1)
			p = p + VEC_DOWN
		end
	end

	return ret
end


--Tip image effect

local function TipFakeFighterStrafe(ret, start, tipStrafeDamage, tipStrafeDir)
	ret:AddAirstrike(start, "units/mission/bomber_1.png")
	local dam = SpaceDamage(start, tipStrafeDamage)
	dam.sAnimation = "ExploArt2"
	dam.iPush = tipStrafeDir
	ret:AddDamage(dam)
	ret:AddBounce(start, 2)
	return ret
end


function truelch_SurveillanceRadar:TipImageEffect(ret, p1, p2)	
	if self.TipIndex == 0 then
		--Radar anim
		local sweepAnim = self.SweepAnim
		if sweepAnimVersion == 2 then
			--LOG("[TIP] switch to old anim!")
			sweepAnim = self.SweepAnimOld
		end
		--LOG("[TIP] ---------> sweepAnim: " .. sweepAnim)
		SweepEffect(ret, p1, sweepAnim, self.SweepSound)

		-- Show mark --->
		local size = self.Range
		local center = p1		
		local corner = center - Point(size, size)		
		local p = Point(corner)
			
		for i = 0, ((size*2+1)*(size*2+1)) do
			local diff = center - p
			local dist = math.abs(diff.x) + math.abs(diff.y)
			local pawn = Board:GetPawn(p)
			if Board:IsValid(p) and dist <= size and pawn ~= nil and pawn:IsEnemy() then
				local damage = SpaceDamage(p, 0)
				damage.sImageMark = "combat/icons/truelch_mark_weapon_mark.png"
				ret:AddDamage(damage)
				ret:AddBounce(p, -2)

				--fake mark icon
				local fakeMarkIcon = SpaceDamage(p, 0)
				fakeMarkIcon.sAnimation = "truelch_tip_mark_short"
				ret:AddDamage(fakeMarkIcon)
			end
			p = p + VEC_RIGHT
			if math.abs(p.x - corner.x) == (size*2+1) then
				p.x = p.x - (size*2+1)
				p = p + VEC_DOWN
			end
		end		
		-- <--- Show Mark

		--
		self.TipIndex = 1
	else
		--Fake strafe attack
		for _, strafeStart in pairs(self.TipStrafeStarts) do
			TipFakeFighterStrafe(ret, strafeStart, self.TipStrafeDamage, self.TipStrafeDir)
			ret:AddDelay(0.2)

			--fake mark icon
			local fakeMarkIcon = SpaceDamage(strafeStart, 0)
			fakeMarkIcon.sAnimation = "truelch_tip_mark_short"
			ret:AddDamage(fakeMarkIcon)
		end

		--
		self.TipIndex = 0
	end

	return ret
end

function truelch_SurveillanceRadar:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	if Board:IsTipImage() then
		self:TipImageEffect(ret, p1, p2)
	else
		self:NormalEffect(ret, p1, p2)
	end

	return ret
end

truelch_SurveillanceRadar_A = truelch_SurveillanceRadar:new{
	UpgradeDescription = "Increases the radius by 1.",
	Range = 2,
	--Effect
	SweepAnim = "truelch_sweep_2",
	SweepAnim = "truelch_sweep_old_2",
	--TipImage
	TipStrafeStarts = { Point(2, 2), Point(1, 2) },
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 2),
		Enemy2 = Point(1, 2),
		Mountain = Point(2, 1),
		Building = Point(1, 1),
		Friendly = Point(3, 3),
		Target = Point(2, 2),
	}
}

truelch_SurveillanceRadar_B = truelch_SurveillanceRadar:new{
	UpgradeDescription = "+1 Damage done by allies to marked enemies.",	
	MarkBonusDamage = 1,
	--TipImage
	TipStrafeDamage = 2,
}

truelch_SurveillanceRadar_AB = truelch_SurveillanceRadar:new{
	Range = 2,
	MarkBonusDamage = 1,
	--Effect
	SweepAnim = "truelch_sweep_2",
	--TipImage
	TipStrafeStarts = { Point(2, 2), Point(1, 2) },
	TipStrafeDamage = 2,
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 2),
		Enemy2 = Point(1, 2),
		Mountain = Point(2, 1),
		Building = Point(1, 1),
		Friendly = Point(3, 3),
		Target = Point(2, 2),
	}
}


---------------------------------------- Passive ----------------------------------------

--local markBonusDamage = 1

--TODO: check if the passive still works if the Mech that carries it dies
local function IsBonusDamageActive()
	for i = 0, 2 do
		local pawn = Board:GetPawn(i)
		if pawn ~= nil then
			local weapons = pawn:GetPoweredWeapons()
			for index = 1, 2 do
				local weaponName = weapons[index]
				if weaponName == "truelch_SurveillanceRadar_B" or weaponName == "truelch_SurveillanceRadar_AB" then
					--LOG("Mark passive bonus damage is active!")
					return true
				end
			end
		end
	end

	--LOG("Mark passive bonus damage is NOT active!")
	return false
end

local function IsBonusDamageActive()
	for i = 0, 2 do
		local pawn = Board:GetPawn(i)
		if pawn ~= nil then
			local weapons = pawn:GetPoweredWeapons()
			for index = 1, 2 do
				local weaponName = weapons[index]
				if weaponName == "truelch_SurveillanceRadar_B" or weaponName == "truelch_SurveillanceRadar_AB" then
					--LOG("Mark passive bonus damage is active!")
					return true
				end
			end
		end
	end

	--LOG("Mark passive bonus damage is NOT active!")
	return false
end

--Example:
-- 123456789012345678901
--"truelch_Musket"

--The Iron Fleet Weapon list: (already sub)
local tifWeapons = {
	"Fighte",
	"Rotary",
	"Musket",
	"Survei"
}

local SUBSTRING_START = 9
local SUBSTRING_END = 14

local function IsSquadWeapon(weaponName)
	for _, name in pairs(tifWeapons) do
	    local sub = string.sub(name, SUBSTRING_START, SUBSTRING_END)
	    if sub == name then
	    	return true
	    end
	end
	return false
end

--Is valid for bonus damage
local function IsValidForBonusDamage(pawn, spaceDamage)

	--LOG("IsValidForBonusDamage?")

	--IS NOT TIP IMAGE (!!)
	if Board:IsTipImage() then
		--LOG("IsTipImage() -> return false")
		return false
	end

	--IS BONUS ACTIVE???
	if not IsBonusDamageActive() then
		--LOG("bonus damage is NOT active -> return false")
		return false
	end

	--(ATTACKING) PAWN IS VALID
	if pawn == nil or pawn:IsEnemy() == true then
		--LOG("attacking pawn is nil or is enemy -> return false")
		return false
	end

	--TARGET IS VALID
	--What's the parameter for the target position? :p
	local targetPawn = Board:GetPawn(spaceDamage.loc)
	if targetPawn == nil or targetPawn:IsEnemy() == false or not mark:isPawnMarked(targetPawn) then
		--LOG("target pawn is nil or is NOT enemy or is NOT marked -> return false")
		return false
	end

	--TODO: check for different threshold: one for is squad and one for is NOT squad

	--DAMAGE MUST BE SUPERIOR TO THRESHOLD
	--Positive for now
	if spaceDamage.iDamage <= 0 then
		--LOG("not an offensive weapon (spaceDamage.iDamage: " .. tostring(spaceDamage.iDamage) .. ") -> return false")
		return false
	end

	--LOG("Everything is ok -> RETURN TRUE! :)")

	--IF EVERYTHING IS OK ---> RETURN TRUE
	return true--lch

end

---------------------------------------- Hooks ----------------------------------------

local function computeMarkBonusDamage(pawn, skillEffect)
	if skillEffect.effect == nil then
		return
	end

	--LOG("skillEffect.effect:size(): " .. tostring(skillEffect.effect:size()))
	for i = 1, skillEffect.effect:size() do
		--LOG("i: " .. tostring(i))
	    local spaceDamage = skillEffect.effect:index(i);

	    --LOG("(before) spaceDamage: " .. tostring(spaceDamage.iDamage))
	    if IsValidForBonusDamage(pawn, spaceDamage) then
	    	--LOG("is valid for bonus damage! Before -> damage: " .. tostring(spaceDamage.iDamage))
	    	spaceDamage.iDamage = spaceDamage.iDamage + 1 --it works!!! thx Lemonymous!
	    end
	   	--LOG("(after) spaceDamage: " .. tostring(spaceDamage.iDamage))

	    --Remove mark is here even if we don't have bonus damage!
    	--Remove mark?
    	local targetPawn = Board:GetPawn(spaceDamage.loc)

    	if CONSUME_MARK and targetPawn ~= nil and mark:isPawnMarked(targetPawn) then
    		mark:removeMark(targetPawn)
    	end
	end
end

local HOOK_onSkillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
	computeMarkBonusDamage(pawn, skillEffect)
end

local HOOK_onFinalEffectBuildHook = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
	computeMarkBonusDamage(pawn, skillEffect)
end


---------------------------------------- Hooks / Events subscription ----------------------------------------

local function EVENT_onModsLoaded()
	modapiext:addSkillBuildHook(HOOK_onSkillBuild)
	modapiext:addFinalEffectBuildHook(HOOK_onFinalEffectBuildHook)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)