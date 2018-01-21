
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
   f:	83 ec 50             	sub    $0x50,%esp
  12:	89 cb                	mov    %ecx,%ebx
  char process[MAXPROC];

  strcpy(process, argv[1]);
  14:	8b 43 04             	mov    0x4(%ebx),%eax
  17:	83 c0 04             	add    $0x4,%eax
  1a:	8b 00                	mov    (%eax),%eax
  1c:	83 ec 08             	sub    $0x8,%esp
  1f:	50                   	push   %eax
  20:	8d 45 a8             	lea    -0x58(%ebp),%eax
  23:	50                   	push   %eax
  24:	e8 d8 00 00 00       	call   101 <strcpy>
  29:	83 c4 10             	add    $0x10,%esp

  printf(1, "%s%s\n",argv[1], " executing...");
  2c:	8b 43 04             	mov    0x4(%ebx),%eax
  2f:	83 c0 04             	add    $0x4,%eax
  32:	8b 00                	mov    (%eax),%eax
  34:	68 72 09 00 00       	push   $0x972
  39:	50                   	push   %eax
  3a:	68 80 09 00 00       	push   $0x980
  3f:	6a 01                	push   $0x1
  41:	e8 76 05 00 00       	call   5bc <printf>
  46:	83 c4 10             	add    $0x10,%esp
  
  int begin = uptime();
  49:	e8 4f 04 00 00       	call   49d <uptime>
  4e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //printf(1, "%s\t %d\n","Start time: ", begin);


  int pid = fork();
  51:	e8 a7 03 00 00       	call   3fd <fork>
  56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid > 0){
  59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5d:	7e 0a                	jle    69 <main+0x69>
      //printf(1, "parent: child=%d\n", pid);
      pid = wait();
  5f:	e8 a9 03 00 00       	call   40d <wait>
  64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  67:	eb 0b                	jmp    74 <main+0x74>
      //printf(1, "child %d is done\n", pid);
  }
  else if(pid ==0){
  69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  6d:	75 05                	jne    74 <main+0x74>
      //printf(1,"child: exiting\n");
      exit();
  6f:	e8 91 03 00 00       	call   405 <exit>
  }
      else{
	  //printf(1,"fork error\n");
      }

  exec("/bin/echo", argv);
  74:	83 ec 08             	sub    $0x8,%esp
  77:	ff 73 04             	pushl  0x4(%ebx)
  7a:	68 86 09 00 00       	push   $0x986
  7f:	e8 b9 03 00 00       	call   43d <exec>
  84:	83 c4 10             	add    $0x10,%esp
 //execute the program


  int end = uptime();
  87:	e8 11 04 00 00       	call   49d <uptime>
  8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  //printf(1, "%s\t %d\n","End time: ", end);

  int total = (end - begin)%1000;
  8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  92:	2b 45 f4             	sub    -0xc(%ebp),%eax
  95:	89 c1                	mov    %eax,%ecx
  97:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  9c:	89 c8                	mov    %ecx,%eax
  9e:	f7 ea                	imul   %edx
  a0:	c1 fa 06             	sar    $0x6,%edx
  a3:	89 c8                	mov    %ecx,%eax
  a5:	c1 f8 1f             	sar    $0x1f,%eax
  a8:	29 c2                	sub    %eax,%edx
  aa:	89 d0                	mov    %edx,%eax
  ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  af:	8b 45 e8             	mov    -0x18(%ebp),%eax
  b2:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  b8:	29 c1                	sub    %eax,%ecx
  ba:	89 c8                	mov    %ecx,%eax
  bc:	89 45 e8             	mov    %eax,-0x18(%ebp)

  
  printf(1, "%s%d\n\n","Total time: .", total);
  bf:	ff 75 e8             	pushl  -0x18(%ebp)
  c2:	68 90 09 00 00       	push   $0x990
  c7:	68 9e 09 00 00       	push   $0x99e
  cc:	6a 01                	push   $0x1
  ce:	e8 e9 04 00 00       	call   5bc <printf>
  d3:	83 c4 10             	add    $0x10,%esp
  exit();
  d6:	e8 2a 03 00 00       	call   405 <exit>

