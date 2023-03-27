--------------------------------------------------- IMPORTATIONS ---------------------------------------------------
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local mark = require(scriptPath.."/mark/mark")

--new previewer (not needed?)
--local previewer = require(scriptPath.."/libs/weaponPreview")
--LOG("TRUELCH - previewer: " .. tostring(previewer))
--old previewer
--local previewer = require(scriptPath .."weaponPreview/api")

--------------------------------------------------- UTILITY / LOCAL FUNCTIONS ---------------------------------------------------

--[[
local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end
]]

local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function missionData()
    local mission = GetCurrentMission()

    --New: hangar
    if mission == nil then
    	return nil
    end

    if mission.truelch_TheIronFleet == nil then
        mission.truelch_TheIronFleet = {}
    end

    return mission.truelch_TheIronFleet
end


--------------------------------------------------- WEAPON ---------------------------------------------------

truelch_FighterStrafe = Skill:new{
	Name = "Fighter Strafe",
	--Description = "Strikes a target and every marked enemy on the map, dealing 1 damage and pushing.",
	Description = "Marks and pushes a target.\nAlso strikes other marked enemies, dealing 1 damage and pushing in the same direction.",
	--Shop
	Class = "Ranged",
	PowerCost = 0,
	Rarity = 3,
	--AE
	TwoClick = true,
	--Art
	Icon = "weapons/fighter_strafe.png",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
	--Upgrades
	Upgrades = 2,
	UpgradeList = { "+1 Range", "+1 Damage" },
	UpgradeCost = { 2, 3 },
	--Gameplay
	Range = 2,
	--Strike
	StrikeDamage = 1,
	--Main target
	TargetDamage = 0,
	MarkTarget = true, --was false in tob's version
	--TipImage
	TipMarkedPoints = { Point(1, 1) },
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(1, 2),
		Enemy2 = Point(1, 1),
		Mountain = Point(2, 1), --to block secondary enemy because I'm too lazy to move the icon :p
		Target = Point(1, 2),
		Second_Click = Point(2, 2),
		Length = 7,
	}
}

function truelch_FighterStrafe:GetTargetArea(point)
	local ret = PointList()

	--Diamond shaped area
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

	local board_size = Board:GetSize()
	for i = 0, board_size.x - 1 do
		for j = 0, board_size.y - 1  do
			if Board:IsPawnTeam(Point(i, j), TEAM_ENEMY) and mark:isPawnMarked(Board:GetPawn(Point(i, j))) then
				ret:push_back(Point(i, j))
			end
		end
	end

	--Show marked enemies
	if Board:IsTipImage() then
	    for _, point in pairs(self.TipMarkedPoints) do
	    	Board:AddAnimation(point, "truelch_tip_mark_long", 2)
    	end
	end
	
	--Return
	return ret
end

--Ret is the skill effect
function truelch_FighterStrafe:Attack(ret, p2, dir, isMainTarget)
	ret:AddSound("/weapons/airstrike")	

	if dir == DIR_UP or dir == DIR_DOWN then
		ret:AddReverseAirstrike(p2, "effects/tif_biplane.png")
	else
		ret:AddAirstrike(p2, "effects/tif_biplane.png")
	end

	--Gave damage after so that we can mark with this space damage.
	local spaceDamage = SpaceDamage(p2, 0) --tmp damage value

	local damage = self.StrikeDamage
	if isMainTarget == true then
		damage = self.TargetDamage

		local target = Board:GetPawn(p2)

		--canMark takes a Point as a parameter, not a Pawn... Ughhh (might be interesting to do both versions to avoid this?)
		if target ~= nil and mark:canMark(p2) then
			mark:markEnemy(ret, spaceDamage, target)
		end

		--Custom tip image! Note: the enemy is pushed!
		local fakeMarkIcon = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		fakeMarkIcon.sAnimation = "truelch_tip_mark_short"
		ret:AddDamage(fakeMarkIcon)
	end

	spaceDamage.iDamage = damage
	
	spaceDamage.sAnimation = "ExploArt2"
	spaceDamage.sSound = "/impact/generic/explosion_large"
	spaceDamage.iPush = dir	
	ret:AddDamage(spaceDamage)
	ret:AddBounce(p2, 2)

	return ret
end

function truelch_FighterStrafe:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, 0)
	ret:AddDamage(damage)
	return ret
end

function truelch_FighterStrafe:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	local board_size = Board:GetSize()
	for dir = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir]
		ret:push_back(curr)
	end

	return ret
end

function truelch_FighterStrafe:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local direction = GetDirection(p3 - p2)

	--Strike the main target before all marked enemies
	self:Attack(ret, p2, direction, true)

	--Attack all marked enemies (excluding the main target)
	local board_size = Board:GetSize()
	for i = 0, board_size.x - 1 do
		for j = 0, board_size.y - 1  do
			if Board:IsPawnTeam(Point(i, j), TEAM_ENEMY) and mark:isPawnMarked(Board:GetPawn(Point(i, j))) and p2 ~= Point(i, j) then
				self:Attack(ret, Point(i, j), direction, false)
			end
		end
	end

	if Board:IsTipImage() then
	    for _, point in pairs(self.TipMarkedPoints) do
	    	self:Attack(ret, point, direction, false)
    	end
	end

	return ret
end

truelch_FighterStrafe_A = truelch_FighterStrafe:new{
	UpgradeDescription = "Increases by one the radius of the targetting range.",
	Range = 3,
	--TipImage
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 0),
		Enemy2 = Point(1, 1),
		Target = Point(2, 0),
		Second_Click = Point(3, 0),
		Length = 7,
	}
}

truelch_FighterStrafe_B = truelch_FighterStrafe:new{
	UpgradeDescription = "All striked tiles are dealt 1 additional damage.",
	StrikeDamage = 2,
}

truelch_FighterStrafe_AB = truelch_FighterStrafe:new{
	StrikeDamage = 2,
	Range = 3,
	--TipImage
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 0),
		Enemy2 = Point(1, 1),
		Target = Point(2, 0),
		Second_Click = Point(3, 0),
		Length = 7,
	}
}