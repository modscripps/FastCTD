#include "CTD.h"

#define PRESS_AVG 16
// average pressure (16 to 1)
static Boolean firstTime = TRUE;

/*
** Function Name: 
** int AverageFishData(FishCTDStructPtr fishCTDPtr, unsigned long *avgTime, float *avgPress, float *avgDepth, float *avgTemp, float *avgCond)
** Purpose: Average data of CTD 16 to one for sending to winch.
*/
int AverageFishData(FishCTDStructPtr fishCTDPtr, unsigned long *avgTime, float *avgPress, float *avgDepth, float *avgTemp, float *avgCond)
{
	int result, indx;
	unsigned int count;
	long num4send = 123456;
	float press = 0.0; //, avgPress= 0;
	float depth = 0.0; //, avgPress= 0;
	float temp = 0.0; //, avgTemp = 0;
	float cond = 0.0; //, avgCond = 0;
	unsigned long realTimestamp=0, timestamp = 0, headTimestamp = 0;
	static float totalpress = 0.0;
	static float totaldepth = 0.0;
	static float totaltemp = 0.0;
	static float totalcond = 0.0;
	static unsigned long totaltime = 0;

    // JMK 24 April 2005 To get current average rather than random average
    fishCTDPtr->GetPressIndx=fishCTDPtr->ParseIndx-PRESS_AVG-1;

for (count=0; count<=PRESS_AVG; count++)
{	
	// get the index of the current data
	indx = fishCTDPtr->GetPressIndx % MAX_CIRBUFF;
    // print out the last of average data - MNB Jun 9, 2011
    if (count == PRESS_AVG)
        printf("%s",fishCTDPtr->FishCTDCirBuff[indx].DataStr);
    
    if ((fishCTDPtr->FishCTDCirBuff[indx].ParseDone) && (fishCTDPtr->ParseIndx > fishCTDPtr->GetPressIndx))
	{
		// get the current data
		realTimestamp = fishCTDPtr->FishCTDCirBuff[indx].timeInHundredsecs;
		headTimestamp = realTimestamp/10000;
		timestamp = realTimestamp%10000;
		press = fishCTDPtr->FishCTDCirBuff[indx].FishCTDdata.pressure;
		depth = fishCTDPtr->FishCTDCirBuff[indx].FishCTDdata.depth;
		temp = fishCTDPtr->FishCTDCirBuff[indx].FishCTDdata.temperature;
		cond = fishCTDPtr->FishCTDCirBuff[indx].FishCTDdata.conductivity;
		
		// average fish pressure 16 -> 1 send to wich.
		if (count==PRESS_AVG)
		{
			// average time
			totaltime += timestamp;
			*avgTime = totaltime/(PRESS_AVG+1);
			*avgTime += headTimestamp*10000;
			totaltime = 0;
			totalpress += press;
			*avgPress = totalpress/(PRESS_AVG+1);
			totalpress = 0.0;
			totaldepth += depth;
			*avgDepth = totaldepth/(PRESS_AVG+1);
			totaldepth = 0.0;
			*avgTemp = totaltemp/(PRESS_AVG+1);
			totaltemp = 0.0;
			*avgCond = totalcond/(PRESS_AVG+1);
			totalcond = 0.0;
			result = 1;
		}
		else
		{
		    totaltime += timestamp;
			*avgTime = 0;
		    totalpress += press;
			*avgPress = 0.0;
			totaldepth += depth;
			*avgDepth = 0.0;
		    totaltemp += temp;
			*avgTemp = 0.0;
		    totalcond += cond;
			*avgCond = 0.0;
			result = 0;
		}
		fishCTDPtr->GetPressIndx++;
	}
}// end of for loop
	return result;
}

