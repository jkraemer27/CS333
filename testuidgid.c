#include "types.h"
#include "user.h"

int
testuidgid(void)
{
    uint uid, gid, ppid;


    uid = getuid();
    printf(2, "Current_UID_is: %d\n\n", uid);

    printf(2, "Setting_UID_to_100\n\n");
    if (setuid(100) < 0)
	printf(2, "Setting_UID_to_100 Failed!!\n\n");
	
    printf(2, "Setting_UID_to_33333\n\n");
    if (setuid(33333) < 0)
	printf(2, "Setting_UID_to_33333 Failed!!\n\n");

    uid = getuid();
    printf(2, "Current_UID_is: %d\n\n", uid);

////////////////

    gid = getgid();
    printf(2, "Current_GID_is: %d\n\n", gid);

    printf(2, "Setting_GID_to_100\n\n");
    if (setgid(100) < 0)
	printf(2, "Setting_GID_to_100 Failed!!\n\n");

    printf(2, "Setting_GID_to_33333\n\n");
    if (setgid(33333) < 0)
	printf(2, "Setting_GID_to_33333 Failed!!\n\n");

    gid = getgid();
    printf(2, "Current_GID_to_100\n\n", gid);

////////////////

    ppid = getppid();
    printf(2, "My_parent_process_is: %d\n\n", ppid);
    printf(2, "Done!\n\n");

    int pid = fork();

    if(pid > 0){
      printf(1, "parent: child=%d\n\n", pid);
      pid = wait();
      printf(1, "child %d is done\n\n", pid);
      ppid = getppid();
      printf(2, "My_parent_process_is: %d\n\n", ppid);
      printf(2, "Done!\n\n");

    }

    exit();
}
