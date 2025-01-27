DEF hSoftReset EQU $FF8A
; Initialized to 16.
; Decremented each input iteration if the player
; presses the reset sequence (A+B+SEL+START).
; Soft reset when 0 is reached.

; base tile ID to which offsets are added
DEF hBaseTileID EQU $FF8B

; 3-byte BCD number
DEF hItemPrice EQU $FF8B

DEF hDexWeight EQU $FF8B

DEF hWarpDestinationMap EQU $FF8B

DEF hOAMTile EQU $FF8B

DEF hROMBankTemp EQU $FF8B

DEF hPreviousTileset EQU $FF8B

DEF hEastWestConnectedMapWidth EQU $FF8B

DEF hSlideAmount EQU $FF8B

DEF hRLEByteValue EQU $FF8B

DEF H_SPRITEWIDTH            EQU $FF8B ; in tiles
DEF H_SPRITEINTERLACECOUNTER EQU $FF8B
DEF H_SPRITEHEIGHT           EQU $FF8C ; in tiles
DEF H_SPRITEOFFSET           EQU $FF8D

; counters for blinking down arrow
DEF H_DOWNARROWBLINKCNT1 EQU $FF8B
DEF H_DOWNARROWBLINKCNT2 EQU $FF8C

DEF H_SPRITEDATAOFFSET EQU $FF8B
DEF H_SPRITEINDEX      EQU $FF8C

DEF hMapStride EQU $FF8B
DEF hMapWidth  EQU $FF8C

DEF hNorthSouthConnectionStripWidth EQU $FF8B
DEF hNorthSouthConnectedMapWidth    EQU $FF8C

; DisplayTextID's argument
DEF hSpriteIndexOrTextID EQU $FF8C

DEF hPartyMonIndex EQU $FF8C

; the total number of tiles being shifted each time the pic slides by one tile
DEF hSlidingRegionSize EQU $FF8C

; 2 bytes
DEF hEnemySpeed EQU $FF8D

DEF hVRAMSlot EQU $FF8D

DEF hFourTileSpriteCount EQU $FF8E

; -1 = left
;  0 = right
DEF hSlideDirection EQU $FF8D

DEF hSpriteFacingDirection EQU $FF8D

DEF hSpriteMovementByte2 EQU $FF8D

DEF hSpriteImageIndex EQU $FF8D

DEF hLoadSpriteTemp1 EQU $FF8D
DEF hLoadSpriteTemp2 EQU $FF8E

DEF hHalveItemPrices EQU $FF8E

DEF hSpriteOffset2 EQU $FF8F

DEF hOAMBufferOffset EQU $FF90

DEF hSpriteScreenX EQU $FF91
DEF hSpriteScreenY EQU $FF92

DEF hTilePlayerStandingOn EQU $FF93

DEF hSpritePriority EQU $FF94

; 2 bytes
DEF hSignCoordPointer EQU $FF95

DEF hNPCMovementDirections2Index EQU $FF95

; CalcPositionOfPlayerRelativeToNPC
DEF hNPCSpriteOffset EQU $FF95

; temp value used when swapping bytes
DEF hSwapTemp EQU $FF95
DEF hSwapItemID EQU $FF95
DEF hSwapItemQuantity EQU $FF96

DEF hExperience EQU $FF96 ; 3 bytes, big endian

; Multiplication and division variables are meant
; to overlap for back-to-back usage. Big endian.

DEF H_MULTIPLICAND EQU $FF96 ; 3 bytes
DEF H_MULTIPLIER   EQU $FF99 ; 1 byte
DEF H_PRODUCT      EQU $FF95 ; 4 bytes

DEF H_DIVIDEND     EQU $FF95 ; 4 bytes
DEF H_DIVISOR      EQU $FF99 ; 1 byte
DEF H_QUOTIENT     EQU $FF95 ; 4 bytes
DEF H_REMAINDER    EQU $FF99 ; 1 byte

DEF H_DIVIDEBUFFER EQU $FF9A

DEF H_MULTIPLYBUFFER EQU $FF9B

; PrintNumber (big endian).
DEF H_PASTLEADINGZEROES EQU $FF95 ; last char printed
DEF H_NUMTOPRINT        EQU $FF96 ; 3 bytes
DEF H_POWEROFTEN        EQU $FF99 ; 3 bytes
DEF H_SAVEDNUMTOPRINT   EQU $FF9C ; 3 bytes

