/*
* L2P3_C.c
* Example relationship between C and Assembly
* Created: 4:56:28 PM
* Author : Eugene Rockey
*/



//Compile and examine the .lss file beginning with main. Comment all the lines the compiler left empty.
int Global_A;
int Global_B = 1;
int Global_C = 2;
void main(void)
{
Global_A = Global_C / Global_B;
}


/*
//Compile and examine the .lss file beginning with main, comment all the lines the compiler left empty.
unsigned char Global_A;
unsigned char Global_B = 1;
unsigned char Global_C = 2;
void main(void)
{
Global_A = Global_C / Global_B;
}
*/
