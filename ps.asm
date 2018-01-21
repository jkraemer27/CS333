
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
  
  struct uproc *p = malloc(sizeof(struct uproc) * MAXPROC);
  14:	83 ec 0c             	sub    $0xc,%esp
  17:	68 00 17 00 00       	push   $0x1700
  1c:	e8 93 08 00 00       	call   8b4 <malloc>
  21:	83 c4 10             	add    $0x10,%esp
  24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  getprocs(MAXPROC, p);
  27:	83 ec 08             	sub    $0x8,%esp
  2a:	ff 75 e0             	pushl  -0x20(%ebp)
  2d:	6a 40                	push   $0x40
  2f:	e8 ce 04 00 00       	call   502 <getprocs>
  34:	83 c4 10             	add    $0x10,%esp

  printf(1, "PID    UID	GID PPID    Elapsed CPU	    State   Size    Name\n");
  37:	83 ec 08             	sub    $0x8,%esp
  3a:	68 98 09 00 00       	push   $0x998
  3f:	6a 01                	push   $0x1
  41:	e8 9b 05 00 00       	call   5e1 <printf>
  46:	83 c4 10             	add    $0x10,%esp

  for(int i = 0; i < MAXPROC; ++i)
  49:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  50:	e9 9c 00 00 00       	jmp    f1 <main+0xf1>
  {
    printf(1, "%d\t %d\t %d\t %d\t %d\t %s\t %d\t %s\n", p[i].pid, p[i].uid, p[i].gid, p[i].ppid, p[i].elapsed_ticks, p[i].state, p[i].size, p[i].name);
  55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  58:	6b d0 5c             	imul   $0x5c,%eax,%edx
  5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  5e:	01 d0                	add    %edx,%eax
  60:	83 c0 3c             	add    $0x3c,%eax
  63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  69:	6b d0 5c             	imul   $0x5c,%eax,%edx
  6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  6f:	01 d0                	add    %edx,%eax
  71:	8b 48 38             	mov    0x38(%eax),%ecx
  74:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  7a:	6b d0 5c             	imul   $0x5c,%eax,%edx
  7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80:	01 d0                	add    %edx,%eax
  82:	8d 58 18             	lea    0x18(%eax),%ebx
  85:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8b:	6b d0 5c             	imul   $0x5c,%eax,%edx
  8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  91:	01 d0                	add    %edx,%eax
  93:	8b 78 10             	mov    0x10(%eax),%edi
  96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  99:	6b d0 5c             	imul   $0x5c,%eax,%edx
  9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  9f:	01 d0                	add    %edx,%eax
  a1:	8b 70 0c             	mov    0xc(%eax),%esi
  a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  a7:	6b d0 5c             	imul   $0x5c,%eax,%edx
  aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  ad:	01 d0                	add    %edx,%eax
  af:	8b 58 08             	mov    0x8(%eax),%ebx
  b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b5:	6b d0 5c             	imul   $0x5c,%eax,%edx
  b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  bb:	01 d0                	add    %edx,%eax
  bd:	8b 48 04             	mov    0x4(%eax),%ecx
  c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c3:	6b d0 5c             	imul   $0x5c,%eax,%edx
  c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  c9:	01 d0                	add    %edx,%eax
  cb:	8b 00                	mov    (%eax),%eax
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  d3:	ff 75 d0             	pushl  -0x30(%ebp)
  d6:	ff 75 cc             	pushl  -0x34(%ebp)
  d9:	57                   	push   %edi
  da:	56                   	push   %esi
  db:	53                   	push   %ebx
  dc:	51                   	push   %ecx
  dd:	50                   	push   %eax
  de:	68 d8 09 00 00       	push   $0x9d8
  e3:	6a 01                	push   $0x1
  e5:	e8 f7 04 00 00       	call   5e1 <printf>
  ea:	83 c4 30             	add    $0x30,%esp
  struct uproc *p = malloc(sizeof(struct uproc) * MAXPROC);
  getprocs(MAXPROC, p);

  printf(1, "PID    UID	GID PPID    Elapsed CPU	    State   Size    Name\n");

  for(int i = 0; i < MAXPROC; ++i)
  ed:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  f1:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
  f5:	0f 8e 5a ff ff ff    	jle    55 <main+0x55>
  {
    printf(1, "%d\t %d\t %d\t %d\t %d\t %s\t %d\t %s\n", p[i].pid, p[i].uid, p[i].gid, p[i].ppid, p[i].elapsed_ticks, p[i].state, p[i].size, p[i].name);
  }

  exit();
  fb:	e8 2a 03 00 00       	call   42a <exit>

00000100 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	57                   	push   %edi
 104:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 105:	8b 4d 08             	mov    0x8(%ebp),%ecx
 108:	8b 55 10             	mov    0x10(%ebp),%edx
 10b:	8b 45 0c             	mov    0xc(%ebp),%eax
 10e:	89 cb                	mov    %ecx,%ebx
 110:	89 df                	mov    %ebx,%edi
 112:	89 d1                	mov    %edx,%ecx
 114:	fc                   	cld    
 115:	f3 aa                	rep stos %al,%es:(%edi)
 117:	89 ca                	mov    %ecx,%edx
 119:	89 fb                	mov    %edi,%ebx
 11b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 11e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 121:	90                   	nop
 122:	5b                   	pop    %ebx
 123:	5f                   	pop    %edi
 124:	5d                   	pop    %ebp
 125:	c3                   	ret    

00000126 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 132:	90                   	nop
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	8d 50 01             	lea    0x1(%eax),%edx
 139:	89 55 08             	mov    %edx,0x8(%ebp)
 13c:	8b 55 0c             	mov    0xc(%ebp),%edx
 13f:	8d 4a 01             	lea    0x1(%edx),%ecx
 142:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 145:	0f b6 12             	movzbl (%edx),%edx
 148:	88 10                	mov    %dl,(%eax)
 14a:	0f b6 00             	movzbl (%eax),%eax
 14d:	84 c0                	test   %al,%al
 14f:	75 e2                	jne    133 <strcpy+0xd>
    ;
  return os;
 151:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 154:	c9                   	leave  
 155:	c3                   	ret    

00000156 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 156:	55                   	push   %ebp
 157:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 159:	eb 08                	jmp    163 <strcmp+0xd>
    p++, q++;
 15b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	84 c0                	test   %al,%al
 16b:	74 10                	je     17d <strcmp+0x27>
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 10             	movzbl (%eax),%edx
 173:	8b 45 0c             	mov    0xc(%ebp),%eax
 176:	0f b6 00             	movzbl (%eax),%eax
 179:	38 c2                	cmp    %al,%dl
 17b:	74 de                	je     15b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	0f b6 00             	movzbl (%eax),%eax
 183:	0f b6 d0             	movzbl %al,%edx
 186:	8b 45 0c             	mov    0xc(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	0f b6 c0             	movzbl %al,%eax
 18f:	29 c2                	sub    %eax,%edx
 191:	89 d0                	mov    %edx,%eax
}
 193:	5d                   	pop    %ebp
 194:	c3                   	ret    

00000195 <strlen>:

uint
strlen(char *s)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
 198:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 19b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a2:	eb 04                	jmp    1a8 <strlen+0x13>
 1a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ab:	8b 45 08             	mov    0x8(%ebp),%eax
 1ae:	01 d0                	add    %edx,%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	84 c0                	test   %al,%al
 1b5:	75 ed                	jne    1a4 <strlen+0xf>
    ;
  return n;
 1b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ba:	c9                   	leave  
 1bb:	c3                   	ret    

000001bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1bf:	8b 45 10             	mov    0x10(%ebp),%eax
 1c2:	50                   	push   %eax
 1c3:	ff 75 0c             	pushl  0xc(%ebp)
 1c6:	ff 75 08             	pushl  0x8(%ebp)
 1c9:	e8 32 ff ff ff       	call   100 <stosb>
 1ce:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d4:	c9                   	leave  
 1d5:	c3                   	ret    

000001d6 <strchr>:

char*
strchr(const char *s, char c)
{
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	83 ec 04             	sub    $0x4,%esp
 1dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1df:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1e2:	eb 14                	jmp    1f8 <strchr+0x22>
    if(*s == c)
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	0f b6 00             	movzbl (%eax),%eax
 1ea:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ed:	75 05                	jne    1f4 <strchr+0x1e>
      return (char*)s;
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	eb 13                	jmp    207 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	0f b6 00             	movzbl (%eax),%eax
 1fe:	84 c0                	test   %al,%al
 200:	75 e2                	jne    1e4 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 202:	b8 00 00 00 00       	mov    $0x0,%eax
}
 207:	c9                   	leave  
 208:	c3                   	ret    

00000209 <gets>:

char*
gets(char *buf, int max)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 216:	eb 42                	jmp    25a <gets+0x51>
    cc = read(0, &c, 1);
 218:	83 ec 04             	sub    $0x4,%esp
 21b:	6a 01                	push   $0x1
 21d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 220:	50                   	push   %eax
 221:	6a 00                	push   $0x0
 223:	e8 1a 02 00 00       	call   442 <read>
 228:	83 c4 10             	add    $0x10,%esp
 22b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 22e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 232:	7e 33                	jle    267 <gets+0x5e>
      break;
    buf[i++] = c;
 234:	8b 45 f4             	mov    -0xc(%ebp),%eax
 237:	8d 50 01             	lea    0x1(%eax),%edx
 23a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 23d:	89 c2                	mov    %eax,%edx
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
 242:	01 c2                	add    %eax,%edx
 244:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 248:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 24a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24e:	3c 0a                	cmp    $0xa,%al
 250:	74 16                	je     268 <gets+0x5f>
 252:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 256:	3c 0d                	cmp    $0xd,%al
 258:	74 0e                	je     268 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25d:	83 c0 01             	add    $0x1,%eax
 260:	3b 45 0c             	cmp    0xc(%ebp),%eax
 263:	7c b3                	jl     218 <gets+0xf>
 265:	eb 01                	jmp    268 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 267:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 268:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	01 d0                	add    %edx,%eax
 270:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 273:	8b 45 08             	mov    0x8(%ebp),%eax
}
 276:	c9                   	leave  
 277:	c3                   	ret    

