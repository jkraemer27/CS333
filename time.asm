
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "uproc.h"
#include "param.h"

int
main(int argc, char ** argv)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 30             	sub    $0x30,%esp
  12:	89 cb                	mov    %ecx,%ebx
  char process[MAXPROC];

  strcpy(process, argv[1]);
  14:	8b 43 04             	mov    0x4(%ebx),%eax
  17:	83 c0 04             	add    $0x4,%eax
  1a:	8b 00                	mov    (%eax),%eax
  1c:	83 ec 08             	sub    $0x8,%esp
  1f:	50                   	push   %eax
  20:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  23:	50                   	push   %eax
  24:	e8 b9 01 00 00       	call   1e2 <strcpy>
  29:	83 c4 10             	add    $0x10,%esp

  if(!argv[1]){
  2c:	8b 43 04             	mov    0x4(%ebx),%eax
  2f:	83 c0 04             	add    $0x4,%eax
  32:	8b 00                	mov    (%eax),%eax
  34:	85 c0                	test   %eax,%eax
  36:	75 26                	jne    5e <main+0x5e>
      printf(1, "\nNo argument provided!\n\nUse \"time [program]\"\n\n");
  38:	83 ec 08             	sub    $0x8,%esp
  3b:	68 74 0a 00 00       	push   $0xa74
  40:	6a 01                	push   $0x1
  42:	e8 76 06 00 00       	call   6bd <printf>
  47:	83 c4 10             	add    $0x10,%esp
      strcpy(process, "time");
  4a:	83 ec 08             	sub    $0x8,%esp
  4d:	68 a3 0a 00 00       	push   $0xaa3
  52:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  55:	50                   	push   %eax
  56:	e8 87 01 00 00       	call   1e2 <strcpy>
  5b:	83 c4 10             	add    $0x10,%esp
  }

  
  int begin = uptime();
  5e:	e8 1b 05 00 00       	call   57e <uptime>
  63:	89 45 f4             	mov    %eax,-0xc(%ebp)

  int pid = fork();
  66:	e8 73 04 00 00       	call   4de <fork>
  6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid > 0){
  6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  72:	7e 0a                	jle    7e <main+0x7e>
      //printf(1, "parent: child=%d\n", pid);
      pid = wait();
  74:	e8 75 04 00 00       	call   4ee <wait>
  79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  7c:	eb 52                	jmp    d0 <main+0xd0>

      //printf(1, "child %d is done\n", pid);
  }
  else if(pid == 0){
  7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  82:	75 3a                	jne    be <main+0xbe>
	  if(exec(argv[1], argv + 1) < 0){
  84:	8b 43 04             	mov    0x4(%ebx),%eax
  87:	8d 50 04             	lea    0x4(%eax),%edx
  8a:	8b 43 04             	mov    0x4(%ebx),%eax
  8d:	83 c0 04             	add    $0x4,%eax
  90:	8b 00                	mov    (%eax),%eax
  92:	83 ec 08             	sub    $0x8,%esp
  95:	52                   	push   %edx
  96:	50                   	push   %eax
  97:	e8 82 04 00 00       	call   51e <exec>
  9c:	83 c4 10             	add    $0x10,%esp
  9f:	85 c0                	test   %eax,%eax
  a1:	79 2d                	jns    d0 <main+0xd0>
	      printf(1,"%s is not a valid program\n", process);
  a3:	83 ec 04             	sub    $0x4,%esp
  a6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  a9:	50                   	push   %eax
  aa:	68 a8 0a 00 00       	push   $0xaa8
  af:	6a 01                	push   $0x1
  b1:	e8 07 06 00 00       	call   6bd <printf>
  b6:	83 c4 10             	add    $0x10,%esp
	      exit();
  b9:	e8 28 04 00 00       	call   4e6 <exit>
	  }
      }

      else
	  printf(1,"fork error\n");
  be:	83 ec 08             	sub    $0x8,%esp
  c1:	68 c3 0a 00 00       	push   $0xac3
  c6:	6a 01                	push   $0x1
  c8:	e8 f0 05 00 00       	call   6bd <printf>
  cd:	83 c4 10             	add    $0x10,%esp

      int end = uptime();
  d0:	e8 a9 04 00 00       	call   57e <uptime>
  d5:	89 45 ec             	mov    %eax,-0x14(%ebp)

      int total = (end - begin)/1000;
  d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  db:	2b 45 f4             	sub    -0xc(%ebp),%eax
  de:	89 c1                	mov    %eax,%ecx
  e0:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  e5:	89 c8                	mov    %ecx,%eax
  e7:	f7 ea                	imul   %edx
  e9:	c1 fa 06             	sar    $0x6,%edx
  ec:	89 c8                	mov    %ecx,%eax
  ee:	c1 f8 1f             	sar    $0x1f,%eax
  f1:	29 c2                	sub    %eax,%edx
  f3:	89 d0                	mov    %edx,%eax
  f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int milli = (end - begin)%1000;
  f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  fb:	2b 45 f4             	sub    -0xc(%ebp),%eax
  fe:	89 c1                	mov    %eax,%ecx
 100:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 105:	89 c8                	mov    %ecx,%eax
 107:	f7 ea                	imul   %edx
 109:	c1 fa 06             	sar    $0x6,%edx
 10c:	89 c8                	mov    %ecx,%eax
 10e:	c1 f8 1f             	sar    $0x1f,%eax
 111:	29 c2                	sub    %eax,%edx
 113:	89 d0                	mov    %edx,%eax
 115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 11b:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 121:	29 c1                	sub    %eax,%ecx
 123:	89 c8                	mov    %ecx,%eax
 125:	89 45 e4             	mov    %eax,-0x1c(%ebp)


      printf(1, "%s%s\n",process, " executing...");
 128:	68 cf 0a 00 00       	push   $0xacf
 12d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 130:	50                   	push   %eax
 131:	68 dd 0a 00 00       	push   $0xadd
 136:	6a 01                	push   $0x1
 138:	e8 80 05 00 00       	call   6bd <printf>
 13d:	83 c4 10             	add    $0x10,%esp
      
      if(milli < 10)
 140:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
 144:	7f 21                	jg     167 <main+0x167>
      printf(1, "%s ran in %d.00%d seconds\n\n",process, total, milli, " seconds");
 146:	83 ec 08             	sub    $0x8,%esp
 149:	68 e3 0a 00 00       	push   $0xae3
 14e:	ff 75 e4             	pushl  -0x1c(%ebp)
 151:	ff 75 e8             	pushl  -0x18(%ebp)
 154:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 157:	50                   	push   %eax
 158:	68 ec 0a 00 00       	push   $0xaec
 15d:	6a 01                	push   $0x1
 15f:	e8 59 05 00 00       	call   6bd <printf>
 164:	83 c4 20             	add    $0x20,%esp
      
      if(milli > 9 && milli < 100)
 167:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
 16b:	7e 29                	jle    196 <main+0x196>
 16d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 171:	7f 23                	jg     196 <main+0x196>
      printf(1, "%s ran in %d.0%d seconds\n\n",process, total, milli, " seconds");
 173:	83 ec 08             	sub    $0x8,%esp
 176:	68 e3 0a 00 00       	push   $0xae3
 17b:	ff 75 e4             	pushl  -0x1c(%ebp)
 17e:	ff 75 e8             	pushl  -0x18(%ebp)
 181:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 184:	50                   	push   %eax
 185:	68 08 0b 00 00       	push   $0xb08
 18a:	6a 01                	push   $0x1
 18c:	e8 2c 05 00 00       	call   6bd <printf>
 191:	83 c4 20             	add    $0x20,%esp
 194:	eb 21                	jmp    1b7 <main+0x1b7>
      
      else
      printf(1, "%s ran in %d.%d seconds\n\n",process, total, milli, " seconds");
 196:	83 ec 08             	sub    $0x8,%esp
 199:	68 e3 0a 00 00       	push   $0xae3
 19e:	ff 75 e4             	pushl  -0x1c(%ebp)
 1a1:	ff 75 e8             	pushl  -0x18(%ebp)
 1a4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 1a7:	50                   	push   %eax
 1a8:	68 23 0b 00 00       	push   $0xb23
 1ad:	6a 01                	push   $0x1
 1af:	e8 09 05 00 00       	call   6bd <printf>
 1b4:	83 c4 20             	add    $0x20,%esp





  exit();
 1b7:	e8 2a 03 00 00       	call   4e6 <exit>