; distance in steps between NPC and player
DEF hNPCPlayerYDistance EQU $FF95
DEF hNPCPlayerXDistance EQU $FF96

DEF hFindPathNumSteps EQU $FF97

; bit 0: set when the end of the path's Y coordinate matches the target's
; bit 1: set when the end of the path's X coordinate matches the target's
; When both bits are set, the end of the path is at the target's position
; (i.e. the path has been found).
DEF hFindPathFlags EQU $FF98

DEF hFindPathYProgress EQU $FF99
DEF hFindPathXProgress EQU $FF9A

; 0 = from player to NPC
; 1 = from NPC to player
DEF hNPCPlayerRelativePosPerspective EQU $FF9B

; bit 0:
; 0 = target is to the south or aligned
; 1 = target is to the north
; bit 1:
; 0 = target is to the east or aligned
; 1 = target is to the west
DEF hNPCPlayerRelativePosFlags EQU $FF9D

; some code zeroes this for no reason when writing a coin amount
DEF hUnusedCoinsByte EQU $FF9F

DEF hMoney EQU $FF9F ; 3-byte BCD number
DEF hCoins EQU $FFA0 ; 2-byte BCD number

DEF hDivideBCDDivisor  EQU $FFA2 ; 3-byte BCD number
DEF hDivideBCDQuotient EQU $FFA2 ; 3-byte BCD number
DEF hDivideBCDBuffer   EQU $FFA5 ; 3-byte BCD number

DEF hSerialReceivedNewData EQU $FFA9

; $01 = using external clock
; $02 = using internal clock
; $ff = establishing connection
DEF hSerialConnectionStatus EQU $FFAA

DEF hSerialIgnoringInitialData EQU $FFAB

DEF hSerialSendData EQU $FFAC

DEF hSerialReceiveData EQU $FFAD

; these values are copied to SCX, SCY, and WY during V-blank
DEF hSCX EQU $FFAE
DEF hSCY EQU $FFAF
DEF hWY  EQU $FFB0

DEF hJoyLast     EQU $FFB1
DEF hJoyReleased EQU $FFB2
DEF hJoyPressed  EQU $FFB3
DEF hJoyHeld     EQU $FFB4
DEF hJoy5        EQU $FFB5
DEF hJoy6        EQU $FFB6
DEF hJoy7        EQU $FFB7

DEF H_LOADEDROMBANK EQU $FFB8

DEF hSavedROMBank EQU $FFB9

; is automatic background transfer during V-blank enabled?
; if nonzero, yes
; if zero, no
DEF H_AUTOBGTRANSFERENABLED EQU $FFBA

DEF TRANSFERTOP    EQU 0
DEF TRANSFERMIDDLE EQU 1
DEF TRANSFERBOTTOM EQU 2

; 00 = top third of background
; 01 = middle third of background
; 02 = bottom third of background
DEF H_AUTOBGTRANSFERPORTION EQU $FFBB

; the destination address of the automatic background transfer
DEF H_AUTOBGTRANSFERDEST EQU $FFBC ; 2 bytes

; temporary storage for stack pointer during memory transfers that use pop
; to increase speed
DEF H_SPTEMP EQU $FFBF ; 2 bytes

; source address for VBlankCopyBgMap function
; the first byte doubles as the byte that enabled the transfer.
; if it is 0, the transfer is disabled
; if it is not 0, the transfer is enabled
; this means that XX00 is not a valid source address
DEF H_VBCOPYBGSRC EQU $FFC1 ; 2 bytes

; destination address for VBlankCopyBgMap function
DEF H_VBCOPYBGDEST EQU $FFC3 ; 2 bytes

; number of rows for VBlankCopyBgMap to copy
DEF H_VBCOPYBGNUMROWS EQU $FFC5

; size of VBlankCopy transfer in 16-byte units
DEF H_VBCOPYSIZE EQU $FFC6

; source address for VBlankCopy function
DEF H_VBCOPYSRC EQU $FFC7

; destination address for VBlankCopy function
DEF H_VBCOPYDEST EQU $FFC9

; size of source data for VBlankCopyDouble in 8-byte units
DEF H_VBCOPYDOUBLESIZE EQU $FFCB

; source address for VBlankCopyDouble function
DEF H_VBCOPYDOUBLESRC EQU $FFCC

