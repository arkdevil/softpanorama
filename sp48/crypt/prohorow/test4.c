/****************************************************************************/
/*                                                                          */
/*      Data Encryption ToolKit. Version 1.3                                */
/*                                                                          */
/*      test4.c -- test module for DES module 4                             */
/*                                                                          */
/*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    */
/*                                                                          */
/*      Purpose:                                                            */
/*        Test encrypt_program and decrypt_program functions. File          */
/*        test4.exe must be encrypted from test_value_1 to key and          */
/*        from test_value_2 to idle by "Prokhorow" key.                     */
/*                                                                          */
/****************************************************************************/


#include <stdio.h>
#include <dos.h>
#include "encrypt.h"

int test_value_1[5] = {1, 2, 3, 4, 5};
char key[] = "Prokhorow";
int test_value_2[5] = {6, 7, 8, 9, 10};
char idle = 0;
const int KEY_NUMBER = 1;
char key_area[ENCRYPTION_KEY_AREA_SIZE (KEY_NUMBER)];

ENCRYPTION_CONTROL_AREA (0, 3)

void test_write () {
  for (int i = 0; i < 5; i ++)
    printf ("%i ", test_value_1[i]);
  for (i = 0; i < 5; i ++)
    printf ("%i ", test_value_2[i]);
  printf ("\n");
  }

void main () {
  test_write ();
  decryption_key (key_area, key);
  decrypt_program (key_area, self_encrypt_start, encryption_control_area_0);
  test_write ();
  encryption_key (key_area, key);
  encrypt_program (key_area, self_encrypt_start, encryption_control_area_0);
  test_write ();
  }
