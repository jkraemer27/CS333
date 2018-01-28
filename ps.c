#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"
#include "param.h"

int
main(void)
{
  int elapsed, milli, cpue, cpum;

  struct uproc *p = malloc(sizeof(struct uproc) * MAXPROC);
  int processes = getprocs(MAXPROC, p);

  printf(1, "PID     Name    UID	GID	PPID    Elapsed CPU	State   Size\n");


    for(int i = 0; i < processes; ++i)
    {
	if(p[i].elapsed_ticks > 0) 
	{
	    elapsed = p[i].elapsed_ticks/1000;
	    milli = p[i].elapsed_ticks%1000;
	    cpue = p[i].CPU_total_ticks/1000;
	    cpum = p[i].CPU_total_ticks%1000;

	    printf(1, "%d\t%s\t%d\t%d\t%d\t%d.", p[i].pid, p[i].name, p[i].uid, p[i].gid, p[i].ppid, elapsed);

	    if(milli < 10)
		printf(1, "00%d\t%d.", milli, cpue);
	    if(milli > 9 && milli < 100)
		printf(1, "0%d\t%d.", milli, cpue);
	    else
		printf(1, "%d\t%d.", milli, cpue);

	    if(cpum < 10)    
		printf(1, "00%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
	    if(cpum > 9 && cpum < 100)
		printf(1, "0%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
	    else
		printf(1, "%d\t%s\t%d\n", cpum, p[i].state, p[i].size);

	    //printf(1, "%d\t%s\t%d\t%d\t%d\t%d.%d\t%d.%d\t%s\t%d\n", p[i].pid, p[i].name, p[i].uid, p[i].gid, p[i].ppid, elapsed, milli, cpue, cpum, p[i].state, p[i].size);
	}
    }
    printf(1, "\n");

  exit();
}
#endif
