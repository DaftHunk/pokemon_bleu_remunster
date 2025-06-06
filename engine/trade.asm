InternalClockTradeAnim:
; Do the trading animation with the player's gameboy on the left.
; In-game trades and internally clocked link cable trades use this.
	ld a, [wTradedPlayerMonSpecies]
	ld [wLeftGBMonSpecies], a
	ld a, [wTradedEnemyMonSpecies]
	ld [wRightGBMonSpecies], a
	ld de, InternalClockTradeFuncSequence
	jr TradeAnimCommon

ExternalClockTradeAnim:
; Do the trading animation with the player's gameboy on the right.
; Externally clocked link cable trades use this.
	ld a, [wTradedEnemyMonSpecies]
	ld [wLeftGBMonSpecies], a
	ld a, [wTradedPlayerMonSpecies]
	ld [wRightGBMonSpecies], a
	ld de, ExternalClockTradeFuncSequence

TradeAnimCommon:
	ld a, [wOptions]
	push af
	and SOUND_STEREO_BITS ; preserve speaker options
	ld [wOptions], a
	ld a, [hSCY]
	push af
	ld a, [hSCX]
	push af
	xor a
	ld [hSCY], a
	ld [hSCX], a
	push de
.loop
	pop de
	ld a, [de]
	cp $ff
	jr z, .done
	inc de
	push de
	ld hl, TradeFuncPointerTable
	add a
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, .loop
	push de
	jp hl ; call trade func, which will return to the top of the loop
.done
	pop af
	ld [hSCX], a
	pop af
	ld [hSCY], a
	pop af
	ld [wOptions], a
	ret

MACRO addtradefunc
\1TradeFunc::
	dw \1
	ENDM

MACRO tradefunc
	db (\1TradeFunc - TradeFuncPointerTable) / 2
	ENDM

; The functions in the sequences below are executed in order by TradeFuncCommon.
; They are from opposite perspectives. The external clock one makes use of
; Trade_SwapNames to swap the player and enemy names for some functions.

InternalClockTradeFuncSequence:
	tradefunc LoadTradingGFXAndMonNames
	tradefunc Trade_ShowPlayerMon
	tradefunc Trade_DrawOpenEndOfLinkCable
	tradefunc Trade_AnimateBallEnteringLinkCable
	tradefunc Trade_AnimLeftToRight
	tradefunc Trade_Delay100
	tradefunc Trade_ShowClearedWindow
	tradefunc PrintTradeWentToText
	tradefunc PrintTradeForSendsText
	tradefunc PrintTradeFarewellText
	tradefunc Trade_AnimRightToLeft
	tradefunc Trade_ShowClearedWindow
	tradefunc Trade_DrawOpenEndOfLinkCable
	tradefunc Trade_ShowEnemyMon
	tradefunc Trade_Delay100
	tradefunc Trade_Cleanup
	db $FF

ExternalClockTradeFuncSequence:
	tradefunc LoadTradingGFXAndMonNames
	tradefunc Trade_ShowClearedWindow
	tradefunc PrintTradeWillTradeText
	tradefunc PrintTradeFarewellText
	tradefunc Trade_SwapNames
	tradefunc Trade_AnimLeftToRight
	tradefunc Trade_SwapNames
	tradefunc Trade_ShowClearedWindow
	tradefunc Trade_DrawOpenEndOfLinkCable
	tradefunc Trade_ShowEnemyMon
	tradefunc Trade_SlideTextBoxOffScreen
	tradefunc Trade_ShowPlayerMon
	tradefunc Trade_DrawOpenEndOfLinkCable
	tradefunc Trade_AnimateBallEnteringLinkCable
	tradefunc Trade_SwapNames
	tradefunc Trade_AnimRightToLeft
	tradefunc Trade_SwapNames
	tradefunc Trade_Delay100
	tradefunc Trade_ShowClearedWindow
	tradefunc PrintTradeWentToText
	tradefunc Trade_Cleanup
	db $FF

