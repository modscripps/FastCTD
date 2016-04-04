/*
 *  TCPIPUtils.h
 *  FastCTD
 *
 *  Created by Mai on 2/4/05.
 *  Copyright 2005 __OPG/MPL__. All rights reserved.
 *
 */
#ifndef TCPIPUTILS_H
#define TCPIPUTILS_H
#import <sys/types.h>   // random types
#import <netinet/in.h>  // for sockaddr_in
#import <sys/socket.h>  // for socket(), AF_INET
#import <arpa/inet.h>   // for inet_ntoa
#import <errno.h>       // for errno
#import <string.h>      // for strerror
#import <stdlib.h>      // for EXIT_SUCCESS
#import <stdio.h>       // for fprintf
#import <unistd.h>      // for close
#import <netdb.h>       // for gethostbyname, h_errno, etc

#include <fcntl.h>
#include <sysexits.h>
#include <CoreFoundation/CoreFoundation.h>

#include <sys/time.h>
#include <pthread.h>
#include <paths.h>
#include <sys/param.h>
#include <IOKit/IOBSD.h>
#include <mach/mach_init.h>
#include <mach/thread_policy.h>
#include <err.h>

#include "Globals.h"

typedef struct TCPDataStruct
{
	struct timeval UnixTime;
	unsigned long timeInHundredsecs;
	char DataStr[MAX_LENGTH];
	Boolean ParseDone;	
	unsigned long dropNum;
}TCPDataStruct, *TCPDataStructPtr;

typedef struct TCPSocketStruct
{
	int portnum;
	char serverName[125];
	int fdTCPIP;
	int remoteSocketfd;
	int doneRead;
	unsigned long PackCnt;		// Read counter from serial port
	unsigned long Write2BufferIndx;		// CTD packet count is written into the circle buffer
	unsigned long ReadBufferIndx;			// CTD packet count is read from the circle buffer
	TCPDataStruct TCPDataCirBuff[MAX_CIRBUFF];
}TCPSocketStruct, *TCPSocketStructPtr;

int writeString (int fd, const void *buffer, size_t length);
int opentcpClient(char hname[]);
int opentcpServer(int port);
int ServerStartListening (int port);

#endif
