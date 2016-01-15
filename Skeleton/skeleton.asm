; skeleton starting point.
; 2015-11-15
; this is my first ever 6502 program!
; Scott Lawrence - yorgle@gmail.com

; define the functionality we want to use in the library
UseVideoDisplay0 = 1

; include our functions
.include "KimDefs.asm"
.include "KimCode200.asm"
.include "KimLib.asm"

;; a little bit of ram we use

SCRATCH = $42	; 0x42: temp value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	jsr	cls	; clear the screen black
	jsr	digits	; display digits

	lda	#$0	; clear Scratch
	sta	SCRATCH

loop:
	jsr	SCANDS	; update the display

	jsr 	colors	; display color on the Video Display
	jmp	loop

	jsr 	end	; end it


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; just set the display
digits:
	lda	#$23
	sta	POINTH	; left two digits
	lda	#$AB
	sta	POINTL	; left two digits
	lda	#$EF
	sta	INH	; left two digits

	jsr	SCANDS	; and show it
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display some colors
colors:
	inc	SCRATCH	; increment it
	lda	SCRATCH	; grab the last value
	and 	#$0F	; mask lower nibble
	sta	SCRATCH	; save it for later

	jsr	fillscr	; fill the screen

	rts