000000db <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  de:	57                   	push   %edi
  df:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  e3:	8b 55 10             	mov    0x10(%ebp),%edx
  e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  e9:	89 cb                	mov    %ecx,%ebx
  eb:	89 df                	mov    %ebx,%edi
  ed:	89 d1                	mov    %edx,%ecx
  ef:	fc                   	cld    
  f0:	f3 aa                	rep stos %al,%es:(%edi)
  f2:	89 ca                	mov    %ecx,%edx
  f4:	89 fb                	mov    %edi,%ebx
  f6:	89 5d 08             	mov    %ebx,0x8(%ebp)
  f9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  fc:	90                   	nop
  fd:	5b                   	pop    %ebx
  fe:	5f                   	pop    %edi
  ff:	5d                   	pop    %ebp
 100:	c3                   	ret    

00000101 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 101:	55                   	push   %ebp
 102:	89 e5                	mov    %esp,%ebp
 104:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 107:	8b 45 08             	mov    0x8(%ebp),%eax
 10a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 10d:	90                   	nop
 10e:	8b 45 08             	mov    0x8(%ebp),%eax
 111:	8d 50 01             	lea    0x1(%eax),%edx
 114:	89 55 08             	mov    %edx,0x8(%ebp)
 117:	8b 55 0c             	mov    0xc(%ebp),%edx
 11a:	8d 4a 01             	lea    0x1(%edx),%ecx
 11d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 120:	0f b6 12             	movzbl (%edx),%edx
 123:	88 10                	mov    %dl,(%eax)
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	84 c0                	test   %al,%al
 12a:	75 e2                	jne    10e <strcpy+0xd>
    ;
  return os;
 12c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12f:	c9                   	leave  
 130:	c3                   	ret    

00000131 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 134:	eb 08                	jmp    13e <strcmp+0xd>
    p++, q++;
 136:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 13e:	8b 45 08             	mov    0x8(%ebp),%eax
 141:	0f b6 00             	movzbl (%eax),%eax
 144:	84 c0                	test   %al,%al
 146:	74 10                	je     158 <strcmp+0x27>
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	0f b6 10             	movzbl (%eax),%edx
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	38 c2                	cmp    %al,%dl
 156:	74 de                	je     136 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 00             	movzbl (%eax),%eax
 15e:	0f b6 d0             	movzbl %al,%edx
 161:	8b 45 0c             	mov    0xc(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	0f b6 c0             	movzbl %al,%eax
 16a:	29 c2                	sub    %eax,%edx
 16c:	89 d0                	mov    %edx,%eax
}
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret    

00000170 <strlen>:

uint
strlen(char *s)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 176:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 17d:	eb 04                	jmp    183 <strlen+0x13>
 17f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 183:	8b 55 fc             	mov    -0x4(%ebp),%edx
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	01 d0                	add    %edx,%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	84 c0                	test   %al,%al
 190:	75 ed                	jne    17f <strlen+0xf>
    ;
  return n;
 192:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 195:	c9                   	leave  
 196:	c3                   	ret    

00000197 <memset>:

void*
memset(void *dst, int c, uint n)
{
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 19a:	8b 45 10             	mov    0x10(%ebp),%eax
 19d:	50                   	push   %eax
 19e:	ff 75 0c             	pushl  0xc(%ebp)
 1a1:	ff 75 08             	pushl  0x8(%ebp)
 1a4:	e8 32 ff ff ff       	call   db <stosb>
 1a9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1af:	c9                   	leave  
 1b0:	c3                   	ret    

000001b1 <strchr>:

char*
strchr(const char *s, char c)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 04             	sub    $0x4,%esp
 1b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ba:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1bd:	eb 14                	jmp    1d3 <strchr+0x22>
    if(*s == c)
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	0f b6 00             	movzbl (%eax),%eax
 1c5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1c8:	75 05                	jne    1cf <strchr+0x1e>
      return (char*)s;
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	eb 13                	jmp    1e2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	84 c0                	test   %al,%al
 1db:	75 e2                	jne    1bf <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <gets>:

char*
gets(char *buf, int max)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1f1:	eb 42                	jmp    235 <gets+0x51>
    cc = read(0, &c, 1);
 1f3:	83 ec 04             	sub    $0x4,%esp
 1f6:	6a 01                	push   $0x1
 1f8:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1fb:	50                   	push   %eax
 1fc:	6a 00                	push   $0x0
 1fe:	e8 1a 02 00 00       	call   41d <read>
 203:	83 c4 10             	add    $0x10,%esp
 206:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20d:	7e 33                	jle    242 <gets+0x5e>
      break;
    buf[i++] = c;
 20f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 212:	8d 50 01             	lea    0x1(%eax),%edx
 215:	89 55 f4             	mov    %edx,-0xc(%ebp)
 218:	89 c2                	mov    %eax,%edx
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	01 c2                	add    %eax,%edx
 21f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 223:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 225:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 229:	3c 0a                	cmp    $0xa,%al
 22b:	74 16                	je     243 <gets+0x5f>
 22d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 231:	3c 0d                	cmp    $0xd,%al
 233:	74 0e                	je     243 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	83 c0 01             	add    $0x1,%eax
 23b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 23e:	7c b3                	jl     1f3 <gets+0xf>
 240:	eb 01                	jmp    243 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 242:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 243:	8b 55 f4             	mov    -0xc(%ebp),%edx
 246:	8b 45 08             	mov    0x8(%ebp),%eax
 249:	01 d0                	add    %edx,%eax
 24b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 251:	c9                   	leave  
 252:	c3                   	ret    

00000253 <stat>:

int
stat(char *n, struct stat *st)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 259:	83 ec 08             	sub    $0x8,%esp
 25c:	6a 00                	push   $0x0
 25e:	ff 75 08             	pushl  0x8(%ebp)
 261:	e8 df 01 00 00       	call   445 <open>
 266:	83 c4 10             	add    $0x10,%esp
 269:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 26c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 270:	79 07                	jns    279 <stat+0x26>
    return -1;
 272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 277:	eb 25                	jmp    29e <stat+0x4b>
  r = fstat(fd, st);
 279:	83 ec 08             	sub    $0x8,%esp
 27c:	ff 75 0c             	pushl  0xc(%ebp)
 27f:	ff 75 f4             	pushl  -0xc(%ebp)
 282:	e8 d6 01 00 00       	call   45d <fstat>
 287:	83 c4 10             	add    $0x10,%esp
 28a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 28d:	83 ec 0c             	sub    $0xc,%esp
 290:	ff 75 f4             	pushl  -0xc(%ebp)
 293:	e8 95 01 00 00       	call   42d <close>
 298:	83 c4 10             	add    $0x10,%esp
  return r;
 29b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2ad:	eb 04                	jmp    2b3 <atoi+0x13>
 2af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	0f b6 00             	movzbl (%eax),%eax
 2b9:	3c 20                	cmp    $0x20,%al
 2bb:	74 f2                	je     2af <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	0f b6 00             	movzbl (%eax),%eax
 2c3:	3c 2d                	cmp    $0x2d,%al
 2c5:	75 07                	jne    2ce <atoi+0x2e>
 2c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cc:	eb 05                	jmp    2d3 <atoi+0x33>
 2ce:	b8 01 00 00 00       	mov    $0x1,%eax
 2d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	0f b6 00             	movzbl (%eax),%eax
 2dc:	3c 2b                	cmp    $0x2b,%al
 2de:	74 0a                	je     2ea <atoi+0x4a>
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	0f b6 00             	movzbl (%eax),%eax
 2e6:	3c 2d                	cmp    $0x2d,%al
 2e8:	75 2b                	jne    315 <atoi+0x75>
    s++;
 2ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 2ee:	eb 25                	jmp    315 <atoi+0x75>
    n = n*10 + *s++ - '0';
 2f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f3:	89 d0                	mov    %edx,%eax
 2f5:	c1 e0 02             	shl    $0x2,%eax
 2f8:	01 d0                	add    %edx,%eax
 2fa:	01 c0                	add    %eax,%eax
 2fc:	89 c1                	mov    %eax,%ecx
 2fe:	8b 45 08             	mov    0x8(%ebp),%eax
 301:	8d 50 01             	lea    0x1(%eax),%edx
 304:	89 55 08             	mov    %edx,0x8(%ebp)
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	0f be c0             	movsbl %al,%eax
 30d:	01 c8                	add    %ecx,%eax
 30f:	83 e8 30             	sub    $0x30,%eax
 312:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	0f b6 00             	movzbl (%eax),%eax
 31b:	3c 2f                	cmp    $0x2f,%al
 31d:	7e 0a                	jle    329 <atoi+0x89>
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	3c 39                	cmp    $0x39,%al
 327:	7e c7                	jle    2f0 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 329:	8b 45 f8             	mov    -0x8(%ebp),%eax
 32c:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <atoo>:

int
atoo(const char *s)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 338:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 33f:	eb 04                	jmp    345 <atoo+0x13>
 341:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	3c 20                	cmp    $0x20,%al
 34d:	74 f2                	je     341 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	0f b6 00             	movzbl (%eax),%eax
 355:	3c 2d                	cmp    $0x2d,%al
 357:	75 07                	jne    360 <atoo+0x2e>
 359:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 35e:	eb 05                	jmp    365 <atoo+0x33>
 360:	b8 01 00 00 00       	mov    $0x1,%eax
 365:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	0f b6 00             	movzbl (%eax),%eax
 36e:	3c 2b                	cmp    $0x2b,%al
 370:	74 0a                	je     37c <atoo+0x4a>
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	0f b6 00             	movzbl (%eax),%eax
 378:	3c 2d                	cmp    $0x2d,%al
 37a:	75 27                	jne    3a3 <atoo+0x71>
    s++;
 37c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 380:	eb 21                	jmp    3a3 <atoo+0x71>
    n = n*8 + *s++ - '0';
 382:	8b 45 fc             	mov    -0x4(%ebp),%eax
 385:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	8d 50 01             	lea    0x1(%eax),%edx
 392:	89 55 08             	mov    %edx,0x8(%ebp)
 395:	0f b6 00             	movzbl (%eax),%eax
 398:	0f be c0             	movsbl %al,%eax
 39b:	01 c8                	add    %ecx,%eax
 39d:	83 e8 30             	sub    $0x30,%eax
 3a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 3a3:	8b 45 08             	mov    0x8(%ebp),%eax
 3a6:	0f b6 00             	movzbl (%eax),%eax
 3a9:	3c 2f                	cmp    $0x2f,%al
 3ab:	7e 0a                	jle    3b7 <atoo+0x85>
 3ad:	8b 45 08             	mov    0x8(%ebp),%eax
 3b0:	0f b6 00             	movzbl (%eax),%eax
 3b3:	3c 37                	cmp    $0x37,%al
 3b5:	7e cb                	jle    382 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3ba:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3be:	c9                   	leave  
 3bf:	c3                   	ret    

000003c0 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 3c0:	55                   	push   %ebp
 3c1:	89 e5                	mov    %esp,%ebp
 3c3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3d2:	eb 17                	jmp    3eb <memmove+0x2b>
    *dst++ = *src++;
 3d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3d7:	8d 50 01             	lea    0x1(%eax),%edx
 3da:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3e0:	8d 4a 01             	lea    0x1(%edx),%ecx
 3e3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3e6:	0f b6 12             	movzbl (%edx),%edx
 3e9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3eb:	8b 45 10             	mov    0x10(%ebp),%eax
 3ee:	8d 50 ff             	lea    -0x1(%eax),%edx
 3f1:	89 55 10             	mov    %edx,0x10(%ebp)
 3f4:	85 c0                	test   %eax,%eax
 3f6:	7f dc                	jg     3d4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3fb:	c9                   	leave  
 3fc:	c3                   	ret    

000003fd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3fd:	b8 01 00 00 00       	mov    $0x1,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <exit>:
SYSCALL(exit)
 405:	b8 02 00 00 00       	mov    $0x2,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <wait>:
SYSCALL(wait)
 40d:	b8 03 00 00 00       	mov    $0x3,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <pipe>:
SYSCALL(pipe)
 415:	b8 04 00 00 00       	mov    $0x4,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <read>:
SYSCALL(read)
 41d:	b8 05 00 00 00       	mov    $0x5,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <write>:
SYSCALL(write)
 425:	b8 10 00 00 00       	mov    $0x10,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <close>:
SYSCALL(close)
 42d:	b8 15 00 00 00       	mov    $0x15,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <kill>:
SYSCALL(kill)
 435:	b8 06 00 00 00       	mov    $0x6,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <exec>:
SYSCALL(exec)
 43d:	b8 07 00 00 00       	mov    $0x7,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <open>:
SYSCALL(open)
 445:	b8 0f 00 00 00       	mov    $0xf,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <mknod>:
SYSCALL(mknod)
 44d:	b8 11 00 00 00       	mov    $0x11,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <unlink>:
SYSCALL(unlink)
 455:	b8 12 00 00 00       	mov    $0x12,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <fstat>:
SYSCALL(fstat)
 45d:	b8 08 00 00 00       	mov    $0x8,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <link>:
SYSCALL(link)
 465:	b8 13 00 00 00       	mov    $0x13,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <mkdir>:
SYSCALL(mkdir)
 46d:	b8 14 00 00 00       	mov    $0x14,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <chdir>:
SYSCALL(chdir)
 475:	b8 09 00 00 00       	mov    $0x9,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <dup>:
SYSCALL(dup)
 47d:	b8 0a 00 00 00       	mov    $0xa,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <getpid>:
SYSCALL(getpid)
 485:	b8 0b 00 00 00       	mov    $0xb,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <sbrk>:
SYSCALL(sbrk)
 48d:	b8 0c 00 00 00       	mov    $0xc,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <sleep>:
SYSCALL(sleep)
 495:	b8 0d 00 00 00       	mov    $0xd,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <uptime>:
SYSCALL(uptime)
 49d:	b8 0e 00 00 00       	mov    $0xe,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <halt>:
SYSCALL(halt)
 4a5:	b8 16 00 00 00       	mov    $0x16,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <date>:
SYSCALL(date)
 4ad:	b8 17 00 00 00       	mov    $0x17,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <getuid>:
SYSCALL(getuid)
 4b5:	b8 18 00 00 00       	mov    $0x18,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <getgid>:
SYSCALL(getgid)
 4bd:	b8 19 00 00 00       	mov    $0x19,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <getppid>:
SYSCALL(getppid)
 4c5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <setuid>:
SYSCALL(setuid)
 4cd:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <setgid>:
SYSCALL(setgid)
 4d5:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <getprocs>:
SYSCALL(getprocs)
 4dd:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4e5:	55                   	push   %ebp
 4e6:	89 e5                	mov    %esp,%ebp
 4e8:	83 ec 18             	sub    $0x18,%esp
 4eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ee:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4f1:	83 ec 04             	sub    $0x4,%esp
 4f4:	6a 01                	push   $0x1
 4f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4f9:	50                   	push   %eax
 4fa:	ff 75 08             	pushl  0x8(%ebp)
 4fd:	e8 23 ff ff ff       	call   425 <write>
 502:	83 c4 10             	add    $0x10,%esp
}
 505:	90                   	nop
 506:	c9                   	leave  
 507:	c3                   	ret    

