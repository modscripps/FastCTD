//
//  main.m
//  FastCTD
//  May 4th, 2004: Put the code from "FASTCATCTD" written by ANSI-C
//  12/1/04: make the app can quit when the user press key 's'
//  Created by Mai Bui on Mon May 03 2004.
//  Copyright (c) 2004 __MPL-SIO-UCSD__. All rights reserved.
//

//#include <Cocoa/Cocoa.h>
#include <stdio.h>
#include <unistd.h>
#include "Globals.h"
#include "FileUtils.h"
#include "SerialPortUtils.h"
#include "FastCat_CTDdaq.h"
#include "PThreadUtils.h"
#include "CTD.h"
#include "PCode.h"
#include "Winch.h"
#include "UDPUtils.h"
#include "TCPIPUtils.h"
#include <sys/time.h>
/* try to have warning if have a style development -> not work
#ifdef MYAPP_DEVELSTYLE
warning "Danger, Mai!"
#endif
*/

int OpenSerialPort4AllSensors(FastCTDStructPtr FCTDPtr);

/*
** FUNCTION NAME: Usage()
** PURPOSE: a quick guide how to use app
** DATE: Mar 31, 2005
*/
void Usage()
{
	printf("Usage: fastCTD CTD 21 Pcode 22 Winch 23 f 8 d /Usr/CTDdataDirectory s 24 tcpPort 2342 statFishInW 1\n");
	printf("\t21: for keyspan box #2, port #1\n\tSize of data file = 8KB (default = 12KB)\n");
	printf("Note: all options for app are set in 'Setup' file");
}
/*
** FUNCTION NAME: CheckInput()
** PURPOSE: get options of user from the command line, overwrite options in "Setup" file
** DATE: Mar 31, 2005
*/
int CheckInput(int argc, const char* argv[], FastCTDStructPtr fctd)
{
	int i, val;
	int portnum = 0, baudrate;

	// Check the number of the argument, get the value of the serial port number to send data out.
	switch(argc)
	{
/*		case 1:
			printf("You need to input sensor's name following by its serial port number\n");
			Usage();
			return 0;
		break;
*/
		case 2:
		case 4:
		case 6:
		case 8:
		case 10:
		case 12:
		case 14:
		case 16:
		case 18:
			printf("INCOMPLETED INPUT!!!: Sensor's name following by its serial port number\n");
			printf(" or: Size file is not correct\n or: destfile is not exist\n or miss port# for write data out.\n");
			Usage();
			return 0;
		break;
		case 3:
		case 5:
		case 7:
		case 9:
		case 11:
		case 13:
		case 15:
		case 17:
		case 19:
		    for (i=1; i<argc; i++)
			{
				// CTD
				if (!strcmp(argv[i],"CTD"))
				{
					fctd->CTDFlag = true;
					portnum = atoi(argv[i+1]);
					if(1<=(portnum % 10)<=4)
						fctd->CTD.CTDPortnum = fctd->CTD.SerialPort4CTD.portnum = portnum;
					else
					{
						printf("WRONG CTD INPUT: Port number must be in range 11->14 or 21->24\n");
						return 0;
					}
					baudrate = atoi(argv[i+2]);
					fctd->CTD.SerialPort4CTD.speed = baudrate;
				}
				// display CTD data
				if (!strcmp(argv[i],"raw"))
				{
					fctd->CTD.printData = atoi(argv[i+1]);
				}

				// PCode
				if (argv[i][0]=='P')
				{
					fctd->PCodeFlag = true;
					portnum = atoi(argv[i+1]);
					if(1<=(portnum % 10)<=4)
						fctd->PCode.SerialPort4PCode.portnum = fctd->PCode.PCodePortnum = portnum;
					else
					{
						printf("WRONG PCode INPUT: Port number must be in range 11->14 or 21->24\n");
						Usage();
						return 0;
					}
					baudrate = atoi(argv[i+2]);
					fctd->PCode.SerialPort4PCode.speed = baudrate;
				}
				// Winch
				if (argv[i][0]=='W')
				{
					val = atoi(argv[i+1]);
					if (val)
						fctd->WinchFlag = true;
				}
				// TCP/IP socket
				if (!strcmp(argv[i],"tcpPort"))
				{
					portnum = atoi(argv[i+1]);
						fctd->Winch.TCPIPSocket.portnum = portnum;
				}
				// File's Size
				if (argv[i][0]=='f')
				{
					fctd->Ascii_dataFile.dataFileSize = atoi(argv[i+1]);
				}
				// File's destination
				if (argv[i][0]=='d')
				{
					sprintf(fctd->Ascii_dataFile.path,"%s/",argv[i+1]);
				}
				// File's name
				if (argv[i][0]=='n')
				{
					sprintf(fctd->Ascii_dataFile.runname,"%s",argv[i+1]);
				}
				// total of drops in file
				if (argv[i][0]=='t')
				{
					fctd->RecHeader.totalDrops = atoi(argv[i+1]);
				}
				// Write data via Serial port
				if (argv[i][0]=='s')
				{
					fctd->WriteDataViaSerialPortFlag = TRUE;
					portnum = atoi(argv[i+1]);
					if(1<=(portnum % 10)<=4)
						fctd->SerialPort4DataOut.portnum = portnum;
					else
					{
						printf("WRONG INPUT: Port number must be in range 11->14 or 21->24\n");
						Usage();
						return 0;
					}
				}
				// Write data to network (UDP broadcast)
				if (argv[i][0]=='i')
				{
					fctd->WriteData2NetworkFlag = TRUE;
					fctd->UDPSocket.portnum = atoi(argv[i+1]);
				}
				if (!strcmp(argv[i],"statFishInW"))
				{
					if (atoi(argv[i+1]) == 1)
					{
						fctd->dropnumBaseonWinch = TRUE;
						fctd->Winch.getStatusFish = TRUE;
					}	
					else fctd->CTD.getStatusFish = TRUE;
				}
			}
		break;
	}
	return 1;
}	// end of CheckInput()

