; try to initiate a wild pokemon encounter
; returns success in Z
TryDoWildEncounter:
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret nz
	ld a, [wd736]
	and a
	ret nz
	callab IsPlayerStandingOnDoorTileOrWarpTile
	jr nc, .notStandingOnDoorOrWarpTile
.CantEncounter
	ld a, $1
	and a
	ret
.notStandingOnDoorOrWarpTile
	callab IsPlayerJustOutsideMap
	jr z, .CantEncounter
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .next
	dec a
	jp z, .lastRepelStep
	ld [wRepelRemainingSteps], a
.next
; determine if wild pokemon can appear in the half-block we're standing in
; is the encounter tile of the half-block we're standing in a grass/water tile?
;joenote - modified to use constants to keep everything consistent and avoid missingno glitch
	coord hl, ENCOUNTER_TILE_COORD_X, ENCOUNTER_TILE_COORD_Y
	ld c, [hl]
	ld a, [wGrassTile]
	cp c
	ld a, [wGrassRate]
	jr z, .CanEncounter
	ld a, $14 ; in all tilesets with a water tile, this is its id
	cp c
	ld a, [wWaterRate]
	jr z, .CanEncounter
; even if not in grass/water, standing anywhere we can encounter pokemon
; so long as the map is "indoor" and has wild pokemon defined.
; ...as long as it's not Viridian Forest or Safari Zone.
	ld a, [wCurMap]
	cp REDS_HOUSE_1F ; is this an indoor map?
	jr c, .CantEncounter2
	ld a, [wCurMapTileset]
	cp FOREST ; Viridian Forest/Safari Zone
	jr z, .CantEncounter2
	ld a, [wGrassRate]
.CanEncounter
; compare encounter chance with a random number to determine if there will be an encounter
	ld b, a
	ld a, [hRandomAdd]
	cp b
	jr nc, .CantEncounter2
	ld a, [hRandomSub]
	ld b, a
	ld hl, WildMonEncounterSlotChances
.determineEncounterSlot
	ld a, [hli]
	cp b
	jr nc, .gotEncounterSlot
	inc hl
	jr .determineEncounterSlot
.gotEncounterSlot
; determine which wild pokemon (grass or water) can appear in the half-block we're standing in
	ld c, [hl]
	ld hl, wGrassMons
;joenote - modified to use constants to keep everything consistent and avoid missingno glitch
	aCoord ENCOUNTER_TILE_COORD_X, ENCOUNTER_TILE_COORD_Y
	cp $14 ; is the encounter tile of the half-block we're standing in a water tile?
	jr nz, .gotWildEncounterType ; if not, it's treated as a grass tile by default
	ld hl, wWaterMons
; since the bottom right tile of a "left shore" half-block used to be $14 but the bottom left tile was not,
; "left shore" half-blocks (such as the one in the east coast of Cinnabar) loaded grass encounters & gave missingno.
.gotWildEncounterType
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld [wCurEnemyLVL], a
	ld a, [hl]
	ld [wcf91], a
	ld [wEnemyMonSpecies2], a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - expand the safari zone random encounters
;	callba GetRandMonSafari
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - check for shiny DV attract conditions
	callba ShinyAttractFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;joenote - generate a random wild pokemon based on a seed value
	predef ReplaceWildMon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .willEncounter
	ld a, [wPartyMon1Level]
	ld b, a
	ld a, [wCurEnemyLVL]
	cp b
;	jr c, .CantEncounter2 ; repel prevents encounters if the leading party mon's level is higher than the wild mon
	jr c, .shinycheck_repel
	jr .willEncounter
.lastRepelStep
	ld [wRepelRemainingSteps], a
	ld a, TEXT_REPEL_WORE_OFF
	ld [hSpriteIndexOrTextID], a
	call EnableAutoTextBoxDrawing
	call DisplayTextID
.CantEncounter2
	ld a, $1
	and a
	ret
.willEncounter
	xor a
	ret
.shinycheck_repel
;joenote - initiate encounter if shiny (overrides repel)
	ld a, [wFontLoaded]
	bit 7, a
	jr nz, .willEncounter
	jr .CantEncounter2
	
WildMonEncounterSlotChances:
; There are 10 slots for wild pokemon, and this is the table that defines how common each of
; those 10 slots is. A random number is generated and then the first byte of each pair in this
; table is compared against that random number. If the random number is less than or equal
; to the first byte, then that slot is chosen.  The second byte is double the slot number.
	db $32, $00 ; 51/256 = 19.9% chance of slot 0
	db $65, $02 ; 51/256 = 19.9% chance of slot 1
	db $8C, $04 ; 39/256 = 15.2% chance of slot 2
	db $A5, $06 ; 25/256 =  9.8% chance of slot 3
	db $BE, $08 ; 25/256 =  9.8% chance of slot 4
	db $D7, $0A ; 25/256 =  9.8% chance of slot 5
	db $E4, $0C ; 13/256 =  5.1% chance of slot 6
	db $F1, $0E ; 13/256 =  5.1% chance of slot 7
	db $FC, $10 ; 11/256 =  4.3% chance of slot 8
	db $FF, $12 ;  3/256 =  1.2% chance of slot 9
