/****************************************************************************/
/*                                                                          */
/*      Data Encryption ToolKit. Version 1.3                                */
/*                                                                          */
/*      test5.c -- test module for DES module 5                             */
/*                                                                          */
/*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    */
/*                                                                          */
/*      Purpose:                                                            */
/*        Test password_decrypt_program function. File test5.exe must be    */
/*        encrypted from test to main and from test_value to incorrect      */
/*        by arbitrary key (password).                                      */
/*                                                                          */
/****************************************************************************/


#include <stdio.h>
#include "encrypt.h"

long test_value = 0;
char correct[] = "Password correct\n";
char incorrect[] = "Password incorrect\n";

void test () {
  printf (correct);
  }

int main () {
  password_decrypt_program ();
  if (test_value) {
    printf (incorrect);
    return 1;
    }
  test ();
  return 0;
  }
