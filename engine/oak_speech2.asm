ChoosePlayerName:
	call OakSpeechSlidePicRight
;joenote - support female trainer sprite
	ld de, DefaultNamesPlayerF
	ld a, [wUnusedD721]
	bit 0, a	;check if girl
	jr nz, .donefemale_names
	ld de, DefaultNamesPlayer
.donefemale_names
	call DisplayIntroNameTextBox
	ld a, [wCurrentMenuItem]
	and a
	jr z, .customName
;joenote - support female trainer sprite
	push af
	ld hl, DefaultNamesPlayerListF
	ld a, [wUnusedD721]
	bit 0, a	;check if girl
	jr nz, .donefemale_names2
	ld hl, DefaultNamesPlayerList
.donefemale_names2
	pop af
	call GetDefaultName
	ld de, wPlayerName
	call OakSpeechSlidePicLeft
	jr .done
.customName
	ld hl, wPlayerName
	xor a ; NAME_PLAYER_SCREEN
	ld [wNamingScreenType], a
	call DisplayNamingScreen
	ld a, [wcf4b]
	cp "@"
	jr z, .customName
	call ClearScreen
	call Delay3
;joenote - support female trainer sprite
	ld de, RedPicFFront
	ld b, BANK(RedPicFFront)
	ld a, [wUnusedD721]
	bit 0, a	;check if girl
	jr nz, .donefemale_front
	ld de, RedPicFront
	ld b, BANK(RedPicFront)
.donefemale_front
	call IntroDisplayPicCenteredOrUpperRight
.done
	ld hl, YourNameIsText
	jp PrintText

YourNameIsText:
	TX_FAR _YourNameIsText
	db "@"

ChooseRivalName:
	call OakSpeechSlidePicRight
	ld de, DefaultNamesRival
	call DisplayIntroNameTextBox
	ld a, [wCurrentMenuItem]
	and a
	jr z, .customName
	ld hl, DefaultNamesRivalList
	call GetDefaultName
	ld de, wRivalName
	call OakSpeechSlidePicLeft
	jr .done
.customName
	ld hl, wRivalName
	ld a, NAME_RIVAL_SCREEN
	ld [wNamingScreenType], a
	call DisplayNamingScreen
	ld a, [wcf4b]
	cp "@"
	jr z, .customName
	call ClearScreen
	call Delay3
	ld de, Rival1Pic
	lb bc, Bank(Rival1Pic), $00
	call IntroDisplayPicCenteredOrUpperRight
.done
	ld hl, HisNameIsText
	jp PrintText

HisNameIsText:
	TX_FAR _HisNameIsText
	db "@"

OakSpeechSlidePicLeft:
	push de
	coord hl, 0, 0
	lb bc, 12, 11
	call ClearScreenArea ; clear the name list text box
	ld c, 10
	call DelayFrames
	pop de
	ld hl, wcd6d
	ld bc, NAME_LENGTH
	call CopyData
	call Delay3
	coord hl, 12, 4
	lb de, 6, 6 * SCREEN_WIDTH + 5
	ld a, $ff
	jr OakSpeechSlidePicCommon

OakSpeechSlidePicRight:
	coord hl, 5, 4
	lb de, 6, 6 * SCREEN_WIDTH + 5
	xor a

OakSpeechSlidePicCommon:
	push hl
	push de
	push bc
	ld [hSlideDirection], a
	ld a, d
	ld [hSlideAmount], a
	ld a, e
	ld [hSlidingRegionSize], a
	ld c, a
	ld a, [hSlideDirection]
	and a
	jr nz, .next
; If sliding right, point hl to the end of the pic's tiles.
	ld d, 0
	add hl, de
.next
	ld d, h
	ld e, l
.loop
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, [hSlideDirection]
	and a
	jr nz, .slideLeft
; sliding right
	ld a, [hli]
	ld [hld], a
	dec hl
	jr .next2
.slideLeft
	ld a, [hld]
	ld [hli], a
	inc hl
.next2
	dec c
	jr nz, .loop
	ld a, [hSlideDirection]
	and a
	jr z, .next3
; If sliding left, we need to zero the last tile in the pic (there is no need
; to take a corresponding action when sliding right because hl initially points
; to a 0 tile in that case).
	xor a
	dec hl
	ld [hl], a
.next3
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	call Delay3
	ld a, [hSlidingRegionSize]
	ld c, a
	ld h, d
	ld l, e
	ld a, [hSlideDirection]
	and a
	jr nz, .slideLeft2
	inc hl
	jr .next4
.slideLeft2
	dec hl
.next4
	ld d, h
	ld e, l
	ld a, [hSlideAmount]
	dec a
	ld [hSlideAmount], a
	jr nz, .loop
	pop bc
	pop de
	pop hl
	ret

DisplayIntroNameTextBox:
	push de
	coord hl, 0, 0
	ld b, $a
	ld c, $9
	call TextBoxBorder
	coord hl, 3, 0
	ld de, .namestring
	call PlaceString
	pop de
	coord hl, 2, 2
	call PlaceString
	call UpdateSprites
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	inc a
	ld [wTopMenuItemX], a
	ld [wMenuWatchedKeys], a ; A_BUTTON
	inc a
	ld [wTopMenuItemY], a
	inc a
	ld [wMaxMenuItem], a
	jp HandleMenuInput

.namestring
	db "─NOM@"

;joenote - set female trainer names
DefaultNamesPlayerF:
	db   "Nom :"
	next "Green"
	next "Flora"
	next "Cléo"
	db   "@"
DefaultNamesPlayer:
	db   "Nom :"
	next "Red"
	next "Sacha"
	next "Jean"
	db   "@"
DefaultNamesRival:
	db   "Nom :"
	next "Blue"
	next "Régis"
	next "Paul"
	db   "@"

GetDefaultName:
; a = name index
; hl = name list
	ld b, a
	ld c, 0
.loop
	ld d, h
	ld e, l
.innerLoop
	ld a, [hli]
	cp "@"
	jr nz, .innerLoop
	ld a, b
	cp c
	jr z, .foundName
	inc c
	jr .loop
.foundName
	ld h, d
	ld l, e
	ld de, wcd6d
	ld bc, $14
	jp CopyData

;joenote - set female trainer names
DefaultNamesPlayerListF:
	db "Nom :@"
	db "Green@"
	db "Flora@"
	db "Cléo@"
DefaultNamesPlayerList:
	db "Nom :@"
	db "Red@"
	db "Sacha@"
	db "Jean@"
DefaultNamesRivalList:
	db "Nom :@"
	db "Blue@"
	db "Régis@"
	db "Paul@"

TextTerminator_6b20:
	db "@"
