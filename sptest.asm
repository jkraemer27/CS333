
_sptest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
void invalidTest(int pid[], int max);
void cleanup(int pid[], int max);

int
main(int argc, char* argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
	int i;
	int max = 4;
  11:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
	int pid[max];
  18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1b:	8d 50 ff             	lea    -0x1(%eax),%edx
  1e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  21:	c1 e0 02             	shl    $0x2,%eax
  24:	8d 50 03             	lea    0x3(%eax),%edx
  27:	b8 10 00 00 00       	mov    $0x10,%eax
  2c:	83 e8 01             	sub    $0x1,%eax
  2f:	01 d0                	add    %edx,%eax
  31:	b9 10 00 00 00       	mov    $0x10,%ecx
  36:	ba 00 00 00 00       	mov    $0x0,%edx
  3b:	f7 f1                	div    %ecx
  3d:	6b c0 10             	imul   $0x10,%eax,%eax
  40:	29 c4                	sub    %eax,%esp
  42:	89 e0                	mov    %esp,%eax
  44:	83 c0 03             	add    $0x3,%eax
  47:	c1 e8 02             	shr    $0x2,%eax
  4a:	c1 e0 02             	shl    $0x2,%eax
  4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	
	for(i = 0; i < max; i++)
  50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  57:	eb 14                	jmp    6d <main+0x6d>
		pid[i] = generateProc();
  59:	e8 a9 00 00 00       	call   107 <generateProc>
  5e:	89 c1                	mov    %eax,%ecx
  60:	8b 45 e8             	mov    -0x18(%ebp),%eax
  63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  66:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
{
	int i;
	int max = 4;
	int pid[max];
	
	for(i = 0; i < max; i++)
  69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  70:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  73:	7c e4                	jl     59 <main+0x59>
		pid[i] = generateProc();
	validTest(pid, max);		
  75:	8b 45 e8             	mov    -0x18(%ebp),%eax
  78:	83 ec 08             	sub    $0x8,%esp
  7b:	ff 75 f0             	pushl  -0x10(%ebp)
  7e:	50                   	push   %eax
  7f:	e8 b3 00 00 00       	call   137 <validTest>
  84:	83 c4 10             	add    $0x10,%esp
	invalidTest(pid, max);
  87:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8a:	83 ec 08             	sub    $0x8,%esp
  8d:	ff 75 f0             	pushl  -0x10(%ebp)
  90:	50                   	push   %eax
  91:	e8 1f 02 00 00       	call   2b5 <invalidTest>
  96:	83 c4 10             	add    $0x10,%esp
	cleanup(pid, max);
  99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  9c:	83 ec 08             	sub    $0x8,%esp
  9f:	ff 75 f0             	pushl  -0x10(%ebp)
  a2:	50                   	push   %eax
  a3:	e8 1a 00 00 00       	call   c2 <cleanup>
  a8:	83 c4 10             	add    $0x10,%esp

	printf(1, "sptest SUCCESS\n");
  ab:	83 ec 08             	sub    $0x8,%esp
  ae:	68 48 0c 00 00       	push   $0xc48
  b3:	6a 01                	push   $0x1
  b5:	e8 d6 07 00 00       	call   890 <printf>
  ba:	83 c4 10             	add    $0x10,%esp
	exit();
  bd:	e8 0f 06 00 00       	call   6d1 <exit>

000000c2 <cleanup>:
}

void 
cleanup(int pid[], int max)
{
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < max; i++)
  c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  cf:	eb 21                	jmp    f2 <cleanup+0x30>
		kill(pid[i]);
  d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  db:	8b 45 08             	mov    0x8(%ebp),%eax
  de:	01 d0                	add    %edx,%eax
  e0:	8b 00                	mov    (%eax),%eax
  e2:	83 ec 0c             	sub    $0xc,%esp
  e5:	50                   	push   %eax
  e6:	e8 16 06 00 00       	call   701 <kill>
  eb:	83 c4 10             	add    $0x10,%esp

void 
cleanup(int pid[], int max)
{
	int i;
	for(i = 0; i < max; i++)
  ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  f8:	7c d7                	jl     d1 <cleanup+0xf>
		kill(pid[i]);
	while(wait() > 0);
  fa:	90                   	nop
  fb:	e8 d9 05 00 00       	call   6d9 <wait>
 100:	85 c0                	test   %eax,%eax
 102:	7f f7                	jg     fb <cleanup+0x39>
}
 104:	90                   	nop
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <generateProc>:

int
generateProc()
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 18             	sub    $0x18,%esp
	int pid;
	
	pid = fork();
 10d:	e8 b7 05 00 00       	call   6c9 <fork>
 112:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0)
 115:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 119:	75 02                	jne    11d <generateProc+0x16>
		while(1);
 11b:	eb fe                	jmp    11b <generateProc+0x14>
	printf(1, "Process %d created...\n", pid);
 11d:	83 ec 04             	sub    $0x4,%esp
 120:	ff 75 f4             	pushl  -0xc(%ebp)
 123:	68 58 0c 00 00       	push   $0xc58
 128:	6a 01                	push   $0x1
 12a:	e8 61 07 00 00       	call   890 <printf>
 12f:	83 c4 10             	add    $0x10,%esp

	return pid;
 132:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 135:	c9                   	leave  
 136:	c3                   	ret    

00000137 <validTest>:

