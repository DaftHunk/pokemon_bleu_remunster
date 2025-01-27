DEF vChars0 EQU $8000
DEF vChars1 EQU $8800
DEF vChars2 EQU $9000
DEF vBGMap0 EQU $9800
DEF vBGMap1 EQU $9c00

; Battle/Menu
DEF vSprites  EQU vChars0
DEF vFont     EQU vChars1
DEF vFrontPic EQU vChars2
DEF vBackPic  EQU vFrontPic + 7 * 7 * $10

; Overworld
DEF vNPCSprites  EQU vChars0
DEF vNPCSprites2 EQU vChars1
DEF vTileset     EQU vChars2

; Title
DEF vTitleLogo  EQU vChars1
DEF vTitleLogo2 EQU vFrontPic + 7 * 7 * $10

