ColosseumScript:
	jp TradeCenterScript

ColosseumTextPointers:
	dw ColosseumText1
	dw ColosseumResetClauses

ColosseumText1:
	TX_FAR _ColosseumText1
	db "@"

;joenote - for battle clauses	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ColosseumResetClauses:
	TX_ASM
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, _TXTAskReset
	call PrintText
	call .choice
	jr z, .end
	
	ResetEvent EVENT_ENABLE_SLEEP_CLAUSE 
	ResetEvent EVENT_ENABLE_FREEZE_CLAUSE 
	ResetEvent EVENT_ENABLE_TRAPPING_CLAUSE 
	ResetEvent EVENT_ENABLE_HYPER_BEAM_CLAUSE 
	
	ld hl, _TXTSleep
	call PrintText
	call .choice
	call nz, .sleep

	ld hl, _TXTFreeze
	call PrintText
	call .choice
	call nz, .freeze

	ld hl, _TXTTrap
	call PrintText
	call .choice
	call nz, .trapping

	ld hl, _TXTHBeam
	call PrintText
	call .choice
	call nz, .hyperbeam

.end
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, _TXTDone
	call PrintText
	jp TextScriptEnd

.choice
	call NoYesChoice ; no/yes menu
	ld a, [wCurrentMenuItem]
	and a
	ret
.sleep
	SetEvent EVENT_ENABLE_SLEEP_CLAUSE 
	ret
.freeze
	SetEvent EVENT_ENABLE_FREEZE_CLAUSE 
	ret
.trapping
	SetEvent EVENT_ENABLE_TRAPPING_CLAUSE 
	ret
.hyperbeam
	SetEvent EVENT_ENABLE_HYPER_BEAM_CLAUSE 
	ret

_TXTAskReset:
	text "Toutes les clauses"
	line "de combat que vous"
	cont "activez seront"
	cont "combinées avec"
	cont "celles de votre"
	cont "adversaire."

	para "Voulez-vous"
	line "écraser et"
	cont "re-choisir"
	cont "vos clauses?"
	done
	db "@"

_TXTSleep:
	text "Activer la clause"
	line "Sommeil?"
	done
	db "@"

_TXTFreeze:
	text "Activer la clause"
	line "Gel?"
	done
	db "@"

_TXTTrap:
	text "Activer la clause"
	line "Piège?"
	done
	db "@"

_TXTHBeam:
	text "Activer la clause"
	line "Ultralaser?"
	done
	db "@"

_TXTDone:
	text "Confirmé!"
	done
	db "@"
