RocketHideout2_h:
	db FACILITY ; tileset
	db ROCKET_HIDEOUT_B2F_HEIGHT, ROCKET_HIDEOUT_B2F_WIDTH ; dimensions (y, x)
	dw RocketHideout2Blocks, RocketHideout2TextPointers, RocketHideout2Script ; blocks, texts, scripts
	db 0 ; connections
	dw RocketHideout2Object ; objects
