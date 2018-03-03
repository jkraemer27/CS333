
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
  1c:	e8 d7 0a 00 00       	call   af8 <malloc>
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
  3d:	68 dc 0b 00 00       	push   $0xbdc
  42:	6a 01                	push   $0x1
  44:	e8 dc 07 00 00       	call   825 <printf>
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
 1b6:	68 0f 0c 00 00       	push   $0xc0f
 1bb:	6a 01                	push   $0x1
 1bd:	e8 63 06 00 00       	call   825 <printf>
 1c2:	83 c4 30             	add    $0x30,%esp

	    if(milli < 10)
 1c5:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
 1c9:	7f 15                	jg     1e0 <main+0x1e0>
		printf(1, "00%d\t%d.", milli, cpue);
 1cb:	ff 75 d0             	pushl  -0x30(%ebp)
 1ce:	ff 75 d4             	pushl  -0x2c(%ebp)
 1d1:	68 24 0c 00 00       	push   $0xc24
 1d6:	6a 01                	push   $0x1
 1d8:	e8 48 06 00 00       	call   825 <printf>
 1dd:	83 c4 10             	add    $0x10,%esp
	    if(milli > 9 && milli < 100)
 1e0:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
 1e4:	7e 1b                	jle    201 <main+0x201>
 1e6:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
 1ea:	7f 15                	jg     201 <main+0x201>
		printf(1, "0%d\t%d.", milli, cpue);
 1ec:	ff 75 d0             	pushl  -0x30(%ebp)
 1ef:	ff 75 d4             	pushl  -0x2c(%ebp)
 1f2:	68 2d 0c 00 00       	push   $0xc2d
 1f7:	6a 01                	push   $0x1
 1f9:	e8 27 06 00 00       	call   825 <printf>
 1fe:	83 c4 10             	add    $0x10,%esp
	    if(milli > 100)
 201:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
 205:	7e 15                	jle    21c <main+0x21c>
		printf(1, "%d\t%d.", milli, cpue);
 207:	ff 75 d0             	pushl  -0x30(%ebp)
 20a:	ff 75 d4             	pushl  -0x2c(%ebp)
 20d:	68 35 0c 00 00       	push   $0xc35
 212:	6a 01                	push   $0x1
 214:	e8 0c 06 00 00       	call   825 <printf>
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
 256:	68 3c 0c 00 00       	push   $0xc3c
 25b:	6a 01                	push   $0x1
 25d:	e8 c3 05 00 00       	call   825 <printf>
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
 2a5:	68 48 0c 00 00       	push   $0xc48
 2aa:	6a 01                	push   $0x1
 2ac:	e8 74 05 00 00       	call   825 <printf>
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
 2ee:	68 53 0c 00 00       	push   $0xc53
 2f3:	6a 01                	push   $0x1
 2f5:	e8 2b 05 00 00       	call   825 <printf>
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
 310:	68 5d 0c 00 00       	push   $0xc5d
 315:	6a 01                	push   $0x1
 317:	e8 09 05 00 00       	call   825 <printf>
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

00000736 <chmod>:
SYSCALL(chmod)
 736:	b8 1c 00 00 00       	mov    $0x1c,%eax
 73b:	cd 40                	int    $0x40
 73d:	c3                   	ret    

0000073e <chown>:
SYSCALL(chown)
 73e:	b8 1d 00 00 00       	mov    $0x1d,%eax
 743:	cd 40                	int    $0x40
 745:	c3                   	ret    

00000746 <chgrp>:
SYSCALL(chgrp)
 746:	b8 1e 00 00 00       	mov    $0x1e,%eax
 74b:	cd 40                	int    $0x40
 74d:	c3                   	ret    

0000074e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 74e:	55                   	push   %ebp
 74f:	89 e5                	mov    %esp,%ebp
 751:	83 ec 18             	sub    $0x18,%esp
 754:	8b 45 0c             	mov    0xc(%ebp),%eax
 757:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 75a:	83 ec 04             	sub    $0x4,%esp
 75d:	6a 01                	push   $0x1
 75f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 762:	50                   	push   %eax
 763:	ff 75 08             	pushl  0x8(%ebp)
 766:	e8 03 ff ff ff       	call   66e <write>
 76b:	83 c4 10             	add    $0x10,%esp
}
 76e:	90                   	nop
 76f:	c9                   	leave  
 770:	c3                   	ret    

