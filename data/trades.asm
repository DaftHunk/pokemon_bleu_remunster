TradeMons:
; givemonster, getmonster, textstring, nickname (11 bytes), 14 bytes total
;unused localization names for blue-jp trades per 
;https://tcrf.net/Development:Pok%C3%A9mon_Red_and_Blue/Localization#Pok%C3%A9mon_Nicknames
;	FLUFFY
;	MYMO
;	<beedrill has no localized name>
;	VALERIE
;	SWANNY
;	JIMBO
;	MICHELLE
;	JENNY
;	SHANE
;	WAGSTER
	db NIDORINO,  NIDORINA, 0,"BIBICHE@@@@"
	db ABRA,      MR_MIME,  0,"MARCEL@@@@@"
	db BUTTERFREE,BEEDRILL, 2,"CHIKUCHIKU@"
	db PONYTA,    SEEL,     0,"BIBI@@@@@@@"
	db SPEAROW,   FARFETCHD,2,"JULIO@@@@@@"
	db SLOWBRO,   LICKITUNG,0,"GLAVIOTEUR@"
	db POLIWHIRL, JYNX,     1,"NINI@@@@@@@"
	db RAICHU,    ELECTRODE,1,"KOURJUS@@@@"
	db VENONAT,   TANGELA,  2,"BIGOUDI@@@@"
;	db NIDORAN_M, NIDORAN_F,2,"FABI@@@@@@@"	;joenote - this was probably accidentally swapped by the localization team
	db NIDORAN_F, NIDORAN_M,2,"FABI@@@@@@@"