; destination address for VBlankCopyDouble function
DEF H_VBCOPYDOUBLEDEST EQU $FFCE

; controls whether a row or column of 2x2 tile blocks is redrawn in V-blank
; 00 = no redraw
; 01 = redraw column
; 02 = redraw row
DEF hRedrawRowOrColumnMode EQU $FFD0

DEF REDRAW_COL EQU 1
DEF REDRAW_ROW EQU 2

DEF hRedrawRowOrColumnDest EQU $FFD1

DEF hRandomAdd EQU $FFD3
DEF hRandomSub EQU $FFD4

DEF H_FRAMECOUNTER EQU $FFD5 ; decremented every V-blank (used for delays)

; V-blank sets this to 0 each time it runs.
; So, by setting it to a nonzero value and waiting for it to become 0 again,
; you can detect that the V-blank handler has run since then.
DEF H_VBLANKOCCURRED EQU $FFD6

; 00 = indoor
; 01 = cave
; 02 = outdoor
; this is often set to 00 in order to turn off water and flower BG tile animations
DEF hTilesetType EQU $FFD7

DEF hMovingBGTilesCounter1 EQU $FFD8

DEF H_CURRENTSPRITEOFFSET EQU $FFDA ; multiple of $10

DEF hItemCounter EQU $FFDB

DEF hGymGateIndex EQU $FFDB

DEF hGymTrashCanRandNumMask EQU $FFDB

DEF hDexRatingNumMonsSeen  EQU $FFDB
DEF hDexRatingNumMonsOwned EQU $FFDC

; $00 = bag full
; $01 = got item
; $80 = didn't meet required number of owned mons
; $FF = player cancelled
DEF hOaksAideResult       EQU $FFDB

DEF hOaksAideRequirement  EQU $FFDB ; required number of owned mons
DEF hOaksAideRewardItem   EQU $FFDC
DEF hOaksAideNumMonsOwned EQU $FFDD

DEF hItemToRemoveID    EQU $FFDB
DEF hItemToRemoveIndex EQU $FFDC

DEF hVendingMachineItem  EQU $FFDB
DEF hVendingMachinePrice EQU $FFDC ; 3-byte BCD number

; the first tile ID in a sequence of tile IDs that increase by 1 each step
DEF hStartTileID EQU $FFE1

DEF hNewPartyLength EQU $FFE4

DEF hDividend2 EQU $FFE5
DEF hDivisor2  EQU $FFE6
DEF hQuotient2 EQU $FFE7

DEF hSpriteVRAMSlotAndFacing EQU $FFE9

DEF hCoordsInFrontOfPlayerMatch EQU $FFEA

DEF hSpriteAnimFrameCounter EQU $FFEA

DEF hRandomLast EQU $FFF0 ; FFF1	;2 bites for xor-shift rng

DEF H_WHOFIRST EQU $FFF2 ; joenote - 0 on player going first, 1 on enemy going first
DEF H_WHOSETURN EQU $FFF3 ; 0 on player’s turn, 1 on enemy’s turn

DEF hClearLetterPrintingDelayFlags EQU $FFF4

;$FFF5 --> used for an LCDC OAM timing test

DEF hFlags_0xFFF6 EQU $FFF6	;has to do with a bunch of menu spacing and stuff
; bit 0: draw HP fraction to the right of bar instead of below (for party menu)
; bit 1: menu is double spaced
; bit 2: something about skipping a line when printing text

DEF hFieldMoveMonMenuTopMenuItemX EQU $FFF7

DEF hDisableJoypadPolling EQU $FFF9

DEF hJoyInput EQU $FFF8

DEF hFlagsFFFA EQU $FFFA	;joenote - added for various uses
;bit 0 - PrepareOAMData and DMARoutine will not run in Vblank while this bit is set
;bit 1 - BGmap update functions will not run in Vblank while this bit is set
;bit 2 - This gets set to indicate that a sfx is playing while printing text
;bit 3 - When set, the CopyData function will only copy when safe to do so for VRAM
DEF hRGB EQU $FFFB	; FFFB=Red, FFFC=Green, FFFD=BLUE	;3 bytes ;joenote - used to store color RGB color values
DEF hGBC EQU $FFFE ;gbcnote - 0 if DMG or SGB, != 0 if GBC, =2 for gamma shader
