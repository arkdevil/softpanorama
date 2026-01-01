//	BIO.CPP - Biorhythms example.
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#include <ui_win.hpp>
#include "demo.hpp"
#include <graphics.h>

UI_PALETTE redPalette = { ' ', attrib(RED, YELLOW),
	attrib(MONO_BLACK, MONO_BLACK), SOLID_FILL, RED, YELLOW,
	BW_BLACK, BW_BLACK, GS_GRAY, GS_GRAY };
UI_PALETTE greenPalette = { ' ', attrib(GREEN, YELLOW),
	attrib(MONO_BLACK, MONO_BLACK), SOLID_FILL, GREEN, YELLOW,
	BW_BLACK, BW_BLACK, GS_GRAY, GS_GRAY };
UI_PALETTE bluePalette = { ' ', attrib(BLUE, YELLOW),
	attrib(MONO_BLACK, MONO_BLACK), SOLID_FILL, BLUE, YELLOW,
	BW_BLACK, BW_BLACK, GS_GRAY, GS_GRAY };
UI_PALETTE bioPalette = { ' ', attrib(BLACK, YELLOW),
	attrib(MONO_BLACK, MONO_BLACK), SOLID_FILL, BLACK, YELLOW,
	BW_BLACK, BW_BLACK, GS_GRAY, GS_GRAY };

// Definition of psuedoSin (used so that the floating point library is not needed).

// Definition of sin(x) function for sin(x * 2*pi / 23) * 10000.
const int pseudoSin23[] =
	{ 0, 2698, 5196, 7308, 8879, 9791, 9977, 9423, 8170, 6311,
	3984, 1362, -1362, -3984, -6311, -8170, -9423, -9977, -9791,
	-8879, -7308, -5196, -2698, 0 };

// Definition of sin(x) function for sin(x * 2*pi / 28) * 10000.
const int pseudoSin28[] =
	{ 0, 2225, 4339, 6235, 7818, 9010, 9749, 10000, 9749, 9010, 7818,
	6235, 4339, 2225, 0, -2225, -4339, -6235, -7818, -9010, -9749,
	-10000, -9749, -9010, -7818, -6235, -4339, -2225, 0 };

// Definition of sin(x) function for sin(x * 2*pi / 33) * 10000.
const int pseudoSin33[] =
	{ 0, 1893, 3717, 5406, 6901, 8146, 9096, 9718, 9989, 9898, 9450,
	8660, 7557, 6182, 4582, 2817, 951, -951, -2817, -4582, -6182,
	-7557, -8660, -9450, -9898, -9989, -9718, -9096, -8146, -6901,
	-5406, -3717, -1893, 0 } ;

// Class prototypes for BIORHYTHM and BIO_WINDOW.
class EXPORT BIORHYTHM : public UI_WINDOW_OBJECT
{
public:
	BIORHYTHM(void) :
		UI_WINDOW_OBJECT(0, 0, 0, 0, WOF_NON_FIELD_REGION, WOAF_NON_CURRENT),
		days(0) {}
	~BIORHYTHM(void) {}

	int Event(const UI_EVENT &event);
	void UpdateBiorhythm(void);
	long JulianDate(UIW_DATE *date);
	static int Validate(void *dateField, int ccode);

	UIW_DATE *birthDate;
	UIW_DATE *today;

private:
	long days;
};

class EXPORT BIO_WINDOW : public UIW_WINDOW
{
public:
	BIO_WINDOW(int left, int top, int width, int height);
	~BIO_WINDOW(void) {}

	static void Help(void *item, UI_EVENT &event);

	BIORHYTHM *biorhythm;
};

BIORHYTHM::Event(const UI_EVENT &event)
{
	// Translate the event into a logical event.
	int ccode = UI_WINDOW_OBJECT::LogicalEvent(event, ID_WINDOW_OBJECT);

	// Switch on the event.
	switch (ccode)
	{
	case S_CREATE:
	case S_SIZE:
		// Let the default event recalculate maximum size.
		UI_WINDOW_OBJECT::Event(event);

		// Decrease the size by 4 lines.
		true.top += display->cellHeight * 4;
		break;

	case S_CURRENT:
	case S_DISPLAY_ACTIVE:
	case S_DISPLAY_INACTIVE:
		// Redisplay the graph.
		days = JulianDate(today) - JulianDate(birthDate);
		UpdateBiorhythm();
		break;

	default:
		// Let the base class process all other events.
		ccode = UI_WINDOW_OBJECT::Event(event);
		break;
	}
	return (ccode);
	return event.type;
}

