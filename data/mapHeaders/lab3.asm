Lab3_h:
	db LAB ; tileset
	db CINNABAR_LAB_METRONOME_ROOM_HEIGHT, CINNABAR_LAB_METRONOME_ROOM_WIDTH ; dimensions (y, x)
	dw Lab3Blocks, Lab3TextPointers, Lab3Script ; blocks, texts, scripts
	db 0 ; connections
	dw Lab3Object ; objects
