
_chmod:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P5
#include "types.h"
#include "user.h"
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
   f:	83 ec 20             	sub    $0x20,%esp
  12:	89 cb                	mov    %ecx,%ebx
  char file[16];
  int perm;

  if(!argv[2] || !argv[1]){
  14:	8b 43 04             	mov    0x4(%ebx),%eax
  17:	83 c0 08             	add    $0x8,%eax
  1a:	8b 00                	mov    (%eax),%eax
  1c:	85 c0                	test   %eax,%eax
  1e:	74 0c                	je     2c <main+0x2c>
  20:	8b 43 04             	mov    0x4(%ebx),%eax
  23:	83 c0 04             	add    $0x4,%eax
  26:	8b 00                	mov    (%eax),%eax
  28:	85 c0                	test   %eax,%eax
  2a:	75 17                	jne    43 <main+0x43>
      printf(1, "\nIncorrect number of arguments provided!\n\nUse \"chmod [permission] [program]\"\n\n");
  2c:	83 ec 08             	sub    $0x8,%esp
  2f:	68 58 09 00 00       	push   $0x958
  34:	6a 01                	push   $0x1
  36:	e8 66 05 00 00       	call   5a1 <printf>
  3b:	83 c4 10             	add    $0x10,%esp
      exit();
  3e:	e8 87 03 00 00       	call   3ca <exit>
  }

  strcpy(file, argv[2]);
  43:	8b 43 04             	mov    0x4(%ebx),%eax
  46:	83 c0 08             	add    $0x8,%eax
  49:	8b 00                	mov    (%eax),%eax
  4b:	83 ec 08             	sub    $0x8,%esp
  4e:	50                   	push   %eax
  4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  52:	50                   	push   %eax
  53:	e8 6e 00 00 00       	call   c6 <strcpy>
  58:	83 c4 10             	add    $0x10,%esp

  perm = atoo(argv[1]);
  5b:	8b 43 04             	mov    0x4(%ebx),%eax
  5e:	83 c0 04             	add    $0x4,%eax
  61:	8b 00                	mov    (%eax),%eax
  63:	83 ec 0c             	sub    $0xc,%esp
  66:	50                   	push   %eax
  67:	e8 8b 02 00 00       	call   2f7 <atoo>
  6c:	83 c4 10             	add    $0x10,%esp
  6f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(chmod(file, perm) == -1)
  72:	83 ec 08             	sub    $0x8,%esp
  75:	ff 75 f4             	pushl  -0xc(%ebp)
  78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  7b:	50                   	push   %eax
  7c:	e8 31 04 00 00       	call   4b2 <chmod>
  81:	83 c4 10             	add    $0x10,%esp
  84:	83 f8 ff             	cmp    $0xffffffff,%eax
  87:	75 12                	jne    9b <main+0x9b>
      printf(1, "\nError\n");
  89:	83 ec 08             	sub    $0x8,%esp
  8c:	68 a7 09 00 00       	push   $0x9a7
  91:	6a 01                	push   $0x1
  93:	e8 09 05 00 00       	call   5a1 <printf>
  98:	83 c4 10             	add    $0x10,%esp

  exit();
  9b:	e8 2a 03 00 00       	call   3ca <exit>

000000a0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	57                   	push   %edi
  a4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a8:	8b 55 10             	mov    0x10(%ebp),%edx
  ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  ae:	89 cb                	mov    %ecx,%ebx
  b0:	89 df                	mov    %ebx,%edi
  b2:	89 d1                	mov    %edx,%ecx
  b4:	fc                   	cld    
  b5:	f3 aa                	rep stos %al,%es:(%edi)
  b7:	89 ca                	mov    %ecx,%edx
  b9:	89 fb                	mov    %edi,%ebx
  bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  be:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  c1:	90                   	nop
  c2:	5b                   	pop    %ebx
  c3:	5f                   	pop    %edi
  c4:	5d                   	pop    %ebp
  c5:	c3                   	ret    

000000c6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c6:	55                   	push   %ebp
  c7:	89 e5                	mov    %esp,%ebp
  c9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  cc:	8b 45 08             	mov    0x8(%ebp),%eax
  cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  d2:	90                   	nop
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	8d 50 01             	lea    0x1(%eax),%edx
  d9:	89 55 08             	mov    %edx,0x8(%ebp)
  dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  df:	8d 4a 01             	lea    0x1(%edx),%ecx
  e2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  e5:	0f b6 12             	movzbl (%edx),%edx
  e8:	88 10                	mov    %dl,(%eax)
  ea:	0f b6 00             	movzbl (%eax),%eax
  ed:	84 c0                	test   %al,%al
  ef:	75 e2                	jne    d3 <strcpy+0xd>
    ;
  return os;
  f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f4:	c9                   	leave  
  f5:	c3                   	ret    

