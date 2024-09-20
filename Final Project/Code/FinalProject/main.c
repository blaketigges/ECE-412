/*
 * main.c
 *
 * Created: 3/21/2024 3:07:00 PM
 *  Author: coles
 */ 


 // Lab3P1.c
 //
 // 
 // Author : Eugene Rockey
 // 
 
 //no includes, no ASF, no libraries
 
 #include <math.h>
 #include "ftoa.h"
 #define F_CPU 8000000UL
 #include <util/delay.h>
 
 const char MS1[] = "\r\nECE-412 ATMega328PB Final";
 const char MS2[] = "\r\nJoystick!";
 const char MS3[] = "\rMenu: (A)DC\r";
 const char MS4[] = "\r\nReady: ";
 const char MS5[] = "\r\nInvalid Command Try Again...";

void UART_Init(void);
void UART_Clear(void);
void UART_Get(void);
void UART_Put(void);
void Mega328P_Init(void);
void ADC_Get_X(void);
void ADC_Get_Y(void);
void EEPROM_Read(void);
void EEPROM_Write(void);
void EEPROM_WriteAddress(char);
void EEPROM_WriteData(char);

unsigned char ASCII;			//shared I/O variable with Assembly
unsigned char DATA;				//shared internal variable with Assembly
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly
char EEPROM_Address;
char EEPROM_Data;
float r;
float b;
float r0;
float t0;
float t;
char temp_X[10];
char temp_Y[10];
char temp_Deg[10];

int acc_X;						//Accumulator for ADC use
int acc_Y;

void UART_Puts(const char *str)	//Display a string in the PC Terminal Program
{
	while (*str)
	{
		ASCII = *str++;
		UART_Put();
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

volatile uint8_t flag = 0; // Volatile to ensure proper access across interrupt handler
// Interrupt Service Routine (ISR) for INT0
ISR(INT0_vect) {
	flag = 1; // Set the flag when the interrupt is triggered
}
sei();
EICRA = 0b00000010; // Interrupt on falling edge
EIMSK = 0b00000001; // Enable INT0

void ftoa (float fp,char ch[]);
void ADC(void)						//Analog to Digital Converter for X-axis (Joystick configuration: Wire leads = North)
{
	UART_Puts("X:");
	ADC_Get_X();
	acc_X = ((((float)HADC) * 0x100 + (float)(LADC))-508.99968)*(-1);
	ftoa(acc_X, temp_X);
	UART_Puts(temp_X);
	
	UART_Puts(", Y:");
	ADC_Get_Y();
	acc_Y = ((((float)HADC) * 0x100 + (float)(LADC))-522.997766)*(-1);
	ftoa(acc_Y, temp_Y);
	UART_Puts(temp_Y);
	
	UART_Puts(", Degrees:");
	float a = sqrt(acc_Y*acc_Y);
	float b = sqrt(acc_X*acc_X);
	float c = sqrt((a*a) + (b*b));
	float rad = asin(a/c);
	float deg = rad*(180/3.14159265358979323846);
	if(deg < 0){
		deg += 360;
	}
	if(acc_X < 0 && acc_Y > 0){
		rad = acos(a/c);
		deg = rad*(180/3.14159265358979323846);
		deg += 90;
	}
	if(acc_X < 0 && acc_Y < 0){
		rad = asin(a/c);
		deg = rad*(180/3.14159265358979323846);
		deg += 180;
	}
	if(acc_X > 0 && acc_Y < 0){
		rad = asin(a/c);
		deg = rad*(180/3.14159265358979323846);
		deg += 270;
	}
	
	ftoa(deg, temp_Deg);
	
	UART_Puts(temp_Deg);
}

void Command(void)					//command interpreter
{
	UART_Puts("\r    ");
	ADC();
	for(int k = 0; k < 10000; k++){
		int x = 1 + 1;
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
