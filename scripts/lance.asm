LanceScript:
	call LanceShowOrHideEntranceBlocks
	call EnableAutoTextBoxDrawing
	ld hl, LanceTrainerHeader0
	ld de, LanceScriptPointers
	ld a, [wLanceCurScript]
	call ExecuteCurMapScriptInTable
	ld [wLanceCurScript], a
	ret

LanceShowOrHideEntranceBlocks:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	ret z
	CheckEvent EVENT_LANCES_ROOM_LOCK_DOOR
	jr nz, .closeEntrance
	; open entrance
	ld a, $31
	ld b, $32
	jp LanceSetEntranceBlocks
.closeEntrance
	ld a, $72
	ld b, $73

LanceSetEntranceBlocks:
; Replaces the tile blocks so the player can't leave.
	push bc
	ld [wNewTileBlockID], a
	lb bc, 6, 2
	call LanceSetEntranceBlock
	pop bc
	ld a, b
	ld [wNewTileBlockID], a
	lb bc, 6, 3

LanceSetEntranceBlock:
	predef_jump ReplaceTileBlock

ResetLanceScript:
	xor a
	ld [wLanceCurScript], a
	ret

LanceScriptPointers:
	dw LanceScript0
	dw DisplayEnemyTrainerTextAndStartBattle
	dw LanceScript2
	dw LanceScript3
	dw LanceScript4

LanceScript4:
	ret

LanceScript0:
	CheckEvent EVENT_BEAT_LANCE
	ret nz
	CheckEvent EVENT_ELITE_4_BEATEN
	jr nz, .elite4Rematch
	jr .continueScript
.elite4Rematch
	ld a, HS_LANCE_1
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_LANCE_2
	ld [wMissableObjectIndex], a
	predef ShowObject2
	jr .continueScript
.continueScript
	ld hl, LanceTriggerMovementCoords
	call ArePlayerCoordsInArray
	jp nc, CheckFightingMapTrainers
	xor a
	ld [hJoyHeld], a
	ld a, [wCoordIndex]
	cp $3  ; Is player standing next to Lance's sprite?
	jr nc, .notStandingNextToLance
	
	call .DoFacings	;joenote - correct the facing
	
	CheckEvent EVENT_ELITE_4_BEATEN
	jr nz, .startRematch

	ld a, $1
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
.startRematch
	ld a, $2
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
.notStandingNextToLance
	cp $5  ; Is player standing on the entrance staircase?
	jr z, WalkToLance
	CheckAndSetEvent EVENT_LANCES_ROOM_LOCK_DOOR
	ret nz
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	ld a, SFX_GO_INSIDE
	call PlaySound
	jp LanceShowOrHideEntranceBlocks

.DoFacings
; joenote: Added from PureRGB. When about to fight Lance, he and the player will face each other properly to talk.
	ld a, [wYCoord]
	cp 1
	jr z, .leftOfLance
	ld a, PLAYER_DIR_UP
	ld [wPlayerMovingDirection], a
	ret
.leftOfLance
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, 1
	ld [H_SPRITEINDEX], a
	ld a, SPRITE_FACING_LEFT
  	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirection
	ld a, 2
	ld [H_SPRITEINDEX], a
	ld a, SPRITE_FACING_LEFT
  	ld [hSpriteFacingDirection], a
  	jp SetSpriteFacingDirection

LanceTriggerMovementCoords:
	db $01,$05
	db $02,$06
	db $0B,$05
	db $0B,$06
	db $10,$18
	db $FF

LanceScript2:
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jp z, ResetLanceScript

	CheckEvent EVENT_ELITE_4_BEATEN
	jr nz, .elite4Rematch

	ld a, $1
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
.elite4Rematch
	ld a, $2
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID

WalkToLance:
; Moves the player down the hallway to Lance's room.
	ld a, $ff
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, WalkToLance_RLEList
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $3
	ld [wLanceCurScript], a
	ld [wCurMapScript], a
	ret

WalkToLance_RLEList:
	db D_UP, $0C
	db D_LEFT, $0C
	db D_DOWN, $07
	db D_LEFT, $06
	db $FF

LanceScript3:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a
	ld [wJoyIgnore], a
	ld [wLanceCurScript], a
	ld [wCurMapScript], a
	ret

LanceTextPointers:
	dw LanceText1
	dw LanceText2

LanceTrainerHeader0:
	dbEventFlagBit EVENT_BEAT_LANCES_ROOM_TRAINER_0
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_LANCES_ROOM_TRAINER_0
	dw LanceBeforeBattleText ; TextBeforeBattle
	dw LanceAfterBattleText ; TextAfterBattle
	dw LanceEndBattleText ; TextEndBattle
	dw LanceEndBattleText ; TextEndBattle
LanceTrainerHeader1:
	dbEventFlagBit EVENT_BEAT_LANCES_ROOM_TRAINER_0
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_LANCES_ROOM_TRAINER_0
	dw RematchLanceBeforeBattleText ; TextBeforeBattle
	dw RematchLanceAfterBattleText ; TextAfterBattle
	dw RematchLanceEndBattleText ; TextEndBattle
	dw RematchLanceEndBattleText ; TextEndBattle

	db $ff

LanceText1:
	TX_ASM
	ld hl, LanceTrainerHeader0
	ld a, 8
	ld [wGymLeaderNo], a	;joenote - use gym leader music
	call TalkToTrainer
	jp TextScriptEnd

LanceText2:
	TX_ASM
	ld hl, LanceTrainerHeader1
	ld a, 8
	ld [wGymLeaderNo], a	;joenote - use gym leader music
	call TalkToTrainer
	jp TextScriptEnd

LanceBeforeBattleText:
	TX_FAR _LanceBeforeBattleText
	db "@"

LanceEndBattleText:
	TX_FAR _LanceEndBattleText
	db "@"

LanceAfterBattleText:
	TX_FAR _LanceAfterBattleText
	TX_ASM
	SetEvent EVENT_BEAT_LANCE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - if you have a dragonite in your first slot, let it learn fly
	ld a, [wPartyMon1Species]
	cp DRAGONITE
	jp nz, TextScriptEnd
	ld a, [wPartyMon1CatchRate]
	cp 168
	jp z, TextScriptEnd
	ld a, DRAGONITE
	call PlayCry
	ld a, 168
	ld [wPartyMon1CatchRate], a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jp TextScriptEnd

RematchLanceBeforeBattleText:
	TX_FAR _RematchLanceBeforeBattleText
	db "@"

RematchLanceEndBattleText:
	TX_FAR _RematchLanceEndBattleText
	db "@"

RematchLanceAfterBattleText:
	TX_FAR _RematchLanceAfterBattleText
	TX_ASM
	SetEvent EVENT_BEAT_LANCE
	jp TextScriptEnd