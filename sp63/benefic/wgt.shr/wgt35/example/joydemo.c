#include <wgtjoy.h>
#include <stdio.h>
#include <conio.h>

// Demonstrates how to detect, calibrate, and read from a joystick

joystick joy;

void main(void)
{
textmode(C80);
clrscr();
if (wcheckjoystick())
{
winitjoystick(&joy,0);	// init joystick 0 
printf("Calibrating joystick\n");
printf("\nHold joystick to the upper left corner and press fire:");
wcalibratejoystick(&joy);
printf("\nHold joystick to the lower right corner and press fire:");
wcalibratejoystick(&joy);
printf("\nJoystick calibrated. \n\nPress any key to stop.");

window(1,1,80,25);
do {
wreadjoystick(&joy);
gotoxy(1,12);
printf("X:%i   \nY:%i   \nButtons:%i",joy.x,joy.y,joy.buttons);
} while (!kbhit());
clrscr();
}
else printf("No joystick found");
}