
------------------------------------------------------------
              Llama Calculator (LlamaCalc) for KIM-1/KIM-Uno

                                      2016-01
                               Scott Lawrence
                             yorgle@gmail.com

----------------------------------------
                                Overview

    LlamaCalc was created originally for the RetroChallenge RC2016/1
    competition.  I used it as a way to refine my Kim Uno Remix
    emulator, and more importantly, as a vehicle to learn how to
    code for the 6502 processor.

    I wanted to create an application that would make my KIM-Uno
    useful as a pocket calculator, but using my own way of doing
    things.


----------------------------------------
                              How To use

    The calculator operates in a few modes.  To toggle between them
    you usually will need to press "GO" to go into a different mode.

    When you start up the calculator it will be in "splash mode"

    Here's a description of the different modes:

--------------------
         Splash Mode

	This mode is used to show the startup "splash" screen. It
	will display the current version of the calculator.  It
	looks something like this on the LEDs:

		CA 1C  07

	This says "Calc" (as in "calculator") version 7

	To exit out of this mode, press [GO], to go into result
	mode.


--------------------
         Result Mode

	Most of your time will likely be in result mode. This is
	where you will enter numbers and interact with the stack.

	Since LlamaCalc is a RPN-style calculator, you will need
	to enter values and then push them onto the stack.  The
	stack can (currently) hold 8 items, which should be plenty
	for this application.

	When you start it, it will look like this on the LEDs:

		00 00  00

	As you press 0-9,A-F, it wll enter that value into the
	displayed result, much like the KIM interface itself. So
	if you were to type [1] [3] [5] [C] [2], the display will
	now show:

		01 35  C2

	indicating the hexidecimal value 0x000135C2.  The calculator
	works in 24 bits (3 bytes) so the actual value is, as shown,
	0x0135C2.

	Other buttons in this mode are:

	[+]     Push the current value onto the stack.
		This will retain the result, but also add it to the
		stack. The stack counter will be incremented by
		one.

	[PC]    Pop the current value from the stack.
		This will change the result to be the last item
		pushed onto the stack, and the stack counter is
		decremented by one.

	If you try to push an item onto a full stack, or pop an
	item from an empty stack, an error will be displayed.  Errors
	can be cleared by pressing [GO] to return to Result mode.
	See "Error Mode" below.

	When an error is encountered, the result will not be affected.

	[GO]    This will switch from Result mode into Menu mode.
		See "Menu Mode" below.  (You can return to Result
		mode by pressing [GO] again.)


--------------------
           Menu Mode

	Menu mode is where all of the calculator functionality is
	kept.  As functionality is added, it will be added to this
	area.  If you find yourself in Menu mode but want to go
	back to Result mode, you can press [GO] to return.

	It looks something like this on the LEDs:

		90 90 90

	It is set up to look like "GO GO GO".

	Here's a list of "GO" commands...

	[GO]	return to Result mode

	[B]	*B*inary conversion (BCD To HEX) (future)
		(assumes RESULT is already base 10)
		Result = convertToHex( Result )
		00 01 11 -> 00 00 6F

	[D]	*D*ecimal conversion (Hex To BCD) 
		(assumes RESULT is already base 16)
		Result = convertToBCD( Result )
		00 01 11 -> 00 02 73

	[A]	*A*dd the top of stack to the result
		Stack gets popped in the process

	[5]	*S*ubtract the result from the top of stack 
		Result = the top of stack minus the current result

	[E]	Shift result left 1 bit
		00 01 00  ->  00 02 00

	[F]	Shift result right 1 bit
		00 01 00  ->  00 00 80


		Quick Lookup:
	[GO]
	Result

	[AD]	[DA]	[PC]	[+]

	[C]	[D]	[E]	[F]
		DEC	<<1	>>1

	[8]	[9]	[A]	[B]
			Add	HEX

	[4]	[5]	[6]	[7]
		Sub

	[0]	[1]	[2]	[3]


--------------------
          Error Mode

	When an error is encountered, the calculator will enter
	Error Mode.  It looks something like this on the LEDs:

		EE EE  00

	It is very obvious by the 4 E's (for "Error") on the display.
	The remaining two digits indicate the error code.  I tried
	to make the codes look similar to what caused them.

	Error mode can be exited by pressing [GO].  This will return
	you to Result mode.

	Here's a list of error codes:

		EE EE  00	No error. ;)

		EE EE  5F	Stack Full	(5->S, F->Full)
				You tried to push an item onto a full stack

		EE EE  5E	Stack Empty	(5->S, E->Empty)
				You tried to pop an item from a full stack

		EE EE  51	Math Stack error 
				You tried to do a math thing with an empty stack

		EE EE  FF	Operation not implemented yet
