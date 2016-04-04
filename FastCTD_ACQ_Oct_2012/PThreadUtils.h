#ifndef PTHREADUTILS_H
#define PTHREADUTILS_H

#include <mach/mach_init.h>
/*#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>

#include <time.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <mach/thread_policy.h>
#include <err.h>
*/
#include "Globals.h"
#include "FileUtils.h"
#include "SerialPortUtils.h"
#include "FastCat_CTDdaq.h"

#define WARN_TIME 2
#define NUM_THREADS 8   // 8 threads for now: ReadFishCTDdataFromPort(),ReadPCodeDataFromPort(), ReadWinchControl(),
						//						WriteCTDdataIntoFile(), WriteCTDdataViaSerialPort(), CheckDataIsBlocked(), StopFastCTD()
						//                      TCPIPSocketServer();
void FastCTDCreateThreads(pthread_t*, FastCTDStructPtr);
void FastCTDJoinThreads(pthread_t threadList[]);
void *my_thread_function(void *arg);
void *ReadCTDdataFromPort(void *arg);
//void *ReadFishCTDdataFromPort(void *arg);
//void *ReadPCodeDataFromPort(void *arg);
void *WriteCTDdataIntoFile(void *arg);
void *CheckDataIsBlocked(void *arg);
void *StopFastCTD(void *arg);
void *TCPIPSocketServer(void *arg);
// copy from /usrs/include/mach/thread_policy.h since it's commented out in that file
kern_return_t   thread_policy_set(thread_act_t thread,thread_policy_flavor_t flavor, thread_policy_t policy_info, mach_msg_type_number_t count);
int set_realtime(int period, int computation, int constraint);  // MNB Aug 14, 2012

#endif
