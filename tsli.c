#ifdef CS333_P3P4
#include "types.h"
#include "user.h"

//Credit to Jacob Collins who developed this test program and gave me permission to use it
//jmc27@pdx.edu

char *psargv[] = { "ps", 0 };

void
runproc(int n)
{
	int i;
	for(i = 0; i < 994; i++)
		printf(1, "%d", n);
}

void
schedulertest()
{
	int pid;

	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| Start: RR test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	printf(1, "\nTesting Round Robin...");
	printf(1, "Creating 3 additional running processes...\n");

	pid = fork();
	if(pid == 0){
		pid = fork();
		if(pid == 0){
			pid = fork();
			if(pid == 0){
				runproc(4);
				exit();
			}
			runproc(3);
			wait();
			exit();
		}
		runproc(2);
		wait();
		exit();
	}
	runproc(1);
	wait();
	printf(1, "\n\n");
	printf(1, "+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: RR test |\n");
	printf(1, "+=+=+=+=+=+=+=+=\n");
}

void
freetest()
{
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| Start: free test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
	printf(1, "Sleeping 5 seconds... call ctrl-f\n");
	sleep(5000);
	int pid = fork();
	if(pid == 0){
		sleep(5000);
		exit();
	}
	printf(1, "New process made...");
	printf(1, "Sleeping 5 seconds... call ctrl-f\n");
	wait();
	printf(1, "Process is done...");
	printf(1, "Sleeping 5 seconds... call ctrl-f\n");
	sleep(5000);
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: free test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	
}

void
sleeptest()
{
	printf(1, "+=+=+=+=+=+=+=+=+=+=+\n");
	printf(1, "| Start: sleep test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=+=+\n");
	printf(1, "Sleeping 5 seconds... call ctrl-s\n");
	sleep(5000);
	int pid = fork();
	if(pid == 0)
	{
		printf(1, "Creating process... Sleeping 5 seconds... call ctrl-s\n");
		sleep(5000);
		exit();
	}
	wait();

	printf(1, "Sleeping 5 seconds... call ctrl-s\n");
	sleep(5000);
	printf(1, "+=+=+=+=+=+=+=+=+=+\n");
	printf(1, "| End: sleep test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=+\n");
}

void
killtest()
{
	int pid;

	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| Start: kill test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=++\n");
	printf(1, "Creating child process with infinite loop...\n");
	pid = fork();
	if(pid == 0)
		for(;;);
	kill(pid);
	printf(1, "Child process killed... Sleeping 5 seconds... call ctrl-z\n");
	sleep(5000);
	wait();
	printf(1, "Wait called... Sleeping 5 seconds... call ctrl-z\n");
	sleep(5000);
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: kill test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
	
}

void
zombietest()
{
	int pid;

	printf(1, "+=+=+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| Start: zombie test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=+=+=\n");
	printf(1, "Creating new process... Sleeping 5 seconds... call ctrl-z\n");
	sleep(5000);
	pid = fork();
	if(pid == 0)
		exit();

	printf(1, "First zombie should exist... Sleeping 5 seconds... call ctrl-z\n");
	sleep(5000);

	printf(1, "Creating another new process...\n");
	pid = fork();
	if(pid == 0)
		exit();

	printf(1, "Two zombies should exist... Sleeping 5 seconds... call ctrl-z\n");
	sleep(5000);
	printf(1, "Sleeping 5 seconds... call ctrl-f then ctrl-z\n");
	sleep(5000);
	wait();
	printf(1, "Wait called... call ctrl-f then ctrl-z\n");
	sleep(5000);
	wait();
	printf(1, "Wait called... call ctrl-f then ctrl-z\n");
	sleep(5000);
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
	printf(1, "| End: zombie test |\n");
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
}

int
main(int argc, char* argv[])
{
//	freetest();
//	schedulertest();	
//	sleeptest();
	killtest();
	zombietest();

	exit();
}

#endif
