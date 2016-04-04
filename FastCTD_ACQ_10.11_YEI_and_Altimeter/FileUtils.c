/*
	Files Utilities:
	
	- Create new file: CreatNewFile()
	- Create a file name: CreateFileName()
	- CloseCurrFile()
*/ 
#include "FileUtils.h"
#include <unistd.h>
   // FOPEN() access modes
   #define FO_READ      0     // Open for reading (default)
   #define FO_WRITE     1     // Open for writing
   #define FO_READWRITE 2     // Open for read or write

   // FOPEN() sharing modes (combine with open mode using +)
   #define FO_COMPAT    0     // Compatibility (default)
   #define FO_EXCLUSIVE 16    // Exclusive use
   #define FO_DENYWRITE 32    // Prevent others writing
   #define FO_DENYREAD  48    // Prevent others reading
   #define FO_DENYNONE  64    // Allow others to read/write
   #define FO_SHARED    64    // Same as FO_DENYNONE
/*
** Function Name: void CloseCurrFile(Files *fpData)
** Purpose: Close file with the mode read only
*/
void CloseCurrFile(Files *fpData)
{
//	mode_t mode = S_IRUSR | S_IRGRP | S_IROTH;
	// Set the file read only, first: get a FILE*, so that you can flush
    FILE* fid = fdopen(fpData->fd, "a");          // First get a FILE*, so 
    fflush(fid);								  // that you can flush.
    fchmod(fpData->fd, S_IRUSR | S_IRGRP | S_IROTH);

	// close all files
	if (fpData->fd) {
		close(fpData->fd); 
		fpData->fd = -1;
	}
}

/*
** Function Name: void CreateFileName(FilesPtr fpDataPtr)
** Purpose: Create data file with has time when it's created and have 2 type: ascii file and mat file
**          but we have only ascii file for now
*/
void CreateFileName(FilesPtr fpDataPtr)
{
	struct timeval timev, *timevPtr;
	struct tm timeInfo, *timeInfoPtr;
	struct timezone timez, *timezPtr;
	time_t timevalue;

	timevPtr = &timev;
	timezPtr = &timez;
	timeInfoPtr = &timeInfo;

	gettimeofday(timevPtr, timezPtr);
	timevalue = timevPtr->tv_sec;
	timeInfoPtr = localtime(&timevalue);

	// save time of file
	fpDataPtr->fileTime.totalsecs = timevalue;
	fpDataPtr->fileTime.day = timeInfoPtr->tm_mday;
	fpDataPtr->fileTime.month = timeInfoPtr->tm_mon+1;
	fpDataPtr->fileTime.year = (timeInfoPtr->tm_year+1900)%2000;
	fpDataPtr->fileTime.hour = timeInfoPtr->tm_hour;
	fpDataPtr->fileTime.min = timeInfoPtr->tm_min;
	fpDataPtr->fileTime.sec = timeInfoPtr->tm_sec;
	
	// create the name for the file
    switch(fpDataPtr->ftype)
	{
		case 0: // for raw data
			sprintf(fpDataPtr->filename,"%s%s%02d_%02d_%02d_%02d%02d%02d.ascii",fpDataPtr->path,fpDataPtr->runname,fpDataPtr->fileTime.year,fpDataPtr->fileTime.month,fpDataPtr->fileTime.day,fpDataPtr->fileTime.hour,fpDataPtr->fileTime.min,fpDataPtr->fileTime.sec);
		break;
		case 1: // for matlab data
			sprintf(fpDataPtr->filename,"%s%s%02d_%02d_%02d_%02d%02d%02d.mat",fpDataPtr->path,fpDataPtr->runname,fpDataPtr->fileTime.year,fpDataPtr->fileTime.month,fpDataPtr->fileTime.day,fpDataPtr->fileTime.hour,fpDataPtr->fileTime.min,fpDataPtr->fileTime.sec);
		break;
		default:
		break;
	}
}

/*
** Function Name: int CreateNewFile(FilesPtr fpDataPtr)
** Purpose: create file name for writing
*/
int CreateNewFile(FilesPtr fpDataPtr)
{
	int fmode = 0; // for writing

	CreateFileName(fpDataPtr);
//	if ((fpDataPtr->fp = OpenFile(fpDataPtr->filename,fmode))==NULL) return 0;
	if ((fpDataPtr->fd = OpenFile(fpDataPtr->filename,fmode))==-1) return 0;
	//JMK 24 April 2005: Added print statement here so we know file opened:
	fprintf(stdout,"Opening %s\n",fpDataPtr->filename);
	return 1;
}

/*
** Function Name: int Filegets(char *s, int n, FILE *fp)
** Purpose: Get a string from a stream, skipping all C and C++ style comments
*/
int Filegets(char *s, int n, FILE *fp)
{
	int c;
	int i = 0;
	char initStr[MAX_LENGTH] = "\0";

	//  Clear buffer
	memcpy(s,initStr,sizeof(initStr));

	
	//  Skip leading whitespace
	while (((c=Getc_ignoreComm(fp)) != EOF) && isspace(c));
    i = 0;
	// start getting each line
	while ((i < n) && (c != EOF) && (c != '\n')){
		s[i++] = c;
		c = Getc_ignoreComm(fp);
	}
	return(c);
}

