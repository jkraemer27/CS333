
_tsli:     file format elf32-i386


Disassembly of section .text:

00000000 <runproc>:

char *psargv[] = { "ps", 0 };

void
runproc(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < 994; i++)
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
   d:	eb 19                	jmp    28 <runproc+0x28>
		printf(1, "%d", n);
   f:	83 ec 04             	sub    $0x4,%esp
  12:	ff 75 08             	pushl  0x8(%ebp)
  15:	68 9b 0e 00 00       	push   $0xe9b
  1a:	6a 01                	push   $0x1
  1c:	e8 be 0a 00 00       	call   adf <printf>
  21:	83 c4 10             	add    $0x10,%esp

void
runproc(int n)
{
	int i;
	for(i = 0; i < 994; i++)
  24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  28:	81 7d f4 e1 03 00 00 	cmpl   $0x3e1,-0xc(%ebp)
  2f:	7e de                	jle    f <runproc+0xf>
		printf(1, "%d", n);
}
  31:	90                   	nop
  32:	c9                   	leave  
  33:	c3                   	ret    

00000034 <schedulertest>:

void
schedulertest()
{
  34:	55                   	push   %ebp
  35:	89 e5                	mov    %esp,%ebp
  37:	83 ec 18             	sub    $0x18,%esp
	int pid;

	printf(1, "+=+=+=+=+=+=+=+=+=\n");
  3a:	83 ec 08             	sub    $0x8,%esp
  3d:	68 9e 0e 00 00       	push   $0xe9e
  42:	6a 01                	push   $0x1
  44:	e8 96 0a 00 00       	call   adf <printf>
  49:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: RR test |\n");
  4c:	83 ec 08             	sub    $0x8,%esp
  4f:	68 b2 0e 00 00       	push   $0xeb2
  54:	6a 01                	push   $0x1
  56:	e8 84 0a 00 00       	call   adf <printf>
  5b:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
  5e:	83 ec 08             	sub    $0x8,%esp
  61:	68 9e 0e 00 00       	push   $0xe9e
  66:	6a 01                	push   $0x1
  68:	e8 72 0a 00 00       	call   adf <printf>
  6d:	83 c4 10             	add    $0x10,%esp
	printf(1, "\nTesting Round Robin...");
  70:	83 ec 08             	sub    $0x8,%esp
  73:	68 c6 0e 00 00       	push   $0xec6
  78:	6a 01                	push   $0x1
  7a:	e8 60 0a 00 00       	call   adf <printf>
  7f:	83 c4 10             	add    $0x10,%esp
	printf(1, "Creating 3 additional running processes...\n");
  82:	83 ec 08             	sub    $0x8,%esp
  85:	68 e0 0e 00 00       	push   $0xee0
  8a:	6a 01                	push   $0x1
  8c:	e8 4e 0a 00 00       	call   adf <printf>
  91:	83 c4 10             	add    $0x10,%esp

	pid = fork();
  94:	e8 7f 08 00 00       	call   918 <fork>
  99:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0){
  9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a0:	75 5c                	jne    fe <schedulertest+0xca>
		pid = fork();
  a2:	e8 71 08 00 00       	call   918 <fork>
  a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(pid == 0){
  aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  ae:	75 37                	jne    e7 <schedulertest+0xb3>
			pid = fork();
  b0:	e8 63 08 00 00       	call   918 <fork>
  b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if(pid == 0){
  b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  bc:	75 12                	jne    d0 <schedulertest+0x9c>
				runproc(4);
  be:	83 ec 0c             	sub    $0xc,%esp
  c1:	6a 04                	push   $0x4
  c3:	e8 38 ff ff ff       	call   0 <runproc>
  c8:	83 c4 10             	add    $0x10,%esp
				exit();
  cb:	e8 50 08 00 00       	call   920 <exit>
			}
			runproc(3);
  d0:	83 ec 0c             	sub    $0xc,%esp
  d3:	6a 03                	push   $0x3
  d5:	e8 26 ff ff ff       	call   0 <runproc>
  da:	83 c4 10             	add    $0x10,%esp
			wait();
  dd:	e8 46 08 00 00       	call   928 <wait>
			exit();
  e2:	e8 39 08 00 00       	call   920 <exit>
		}
		runproc(2);
  e7:	83 ec 0c             	sub    $0xc,%esp
  ea:	6a 02                	push   $0x2
  ec:	e8 0f ff ff ff       	call   0 <runproc>
  f1:	83 c4 10             	add    $0x10,%esp
		wait();
  f4:	e8 2f 08 00 00       	call   928 <wait>
		exit();
  f9:	e8 22 08 00 00       	call   920 <exit>
	}
	runproc(1);
  fe:	83 ec 0c             	sub    $0xc,%esp
 101:	6a 01                	push   $0x1
 103:	e8 f8 fe ff ff       	call   0 <runproc>
 108:	83 c4 10             	add    $0x10,%esp
	wait();
 10b:	e8 18 08 00 00       	call   928 <wait>
	printf(1, "\n\n");
 110:	83 ec 08             	sub    $0x8,%esp
 113:	68 0c 0f 00 00       	push   $0xf0c
 118:	6a 01                	push   $0x1
 11a:	e8 c0 09 00 00       	call   adf <printf>
 11f:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=\n");
 122:	83 ec 08             	sub    $0x8,%esp
 125:	68 0f 0f 00 00       	push   $0xf0f
 12a:	6a 01                	push   $0x1
 12c:	e8 ae 09 00 00       	call   adf <printf>
 131:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: RR test |\n");
 134:	83 ec 08             	sub    $0x8,%esp
 137:	68 21 0f 00 00       	push   $0xf21
 13c:	6a 01                	push   $0x1
 13e:	e8 9c 09 00 00       	call   adf <printf>
 143:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=\n");
 146:	83 ec 08             	sub    $0x8,%esp
 149:	68 0f 0f 00 00       	push   $0xf0f
 14e:	6a 01                	push   $0x1
 150:	e8 8a 09 00 00       	call   adf <printf>
 155:	83 c4 10             	add    $0x10,%esp
}
 158:	90                   	nop
 159:	c9                   	leave  
 15a:	c3                   	ret    

0000015b <freetest>:

