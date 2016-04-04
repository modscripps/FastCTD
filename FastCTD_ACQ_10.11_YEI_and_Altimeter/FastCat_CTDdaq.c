#include "FastCat_CTDdaq.h"


/*
** FUNCTION NAME: FastCTDInit(FastCTDStructPtr fctd)
** PURPOSE: Initialize all parameters for FastCTD app, all sensors.
** DATE: Mar 31, 2005
*/
void FastCTDInit(FastCTDStructPtr fctd)
{
	enum Sensors sensorType;
	int i;
	int val;
	// portnumber was set in CheckInput()
	// initialize, will be update after reading from setup file
	fctd->Done = false;
	// initialize for out put data file
	fctd->Ascii_dataFile.ftype = 0;	// initialize, will be update after reading from setup file

	if (fctd->Ascii_dataFile.runname[0]=='\0') strcpy(fctd->Ascii_dataFile.runname, "FCTD");

	// if CTD install, initialize for CTD
	if (fctd->CTDFlag)
	{
		sensorType = CTD;
		// Initialize Fish CTD: assign all Fish CTD's parameters and get coefficiences from Fish CTD's file
		if ((val=InitFishCTD(&fctd->CTD)) == 0) 
			printf("Fish does not have coeff from cal file\n");
	}
	// if Pcode install, initialize for PCode
	if (fctd->PCodeFlag)
	{
		sensorType = PCode;
		InitPCode(&fctd->PCode);
	}
	// if Winch install, initialize for Winch
	if (fctd->WinchFlag)
	{
		sensorType = Winch;
		InitWinch(&fctd->Winch);
	}
}
// Write data into a file:
// if have a winch data: file is created by the drop number, otherwise created by size
int WriteDataIntoFile(const char *str, FastCTDStructPtr fctd)
{
	ssize_t numBytesWr;
	unsigned long diffDrop = 0;
	Boolean newFile=FALSE;

	// diffDrop>1 for detect the other sensor write data not create the new file when the drop num has not been increased
//	diffDrop = fctd->CTD.dropNum - fctd->dropnum4newfile;
	diffDrop = fctd->Winch.dropNum - fctd->dropnum4newfile;

	// Checking whether need to create a new file before writing data in
	// if the file is written over limit size - set in Global.h

	// if the file size is set -> data is saved base on the file size: reach a limit -> create the new file
	if(fctd->Ascii_dataFile.dataFileSize!=0 && fctd->Ascii_dataFile.totalBytesWrFile > fctd->Ascii_dataFile.dataFileSize)
		newFile = TRUE;
	// otherwise base on the drop numbers
	else if (fctd->Ascii_dataFile.dataFileSize==0 && fctd->Winch.dropNum>1 && !((fctd->Winch.dropNum-1)%(fctd->RecHeader.totalDrops))&&(diffDrop>1))
		newFile = TRUE;

	// need to create a new file
	if (newFile)
	{
		// Save the information at the end of the old file first before closing the old file
		SaveHeaderFile(fctd,2);
		CloseCurrFile(&(fctd->Ascii_dataFile));
		// Now, create the new file
		if(CreateNewFile(&(fctd->Ascii_dataFile))==0){ 
			printf("Could not create the new file when it reachs limit\n");
			return 0;
		}
//		printf("Create the new file \n");
		// update the drop number and reset the total bytes for the new file
//		fctd->dropnum4newfile = fctd->CTD.dropNum;
		fctd->dropnum4newfile = fctd->Winch.dropNum;
		fctd->Ascii_dataFile.totalBytesWrFile = 0;
		// put information in the header file
		SaveHeaderFile(fctd,1);
	}

	// Write data into the file
	if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
	{
		fprintf(stderr,"ERROR! Can not write data into file\n");
		return 0;
	}
	fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
	return 1;
}
int ReadSetup_Write2File(FastCTDStructPtr FastCTDPtr, FILE *fp_data, char *str,int *total_line)
{
	char confstr[MAX_LENGTH] = "\0";
	ssize_t numBytesWr=0;
	int len = 0, total_chars = 0;
	char nl[1] = {'\n'};
	int tl = 0;
    
	char filename[1024], fname[] = "Setup", path[1024]="\0";
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
		len = strlen(confstr);
		confstr[len] = '\n';
		confstr[len+1] = '\0';
		tl++;
		if(fp_data)
		{
			if((numBytesWr=fwrite(confstr,1,strlen(confstr),fp_data))==-1)
			{
				fprintf(stderr,"ERROR! Can not write setup data file\n");
				return 0;
			}
			total_chars += numBytesWr;
		}
		else
		{
			strncat(str,confstr,sizeof(confstr)-strlen(confstr)-1);
			total_chars = strlen(str);
		}	
	}
	if (fp) {fclose(fp);fp = NULL;}
	*total_line = tl;	
	return total_chars;
} // end of ReadSetupFile

