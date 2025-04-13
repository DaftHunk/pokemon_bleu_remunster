db DEX_MOLTRES ; pokedex id
db 90 ; base hp
db 100 ; base attack
db 90 ; base defense
db 90 ; base speed
db 125 ; base special
db FIRE ; species type 1
db FLYING ; species type 2
db 3 ; catch rate
db 217 ; base exp yield
INCBIN "gfx/pokemon/front/moltres.pic",0,1 ; 77, sprite dimensions
dw MoltresPicFront
dw MoltresPicBack
; attacks known at lvl 0
db WING_ATTACK
db EMBER
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn tm02_RAZOR_WIND, tm04_FLAMETHROWER, tm06_TOXIC
	tmlearn tm09_TAKE_DOWN, tm10_DOUBLE_EDGE, tm15_HYPER_BEAM
	tmlearn tm20_RAGE
	tmlearn tm31_MIMIC, tm32_DOUBLE_TEAM
	tmlearn tm33_REFLECT, tm34_BIDE, tm38_FIRE_BLAST, tm39_SWIFT
	tmlearn tm43_SKY_ATTACK, tm44_REST
	tmlearn tm50_SUBSTITUTE, hm02_FLY
;	db 0 ; padding
	db BANK(MoltresPicFront)
	assert BANK(MoltresPicFront) == BANK(MoltresPicBack)

