; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; KimLib
;   Standard use library functions
;
; 2015-12-29+
; Scott Lawrence - yorgle@gmail.com

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   include this after including "KimDefines.asm"
;   
;   the entry point for your code should be a label called "main"
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Feature defines (define these to use the feature)
;
;   UseVideoDisplay0 = 1  ; turn on Video Display framebuffer at $4000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Required defines
;
;   .define VERSIONH #01  ; \__ this becomes 01.02 for version display 
;   .define VERSIONL #02  ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; entrypoint
;  - this is where the code will start from
;  - we have this jump to the user's 'main' 
entrypoint:
	jmp main


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end
;  - jump here to end everything (centralized)
end:
	brk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cls7seg
;  - clear the 7 segment display (zeroes)
;  A - junked
cls7seg:
	lda     #$00
	sta     KIM_POINTH	; left two digits
	sta     KIM_POINTL	; middle two digits
	sta     KIM_INH		; right two digits
	jsr     SCANDS		; draw it to the display

	rts			; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; displayVersion
;  - display VERSIONH/VERSIONL to the display
;  A - junked
displayVersion:
	lda     #$00
	sta     KIM_INH		; right two digits

	lda     VERSIONH
	sta     KIM_POINTH	; v00
	lda     VERSIONL
	sta     KIM_POINTL	;    01

	jsr     SCANDS		; draw it to the display

	rts			; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Video Display 0 support

.if .defined(UseVideoDisplay0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cls
;  - clear the screen
;  -  jsr cls	- fills with black
;  -  jsr fillscr	- fills with the color in (A & 0x0F)
cls:
        lda     #$00    ; a = 7 ; color

fillscr:
        tax             ; x = a (store it aside)
        ldy     #$00    ; y = 0

clsloop:
	; we'll do this call 4 times for each 255 byte (0x0100) sections
	; we could do it once for each section, but it's a lot slower.
	; we can do it 8 times for each section, but it doubles the code
	; chunk, so we'll just go with this for now. whatever.
        sta 	RASTER + $0000, y
        sta 	RASTER + $0100, y
        sta 	RASTER + $0200, y
        sta 	RASTER + $0300, y

        sta 	RASTER + $0040, y
        sta 	RASTER + $0140, y
        sta 	RASTER + $0240, y
        sta 	RASTER + $0340, y

        sta 	RASTER + $0080, y
        sta 	RASTER + $0180, y
        sta 	RASTER + $0280, y
        sta 	RASTER + $0380, y

        sta 	RASTER + $00C0, y
        sta 	RASTER + $01C0, y
        sta 	RASTER + $02C0, y
        sta 	RASTER + $03C0, y

	; use $FF for single, $7F for double,  $3F for quad
	iny
        cpy	#$40		; does y==(last)?
        bne	clsloop		; nope, go again

	rts

gfxNoise:
        ; display some nosie to the lcd
        ldx     #$80
:       lda     RANDOM
        sta     RASTER,Y
        ldy     RANDOM
        lda     RANDOM
        sta     RASTER+$100,Y
        ldy     RANDOM
        lda     RANDOM
        sta     RASTER+$200,Y
        ldy     RANDOM
        lda     RANDOM
        sta     RASTER+$300,Y
        inx
        cmp     #0
        bne     :-
	rts


.endif ; UseVideoDisplay0

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
