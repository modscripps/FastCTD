#ifndef CTD_H
#define CTD_H

#include "SerialPortUtils.h"
#include "Globals.h"
#include "Utilities.h"
#include "FileUtils.h"
//#include "PThreadUtils.h"


#define AVG_WINDOWINPACKS 5	// 5 packet(string) of FishCTD's data for average.

// SN removed this static predefined variable because we already changed to dynamic variable for CTD Length in setup file 2014 10 31 (Happy Halloween)
//#define CTD_LENGTH 72  // 6(T) + 6(C) + 6(P) + 4(temperature compensation) data + 40 chars + 8 checksum and  2(carriage return & line feed)
//#define CTD_LENGTH 24  // 6(T) + 6(C) + 6(P) + 4(temperature compensation) data and  2(carriage return & line feed)

//CTD data now has
// $OPGCTD TTTTTT CCCCCC PPPPPP TPTP MICRMICRMICRMICRMICRMICRMICRMICRMICRMICR GYROGYROGYRO ACCEACCEACCE COMPCOMPCOMP ALTI NCOUNTER \n\r
// (7)a    (6)b   (6)c   (6)d   (4)e (40)f                                    (12)g        (12)h        (12)i        (4)j (8)k     (2)l
// a: CTD string identifier (7 chars) [offset: 0]
// b: temperature (6 chars) [offset: 7]
// c: conductivity (6 chars)[offset: 13]
// d: pressure (6 chars) [offset: 19]
// e: temperature compensation (4 chars) [offset: 25]
// f: microconductivity (40 chars) (10 samples, 4char per sample)[offset: 29]
// g: gyro from YEI (12 chars) [offset: 69]
// h: acceleration from YEI (12 chars) [offset: 81]
// i: compass from YEI (12 chars) [offset: 93]
// j: altimeter (4 chars) [offset: 105]
// k: record counter (8 chars) [offset: 109]
// l: carriage and newline (2 chars) [offset: 117]
// CTD_LENGTH doesn't count the CTD string identifier

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
    float altTime;
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

int AverageFishData(FishCTDStructPtr fishCTDPtr, unsigned long *avgTime, float *avgPress,float *avgTemp, float *avgCond, float *avgAltTime);
// San Nguyen added on 2014 Oct 31
int CurrentFishData(FishCTDStructPtr fishCTDPtr, unsigned long *CTDtime, float *CTDpress, float *CTDtemp, float *CTDcond, float *AltTime);
float CalculateTemp(FishCTDStructPtr FishCTDPtr, long tempInHex);
float CalculateCond(FishCTDStructPtr FishCTDPtr, float, float, long condFreq);
float CalculatePress(FishCTDStructPtr FishCTDPtr, long pressTemp, long pressTempComp);
float CalculateSalt(float C,float T, float P);
float CalculateSoundVel(FishCTDStructPtr FishCTDPtr,float cond, float temp, float press);
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