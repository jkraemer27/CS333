
_p4test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
const int promo = TICKS_TO_PROMOTE;


int
main(int argc, char* argv[])
{
       0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
       4:	83 e4 f0             	and    $0xfffffff0,%esp
       7:	ff 71 fc             	pushl  -0x4(%ecx)
       a:	55                   	push   %ebp
       b:	89 e5                	mov    %esp,%ebp
       d:	53                   	push   %ebx
       e:	51                   	push   %ecx
       f:	83 ec 20             	sub    $0x20,%esp
      12:	89 cb                	mov    %ecx,%ebx
	int i;
	int test_num = argc - 1;
      14:	8b 03                	mov    (%ebx),%eax
      16:	83 e8 01             	sub    $0x1,%eax
      19:	89 45 f0             	mov    %eax,-0x10(%ebp)
	void (*test[])() = {test1, test2, test3, test4, test5, test6};
      1c:	c7 45 d8 c7 00 00 00 	movl   $0xc7,-0x28(%ebp)
      23:	c7 45 dc e4 01 00 00 	movl   $0x1e4,-0x24(%ebp)
      2a:	c7 45 e0 e0 03 00 00 	movl   $0x3e0,-0x20(%ebp)
      31:	c7 45 e4 0f 05 00 00 	movl   $0x50f,-0x1c(%ebp)
      38:	c7 45 e8 03 0c 00 00 	movl   $0xc03,-0x18(%ebp)
      3f:	c7 45 ec 96 07 00 00 	movl   $0x796,-0x14(%ebp)

	if(test_num == 0) {
      46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      4a:	75 17                	jne    63 <main+0x63>
		printf(1, "correct usage: p4test <test_num>\n");
      4c:	83 ec 08             	sub    $0x8,%esp
      4f:	68 bc 16 00 00       	push   $0x16bc
      54:	6a 01                	push   $0x1
      56:	e8 9f 12 00 00       	call   12fa <printf>
      5b:	83 c4 10             	add    $0x10,%esp
		exit();
      5e:	e8 d8 10 00 00       	call   113b <exit>
	}

	printf(1, "p4test starting with: MAX = %d, DEFAULT_BUDGET = %d, TICKS_TO_PROMOTE = %d\n\n", plevels, budget, promo);
      63:	b9 88 13 00 00       	mov    $0x1388,%ecx
      68:	ba 88 13 00 00       	mov    $0x1388,%edx
      6d:	b8 04 00 00 00       	mov    $0x4,%eax
      72:	83 ec 0c             	sub    $0xc,%esp
      75:	51                   	push   %ecx
      76:	52                   	push   %edx
      77:	50                   	push   %eax
      78:	68 e0 16 00 00       	push   $0x16e0
      7d:	6a 01                	push   $0x1
      7f:	e8 76 12 00 00       	call   12fa <printf>
      84:	83 c4 20             	add    $0x20,%esp

	for(i = 1; i <= test_num; i++) 
      87:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      8e:	eb 2a                	jmp    ba <main+0xba>
		(*test[atoi(argv[i])-1])();
      90:	8b 45 f4             	mov    -0xc(%ebp),%eax
      93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
      9a:	8b 43 04             	mov    0x4(%ebx),%eax
      9d:	01 d0                	add    %edx,%eax
      9f:	8b 00                	mov    (%eax),%eax
      a1:	83 ec 0c             	sub    $0xc,%esp
      a4:	50                   	push   %eax
      a5:	e8 2c 0f 00 00       	call   fd6 <atoi>
      aa:	83 c4 10             	add    $0x10,%esp
      ad:	83 e8 01             	sub    $0x1,%eax
      b0:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
      b4:	ff d0                	call   *%eax
		exit();
	}

	printf(1, "p4test starting with: MAX = %d, DEFAULT_BUDGET = %d, TICKS_TO_PROMOTE = %d\n\n", plevels, budget, promo);

	for(i = 1; i <= test_num; i++) 
      b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
      bd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
      c0:	7e ce                	jle    90 <main+0x90>
		(*test[atoi(argv[i])-1])();

	exit();
      c2:	e8 74 10 00 00       	call   113b <exit>

000000c7 <test1>:
}

void
test1()
{
      c7:	55                   	push   %ebp
      c8:	89 e5                	mov    %esp,%ebp
      ca:	53                   	push   %ebx
      cb:	83 ec 14             	sub    $0x14,%esp
      ce:	89 e0                	mov    %esp,%eax
      d0:	89 c3                	mov    %eax,%ebx
	printf(1, "+=+=+=+=+=+=+=+=+\n");
      d2:	83 ec 08             	sub    $0x8,%esp
      d5:	68 2d 17 00 00       	push   $0x172d
      da:	6a 01                	push   $0x1
      dc:	e8 19 12 00 00       	call   12fa <printf>
      e1:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: Test 1 |\n");
      e4:	83 ec 08             	sub    $0x8,%esp
      e7:	68 40 17 00 00       	push   $0x1740
      ec:	6a 01                	push   $0x1
      ee:	e8 07 12 00 00       	call   12fa <printf>
      f3:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+\n");
      f6:	83 ec 08             	sub    $0x8,%esp
      f9:	68 2d 17 00 00       	push   $0x172d
      fe:	6a 01                	push   $0x1
     100:	e8 f5 11 00 00       	call   12fa <printf>
     105:	83 c4 10             	add    $0x10,%esp
	int i;
	int max = 8;
     108:	c7 45 f0 08 00 00 00 	movl   $0x8,-0x10(%ebp)
	int pid[max];
     10f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     112:	8d 50 ff             	lea    -0x1(%eax),%edx
     115:	89 55 ec             	mov    %edx,-0x14(%ebp)
     118:	c1 e0 02             	shl    $0x2,%eax
     11b:	8d 50 03             	lea    0x3(%eax),%edx
     11e:	b8 10 00 00 00       	mov    $0x10,%eax
     123:	83 e8 01             	sub    $0x1,%eax
     126:	01 d0                	add    %edx,%eax
     128:	b9 10 00 00 00       	mov    $0x10,%ecx
     12d:	ba 00 00 00 00       	mov    $0x0,%edx
     132:	f7 f1                	div    %ecx
     134:	6b c0 10             	imul   $0x10,%eax,%eax
     137:	29 c4                	sub    %eax,%esp
     139:	89 e0                	mov    %esp,%eax
     13b:	83 c0 03             	add    $0x3,%eax
     13e:	c1 e8 02             	shr    $0x2,%eax
     141:	c1 e0 02             	shl    $0x2,%eax
     144:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for(i = 0; i < max; i++)
     147:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     14e:	eb 14                	jmp    164 <test1+0x9d>
		pid[i] = createInfiniteProc();
     150:	e8 18 0c 00 00       	call   d6d <createInfiniteProc>
     155:	89 c1                	mov    %eax,%ecx
     157:	8b 45 e8             	mov    -0x18(%ebp),%eax
     15a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     15d:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
	printf(1, "+=+=+=+=+=+=+=+=+\n");
	int i;
	int max = 8;
	int pid[max];

	for(i = 0; i < max; i++)
     160:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     164:	8b 45 f4             	mov    -0xc(%ebp),%eax
     167:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     16a:	7c e4                	jl     150 <test1+0x89>
		pid[i] = createInfiniteProc();

	for(i = 0; i < 3; i++)
     16c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     173:	eb 19                	jmp    18e <test1+0xc7>
		sleepMessage(5000, "Sleeping... ctrl-p\n");
     175:	83 ec 08             	sub    $0x8,%esp
     178:	68 53 17 00 00       	push   $0x1753
     17d:	68 88 13 00 00       	push   $0x1388
     182:	e8 bf 0b 00 00       	call   d46 <sleepMessage>
     187:	83 c4 10             	add    $0x10,%esp
	int pid[max];

	for(i = 0; i < max; i++)
		pid[i] = createInfiniteProc();

	for(i = 0; i < 3; i++)
     18a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     18e:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
     192:	7e e1                	jle    175 <test1+0xae>
		sleepMessage(5000, "Sleeping... ctrl-p\n");

	cleanupProcs(pid, max);
     194:	8b 45 e8             	mov    -0x18(%ebp),%eax
     197:	83 ec 08             	sub    $0x8,%esp
     19a:	ff 75 f0             	pushl  -0x10(%ebp)
     19d:	50                   	push   %eax
     19e:	e8 29 0c 00 00       	call   dcc <cleanupProcs>
     1a3:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+\n");
     1a6:	83 ec 08             	sub    $0x8,%esp
     1a9:	68 67 17 00 00       	push   $0x1767
     1ae:	6a 01                	push   $0x1
     1b0:	e8 45 11 00 00       	call   12fa <printf>
     1b5:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: Test 1 |\n");
     1b8:	83 ec 08             	sub    $0x8,%esp
     1bb:	68 78 17 00 00       	push   $0x1778
     1c0:	6a 01                	push   $0x1
     1c2:	e8 33 11 00 00       	call   12fa <printf>
     1c7:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+\n");
     1ca:	83 ec 08             	sub    $0x8,%esp
     1cd:	68 67 17 00 00       	push   $0x1767
     1d2:	6a 01                	push   $0x1
     1d4:	e8 21 11 00 00       	call   12fa <printf>
     1d9:	83 c4 10             	add    $0x10,%esp
     1dc:	89 dc                	mov    %ebx,%esp
}
     1de:	90                   	nop
     1df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     1e2:	c9                   	leave  
     1e3:	c3                   	ret    

000001e4 <test2>:

void 
test2()
{
     1e4:	55                   	push   %ebp
     1e5:	89 e5                	mov    %esp,%ebp
     1e7:	53                   	push   %ebx
     1e8:	83 ec 24             	sub    $0x24,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
     1eb:	83 ec 08             	sub    $0x8,%esp
     1ee:	68 89 17 00 00       	push   $0x1789
     1f3:	6a 01                	push   $0x1
     1f5:	e8 00 11 00 00       	call   12fa <printf>
     1fa:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: Test 2a |\n");
     1fd:	83 ec 08             	sub    $0x8,%esp
     200:	68 9d 17 00 00       	push   $0x179d
     205:	6a 01                	push   $0x1
     207:	e8 ee 10 00 00       	call   12fa <printf>
     20c:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
     20f:	83 ec 08             	sub    $0x8,%esp
     212:	68 89 17 00 00       	push   $0x1789
     217:	6a 01                	push   $0x1
     219:	e8 dc 10 00 00       	call   12fa <printf>
     21e:	83 c4 10             	add    $0x10,%esp
	int i, start_time, elapsed_time;
	int pid[2];
	pid[0]  = createInfiniteProc();
     221:	e8 47 0b 00 00       	call   d6d <createInfiniteProc>
     226:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	setpriority(getpid(), plevels);
     229:	bb 04 00 00 00       	mov    $0x4,%ebx
     22e:	e8 88 0f 00 00       	call   11bb <getpid>
     233:	83 ec 08             	sub    $0x8,%esp
     236:	53                   	push   %ebx
     237:	50                   	push   %eax
     238:	e8 de 0f 00 00       	call   121b <setpriority>
     23d:	83 c4 10             	add    $0x10,%esp
	start_time = uptime();
     240:	e8 8e 0f 00 00       	call   11d3 <uptime>
     245:	89 45 f0             	mov    %eax,-0x10(%ebp)

	i = 0;
     248:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(i <= plevels) {
     24f:	eb 40                	jmp    291 <test2+0xad>
		elapsed_time = uptime() - start_time;
     251:	e8 7d 0f 00 00       	call   11d3 <uptime>
     256:	2b 45 f0             	sub    -0x10(%ebp),%eax
     259:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(elapsed_time % promo-100 == 0) {
     25c:	b9 88 13 00 00       	mov    $0x1388,%ecx
     261:	8b 45 ec             	mov    -0x14(%ebp),%eax
     264:	99                   	cltd   
     265:	f7 f9                	idiv   %ecx
     267:	89 d0                	mov    %edx,%eax
     269:	83 f8 64             	cmp    $0x64,%eax
     26c:	75 23                	jne    291 <test2+0xad>
			sleepMessage(promo/2, "Sleeping... ctrl-p\n");
     26e:	b8 88 13 00 00       	mov    $0x1388,%eax
     273:	89 c2                	mov    %eax,%edx
     275:	c1 ea 1f             	shr    $0x1f,%edx
     278:	01 d0                	add    %edx,%eax
     27a:	d1 f8                	sar    %eax
     27c:	83 ec 08             	sub    $0x8,%esp
     27f:	68 53 17 00 00       	push   $0x1753
     284:	50                   	push   %eax
     285:	e8 bc 0a 00 00       	call   d46 <sleepMessage>
     28a:	83 c4 10             	add    $0x10,%esp
			i++;
     28d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

	setpriority(getpid(), plevels);
	start_time = uptime();

	i = 0;
	while(i <= plevels) {
     291:	b8 04 00 00 00       	mov    $0x4,%eax
     296:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     299:	7e b6                	jle    251 <test2+0x6d>
			sleepMessage(promo/2, "Sleeping... ctrl-p\n");
			i++;
		}
	}

	printf(1, "+=+=+=+=+=+=+=+=\n");
     29b:	83 ec 08             	sub    $0x8,%esp
     29e:	68 b1 17 00 00       	push   $0x17b1
     2a3:	6a 01                	push   $0x1
     2a5:	e8 50 10 00 00       	call   12fa <printf>
     2aa:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: Test 2a |\n");
     2ad:	83 ec 08             	sub    $0x8,%esp
     2b0:	68 c3 17 00 00       	push   $0x17c3
     2b5:	6a 01                	push   $0x1
     2b7:	e8 3e 10 00 00       	call   12fa <printf>
     2bc:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=\n");
     2bf:	83 ec 08             	sub    $0x8,%esp
     2c2:	68 b1 17 00 00       	push   $0x17b1
     2c7:	6a 01                	push   $0x1
     2c9:	e8 2c 10 00 00       	call   12fa <printf>
     2ce:	83 c4 10             	add    $0x10,%esp
	printf(1, "\n");
     2d1:	83 ec 08             	sub    $0x8,%esp
     2d4:	68 d5 17 00 00       	push   $0x17d5
     2d9:	6a 01                	push   $0x1
     2db:	e8 1a 10 00 00       	call   12fa <printf>
     2e0:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
     2e3:	83 ec 08             	sub    $0x8,%esp
     2e6:	68 89 17 00 00       	push   $0x1789
     2eb:	6a 01                	push   $0x1
     2ed:	e8 08 10 00 00       	call   12fa <printf>
     2f2:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: Test 2b |\n");
     2f5:	83 ec 08             	sub    $0x8,%esp
     2f8:	68 d7 17 00 00       	push   $0x17d7
     2fd:	6a 01                	push   $0x1
     2ff:	e8 f6 0f 00 00       	call   12fa <printf>
     304:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+=\n");
     307:	83 ec 08             	sub    $0x8,%esp
     30a:	68 89 17 00 00       	push   $0x1789
     30f:	6a 01                	push   $0x1
     311:	e8 e4 0f 00 00       	call   12fa <printf>
     316:	83 c4 10             	add    $0x10,%esp

	pid[1] = createSetPrioProc(0);
     319:	83 ec 0c             	sub    $0xc,%esp
     31c:	6a 00                	push   $0x0
     31e:	e8 7a 0a 00 00       	call   d9d <createSetPrioProc>
     323:	83 c4 10             	add    $0x10,%esp
     326:	89 45 e8             	mov    %eax,-0x18(%ebp)
	setpriority(pid[0], plevels);
     329:	ba 04 00 00 00       	mov    $0x4,%edx
     32e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     331:	83 ec 08             	sub    $0x8,%esp
     334:	52                   	push   %edx
     335:	50                   	push   %eax
     336:	e8 e0 0e 00 00       	call   121b <setpriority>
     33b:	83 c4 10             	add    $0x10,%esp
	start_time = uptime();
     33e:	e8 90 0e 00 00       	call   11d3 <uptime>
     343:	89 45 f0             	mov    %eax,-0x10(%ebp)

	i = 0;
     346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(i <= plevels) {
     34d:	eb 3a                	jmp    389 <test2+0x1a5>
		elapsed_time = uptime() - start_time;
     34f:	e8 7f 0e 00 00       	call   11d3 <uptime>
     354:	2b 45 f0             	sub    -0x10(%ebp),%eax
     357:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(elapsed_time % promo-100 == 0) {
     35a:	b9 88 13 00 00       	mov    $0x1388,%ecx
     35f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     362:	99                   	cltd   
     363:	f7 f9                	idiv   %ecx
     365:	89 d0                	mov    %edx,%eax
     367:	83 f8 64             	cmp    $0x64,%eax
     36a:	75 1d                	jne    389 <test2+0x1a5>
			sleepMessage(promo-100, "Sleeping... ctrl-p\n");
     36c:	b8 88 13 00 00       	mov    $0x1388,%eax
     371:	83 e8 64             	sub    $0x64,%eax
     374:	83 ec 08             	sub    $0x8,%esp
     377:	68 53 17 00 00       	push   $0x1753
     37c:	50                   	push   %eax
     37d:	e8 c4 09 00 00       	call   d46 <sleepMessage>
     382:	83 c4 10             	add    $0x10,%esp
			i++;
     385:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	pid[1] = createSetPrioProc(0);
	setpriority(pid[0], plevels);
	start_time = uptime();

	i = 0;
	while(i <= plevels) {
     389:	b8 04 00 00 00       	mov    $0x4,%eax
     38e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     391:	7e bc                	jle    34f <test2+0x16b>
			sleepMessage(promo-100, "Sleeping... ctrl-p\n");
			i++;
		}
	}
	
	cleanupProcs(pid, 2);
     393:	83 ec 08             	sub    $0x8,%esp
     396:	6a 02                	push   $0x2
     398:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     39b:	50                   	push   %eax
     39c:	e8 2b 0a 00 00       	call   dcc <cleanupProcs>
     3a1:	83 c4 10             	add    $0x10,%esp
	
	printf(1, "+=+=+=+=+=+=+=+=\n");
     3a4:	83 ec 08             	sub    $0x8,%esp
     3a7:	68 b1 17 00 00       	push   $0x17b1
     3ac:	6a 01                	push   $0x1
     3ae:	e8 47 0f 00 00       	call   12fa <printf>
     3b3:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: Test 2b |\n");
     3b6:	83 ec 08             	sub    $0x8,%esp
     3b9:	68 eb 17 00 00       	push   $0x17eb
     3be:	6a 01                	push   $0x1
     3c0:	e8 35 0f 00 00       	call   12fa <printf>
     3c5:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=\n");
     3c8:	83 ec 08             	sub    $0x8,%esp
     3cb:	68 b1 17 00 00       	push   $0x17b1
     3d0:	6a 01                	push   $0x1
     3d2:	e8 23 0f 00 00       	call   12fa <printf>
     3d7:	83 c4 10             	add    $0x10,%esp
}
     3da:	90                   	nop
     3db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     3de:	c9                   	leave  
     3df:	c3                   	ret    

000003e0 <test3>:

void 
test3()
{
     3e0:	55                   	push   %ebp
     3e1:	89 e5                	mov    %esp,%ebp
     3e3:	53                   	push   %ebx
     3e4:	83 ec 14             	sub    $0x14,%esp
     3e7:	89 e0                	mov    %esp,%eax
     3e9:	89 c3                	mov    %eax,%ebx
	printf(1, "+=+=+=+=+=+=+=+=+\n");
     3eb:	83 ec 08             	sub    $0x8,%esp
     3ee:	68 2d 17 00 00       	push   $0x172d
     3f3:	6a 01                	push   $0x1
     3f5:	e8 00 0f 00 00       	call   12fa <printf>
     3fa:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: Test 3 |\n");
     3fd:	83 ec 08             	sub    $0x8,%esp
     400:	68 fd 17 00 00       	push   $0x17fd
     405:	6a 01                	push   $0x1
     407:	e8 ee 0e 00 00       	call   12fa <printf>
     40c:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+\n");
     40f:	83 ec 08             	sub    $0x8,%esp
     412:	68 2d 17 00 00       	push   $0x172d
     417:	6a 01                	push   $0x1
     419:	e8 dc 0e 00 00       	call   12fa <printf>
     41e:	83 c4 10             	add    $0x10,%esp

	int i;
	int max = 8;
     421:	c7 45 f0 08 00 00 00 	movl   $0x8,-0x10(%ebp)
	int pid[max];
     428:	8b 45 f0             	mov    -0x10(%ebp),%eax
     42b:	8d 50 ff             	lea    -0x1(%eax),%edx
     42e:	89 55 ec             	mov    %edx,-0x14(%ebp)
     431:	c1 e0 02             	shl    $0x2,%eax
     434:	8d 50 03             	lea    0x3(%eax),%edx
     437:	b8 10 00 00 00       	mov    $0x10,%eax
     43c:	83 e8 01             	sub    $0x1,%eax
     43f:	01 d0                	add    %edx,%eax
     441:	b9 10 00 00 00       	mov    $0x10,%ecx
     446:	ba 00 00 00 00       	mov    $0x0,%edx
     44b:	f7 f1                	div    %ecx
     44d:	6b c0 10             	imul   $0x10,%eax,%eax
     450:	29 c4                	sub    %eax,%esp
     452:	89 e0                	mov    %esp,%eax
     454:	83 c0 03             	add    $0x3,%eax
     457:	c1 e8 02             	shr    $0x2,%eax
     45a:	c1 e0 02             	shl    $0x2,%eax
     45d:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for(i = 0; i < max; i++) 
     460:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     467:	eb 14                	jmp    47d <test3+0x9d>
		pid[i] = createInfiniteProc();
     469:	e8 ff 08 00 00       	call   d6d <createInfiniteProc>
     46e:	89 c1                	mov    %eax,%ecx
     470:	8b 45 e8             	mov    -0x18(%ebp),%eax
     473:	8b 55 f4             	mov    -0xc(%ebp),%edx
     476:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

	int i;
	int max = 8;
	int pid[max];

	for(i = 0; i < max; i++) 
     479:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     47d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     480:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     483:	7c e4                	jl     469 <test3+0x89>
		pid[i] = createInfiniteProc();
	
	for(i = 0; i <= plevels; i++) 
     485:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     48c:	eb 27                	jmp    4b5 <test3+0xd5>
		sleepMessage((budget*max)/2, "Sleeping... ctrl-p OR ctrl-r\n");
     48e:	b8 88 13 00 00       	mov    $0x1388,%eax
     493:	0f af 45 f0          	imul   -0x10(%ebp),%eax
     497:	89 c2                	mov    %eax,%edx
     499:	c1 ea 1f             	shr    $0x1f,%edx
     49c:	01 d0                	add    %edx,%eax
     49e:	d1 f8                	sar    %eax
     4a0:	83 ec 08             	sub    $0x8,%esp
     4a3:	68 10 18 00 00       	push   $0x1810
     4a8:	50                   	push   %eax
     4a9:	e8 98 08 00 00       	call   d46 <sleepMessage>
     4ae:	83 c4 10             	add    $0x10,%esp
	int pid[max];

	for(i = 0; i < max; i++) 
		pid[i] = createInfiniteProc();
	
	for(i = 0; i <= plevels; i++) 
     4b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     4b5:	b8 04 00 00 00       	mov    $0x4,%eax
     4ba:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     4bd:	7e cf                	jle    48e <test3+0xae>
		sleepMessage((budget*max)/2, "Sleeping... ctrl-p OR ctrl-r\n");
	
	cleanupProcs(pid, max);
     4bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
     4c2:	83 ec 08             	sub    $0x8,%esp
     4c5:	ff 75 f0             	pushl  -0x10(%ebp)
     4c8:	50                   	push   %eax
     4c9:	e8 fe 08 00 00       	call   dcc <cleanupProcs>
     4ce:	83 c4 10             	add    $0x10,%esp

	printf(1, "+=+=+=+=+=+=+=+\n");
     4d1:	83 ec 08             	sub    $0x8,%esp
     4d4:	68 67 17 00 00       	push   $0x1767
     4d9:	6a 01                	push   $0x1
     4db:	e8 1a 0e 00 00       	call   12fa <printf>
     4e0:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: Test 3 |\n");
     4e3:	83 ec 08             	sub    $0x8,%esp
     4e6:	68 2e 18 00 00       	push   $0x182e
     4eb:	6a 01                	push   $0x1
     4ed:	e8 08 0e 00 00       	call   12fa <printf>
     4f2:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+\n");
     4f5:	83 ec 08             	sub    $0x8,%esp
     4f8:	68 67 17 00 00       	push   $0x1767
     4fd:	6a 01                	push   $0x1
     4ff:	e8 f6 0d 00 00       	call   12fa <printf>
     504:	83 c4 10             	add    $0x10,%esp
     507:	89 dc                	mov    %ebx,%esp

}
     509:	90                   	nop
     50a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     50d:	c9                   	leave  
     50e:	c3                   	ret    

0000050f <test4>:

void 
test4()
{
     50f:	55                   	push   %ebp
     510:	89 e5                	mov    %esp,%ebp
     512:	53                   	push   %ebx
     513:	83 ec 14             	sub    $0x14,%esp
     516:	89 e0                	mov    %esp,%eax
     518:	89 c3                	mov    %eax,%ebx
	if(plevels == 0) {
     51a:	b8 04 00 00 00       	mov    $0x4,%eax
     51f:	85 c0                	test   %eax,%eax
     521:	75 3b                	jne    55e <test4+0x4f>
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     523:	83 ec 08             	sub    $0x8,%esp
     526:	68 89 17 00 00       	push   $0x1789
     52b:	6a 01                	push   $0x1
     52d:	e8 c8 0d 00 00       	call   12fa <printf>
     532:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 6a |\n");
     535:	83 ec 08             	sub    $0x8,%esp
     538:	68 3f 18 00 00       	push   $0x183f
     53d:	6a 01                	push   $0x1
     53f:	e8 b6 0d 00 00       	call   12fa <printf>
     544:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     547:	83 ec 08             	sub    $0x8,%esp
     54a:	68 89 17 00 00       	push   $0x1789
     54f:	6a 01                	push   $0x1
     551:	e8 a4 0d 00 00       	call   12fa <printf>
     556:	83 c4 10             	add    $0x10,%esp
     559:	e9 82 00 00 00       	jmp    5e0 <test4+0xd1>
	}
	else if(plevels == 2) {
     55e:	b8 04 00 00 00       	mov    $0x4,%eax
     563:	83 f8 02             	cmp    $0x2,%eax
     566:	75 38                	jne    5a0 <test4+0x91>
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     568:	83 ec 08             	sub    $0x8,%esp
     56b:	68 89 17 00 00       	push   $0x1789
     570:	6a 01                	push   $0x1
     572:	e8 83 0d 00 00       	call   12fa <printf>
     577:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 4a |\n");
     57a:	83 ec 08             	sub    $0x8,%esp
     57d:	68 53 18 00 00       	push   $0x1853
     582:	6a 01                	push   $0x1
     584:	e8 71 0d 00 00       	call   12fa <printf>
     589:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     58c:	83 ec 08             	sub    $0x8,%esp
     58f:	68 89 17 00 00       	push   $0x1789
     594:	6a 01                	push   $0x1
     596:	e8 5f 0d 00 00       	call   12fa <printf>
     59b:	83 c4 10             	add    $0x10,%esp
     59e:	eb 40                	jmp    5e0 <test4+0xd1>
	}
	else if(plevels == 6) {
     5a0:	b8 04 00 00 00       	mov    $0x4,%eax
     5a5:	83 f8 06             	cmp    $0x6,%eax
     5a8:	75 36                	jne    5e0 <test4+0xd1>
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     5aa:	83 ec 08             	sub    $0x8,%esp
     5ad:	68 89 17 00 00       	push   $0x1789
     5b2:	6a 01                	push   $0x1
     5b4:	e8 41 0d 00 00       	call   12fa <printf>
     5b9:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 5a |\n");
     5bc:	83 ec 08             	sub    $0x8,%esp
     5bf:	68 67 18 00 00       	push   $0x1867
     5c4:	6a 01                	push   $0x1
     5c6:	e8 2f 0d 00 00       	call   12fa <printf>
     5cb:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     5ce:	83 ec 08             	sub    $0x8,%esp
     5d1:	68 89 17 00 00       	push   $0x1789
     5d6:	6a 01                	push   $0x1
     5d8:	e8 1d 0d 00 00       	call   12fa <printf>
     5dd:	83 c4 10             	add    $0x10,%esp
	}

	int i;	
	int max = 10;
     5e0:	c7 45 f0 0a 00 00 00 	movl   $0xa,-0x10(%ebp)
	int pid[max];
     5e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5ea:	8d 50 ff             	lea    -0x1(%eax),%edx
     5ed:	89 55 ec             	mov    %edx,-0x14(%ebp)
     5f0:	c1 e0 02             	shl    $0x2,%eax
     5f3:	8d 50 03             	lea    0x3(%eax),%edx
     5f6:	b8 10 00 00 00       	mov    $0x10,%eax
     5fb:	83 e8 01             	sub    $0x1,%eax
     5fe:	01 d0                	add    %edx,%eax
     600:	b9 10 00 00 00       	mov    $0x10,%ecx
     605:	ba 00 00 00 00       	mov    $0x0,%edx
     60a:	f7 f1                	div    %ecx
     60c:	6b c0 10             	imul   $0x10,%eax,%eax
     60f:	29 c4                	sub    %eax,%esp
     611:	89 e0                	mov    %esp,%eax
     613:	83 c0 03             	add    $0x3,%eax
     616:	c1 e8 02             	shr    $0x2,%eax
     619:	c1 e0 02             	shl    $0x2,%eax
     61c:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for(i = 0; i < max/2; i++)
     61f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     626:	eb 20                	jmp    648 <test4+0x139>
		pid[i] = createSetPrioProc(plevels);
     628:	b8 04 00 00 00       	mov    $0x4,%eax
     62d:	83 ec 0c             	sub    $0xc,%esp
     630:	50                   	push   %eax
     631:	e8 67 07 00 00       	call   d9d <createSetPrioProc>
     636:	83 c4 10             	add    $0x10,%esp
     639:	89 c1                	mov    %eax,%ecx
     63b:	8b 45 e8             	mov    -0x18(%ebp),%eax
     63e:	8b 55 f4             	mov    -0xc(%ebp),%edx
     641:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

	int i;	
	int max = 10;
	int pid[max];

	for(i = 0; i < max/2; i++)
     644:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     648:	8b 45 f0             	mov    -0x10(%ebp),%eax
     64b:	89 c2                	mov    %eax,%edx
     64d:	c1 ea 1f             	shr    $0x1f,%edx
     650:	01 d0                	add    %edx,%eax
     652:	d1 f8                	sar    %eax
     654:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     657:	7f cf                	jg     628 <test4+0x119>
		pid[i] = createSetPrioProc(plevels);
	for(i = max/2; i < max; i++)
     659:	8b 45 f0             	mov    -0x10(%ebp),%eax
     65c:	89 c2                	mov    %eax,%edx
     65e:	c1 ea 1f             	shr    $0x1f,%edx
     661:	01 d0                	add    %edx,%eax
     663:	d1 f8                	sar    %eax
     665:	89 45 f4             	mov    %eax,-0xc(%ebp)
     668:	eb 1c                	jmp    686 <test4+0x177>
		pid[i] = createSetPrioProc(0);
     66a:	83 ec 0c             	sub    $0xc,%esp
     66d:	6a 00                	push   $0x0
     66f:	e8 29 07 00 00       	call   d9d <createSetPrioProc>
     674:	83 c4 10             	add    $0x10,%esp
     677:	89 c1                	mov    %eax,%ecx
     679:	8b 45 e8             	mov    -0x18(%ebp),%eax
     67c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     67f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
	int max = 10;
	int pid[max];

	for(i = 0; i < max/2; i++)
		pid[i] = createSetPrioProc(plevels);
	for(i = max/2; i < max; i++)
     682:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     686:	8b 45 f4             	mov    -0xc(%ebp),%eax
     689:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     68c:	7c dc                	jl     66a <test4+0x15b>
		pid[i] = createSetPrioProc(0);

	for(i = 0; i < 2; i++)
     68e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     695:	eb 19                	jmp    6b0 <test4+0x1a1>
		sleepMessage(6000, "Sleeping... ctrl-p\n");
     697:	83 ec 08             	sub    $0x8,%esp
     69a:	68 53 17 00 00       	push   $0x1753
     69f:	68 70 17 00 00       	push   $0x1770
     6a4:	e8 9d 06 00 00       	call   d46 <sleepMessage>
     6a9:	83 c4 10             	add    $0x10,%esp
	for(i = 0; i < max/2; i++)
		pid[i] = createSetPrioProc(plevels);
	for(i = max/2; i < max; i++)
		pid[i] = createSetPrioProc(0);

	for(i = 0; i < 2; i++)
     6ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     6b0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
     6b4:	7e e1                	jle    697 <test4+0x188>
		sleepMessage(6000, "Sleeping... ctrl-p\n");

	cleanupProcs(pid, max);
     6b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     6b9:	83 ec 08             	sub    $0x8,%esp
     6bc:	ff 75 f0             	pushl  -0x10(%ebp)
     6bf:	50                   	push   %eax
     6c0:	e8 07 07 00 00       	call   dcc <cleanupProcs>
     6c5:	83 c4 10             	add    $0x10,%esp

	if(plevels == 0) {
     6c8:	b8 04 00 00 00       	mov    $0x4,%eax
     6cd:	85 c0                	test   %eax,%eax
     6cf:	75 3b                	jne    70c <test4+0x1fd>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     6d1:	83 ec 08             	sub    $0x8,%esp
     6d4:	68 b1 17 00 00       	push   $0x17b1
     6d9:	6a 01                	push   $0x1
     6db:	e8 1a 0c 00 00       	call   12fa <printf>
     6e0:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 6a |\n");
     6e3:	83 ec 08             	sub    $0x8,%esp
     6e6:	68 7b 18 00 00       	push   $0x187b
     6eb:	6a 01                	push   $0x1
     6ed:	e8 08 0c 00 00       	call   12fa <printf>
     6f2:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     6f5:	83 ec 08             	sub    $0x8,%esp
     6f8:	68 b1 17 00 00       	push   $0x17b1
     6fd:	6a 01                	push   $0x1
     6ff:	e8 f6 0b 00 00       	call   12fa <printf>
     704:	83 c4 10             	add    $0x10,%esp
     707:	e9 82 00 00 00       	jmp    78e <test4+0x27f>
	}
	else if(plevels == 2) {
     70c:	b8 04 00 00 00       	mov    $0x4,%eax
     711:	83 f8 02             	cmp    $0x2,%eax
     714:	75 38                	jne    74e <test4+0x23f>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     716:	83 ec 08             	sub    $0x8,%esp
     719:	68 b1 17 00 00       	push   $0x17b1
     71e:	6a 01                	push   $0x1
     720:	e8 d5 0b 00 00       	call   12fa <printf>
     725:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 4a |\n");
     728:	83 ec 08             	sub    $0x8,%esp
     72b:	68 8d 18 00 00       	push   $0x188d
     730:	6a 01                	push   $0x1
     732:	e8 c3 0b 00 00       	call   12fa <printf>
     737:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     73a:	83 ec 08             	sub    $0x8,%esp
     73d:	68 b1 17 00 00       	push   $0x17b1
     742:	6a 01                	push   $0x1
     744:	e8 b1 0b 00 00       	call   12fa <printf>
     749:	83 c4 10             	add    $0x10,%esp
     74c:	eb 40                	jmp    78e <test4+0x27f>
	}
	else if(plevels == 6) {
     74e:	b8 04 00 00 00       	mov    $0x4,%eax
     753:	83 f8 06             	cmp    $0x6,%eax
     756:	75 36                	jne    78e <test4+0x27f>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     758:	83 ec 08             	sub    $0x8,%esp
     75b:	68 b1 17 00 00       	push   $0x17b1
     760:	6a 01                	push   $0x1
     762:	e8 93 0b 00 00       	call   12fa <printf>
     767:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 5a |\n");
     76a:	83 ec 08             	sub    $0x8,%esp
     76d:	68 9f 18 00 00       	push   $0x189f
     772:	6a 01                	push   $0x1
     774:	e8 81 0b 00 00       	call   12fa <printf>
     779:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     77c:	83 ec 08             	sub    $0x8,%esp
     77f:	68 b1 17 00 00       	push   $0x17b1
     784:	6a 01                	push   $0x1
     786:	e8 6f 0b 00 00       	call   12fa <printf>
     78b:	83 c4 10             	add    $0x10,%esp
     78e:	89 dc                	mov    %ebx,%esp
	}
}
     790:	90                   	nop
     791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     794:	c9                   	leave  
     795:	c3                   	ret    

00000796 <test6>:

void
test6()
{
     796:	55                   	push   %ebp
     797:	89 e5                	mov    %esp,%ebp
     799:	53                   	push   %ebx
     79a:	83 ec 14             	sub    $0x14,%esp
     79d:	89 e0                	mov    %esp,%eax
     79f:	89 c3                	mov    %eax,%ebx
	if(plevels == 0) {
     7a1:	b8 04 00 00 00       	mov    $0x4,%eax
     7a6:	85 c0                	test   %eax,%eax
     7a8:	75 3b                	jne    7e5 <test6+0x4f>
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     7aa:	83 ec 08             	sub    $0x8,%esp
     7ad:	68 89 17 00 00       	push   $0x1789
     7b2:	6a 01                	push   $0x1
     7b4:	e8 41 0b 00 00       	call   12fa <printf>
     7b9:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 6b |\n");
     7bc:	83 ec 08             	sub    $0x8,%esp
     7bf:	68 b1 18 00 00       	push   $0x18b1
     7c4:	6a 01                	push   $0x1
     7c6:	e8 2f 0b 00 00       	call   12fa <printf>
     7cb:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     7ce:	83 ec 08             	sub    $0x8,%esp
     7d1:	68 89 17 00 00       	push   $0x1789
     7d6:	6a 01                	push   $0x1
     7d8:	e8 1d 0b 00 00       	call   12fa <printf>
     7dd:	83 c4 10             	add    $0x10,%esp
     7e0:	e9 82 00 00 00       	jmp    867 <test6+0xd1>
	}
	else if(plevels == 2) {
     7e5:	b8 04 00 00 00       	mov    $0x4,%eax
     7ea:	83 f8 02             	cmp    $0x2,%eax
     7ed:	75 38                	jne    827 <test6+0x91>
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     7ef:	83 ec 08             	sub    $0x8,%esp
     7f2:	68 89 17 00 00       	push   $0x1789
     7f7:	6a 01                	push   $0x1
     7f9:	e8 fc 0a 00 00       	call   12fa <printf>
     7fe:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 4b |\n");
     801:	83 ec 08             	sub    $0x8,%esp
     804:	68 c5 18 00 00       	push   $0x18c5
     809:	6a 01                	push   $0x1
     80b:	e8 ea 0a 00 00       	call   12fa <printf>
     810:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     813:	83 ec 08             	sub    $0x8,%esp
     816:	68 89 17 00 00       	push   $0x1789
     81b:	6a 01                	push   $0x1
     81d:	e8 d8 0a 00 00       	call   12fa <printf>
     822:	83 c4 10             	add    $0x10,%esp
     825:	eb 40                	jmp    867 <test6+0xd1>
	}
	else if(plevels == 6) {
     827:	b8 04 00 00 00       	mov    $0x4,%eax
     82c:	83 f8 06             	cmp    $0x6,%eax
     82f:	75 36                	jne    867 <test6+0xd1>
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     831:	83 ec 08             	sub    $0x8,%esp
     834:	68 89 17 00 00       	push   $0x1789
     839:	6a 01                	push   $0x1
     83b:	e8 ba 0a 00 00       	call   12fa <printf>
     840:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 5b |\n");
     843:	83 ec 08             	sub    $0x8,%esp
     846:	68 d9 18 00 00       	push   $0x18d9
     84b:	6a 01                	push   $0x1
     84d:	e8 a8 0a 00 00       	call   12fa <printf>
     852:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     855:	83 ec 08             	sub    $0x8,%esp
     858:	68 89 17 00 00       	push   $0x1789
     85d:	6a 01                	push   $0x1
     85f:	e8 96 0a 00 00       	call   12fa <printf>
     864:	83 c4 10             	add    $0x10,%esp
	}

	int i;
	int max = 8;
     867:	c7 45 f0 08 00 00 00 	movl   $0x8,-0x10(%ebp)
	int pid[max];
     86e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     871:	8d 50 ff             	lea    -0x1(%eax),%edx
     874:	89 55 ec             	mov    %edx,-0x14(%ebp)
     877:	c1 e0 02             	shl    $0x2,%eax
     87a:	8d 50 03             	lea    0x3(%eax),%edx
     87d:	b8 10 00 00 00       	mov    $0x10,%eax
     882:	83 e8 01             	sub    $0x1,%eax
     885:	01 d0                	add    %edx,%eax
     887:	b9 10 00 00 00       	mov    $0x10,%ecx
     88c:	ba 00 00 00 00       	mov    $0x0,%edx
     891:	f7 f1                	div    %ecx
     893:	6b c0 10             	imul   $0x10,%eax,%eax
     896:	29 c4                	sub    %eax,%esp
     898:	89 e0                	mov    %esp,%eax
     89a:	83 c0 03             	add    $0x3,%eax
     89d:	c1 e8 02             	shr    $0x2,%eax
     8a0:	c1 e0 02             	shl    $0x2,%eax
     8a3:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for(i = 0; i < max/2; i++)
     8a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     8ad:	eb 14                	jmp    8c3 <test6+0x12d>
		pid[i] = createInfiniteProc();
     8af:	e8 b9 04 00 00       	call   d6d <createInfiniteProc>
     8b4:	89 c1                	mov    %eax,%ecx
     8b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     8b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
     8bc:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

	int i;
	int max = 8;
	int pid[max];

	for(i = 0; i < max/2; i++)
     8bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     8c6:	89 c2                	mov    %eax,%edx
     8c8:	c1 ea 1f             	shr    $0x1f,%edx
     8cb:	01 d0                	add    %edx,%eax
     8cd:	d1 f8                	sar    %eax
     8cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     8d2:	7f db                	jg     8af <test6+0x119>
		pid[i] = createInfiniteProc();

	for(i = 0; i <= plevels; i++)
     8d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     8db:	eb 19                	jmp    8f6 <test6+0x160>
		sleepMessage(2000, "Sleeping... ctrl-p OR ctrl-r\n");
     8dd:	83 ec 08             	sub    $0x8,%esp
     8e0:	68 10 18 00 00       	push   $0x1810
     8e5:	68 d0 07 00 00       	push   $0x7d0
     8ea:	e8 57 04 00 00       	call   d46 <sleepMessage>
     8ef:	83 c4 10             	add    $0x10,%esp
	int pid[max];

	for(i = 0; i < max/2; i++)
		pid[i] = createInfiniteProc();

	for(i = 0; i <= plevels; i++)
     8f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8f6:	b8 04 00 00 00       	mov    $0x4,%eax
     8fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     8fe:	7e dd                	jle    8dd <test6+0x147>
		sleepMessage(2000, "Sleeping... ctrl-p OR ctrl-r\n");
	if(plevels == 0)
     900:	b8 04 00 00 00       	mov    $0x4,%eax
     905:	85 c0                	test   %eax,%eax
     907:	75 15                	jne    91e <test6+0x188>
		sleepMessage(2000, "Sleeping... ctrl-p OR ctrl-r\n");
     909:	83 ec 08             	sub    $0x8,%esp
     90c:	68 10 18 00 00       	push   $0x1810
     911:	68 d0 07 00 00       	push   $0x7d0
     916:	e8 2b 04 00 00       	call   d46 <sleepMessage>
     91b:	83 c4 10             	add    $0x10,%esp

	if(plevels == 0) {
     91e:	b8 04 00 00 00       	mov    $0x4,%eax
     923:	85 c0                	test   %eax,%eax
     925:	0f 85 83 00 00 00    	jne    9ae <test6+0x218>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     92b:	83 ec 08             	sub    $0x8,%esp
     92e:	68 b1 17 00 00       	push   $0x17b1
     933:	6a 01                	push   $0x1
     935:	e8 c0 09 00 00       	call   12fa <printf>
     93a:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 6b |\n");
     93d:	83 ec 08             	sub    $0x8,%esp
     940:	68 ed 18 00 00       	push   $0x18ed
     945:	6a 01                	push   $0x1
     947:	e8 ae 09 00 00       	call   12fa <printf>
     94c:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     94f:	83 ec 08             	sub    $0x8,%esp
     952:	68 b1 17 00 00       	push   $0x17b1
     957:	6a 01                	push   $0x1
     959:	e8 9c 09 00 00       	call   12fa <printf>
     95e:	83 c4 10             	add    $0x10,%esp
		printf(1, "\n");
     961:	83 ec 08             	sub    $0x8,%esp
     964:	68 d5 17 00 00       	push   $0x17d5
     969:	6a 01                	push   $0x1
     96b:	e8 8a 09 00 00       	call   12fa <printf>
     970:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     973:	83 ec 08             	sub    $0x8,%esp
     976:	68 89 17 00 00       	push   $0x1789
     97b:	6a 01                	push   $0x1
     97d:	e8 78 09 00 00       	call   12fa <printf>
     982:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 6c |\n");
     985:	83 ec 08             	sub    $0x8,%esp
     988:	68 ff 18 00 00       	push   $0x18ff
     98d:	6a 01                	push   $0x1
     98f:	e8 66 09 00 00       	call   12fa <printf>
     994:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     997:	83 ec 08             	sub    $0x8,%esp
     99a:	68 89 17 00 00       	push   $0x1789
     99f:	6a 01                	push   $0x1
     9a1:	e8 54 09 00 00       	call   12fa <printf>
     9a6:	83 c4 10             	add    $0x10,%esp
     9a9:	e9 19 01 00 00       	jmp    ac7 <test6+0x331>
	}
	else if(plevels == 2) {
     9ae:	b8 04 00 00 00       	mov    $0x4,%eax
     9b3:	83 f8 02             	cmp    $0x2,%eax
     9b6:	0f 85 83 00 00 00    	jne    a3f <test6+0x2a9>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     9bc:	83 ec 08             	sub    $0x8,%esp
     9bf:	68 b1 17 00 00       	push   $0x17b1
     9c4:	6a 01                	push   $0x1
     9c6:	e8 2f 09 00 00       	call   12fa <printf>
     9cb:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 4b |\n");
     9ce:	83 ec 08             	sub    $0x8,%esp
     9d1:	68 13 19 00 00       	push   $0x1913
     9d6:	6a 01                	push   $0x1
     9d8:	e8 1d 09 00 00       	call   12fa <printf>
     9dd:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     9e0:	83 ec 08             	sub    $0x8,%esp
     9e3:	68 b1 17 00 00       	push   $0x17b1
     9e8:	6a 01                	push   $0x1
     9ea:	e8 0b 09 00 00       	call   12fa <printf>
     9ef:	83 c4 10             	add    $0x10,%esp
		printf(1, "\n");
     9f2:	83 ec 08             	sub    $0x8,%esp
     9f5:	68 d5 17 00 00       	push   $0x17d5
     9fa:	6a 01                	push   $0x1
     9fc:	e8 f9 08 00 00       	call   12fa <printf>
     a01:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     a04:	83 ec 08             	sub    $0x8,%esp
     a07:	68 89 17 00 00       	push   $0x1789
     a0c:	6a 01                	push   $0x1
     a0e:	e8 e7 08 00 00       	call   12fa <printf>
     a13:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 4c |\n");
     a16:	83 ec 08             	sub    $0x8,%esp
     a19:	68 25 19 00 00       	push   $0x1925
     a1e:	6a 01                	push   $0x1
     a20:	e8 d5 08 00 00       	call   12fa <printf>
     a25:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     a28:	83 ec 08             	sub    $0x8,%esp
     a2b:	68 89 17 00 00       	push   $0x1789
     a30:	6a 01                	push   $0x1
     a32:	e8 c3 08 00 00       	call   12fa <printf>
     a37:	83 c4 10             	add    $0x10,%esp
     a3a:	e9 88 00 00 00       	jmp    ac7 <test6+0x331>
	}
	else if(plevels == 6) {
     a3f:	b8 04 00 00 00       	mov    $0x4,%eax
     a44:	83 f8 06             	cmp    $0x6,%eax
     a47:	75 7e                	jne    ac7 <test6+0x331>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     a49:	83 ec 08             	sub    $0x8,%esp
     a4c:	68 b1 17 00 00       	push   $0x17b1
     a51:	6a 01                	push   $0x1
     a53:	e8 a2 08 00 00       	call   12fa <printf>
     a58:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 5b |\n");
     a5b:	83 ec 08             	sub    $0x8,%esp
     a5e:	68 39 19 00 00       	push   $0x1939
     a63:	6a 01                	push   $0x1
     a65:	e8 90 08 00 00       	call   12fa <printf>
     a6a:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     a6d:	83 ec 08             	sub    $0x8,%esp
     a70:	68 b1 17 00 00       	push   $0x17b1
     a75:	6a 01                	push   $0x1
     a77:	e8 7e 08 00 00       	call   12fa <printf>
     a7c:	83 c4 10             	add    $0x10,%esp
		printf(1, "\n");
     a7f:	83 ec 08             	sub    $0x8,%esp
     a82:	68 d5 17 00 00       	push   $0x17d5
     a87:	6a 01                	push   $0x1
     a89:	e8 6c 08 00 00       	call   12fa <printf>
     a8e:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     a91:	83 ec 08             	sub    $0x8,%esp
     a94:	68 89 17 00 00       	push   $0x1789
     a99:	6a 01                	push   $0x1
     a9b:	e8 5a 08 00 00       	call   12fa <printf>
     aa0:	83 c4 10             	add    $0x10,%esp
		printf(1, "| Start: Test 5c |\n");
     aa3:	83 ec 08             	sub    $0x8,%esp
     aa6:	68 4b 19 00 00       	push   $0x194b
     aab:	6a 01                	push   $0x1
     aad:	e8 48 08 00 00       	call   12fa <printf>
     ab2:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
     ab5:	83 ec 08             	sub    $0x8,%esp
     ab8:	68 89 17 00 00       	push   $0x1789
     abd:	6a 01                	push   $0x1
     abf:	e8 36 08 00 00       	call   12fa <printf>
     ac4:	83 c4 10             	add    $0x10,%esp
	}

	for(i = max/2; i < max; i++)
     ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     aca:	89 c2                	mov    %eax,%edx
     acc:	c1 ea 1f             	shr    $0x1f,%edx
     acf:	01 d0                	add    %edx,%eax
     ad1:	d1 f8                	sar    %eax
     ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     ad6:	eb 14                	jmp    aec <test6+0x356>
		pid[i] = createInfiniteProc();
     ad8:	e8 90 02 00 00       	call   d6d <createInfiniteProc>
     add:	89 c1                	mov    %eax,%ecx
     adf:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ae5:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
		printf(1, "| Start: Test 5c |\n");
		printf(1, "+=+=+=+=+=+=+=+=+=\n");
	}

	for(i = max/2; i < max; i++)
     ae8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     af2:	7c e4                	jl     ad8 <test6+0x342>
		pid[i] = createInfiniteProc();
	
	for(i = 0; i <= plevels+1; i++)
     af4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     afb:	eb 19                	jmp    b16 <test6+0x380>
		sleepMessage(1500, "Sleeping... ctrl-p OR ctrl-r\n");
     afd:	83 ec 08             	sub    $0x8,%esp
     b00:	68 10 18 00 00       	push   $0x1810
     b05:	68 dc 05 00 00       	push   $0x5dc
     b0a:	e8 37 02 00 00       	call   d46 <sleepMessage>
     b0f:	83 c4 10             	add    $0x10,%esp
	}

	for(i = max/2; i < max; i++)
		pid[i] = createInfiniteProc();
	
	for(i = 0; i <= plevels+1; i++)
     b12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     b16:	b8 04 00 00 00       	mov    $0x4,%eax
     b1b:	83 c0 01             	add    $0x1,%eax
     b1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     b21:	7d da                	jge    afd <test6+0x367>
		sleepMessage(1500, "Sleeping... ctrl-p OR ctrl-r\n");

	cleanupProcs(pid, max);
     b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
     b26:	83 ec 08             	sub    $0x8,%esp
     b29:	ff 75 f0             	pushl  -0x10(%ebp)
     b2c:	50                   	push   %eax
     b2d:	e8 9a 02 00 00       	call   dcc <cleanupProcs>
     b32:	83 c4 10             	add    $0x10,%esp

	if(plevels == 0) {
     b35:	b8 04 00 00 00       	mov    $0x4,%eax
     b3a:	85 c0                	test   %eax,%eax
     b3c:	75 3b                	jne    b79 <test6+0x3e3>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     b3e:	83 ec 08             	sub    $0x8,%esp
     b41:	68 b1 17 00 00       	push   $0x17b1
     b46:	6a 01                	push   $0x1
     b48:	e8 ad 07 00 00       	call   12fa <printf>
     b4d:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 6c |\n");
     b50:	83 ec 08             	sub    $0x8,%esp
     b53:	68 5f 19 00 00       	push   $0x195f
     b58:	6a 01                	push   $0x1
     b5a:	e8 9b 07 00 00       	call   12fa <printf>
     b5f:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     b62:	83 ec 08             	sub    $0x8,%esp
     b65:	68 b1 17 00 00       	push   $0x17b1
     b6a:	6a 01                	push   $0x1
     b6c:	e8 89 07 00 00       	call   12fa <printf>
     b71:	83 c4 10             	add    $0x10,%esp
     b74:	e9 82 00 00 00       	jmp    bfb <test6+0x465>
	}
	else if(plevels == 2) {
     b79:	b8 04 00 00 00       	mov    $0x4,%eax
     b7e:	83 f8 02             	cmp    $0x2,%eax
     b81:	75 38                	jne    bbb <test6+0x425>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     b83:	83 ec 08             	sub    $0x8,%esp
     b86:	68 b1 17 00 00       	push   $0x17b1
     b8b:	6a 01                	push   $0x1
     b8d:	e8 68 07 00 00       	call   12fa <printf>
     b92:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 4c |\n");
     b95:	83 ec 08             	sub    $0x8,%esp
     b98:	68 71 19 00 00       	push   $0x1971
     b9d:	6a 01                	push   $0x1
     b9f:	e8 56 07 00 00       	call   12fa <printf>
     ba4:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     ba7:	83 ec 08             	sub    $0x8,%esp
     baa:	68 b1 17 00 00       	push   $0x17b1
     baf:	6a 01                	push   $0x1
     bb1:	e8 44 07 00 00       	call   12fa <printf>
     bb6:	83 c4 10             	add    $0x10,%esp
     bb9:	eb 40                	jmp    bfb <test6+0x465>
	}
	else if(plevels == 6) {
     bbb:	b8 04 00 00 00       	mov    $0x4,%eax
     bc0:	83 f8 06             	cmp    $0x6,%eax
     bc3:	75 36                	jne    bfb <test6+0x465>
		printf(1, "+=+=+=+=+=+=+=+=\n");
     bc5:	83 ec 08             	sub    $0x8,%esp
     bc8:	68 b1 17 00 00       	push   $0x17b1
     bcd:	6a 01                	push   $0x1
     bcf:	e8 26 07 00 00       	call   12fa <printf>
     bd4:	83 c4 10             	add    $0x10,%esp
		printf(1, "| End: Test 5c |\n");
     bd7:	83 ec 08             	sub    $0x8,%esp
     bda:	68 83 19 00 00       	push   $0x1983
     bdf:	6a 01                	push   $0x1
     be1:	e8 14 07 00 00       	call   12fa <printf>
     be6:	83 c4 10             	add    $0x10,%esp
		printf(1, "+=+=+=+=+=+=+=+=\n");
     be9:	83 ec 08             	sub    $0x8,%esp
     bec:	68 b1 17 00 00       	push   $0x17b1
     bf1:	6a 01                	push   $0x1
     bf3:	e8 02 07 00 00       	call   12fa <printf>
     bf8:	83 c4 10             	add    $0x10,%esp
     bfb:	89 dc                	mov    %ebx,%esp
	}
	
}
     bfd:	90                   	nop
     bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     c01:	c9                   	leave  
     c02:	c3                   	ret    

