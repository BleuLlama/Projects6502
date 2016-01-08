;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LlamaCalc - a programmer's calculator for KIM (1/Uno)
;
; 2016-01 Scott Lawrence
;
;  Created for the RetroChallenge RC2016-1
; Scott Lawrence - yorgle@gmail.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$02

; v 00 02 - 2016-01-04 - 
; v 00 01 - 2016-01-01 - initial version, keypad input support


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; define the functionality we want to use in the library
UseVideoDisplay0 = 1 ; video display 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; include our support defines and libraries

.include "KimDefs.asm"
.include "KimLib.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RAM used

KEYBAK	     = $10
SHIFTSCRATCH = $11	; shifter needs this when it's running.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	ldx	#0

main0:
	lda	RANDOM
	sta	RASTER,Y
	ldy	RANDOM
	lda	RANDOM
	sta	RASTER+$100,Y
	ldy	RANDOM
	lda	RANDOM
	sta	RASTER+$200,Y
	ldy	RANDOM
	lda	RANDOM
	sta	RASTER+$300,Y
	inx
	cmp	#0
	bne	main0



.if .defined(UseVideoDisplay0)
	jsr	cls		; clear the screen black
.endif
	jsr	cls7seg
	jsr	displayVersion	; display the version number

	jmp	keyinput	; press a key, get a color
	jsr	end		; end it


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
keyinput:
	; check for key
	jsr	GETKEY		; get a keypress
	sta	KEYBAK		; KeyBak = a
	cmp	KEY_NONE 	; $15 is "no press"
	beq	keyinput	; then there's no press, check again

	; store aside a backup of the press
	;jmp	keyShiftIntoDisplay

	; check for AD/DA/PC/+ keys
	and	KEY_SPECIAL_MASK
	cmp	KEY_SPECIAL_MASK
	bne	keyShiftIntoDisplay	; nope. regular key press

	; handle a control key
handleControlKey:
	lda	KEYBAK		; restore A

	cmp	KEY_AD		; ADdress button
	beq	handle_AD
	cmp	KEY_DA		; DAta button
	beq	handle_DA
	cmp	KEY_PC		; PC button
	beq	handle_PC
	cmp	KEY_PL		; PLus button
	beq	handle_PL
	cmp	KEY_GO		; GO button
	beq	handle_GO
	jmp	keyinput	; repeat


handle_AD:
	lda	#$11
	jmp	tempAdisp

handle_DA:
	lda	#$22
	jmp	tempAdisp

handle_PC:
	lda	#$33
	jmp	tempAdisp

handle_PL:
	lda	#$44
	jmp	tempAdisp

handle_GO:
	lda	#$55
	jmp	tempAdisp


	; debugging, just display whatever's in A to the screen
tempAdisp:
	sta	KIM_POINTL	; short circuit
	lda	#$00
	sta	KIM_POINTH
	sta	KIM_INH
	jsr	SCANS		; update display
	jmp	keyinput	; repeat
	

	; handle a digit 0..F
keyShiftIntoDisplay:
	; right byte
	lda	KEYBAK		; A = Key pressed (A to be shifted in)

	ldx	KIM_INH		; X = INH
	jsr 	shifter 	; shift around nibbles
	stx	KIM_INH		; store X back out

	; middle byte
	ldx	KIM_POINTL	; X from the byte
	jsr	shifter		; shift ecverything around
	stx	KIM_POINTL	; store the modified X back out

	; left byte
	ldx	KIM_POINTH	; X from the byte
	jsr	shifter		; shift ecverything around
	stx	KIM_POINTH	; store the modified X back out

	; and finally display it to the screen
	jsr	SCANS		; and display it to the screen


.if .defined(UseVideoDisplay0)
	; and display the color
	lda	KEYBAK
	jsr	fillscr		; fill the screen
.endif

	jmp 	keyinput	; repeat...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; shifter
;  roll A through X (for keypad->multibyte display use)
;  eg:  A=$0D   X=$4C  ->  X=$CD  A=$0C
;    in: A - nibble to shift in from the right
;    in: X - byte to work on
;    mod: Y - scratch
;    out: A - nibble shifted out
shifter:
	; 1. store aside A in Y
	and 	#$0F	; clean up A (just in case)
	sta	SHIFTSCRATCH
		; A = input byte / nib
		; X = starting byte
		; SHIFTSCRATCH = masked input nibble

	; 2. generate carry result, store on stack
	txa		; A = X
	lsr
	lsr
	lsr
	lsr		; A >>= 4 (shift nibble down)
	;and	#$0F	; A &= 0x0F (mask it) (unnecessary due to LSR)
	pha		; push A onto stack

		; A = carry nibble (junk now)
		; X = starting byte
		; SHIFTSCRATCH = masked input nibble
		; stack =  x >> 4 (carry nibble)

	; 3. shift nibble and apply new carry in
	txa		; A = X
	asl
	asl
	asl
	asl		; a <<=4 (shift nibble up)
	;and	#$F0	; A &= 0xF0 (mask it) (unnecessary due to ASL)
	ora	SHIFTSCRATCH	; A = A | SCRATCH  ( shift in nibble)
		; A = output byte (shifted nibbles)
		; X = junk
		; SHIFTSCRATCH = masked input nibble (junk now)

	; 4. Setup return values 
	tax		; X = A
	pla		; pop A from stack (from 2.)
		; X = output byte
		; A = carry nibble

	; 5. and return
	rts		; return 
