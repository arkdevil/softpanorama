/*
	BarClock(tm) Common Definitions

	Copyright (c) 1995  Patrick Breen
	All rights reserved.

	Atomic Dog Software
	PO Box 523
	Medford, MA 02155

	Phone (617) 396-2673
	Fax   (617) 396-5761

	Internet:			pbreen@world.std.com
	CompuServe: 		70312,743
	America Online: 	PBreen

	FTP:	 ftp.std.com	/vendors/AtomicDog
*/

#ifndef _BCCOMMON_H
#define _BCCOMMON_H

typedef enum {

	ePosLeft,
	ePosRight,
	ePosCnt

} Position;

typedef enum {

	eTmrCountDown,
	eTmrCountUp,
	eTmrCISStandard,
	eTmrCISAlternate,
	eTmrAOL,
	eTmrProdigy,

} TimerType;

typedef enum {

	eIncSecond,
	eIncMinute,
	eIncQtrHour,
	eIncHalfHour,
	eIncHour,

} TimerIncrement;

typedef enum {

	eDspTenths,
	eDspSeconds,
	eDspMinutes,

} TimerResolution;

typedef enum {

	eRepeatNone,
	eRepeatHour,
	eRepeatDay,
	eRepeatWeekday,
	eRepeatWeekend,
	eRepeatWeek,
	eRepeatBiweek,
	eRepeatMonth,
	eRepeatYear,

} RepeatType;

#endif