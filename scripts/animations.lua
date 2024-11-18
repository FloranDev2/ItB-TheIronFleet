--Radar sweep anim

--Opacity: 50 / 100 / 150 / 200
--Normal    :  0  1  2  3  4  5  6  7
--Appear    :  8  9 10 11 (50 / 100 / 150 / 200)
--Diseappear:             12 13 14 15 (200 / 150 / 100 / 50)
ANIMS.truelch_sweep_old_1 = Animation:new{
	Image = "combat/icons/OLD_truelch_radar_sweep_1.png",
	PosX = -85,
	PosY = -41,
	Time = 0.25, --0.08,
	NumFrames = 16,
	Frames = { 8,  9, 10, 11, 4,  5,  6,  7,
			   0,  1, 2,  3,  4,  5,  6,  7,
			   0,  1, 2,  3, 12, 13, 14, 15 },
}

ANIMS.truelch_sweep_1 = Animation:new{
	Image = "combat/icons/truelch_radar_sweep_1.png",
	PosX = -85,
	PosY = -41,
	Time = 0.10,
	NumFrames = 16,
}

--That could also work, right?
--[[
ANIMS.truelch_sweep_2 = truelch_sweep_1:new{
	Image = "combat/icons/truelch_radar_sweep_2.png",
}
]]

ANIMS.truelch_sweep_old_2 = Animation:new{
	Image = "combat/icons/OLD_truelch_radar_sweep_2.png",
	PosX = -85,
	PosY = -41,
	Time = 0.08,
	NumFrames = 16,
  	Frames = { 8,  9, 10, 11, 4,  5,  6,  7,
			   0,  1, 2,  3,  4,  5,  6,  7,
			   0,  1, 2,  3, 12, 13, 14, 15 },
}

ANIMS.truelch_sweep_2 = Animation:new{
	Image = "combat/icons/truelch_radar_sweep_2.png",
	PosX = -85,
	PosY = -41,
	Time = 0.08,
	NumFrames = 16,
}

--[[
---"Real" animations, used for tip image
ANIMS.truelch_tip_mark = Animation:new{
	Image = "combat/icons/truelch_mark_board_c.png",
	PosX = -15,
	PosY = 6,
	Time = 0.2,
	NumFrames = 3,
	Frames = { 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2 },
}
]]