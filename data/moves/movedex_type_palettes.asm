; PureRGBnote: ADDED: subroutines for choosing which color palette the type icons in the movedex should use, and which icon images to use for which type.

; input d = type ID
; output d = palette ID
GetTypePalette:
	ld hl, TypePaletteMapping
	ld a, d ; d = type ID
	ld b, 0
	ld c, a
	add hl, bc ; which palette to use for this type
	ld a, [hl]
	ld d, a
	ret

TypePaletteMapping:
	db PAL_BW;normal
	db PAL_BROWNMON;fighting
	db PAL_MEWMON;flying
	db PAL_PURPLEMON;poison
	db PAL_ORANGEMON;ground
	db PAL_GREYMON;rock
	db PAL_BW;bird
	db PAL_GREENMON;bug
	db PAL_PURPLEMON;dragon
	db PAL_GREYBLUEMON;steel
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_BW;unused
	db PAL_REDMON;fire
	db PAL_BLUEMON;water
	db PAL_GREENMON;grass
	db PAL_YELLOWMON;electric
	db PAL_PINKMON;psychic
	db PAL_CYANMON;ice
	db PAL_0F;ghost
	db PAL_0F;dark

; input d = type ID
LoadTypeIcon:
	ld hl, TypeGraphicMapping
	ld a, d ; d = type ID
	ld b, 0
	ld c, a
	add hl, bc 
	add hl, bc ; pointer to which function to use for this type
	ld a, d
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	lb bc, BANK(NormalTypeIcon), 4
	ld hl, vChars1 + $400
	jp CopyVideoData

TypeGraphicMapping:
	dw NormalTypeIcon
	dw FightingTypeIcon;fighting
	dw FlyingTypeIcon;flying
	dw PoisonTypeIcon;poison
	dw GroundTypeIcon;ground
	dw RockTypeIcon;rock
	dw TypelessIcon;typeless
	dw BugTypeIcon;bug
	dw DragonTypeIcon;dragon
	dw SteelTypeIcon;steel
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw 0 ;unused
	dw FireTypeIcon;fire
	dw WaterTypeIcon;water
	dw GrassTypeIcon;grass
	dw ElectricTypeIcon;electric
	dw PsychicTypeIcon;psychic
	dw IceTypeIcon;ice
	dw GhostTypeIcon;ghost
	dw DarkTypeIcon;dark