/*
Model: FAST CAT CTD 49
CTD's data format:  Raw data in Hexadecimal - 24 chars: 22 ASCII chars (hex) + 2 chars (carriage return & line feed) : 11 bytes per scan
example: ttttttccccccppppppvvvv = 0A53711BC7220C14C17D82
    Temperature = tttttt = 0A5371 (676721 decimal)
    tempeatrue A/D counts = 676721
	Conductivity = cccccc = 1BC722 (1820450)
	conductivity frequency = 1820450/256 = 7111.133 Hz
	Pressure = pppppp = 0C14C1 (791745 decimal)
	pressure A/D counts = 791745
	Pressure temperature compensation = vvvv = 7D82 (32,130 decimal)
	pressure temperature = 32,130 / 13,107 = 2.4514 volts

Model: 911 CTD:	
There are 12 words per scan, 3 bytes/word -> 36 bytes/scan.
	Word 0	Byte 0 -> 2:	Primary Temperature
	Word 1	Byte 3 -> 5:	Primary Conductivity
	Word 2	Byte 6 -> 8:	Pressure
	Word 11	Byte 33	   :	Pressure Sensor Temperature MSBs
		 	Byte 34	   :	4 MSB = Pressure Sensor Temperature LSBs
CALCULATION:	( perform in ConvertBinData() )
1. Frequencies:
	FT (Temperature) = Byte(0)*256 + Byte(1) + Byte(2)/256		(Hz)
	FC (Temperature) = Byte(3)*256 + Byte(4) + Byte(5)/256		(Hz)
	FP (Temperature) = Byte(6)*256 + Byte(7) + Byte(8)/256		(Hz)
2. Temperature:
		T = 1/{Ta+Tb*[ln(Tfo/FT)]+Tc*[ln(Tfo/FT)]^2+Td*[ln(Tfo/FT)]^3} - 273.15	(˚C)
3. Pressure:
	Pressure Temperature Compensation:
		12-bit pressure temperature compensation word =
			Byte(33)*16 + Byte(34)/16
		U = M * (12-bit pressure temperature compensation word) + B		(˚C)
		Pc = Pc1 + Pc2*U + Pc3*U^2
		Pd = Pd1 + Pd2*U
		Pto = Pt1 + Pt2*U + Pt3*U^2 + Pt4*U^3 + Pt5*U^4		(µsec)
		
		freq = (Pto/FT)^2
		P = Pc*[1 - freq]*[1 - Pd*(1 - freq)]				(psia)
  	
  	or the other way of calculation: (we use this following formular) 	

		freq = (Pto*FT)^2*1e-12;				1e-12: convert from µsec -> sec  		
  		P = {Pc*(1 - freq)*[1 - Pd*(1 - freq)]}/1.47 - 10	(dbar)
			1.47 = convert from psia to decibar
			10   = offset, the pressure at the surface of the ocean = 10
		
4. Conductivity:
		C = (Ca*FC^Cm + Cb*FC^2 + Cc + Cd*T)/[10(1 + CPCor*P)]		

*/

float CalculateTemp(FishCTDStructPtr FishCTDPtr, long tempInHex)
{
    float MV, R;
	float temp = 0.0;
	
	MV = (tempInHex - 524288)/1.6e+007;
	R = (MV * 2.295e+10 + 9.216e+8) / (6.144e+4 - MV*5.3e+5);
	temp = 1/( FishCTDPtr->FastCTDSetup.CTDCoeff.ta0
	          + FishCTDPtr->FastCTDSetup.CTDCoeff.ta1*log(R)
			  + FishCTDPtr->FastCTDSetup.CTDCoeff.ta2*log(R)*log(R)
			  + FishCTDPtr->FastCTDSetup.CTDCoeff.ta3*log(R)*log(R)*log(R)) - 273.15;
    return temp;
}

float CalculatePress(FishCTDStructPtr FishCTDPtr, long pressTemp, long pressTempComp)
{
    float y = 0.0, t = 0.0, x = 0.0, n = 0.0;
	float press = 0.0;
	
	y = pressTemp/13107;
	//JMK 29Aug06 fixed to be a0+T*a1+T^2*a2 
	t = FishCTDPtr->FastCTDSetup.CTDCoeff.ptempa0 + FishCTDPtr->FastCTDSetup.CTDCoeff.ptempa1*y
	    + FishCTDPtr->FastCTDSetup.CTDCoeff.ptempa2*y*y;
	x = pressTempComp - FishCTDPtr->FastCTDSetup.CTDCoeff.ptca0 - FishCTDPtr->FastCTDSetup.CTDCoeff.ptca1*t
					  - FishCTDPtr->FastCTDSetup.CTDCoeff.ptca2*t*t;
	n = x*FishCTDPtr->FastCTDSetup.CTDCoeff.ptcb0/(FishCTDPtr->FastCTDSetup.CTDCoeff.ptcb0
	                                               + FishCTDPtr->FastCTDSetup.CTDCoeff.ptcb1*t
												   + FishCTDPtr->FastCTDSetup.CTDCoeff.ptcb2*t*t);
	press = FishCTDPtr->FastCTDSetup.CTDCoeff.pa0 + FishCTDPtr->FastCTDSetup.CTDCoeff.pa1*n
	                                               + FishCTDPtr->FastCTDSetup.CTDCoeff.pa2*n*n;
    press = (press - 14.6959488) * 0.689476;	// convert psia to decibars
	 return press;
}

