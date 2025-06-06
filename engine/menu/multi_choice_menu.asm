; PureRGBnote: ADDED: this code lets you bring up selection lists of 2-6 entries without relying on item menu code.
; INPUT:
; [wListPointer] = address of the text list (2 bytes) (expected to be defined within this bank)
; [wMenuWatchedKeys] = which buttons should exit the menu (like A button for selecting an option)
; Should only be used to display up to 6 options
; OUTPUT: 
; [wCurrentMenuItem] = what was chosen from the menu
DisplayMultiChoiceMenu::
	xor a
	ldh [H_AUTOBGTRANSFERENABLED], a ; disable auto-transfer
	ld a, 1
	ldh [hJoy7], a ; joypad state update flag
	ld a, [wd730]
	push af
	set 6, a ; turn off letter printing delay
	ld [wd730], a
	hl_deref wListPointer ; hl = address of the list
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = address of the text box drawing function to call
	push hl ; address of the start of the text we will draw later
	xor a
	ldh [H_AUTOBGTRANSFERENABLED], a ; disable transfer
	ld h, d
	ld l, e
	jp hl ; function that draws the textbox

DoneDrawFunc:
	push hl
	call UpdateSprites ; disable sprites behind the text box
	xor a
	ld [wMenuWatchMovingOutOfBounds], a ; enable menu wrapping
	pop hl ; hl = coordinate of the list
	pop de ; de = address of the start of text
	call PlaceString
	ld a, 1
	ldh [H_AUTOBGTRANSFERENABLED], a ; enable transfer
	call Delay3
	call HandleMenuInput
	xor a
	ldh [hJoy7], a ; joypad state update flag
	pop af
	ld [wd730], a ; reset letter printing delay to what it was before calling this function
	ret

; multi-option menus can have 2-6 options, visually set up by the below functions

TwoOptionMenu::
	ld a, 1 ; 2-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a

	ld a, 8
	ld [wTopMenuItemY], a
	ld a, 5
	ld [wTopMenuItemX], a

	coord hl, 4, 7
	lb bc, 3, 14  ; height, width
	call TextBoxBorder

	coord hl, 6, 8 ; where the list will be drawn at
	jp DoneDrawFunc

TwoOptionSmallMenu::
	ld a, 1 ; 2-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a

	ld a, 8
	ld [wTopMenuItemY], a
	ld a, 14
	ld [wTopMenuItemX], a

	coord hl, 13, 7
	lb bc, 3, 5  ; height, width
	call TextBoxBorder

	coord hl, 15, 8 ; where the list will be drawn at
	jp DoneDrawFunc

ThreeOptionMenu::
	ld a, 2 ; 3-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a

	ld a, 6
	ld [wTopMenuItemY], a
	ld a, 5
	ld [wTopMenuItemX], a

	coord hl, 4, 5
	lb bc, 5, 13  ; height, width
	call TextBoxBorder

	coord hl, 6, 6 ; where the list will be drawn at
	jp DoneDrawFunc

InitThreeOptionMenuSmall::
	ld [wTopMenuItemY], a
	ld a, 2 ; 3-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a
	ld a, 12
	ld [wTopMenuItemX], a
	lb bc, 5, 7 ; height, width
	ret

ThreeOptionMenuSmall::
	ld a, 6
	call InitThreeOptionMenuSmall
	coord hl, 11, 5
	call TextBoxBorder

	coord hl, 13, 6 ; where the list will be drawn at
	jp DoneDrawFunc

ThreeOptionMenuSmallLower::
	ld a, 8
	call InitThreeOptionMenuSmall
	coord hl, 11, 7
	call TextBoxBorder

	coord hl, 13, 8 ; where the list will be drawn at
	jp DoneDrawFunc


FourOptionMenuBig::
	ld c, 14 ; width
	jr FourOptionMenuCommon

FourOptionMenu::
	ld c, 13 ; width
	; fall through
FourOptionMenuCommon::
	ld a, 3 ; 4-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a

	ld a, 4
	ld [wTopMenuItemY], a
	ld a, 5
	ld [wTopMenuItemX], a

	coord hl, 4, 3
	ld b, 7  ; height
	call TextBoxBorder

	coord hl, 6, 4 ; where the list will be drawn at
	jp DoneDrawFunc

FiveOptionMenu::
	ld a, 4 ; 5-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a


	ld a, 2
	ld [wTopMenuItemY], a
	ld a, 5
	ld [wTopMenuItemX], a

	coord hl, 4, 1
	lb bc, 9, 13  ; height, width
	call TextBoxBorder
	
	coord hl, 6, 2 ; where the list will be drawn at
	jp DoneDrawFunc

SixOptionMenu::
	ld a, 5 ; 6-item menu (0 counts)
	ld [wListCount], a
	ld [wMaxMenuItem], a

	ld a, 1
	ld [wTopMenuItemY], a
	ld a, 5
	ld [wTopMenuItemX], a

	coord hl, 4, 0
	lb bc, 11, 13 ; height, width
	call TextBoxBorder
	
	coord hl, 6, 1 ; where the list will be drawn at
	jp DoneDrawFunc

YesNoHide::
	dw ThreeOptionMenuSmall
	db "Oui"
	next "Non"
	next "Cacher@"

YesNoSmall::
	dw TwoOptionSmallMenu
	db "Oui"
	next "Non@"