TradeFuncPointerTable:
	addtradefunc LoadTradingGFXAndMonNames
	addtradefunc Trade_ShowPlayerMon
	addtradefunc Trade_DrawOpenEndOfLinkCable
	addtradefunc Trade_AnimateBallEnteringLinkCable
	addtradefunc Trade_ShowEnemyMon
	addtradefunc Trade_AnimLeftToRight
	addtradefunc Trade_AnimRightToLeft
	addtradefunc Trade_Delay100
	addtradefunc Trade_ShowClearedWindow
	addtradefunc PrintTradeWentToText
	addtradefunc PrintTradeForSendsText
	addtradefunc PrintTradeFarewellText
	addtradefunc PrintTradeTakeCareText
	addtradefunc PrintTradeWillTradeText
	addtradefunc Trade_Cleanup
	addtradefunc Trade_SlideTextBoxOffScreen
	addtradefunc Trade_SwapNames

Trade_Delay100:
	ld c, 100
	jp DelayFrames

Trade_CopyTileMapToVRAM:
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call Delay3
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ret

Trade_Delay80:
	ld c, 80
	jp DelayFrames

Trade_ClearTileMap:
	coord hl, 0, 0
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	ld a, " "
	jp FillMemory

LoadTradingGFXAndMonNames:
	call Trade_ClearTileMap
	call DisableLCD
	ld hl, TradingAnimationGraphics
	ld de, vChars2 + $310
	ld bc, TradingAnimationGraphicsEnd - TradingAnimationGraphics
	ld a, BANK(TradingAnimationGraphics)
	call FarCopyData2
	ld hl, TradingAnimationGraphics2
	ld de, vSprites + $7c0
	ld bc, TradingAnimationGraphics2End - TradingAnimationGraphics2
	ld a, BANK(TradingAnimationGraphics2)
	call FarCopyData2
	ld hl, vBGMap0
	ld bc, $800
	ld a, " "
	call FillMemory
	call ClearSprites
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld hl, wd730
	set 6, [hl] ; turn on instant text printing
	ld a, [wOnSGB]
	and a
	ld a, $e4 ; non-SGB OBP0
	jr z, .next
	ld a, $f0 ; SGB OBP0
.next
	ld [rOBP0], a
	call UpdateGBCPal_OBP0
	call EnableLCD
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, [wTradedPlayerMonSpecies]
	ld [wPokedexNum], a
	call GetMonName
	ld hl, wcd6d
	ld de, wcf4b
	ld bc, NAME_LENGTH
	call CopyData
	ld a, [wTradedEnemyMonSpecies]
	ld [wPokedexNum], a
	jp GetMonName

Trade_LoadMonPartySpriteGfx:
	ld a, %11010000
	ld [rOBP1], a
	call UpdateGBCPal_OBP1
	jpba LoadMonPartySpriteGfx

Trade_SwapNames:
	ld hl, wPlayerName
	ld de, wBuffer
	ld bc, NAME_LENGTH
	call CopyData
	ld hl, wLinkEnemyTrainerName
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData
	ld hl, wBuffer
	ld de, wLinkEnemyTrainerName
	ld bc, NAME_LENGTH
	jp CopyData

Trade_Cleanup:
	xor a
	call LoadGBPal
	ld hl, wd730
	res 6, [hl] ; turn off instant text printing
	ret

Trade_ShowPlayerMon:
	ld a, %10101011
	ld [rLCDC], a
	ld a, $50
	ld [hWY], a
	ld a, $86
	ld [rWX], a
	ld [hSCX], a
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	coord hl, 4, 0
	ld b, 6
	ld c, 10
	call TextBoxBorder
	call Trade_PrintPlayerMonInfoText
	ld b, vBGMap0 / $100
	call CopyScreenTileBufferToVRAM
	call ClearScreen
	ld a, [wTradedPlayerMonSpecies]
	call Trade_LoadMonSprite
	ld a, $7e