float CalculateCond(FishCTDStructPtr FishCTDPtr, float temp, float press, long condInHex)
{
    float condFreq = 0.0, f= 0.0, cond = 0.0, cond1 = 0.0, cond2 = 0.0;
	
	condFreq = condInHex/256;
	f = condFreq/1000.0;
	// in Siemens/meter unit
	cond1 = ( FishCTDPtr->FastCTDSetup.CTDCoeff.cg
			+ FishCTDPtr->FastCTDSetup.CTDCoeff.ch*f*f
			+ FishCTDPtr->FastCTDSetup.CTDCoeff.ci*f*f*f
			+ FishCTDPtr->FastCTDSetup.CTDCoeff.cj*f*f*f*f);
	cond2 = 1 + FishCTDPtr->FastCTDSetup.CTDCoeff.ctcor*temp + FishCTDPtr->FastCTDSetup.CTDCoeff.cpcor*press;
	cond = cond1/cond2;                                          
    return cond;
}

/*
** Function Name: Boolean FishCTD_AcquireData(FishCTDStructPtr fishCTDPtr)
** Purpose: Acquire CTD's data: find a sync and get the whole packet (CTD has a fixed length)
*/
Boolean FishCTD_AcquireData(FishCTDStructPtr fishCTDPtr)
{
    char	*buffPtr;	// Current char in buffer
	char tstr[MAX_LENGTH] = "\0";
	char tstr1[MAX_LENGTH] = "\0";
	ssize_t	numBytes = 0;	// Number of bytes read or written
	int serialPortIndx = 0; // by default: use SerialPort[0] for acquire CTD's data
	int indx;
	struct timeval *timevPtr;
	struct timezone timez, *timezPtr;
	struct tm time_str;
	int local = 1;
	char timeStr[125] = "\0";
	int val = 0;
    int rate = 0; // addding rate for display - MNB Jun 16, 2011
	// time_t offsetTime;
	
    buffPtr = tstr;
	switch (fishCTDPtr->CTDPhase)
	{
		case 1:		// find a sync
			fishCTDPtr->SerialPort4CTD.reqReadSize = 1;
			numBytes = read(fishCTDPtr->SerialPort4CTD.spd, buffPtr, fishCTDPtr->SerialPort4CTD.reqReadSize);
			if (numBytes == -1)
			{
				printf("Error reading from serial port at phase 1 - %s(%d).\n",
					strerror(errno), errno);
				return false;
			}
			if(numBytes>0)  // get byte of data
			{
				if (*buffPtr==(char)10){	// linefeed
					fishCTDPtr->SerialPort4CTD.reqReadSize = fishCTDPtr->CTDlength;//CTD_LENGTH;
					fishCTDPtr->CTDPhase = 2;
					// set VMIN to CTD_LENGTH bytes for serial port
					fishCTDPtr->SerialPort4CTD.spOptions.c_cc[ VMIN ] = fishCTDPtr->CTDlength;//CTD_LENGTH;
					if (tcsetattr(fishCTDPtr->SerialPort4CTD.spd, TCSANOW, &fishCTDPtr->SerialPort4CTD.spOptions) == -1)
					{
						printf("Error setting tty attributes %s(%d).\n",
							strerror(errno), errno);
						return false;
					}
				}
			}
		break;
		case 2:		// read the whole packet from serial port
			numBytes = read(fishCTDPtr->SerialPort4CTD.spd, buffPtr, fishCTDPtr->SerialPort4CTD.reqReadSize);
			if (numBytes == -1)
			{
				printf("Error reading from serial port at phase 1 - %s(%d).\n",	strerror(errno), errno);
				return false;
			}

			if (numBytes > 0)
			{
				// if the end of the packet is not carriage return character -> come back phase 0 
				if (tstr[numBytes-2]!='\r')
				{
					fishCTDPtr->SerialPort4CTD.reqReadSize = 1;
					fishCTDPtr->CTDPhase = 1;
					fishCTDPtr->SerialPort4CTD.doneRead = 0;
					fishCTDPtr->doneRead = 0;
					// set VMIN to 1byte for serial port
					fishCTDPtr->SerialPort4CTD.spOptions.c_cc[ VMIN ] = 1;
					if (tcsetattr(fishCTDPtr->SerialPort4CTD.spd, TCSANOW, &fishCTDPtr->SerialPort4CTD.spOptions) == -1)
					{
						printf("Error setting tty attributes - %s(%d).\n", strerror(errno), errno);
						return false;
					}
				}
				else
				{   // save data into the string .  ... parsing data later
					indx = fishCTDPtr->Write2BufferIndx%MAX_CIRBUFF;
					sprintf(tstr1,"$OPGCTD%s",tstr);
					strncpy(fishCTDPtr->FishCTDCirBuff[indx].DataStr,tstr1,strlen(tstr1));

                    // display in debug mode
                    if (fishCTDPtr->printData == 2)
						printf("Get data from CTD: %s",tstr);

					// display CTD data in engineer mode with 2 times/sec
                    rate = 16/fishCTDPtr->engDispRate;
                    val = indx%rate;

					if ((fishCTDPtr->printData == 1) && (val==0)) // engineer data
						printf("%s",fishCTDPtr->FishCTDCirBuff[indx].DataStr);
                    
                    // Debug mode: print out everything. - MNB Jun 16, 2011
                    if (fishCTDPtr->printData == 2)
						printf("Combine with indentify: %s",fishCTDPtr->FishCTDCirBuff[indx].DataStr);

					// Get the current time and save it.
					timevPtr = &fishCTDPtr->FishCTDCirBuff[indx].UnixTime;
					timezPtr = &timez;
					// offsetTime is from Globals.h JMK
					
					gettimeofday(timevPtr, timezPtr);	// get number of seconds from Jan 1, 1970
					//getT0(&offsetTime); //JMK
					
					fishCTDPtr->FishCTDCirBuff[indx].timeInHundredsecs = Get_Time_In_Hundred_Secs(timeStr, local);
					// Increase the write count
					fishCTDPtr->Write2BufferIndx++;
					fishCTDPtr->FishCTDCirBuff[indx].ParseDone = FALSE;
					fishCTDPtr->doneRead = 1;
					fishCTDPtr->PackCnt ++;	// update the packet Fish CTD count
					fishCTDPtr->SerialPort4CTD.PackCnt ++;	// update the packet Fish CTD count for detect losing packet in CheckBlockThread()
					fishCTDPtr->SerialPort4CTD.totalBytesSPread = numBytes;  // total bytes read from serial port
				}
			}
			break;
		default:
		break;
	}
	return true;
}

