AskName:
	call SaveScreenTilesToBuffer1
	call GetPredefRegisters
	push hl
	ld a, [wIsInBattle]
	dec a
	coord hl, 0, 0
	ld b, 4
	ld c, 11
	call z, ClearScreenArea ; only if in wild battle
	ld a, [wcf91]
	ld [wPokedexNum], a
	call GetMonName
	
	;joenote - always ask to name if in nuzlocke mode
	ld a, [wUnusedD721]
	bit 6, a
	jr z, .notNuzlocke
	xor a
	ld [wCurrentMenuItem], a
	jr .skipAskName
.notNuzlocke
	
	ld hl, DoYouWantToNicknameText
	call PrintText
	coord hl, 14, 7
	lb bc, 8, 15
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID
.skipAskName
	pop hl
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declinedNickname
	ld a, [wUpdateSpritesEnabled]
	push af
	xor a
	ld [wUpdateSpritesEnabled], a
	push hl
	ld a, NAME_MON_SCREEN
	ld [wNamingScreenType], a
	call DisplayNamingScreen
	ld a, [wIsInBattle]
	and a
	jr nz, .inBattle
	call ReloadMapSpriteTilePatterns
.inBattle
	call LoadScreenTilesFromBuffer1
	pop hl
	pop af
	ld [wUpdateSpritesEnabled], a
	ld a, [wcf4b]
	cp "@"
	ret nz
.declinedNickname
	ld d, h
	ld e, l
	ld hl, wcd6d
	ld bc, NAME_LENGTH
	jp CopyData

DoYouWantToNicknameText:
	TX_FAR _DoYouWantToNicknameText
	db "@"

DisplayNameRaterScreen:
	ld hl, wBuffer
	xor a
	ld [wUpdateSpritesEnabled], a
	ld a, NAME_MON_SCREEN
	ld [wNamingScreenType], a
	call DisplayNamingScreen
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, [wcf4b]
	cp "@"
	jr z, .playerCancelled
	ld hl, wPartyMonNicks
	ld bc, NAME_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld e, l
	ld d, h
	ld hl, wBuffer
	ld bc, NAME_LENGTH
	call CopyData
	and a
	ret
.playerCancelled
	scf
	ret

DisplayNamingScreen:
	push hl
	ld hl, wd730
	set 6, [hl]
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	call UpdateSprites
	ld b, SET_PAL_GENERIC
	call RunPaletteCommand
	call LoadHpBarAndStatusTilePatterns
	call LoadEDTile
	callba LoadMonPartySpriteGfx
	coord hl, 0, 4
	ld b, 9
	ld c, 18
	call TextBoxBorder
	call PrintNamingText
	ld a, 3
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	ld [wLastMenuItem], a
	ld [wCurrentMenuItem], a
	ld a, $ff
	ld [wMenuWatchedKeys], a
	ld a, 7
	ld [wMaxMenuItem], a
	ld a, "@"
	ld [wcf4b], a
	xor a
	ld hl, wNamingScreenSubmitName
	ld [hli], a
	ld [hli], a
	ld [wAnimCounter], a
.selectReturnPoint
	call PrintAlphabet
	call GBPalNormal
.ABStartReturnPoint
	ld a, [wNamingScreenSubmitName]
	and a
	jr nz, .submitNickname
	call PrintNicknameAndUnderscores
.dPadReturnPoint
	call PlaceMenuCursor
.inputLoop
	ld a, [wCurrentMenuItem]
	push af
	callba AnimatePartyMon_ForceSpeed1
	pop af
	ld [wCurrentMenuItem], a
	call JoypadLowSensitivity
	ld a, [hJoyPressed]
	and a
	jr z, .inputLoop
	ld hl, .namingScreenButtonFunctions
.checkForPressedButton
	sla a
	jr c, .foundPressedButton
	inc hl
	inc hl
	inc hl
	inc hl
	jr .checkForPressedButton
.foundPressedButton
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push de
	jp hl

.submitNickname
	pop de
	ld hl, wcf4b
	ld bc, NAME_LENGTH
	call CopyData
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	call ClearSprites
	call RunDefaultPaletteCommand
	call GBPalNormal
	xor a
	ld [wAnimCounter], a
	ld hl, wd730
	res 6, [hl]
	ld a, [wIsInBattle]
	and a
	jp z, LoadTextBoxTilePatterns
	jpab LoadHudTilePatterns

