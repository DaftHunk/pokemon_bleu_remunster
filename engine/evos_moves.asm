
; try to evolve the mon in [wWhichPokemon]
TryEvolvingMon:
	ld hl, wCanEvolveFlags
	xor a
	ld [hl], a
	ld a, [wWhichPokemon]
	ld c, a
	ld b, FLAG_SET
	call Evolution_FlagAction

; this is only called after battle
; it is supposed to do level up evolutions, though there is a bug that allows item evolutions to occur *fixed this bug*
EvolutionAfterBattle:
	ld a, [hTilesetType]
	push af
	xor a
	ld [wEvolutionOccurred], a
	dec a
	ld [wWhichPokemon], a
	push hl
	push bc
	push de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wispnote - We keep a pointer to the current PKMN's Level at the Beginning of the Battle.
	ld hl, wStartBattleLevels
	push hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld hl, wPartyCount
	push hl

Evolution_PartyMonLoop: ; loop over party mons
	ld hl, wWhichPokemon
	inc [hl]	;increment to current wWhichPokemon
	pop hl	;point HL to wPartyCount
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wispnote - We store current PKMN' Level at the Beginning of the Battle
; to a chosen memory address in order to be compaired later with the evolution requirements.
	pop de	;point DE to wStartBattleLevels
	ld a, [de]
	ld [wTempCoins1], a
	inc de	; increment to next wStartBattleLevels position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	inc hl	; point HL to wPartySpecies
	ld a, [hl]
	cp $ff ; have we reached the end of the party?
	jp z, .done
	ld [wEvoOldSpecies], a
	push de; wispnote - If we are not done we need to push the wStartBattleLevels pointer for the next iteration.
	push hl	; as well as the wPartySpecies pointer
	ld a, [wWhichPokemon]
	ld c, a
	ld hl, wCanEvolveFlags
	ld b, FLAG_TEST
	call Evolution_FlagAction
	ld a, c
	and a ; is the mon's bit set?
	jp z, Evolution_PartyMonLoop ; if not, go to the next mon
	ld a, [wEvoOldSpecies]
	dec a
	ld b, 0
	ld hl, EvosMovesPointerTable
	add a
	rl b
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [wcf91]
	push af
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	call LoadMonData
	pop af
	ld [wcf91], a
	pop hl

.evoEntryLoop ; loop over evolution entries
	ld a, [hli]
	and a ; have we reached the end of the evolution data?
	jr z, Evolution_PartyMonLoop
	ld b, a ; evolution type
	cp EV_TRADE
	jr z, .checkTradeEvo
; not trade evolution
	ld a, [wLinkState]
	cp LINK_STATE_TRADING
	jr z, Evolution_PartyMonLoop ; if trading, go the next mon
	ld a, b
	cp EV_ITEM
	jr z, .checkItemEvo
	ld a, [wForceEvolution]
	and a
	jr nz, Evolution_PartyMonLoop
	ld a, b
	cp EV_LEVEL
	jr z, .checkLevel
.checkTradeEvo
	ld a, [wLinkState]
	cp LINK_STATE_TRADING
	jp nz, .nextEvoEntry1 ; if not trading, go to the next evolution entry
	ld a, [hli] ; level requirement
	ld b, a
	ld a, [wLoadedMonLevel]
	cp b ; is the mon's level greater than the evolution requirement?
	jp c, Evolution_PartyMonLoop ; if so, go the next mon
	jr .doEvolution
.checkItemEvo	;joenote - .checkItemEvo updated to match pokemon yellow. this prevents erroneos stone evolutions
	ld a, [wIsInBattle] ; are we in battle?
	and a
	ld a, [hli]
	jp nz, .nextEvoEntry1 ; don't evolve if we're in a battle as wcf91 could be holding the last mon sent out
	ld b, a ; evolution item
	ld a, [wcf91] ; *fixed above* this is supposed to be the last item used, but it is also used to hold species numbers
	cp b ; was the evolution item in this entry used?
	jp nz, .nextEvoEntry1 ; if not, go to the next evolution entry

