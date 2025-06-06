SeafoamIslands3Object:
	db $7d ; border block

	db 7 ; warps
	warp 5, 3, 0, SEAFOAM_ISLANDS_B1F
	warp 5, 13, 0, SEAFOAM_ISLANDS_B3F
	warp 13, 7, 2, SEAFOAM_ISLANDS_B1F
	warp 19, 15, 3, SEAFOAM_ISLANDS_B1F
	warp 25, 3, 3, SEAFOAM_ISLANDS_B3F
	warp 25, 11, 5, SEAFOAM_ISLANDS_B1F
	warp 25, 14, 4, SEAFOAM_ISLANDS_B3F

	db 0 ; signs

	db 2 ; objects
	object SPRITE_BOULDER, 18, 6, STAY, BOULDER_MOVEMENT_BYTE_2, 1 ; person
	object SPRITE_BOULDER, 23, 6, STAY, BOULDER_MOVEMENT_BYTE_2, 2 ; person

	; warp-to
	warp_to 5, 3, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B1F
	warp_to 5, 13, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B3F
	warp_to 13, 7, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B1F
	warp_to 19, 15, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B1F
	warp_to 25, 3, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B3F
	warp_to 25, 11, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B1F
	warp_to 25, 14, SEAFOAM_ISLANDS_B2F_WIDTH ; SEAFOAM_ISLANDS_B3F
