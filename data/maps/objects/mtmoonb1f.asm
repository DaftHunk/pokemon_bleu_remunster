MtMoonB1FObject:
	db $3 ; border block

	db 8 ; warps
	warp 5, 5, 2, MT_MOON_1F
	warp 17, 11, 0, MT_MOON_B2F
	warp 25, 9, 3, MT_MOON_1F
	warp 25, 15, 4, MT_MOON_1F
	warp 21, 17, 1, MT_MOON_B2F
	warp 13, 27, 2, MT_MOON_B2F
	warp 23, 3, 3, MT_MOON_B2F
	warp 27, 3, 2, -1

	db 0 ; signs

	db 2 ; objects
	object SPRITE_ROCKET, 23, 2, STAY, DOWN, 1, OPP_JESSIE_JAMES, 1
	object SPRITE_ROCKET, 24, 3, STAY, LEFT, 2, OPP_JESSIE_JAMES, 1 ; James

	; warp-to
	warp_to 5, 5, MT_MOON_B1F_WIDTH ; MT_MOON_1F
	warp_to 17, 11, MT_MOON_B1F_WIDTH ; MT_MOON_B2F
	warp_to 25, 9, MT_MOON_B1F_WIDTH ; MT_MOON_1F
	warp_to 25, 15, MT_MOON_B1F_WIDTH ; MT_MOON_1F
	warp_to 21, 17, MT_MOON_B1F_WIDTH ; MT_MOON_B2F
	warp_to 13, 27, MT_MOON_B1F_WIDTH ; MT_MOON_B2F
	warp_to 23, 3, MT_MOON_B1F_WIDTH ; MT_MOON_B2F
	warp_to 27, 3, MT_MOON_B1F_WIDTH
