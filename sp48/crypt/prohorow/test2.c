/****************************************************************************/
/*                                                                          */
/*      Data Encryption ToolKit. Version 1.3                                */
/*                                                                          */
/*      test2.c -- test module for DES module 2                             */
/*                                                                          */
/*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    */
/*                                                                          */
/*      Purpose:                                                            */
/*        Test encryption_key and decryption_key functions.                 */
/*                                                                          */
/****************************************************************************/


#include <stdio.h>
#include "encrypt.h"

int test_value[4] = {1, 2, 3, 4};
char key[] = "Prokhorow";
const int KEY_NUMBER = 1;
char key_area[ENCRYPTION_KEY_AREA_SIZE (KEY_NUMBER)];

void test_write () {
  for (int i = 0; i < 4; i ++)
    printf ("%i ", test_value[i]);
  printf ("\n");
  }

void main () {
  test_write ();
  encryption_key (key_area, key);
  encrypt_block (key_area, test_value);
  test_write ();
  decryption_key (key_area, key);
  encrypt_block (key_area, test_value);
  test_write ();
  }