void
freetest()
{
 15b:	55                   	push   %ebp
 15c:	89 e5                	mov    %esp,%ebp
 15e:	83 ec 18             	sub    $0x18,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
 161:	83 ec 08             	sub    $0x8,%esp
 164:	68 33 0f 00 00       	push   $0xf33
 169:	6a 01                	push   $0x1
 16b:	e8 6f 09 00 00       	call   adf <printf>
 170:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: free test |\n");
 173:	83 ec 08             	sub    $0x8,%esp
 176:	68 49 0f 00 00       	push   $0xf49
 17b:	6a 01                	push   $0x1
 17d:	e8 5d 09 00 00       	call   adf <printf>
 182:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
 185:	83 ec 08             	sub    $0x8,%esp
 188:	68 33 0f 00 00       	push   $0xf33
 18d:	6a 01                	push   $0x1
 18f:	e8 4b 09 00 00       	call   adf <printf>
 194:	83 c4 10             	add    $0x10,%esp
	printf(1, "Sleeping 5 seconds... call ctrl-f\n");
 197:	83 ec 08             	sub    $0x8,%esp
 19a:	68 60 0f 00 00       	push   $0xf60
 19f:	6a 01                	push   $0x1
 1a1:	e8 39 09 00 00       	call   adf <printf>
 1a6:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 1a9:	83 ec 0c             	sub    $0xc,%esp
 1ac:	68 88 13 00 00       	push   $0x1388
 1b1:	e8 fa 07 00 00       	call   9b0 <sleep>
 1b6:	83 c4 10             	add    $0x10,%esp
	int pid = fork();
 1b9:	e8 5a 07 00 00       	call   918 <fork>
 1be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0){
 1c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c5:	75 15                	jne    1dc <freetest+0x81>
		sleep(5000);
 1c7:	83 ec 0c             	sub    $0xc,%esp
 1ca:	68 88 13 00 00       	push   $0x1388
 1cf:	e8 dc 07 00 00       	call   9b0 <sleep>
 1d4:	83 c4 10             	add    $0x10,%esp
		exit();
 1d7:	e8 44 07 00 00       	call   920 <exit>
	}
	printf(1, "New process made...");
 1dc:	83 ec 08             	sub    $0x8,%esp
 1df:	68 83 0f 00 00       	push   $0xf83
 1e4:	6a 01                	push   $0x1
 1e6:	e8 f4 08 00 00       	call   adf <printf>
 1eb:	83 c4 10             	add    $0x10,%esp
	printf(1, "Sleeping 5 seconds... call ctrl-f\n");
 1ee:	83 ec 08             	sub    $0x8,%esp
 1f1:	68 60 0f 00 00       	push   $0xf60
 1f6:	6a 01                	push   $0x1
 1f8:	e8 e2 08 00 00       	call   adf <printf>
 1fd:	83 c4 10             	add    $0x10,%esp
	wait();
 200:	e8 23 07 00 00       	call   928 <wait>
	printf(1, "Process is done...");
 205:	83 ec 08             	sub    $0x8,%esp
 208:	68 97 0f 00 00       	push   $0xf97
 20d:	6a 01                	push   $0x1
 20f:	e8 cb 08 00 00       	call   adf <printf>
 214:	83 c4 10             	add    $0x10,%esp
	printf(1, "Sleeping 5 seconds... call ctrl-f\n");
 217:	83 ec 08             	sub    $0x8,%esp
 21a:	68 60 0f 00 00       	push   $0xf60
 21f:	6a 01                	push   $0x1
 221:	e8 b9 08 00 00       	call   adf <printf>
 226:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 229:	83 ec 0c             	sub    $0xc,%esp
 22c:	68 88 13 00 00       	push   $0x1388
 231:	e8 7a 07 00 00       	call   9b0 <sleep>
 236:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
 239:	83 ec 08             	sub    $0x8,%esp
 23c:	68 9e 0e 00 00       	push   $0xe9e
 241:	6a 01                	push   $0x1
 243:	e8 97 08 00 00       	call   adf <printf>
 248:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: free test |\n");
 24b:	83 ec 08             	sub    $0x8,%esp
 24e:	68 aa 0f 00 00       	push   $0xfaa
 253:	6a 01                	push   $0x1
 255:	e8 85 08 00 00       	call   adf <printf>
 25a:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
 25d:	83 ec 08             	sub    $0x8,%esp
 260:	68 9e 0e 00 00       	push   $0xe9e
 265:	6a 01                	push   $0x1
 267:	e8 73 08 00 00       	call   adf <printf>
 26c:	83 c4 10             	add    $0x10,%esp
	
}
 26f:	90                   	nop
 270:	c9                   	leave  
 271:	c3                   	ret    

00000272 <sleeptest>:

void
sleeptest()
{
 272:	55                   	push   %ebp
 273:	89 e5                	mov    %esp,%ebp
 275:	83 ec 18             	sub    $0x18,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=+\n");
 278:	83 ec 08             	sub    $0x8,%esp
 27b:	68 be 0f 00 00       	push   $0xfbe
 280:	6a 01                	push   $0x1
 282:	e8 58 08 00 00       	call   adf <printf>
 287:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: sleep test |\n");
 28a:	83 ec 08             	sub    $0x8,%esp
 28d:	68 d5 0f 00 00       	push   $0xfd5
 292:	6a 01                	push   $0x1
 294:	e8 46 08 00 00       	call   adf <printf>
 299:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=+\n");
 29c:	83 ec 08             	sub    $0x8,%esp
 29f:	68 be 0f 00 00       	push   $0xfbe
 2a4:	6a 01                	push   $0x1
 2a6:	e8 34 08 00 00       	call   adf <printf>
 2ab:	83 c4 10             	add    $0x10,%esp
	printf(1, "Sleeping 5 seconds... call ctrl-s\n");
 2ae:	83 ec 08             	sub    $0x8,%esp
 2b1:	68 ec 0f 00 00       	push   $0xfec
 2b6:	6a 01                	push   $0x1
 2b8:	e8 22 08 00 00       	call   adf <printf>
 2bd:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 2c0:	83 ec 0c             	sub    $0xc,%esp
 2c3:	68 88 13 00 00       	push   $0x1388
 2c8:	e8 e3 06 00 00       	call   9b0 <sleep>
 2cd:	83 c4 10             	add    $0x10,%esp
	int pid = fork();
 2d0:	e8 43 06 00 00       	call   918 <fork>
 2d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0)
 2d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2dc:	75 27                	jne    305 <sleeptest+0x93>
	{
		printf(1, "Creating process... Sleeping 5 seconds... call ctrl-s\n");
 2de:	83 ec 08             	sub    $0x8,%esp
 2e1:	68 10 10 00 00       	push   $0x1010
 2e6:	6a 01                	push   $0x1
 2e8:	e8 f2 07 00 00       	call   adf <printf>
 2ed:	83 c4 10             	add    $0x10,%esp
		sleep(5000);
 2f0:	83 ec 0c             	sub    $0xc,%esp
 2f3:	68 88 13 00 00       	push   $0x1388
 2f8:	e8 b3 06 00 00       	call   9b0 <sleep>
 2fd:	83 c4 10             	add    $0x10,%esp
		exit();
 300:	e8 1b 06 00 00       	call   920 <exit>
	}
	wait();
 305:	e8 1e 06 00 00       	call   928 <wait>

	printf(1, "Sleeping 5 seconds... call ctrl-s\n");
 30a:	83 ec 08             	sub    $0x8,%esp
 30d:	68 ec 0f 00 00       	push   $0xfec
 312:	6a 01                	push   $0x1
 314:	e8 c6 07 00 00       	call   adf <printf>
 319:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 31c:	83 ec 0c             	sub    $0xc,%esp
 31f:	68 88 13 00 00       	push   $0x1388
 324:	e8 87 06 00 00       	call   9b0 <sleep>
 329:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+\n");
 32c:	83 ec 08             	sub    $0x8,%esp
 32f:	68 47 10 00 00       	push   $0x1047
 334:	6a 01                	push   $0x1
 336:	e8 a4 07 00 00       	call   adf <printf>
 33b:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: sleep test |\n");
 33e:	83 ec 08             	sub    $0x8,%esp
 341:	68 5c 10 00 00       	push   $0x105c
 346:	6a 01                	push   $0x1
 348:	e8 92 07 00 00       	call   adf <printf>
 34d:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+\n");
 350:	83 ec 08             	sub    $0x8,%esp
 353:	68 47 10 00 00       	push   $0x1047
 358:	6a 01                	push   $0x1
 35a:	e8 80 07 00 00       	call   adf <printf>
 35f:	83 c4 10             	add    $0x10,%esp
}
 362:	90                   	nop
 363:	c9                   	leave  
 364:	c3                   	ret    

00000365 <killtest>:

void
killtest()
{
 365:	55                   	push   %ebp
 366:	89 e5                	mov    %esp,%ebp
 368:	83 ec 18             	sub    $0x18,%esp
	int pid;

	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
 36b:	83 ec 08             	sub    $0x8,%esp
 36e:	68 33 0f 00 00       	push   $0xf33
 373:	6a 01                	push   $0x1
 375:	e8 65 07 00 00       	call   adf <printf>
 37a:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: kill test |\n");
 37d:	83 ec 08             	sub    $0x8,%esp
 380:	68 71 10 00 00       	push   $0x1071
 385:	6a 01                	push   $0x1
 387:	e8 53 07 00 00       	call   adf <printf>
 38c:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=++\n");
 38f:	83 ec 08             	sub    $0x8,%esp
 392:	68 87 10 00 00       	push   $0x1087
 397:	6a 01                	push   $0x1
 399:	e8 41 07 00 00       	call   adf <printf>
 39e:	83 c4 10             	add    $0x10,%esp
	printf(1, "Creating child process with infinite loop...\n");
 3a1:	83 ec 08             	sub    $0x8,%esp
 3a4:	68 a0 10 00 00       	push   $0x10a0
 3a9:	6a 01                	push   $0x1
 3ab:	e8 2f 07 00 00       	call   adf <printf>
 3b0:	83 c4 10             	add    $0x10,%esp
	pid = fork();
 3b3:	e8 60 05 00 00       	call   918 <fork>
 3b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0)
 3bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3bf:	75 02                	jne    3c3 <killtest+0x5e>
		for(;;);
 3c1:	eb fe                	jmp    3c1 <killtest+0x5c>
	kill(pid);
 3c3:	83 ec 0c             	sub    $0xc,%esp
 3c6:	ff 75 f4             	pushl  -0xc(%ebp)
 3c9:	e8 82 05 00 00       	call   950 <kill>
 3ce:	83 c4 10             	add    $0x10,%esp
	printf(1, "Child process killed... Sleeping 5 seconds... call ctrl-z\n");
 3d1:	83 ec 08             	sub    $0x8,%esp
 3d4:	68 d0 10 00 00       	push   $0x10d0
 3d9:	6a 01                	push   $0x1
 3db:	e8 ff 06 00 00       	call   adf <printf>
 3e0:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 3e3:	83 ec 0c             	sub    $0xc,%esp
 3e6:	68 88 13 00 00       	push   $0x1388
 3eb:	e8 c0 05 00 00       	call   9b0 <sleep>
 3f0:	83 c4 10             	add    $0x10,%esp
	wait();
 3f3:	e8 30 05 00 00       	call   928 <wait>
	printf(1, "Wait called... Sleeping 5 seconds... call ctrl-z\n");
 3f8:	83 ec 08             	sub    $0x8,%esp
 3fb:	68 0c 11 00 00       	push   $0x110c
 400:	6a 01                	push   $0x1
 402:	e8 d8 06 00 00       	call   adf <printf>
 407:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 40a:	83 ec 0c             	sub    $0xc,%esp
 40d:	68 88 13 00 00       	push   $0x1388
 412:	e8 99 05 00 00       	call   9b0 <sleep>
 417:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
 41a:	83 ec 08             	sub    $0x8,%esp
 41d:	68 9e 0e 00 00       	push   $0xe9e
 422:	6a 01                	push   $0x1
 424:	e8 b6 06 00 00       	call   adf <printf>
 429:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: kill test |\n");
 42c:	83 ec 08             	sub    $0x8,%esp
 42f:	68 3e 11 00 00       	push   $0x113e
 434:	6a 01                	push   $0x1
 436:	e8 a4 06 00 00       	call   adf <printf>
 43b:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
 43e:	83 ec 08             	sub    $0x8,%esp
 441:	68 9e 0e 00 00       	push   $0xe9e
 446:	6a 01                	push   $0x1
 448:	e8 92 06 00 00       	call   adf <printf>
 44d:	83 c4 10             	add    $0x10,%esp
	
}
 450:	90                   	nop
 451:	c9                   	leave  
 452:	c3                   	ret    

00000453 <zombietest>:

void
zombietest()
{
 453:	55                   	push   %ebp
 454:	89 e5                	mov    %esp,%ebp
 456:	83 ec 18             	sub    $0x18,%esp
	int pid;

	printf(1, "+=+=+=+=+=+=+=+=+=+=+=\n");
 459:	83 ec 08             	sub    $0x8,%esp
 45c:	68 52 11 00 00       	push   $0x1152
 461:	6a 01                	push   $0x1
 463:	e8 77 06 00 00       	call   adf <printf>
 468:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: zombie test |\n");
 46b:	83 ec 08             	sub    $0x8,%esp
 46e:	68 6a 11 00 00       	push   $0x116a
 473:	6a 01                	push   $0x1
 475:	e8 65 06 00 00       	call   adf <printf>
 47a:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=+=\n");
 47d:	83 ec 08             	sub    $0x8,%esp
 480:	68 52 11 00 00       	push   $0x1152
 485:	6a 01                	push   $0x1
 487:	e8 53 06 00 00       	call   adf <printf>
 48c:	83 c4 10             	add    $0x10,%esp
	printf(1, "Creating new process... Sleeping 5 seconds... call ctrl-z\n");
 48f:	83 ec 08             	sub    $0x8,%esp
 492:	68 84 11 00 00       	push   $0x1184
 497:	6a 01                	push   $0x1
 499:	e8 41 06 00 00       	call   adf <printf>
 49e:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 4a1:	83 ec 0c             	sub    $0xc,%esp
 4a4:	68 88 13 00 00       	push   $0x1388
 4a9:	e8 02 05 00 00       	call   9b0 <sleep>
 4ae:	83 c4 10             	add    $0x10,%esp
	pid = fork();
 4b1:	e8 62 04 00 00       	call   918 <fork>
 4b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0)
 4b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4bd:	75 05                	jne    4c4 <zombietest+0x71>
		exit();
 4bf:	e8 5c 04 00 00       	call   920 <exit>

	printf(1, "First zombie should exist... Sleeping 5 seconds... call ctrl-z\n");
 4c4:	83 ec 08             	sub    $0x8,%esp
 4c7:	68 c0 11 00 00       	push   $0x11c0
 4cc:	6a 01                	push   $0x1
 4ce:	e8 0c 06 00 00       	call   adf <printf>
 4d3:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 4d6:	83 ec 0c             	sub    $0xc,%esp
 4d9:	68 88 13 00 00       	push   $0x1388
 4de:	e8 cd 04 00 00       	call   9b0 <sleep>
 4e3:	83 c4 10             	add    $0x10,%esp

	printf(1, "Creating another new process...\n");
 4e6:	83 ec 08             	sub    $0x8,%esp
 4e9:	68 00 12 00 00       	push   $0x1200
 4ee:	6a 01                	push   $0x1
 4f0:	e8 ea 05 00 00       	call   adf <printf>
 4f5:	83 c4 10             	add    $0x10,%esp
	pid = fork();
 4f8:	e8 1b 04 00 00       	call   918 <fork>
 4fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0)
 500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 504:	75 05                	jne    50b <zombietest+0xb8>
		exit();
 506:	e8 15 04 00 00       	call   920 <exit>

	printf(1, "Two zombies should exist... Sleeping 5 seconds... call ctrl-z\n");
 50b:	83 ec 08             	sub    $0x8,%esp
 50e:	68 24 12 00 00       	push   $0x1224
 513:	6a 01                	push   $0x1
 515:	e8 c5 05 00 00       	call   adf <printf>
 51a:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 51d:	83 ec 0c             	sub    $0xc,%esp
 520:	68 88 13 00 00       	push   $0x1388
 525:	e8 86 04 00 00       	call   9b0 <sleep>
 52a:	83 c4 10             	add    $0x10,%esp
	printf(1, "Sleeping 5 seconds... call ctrl-f then ctrl-z\n");
 52d:	83 ec 08             	sub    $0x8,%esp
 530:	68 64 12 00 00       	push   $0x1264
 535:	6a 01                	push   $0x1
 537:	e8 a3 05 00 00       	call   adf <printf>
 53c:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 53f:	83 ec 0c             	sub    $0xc,%esp
 542:	68 88 13 00 00       	push   $0x1388
 547:	e8 64 04 00 00       	call   9b0 <sleep>
 54c:	83 c4 10             	add    $0x10,%esp
	wait();
 54f:	e8 d4 03 00 00       	call   928 <wait>
	printf(1, "Wait called... call ctrl-f then ctrl-z\n");
 554:	83 ec 08             	sub    $0x8,%esp
 557:	68 94 12 00 00       	push   $0x1294
 55c:	6a 01                	push   $0x1
 55e:	e8 7c 05 00 00       	call   adf <printf>
 563:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 566:	83 ec 0c             	sub    $0xc,%esp
 569:	68 88 13 00 00       	push   $0x1388
 56e:	e8 3d 04 00 00       	call   9b0 <sleep>
 573:	83 c4 10             	add    $0x10,%esp
	wait();
 576:	e8 ad 03 00 00       	call   928 <wait>
	printf(1, "Wait called... call ctrl-f then ctrl-z\n");
 57b:	83 ec 08             	sub    $0x8,%esp
 57e:	68 94 12 00 00       	push   $0x1294
 583:	6a 01                	push   $0x1
 585:	e8 55 05 00 00       	call   adf <printf>
 58a:	83 c4 10             	add    $0x10,%esp
	sleep(5000);
 58d:	83 ec 0c             	sub    $0xc,%esp
 590:	68 88 13 00 00       	push   $0x1388
 595:	e8 16 04 00 00       	call   9b0 <sleep>
 59a:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
 59d:	83 ec 08             	sub    $0x8,%esp
 5a0:	68 33 0f 00 00       	push   $0xf33
 5a5:	6a 01                	push   $0x1
 5a7:	e8 33 05 00 00       	call   adf <printf>
 5ac:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: zombie test |\n");
 5af:	83 ec 08             	sub    $0x8,%esp
 5b2:	68 bc 12 00 00       	push   $0x12bc
 5b7:	6a 01                	push   $0x1
 5b9:	e8 21 05 00 00       	call   adf <printf>
 5be:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=+=\n");
 5c1:	83 ec 08             	sub    $0x8,%esp
 5c4:	68 33 0f 00 00       	push   $0xf33
 5c9:	6a 01                	push   $0x1
 5cb:	e8 0f 05 00 00       	call   adf <printf>
 5d0:	83 c4 10             	add    $0x10,%esp
}
 5d3:	90                   	nop
 5d4:	c9                   	leave  
 5d5:	c3                   	ret    

