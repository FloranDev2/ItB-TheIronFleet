--Mod
local mod = mod_loader.mods[modApi.currentMod]

--Paths
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

--Libs
local mark = require(scriptPath.."/mark/mark")

--Goals
local HI_MARK_GOAL   = 4
local VALKYRIES_GOAL = 5

squad = "truelch_TheIronFleet"

--Add achievements
local achievements = {
	hiMark = modApi.achievements:add{
		id = "hiMark",
		name = "Oh, hi Mark!",
		tip = "Have "..tostring(HI_MARK_GOAL).." marked enemies at the end of your turn",
		img = mod.resourcePath.."img/achievements/hiMark.png",
		squad = squad,
	},

	rideOfTheValkyries = modApi.achievements:add{
		id = "rideOfTheValkyries",
		name = "Ride of the Valkyries",
		tip = "Kill "..tostring(VALKYRIES_GOAL).." enemies in a single attack",
		img = mod.resourcePath.."img/achievements/rideOfTheValkyries.png",
		squad = squad,
	},

	aroundTheWorld = modApi.achievements:add{
		id = "aroundTheWorld",
		name = "Around the World in Eighty Days",
		tip = "Reach every corner of the map with the Airship Mech before the end of a mission",
		img = mod.resourcePath.."img/achievements/aroundTheWorld.png",
		squad = squad,
	},
}

--Utility functions
local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function isSquad()
	return true
		and isGame()
		and GAME.additionalSquadData.squad == squad
end

local function isMission()
	local mission = GetCurrentMission()

	return true
		and isGame()
		and mission ~= nil
		and mission ~= Mission_Test
end

local function isMissionBoard()
	return true
		and isMission()
		and Board ~= nil
		and Board:IsTipImage() == false
end

local function isGameData()
	return true
		and GAME ~= nil
		and GAME.truelch_TheIronFleet ~= nil
		and GAME.truelch_TheIronFleet.achievementData ~= nil
end

local function gameData()
	if GAME.truelch_TheIronFleet == nil then
		GAME.truelch_TheIronFleet = {}
	end

	if GAME.truelch_TheIronFleet.achievementData == nil then
		GAME.truelch_TheIronFleet.achievementData = {}
	end

	return GAME.truelch_TheIronFleet.achievementData
end

local function missionData()
    local mission = GetCurrentMission()

    --test
    if mission == nil then
    	return nil
    end

    if mission.truelch_TheIronFleet == nil then
        mission.truelch_TheIronFleet = {}
    end

    return mission.truelch_TheIronFleet
end

local function achievementData()
	local mission = GetCurrentMission()

	if mission.truelch_TheIronFleet == nil then
		mission.truelch_TheIronFleet = {}
	end

	if mission.truelch_TheIronFleet.achievementData == nil then
		mission.truelch_TheIronFleet.achievementData = {}
	end

	--Initializing other data here
	--Pending points
	if mission.truelch_TheIronFleet.achievementData.pendingPoints == nil then
		mission.truelch_TheIronFleet.achievementData.pendingPoints = {}
		--0: North, 1: West, 2: East, 3: South
		for i = 0, 3 do
			mission.truelch_TheIronFleet.achievementData.pendingPoints[i] = false
		end
	end

	--Validated points
	if mission.truelch_TheIronFleet.achievementData.validatedPoints == nil then
		mission.truelch_TheIronFleet.achievementData.validatedPoints = {}
		--0: North, 1: West, 2: East, 3: South
		for i = 0, 3 do
			mission.truelch_TheIronFleet.achievementData.validatedPoints[i] = false
		end
	end

	--Kill count since last pawn triggered skill build (should be enough)
	if mission.truelch_TheIronFleet.achievementData.killCount == nil then
		mission.truelch_TheIronFleet.achievementData.killCount = 0
	end

	--Return
	return mission.truelch_TheIronFleet.achievementData
end

--Oh, hi Mark! (hiMark)
--Have HI_MARK_GOAL (4) marked enemies at the end of your turn
--Move that to mark lib?
local function getAliveMarkedEnemyNumber()
	local missionData = missionData()

	aliveMarkedEnemyNumber = 0
    for _, id in pairs(missionData.markedPawnIds) do
    	local pawn = Board:GetPawn(id)
    	if pawn ~= nil then
    		aliveMarkedEnemyNumber = aliveMarkedEnemyNumber + 1
    	end
    end
    return aliveMarkedEnemyNumber
end

local getTooltip = achievements.hiMark.getTooltip
achievements.hiMark.getTooltip = function(self)
	local result = getTooltip(self)

	if isMission() then
		result = result.."\n\nMarked enemies: "..getAliveMarkedEnemyNumber().." / "..HI_MARK_GOAL
	end

	return result
end

