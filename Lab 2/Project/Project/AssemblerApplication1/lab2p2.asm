/*
 *  lab2p2.asm
 *  Celsius to Fahrenheit Look-Up Table
 *  Created: 10:17:31 AM
 *  Author: Eugene Rockey
 */
			.dseg
			.org	0x100
output:		.byte	1					;student comment goes here
			.cseg
			.org	0x0
			jmp		main				;partial vector table at address 0x0
			.org	0x100				;MAIN entry point at address 0x200 (step through the code)
main:		ldi		ZL,low(2*table)		;Load low byte of table address into Z low
			ldi		ZH,high(2*table)	;Load high byte of table address into Z high, Z now points to table
			ldi		r16,celsius			;Load celsius into r16
			add		ZL,r16				;Add r16 to ZL, incrementing table address by the celsius value
			ldi		r16,0				;set r16 to 0
			adc		ZH,r16				;Add carry from previous addition if needed
			lpm							;lpm = lpm r0,Z in reality, what does this mean? Loads value of address stored in Z into r0, this will be address of table + celsius which is where the Fahrenheit value will be
			sts		output,r0			;store look-up result to SRAM
			ret							;consider MAIN as a subroutine to return from - but back to where?? Stack was 0 so it sets PC to zero, returns to first instruction.
										; Fahrenheit look-up table 
table:		.db		32, 34, 36, 37, 39, 41, 43, 45, 46, 48, 50, 52, 54, 55, 57, 59, 61, 63, 64, 66
			.equ	celsius = 5			;modify Celsius from 0 to 19 degrees for different results
			.exit