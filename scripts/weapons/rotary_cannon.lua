--------------------------------------------------- IMPORTATIONS ---------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]

local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

local mark = require(scriptPath.."/mark/mark")
--LOG("mark: " .. tostring(mark))

--------------------------------------------------- GENERIC UTILITY ---------------------------------------------------

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


--------------------------------------------------- CUSTOM UTILITY ---------------------------------------------------

local strafePath = {}

local function debugPointList()
	local str = "debugPointList() - Point list (count: " .. tostring(#strafePath) .. "): "
    for _,v in pairs(strafePath) do
        str = str .. "\n" .. v:GetString()
    end
    LOG(str)
end

local function getLastPathPoint(origin)
    local lastPathPoint = origin
    if #strafePath > 0 then
        lastPathPoint = strafePath[#strafePath]
    end
    return lastPathPoint
end

local function isAdjacentTile(origin, p)
    local lastPathPoint = getLastPathPoint(origin)

    if lastPathPoint == nil or p == nil then
        LOG("lastPathPoint is nil or p is nil! (shouldn't happen)")
        return false
    end
    return lastPathPoint:Manhattan(p) == 1
end

local function isRotaryCannon(weapon)
    return string.sub(weapon, 1, 20) == "truelch_RotaryCannon"
end

--[[
local function isPointAlreadyInTheList(p)
    for _, pathPoint in pairs(strafePath) do
        if pathPoint == p then
        	return true
        end
    end
    return false
end
]]

--I don't know if I can clone the list without using the same reference in lua, so I'll do that manually...
local function trimPath(p)
	--Step1: create a clone list
	--Lemon's suggestion: (shallow copy)
	local clonedStrafePath = shallow_copy(strafePath)

	--[[
	local clonedStrafePath = {}
    for _, pathPoint in pairs(strafePath) do
    	table.insert(clonedStrafePath, pathPoint)
    end
    ]]

	--Step2: clean path
	strafePath = {}

	--Step3: add points to path until we find p (included)
    for _, pathPoint in pairs(clonedStrafePath) do
    	table.insert(strafePath, pathPoint)
    	if pathPoint == p then
    		--LOG("We found p -> BREAK!")
    		break
    	end
    end
end

--Making it truelch_RotaryCannon: make p == nil for some reason
local function computeAddPoint(origin, p, maxLength)
    if p == nil then
        return
    end

    if strafePath == nil then
        strafePath = {}
    end

    --if isPointAlreadyInTheList(p) then
	if list_contains(strafePath, p) then --Lemon's suggestion!
        --TRIM
        trimPath(p)
    elseif isAdjacentTile(origin, p) and #strafePath < maxLength then
        table.insert(strafePath, p)
    end
end


--------------------------------------------------- WEAPON ---------------------------------------------------

truelch_RotaryCannon = Skill:new{
	Name = "Rotary Cannon / Missiles",
	Description = "Deals 2 damage on marked enemies at a range of 2.\nThen, do a strafe attack that marks enemies and deals one damage.\nThe path of the strafe is created by hovering the tiles you want to strike.",
	--Shop
	Class = "Brute",
	PowerCost = 0,
	Rarity = 3,
	--Art
	Icon = "weapons/rotary_cannon.png",
	LaunchSound = "/weapons/rocket_launcher",
	ImpactSound = "/impact/generic/explosion_large",	
	--Upgrades
	Upgrades = 2,
	UpgradeList = { "+1 Range", "+1 Damage" },
	UpgradeCost = { 2, 3 },
	--Strafe (cannon)
	DamageCannon = 1,
	Range = 3,
	StrafeApplyMark = true,
	StrafeAnimation = "ExploRaining1",
	StrafeSound = "/impact/generic/explosion",
	--AoE (missiles)
	DamageMissile = 2,
	AoERange = 2,
	MissileUpShot = "effects/tif_shotup_missile.png", --"effects/shotup_missileswarm.png"
	--TipImage
	TipMarkedPoints = { Point(1, 3) }, --for the custom tip image, missile effect
	TipStrafePath = { Point(2, 2), Point(3, 2), Point(3, 1) },
	TipImage = {
		Unit   = Point(2, 3),
		Enemy  = Point(2, 2),
		Enemy2 = Point(3, 2),
		Enemy3 = Point(1, 3),
		Target = Point(3, 3),
	}
}

--- Get Target Area

local previousOrigin
function truelch_RotaryCannon:GetTargetArea(point)
	--LOG("GetTargetArea")
	local ret = PointList()

	if previousOrigin == nil or previousOrigin ~= point then
		--Clear the path if we start from somewhere else! (maybe it's only useful in test mission?)
		strafePath = {}
	end
	previousOrigin = point

    --Add self point
    ret:push_back(point)

    --Add point adjacent to last point
    if #strafePath < self.Range then
        local lastPathPoint = getLastPathPoint(point)
        for dir = DIR_START, DIR_END do
            local nextPoint = lastPathPoint + DIR_VECTORS[dir]
            --if not isPointAlreadyInTheList(nextPoint) and nextPoint ~= point then
        	if not list_contains(strafePath, nextPoint) and nextPoint ~= point then --Lemon's suggestion
                ret:push_back(nextPoint)
            end
        end
    end

    --Path point (new!) - EXCEPT origin (point)
    for _, pathPoint in pairs(strafePath) do
    	if pathPoint ~= point then
    		ret:push_back(pathPoint)
    	end
    end

	--Show marked enemies
	if Board:IsTipImage() then
	    for _, point in pairs(self.TipMarkedPoints) do
	    	Board:AddAnimation(point, "truelch_tip_mark_medium", 2)
    	end
	end
	
	return ret
end

--- Attacks Custom Functions

--Cannon
function truelch_RotaryCannon:StrafeAttack(ret, start, dest, path)
	--Fix the dest. Basically we take the latest reachable point.
	--We stop the search when we actually reach dest. (we don't want to go through all the path!)

	local fixedDest = start

    for _, pathPoint in pairs(path) do
		if not Board:IsBlocked(pathPoint, PATH_PROJECTILE) then			
    		fixedDest = pathPoint
    	end

    	if pathPoint == dest then
    		--Stop the search here!
    		break
    	end
    end

	--Leap move
	local move = PointList()
	move:push_back(start)
	move:push_back(fixedDest)

	ret:AddLeap(move, 0.25)

	if fixedDest == start then
		--No move at all, we don't do the strafe attack
		return
	end

	for _, pathPoint in pairs(path) do
    	--we actually NEED to go through (fixed) dest for the break

		if pathPoint ~= start then
			--break if (fixed) dest
			if pathPoint == fixedDest then
				break
			end

    		--do damage + effect and stuff
    		local damage = SpaceDamage(pathPoint, self.DamageCannon)
    		damage.sAnimation = self.StrafeAnimation
    		damage.sSound = self.StrafeSound

			--Show mark (only tip image) --wut why did I limit this to tip image?
			--if Board:IsTipImage() then
			if Board:IsPawnSpace(pathPoint) then
				damage.sImageMark = "combat/icons/truelch_mark_weapon_mark.png"
			end

    		ret:AddDamage(damage)

    		ret:AddBounce(pathPoint, 1)

    		--mark?
    		local pawn = Board:GetPawn(pathPoint)
			if not Board:IsTipImage() and self.StrafeApplyMark == true and mark:canMark(pathPoint) then				
				mark:markEnemy(ret, damage, pawn)
			end

			if Board:IsTipImage() and self.StrafeApplyMark == true and pawn ~= nil then
				local fakeMarkIcon = SpaceDamage(pathPoint, 0)
				fakeMarkIcon.sAnimation = "truelch_tip_mark_short"
				ret:AddDamage(fakeMarkIcon)
			end

			ret:AddDelay(0.2)
    	end
    end
end

--Missiles
function truelch_RotaryCannon:ZoneAttack(ret, center)
	local size = self.AoERange
	local corner = center - Point(size, size)
	local p = Point(corner)
	for i = 0, ((size*2+1)*(size*2+1)) do
		local diff = center - p
		local dist = math.abs(diff.x) + math.abs(diff.y)

		local pawn = Board:GetPawn(p)

		--if we need to check isPawnMarked, no need to check if the pawn is an enemy
		if dist <= size and pawn ~= nil and p ~= center and pawn:IsEnemy() and mark:isPawnMarked(pawn) then
			local spaceDamage = SpaceDamage(p, self.DamageMissile)
			spaceDamage.bHidePath = true
			ret:AddArtillery(spaceDamage, self.MissileUpShot, 0.1) --,NO_DELAY
		end
		p = p + VEC_RIGHT
		if math.abs(p.x - corner.x) == (size*2+1) then
			p.x = p.x - (size*2+1)
			p = p + VEC_DOWN
		end
	end
end

--Fake missiles
local function TipFakeZoneAttack(ret, pointList, damage, upShot)
    for _, point in pairs(pointList) do
		local spaceDamage = SpaceDamage(point, damage)
		ret:AddArtillery(spaceDamage, upShot, 0.1) --,NO_DELAY
    end
end


-- Normal / Tip Image Effects

function truelch_RotaryCannon:NormalEffect(ret, p1, p2)
	LOG("truelch_RotaryCannon:NormalEffect")
	--Check if we click on start: don't do anything (it won't waste the turn)
	--TODO: also check if there's actually no enemies in range for the missiles' attack	
	if p2 == p1 then
		--RESET
		strafePath = {}
		--LOG("p2 == p1 -> RETURN") --happens even when I'm targeting an adjacent tile, wtf
		return --NEW!!! --(but still need to do the ... TODO)
	else
		computeAddPoint(p1, p2, self.Range)	
	end

	--another check: if you click on an occupied adjacent tile
	--well not adjacent from p1, if the tile is blocked we just don't allow the rest of the behaviour
	--if p1:Manhattan(p2) == 1 and Board:IsBlocked(p2, PATH_PROJECTILE) then
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		--LOG("adjacent AND blocked! -> RETURN")
		return
	end

	--Custom attacks
	--AoE missile attack -> p1: center, self.Range: size
	self:ZoneAttack(ret, p1)

	ret:AddDelay(0.3)

	if p2 ~= p1 then --new!
		--Strafe cannon attack -> p2: dest
		self:StrafeAttack(ret, p1, p2, strafePath)
	end

end


function truelch_RotaryCannon:TipImageEffect(ret, p1, p2)
	--LOG("truelch_RotaryCannon:TipImageEffect(p1: " .. p1:GetString() .. ", p2: " .. p2:GetString() .. ")")
	TipFakeZoneAttack(ret, self.TipMarkedPoints, self.DamageMissile, self.MissileUpShot)
	ret:AddDelay(0.3)
	self:StrafeAttack(ret, p1, p2, self.TipStrafePath)
end


function truelch_RotaryCannon:GetSkillEffect(p1, p2)
	--LOG("truelch_RotaryCannon:GetSkillEffect")
	local ret = SkillEffect()

	--To display the AoE
	--Wait maybe it'll be an issue with the attempted fix
	--Maybe only add this when we aren't targeting obstacles? That sounds dumb though...
	--Doesn't work because of the leap arrow anyway...
	--[[
	local aoePreviewDamage = SpaceDamage(p1)
	aoePreviewDamage.sImageMark = "combat/icons/truelch_gunship_rocket_aoe.png"
	ret:AddDamage(aoePreviewDamage)
	]]

	if Board:IsTipImage() then
		self:TipImageEffect(ret, p1, p2)
	else
		self:NormalEffect(ret, p1, p2)
	end
	
	return ret
end


--- Upgrades

truelch_RotaryCannon_A = truelch_RotaryCannon:new{
	UpgradeDescription = "You can target one additional tile.",
	Range = 4,
}

truelch_RotaryCannon_B = truelch_RotaryCannon:new{
	UpgradeDescription = "Increases the damage dealt by the Cannon and the Missiles by 1.",
	DamageCannon = 2,
	DamageMissile = 3,
}

truelch_RotaryCannon_AB = truelch_RotaryCannon:new{
	DamageCannon = 2,
	DamageMissile = 3,
	Range = 4,
}

--------------------------------------------------- CUSTOM EVENT ---------------------------------------------------

local function onRotaryCannonArmed(pawn)
	--LOG("onRotaryCannonArmed(pawn: " .. pawn:GetMechName() .. ")")

	--Create a new point list!
	strafePath = {}
end

local function onRotaryCannonDisarmed(pawn)
	--LOG("onRotaryCannonDisarmed(pawn: " .. pawn:GetMechName() .. ")")

	--Clear points!
	strafePath = {} --useless?
end


--------------------------------------------------- HOOKS / EVENTS SUBSCRIPTIONS ---------------------------------------------------

local previouslyArmed = false

modApi.events.onMissionUpdate:subscribe(function(mission)
	local currentlyArmed = false
	local pawn

	for i = 0, 2 do
		pawn = Board:GetPawn(i)
		if pawn ~= nil and isRotaryCannon(tostring(pawn:GetArmedWeapon())) then
			currentlyArmed = true
			break
		end
	end

	--Maybe an unnecessary precaution
	if pawn == nil then
		return
	end

	--Custom events
	if currentlyArmed and not previouslyArmed then		
		onRotaryCannonArmed(pawn)
	elseif not currentlyArmed and previouslyArmed then	
		onRotaryCannonDisarmed(pawn)
	end

	--Update previouslyArmed
	previouslyArmed = currentlyArmed
end)