.slideScreenLoop
	push af
	call DelayFrame
	pop af
	ld [rWX], a
	ld [hSCX], a
	dec a
	dec a
	and a
	jr nz, .slideScreenLoop
	call Trade_Delay80
	ld a, TRADE_BALL_POOF_ANIM
	call Trade_ShowAnimation
	ld a, TRADE_BALL_DROP_ANIM
	call Trade_ShowAnimation ; clears mon pic
	ld a, [wTradedPlayerMonSpecies]
	call PlayCry
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ret

Trade_DrawOpenEndOfLinkCable:
	call Trade_ClearTileMap
	ld b, vBGMap0 / $100
	call CopyScreenTileBufferToVRAM
	ld b, SET_PAL_GENERIC
	call RunPaletteCommand

; This function call is pointless. It just copies blank tiles to VRAM that was
; already filled with blank tiles.
	ld hl, vBGMap1 + $8c
	call Trade_CopyCableTilesOffScreen

	ld a, $a0
	ld [hSCX], a
	call DelayFrame
	ld a, %10001011
	ld [rLCDC], a
	coord hl, 6, 2
	ld b, $7 ; open end of link cable tile ID list index
	call CopyTileIDsFromList_ZeroBaseTileID
	call Trade_CopyTileMapToVRAM
	ld a, SFX_HEAL_HP
	call PlaySound
	ld c, 20
.loop
	ld a, [hSCX]
	add 4
	ld [hSCX], a
	dec c
	jr nz, .loop
	ret

Trade_AnimateBallEnteringLinkCable:
	ld a, TRADE_BALL_SHAKE_ANIM
	call Trade_ShowAnimation
	ld c, 10
	call DelayFrames
	ld a, %11100100
	ld [rOBP0], a
	call UpdateGBCPal_OBP0
	xor a
	ld [wLinkCableAnimBulgeToggle], a
	lb bc, $20, $60
.moveBallInsideLinkCableLoop
	push bc
	xor a
	ld de, Trade_BallInsideLinkCableOAM
	call WriteOAMBlock
	ld a, [wLinkCableAnimBulgeToggle]
	xor $1
	ld [wLinkCableAnimBulgeToggle], a
	add $7e
	ld hl, wOAMBuffer + $02
	ld de, 4
	ld c, e
.cycleLinkCableBulgeTile
	ld [hl], a
	add hl, de
	dec c
	jr nz, .cycleLinkCableBulgeTile
	call Delay3
	pop bc
	ld a, c
	add $4
	ld c, a
	cp $a0
	jr nc, .ballSpriteReachedEdgeOfScreen
	ld a, SFX_TINK
	call PlaySound
	jr .moveBallInsideLinkCableLoop
.ballSpriteReachedEdgeOfScreen
	call ClearSprites
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearScreen
	ld b, $98
	call CopyScreenTileBufferToVRAM
	call Delay3
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ret

Trade_BallInsideLinkCableOAM:
	db $7E,$00,$7E,$20
	db $7E,$40,$7E,$60

Trade_ShowEnemyMon:
	ld a, TRADE_BALL_TILT_ANIM
	call Trade_ShowAnimation
	call Trade_ShowClearedWindow
	coord hl, 4, 10
	ld b, 6
	ld c, 10
	call TextBoxBorder
	call Trade_PrintEnemyMonInfoText
	call Trade_CopyTileMapToVRAM
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, [wTradedEnemyMonSpecies]
	call Trade_LoadMonSprite
	ld a, TRADE_BALL_POOF_ANIM
	call Trade_ShowAnimation
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, [wTradedEnemyMonSpecies]
	call PlayCry
	call Trade_Delay100
	coord hl, 4, 10
	lb bc, 8, 12
	call ClearScreenArea
	jp PrintTradeTakeCareText

