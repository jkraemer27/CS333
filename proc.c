#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "uproc.h"


#ifdef CS333_P3P4
struct StateLists {
  struct proc* ready;
  struct proc* free;
  struct proc* sleep;
  struct proc* zombie;
  struct proc* running;
  struct proc* embryo;
};
#endif

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
#ifdef CS333_P3P4
  struct StateLists pLists;
#endif
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

#ifdef CS333_P3P4
//helper functions go here

static void
assertStateFree(struct proc* p);

static void
assertStateZombie(struct proc* p);

static void
assertStateEmbryo(struct proc* p);

static void
assertStateRunning(struct proc* p);

static void
assertStateSleep(struct proc* p);

static void
assertStateReady(struct proc* p);

static int
addToStateListEnd(struct proc** sList, struct proc* p);

static void
assertStateFree(struct proc* p){
    if(p -> state != UNUSED)
	panic("Process not in an UNUSED state");
}
static void
assertStateZombie(struct proc* p){
    if(p -> state != ZOMBIE)
	panic("Process not in a ZOMBIE state");
}
static void
assertStateEmbryo(struct proc* p){
    if(p -> state != EMBRYO)
	panic("Process not in a EMBRYO state");
}
static void
assertStateRunning(struct proc* p){
    if(p -> state != RUNNING)
	panic("Process not in a RUNNING state");
}
static void
assertStateSleep(struct proc* p){
    if(p -> state != SLEEPING)
	panic("Process not in a SLEEPING state");
}
static void
assertStateReady(struct proc* p){
    if(p -> state != RUNNABLE)
	panic("Process not in a RUNNABLE state");
}


static int
addToStateListEnd(struct proc** sList, struct proc* p){

    struct proc *current = *sList;

    if(!current){
	current = p;
	p -> next = 0;
	return 0;
    }

    while(current -> next)
	current = current -> next;
    
    current -> next = p;

    p -> next = 0;

    return 0;
}

static int
addToStateListHead(struct proc** sList, struct proc* p){

    struct proc *temp = *sList;
    p -> next = temp;
    *sList = p;

    return 0;
}

static int
removeFromStateList(struct proc** sList, struct proc* p){
    if(!sList)
	return -1;

    struct proc *current = *sList;
    struct proc *previous = *sList;

    while(current){
	if(p == current)
	    break;
	previous = current;
	current = current -> next;
    }
    if(!current)
	return -1;

    previous -> next = current -> next;
    p -> next = 0;

    return 0;

}

#endif

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
//test
//test2

static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
#ifdef CS333_P3P4

  assertStateFree(p);
  removeFromStateList(&ptable.pLists.free, p);
  addToStateListEnd(&ptable.pLists.embryo, p);

#endif 
  p->state = EMBRYO;

  p->pid = nextpid++;
  release(&ptable.lock);
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){

#ifdef CS333_P3P4

  acquire(&ptable.lock);

  assertStateZombie(p);

  removeFromStateList(&ptable.pLists.zombie, p);

  addToStateListHead(&ptable.pLists.free, p);

  release(&ptable.lock);

#endif
    p->state = UNUSED;


    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;
  #ifdef CS333_P1
  p->start_ticks = ticks;
  #endif
  #ifdef CS333_P2
  p -> cpu_ticks_total = 0;
  p -> cpu_ticks_in = 0;
  #endif
  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  #ifdef CS333_P3P4
  
  ptable.pLists.ready = 0;
  ptable.pLists.free = 0;
  ptable.pLists.sleep = 0;
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  acquire(&ptable.lock);
  for(int i = 0; i < NPROC; i++){
    addToStateListHead(&ptable.pLists.free, &ptable.proc[i]);
  }
  release(&ptable.lock);

  #endif

  p = allocproc();

  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

#ifdef CS333_P3P4
  acquire(&ptable.lock);

  assertStateEmbryo(p);
  removeFromStateList(&ptable.pLists.embryo, p);
  addToStateListEnd(&ptable.pLists.ready, p);
  
  release(&ptable.lock);
  #endif
  p->state = RUNNABLE;



}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;

#ifdef CS333_P3P4

  acquire(&ptable.lock);

  assertStateZombie(np);

  removeFromStateList(&ptable.pLists.zombie, np);

  addToStateListHead(&ptable.pLists.free, np);

  release(&ptable.lock);

#endif
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

    #ifdef CS333_P2
    np -> uid = proc -> uid;
    np -> gid = proc -> gid;
    #endif

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);

#ifdef CS333_P3P4

  assertStateEmbryo(np);

  removeFromStateList(&ptable.pLists.embryo, np);

  addToStateListHead(&ptable.pLists.free, np);

#endif
  np->state = RUNNABLE;
  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#else
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  #ifdef CS333_P3P4

  assertStateRunning(p);

  removeFromStateList(&ptable.pLists.running, p);

  addToStateListHead(&ptable.pLists.zombie, p);

  #endif
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#endif

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#else
int
wait(void)
{

  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);

	#ifdef CS333_P3P4

	assertStateZombie(p);

	removeFromStateList(&ptable.pLists.zombie, p);

	addToStateListHead(&ptable.pLists.free, p);

	#endif

        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#endif

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);


      p->state = RUNNING;
      #ifdef CS333_P2
      p->cpu_ticks_in = ticks;
      #endif
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}

