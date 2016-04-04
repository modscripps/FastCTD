/*
 *  Winch.h
 *  FastCTD
 *
 *  Created by Mai Bui on 1/19/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef WINCH_H
#define WINCH_H
#include <CoreFoundation/CoreFoundation.h>

#include "SerialPortUtils.h"
#include "TCPIPUtils.h"
#include "Utilities.h"

#define WINCH_MAXLEN 100

//#include <Carbon/Carbon.h>
typedef struct WinchBuffStruct
{
	struct timeval UnixTime;
	unsigned long timeInHundredsecs;
	char DataStr[MAX_LENGTH];
	int newData;
	Boolean ParseDone;
	int FishStatus;	// 0: home, 1: wait, 2: down, 3: up
	Boolean FishChangesCourse;
	unsigned long dropNum;
}WinchBuffStruct, *WinchBuffStructPtr;

typedef struct WinchStruct
{
	Boolean WinchDone;
	int WinchPhase;
	int WinchReqReadSize;
	int printData;	// use the same way of CTD:  0: status, 1: engineer format, 2: debug
	Boolean TCPIPdone;
	TCPSocketStruct TCPIPSocket;
	int charsIn;		// keep track number of bytes for each packet
	char CommingStr[WINCH_MAXLEN];	// contents one valid packet
	char ParsingStr[WINCH_MAXLEN];	// contents data for parsing task
	int ParseIndx;
	unsigned long dropNum;
	unsigned long lastDropNum;
	WinchBuffStruct WinchCirBuff[MAX_CIRBUFF];
	unsigned int Write2BufferIndx;
	unsigned int ReadBufferIndx;
	unsigned long PackCnt;
	int haveNewData;
	Boolean getStatusFish;
}WinchStruct, *WinchStructPtr;

Boolean AcquireWinchDataTCPIP(WinchStructPtr WinchPtr);
int	InitWinch(WinchStructPtr);
int ParsingWinch(WinchStructPtr);
void *ReadWinchControl(void *arg);
Boolean SendData2Winch(WinchStructPtr WinchPtr, unsigned long avgTime, float avgPress, float avgDepth, float avgTemp, float avgCond);

#endif