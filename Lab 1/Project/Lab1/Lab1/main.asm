/*
*
*	projectl. asm
*
*	Created: 1/18/2022 5:18:16 PM
*	Author: Eugene Rockey
*/
// Ctrl + K then Ctrl + C to comment code
/*		.eseg				;EEPROM data segment, 0x0 to 0x3FF
		.org	0x0			;Begin EEPROM segment at address 0x0
eevar:	.dw		0xfaff		;Store a constant 16-bit data in EEPROM
msg:	.db		"HelloWorld";Store a constant string data in EEPROM
		.dseg				;SRAM data segment, 0x100 to 0x8FF
		.org	0x100		;Begin data segment at address 0x00
string:	.byte	3			;a three byte variable
		.cseg				;FLASH code segment, 0x0 to 0x3FFF
		.org	0x0			;Begin code at address 0x0
start:	ldi		r30,56		;load immediate value 56 into register 30
		ldi		r31,24		;load immediate value 24 into register 31
		add		r31,r30		;56+24=80 ; store 80 into register 31 and overwrite 24
here:	jmp		here		;jump to here forever or infinite loop
		.exit				;make .exit the very last line
*/

// Arithmetic, logic, Data Transfer Instructions
/*		.cseg				;FLASH code segment
		.org	0x0
start:	ldi		r26,0x00	;load immediate value 0x00 into register 26
		ldi		r27,0x01	;load immediate value 0x01 into register 27
		ldi		r30,56		;load immediate value 56 into register 30
		ldi		r31,24		;load immediate value 24 into register 31
		add		r31,r30		;Add values in r31 and r30, answer stored in r31, H flag 1
		sub		r31,r30		;Subtract r30 from r31, store in r31
		and		r30,r31		;Performs logical and between r30 and r31 stores in r30
		mul		r30,r31		;Multiple r30 and r31 stored in r0 (low) and r1 (high)
		st		X,r30		;Store r30 in data space
  		clr		r30			;Set r30 to 0, sets Z flag 1
		ser		r31			;Sets all bits in r31 to 1
here:	jmp		here		;Jumps to here section
		.exit*/

// Conditional Branch Instructions
/*		.cseg
		.org	0x0
start:	ldi		r26,0x00
		ldi		r27,0x01
		ldi		r30,56
		ldi		r31,24
		sub		r31,r30
		brmi	here		;Branch if negative flag is set
		st		X,r30		;Store r30 in data space
		nop					;Do nothing
		clr		r30			;Set r30 to 0
here:	breq	here		;Branch if zero flag
		.exit*/

// bit instructions?
		.cseg
		.org	0x0
start:	ldi		r26,0x00
		ldi		r27,0x01
		ldi		r30,0xAC
		lsl		r30			;Shifts bits left, bit 0 cleared, bit 7 into C Flag (r30x2)
		lsr		r30			;Shifts bits right, bit 7 cleared, bit 0 into c flag (r30/2)
		asr		r30			;Shifts bits right, bit 7 constant, bit 0 into c flag (r30/2 same sign)
		bset	2			;Set a flag or bit
		bclr	2			;Clear a flag or bit
		brmi	here
		st		X+,r30		;Stores r30 in x then increments x
		st		X+,r30		;Stores r30 in x then increments x
		st		X+,r30		;Stores r30 in x then increments x
here:	jmp		here
		.exit