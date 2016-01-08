;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; program to test the display
; 2015-11-15
; this is my first ever 6502 program!
; Scott Lawrence - yorgle@gmail.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; define the functionality we want to use in the library
UseVideoDisplay0 = 1 ; video display 0

.define VERSIONH #$00
.define VERSIONL #$01

; include our functions
.include "KimDefs.asm"
.include "KimLib.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RAM used
KEYBAK	     = $10


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
.if .defined(UseVideoDisplay0)
	jsr	cls		; clear the screen black
.endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

keycolor:
	; 1. clear the 7 segment display
	lda	#$00
	sta	KIM_POINTH 	; left two digits
	sta	KIM_POINTL	; middle two digits
	sta	KIM_INH		; right two digits
	jsr	SCANS		; draw it to the display

keyloop:
	; check for key
	jsr	GETKEY		; get a keypress
	cmp	KEY_NONE 	; $15 is "no press"
	beq	keyloop		; then there's no press, check again
	
	sta	KEYBAK

	; copy it to the screen
	sta	KIM_INH
	jsr	SCANS		; and display it to the screen


.if .defined(UseVideoDisplay0)
	; and display the color
	lda	KEYBAK
	jsr	fillscr		; fill the screen
.endif

	jmp 	keyloop		; repeat...
