;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LlamaCalc - a programmer's calculator for KIM (1/Uno)
;
; 2016-01 Scott Lawrence
;
;  Created for the RetroChallenge RC2016-1
; Scott Lawrence - yorgle@gmail.com
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; [Go] exits the current mode to return it to Result mode

; Result mode:
;	A--F : enter new number
;	+    : push to stack
;	PC   : pop from stack
;	GO   : Switch to menu mode
;
; Menu mode:
;	 B   : Convert result to binary/hex (base 16)
;	 D   : Convert result to decimal (base 10)
;	 E   : shift left one bit
;	 F   ; shift right one bit
;	 A   ; Add result to top of stack (future)
;	 5   ; Subtract result from top of stack (future)
;	GO   : return to result mode


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$08

; v 00 08 - Add, Subtract, Shift L, Shift R, ToBCD, Error handling
; v 00 07 - development mode, new menu, functions
; v 00 06 - Better, more flexible error display with backup and 'GO' press
; v 00 05 - some error display
; v 00 04 - PC/+ stack pop and push
; v 00 03 - Sped up input routine, AD lshift, DA rshift
; v 00 02 - 2016-01-04 - 
; v 00 01 - 2016-01-01 - initial version, keypad input support


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; define the functionality we want to use in the library
;UseVideoDisplay0 = 1 ; video display 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; include our support defines and libraries

.include "KimDefs.asm"
.include "KimCode200.asm"
;.include "KimLib.asm"


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


ERRORCODE	= $1C
.define ERROR_NONE		#$00
.define ERROR_STACK_FULL	#$5F
.define ERROR_STACK_EMPTY	#$5E
.define ERROR_STACK_MATH	#$51
.define ERROR_NOT_IMPLEMENTED	#$FF


DISPLAYMODE	= $1D	; 0 = splash, 1 = result, 2 = mode
.define DISPLAY_MODE_SPLASH	#$00
.define DISPLAY_MODE_RESULT	#$01
.define DISPLAY_MODE_MENU	#$02
.define DISPLAY_MODE_ERROR	#$FF

STACKDEPTH	= $1E	; current depth of the stack
STACKIDX	= $1F	; current pointer into the stack

STACK		= $20	; uses maxdepth * 3 bytes (goes up)

.define STACKMIN #$00
.define STACKMAX #$08


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	; reset the stack, variables, and mode
	lda	#0
	sta	STACKDEPTH	; reset stack depth

	sta	DISPLAYMODE	; display 0 (splash)

	sta	RESULT0		; initialize our result
	sta	RESULT1
	sta	RESULT2

	sta	I0		; initialize I
	sta	I1
	sta	I2

	sta	J0		; initialize J
	sta	J1
	sta	J2

	jsr	display		; display the version number
.if .defined(UseVideoDisplay0)
	jsr	gfxNoise	; display noise stuff
	jsr	cls		; clear the screen black
.endif

	jmp	waitForGo	; skip the test.
	; test a function
test:
	lda	DISPLAY_MODE_RESULT
	sta	DISPLAYMODE
	lda	#$80
	sta	RESULT2
	lda	#$00
	sta	RESULT1
	lda	#$00
	sta	RESULT0

	jmp	fcnToBCD


	; wait for 'go' to advance to result mode
waitForGo:
	jsr	display
	jsr	GETKEY
	cmp	KEY_GO
	bne	waitForGo

	; restore result mode
	lda	DISPLAY_MODE_RESULT
	sta	DISPLAYMODE
	; fall through to the key input loop
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; at this point, we're in RESULT mode
keyInput:
	jsr	display		; refresh the display
	; check for key
	jsr	GETKEY		; get a keypress
	sta	KEYBAK		; KeyBak = a
	cmp	KEY_NONE 	; $15 is "no press"
	beq	keyInput	; then there's no press, check again

	; check for AD/DA/PC/+ keys
	and	KEY_SPECIAL_MASK
	cmp	KEY_SPECIAL_MASK
	beq	handleControlKey	; yep. control key, handle it.
	jmp	keyShiftIntoDisplay	; nope. regular key press

	; handle a control key
handleControlKey:
	lda	KEYBAK		; restore A

	cmp	KEY_PC		; PC button (pop)
	beq	handle_PC

	cmp	KEY_PL		; PLus button (push)
	beq	handle_PL

	cmp	KEY_GO		; GO button (menu)
	beq	handle_GO

	cmp	KEY_AD		; ADdress button
		; no function yet

	cmp	KEY_DA		; DAta button
		; no function yet

	jmp	keyInput	; dunno what it was. ignore and repeat


handle_PL:
	jsr	stackPush	; push the result on the stack
	jmp	handle_error

handle_PC:
	jsr	stackPop	; pop the stack to the result

handle_error:
	lda	ERRORCODE
	cmp	ERROR_NONE	; were there no errors?
	beq	keyInput	; ok. then display the key
	jmp	waitForGo	; wait for [GO] pressed

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
handle_GO:
	; menu display
	lda	DISPLAY_MODE_MENU
	sta	DISPLAYMODE
menuLoop:
	jsr	display

	jsr	GETKEY		; get a keypress
	sta	KEYBAK		; store a backup

	cmp	KEY_GO
	beq	exitMenu	; [GO] -> back to result mode

	cmp	KEY_B
	beq	fcnHex		; [B] -> result to Hex
	cmp	KEY_D
	beq	fcnToBCD	; [D] -> result to Decimal

	cmp	KEY_E
	beq	fcnShiftLeft	; [E] -> Shift Left
	cmp	KEY_F
	beq	fcnShiftRight	; [F] -> Shift Right

	jmp	checkKeysForMath	; jump below for short jumps


