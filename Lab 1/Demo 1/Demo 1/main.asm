;
; Demo 1.asm
;
; Created: 1/31/2024 10:54:54 PM
; Author : blake
;
		.cseg					; FLASH code segment
		.org	0x0				; Begin code at address 0x0
start:	
// add and subtract two numbers showing result in a register
		ldi		r30,1			; Store 1 in register 30	
		ldi		r31,2			; Store 2 in register 31
		add		r31,r30			; Add 1 + 2 and store 3 in register 31
		sub		r31,r30			; Subtract 1 from 3 and store in register 31

// multiply two numbers showing result in a register.
		ldi		r26,11			; Store 11 in r26
		ldi		r27,5			; Store 5 in r27
		mul		r26,r27			; Multiply 5x11 and store in r0(low) and r1(high)

// negate a register and set bits in a register.
		ldi		r19,10			; Store 10 in r19
		neg		r19				; Negate r19 so 10 = 246 
		sbr		r19,0xAF		; Set bits 0-3 in r19 (r19 = r19 OR 0xAF) r19 should be 0xFA so only A is changed to F

// clear a register.
		clr		r19				; Clear r19

// transfer a number from a register to an SRAM location.
		ldi		r19,42			; Store 42 in r19
		sts		0x0100,r19		; Store the value of r19 into SRAM address 0x0100

// transfer a number from an SRAM location to a register.
		lds		r20,0x0100		; Load the value from SRAM address 0x0100 into r20

// Copy one register to another.
		ldi		r19,44			; Change r19 so it has something to copy to r20
		mov		r20,r19			; Copy the value from r19 to r20

// Conditionally branch to another part of the code.
		cpi		r19,44			; Compare r19 with 44
		brne	another_part	; Branch if not equal to label, it is equal so wont branch

// Unconditionally branch or jump to another part of the code.
		rjmp	another_part	; Jump to the label "another_part"

// Set and Clear the carry bit in the status register.
here:	sec						; Set carry flag
		clc						; Clear carry flag

// Swap the two nibbles of an 8-bit register.
		swap	r19				; Swap the two nibbles of r19

// Create a DO-UNTIL loop.
		ldi		r19,5			; Set r19 to 5
do:		nop						; do something (nothing)
		dec		r19				; Decrement r19
		brne	do				; Do unless r19 is 0

// Create a FOr-NEXT loop.
		ldi		r19,10			; Set r19 to 10
for:	cpi		r19,5			; compare r19 to 5
		brpl	loop			; Branch if r19 greater than or equal to 5
		rjmp	exit			; if it doesnt branch exit
loop:	nop						; do nothing
		dec		r19				; decrease r19
		rjmp	for				; go back to start of for loop
exit:	nop						; exit
		
		rjmp		end			; Jump to end and skip the another_part section
another_part:
		clr		r26				; Clear r26
		rjmp		here		; Jump back to next section in checklist
	
end:	.exit	