UndergroundPathNSScript:
	jp EnableAutoTextBoxDrawing

UndergroundPathNSTextPointers:
	dw MirrorTrainerText1
	db "@"

MirrorTrainerText1:
	TX_ASM
	ld hl, MirrorTrainerIntro
	call PrintText
	CheckEvent EVENT_ELITE_4_BEATEN	;has elite 4 been beaten?
	jr nz, .ready	;jump if beaten
	ld hl, MirrorTrainerNotReady
	call PrintText
	jr .textend
.ready
	ld hl, MirrorTrainerChallenge
	call PrintText
	call YesNoChoice	;prompt a yes/no choice
	ld a, [wCurrentMenuItem]	;load the player choice
	and a	;check the player choice
	jr nz, .goodbye	;if no, jump
	;otherwise begin loading battle
	SetEvent EVENT_LOAD_MIRROR_MATCH
	ld hl, MirrorTrainerPre
	call PrintText
	ld hl, wd72d;set the bits for triggering battle
	set 6, [hl]	;
	set 7, [hl]	;
	ld hl, MirrorTrainerPost	;load text for when you win
	ld de, MirrorTrainerPost	;load text for when you lose
	call SaveEndBattleTextPointers	;save the win/lose text
	ld a, OPP_GENTLEMAN	;load the trainer type
	ld [wCurOpponent], a	;set as the current opponent
	ld a, 1	;get a basic roster (doesn't matter)
	ld [wTrainerNo], a
	xor a
	ld [hJoyHeld], a
	jr .textend
.goodbye
	ld hl, MirrorTrainerBye
	call PrintText
.textend
	jp TextScriptEnd

MirrorTrainerIntro:
	text "Je suis Cilque,"
	line "artiste extra-"
	cont "ordinaire et"
	cont "maître du mime!"
	prompt
	db "@"
MirrorTrainerNotReady:
	text "Mais je dois fi-"
	line "nir de me poudrer"
	cont "et préparer tous"
	cont "mes costumes."
	
	para "Je serai prêt"
	line "quand la finale"
	cont "de la Ligue #-"
	cont "mon sera ter-"
	cont "minée."
	done
	db "@"
MirrorTrainerChallenge:
	text "Tu veux tester"
	line "tes stratégies"
	cont "sur moi,"
	cont "jeune Champion?"
	done
	db "@"
MirrorTrainerBye:
	text "Adieu et"
	line "bonne chanche!"
	done
	db "@"
MirrorTrainerPre:
	text "Allons-y!"
	done
	db "@"
MirrorTrainerPost:
	text "Ah ah!"
	line "Bien joué."
	prompt
	db "@"
