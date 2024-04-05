
 // Lab3P1.c
 //
 // 
 // Author : Eugene Rockey
 // 
 
 //no includes, no ASF, no libraries
#define F_CPU 8000000UL
#include <util/delay.h>
#include "ftoa.h"
 
 const char MS1[] = "\r\nECE-412 ATMega328PB Tiny OS";
 const char MS2[] = "\r\nby Eugene Rockey Copyright 2022, All Rights Reserved";
 const char MS3[] = "\r\nMenu: (L)CD, (A)DC, (E)EPROM, (U)USART\r\n";
 const char MS4[] = "\r\nReady: ";
 const char MS5[] = "\r\nInvalid Command Try Again...";
 const char MS6[] = "Volts\r";
 
 

void LCD_Init(void);			//external Assembly functions
void UART_Init(void);
void UART_Clear(void);
void UART_Get(void);
void UART_Get_noloop(void);
void UART_SET_INTR(void);
void UART_Gets(void);
void UART_Put(void);
void LCD_Write_Data(void);
void LCD_Write_Command(void);
void LCD_Read_Data(void);
void Mega328P_Init(void);
void ADC_Get(void);
void EEPROM_Read(void);
void EEPROM_Write(void);
void Config_USART(void);

unsigned char ASCII;			//shared I/O variable with Assembly
unsigned char DATA;				//shared internal variable with Assembly
unsigned int EEPWRITE;
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly

char volts[5];					//string buffer for ADC output
int Acc;						//Accumulator for ADC use

void UART_Puts(const char *str)	//Display a string in the PC Terminal Program
{
	while (*str)
	{
		ASCII = *str++;
		UART_Put();
	}
}

int Fib(int n)
{
	if (n <= 1)
		return 1;
	else
		return Fib(n - 1) + Fib(n - 2);
}

void LCD_Puts(const char *str)	//Display a string on the LCD Module
{
	while (*str)
	{
		DATA = *str++;				// Go to next char in string
		LCD_Write_Data();			// Write that char to screen
	}
	ASCII = '\0';
	while (1) {
		if(ASCII != '\0')
		{
			UART_Put();				// Print char that caused it to break
			break;
		}
		Fib(25);					// Delay shifting
		
		DATA = 0x18;				// 0b00001100, Shift right 1
		LCD_Write_Command();
		UART_Get_noloop();
	}
}


void Banner(void)				//Display Tiny OS Banner on Terminal
{
	UART_Puts(MS1);
	UART_Puts(MS2);
	UART_Puts(MS4);
}

void HELP(void)						//Display available Tiny OS Commands on Terminal
{
	UART_Puts(MS3);
}

void LCD(void)						//Lite LCD demo
{
	
	DATA = 0x01;					// 0b00000001, Clears display
	LCD_Write_Command();
	DATA = 0x34;					// 0b00110100, Set data bus to 8 bit, 1 line, and font to 5x10
	LCD_Write_Command();
	DATA = 0x08;					// 0b00001000, Set display cursor and brink off?
	LCD_Write_Command();
	DATA = 0x02;					// 0b00000010, Return cursor to 0
	LCD_Write_Command();
	DATA = 0x06;					// 0b00000110, Set cursor shift to increment, and display to not shifted
	LCD_Write_Command();
	DATA = 0x0d;					// 0b00001111, Set display on, cursor on, brink on.
	LCD_Write_Command();
	LCD_Puts("Hello ECE412!    Hello ECE412!    Hello ECE412!    Hello ECE412!");
	/*
	Re-engineer this subroutine to have the LCD endlessly scroll a marquee sign of 
	your Team's name either vertically or horizontally. Any key press should stop
	the scrolling and return execution to the command line in Terminal. User must
	always be able to return to command line.
	*/
}

char temp[50];
void ftoa (float fp,char ch[]);
void ADC(void)                        //Lite Demo of the Analog to Digital Converter
{
	for (int i= 0; i < 20; i++)
	{
		ADC_Get();
		Acc = (((float)HADC) * 0x100 + (float)(LADC));
		float r0 = 10000.0;                                    //r0 constant
		float t0 = 298.15;                                    //t0 constant
		float b = 3950.0;                                    //b constant
		float r;
		float t;
		r = 10000.0 * Acc / (1024.0 - Acc);
		t = b * t0 / (t0 * log(r/r0) + b);
		t = t - 273.15;
		t = t * 9.0/5.0 + 32.0;
		ftoa(t, temp);
		
		UART_Puts(temp);
		UART_Puts("\r");
		_delay_ms(500);
	}
    
    /*
        Re-engineer this subroutine to display temperature in degrees Fahrenheit on the Terminal.
        The potentiometer simulates a thermistor, its varying resistance simulates the
        varying resistance of a thermistor as it is heated and cooled. See the thermistor
        equations in the lab 3 folder. User must always be able to return to command line.
    */
}

void EEPRead()
{
	UART_Puts("\r\nEnter address to read: (1-9)\r\n");
	UART_Get();
	EEPWRITE = ASCII - '0'; // Convert ASCII input into int for address
	EEPROM_Read();
	UART_Put();
}

void EEPWrite()
{
	UART_Puts("\r\nEnter address to write: (1-9)");
	UART_Get();
	EEPWRITE = ASCII - '0'; // Convert ASCII input into int for address
	UART_Puts("\r\nEnter char to write:");
	UART_Get();
	EEPROM_Write();
}

void EEPROM(void)
{
	UART_Puts("\r\nEEPROM Write and Read.");
	/*
	Re-engineer this subroutine so that a byte of data can be written to any address in EEPROM
	during run-time via the command line and the same byte of data can be read back and verified after the power to
	the Xplained Mini board has been cycled. Ask the user to enter a valid EEPROM address and an
	8-bit data value. Utilize the following two given Assembly based drivers to communicate with the EEPROM. You
	may modify the EEPROM drivers as needed. User must be able to always return to command line.
	*/
	UART_Puts("\r\nWrite(W) or Read(R)?");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case 'W' | 'w': EEPWrite();
		break;
		case 'R' | 'r': EEPRead();
		break;
		UART_Puts(MS5);
		UART_Puts("\r\nWrite(W) or Read(R)?");
		break;
	}
	//EEPROM_Write();
	//UART_Puts("\r\n");
	//EEPROM_Read();
	//UART_Put();
	//UART_Puts("\r\n");
}

void USART(void)
{
	Config_USART();
}


void Command(void)					//command interpreter
{
	UART_Puts(MS3);
	ASCII = '\0';						
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case 'L' | 'l': LCD();
		break;
		case 'A' | 'a': ADC();
		break;
		case 'E' | 'e': EEPROM();
		break;
		case 'U' | 'u': USART();
		break;
		default:
		UART_Puts(MS5);
		HELP();
		break;  			
//Add a 'USART' command and subroutine to allow the user to reconfigure the 						
//serial port parameters during runtime. Modify baud rate, # of data bits, parity, 							
//# of stop bits.
	}
}

int main(void)
{
	Mega328P_Init();
	Banner();
	while (1)
	{
		Command();				//infinite command loop
	}
}

