/*
 *  Winch.c
 *  FastCTD
 *
 *  Created by Mai Bui on 1/19/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "Winch.h"
#include "Globals.h"
 
static int WinchThread = 0;

/*
** FUNCTION NAME: InitWinch(WinchStructPtr WinchPtr)
** PURPOSE: Initialize some parameters in Winch's member structure.
** DATE: Mar 31, 2005
*/
int	InitWinch(WinchStructPtr WinchPtr)
{
	WinchPtr->WinchPhase = 1;
	WinchPtr->WinchDone = false;
	WinchPtr->WinchReqReadSize = 1;
	return 1;
}
enum WinchType{StatusStr,DownStr,UpStr};
int ParsingWinch(WinchStructPtr WinchPtr)
{
	char *strSep = "\0", *dataSep = ",\n";
	char *brks, *brkd;
	char *dataStr, *WinchData;
	char emptyStr[WINCH_MAXLEN] = "\0";
	char tempStr[WINCH_MAXLEN] = "\0";
	int i=0, j,k;
	enum WinchType Winchstr;
	float val, mlat, lat, mlon, lon;
	int dlat, dlon;
	float temp = 0.0;
	int indx;
	
	indx = WinchPtr->ParseIndx % MAX_CIRBUFF;
    if ((WinchPtr->WinchCirBuff[indx].newData) && (WinchPtr->ParseIndx < WinchPtr->Write2BufferIndx))
	{
		WinchPtr->WinchCirBuff[indx].newData = TRUE;
		strcpy(WinchPtr->ParsingStr,WinchPtr->WinchCirBuff[indx].DataStr);
		WinchPtr->ParseIndx++;
		for (WinchData = strtok_r(WinchPtr->ParsingStr, dataSep, &brkd); WinchData;WinchData=strtok_r(NULL,dataSep,&brkd))
		{
			if (!strcmp(WinchData,"$OPGWST"))
					Winchstr = StatusStr;
			if (!strcmp(WinchData,"$OPGWUP\r"))
					Winchstr = UpStr;
			if (!strcmp(WinchData,"$OPGWDN\r"))
			{
					Winchstr = DownStr;
			}
			if (Winchstr==StatusStr)
			{
			}
			if (Winchstr==UpStr)
			{
			}
			if (Winchstr==DownStr)	// not use this data for now.
			{
				WinchPtr->dropNum++;
					printf("DropNum = %lu\n",WinchPtr->dropNum);
			}
		}
	}
}
void *ReadWinchControl(void *arg)
{
	WinchStruct *WinchPtr;

	WinchPtr = (WinchStructPtr)arg;
		
	while(!WinchPtr->WinchDone)
	{
		if(WinchPtr->haveNewData)
		{
//			ParsingWinch(WinchPtr);
		}
	}	// end of while(!WinchPtr->WinchDone)

	printf("End of ReadWinchControl()\n");

	return NULL;
}

