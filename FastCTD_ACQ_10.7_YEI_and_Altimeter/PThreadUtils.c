#include "PThreadUtils.h"

// Globals for PThreadUtils
int TotalThreads = 0;
static int LastFishIsDown = 0;	 
/*
** FUNCTION NAME: FastCTDCreateThreads(pthread_t* threadList, FastCTDStructPtr fctd)
** PURPOSE: Create all threads for CTD, PCode, Winch, write data into file, checking communication and stop application
** DATE: Mar 31, 2005
*/
void FastCTDCreateThreads(pthread_t* threadList, FastCTDStructPtr fctd)
{
	int thnum = 0, terr=0;

	// Fish CTD
	if (fctd->CTDFlag&&!fctd->Done)
	{
		printf("Acquire CTD data ...\n");
		terr = pthread_create(&threadList[thnum],NULL,ReadFishCTDdataFromPort,(void*)&(fctd->CTD));
		thnum++;
	}
	// PCode
	if (fctd->PCodeFlag&&!fctd->Done)
	{
		printf("Acquire PCode data ...\n");
		terr = pthread_create(&threadList[thnum],NULL,ReadPCodeDataFromPort,(void*)&(fctd->PCode));
		thnum++;
	}
	// Winch
	if (fctd->WinchFlag&&!fctd->Done)
	{
		printf("Acquire Winch data ...\n");
		terr = pthread_create(&threadList[thnum],NULL,TCPIPSocketServer,(void*)fctd);
		thnum++;
	}
	// Write data into a file
	terr = pthread_create(&threadList[thnum],NULL,WriteCTDdataIntoFile,(void*)fctd);
	thnum++;
	// Checking for lost communication
	terr = pthread_create(&threadList[thnum],NULL,CheckDataIsBlocked,(void*)fctd);
	thnum++;
	// Stop app from the user
	terr = pthread_create(&threadList[thnum],NULL,StopFastCTD,(void*)fctd);
	thnum++;
	
	TotalThreads = thnum;
}

/*
** FUNCTION NAME: FastCTDJoinThreads(pthread_t threadList[])
** PURPOSE: Join all threads.
** DATE: Mar 31, 2005
*/
void FastCTDJoinThreads(pthread_t threadList[])
{
	int thnum = 0, terr = 0;
	for (thnum = 0; thnum< TotalThreads; thnum++)
	{
		terr = pthread_join(threadList[thnum],NULL);    
		if (terr)
		{
			printf("ERROR! Join a thread #%d.\n", thnum);
			abort();
		}
	}
}

// copy from /usrs/include/mach/thread_policy.h since it's commented out in that file
kern_return_t   thread_policy_set(thread_act_t thread,thread_policy_flavor_t flavor, thread_policy_t policy_info, mach_msg_type_number_t count);

int set_realtime(int period, int computation, int constraint) {

    struct thread_time_constraint_policy ttcpolicy;
    int ret;

    ttcpolicy.period=period; // HZ/160
    ttcpolicy.computation=computation; // HZ/3300;
    ttcpolicy.constraint=constraint; // HZ/2200;
    ttcpolicy.preemptible=0;

    if ((ret=thread_policy_set(mach_thread_self(),
        THREAD_TIME_CONSTRAINT_POLICY, (int *)&ttcpolicy,
        THREAD_TIME_CONSTRAINT_POLICY_COUNT)) != KERN_SUCCESS) {
            fprintf(stderr, "set_realtime() failed.\n");
            return 0;
    }
    return 1;
}


