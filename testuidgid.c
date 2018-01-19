#include "types.h"
#include "user.h"

int
testuidgid(void)
{
    uint uid, gid, ppid;

    uid = getuid();
    printf(2, "Current_UID_is: %d\n", uid);

    printf(2, "Setting_UID_to_100\n");
    setuid(100);
    uid = getuid();
    printf(2, "Current_UID_is: %d\n", uid);

    gid = getgid();
    printf(2, "Current_GID_is: %d\n", gid);
    printf(2, "Setting_GID_to_100\n");
    setgid(100);
    gid = getgid();
    printf(2, "Current_GID_to_100\n", gid);

    ppid = getppid();
    printf(2, "My_parent_process_is: %d\n", ppid);
    printf(2, "Done!\n");

    return 0;

}