; exit the menu mode
exitMenu:
	lda	DISPLAY_MODE_RESULT
	sta	DISPLAYMODE
	jmp	keyInput

	

; convert result to hex  (Result is base 10, convert to base 16)
fcnHex:
	jmp	fcnNotImpError	; not implemented yet.

; convert result to BCD  (Result is base 16, convert to base 10)
fcnToBCD: ; binary to BCD
	jsr	resultToI	; I = RESULT

	sed			; switch to decimal mode
	lda	#$0		; clear result
	sta	RESULT0
	sta	RESULT1
	sta	RESULT2
	ldx	#24
cnvbit:
	asl	I0		; shift out a bit
	rol	I1
	rol	I2

	lda	RESULT0
	adc	RESULT0		; add it into the result
	sta	RESULT0
	lda	RESULT1		; propagate carry
	adc	RESULT1
	sta	RESULT1
	lda	RESULT2		; propagate carry
	adc	RESULT2
	sta	RESULT2
	dex
	bne	cnvbit

	cld			; binary mode
	jmp	exitMenu	; and exit out of menu mode

; shift result left one bit
fcnShiftLeft:
	clc
	rol	RESULT0
	rol	RESULT1
	rol	RESULT2
	jmp	exitMenu	; and exit out of menu mode

; shift result right one bit
fcnShiftRight:
	clc
	ror	RESULT2
	ror	RESULT1
	ror	RESULT0
	jmp	exitMenu	; and exit out of menu mode


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fcnNotImpError:
	lda 	ERROR_NOT_IMPLEMENTED
	jmp	fse2

fcnStackError:
	; display the stack math error
	lda	ERROR_STACK_MATH
fse2: 	sta	ERRORCODE
	
	lda	DISPLAY_MODE_ERROR
	sta	DISPLAYMODE

	; display the erorr wait for GO
:	jsr	display
	jsr	GETKEY
	cmp	KEY_GO
	bne	:-

	; restore menu display mode
	jmp	handle_GO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

checkKeysForMath:
	cmp	KEY_A
	beq	fcnAdd		; [A] -> Add

	cmp	KEY_5
	beq	fcnSubtract	; [5] -> Subtract

	jmp	menuLoop	; dunno what that was, repeat.

fcnAdd:
	lda	STACKDEPTH
	cmp	#$0
	beq	fcnStackError

	; prep the operands
	jsr 	resultToI	; I = Result
	jsr	stackPop	; Result = pop()
	jsr 	resultToJ	; J = Result

	; do the math
	clc
	lda	I0
	adc	J0
	sta	RESULT0
	lda	I1
	adc	J1
	sta	RESULT1
	lda	I2
	adc	J2
	sta	RESULT2

	; return to result mode
	jmp	exitMenu

fcnSubtract:
	lda	STACKDEPTH
	cmp	#$0
	beq	fcnStackError

	; prep the operands
	jsr 	resultToI	; I = Result
	jsr	stackPop	; Result = pop()
	jsr 	resultToJ	; J = Result

	; do the math
	sec
	lda	I0
	sbc	J0
	sta	RESULT0
	lda	I1
	sbc	J1
	sta	RESULT1
	lda	I2
	sbc	J2
	sta	RESULT2

	; return to result mode
	jmp	exitMenu


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
;	lda	KEYBAK
;	jsr	fillscr		; fill the screen
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

; I decided to have one central display updating routine. this means
; that everything can be stupider, but it uses another byte of memory
; to store the mode.  That mode is also used for the input menu too.

display:
	lda	DISPLAYMODE
	cmp	DISPLAY_MODE_SPLASH
	beq	displaySplash

	cmp	DISPLAY_MODE_MENU
	beq	displayMenu

	cmp	DISPLAY_MODE_ERROR
	beq	displayError

	; display result (fall through)
	
displayResult:
	;	R2 R1  R0
	lda	RESULT0
	sta	KIM_INH
	lda	RESULT1
	sta	KIM_POINTL
	lda	RESULT2
	sta	KIM_POINTH
	jsr	SCANDS
	rts

displaySplash:
	;	CA 1C  07
	lda	#$CA
	sta	KIM_POINTH
	lda	#$1C
	sta	KIM_POINTL
	lda	VERSIONL
	sta	KIM_INH
	jsr	SCANDS
	rts

displayMenu:
	;	90 90  90
	lda	#$90
	sta	KIM_POINTH
	sta	KIM_POINTL
	sta	KIM_INH
	jsr	SCANDS
	rts

displayError:
	;	EE EE  xx
	lda	#$EE
	sta	KIM_POINTH
	sta	KIM_POINTL
	lda	ERRORCODE
	sta	KIM_INH
	jsr	SCANDS
	rts

errorClear:
	lda	ERROR_NONE
	sta	ERRORCODE
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
	lda	ERROR_STACK_FULL	; preload for error code
	sta	ERRORCODE

	; make sure it's ok to do
	lda	STACKDEPTH
	cmp	STACKMAX		; full stack?
	beq	stackError		; yep! Can't push any more!

	jsr	errorClear 		; clear error codes

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
	lda	ERROR_STACK_EMPTY	; preload for error code
	sta	ERRORCODE

	lda	STACKDEPTH
	cmp	STACKMIN		; empty stack?
	beq	stackError		; yep. Can't pop from empty!

	jsr	errorClear 		; clear error codes

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

stackError:
	lda	DISPLAY_MODE_ERROR
	sta	DISPLAYMODE
	rts

