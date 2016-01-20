;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RLE Test - experiments with RLE frame encoding
;
; 2016-01 Scott Lawrence
;
;  Created for the RetroChallenge RC2016-1
; Scott Lawrence - yorgle@gmail.com
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$01

; v 00 01 - 2016-01-01 - initial version


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; define the functionality we want to use in the library
UseVideoDisplay0 = 1 ; video display 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; include our support defines and libraries

.include "KimDefs.asm"
.include "KimCode200.asm"
.include "KimLib.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	lda	COLOR_DKGRAY
	jsr	fillscr

	jsr	rleRenderSprite

: 	jmp	:-


SCREEN = $20
IMAGE  = $22
COLOR  = $24
REPS   = $25

rleRenderSprite:
	; setup IMAGE to point to image to be drawn
	lda	#<stripesRLE
	sta	IMAGE
	lda	#>stripesRLE
	sta	IMAGE+1
	ldy	#$08		; start it at this Y position 00..1f
	ldx	#$00		; start at this X position
	jsr	rleDecoder
	rts

rleDecoder:
	; 0.A Adjust the start position for the X,Y position passed in
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

	; 0.B initialize our loop variables...
	sta	COLOR		; color = 0
	sta	REPS		; reps = 0
	lda	#0
	tay			; clear Y

; RLE format:
;	0x00	End of image
;	0x0F	End of row (skip to next start)
;	0x01	(skip 0x01 pixels) (future)
;	0x0E	(skip 0x0e pixels) (future)
; 	0xnM	repeat color M for N bytes

rleLoop:
	; 1. if REPS > 0  
	; 1.a output the color to memory
	; 1.b advance to next screen pos
	; 1.c dec REPS
	; 1.d goto loop

	; 2, if REPS == 0
	; 2.a get next byte from the image data

	; 3. if byte & 0xF0 nz
	; 3.a load this into reps
	; 3.b load the byte into color
	; 3.c goto loop

	; 4. if byte == 0x00
	; 4.a  goto DONE

	; 5. if byte == 0x01
	; 5.a advance cursor to next Y start position
	; 5.b goto loop


	; get the next byte
	ldx	#0
	lda	(IMAGE, x)

	; check for commands
	cmp	#$00
	beq 	foodone

	COLOR
	REPS

	; store it to the screen
	sta	(SCREEN), y

	; increment IMAGE
	inc	IMAGE

;	bcs	:+
;	lda	IMAGE+1
;	adc	#$01
;	sta	IMAGE+1
;:

	iny
	bne	rleLoop		; if we haven't reached 255, repeat
	

		; we filled a bank...
	inc	SCREEN+1	; advance pointer to the next bank

	bne	rleLoop
	
foodone:
	; we're done here
	rts


; 01	- end of line
; 00	- end of image

; 0 black
; 3 white
; 4 red
; D blue

; 6 brown
; 7 orange
; 

stripesRLE:
	.byte	$10, $11, $12, $13, $14, $15, $16, $17, $01
	.byte	$18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $01
	.byte	$10, $11, $12, $13, $14, $15, $16, $17, $01
	.byte	$18, $19, $1A, $1B, $1C, $1D, $1E, $1F
	.byte	$00	; END OF IMAGE




redghost:
	.byte	$50, $44, $01
	.byte	$30, $84, $01
	.byte	$20, $A4, $01
	.byte	$10, $34, $23, $44, $23, $14, $01
	.byte	$10, $24, $43, $24, $43, $01
	.byte	$34, $23, $2d, $24, $23, $2d, $14, $01
	.byte	$34, $23, $2d, $24, $23, $2d, $14, $01
	.byte	$44, $23, $44, $23, $24, $01
	.byte	$E4, $01
	.byte	$E4, $01
	.byte	$E4, $01
	.byte	$E4, $01
	.byte	$24, $13, $34, $23, $34, $13, $24, $01
	.byte	$14, $33, $24, $23, $24, $33, $14
	.byte	$00


mouse:
	.byte	$40, $36, $10, $26, $01
	.byte 	$30, $16, $27, $26, $10, $26, $01
	.byte 	$30, $16, $37, $16, $10, $26, $01
	.byte 	$40, $16, $27, $16, $10, $26, $01
	.byte	$50, $66
	.byte	$40, $36, $20, $36, $10, $17, $01
	.byte	$16, $30, $56, $10, $36, $17, $01
	.byte	$10, $16, $30, $86, $01
	.byte	$10, $16, $40, $56, $17, $01
	.byte	$10, $16, $20, $26, $10, $26, $01

	.byte	$10, $16, $20, $66, $17, $01
	.byte	$10, $16, $40, $46, $27, $01
	.byte	$20, $16, $20, $46, $37, $01
	.byte	$30, $26, $10, $36, $27, $01
	.byte	$80, $26, $01
	.byte	$70, $46
	.byte 	$00
