
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "uproc.h"
#include "param.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 38             	sub    $0x38,%esp
  int elapsed, milli, cpue, cpum;

  struct uproc *p = malloc(sizeof(struct uproc) * MAXPROC);
  14:	83 ec 0c             	sub    $0xc,%esp
  17:	68 00 06 00 00       	push   $0x600
  1c:	e8 bf 0a 00 00       	call   ae0 <malloc>
  21:	83 c4 10             	add    $0x10,%esp
  24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int processes = getprocs(MAXPROC, p);
  27:	83 ec 08             	sub    $0x8,%esp
  2a:	ff 75 e0             	pushl  -0x20(%ebp)
  2d:	6a 10                	push   $0x10
  2f:	e8 f2 06 00 00       	call   726 <getprocs>
  34:	83 c4 10             	add    $0x10,%esp
  37:	89 45 dc             	mov    %eax,-0x24(%ebp)

  printf(1, "PID\tName\tUID\tGID\tPPID\tPrio\tElapsed CPU\tState\tSize\n");
  3a:	83 ec 08             	sub    $0x8,%esp
  3d:	68 c4 0b 00 00       	push   $0xbc4
  42:	6a 01                	push   $0x1
  44:	e8 c4 07 00 00       	call   80d <printf>
  49:	83 c4 10             	add    $0x10,%esp


    for(int i = 0; i < processes; ++i)
  4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  53:	e9 a9 02 00 00       	jmp    301 <main+0x301>
    {
	if(p[i].elapsed_ticks > 0) 
  58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  5b:	89 d0                	mov    %edx,%eax
  5d:	01 c0                	add    %eax,%eax
  5f:	01 d0                	add    %edx,%eax
  61:	c1 e0 05             	shl    $0x5,%eax
  64:	89 c2                	mov    %eax,%edx
  66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  69:	01 d0                	add    %edx,%eax
  6b:	8b 40 10             	mov    0x10(%eax),%eax
  6e:	85 c0                	test   %eax,%eax
  70:	0f 84 87 02 00 00    	je     2fd <main+0x2fd>
	{
	    elapsed = p[i].elapsed_ticks/1000;
  76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  79:	89 d0                	mov    %edx,%eax
  7b:	01 c0                	add    %eax,%eax
  7d:	01 d0                	add    %edx,%eax
  7f:	c1 e0 05             	shl    $0x5,%eax
  82:	89 c2                	mov    %eax,%edx
  84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  87:	01 d0                	add    %edx,%eax
  89:	8b 40 10             	mov    0x10(%eax),%eax
  8c:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  91:	f7 e2                	mul    %edx
  93:	89 d0                	mov    %edx,%eax
  95:	c1 e8 06             	shr    $0x6,%eax
  98:	89 45 d8             	mov    %eax,-0x28(%ebp)
	    milli = p[i].elapsed_ticks%1000;
  9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  9e:	89 d0                	mov    %edx,%eax
  a0:	01 c0                	add    %eax,%eax
  a2:	01 d0                	add    %edx,%eax
  a4:	c1 e0 05             	shl    $0x5,%eax
  a7:	89 c2                	mov    %eax,%edx
  a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  ac:	01 d0                	add    %edx,%eax
  ae:	8b 48 10             	mov    0x10(%eax),%ecx
  b1:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  b6:	89 c8                	mov    %ecx,%eax
  b8:	f7 e2                	mul    %edx
  ba:	89 d0                	mov    %edx,%eax
  bc:	c1 e8 06             	shr    $0x6,%eax
  bf:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  c5:	29 c1                	sub    %eax,%ecx
  c7:	89 c8                	mov    %ecx,%eax
  c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    cpue = p[i].CPU_total_ticks/1000;
  cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  cf:	89 d0                	mov    %edx,%eax
  d1:	01 c0                	add    %eax,%eax
  d3:	01 d0                	add    %edx,%eax
  d5:	c1 e0 05             	shl    $0x5,%eax
  d8:	89 c2                	mov    %eax,%edx
  da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  dd:	01 d0                	add    %edx,%eax
  df:	8b 40 14             	mov    0x14(%eax),%eax
  e2:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  e7:	f7 e2                	mul    %edx
  e9:	89 d0                	mov    %edx,%eax
  eb:	c1 e8 06             	shr    $0x6,%eax
  ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    cpum = p[i].CPU_total_ticks%1000;
  f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f4:	89 d0                	mov    %edx,%eax
  f6:	01 c0                	add    %eax,%eax
  f8:	01 d0                	add    %edx,%eax
  fa:	c1 e0 05             	shl    $0x5,%eax
  fd:	89 c2                	mov    %eax,%edx
  ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
 102:	01 d0                	add    %edx,%eax
 104:	8b 48 14             	mov    0x14(%eax),%ecx
 107:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 10c:	89 c8                	mov    %ecx,%eax
 10e:	f7 e2                	mul    %edx
 110:	89 d0                	mov    %edx,%eax
 112:	c1 e8 06             	shr    $0x6,%eax
 115:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 11b:	29 c1                	sub    %eax,%ecx
 11d:	89 c8                	mov    %ecx,%eax
 11f:	89 45 cc             	mov    %eax,-0x34(%ebp)

	    printf(1, "%d\t%s\t%d\t%d\t%d\t%d\t%d", p[i].pid, p[i].name, p[i].uid, p[i].gid, p[i].ppid,p[i].priority, elapsed);
 122:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 125:	89 d0                	mov    %edx,%eax
 127:	01 c0                	add    %eax,%eax
 129:	01 d0                	add    %edx,%eax
 12b:	c1 e0 05             	shl    $0x5,%eax
 12e:	89 c2                	mov    %eax,%edx
 130:	8b 45 e0             	mov    -0x20(%ebp),%eax
 133:	01 d0                	add    %edx,%eax
 135:	8b 78 5c             	mov    0x5c(%eax),%edi
 138:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 13b:	89 d0                	mov    %edx,%eax
 13d:	01 c0                	add    %eax,%eax
 13f:	01 d0                	add    %edx,%eax
 141:	c1 e0 05             	shl    $0x5,%eax
 144:	89 c2                	mov    %eax,%edx
 146:	8b 45 e0             	mov    -0x20(%ebp),%eax
 149:	01 d0                	add    %edx,%eax
 14b:	8b 70 0c             	mov    0xc(%eax),%esi
 14e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 151:	89 d0                	mov    %edx,%eax
 153:	01 c0                	add    %eax,%eax
 155:	01 d0                	add    %edx,%eax
 157:	c1 e0 05             	shl    $0x5,%eax
 15a:	89 c2                	mov    %eax,%edx
 15c:	8b 45 e0             	mov    -0x20(%ebp),%eax
 15f:	01 d0                	add    %edx,%eax
 161:	8b 58 08             	mov    0x8(%eax),%ebx
 164:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 167:	89 d0                	mov    %edx,%eax
 169:	01 c0                	add    %eax,%eax
 16b:	01 d0                	add    %edx,%eax
 16d:	c1 e0 05             	shl    $0x5,%eax
 170:	89 c2                	mov    %eax,%edx
 172:	8b 45 e0             	mov    -0x20(%ebp),%eax
 175:	01 d0                	add    %edx,%eax
 177:	8b 48 04             	mov    0x4(%eax),%ecx
 17a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 17d:	89 d0                	mov    %edx,%eax
 17f:	01 c0                	add    %eax,%eax
 181:	01 d0                	add    %edx,%eax
 183:	c1 e0 05             	shl    $0x5,%eax
 186:	89 c2                	mov    %eax,%edx
 188:	8b 45 e0             	mov    -0x20(%ebp),%eax
 18b:	01 d0                	add    %edx,%eax
 18d:	83 c0 3c             	add    $0x3c,%eax
 190:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 193:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 196:	89 d0                	mov    %edx,%eax
 198:	01 c0                	add    %eax,%eax
 19a:	01 d0                	add    %edx,%eax
 19c:	c1 e0 05             	shl    $0x5,%eax
 19f:	89 c2                	mov    %eax,%edx
 1a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1a4:	01 d0                	add    %edx,%eax
 1a6:	8b 00                	mov    (%eax),%eax
 1a8:	83 ec 0c             	sub    $0xc,%esp
 1ab:	ff 75 d8             	pushl  -0x28(%ebp)
 1ae:	57                   	push   %edi
 1af:	56                   	push   %esi
 1b0:	53                   	push   %ebx
 1b1:	51                   	push   %ecx
 1b2:	ff 75 c4             	pushl  -0x3c(%ebp)
 1b5:	50                   	push   %eax
 1b6:	68 f7 0b 00 00       	push   $0xbf7
 1bb:	6a 01                	push   $0x1
 1bd:	e8 4b 06 00 00       	call   80d <printf>
 1c2:	83 c4 30             	add    $0x30,%esp

	    if(milli < 10)
 1c5:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
 1c9:	7f 15                	jg     1e0 <main+0x1e0>
		printf(1, "00%d\t%d.", milli, cpue);
 1cb:	ff 75 d0             	pushl  -0x30(%ebp)
 1ce:	ff 75 d4             	pushl  -0x2c(%ebp)
 1d1:	68 0c 0c 00 00       	push   $0xc0c
 1d6:	6a 01                	push   $0x1
 1d8:	e8 30 06 00 00       	call   80d <printf>
 1dd:	83 c4 10             	add    $0x10,%esp
	    if(milli > 9 && milli < 100)
 1e0:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
 1e4:	7e 1b                	jle    201 <main+0x201>
 1e6:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
 1ea:	7f 15                	jg     201 <main+0x201>
		printf(1, "0%d\t%d.", milli, cpue);
 1ec:	ff 75 d0             	pushl  -0x30(%ebp)
 1ef:	ff 75 d4             	pushl  -0x2c(%ebp)
 1f2:	68 15 0c 00 00       	push   $0xc15
 1f7:	6a 01                	push   $0x1
 1f9:	e8 0f 06 00 00       	call   80d <printf>
 1fe:	83 c4 10             	add    $0x10,%esp
	    if(milli > 100)
 201:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
 205:	7e 15                	jle    21c <main+0x21c>
		printf(1, "%d\t%d.", milli, cpue);
 207:	ff 75 d0             	pushl  -0x30(%ebp)
 20a:	ff 75 d4             	pushl  -0x2c(%ebp)
 20d:	68 1d 0c 00 00       	push   $0xc1d
 212:	6a 01                	push   $0x1
 214:	e8 f4 05 00 00       	call   80d <printf>
 219:	83 c4 10             	add    $0x10,%esp

	    if(cpum < 10)    
 21c:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
 220:	7f 43                	jg     265 <main+0x265>
		printf(1, "00%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
 222:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 225:	89 d0                	mov    %edx,%eax
 227:	01 c0                	add    %eax,%eax
 229:	01 d0                	add    %edx,%eax
 22b:	c1 e0 05             	shl    $0x5,%eax
 22e:	89 c2                	mov    %eax,%edx
 230:	8b 45 e0             	mov    -0x20(%ebp),%eax
 233:	01 d0                	add    %edx,%eax
 235:	8b 48 38             	mov    0x38(%eax),%ecx
 238:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 23b:	89 d0                	mov    %edx,%eax
 23d:	01 c0                	add    %eax,%eax
 23f:	01 d0                	add    %edx,%eax
 241:	c1 e0 05             	shl    $0x5,%eax
 244:	89 c2                	mov    %eax,%edx
 246:	8b 45 e0             	mov    -0x20(%ebp),%eax
 249:	01 d0                	add    %edx,%eax
 24b:	83 c0 18             	add    $0x18,%eax
 24e:	83 ec 0c             	sub    $0xc,%esp
 251:	51                   	push   %ecx
 252:	50                   	push   %eax
 253:	ff 75 cc             	pushl  -0x34(%ebp)
 256:	68 24 0c 00 00       	push   $0xc24
 25b:	6a 01                	push   $0x1
 25d:	e8 ab 05 00 00       	call   80d <printf>
 262:	83 c4 20             	add    $0x20,%esp
	    if(cpum > 9 && cpum < 100)
 265:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
 269:	7e 49                	jle    2b4 <main+0x2b4>
 26b:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
 26f:	7f 43                	jg     2b4 <main+0x2b4>
		printf(1, "0%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
 271:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 274:	89 d0                	mov    %edx,%eax
 276:	01 c0                	add    %eax,%eax
 278:	01 d0                	add    %edx,%eax
 27a:	c1 e0 05             	shl    $0x5,%eax
 27d:	89 c2                	mov    %eax,%edx
 27f:	8b 45 e0             	mov    -0x20(%ebp),%eax
 282:	01 d0                	add    %edx,%eax
 284:	8b 48 38             	mov    0x38(%eax),%ecx
 287:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 28a:	89 d0                	mov    %edx,%eax
 28c:	01 c0                	add    %eax,%eax
 28e:	01 d0                	add    %edx,%eax
 290:	c1 e0 05             	shl    $0x5,%eax
 293:	89 c2                	mov    %eax,%edx
 295:	8b 45 e0             	mov    -0x20(%ebp),%eax
 298:	01 d0                	add    %edx,%eax
 29a:	83 c0 18             	add    $0x18,%eax
 29d:	83 ec 0c             	sub    $0xc,%esp
 2a0:	51                   	push   %ecx
 2a1:	50                   	push   %eax
 2a2:	ff 75 cc             	pushl  -0x34(%ebp)
 2a5:	68 30 0c 00 00       	push   $0xc30
 2aa:	6a 01                	push   $0x1
 2ac:	e8 5c 05 00 00       	call   80d <printf>
 2b1:	83 c4 20             	add    $0x20,%esp
	    if(cpum > 100)
 2b4:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
 2b8:	7e 43                	jle    2fd <main+0x2fd>
		printf(1, "%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
 2ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2bd:	89 d0                	mov    %edx,%eax
 2bf:	01 c0                	add    %eax,%eax
 2c1:	01 d0                	add    %edx,%eax
 2c3:	c1 e0 05             	shl    $0x5,%eax
 2c6:	89 c2                	mov    %eax,%edx
 2c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 2cb:	01 d0                	add    %edx,%eax
 2cd:	8b 48 38             	mov    0x38(%eax),%ecx
 2d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2d3:	89 d0                	mov    %edx,%eax
 2d5:	01 c0                	add    %eax,%eax
 2d7:	01 d0                	add    %edx,%eax
 2d9:	c1 e0 05             	shl    $0x5,%eax
 2dc:	89 c2                	mov    %eax,%edx
 2de:	8b 45 e0             	mov    -0x20(%ebp),%eax
 2e1:	01 d0                	add    %edx,%eax
 2e3:	83 c0 18             	add    $0x18,%eax
 2e6:	83 ec 0c             	sub    $0xc,%esp
 2e9:	51                   	push   %ecx
 2ea:	50                   	push   %eax
 2eb:	ff 75 cc             	pushl  -0x34(%ebp)
 2ee:	68 3b 0c 00 00       	push   $0xc3b
 2f3:	6a 01                	push   $0x1
 2f5:	e8 13 05 00 00       	call   80d <printf>
 2fa:	83 c4 20             	add    $0x20,%esp
  int processes = getprocs(MAXPROC, p);

  printf(1, "PID\tName\tUID\tGID\tPPID\tPrio\tElapsed CPU\tState\tSize\n");


    for(int i = 0; i < processes; ++i)
 2fd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 301:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 304:	3b 45 dc             	cmp    -0x24(%ebp),%eax
 307:	0f 8c 4b fd ff ff    	jl     58 <main+0x58>
	    if(cpum > 100)
		printf(1, "%d\t%s\t%d\n", cpum, p[i].state, p[i].size);

	}
    }
    printf(1, "\n");
 30d:	83 ec 08             	sub    $0x8,%esp
 310:	68 45 0c 00 00       	push   $0xc45
 315:	6a 01                	push   $0x1
 317:	e8 f1 04 00 00       	call   80d <printf>
 31c:	83 c4 10             	add    $0x10,%esp

  exit();
 31f:	e8 2a 03 00 00       	call   64e <exit>

00000324 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 324:	55                   	push   %ebp
 325:	89 e5                	mov    %esp,%ebp
 327:	57                   	push   %edi
 328:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 329:	8b 4d 08             	mov    0x8(%ebp),%ecx
 32c:	8b 55 10             	mov    0x10(%ebp),%edx
 32f:	8b 45 0c             	mov    0xc(%ebp),%eax
 332:	89 cb                	mov    %ecx,%ebx
 334:	89 df                	mov    %ebx,%edi
 336:	89 d1                	mov    %edx,%ecx
 338:	fc                   	cld    
 339:	f3 aa                	rep stos %al,%es:(%edi)
 33b:	89 ca                	mov    %ecx,%edx
 33d:	89 fb                	mov    %edi,%ebx
 33f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 342:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 345:	90                   	nop
 346:	5b                   	pop    %ebx
 347:	5f                   	pop    %edi
 348:	5d                   	pop    %ebp
 349:	c3                   	ret    

0000034a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 350:	8b 45 08             	mov    0x8(%ebp),%eax
 353:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 356:	90                   	nop
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	8d 50 01             	lea    0x1(%eax),%edx
 35d:	89 55 08             	mov    %edx,0x8(%ebp)
 360:	8b 55 0c             	mov    0xc(%ebp),%edx
 363:	8d 4a 01             	lea    0x1(%edx),%ecx
 366:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 369:	0f b6 12             	movzbl (%edx),%edx
 36c:	88 10                	mov    %dl,(%eax)
 36e:	0f b6 00             	movzbl (%eax),%eax
 371:	84 c0                	test   %al,%al
 373:	75 e2                	jne    357 <strcpy+0xd>
    ;
  return os;
 375:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 378:	c9                   	leave  
 379:	c3                   	ret    

0000037a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 37d:	eb 08                	jmp    387 <strcmp+0xd>
    p++, q++;
 37f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 383:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	0f b6 00             	movzbl (%eax),%eax
 38d:	84 c0                	test   %al,%al
 38f:	74 10                	je     3a1 <strcmp+0x27>
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	0f b6 10             	movzbl (%eax),%edx
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	0f b6 00             	movzbl (%eax),%eax
 39d:	38 c2                	cmp    %al,%dl
 39f:	74 de                	je     37f <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	0f b6 d0             	movzbl %al,%edx
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	0f b6 c0             	movzbl %al,%eax
 3b3:	29 c2                	sub    %eax,%edx
 3b5:	89 d0                	mov    %edx,%eax
}
 3b7:	5d                   	pop    %ebp
 3b8:	c3                   	ret    

000003b9 <strlen>:

uint
strlen(char *s)
{
 3b9:	55                   	push   %ebp
 3ba:	89 e5                	mov    %esp,%ebp
 3bc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3c6:	eb 04                	jmp    3cc <strlen+0x13>
 3c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	01 d0                	add    %edx,%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	84 c0                	test   %al,%al
 3d9:	75 ed                	jne    3c8 <strlen+0xf>
    ;
  return n;
 3db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3e3:	8b 45 10             	mov    0x10(%ebp),%eax
 3e6:	50                   	push   %eax
 3e7:	ff 75 0c             	pushl  0xc(%ebp)
 3ea:	ff 75 08             	pushl  0x8(%ebp)
 3ed:	e8 32 ff ff ff       	call   324 <stosb>
 3f2:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f8:	c9                   	leave  
 3f9:	c3                   	ret    

000003fa <strchr>:

char*
strchr(const char *s, char c)
{
 3fa:	55                   	push   %ebp
 3fb:	89 e5                	mov    %esp,%ebp
 3fd:	83 ec 04             	sub    $0x4,%esp
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 406:	eb 14                	jmp    41c <strchr+0x22>
    if(*s == c)
 408:	8b 45 08             	mov    0x8(%ebp),%eax
 40b:	0f b6 00             	movzbl (%eax),%eax
 40e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 411:	75 05                	jne    418 <strchr+0x1e>
      return (char*)s;
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	eb 13                	jmp    42b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 418:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 41c:	8b 45 08             	mov    0x8(%ebp),%eax
 41f:	0f b6 00             	movzbl (%eax),%eax
 422:	84 c0                	test   %al,%al
 424:	75 e2                	jne    408 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 426:	b8 00 00 00 00       	mov    $0x0,%eax
}
 42b:	c9                   	leave  
 42c:	c3                   	ret    

0000042d <gets>:

char*
gets(char *buf, int max)
{
 42d:	55                   	push   %ebp
 42e:	89 e5                	mov    %esp,%ebp
 430:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 433:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 43a:	eb 42                	jmp    47e <gets+0x51>
    cc = read(0, &c, 1);
 43c:	83 ec 04             	sub    $0x4,%esp
 43f:	6a 01                	push   $0x1
 441:	8d 45 ef             	lea    -0x11(%ebp),%eax
 444:	50                   	push   %eax
 445:	6a 00                	push   $0x0
 447:	e8 1a 02 00 00       	call   666 <read>
 44c:	83 c4 10             	add    $0x10,%esp
 44f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 452:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 456:	7e 33                	jle    48b <gets+0x5e>
      break;
    buf[i++] = c;
 458:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45b:	8d 50 01             	lea    0x1(%eax),%edx
 45e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 461:	89 c2                	mov    %eax,%edx
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	01 c2                	add    %eax,%edx
 468:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 46c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 46e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 472:	3c 0a                	cmp    $0xa,%al
 474:	74 16                	je     48c <gets+0x5f>
 476:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47a:	3c 0d                	cmp    $0xd,%al
 47c:	74 0e                	je     48c <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 47e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 481:	83 c0 01             	add    $0x1,%eax
 484:	3b 45 0c             	cmp    0xc(%ebp),%eax
 487:	7c b3                	jl     43c <gets+0xf>
 489:	eb 01                	jmp    48c <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 48b:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 48c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	01 d0                	add    %edx,%eax
 494:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 497:	8b 45 08             	mov    0x8(%ebp),%eax
}
 49a:	c9                   	leave  
 49b:	c3                   	ret    

0000049c <stat>:

int
stat(char *n, struct stat *st)
{
 49c:	55                   	push   %ebp
 49d:	89 e5                	mov    %esp,%ebp
 49f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a2:	83 ec 08             	sub    $0x8,%esp
 4a5:	6a 00                	push   $0x0
 4a7:	ff 75 08             	pushl  0x8(%ebp)
 4aa:	e8 df 01 00 00       	call   68e <open>
 4af:	83 c4 10             	add    $0x10,%esp
 4b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4b9:	79 07                	jns    4c2 <stat+0x26>
    return -1;
 4bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4c0:	eb 25                	jmp    4e7 <stat+0x4b>
  r = fstat(fd, st);
 4c2:	83 ec 08             	sub    $0x8,%esp
 4c5:	ff 75 0c             	pushl  0xc(%ebp)
 4c8:	ff 75 f4             	pushl  -0xc(%ebp)
 4cb:	e8 d6 01 00 00       	call   6a6 <fstat>
 4d0:	83 c4 10             	add    $0x10,%esp
 4d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4d6:	83 ec 0c             	sub    $0xc,%esp
 4d9:	ff 75 f4             	pushl  -0xc(%ebp)
 4dc:	e8 95 01 00 00       	call   676 <close>
 4e1:	83 c4 10             	add    $0x10,%esp
  return r;
 4e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4e7:	c9                   	leave  
 4e8:	c3                   	ret    

000004e9 <atoi>:

int
atoi(const char *s)
{
 4e9:	55                   	push   %ebp
 4ea:	89 e5                	mov    %esp,%ebp
 4ec:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4f6:	eb 04                	jmp    4fc <atoi+0x13>
 4f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
 4ff:	0f b6 00             	movzbl (%eax),%eax
 502:	3c 20                	cmp    $0x20,%al
 504:	74 f2                	je     4f8 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 506:	8b 45 08             	mov    0x8(%ebp),%eax
 509:	0f b6 00             	movzbl (%eax),%eax
 50c:	3c 2d                	cmp    $0x2d,%al
 50e:	75 07                	jne    517 <atoi+0x2e>
 510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 515:	eb 05                	jmp    51c <atoi+0x33>
 517:	b8 01 00 00 00       	mov    $0x1,%eax
 51c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 51f:	8b 45 08             	mov    0x8(%ebp),%eax
 522:	0f b6 00             	movzbl (%eax),%eax
 525:	3c 2b                	cmp    $0x2b,%al
 527:	74 0a                	je     533 <atoi+0x4a>
 529:	8b 45 08             	mov    0x8(%ebp),%eax
 52c:	0f b6 00             	movzbl (%eax),%eax
 52f:	3c 2d                	cmp    $0x2d,%al
 531:	75 2b                	jne    55e <atoi+0x75>
    s++;
 533:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 537:	eb 25                	jmp    55e <atoi+0x75>
    n = n*10 + *s++ - '0';
 539:	8b 55 fc             	mov    -0x4(%ebp),%edx
 53c:	89 d0                	mov    %edx,%eax
 53e:	c1 e0 02             	shl    $0x2,%eax
 541:	01 d0                	add    %edx,%eax
 543:	01 c0                	add    %eax,%eax
 545:	89 c1                	mov    %eax,%ecx
 547:	8b 45 08             	mov    0x8(%ebp),%eax
 54a:	8d 50 01             	lea    0x1(%eax),%edx
 54d:	89 55 08             	mov    %edx,0x8(%ebp)
 550:	0f b6 00             	movzbl (%eax),%eax
 553:	0f be c0             	movsbl %al,%eax
 556:	01 c8                	add    %ecx,%eax
 558:	83 e8 30             	sub    $0x30,%eax
 55b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 55e:	8b 45 08             	mov    0x8(%ebp),%eax
 561:	0f b6 00             	movzbl (%eax),%eax
 564:	3c 2f                	cmp    $0x2f,%al
 566:	7e 0a                	jle    572 <atoi+0x89>
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	0f b6 00             	movzbl (%eax),%eax
 56e:	3c 39                	cmp    $0x39,%al
 570:	7e c7                	jle    539 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 572:	8b 45 f8             	mov    -0x8(%ebp),%eax
 575:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 579:	c9                   	leave  
 57a:	c3                   	ret    

0000057b <atoo>:

int
atoo(const char *s)
{
 57b:	55                   	push   %ebp
 57c:	89 e5                	mov    %esp,%ebp
 57e:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 581:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 588:	eb 04                	jmp    58e <atoo+0x13>
 58a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 58e:	8b 45 08             	mov    0x8(%ebp),%eax
 591:	0f b6 00             	movzbl (%eax),%eax
 594:	3c 20                	cmp    $0x20,%al
 596:	74 f2                	je     58a <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	0f b6 00             	movzbl (%eax),%eax
 59e:	3c 2d                	cmp    $0x2d,%al
 5a0:	75 07                	jne    5a9 <atoo+0x2e>
 5a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5a7:	eb 05                	jmp    5ae <atoo+0x33>
 5a9:	b8 01 00 00 00       	mov    $0x1,%eax
 5ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 5b1:	8b 45 08             	mov    0x8(%ebp),%eax
 5b4:	0f b6 00             	movzbl (%eax),%eax
 5b7:	3c 2b                	cmp    $0x2b,%al
 5b9:	74 0a                	je     5c5 <atoo+0x4a>
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	3c 2d                	cmp    $0x2d,%al
 5c3:	75 27                	jne    5ec <atoo+0x71>
    s++;
 5c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 5c9:	eb 21                	jmp    5ec <atoo+0x71>
    n = n*8 + *s++ - '0';
 5cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ce:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	8d 50 01             	lea    0x1(%eax),%edx
 5db:	89 55 08             	mov    %edx,0x8(%ebp)
 5de:	0f b6 00             	movzbl (%eax),%eax
 5e1:	0f be c0             	movsbl %al,%eax
 5e4:	01 c8                	add    %ecx,%eax
 5e6:	83 e8 30             	sub    $0x30,%eax
 5e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
 5ef:	0f b6 00             	movzbl (%eax),%eax
 5f2:	3c 2f                	cmp    $0x2f,%al
 5f4:	7e 0a                	jle    600 <atoo+0x85>
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	3c 37                	cmp    $0x37,%al
 5fe:	7e cb                	jle    5cb <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 600:	8b 45 f8             	mov    -0x8(%ebp),%eax
 603:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 607:	c9                   	leave  
 608:	c3                   	ret    

00000609 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 615:	8b 45 0c             	mov    0xc(%ebp),%eax
 618:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 61b:	eb 17                	jmp    634 <memmove+0x2b>
    *dst++ = *src++;
 61d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 620:	8d 50 01             	lea    0x1(%eax),%edx
 623:	89 55 fc             	mov    %edx,-0x4(%ebp)
 626:	8b 55 f8             	mov    -0x8(%ebp),%edx
 629:	8d 4a 01             	lea    0x1(%edx),%ecx
 62c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 62f:	0f b6 12             	movzbl (%edx),%edx
 632:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 634:	8b 45 10             	mov    0x10(%ebp),%eax
 637:	8d 50 ff             	lea    -0x1(%eax),%edx
 63a:	89 55 10             	mov    %edx,0x10(%ebp)
 63d:	85 c0                	test   %eax,%eax
 63f:	7f dc                	jg     61d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 641:	8b 45 08             	mov    0x8(%ebp),%eax
}
 644:	c9                   	leave  
 645:	c3                   	ret    

00000646 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 646:	b8 01 00 00 00       	mov    $0x1,%eax
 64b:	cd 40                	int    $0x40
 64d:	c3                   	ret    

0000064e <exit>:
SYSCALL(exit)
 64e:	b8 02 00 00 00       	mov    $0x2,%eax
 653:	cd 40                	int    $0x40
 655:	c3                   	ret    

00000656 <wait>:
SYSCALL(wait)
 656:	b8 03 00 00 00       	mov    $0x3,%eax
 65b:	cd 40                	int    $0x40
 65d:	c3                   	ret    

0000065e <pipe>:
SYSCALL(pipe)
 65e:	b8 04 00 00 00       	mov    $0x4,%eax
 663:	cd 40                	int    $0x40
 665:	c3                   	ret    

00000666 <read>:
SYSCALL(read)
 666:	b8 05 00 00 00       	mov    $0x5,%eax
 66b:	cd 40                	int    $0x40
 66d:	c3                   	ret    

0000066e <write>:
SYSCALL(write)
 66e:	b8 10 00 00 00       	mov    $0x10,%eax
 673:	cd 40                	int    $0x40
 675:	c3                   	ret    

00000676 <close>:
SYSCALL(close)
 676:	b8 15 00 00 00       	mov    $0x15,%eax
 67b:	cd 40                	int    $0x40
 67d:	c3                   	ret    

0000067e <kill>:
SYSCALL(kill)
 67e:	b8 06 00 00 00       	mov    $0x6,%eax
 683:	cd 40                	int    $0x40
 685:	c3                   	ret    

00000686 <exec>:
SYSCALL(exec)
 686:	b8 07 00 00 00       	mov    $0x7,%eax
 68b:	cd 40                	int    $0x40
 68d:	c3                   	ret    

0000068e <open>:
SYSCALL(open)
 68e:	b8 0f 00 00 00       	mov    $0xf,%eax
 693:	cd 40                	int    $0x40
 695:	c3                   	ret    

00000696 <mknod>:
SYSCALL(mknod)
 696:	b8 11 00 00 00       	mov    $0x11,%eax
 69b:	cd 40                	int    $0x40
 69d:	c3                   	ret    

0000069e <unlink>:
SYSCALL(unlink)
 69e:	b8 12 00 00 00       	mov    $0x12,%eax
 6a3:	cd 40                	int    $0x40
 6a5:	c3                   	ret    

000006a6 <fstat>:
SYSCALL(fstat)
 6a6:	b8 08 00 00 00       	mov    $0x8,%eax
 6ab:	cd 40                	int    $0x40
 6ad:	c3                   	ret    

000006ae <link>:
SYSCALL(link)
 6ae:	b8 13 00 00 00       	mov    $0x13,%eax
 6b3:	cd 40                	int    $0x40
 6b5:	c3                   	ret    

000006b6 <mkdir>:
SYSCALL(mkdir)
 6b6:	b8 14 00 00 00       	mov    $0x14,%eax
 6bb:	cd 40                	int    $0x40
 6bd:	c3                   	ret    

000006be <chdir>:
SYSCALL(chdir)
 6be:	b8 09 00 00 00       	mov    $0x9,%eax
 6c3:	cd 40                	int    $0x40
 6c5:	c3                   	ret    

000006c6 <dup>:
SYSCALL(dup)
 6c6:	b8 0a 00 00 00       	mov    $0xa,%eax
 6cb:	cd 40                	int    $0x40
 6cd:	c3                   	ret    

000006ce <getpid>:
SYSCALL(getpid)
 6ce:	b8 0b 00 00 00       	mov    $0xb,%eax
 6d3:	cd 40                	int    $0x40
 6d5:	c3                   	ret    

000006d6 <sbrk>:
SYSCALL(sbrk)
 6d6:	b8 0c 00 00 00       	mov    $0xc,%eax
 6db:	cd 40                	int    $0x40
 6dd:	c3                   	ret    

000006de <sleep>:
SYSCALL(sleep)
 6de:	b8 0d 00 00 00       	mov    $0xd,%eax
 6e3:	cd 40                	int    $0x40
 6e5:	c3                   	ret    

000006e6 <uptime>:
SYSCALL(uptime)
 6e6:	b8 0e 00 00 00       	mov    $0xe,%eax
 6eb:	cd 40                	int    $0x40
 6ed:	c3                   	ret    

000006ee <halt>:
SYSCALL(halt)
 6ee:	b8 16 00 00 00       	mov    $0x16,%eax
 6f3:	cd 40                	int    $0x40
 6f5:	c3                   	ret    

000006f6 <date>:
SYSCALL(date)
 6f6:	b8 17 00 00 00       	mov    $0x17,%eax
 6fb:	cd 40                	int    $0x40
 6fd:	c3                   	ret    

000006fe <getuid>:
SYSCALL(getuid)
 6fe:	b8 18 00 00 00       	mov    $0x18,%eax
 703:	cd 40                	int    $0x40
 705:	c3                   	ret    

00000706 <getgid>:
SYSCALL(getgid)
 706:	b8 19 00 00 00       	mov    $0x19,%eax
 70b:	cd 40                	int    $0x40
 70d:	c3                   	ret    

0000070e <getppid>:
SYSCALL(getppid)
 70e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 713:	cd 40                	int    $0x40
 715:	c3                   	ret    

00000716 <setuid>:
SYSCALL(setuid)
 716:	b8 1b 00 00 00       	mov    $0x1b,%eax
 71b:	cd 40                	int    $0x40
 71d:	c3                   	ret    

0000071e <setgid>:
SYSCALL(setgid)
 71e:	b8 1c 00 00 00       	mov    $0x1c,%eax
 723:	cd 40                	int    $0x40
 725:	c3                   	ret    

00000726 <getprocs>:
SYSCALL(getprocs)
 726:	b8 1a 00 00 00       	mov    $0x1a,%eax
 72b:	cd 40                	int    $0x40
 72d:	c3                   	ret    

0000072e <setpriority>:
SYSCALL(setpriority)
 72e:	b8 1b 00 00 00       	mov    $0x1b,%eax
 733:	cd 40                	int    $0x40
 735:	c3                   	ret    

00000736 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 736:	55                   	push   %ebp
 737:	89 e5                	mov    %esp,%ebp
 739:	83 ec 18             	sub    $0x18,%esp
 73c:	8b 45 0c             	mov    0xc(%ebp),%eax
 73f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 742:	83 ec 04             	sub    $0x4,%esp
 745:	6a 01                	push   $0x1
 747:	8d 45 f4             	lea    -0xc(%ebp),%eax
 74a:	50                   	push   %eax
 74b:	ff 75 08             	pushl  0x8(%ebp)
 74e:	e8 1b ff ff ff       	call   66e <write>
 753:	83 c4 10             	add    $0x10,%esp
}
 756:	90                   	nop
 757:	c9                   	leave  
 758:	c3                   	ret    

00000759 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 759:	55                   	push   %ebp
 75a:	89 e5                	mov    %esp,%ebp
 75c:	53                   	push   %ebx
 75d:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 760:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 767:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 76b:	74 17                	je     784 <printint+0x2b>
 76d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 771:	79 11                	jns    784 <printint+0x2b>
    neg = 1;
 773:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 77a:	8b 45 0c             	mov    0xc(%ebp),%eax
 77d:	f7 d8                	neg    %eax
 77f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 782:	eb 06                	jmp    78a <printint+0x31>
  } else {
    x = xx;
 784:	8b 45 0c             	mov    0xc(%ebp),%eax
 787:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 78a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 791:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 794:	8d 41 01             	lea    0x1(%ecx),%eax
 797:	89 45 f4             	mov    %eax,-0xc(%ebp)
 79a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 79d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7a0:	ba 00 00 00 00       	mov    $0x0,%edx
 7a5:	f7 f3                	div    %ebx
 7a7:	89 d0                	mov    %edx,%eax
 7a9:	0f b6 80 c4 0e 00 00 	movzbl 0xec4(%eax),%eax
 7b0:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 7b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ba:	ba 00 00 00 00       	mov    $0x0,%edx
 7bf:	f7 f3                	div    %ebx
 7c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7c8:	75 c7                	jne    791 <printint+0x38>
  if(neg)
 7ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ce:	74 2d                	je     7fd <printint+0xa4>
    buf[i++] = '-';
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	8d 50 01             	lea    0x1(%eax),%edx
 7d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7d9:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7de:	eb 1d                	jmp    7fd <printint+0xa4>
    putc(fd, buf[i]);
 7e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e6:	01 d0                	add    %edx,%eax
 7e8:	0f b6 00             	movzbl (%eax),%eax
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	83 ec 08             	sub    $0x8,%esp
 7f1:	50                   	push   %eax
 7f2:	ff 75 08             	pushl  0x8(%ebp)
 7f5:	e8 3c ff ff ff       	call   736 <putc>
 7fa:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7fd:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 801:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 805:	79 d9                	jns    7e0 <printint+0x87>
    putc(fd, buf[i]);
}
 807:	90                   	nop
 808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 80b:	c9                   	leave  
 80c:	c3                   	ret    

0000080d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 80d:	55                   	push   %ebp
 80e:	89 e5                	mov    %esp,%ebp
 810:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 813:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 81a:	8d 45 0c             	lea    0xc(%ebp),%eax
 81d:	83 c0 04             	add    $0x4,%eax
 820:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 823:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 82a:	e9 59 01 00 00       	jmp    988 <printf+0x17b>
    c = fmt[i] & 0xff;
 82f:	8b 55 0c             	mov    0xc(%ebp),%edx
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	01 d0                	add    %edx,%eax
 837:	0f b6 00             	movzbl (%eax),%eax
 83a:	0f be c0             	movsbl %al,%eax
 83d:	25 ff 00 00 00       	and    $0xff,%eax
 842:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 845:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 849:	75 2c                	jne    877 <printf+0x6a>
      if(c == '%'){
 84b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84f:	75 0c                	jne    85d <printf+0x50>
        state = '%';
 851:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 858:	e9 27 01 00 00       	jmp    984 <printf+0x177>
      } else {
        putc(fd, c);
 85d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 860:	0f be c0             	movsbl %al,%eax
 863:	83 ec 08             	sub    $0x8,%esp
 866:	50                   	push   %eax
 867:	ff 75 08             	pushl  0x8(%ebp)
 86a:	e8 c7 fe ff ff       	call   736 <putc>
 86f:	83 c4 10             	add    $0x10,%esp
 872:	e9 0d 01 00 00       	jmp    984 <printf+0x177>
      }
    } else if(state == '%'){
 877:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 87b:	0f 85 03 01 00 00    	jne    984 <printf+0x177>
      if(c == 'd'){
 881:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 885:	75 1e                	jne    8a5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 887:	8b 45 e8             	mov    -0x18(%ebp),%eax
 88a:	8b 00                	mov    (%eax),%eax
 88c:	6a 01                	push   $0x1
 88e:	6a 0a                	push   $0xa
 890:	50                   	push   %eax
 891:	ff 75 08             	pushl  0x8(%ebp)
 894:	e8 c0 fe ff ff       	call   759 <printint>
 899:	83 c4 10             	add    $0x10,%esp
        ap++;
 89c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a0:	e9 d8 00 00 00       	jmp    97d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 8a5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8a9:	74 06                	je     8b1 <printf+0xa4>
 8ab:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8af:	75 1e                	jne    8cf <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b4:	8b 00                	mov    (%eax),%eax
 8b6:	6a 00                	push   $0x0
 8b8:	6a 10                	push   $0x10
 8ba:	50                   	push   %eax
 8bb:	ff 75 08             	pushl  0x8(%ebp)
 8be:	e8 96 fe ff ff       	call   759 <printint>
 8c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 8c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8ca:	e9 ae 00 00 00       	jmp    97d <printf+0x170>
      } else if(c == 's'){
 8cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8d3:	75 43                	jne    918 <printf+0x10b>
        s = (char*)*ap;
 8d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e5:	75 25                	jne    90c <printf+0xff>
          s = "(null)";
 8e7:	c7 45 f4 47 0c 00 00 	movl   $0xc47,-0xc(%ebp)
        while(*s != 0){
 8ee:	eb 1c                	jmp    90c <printf+0xff>
          putc(fd, *s);
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	0f b6 00             	movzbl (%eax),%eax
 8f6:	0f be c0             	movsbl %al,%eax
 8f9:	83 ec 08             	sub    $0x8,%esp
 8fc:	50                   	push   %eax
 8fd:	ff 75 08             	pushl  0x8(%ebp)
 900:	e8 31 fe ff ff       	call   736 <putc>
 905:	83 c4 10             	add    $0x10,%esp
          s++;
 908:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	0f b6 00             	movzbl (%eax),%eax
 912:	84 c0                	test   %al,%al
 914:	75 da                	jne    8f0 <printf+0xe3>
 916:	eb 65                	jmp    97d <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 918:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 91c:	75 1d                	jne    93b <printf+0x12e>
        putc(fd, *ap);
 91e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 921:	8b 00                	mov    (%eax),%eax
 923:	0f be c0             	movsbl %al,%eax
 926:	83 ec 08             	sub    $0x8,%esp
 929:	50                   	push   %eax
 92a:	ff 75 08             	pushl  0x8(%ebp)
 92d:	e8 04 fe ff ff       	call   736 <putc>
 932:	83 c4 10             	add    $0x10,%esp
        ap++;
 935:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 939:	eb 42                	jmp    97d <printf+0x170>
      } else if(c == '%'){
 93b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 93f:	75 17                	jne    958 <printf+0x14b>
        putc(fd, c);
 941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 944:	0f be c0             	movsbl %al,%eax
 947:	83 ec 08             	sub    $0x8,%esp
 94a:	50                   	push   %eax
 94b:	ff 75 08             	pushl  0x8(%ebp)
 94e:	e8 e3 fd ff ff       	call   736 <putc>
 953:	83 c4 10             	add    $0x10,%esp
 956:	eb 25                	jmp    97d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 958:	83 ec 08             	sub    $0x8,%esp
 95b:	6a 25                	push   $0x25
 95d:	ff 75 08             	pushl  0x8(%ebp)
 960:	e8 d1 fd ff ff       	call   736 <putc>
 965:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 96b:	0f be c0             	movsbl %al,%eax
 96e:	83 ec 08             	sub    $0x8,%esp
 971:	50                   	push   %eax
 972:	ff 75 08             	pushl  0x8(%ebp)
 975:	e8 bc fd ff ff       	call   736 <putc>
 97a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 97d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 984:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 988:	8b 55 0c             	mov    0xc(%ebp),%edx
 98b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98e:	01 d0                	add    %edx,%eax
 990:	0f b6 00             	movzbl (%eax),%eax
 993:	84 c0                	test   %al,%al
 995:	0f 85 94 fe ff ff    	jne    82f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 99b:	90                   	nop
 99c:	c9                   	leave  
 99d:	c3                   	ret    

0000099e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 99e:	55                   	push   %ebp
 99f:	89 e5                	mov    %esp,%ebp
 9a1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9a4:	8b 45 08             	mov    0x8(%ebp),%eax
 9a7:	83 e8 08             	sub    $0x8,%eax
 9aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ad:	a1 e0 0e 00 00       	mov    0xee0,%eax
 9b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9b5:	eb 24                	jmp    9db <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	8b 00                	mov    (%eax),%eax
 9bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9bf:	77 12                	ja     9d3 <free+0x35>
 9c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c7:	77 24                	ja     9ed <free+0x4f>
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	8b 00                	mov    (%eax),%eax
 9ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9d1:	77 1a                	ja     9ed <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d6:	8b 00                	mov    (%eax),%eax
 9d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e1:	76 d4                	jbe    9b7 <free+0x19>
 9e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e6:	8b 00                	mov    (%eax),%eax
 9e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9eb:	76 ca                	jbe    9b7 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 9ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f0:	8b 40 04             	mov    0x4(%eax),%eax
 9f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fd:	01 c2                	add    %eax,%edx
 9ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a02:	8b 00                	mov    (%eax),%eax
 a04:	39 c2                	cmp    %eax,%edx
 a06:	75 24                	jne    a2c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a08:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0b:	8b 50 04             	mov    0x4(%eax),%edx
 a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a11:	8b 00                	mov    (%eax),%eax
 a13:	8b 40 04             	mov    0x4(%eax),%eax
 a16:	01 c2                	add    %eax,%edx
 a18:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a21:	8b 00                	mov    (%eax),%eax
 a23:	8b 10                	mov    (%eax),%edx
 a25:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a28:	89 10                	mov    %edx,(%eax)
 a2a:	eb 0a                	jmp    a36 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2f:	8b 10                	mov    (%eax),%edx
 a31:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a34:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a36:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a39:	8b 40 04             	mov    0x4(%eax),%eax
 a3c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a43:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a46:	01 d0                	add    %edx,%eax
 a48:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a4b:	75 20                	jne    a6d <free+0xcf>
    p->s.size += bp->s.size;
 a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a50:	8b 50 04             	mov    0x4(%eax),%edx
 a53:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a56:	8b 40 04             	mov    0x4(%eax),%eax
 a59:	01 c2                	add    %eax,%edx
 a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a61:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a64:	8b 10                	mov    (%eax),%edx
 a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a69:	89 10                	mov    %edx,(%eax)
 a6b:	eb 08                	jmp    a75 <free+0xd7>
  } else
    p->s.ptr = bp;
 a6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a70:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a73:	89 10                	mov    %edx,(%eax)
  freep = p;
 a75:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a78:	a3 e0 0e 00 00       	mov    %eax,0xee0
}
 a7d:	90                   	nop
 a7e:	c9                   	leave  
 a7f:	c3                   	ret    

00000a80 <morecore>:

static Header*
morecore(uint nu)
{
 a80:	55                   	push   %ebp
 a81:	89 e5                	mov    %esp,%ebp
 a83:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a86:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a8d:	77 07                	ja     a96 <morecore+0x16>
    nu = 4096;
 a8f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a96:	8b 45 08             	mov    0x8(%ebp),%eax
 a99:	c1 e0 03             	shl    $0x3,%eax
 a9c:	83 ec 0c             	sub    $0xc,%esp
 a9f:	50                   	push   %eax
 aa0:	e8 31 fc ff ff       	call   6d6 <sbrk>
 aa5:	83 c4 10             	add    $0x10,%esp
 aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 aab:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 aaf:	75 07                	jne    ab8 <morecore+0x38>
    return 0;
 ab1:	b8 00 00 00 00       	mov    $0x0,%eax
 ab6:	eb 26                	jmp    ade <morecore+0x5e>
  hp = (Header*)p;
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac1:	8b 55 08             	mov    0x8(%ebp),%edx
 ac4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aca:	83 c0 08             	add    $0x8,%eax
 acd:	83 ec 0c             	sub    $0xc,%esp
 ad0:	50                   	push   %eax
 ad1:	e8 c8 fe ff ff       	call   99e <free>
 ad6:	83 c4 10             	add    $0x10,%esp
  return freep;
 ad9:	a1 e0 0e 00 00       	mov    0xee0,%eax
}
 ade:	c9                   	leave  
 adf:	c3                   	ret    

00000ae0 <malloc>:

void*
malloc(uint nbytes)
{
 ae0:	55                   	push   %ebp
 ae1:	89 e5                	mov    %esp,%ebp
 ae3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ae6:	8b 45 08             	mov    0x8(%ebp),%eax
 ae9:	83 c0 07             	add    $0x7,%eax
 aec:	c1 e8 03             	shr    $0x3,%eax
 aef:	83 c0 01             	add    $0x1,%eax
 af2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 af5:	a1 e0 0e 00 00       	mov    0xee0,%eax
 afa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 afd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b01:	75 23                	jne    b26 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b03:	c7 45 f0 d8 0e 00 00 	movl   $0xed8,-0x10(%ebp)
 b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b0d:	a3 e0 0e 00 00       	mov    %eax,0xee0
 b12:	a1 e0 0e 00 00       	mov    0xee0,%eax
 b17:	a3 d8 0e 00 00       	mov    %eax,0xed8
    base.s.size = 0;
 b1c:	c7 05 dc 0e 00 00 00 	movl   $0x0,0xedc
 b23:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b29:	8b 00                	mov    (%eax),%eax
 b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b31:	8b 40 04             	mov    0x4(%eax),%eax
 b34:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b37:	72 4d                	jb     b86 <malloc+0xa6>
      if(p->s.size == nunits)
 b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3c:	8b 40 04             	mov    0x4(%eax),%eax
 b3f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b42:	75 0c                	jne    b50 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b47:	8b 10                	mov    (%eax),%edx
 b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b4c:	89 10                	mov    %edx,(%eax)
 b4e:	eb 26                	jmp    b76 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b53:	8b 40 04             	mov    0x4(%eax),%eax
 b56:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b59:	89 c2                	mov    %eax,%edx
 b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b64:	8b 40 04             	mov    0x4(%eax),%eax
 b67:	c1 e0 03             	shl    $0x3,%eax
 b6a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b70:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b73:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b79:	a3 e0 0e 00 00       	mov    %eax,0xee0
      return (void*)(p + 1);
 b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b81:	83 c0 08             	add    $0x8,%eax
 b84:	eb 3b                	jmp    bc1 <malloc+0xe1>
    }
    if(p == freep)
 b86:	a1 e0 0e 00 00       	mov    0xee0,%eax
 b8b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b8e:	75 1e                	jne    bae <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b90:	83 ec 0c             	sub    $0xc,%esp
 b93:	ff 75 ec             	pushl  -0x14(%ebp)
 b96:	e8 e5 fe ff ff       	call   a80 <morecore>
 b9b:	83 c4 10             	add    $0x10,%esp
 b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ba1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ba5:	75 07                	jne    bae <malloc+0xce>
        return 0;
 ba7:	b8 00 00 00 00       	mov    $0x0,%eax
 bac:	eb 13                	jmp    bc1 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb7:	8b 00                	mov    (%eax),%eax
 bb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 bbc:	e9 6d ff ff ff       	jmp    b2e <malloc+0x4e>
}
 bc1:	c9                   	leave  
 bc2:	c3                   	ret    
