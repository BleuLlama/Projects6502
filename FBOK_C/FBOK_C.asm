; Mini Program C
;  First book of kim, page 19
;
; Display something to the LED Display


; include our functions
.include "KimDefs.asm"

.code
.org $0200

start:
	lda	#$42		; put 0x42 into A
	sta	KIM_POINTH	; put it into the first digit
	sta	KIM_POINTL	; put it into the second digit
	sta	KIM_INH		; put it into the third digit
loop:
	jsr	SCANDS		; display it to the screen
	jmp 	loop
