MainMenu:
; Check save file
	call InitOptions
	xor a
	ld [wOptionsInitialized], a
	inc a
	ld [wSaveFileStatus], a
	call CheckForPlayerNameInSRAM
	jr nc, .mainMenuLoop

	predef LoadSAV

.mainMenuLoop
	ld c, 20
	call DelayFrames
	xor a ; LINK_STATE_NONE 
	ld [wLinkState], a
	ld hl, wPartyAndBillsPCSavedMenuItem
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wDefaultMap], a
	ld hl, wd72e
	res 6, [hl]
	call ClearScreen
	call RunDefaultPaletteCommand
	call LoadTextBoxTilePatterns
	call LoadFontTilePatterns
	ld hl, wd730
	set 6, [hl]
	ld a, [wSaveFileStatus]
	cp 1
	jr z, .noSaveFile
; there's a save file
	coord hl, 0, 0
	ld b, 6
	ld c, 13
	call TextBoxBorder
	coord hl, 2, 2
	ld de, ContinueText
	call PlaceString
	jr .next2
.noSaveFile
	coord hl, 0, 0
	ld b, 4
	ld c, 13
	call TextBoxBorder
	coord hl, 2, 2
	ld de, NewGameText
	call PlaceString
.next2
;joenote - print the game version
	coord hl, $00, $11
	ld de, VersionText
	call PlaceString
	
;joenote - check for emulator issues
	callba EmulatorChecks
	
;joenote - detect a random seed of 01 01 01 01 and do something to help correct it
	callba RNG_Correction

	ld a, [hJoyInput]
	cp A_BUTTON + SELECT
	jr nz, .endseed
;joedebug - print the random seed
	ld hl, $DEF3
	ld c, 4
.seedloop
	ld a, [hld]
	push af
	dec c
	jr nz, .seedloop
	coord hl, $00, $10
	ld c, 4
.seedloop2
	pop af
	push af
	and $F0
	swap a
	call .printnybble
	pop af
	and $0F
	call .printnybble
	dec c
	jr nz, .seedloop2
	jr .endseed
.printnybble
	add $F6
	jr nc, .printnybble_next
	add $80
.printnybble_next
	ld [hli], a
	ret
.endseed
	
	
	ld hl, wd730
	res 6, [hl]
	call UpdateSprites
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld [wMenuJoypadPollCount], a
	inc a
	ld [wTopMenuItemX], a
	inc a
	ld [wTopMenuItemY], a
	ld a, A_BUTTON | B_BUTTON | START
	ld [wMenuWatchedKeys], a
	ld a, [wSaveFileStatus]
	ld [wMaxMenuItem], a
	call HandleMenuInput
	bit 1, a ; pressed B?
	jp nz, DisplayTitleScreen ; if so, go back to the title screen
	ld c, 20
	call DelayFrames
	ld a, [wCurrentMenuItem]
	ld b, a
	ld a, [wSaveFileStatus]
	cp 2
	jp z, .skipInc
; If there's no save file, increment the current menu item so that the numbers
; are the same whether or not there's a save file.
	inc b
.skipInc
	ld a, b
	and a
	jr z, .choseContinue
	cp 1
	jp z, StartNewGame
	call DisplayOptionMenu
	ld a, 1
	ld [wOptionsInitialized], a
	jp .mainMenuLoop
.choseContinue
	call DisplayContinueGameInfo
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
.inputLoop
	xor a
	ld [hJoyPressed], a
	ld [hJoyReleased], a
	ld [hJoyHeld], a
	call Joypad
	ld a, [hJoyHeld]
	bit 0, a
	jr nz, .pressedA
	bit 1, a
	jp nz, .mainMenuLoop ; pressed B
	jr .inputLoop
.pressedA

;joenote - check the rom hack version and give a choice for the pallet warp
	ld a, [hJoyInput]
	cp A_BUTTON + SELECT
;	call z, ClearHackVersion	;this is a debug function to force a warp
	ld a, [wRomHackVersion]
	ld b, a		;use register b for temporarily holding the rom hack version
	push bc
	cp HACK_VERSION
	jr z, .warpcheck_end
	ld hl, RomHackVersionText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr z, .warpcheck_end
	ld a, HACK_VERSION
	pop bc		;if picking "no", overwrite the temp value so that the warp won't happen
	ld b, a
	push bc