00000508 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 508:	55                   	push   %ebp
 509:	89 e5                	mov    %esp,%ebp
 50b:	53                   	push   %ebx
 50c:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 50f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 516:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 51a:	74 17                	je     533 <printint+0x2b>
 51c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 520:	79 11                	jns    533 <printint+0x2b>
    neg = 1;
 522:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 529:	8b 45 0c             	mov    0xc(%ebp),%eax
 52c:	f7 d8                	neg    %eax
 52e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 531:	eb 06                	jmp    539 <printint+0x31>
  } else {
    x = xx;
 533:	8b 45 0c             	mov    0xc(%ebp),%eax
 536:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 539:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 540:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 543:	8d 41 01             	lea    0x1(%ecx),%eax
 546:	89 45 f4             	mov    %eax,-0xc(%ebp)
 549:	8b 5d 10             	mov    0x10(%ebp),%ebx
 54c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 54f:	ba 00 00 00 00       	mov    $0x0,%edx
 554:	f7 f3                	div    %ebx
 556:	89 d0                	mov    %edx,%eax
 558:	0f b6 80 18 0c 00 00 	movzbl 0xc18(%eax),%eax
 55f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 563:	8b 5d 10             	mov    0x10(%ebp),%ebx
 566:	8b 45 ec             	mov    -0x14(%ebp),%eax
 569:	ba 00 00 00 00       	mov    $0x0,%edx
 56e:	f7 f3                	div    %ebx
 570:	89 45 ec             	mov    %eax,-0x14(%ebp)
 573:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 577:	75 c7                	jne    540 <printint+0x38>
  if(neg)
 579:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 57d:	74 2d                	je     5ac <printint+0xa4>
    buf[i++] = '-';
 57f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 582:	8d 50 01             	lea    0x1(%eax),%edx
 585:	89 55 f4             	mov    %edx,-0xc(%ebp)
 588:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 58d:	eb 1d                	jmp    5ac <printint+0xa4>
    putc(fd, buf[i]);
 58f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 592:	8b 45 f4             	mov    -0xc(%ebp),%eax
 595:	01 d0                	add    %edx,%eax
 597:	0f b6 00             	movzbl (%eax),%eax
 59a:	0f be c0             	movsbl %al,%eax
 59d:	83 ec 08             	sub    $0x8,%esp
 5a0:	50                   	push   %eax
 5a1:	ff 75 08             	pushl  0x8(%ebp)
 5a4:	e8 3c ff ff ff       	call   4e5 <putc>
 5a9:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5ac:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5b4:	79 d9                	jns    58f <printint+0x87>
    putc(fd, buf[i]);
}
 5b6:	90                   	nop
 5b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5ba:	c9                   	leave  
 5bb:	c3                   	ret    

