#ifndef GLOBALS_H
#define GLOBALS_H

//#include <stdlib.h>
//#include <stdio.h>
//#include <CoreFoundation/CoreFoundation.h>

/*
#include <pthread.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <mach/mach_init.h>
#include <mach/thread_policy.h>

#include <err.h>
*/
#include <sys/time.h>

#define MAX_CIRBUFF 1024
#define MAX_LENGTH 1024
//#define CTD_LENGTH 24  // 6(T) + 6(C) + 6(P) + 4(temperature compensation) data and  2(carriage return & line feed)
// SBD 49 FASTCAT, SN: 4933450-0057 - 2/13/04
//#define CTD_LENGTH 68  // 6(T) + 6(C) + 6(P) + 4(temperature compensation) data + 40 chars + 4 checksum and  2(carriage return & line feed)
#define MAX_FILE_SIZE 4000 // maxfsize = 4000;
#define MAXNAMELEN 25
#define pi 3.1415926
#define FILESIZE_LIMIT 100000000	// 100MB

enum Sensors { CTD = 1, PCode, Winch};
//extern time_t offsetTime;

#endif