.warpcheck_end
	
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerDirection], a
	ld [wPlayerLastStopDirection], a	;joenote - set face down as last direction for 180 degree turn frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - clear saved events flags on load for safety
	ResetEvent EVENT_ACTIVATE_GHOST_MAROWAK	;ghost marowak
	ResetEvent EVENT_CINNABAR_SHORE_MISSINGNO	;cinnabar shore missingno
	ResetEvent EVENT_RANDOM_TRAINER	;random trainer flag
	ResetEvent EVENT_3_MONS_RANDOM_TRAINER	;random 3-mon trainer for tournament
	ld hl, wFlags_D733
	res 1, [hl]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld c, 10
	call DelayFrames

;joenote - check the rom hack version of the save and update if necessary
;Special warp to pallet town if the save is from a different version number
;This will prevent a number of crashes and collision issues
	pop bc
	ld a, b
	cp HACK_VERSION
	jr nz, .pallet_warp

	ld a, [wNumHoFTeams]
	and a
	jp z, SpecialEnterMap
	ld a, [wCurMap] ; map ID
	cp HALL_OF_FAME
	jp nz, SpecialEnterMap
.pallet_warp
	;doing the special warp to pallet town so update some save-able parameters
	ld a, HACK_VERSION
	ld [wRomHackVersion], a	;update the working ram with the current rom hack version
	ld a, [wNumHoFTeams]
	and a
	jr z, .noHoF
	SetEvent EVENT_ELITE_4_BEATEN ;if the elite 4 have been beaten, set the event flag for it
.noHoF
	xor a
	ld [wDestinationMap], a
	ld hl, wd732
	set 2, [hl] ; fly warp or dungeon warp
	call SpecialWarpIn
	jp SpecialEnterMap

InitOptions:
	xor a
	ld [wUnusedD721], a	;joenote - reset any extra optioins
	ld a, 1 ; no delay
	ld [wLetterPrintingDelayFlags], a
	ld a, TEXT_DELAY_FAST ; medium speed
	set BIT_BATTLE_SHIFT, a ;joenote - SET battle style
;	set BIT_BATTLE_HARD, a ;joenote - hard mode
	ld [wOptions], a
	ld a, [hGBC]
	and a
	ret z
	;intialize 60 fps if on playing in GBC-mode
	ld a, [wUnusedD721]
	set 4, a
	ld [wUnusedD721], a
	ret

LinkMenu:
	xor a
	ld [wLetterPrintingDelayFlags], a
	ld hl, wd72e
	set 6, [hl]
	ld hl, TextTerminator_6b20
	call PrintText
	call SaveScreenTilesToBuffer1
	ld hl, WhereWouldYouLikeText
	call PrintText
	coord hl, 5, 5
	ld b, $6
	ld c, $d
	call TextBoxBorder
	call UpdateSprites
	coord hl, 7, 7
	ld de, CableClubOptionsText
	call PlaceString
	xor a
	ld [wUnusedCD37], a
	ld [wd72d], a
	ld hl, wTopMenuItemY
	ld a, $7
	ld [hli], a
	ld a, $6
	ld [hli], a
	xor a
	ld [hli], a
	inc hl
	ld a, $2
	ld [hli], a
	inc a
	; ld a, A_BUTTON | B_BUTTON
	ld [hli], a ; wMenuWatchedKeys
	xor a
	ld [hl], a
.waitForInputLoop
	call HandleMenuInput
	and A_BUTTON | B_BUTTON
	add a
	add a
	ld b, a
	ld a, [wCurrentMenuItem]
	add b
	add $d0
	ld [wLinkMenuSelectionSendBuffer], a
	ld [wLinkMenuSelectionSendBuffer + 1], a
.exchangeMenuSelectionLoop
	call Serial_ExchangeLinkMenuSelection
	ld a, [wLinkMenuSelectionReceiveBuffer]
	ld b, a
	and $f0
	cp $d0
	jr z, .asm_5c7d
	ld a, [wLinkMenuSelectionReceiveBuffer + 1]
	ld b, a
	and $f0
	cp $d0
	jr nz, .exchangeMenuSelectionLoop