00000278 <stat>:

int
stat(char *n, struct stat *st)
{
 278:	55                   	push   %ebp
 279:	89 e5                	mov    %esp,%ebp
 27b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27e:	83 ec 08             	sub    $0x8,%esp
 281:	6a 00                	push   $0x0
 283:	ff 75 08             	pushl  0x8(%ebp)
 286:	e8 df 01 00 00       	call   46a <open>
 28b:	83 c4 10             	add    $0x10,%esp
 28e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 291:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 295:	79 07                	jns    29e <stat+0x26>
    return -1;
 297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29c:	eb 25                	jmp    2c3 <stat+0x4b>
  r = fstat(fd, st);
 29e:	83 ec 08             	sub    $0x8,%esp
 2a1:	ff 75 0c             	pushl  0xc(%ebp)
 2a4:	ff 75 f4             	pushl  -0xc(%ebp)
 2a7:	e8 d6 01 00 00       	call   482 <fstat>
 2ac:	83 c4 10             	add    $0x10,%esp
 2af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b2:	83 ec 0c             	sub    $0xc,%esp
 2b5:	ff 75 f4             	pushl  -0xc(%ebp)
 2b8:	e8 95 01 00 00       	call   452 <close>
 2bd:	83 c4 10             	add    $0x10,%esp
  return r;
 2c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c3:	c9                   	leave  
 2c4:	c3                   	ret    

000002c5 <atoi>:

int
atoi(const char *s)
{
 2c5:	55                   	push   %ebp
 2c6:	89 e5                	mov    %esp,%ebp
 2c8:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2d2:	eb 04                	jmp    2d8 <atoi+0x13>
 2d4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
 2db:	0f b6 00             	movzbl (%eax),%eax
 2de:	3c 20                	cmp    $0x20,%al
 2e0:	74 f2                	je     2d4 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	0f b6 00             	movzbl (%eax),%eax
 2e8:	3c 2d                	cmp    $0x2d,%al
 2ea:	75 07                	jne    2f3 <atoi+0x2e>
 2ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2f1:	eb 05                	jmp    2f8 <atoi+0x33>
 2f3:	b8 01 00 00 00       	mov    $0x1,%eax
 2f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	3c 2b                	cmp    $0x2b,%al
 303:	74 0a                	je     30f <atoi+0x4a>
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	0f b6 00             	movzbl (%eax),%eax
 30b:	3c 2d                	cmp    $0x2d,%al
 30d:	75 2b                	jne    33a <atoi+0x75>
    s++;
 30f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 313:	eb 25                	jmp    33a <atoi+0x75>
    n = n*10 + *s++ - '0';
 315:	8b 55 fc             	mov    -0x4(%ebp),%edx
 318:	89 d0                	mov    %edx,%eax
 31a:	c1 e0 02             	shl    $0x2,%eax
 31d:	01 d0                	add    %edx,%eax
 31f:	01 c0                	add    %eax,%eax
 321:	89 c1                	mov    %eax,%ecx
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	8d 50 01             	lea    0x1(%eax),%edx
 329:	89 55 08             	mov    %edx,0x8(%ebp)
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	0f be c0             	movsbl %al,%eax
 332:	01 c8                	add    %ecx,%eax
 334:	83 e8 30             	sub    $0x30,%eax
 337:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	3c 2f                	cmp    $0x2f,%al
 342:	7e 0a                	jle    34e <atoi+0x89>
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	0f b6 00             	movzbl (%eax),%eax
 34a:	3c 39                	cmp    $0x39,%al
 34c:	7e c7                	jle    315 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 34e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 351:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 355:	c9                   	leave  
 356:	c3                   	ret    

00000357 <atoo>:

int
atoo(const char *s)
{
 357:	55                   	push   %ebp
 358:	89 e5                	mov    %esp,%ebp
 35a:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 35d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 364:	eb 04                	jmp    36a <atoo+0x13>
 366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	0f b6 00             	movzbl (%eax),%eax
 370:	3c 20                	cmp    $0x20,%al
 372:	74 f2                	je     366 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 374:	8b 45 08             	mov    0x8(%ebp),%eax
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	3c 2d                	cmp    $0x2d,%al
 37c:	75 07                	jne    385 <atoo+0x2e>
 37e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 383:	eb 05                	jmp    38a <atoo+0x33>
 385:	b8 01 00 00 00       	mov    $0x1,%eax
 38a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	0f b6 00             	movzbl (%eax),%eax
 393:	3c 2b                	cmp    $0x2b,%al
 395:	74 0a                	je     3a1 <atoo+0x4a>
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	0f b6 00             	movzbl (%eax),%eax
 39d:	3c 2d                	cmp    $0x2d,%al
 39f:	75 27                	jne    3c8 <atoo+0x71>
    s++;
 3a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 3a5:	eb 21                	jmp    3c8 <atoo+0x71>
    n = n*8 + *s++ - '0';
 3a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3aa:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	8d 50 01             	lea    0x1(%eax),%edx
 3b7:	89 55 08             	mov    %edx,0x8(%ebp)
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	0f be c0             	movsbl %al,%eax
 3c0:	01 c8                	add    %ecx,%eax
 3c2:	83 e8 30             	sub    $0x30,%eax
 3c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	3c 2f                	cmp    $0x2f,%al
 3d0:	7e 0a                	jle    3dc <atoo+0x85>
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	3c 37                	cmp    $0x37,%al
 3da:	7e cb                	jle    3a7 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3df:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3e3:	c9                   	leave  
 3e4:	c3                   	ret    

000003e5 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 3e5:	55                   	push   %ebp
 3e6:	89 e5                	mov    %esp,%ebp
 3e8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f7:	eb 17                	jmp    410 <memmove+0x2b>
    *dst++ = *src++;
 3f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3fc:	8d 50 01             	lea    0x1(%eax),%edx
 3ff:	89 55 fc             	mov    %edx,-0x4(%ebp)
 402:	8b 55 f8             	mov    -0x8(%ebp),%edx
 405:	8d 4a 01             	lea    0x1(%edx),%ecx
 408:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 40b:	0f b6 12             	movzbl (%edx),%edx
 40e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 410:	8b 45 10             	mov    0x10(%ebp),%eax
 413:	8d 50 ff             	lea    -0x1(%eax),%edx
 416:	89 55 10             	mov    %edx,0x10(%ebp)
 419:	85 c0                	test   %eax,%eax
 41b:	7f dc                	jg     3f9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 420:	c9                   	leave  
 421:	c3                   	ret    

00000422 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 422:	b8 01 00 00 00       	mov    $0x1,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <exit>:
SYSCALL(exit)
 42a:	b8 02 00 00 00       	mov    $0x2,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <wait>:
SYSCALL(wait)
 432:	b8 03 00 00 00       	mov    $0x3,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <pipe>:
SYSCALL(pipe)
 43a:	b8 04 00 00 00       	mov    $0x4,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <read>:
SYSCALL(read)
 442:	b8 05 00 00 00       	mov    $0x5,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <write>:
SYSCALL(write)
 44a:	b8 10 00 00 00       	mov    $0x10,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <close>:
SYSCALL(close)
 452:	b8 15 00 00 00       	mov    $0x15,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <kill>:
SYSCALL(kill)
 45a:	b8 06 00 00 00       	mov    $0x6,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <exec>:
SYSCALL(exec)
 462:	b8 07 00 00 00       	mov    $0x7,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <open>:
SYSCALL(open)
 46a:	b8 0f 00 00 00       	mov    $0xf,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <mknod>:
SYSCALL(mknod)
 472:	b8 11 00 00 00       	mov    $0x11,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <unlink>:
SYSCALL(unlink)
 47a:	b8 12 00 00 00       	mov    $0x12,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <fstat>:
SYSCALL(fstat)
 482:	b8 08 00 00 00       	mov    $0x8,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <link>:
SYSCALL(link)
 48a:	b8 13 00 00 00       	mov    $0x13,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <mkdir>:
SYSCALL(mkdir)
 492:	b8 14 00 00 00       	mov    $0x14,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <chdir>:
SYSCALL(chdir)
 49a:	b8 09 00 00 00       	mov    $0x9,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <dup>:
SYSCALL(dup)
 4a2:	b8 0a 00 00 00       	mov    $0xa,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <getpid>:
SYSCALL(getpid)
 4aa:	b8 0b 00 00 00       	mov    $0xb,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <sbrk>:
SYSCALL(sbrk)
 4b2:	b8 0c 00 00 00       	mov    $0xc,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <sleep>:
SYSCALL(sleep)
 4ba:	b8 0d 00 00 00       	mov    $0xd,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <uptime>:
SYSCALL(uptime)
 4c2:	b8 0e 00 00 00       	mov    $0xe,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <halt>:
SYSCALL(halt)
 4ca:	b8 16 00 00 00       	mov    $0x16,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret    

000004d2 <date>:
SYSCALL(date)
 4d2:	b8 17 00 00 00       	mov    $0x17,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret    

000004da <getuid>:
SYSCALL(getuid)
 4da:	b8 18 00 00 00       	mov    $0x18,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret    

000004e2 <getgid>:
SYSCALL(getgid)
 4e2:	b8 19 00 00 00       	mov    $0x19,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret    

000004ea <getppid>:
SYSCALL(getppid)
 4ea:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret    

000004f2 <setuid>:
SYSCALL(setuid)
 4f2:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret    

000004fa <setgid>:
SYSCALL(setgid)
 4fa:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <getprocs>:
SYSCALL(getprocs)
 502:	b8 1a 00 00 00       	mov    $0x1a,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 50a:	55                   	push   %ebp
 50b:	89 e5                	mov    %esp,%ebp
 50d:	83 ec 18             	sub    $0x18,%esp
 510:	8b 45 0c             	mov    0xc(%ebp),%eax
 513:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 516:	83 ec 04             	sub    $0x4,%esp
 519:	6a 01                	push   $0x1
 51b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 51e:	50                   	push   %eax
 51f:	ff 75 08             	pushl  0x8(%ebp)
 522:	e8 23 ff ff ff       	call   44a <write>
 527:	83 c4 10             	add    $0x10,%esp
}
 52a:	90                   	nop
 52b:	c9                   	leave  
 52c:	c3                   	ret    

0000052d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52d:	55                   	push   %ebp
 52e:	89 e5                	mov    %esp,%ebp
 530:	53                   	push   %ebx
 531:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 534:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 53b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 53f:	74 17                	je     558 <printint+0x2b>
 541:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 545:	79 11                	jns    558 <printint+0x2b>
    neg = 1;
 547:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 54e:	8b 45 0c             	mov    0xc(%ebp),%eax
 551:	f7 d8                	neg    %eax
 553:	89 45 ec             	mov    %eax,-0x14(%ebp)
 556:	eb 06                	jmp    55e <printint+0x31>
  } else {
    x = xx;
 558:	8b 45 0c             	mov    0xc(%ebp),%eax
 55b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 55e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 565:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 568:	8d 41 01             	lea    0x1(%ecx),%eax
 56b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 56e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 571:	8b 45 ec             	mov    -0x14(%ebp),%eax
 574:	ba 00 00 00 00       	mov    $0x0,%edx
 579:	f7 f3                	div    %ebx
 57b:	89 d0                	mov    %edx,%eax
 57d:	0f b6 80 74 0c 00 00 	movzbl 0xc74(%eax),%eax
 584:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 588:	8b 5d 10             	mov    0x10(%ebp),%ebx
 58b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58e:	ba 00 00 00 00       	mov    $0x0,%edx
 593:	f7 f3                	div    %ebx
 595:	89 45 ec             	mov    %eax,-0x14(%ebp)
 598:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 59c:	75 c7                	jne    565 <printint+0x38>
  if(neg)
 59e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a2:	74 2d                	je     5d1 <printint+0xa4>
    buf[i++] = '-';
 5a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a7:	8d 50 01             	lea    0x1(%eax),%edx
 5aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5ad:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5b2:	eb 1d                	jmp    5d1 <printint+0xa4>
    putc(fd, buf[i]);
 5b4:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ba:	01 d0                	add    %edx,%eax
 5bc:	0f b6 00             	movzbl (%eax),%eax
 5bf:	0f be c0             	movsbl %al,%eax
 5c2:	83 ec 08             	sub    $0x8,%esp
 5c5:	50                   	push   %eax
 5c6:	ff 75 08             	pushl  0x8(%ebp)
 5c9:	e8 3c ff ff ff       	call   50a <putc>
 5ce:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d9:	79 d9                	jns    5b4 <printint+0x87>
    putc(fd, buf[i]);
}
 5db:	90                   	nop
 5dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5df:	c9                   	leave  
 5e0:	c3                   	ret    

000005e1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e1:	55                   	push   %ebp
 5e2:	89 e5                	mov    %esp,%ebp
 5e4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ee:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f1:	83 c0 04             	add    $0x4,%eax
 5f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5fe:	e9 59 01 00 00       	jmp    75c <printf+0x17b>
    c = fmt[i] & 0xff;
 603:	8b 55 0c             	mov    0xc(%ebp),%edx
 606:	8b 45 f0             	mov    -0x10(%ebp),%eax
 609:	01 d0                	add    %edx,%eax
 60b:	0f b6 00             	movzbl (%eax),%eax
 60e:	0f be c0             	movsbl %al,%eax
 611:	25 ff 00 00 00       	and    $0xff,%eax
 616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 619:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61d:	75 2c                	jne    64b <printf+0x6a>
      if(c == '%'){
 61f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 623:	75 0c                	jne    631 <printf+0x50>
        state = '%';
 625:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62c:	e9 27 01 00 00       	jmp    758 <printf+0x177>
      } else {
        putc(fd, c);
 631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	83 ec 08             	sub    $0x8,%esp
 63a:	50                   	push   %eax
 63b:	ff 75 08             	pushl  0x8(%ebp)
 63e:	e8 c7 fe ff ff       	call   50a <putc>
 643:	83 c4 10             	add    $0x10,%esp
 646:	e9 0d 01 00 00       	jmp    758 <printf+0x177>
      }
    } else if(state == '%'){
 64b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 64f:	0f 85 03 01 00 00    	jne    758 <printf+0x177>
      if(c == 'd'){
 655:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 659:	75 1e                	jne    679 <printf+0x98>
        printint(fd, *ap, 10, 1);
 65b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	6a 01                	push   $0x1
 662:	6a 0a                	push   $0xa
 664:	50                   	push   %eax
 665:	ff 75 08             	pushl  0x8(%ebp)
 668:	e8 c0 fe ff ff       	call   52d <printint>
 66d:	83 c4 10             	add    $0x10,%esp
        ap++;
 670:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 674:	e9 d8 00 00 00       	jmp    751 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 679:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 67d:	74 06                	je     685 <printf+0xa4>
 67f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 683:	75 1e                	jne    6a3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 685:	8b 45 e8             	mov    -0x18(%ebp),%eax
 688:	8b 00                	mov    (%eax),%eax
 68a:	6a 00                	push   $0x0
 68c:	6a 10                	push   $0x10
 68e:	50                   	push   %eax
 68f:	ff 75 08             	pushl  0x8(%ebp)
 692:	e8 96 fe ff ff       	call   52d <printint>
 697:	83 c4 10             	add    $0x10,%esp
        ap++;
 69a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69e:	e9 ae 00 00 00       	jmp    751 <printf+0x170>
      } else if(c == 's'){
 6a3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6a7:	75 43                	jne    6ec <printf+0x10b>
        s = (char*)*ap;
 6a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ac:	8b 00                	mov    (%eax),%eax
 6ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b9:	75 25                	jne    6e0 <printf+0xff>
          s = "(null)";
 6bb:	c7 45 f4 f8 09 00 00 	movl   $0x9f8,-0xc(%ebp)
        while(*s != 0){
 6c2:	eb 1c                	jmp    6e0 <printf+0xff>
          putc(fd, *s);
 6c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c7:	0f b6 00             	movzbl (%eax),%eax
 6ca:	0f be c0             	movsbl %al,%eax
 6cd:	83 ec 08             	sub    $0x8,%esp
 6d0:	50                   	push   %eax
 6d1:	ff 75 08             	pushl  0x8(%ebp)
 6d4:	e8 31 fe ff ff       	call   50a <putc>
 6d9:	83 c4 10             	add    $0x10,%esp
          s++;
 6dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e3:	0f b6 00             	movzbl (%eax),%eax
 6e6:	84 c0                	test   %al,%al
 6e8:	75 da                	jne    6c4 <printf+0xe3>
 6ea:	eb 65                	jmp    751 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ec:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6f0:	75 1d                	jne    70f <printf+0x12e>
        putc(fd, *ap);
 6f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f5:	8b 00                	mov    (%eax),%eax
 6f7:	0f be c0             	movsbl %al,%eax
 6fa:	83 ec 08             	sub    $0x8,%esp
 6fd:	50                   	push   %eax
 6fe:	ff 75 08             	pushl  0x8(%ebp)
 701:	e8 04 fe ff ff       	call   50a <putc>
 706:	83 c4 10             	add    $0x10,%esp
        ap++;
 709:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70d:	eb 42                	jmp    751 <printf+0x170>
      } else if(c == '%'){
 70f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 713:	75 17                	jne    72c <printf+0x14b>
        putc(fd, c);
 715:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 718:	0f be c0             	movsbl %al,%eax
 71b:	83 ec 08             	sub    $0x8,%esp
 71e:	50                   	push   %eax
 71f:	ff 75 08             	pushl  0x8(%ebp)
 722:	e8 e3 fd ff ff       	call   50a <putc>
 727:	83 c4 10             	add    $0x10,%esp
 72a:	eb 25                	jmp    751 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 72c:	83 ec 08             	sub    $0x8,%esp
 72f:	6a 25                	push   $0x25
 731:	ff 75 08             	pushl  0x8(%ebp)
 734:	e8 d1 fd ff ff       	call   50a <putc>
 739:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 73c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73f:	0f be c0             	movsbl %al,%eax
 742:	83 ec 08             	sub    $0x8,%esp
 745:	50                   	push   %eax
 746:	ff 75 08             	pushl  0x8(%ebp)
 749:	e8 bc fd ff ff       	call   50a <putc>
 74e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 751:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 758:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 75c:	8b 55 0c             	mov    0xc(%ebp),%edx
 75f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 762:	01 d0                	add    %edx,%eax
 764:	0f b6 00             	movzbl (%eax),%eax
 767:	84 c0                	test   %al,%al
 769:	0f 85 94 fe ff ff    	jne    603 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 76f:	90                   	nop
 770:	c9                   	leave  
 771:	c3                   	ret    

00000772 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 772:	55                   	push   %ebp
 773:	89 e5                	mov    %esp,%ebp
 775:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 778:	8b 45 08             	mov    0x8(%ebp),%eax
 77b:	83 e8 08             	sub    $0x8,%eax
 77e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 781:	a1 90 0c 00 00       	mov    0xc90,%eax
 786:	89 45 fc             	mov    %eax,-0x4(%ebp)
 789:	eb 24                	jmp    7af <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 793:	77 12                	ja     7a7 <free+0x35>
 795:	8b 45 f8             	mov    -0x8(%ebp),%eax
 798:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79b:	77 24                	ja     7c1 <free+0x4f>
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a5:	77 1a                	ja     7c1 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 00                	mov    (%eax),%eax
 7ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b5:	76 d4                	jbe    78b <free+0x19>
 7b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ba:	8b 00                	mov    (%eax),%eax
 7bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bf:	76 ca                	jbe    78b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c4:	8b 40 04             	mov    0x4(%eax),%eax
 7c7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d1:	01 c2                	add    %eax,%edx
 7d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d6:	8b 00                	mov    (%eax),%eax
 7d8:	39 c2                	cmp    %eax,%edx
 7da:	75 24                	jne    800 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7df:	8b 50 04             	mov    0x4(%eax),%edx
 7e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e5:	8b 00                	mov    (%eax),%eax
 7e7:	8b 40 04             	mov    0x4(%eax),%eax
 7ea:	01 c2                	add    %eax,%edx
 7ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ef:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f5:	8b 00                	mov    (%eax),%eax
 7f7:	8b 10                	mov    (%eax),%edx
 7f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fc:	89 10                	mov    %edx,(%eax)
 7fe:	eb 0a                	jmp    80a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 10                	mov    (%eax),%edx
 805:	8b 45 f8             	mov    -0x8(%ebp),%eax
 808:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	8b 40 04             	mov    0x4(%eax),%eax
 810:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 817:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81a:	01 d0                	add    %edx,%eax
 81c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81f:	75 20                	jne    841 <free+0xcf>
    p->s.size += bp->s.size;
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 50 04             	mov    0x4(%eax),%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	01 c2                	add    %eax,%edx
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 835:	8b 45 f8             	mov    -0x8(%ebp),%eax
 838:	8b 10                	mov    (%eax),%edx
 83a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83d:	89 10                	mov    %edx,(%eax)
 83f:	eb 08                	jmp    849 <free+0xd7>
  } else
    p->s.ptr = bp;
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 55 f8             	mov    -0x8(%ebp),%edx
 847:	89 10                	mov    %edx,(%eax)
  freep = p;
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	a3 90 0c 00 00       	mov    %eax,0xc90
}
 851:	90                   	nop
 852:	c9                   	leave  
 853:	c3                   	ret    

00000854 <morecore>:

static Header*
morecore(uint nu)
{
 854:	55                   	push   %ebp
 855:	89 e5                	mov    %esp,%ebp
 857:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 85a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 861:	77 07                	ja     86a <morecore+0x16>
    nu = 4096;
 863:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 86a:	8b 45 08             	mov    0x8(%ebp),%eax
 86d:	c1 e0 03             	shl    $0x3,%eax
 870:	83 ec 0c             	sub    $0xc,%esp
 873:	50                   	push   %eax
 874:	e8 39 fc ff ff       	call   4b2 <sbrk>
 879:	83 c4 10             	add    $0x10,%esp
 87c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 87f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 883:	75 07                	jne    88c <morecore+0x38>
    return 0;
 885:	b8 00 00 00 00       	mov    $0x0,%eax
 88a:	eb 26                	jmp    8b2 <morecore+0x5e>
  hp = (Header*)p;
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 892:	8b 45 f0             	mov    -0x10(%ebp),%eax
 895:	8b 55 08             	mov    0x8(%ebp),%edx
 898:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 89b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89e:	83 c0 08             	add    $0x8,%eax
 8a1:	83 ec 0c             	sub    $0xc,%esp
 8a4:	50                   	push   %eax
 8a5:	e8 c8 fe ff ff       	call   772 <free>
 8aa:	83 c4 10             	add    $0x10,%esp
  return freep;
 8ad:	a1 90 0c 00 00       	mov    0xc90,%eax
}
 8b2:	c9                   	leave  
 8b3:	c3                   	ret    

000008b4 <malloc>:

void*
malloc(uint nbytes)
{
 8b4:	55                   	push   %ebp
 8b5:	89 e5                	mov    %esp,%ebp
 8b7:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ba:	8b 45 08             	mov    0x8(%ebp),%eax
 8bd:	83 c0 07             	add    $0x7,%eax
 8c0:	c1 e8 03             	shr    $0x3,%eax
 8c3:	83 c0 01             	add    $0x1,%eax
 8c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c9:	a1 90 0c 00 00       	mov    0xc90,%eax
 8ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8d5:	75 23                	jne    8fa <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8d7:	c7 45 f0 88 0c 00 00 	movl   $0xc88,-0x10(%ebp)
 8de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e1:	a3 90 0c 00 00       	mov    %eax,0xc90
 8e6:	a1 90 0c 00 00       	mov    0xc90,%eax
 8eb:	a3 88 0c 00 00       	mov    %eax,0xc88
    base.s.size = 0;
 8f0:	c7 05 8c 0c 00 00 00 	movl   $0x0,0xc8c
 8f7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fd:	8b 00                	mov    (%eax),%eax
 8ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 902:	8b 45 f4             	mov    -0xc(%ebp),%eax
 905:	8b 40 04             	mov    0x4(%eax),%eax
 908:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 90b:	72 4d                	jb     95a <malloc+0xa6>
      if(p->s.size == nunits)
 90d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 910:	8b 40 04             	mov    0x4(%eax),%eax
 913:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 916:	75 0c                	jne    924 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 10                	mov    (%eax),%edx
 91d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 920:	89 10                	mov    %edx,(%eax)
 922:	eb 26                	jmp    94a <malloc+0x96>
      else {
        p->s.size -= nunits;
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 40 04             	mov    0x4(%eax),%eax
 92a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 92d:	89 c2                	mov    %eax,%edx
 92f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 932:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 935:	8b 45 f4             	mov    -0xc(%ebp),%eax
 938:	8b 40 04             	mov    0x4(%eax),%eax
 93b:	c1 e0 03             	shl    $0x3,%eax
 93e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 941:	8b 45 f4             	mov    -0xc(%ebp),%eax
 944:	8b 55 ec             	mov    -0x14(%ebp),%edx
 947:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 94a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94d:	a3 90 0c 00 00       	mov    %eax,0xc90
      return (void*)(p + 1);
 952:	8b 45 f4             	mov    -0xc(%ebp),%eax
 955:	83 c0 08             	add    $0x8,%eax
 958:	eb 3b                	jmp    995 <malloc+0xe1>
    }
    if(p == freep)
 95a:	a1 90 0c 00 00       	mov    0xc90,%eax
 95f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 962:	75 1e                	jne    982 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 964:	83 ec 0c             	sub    $0xc,%esp
 967:	ff 75 ec             	pushl  -0x14(%ebp)
 96a:	e8 e5 fe ff ff       	call   854 <morecore>
 96f:	83 c4 10             	add    $0x10,%esp
 972:	89 45 f4             	mov    %eax,-0xc(%ebp)
 975:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 979:	75 07                	jne    982 <malloc+0xce>
        return 0;
 97b:	b8 00 00 00 00       	mov    $0x0,%eax
 980:	eb 13                	jmp    995 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	8b 45 f4             	mov    -0xc(%ebp),%eax
 985:	89 45 f0             	mov    %eax,-0x10(%ebp)
 988:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98b:	8b 00                	mov    (%eax),%eax
 98d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 990:	e9 6d ff ff ff       	jmp    902 <malloc+0x4e>
}
 995:	c9                   	leave  
 996:	c3                   	ret    
