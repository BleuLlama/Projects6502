; fibonacci sequence printer
;  displays the fibonacci sequence through the point where it is 7 digits big
;  also experiments with Decimal/Hex operations
;
; Scott Lawrence - yorgle@gmail.com
; 2016-01-24
;
; decimal:
; 0 1 1 2 3 5 8 13 21 34 55 89 144
; Hex:
; 0 1 1 2 3 5 8 D 15 22 37 59 90 E9 179


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; Configuration

VERSIONH = 0
VERSIONL = 2

; define the functionality we want to use in the library
UseVideoDisplay0 = 1

; include our functions
.include "KimDefs.asm"
.include "KimCode200.asm"
.include "KimLib.asm"


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; RAM

; the operations stack is:
;	display	param0	param1
;	RESULT	VALI	VALJ
VALI	 = $20		; Parameter 1 for operations (24 bit)
VALJ	 = $23		; Parameter 2 for operations (24 bit)
RESULT 	 = $26		; Result for operations (24 bit)
OVERFLOW = $1F		; if operation overflowed, this is set


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; main
;	the main loop
main:
setup:
	jsr	cls		; clear the video display black

	; clear the value, setup the 
	lda	#$0		; A = 0
	sta	RESULT+0	; RESULT =     00
	sta	RESULT+1	; RESULT =   00
	sta	RESULT+2	; RESULT = 00

	sta	VALI+0		; VALI =       00
	sta	VALI+1		; VALI =    00
	sta	VALI+2		; VALI = 00

	sta	VALJ+0		; VALJ =       00
	sta	VALJ+1		; VALJ =    00
	sta	VALJ+2		; VALJ = 00

	;cld			; HEX mode
	sed			; Decimal mode (BCD)

; since the Fib sequence starts with two values that don't follow
; the pattern (0, 1)  we need to preload it..
preloadFibonacci:
	; prep 00 00 00
	jsr	displayAndWait	; display to LED, Video Display, wait for press

	; prep 00 00 01
	lda	#$01
	sta	RESULT+0	; RESULT = 00 00 01
	jsr	rollValues	; J gets I, I gets RESULT

; now, once we get going, we can just work from RESULT/I/J
mainLoop:
	jsr	displayAndWait	; display to LED, Video Display, wait for press

	jsr	addIJ		; RESULT = I + J
	jsr	rollValues	; J gets I, I gets RESULT

	; check for overflow...
	lda	OVERFLOW	; see if there was a math overflow 
	cmp	#$00
	beq	mainLoop	; nope?  Go again!

	; display overflow error
	lda	#$EE		; display error
	sta	KIM_POINTH	; EE
	sta	KIM_POINTL	;    EE
	sta	KIM_INH		;       EE
	jsr	waitForPress	; wait for press

	; now just restart from scratch
	jmp	setup


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; math operations

; rollValues
;	J gets I
; 	I gets RESULT
;	RESULT is untouched
rollValues:
	LDA	VALI+0		; J gets I
	STA	VALJ+0
	LDA	VALI+1
	STA	VALJ+1
	LDA	VALI+2
	STA	VALJ+2

	LDA	RESULT+0	; I gets RESULT
	STA	VALI+0
	LDA	RESULT+1
	STA	VALI+1
	LDA	RESULT+2
	STA	VALI+2

	rts;

; addIJ
;	C is untouched
;	B is untouched
;	RESULT gets C+B
; 	OVERFLOW is set/cleared
addIJ:
	jsr	clearOverflow	; clear overflow
	clc			; C (carry) is cleared

	lda	VALJ+0
	adc	VALI+0
	sta	RESULT+0	; RESULT0 = VALI0 + VALJ0 + C(0)
	lda	VALJ+1
	adc	VALI+1
	sta	RESULT+1	; RESULT1 = VALI1 + VALJ1 + C
	lda	VALJ+2
	adc	VALI+2
	sta	RESULT+2	; RESULT2 = VALI2 + VALJ2 + C

	bcs	setOverflow	; set overflow if C was set
	rts

; clearOverflow
;	OVERFLOW is set to 0
clearOverflow:
	lda	#$00
	sta	OVERFLOW	; OVERFLOW = 0
	rts

	
; setOverflow
;	OVERFLOW is set to 1
setOverflow:
	lda	#$01
	sta	OVERFLOW	; OVERFLOW = 1
	rts



; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; input and display operations

; displayAndWait
;	display the result to the LEDs
;	display the result to the video display
;	wait for any key to be hit on the keypad
displayAndWait:
	jsr	displayResult	; display the result to the LED display
	jsr	displayColor	; display the result to the video display
	jsr	waitForPress	; wait for the user to press something
	rts


; waitForPress
;	wait for the user to hit a key
;	A gets the key pressed
waitForPress:
	jsr	SCANDS		; refresh the display (for real KIM)
	jsr	GETKEY		; get a keypad press
	cmp	KEY_NONE	; returned $15?
	beq	waitForPress	; nothing pressed, repeat
	rts			; we're done, return.


; displayResult
;	Copy the RESULT to the KIM display ram
;	display it to the LEDs
displayResult:
	lda	RESULT+2
	sta	KIM_POINTH	; xx .. ..
	lda	RESULT+1
	sta	KIM_POINTL	; .. xx ..
	lda	RESULT+0
	sta	KIM_INH		; .. .. xx

	jsr	SCANDS		; refresh it to the display
	rts			; we're done, return.

; displayColor
;	fill video filled with the color from the bottom nib of RESULT
displayColor:
	lda	RESULT+0	; set the color (bottom nibble)
	jsr	fillscr		; fill the screen
	rts			; we're done, return.
