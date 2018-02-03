
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
  3b:	68 54 0a 00 00       	push   $0xa54
  40:	6a 01                	push   $0x1
  42:	e8 56 06 00 00       	call   69d <printf>
  47:	83 c4 10             	add    $0x10,%esp
      strcpy(process, "time");
  4a:	83 ec 08             	sub    $0x8,%esp
  4d:	68 83 0a 00 00       	push   $0xa83
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
  aa:	68 88 0a 00 00       	push   $0xa88
  af:	6a 01                	push   $0x1
  b1:	e8 e7 05 00 00       	call   69d <printf>
  b6:	83 c4 10             	add    $0x10,%esp
	      exit();
  b9:	e8 28 04 00 00       	call   4e6 <exit>
	  }
      }

      else
	  printf(1,"fork error\n");
  be:	83 ec 08             	sub    $0x8,%esp
  c1:	68 a3 0a 00 00       	push   $0xaa3
  c6:	6a 01                	push   $0x1
  c8:	e8 d0 05 00 00       	call   69d <printf>
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
 128:	68 af 0a 00 00       	push   $0xaaf
 12d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 130:	50                   	push   %eax
 131:	68 bd 0a 00 00       	push   $0xabd
 136:	6a 01                	push   $0x1
 138:	e8 60 05 00 00       	call   69d <printf>
 13d:	83 c4 10             	add    $0x10,%esp
      
      if(milli < 10)
 140:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
 144:	7f 21                	jg     167 <main+0x167>
      printf(1, "%s ran in %d.00%d seconds\n\n",process, total, milli, " seconds");
 146:	83 ec 08             	sub    $0x8,%esp
 149:	68 c3 0a 00 00       	push   $0xac3
 14e:	ff 75 e4             	pushl  -0x1c(%ebp)
 151:	ff 75 e8             	pushl  -0x18(%ebp)
 154:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 157:	50                   	push   %eax
 158:	68 cc 0a 00 00       	push   $0xacc
 15d:	6a 01                	push   $0x1
 15f:	e8 39 05 00 00       	call   69d <printf>
 164:	83 c4 20             	add    $0x20,%esp
      
      if(milli > 9 && milli < 100)
 167:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
 16b:	7e 29                	jle    196 <main+0x196>
 16d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 171:	7f 23                	jg     196 <main+0x196>
      printf(1, "%s ran in %d.0%d seconds\n\n",process, total, milli, " seconds");
 173:	83 ec 08             	sub    $0x8,%esp
 176:	68 c3 0a 00 00       	push   $0xac3
 17b:	ff 75 e4             	pushl  -0x1c(%ebp)
 17e:	ff 75 e8             	pushl  -0x18(%ebp)
 181:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 184:	50                   	push   %eax
 185:	68 e8 0a 00 00       	push   $0xae8
 18a:	6a 01                	push   $0x1
 18c:	e8 0c 05 00 00       	call   69d <printf>
 191:	83 c4 20             	add    $0x20,%esp
 194:	eb 21                	jmp    1b7 <main+0x1b7>
      
      else
      printf(1, "%s ran in %d.%d seconds\n\n",process, total, milli, " seconds");
 196:	83 ec 08             	sub    $0x8,%esp
 199:	68 c3 0a 00 00       	push   $0xac3
 19e:	ff 75 e4             	pushl  -0x1c(%ebp)
 1a1:	ff 75 e8             	pushl  -0x18(%ebp)
 1a4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 1a7:	50                   	push   %eax
 1a8:	68 03 0b 00 00       	push   $0xb03
 1ad:	6a 01                	push   $0x1
 1af:	e8 e9 04 00 00       	call   69d <printf>
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

000005c6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c6:	55                   	push   %ebp
 5c7:	89 e5                	mov    %esp,%ebp
 5c9:	83 ec 18             	sub    $0x18,%esp
 5cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cf:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5d2:	83 ec 04             	sub    $0x4,%esp
 5d5:	6a 01                	push   $0x1
 5d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5da:	50                   	push   %eax
 5db:	ff 75 08             	pushl  0x8(%ebp)
 5de:	e8 23 ff ff ff       	call   506 <write>
 5e3:	83 c4 10             	add    $0x10,%esp
}
 5e6:	90                   	nop
 5e7:	c9                   	leave  
 5e8:	c3                   	ret    