.namingScreenButtonFunctions
	dw .dPadReturnPoint
	dw .pressedDown
	dw .dPadReturnPoint
	dw .pressedUp
	dw .dPadReturnPoint
	dw .pressedLeft
	dw .dPadReturnPoint
	dw .pressedRight
	dw .ABStartReturnPoint
	dw .pressedStart
	dw .selectReturnPoint
	dw .pressedSelect
	dw .ABStartReturnPoint
	dw .pressedB
	dw .ABStartReturnPoint
	dw .pressedA

.pressedA_changedCase
	pop de
	ld de, .selectReturnPoint
	push de
.pressedSelect
	ld a, [wAlphabetCase]
	xor $1
	ld [wAlphabetCase], a
	ret

.pressedStart
	ld a, 1
	ld [wNamingScreenSubmitName], a
	ret

.pressedA
	ld a, [wCurrentMenuItem]
	cp $5 ; "ED" row
	jr nz, .didNotPressED
	ld a, [wTopMenuItemX]
	cp $11 ; "ED" column
	jr z, .pressedStart
.didNotPressED
	ld a, [wCurrentMenuItem]
	cp $6 ; case switch row
	jr nz, .didNotPressCaseSwtich
	ld a, [wTopMenuItemX]
	cp $1 ; case switch column
	jr z, .pressedA_changedCase
.didNotPressCaseSwtich
	ld hl, wMenuCursorLocation
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
	ld a, [hl]
	ld [wNamingScreenLetter], a
	call CalcStringLength
	ld a, [wNamingScreenType]
	cp NAME_MON_SCREEN
	jr nc, .checkMonNameLength
	ld a, [wNamingScreenNameLength]
	cp $7 ; max length of player/rival names
	jr .checkNameLength
.checkMonNameLength
	ld a, [wNamingScreenNameLength]
	cp $a ; max length of pokemon nicknames
.checkNameLength
	jr c, .addLetter
	ret

.addLetter
	ld a, [wNamingScreenLetter]
	ld [hli], a
	ld [hl], "@"
	ld a, SFX_PRESS_AB
	call PlaySound
	ret
.pressedB
	ld a, [wNamingScreenNameLength]
	and a
	ret z
	call CalcStringLength
	dec hl
	ld [hl], "@"
	ret
.pressedRight
	ld a, [wCurrentMenuItem]
	cp $6
	ret z ; can't scroll right on bottom row
	ld a, [wTopMenuItemX]
	cp $11 ; max
	jp z, .wrapToFirstColumn
	inc a
	inc a
	jr .done
.wrapToFirstColumn
	ld a, $1
	jr .done
.pressedLeft
	ld a, [wCurrentMenuItem]
	cp $6
	ret z ; can't scroll right on bottom row
	ld a, [wTopMenuItemX]
	dec a
	jp z, .wrapToLastColumn
	dec a
	jr .done
.wrapToLastColumn
	ld a, $11 ; max
	jr .done
.pressedUp
	ld a, [wCurrentMenuItem]
	dec a
	ld [wCurrentMenuItem], a
	and a
	ret nz
	ld a, $6 ; wrap to bottom row
	ld [wCurrentMenuItem], a
	ld a, $1 ; force left column
	jr .done
.pressedDown
	ld a, [wCurrentMenuItem]
	inc a
	ld [wCurrentMenuItem], a
	cp $7
	jr nz, .wrapToTopRow
	ld a, $1
	ld [wCurrentMenuItem], a
	jr .done
.wrapToTopRow
	cp $6
	ret nz
	ld a, $1
.done
	ld [wTopMenuItemX], a
	jp EraseMenuCursor

LoadEDTile:
	ld de, ED_Tile
	ld hl, vFont + $700
;	ld bc, (ED_TileEnd - ED_Tile) / $8

	; to fix the graphical bug on poor emulators
	lb bc, BANK(ED_Tile), (ED_TileEnd - ED_Tile) / $8
