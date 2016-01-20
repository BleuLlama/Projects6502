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

	jsr	rleRender

: 	jmp	:-


SCREEN = $20
IMAGE  = $22
COLOR  = $24
REPS   = $25

rleRender:
	; setup IMAGE to point to image to be drawn
	lda	#<stripesRLE
	sta	IMAGE
	lda	#>stripesRLE
	sta	IMAGE+1
	ldy	#$10		; start it at this Y position 00..1f
	ldx	#$0		; start at this X position
	jsr	rleDecoder
	rts

rleDecoder:
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

	; initialize our loop variables...
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
	; get the next byte
	ldx	#0
	lda	(IMAGE, x)

	; check for commands
	cmp	#$00
	beq 	foodone

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
	.byte	$10, $11, $12, $13, $14, $15, $16, $17
	.byte	$18, $19, $1A, $1B, $1C, $1D, $1E, $1F
	.byte	$10, $11, $12, $13, $14, $15, $16, $17
	.byte	$18, $19, $1A, $1B, $1C, $1D, $1E, $1F
	.byte	$00	; END OF IMAGE




image:
	;	blk  red  wht  red  wht  red  end
	.byte	$51, $44,                     $01
	.byte	$31, $84,                     $01
	.byte	$21, $A4,                     $01
	.byte	$11, $34, $23, $44, $23, $14, $01
	.byte	$11, $24, $43, $24, $43,      $01
	.byte	$00

	.byte 	$0f, $0f, $0f, $0f
	.byte	$11, $22, $33, $00


	.byte	$01, $02, $03, $04, $05, $06, $07, $08
	.byte $9, $a, $b, $c, $d, $e, $f
	.byte	$01, $02, $03, $04, $05, $06, $07, $08
	.byte $9, $a, $b, $c, $d, $e, $f
	.byte	$01, $02, $03, $04, $05, $06, $07, $08
	.byte $9, $a, $b, $c, $d, $e, $f
	.byte	$01, $02, $03, $04, $05, $06, $07, $08
	.byte $9, $a, $b, $c, $d, $e, $f
	.byte	$01, $02, $03, $04, $05, $06, $07, $08
	.byte $9, $a, $b, $c, $d, $e, $f
	.byte	$01, $02, $03, $04, $05, $06, $07, $08
	.byte $9, $a, $b, $c, $d, $e, $f

