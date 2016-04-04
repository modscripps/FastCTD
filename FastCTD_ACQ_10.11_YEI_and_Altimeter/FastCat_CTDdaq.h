#ifndef FASTCAT_CTDDAG_H
#define FASTCAT_CTDDAG_H

//#include<stdlib.h>
//#include<stdio.h>
//#include <unistd.h>
//#include <fcntl.h>
//#include <errno.h>
//#include <paths.h>
//#include <termios.h>
//#include <sysexits.h>
//#include <sys/param.h>

//#include <CoreFoundation/CoreFoundation.h>

//#include <IOKit/IOKitLib.h>
//#include <IOKit/serial/IOSerialKeys.h>
//#include <IOKit/IOBSD.h>
//#include <mach/mach_init.h>
//#include <mach/thread_policy.h>
//#include <err.h>

#include "Globals.h"
#include "SerialPortUtils.h"
#include "FileUtils.h"
#include "CTD.h"
#include "PCode.h"
#include "Winch.h"
#include "UDPUtils.h"
#include "TCPIPUtils.h"

typedef struct RecHeaderStruct
{
	unsigned long seqnum;
	unsigned long startrunDropnum;
	unsigned long endrunDropnum;
	unsigned long totalDrops;
	unsigned long timestamp;
	unsigned long startrunSysTime;
	unsigned long startrunGPSTime;
	unsigned long endrunSysTime;
	unsigned long endrunGPSTime;
	float lat;
	float lon;
}RecHeaderStruct, *RecHeaderStructPtr;

typedef struct FastCTDstruct	//RuntimeStruct
{
	Boolean Done;
	Boolean NotFirstTime;
	Files Ascii_dataFile;	// raw and matfile
	Boolean WriteDataViaSerialPortFlag;
	Boolean WriteData2NetworkFlag;
	UDPStruct UDPSocket;
	SerialPortData SerialPort4DataOut;
	unsigned int totalByteSending;
	Boolean PCodeFlag;
	Boolean CTDFlag;
	Boolean WinchFlag;
	// All sensor: CTD, PCode
	FishCTDStruct CTD;
	PCodeStruct PCode;
	WinchStruct Winch;
	RecHeaderStruct RecHeader;
//	int hdsizeInLine;
	unsigned int header_file_size_bytes;
	Boolean dropnumBaseonWinch;	// 1: base on pressure of fish, 0: base on Winch's data
	unsigned long dropnum4newfile;
	char app_path[1024];
	time_t offset_time;	
}FastCTDStruct, *FastCTDStructPtr;


void FastCTDInit(FastCTDStructPtr fctd);
void WriteDataIntoBuffer(char*, FastCTDStructPtr);
int WriteDataIntoFile(const char *str, FastCTDStructPtr fctd);
ssize_t SaveHeaderFile(FastCTDStructPtr fctd,int head_tail);
int ReadSetup_Write2File(FastCTDStructPtr FastCTDPtr, FILE *fp_data, char *str,int *total_line);
int ReadFishCTDCal_Write2File(char* calFileName, FILE *fp_data, char* str,int *total_line);

#endif
