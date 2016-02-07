;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llam-A-Sketch
;
; 2016-02 Scott Lawrence
;         yorgle@gmail.com
;
;	a simple little drawing tool to draw on video display 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$01

; v 00 01 - 2016-02-01 - initial version

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; define the functionality we want to use in the library
UseVideoDisplay0 = 1 ; video display 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; include our support defines and libraries

.include "KimDefs.asm"
.include "KimCode200.asm"
.include "KimLib.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM usage:

COLOR	= $20
POSX	= $21
POSY 	= $22

SCREEN 	= $30
SCREENBAK = $32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	lda	COLOR_BLACK
	sta	COLOR
	jsr	fillscr			; fill the screen to start fresh

	lda	#$15
	sta	KIM_POINTH
	lda	VERSIONH
	sta	KIM_POINTL
	lda	VERSIONL
	sta	KIM_INH
	jsr	SCANDS			; display the splash

waitForGo:
	jsr	GETKEY
	cmp	KEY_GO
	bne	waitForGo		; wait until [GO] is pressed

initGraphics:
	lda	#$10
	sta	POSX
	lda	#$10
	sta	POSY
	lda	COLOR_WHITE
	sta	COLOR

loop:
	; draw the current values to the display
	lda	POSX
	sta	KIM_POINTH
	lda	POSY
	sta	KIM_POINTL
	lda	COLOR
	sta	KIM_INH
	jsr	SCANDS
	jsr	DrawPoint	; draw it to the screen

	jsr	GETKEY		; check for key input
	cmp	KEY_NONE
	beq	loop

	; check for movement keys
	cmp	KEY_9
	beq	moveUp
	cmp	KEY_1
	beq	moveDown
	cmp	KEY_4
	beq	moveLeft
	cmp	KEY_6
	beq	moveRight

	; check for color change
	cmp	KEY_5
	beq	nextColor

	cmp	KEY_GO
	beq	pickColor

	cmp	KEY_F
	beq	clearScreen

	; no idea, just repeat
	jmp 	loop

moveUp:
	dec	POSY	; increment it
	lda	POSY	; now mask it
	and	#$1F
	sta	POSY
	jmp	loop	; and repeat

moveDown:
	inc	POSY	; increment it
	lda	POSY	; now mask it
	and	#$1F
	sta	POSY
	jmp	loop	; and repeat

moveLeft:
	dec	POSX	; decrement it
	lda	POSX	; now mask it
	and	#$1F
	sta	POSX
	jmp	loop	; and repeat

moveRight:
	inc	POSX	; increment it
	lda	POSX	; now mask it
	and	#$1F
	sta	POSX
	jmp	loop	; and repeat

nextColor:
	inc	COLOR	; increment it
	lda	COLOR	; now mask it
	and	#$0F
	sta	COLOR
	jmp	loop	; and repeat


clearScreen:
	lda	COLOR
	jsr	fillscr
	jmp	loop

pickColor:
	lda	#$CC
	sta	KIM_POINTH
	sta	KIM_POINTL
	lda	#$00
	sta	KIM_INH		; set display to CCCC 00
:	jsr	SCANDS		; update the display
	jsr	GETKEY		; get a press
	cmp	KEY_NONE
	beq	:-		; nothing pressed? try again
	cmp	KEY_GO
	beq	donePickColor	; cancel, return

	cmp	KEY_F+1
	bcs	:-		; it wasn't 0..F, try again

	; set new color
	sta	COLOR

donePickColor:
	jmp	loop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw COLOR at POSX, POSY
DrawPoint:
	ldx	POSX
	ldy	POSY
	jsr	XYToScreen
	lda	COLOR
	ldy	#$00
	sta	(SCREEN),y
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set X = x position
; set Y = y position
; call this, SCREEN will be set for the right position
XYToScreen:
	; Adjust the start position for the X,Y position passed in
	; setup "SCREEN" to point to raster data ram
	lda	#<RASTER
	sta	SCREEN
	lda	#>RASTER
	sta	SCREEN+1	; "SCREEN" points to base of RASTER ram

	; adjust for Y position
	tya
	lsr
	lsr
	lsr
	clc
	adc	SCREEN+1
	sta	SCREEN+1	; bank offset

	tya
	asl
	asl
	asl
	asl
	asl
	clc
	adc	SCREEN
	sta	SCREEN		; row offset

	; adjust for X position
	clc
	txa
	adc	SCREEN	
	sta	SCREEN

	rts
