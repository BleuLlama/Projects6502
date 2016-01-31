; simple picture
;	just to try out loading right into the video buffer...
;
; 2016-01-21
; Scott Lawrence - yorgle@gmail.com

.code
.org $0200			; start at 0200 (KIM)

start:
	jmp	start		; do nothing, forever

	; skip to the video buffer location
.org $4000
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$8, $9, $a, $b, $c, $d, $e, $f

	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0

	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$8, $9, $a, $b, $c, $d, $e, $f

	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0

	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7
	.byte	$0, $1, $2, $3, $4, $5, $6, $7

	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0
	.byte	$0, $0, $0, $0, $0, $0, $0, $0

	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
	.byte	$8, $9, $a, $b, $c, $d, $e, $f