.asm_5c7d
	ld a, b
	and $c ; did the enemy press A or B?
	jr nz, .enemyPressedAOrB
; the enemy didn't press A or B
	ld a, [wLinkMenuSelectionSendBuffer]
	and $c ; did the player press A or B?
	jr z, .waitForInputLoop ; if neither the player nor the enemy pressed A or B, try again
	jr .doneChoosingMenuSelection ; if the player pressed A or B but the enemy didn't, use the player's selection
.enemyPressedAOrB
	ld a, [wLinkMenuSelectionSendBuffer]
	and $c ; did the player press A or B?
	jr z, .useEnemyMenuSelection ; if the enemy pressed A or B but the player didn't, use the enemy's selection
; the enemy and the player both pressed A or B
; The gameboy that is clocking the connection wins.
	ld a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr z, .doneChoosingMenuSelection
.useEnemyMenuSelection
	ld a, b
	ld [wLinkMenuSelectionSendBuffer], a
	and $3
	ld [wCurrentMenuItem], a
.doneChoosingMenuSelection
	ld a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr nz, .skipStartingTransfer
	call DelayFrame
	call DelayFrame
	ld a, START_TRANSFER_INTERNAL_CLOCK
	ld [rSC], a
.skipStartingTransfer
	ld b, $7f
	ld c, $7f
	ld d, $ec
	ld a, [wLinkMenuSelectionSendBuffer]
	and (B_BUTTON << 2) ; was B button pressed?
	jr nz, .updateCursorPosition
; A button was pressed
	ld a, [wCurrentMenuItem]
	cp $2
	jr z, .updateCursorPosition
	ld c, d
	ld d, b
	dec a
	jr z, .updateCursorPosition
	ld b, c
	ld c, d
.updateCursorPosition
	ld a, b
	Coorda 6, 7
	ld a, c
	Coorda 6, 9
	ld a, d
	Coorda 6, 11
	ld c, 40
	call DelayFrames
	call LoadScreenTilesFromBuffer1
	ld a, [wLinkMenuSelectionSendBuffer]
	and (B_BUTTON << 2) ; was B button pressed?
	jr nz, .choseCancel ; cancel if B pressed
	ld a, [wCurrentMenuItem]
	cp $2
	jr z, .choseCancel
	xor a
	ld [wWalkBikeSurfState], a ; start walking
	ld a, [wCurrentMenuItem]
	and a
	ld a, COLOSSEUM
	;jr nz, .next
	jp nz, ShinPokemonHandshake	;joenote - do a version control check before going to the colosseum
	ld a, TRADE_CENTER
.next
	ld [wd72d], a
	ld hl, PleaseWaitText
	call PrintText
	ld c, 50
	call DelayFrames
	ld hl, wd732
	res 1, [hl]
	ld a, [wDefaultMap]
	ld [wDestinationMap], a
	call SpecialWarpIn
	ld c, 20
	call DelayFrames
	xor a
	ld [wMenuJoypadPollCount], a
	ld [wSerialExchangeNybbleSendData], a
	inc a ; LINK_STATE_IN_CABLE_CLUB (makes a = 1)
	ld [wLinkState], a
	ld [wEnteringCableClub], a
	jp SpecialEnterMap
.choseCancel
	xor a
	ld [wMenuJoypadPollCount], a
	call Delay3
	call CloseLinkConnection
	ld hl, LinkCanceledText
	call PrintText
	ld hl, wd72e
	res 6, [hl]
	ret