/*
** FUNCTION NAME: InitApp(FastCTDStructPtr *FCTDPtr, char SPList[][MAXNAMELEN])
** PURPOSE: Initialize all parameters for FastCTD app.  Allocate main Fast CTD structure
** DESCRIPTION: Initialize all parameters for all sensors, find-open request serial ports and create data file
** DATE: Mar 31, 2005
*/
int	InitApp(FastCTDStructPtr *FCTDPtr, char SPList[][MAXNAMELEN])
{
    int i;
	int fd = -1;
	char timeStr[32] = "\0";
	char temp[TOTAL_SERIALPORT][MAXNAMELEN] = {"\0"};

	memcpy(SPList,temp,sizeof(temp));
	// for ASCII file
	if ((*FCTDPtr)->Ascii_dataFile.path[0]=='\0') strcpy((*FCTDPtr)->Ascii_dataFile.path,"/Users/Shared/");

	// Initialize CTD's data structure
	FastCTDInit(*FCTDPtr);

	// Open the aquired sensors's port
	OpenSerialPort4AllSensors(*FCTDPtr);

	// open UDP broadcast port if apply
	if ((*FCTDPtr)->WriteData2NetworkFlag)
	{
		InitUDP(&((*FCTDPtr)->UDPSocket.sockaddInfo));
		(*FCTDPtr)->UDPSocket.udpfd = u_openudp((*FCTDPtr)->UDPSocket.portnum);
	}

    
	// FCTD server opens TCP/IP connection for client (Winch)
	(*FCTDPtr)->Winch.TCPIPSocket.remoteSocketfd = -1;
	if ((*FCTDPtr)->WinchFlag)
	{
		if((fd = ServerStartListening((*FCTDPtr)->Winch.TCPIPSocket.portnum))==-1)
		{
			fprintf (stderr, "FCTD fails in listening.  error: %d / %s\n",
						 errno, strerror(errno));
			close (fd);
		}
		(*FCTDPtr)->Winch.TCPIPSocket.fdTCPIP = fd;
		printf("Success opentcp port, go to accept loop\n");
	}

	// Create data file - in ascii file for now
	if(CreateNewFile(&((*FCTDPtr)->Ascii_dataFile))==0){ 
		printf("Could not create the new file in Init\n");
		return 0;
	}
	// initialize the drop number of the file
	(*FCTDPtr)->dropnum4newfile = (*FCTDPtr)->Winch.dropNum;
	
	// get offset time for saving into data file later
	(*FCTDPtr)->offset_time = Get_Offset_Time(timeStr, 1);	
	
	return 1;
}


