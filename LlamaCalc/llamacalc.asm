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
;	A--F : enter new number into the display
;	AD   : shift value left one bit (x2)
;	DA   : shift value right one bit (integer /2)
; 	PC/+ : pop/push current value to stack
;	GO   : continue (when in an error or startup display)

; New version:
;	A--F : enter new number
;	+    : push to stack
;	PC   : pop from stack
;	GO   : Switch to/from menu mode
;	Menu mode:
;	 B   : Convert result to binary (base 16)
;	 D   : Convert result to decimal (base 10)
;	 +   : pop stack to operand, add to result
;	 E   : shift left one bit
;	 F   ; shift right one bit


; Internally:
;	INH POINTH, POINTL  - displayed value / error display
;	RESULT	- displayed result
;	STACKTOP - item at the front of the stack
;	STACK	- bottom of the stack


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; POP:     item is removed from stack, placed in RESULT
; PUSH:    RESULT is copied to the stack
; SHIFTL:  RESULT is << 1
; SHIFTR:  RESULT is >> 1
; MATH:    RESULT = RESULT (math) STACK
;	   I = RESULT
;	   POP
;	   J = RESULT
;	   RESULT = I (math) J



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$07

; v 00 06 - Better, more flexible error display with backup and 'GO' press
; v 00 05 - some error display
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
.include "KimCode200.asm"
.include "KimLib.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RAM used

;	for multibyte, indexing is   22 11 00

KEYBAK		= $10
SHIFTSCRATCH	= $11	; shifter needs this when it's running.

RESULT0		= $12
RESULT1		= $13
RESULT2		= $14

I0		= $15
I1		= $16
I2		= $17

J0		= $18
J1		= $19
J2		= $1A


STACKDEPTH	= $1E	; current depth of the stack
STACKIDX	= $1F	; current pointer into the stack

STACK		= $20	; uses maxdepth * 3 bytes (goes up)

.define STACKMAX #$08


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	; reset the stack and variables
	; refresh the display
	; display the version splash
	; wait for GO

	; mode == number: enter number
	; mode == menu: select option

	lda	#0
	sta	STACKDEPTH	; reset stack depth

	sta	RESULT0		; initialize our result, I and J
	sta	RESULT1
	sta	RESULT2

	sta	I0
	sta	I1
	sta	I2

	sta	J0
	sta	J1
	sta	J2

	; display version to screen
	jsr	displayVersion	; display the version number
	jsr	gfxNoise	; display noise stuff
	jsr	cls		; clear the screen black

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
	cmp	KEY_DA		; DAta button
	cmp	KEY_PC		; PC button
	cmp	KEY_PL		; PLus button
	cmp	KEY_GO		; GO button
	jmp	keyInput	; repeat


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; number key handlers (0-F)
; shift the value in from the right

	; handle a digit 0..F shift in from the right...
keyShiftIntoDisplay:
	ldx	#$04		; 4 bits to shift

:	clc			; rol pulls from carry, so clear it
	rol	RESULT0		; shift this byte by 1
	rol	RESULT1		; shift this one, shift in carry from INH
	rol	RESULT2		; shift this one, shift in carry from POINTL
	dex			; x = x - 1
	cpx	#$00		; x == 0?
	bne	:-		; mot 0, repeat loop

	; now shove the content in
	lda	KEYBAK		; restore key 00 .. 0F to A
	ora	RESULT0		; A = A | INH
	sta	RESULT0		; INH = A

	jsr	displayResult	; and display it to the screen

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


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; display
	
displayResult:
	lda	RESULT0
	sta	KIM_INH
	lda	RESULT1
	sta	KIM_POINTL
	lda	RESULT2
	sta	KIM_POINTH
	jsr	SCANDS
	rts


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; bit shift

shiftL:
	clc
	rol	RESULT0
	rol	RESULT1
	rol	RESULT2
	rts

shiftR:
	clc
	ror	RESULT2
	ror	RESULT1
	ror	RESULT0
	rts


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; result, i, j swaps
resultToI:
	lda	RESULT0
	sta	I0
	lda	RESULT1
	sta	I1
	lda	RESULT2
	sta	I2
	rts

resultToJ:
	lda	RESULT0
	sta	J0
	lda	RESULT1
	sta	J1
	lda	RESULT2
	sta	J2
	rts

jToResult:
	lda	J0
	sta	RESULT0
	lda	J1
	sta	RESULT1
	lda	J1
	sta	RESULT2
	rts

iToResult:
	lda	I0
	sta	RESULT0
	lda	I1
	sta	RESULT1
	lda	I1
	sta	RESULT2
	rts

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; Stack operations
stackPush:
	; make sure it's ok to do
	lda	STACKDEPTH
	cmp	STACKMAX
	;beq	stackError

	; ok. we're good to go, store it!
	lda	RESULT0
	ldx	STACKIDX
	sta	STACK, x
	inx

	lda	RESULT1
	sta	STACK, x
	inx

	lda	RESULT2
	sta	STACK, x
	inx

	stx	STACKIDX

	; and adjust the stack depth
	inc	STACKDEPTH
	rts

stackPop:
	; make sure it's ok to do
	lda	STACKDEPTH
	cmp	STACKMAX
	;beq	stackError

	; ok. we're good to go, restore it
	ldx	STACKIDX
	dex
	lda	STACK, x
	sta	RESULT2

	dex
	lda	STACK, x
	sta	RESULT1

	dex
	lda	STACK, x
	sta	RESULT0
	stx	STACKIDX

	; and adjust the stack depth
	dec	STACKDEPTH
	rts