000000f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  f9:	eb 08                	jmp    103 <strcmp+0xd>
    p++, q++;
  fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 103:	8b 45 08             	mov    0x8(%ebp),%eax
 106:	0f b6 00             	movzbl (%eax),%eax
 109:	84 c0                	test   %al,%al
 10b:	74 10                	je     11d <strcmp+0x27>
 10d:	8b 45 08             	mov    0x8(%ebp),%eax
 110:	0f b6 10             	movzbl (%eax),%edx
 113:	8b 45 0c             	mov    0xc(%ebp),%eax
 116:	0f b6 00             	movzbl (%eax),%eax
 119:	38 c2                	cmp    %al,%dl
 11b:	74 de                	je     fb <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	0f b6 00             	movzbl (%eax),%eax
 123:	0f b6 d0             	movzbl %al,%edx
 126:	8b 45 0c             	mov    0xc(%ebp),%eax
 129:	0f b6 00             	movzbl (%eax),%eax
 12c:	0f b6 c0             	movzbl %al,%eax
 12f:	29 c2                	sub    %eax,%edx
 131:	89 d0                	mov    %edx,%eax
}
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strlen>:

uint
strlen(char *s)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 13b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 142:	eb 04                	jmp    148 <strlen+0x13>
 144:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 148:	8b 55 fc             	mov    -0x4(%ebp),%edx
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	01 d0                	add    %edx,%eax
 150:	0f b6 00             	movzbl (%eax),%eax
 153:	84 c0                	test   %al,%al
 155:	75 ed                	jne    144 <strlen+0xf>
    ;
  return n;
 157:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 15a:	c9                   	leave  
 15b:	c3                   	ret    

0000015c <memset>:

void*
memset(void *dst, int c, uint n)
{
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 15f:	8b 45 10             	mov    0x10(%ebp),%eax
 162:	50                   	push   %eax
 163:	ff 75 0c             	pushl  0xc(%ebp)
 166:	ff 75 08             	pushl  0x8(%ebp)
 169:	e8 32 ff ff ff       	call   a0 <stosb>
 16e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 171:	8b 45 08             	mov    0x8(%ebp),%eax
}
 174:	c9                   	leave  
 175:	c3                   	ret    

00000176 <strchr>:

char*
strchr(const char *s, char c)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	83 ec 04             	sub    $0x4,%esp
 17c:	8b 45 0c             	mov    0xc(%ebp),%eax
 17f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 182:	eb 14                	jmp    198 <strchr+0x22>
    if(*s == c)
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	0f b6 00             	movzbl (%eax),%eax
 18a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 18d:	75 05                	jne    194 <strchr+0x1e>
      return (char*)s;
 18f:	8b 45 08             	mov    0x8(%ebp),%eax
 192:	eb 13                	jmp    1a7 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 194:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	84 c0                	test   %al,%al
 1a0:	75 e2                	jne    184 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a7:	c9                   	leave  
 1a8:	c3                   	ret    

000001a9 <gets>:

char*
gets(char *buf, int max)
{
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b6:	eb 42                	jmp    1fa <gets+0x51>
    cc = read(0, &c, 1);
 1b8:	83 ec 04             	sub    $0x4,%esp
 1bb:	6a 01                	push   $0x1
 1bd:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c0:	50                   	push   %eax
 1c1:	6a 00                	push   $0x0
 1c3:	e8 1a 02 00 00       	call   3e2 <read>
 1c8:	83 c4 10             	add    $0x10,%esp
 1cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d2:	7e 33                	jle    207 <gets+0x5e>
      break;
    buf[i++] = c;
 1d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d7:	8d 50 01             	lea    0x1(%eax),%edx
 1da:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1dd:	89 c2                	mov    %eax,%edx
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	01 c2                	add    %eax,%edx
 1e4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ee:	3c 0a                	cmp    $0xa,%al
 1f0:	74 16                	je     208 <gets+0x5f>
 1f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f6:	3c 0d                	cmp    $0xd,%al
 1f8:	74 0e                	je     208 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fd:	83 c0 01             	add    $0x1,%eax
 200:	3b 45 0c             	cmp    0xc(%ebp),%eax
 203:	7c b3                	jl     1b8 <gets+0xf>
 205:	eb 01                	jmp    208 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 207:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 208:	8b 55 f4             	mov    -0xc(%ebp),%edx
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	01 d0                	add    %edx,%eax
 210:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 213:	8b 45 08             	mov    0x8(%ebp),%eax
}
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <stat>:

int
stat(char *n, struct stat *st)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21e:	83 ec 08             	sub    $0x8,%esp
 221:	6a 00                	push   $0x0
 223:	ff 75 08             	pushl  0x8(%ebp)
 226:	e8 df 01 00 00       	call   40a <open>
 22b:	83 c4 10             	add    $0x10,%esp
 22e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 231:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 235:	79 07                	jns    23e <stat+0x26>
    return -1;
 237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 23c:	eb 25                	jmp    263 <stat+0x4b>
  r = fstat(fd, st);
 23e:	83 ec 08             	sub    $0x8,%esp
 241:	ff 75 0c             	pushl  0xc(%ebp)
 244:	ff 75 f4             	pushl  -0xc(%ebp)
 247:	e8 d6 01 00 00       	call   422 <fstat>
 24c:	83 c4 10             	add    $0x10,%esp
 24f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 252:	83 ec 0c             	sub    $0xc,%esp
 255:	ff 75 f4             	pushl  -0xc(%ebp)
 258:	e8 95 01 00 00       	call   3f2 <close>
 25d:	83 c4 10             	add    $0x10,%esp
  return r;
 260:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    

00000265 <atoi>:

int
atoi(const char *s)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
 268:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 26b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 272:	eb 04                	jmp    278 <atoi+0x13>
 274:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	0f b6 00             	movzbl (%eax),%eax
 27e:	3c 20                	cmp    $0x20,%al
 280:	74 f2                	je     274 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	0f b6 00             	movzbl (%eax),%eax
 288:	3c 2d                	cmp    $0x2d,%al
 28a:	75 07                	jne    293 <atoi+0x2e>
 28c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 291:	eb 05                	jmp    298 <atoi+0x33>
 293:	b8 01 00 00 00       	mov    $0x1,%eax
 298:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 2b                	cmp    $0x2b,%al
 2a3:	74 0a                	je     2af <atoi+0x4a>
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	0f b6 00             	movzbl (%eax),%eax
 2ab:	3c 2d                	cmp    $0x2d,%al
 2ad:	75 2b                	jne    2da <atoi+0x75>
    s++;
 2af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 2b3:	eb 25                	jmp    2da <atoi+0x75>
    n = n*10 + *s++ - '0';
 2b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2b8:	89 d0                	mov    %edx,%eax
 2ba:	c1 e0 02             	shl    $0x2,%eax
 2bd:	01 d0                	add    %edx,%eax
 2bf:	01 c0                	add    %eax,%eax
 2c1:	89 c1                	mov    %eax,%ecx
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
 2c6:	8d 50 01             	lea    0x1(%eax),%edx
 2c9:	89 55 08             	mov    %edx,0x8(%ebp)
 2cc:	0f b6 00             	movzbl (%eax),%eax
 2cf:	0f be c0             	movsbl %al,%eax
 2d2:	01 c8                	add    %ecx,%eax
 2d4:	83 e8 30             	sub    $0x30,%eax
 2d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	0f b6 00             	movzbl (%eax),%eax
 2e0:	3c 2f                	cmp    $0x2f,%al
 2e2:	7e 0a                	jle    2ee <atoi+0x89>
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	0f b6 00             	movzbl (%eax),%eax
 2ea:	3c 39                	cmp    $0x39,%al
 2ec:	7e c7                	jle    2b5 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 2ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2f1:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 2f5:	c9                   	leave  
 2f6:	c3                   	ret    

000002f7 <atoo>:

int
atoo(const char *s)
{
 2f7:	55                   	push   %ebp
 2f8:	89 e5                	mov    %esp,%ebp
 2fa:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 304:	eb 04                	jmp    30a <atoo+0x13>
 306:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	3c 20                	cmp    $0x20,%al
 312:	74 f2                	je     306 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	3c 2d                	cmp    $0x2d,%al
 31c:	75 07                	jne    325 <atoo+0x2e>
 31e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 323:	eb 05                	jmp    32a <atoo+0x33>
 325:	b8 01 00 00 00       	mov    $0x1,%eax
 32a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	0f b6 00             	movzbl (%eax),%eax
 333:	3c 2b                	cmp    $0x2b,%al
 335:	74 0a                	je     341 <atoo+0x4a>
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	0f b6 00             	movzbl (%eax),%eax
 33d:	3c 2d                	cmp    $0x2d,%al
 33f:	75 27                	jne    368 <atoo+0x71>
    s++;
 341:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 345:	eb 21                	jmp    368 <atoo+0x71>
    n = n*8 + *s++ - '0';
 347:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34a:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	8d 50 01             	lea    0x1(%eax),%edx
 357:	89 55 08             	mov    %edx,0x8(%ebp)
 35a:	0f b6 00             	movzbl (%eax),%eax
 35d:	0f be c0             	movsbl %al,%eax
 360:	01 c8                	add    %ecx,%eax
 362:	83 e8 30             	sub    $0x30,%eax
 365:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	0f b6 00             	movzbl (%eax),%eax
 36e:	3c 2f                	cmp    $0x2f,%al
 370:	7e 0a                	jle    37c <atoo+0x85>
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	0f b6 00             	movzbl (%eax),%eax
 378:	3c 37                	cmp    $0x37,%al
 37a:	7e cb                	jle    347 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 37c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 37f:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 383:	c9                   	leave  
 384:	c3                   	ret    

00000385 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 385:	55                   	push   %ebp
 386:	89 e5                	mov    %esp,%ebp
 388:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 391:	8b 45 0c             	mov    0xc(%ebp),%eax
 394:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 397:	eb 17                	jmp    3b0 <memmove+0x2b>
    *dst++ = *src++;
 399:	8b 45 fc             	mov    -0x4(%ebp),%eax
 39c:	8d 50 01             	lea    0x1(%eax),%edx
 39f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3a2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3a5:	8d 4a 01             	lea    0x1(%edx),%ecx
 3a8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3ab:	0f b6 12             	movzbl (%edx),%edx
 3ae:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3b0:	8b 45 10             	mov    0x10(%ebp),%eax
 3b3:	8d 50 ff             	lea    -0x1(%eax),%edx
 3b6:	89 55 10             	mov    %edx,0x10(%ebp)
 3b9:	85 c0                	test   %eax,%eax
 3bb:	7f dc                	jg     399 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c0:	c9                   	leave  
 3c1:	c3                   	ret    

000003c2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3c2:	b8 01 00 00 00       	mov    $0x1,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <exit>:
SYSCALL(exit)
 3ca:	b8 02 00 00 00       	mov    $0x2,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <wait>:
SYSCALL(wait)
 3d2:	b8 03 00 00 00       	mov    $0x3,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <pipe>:
SYSCALL(pipe)
 3da:	b8 04 00 00 00       	mov    $0x4,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <read>:
SYSCALL(read)
 3e2:	b8 05 00 00 00       	mov    $0x5,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <write>:
SYSCALL(write)
 3ea:	b8 10 00 00 00       	mov    $0x10,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <close>:
SYSCALL(close)
 3f2:	b8 15 00 00 00       	mov    $0x15,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <kill>:
SYSCALL(kill)
 3fa:	b8 06 00 00 00       	mov    $0x6,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <exec>:
SYSCALL(exec)
 402:	b8 07 00 00 00       	mov    $0x7,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <open>:
SYSCALL(open)
 40a:	b8 0f 00 00 00       	mov    $0xf,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <mknod>:
SYSCALL(mknod)
 412:	b8 11 00 00 00       	mov    $0x11,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <unlink>:
SYSCALL(unlink)
 41a:	b8 12 00 00 00       	mov    $0x12,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <fstat>:
SYSCALL(fstat)
 422:	b8 08 00 00 00       	mov    $0x8,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <link>:
SYSCALL(link)
 42a:	b8 13 00 00 00       	mov    $0x13,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <mkdir>:
SYSCALL(mkdir)
 432:	b8 14 00 00 00       	mov    $0x14,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <chdir>:
SYSCALL(chdir)
 43a:	b8 09 00 00 00       	mov    $0x9,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <dup>:
SYSCALL(dup)
 442:	b8 0a 00 00 00       	mov    $0xa,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <getpid>:
SYSCALL(getpid)
 44a:	b8 0b 00 00 00       	mov    $0xb,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <sbrk>:
SYSCALL(sbrk)
 452:	b8 0c 00 00 00       	mov    $0xc,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <sleep>:
SYSCALL(sleep)
 45a:	b8 0d 00 00 00       	mov    $0xd,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <uptime>:
SYSCALL(uptime)
 462:	b8 0e 00 00 00       	mov    $0xe,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <halt>:
SYSCALL(halt)
 46a:	b8 16 00 00 00       	mov    $0x16,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <date>:
SYSCALL(date)
 472:	b8 17 00 00 00       	mov    $0x17,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <getuid>:
SYSCALL(getuid)
 47a:	b8 18 00 00 00       	mov    $0x18,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <getgid>:
SYSCALL(getgid)
 482:	b8 19 00 00 00       	mov    $0x19,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <getppid>:
SYSCALL(getppid)
 48a:	b8 1a 00 00 00       	mov    $0x1a,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <setuid>:
SYSCALL(setuid)
 492:	b8 1b 00 00 00       	mov    $0x1b,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <setgid>:
SYSCALL(setgid)
 49a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <getprocs>:
SYSCALL(getprocs)
 4a2:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <setpriority>:
SYSCALL(setpriority)
 4aa:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <chmod>:
SYSCALL(chmod)
 4b2:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <chown>:
SYSCALL(chown)
 4ba:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <chgrp>:
SYSCALL(chgrp)
 4c2:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4ca:	55                   	push   %ebp
 4cb:	89 e5                	mov    %esp,%ebp
 4cd:	83 ec 18             	sub    $0x18,%esp
 4d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4d6:	83 ec 04             	sub    $0x4,%esp
 4d9:	6a 01                	push   $0x1
 4db:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4de:	50                   	push   %eax
 4df:	ff 75 08             	pushl  0x8(%ebp)
 4e2:	e8 03 ff ff ff       	call   3ea <write>
 4e7:	83 c4 10             	add    $0x10,%esp
}
 4ea:	90                   	nop
 4eb:	c9                   	leave  
 4ec:	c3                   	ret    