00000c03 <test5>:

void
test5()
{
     c03:	55                   	push   %ebp
     c04:	89 e5                	mov    %esp,%ebp
     c06:	53                   	push   %ebx
     c07:	83 ec 24             	sub    $0x24,%esp
     c0a:	89 e0                	mov    %esp,%eax
     c0c:	89 c3                	mov    %eax,%ebx
	printf(1, "+=+=+=+=+=+=+=+=+\n");
     c0e:	83 ec 08             	sub    $0x8,%esp
     c11:	68 2d 17 00 00       	push   $0x172d
     c16:	6a 01                	push   $0x1
     c18:	e8 dd 06 00 00       	call   12fa <printf>
     c1d:	83 c4 10             	add    $0x10,%esp
	printf(1, "| Start: Test 5 |\n");
     c20:	83 ec 08             	sub    $0x8,%esp
     c23:	68 95 19 00 00       	push   $0x1995
     c28:	6a 01                	push   $0x1
     c2a:	e8 cb 06 00 00       	call   12fa <printf>
     c2f:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=+\n");
     c32:	83 ec 08             	sub    $0x8,%esp
     c35:	68 2d 17 00 00       	push   $0x172d
     c3a:	6a 01                	push   $0x1
     c3c:	e8 b9 06 00 00       	call   12fa <printf>
     c41:	83 c4 10             	add    $0x10,%esp

	int i, prio;
	int max = 10;
     c44:	c7 45 f0 0a 00 00 00 	movl   $0xa,-0x10(%ebp)
	int pid[max];
     c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c4e:	8d 50 ff             	lea    -0x1(%eax),%edx
     c51:	89 55 ec             	mov    %edx,-0x14(%ebp)
     c54:	c1 e0 02             	shl    $0x2,%eax
     c57:	8d 50 03             	lea    0x3(%eax),%edx
     c5a:	b8 10 00 00 00       	mov    $0x10,%eax
     c5f:	83 e8 01             	sub    $0x1,%eax
     c62:	01 d0                	add    %edx,%eax
     c64:	b9 10 00 00 00       	mov    $0x10,%ecx
     c69:	ba 00 00 00 00       	mov    $0x0,%edx
     c6e:	f7 f1                	div    %ecx
     c70:	6b c0 10             	imul   $0x10,%eax,%eax
     c73:	29 c4                	sub    %eax,%esp
     c75:	89 e0                	mov    %esp,%eax
     c77:	83 c0 03             	add    $0x3,%eax
     c7a:	c1 e8 02             	shr    $0x2,%eax
     c7d:	c1 e0 02             	shl    $0x2,%eax
     c80:	89 45 e8             	mov    %eax,-0x18(%ebp)
	
	for(i = 0; i < max; i++) {
     c83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c8a:	eb 4a                	jmp    cd6 <test5+0xd3>
		prio = i%(plevels+1);
     c8c:	b8 04 00 00 00       	mov    $0x4,%eax
     c91:	8d 48 01             	lea    0x1(%eax),%ecx
     c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c97:	99                   	cltd   
     c98:	f7 f9                	idiv   %ecx
     c9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pid[i] = createSetPrioProc(prio);
     c9d:	83 ec 0c             	sub    $0xc,%esp
     ca0:	ff 75 e4             	pushl  -0x1c(%ebp)
     ca3:	e8 f5 00 00 00       	call   d9d <createSetPrioProc>
     ca8:	83 c4 10             	add    $0x10,%esp
     cab:	89 c1                	mov    %eax,%ecx
     cad:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cb3:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
		printf(1, "Process %d will be at priority level %d\n", pid[i], prio); 
     cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cbc:	8b 04 90             	mov    (%eax,%edx,4),%eax
     cbf:	ff 75 e4             	pushl  -0x1c(%ebp)
     cc2:	50                   	push   %eax
     cc3:	68 a8 19 00 00       	push   $0x19a8
     cc8:	6a 01                	push   $0x1
     cca:	e8 2b 06 00 00       	call   12fa <printf>
     ccf:	83 c4 10             	add    $0x10,%esp

	int i, prio;
	int max = 10;
	int pid[max];
	
	for(i = 0; i < max; i++) {
     cd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     cd9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     cdc:	7c ae                	jl     c8c <test5+0x89>
		prio = i%(plevels+1);
		pid[i] = createSetPrioProc(prio);
		printf(1, "Process %d will be at priority level %d\n", pid[i], prio); 
	}

	sleepMessage(5000, "Sleeping... ctrl-p\n");
     cde:	83 ec 08             	sub    $0x8,%esp
     ce1:	68 53 17 00 00       	push   $0x1753
     ce6:	68 88 13 00 00       	push   $0x1388
     ceb:	e8 56 00 00 00       	call   d46 <sleepMessage>
     cf0:	83 c4 10             	add    $0x10,%esp
	sleepMessage(5000, "Sleeping... ctrl-r\n");
     cf3:	83 ec 08             	sub    $0x8,%esp
     cf6:	68 d1 19 00 00       	push   $0x19d1
     cfb:	68 88 13 00 00       	push   $0x1388
     d00:	e8 41 00 00 00       	call   d46 <sleepMessage>
     d05:	83 c4 10             	add    $0x10,%esp

	printf(1, "+=+=+=+=+=+=+=+=\n");
     d08:	83 ec 08             	sub    $0x8,%esp
     d0b:	68 b1 17 00 00       	push   $0x17b1
     d10:	6a 01                	push   $0x1
     d12:	e8 e3 05 00 00       	call   12fa <printf>
     d17:	83 c4 10             	add    $0x10,%esp
	printf(1, "| End: Test 5 |\n");
     d1a:	83 ec 08             	sub    $0x8,%esp
     d1d:	68 e5 19 00 00       	push   $0x19e5
     d22:	6a 01                	push   $0x1
     d24:	e8 d1 05 00 00       	call   12fa <printf>
     d29:	83 c4 10             	add    $0x10,%esp
	printf(1, "+=+=+=+=+=+=+=+=\n");
     d2c:	83 ec 08             	sub    $0x8,%esp
     d2f:	68 b1 17 00 00       	push   $0x17b1
     d34:	6a 01                	push   $0x1
     d36:	e8 bf 05 00 00       	call   12fa <printf>
     d3b:	83 c4 10             	add    $0x10,%esp
     d3e:	89 dc                	mov    %ebx,%esp
}
     d40:	90                   	nop
     d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     d44:	c9                   	leave  
     d45:	c3                   	ret    

00000d46 <sleepMessage>:

void
sleepMessage(int time, char message[])
{
     d46:	55                   	push   %ebp
     d47:	89 e5                	mov    %esp,%ebp
     d49:	83 ec 08             	sub    $0x8,%esp
	printf(1, message);
     d4c:	83 ec 08             	sub    $0x8,%esp
     d4f:	ff 75 0c             	pushl  0xc(%ebp)
     d52:	6a 01                	push   $0x1
     d54:	e8 a1 05 00 00       	call   12fa <printf>
     d59:	83 c4 10             	add    $0x10,%esp
	sleep(time);
     d5c:	83 ec 0c             	sub    $0xc,%esp
     d5f:	ff 75 08             	pushl  0x8(%ebp)
     d62:	e8 64 04 00 00       	call   11cb <sleep>
     d67:	83 c4 10             	add    $0x10,%esp
}
     d6a:	90                   	nop
     d6b:	c9                   	leave  
     d6c:	c3                   	ret    

00000d6d <createInfiniteProc>:

int
createInfiniteProc()
{
     d6d:	55                   	push   %ebp
     d6e:	89 e5                	mov    %esp,%ebp
     d70:	83 ec 18             	sub    $0x18,%esp
	int pid = fork();
     d73:	e8 bb 03 00 00       	call   1133 <fork>
     d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0)
     d7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d7f:	75 02                	jne    d83 <createInfiniteProc+0x16>
		while(1);
     d81:	eb fe                	jmp    d81 <createInfiniteProc+0x14>
	printf(1, "Process %d created...\n", pid);
     d83:	83 ec 04             	sub    $0x4,%esp
     d86:	ff 75 f4             	pushl  -0xc(%ebp)
     d89:	68 f6 19 00 00       	push   $0x19f6
     d8e:	6a 01                	push   $0x1
     d90:	e8 65 05 00 00       	call   12fa <printf>
     d95:	83 c4 10             	add    $0x10,%esp

	return pid;
     d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     d9b:	c9                   	leave  
     d9c:	c3                   	ret    

00000d9d <createSetPrioProc>:

int 
createSetPrioProc(int prio)
{
     d9d:	55                   	push   %ebp
     d9e:	89 e5                	mov    %esp,%ebp
     da0:	83 ec 18             	sub    $0x18,%esp
	int pid = fork();
     da3:	e8 8b 03 00 00       	call   1133 <fork>
     da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(pid == 0) 
     dab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     daf:	75 16                	jne    dc7 <createSetPrioProc+0x2a>
		while(1)
			setpriority(getpid(), prio);
     db1:	e8 05 04 00 00       	call   11bb <getpid>
     db6:	83 ec 08             	sub    $0x8,%esp
     db9:	ff 75 08             	pushl  0x8(%ebp)
     dbc:	50                   	push   %eax
     dbd:	e8 59 04 00 00       	call   121b <setpriority>
     dc2:	83 c4 10             	add    $0x10,%esp
     dc5:	eb ea                	jmp    db1 <createSetPrioProc+0x14>

	return pid;
     dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     dca:	c9                   	leave  
     dcb:	c3                   	ret    

00000dcc <cleanupProcs>:

void 
cleanupProcs(int pid[], int max)
{
     dcc:	55                   	push   %ebp
     dcd:	89 e5                	mov    %esp,%ebp
     dcf:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < max; i++)
     dd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     dd9:	eb 21                	jmp    dfc <cleanupProcs+0x30>
		kill(pid[i]);
     ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     de5:	8b 45 08             	mov    0x8(%ebp),%eax
     de8:	01 d0                	add    %edx,%eax
     dea:	8b 00                	mov    (%eax),%eax
     dec:	83 ec 0c             	sub    $0xc,%esp
     def:	50                   	push   %eax
     df0:	e8 76 03 00 00       	call   116b <kill>
     df5:	83 c4 10             	add    $0x10,%esp

void 
cleanupProcs(int pid[], int max)
{
	int i;
	for(i = 0; i < max; i++)
     df8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dff:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e02:	7c d7                	jl     ddb <cleanupProcs+0xf>
		kill(pid[i]);
	while(wait() > 0);
     e04:	90                   	nop
     e05:	e8 39 03 00 00       	call   1143 <wait>
     e0a:	85 c0                	test   %eax,%eax
     e0c:	7f f7                	jg     e05 <cleanupProcs+0x39>
}
     e0e:	90                   	nop
     e0f:	c9                   	leave  
     e10:	c3                   	ret    

00000e11 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     e11:	55                   	push   %ebp
     e12:	89 e5                	mov    %esp,%ebp
     e14:	57                   	push   %edi
     e15:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
     e19:	8b 55 10             	mov    0x10(%ebp),%edx
     e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
     e1f:	89 cb                	mov    %ecx,%ebx
     e21:	89 df                	mov    %ebx,%edi
     e23:	89 d1                	mov    %edx,%ecx
     e25:	fc                   	cld    
     e26:	f3 aa                	rep stos %al,%es:(%edi)
     e28:	89 ca                	mov    %ecx,%edx
     e2a:	89 fb                	mov    %edi,%ebx
     e2c:	89 5d 08             	mov    %ebx,0x8(%ebp)
     e2f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     e32:	90                   	nop
     e33:	5b                   	pop    %ebx
     e34:	5f                   	pop    %edi
     e35:	5d                   	pop    %ebp
     e36:	c3                   	ret    

00000e37 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     e37:	55                   	push   %ebp
     e38:	89 e5                	mov    %esp,%ebp
     e3a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     e3d:	8b 45 08             	mov    0x8(%ebp),%eax
     e40:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     e43:	90                   	nop
     e44:	8b 45 08             	mov    0x8(%ebp),%eax
     e47:	8d 50 01             	lea    0x1(%eax),%edx
     e4a:	89 55 08             	mov    %edx,0x8(%ebp)
     e4d:	8b 55 0c             	mov    0xc(%ebp),%edx
     e50:	8d 4a 01             	lea    0x1(%edx),%ecx
     e53:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     e56:	0f b6 12             	movzbl (%edx),%edx
     e59:	88 10                	mov    %dl,(%eax)
     e5b:	0f b6 00             	movzbl (%eax),%eax
     e5e:	84 c0                	test   %al,%al
     e60:	75 e2                	jne    e44 <strcpy+0xd>
    ;
  return os;
     e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e65:	c9                   	leave  
     e66:	c3                   	ret    

00000e67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     e67:	55                   	push   %ebp
     e68:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     e6a:	eb 08                	jmp    e74 <strcmp+0xd>
    p++, q++;
     e6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     e74:	8b 45 08             	mov    0x8(%ebp),%eax
     e77:	0f b6 00             	movzbl (%eax),%eax
     e7a:	84 c0                	test   %al,%al
     e7c:	74 10                	je     e8e <strcmp+0x27>
     e7e:	8b 45 08             	mov    0x8(%ebp),%eax
     e81:	0f b6 10             	movzbl (%eax),%edx
     e84:	8b 45 0c             	mov    0xc(%ebp),%eax
     e87:	0f b6 00             	movzbl (%eax),%eax
     e8a:	38 c2                	cmp    %al,%dl
     e8c:	74 de                	je     e6c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     e8e:	8b 45 08             	mov    0x8(%ebp),%eax
     e91:	0f b6 00             	movzbl (%eax),%eax
     e94:	0f b6 d0             	movzbl %al,%edx
     e97:	8b 45 0c             	mov    0xc(%ebp),%eax
     e9a:	0f b6 00             	movzbl (%eax),%eax
     e9d:	0f b6 c0             	movzbl %al,%eax
     ea0:	29 c2                	sub    %eax,%edx
     ea2:	89 d0                	mov    %edx,%eax
}
     ea4:	5d                   	pop    %ebp
     ea5:	c3                   	ret    

00000ea6 <strlen>:

uint
strlen(char *s)
{
     ea6:	55                   	push   %ebp
     ea7:	89 e5                	mov    %esp,%ebp
     ea9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     eac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     eb3:	eb 04                	jmp    eb9 <strlen+0x13>
     eb5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     eb9:	8b 55 fc             	mov    -0x4(%ebp),%edx
     ebc:	8b 45 08             	mov    0x8(%ebp),%eax
     ebf:	01 d0                	add    %edx,%eax
     ec1:	0f b6 00             	movzbl (%eax),%eax
     ec4:	84 c0                	test   %al,%al
     ec6:	75 ed                	jne    eb5 <strlen+0xf>
    ;
  return n;
     ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ecb:	c9                   	leave  
     ecc:	c3                   	ret    

00000ecd <memset>:

void*
memset(void *dst, int c, uint n)
{
     ecd:	55                   	push   %ebp
     ece:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
     ed0:	8b 45 10             	mov    0x10(%ebp),%eax
     ed3:	50                   	push   %eax
     ed4:	ff 75 0c             	pushl  0xc(%ebp)
     ed7:	ff 75 08             	pushl  0x8(%ebp)
     eda:	e8 32 ff ff ff       	call   e11 <stosb>
     edf:	83 c4 0c             	add    $0xc,%esp
  return dst;
     ee2:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ee5:	c9                   	leave  
     ee6:	c3                   	ret    

00000ee7 <strchr>:

char*
strchr(const char *s, char c)
{
     ee7:	55                   	push   %ebp
     ee8:	89 e5                	mov    %esp,%ebp
     eea:	83 ec 04             	sub    $0x4,%esp
     eed:	8b 45 0c             	mov    0xc(%ebp),%eax
     ef0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     ef3:	eb 14                	jmp    f09 <strchr+0x22>
    if(*s == c)
     ef5:	8b 45 08             	mov    0x8(%ebp),%eax
     ef8:	0f b6 00             	movzbl (%eax),%eax
     efb:	3a 45 fc             	cmp    -0x4(%ebp),%al
     efe:	75 05                	jne    f05 <strchr+0x1e>
      return (char*)s;
     f00:	8b 45 08             	mov    0x8(%ebp),%eax
     f03:	eb 13                	jmp    f18 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     f05:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f09:	8b 45 08             	mov    0x8(%ebp),%eax
     f0c:	0f b6 00             	movzbl (%eax),%eax
     f0f:	84 c0                	test   %al,%al
     f11:	75 e2                	jne    ef5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
     f18:	c9                   	leave  
     f19:	c3                   	ret    

00000f1a <gets>:

char*
gets(char *buf, int max)
{
     f1a:	55                   	push   %ebp
     f1b:	89 e5                	mov    %esp,%ebp
     f1d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     f20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f27:	eb 42                	jmp    f6b <gets+0x51>
    cc = read(0, &c, 1);
     f29:	83 ec 04             	sub    $0x4,%esp
     f2c:	6a 01                	push   $0x1
     f2e:	8d 45 ef             	lea    -0x11(%ebp),%eax
     f31:	50                   	push   %eax
     f32:	6a 00                	push   $0x0
     f34:	e8 1a 02 00 00       	call   1153 <read>
     f39:	83 c4 10             	add    $0x10,%esp
     f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     f3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     f43:	7e 33                	jle    f78 <gets+0x5e>
      break;
    buf[i++] = c;
     f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f48:	8d 50 01             	lea    0x1(%eax),%edx
     f4b:	89 55 f4             	mov    %edx,-0xc(%ebp)
     f4e:	89 c2                	mov    %eax,%edx
     f50:	8b 45 08             	mov    0x8(%ebp),%eax
     f53:	01 c2                	add    %eax,%edx
     f55:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     f59:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     f5b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     f5f:	3c 0a                	cmp    $0xa,%al
     f61:	74 16                	je     f79 <gets+0x5f>
     f63:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     f67:	3c 0d                	cmp    $0xd,%al
     f69:	74 0e                	je     f79 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f6e:	83 c0 01             	add    $0x1,%eax
     f71:	3b 45 0c             	cmp    0xc(%ebp),%eax
     f74:	7c b3                	jl     f29 <gets+0xf>
     f76:	eb 01                	jmp    f79 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     f78:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     f79:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f7c:	8b 45 08             	mov    0x8(%ebp),%eax
     f7f:	01 d0                	add    %edx,%eax
     f81:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     f84:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f87:	c9                   	leave  
     f88:	c3                   	ret    

00000f89 <stat>:

int
stat(char *n, struct stat *st)
{
     f89:	55                   	push   %ebp
     f8a:	89 e5                	mov    %esp,%ebp
     f8c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     f8f:	83 ec 08             	sub    $0x8,%esp
     f92:	6a 00                	push   $0x0
     f94:	ff 75 08             	pushl  0x8(%ebp)
     f97:	e8 df 01 00 00       	call   117b <open>
     f9c:	83 c4 10             	add    $0x10,%esp
     f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     fa2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     fa6:	79 07                	jns    faf <stat+0x26>
    return -1;
     fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     fad:	eb 25                	jmp    fd4 <stat+0x4b>
  r = fstat(fd, st);
     faf:	83 ec 08             	sub    $0x8,%esp
     fb2:	ff 75 0c             	pushl  0xc(%ebp)
     fb5:	ff 75 f4             	pushl  -0xc(%ebp)
     fb8:	e8 d6 01 00 00       	call   1193 <fstat>
     fbd:	83 c4 10             	add    $0x10,%esp
     fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     fc3:	83 ec 0c             	sub    $0xc,%esp
     fc6:	ff 75 f4             	pushl  -0xc(%ebp)
     fc9:	e8 95 01 00 00       	call   1163 <close>
     fce:	83 c4 10             	add    $0x10,%esp
  return r;
     fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     fd4:	c9                   	leave  
     fd5:	c3                   	ret    

00000fd6 <atoi>:

int
atoi(const char *s)
{
     fd6:	55                   	push   %ebp
     fd7:	89 e5                	mov    %esp,%ebp
     fd9:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
     fdc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
     fe3:	eb 04                	jmp    fe9 <atoi+0x13>
     fe5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     fe9:	8b 45 08             	mov    0x8(%ebp),%eax
     fec:	0f b6 00             	movzbl (%eax),%eax
     fef:	3c 20                	cmp    $0x20,%al
     ff1:	74 f2                	je     fe5 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
     ff3:	8b 45 08             	mov    0x8(%ebp),%eax
     ff6:	0f b6 00             	movzbl (%eax),%eax
     ff9:	3c 2d                	cmp    $0x2d,%al
     ffb:	75 07                	jne    1004 <atoi+0x2e>
     ffd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1002:	eb 05                	jmp    1009 <atoi+0x33>
    1004:	b8 01 00 00 00       	mov    $0x1,%eax
    1009:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    100c:	8b 45 08             	mov    0x8(%ebp),%eax
    100f:	0f b6 00             	movzbl (%eax),%eax
    1012:	3c 2b                	cmp    $0x2b,%al
    1014:	74 0a                	je     1020 <atoi+0x4a>
    1016:	8b 45 08             	mov    0x8(%ebp),%eax
    1019:	0f b6 00             	movzbl (%eax),%eax
    101c:	3c 2d                	cmp    $0x2d,%al
    101e:	75 2b                	jne    104b <atoi+0x75>
    s++;
    1020:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
    1024:	eb 25                	jmp    104b <atoi+0x75>
    n = n*10 + *s++ - '0';
    1026:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1029:	89 d0                	mov    %edx,%eax
    102b:	c1 e0 02             	shl    $0x2,%eax
    102e:	01 d0                	add    %edx,%eax
    1030:	01 c0                	add    %eax,%eax
    1032:	89 c1                	mov    %eax,%ecx
    1034:	8b 45 08             	mov    0x8(%ebp),%eax
    1037:	8d 50 01             	lea    0x1(%eax),%edx
    103a:	89 55 08             	mov    %edx,0x8(%ebp)
    103d:	0f b6 00             	movzbl (%eax),%eax
    1040:	0f be c0             	movsbl %al,%eax
    1043:	01 c8                	add    %ecx,%eax
    1045:	83 e8 30             	sub    $0x30,%eax
    1048:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
    104b:	8b 45 08             	mov    0x8(%ebp),%eax
    104e:	0f b6 00             	movzbl (%eax),%eax
    1051:	3c 2f                	cmp    $0x2f,%al
    1053:	7e 0a                	jle    105f <atoi+0x89>
    1055:	8b 45 08             	mov    0x8(%ebp),%eax
    1058:	0f b6 00             	movzbl (%eax),%eax
    105b:	3c 39                	cmp    $0x39,%al
    105d:	7e c7                	jle    1026 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
    105f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1062:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    1066:	c9                   	leave  
    1067:	c3                   	ret    

00001068 <atoo>:

int
atoo(const char *s)
{
    1068:	55                   	push   %ebp
    1069:	89 e5                	mov    %esp,%ebp
    106b:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
    106e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
    1075:	eb 04                	jmp    107b <atoo+0x13>
    1077:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    107b:	8b 45 08             	mov    0x8(%ebp),%eax
    107e:	0f b6 00             	movzbl (%eax),%eax
    1081:	3c 20                	cmp    $0x20,%al
    1083:	74 f2                	je     1077 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
    1085:	8b 45 08             	mov    0x8(%ebp),%eax
    1088:	0f b6 00             	movzbl (%eax),%eax
    108b:	3c 2d                	cmp    $0x2d,%al
    108d:	75 07                	jne    1096 <atoo+0x2e>
    108f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1094:	eb 05                	jmp    109b <atoo+0x33>
    1096:	b8 01 00 00 00       	mov    $0x1,%eax
    109b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    109e:	8b 45 08             	mov    0x8(%ebp),%eax
    10a1:	0f b6 00             	movzbl (%eax),%eax
    10a4:	3c 2b                	cmp    $0x2b,%al
    10a6:	74 0a                	je     10b2 <atoo+0x4a>
    10a8:	8b 45 08             	mov    0x8(%ebp),%eax
    10ab:	0f b6 00             	movzbl (%eax),%eax
    10ae:	3c 2d                	cmp    $0x2d,%al
    10b0:	75 27                	jne    10d9 <atoo+0x71>
    s++;
    10b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
    10b6:	eb 21                	jmp    10d9 <atoo+0x71>
    n = n*8 + *s++ - '0';
    10b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    10bb:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
    10c2:	8b 45 08             	mov    0x8(%ebp),%eax
    10c5:	8d 50 01             	lea    0x1(%eax),%edx
    10c8:	89 55 08             	mov    %edx,0x8(%ebp)
    10cb:	0f b6 00             	movzbl (%eax),%eax
    10ce:	0f be c0             	movsbl %al,%eax
    10d1:	01 c8                	add    %ecx,%eax
    10d3:	83 e8 30             	sub    $0x30,%eax
    10d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
    10d9:	8b 45 08             	mov    0x8(%ebp),%eax
    10dc:	0f b6 00             	movzbl (%eax),%eax
    10df:	3c 2f                	cmp    $0x2f,%al
    10e1:	7e 0a                	jle    10ed <atoo+0x85>
    10e3:	8b 45 08             	mov    0x8(%ebp),%eax
    10e6:	0f b6 00             	movzbl (%eax),%eax
    10e9:	3c 37                	cmp    $0x37,%al
    10eb:	7e cb                	jle    10b8 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
    10ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
    10f0:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    10f4:	c9                   	leave  
    10f5:	c3                   	ret    

000010f6 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
    10f6:	55                   	push   %ebp
    10f7:	89 e5                	mov    %esp,%ebp
    10f9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    10fc:	8b 45 08             	mov    0x8(%ebp),%eax
    10ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1102:	8b 45 0c             	mov    0xc(%ebp),%eax
    1105:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1108:	eb 17                	jmp    1121 <memmove+0x2b>
    *dst++ = *src++;
    110a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    110d:	8d 50 01             	lea    0x1(%eax),%edx
    1110:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1113:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1116:	8d 4a 01             	lea    0x1(%edx),%ecx
    1119:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    111c:	0f b6 12             	movzbl (%edx),%edx
    111f:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1121:	8b 45 10             	mov    0x10(%ebp),%eax
    1124:	8d 50 ff             	lea    -0x1(%eax),%edx
    1127:	89 55 10             	mov    %edx,0x10(%ebp)
    112a:	85 c0                	test   %eax,%eax
    112c:	7f dc                	jg     110a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    112e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1131:	c9                   	leave  
    1132:	c3                   	ret    

00001133 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1133:	b8 01 00 00 00       	mov    $0x1,%eax
    1138:	cd 40                	int    $0x40
    113a:	c3                   	ret    

0000113b <exit>:
SYSCALL(exit)
    113b:	b8 02 00 00 00       	mov    $0x2,%eax
    1140:	cd 40                	int    $0x40
    1142:	c3                   	ret    

00001143 <wait>:
SYSCALL(wait)
    1143:	b8 03 00 00 00       	mov    $0x3,%eax
    1148:	cd 40                	int    $0x40
    114a:	c3                   	ret    

0000114b <pipe>:
SYSCALL(pipe)
    114b:	b8 04 00 00 00       	mov    $0x4,%eax
    1150:	cd 40                	int    $0x40
    1152:	c3                   	ret    

00001153 <read>:
SYSCALL(read)
    1153:	b8 05 00 00 00       	mov    $0x5,%eax
    1158:	cd 40                	int    $0x40
    115a:	c3                   	ret    

0000115b <write>:
SYSCALL(write)
    115b:	b8 10 00 00 00       	mov    $0x10,%eax
    1160:	cd 40                	int    $0x40
    1162:	c3                   	ret    

00001163 <close>:
SYSCALL(close)
    1163:	b8 15 00 00 00       	mov    $0x15,%eax
    1168:	cd 40                	int    $0x40
    116a:	c3                   	ret    

0000116b <kill>:
SYSCALL(kill)
    116b:	b8 06 00 00 00       	mov    $0x6,%eax
    1170:	cd 40                	int    $0x40
    1172:	c3                   	ret    

00001173 <exec>:
SYSCALL(exec)
    1173:	b8 07 00 00 00       	mov    $0x7,%eax
    1178:	cd 40                	int    $0x40
    117a:	c3                   	ret    

0000117b <open>:
SYSCALL(open)
    117b:	b8 0f 00 00 00       	mov    $0xf,%eax
    1180:	cd 40                	int    $0x40
    1182:	c3                   	ret    

00001183 <mknod>:
SYSCALL(mknod)
    1183:	b8 11 00 00 00       	mov    $0x11,%eax
    1188:	cd 40                	int    $0x40
    118a:	c3                   	ret    

0000118b <unlink>:
SYSCALL(unlink)
    118b:	b8 12 00 00 00       	mov    $0x12,%eax
    1190:	cd 40                	int    $0x40
    1192:	c3                   	ret    

00001193 <fstat>:
SYSCALL(fstat)
    1193:	b8 08 00 00 00       	mov    $0x8,%eax
    1198:	cd 40                	int    $0x40
    119a:	c3                   	ret    

0000119b <link>:
SYSCALL(link)
    119b:	b8 13 00 00 00       	mov    $0x13,%eax
    11a0:	cd 40                	int    $0x40
    11a2:	c3                   	ret    

000011a3 <mkdir>:
SYSCALL(mkdir)
    11a3:	b8 14 00 00 00       	mov    $0x14,%eax
    11a8:	cd 40                	int    $0x40
    11aa:	c3                   	ret    

000011ab <chdir>:
SYSCALL(chdir)
    11ab:	b8 09 00 00 00       	mov    $0x9,%eax
    11b0:	cd 40                	int    $0x40
    11b2:	c3                   	ret    

000011b3 <dup>:
SYSCALL(dup)
    11b3:	b8 0a 00 00 00       	mov    $0xa,%eax
    11b8:	cd 40                	int    $0x40
    11ba:	c3                   	ret    

000011bb <getpid>:
SYSCALL(getpid)
    11bb:	b8 0b 00 00 00       	mov    $0xb,%eax
    11c0:	cd 40                	int    $0x40
    11c2:	c3                   	ret    

000011c3 <sbrk>:
SYSCALL(sbrk)
    11c3:	b8 0c 00 00 00       	mov    $0xc,%eax
    11c8:	cd 40                	int    $0x40
    11ca:	c3                   	ret    

000011cb <sleep>:
SYSCALL(sleep)
    11cb:	b8 0d 00 00 00       	mov    $0xd,%eax
    11d0:	cd 40                	int    $0x40
    11d2:	c3                   	ret    

000011d3 <uptime>:
SYSCALL(uptime)
    11d3:	b8 0e 00 00 00       	mov    $0xe,%eax
    11d8:	cd 40                	int    $0x40
    11da:	c3                   	ret    

000011db <halt>:
SYSCALL(halt)
    11db:	b8 16 00 00 00       	mov    $0x16,%eax
    11e0:	cd 40                	int    $0x40
    11e2:	c3                   	ret    

000011e3 <date>:
SYSCALL(date)
    11e3:	b8 17 00 00 00       	mov    $0x17,%eax
    11e8:	cd 40                	int    $0x40
    11ea:	c3                   	ret    

000011eb <getuid>:
SYSCALL(getuid)
    11eb:	b8 18 00 00 00       	mov    $0x18,%eax
    11f0:	cd 40                	int    $0x40
    11f2:	c3                   	ret    

000011f3 <getgid>:
SYSCALL(getgid)
    11f3:	b8 19 00 00 00       	mov    $0x19,%eax
    11f8:	cd 40                	int    $0x40
    11fa:	c3                   	ret    

000011fb <getppid>:
SYSCALL(getppid)
    11fb:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1200:	cd 40                	int    $0x40
    1202:	c3                   	ret    

00001203 <setuid>:
SYSCALL(setuid)
    1203:	b8 1b 00 00 00       	mov    $0x1b,%eax
    1208:	cd 40                	int    $0x40
    120a:	c3                   	ret    

0000120b <setgid>:
SYSCALL(setgid)
    120b:	b8 1c 00 00 00       	mov    $0x1c,%eax
    1210:	cd 40                	int    $0x40
    1212:	c3                   	ret    

00001213 <getprocs>:
SYSCALL(getprocs)
    1213:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1218:	cd 40                	int    $0x40
    121a:	c3                   	ret    

0000121b <setpriority>:
SYSCALL(setpriority)
    121b:	b8 1b 00 00 00       	mov    $0x1b,%eax
    1220:	cd 40                	int    $0x40
    1222:	c3                   	ret    

00001223 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1223:	55                   	push   %ebp
    1224:	89 e5                	mov    %esp,%ebp
    1226:	83 ec 18             	sub    $0x18,%esp
    1229:	8b 45 0c             	mov    0xc(%ebp),%eax
    122c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    122f:	83 ec 04             	sub    $0x4,%esp
    1232:	6a 01                	push   $0x1
    1234:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1237:	50                   	push   %eax
    1238:	ff 75 08             	pushl  0x8(%ebp)
    123b:	e8 1b ff ff ff       	call   115b <write>
    1240:	83 c4 10             	add    $0x10,%esp
}
    1243:	90                   	nop
    1244:	c9                   	leave  
    1245:	c3                   	ret    

00001246 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1246:	55                   	push   %ebp
    1247:	89 e5                	mov    %esp,%ebp
    1249:	53                   	push   %ebx
    124a:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    124d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1254:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1258:	74 17                	je     1271 <printint+0x2b>
    125a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    125e:	79 11                	jns    1271 <printint+0x2b>
    neg = 1;
    1260:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1267:	8b 45 0c             	mov    0xc(%ebp),%eax
    126a:	f7 d8                	neg    %eax
    126c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    126f:	eb 06                	jmp    1277 <printint+0x31>
  } else {
    x = xx;
    1271:	8b 45 0c             	mov    0xc(%ebp),%eax
    1274:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1277:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    127e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1281:	8d 41 01             	lea    0x1(%ecx),%eax
    1284:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1287:	8b 5d 10             	mov    0x10(%ebp),%ebx
    128a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    128d:	ba 00 00 00 00       	mov    $0x0,%edx
    1292:	f7 f3                	div    %ebx
    1294:	89 d0                	mov    %edx,%eax
    1296:	0f b6 80 d8 1d 00 00 	movzbl 0x1dd8(%eax),%eax
    129d:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    12a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    12a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    12a7:	ba 00 00 00 00       	mov    $0x0,%edx
    12ac:	f7 f3                	div    %ebx
    12ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    12b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12b5:	75 c7                	jne    127e <printint+0x38>
  if(neg)
    12b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    12bb:	74 2d                	je     12ea <printint+0xa4>
    buf[i++] = '-';
    12bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12c0:	8d 50 01             	lea    0x1(%eax),%edx
    12c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
    12c6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    12cb:	eb 1d                	jmp    12ea <printint+0xa4>
    putc(fd, buf[i]);
    12cd:	8d 55 dc             	lea    -0x24(%ebp),%edx
    12d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12d3:	01 d0                	add    %edx,%eax
    12d5:	0f b6 00             	movzbl (%eax),%eax
    12d8:	0f be c0             	movsbl %al,%eax
    12db:	83 ec 08             	sub    $0x8,%esp
    12de:	50                   	push   %eax
    12df:	ff 75 08             	pushl  0x8(%ebp)
    12e2:	e8 3c ff ff ff       	call   1223 <putc>
    12e7:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    12ea:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    12ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12f2:	79 d9                	jns    12cd <printint+0x87>
    putc(fd, buf[i]);
}
    12f4:	90                   	nop
    12f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    12f8:	c9                   	leave  
    12f9:	c3                   	ret    

000012fa <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    12fa:	55                   	push   %ebp
    12fb:	89 e5                	mov    %esp,%ebp
    12fd:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1300:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1307:	8d 45 0c             	lea    0xc(%ebp),%eax
    130a:	83 c0 04             	add    $0x4,%eax
    130d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1310:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1317:	e9 59 01 00 00       	jmp    1475 <printf+0x17b>
    c = fmt[i] & 0xff;
    131c:	8b 55 0c             	mov    0xc(%ebp),%edx
    131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1322:	01 d0                	add    %edx,%eax
    1324:	0f b6 00             	movzbl (%eax),%eax
    1327:	0f be c0             	movsbl %al,%eax
    132a:	25 ff 00 00 00       	and    $0xff,%eax
    132f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1332:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1336:	75 2c                	jne    1364 <printf+0x6a>
      if(c == '%'){
    1338:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    133c:	75 0c                	jne    134a <printf+0x50>
        state = '%';
    133e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1345:	e9 27 01 00 00       	jmp    1471 <printf+0x177>
      } else {
        putc(fd, c);
    134a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    134d:	0f be c0             	movsbl %al,%eax
    1350:	83 ec 08             	sub    $0x8,%esp
    1353:	50                   	push   %eax
    1354:	ff 75 08             	pushl  0x8(%ebp)
    1357:	e8 c7 fe ff ff       	call   1223 <putc>
    135c:	83 c4 10             	add    $0x10,%esp
    135f:	e9 0d 01 00 00       	jmp    1471 <printf+0x177>
      }
    } else if(state == '%'){
    1364:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1368:	0f 85 03 01 00 00    	jne    1471 <printf+0x177>
      if(c == 'd'){
    136e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1372:	75 1e                	jne    1392 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1374:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1377:	8b 00                	mov    (%eax),%eax
    1379:	6a 01                	push   $0x1
    137b:	6a 0a                	push   $0xa
    137d:	50                   	push   %eax
    137e:	ff 75 08             	pushl  0x8(%ebp)
    1381:	e8 c0 fe ff ff       	call   1246 <printint>
    1386:	83 c4 10             	add    $0x10,%esp
        ap++;
    1389:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    138d:	e9 d8 00 00 00       	jmp    146a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1392:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1396:	74 06                	je     139e <printf+0xa4>
    1398:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    139c:	75 1e                	jne    13bc <printf+0xc2>
        printint(fd, *ap, 16, 0);
    139e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    13a1:	8b 00                	mov    (%eax),%eax
    13a3:	6a 00                	push   $0x0
    13a5:	6a 10                	push   $0x10
    13a7:	50                   	push   %eax
    13a8:	ff 75 08             	pushl  0x8(%ebp)
    13ab:	e8 96 fe ff ff       	call   1246 <printint>
    13b0:	83 c4 10             	add    $0x10,%esp
        ap++;
    13b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    13b7:	e9 ae 00 00 00       	jmp    146a <printf+0x170>
      } else if(c == 's'){
    13bc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    13c0:	75 43                	jne    1405 <printf+0x10b>
        s = (char*)*ap;
    13c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    13c5:	8b 00                	mov    (%eax),%eax
    13c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    13ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    13ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    13d2:	75 25                	jne    13f9 <printf+0xff>
          s = "(null)";
    13d4:	c7 45 f4 0d 1a 00 00 	movl   $0x1a0d,-0xc(%ebp)
        while(*s != 0){
    13db:	eb 1c                	jmp    13f9 <printf+0xff>
          putc(fd, *s);
    13dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e0:	0f b6 00             	movzbl (%eax),%eax
    13e3:	0f be c0             	movsbl %al,%eax
    13e6:	83 ec 08             	sub    $0x8,%esp
    13e9:	50                   	push   %eax
    13ea:	ff 75 08             	pushl  0x8(%ebp)
    13ed:	e8 31 fe ff ff       	call   1223 <putc>
    13f2:	83 c4 10             	add    $0x10,%esp
          s++;
    13f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    13f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13fc:	0f b6 00             	movzbl (%eax),%eax
    13ff:	84 c0                	test   %al,%al
    1401:	75 da                	jne    13dd <printf+0xe3>
    1403:	eb 65                	jmp    146a <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1405:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1409:	75 1d                	jne    1428 <printf+0x12e>
        putc(fd, *ap);
    140b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    140e:	8b 00                	mov    (%eax),%eax
    1410:	0f be c0             	movsbl %al,%eax
    1413:	83 ec 08             	sub    $0x8,%esp
    1416:	50                   	push   %eax
    1417:	ff 75 08             	pushl  0x8(%ebp)
    141a:	e8 04 fe ff ff       	call   1223 <putc>
    141f:	83 c4 10             	add    $0x10,%esp
        ap++;
    1422:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1426:	eb 42                	jmp    146a <printf+0x170>
      } else if(c == '%'){
    1428:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    142c:	75 17                	jne    1445 <printf+0x14b>
        putc(fd, c);
    142e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1431:	0f be c0             	movsbl %al,%eax
    1434:	83 ec 08             	sub    $0x8,%esp
    1437:	50                   	push   %eax
    1438:	ff 75 08             	pushl  0x8(%ebp)
    143b:	e8 e3 fd ff ff       	call   1223 <putc>
    1440:	83 c4 10             	add    $0x10,%esp
    1443:	eb 25                	jmp    146a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1445:	83 ec 08             	sub    $0x8,%esp
    1448:	6a 25                	push   $0x25
    144a:	ff 75 08             	pushl  0x8(%ebp)
    144d:	e8 d1 fd ff ff       	call   1223 <putc>
    1452:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1455:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1458:	0f be c0             	movsbl %al,%eax
    145b:	83 ec 08             	sub    $0x8,%esp
    145e:	50                   	push   %eax
    145f:	ff 75 08             	pushl  0x8(%ebp)
    1462:	e8 bc fd ff ff       	call   1223 <putc>
    1467:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1471:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1475:	8b 55 0c             	mov    0xc(%ebp),%edx
    1478:	8b 45 f0             	mov    -0x10(%ebp),%eax
    147b:	01 d0                	add    %edx,%eax
    147d:	0f b6 00             	movzbl (%eax),%eax
    1480:	84 c0                	test   %al,%al
    1482:	0f 85 94 fe ff ff    	jne    131c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1488:	90                   	nop
    1489:	c9                   	leave  
    148a:	c3                   	ret    

0000148b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    148b:	55                   	push   %ebp
    148c:	89 e5                	mov    %esp,%ebp
    148e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1491:	8b 45 08             	mov    0x8(%ebp),%eax
    1494:	83 e8 08             	sub    $0x8,%eax
    1497:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    149a:	a1 f4 1d 00 00       	mov    0x1df4,%eax
    149f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    14a2:	eb 24                	jmp    14c8 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    14a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14a7:	8b 00                	mov    (%eax),%eax
    14a9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    14ac:	77 12                	ja     14c0 <free+0x35>
    14ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    14b4:	77 24                	ja     14da <free+0x4f>
    14b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14b9:	8b 00                	mov    (%eax),%eax
    14bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    14be:	77 1a                	ja     14da <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    14c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14c3:	8b 00                	mov    (%eax),%eax
    14c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    14c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14cb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    14ce:	76 d4                	jbe    14a4 <free+0x19>
    14d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14d3:	8b 00                	mov    (%eax),%eax
    14d5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    14d8:	76 ca                	jbe    14a4 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    14da:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14dd:	8b 40 04             	mov    0x4(%eax),%eax
    14e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    14e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14ea:	01 c2                	add    %eax,%edx
    14ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14ef:	8b 00                	mov    (%eax),%eax
    14f1:	39 c2                	cmp    %eax,%edx
    14f3:	75 24                	jne    1519 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    14f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14f8:	8b 50 04             	mov    0x4(%eax),%edx
    14fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14fe:	8b 00                	mov    (%eax),%eax
    1500:	8b 40 04             	mov    0x4(%eax),%eax
    1503:	01 c2                	add    %eax,%edx
    1505:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1508:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    150b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    150e:	8b 00                	mov    (%eax),%eax
    1510:	8b 10                	mov    (%eax),%edx
    1512:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1515:	89 10                	mov    %edx,(%eax)
    1517:	eb 0a                	jmp    1523 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1519:	8b 45 fc             	mov    -0x4(%ebp),%eax
    151c:	8b 10                	mov    (%eax),%edx
    151e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1521:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1523:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1526:	8b 40 04             	mov    0x4(%eax),%eax
    1529:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1530:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1533:	01 d0                	add    %edx,%eax
    1535:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1538:	75 20                	jne    155a <free+0xcf>
    p->s.size += bp->s.size;
    153a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    153d:	8b 50 04             	mov    0x4(%eax),%edx
    1540:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1543:	8b 40 04             	mov    0x4(%eax),%eax
    1546:	01 c2                	add    %eax,%edx
    1548:	8b 45 fc             	mov    -0x4(%ebp),%eax
    154b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    154e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1551:	8b 10                	mov    (%eax),%edx
    1553:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1556:	89 10                	mov    %edx,(%eax)
    1558:	eb 08                	jmp    1562 <free+0xd7>
  } else
    p->s.ptr = bp;
    155a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    155d:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1560:	89 10                	mov    %edx,(%eax)
  freep = p;
    1562:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1565:	a3 f4 1d 00 00       	mov    %eax,0x1df4
}
    156a:	90                   	nop
    156b:	c9                   	leave  
    156c:	c3                   	ret    

0000156d <morecore>:

static Header*
morecore(uint nu)
{
    156d:	55                   	push   %ebp
    156e:	89 e5                	mov    %esp,%ebp
    1570:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1573:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    157a:	77 07                	ja     1583 <morecore+0x16>
    nu = 4096;
    157c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1583:	8b 45 08             	mov    0x8(%ebp),%eax
    1586:	c1 e0 03             	shl    $0x3,%eax
    1589:	83 ec 0c             	sub    $0xc,%esp
    158c:	50                   	push   %eax
    158d:	e8 31 fc ff ff       	call   11c3 <sbrk>
    1592:	83 c4 10             	add    $0x10,%esp
    1595:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1598:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    159c:	75 07                	jne    15a5 <morecore+0x38>
    return 0;
    159e:	b8 00 00 00 00       	mov    $0x0,%eax
    15a3:	eb 26                	jmp    15cb <morecore+0x5e>
  hp = (Header*)p;
    15a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    15ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15ae:	8b 55 08             	mov    0x8(%ebp),%edx
    15b1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    15b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15b7:	83 c0 08             	add    $0x8,%eax
    15ba:	83 ec 0c             	sub    $0xc,%esp
    15bd:	50                   	push   %eax
    15be:	e8 c8 fe ff ff       	call   148b <free>
    15c3:	83 c4 10             	add    $0x10,%esp
  return freep;
    15c6:	a1 f4 1d 00 00       	mov    0x1df4,%eax
}
    15cb:	c9                   	leave  
    15cc:	c3                   	ret    

000015cd <malloc>:

void*
malloc(uint nbytes)
{
    15cd:	55                   	push   %ebp
    15ce:	89 e5                	mov    %esp,%ebp
    15d0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    15d3:	8b 45 08             	mov    0x8(%ebp),%eax
    15d6:	83 c0 07             	add    $0x7,%eax
    15d9:	c1 e8 03             	shr    $0x3,%eax
    15dc:	83 c0 01             	add    $0x1,%eax
    15df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    15e2:	a1 f4 1d 00 00       	mov    0x1df4,%eax
    15e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    15ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    15ee:	75 23                	jne    1613 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    15f0:	c7 45 f0 ec 1d 00 00 	movl   $0x1dec,-0x10(%ebp)
    15f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15fa:	a3 f4 1d 00 00       	mov    %eax,0x1df4
    15ff:	a1 f4 1d 00 00       	mov    0x1df4,%eax
    1604:	a3 ec 1d 00 00       	mov    %eax,0x1dec
    base.s.size = 0;
    1609:	c7 05 f0 1d 00 00 00 	movl   $0x0,0x1df0
    1610:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1613:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1616:	8b 00                	mov    (%eax),%eax
    1618:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    161e:	8b 40 04             	mov    0x4(%eax),%eax
    1621:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1624:	72 4d                	jb     1673 <malloc+0xa6>
      if(p->s.size == nunits)
    1626:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1629:	8b 40 04             	mov    0x4(%eax),%eax
    162c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    162f:	75 0c                	jne    163d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1631:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1634:	8b 10                	mov    (%eax),%edx
    1636:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1639:	89 10                	mov    %edx,(%eax)
    163b:	eb 26                	jmp    1663 <malloc+0x96>
      else {
        p->s.size -= nunits;
    163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1640:	8b 40 04             	mov    0x4(%eax),%eax
    1643:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1646:	89 c2                	mov    %eax,%edx
    1648:	8b 45 f4             	mov    -0xc(%ebp),%eax
    164b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1651:	8b 40 04             	mov    0x4(%eax),%eax
    1654:	c1 e0 03             	shl    $0x3,%eax
    1657:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    165d:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1660:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1663:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1666:	a3 f4 1d 00 00       	mov    %eax,0x1df4
      return (void*)(p + 1);
    166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    166e:	83 c0 08             	add    $0x8,%eax
    1671:	eb 3b                	jmp    16ae <malloc+0xe1>
    }
    if(p == freep)
    1673:	a1 f4 1d 00 00       	mov    0x1df4,%eax
    1678:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    167b:	75 1e                	jne    169b <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    167d:	83 ec 0c             	sub    $0xc,%esp
    1680:	ff 75 ec             	pushl  -0x14(%ebp)
    1683:	e8 e5 fe ff ff       	call   156d <morecore>
    1688:	83 c4 10             	add    $0x10,%esp
    168b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    168e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1692:	75 07                	jne    169b <malloc+0xce>
        return 0;
    1694:	b8 00 00 00 00       	mov    $0x0,%eax
    1699:	eb 13                	jmp    16ae <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    169e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    16a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16a4:	8b 00                	mov    (%eax),%eax
    16a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    16a9:	e9 6d ff ff ff       	jmp    161b <malloc+0x4e>
}
    16ae:	c9                   	leave  
    16af:	c3                   	ret    
