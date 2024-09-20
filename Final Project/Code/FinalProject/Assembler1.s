
/*
 * Assembler1.s
 *
 * Created: 3/21/2024 3:06:30 PM
 *  Author: coles
 */ 


  // Lab3P1.s
 //
 // 
 // Author : Eugene Rockey
 // Copyright 2022, All Rights Reserved


.section ".data"					//Declare this is for initializing data
.equ	DDRB,0x04					//Data Direction Register B
.equ	DDRD,0x0A					//Data Direction Register D
.equ	PORTB,0x05					//Port B Output Register
.equ	PORTD,0x0B					//Port D Output Register
.equ	U2X0,1						//Double Transmission Speed bit in UCSR0A register
.equ	UBRR0L,0xC4					//USART Baud Rate Register (Low)
.equ	UBRR0H,0xC5					//USART Baud Rate Register (High)
.equ	UCSR0A,0xC0					//USART Control and Status Register A 
.equ	UCSR0B,0xC1					//USART Control and Status Register B 
.equ	UCSR0C,0xC2					//USART Control and Status Register C 
.equ	UDR0,0xC6					//USART I/O Data Register 
.equ	RXC0,0x07					//USART Receive Complete Flag bit in UCSR0A
.equ	UDRE0,0x05					//USART Data Register Empty Flag bit in UCSR0A
.equ	ADCSRA,0x7A					//ADC Control and Status Register A
.equ	ADMUX,0x7C					//ADC Multiplexer Selection Register
.equ	ADCSRB,0x7B					//ADC Control and Status Register B
.equ	DIDR0,0x7E					//Digital Input Disable Register 0
.equ	DIDR1,0x7F					//Digital Input Disable Register 1
.equ	ADSC,6						//ADC Start Conversion bit in ADCSRA (Bit 6)
.equ	ADIF,4						//ADC Interrupt Flag bit in ADSCRA (Bit 4)
.equ	ADCL,0x78					//ADC Data Register Low
.equ	ADCH,0x79					//ADC Data Register High
.equ	EECR,0x1F					//EEPROM Control Register	
.equ	EEDR,0x20					//EEPROM Data Register, data to/from EEPROM
.equ	EEARL,0x21					//EEPROM Address Register (Low) 
.equ	EEARH,0x22					//EEPROM Address Register (High) 
.equ	EERE,0						//EEPROM Read Enable Bit (EECR 0)
.equ	EEPE,1						//EEPROM Write Enable Bit (EECR 1) 
.equ	EEMPE,2						//EEPROM Master Write Enable Bit (EECR 2)
.equ	EERIE,3						//EEPROM Ready Interrupt Enable Bit (EECR 3)

.global HADC			//High adc
.global LADC			//Low adc
.global ASCII			//ASCII for sending chars between c and asm
.global DATA			//Send data from LCD c func

.set	temp,0				//not used

.section ".text"			//Declare this is for code
.global Mega328P_Init
Mega328P_Init:
		//***********************************************
		//initialize PB0(R*W),PB1(RS),PB2(E) as fixed cleared outputs
		ldi		r16,0x07		//Load 0000 0111 into r16
		out		DDRB,r16		//Load r16 into DDRB setting PB0, PB1, and PB2 and out-puts
		ldi		r16,0			//Set r16 to 0
		out		PORTB,r16		//Use r16 to clear PORTB data
		//***********************************************
		//initialize UART, 8bits, no parity, 1 stop, 9600
		out		U2X0,r16		//Write r16(0) to U2X0
		ldi		r17,0x0			//r17 0
		ldi		r16,0x67		//r16 0110 0111 9600 baud
		sts		UBRR0H,r17		//Sets baud rate register to 103 
		sts		UBRR0L,r16		//
		ldi		r16,24			//0001 1000
		sts		UCSR0B,r16		//Enable USART reciever and transmitter
		ldi		r16,6			//0000 0110
		sts		UCSR0C,r16		//bit 7&6 enable Async USART, 5&4 no parity, 3 sets 1 stop bit, 				bit 2 from UCSR0B and bit 2&1 from here set 8 data bits (011)
		//************************************************
		//initialize ADC
		ldi		r16,0x87		//1000 0111
		sts		ADCSRA,r16		//ADC Enable, Division factor 128