;joenote - make it so a message is printed if the level requirement for an item evolution is not met
	push hl
	ld a, [wCurEnemyLVL]
	push af
	ld a, [hl] 	; level requirement
	ld [wCurEnemyLVL], a
	ld b, a
	ld a, [wLoadedMonLevel]
	cp b ; is the mon's level less than the evolution requirement?
	jr nc, .skip_level_req_print
	ld hl, _NeededLevelText
	call PrintText
.skip_level_req_print
	pop af
	ld [wCurEnemyLVL], a
	pop hl

.checkLevel
	ld a, [hli] ; level requirement
	ld b, a
	ld a, [wLoadedMonLevel]
	cp b ; is the mon's level less than the evolution requirement?
	jp c, .nextEvoEntry2 ; if so, go the next evolution entry
.doEvolution	
	ld [wCurEnemyLVL], a
	ld a, 1
	ld [wEvolutionOccurred], a
;b has 'mon evo level requirement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - fixing an oversight where gaining multiple levels in battle then evolving can cause 
;			learning moves of the new evolution to be skipped.
			;need to store the evo level requirement somewhere.
	;wTempCoins1 was chosen because it's used only for slot machine and gets defaulted to 1 during the mini-game
; wispnote - We compare with PKMN's level at the Beginning of the Battle and keep the highest value.
	ld a, [wTempCoins1]
	cp b
	jp nc, .evoLevelRequirementSatisfied
	ld a, b
	ld [wTempCoins1], a
.evoLevelRequirementSatisfied
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	push hl
	ld a, [hl]
	ld [wEvoNewSpecies], a
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	call CopyStringToCF4B
	ld hl, IsEvolvingText
	call PrintText
	ld c, 50
	call DelayFrames
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	coord hl, 0, 0
	lb bc, 12, 20
	call ClearScreenArea
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	call ClearSprites
	callab EvolveMon
	jp c, CancelledEvolution
	ld hl, EvolvedText
	call PrintText
	pop hl
	ld a, [hl]
	ld [wd0b5], a
	ld [wLoadedMonSpecies], a
	ld [wEvoNewSpecies], a
	ld a, MONSTER_NAME
	ld [wNameListType], a
	ld a, BANK(TrainerNames) ; bank is not used for monster names
	ld [wPredefBank], a
	call GetName
	push hl
	ld hl, IntoText
	call PrintText_NoCreatingTextBox
	ld a, SFX_GET_ITEM_2
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	ld c, 40
	call DelayFrames
	call ClearScreen
	call RenameEvolvedMon
	ld a, [wPokedexNum]
	push af
	ld a, [wd0b5]
	ld [wPokedexNum], a
	predef IndexToPokedex
	ld a, [wPokedexNum]
	dec a
	ld hl, BaseStats
	ld bc, MonBaseStatsEnd - MonBaseStats
	call AddNTimes
	ld de, wMonHeader
	call CopyData
	ld a, [wd0b5]
	ld [wMonHIndex], a
	pop af
	ld [wPokedexNum], a
	ld hl, wLoadedMonHPExp - 1
	ld de, wLoadedMonStats
	ld b, $1
	call CalcStats
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld e, l
	ld d, h
	push hl
	push bc
	ld bc, wPartyMon1MaxHP - wPartyMon1
	add hl, bc
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld hl, wLoadedMonMaxHP + 1
	ld a, [hld]
	sub c
	ld c, a
	ld a, [hl]
	sbc b
	ld b, a
	ld hl, wLoadedMonHP + 1
	ld a, [hl]
	add c
	ld [hld], a
	ld a, [hl]
	adc b
	ld [hl], a
	dec hl
	pop bc
	call CopyData
	ld a, [wd0b5]
	ld [wPokedexNum], a
	xor a
	ld [wMonDataLocation], a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;joenote - fixing skip move-learn on level-up evolution
	ld a, [wFlags_D733]
	bit 6, a
	jr nz, .learn_missed_moves
	
	ld a, [wIsInBattle]
	and a
	jr z, .notinbattle
	
.learn_missed_moves
	push bc
	
	ld a, [wCurEnemyLVL]	; load the final level into a.
	ld c, a	; load the final level to over to c
	ld a, [wTempCoins1]	; load the evolution level into a
	ld b, a	; load the evolution level over to b
	dec b