void 
validTest(int pid[], int max)
{
 137:	55                   	push   %ebp
 138:	89 e5                	mov    %esp,%ebp
 13a:	83 ec 18             	sub    $0x18,%esp
	int i, rc;
	int invalid = 0;
 13d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	printf(1, "\nTesting valid priorities...\n");
 144:	83 ec 08             	sub    $0x8,%esp
 147:	68 6f 0c 00 00       	push   $0xc6f
 14c:	6a 01                	push   $0x1
 14e:	e8 3d 07 00 00       	call   890 <printf>
 153:	83 c4 10             	add    $0x10,%esp
	for(i = 0; i < MAX+1 && invalid != 1; i++) {
 156:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 15d:	e9 8a 00 00 00       	jmp    1ec <validTest+0xb5>
		printf(1, "Setting process %d priority to %d... ", pid[0], i);
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	8b 00                	mov    (%eax),%eax
 167:	ff 75 f4             	pushl  -0xc(%ebp)
 16a:	50                   	push   %eax
 16b:	68 90 0c 00 00       	push   $0xc90
 170:	6a 01                	push   $0x1
 172:	e8 19 07 00 00       	call   890 <printf>
 177:	83 c4 10             	add    $0x10,%esp
		rc = setpriority(pid[0], i);
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	8b 00                	mov    (%eax),%eax
 17f:	83 ec 08             	sub    $0x8,%esp
 182:	ff 75 f4             	pushl  -0xc(%ebp)
 185:	50                   	push   %eax
 186:	e8 26 06 00 00       	call   7b1 <setpriority>
 18b:	83 c4 10             	add    $0x10,%esp
 18e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(rc < 0) {
 191:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 195:	79 1e                	jns    1b5 <validTest+0x7e>
			printf(1, "Invalid priority: %d\n", i);
 197:	83 ec 04             	sub    $0x4,%esp
 19a:	ff 75 f4             	pushl  -0xc(%ebp)
 19d:	68 b6 0c 00 00       	push   $0xcb6
 1a2:	6a 01                	push   $0x1
 1a4:	e8 e7 06 00 00       	call   890 <printf>
 1a9:	83 c4 10             	add    $0x10,%esp
			invalid = 1;
 1ac:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 1b3:	eb 33                	jmp    1e8 <validTest+0xb1>
		}
		else if(rc == 0) {
 1b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1b9:	75 1b                	jne    1d6 <validTest+0x9f>
			printf(1, "Invalid PID\n");
 1bb:	83 ec 08             	sub    $0x8,%esp
 1be:	68 cc 0c 00 00       	push   $0xccc
 1c3:	6a 01                	push   $0x1
 1c5:	e8 c6 06 00 00       	call   890 <printf>
 1ca:	83 c4 10             	add    $0x10,%esp
			invalid = 1;
 1cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 1d4:	eb 12                	jmp    1e8 <validTest+0xb1>
		}
		else
			printf(1, "SUCCESS\n");
 1d6:	83 ec 08             	sub    $0x8,%esp
 1d9:	68 d9 0c 00 00       	push   $0xcd9
 1de:	6a 01                	push   $0x1
 1e0:	e8 ab 06 00 00       	call   890 <printf>
 1e5:	83 c4 10             	add    $0x10,%esp
{
	int i, rc;
	int invalid = 0;

	printf(1, "\nTesting valid priorities...\n");
	for(i = 0; i < MAX+1 && invalid != 1; i++) {
 1e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1ec:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 1f0:	7f 0a                	jg     1fc <validTest+0xc5>
 1f2:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
 1f6:	0f 85 66 ff ff ff    	jne    162 <validTest+0x2b>
		}
		else
			printf(1, "SUCCESS\n");
	}

	if(invalid == 1) {
 1fc:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
 200:	75 4c                	jne    24e <validTest+0x117>
		printf(1, "setpriority() returned error code... ");
 202:	83 ec 08             	sub    $0x8,%esp
 205:	68 e4 0c 00 00       	push   $0xce4
 20a:	6a 01                	push   $0x1
 20c:	e8 7f 06 00 00       	call   890 <printf>
 211:	83 c4 10             	add    $0x10,%esp
		printf(1, "Valid priorities test FAILED\n");
 214:	83 ec 08             	sub    $0x8,%esp
 217:	68 0a 0d 00 00       	push   $0xd0a
 21c:	6a 01                	push   $0x1
 21e:	e8 6d 06 00 00       	call   890 <printf>
 223:	83 c4 10             	add    $0x10,%esp
		printf(1, "sptest FAILED\n");
 226:	83 ec 08             	sub    $0x8,%esp
 229:	68 28 0d 00 00       	push   $0xd28
 22e:	6a 01                	push   $0x1
 230:	e8 5b 06 00 00       	call   890 <printf>
 235:	83 c4 10             	add    $0x10,%esp
		cleanup(pid, max);
 238:	83 ec 08             	sub    $0x8,%esp
 23b:	ff 75 0c             	pushl  0xc(%ebp)
 23e:	ff 75 08             	pushl  0x8(%ebp)
 241:	e8 7c fe ff ff       	call   c2 <cleanup>
 246:	83 c4 10             	add    $0x10,%esp
		exit();
 249:	e8 83 04 00 00       	call   6d1 <exit>
	}
	else if(i != MAX+1) {
 24e:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
 252:	74 4c                	je     2a0 <validTest+0x169>
		printf(1, "Not all priorities levels checked...  ");
 254:	83 ec 08             	sub    $0x8,%esp
 257:	68 38 0d 00 00       	push   $0xd38
 25c:	6a 01                	push   $0x1
 25e:	e8 2d 06 00 00       	call   890 <printf>
 263:	83 c4 10             	add    $0x10,%esp
		printf(1, "Valid priorities test FAILED\n");
 266:	83 ec 08             	sub    $0x8,%esp
 269:	68 0a 0d 00 00       	push   $0xd0a
 26e:	6a 01                	push   $0x1
 270:	e8 1b 06 00 00       	call   890 <printf>
 275:	83 c4 10             	add    $0x10,%esp
		printf(1, "sptest FAILED\n");
 278:	83 ec 08             	sub    $0x8,%esp
 27b:	68 28 0d 00 00       	push   $0xd28
 280:	6a 01                	push   $0x1
 282:	e8 09 06 00 00       	call   890 <printf>
 287:	83 c4 10             	add    $0x10,%esp
		cleanup(pid, max);
 28a:	83 ec 08             	sub    $0x8,%esp
 28d:	ff 75 0c             	pushl  0xc(%ebp)
 290:	ff 75 08             	pushl  0x8(%ebp)
 293:	e8 2a fe ff ff       	call   c2 <cleanup>
 298:	83 c4 10             	add    $0x10,%esp
		exit();
 29b:	e8 31 04 00 00       	call   6d1 <exit>
	}
	else
		printf(1, "Valid priorities test SUCCESS\n\n");
 2a0:	83 ec 08             	sub    $0x8,%esp
 2a3:	68 60 0d 00 00       	push   $0xd60
 2a8:	6a 01                	push   $0x1
 2aa:	e8 e1 05 00 00       	call   890 <printf>
 2af:	83 c4 10             	add    $0x10,%esp
}
 2b2:	90                   	nop
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <invalidTest>:

void
invalidTest(int pid[], int max) 
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	83 ec 08             	sub    $0x8,%esp
	printf(1, "Testing that setpriority returns failure for invalid priority...\n");
 2bb:	83 ec 08             	sub    $0x8,%esp
 2be:	68 80 0d 00 00       	push   $0xd80
 2c3:	6a 01                	push   $0x1
 2c5:	e8 c6 05 00 00       	call   890 <printf>
 2ca:	83 c4 10             	add    $0x10,%esp
	if(setpriority(pid[0], MAX+2) < 0)
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	8b 00                	mov    (%eax),%eax
 2d2:	83 ec 08             	sub    $0x8,%esp
 2d5:	6a 06                	push   $0x6
 2d7:	50                   	push   %eax
 2d8:	e8 d4 04 00 00       	call   7b1 <setpriority>
 2dd:	83 c4 10             	add    $0x10,%esp
 2e0:	85 c0                	test   %eax,%eax
 2e2:	79 39                	jns    31d <invalidTest+0x68>
		printf(1, "Invalid priority test SUCCESS\n");
 2e4:	83 ec 08             	sub    $0x8,%esp
 2e7:	68 c4 0d 00 00       	push   $0xdc4
 2ec:	6a 01                	push   $0x1
 2ee:	e8 9d 05 00 00       	call   890 <printf>
 2f3:	83 c4 10             	add    $0x10,%esp
		printf(1, "sptest FAILED\n");
		cleanup(pid, max);
		exit();
	}

	printf(1, "Testing that setpriority returns failure for invalid PID...\n");
 2f6:	83 ec 08             	sub    $0x8,%esp
 2f9:	68 04 0e 00 00       	push   $0xe04
 2fe:	6a 01                	push   $0x1
 300:	e8 8b 05 00 00       	call   890 <printf>
 305:	83 c4 10             	add    $0x10,%esp
	if(setpriority(-1, 0) == 0)
 308:	83 ec 08             	sub    $0x8,%esp
 30b:	6a 00                	push   $0x0
 30d:	6a ff                	push   $0xffffffff
 30f:	e8 9d 04 00 00       	call   7b1 <setpriority>
 314:	83 c4 10             	add    $0x10,%esp
 317:	85 c0                	test   %eax,%eax
 319:	75 50                	jne    36b <invalidTest+0xb6>
 31b:	eb 3a                	jmp    357 <invalidTest+0xa2>
{
	printf(1, "Testing that setpriority returns failure for invalid priority...\n");
	if(setpriority(pid[0], MAX+2) < 0)
		printf(1, "Invalid priority test SUCCESS\n");
	else {
		printf(1, "Invalid priority test failed\n");
 31d:	83 ec 08             	sub    $0x8,%esp
 320:	68 e3 0d 00 00       	push   $0xde3
 325:	6a 01                	push   $0x1
 327:	e8 64 05 00 00       	call   890 <printf>
 32c:	83 c4 10             	add    $0x10,%esp
		printf(1, "sptest FAILED\n");
 32f:	83 ec 08             	sub    $0x8,%esp
 332:	68 28 0d 00 00       	push   $0xd28
 337:	6a 01                	push   $0x1
 339:	e8 52 05 00 00       	call   890 <printf>
 33e:	83 c4 10             	add    $0x10,%esp
		cleanup(pid, max);
 341:	83 ec 08             	sub    $0x8,%esp
 344:	ff 75 0c             	pushl  0xc(%ebp)
 347:	ff 75 08             	pushl  0x8(%ebp)
 34a:	e8 73 fd ff ff       	call   c2 <cleanup>
 34f:	83 c4 10             	add    $0x10,%esp
		exit();
 352:	e8 7a 03 00 00       	call   6d1 <exit>
	}

	printf(1, "Testing that setpriority returns failure for invalid PID...\n");
	if(setpriority(-1, 0) == 0)
		printf(1, "Invalid PID test SUCCESS\n");
 357:	83 ec 08             	sub    $0x8,%esp
 35a:	68 41 0e 00 00       	push   $0xe41
 35f:	6a 01                	push   $0x1
 361:	e8 2a 05 00 00       	call   890 <printf>
 366:	83 c4 10             	add    $0x10,%esp
		printf(1, "Invalid PID test failed\n");
		printf(1, "sptest FAILED\n");
		cleanup(pid, max);
		exit();
	}
}
 369:	eb 3a                	jmp    3a5 <invalidTest+0xf0>

	printf(1, "Testing that setpriority returns failure for invalid PID...\n");
	if(setpriority(-1, 0) == 0)
		printf(1, "Invalid PID test SUCCESS\n");
	else {
		printf(1, "Invalid PID test failed\n");
 36b:	83 ec 08             	sub    $0x8,%esp
 36e:	68 5b 0e 00 00       	push   $0xe5b
 373:	6a 01                	push   $0x1
 375:	e8 16 05 00 00       	call   890 <printf>
 37a:	83 c4 10             	add    $0x10,%esp
		printf(1, "sptest FAILED\n");
 37d:	83 ec 08             	sub    $0x8,%esp
 380:	68 28 0d 00 00       	push   $0xd28
 385:	6a 01                	push   $0x1
 387:	e8 04 05 00 00       	call   890 <printf>
 38c:	83 c4 10             	add    $0x10,%esp
		cleanup(pid, max);
 38f:	83 ec 08             	sub    $0x8,%esp
 392:	ff 75 0c             	pushl  0xc(%ebp)
 395:	ff 75 08             	pushl  0x8(%ebp)
 398:	e8 25 fd ff ff       	call   c2 <cleanup>
 39d:	83 c4 10             	add    $0x10,%esp
		exit();
 3a0:	e8 2c 03 00 00       	call   6d1 <exit>
	}
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	57                   	push   %edi
 3ab:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3af:	8b 55 10             	mov    0x10(%ebp),%edx
 3b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b5:	89 cb                	mov    %ecx,%ebx
 3b7:	89 df                	mov    %ebx,%edi
 3b9:	89 d1                	mov    %edx,%ecx
 3bb:	fc                   	cld    
 3bc:	f3 aa                	rep stos %al,%es:(%edi)
 3be:	89 ca                	mov    %ecx,%edx
 3c0:	89 fb                	mov    %edi,%ebx
 3c2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3c5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3c8:	90                   	nop
 3c9:	5b                   	pop    %ebx
 3ca:	5f                   	pop    %edi
 3cb:	5d                   	pop    %ebp
 3cc:	c3                   	ret    

