#ifndef FILEUTILS_H
#define FILEUTILS_H

#include <sys/time.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
//JMK 23 April 2006
#include <errno.h>
#include <string.h>
#include <fcntl.h>	// for open file's mode
#include <sys/types.h>
#include <sys/stat.h>

#include "Globals.h"


typedef struct TimeStruct
{
	long totalsecs;	// from Jan 1, 1970
	int day;
	int month;
	int year;
	int hour;
	int min;
	int sec;
}TimeStruct, *TimeStructPtr;

typedef struct Files
{
	FILE *fp;
	int fd;
	char path[225];
	char runname[25];
	char filename[225];
	ssize_t totalBytesWrFile;
	ssize_t dataFileSize;
	struct TimeStruct fileTime;
	int ftype;
}Files, *FilesPtr;

void 	CloseCurrFile(Files*);
void	CreateFileName(FilesPtr);
int		CreateNewFile(FilesPtr);
int		Filegets(char *s, int n, FILE *fp);
int		Getc_ignoreComm(FILE *);
void	GetPath(char [],char*);
int		OpenFile(char *, int);
int		OpenFileInWdir(char *fname, int);

#endif