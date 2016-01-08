; Mini Program D
;  First book of kim, page 21
;
; shows the key pressed on the display

; include our functions
.include "KimDefs.asm"

.code
.org $0200

start:
	cld		; clear dc mode, SED for decimal mode
	lda	#$00	; load 0 into A

store:
	sta	KIM_POINTH	; copy A to the first digit
	sta	KIM_POINTL	; copy A to the second digit
	sta	KIM_INH		; copy A to the third digit

	jsr	SCANDS		; refresh the display
	jsr	GETKEY		; read a key, 0x15 if no press
	jmp	store		; repeat
