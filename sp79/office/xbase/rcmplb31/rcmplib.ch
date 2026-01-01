/***
*	RCmpLib.CH
*
*	Header file for the RCmpLib v3.1 CA-Clipper Library
*
*	Copyright (c) 1995  Rolf van Gelder, Eindhoven
*	All rights reserved
*
*	Revision date : 24/01/95
*/

*==========================================================================
*	Return codes for RCmpLib functions
*==========================================================================

#define	CP_OKAY			0	&& No errors detected
#define	CP_INVALID_PARM		1	&& Invalid parameter passed
#define	CP_OPEN_INPUT		2	&& Error opening  input  file
#define	CP_NOT_RCMPLIB		3	&& Not compressed by RCmpLib
#define	CP_WRONG_VERSION	4	&& Wrong version of RCmpLib
#define	CP_CREATE_OUTPUT	5	&& Error CREATING output file
#define	CP_READ_INPUT		6	&& Error READING  input  file
#define	CP_WRITE_OUTPUT		7	&& Error WRITING  output file
#define	CP_NO_FILES_FOUND	8	&& No files found to compress
#define	CP_USER_ABORT		9	&& Function aborted by user
#define	CP_NOT_COMPRESSED	10	&& String couldn't be compressed
#define	CP_WAS_COMPRESSED	11	&& String was already compressed
#define CP_ARCHIVE_CORRUPT	12	&& Archive is corrupt (v3.0b)

*==========================================================================
*	Array with pre-defined error messages
*==========================================================================
#define	CP_ERRMSG { ;
	"Invalid parameter(s) passed", ;
	"Error OPENING input file", ;
	"Not RCmpLib or protected w/password", ;
	"Wrong version of RCmpLib", ;
	"Error CREATING output file", ;
	"Error READING input file", ;
	"Error WRITING output file", ;
	"No files found to compress", ;
	"Function aborted by user", ;
	"String couldn't be compressed", ;
	"String was already compressed", ;
        "Archive is corrupt" }


*==========================================================================
*	R_CmpList() Subarray Structure
*==========================================================================
#define	CP_FNAME		1	&& Original file name
#define	CP_ORGSIZE		2	&& Original file size
#define	CP_ORGDATE		3	&& Original file date (dd-mm-yyyy)
#define	CP_ORGTIME		4	&& Original file time (hh:mm)
#define	CP_CMPSIZE		5	&& Compressed file size
#define	CP_RATIO		6	&& Compression ratio
#define	CP_VERSION		7	&& Version of RCmpLib


*==========================================================================
*	bRCmpBlk Return Codes (R_CmpFile() and R_DCmpFile())
*==========================================================================
#define	CP_ABORT		0	&& Abort    compression/decompression
#define	CP_CONT			1	&& Continue compression/decompression
*
* Eof RCmpLib.CH
