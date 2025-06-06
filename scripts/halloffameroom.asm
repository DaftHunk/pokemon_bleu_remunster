HallofFameRoomScript:
	call EnableAutoTextBoxDrawing
	ld hl, HallofFameRoomScriptPointers
	ld a, [wHallOfFameRoomCurScript]
	jp CallFunctionInTable

HallofFameRoomScript_5a4aa:
	xor a
	ld [wJoyIgnore], a
	ld [wHallOfFameRoomCurScript], a
	ret

HallofFameRoomScriptPointers:
	dw HallofFameRoomScript0
	dw HallofFameRoomScript1
	dw HallofFameRoomScript2
	dw HallofFameRoomScript3

HallofFameRoomScript3:
	ret

HallofFameRoomScript2:
	predef SingleCPUSpeed	;deactivate 2x speed during hall of fame and credits as it may cause visual bugs
	
	call Delay3
	ld a, [wLetterPrintingDelayFlags]
	push af
	xor a
	ld [wJoyIgnore], a
	predef HallOfFamePC
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld hl, wFlags_D733
	res 1, [hl]
	inc hl
	set 0, [hl]
	xor a
	ld hl, wLoreleiCurScript
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wLanceCurScript], a
	ld [wHallOfFameRoomCurScript], a
	; Elite 4 events
	ResetEventRange ELITE4_EVENTS_START, ELITE4_CHAMPION_EVENTS_END, 1

	CheckEvent EVENT_ELITE_4_BEATEN
	; if elite 4 already beaten set rematch instead
	jr nz, .setRematch

	SetEvent EVENT_ELITE_4_BEATEN ;if the elite 4 have been beaten, set the event flag for it
	; After beating elite 4 level scaling is now enabled
	SetEvent EVENT_TRAINER_LVL_SCALING
.next
	xor a
	ld [wHallOfFameRoomCurScript], a
	ld a, PALLET_TOWN
	ld [wLastBlackoutMap], a
	callba SaveSAVtoSRAM
	ld b, 5
.delayLoop
	ld c, 600 / 5
	call DelayFrames
	dec b
	jr nz, .delayLoop
	call WaitForTextScrollButtonPress
;	jp Init
	jp SoftReset	;joenote - fix an issue where junk tiles display for 1 frame because SoftReset whites-out the screen

.setRematch
	SetEvent EVENT_ELITE_4_REMATCH_BEATEN
	jr .next

HallofFameRoomScript0:
	ld a, $ff
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RLEMovement5a528
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $1
	ld [wHallOfFameRoomCurScript], a
	ret

RLEMovement5a528:
	db D_UP,$5
	db $ff

HallofFameRoomScript1:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, $1
	ld [H_SPRITEINDEX], a
	call SetSpriteMovementBytesToFF
	ld a, SPRITE_FACING_LEFT
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	call Delay3
	xor a
	ld [wJoyIgnore], a
	inc a ; PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, $1
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, $ff
	ld [wJoyIgnore], a
	ld a, HS_UNKNOWN_DUNGEON_GUY
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, $2
	ld [wHallOfFameRoomCurScript], a
	ret

HallofFameRoomTextPointers:
	dw HallofFameRoomText1

HallofFameRoomText1:
	TX_FAR _HallofFameRoomText1
	db "@"
