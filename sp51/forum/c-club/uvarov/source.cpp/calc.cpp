//	CALC.CPP - Sample calculator
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#include <ui_win.hpp>
#include "demo.hpp"
#define USE_RAW_KEYS

// Definition of the calculator class.
class CALCULATOR : public UIW_WINDOW
{
public:
	CALCULATOR(int left, int top, char *title);

private:
	UIW_NUMBER *numberField;
	double operand1;
	double operand2;
	int operatorLast;
	UCHAR operation;
	double decimal;
	double memory;

	static void ButtonFunction(void *button, UI_EVENT &event);
	void Display(UIW_BUTTON *button);
};

CALCULATOR::CALCULATOR(int left, int top, char *title) :
	UIW_WINDOW(left, top, 20, 11, WOF_NO_FLAGS, WOAF_NO_SIZE | WOAF_NORMAL_HOT_KEYS)
{
	UIW_BUTTON *mrButton;
	UIW_BUTTON *mmButton;
	UIW_BUTTON *mpButton;

	// Initialize the calculator values.
	operand1 = 0.0;
	operand2 = 0.0;
	operatorLast = TRUE;
	operation = '=';
	decimal = 0.0;
	memory = 0.0;

	// Create the number display field.
	numberField = new UIW_NUMBER(2, 1, 12, &operand2, NULL, NMF_COMMAS,
		WOF_BORDER | WOF_JUSTIFY_RIGHT | WOF_VIEW_ONLY | WOF_NO_ALLOCATE_DATA);

	// Add the buttons and other objects.
	*this
		+ new UIW_BORDER
		+ new UIW_MINIMIZE_BUTTON
		+ &(*new UIW_SYSTEM_BUTTON
			+ new UIW_POP_UP_ITEM("~Move", MNIF_MOVE, BTF_NO_TOGGLE, WOF_NO_FLAGS, 0)
			+ new UIW_POP_UP_ITEM("Mi~nimize", MNIF_MINIMIZE, BTF_NO_TOGGLE, WOF_NO_FLAGS, 0)
			+ new UIW_POP_UP_ITEM
			+ new UIW_POP_UP_ITEM("~Close", MNIF_CLOSE, BTF_NO_TOGGLE, WOF_NO_FLAGS, 0))
		+ new UIW_TITLE(title, WOF_JUSTIFY_CENTER)
		+ numberField
		+ new UIW_BUTTON(1, 3, 4, "~C", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ (mrButton = new UIW_BUTTON(5, 3, 4, "MR", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction))
		+ (mmButton = new UIW_BUTTON(9, 3, 4, "M-", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction))
		+ (mpButton = new UIW_BUTTON(13, 3, 4, "M+", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction))
		+ new UIW_BUTTON(1, 4, 4, "~7", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(5, 4, 4, "~8", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(9, 4, 4, "~9", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(13, 4, 4, "~/", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(1, 5, 4, "~4", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(5, 5, 4, "~5", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(9, 5, 4, "~6", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(13, 5, 4, "~-", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(1, 6, 4, "~1", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(5, 6, 4, "~2", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(9, 6, 4, "~3", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(13, 6, 4, "~*", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(1, 7, 4, "~.", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(5, 7, 4, "~0", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(9, 7, 4, "~=", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction)
		+ new UIW_BUTTON(13, 7, 4, "~+", BTF_NO_TOGGLE, WOF_JUSTIFY_CENTER, CALCULATOR::ButtonFunction);

	// Add hot keys to memory buttons.
	mrButton->hotKey = 'R';
	mmButton->hotKey = 'M';
	mpButton->hotKey = 'P';
}

#pragma argsused
void CALCULATOR::ButtonFunction(void *button, UI_EVENT &event)
{
	CALCULATOR *calculator = (CALCULATOR *)((UIW_BUTTON *)button)->parent;
	calculator->Display((UIW_BUTTON *)button);
}

void CALCULATOR::Display(UIW_BUTTON *button)
{
	// Switch on the button value.
	switch (button->hotKey)
	{

	// Clear the calculator.
	case 'C' :
		decimal =
			memory =
			operand1 =
			operand2 = 0.0;
		operation = '=';
		break;

	// Memory operations.
	case 'R' :
		decimal = 0.0;
		operatorLast = FALSE;
		operand1 = operand2;
		operand2 = memory;
		break;

	case 'M' :
		memory -= operand2;
		break;

	case 'P' :
		memory += operand2;
		break;

	// Operations.
	case '/' :
	case '*' :
	case '-' :
	case '+' :
	case '=' :
		if (operation != '=' && !operatorLast)
		{
			switch (operation)
			{
			case '/' :
				if (operand2 != 0.0)
					operand2 = operand1 / operand2;
				else
					operand2 = 1000000000.0;
				break;

			case '*' :
				operand2 *= operand1;
				break;

			case '-' :
				operand2 = operand1 - operand2;
				break;

			case '+' :
				operand2 += operand1;
				break;

			}
			operand1 = 0.0;
		}
		decimal = 0.0;
		operatorLast = TRUE;
		operation = button->hotKey;
		break;

	// Decimal placement.
	case '.' :
		if (operatorLast)
		{
			operatorLast = FALSE;
			operand1 = operand2;
			operand2 = 0.0;
		}
		if (decimal == 0.0)
			decimal = .1;
		break;

	// Digit pressed.
	default:
		if (operatorLast)
		{
			operatorLast = FALSE;
			operand1 = operand2;
			operand2 = 0.0;
		}
		if (decimal == 0.0 && operand2 < 100000000.0)
			operand2 = operand2 * 10 + button->hotKey - '0';
		else if (decimal > 0.0000001)
		{
			operand2 = operand2 + (button->hotKey - '0') * decimal;
			decimal /= 10.0;
		}
		break;
	}

	// Check for out of range numbers.
	if (operand2 >= 1000000000.0)
	{
		operand2 =
			operand1 = 0.0;
		operation = '=';
	}

	// Update the displayed number.
	numberField->DataSet(NULL);
}



UI_WINDOW_OBJECT *CONTROL_WINDOW::Window_Calculator(void)
{
	// Create a window in the screen center.
	int left = display->columns / display->cellWidth / 2 - 10;
	int top = display->lines / display->cellHeight / 2 - 5;
//	*windowManager + new
	CALCULATOR *calc=new CALCULATOR(left, top, "Calculator");
	// Return the window pointer.
	return ((UI_WINDOW_OBJECT *)calc);
}