00000771 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 771:	55                   	push   %ebp
 772:	89 e5                	mov    %esp,%ebp
 774:	53                   	push   %ebx
 775:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 778:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 77f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 783:	74 17                	je     79c <printint+0x2b>
 785:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 789:	79 11                	jns    79c <printint+0x2b>
    neg = 1;
 78b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 792:	8b 45 0c             	mov    0xc(%ebp),%eax
 795:	f7 d8                	neg    %eax
 797:	89 45 ec             	mov    %eax,-0x14(%ebp)
 79a:	eb 06                	jmp    7a2 <printint+0x31>
  } else {
    x = xx;
 79c:	8b 45 0c             	mov    0xc(%ebp),%eax
 79f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7a9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 7ac:	8d 41 01             	lea    0x1(%ecx),%eax
 7af:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7b8:	ba 00 00 00 00       	mov    $0x0,%edx
 7bd:	f7 f3                	div    %ebx
 7bf:	89 d0                	mov    %edx,%eax
 7c1:	0f b6 80 dc 0e 00 00 	movzbl 0xedc(%eax),%eax
 7c8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 7cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7d2:	ba 00 00 00 00       	mov    $0x0,%edx
 7d7:	f7 f3                	div    %ebx
 7d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7e0:	75 c7                	jne    7a9 <printint+0x38>
  if(neg)
 7e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7e6:	74 2d                	je     815 <printint+0xa4>
    buf[i++] = '-';
 7e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7eb:	8d 50 01             	lea    0x1(%eax),%edx
 7ee:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7f1:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7f6:	eb 1d                	jmp    815 <printint+0xa4>
    putc(fd, buf[i]);
 7f8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	01 d0                	add    %edx,%eax
 800:	0f b6 00             	movzbl (%eax),%eax
 803:	0f be c0             	movsbl %al,%eax
 806:	83 ec 08             	sub    $0x8,%esp
 809:	50                   	push   %eax
 80a:	ff 75 08             	pushl  0x8(%ebp)
 80d:	e8 3c ff ff ff       	call   74e <putc>
 812:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 815:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 819:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 81d:	79 d9                	jns    7f8 <printint+0x87>
    putc(fd, buf[i]);
}
 81f:	90                   	nop
 820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 823:	c9                   	leave  
 824:	c3                   	ret    

