; simple starting point. (no additional dependencies)
; 2015-11-15
; Scott Lawrence - yorgle@gmail.com

.code
.org $0200			; start at 0200 (KIM)

start:
	ldx	#$00		; reset X register to 0
:
	txa			; A = X
	sta	$4000,x		; copy to the first bank of the screen
	sta	$4200,x		; copy to the third bank of the screen
	inx			; X = X + 1
	bne	:-		; if X != 0 (didn't wrap around) repeat
	
end:
	rts			; done