000001bc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
 1bf:	57                   	push   %edi
 1c0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1c4:	8b 55 10             	mov    0x10(%ebp),%edx
 1c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ca:	89 cb                	mov    %ecx,%ebx
 1cc:	89 df                	mov    %ebx,%edi
 1ce:	89 d1                	mov    %edx,%ecx
 1d0:	fc                   	cld    
 1d1:	f3 aa                	rep stos %al,%es:(%edi)
 1d3:	89 ca                	mov    %ecx,%edx
 1d5:	89 fb                	mov    %edi,%ebx
 1d7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1da:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1dd:	90                   	nop
 1de:	5b                   	pop    %ebx
 1df:	5f                   	pop    %edi
 1e0:	5d                   	pop    %ebp
 1e1:	c3                   	ret    

000001e2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
 1eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1ee:	90                   	nop
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	8d 50 01             	lea    0x1(%eax),%edx
 1f5:	89 55 08             	mov    %edx,0x8(%ebp)
 1f8:	8b 55 0c             	mov    0xc(%ebp),%edx
 1fb:	8d 4a 01             	lea    0x1(%edx),%ecx
 1fe:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 201:	0f b6 12             	movzbl (%edx),%edx
 204:	88 10                	mov    %dl,(%eax)
 206:	0f b6 00             	movzbl (%eax),%eax
 209:	84 c0                	test   %al,%al
 20b:	75 e2                	jne    1ef <strcpy+0xd>
    ;
  return os;
 20d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 210:	c9                   	leave  
 211:	c3                   	ret    

00000212 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 212:	55                   	push   %ebp
 213:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 215:	eb 08                	jmp    21f <strcmp+0xd>
    p++, q++;
 217:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	0f b6 00             	movzbl (%eax),%eax
 225:	84 c0                	test   %al,%al
 227:	74 10                	je     239 <strcmp+0x27>
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 10             	movzbl (%eax),%edx
 22f:	8b 45 0c             	mov    0xc(%ebp),%eax
 232:	0f b6 00             	movzbl (%eax),%eax
 235:	38 c2                	cmp    %al,%dl
 237:	74 de                	je     217 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	0f b6 d0             	movzbl %al,%edx
 242:	8b 45 0c             	mov    0xc(%ebp),%eax
 245:	0f b6 00             	movzbl (%eax),%eax
 248:	0f b6 c0             	movzbl %al,%eax
 24b:	29 c2                	sub    %eax,%edx
 24d:	89 d0                	mov    %edx,%eax
}
 24f:	5d                   	pop    %ebp
 250:	c3                   	ret    