000005d6 <main>:

int
main(int argc, char* argv[])
{
 5d6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 5da:	83 e4 f0             	and    $0xfffffff0,%esp
 5dd:	ff 71 fc             	pushl  -0x4(%ecx)
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	51                   	push   %ecx
 5e4:	83 ec 04             	sub    $0x4,%esp
//	freetest();
//	schedulertest();	
//	sleeptest();
	killtest();
 5e7:	e8 79 fd ff ff       	call   365 <killtest>
	zombietest();
 5ec:	e8 62 fe ff ff       	call   453 <zombietest>

	exit();
 5f1:	e8 2a 03 00 00       	call   920 <exit>

000005f6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5f6:	55                   	push   %ebp
 5f7:	89 e5                	mov    %esp,%ebp
 5f9:	57                   	push   %edi
 5fa:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5fe:	8b 55 10             	mov    0x10(%ebp),%edx
 601:	8b 45 0c             	mov    0xc(%ebp),%eax
 604:	89 cb                	mov    %ecx,%ebx
 606:	89 df                	mov    %ebx,%edi
 608:	89 d1                	mov    %edx,%ecx
 60a:	fc                   	cld    
 60b:	f3 aa                	rep stos %al,%es:(%edi)
 60d:	89 ca                	mov    %ecx,%edx
 60f:	89 fb                	mov    %edi,%ebx
 611:	89 5d 08             	mov    %ebx,0x8(%ebp)
 614:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 617:	90                   	nop
 618:	5b                   	pop    %ebx
 619:	5f                   	pop    %edi
 61a:	5d                   	pop    %ebp
 61b:	c3                   	ret    

0000061c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 61c:	55                   	push   %ebp
 61d:	89 e5                	mov    %esp,%ebp
 61f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 622:	8b 45 08             	mov    0x8(%ebp),%eax
 625:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 628:	90                   	nop
 629:	8b 45 08             	mov    0x8(%ebp),%eax
 62c:	8d 50 01             	lea    0x1(%eax),%edx
 62f:	89 55 08             	mov    %edx,0x8(%ebp)
 632:	8b 55 0c             	mov    0xc(%ebp),%edx
 635:	8d 4a 01             	lea    0x1(%edx),%ecx
 638:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 63b:	0f b6 12             	movzbl (%edx),%edx
 63e:	88 10                	mov    %dl,(%eax)
 640:	0f b6 00             	movzbl (%eax),%eax
 643:	84 c0                	test   %al,%al
 645:	75 e2                	jne    629 <strcpy+0xd>
    ;
  return os;
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 64f:	eb 08                	jmp    659 <strcmp+0xd>
    p++, q++;
 651:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 655:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 659:	8b 45 08             	mov    0x8(%ebp),%eax
 65c:	0f b6 00             	movzbl (%eax),%eax
 65f:	84 c0                	test   %al,%al
 661:	74 10                	je     673 <strcmp+0x27>
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	0f b6 10             	movzbl (%eax),%edx
 669:	8b 45 0c             	mov    0xc(%ebp),%eax
 66c:	0f b6 00             	movzbl (%eax),%eax
 66f:	38 c2                	cmp    %al,%dl
 671:	74 de                	je     651 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	0f b6 00             	movzbl (%eax),%eax
 679:	0f b6 d0             	movzbl %al,%edx
 67c:	8b 45 0c             	mov    0xc(%ebp),%eax
 67f:	0f b6 00             	movzbl (%eax),%eax
 682:	0f b6 c0             	movzbl %al,%eax
 685:	29 c2                	sub    %eax,%edx
 687:	89 d0                	mov    %edx,%eax
}
 689:	5d                   	pop    %ebp
 68a:	c3                   	ret    

0000068b <strlen>:

uint
strlen(char *s)
{
 68b:	55                   	push   %ebp
 68c:	89 e5                	mov    %esp,%ebp
 68e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 691:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 698:	eb 04                	jmp    69e <strlen+0x13>
 69a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 69e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6a1:	8b 45 08             	mov    0x8(%ebp),%eax
 6a4:	01 d0                	add    %edx,%eax
 6a6:	0f b6 00             	movzbl (%eax),%eax
 6a9:	84 c0                	test   %al,%al
 6ab:	75 ed                	jne    69a <strlen+0xf>
    ;
  return n;
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6b0:	c9                   	leave  
 6b1:	c3                   	ret    

000006b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6b2:	55                   	push   %ebp
 6b3:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 6b5:	8b 45 10             	mov    0x10(%ebp),%eax
 6b8:	50                   	push   %eax
 6b9:	ff 75 0c             	pushl  0xc(%ebp)
 6bc:	ff 75 08             	pushl  0x8(%ebp)
 6bf:	e8 32 ff ff ff       	call   5f6 <stosb>
 6c4:	83 c4 0c             	add    $0xc,%esp
  return dst;
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6ca:	c9                   	leave  
 6cb:	c3                   	ret    

000006cc <strchr>:

char*
strchr(const char *s, char c)
{
 6cc:	55                   	push   %ebp
 6cd:	89 e5                	mov    %esp,%ebp
 6cf:	83 ec 04             	sub    $0x4,%esp
 6d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6d8:	eb 14                	jmp    6ee <strchr+0x22>
    if(*s == c)
 6da:	8b 45 08             	mov    0x8(%ebp),%eax
 6dd:	0f b6 00             	movzbl (%eax),%eax
 6e0:	3a 45 fc             	cmp    -0x4(%ebp),%al
 6e3:	75 05                	jne    6ea <strchr+0x1e>
      return (char*)s;
 6e5:	8b 45 08             	mov    0x8(%ebp),%eax
 6e8:	eb 13                	jmp    6fd <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 6ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	0f b6 00             	movzbl (%eax),%eax
 6f4:	84 c0                	test   %al,%al
 6f6:	75 e2                	jne    6da <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 6f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6fd:	c9                   	leave  
 6fe:	c3                   	ret    

000006ff <gets>:

char*
gets(char *buf, int max)
{
 6ff:	55                   	push   %ebp
 700:	89 e5                	mov    %esp,%ebp
 702:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 705:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 70c:	eb 42                	jmp    750 <gets+0x51>
    cc = read(0, &c, 1);
 70e:	83 ec 04             	sub    $0x4,%esp
 711:	6a 01                	push   $0x1
 713:	8d 45 ef             	lea    -0x11(%ebp),%eax
 716:	50                   	push   %eax
 717:	6a 00                	push   $0x0
 719:	e8 1a 02 00 00       	call   938 <read>
 71e:	83 c4 10             	add    $0x10,%esp
 721:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 724:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 728:	7e 33                	jle    75d <gets+0x5e>
      break;
    buf[i++] = c;
 72a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72d:	8d 50 01             	lea    0x1(%eax),%edx
 730:	89 55 f4             	mov    %edx,-0xc(%ebp)
 733:	89 c2                	mov    %eax,%edx
 735:	8b 45 08             	mov    0x8(%ebp),%eax
 738:	01 c2                	add    %eax,%edx
 73a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 73e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 740:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 744:	3c 0a                	cmp    $0xa,%al
 746:	74 16                	je     75e <gets+0x5f>
 748:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 74c:	3c 0d                	cmp    $0xd,%al
 74e:	74 0e                	je     75e <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 750:	8b 45 f4             	mov    -0xc(%ebp),%eax
 753:	83 c0 01             	add    $0x1,%eax
 756:	3b 45 0c             	cmp    0xc(%ebp),%eax
 759:	7c b3                	jl     70e <gets+0xf>
 75b:	eb 01                	jmp    75e <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 75d:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 75e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 761:	8b 45 08             	mov    0x8(%ebp),%eax
 764:	01 d0                	add    %edx,%eax
 766:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 769:	8b 45 08             	mov    0x8(%ebp),%eax
}
 76c:	c9                   	leave  
 76d:	c3                   	ret    

0000076e <stat>:

int
stat(char *n, struct stat *st)
{
 76e:	55                   	push   %ebp
 76f:	89 e5                	mov    %esp,%ebp
 771:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 774:	83 ec 08             	sub    $0x8,%esp
 777:	6a 00                	push   $0x0
 779:	ff 75 08             	pushl  0x8(%ebp)
 77c:	e8 df 01 00 00       	call   960 <open>
 781:	83 c4 10             	add    $0x10,%esp
 784:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 787:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78b:	79 07                	jns    794 <stat+0x26>
    return -1;
 78d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 792:	eb 25                	jmp    7b9 <stat+0x4b>
  r = fstat(fd, st);
 794:	83 ec 08             	sub    $0x8,%esp
 797:	ff 75 0c             	pushl  0xc(%ebp)
 79a:	ff 75 f4             	pushl  -0xc(%ebp)
 79d:	e8 d6 01 00 00       	call   978 <fstat>
 7a2:	83 c4 10             	add    $0x10,%esp
 7a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 7a8:	83 ec 0c             	sub    $0xc,%esp
 7ab:	ff 75 f4             	pushl  -0xc(%ebp)
 7ae:	e8 95 01 00 00       	call   948 <close>
 7b3:	83 c4 10             	add    $0x10,%esp
  return r;
 7b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7b9:	c9                   	leave  
 7ba:	c3                   	ret    

000007bb <atoi>:

int
atoi(const char *s)
{
 7bb:	55                   	push   %ebp
 7bc:	89 e5                	mov    %esp,%ebp
 7be:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 7c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 7c8:	eb 04                	jmp    7ce <atoi+0x13>
 7ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7ce:	8b 45 08             	mov    0x8(%ebp),%eax
 7d1:	0f b6 00             	movzbl (%eax),%eax
 7d4:	3c 20                	cmp    $0x20,%al
 7d6:	74 f2                	je     7ca <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 7d8:	8b 45 08             	mov    0x8(%ebp),%eax
 7db:	0f b6 00             	movzbl (%eax),%eax
 7de:	3c 2d                	cmp    $0x2d,%al
 7e0:	75 07                	jne    7e9 <atoi+0x2e>
 7e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 7e7:	eb 05                	jmp    7ee <atoi+0x33>
 7e9:	b8 01 00 00 00       	mov    $0x1,%eax
 7ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 7f1:	8b 45 08             	mov    0x8(%ebp),%eax
 7f4:	0f b6 00             	movzbl (%eax),%eax
 7f7:	3c 2b                	cmp    $0x2b,%al
 7f9:	74 0a                	je     805 <atoi+0x4a>
 7fb:	8b 45 08             	mov    0x8(%ebp),%eax
 7fe:	0f b6 00             	movzbl (%eax),%eax
 801:	3c 2d                	cmp    $0x2d,%al
 803:	75 2b                	jne    830 <atoi+0x75>
    s++;
 805:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 809:	eb 25                	jmp    830 <atoi+0x75>
    n = n*10 + *s++ - '0';
 80b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 80e:	89 d0                	mov    %edx,%eax
 810:	c1 e0 02             	shl    $0x2,%eax
 813:	01 d0                	add    %edx,%eax
 815:	01 c0                	add    %eax,%eax
 817:	89 c1                	mov    %eax,%ecx
 819:	8b 45 08             	mov    0x8(%ebp),%eax
 81c:	8d 50 01             	lea    0x1(%eax),%edx
 81f:	89 55 08             	mov    %edx,0x8(%ebp)
 822:	0f b6 00             	movzbl (%eax),%eax
 825:	0f be c0             	movsbl %al,%eax
 828:	01 c8                	add    %ecx,%eax
 82a:	83 e8 30             	sub    $0x30,%eax
 82d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 830:	8b 45 08             	mov    0x8(%ebp),%eax
 833:	0f b6 00             	movzbl (%eax),%eax
 836:	3c 2f                	cmp    $0x2f,%al
 838:	7e 0a                	jle    844 <atoi+0x89>
 83a:	8b 45 08             	mov    0x8(%ebp),%eax
 83d:	0f b6 00             	movzbl (%eax),%eax
 840:	3c 39                	cmp    $0x39,%al
 842:	7e c7                	jle    80b <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 844:	8b 45 f8             	mov    -0x8(%ebp),%eax
 847:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 84b:	c9                   	leave  
 84c:	c3                   	ret    

0000084d <atoo>:

int
atoo(const char *s)
{
 84d:	55                   	push   %ebp
 84e:	89 e5                	mov    %esp,%ebp
 850:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 853:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 85a:	eb 04                	jmp    860 <atoo+0x13>
 85c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 860:	8b 45 08             	mov    0x8(%ebp),%eax
 863:	0f b6 00             	movzbl (%eax),%eax
 866:	3c 20                	cmp    $0x20,%al
 868:	74 f2                	je     85c <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 86a:	8b 45 08             	mov    0x8(%ebp),%eax
 86d:	0f b6 00             	movzbl (%eax),%eax
 870:	3c 2d                	cmp    $0x2d,%al
 872:	75 07                	jne    87b <atoo+0x2e>
 874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 879:	eb 05                	jmp    880 <atoo+0x33>
 87b:	b8 01 00 00 00       	mov    $0x1,%eax
 880:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 883:	8b 45 08             	mov    0x8(%ebp),%eax
 886:	0f b6 00             	movzbl (%eax),%eax
 889:	3c 2b                	cmp    $0x2b,%al
 88b:	74 0a                	je     897 <atoo+0x4a>
 88d:	8b 45 08             	mov    0x8(%ebp),%eax
 890:	0f b6 00             	movzbl (%eax),%eax
 893:	3c 2d                	cmp    $0x2d,%al
 895:	75 27                	jne    8be <atoo+0x71>
    s++;
 897:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 89b:	eb 21                	jmp    8be <atoo+0x71>
    n = n*8 + *s++ - '0';
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 8a7:	8b 45 08             	mov    0x8(%ebp),%eax
 8aa:	8d 50 01             	lea    0x1(%eax),%edx
 8ad:	89 55 08             	mov    %edx,0x8(%ebp)
 8b0:	0f b6 00             	movzbl (%eax),%eax
 8b3:	0f be c0             	movsbl %al,%eax
 8b6:	01 c8                	add    %ecx,%eax
 8b8:	83 e8 30             	sub    $0x30,%eax
 8bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 8be:	8b 45 08             	mov    0x8(%ebp),%eax
 8c1:	0f b6 00             	movzbl (%eax),%eax
 8c4:	3c 2f                	cmp    $0x2f,%al
 8c6:	7e 0a                	jle    8d2 <atoo+0x85>
 8c8:	8b 45 08             	mov    0x8(%ebp),%eax
 8cb:	0f b6 00             	movzbl (%eax),%eax
 8ce:	3c 37                	cmp    $0x37,%al
 8d0:	7e cb                	jle    89d <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 8d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d5:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 8d9:	c9                   	leave  
 8da:	c3                   	ret    

000008db <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 8db:	55                   	push   %ebp
 8dc:	89 e5                	mov    %esp,%ebp
 8de:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 8e1:	8b 45 08             	mov    0x8(%ebp),%eax
 8e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 8e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 8ea:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 8ed:	eb 17                	jmp    906 <memmove+0x2b>
    *dst++ = *src++;
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8d 50 01             	lea    0x1(%eax),%edx
 8f5:	89 55 fc             	mov    %edx,-0x4(%ebp)
 8f8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8fb:	8d 4a 01             	lea    0x1(%edx),%ecx
 8fe:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 901:	0f b6 12             	movzbl (%edx),%edx
 904:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 906:	8b 45 10             	mov    0x10(%ebp),%eax
 909:	8d 50 ff             	lea    -0x1(%eax),%edx
 90c:	89 55 10             	mov    %edx,0x10(%ebp)
 90f:	85 c0                	test   %eax,%eax
 911:	7f dc                	jg     8ef <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 913:	8b 45 08             	mov    0x8(%ebp),%eax
}
 916:	c9                   	leave  
 917:	c3                   	ret    

00000918 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 918:	b8 01 00 00 00       	mov    $0x1,%eax
 91d:	cd 40                	int    $0x40
 91f:	c3                   	ret    

00000920 <exit>:
SYSCALL(exit)
 920:	b8 02 00 00 00       	mov    $0x2,%eax
 925:	cd 40                	int    $0x40
 927:	c3                   	ret    

00000928 <wait>:
SYSCALL(wait)
 928:	b8 03 00 00 00       	mov    $0x3,%eax
 92d:	cd 40                	int    $0x40
 92f:	c3                   	ret    

00000930 <pipe>:
SYSCALL(pipe)
 930:	b8 04 00 00 00       	mov    $0x4,%eax
 935:	cd 40                	int    $0x40
 937:	c3                   	ret    

00000938 <read>:
SYSCALL(read)
 938:	b8 05 00 00 00       	mov    $0x5,%eax
 93d:	cd 40                	int    $0x40
 93f:	c3                   	ret    

00000940 <write>:
SYSCALL(write)
 940:	b8 10 00 00 00       	mov    $0x10,%eax
 945:	cd 40                	int    $0x40
 947:	c3                   	ret    

00000948 <close>:
SYSCALL(close)
 948:	b8 15 00 00 00       	mov    $0x15,%eax
 94d:	cd 40                	int    $0x40
 94f:	c3                   	ret    

00000950 <kill>:
SYSCALL(kill)
 950:	b8 06 00 00 00       	mov    $0x6,%eax
 955:	cd 40                	int    $0x40
 957:	c3                   	ret    

00000958 <exec>:
SYSCALL(exec)
 958:	b8 07 00 00 00       	mov    $0x7,%eax
 95d:	cd 40                	int    $0x40
 95f:	c3                   	ret    

00000960 <open>:
SYSCALL(open)
 960:	b8 0f 00 00 00       	mov    $0xf,%eax
 965:	cd 40                	int    $0x40
 967:	c3                   	ret    

00000968 <mknod>:
SYSCALL(mknod)
 968:	b8 11 00 00 00       	mov    $0x11,%eax
 96d:	cd 40                	int    $0x40
 96f:	c3                   	ret    

00000970 <unlink>:
SYSCALL(unlink)
 970:	b8 12 00 00 00       	mov    $0x12,%eax
 975:	cd 40                	int    $0x40
 977:	c3                   	ret    

00000978 <fstat>:
SYSCALL(fstat)
 978:	b8 08 00 00 00       	mov    $0x8,%eax
 97d:	cd 40                	int    $0x40
 97f:	c3                   	ret    

00000980 <link>:
SYSCALL(link)
 980:	b8 13 00 00 00       	mov    $0x13,%eax
 985:	cd 40                	int    $0x40
 987:	c3                   	ret    

00000988 <mkdir>:
SYSCALL(mkdir)
 988:	b8 14 00 00 00       	mov    $0x14,%eax
 98d:	cd 40                	int    $0x40
 98f:	c3                   	ret    

00000990 <chdir>:
SYSCALL(chdir)
 990:	b8 09 00 00 00       	mov    $0x9,%eax
 995:	cd 40                	int    $0x40
 997:	c3                   	ret    

00000998 <dup>:
SYSCALL(dup)
 998:	b8 0a 00 00 00       	mov    $0xa,%eax
 99d:	cd 40                	int    $0x40
 99f:	c3                   	ret    

000009a0 <getpid>:
SYSCALL(getpid)
 9a0:	b8 0b 00 00 00       	mov    $0xb,%eax
 9a5:	cd 40                	int    $0x40
 9a7:	c3                   	ret    

000009a8 <sbrk>:
SYSCALL(sbrk)
 9a8:	b8 0c 00 00 00       	mov    $0xc,%eax
 9ad:	cd 40                	int    $0x40
 9af:	c3                   	ret    

000009b0 <sleep>:
SYSCALL(sleep)
 9b0:	b8 0d 00 00 00       	mov    $0xd,%eax
 9b5:	cd 40                	int    $0x40
 9b7:	c3                   	ret    

000009b8 <uptime>:
SYSCALL(uptime)
 9b8:	b8 0e 00 00 00       	mov    $0xe,%eax
 9bd:	cd 40                	int    $0x40
 9bf:	c3                   	ret    

000009c0 <halt>:
SYSCALL(halt)
 9c0:	b8 16 00 00 00       	mov    $0x16,%eax
 9c5:	cd 40                	int    $0x40
 9c7:	c3                   	ret    

000009c8 <date>:
SYSCALL(date)
 9c8:	b8 17 00 00 00       	mov    $0x17,%eax
 9cd:	cd 40                	int    $0x40
 9cf:	c3                   	ret    

000009d0 <getuid>:
SYSCALL(getuid)
 9d0:	b8 18 00 00 00       	mov    $0x18,%eax
 9d5:	cd 40                	int    $0x40
 9d7:	c3                   	ret    

000009d8 <getgid>:
SYSCALL(getgid)
 9d8:	b8 19 00 00 00       	mov    $0x19,%eax
 9dd:	cd 40                	int    $0x40
 9df:	c3                   	ret    

000009e0 <getppid>:
SYSCALL(getppid)
 9e0:	b8 1a 00 00 00       	mov    $0x1a,%eax
 9e5:	cd 40                	int    $0x40
 9e7:	c3                   	ret    

000009e8 <setuid>:
SYSCALL(setuid)
 9e8:	b8 1b 00 00 00       	mov    $0x1b,%eax
 9ed:	cd 40                	int    $0x40
 9ef:	c3                   	ret    

000009f0 <setgid>:
SYSCALL(setgid)
 9f0:	b8 1c 00 00 00       	mov    $0x1c,%eax
 9f5:	cd 40                	int    $0x40
 9f7:	c3                   	ret    

000009f8 <getprocs>:
SYSCALL(getprocs)
 9f8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 9fd:	cd 40                	int    $0x40
 9ff:	c3                   	ret    

00000a00 <setpriority>:
SYSCALL(setpriority)
 a00:	b8 1b 00 00 00       	mov    $0x1b,%eax
 a05:	cd 40                	int    $0x40
 a07:	c3                   	ret    

00000a08 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 a08:	55                   	push   %ebp
 a09:	89 e5                	mov    %esp,%ebp
 a0b:	83 ec 18             	sub    $0x18,%esp
 a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
 a11:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 a14:	83 ec 04             	sub    $0x4,%esp
 a17:	6a 01                	push   $0x1
 a19:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a1c:	50                   	push   %eax
 a1d:	ff 75 08             	pushl  0x8(%ebp)
 a20:	e8 1b ff ff ff       	call   940 <write>
 a25:	83 c4 10             	add    $0x10,%esp
}
 a28:	90                   	nop
 a29:	c9                   	leave  
 a2a:	c3                   	ret    

00000a2b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a2b:	55                   	push   %ebp
 a2c:	89 e5                	mov    %esp,%ebp
 a2e:	53                   	push   %ebx
 a2f:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a39:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a3d:	74 17                	je     a56 <printint+0x2b>
 a3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a43:	79 11                	jns    a56 <printint+0x2b>
    neg = 1;
 a45:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
 a4f:	f7 d8                	neg    %eax
 a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a54:	eb 06                	jmp    a5c <printint+0x31>
  } else {
    x = xx;
 a56:	8b 45 0c             	mov    0xc(%ebp),%eax
 a59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 a63:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 a66:	8d 41 01             	lea    0x1(%ecx),%eax
 a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
 a6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a72:	ba 00 00 00 00       	mov    $0x0,%edx
 a77:	f7 f3                	div    %ebx
 a79:	89 d0                	mov    %edx,%eax
 a7b:	0f b6 80 0c 16 00 00 	movzbl 0x160c(%eax),%eax
 a82:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
 a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a8c:	ba 00 00 00 00       	mov    $0x0,%edx
 a91:	f7 f3                	div    %ebx
 a93:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a96:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a9a:	75 c7                	jne    a63 <printint+0x38>
  if(neg)
 a9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aa0:	74 2d                	je     acf <printint+0xa4>
    buf[i++] = '-';
 aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa5:	8d 50 01             	lea    0x1(%eax),%edx
 aa8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 aab:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 ab0:	eb 1d                	jmp    acf <printint+0xa4>
    putc(fd, buf[i]);
 ab2:	8d 55 dc             	lea    -0x24(%ebp),%edx
 ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab8:	01 d0                	add    %edx,%eax
 aba:	0f b6 00             	movzbl (%eax),%eax
 abd:	0f be c0             	movsbl %al,%eax
 ac0:	83 ec 08             	sub    $0x8,%esp
 ac3:	50                   	push   %eax
 ac4:	ff 75 08             	pushl  0x8(%ebp)
 ac7:	e8 3c ff ff ff       	call   a08 <putc>
 acc:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 acf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 ad3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad7:	79 d9                	jns    ab2 <printint+0x87>
    putc(fd, buf[i]);
}
 ad9:	90                   	nop
 ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 add:	c9                   	leave  
 ade:	c3                   	ret    

00000adf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 adf:	55                   	push   %ebp
 ae0:	89 e5                	mov    %esp,%ebp
 ae2:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 ae5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 aec:	8d 45 0c             	lea    0xc(%ebp),%eax
 aef:	83 c0 04             	add    $0x4,%eax
 af2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 af5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 afc:	e9 59 01 00 00       	jmp    c5a <printf+0x17b>
    c = fmt[i] & 0xff;
 b01:	8b 55 0c             	mov    0xc(%ebp),%edx
 b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b07:	01 d0                	add    %edx,%eax
 b09:	0f b6 00             	movzbl (%eax),%eax
 b0c:	0f be c0             	movsbl %al,%eax
 b0f:	25 ff 00 00 00       	and    $0xff,%eax
 b14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 b17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b1b:	75 2c                	jne    b49 <printf+0x6a>
      if(c == '%'){
 b1d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b21:	75 0c                	jne    b2f <printf+0x50>
        state = '%';
 b23:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b2a:	e9 27 01 00 00       	jmp    c56 <printf+0x177>
      } else {
        putc(fd, c);
 b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b32:	0f be c0             	movsbl %al,%eax
 b35:	83 ec 08             	sub    $0x8,%esp
 b38:	50                   	push   %eax
 b39:	ff 75 08             	pushl  0x8(%ebp)
 b3c:	e8 c7 fe ff ff       	call   a08 <putc>
 b41:	83 c4 10             	add    $0x10,%esp
 b44:	e9 0d 01 00 00       	jmp    c56 <printf+0x177>
      }
    } else if(state == '%'){
 b49:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b4d:	0f 85 03 01 00 00    	jne    c56 <printf+0x177>
      if(c == 'd'){
 b53:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b57:	75 1e                	jne    b77 <printf+0x98>
        printint(fd, *ap, 10, 1);
 b59:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b5c:	8b 00                	mov    (%eax),%eax
 b5e:	6a 01                	push   $0x1
 b60:	6a 0a                	push   $0xa
 b62:	50                   	push   %eax
 b63:	ff 75 08             	pushl  0x8(%ebp)
 b66:	e8 c0 fe ff ff       	call   a2b <printint>
 b6b:	83 c4 10             	add    $0x10,%esp
        ap++;
 b6e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b72:	e9 d8 00 00 00       	jmp    c4f <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 b77:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 b7b:	74 06                	je     b83 <printf+0xa4>
 b7d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 b81:	75 1e                	jne    ba1 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 b83:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b86:	8b 00                	mov    (%eax),%eax
 b88:	6a 00                	push   $0x0
 b8a:	6a 10                	push   $0x10
 b8c:	50                   	push   %eax
 b8d:	ff 75 08             	pushl  0x8(%ebp)
 b90:	e8 96 fe ff ff       	call   a2b <printint>
 b95:	83 c4 10             	add    $0x10,%esp
        ap++;
 b98:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b9c:	e9 ae 00 00 00       	jmp    c4f <printf+0x170>
      } else if(c == 's'){
 ba1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 ba5:	75 43                	jne    bea <printf+0x10b>
        s = (char*)*ap;
 ba7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 baa:	8b 00                	mov    (%eax),%eax
 bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 baf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 bb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bb7:	75 25                	jne    bde <printf+0xff>
          s = "(null)";
 bb9:	c7 45 f4 d2 12 00 00 	movl   $0x12d2,-0xc(%ebp)
        while(*s != 0){
 bc0:	eb 1c                	jmp    bde <printf+0xff>
          putc(fd, *s);
 bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc5:	0f b6 00             	movzbl (%eax),%eax
 bc8:	0f be c0             	movsbl %al,%eax
 bcb:	83 ec 08             	sub    $0x8,%esp
 bce:	50                   	push   %eax
 bcf:	ff 75 08             	pushl  0x8(%ebp)
 bd2:	e8 31 fe ff ff       	call   a08 <putc>
 bd7:	83 c4 10             	add    $0x10,%esp
          s++;
 bda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be1:	0f b6 00             	movzbl (%eax),%eax
 be4:	84 c0                	test   %al,%al
 be6:	75 da                	jne    bc2 <printf+0xe3>
 be8:	eb 65                	jmp    c4f <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 bea:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 bee:	75 1d                	jne    c0d <printf+0x12e>
        putc(fd, *ap);
 bf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bf3:	8b 00                	mov    (%eax),%eax
 bf5:	0f be c0             	movsbl %al,%eax
 bf8:	83 ec 08             	sub    $0x8,%esp
 bfb:	50                   	push   %eax
 bfc:	ff 75 08             	pushl  0x8(%ebp)
 bff:	e8 04 fe ff ff       	call   a08 <putc>
 c04:	83 c4 10             	add    $0x10,%esp
        ap++;
 c07:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c0b:	eb 42                	jmp    c4f <printf+0x170>
      } else if(c == '%'){
 c0d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 c11:	75 17                	jne    c2a <printf+0x14b>
        putc(fd, c);
 c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c16:	0f be c0             	movsbl %al,%eax
 c19:	83 ec 08             	sub    $0x8,%esp
 c1c:	50                   	push   %eax
 c1d:	ff 75 08             	pushl  0x8(%ebp)
 c20:	e8 e3 fd ff ff       	call   a08 <putc>
 c25:	83 c4 10             	add    $0x10,%esp
 c28:	eb 25                	jmp    c4f <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c2a:	83 ec 08             	sub    $0x8,%esp
 c2d:	6a 25                	push   $0x25
 c2f:	ff 75 08             	pushl  0x8(%ebp)
 c32:	e8 d1 fd ff ff       	call   a08 <putc>
 c37:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 c3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c3d:	0f be c0             	movsbl %al,%eax
 c40:	83 ec 08             	sub    $0x8,%esp
 c43:	50                   	push   %eax
 c44:	ff 75 08             	pushl  0x8(%ebp)
 c47:	e8 bc fd ff ff       	call   a08 <putc>
 c4c:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 c4f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 c56:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
 c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c60:	01 d0                	add    %edx,%eax
 c62:	0f b6 00             	movzbl (%eax),%eax
 c65:	84 c0                	test   %al,%al
 c67:	0f 85 94 fe ff ff    	jne    b01 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 c6d:	90                   	nop
 c6e:	c9                   	leave  
 c6f:	c3                   	ret    

00000c70 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c70:	55                   	push   %ebp
 c71:	89 e5                	mov    %esp,%ebp
 c73:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c76:	8b 45 08             	mov    0x8(%ebp),%eax
 c79:	83 e8 08             	sub    $0x8,%eax
 c7c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c7f:	a1 28 16 00 00       	mov    0x1628,%eax
 c84:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c87:	eb 24                	jmp    cad <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c8c:	8b 00                	mov    (%eax),%eax
 c8e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c91:	77 12                	ja     ca5 <free+0x35>
 c93:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c96:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c99:	77 24                	ja     cbf <free+0x4f>
 c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c9e:	8b 00                	mov    (%eax),%eax
 ca0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ca3:	77 1a                	ja     cbf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ca5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ca8:	8b 00                	mov    (%eax),%eax
 caa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 cad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cb0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cb3:	76 d4                	jbe    c89 <free+0x19>
 cb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cb8:	8b 00                	mov    (%eax),%eax
 cba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cbd:	76 ca                	jbe    c89 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 cbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cc2:	8b 40 04             	mov    0x4(%eax),%eax
 cc5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ccc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ccf:	01 c2                	add    %eax,%edx
 cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cd4:	8b 00                	mov    (%eax),%eax
 cd6:	39 c2                	cmp    %eax,%edx
 cd8:	75 24                	jne    cfe <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 cda:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cdd:	8b 50 04             	mov    0x4(%eax),%edx
 ce0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce3:	8b 00                	mov    (%eax),%eax
 ce5:	8b 40 04             	mov    0x4(%eax),%eax
 ce8:	01 c2                	add    %eax,%edx
 cea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ced:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 cf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cf3:	8b 00                	mov    (%eax),%eax
 cf5:	8b 10                	mov    (%eax),%edx
 cf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cfa:	89 10                	mov    %edx,(%eax)
 cfc:	eb 0a                	jmp    d08 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 cfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d01:	8b 10                	mov    (%eax),%edx
 d03:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d06:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d0b:	8b 40 04             	mov    0x4(%eax),%eax
 d0e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d18:	01 d0                	add    %edx,%eax
 d1a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d1d:	75 20                	jne    d3f <free+0xcf>
    p->s.size += bp->s.size;
 d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d22:	8b 50 04             	mov    0x4(%eax),%edx
 d25:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d28:	8b 40 04             	mov    0x4(%eax),%eax
 d2b:	01 c2                	add    %eax,%edx
 d2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d30:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 d33:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d36:	8b 10                	mov    (%eax),%edx
 d38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d3b:	89 10                	mov    %edx,(%eax)
 d3d:	eb 08                	jmp    d47 <free+0xd7>
  } else
    p->s.ptr = bp;
 d3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d42:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d45:	89 10                	mov    %edx,(%eax)
  freep = p;
 d47:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d4a:	a3 28 16 00 00       	mov    %eax,0x1628
}
 d4f:	90                   	nop
 d50:	c9                   	leave  
 d51:	c3                   	ret    

00000d52 <morecore>:

static Header*
morecore(uint nu)
{
 d52:	55                   	push   %ebp
 d53:	89 e5                	mov    %esp,%ebp
 d55:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d58:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 d5f:	77 07                	ja     d68 <morecore+0x16>
    nu = 4096;
 d61:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 d68:	8b 45 08             	mov    0x8(%ebp),%eax
 d6b:	c1 e0 03             	shl    $0x3,%eax
 d6e:	83 ec 0c             	sub    $0xc,%esp
 d71:	50                   	push   %eax
 d72:	e8 31 fc ff ff       	call   9a8 <sbrk>
 d77:	83 c4 10             	add    $0x10,%esp
 d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 d7d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d81:	75 07                	jne    d8a <morecore+0x38>
    return 0;
 d83:	b8 00 00 00 00       	mov    $0x0,%eax
 d88:	eb 26                	jmp    db0 <morecore+0x5e>
  hp = (Header*)p;
 d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d93:	8b 55 08             	mov    0x8(%ebp),%edx
 d96:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d9c:	83 c0 08             	add    $0x8,%eax
 d9f:	83 ec 0c             	sub    $0xc,%esp
 da2:	50                   	push   %eax
 da3:	e8 c8 fe ff ff       	call   c70 <free>
 da8:	83 c4 10             	add    $0x10,%esp
  return freep;
 dab:	a1 28 16 00 00       	mov    0x1628,%eax
}
 db0:	c9                   	leave  
 db1:	c3                   	ret    

00000db2 <malloc>:

void*
malloc(uint nbytes)
{
 db2:	55                   	push   %ebp
 db3:	89 e5                	mov    %esp,%ebp
 db5:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 db8:	8b 45 08             	mov    0x8(%ebp),%eax
 dbb:	83 c0 07             	add    $0x7,%eax
 dbe:	c1 e8 03             	shr    $0x3,%eax
 dc1:	83 c0 01             	add    $0x1,%eax
 dc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 dc7:	a1 28 16 00 00       	mov    0x1628,%eax
 dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 dcf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 dd3:	75 23                	jne    df8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 dd5:	c7 45 f0 20 16 00 00 	movl   $0x1620,-0x10(%ebp)
 ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ddf:	a3 28 16 00 00       	mov    %eax,0x1628
 de4:	a1 28 16 00 00       	mov    0x1628,%eax
 de9:	a3 20 16 00 00       	mov    %eax,0x1620
    base.s.size = 0;
 dee:	c7 05 24 16 00 00 00 	movl   $0x0,0x1624
 df5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dfb:	8b 00                	mov    (%eax),%eax
 dfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e03:	8b 40 04             	mov    0x4(%eax),%eax
 e06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e09:	72 4d                	jb     e58 <malloc+0xa6>
      if(p->s.size == nunits)
 e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e0e:	8b 40 04             	mov    0x4(%eax),%eax
 e11:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e14:	75 0c                	jne    e22 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e19:	8b 10                	mov    (%eax),%edx
 e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e1e:	89 10                	mov    %edx,(%eax)
 e20:	eb 26                	jmp    e48 <malloc+0x96>
      else {
        p->s.size -= nunits;
 e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e25:	8b 40 04             	mov    0x4(%eax),%eax
 e28:	2b 45 ec             	sub    -0x14(%ebp),%eax
 e2b:	89 c2                	mov    %eax,%edx
 e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e30:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e36:	8b 40 04             	mov    0x4(%eax),%eax
 e39:	c1 e0 03             	shl    $0x3,%eax
 e3c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e42:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e45:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e4b:	a3 28 16 00 00       	mov    %eax,0x1628
      return (void*)(p + 1);
 e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e53:	83 c0 08             	add    $0x8,%eax
 e56:	eb 3b                	jmp    e93 <malloc+0xe1>
    }
    if(p == freep)
 e58:	a1 28 16 00 00       	mov    0x1628,%eax
 e5d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 e60:	75 1e                	jne    e80 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 e62:	83 ec 0c             	sub    $0xc,%esp
 e65:	ff 75 ec             	pushl  -0x14(%ebp)
 e68:	e8 e5 fe ff ff       	call   d52 <morecore>
 e6d:	83 c4 10             	add    $0x10,%esp
 e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
 e73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 e77:	75 07                	jne    e80 <malloc+0xce>
        return 0;
 e79:	b8 00 00 00 00       	mov    $0x0,%eax
 e7e:	eb 13                	jmp    e93 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e89:	8b 00                	mov    (%eax),%eax
 e8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 e8e:	e9 6d ff ff ff       	jmp    e00 <malloc+0x4e>
}
 e93:	c9                   	leave  
 e94:	c3                   	ret    
