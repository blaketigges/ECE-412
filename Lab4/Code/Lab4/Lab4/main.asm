 ; Lab4
 ;

		 .org 0				;student discuss interrupts and vector table in report
		 jmp RESET			;student discuss in report
		 jmp INT0_H			;student discuss in report
		 jmp INT1_H			;student discuss in report
		 jmp PCINT0_H			;student discuss in report
		 jmp PCINT1_H			;student discuss in report
		 jmp PCINT2_H			;student discuss in report
		 jmp WDT			;student discuss in report
		 jmp TIM2_COMPA			;student discuss in report
		 jmp TIM2_COMPB			;student discuss in report
		 jmp TIM2_OVF			;student discuss in report
		 jmp TIM1_CAPT			;student discuss in report
		 jmp TIM1_COMPA			;student discuss in report
		 jmp TIM1_COMPB			;student discuss in report
		 jmp TIM1_OVF			;student discuss in report
		 jmp TIM0_COMPA			;student discuss in report
		 jmp TIM0_COMPB			;student discuss in report
		 jmp TIM0_OVF			;student discuss in report
		 jmp SPI_TC			;student discuss in report
		 jmp USART_RXC			;student discuss in report
		 jmp USART_UDRE			;student discuss in report
		 jmp USART_TXC			;student discuss in report
		 jmp ADCC			;student discuss in report
		 jmp EE_READY			;student discuss in report
		 jmp ANA_COMP			;student discuss in report
		 jmp TWI			;student discuss in report
		 jmp SPM_READY			;student discuss in report



RESET:	;Initialize the ATMega328P chip for the THIS embedded application.
		;initialize PORTB for Output
		cli
		ldi	r16,0x02			;PB1 or OC1A Output
		out	DDRB,r16
		ldi		r20,1			;Use r20 as dir, dir = 1
								;initialize and start Timer A, compare match, interrupt enabled
		ldi r17,8
		sts ICR1H,r17
		ldi r16,0x1B	
		sts ICR1L,r16			; Set ICR to 2075
		ldi	r16,0x82			;set OC to compare match set output to high level
		sts TCCR1A,r16			;store r16 value (11000000) into register TCCR1A (TC1 Control Register A, which sets OC1A on compare match and sets output to high)
		ldi r16,0x1B			;set clock prescaler
		sts TCCR1B,r16			;store r16 value (00000100) into register TCCR1B (TC1 Control Register B, which sets the clock prescalar clkI/O/256)
		ldi	r18,0x00			;load immediate value 0x0B into register r18
		ldi r17,0x00			;load immediate value 0xB8 into register r17
		lds r16,TCNT1L			;load TCNT1L (TC1 Counter Value Low byte) register value into register r16
		lds r16,TCNT1H			;load TCNT1H (TC1 Counter Value High byte) register value into register r16
		ldi r16,0
		sts OCR1AH,r16			;store r16 value into OCR1AH (Output Compare Register 1 A High byte) register
		sts OCR1AL,r16			;store r16 value into OCR1AL (Output Compare Register 1 A Low byte) register
		ldi r19,0				;loads immediate value 0 into register r19
		ldi r16,0x02			;loads immediate value 0x02 into register r16
		sts TIMSK1,r16			;store 0x02 into TIMSK1 register (Timer/Counter 1 Interrupt Mask Register, enable output compare A interrupt)
		sei						;enable global interrupts
here:	rjmp here
		
INT0_H:
		nop			;external interrupt 0 handler
		reti
INT1_H:
		nop			;external interrupt 1 handler
		reti
PCINT0_H:
		nop			;pin change interrupt 0 handler
		reti
PCINT1_H:
		nop			;pin change interrupt 1 handler
		reti
PCINT2_H:
		nop			;pin change interrupt 2 handler
		reti
WDT:
		nop			;watch dog time out handler
		reti
TIM2_COMPA:
		nop			;TC 2 compare match A handler
		reti
TIM2_COMPB:
		nop			;TC 2 compare match B handler
		reti
TIM2_OVF:
		nop			;TC 2 overflow handler
		reti
TIM1_CAPT:
		nop			;TC 1 capture event handler
		reti
TIM1_COMPA:			;TC 1 compare match A handler
		cli
LDOCR:	lds		ZL,OCR1AL
		lds		ZH,OCR1AH
IF:		cpi		r20,1	 ;if (dir == 1 && 
		breq	AND2
		jmp		ELSE
AND2:	cpi		ZL,0x1B  ;OCR1AH < 0x1B) sets carry if ZL larger than 27, cleared otherwise
		sbci	ZH,0x08	 ; Sets carry if 08 + prev carry is greater than ZH
		brcc	ELSE
THEN:	lds		ZL,OCR1AL
		lds		ZH,OCR1AH
		adiw	ZH:ZL,5		;Load then increment OCR1A
		sts		OCR1AH,ZH
		sts		OCR1AL,ZL
		jmp		ENDIF
ELSE:	ldi		r20,0		;dir = 0
		lds		ZL,OCR1AL
		lds		ZH,OCR1AH
ENDIF:	nop

dIF:	ori		r20,0 ;if (dir == 0 && 
		breq	dAND1
		jmp		dELSE
dAND1:	cpi		ZL,0  ;OCR1AL > 0)
		brge	dAND2
		jmp		dELSE
dAND2:	cpi		ZH,0  ;OCR1AH > 0)
		brge	dTHEN
		jmp		dELSE
dTHEN:	sbiw	ZH:ZL,5	
		sts		OCR1AH,ZH
		sts		OCR1AL,ZL
		jmp		dENDIF
dELSE:	ldi		r20,1		;dir = 1
dENDIF:	nop
		sei
		reti

TIM1_COMPB:
		nop			;TC 1 compare match B handler
		reti
TIM1_OVF:
		nop			;TC 1 overflow handler
		reti
TIM0_COMPA:
		nop			;TC 0 compare match A handler
		reti
TIM0_COMPB:			
		nop			;TC 1 compare match B handler
		reti
TIM0_OVF:
		nop			;TC 0 overflow handler
		reti
SPI_TC:
		nop			;SPI Transfer Complete
		reti
USART_RXC:
		nop			;USART receive complete
		reti
USART_UDRE:
		nop			;USART data register empty
		reti
USART_TXC:
		nop			;USART transmit complete
		reti
ADCC:
		nop			;ADC conversion complete
		reti
EE_READY:
		nop			;EEPROM ready
		reti
ANA_COMP:
		nop			;Analog Comparison complete 
		reti
TWI:
		nop			;I2C interrupt handler
		reti
SPM_READY:
		nop			;store program memory ready handler
		reti		