int ReadFishCTDCal_Write2File(char* calFileName, FILE *fp_data, char* str,int *total_line)
{
	FILE* fp = NULL;
	char confstr[MAX_LENGTH] = "\0", tempStr[32]="\0", str1[32]="\0", parsestr[32]="\0";
	char *strPtr;
	char* sep = "= ";
    
	char cwd[256], pcwd[256], filename[256];
	char *cwdPtr;
	ssize_t numBytesWr=0;
	int len = 0, total_chars = 0, tl = 0;
	
    if ((cwdPtr=getcwd(cwd, 256)) == NULL)
	{
		perror("getcwd() error");
		return 0;
	}
	// get its parent directory
	GetPath(cwd, pcwd);
	sprintf(filename,"%s/%s",cwd,calFileName);
	fprintf(stdout,"Reading Cal file %s and writing to data file\n",filename);
	
	fp = fopen(filename,"r");
	if(fp==NULL){
		printf("Could not open the calibration file for fish\n");
		return 0;
	}
    
	while(Filegets(confstr,sizeof(confstr),fp))
	{
		if (confstr[0]=='\0') break;
		tl++;
		strcpy(parsestr,confstr);
		strPtr = strtok(parsestr,sep);
        
		// Add the single quote to these strings
		if(*strPtr=='S')
		{
			strcpy(str1,strPtr);	// save the SERIALNO into the first temporary string
			strPtr = strtok(NULL,sep);	//  get the serial number
			strcpy(tempStr,strPtr);		// copy it into the second temporary string
			sprintf(confstr,"%s%c'%s'",str1,'=',tempStr);	// construct the string to write into the data file
		}
		else if(!strcmp("TCALDATE",strPtr))
		{
			strcpy(str1,strPtr);	// save the TCALDATE into the first temporary string
			strPtr = strtok(NULL,sep);
			strcpy(tempStr,strPtr);		// copy it into the second temporary string
			sprintf(confstr,"     %s%c'%s'",str1,'=',tempStr);	// construct the string to write into the data file
		}
		else if(!strcmp("CCALDATE",strPtr))
		{
			strcpy(str1,strPtr);	// save the CCALDATE into the first temporary string
			strPtr = strtok(NULL,sep);
			strcpy(tempStr,strPtr);		// copy it into the second temporary string
			sprintf(confstr,"     %s%c'%s'",str1,'=',tempStr);	// construct the string to write into the data file
		}
		else if(!strcmp("PCALDATE",strPtr))
		{
			strcpy(str1,strPtr);	// save the PCALDATE into the first temporary string
			strPtr = strtok(NULL,sep);
			strcpy(tempStr,strPtr);		// copy it into the second temporary string
			sprintf(confstr,"     %s%c'%s'",str1,'=',tempStr);	// construct the string to write into the data file
		}
        
		len = strlen(confstr);
		confstr[len] = '\n';
		confstr[len+1] = '\0';
		if(fp_data)
		{
			if((numBytesWr=fwrite(confstr,1,strlen(confstr),fp_data))==-1)
			{
				fprintf(stderr,"ERROR! Can not write setup data file\n");
				return 0;
			}
			total_chars += numBytesWr;
		}
		else
		{
			strncat(str,confstr,sizeof(confstr)-strlen(confstr)-1);
			total_chars = strlen(str);
		}	
	}
    
	if(fp) fclose(fp);
	*total_line = tl;
	return total_chars;
}	// end of ReadFishCTDCal_Write2File()