function completeHiMark()
	--LOG("completeHiMark()")
	--Board:AddAlert(Point(4, 4), "Oh hi, Mark! completed!")
	if not achievements.hiMark:isComplete() then
		achievements.hiMark:addProgress{ complete = true } --test for now
	end
end

--Ride of the Valkyries (rideOfTheValkyries)
--Kill VALKYRIES_GOAL (5) enemies in a single attack
--No tooltip for this one, the action is instant
function completeRideOfTheValkyries()
	LOG("completeRideOfTheValkyries()")
	Board:AddAlert(Point(4, 4), "Ride of the Valkyries completed!")
	if not achievements.rideOfTheValkyries:isComplete() then
		achievements.rideOfTheValkyries:addProgress{ complete = true } --test for now
	end
end

--Around the world (aroundTheWorld)
--Reach every corner of the map with the Airship Mech before the end of a mission
local function getAroundTheWorldPointText(i)
	local achievementData = achievementData()
	if achievementData.validatedPoints[i] then
		return "validated!"
	elseif achievementData.pendingPoints[i] then
		return "pending..."
	else
		return "not reached yet."
	end
end

local getTooltip = achievements.aroundTheWorld.getTooltip
achievements.aroundTheWorld.getTooltip = function(self)
	local result = getTooltip(self)

	if isMission() then
		result = result.."\n\nNorth: "..getAroundTheWorldPointText(0)..
						   "\nWest: "..getAroundTheWorldPointText(1)..
						   "\nEast: "..getAroundTheWorldPointText(2)..
						   "\nSouth: "..getAroundTheWorldPointText(3)
	end

	return result
end

function completeAroundTheWorld()
	--LOG("completeAroundTheWorld()")
	--Board:AddAlert(Point(4, 4), "Around the World completed!")
	if not achievements.aroundTheWorld:isComplete() then
		achievements.aroundTheWorld:addProgress{ complete = true } --test for now
	end
end


----------------------------------------------- VARS -----------------------------------------------

--I hope I didn't mess that up!
--0: North, 1: West, 2: East, 3: South
local NORTH = Point(0, 0)
local WEST  = Point(0, 7)
local EAST  = Point(7, 0)
local SOUTH = Point(7, 7)

--For tests:
--[[
local NORTH = Point(3, 3)
local WEST  = Point(3, 4)
local EAST  = Point(4, 3)
local SOUTH = Point(4, 4)
]]

----------------------------------------------- FUNCTIONS -----------------------------------------------

--aroundTheWorld
local function computeAddPoint(point)
	--LOG("computeAddPoint(point: " .. point:GetString() .. ")")
	local achievementData = achievementData()
	--0: North, 1: West, 2: East, 3: South
	if point == NORTH then
		achievementData.pendingPoints[0] = true
		--LOG("Added North to pending points!")
		--Board:AddAlert(point, "Added North to pending points!")
	elseif point == WEST then
		achievementData.pendingPoints[1] = true
		--LOG("Added West to pending points!")
		--Board:AddAlert(point, "Added West to pending points!")
	elseif point == EAST then
		achievementData.pendingPoints[2] = true
		--LOG("Added East to pending points!")
		--Board:AddAlert(point, "Added East to pending points!")
	elseif point == SOUTH then
		achievementData.pendingPoints[3] = true
		--LOG("Added South to pending points!")
		--Board:AddAlert(point, "Added South to pending points!")
	end
end

--aroundTheWorld
--UH OH. It seems that enemy turn is skipped if there's no enemy in the last turn!
--Might need to use pending point in this case...
local function computeRemovePoint(point)
	local achievementData = achievementData()
	--0: North, 1: West, 2: East, 3: South
	if point == NORTH then
		achievementData.pendingPoints[0] = false
		--LOG("Removed North to pending points!")
		--Board:AddAlert(point, "Removed North to pending points!")
	elseif point == WEST then
		achievementData.pendingPoints[1] = false
		--LOG("Removed West to pending points!")
		--Board:AddAlert(point, "Removed West to pending points!")
	elseif point == EAST then
		achievementData.pendingPoints[2] = false
		--LOG("Removed East to pending points!")
		--Board:AddAlert(point, "Removed East to pending points!")
	elseif point == SOUTH then
		achievementData.pendingPoints[3] = false
		--LOG("Removed South to pending points!")
		--Board:AddAlert(point, "Removed South to pending points!")
	end	
end

--aroundTheWorld
local function loadPendingToValidatedPoints()
	local achievementData = achievementData()
	--0: North, 1: West, 2: East, 3: South
	for i = 0, 3 do
		--That should do the trick
		achievementData.validatedPoints[i] = achievementData.validatedPoints[i] or achievementData.pendingPoints[i]
		--LOG("validatedPoints[" .. tostring(i) .. "]: " .. tostring(achievementData.validatedPoints[i]))
	end	
