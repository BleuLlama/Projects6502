; program to test the display
; 2015-11-15
; Scott Lawrence - yorgle@gmail.com

.define VERSIONL #$00
.define VERSIONH #$00
UseVideoDisplay0 = 1

.include "KimDefs.asm"
.include "KimCode200.asm"
.include "KimLib.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main 
;  - the library entry point.
main:
	jsr cls		; clear the screen black
	jsr discodisco	; disco lights
	jsr end		; end it

discodisco:
	inx
	txa
	sta RASTER, y
	sta $4100, y
	sta $4200, y
	sta $4300, y
	iny
	tya
	cmp 16
	bne dd1
	iny
	jmp discodisco
dd1:
	iny
	iny
	iny
	iny
	jmp discodisco

