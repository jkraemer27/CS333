#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
#include "param.h"
//Credit to Jacob Collins who developed this test program and gave me permission to use it
//jmc27@pdx.edu
void test1();
void test2();
void test3();
void test4();
void test5();
void test6();
void cleanupProcs(int pid[], int max);
void sleepMessage(int time, char message[]);
int createInfiniteProc();
int createSetPrioProc(int prio);

const int plevels = MAX;
const int budget = BUDGET;
const int promo = TICKS_TO_PROMOTE;


int
main(int argc, char* argv[])
{
	int i;
	int test_num = argc - 1;
	void (*test[])() = {test1, test2, test3, test4, test5, test6};

	if(test_num == 0) {
		printf(1, "correct usage: p4test <test_num>\n");
		exit();
	}

	printf(1, "p4test starting with: MAX = %d, DEFAULT_BUDGET = %d, TICKS_TO_PROMOTE = %d\n\n", plevels, budget, promo);

	for(i = 1; i <= test_num; i++) 
		(*test[atoi(argv[i])-1])();

	exit();
}

void
test1()
{
	printf(1, "+=+=+=+=+=+=+=+=+\n");
	printf(1, "| Start: Test 1 |\n");
	printf(1, "+=+=+=+=+=+=+=+=+\n");
	int i;
	int max = 8;
	int pid[max];

	for(i = 0; i < max; i++)
		pid[i] = createInfiniteProc();

	for(i = 0; i < 3; i++)
		sleepMessage(5000, "Sleeping... ctrl-p\n");

	cleanupProcs(pid, max);
	printf(1, "+=+=+=+=+=+=+=+\n");
	printf(1, "| End: Test 1 |\n");
	printf(1, "+=+=+=+=+=+=+=+\n");
}

void 
test2()
{
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| Start: Test 2a |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	int i, start_time, elapsed_time;
	int pid[2];
	pid[0]  = createInfiniteProc();

	setpriority(getpid(), plevels);
	start_time = uptime();

	i = 0;
	while(i <= plevels) {
		elapsed_time = uptime() - start_time;
		if(elapsed_time % promo-100 == 0) {
			sleepMessage(promo/2, "Sleeping... ctrl-p\n");
			i++;
		}
	}

	printf(1, "+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: Test 2a |\n");
	printf(1, "+=+=+=+=+=+=+=+=\n");
	printf(1, "\n");
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| Start: Test 2b |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=\n");

	pid[1] = createSetPrioProc(0);
	setpriority(pid[0], plevels);
	start_time = uptime();

	i = 0;
	while(i <= plevels) {
		elapsed_time = uptime() - start_time;
		if(elapsed_time % promo-100 == 0) {
			sleepMessage(promo-100, "Sleeping... ctrl-p\n");
			i++;
		}
	}
	
	cleanupProcs(pid, 2);
	
	printf(1, "+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: Test 2b |\n");
	printf(1, "+=+=+=+=+=+=+=+=\n");
}

void 
test3()
{
	printf(1, "+=+=+=+=+=+=+=+=+\n");
	printf(1, "| Start: Test 3 |\n");
	printf(1, "+=+=+=+=+=+=+=+=+\n");

	int i;
	int max = 8;
	int pid[max];

	for(i = 0; i < max; i++) 
		pid[i] = createInfiniteProc();
	
	for(i = 0; i <= plevels; i++) 
		sleepMessage((budget*max)/2, "Sleeping... ctrl-p OR ctrl-r\n");
	
	cleanupProcs(pid, max);

	printf(1, "+=+=+=+=+=+=+=+\n");
	printf(1, "| End: Test 3 |\n");
	printf(1, "+=+=+=+=+=+=+=+\n");

}

void 
test4()
{
	if(plevels == 0) {
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 6a |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 2) {
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 4a |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 6) {
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 5a |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}

	int i;	
	int max = 10;
	int pid[max];

	for(i = 0; i < max/2; i++)
		pid[i] = createSetPrioProc(plevels);
	for(i = max/2; i < max; i++)
		pid[i] = createSetPrioProc(0);

	for(i = 0; i < 2; i++)
		sleepMessage(6000, "Sleeping... ctrl-p\n");

	cleanupProcs(pid, max);

	if(plevels == 0) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 6a |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 2) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 4a |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 6) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 5a |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
	}
}

void
test6()
{
	if(plevels == 0) {
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 6b |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 2) {
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 4b |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 6) {
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 5b |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}

	int i;
	int max = 8;
	int pid[max];

	for(i = 0; i < max/2; i++)
		pid[i] = createInfiniteProc();

	for(i = 0; i <= plevels; i++)
		sleepMessage(2000, "Sleeping... ctrl-p OR ctrl-r\n");
	if(plevels == 0)
		sleepMessage(2000, "Sleeping... ctrl-p OR ctrl-r\n");

	if(plevels == 0) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 6b |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 6c |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 2) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 4b |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 4c |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 6) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 5b |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 5c |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}

	for(i = max/2; i < max; i++)
		pid[i] = createInfiniteProc();
	
	for(i = 0; i <= plevels+1; i++)
		sleepMessage(1500, "Sleeping... ctrl-p OR ctrl-r\n");

	cleanupProcs(pid, max);

	if(plevels == 0) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 6c |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 2) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 4c |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
	}
	else if(plevels == 6) {
		printf(1, "+=+=+=+=+=+=+=+=\n");
		printf(1, "| End: Test 5c |\n");
		printf(1, "+=+=+=+=+=+=+=+=\n");
	}
	
}

void
test5()
{
	printf(1, "+=+=+=+=+=+=+=+=+\n");
	printf(1, "| Start: Test 5 |\n");
	printf(1, "+=+=+=+=+=+=+=+=+\n");

	int i, prio;
	int max = 10;
	int pid[max];
	
	for(i = 0; i < max; i++) {
		prio = i%(plevels+1);
		pid[i] = createSetPrioProc(prio);
		printf(1, "Process %d will be at priority level %d\n", pid[i], prio); 
	}

	sleepMessage(5000, "Sleeping... ctrl-p\n");
	sleepMessage(5000, "Sleeping... ctrl-r\n");

	printf(1, "+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: Test 5 |\n");
	printf(1, "+=+=+=+=+=+=+=+=\n");
}

void
sleepMessage(int time, char message[])
{
	printf(1, message);
	sleep(time);
}

int
createInfiniteProc()
{
	int pid = fork();
	if(pid == 0)
		while(1);
	printf(1, "Process %d created...\n", pid);

	return pid;
}

int 
createSetPrioProc(int prio)
{
	int pid = fork();
	if(pid == 0) 
		while(1)
			setpriority(getpid(), prio);

	return pid;
}

void 
cleanupProcs(int pid[], int max)
{
	int i;
	for(i = 0; i < max; i++)
		kill(pid[i]);
	while(wait() > 0);
}

#endif