/*
** FUNCTION NAME: OpenSerialPort4AllSensors(FastCTDStructPtr FCTDPtr, char SPList[][MAXNAMELEN])
** PURPOSE: Open the one apply for sensors: CTD, PCode, data out via serial port (if apply)
** DATE: Mar 31, 2005
*/
int OpenSerialPort4AllSensors(FastCTDStructPtr FCTDPtr)
{
	int indx = 0;
	int portnum = 0;
	int boxnum = 0;
	// CTD install
	if (FCTDPtr->CTDFlag)
	{
		InitSerialPort(&FCTDPtr->CTD.SerialPort4CTD, FCTDPtr->CTD.CTDPortName);
		SetOptionSerialPort4FishCTD(&FCTDPtr->CTD);
		if ((OpenSerialPort(&((FCTDPtr)->CTD.SerialPort4CTD)))!=0)	// != 0 -> failed
			return EX_IOERR;
	}
	// PCode install
	if ((FCTDPtr)->PCodeFlag)
	{
        InitSerialPort(&FCTDPtr->PCode.SerialPort4PCode, FCTDPtr->PCode.PCodePortName);
        SetOptionSerialPort4PCode(&FCTDPtr->PCode);
        if ((OpenSerialPort(&((FCTDPtr)->PCode.SerialPort4PCode)))!=0)	// != 0 -> failed
            return EX_IOERR;
	}
	// Write data via serial port
	if ((FCTDPtr)->WriteDataViaSerialPortFlag)
	{
		InitSerialPort4Writting(&(FCTDPtr)->SerialPort4DataOut, FCTDPtr->SerialPort4DataOut.serialPortName);
		cfsetspeed(&(FCTDPtr)->SerialPort4DataOut.spOptions, FCTDPtr->SerialPort4DataOut.speed);	// 38400
		if ((OpenSerialPort((&(FCTDPtr)->SerialPort4DataOut)))!=0)	// != 0 -> failed
			return EX_IOERR;
	}
	return 1;
}

/*
** FUNCTION NAME: FreeAllMemory(FastCTDStructPtr FCTDPtr)
** PURPOSE: Clean memory: Close all serial port, TCP/IP port and deallocate FastCTD struct
** DATE: Mar 31, 2005
*/
int	FreeAllMemory(FastCTDStructPtr FCTDPtr)
{	
	// Close all files
	if (FCTDPtr->Ascii_dataFile.fd) SaveHeaderFile(FCTDPtr,2);
	CloseCurrFile(&FCTDPtr->Ascii_dataFile);

	// Close all serial ports
	// Close serial port getting CTD data
	if (FCTDPtr->CTDFlag)
	{
		if ((FCTDPtr->CTD.SerialPort4CTD.portnum)!=0){
			CloseSerialPort(&(FCTDPtr->CTD.SerialPort4CTD));
			printf("Close CTD port\n");}
	}
	// Close serial port getting PCode data
	if (FCTDPtr->PCodeFlag)
	{
		if ((FCTDPtr->PCode.SerialPort4PCode.portnum)!=0){
			CloseSerialPort(&(FCTDPtr->PCode.SerialPort4PCode));printf("Close PCode port\n");}
	}
	// Close serial port sending data out
	if (FCTDPtr->WriteDataViaSerialPortFlag)
	{
		if ((FCTDPtr->SerialPort4DataOut.portnum)!=0){
			CloseSerialPort(&(FCTDPtr->SerialPort4DataOut));printf("Close serial port for sending data\n");}
	}
	printf("All serial ports closed.\n");

	// close TCP/IP connection port
	if (FCTDPtr->Winch.TCPIPSocket.fdTCPIP)
		close (FCTDPtr->Winch.TCPIPSocket.fdTCPIP);

	// Free memory for FastCTDPtr
	if(FCTDPtr){ free(FCTDPtr); FCTDPtr = NULL;}

	return 1;
}