ShinPokemonHandshake:
;joenote - do a security handshake that checks the version of the other linked game.
;The other game must send back the same sequence of numbers given under HandshakeList.
;Otherwise the handshake fails and the connection is cancelled.
	push af	
	push hl
	;wUnknownSerialCounter is two bytes. Write the default of 03 00 to it.
	;This acts as a timeout counter for when two linked gameboys are trying to sync up.
	;We set it to its default because if it is left as zero then the syncing can get stuck in an infinite loop.
	ld hl, wUnknownSerialCounter
	ld a, $3
	ld [hli], a
	xor a
	ld [hl], a
	;wSerialExchangeNybbleSendData holds the nybble (a half-byte of 0 to f) to send to the other game.
	;Let's send a 0 across the link to make sure the other game can communicate.
	ld [wSerialExchangeNybbleSendData], a
	call Serial_PrintWaitingTextAndSyncAndExchangeNybble
	;Check wUnknownSerialCounter. If FFFF is there, then the connection timed out.
	ld hl, wUnknownSerialCounter
	ld a, [hli]
	inc a
	jr nz, .connected
	ld a, [hl]
	inc a
	jr nz, .connected
	jr .fail
.connected
	;wSerialExchangeNybbleReceiveData holds the nybble recieved from the other game.
	;This defaults to FF to indicate that no information was recieved.
	ld a, [wSerialExchangeNybbleReceiveData]
	and a
	;Since a 0 was sent, a 0 should also be recieved if communicating with a game that supports this handshake check.
	;If zero is not recieved, then there is a communication error and the handshake fails.
	jr nz, .fail
	;Else we have proper communication. Time to check to make sure the version control passcode matches.
	ld hl, HandshakeList
.loop
	ld a, [hl]	;load a digit of the version control passcode
	cp $ff	;has the end been reached?
	jr z, .pass	;handshake check passes if the end has been reached
	ld [wSerialExchangeNybbleSendData], a	;load the digit to be sent over link
	ld a, $ff
	ld [wSerialExchangeNybbleReceiveData], a	;default the recieved data to FF
	;This function syncs up with the other game.
	;The nybble in wSerialExchangeNybbleSendData is sent to the other game's wSerialExchangeNybbleReceiveData.
	;And the nybble in the other game's wSerialExchangeNybbleSendData is sent to your wSerialExchangeNybbleReceiveData.
	call Serial_SyncAndExchangeNybble
	ld a, [wSerialExchangeNybbleReceiveData]
	cp [hl]	
	jr nz, .fail	;the handshake fails if the digit recieved does not match the digit sent
	inc hl	;otherwise increment to the next digit and loop.
	jr .loop	
.fail
	xor a
	ld hl, wUnknownSerialCounter
	ld [hli], a
	ld [hl], a
	pop hl
	pop af
	jp LinkMenu.choseCancel
.pass
;One more thing. Exchange if you are a male or female trainer with the other game.
	ResetEvent EVENT_LINKED_FPLAYER
	ld a, [wUnusedD721]
	and $0F
	ld [wSerialExchangeNybbleSendData], a	;load the digit to be sent over link
	ld a, $ff
	ld [wSerialExchangeNybbleReceiveData], a	;default the recieved data to FF
	call Serial_SyncAndExchangeNybble
	ld a, [wSerialExchangeNybbleReceiveData]
	cp $ff
	jr z, .fail
	bit 0, a	;check bit 0 that was sent to tell if other trainer is female or not
	jr z, .pass_exchanged
	SetEvent EVENT_LINKED_FPLAYER
.pass_exchanged
	xor a
	ld hl, wUnknownSerialCounter
	ld [hli], a
	ld [hl], a
	pop hl
	pop af
	jp LinkMenu.next

HandshakeList:	
;This serves as a version control passcode.
;Each digit of the passcode is one nybble.
;FF is used as an end-of-list marker.
	db $1
	db $2
	db $4
	db $7
	db $a
	db $ff
VersionText:
	db "v1.1.0@"

WhereWouldYouLikeText:
	TX_FAR _WhereWouldYouLikeText
	db "@"

PleaseWaitText:
	TX_FAR _PleaseWaitText
	db "@"

LinkCanceledText:
	TX_FAR _LinkCanceledText
	db "@"

RomHackVersionText:
	TX_FAR _RomHackVersionText
	db "@"

StartNewGame:
	ld hl, wd732
	; Ensure debug mode is not used when starting a regular new game.
	; Debug mode persists in saved games for both debug and non-debug builds, and is
	; only reset here by the main menu.
	res 1, [hl]
	; fallthrough
StartNewGameDebug:
	call OakSpeech
	ld c, 20
	call DelayFrames