#else
void
scheduler(void)
{
    struct proc *p;
      int idle;  // for checking if processor is idle

      for(;;){
	// Enable interrupts on this processor.
	sti();

	idle = 1;  // assume idle unless we schedule a process
	// Loop over process table looking for process to run.
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	  if(p->state != RUNNABLE)
	    continue;

	  // Switch to chosen process.  It is the process's job
	  // to release ptable.lock and then reacquire it
	  // before jumping back to us.
	  idle = 0;  // not idle this timeslice
	  proc = p;
	  switchuvm(p);

	  #ifdef CS333_P3P4

	  assertStateReady(p);

	  removeFromStateList(&ptable.pLists.ready, p);

	  addToStateListHead(&ptable.pLists.running, p);

	  #endif

	  p->state = RUNNING;
	  #ifdef CS333_P2
	  p->cpu_ticks_in = ticks;
	  #endif
	  swtch(&cpu->scheduler, proc->context);
	  switchkvm();

	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
	}
	release(&ptable.lock);
	// if idle, wait for next interrupt
	if (idle) {
	  sti();
	  hlt();
	}
      }
}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
#ifndef CS333_P3P4
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
    #ifdef CS333_P2
    proc -> cpu_ticks_total += (ticks - proc -> cpu_ticks_in);
    #endif
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;


}
#else
void
sched(void)
{
    int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
    #ifdef CS333_P2
    proc -> cpu_ticks_total += (ticks - proc -> cpu_ticks_in);
    #endif
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;

}
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock

  #ifdef CS333_P3P4

  assertStateRunning(proc);

  removeFromStateList(&ptable.pLists.running, proc);

  addToStateListHead(&ptable.pLists.ready, proc);

  #endif
  proc->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
    acquire(&ptable.lock);
    if (lk) release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  #ifdef CS333_P3P4

  assertStateRunning(proc);

  removeFromStateList(&ptable.pLists.running, proc);

  addToStateListHead(&ptable.pLists.sleep, proc);

  #endif
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
    release(&ptable.lock);
    if (lk) acquire(lk);
  }
}

//PAGEBREAK!
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan){
      #ifdef CS333_P3P4

      assertStateSleep(p);

      removeFromStateList(&ptable.pLists.sleep, p);

      addToStateListHead(&ptable.pLists.ready, p);

      #endif

      p->state = RUNNABLE;
    }
}
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
#else
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING){
	#ifdef CS333_P3P4

	assertStateSleep(p);

	removeFromStateList(&ptable.pLists.sleep, p);

	addToStateListHead(&ptable.pLists.ready, p);

	#endif
        p->state = RUNNABLE;
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
#endif

static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
};

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  int i, elapsed, milli, cpue, cpum;
  struct proc *p;
  char *state = "???";
  uint pc[10];
  
    //#ifdef CS333_P1
    //cprintf("PID      State   Name    Elapsed         PCs test\n");
    //#endif

    #ifdef CS333_P2
    cprintf("PID	Name    UID	GID	PPID    Elapsed	CPU	State   Size     PCs\n");
    #endif


    acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];

    //#ifdef CS333_P1
    //elapsed = ticks - p -> start_ticks;
    //cprintf("%d\t %s\t %s\t %d\t\t", p -> pid, state, p -> name , elapsed, "\n");
    //#else
    //cprintf("%d %s %s", p->pid, state, p->name);
    //cprintf("\n");
    //#endif

    #ifdef CS333_P2
    elapsed = (ticks - p -> start_ticks)/1000;
    milli = (ticks - p -> start_ticks)%1000;
    cpue = (p -> cpu_ticks_total)/1000;
    cpum = (p -> cpu_ticks_total)%1000;

    if(p -> pid == 1){
	cprintf("%d\t%s\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,1,  elapsed);
	if(milli < 10)
	    cprintf("00%d\t%d.", milli, cpue);
	if(milli > 9 && milli < 100)
	    cprintf("0%d\t%d.", milli, cpue);
	else
	    cprintf("%d\t%d.", milli, cpue);

	if(cpum < 10)
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
	if(cpum > 9 && cpum < 100)
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
	else
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
	}
    else{
	cprintf("%d\t%s\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid,  elapsed);
	if(milli < 10)
	    cprintf("00%d\t%d.", milli, cpue);
	if(milli > 9 && milli < 100)
	    cprintf("0%d\t%d.", milli, cpue);
	else
	    cprintf("%d\t%d.", milli, cpue);

	if(cpum < 10)
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
	if(cpum > 9 && cpum < 100)
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
	else
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
	}

    //cprintf("%d\t%s\t%d\t%d\t%d\t%d.%d\t%d.%d\t%s\t%d\t", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid,  elapsed, milli,cpue,cpum, state, p->sz, "\n");

    #endif


    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

    cprintf("\n");
    release(&ptable.lock);
}
#ifdef CS333_P2
int 
getproctable(uint max, struct uproc* table)
{
    int i = 0;
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);

 // for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
 for(i = 0; i < max; ++i)
 {
     p = &ptable.proc[i];
    if(p -> state == RUNNABLE || p -> state == SLEEPING || p -> state == RUNNING)
    {
	/*
	cprintf("%d\n", table[i].pid);

	cprintf("%d\n", table[i].uid);

	cprintf("%d\n", table[i].gid);*/
	
	table[i].pid = p -> pid;
	table[i].uid = p -> uid;
	table[i].gid = p -> gid;

	if(p -> pid == 1)
	    table[i].ppid = 1;
	else
	    table[i].ppid = p -> parent -> pid;
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);

	table[i].CPU_total_ticks = p -> cpu_ticks_total;

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );

	table[i].size = p -> sz;

	safestrcpy(table[i].name,p -> name, STRMAX);

     }
   }
    //release lock
    release(&ptable.lock);
    return i;
}
#endif
