PokemonTower7_h:
	db CEMETERY ; tileset
	db POKEMONTOWER_7F_HEIGHT, POKEMONTOWER_7F_WIDTH ; dimensions (y, x)
	dw PokemonTower7Blocks, PokemonTower7TextPointers, PokemonTower7Script ; blocks, texts, scripts
	db 0 ; connections
	dw PokemonTower7Object ; objects