end

--aroundTheWorld (maybe unnecessary)
local function refreshPendingPoints()
	--LOG("refreshPendingPoints()")
	local achievementData = achievementData()
	--0: North, 1: West, 2: East, 3: South
	for i = 0, 3 do
		achievementData.pendingPoints[i] = false
	end
end

--hiMark
local function checkMarkedEnemiesNumber()
	--LOG("checkMarkedEnemiesNumber()")

	local missionData = missionData()

	if missionData == nil or missionData.markedPawnIds == nil then
		LOG(" -> missionData == nil or missionData.markedPawnIds -> RETURN")
		return
	end

	--Actually, we still store the ids of dead enemies!
	local aliveMarkedEnemyNumber = getAliveMarkedEnemyNumber()

    --LOG("marked enemies: " .. #missionData.markedPawnIds)
	--LOG("aliveMarkedEnemyNumber: " .. aliveMarkedEnemyNumber .. " / goal: " .. HI_MARK_GOAL)	

	if aliveMarkedEnemyNumber >= HI_MARK_GOAL then
		completeHiMark()
	end
end

--aroundTheWorld
--Hope this is called AFTER the last loadPendingToValidatedPoints() call
local function checkValidatedPoints()
	local achievementData = achievementData()
	local isOk = true
	for i = 0, 3 do
		--Fix for when the last turn has no Vek and their turn is skipped
		isOk = isOk and (achievementData.validatedPoints[i] or achievementData.pendingPoints[i])
	end
	if isOk then
		completeAroundTheWorld()
	end
end

----------------------------------------------- HOOKS -----------------------------------------------
--local lastTurn = "none" --to see if the enemy turn is skipped when there's no living enemy last turn
local function HOOK_onNextTurnHook()
	if not isSquad() or not isMission() then return end
	achievementData().killCount = 0
    if Game:GetTeamTurn() == TEAM_PLAYER then
    	refreshPendingPoints()
    elseif Game:GetTeamTurn() == TEAM_ENEMY then
    	loadPendingToValidatedPoints()
		checkMarkedEnemiesNumber()
    end
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
	if not isSquad() or not isMission() then return end
	achievementData().killCount = 0
end

local HOOK_onFinalEffectBuild = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
	if not isSquad() or not isMission() then return end
	achievementData().killCount = 0
end

local HOOK_onPawnUndoMove = function(mission, pawn, undonePosition)
	if not isSquad() or not isMission() then return end

	--LOG("HOOK_onPawnUndoMove")

	if pawn:GetType() == "AirshipMech" then
		computeRemovePoint(undonePosition)
	end
end

--https://github.com/itb-community/ITB-ModUtils/blob/master/hooks.md#pawnpositionchangedhook
local function HOOK_onPawnPositionChanged(mission, pawn, oldPosition)
	--LOG(pawn:GetMechName() .. " position changed from " .. oldPosition:GetString() .. " to " .. pawn:GetSpace():GetString())
	if pawn ~= nil and pawn:GetType() == "AirshipMech" then
		--Board:Ping(oldPosition, GL_Color(0, 0, 0))
		--Board:Ping(pawn:GetSpace(), GL_Color(255, 255, 255))
		computeAddPoint(pawn:GetSpace())
	end
end

local function HOOK_onMissionEnd(mission)
    if not isSquad() or not isMission() then return end
    local achievementData = achievementData()
    checkValidatedPoints()
end

local HOOK_onPawnKilled = function(mission, pawn)
	if not isSquad() or not isMission() then return end

	local achievementData = achievementData()
	
	if pawn:IsEnemy() then --lmao don't kill your own units / allies / neutral to get this achievement!
		--Increment kill count
		--LOG("(before) kill count: " .. achievementData.killCount)
		achievementData.killCount = achievementData.killCount + 1
		LOG("(after) kill count: " .. achievementData.killCount)

		--Check kill count
		if achievementData.killCount >= VALKYRIES_GOAL then
			completeRideOfTheValkyries()
		end
	end
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook) --hiMark + aroundTheWorld
    modapiext:addSkillEndHook(HOOK_onSkillEnd) --ideOfTheValkyries
    modapiext:addFinalEffectBuildHook(HOOK_onFinalEffectBuild)
    modapiext:addPawnUndoMoveHook(HOOK_onPawnUndoMove) --aroundTheWorld
    modapiext:addPawnPositionChangedHook(HOOK_onPawnPositionChanged) --omg this is what I was looking for
    modApi:addMissionEndHook(HOOK_onMissionEnd) --aroundTheWorld
	modapiext:addPawnKilledHook(HOOK_onPawnKilled) --rideOfTheValkyries
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)