#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
#include "param.h"

int
main(int argc, char ** argv)
{
    int pid, prio;

    if(argc != 3){
	printf(1, "\nInvalid number of arguments, please pass exactly 2\n");
	exit();
    }

    pid  = atoi(argv[1]);
    prio = atoi(argv[2]);

    setpriority(pid, prio);

    exit();

}
#endif

