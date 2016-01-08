;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GameOfLife
;
; ported 2016-01 Scott Lawrence
; from http://6502asm.com
;
; Scott Lawrence - yorgle@gmail.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version history

.define VERSIONH #$00
.define VERSIONL #$01


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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	lda	#$0
	ldy	#$0
	ldx	$4000
	inx
	txa
	jsr 	fillscr
	lda	#$0
	ldx	#$0
	ldy	#$0


; Conway\'s Game of Life
; http://rosettacode.org/wiki/Conway\'s_Game_of_Life
; Submitted by Anonymous

life:

randfill:   stx $01          ;$200 for indirect
            ldx #$40         ;addressing
            stx $02
randloop:   lda RANDOM          ;generate random
            and #$01         ;pixels on the
            sta ($01),Y      ;screen
            jsr inc0103
            cmp #$00
            bne randloop
            lda $02
            cmp #$06
            bne randloop
 
 
clearmem:   lda #$df         ;set $07df-$0a20
            sta $01          ;to $#00
            lda #$07
            sta $02
clearbyte:  lda #$00
            sta ($01),Y
            jsr inc0103
            cmp #$20
            bne clearbyte
            lda $02
            cmp #$0a
            bne clearbyte
 
 
starttick:
copyscreen: lda #$00         ;set up source
            sta $01          ;pointer at
            sta $03          ;$01/$02 and
            lda #$40         ;dest pointer
            sta $02          ;at $03/$04
            lda #$08
            sta $04
            ldy #$00
copybyte:   lda ($01),Y      ;copy pixel to
            sta ($03),Y      ;back buffer
            jsr inc0103      ;increment pointers
            cmp #$00         ;check to see
            bne copybyte     ;if we\'re at $600
            lda $02          ;if so, we\'ve
            cmp #$06         ;copied the
            bne copybyte     ;entire screen
 
 
conway:     lda #$df         ;apply conway rules
            sta $01          ;reset the pointer
            sta $03          ;to $#01df/$#07df
            lda #$01         ;($200 - $21)
            sta $40          ;($800 - $21)
            lda #$07
            sta $04
onecell:    lda #$00         ;process one cell
            ldy #$01         ;upper cell
            clc
            adc ($03),Y
            ldy #$41         ;lower cell
            clc
            adc ($03),Y
chkleft:    tax              ;check to see
            lda $01          ;if we\'re at the
            and #$1f         ;left edge
            tay
            txa
            cpy #$1f
            beq rightcells
leftcells:  ldy #$00         ;upper-left cell
            clc
            adc ($03),Y
            ldy #$20         ;left cell
            clc
            adc ($03),Y
            ldy #$40         ;lower-left cell
            clc
            adc ($03),Y
chkright:   tax              ;check to see
            lda $01          ;if we\'re at the
            and #$1f         ;right edge
            tay
            txa
            cpy #$1e
            beq evaluate
rightcells: ldy #$40         ;upper-right cell
            clc
            adc ($03),Y
            ldy #$22         ;right cell
            clc
            adc ($03),Y
            ldy #$42         ;lower-right cell
            clc
            adc ($03),Y
evaluate:   ldx #$01         ;evaluate total
            ldy #$21         ;for current cell
            cmp #$03         ;3 = alive
            beq storex
            ldx #$00
            cmp #$02         ;2 = alive if
            bne storex       ;c = alive
            lda ($03),Y
            and #$01
            tax
storex:     txa              ;store to screen
            sta ($01),Y
            jsr inc0103      ;move to next cell
conwayloop: cmp #$e0         ;if not last cell,
            bne onecell      ;process next cell
            lda $02
            cmp #$05
            bne onecell
            jmp starttick    ;run next tick
 
 
inc0103:    lda $01          ;increment $01
            cmp #$ff         ;and $03 as 16-bit
            bne onlyinc01    ;pointers
            inc $02
            inc $04
onlyinc01:  inc $01
            lda $01
            sta $03
            rts