Boolean AcquireWinchDataTCPIP(WinchStructPtr WinchPtr)
{
	char	tstr[255] = "\0";
	char	emptstr[255] = "\0";
	int		result, indx, fd = -1, cnt = 0;
	struct timeval *timevPtr;
	struct timezone timez, *timezPtr;
	char *brks, *brkd;
	char *dataStr, *WinchData;
	char *strSep = "\n", *dataSep = ",\n";
	char*	buffPtr;	// Current char in buffer
	int FStatus = 0;
	static int lastFStatus = 0;
	int local = 1;
	char timeStr[125] = "\0";

    char tempStr[] = "$OPGWST,0,0,+   0.0,   0.0,   0,  0.00,   0.00,   0,       0,;";

    // initialize the buffer
 	memcpy(tstr,emptstr,sizeof(emptstr));
 if (WinchPtr->TCPIPSocket.remoteSocketfd == -1)
 {
 return 0;
 }
 else
 {
	result = read (WinchPtr->TCPIPSocket.remoteSocketfd, &tstr, sizeof(tstr));
	if (result == 0) {
		// EOF.
		printf ("Nothing comming\n");
		return FALSE;
	} 
	else if (result == -1) {
		fprintf (stderr, "could not read from remote socket.  "
				 "error %d / %s\n", errno, strerror(errno));
		return FALSE;
	}
	else
	{
        if (WinchPtr->printData == 2)
            printf("Get data from Winch: ");
        printf("%s\n",tstr);    

		// null-terminate the string and print it out
		tstr[result] = '\0';
		int i = 0;
       // to get the whole valid string: status or up or down
		for (WinchData = strtok_r(tstr, strSep, &brkd); WinchData; WinchData=strtok_r(NULL,strSep,&brkd))
		{
			indx = WinchPtr->Write2BufferIndx%MAX_CIRBUFF;

			// Get the current time and save it.
			timevPtr = &WinchPtr->WinchCirBuff[indx].UnixTime;
			timezPtr = &timez;
			gettimeofday(timevPtr, timezPtr);

			WinchPtr->WinchCirBuff[indx].timeInHundredsecs = Get_Time_In_Hundred_Secs(timeStr, local);

			// copy the Winchdata into buffer
			strncpy(WinchPtr->WinchCirBuff[indx].DataStr,WinchData,strlen(WinchData));
			// also copy this data into global comming string for comfirm having Winch data comming (use it in create file)
			strcpy(WinchPtr->CommingStr,WinchData);
			// increase the write index count
			WinchPtr->Write2BufferIndx++;
			WinchPtr->WinchCirBuff[indx].ParseDone = FALSE;
			cnt = 0;
			// define a drop number
          
			for (dataStr = strtok_r(WinchData, dataSep, &brkd); dataStr;dataStr=strtok_r(NULL,dataSep,&brkd))
			{
                if (WinchPtr->printData == 2)
                    printf("In Parsing: dataStr = %s\n",dataStr);
				if (cnt == 2)
				{
					lastFStatus = WinchPtr->WinchCirBuff[indx-1].FishStatus;
					FStatus = atoi(dataStr);
					switch(FStatus)
					{
					   case 0:
						   WinchPtr->WinchCirBuff[indx].FishStatus = 0;	// home
					   break;
					   case 1:
						   WinchPtr->WinchCirBuff[indx].FishStatus = 1;	// wait
					   break;
					   case 2:
						   WinchPtr->WinchCirBuff[indx].FishStatus = 2;	// going down
							if (lastFStatus == 3) // if last time is going up -> new drop beginning
							{
								WinchPtr->WinchCirBuff[indx].dropNum = WinchPtr->dropNum++;
								WinchPtr->WinchCirBuff[indx].FishChangesCourse = TRUE;
							}
							else	// otherwise, still save the current dropnumber into cir buffer
							{
								WinchPtr->WinchCirBuff[indx].dropNum = WinchPtr->dropNum; 
								WinchPtr->WinchCirBuff[indx].FishChangesCourse = FALSE;
							}
                           if (WinchPtr->printData == 2)
                               printf("Fish is going down = %d, last = %d, DropNum = %lu\n",WinchPtr->WinchCirBuff[indx].FishStatus,lastFStatus,WinchPtr->dropNum);

					   break;
					   case 3:
                            WinchPtr->WinchCirBuff[indx].FishStatus = 3;	// going up
                            if (WinchPtr->printData == 2)
                                printf("Fish is going up = %d, last = %d\n",WinchPtr->WinchCirBuff[indx].FishStatus,lastFStatus);
							if (lastFStatus == 2) // if last time is going down -> CTD changes course
								WinchPtr->WinchCirBuff[indx].FishChangesCourse = TRUE;
							else	// otherwise, continue going up
								WinchPtr->WinchCirBuff[indx].FishChangesCourse = FALSE;
					   break;
					}
				}
				cnt++;
			}

		}
		WinchPtr->PackCnt++;	// increase the Winch package count
		WinchPtr->haveNewData = 1;
	}
}	
	return TRUE;
}

// send average data to winch via network
Boolean SendData2Winch(WinchStructPtr WinchPtr, unsigned long CTDtime, float CTDpress,float CTDtemp, float CTDcond, float AltTime)
{
	int result;
	char dataSend[1014];
	int len;
	
    sprintf(dataSend, "%lu,%f,%f,%f,%f",CTDtime,CTDpress,CTDtemp,CTDcond,AltTime);

	// JMK 23 April 05: Print data out to screen so we know that things are running...
    if (WinchPtr->printData == 2){
        fprintf(stdout, "Send to Winch: %lu,%f,%f,%f,%f\n",CTDtime,CTDpress,CTDtemp,CTDcond,AltTime);
    }

	// 1. send the length of data to winch
	len = strlen(dataSend);
    // firsts, convert the native to Big-endian since the winch read as big-endian - MNB, MG Jun 7,2011
    len = CFSwapInt32HostToBig ((uint32_t) len);          
	// now, send
    result = write (WinchPtr->TCPIPSocket.remoteSocketfd, &len, sizeof(int));
	if (result==-1)
	{
		fprintf (stderr, "could not write data length to remote socket.  "
				 "error %d / %s\n", errno, strerror(errno));
		return FALSE;
	}
	
    // 2. send data to winch
	result = write (WinchPtr->TCPIPSocket.remoteSocketfd, &dataSend, strlen(dataSend));
	if (result==-1)
	{
		fprintf (stderr, "could not write data to remote socket.  "
				 "error %d / %s\n", errno, strerror(errno));
		return FALSE;
	}
    
    if (WinchPtr->printData == 2)
        printf("Send %d bytes to Winch: %s ",result,dataSend);
    printf("$OPGCTDE,CTDtime= %lu,p= %f, t=%f, c=%f, t=%f\n",CTDtime,CTDpress,CTDtemp,CTDcond,AltTime);
    printf("***** ------------------------------------------------------- *******\n\n");

    return TRUE;
}
