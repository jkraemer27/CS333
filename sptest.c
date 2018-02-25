#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
#include "param.h"
//Credit to Jacob Collins who developed this test program and gave me permission to use it
//jmc27@pdx.edu
int generateProc();
void validTest(int pid[], int max);
void invalidTest(int pid[], int max);
void cleanup(int pid[], int max);

int
main(int argc, char* argv[])
{
	int i;
	int max = 4;
	int pid[max];
	
	for(i = 0; i < max; i++)
		pid[i] = generateProc();
	validTest(pid, max);		
	invalidTest(pid, max);
	cleanup(pid, max);

	printf(1, "sptest SUCCESS\n");
	exit();
}

void 
cleanup(int pid[], int max)
{
	int i;
	for(i = 0; i < max; i++)
		kill(pid[i]);
	while(wait() > 0);
}

int
generateProc()
{
	int pid;
	
	pid = fork();
	if(pid == 0)
		while(1);
	printf(1, "Process %d created...\n", pid);

	return pid;
}

void 
validTest(int pid[], int max)
{
	int i, rc;
	int invalid = 0;

	printf(1, "\nTesting valid priorities...\n");
	for(i = 0; i < MAX+1 && invalid != 1; i++) {
		printf(1, "Setting process %d priority to %d... ", pid[0], i);
		rc = setpriority(pid[0], i);
		if(rc < 0) {
			printf(1, "Invalid priority: %d\n", i);
			invalid = 1;
		}
		else if(rc == 0) {
			printf(1, "Invalid PID\n");
			invalid = 1;
		}
		else
			printf(1, "SUCCESS\n");
	}

	if(invalid == 1) {
		printf(1, "setpriority() returned error code... ");
		printf(1, "Valid priorities test FAILED\n");
		printf(1, "sptest FAILED\n");
		cleanup(pid, max);
		exit();
	}
	else if(i != MAX+1) {
		printf(1, "Not all priorities levels checked...  ");
		printf(1, "Valid priorities test FAILED\n");
		printf(1, "sptest FAILED\n");
		cleanup(pid, max);
		exit();
	}
	else
		printf(1, "Valid priorities test SUCCESS\n\n");
}

void
invalidTest(int pid[], int max) 
{
	printf(1, "Testing that setpriority returns failure for invalid priority...\n");
	if(setpriority(pid[0], MAX+2) < 0)
		printf(1, "Invalid priority test SUCCESS\n");
	else {
		printf(1, "Invalid priority test failed\n");
		printf(1, "sptest FAILED\n");
		cleanup(pid, max);
		exit();
	}

	printf(1, "Testing that setpriority returns failure for invalid PID...\n");
	if(setpriority(-1, 0) == 0)
		printf(1, "Invalid PID test SUCCESS\n");
	else {
		printf(1, "Invalid PID test failed\n");
		printf(1, "sptest FAILED\n");
		cleanup(pid, max);
		exit();
	}
}
#endif