; enter map after using a special warp or loading the game from the main menu
SpecialEnterMap::
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyHeld], a
	ldh [hJoy5], a
	ld [wd72d], a
	ld hl, wd732
	set 0, [hl] ; count play time
	call ResetPlayerSpriteData
	ld c, 20
	call DelayFrames
	ld a, [wEnteringCableClub]
	and a
	ret nz
	jp EnterMap

ContinueText:
	db "Continuer", $4e

NewGameText:
	db   "Nouveau jeu"
	next "Options@"

CableClubOptionsText:
	db   "Centre Troc"
	next "Colisée"
	next "Retour@"

DisplayContinueGameInfo:
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	coord hl, 4, 7
	ld b, 8
	ld c, 14
	call TextBoxBorder
	coord hl, 5, 9
	ld de, SaveScreenInfoText
	call PlaceString
	coord hl, 12, 9
	ld de, wPlayerName
	call PlaceString
	coord hl, 17, 11
	call PrintNumBadges
	coord hl, 16, 13
	call PrintNumOwnedMons
	coord hl, 11, 15
	call PrintPlayTime_local
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	ld c, 30
	jp DelayFrames

PrintSaveScreenText:
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	coord hl, 4, 0
	ld b, $8
	ld c, $e
	call TextBoxBorder
	call LoadTextBoxTilePatterns
	call UpdateSprites
	coord hl, 5, 2
	ld de, SaveScreenInfoText
	call PlaceString
	coord hl, 12, 2
	ld de, wPlayerName
	call PlaceString
	coord hl, 17, 4
	call PrintNumBadges
	coord hl, 16, 6
	call PrintNumOwnedMons
	coord hl, 11, 8
	call PrintPlayTime_local
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	ld c, 30
	jp DelayFrames

PrintNumBadges:
	push hl
	ld hl, wObtainedBadges
	ld b, $1
	call CountSetBits
	pop hl
	ld de, wNumSetBits
	lb bc, 1, 2
	jp PrintNumber

PrintNumOwnedMons:
	push hl
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	pop hl
	ld de, wNumSetBits
	lb bc, 1, 3
	jp PrintNumber

PrintPlayTime_local:
	ld d, $6d
	predef PrintPlayTime
	ret
;PrintPlayTime:	;joenote - moved this into a predef
;	ld de, wPlayTimeHours
;	lb bc, 1, 3
;	call PrintNumber
;	ld [hl], $6d
;	inc hl
;	ld de, wPlayTimeMinutes
;	lb bc, LEADING_ZEROES | 1, 2
;	jp PrintNumber

SaveScreenInfoText:
	db   "Joueur"
	next "Badges    "
	next "#dex    "
	next "Temps@"

DisplayOptionMenu:
	call GBPalNormal	;joenote - fixes rock tunnel darkness affecting option menu
	coord hl, 0, 0
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 5
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 10
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 1, 1
	ld de, TextSpeedOptionText
	call PlaceString
	coord hl, 1, 6
	ld de, BattleAnimationOptionText
	call PlaceString
	coord hl, 1, 11
	ld de, BattleStyleOptionText
	call PlaceString
	coord hl, 2, 16
	ld de, OptionMenuCancelText
	call PlaceString
	
	coord hl, $B, $10
	ld de, OptionMenuSelectText	;joenote - text for getting to extra options screen
	call PlaceString
		
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	inc a
	ld [wLetterPrintingDelayFlags], a
	ld [wUnusedCD40], a
	ld a, 3 ; text speed cursor Y coordinate
	ld [wTopMenuItemY], a
	call SetCursorPositionsFromOptions
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	ld [wTopMenuItemX], a
	ld a, $01
	ld [H_AUTOBGTRANSFERENABLED], a ; enable auto background transfer
	call Delay3
.loop
	call PlaceMenuCursor
	call SetOptionsFromCursorPositions
.getJoypadStateLoop
	call JoypadLowSensitivity
	ld a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | START | D_RIGHT | D_LEFT | D_UP | D_DOWN ; any key besides select pressed?
	jp z, .checkSelectPressed
