; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
; Kim ROM/RAM defines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; keypad - ROM functions

; key presses
AK	= $1EFE	; ROMFN: key down a=0, key up a<>0
GETKEY  = $1F6A	; ROMFN: A>15 = bad key, otherwise, it's the key

; key codes
.define KEY_NONE #$15
.define  KEY_SPECIAL_MASK #$10
.define   KEY_AD #$10
.define   KEY_DA #$11
.define   KEY_PL #$12
.define   KEY_GO #$13
.define   KEY_PC #$14


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7-seg display - ROM functions

SCANDS	= $1F1F	; ROMFN: refresh KIM_POINTL,POINTH,INH to the display


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Serial TTY - ROM functions

GETCH	= $1E5A	; ROMFN: Gets TTY char to A
OUTCH	= $1EA0	; ROMFN: Prints A as ASCII to TTY
OUTSP	= $1E9E	; ROMFN: Prints ' ' to TTY
PRTBYT	= $1E3B	; ROMFN: TTY Out A as 2 hex chars
PRTPNT	= $1E1D	; ROMFN: Prints FB, FA to TTY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; KIM-1 Zero Page memory usage

	; Machine Register Storage Buffer
MREG_PCL	= $EF	; program counter - low order byte
MREG_PCH	= $F0	; program counter - high order byte
MREG_P		= $F1	; status register
MREG_SP		= $F2	; stack pointer
MREG_A		= $F3	; accumulator
MREG_Y		= $F4	; y-index register
MREG_X		= $F5	; x-index register

	; Fixed area in page 0
KIM_CHKHI	= $F6
KIM_CHKSUM 	= $F7
KIM_INL		= $F8	; input buffer
KIM_INH		= $F9	; input buffer   ; displayed data byte
KIM_POINTL	= $FA	; LSB of open cell
KIM_POINTH	= $FB	; MSB of open cell
KIM_TEMP	= $FC
KIM_TMPX	= $FD
KIM_CHAR	= $FE
KIM_MODE	= $FF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; KIM-1 Rom/Timer - Control addresses

KIM_SAD		= $1700	; DA  Data reg A
KIM_PADD	= $1701 ; DDA Data direction A
KIM_SBD		= $1702	; DB  Data reg B
KIM_PBDD	= $1703 ; DDB Data direction B

	; timers
KIM_C1D		= $1704	; Div by 1	disable int
KIM_C8D		= $1705	; Div by 8	disable int
KIM_C64D	= $1706	; Div by 64	disable int
KIM_C1024D	= $1707	; Div by 1024	disable int

KIM_C1E		= $170C	; Div by 1	enable int
KIM_C8E		= $170D	; Div by 8	enable int
KIM_C64E	= $170E	; Div by 64	enable int
KIM_C1024E	= $170F	; Div by 1024	enable int

KIM_TRD		= $1706 ; Read time disable int
KIM_SR		= $1707 ; Read int stat
KIM_TRE		= $170E ; Read time enable int

	; Audio Tape load & dump

KIM_SAL		= $17F5	; starting address - low order byte
KIM_SAH		= $17F6	; starting address - high order byte
KIM_EAL		= $17F7	; ending address - low order byte
KIM_EAH		= $17F8	; ending address - high order byte
KIM_ID		= $17F9 ; file identification number

KIM_DUMPT	= $1800 ; Start address audio tape dump
KIM_LOADT	= $1873 ; Start address audio tape load

	; interrupt vectors

KIM_NMIL	= $17FA ; NMI vector - low order byte
KIM_NMIH	= $17FB ; NMI vector - high order byte
KIM_RSTL	= $17FC ; RST vector - low order byte
KIM_RSTH	= $17FD ; RST vector - high order byte
KIM_IRQL	= $17FE ; IRQ vector - low order byte
KIM_IRQH	= $17FF ; IRQ vector - high order byte

KIM_STOPSST	= $1C00 ; Start address for NMI using KIM Save Machine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Misc KIM Uno Extensions

; EF -- FF are reserved for KIM
RANDSEED = $ED	; Write: set the new seed  (on 6502.org this is key input)
RANDOM	 = $EE	; Read: new random value each call



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Video Display 0

RASTER	= $4000	; base of raster memory (on 6502.org this is at $0200)

.define   COLOR_BLACK		#$00
.define   COLOR_DKGRAY		#$01
.define   COLOR_LTGRAY		#$02
.define   COLOR_WHITE		#$03

.define   COLOR_RED		#$04
.define   COLOR_DKRED		#$05
.define   COLOR_BROWN		#$06
.define   COLOR_ORANGE		#$07
.define   COLOR_YELLOW		#$08

.define   COLOR_GREEN		#$09
.define   COLOR_DKGREEN		#$0A
.define   COLOR_BLUGREEN	#$0B
.define   COLOR_CYAN		#$0C

.define   COLOR_BLUE		#$0D
.define   COLOR_VIOLET		#$0E
.define   COLOR_PURPLE		#$0F

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

