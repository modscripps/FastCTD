#ifndef CTD_H
#define CTD_H

#include "SerialPortUtils.h"
#include "Globals.h"
#include "Utilities.h"
#include "FileUtils.h"
//#include "PThreadUtils.h"


#define AVG_WINDOWINPACKS 5	// 5 packet(string) of FishCTD's data for average.
#define CTD_LENGTH 72  // 6(T) + 6(C) + 6(P) + 4(temperature compensation) data + 40 chars + 8 checksum and  2(carriage return & line feed)
//#define CTD_LENGTH 24  // 6(T) + 6(C) + 6(P) + 4(temperature compensation) data and  2(carriage return & line feed)

typedef struct CTDCoeffStruct
{
	char serialnum[25];
	char tcalDate[25];
	float ta0;
	float ta1;
	float ta2;
	float ta3;
	char ccalDate[25];
	float cg;
	float ch;
	float ci;
	float cj;
	float ctcor;
	float cpcor;
	char pcalDate[25];
	float pa0;
	float pa1;
	float pa2;
	float ptca0;
	float ptca1;
	float ptca2;
	float ptcb0;
	float ptcb1;
	float ptcb2;
	float ptempa0;
	float ptempa1;
	float ptempa2;
}CTDCoeffStruct, *CTDCoeffStructPtr;

typedef struct FastCTDSetupStruct
{
	// later ... FastCTDApp version
	// later ... Time stamp
	CTDCoeffStruct CTDCoeff;
}FastCTDSetupStruct, *FastCTDSetupStructPtr;

typedef struct FishCTDdataStruct
{
	float temperature;
	float conductivity;
	float pressure;
	float depth;
}FishCTDdataStruct, *FishCTDdataStructPtr;

typedef struct FishCTDBuffStruct
{
	struct timeval UnixTime;
	unsigned long timeInHundredsecs;
	unsigned long dropNum;
	FishCTDdataStruct FishCTDdata;
	int FishIsDown;
	Boolean FishChangesCourse;
	char DataStr[MAX_LENGTH];
	Boolean ParseDone;
}FishCTDBuffStruct, *FishCTDBuffStructPtr;

typedef struct FishCTDpressAvgStruct
{
	long PressWindow[AVG_WINDOWINPACKS];
	long LastPressAvg;
	long CurrPressAvg;
	unsigned int CurrIndx;
	unsigned int LastIndx;
}FishCTDpressAvgStruct, *FishCTDpressAvgStructPtr;

typedef struct FishCTDStruct
{
	int CTDPortnum;
	char CTDPortName[32];
	int total_cal_line;
	Boolean CTDDone;
	int printData;	// 0: status, 1: engineer format, 2: debug
    int engDispRate;
	int CTDPhase;
	int CTDReqReadSize;
	SerialPortData SerialPort4CTD;
	FishCTDBuffStruct FishCTDCirBuff[MAX_CIRBUFF];
	FastCTDSetupStruct FastCTDSetup; // FastCTDSetup.
	unsigned int ParseIndx;
	unsigned int Write2BufferIndx;
	unsigned int ReadBufferIndx;
	unsigned int GetPressIndx;			
	int doneRead;
	unsigned long PackCnt;		// Read counter from serial port
	Boolean getStatusFish;
	unsigned long dropNum;
	FishCTDpressAvgStruct FishPressAvg;
//	char ParsingStr[CTD_LENGTH];	// contents data for parsing task
	char ParsingStr[255];	// contents data for parsing task
	int CTDlength;	// length of the CTD's string
	char SerialNum[32]; // JMK 17 April 05, New variable for CTD serial number....
}FishCTDStruct, *FishCTDStructPtr;

int AverageFishData(FishCTDStructPtr fishCTDPtr, unsigned long *avgTime, float *avgPress, float *avgDepth, float *avgTemp, float *avgCond);
float CalculateTemp(FishCTDStructPtr FishCTDPtr, long tempInHex);
float CalculateCond(FishCTDStructPtr FishCTDPtr, float, float, long condFreq);
float CalculatePress(FishCTDStructPtr FishCTDPtr, long pressTemp, long pressTempComp);
Boolean FishCTD_AcquireData(FishCTDStructPtr);
int InitFishCTD(FishCTDStructPtr);
//JMK 17 April 05: Added optional CalFileName argument
int GetFishCTDCal(CTDCoeffStructPtr,char *CalFileName);
int ParsingFishCTD(FishCTDStructPtr FishCTDPtr);
float Press2Meter(float pressInDecibars);
void *ReadFishCTDdataFromPort(void *arg);
int SetOptionSerialPort4FishCTD(FishCTDStructPtr);
void WriteFishCTDDataIntoBuffer(char *str, FishCTDStructPtr fishCTDPtr);

#endif