/*
** FUNCTION NAME: StopFastCTD(void *arg)
** PURPOSE: Stop app when user type 's'
** DATE: Mar 31, 2005
*/
void *StopFastCTD(void *arg)
{
	char gc;
	FastCTDStruct *fCTDPtr = (FastCTDStructPtr)arg;
	while(!fCTDPtr->Done)
	{
		gc = getchar();
 
		if (gc=='q' || gc=='s') 
		{
			fprintf(stdout, "Quitting FastCTD DAQ.\n");
 
			fCTDPtr->Done = TRUE;
			if(fCTDPtr->CTDFlag) {fCTDPtr->CTD.CTDDone = TRUE;RealeaseSPRead(&fCTDPtr->CTD.SerialPort4CTD);}
			if(fCTDPtr->PCodeFlag){fCTDPtr->PCode.PCodeDone = TRUE;RealeaseSPRead(&fCTDPtr->PCode.SerialPort4PCode);}
			if(fCTDPtr->WinchFlag){fCTDPtr->Winch.WinchDone = TRUE;}
			if(fCTDPtr->Winch.TCPIPSocket.fdTCPIP) close(fCTDPtr->Winch.TCPIPSocket.fdTCPIP);	// to terminate accept()
		}
	}
}

/*
** FUNCTION NAME: TCPIPSocketServer(void *arg)
** PURPOSE: Waiting for client (Winch), when has connection acquire Winch data and send Fish CTD's data to Winch.
** DATE: Mar 31, 2005
*/
void *TCPIPSocketServer(void *arg)
{
	int result, val;
	struct sockaddr_in address;
	socklen_t addressLength = sizeof(address);
    float CTDpress = 0, CTDcond = 0;
    float CTDtemp = 0, AltTime = 0.0;
    unsigned long CTDtime =0;

	FastCTDStruct *fCTDPtr = (FastCTDStructPtr)arg;
    
	while(!fCTDPtr->Done)
	{
		// waiting for Winch asking connection
		printf("Waiting for Winch's request to accept connection...\n");
		if(fCTDPtr->Winch.TCPIPSocket.fdTCPIP!=-1)
		{
			result = accept (fCTDPtr->Winch.TCPIPSocket.fdTCPIP, (struct sockaddr *)&address, &addressLength);
			if (result == -1) {
	            fprintf (stderr, "accept failed.  error: %d / %s\n",
                     errno, strerror(errno));
				// if stop program, it will not wait for another connection.
				if (fCTDPtr->Done) {printf("TCPThread is terminated by user\n");break;}
				else continue;
			}
			if (result == EWOULDBLOCK)
			{	printf("break in WOULDBLOCK\n");
				break;
			}
			printf ("accepted connection from %s:%d\n",inet_ntoa(address.sin_addr), ntohs(address.sin_port));
            
			// copy socketfd into Winch structure for receiving data
			fCTDPtr->Winch.TCPIPSocket.remoteSocketfd = result;
		}
		// after making a pine connection to Winch, aquire data, average FishCTD's data and send to winch.
		while (!fCTDPtr->Done)
		{
			// if get data from winch
			if (!AcquireWinchDataTCPIP(&fCTDPtr->Winch)) break;
            // fish's data and send them to winch.
            val = CurrentFishData(&(fCTDPtr->CTD), &CTDtime, &CTDpress, &CTDtemp, &CTDcond,&AltTime);
            
            if (!SendData2Winch(&fCTDPtr->Winch, CTDtime, CTDpress, CTDtemp, CTDcond,  AltTime))
            {
                break;
            }
		}
        // close the connection
		if(fCTDPtr->Winch.TCPIPSocket.remoteSocketfd>0){ close (fCTDPtr->Winch.TCPIPSocket.remoteSocketfd);
            fCTDPtr->Winch.TCPIPSocket.remoteSocketfd = -1;
        }
	}
}