00000825 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 825:	55                   	push   %ebp
 826:	89 e5                	mov    %esp,%ebp
 828:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 82b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 832:	8d 45 0c             	lea    0xc(%ebp),%eax
 835:	83 c0 04             	add    $0x4,%eax
 838:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 83b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 842:	e9 59 01 00 00       	jmp    9a0 <printf+0x17b>
    c = fmt[i] & 0xff;
 847:	8b 55 0c             	mov    0xc(%ebp),%edx
 84a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84d:	01 d0                	add    %edx,%eax
 84f:	0f b6 00             	movzbl (%eax),%eax
 852:	0f be c0             	movsbl %al,%eax
 855:	25 ff 00 00 00       	and    $0xff,%eax
 85a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 85d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 861:	75 2c                	jne    88f <printf+0x6a>
      if(c == '%'){
 863:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 867:	75 0c                	jne    875 <printf+0x50>
        state = '%';
 869:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 870:	e9 27 01 00 00       	jmp    99c <printf+0x177>
      } else {
        putc(fd, c);
 875:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 878:	0f be c0             	movsbl %al,%eax
 87b:	83 ec 08             	sub    $0x8,%esp
 87e:	50                   	push   %eax
 87f:	ff 75 08             	pushl  0x8(%ebp)
 882:	e8 c7 fe ff ff       	call   74e <putc>
 887:	83 c4 10             	add    $0x10,%esp
 88a:	e9 0d 01 00 00       	jmp    99c <printf+0x177>
      }
    } else if(state == '%'){
 88f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 893:	0f 85 03 01 00 00    	jne    99c <printf+0x177>
      if(c == 'd'){
 899:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 89d:	75 1e                	jne    8bd <printf+0x98>
        printint(fd, *ap, 10, 1);
 89f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a2:	8b 00                	mov    (%eax),%eax
 8a4:	6a 01                	push   $0x1
 8a6:	6a 0a                	push   $0xa
 8a8:	50                   	push   %eax
 8a9:	ff 75 08             	pushl  0x8(%ebp)
 8ac:	e8 c0 fe ff ff       	call   771 <printint>
 8b1:	83 c4 10             	add    $0x10,%esp
        ap++;
 8b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8b8:	e9 d8 00 00 00       	jmp    995 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 8bd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8c1:	74 06                	je     8c9 <printf+0xa4>
 8c3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8c7:	75 1e                	jne    8e7 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	6a 00                	push   $0x0
 8d0:	6a 10                	push   $0x10
 8d2:	50                   	push   %eax
 8d3:	ff 75 08             	pushl  0x8(%ebp)
 8d6:	e8 96 fe ff ff       	call   771 <printint>
 8db:	83 c4 10             	add    $0x10,%esp
        ap++;
 8de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8e2:	e9 ae 00 00 00       	jmp    995 <printf+0x170>
      } else if(c == 's'){
 8e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8eb:	75 43                	jne    930 <printf+0x10b>
        s = (char*)*ap;
 8ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8f0:	8b 00                	mov    (%eax),%eax
 8f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8fd:	75 25                	jne    924 <printf+0xff>
          s = "(null)";
 8ff:	c7 45 f4 5f 0c 00 00 	movl   $0xc5f,-0xc(%ebp)
        while(*s != 0){
 906:	eb 1c                	jmp    924 <printf+0xff>
          putc(fd, *s);
 908:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90b:	0f b6 00             	movzbl (%eax),%eax
 90e:	0f be c0             	movsbl %al,%eax
 911:	83 ec 08             	sub    $0x8,%esp
 914:	50                   	push   %eax
 915:	ff 75 08             	pushl  0x8(%ebp)
 918:	e8 31 fe ff ff       	call   74e <putc>
 91d:	83 c4 10             	add    $0x10,%esp
          s++;
 920:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	0f b6 00             	movzbl (%eax),%eax
 92a:	84 c0                	test   %al,%al
 92c:	75 da                	jne    908 <printf+0xe3>
 92e:	eb 65                	jmp    995 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 930:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 934:	75 1d                	jne    953 <printf+0x12e>
        putc(fd, *ap);
 936:	8b 45 e8             	mov    -0x18(%ebp),%eax
 939:	8b 00                	mov    (%eax),%eax
 93b:	0f be c0             	movsbl %al,%eax
 93e:	83 ec 08             	sub    $0x8,%esp
 941:	50                   	push   %eax
 942:	ff 75 08             	pushl  0x8(%ebp)
 945:	e8 04 fe ff ff       	call   74e <putc>
 94a:	83 c4 10             	add    $0x10,%esp
        ap++;
 94d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 951:	eb 42                	jmp    995 <printf+0x170>
      } else if(c == '%'){
 953:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 957:	75 17                	jne    970 <printf+0x14b>
        putc(fd, c);
 959:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 95c:	0f be c0             	movsbl %al,%eax
 95f:	83 ec 08             	sub    $0x8,%esp
 962:	50                   	push   %eax
 963:	ff 75 08             	pushl  0x8(%ebp)
 966:	e8 e3 fd ff ff       	call   74e <putc>
 96b:	83 c4 10             	add    $0x10,%esp
 96e:	eb 25                	jmp    995 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 970:	83 ec 08             	sub    $0x8,%esp
 973:	6a 25                	push   $0x25
 975:	ff 75 08             	pushl  0x8(%ebp)
 978:	e8 d1 fd ff ff       	call   74e <putc>
 97d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 980:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 983:	0f be c0             	movsbl %al,%eax
 986:	83 ec 08             	sub    $0x8,%esp
 989:	50                   	push   %eax
 98a:	ff 75 08             	pushl  0x8(%ebp)
 98d:	e8 bc fd ff ff       	call   74e <putc>
 992:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 995:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 99c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9a0:	8b 55 0c             	mov    0xc(%ebp),%edx
 9a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a6:	01 d0                	add    %edx,%eax
 9a8:	0f b6 00             	movzbl (%eax),%eax
 9ab:	84 c0                	test   %al,%al
 9ad:	0f 85 94 fe ff ff    	jne    847 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 9b3:	90                   	nop
 9b4:	c9                   	leave  
 9b5:	c3                   	ret    

000009b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9b6:	55                   	push   %ebp
 9b7:	89 e5                	mov    %esp,%ebp
 9b9:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9bc:	8b 45 08             	mov    0x8(%ebp),%eax
 9bf:	83 e8 08             	sub    $0x8,%eax
 9c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c5:	a1 f8 0e 00 00       	mov    0xef8,%eax
 9ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9cd:	eb 24                	jmp    9f3 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d2:	8b 00                	mov    (%eax),%eax
 9d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9d7:	77 12                	ja     9eb <free+0x35>
 9d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9df:	77 24                	ja     a05 <free+0x4f>
 9e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e4:	8b 00                	mov    (%eax),%eax
 9e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9e9:	77 1a                	ja     a05 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ee:	8b 00                	mov    (%eax),%eax
 9f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9f9:	76 d4                	jbe    9cf <free+0x19>
 9fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fe:	8b 00                	mov    (%eax),%eax
 a00:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a03:	76 ca                	jbe    9cf <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a05:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a08:	8b 40 04             	mov    0x4(%eax),%eax
 a0b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a12:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a15:	01 c2                	add    %eax,%edx
 a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1a:	8b 00                	mov    (%eax),%eax
 a1c:	39 c2                	cmp    %eax,%edx
 a1e:	75 24                	jne    a44 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a20:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a23:	8b 50 04             	mov    0x4(%eax),%edx
 a26:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a29:	8b 00                	mov    (%eax),%eax
 a2b:	8b 40 04             	mov    0x4(%eax),%eax
 a2e:	01 c2                	add    %eax,%edx
 a30:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a33:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a36:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a39:	8b 00                	mov    (%eax),%eax
 a3b:	8b 10                	mov    (%eax),%edx
 a3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a40:	89 10                	mov    %edx,(%eax)
 a42:	eb 0a                	jmp    a4e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a44:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a47:	8b 10                	mov    (%eax),%edx
 a49:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a4c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a51:	8b 40 04             	mov    0x4(%eax),%eax
 a54:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5e:	01 d0                	add    %edx,%eax
 a60:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a63:	75 20                	jne    a85 <free+0xcf>
    p->s.size += bp->s.size;
 a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a68:	8b 50 04             	mov    0x4(%eax),%edx
 a6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a6e:	8b 40 04             	mov    0x4(%eax),%eax
 a71:	01 c2                	add    %eax,%edx
 a73:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a76:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a79:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a7c:	8b 10                	mov    (%eax),%edx
 a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a81:	89 10                	mov    %edx,(%eax)
 a83:	eb 08                	jmp    a8d <free+0xd7>
  } else
    p->s.ptr = bp;
 a85:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a88:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a8b:	89 10                	mov    %edx,(%eax)
  freep = p;
 a8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a90:	a3 f8 0e 00 00       	mov    %eax,0xef8
}
 a95:	90                   	nop
 a96:	c9                   	leave  
 a97:	c3                   	ret    

00000a98 <morecore>:

static Header*
morecore(uint nu)
{
 a98:	55                   	push   %ebp
 a99:	89 e5                	mov    %esp,%ebp
 a9b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a9e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 aa5:	77 07                	ja     aae <morecore+0x16>
    nu = 4096;
 aa7:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 aae:	8b 45 08             	mov    0x8(%ebp),%eax
 ab1:	c1 e0 03             	shl    $0x3,%eax
 ab4:	83 ec 0c             	sub    $0xc,%esp
 ab7:	50                   	push   %eax
 ab8:	e8 19 fc ff ff       	call   6d6 <sbrk>
 abd:	83 c4 10             	add    $0x10,%esp
 ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ac3:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ac7:	75 07                	jne    ad0 <morecore+0x38>
    return 0;
 ac9:	b8 00 00 00 00       	mov    $0x0,%eax
 ace:	eb 26                	jmp    af6 <morecore+0x5e>
  hp = (Header*)p;
 ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad9:	8b 55 08             	mov    0x8(%ebp),%edx
 adc:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae2:	83 c0 08             	add    $0x8,%eax
 ae5:	83 ec 0c             	sub    $0xc,%esp
 ae8:	50                   	push   %eax
 ae9:	e8 c8 fe ff ff       	call   9b6 <free>
 aee:	83 c4 10             	add    $0x10,%esp
  return freep;
 af1:	a1 f8 0e 00 00       	mov    0xef8,%eax
}
 af6:	c9                   	leave  
 af7:	c3                   	ret    

00000af8 <malloc>:

void*
malloc(uint nbytes)
{
 af8:	55                   	push   %ebp
 af9:	89 e5                	mov    %esp,%ebp
 afb:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 afe:	8b 45 08             	mov    0x8(%ebp),%eax
 b01:	83 c0 07             	add    $0x7,%eax
 b04:	c1 e8 03             	shr    $0x3,%eax
 b07:	83 c0 01             	add    $0x1,%eax
 b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b0d:	a1 f8 0e 00 00       	mov    0xef8,%eax
 b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b19:	75 23                	jne    b3e <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b1b:	c7 45 f0 f0 0e 00 00 	movl   $0xef0,-0x10(%ebp)
 b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b25:	a3 f8 0e 00 00       	mov    %eax,0xef8
 b2a:	a1 f8 0e 00 00       	mov    0xef8,%eax
 b2f:	a3 f0 0e 00 00       	mov    %eax,0xef0
    base.s.size = 0;
 b34:	c7 05 f4 0e 00 00 00 	movl   $0x0,0xef4
 b3b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b41:	8b 00                	mov    (%eax),%eax
 b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b49:	8b 40 04             	mov    0x4(%eax),%eax
 b4c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b4f:	72 4d                	jb     b9e <malloc+0xa6>
      if(p->s.size == nunits)
 b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b54:	8b 40 04             	mov    0x4(%eax),%eax
 b57:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b5a:	75 0c                	jne    b68 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5f:	8b 10                	mov    (%eax),%edx
 b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b64:	89 10                	mov    %edx,(%eax)
 b66:	eb 26                	jmp    b8e <malloc+0x96>
      else {
        p->s.size -= nunits;
 b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6b:	8b 40 04             	mov    0x4(%eax),%eax
 b6e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b71:	89 c2                	mov    %eax,%edx
 b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b76:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b7c:	8b 40 04             	mov    0x4(%eax),%eax
 b7f:	c1 e0 03             	shl    $0x3,%eax
 b82:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b88:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b8b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b91:	a3 f8 0e 00 00       	mov    %eax,0xef8
      return (void*)(p + 1);
 b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b99:	83 c0 08             	add    $0x8,%eax
 b9c:	eb 3b                	jmp    bd9 <malloc+0xe1>
    }
    if(p == freep)
 b9e:	a1 f8 0e 00 00       	mov    0xef8,%eax
 ba3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ba6:	75 1e                	jne    bc6 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ba8:	83 ec 0c             	sub    $0xc,%esp
 bab:	ff 75 ec             	pushl  -0x14(%ebp)
 bae:	e8 e5 fe ff ff       	call   a98 <morecore>
 bb3:	83 c4 10             	add    $0x10,%esp
 bb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bbd:	75 07                	jne    bc6 <malloc+0xce>
        return 0;
 bbf:	b8 00 00 00 00       	mov    $0x0,%eax
 bc4:	eb 13                	jmp    bd9 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bcf:	8b 00                	mov    (%eax),%eax
 bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 bd4:	e9 6d ff ff ff       	jmp    b46 <malloc+0x4e>
}
 bd9:	c9                   	leave  
 bda:	c3                   	ret    
