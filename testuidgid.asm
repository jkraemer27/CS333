
_testuidgid:     file format elf32-i386


Disassembly of section .text:

00000000 <testuidgid>:
#include "types.h"
#include "user.h"

int
testuidgid(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
    uint uid, gid, ppid;


    uid = getuid();
   6:	e8 6e 05 00 00       	call   579 <getuid>
   b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    printf(2, "Current_UID_is: %d\n\n", uid);
   e:	83 ec 04             	sub    $0x4,%esp
  11:	ff 75 f4             	pushl  -0xc(%ebp)
  14:	68 36 0a 00 00       	push   $0xa36
  19:	6a 02                	push   $0x2
  1b:	e8 60 06 00 00       	call   680 <printf>
  20:	83 c4 10             	add    $0x10,%esp

    printf(2, "Setting_UID_to_100\n\n");
  23:	83 ec 08             	sub    $0x8,%esp
  26:	68 4b 0a 00 00       	push   $0xa4b
  2b:	6a 02                	push   $0x2
  2d:	e8 4e 06 00 00       	call   680 <printf>
  32:	83 c4 10             	add    $0x10,%esp
    if (setuid(100) < 0)
  35:	83 ec 0c             	sub    $0xc,%esp
  38:	6a 64                	push   $0x64
  3a:	e8 52 05 00 00       	call   591 <setuid>
  3f:	83 c4 10             	add    $0x10,%esp
	printf(2, "Setting_UID_to_100 Failed!!\n\n");
	
    printf(2, "Setting_UID_to_33333\n\n");
  42:	83 ec 08             	sub    $0x8,%esp
  45:	68 60 0a 00 00       	push   $0xa60
  4a:	6a 02                	push   $0x2
  4c:	e8 2f 06 00 00       	call   680 <printf>
  51:	83 c4 10             	add    $0x10,%esp
    if (setuid(33333) < 0)
  54:	83 ec 0c             	sub    $0xc,%esp
  57:	68 35 82 00 00       	push   $0x8235
  5c:	e8 30 05 00 00       	call   591 <setuid>
  61:	83 c4 10             	add    $0x10,%esp
	printf(2, "Setting_UID_to_33333 Failed!!\n\n");

    uid = getuid();
  64:	e8 10 05 00 00       	call   579 <getuid>
  69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    printf(2, "Current_UID_is: %d\n\n", uid);
  6c:	83 ec 04             	sub    $0x4,%esp
  6f:	ff 75 f4             	pushl  -0xc(%ebp)
  72:	68 36 0a 00 00       	push   $0xa36
  77:	6a 02                	push   $0x2
  79:	e8 02 06 00 00       	call   680 <printf>
  7e:	83 c4 10             	add    $0x10,%esp

////////////////

    gid = getgid();
  81:	e8 fb 04 00 00       	call   581 <getgid>
  86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(2, "Current_GID_is: %d\n\n", gid);
  89:	83 ec 04             	sub    $0x4,%esp
  8c:	ff 75 f0             	pushl  -0x10(%ebp)
  8f:	68 77 0a 00 00       	push   $0xa77
  94:	6a 02                	push   $0x2
  96:	e8 e5 05 00 00       	call   680 <printf>
  9b:	83 c4 10             	add    $0x10,%esp

    printf(2, "Setting_GID_to_100\n\n");
  9e:	83 ec 08             	sub    $0x8,%esp
  a1:	68 8c 0a 00 00       	push   $0xa8c
  a6:	6a 02                	push   $0x2
  a8:	e8 d3 05 00 00       	call   680 <printf>
  ad:	83 c4 10             	add    $0x10,%esp
    if (setgid(100) < 0)
  b0:	83 ec 0c             	sub    $0xc,%esp
  b3:	6a 64                	push   $0x64
  b5:	e8 df 04 00 00       	call   599 <setgid>
  ba:	83 c4 10             	add    $0x10,%esp
	printf(2, "Setting_GID_to_100 Failed!!\n\n");

    printf(2, "Setting_GID_to_33333\n\n");
  bd:	83 ec 08             	sub    $0x8,%esp
  c0:	68 a1 0a 00 00       	push   $0xaa1
  c5:	6a 02                	push   $0x2
  c7:	e8 b4 05 00 00       	call   680 <printf>
  cc:	83 c4 10             	add    $0x10,%esp
    if (setgid(33333) < 0)
  cf:	83 ec 0c             	sub    $0xc,%esp
  d2:	68 35 82 00 00       	push   $0x8235
  d7:	e8 bd 04 00 00       	call   599 <setgid>
  dc:	83 c4 10             	add    $0x10,%esp
	printf(2, "Setting_GID_to_33333 Failed!!\n\n");

    gid = getgid();
  df:	e8 9d 04 00 00       	call   581 <getgid>
  e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(2, "Current_GID_to_100\n\n", gid);
  e7:	83 ec 04             	sub    $0x4,%esp
  ea:	ff 75 f0             	pushl  -0x10(%ebp)
  ed:	68 b8 0a 00 00       	push   $0xab8
  f2:	6a 02                	push   $0x2
  f4:	e8 87 05 00 00       	call   680 <printf>
  f9:	83 c4 10             	add    $0x10,%esp

////////////////

    ppid = getppid();
  fc:	e8 88 04 00 00       	call   589 <getppid>
 101:	89 45 ec             	mov    %eax,-0x14(%ebp)
    printf(2, "My_parent_process_is: %d\n\n", ppid);
 104:	83 ec 04             	sub    $0x4,%esp
 107:	ff 75 ec             	pushl  -0x14(%ebp)
 10a:	68 cd 0a 00 00       	push   $0xacd
 10f:	6a 02                	push   $0x2
 111:	e8 6a 05 00 00       	call   680 <printf>
 116:	83 c4 10             	add    $0x10,%esp
    printf(2, "Done!\n\n");
 119:	83 ec 08             	sub    $0x8,%esp
 11c:	68 e8 0a 00 00       	push   $0xae8
 121:	6a 02                	push   $0x2
 123:	e8 58 05 00 00       	call   680 <printf>
 128:	83 c4 10             	add    $0x10,%esp

    int pid = fork();
 12b:	e8 91 03 00 00       	call   4c1 <fork>
 130:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(pid > 0){
 133:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 137:	7e 61                	jle    19a <testuidgid+0x19a>
      printf(1, "parent: child=%d\n\n", pid);
 139:	83 ec 04             	sub    $0x4,%esp
 13c:	ff 75 e8             	pushl  -0x18(%ebp)
 13f:	68 f0 0a 00 00       	push   $0xaf0
 144:	6a 01                	push   $0x1
 146:	e8 35 05 00 00       	call   680 <printf>
 14b:	83 c4 10             	add    $0x10,%esp
      pid = wait();
 14e:	e8 7e 03 00 00       	call   4d1 <wait>
 153:	89 45 e8             	mov    %eax,-0x18(%ebp)
      printf(1, "child %d is done\n\n", pid);
 156:	83 ec 04             	sub    $0x4,%esp
 159:	ff 75 e8             	pushl  -0x18(%ebp)
 15c:	68 03 0b 00 00       	push   $0xb03
 161:	6a 01                	push   $0x1
 163:	e8 18 05 00 00       	call   680 <printf>
 168:	83 c4 10             	add    $0x10,%esp
      ppid = getppid();
 16b:	e8 19 04 00 00       	call   589 <getppid>
 170:	89 45 ec             	mov    %eax,-0x14(%ebp)
      printf(2, "My_parent_process_is: %d\n\n", ppid);
 173:	83 ec 04             	sub    $0x4,%esp
 176:	ff 75 ec             	pushl  -0x14(%ebp)
 179:	68 cd 0a 00 00       	push   $0xacd
 17e:	6a 02                	push   $0x2
 180:	e8 fb 04 00 00       	call   680 <printf>
 185:	83 c4 10             	add    $0x10,%esp
      printf(2, "Done!\n\n");
 188:	83 ec 08             	sub    $0x8,%esp
 18b:	68 e8 0a 00 00       	push   $0xae8
 190:	6a 02                	push   $0x2
 192:	e8 e9 04 00 00       	call   680 <printf>
 197:	83 c4 10             	add    $0x10,%esp

    }

    exit();
 19a:	e8 2a 03 00 00       	call   4c9 <exit>

0000019f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	57                   	push   %edi
 1a3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1a7:	8b 55 10             	mov    0x10(%ebp),%edx
 1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ad:	89 cb                	mov    %ecx,%ebx
 1af:	89 df                	mov    %ebx,%edi
 1b1:	89 d1                	mov    %edx,%ecx
 1b3:	fc                   	cld    
 1b4:	f3 aa                	rep stos %al,%es:(%edi)
 1b6:	89 ca                	mov    %ecx,%edx
 1b8:	89 fb                	mov    %edi,%ebx
 1ba:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1bd:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1c0:	90                   	nop
 1c1:	5b                   	pop    %ebx
 1c2:	5f                   	pop    %edi
 1c3:	5d                   	pop    %ebp
 1c4:	c3                   	ret    

000001c5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1c5:	55                   	push   %ebp
 1c6:	89 e5                	mov    %esp,%ebp
 1c8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1d1:	90                   	nop
 1d2:	8b 45 08             	mov    0x8(%ebp),%eax
 1d5:	8d 50 01             	lea    0x1(%eax),%edx
 1d8:	89 55 08             	mov    %edx,0x8(%ebp)
 1db:	8b 55 0c             	mov    0xc(%ebp),%edx
 1de:	8d 4a 01             	lea    0x1(%edx),%ecx
 1e1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1e4:	0f b6 12             	movzbl (%edx),%edx
 1e7:	88 10                	mov    %dl,(%eax)
 1e9:	0f b6 00             	movzbl (%eax),%eax
 1ec:	84 c0                	test   %al,%al
 1ee:	75 e2                	jne    1d2 <strcpy+0xd>
    ;
  return os;
 1f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1f3:	c9                   	leave  
 1f4:	c3                   	ret    

000001f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1f8:	eb 08                	jmp    202 <strcmp+0xd>
    p++, q++;
 1fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1fe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 202:	8b 45 08             	mov    0x8(%ebp),%eax
 205:	0f b6 00             	movzbl (%eax),%eax
 208:	84 c0                	test   %al,%al
 20a:	74 10                	je     21c <strcmp+0x27>
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	0f b6 10             	movzbl (%eax),%edx
 212:	8b 45 0c             	mov    0xc(%ebp),%eax
 215:	0f b6 00             	movzbl (%eax),%eax
 218:	38 c2                	cmp    %al,%dl
 21a:	74 de                	je     1fa <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	0f b6 00             	movzbl (%eax),%eax
 222:	0f b6 d0             	movzbl %al,%edx
 225:	8b 45 0c             	mov    0xc(%ebp),%eax
 228:	0f b6 00             	movzbl (%eax),%eax
 22b:	0f b6 c0             	movzbl %al,%eax
 22e:	29 c2                	sub    %eax,%edx
 230:	89 d0                	mov    %edx,%eax
}
 232:	5d                   	pop    %ebp
 233:	c3                   	ret    