000004ed <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ed:	55                   	push   %ebp
 4ee:	89 e5                	mov    %esp,%ebp
 4f0:	53                   	push   %ebx
 4f1:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4fb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4ff:	74 17                	je     518 <printint+0x2b>
 501:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 505:	79 11                	jns    518 <printint+0x2b>
    neg = 1;
 507:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 50e:	8b 45 0c             	mov    0xc(%ebp),%eax
 511:	f7 d8                	neg    %eax
 513:	89 45 ec             	mov    %eax,-0x14(%ebp)
 516:	eb 06                	jmp    51e <printint+0x31>
  } else {
    x = xx;
 518:	8b 45 0c             	mov    0xc(%ebp),%eax
 51b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 51e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 525:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 528:	8d 41 01             	lea    0x1(%ecx),%eax
 52b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 52e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 531:	8b 45 ec             	mov    -0x14(%ebp),%eax
 534:	ba 00 00 00 00       	mov    $0x0,%edx
 539:	f7 f3                	div    %ebx
 53b:	89 d0                	mov    %edx,%eax
 53d:	0f b6 80 24 0c 00 00 	movzbl 0xc24(%eax),%eax
 544:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 548:	8b 5d 10             	mov    0x10(%ebp),%ebx
 54b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 54e:	ba 00 00 00 00       	mov    $0x0,%edx
 553:	f7 f3                	div    %ebx
 555:	89 45 ec             	mov    %eax,-0x14(%ebp)
 558:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 55c:	75 c7                	jne    525 <printint+0x38>
  if(neg)
 55e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 562:	74 2d                	je     591 <printint+0xa4>
    buf[i++] = '-';
 564:	8b 45 f4             	mov    -0xc(%ebp),%eax
 567:	8d 50 01             	lea    0x1(%eax),%edx
 56a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 56d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 572:	eb 1d                	jmp    591 <printint+0xa4>
    putc(fd, buf[i]);
 574:	8d 55 dc             	lea    -0x24(%ebp),%edx
 577:	8b 45 f4             	mov    -0xc(%ebp),%eax
 57a:	01 d0                	add    %edx,%eax
 57c:	0f b6 00             	movzbl (%eax),%eax
 57f:	0f be c0             	movsbl %al,%eax
 582:	83 ec 08             	sub    $0x8,%esp
 585:	50                   	push   %eax
 586:	ff 75 08             	pushl  0x8(%ebp)
 589:	e8 3c ff ff ff       	call   4ca <putc>
 58e:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 591:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 595:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 599:	79 d9                	jns    574 <printint+0x87>
    putc(fd, buf[i]);
}
 59b:	90                   	nop
 59c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 59f:	c9                   	leave  
 5a0:	c3                   	ret    