void BIORHYTHM::UpdateBiorhythm(void)
{
	// This member function displays the biorhythm information in the window.
	// As the size of the window object changes (by changing the parent window)
	// the size of the biorhythm chart also changes.  A horizontal change
	// results in a change in the number of days displayed.  A vertical change
	// results in a dynamic change in the height of the biorhythm curve.

	int x, y1, y2, y3;

	// Return if no display area.
	int width = display->cellWidth * 2;
	int maxDays = (true.right - true.left) / width;
	if (!maxDays || true.left >= true.right || true.top + 3 >= true.bottom)
		return;

	// Draw center line.
	int height = (true.bottom - true.top) * 7 / 16;
	int yCenter = true.top + (true.bottom - true.top) / 2;
	display->Rectangle(screenID, true, &bioPalette, 0, TRUE);
	display->Line(screenID, true.left, yCenter, true.right, yCenter, &bioPalette);

	// Draw current day line in the center.
	x = true.left + maxDays / 2 * width;
	display->Line(screenID, x, true.top, x, true.bottom, &bioPalette);

	// Find day offset to the left (center is today).
	long currentDay = days - maxDays / 2;
	x = true.left + width;
	while (currentDay < 0)
	{
		x += width;
		currentDay++;
	}

	// Draw the sin(x) curves for the different biorhythm curves.
	int lastY1 = (int)(yCenter - 1L * pseudoSin23[(int)(currentDay % 23)] * height /  10000L);
	int lastY2 = (int)(yCenter - 1L * pseudoSin28[(int)(currentDay % 28)] * height /  10000L);
	int lastY3 = (int)(yCenter - 1L * pseudoSin33[(int)(currentDay++ % 33)] * height /  10000L);
	int lastX = x - width;
	for (; x <= true.right; x += width)
	{
		y1 = (int)(yCenter - 1L * pseudoSin23[(int)(currentDay % 23)] * height /  10000L);
		y2 = (int)(yCenter - 1L * pseudoSin28[(int)(currentDay % 28)] * height /  10000L);
		y3 = (int)(yCenter - 1L * pseudoSin33[(int)(currentDay++ % 33)] * height /  10000L);
		display->Line(screenID, lastX, lastY1, x, y1, &redPalette);
		display->Line(screenID, lastX, lastY2, x, y2, &bluePalette);
		display->Line(screenID, lastX, lastY3, x, y3, &greenPalette);
		lastX = x;
		lastY1 = y1;
		lastY2 = y2;
		lastY3 = y3;
	}

	// Draw hash marks.
	for (x = true.left; x <= true.right; x += width)
		display->Line(screenID, x, yCenter - 1, x, yCenter + 1, &bioPalette);

	// Update legend if enough room.
	if ((true.right - true.left) > display->cellWidth * 10 && (true.bottom - true.top) > display->cellHeight * 4)
	{
		display->Text(screenID, true.left, true.top + display->cellHeight / 2, " Emotional", &redPalette, -1, FALSE);
		display->Text(screenID, true.left, true.top + display->cellHeight * 3 / 2, " Cognitive", &bluePalette, -1, FALSE);
		display->Text(screenID, true.left, true.top + display->cellHeight * 5 / 2, " Physical", &greenPalette, -1, FALSE);
	}
}

long BIORHYTHM::JulianDate(UIW_DATE *dateField)
{
	int year;
	int month;
	int day;

	// Get the year, month, and day.
	UI_DATE date = *dateField->DataGet();
	date.Export(&year, &month, &day);

	// A Julian Date is defined as 'a day count starting at 1200 UT on
	// 1 January -4713' by the U.S. Naval Observatory.  A date entered is
	// assumed to be after 1200 UTC.  This algorhythm is valid for any date
	// after Jan. 1, 1700 and accounts for all leap years (including
	// centessimal years and centessimal years divisible by 400).  This
	// algorithm (by Wayne Rust) is useful because it automatically
	// takes the number of days in each month into account and does not use
	// floating point arithmetic.
	//
	// The day of week can also be computed from this by finding
	// JulianDate % 7 + 1. (1 = Sun, 2 = Mon, etc.)
	year -= 1700 + (month < 3);
	return (365L * (year + (month < 3)) + year / 4 - year / 100 +
		(year + 100) / 400 + (305 * (month - 1) - (month > 2) * 20 +
		(month > 7) * 5 + 5) / 10 + day + 2341972L);
}