Trade_AnimLeftToRight:
; Animates the mon moving from the left GB to the right one.
	ld a, $1
	ld [wTradedMonMovingRight], a
	ld a, %11100100
	ld [rOBP0], a
	call UpdateGBCPal_OBP0
	ld a, $54
	ld [wBaseCoordX], a
	ld a, $1c
	ld [wBaseCoordY], a
	ld a, [wLeftGBMonSpecies]
	ld [wcf91], a
	call Trade_InitGameboyTransferGfx
	call Trade_WriteCircledMonOAM
	call Trade_DrawLeftGameboy
	call Trade_CopyTileMapToVRAM
	call Trade_DrawCableAcrossScreen
	ld hl, vBGMap1 + $8c
	call Trade_CopyCableTilesOffScreen
	ld b, $6
	call Trade_AnimMonMoveHorizontal
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call Trade_DrawCableAcrossScreen
	ld b, $4
	call Trade_AnimMonMoveHorizontal
	call Trade_DrawRightGameboy
	ld b, $6
	call Trade_AnimMonMoveHorizontal
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	call Trade_AnimMonMoveVertical
	jp ClearSprites

Trade_AnimRightToLeft:
; Animates the mon moving from the right GB to the left one.
	xor a
	ld [wTradedMonMovingRight], a
	ld a, $64
	ld [wBaseCoordX], a
	ld a, $44
	ld [wBaseCoordY], a
	ld a, [wRightGBMonSpecies]
	ld [wcf91], a
	call Trade_InitGameboyTransferGfx
	call Trade_WriteCircledMonOAM
	call Trade_DrawRightGameboy
	call Trade_CopyTileMapToVRAM
	call Trade_DrawCableAcrossScreen
	ld hl, vBGMap1 + $94
	call Trade_CopyCableTilesOffScreen
	call Trade_AnimMonMoveVertical
	ld b, $6
	call Trade_AnimMonMoveHorizontal
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call Trade_DrawCableAcrossScreen
	ld b, $4
	call Trade_AnimMonMoveHorizontal
	call Trade_DrawLeftGameboy
	ld b, $6
	call Trade_AnimMonMoveHorizontal
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	jp ClearSprites

Trade_InitGameboyTransferGfx:
; Initialises the graphics for showing a mon moving between gameboys.
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearScreen
	;gbcnote - update pal for GBC
	ld b, SET_PAL_GENERIC
	call RunPaletteCommand
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	call Trade_LoadMonPartySpriteGfx
	call DelayFrame
	ld a, %10101011
	ld [rLCDC], a
	xor a
	ld [hSCX], a
	ld a, $90
	ld [hWY], a
	ret

Trade_DrawLeftGameboy:
	call Trade_ClearTileMap

; draw link cable
	coord hl, 11, 4
	ld a, $5d
	ld [hli], a
	ld a, $5e
	ld c, 8
.loop
	ld [hli], a
	dec c
	jr nz, .loop

; draw gameboy pic
	coord hl, 5, 3
	ld b, $6
	call CopyTileIDsFromList_ZeroBaseTileID

; draw text box with player name below gameboy pic
	coord hl, 4, 12
	ld b, 2
	ld c, 7
	call TextBoxBorder
	coord hl, 5, 14
	ld de, wPlayerName
	call PlaceString

	jp DelayFrame

Trade_DrawRightGameboy:
	call Trade_ClearTileMap

; draw horizontal segment of link cable
	coord hl, 0, 4
	ld a, $5e
	ld c, $e
.loop
	ld [hli], a
	dec c
	jr nz, .loop

; draw vertical segment of link cable
	ld a, $5f
	ld [hl], a
	ld de, SCREEN_WIDTH
	add hl, de
	ld a, $61
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld a, $60
	ld [hld], a
	ld a, $5d
	ld [hl], a

; draw gameboy pic
	coord hl, 7, 8
	ld b, $6
	call CopyTileIDsFromList_ZeroBaseTileID

; draw text box with enemy name above link cable
	coord hl, 6, 0
	ld b, 2
	ld c, 7
	call TextBoxBorder
	coord hl, 7, 2
	ld de, wLinkEnemyTrainerName
	call PlaceString

	jp DelayFrame

Trade_DrawCableAcrossScreen:
; Draws the link cable across the screen.
	call Trade_ClearTileMap
	coord hl, 0, 4
	ld a, $5e
	ld c, SCREEN_WIDTH
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	ret