/*
** FUNCTION NAME: RunApp(FastCTDStructPtr FastCTDPtr, pthread_t ThList[])
** PURPOSE: Create all thread for FastCTD app
** DATE: Mar 31, 2005
*/
void RunApp(FastCTDStructPtr FastCTDPtr, pthread_t ThList[])
{
	// THREADS TASKS:  HAPPEN HERE ... *************************
	// Start background tasks that doo all the realtime work.
	// Each sensor has its own thread and one thread for write data to file, thread timeout control
	// one thread for checking stop command from user
	
	// Create all threads for CTD
	FastCTDCreateThreads(ThList, FastCTDPtr);
}

/*
** FUNCTION NAME: ReadSetupFile(FastCTDStructPtr FastCTDPtr)
** PURPOSE: Read Setup file to get all options before run FastCTD app
** DESCRIPTION:
**		1. Get the current working to get the whole path of the Setup file
**		2. Open the setup file
**		3. Read the setup file and parse them to get all options
** DATE: Mar 31, 2005
*/
int ReadSetupFile(FastCTDStructPtr FastCTDPtr)
{
	char confstr[MAX_LENGTH] = "\0";
	char* sep = "=, '";
	char *strPtr;
	int portnum = 0, baudrate = 0;
	int val = 0, total_line = 0;

	char cwd[256], pcwd[256], filename[1024], fname[] = "Setup", path[1024]="\0";
	char *cwdPtr;
	FILE *fp = NULL;
	
	strcpy(filename, FastCTDPtr->app_path);
	// Get the path of application
	GetPath(filename, path);

	// filename = application_path/fname
	sprintf(filename,"%s%s",path,fname);

	// open the Setup file
	if((fp = fopen(filename, "r"))==NULL)
	{
		fprintf(stderr,"Could not open file %s for reading: %d - %s\n",filename,errno, strerror(errno));
		  return 0;
	}

	// read options to the end of the file: ignore comment line (start with %) and empty line
	while(Filegets(confstr,sizeof(confstr),fp))
	{
		if (confstr[0]=='\0') break;	// the end of the file -> done
		total_line++;
		strPtr = strtok(confstr,sep);	// ignore space
		
		if (*strPtr=='%'||*strPtr=='\n')	// ignore % and empty line
			continue;

		// CTD
		if (!strcmp("CTD.CTDPortName",strPtr))	// CTD's serial port name
		{
			FastCTDPtr->CTDFlag = true;
			strPtr = strtok(NULL,sep);	// get the name of the serial port
			strcpy(FastCTDPtr->CTD.CTDPortName,strPtr);
		printf("CTD port name: %s\n",FastCTDPtr->CTD.CTDPortName);
		}
		if (!strcmp("CTD.speed",strPtr))	// CTD's baudrate
		{
			strPtr = strtok(NULL,sep);	// get number
			baudrate = atoi(strPtr);		// convert string to number
			FastCTDPtr->CTD.SerialPort4CTD.speed = baudrate;
		}
		if (!strcmp("CTD.printData",strPtr))	// diplay CTD data
		{
			strPtr = strtok(NULL,sep);	// get number
			val = atoi(strPtr);		// convert string to number
			FastCTDPtr->CTD.printData = val;
            FastCTDPtr->PCode.printData = val;  // set for PCode also - MNB Jun 21, 2011
            FastCTDPtr->Winch.printData = val;  // set for Winch also - MNB Jun 21, 2011
		}
		if (!strcmp("CTD.engDispRate",strPtr))	// get the rate for printing data in engineer mode
		{
			strPtr = strtok(NULL,sep);	// get number
			val = atoi(strPtr);		// convert string to number
            if (val > 16)
            {
                FastCTDPtr->CTD.engDispRate = 16;
            }
            else
            {
                if (val == 3) 
                    FastCTDPtr->CTD.engDispRate = 2;
                else if (val > 4 && val < 8) 
                    FastCTDPtr->CTD.engDispRate = 4;
                else if (val > 8 && val < 16) 
                    FastCTDPtr->CTD.engDispRate = 8;
                else
                   FastCTDPtr->CTD.engDispRate = val;
            }
 		}
		if (!strcmp("CTD.CTDlength",strPtr))	// length of CTD's string
		{
			strPtr = strtok(NULL,sep);	// get string's length
			FastCTDPtr->CTD.CTDlength = atoi(strPtr);
		}
		//JMK 17 April 05:  record the serial number...
		if (!strcmp("CTD.SerialNum",strPtr))	// length of CTD's string
		{
			strPtr = strtok(NULL,sep);	// get string's length
			strcpy(FastCTDPtr->CTD.SerialNum,strPtr);
		}
		// Winch
		if (!strcmp("TCPIPSocket.portnum",strPtr))	// port number for TCP/IP socket: communicate to winch
		{
			strPtr = strtok(NULL,sep);	// get port number in tring
			portnum = atoi(strPtr);     // convert string to number
			FastCTDPtr->Winch.TCPIPSocket.portnum = portnum;
		}
        
		// PCode set up
		if (!strcmp("PCode.PCodePortName",strPtr))	// PCode's serial port name
		{
			FastCTDPtr->PCodeFlag = true;
			strPtr = strtok(NULL,sep);	// get the name of the serial port
			strcpy(FastCTDPtr->PCode.PCodePortName,strPtr);
		printf("PCode port name: %s\n",FastCTDPtr->PCode.PCodePortName);
		}
		if (!strcmp("PCode.speed",strPtr))	// CTD's baudrate
		{
			strPtr = strtok(NULL,sep);	// get port number
			baudrate = atoi(strPtr);		// convert string to number
			FastCTDPtr->PCode.SerialPort4PCode.speed = baudrate;
		}
		// via TCP/IP socket
		if (!strcmp("TCPIP4Winch",strPtr))
		{
			FastCTDPtr->WinchFlag = true;
		}
		// if statFishInW = 1 -> base on the data from winch, otherwise, base on the pressure of the fish
		if (!strcmp("dropnumBaseonWinch",strPtr))
		{
			strPtr = strtok(NULL,sep);	// get the option for defining drop number
			if (atoi(strPtr) == 1){
				FastCTDPtr->dropnumBaseonWinch = TRUE;
				FastCTDPtr->Winch.getStatusFish = TRUE;
			}
			else FastCTDPtr->CTD.getStatusFish = TRUE;
		}

		// Options for data file
		if (!strcmp("RecHeader.totalDrops",strPtr))	// total drops in this file
		{
			strPtr = strtok(NULL,sep);	// get number of drops in data file
			FastCTDPtr->RecHeader.totalDrops = atoi(strPtr);
		}
		if (!strcmp("Ascii_dataFile.runname",strPtr))	// run name for data file
		{
			strPtr = strtok(NULL,sep);	// get the name of the data file
			strcpy(FastCTDPtr->Ascii_dataFile.runname,strPtr);
		}
		if (!strcmp("Ascii_dataFile.path",strPtr))	// directory of storing data file
		{
			strPtr = strtok(NULL,sep);	// get the name of the data file
			strcpy(FastCTDPtr->Ascii_dataFile.path,strPtr);
		}
		if (!strcmp("Ascii_dataFile.dataFileSize",strPtr))	
		{
			strPtr = strtok(NULL,sep);	// get the size of the data file
			FastCTDPtr->Ascii_dataFile.dataFileSize = atoi(strPtr);
		}
		if (!strcmp("SerialPort4DataOut.portnum",strPtr))	// Send data via serial port -> get port number
		{
			strPtr = strtok(NULL,sep);	// get the port number
			portnum = atoi(strPtr);
			if (portnum == 0)
				FastCTDPtr->WriteDataViaSerialPortFlag = FALSE;
			else
			{
				FastCTDPtr->WriteDataViaSerialPortFlag = TRUE;
				if(1<=(portnum % 10)<=4)
					FastCTDPtr->SerialPort4DataOut.portnum = portnum;
				else
				{
					printf("WRONG INPUT: Port number must be in range 11->14 or 21->24\n");
					return 0;
				}
			}
		}
		if (!strcmp("DataOut.speed",strPtr))	// CTD's baudrate
		{
			strPtr = strtok(NULL,sep);	// get port number
			baudrate = atoi(strPtr);		// convert string to number
			FastCTDPtr->SerialPort4DataOut.speed = baudrate;
		}
		if (!strcmp("UDPSocket.portnum",strPtr))	// Send data to network (UDP broadcast) -> get port number
		{
			strPtr = strtok(NULL,sep);	// get the port number
			portnum = atoi(strPtr);
			if (portnum == 0)
				FastCTDPtr->WriteData2NetworkFlag = FALSE;
			else
			{
				FastCTDPtr->WriteData2NetworkFlag = TRUE;
				FastCTDPtr->UDPSocket.portnum = portnum;
			}
		}
	}
	if (fp) {fclose(fp);fp = NULL;}

	return 1;
} // end of ReadSetupFile

