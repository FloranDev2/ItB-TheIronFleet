testAction = Skill:new{
	--Infos
	Name = "Test Action",
	Description = "Test action.",
	Class = "TechnoVek",
	Icon = "weapons/truelch_burrower_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,--[[
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	]]
}

function testAction:GetTargetArea(point)
	local ret = PointList()
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			ret:push_back(curr)
		end
	end	
	return ret
end

function testAction:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	--[[
	if p2 ~= p1 then
		return
	end
	]]

	return ret
end