.inc_level	; marker for looping back 
	inc b	;increment 	the current evolution level
	ld a, b	;put the evolution level in a
	ld [wCurEnemyLVL], a	;and reset the final level to the evolution level
	push bc	;save b & c on the stack as they hold the currently tracked evolution level a true final level
	call LearnMoveFromLevelUp
	pop bc	;get the current evolution and final level values back from the stack
	ld a, b	;load the current evolution level into a
	cp c	;compare it with the final level
	jr nz, .inc_level	;loop back again if final level has not been reached
	
	pop bc
	jr .skipfix_end
.notinbattle
	call LearnMoveFromLevelUp
.skipfix_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	pop hl
	predef SetPartyMonTypes
	ld a, [wIsInBattle]
	and a
	call z, Evolution_ReloadTilesetTilePatterns
	predef IndexToPokedex
	ld a, [wPokedexNum]
	dec a
	ld c, a
	ld b, FLAG_SET
	ld hl, wPokedexOwned
	push bc
	call Evolution_FlagAction
	pop bc
	ld hl, wPokedexSeen
	call Evolution_FlagAction
	pop de
	pop hl
	ld a, [wLoadedMonSpecies]
	ld [hl], a
	push hl
	ld l, e
	ld h, d
	jr .nextEvoEntry2

.nextEvoEntry1
	inc hl

.nextEvoEntry2
	inc hl
	jp .evoEntryLoop

.done
	pop de
	pop bc
	pop hl
	pop af
	ld [hTilesetType], a
	ld a, [wLinkState]
	cp LINK_STATE_TRADING
	ret z
	ld a, [wIsInBattle]
	and a
	ret nz
	ld a, [wEvolutionOccurred]
	and a
	call nz, PlayDefaultMusic
	ret

RenameEvolvedMon:
; Renames the mon to its new, evolved form's standard name unless it had a
; nickname, in which case the nickname is kept.
	ld a, [wd0b5]
	push af
	ld a, [wMonHIndex]
	ld [wd0b5], a
	call GetName
	pop af
	ld [wd0b5], a
	ld hl, wcd6d
	ld de, wcf4b
.compareNamesLoop
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	ret nz
	cp "@"
	jr nz, .compareNamesLoop
	ld a, [wWhichPokemon]
	ld bc, NAME_LENGTH
	ld hl, wPartyMonNicks
	call AddNTimes
	push hl
	call GetName
	ld hl, wcd6d
	pop de
	jp CopyData

CancelledEvolution:
	ld a, 2	;joenote - set something to recognize a cancelled evolution later
	ld [wEvolutionOccurred], a
	ld hl, StoppedEvolvingText
	call PrintText
	call ClearScreen
	pop hl
	call Evolution_ReloadTilesetTilePatterns
	jp Evolution_PartyMonLoop

EvolvedText:
	TX_FAR _EvolvedText
	db "@"

IntoText:
	TX_FAR _IntoText
	db "@"

StoppedEvolvingText:
	TX_FAR _StoppedEvolvingText
	db "@"

IsEvolvingText:
	TX_FAR _IsEvolvingText
	db "@"

Evolution_ReloadTilesetTilePatterns:
	ld a, [wLinkState]
	cp LINK_STATE_TRADING
	ret z
	jp ReloadTilesetTilePatterns

;joenote - this has been modified to allow for learning multiple moves at the same level
LearnMoveFromLevelUp:
	ld hl, EvosMovesPointerTable
	ld a, [wPokedexNum] ; species
	ld [wcf91], a
	dec a
	ld bc, 0
	ld hl, EvosMovesPointerTable
	add a
	rl b
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.skipEvolutionDataLoop ; loop to skip past the evolution data, which comes before the move data
	ld a, [hli]
	and a ; have we reached the end of the evolution data?
	jr nz, .skipEvolutionDataLoop ; if not, jump back up
.learnSetLoop ; loop over the learn set until we reach a move that is learnt at the current level or the end of the list
	ld a, [hli]
	and a ; have we reached the end of the learn set?
	jr z, .done ; if we've reached the end of the learn set, jump
	ld b, a ; level the move is learnt at
	ld a, [wCurEnemyLVL]
	cp b ; is the move learnt at the mon's current level?
	ld a, [hli] ; move ID
	jr nz, .learnSetLoop
	
