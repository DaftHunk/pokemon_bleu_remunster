; non-volatile statuses
DEF SLP EQU %111 ; sleep counter
DEF PSN EQU 3
DEF BRN EQU 4
DEF FRZ EQU 5
DEF PAR EQU 6
DEF SLP_NOMOVE EQU %110	;joenote - sleep counter for when choosing won't be used on wakeup

; volatile statuses 1
DEF STORING_ENERGY           EQU 0 ; Bide
DEF THRASHING_ABOUT          EQU 1 ; e.g. Thrash
DEF ATTACKING_MULTIPLE_TIMES EQU 2 ; e.g. Double Kick, Fury Attack
DEF FLINCHED                 EQU 3
DEF CHARGING_UP              EQU 4 ; e.g. Solar Beam, Fly
DEF USING_TRAPPING_MOVE      EQU 5 ; e.g. Wrap
DEF INVULNERABLE             EQU 6 ; charging up Fly/Dig
DEF CONFUSED                 EQU 7

; volatile statuses 2
DEF USING_X_ACCURACY    EQU 0
DEF PROTECTED_BY_MIST   EQU 1
DEF GETTING_PUMPED      EQU 2 ; Focus Energy
;                   EQU 3 ; unused
DEF HAS_SUBSTITUTE_UP   EQU 4
DEF NEEDS_TO_RECHARGE   EQU 5 ; Hyper Beam
DEF USING_RAGE          EQU 6
DEF SEEDED              EQU 7

; volatile statuses 3
DEF BADLY_POISONED      EQU 0
DEF HAS_LIGHT_SCREEN_UP EQU 1
DEF HAS_REFLECT_UP      EQU 2
DEF TRANSFORMED         EQU 3
;joenote - for trapping spam counter
DEF TRAPPING_COUNT EQU 6
DEF TRAPPING_NEGATIVE EQU 7
DEF TRAPPING_COUNT_BIT EQU %01000000
DEF TRAPPING_NEGATIVE_BIT EQU %10000000