/*
** FUNCTION NAME: GetInfo4SetupFile(FastCTDStructPtr FastCTDPtr, char* str)
** PURPOSE: Get value of all parameters from FastCTD struct to construct a string to write to "Setup" file
** DATE: Mar 31, 2005
*/
int GetInfo4SetupFile(FastCTDStructPtr FastCTDPtr, char* str)
{
	char cmm1[] = "%Format: '%': for comment out, \"name=1234\"\n";
	char cmm2[] = "%TCPIP port for send and receive data\n";
	char cmm3[] = "%SENSOR SETUP\n";
	char cmm4[] = "%Serial port for Fish and PCode\n";
	char cmm5[] = "%Install Winch or not\n";
	char cmm6[] = "%FILES\n";
	char cmm7[] = "%Display CTD data: 0=raw, 1=engineer format\n";
	char cmm8[] = "%Length of CTD data: 24 or 72 (has micro-cond)\n";

	char str1[32]="\0",str2[32]="\0",str3[32]="\0",str4[256]="\0",str5[256]="\0",str6[256]="\0",str7[256]="\0",str8[125]="\0",str9[125]="\0",str13[32]="\0";
	char str10[32] = "\0", str11[32] = "\0", str12[32] = "\0", str14[32] = "\0";
	ssize_t numBytesWr=0;
	char cmm = '%';

	sprintf(str1,"TCPIPSocket.portnum=%d\n",FastCTDPtr->Winch.TCPIPSocket.portnum);
	// CTD
	if(FastCTDPtr->CTDFlag) 
		sprintf(str2,"CTD.CTDPortName='%s'\n",FastCTDPtr->CTD.CTDPortName);
	else 
		sprintf(str2,"%cCTD.CTDPortName='USA49W1813P1.1'\n",cmm);
	sprintf(str12,"CTD.CTDlength=%d\n",FastCTDPtr->CTD.CTDlength);
	sprintf(str13,"CTD.printData=%d\n",FastCTDPtr->CTD.printData);
	// PCode
	if (FastCTDPtr->PCodeFlag) 
		sprintf(str3,"PCode.PCodePortName='%s'\n",FastCTDPtr->PCode.PCodePortName);
	else 
		sprintf(str3,"%cPCode.PCodePortName='USA49W1813P1.1'\n",cmm);
	// Winch
	if (FastCTDPtr->WinchFlag) 
		sprintf(str4,"TCPIP4Winch\n");
	else 
		sprintf(str4,"%cTCPIP4Winch\n",cmm);
	if (FastCTDPtr->dropnumBaseonWinch) 
		sprintf(str11,"dropnumBaseonWinch=1\n");
	else 
		sprintf(str11,"%cdropnumBaseonWinch=1\n",cmm);
	// Setup
	sprintf(str5,"RecHeader.totalDrops=%lu\n",FastCTDPtr->RecHeader.totalDrops);
	//JMK 16Apr05: Matlab doesn't like square brackets...
	sprintf(str6,"fpData0.runname='%s'\n",FastCTDPtr->Ascii_dataFile.runname);
	sprintf(str7,"fpData0.path='%s'\n",FastCTDPtr->Ascii_dataFile.path);
	sprintf(str10,"fpData0.dataFileSize=%ld\n",FastCTDPtr->Ascii_dataFile.dataFileSize);
	if (FastCTDPtr->WriteDataViaSerialPortFlag)
		sprintf(str8,"SerialPort4DataOut.serialPortName='%s'\n",FastCTDPtr->SerialPort4DataOut.serialPortName);
	else
		sprintf(str8,"SerialPort4DataOut.serialPortName='USA49W1813P1.1'\n");	
	if (FastCTDPtr->WriteData2NetworkFlag)
		sprintf(str9,"UDPSocket.portnum=%d",FastCTDPtr->UDPSocket.portnum);
	else
		sprintf(str9,"%cUDPSocket.portnum=%d",FastCTDPtr->UDPSocket.portnum,cmm);
	
	sprintf(str14,"CTD.SerialNum='%s'\n",FastCTDPtr->CTD.SerialNum);
	
	sprintf(str,"%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",cmm1,cmm2,str1,cmm3,str14,cmm7,str13,cmm4,str2,cmm8,str12,str3,cmm5,str4,str11,cmm6,str5,str6,str7,str10,str9);

    return 1;
}


