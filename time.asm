
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
  3b:	68 5c 0a 00 00       	push   $0xa5c
  40:	6a 01                	push   $0x1
  42:	e8 5e 06 00 00       	call   6a5 <printf>
  47:	83 c4 10             	add    $0x10,%esp
      strcpy(process, "time");
  4a:	83 ec 08             	sub    $0x8,%esp
  4d:	68 8b 0a 00 00       	push   $0xa8b
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
  aa:	68 90 0a 00 00       	push   $0xa90
  af:	6a 01                	push   $0x1
  b1:	e8 ef 05 00 00       	call   6a5 <printf>
  b6:	83 c4 10             	add    $0x10,%esp
	      exit();
  b9:	e8 28 04 00 00       	call   4e6 <exit>
	  }
      }

      else
	  printf(1,"fork error\n");
  be:	83 ec 08             	sub    $0x8,%esp
  c1:	68 ab 0a 00 00       	push   $0xaab
  c6:	6a 01                	push   $0x1
  c8:	e8 d8 05 00 00       	call   6a5 <printf>
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
 128:	68 b7 0a 00 00       	push   $0xab7
 12d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 130:	50                   	push   %eax
 131:	68 c5 0a 00 00       	push   $0xac5
 136:	6a 01                	push   $0x1
 138:	e8 68 05 00 00       	call   6a5 <printf>
 13d:	83 c4 10             	add    $0x10,%esp
      
      if(milli < 10)
 140:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
 144:	7f 21                	jg     167 <main+0x167>
      printf(1, "%s ran in %d.00%d seconds\n\n",process, total, milli, " seconds");
 146:	83 ec 08             	sub    $0x8,%esp
 149:	68 cb 0a 00 00       	push   $0xacb
 14e:	ff 75 e4             	pushl  -0x1c(%ebp)
 151:	ff 75 e8             	pushl  -0x18(%ebp)
 154:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 157:	50                   	push   %eax
 158:	68 d4 0a 00 00       	push   $0xad4
 15d:	6a 01                	push   $0x1
 15f:	e8 41 05 00 00       	call   6a5 <printf>
 164:	83 c4 20             	add    $0x20,%esp
      
      if(milli > 9 && milli < 100)
 167:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
 16b:	7e 29                	jle    196 <main+0x196>
 16d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 171:	7f 23                	jg     196 <main+0x196>
      printf(1, "%s ran in %d.0%d seconds\n\n",process, total, milli, " seconds");
 173:	83 ec 08             	sub    $0x8,%esp
 176:	68 cb 0a 00 00       	push   $0xacb
 17b:	ff 75 e4             	pushl  -0x1c(%ebp)
 17e:	ff 75 e8             	pushl  -0x18(%ebp)
 181:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 184:	50                   	push   %eax
 185:	68 f0 0a 00 00       	push   $0xaf0
 18a:	6a 01                	push   $0x1
 18c:	e8 14 05 00 00       	call   6a5 <printf>
 191:	83 c4 20             	add    $0x20,%esp
 194:	eb 21                	jmp    1b7 <main+0x1b7>
      
      else
      printf(1, "%s ran in %d.%d seconds\n\n",process, total, milli, " seconds");
 196:	83 ec 08             	sub    $0x8,%esp
 199:	68 cb 0a 00 00       	push   $0xacb
 19e:	ff 75 e4             	pushl  -0x1c(%ebp)
 1a1:	ff 75 e8             	pushl  -0x18(%ebp)
 1a4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 1a7:	50                   	push   %eax
 1a8:	68 0b 0b 00 00       	push   $0xb0b
 1ad:	6a 01                	push   $0x1
 1af:	e8 f1 04 00 00       	call   6a5 <printf>
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

000005ce <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ce:	55                   	push   %ebp
 5cf:	89 e5                	mov    %esp,%ebp
 5d1:	83 ec 18             	sub    $0x18,%esp
 5d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d7:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5da:	83 ec 04             	sub    $0x4,%esp
 5dd:	6a 01                	push   $0x1
 5df:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5e2:	50                   	push   %eax
 5e3:	ff 75 08             	pushl  0x8(%ebp)
 5e6:	e8 1b ff ff ff       	call   506 <write>
 5eb:	83 c4 10             	add    $0x10,%esp
}
 5ee:	90                   	nop
 5ef:	c9                   	leave  
 5f0:	c3                   	ret    

