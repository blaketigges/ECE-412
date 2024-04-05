/*
 *  lab2p2_demo.asm
 *  Sort
 *  Author: Blake Tigges
 */
			.dseg
			.org	0x100
output:		.byte	1					;student comment goes here
flags:		.byte	20					;Flags for if element is stored
			.cseg
			.org	0x0
			jmp		main				;partial vector table at address 0x0
			.org	0x100				;MAIN entry point at address 0x200 (step through the code)

										; Iterate thourgh loop, store max in register, then put them in iram
main:		ldi		r21,0				;Count of values added to IRAM
			ldi		r20,20				;Length of array
			ldi		XH,3				;IRAM address for sorted array
			call	iter
			call	sortloop
iter:		ldi		r17,0				;Use as count of runs through array
			ldi		ZL,low(2*table)		;Load low byte of table address into Z low
			ldi		ZH,high(2*table)	;Load high byte of table address into Z high
			ldi		YL,low(2*flags)		;Load low byte of flags address into Y low
			ldi		YH,high(2*flags)	;Load high byte of flags address into Y high
			ldi		r18,0				;Max value
			ldi		r23,0
			lpm		
			ret

loadnext:	inc		ZL					;Increment flash address in Z	
			lpm							;Load new value from flash
			ret

maxval:		cp		r18,r0				;Compare new with max
			brge	return			;If new value bigger and not flagged then store it
			mov		r15,r23				;Store previous index incase this one is flagged
			mov		r23,r17				;Store index of max value
			call	checkflag			;Check if index has been flagged
			cpi		r24,255				;Check if value has been stored
			breq	resttemp			;If value has been stored then iterate through loop
			mov		r18,r0				;Max value
			ret

resttemp:	mov		r23,r15
			jmp		return

store:		st		X+,r18				;Store max in X+ then inc x
			call	checkflag
			call	setflag				;Set flag for value
			inc		r21					;Increment count of values added to IRAM
			cpi		r21,20  			;Check if all values have been added to IRAM
			breq	exit				;If all values have been added to IRAM then exit
			call	iter				;If not then iterate through loop
			ret

checkflag:	;code to check flag array for the byte corresponding to element in table
			ldi		YL,low(2*flags)		;Load low byte of flags address into Y low
			ldi		YH,high(2*flags)	;Load high byte of flags address into Y high
			ldi		r22,0				;Use as index for flags, 
			call	flagloop			;Iterate through flags
			ld 		r24,Y				;Load flags
			ret

flagloop:	cp		r22,r23				; compare r23 to r23
			brne	loop				; Branch if not equal
			ret
loop:		ld		r24,Y+				; inc Y
			inc		r22					;Increment r22
			rjmp	flagloop					; go back to start of for loop
			
setflag:   ;code to set the flag array for the byte corresponding to element in table ONLY CALL AFTER CHECKING
			ldi 	r24,255				;Set r24 to 255
			st 		Y,r24				;Store 255 in flags
			ret

length:		cpse	r17,r20				;If done skip return
			ret
			call	store				;If not then store max in IRAM
			ret

sortloop:	call	length				;Check if iterated through whole array
			call	maxval				;If r0 greater than r18 store in r18
			call	loadnext			;Load current value into r16 and next value into r0
			inc		r17
			call	sortloop
			ret

return:		ret
table:		.db		32, 02, 86, 37, 39, 41, 43, 45, 46, 48, 50, 52, 54, 55, 57, 59, 61, 63, 64, 66
			
exit:		.exit
