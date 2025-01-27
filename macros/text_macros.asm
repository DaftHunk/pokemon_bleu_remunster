
; text macros
DEF text   EQUS "db $00," ; Start writing text.
DEF next   EQUS "db $4e," ; Move a line down.
DEF line   EQUS "db $4f," ; Start writing at the bottom line.
DEF para   EQUS "db $51," ; Start a new paragraph.
DEF cont   EQUS "db $55," ; Scroll to the next line.
DEF autocont   EQUS "db $4C," ; Auto-Scroll to the next line.
DEF done   EQUS "db $57"  ; End a text box.
DEF prompt EQUS "db $58"  ; Prompt the player to end a text box (initiating some other event).

DEF page   EQUS "db $49,"     ; Start a new Pokedex page.
DEF dex    EQUS "db $5f, $50" ; End a Pokedex entry.

DEF wStringBuffer EQUS "wcf4b" ; Alias for french text

MACRO text_start ; Alias for french text
	db $00
ENDM

MACRO TX_RAM
; prints text to screen
; \1: RAM address to read from
	db $1
	dw \1
ENDM

MACRO text_ram ; Alias for french text
	TX_RAM \1
ENDM

MACRO TX_BCD
; \1: RAM address to read from
; \2: number of bytes + print flags
	db $2
	dw \1
	db \2
ENDM

MACRO text_bcd ; Alias for french text
	TX_BCD \1, \2
ENDM

DEF TX_LINE    EQUS "db $05"
DEF TX_BLINK   EQUS "db $06"
;DEF TX_SCROLL EQUS "db $07"
DEF TX_ASM     EQUS "db $08"

MACRO TX_NUM
; print a big-endian decimal number.
; \1: address to read from
; \2: number of bytes to read
; \3: number of digits to display
	db $09
	dw \1
	db \2 << 4 | \3
ENDM

MACRO text_decimal ; Alias for french text
	TX_NUM \1, \2, \3
ENDM

DEF TX_DELAY              EQUS "db $0a"
DEF TX_SFX_ITEM_1         EQUS "db $0b"
DEF TX_SFX_LEVEL_UP       EQUS "db $0b"
;DEF TX_ELLIPSES          EQUS "db $0c"
DEF TX_WAIT               EQUS "db $0d"
;DEF TX_SFX_DEX_RATING    EQUS "db $0e"
DEF TX_SFX_ITEM_2         EQUS "db $10"
DEF TX_SFX_KEY_ITEM       EQUS "db $11"
DEF TX_SFX_CAUGHT_MON     EQUS "db $12"
DEF TX_SFX_DEX_PAGE_ADDED EQUS "db $13"
DEF TX_CRY_NIDORINO       EQUS "db $14"
DEF TX_CRY_PIDGEOT        EQUS "db $15"
;DEF TX_CRY_DEWGONG       EQUS "db $16"

MACRO TX_FAR
	db $17
	dw \1
	db BANK(\1)
ENDM

DEF TX_VENDING_MACHINE         EQUS "db $f5"
DEF TX_CABLE_CLUB_RECEPTIONIST EQUS "db $f6"
DEF TX_PRIZE_VENDOR            EQUS "db $f7"
DEF TX_POKECENTER_PC           EQUS "db $f9"
DEF TX_PLAYERS_PC              EQUS "db $fc"
DEF TX_BILLS_PC                EQUS "db $fd"

MACRO TX_MART
	db $FE, _NARG
	REPT _NARG
	db \1
	SHIFT
	ENDR
	db $FF
ENDM

DEF TX_POKECENTER_NURSE        EQUS "db $ff"

MACRO text_end ; Alias for french text
	db $50
ENDM
