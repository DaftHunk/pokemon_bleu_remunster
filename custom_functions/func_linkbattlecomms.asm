
SyncBattleClauses:
;Exchanges battle clause flags with the link opponent.
;If your opponent has clauses set that you have not, then those clauses will be set for you.
;If you have clauses set that your opponent has not, then those clauses will be set for him.
;This results in both players having the same clause flags set.
;Sets the Z flag if successful.

	call VerifyComms
	ret nz

	call ClauseFlagsToNybble
	call ExchangeNybbleBC
	ret nz
	
	;bitwise OR your clauses with the opponent's clauses
	ld a, b
	or c
	ld b, a
	
	;exchange the OR'd clause nybble and verify it matches what the opponent has
	call ExchangeNybbleBC
	ret nz
	ld a, b
	cp c
	ret nz	;return
	
	call NybbleToClauses
	
	
	xor a	;success, so set Z flag
	ret



;Verify that there is a proper link connection. Sets the Z flag if true.
VerifyComms:
	;wUnknownSerialCounter is two bytes. Write the default of 03 00 to it.
	;This acts as a timeout counter for when two linked gameboys are trying to sync up.
	;We set it to its default because if it is left as zero then the syncing can get stuck in an infinite loop.
	ld hl, wUnknownSerialCounter
	ld a, $3
	ld [hli], a
	xor a
	ld [hl], a
	;wSerialExchangeNybbleSendData holds the nybble (a half-byte of 0 to f) to send to the other game.
	;Let's send a 0 across the link to make sure the other game can communicate.
	ld [wSerialExchangeNybbleSendData], a
	call Serial_PrintWaitingTextAndSyncAndExchangeNybble
	call CheckCommTimeout
	ret nz	;return if a timeout happened
	;wSerialExchangeNybbleReceiveData holds the nybble recieved from the other game.
	;This defaults to FF to indicate that no information was recieved.
	ld a, [wSerialExchangeNybbleReceiveData]
	and a
	;Since a 0 was sent, a 0 should also be recieved if communicating with a game that supports this check.
	;If zero is not recieved, then there is a communication error and the handshake fails.
	ret
	
;get the event bits for freeze, sleep, trapping move, and hyper beam clauses and put them in one nybble
ClauseFlagsToNybble:
	ld b, 0
	CheckEvent EVENT_ENABLE_SLEEP_CLAUSE 
	call nz, .sleep
	CheckEvent EVENT_ENABLE_FREEZE_CLAUSE 
	call nz, .freeze
	CheckEvent EVENT_ENABLE_TRAPPING_CLAUSE 
	call nz, .trapping
	CheckEvent EVENT_ENABLE_HYPER_BEAM_CLAUSE 
	call nz, .hyperbeam
	ret
.sleep
	set 3, b
	ret
.freeze
	set 2, b
	ret
.trapping
	set 1, b
	ret
.hyperbeam
	set 0, b
	ret

;reverse of ClauseFlagsToNybble
NybbleToClauses:
	bit 3, b
	call nz, .sleep
	bit 2, b
	call nz, .freeze
	bit 1, b
	call nz, .trapping
	bit 0, b
	call nz, .hyperbeam
	ret
.sleep
	SetEvent EVENT_ENABLE_SLEEP_CLAUSE 
	ret
.freeze
	SetEvent EVENT_ENABLE_FREEZE_CLAUSE 
	ret
.trapping
	SetEvent EVENT_ENABLE_TRAPPING_CLAUSE 
	ret
.hyperbeam
	SetEvent EVENT_ENABLE_HYPER_BEAM_CLAUSE 
	ret

;Send a nybble in register B over link
;Put the recieved nybble in register C
;Clears Z flag if connection timed out
ExchangeNybbleBC:
	;wUnknownSerialCounter is two bytes. Write the default of 03 00 to it.
	;This acts as a timeout counter for when two linked gameboys are trying to sync up.
	;We set it to its default because if it is left as zero then the syncing can get stuck in an infinite loop.
	ld hl, wUnknownSerialCounter
	ld a, $3
	ld [hli], a
	xor a
	ld [hl], a
	;wSerialExchangeNybbleSendData holds the nybble (a half-byte of 0 to f) to send to the other game.
	ld a, b
	ld [wSerialExchangeNybbleSendData], a
	push bc
	call Serial_PrintWaitingTextAndSyncAndExchangeNybble
	pop bc
	call CheckCommTimeout
	ret nz	;return if a timeout happened
	;wSerialExchangeNybbleReceiveData holds the nybble recieved from the other game.
	;This defaults to FF to indicate that no information was recieved.
	ld a, [wSerialExchangeNybbleReceiveData]
	ld c, a
	xor a
	ret

;Check wUnknownSerialCounter. If FFFF is there, then the connection timed out.
;Clears Z flag if timeout occurred
;Also resets the counter to zero
CheckCommTimeout:	
	ld hl, wUnknownSerialCounter
	ld a, [hli]
	inc a
	jr nz, .connected
	ld a, [hl]
	inc a
	jr nz, .connected
;timed out, so reset the counter and return with z flag cleared 
	;a = 0 right now
	ld [hld], a
	ld [hl], a
	dec a
	ret
.connected
	;Remember to reset the serial counter once finished
	ld hl, wUnknownSerialCounter
	xor a
	ld [hli], a
	ld [hl], a
	ret
	