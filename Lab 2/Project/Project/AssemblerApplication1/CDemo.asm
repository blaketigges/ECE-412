/*unsigned char Global_A;
unsigned char Global_B = 1;
unsigned char Global_C = 2;
void main(void)
{
		Global_A = (Global_C^2) - Global_B;
}*/
			.dseg
			.org	0x100
Global_C:	.byte	1
Global_B:	.byte	1
Global_A:	.byte	1
			.cseg
			.org	0x0

			ldi r20,1
			ldi r21,2
			sts	0x0100,r21
			sts 0x0101,r20

main:		lds		r25, 0x0100	; 0x800100 <__DATA_REGION_ORIGIN__> Load global_c
			ldi		r24, 0x02	; 2 
			eor		r24, r25	; XOR between 2 or Global C
			lds		r25, 0x0101	; 0x800101 <Global_B> Load Global_B
			sub		r24, r25	; Subtract B from (C^2)
			sts		0x0102, r24	; 0x800102 <__data_end> Store r24 in global A
			ret	