SeafoamIslands2_h:
	db CAVERN ; tileset
	db SEAFOAM_ISLANDS_B1F_HEIGHT, SEAFOAM_ISLANDS_B1F_WIDTH ; dimensions (y, x)
	dw SeafoamIslands2Blocks, SeafoamIslands2TextPointers, SeafoamIslands2Script ; blocks, texts, scripts
	db 0 ; connections
	dw SeafoamIslands2Object ; objects
