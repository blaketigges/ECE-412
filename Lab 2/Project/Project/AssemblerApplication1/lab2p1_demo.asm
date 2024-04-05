/*
 * lab2p1.asm
 * Nested Positive 8 bit Integer Division
 * Created: 2:07:42 PM
 * Author: Eugene Rockey
*/	
;****************************
;* Declare Variables  
;*********************

			.dseg
			.org	0x100			;originate data storage at address 0x100
quotient:	.byte	1				;uninitialized quotient variable stored in SRAM aka data segment
remainder:	.byte	1				;uninitialized remainder variable stored in SRAM
			.set	count = 0		;initialized count variable stored in SRAM
;******************************
			.cseg					; Declare and Initialize Constants (modify them for different results)
			.equ	dividend = 13	;8-bit dividend constant (positive integer) stored in FLASH memory aka code segment
			.equ	divisor = 3		;8-bit divisor constant (positive integer) stored in FLASH memory
;******************************
;* Vector Table (partial)
;******************************
			.org	0x0
reset:		jmp		main			;RESET Vector at address 0x0 in FLASH memory (handled by MAIN)
int0v:		jmp		int0h			;External interrupt vector at address 0x2 in Flash memory (handled by int0)
;******************************
;* MAIN entry point to program*
;******************************
			.org	0x100			;originate MAIN at address 0x100 in FLASH memory (step through the code) (stack?, 0xCURRENT -> 0xAFTER, CurPC -> AfterPC)
main:		call	init			;initialize variables subroutine, set break point here, check the STACK,SP,PC (01 02 onto stack dec by 2, 0x08FF -> 0x08FD, 0x00000100 -> 0x00000104)
endmain:	jmp		endmain
init:		lds		r0,count		;get initial count, set break point here and check the STACK,SP,PC (stack unchanged, 0x08FD -> 0x08FD, 0x00000104 -> 0x00000106)
			sts		quotient,r0		;use the same r0 value to clear the quotientsts
			sts		remainder,r0	;and the remainder storage locations
			call	getnums			;Check the STACK,SP,PC here. (01 0c onto stack dec by 2, 0x08FD -> 0x08FB, 0x0000010A -> 0x0000010D)
			ret						;return from subroutine, check the STACK,SP,PC here. (Read stack into PC inc by 2, 0x08FD -> 0x08FF, 0x0000010C -> 0x00000102)
getnums:	ldi		r30,dividend	;Check the STACK,SP,PC here. (stack unchanged, 0x08FB -> 0x08FB, 0x0000010D -> 0x0000010E)
			ldi		r31,divisor
			call	test			;Check the STACK,SP,PC here. (01 11 onto stack dec by 2, 0x08FB -> 0x08F9, 0x0000010F -> 0x00000112)
			ret						;Check the STACK,SP,PC here. (Read stack into PC inc by 2, 0x08FB -> 0x08FD, 0x00000111 -> 0x0000010C)
test:		cpi		r30,0			; is dividend == 0 ?
			brne	test2
test1:		jmp		test1			; halt program, output = 0 quotient and 0 remainder
test2:		cpi		r31,0			; is divisor == 0 ?
			brne	test4
			ldi		r30,0xEE		; set output to all EE's = Error division by 0
			sts		quotient,r30
			sts		remainder,r30
test3:		jmp		test3			; halt program, look at output
test4:		cp		r30,r31			; is dividend == divisor ?
			brne	test6
			ldi		r30,1			;then set output accordingly
			sts		quotient,r30
test5:		jmp		test5			; halt program, look at output
test6:		brpl	test8			; is dividend < divisor ?
			ser		r30
			sts		quotient,r30
			sts		remainder,r30	; set output to all FF's = not solving Fractions in this program
test7:		jmp		test7			; halt program look at output
test8:		call	divide			;Check the STACK,SP,PC here. (01 30 onto stack dec by 2, 0x08F9 -> 0x08F7, 0x0000012E -> 0x00000131)
			ret						; otherwise, return to do positive integer division (Read stack into PC inc by 2, 0x08F9 -> 0x08FB, 0x00000130 -> 0x00000111)
divide:		lds		r0,count		; Loads count into r0
divide1:	inc		r0				; Increments count for each loop, represents how many times divisor wholly goes into dividend 
			sub		r30,r31			; Subtracts divisor (r31) from dividend (r30)
			brpl	divide1			; If above result is posistive go back to start of loop, else continue and find remainder
			dec		r0				; If result was negative decrease quotient
			add		r30,r31			; Add divisor back into dividend to revert negative
			sts		quotient,r0		; Store r0 into quotient
			sts		remainder,r30	; Store r30 into remainder
divide2:	ret						; return (Read stack into PC inc by 2, 0x08F7 -> 0x08F9, 0x0000013C -> 0x00000130)
int0h:		jmp		int0h			; interrupt 0 handler goes here