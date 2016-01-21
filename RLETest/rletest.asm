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

	jsr	rleRenderStripes

	jsr 	rleRenderRedGhost

	rts


SCREEN    = $20
SCREENBAK = $22
IMAGE     = $24
COLOR     = $26
REPS      = $27

rleRenderStripes:
	; setup IMAGE to point to image to be drawn
	lda	#<stripesRLE
	sta	IMAGE
	lda	#>stripesRLE
	sta	IMAGE+1
	ldy	#$00		; start it at this Y position 00..1f
	ldx	#$00		; start at this X position
	jsr	rleAdjustXY
	rts

rleRenderRedGhost:
	; setup IMAGE to point to image to be drawn
	lda	#<redGhostRLE
	sta	IMAGE
	lda	#>redGhostRLE
	sta	IMAGE+1
	ldy	#$0A		; start it at this Y position 00..1f
	ldx	#$0A		; start at this X position
	jsr	rleAdjustXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rleAdjustXY:
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
	sta	SCREENBAK+1 	; set it aside for 0F 

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
	sta	SCREENBAK 	; set it aside for 0F 

	; 0.B initialize our loop variables...
	lda	#0
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
	lda	REPS
	cmp	#$00
	beq	rleNext

	; 1. if REPS > 0  
	; 1.a output the color to memory
	; 1.b advance to next screen pos
	; 1.c dec REPS
	; 1.d goto loop

	; ok. more to do
	dec	REPS		; REPS--

	; output color
	lda	COLOR
	sta	(SCREEN), y

	; increment position
	inc	SCREEN

	; go again...
	jmp	rleLoop

rleNext:
	; 2, if REPS == 0
	; 2.a get next byte from the image data
	ldx	#0
	lda	(IMAGE, x)	; A = current image pointer item
	sta	COLOR
	lsr
	lsr
	lsr
	lsr
	sta	REPS

	; inc IMAGE but adjust for bank switchover
	clc
	lda	IMAGE
	adc	#$01
	sta	IMAGE
	lda	IMAGE+1
	adc	#$00
	sta	IMAGE+1


	; 3. if byte & 0xF0 nz
	; 3.a load this into reps
	; 3.b load the byte into color
	; 3.c goto loop


	; 4. if byte == 0x00
	; 4.a  goto DONE
	lda	COLOR
	cmp	#$00
	beq	rleDone

	
	; 5. if byte == 0x0F
	; 5.a advance cursor to next Y start position
	; 5.b goto loop

	lda	COLOR
	cmp	#$0F
	beq	rleNextLine

	jmp	rleLoop
	

rleNextLine:
	; add $20 to the last known backup, and use that
	clc
	lda	SCREENBAK
	adc	#$20
	sta	SCREENBAK
	sta	SCREEN

	lda	SCREENBAK+1
	adc	#0
	sta	SCREENBAK+1
	sta	SCREEN+1

	jmp 	rleNext


rleDone:
	rts


; 0F	- end of line
; 00	- end of image

; 0 black
; 3 white
; 4 red
; D blue

; 6 brown
; 7 orange
; 

stripesRLE:
	.byte	$20, $21, $22, $23, $24, $25, $26, $27, $0F
	.byte	$28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $0F

	.byte	$10, $11, $12, $13, $14, $15, $16, $17, $0F
	.byte	$18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $0F
	.byte	$18, $19, $1A, $1B, $1C, $1D, $1E, $1F
	.byte	$00	; END OF IMAGE



.org $0400
redGhostRLE:
	.byte	$50, $44, $0F
	.byte	$30, $84, $0F
	.byte	$20, $A4, $0F
	.byte	$10, $34, $23, $44, $23, $14, $0F
	.byte	$10, $24, $43, $24, $43, $0F
	.byte	$34, $23, $2d, $24, $23, $2d, $14, $0F
	.byte	$34, $23, $2d, $24, $23, $2d, $14, $0F
	.byte	$44, $23, $44, $23, $24, $0F
	.byte	$E4, $0F
	.byte	$E4, $0F
	.byte	$E4, $0F
	.byte	$E4, $0F
	.byte	$24, $10, $34, $20, $34, $10, $24, $0F
	.byte	$14, $30, $24, $20, $24, $30, $14
	.byte	$00


mouseRLE:
	.byte	$40, $36, $10, $26, $0F
	.byte 	$30, $16, $27, $26, $10, $26, $0F
	.byte 	$30, $16, $37, $16, $10, $26, $0F
	.byte 	$40, $16, $27, $16, $10, $26, $0F
	.byte	$50, $66
	.byte	$40, $36, $20, $36, $10, $17, $0F
	.byte	$16, $30, $56, $10, $36, $17, $0F
	.byte	$10, $16, $30, $86, $0F
	.byte	$10, $16, $40, $56, $17, $0F
	.byte	$10, $16, $20, $26, $10, $26, $0F

	.byte	$10, $16, $20, $66, $17, $0F
	.byte	$10, $16, $40, $46, $27, $0F
	.byte	$20, $16, $20, $46, $37, $0F
	.byte	$30, $26, $10, $36, $27, $0F
	.byte	$80, $26, $0F
	.byte	$70, $46
	.byte 	$00
