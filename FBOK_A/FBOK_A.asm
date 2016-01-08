; First book of kim, page 9
; Swaps data in addrs $10, $11


; include our functions
.include "KimDefs.asm"

.code
.org $0200

start:
	lda	$10	; Address "10" to A
	ldx	$11	; Address "11" to x
	sta	$11	; a to address "11"
	stx	$10	; x to address "10"
	brk

.org $0010
.byte	$10, $11