Trade_CopyCableTilesOffScreen:
; This is used to copy the link cable tiles off screen so that the cable
; continues when the screen is scrolled.
	push hl
	coord hl, 0, 4
	call CopyToRedrawRowOrColumnSrcTiles
	pop hl
	ld a, h
	ld [hRedrawRowOrColumnDest + 1], a
	ld a, l
	ld [hRedrawRowOrColumnDest], a
	ld a, REDRAW_ROW
	ld [hRedrawRowOrColumnMode], a
	ld c, 10
	jp DelayFrames

Trade_AnimMonMoveHorizontal:
; Animates the mon going through the link cable horizontally over a distance of
; b 16-pixel units.
	ld a, [wTradedMonMovingRight]
	ld e, a
	ld d, $8
.scrollLoop
	ld a, e
	dec a
	jr z, .movingRight
; moving left
	ld a, [hSCX]
	sub $2
	jr .next
.movingRight
	ld a, [hSCX]
	add $2
.next
	ld [hSCX], a
	call DelayFrame
	dec d
	jr nz, .scrollLoop
	call Trade_AnimCircledMon
	dec b
	jr nz, Trade_AnimMonMoveHorizontal
	ret

Trade_AnimCircledMon:
; Cycles between the two animation frames of the mon party sprite, cycles
; between a circle and an oval around the mon sprite, and makes the cable flash.
	push de
	push bc
	push hl
	ld a, [rBGP]
	xor $3c ; make link cable flash
	ld [rBGP], a
	call UpdateGBCPal_BGP
	ld hl, wOAMBuffer + $02
	ld a, [hl]
	bit 2, a
	jr z, .firstFrame
	sub 8
.firstFrame
	add 4
	ld bc, 4
rept 3
	ld [hl], a
	add hl, bc
	inc a
endr
	ld [hl], a
	add hl, bc
	ld de, $4
	ld c, $10
.loop
	ld a, [hl]
	xor $40
	ld [hl], a
	add hl, de
	dec c
	jr nz, .loop
	pop hl
	pop bc
	pop de
	ret

Trade_WriteCircledMonOAM:
	callba WriteMonPartySpriteOAMBySpecies
	call Trade_WriteCircleOAM

Trade_AddOffsetsToOAMCoords:
	ld hl, wOAMBuffer
	ld c, $14
.loop
	ld a, [wBaseCoordY]
	add [hl]
	ld [hli], a
	ld a, [wBaseCoordX]
	add [hl]
	ld [hli], a
	inc hl
	inc hl
	dec c
	jr nz, .loop
	ret

Trade_AnimMonMoveVertical:
; Animates the mon going through the link cable vertically as well as
; horizontally for a bit. The last bit of horizontal movement (when moving
; right) or the first bit of horizontal movement (when moving left) are done
; here instead of Trade_AnimMonMoveHorizontal because this function moves the
; sprite itself rather than scrolling the screen around the sprite. Moving the
; sprite itself is necessary because the vertical segment of the link cable is
; to the right of the screen position that the mon sprite has when
; Trade_AnimMonMoveHorizontal is executing.
	ld a, [wTradedMonMovingRight]
	and a
	jr z, .movingLeft
; moving right
	lb bc, 4, 0 ; move right
	call .doAnim
	lb bc, 0, 10 ; move down
	jr .doAnim
.movingLeft
	lb bc, 0, -10 ; move up
	call .doAnim
	lb bc, -4, 0 ; move left
.doAnim
	ld a, b
	ld [wBaseCoordX], a
	ld a, c
	ld [wBaseCoordY], a
	ld d, $4
.loop
	call Trade_AddOffsetsToOAMCoords
	call Trade_AnimCircledMon
	ld c, 8
	call DelayFrames
	dec d
	jr nz, .loop
	ret

Trade_WriteCircleOAM:
; Writes the OAM blocks for the circle around the traded mon as it passes
; the link cable.
	ld hl, Trade_CircleOAMPointers
	ld c, $4
	xor a