/*
** FUNCTION NAME: WriteCTDdataIntoFile(void *arg)
** PURPOSE: Write CTD data from circular buffer into data file
** DATE: Mar 31, 2005
*/
void *WriteCTDdataIntoFile(void *arg)
{
	int indx = 0;
	int serialPortIndx = 0;
	char PCodeDataStr[MAX_LENGTH] = "\0";
	char FCTDdataStr[MAX_LENGTH] = "\0";
	char WinchDataStr[MAX_LENGTH] = "\0";
	char timeChar = 'T';
	char dataChar = '$';
	ssize_t numbytes = 0;
	unsigned long htime = 0;

	FastCTDStruct *fCTDPtr = (FastCTDStructPtr)arg;

	while(!fCTDPtr->Done)
	{
		// save the header info into file: only the first time run, next time is taken care by "WriteDataIntoFile()"
		if (!fCTDPtr->NotFirstTime)
		{
			SaveHeaderFile(fCTDPtr,1);
			fCTDPtr->NotFirstTime = TRUE;
		}
		// if CTD is installed: write the CTD's data into file
		if (fCTDPtr->CTDFlag&&!fCTDPtr->CTD.CTDDone)
		{
			// get index in cir buffer
			indx = fCTDPtr->CTD.ReadBufferIndx%MAX_CIRBUFF;
			if (fCTDPtr->CTD.ReadBufferIndx < fCTDPtr->CTD.Write2BufferIndx && fCTDPtr->CTD.FishCTDCirBuff[indx].ParseDone)
			{
				// If the new drop is base on the pressure of the CTD
				if (fCTDPtr->dropnumBaseonWinch==0)
				{
					// get the Fish's status and write to the file
					if(fCTDPtr->CTD.FishCTDCirBuff[indx].FishChangesCourse)
					{
						if (fCTDPtr->CTD.FishCTDCirBuff[indx].FishIsDown==1)	// start to go down for the new drop
						{
							sprintf(FCTDdataStr,"%c%010lu$OPGFDN\r\n",timeChar, fCTDPtr->CTD.FishCTDCirBuff[indx].timeInHundredsecs);
							fCTDPtr->CTD.FishCTDCirBuff[indx].dropNum = fCTDPtr->CTD.dropNum++;
						}
						else // start to go up
						{
							sprintf(FCTDdataStr,"%c%010lu$OPGFUP\r\n",timeChar, fCTDPtr->CTD.FishCTDCirBuff[indx].timeInHundredsecs);
							fCTDPtr->CTD.FishCTDCirBuff[indx].dropNum = fCTDPtr->CTD.dropNum;
						}
						WriteDataIntoFile(FCTDdataStr, fCTDPtr);
					}
					LastFishIsDown = fCTDPtr->CTD.FishCTDCirBuff[indx].FishIsDown;
				}
				// write the data of the CTD into the file
				// contruct the string: T+timestamp+PcodeData
				sprintf(FCTDdataStr,"%c%010lu%s",timeChar, fCTDPtr->CTD.FishCTDCirBuff[indx].timeInHundredsecs, fCTDPtr->CTD.FishCTDCirBuff[indx].DataStr);
				WriteDataIntoFile(FCTDdataStr, fCTDPtr);

				// if data is sending out via serialport
				if (fCTDPtr->WriteDataViaSerialPortFlag)
					if((fCTDPtr->totalByteSending+=WriteData(fCTDPtr->SerialPort4DataOut.spd, FCTDdataStr))==0)
						printf("Can not send CTD to the serial port\n");

				// if data is sending out to network by UDP broadcast
				if (fCTDPtr->WriteData2NetworkFlag)
					if((numbytes = u_sendto(fCTDPtr->UDPSocket.udpfd,FCTDdataStr,strlen(FCTDdataStr),&fCTDPtr->UDPSocket.sockaddInfo))==-1)
						printf("Can not send CTD out via network\n");

				fCTDPtr->CTD.SerialPort4CTD.ReadBufferIndx++;
				fCTDPtr->CTD.ReadBufferIndx++;
			}
		}
		// if PCode is installed: write the PCode's data into file
		if (fCTDPtr->PCodeFlag&&!fCTDPtr->PCode.PCodeDone)
		{
			if (fCTDPtr->PCode.SerialPort4PCode.ReadBufferIndx < fCTDPtr->PCode.SerialPort4PCode.Write2BufferIndx)
			{
				indx = fCTDPtr->PCode.SerialPort4PCode.ReadBufferIndx%MAX_CIRBUFF;
				// contruct the string: T+timestamp+PcodeData
				sprintf(PCodeDataStr,"%c%010lu%s",timeChar,
							fCTDPtr->PCode.SerialPort4PCode.SerialDataCirBuff[indx].timeInHundredsecs,
							fCTDPtr->PCode.SerialPort4PCode.SerialDataCirBuff[indx].DataStr);
				WriteDataIntoFile(PCodeDataStr, fCTDPtr);
				// if data is sending out via serialport
				if (fCTDPtr->WriteDataViaSerialPortFlag)
					if((fCTDPtr->totalByteSending+=WriteData(fCTDPtr->SerialPort4DataOut.spd, PCodeDataStr))==0)
						printf("Can not send PCode to the serial port\n");
				// if data is sending out to network by UDP broadcast
				if (fCTDPtr->WriteData2NetworkFlag)
					if((numbytes = u_sendto(fCTDPtr->UDPSocket.udpfd,PCodeDataStr,strlen(PCodeDataStr),&fCTDPtr->UDPSocket.sockaddInfo))==-1)
						printf("Can not send CTD out via network\n");
				fCTDPtr->PCode.SerialPort4PCode.ReadBufferIndx++;
			}
		}
		// if Winch is installed: write the Winch's data into file
		if (fCTDPtr->WinchFlag&&!fCTDPtr->Winch.WinchDone)
		{
			if (fCTDPtr->Winch.ReadBufferIndx < fCTDPtr->Winch.Write2BufferIndx)
			{
				indx = fCTDPtr->Winch.ReadBufferIndx%MAX_CIRBUFF;

				// If the new drop is base on the Winch, write the status of the CTD into the file
				if (fCTDPtr->dropnumBaseonWinch==1)
				{
					// get the Fish's status and write to the file
					if(fCTDPtr->Winch.WinchCirBuff[indx].FishChangesCourse)
					{
						if (fCTDPtr->Winch.WinchCirBuff[indx].FishStatus==2)	// start to go down for the new drop
						{
							sprintf(WinchDataStr,"%c%010lu$OPGFDN\r\n",timeChar, fCTDPtr->Winch.WinchCirBuff[indx].timeInHundredsecs);
						}
						else if (fCTDPtr->Winch.WinchCirBuff[indx].FishStatus==3)	// start to go up
						{
							sprintf(WinchDataStr,"%c%010lu$OPGFUP\r\n",timeChar, fCTDPtr->Winch.WinchCirBuff[indx].timeInHundredsecs);
						}
						WriteDataIntoFile(WinchDataStr, fCTDPtr);
					}
				}
				
				// write Winch's data into the file
				// contruct the string: T+timestamp+WinchData
				sprintf(WinchDataStr,"%c%010lu%s\n",timeChar,
								fCTDPtr->Winch.WinchCirBuff[indx].timeInHundredsecs,
								fCTDPtr->Winch.WinchCirBuff[indx].DataStr);
				if(WriteDataIntoFile(WinchDataStr, fCTDPtr)!=0)
					fCTDPtr->Winch.lastDropNum = fCTDPtr->Winch.dropNum;

				// if data is sending out via serialport
				if (fCTDPtr->WriteDataViaSerialPortFlag)
					if((fCTDPtr->totalByteSending+=WriteData(fCTDPtr->SerialPort4DataOut.spd, WinchDataStr))==0)
						printf("Can not send Winch to the serial port\n");
				// if data is sending out to network by UDP broadcast
				if (fCTDPtr->WriteData2NetworkFlag)
					if((numbytes = u_sendto(fCTDPtr->UDPSocket.udpfd,WinchDataStr,strlen(WinchDataStr),&fCTDPtr->UDPSocket.sockaddInfo))==-1)
						printf("Can not send CTD out via network\n");
				fCTDPtr->Winch.ReadBufferIndx++;
			}
		}
	}
	return NULL;
}

