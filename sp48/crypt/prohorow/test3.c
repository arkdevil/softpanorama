/****************************************************************************/
/*                                                                          */
/*      Data Encryption ToolKit. Version 1.3                                */
/*                                                                          */
/*      test3.c -- test module for DES module 3                             */
/*                                                                          */
/*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    */
/*                                                                          */
/*      Purpose:                                                            */
/*        Test encrypt_area function.                                       */
/*                                                                          */
/****************************************************************************/


#include <stdio.h>
#include "encrypt.h"

int test_value[16];
int add_value[4];
int ret_code;
char key[] = "Prokhorow";
const int KEY_NUMBER = 1;
char key_area[ENCRYPTION_KEY_AREA_SIZE (KEY_NUMBER)];

void test_init () {
  ret_code = 0;
  for (int i = 0; i < 16; i ++)
    test_value[i] = i + 1;
  }

void add_init () {
  for (int i = 0; i < 4; i ++)
    add_value[i] = (i + 1) * 100;
  }

void test_write () {
  printf ("%i : ", ret_code);
  for (int i = 0; i < 16; i ++)
    printf ("%i ", test_value[i]);
  printf (" / ");
  for (i = 0; i < 4; i ++)
    printf ("%i ", add_value[i]);
  printf ("\n");
  }

void main () {

  test_init ();
  add_init ();
  test_write ();
  encryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, ENCRYPT_NOCHAIN);
  test_write ();
  decryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, DECRYPT_NOCHAIN);
  test_write ();

  test_init ();
  add_init ();
  test_write ();
  encryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, ENCRYPT_CHAIN);
  test_write ();
  add_init ();
  decryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, DECRYPT_CHAIN);
  test_write ();

  test_init ();
  add_init ();
  test_write ();
  encryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, ENCRYPT_AUTH);
  test_write ();
  decryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, DECRYPT_AUTH);
  test_write ();

  test_init ();
  add_init ();
  test_write ();
  encryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, ENCRYPT_AUTH);
  test_write ();
  add_init ();
  decryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, DECRYPT_AUTH);
  test_write ();

  test_init ();
  add_init ();
  test_write ();
  encryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, ENCRYPT_LAST_AUTH);
  test_write ();
  decryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, DECRYPT_LAST_AUTH);
  test_write ();

  test_init ();
  add_init ();
  test_write ();
  encryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, ENCRYPT_FIRST_AUTH);
  test_write ();
  decryption_key (key_area, key);
  ret_code =
    encrypt_area (key_area, test_value, 4, add_value, DECRYPT_FIRST_AUTH);
  test_write ();

  }
