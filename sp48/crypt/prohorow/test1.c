/****************************************************************************/
/*                                                                          */
/*      Data Encryption ToolKit. Version 1.3                                */
/*                                                                          */
/*      test1.c -- test module for DES module 1                             */
/*                                                                          */
/*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    */
/*                                                                          */
/*      Purpose:                                                            */
/*        Test init_encryption and encrypt_block functions.                 */
/*                                                                          */
/****************************************************************************/


#include <stdio.h>
#include "encrypt.h"

int test_value[4] = {1, 2, 3, 4};
int key[4] = {100, 200, 300, 400};
const int KEY_NUMBER = 1;
char key_area[ENCRYPTION_KEY_AREA_SIZE (KEY_NUMBER)];

void test_write () {
  for (int i = 0; i < 4; i ++)
    printf ("%i ", test_value[i]);
  printf ("\n");
  }

void main () {
  test_write ();
  init_encryption (key_area, key, KEY_NUMBER);
  encrypt_block (key_area, test_value);
  test_write ();
  init_encryption (key_area, key, - KEY_NUMBER);
  encrypt_block (key_area, test_value);
  test_write ();
  }