/*
** FUNCTION NAME: CheckDataIsBlocked(void *arg)
** PURPOSE: Checking lost communication with sensors
** DESCRIPTION:
** Checking the read (thread #1) is blocked
** by checking the last count every second:
** every  time the thread call get:    time -> to have ¶t = currtime - lasttime
**							number package -> have ¶Cnt = currCnt - lastCnt
** if the number package less than the expect number package -> send warning with total number lost package. 
**         ¶Cnt < ¶t*freq - 1
** the other words: (¶Cnt +1) * T < ¶t  (numberofPackage between 2 call * time/package < time between 2 call)
** --> comming data is stop.
** DATE: Mar 31, 2005
*/
#define FCTD_FREQ	16
#define PCODE_FREQ	1
#define WINCH_FREQ	1   // 1: for status, 1/240: for UP & DN
void *CheckDataIsBlocked(void *arg)
{
	int serialPortIndx = 0;
	struct timeval timev, *timevPtr;
	struct timezone timez, *timezPtr;
	timevPtr = &timev;
	timezPtr = &timez;
	static long CTDlastTimeInSec = 0;
	long CTDcurrTimeInSec = 0, CTDlastPacketCnt = 0, CTDcurrPacketCnt = 0, CTDtotalPackLost = 0;
	static long PCodelastTimeInSec = 0;
	long PCodecurrTimeInSec = 0, PCodelastPacketCnt = 0, PCodecurrPacketCnt = 0, PCodetotalPackLost = 0;
	static long WinchlastTimeInSec = 0;
	long WinchcurrTimeInSec = 0, WinchlastPacketCnt = 0, WinchcurrPacketCnt = 0, WinchtotalPackLost = 0;
	long deltaTime, deltaCnt;

	FastCTDStruct *fCTDPtr = (FastCTDStructPtr)arg;
	
	while(!fCTDPtr->Done)
	{
		sleep(1);
		if (fCTDPtr->CTDFlag&&!fCTDPtr->CTD.CTDDone)
		{
			// Get the current time
			gettimeofday(timevPtr, timezPtr);
			CTDcurrTimeInSec = timevPtr->tv_sec;
			// Initialize at the first call
			if (CTDlastTimeInSec==0)
			{
				CTDlastPacketCnt = fCTDPtr->CTD.SerialPort4CTD.PackCnt;
				CTDlastTimeInSec = CTDcurrTimeInSec;
			}
			// Get the current number of package data
			CTDcurrPacketCnt = fCTDPtr->CTD.SerialPort4CTD.PackCnt;
			// calculate ¶t and ¶Cnt
			deltaTime = CTDcurrTimeInSec - CTDlastTimeInSec;
			deltaCnt = CTDcurrPacketCnt - CTDlastPacketCnt;
			if (deltaCnt + 1 < (deltaTime*FCTD_FREQ))
			{
				CTDtotalPackLost += deltaTime*FCTD_FREQ-deltaCnt;
				printf("WARNING!!! Missing %ld string CTD data\n",CTDtotalPackLost);
			}
			else
				CTDtotalPackLost = 0;
			CTDlastPacketCnt = CTDcurrPacketCnt;
			CTDlastTimeInSec = CTDcurrTimeInSec;
		}
		if (fCTDPtr->PCodeFlag&&!fCTDPtr->PCode.PCodeDone)
		{
			gettimeofday(timevPtr, timezPtr);
			PCodecurrTimeInSec = timevPtr->tv_sec;
			if (PCodelastTimeInSec==0)
			{
				PCodelastPacketCnt = fCTDPtr->PCode.SerialPort4PCode.PackCnt;
				PCodelastTimeInSec = PCodecurrTimeInSec;
			}
			PCodecurrPacketCnt = fCTDPtr->PCode.SerialPort4PCode.PackCnt;
			deltaTime = PCodecurrTimeInSec - PCodelastTimeInSec;
			deltaCnt = PCodecurrPacketCnt - PCodelastPacketCnt;

			if (deltaCnt +1 <= deltaTime*PCODE_FREQ)
			{ 
				PCodetotalPackLost += deltaTime*PCODE_FREQ-deltaCnt;
				printf("WARNING!!! Missing %ld strings PCode data\n",PCodetotalPackLost);
			}
			else
				PCodetotalPackLost = 0;
			PCodelastPacketCnt = PCodecurrPacketCnt;
			PCodelastTimeInSec = PCodecurrTimeInSec;
		}
	}
	return NULL;
}