/*
** Function Name: unsigned long filesize(FILE* fpIn)
** Purpose: get the size of the file with file pointer is passed in
*/
unsigned long filesize(FILE* fpIn)
{
    unsigned long fs = 0;
    int i;
    while((i=getc(fpIn))!=EOF){
        fs++;
	printf("size = %lu\n",fs);
	}
    return fs;
}

/*
** Function Name: int Getc_ignoreComm(FILE *fp)
** Purpose: 
** Get char from the file, ignore the line start with:
**        1. C-style comment (//) 
**        2. C++ style comment 
**        3. '#' sign
*/
int Getc_ignoreComm(FILE *fp)
{
  int	c1,c2;

  c1 = fgetc(fp);

  if (c1 != '/' && c1 != '#') return(c1);

  if (c1 == '#')
  {
    while ((c1 != EOF) && (c1 != '\n')) c1 = fgetc(fp);
    return(c1);
  }

  if ((c2 = fgetc(fp)) == '*')  // C-style comment
  {		
    do{
      c1 = c2;
      c2 = fgetc(fp);
    }while (!((c1 == '*') && (c2 == '/')) && (c2 != EOF));
    
	if (c2 == EOF) return(EOF);
    c1 = Getc_ignoreComm(fp);
  } 
  else if (c2 == '/')			// C++-sytle comment
  {
    while((c1 != EOF) && (c1 != '\n')) c1 = fgetc(fp);
  }
  else 
    ungetc(c2,fp);
  
  return(c1);
}
/*
** Function Name: int OpenFileInWdir(char *fname, int opt)
** Purpose: open the "fname" file in the working directory
** Description: - input fname: name of the file want to open
**                opt: read (0), write (1), write(2) only for setup file
**              - output: return file descriptor of the file
**   1. Get the current working directory 
*/
int OpenFileInWdir(char *fname, int opt)
{
	char cwd[256], pcwd[256], filename[256];
	char *cwdPtr;
	FILE *fp = NULL;
	int fd = -1;
	
    if ((cwdPtr=getcwd(cwd, 256)) == NULL)
	{
		perror("getcwd() error");
		return 0;
	}
	// get its parent directory
	GetPath(cwd, pcwd);
	// filename = currdir/fname
	sprintf(filename,"%s/%s",cwd,fname);
	if (opt==2)	// for setup file
	{
	   if ((fd = open(filename,O_WRONLY))==-1)
		fprintf(stderr,"Could not open file %s for writing in OpenFileInWdir(): %d - %s\n",filename,errno, strerror(errno));
	}
	else  // for writing data file and reading setup file
	{
	   if ((fd=OpenFile(filename,opt))==-1) printf("Could not open with opt %d\n",opt);
	}
	return fd;
}

/*
** Function Name: int GetPath(char filename[], char* path)
** Purpose: Get the path from the provided filename
*/
void	GetPath(char filename[], char* path)
{
	int val = 0, indx = 0, i=0;
																																																																																
	// get index number of the last character '/' of the filename
	val = strlen(filename);
    for(indx=val-1; indx>=0; indx--)   // get the whole path of object file "playback"
       if (filename[indx] == '/') break;   // get the index of the last '/' of the path

	if (indx < 0)  indx = 0;		// indx<0 when filename = "/nameoffile"
	else{
		// copy the whole path for output file's location, this one only happen when index > 0
		for (i=0; i<=indx; i++)
		   *path++ = filename[i];
		*path = '\0';
	}
}

/*
** Function Name: int OpenFile(char *filename, int rwFlag)
** Purpose: open file for reading or writing
*/
int OpenFile(char *filename, int rwFlag)
{
	int fd;
			// O_WRONLY		   for read and writing
			// O_EXCL          error if create and file exists
	//mode_t wmode = O_RDWR | O_CREAT | O_EXCL | S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
    // JMK 16April05: Fixed permissions (I hope)..
	mode_t wmode = O_RDWR | O_CREAT | O_EXCL;
	mode_t umode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
	//mode_t rmode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR;
	mode_t rmode = O_RDONLY;
	switch(rwFlag)
	{
		case 0:		// for writing
			if((fd = open(filename, wmode))==-1)
			{
				  fprintf(stderr,"Could not open file %s for writing data in OpenFile: %d - %s\n",filename,errno, strerror(errno));
				  return 0;
			}
			//JMK 16 April 2005:
			fchmod(fd,umode);
//			printf("");
		break;
		case 1:		// for reading
			if((fd = open(filename, rmode))==-1)
			{
				  fprintf(stderr,"Could not open file %s for reading data in OpenFile: %d - %s\n",filename,errno, strerror(errno));
				  return 0;
			}
		break;
		default:
		break;
	}
	return fd;
}

