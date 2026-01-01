/*
	testdoor.c - A sample door to demonstrate TriDoor
	Copyright (c) 1992 By Mark Goodwin

	Compile as follows:

	Borland C++    : bcc -ml testdoor.c bctdoor.lib
	Turbo C++      : tcc -ml testdoor.c tctdoor.lib
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include "tridoor.h"

#define TRUE 1
#define FALSE 0

void displaywelcome(void);
void playgame(void);

void main(void)
{
	TDInitialize();
	strcpy(TDDoorName, "TestDoor 1.0");
	randomize();
	displaywelcome();
	while (TRUE)
		playgame();
}

void displaywelcome(void)
{
	TDSetColor(WHITE, BLACK);
	TDClrScr();
	TDPrintf("TestDoor 1.0\n");
	TDSetColor(YELLOW, BLACK);
	TDPrintf("Copyright (c) 1992 By Mark Goodwin\n\n");
}

void playgame(void)
{
	int computernum, usernum, win, numguesses, input;
	char line[81];

	TDSetColor(LIGHTCYAN, BLACK);
	computernum = random(1000 + 1);
	win = FALSE;
	numguesses = 0;
	TDSetColor(LIGHTMAGENTA, BLACK);
	TDPrintf("The computer is thinking of a number from 1-1000!\n");
	do {
		numguesses++;
		TDSetColor(LIGHTGREEN, BLACK);
		TDPrintf("Enter a number from 1-1000 (0 to quit): ");
		TDSetColor(LIGHTRED, BLACK);
		TDGets(line);
		usernum = atoi(line);
		if (usernum < 0 || usernum > 1000) {
			TDSetColor(YELLOW, BLACK);
			TDPrintf("Number must be between 1 and 1000!!\n");
		}
		if (usernum) {
			if (computernum == usernum)
				win = TRUE;
			else {
				TDSetColor(YELLOW, BLACK);
				if (usernum > computernum)
					TDPrintf("   Too high!\n");
				else
					TDPrintf("   Too low!\n");
			}
		}
	} while (!win && usernum);
	TDSetColor(YELLOW, BLACK);
	if (win)
		TDPrintf("You got it in %d guesses\n", numguesses);
	TDPrintf("Play again (y/n)? ");
	do {
		input = toupper(TDGetch());
	} while (input != 'Y' && input != 'N');
	TDSetColor(LIGHTCYAN, BLACK);
	if (input =='N') {
		TDPrintf("No\n\n");
		exit(0);
	}
	TDPrintf("Yes\n\n\n");
}
