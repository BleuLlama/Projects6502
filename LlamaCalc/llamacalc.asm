;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LlamaCalc - a programmer's calculator for KIM (1/Uno)
;
; 2016-01 Scott Lawrence
;
;  Created for the RetroChallenge RC2016-1
; Scott Lawrence - yorgle@gmail.com
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Functions:
;	A--F: enter new number into the display
;	AD  : shift value left one bit (x2)
;	DA  : shift value right one bit (integer /2)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$05

; v 00 04 - PC/+ stack pop and push
; v 00 03 - Sped up input routine, AD lshift, DA rshift
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
STACKDEPTH   = $12
STACKIDX     = $13
STACK        = $20	; uses maxdepth * 3 bytes (goes up)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	lda	#0
	sta	STACKDEPTH	; reset stack depth

	; display version to screen
	jsr	displayVersion	; display the version number

	; display some nosie to the lcd
	ldx	#$80
:	lda	RANDOM
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
	bne	:-



.if .defined(UseVideoDisplay0)
	jsr	cls		; clear the screen black
.endif

	; now clear the display, and go to our key input loop
	jsr	cls7seg
	jmp	keyInput	; press a key, get a color
	jsr	end		; end it


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
keyInput:
	; check for key
	jsr	GETKEY		; get a keypress
	sta	KEYBAK		; KeyBak = a
	cmp	KEY_NONE 	; $15 is "no press"
	beq	keyInput	; then there's no press, check again

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
	jmp	keyInput	; repeat


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; control key handlers

; AD- shift left by one bit
handle_AD:
	jsr	errorLoop
	jmp	keyInput

	clc
	rol	KIM_INH
	rol	KIM_POINTL
	rol	KIM_POINTH
	jsr	SCANDS
	jmp	keyInput

; DA- shift right by one bit
handle_DA:
	clc
	ror	KIM_POINTH
	ror	KIM_POINTL
	ror	KIM_INH
	jsr	SCANDS
	jmp	keyInput

handle_PC:
	jsr	popValue
	jmp	keyInput

handle_PL:
	jsr	pushValue
	jmp	keyInput

handle_GO:
	jmp	keyInput


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; number key handlers (0-F)
; shift the value in from the right

	; handle a digit 0..F shift in from the right...
keyShiftIntoDisplay:
	ldx	#$04		; 4 bits to shift

:	clc			; rol pulls from carry, so clear it
	rol	KIM_INH		; shift this byte by 1
	rol	KIM_POINTL	; shift this one, shift in carry from INH
	rol	KIM_POINTH	; shift this one, shift in carry from POINTL
	dex			; x = x - 1
	cpx	#$00		; x == 0?
	bne	:-		; mot 0, repeat loop

	; now shove the content in
	lda	KEYBAK		; restore key 00 .. 0F to A
	ora	KIM_INH		; A = A | INH
	sta	KIM_INH		; INH = A

	jsr	SCANDS		; and display it to the screen

.if .defined(UseVideoDisplay0)
	; and display the color
	lda	KEYBAK
	jsr	fillscr		; fill the screen
.endif

	jmp	keyInput	; next!
	
	; v4 above was 27 bytes. (then further reduved to 26)
	;    (up to and including the jsr SCANDS)
	; v3 was 46 + 20 bytes (66 bytes)
	;    (up to and including the jsr SCANDS)
	; v2 was never completed
	; v1 wouldn't work


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stack functions

pushValue:
	; make sure it's ok to do
	lda	STACKDEPTH
	cmp	#$05
	beq	stackError

pushNoCheck:
	; ok. we're good to go, store it!
	lda	KIM_POINTH
	ldx	STACKIDX
	sta	STACK, x
	inx

	lda	KIM_POINTL
	sta	STACK, x
	inx

	lda	KIM_INH
	sta	STACK, x
	inx

	stx	STACKIDX

	; and display the stack level
	inc	STACKDEPTH
	jmp	showStack

popValue:
	; make sure it's ok to do
	lda	STACKDEPTH
	cmp	#$00
	beq	stackError

	; ok. we're good to go, restore it
	ldx	STACKIDX
	dex
	lda	STACK, x
	sta	KIM_INH

	dex
	lda	STACK, x
	sta	KIM_POINTL

	dex
	lda	STACK, x
	sta	KIM_POINTH
	stx	STACKIDX

	; and display the value
	dec	STACKDEPTH
	jsr	SCANDS
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; error code display
;
;   load the error code into 
;	press "GO" to continue past
errorLoop:
	; push the current number to store it aside
	jsr	pushNoCheck	; push POINTH/POINTL/INH

	; update the display...  will be EE NN 5d
	lda	#$EE
	sta	KIM_POINTH

	lda	#$42
	sta	KIM_POINTL

	lda	#$5D
	sta	KIM_INH

	; display the above, repeat until [GO] is pressed
:	jsr	SCANDS		; display the new stuff
	jsr	GETKEY		; get a keypress
	sta	KEYBAK		; KeyBak = a
	cmp	KEY_GO		; was 'go' pressed?
	bne	:-		; nope, scan again...

	; restore the display and return
	jsr	popValue	; pop POINTH/POINTL/INH
	jsr	SCANDS		; display the new stuff
	rts			; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; rework this ;;;;;

; show a stack error
;  EExx 5D	("S"tack "D"epth)
stackError:
	;; flesh this out more
	lda	#$EE
	sta	KIM_POINTH
	jmp	sstb

; show the stack in this format:
;  00xx 5D	("S"tack "D"epth)
showStack:
	lda	#$00
	sta	KIM_POINTH
sstb:
	lda	STACKDEPTH
	sta	KIM_POINTL
	lda	#$5D
	sta	KIM_INH
	jsr	SCANDS		; and show it
	rts

