#define NPROC		    64  // maximum number of processes
#define KSTACKSIZE	    4096  // size of per-process kernel stack
#define NCPU		    8  // maximum number of CPUs
#define NOFILE		    16  // open files per process
#define NFILE		    100  // open files per system
#define NINODE		    50  // maximum number of active i-nodes
#define NDEV		    10  // maximum major device number
#define ROOTDEV		    1  // device number of file system root disk
#define MAXARG		    32  // max exec arguments
#define MAXOPBLOCKS	    10  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
// #define FSSIZE       1000  // size of file system in blocks
#define FSSIZE		    2000  // size of file system in blocks  // CS333 requires a larger FS.
#define UIDGID		    0   // initial value of UID and GID set to 0 - being used for processes 
				// and files created by mkfs when the file system is created
#define MAXPROC		    16  //max num of processes
#define MAX		    4  //Maximum priority of a process in the ready list
#define TICKS_TO_PROMOTE    5000 //number of CPU ticks before a process priority is promoted 
#define BUDGET		    5000 // a process's tick budget before moving down a queue
#define MODE		    0755  //default mode in decimal converted from octal 0755 to decimal is 493
