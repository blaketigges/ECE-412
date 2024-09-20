/*
 * LCDPWM.c
 *
 * Created: 11/11/2018 12:18:09 PM
 * Author : Eugene Rockey Copyright 2018 All Rights Reserved
 * This is Lab 4 assistance code that you can port as YOUR original
 * pure AVR assembly code and use for Demo 4, but no code from LCDPWM.c listing file.
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
char dir = 1;

int main(void)
{
    DDRB |= 0x02;		//set PB1 as output to drive transistor driver.
	ICR1 = 2075;		//Counter TOP value so Frequency ~120HZ, see CLK pre-scaler
	TCNT1 = 0;			//Start the timer count from 0 in accordance with dir = 1.
	TCCR1A = 0x82;		//These configuration bits are key, research them... 10000010
						// Above Sets Fast PWM with TOP value set by ICR1 (mode 14), and Clear OC1A on compare match (set oc1a at bottom)
	TCCR1B = 0x1B;		//ditto! 00011011, WGM13 and WGM12 part of seting PWM mode above, also set clock source to  clock_i/o / 64
	TIMSK1 |= 0x02;		//Enable Timer 1 to generate interrupts.
	sei();				//Allow any source to interrupt the ATMega328PB CPU.
	while (1){}			//Do nothing infinitely, but it could be something productive,
						//and it will not interfere with the breathing LCD - HOORAY for
						//interrupts!
}

// OCR1A Controls duty cycle of PWM, controlling brightness
ISR(TIMER1_COMPA_vect)            //Timer 1 Interrupt Handler in C
{
	if (dir == 1 && OCR1A < 2075) //When dir = 1, the LCD gets brighter.
	{
		OCR1A += 5;				  //Instead of incrementing by 5 try 1,...
	}							  //2, 3, 4, 6, 7, 8, 9, or etc...
	else
	{
		dir = 0;				 //Switch direction to dimmer.
	}
	if (dir == 0 && OCR1A > 0)	//When dir = 0, the LCD is getting dimmer.
	{
		OCR1A -= 5;				//You could cause the LCD to get dimmer faster than...
	}							//than it gets brighter or vice-versa.
	else
	{
		dir = 1;				//Switch direction to brighter.
	}
}