int BIORHYTHM::Validate(void *dateField, int ccode)
{
	// Validate only on exit from the field.
	if (ccode == S_NON_CURRENT)
	{
		// Compute the number of days between the two dates.
		BIORHYTHM *biorhythm = ((BIO_WINDOW *)((UIW_DATE *)dateField)->parent)->biorhythm;
		long tDays = biorhythm->days;
		biorhythm->days = biorhythm->JulianDate(biorhythm->today) - biorhythm->JulianDate(biorhythm->birthDate);
		if (biorhythm->days < 0)
		{
			// Report an error if the chart date is less than birth date.
			_errorSystem->ReportError(biorhythm->windowManager, -1,
				"Today's date must be greater than your birth date.");
			return(-1);
		}
		else if (tDays != biorhythm->days)
			// Update the display chart if the number of days has changed.
			biorhythm->UpdateBiorhythm();
	}

	return (0);
}


BIO_WINDOW::BIO_WINDOW(int left, int top, int width, int height) :
	UIW_WINDOW(left, top, width, height, WOF_NO_FLAGS, WOAF_NO_FLAGS)
{
	// Create biorhythm display object and date fields.
	biorhythm = new BIORHYTHM();
	biorhythm->birthDate = new UIW_DATE(15, 1, 20, &UI_DATE("1-1-50"),
		"1-1-1700..12-31-32767", DTF_ALPHA_MONTH, WOF_BORDER | WOF_NO_INVALID |
		WOF_NO_UNANSWERED | WOF_AUTO_CLEAR, BIORHYTHM::Validate);
	biorhythm->today = new UIW_DATE(15, 2, 20, &UI_DATE(),
		"1-1-1700..12-31-32767", DTF_ALPHA_MONTH, WOF_BORDER | WOF_NO_INVALID |
		WOF_NO_UNANSWERED | WOF_AUTO_CLEAR, BIORHYTHM::Validate);

	// Add all window objects to the window.
	*this
		+ new UIW_BORDER
		+ new UIW_MAXIMIZE_BUTTON
		+ new UIW_MINIMIZE_BUTTON
		+ UIW_SYSTEM_BUTTON::Generic()
		+ new UIW_TITLE("Biorhythm", WOF_JUSTIFY_CENTER)
		+ &(*new UIW_PULL_DOWN_MENU(0, WOF_NO_FLAGS, WOAF_NO_FLAGS)
			+ &(*new UIW_PULL_DOWN_ITEM(" ~Help ", MNF_NO_FLAGS)
				+ new UIW_POP_UP_ITEM("~General help", MNIF_NO_FLAGS, BTF_NO_TOGGLE, WOF_NO_FLAGS, BIO_WINDOW::Help)
				+ new UIW_POP_UP_ITEM("~History", MNIF_NO_FLAGS, BTF_NO_TOGGLE, WOF_NO_FLAGS, BIO_WINDOW::Help)
				+ new UIW_POP_UP_ITEM
				+ new UIW_POP_UP_ITEM("~About", MNIF_NO_FLAGS, BTF_NO_TOGGLE, WOF_NO_FLAGS, BIO_WINDOW::Help)))

		+ new UIW_PROMPT(1, 1, "~Birth date...", WOF_NO_FLAGS)
		+ biorhythm->birthDate
		+ new UIW_PROMPT(1, 2, "~Today...", WOF_NO_FLAGS)
		+ biorhythm->today
		+ biorhythm;
}

#pragma argsused
void BIO_WINDOW::Help(void *item, UI_EVENT &event)
{
/*
	// Find the particular help context.
	int helpContext;
	const char *string = ((UIW_POP_UP_ITEM *)item)->DataGet();
	switch(string[2])
	{
	case 'G':
		helpContext = HELP_GENERAL;
		break;

	case 'H':
		helpContext = HELP_HISTORY;
		break;

	case 'A':
		helpContext = HELP_ABOUT;
		break;
	}

	// Call the help system to display help.
	_helpSystem->DisplayHelp(((UIW_POP_UP_ITEM *)item)->windowManager, helpContext);
*/
}

UI_WINDOW_OBJECT *CONTROL_WINDOW::Window_Biorythm(void)
{
	// Add a biorhythm window to the center of the screen.
	int centerX = display->columns / display->cellWidth / 2;
	int centerY = display->lines / display->cellHeight / 2;
	BIO_WINDOW *bio= new BIO_WINDOW(centerX - 20, centerY - 6, 40, 12);
	// Return the window pointer.
	return ((UI_WINDOW_OBJECT *)bio);
}