000003cd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3cd:	55                   	push   %ebp
 3ce:	89 e5                	mov    %esp,%ebp
 3d0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3d9:	90                   	nop
 3da:	8b 45 08             	mov    0x8(%ebp),%eax
 3dd:	8d 50 01             	lea    0x1(%eax),%edx
 3e0:	89 55 08             	mov    %edx,0x8(%ebp)
 3e3:	8b 55 0c             	mov    0xc(%ebp),%edx
 3e6:	8d 4a 01             	lea    0x1(%edx),%ecx
 3e9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 3ec:	0f b6 12             	movzbl (%edx),%edx
 3ef:	88 10                	mov    %dl,(%eax)
 3f1:	0f b6 00             	movzbl (%eax),%eax
 3f4:	84 c0                	test   %al,%al
 3f6:	75 e2                	jne    3da <strcpy+0xd>
    ;
  return os;
 3f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3fb:	c9                   	leave  
 3fc:	c3                   	ret    

000003fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3fd:	55                   	push   %ebp
 3fe:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 400:	eb 08                	jmp    40a <strcmp+0xd>
    p++, q++;
 402:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 406:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 40a:	8b 45 08             	mov    0x8(%ebp),%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	84 c0                	test   %al,%al
 412:	74 10                	je     424 <strcmp+0x27>
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	0f b6 10             	movzbl (%eax),%edx
 41a:	8b 45 0c             	mov    0xc(%ebp),%eax
 41d:	0f b6 00             	movzbl (%eax),%eax
 420:	38 c2                	cmp    %al,%dl
 422:	74 de                	je     402 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	0f b6 00             	movzbl (%eax),%eax
 42a:	0f b6 d0             	movzbl %al,%edx
 42d:	8b 45 0c             	mov    0xc(%ebp),%eax
 430:	0f b6 00             	movzbl (%eax),%eax
 433:	0f b6 c0             	movzbl %al,%eax
 436:	29 c2                	sub    %eax,%edx
 438:	89 d0                	mov    %edx,%eax
}
 43a:	5d                   	pop    %ebp
 43b:	c3                   	ret    

