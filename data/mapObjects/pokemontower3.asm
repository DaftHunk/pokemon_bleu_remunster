PokemonTower3Object:
	db $1 ; border block

	db 2 ; warps
	warp 3, 9, 0, POKEMONTOWER_2F
	warp 18, 9, 1, POKEMONTOWER_4F

	db 0 ; signs

	db 4 ; objects
	object SPRITE_MEDIUM, 12, 3, STAY, LEFT, 1, OPP_CHANNELER, 1
	object SPRITE_MEDIUM, 9, 8, STAY, DOWN, 2, OPP_CHANNELER, 2
	object SPRITE_MEDIUM, 10, 13, STAY, DOWN, 3, OPP_CHANNELER, 3
	object SPRITE_BALL, 12, 1, STAY, NONE, 4, ESCAPE_ROPE

	; warp-to
	warp_to 3, 9, POKEMONTOWER_3F_WIDTH ; POKEMONTOWER_2F
	warp_to 18, 9, POKEMONTOWER_3F_WIDTH ; POKEMONTOWER_4F
