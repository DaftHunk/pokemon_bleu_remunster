SafariZoneRestHouse3_h:
	db GATE ; tileset
	db SAFARI_ZONE_EAST_REST_HOUSE_HEIGHT, SAFARI_ZONE_EAST_REST_HOUSE_WIDTH ; dimensions (y, x)
	dw SafariZoneRestHouse3Blocks, SafariZoneRestHouse3TextPointers, SafariZoneRestHouse3Script ; blocks, texts, scripts
	db 0 ; connections
	dw SafariZoneRestHouse3Object ; objects
