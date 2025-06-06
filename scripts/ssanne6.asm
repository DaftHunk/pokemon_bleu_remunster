SSAnne6Script:
	call EnableAutoTextBoxDrawing
	
;joenote - set up tournament
	CheckEvent EVENT_3_MONS_RANDOM_TRAINER
	jr z, .mainreturn
	CheckEvent EVENT_WAITING_FOR_TOURNAMENT_BAG_ROOM
	jr nz, .mainreturn
	ld a, [wIsInBattle]
	cp $ff
	jp nz, ContinueTournament
	;don't continue the tournament if you lost
	ResetEvent EVENT_3_MONS_RANDOM_TRAINER
	xor a
	ld [wUnusedD5A3], a
.mainreturn
	ret

SSAnne6TextPointers:
	dw SSAnne6Text1
	dw SSAnne6Text2
	dw SSAnne6Text3
	dw SSAnne6Text4
	dw SSAnne6Text5
	dw SSAnne6Text6
	dw SSAnne6Text7
	dw SSAnne6Text8	;joenote - gym guy for post-game tournament

SSAnne6Text1:
	TX_FAR _SSAnne6Text1
	db "@"

SSAnne6Text2:
	TX_FAR _SSAnne6Text2
	db "@"

SSAnne6Text3:
	TX_FAR _SSAnne6Text3
	db "@"

SSAnne6Text4:
	TX_FAR _SSAnne6Text4
	db "@"

SSAnne6Text5:
	TX_FAR _SSAnne6Text5
	db "@"

SSAnne6Text6:
	TX_FAR _SSAnne6Text6
	db "@"

SSAnne6Text7:
	TX_ASM
	ld hl, SSAnne6Text_61807
	call PrintText
	ld a, [hRandomAdd]
	bit 7, a
	jr z, .asm_93eb1
	ld hl, SSAnne6Text_6180c
	jr .asm_63292
.asm_93eb1
	bit 4, a
	jr z, .asm_7436c
	ld hl, SSAnne6Text_61811
	jr .asm_63292
.asm_7436c
	ld hl, SSAnne6Text_61816
.asm_63292
	call PrintText
	jp TextScriptEnd


SSAnne6Text8: ;joenote - gym guy for post-game tournament
	TX_ASM
	CheckEvent EVENT_WAITING_FOR_TOURNAMENT_BAG_ROOM
	jr nz, .giveAward

	;check if your are in tournament
	CheckEvent EVENT_3_MONS_RANDOM_TRAINER
	jr z, .promptdefaulttext
	predef HealParty
	
	;check if you won tournament
	ld a, [wUnusedD5A3]
	cp 7 ;# matches to win
	jr c, .notyet
.giveAward
	SetEvent EVENT_SS_ANNE_TOURNAMENT_BEATEN
	lb bc, MASTER_BALL, 1
	call GiveItem
	jr nc, .nobagroom

	ResetEvent EVENT_WAITING_FOR_TOURNAMENT_BAG_ROOM
	ld hl, SSAnne6Text_GymGuy_win
	call PrintText
	jr .endtournament
.nobagroom
	SetEvent EVENT_WAITING_FOR_TOURNAMENT_BAG_ROOM
	ld hl, SSAnne6Text_GymGuy_noroom
	jr .endprint
.notyet
	;ask if continue
	ld hl, SSAnne6Text_GymGuy_keepgoing
	call PrintText
	call YesNoChoice ;ask if you want to keep going
	ld a, [wCurrentMenuItem]	
	and a	
	jr nz, .endtournament ;leave if NO
	jr .startbattle
.promptdefaulttext	
	ld hl, SSAnne6Text_GymGuy ;load default text
	CheckEvent EVENT_ELITE_4_BEATEN
	jp z, .endprint
	ld hl, SSAnne6Text_GymGuy2 ;load intro text after beating elite 4
	call PrintText
	call YesNoChoice ;ask if you want to join tournament
	ld a, [wCurrentMenuItem]	
	and a	
	jr nz, .endtournament ;leave if NO
	
	;make sure party is 3 pkmn
	ld a, [wPartyCount]
	cp 3
	jr nz, .partynot3
	
	predef HealParty
.startbattle
	;if everything checks out, begin initiating battle with a random trainer
	SetEvent EVENT_3_MONS_RANDOM_TRAINER ;used for the 3-pkmn tournament
	ld hl, SSAnne6Text_GymGuy_ready
	call PrintText
	ld hl, wd72d ;set the bits for triggering battle
	set 6, [hl]
	set 7, [hl]
	ld hl, SSAnne6Text_GymGuy_battleend ;load text for when you win
	ld de, SSAnne6Text_GymGuy_battleend ;load text for when you lose
	call SaveEndBattleTextPointers ;save the win/lose text
	ld a, [H_SPRITEINDEX]
	ld [wSpriteIndex], a
	callba GetRandTrainer
	call InitBattleEnemyParameters
	;increment victory counter for the random trainer
	ld a, [wUnusedD5A3]
	inc a
	ld [wUnusedD5A3], a
	xor a
	ld [hJoyHeld], a
	jr .end
.partynot3
	ld hl, SSAnne6Text_GymGuy_party
	jr .endprint
.endtournament
	xor a
	ld [wUnusedD5A3], a
	ResetEvent EVENT_3_MONS_RANDOM_TRAINER
	ld hl, SSAnne6Text_GymGuy_bye
.endprint
	call PrintText
.end
	jp TextScriptEnd
	
ContinueTournament:
	ld a, $8
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
	
SSAnne6Text_61807:
	TX_FAR _SSAnne6Text_61807
	db "@"

SSAnne6Text_6180c:
	TX_FAR _SSAnne6Text_6180c
	db "@"

SSAnne6Text_61811:
	TX_FAR _SSAnne6Text_61811
	db "@"

SSAnne6Text_61816:
	TX_FAR _SSAnne6Text_61816
	db "@"

SSAnne6Text_GymGuy:
	TX_FAR _SSAnne6Text_GymGuy
	db "@"
SSAnne6Text_GymGuy2:
	TX_FAR _SSAnne6Text_GymGuy2
	db "@"
SSAnne6Text_GymGuy_bye:
	TX_FAR _SSAnne6Text_GymGuy_bye
	db "@"
SSAnne6Text_GymGuy_ready:
	TX_FAR _SSAnne6Text_GymGuy_ready
	db "@"
SSAnne6Text_GymGuy_battleend:
	TX_FAR _SSAnne6Text_GymGuy_battleend
	db "@"
SSAnne6Text_GymGuy_party:
	TX_FAR _SSAnne6Text_GymGuy_party
	db "@"
SSAnne6Text_GymGuy_noroom:
	TX_FAR _SSAnne6Text_GymGuy_noroom
	db "@"
SSAnne6Text_GymGuy_keepgoing:
	TX_FAR _SSAnne6Text_GymGuy_keepgoing
	db "@"
SSAnne6Text_GymGuy_win:
	TX_FAR _SSAnne6Text_GymGuy_win
	TX_SFX_ITEM_1
	db "@"