;	jr z, .getJoypadStateLoop
	bit 1, b ; B button pressed?
	jr nz, .exitMenu
	bit 3, b ; Start button pressed?
	jr nz, .exitMenu
	bit 0, b ; A button pressed?
	jr z, .checkDirectionKeys
	ld a, [wTopMenuItemY]
	cp 16 ; is the cursor on Cancel?
	jr nz, .loop
.exitMenu
	ld a, SFX_PRESS_AB
	call PlaySound
	ret
.eraseOldMenuCursor
	ld [wTopMenuItemX], a
	call EraseMenuCursor
	jp .loop
.checkDirectionKeys
	ld a, [wTopMenuItemY]
	bit 7, b ; Down pressed?
	jr nz, .downPressed
	bit 6, b ; Up pressed?
	jr nz, .upPressed
	cp 8 ; cursor in Battle Animation section?
	jr z, .cursorInBattleAnimation
	cp 13 ; cursor in Battle Style section?
	jr z, .cursorInBattleStyle
	cp 16 ; cursor on Cancel?
	jr z, .loop
.cursorInTextSpeed
	bit 5, b ; Left pressed?
	jp nz, .pressedLeftInTextSpeed
	jp .pressedRightInTextSpeed
.downPressed
	cp 16
	ld b, -13
	ld hl, wOptionsTextSpeedCursorX
	jr z, .updateMenuVariables
	ld b, 5
	cp 3
	inc hl
	jr z, .updateMenuVariables
	cp 8
	inc hl
	jr z, .updateMenuVariables
	ld b, 3
	inc hl
	jr .updateMenuVariables
.upPressed
	cp 8
	ld b, -5
	ld hl, wOptionsTextSpeedCursorX
	jr z, .updateMenuVariables
	cp 13
	inc hl
	jr z, .updateMenuVariables
	cp 16
	ld b, -3
	inc hl
	jr z, .updateMenuVariables
	ld b, 13
	inc hl
.updateMenuVariables
	add b
	ld [wTopMenuItemY], a
	ld a, [hl]
	ld [wTopMenuItemX], a
	call PlaceUnfilledArrowMenuCursor
	jp .loop
.cursorInBattleAnimation
	ld a, [wOptionsBattleAnimCursorX] ; battle animation cursor X coordinate
	xor $0b ; toggle between 1 and 10
	ld [wOptionsBattleAnimCursorX], a
	jp .eraseOldMenuCursor
.cursorInBattleStyle
	ld a, [wOptionsBattleStyleCursorX] ; battle style cursor X coordinate
	xor $0b ; toggle between 1 and 10
	ld [wOptionsBattleStyleCursorX], a
	jp .eraseOldMenuCursor
.pressedLeftInTextSpeed
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	cp 1
	jr z, .updateTextSpeedXCoord
	cp 7
	jr nz, .fromSlowToMedium
	sub 6
	jr .updateTextSpeedXCoord
.fromSlowToMedium
	sub 7
	jr .updateTextSpeedXCoord
.pressedRightInTextSpeed
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	cp 14
	jr z, .updateTextSpeedXCoord
	cp 7
	jr nz, .fromFastToMedium
	add 7
	jr .updateTextSpeedXCoord
.fromFastToMedium
	add 6
.updateTextSpeedXCoord
	ld [wOptionsTextSpeedCursorX], a ; text speed cursor X coordinate
	jp .eraseOldMenuCursor
.checkSelectPressed
	bit BIT_SELECT, b
	jp z, .getJoypadStateLoop
	ld a, SFX_PRESS_AB
	call PlaySound
	call ClearScreen
	callba DisplayExtraOptionMenu
	jp DisplayOptionMenu

TextSpeedOptionText:
	db   "Vit. texte"
	next " 3     2      1   @"

BattleAnimationOptionText:
	db   "Animation combat"
	next " Oui      Non@"

BattleStyleOptionText:
	db   "Style combat"
	next " Choix    Défini@"

OptionMenuCancelText:
	db "Retour@"

OptionMenuSelectText:	;joenote - text for getting to extra options screen
	db "Select",$E3,$ED,"@"

; sets the options variable according to the current placement of the menu cursors in the options menu
SetOptionsFromCursorPositions:
	ld hl, TextSpeedOptionData
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	ld c, a
.loop
	ld a, [hli]
	cp c
	jr z, .textSpeedMatchFound
	inc hl
	jr .loop