ssize_t SaveHeaderFile(FastCTDStructPtr fctd,int head_tail)
{
	struct timeval timev, *timevPtr;
	struct tm timeInfo, *timeInfoPtr;
	struct timezone timez, *timezPtr;
	unsigned long timevalue, dn;
	ssize_t numBytesWr, headerBytes=0;
	char startHeader[] = "%*****START_FCTD_HEADER_START_RUN*****\n";
	char endHeader[] = "%*****END_FCTD_HEADER_START_RUN*****\n";
	char startTailer[] = "%*****START_FCTD_TAILER_END_RUN*****\n";
	char endTailer[] = "%*****END_FCTD_TAILER_END_RUN*****\n";
	char appStr[] = "%***APP_OPTIONS (identical with setup file)\n";
	char sensorsStr[] = "%***SENSORS_INFO:\n%1. FISH_CTD SBD 49 FASTCAT (as in Fish calibration file)\n";
	char winchStr[] = "%2. WINCH_PARAMETERS: to be determined later...\n";
	char noteTimeStr[] = "%OFFSET_TIME: (since Jan 1, 1970 to Jan 1, CURRENT YEAR), SYSTEM_TIME (since Jan 1, CURRENT YEAR to now) hundreths of seconds\n";
	char str[1024]="\0",hdsize[125]="\0", fctdVer[125]="\0", timeStr[125]="\0",gpsTime[125]="\0";
	char latlon[125]="\0", dropnum[125]="\0", fish_sn[125]="\0", fish_cal[1024]="\0";
	char str4Setupfile[2124] = "\0", cal_str[2124] = "\0";
	struct tm *time_str;
	time_t hundredSecs;
	char timestr[125] = "\0";
	char cal_file[32] = "\0";
	int num_header_line = 0,  val = 0;

	sprintf(cal_file,"%s.CAL",fctd->CTD.SerialNum);
	
	hundredSecs = Get_Time_In_Hundred_Secs(timestr,0);
	
//JMK 16Apr2005: Changed string entries to have  single quotes around them.
//               Added carriage returns where necessary.
//               This is for MatLab parsability...
	sprintf(hdsize,"HEADER_SIZE = %d\n",num_header_line);
	sprintf(fctdVer,"FCTD_VER = '%s, %s'\n",__DATE__,__TIME__);
	sprintf(timeStr,"SYSTEM_TIME = %lu\nGM_TIME = '%.22s'\n",hundredSecs,timestr);
	sprintf(latlon,"PCodeData.lat = %f\nPCodeData.lon = %f\n",fctd->PCode.PCodeData.lat,fctd->PCode.PCodeData.lon);
/*
	sprintf(fish_sn,"CTDCoeff.serialnum = '%s'\n",fctd->CTD.FastCTDSetup.CTDCoeff.serialnum);
	sprintf(fish_cal,"CTDCoeff.tcalDate = '%s'\nCTDCoeff.ta0 = %e\nCTDCoeff.ta1 = %e\nCTDCoeff.ta2 = %e\nCTDCoeff.ta3 = %e\n\
	CTDCoeff.ccalDate = '%s'\nCTDCoeff.cg = %e\nCTDCoeff.ch=%e\nCTDCoeff.ci = %e\nCTDCoeff.cj = %e\nCTDCoeff.ctcor = %e\nCTDCoeff.cpcor = %e\n\
	CTDCoeff.pcalDate = '%s'\nCTDCoeff.pa0 = %e\nCTDCoeff.pa1 = %e\nCTDCoeff.pa2 = %e\nCTDCoeff.ptca0 = %e\nCTDCoeff.ptca1 = %e\nCTDCoeff.ptca2 = %e\n\
	CTDCoeff.ptcb0 = %e\nCTDCoeff.ptcb1 = %e\nCTDCoeff.ptcb2 = %e\n\
	CTDCoeff.ptempa0 = %e\nCTDCoeff.ptempa1 = %e\nCTDCoeff.ptempa2 = %e\n",
	                  fctd->CTD.FastCTDSetup.CTDCoeff.tcalDate,fctd->CTD.FastCTDSetup.CTDCoeff.ta0,fctd->CTD.FastCTDSetup.CTDCoeff.ta1,fctd->CTD.FastCTDSetup.CTDCoeff.ta2,fctd->CTD.FastCTDSetup.CTDCoeff.ta3,
					  fctd->CTD.FastCTDSetup.CTDCoeff.ccalDate,fctd->CTD.FastCTDSetup.CTDCoeff.cg,fctd->CTD.FastCTDSetup.CTDCoeff.ch,fctd->CTD.FastCTDSetup.CTDCoeff.ci,fctd->CTD.FastCTDSetup.CTDCoeff.cj,fctd->CTD.FastCTDSetup.CTDCoeff.ctcor,fctd->CTD.FastCTDSetup.CTDCoeff.cpcor,
					  fctd->CTD.FastCTDSetup.CTDCoeff.pcalDate,fctd->CTD.FastCTDSetup.CTDCoeff.pa0,fctd->CTD.FastCTDSetup.CTDCoeff.pa1,fctd->CTD.FastCTDSetup.CTDCoeff.pa2,fctd->CTD.FastCTDSetup.CTDCoeff.ptca0,fctd->CTD.FastCTDSetup.CTDCoeff.ptca1,fctd->CTD.FastCTDSetup.CTDCoeff.ptca2,
					  fctd->CTD.FastCTDSetup.CTDCoeff.ptcb0,fctd->CTD.FastCTDSetup.CTDCoeff.ptcb1,fctd->CTD.FastCTDSetup.CTDCoeff.ptcb2,
					  fctd->CTD.FastCTDSetup.CTDCoeff.ptempa0,fctd->CTD.FastCTDSetup.CTDCoeff.ptempa1,fctd->CTD.FastCTDSetup.CTDCoeff.ptempa2);
*/
	if (head_tail==1)	// header
	{
		// for the begining of the run
		if (fctd->Winch.dropNum==0) dn = 1;
		else dn = fctd->Winch.dropNum;
		sprintf(dropnum,"Winch.dropNum=%lu\n",dn);

		// write the header size (bytes) at the beginning of the header
		sprintf(str,"header_file_size_inbytes = %6d\n",fctd->header_file_size_bytes); // strlen(tempStr) = 32
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write setup file info into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
		fctd->header_file_size_bytes += numBytesWr;
		num_header_line++;

		sprintf(str,"TOTAL_HEADER_LINES = %d\n%s%s%sOFFSET_TIME = %lu\n%s%s%s%s",num_header_line,startHeader,fctdVer,noteTimeStr,fctd->offset_time,timeStr,latlon,dropnum,appStr);
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write start header into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
		fctd->header_file_size_bytes += numBytesWr;
		num_header_line += 11;
		
		val = 0;
		// read the SETUP FILE and write them into header
		if (ReadSetup_Write2File(fctd,NULL,str4Setupfile,&val)==0)
			fprintf(stderr,"ERROR! Can not write setup data file\n");

		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str4Setupfile,strlen(str4Setupfile)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write setup file info into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
		fctd->header_file_size_bytes += numBytesWr;
		num_header_line += val;

		// write the sensorsStr into the header
		sprintf(str,"%s",sensorsStr);
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write sensorsStr header info into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
		fctd->header_file_size_bytes += numBytesWr;
		num_header_line += 2;

		// read the FISH CAL FILE and write them into header
		if (ReadFishCTDCal_Write2File(cal_file, NULL, cal_str,&val)==0)
			printf("ERROR! Can not read cal file for writing into data file\n");
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,cal_str,strlen(cal_str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write header info into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
		fctd->header_file_size_bytes += numBytesWr;
		num_header_line += val;

		// write the strings end of the header
		sprintf(str,"%s%s",winchStr,endHeader);
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write sensorsStr header info into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
		fctd->header_file_size_bytes += numBytesWr;
		num_header_line += 2;
		
		// update header file size
		lseek(fctd->Ascii_dataFile.fd,0L,SEEK_SET);
		sprintf(str,"header_file_size_inbytes = %6d\n",fctd->header_file_size_bytes); // strlen(tempStr) = 32
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write setup file info into file\n");
			return 0;
		}
		sprintf(str,"TOTAL_HEADER_LINES = %d\n",num_header_line); // strlen(tempStr) = 32
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write setup file info into file\n");
			return 0;
		}
		// return to the end of the file
		lseek(fctd->Ascii_dataFile.fd,0L,SEEK_END);
	}
	if (head_tail==2)	// tailer
	{
		// for the begining of the run
		if (fctd->Winch.dropNum==0) dn = 1;
		else dn = fctd->Winch.dropNum;
		if(fctd->dropnum4newfile==fctd->Winch.dropNum) sprintf(dropnum,"Winch.dropNum=%lu\n",dn);
		else sprintf(dropnum,"Winch.dropNum=%lu\n",dn-1);

		sprintf(str,"%s%s%s%s%s",startTailer,timeStr,latlon,dropnum,endTailer);
//		if((numBytesWr=fwrite(str,1,strlen(str),fctd->fpData[0].fp))==NULL)
		if((numBytesWr=write(fctd->Ascii_dataFile.fd,str,strlen(str)))==-1)
		{
			fprintf(stderr,"ERROR! Can not write header info into file\n");
			return 0;
		}
		fctd->Ascii_dataFile.totalBytesWrFile += numBytesWr;
	}
	return numBytesWr;
}