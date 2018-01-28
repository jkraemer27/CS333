
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
  11:	83 ec 28             	sub    $0x28,%esp
  int elapsed, milli, cpue, cpum;

  struct uproc *p = malloc(sizeof(struct uproc) * MAXPROC);
  14:	83 ec 0c             	sub    $0xc,%esp
  17:	68 00 17 00 00       	push   $0x1700
  1c:	e8 10 0a 00 00       	call   a31 <malloc>
  21:	83 c4 10             	add    $0x10,%esp
  24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int processes = getprocs(MAXPROC, p);
  27:	83 ec 08             	sub    $0x8,%esp
  2a:	ff 75 e0             	pushl  -0x20(%ebp)
  2d:	6a 40                	push   $0x40
  2f:	e8 4b 06 00 00       	call   67f <getprocs>
  34:	83 c4 10             	add    $0x10,%esp
  37:	89 45 dc             	mov    %eax,-0x24(%ebp)

  printf(1, "PID     Name    UID	GID	PPID    Elapsed CPU	State   Size\n");
  3a:	83 ec 08             	sub    $0x8,%esp
  3d:	68 14 0b 00 00       	push   $0xb14
  42:	6a 01                	push   $0x1
  44:	e8 15 07 00 00       	call   75e <printf>
  49:	83 c4 10             	add    $0x10,%esp


    for(int i = 0; i < processes; ++i)
  4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  53:	e9 02 02 00 00       	jmp    25a <main+0x25a>
    {
	if(p[i].elapsed_ticks > 0) 
  58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  5b:	6b d0 5c             	imul   $0x5c,%eax,%edx
  5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  61:	01 d0                	add    %edx,%eax
  63:	8b 40 10             	mov    0x10(%eax),%eax
  66:	85 c0                	test   %eax,%eax
  68:	0f 84 e8 01 00 00    	je     256 <main+0x256>
	{
	    elapsed = p[i].elapsed_ticks/1000;
  6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  71:	6b d0 5c             	imul   $0x5c,%eax,%edx
  74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  77:	01 d0                	add    %edx,%eax
  79:	8b 40 10             	mov    0x10(%eax),%eax
  7c:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  81:	f7 e2                	mul    %edx
  83:	89 d0                	mov    %edx,%eax
  85:	c1 e8 06             	shr    $0x6,%eax
  88:	89 45 d8             	mov    %eax,-0x28(%ebp)
	    milli = p[i].elapsed_ticks%1000;
  8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8e:	6b d0 5c             	imul   $0x5c,%eax,%edx
  91:	8b 45 e0             	mov    -0x20(%ebp),%eax
  94:	01 d0                	add    %edx,%eax
  96:	8b 48 10             	mov    0x10(%eax),%ecx
  99:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  9e:	89 c8                	mov    %ecx,%eax
  a0:	f7 e2                	mul    %edx
  a2:	89 d0                	mov    %edx,%eax
  a4:	c1 e8 06             	shr    $0x6,%eax
  a7:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  ad:	29 c1                	sub    %eax,%ecx
  af:	89 c8                	mov    %ecx,%eax
  b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    cpue = p[i].CPU_total_ticks/1000;
  b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b7:	6b d0 5c             	imul   $0x5c,%eax,%edx
  ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  bd:	01 d0                	add    %edx,%eax
  bf:	8b 40 14             	mov    0x14(%eax),%eax
  c2:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  c7:	f7 e2                	mul    %edx
  c9:	89 d0                	mov    %edx,%eax
  cb:	c1 e8 06             	shr    $0x6,%eax
  ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    cpum = p[i].CPU_total_ticks%1000;
  d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  d4:	6b d0 5c             	imul   $0x5c,%eax,%edx
  d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  da:	01 d0                	add    %edx,%eax
  dc:	8b 48 14             	mov    0x14(%eax),%ecx
  df:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  e4:	89 c8                	mov    %ecx,%eax
  e6:	f7 e2                	mul    %edx
  e8:	89 d0                	mov    %edx,%eax
  ea:	c1 e8 06             	shr    $0x6,%eax
  ed:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  f3:	29 c1                	sub    %eax,%ecx
  f5:	89 c8                	mov    %ecx,%eax
  f7:	89 45 cc             	mov    %eax,-0x34(%ebp)

	    printf(1, "%d\t%s\t%d\t%d\t%d\t%d.", p[i].pid, p[i].name, p[i].uid, p[i].gid, p[i].ppid, elapsed);
  fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  fd:	6b d0 5c             	imul   $0x5c,%eax,%edx
 100:	8b 45 e0             	mov    -0x20(%ebp),%eax
 103:	01 d0                	add    %edx,%eax
 105:	8b 58 0c             	mov    0xc(%eax),%ebx
 108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 10b:	6b d0 5c             	imul   $0x5c,%eax,%edx
 10e:	8b 45 e0             	mov    -0x20(%ebp),%eax
 111:	01 d0                	add    %edx,%eax
 113:	8b 48 08             	mov    0x8(%eax),%ecx
 116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 119:	6b d0 5c             	imul   $0x5c,%eax,%edx
 11c:	8b 45 e0             	mov    -0x20(%ebp),%eax
 11f:	01 d0                	add    %edx,%eax
 121:	8b 50 04             	mov    0x4(%eax),%edx
 124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 127:	6b f0 5c             	imul   $0x5c,%eax,%esi
 12a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 12d:	01 f0                	add    %esi,%eax
 12f:	8d 70 3c             	lea    0x3c(%eax),%esi
 132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 135:	6b f8 5c             	imul   $0x5c,%eax,%edi
 138:	8b 45 e0             	mov    -0x20(%ebp),%eax
 13b:	01 f8                	add    %edi,%eax
 13d:	8b 00                	mov    (%eax),%eax
 13f:	ff 75 d8             	pushl  -0x28(%ebp)
 142:	53                   	push   %ebx
 143:	51                   	push   %ecx
 144:	52                   	push   %edx
 145:	56                   	push   %esi
 146:	50                   	push   %eax
 147:	68 4e 0b 00 00       	push   $0xb4e
 14c:	6a 01                	push   $0x1
 14e:	e8 0b 06 00 00       	call   75e <printf>
 153:	83 c4 20             	add    $0x20,%esp

	    if(milli < 10)
 156:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
 15a:	7f 15                	jg     171 <main+0x171>
		printf(1, "00%d\t%d.", milli, cpue);
 15c:	ff 75 d0             	pushl  -0x30(%ebp)
 15f:	ff 75 d4             	pushl  -0x2c(%ebp)
 162:	68 61 0b 00 00       	push   $0xb61
 167:	6a 01                	push   $0x1
 169:	e8 f0 05 00 00       	call   75e <printf>
 16e:	83 c4 10             	add    $0x10,%esp
	    if(milli > 9 && milli < 100)
 171:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
 175:	7e 1d                	jle    194 <main+0x194>
 177:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
 17b:	7f 17                	jg     194 <main+0x194>
		printf(1, "0%d\t%d.", milli, cpue);
 17d:	ff 75 d0             	pushl  -0x30(%ebp)
 180:	ff 75 d4             	pushl  -0x2c(%ebp)
 183:	68 6a 0b 00 00       	push   $0xb6a
 188:	6a 01                	push   $0x1
 18a:	e8 cf 05 00 00       	call   75e <printf>
 18f:	83 c4 10             	add    $0x10,%esp
 192:	eb 15                	jmp    1a9 <main+0x1a9>
	    else
		printf(1, "%d\t%d.", milli, cpue);
 194:	ff 75 d0             	pushl  -0x30(%ebp)
 197:	ff 75 d4             	pushl  -0x2c(%ebp)
 19a:	68 72 0b 00 00       	push   $0xb72
 19f:	6a 01                	push   $0x1
 1a1:	e8 b8 05 00 00       	call   75e <printf>
 1a6:	83 c4 10             	add    $0x10,%esp

	    if(cpum < 10)    
 1a9:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
 1ad:	7f 33                	jg     1e2 <main+0x1e2>
		printf(1, "00%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
 1af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1b2:	6b d0 5c             	imul   $0x5c,%eax,%edx
 1b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1b8:	01 d0                	add    %edx,%eax
 1ba:	8b 40 38             	mov    0x38(%eax),%eax
 1bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1c0:	6b ca 5c             	imul   $0x5c,%edx,%ecx
 1c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
 1c6:	01 ca                	add    %ecx,%edx
 1c8:	83 c2 18             	add    $0x18,%edx
 1cb:	83 ec 0c             	sub    $0xc,%esp
 1ce:	50                   	push   %eax
 1cf:	52                   	push   %edx
 1d0:	ff 75 cc             	pushl  -0x34(%ebp)
 1d3:	68 79 0b 00 00       	push   $0xb79
 1d8:	6a 01                	push   $0x1
 1da:	e8 7f 05 00 00       	call   75e <printf>
 1df:	83 c4 20             	add    $0x20,%esp
	    if(cpum > 9 && cpum < 100)
 1e2:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
 1e6:	7e 3b                	jle    223 <main+0x223>
 1e8:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
 1ec:	7f 35                	jg     223 <main+0x223>
		printf(1, "0%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
 1ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1f1:	6b d0 5c             	imul   $0x5c,%eax,%edx
 1f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f7:	01 d0                	add    %edx,%eax
 1f9:	8b 40 38             	mov    0x38(%eax),%eax
 1fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1ff:	6b ca 5c             	imul   $0x5c,%edx,%ecx
 202:	8b 55 e0             	mov    -0x20(%ebp),%edx
 205:	01 ca                	add    %ecx,%edx
 207:	83 c2 18             	add    $0x18,%edx
 20a:	83 ec 0c             	sub    $0xc,%esp
 20d:	50                   	push   %eax
 20e:	52                   	push   %edx
 20f:	ff 75 cc             	pushl  -0x34(%ebp)
 212:	68 85 0b 00 00       	push   $0xb85
 217:	6a 01                	push   $0x1
 219:	e8 40 05 00 00       	call   75e <printf>
 21e:	83 c4 20             	add    $0x20,%esp
 221:	eb 33                	jmp    256 <main+0x256>
	    else
		printf(1, "%d\t%s\t%d\n", cpum, p[i].state, p[i].size);
 223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 226:	6b d0 5c             	imul   $0x5c,%eax,%edx
 229:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22c:	01 d0                	add    %edx,%eax
 22e:	8b 40 38             	mov    0x38(%eax),%eax
 231:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 234:	6b ca 5c             	imul   $0x5c,%edx,%ecx
 237:	8b 55 e0             	mov    -0x20(%ebp),%edx
 23a:	01 ca                	add    %ecx,%edx
 23c:	83 c2 18             	add    $0x18,%edx
 23f:	83 ec 0c             	sub    $0xc,%esp
 242:	50                   	push   %eax
 243:	52                   	push   %edx
 244:	ff 75 cc             	pushl  -0x34(%ebp)
 247:	68 90 0b 00 00       	push   $0xb90
 24c:	6a 01                	push   $0x1
 24e:	e8 0b 05 00 00       	call   75e <printf>
 253:	83 c4 20             	add    $0x20,%esp
  int processes = getprocs(MAXPROC, p);

  printf(1, "PID     Name    UID	GID	PPID    Elapsed CPU	State   Size\n");


    for(int i = 0; i < processes; ++i)
 256:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 25a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 25d:	3b 45 dc             	cmp    -0x24(%ebp),%eax
 260:	0f 8c f2 fd ff ff    	jl     58 <main+0x58>
		printf(1, "%d\t%s\t%d\n", cpum, p[i].state, p[i].size);

	    //printf(1, "%d\t%s\t%d\t%d\t%d\t%d.%d\t%d.%d\t%s\t%d\n", p[i].pid, p[i].name, p[i].uid, p[i].gid, p[i].ppid, elapsed, milli, cpue, cpum, p[i].state, p[i].size);
	}
    }
    printf(1, "\n");
 266:	83 ec 08             	sub    $0x8,%esp
 269:	68 9a 0b 00 00       	push   $0xb9a
 26e:	6a 01                	push   $0x1
 270:	e8 e9 04 00 00       	call   75e <printf>
 275:	83 c4 10             	add    $0x10,%esp

  exit();
 278:	e8 2a 03 00 00       	call   5a7 <exit>

0000027d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 27d:	55                   	push   %ebp
 27e:	89 e5                	mov    %esp,%ebp
 280:	57                   	push   %edi
 281:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 282:	8b 4d 08             	mov    0x8(%ebp),%ecx
 285:	8b 55 10             	mov    0x10(%ebp),%edx
 288:	8b 45 0c             	mov    0xc(%ebp),%eax
 28b:	89 cb                	mov    %ecx,%ebx
 28d:	89 df                	mov    %ebx,%edi
 28f:	89 d1                	mov    %edx,%ecx
 291:	fc                   	cld    
 292:	f3 aa                	rep stos %al,%es:(%edi)
 294:	89 ca                	mov    %ecx,%edx
 296:	89 fb                	mov    %edi,%ebx
 298:	89 5d 08             	mov    %ebx,0x8(%ebp)
 29b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 29e:	90                   	nop
 29f:	5b                   	pop    %ebx
 2a0:	5f                   	pop    %edi
 2a1:	5d                   	pop    %ebp
 2a2:	c3                   	ret    

000002a3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2af:	90                   	nop
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	8d 50 01             	lea    0x1(%eax),%edx
 2b6:	89 55 08             	mov    %edx,0x8(%ebp)
 2b9:	8b 55 0c             	mov    0xc(%ebp),%edx
 2bc:	8d 4a 01             	lea    0x1(%edx),%ecx
 2bf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2c2:	0f b6 12             	movzbl (%edx),%edx
 2c5:	88 10                	mov    %dl,(%eax)
 2c7:	0f b6 00             	movzbl (%eax),%eax
 2ca:	84 c0                	test   %al,%al
 2cc:	75 e2                	jne    2b0 <strcpy+0xd>
    ;
  return os;
 2ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2d6:	eb 08                	jmp    2e0 <strcmp+0xd>
    p++, q++;
 2d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2dc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	0f b6 00             	movzbl (%eax),%eax
 2e6:	84 c0                	test   %al,%al
 2e8:	74 10                	je     2fa <strcmp+0x27>
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	0f b6 10             	movzbl (%eax),%edx
 2f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f3:	0f b6 00             	movzbl (%eax),%eax
 2f6:	38 c2                	cmp    %al,%dl
 2f8:	74 de                	je     2d8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	0f b6 00             	movzbl (%eax),%eax
 300:	0f b6 d0             	movzbl %al,%edx
 303:	8b 45 0c             	mov    0xc(%ebp),%eax
 306:	0f b6 00             	movzbl (%eax),%eax
 309:	0f b6 c0             	movzbl %al,%eax
 30c:	29 c2                	sub    %eax,%edx
 30e:	89 d0                	mov    %edx,%eax
}
 310:	5d                   	pop    %ebp
 311:	c3                   	ret    

00000312 <strlen>:

uint
strlen(char *s)
{
 312:	55                   	push   %ebp
 313:	89 e5                	mov    %esp,%ebp
 315:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 318:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 31f:	eb 04                	jmp    325 <strlen+0x13>
 321:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 325:	8b 55 fc             	mov    -0x4(%ebp),%edx
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	01 d0                	add    %edx,%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	84 c0                	test   %al,%al
 332:	75 ed                	jne    321 <strlen+0xf>
    ;
  return n;
 334:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 337:	c9                   	leave  
 338:	c3                   	ret    

00000339 <memset>:

void*
memset(void *dst, int c, uint n)
{
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 33c:	8b 45 10             	mov    0x10(%ebp),%eax
 33f:	50                   	push   %eax
 340:	ff 75 0c             	pushl  0xc(%ebp)
 343:	ff 75 08             	pushl  0x8(%ebp)
 346:	e8 32 ff ff ff       	call   27d <stosb>
 34b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 351:	c9                   	leave  
 352:	c3                   	ret    

00000353 <strchr>:

char*
strchr(const char *s, char c)
{
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	83 ec 04             	sub    $0x4,%esp
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 35f:	eb 14                	jmp    375 <strchr+0x22>
    if(*s == c)
 361:	8b 45 08             	mov    0x8(%ebp),%eax
 364:	0f b6 00             	movzbl (%eax),%eax
 367:	3a 45 fc             	cmp    -0x4(%ebp),%al
 36a:	75 05                	jne    371 <strchr+0x1e>
      return (char*)s;
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	eb 13                	jmp    384 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 371:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	0f b6 00             	movzbl (%eax),%eax
 37b:	84 c0                	test   %al,%al
 37d:	75 e2                	jne    361 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 37f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 384:	c9                   	leave  
 385:	c3                   	ret    

00000386 <gets>:

char*
gets(char *buf, int max)
{
 386:	55                   	push   %ebp
 387:	89 e5                	mov    %esp,%ebp
 389:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 38c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 393:	eb 42                	jmp    3d7 <gets+0x51>
    cc = read(0, &c, 1);
 395:	83 ec 04             	sub    $0x4,%esp
 398:	6a 01                	push   $0x1
 39a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 39d:	50                   	push   %eax
 39e:	6a 00                	push   $0x0
 3a0:	e8 1a 02 00 00       	call   5bf <read>
 3a5:	83 c4 10             	add    $0x10,%esp
 3a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3af:	7e 33                	jle    3e4 <gets+0x5e>
      break;
    buf[i++] = c;
 3b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b4:	8d 50 01             	lea    0x1(%eax),%edx
 3b7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ba:	89 c2                	mov    %eax,%edx
 3bc:	8b 45 08             	mov    0x8(%ebp),%eax
 3bf:	01 c2                	add    %eax,%edx
 3c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3c7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3cb:	3c 0a                	cmp    $0xa,%al
 3cd:	74 16                	je     3e5 <gets+0x5f>
 3cf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d3:	3c 0d                	cmp    $0xd,%al
 3d5:	74 0e                	je     3e5 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3da:	83 c0 01             	add    $0x1,%eax
 3dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3e0:	7c b3                	jl     395 <gets+0xf>
 3e2:	eb 01                	jmp    3e5 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3e4:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
 3eb:	01 d0                	add    %edx,%eax
 3ed:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f3:	c9                   	leave  
 3f4:	c3                   	ret    

000003f5 <stat>:

int
stat(char *n, struct stat *st)
{
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fb:	83 ec 08             	sub    $0x8,%esp
 3fe:	6a 00                	push   $0x0
 400:	ff 75 08             	pushl  0x8(%ebp)
 403:	e8 df 01 00 00       	call   5e7 <open>
 408:	83 c4 10             	add    $0x10,%esp
 40b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 40e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 412:	79 07                	jns    41b <stat+0x26>
    return -1;
 414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 419:	eb 25                	jmp    440 <stat+0x4b>
  r = fstat(fd, st);
 41b:	83 ec 08             	sub    $0x8,%esp
 41e:	ff 75 0c             	pushl  0xc(%ebp)
 421:	ff 75 f4             	pushl  -0xc(%ebp)
 424:	e8 d6 01 00 00       	call   5ff <fstat>
 429:	83 c4 10             	add    $0x10,%esp
 42c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 42f:	83 ec 0c             	sub    $0xc,%esp
 432:	ff 75 f4             	pushl  -0xc(%ebp)
 435:	e8 95 01 00 00       	call   5cf <close>
 43a:	83 c4 10             	add    $0x10,%esp
  return r;
 43d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 440:	c9                   	leave  
 441:	c3                   	ret    

00000442 <atoi>:

int
atoi(const char *s)
{
 442:	55                   	push   %ebp
 443:	89 e5                	mov    %esp,%ebp
 445:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 448:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 44f:	eb 04                	jmp    455 <atoi+0x13>
 451:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	0f b6 00             	movzbl (%eax),%eax
 45b:	3c 20                	cmp    $0x20,%al
 45d:	74 f2                	je     451 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 45f:	8b 45 08             	mov    0x8(%ebp),%eax
 462:	0f b6 00             	movzbl (%eax),%eax
 465:	3c 2d                	cmp    $0x2d,%al
 467:	75 07                	jne    470 <atoi+0x2e>
 469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 46e:	eb 05                	jmp    475 <atoi+0x33>
 470:	b8 01 00 00 00       	mov    $0x1,%eax
 475:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	0f b6 00             	movzbl (%eax),%eax
 47e:	3c 2b                	cmp    $0x2b,%al
 480:	74 0a                	je     48c <atoi+0x4a>
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	0f b6 00             	movzbl (%eax),%eax
 488:	3c 2d                	cmp    $0x2d,%al
 48a:	75 2b                	jne    4b7 <atoi+0x75>
    s++;
 48c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 490:	eb 25                	jmp    4b7 <atoi+0x75>
    n = n*10 + *s++ - '0';
 492:	8b 55 fc             	mov    -0x4(%ebp),%edx
 495:	89 d0                	mov    %edx,%eax
 497:	c1 e0 02             	shl    $0x2,%eax
 49a:	01 d0                	add    %edx,%eax
 49c:	01 c0                	add    %eax,%eax
 49e:	89 c1                	mov    %eax,%ecx
 4a0:	8b 45 08             	mov    0x8(%ebp),%eax
 4a3:	8d 50 01             	lea    0x1(%eax),%edx
 4a6:	89 55 08             	mov    %edx,0x8(%ebp)
 4a9:	0f b6 00             	movzbl (%eax),%eax
 4ac:	0f be c0             	movsbl %al,%eax
 4af:	01 c8                	add    %ecx,%eax
 4b1:	83 e8 30             	sub    $0x30,%eax
 4b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 4b7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ba:	0f b6 00             	movzbl (%eax),%eax
 4bd:	3c 2f                	cmp    $0x2f,%al
 4bf:	7e 0a                	jle    4cb <atoi+0x89>
 4c1:	8b 45 08             	mov    0x8(%ebp),%eax
 4c4:	0f b6 00             	movzbl (%eax),%eax
 4c7:	3c 39                	cmp    $0x39,%al
 4c9:	7e c7                	jle    492 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 4cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4ce:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4d2:	c9                   	leave  
 4d3:	c3                   	ret    

000004d4 <atoo>:

int
atoo(const char *s)
{
 4d4:	55                   	push   %ebp
 4d5:	89 e5                	mov    %esp,%ebp
 4d7:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4e1:	eb 04                	jmp    4e7 <atoo+0x13>
 4e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	0f b6 00             	movzbl (%eax),%eax
 4ed:	3c 20                	cmp    $0x20,%al
 4ef:	74 f2                	je     4e3 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 4f1:	8b 45 08             	mov    0x8(%ebp),%eax
 4f4:	0f b6 00             	movzbl (%eax),%eax
 4f7:	3c 2d                	cmp    $0x2d,%al
 4f9:	75 07                	jne    502 <atoo+0x2e>
 4fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 500:	eb 05                	jmp    507 <atoo+0x33>
 502:	b8 01 00 00 00       	mov    $0x1,%eax
 507:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 50a:	8b 45 08             	mov    0x8(%ebp),%eax
 50d:	0f b6 00             	movzbl (%eax),%eax
 510:	3c 2b                	cmp    $0x2b,%al
 512:	74 0a                	je     51e <atoo+0x4a>
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	3c 2d                	cmp    $0x2d,%al
 51c:	75 27                	jne    545 <atoo+0x71>
    s++;
 51e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 522:	eb 21                	jmp    545 <atoo+0x71>
    n = n*8 + *s++ - '0';
 524:	8b 45 fc             	mov    -0x4(%ebp),%eax
 527:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 52e:	8b 45 08             	mov    0x8(%ebp),%eax
 531:	8d 50 01             	lea    0x1(%eax),%edx
 534:	89 55 08             	mov    %edx,0x8(%ebp)
 537:	0f b6 00             	movzbl (%eax),%eax
 53a:	0f be c0             	movsbl %al,%eax
 53d:	01 c8                	add    %ecx,%eax
 53f:	83 e8 30             	sub    $0x30,%eax
 542:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	0f b6 00             	movzbl (%eax),%eax
 54b:	3c 2f                	cmp    $0x2f,%al
 54d:	7e 0a                	jle    559 <atoo+0x85>
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	0f b6 00             	movzbl (%eax),%eax
 555:	3c 37                	cmp    $0x37,%al
 557:	7e cb                	jle    524 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 559:	8b 45 f8             	mov    -0x8(%ebp),%eax
 55c:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 560:	c9                   	leave  
 561:	c3                   	ret    

00000562 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 562:	55                   	push   %ebp
 563:	89 e5                	mov    %esp,%ebp
 565:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 56e:	8b 45 0c             	mov    0xc(%ebp),%eax
 571:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 574:	eb 17                	jmp    58d <memmove+0x2b>
    *dst++ = *src++;
 576:	8b 45 fc             	mov    -0x4(%ebp),%eax
 579:	8d 50 01             	lea    0x1(%eax),%edx
 57c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 57f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 582:	8d 4a 01             	lea    0x1(%edx),%ecx
 585:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 588:	0f b6 12             	movzbl (%edx),%edx
 58b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 58d:	8b 45 10             	mov    0x10(%ebp),%eax
 590:	8d 50 ff             	lea    -0x1(%eax),%edx
 593:	89 55 10             	mov    %edx,0x10(%ebp)
 596:	85 c0                	test   %eax,%eax
 598:	7f dc                	jg     576 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 59d:	c9                   	leave  
 59e:	c3                   	ret    

0000059f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 59f:	b8 01 00 00 00       	mov    $0x1,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <exit>:
SYSCALL(exit)
 5a7:	b8 02 00 00 00       	mov    $0x2,%eax
 5ac:	cd 40                	int    $0x40
 5ae:	c3                   	ret    

000005af <wait>:
SYSCALL(wait)
 5af:	b8 03 00 00 00       	mov    $0x3,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret    

000005b7 <pipe>:
SYSCALL(pipe)
 5b7:	b8 04 00 00 00       	mov    $0x4,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret    

000005bf <read>:
SYSCALL(read)
 5bf:	b8 05 00 00 00       	mov    $0x5,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret    

000005c7 <write>:
SYSCALL(write)
 5c7:	b8 10 00 00 00       	mov    $0x10,%eax
 5cc:	cd 40                	int    $0x40
 5ce:	c3                   	ret    

000005cf <close>:
SYSCALL(close)
 5cf:	b8 15 00 00 00       	mov    $0x15,%eax
 5d4:	cd 40                	int    $0x40
 5d6:	c3                   	ret    

000005d7 <kill>:
SYSCALL(kill)
 5d7:	b8 06 00 00 00       	mov    $0x6,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret    

000005df <exec>:
SYSCALL(exec)
 5df:	b8 07 00 00 00       	mov    $0x7,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret    

000005e7 <open>:
SYSCALL(open)
 5e7:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret    

000005ef <mknod>:
SYSCALL(mknod)
 5ef:	b8 11 00 00 00       	mov    $0x11,%eax
 5f4:	cd 40                	int    $0x40
 5f6:	c3                   	ret    

000005f7 <unlink>:
SYSCALL(unlink)
 5f7:	b8 12 00 00 00       	mov    $0x12,%eax
 5fc:	cd 40                	int    $0x40
 5fe:	c3                   	ret    

000005ff <fstat>:
SYSCALL(fstat)
 5ff:	b8 08 00 00 00       	mov    $0x8,%eax
 604:	cd 40                	int    $0x40
 606:	c3                   	ret    

00000607 <link>:
SYSCALL(link)
 607:	b8 13 00 00 00       	mov    $0x13,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret    

0000060f <mkdir>:
SYSCALL(mkdir)
 60f:	b8 14 00 00 00       	mov    $0x14,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret    

00000617 <chdir>:
SYSCALL(chdir)
 617:	b8 09 00 00 00       	mov    $0x9,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret    

0000061f <dup>:
SYSCALL(dup)
 61f:	b8 0a 00 00 00       	mov    $0xa,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret    

00000627 <getpid>:
SYSCALL(getpid)
 627:	b8 0b 00 00 00       	mov    $0xb,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret    

0000062f <sbrk>:
SYSCALL(sbrk)
 62f:	b8 0c 00 00 00       	mov    $0xc,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret    

00000637 <sleep>:
SYSCALL(sleep)
 637:	b8 0d 00 00 00       	mov    $0xd,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret    

0000063f <uptime>:
SYSCALL(uptime)
 63f:	b8 0e 00 00 00       	mov    $0xe,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret    

00000647 <halt>:
SYSCALL(halt)
 647:	b8 16 00 00 00       	mov    $0x16,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret    

0000064f <date>:
SYSCALL(date)
 64f:	b8 17 00 00 00       	mov    $0x17,%eax
 654:	cd 40                	int    $0x40
 656:	c3                   	ret    

00000657 <getuid>:
SYSCALL(getuid)
 657:	b8 18 00 00 00       	mov    $0x18,%eax
 65c:	cd 40                	int    $0x40
 65e:	c3                   	ret    

0000065f <getgid>:
SYSCALL(getgid)
 65f:	b8 19 00 00 00       	mov    $0x19,%eax
 664:	cd 40                	int    $0x40
 666:	c3                   	ret    

00000667 <getppid>:
SYSCALL(getppid)
 667:	b8 1a 00 00 00       	mov    $0x1a,%eax
 66c:	cd 40                	int    $0x40
 66e:	c3                   	ret    

0000066f <setuid>:
SYSCALL(setuid)
 66f:	b8 1b 00 00 00       	mov    $0x1b,%eax
 674:	cd 40                	int    $0x40
 676:	c3                   	ret    

00000677 <setgid>:
SYSCALL(setgid)
 677:	b8 1c 00 00 00       	mov    $0x1c,%eax
 67c:	cd 40                	int    $0x40
 67e:	c3                   	ret    

0000067f <getprocs>:
SYSCALL(getprocs)
 67f:	b8 1a 00 00 00       	mov    $0x1a,%eax
 684:	cd 40                	int    $0x40
 686:	c3                   	ret    

00000687 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 687:	55                   	push   %ebp
 688:	89 e5                	mov    %esp,%ebp
 68a:	83 ec 18             	sub    $0x18,%esp
 68d:	8b 45 0c             	mov    0xc(%ebp),%eax
 690:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 693:	83 ec 04             	sub    $0x4,%esp
 696:	6a 01                	push   $0x1
 698:	8d 45 f4             	lea    -0xc(%ebp),%eax
 69b:	50                   	push   %eax
 69c:	ff 75 08             	pushl  0x8(%ebp)
 69f:	e8 23 ff ff ff       	call   5c7 <write>
 6a4:	83 c4 10             	add    $0x10,%esp
}
 6a7:	90                   	nop
 6a8:	c9                   	leave  
 6a9:	c3                   	ret    

000006aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6aa:	55                   	push   %ebp
 6ab:	89 e5                	mov    %esp,%ebp
 6ad:	53                   	push   %ebx
 6ae:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6b8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6bc:	74 17                	je     6d5 <printint+0x2b>
 6be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6c2:	79 11                	jns    6d5 <printint+0x2b>
    neg = 1;
 6c4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ce:	f7 d8                	neg    %eax
 6d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6d3:	eb 06                	jmp    6db <printint+0x31>
  } else {
    x = xx;
 6d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6e2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6e5:	8d 41 01             	lea    0x1(%ecx),%eax
 6e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f1:	ba 00 00 00 00       	mov    $0x0,%edx
 6f6:	f7 f3                	div    %ebx
 6f8:	89 d0                	mov    %edx,%eax
 6fa:	0f b6 80 18 0e 00 00 	movzbl 0xe18(%eax),%eax
 701:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 705:	8b 5d 10             	mov    0x10(%ebp),%ebx
 708:	8b 45 ec             	mov    -0x14(%ebp),%eax
 70b:	ba 00 00 00 00       	mov    $0x0,%edx
 710:	f7 f3                	div    %ebx
 712:	89 45 ec             	mov    %eax,-0x14(%ebp)
 715:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 719:	75 c7                	jne    6e2 <printint+0x38>
  if(neg)
 71b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 71f:	74 2d                	je     74e <printint+0xa4>
    buf[i++] = '-';
 721:	8b 45 f4             	mov    -0xc(%ebp),%eax
 724:	8d 50 01             	lea    0x1(%eax),%edx
 727:	89 55 f4             	mov    %edx,-0xc(%ebp)
 72a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 72f:	eb 1d                	jmp    74e <printint+0xa4>
    putc(fd, buf[i]);
 731:	8d 55 dc             	lea    -0x24(%ebp),%edx
 734:	8b 45 f4             	mov    -0xc(%ebp),%eax
 737:	01 d0                	add    %edx,%eax
 739:	0f b6 00             	movzbl (%eax),%eax
 73c:	0f be c0             	movsbl %al,%eax
 73f:	83 ec 08             	sub    $0x8,%esp
 742:	50                   	push   %eax
 743:	ff 75 08             	pushl  0x8(%ebp)
 746:	e8 3c ff ff ff       	call   687 <putc>
 74b:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 74e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 752:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 756:	79 d9                	jns    731 <printint+0x87>
    putc(fd, buf[i]);
}
 758:	90                   	nop
 759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 75c:	c9                   	leave  
 75d:	c3                   	ret    

0000075e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 75e:	55                   	push   %ebp
 75f:	89 e5                	mov    %esp,%ebp
 761:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 764:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 76b:	8d 45 0c             	lea    0xc(%ebp),%eax
 76e:	83 c0 04             	add    $0x4,%eax
 771:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 774:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 77b:	e9 59 01 00 00       	jmp    8d9 <printf+0x17b>
    c = fmt[i] & 0xff;
 780:	8b 55 0c             	mov    0xc(%ebp),%edx
 783:	8b 45 f0             	mov    -0x10(%ebp),%eax
 786:	01 d0                	add    %edx,%eax
 788:	0f b6 00             	movzbl (%eax),%eax
 78b:	0f be c0             	movsbl %al,%eax
 78e:	25 ff 00 00 00       	and    $0xff,%eax
 793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 796:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 79a:	75 2c                	jne    7c8 <printf+0x6a>
      if(c == '%'){
 79c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7a0:	75 0c                	jne    7ae <printf+0x50>
        state = '%';
 7a2:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7a9:	e9 27 01 00 00       	jmp    8d5 <printf+0x177>
      } else {
        putc(fd, c);
 7ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b1:	0f be c0             	movsbl %al,%eax
 7b4:	83 ec 08             	sub    $0x8,%esp
 7b7:	50                   	push   %eax
 7b8:	ff 75 08             	pushl  0x8(%ebp)
 7bb:	e8 c7 fe ff ff       	call   687 <putc>
 7c0:	83 c4 10             	add    $0x10,%esp
 7c3:	e9 0d 01 00 00       	jmp    8d5 <printf+0x177>
      }
    } else if(state == '%'){
 7c8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7cc:	0f 85 03 01 00 00    	jne    8d5 <printf+0x177>
      if(c == 'd'){
 7d2:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7d6:	75 1e                	jne    7f6 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	6a 01                	push   $0x1
 7df:	6a 0a                	push   $0xa
 7e1:	50                   	push   %eax
 7e2:	ff 75 08             	pushl  0x8(%ebp)
 7e5:	e8 c0 fe ff ff       	call   6aa <printint>
 7ea:	83 c4 10             	add    $0x10,%esp
        ap++;
 7ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f1:	e9 d8 00 00 00       	jmp    8ce <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7f6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7fa:	74 06                	je     802 <printf+0xa4>
 7fc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 800:	75 1e                	jne    820 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 802:	8b 45 e8             	mov    -0x18(%ebp),%eax
 805:	8b 00                	mov    (%eax),%eax
 807:	6a 00                	push   $0x0
 809:	6a 10                	push   $0x10
 80b:	50                   	push   %eax
 80c:	ff 75 08             	pushl  0x8(%ebp)
 80f:	e8 96 fe ff ff       	call   6aa <printint>
 814:	83 c4 10             	add    $0x10,%esp
        ap++;
 817:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 81b:	e9 ae 00 00 00       	jmp    8ce <printf+0x170>
      } else if(c == 's'){
 820:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 824:	75 43                	jne    869 <printf+0x10b>
        s = (char*)*ap;
 826:	8b 45 e8             	mov    -0x18(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 82e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 832:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 836:	75 25                	jne    85d <printf+0xff>
          s = "(null)";
 838:	c7 45 f4 9c 0b 00 00 	movl   $0xb9c,-0xc(%ebp)
        while(*s != 0){
 83f:	eb 1c                	jmp    85d <printf+0xff>
          putc(fd, *s);
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	0f b6 00             	movzbl (%eax),%eax
 847:	0f be c0             	movsbl %al,%eax
 84a:	83 ec 08             	sub    $0x8,%esp
 84d:	50                   	push   %eax
 84e:	ff 75 08             	pushl  0x8(%ebp)
 851:	e8 31 fe ff ff       	call   687 <putc>
 856:	83 c4 10             	add    $0x10,%esp
          s++;
 859:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	0f b6 00             	movzbl (%eax),%eax
 863:	84 c0                	test   %al,%al
 865:	75 da                	jne    841 <printf+0xe3>
 867:	eb 65                	jmp    8ce <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 869:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 86d:	75 1d                	jne    88c <printf+0x12e>
        putc(fd, *ap);
 86f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 872:	8b 00                	mov    (%eax),%eax
 874:	0f be c0             	movsbl %al,%eax
 877:	83 ec 08             	sub    $0x8,%esp
 87a:	50                   	push   %eax
 87b:	ff 75 08             	pushl  0x8(%ebp)
 87e:	e8 04 fe ff ff       	call   687 <putc>
 883:	83 c4 10             	add    $0x10,%esp
        ap++;
 886:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88a:	eb 42                	jmp    8ce <printf+0x170>
      } else if(c == '%'){
 88c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 890:	75 17                	jne    8a9 <printf+0x14b>
        putc(fd, c);
 892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 895:	0f be c0             	movsbl %al,%eax
 898:	83 ec 08             	sub    $0x8,%esp
 89b:	50                   	push   %eax
 89c:	ff 75 08             	pushl  0x8(%ebp)
 89f:	e8 e3 fd ff ff       	call   687 <putc>
 8a4:	83 c4 10             	add    $0x10,%esp
 8a7:	eb 25                	jmp    8ce <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8a9:	83 ec 08             	sub    $0x8,%esp
 8ac:	6a 25                	push   $0x25
 8ae:	ff 75 08             	pushl  0x8(%ebp)
 8b1:	e8 d1 fd ff ff       	call   687 <putc>
 8b6:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8bc:	0f be c0             	movsbl %al,%eax
 8bf:	83 ec 08             	sub    $0x8,%esp
 8c2:	50                   	push   %eax
 8c3:	ff 75 08             	pushl  0x8(%ebp)
 8c6:	e8 bc fd ff ff       	call   687 <putc>
 8cb:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8ce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8d5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8d9:	8b 55 0c             	mov    0xc(%ebp),%edx
 8dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8df:	01 d0                	add    %edx,%eax
 8e1:	0f b6 00             	movzbl (%eax),%eax
 8e4:	84 c0                	test   %al,%al
 8e6:	0f 85 94 fe ff ff    	jne    780 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8ec:	90                   	nop
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    

000008ef <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ef:	55                   	push   %ebp
 8f0:	89 e5                	mov    %esp,%ebp
 8f2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f5:	8b 45 08             	mov    0x8(%ebp),%eax
 8f8:	83 e8 08             	sub    $0x8,%eax
 8fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fe:	a1 34 0e 00 00       	mov    0xe34,%eax
 903:	89 45 fc             	mov    %eax,-0x4(%ebp)
 906:	eb 24                	jmp    92c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 910:	77 12                	ja     924 <free+0x35>
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 918:	77 24                	ja     93e <free+0x4f>
 91a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91d:	8b 00                	mov    (%eax),%eax
 91f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 922:	77 1a                	ja     93e <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 00                	mov    (%eax),%eax
 929:	89 45 fc             	mov    %eax,-0x4(%ebp)
 92c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 932:	76 d4                	jbe    908 <free+0x19>
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 93c:	76 ca                	jbe    908 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 93e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 941:	8b 40 04             	mov    0x4(%eax),%eax
 944:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	01 c2                	add    %eax,%edx
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 00                	mov    (%eax),%eax
 955:	39 c2                	cmp    %eax,%edx
 957:	75 24                	jne    97d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 959:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95c:	8b 50 04             	mov    0x4(%eax),%edx
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	8b 00                	mov    (%eax),%eax
 964:	8b 40 04             	mov    0x4(%eax),%eax
 967:	01 c2                	add    %eax,%edx
 969:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 96f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 972:	8b 00                	mov    (%eax),%eax
 974:	8b 10                	mov    (%eax),%edx
 976:	8b 45 f8             	mov    -0x8(%ebp),%eax
 979:	89 10                	mov    %edx,(%eax)
 97b:	eb 0a                	jmp    987 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	8b 10                	mov    (%eax),%edx
 982:	8b 45 f8             	mov    -0x8(%ebp),%eax
 985:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 987:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98a:	8b 40 04             	mov    0x4(%eax),%eax
 98d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 994:	8b 45 fc             	mov    -0x4(%ebp),%eax
 997:	01 d0                	add    %edx,%eax
 999:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 99c:	75 20                	jne    9be <free+0xcf>
    p->s.size += bp->s.size;
 99e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a1:	8b 50 04             	mov    0x4(%eax),%edx
 9a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a7:	8b 40 04             	mov    0x4(%eax),%eax
 9aa:	01 c2                	add    %eax,%edx
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b5:	8b 10                	mov    (%eax),%edx
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	89 10                	mov    %edx,(%eax)
 9bc:	eb 08                	jmp    9c6 <free+0xd7>
  } else
    p->s.ptr = bp;
 9be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9c4:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c9:	a3 34 0e 00 00       	mov    %eax,0xe34
}
 9ce:	90                   	nop
 9cf:	c9                   	leave  
 9d0:	c3                   	ret    

000009d1 <morecore>:

static Header*
morecore(uint nu)
{
 9d1:	55                   	push   %ebp
 9d2:	89 e5                	mov    %esp,%ebp
 9d4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9d7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9de:	77 07                	ja     9e7 <morecore+0x16>
    nu = 4096;
 9e0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9e7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ea:	c1 e0 03             	shl    $0x3,%eax
 9ed:	83 ec 0c             	sub    $0xc,%esp
 9f0:	50                   	push   %eax
 9f1:	e8 39 fc ff ff       	call   62f <sbrk>
 9f6:	83 c4 10             	add    $0x10,%esp
 9f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9fc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a00:	75 07                	jne    a09 <morecore+0x38>
    return 0;
 a02:	b8 00 00 00 00       	mov    $0x0,%eax
 a07:	eb 26                	jmp    a2f <morecore+0x5e>
  hp = (Header*)p;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a12:	8b 55 08             	mov    0x8(%ebp),%edx
 a15:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1b:	83 c0 08             	add    $0x8,%eax
 a1e:	83 ec 0c             	sub    $0xc,%esp
 a21:	50                   	push   %eax
 a22:	e8 c8 fe ff ff       	call   8ef <free>
 a27:	83 c4 10             	add    $0x10,%esp
  return freep;
 a2a:	a1 34 0e 00 00       	mov    0xe34,%eax
}
 a2f:	c9                   	leave  
 a30:	c3                   	ret    

00000a31 <malloc>:

void*
malloc(uint nbytes)
{
 a31:	55                   	push   %ebp
 a32:	89 e5                	mov    %esp,%ebp
 a34:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a37:	8b 45 08             	mov    0x8(%ebp),%eax
 a3a:	83 c0 07             	add    $0x7,%eax
 a3d:	c1 e8 03             	shr    $0x3,%eax
 a40:	83 c0 01             	add    $0x1,%eax
 a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a46:	a1 34 0e 00 00       	mov    0xe34,%eax
 a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a52:	75 23                	jne    a77 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a54:	c7 45 f0 2c 0e 00 00 	movl   $0xe2c,-0x10(%ebp)
 a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5e:	a3 34 0e 00 00       	mov    %eax,0xe34
 a63:	a1 34 0e 00 00       	mov    0xe34,%eax
 a68:	a3 2c 0e 00 00       	mov    %eax,0xe2c
    base.s.size = 0;
 a6d:	c7 05 30 0e 00 00 00 	movl   $0x0,0xe30
 a74:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7a:	8b 00                	mov    (%eax),%eax
 a7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	8b 40 04             	mov    0x4(%eax),%eax
 a85:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a88:	72 4d                	jb     ad7 <malloc+0xa6>
      if(p->s.size == nunits)
 a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8d:	8b 40 04             	mov    0x4(%eax),%eax
 a90:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a93:	75 0c                	jne    aa1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a98:	8b 10                	mov    (%eax),%edx
 a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a9d:	89 10                	mov    %edx,(%eax)
 a9f:	eb 26                	jmp    ac7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa4:	8b 40 04             	mov    0x4(%eax),%eax
 aa7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aaa:	89 c2                	mov    %eax,%edx
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab5:	8b 40 04             	mov    0x4(%eax),%eax
 ab8:	c1 e0 03             	shl    $0x3,%eax
 abb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ac4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aca:	a3 34 0e 00 00       	mov    %eax,0xe34
      return (void*)(p + 1);
 acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad2:	83 c0 08             	add    $0x8,%eax
 ad5:	eb 3b                	jmp    b12 <malloc+0xe1>
    }
    if(p == freep)
 ad7:	a1 34 0e 00 00       	mov    0xe34,%eax
 adc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 adf:	75 1e                	jne    aff <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ae1:	83 ec 0c             	sub    $0xc,%esp
 ae4:	ff 75 ec             	pushl  -0x14(%ebp)
 ae7:	e8 e5 fe ff ff       	call   9d1 <morecore>
 aec:	83 c4 10             	add    $0x10,%esp
 aef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 af6:	75 07                	jne    aff <malloc+0xce>
        return 0;
 af8:	b8 00 00 00 00       	mov    $0x0,%eax
 afd:	eb 13                	jmp    b12 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b02:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b08:	8b 00                	mov    (%eax),%eax
 b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b0d:	e9 6d ff ff ff       	jmp    a7f <malloc+0x4e>
}
 b12:	c9                   	leave  
 b13:	c3                   	ret    