.textSpeedMatchFound

	;joenote - set cursor position for lagless text
	ld a, [wOptions]
	and TEXT_DELAY_BITS
	ld a, [hl]
	jr nz, .settextspeed
	xor a
.settextspeed

	ld d, a
	ld a, [wOptionsBattleAnimCursorX] ; battle animation cursor X coordinate
	dec a
	jr z, .battleAnimationOn
.battleAnimationOff
	set BIT_BATTLE_ANIMATION, d
	jr .checkBattleStyle
.battleAnimationOn
	res BIT_BATTLE_ANIMATION, d
.checkBattleStyle
	ld a, [wOptionsBattleStyleCursorX] ; battle style cursor X coordinate
	dec a
	jr z, .battleStyleShift
.battleStyleSet
	set BIT_BATTLE_SHIFT, d
	jr .storeOptions
.battleStyleShift
	res BIT_BATTLE_SHIFT, d
.storeOptions
	ld a, [wOptions]	;joenote - preserve sound and hard mode settings
	and (SOUND_STEREO_BITS | BATTLE_HARD_MODE)
	or d
	;ld a, d
	ld [wOptions], a
	ret

; reads the options variable and places menu cursors in the correct positions within the options menu
SetCursorPositionsFromOptions:
	ld hl, TextSpeedOptionData + 1
	ld a, [wOptions]
	and (SOUND_STEREO_BITS ^ $FF)	;joenote - bypass sound settings
	ld c, a
	and TEXT_DELAY_BITS
	push bc
	ld de, 2
	call IsInArray
	pop bc
	dec hl
	
	;joenote - set cursor position for lagless text
	ld a, [wOptions]
	and TEXT_DELAY_BITS
	ld a, [hl]
	jr nz, .settextspeed
	ld a, 1
.settextspeed

	ld [wOptionsTextSpeedCursorX], a ; text speed cursor X coordinate
	coord hl, 0, 3
	call .placeUnfilledRightArrow
	bit BIT_BATTLE_ANIMATION, c
	ld a, 1 ; On
	jr z, .storeBattleAnimationCursorX
	ld a, 10 ; Off
.storeBattleAnimationCursorX
	ld [wOptionsBattleAnimCursorX], a ; battle animation cursor X coordinate
	coord hl, 0, 8
	call .placeUnfilledRightArrow
	bit BIT_BATTLE_SHIFT, c
	ld a, 1
	jr z, .storeBattleStyleCursorX
	ld a, 10
.storeBattleStyleCursorX
	ld [wOptionsBattleStyleCursorX], a ; battle style cursor X coordinate
	coord hl, 0, 13
	call .placeUnfilledRightArrow
; cursor in front of Cancel
	coord hl, 0, 16
	ld a, 1
.placeUnfilledRightArrow
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], $ec ; unfilled right arrow menu cursor
	ret

; table that indicates how the 3 text speed options affect frame delays
; Format:
; 00: X coordinate of menu cursor
; 01: delay after printing a letter (in frames)
TextSpeedOptionData:
	db 14,5 ; Slow
	db  7,3 ; Medium
	db  1,1 ; Fast
	db 7 ; default X coordinate (Medium)
	db $ff ; terminator

CheckForPlayerNameInSRAM:
; Check if the player name data in SRAM has a string terminator character
; (indicating that a name may have been saved there) and return whether it does
; in carry.
	ld a, SRAM_ENABLE
	ld [MBC1SRamEnable], a
	ld a, $1
	ld [MBC1SRamBankingMode], a
	ld [MBC1SRamBank], a
	ld b, NAME_LENGTH
	ld hl, sPlayerName
.loop
	ld a, [hli]
	cp "@"
	jr z, .found
	dec b
	jr nz, .loop
; not found
	xor a
	ld [MBC1SRamEnable], a
	ld [MBC1SRamBankingMode], a
	and a
	ret
.found
	xor a
	ld [MBC1SRamEnable], a
	ld [MBC1SRamBankingMode], a
	scf
	ret

ClearHackVersion:
	xor a
	ld [wRomHackVersion], a
	ret