/*
** FUNCTION NAME: SaveSetupFile(FastCTDStructPtr FastCTDPtr)
** PURPOSE: Get value of all parameters from FastCTD struct to construct a string to write to "Setup" file
** DATE: Mar 15, 2007
*/
int SaveSetupFile(FastCTDStructPtr FastCTDPtr)
{
    char str[2048] = "\0";
	char cwd[256], pcwd[256], filename[1024]="\0", fname[] = "Setup", path[1024]="\0";
	char *cwdPtr;
	//JMK 25 April 2005
	struct tm *timeptr;
	time_t thetime;
	FILE *fp = NULL;
	ssize_t numBytesWr=0;
	int total_line =0;
	
	//JMK 25 April 2005 Get time...
	time(&thetime);
	timeptr=gmtime(&thetime);

	// Get the whole path of the application.
	strcpy(filename, FastCTDPtr->app_path);
	// Discard the application name, only get the path of application
	GetPath(filename, path);

	// filename = application_path/fname
	sprintf(filename,"%s%s%04d%02d%02d%02d%02d",path,fname,timeptr->tm_year+1900,
	   timeptr->tm_mon+1,timeptr->tm_mday,timeptr->tm_hour,timeptr->tm_min);
	fprintf(stdout,"Setup file: %s\n",filename);

	if((fp = fopen(filename, "w"))==NULL)
	{
		fprintf(stderr,"Could not open file %s for writing: %d - %s\n",filename,errno, strerror(errno));
		  return 0;
	}

	if ((numBytesWr=ReadSetup_Write2File(FastCTDPtr,fp,str,&total_line))==0)
		fprintf(stderr,"ERROR! Failed to read setup and write into the file\n");

	if (fp) fclose(fp);

	return numBytesWr;
}// end of SaveSetupFile