/*
** Function Name: int GetFishCTDCal(CTDCoeffStructPtr coeffFishCTDPtr)
** Purpose: Read CTD calibration file
*/
int GetFishCTDCal(CTDCoeffStructPtr coeffFishCTDPtr, char* calFileName)
{
	FILE* fp = NULL;
	char* sep = "= ";
	char confstr[MAX_LENGTH] = "\0";
	char *strPtr;

	char cwd[256], pcwd[256], filename[256];
	char *cwdPtr;
	
	int total_line = 0;
	
    if ((cwdPtr=getcwd(cwd, 256)) == NULL)
	{
		perror("getcwd() error");
		return 0;
	}
	// get its parent directory
	GetPath(cwd, pcwd);
	sprintf(filename,"%s/%s",cwd,calFileName);
	fprintf(stdout,"Reading Cal file %s\n",filename);
	
	fp = fopen(filename,"r");
	if(fp==NULL){
		printf("Could not open the calibration file for fish\n");
		return 0;
	}

	while(Filegets(confstr,sizeof(confstr),fp))
	{
		if (confstr[0]=='\0') break;
		total_line++;

		strPtr = strtok(confstr,sep);

		if(*strPtr=='S')
		{
			strPtr = strtok(NULL,sep);
			strcpy(coeffFishCTDPtr->serialnum,strPtr);
		}
		else if (*strPtr=='T')
		{
			if(!strcmp("TCALDATE",strPtr))
			{
				strPtr = strtok(NULL,sep);
				strcpy(coeffFishCTDPtr->tcalDate,strPtr);
			}
			else if(!strcmp("TA0",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ta0 = atof(strPtr);
			}
			else if(!strcmp("TA1",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ta1 = atof(strPtr);
			}
			else if(!strcmp("TA2",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ta2 = atof(strPtr);
			}
			else // if(!strcmp("TA3",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ta3 = atof(strPtr);
			}
		}
		else if (*strPtr=='C')
		{
			if(!strcmp("CCALDATE",strPtr))
			{
				strPtr = strtok(NULL,sep);
				strcpy(coeffFishCTDPtr->tcalDate,strPtr);
			}
			else if(!strcmp("CG",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->cg = atof(strPtr);
			}
			else if(!strcmp("CH",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ch = atof(strPtr);
			}
			else if(!strcmp("CI",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ci = atof(strPtr);
			}
			else if(!strcmp("CJ",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->cj = atof(strPtr);
			}
			else if(!strcmp("CG",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->cg = atof(strPtr);
			}
			else if(!strcmp("CTCOR",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ctcor = atof(strPtr);
			}
			else //if(!strcmp("CPCOR",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->cpcor = atof(strPtr);
			}
		}
		else if (*strPtr == 'P')
		{
			if(!strcmp("PCALDATE",strPtr))
			{
				strPtr = strtok(NULL,sep);
				strcpy(coeffFishCTDPtr->pcalDate,strPtr);
			}
			else if(!strcmp("PA0",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->pa0 = atof(strPtr);
			}
			else if(!strcmp("PA1",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->pa1 = atof(strPtr);
			}
			else if(!strcmp("PA2",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->pa2 = atof(strPtr);
			}
			else if(!strcmp("PTCA0",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptca0 = atof(strPtr);
			}
			else if(!strcmp("PTCA1",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptca1 = atof(strPtr);
			}
			else if(!strcmp("PTCA2",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptca2 = atof(strPtr);
			}
			else if(!strcmp("PTCB0",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptcb0 = atof(strPtr);
			}
			else if(!strcmp("PTCB1",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptcb1 = atof(strPtr);
			}
			else if(!strcmp("PTCB2",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptcb2 = atof(strPtr);
			}
			else if(!strcmp("PTEMPA0",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptempa0 = atof(strPtr);
			}
			else if(!strcmp("PTEMPA1",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptempa1 = atof(strPtr);
			}
			else //(!strcmp("PTEMPA2",strPtr))
			{
				strPtr = strtok(NULL,sep);
				coeffFishCTDPtr->ptempa2 = atof(strPtr);
			}
		}
	}

	if(fp) fclose(fp);
	return total_line;
}	// end of GetFishCTDCal()

/*
** Function Name: int GetFishCTDCal(CTDCoeffStructPtr coeffFishCTDPtr)
** Purpose: Read CTD calibration file
*/
int InitFishCTD(FishCTDStructPtr fishCTDPtr)
{
    char filename[32];
	int total_cal_line;
		
	fishCTDPtr->CTDPhase = 1;
	fishCTDPtr->CTDDone = false;
	fishCTDPtr->CTDReqReadSize = 1;
	fishCTDPtr->ParseIndx = 0;
	fishCTDPtr->Write2BufferIndx = 0;
	sprintf(filename,"%s.CAL",fishCTDPtr->SerialNum);
	
	if ((total_cal_line=GetFishCTDCal(&fishCTDPtr->FastCTDSetup.CTDCoeff,filename)) == 0) return 0;
	return total_cal_line;
}

static int LastFishIsDown = 0;
/*
** Function Name: ParsingFishCTD(FishCTDStructPtr FishCTDPtr)
** Purpose: Parse CTD's data
** has micro-cond: 
**      $OPGCTD055D820A889107FE5641DBEC13EC16EC12EC10EC16EC11EC14EC11EC12EC0F9F25575F83B10000026C
**  $OPGCTD  055D82 0A8891 07FE56 41DB EC13 EC16 EC12 EC10 EC16 EC11 EC14 EC11 EC12 EC0F 9F25575F83B10000026C
*/
int ParsingFishCTD(FishCTDStructPtr FishCTDPtr)
{
	int indx, i,j,indx2,k,dataIndx, result;
	long val = 0, val2 = 0, tempInDec, pressInDec, condInDec, pressTempInDec;
	char tstr[25] = "\0";
	float temp;
	unsigned int total_micro = 0, avg_micro = 0;
    int rate = 0;
	
	dataIndx = FishCTDPtr->ParseIndx % MAX_CIRBUFF;

    if ((!FishCTDPtr->FishCTDCirBuff[dataIndx].ParseDone) && (FishCTDPtr->ParseIndx < FishCTDPtr->Write2BufferIndx))
	{
		strcpy(FishCTDPtr->ParsingStr,FishCTDPtr->FishCTDCirBuff[dataIndx].DataStr);
		// *** convert data: temp, cond, press in hex to decimal
		for (j=0; j<4; j++)
		{
			indx = 7+6*j;	// 7: start after identifier string: "$OPGCTD"
			if (j<3) indx2 = indx+6;  // for temp, cond, pressure
			else indx2 = indx+4;      // for pressure temperature compensation
			// copy a character string want to convert to decimal value into tstr string
			for (i=indx,k=0; i<indx2; i++,k++)
				tstr[k] = FishCTDPtr->ParsingStr[i]; // j=0: copy temp to tstr, j=1: cond to tstr, j=2: press to tstr, j=3: presstemp to tstr
			tstr[k] = '\0';
			val = HexStr2Dec(tstr);
			switch(j)
			{
				case 0:
					tempInDec = val;
				break;
				case 1:
					condInDec = val;
				break;
				case 2:
					pressInDec = val;
					// define whether fish is up or down.
					if (firstTime)	// initialize
					{
					   FishCTDPtr->FishPressAvg.LastPressAvg = FishCTDPtr->FishPressAvg.CurrPressAvg = AVG_WINDOWINPACKS*val;
					   for(i = 0; i<AVG_WINDOWINPACKS; i++){
					      FishCTDPtr->FishPressAvg.PressWindow[i] = val;
						}				   
						firstTime = FALSE;
					}
					else
					{
						FishCTDPtr->FishPressAvg.LastPressAvg = FishCTDPtr->FishPressAvg.CurrPressAvg;	// the current become the last
						FishCTDPtr->FishPressAvg.CurrPressAvg = FishCTDPtr->FishPressAvg.CurrPressAvg + val - FishCTDPtr->FishPressAvg.PressWindow[FishCTDPtr->FishPressAvg.LastIndx];

						if (FishCTDPtr->FishPressAvg.CurrPressAvg > FishCTDPtr->FishPressAvg.LastPressAvg){ FishCTDPtr->FishCTDCirBuff[dataIndx].FishIsDown = 1;}
						else if (FishCTDPtr->FishPressAvg.CurrPressAvg < FishCTDPtr->FishPressAvg.LastPressAvg) {FishCTDPtr->FishCTDCirBuff[dataIndx].FishIsDown = 0;}

						if (FishCTDPtr->FishCTDCirBuff[dataIndx].FishIsDown != LastFishIsDown) FishCTDPtr->FishCTDCirBuff[dataIndx].FishChangesCourse = TRUE;
						else FishCTDPtr->FishCTDCirBuff[dataIndx].FishChangesCourse = FALSE;
						LastFishIsDown = FishCTDPtr->FishCTDCirBuff[dataIndx].FishIsDown;

						// update its index and pressure window
						FishCTDPtr->FishPressAvg.LastIndx = (FishCTDPtr->FishPressAvg.LastIndx + 1) % AVG_WINDOWINPACKS;
						FishCTDPtr->FishPressAvg.CurrIndx = (FishCTDPtr->FishPressAvg.CurrIndx + 1) % AVG_WINDOWINPACKS;
						FishCTDPtr->FishPressAvg.PressWindow[FishCTDPtr->FishPressAvg.CurrIndx] = val;
					}
				break;
				case 3:
					pressTempInDec = val;
				break;
			}
		}
		if (CTD_LENGTH == 72)	// has micro-conductivity
		{
			// *** convert micro-cond in hex to decimal
			for (j=0; j<10; j++)
			{
				indx = 29+4*j;
				indx2 = indx+4;
				for (i=indx,k=0; i<indx2; i++,k++)
					tstr[k] = FishCTDPtr->ParsingStr[i]; // copy each number of micro-cond (total=10) to tstr
				tstr[k] = '\0';
				val = HexStr2Dec(tstr);
				total_micro += val;
			}
			avg_micro = total_micro/10;	
		}
		// *** Calculate temp, press, cond with engineer unit
		FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.temperature = CalculateTemp(FishCTDPtr, tempInDec);
		FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.pressure = CalculatePress(FishCTDPtr, pressTempInDec, pressInDec);
		FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.depth = Press2Meter(FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.pressure);
		FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.conductivity 
		   = CalculateCond(FishCTDPtr, FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.temperature, FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.pressure, condInDec);
		FishCTDPtr->ParseIndx++;
		FishCTDPtr->FishCTDCirBuff[dataIndx].ParseDone = TRUE;

		// diplay data in engineer format in engDispRate times/sec
        if (FishCTDPtr->engDispRate != 16)
       {
            rate = 16/(FishCTDPtr->engDispRate);
            val2 = indx%rate;
    //		val2 = dataIndx%4;
            if ((FishCTDPtr->printData == 1) && (val2==0))
            {
                printf("time = %lu, temp = %f, press = %f, cond = %f",FishCTDPtr->FishCTDCirBuff[dataIndx].timeInHundredsecs,
                                                        FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.temperature,
                                                        FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.pressure,
                                                        FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.conductivity);
                if(CTD_LENGTH == 72)
                    printf(", avg_micro = %d\n",avg_micro);
                else
                    printf("\n");
            }
        }
       // for debug mode, print out everything - MNB Jun 16, 2011
		if (FishCTDPtr->printData == 2)
		{
			printf("After parsing CTD: time = %lu, temp = %f, press = %f, cond = %f",FishCTDPtr->FishCTDCirBuff[dataIndx].timeInHundredsecs,
                   FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.temperature,
                   FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.pressure,
                   FishCTDPtr->FishCTDCirBuff[dataIndx].FishCTDdata.conductivity);
			if(CTD_LENGTH == 72)
				printf(", avg_micro = %d\n",avg_micro);
			else
				printf("\n");
		}

	}
}

/*
** Function Name: Press2Meter(float pressInDecibars)
** Purpose: convert pressure to meter
*/
float Press2Meter(float pressInDecibars)
{
	float g = 9.780318;
	float depth;
	float depth1;
    float depth2;
    float c1 = 9.72659;
    float c2 = -2.22512e-5;
    float c3 = 2.279e-10;
    float c4 = -1.82e-15;
    float gam_dash = 2.184e-6;
    
    depth1 = g + gam_dash*0.5*pressInDecibars;
    depth2 = (((c4*pressInDecibars+c3)*pressInDecibars+c2)*pressInDecibars+c1)*pressInDecibars;
    
	depth = depth2/depth1;
    	
	return depth;
}

/*
** Function Name: ReadFishCTDdataFromPort(void *arg)
** Purpose: Read CTD from serial port
*/
void *ReadFishCTDdataFromPort(void *arg)
{
	struct timespec stime;
	stime.tv_nsec = 1000000000;  // 1000ms
	stime.tv_sec = 0;
	FishCTDStruct *fCTDPtr;
	char tempStr[MAX_LENGTH] = "\0";
	int serialPortIndx = 0;
    
	fCTDPtr	= (FishCTDStructPtr)arg;
		
	set_realtime(1000000, 5000, 10000);
	while(!fCTDPtr->CTDDone){
		// read data from port1
		if(FishCTD_AcquireData(fCTDPtr)==0)
			continue;
		// copy data into circle buffer when we get the whole CTD packet
		if(fCTDPtr->doneRead)
		{
			ParsingFishCTD(fCTDPtr);
		}
	}
	printf("End of ReadCTDfromPort() in Pthread.c\n");

	return NULL;
}

/*
** Function Name: SetOptionSerialPort4FishCTD(FishCTDStructPtr FishCTDPtr)
** Purpose: Set option of serial port for Fish CTD
*/
 int SetOptionSerialPort4FishCTD(FishCTDStructPtr FishCTDPtr)
 {
	cfsetspeed(&FishCTDPtr->SerialPort4CTD.spOptions, FishCTDPtr->SerialPort4CTD.speed);
 }
 
/*
** Function Name: WriteFishCTDDataIntoBuffer(char *str, FishCTDStructPtr fishCTDPtr)
** Purpose: Write CTD's data into cir buffer
*/
void WriteFishCTDDataIntoBuffer(char *str, FishCTDStructPtr fishCTDPtr)
{
	int indx;
	// write into FishCTD's circular buffer
	indx = fishCTDPtr->Write2BufferIndx%MAX_CIRBUFF;
	strcpy(fishCTDPtr->FishCTDCirBuff[indx].DataStr, str);
	fishCTDPtr->Write2BufferIndx++;
}