.loop
	push bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	push hl
	inc a
	push af
	call WriteOAMBlock
	pop af
	pop hl
	pop bc
	dec c
	jr nz, .loop
	ret

Trade_CircleOAMPointers:
	dw Trade_CircleOAM0
	db $08,$08
	dw Trade_CircleOAM1
	db $18,$08
	dw Trade_CircleOAM2
	db $08,$18
	dw Trade_CircleOAM3
	db $18,$18

Trade_CircleOAM0:
	db $38,$10,$39,$10
	db $3A,$10,$3B,$10

Trade_CircleOAM1:
	db $39,$30,$38,$30
	db $3B,$30,$3A,$30

Trade_CircleOAM2:
	db $3A,$50,$3B,$50
	db $38,$50,$39,$50

Trade_CircleOAM3:
	db $3B,$70,$3A,$70
	db $39,$70,$38,$70

; a = species
Trade_LoadMonSprite:
	ld [wcf91], a
	ld [wd0b5], a
	ld [wWholeScreenPaletteMonSpecies], a
	ld b, SET_PAL_POKEMON_WHOLE_SCREEN
	ld c, 0
	call RunPaletteCommand
	ld a, [H_AUTOBGTRANSFERENABLED]
	xor $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call GetMonHeader
	coord hl, 7, 2
	call LoadFlippedFrontSpriteByMonIndex
	ld c, 10
	jp DelayFrames

Trade_ShowClearedWindow:
; clears the window and covers the BG entirely with the window
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearScreen
	ld a, %11100011
	ld [rLCDC], a
	ld a, $7
	ld [rWX], a
	xor a
	ld [hWY], a
	ld a, $90
	ld [hSCX], a
	ret

Trade_SlideTextBoxOffScreen:
; Slides the window right until it's off screen. The window usually just has
; a text box at the bottom when this is called. However, when this is called
; after Trade_ShowEnemyMon in the external clock sequence, there is a mon pic
; above the text box and it is also scrolled off the screen.
	ld c, 50
	call DelayFrames
.loop
	call DelayFrame
	ld a, [rWX]
	inc a
	inc a
	ld [rWX], a
	cp $a1
	jr nz, .loop
	call Trade_ClearTileMap
	ld c, 10
	call DelayFrames
	ld a, $7
	ld [rWX], a
	ret

PrintTradeWentToText:
	ld hl, TradeWentToText
	call PrintText
	ld c, 200
	call DelayFrames
	jp Trade_SlideTextBoxOffScreen

TradeWentToText:
	TX_FAR _TradeWentToText
	db "@"

PrintTradeForSendsText:
	ld hl, TradeForText
	call PrintText
	call Trade_Delay80
	ld hl, TradeSendsText
	call PrintText
	jp Trade_Delay80

TradeForText:
	TX_FAR _TradeForText
	db "@"

TradeSendsText:
	TX_FAR _TradeSendsText
	db "@"

PrintTradeFarewellText:
	ld hl, TradeWavesFarewellText
	call PrintText
	call Trade_Delay80
	ld hl, TradeTransferredText
	call PrintText
	call Trade_Delay80
	jp Trade_SlideTextBoxOffScreen

TradeWavesFarewellText:
	TX_FAR _TradeWavesFarewellText
	db "@"

TradeTransferredText:
	TX_FAR _TradeTransferredText
	db "@"

PrintTradeTakeCareText:
	ld hl, TradeTakeCareText
	call PrintText
	jp Trade_Delay80

TradeTakeCareText:
	TX_FAR _TradeTakeCareText
	db "@"

PrintTradeWillTradeText:
	ld hl, TradeWillTradeText
	call PrintText
	call Trade_Delay80
	ld hl, TradeforText
	call PrintText
	jp Trade_Delay80

TradeWillTradeText:
	TX_FAR _TradeWillTradeText
	db "@"

TradeforText:
	TX_FAR _TradeforText
	db "@"

Trade_ShowAnimation:
	ld [wAnimationID], a
	xor a
	ld [wAnimationType], a
	predef_jump MoveAnimation
