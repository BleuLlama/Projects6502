; Mini Program B
;  First book of kim, page 14
;
; Sets memory 0030 through 0039 with 0x42


; include our functions
.include "KimDefs.asm"

.code
.org $0200

start:
	lda	#$42	; value 0x42 into A
	ldx	#$09	; value 0x09 into X

loop:
	sta	$30, X	; write 0x42 into (30+X)
	dex		; x=x-1
	bpl	loop	; if x > 0, re-loop
	
	brk		; end execution
