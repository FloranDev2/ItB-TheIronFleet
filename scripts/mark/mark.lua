
--[[
Mark Library
v0.0.0
By: Truelch, imagined by tob260 for the Iron Fleet.

Dependencies:
- weaponPreview (old lib)
]]

--------------------------------------------------- MARK ---------------------------------------------------

mark = {}


--------------------------------------------------- IMPORTATIONS ---------------------------------------------------

--Mod
local mod = mod_loader.mods[modApi.currentMod]

--Paths
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

local markScriptPath = scriptPath .. "/mark/scripts/"
local markResourcePath = scriptPath .. "/mark/"

--old previewer (unused?)
--local previewer = require(scriptPath.."/weaponPreview/api")
--local previewer = require(markScriptPath.."/libs/weaponPreview/api") --same issue as above


--I can do that before importing the images, cool!
require(markScriptPath .. "/animations")

--------------------------------------------------- IMAGES ---------------------------------------------------


--Mark icons (weapon's mark)
modApi:appendAsset("img/combat/icons/truelch_mark_weapon_mark.png", markResourcePath.."img/combat/icons/truelch_mark_weapon_mark.png")
	Location["combat/icons/truelch_mark_weapon_mark.png"] = Point(-21, 4)

--Mark icons (board)
for i = 0, 2 do
	--big red (b)
	modApi:appendAsset("img/combat/icons/truelch_mark_board_b_"..tostring(i)..".png", markResourcePath.."img/combat/icons/truelch_mark_board_b_0.png")
		Location["combat/icons/truelch_mark_board_b_"..tostring(i)..".png"] = Point(-15, 6)
	--small red (c)
	modApi:appendAsset("img/combat/icons/truelch_mark_board_c_"..tostring(i)..".png", markResourcePath.."img/combat/icons/truelch_mark_board_c_"..tostring(i)..".png")
		Location["combat/icons/truelch_mark_board_c_"..tostring(i)..".png"] = Point(-15, 6)
	--big yellow (tmp b)
	modApi:appendAsset("img/combat/icons/truelch_mark_board_b_"..tostring(i)..".png", markResourcePath.."img/combat/icons/truelch_mark_board_b_"..tostring(i)..".png")
		Location["combat/icons/truelch_mark_board_b_"..tostring(i)..".png"] = Point(-15, 6)
	--small yellow (tmp c)
	modApi:appendAsset("img/combat/icons/truelch_mark_board_c_"..tostring(i)..".png", markResourcePath.."img/combat/icons/truelch_mark_board_c_"..tostring(i)..".png")
		Location["combat/icons/truelch_mark_board_c_"..tostring(i)..".png"] = Point(-15, 6)
end

--small red (c) - "real" anim for custom tip images
modApi:appendAsset("img/combat/icons/truelch_mark_board_c.png", markResourcePath.."img/combat/icons/truelch_mark_board_c.png")
	Location["combat/icons/truelch_mark_board_c.png"] = Point(-15, 6)


--------------------------------------------------- UTILITY / LOCAL FUNCTIONS ---------------------------------------------------

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

    --test
    if mission == nil then
    	return nil
    end

    if mission.truelch_TheIronFleet == nil then
        mission.truelch_TheIronFleet = {}
    end

    return mission.truelch_TheIronFleet
end


--------------------------------------------------- "PUBLIC" FUNCTIONS ---------------------------------------------------

--p must be a point
function mark:canMark(p)
	--TODO: add assert

	--Additional safety
	if Board:IsTipImage() then
		return false
	end

	local pawn = Board:GetPawn(p)

	--Pawn exists?
	if pawn == nil then
		--LOG("  -> The pawn doesn't exist! -> return false")
		return false
	end

	--Not an enemy?
	if not pawn:IsEnemy() then
		--LOG("  -> This pawn is not an enemy! -> return false")
		return false
	end

	local missionData = missionData()

	--Tmp fix for hangar
	if missionData == nil then
		--LOG("missionData is nil!")
		return false
	end

	--Shouldn't be useful anymore
	if missionData.markedPawnIds == nil then
		--LOG("Initialized markedPawnIds (canMark)")
		missionData.markedPawnIds = {} --test
	end

	--TODO: check if it's tip image
	--Already in list?
    for _, v in pairs(missionData.markedPawnIds) do
        if v == pawn:GetId() then
    		--LOG("  -> This enemy is already marked! -> return false")
            return false
        end
    end

	--End
	--LOG("  -> This enemy can be marked! -> return true")

	return true
end


--"local" function (maybe I should add "local" accessor btw?)
function mark:addMark(ret, pawn)
	--I had this error:
	--./mods/The Iron Fleet AE (v0_0_0)/scripts//mark.lua:147: attempt to index local 'pawn' (a nil value)
	--don't know when it happened though
	--I think it happen when the pawn we target dies from the attack that also mark.
	--But AddScript happen after, so the target is already dead (I guess)
	if pawn == nil then
		return
	end

	local missionData = missionData()
	if missionData == nil then
		return
	end

	--Shouldn't be useful anymore
	if missionData.markedPawnIds == nil then
		missionData.markedPawnIds = {}
	end

	table.insert(missionData.markedPawnIds, pawn:GetId())
end


function mark:removeMark(pawn)

	if pawn == nil then
		LOG("removeMark -> pawn is nil! -> return!")
		return
	end

	LOG("removeMark(pawn: " .. pawn:GetType() .. ", id: " .. pawn:GetId() .. ")")

	local missionData = missionData()
	if missionData == nil then
		return
	end

	--Shouldn't be useful anymore
	if missionData.markedPawnIds == nil then
		LOG("Initialized markedPawnIds (removeMark)")
		missionData.markedPawnIds = {} --test
	end

	--Hm I think I can use _ as the index value (might rename it to "i" or "index" actually)
	local index = 0
    for _, v in pairs(missionData.markedPawnIds) do
        if v == pawn:GetId() then
        	table.remove(missionData.markedPawnIds, index)
        	LOG("Successfuly found the pawn whose mark must be removed!")
        	break
        end
        index = index + 1
    end
	
end


--Is the public function that's supposed to be called
function mark:markEnemy(ret, spaceDamage, pawn)
	if pawn == nil then return end

	local pawnPos = pawn:GetSpace()
	if not self:canMark(pawnPos) then
		--LOG("can't mark this pawn! -> RETURN!")
		return
	end

	--Show mark
	spaceDamage.sImageMark = "combat/icons/truelch_mark_weapon_mark.png"

	--Mark enemy
	ret:AddScript([[
	    local pawn2 = Board:GetPawn(Point(]] .. pawnPos:GetString() .. [[))
	    mark:addMark(ret, pawn2)
	    if GAME.roninMark ~= nil then
	    	GAME.roninMark[pawn2:GetId()] = pawn2:GetId()
	    end
	]])
end


function mark:isPawnMarked(pawn)
	--TODO: check if the pawn exists, is alive, etc.

	if pawn == nil then
		return
	end

	local missionData = missionData()

	if missionData == nil then
		return
	end

	--Shouldn't be useful anymore
	if missionData.markedPawnIds == nil then
		LOG("Initialized markedPawnIds (isPawnMarked)")
		missionData.markedPawnIds = {} --test
	end

	--There got to be a more efficient way to accomplish this
	--if I use the table as a dictionary and I read directly the value of the key (pawn id)
    for _, v in pairs(missionData.markedPawnIds) do
        if v == pawn:GetId() then
            return true
        end
    end

    --New: tosx Mecha Ronins Hunter mark
    if GAME and
    	not Board:IsTipImage() and
    	GAME.roninMark ~= nil and
    	GAME.roninMark[Board:GetPawn(pawn:GetSpace()):GetId()] then
		--LOG("Iron fleet detected roninMark!")
		return true
	end

    return false
end

--------------------------------------------------- HOOKS / EVENTS ---------------------------------------------------
local function HOOK_onMissionStart(mission)
    --LOG("HOOK_onMissionStart()")
    --Initialize mark list
    local missionData = missionData()
    missionData.markedPawnIds = {}
end

local function HOOK_onMissionNextPhaseCreated(prevMission, nextMission)
	--LOG("Left mission " .. prevMission.ID .. ", going into " .. nextMission.ID) --is it also called for regular missions? I don't think so, but...	
    --Initialize mark list
    local missionData = missionData()
    missionData.markedPawnIds = {}
end

--------------------------------------------------- HOOKS / EVENTS SUBSCRIPTIONS ---------------------------------------------------

local markBoardIndex = 0
local frameDuration = 25
local frameCount = 0
modApi.events.onMissionUpdate:subscribe(function(mission)
	local allpawns = extract_table(Board:GetPawns(TEAM_ENEMY))
	for i, id in pairs(allpawns) do
		local point = Board:GetPawnSpace(id)
		local pawn = Board:GetPawn(point)
		if mark:isPawnMarked(pawn) then
			--Fake anim
			--Board:AddAnimation(point, "truelch_mark_board_b_"..tostring(markBoardIndex), 0.08) --it works!
			Board:AddAnimation(point, "truelch_mark_board_c_"..tostring(markBoardIndex), 0.08)
		end
	end

	--
	frameCount = frameCount + 1
	if frameCount > frameDuration then
		frameCount = 0
		markBoardIndex = markBoardIndex + 1
		if markBoardIndex > 2 then
			markBoardIndex = 0
		end
	end
end)

modApi.events.onTestMechEntered:subscribe(function()
    modApi:runLater(function()
        --Initialize mark list
	    local missionData = missionData()
	    missionData.markedPawnIds = {}
    end)
end)

local function EVENT_onModsLoaded()
    modApi:addMissionStartHook(HOOK_onMissionStart)
    modApi:addMissionNextPhaseCreatedHook(HOOK_onMissionNextPhaseCreated)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)


--------------------------------------------------- RETURN TABLE ---------------------------------------------------

return mark