000005e9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e9:	55                   	push   %ebp
 5ea:	89 e5                	mov    %esp,%ebp
 5ec:	53                   	push   %ebx
 5ed:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5f7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5fb:	74 17                	je     614 <printint+0x2b>
 5fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 601:	79 11                	jns    614 <printint+0x2b>
    neg = 1;
 603:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 60a:	8b 45 0c             	mov    0xc(%ebp),%eax
 60d:	f7 d8                	neg    %eax
 60f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 612:	eb 06                	jmp    61a <printint+0x31>
  } else {
    x = xx;
 614:	8b 45 0c             	mov    0xc(%ebp),%eax
 617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 61a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 621:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 624:	8d 41 01             	lea    0x1(%ecx),%eax
 627:	89 45 f4             	mov    %eax,-0xc(%ebp)
 62a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 62d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 630:	ba 00 00 00 00       	mov    $0x0,%edx
 635:	f7 f3                	div    %ebx
 637:	89 d0                	mov    %edx,%eax
 639:	0f b6 80 90 0d 00 00 	movzbl 0xd90(%eax),%eax
 640:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 644:	8b 5d 10             	mov    0x10(%ebp),%ebx
 647:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64a:	ba 00 00 00 00       	mov    $0x0,%edx
 64f:	f7 f3                	div    %ebx
 651:	89 45 ec             	mov    %eax,-0x14(%ebp)
 654:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 658:	75 c7                	jne    621 <printint+0x38>
  if(neg)
 65a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 65e:	74 2d                	je     68d <printint+0xa4>
    buf[i++] = '-';
 660:	8b 45 f4             	mov    -0xc(%ebp),%eax
 663:	8d 50 01             	lea    0x1(%eax),%edx
 666:	89 55 f4             	mov    %edx,-0xc(%ebp)
 669:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 66e:	eb 1d                	jmp    68d <printint+0xa4>
    putc(fd, buf[i]);
 670:	8d 55 dc             	lea    -0x24(%ebp),%edx
 673:	8b 45 f4             	mov    -0xc(%ebp),%eax
 676:	01 d0                	add    %edx,%eax
 678:	0f b6 00             	movzbl (%eax),%eax
 67b:	0f be c0             	movsbl %al,%eax
 67e:	83 ec 08             	sub    $0x8,%esp
 681:	50                   	push   %eax
 682:	ff 75 08             	pushl  0x8(%ebp)
 685:	e8 3c ff ff ff       	call   5c6 <putc>
 68a:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 68d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 691:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 695:	79 d9                	jns    670 <printint+0x87>
    putc(fd, buf[i]);
}
 697:	90                   	nop
 698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 69b:	c9                   	leave  
 69c:	c3                   	ret    

