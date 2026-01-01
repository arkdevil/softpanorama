/****************************************************************************/
/*                                                                          */
/*      Data Encryption ToolKit. Version 1.3                                */
/*                                                                          */
/*      encrypt.h -- declare constants and functions for encrypt library    */
/*                                                                          */
/*      Copyright (c) 1991, 1992, Andrew Prokhorow. All rights reserved.    */
/*                                                                          */
/*      Purpose:                                                            */
/*        This file declares the encrypt library functions, define macros,  */
/*        and manifest constants that are used with them.                   */
/*                                                                          */
/****************************************************************************/


const int ENCRYPTION_KEY_SIZE = 8;
const int ENCRYPTION_KEY_MAX_NUMBER = 255;
const int ENCRYPTION_KEY_LENGTH = 9;
const int ENCRYPTION_KEY_MAX_LENGTH = 9 * 255;
const int ENCRYPTED_BLOCK_SIZE = 8;
const int ENCRYPTED_BLOCK_MAX_NUMBER = 4095;
const int ENCRYPTED_BLOCK_MAX_SIZE = 8 * 4095;
const int ENCRYPTED_FRAGMENT_MAX_NUMBER = 84;
const int ENCRYPTION_CONTROL_AREA_MAX_ID = 9;

#define ENCRYPTION_KEY_AREA_SIZE(NUMBER) ((NUMBER) * 128 + 8)

#ifdef __cplusplus
extern "C" {
#endif

void far cdecl init_encryption (void far *, const void far *, const int);
void far cdecl encrypt_block (const void far *, void far *);
void far cdecl encryption_key (void far *, const char far *);
void far cdecl decryption_key (void far *, const char far *);
int far cdecl encrypt_area (const void far *, void far *, const int,
  void far *, const int);
void far cdecl encrypt_program (const void far *, const int,
  const void far *);
void far cdecl decrypt_program (const void far *, const int,
  const void far *);
void far cdecl password_decrypt_program ();

#ifdef __cplusplus
}
#endif

#define self_encrypt_start (_psp + 16)

/*  Operation codes  */
const int ENCRYPT_NOCHAIN = 0;
const int DECRYPT_NOCHAIN = - 0;
const int ENCRYPT_CHAIN = 1;
const int DECRYPT_CHAIN = - 1;
const int ENCRYPT_AUTH = 2;
const int DECRYPT_AUTH = - 2;
const int ENCRYPT_LAST_AUTH = 3;
const int DECRYPT_LAST_AUTH = - 3;
const int ENCRYPT_FIRST_AUTH = 4;
const int DECRYPT_FIRST_AUTH = - 4;

/*  Return codes  */
const int NORMAL_ENCRYPTION = 0;
const int INVALID_ENCRYPT_PARAM = 1;
const int INVALID_ENCRYPT_AUTH = 2;

#define SIGNATURE_0 {'e', 'N', 'c', 'R', 'y', 'P', 't'}
#define SIGNATURE_1 {'e', 'N', 'C', 'r', 'y', 'P', 't'}
#define SIGNATURE_2 {'e', 'N', 'c', 'r', 'Y', 'P', 't'}
#define SIGNATURE_3 {'e', 'n', 'C', 'R', 'y', 'P', 't'}
#define SIGNATURE_4 {'e', 'N', 'c', 'R', 'Y', 'p', 't'}
#define SIGNATURE_5 {'e', 'n', 'C', 'r', 'Y', 'P', 't'}
#define SIGNATURE_6 {'e', 'N', 'C', 'r', 'Y', 'p', 't'}
#define SIGNATURE_7 {'e', 'n', 'c', 'R', 'Y', 'P', 't'}
#define SIGNATURE_8 {'e', 'N', 'C', 'R', 'y', 'p', 't'}
#define SIGNATURE_9 {'e', 'n', 'C', 'R', 'Y', 'p', 't'}

#define ENCRYPTION_CONTROL_AREA(ID,NUMBER)                              \
  static struct {                                                       \
    char search_pattern[7];                                             \
    char number;                                                        \
    char list[NUMBER][6];                                               \
    } ENCRYPTION_CONTROL_AREA_##ID = {SIGNATURE_##ID, (NUMBER) | 0x80}; \
  static void * encryption_control_area_##ID =                          \
    & ENCRYPTION_CONTROL_AREA_##ID;