//		ldi		r16,0x40		//0100 0000
//		sts		ADMUX,r16		//Aet ADV voltage ref to AV_cc, set input to ADC0
		ldi		r16,0			//0000 0000
		sts		ADCSRB,r16		//Sets ADC Auto Trigger source to free running mode
		ldi		r16,0xFE		//1111 1110
		sts		DIDR0,r16		//Disables digital input on pints 7-1
		ldi		r16,0xFF		//1111 1111
		sts		DIDR1,r16		//Disables digital input on AIN1 and AIN0
		//************************************************
		ret					//student comment here

.global UART_On
UART_On:
	ldi	r16,2					//0000 0010
	out	DDRD,r16				//Set pin as output
	ldi	r16,24					//0001 1000
	sts	UCSR0B,r16				//Enable reciever and transmitter
	ret

.global UART_Off
UART_Off:
	ldi	r16,0					//Clear 16
	sts UCSR0B,r16				//Disable reciever and transmitter
	ret	

.global UART_Clear
UART_Clear:
	lds		r16,UCSR0A			//Load control register a into r16
	sbrs	r16,RXC0			//Skip if recieve not complete
	ret							//Return if recieve complete
	lds		r16,UDR0			//load data register into udr0
	rjmp	UART_Clear			//Restart

.global UART_Get
UART_Get:
	lds		r16,UCSR0A			//Load USCROA into r16
	sbrs	r16,RXC0			//Skip next if RXCO is set (Recieve complete)
	rjmp	UART_Get			//Jump back if not done recieving
	lds		r16,UDR0			//Load uart data register 16
	sts		ASCII,r16			//Store r16 into ASCII var
	ret	

.global UART_Put
UART_Put:
	lds		r17,UCSR0A			//Load status register A into r17
	sbrs	r17,UDRE0			//Skip if data register not ready
	rjmp	UART_Put			//Restart if data register not ready
	lds		r16,ASCII			//Load input to r16
	sts		UDR0,r16			//write input to data register
	ret		

.global ADC_Get_X
ADC_Get_X:
		ldi		r16,0x40			//0100 0000
		sts		ADMUX,r16			//Aet ADV voltage ref to AV_cc, set input to ADC0
		ldi		r16,0xC7			//11000111
		sts		ADCSRA,r16			//Enable adc, start conversion, division factor 128
A2V1_X:	lds		r16,ADCSRA			//Load ADCSRA into r16
		sbrc	r16,ADSC			//Skip if start conversion bit is clear
		rjmp 	A2V1_X				//Jump if not clear (conversion not complete)
		lds		r16,ADCL			//Load ADC low register
		sts		LADC,r16			//put low register into low global var
		lds		r16,ADCH			//Load ADC high register
		sts		HADC,r16			//put high register into high global var
		ret

.global ADC_Get_Y
ADC_Get_Y:
		ldi		r16,0x41			//0100 0001
		sts		ADMUX,r16			//Aet ADV voltage ref to AV_cc, set input to ADC1
		ldi		r16,0xC7			//11000111
		sts		ADCSRA,r16			//Enable adc, start conversion, division factor 128
A2V1_Y:	lds		r16,ADCSRA			//Load ADCSRA into r16
		sbrc	r16,ADSC			//Skip if start conversion bit is clear
		rjmp 	A2V1_Y				//Jump if not clear (conversion not complete)
		lds		r16,ADCL			//Load ADC low register
		sts		LADC,r16			//put low register into low global var
		lds		r16,ADCH			//Load ADC high register
		sts		HADC,r16			//put high register into high global var
		ret