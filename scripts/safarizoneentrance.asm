SafariZoneEntranceScript:
	call EnableAutoTextBoxDrawing
	ld hl, SafariZoneEntranceScriptPointers
	ld a, [wSafariZoneEntranceCurScript]
	jp CallFunctionInTable

SafariZoneEntranceScriptPointers:
	dw .SafariZoneEntranceScript0
	dw .SafariZoneEntranceScript1
	dw .SafariZoneEntranceScript2
	dw .SafariZoneEntranceScript3
	dw .SafariZoneEntranceScript4
	dw .SafariZoneEntranceScript5
	dw .SafariZoneEntranceScript6

.SafariZoneEntranceScript0
	ld hl, .CoordsData_75221
	call ArePlayerCoordsInArray
	ret nc
	ld a, $4	;$3 joenote - shifting text scripts
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, $ff
	ld [wJoyIgnore], a
	xor a
	ld [hJoyHeld], a
	ld a, SPRITE_FACING_RIGHT
	ld [wSpriteStateData1 + 9], a
	ld a, [wCoordIndex]
	cp $1
	jr z, .asm_7520f
	ld a, $2
	ld [wSafariZoneEntranceCurScript], a
	ret
.asm_7520f
	ld a, D_RIGHT
	ld c, $1
	call SafariZoneEntranceAutoWalk
	ld a, $f0
	ld [wJoyIgnore], a
	ld a, $1
	ld [wSafariZoneEntranceCurScript], a
	ret

.CoordsData_75221:
	db $02,$03
	db $02,$04
	db $FF

.SafariZoneEntranceScript1
	call SafariZoneEntranceScript_752b4
	ret nz
.SafariZoneEntranceScript2
	xor a
	ld [hJoyHeld], a
	ld [wJoyIgnore], a
	call UpdateSprites
	ld a, $5 ;$4	joenote - shifting text scripts
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, $ff
	ld [wJoyIgnore], a
	ret

.SafariZoneEntranceScript3
	call SafariZoneEntranceScript_752b4
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, $5
	ld [wSafariZoneEntranceCurScript], a
	ret

.SafariZoneEntranceScript5
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerMovingDirection], a
	CheckAndResetEvent EVENT_SAFARI_GAME_OVER
	jr z, .asm_7527f
	ResetEventReuseHL EVENT_IN_SAFARI_ZONE
	call UpdateSprites
	ld a, $f0
	ld [wJoyIgnore], a
	ld a, $7 ;$6	joenote - shifting text scripts
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ld [wNumSafariBalls], a
	ld a, D_DOWN
	ld c, $3
	call SafariZoneEntranceAutoWalk
	ld a, $4
	ld [wSafariZoneEntranceCurScript], a
	jr .asm_75286
.asm_7527f
	ld a, $6 ;$5 joenote - shifting text scripts
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
.asm_75286
	ret

.SafariZoneEntranceScript4
	call SafariZoneEntranceScript_752b4
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, $0
	ld [wSafariZoneEntranceCurScript], a
	ret

.SafariZoneEntranceScript6
	call SafariZoneEntranceScript_752b4
	ret nz
	call .CheckSafariStatus
	call Delay3
	ld a, [wcf0d]
	ld [wSafariZoneEntranceCurScript], a
	ret
.CheckSafariStatus	;joenote - data in wcf0d isn't part of the game save, so a check needs to be done.
	CheckEvent EVENT_SAFARI_GAME_OVER
	ret nz
	CheckEvent EVENT_IN_SAFARI_ZONE
	ret z
	;if the safari event is going on but not in game-over, then wcf0d needs to hold $05
	ld a, 5
	ld [wcf0d], a
	ret

SafariZoneEntranceAutoWalk:
	push af
	ld b, 0
	ld a, c
	ld [wSimulatedJoypadStatesIndex], a
	ld hl, wSimulatedJoypadStatesEnd
	pop af
	call FillMemory
	jp StartSimulatingJoypadStates

SafariZoneEntranceScript_752b4:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret

SafariZoneEntranceTextPointers:
	dw .SafariZoneEntranceText1
	dw .SafariZoneEntranceText2
	dw .SafariZoneSpecialEventText
	dw .SafariZoneEntranceText1
	dw .SafariZoneEntranceText4
	dw .SafariZoneEntranceText5
	dw .SafariZoneEntranceText6
	
.SafariZoneEntranceText1
	TX_FAR _SafariZoneEntranceText1
	db "@"

.SafariZoneEntranceText4
	TX_FAR SafariZoneEntranceText_9e6e4
	TX_ASM
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .PleaseComeAgain
	xor a
	ld [hMoney], a
	ld a, $05
	ld [hMoney + 1], a
	ld a, $00
	ld [hMoney + 2], a
	call HasEnoughMoney
	jr nc, .success
	ld hl, .NotEnoughMoneyText
	call PrintText
	jr .CantPayWalkDown