0000069d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 69d:	55                   	push   %ebp
 69e:	89 e5                	mov    %esp,%ebp
 6a0:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6a3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6aa:	8d 45 0c             	lea    0xc(%ebp),%eax
 6ad:	83 c0 04             	add    $0x4,%eax
 6b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ba:	e9 59 01 00 00       	jmp    818 <printf+0x17b>
    c = fmt[i] & 0xff;
 6bf:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c5:	01 d0                	add    %edx,%eax
 6c7:	0f b6 00             	movzbl (%eax),%eax
 6ca:	0f be c0             	movsbl %al,%eax
 6cd:	25 ff 00 00 00       	and    $0xff,%eax
 6d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d9:	75 2c                	jne    707 <printf+0x6a>
      if(c == '%'){
 6db:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6df:	75 0c                	jne    6ed <printf+0x50>
        state = '%';
 6e1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6e8:	e9 27 01 00 00       	jmp    814 <printf+0x177>
      } else {
        putc(fd, c);
 6ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6f0:	0f be c0             	movsbl %al,%eax
 6f3:	83 ec 08             	sub    $0x8,%esp
 6f6:	50                   	push   %eax
 6f7:	ff 75 08             	pushl  0x8(%ebp)
 6fa:	e8 c7 fe ff ff       	call   5c6 <putc>
 6ff:	83 c4 10             	add    $0x10,%esp
 702:	e9 0d 01 00 00       	jmp    814 <printf+0x177>
      }
    } else if(state == '%'){
 707:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 70b:	0f 85 03 01 00 00    	jne    814 <printf+0x177>
      if(c == 'd'){
 711:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 715:	75 1e                	jne    735 <printf+0x98>
        printint(fd, *ap, 10, 1);
 717:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71a:	8b 00                	mov    (%eax),%eax
 71c:	6a 01                	push   $0x1
 71e:	6a 0a                	push   $0xa
 720:	50                   	push   %eax
 721:	ff 75 08             	pushl  0x8(%ebp)
 724:	e8 c0 fe ff ff       	call   5e9 <printint>
 729:	83 c4 10             	add    $0x10,%esp
        ap++;
 72c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 730:	e9 d8 00 00 00       	jmp    80d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 735:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 739:	74 06                	je     741 <printf+0xa4>
 73b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 73f:	75 1e                	jne    75f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 741:	8b 45 e8             	mov    -0x18(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	6a 00                	push   $0x0
 748:	6a 10                	push   $0x10
 74a:	50                   	push   %eax
 74b:	ff 75 08             	pushl  0x8(%ebp)
 74e:	e8 96 fe ff ff       	call   5e9 <printint>
 753:	83 c4 10             	add    $0x10,%esp
        ap++;
 756:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 75a:	e9 ae 00 00 00       	jmp    80d <printf+0x170>
      } else if(c == 's'){
 75f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 763:	75 43                	jne    7a8 <printf+0x10b>
        s = (char*)*ap;
 765:	8b 45 e8             	mov    -0x18(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 76d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 775:	75 25                	jne    79c <printf+0xff>
          s = "(null)";
 777:	c7 45 f4 1d 0b 00 00 	movl   $0xb1d,-0xc(%ebp)
        while(*s != 0){
 77e:	eb 1c                	jmp    79c <printf+0xff>
          putc(fd, *s);
 780:	8b 45 f4             	mov    -0xc(%ebp),%eax
 783:	0f b6 00             	movzbl (%eax),%eax
 786:	0f be c0             	movsbl %al,%eax
 789:	83 ec 08             	sub    $0x8,%esp
 78c:	50                   	push   %eax
 78d:	ff 75 08             	pushl  0x8(%ebp)
 790:	e8 31 fe ff ff       	call   5c6 <putc>
 795:	83 c4 10             	add    $0x10,%esp
          s++;
 798:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	0f b6 00             	movzbl (%eax),%eax
 7a2:	84 c0                	test   %al,%al
 7a4:	75 da                	jne    780 <printf+0xe3>
 7a6:	eb 65                	jmp    80d <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7a8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7ac:	75 1d                	jne    7cb <printf+0x12e>
        putc(fd, *ap);
 7ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	0f be c0             	movsbl %al,%eax
 7b6:	83 ec 08             	sub    $0x8,%esp
 7b9:	50                   	push   %eax
 7ba:	ff 75 08             	pushl  0x8(%ebp)
 7bd:	e8 04 fe ff ff       	call   5c6 <putc>
 7c2:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c9:	eb 42                	jmp    80d <printf+0x170>
      } else if(c == '%'){
 7cb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7cf:	75 17                	jne    7e8 <printf+0x14b>
        putc(fd, c);
 7d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d4:	0f be c0             	movsbl %al,%eax
 7d7:	83 ec 08             	sub    $0x8,%esp
 7da:	50                   	push   %eax
 7db:	ff 75 08             	pushl  0x8(%ebp)
 7de:	e8 e3 fd ff ff       	call   5c6 <putc>
 7e3:	83 c4 10             	add    $0x10,%esp
 7e6:	eb 25                	jmp    80d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7e8:	83 ec 08             	sub    $0x8,%esp
 7eb:	6a 25                	push   $0x25
 7ed:	ff 75 08             	pushl  0x8(%ebp)
 7f0:	e8 d1 fd ff ff       	call   5c6 <putc>
 7f5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fb:	0f be c0             	movsbl %al,%eax
 7fe:	83 ec 08             	sub    $0x8,%esp
 801:	50                   	push   %eax
 802:	ff 75 08             	pushl  0x8(%ebp)
 805:	e8 bc fd ff ff       	call   5c6 <putc>
 80a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 80d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 814:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 818:	8b 55 0c             	mov    0xc(%ebp),%edx
 81b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81e:	01 d0                	add    %edx,%eax
 820:	0f b6 00             	movzbl (%eax),%eax
 823:	84 c0                	test   %al,%al
 825:	0f 85 94 fe ff ff    	jne    6bf <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 82b:	90                   	nop
 82c:	c9                   	leave  
 82d:	c3                   	ret    

0000082e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82e:	55                   	push   %ebp
 82f:	89 e5                	mov    %esp,%ebp
 831:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 834:	8b 45 08             	mov    0x8(%ebp),%eax
 837:	83 e8 08             	sub    $0x8,%eax
 83a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83d:	a1 ac 0d 00 00       	mov    0xdac,%eax
 842:	89 45 fc             	mov    %eax,-0x4(%ebp)
 845:	eb 24                	jmp    86b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	8b 00                	mov    (%eax),%eax
 84c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 84f:	77 12                	ja     863 <free+0x35>
 851:	8b 45 f8             	mov    -0x8(%ebp),%eax
 854:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 857:	77 24                	ja     87d <free+0x4f>
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 861:	77 1a                	ja     87d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	8b 00                	mov    (%eax),%eax
 868:	89 45 fc             	mov    %eax,-0x4(%ebp)
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 871:	76 d4                	jbe    847 <free+0x19>
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87b:	76 ca                	jbe    847 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	8b 40 04             	mov    0x4(%eax),%eax
 883:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 88a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88d:	01 c2                	add    %eax,%edx
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	39 c2                	cmp    %eax,%edx
 896:	75 24                	jne    8bc <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 898:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89b:	8b 50 04             	mov    0x4(%eax),%edx
 89e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a1:	8b 00                	mov    (%eax),%eax
 8a3:	8b 40 04             	mov    0x4(%eax),%eax
 8a6:	01 c2                	add    %eax,%edx
 8a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ab:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b1:	8b 00                	mov    (%eax),%eax
 8b3:	8b 10                	mov    (%eax),%edx
 8b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b8:	89 10                	mov    %edx,(%eax)
 8ba:	eb 0a                	jmp    8c6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bf:	8b 10                	mov    (%eax),%edx
 8c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c9:	8b 40 04             	mov    0x4(%eax),%eax
 8cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d6:	01 d0                	add    %edx,%eax
 8d8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8db:	75 20                	jne    8fd <free+0xcf>
    p->s.size += bp->s.size;
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	8b 50 04             	mov    0x4(%eax),%edx
 8e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e6:	8b 40 04             	mov    0x4(%eax),%eax
 8e9:	01 c2                	add    %eax,%edx
 8eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ee:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f4:	8b 10                	mov    (%eax),%edx
 8f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f9:	89 10                	mov    %edx,(%eax)
 8fb:	eb 08                	jmp    905 <free+0xd7>
  } else
    p->s.ptr = bp;
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 55 f8             	mov    -0x8(%ebp),%edx
 903:	89 10                	mov    %edx,(%eax)
  freep = p;
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	a3 ac 0d 00 00       	mov    %eax,0xdac
}
 90d:	90                   	nop
 90e:	c9                   	leave  
 90f:	c3                   	ret    

00000910 <morecore>:

static Header*
morecore(uint nu)
{
 910:	55                   	push   %ebp
 911:	89 e5                	mov    %esp,%ebp
 913:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 916:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 91d:	77 07                	ja     926 <morecore+0x16>
    nu = 4096;
 91f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 926:	8b 45 08             	mov    0x8(%ebp),%eax
 929:	c1 e0 03             	shl    $0x3,%eax
 92c:	83 ec 0c             	sub    $0xc,%esp
 92f:	50                   	push   %eax
 930:	e8 39 fc ff ff       	call   56e <sbrk>
 935:	83 c4 10             	add    $0x10,%esp
 938:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 93b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 93f:	75 07                	jne    948 <morecore+0x38>
    return 0;
 941:	b8 00 00 00 00       	mov    $0x0,%eax
 946:	eb 26                	jmp    96e <morecore+0x5e>
  hp = (Header*)p;
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 94e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 951:	8b 55 08             	mov    0x8(%ebp),%edx
 954:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 957:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95a:	83 c0 08             	add    $0x8,%eax
 95d:	83 ec 0c             	sub    $0xc,%esp
 960:	50                   	push   %eax
 961:	e8 c8 fe ff ff       	call   82e <free>
 966:	83 c4 10             	add    $0x10,%esp
  return freep;
 969:	a1 ac 0d 00 00       	mov    0xdac,%eax
}
 96e:	c9                   	leave  
 96f:	c3                   	ret    

00000970 <malloc>:

void*
malloc(uint nbytes)
{
 970:	55                   	push   %ebp
 971:	89 e5                	mov    %esp,%ebp
 973:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 976:	8b 45 08             	mov    0x8(%ebp),%eax
 979:	83 c0 07             	add    $0x7,%eax
 97c:	c1 e8 03             	shr    $0x3,%eax
 97f:	83 c0 01             	add    $0x1,%eax
 982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 985:	a1 ac 0d 00 00       	mov    0xdac,%eax
 98a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 991:	75 23                	jne    9b6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 993:	c7 45 f0 a4 0d 00 00 	movl   $0xda4,-0x10(%ebp)
 99a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99d:	a3 ac 0d 00 00       	mov    %eax,0xdac
 9a2:	a1 ac 0d 00 00       	mov    0xdac,%eax
 9a7:	a3 a4 0d 00 00       	mov    %eax,0xda4
    base.s.size = 0;
 9ac:	c7 05 a8 0d 00 00 00 	movl   $0x0,0xda8
 9b3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b9:	8b 00                	mov    (%eax),%eax
 9bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	8b 40 04             	mov    0x4(%eax),%eax
 9c4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9c7:	72 4d                	jb     a16 <malloc+0xa6>
      if(p->s.size == nunits)
 9c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cc:	8b 40 04             	mov    0x4(%eax),%eax
 9cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d2:	75 0c                	jne    9e0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	8b 10                	mov    (%eax),%edx
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	89 10                	mov    %edx,(%eax)
 9de:	eb 26                	jmp    a06 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 40 04             	mov    0x4(%eax),%eax
 9e6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9e9:	89 c2                	mov    %eax,%edx
 9eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ee:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	c1 e0 03             	shl    $0x3,%eax
 9fa:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a00:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a03:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a09:	a3 ac 0d 00 00       	mov    %eax,0xdac
      return (void*)(p + 1);
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	83 c0 08             	add    $0x8,%eax
 a14:	eb 3b                	jmp    a51 <malloc+0xe1>
    }
    if(p == freep)
 a16:	a1 ac 0d 00 00       	mov    0xdac,%eax
 a1b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a1e:	75 1e                	jne    a3e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a20:	83 ec 0c             	sub    $0xc,%esp
 a23:	ff 75 ec             	pushl  -0x14(%ebp)
 a26:	e8 e5 fe ff ff       	call   910 <morecore>
 a2b:	83 c4 10             	add    $0x10,%esp
 a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a35:	75 07                	jne    a3e <malloc+0xce>
        return 0;
 a37:	b8 00 00 00 00       	mov    $0x0,%eax
 a3c:	eb 13                	jmp    a51 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a47:	8b 00                	mov    (%eax),%eax
 a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a4c:	e9 6d ff ff ff       	jmp    9be <malloc+0x4e>
}
 a51:	c9                   	leave  
 a52:	c3                   	ret    