000005bc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5c9:	8d 45 0c             	lea    0xc(%ebp),%eax
 5cc:	83 c0 04             	add    $0x4,%eax
 5cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5d9:	e9 59 01 00 00       	jmp    737 <printf+0x17b>
    c = fmt[i] & 0xff;
 5de:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e4:	01 d0                	add    %edx,%eax
 5e6:	0f b6 00             	movzbl (%eax),%eax
 5e9:	0f be c0             	movsbl %al,%eax
 5ec:	25 ff 00 00 00       	and    $0xff,%eax
 5f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f8:	75 2c                	jne    626 <printf+0x6a>
      if(c == '%'){
 5fa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5fe:	75 0c                	jne    60c <printf+0x50>
        state = '%';
 600:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 607:	e9 27 01 00 00       	jmp    733 <printf+0x177>
      } else {
        putc(fd, c);
 60c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60f:	0f be c0             	movsbl %al,%eax
 612:	83 ec 08             	sub    $0x8,%esp
 615:	50                   	push   %eax
 616:	ff 75 08             	pushl  0x8(%ebp)
 619:	e8 c7 fe ff ff       	call   4e5 <putc>
 61e:	83 c4 10             	add    $0x10,%esp
 621:	e9 0d 01 00 00       	jmp    733 <printf+0x177>
      }
    } else if(state == '%'){
 626:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 62a:	0f 85 03 01 00 00    	jne    733 <printf+0x177>
      if(c == 'd'){
 630:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 634:	75 1e                	jne    654 <printf+0x98>
        printint(fd, *ap, 10, 1);
 636:	8b 45 e8             	mov    -0x18(%ebp),%eax
 639:	8b 00                	mov    (%eax),%eax
 63b:	6a 01                	push   $0x1
 63d:	6a 0a                	push   $0xa
 63f:	50                   	push   %eax
 640:	ff 75 08             	pushl  0x8(%ebp)
 643:	e8 c0 fe ff ff       	call   508 <printint>
 648:	83 c4 10             	add    $0x10,%esp
        ap++;
 64b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64f:	e9 d8 00 00 00       	jmp    72c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 654:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 658:	74 06                	je     660 <printf+0xa4>
 65a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 65e:	75 1e                	jne    67e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 660:	8b 45 e8             	mov    -0x18(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	6a 00                	push   $0x0
 667:	6a 10                	push   $0x10
 669:	50                   	push   %eax
 66a:	ff 75 08             	pushl  0x8(%ebp)
 66d:	e8 96 fe ff ff       	call   508 <printint>
 672:	83 c4 10             	add    $0x10,%esp
        ap++;
 675:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 679:	e9 ae 00 00 00       	jmp    72c <printf+0x170>
      } else if(c == 's'){
 67e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 682:	75 43                	jne    6c7 <printf+0x10b>
        s = (char*)*ap;
 684:	8b 45 e8             	mov    -0x18(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 68c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 690:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 694:	75 25                	jne    6bb <printf+0xff>
          s = "(null)";
 696:	c7 45 f4 a5 09 00 00 	movl   $0x9a5,-0xc(%ebp)
        while(*s != 0){
 69d:	eb 1c                	jmp    6bb <printf+0xff>
          putc(fd, *s);
 69f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a2:	0f b6 00             	movzbl (%eax),%eax
 6a5:	0f be c0             	movsbl %al,%eax
 6a8:	83 ec 08             	sub    $0x8,%esp
 6ab:	50                   	push   %eax
 6ac:	ff 75 08             	pushl  0x8(%ebp)
 6af:	e8 31 fe ff ff       	call   4e5 <putc>
 6b4:	83 c4 10             	add    $0x10,%esp
          s++;
 6b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6be:	0f b6 00             	movzbl (%eax),%eax
 6c1:	84 c0                	test   %al,%al
 6c3:	75 da                	jne    69f <printf+0xe3>
 6c5:	eb 65                	jmp    72c <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6c7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6cb:	75 1d                	jne    6ea <printf+0x12e>
        putc(fd, *ap);
 6cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	0f be c0             	movsbl %al,%eax
 6d5:	83 ec 08             	sub    $0x8,%esp
 6d8:	50                   	push   %eax
 6d9:	ff 75 08             	pushl  0x8(%ebp)
 6dc:	e8 04 fe ff ff       	call   4e5 <putc>
 6e1:	83 c4 10             	add    $0x10,%esp
        ap++;
 6e4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e8:	eb 42                	jmp    72c <printf+0x170>
      } else if(c == '%'){
 6ea:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ee:	75 17                	jne    707 <printf+0x14b>
        putc(fd, c);
 6f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6f3:	0f be c0             	movsbl %al,%eax
 6f6:	83 ec 08             	sub    $0x8,%esp
 6f9:	50                   	push   %eax
 6fa:	ff 75 08             	pushl  0x8(%ebp)
 6fd:	e8 e3 fd ff ff       	call   4e5 <putc>
 702:	83 c4 10             	add    $0x10,%esp
 705:	eb 25                	jmp    72c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 707:	83 ec 08             	sub    $0x8,%esp
 70a:	6a 25                	push   $0x25
 70c:	ff 75 08             	pushl  0x8(%ebp)
 70f:	e8 d1 fd ff ff       	call   4e5 <putc>
 714:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71a:	0f be c0             	movsbl %al,%eax
 71d:	83 ec 08             	sub    $0x8,%esp
 720:	50                   	push   %eax
 721:	ff 75 08             	pushl  0x8(%ebp)
 724:	e8 bc fd ff ff       	call   4e5 <putc>
 729:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 72c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 733:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 737:	8b 55 0c             	mov    0xc(%ebp),%edx
 73a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73d:	01 d0                	add    %edx,%eax
 73f:	0f b6 00             	movzbl (%eax),%eax
 742:	84 c0                	test   %al,%al
 744:	0f 85 94 fe ff ff    	jne    5de <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 74a:	90                   	nop
 74b:	c9                   	leave  
 74c:	c3                   	ret    

0000074d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74d:	55                   	push   %ebp
 74e:	89 e5                	mov    %esp,%ebp
 750:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 753:	8b 45 08             	mov    0x8(%ebp),%eax
 756:	83 e8 08             	sub    $0x8,%eax
 759:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	a1 34 0c 00 00       	mov    0xc34,%eax
 761:	89 45 fc             	mov    %eax,-0x4(%ebp)
 764:	eb 24                	jmp    78a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	8b 00                	mov    (%eax),%eax
 76b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76e:	77 12                	ja     782 <free+0x35>
 770:	8b 45 f8             	mov    -0x8(%ebp),%eax
 773:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 776:	77 24                	ja     79c <free+0x4f>
 778:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77b:	8b 00                	mov    (%eax),%eax
 77d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 780:	77 1a                	ja     79c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	89 45 fc             	mov    %eax,-0x4(%ebp)
 78a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 790:	76 d4                	jbe    766 <free+0x19>
 792:	8b 45 fc             	mov    -0x4(%ebp),%eax
 795:	8b 00                	mov    (%eax),%eax
 797:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 79a:	76 ca                	jbe    766 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 79c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79f:	8b 40 04             	mov    0x4(%eax),%eax
 7a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ac:	01 c2                	add    %eax,%edx
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	39 c2                	cmp    %eax,%edx
 7b5:	75 24                	jne    7db <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	8b 50 04             	mov    0x4(%eax),%edx
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	8b 40 04             	mov    0x4(%eax),%eax
 7c5:	01 c2                	add    %eax,%edx
 7c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ca:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	8b 10                	mov    (%eax),%edx
 7d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d7:	89 10                	mov    %edx,(%eax)
 7d9:	eb 0a                	jmp    7e5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7de:	8b 10                	mov    (%eax),%edx
 7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f5:	01 d0                	add    %edx,%eax
 7f7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7fa:	75 20                	jne    81c <free+0xcf>
    p->s.size += bp->s.size;
 7fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ff:	8b 50 04             	mov    0x4(%eax),%edx
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	8b 40 04             	mov    0x4(%eax),%eax
 808:	01 c2                	add    %eax,%edx
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 810:	8b 45 f8             	mov    -0x8(%ebp),%eax
 813:	8b 10                	mov    (%eax),%edx
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	89 10                	mov    %edx,(%eax)
 81a:	eb 08                	jmp    824 <free+0xd7>
  } else
    p->s.ptr = bp;
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 822:	89 10                	mov    %edx,(%eax)
  freep = p;
 824:	8b 45 fc             	mov    -0x4(%ebp),%eax
 827:	a3 34 0c 00 00       	mov    %eax,0xc34
}
 82c:	90                   	nop
 82d:	c9                   	leave  
 82e:	c3                   	ret    

0000082f <morecore>:

static Header*
morecore(uint nu)
{
 82f:	55                   	push   %ebp
 830:	89 e5                	mov    %esp,%ebp
 832:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 835:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 83c:	77 07                	ja     845 <morecore+0x16>
    nu = 4096;
 83e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 845:	8b 45 08             	mov    0x8(%ebp),%eax
 848:	c1 e0 03             	shl    $0x3,%eax
 84b:	83 ec 0c             	sub    $0xc,%esp
 84e:	50                   	push   %eax
 84f:	e8 39 fc ff ff       	call   48d <sbrk>
 854:	83 c4 10             	add    $0x10,%esp
 857:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 85a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 85e:	75 07                	jne    867 <morecore+0x38>
    return 0;
 860:	b8 00 00 00 00       	mov    $0x0,%eax
 865:	eb 26                	jmp    88d <morecore+0x5e>
  hp = (Header*)p;
 867:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	8b 55 08             	mov    0x8(%ebp),%edx
 873:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 876:	8b 45 f0             	mov    -0x10(%ebp),%eax
 879:	83 c0 08             	add    $0x8,%eax
 87c:	83 ec 0c             	sub    $0xc,%esp
 87f:	50                   	push   %eax
 880:	e8 c8 fe ff ff       	call   74d <free>
 885:	83 c4 10             	add    $0x10,%esp
  return freep;
 888:	a1 34 0c 00 00       	mov    0xc34,%eax
}
 88d:	c9                   	leave  
 88e:	c3                   	ret    

0000088f <malloc>:

void*
malloc(uint nbytes)
{
 88f:	55                   	push   %ebp
 890:	89 e5                	mov    %esp,%ebp
 892:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 895:	8b 45 08             	mov    0x8(%ebp),%eax
 898:	83 c0 07             	add    $0x7,%eax
 89b:	c1 e8 03             	shr    $0x3,%eax
 89e:	83 c0 01             	add    $0x1,%eax
 8a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8a4:	a1 34 0c 00 00       	mov    0xc34,%eax
 8a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8b0:	75 23                	jne    8d5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8b2:	c7 45 f0 2c 0c 00 00 	movl   $0xc2c,-0x10(%ebp)
 8b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bc:	a3 34 0c 00 00       	mov    %eax,0xc34
 8c1:	a1 34 0c 00 00       	mov    0xc34,%eax
 8c6:	a3 2c 0c 00 00       	mov    %eax,0xc2c
    base.s.size = 0;
 8cb:	c7 05 30 0c 00 00 00 	movl   $0x0,0xc30
 8d2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e0:	8b 40 04             	mov    0x4(%eax),%eax
 8e3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8e6:	72 4d                	jb     935 <malloc+0xa6>
      if(p->s.size == nunits)
 8e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8eb:	8b 40 04             	mov    0x4(%eax),%eax
 8ee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f1:	75 0c                	jne    8ff <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f6:	8b 10                	mov    (%eax),%edx
 8f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fb:	89 10                	mov    %edx,(%eax)
 8fd:	eb 26                	jmp    925 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 902:	8b 40 04             	mov    0x4(%eax),%eax
 905:	2b 45 ec             	sub    -0x14(%ebp),%eax
 908:	89 c2                	mov    %eax,%edx
 90a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 910:	8b 45 f4             	mov    -0xc(%ebp),%eax
 913:	8b 40 04             	mov    0x4(%eax),%eax
 916:	c1 e0 03             	shl    $0x3,%eax
 919:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 91c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 922:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 925:	8b 45 f0             	mov    -0x10(%ebp),%eax
 928:	a3 34 0c 00 00       	mov    %eax,0xc34
      return (void*)(p + 1);
 92d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 930:	83 c0 08             	add    $0x8,%eax
 933:	eb 3b                	jmp    970 <malloc+0xe1>
    }
    if(p == freep)
 935:	a1 34 0c 00 00       	mov    0xc34,%eax
 93a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 93d:	75 1e                	jne    95d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 93f:	83 ec 0c             	sub    $0xc,%esp
 942:	ff 75 ec             	pushl  -0x14(%ebp)
 945:	e8 e5 fe ff ff       	call   82f <morecore>
 94a:	83 c4 10             	add    $0x10,%esp
 94d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 950:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 954:	75 07                	jne    95d <malloc+0xce>
        return 0;
 956:	b8 00 00 00 00       	mov    $0x0,%eax
 95b:	eb 13                	jmp    970 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	89 45 f0             	mov    %eax,-0x10(%ebp)
 963:	8b 45 f4             	mov    -0xc(%ebp),%eax
 966:	8b 00                	mov    (%eax),%eax
 968:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 96b:	e9 6d ff ff ff       	jmp    8dd <malloc+0x4e>
}
 970:	c9                   	leave  
 971:	c3                   	ret    