000005a1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5a1:	55                   	push   %ebp
 5a2:	89 e5                	mov    %esp,%ebp
 5a4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5a7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ae:	8d 45 0c             	lea    0xc(%ebp),%eax
 5b1:	83 c0 04             	add    $0x4,%eax
 5b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5be:	e9 59 01 00 00       	jmp    71c <printf+0x17b>
    c = fmt[i] & 0xff;
 5c3:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c9:	01 d0                	add    %edx,%eax
 5cb:	0f b6 00             	movzbl (%eax),%eax
 5ce:	0f be c0             	movsbl %al,%eax
 5d1:	25 ff 00 00 00       	and    $0xff,%eax
 5d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5dd:	75 2c                	jne    60b <printf+0x6a>
      if(c == '%'){
 5df:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e3:	75 0c                	jne    5f1 <printf+0x50>
        state = '%';
 5e5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5ec:	e9 27 01 00 00       	jmp    718 <printf+0x177>
      } else {
        putc(fd, c);
 5f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f4:	0f be c0             	movsbl %al,%eax
 5f7:	83 ec 08             	sub    $0x8,%esp
 5fa:	50                   	push   %eax
 5fb:	ff 75 08             	pushl  0x8(%ebp)
 5fe:	e8 c7 fe ff ff       	call   4ca <putc>
 603:	83 c4 10             	add    $0x10,%esp
 606:	e9 0d 01 00 00       	jmp    718 <printf+0x177>
      }
    } else if(state == '%'){
 60b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 60f:	0f 85 03 01 00 00    	jne    718 <printf+0x177>
      if(c == 'd'){
 615:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 619:	75 1e                	jne    639 <printf+0x98>
        printint(fd, *ap, 10, 1);
 61b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61e:	8b 00                	mov    (%eax),%eax
 620:	6a 01                	push   $0x1
 622:	6a 0a                	push   $0xa
 624:	50                   	push   %eax
 625:	ff 75 08             	pushl  0x8(%ebp)
 628:	e8 c0 fe ff ff       	call   4ed <printint>
 62d:	83 c4 10             	add    $0x10,%esp
        ap++;
 630:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 634:	e9 d8 00 00 00       	jmp    711 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 639:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 63d:	74 06                	je     645 <printf+0xa4>
 63f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 643:	75 1e                	jne    663 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 645:	8b 45 e8             	mov    -0x18(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	6a 00                	push   $0x0
 64c:	6a 10                	push   $0x10
 64e:	50                   	push   %eax
 64f:	ff 75 08             	pushl  0x8(%ebp)
 652:	e8 96 fe ff ff       	call   4ed <printint>
 657:	83 c4 10             	add    $0x10,%esp
        ap++;
 65a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65e:	e9 ae 00 00 00       	jmp    711 <printf+0x170>
      } else if(c == 's'){
 663:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 667:	75 43                	jne    6ac <printf+0x10b>
        s = (char*)*ap;
 669:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 671:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 675:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 679:	75 25                	jne    6a0 <printf+0xff>
          s = "(null)";
 67b:	c7 45 f4 af 09 00 00 	movl   $0x9af,-0xc(%ebp)
        while(*s != 0){
 682:	eb 1c                	jmp    6a0 <printf+0xff>
          putc(fd, *s);
 684:	8b 45 f4             	mov    -0xc(%ebp),%eax
 687:	0f b6 00             	movzbl (%eax),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	83 ec 08             	sub    $0x8,%esp
 690:	50                   	push   %eax
 691:	ff 75 08             	pushl  0x8(%ebp)
 694:	e8 31 fe ff ff       	call   4ca <putc>
 699:	83 c4 10             	add    $0x10,%esp
          s++;
 69c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a3:	0f b6 00             	movzbl (%eax),%eax
 6a6:	84 c0                	test   %al,%al
 6a8:	75 da                	jne    684 <printf+0xe3>
 6aa:	eb 65                	jmp    711 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ac:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6b0:	75 1d                	jne    6cf <printf+0x12e>
        putc(fd, *ap);
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	0f be c0             	movsbl %al,%eax
 6ba:	83 ec 08             	sub    $0x8,%esp
 6bd:	50                   	push   %eax
 6be:	ff 75 08             	pushl  0x8(%ebp)
 6c1:	e8 04 fe ff ff       	call   4ca <putc>
 6c6:	83 c4 10             	add    $0x10,%esp
        ap++;
 6c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6cd:	eb 42                	jmp    711 <printf+0x170>
      } else if(c == '%'){
 6cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d3:	75 17                	jne    6ec <printf+0x14b>
        putc(fd, c);
 6d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d8:	0f be c0             	movsbl %al,%eax
 6db:	83 ec 08             	sub    $0x8,%esp
 6de:	50                   	push   %eax
 6df:	ff 75 08             	pushl  0x8(%ebp)
 6e2:	e8 e3 fd ff ff       	call   4ca <putc>
 6e7:	83 c4 10             	add    $0x10,%esp
 6ea:	eb 25                	jmp    711 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ec:	83 ec 08             	sub    $0x8,%esp
 6ef:	6a 25                	push   $0x25
 6f1:	ff 75 08             	pushl  0x8(%ebp)
 6f4:	e8 d1 fd ff ff       	call   4ca <putc>
 6f9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ff:	0f be c0             	movsbl %al,%eax
 702:	83 ec 08             	sub    $0x8,%esp
 705:	50                   	push   %eax
 706:	ff 75 08             	pushl  0x8(%ebp)
 709:	e8 bc fd ff ff       	call   4ca <putc>
 70e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 711:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 718:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 71c:	8b 55 0c             	mov    0xc(%ebp),%edx
 71f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 722:	01 d0                	add    %edx,%eax
 724:	0f b6 00             	movzbl (%eax),%eax
 727:	84 c0                	test   %al,%al
 729:	0f 85 94 fe ff ff    	jne    5c3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 72f:	90                   	nop
 730:	c9                   	leave  
 731:	c3                   	ret    

00000732 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 732:	55                   	push   %ebp
 733:	89 e5                	mov    %esp,%ebp
 735:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 738:	8b 45 08             	mov    0x8(%ebp),%eax
 73b:	83 e8 08             	sub    $0x8,%eax
 73e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 741:	a1 40 0c 00 00       	mov    0xc40,%eax
 746:	89 45 fc             	mov    %eax,-0x4(%ebp)
 749:	eb 24                	jmp    76f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 00                	mov    (%eax),%eax
 750:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 753:	77 12                	ja     767 <free+0x35>
 755:	8b 45 f8             	mov    -0x8(%ebp),%eax
 758:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 75b:	77 24                	ja     781 <free+0x4f>
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 765:	77 1a                	ja     781 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 767:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76a:	8b 00                	mov    (%eax),%eax
 76c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 775:	76 d4                	jbe    74b <free+0x19>
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 77f:	76 ca                	jbe    74b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 781:	8b 45 f8             	mov    -0x8(%ebp),%eax
 784:	8b 40 04             	mov    0x4(%eax),%eax
 787:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 791:	01 c2                	add    %eax,%edx
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	8b 00                	mov    (%eax),%eax
 798:	39 c2                	cmp    %eax,%edx
 79a:	75 24                	jne    7c0 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 79c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79f:	8b 50 04             	mov    0x4(%eax),%edx
 7a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a5:	8b 00                	mov    (%eax),%eax
 7a7:	8b 40 04             	mov    0x4(%eax),%eax
 7aa:	01 c2                	add    %eax,%edx
 7ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7af:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b5:	8b 00                	mov    (%eax),%eax
 7b7:	8b 10                	mov    (%eax),%edx
 7b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bc:	89 10                	mov    %edx,(%eax)
 7be:	eb 0a                	jmp    7ca <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c3:	8b 10                	mov    (%eax),%edx
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cd:	8b 40 04             	mov    0x4(%eax),%eax
 7d0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7da:	01 d0                	add    %edx,%eax
 7dc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7df:	75 20                	jne    801 <free+0xcf>
    p->s.size += bp->s.size;
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 50 04             	mov    0x4(%eax),%edx
 7e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ea:	8b 40 04             	mov    0x4(%eax),%eax
 7ed:	01 c2                	add    %eax,%edx
 7ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f8:	8b 10                	mov    (%eax),%edx
 7fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fd:	89 10                	mov    %edx,(%eax)
 7ff:	eb 08                	jmp    809 <free+0xd7>
  } else
    p->s.ptr = bp;
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 55 f8             	mov    -0x8(%ebp),%edx
 807:	89 10                	mov    %edx,(%eax)
  freep = p;
 809:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80c:	a3 40 0c 00 00       	mov    %eax,0xc40
}
 811:	90                   	nop
 812:	c9                   	leave  
 813:	c3                   	ret    

00000814 <morecore>:

static Header*
morecore(uint nu)
{
 814:	55                   	push   %ebp
 815:	89 e5                	mov    %esp,%ebp
 817:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 81a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 821:	77 07                	ja     82a <morecore+0x16>
    nu = 4096;
 823:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 82a:	8b 45 08             	mov    0x8(%ebp),%eax
 82d:	c1 e0 03             	shl    $0x3,%eax
 830:	83 ec 0c             	sub    $0xc,%esp
 833:	50                   	push   %eax
 834:	e8 19 fc ff ff       	call   452 <sbrk>
 839:	83 c4 10             	add    $0x10,%esp
 83c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 83f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 843:	75 07                	jne    84c <morecore+0x38>
    return 0;
 845:	b8 00 00 00 00       	mov    $0x0,%eax
 84a:	eb 26                	jmp    872 <morecore+0x5e>
  hp = (Header*)p;
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 852:	8b 45 f0             	mov    -0x10(%ebp),%eax
 855:	8b 55 08             	mov    0x8(%ebp),%edx
 858:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 85b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85e:	83 c0 08             	add    $0x8,%eax
 861:	83 ec 0c             	sub    $0xc,%esp
 864:	50                   	push   %eax
 865:	e8 c8 fe ff ff       	call   732 <free>
 86a:	83 c4 10             	add    $0x10,%esp
  return freep;
 86d:	a1 40 0c 00 00       	mov    0xc40,%eax
}
 872:	c9                   	leave  
 873:	c3                   	ret    

00000874 <malloc>:

void*
malloc(uint nbytes)
{
 874:	55                   	push   %ebp
 875:	89 e5                	mov    %esp,%ebp
 877:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87a:	8b 45 08             	mov    0x8(%ebp),%eax
 87d:	83 c0 07             	add    $0x7,%eax
 880:	c1 e8 03             	shr    $0x3,%eax
 883:	83 c0 01             	add    $0x1,%eax
 886:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 889:	a1 40 0c 00 00       	mov    0xc40,%eax
 88e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 891:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 895:	75 23                	jne    8ba <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 897:	c7 45 f0 38 0c 00 00 	movl   $0xc38,-0x10(%ebp)
 89e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a1:	a3 40 0c 00 00       	mov    %eax,0xc40
 8a6:	a1 40 0c 00 00       	mov    0xc40,%eax
 8ab:	a3 38 0c 00 00       	mov    %eax,0xc38
    base.s.size = 0;
 8b0:	c7 05 3c 0c 00 00 00 	movl   $0x0,0xc3c
 8b7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	8b 40 04             	mov    0x4(%eax),%eax
 8c8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8cb:	72 4d                	jb     91a <malloc+0xa6>
      if(p->s.size == nunits)
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	8b 40 04             	mov    0x4(%eax),%eax
 8d3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8d6:	75 0c                	jne    8e4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8db:	8b 10                	mov    (%eax),%edx
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	89 10                	mov    %edx,(%eax)
 8e2:	eb 26                	jmp    90a <malloc+0x96>
      else {
        p->s.size -= nunits;
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	8b 40 04             	mov    0x4(%eax),%eax
 8ea:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8ed:	89 c2                	mov    %eax,%edx
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	8b 40 04             	mov    0x4(%eax),%eax
 8fb:	c1 e0 03             	shl    $0x3,%eax
 8fe:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 901:	8b 45 f4             	mov    -0xc(%ebp),%eax
 904:	8b 55 ec             	mov    -0x14(%ebp),%edx
 907:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 90a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90d:	a3 40 0c 00 00       	mov    %eax,0xc40
      return (void*)(p + 1);
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	83 c0 08             	add    $0x8,%eax
 918:	eb 3b                	jmp    955 <malloc+0xe1>
    }
    if(p == freep)
 91a:	a1 40 0c 00 00       	mov    0xc40,%eax
 91f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 922:	75 1e                	jne    942 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 924:	83 ec 0c             	sub    $0xc,%esp
 927:	ff 75 ec             	pushl  -0x14(%ebp)
 92a:	e8 e5 fe ff ff       	call   814 <morecore>
 92f:	83 c4 10             	add    $0x10,%esp
 932:	89 45 f4             	mov    %eax,-0xc(%ebp)
 935:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 939:	75 07                	jne    942 <malloc+0xce>
        return 0;
 93b:	b8 00 00 00 00       	mov    $0x0,%eax
 940:	eb 13                	jmp    955 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 942:	8b 45 f4             	mov    -0xc(%ebp),%eax
 945:	89 45 f0             	mov    %eax,-0x10(%ebp)
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	8b 00                	mov    (%eax),%eax
 94d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 950:	e9 6d ff ff ff       	jmp    8c2 <malloc+0x4e>
}
 955:	c9                   	leave  
 956:	c3                   	ret    