00000234 <strlen>:

uint
strlen(char *s)
{
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 23a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 241:	eb 04                	jmp    247 <strlen+0x13>
 243:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 247:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	01 d0                	add    %edx,%eax
 24f:	0f b6 00             	movzbl (%eax),%eax
 252:	84 c0                	test   %al,%al
 254:	75 ed                	jne    243 <strlen+0xf>
    ;
  return n;
 256:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <memset>:

void*
memset(void *dst, int c, uint n)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 25e:	8b 45 10             	mov    0x10(%ebp),%eax
 261:	50                   	push   %eax
 262:	ff 75 0c             	pushl  0xc(%ebp)
 265:	ff 75 08             	pushl  0x8(%ebp)
 268:	e8 32 ff ff ff       	call   19f <stosb>
 26d:	83 c4 0c             	add    $0xc,%esp
  return dst;
 270:	8b 45 08             	mov    0x8(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <strchr>:

char*
strchr(const char *s, char c)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 04             	sub    $0x4,%esp
 27b:	8b 45 0c             	mov    0xc(%ebp),%eax
 27e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 281:	eb 14                	jmp    297 <strchr+0x22>
    if(*s == c)
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	0f b6 00             	movzbl (%eax),%eax
 289:	3a 45 fc             	cmp    -0x4(%ebp),%al
 28c:	75 05                	jne    293 <strchr+0x1e>
      return (char*)s;
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	eb 13                	jmp    2a6 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 293:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	0f b6 00             	movzbl (%eax),%eax
 29d:	84 c0                	test   %al,%al
 29f:	75 e2                	jne    283 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2a6:	c9                   	leave  
 2a7:	c3                   	ret    

000002a8 <gets>:

char*
gets(char *buf, int max)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2b5:	eb 42                	jmp    2f9 <gets+0x51>
    cc = read(0, &c, 1);
 2b7:	83 ec 04             	sub    $0x4,%esp
 2ba:	6a 01                	push   $0x1
 2bc:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2bf:	50                   	push   %eax
 2c0:	6a 00                	push   $0x0
 2c2:	e8 1a 02 00 00       	call   4e1 <read>
 2c7:	83 c4 10             	add    $0x10,%esp
 2ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2d1:	7e 33                	jle    306 <gets+0x5e>
      break;
    buf[i++] = c;
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	8d 50 01             	lea    0x1(%eax),%edx
 2d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2dc:	89 c2                	mov    %eax,%edx
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	01 c2                	add    %eax,%edx
 2e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ed:	3c 0a                	cmp    $0xa,%al
 2ef:	74 16                	je     307 <gets+0x5f>
 2f1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2f5:	3c 0d                	cmp    $0xd,%al
 2f7:	74 0e                	je     307 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fc:	83 c0 01             	add    $0x1,%eax
 2ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
 302:	7c b3                	jl     2b7 <gets+0xf>
 304:	eb 01                	jmp    307 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 306:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 307:	8b 55 f4             	mov    -0xc(%ebp),%edx
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 312:	8b 45 08             	mov    0x8(%ebp),%eax
}
 315:	c9                   	leave  
 316:	c3                   	ret    

00000317 <stat>:

int
stat(char *n, struct stat *st)
{
 317:	55                   	push   %ebp
 318:	89 e5                	mov    %esp,%ebp
 31a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31d:	83 ec 08             	sub    $0x8,%esp
 320:	6a 00                	push   $0x0
 322:	ff 75 08             	pushl  0x8(%ebp)
 325:	e8 df 01 00 00       	call   509 <open>
 32a:	83 c4 10             	add    $0x10,%esp
 32d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 330:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 334:	79 07                	jns    33d <stat+0x26>
    return -1;
 336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 33b:	eb 25                	jmp    362 <stat+0x4b>
  r = fstat(fd, st);
 33d:	83 ec 08             	sub    $0x8,%esp
 340:	ff 75 0c             	pushl  0xc(%ebp)
 343:	ff 75 f4             	pushl  -0xc(%ebp)
 346:	e8 d6 01 00 00       	call   521 <fstat>
 34b:	83 c4 10             	add    $0x10,%esp
 34e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 351:	83 ec 0c             	sub    $0xc,%esp
 354:	ff 75 f4             	pushl  -0xc(%ebp)
 357:	e8 95 01 00 00       	call   4f1 <close>
 35c:	83 c4 10             	add    $0x10,%esp
  return r;
 35f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 362:	c9                   	leave  
 363:	c3                   	ret    

00000364 <atoi>:

int
atoi(const char *s)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 36a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 371:	eb 04                	jmp    377 <atoi+0x13>
 373:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	0f b6 00             	movzbl (%eax),%eax
 37d:	3c 20                	cmp    $0x20,%al
 37f:	74 f2                	je     373 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	0f b6 00             	movzbl (%eax),%eax
 387:	3c 2d                	cmp    $0x2d,%al
 389:	75 07                	jne    392 <atoi+0x2e>
 38b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 390:	eb 05                	jmp    397 <atoi+0x33>
 392:	b8 01 00 00 00       	mov    $0x1,%eax
 397:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	0f b6 00             	movzbl (%eax),%eax
 3a0:	3c 2b                	cmp    $0x2b,%al
 3a2:	74 0a                	je     3ae <atoi+0x4a>
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	3c 2d                	cmp    $0x2d,%al
 3ac:	75 2b                	jne    3d9 <atoi+0x75>
    s++;
 3ae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 3b2:	eb 25                	jmp    3d9 <atoi+0x75>
    n = n*10 + *s++ - '0';
 3b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b7:	89 d0                	mov    %edx,%eax
 3b9:	c1 e0 02             	shl    $0x2,%eax
 3bc:	01 d0                	add    %edx,%eax
 3be:	01 c0                	add    %eax,%eax
 3c0:	89 c1                	mov    %eax,%ecx
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	8d 50 01             	lea    0x1(%eax),%edx
 3c8:	89 55 08             	mov    %edx,0x8(%ebp)
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	0f be c0             	movsbl %al,%eax
 3d1:	01 c8                	add    %ecx,%eax
 3d3:	83 e8 30             	sub    $0x30,%eax
 3d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 3d9:	8b 45 08             	mov    0x8(%ebp),%eax
 3dc:	0f b6 00             	movzbl (%eax),%eax
 3df:	3c 2f                	cmp    $0x2f,%al
 3e1:	7e 0a                	jle    3ed <atoi+0x89>
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	3c 39                	cmp    $0x39,%al
 3eb:	7e c7                	jle    3b4 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 3ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f0:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3f4:	c9                   	leave  
 3f5:	c3                   	ret    

000003f6 <atoo>:

int
atoo(const char *s)
{
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 3fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 403:	eb 04                	jmp    409 <atoo+0x13>
 405:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 409:	8b 45 08             	mov    0x8(%ebp),%eax
 40c:	0f b6 00             	movzbl (%eax),%eax
 40f:	3c 20                	cmp    $0x20,%al
 411:	74 f2                	je     405 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	0f b6 00             	movzbl (%eax),%eax
 419:	3c 2d                	cmp    $0x2d,%al
 41b:	75 07                	jne    424 <atoo+0x2e>
 41d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 422:	eb 05                	jmp    429 <atoo+0x33>
 424:	b8 01 00 00 00       	mov    $0x1,%eax
 429:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	3c 2b                	cmp    $0x2b,%al
 434:	74 0a                	je     440 <atoo+0x4a>
 436:	8b 45 08             	mov    0x8(%ebp),%eax
 439:	0f b6 00             	movzbl (%eax),%eax
 43c:	3c 2d                	cmp    $0x2d,%al
 43e:	75 27                	jne    467 <atoo+0x71>
    s++;
 440:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 444:	eb 21                	jmp    467 <atoo+0x71>
    n = n*8 + *s++ - '0';
 446:	8b 45 fc             	mov    -0x4(%ebp),%eax
 449:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	8d 50 01             	lea    0x1(%eax),%edx
 456:	89 55 08             	mov    %edx,0x8(%ebp)
 459:	0f b6 00             	movzbl (%eax),%eax
 45c:	0f be c0             	movsbl %al,%eax
 45f:	01 c8                	add    %ecx,%eax
 461:	83 e8 30             	sub    $0x30,%eax
 464:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	3c 2f                	cmp    $0x2f,%al
 46f:	7e 0a                	jle    47b <atoo+0x85>
 471:	8b 45 08             	mov    0x8(%ebp),%eax
 474:	0f b6 00             	movzbl (%eax),%eax
 477:	3c 37                	cmp    $0x37,%al
 479:	7e cb                	jle    446 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 47b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 47e:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 482:	c9                   	leave  
 483:	c3                   	ret    

00000484 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
 487:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 490:	8b 45 0c             	mov    0xc(%ebp),%eax
 493:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 496:	eb 17                	jmp    4af <memmove+0x2b>
    *dst++ = *src++;
 498:	8b 45 fc             	mov    -0x4(%ebp),%eax
 49b:	8d 50 01             	lea    0x1(%eax),%edx
 49e:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4a1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4a4:	8d 4a 01             	lea    0x1(%edx),%ecx
 4a7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4aa:	0f b6 12             	movzbl (%edx),%edx
 4ad:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4af:	8b 45 10             	mov    0x10(%ebp),%eax
 4b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 4b5:	89 55 10             	mov    %edx,0x10(%ebp)
 4b8:	85 c0                	test   %eax,%eax
 4ba:	7f dc                	jg     498 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4bf:	c9                   	leave  
 4c0:	c3                   	ret    

000004c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4c1:	b8 01 00 00 00       	mov    $0x1,%eax
 4c6:	cd 40                	int    $0x40
 4c8:	c3                   	ret    

000004c9 <exit>:
SYSCALL(exit)
 4c9:	b8 02 00 00 00       	mov    $0x2,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	ret    

000004d1 <wait>:
SYSCALL(wait)
 4d1:	b8 03 00 00 00       	mov    $0x3,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <pipe>:
SYSCALL(pipe)
 4d9:	b8 04 00 00 00       	mov    $0x4,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <read>:
SYSCALL(read)
 4e1:	b8 05 00 00 00       	mov    $0x5,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <write>:
SYSCALL(write)
 4e9:	b8 10 00 00 00       	mov    $0x10,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <close>:
SYSCALL(close)
 4f1:	b8 15 00 00 00       	mov    $0x15,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <kill>:
SYSCALL(kill)
 4f9:	b8 06 00 00 00       	mov    $0x6,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	ret    

00000501 <exec>:
SYSCALL(exec)
 501:	b8 07 00 00 00       	mov    $0x7,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	ret    

00000509 <open>:
SYSCALL(open)
 509:	b8 0f 00 00 00       	mov    $0xf,%eax
 50e:	cd 40                	int    $0x40
 510:	c3                   	ret    

00000511 <mknod>:
SYSCALL(mknod)
 511:	b8 11 00 00 00       	mov    $0x11,%eax
 516:	cd 40                	int    $0x40
 518:	c3                   	ret    

00000519 <unlink>:
SYSCALL(unlink)
 519:	b8 12 00 00 00       	mov    $0x12,%eax
 51e:	cd 40                	int    $0x40
 520:	c3                   	ret    

00000521 <fstat>:
SYSCALL(fstat)
 521:	b8 08 00 00 00       	mov    $0x8,%eax
 526:	cd 40                	int    $0x40
 528:	c3                   	ret    

00000529 <link>:
SYSCALL(link)
 529:	b8 13 00 00 00       	mov    $0x13,%eax
 52e:	cd 40                	int    $0x40
 530:	c3                   	ret    

00000531 <mkdir>:
SYSCALL(mkdir)
 531:	b8 14 00 00 00       	mov    $0x14,%eax
 536:	cd 40                	int    $0x40
 538:	c3                   	ret    

00000539 <chdir>:
SYSCALL(chdir)
 539:	b8 09 00 00 00       	mov    $0x9,%eax
 53e:	cd 40                	int    $0x40
 540:	c3                   	ret    

00000541 <dup>:
SYSCALL(dup)
 541:	b8 0a 00 00 00       	mov    $0xa,%eax
 546:	cd 40                	int    $0x40
 548:	c3                   	ret    

00000549 <getpid>:
SYSCALL(getpid)
 549:	b8 0b 00 00 00       	mov    $0xb,%eax
 54e:	cd 40                	int    $0x40
 550:	c3                   	ret    

00000551 <sbrk>:
SYSCALL(sbrk)
 551:	b8 0c 00 00 00       	mov    $0xc,%eax
 556:	cd 40                	int    $0x40
 558:	c3                   	ret    

00000559 <sleep>:
SYSCALL(sleep)
 559:	b8 0d 00 00 00       	mov    $0xd,%eax
 55e:	cd 40                	int    $0x40
 560:	c3                   	ret    

00000561 <uptime>:
SYSCALL(uptime)
 561:	b8 0e 00 00 00       	mov    $0xe,%eax
 566:	cd 40                	int    $0x40
 568:	c3                   	ret    

00000569 <halt>:
SYSCALL(halt)
 569:	b8 16 00 00 00       	mov    $0x16,%eax
 56e:	cd 40                	int    $0x40
 570:	c3                   	ret    

00000571 <date>:
SYSCALL(date)
 571:	b8 17 00 00 00       	mov    $0x17,%eax
 576:	cd 40                	int    $0x40
 578:	c3                   	ret    

00000579 <getuid>:
SYSCALL(getuid)
 579:	b8 18 00 00 00       	mov    $0x18,%eax
 57e:	cd 40                	int    $0x40
 580:	c3                   	ret    

00000581 <getgid>:
SYSCALL(getgid)
 581:	b8 19 00 00 00       	mov    $0x19,%eax
 586:	cd 40                	int    $0x40
 588:	c3                   	ret    

00000589 <getppid>:
SYSCALL(getppid)
 589:	b8 1a 00 00 00       	mov    $0x1a,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret    

00000591 <setuid>:
SYSCALL(setuid)
 591:	b8 1b 00 00 00       	mov    $0x1b,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <setgid>:
SYSCALL(setgid)
 599:	b8 1c 00 00 00       	mov    $0x1c,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    

000005a1 <getprocs>:
SYSCALL(getprocs)
 5a1:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret    

000005a9 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5a9:	55                   	push   %ebp
 5aa:	89 e5                	mov    %esp,%ebp
 5ac:	83 ec 18             	sub    $0x18,%esp
 5af:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b2:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5b5:	83 ec 04             	sub    $0x4,%esp
 5b8:	6a 01                	push   $0x1
 5ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5bd:	50                   	push   %eax
 5be:	ff 75 08             	pushl  0x8(%ebp)
 5c1:	e8 23 ff ff ff       	call   4e9 <write>
 5c6:	83 c4 10             	add    $0x10,%esp
}
 5c9:	90                   	nop
 5ca:	c9                   	leave  
 5cb:	c3                   	ret    

000005cc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5cc:	55                   	push   %ebp
 5cd:	89 e5                	mov    %esp,%ebp
 5cf:	53                   	push   %ebx
 5d0:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5da:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5de:	74 17                	je     5f7 <printint+0x2b>
 5e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e4:	79 11                	jns    5f7 <printint+0x2b>
    neg = 1;
 5e6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f0:	f7 d8                	neg    %eax
 5f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f5:	eb 06                	jmp    5fd <printint+0x31>
  } else {
    x = xx;
 5f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 604:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 607:	8d 41 01             	lea    0x1(%ecx),%eax
 60a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 60d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 610:	8b 45 ec             	mov    -0x14(%ebp),%eax
 613:	ba 00 00 00 00       	mov    $0x0,%edx
 618:	f7 f3                	div    %ebx
 61a:	89 d0                	mov    %edx,%eax
 61c:	0f b6 80 80 0d 00 00 	movzbl 0xd80(%eax),%eax
 623:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 627:	8b 5d 10             	mov    0x10(%ebp),%ebx
 62a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 62d:	ba 00 00 00 00       	mov    $0x0,%edx
 632:	f7 f3                	div    %ebx
 634:	89 45 ec             	mov    %eax,-0x14(%ebp)
 637:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63b:	75 c7                	jne    604 <printint+0x38>
  if(neg)
 63d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 641:	74 2d                	je     670 <printint+0xa4>
    buf[i++] = '-';
 643:	8b 45 f4             	mov    -0xc(%ebp),%eax
 646:	8d 50 01             	lea    0x1(%eax),%edx
 649:	89 55 f4             	mov    %edx,-0xc(%ebp)
 64c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 651:	eb 1d                	jmp    670 <printint+0xa4>
    putc(fd, buf[i]);
 653:	8d 55 dc             	lea    -0x24(%ebp),%edx
 656:	8b 45 f4             	mov    -0xc(%ebp),%eax
 659:	01 d0                	add    %edx,%eax
 65b:	0f b6 00             	movzbl (%eax),%eax
 65e:	0f be c0             	movsbl %al,%eax
 661:	83 ec 08             	sub    $0x8,%esp
 664:	50                   	push   %eax
 665:	ff 75 08             	pushl  0x8(%ebp)
 668:	e8 3c ff ff ff       	call   5a9 <putc>
 66d:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 670:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 674:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 678:	79 d9                	jns    653 <printint+0x87>
    putc(fd, buf[i]);
}
 67a:	90                   	nop
 67b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 67e:	c9                   	leave  
 67f:	c3                   	ret    

00000680 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 680:	55                   	push   %ebp
 681:	89 e5                	mov    %esp,%ebp
 683:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 686:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 68d:	8d 45 0c             	lea    0xc(%ebp),%eax
 690:	83 c0 04             	add    $0x4,%eax
 693:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 696:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 69d:	e9 59 01 00 00       	jmp    7fb <printf+0x17b>
    c = fmt[i] & 0xff;
 6a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a8:	01 d0                	add    %edx,%eax
 6aa:	0f b6 00             	movzbl (%eax),%eax
 6ad:	0f be c0             	movsbl %al,%eax
 6b0:	25 ff 00 00 00       	and    $0xff,%eax
 6b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6bc:	75 2c                	jne    6ea <printf+0x6a>
      if(c == '%'){
 6be:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6c2:	75 0c                	jne    6d0 <printf+0x50>
        state = '%';
 6c4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6cb:	e9 27 01 00 00       	jmp    7f7 <printf+0x177>
      } else {
        putc(fd, c);
 6d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d3:	0f be c0             	movsbl %al,%eax
 6d6:	83 ec 08             	sub    $0x8,%esp
 6d9:	50                   	push   %eax
 6da:	ff 75 08             	pushl  0x8(%ebp)
 6dd:	e8 c7 fe ff ff       	call   5a9 <putc>
 6e2:	83 c4 10             	add    $0x10,%esp
 6e5:	e9 0d 01 00 00       	jmp    7f7 <printf+0x177>
      }
    } else if(state == '%'){
 6ea:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ee:	0f 85 03 01 00 00    	jne    7f7 <printf+0x177>
      if(c == 'd'){
 6f4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f8:	75 1e                	jne    718 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6fd:	8b 00                	mov    (%eax),%eax
 6ff:	6a 01                	push   $0x1
 701:	6a 0a                	push   $0xa
 703:	50                   	push   %eax
 704:	ff 75 08             	pushl  0x8(%ebp)
 707:	e8 c0 fe ff ff       	call   5cc <printint>
 70c:	83 c4 10             	add    $0x10,%esp
        ap++;
 70f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 713:	e9 d8 00 00 00       	jmp    7f0 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 718:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 71c:	74 06                	je     724 <printf+0xa4>
 71e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 722:	75 1e                	jne    742 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 724:	8b 45 e8             	mov    -0x18(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	6a 00                	push   $0x0
 72b:	6a 10                	push   $0x10
 72d:	50                   	push   %eax
 72e:	ff 75 08             	pushl  0x8(%ebp)
 731:	e8 96 fe ff ff       	call   5cc <printint>
 736:	83 c4 10             	add    $0x10,%esp
        ap++;
 739:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73d:	e9 ae 00 00 00       	jmp    7f0 <printf+0x170>
      } else if(c == 's'){
 742:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 746:	75 43                	jne    78b <printf+0x10b>
        s = (char*)*ap;
 748:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74b:	8b 00                	mov    (%eax),%eax
 74d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 750:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 754:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 758:	75 25                	jne    77f <printf+0xff>
          s = "(null)";
 75a:	c7 45 f4 16 0b 00 00 	movl   $0xb16,-0xc(%ebp)
        while(*s != 0){
 761:	eb 1c                	jmp    77f <printf+0xff>
          putc(fd, *s);
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	0f b6 00             	movzbl (%eax),%eax
 769:	0f be c0             	movsbl %al,%eax
 76c:	83 ec 08             	sub    $0x8,%esp
 76f:	50                   	push   %eax
 770:	ff 75 08             	pushl  0x8(%ebp)
 773:	e8 31 fe ff ff       	call   5a9 <putc>
 778:	83 c4 10             	add    $0x10,%esp
          s++;
 77b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	0f b6 00             	movzbl (%eax),%eax
 785:	84 c0                	test   %al,%al
 787:	75 da                	jne    763 <printf+0xe3>
 789:	eb 65                	jmp    7f0 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 78b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 78f:	75 1d                	jne    7ae <printf+0x12e>
        putc(fd, *ap);
 791:	8b 45 e8             	mov    -0x18(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	83 ec 08             	sub    $0x8,%esp
 79c:	50                   	push   %eax
 79d:	ff 75 08             	pushl  0x8(%ebp)
 7a0:	e8 04 fe ff ff       	call   5a9 <putc>
 7a5:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ac:	eb 42                	jmp    7f0 <printf+0x170>
      } else if(c == '%'){
 7ae:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b2:	75 17                	jne    7cb <printf+0x14b>
        putc(fd, c);
 7b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b7:	0f be c0             	movsbl %al,%eax
 7ba:	83 ec 08             	sub    $0x8,%esp
 7bd:	50                   	push   %eax
 7be:	ff 75 08             	pushl  0x8(%ebp)
 7c1:	e8 e3 fd ff ff       	call   5a9 <putc>
 7c6:	83 c4 10             	add    $0x10,%esp
 7c9:	eb 25                	jmp    7f0 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7cb:	83 ec 08             	sub    $0x8,%esp
 7ce:	6a 25                	push   $0x25
 7d0:	ff 75 08             	pushl  0x8(%ebp)
 7d3:	e8 d1 fd ff ff       	call   5a9 <putc>
 7d8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7de:	0f be c0             	movsbl %al,%eax
 7e1:	83 ec 08             	sub    $0x8,%esp
 7e4:	50                   	push   %eax
 7e5:	ff 75 08             	pushl  0x8(%ebp)
 7e8:	e8 bc fd ff ff       	call   5a9 <putc>
 7ed:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7f7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 7fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 801:	01 d0                	add    %edx,%eax
 803:	0f b6 00             	movzbl (%eax),%eax
 806:	84 c0                	test   %al,%al
 808:	0f 85 94 fe ff ff    	jne    6a2 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 80e:	90                   	nop
 80f:	c9                   	leave  
 810:	c3                   	ret    

00000811 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 811:	55                   	push   %ebp
 812:	89 e5                	mov    %esp,%ebp
 814:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 817:	8b 45 08             	mov    0x8(%ebp),%eax
 81a:	83 e8 08             	sub    $0x8,%eax
 81d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 825:	89 45 fc             	mov    %eax,-0x4(%ebp)
 828:	eb 24                	jmp    84e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82d:	8b 00                	mov    (%eax),%eax
 82f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 832:	77 12                	ja     846 <free+0x35>
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83a:	77 24                	ja     860 <free+0x4f>
 83c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 844:	77 1a                	ja     860 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 00                	mov    (%eax),%eax
 84b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 84e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 851:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 854:	76 d4                	jbe    82a <free+0x19>
 856:	8b 45 fc             	mov    -0x4(%ebp),%eax
 859:	8b 00                	mov    (%eax),%eax
 85b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85e:	76 ca                	jbe    82a <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 860:	8b 45 f8             	mov    -0x8(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 86d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 870:	01 c2                	add    %eax,%edx
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	39 c2                	cmp    %eax,%edx
 879:	75 24                	jne    89f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	8b 50 04             	mov    0x4(%eax),%edx
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	01 c2                	add    %eax,%edx
 88b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 00                	mov    (%eax),%eax
 896:	8b 10                	mov    (%eax),%edx
 898:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89b:	89 10                	mov    %edx,(%eax)
 89d:	eb 0a                	jmp    8a9 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 10                	mov    (%eax),%edx
 8a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a7:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 40 04             	mov    0x4(%eax),%eax
 8af:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	01 d0                	add    %edx,%eax
 8bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8be:	75 20                	jne    8e0 <free+0xcf>
    p->s.size += bp->s.size;
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c3:	8b 50 04             	mov    0x4(%eax),%edx
 8c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c9:	8b 40 04             	mov    0x4(%eax),%eax
 8cc:	01 c2                	add    %eax,%edx
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d7:	8b 10                	mov    (%eax),%edx
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	89 10                	mov    %edx,(%eax)
 8de:	eb 08                	jmp    8e8 <free+0xd7>
  } else
    p->s.ptr = bp;
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e6:	89 10                	mov    %edx,(%eax)
  freep = p;
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8eb:	a3 9c 0d 00 00       	mov    %eax,0xd9c
}
 8f0:	90                   	nop
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    

000008f3 <morecore>:

static Header*
morecore(uint nu)
{
 8f3:	55                   	push   %ebp
 8f4:	89 e5                	mov    %esp,%ebp
 8f6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8f9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 900:	77 07                	ja     909 <morecore+0x16>
    nu = 4096;
 902:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 909:	8b 45 08             	mov    0x8(%ebp),%eax
 90c:	c1 e0 03             	shl    $0x3,%eax
 90f:	83 ec 0c             	sub    $0xc,%esp
 912:	50                   	push   %eax
 913:	e8 39 fc ff ff       	call   551 <sbrk>
 918:	83 c4 10             	add    $0x10,%esp
 91b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 91e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 922:	75 07                	jne    92b <morecore+0x38>
    return 0;
 924:	b8 00 00 00 00       	mov    $0x0,%eax
 929:	eb 26                	jmp    951 <morecore+0x5e>
  hp = (Header*)p;
 92b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 931:	8b 45 f0             	mov    -0x10(%ebp),%eax
 934:	8b 55 08             	mov    0x8(%ebp),%edx
 937:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 93a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93d:	83 c0 08             	add    $0x8,%eax
 940:	83 ec 0c             	sub    $0xc,%esp
 943:	50                   	push   %eax
 944:	e8 c8 fe ff ff       	call   811 <free>
 949:	83 c4 10             	add    $0x10,%esp
  return freep;
 94c:	a1 9c 0d 00 00       	mov    0xd9c,%eax
}
 951:	c9                   	leave  
 952:	c3                   	ret    

00000953 <malloc>:

void*
malloc(uint nbytes)
{
 953:	55                   	push   %ebp
 954:	89 e5                	mov    %esp,%ebp
 956:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 959:	8b 45 08             	mov    0x8(%ebp),%eax
 95c:	83 c0 07             	add    $0x7,%eax
 95f:	c1 e8 03             	shr    $0x3,%eax
 962:	83 c0 01             	add    $0x1,%eax
 965:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 968:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 96d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 970:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 974:	75 23                	jne    999 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 976:	c7 45 f0 94 0d 00 00 	movl   $0xd94,-0x10(%ebp)
 97d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 980:	a3 9c 0d 00 00       	mov    %eax,0xd9c
 985:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 98a:	a3 94 0d 00 00       	mov    %eax,0xd94
    base.s.size = 0;
 98f:	c7 05 98 0d 00 00 00 	movl   $0x0,0xd98
 996:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 999:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99c:	8b 00                	mov    (%eax),%eax
 99e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a4:	8b 40 04             	mov    0x4(%eax),%eax
 9a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9aa:	72 4d                	jb     9f9 <malloc+0xa6>
      if(p->s.size == nunits)
 9ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9af:	8b 40 04             	mov    0x4(%eax),%eax
 9b2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9b5:	75 0c                	jne    9c3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ba:	8b 10                	mov    (%eax),%edx
 9bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bf:	89 10                	mov    %edx,(%eax)
 9c1:	eb 26                	jmp    9e9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c6:	8b 40 04             	mov    0x4(%eax),%eax
 9c9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9cc:	89 c2                	mov    %eax,%edx
 9ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	8b 40 04             	mov    0x4(%eax),%eax
 9da:	c1 e0 03             	shl    $0x3,%eax
 9dd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ec:	a3 9c 0d 00 00       	mov    %eax,0xd9c
      return (void*)(p + 1);
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	83 c0 08             	add    $0x8,%eax
 9f7:	eb 3b                	jmp    a34 <malloc+0xe1>
    }
    if(p == freep)
 9f9:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 9fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a01:	75 1e                	jne    a21 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a03:	83 ec 0c             	sub    $0xc,%esp
 a06:	ff 75 ec             	pushl  -0x14(%ebp)
 a09:	e8 e5 fe ff ff       	call   8f3 <morecore>
 a0e:	83 c4 10             	add    $0x10,%esp
 a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a18:	75 07                	jne    a21 <malloc+0xce>
        return 0;
 a1a:	b8 00 00 00 00       	mov    $0x0,%eax
 a1f:	eb 13                	jmp    a34 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a24:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2a:	8b 00                	mov    (%eax),%eax
 a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a2f:	e9 6d ff ff ff       	jmp    9a1 <malloc+0x4e>
}
 a34:	c9                   	leave  
 a35:	c3                   	ret    