;the move can indeed be learned at this level
.confirmlearnmove
	push hl	
	ld d, a ; ID of move to learn
	ld a, [wMonDataLocation]
	and a
	jr nz, .next
; If [wMonDataLocation] is 0 (PLAYER_PARTY_DATA), get the address of the mon's
; current moves in party data. Every call to this function sets
; [wMonDataLocation] to 0 because other data locations are not supported.
; If it is not 0, this function will not work properly.
	ld hl, wPartyMon1Moves
	ld a, [wWhichPokemon]
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
.next
	ld b, NUM_MOVES
.checkCurrentMovesLoop ; check if the move to learn is already known
	ld a, [hli]
	cp d
	jr z, .movesloop_done ; if already known, jump
	dec b
	jr nz, .checkCurrentMovesLoop
	ld a, d
	ld [wMoveNum], a
	ld [wPokedexNum], a
	call GetMoveName
	call CopyStringToCF4B
	predef LearnMove
.movesloop_done
	pop hl
	jr .learnSetLoop
	
	
.done
	ld a, [wcf91]
	ld [wPokedexNum], a
	ret

; writes the moves a mon has at level [wCurEnemyLVL] to [de]
; move slots are being filled up sequentially and shifted if all slots are full
WriteMonMoves:
	call GetPredefRegisters
	push hl
	push de
	push bc
	ld hl, EvosMovesPointerTable
	ld b, 0
	ld a, [wcf91]  ; cur mon ID
	dec a
	add a
	rl b
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.skipEvoEntriesLoop
	ld a, [hli]
	and a
	jr nz, .skipEvoEntriesLoop
	jr .firstMove
.nextMove
	pop de
.nextMove2
	inc hl
.firstMove
	ld a, [hli]       ; read level of next move in learnset
	and a
	jp z, .done       ; end of list
	ld b, a
	ld a, [wCurEnemyLVL]
	cp b
	jp c, .done       ; mon level < move level (assumption: learnset is sorted by level)
	ld a, [wLearningMovesFromDayCare]
	and a
	jr z, .skipMinLevelCheck
	ld a, [wDayCareStartLevel]
	cp b
	jr nc, .nextMove2 ; min level >= move level

.skipMinLevelCheck

; check if the move is already known
	push de
	call CheckForBumpingSameMove	;joenote - extra functionality
	jr nz, .alreadyKnowsCheckLoop_end
	ld c, NUM_MOVES
.alreadyKnowsCheckLoop
	ld a, [de]
	inc de
	cp [hl]
	jr z, .nextMove
	dec c
	jr nz, .alreadyKnowsCheckLoop
.alreadyKnowsCheckLoop_end

; try to find an empty move slot
	pop de
	push de
	ld c, NUM_MOVES
.findEmptySlotLoop
	ld a, [de]
	and a
	jr z, .writeMoveToSlot2
	inc de
	dec c
	jr nz, .findEmptySlotLoop

; no empty move slots found
	pop de
	push de
	push hl
	ld h, d
	ld l, e
	call WriteMonMoves_ShiftMoveData ; shift all moves one up (deleting move 1)
	ld a, [wLearningMovesFromDayCare]
	and a
	jr z, .writeMoveToSlot

; shift PP as well if learning moves from day care
	push de
	ld bc, wPartyMon1PP - (wPartyMon1Moves + 3)
	add hl, bc
	ld d, h
	ld e, l
	call WriteMonMoves_ShiftMoveData ; shift all move PP data one up
	pop de

.writeMoveToSlot
	pop hl
.writeMoveToSlot2
	ld a, [hl]
	ld [de], a
	ld a, [wLearningMovesFromDayCare]
	and a
	jr z, .nextMove

; write move PP value if learning moves from day care
	push hl
	ld a, [hl]
	ld hl, wPartyMon1PP - wPartyMon1Moves
	add hl, de
	push hl
	dec a
	ld hl, Moves
	ld bc, MoveEnd - Moves
	call AddNTimes
	ld de, wBuffer
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wBuffer + 5]
	pop hl
	ld [hl], a
	pop hl
	jr .nextMove

.done
	pop bc
	pop de
	pop hl
	ret

; shifts all move data one up (freeing 4th move slot)
WriteMonMoves_ShiftMoveData:
	ld c, NUM_MOVES - 1