00000251 <strlen>:

uint
strlen(char *s)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 257:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 25e:	eb 04                	jmp    264 <strlen+0x13>
 260:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 264:	8b 55 fc             	mov    -0x4(%ebp),%edx
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	01 d0                	add    %edx,%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	84 c0                	test   %al,%al
 271:	75 ed                	jne    260 <strlen+0xf>
    ;
  return n;
 273:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 276:	c9                   	leave  
 277:	c3                   	ret    

00000278 <memset>:

void*
memset(void *dst, int c, uint n)
{
 278:	55                   	push   %ebp
 279:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 27b:	8b 45 10             	mov    0x10(%ebp),%eax
 27e:	50                   	push   %eax
 27f:	ff 75 0c             	pushl  0xc(%ebp)
 282:	ff 75 08             	pushl  0x8(%ebp)
 285:	e8 32 ff ff ff       	call   1bc <stosb>
 28a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 290:	c9                   	leave  
 291:	c3                   	ret    

00000292 <strchr>:

char*
strchr(const char *s, char c)
{
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp
 295:	83 ec 04             	sub    $0x4,%esp
 298:	8b 45 0c             	mov    0xc(%ebp),%eax
 29b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 29e:	eb 14                	jmp    2b4 <strchr+0x22>
    if(*s == c)
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2a9:	75 05                	jne    2b0 <strchr+0x1e>
      return (char*)s;
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	eb 13                	jmp    2c3 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	84 c0                	test   %al,%al
 2bc:	75 e2                	jne    2a0 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2be:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c3:	c9                   	leave  
 2c4:	c3                   	ret    

000002c5 <gets>:

char*
gets(char *buf, int max)
{
 2c5:	55                   	push   %ebp
 2c6:	89 e5                	mov    %esp,%ebp
 2c8:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d2:	eb 42                	jmp    316 <gets+0x51>
    cc = read(0, &c, 1);
 2d4:	83 ec 04             	sub    $0x4,%esp
 2d7:	6a 01                	push   $0x1
 2d9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2dc:	50                   	push   %eax
 2dd:	6a 00                	push   $0x0
 2df:	e8 1a 02 00 00       	call   4fe <read>
 2e4:	83 c4 10             	add    $0x10,%esp
 2e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ee:	7e 33                	jle    323 <gets+0x5e>
      break;
    buf[i++] = c;
 2f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f3:	8d 50 01             	lea    0x1(%eax),%edx
 2f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2f9:	89 c2                	mov    %eax,%edx
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	01 c2                	add    %eax,%edx
 300:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 304:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 306:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30a:	3c 0a                	cmp    $0xa,%al
 30c:	74 16                	je     324 <gets+0x5f>
 30e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 312:	3c 0d                	cmp    $0xd,%al
 314:	74 0e                	je     324 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 316:	8b 45 f4             	mov    -0xc(%ebp),%eax
 319:	83 c0 01             	add    $0x1,%eax
 31c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 31f:	7c b3                	jl     2d4 <gets+0xf>
 321:	eb 01                	jmp    324 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 323:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 324:	8b 55 f4             	mov    -0xc(%ebp),%edx
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	01 d0                	add    %edx,%eax
 32c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 332:	c9                   	leave  
 333:	c3                   	ret    

00000334 <stat>:

int
stat(char *n, struct stat *st)
{
 334:	55                   	push   %ebp
 335:	89 e5                	mov    %esp,%ebp
 337:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33a:	83 ec 08             	sub    $0x8,%esp
 33d:	6a 00                	push   $0x0
 33f:	ff 75 08             	pushl  0x8(%ebp)
 342:	e8 df 01 00 00       	call   526 <open>
 347:	83 c4 10             	add    $0x10,%esp
 34a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 34d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 351:	79 07                	jns    35a <stat+0x26>
    return -1;
 353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 358:	eb 25                	jmp    37f <stat+0x4b>
  r = fstat(fd, st);
 35a:	83 ec 08             	sub    $0x8,%esp
 35d:	ff 75 0c             	pushl  0xc(%ebp)
 360:	ff 75 f4             	pushl  -0xc(%ebp)
 363:	e8 d6 01 00 00       	call   53e <fstat>
 368:	83 c4 10             	add    $0x10,%esp
 36b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 36e:	83 ec 0c             	sub    $0xc,%esp
 371:	ff 75 f4             	pushl  -0xc(%ebp)
 374:	e8 95 01 00 00       	call   50e <close>
 379:	83 c4 10             	add    $0x10,%esp
  return r;
 37c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37f:	c9                   	leave  
 380:	c3                   	ret    

00000381 <atoi>:

int
atoi(const char *s)
{
 381:	55                   	push   %ebp
 382:	89 e5                	mov    %esp,%ebp
 384:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 387:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 38e:	eb 04                	jmp    394 <atoi+0x13>
 390:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	0f b6 00             	movzbl (%eax),%eax
 39a:	3c 20                	cmp    $0x20,%al
 39c:	74 f2                	je     390 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
 3a1:	0f b6 00             	movzbl (%eax),%eax
 3a4:	3c 2d                	cmp    $0x2d,%al
 3a6:	75 07                	jne    3af <atoi+0x2e>
 3a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3ad:	eb 05                	jmp    3b4 <atoi+0x33>
 3af:	b8 01 00 00 00       	mov    $0x1,%eax
 3b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	3c 2b                	cmp    $0x2b,%al
 3bf:	74 0a                	je     3cb <atoi+0x4a>
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	0f b6 00             	movzbl (%eax),%eax
 3c7:	3c 2d                	cmp    $0x2d,%al
 3c9:	75 2b                	jne    3f6 <atoi+0x75>
    s++;
 3cb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 3cf:	eb 25                	jmp    3f6 <atoi+0x75>
    n = n*10 + *s++ - '0';
 3d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d4:	89 d0                	mov    %edx,%eax
 3d6:	c1 e0 02             	shl    $0x2,%eax
 3d9:	01 d0                	add    %edx,%eax
 3db:	01 c0                	add    %eax,%eax
 3dd:	89 c1                	mov    %eax,%ecx
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	8d 50 01             	lea    0x1(%eax),%edx
 3e5:	89 55 08             	mov    %edx,0x8(%ebp)
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	0f be c0             	movsbl %al,%eax
 3ee:	01 c8                	add    %ecx,%eax
 3f0:	83 e8 30             	sub    $0x30,%eax
 3f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	0f b6 00             	movzbl (%eax),%eax
 3fc:	3c 2f                	cmp    $0x2f,%al
 3fe:	7e 0a                	jle    40a <atoi+0x89>
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	0f b6 00             	movzbl (%eax),%eax
 406:	3c 39                	cmp    $0x39,%al
 408:	7e c7                	jle    3d1 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 40a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 40d:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <atoo>:

int
atoo(const char *s)
{
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 419:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 420:	eb 04                	jmp    426 <atoo+0x13>
 422:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	3c 20                	cmp    $0x20,%al
 42e:	74 f2                	je     422 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	0f b6 00             	movzbl (%eax),%eax
 436:	3c 2d                	cmp    $0x2d,%al
 438:	75 07                	jne    441 <atoo+0x2e>
 43a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 43f:	eb 05                	jmp    446 <atoo+0x33>
 441:	b8 01 00 00 00       	mov    $0x1,%eax
 446:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	3c 2b                	cmp    $0x2b,%al
 451:	74 0a                	je     45d <atoo+0x4a>
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	0f b6 00             	movzbl (%eax),%eax
 459:	3c 2d                	cmp    $0x2d,%al
 45b:	75 27                	jne    484 <atoo+0x71>
    s++;
 45d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 461:	eb 21                	jmp    484 <atoo+0x71>
    n = n*8 + *s++ - '0';
 463:	8b 45 fc             	mov    -0x4(%ebp),%eax
 466:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	8d 50 01             	lea    0x1(%eax),%edx
 473:	89 55 08             	mov    %edx,0x8(%ebp)
 476:	0f b6 00             	movzbl (%eax),%eax
 479:	0f be c0             	movsbl %al,%eax
 47c:	01 c8                	add    %ecx,%eax
 47e:	83 e8 30             	sub    $0x30,%eax
 481:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 484:	8b 45 08             	mov    0x8(%ebp),%eax
 487:	0f b6 00             	movzbl (%eax),%eax
 48a:	3c 2f                	cmp    $0x2f,%al
 48c:	7e 0a                	jle    498 <atoo+0x85>
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	0f b6 00             	movzbl (%eax),%eax
 494:	3c 37                	cmp    $0x37,%al
 496:	7e cb                	jle    463 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 498:	8b 45 f8             	mov    -0x8(%ebp),%eax
 49b:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 49f:	c9                   	leave  
 4a0:	c3                   	ret    

000004a1 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 4a1:	55                   	push   %ebp
 4a2:	89 e5                	mov    %esp,%ebp
 4a4:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4b3:	eb 17                	jmp    4cc <memmove+0x2b>
    *dst++ = *src++;
 4b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b8:	8d 50 01             	lea    0x1(%eax),%edx
 4bb:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4be:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4c1:	8d 4a 01             	lea    0x1(%edx),%ecx
 4c4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4c7:	0f b6 12             	movzbl (%edx),%edx
 4ca:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4cc:	8b 45 10             	mov    0x10(%ebp),%eax
 4cf:	8d 50 ff             	lea    -0x1(%eax),%edx
 4d2:	89 55 10             	mov    %edx,0x10(%ebp)
 4d5:	85 c0                	test   %eax,%eax
 4d7:	7f dc                	jg     4b5 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4dc:	c9                   	leave  
 4dd:	c3                   	ret    

000004de <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4de:	b8 01 00 00 00       	mov    $0x1,%eax
 4e3:	cd 40                	int    $0x40
 4e5:	c3                   	ret    

000004e6 <exit>:
SYSCALL(exit)
 4e6:	b8 02 00 00 00       	mov    $0x2,%eax
 4eb:	cd 40                	int    $0x40
 4ed:	c3                   	ret    

000004ee <wait>:
SYSCALL(wait)
 4ee:	b8 03 00 00 00       	mov    $0x3,%eax
 4f3:	cd 40                	int    $0x40
 4f5:	c3                   	ret    

000004f6 <pipe>:
SYSCALL(pipe)
 4f6:	b8 04 00 00 00       	mov    $0x4,%eax
 4fb:	cd 40                	int    $0x40
 4fd:	c3                   	ret    

000004fe <read>:
SYSCALL(read)
 4fe:	b8 05 00 00 00       	mov    $0x5,%eax
 503:	cd 40                	int    $0x40
 505:	c3                   	ret    

00000506 <write>:
SYSCALL(write)
 506:	b8 10 00 00 00       	mov    $0x10,%eax
 50b:	cd 40                	int    $0x40
 50d:	c3                   	ret    

0000050e <close>:
SYSCALL(close)
 50e:	b8 15 00 00 00       	mov    $0x15,%eax
 513:	cd 40                	int    $0x40
 515:	c3                   	ret    

00000516 <kill>:
SYSCALL(kill)
 516:	b8 06 00 00 00       	mov    $0x6,%eax
 51b:	cd 40                	int    $0x40
 51d:	c3                   	ret    

0000051e <exec>:
SYSCALL(exec)
 51e:	b8 07 00 00 00       	mov    $0x7,%eax
 523:	cd 40                	int    $0x40
 525:	c3                   	ret    

00000526 <open>:
SYSCALL(open)
 526:	b8 0f 00 00 00       	mov    $0xf,%eax
 52b:	cd 40                	int    $0x40
 52d:	c3                   	ret    

0000052e <mknod>:
SYSCALL(mknod)
 52e:	b8 11 00 00 00       	mov    $0x11,%eax
 533:	cd 40                	int    $0x40
 535:	c3                   	ret    

00000536 <unlink>:
SYSCALL(unlink)
 536:	b8 12 00 00 00       	mov    $0x12,%eax
 53b:	cd 40                	int    $0x40
 53d:	c3                   	ret    

0000053e <fstat>:
SYSCALL(fstat)
 53e:	b8 08 00 00 00       	mov    $0x8,%eax
 543:	cd 40                	int    $0x40
 545:	c3                   	ret    

00000546 <link>:
SYSCALL(link)
 546:	b8 13 00 00 00       	mov    $0x13,%eax
 54b:	cd 40                	int    $0x40
 54d:	c3                   	ret    

0000054e <mkdir>:
SYSCALL(mkdir)
 54e:	b8 14 00 00 00       	mov    $0x14,%eax
 553:	cd 40                	int    $0x40
 555:	c3                   	ret    

00000556 <chdir>:
SYSCALL(chdir)
 556:	b8 09 00 00 00       	mov    $0x9,%eax
 55b:	cd 40                	int    $0x40
 55d:	c3                   	ret    

0000055e <dup>:
SYSCALL(dup)
 55e:	b8 0a 00 00 00       	mov    $0xa,%eax
 563:	cd 40                	int    $0x40
 565:	c3                   	ret    

00000566 <getpid>:
SYSCALL(getpid)
 566:	b8 0b 00 00 00       	mov    $0xb,%eax
 56b:	cd 40                	int    $0x40
 56d:	c3                   	ret    

0000056e <sbrk>:
SYSCALL(sbrk)
 56e:	b8 0c 00 00 00       	mov    $0xc,%eax
 573:	cd 40                	int    $0x40
 575:	c3                   	ret    

00000576 <sleep>:
SYSCALL(sleep)
 576:	b8 0d 00 00 00       	mov    $0xd,%eax
 57b:	cd 40                	int    $0x40
 57d:	c3                   	ret    

0000057e <uptime>:
SYSCALL(uptime)
 57e:	b8 0e 00 00 00       	mov    $0xe,%eax
 583:	cd 40                	int    $0x40
 585:	c3                   	ret    

00000586 <halt>:
SYSCALL(halt)
 586:	b8 16 00 00 00       	mov    $0x16,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret    

0000058e <date>:
SYSCALL(date)
 58e:	b8 17 00 00 00       	mov    $0x17,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret    

00000596 <getuid>:
SYSCALL(getuid)
 596:	b8 18 00 00 00       	mov    $0x18,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret    

0000059e <getgid>:
SYSCALL(getgid)
 59e:	b8 19 00 00 00       	mov    $0x19,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret    

000005a6 <getppid>:
SYSCALL(getppid)
 5a6:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret    

000005ae <setuid>:
SYSCALL(setuid)
 5ae:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5b3:	cd 40                	int    $0x40
 5b5:	c3                   	ret    

000005b6 <setgid>:
SYSCALL(setgid)
 5b6:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret    

000005be <getprocs>:
SYSCALL(getprocs)
 5be:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret    

000005c6 <setpriority>:
SYSCALL(setpriority)
 5c6:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret    

000005ce <chmod>:
SYSCALL(chmod)
 5ce:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <chown>:
SYSCALL(chown)
 5d6:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <chgrp>:
SYSCALL(chgrp)
 5de:	b8 1e 00 00 00       	mov    $0x1e,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e6:	55                   	push   %ebp
 5e7:	89 e5                	mov    %esp,%ebp
 5e9:	83 ec 18             	sub    $0x18,%esp
 5ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ef:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5f2:	83 ec 04             	sub    $0x4,%esp
 5f5:	6a 01                	push   $0x1
 5f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5fa:	50                   	push   %eax
 5fb:	ff 75 08             	pushl  0x8(%ebp)
 5fe:	e8 03 ff ff ff       	call   506 <write>
 603:	83 c4 10             	add    $0x10,%esp
}
 606:	90                   	nop
 607:	c9                   	leave  
 608:	c3                   	ret    

00000609 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	53                   	push   %ebx
 60d:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 610:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 617:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 61b:	74 17                	je     634 <printint+0x2b>
 61d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 621:	79 11                	jns    634 <printint+0x2b>
    neg = 1;
 623:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 62a:	8b 45 0c             	mov    0xc(%ebp),%eax
 62d:	f7 d8                	neg    %eax
 62f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 632:	eb 06                	jmp    63a <printint+0x31>
  } else {
    x = xx;
 634:	8b 45 0c             	mov    0xc(%ebp),%eax
 637:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 63a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 641:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 644:	8d 41 01             	lea    0x1(%ecx),%eax
 647:	89 45 f4             	mov    %eax,-0xc(%ebp)
 64a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 64d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 650:	ba 00 00 00 00       	mov    $0x0,%edx
 655:	f7 f3                	div    %ebx
 657:	89 d0                	mov    %edx,%eax
 659:	0f b6 80 b0 0d 00 00 	movzbl 0xdb0(%eax),%eax
 660:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 664:	8b 5d 10             	mov    0x10(%ebp),%ebx
 667:	8b 45 ec             	mov    -0x14(%ebp),%eax
 66a:	ba 00 00 00 00       	mov    $0x0,%edx
 66f:	f7 f3                	div    %ebx
 671:	89 45 ec             	mov    %eax,-0x14(%ebp)
 674:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 678:	75 c7                	jne    641 <printint+0x38>
  if(neg)
 67a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 67e:	74 2d                	je     6ad <printint+0xa4>
    buf[i++] = '-';
 680:	8b 45 f4             	mov    -0xc(%ebp),%eax
 683:	8d 50 01             	lea    0x1(%eax),%edx
 686:	89 55 f4             	mov    %edx,-0xc(%ebp)
 689:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 68e:	eb 1d                	jmp    6ad <printint+0xa4>
    putc(fd, buf[i]);
 690:	8d 55 dc             	lea    -0x24(%ebp),%edx
 693:	8b 45 f4             	mov    -0xc(%ebp),%eax
 696:	01 d0                	add    %edx,%eax
 698:	0f b6 00             	movzbl (%eax),%eax
 69b:	0f be c0             	movsbl %al,%eax
 69e:	83 ec 08             	sub    $0x8,%esp
 6a1:	50                   	push   %eax
 6a2:	ff 75 08             	pushl  0x8(%ebp)
 6a5:	e8 3c ff ff ff       	call   5e6 <putc>
 6aa:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6ad:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b5:	79 d9                	jns    690 <printint+0x87>
    putc(fd, buf[i]);
}
 6b7:	90                   	nop
 6b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 6bb:	c9                   	leave  
 6bc:	c3                   	ret    

000006bd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6bd:	55                   	push   %ebp
 6be:	89 e5                	mov    %esp,%ebp
 6c0:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6ca:	8d 45 0c             	lea    0xc(%ebp),%eax
 6cd:	83 c0 04             	add    $0x4,%eax
 6d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6da:	e9 59 01 00 00       	jmp    838 <printf+0x17b>
    c = fmt[i] & 0xff;
 6df:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e5:	01 d0                	add    %edx,%eax
 6e7:	0f b6 00             	movzbl (%eax),%eax
 6ea:	0f be c0             	movsbl %al,%eax
 6ed:	25 ff 00 00 00       	and    $0xff,%eax
 6f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f9:	75 2c                	jne    727 <printf+0x6a>
      if(c == '%'){
 6fb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ff:	75 0c                	jne    70d <printf+0x50>
        state = '%';
 701:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 708:	e9 27 01 00 00       	jmp    834 <printf+0x177>
      } else {
        putc(fd, c);
 70d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 710:	0f be c0             	movsbl %al,%eax
 713:	83 ec 08             	sub    $0x8,%esp
 716:	50                   	push   %eax
 717:	ff 75 08             	pushl  0x8(%ebp)
 71a:	e8 c7 fe ff ff       	call   5e6 <putc>
 71f:	83 c4 10             	add    $0x10,%esp
 722:	e9 0d 01 00 00       	jmp    834 <printf+0x177>
      }
    } else if(state == '%'){
 727:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 72b:	0f 85 03 01 00 00    	jne    834 <printf+0x177>
      if(c == 'd'){
 731:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 735:	75 1e                	jne    755 <printf+0x98>
        printint(fd, *ap, 10, 1);
 737:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73a:	8b 00                	mov    (%eax),%eax
 73c:	6a 01                	push   $0x1
 73e:	6a 0a                	push   $0xa
 740:	50                   	push   %eax
 741:	ff 75 08             	pushl  0x8(%ebp)
 744:	e8 c0 fe ff ff       	call   609 <printint>
 749:	83 c4 10             	add    $0x10,%esp
        ap++;
 74c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 750:	e9 d8 00 00 00       	jmp    82d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 755:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 759:	74 06                	je     761 <printf+0xa4>
 75b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 75f:	75 1e                	jne    77f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 761:	8b 45 e8             	mov    -0x18(%ebp),%eax
 764:	8b 00                	mov    (%eax),%eax
 766:	6a 00                	push   $0x0
 768:	6a 10                	push   $0x10
 76a:	50                   	push   %eax
 76b:	ff 75 08             	pushl  0x8(%ebp)
 76e:	e8 96 fe ff ff       	call   609 <printint>
 773:	83 c4 10             	add    $0x10,%esp
        ap++;
 776:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 77a:	e9 ae 00 00 00       	jmp    82d <printf+0x170>
      } else if(c == 's'){
 77f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 783:	75 43                	jne    7c8 <printf+0x10b>
        s = (char*)*ap;
 785:	8b 45 e8             	mov    -0x18(%ebp),%eax
 788:	8b 00                	mov    (%eax),%eax
 78a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 78d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 791:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 795:	75 25                	jne    7bc <printf+0xff>
          s = "(null)";
 797:	c7 45 f4 3d 0b 00 00 	movl   $0xb3d,-0xc(%ebp)
        while(*s != 0){
 79e:	eb 1c                	jmp    7bc <printf+0xff>
          putc(fd, *s);
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	0f b6 00             	movzbl (%eax),%eax
 7a6:	0f be c0             	movsbl %al,%eax
 7a9:	83 ec 08             	sub    $0x8,%esp
 7ac:	50                   	push   %eax
 7ad:	ff 75 08             	pushl  0x8(%ebp)
 7b0:	e8 31 fe ff ff       	call   5e6 <putc>
 7b5:	83 c4 10             	add    $0x10,%esp
          s++;
 7b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	0f b6 00             	movzbl (%eax),%eax
 7c2:	84 c0                	test   %al,%al
 7c4:	75 da                	jne    7a0 <printf+0xe3>
 7c6:	eb 65                	jmp    82d <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7c8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7cc:	75 1d                	jne    7eb <printf+0x12e>
        putc(fd, *ap);
 7ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	0f be c0             	movsbl %al,%eax
 7d6:	83 ec 08             	sub    $0x8,%esp
 7d9:	50                   	push   %eax
 7da:	ff 75 08             	pushl  0x8(%ebp)
 7dd:	e8 04 fe ff ff       	call   5e6 <putc>
 7e2:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e9:	eb 42                	jmp    82d <printf+0x170>
      } else if(c == '%'){
 7eb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ef:	75 17                	jne    808 <printf+0x14b>
        putc(fd, c);
 7f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f4:	0f be c0             	movsbl %al,%eax
 7f7:	83 ec 08             	sub    $0x8,%esp
 7fa:	50                   	push   %eax
 7fb:	ff 75 08             	pushl  0x8(%ebp)
 7fe:	e8 e3 fd ff ff       	call   5e6 <putc>
 803:	83 c4 10             	add    $0x10,%esp
 806:	eb 25                	jmp    82d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 808:	83 ec 08             	sub    $0x8,%esp
 80b:	6a 25                	push   $0x25
 80d:	ff 75 08             	pushl  0x8(%ebp)
 810:	e8 d1 fd ff ff       	call   5e6 <putc>
 815:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 818:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 81b:	0f be c0             	movsbl %al,%eax
 81e:	83 ec 08             	sub    $0x8,%esp
 821:	50                   	push   %eax
 822:	ff 75 08             	pushl  0x8(%ebp)
 825:	e8 bc fd ff ff       	call   5e6 <putc>
 82a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 82d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 834:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 838:	8b 55 0c             	mov    0xc(%ebp),%edx
 83b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83e:	01 d0                	add    %edx,%eax
 840:	0f b6 00             	movzbl (%eax),%eax
 843:	84 c0                	test   %al,%al
 845:	0f 85 94 fe ff ff    	jne    6df <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 84b:	90                   	nop
 84c:	c9                   	leave  
 84d:	c3                   	ret    

0000084e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84e:	55                   	push   %ebp
 84f:	89 e5                	mov    %esp,%ebp
 851:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 854:	8b 45 08             	mov    0x8(%ebp),%eax
 857:	83 e8 08             	sub    $0x8,%eax
 85a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85d:	a1 cc 0d 00 00       	mov    0xdcc,%eax
 862:	89 45 fc             	mov    %eax,-0x4(%ebp)
 865:	eb 24                	jmp    88b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	8b 00                	mov    (%eax),%eax
 86c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86f:	77 12                	ja     883 <free+0x35>
 871:	8b 45 f8             	mov    -0x8(%ebp),%eax
 874:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 877:	77 24                	ja     89d <free+0x4f>
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 881:	77 1a                	ja     89d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	8b 00                	mov    (%eax),%eax
 888:	89 45 fc             	mov    %eax,-0x4(%ebp)
 88b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 891:	76 d4                	jbe    867 <free+0x19>
 893:	8b 45 fc             	mov    -0x4(%ebp),%eax
 896:	8b 00                	mov    (%eax),%eax
 898:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 89b:	76 ca                	jbe    867 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 89d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a0:	8b 40 04             	mov    0x4(%eax),%eax
 8a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ad:	01 c2                	add    %eax,%edx
 8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b2:	8b 00                	mov    (%eax),%eax
 8b4:	39 c2                	cmp    %eax,%edx
 8b6:	75 24                	jne    8dc <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bb:	8b 50 04             	mov    0x4(%eax),%edx
 8be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c1:	8b 00                	mov    (%eax),%eax
 8c3:	8b 40 04             	mov    0x4(%eax),%eax
 8c6:	01 c2                	add    %eax,%edx
 8c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	8b 00                	mov    (%eax),%eax
 8d3:	8b 10                	mov    (%eax),%edx
 8d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d8:	89 10                	mov    %edx,(%eax)
 8da:	eb 0a                	jmp    8e6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 10                	mov    (%eax),%edx
 8e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e9:	8b 40 04             	mov    0x4(%eax),%eax
 8ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	01 d0                	add    %edx,%eax
 8f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8fb:	75 20                	jne    91d <free+0xcf>
    p->s.size += bp->s.size;
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 50 04             	mov    0x4(%eax),%edx
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	8b 40 04             	mov    0x4(%eax),%eax
 909:	01 c2                	add    %eax,%edx
 90b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 911:	8b 45 f8             	mov    -0x8(%ebp),%eax
 914:	8b 10                	mov    (%eax),%edx
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	89 10                	mov    %edx,(%eax)
 91b:	eb 08                	jmp    925 <free+0xd7>
  } else
    p->s.ptr = bp;
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	8b 55 f8             	mov    -0x8(%ebp),%edx
 923:	89 10                	mov    %edx,(%eax)
  freep = p;
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	a3 cc 0d 00 00       	mov    %eax,0xdcc
}
 92d:	90                   	nop
 92e:	c9                   	leave  
 92f:	c3                   	ret    

00000930 <morecore>:

static Header*
morecore(uint nu)
{
 930:	55                   	push   %ebp
 931:	89 e5                	mov    %esp,%ebp
 933:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 936:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 93d:	77 07                	ja     946 <morecore+0x16>
    nu = 4096;
 93f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 946:	8b 45 08             	mov    0x8(%ebp),%eax
 949:	c1 e0 03             	shl    $0x3,%eax
 94c:	83 ec 0c             	sub    $0xc,%esp
 94f:	50                   	push   %eax
 950:	e8 19 fc ff ff       	call   56e <sbrk>
 955:	83 c4 10             	add    $0x10,%esp
 958:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 95b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 95f:	75 07                	jne    968 <morecore+0x38>
    return 0;
 961:	b8 00 00 00 00       	mov    $0x0,%eax
 966:	eb 26                	jmp    98e <morecore+0x5e>
  hp = (Header*)p;
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 96e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 971:	8b 55 08             	mov    0x8(%ebp),%edx
 974:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 977:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97a:	83 c0 08             	add    $0x8,%eax
 97d:	83 ec 0c             	sub    $0xc,%esp
 980:	50                   	push   %eax
 981:	e8 c8 fe ff ff       	call   84e <free>
 986:	83 c4 10             	add    $0x10,%esp
  return freep;
 989:	a1 cc 0d 00 00       	mov    0xdcc,%eax
}
 98e:	c9                   	leave  
 98f:	c3                   	ret    

00000990 <malloc>:

void*
malloc(uint nbytes)
{
 990:	55                   	push   %ebp
 991:	89 e5                	mov    %esp,%ebp
 993:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 996:	8b 45 08             	mov    0x8(%ebp),%eax
 999:	83 c0 07             	add    $0x7,%eax
 99c:	c1 e8 03             	shr    $0x3,%eax
 99f:	83 c0 01             	add    $0x1,%eax
 9a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9a5:	a1 cc 0d 00 00       	mov    0xdcc,%eax
 9aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b1:	75 23                	jne    9d6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9b3:	c7 45 f0 c4 0d 00 00 	movl   $0xdc4,-0x10(%ebp)
 9ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bd:	a3 cc 0d 00 00       	mov    %eax,0xdcc
 9c2:	a1 cc 0d 00 00       	mov    0xdcc,%eax
 9c7:	a3 c4 0d 00 00       	mov    %eax,0xdc4
    base.s.size = 0;
 9cc:	c7 05 c8 0d 00 00 00 	movl   $0x0,0xdc8
 9d3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d9:	8b 00                	mov    (%eax),%eax
 9db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e1:	8b 40 04             	mov    0x4(%eax),%eax
 9e4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9e7:	72 4d                	jb     a36 <malloc+0xa6>
      if(p->s.size == nunits)
 9e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ec:	8b 40 04             	mov    0x4(%eax),%eax
 9ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9f2:	75 0c                	jne    a00 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f7:	8b 10                	mov    (%eax),%edx
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	89 10                	mov    %edx,(%eax)
 9fe:	eb 26                	jmp    a26 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a03:	8b 40 04             	mov    0x4(%eax),%eax
 a06:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a09:	89 c2                	mov    %eax,%edx
 a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a14:	8b 40 04             	mov    0x4(%eax),%eax
 a17:	c1 e0 03             	shl    $0x3,%eax
 a1a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a23:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a29:	a3 cc 0d 00 00       	mov    %eax,0xdcc
      return (void*)(p + 1);
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	83 c0 08             	add    $0x8,%eax
 a34:	eb 3b                	jmp    a71 <malloc+0xe1>
    }
    if(p == freep)
 a36:	a1 cc 0d 00 00       	mov    0xdcc,%eax
 a3b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a3e:	75 1e                	jne    a5e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a40:	83 ec 0c             	sub    $0xc,%esp
 a43:	ff 75 ec             	pushl  -0x14(%ebp)
 a46:	e8 e5 fe ff ff       	call   930 <morecore>
 a4b:	83 c4 10             	add    $0x10,%esp
 a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a55:	75 07                	jne    a5e <malloc+0xce>
        return 0;
 a57:	b8 00 00 00 00       	mov    $0x0,%eax
 a5c:	eb 13                	jmp    a71 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a6c:	e9 6d ff ff ff       	jmp    9de <malloc+0x4e>
}
 a71:	c9                   	leave  
 a72:	c3                   	ret    
