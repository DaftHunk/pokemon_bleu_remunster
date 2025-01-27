; list menu ID's
DEF PCPOKEMONLISTMENU  EQU $00 ; PC pokemon withdraw/deposit lists
DEF MOVESLISTMENU      EQU $01 ; XXX where is this used?	joenote - now used for move deleter/relearner
DEF PRICEDITEMLISTMENU EQU $02 ; Pokemart buy menu / Pokemart buy/sell choose quantity menu
DEF ITEMLISTMENU       EQU $03 ; Start menu Item menu / Pokemart sell menu
DEF SPECIALLISTMENU    EQU $04 ; list of special "items" e.g. floor list in elevators / list of badges

DEF MONSTER_NAME  EQU 1
DEF MOVE_NAME     EQU 2
; ???_NAME    EQU 3	;joenote - adding tm & hm names in this spot
DEF TMHM_NAME	  EQU 3
DEF ITEM_NAME     EQU 4
DEF PLAYEROT_NAME EQU 5
DEF ENEMYOT_NAME  EQU 6
DEF TRAINER_NAME  EQU 7

DEF INIT_ENEMYOT_LIST    EQU 1
DEF INIT_BAG_ITEM_LIST   EQU 2
DEF INIT_OTHER_ITEM_LIST EQU 3
DEF INIT_PLAYEROT_LIST   EQU 4
DEF INIT_MON_LIST        EQU 5
