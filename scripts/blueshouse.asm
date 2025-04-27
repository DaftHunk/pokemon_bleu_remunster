BluesHouseScript:
	call EnableAutoTextBoxDrawing
	ld hl, BluesHouseScriptPointers
	ld a, [wBluesHouseCurScript]
	jp CallFunctionInTable

BluesHouseScriptPointers:
	dw BluesHouseScript0
	dw BluesHouseScript1

BluesHouseScript0:
	SetEvent EVENT_ENTERED_BLUES_HOUSE

	; trigger the next script
	ld a, 1
	ld [wBluesHouseCurScript], a
	ret

BluesHouseScript1:
	ret

BluesHouseTextPointers:
	dw BluesHouseText1
	dw BluesHouseText2
	dw BluesHouseText3

BluesHouseText1:
	TX_ASM
	CheckEvent EVENT_GOT_TOWN_MAP
	jr nz, .GotMap
	CheckEvent EVENT_GOT_POKEDEX
	jr nz, .GiveMap
	ld hl, DaisyInitialText
	call PrintText
	jr .done

.GiveMap
	ld hl, DaisyOfferMapText
	call PrintText
	ld a, HS_TOWN_MAP
	ld [wMissableObjectIndex], a
	predef HideObject ; hide table map object
	ld hl, GotMapText
	call PrintText
	SetEvent EVENT_GOT_TOWN_MAP
	jr .done

.GotMap
	ld hl, DaisyUseMapText
	call PrintText
	jr .done

.done
	jp TextScriptEnd

DaisyInitialText:
	TX_FAR _DaisyInitialText
	db "@"

DaisyOfferMapText:
	TX_FAR _DaisyOfferMapText
	db "@"

GotMapText:
	TX_FAR _GotMapText
	TX_SFX_KEY_ITEM
	TX_FAR _GotMapTextHint
	db "@"

DaisyUseMapText:
	TX_FAR _DaisyUseMapText
	db "@"

BluesHouseText2: ; Daisy, walking around
	TX_ASM
	CheckEvent EVENT_ELITE_4_BEATEN
	jr nz, .afterElite4
	; else
	ld hl, .beforeElite4Text
	jp .done
.beforeElite4Text
	TX_FAR _BluesHouseText2
	db "@"
.afterElite4
	ld hl, .afterElite4Text
	jp .done
.afterElite4Text
	TX_FAR _BluesHouseText2AfterElite4
	db "@"
.done
	call PrintText
	jp TextScriptEnd

BluesHouseText3: ; map on table
	TX_FAR _BluesHouseText3
	db "@"
