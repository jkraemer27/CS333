#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"
#include "param.h"

int
main(void)
{
  
  struct uproc *p = malloc(sizeof(struct uproc) * MAXPROC);
  getprocs(MAXPROC, p);

  printf(1, "PID    UID	GID PPID    Elapsed CPU	    State   Size    Name\n");

  for(int i = 0; i < MAXPROC; ++i)
  {
    printf(1, "%d\t %d\t %d\t %d\t %d\t %s\t %d\t %s\n", p[i].pid, p[i].uid, p[i].gid, p[i].ppid, p[i].elapsed_ticks, p[i].state, p[i].size, p[i].name);
  }

  exit();
}
#endif