;joenote - What's going on here is that the CPU is requesting the MBC to load bank 0 into $4000-$7fff.
;		- Normally this is complete nonsense because bank 0 is always loaded. 
;		- And official Nintendo cartridges will see this and load bank 1 instead.
;		- But inaccurate emulators and cheap flash cartridges will often allow the MBC to load bank 0 anyway.
;		- This results in a graphical bug.

	jp CopyVideoDataDouble

ED_Tile:
	INCBIN "gfx/tiles/ED_tile.1bpp"
ED_TileEnd:

PrintAlphabet:
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, [wAlphabetCase]
	and a
	ld de, LowerCaseAlphabet
	jr nz, .lowercase
	ld de, UpperCaseAlphabet
.lowercase
	coord hl, 2, 5
	lb bc, 5, 9 ; 5 rows, 9 columns
.outerLoop
	push bc
.innerLoop
	ld a, [de]
	ld [hli], a
	inc hl
	inc de
	dec c
	jr nz, .innerLoop
	ld bc, SCREEN_WIDTH + 2
	add hl, bc
	pop bc
	dec b
	jr nz, .outerLoop
	call PlaceString
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	jp Delay3

LowerCaseAlphabet:
	db "abcdefghijklmnopqrstuvwxyz àâéèêùûïîôçäöüë ,¥MAJUSCULES@"

UpperCaseAlphabet:
	db "ABCDEFGHIJKLMNOPQRSTUVWXYZ ×():;[]",$e1,$e2,"-?!♂♀/⠄,¥minuscules@"

PrintNicknameAndUnderscores:
	call CalcStringLength
	ld a, c
	ld [wNamingScreenNameLength], a
	coord hl, 10, 2
	lb bc, 1, 10
	call ClearScreenArea
	coord hl, 10, 2
	ld de, wcf4b
	call PlaceString
	coord hl, 10, 3
	ld a, [wNamingScreenType]
	cp NAME_MON_SCREEN
	jr nc, .pokemon1
	ld b, 7 ; player or rival max name length
	jr .playerOrRival1
.pokemon1
	ld b, 10 ; pokemon max name length
.playerOrRival1
	ld a, $76 ; underscore tile id
.placeUnderscoreLoop
	ld [hli], a
	dec b
	jr nz, .placeUnderscoreLoop
	ld a, [wNamingScreenType]
	cp NAME_MON_SCREEN
	ld a, [wNamingScreenNameLength]
	jr nc, .pokemon2
	cp 7 ; player or rival max name length
	jr .playerOrRival2
.pokemon2
	cp 10 ; pokemon max name length
.playerOrRival2
	jr nz, .emptySpacesRemaining
	; when all spaces are filled, force the cursor onto the ED tile
	call EraseMenuCursor
	ld a, $11 ; "ED" x coord
	ld [wTopMenuItemX], a
	ld a, $5 ; "ED" y coord
	ld [wCurrentMenuItem], a
	ld a, [wNamingScreenType]
	cp NAME_MON_SCREEN
	ld a, 9 ; keep the last underscore raised
	jr nc, .pokemon3
	ld a, 6 ; keep the last underscore raised
.pokemon3
.emptySpacesRemaining
	ld c, a
	ld b, $0
	coord hl, 10, 3
	add hl, bc
	ld [hl], $77 ; raised underscore tile id
	ret

; calculates the length of the string at wcf4b and stores it in c
CalcStringLength:
	ld hl, wcf4b
	ld c, $0
.loop
	ld a, [hl]
	cp "@"
	ret z
	inc hl
	inc c
	jr .loop

PrintNamingText:
	coord hl, 0, 1
	ld a, [wNamingScreenType]
	ld de, YourTextString
	and a
	jr z, .placeString
	ld de, RivalsTextString
	dec a
	jr z, .placeString
	ld a, [wcf91]
	ld [wMonPartySpriteSpecies], a
	push af
	callba WriteMonPartySpriteOAMBySpecies
	pop af
	ld [wPokedexNum], a
	call GetMonName
	coord hl, 4, 1
	call PlaceString
	coord hl, 1, 3
	ld de, NicknameTextString
	jr .placeString
.placeString
	jp PlaceString

YourTextString:
	db "Votre nom ?@"

RivalsTextString:
	db "Nom du rival ?@"

NameTextString:
	db "Nom ?@"

NicknameTextString:
	db "Surnom ?@"