int main(int argc, const char *argv[])
{
	pthread_t threadList[NUM_THREADS];
	FastCTDStructPtr FastCTDPtr = NULL;
	static char SerialPortListName[TOTAL_SERIALPORT][MAXNAMELEN] = {"\0"};
	char sfn[] = "Setup";
	FILE *fp = NULL;
	int fd = -1, filedes;
	char cwd[MAXPATHLEN] = "\0",path[MAXPATHLEN]="\0";
	char *cwdPtr;
	// TCP/IP
    int result;

	// INITIALIZE CTD STRUCTURE TO STORE SENSORS'S TYPE LATER *************************************
	FastCTDPtr = (FastCTDStruct*)malloc(sizeof(FastCTDStruct));
	if (FastCTDPtr == NULL)
		return 0;

	// Get the path of the application
	strcpy(FastCTDPtr->app_path,argv[0]);
	
	// GET APP's OPTION: from Setup file ****************************
	// Open the setup file and get all options and close
	ReadSetupFile(FastCTDPtr);

	// Get options from the user - in command line
	if(!CheckInput(argc,argv,FastCTDPtr))
	{
		// free memory for FastCTDPtr
		if(FastCTDPtr){ free(FastCTDPtr); FastCTDPtr = NULL;}
		return 1;
	}

	// INITIALIZATION *************************************
		if (InitApp(&FastCTDPtr, SerialPortListName)==0){
			if(FastCTDPtr){ free(FastCTDPtr); FastCTDPtr = NULL;}
			return 1;
		}

	// RUNNING LOOP *************************************
		RunApp(FastCTDPtr, threadList);
		FastCTDJoinThreads(threadList);

	// Save the setup file.   
	if (SaveSetupFile(FastCTDPtr)==0) fprintf(stderr,"Write nothing into setup file\n");

	// CLEANING ********************************* ... need to clean all threads
		FreeAllMemory(FastCTDPtr);

	return 0;
}