0000043c <strlen>:

uint
strlen(char *s)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
 43f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 442:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 449:	eb 04                	jmp    44f <strlen+0x13>
 44b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 44f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 452:	8b 45 08             	mov    0x8(%ebp),%eax
 455:	01 d0                	add    %edx,%eax
 457:	0f b6 00             	movzbl (%eax),%eax
 45a:	84 c0                	test   %al,%al
 45c:	75 ed                	jne    44b <strlen+0xf>
    ;
  return n;
 45e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 461:	c9                   	leave  
 462:	c3                   	ret    

00000463 <memset>:

void*
memset(void *dst, int c, uint n)
{
 463:	55                   	push   %ebp
 464:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 466:	8b 45 10             	mov    0x10(%ebp),%eax
 469:	50                   	push   %eax
 46a:	ff 75 0c             	pushl  0xc(%ebp)
 46d:	ff 75 08             	pushl  0x8(%ebp)
 470:	e8 32 ff ff ff       	call   3a7 <stosb>
 475:	83 c4 0c             	add    $0xc,%esp
  return dst;
 478:	8b 45 08             	mov    0x8(%ebp),%eax
}
 47b:	c9                   	leave  
 47c:	c3                   	ret    

0000047d <strchr>:

char*
strchr(const char *s, char c)
{
 47d:	55                   	push   %ebp
 47e:	89 e5                	mov    %esp,%ebp
 480:	83 ec 04             	sub    $0x4,%esp
 483:	8b 45 0c             	mov    0xc(%ebp),%eax
 486:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 489:	eb 14                	jmp    49f <strchr+0x22>
    if(*s == c)
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	0f b6 00             	movzbl (%eax),%eax
 491:	3a 45 fc             	cmp    -0x4(%ebp),%al
 494:	75 05                	jne    49b <strchr+0x1e>
      return (char*)s;
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	eb 13                	jmp    4ae <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 49b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 49f:	8b 45 08             	mov    0x8(%ebp),%eax
 4a2:	0f b6 00             	movzbl (%eax),%eax
 4a5:	84 c0                	test   %al,%al
 4a7:	75 e2                	jne    48b <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 4a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4ae:	c9                   	leave  
 4af:	c3                   	ret    

000004b0 <gets>:

char*
gets(char *buf, int max)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4bd:	eb 42                	jmp    501 <gets+0x51>
    cc = read(0, &c, 1);
 4bf:	83 ec 04             	sub    $0x4,%esp
 4c2:	6a 01                	push   $0x1
 4c4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4c7:	50                   	push   %eax
 4c8:	6a 00                	push   $0x0
 4ca:	e8 1a 02 00 00       	call   6e9 <read>
 4cf:	83 c4 10             	add    $0x10,%esp
 4d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4d9:	7e 33                	jle    50e <gets+0x5e>
      break;
    buf[i++] = c;
 4db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4de:	8d 50 01             	lea    0x1(%eax),%edx
 4e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4e4:	89 c2                	mov    %eax,%edx
 4e6:	8b 45 08             	mov    0x8(%ebp),%eax
 4e9:	01 c2                	add    %eax,%edx
 4eb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ef:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4f1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4f5:	3c 0a                	cmp    $0xa,%al
 4f7:	74 16                	je     50f <gets+0x5f>
 4f9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4fd:	3c 0d                	cmp    $0xd,%al
 4ff:	74 0e                	je     50f <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 501:	8b 45 f4             	mov    -0xc(%ebp),%eax
 504:	83 c0 01             	add    $0x1,%eax
 507:	3b 45 0c             	cmp    0xc(%ebp),%eax
 50a:	7c b3                	jl     4bf <gets+0xf>
 50c:	eb 01                	jmp    50f <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 50e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 50f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	01 d0                	add    %edx,%eax
 517:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 51a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 51d:	c9                   	leave  
 51e:	c3                   	ret    

0000051f <stat>:

int
stat(char *n, struct stat *st)
{
 51f:	55                   	push   %ebp
 520:	89 e5                	mov    %esp,%ebp
 522:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 525:	83 ec 08             	sub    $0x8,%esp
 528:	6a 00                	push   $0x0
 52a:	ff 75 08             	pushl  0x8(%ebp)
 52d:	e8 df 01 00 00       	call   711 <open>
 532:	83 c4 10             	add    $0x10,%esp
 535:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 538:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53c:	79 07                	jns    545 <stat+0x26>
    return -1;
 53e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 543:	eb 25                	jmp    56a <stat+0x4b>
  r = fstat(fd, st);
 545:	83 ec 08             	sub    $0x8,%esp
 548:	ff 75 0c             	pushl  0xc(%ebp)
 54b:	ff 75 f4             	pushl  -0xc(%ebp)
 54e:	e8 d6 01 00 00       	call   729 <fstat>
 553:	83 c4 10             	add    $0x10,%esp
 556:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 559:	83 ec 0c             	sub    $0xc,%esp
 55c:	ff 75 f4             	pushl  -0xc(%ebp)
 55f:	e8 95 01 00 00       	call   6f9 <close>
 564:	83 c4 10             	add    $0x10,%esp
  return r;
 567:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 56a:	c9                   	leave  
 56b:	c3                   	ret    

0000056c <atoi>:

int
atoi(const char *s)
{
 56c:	55                   	push   %ebp
 56d:	89 e5                	mov    %esp,%ebp
 56f:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 572:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 579:	eb 04                	jmp    57f <atoi+0x13>
 57b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 57f:	8b 45 08             	mov    0x8(%ebp),%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	3c 20                	cmp    $0x20,%al
 587:	74 f2                	je     57b <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 589:	8b 45 08             	mov    0x8(%ebp),%eax
 58c:	0f b6 00             	movzbl (%eax),%eax
 58f:	3c 2d                	cmp    $0x2d,%al
 591:	75 07                	jne    59a <atoi+0x2e>
 593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 598:	eb 05                	jmp    59f <atoi+0x33>
 59a:	b8 01 00 00 00       	mov    $0x1,%eax
 59f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
 5a5:	0f b6 00             	movzbl (%eax),%eax
 5a8:	3c 2b                	cmp    $0x2b,%al
 5aa:	74 0a                	je     5b6 <atoi+0x4a>
 5ac:	8b 45 08             	mov    0x8(%ebp),%eax
 5af:	0f b6 00             	movzbl (%eax),%eax
 5b2:	3c 2d                	cmp    $0x2d,%al
 5b4:	75 2b                	jne    5e1 <atoi+0x75>
    s++;
 5b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 5ba:	eb 25                	jmp    5e1 <atoi+0x75>
    n = n*10 + *s++ - '0';
 5bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5bf:	89 d0                	mov    %edx,%eax
 5c1:	c1 e0 02             	shl    $0x2,%eax
 5c4:	01 d0                	add    %edx,%eax
 5c6:	01 c0                	add    %eax,%eax
 5c8:	89 c1                	mov    %eax,%ecx
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	8d 50 01             	lea    0x1(%eax),%edx
 5d0:	89 55 08             	mov    %edx,0x8(%ebp)
 5d3:	0f b6 00             	movzbl (%eax),%eax
 5d6:	0f be c0             	movsbl %al,%eax
 5d9:	01 c8                	add    %ecx,%eax
 5db:	83 e8 30             	sub    $0x30,%eax
 5de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 5e1:	8b 45 08             	mov    0x8(%ebp),%eax
 5e4:	0f b6 00             	movzbl (%eax),%eax
 5e7:	3c 2f                	cmp    $0x2f,%al
 5e9:	7e 0a                	jle    5f5 <atoi+0x89>
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	0f b6 00             	movzbl (%eax),%eax
 5f1:	3c 39                	cmp    $0x39,%al
 5f3:	7e c7                	jle    5bc <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 5f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f8:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 5fc:	c9                   	leave  
 5fd:	c3                   	ret    

000005fe <atoo>:

int
atoo(const char *s)
{
 5fe:	55                   	push   %ebp
 5ff:	89 e5                	mov    %esp,%ebp
 601:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 604:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 60b:	eb 04                	jmp    611 <atoo+0x13>
 60d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 611:	8b 45 08             	mov    0x8(%ebp),%eax
 614:	0f b6 00             	movzbl (%eax),%eax
 617:	3c 20                	cmp    $0x20,%al
 619:	74 f2                	je     60d <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 61b:	8b 45 08             	mov    0x8(%ebp),%eax
 61e:	0f b6 00             	movzbl (%eax),%eax
 621:	3c 2d                	cmp    $0x2d,%al
 623:	75 07                	jne    62c <atoo+0x2e>
 625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 62a:	eb 05                	jmp    631 <atoo+0x33>
 62c:	b8 01 00 00 00       	mov    $0x1,%eax
 631:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 634:	8b 45 08             	mov    0x8(%ebp),%eax
 637:	0f b6 00             	movzbl (%eax),%eax
 63a:	3c 2b                	cmp    $0x2b,%al
 63c:	74 0a                	je     648 <atoo+0x4a>
 63e:	8b 45 08             	mov    0x8(%ebp),%eax
 641:	0f b6 00             	movzbl (%eax),%eax
 644:	3c 2d                	cmp    $0x2d,%al
 646:	75 27                	jne    66f <atoo+0x71>
    s++;
 648:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 64c:	eb 21                	jmp    66f <atoo+0x71>
    n = n*8 + *s++ - '0';
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 658:	8b 45 08             	mov    0x8(%ebp),%eax
 65b:	8d 50 01             	lea    0x1(%eax),%edx
 65e:	89 55 08             	mov    %edx,0x8(%ebp)
 661:	0f b6 00             	movzbl (%eax),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	01 c8                	add    %ecx,%eax
 669:	83 e8 30             	sub    $0x30,%eax
 66c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 66f:	8b 45 08             	mov    0x8(%ebp),%eax
 672:	0f b6 00             	movzbl (%eax),%eax
 675:	3c 2f                	cmp    $0x2f,%al
 677:	7e 0a                	jle    683 <atoo+0x85>
 679:	8b 45 08             	mov    0x8(%ebp),%eax
 67c:	0f b6 00             	movzbl (%eax),%eax
 67f:	3c 37                	cmp    $0x37,%al
 681:	7e cb                	jle    64e <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 698:	8b 45 0c             	mov    0xc(%ebp),%eax
 69b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 69e:	eb 17                	jmp    6b7 <memmove+0x2b>
    *dst++ = *src++;
 6a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a3:	8d 50 01             	lea    0x1(%eax),%edx
 6a6:	89 55 fc             	mov    %edx,-0x4(%ebp)
 6a9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ac:	8d 4a 01             	lea    0x1(%edx),%ecx
 6af:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 6b2:	0f b6 12             	movzbl (%edx),%edx
 6b5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6b7:	8b 45 10             	mov    0x10(%ebp),%eax
 6ba:	8d 50 ff             	lea    -0x1(%eax),%edx
 6bd:	89 55 10             	mov    %edx,0x10(%ebp)
 6c0:	85 c0                	test   %eax,%eax
 6c2:	7f dc                	jg     6a0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6c7:	c9                   	leave  
 6c8:	c3                   	ret    

000006c9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6c9:	b8 01 00 00 00       	mov    $0x1,%eax
 6ce:	cd 40                	int    $0x40
 6d0:	c3                   	ret    

000006d1 <exit>:
SYSCALL(exit)
 6d1:	b8 02 00 00 00       	mov    $0x2,%eax
 6d6:	cd 40                	int    $0x40
 6d8:	c3                   	ret    

000006d9 <wait>:
SYSCALL(wait)
 6d9:	b8 03 00 00 00       	mov    $0x3,%eax
 6de:	cd 40                	int    $0x40
 6e0:	c3                   	ret    

000006e1 <pipe>:
SYSCALL(pipe)
 6e1:	b8 04 00 00 00       	mov    $0x4,%eax
 6e6:	cd 40                	int    $0x40
 6e8:	c3                   	ret    

000006e9 <read>:
SYSCALL(read)
 6e9:	b8 05 00 00 00       	mov    $0x5,%eax
 6ee:	cd 40                	int    $0x40
 6f0:	c3                   	ret    

000006f1 <write>:
SYSCALL(write)
 6f1:	b8 10 00 00 00       	mov    $0x10,%eax
 6f6:	cd 40                	int    $0x40
 6f8:	c3                   	ret    

000006f9 <close>:
SYSCALL(close)
 6f9:	b8 15 00 00 00       	mov    $0x15,%eax
 6fe:	cd 40                	int    $0x40
 700:	c3                   	ret    

00000701 <kill>:
SYSCALL(kill)
 701:	b8 06 00 00 00       	mov    $0x6,%eax
 706:	cd 40                	int    $0x40
 708:	c3                   	ret    

00000709 <exec>:
SYSCALL(exec)
 709:	b8 07 00 00 00       	mov    $0x7,%eax
 70e:	cd 40                	int    $0x40
 710:	c3                   	ret    

00000711 <open>:
SYSCALL(open)
 711:	b8 0f 00 00 00       	mov    $0xf,%eax
 716:	cd 40                	int    $0x40
 718:	c3                   	ret    

00000719 <mknod>:
SYSCALL(mknod)
 719:	b8 11 00 00 00       	mov    $0x11,%eax
 71e:	cd 40                	int    $0x40
 720:	c3                   	ret    

00000721 <unlink>:
SYSCALL(unlink)
 721:	b8 12 00 00 00       	mov    $0x12,%eax
 726:	cd 40                	int    $0x40
 728:	c3                   	ret    

00000729 <fstat>:
SYSCALL(fstat)
 729:	b8 08 00 00 00       	mov    $0x8,%eax
 72e:	cd 40                	int    $0x40
 730:	c3                   	ret    

00000731 <link>:
SYSCALL(link)
 731:	b8 13 00 00 00       	mov    $0x13,%eax
 736:	cd 40                	int    $0x40
 738:	c3                   	ret    

00000739 <mkdir>:
SYSCALL(mkdir)
 739:	b8 14 00 00 00       	mov    $0x14,%eax
 73e:	cd 40                	int    $0x40
 740:	c3                   	ret    

00000741 <chdir>:
SYSCALL(chdir)
 741:	b8 09 00 00 00       	mov    $0x9,%eax
 746:	cd 40                	int    $0x40
 748:	c3                   	ret    

00000749 <dup>:
SYSCALL(dup)
 749:	b8 0a 00 00 00       	mov    $0xa,%eax
 74e:	cd 40                	int    $0x40
 750:	c3                   	ret    

00000751 <getpid>:
SYSCALL(getpid)
 751:	b8 0b 00 00 00       	mov    $0xb,%eax
 756:	cd 40                	int    $0x40
 758:	c3                   	ret    

00000759 <sbrk>:
SYSCALL(sbrk)
 759:	b8 0c 00 00 00       	mov    $0xc,%eax
 75e:	cd 40                	int    $0x40
 760:	c3                   	ret    

00000761 <sleep>:
SYSCALL(sleep)
 761:	b8 0d 00 00 00       	mov    $0xd,%eax
 766:	cd 40                	int    $0x40
 768:	c3                   	ret    

00000769 <uptime>:
SYSCALL(uptime)
 769:	b8 0e 00 00 00       	mov    $0xe,%eax
 76e:	cd 40                	int    $0x40
 770:	c3                   	ret    

00000771 <halt>:
SYSCALL(halt)
 771:	b8 16 00 00 00       	mov    $0x16,%eax
 776:	cd 40                	int    $0x40
 778:	c3                   	ret    

00000779 <date>:
SYSCALL(date)
 779:	b8 17 00 00 00       	mov    $0x17,%eax
 77e:	cd 40                	int    $0x40
 780:	c3                   	ret    

00000781 <getuid>:
SYSCALL(getuid)
 781:	b8 18 00 00 00       	mov    $0x18,%eax
 786:	cd 40                	int    $0x40
 788:	c3                   	ret    

00000789 <getgid>:
SYSCALL(getgid)
 789:	b8 19 00 00 00       	mov    $0x19,%eax
 78e:	cd 40                	int    $0x40
 790:	c3                   	ret    

00000791 <getppid>:
SYSCALL(getppid)
 791:	b8 1a 00 00 00       	mov    $0x1a,%eax
 796:	cd 40                	int    $0x40
 798:	c3                   	ret    

00000799 <setuid>:
SYSCALL(setuid)
 799:	b8 1b 00 00 00       	mov    $0x1b,%eax
 79e:	cd 40                	int    $0x40
 7a0:	c3                   	ret    

000007a1 <setgid>:
SYSCALL(setgid)
 7a1:	b8 1c 00 00 00       	mov    $0x1c,%eax
 7a6:	cd 40                	int    $0x40
 7a8:	c3                   	ret    

000007a9 <getprocs>:
SYSCALL(getprocs)
 7a9:	b8 1a 00 00 00       	mov    $0x1a,%eax
 7ae:	cd 40                	int    $0x40
 7b0:	c3                   	ret    

000007b1 <setpriority>:
SYSCALL(setpriority)
 7b1:	b8 1b 00 00 00       	mov    $0x1b,%eax
 7b6:	cd 40                	int    $0x40
 7b8:	c3                   	ret    

000007b9 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7b9:	55                   	push   %ebp
 7ba:	89 e5                	mov    %esp,%ebp
 7bc:	83 ec 18             	sub    $0x18,%esp
 7bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 7c2:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7c5:	83 ec 04             	sub    $0x4,%esp
 7c8:	6a 01                	push   $0x1
 7ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7cd:	50                   	push   %eax
 7ce:	ff 75 08             	pushl  0x8(%ebp)
 7d1:	e8 1b ff ff ff       	call   6f1 <write>
 7d6:	83 c4 10             	add    $0x10,%esp
}
 7d9:	90                   	nop
 7da:	c9                   	leave  
 7db:	c3                   	ret    

000007dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7dc:	55                   	push   %ebp
 7dd:	89 e5                	mov    %esp,%ebp
 7df:	53                   	push   %ebx
 7e0:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7ea:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7ee:	74 17                	je     807 <printint+0x2b>
 7f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7f4:	79 11                	jns    807 <printint+0x2b>
    neg = 1;
 7f6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 800:	f7 d8                	neg    %eax
 802:	89 45 ec             	mov    %eax,-0x14(%ebp)
 805:	eb 06                	jmp    80d <printint+0x31>
  } else {
    x = xx;
 807:	8b 45 0c             	mov    0xc(%ebp),%eax
 80a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 80d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 814:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 817:	8d 41 01             	lea    0x1(%ecx),%eax
 81a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 81d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 820:	8b 45 ec             	mov    -0x14(%ebp),%eax
 823:	ba 00 00 00 00       	mov    $0x0,%edx
 828:	f7 f3                	div    %ebx
 82a:	89 d0                	mov    %edx,%eax
 82c:	0f b6 80 64 11 00 00 	movzbl 0x1164(%eax),%eax
 833:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 837:	8b 5d 10             	mov    0x10(%ebp),%ebx
 83a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 83d:	ba 00 00 00 00       	mov    $0x0,%edx
 842:	f7 f3                	div    %ebx
 844:	89 45 ec             	mov    %eax,-0x14(%ebp)
 847:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 84b:	75 c7                	jne    814 <printint+0x38>
  if(neg)
 84d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 851:	74 2d                	je     880 <printint+0xa4>
    buf[i++] = '-';
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8d 50 01             	lea    0x1(%eax),%edx
 859:	89 55 f4             	mov    %edx,-0xc(%ebp)
 85c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 861:	eb 1d                	jmp    880 <printint+0xa4>
    putc(fd, buf[i]);
 863:	8d 55 dc             	lea    -0x24(%ebp),%edx
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	01 d0                	add    %edx,%eax
 86b:	0f b6 00             	movzbl (%eax),%eax
 86e:	0f be c0             	movsbl %al,%eax
 871:	83 ec 08             	sub    $0x8,%esp
 874:	50                   	push   %eax
 875:	ff 75 08             	pushl  0x8(%ebp)
 878:	e8 3c ff ff ff       	call   7b9 <putc>
 87d:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 880:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 884:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 888:	79 d9                	jns    863 <printint+0x87>
    putc(fd, buf[i]);
}
 88a:	90                   	nop
 88b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 88e:	c9                   	leave  
 88f:	c3                   	ret    

00000890 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 890:	55                   	push   %ebp
 891:	89 e5                	mov    %esp,%ebp
 893:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 896:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 89d:	8d 45 0c             	lea    0xc(%ebp),%eax
 8a0:	83 c0 04             	add    $0x4,%eax
 8a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8ad:	e9 59 01 00 00       	jmp    a0b <printf+0x17b>
    c = fmt[i] & 0xff;
 8b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b8:	01 d0                	add    %edx,%eax
 8ba:	0f b6 00             	movzbl (%eax),%eax
 8bd:	0f be c0             	movsbl %al,%eax
 8c0:	25 ff 00 00 00       	and    $0xff,%eax
 8c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8cc:	75 2c                	jne    8fa <printf+0x6a>
      if(c == '%'){
 8ce:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8d2:	75 0c                	jne    8e0 <printf+0x50>
        state = '%';
 8d4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8db:	e9 27 01 00 00       	jmp    a07 <printf+0x177>
      } else {
        putc(fd, c);
 8e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8e3:	0f be c0             	movsbl %al,%eax
 8e6:	83 ec 08             	sub    $0x8,%esp
 8e9:	50                   	push   %eax
 8ea:	ff 75 08             	pushl  0x8(%ebp)
 8ed:	e8 c7 fe ff ff       	call   7b9 <putc>
 8f2:	83 c4 10             	add    $0x10,%esp
 8f5:	e9 0d 01 00 00       	jmp    a07 <printf+0x177>
      }
    } else if(state == '%'){
 8fa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8fe:	0f 85 03 01 00 00    	jne    a07 <printf+0x177>
      if(c == 'd'){
 904:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 908:	75 1e                	jne    928 <printf+0x98>
        printint(fd, *ap, 10, 1);
 90a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 90d:	8b 00                	mov    (%eax),%eax
 90f:	6a 01                	push   $0x1
 911:	6a 0a                	push   $0xa
 913:	50                   	push   %eax
 914:	ff 75 08             	pushl  0x8(%ebp)
 917:	e8 c0 fe ff ff       	call   7dc <printint>
 91c:	83 c4 10             	add    $0x10,%esp
        ap++;
 91f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 923:	e9 d8 00 00 00       	jmp    a00 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 928:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 92c:	74 06                	je     934 <printf+0xa4>
 92e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 932:	75 1e                	jne    952 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 934:	8b 45 e8             	mov    -0x18(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	6a 00                	push   $0x0
 93b:	6a 10                	push   $0x10
 93d:	50                   	push   %eax
 93e:	ff 75 08             	pushl  0x8(%ebp)
 941:	e8 96 fe ff ff       	call   7dc <printint>
 946:	83 c4 10             	add    $0x10,%esp
        ap++;
 949:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 94d:	e9 ae 00 00 00       	jmp    a00 <printf+0x170>
      } else if(c == 's'){
 952:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 956:	75 43                	jne    99b <printf+0x10b>
        s = (char*)*ap;
 958:	8b 45 e8             	mov    -0x18(%ebp),%eax
 95b:	8b 00                	mov    (%eax),%eax
 95d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 960:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 964:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 968:	75 25                	jne    98f <printf+0xff>
          s = "(null)";
 96a:	c7 45 f4 74 0e 00 00 	movl   $0xe74,-0xc(%ebp)
        while(*s != 0){
 971:	eb 1c                	jmp    98f <printf+0xff>
          putc(fd, *s);
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	0f b6 00             	movzbl (%eax),%eax
 979:	0f be c0             	movsbl %al,%eax
 97c:	83 ec 08             	sub    $0x8,%esp
 97f:	50                   	push   %eax
 980:	ff 75 08             	pushl  0x8(%ebp)
 983:	e8 31 fe ff ff       	call   7b9 <putc>
 988:	83 c4 10             	add    $0x10,%esp
          s++;
 98b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 98f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 992:	0f b6 00             	movzbl (%eax),%eax
 995:	84 c0                	test   %al,%al
 997:	75 da                	jne    973 <printf+0xe3>
 999:	eb 65                	jmp    a00 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 99b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 99f:	75 1d                	jne    9be <printf+0x12e>
        putc(fd, *ap);
 9a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9a4:	8b 00                	mov    (%eax),%eax
 9a6:	0f be c0             	movsbl %al,%eax
 9a9:	83 ec 08             	sub    $0x8,%esp
 9ac:	50                   	push   %eax
 9ad:	ff 75 08             	pushl  0x8(%ebp)
 9b0:	e8 04 fe ff ff       	call   7b9 <putc>
 9b5:	83 c4 10             	add    $0x10,%esp
        ap++;
 9b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9bc:	eb 42                	jmp    a00 <printf+0x170>
      } else if(c == '%'){
 9be:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9c2:	75 17                	jne    9db <printf+0x14b>
        putc(fd, c);
 9c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9c7:	0f be c0             	movsbl %al,%eax
 9ca:	83 ec 08             	sub    $0x8,%esp
 9cd:	50                   	push   %eax
 9ce:	ff 75 08             	pushl  0x8(%ebp)
 9d1:	e8 e3 fd ff ff       	call   7b9 <putc>
 9d6:	83 c4 10             	add    $0x10,%esp
 9d9:	eb 25                	jmp    a00 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9db:	83 ec 08             	sub    $0x8,%esp
 9de:	6a 25                	push   $0x25
 9e0:	ff 75 08             	pushl  0x8(%ebp)
 9e3:	e8 d1 fd ff ff       	call   7b9 <putc>
 9e8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9ee:	0f be c0             	movsbl %al,%eax
 9f1:	83 ec 08             	sub    $0x8,%esp
 9f4:	50                   	push   %eax
 9f5:	ff 75 08             	pushl  0x8(%ebp)
 9f8:	e8 bc fd ff ff       	call   7b9 <putc>
 9fd:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a00:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a07:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
 a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a11:	01 d0                	add    %edx,%eax
 a13:	0f b6 00             	movzbl (%eax),%eax
 a16:	84 c0                	test   %al,%al
 a18:	0f 85 94 fe ff ff    	jne    8b2 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a1e:	90                   	nop
 a1f:	c9                   	leave  
 a20:	c3                   	ret    

00000a21 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a21:	55                   	push   %ebp
 a22:	89 e5                	mov    %esp,%ebp
 a24:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a27:	8b 45 08             	mov    0x8(%ebp),%eax
 a2a:	83 e8 08             	sub    $0x8,%eax
 a2d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a30:	a1 80 11 00 00       	mov    0x1180,%eax
 a35:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a38:	eb 24                	jmp    a5e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3d:	8b 00                	mov    (%eax),%eax
 a3f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a42:	77 12                	ja     a56 <free+0x35>
 a44:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a47:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a4a:	77 24                	ja     a70 <free+0x4f>
 a4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4f:	8b 00                	mov    (%eax),%eax
 a51:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a54:	77 1a                	ja     a70 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a56:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a59:	8b 00                	mov    (%eax),%eax
 a5b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a61:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a64:	76 d4                	jbe    a3a <free+0x19>
 a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a69:	8b 00                	mov    (%eax),%eax
 a6b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a6e:	76 ca                	jbe    a3a <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a70:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a73:	8b 40 04             	mov    0x4(%eax),%eax
 a76:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a80:	01 c2                	add    %eax,%edx
 a82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a85:	8b 00                	mov    (%eax),%eax
 a87:	39 c2                	cmp    %eax,%edx
 a89:	75 24                	jne    aaf <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8e:	8b 50 04             	mov    0x4(%eax),%edx
 a91:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a94:	8b 00                	mov    (%eax),%eax
 a96:	8b 40 04             	mov    0x4(%eax),%eax
 a99:	01 c2                	add    %eax,%edx
 a9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a9e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 aa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa4:	8b 00                	mov    (%eax),%eax
 aa6:	8b 10                	mov    (%eax),%edx
 aa8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aab:	89 10                	mov    %edx,(%eax)
 aad:	eb 0a                	jmp    ab9 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 aaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab2:	8b 10                	mov    (%eax),%edx
 ab4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab7:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ab9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abc:	8b 40 04             	mov    0x4(%eax),%eax
 abf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ac6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac9:	01 d0                	add    %edx,%eax
 acb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ace:	75 20                	jne    af0 <free+0xcf>
    p->s.size += bp->s.size;
 ad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad3:	8b 50 04             	mov    0x4(%eax),%edx
 ad6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad9:	8b 40 04             	mov    0x4(%eax),%eax
 adc:	01 c2                	add    %eax,%edx
 ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ae4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae7:	8b 10                	mov    (%eax),%edx
 ae9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aec:	89 10                	mov    %edx,(%eax)
 aee:	eb 08                	jmp    af8 <free+0xd7>
  } else
    p->s.ptr = bp;
 af0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 af6:	89 10                	mov    %edx,(%eax)
  freep = p;
 af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afb:	a3 80 11 00 00       	mov    %eax,0x1180
}
 b00:	90                   	nop
 b01:	c9                   	leave  
 b02:	c3                   	ret    

00000b03 <morecore>:

static Header*
morecore(uint nu)
{
 b03:	55                   	push   %ebp
 b04:	89 e5                	mov    %esp,%ebp
 b06:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b09:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b10:	77 07                	ja     b19 <morecore+0x16>
    nu = 4096;
 b12:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b19:	8b 45 08             	mov    0x8(%ebp),%eax
 b1c:	c1 e0 03             	shl    $0x3,%eax
 b1f:	83 ec 0c             	sub    $0xc,%esp
 b22:	50                   	push   %eax
 b23:	e8 31 fc ff ff       	call   759 <sbrk>
 b28:	83 c4 10             	add    $0x10,%esp
 b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b2e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b32:	75 07                	jne    b3b <morecore+0x38>
    return 0;
 b34:	b8 00 00 00 00       	mov    $0x0,%eax
 b39:	eb 26                	jmp    b61 <morecore+0x5e>
  hp = (Header*)p;
 b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b44:	8b 55 08             	mov    0x8(%ebp),%edx
 b47:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b4d:	83 c0 08             	add    $0x8,%eax
 b50:	83 ec 0c             	sub    $0xc,%esp
 b53:	50                   	push   %eax
 b54:	e8 c8 fe ff ff       	call   a21 <free>
 b59:	83 c4 10             	add    $0x10,%esp
  return freep;
 b5c:	a1 80 11 00 00       	mov    0x1180,%eax
}
 b61:	c9                   	leave  
 b62:	c3                   	ret    

00000b63 <malloc>:

void*
malloc(uint nbytes)
{
 b63:	55                   	push   %ebp
 b64:	89 e5                	mov    %esp,%ebp
 b66:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b69:	8b 45 08             	mov    0x8(%ebp),%eax
 b6c:	83 c0 07             	add    $0x7,%eax
 b6f:	c1 e8 03             	shr    $0x3,%eax
 b72:	83 c0 01             	add    $0x1,%eax
 b75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b78:	a1 80 11 00 00       	mov    0x1180,%eax
 b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b84:	75 23                	jne    ba9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b86:	c7 45 f0 78 11 00 00 	movl   $0x1178,-0x10(%ebp)
 b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b90:	a3 80 11 00 00       	mov    %eax,0x1180
 b95:	a1 80 11 00 00       	mov    0x1180,%eax
 b9a:	a3 78 11 00 00       	mov    %eax,0x1178
    base.s.size = 0;
 b9f:	c7 05 7c 11 00 00 00 	movl   $0x0,0x117c
 ba6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bac:	8b 00                	mov    (%eax),%eax
 bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb4:	8b 40 04             	mov    0x4(%eax),%eax
 bb7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 bba:	72 4d                	jb     c09 <malloc+0xa6>
      if(p->s.size == nunits)
 bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bbf:	8b 40 04             	mov    0x4(%eax),%eax
 bc2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 bc5:	75 0c                	jne    bd3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bca:	8b 10                	mov    (%eax),%edx
 bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bcf:	89 10                	mov    %edx,(%eax)
 bd1:	eb 26                	jmp    bf9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd6:	8b 40 04             	mov    0x4(%eax),%eax
 bd9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 bdc:	89 c2                	mov    %eax,%edx
 bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be7:	8b 40 04             	mov    0x4(%eax),%eax
 bea:	c1 e0 03             	shl    $0x3,%eax
 bed:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bf6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bfc:	a3 80 11 00 00       	mov    %eax,0x1180
      return (void*)(p + 1);
 c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c04:	83 c0 08             	add    $0x8,%eax
 c07:	eb 3b                	jmp    c44 <malloc+0xe1>
    }
    if(p == freep)
 c09:	a1 80 11 00 00       	mov    0x1180,%eax
 c0e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c11:	75 1e                	jne    c31 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 c13:	83 ec 0c             	sub    $0xc,%esp
 c16:	ff 75 ec             	pushl  -0x14(%ebp)
 c19:	e8 e5 fe ff ff       	call   b03 <morecore>
 c1e:	83 c4 10             	add    $0x10,%esp
 c21:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c28:	75 07                	jne    c31 <malloc+0xce>
        return 0;
 c2a:	b8 00 00 00 00       	mov    $0x0,%eax
 c2f:	eb 13                	jmp    c44 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3a:	8b 00                	mov    (%eax),%eax
 c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c3f:	e9 6d ff ff ff       	jmp    bb1 <malloc+0x4e>
}
 c44:	c9                   	leave  
 c45:	c3                   	ret    