.loop
	inc de
	ld a, [de]
	ld [hli], a
	dec c
	jr nz, .loop
	ret

Evolution_FlagAction:
	predef_jump FlagActionPredef

;joenote - custom function by Mateo for move relearner
PrepareRelearnableMoveList:	
; Loads relearnable move list to wMoveBuffer.
; Input: party mon index = [wWhichPokemon]
	; Get mon id.
	ld a, [wWhichPokemon]
	ld c, a
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld a, [hl] ; a = mon id
	ld [wd0b5], a	;joenote - put mon id into wram for potential later usage of GetMonHeader
	; Get pointer to evos moves data.
	dec a
	ld c, a
	ld b, 0
	ld hl, EvosMovesPointerTable
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a  ; hl = pointer to evos moves data for our mon
	push hl
	; Get pointer to mon's currently-known moves.
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Level
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [hl]
	ld b, a
	push bc
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	pop bc
	ld d, h
	ld e, l
	pop hl
	; Skip over evolution data.
.skipEvoEntriesLoop
	ld a, [hli]
	and a
	jr nz, .skipEvoEntriesLoop
	; Write list of relearnable moves, while keeping count along the way.
	; de = pointer to mon's currently-known moves
	; hl = pointer to moves data for our mon
	;  b = mon's level
	ld c, 0 ; c = count of relearnable moves
.loop
	ld a, [hli]
	and a
	jr z, .done
	cp b
	jr c, .addMove
	jr nz, .done
.addMove
	push bc
	ld a, [hli] ; move id
	ld b, a
	; Check if move is already known by our mon.
	push de
	ld a, [de]
	cp b
	jr z, .knowsMove
	inc de
	ld a, [de]
	cp b
	jr z, .knowsMove
	inc de
	ld a, [de]
	cp b
	jr z, .knowsMove
	inc de
	ld a, [de]
	cp b
	jr z, .knowsMove
.relearnableMove
	pop de
	push hl
	; Add move to the list, and update the running count.
	ld a, b
	ld b, 0
	ld hl, wMoveBuffer + 1
	add hl, bc
	ld [hl], a
	pop hl
	pop bc
	inc c
	jr .loop
.knowsMove
	pop de
	pop bc
	jr .loop
.done	

;joenote - start checking for level-0 moves
	xor a
	ld b, a	;b will act as a counter, as there can only be up to 4 level-0 moves
	call GetMonHeader ;mon id already stored earlier in wd0b5
	ld hl, wMonHMoves
.loop2
	ld a, b	;get the current loop counter into a
	cp $4
	jr nc, .done2	;if gone through 4 moves already, reached the end of the list. move to done2.
	ld a, [hl]	;load move
	and a
	jr z, .done2	;if move has id 0, list has reached the end early. move to done2.
	
	;check if the move is already in the learnable move list
	push bc
	push hl
	;c = buffer length
.buffer_loop
	ld hl, wMoveBuffer
	ld b, 0
	add hl, bc	;move to buffer at current c value
	ld b, a	;b = move id
	ld a, [hl] ; move id at buffer point
	cp b
	ld a, b	;a = move id
	jr z, .move_in_buffer
	inc c
	dec c
	jr z, .end_buffer_loop	;jump out if start of buffer is reached
	dec c	;else decrement c and loop again
	jr .buffer_loop
.move_in_buffer
	pop hl
	pop bc
	inc hl	;increment to the next level-0 move
	inc b	;increment the loop counter
	jr .loop2
.end_buffer_loop
	pop hl
	pop bc
	
	;Check if move is already known by our mon.
	push bc
	ld a, [hl] ; move id
	ld b, a
	push de
	ld a, [de]
	cp b
	jr z, .knowsMove2
	inc de
	ld a, [de]
	cp b
	jr z, .knowsMove2
	inc de
	ld a, [de]
	cp b
	jr z, .knowsMove2
	inc de
	ld a, [de]
	cp b
	jr z, .knowsMove2

	;if the move is not already known, add it to the learnable move list
	pop de
	push hl
	; Add move to the list, and update the running count.
	ld a, b
	ld b, 0
	ld hl, wMoveBuffer + 1
	add hl, bc
	ld [hl], a
	pop hl
	pop bc
	inc c
	inc hl	;increment to the next level-0 move
	inc b	;increment the loop counter
	jr .loop2
	
