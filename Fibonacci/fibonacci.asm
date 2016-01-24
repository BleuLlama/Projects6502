; fibonacci sequence printer
;
; 2016-01-24
;  Experiments for learning BCD routines
; 
; Scott Lawrence - yorgle@gmail.com


VERSIONL = 0
VERSIONH = 1

; define the functionality we want to use in the library
UseVideoDisplay0 = 1

; include our functions
.include "KimDefs.asm"
.include "KimCode200.asm"
.include "KimLib.asm"

;; a little bit of ram we use

; Value   LL MM RR
VALL	= $20
VALM	= $21
VALR	= $22

; 0 1 1 2 3 5 ...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do the thing...
main:
	jsr	cls		; clear the video display black

	; clear the value, setup the 
	lda	#$0		; A = 0
	sta	VALL		; VALL = 00
	sta	VALM		; VALM =   00
	sta	VALR		; VALR =      00

	cld			; HEX mode
	sed			; Decimal mode (BCD)

; since the Fib sequence starts with two values that don't follow
; the pattern (0, 1)  we need to preload it..
mainFirstbits:
	; display 00 00 00
	jsr	displayAndWait	; display to LED, Video Display, wait for press

	; display 00 00 01
	lda	#$01
	sta	VALR		; VALR =      01
	jsr	displayAndWait	; display to LED, Video Display, wait for press

mainLoop:
	jsr	displayAndWait	; display to LED, Video Display, wait for press
	jsr	computeValue	; compute the next value
	jmp	mainLoop	; and again.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; compute the next value
computeValue:
	clc			; clear carry
	lda	VALR		; A = VALR
	adc	VALR		; A = VALR + VALR
	sta	VALR		; (store it)

; nope
	lda	#$0		; A = 0
	adc	VALM		; A = 0 + VALM + C
	sta	VALM		; (store it)

	lda	#$0		; A = 0
	adc	VALR		; A = VALL + C
	sta	VALR		; (store it)

	rts			; we're done, return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display value and wait for press
displayAndWait:
	jsr	displayValue	; display VALx to the LED display
	jsr	displayColor	; display VALx to the video display
	jsr	waitForPress	; wait for the user to press something
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait for a user press
waitForPress:
	jsr	SCANDS		; refresh the display (for real KIM)
	jsr	GETKEY		; get a keypad press
	cmp	KEY_NONE	; returned $15?
	beq	waitForPress	; nothing pressed, repeat
	rts			; we're done, return.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display the value to the LED display
displayValue:
	lda	VALL
	sta	KIM_POINTH	; left two digits
	lda	VALM
	sta	KIM_POINTL	; left two digits
	lda	VALR
	sta	KIM_INH		; left two digits

	jsr	SCANDS		; refresh it to the display
	rts			; we're done, return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display the value as a color
displayColor:
	lda	VALR		; set the color (bottom nibble)
	jsr	fillscr		; fill the screen
	rts			; we're done, return.