.success
	xor a
	ld [wPriceTemp], a
	ld a, $05
	ld [wPriceTemp + 1], a
	ld a, $00
	ld [wPriceTemp + 2], a
	ld hl, wPriceTemp + 2
	ld de, wPlayerMoney + 2
	ld c, 3
	predef SubBCDPredef
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	ld hl, .MakePaymentText
	call PrintText
	predef ResetAreaFlag_NuzlockePredef	;joenote - for nuzlocke, reset safari area encounter flag upon payment
;joedebug - safari zone starts here
	ld a, 30
	ld [wNumSafariBalls], a
	ld a, 502 / $100
	ld [wSafariSteps], a
	ld a, 502 % $100
	ld [wSafariSteps + 1], a
	ld a, D_UP
	ld c, 3
	call SafariZoneEntranceAutoWalk
	SetEvent EVENT_IN_SAFARI_ZONE
	ResetEventReuseHL EVENT_SAFARI_GAME_OVER
	ld a, 3
	ld [wSafariZoneEntranceCurScript], a
	jr .done

.PleaseComeAgain
	ld hl, .PleaseComeAgainText
	call PrintText
.CantPayWalkDown
	ld a, D_DOWN
	ld c, 1
	call SafariZoneEntranceAutoWalk
	ld a, 4
	ld [wSafariZoneEntranceCurScript], a
.done
	jp TextScriptEnd

.MakePaymentText
	TX_FAR SafariZoneEntranceText_9e747
	TX_SFX_ITEM_1
	TX_FAR _SafariZoneEntranceText_75360
	db "@"

.PleaseComeAgainText
	TX_FAR _SafariZoneEntranceText_75365
	db "@"

.NotEnoughMoneyText
	TX_FAR _SafariZoneEntranceText_7536a
	db "@"

.SafariZoneEntranceText5
	TX_FAR SafariZoneEntranceText_9e814
	TX_ASM
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .asm_7539c
	ld hl, .SafariZoneEntranceText_753bb
	call PrintText
	xor a
	ld [wSpriteStateData1 + 9], a
	ld a, D_DOWN
	ld c, $3
	call SafariZoneEntranceAutoWalk
	ResetEvents EVENT_SAFARI_GAME_OVER, EVENT_IN_SAFARI_ZONE
	ld a, $0
	ld [wcf0d], a
	jr .asm_753b3
.asm_7539c
	ld hl, .SafariZoneEntranceText_753c0
	call PrintText
	ld a, SPRITE_FACING_UP
	ld [wSpriteStateData1 + 9], a
	ld a, D_UP
	ld c, $1
	call SafariZoneEntranceAutoWalk
	ld a, $5
	ld [wcf0d], a
.asm_753b3
	ld a, $6
	ld [wSafariZoneEntranceCurScript], a
	jp TextScriptEnd

.SafariZoneEntranceText_753bb
	TX_FAR _SafariZoneEntranceText_753bb
	db "@"

.SafariZoneEntranceText_753c0
	TX_FAR _SafariZoneEntranceText_753c0
	db "@"

.SafariZoneEntranceText6
	TX_FAR _SafariZoneEntranceText_753c5
	db "@"

.SafariZoneEntranceText2
	TX_ASM
	ld hl, .FirstTimeQuestionText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, .RegularText
	jr nz, .Explanation
	ld hl, .ExplanationText
.Explanation
	call PrintText
	jp TextScriptEnd

.FirstTimeQuestionText
	TX_FAR _SafariZoneEntranceText_753e6
	db "@"

.ExplanationText
	TX_FAR _SafariZoneEntranceText_753eb
	db "@"

.RegularText
	TX_FAR _SafariZoneEntranceText_753f0
	db "@"


	

;joenote - allow for special safari settings
;Makes safari mons have 9888 DVs at the lowest
;Also adds random mons into areas
;Available after the elite 4
.SafariZoneSpecialEventText
	TX_ASM
	CheckEvent EVENT_ELITE_4_BEATEN
	ld hl, .NotReady
	jr z, .end
	
	CheckEvent EVENT_SPECIAL_SAFARI_ZONE
	jr nz, .activeevent
	
	ld hl, .Ready
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	call z, .setevent
	ld hl, SafariZoneEntranceTextPointers.SafariZoneEntranceText_753c0
	jr .end

.activeevent	
	ld hl, .alreadyactive
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	call z, .resetevent
	ld hl, SafariZoneEntranceTextPointers.SafariZoneEntranceText_753c0

	.end
	call PrintText
	jp TextScriptEnd
.setevent
	SetEvent EVENT_SPECIAL_SAFARI_ZONE	;turn on special safari event
	ret
.resetevent
	ResetEvent EVENT_SPECIAL_SAFARI_ZONE	;turn off special safari event
	ret
.NotReady
	TX_FAR _SafariZoneEntranceTextSpecial_NotReady
	db "@"
.Ready
	TX_FAR _SafariZoneEntranceTextSpecial_Ready
	db "@"
.alreadyactive
	TX_FAR _SafariZoneEntranceTextSpecial_Active
	db "@"
	