000005f1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5f1:	55                   	push   %ebp
 5f2:	89 e5                	mov    %esp,%ebp
 5f4:	53                   	push   %ebx
 5f5:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5ff:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 603:	74 17                	je     61c <printint+0x2b>
 605:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 609:	79 11                	jns    61c <printint+0x2b>
    neg = 1;
 60b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 612:	8b 45 0c             	mov    0xc(%ebp),%eax
 615:	f7 d8                	neg    %eax
 617:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61a:	eb 06                	jmp    622 <printint+0x31>
  } else {
    x = xx;
 61c:	8b 45 0c             	mov    0xc(%ebp),%eax
 61f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 622:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 629:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 62c:	8d 41 01             	lea    0x1(%ecx),%eax
 62f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 632:	8b 5d 10             	mov    0x10(%ebp),%ebx
 635:	8b 45 ec             	mov    -0x14(%ebp),%eax
 638:	ba 00 00 00 00       	mov    $0x0,%edx
 63d:	f7 f3                	div    %ebx
 63f:	89 d0                	mov    %edx,%eax
 641:	0f b6 80 98 0d 00 00 	movzbl 0xd98(%eax),%eax
 648:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 64c:	8b 5d 10             	mov    0x10(%ebp),%ebx
 64f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 652:	ba 00 00 00 00       	mov    $0x0,%edx
 657:	f7 f3                	div    %ebx
 659:	89 45 ec             	mov    %eax,-0x14(%ebp)
 65c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 660:	75 c7                	jne    629 <printint+0x38>
  if(neg)
 662:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 666:	74 2d                	je     695 <printint+0xa4>
    buf[i++] = '-';
 668:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66b:	8d 50 01             	lea    0x1(%eax),%edx
 66e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 671:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 676:	eb 1d                	jmp    695 <printint+0xa4>
    putc(fd, buf[i]);
 678:	8d 55 dc             	lea    -0x24(%ebp),%edx
 67b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67e:	01 d0                	add    %edx,%eax
 680:	0f b6 00             	movzbl (%eax),%eax
 683:	0f be c0             	movsbl %al,%eax
 686:	83 ec 08             	sub    $0x8,%esp
 689:	50                   	push   %eax
 68a:	ff 75 08             	pushl  0x8(%ebp)
 68d:	e8 3c ff ff ff       	call   5ce <putc>
 692:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 695:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 699:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69d:	79 d9                	jns    678 <printint+0x87>
    putc(fd, buf[i]);
}
 69f:	90                   	nop
 6a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 6a3:	c9                   	leave  
 6a4:	c3                   	ret    