.knowsMove2
	pop de
	pop bc
	inc hl	;increment to the next level-0 move
	inc b	;increment the loop counter
	jr .loop2
	
.done2
	ld b, 0
	ld hl, wMoveBuffer + 1
	add hl, bc
	ld a, $ff
	ld [hl], a
	ld hl, wMoveBuffer
	ld [hl], c
	ret
	

;joenote - This function makes it so that if a move is in the first slot you can bump it out with itself in a learn list 
CheckForBumpingSameMove:
;DE points to first move slot on the pokemon
;HL points to move on the learn list
;return with z flag set if the move on the learn list is to be ignored
;return with z flag cleared if the learn list move is... 
;	- the same as the 1st move slot
;	- and all four move slots are full
;	- and the intent is to bump the move out of the 1st move slot and slide the same move into the 4th slot
	push de
	;increment to 4th move slot
	inc de
	inc de
	inc de
	;return if this slot is $00, since it means the slots are not all full
	ld a, [de]
	and a
	jr z, .return
	;else all the slots are full, so point back to the first slot
	pop de
	push de
	;see if the list move and the 1st slot move are the same
	ld a, [de]
	cp [hl]
	jr z, .clear_z_flag
	xor a
	jr .return
.clear_z_flag
	ld a, 1
	and a
.return
	pop de
	ret


;joenote - make it so a message is printed if the level requirement for an item evolution is not met
_NeededLevelText:
	text "Niveau @"
	TX_NUM wCurEnemyLVL, 1, 3
	text " requis!"
	prompt

PrepareLevelUpMoveList:: ; I don't know how the fuck you're a single colon in shin pokered but it sure as shit doesn't work here - PvK
 ; Loads relearnable move list to wMoveBuffer.
 ; Input: party mon index = [wWhichPokemon]
 	; Get mon id.
 	ld a, [wWhichPokemon]
 	ld [wd0b5], a	;joenote - put mon id into wram for potential later usage of GetMonHeader
 
 	ld de, wMoveBuffer ; de = moves list
 	ld c, 0 ; c = count of relearnable moves
 
 	;joenote - start checking for level-0 moves
 	xor a
 	ld b, a	;b will act as a counter, as there can only be up to 4 level-0 moves
 	call GetMonHeader ;mon id already stored earlier in wd0b5
 	ld hl, wMonHMoves
 .loop2
 	ld a, b	;get the current loop counter into a
 	cp $4
 	jr nc, .done2	;if gone through 4 moves already, reached the end of the list. move to done2.
 	ld a, [hl]	;load move
 	and a
 	jr z, .done2	;if move has id 0, list has reached the end early. move to done2.
 
 	; Add move to the list, and update the running count.
 	ld a, 1
 	ld [de], a
 	inc de
 
 	ld a, [hl]	;load move
 	ld [de], a
 	inc de
 	inc c
 	inc hl	;increment to the next level-0 move
 	inc b	;increment the loop counter
 	jr .loop2
 .done2
 	
 	push bc
 	; Get pointer to evos moves data.
 	ld a, [wWhichPokemon]
 	dec a
 	ld c, a
 	ld b, 0
 	ld hl, EvosMovesPointerTable
 	add hl, bc
 	add hl, bc
 	ld a, [hli]
 	ld h, [hl]
 	ld l, a  ; hl = pointer to evos moves data for our mon
 	pop bc
 
 	; Skip over evolution data.
 .skipEvoEntriesLoop
 	ld a, [hli]
 	and a
 	jr nz, .skipEvoEntriesLoop
 	; Write list of relearnable moves, while keeping count along the way.
 	ld b, 100 ;  b = mon's level
 
 .loop
 	ld a, [hli]
 	and a
 	jr z, .done
 
 	cp b
 	jr c, .addMove
 	jr nz, .done
 .addMove
 	ld [de], a
 	inc de
 
 	ld a, [hli] ; move id
 	; Add move to the list, and update the running count.
 	ld [de], a
 	inc de
 	inc c
 	jr .loop
 .done
 	ld a, c
 	ld [wMoveListCounter], a ; number of moves in the list
 .debug
 	ret

INCLUDE "data/moves/evos_moves.asm"
