#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;

    cprintf("Implement this");
}
int
sys_sleep(void)
{
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
}
#ifdef CS333_P1
int
sys_date(void)
{
    struct rtcdate *d;
   
    if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
	return -1;

    cmostime(d);
    return 0;
}
#endif

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
  uint xticks;
  
  xticks = ticks;
  return xticks;
}

//Turn of the computer
int
sys_halt(void){
  cprintf("Shutting down ...\n");
  outw( 0x604, 0x0 | 0x2000);
  return 0;
}

#ifdef CS333_P2
int 
sys_getuid(void)
{
    return proc -> uid;
}

int 
sys_getgid(void)
{
    return proc -> gid;
}

int 
sys_getppid(void)
{
    if(proc -> parent)
	return proc -> parent -> pid;
    else
	return 1;
}

int 
sys_setuid(void)
{
    int uid;

    if(argint(0, &uid) < 0)
	return -1;
    if(uid > 32767 || uid < 0)
	return -1;
    else
	return proc -> uid = uid;
}

int 
sys_setgid(void)
{
    int gid;

    if(argint(0, &gid) < 0)
	return -1;
    if(gid > 32767 || gid < 0)
	return -1;
    else
	return proc -> gid = gid;
}

int
sys_getprocs(void)
{
    int num;
    struct uproc *procarray;

    if(argint(0, &num) < 0)
	return -1;
    
    if(argptr(1, (void*)&procarray, sizeof(struct uproc)) < 0)
	return -1;

   getproctable(num, procarray);
   return 1;
}
#endif
#ifdef CS333_P3P4
int
sys_setpriority(void)
{
    int pid, prio;

    if(argint(0, &pid) < 0)
	return -1;

    if(argint(1, &prio) < 0)
	return -1;
    
    if(prio < 0 || prio > MAX){
	cprintf("\nPriority: %d out of bounds, enter a value between 0 and %d\n", prio, MAX);
	return -2;
    }
	
    if(pid < 1){
	cprintf("\nInvalid PID\n");
	return -3;
    }

    setpriority(pid, prio);

    return 1;
}
#endif