000006a5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6a5:	55                   	push   %ebp
 6a6:	89 e5                	mov    %esp,%ebp
 6a8:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6b2:	8d 45 0c             	lea    0xc(%ebp),%eax
 6b5:	83 c0 04             	add    $0x4,%eax
 6b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6bb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6c2:	e9 59 01 00 00       	jmp    820 <printf+0x17b>
    c = fmt[i] & 0xff;
 6c7:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cd:	01 d0                	add    %edx,%eax
 6cf:	0f b6 00             	movzbl (%eax),%eax
 6d2:	0f be c0             	movsbl %al,%eax
 6d5:	25 ff 00 00 00       	and    $0xff,%eax
 6da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e1:	75 2c                	jne    70f <printf+0x6a>
      if(c == '%'){
 6e3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6e7:	75 0c                	jne    6f5 <printf+0x50>
        state = '%';
 6e9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6f0:	e9 27 01 00 00       	jmp    81c <printf+0x177>
      } else {
        putc(fd, c);
 6f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6f8:	0f be c0             	movsbl %al,%eax
 6fb:	83 ec 08             	sub    $0x8,%esp
 6fe:	50                   	push   %eax
 6ff:	ff 75 08             	pushl  0x8(%ebp)
 702:	e8 c7 fe ff ff       	call   5ce <putc>
 707:	83 c4 10             	add    $0x10,%esp
 70a:	e9 0d 01 00 00       	jmp    81c <printf+0x177>
      }
    } else if(state == '%'){
 70f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 713:	0f 85 03 01 00 00    	jne    81c <printf+0x177>
      if(c == 'd'){
 719:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 71d:	75 1e                	jne    73d <printf+0x98>
        printint(fd, *ap, 10, 1);
 71f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	6a 01                	push   $0x1
 726:	6a 0a                	push   $0xa
 728:	50                   	push   %eax
 729:	ff 75 08             	pushl  0x8(%ebp)
 72c:	e8 c0 fe ff ff       	call   5f1 <printint>
 731:	83 c4 10             	add    $0x10,%esp
        ap++;
 734:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 738:	e9 d8 00 00 00       	jmp    815 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 73d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 741:	74 06                	je     749 <printf+0xa4>
 743:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 747:	75 1e                	jne    767 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 749:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	6a 00                	push   $0x0
 750:	6a 10                	push   $0x10
 752:	50                   	push   %eax
 753:	ff 75 08             	pushl  0x8(%ebp)
 756:	e8 96 fe ff ff       	call   5f1 <printint>
 75b:	83 c4 10             	add    $0x10,%esp
        ap++;
 75e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 762:	e9 ae 00 00 00       	jmp    815 <printf+0x170>
      } else if(c == 's'){
 767:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 76b:	75 43                	jne    7b0 <printf+0x10b>
        s = (char*)*ap;
 76d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 770:	8b 00                	mov    (%eax),%eax
 772:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 775:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 779:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 77d:	75 25                	jne    7a4 <printf+0xff>
          s = "(null)";
 77f:	c7 45 f4 25 0b 00 00 	movl   $0xb25,-0xc(%ebp)
        while(*s != 0){
 786:	eb 1c                	jmp    7a4 <printf+0xff>
          putc(fd, *s);
 788:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78b:	0f b6 00             	movzbl (%eax),%eax
 78e:	0f be c0             	movsbl %al,%eax
 791:	83 ec 08             	sub    $0x8,%esp
 794:	50                   	push   %eax
 795:	ff 75 08             	pushl  0x8(%ebp)
 798:	e8 31 fe ff ff       	call   5ce <putc>
 79d:	83 c4 10             	add    $0x10,%esp
          s++;
 7a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	0f b6 00             	movzbl (%eax),%eax
 7aa:	84 c0                	test   %al,%al
 7ac:	75 da                	jne    788 <printf+0xe3>
 7ae:	eb 65                	jmp    815 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7b0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7b4:	75 1d                	jne    7d3 <printf+0x12e>
        putc(fd, *ap);
 7b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b9:	8b 00                	mov    (%eax),%eax
 7bb:	0f be c0             	movsbl %al,%eax
 7be:	83 ec 08             	sub    $0x8,%esp
 7c1:	50                   	push   %eax
 7c2:	ff 75 08             	pushl  0x8(%ebp)
 7c5:	e8 04 fe ff ff       	call   5ce <putc>
 7ca:	83 c4 10             	add    $0x10,%esp
        ap++;
 7cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d1:	eb 42                	jmp    815 <printf+0x170>
      } else if(c == '%'){
 7d3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7d7:	75 17                	jne    7f0 <printf+0x14b>
        putc(fd, c);
 7d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7dc:	0f be c0             	movsbl %al,%eax
 7df:	83 ec 08             	sub    $0x8,%esp
 7e2:	50                   	push   %eax
 7e3:	ff 75 08             	pushl  0x8(%ebp)
 7e6:	e8 e3 fd ff ff       	call   5ce <putc>
 7eb:	83 c4 10             	add    $0x10,%esp
 7ee:	eb 25                	jmp    815 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f0:	83 ec 08             	sub    $0x8,%esp
 7f3:	6a 25                	push   $0x25
 7f5:	ff 75 08             	pushl  0x8(%ebp)
 7f8:	e8 d1 fd ff ff       	call   5ce <putc>
 7fd:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 800:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 803:	0f be c0             	movsbl %al,%eax
 806:	83 ec 08             	sub    $0x8,%esp
 809:	50                   	push   %eax
 80a:	ff 75 08             	pushl  0x8(%ebp)
 80d:	e8 bc fd ff ff       	call   5ce <putc>
 812:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 815:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 81c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 820:	8b 55 0c             	mov    0xc(%ebp),%edx
 823:	8b 45 f0             	mov    -0x10(%ebp),%eax
 826:	01 d0                	add    %edx,%eax
 828:	0f b6 00             	movzbl (%eax),%eax
 82b:	84 c0                	test   %al,%al
 82d:	0f 85 94 fe ff ff    	jne    6c7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 833:	90                   	nop
 834:	c9                   	leave  
 835:	c3                   	ret    

00000836 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 836:	55                   	push   %ebp
 837:	89 e5                	mov    %esp,%ebp
 839:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83c:	8b 45 08             	mov    0x8(%ebp),%eax
 83f:	83 e8 08             	sub    $0x8,%eax
 842:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 845:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 84a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 84d:	eb 24                	jmp    873 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 852:	8b 00                	mov    (%eax),%eax
 854:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 857:	77 12                	ja     86b <free+0x35>
 859:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 85f:	77 24                	ja     885 <free+0x4f>
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 869:	77 1a                	ja     885 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	89 45 fc             	mov    %eax,-0x4(%ebp)
 873:	8b 45 f8             	mov    -0x8(%ebp),%eax
 876:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 879:	76 d4                	jbe    84f <free+0x19>
 87b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87e:	8b 00                	mov    (%eax),%eax
 880:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 883:	76 ca                	jbe    84f <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	8b 40 04             	mov    0x4(%eax),%eax
 88b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 892:	8b 45 f8             	mov    -0x8(%ebp),%eax
 895:	01 c2                	add    %eax,%edx
 897:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89a:	8b 00                	mov    (%eax),%eax
 89c:	39 c2                	cmp    %eax,%edx
 89e:	75 24                	jne    8c4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	8b 50 04             	mov    0x4(%eax),%edx
 8a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a9:	8b 00                	mov    (%eax),%eax
 8ab:	8b 40 04             	mov    0x4(%eax),%eax
 8ae:	01 c2                	add    %eax,%edx
 8b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	8b 00                	mov    (%eax),%eax
 8bb:	8b 10                	mov    (%eax),%edx
 8bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c0:	89 10                	mov    %edx,(%eax)
 8c2:	eb 0a                	jmp    8ce <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 10                	mov    (%eax),%edx
 8c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	8b 40 04             	mov    0x4(%eax),%eax
 8d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	01 d0                	add    %edx,%eax
 8e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e3:	75 20                	jne    905 <free+0xcf>
    p->s.size += bp->s.size;
 8e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e8:	8b 50 04             	mov    0x4(%eax),%edx
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	01 c2                	add    %eax,%edx
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fc:	8b 10                	mov    (%eax),%edx
 8fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 901:	89 10                	mov    %edx,(%eax)
 903:	eb 08                	jmp    90d <free+0xd7>
  } else
    p->s.ptr = bp;
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	8b 55 f8             	mov    -0x8(%ebp),%edx
 90b:	89 10                	mov    %edx,(%eax)
  freep = p;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	a3 b4 0d 00 00       	mov    %eax,0xdb4
}
 915:	90                   	nop
 916:	c9                   	leave  
 917:	c3                   	ret    

00000918 <morecore>:

static Header*
morecore(uint nu)
{
 918:	55                   	push   %ebp
 919:	89 e5                	mov    %esp,%ebp
 91b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 91e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 925:	77 07                	ja     92e <morecore+0x16>
    nu = 4096;
 927:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 92e:	8b 45 08             	mov    0x8(%ebp),%eax
 931:	c1 e0 03             	shl    $0x3,%eax
 934:	83 ec 0c             	sub    $0xc,%esp
 937:	50                   	push   %eax
 938:	e8 31 fc ff ff       	call   56e <sbrk>
 93d:	83 c4 10             	add    $0x10,%esp
 940:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 943:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 947:	75 07                	jne    950 <morecore+0x38>
    return 0;
 949:	b8 00 00 00 00       	mov    $0x0,%eax
 94e:	eb 26                	jmp    976 <morecore+0x5e>
  hp = (Header*)p;
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 956:	8b 45 f0             	mov    -0x10(%ebp),%eax
 959:	8b 55 08             	mov    0x8(%ebp),%edx
 95c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 95f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 962:	83 c0 08             	add    $0x8,%eax
 965:	83 ec 0c             	sub    $0xc,%esp
 968:	50                   	push   %eax
 969:	e8 c8 fe ff ff       	call   836 <free>
 96e:	83 c4 10             	add    $0x10,%esp
  return freep;
 971:	a1 b4 0d 00 00       	mov    0xdb4,%eax
}
 976:	c9                   	leave  
 977:	c3                   	ret    

00000978 <malloc>:

void*
malloc(uint nbytes)
{
 978:	55                   	push   %ebp
 979:	89 e5                	mov    %esp,%ebp
 97b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 97e:	8b 45 08             	mov    0x8(%ebp),%eax
 981:	83 c0 07             	add    $0x7,%eax
 984:	c1 e8 03             	shr    $0x3,%eax
 987:	83 c0 01             	add    $0x1,%eax
 98a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 98d:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 992:	89 45 f0             	mov    %eax,-0x10(%ebp)
 995:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 999:	75 23                	jne    9be <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 99b:	c7 45 f0 ac 0d 00 00 	movl   $0xdac,-0x10(%ebp)
 9a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a5:	a3 b4 0d 00 00       	mov    %eax,0xdb4
 9aa:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 9af:	a3 ac 0d 00 00       	mov    %eax,0xdac
    base.s.size = 0;
 9b4:	c7 05 b0 0d 00 00 00 	movl   $0x0,0xdb0
 9bb:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c1:	8b 00                	mov    (%eax),%eax
 9c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	8b 40 04             	mov    0x4(%eax),%eax
 9cc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9cf:	72 4d                	jb     a1e <malloc+0xa6>
      if(p->s.size == nunits)
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	8b 40 04             	mov    0x4(%eax),%eax
 9d7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9da:	75 0c                	jne    9e8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	8b 10                	mov    (%eax),%edx
 9e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e4:	89 10                	mov    %edx,(%eax)
 9e6:	eb 26                	jmp    a0e <malloc+0x96>
      else {
        p->s.size -= nunits;
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	8b 40 04             	mov    0x4(%eax),%eax
 9ee:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9f1:	89 c2                	mov    %eax,%edx
 9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fc:	8b 40 04             	mov    0x4(%eax),%eax
 9ff:	c1 e0 03             	shl    $0x3,%eax
 a02:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a08:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a0b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a11:	a3 b4 0d 00 00       	mov    %eax,0xdb4
      return (void*)(p + 1);
 a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a19:	83 c0 08             	add    $0x8,%eax
 a1c:	eb 3b                	jmp    a59 <malloc+0xe1>
    }
    if(p == freep)
 a1e:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 a23:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a26:	75 1e                	jne    a46 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a28:	83 ec 0c             	sub    $0xc,%esp
 a2b:	ff 75 ec             	pushl  -0x14(%ebp)
 a2e:	e8 e5 fe ff ff       	call   918 <morecore>
 a33:	83 c4 10             	add    $0x10,%esp
 a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a3d:	75 07                	jne    a46 <malloc+0xce>
        return 0;
 a3f:	b8 00 00 00 00       	mov    $0x0,%eax
 a44:	eb 13                	jmp    a59 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	8b 00                	mov    (%eax),%eax
 a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a54:	e9 6d ff ff ff       	jmp    9c6 <malloc+0x4e>
}
 a59:	c9                   	leave  
 a5a:	c3                   	ret    
