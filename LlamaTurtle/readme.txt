LlamaMicroTurtle  LMT

The basic idea for LlamaTurtle is that it's a simplified ASM-like
Logo-like turtle graphics renderer for the KIM+Framebuffer0

It would interpret a program that you could easily handcode into a
block, live on the KIM.

Opcodes (in HEX) are picked because their value looks like what
they do.

Proposed list:


    Direction as Hex:

		0
	      F | 1
	    E   |   2
	  D     |     3
	C-------+-------4
	  B     |     5
	    A   |   6
	      9 | 7
		8

	0 4 8 C  are direct
	2 6 A E  are 45 degree

	Rise/Run for 0..4: (two steps indicate full movement angle)
	0: 10 10
	1: 10 11
	2: 11 11
	3: 11 01
	4: 01 01



     Opcodes	What it is			LOGO/BASIC equivalentish

	00	END				END
	1x	Call subroutine x		GOSUB x

	2x	Loop 2: repeat x times.		FOR TWO = 0 TO x {
	3x	Loop 3: repeat x times.		FOR THREE = 0 TO x {
	4x	Loop 4: repeat x times.		FOR FOUR = 0 TO x {
	5x	Loop 5: repeat x times.		FOR FIVE = 0 TO x {
	6x	Loop 6: repeat x times.		FOR SIX = 0 TO x {

	7x	Turn to angle x			-
	8x	Start Subroutine x		SUB x {
	9x	End Subroutine x		}
	
	Ax	Turn to angle +x (delta)	RT x
	Bx	(tbd)
	Cx 	Color x				SET PEN COLOR x  .. (C0 = ERASE)

	Dx	(tbd)
	Ex	Extended commands (below)
	Fx	move forward x steps		FD X

    Extended commands:

	E0	PEN UP
	E1	PEN DOWN
	E2	End of loop 2			} NEXT TWO
	E3	End of loop 3			} NEXT THREE
	E4	End of loop 4			} NEXT FOUR
	E5	End of loop 5			} NEXT FIVE
	E6	End of loop 6			} NEXT SIX

	E7-EF	(tbd)
	


