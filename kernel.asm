
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 39 39 10 80       	mov    $0x80103939,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 d0 94 10 80       	push   $0x801094d0
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 c4 5d 00 00       	call   80105e10 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 6c 5d 00 00       	call   80105e32 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 88 5d 00 00       	call   80105e99 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 d7 52 00 00       	call   80105403 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 0c 5d 00 00       	call   80105e99 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 d7 94 10 80       	push   $0x801094d7
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 d0 27 00 00       	call   801029b7 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 e8 94 10 80       	push   $0x801094e8
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 8f 27 00 00       	call   801029b7 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 ef 94 10 80       	push   $0x801094ef
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 d8 5b 00 00       	call   80105e32 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 c0 52 00 00       	call   8010557e <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 cb 5b 00 00       	call   80105e99 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 4b 5a 00 00       	call   80105e32 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 f6 94 10 80       	push   $0x801094f6
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec ff 94 10 80 	movl   $0x801094ff,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 39 59 00 00       	call   80105e99 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 06 95 10 80       	push   $0x80109506
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 15 95 10 80       	push   $0x80109515
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 24 59 00 00       	call   80105eeb <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 17 95 10 80       	push   $0x80109517
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 1b 95 10 80       	push   $0x8010951b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 58 5a 00 00       	call   80106154 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 6f 59 00 00       	call   80106095 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 9e 73 00 00       	call   80107b59 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 91 73 00 00       	call   80107b59 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 84 73 00 00       	call   80107b59 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 74 73 00 00       	call   80107b59 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int doprintready  = 0;
80100806:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int doprintfree   = 0;
8010080d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int doprintsleep  = 0;
80100814:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  int doprintzombie = 0;
8010081b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)


  acquire(&cons.lock);
80100822:	83 ec 0c             	sub    $0xc,%esp
80100825:	68 e0 c5 10 80       	push   $0x8010c5e0
8010082a:	e8 03 56 00 00       	call   80105e32 <acquire>
8010082f:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100832:	e9 a6 01 00 00       	jmp    801009dd <consoleintr+0x1e4>
    switch(c){
80100837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010083a:	83 f8 12             	cmp    $0x12,%eax
8010083d:	0f 84 d8 00 00 00    	je     8010091b <consoleintr+0x122>
80100843:	83 f8 12             	cmp    $0x12,%eax
80100846:	7f 1c                	jg     80100864 <consoleintr+0x6b>
80100848:	83 f8 08             	cmp    $0x8,%eax
8010084b:	0f 84 95 00 00 00    	je     801008e6 <consoleintr+0xed>
80100851:	83 f8 10             	cmp    $0x10,%eax
80100854:	74 39                	je     8010088f <consoleintr+0x96>
80100856:	83 f8 06             	cmp    $0x6,%eax
80100859:	0f 84 c8 00 00 00    	je     80100927 <consoleintr+0x12e>
8010085f:	e9 e7 00 00 00       	jmp    8010094b <consoleintr+0x152>
80100864:	83 f8 15             	cmp    $0x15,%eax
80100867:	74 4f                	je     801008b8 <consoleintr+0xbf>
80100869:	83 f8 15             	cmp    $0x15,%eax
8010086c:	7f 0e                	jg     8010087c <consoleintr+0x83>
8010086e:	83 f8 13             	cmp    $0x13,%eax
80100871:	0f 84 bc 00 00 00    	je     80100933 <consoleintr+0x13a>
80100877:	e9 cf 00 00 00       	jmp    8010094b <consoleintr+0x152>
8010087c:	83 f8 1a             	cmp    $0x1a,%eax
8010087f:	0f 84 ba 00 00 00    	je     8010093f <consoleintr+0x146>
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	74 5c                	je     801008e6 <consoleintr+0xed>
8010088a:	e9 bc 00 00 00       	jmp    8010094b <consoleintr+0x152>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010088f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100896:	e9 42 01 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010089b:	a1 28 18 11 80       	mov    0x80111828,%eax
801008a0:	83 e8 01             	sub    $0x1,%eax
801008a3:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
801008a8:	83 ec 0c             	sub    $0xc,%esp
801008ab:	68 00 01 00 00       	push   $0x100
801008b0:	e8 dd fe ff ff       	call   80100792 <consputc>
801008b5:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008b8:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008be:	a1 24 18 11 80       	mov    0x80111824,%eax
801008c3:	39 c2                	cmp    %eax,%edx
801008c5:	0f 84 12 01 00 00    	je     801009dd <consoleintr+0x1e4>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008cb:	a1 28 18 11 80       	mov    0x80111828,%eax
801008d0:	83 e8 01             	sub    $0x1,%eax
801008d3:	83 e0 7f             	and    $0x7f,%eax
801008d6:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008dd:	3c 0a                	cmp    $0xa,%al
801008df:	75 ba                	jne    8010089b <consoleintr+0xa2>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008e1:	e9 f7 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008e6:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008ec:	a1 24 18 11 80       	mov    0x80111824,%eax
801008f1:	39 c2                	cmp    %eax,%edx
801008f3:	0f 84 e4 00 00 00    	je     801009dd <consoleintr+0x1e4>
        input.e--;
801008f9:	a1 28 18 11 80       	mov    0x80111828,%eax
801008fe:	83 e8 01             	sub    $0x1,%eax
80100901:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
80100906:	83 ec 0c             	sub    $0xc,%esp
80100909:	68 00 01 00 00       	push   $0x100
8010090e:	e8 7f fe ff ff       	call   80100792 <consputc>
80100913:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100916:	e9 c2 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    #ifdef CS333_P3P4
    case C('R'): //print PIDs in ready list
	doprintready  = 1;
8010091b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    break;
80100922:	e9 b6 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('F'):
	doprintfree   = 1;
80100927:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
    break;
8010092e:	e9 aa 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('S'):
	doprintsleep  = 1;
80100933:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    break;
8010093a:	e9 9e 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('Z'):
	doprintzombie = 1;
8010093f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    break;
80100946:	e9 92 00 00 00       	jmp    801009dd <consoleintr+0x1e4>


    #endif
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010094b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010094f:	0f 84 87 00 00 00    	je     801009dc <consoleintr+0x1e3>
80100955:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010095b:	a1 20 18 11 80       	mov    0x80111820,%eax
80100960:	29 c2                	sub    %eax,%edx
80100962:	89 d0                	mov    %edx,%eax
80100964:	83 f8 7f             	cmp    $0x7f,%eax
80100967:	77 73                	ja     801009dc <consoleintr+0x1e3>
        c = (c == '\r') ? '\n' : c;
80100969:	83 7d e0 0d          	cmpl   $0xd,-0x20(%ebp)
8010096d:	74 05                	je     80100974 <consoleintr+0x17b>
8010096f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100972:	eb 05                	jmp    80100979 <consoleintr+0x180>
80100974:	b8 0a 00 00 00       	mov    $0xa,%eax
80100979:	89 45 e0             	mov    %eax,-0x20(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010097c:	a1 28 18 11 80       	mov    0x80111828,%eax
80100981:	8d 50 01             	lea    0x1(%eax),%edx
80100984:	89 15 28 18 11 80    	mov    %edx,0x80111828
8010098a:	83 e0 7f             	and    $0x7f,%eax
8010098d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100990:	88 90 a0 17 11 80    	mov    %dl,-0x7feee860(%eax)
        consputc(c);
80100996:	83 ec 0c             	sub    $0xc,%esp
80100999:	ff 75 e0             	pushl  -0x20(%ebp)
8010099c:	e8 f1 fd ff ff       	call   80100792 <consputc>
801009a1:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009a4:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
801009a8:	74 18                	je     801009c2 <consoleintr+0x1c9>
801009aa:	83 7d e0 04          	cmpl   $0x4,-0x20(%ebp)
801009ae:	74 12                	je     801009c2 <consoleintr+0x1c9>
801009b0:	a1 28 18 11 80       	mov    0x80111828,%eax
801009b5:	8b 15 20 18 11 80    	mov    0x80111820,%edx
801009bb:	83 ea 80             	sub    $0xffffff80,%edx
801009be:	39 d0                	cmp    %edx,%eax
801009c0:	75 1a                	jne    801009dc <consoleintr+0x1e3>
          input.w = input.e;
801009c2:	a1 28 18 11 80       	mov    0x80111828,%eax
801009c7:	a3 24 18 11 80       	mov    %eax,0x80111824
          wakeup(&input.r);
801009cc:	83 ec 0c             	sub    $0xc,%esp
801009cf:	68 20 18 11 80       	push   $0x80111820
801009d4:	e8 a5 4b 00 00       	call   8010557e <wakeup>
801009d9:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009dc:	90                   	nop
  int doprintsleep  = 0;
  int doprintzombie = 0;


  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009dd:	8b 45 08             	mov    0x8(%ebp),%eax
801009e0:	ff d0                	call   *%eax
801009e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801009e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801009e9:	0f 89 48 fe ff ff    	jns    80100837 <consoleintr+0x3e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009ef:	83 ec 0c             	sub    $0xc,%esp
801009f2:	68 e0 c5 10 80       	push   $0x8010c5e0
801009f7:	e8 9d 54 00 00       	call   80105e99 <release>
801009fc:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a03:	74 05                	je     80100a0a <consoleintr+0x211>
    procdump();  // now call procdump() wo. cons.lock held
80100a05:	e8 7f 4c 00 00       	call   80105689 <procdump>
  }
  if(doprintready)
80100a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a0e:	74 05                	je     80100a15 <consoleintr+0x21c>
      printready();
80100a10:	e8 f8 51 00 00       	call   80105c0d <printready>
  if(doprintfree)
80100a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a19:	74 05                	je     80100a20 <consoleintr+0x227>
      printfree();
80100a1b:	e8 59 52 00 00       	call   80105c79 <printfree>
  if(doprintsleep)
80100a20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a24:	74 05                	je     80100a2b <consoleintr+0x232>
      printsleep();
80100a26:	e8 b1 52 00 00       	call   80105cdc <printsleep>
  if(doprintzombie)
80100a2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2f:	74 05                	je     80100a36 <consoleintr+0x23d>
      printzombie();
80100a31:	e8 12 53 00 00       	call   80105d48 <printzombie>
}
80100a36:	90                   	nop
80100a37:	c9                   	leave  
80100a38:	c3                   	ret    

80100a39 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a39:	55                   	push   %ebp
80100a3a:	89 e5                	mov    %esp,%ebp
80100a3c:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a3f:	83 ec 0c             	sub    $0xc,%esp
80100a42:	ff 75 08             	pushl  0x8(%ebp)
80100a45:	e8 28 11 00 00       	call   80101b72 <iunlock>
80100a4a:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a4d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a53:	83 ec 0c             	sub    $0xc,%esp
80100a56:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a5b:	e8 d2 53 00 00       	call   80105e32 <acquire>
80100a60:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a63:	e9 ac 00 00 00       	jmp    80100b14 <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
80100a68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a6e:	8b 40 24             	mov    0x24(%eax),%eax
80100a71:	85 c0                	test   %eax,%eax
80100a73:	74 28                	je     80100a9d <consoleread+0x64>
        release(&cons.lock);
80100a75:	83 ec 0c             	sub    $0xc,%esp
80100a78:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a7d:	e8 17 54 00 00       	call   80105e99 <release>
80100a82:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a85:	83 ec 0c             	sub    $0xc,%esp
80100a88:	ff 75 08             	pushl  0x8(%ebp)
80100a8b:	e8 84 0f 00 00       	call   80101a14 <ilock>
80100a90:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a98:	e9 ab 00 00 00       	jmp    80100b48 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a9d:	83 ec 08             	sub    $0x8,%esp
80100aa0:	68 e0 c5 10 80       	push   $0x8010c5e0
80100aa5:	68 20 18 11 80       	push   $0x80111820
80100aaa:	e8 54 49 00 00       	call   80105403 <sleep>
80100aaf:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100ab2:	8b 15 20 18 11 80    	mov    0x80111820,%edx
80100ab8:	a1 24 18 11 80       	mov    0x80111824,%eax
80100abd:	39 c2                	cmp    %eax,%edx
80100abf:	74 a7                	je     80100a68 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ac1:	a1 20 18 11 80       	mov    0x80111820,%eax
80100ac6:	8d 50 01             	lea    0x1(%eax),%edx
80100ac9:	89 15 20 18 11 80    	mov    %edx,0x80111820
80100acf:	83 e0 7f             	and    $0x7f,%eax
80100ad2:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
80100ad9:	0f be c0             	movsbl %al,%eax
80100adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100adf:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ae3:	75 17                	jne    80100afc <consoleread+0xc3>
      if(n < target){
80100ae5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ae8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100aeb:	73 2f                	jae    80100b1c <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aed:	a1 20 18 11 80       	mov    0x80111820,%eax
80100af2:	83 e8 01             	sub    $0x1,%eax
80100af5:	a3 20 18 11 80       	mov    %eax,0x80111820
      }
      break;
80100afa:	eb 20                	jmp    80100b1c <consoleread+0xe3>
    }
    *dst++ = c;
80100afc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aff:	8d 50 01             	lea    0x1(%eax),%edx
80100b02:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b08:	88 10                	mov    %dl,(%eax)
    --n;
80100b0a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b0e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b12:	74 0b                	je     80100b1f <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b18:	7f 98                	jg     80100ab2 <consoleread+0x79>
80100b1a:	eb 04                	jmp    80100b20 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100b1c:	90                   	nop
80100b1d:	eb 01                	jmp    80100b20 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100b1f:	90                   	nop
  }
  release(&cons.lock);
80100b20:	83 ec 0c             	sub    $0xc,%esp
80100b23:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b28:	e8 6c 53 00 00       	call   80105e99 <release>
80100b2d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b30:	83 ec 0c             	sub    $0xc,%esp
80100b33:	ff 75 08             	pushl  0x8(%ebp)
80100b36:	e8 d9 0e 00 00       	call   80101a14 <ilock>
80100b3b:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b3e:	8b 45 10             	mov    0x10(%ebp),%eax
80100b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b44:	29 c2                	sub    %eax,%edx
80100b46:	89 d0                	mov    %edx,%eax
}
80100b48:	c9                   	leave  
80100b49:	c3                   	ret    

80100b4a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b4a:	55                   	push   %ebp
80100b4b:	89 e5                	mov    %esp,%ebp
80100b4d:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b50:	83 ec 0c             	sub    $0xc,%esp
80100b53:	ff 75 08             	pushl  0x8(%ebp)
80100b56:	e8 17 10 00 00       	call   80101b72 <iunlock>
80100b5b:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b5e:	83 ec 0c             	sub    $0xc,%esp
80100b61:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b66:	e8 c7 52 00 00       	call   80105e32 <acquire>
80100b6b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b75:	eb 21                	jmp    80100b98 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b7d:	01 d0                	add    %edx,%eax
80100b7f:	0f b6 00             	movzbl (%eax),%eax
80100b82:	0f be c0             	movsbl %al,%eax
80100b85:	0f b6 c0             	movzbl %al,%eax
80100b88:	83 ec 0c             	sub    $0xc,%esp
80100b8b:	50                   	push   %eax
80100b8c:	e8 01 fc ff ff       	call   80100792 <consputc>
80100b91:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b9e:	7c d7                	jl     80100b77 <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	68 e0 c5 10 80       	push   $0x8010c5e0
80100ba8:	e8 ec 52 00 00       	call   80105e99 <release>
80100bad:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 08             	pushl  0x8(%ebp)
80100bb6:	e8 59 0e 00 00       	call   80101a14 <ilock>
80100bbb:	83 c4 10             	add    $0x10,%esp

  return n;
80100bbe:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    

80100bc3 <consoleinit>:

void
consoleinit(void)
{
80100bc3:	55                   	push   %ebp
80100bc4:	89 e5                	mov    %esp,%ebp
80100bc6:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bc9:	83 ec 08             	sub    $0x8,%esp
80100bcc:	68 2e 95 10 80       	push   $0x8010952e
80100bd1:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bd6:	e8 35 52 00 00       	call   80105e10 <initlock>
80100bdb:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bde:	c7 05 ec 21 11 80 4a 	movl   $0x80100b4a,0x801121ec
80100be5:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100be8:	c7 05 e8 21 11 80 39 	movl   $0x80100a39,0x801121e8
80100bef:	0a 10 80 
  cons.locking = 1;
80100bf2:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100bf9:	00 00 00 

  picenable(IRQ_KBD);
80100bfc:	83 ec 0c             	sub    $0xc,%esp
80100bff:	6a 01                	push   $0x1
80100c01:	e8 cf 33 00 00       	call   80103fd5 <picenable>
80100c06:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100c09:	83 ec 08             	sub    $0x8,%esp
80100c0c:	6a 00                	push   $0x0
80100c0e:	6a 01                	push   $0x1
80100c10:	e8 6f 1f 00 00       	call   80102b84 <ioapicenable>
80100c15:	83 c4 10             	add    $0x10,%esp
}
80100c18:	90                   	nop
80100c19:	c9                   	leave  
80100c1a:	c3                   	ret    

80100c1b <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c1b:	55                   	push   %ebp
80100c1c:	89 e5                	mov    %esp,%ebp
80100c1e:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c24:	e8 ce 29 00 00       	call   801035f7 <begin_op>
  if((ip = namei(path)) == 0){
80100c29:	83 ec 0c             	sub    $0xc,%esp
80100c2c:	ff 75 08             	pushl  0x8(%ebp)
80100c2f:	e8 9e 19 00 00       	call   801025d2 <namei>
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c3e:	75 0f                	jne    80100c4f <exec+0x34>
    end_op();
80100c40:	e8 3e 2a 00 00       	call   80103683 <end_op>
    return -1;
80100c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c4a:	e9 ce 03 00 00       	jmp    8010101d <exec+0x402>
  }
  ilock(ip);
80100c4f:	83 ec 0c             	sub    $0xc,%esp
80100c52:	ff 75 d8             	pushl  -0x28(%ebp)
80100c55:	e8 ba 0d 00 00       	call   80101a14 <ilock>
80100c5a:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c5d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c64:	6a 34                	push   $0x34
80100c66:	6a 00                	push   $0x0
80100c68:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c6e:	50                   	push   %eax
80100c6f:	ff 75 d8             	pushl  -0x28(%ebp)
80100c72:	e8 0b 13 00 00       	call   80101f82 <readi>
80100c77:	83 c4 10             	add    $0x10,%esp
80100c7a:	83 f8 33             	cmp    $0x33,%eax
80100c7d:	0f 86 49 03 00 00    	jbe    80100fcc <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c83:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c89:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c8e:	0f 85 3b 03 00 00    	jne    80100fcf <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c94:	e8 15 80 00 00       	call   80108cae <setupkvm>
80100c99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c9c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ca0:	0f 84 2c 03 00 00    	je     80100fd2 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ca6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cb4:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100cba:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cbd:	e9 ab 00 00 00       	jmp    80100d6d <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cc5:	6a 20                	push   $0x20
80100cc7:	50                   	push   %eax
80100cc8:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100cce:	50                   	push   %eax
80100ccf:	ff 75 d8             	pushl  -0x28(%ebp)
80100cd2:	e8 ab 12 00 00       	call   80101f82 <readi>
80100cd7:	83 c4 10             	add    $0x10,%esp
80100cda:	83 f8 20             	cmp    $0x20,%eax
80100cdd:	0f 85 f2 02 00 00    	jne    80100fd5 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ce3:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ce9:	83 f8 01             	cmp    $0x1,%eax
80100cec:	75 71                	jne    80100d5f <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100cee:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100cf4:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cfa:	39 c2                	cmp    %eax,%edx
80100cfc:	0f 82 d6 02 00 00    	jb     80100fd8 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d02:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d08:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100d0e:	01 d0                	add    %edx,%eax
80100d10:	83 ec 04             	sub    $0x4,%esp
80100d13:	50                   	push   %eax
80100d14:	ff 75 e0             	pushl  -0x20(%ebp)
80100d17:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1a:	e8 36 83 00 00       	call   80109055 <allocuvm>
80100d1f:	83 c4 10             	add    $0x10,%esp
80100d22:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d29:	0f 84 ac 02 00 00    	je     80100fdb <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d2f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d35:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d3b:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	52                   	push   %edx
80100d45:	50                   	push   %eax
80100d46:	ff 75 d8             	pushl  -0x28(%ebp)
80100d49:	51                   	push   %ecx
80100d4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d4d:	e8 2c 82 00 00       	call   80108f7e <loaduvm>
80100d52:	83 c4 20             	add    $0x20,%esp
80100d55:	85 c0                	test   %eax,%eax
80100d57:	0f 88 81 02 00 00    	js     80100fde <exec+0x3c3>
80100d5d:	eb 01                	jmp    80100d60 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d5f:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d60:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d67:	83 c0 20             	add    $0x20,%eax
80100d6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d6d:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d74:	0f b7 c0             	movzwl %ax,%eax
80100d77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d7a:	0f 8f 42 ff ff ff    	jg     80100cc2 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d80:	83 ec 0c             	sub    $0xc,%esp
80100d83:	ff 75 d8             	pushl  -0x28(%ebp)
80100d86:	e8 49 0f 00 00       	call   80101cd4 <iunlockput>
80100d8b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d8e:	e8 f0 28 00 00       	call   80103683 <end_op>
  ip = 0;
80100d93:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100da2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100da7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dad:	05 00 20 00 00       	add    $0x2000,%eax
80100db2:	83 ec 04             	sub    $0x4,%esp
80100db5:	50                   	push   %eax
80100db6:	ff 75 e0             	pushl  -0x20(%ebp)
80100db9:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dbc:	e8 94 82 00 00       	call   80109055 <allocuvm>
80100dc1:	83 c4 10             	add    $0x10,%esp
80100dc4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dcb:	0f 84 10 02 00 00    	je     80100fe1 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dd4:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dd9:	83 ec 08             	sub    $0x8,%esp
80100ddc:	50                   	push   %eax
80100ddd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100de0:	e8 96 84 00 00       	call   8010927b <clearpteu>
80100de5:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100deb:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100df5:	e9 96 00 00 00       	jmp    80100e90 <exec+0x275>
    if(argc >= MAXARG)
80100dfa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dfe:	0f 87 e0 01 00 00    	ja     80100fe4 <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e11:	01 d0                	add    %edx,%eax
80100e13:	8b 00                	mov    (%eax),%eax
80100e15:	83 ec 0c             	sub    $0xc,%esp
80100e18:	50                   	push   %eax
80100e19:	e8 c4 54 00 00       	call   801062e2 <strlen>
80100e1e:	83 c4 10             	add    $0x10,%esp
80100e21:	89 c2                	mov    %eax,%edx
80100e23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e26:	29 d0                	sub    %edx,%eax
80100e28:	83 e8 01             	sub    $0x1,%eax
80100e2b:	83 e0 fc             	and    $0xfffffffc,%eax
80100e2e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e3e:	01 d0                	add    %edx,%eax
80100e40:	8b 00                	mov    (%eax),%eax
80100e42:	83 ec 0c             	sub    $0xc,%esp
80100e45:	50                   	push   %eax
80100e46:	e8 97 54 00 00       	call   801062e2 <strlen>
80100e4b:	83 c4 10             	add    $0x10,%esp
80100e4e:	83 c0 01             	add    $0x1,%eax
80100e51:	89 c1                	mov    %eax,%ecx
80100e53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e60:	01 d0                	add    %edx,%eax
80100e62:	8b 00                	mov    (%eax),%eax
80100e64:	51                   	push   %ecx
80100e65:	50                   	push   %eax
80100e66:	ff 75 dc             	pushl  -0x24(%ebp)
80100e69:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e6c:	e8 c1 85 00 00       	call   80109432 <copyout>
80100e71:	83 c4 10             	add    $0x10,%esp
80100e74:	85 c0                	test   %eax,%eax
80100e76:	0f 88 6b 01 00 00    	js     80100fe7 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7f:	8d 50 03             	lea    0x3(%eax),%edx
80100e82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e85:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e8c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e9d:	01 d0                	add    %edx,%eax
80100e9f:	8b 00                	mov    (%eax),%eax
80100ea1:	85 c0                	test   %eax,%eax
80100ea3:	0f 85 51 ff ff ff    	jne    80100dfa <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eac:	83 c0 03             	add    $0x3,%eax
80100eaf:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100eb6:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eba:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100ec1:	ff ff ff 
  ustack[1] = argc;
80100ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec7:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed0:	83 c0 01             	add    $0x1,%eax
80100ed3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100eda:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100edd:	29 d0                	sub    %edx,%eax
80100edf:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ee5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee8:	83 c0 04             	add    $0x4,%eax
80100eeb:	c1 e0 02             	shl    $0x2,%eax
80100eee:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef4:	83 c0 04             	add    $0x4,%eax
80100ef7:	c1 e0 02             	shl    $0x2,%eax
80100efa:	50                   	push   %eax
80100efb:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100f01:	50                   	push   %eax
80100f02:	ff 75 dc             	pushl  -0x24(%ebp)
80100f05:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f08:	e8 25 85 00 00       	call   80109432 <copyout>
80100f0d:	83 c4 10             	add    $0x10,%esp
80100f10:	85 c0                	test   %eax,%eax
80100f12:	0f 88 d2 00 00 00    	js     80100fea <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f18:	8b 45 08             	mov    0x8(%ebp),%eax
80100f1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f24:	eb 17                	jmp    80100f3d <exec+0x322>
    if(*s == '/')
80100f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f29:	0f b6 00             	movzbl (%eax),%eax
80100f2c:	3c 2f                	cmp    $0x2f,%al
80100f2e:	75 09                	jne    80100f39 <exec+0x31e>
      last = s+1;
80100f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f33:	83 c0 01             	add    $0x1,%eax
80100f36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f40:	0f b6 00             	movzbl (%eax),%eax
80100f43:	84 c0                	test   %al,%al
80100f45:	75 df                	jne    80100f26 <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f4d:	83 c0 6c             	add    $0x6c,%eax
80100f50:	83 ec 04             	sub    $0x4,%esp
80100f53:	6a 10                	push   $0x10
80100f55:	ff 75 f0             	pushl  -0x10(%ebp)
80100f58:	50                   	push   %eax
80100f59:	e8 3a 53 00 00       	call   80106298 <safestrcpy>
80100f5e:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f67:	8b 40 04             	mov    0x4(%eax),%eax
80100f6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f73:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f76:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f82:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f8a:	8b 40 18             	mov    0x18(%eax),%eax
80100f8d:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f93:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f9c:	8b 40 18             	mov    0x18(%eax),%eax
80100f9f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fa2:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100fa5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	50                   	push   %eax
80100faf:	e8 e1 7d 00 00       	call   80108d95 <switchuvm>
80100fb4:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fb7:	83 ec 0c             	sub    $0xc,%esp
80100fba:	ff 75 d0             	pushl  -0x30(%ebp)
80100fbd:	e8 19 82 00 00       	call   801091db <freevm>
80100fc2:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fc5:	b8 00 00 00 00       	mov    $0x0,%eax
80100fca:	eb 51                	jmp    8010101d <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100fcc:	90                   	nop
80100fcd:	eb 1c                	jmp    80100feb <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fcf:	90                   	nop
80100fd0:	eb 19                	jmp    80100feb <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fd2:	90                   	nop
80100fd3:	eb 16                	jmp    80100feb <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fd5:	90                   	nop
80100fd6:	eb 13                	jmp    80100feb <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fd8:	90                   	nop
80100fd9:	eb 10                	jmp    80100feb <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fdb:	90                   	nop
80100fdc:	eb 0d                	jmp    80100feb <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fde:	90                   	nop
80100fdf:	eb 0a                	jmp    80100feb <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100fe1:	90                   	nop
80100fe2:	eb 07                	jmp    80100feb <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fe4:	90                   	nop
80100fe5:	eb 04                	jmp    80100feb <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fe7:	90                   	nop
80100fe8:	eb 01                	jmp    80100feb <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100fea:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100feb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fef:	74 0e                	je     80100fff <exec+0x3e4>
    freevm(pgdir);
80100ff1:	83 ec 0c             	sub    $0xc,%esp
80100ff4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ff7:	e8 df 81 00 00       	call   801091db <freevm>
80100ffc:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101003:	74 13                	je     80101018 <exec+0x3fd>
    iunlockput(ip);
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	ff 75 d8             	pushl  -0x28(%ebp)
8010100b:	e8 c4 0c 00 00       	call   80101cd4 <iunlockput>
80101010:	83 c4 10             	add    $0x10,%esp
    end_op();
80101013:	e8 6b 26 00 00       	call   80103683 <end_op>
  }
  return -1;
80101018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010101d:	c9                   	leave  
8010101e:	c3                   	ret    

8010101f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010101f:	55                   	push   %ebp
80101020:	89 e5                	mov    %esp,%ebp
80101022:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101025:	83 ec 08             	sub    $0x8,%esp
80101028:	68 36 95 10 80       	push   $0x80109536
8010102d:	68 40 18 11 80       	push   $0x80111840
80101032:	e8 d9 4d 00 00       	call   80105e10 <initlock>
80101037:	83 c4 10             	add    $0x10,%esp
}
8010103a:	90                   	nop
8010103b:	c9                   	leave  
8010103c:	c3                   	ret    

8010103d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010103d:	55                   	push   %ebp
8010103e:	89 e5                	mov    %esp,%ebp
80101040:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101043:	83 ec 0c             	sub    $0xc,%esp
80101046:	68 40 18 11 80       	push   $0x80111840
8010104b:	e8 e2 4d 00 00       	call   80105e32 <acquire>
80101050:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101053:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
8010105a:	eb 2d                	jmp    80101089 <filealloc+0x4c>
    if(f->ref == 0){
8010105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010105f:	8b 40 04             	mov    0x4(%eax),%eax
80101062:	85 c0                	test   %eax,%eax
80101064:	75 1f                	jne    80101085 <filealloc+0x48>
      f->ref = 1;
80101066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101069:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101070:	83 ec 0c             	sub    $0xc,%esp
80101073:	68 40 18 11 80       	push   $0x80111840
80101078:	e8 1c 4e 00 00       	call   80105e99 <release>
8010107d:	83 c4 10             	add    $0x10,%esp
      return f;
80101080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101083:	eb 23                	jmp    801010a8 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101085:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101089:	b8 d4 21 11 80       	mov    $0x801121d4,%eax
8010108e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101091:	72 c9                	jb     8010105c <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101093:	83 ec 0c             	sub    $0xc,%esp
80101096:	68 40 18 11 80       	push   $0x80111840
8010109b:	e8 f9 4d 00 00       	call   80105e99 <release>
801010a0:	83 c4 10             	add    $0x10,%esp
  return 0;
801010a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010a8:	c9                   	leave  
801010a9:	c3                   	ret    

801010aa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010aa:	55                   	push   %ebp
801010ab:	89 e5                	mov    %esp,%ebp
801010ad:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010b0:	83 ec 0c             	sub    $0xc,%esp
801010b3:	68 40 18 11 80       	push   $0x80111840
801010b8:	e8 75 4d 00 00       	call   80105e32 <acquire>
801010bd:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	8b 40 04             	mov    0x4(%eax),%eax
801010c6:	85 c0                	test   %eax,%eax
801010c8:	7f 0d                	jg     801010d7 <filedup+0x2d>
    panic("filedup");
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 3d 95 10 80       	push   $0x8010953d
801010d2:	e8 8f f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	8d 50 01             	lea    0x1(%eax),%edx
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
801010e3:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010e6:	83 ec 0c             	sub    $0xc,%esp
801010e9:	68 40 18 11 80       	push   $0x80111840
801010ee:	e8 a6 4d 00 00       	call   80105e99 <release>
801010f3:	83 c4 10             	add    $0x10,%esp
  return f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010f9:	c9                   	leave  
801010fa:	c3                   	ret    

801010fb <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010fb:	55                   	push   %ebp
801010fc:	89 e5                	mov    %esp,%ebp
801010fe:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101101:	83 ec 0c             	sub    $0xc,%esp
80101104:	68 40 18 11 80       	push   $0x80111840
80101109:	e8 24 4d 00 00       	call   80105e32 <acquire>
8010110e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101111:	8b 45 08             	mov    0x8(%ebp),%eax
80101114:	8b 40 04             	mov    0x4(%eax),%eax
80101117:	85 c0                	test   %eax,%eax
80101119:	7f 0d                	jg     80101128 <fileclose+0x2d>
    panic("fileclose");
8010111b:	83 ec 0c             	sub    $0xc,%esp
8010111e:	68 45 95 10 80       	push   $0x80109545
80101123:	e8 3e f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101128:	8b 45 08             	mov    0x8(%ebp),%eax
8010112b:	8b 40 04             	mov    0x4(%eax),%eax
8010112e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101131:	8b 45 08             	mov    0x8(%ebp),%eax
80101134:	89 50 04             	mov    %edx,0x4(%eax)
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 40 04             	mov    0x4(%eax),%eax
8010113d:	85 c0                	test   %eax,%eax
8010113f:	7e 15                	jle    80101156 <fileclose+0x5b>
    release(&ftable.lock);
80101141:	83 ec 0c             	sub    $0xc,%esp
80101144:	68 40 18 11 80       	push   $0x80111840
80101149:	e8 4b 4d 00 00       	call   80105e99 <release>
8010114e:	83 c4 10             	add    $0x10,%esp
80101151:	e9 8b 00 00 00       	jmp    801011e1 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101156:	8b 45 08             	mov    0x8(%ebp),%eax
80101159:	8b 10                	mov    (%eax),%edx
8010115b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010115e:	8b 50 04             	mov    0x4(%eax),%edx
80101161:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101164:	8b 50 08             	mov    0x8(%eax),%edx
80101167:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010116a:	8b 50 0c             	mov    0xc(%eax),%edx
8010116d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101170:	8b 50 10             	mov    0x10(%eax),%edx
80101173:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101176:	8b 40 14             	mov    0x14(%eax),%eax
80101179:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101186:	8b 45 08             	mov    0x8(%ebp),%eax
80101189:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010118f:	83 ec 0c             	sub    $0xc,%esp
80101192:	68 40 18 11 80       	push   $0x80111840
80101197:	e8 fd 4c 00 00       	call   80105e99 <release>
8010119c:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010119f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a2:	83 f8 01             	cmp    $0x1,%eax
801011a5:	75 19                	jne    801011c0 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011a7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011ab:	0f be d0             	movsbl %al,%edx
801011ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011b1:	83 ec 08             	sub    $0x8,%esp
801011b4:	52                   	push   %edx
801011b5:	50                   	push   %eax
801011b6:	e8 83 30 00 00       	call   8010423e <pipeclose>
801011bb:	83 c4 10             	add    $0x10,%esp
801011be:	eb 21                	jmp    801011e1 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c3:	83 f8 02             	cmp    $0x2,%eax
801011c6:	75 19                	jne    801011e1 <fileclose+0xe6>
    begin_op();
801011c8:	e8 2a 24 00 00       	call   801035f7 <begin_op>
    iput(ff.ip);
801011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011d0:	83 ec 0c             	sub    $0xc,%esp
801011d3:	50                   	push   %eax
801011d4:	e8 0b 0a 00 00       	call   80101be4 <iput>
801011d9:	83 c4 10             	add    $0x10,%esp
    end_op();
801011dc:	e8 a2 24 00 00       	call   80103683 <end_op>
  }
}
801011e1:	c9                   	leave  
801011e2:	c3                   	ret    

801011e3 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011e3:	55                   	push   %ebp
801011e4:	89 e5                	mov    %esp,%ebp
801011e6:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 00                	mov    (%eax),%eax
801011ee:	83 f8 02             	cmp    $0x2,%eax
801011f1:	75 40                	jne    80101233 <filestat+0x50>
    ilock(f->ip);
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 40 10             	mov    0x10(%eax),%eax
801011f9:	83 ec 0c             	sub    $0xc,%esp
801011fc:	50                   	push   %eax
801011fd:	e8 12 08 00 00       	call   80101a14 <ilock>
80101202:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101205:	8b 45 08             	mov    0x8(%ebp),%eax
80101208:	8b 40 10             	mov    0x10(%eax),%eax
8010120b:	83 ec 08             	sub    $0x8,%esp
8010120e:	ff 75 0c             	pushl  0xc(%ebp)
80101211:	50                   	push   %eax
80101212:	e8 25 0d 00 00       	call   80101f3c <stati>
80101217:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 40 10             	mov    0x10(%eax),%eax
80101220:	83 ec 0c             	sub    $0xc,%esp
80101223:	50                   	push   %eax
80101224:	e8 49 09 00 00       	call   80101b72 <iunlock>
80101229:	83 c4 10             	add    $0x10,%esp
    return 0;
8010122c:	b8 00 00 00 00       	mov    $0x0,%eax
80101231:	eb 05                	jmp    80101238 <filestat+0x55>
  }
  return -1;
80101233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101238:	c9                   	leave  
80101239:	c3                   	ret    

8010123a <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010123a:	55                   	push   %ebp
8010123b:	89 e5                	mov    %esp,%ebp
8010123d:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101240:	8b 45 08             	mov    0x8(%ebp),%eax
80101243:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101247:	84 c0                	test   %al,%al
80101249:	75 0a                	jne    80101255 <fileread+0x1b>
    return -1;
8010124b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101250:	e9 9b 00 00 00       	jmp    801012f0 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101255:	8b 45 08             	mov    0x8(%ebp),%eax
80101258:	8b 00                	mov    (%eax),%eax
8010125a:	83 f8 01             	cmp    $0x1,%eax
8010125d:	75 1a                	jne    80101279 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010125f:	8b 45 08             	mov    0x8(%ebp),%eax
80101262:	8b 40 0c             	mov    0xc(%eax),%eax
80101265:	83 ec 04             	sub    $0x4,%esp
80101268:	ff 75 10             	pushl  0x10(%ebp)
8010126b:	ff 75 0c             	pushl  0xc(%ebp)
8010126e:	50                   	push   %eax
8010126f:	e8 72 31 00 00       	call   801043e6 <piperead>
80101274:	83 c4 10             	add    $0x10,%esp
80101277:	eb 77                	jmp    801012f0 <fileread+0xb6>
  if(f->type == FD_INODE){
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 00                	mov    (%eax),%eax
8010127e:	83 f8 02             	cmp    $0x2,%eax
80101281:	75 60                	jne    801012e3 <fileread+0xa9>
    ilock(f->ip);
80101283:	8b 45 08             	mov    0x8(%ebp),%eax
80101286:	8b 40 10             	mov    0x10(%eax),%eax
80101289:	83 ec 0c             	sub    $0xc,%esp
8010128c:	50                   	push   %eax
8010128d:	e8 82 07 00 00       	call   80101a14 <ilock>
80101292:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101295:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 50 14             	mov    0x14(%eax),%edx
8010129e:	8b 45 08             	mov    0x8(%ebp),%eax
801012a1:	8b 40 10             	mov    0x10(%eax),%eax
801012a4:	51                   	push   %ecx
801012a5:	52                   	push   %edx
801012a6:	ff 75 0c             	pushl  0xc(%ebp)
801012a9:	50                   	push   %eax
801012aa:	e8 d3 0c 00 00       	call   80101f82 <readi>
801012af:	83 c4 10             	add    $0x10,%esp
801012b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b9:	7e 11                	jle    801012cc <fileread+0x92>
      f->off += r;
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 50 14             	mov    0x14(%eax),%edx
801012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c4:	01 c2                	add    %eax,%edx
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012cc:	8b 45 08             	mov    0x8(%ebp),%eax
801012cf:	8b 40 10             	mov    0x10(%eax),%eax
801012d2:	83 ec 0c             	sub    $0xc,%esp
801012d5:	50                   	push   %eax
801012d6:	e8 97 08 00 00       	call   80101b72 <iunlock>
801012db:	83 c4 10             	add    $0x10,%esp
    return r;
801012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e1:	eb 0d                	jmp    801012f0 <fileread+0xb6>
  }
  panic("fileread");
801012e3:	83 ec 0c             	sub    $0xc,%esp
801012e6:	68 4f 95 10 80       	push   $0x8010954f
801012eb:	e8 76 f2 ff ff       	call   80100566 <panic>
}
801012f0:	c9                   	leave  
801012f1:	c3                   	ret    

801012f2 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012f2:	55                   	push   %ebp
801012f3:	89 e5                	mov    %esp,%ebp
801012f5:	53                   	push   %ebx
801012f6:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101300:	84 c0                	test   %al,%al
80101302:	75 0a                	jne    8010130e <filewrite+0x1c>
    return -1;
80101304:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101309:	e9 1b 01 00 00       	jmp    80101429 <filewrite+0x137>
  if(f->type == FD_PIPE)
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 00                	mov    (%eax),%eax
80101313:	83 f8 01             	cmp    $0x1,%eax
80101316:	75 1d                	jne    80101335 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 40 0c             	mov    0xc(%eax),%eax
8010131e:	83 ec 04             	sub    $0x4,%esp
80101321:	ff 75 10             	pushl  0x10(%ebp)
80101324:	ff 75 0c             	pushl  0xc(%ebp)
80101327:	50                   	push   %eax
80101328:	e8 bb 2f 00 00       	call   801042e8 <pipewrite>
8010132d:	83 c4 10             	add    $0x10,%esp
80101330:	e9 f4 00 00 00       	jmp    80101429 <filewrite+0x137>
  if(f->type == FD_INODE){
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 00                	mov    (%eax),%eax
8010133a:	83 f8 02             	cmp    $0x2,%eax
8010133d:	0f 85 d9 00 00 00    	jne    8010141c <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101343:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010134a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101351:	e9 a3 00 00 00       	jmp    801013f9 <filewrite+0x107>
      int n1 = n - i;
80101356:	8b 45 10             	mov    0x10(%ebp),%eax
80101359:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010135c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010135f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101362:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101365:	7e 06                	jle    8010136d <filewrite+0x7b>
        n1 = max;
80101367:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010136a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010136d:	e8 85 22 00 00       	call   801035f7 <begin_op>
      ilock(f->ip);
80101372:	8b 45 08             	mov    0x8(%ebp),%eax
80101375:	8b 40 10             	mov    0x10(%eax),%eax
80101378:	83 ec 0c             	sub    $0xc,%esp
8010137b:	50                   	push   %eax
8010137c:	e8 93 06 00 00       	call   80101a14 <ilock>
80101381:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101384:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101387:	8b 45 08             	mov    0x8(%ebp),%eax
8010138a:	8b 50 14             	mov    0x14(%eax),%edx
8010138d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101390:	8b 45 0c             	mov    0xc(%ebp),%eax
80101393:	01 c3                	add    %eax,%ebx
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	8b 40 10             	mov    0x10(%eax),%eax
8010139b:	51                   	push   %ecx
8010139c:	52                   	push   %edx
8010139d:	53                   	push   %ebx
8010139e:	50                   	push   %eax
8010139f:	e8 35 0d 00 00       	call   801020d9 <writei>
801013a4:	83 c4 10             	add    $0x10,%esp
801013a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ae:	7e 11                	jle    801013c1 <filewrite+0xcf>
        f->off += r;
801013b0:	8b 45 08             	mov    0x8(%ebp),%eax
801013b3:	8b 50 14             	mov    0x14(%eax),%edx
801013b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b9:	01 c2                	add    %eax,%edx
801013bb:	8b 45 08             	mov    0x8(%ebp),%eax
801013be:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013c1:	8b 45 08             	mov    0x8(%ebp),%eax
801013c4:	8b 40 10             	mov    0x10(%eax),%eax
801013c7:	83 ec 0c             	sub    $0xc,%esp
801013ca:	50                   	push   %eax
801013cb:	e8 a2 07 00 00       	call   80101b72 <iunlock>
801013d0:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d3:	e8 ab 22 00 00       	call   80103683 <end_op>

      if(r < 0)
801013d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013dc:	78 29                	js     80101407 <filewrite+0x115>
        break;
      if(r != n1)
801013de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e4:	74 0d                	je     801013f3 <filewrite+0x101>
        panic("short filewrite");
801013e6:	83 ec 0c             	sub    $0xc,%esp
801013e9:	68 58 95 10 80       	push   $0x80109558
801013ee:	e8 73 f1 ff ff       	call   80100566 <panic>
      i += r;
801013f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f6:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fc:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ff:	0f 8c 51 ff ff ff    	jl     80101356 <filewrite+0x64>
80101405:	eb 01                	jmp    80101408 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101407:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010140b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140e:	75 05                	jne    80101415 <filewrite+0x123>
80101410:	8b 45 10             	mov    0x10(%ebp),%eax
80101413:	eb 14                	jmp    80101429 <filewrite+0x137>
80101415:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010141a:	eb 0d                	jmp    80101429 <filewrite+0x137>
  }
  panic("filewrite");
8010141c:	83 ec 0c             	sub    $0xc,%esp
8010141f:	68 68 95 10 80       	push   $0x80109568
80101424:	e8 3d f1 ff ff       	call   80100566 <panic>
}
80101429:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010142c:	c9                   	leave  
8010142d:	c3                   	ret    

8010142e <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010142e:	55                   	push   %ebp
8010142f:	89 e5                	mov    %esp,%ebp
80101431:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101434:	8b 45 08             	mov    0x8(%ebp),%eax
80101437:	83 ec 08             	sub    $0x8,%esp
8010143a:	6a 01                	push   $0x1
8010143c:	50                   	push   %eax
8010143d:	e8 74 ed ff ff       	call   801001b6 <bread>
80101442:	83 c4 10             	add    $0x10,%esp
80101445:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144b:	83 c0 18             	add    $0x18,%eax
8010144e:	83 ec 04             	sub    $0x4,%esp
80101451:	6a 1c                	push   $0x1c
80101453:	50                   	push   %eax
80101454:	ff 75 0c             	pushl  0xc(%ebp)
80101457:	e8 f8 4c 00 00       	call   80106154 <memmove>
8010145c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145f:	83 ec 0c             	sub    $0xc,%esp
80101462:	ff 75 f4             	pushl  -0xc(%ebp)
80101465:	e8 c4 ed ff ff       	call   8010022e <brelse>
8010146a:	83 c4 10             	add    $0x10,%esp
}
8010146d:	90                   	nop
8010146e:	c9                   	leave  
8010146f:	c3                   	ret    

80101470 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101470:	55                   	push   %ebp
80101471:	89 e5                	mov    %esp,%ebp
80101473:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101476:	8b 55 0c             	mov    0xc(%ebp),%edx
80101479:	8b 45 08             	mov    0x8(%ebp),%eax
8010147c:	83 ec 08             	sub    $0x8,%esp
8010147f:	52                   	push   %edx
80101480:	50                   	push   %eax
80101481:	e8 30 ed ff ff       	call   801001b6 <bread>
80101486:	83 c4 10             	add    $0x10,%esp
80101489:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148f:	83 c0 18             	add    $0x18,%eax
80101492:	83 ec 04             	sub    $0x4,%esp
80101495:	68 00 02 00 00       	push   $0x200
8010149a:	6a 00                	push   $0x0
8010149c:	50                   	push   %eax
8010149d:	e8 f3 4b 00 00       	call   80106095 <memset>
801014a2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014a5:	83 ec 0c             	sub    $0xc,%esp
801014a8:	ff 75 f4             	pushl  -0xc(%ebp)
801014ab:	e8 7f 23 00 00       	call   8010382f <log_write>
801014b0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b3:	83 ec 0c             	sub    $0xc,%esp
801014b6:	ff 75 f4             	pushl  -0xc(%ebp)
801014b9:	e8 70 ed ff ff       	call   8010022e <brelse>
801014be:	83 c4 10             	add    $0x10,%esp
}
801014c1:	90                   	nop
801014c2:	c9                   	leave  
801014c3:	c3                   	ret    

801014c4 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014c4:	55                   	push   %ebp
801014c5:	89 e5                	mov    %esp,%ebp
801014c7:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014d8:	e9 13 01 00 00       	jmp    801015f0 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014e6:	85 c0                	test   %eax,%eax
801014e8:	0f 48 c2             	cmovs  %edx,%eax
801014eb:	c1 f8 0c             	sar    $0xc,%eax
801014ee:	89 c2                	mov    %eax,%edx
801014f0:	a1 58 22 11 80       	mov    0x80112258,%eax
801014f5:	01 d0                	add    %edx,%eax
801014f7:	83 ec 08             	sub    $0x8,%esp
801014fa:	50                   	push   %eax
801014fb:	ff 75 08             	pushl  0x8(%ebp)
801014fe:	e8 b3 ec ff ff       	call   801001b6 <bread>
80101503:	83 c4 10             	add    $0x10,%esp
80101506:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101509:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101510:	e9 a6 00 00 00       	jmp    801015bb <balloc+0xf7>
      m = 1 << (bi % 8);
80101515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101518:	99                   	cltd   
80101519:	c1 ea 1d             	shr    $0x1d,%edx
8010151c:	01 d0                	add    %edx,%eax
8010151e:	83 e0 07             	and    $0x7,%eax
80101521:	29 d0                	sub    %edx,%eax
80101523:	ba 01 00 00 00       	mov    $0x1,%edx
80101528:	89 c1                	mov    %eax,%ecx
8010152a:	d3 e2                	shl    %cl,%edx
8010152c:	89 d0                	mov    %edx,%eax
8010152e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101534:	8d 50 07             	lea    0x7(%eax),%edx
80101537:	85 c0                	test   %eax,%eax
80101539:	0f 48 c2             	cmovs  %edx,%eax
8010153c:	c1 f8 03             	sar    $0x3,%eax
8010153f:	89 c2                	mov    %eax,%edx
80101541:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101544:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101549:	0f b6 c0             	movzbl %al,%eax
8010154c:	23 45 e8             	and    -0x18(%ebp),%eax
8010154f:	85 c0                	test   %eax,%eax
80101551:	75 64                	jne    801015b7 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
80101553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101556:	8d 50 07             	lea    0x7(%eax),%edx
80101559:	85 c0                	test   %eax,%eax
8010155b:	0f 48 c2             	cmovs  %edx,%eax
8010155e:	c1 f8 03             	sar    $0x3,%eax
80101561:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101564:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101569:	89 d1                	mov    %edx,%ecx
8010156b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010156e:	09 ca                	or     %ecx,%edx
80101570:	89 d1                	mov    %edx,%ecx
80101572:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101575:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101579:	83 ec 0c             	sub    $0xc,%esp
8010157c:	ff 75 ec             	pushl  -0x14(%ebp)
8010157f:	e8 ab 22 00 00       	call   8010382f <log_write>
80101584:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101587:	83 ec 0c             	sub    $0xc,%esp
8010158a:	ff 75 ec             	pushl  -0x14(%ebp)
8010158d:	e8 9c ec ff ff       	call   8010022e <brelse>
80101592:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101595:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159b:	01 c2                	add    %eax,%edx
8010159d:	8b 45 08             	mov    0x8(%ebp),%eax
801015a0:	83 ec 08             	sub    $0x8,%esp
801015a3:	52                   	push   %edx
801015a4:	50                   	push   %eax
801015a5:	e8 c6 fe ff ff       	call   80101470 <bzero>
801015aa:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b3:	01 d0                	add    %edx,%eax
801015b5:	eb 57                	jmp    8010160e <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015b7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015bb:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015c2:	7f 17                	jg     801015db <balloc+0x117>
801015c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ca:	01 d0                	add    %edx,%eax
801015cc:	89 c2                	mov    %eax,%edx
801015ce:	a1 40 22 11 80       	mov    0x80112240,%eax
801015d3:	39 c2                	cmp    %eax,%edx
801015d5:	0f 82 3a ff ff ff    	jb     80101515 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015db:	83 ec 0c             	sub    $0xc,%esp
801015de:	ff 75 ec             	pushl  -0x14(%ebp)
801015e1:	e8 48 ec ff ff       	call   8010022e <brelse>
801015e6:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015e9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015f0:	8b 15 40 22 11 80    	mov    0x80112240,%edx
801015f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f9:	39 c2                	cmp    %eax,%edx
801015fb:	0f 87 dc fe ff ff    	ja     801014dd <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101601:	83 ec 0c             	sub    $0xc,%esp
80101604:	68 74 95 10 80       	push   $0x80109574
80101609:	e8 58 ef ff ff       	call   80100566 <panic>
}
8010160e:	c9                   	leave  
8010160f:	c3                   	ret    

80101610 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101610:	55                   	push   %ebp
80101611:	89 e5                	mov    %esp,%ebp
80101613:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101616:	83 ec 08             	sub    $0x8,%esp
80101619:	68 40 22 11 80       	push   $0x80112240
8010161e:	ff 75 08             	pushl  0x8(%ebp)
80101621:	e8 08 fe ff ff       	call   8010142e <readsb>
80101626:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010162c:	c1 e8 0c             	shr    $0xc,%eax
8010162f:	89 c2                	mov    %eax,%edx
80101631:	a1 58 22 11 80       	mov    0x80112258,%eax
80101636:	01 c2                	add    %eax,%edx
80101638:	8b 45 08             	mov    0x8(%ebp),%eax
8010163b:	83 ec 08             	sub    $0x8,%esp
8010163e:	52                   	push   %edx
8010163f:	50                   	push   %eax
80101640:	e8 71 eb ff ff       	call   801001b6 <bread>
80101645:	83 c4 10             	add    $0x10,%esp
80101648:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010164b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101653:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101659:	99                   	cltd   
8010165a:	c1 ea 1d             	shr    $0x1d,%edx
8010165d:	01 d0                	add    %edx,%eax
8010165f:	83 e0 07             	and    $0x7,%eax
80101662:	29 d0                	sub    %edx,%eax
80101664:	ba 01 00 00 00       	mov    $0x1,%edx
80101669:	89 c1                	mov    %eax,%ecx
8010166b:	d3 e2                	shl    %cl,%edx
8010166d:	89 d0                	mov    %edx,%eax
8010166f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101675:	8d 50 07             	lea    0x7(%eax),%edx
80101678:	85 c0                	test   %eax,%eax
8010167a:	0f 48 c2             	cmovs  %edx,%eax
8010167d:	c1 f8 03             	sar    $0x3,%eax
80101680:	89 c2                	mov    %eax,%edx
80101682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101685:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010168a:	0f b6 c0             	movzbl %al,%eax
8010168d:	23 45 ec             	and    -0x14(%ebp),%eax
80101690:	85 c0                	test   %eax,%eax
80101692:	75 0d                	jne    801016a1 <bfree+0x91>
    panic("freeing free block");
80101694:	83 ec 0c             	sub    $0xc,%esp
80101697:	68 8a 95 10 80       	push   $0x8010958a
8010169c:	e8 c5 ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a4:	8d 50 07             	lea    0x7(%eax),%edx
801016a7:	85 c0                	test   %eax,%eax
801016a9:	0f 48 c2             	cmovs  %edx,%eax
801016ac:	c1 f8 03             	sar    $0x3,%eax
801016af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b2:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016b7:	89 d1                	mov    %edx,%ecx
801016b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016bc:	f7 d2                	not    %edx
801016be:	21 ca                	and    %ecx,%edx
801016c0:	89 d1                	mov    %edx,%ecx
801016c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016c9:	83 ec 0c             	sub    $0xc,%esp
801016cc:	ff 75 f4             	pushl  -0xc(%ebp)
801016cf:	e8 5b 21 00 00       	call   8010382f <log_write>
801016d4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	pushl  -0xc(%ebp)
801016dd:	e8 4c eb ff ff       	call   8010022e <brelse>
801016e2:	83 c4 10             	add    $0x10,%esp
}
801016e5:	90                   	nop
801016e6:	c9                   	leave  
801016e7:	c3                   	ret    

801016e8 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016e8:	55                   	push   %ebp
801016e9:	89 e5                	mov    %esp,%ebp
801016eb:	57                   	push   %edi
801016ec:	56                   	push   %esi
801016ed:	53                   	push   %ebx
801016ee:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016f1:	83 ec 08             	sub    $0x8,%esp
801016f4:	68 9d 95 10 80       	push   $0x8010959d
801016f9:	68 60 22 11 80       	push   $0x80112260
801016fe:	e8 0d 47 00 00       	call   80105e10 <initlock>
80101703:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101706:	83 ec 08             	sub    $0x8,%esp
80101709:	68 40 22 11 80       	push   $0x80112240
8010170e:	ff 75 08             	pushl  0x8(%ebp)
80101711:	e8 18 fd ff ff       	call   8010142e <readsb>
80101716:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101719:	a1 58 22 11 80       	mov    0x80112258,%eax
8010171e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101721:	8b 3d 54 22 11 80    	mov    0x80112254,%edi
80101727:	8b 35 50 22 11 80    	mov    0x80112250,%esi
8010172d:	8b 1d 4c 22 11 80    	mov    0x8011224c,%ebx
80101733:	8b 0d 48 22 11 80    	mov    0x80112248,%ecx
80101739:	8b 15 44 22 11 80    	mov    0x80112244,%edx
8010173f:	a1 40 22 11 80       	mov    0x80112240,%eax
80101744:	ff 75 e4             	pushl  -0x1c(%ebp)
80101747:	57                   	push   %edi
80101748:	56                   	push   %esi
80101749:	53                   	push   %ebx
8010174a:	51                   	push   %ecx
8010174b:	52                   	push   %edx
8010174c:	50                   	push   %eax
8010174d:	68 a4 95 10 80       	push   $0x801095a4
80101752:	e8 6f ec ff ff       	call   801003c6 <cprintf>
80101757:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
8010175a:	90                   	nop
8010175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010175e:	5b                   	pop    %ebx
8010175f:	5e                   	pop    %esi
80101760:	5f                   	pop    %edi
80101761:	5d                   	pop    %ebp
80101762:	c3                   	ret    

80101763 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101763:	55                   	push   %ebp
80101764:	89 e5                	mov    %esp,%ebp
80101766:	83 ec 28             	sub    $0x28,%esp
80101769:	8b 45 0c             	mov    0xc(%ebp),%eax
8010176c:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101770:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101777:	e9 9e 00 00 00       	jmp    8010181a <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177f:	c1 e8 03             	shr    $0x3,%eax
80101782:	89 c2                	mov    %eax,%edx
80101784:	a1 54 22 11 80       	mov    0x80112254,%eax
80101789:	01 d0                	add    %edx,%eax
8010178b:	83 ec 08             	sub    $0x8,%esp
8010178e:	50                   	push   %eax
8010178f:	ff 75 08             	pushl  0x8(%ebp)
80101792:	e8 1f ea ff ff       	call   801001b6 <bread>
80101797:	83 c4 10             	add    $0x10,%esp
8010179a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a0:	8d 50 18             	lea    0x18(%eax),%edx
801017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a6:	83 e0 07             	and    $0x7,%eax
801017a9:	c1 e0 06             	shl    $0x6,%eax
801017ac:	01 d0                	add    %edx,%eax
801017ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b4:	0f b7 00             	movzwl (%eax),%eax
801017b7:	66 85 c0             	test   %ax,%ax
801017ba:	75 4c                	jne    80101808 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017bc:	83 ec 04             	sub    $0x4,%esp
801017bf:	6a 40                	push   $0x40
801017c1:	6a 00                	push   $0x0
801017c3:	ff 75 ec             	pushl  -0x14(%ebp)
801017c6:	e8 ca 48 00 00       	call   80106095 <memset>
801017cb:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d1:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017d5:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017d8:	83 ec 0c             	sub    $0xc,%esp
801017db:	ff 75 f0             	pushl  -0x10(%ebp)
801017de:	e8 4c 20 00 00       	call   8010382f <log_write>
801017e3:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017e6:	83 ec 0c             	sub    $0xc,%esp
801017e9:	ff 75 f0             	pushl  -0x10(%ebp)
801017ec:	e8 3d ea ff ff       	call   8010022e <brelse>
801017f1:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f7:	83 ec 08             	sub    $0x8,%esp
801017fa:	50                   	push   %eax
801017fb:	ff 75 08             	pushl  0x8(%ebp)
801017fe:	e8 f8 00 00 00       	call   801018fb <iget>
80101803:	83 c4 10             	add    $0x10,%esp
80101806:	eb 30                	jmp    80101838 <ialloc+0xd5>
    }
    brelse(bp);
80101808:	83 ec 0c             	sub    $0xc,%esp
8010180b:	ff 75 f0             	pushl  -0x10(%ebp)
8010180e:	e8 1b ea ff ff       	call   8010022e <brelse>
80101813:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101816:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010181a:	8b 15 48 22 11 80    	mov    0x80112248,%edx
80101820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101823:	39 c2                	cmp    %eax,%edx
80101825:	0f 87 51 ff ff ff    	ja     8010177c <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010182b:	83 ec 0c             	sub    $0xc,%esp
8010182e:	68 f7 95 10 80       	push   $0x801095f7
80101833:	e8 2e ed ff ff       	call   80100566 <panic>
}
80101838:	c9                   	leave  
80101839:	c3                   	ret    

8010183a <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010183a:	55                   	push   %ebp
8010183b:	89 e5                	mov    %esp,%ebp
8010183d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	c1 e8 03             	shr    $0x3,%eax
80101849:	89 c2                	mov    %eax,%edx
8010184b:	a1 54 22 11 80       	mov    0x80112254,%eax
80101850:	01 c2                	add    %eax,%edx
80101852:	8b 45 08             	mov    0x8(%ebp),%eax
80101855:	8b 00                	mov    (%eax),%eax
80101857:	83 ec 08             	sub    $0x8,%esp
8010185a:	52                   	push   %edx
8010185b:	50                   	push   %eax
8010185c:	e8 55 e9 ff ff       	call   801001b6 <bread>
80101861:	83 c4 10             	add    $0x10,%esp
80101864:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186a:	8d 50 18             	lea    0x18(%eax),%edx
8010186d:	8b 45 08             	mov    0x8(%ebp),%eax
80101870:	8b 40 04             	mov    0x4(%eax),%eax
80101873:	83 e0 07             	and    $0x7,%eax
80101876:	c1 e0 06             	shl    $0x6,%eax
80101879:	01 d0                	add    %edx,%eax
8010187b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010187e:	8b 45 08             	mov    0x8(%ebp),%eax
80101881:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101888:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010188b:	8b 45 08             	mov    0x8(%ebp),%eax
8010188e:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101895:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101899:	8b 45 08             	mov    0x8(%ebp),%eax
8010189c:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801018a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a3:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018a7:	8b 45 08             	mov    0x8(%ebp),%eax
801018aa:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b1:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018b5:	8b 45 08             	mov    0x8(%ebp),%eax
801018b8:	8b 50 18             	mov    0x18(%eax),%edx
801018bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018be:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018c1:	8b 45 08             	mov    0x8(%ebp),%eax
801018c4:	8d 50 1c             	lea    0x1c(%eax),%edx
801018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ca:	83 c0 0c             	add    $0xc,%eax
801018cd:	83 ec 04             	sub    $0x4,%esp
801018d0:	6a 34                	push   $0x34
801018d2:	52                   	push   %edx
801018d3:	50                   	push   %eax
801018d4:	e8 7b 48 00 00       	call   80106154 <memmove>
801018d9:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	ff 75 f4             	pushl  -0xc(%ebp)
801018e2:	e8 48 1f 00 00       	call   8010382f <log_write>
801018e7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018ea:	83 ec 0c             	sub    $0xc,%esp
801018ed:	ff 75 f4             	pushl  -0xc(%ebp)
801018f0:	e8 39 e9 ff ff       	call   8010022e <brelse>
801018f5:	83 c4 10             	add    $0x10,%esp
}
801018f8:	90                   	nop
801018f9:	c9                   	leave  
801018fa:	c3                   	ret    

801018fb <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018fb:	55                   	push   %ebp
801018fc:	89 e5                	mov    %esp,%ebp
801018fe:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101901:	83 ec 0c             	sub    $0xc,%esp
80101904:	68 60 22 11 80       	push   $0x80112260
80101909:	e8 24 45 00 00       	call   80105e32 <acquire>
8010190e:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101911:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101918:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
8010191f:	eb 5d                	jmp    8010197e <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101924:	8b 40 08             	mov    0x8(%eax),%eax
80101927:	85 c0                	test   %eax,%eax
80101929:	7e 39                	jle    80101964 <iget+0x69>
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192e:	8b 00                	mov    (%eax),%eax
80101930:	3b 45 08             	cmp    0x8(%ebp),%eax
80101933:	75 2f                	jne    80101964 <iget+0x69>
80101935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101938:	8b 40 04             	mov    0x4(%eax),%eax
8010193b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010193e:	75 24                	jne    80101964 <iget+0x69>
      ip->ref++;
80101940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101943:	8b 40 08             	mov    0x8(%eax),%eax
80101946:	8d 50 01             	lea    0x1(%eax),%edx
80101949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010194f:	83 ec 0c             	sub    $0xc,%esp
80101952:	68 60 22 11 80       	push   $0x80112260
80101957:	e8 3d 45 00 00       	call   80105e99 <release>
8010195c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010195f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101962:	eb 74                	jmp    801019d8 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101964:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101968:	75 10                	jne    8010197a <iget+0x7f>
8010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196d:	8b 40 08             	mov    0x8(%eax),%eax
80101970:	85 c0                	test   %eax,%eax
80101972:	75 06                	jne    8010197a <iget+0x7f>
      empty = ip;
80101974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101977:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010197a:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010197e:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
80101985:	72 9a                	jb     80101921 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101987:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010198b:	75 0d                	jne    8010199a <iget+0x9f>
    panic("iget: no inodes");
8010198d:	83 ec 0c             	sub    $0xc,%esp
80101990:	68 09 96 10 80       	push   $0x80109609
80101995:	e8 cc eb ff ff       	call   80100566 <panic>

  ip = empty;
8010199a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a3:	8b 55 08             	mov    0x8(%ebp),%edx
801019a6:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801019ae:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019c5:	83 ec 0c             	sub    $0xc,%esp
801019c8:	68 60 22 11 80       	push   $0x80112260
801019cd:	e8 c7 44 00 00       	call   80105e99 <release>
801019d2:	83 c4 10             	add    $0x10,%esp

  return ip;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019d8:	c9                   	leave  
801019d9:	c3                   	ret    

801019da <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019da:	55                   	push   %ebp
801019db:	89 e5                	mov    %esp,%ebp
801019dd:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019e0:	83 ec 0c             	sub    $0xc,%esp
801019e3:	68 60 22 11 80       	push   $0x80112260
801019e8:	e8 45 44 00 00       	call   80105e32 <acquire>
801019ed:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019f0:	8b 45 08             	mov    0x8(%ebp),%eax
801019f3:	8b 40 08             	mov    0x8(%eax),%eax
801019f6:	8d 50 01             	lea    0x1(%eax),%edx
801019f9:	8b 45 08             	mov    0x8(%ebp),%eax
801019fc:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019ff:	83 ec 0c             	sub    $0xc,%esp
80101a02:	68 60 22 11 80       	push   $0x80112260
80101a07:	e8 8d 44 00 00       	call   80105e99 <release>
80101a0c:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a12:	c9                   	leave  
80101a13:	c3                   	ret    

80101a14 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a14:	55                   	push   %ebp
80101a15:	89 e5                	mov    %esp,%ebp
80101a17:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a1a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a1e:	74 0a                	je     80101a2a <ilock+0x16>
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 08             	mov    0x8(%eax),%eax
80101a26:	85 c0                	test   %eax,%eax
80101a28:	7f 0d                	jg     80101a37 <ilock+0x23>
    panic("ilock");
80101a2a:	83 ec 0c             	sub    $0xc,%esp
80101a2d:	68 19 96 10 80       	push   $0x80109619
80101a32:	e8 2f eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a37:	83 ec 0c             	sub    $0xc,%esp
80101a3a:	68 60 22 11 80       	push   $0x80112260
80101a3f:	e8 ee 43 00 00       	call   80105e32 <acquire>
80101a44:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a47:	eb 13                	jmp    80101a5c <ilock+0x48>
    sleep(ip, &icache.lock);
80101a49:	83 ec 08             	sub    $0x8,%esp
80101a4c:	68 60 22 11 80       	push   $0x80112260
80101a51:	ff 75 08             	pushl  0x8(%ebp)
80101a54:	e8 aa 39 00 00       	call   80105403 <sleep>
80101a59:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a62:	83 e0 01             	and    $0x1,%eax
80101a65:	85 c0                	test   %eax,%eax
80101a67:	75 e0                	jne    80101a49 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a69:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6f:	83 c8 01             	or     $0x1,%eax
80101a72:	89 c2                	mov    %eax,%edx
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a7a:	83 ec 0c             	sub    $0xc,%esp
80101a7d:	68 60 22 11 80       	push   $0x80112260
80101a82:	e8 12 44 00 00       	call   80105e99 <release>
80101a87:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a90:	83 e0 02             	and    $0x2,%eax
80101a93:	85 c0                	test   %eax,%eax
80101a95:	0f 85 d4 00 00 00    	jne    80101b6f <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	8b 40 04             	mov    0x4(%eax),%eax
80101aa1:	c1 e8 03             	shr    $0x3,%eax
80101aa4:	89 c2                	mov    %eax,%edx
80101aa6:	a1 54 22 11 80       	mov    0x80112254,%eax
80101aab:	01 c2                	add    %eax,%edx
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	8b 00                	mov    (%eax),%eax
80101ab2:	83 ec 08             	sub    $0x8,%esp
80101ab5:	52                   	push   %edx
80101ab6:	50                   	push   %eax
80101ab7:	e8 fa e6 ff ff       	call   801001b6 <bread>
80101abc:	83 c4 10             	add    $0x10,%esp
80101abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac5:	8d 50 18             	lea    0x18(%eax),%edx
80101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80101acb:	8b 40 04             	mov    0x4(%eax),%eax
80101ace:	83 e0 07             	and    $0x7,%eax
80101ad1:	c1 e0 06             	shl    $0x6,%eax
80101ad4:	01 d0                	add    %edx,%eax
80101ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101adc:	0f b7 10             	movzwl (%eax),%edx
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af7:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101afb:	8b 45 08             	mov    0x8(%ebp),%eax
80101afe:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b05:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b13:	8b 50 08             	mov    0x8(%eax),%edx
80101b16:	8b 45 08             	mov    0x8(%ebp),%eax
80101b19:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	8d 50 0c             	lea    0xc(%eax),%edx
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	83 c0 1c             	add    $0x1c,%eax
80101b28:	83 ec 04             	sub    $0x4,%esp
80101b2b:	6a 34                	push   $0x34
80101b2d:	52                   	push   %edx
80101b2e:	50                   	push   %eax
80101b2f:	e8 20 46 00 00       	call   80106154 <memmove>
80101b34:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b37:	83 ec 0c             	sub    $0xc,%esp
80101b3a:	ff 75 f4             	pushl  -0xc(%ebp)
80101b3d:	e8 ec e6 ff ff       	call   8010022e <brelse>
80101b42:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b45:	8b 45 08             	mov    0x8(%ebp),%eax
80101b48:	8b 40 0c             	mov    0xc(%eax),%eax
80101b4b:	83 c8 02             	or     $0x2,%eax
80101b4e:	89 c2                	mov    %eax,%edx
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
80101b59:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b5d:	66 85 c0             	test   %ax,%ax
80101b60:	75 0d                	jne    80101b6f <ilock+0x15b>
      panic("ilock: no type");
80101b62:	83 ec 0c             	sub    $0xc,%esp
80101b65:	68 1f 96 10 80       	push   $0x8010961f
80101b6a:	e8 f7 e9 ff ff       	call   80100566 <panic>
  }
}
80101b6f:	90                   	nop
80101b70:	c9                   	leave  
80101b71:	c3                   	ret    

80101b72 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b72:	55                   	push   %ebp
80101b73:	89 e5                	mov    %esp,%ebp
80101b75:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b7c:	74 17                	je     80101b95 <iunlock+0x23>
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 40 0c             	mov    0xc(%eax),%eax
80101b84:	83 e0 01             	and    $0x1,%eax
80101b87:	85 c0                	test   %eax,%eax
80101b89:	74 0a                	je     80101b95 <iunlock+0x23>
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 40 08             	mov    0x8(%eax),%eax
80101b91:	85 c0                	test   %eax,%eax
80101b93:	7f 0d                	jg     80101ba2 <iunlock+0x30>
    panic("iunlock");
80101b95:	83 ec 0c             	sub    $0xc,%esp
80101b98:	68 2e 96 10 80       	push   $0x8010962e
80101b9d:	e8 c4 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101ba2:	83 ec 0c             	sub    $0xc,%esp
80101ba5:	68 60 22 11 80       	push   $0x80112260
80101baa:	e8 83 42 00 00       	call   80105e32 <acquire>
80101baf:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb5:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb8:	83 e0 fe             	and    $0xfffffffe,%eax
80101bbb:	89 c2                	mov    %eax,%edx
80101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc0:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	ff 75 08             	pushl  0x8(%ebp)
80101bc9:	e8 b0 39 00 00       	call   8010557e <wakeup>
80101bce:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bd1:	83 ec 0c             	sub    $0xc,%esp
80101bd4:	68 60 22 11 80       	push   $0x80112260
80101bd9:	e8 bb 42 00 00       	call   80105e99 <release>
80101bde:	83 c4 10             	add    $0x10,%esp
}
80101be1:	90                   	nop
80101be2:	c9                   	leave  
80101be3:	c3                   	ret    

80101be4 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be4:	55                   	push   %ebp
80101be5:	89 e5                	mov    %esp,%ebp
80101be7:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101bea:	83 ec 0c             	sub    $0xc,%esp
80101bed:	68 60 22 11 80       	push   $0x80112260
80101bf2:	e8 3b 42 00 00       	call   80105e32 <acquire>
80101bf7:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 08             	mov    0x8(%eax),%eax
80101c00:	83 f8 01             	cmp    $0x1,%eax
80101c03:	0f 85 a9 00 00 00    	jne    80101cb2 <iput+0xce>
80101c09:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0c:	8b 40 0c             	mov    0xc(%eax),%eax
80101c0f:	83 e0 02             	and    $0x2,%eax
80101c12:	85 c0                	test   %eax,%eax
80101c14:	0f 84 98 00 00 00    	je     80101cb2 <iput+0xce>
80101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c21:	66 85 c0             	test   %ax,%ax
80101c24:	0f 85 88 00 00 00    	jne    80101cb2 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2d:	8b 40 0c             	mov    0xc(%eax),%eax
80101c30:	83 e0 01             	and    $0x1,%eax
80101c33:	85 c0                	test   %eax,%eax
80101c35:	74 0d                	je     80101c44 <iput+0x60>
      panic("iput busy");
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	68 36 96 10 80       	push   $0x80109636
80101c3f:	e8 22 e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101c44:	8b 45 08             	mov    0x8(%ebp),%eax
80101c47:	8b 40 0c             	mov    0xc(%eax),%eax
80101c4a:	83 c8 01             	or     $0x1,%eax
80101c4d:	89 c2                	mov    %eax,%edx
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c55:	83 ec 0c             	sub    $0xc,%esp
80101c58:	68 60 22 11 80       	push   $0x80112260
80101c5d:	e8 37 42 00 00       	call   80105e99 <release>
80101c62:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101c65:	83 ec 0c             	sub    $0xc,%esp
80101c68:	ff 75 08             	pushl  0x8(%ebp)
80101c6b:	e8 a8 01 00 00       	call   80101e18 <itrunc>
80101c70:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101c73:	8b 45 08             	mov    0x8(%ebp),%eax
80101c76:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c7c:	83 ec 0c             	sub    $0xc,%esp
80101c7f:	ff 75 08             	pushl  0x8(%ebp)
80101c82:	e8 b3 fb ff ff       	call   8010183a <iupdate>
80101c87:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c8a:	83 ec 0c             	sub    $0xc,%esp
80101c8d:	68 60 22 11 80       	push   $0x80112260
80101c92:	e8 9b 41 00 00       	call   80105e32 <acquire>
80101c97:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ca4:	83 ec 0c             	sub    $0xc,%esp
80101ca7:	ff 75 08             	pushl  0x8(%ebp)
80101caa:	e8 cf 38 00 00       	call   8010557e <wakeup>
80101caf:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	8b 40 08             	mov    0x8(%eax),%eax
80101cb8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cc1:	83 ec 0c             	sub    $0xc,%esp
80101cc4:	68 60 22 11 80       	push   $0x80112260
80101cc9:	e8 cb 41 00 00       	call   80105e99 <release>
80101cce:	83 c4 10             	add    $0x10,%esp
}
80101cd1:	90                   	nop
80101cd2:	c9                   	leave  
80101cd3:	c3                   	ret    

80101cd4 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cd4:	55                   	push   %ebp
80101cd5:	89 e5                	mov    %esp,%ebp
80101cd7:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cda:	83 ec 0c             	sub    $0xc,%esp
80101cdd:	ff 75 08             	pushl  0x8(%ebp)
80101ce0:	e8 8d fe ff ff       	call   80101b72 <iunlock>
80101ce5:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ce8:	83 ec 0c             	sub    $0xc,%esp
80101ceb:	ff 75 08             	pushl  0x8(%ebp)
80101cee:	e8 f1 fe ff ff       	call   80101be4 <iput>
80101cf3:	83 c4 10             	add    $0x10,%esp
}
80101cf6:	90                   	nop
80101cf7:	c9                   	leave  
80101cf8:	c3                   	ret    

80101cf9 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cf9:	55                   	push   %ebp
80101cfa:	89 e5                	mov    %esp,%ebp
80101cfc:	53                   	push   %ebx
80101cfd:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d00:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d04:	77 42                	ja     80101d48 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d0c:	83 c2 04             	add    $0x4,%edx
80101d0f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d1a:	75 24                	jne    80101d40 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 00                	mov    (%eax),%eax
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	50                   	push   %eax
80101d25:	e8 9a f7 ff ff       	call   801014c4 <balloc>
80101d2a:	83 c4 10             	add    $0x10,%esp
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d36:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d43:	e9 cb 00 00 00       	jmp    80101e13 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101d48:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d50:	0f 87 b0 00 00 00    	ja     80101e06 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d63:	75 1d                	jne    80101d82 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d65:	8b 45 08             	mov    0x8(%ebp),%eax
80101d68:	8b 00                	mov    (%eax),%eax
80101d6a:	83 ec 0c             	sub    $0xc,%esp
80101d6d:	50                   	push   %eax
80101d6e:	e8 51 f7 ff ff       	call   801014c4 <balloc>
80101d73:	83 c4 10             	add    $0x10,%esp
80101d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d79:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7f:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d82:	8b 45 08             	mov    0x8(%ebp),%eax
80101d85:	8b 00                	mov    (%eax),%eax
80101d87:	83 ec 08             	sub    $0x8,%esp
80101d8a:	ff 75 f4             	pushl  -0xc(%ebp)
80101d8d:	50                   	push   %eax
80101d8e:	e8 23 e4 ff ff       	call   801001b6 <bread>
80101d93:	83 c4 10             	add    $0x10,%esp
80101d96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9c:	83 c0 18             	add    $0x18,%eax
80101d9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101daf:	01 d0                	add    %edx,%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dba:	75 37                	jne    80101df3 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dc9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	8b 00                	mov    (%eax),%eax
80101dd1:	83 ec 0c             	sub    $0xc,%esp
80101dd4:	50                   	push   %eax
80101dd5:	e8 ea f6 ff ff       	call   801014c4 <balloc>
80101dda:	83 c4 10             	add    $0x10,%esp
80101ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de3:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101de5:	83 ec 0c             	sub    $0xc,%esp
80101de8:	ff 75 f0             	pushl  -0x10(%ebp)
80101deb:	e8 3f 1a 00 00       	call   8010382f <log_write>
80101df0:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101df3:	83 ec 0c             	sub    $0xc,%esp
80101df6:	ff 75 f0             	pushl  -0x10(%ebp)
80101df9:	e8 30 e4 ff ff       	call   8010022e <brelse>
80101dfe:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e04:	eb 0d                	jmp    80101e13 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101e06:	83 ec 0c             	sub    $0xc,%esp
80101e09:	68 40 96 10 80       	push   $0x80109640
80101e0e:	e8 53 e7 ff ff       	call   80100566 <panic>
}
80101e13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e16:	c9                   	leave  
80101e17:	c3                   	ret    

80101e18 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e18:	55                   	push   %ebp
80101e19:	89 e5                	mov    %esp,%ebp
80101e1b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e25:	eb 45                	jmp    80101e6c <itrunc+0x54>
    if(ip->addrs[i]){
80101e27:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e2d:	83 c2 04             	add    $0x4,%edx
80101e30:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e34:	85 c0                	test   %eax,%eax
80101e36:	74 30                	je     80101e68 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e38:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e3e:	83 c2 04             	add    $0x4,%edx
80101e41:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e45:	8b 55 08             	mov    0x8(%ebp),%edx
80101e48:	8b 12                	mov    (%edx),%edx
80101e4a:	83 ec 08             	sub    $0x8,%esp
80101e4d:	50                   	push   %eax
80101e4e:	52                   	push   %edx
80101e4f:	e8 bc f7 ff ff       	call   80101610 <bfree>
80101e54:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e57:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e5d:	83 c2 04             	add    $0x4,%edx
80101e60:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e67:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e68:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e6c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e70:	7e b5                	jle    80101e27 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e72:	8b 45 08             	mov    0x8(%ebp),%eax
80101e75:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e78:	85 c0                	test   %eax,%eax
80101e7a:	0f 84 a1 00 00 00    	je     80101f21 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e80:	8b 45 08             	mov    0x8(%ebp),%eax
80101e83:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	8b 00                	mov    (%eax),%eax
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	52                   	push   %edx
80101e8f:	50                   	push   %eax
80101e90:	e8 21 e3 ff ff       	call   801001b6 <bread>
80101e95:	83 c4 10             	add    $0x10,%esp
80101e98:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e9e:	83 c0 18             	add    $0x18,%eax
80101ea1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ea4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eab:	eb 3c                	jmp    80101ee9 <itrunc+0xd1>
      if(a[j])
80101ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eba:	01 d0                	add    %edx,%eax
80101ebc:	8b 00                	mov    (%eax),%eax
80101ebe:	85 c0                	test   %eax,%eax
80101ec0:	74 23                	je     80101ee5 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ecc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ecf:	01 d0                	add    %edx,%eax
80101ed1:	8b 00                	mov    (%eax),%eax
80101ed3:	8b 55 08             	mov    0x8(%ebp),%edx
80101ed6:	8b 12                	mov    (%edx),%edx
80101ed8:	83 ec 08             	sub    $0x8,%esp
80101edb:	50                   	push   %eax
80101edc:	52                   	push   %edx
80101edd:	e8 2e f7 ff ff       	call   80101610 <bfree>
80101ee2:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ee5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eec:	83 f8 7f             	cmp    $0x7f,%eax
80101eef:	76 bc                	jbe    80101ead <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ef1:	83 ec 0c             	sub    $0xc,%esp
80101ef4:	ff 75 ec             	pushl  -0x14(%ebp)
80101ef7:	e8 32 e3 ff ff       	call   8010022e <brelse>
80101efc:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101eff:	8b 45 08             	mov    0x8(%ebp),%eax
80101f02:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f05:	8b 55 08             	mov    0x8(%ebp),%edx
80101f08:	8b 12                	mov    (%edx),%edx
80101f0a:	83 ec 08             	sub    $0x8,%esp
80101f0d:	50                   	push   %eax
80101f0e:	52                   	push   %edx
80101f0f:	e8 fc f6 ff ff       	call   80101610 <bfree>
80101f14:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f17:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f2b:	83 ec 0c             	sub    $0xc,%esp
80101f2e:	ff 75 08             	pushl  0x8(%ebp)
80101f31:	e8 04 f9 ff ff       	call   8010183a <iupdate>
80101f36:	83 c4 10             	add    $0x10,%esp
}
80101f39:	90                   	nop
80101f3a:	c9                   	leave  
80101f3b:	c3                   	ret    

80101f3c <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f3c:	55                   	push   %ebp
80101f3d:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 00                	mov    (%eax),%eax
80101f44:	89 c2                	mov    %eax,%edx
80101f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f49:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4f:	8b 50 04             	mov    0x4(%eax),%edx
80101f52:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f55:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f58:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5b:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f62:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f6f:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f73:	8b 45 08             	mov    0x8(%ebp),%eax
80101f76:	8b 50 18             	mov    0x18(%eax),%edx
80101f79:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7c:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f7f:	90                   	nop
80101f80:	5d                   	pop    %ebp
80101f81:	c3                   	ret    

80101f82 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f82:	55                   	push   %ebp
80101f83:	89 e5                	mov    %esp,%ebp
80101f85:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f88:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f8f:	66 83 f8 03          	cmp    $0x3,%ax
80101f93:	75 5c                	jne    80101ff1 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9c:	66 85 c0             	test   %ax,%ax
80101f9f:	78 20                	js     80101fc1 <readi+0x3f>
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fa8:	66 83 f8 09          	cmp    $0x9,%ax
80101fac:	7f 13                	jg     80101fc1 <readi+0x3f>
80101fae:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fb5:	98                   	cwtl   
80101fb6:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fbd:	85 c0                	test   %eax,%eax
80101fbf:	75 0a                	jne    80101fcb <readi+0x49>
      return -1;
80101fc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fc6:	e9 0c 01 00 00       	jmp    801020d7 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd2:	98                   	cwtl   
80101fd3:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fda:	8b 55 14             	mov    0x14(%ebp),%edx
80101fdd:	83 ec 04             	sub    $0x4,%esp
80101fe0:	52                   	push   %edx
80101fe1:	ff 75 0c             	pushl  0xc(%ebp)
80101fe4:	ff 75 08             	pushl  0x8(%ebp)
80101fe7:	ff d0                	call   *%eax
80101fe9:	83 c4 10             	add    $0x10,%esp
80101fec:	e9 e6 00 00 00       	jmp    801020d7 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	8b 40 18             	mov    0x18(%eax),%eax
80101ff7:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ffa:	72 0d                	jb     80102009 <readi+0x87>
80101ffc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fff:	8b 45 14             	mov    0x14(%ebp),%eax
80102002:	01 d0                	add    %edx,%eax
80102004:	3b 45 10             	cmp    0x10(%ebp),%eax
80102007:	73 0a                	jae    80102013 <readi+0x91>
    return -1;
80102009:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010200e:	e9 c4 00 00 00       	jmp    801020d7 <readi+0x155>
  if(off + n > ip->size)
80102013:	8b 55 10             	mov    0x10(%ebp),%edx
80102016:	8b 45 14             	mov    0x14(%ebp),%eax
80102019:	01 c2                	add    %eax,%edx
8010201b:	8b 45 08             	mov    0x8(%ebp),%eax
8010201e:	8b 40 18             	mov    0x18(%eax),%eax
80102021:	39 c2                	cmp    %eax,%edx
80102023:	76 0c                	jbe    80102031 <readi+0xaf>
    n = ip->size - off;
80102025:	8b 45 08             	mov    0x8(%ebp),%eax
80102028:	8b 40 18             	mov    0x18(%eax),%eax
8010202b:	2b 45 10             	sub    0x10(%ebp),%eax
8010202e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102031:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102038:	e9 8b 00 00 00       	jmp    801020c8 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010203d:	8b 45 10             	mov    0x10(%ebp),%eax
80102040:	c1 e8 09             	shr    $0x9,%eax
80102043:	83 ec 08             	sub    $0x8,%esp
80102046:	50                   	push   %eax
80102047:	ff 75 08             	pushl  0x8(%ebp)
8010204a:	e8 aa fc ff ff       	call   80101cf9 <bmap>
8010204f:	83 c4 10             	add    $0x10,%esp
80102052:	89 c2                	mov    %eax,%edx
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	8b 00                	mov    (%eax),%eax
80102059:	83 ec 08             	sub    $0x8,%esp
8010205c:	52                   	push   %edx
8010205d:	50                   	push   %eax
8010205e:	e8 53 e1 ff ff       	call   801001b6 <bread>
80102063:	83 c4 10             	add    $0x10,%esp
80102066:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102069:	8b 45 10             	mov    0x10(%ebp),%eax
8010206c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102071:	ba 00 02 00 00       	mov    $0x200,%edx
80102076:	29 c2                	sub    %eax,%edx
80102078:	8b 45 14             	mov    0x14(%ebp),%eax
8010207b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010207e:	39 c2                	cmp    %eax,%edx
80102080:	0f 46 c2             	cmovbe %edx,%eax
80102083:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102089:	8d 50 18             	lea    0x18(%eax),%edx
8010208c:	8b 45 10             	mov    0x10(%ebp),%eax
8010208f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102094:	01 d0                	add    %edx,%eax
80102096:	83 ec 04             	sub    $0x4,%esp
80102099:	ff 75 ec             	pushl  -0x14(%ebp)
8010209c:	50                   	push   %eax
8010209d:	ff 75 0c             	pushl  0xc(%ebp)
801020a0:	e8 af 40 00 00       	call   80106154 <memmove>
801020a5:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020a8:	83 ec 0c             	sub    $0xc,%esp
801020ab:	ff 75 f0             	pushl  -0x10(%ebp)
801020ae:	e8 7b e1 ff ff       	call   8010022e <brelse>
801020b3:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b9:	01 45 f4             	add    %eax,-0xc(%ebp)
801020bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bf:	01 45 10             	add    %eax,0x10(%ebp)
801020c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c5:	01 45 0c             	add    %eax,0xc(%ebp)
801020c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cb:	3b 45 14             	cmp    0x14(%ebp),%eax
801020ce:	0f 82 69 ff ff ff    	jb     8010203d <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020d4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020d7:	c9                   	leave  
801020d8:	c3                   	ret    

801020d9 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020d9:	55                   	push   %ebp
801020da:	89 e5                	mov    %esp,%ebp
801020dc:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020df:	8b 45 08             	mov    0x8(%ebp),%eax
801020e2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020e6:	66 83 f8 03          	cmp    $0x3,%ax
801020ea:	75 5c                	jne    80102148 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020ec:	8b 45 08             	mov    0x8(%ebp),%eax
801020ef:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f3:	66 85 c0             	test   %ax,%ax
801020f6:	78 20                	js     80102118 <writei+0x3f>
801020f8:	8b 45 08             	mov    0x8(%ebp),%eax
801020fb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ff:	66 83 f8 09          	cmp    $0x9,%ax
80102103:	7f 13                	jg     80102118 <writei+0x3f>
80102105:	8b 45 08             	mov    0x8(%ebp),%eax
80102108:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010210c:	98                   	cwtl   
8010210d:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102114:	85 c0                	test   %eax,%eax
80102116:	75 0a                	jne    80102122 <writei+0x49>
      return -1;
80102118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010211d:	e9 3d 01 00 00       	jmp    8010225f <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102122:	8b 45 08             	mov    0x8(%ebp),%eax
80102125:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102129:	98                   	cwtl   
8010212a:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102131:	8b 55 14             	mov    0x14(%ebp),%edx
80102134:	83 ec 04             	sub    $0x4,%esp
80102137:	52                   	push   %edx
80102138:	ff 75 0c             	pushl  0xc(%ebp)
8010213b:	ff 75 08             	pushl  0x8(%ebp)
8010213e:	ff d0                	call   *%eax
80102140:	83 c4 10             	add    $0x10,%esp
80102143:	e9 17 01 00 00       	jmp    8010225f <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102148:	8b 45 08             	mov    0x8(%ebp),%eax
8010214b:	8b 40 18             	mov    0x18(%eax),%eax
8010214e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102151:	72 0d                	jb     80102160 <writei+0x87>
80102153:	8b 55 10             	mov    0x10(%ebp),%edx
80102156:	8b 45 14             	mov    0x14(%ebp),%eax
80102159:	01 d0                	add    %edx,%eax
8010215b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010215e:	73 0a                	jae    8010216a <writei+0x91>
    return -1;
80102160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102165:	e9 f5 00 00 00       	jmp    8010225f <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010216a:	8b 55 10             	mov    0x10(%ebp),%edx
8010216d:	8b 45 14             	mov    0x14(%ebp),%eax
80102170:	01 d0                	add    %edx,%eax
80102172:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102177:	76 0a                	jbe    80102183 <writei+0xaa>
    return -1;
80102179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217e:	e9 dc 00 00 00       	jmp    8010225f <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218a:	e9 99 00 00 00       	jmp    80102228 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010218f:	8b 45 10             	mov    0x10(%ebp),%eax
80102192:	c1 e8 09             	shr    $0x9,%eax
80102195:	83 ec 08             	sub    $0x8,%esp
80102198:	50                   	push   %eax
80102199:	ff 75 08             	pushl  0x8(%ebp)
8010219c:	e8 58 fb ff ff       	call   80101cf9 <bmap>
801021a1:	83 c4 10             	add    $0x10,%esp
801021a4:	89 c2                	mov    %eax,%edx
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	8b 00                	mov    (%eax),%eax
801021ab:	83 ec 08             	sub    $0x8,%esp
801021ae:	52                   	push   %edx
801021af:	50                   	push   %eax
801021b0:	e8 01 e0 ff ff       	call   801001b6 <bread>
801021b5:	83 c4 10             	add    $0x10,%esp
801021b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021bb:	8b 45 10             	mov    0x10(%ebp),%eax
801021be:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c3:	ba 00 02 00 00       	mov    $0x200,%edx
801021c8:	29 c2                	sub    %eax,%edx
801021ca:	8b 45 14             	mov    0x14(%ebp),%eax
801021cd:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d0:	39 c2                	cmp    %eax,%edx
801021d2:	0f 46 c2             	cmovbe %edx,%eax
801021d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021db:	8d 50 18             	lea    0x18(%eax),%edx
801021de:	8b 45 10             	mov    0x10(%ebp),%eax
801021e1:	25 ff 01 00 00       	and    $0x1ff,%eax
801021e6:	01 d0                	add    %edx,%eax
801021e8:	83 ec 04             	sub    $0x4,%esp
801021eb:	ff 75 ec             	pushl  -0x14(%ebp)
801021ee:	ff 75 0c             	pushl  0xc(%ebp)
801021f1:	50                   	push   %eax
801021f2:	e8 5d 3f 00 00       	call   80106154 <memmove>
801021f7:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021fa:	83 ec 0c             	sub    $0xc,%esp
801021fd:	ff 75 f0             	pushl  -0x10(%ebp)
80102200:	e8 2a 16 00 00       	call   8010382f <log_write>
80102205:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102208:	83 ec 0c             	sub    $0xc,%esp
8010220b:	ff 75 f0             	pushl  -0x10(%ebp)
8010220e:	e8 1b e0 ff ff       	call   8010022e <brelse>
80102213:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102216:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102219:	01 45 f4             	add    %eax,-0xc(%ebp)
8010221c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221f:	01 45 10             	add    %eax,0x10(%ebp)
80102222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102225:	01 45 0c             	add    %eax,0xc(%ebp)
80102228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010222b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010222e:	0f 82 5b ff ff ff    	jb     8010218f <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102234:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102238:	74 22                	je     8010225c <writei+0x183>
8010223a:	8b 45 08             	mov    0x8(%ebp),%eax
8010223d:	8b 40 18             	mov    0x18(%eax),%eax
80102240:	3b 45 10             	cmp    0x10(%ebp),%eax
80102243:	73 17                	jae    8010225c <writei+0x183>
    ip->size = off;
80102245:	8b 45 08             	mov    0x8(%ebp),%eax
80102248:	8b 55 10             	mov    0x10(%ebp),%edx
8010224b:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010224e:	83 ec 0c             	sub    $0xc,%esp
80102251:	ff 75 08             	pushl  0x8(%ebp)
80102254:	e8 e1 f5 ff ff       	call   8010183a <iupdate>
80102259:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010225c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010225f:	c9                   	leave  
80102260:	c3                   	ret    

80102261 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102261:	55                   	push   %ebp
80102262:	89 e5                	mov    %esp,%ebp
80102264:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102267:	83 ec 04             	sub    $0x4,%esp
8010226a:	6a 0e                	push   $0xe
8010226c:	ff 75 0c             	pushl  0xc(%ebp)
8010226f:	ff 75 08             	pushl  0x8(%ebp)
80102272:	e8 73 3f 00 00       	call   801061ea <strncmp>
80102277:	83 c4 10             	add    $0x10,%esp
}
8010227a:	c9                   	leave  
8010227b:	c3                   	ret    

8010227c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010227c:	55                   	push   %ebp
8010227d:	89 e5                	mov    %esp,%ebp
8010227f:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102282:	8b 45 08             	mov    0x8(%ebp),%eax
80102285:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102289:	66 83 f8 01          	cmp    $0x1,%ax
8010228d:	74 0d                	je     8010229c <dirlookup+0x20>
    panic("dirlookup not DIR");
8010228f:	83 ec 0c             	sub    $0xc,%esp
80102292:	68 53 96 10 80       	push   $0x80109653
80102297:	e8 ca e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010229c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a3:	eb 7b                	jmp    80102320 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a5:	6a 10                	push   $0x10
801022a7:	ff 75 f4             	pushl  -0xc(%ebp)
801022aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ad:	50                   	push   %eax
801022ae:	ff 75 08             	pushl  0x8(%ebp)
801022b1:	e8 cc fc ff ff       	call   80101f82 <readi>
801022b6:	83 c4 10             	add    $0x10,%esp
801022b9:	83 f8 10             	cmp    $0x10,%eax
801022bc:	74 0d                	je     801022cb <dirlookup+0x4f>
      panic("dirlink read");
801022be:	83 ec 0c             	sub    $0xc,%esp
801022c1:	68 65 96 10 80       	push   $0x80109665
801022c6:	e8 9b e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022cb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022cf:	66 85 c0             	test   %ax,%ax
801022d2:	74 47                	je     8010231b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022d4:	83 ec 08             	sub    $0x8,%esp
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	83 c0 02             	add    $0x2,%eax
801022dd:	50                   	push   %eax
801022de:	ff 75 0c             	pushl  0xc(%ebp)
801022e1:	e8 7b ff ff ff       	call   80102261 <namecmp>
801022e6:	83 c4 10             	add    $0x10,%esp
801022e9:	85 c0                	test   %eax,%eax
801022eb:	75 2f                	jne    8010231c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022f1:	74 08                	je     801022fb <dirlookup+0x7f>
        *poff = off;
801022f3:	8b 45 10             	mov    0x10(%ebp),%eax
801022f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f9:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022fb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ff:	0f b7 c0             	movzwl %ax,%eax
80102302:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	8b 00                	mov    (%eax),%eax
8010230a:	83 ec 08             	sub    $0x8,%esp
8010230d:	ff 75 f0             	pushl  -0x10(%ebp)
80102310:	50                   	push   %eax
80102311:	e8 e5 f5 ff ff       	call   801018fb <iget>
80102316:	83 c4 10             	add    $0x10,%esp
80102319:	eb 19                	jmp    80102334 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010231b:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010231c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102320:	8b 45 08             	mov    0x8(%ebp),%eax
80102323:	8b 40 18             	mov    0x18(%eax),%eax
80102326:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102329:	0f 87 76 ff ff ff    	ja     801022a5 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010232f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102334:	c9                   	leave  
80102335:	c3                   	ret    

80102336 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102336:	55                   	push   %ebp
80102337:	89 e5                	mov    %esp,%ebp
80102339:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010233c:	83 ec 04             	sub    $0x4,%esp
8010233f:	6a 00                	push   $0x0
80102341:	ff 75 0c             	pushl  0xc(%ebp)
80102344:	ff 75 08             	pushl  0x8(%ebp)
80102347:	e8 30 ff ff ff       	call   8010227c <dirlookup>
8010234c:	83 c4 10             	add    $0x10,%esp
8010234f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102352:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102356:	74 18                	je     80102370 <dirlink+0x3a>
    iput(ip);
80102358:	83 ec 0c             	sub    $0xc,%esp
8010235b:	ff 75 f0             	pushl  -0x10(%ebp)
8010235e:	e8 81 f8 ff ff       	call   80101be4 <iput>
80102363:	83 c4 10             	add    $0x10,%esp
    return -1;
80102366:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010236b:	e9 9c 00 00 00       	jmp    8010240c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102370:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102377:	eb 39                	jmp    801023b2 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	6a 10                	push   $0x10
8010237e:	50                   	push   %eax
8010237f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102382:	50                   	push   %eax
80102383:	ff 75 08             	pushl  0x8(%ebp)
80102386:	e8 f7 fb ff ff       	call   80101f82 <readi>
8010238b:	83 c4 10             	add    $0x10,%esp
8010238e:	83 f8 10             	cmp    $0x10,%eax
80102391:	74 0d                	je     801023a0 <dirlink+0x6a>
      panic("dirlink read");
80102393:	83 ec 0c             	sub    $0xc,%esp
80102396:	68 65 96 10 80       	push   $0x80109665
8010239b:	e8 c6 e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801023a0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023a4:	66 85 c0             	test   %ax,%ax
801023a7:	74 18                	je     801023c1 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ac:	83 c0 10             	add    $0x10,%eax
801023af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023b2:	8b 45 08             	mov    0x8(%ebp),%eax
801023b5:	8b 50 18             	mov    0x18(%eax),%edx
801023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bb:	39 c2                	cmp    %eax,%edx
801023bd:	77 ba                	ja     80102379 <dirlink+0x43>
801023bf:	eb 01                	jmp    801023c2 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023c1:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023c2:	83 ec 04             	sub    $0x4,%esp
801023c5:	6a 0e                	push   $0xe
801023c7:	ff 75 0c             	pushl  0xc(%ebp)
801023ca:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cd:	83 c0 02             	add    $0x2,%eax
801023d0:	50                   	push   %eax
801023d1:	e8 6a 3e 00 00       	call   80106240 <strncpy>
801023d6:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023d9:	8b 45 10             	mov    0x10(%ebp),%eax
801023dc:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e3:	6a 10                	push   $0x10
801023e5:	50                   	push   %eax
801023e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e9:	50                   	push   %eax
801023ea:	ff 75 08             	pushl  0x8(%ebp)
801023ed:	e8 e7 fc ff ff       	call   801020d9 <writei>
801023f2:	83 c4 10             	add    $0x10,%esp
801023f5:	83 f8 10             	cmp    $0x10,%eax
801023f8:	74 0d                	je     80102407 <dirlink+0xd1>
    panic("dirlink");
801023fa:	83 ec 0c             	sub    $0xc,%esp
801023fd:	68 72 96 10 80       	push   $0x80109672
80102402:	e8 5f e1 ff ff       	call   80100566 <panic>
  
  return 0;
80102407:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010240c:	c9                   	leave  
8010240d:	c3                   	ret    

8010240e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010240e:	55                   	push   %ebp
8010240f:	89 e5                	mov    %esp,%ebp
80102411:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102414:	eb 04                	jmp    8010241a <skipelem+0xc>
    path++;
80102416:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010241a:	8b 45 08             	mov    0x8(%ebp),%eax
8010241d:	0f b6 00             	movzbl (%eax),%eax
80102420:	3c 2f                	cmp    $0x2f,%al
80102422:	74 f2                	je     80102416 <skipelem+0x8>
    path++;
  if(*path == 0)
80102424:	8b 45 08             	mov    0x8(%ebp),%eax
80102427:	0f b6 00             	movzbl (%eax),%eax
8010242a:	84 c0                	test   %al,%al
8010242c:	75 07                	jne    80102435 <skipelem+0x27>
    return 0;
8010242e:	b8 00 00 00 00       	mov    $0x0,%eax
80102433:	eb 7b                	jmp    801024b0 <skipelem+0xa2>
  s = path;
80102435:	8b 45 08             	mov    0x8(%ebp),%eax
80102438:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010243b:	eb 04                	jmp    80102441 <skipelem+0x33>
    path++;
8010243d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102441:	8b 45 08             	mov    0x8(%ebp),%eax
80102444:	0f b6 00             	movzbl (%eax),%eax
80102447:	3c 2f                	cmp    $0x2f,%al
80102449:	74 0a                	je     80102455 <skipelem+0x47>
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	0f b6 00             	movzbl (%eax),%eax
80102451:	84 c0                	test   %al,%al
80102453:	75 e8                	jne    8010243d <skipelem+0x2f>
    path++;
  len = path - s;
80102455:	8b 55 08             	mov    0x8(%ebp),%edx
80102458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245b:	29 c2                	sub    %eax,%edx
8010245d:	89 d0                	mov    %edx,%eax
8010245f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102462:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102466:	7e 15                	jle    8010247d <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102468:	83 ec 04             	sub    $0x4,%esp
8010246b:	6a 0e                	push   $0xe
8010246d:	ff 75 f4             	pushl  -0xc(%ebp)
80102470:	ff 75 0c             	pushl  0xc(%ebp)
80102473:	e8 dc 3c 00 00       	call   80106154 <memmove>
80102478:	83 c4 10             	add    $0x10,%esp
8010247b:	eb 26                	jmp    801024a3 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010247d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102480:	83 ec 04             	sub    $0x4,%esp
80102483:	50                   	push   %eax
80102484:	ff 75 f4             	pushl  -0xc(%ebp)
80102487:	ff 75 0c             	pushl  0xc(%ebp)
8010248a:	e8 c5 3c 00 00       	call   80106154 <memmove>
8010248f:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102492:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	01 d0                	add    %edx,%eax
8010249a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010249d:	eb 04                	jmp    801024a3 <skipelem+0x95>
    path++;
8010249f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	0f b6 00             	movzbl (%eax),%eax
801024a9:	3c 2f                	cmp    $0x2f,%al
801024ab:	74 f2                	je     8010249f <skipelem+0x91>
    path++;
  return path;
801024ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024b0:	c9                   	leave  
801024b1:	c3                   	ret    

801024b2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024b2:	55                   	push   %ebp
801024b3:	89 e5                	mov    %esp,%ebp
801024b5:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024b8:	8b 45 08             	mov    0x8(%ebp),%eax
801024bb:	0f b6 00             	movzbl (%eax),%eax
801024be:	3c 2f                	cmp    $0x2f,%al
801024c0:	75 17                	jne    801024d9 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024c2:	83 ec 08             	sub    $0x8,%esp
801024c5:	6a 01                	push   $0x1
801024c7:	6a 01                	push   $0x1
801024c9:	e8 2d f4 ff ff       	call   801018fb <iget>
801024ce:	83 c4 10             	add    $0x10,%esp
801024d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024d4:	e9 bb 00 00 00       	jmp    80102594 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801024d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024df:	8b 40 68             	mov    0x68(%eax),%eax
801024e2:	83 ec 0c             	sub    $0xc,%esp
801024e5:	50                   	push   %eax
801024e6:	e8 ef f4 ff ff       	call   801019da <idup>
801024eb:	83 c4 10             	add    $0x10,%esp
801024ee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024f1:	e9 9e 00 00 00       	jmp    80102594 <namex+0xe2>
    ilock(ip);
801024f6:	83 ec 0c             	sub    $0xc,%esp
801024f9:	ff 75 f4             	pushl  -0xc(%ebp)
801024fc:	e8 13 f5 ff ff       	call   80101a14 <ilock>
80102501:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102507:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010250b:	66 83 f8 01          	cmp    $0x1,%ax
8010250f:	74 18                	je     80102529 <namex+0x77>
      iunlockput(ip);
80102511:	83 ec 0c             	sub    $0xc,%esp
80102514:	ff 75 f4             	pushl  -0xc(%ebp)
80102517:	e8 b8 f7 ff ff       	call   80101cd4 <iunlockput>
8010251c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010251f:	b8 00 00 00 00       	mov    $0x0,%eax
80102524:	e9 a7 00 00 00       	jmp    801025d0 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102529:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010252d:	74 20                	je     8010254f <namex+0x9d>
8010252f:	8b 45 08             	mov    0x8(%ebp),%eax
80102532:	0f b6 00             	movzbl (%eax),%eax
80102535:	84 c0                	test   %al,%al
80102537:	75 16                	jne    8010254f <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102539:	83 ec 0c             	sub    $0xc,%esp
8010253c:	ff 75 f4             	pushl  -0xc(%ebp)
8010253f:	e8 2e f6 ff ff       	call   80101b72 <iunlock>
80102544:	83 c4 10             	add    $0x10,%esp
      return ip;
80102547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010254a:	e9 81 00 00 00       	jmp    801025d0 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010254f:	83 ec 04             	sub    $0x4,%esp
80102552:	6a 00                	push   $0x0
80102554:	ff 75 10             	pushl  0x10(%ebp)
80102557:	ff 75 f4             	pushl  -0xc(%ebp)
8010255a:	e8 1d fd ff ff       	call   8010227c <dirlookup>
8010255f:	83 c4 10             	add    $0x10,%esp
80102562:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102565:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102569:	75 15                	jne    80102580 <namex+0xce>
      iunlockput(ip);
8010256b:	83 ec 0c             	sub    $0xc,%esp
8010256e:	ff 75 f4             	pushl  -0xc(%ebp)
80102571:	e8 5e f7 ff ff       	call   80101cd4 <iunlockput>
80102576:	83 c4 10             	add    $0x10,%esp
      return 0;
80102579:	b8 00 00 00 00       	mov    $0x0,%eax
8010257e:	eb 50                	jmp    801025d0 <namex+0x11e>
    }
    iunlockput(ip);
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	ff 75 f4             	pushl  -0xc(%ebp)
80102586:	e8 49 f7 ff ff       	call   80101cd4 <iunlockput>
8010258b:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010258e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102591:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102594:	83 ec 08             	sub    $0x8,%esp
80102597:	ff 75 10             	pushl  0x10(%ebp)
8010259a:	ff 75 08             	pushl  0x8(%ebp)
8010259d:	e8 6c fe ff ff       	call   8010240e <skipelem>
801025a2:	83 c4 10             	add    $0x10,%esp
801025a5:	89 45 08             	mov    %eax,0x8(%ebp)
801025a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ac:	0f 85 44 ff ff ff    	jne    801024f6 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025b6:	74 15                	je     801025cd <namex+0x11b>
    iput(ip);
801025b8:	83 ec 0c             	sub    $0xc,%esp
801025bb:	ff 75 f4             	pushl  -0xc(%ebp)
801025be:	e8 21 f6 ff ff       	call   80101be4 <iput>
801025c3:	83 c4 10             	add    $0x10,%esp
    return 0;
801025c6:	b8 00 00 00 00       	mov    $0x0,%eax
801025cb:	eb 03                	jmp    801025d0 <namex+0x11e>
  }
  return ip;
801025cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025d0:	c9                   	leave  
801025d1:	c3                   	ret    

801025d2 <namei>:

struct inode*
namei(char *path)
{
801025d2:	55                   	push   %ebp
801025d3:	89 e5                	mov    %esp,%ebp
801025d5:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025d8:	83 ec 04             	sub    $0x4,%esp
801025db:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025de:	50                   	push   %eax
801025df:	6a 00                	push   $0x0
801025e1:	ff 75 08             	pushl  0x8(%ebp)
801025e4:	e8 c9 fe ff ff       	call   801024b2 <namex>
801025e9:	83 c4 10             	add    $0x10,%esp
}
801025ec:	c9                   	leave  
801025ed:	c3                   	ret    

801025ee <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025ee:	55                   	push   %ebp
801025ef:	89 e5                	mov    %esp,%ebp
801025f1:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025f4:	83 ec 04             	sub    $0x4,%esp
801025f7:	ff 75 0c             	pushl  0xc(%ebp)
801025fa:	6a 01                	push   $0x1
801025fc:	ff 75 08             	pushl  0x8(%ebp)
801025ff:	e8 ae fe ff ff       	call   801024b2 <namex>
80102604:	83 c4 10             	add    $0x10,%esp
}
80102607:	c9                   	leave  
80102608:	c3                   	ret    

80102609 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102609:	55                   	push   %ebp
8010260a:	89 e5                	mov    %esp,%ebp
8010260c:	83 ec 14             	sub    $0x14,%esp
8010260f:	8b 45 08             	mov    0x8(%ebp),%eax
80102612:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102616:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010261a:	89 c2                	mov    %eax,%edx
8010261c:	ec                   	in     (%dx),%al
8010261d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102620:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102624:	c9                   	leave  
80102625:	c3                   	ret    

80102626 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102626:	55                   	push   %ebp
80102627:	89 e5                	mov    %esp,%ebp
80102629:	57                   	push   %edi
8010262a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010262b:	8b 55 08             	mov    0x8(%ebp),%edx
8010262e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102631:	8b 45 10             	mov    0x10(%ebp),%eax
80102634:	89 cb                	mov    %ecx,%ebx
80102636:	89 df                	mov    %ebx,%edi
80102638:	89 c1                	mov    %eax,%ecx
8010263a:	fc                   	cld    
8010263b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010263d:	89 c8                	mov    %ecx,%eax
8010263f:	89 fb                	mov    %edi,%ebx
80102641:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102644:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102647:	90                   	nop
80102648:	5b                   	pop    %ebx
80102649:	5f                   	pop    %edi
8010264a:	5d                   	pop    %ebp
8010264b:	c3                   	ret    

8010264c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010264c:	55                   	push   %ebp
8010264d:	89 e5                	mov    %esp,%ebp
8010264f:	83 ec 08             	sub    $0x8,%esp
80102652:	8b 55 08             	mov    0x8(%ebp),%edx
80102655:	8b 45 0c             	mov    0xc(%ebp),%eax
80102658:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010265c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010265f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102663:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102667:	ee                   	out    %al,(%dx)
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	56                   	push   %esi
8010266f:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102670:	8b 55 08             	mov    0x8(%ebp),%edx
80102673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102676:	8b 45 10             	mov    0x10(%ebp),%eax
80102679:	89 cb                	mov    %ecx,%ebx
8010267b:	89 de                	mov    %ebx,%esi
8010267d:	89 c1                	mov    %eax,%ecx
8010267f:	fc                   	cld    
80102680:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102682:	89 c8                	mov    %ecx,%eax
80102684:	89 f3                	mov    %esi,%ebx
80102686:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102689:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010268c:	90                   	nop
8010268d:	5b                   	pop    %ebx
8010268e:	5e                   	pop    %esi
8010268f:	5d                   	pop    %ebp
80102690:	c3                   	ret    

80102691 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102691:	55                   	push   %ebp
80102692:	89 e5                	mov    %esp,%ebp
80102694:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102697:	90                   	nop
80102698:	68 f7 01 00 00       	push   $0x1f7
8010269d:	e8 67 ff ff ff       	call   80102609 <inb>
801026a2:	83 c4 04             	add    $0x4,%esp
801026a5:	0f b6 c0             	movzbl %al,%eax
801026a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026ae:	25 c0 00 00 00       	and    $0xc0,%eax
801026b3:	83 f8 40             	cmp    $0x40,%eax
801026b6:	75 e0                	jne    80102698 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026bc:	74 11                	je     801026cf <idewait+0x3e>
801026be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026c1:	83 e0 21             	and    $0x21,%eax
801026c4:	85 c0                	test   %eax,%eax
801026c6:	74 07                	je     801026cf <idewait+0x3e>
    return -1;
801026c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026cd:	eb 05                	jmp    801026d4 <idewait+0x43>
  return 0;
801026cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026d4:	c9                   	leave  
801026d5:	c3                   	ret    

801026d6 <ideinit>:

void
ideinit(void)
{
801026d6:	55                   	push   %ebp
801026d7:	89 e5                	mov    %esp,%ebp
801026d9:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801026dc:	83 ec 08             	sub    $0x8,%esp
801026df:	68 7a 96 10 80       	push   $0x8010967a
801026e4:	68 20 c6 10 80       	push   $0x8010c620
801026e9:	e8 22 37 00 00       	call   80105e10 <initlock>
801026ee:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026f1:	83 ec 0c             	sub    $0xc,%esp
801026f4:	6a 0e                	push   $0xe
801026f6:	e8 da 18 00 00       	call   80103fd5 <picenable>
801026fb:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026fe:	a1 60 39 11 80       	mov    0x80113960,%eax
80102703:	83 e8 01             	sub    $0x1,%eax
80102706:	83 ec 08             	sub    $0x8,%esp
80102709:	50                   	push   %eax
8010270a:	6a 0e                	push   $0xe
8010270c:	e8 73 04 00 00       	call   80102b84 <ioapicenable>
80102711:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102714:	83 ec 0c             	sub    $0xc,%esp
80102717:	6a 00                	push   $0x0
80102719:	e8 73 ff ff ff       	call   80102691 <idewait>
8010271e:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102721:	83 ec 08             	sub    $0x8,%esp
80102724:	68 f0 00 00 00       	push   $0xf0
80102729:	68 f6 01 00 00       	push   $0x1f6
8010272e:	e8 19 ff ff ff       	call   8010264c <outb>
80102733:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010273d:	eb 24                	jmp    80102763 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010273f:	83 ec 0c             	sub    $0xc,%esp
80102742:	68 f7 01 00 00       	push   $0x1f7
80102747:	e8 bd fe ff ff       	call   80102609 <inb>
8010274c:	83 c4 10             	add    $0x10,%esp
8010274f:	84 c0                	test   %al,%al
80102751:	74 0c                	je     8010275f <ideinit+0x89>
      havedisk1 = 1;
80102753:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
8010275a:	00 00 00 
      break;
8010275d:	eb 0d                	jmp    8010276c <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010275f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102763:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010276a:	7e d3                	jle    8010273f <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010276c:	83 ec 08             	sub    $0x8,%esp
8010276f:	68 e0 00 00 00       	push   $0xe0
80102774:	68 f6 01 00 00       	push   $0x1f6
80102779:	e8 ce fe ff ff       	call   8010264c <outb>
8010277e:	83 c4 10             	add    $0x10,%esp
}
80102781:	90                   	nop
80102782:	c9                   	leave  
80102783:	c3                   	ret    

80102784 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102784:	55                   	push   %ebp
80102785:	89 e5                	mov    %esp,%ebp
80102787:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010278a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010278e:	75 0d                	jne    8010279d <idestart+0x19>
    panic("idestart");
80102790:	83 ec 0c             	sub    $0xc,%esp
80102793:	68 7e 96 10 80       	push   $0x8010967e
80102798:	e8 c9 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
8010279d:	8b 45 08             	mov    0x8(%ebp),%eax
801027a0:	8b 40 08             	mov    0x8(%eax),%eax
801027a3:	3d cf 07 00 00       	cmp    $0x7cf,%eax
801027a8:	76 0d                	jbe    801027b7 <idestart+0x33>
    panic("incorrect blockno");
801027aa:	83 ec 0c             	sub    $0xc,%esp
801027ad:	68 87 96 10 80       	push   $0x80109687
801027b2:	e8 af dd ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027b7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027be:	8b 45 08             	mov    0x8(%ebp),%eax
801027c1:	8b 50 08             	mov    0x8(%eax),%edx
801027c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c7:	0f af c2             	imul   %edx,%eax
801027ca:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027cd:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027d1:	7e 0d                	jle    801027e0 <idestart+0x5c>
801027d3:	83 ec 0c             	sub    $0xc,%esp
801027d6:	68 7e 96 10 80       	push   $0x8010967e
801027db:	e8 86 dd ff ff       	call   80100566 <panic>
  
  idewait(0);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	6a 00                	push   $0x0
801027e5:	e8 a7 fe ff ff       	call   80102691 <idewait>
801027ea:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027ed:	83 ec 08             	sub    $0x8,%esp
801027f0:	6a 00                	push   $0x0
801027f2:	68 f6 03 00 00       	push   $0x3f6
801027f7:	e8 50 fe ff ff       	call   8010264c <outb>
801027fc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102802:	0f b6 c0             	movzbl %al,%eax
80102805:	83 ec 08             	sub    $0x8,%esp
80102808:	50                   	push   %eax
80102809:	68 f2 01 00 00       	push   $0x1f2
8010280e:	e8 39 fe ff ff       	call   8010264c <outb>
80102813:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102816:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102819:	0f b6 c0             	movzbl %al,%eax
8010281c:	83 ec 08             	sub    $0x8,%esp
8010281f:	50                   	push   %eax
80102820:	68 f3 01 00 00       	push   $0x1f3
80102825:	e8 22 fe ff ff       	call   8010264c <outb>
8010282a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010282d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102830:	c1 f8 08             	sar    $0x8,%eax
80102833:	0f b6 c0             	movzbl %al,%eax
80102836:	83 ec 08             	sub    $0x8,%esp
80102839:	50                   	push   %eax
8010283a:	68 f4 01 00 00       	push   $0x1f4
8010283f:	e8 08 fe ff ff       	call   8010264c <outb>
80102844:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010284a:	c1 f8 10             	sar    $0x10,%eax
8010284d:	0f b6 c0             	movzbl %al,%eax
80102850:	83 ec 08             	sub    $0x8,%esp
80102853:	50                   	push   %eax
80102854:	68 f5 01 00 00       	push   $0x1f5
80102859:	e8 ee fd ff ff       	call   8010264c <outb>
8010285e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102861:	8b 45 08             	mov    0x8(%ebp),%eax
80102864:	8b 40 04             	mov    0x4(%eax),%eax
80102867:	83 e0 01             	and    $0x1,%eax
8010286a:	c1 e0 04             	shl    $0x4,%eax
8010286d:	89 c2                	mov    %eax,%edx
8010286f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102872:	c1 f8 18             	sar    $0x18,%eax
80102875:	83 e0 0f             	and    $0xf,%eax
80102878:	09 d0                	or     %edx,%eax
8010287a:	83 c8 e0             	or     $0xffffffe0,%eax
8010287d:	0f b6 c0             	movzbl %al,%eax
80102880:	83 ec 08             	sub    $0x8,%esp
80102883:	50                   	push   %eax
80102884:	68 f6 01 00 00       	push   $0x1f6
80102889:	e8 be fd ff ff       	call   8010264c <outb>
8010288e:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102891:	8b 45 08             	mov    0x8(%ebp),%eax
80102894:	8b 00                	mov    (%eax),%eax
80102896:	83 e0 04             	and    $0x4,%eax
80102899:	85 c0                	test   %eax,%eax
8010289b:	74 30                	je     801028cd <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
8010289d:	83 ec 08             	sub    $0x8,%esp
801028a0:	6a 30                	push   $0x30
801028a2:	68 f7 01 00 00       	push   $0x1f7
801028a7:	e8 a0 fd ff ff       	call   8010264c <outb>
801028ac:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028af:	8b 45 08             	mov    0x8(%ebp),%eax
801028b2:	83 c0 18             	add    $0x18,%eax
801028b5:	83 ec 04             	sub    $0x4,%esp
801028b8:	68 80 00 00 00       	push   $0x80
801028bd:	50                   	push   %eax
801028be:	68 f0 01 00 00       	push   $0x1f0
801028c3:	e8 a3 fd ff ff       	call   8010266b <outsl>
801028c8:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801028cb:	eb 12                	jmp    801028df <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801028cd:	83 ec 08             	sub    $0x8,%esp
801028d0:	6a 20                	push   $0x20
801028d2:	68 f7 01 00 00       	push   $0x1f7
801028d7:	e8 70 fd ff ff       	call   8010264c <outb>
801028dc:	83 c4 10             	add    $0x10,%esp
  }
}
801028df:	90                   	nop
801028e0:	c9                   	leave  
801028e1:	c3                   	ret    

801028e2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028e2:	55                   	push   %ebp
801028e3:	89 e5                	mov    %esp,%ebp
801028e5:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028e8:	83 ec 0c             	sub    $0xc,%esp
801028eb:	68 20 c6 10 80       	push   $0x8010c620
801028f0:	e8 3d 35 00 00       	call   80105e32 <acquire>
801028f5:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028f8:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102900:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102904:	75 15                	jne    8010291b <ideintr+0x39>
    release(&idelock);
80102906:	83 ec 0c             	sub    $0xc,%esp
80102909:	68 20 c6 10 80       	push   $0x8010c620
8010290e:	e8 86 35 00 00       	call   80105e99 <release>
80102913:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102916:	e9 9a 00 00 00       	jmp    801029b5 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010291b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291e:	8b 40 14             	mov    0x14(%eax),%eax
80102921:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102929:	8b 00                	mov    (%eax),%eax
8010292b:	83 e0 04             	and    $0x4,%eax
8010292e:	85 c0                	test   %eax,%eax
80102930:	75 2d                	jne    8010295f <ideintr+0x7d>
80102932:	83 ec 0c             	sub    $0xc,%esp
80102935:	6a 01                	push   $0x1
80102937:	e8 55 fd ff ff       	call   80102691 <idewait>
8010293c:	83 c4 10             	add    $0x10,%esp
8010293f:	85 c0                	test   %eax,%eax
80102941:	78 1c                	js     8010295f <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102946:	83 c0 18             	add    $0x18,%eax
80102949:	83 ec 04             	sub    $0x4,%esp
8010294c:	68 80 00 00 00       	push   $0x80
80102951:	50                   	push   %eax
80102952:	68 f0 01 00 00       	push   $0x1f0
80102957:	e8 ca fc ff ff       	call   80102626 <insl>
8010295c:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010295f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102962:	8b 00                	mov    (%eax),%eax
80102964:	83 c8 02             	or     $0x2,%eax
80102967:	89 c2                	mov    %eax,%edx
80102969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296c:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102971:	8b 00                	mov    (%eax),%eax
80102973:	83 e0 fb             	and    $0xfffffffb,%eax
80102976:	89 c2                	mov    %eax,%edx
80102978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297b:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010297d:	83 ec 0c             	sub    $0xc,%esp
80102980:	ff 75 f4             	pushl  -0xc(%ebp)
80102983:	e8 f6 2b 00 00       	call   8010557e <wakeup>
80102988:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010298b:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102990:	85 c0                	test   %eax,%eax
80102992:	74 11                	je     801029a5 <ideintr+0xc3>
    idestart(idequeue);
80102994:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102999:	83 ec 0c             	sub    $0xc,%esp
8010299c:	50                   	push   %eax
8010299d:	e8 e2 fd ff ff       	call   80102784 <idestart>
801029a2:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	68 20 c6 10 80       	push   $0x8010c620
801029ad:	e8 e7 34 00 00       	call   80105e99 <release>
801029b2:	83 c4 10             	add    $0x10,%esp
}
801029b5:	c9                   	leave  
801029b6:	c3                   	ret    

801029b7 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029b7:	55                   	push   %ebp
801029b8:	89 e5                	mov    %esp,%ebp
801029ba:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801029bd:	8b 45 08             	mov    0x8(%ebp),%eax
801029c0:	8b 00                	mov    (%eax),%eax
801029c2:	83 e0 01             	and    $0x1,%eax
801029c5:	85 c0                	test   %eax,%eax
801029c7:	75 0d                	jne    801029d6 <iderw+0x1f>
    panic("iderw: buf not busy");
801029c9:	83 ec 0c             	sub    $0xc,%esp
801029cc:	68 99 96 10 80       	push   $0x80109699
801029d1:	e8 90 db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029d6:	8b 45 08             	mov    0x8(%ebp),%eax
801029d9:	8b 00                	mov    (%eax),%eax
801029db:	83 e0 06             	and    $0x6,%eax
801029de:	83 f8 02             	cmp    $0x2,%eax
801029e1:	75 0d                	jne    801029f0 <iderw+0x39>
    panic("iderw: nothing to do");
801029e3:	83 ec 0c             	sub    $0xc,%esp
801029e6:	68 ad 96 10 80       	push   $0x801096ad
801029eb:	e8 76 db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029f0:	8b 45 08             	mov    0x8(%ebp),%eax
801029f3:	8b 40 04             	mov    0x4(%eax),%eax
801029f6:	85 c0                	test   %eax,%eax
801029f8:	74 16                	je     80102a10 <iderw+0x59>
801029fa:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801029ff:	85 c0                	test   %eax,%eax
80102a01:	75 0d                	jne    80102a10 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102a03:	83 ec 0c             	sub    $0xc,%esp
80102a06:	68 c2 96 10 80       	push   $0x801096c2
80102a0b:	e8 56 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a10:	83 ec 0c             	sub    $0xc,%esp
80102a13:	68 20 c6 10 80       	push   $0x8010c620
80102a18:	e8 15 34 00 00       	call   80105e32 <acquire>
80102a1d:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a20:	8b 45 08             	mov    0x8(%ebp),%eax
80102a23:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a2a:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102a31:	eb 0b                	jmp    80102a3e <iderw+0x87>
80102a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a36:	8b 00                	mov    (%eax),%eax
80102a38:	83 c0 14             	add    $0x14,%eax
80102a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a41:	8b 00                	mov    (%eax),%eax
80102a43:	85 c0                	test   %eax,%eax
80102a45:	75 ec                	jne    80102a33 <iderw+0x7c>
    ;
  *pp = b;
80102a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4a:	8b 55 08             	mov    0x8(%ebp),%edx
80102a4d:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a4f:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102a54:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a57:	75 23                	jne    80102a7c <iderw+0xc5>
    idestart(b);
80102a59:	83 ec 0c             	sub    $0xc,%esp
80102a5c:	ff 75 08             	pushl  0x8(%ebp)
80102a5f:	e8 20 fd ff ff       	call   80102784 <idestart>
80102a64:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a67:	eb 13                	jmp    80102a7c <iderw+0xc5>
    sleep(b, &idelock);
80102a69:	83 ec 08             	sub    $0x8,%esp
80102a6c:	68 20 c6 10 80       	push   $0x8010c620
80102a71:	ff 75 08             	pushl  0x8(%ebp)
80102a74:	e8 8a 29 00 00       	call   80105403 <sleep>
80102a79:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7f:	8b 00                	mov    (%eax),%eax
80102a81:	83 e0 06             	and    $0x6,%eax
80102a84:	83 f8 02             	cmp    $0x2,%eax
80102a87:	75 e0                	jne    80102a69 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a89:	83 ec 0c             	sub    $0xc,%esp
80102a8c:	68 20 c6 10 80       	push   $0x8010c620
80102a91:	e8 03 34 00 00       	call   80105e99 <release>
80102a96:	83 c4 10             	add    $0x10,%esp
}
80102a99:	90                   	nop
80102a9a:	c9                   	leave  
80102a9b:	c3                   	ret    

80102a9c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a9c:	55                   	push   %ebp
80102a9d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a9f:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aa4:	8b 55 08             	mov    0x8(%ebp),%edx
80102aa7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102aa9:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aae:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ab1:	5d                   	pop    %ebp
80102ab2:	c3                   	ret    

80102ab3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102ab3:	55                   	push   %ebp
80102ab4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ab6:	a1 34 32 11 80       	mov    0x80113234,%eax
80102abb:	8b 55 08             	mov    0x8(%ebp),%edx
80102abe:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ac0:	a1 34 32 11 80       	mov    0x80113234,%eax
80102ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ac8:	89 50 10             	mov    %edx,0x10(%eax)
}
80102acb:	90                   	nop
80102acc:	5d                   	pop    %ebp
80102acd:	c3                   	ret    

80102ace <ioapicinit>:

void
ioapicinit(void)
{
80102ace:	55                   	push   %ebp
80102acf:	89 e5                	mov    %esp,%ebp
80102ad1:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102ad4:	a1 64 33 11 80       	mov    0x80113364,%eax
80102ad9:	85 c0                	test   %eax,%eax
80102adb:	0f 84 a0 00 00 00    	je     80102b81 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ae1:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102ae8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102aeb:	6a 01                	push   $0x1
80102aed:	e8 aa ff ff ff       	call   80102a9c <ioapicread>
80102af2:	83 c4 04             	add    $0x4,%esp
80102af5:	c1 e8 10             	shr    $0x10,%eax
80102af8:	25 ff 00 00 00       	and    $0xff,%eax
80102afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b00:	6a 00                	push   $0x0
80102b02:	e8 95 ff ff ff       	call   80102a9c <ioapicread>
80102b07:	83 c4 04             	add    $0x4,%esp
80102b0a:	c1 e8 18             	shr    $0x18,%eax
80102b0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b10:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102b17:	0f b6 c0             	movzbl %al,%eax
80102b1a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b1d:	74 10                	je     80102b2f <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b1f:	83 ec 0c             	sub    $0xc,%esp
80102b22:	68 e0 96 10 80       	push   $0x801096e0
80102b27:	e8 9a d8 ff ff       	call   801003c6 <cprintf>
80102b2c:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b36:	eb 3f                	jmp    80102b77 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3b:	83 c0 20             	add    $0x20,%eax
80102b3e:	0d 00 00 01 00       	or     $0x10000,%eax
80102b43:	89 c2                	mov    %eax,%edx
80102b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b48:	83 c0 08             	add    $0x8,%eax
80102b4b:	01 c0                	add    %eax,%eax
80102b4d:	83 ec 08             	sub    $0x8,%esp
80102b50:	52                   	push   %edx
80102b51:	50                   	push   %eax
80102b52:	e8 5c ff ff ff       	call   80102ab3 <ioapicwrite>
80102b57:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b5d:	83 c0 08             	add    $0x8,%eax
80102b60:	01 c0                	add    %eax,%eax
80102b62:	83 c0 01             	add    $0x1,%eax
80102b65:	83 ec 08             	sub    $0x8,%esp
80102b68:	6a 00                	push   $0x0
80102b6a:	50                   	push   %eax
80102b6b:	e8 43 ff ff ff       	call   80102ab3 <ioapicwrite>
80102b70:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b7d:	7e b9                	jle    80102b38 <ioapicinit+0x6a>
80102b7f:	eb 01                	jmp    80102b82 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102b81:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b82:	c9                   	leave  
80102b83:	c3                   	ret    

80102b84 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b84:	55                   	push   %ebp
80102b85:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b87:	a1 64 33 11 80       	mov    0x80113364,%eax
80102b8c:	85 c0                	test   %eax,%eax
80102b8e:	74 39                	je     80102bc9 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b90:	8b 45 08             	mov    0x8(%ebp),%eax
80102b93:	83 c0 20             	add    $0x20,%eax
80102b96:	89 c2                	mov    %eax,%edx
80102b98:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9b:	83 c0 08             	add    $0x8,%eax
80102b9e:	01 c0                	add    %eax,%eax
80102ba0:	52                   	push   %edx
80102ba1:	50                   	push   %eax
80102ba2:	e8 0c ff ff ff       	call   80102ab3 <ioapicwrite>
80102ba7:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102baa:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bad:	c1 e0 18             	shl    $0x18,%eax
80102bb0:	89 c2                	mov    %eax,%edx
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	83 c0 08             	add    $0x8,%eax
80102bb8:	01 c0                	add    %eax,%eax
80102bba:	83 c0 01             	add    $0x1,%eax
80102bbd:	52                   	push   %edx
80102bbe:	50                   	push   %eax
80102bbf:	e8 ef fe ff ff       	call   80102ab3 <ioapicwrite>
80102bc4:	83 c4 08             	add    $0x8,%esp
80102bc7:	eb 01                	jmp    80102bca <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102bc9:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102bca:	c9                   	leave  
80102bcb:	c3                   	ret    

80102bcc <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102bcc:	55                   	push   %ebp
80102bcd:	89 e5                	mov    %esp,%ebp
80102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd2:	05 00 00 00 80       	add    $0x80000000,%eax
80102bd7:	5d                   	pop    %ebp
80102bd8:	c3                   	ret    

80102bd9 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bd9:	55                   	push   %ebp
80102bda:	89 e5                	mov    %esp,%ebp
80102bdc:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bdf:	83 ec 08             	sub    $0x8,%esp
80102be2:	68 12 97 10 80       	push   $0x80109712
80102be7:	68 40 32 11 80       	push   $0x80113240
80102bec:	e8 1f 32 00 00       	call   80105e10 <initlock>
80102bf1:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102bf4:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102bfb:	00 00 00 
  freerange(vstart, vend);
80102bfe:	83 ec 08             	sub    $0x8,%esp
80102c01:	ff 75 0c             	pushl  0xc(%ebp)
80102c04:	ff 75 08             	pushl  0x8(%ebp)
80102c07:	e8 2a 00 00 00       	call   80102c36 <freerange>
80102c0c:	83 c4 10             	add    $0x10,%esp
}
80102c0f:	90                   	nop
80102c10:	c9                   	leave  
80102c11:	c3                   	ret    

80102c12 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c12:	55                   	push   %ebp
80102c13:	89 e5                	mov    %esp,%ebp
80102c15:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c18:	83 ec 08             	sub    $0x8,%esp
80102c1b:	ff 75 0c             	pushl  0xc(%ebp)
80102c1e:	ff 75 08             	pushl  0x8(%ebp)
80102c21:	e8 10 00 00 00       	call   80102c36 <freerange>
80102c26:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c29:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102c30:	00 00 00 
}
80102c33:	90                   	nop
80102c34:	c9                   	leave  
80102c35:	c3                   	ret    

80102c36 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c36:	55                   	push   %ebp
80102c37:	89 e5                	mov    %esp,%ebp
80102c39:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c3f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c4c:	eb 15                	jmp    80102c63 <freerange+0x2d>
    kfree(p);
80102c4e:	83 ec 0c             	sub    $0xc,%esp
80102c51:	ff 75 f4             	pushl  -0xc(%ebp)
80102c54:	e8 1a 00 00 00       	call   80102c73 <kfree>
80102c59:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c66:	05 00 10 00 00       	add    $0x1000,%eax
80102c6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c6e:	76 de                	jbe    80102c4e <freerange+0x18>
    kfree(p);
}
80102c70:	90                   	nop
80102c71:	c9                   	leave  
80102c72:	c3                   	ret    

80102c73 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c73:	55                   	push   %ebp
80102c74:	89 e5                	mov    %esp,%ebp
80102c76:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c79:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7c:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c81:	85 c0                	test   %eax,%eax
80102c83:	75 1b                	jne    80102ca0 <kfree+0x2d>
80102c85:	81 7d 08 dc 6b 11 80 	cmpl   $0x80116bdc,0x8(%ebp)
80102c8c:	72 12                	jb     80102ca0 <kfree+0x2d>
80102c8e:	ff 75 08             	pushl  0x8(%ebp)
80102c91:	e8 36 ff ff ff       	call   80102bcc <v2p>
80102c96:	83 c4 04             	add    $0x4,%esp
80102c99:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c9e:	76 0d                	jbe    80102cad <kfree+0x3a>
    panic("kfree");
80102ca0:	83 ec 0c             	sub    $0xc,%esp
80102ca3:	68 17 97 10 80       	push   $0x80109717
80102ca8:	e8 b9 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cad:	83 ec 04             	sub    $0x4,%esp
80102cb0:	68 00 10 00 00       	push   $0x1000
80102cb5:	6a 01                	push   $0x1
80102cb7:	ff 75 08             	pushl  0x8(%ebp)
80102cba:	e8 d6 33 00 00       	call   80106095 <memset>
80102cbf:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cc2:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cc7:	85 c0                	test   %eax,%eax
80102cc9:	74 10                	je     80102cdb <kfree+0x68>
    acquire(&kmem.lock);
80102ccb:	83 ec 0c             	sub    $0xc,%esp
80102cce:	68 40 32 11 80       	push   $0x80113240
80102cd3:	e8 5a 31 00 00       	call   80105e32 <acquire>
80102cd8:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ce1:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cea:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cef:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102cf4:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cf9:	85 c0                	test   %eax,%eax
80102cfb:	74 10                	je     80102d0d <kfree+0x9a>
    release(&kmem.lock);
80102cfd:	83 ec 0c             	sub    $0xc,%esp
80102d00:	68 40 32 11 80       	push   $0x80113240
80102d05:	e8 8f 31 00 00       	call   80105e99 <release>
80102d0a:	83 c4 10             	add    $0x10,%esp
}
80102d0d:	90                   	nop
80102d0e:	c9                   	leave  
80102d0f:	c3                   	ret    

80102d10 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d10:	55                   	push   %ebp
80102d11:	89 e5                	mov    %esp,%ebp
80102d13:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d16:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 10                	je     80102d2f <kalloc+0x1f>
    acquire(&kmem.lock);
80102d1f:	83 ec 0c             	sub    $0xc,%esp
80102d22:	68 40 32 11 80       	push   $0x80113240
80102d27:	e8 06 31 00 00       	call   80105e32 <acquire>
80102d2c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d2f:	a1 78 32 11 80       	mov    0x80113278,%eax
80102d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d3b:	74 0a                	je     80102d47 <kalloc+0x37>
    kmem.freelist = r->next;
80102d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d40:	8b 00                	mov    (%eax),%eax
80102d42:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102d47:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d4c:	85 c0                	test   %eax,%eax
80102d4e:	74 10                	je     80102d60 <kalloc+0x50>
    release(&kmem.lock);
80102d50:	83 ec 0c             	sub    $0xc,%esp
80102d53:	68 40 32 11 80       	push   $0x80113240
80102d58:	e8 3c 31 00 00       	call   80105e99 <release>
80102d5d:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d63:	c9                   	leave  
80102d64:	c3                   	ret    

80102d65 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102d65:	55                   	push   %ebp
80102d66:	89 e5                	mov    %esp,%ebp
80102d68:	83 ec 14             	sub    $0x14,%esp
80102d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d72:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d76:	89 c2                	mov    %eax,%edx
80102d78:	ec                   	in     (%dx),%al
80102d79:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d7c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d80:	c9                   	leave  
80102d81:	c3                   	ret    

80102d82 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d82:	55                   	push   %ebp
80102d83:	89 e5                	mov    %esp,%ebp
80102d85:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d88:	6a 64                	push   $0x64
80102d8a:	e8 d6 ff ff ff       	call   80102d65 <inb>
80102d8f:	83 c4 04             	add    $0x4,%esp
80102d92:	0f b6 c0             	movzbl %al,%eax
80102d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9b:	83 e0 01             	and    $0x1,%eax
80102d9e:	85 c0                	test   %eax,%eax
80102da0:	75 0a                	jne    80102dac <kbdgetc+0x2a>
    return -1;
80102da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102da7:	e9 23 01 00 00       	jmp    80102ecf <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102dac:	6a 60                	push   $0x60
80102dae:	e8 b2 ff ff ff       	call   80102d65 <inb>
80102db3:	83 c4 04             	add    $0x4,%esp
80102db6:	0f b6 c0             	movzbl %al,%eax
80102db9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102dbc:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dc3:	75 17                	jne    80102ddc <kbdgetc+0x5a>
    shift |= E0ESC;
80102dc5:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dca:	83 c8 40             	or     $0x40,%eax
80102dcd:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102dd2:	b8 00 00 00 00       	mov    $0x0,%eax
80102dd7:	e9 f3 00 00 00       	jmp    80102ecf <kbdgetc+0x14d>
  } else if(data & 0x80){
80102ddc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ddf:	25 80 00 00 00       	and    $0x80,%eax
80102de4:	85 c0                	test   %eax,%eax
80102de6:	74 45                	je     80102e2d <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102de8:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ded:	83 e0 40             	and    $0x40,%eax
80102df0:	85 c0                	test   %eax,%eax
80102df2:	75 08                	jne    80102dfc <kbdgetc+0x7a>
80102df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df7:	83 e0 7f             	and    $0x7f,%eax
80102dfa:	eb 03                	jmp    80102dff <kbdgetc+0x7d>
80102dfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dff:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e05:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e0a:	0f b6 00             	movzbl (%eax),%eax
80102e0d:	83 c8 40             	or     $0x40,%eax
80102e10:	0f b6 c0             	movzbl %al,%eax
80102e13:	f7 d0                	not    %eax
80102e15:	89 c2                	mov    %eax,%edx
80102e17:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e1c:	21 d0                	and    %edx,%eax
80102e1e:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102e23:	b8 00 00 00 00       	mov    $0x0,%eax
80102e28:	e9 a2 00 00 00       	jmp    80102ecf <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e2d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e32:	83 e0 40             	and    $0x40,%eax
80102e35:	85 c0                	test   %eax,%eax
80102e37:	74 14                	je     80102e4d <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e39:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e40:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e45:	83 e0 bf             	and    $0xffffffbf,%eax
80102e48:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e50:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e55:	0f b6 00             	movzbl (%eax),%eax
80102e58:	0f b6 d0             	movzbl %al,%edx
80102e5b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e60:	09 d0                	or     %edx,%eax
80102e62:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102e67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e6a:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e6f:	0f b6 00             	movzbl (%eax),%eax
80102e72:	0f b6 d0             	movzbl %al,%edx
80102e75:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e7a:	31 d0                	xor    %edx,%eax
80102e7c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e81:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e86:	83 e0 03             	and    $0x3,%eax
80102e89:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e93:	01 d0                	add    %edx,%eax
80102e95:	0f b6 00             	movzbl (%eax),%eax
80102e98:	0f b6 c0             	movzbl %al,%eax
80102e9b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e9e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ea3:	83 e0 08             	and    $0x8,%eax
80102ea6:	85 c0                	test   %eax,%eax
80102ea8:	74 22                	je     80102ecc <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102eaa:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102eae:	76 0c                	jbe    80102ebc <kbdgetc+0x13a>
80102eb0:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102eb4:	77 06                	ja     80102ebc <kbdgetc+0x13a>
      c += 'A' - 'a';
80102eb6:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102eba:	eb 10                	jmp    80102ecc <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ebc:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ec0:	76 0a                	jbe    80102ecc <kbdgetc+0x14a>
80102ec2:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ec6:	77 04                	ja     80102ecc <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ec8:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ecc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ecf:	c9                   	leave  
80102ed0:	c3                   	ret    

80102ed1 <kbdintr>:

void
kbdintr(void)
{
80102ed1:	55                   	push   %ebp
80102ed2:	89 e5                	mov    %esp,%ebp
80102ed4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ed7:	83 ec 0c             	sub    $0xc,%esp
80102eda:	68 82 2d 10 80       	push   $0x80102d82
80102edf:	e8 15 d9 ff ff       	call   801007f9 <consoleintr>
80102ee4:	83 c4 10             	add    $0x10,%esp
}
80102ee7:	90                   	nop
80102ee8:	c9                   	leave  
80102ee9:	c3                   	ret    

80102eea <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102eea:	55                   	push   %ebp
80102eeb:	89 e5                	mov    %esp,%ebp
80102eed:	83 ec 14             	sub    $0x14,%esp
80102ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ef7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102efb:	89 c2                	mov    %eax,%edx
80102efd:	ec                   	in     (%dx),%al
80102efe:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f01:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f05:	c9                   	leave  
80102f06:	c3                   	ret    

80102f07 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f07:	55                   	push   %ebp
80102f08:	89 e5                	mov    %esp,%ebp
80102f0a:	83 ec 08             	sub    $0x8,%esp
80102f0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f13:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f17:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f1a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f1e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f22:	ee                   	out    %al,(%dx)
}
80102f23:	90                   	nop
80102f24:	c9                   	leave  
80102f25:	c3                   	ret    

80102f26 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f26:	55                   	push   %ebp
80102f27:	89 e5                	mov    %esp,%ebp
80102f29:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f2c:	9c                   	pushf  
80102f2d:	58                   	pop    %eax
80102f2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f34:	c9                   	leave  
80102f35:	c3                   	ret    

80102f36 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f36:	55                   	push   %ebp
80102f37:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f39:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f3e:	8b 55 08             	mov    0x8(%ebp),%edx
80102f41:	c1 e2 02             	shl    $0x2,%edx
80102f44:	01 c2                	add    %eax,%edx
80102f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f49:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f4b:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f50:	83 c0 20             	add    $0x20,%eax
80102f53:	8b 00                	mov    (%eax),%eax
}
80102f55:	90                   	nop
80102f56:	5d                   	pop    %ebp
80102f57:	c3                   	ret    

80102f58 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102f58:	55                   	push   %ebp
80102f59:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102f5b:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f60:	85 c0                	test   %eax,%eax
80102f62:	0f 84 0b 01 00 00    	je     80103073 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f68:	68 3f 01 00 00       	push   $0x13f
80102f6d:	6a 3c                	push   $0x3c
80102f6f:	e8 c2 ff ff ff       	call   80102f36 <lapicw>
80102f74:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f77:	6a 0b                	push   $0xb
80102f79:	68 f8 00 00 00       	push   $0xf8
80102f7e:	e8 b3 ff ff ff       	call   80102f36 <lapicw>
80102f83:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f86:	68 20 00 02 00       	push   $0x20020
80102f8b:	68 c8 00 00 00       	push   $0xc8
80102f90:	e8 a1 ff ff ff       	call   80102f36 <lapicw>
80102f95:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102f98:	68 40 42 0f 00       	push   $0xf4240
80102f9d:	68 e0 00 00 00       	push   $0xe0
80102fa2:	e8 8f ff ff ff       	call   80102f36 <lapicw>
80102fa7:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102faa:	68 00 00 01 00       	push   $0x10000
80102faf:	68 d4 00 00 00       	push   $0xd4
80102fb4:	e8 7d ff ff ff       	call   80102f36 <lapicw>
80102fb9:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fbc:	68 00 00 01 00       	push   $0x10000
80102fc1:	68 d8 00 00 00       	push   $0xd8
80102fc6:	e8 6b ff ff ff       	call   80102f36 <lapicw>
80102fcb:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fce:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fd3:	83 c0 30             	add    $0x30,%eax
80102fd6:	8b 00                	mov    (%eax),%eax
80102fd8:	c1 e8 10             	shr    $0x10,%eax
80102fdb:	0f b6 c0             	movzbl %al,%eax
80102fde:	83 f8 03             	cmp    $0x3,%eax
80102fe1:	76 12                	jbe    80102ff5 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102fe3:	68 00 00 01 00       	push   $0x10000
80102fe8:	68 d0 00 00 00       	push   $0xd0
80102fed:	e8 44 ff ff ff       	call   80102f36 <lapicw>
80102ff2:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ff5:	6a 33                	push   $0x33
80102ff7:	68 dc 00 00 00       	push   $0xdc
80102ffc:	e8 35 ff ff ff       	call   80102f36 <lapicw>
80103001:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103004:	6a 00                	push   $0x0
80103006:	68 a0 00 00 00       	push   $0xa0
8010300b:	e8 26 ff ff ff       	call   80102f36 <lapicw>
80103010:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103013:	6a 00                	push   $0x0
80103015:	68 a0 00 00 00       	push   $0xa0
8010301a:	e8 17 ff ff ff       	call   80102f36 <lapicw>
8010301f:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103022:	6a 00                	push   $0x0
80103024:	6a 2c                	push   $0x2c
80103026:	e8 0b ff ff ff       	call   80102f36 <lapicw>
8010302b:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010302e:	6a 00                	push   $0x0
80103030:	68 c4 00 00 00       	push   $0xc4
80103035:	e8 fc fe ff ff       	call   80102f36 <lapicw>
8010303a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010303d:	68 00 85 08 00       	push   $0x88500
80103042:	68 c0 00 00 00       	push   $0xc0
80103047:	e8 ea fe ff ff       	call   80102f36 <lapicw>
8010304c:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010304f:	90                   	nop
80103050:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80103055:	05 00 03 00 00       	add    $0x300,%eax
8010305a:	8b 00                	mov    (%eax),%eax
8010305c:	25 00 10 00 00       	and    $0x1000,%eax
80103061:	85 c0                	test   %eax,%eax
80103063:	75 eb                	jne    80103050 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103065:	6a 00                	push   $0x0
80103067:	6a 20                	push   $0x20
80103069:	e8 c8 fe ff ff       	call   80102f36 <lapicw>
8010306e:	83 c4 08             	add    $0x8,%esp
80103071:	eb 01                	jmp    80103074 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80103073:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103074:	c9                   	leave  
80103075:	c3                   	ret    

80103076 <cpunum>:

int
cpunum(void)
{
80103076:	55                   	push   %ebp
80103077:	89 e5                	mov    %esp,%ebp
80103079:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010307c:	e8 a5 fe ff ff       	call   80102f26 <readeflags>
80103081:	25 00 02 00 00       	and    $0x200,%eax
80103086:	85 c0                	test   %eax,%eax
80103088:	74 26                	je     801030b0 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
8010308a:	a1 60 c6 10 80       	mov    0x8010c660,%eax
8010308f:	8d 50 01             	lea    0x1(%eax),%edx
80103092:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80103098:	85 c0                	test   %eax,%eax
8010309a:	75 14                	jne    801030b0 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010309c:	8b 45 04             	mov    0x4(%ebp),%eax
8010309f:	83 ec 08             	sub    $0x8,%esp
801030a2:	50                   	push   %eax
801030a3:	68 20 97 10 80       	push   $0x80109720
801030a8:	e8 19 d3 ff ff       	call   801003c6 <cprintf>
801030ad:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801030b0:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030b5:	85 c0                	test   %eax,%eax
801030b7:	74 0f                	je     801030c8 <cpunum+0x52>
    return lapic[ID]>>24;
801030b9:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030be:	83 c0 20             	add    $0x20,%eax
801030c1:	8b 00                	mov    (%eax),%eax
801030c3:	c1 e8 18             	shr    $0x18,%eax
801030c6:	eb 05                	jmp    801030cd <cpunum+0x57>
  return 0;
801030c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030cd:	c9                   	leave  
801030ce:	c3                   	ret    

801030cf <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030cf:	55                   	push   %ebp
801030d0:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030d2:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030d7:	85 c0                	test   %eax,%eax
801030d9:	74 0c                	je     801030e7 <lapiceoi+0x18>
    lapicw(EOI, 0);
801030db:	6a 00                	push   $0x0
801030dd:	6a 2c                	push   $0x2c
801030df:	e8 52 fe ff ff       	call   80102f36 <lapicw>
801030e4:	83 c4 08             	add    $0x8,%esp
}
801030e7:	90                   	nop
801030e8:	c9                   	leave  
801030e9:	c3                   	ret    

801030ea <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030ea:	55                   	push   %ebp
801030eb:	89 e5                	mov    %esp,%ebp
}
801030ed:	90                   	nop
801030ee:	5d                   	pop    %ebp
801030ef:	c3                   	ret    

801030f0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030f0:	55                   	push   %ebp
801030f1:	89 e5                	mov    %esp,%ebp
801030f3:	83 ec 14             	sub    $0x14,%esp
801030f6:	8b 45 08             	mov    0x8(%ebp),%eax
801030f9:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030fc:	6a 0f                	push   $0xf
801030fe:	6a 70                	push   $0x70
80103100:	e8 02 fe ff ff       	call   80102f07 <outb>
80103105:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103108:	6a 0a                	push   $0xa
8010310a:	6a 71                	push   $0x71
8010310c:	e8 f6 fd ff ff       	call   80102f07 <outb>
80103111:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103114:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010311b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010311e:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103123:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103126:	83 c0 02             	add    $0x2,%eax
80103129:	8b 55 0c             	mov    0xc(%ebp),%edx
8010312c:	c1 ea 04             	shr    $0x4,%edx
8010312f:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103132:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103136:	c1 e0 18             	shl    $0x18,%eax
80103139:	50                   	push   %eax
8010313a:	68 c4 00 00 00       	push   $0xc4
8010313f:	e8 f2 fd ff ff       	call   80102f36 <lapicw>
80103144:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103147:	68 00 c5 00 00       	push   $0xc500
8010314c:	68 c0 00 00 00       	push   $0xc0
80103151:	e8 e0 fd ff ff       	call   80102f36 <lapicw>
80103156:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103159:	68 c8 00 00 00       	push   $0xc8
8010315e:	e8 87 ff ff ff       	call   801030ea <microdelay>
80103163:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103166:	68 00 85 00 00       	push   $0x8500
8010316b:	68 c0 00 00 00       	push   $0xc0
80103170:	e8 c1 fd ff ff       	call   80102f36 <lapicw>
80103175:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103178:	6a 64                	push   $0x64
8010317a:	e8 6b ff ff ff       	call   801030ea <microdelay>
8010317f:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103182:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103189:	eb 3d                	jmp    801031c8 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010318b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010318f:	c1 e0 18             	shl    $0x18,%eax
80103192:	50                   	push   %eax
80103193:	68 c4 00 00 00       	push   $0xc4
80103198:	e8 99 fd ff ff       	call   80102f36 <lapicw>
8010319d:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801031a3:	c1 e8 0c             	shr    $0xc,%eax
801031a6:	80 cc 06             	or     $0x6,%ah
801031a9:	50                   	push   %eax
801031aa:	68 c0 00 00 00       	push   $0xc0
801031af:	e8 82 fd ff ff       	call   80102f36 <lapicw>
801031b4:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801031b7:	68 c8 00 00 00       	push   $0xc8
801031bc:	e8 29 ff ff ff       	call   801030ea <microdelay>
801031c1:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031c4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031c8:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031cc:	7e bd                	jle    8010318b <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031ce:	90                   	nop
801031cf:	c9                   	leave  
801031d0:	c3                   	ret    

801031d1 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031d1:	55                   	push   %ebp
801031d2:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031d4:	8b 45 08             	mov    0x8(%ebp),%eax
801031d7:	0f b6 c0             	movzbl %al,%eax
801031da:	50                   	push   %eax
801031db:	6a 70                	push   $0x70
801031dd:	e8 25 fd ff ff       	call   80102f07 <outb>
801031e2:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031e5:	68 c8 00 00 00       	push   $0xc8
801031ea:	e8 fb fe ff ff       	call   801030ea <microdelay>
801031ef:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031f2:	6a 71                	push   $0x71
801031f4:	e8 f1 fc ff ff       	call   80102eea <inb>
801031f9:	83 c4 04             	add    $0x4,%esp
801031fc:	0f b6 c0             	movzbl %al,%eax
}
801031ff:	c9                   	leave  
80103200:	c3                   	ret    

80103201 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103201:	55                   	push   %ebp
80103202:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103204:	6a 00                	push   $0x0
80103206:	e8 c6 ff ff ff       	call   801031d1 <cmos_read>
8010320b:	83 c4 04             	add    $0x4,%esp
8010320e:	89 c2                	mov    %eax,%edx
80103210:	8b 45 08             	mov    0x8(%ebp),%eax
80103213:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103215:	6a 02                	push   $0x2
80103217:	e8 b5 ff ff ff       	call   801031d1 <cmos_read>
8010321c:	83 c4 04             	add    $0x4,%esp
8010321f:	89 c2                	mov    %eax,%edx
80103221:	8b 45 08             	mov    0x8(%ebp),%eax
80103224:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103227:	6a 04                	push   $0x4
80103229:	e8 a3 ff ff ff       	call   801031d1 <cmos_read>
8010322e:	83 c4 04             	add    $0x4,%esp
80103231:	89 c2                	mov    %eax,%edx
80103233:	8b 45 08             	mov    0x8(%ebp),%eax
80103236:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103239:	6a 07                	push   $0x7
8010323b:	e8 91 ff ff ff       	call   801031d1 <cmos_read>
80103240:	83 c4 04             	add    $0x4,%esp
80103243:	89 c2                	mov    %eax,%edx
80103245:	8b 45 08             	mov    0x8(%ebp),%eax
80103248:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
8010324b:	6a 08                	push   $0x8
8010324d:	e8 7f ff ff ff       	call   801031d1 <cmos_read>
80103252:	83 c4 04             	add    $0x4,%esp
80103255:	89 c2                	mov    %eax,%edx
80103257:	8b 45 08             	mov    0x8(%ebp),%eax
8010325a:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
8010325d:	6a 09                	push   $0x9
8010325f:	e8 6d ff ff ff       	call   801031d1 <cmos_read>
80103264:	83 c4 04             	add    $0x4,%esp
80103267:	89 c2                	mov    %eax,%edx
80103269:	8b 45 08             	mov    0x8(%ebp),%eax
8010326c:	89 50 14             	mov    %edx,0x14(%eax)
}
8010326f:	90                   	nop
80103270:	c9                   	leave  
80103271:	c3                   	ret    

80103272 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103272:	55                   	push   %ebp
80103273:	89 e5                	mov    %esp,%ebp
80103275:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103278:	6a 0b                	push   $0xb
8010327a:	e8 52 ff ff ff       	call   801031d1 <cmos_read>
8010327f:	83 c4 04             	add    $0x4,%esp
80103282:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103288:	83 e0 04             	and    $0x4,%eax
8010328b:	85 c0                	test   %eax,%eax
8010328d:	0f 94 c0             	sete   %al
80103290:	0f b6 c0             	movzbl %al,%eax
80103293:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103296:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103299:	50                   	push   %eax
8010329a:	e8 62 ff ff ff       	call   80103201 <fill_rtcdate>
8010329f:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801032a2:	6a 0a                	push   $0xa
801032a4:	e8 28 ff ff ff       	call   801031d1 <cmos_read>
801032a9:	83 c4 04             	add    $0x4,%esp
801032ac:	25 80 00 00 00       	and    $0x80,%eax
801032b1:	85 c0                	test   %eax,%eax
801032b3:	75 27                	jne    801032dc <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801032b5:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032b8:	50                   	push   %eax
801032b9:	e8 43 ff ff ff       	call   80103201 <fill_rtcdate>
801032be:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801032c1:	83 ec 04             	sub    $0x4,%esp
801032c4:	6a 18                	push   $0x18
801032c6:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032c9:	50                   	push   %eax
801032ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032cd:	50                   	push   %eax
801032ce:	e8 29 2e 00 00       	call   801060fc <memcmp>
801032d3:	83 c4 10             	add    $0x10,%esp
801032d6:	85 c0                	test   %eax,%eax
801032d8:	74 05                	je     801032df <cmostime+0x6d>
801032da:	eb ba                	jmp    80103296 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032dc:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032dd:	eb b7                	jmp    80103296 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032df:	90                   	nop
  }

  // convert
  if (bcd) {
801032e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032e4:	0f 84 b4 00 00 00    	je     8010339e <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032ed:	c1 e8 04             	shr    $0x4,%eax
801032f0:	89 c2                	mov    %eax,%edx
801032f2:	89 d0                	mov    %edx,%eax
801032f4:	c1 e0 02             	shl    $0x2,%eax
801032f7:	01 d0                	add    %edx,%eax
801032f9:	01 c0                	add    %eax,%eax
801032fb:	89 c2                	mov    %eax,%edx
801032fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103300:	83 e0 0f             	and    $0xf,%eax
80103303:	01 d0                	add    %edx,%eax
80103305:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103308:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010330b:	c1 e8 04             	shr    $0x4,%eax
8010330e:	89 c2                	mov    %eax,%edx
80103310:	89 d0                	mov    %edx,%eax
80103312:	c1 e0 02             	shl    $0x2,%eax
80103315:	01 d0                	add    %edx,%eax
80103317:	01 c0                	add    %eax,%eax
80103319:	89 c2                	mov    %eax,%edx
8010331b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010331e:	83 e0 0f             	and    $0xf,%eax
80103321:	01 d0                	add    %edx,%eax
80103323:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103326:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103329:	c1 e8 04             	shr    $0x4,%eax
8010332c:	89 c2                	mov    %eax,%edx
8010332e:	89 d0                	mov    %edx,%eax
80103330:	c1 e0 02             	shl    $0x2,%eax
80103333:	01 d0                	add    %edx,%eax
80103335:	01 c0                	add    %eax,%eax
80103337:	89 c2                	mov    %eax,%edx
80103339:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010333c:	83 e0 0f             	and    $0xf,%eax
8010333f:	01 d0                	add    %edx,%eax
80103341:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103347:	c1 e8 04             	shr    $0x4,%eax
8010334a:	89 c2                	mov    %eax,%edx
8010334c:	89 d0                	mov    %edx,%eax
8010334e:	c1 e0 02             	shl    $0x2,%eax
80103351:	01 d0                	add    %edx,%eax
80103353:	01 c0                	add    %eax,%eax
80103355:	89 c2                	mov    %eax,%edx
80103357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010335a:	83 e0 0f             	and    $0xf,%eax
8010335d:	01 d0                	add    %edx,%eax
8010335f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103362:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103365:	c1 e8 04             	shr    $0x4,%eax
80103368:	89 c2                	mov    %eax,%edx
8010336a:	89 d0                	mov    %edx,%eax
8010336c:	c1 e0 02             	shl    $0x2,%eax
8010336f:	01 d0                	add    %edx,%eax
80103371:	01 c0                	add    %eax,%eax
80103373:	89 c2                	mov    %eax,%edx
80103375:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103378:	83 e0 0f             	and    $0xf,%eax
8010337b:	01 d0                	add    %edx,%eax
8010337d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103383:	c1 e8 04             	shr    $0x4,%eax
80103386:	89 c2                	mov    %eax,%edx
80103388:	89 d0                	mov    %edx,%eax
8010338a:	c1 e0 02             	shl    $0x2,%eax
8010338d:	01 d0                	add    %edx,%eax
8010338f:	01 c0                	add    %eax,%eax
80103391:	89 c2                	mov    %eax,%edx
80103393:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103396:	83 e0 0f             	and    $0xf,%eax
80103399:	01 d0                	add    %edx,%eax
8010339b:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010339e:	8b 45 08             	mov    0x8(%ebp),%eax
801033a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033a4:	89 10                	mov    %edx,(%eax)
801033a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033a9:	89 50 04             	mov    %edx,0x4(%eax)
801033ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033af:	89 50 08             	mov    %edx,0x8(%eax)
801033b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033b5:	89 50 0c             	mov    %edx,0xc(%eax)
801033b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033bb:	89 50 10             	mov    %edx,0x10(%eax)
801033be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033c1:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033c4:	8b 45 08             	mov    0x8(%ebp),%eax
801033c7:	8b 40 14             	mov    0x14(%eax),%eax
801033ca:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033d0:	8b 45 08             	mov    0x8(%ebp),%eax
801033d3:	89 50 14             	mov    %edx,0x14(%eax)
}
801033d6:	90                   	nop
801033d7:	c9                   	leave  
801033d8:	c3                   	ret    

801033d9 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033d9:	55                   	push   %ebp
801033da:	89 e5                	mov    %esp,%ebp
801033dc:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033df:	83 ec 08             	sub    $0x8,%esp
801033e2:	68 4c 97 10 80       	push   $0x8010974c
801033e7:	68 80 32 11 80       	push   $0x80113280
801033ec:	e8 1f 2a 00 00       	call   80105e10 <initlock>
801033f1:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033f4:	83 ec 08             	sub    $0x8,%esp
801033f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033fa:	50                   	push   %eax
801033fb:	ff 75 08             	pushl  0x8(%ebp)
801033fe:	e8 2b e0 ff ff       	call   8010142e <readsb>
80103403:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103406:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103409:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
8010340e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103411:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = dev;
80103416:	8b 45 08             	mov    0x8(%ebp),%eax
80103419:	a3 c4 32 11 80       	mov    %eax,0x801132c4
  recover_from_log();
8010341e:	e8 b2 01 00 00       	call   801035d5 <recover_from_log>
}
80103423:	90                   	nop
80103424:	c9                   	leave  
80103425:	c3                   	ret    

80103426 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103426:	55                   	push   %ebp
80103427:	89 e5                	mov    %esp,%ebp
80103429:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010342c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103433:	e9 95 00 00 00       	jmp    801034cd <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103438:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010343e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103441:	01 d0                	add    %edx,%eax
80103443:	83 c0 01             	add    $0x1,%eax
80103446:	89 c2                	mov    %eax,%edx
80103448:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	52                   	push   %edx
80103451:	50                   	push   %eax
80103452:	e8 5f cd ff ff       	call   801001b6 <bread>
80103457:	83 c4 10             	add    $0x10,%esp
8010345a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010345d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103460:	83 c0 10             	add    $0x10,%eax
80103463:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010346a:	89 c2                	mov    %eax,%edx
8010346c:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103471:	83 ec 08             	sub    $0x8,%esp
80103474:	52                   	push   %edx
80103475:	50                   	push   %eax
80103476:	e8 3b cd ff ff       	call   801001b6 <bread>
8010347b:	83 c4 10             	add    $0x10,%esp
8010347e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103484:	8d 50 18             	lea    0x18(%eax),%edx
80103487:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010348a:	83 c0 18             	add    $0x18,%eax
8010348d:	83 ec 04             	sub    $0x4,%esp
80103490:	68 00 02 00 00       	push   $0x200
80103495:	52                   	push   %edx
80103496:	50                   	push   %eax
80103497:	e8 b8 2c 00 00       	call   80106154 <memmove>
8010349c:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010349f:	83 ec 0c             	sub    $0xc,%esp
801034a2:	ff 75 ec             	pushl  -0x14(%ebp)
801034a5:	e8 45 cd ff ff       	call   801001ef <bwrite>
801034aa:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801034ad:	83 ec 0c             	sub    $0xc,%esp
801034b0:	ff 75 f0             	pushl  -0x10(%ebp)
801034b3:	e8 76 cd ff ff       	call   8010022e <brelse>
801034b8:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801034bb:	83 ec 0c             	sub    $0xc,%esp
801034be:	ff 75 ec             	pushl  -0x14(%ebp)
801034c1:	e8 68 cd ff ff       	call   8010022e <brelse>
801034c6:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034cd:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034d5:	0f 8f 5d ff ff ff    	jg     80103438 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034db:	90                   	nop
801034dc:	c9                   	leave  
801034dd:	c3                   	ret    

801034de <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034de:	55                   	push   %ebp
801034df:	89 e5                	mov    %esp,%ebp
801034e1:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034e4:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801034e9:	89 c2                	mov    %eax,%edx
801034eb:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801034f0:	83 ec 08             	sub    $0x8,%esp
801034f3:	52                   	push   %edx
801034f4:	50                   	push   %eax
801034f5:	e8 bc cc ff ff       	call   801001b6 <bread>
801034fa:	83 c4 10             	add    $0x10,%esp
801034fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103503:	83 c0 18             	add    $0x18,%eax
80103506:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103509:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010350c:	8b 00                	mov    (%eax),%eax
8010350e:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103513:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010351a:	eb 1b                	jmp    80103537 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010351c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103522:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103526:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103529:	83 c2 10             	add    $0x10,%edx
8010352c:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103533:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103537:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010353c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010353f:	7f db                	jg     8010351c <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103541:	83 ec 0c             	sub    $0xc,%esp
80103544:	ff 75 f0             	pushl  -0x10(%ebp)
80103547:	e8 e2 cc ff ff       	call   8010022e <brelse>
8010354c:	83 c4 10             	add    $0x10,%esp
}
8010354f:	90                   	nop
80103550:	c9                   	leave  
80103551:	c3                   	ret    

80103552 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103552:	55                   	push   %ebp
80103553:	89 e5                	mov    %esp,%ebp
80103555:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103558:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010355d:	89 c2                	mov    %eax,%edx
8010355f:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103564:	83 ec 08             	sub    $0x8,%esp
80103567:	52                   	push   %edx
80103568:	50                   	push   %eax
80103569:	e8 48 cc ff ff       	call   801001b6 <bread>
8010356e:	83 c4 10             	add    $0x10,%esp
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103577:	83 c0 18             	add    $0x18,%eax
8010357a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010357d:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
80103583:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103586:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103588:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010358f:	eb 1b                	jmp    801035ac <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103594:	83 c0 10             	add    $0x10,%eax
80103597:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
8010359e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035a4:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035ac:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035b1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035b4:	7f db                	jg     80103591 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035b6:	83 ec 0c             	sub    $0xc,%esp
801035b9:	ff 75 f0             	pushl  -0x10(%ebp)
801035bc:	e8 2e cc ff ff       	call   801001ef <bwrite>
801035c1:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801035c4:	83 ec 0c             	sub    $0xc,%esp
801035c7:	ff 75 f0             	pushl  -0x10(%ebp)
801035ca:	e8 5f cc ff ff       	call   8010022e <brelse>
801035cf:	83 c4 10             	add    $0x10,%esp
}
801035d2:	90                   	nop
801035d3:	c9                   	leave  
801035d4:	c3                   	ret    

801035d5 <recover_from_log>:

static void
recover_from_log(void)
{
801035d5:	55                   	push   %ebp
801035d6:	89 e5                	mov    %esp,%ebp
801035d8:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801035db:	e8 fe fe ff ff       	call   801034de <read_head>
  install_trans(); // if committed, copy from log to disk
801035e0:	e8 41 fe ff ff       	call   80103426 <install_trans>
  log.lh.n = 0;
801035e5:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801035ec:	00 00 00 
  write_head(); // clear the log
801035ef:	e8 5e ff ff ff       	call   80103552 <write_head>
}
801035f4:	90                   	nop
801035f5:	c9                   	leave  
801035f6:	c3                   	ret    

801035f7 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035f7:	55                   	push   %ebp
801035f8:	89 e5                	mov    %esp,%ebp
801035fa:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035fd:	83 ec 0c             	sub    $0xc,%esp
80103600:	68 80 32 11 80       	push   $0x80113280
80103605:	e8 28 28 00 00       	call   80105e32 <acquire>
8010360a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010360d:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103612:	85 c0                	test   %eax,%eax
80103614:	74 17                	je     8010362d <begin_op+0x36>
      sleep(&log, &log.lock);
80103616:	83 ec 08             	sub    $0x8,%esp
80103619:	68 80 32 11 80       	push   $0x80113280
8010361e:	68 80 32 11 80       	push   $0x80113280
80103623:	e8 db 1d 00 00       	call   80105403 <sleep>
80103628:	83 c4 10             	add    $0x10,%esp
8010362b:	eb e0                	jmp    8010360d <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010362d:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103633:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103638:	8d 50 01             	lea    0x1(%eax),%edx
8010363b:	89 d0                	mov    %edx,%eax
8010363d:	c1 e0 02             	shl    $0x2,%eax
80103640:	01 d0                	add    %edx,%eax
80103642:	01 c0                	add    %eax,%eax
80103644:	01 c8                	add    %ecx,%eax
80103646:	83 f8 1e             	cmp    $0x1e,%eax
80103649:	7e 17                	jle    80103662 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010364b:	83 ec 08             	sub    $0x8,%esp
8010364e:	68 80 32 11 80       	push   $0x80113280
80103653:	68 80 32 11 80       	push   $0x80113280
80103658:	e8 a6 1d 00 00       	call   80105403 <sleep>
8010365d:	83 c4 10             	add    $0x10,%esp
80103660:	eb ab                	jmp    8010360d <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103662:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103667:	83 c0 01             	add    $0x1,%eax
8010366a:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	68 80 32 11 80       	push   $0x80113280
80103677:	e8 1d 28 00 00       	call   80105e99 <release>
8010367c:	83 c4 10             	add    $0x10,%esp
      break;
8010367f:	90                   	nop
    }
  }
}
80103680:	90                   	nop
80103681:	c9                   	leave  
80103682:	c3                   	ret    

80103683 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103683:	55                   	push   %ebp
80103684:	89 e5                	mov    %esp,%ebp
80103686:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103689:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103690:	83 ec 0c             	sub    $0xc,%esp
80103693:	68 80 32 11 80       	push   $0x80113280
80103698:	e8 95 27 00 00       	call   80105e32 <acquire>
8010369d:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801036a0:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036a5:	83 e8 01             	sub    $0x1,%eax
801036a8:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801036ad:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	74 0d                	je     801036c3 <end_op+0x40>
    panic("log.committing");
801036b6:	83 ec 0c             	sub    $0xc,%esp
801036b9:	68 50 97 10 80       	push   $0x80109750
801036be:	e8 a3 ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036c3:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036c8:	85 c0                	test   %eax,%eax
801036ca:	75 13                	jne    801036df <end_op+0x5c>
    do_commit = 1;
801036cc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036d3:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801036da:	00 00 00 
801036dd:	eb 10                	jmp    801036ef <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036df:	83 ec 0c             	sub    $0xc,%esp
801036e2:	68 80 32 11 80       	push   $0x80113280
801036e7:	e8 92 1e 00 00       	call   8010557e <wakeup>
801036ec:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	68 80 32 11 80       	push   $0x80113280
801036f7:	e8 9d 27 00 00       	call   80105e99 <release>
801036fc:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103703:	74 3f                	je     80103744 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103705:	e8 f5 00 00 00       	call   801037ff <commit>
    acquire(&log.lock);
8010370a:	83 ec 0c             	sub    $0xc,%esp
8010370d:	68 80 32 11 80       	push   $0x80113280
80103712:	e8 1b 27 00 00       	call   80105e32 <acquire>
80103717:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010371a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103721:	00 00 00 
    wakeup(&log);
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	68 80 32 11 80       	push   $0x80113280
8010372c:	e8 4d 1e 00 00       	call   8010557e <wakeup>
80103731:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103734:	83 ec 0c             	sub    $0xc,%esp
80103737:	68 80 32 11 80       	push   $0x80113280
8010373c:	e8 58 27 00 00       	call   80105e99 <release>
80103741:	83 c4 10             	add    $0x10,%esp
  }
}
80103744:	90                   	nop
80103745:	c9                   	leave  
80103746:	c3                   	ret    

80103747 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103747:	55                   	push   %ebp
80103748:	89 e5                	mov    %esp,%ebp
8010374a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010374d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103754:	e9 95 00 00 00       	jmp    801037ee <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103759:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010375f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103762:	01 d0                	add    %edx,%eax
80103764:	83 c0 01             	add    $0x1,%eax
80103767:	89 c2                	mov    %eax,%edx
80103769:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010376e:	83 ec 08             	sub    $0x8,%esp
80103771:	52                   	push   %edx
80103772:	50                   	push   %eax
80103773:	e8 3e ca ff ff       	call   801001b6 <bread>
80103778:	83 c4 10             	add    $0x10,%esp
8010377b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010377e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103781:	83 c0 10             	add    $0x10,%eax
80103784:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010378b:	89 c2                	mov    %eax,%edx
8010378d:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103792:	83 ec 08             	sub    $0x8,%esp
80103795:	52                   	push   %edx
80103796:	50                   	push   %eax
80103797:	e8 1a ca ff ff       	call   801001b6 <bread>
8010379c:	83 c4 10             	add    $0x10,%esp
8010379f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801037a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037a5:	8d 50 18             	lea    0x18(%eax),%edx
801037a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ab:	83 c0 18             	add    $0x18,%eax
801037ae:	83 ec 04             	sub    $0x4,%esp
801037b1:	68 00 02 00 00       	push   $0x200
801037b6:	52                   	push   %edx
801037b7:	50                   	push   %eax
801037b8:	e8 97 29 00 00       	call   80106154 <memmove>
801037bd:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801037c0:	83 ec 0c             	sub    $0xc,%esp
801037c3:	ff 75 f0             	pushl  -0x10(%ebp)
801037c6:	e8 24 ca ff ff       	call   801001ef <bwrite>
801037cb:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801037ce:	83 ec 0c             	sub    $0xc,%esp
801037d1:	ff 75 ec             	pushl  -0x14(%ebp)
801037d4:	e8 55 ca ff ff       	call   8010022e <brelse>
801037d9:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037dc:	83 ec 0c             	sub    $0xc,%esp
801037df:	ff 75 f0             	pushl  -0x10(%ebp)
801037e2:	e8 47 ca ff ff       	call   8010022e <brelse>
801037e7:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037ee:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037f3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037f6:	0f 8f 5d ff ff ff    	jg     80103759 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801037fc:	90                   	nop
801037fd:	c9                   	leave  
801037fe:	c3                   	ret    

801037ff <commit>:

static void
commit()
{
801037ff:	55                   	push   %ebp
80103800:	89 e5                	mov    %esp,%ebp
80103802:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103805:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010380a:	85 c0                	test   %eax,%eax
8010380c:	7e 1e                	jle    8010382c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010380e:	e8 34 ff ff ff       	call   80103747 <write_log>
    write_head();    // Write header to disk -- the real commit
80103813:	e8 3a fd ff ff       	call   80103552 <write_head>
    install_trans(); // Now install writes to home locations
80103818:	e8 09 fc ff ff       	call   80103426 <install_trans>
    log.lh.n = 0; 
8010381d:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103824:	00 00 00 
    write_head();    // Erase the transaction from the log
80103827:	e8 26 fd ff ff       	call   80103552 <write_head>
  }
}
8010382c:	90                   	nop
8010382d:	c9                   	leave  
8010382e:	c3                   	ret    

8010382f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103835:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010383a:	83 f8 1d             	cmp    $0x1d,%eax
8010383d:	7f 12                	jg     80103851 <log_write+0x22>
8010383f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103844:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
8010384a:	83 ea 01             	sub    $0x1,%edx
8010384d:	39 d0                	cmp    %edx,%eax
8010384f:	7c 0d                	jl     8010385e <log_write+0x2f>
    panic("too big a transaction");
80103851:	83 ec 0c             	sub    $0xc,%esp
80103854:	68 5f 97 10 80       	push   $0x8010975f
80103859:	e8 08 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010385e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103863:	85 c0                	test   %eax,%eax
80103865:	7f 0d                	jg     80103874 <log_write+0x45>
    panic("log_write outside of trans");
80103867:	83 ec 0c             	sub    $0xc,%esp
8010386a:	68 75 97 10 80       	push   $0x80109775
8010386f:	e8 f2 cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103874:	83 ec 0c             	sub    $0xc,%esp
80103877:	68 80 32 11 80       	push   $0x80113280
8010387c:	e8 b1 25 00 00       	call   80105e32 <acquire>
80103881:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103884:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010388b:	eb 1d                	jmp    801038aa <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010388d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103890:	83 c0 10             	add    $0x10,%eax
80103893:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010389a:	89 c2                	mov    %eax,%edx
8010389c:	8b 45 08             	mov    0x8(%ebp),%eax
8010389f:	8b 40 08             	mov    0x8(%eax),%eax
801038a2:	39 c2                	cmp    %eax,%edx
801038a4:	74 10                	je     801038b6 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801038a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038aa:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038af:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038b2:	7f d9                	jg     8010388d <log_write+0x5e>
801038b4:	eb 01                	jmp    801038b7 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801038b6:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801038b7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ba:	8b 40 08             	mov    0x8(%eax),%eax
801038bd:	89 c2                	mov    %eax,%edx
801038bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038c2:	83 c0 10             	add    $0x10,%eax
801038c5:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801038cc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038d4:	75 0d                	jne    801038e3 <log_write+0xb4>
    log.lh.n++;
801038d6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038db:	83 c0 01             	add    $0x1,%eax
801038de:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801038e3:	8b 45 08             	mov    0x8(%ebp),%eax
801038e6:	8b 00                	mov    (%eax),%eax
801038e8:	83 c8 04             	or     $0x4,%eax
801038eb:	89 c2                	mov    %eax,%edx
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038f2:	83 ec 0c             	sub    $0xc,%esp
801038f5:	68 80 32 11 80       	push   $0x80113280
801038fa:	e8 9a 25 00 00       	call   80105e99 <release>
801038ff:	83 c4 10             	add    $0x10,%esp
}
80103902:	90                   	nop
80103903:	c9                   	leave  
80103904:	c3                   	ret    

80103905 <v2p>:
80103905:	55                   	push   %ebp
80103906:	89 e5                	mov    %esp,%ebp
80103908:	8b 45 08             	mov    0x8(%ebp),%eax
8010390b:	05 00 00 00 80       	add    $0x80000000,%eax
80103910:	5d                   	pop    %ebp
80103911:	c3                   	ret    

80103912 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103912:	55                   	push   %ebp
80103913:	89 e5                	mov    %esp,%ebp
80103915:	8b 45 08             	mov    0x8(%ebp),%eax
80103918:	05 00 00 00 80       	add    $0x80000000,%eax
8010391d:	5d                   	pop    %ebp
8010391e:	c3                   	ret    

8010391f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010391f:	55                   	push   %ebp
80103920:	89 e5                	mov    %esp,%ebp
80103922:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103925:	8b 55 08             	mov    0x8(%ebp),%edx
80103928:	8b 45 0c             	mov    0xc(%ebp),%eax
8010392b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010392e:	f0 87 02             	lock xchg %eax,(%edx)
80103931:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103934:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103937:	c9                   	leave  
80103938:	c3                   	ret    

80103939 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103939:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010393d:	83 e4 f0             	and    $0xfffffff0,%esp
80103940:	ff 71 fc             	pushl  -0x4(%ecx)
80103943:	55                   	push   %ebp
80103944:	89 e5                	mov    %esp,%ebp
80103946:	51                   	push   %ecx
80103947:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010394a:	83 ec 08             	sub    $0x8,%esp
8010394d:	68 00 00 40 80       	push   $0x80400000
80103952:	68 dc 6b 11 80       	push   $0x80116bdc
80103957:	e8 7d f2 ff ff       	call   80102bd9 <kinit1>
8010395c:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010395f:	e8 fc 53 00 00       	call   80108d60 <kvmalloc>
  mpinit();        // collect info about this machine
80103964:	e8 43 04 00 00       	call   80103dac <mpinit>
  lapicinit();
80103969:	e8 ea f5 ff ff       	call   80102f58 <lapicinit>
  seginit();       // set up segments
8010396e:	e8 96 4d 00 00       	call   80108709 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103973:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103979:	0f b6 00             	movzbl (%eax),%eax
8010397c:	0f b6 c0             	movzbl %al,%eax
8010397f:	83 ec 08             	sub    $0x8,%esp
80103982:	50                   	push   %eax
80103983:	68 90 97 10 80       	push   $0x80109790
80103988:	e8 39 ca ff ff       	call   801003c6 <cprintf>
8010398d:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103990:	e8 6d 06 00 00       	call   80104002 <picinit>
  ioapicinit();    // another interrupt controller
80103995:	e8 34 f1 ff ff       	call   80102ace <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010399a:	e8 24 d2 ff ff       	call   80100bc3 <consoleinit>
  uartinit();      // serial port
8010399f:	e8 c1 40 00 00       	call   80107a65 <uartinit>
  pinit();         // process table
801039a4:	e8 9c 0d 00 00       	call   80104745 <pinit>
  tvinit();        // trap vectors
801039a9:	e8 90 3c 00 00       	call   8010763e <tvinit>
  binit();         // buffer cache
801039ae:	e8 81 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039b3:	e8 67 d6 ff ff       	call   8010101f <fileinit>
  ideinit();       // disk
801039b8:	e8 19 ed ff ff       	call   801026d6 <ideinit>
  if(!ismp)
801039bd:	a1 64 33 11 80       	mov    0x80113364,%eax
801039c2:	85 c0                	test   %eax,%eax
801039c4:	75 05                	jne    801039cb <main+0x92>
    timerinit();   // uniprocessor timer
801039c6:	e8 c4 3b 00 00       	call   8010758f <timerinit>
  startothers();   // start other processors
801039cb:	e8 7f 00 00 00       	call   80103a4f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039d0:	83 ec 08             	sub    $0x8,%esp
801039d3:	68 00 00 00 8e       	push   $0x8e000000
801039d8:	68 00 00 40 80       	push   $0x80400000
801039dd:	e8 30 f2 ff ff       	call   80102c12 <kinit2>
801039e2:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039e5:	e8 55 0f 00 00       	call   8010493f <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801039ea:	e8 1a 00 00 00       	call   80103a09 <mpmain>

801039ef <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039ef:	55                   	push   %ebp
801039f0:	89 e5                	mov    %esp,%ebp
801039f2:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801039f5:	e8 7e 53 00 00       	call   80108d78 <switchkvm>
  seginit();
801039fa:	e8 0a 4d 00 00       	call   80108709 <seginit>
  lapicinit();
801039ff:	e8 54 f5 ff ff       	call   80102f58 <lapicinit>
  mpmain();
80103a04:	e8 00 00 00 00       	call   80103a09 <mpmain>

80103a09 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103a0f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a15:	0f b6 00             	movzbl (%eax),%eax
80103a18:	0f b6 c0             	movzbl %al,%eax
80103a1b:	83 ec 08             	sub    $0x8,%esp
80103a1e:	50                   	push   %eax
80103a1f:	68 a7 97 10 80       	push   $0x801097a7
80103a24:	e8 9d c9 ff ff       	call   801003c6 <cprintf>
80103a29:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a2c:	e8 6e 3d 00 00       	call   8010779f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a31:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a37:	05 a8 00 00 00       	add    $0xa8,%eax
80103a3c:	83 ec 08             	sub    $0x8,%esp
80103a3f:	6a 01                	push   $0x1
80103a41:	50                   	push   %eax
80103a42:	e8 d8 fe ff ff       	call   8010391f <xchg>
80103a47:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a4a:	e8 fb 16 00 00       	call   8010514a <scheduler>

80103a4f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	53                   	push   %ebx
80103a53:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103a56:	68 00 70 00 00       	push   $0x7000
80103a5b:	e8 b2 fe ff ff       	call   80103912 <p2v>
80103a60:	83 c4 04             	add    $0x4,%esp
80103a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a66:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a6b:	83 ec 04             	sub    $0x4,%esp
80103a6e:	50                   	push   %eax
80103a6f:	68 2c c5 10 80       	push   $0x8010c52c
80103a74:	ff 75 f0             	pushl  -0x10(%ebp)
80103a77:	e8 d8 26 00 00       	call   80106154 <memmove>
80103a7c:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a7f:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103a86:	e9 90 00 00 00       	jmp    80103b1b <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a8b:	e8 e6 f5 ff ff       	call   80103076 <cpunum>
80103a90:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a96:	05 80 33 11 80       	add    $0x80113380,%eax
80103a9b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a9e:	74 73                	je     80103b13 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103aa0:	e8 6b f2 ff ff       	call   80102d10 <kalloc>
80103aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aab:	83 e8 04             	sub    $0x4,%eax
80103aae:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ab1:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103ab7:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abc:	83 e8 08             	sub    $0x8,%eax
80103abf:	c7 00 ef 39 10 80    	movl   $0x801039ef,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac8:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 b0 10 80       	push   $0x8010b000
80103ad3:	e8 2d fe ff ff       	call   80103905 <v2p>
80103ad8:	83 c4 10             	add    $0x10,%esp
80103adb:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103add:	83 ec 0c             	sub    $0xc,%esp
80103ae0:	ff 75 f0             	pushl  -0x10(%ebp)
80103ae3:	e8 1d fe ff ff       	call   80103905 <v2p>
80103ae8:	83 c4 10             	add    $0x10,%esp
80103aeb:	89 c2                	mov    %eax,%edx
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	0f b6 00             	movzbl (%eax),%eax
80103af3:	0f b6 c0             	movzbl %al,%eax
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	52                   	push   %edx
80103afa:	50                   	push   %eax
80103afb:	e8 f0 f5 ff ff       	call   801030f0 <lapicstartap>
80103b00:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b03:	90                   	nop
80103b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b07:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103b0d:	85 c0                	test   %eax,%eax
80103b0f:	74 f3                	je     80103b04 <startothers+0xb5>
80103b11:	eb 01                	jmp    80103b14 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103b13:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b14:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103b1b:	a1 60 39 11 80       	mov    0x80113960,%eax
80103b20:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b26:	05 80 33 11 80       	add    $0x80113380,%eax
80103b2b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b2e:	0f 87 57 ff ff ff    	ja     80103a8b <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b34:	90                   	nop
80103b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b38:	c9                   	leave  
80103b39:	c3                   	ret    

80103b3a <p2v>:
80103b3a:	55                   	push   %ebp
80103b3b:	89 e5                	mov    %esp,%ebp
80103b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b40:	05 00 00 00 80       	add    $0x80000000,%eax
80103b45:	5d                   	pop    %ebp
80103b46:	c3                   	ret    

80103b47 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103b47:	55                   	push   %ebp
80103b48:	89 e5                	mov    %esp,%ebp
80103b4a:	83 ec 14             	sub    $0x14,%esp
80103b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b50:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b54:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b58:	89 c2                	mov    %eax,%edx
80103b5a:	ec                   	in     (%dx),%al
80103b5b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b5e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b62:	c9                   	leave  
80103b63:	c3                   	ret    

80103b64 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b64:	55                   	push   %ebp
80103b65:	89 e5                	mov    %esp,%ebp
80103b67:	83 ec 08             	sub    $0x8,%esp
80103b6a:	8b 55 08             	mov    0x8(%ebp),%edx
80103b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b70:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b74:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b77:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b7b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b7f:	ee                   	out    %al,(%dx)
}
80103b80:	90                   	nop
80103b81:	c9                   	leave  
80103b82:	c3                   	ret    

80103b83 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b83:	55                   	push   %ebp
80103b84:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b86:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103b8b:	89 c2                	mov    %eax,%edx
80103b8d:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103b92:	29 c2                	sub    %eax,%edx
80103b94:	89 d0                	mov    %edx,%eax
80103b96:	c1 f8 02             	sar    $0x2,%eax
80103b99:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b9f:	5d                   	pop    %ebp
80103ba0:	c3                   	ret    

80103ba1 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103ba1:	55                   	push   %ebp
80103ba2:	89 e5                	mov    %esp,%ebp
80103ba4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103ba7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103bae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103bb5:	eb 15                	jmp    80103bcc <sum+0x2b>
    sum += addr[i];
80103bb7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bba:	8b 45 08             	mov    0x8(%ebp),%eax
80103bbd:	01 d0                	add    %edx,%eax
80103bbf:	0f b6 00             	movzbl (%eax),%eax
80103bc2:	0f b6 c0             	movzbl %al,%eax
80103bc5:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103bc8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103bcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103bcf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103bd2:	7c e3                	jl     80103bb7 <sum+0x16>
    sum += addr[i];
  return sum;
80103bd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103bd7:	c9                   	leave  
80103bd8:	c3                   	ret    

80103bd9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103bd9:	55                   	push   %ebp
80103bda:	89 e5                	mov    %esp,%ebp
80103bdc:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103bdf:	ff 75 08             	pushl  0x8(%ebp)
80103be2:	e8 53 ff ff ff       	call   80103b3a <p2v>
80103be7:	83 c4 04             	add    $0x4,%esp
80103bea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103bed:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf3:	01 d0                	add    %edx,%eax
80103bf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bfe:	eb 36                	jmp    80103c36 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c00:	83 ec 04             	sub    $0x4,%esp
80103c03:	6a 04                	push   $0x4
80103c05:	68 b8 97 10 80       	push   $0x801097b8
80103c0a:	ff 75 f4             	pushl  -0xc(%ebp)
80103c0d:	e8 ea 24 00 00       	call   801060fc <memcmp>
80103c12:	83 c4 10             	add    $0x10,%esp
80103c15:	85 c0                	test   %eax,%eax
80103c17:	75 19                	jne    80103c32 <mpsearch1+0x59>
80103c19:	83 ec 08             	sub    $0x8,%esp
80103c1c:	6a 10                	push   $0x10
80103c1e:	ff 75 f4             	pushl  -0xc(%ebp)
80103c21:	e8 7b ff ff ff       	call   80103ba1 <sum>
80103c26:	83 c4 10             	add    $0x10,%esp
80103c29:	84 c0                	test   %al,%al
80103c2b:	75 05                	jne    80103c32 <mpsearch1+0x59>
      return (struct mp*)p;
80103c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c30:	eb 11                	jmp    80103c43 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c32:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c39:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c3c:	72 c2                	jb     80103c00 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c43:	c9                   	leave  
80103c44:	c3                   	ret    

80103c45 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c45:	55                   	push   %ebp
80103c46:	89 e5                	mov    %esp,%ebp
80103c48:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c4b:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c55:	83 c0 0f             	add    $0xf,%eax
80103c58:	0f b6 00             	movzbl (%eax),%eax
80103c5b:	0f b6 c0             	movzbl %al,%eax
80103c5e:	c1 e0 08             	shl    $0x8,%eax
80103c61:	89 c2                	mov    %eax,%edx
80103c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c66:	83 c0 0e             	add    $0xe,%eax
80103c69:	0f b6 00             	movzbl (%eax),%eax
80103c6c:	0f b6 c0             	movzbl %al,%eax
80103c6f:	09 d0                	or     %edx,%eax
80103c71:	c1 e0 04             	shl    $0x4,%eax
80103c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c7b:	74 21                	je     80103c9e <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c7d:	83 ec 08             	sub    $0x8,%esp
80103c80:	68 00 04 00 00       	push   $0x400
80103c85:	ff 75 f0             	pushl  -0x10(%ebp)
80103c88:	e8 4c ff ff ff       	call   80103bd9 <mpsearch1>
80103c8d:	83 c4 10             	add    $0x10,%esp
80103c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c93:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c97:	74 51                	je     80103cea <mpsearch+0xa5>
      return mp;
80103c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c9c:	eb 61                	jmp    80103cff <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca1:	83 c0 14             	add    $0x14,%eax
80103ca4:	0f b6 00             	movzbl (%eax),%eax
80103ca7:	0f b6 c0             	movzbl %al,%eax
80103caa:	c1 e0 08             	shl    $0x8,%eax
80103cad:	89 c2                	mov    %eax,%edx
80103caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb2:	83 c0 13             	add    $0x13,%eax
80103cb5:	0f b6 00             	movzbl (%eax),%eax
80103cb8:	0f b6 c0             	movzbl %al,%eax
80103cbb:	09 d0                	or     %edx,%eax
80103cbd:	c1 e0 0a             	shl    $0xa,%eax
80103cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc6:	2d 00 04 00 00       	sub    $0x400,%eax
80103ccb:	83 ec 08             	sub    $0x8,%esp
80103cce:	68 00 04 00 00       	push   $0x400
80103cd3:	50                   	push   %eax
80103cd4:	e8 00 ff ff ff       	call   80103bd9 <mpsearch1>
80103cd9:	83 c4 10             	add    $0x10,%esp
80103cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cdf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ce3:	74 05                	je     80103cea <mpsearch+0xa5>
      return mp;
80103ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ce8:	eb 15                	jmp    80103cff <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103cea:	83 ec 08             	sub    $0x8,%esp
80103ced:	68 00 00 01 00       	push   $0x10000
80103cf2:	68 00 00 0f 00       	push   $0xf0000
80103cf7:	e8 dd fe ff ff       	call   80103bd9 <mpsearch1>
80103cfc:	83 c4 10             	add    $0x10,%esp
}
80103cff:	c9                   	leave  
80103d00:	c3                   	ret    

80103d01 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d01:	55                   	push   %ebp
80103d02:	89 e5                	mov    %esp,%ebp
80103d04:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d07:	e8 39 ff ff ff       	call   80103c45 <mpsearch>
80103d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d13:	74 0a                	je     80103d1f <mpconfig+0x1e>
80103d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d18:	8b 40 04             	mov    0x4(%eax),%eax
80103d1b:	85 c0                	test   %eax,%eax
80103d1d:	75 0a                	jne    80103d29 <mpconfig+0x28>
    return 0;
80103d1f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d24:	e9 81 00 00 00       	jmp    80103daa <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2c:	8b 40 04             	mov    0x4(%eax),%eax
80103d2f:	83 ec 0c             	sub    $0xc,%esp
80103d32:	50                   	push   %eax
80103d33:	e8 02 fe ff ff       	call   80103b3a <p2v>
80103d38:	83 c4 10             	add    $0x10,%esp
80103d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d3e:	83 ec 04             	sub    $0x4,%esp
80103d41:	6a 04                	push   $0x4
80103d43:	68 bd 97 10 80       	push   $0x801097bd
80103d48:	ff 75 f0             	pushl  -0x10(%ebp)
80103d4b:	e8 ac 23 00 00       	call   801060fc <memcmp>
80103d50:	83 c4 10             	add    $0x10,%esp
80103d53:	85 c0                	test   %eax,%eax
80103d55:	74 07                	je     80103d5e <mpconfig+0x5d>
    return 0;
80103d57:	b8 00 00 00 00       	mov    $0x0,%eax
80103d5c:	eb 4c                	jmp    80103daa <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d61:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d65:	3c 01                	cmp    $0x1,%al
80103d67:	74 12                	je     80103d7b <mpconfig+0x7a>
80103d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d70:	3c 04                	cmp    $0x4,%al
80103d72:	74 07                	je     80103d7b <mpconfig+0x7a>
    return 0;
80103d74:	b8 00 00 00 00       	mov    $0x0,%eax
80103d79:	eb 2f                	jmp    80103daa <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d82:	0f b7 c0             	movzwl %ax,%eax
80103d85:	83 ec 08             	sub    $0x8,%esp
80103d88:	50                   	push   %eax
80103d89:	ff 75 f0             	pushl  -0x10(%ebp)
80103d8c:	e8 10 fe ff ff       	call   80103ba1 <sum>
80103d91:	83 c4 10             	add    $0x10,%esp
80103d94:	84 c0                	test   %al,%al
80103d96:	74 07                	je     80103d9f <mpconfig+0x9e>
    return 0;
80103d98:	b8 00 00 00 00       	mov    $0x0,%eax
80103d9d:	eb 0b                	jmp    80103daa <mpconfig+0xa9>
  *pmp = mp;
80103d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103da5:	89 10                	mov    %edx,(%eax)
  return conf;
80103da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103daa:	c9                   	leave  
80103dab:	c3                   	ret    

80103dac <mpinit>:

void
mpinit(void)
{
80103dac:	55                   	push   %ebp
80103dad:	89 e5                	mov    %esp,%ebp
80103daf:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103db2:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103db9:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103dbc:	83 ec 0c             	sub    $0xc,%esp
80103dbf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103dc2:	50                   	push   %eax
80103dc3:	e8 39 ff ff ff       	call   80103d01 <mpconfig>
80103dc8:	83 c4 10             	add    $0x10,%esp
80103dcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103dce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dd2:	0f 84 96 01 00 00    	je     80103f6e <mpinit+0x1c2>
    return;
  ismp = 1;
80103dd8:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103ddf:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de5:	8b 40 24             	mov    0x24(%eax),%eax
80103de8:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df0:	83 c0 2c             	add    $0x2c,%eax
80103df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103dfd:	0f b7 d0             	movzwl %ax,%edx
80103e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e03:	01 d0                	add    %edx,%eax
80103e05:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e08:	e9 f2 00 00 00       	jmp    80103eff <mpinit+0x153>
    switch(*p){
80103e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e10:	0f b6 00             	movzbl (%eax),%eax
80103e13:	0f b6 c0             	movzbl %al,%eax
80103e16:	83 f8 04             	cmp    $0x4,%eax
80103e19:	0f 87 bc 00 00 00    	ja     80103edb <mpinit+0x12f>
80103e1f:	8b 04 85 00 98 10 80 	mov    -0x7fef6800(,%eax,4),%eax
80103e26:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e31:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e35:	0f b6 d0             	movzbl %al,%edx
80103e38:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e3d:	39 c2                	cmp    %eax,%edx
80103e3f:	74 2b                	je     80103e6c <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e44:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e48:	0f b6 d0             	movzbl %al,%edx
80103e4b:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e50:	83 ec 04             	sub    $0x4,%esp
80103e53:	52                   	push   %edx
80103e54:	50                   	push   %eax
80103e55:	68 c2 97 10 80       	push   $0x801097c2
80103e5a:	e8 67 c5 ff ff       	call   801003c6 <cprintf>
80103e5f:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e62:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103e69:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e6f:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e73:	0f b6 c0             	movzbl %al,%eax
80103e76:	83 e0 02             	and    $0x2,%eax
80103e79:	85 c0                	test   %eax,%eax
80103e7b:	74 15                	je     80103e92 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103e7d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e82:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e88:	05 80 33 11 80       	add    $0x80113380,%eax
80103e8d:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103e92:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e97:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103e9d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ea3:	05 80 33 11 80       	add    $0x80113380,%eax
80103ea8:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103eaa:	a1 60 39 11 80       	mov    0x80113960,%eax
80103eaf:	83 c0 01             	add    $0x1,%eax
80103eb2:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103eb7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ebb:	eb 42                	jmp    80103eff <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ec3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ec6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103eca:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103ecf:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ed3:	eb 2a                	jmp    80103eff <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ed5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ed9:	eb 24                	jmp    80103eff <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ede:	0f b6 00             	movzbl (%eax),%eax
80103ee1:	0f b6 c0             	movzbl %al,%eax
80103ee4:	83 ec 08             	sub    $0x8,%esp
80103ee7:	50                   	push   %eax
80103ee8:	68 e0 97 10 80       	push   $0x801097e0
80103eed:	e8 d4 c4 ff ff       	call   801003c6 <cprintf>
80103ef2:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103ef5:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103efc:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f02:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f05:	0f 82 02 ff ff ff    	jb     80103e0d <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103f0b:	a1 64 33 11 80       	mov    0x80113364,%eax
80103f10:	85 c0                	test   %eax,%eax
80103f12:	75 1d                	jne    80103f31 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f14:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f1b:	00 00 00 
    lapic = 0;
80103f1e:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f25:	00 00 00 
    ioapicid = 0;
80103f28:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f2f:	eb 3e                	jmp    80103f6f <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f34:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f38:	84 c0                	test   %al,%al
80103f3a:	74 33                	je     80103f6f <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f3c:	83 ec 08             	sub    $0x8,%esp
80103f3f:	6a 70                	push   $0x70
80103f41:	6a 22                	push   $0x22
80103f43:	e8 1c fc ff ff       	call   80103b64 <outb>
80103f48:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f4b:	83 ec 0c             	sub    $0xc,%esp
80103f4e:	6a 23                	push   $0x23
80103f50:	e8 f2 fb ff ff       	call   80103b47 <inb>
80103f55:	83 c4 10             	add    $0x10,%esp
80103f58:	83 c8 01             	or     $0x1,%eax
80103f5b:	0f b6 c0             	movzbl %al,%eax
80103f5e:	83 ec 08             	sub    $0x8,%esp
80103f61:	50                   	push   %eax
80103f62:	6a 23                	push   $0x23
80103f64:	e8 fb fb ff ff       	call   80103b64 <outb>
80103f69:	83 c4 10             	add    $0x10,%esp
80103f6c:	eb 01                	jmp    80103f6f <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103f6e:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103f6f:	c9                   	leave  
80103f70:	c3                   	ret    

80103f71 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f71:	55                   	push   %ebp
80103f72:	89 e5                	mov    %esp,%ebp
80103f74:	83 ec 08             	sub    $0x8,%esp
80103f77:	8b 55 08             	mov    0x8(%ebp),%edx
80103f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f7d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f81:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f84:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f88:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f8c:	ee                   	out    %al,(%dx)
}
80103f8d:	90                   	nop
80103f8e:	c9                   	leave  
80103f8f:	c3                   	ret    

80103f90 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
80103f93:	83 ec 04             	sub    $0x4,%esp
80103f96:	8b 45 08             	mov    0x8(%ebp),%eax
80103f99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f9d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fa1:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103fa7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fab:	0f b6 c0             	movzbl %al,%eax
80103fae:	50                   	push   %eax
80103faf:	6a 21                	push   $0x21
80103fb1:	e8 bb ff ff ff       	call   80103f71 <outb>
80103fb6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103fb9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fbd:	66 c1 e8 08          	shr    $0x8,%ax
80103fc1:	0f b6 c0             	movzbl %al,%eax
80103fc4:	50                   	push   %eax
80103fc5:	68 a1 00 00 00       	push   $0xa1
80103fca:	e8 a2 ff ff ff       	call   80103f71 <outb>
80103fcf:	83 c4 08             	add    $0x8,%esp
}
80103fd2:	90                   	nop
80103fd3:	c9                   	leave  
80103fd4:	c3                   	ret    

80103fd5 <picenable>:

void
picenable(int irq)
{
80103fd5:	55                   	push   %ebp
80103fd6:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdb:	ba 01 00 00 00       	mov    $0x1,%edx
80103fe0:	89 c1                	mov    %eax,%ecx
80103fe2:	d3 e2                	shl    %cl,%edx
80103fe4:	89 d0                	mov    %edx,%eax
80103fe6:	f7 d0                	not    %eax
80103fe8:	89 c2                	mov    %eax,%edx
80103fea:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103ff1:	21 d0                	and    %edx,%eax
80103ff3:	0f b7 c0             	movzwl %ax,%eax
80103ff6:	50                   	push   %eax
80103ff7:	e8 94 ff ff ff       	call   80103f90 <picsetmask>
80103ffc:	83 c4 04             	add    $0x4,%esp
}
80103fff:	90                   	nop
80104000:	c9                   	leave  
80104001:	c3                   	ret    

80104002 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104002:	55                   	push   %ebp
80104003:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104005:	68 ff 00 00 00       	push   $0xff
8010400a:	6a 21                	push   $0x21
8010400c:	e8 60 ff ff ff       	call   80103f71 <outb>
80104011:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104014:	68 ff 00 00 00       	push   $0xff
80104019:	68 a1 00 00 00       	push   $0xa1
8010401e:	e8 4e ff ff ff       	call   80103f71 <outb>
80104023:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104026:	6a 11                	push   $0x11
80104028:	6a 20                	push   $0x20
8010402a:	e8 42 ff ff ff       	call   80103f71 <outb>
8010402f:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104032:	6a 20                	push   $0x20
80104034:	6a 21                	push   $0x21
80104036:	e8 36 ff ff ff       	call   80103f71 <outb>
8010403b:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
8010403e:	6a 04                	push   $0x4
80104040:	6a 21                	push   $0x21
80104042:	e8 2a ff ff ff       	call   80103f71 <outb>
80104047:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010404a:	6a 03                	push   $0x3
8010404c:	6a 21                	push   $0x21
8010404e:	e8 1e ff ff ff       	call   80103f71 <outb>
80104053:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104056:	6a 11                	push   $0x11
80104058:	68 a0 00 00 00       	push   $0xa0
8010405d:	e8 0f ff ff ff       	call   80103f71 <outb>
80104062:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104065:	6a 28                	push   $0x28
80104067:	68 a1 00 00 00       	push   $0xa1
8010406c:	e8 00 ff ff ff       	call   80103f71 <outb>
80104071:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104074:	6a 02                	push   $0x2
80104076:	68 a1 00 00 00       	push   $0xa1
8010407b:	e8 f1 fe ff ff       	call   80103f71 <outb>
80104080:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104083:	6a 03                	push   $0x3
80104085:	68 a1 00 00 00       	push   $0xa1
8010408a:	e8 e2 fe ff ff       	call   80103f71 <outb>
8010408f:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104092:	6a 68                	push   $0x68
80104094:	6a 20                	push   $0x20
80104096:	e8 d6 fe ff ff       	call   80103f71 <outb>
8010409b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
8010409e:	6a 0a                	push   $0xa
801040a0:	6a 20                	push   $0x20
801040a2:	e8 ca fe ff ff       	call   80103f71 <outb>
801040a7:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801040aa:	6a 68                	push   $0x68
801040ac:	68 a0 00 00 00       	push   $0xa0
801040b1:	e8 bb fe ff ff       	call   80103f71 <outb>
801040b6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801040b9:	6a 0a                	push   $0xa
801040bb:	68 a0 00 00 00       	push   $0xa0
801040c0:	e8 ac fe ff ff       	call   80103f71 <outb>
801040c5:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801040c8:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040cf:	66 83 f8 ff          	cmp    $0xffff,%ax
801040d3:	74 13                	je     801040e8 <picinit+0xe6>
    picsetmask(irqmask);
801040d5:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040dc:	0f b7 c0             	movzwl %ax,%eax
801040df:	50                   	push   %eax
801040e0:	e8 ab fe ff ff       	call   80103f90 <picsetmask>
801040e5:	83 c4 04             	add    $0x4,%esp
}
801040e8:	90                   	nop
801040e9:	c9                   	leave  
801040ea:	c3                   	ret    

801040eb <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040eb:	55                   	push   %ebp
801040ec:	89 e5                	mov    %esp,%ebp
801040ee:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801040f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104101:	8b 45 0c             	mov    0xc(%ebp),%eax
80104104:	8b 10                	mov    (%eax),%edx
80104106:	8b 45 08             	mov    0x8(%ebp),%eax
80104109:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010410b:	e8 2d cf ff ff       	call   8010103d <filealloc>
80104110:	89 c2                	mov    %eax,%edx
80104112:	8b 45 08             	mov    0x8(%ebp),%eax
80104115:	89 10                	mov    %edx,(%eax)
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	8b 00                	mov    (%eax),%eax
8010411c:	85 c0                	test   %eax,%eax
8010411e:	0f 84 cb 00 00 00    	je     801041ef <pipealloc+0x104>
80104124:	e8 14 cf ff ff       	call   8010103d <filealloc>
80104129:	89 c2                	mov    %eax,%edx
8010412b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412e:	89 10                	mov    %edx,(%eax)
80104130:	8b 45 0c             	mov    0xc(%ebp),%eax
80104133:	8b 00                	mov    (%eax),%eax
80104135:	85 c0                	test   %eax,%eax
80104137:	0f 84 b2 00 00 00    	je     801041ef <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010413d:	e8 ce eb ff ff       	call   80102d10 <kalloc>
80104142:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104149:	0f 84 9f 00 00 00    	je     801041ee <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010414f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104152:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104159:	00 00 00 
  p->writeopen = 1;
8010415c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415f:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104166:	00 00 00 
  p->nwrite = 0;
80104169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104173:	00 00 00 
  p->nread = 0;
80104176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104179:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104180:	00 00 00 
  initlock(&p->lock, "pipe");
80104183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104186:	83 ec 08             	sub    $0x8,%esp
80104189:	68 14 98 10 80       	push   $0x80109814
8010418e:	50                   	push   %eax
8010418f:	e8 7c 1c 00 00       	call   80105e10 <initlock>
80104194:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104197:	8b 45 08             	mov    0x8(%ebp),%eax
8010419a:	8b 00                	mov    (%eax),%eax
8010419c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041a2:	8b 45 08             	mov    0x8(%ebp),%eax
801041a5:	8b 00                	mov    (%eax),%eax
801041a7:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041ab:	8b 45 08             	mov    0x8(%ebp),%eax
801041ae:	8b 00                	mov    (%eax),%eax
801041b0:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041b4:	8b 45 08             	mov    0x8(%ebp),%eax
801041b7:	8b 00                	mov    (%eax),%eax
801041b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041bc:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c2:	8b 00                	mov    (%eax),%eax
801041c4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801041cd:	8b 00                	mov    (%eax),%eax
801041cf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d6:	8b 00                	mov    (%eax),%eax
801041d8:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801041df:	8b 00                	mov    (%eax),%eax
801041e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e4:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041e7:	b8 00 00 00 00       	mov    $0x0,%eax
801041ec:	eb 4e                	jmp    8010423c <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801041ee:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801041ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041f3:	74 0e                	je     80104203 <pipealloc+0x118>
    kfree((char*)p);
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	ff 75 f4             	pushl  -0xc(%ebp)
801041fb:	e8 73 ea ff ff       	call   80102c73 <kfree>
80104200:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104203:	8b 45 08             	mov    0x8(%ebp),%eax
80104206:	8b 00                	mov    (%eax),%eax
80104208:	85 c0                	test   %eax,%eax
8010420a:	74 11                	je     8010421d <pipealloc+0x132>
    fileclose(*f0);
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	8b 00                	mov    (%eax),%eax
80104211:	83 ec 0c             	sub    $0xc,%esp
80104214:	50                   	push   %eax
80104215:	e8 e1 ce ff ff       	call   801010fb <fileclose>
8010421a:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010421d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104220:	8b 00                	mov    (%eax),%eax
80104222:	85 c0                	test   %eax,%eax
80104224:	74 11                	je     80104237 <pipealloc+0x14c>
    fileclose(*f1);
80104226:	8b 45 0c             	mov    0xc(%ebp),%eax
80104229:	8b 00                	mov    (%eax),%eax
8010422b:	83 ec 0c             	sub    $0xc,%esp
8010422e:	50                   	push   %eax
8010422f:	e8 c7 ce ff ff       	call   801010fb <fileclose>
80104234:	83 c4 10             	add    $0x10,%esp
  return -1;
80104237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010423c:	c9                   	leave  
8010423d:	c3                   	ret    

8010423e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010423e:	55                   	push   %ebp
8010423f:	89 e5                	mov    %esp,%ebp
80104241:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	83 ec 0c             	sub    $0xc,%esp
8010424a:	50                   	push   %eax
8010424b:	e8 e2 1b 00 00       	call   80105e32 <acquire>
80104250:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104253:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104257:	74 23                	je     8010427c <pipeclose+0x3e>
    p->writeopen = 0;
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104263:	00 00 00 
    wakeup(&p->nread);
80104266:	8b 45 08             	mov    0x8(%ebp),%eax
80104269:	05 34 02 00 00       	add    $0x234,%eax
8010426e:	83 ec 0c             	sub    $0xc,%esp
80104271:	50                   	push   %eax
80104272:	e8 07 13 00 00       	call   8010557e <wakeup>
80104277:	83 c4 10             	add    $0x10,%esp
8010427a:	eb 21                	jmp    8010429d <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104286:	00 00 00 
    wakeup(&p->nwrite);
80104289:	8b 45 08             	mov    0x8(%ebp),%eax
8010428c:	05 38 02 00 00       	add    $0x238,%eax
80104291:	83 ec 0c             	sub    $0xc,%esp
80104294:	50                   	push   %eax
80104295:	e8 e4 12 00 00       	call   8010557e <wakeup>
8010429a:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010429d:	8b 45 08             	mov    0x8(%ebp),%eax
801042a0:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042a6:	85 c0                	test   %eax,%eax
801042a8:	75 2c                	jne    801042d6 <pipeclose+0x98>
801042aa:	8b 45 08             	mov    0x8(%ebp),%eax
801042ad:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042b3:	85 c0                	test   %eax,%eax
801042b5:	75 1f                	jne    801042d6 <pipeclose+0x98>
    release(&p->lock);
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	83 ec 0c             	sub    $0xc,%esp
801042bd:	50                   	push   %eax
801042be:	e8 d6 1b 00 00       	call   80105e99 <release>
801042c3:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801042c6:	83 ec 0c             	sub    $0xc,%esp
801042c9:	ff 75 08             	pushl  0x8(%ebp)
801042cc:	e8 a2 e9 ff ff       	call   80102c73 <kfree>
801042d1:	83 c4 10             	add    $0x10,%esp
801042d4:	eb 0f                	jmp    801042e5 <pipeclose+0xa7>
  } else
    release(&p->lock);
801042d6:	8b 45 08             	mov    0x8(%ebp),%eax
801042d9:	83 ec 0c             	sub    $0xc,%esp
801042dc:	50                   	push   %eax
801042dd:	e8 b7 1b 00 00       	call   80105e99 <release>
801042e2:	83 c4 10             	add    $0x10,%esp
}
801042e5:	90                   	nop
801042e6:	c9                   	leave  
801042e7:	c3                   	ret    

801042e8 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042e8:	55                   	push   %ebp
801042e9:	89 e5                	mov    %esp,%ebp
801042eb:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042ee:	8b 45 08             	mov    0x8(%ebp),%eax
801042f1:	83 ec 0c             	sub    $0xc,%esp
801042f4:	50                   	push   %eax
801042f5:	e8 38 1b 00 00       	call   80105e32 <acquire>
801042fa:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801042fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104304:	e9 ad 00 00 00       	jmp    801043b6 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104309:	8b 45 08             	mov    0x8(%ebp),%eax
8010430c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104312:	85 c0                	test   %eax,%eax
80104314:	74 0d                	je     80104323 <pipewrite+0x3b>
80104316:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010431c:	8b 40 24             	mov    0x24(%eax),%eax
8010431f:	85 c0                	test   %eax,%eax
80104321:	74 19                	je     8010433c <pipewrite+0x54>
        release(&p->lock);
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	83 ec 0c             	sub    $0xc,%esp
80104329:	50                   	push   %eax
8010432a:	e8 6a 1b 00 00       	call   80105e99 <release>
8010432f:	83 c4 10             	add    $0x10,%esp
        return -1;
80104332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104337:	e9 a8 00 00 00       	jmp    801043e4 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010433c:	8b 45 08             	mov    0x8(%ebp),%eax
8010433f:	05 34 02 00 00       	add    $0x234,%eax
80104344:	83 ec 0c             	sub    $0xc,%esp
80104347:	50                   	push   %eax
80104348:	e8 31 12 00 00       	call   8010557e <wakeup>
8010434d:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104350:	8b 45 08             	mov    0x8(%ebp),%eax
80104353:	8b 55 08             	mov    0x8(%ebp),%edx
80104356:	81 c2 38 02 00 00    	add    $0x238,%edx
8010435c:	83 ec 08             	sub    $0x8,%esp
8010435f:	50                   	push   %eax
80104360:	52                   	push   %edx
80104361:	e8 9d 10 00 00       	call   80105403 <sleep>
80104366:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104369:	8b 45 08             	mov    0x8(%ebp),%eax
8010436c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104372:	8b 45 08             	mov    0x8(%ebp),%eax
80104375:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010437b:	05 00 02 00 00       	add    $0x200,%eax
80104380:	39 c2                	cmp    %eax,%edx
80104382:	74 85                	je     80104309 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104384:	8b 45 08             	mov    0x8(%ebp),%eax
80104387:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010438d:	8d 48 01             	lea    0x1(%eax),%ecx
80104390:	8b 55 08             	mov    0x8(%ebp),%edx
80104393:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104399:	25 ff 01 00 00       	and    $0x1ff,%eax
8010439e:	89 c1                	mov    %eax,%ecx
801043a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a6:	01 d0                	add    %edx,%eax
801043a8:	0f b6 10             	movzbl (%eax),%edx
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801043bc:	7c ab                	jl     80104369 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043be:	8b 45 08             	mov    0x8(%ebp),%eax
801043c1:	05 34 02 00 00       	add    $0x234,%eax
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	50                   	push   %eax
801043ca:	e8 af 11 00 00       	call   8010557e <wakeup>
801043cf:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043d2:	8b 45 08             	mov    0x8(%ebp),%eax
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	50                   	push   %eax
801043d9:	e8 bb 1a 00 00       	call   80105e99 <release>
801043de:	83 c4 10             	add    $0x10,%esp
  return n;
801043e1:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043e4:	c9                   	leave  
801043e5:	c3                   	ret    

801043e6 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043e6:	55                   	push   %ebp
801043e7:	89 e5                	mov    %esp,%ebp
801043e9:	53                   	push   %ebx
801043ea:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801043ed:	8b 45 08             	mov    0x8(%ebp),%eax
801043f0:	83 ec 0c             	sub    $0xc,%esp
801043f3:	50                   	push   %eax
801043f4:	e8 39 1a 00 00       	call   80105e32 <acquire>
801043f9:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043fc:	eb 3f                	jmp    8010443d <piperead+0x57>
    if(proc->killed){
801043fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104404:	8b 40 24             	mov    0x24(%eax),%eax
80104407:	85 c0                	test   %eax,%eax
80104409:	74 19                	je     80104424 <piperead+0x3e>
      release(&p->lock);
8010440b:	8b 45 08             	mov    0x8(%ebp),%eax
8010440e:	83 ec 0c             	sub    $0xc,%esp
80104411:	50                   	push   %eax
80104412:	e8 82 1a 00 00       	call   80105e99 <release>
80104417:	83 c4 10             	add    $0x10,%esp
      return -1;
8010441a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010441f:	e9 bf 00 00 00       	jmp    801044e3 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104424:	8b 45 08             	mov    0x8(%ebp),%eax
80104427:	8b 55 08             	mov    0x8(%ebp),%edx
8010442a:	81 c2 34 02 00 00    	add    $0x234,%edx
80104430:	83 ec 08             	sub    $0x8,%esp
80104433:	50                   	push   %eax
80104434:	52                   	push   %edx
80104435:	e8 c9 0f 00 00       	call   80105403 <sleep>
8010443a:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010443d:	8b 45 08             	mov    0x8(%ebp),%eax
80104440:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104446:	8b 45 08             	mov    0x8(%ebp),%eax
80104449:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010444f:	39 c2                	cmp    %eax,%edx
80104451:	75 0d                	jne    80104460 <piperead+0x7a>
80104453:	8b 45 08             	mov    0x8(%ebp),%eax
80104456:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010445c:	85 c0                	test   %eax,%eax
8010445e:	75 9e                	jne    801043fe <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104460:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104467:	eb 49                	jmp    801044b2 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104469:	8b 45 08             	mov    0x8(%ebp),%eax
8010446c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104472:	8b 45 08             	mov    0x8(%ebp),%eax
80104475:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010447b:	39 c2                	cmp    %eax,%edx
8010447d:	74 3d                	je     801044bc <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010447f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104482:	8b 45 0c             	mov    0xc(%ebp),%eax
80104485:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104488:	8b 45 08             	mov    0x8(%ebp),%eax
8010448b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104491:	8d 48 01             	lea    0x1(%eax),%ecx
80104494:	8b 55 08             	mov    0x8(%ebp),%edx
80104497:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010449d:	25 ff 01 00 00       	and    $0x1ff,%eax
801044a2:	89 c2                	mov    %eax,%edx
801044a4:	8b 45 08             	mov    0x8(%ebp),%eax
801044a7:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801044ac:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801044b8:	7c af                	jl     80104469 <piperead+0x83>
801044ba:	eb 01                	jmp    801044bd <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801044bc:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044bd:	8b 45 08             	mov    0x8(%ebp),%eax
801044c0:	05 38 02 00 00       	add    $0x238,%eax
801044c5:	83 ec 0c             	sub    $0xc,%esp
801044c8:	50                   	push   %eax
801044c9:	e8 b0 10 00 00       	call   8010557e <wakeup>
801044ce:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044d1:	8b 45 08             	mov    0x8(%ebp),%eax
801044d4:	83 ec 0c             	sub    $0xc,%esp
801044d7:	50                   	push   %eax
801044d8:	e8 bc 19 00 00       	call   80105e99 <release>
801044dd:	83 c4 10             	add    $0x10,%esp
  return i;
801044e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044e6:	c9                   	leave  
801044e7:	c3                   	ret    

801044e8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044e8:	55                   	push   %ebp
801044e9:	89 e5                	mov    %esp,%ebp
801044eb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044ee:	9c                   	pushf  
801044ef:	58                   	pop    %eax
801044f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044f6:	c9                   	leave  
801044f7:	c3                   	ret    

801044f8 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044f8:	55                   	push   %ebp
801044f9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044fb:	fb                   	sti    
}
801044fc:	90                   	nop
801044fd:	5d                   	pop    %ebp
801044fe:	c3                   	ret    

801044ff <assertStateFree>:

static struct proc*
removeFromStateListHead(struct proc** sList);

static void
assertStateFree(struct proc* p){
801044ff:	55                   	push   %ebp
80104500:	89 e5                	mov    %esp,%ebp
80104502:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != UNUSED)
80104505:	8b 45 08             	mov    0x8(%ebp),%eax
80104508:	8b 40 0c             	mov    0xc(%eax),%eax
8010450b:	85 c0                	test   %eax,%eax
8010450d:	74 0d                	je     8010451c <assertStateFree+0x1d>
	panic("Process not in an UNUSED state");
8010450f:	83 ec 0c             	sub    $0xc,%esp
80104512:	68 1c 98 10 80       	push   $0x8010981c
80104517:	e8 4a c0 ff ff       	call   80100566 <panic>
}
8010451c:	90                   	nop
8010451d:	c9                   	leave  
8010451e:	c3                   	ret    

8010451f <assertStateZombie>:
static void
assertStateZombie(struct proc* p){
8010451f:	55                   	push   %ebp
80104520:	89 e5                	mov    %esp,%ebp
80104522:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != ZOMBIE)
80104525:	8b 45 08             	mov    0x8(%ebp),%eax
80104528:	8b 40 0c             	mov    0xc(%eax),%eax
8010452b:	83 f8 05             	cmp    $0x5,%eax
8010452e:	74 0d                	je     8010453d <assertStateZombie+0x1e>
	panic("Process not in a ZOMBIE state");
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 3b 98 10 80       	push   $0x8010983b
80104538:	e8 29 c0 ff ff       	call   80100566 <panic>
}
8010453d:	90                   	nop
8010453e:	c9                   	leave  
8010453f:	c3                   	ret    

80104540 <assertStateEmbryo>:
static void
assertStateEmbryo(struct proc* p){
80104540:	55                   	push   %ebp
80104541:	89 e5                	mov    %esp,%ebp
80104543:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != EMBRYO)
80104546:	8b 45 08             	mov    0x8(%ebp),%eax
80104549:	8b 40 0c             	mov    0xc(%eax),%eax
8010454c:	83 f8 01             	cmp    $0x1,%eax
8010454f:	74 0d                	je     8010455e <assertStateEmbryo+0x1e>
	panic("Process not in a EMBRYO state");
80104551:	83 ec 0c             	sub    $0xc,%esp
80104554:	68 59 98 10 80       	push   $0x80109859
80104559:	e8 08 c0 ff ff       	call   80100566 <panic>
}
8010455e:	90                   	nop
8010455f:	c9                   	leave  
80104560:	c3                   	ret    

80104561 <assertStateRunning>:
static void
assertStateRunning(struct proc* p){
80104561:	55                   	push   %ebp
80104562:	89 e5                	mov    %esp,%ebp
80104564:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != RUNNING)
80104567:	8b 45 08             	mov    0x8(%ebp),%eax
8010456a:	8b 40 0c             	mov    0xc(%eax),%eax
8010456d:	83 f8 04             	cmp    $0x4,%eax
80104570:	74 0d                	je     8010457f <assertStateRunning+0x1e>
	panic("Process not in a RUNNING state");
80104572:	83 ec 0c             	sub    $0xc,%esp
80104575:	68 78 98 10 80       	push   $0x80109878
8010457a:	e8 e7 bf ff ff       	call   80100566 <panic>
}
8010457f:	90                   	nop
80104580:	c9                   	leave  
80104581:	c3                   	ret    

80104582 <assertStateSleep>:
static void
assertStateSleep(struct proc* p){
80104582:	55                   	push   %ebp
80104583:	89 e5                	mov    %esp,%ebp
80104585:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != SLEEPING)
80104588:	8b 45 08             	mov    0x8(%ebp),%eax
8010458b:	8b 40 0c             	mov    0xc(%eax),%eax
8010458e:	83 f8 02             	cmp    $0x2,%eax
80104591:	74 0d                	je     801045a0 <assertStateSleep+0x1e>
	panic("Process not in a SLEEPING state");
80104593:	83 ec 0c             	sub    $0xc,%esp
80104596:	68 98 98 10 80       	push   $0x80109898
8010459b:	e8 c6 bf ff ff       	call   80100566 <panic>
}
801045a0:	90                   	nop
801045a1:	c9                   	leave  
801045a2:	c3                   	ret    

801045a3 <assertStateReady>:
static void
assertStateReady(struct proc* p){
801045a3:	55                   	push   %ebp
801045a4:	89 e5                	mov    %esp,%ebp
801045a6:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != RUNNABLE)
801045a9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ac:	8b 40 0c             	mov    0xc(%eax),%eax
801045af:	83 f8 03             	cmp    $0x3,%eax
801045b2:	74 0d                	je     801045c1 <assertStateReady+0x1e>
	panic("Process not in a RUNNABLE state");
801045b4:	83 ec 0c             	sub    $0xc,%esp
801045b7:	68 b8 98 10 80       	push   $0x801098b8
801045bc:	e8 a5 bf ff ff       	call   80100566 <panic>
}
801045c1:	90                   	nop
801045c2:	c9                   	leave  
801045c3:	c3                   	ret    

801045c4 <addToStateListEnd>:


static int
addToStateListEnd(struct proc** sList, struct proc* p){
801045c4:	55                   	push   %ebp
801045c5:	89 e5                	mov    %esp,%ebp
801045c7:	83 ec 10             	sub    $0x10,%esp

    struct proc *current = *sList;
801045ca:	8b 45 08             	mov    0x8(%ebp),%eax
801045cd:	8b 00                	mov    (%eax),%eax
801045cf:	89 45 fc             	mov    %eax,-0x4(%ebp)

    if(!current){
801045d2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801045d6:	75 26                	jne    801045fe <addToStateListEnd+0x3a>
	current = p;
801045d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801045db:	89 45 fc             	mov    %eax,-0x4(%ebp)
	p -> next = 0;
801045de:	8b 45 0c             	mov    0xc(%ebp),%eax
801045e1:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801045e8:	00 00 00 
	return 0;
801045eb:	b8 00 00 00 00       	mov    $0x0,%eax
801045f0:	eb 37                	jmp    80104629 <addToStateListEnd+0x65>
    }

    while(current -> next)
	current = current -> next;
801045f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045f5:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801045fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	current = p;
	p -> next = 0;
	return 0;
    }

    while(current -> next)
801045fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104601:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104607:	85 c0                	test   %eax,%eax
80104609:	75 e7                	jne    801045f2 <addToStateListEnd+0x2e>
	current = current -> next;
    
    current -> next = p;
8010460b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010460e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104611:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)

    p -> next = 0;
80104617:	8b 45 0c             	mov    0xc(%ebp),%eax
8010461a:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104621:	00 00 00 

    return 0;
80104624:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104629:	c9                   	leave  
8010462a:	c3                   	ret    

8010462b <addToStateListHead>:

static int
addToStateListHead(struct proc** sList, struct proc* p){
8010462b:	55                   	push   %ebp
8010462c:	89 e5                	mov    %esp,%ebp
8010462e:	83 ec 10             	sub    $0x10,%esp

    struct proc *temp = *sList;
80104631:	8b 45 08             	mov    0x8(%ebp),%eax
80104634:	8b 00                	mov    (%eax),%eax
80104636:	89 45 fc             	mov    %eax,-0x4(%ebp)
    p -> next = temp;
80104639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010463c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010463f:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *sList = p;
80104645:	8b 45 08             	mov    0x8(%ebp),%eax
80104648:	8b 55 0c             	mov    0xc(%ebp),%edx
8010464b:	89 10                	mov    %edx,(%eax)

    return 0;
8010464d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104652:	c9                   	leave  
80104653:	c3                   	ret    

80104654 <removeFromStateListHead>:
static struct proc*
removeFromStateListHead(struct proc** sList){
80104654:	55                   	push   %ebp
80104655:	89 e5                	mov    %esp,%ebp
80104657:	83 ec 18             	sub    $0x18,%esp
    if(!sList){
8010465a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010465e:	75 17                	jne    80104677 <removeFromStateListHead+0x23>
	cprintf("No processes in the ready list?");
80104660:	83 ec 0c             	sub    $0xc,%esp
80104663:	68 d8 98 10 80       	push   $0x801098d8
80104668:	e8 59 bd ff ff       	call   801003c6 <cprintf>
8010466d:	83 c4 10             	add    $0x10,%esp
	return 0;
80104670:	b8 00 00 00 00       	mov    $0x0,%eax
80104675:	eb 51                	jmp    801046c8 <removeFromStateListHead+0x74>
    }
    cprintf("process = sList");
80104677:	83 ec 0c             	sub    $0xc,%esp
8010467a:	68 f8 98 10 80       	push   $0x801098f8
8010467f:	e8 42 bd ff ff       	call   801003c6 <cprintf>
80104684:	83 c4 10             	add    $0x10,%esp
    struct proc * process = *sList;
80104687:	8b 45 08             	mov    0x8(%ebp),%eax
8010468a:	8b 00                	mov    (%eax),%eax
8010468c:	89 45 f4             	mov    %eax,-0xc(%ebp)

    cprintf("temp = sList");
8010468f:	83 ec 0c             	sub    $0xc,%esp
80104692:	68 08 99 10 80       	push   $0x80109908
80104697:	e8 2a bd ff ff       	call   801003c6 <cprintf>
8010469c:	83 c4 10             	add    $0x10,%esp
    struct proc * temp = *sList;
8010469f:	8b 45 08             	mov    0x8(%ebp),%eax
801046a2:	8b 00                	mov    (%eax),%eax
801046a4:	89 45 f0             	mov    %eax,-0x10(%ebp)

    cprintf("sList = temp next");
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	68 15 99 10 80       	push   $0x80109915
801046af:	e8 12 bd ff ff       	call   801003c6 <cprintf>
801046b4:	83 c4 10             	add    $0x10,%esp
    *sList = temp -> next;
801046b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ba:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801046c0:	8b 45 08             	mov    0x8(%ebp),%eax
801046c3:	89 10                	mov    %edx,(%eax)

	return process;
801046c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046c8:	c9                   	leave  
801046c9:	c3                   	ret    

801046ca <removeFromStateList>:

static int
removeFromStateList(struct proc** sList, struct proc* p){
801046ca:	55                   	push   %ebp
801046cb:	89 e5                	mov    %esp,%ebp
801046cd:	83 ec 10             	sub    $0x10,%esp
    if(!sList)
801046d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046d4:	75 07                	jne    801046dd <removeFromStateList+0x13>
	return -1;
801046d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046db:	eb 66                	jmp    80104743 <removeFromStateList+0x79>

    struct proc *current = *sList;
801046dd:	8b 45 08             	mov    0x8(%ebp),%eax
801046e0:	8b 00                	mov    (%eax),%eax
801046e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    struct proc *previous = *sList;
801046e5:	8b 45 08             	mov    0x8(%ebp),%eax
801046e8:	8b 00                	mov    (%eax),%eax
801046ea:	89 45 f8             	mov    %eax,-0x8(%ebp)

    while(current){
801046ed:	eb 1a                	jmp    80104709 <removeFromStateList+0x3f>
	if(p == current)
801046ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801046f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
801046f5:	74 1a                	je     80104711 <removeFromStateList+0x47>
	    break;
	previous = current;
801046f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801046fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
	current = current -> next;
801046fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104700:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104706:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return -1;

    struct proc *current = *sList;
    struct proc *previous = *sList;

    while(current){
80104709:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010470d:	75 e0                	jne    801046ef <removeFromStateList+0x25>
8010470f:	eb 01                	jmp    80104712 <removeFromStateList+0x48>
	if(p == current)
	    break;
80104711:	90                   	nop
	previous = current;
	current = current -> next;
    }
    if(!current)
80104712:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104716:	75 07                	jne    8010471f <removeFromStateList+0x55>
	return -1;
80104718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471d:	eb 24                	jmp    80104743 <removeFromStateList+0x79>

    previous -> next = current -> next;
8010471f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104722:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104728:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010472b:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    p -> next = 0;
80104731:	8b 45 0c             	mov    0xc(%ebp),%eax
80104734:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010473b:	00 00 00 

    return 0;
8010473e:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104743:	c9                   	leave  
80104744:	c3                   	ret    

80104745 <pinit>:

#endif

void
pinit(void)
{
80104745:	55                   	push   %ebp
80104746:	89 e5                	mov    %esp,%ebp
80104748:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010474b:	83 ec 08             	sub    $0x8,%esp
8010474e:	68 27 99 10 80       	push   $0x80109927
80104753:	68 80 39 11 80       	push   $0x80113980
80104758:	e8 b3 16 00 00       	call   80105e10 <initlock>
8010475d:	83 c4 10             	add    $0x10,%esp
}
80104760:	90                   	nop
80104761:	c9                   	leave  
80104762:	c3                   	ret    

80104763 <allocproc>:
//test
//test2

static struct proc*
allocproc(void)
{
80104763:	55                   	push   %ebp
80104764:	89 e5                	mov    %esp,%ebp
80104766:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104769:	83 ec 0c             	sub    $0xc,%esp
8010476c:	68 80 39 11 80       	push   $0x80113980
80104771:	e8 bc 16 00 00       	call   80105e32 <acquire>
80104776:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104779:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104780:	eb 11                	jmp    80104793 <allocproc+0x30>
    if(p->state == UNUSED)
80104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104785:	8b 40 0c             	mov    0xc(%eax),%eax
80104788:	85 c0                	test   %eax,%eax
8010478a:	74 2a                	je     801047b6 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010478c:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104793:	81 7d f4 54 63 11 80 	cmpl   $0x80116354,-0xc(%ebp)
8010479a:	72 e6                	jb     80104782 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010479c:	83 ec 0c             	sub    $0xc,%esp
8010479f:	68 80 39 11 80       	push   $0x80113980
801047a4:	e8 f0 16 00 00       	call   80105e99 <release>
801047a9:	83 c4 10             	add    $0x10,%esp
  return 0;
801047ac:	b8 00 00 00 00       	mov    $0x0,%eax
801047b1:	e9 87 01 00 00       	jmp    8010493d <allocproc+0x1da>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801047b6:	90                   	nop
  return 0;

found:
#ifdef CS333_P3P4

  assertStateFree(p);
801047b7:	83 ec 0c             	sub    $0xc,%esp
801047ba:	ff 75 f4             	pushl  -0xc(%ebp)
801047bd:	e8 3d fd ff ff       	call   801044ff <assertStateFree>
801047c2:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.free, p);
801047c5:	83 ec 08             	sub    $0x8,%esp
801047c8:	ff 75 f4             	pushl  -0xc(%ebp)
801047cb:	68 58 63 11 80       	push   $0x80116358
801047d0:	e8 f5 fe ff ff       	call   801046ca <removeFromStateList>
801047d5:	83 c4 10             	add    $0x10,%esp

  p->state = EMBRYO;
801047d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047db:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  addToStateListEnd(&ptable.pLists.embryo, p);
801047e2:	83 ec 08             	sub    $0x8,%esp
801047e5:	ff 75 f4             	pushl  -0xc(%ebp)
801047e8:	68 68 63 11 80       	push   $0x80116368
801047ed:	e8 d2 fd ff ff       	call   801045c4 <addToStateListEnd>
801047f2:	83 c4 10             	add    $0x10,%esp
  cprintf("185\n");
801047f5:	83 ec 0c             	sub    $0xc,%esp
801047f8:	68 2e 99 10 80       	push   $0x8010992e
801047fd:	e8 c4 bb ff ff       	call   801003c6 <cprintf>
80104802:	83 c4 10             	add    $0x10,%esp

#endif 

  p->pid = nextpid++;
80104805:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010480a:	8d 50 01             	lea    0x1(%eax),%edx
8010480d:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104813:	89 c2                	mov    %eax,%edx
80104815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104818:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
8010481b:	83 ec 0c             	sub    $0xc,%esp
8010481e:	68 80 39 11 80       	push   $0x80113980
80104823:	e8 71 16 00 00       	call   80105e99 <release>
80104828:	83 c4 10             	add    $0x10,%esp
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010482b:	e8 e0 e4 ff ff       	call   80102d10 <kalloc>
80104830:	89 c2                	mov    %eax,%edx
80104832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104835:	89 50 08             	mov    %edx,0x8(%eax)
80104838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483b:	8b 40 08             	mov    0x8(%eax),%eax
8010483e:	85 c0                	test   %eax,%eax
80104840:	75 78                	jne    801048ba <allocproc+0x157>

#ifdef CS333_P3P4

  acquire(&ptable.lock);
80104842:	83 ec 0c             	sub    $0xc,%esp
80104845:	68 80 39 11 80       	push   $0x80113980
8010484a:	e8 e3 15 00 00       	call   80105e32 <acquire>
8010484f:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104852:	83 ec 0c             	sub    $0xc,%esp
80104855:	ff 75 f4             	pushl  -0xc(%ebp)
80104858:	e8 e3 fc ff ff       	call   80104540 <assertStateEmbryo>
8010485d:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.embryo, p);
80104860:	83 ec 08             	sub    $0x8,%esp
80104863:	ff 75 f4             	pushl  -0xc(%ebp)
80104866:	68 68 63 11 80       	push   $0x80116368
8010486b:	e8 5a fe ff ff       	call   801046ca <removeFromStateList>
80104870:	83 c4 10             	add    $0x10,%esp

    p->state = UNUSED;
80104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104876:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  addToStateListHead(&ptable.pLists.free, p);
8010487d:	83 ec 08             	sub    $0x8,%esp
80104880:	ff 75 f4             	pushl  -0xc(%ebp)
80104883:	68 58 63 11 80       	push   $0x80116358
80104888:	e8 9e fd ff ff       	call   8010462b <addToStateListHead>
8010488d:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104890:	83 ec 0c             	sub    $0xc,%esp
80104893:	68 80 39 11 80       	push   $0x80113980
80104898:	e8 fc 15 00 00       	call   80105e99 <release>
8010489d:	83 c4 10             	add    $0x10,%esp

  cprintf("207\n");
801048a0:	83 ec 0c             	sub    $0xc,%esp
801048a3:	68 33 99 10 80       	push   $0x80109933
801048a8:	e8 19 bb ff ff       	call   801003c6 <cprintf>
801048ad:	83 c4 10             	add    $0x10,%esp
#endif


    return 0;
801048b0:	b8 00 00 00 00       	mov    $0x0,%eax
801048b5:	e9 83 00 00 00       	jmp    8010493d <allocproc+0x1da>
  }
  sp = p->kstack + KSTACKSIZE;
801048ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bd:	8b 40 08             	mov    0x8(%eax),%eax
801048c0:	05 00 10 00 00       	add    $0x1000,%eax
801048c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801048c8:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801048cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048d2:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801048d5:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801048d9:	ba ec 75 10 80       	mov    $0x801075ec,%edx
801048de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e1:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801048e3:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801048e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048ed:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f3:	8b 40 1c             	mov    0x1c(%eax),%eax
801048f6:	83 ec 04             	sub    $0x4,%esp
801048f9:	6a 14                	push   $0x14
801048fb:	6a 00                	push   $0x0
801048fd:	50                   	push   %eax
801048fe:	e8 92 17 00 00       	call   80106095 <memset>
80104903:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	8b 40 1c             	mov    0x1c(%eax),%eax
8010490c:	ba bd 53 10 80       	mov    $0x801053bd,%edx
80104911:	89 50 10             	mov    %edx,0x10(%eax)
  #ifdef CS333_P1
  p->start_ticks = ticks;
80104914:	8b 15 80 6b 11 80    	mov    0x80116b80,%edx
8010491a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491d:	89 50 7c             	mov    %edx,0x7c(%eax)
  #endif
  #ifdef CS333_P2
  p -> cpu_ticks_total = 0;
80104920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104923:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
8010492a:	00 00 00 
  p -> cpu_ticks_in = 0;
8010492d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104930:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80104937:	00 00 00 
  #endif
  return p;
8010493a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010493d:	c9                   	leave  
8010493e:	c3                   	ret    

8010493f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010493f:	55                   	push   %ebp
80104940:	89 e5                	mov    %esp,%ebp
80104942:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  #ifdef CS333_P3P4
  
  ptable.pLists.ready = 0;
80104945:	c7 05 54 63 11 80 00 	movl   $0x0,0x80116354
8010494c:	00 00 00 
  ptable.pLists.free = 0;
8010494f:	c7 05 58 63 11 80 00 	movl   $0x0,0x80116358
80104956:	00 00 00 
  ptable.pLists.sleep = 0;
80104959:	c7 05 5c 63 11 80 00 	movl   $0x0,0x8011635c
80104960:	00 00 00 
  ptable.pLists.zombie = 0;
80104963:	c7 05 60 63 11 80 00 	movl   $0x0,0x80116360
8010496a:	00 00 00 
  ptable.pLists.running = 0;
8010496d:	c7 05 64 63 11 80 00 	movl   $0x0,0x80116364
80104974:	00 00 00 
  ptable.pLists.embryo = 0;
80104977:	c7 05 68 63 11 80 00 	movl   $0x0,0x80116368
8010497e:	00 00 00 

  acquire(&ptable.lock);
80104981:	83 ec 0c             	sub    $0xc,%esp
80104984:	68 80 39 11 80       	push   $0x80113980
80104989:	e8 a4 14 00 00       	call   80105e32 <acquire>
8010498e:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < NPROC; i++){
80104991:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104998:	eb 29                	jmp    801049c3 <userinit+0x84>
    addToStateListHead(&ptable.pLists.free, &ptable.proc[i]);
8010499a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499d:	69 c0 94 00 00 00    	imul   $0x94,%eax,%eax
801049a3:	83 c0 30             	add    $0x30,%eax
801049a6:	05 80 39 11 80       	add    $0x80113980,%eax
801049ab:	83 c0 04             	add    $0x4,%eax
801049ae:	83 ec 08             	sub    $0x8,%esp
801049b1:	50                   	push   %eax
801049b2:	68 58 63 11 80       	push   $0x80116358
801049b7:	e8 6f fc ff ff       	call   8010462b <addToStateListHead>
801049bc:	83 c4 10             	add    $0x10,%esp
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  acquire(&ptable.lock);
  for(int i = 0; i < NPROC; i++){
801049bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049c3:	83 7d f4 47          	cmpl   $0x47,-0xc(%ebp)
801049c7:	7e d1                	jle    8010499a <userinit+0x5b>
    addToStateListHead(&ptable.pLists.free, &ptable.proc[i]);
  }
  release(&ptable.lock);
801049c9:	83 ec 0c             	sub    $0xc,%esp
801049cc:	68 80 39 11 80       	push   $0x80113980
801049d1:	e8 c3 14 00 00       	call   80105e99 <release>
801049d6:	83 c4 10             	add    $0x10,%esp

  #endif

  p = allocproc();
801049d9:	e8 85 fd ff ff       	call   80104763 <allocproc>
801049de:	89 45 f0             	mov    %eax,-0x10(%ebp)

  initproc = p;
801049e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e4:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801049e9:	e8 c0 42 00 00       	call   80108cae <setupkvm>
801049ee:	89 c2                	mov    %eax,%edx
801049f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049f3:	89 50 04             	mov    %edx,0x4(%eax)
801049f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049f9:	8b 40 04             	mov    0x4(%eax),%eax
801049fc:	85 c0                	test   %eax,%eax
801049fe:	75 0d                	jne    80104a0d <userinit+0xce>
    panic("userinit: out of memory?");
80104a00:	83 ec 0c             	sub    $0xc,%esp
80104a03:	68 38 99 10 80       	push   $0x80109938
80104a08:	e8 59 bb ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104a0d:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a15:	8b 40 04             	mov    0x4(%eax),%eax
80104a18:	83 ec 04             	sub    $0x4,%esp
80104a1b:	52                   	push   %edx
80104a1c:	68 00 c5 10 80       	push   $0x8010c500
80104a21:	50                   	push   %eax
80104a22:	e8 e1 44 00 00       	call   80108f08 <inituvm>
80104a27:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a2d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a36:	8b 40 18             	mov    0x18(%eax),%eax
80104a39:	83 ec 04             	sub    $0x4,%esp
80104a3c:	6a 4c                	push   $0x4c
80104a3e:	6a 00                	push   $0x0
80104a40:	50                   	push   %eax
80104a41:	e8 4f 16 00 00       	call   80106095 <memset>
80104a46:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a4c:	8b 40 18             	mov    0x18(%eax),%eax
80104a4f:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a58:	8b 40 18             	mov    0x18(%eax),%eax
80104a5b:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a64:	8b 40 18             	mov    0x18(%eax),%eax
80104a67:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a6a:	8b 52 18             	mov    0x18(%edx),%edx
80104a6d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104a71:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a78:	8b 40 18             	mov    0x18(%eax),%eax
80104a7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a7e:	8b 52 18             	mov    0x18(%edx),%edx
80104a81:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104a85:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a8c:	8b 40 18             	mov    0x18(%eax),%eax
80104a8f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a99:	8b 40 18             	mov    0x18(%eax),%eax
80104a9c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aa6:	8b 40 18             	mov    0x18(%eax),%eax
80104aa9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab3:	83 c0 6c             	add    $0x6c,%eax
80104ab6:	83 ec 04             	sub    $0x4,%esp
80104ab9:	6a 10                	push   $0x10
80104abb:	68 51 99 10 80       	push   $0x80109951
80104ac0:	50                   	push   %eax
80104ac1:	e8 d2 17 00 00       	call   80106298 <safestrcpy>
80104ac6:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104ac9:	83 ec 0c             	sub    $0xc,%esp
80104acc:	68 5a 99 10 80       	push   $0x8010995a
80104ad1:	e8 fc da ff ff       	call   801025d2 <namei>
80104ad6:	83 c4 10             	add    $0x10,%esp
80104ad9:	89 c2                	mov    %eax,%edx
80104adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ade:	89 50 68             	mov    %edx,0x68(%eax)

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104ae1:	83 ec 0c             	sub    $0xc,%esp
80104ae4:	68 80 39 11 80       	push   $0x80113980
80104ae9:	e8 44 13 00 00       	call   80105e32 <acquire>
80104aee:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	ff 75 f0             	pushl  -0x10(%ebp)
80104af7:	e8 44 fa ff ff       	call   80104540 <assertStateEmbryo>
80104afc:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.embryo, p);
80104aff:	83 ec 08             	sub    $0x8,%esp
80104b02:	ff 75 f0             	pushl  -0x10(%ebp)
80104b05:	68 68 63 11 80       	push   $0x80116368
80104b0a:	e8 bb fb ff ff       	call   801046ca <removeFromStateList>
80104b0f:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b15:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready, p);
80104b1c:	83 ec 08             	sub    $0x8,%esp
80104b1f:	ff 75 f0             	pushl  -0x10(%ebp)
80104b22:	68 54 63 11 80       	push   $0x80116354
80104b27:	e8 98 fa ff ff       	call   801045c4 <addToStateListEnd>
80104b2c:	83 c4 10             	add    $0x10,%esp

  cprintf("289\n");
80104b2f:	83 ec 0c             	sub    $0xc,%esp
80104b32:	68 5c 99 10 80       	push   $0x8010995c
80104b37:	e8 8a b8 ff ff       	call   801003c6 <cprintf>
80104b3c:	83 c4 10             	add    $0x10,%esp
  
  release(&ptable.lock);
80104b3f:	83 ec 0c             	sub    $0xc,%esp
80104b42:	68 80 39 11 80       	push   $0x80113980
80104b47:	e8 4d 13 00 00       	call   80105e99 <release>
80104b4c:	83 c4 10             	add    $0x10,%esp
  #endif



}
80104b4f:	90                   	nop
80104b50:	c9                   	leave  
80104b51:	c3                   	ret    

80104b52 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104b52:	55                   	push   %ebp
80104b53:	89 e5                	mov    %esp,%ebp
80104b55:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104b58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5e:	8b 00                	mov    (%eax),%eax
80104b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104b63:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b67:	7e 31                	jle    80104b9a <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104b69:	8b 55 08             	mov    0x8(%ebp),%edx
80104b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6f:	01 c2                	add    %eax,%edx
80104b71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b77:	8b 40 04             	mov    0x4(%eax),%eax
80104b7a:	83 ec 04             	sub    $0x4,%esp
80104b7d:	52                   	push   %edx
80104b7e:	ff 75 f4             	pushl  -0xc(%ebp)
80104b81:	50                   	push   %eax
80104b82:	e8 ce 44 00 00       	call   80109055 <allocuvm>
80104b87:	83 c4 10             	add    $0x10,%esp
80104b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b91:	75 3e                	jne    80104bd1 <growproc+0x7f>
      return -1;
80104b93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b98:	eb 59                	jmp    80104bf3 <growproc+0xa1>
  } else if(n < 0){
80104b9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b9e:	79 31                	jns    80104bd1 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104ba0:	8b 55 08             	mov    0x8(%ebp),%edx
80104ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba6:	01 c2                	add    %eax,%edx
80104ba8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bae:	8b 40 04             	mov    0x4(%eax),%eax
80104bb1:	83 ec 04             	sub    $0x4,%esp
80104bb4:	52                   	push   %edx
80104bb5:	ff 75 f4             	pushl  -0xc(%ebp)
80104bb8:	50                   	push   %eax
80104bb9:	e8 60 45 00 00       	call   8010911e <deallocuvm>
80104bbe:	83 c4 10             	add    $0x10,%esp
80104bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bc8:	75 07                	jne    80104bd1 <growproc+0x7f>
      return -1;
80104bca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bcf:	eb 22                	jmp    80104bf3 <growproc+0xa1>
  }
  proc->sz = sz;
80104bd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bda:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104bdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be2:	83 ec 0c             	sub    $0xc,%esp
80104be5:	50                   	push   %eax
80104be6:	e8 aa 41 00 00       	call   80108d95 <switchuvm>
80104beb:	83 c4 10             	add    $0x10,%esp
  return 0;
80104bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bf3:	c9                   	leave  
80104bf4:	c3                   	ret    

80104bf5 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104bf5:	55                   	push   %ebp
80104bf6:	89 e5                	mov    %esp,%ebp
80104bf8:	57                   	push   %edi
80104bf9:	56                   	push   %esi
80104bfa:	53                   	push   %ebx
80104bfb:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104bfe:	e8 60 fb ff ff       	call   80104763 <allocproc>
80104c03:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104c06:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104c0a:	75 0a                	jne    80104c16 <fork+0x21>
    return -1;
80104c0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c11:	e9 3e 02 00 00       	jmp    80104e54 <fork+0x25f>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104c16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c1c:	8b 10                	mov    (%eax),%edx
80104c1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c24:	8b 40 04             	mov    0x4(%eax),%eax
80104c27:	83 ec 08             	sub    $0x8,%esp
80104c2a:	52                   	push   %edx
80104c2b:	50                   	push   %eax
80104c2c:	e8 8b 46 00 00       	call   801092bc <copyuvm>
80104c31:	83 c4 10             	add    $0x10,%esp
80104c34:	89 c2                	mov    %eax,%edx
80104c36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c39:	89 50 04             	mov    %edx,0x4(%eax)
80104c3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c3f:	8b 40 04             	mov    0x4(%eax),%eax
80104c42:	85 c0                	test   %eax,%eax
80104c44:	0f 85 94 00 00 00    	jne    80104cde <fork+0xe9>
    kfree(np->kstack);
80104c4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c4d:	8b 40 08             	mov    0x8(%eax),%eax
80104c50:	83 ec 0c             	sub    $0xc,%esp
80104c53:	50                   	push   %eax
80104c54:	e8 1a e0 ff ff       	call   80102c73 <kfree>
80104c59:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104c5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

#ifdef CS333_P3P4

  acquire(&ptable.lock);
80104c66:	83 ec 0c             	sub    $0xc,%esp
80104c69:	68 80 39 11 80       	push   $0x80113980
80104c6e:	e8 bf 11 00 00       	call   80105e32 <acquire>
80104c73:	83 c4 10             	add    $0x10,%esp

  assertStateZombie(np);
80104c76:	83 ec 0c             	sub    $0xc,%esp
80104c79:	ff 75 e0             	pushl  -0x20(%ebp)
80104c7c:	e8 9e f8 ff ff       	call   8010451f <assertStateZombie>
80104c81:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.zombie, np);
80104c84:	83 ec 08             	sub    $0x8,%esp
80104c87:	ff 75 e0             	pushl  -0x20(%ebp)
80104c8a:	68 60 63 11 80       	push   $0x80116360
80104c8f:	e8 36 fa ff ff       	call   801046ca <removeFromStateList>
80104c94:	83 c4 10             	add    $0x10,%esp

    np->state = UNUSED;
80104c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c9a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  addToStateListHead(&ptable.pLists.free, np);
80104ca1:	83 ec 08             	sub    $0x8,%esp
80104ca4:	ff 75 e0             	pushl  -0x20(%ebp)
80104ca7:	68 58 63 11 80       	push   $0x80116358
80104cac:	e8 7a f9 ff ff       	call   8010462b <addToStateListHead>
80104cb1:	83 c4 10             	add    $0x10,%esp

  cprintf("348\n");
80104cb4:	83 ec 0c             	sub    $0xc,%esp
80104cb7:	68 61 99 10 80       	push   $0x80109961
80104cbc:	e8 05 b7 ff ff       	call   801003c6 <cprintf>
80104cc1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104cc4:	83 ec 0c             	sub    $0xc,%esp
80104cc7:	68 80 39 11 80       	push   $0x80113980
80104ccc:	e8 c8 11 00 00       	call   80105e99 <release>
80104cd1:	83 c4 10             	add    $0x10,%esp

#endif
    return -1;
80104cd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cd9:	e9 76 01 00 00       	jmp    80104e54 <fork+0x25f>
  }
  np->sz = proc->sz;
80104cde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce4:	8b 10                	mov    (%eax),%edx
80104ce6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ce9:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104ceb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cf2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cf5:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104cf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cfb:	8b 50 18             	mov    0x18(%eax),%edx
80104cfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d04:	8b 40 18             	mov    0x18(%eax),%eax
80104d07:	89 c3                	mov    %eax,%ebx
80104d09:	b8 13 00 00 00       	mov    $0x13,%eax
80104d0e:	89 d7                	mov    %edx,%edi
80104d10:	89 de                	mov    %ebx,%esi
80104d12:	89 c1                	mov    %eax,%ecx
80104d14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

    #ifdef CS333_P2
    np -> uid = proc -> uid;
80104d16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1c:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d25:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    np -> gid = proc -> gid;
80104d2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d31:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d3a:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    #endif

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104d40:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d43:	8b 40 18             	mov    0x18(%eax),%eax
80104d46:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104d4d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104d54:	eb 43                	jmp    80104d99 <fork+0x1a4>
    if(proc->ofile[i])
80104d56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d5f:	83 c2 08             	add    $0x8,%edx
80104d62:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d66:	85 c0                	test   %eax,%eax
80104d68:	74 2b                	je     80104d95 <fork+0x1a0>
      np->ofile[i] = filedup(proc->ofile[i]);
80104d6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d73:	83 c2 08             	add    $0x8,%edx
80104d76:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d7a:	83 ec 0c             	sub    $0xc,%esp
80104d7d:	50                   	push   %eax
80104d7e:	e8 27 c3 ff ff       	call   801010aa <filedup>
80104d83:	83 c4 10             	add    $0x10,%esp
80104d86:	89 c1                	mov    %eax,%ecx
80104d88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d8e:	83 c2 08             	add    $0x8,%edx
80104d91:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
    #endif

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104d95:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104d99:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104d9d:	7e b7                	jle    80104d56 <fork+0x161>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104d9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da5:	8b 40 68             	mov    0x68(%eax),%eax
80104da8:	83 ec 0c             	sub    $0xc,%esp
80104dab:	50                   	push   %eax
80104dac:	e8 29 cc ff ff       	call   801019da <idup>
80104db1:	83 c4 10             	add    $0x10,%esp
80104db4:	89 c2                	mov    %eax,%edx
80104db6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104db9:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104dbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc2:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dc8:	83 c0 6c             	add    $0x6c,%eax
80104dcb:	83 ec 04             	sub    $0x4,%esp
80104dce:	6a 10                	push   $0x10
80104dd0:	52                   	push   %edx
80104dd1:	50                   	push   %eax
80104dd2:	e8 c1 14 00 00       	call   80106298 <safestrcpy>
80104dd7:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ddd:	8b 40 10             	mov    0x10(%eax),%eax
80104de0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104de3:	83 ec 0c             	sub    $0xc,%esp
80104de6:	68 80 39 11 80       	push   $0x80113980
80104deb:	e8 42 10 00 00       	call   80105e32 <acquire>
80104df0:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4

  assertStateEmbryo(np);
80104df3:	83 ec 0c             	sub    $0xc,%esp
80104df6:	ff 75 e0             	pushl  -0x20(%ebp)
80104df9:	e8 42 f7 ff ff       	call   80104540 <assertStateEmbryo>
80104dfe:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.embryo, np);
80104e01:	83 ec 08             	sub    $0x8,%esp
80104e04:	ff 75 e0             	pushl  -0x20(%ebp)
80104e07:	68 68 63 11 80       	push   $0x80116368
80104e0c:	e8 b9 f8 ff ff       	call   801046ca <removeFromStateList>
80104e11:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e17:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListHead(&ptable.pLists.ready, np);
80104e1e:	83 ec 08             	sub    $0x8,%esp
80104e21:	ff 75 e0             	pushl  -0x20(%ebp)
80104e24:	68 54 63 11 80       	push   $0x80116354
80104e29:	e8 fd f7 ff ff       	call   8010462b <addToStateListHead>
80104e2e:	83 c4 10             	add    $0x10,%esp

  cprintf("387\n");
80104e31:	83 ec 0c             	sub    $0xc,%esp
80104e34:	68 66 99 10 80       	push   $0x80109966
80104e39:	e8 88 b5 ff ff       	call   801003c6 <cprintf>
80104e3e:	83 c4 10             	add    $0x10,%esp
#endif
  release(&ptable.lock);
80104e41:	83 ec 0c             	sub    $0xc,%esp
80104e44:	68 80 39 11 80       	push   $0x80113980
80104e49:	e8 4b 10 00 00       	call   80105e99 <release>
80104e4e:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104e51:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e57:	5b                   	pop    %ebx
80104e58:	5e                   	pop    %esi
80104e59:	5f                   	pop    %edi
80104e5a:	5d                   	pop    %ebp
80104e5b:	c3                   	ret    

80104e5c <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
80104e5f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104e62:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e69:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104e6e:	39 c2                	cmp    %eax,%edx
80104e70:	75 0d                	jne    80104e7f <exit+0x23>
    panic("init exiting");
80104e72:	83 ec 0c             	sub    $0xc,%esp
80104e75:	68 6b 99 10 80       	push   $0x8010996b
80104e7a:	e8 e7 b6 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104e7f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104e86:	eb 48                	jmp    80104ed0 <exit+0x74>
    if(proc->ofile[fd]){
80104e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e91:	83 c2 08             	add    $0x8,%edx
80104e94:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e98:	85 c0                	test   %eax,%eax
80104e9a:	74 30                	je     80104ecc <exit+0x70>
      fileclose(proc->ofile[fd]);
80104e9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ea5:	83 c2 08             	add    $0x8,%edx
80104ea8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104eac:	83 ec 0c             	sub    $0xc,%esp
80104eaf:	50                   	push   %eax
80104eb0:	e8 46 c2 ff ff       	call   801010fb <fileclose>
80104eb5:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ebe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ec1:	83 c2 08             	add    $0x8,%edx
80104ec4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104ecb:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ecc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104ed0:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104ed4:	7e b2                	jle    80104e88 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104ed6:	e8 1c e7 ff ff       	call   801035f7 <begin_op>
  iput(proc->cwd);
80104edb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee1:	8b 40 68             	mov    0x68(%eax),%eax
80104ee4:	83 ec 0c             	sub    $0xc,%esp
80104ee7:	50                   	push   %eax
80104ee8:	e8 f7 cc ff ff       	call   80101be4 <iput>
80104eed:	83 c4 10             	add    $0x10,%esp
  end_op();
80104ef0:	e8 8e e7 ff ff       	call   80103683 <end_op>
  proc->cwd = 0;
80104ef5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104efb:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104f02:	83 ec 0c             	sub    $0xc,%esp
80104f05:	68 80 39 11 80       	push   $0x80113980
80104f0a:	e8 23 0f 00 00       	call   80105e32 <acquire>
80104f0f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104f12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f18:	8b 40 14             	mov    0x14(%eax),%eax
80104f1b:	83 ec 0c             	sub    $0xc,%esp
80104f1e:	50                   	push   %eax
80104f1f:	e8 d4 05 00 00       	call   801054f8 <wakeup1>
80104f24:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f27:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f2e:	eb 3f                	jmp    80104f6f <exit+0x113>
    if(p->parent == proc){
80104f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f33:	8b 50 14             	mov    0x14(%eax),%edx
80104f36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f3c:	39 c2                	cmp    %eax,%edx
80104f3e:	75 28                	jne    80104f68 <exit+0x10c>
      p->parent = initproc;
80104f40:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f49:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f52:	83 f8 05             	cmp    $0x5,%eax
80104f55:	75 11                	jne    80104f68 <exit+0x10c>
        wakeup1(initproc);
80104f57:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104f5c:	83 ec 0c             	sub    $0xc,%esp
80104f5f:	50                   	push   %eax
80104f60:	e8 93 05 00 00       	call   801054f8 <wakeup1>
80104f65:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f68:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104f6f:	81 7d f4 54 63 11 80 	cmpl   $0x80116354,-0xc(%ebp)
80104f76:	72 b8                	jb     80104f30 <exit+0xd4>
  }

  // Jump into the scheduler, never to return.
  #ifdef CS333_P3P4

  assertStateRunning(p);
80104f78:	83 ec 0c             	sub    $0xc,%esp
80104f7b:	ff 75 f4             	pushl  -0xc(%ebp)
80104f7e:	e8 de f5 ff ff       	call   80104561 <assertStateRunning>
80104f83:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.running, p);
80104f86:	83 ec 08             	sub    $0x8,%esp
80104f89:	ff 75 f4             	pushl  -0xc(%ebp)
80104f8c:	68 64 63 11 80       	push   $0x80116364
80104f91:	e8 34 f7 ff ff       	call   801046ca <removeFromStateList>
80104f96:	83 c4 10             	add    $0x10,%esp

  proc->state = ZOMBIE;
80104f99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  addToStateListHead(&ptable.pLists.zombie, p);
80104fa6:	83 ec 08             	sub    $0x8,%esp
80104fa9:	ff 75 f4             	pushl  -0xc(%ebp)
80104fac:	68 60 63 11 80       	push   $0x80116360
80104fb1:	e8 75 f6 ff ff       	call   8010462b <addToStateListHead>
80104fb6:	83 c4 10             	add    $0x10,%esp

  cprintf("486\n");
80104fb9:	83 ec 0c             	sub    $0xc,%esp
80104fbc:	68 78 99 10 80       	push   $0x80109978
80104fc1:	e8 00 b4 ff ff       	call   801003c6 <cprintf>
80104fc6:	83 c4 10             	add    $0x10,%esp
  #endif
  sched();
80104fc9:	e8 72 02 00 00       	call   80105240 <sched>
  panic("zombie exit");
80104fce:	83 ec 0c             	sub    $0xc,%esp
80104fd1:	68 7d 99 10 80       	push   $0x8010997d
80104fd6:	e8 8b b5 ff ff       	call   80100566 <panic>

80104fdb <wait>:
  }
}
#else
int
wait(void)
{
80104fdb:	55                   	push   %ebp
80104fdc:	89 e5                	mov    %esp,%ebp
80104fde:	83 ec 18             	sub    $0x18,%esp

  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104fe1:	83 ec 0c             	sub    $0xc,%esp
80104fe4:	68 80 39 11 80       	push   $0x80113980
80104fe9:	e8 44 0e 00 00       	call   80105e32 <acquire>
80104fee:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104ff1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff8:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104fff:	e9 f1 00 00 00       	jmp    801050f5 <wait+0x11a>
      if(p->parent != proc)
80105004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105007:	8b 50 14             	mov    0x14(%eax),%edx
8010500a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105010:	39 c2                	cmp    %eax,%edx
80105012:	0f 85 d5 00 00 00    	jne    801050ed <wait+0x112>
        continue;
      havekids = 1;
80105018:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010501f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105022:	8b 40 0c             	mov    0xc(%eax),%eax
80105025:	83 f8 05             	cmp    $0x5,%eax
80105028:	0f 85 c0 00 00 00    	jne    801050ee <wait+0x113>
        // Found one.
        pid = p->pid;
8010502e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105031:	8b 40 10             	mov    0x10(%eax),%eax
80105034:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503a:	8b 40 08             	mov    0x8(%eax),%eax
8010503d:	83 ec 0c             	sub    $0xc,%esp
80105040:	50                   	push   %eax
80105041:	e8 2d dc ff ff       	call   80102c73 <kfree>
80105046:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80105049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105056:	8b 40 04             	mov    0x4(%eax),%eax
80105059:	83 ec 0c             	sub    $0xc,%esp
8010505c:	50                   	push   %eax
8010505d:	e8 79 41 00 00       	call   801091db <freevm>
80105062:	83 c4 10             	add    $0x10,%esp

	#ifdef CS333_P3P4

	assertStateZombie(p);
80105065:	83 ec 0c             	sub    $0xc,%esp
80105068:	ff 75 f4             	pushl  -0xc(%ebp)
8010506b:	e8 af f4 ff ff       	call   8010451f <assertStateZombie>
80105070:	83 c4 10             	add    $0x10,%esp

	removeFromStateList(&ptable.pLists.zombie, p);
80105073:	83 ec 08             	sub    $0x8,%esp
80105076:	ff 75 f4             	pushl  -0xc(%ebp)
80105079:	68 60 63 11 80       	push   $0x80116360
8010507e:	e8 47 f6 ff ff       	call   801046ca <removeFromStateList>
80105083:	83 c4 10             	add    $0x10,%esp

        p->state = UNUSED;
80105086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105089:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	addToStateListHead(&ptable.pLists.free, p);
80105090:	83 ec 08             	sub    $0x8,%esp
80105093:	ff 75 f4             	pushl  -0xc(%ebp)
80105096:	68 58 63 11 80       	push   $0x80116358
8010509b:	e8 8b f5 ff ff       	call   8010462b <addToStateListHead>
801050a0:	83 c4 10             	add    $0x10,%esp

	cprintf("568\n");
801050a3:	83 ec 0c             	sub    $0xc,%esp
801050a6:	68 89 99 10 80       	push   $0x80109989
801050ab:	e8 16 b3 ff ff       	call   801003c6 <cprintf>
801050b0:	83 c4 10             	add    $0x10,%esp
	#endif

        p->pid = 0;
801050b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801050bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801050c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ca:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801050ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d1:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801050d8:	83 ec 0c             	sub    $0xc,%esp
801050db:	68 80 39 11 80       	push   $0x80113980
801050e0:	e8 b4 0d 00 00       	call   80105e99 <release>
801050e5:	83 c4 10             	add    $0x10,%esp
        return pid;
801050e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050eb:	eb 5b                	jmp    80105148 <wait+0x16d>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801050ed:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ee:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801050f5:	81 7d f4 54 63 11 80 	cmpl   $0x80116354,-0xc(%ebp)
801050fc:	0f 82 02 ff ff ff    	jb     80105004 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105102:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105106:	74 0d                	je     80105115 <wait+0x13a>
80105108:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010510e:	8b 40 24             	mov    0x24(%eax),%eax
80105111:	85 c0                	test   %eax,%eax
80105113:	74 17                	je     8010512c <wait+0x151>
      release(&ptable.lock);
80105115:	83 ec 0c             	sub    $0xc,%esp
80105118:	68 80 39 11 80       	push   $0x80113980
8010511d:	e8 77 0d 00 00       	call   80105e99 <release>
80105122:	83 c4 10             	add    $0x10,%esp
      return -1;
80105125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512a:	eb 1c                	jmp    80105148 <wait+0x16d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010512c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105132:	83 ec 08             	sub    $0x8,%esp
80105135:	68 80 39 11 80       	push   $0x80113980
8010513a:	50                   	push   %eax
8010513b:	e8 c3 02 00 00       	call   80105403 <sleep>
80105140:	83 c4 10             	add    $0x10,%esp
  }
80105143:	e9 a9 fe ff ff       	jmp    80104ff1 <wait+0x16>
}
80105148:	c9                   	leave  
80105149:	c3                   	ret    

8010514a <scheduler>:
}

#else
void
scheduler(void)
{
8010514a:	55                   	push   %ebp
8010514b:	89 e5                	mov    %esp,%ebp
8010514d:	83 ec 18             	sub    $0x18,%esp
      int idle;  // for checking if processor is idle

      //cprintf("scheduler invoked\n");
      for(;;){
	// Enable interrupts on this processor.
	sti();
80105150:	e8 a3 f3 ff ff       	call   801044f8 <sti>

	idle = 1;  // assume idle unless we schedule a process
80105155:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

	//cprintf(" before the while loop is hit\n");
	if(ptable.pLists.ready){
8010515c:	a1 54 63 11 80       	mov    0x80116354,%eax
80105161:	85 c0                	test   %eax,%eax
80105163:	74 eb                	je     80105150 <scheduler+0x6>

	  acquire(&ptable.lock);
80105165:	83 ec 0c             	sub    $0xc,%esp
80105168:	68 80 39 11 80       	push   $0x80113980
8010516d:	e8 c0 0c 00 00       	call   80105e32 <acquire>
80105172:	83 c4 10             	add    $0x10,%esp
	  assertStateReady(ptable.pLists.ready);
80105175:	a1 54 63 11 80       	mov    0x80116354,%eax
8010517a:	83 ec 0c             	sub    $0xc,%esp
8010517d:	50                   	push   %eax
8010517e:	e8 20 f4 ff ff       	call   801045a3 <assertStateReady>
80105183:	83 c4 10             	add    $0x10,%esp
	  //cprintf("assserted ready\n");
	  proc = removeFromStateListHead(&ptable.pLists.ready);
80105186:	83 ec 0c             	sub    $0xc,%esp
80105189:	68 54 63 11 80       	push   $0x80116354
8010518e:	e8 c1 f4 ff ff       	call   80104654 <removeFromStateListHead>
80105193:	83 c4 10             	add    $0x10,%esp
80105196:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  //cprintf("remove from state list finished\n");

	  if(proc){
8010519c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051a2:	85 c0                	test   %eax,%eax
801051a4:	74 aa                	je     80105150 <scheduler+0x6>
	      idle = 0;  // not idle this timeslice
801051a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	      switchuvm(proc);
801051ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b3:	83 ec 0c             	sub    $0xc,%esp
801051b6:	50                   	push   %eax
801051b7:	e8 d9 3b 00 00       	call   80108d95 <switchuvm>
801051bc:	83 c4 10             	add    $0x10,%esp
	      proc -> state = RUNNING;
801051bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c5:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	      addToStateListHead(&ptable.pLists.running, proc);
801051cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d2:	83 ec 08             	sub    $0x8,%esp
801051d5:	50                   	push   %eax
801051d6:	68 64 63 11 80       	push   $0x80116364
801051db:	e8 4b f4 ff ff       	call   8010462b <addToStateListHead>
801051e0:	83 c4 10             	add    $0x10,%esp

	      #ifdef CS333_P2
	      p = proc;
801051e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	      p->cpu_ticks_in = ticks;
801051ec:	8b 15 80 6b 11 80    	mov    0x80116b80,%edx
801051f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f5:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
	      #endif

	      release(&ptable.lock);
801051fb:	83 ec 0c             	sub    $0xc,%esp
801051fe:	68 80 39 11 80       	push   $0x80113980
80105203:	e8 91 0c 00 00       	call   80105e99 <release>
80105208:	83 c4 10             	add    $0x10,%esp
	      swtch(&cpu->scheduler, proc->context);
8010520b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105211:	8b 40 1c             	mov    0x1c(%eax),%eax
80105214:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010521b:	83 c2 04             	add    $0x4,%edx
8010521e:	83 ec 08             	sub    $0x8,%esp
80105221:	50                   	push   %eax
80105222:	52                   	push   %edx
80105223:	e8 e1 10 00 00       	call   80106309 <swtch>
80105228:	83 c4 10             	add    $0x10,%esp
	      switchkvm();
8010522b:	e8 48 3b 00 00       	call   80108d78 <switchkvm>

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      proc = 0;
80105230:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105237:	00 00 00 00 
	  }
	}
    	//else
	//    cprintf("ptable.pLists.ready is null");
      }
8010523b:	e9 10 ff ff ff       	jmp    80105150 <scheduler+0x6>

80105240 <sched>:

}
#else
void
sched(void)
{
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
80105243:	53                   	push   %ebx
80105244:	83 ec 14             	sub    $0x14,%esp
    int intena;

  if(!holding(&ptable.lock))
80105247:	83 ec 0c             	sub    $0xc,%esp
8010524a:	68 80 39 11 80       	push   $0x80113980
8010524f:	e8 11 0d 00 00       	call   80105f65 <holding>
80105254:	83 c4 10             	add    $0x10,%esp
80105257:	85 c0                	test   %eax,%eax
80105259:	75 0d                	jne    80105268 <sched+0x28>
    panic("sched ptable.lock");
8010525b:	83 ec 0c             	sub    $0xc,%esp
8010525e:	68 8e 99 10 80       	push   $0x8010998e
80105263:	e8 fe b2 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105268:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010526e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105274:	83 f8 01             	cmp    $0x1,%eax
80105277:	74 0d                	je     80105286 <sched+0x46>
    panic("sched locks");
80105279:	83 ec 0c             	sub    $0xc,%esp
8010527c:	68 a0 99 10 80       	push   $0x801099a0
80105281:	e8 e0 b2 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105286:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528c:	8b 40 0c             	mov    0xc(%eax),%eax
8010528f:	83 f8 04             	cmp    $0x4,%eax
80105292:	75 0d                	jne    801052a1 <sched+0x61>
    panic("sched running");
80105294:	83 ec 0c             	sub    $0xc,%esp
80105297:	68 ac 99 10 80       	push   $0x801099ac
8010529c:	e8 c5 b2 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801052a1:	e8 42 f2 ff ff       	call   801044e8 <readeflags>
801052a6:	25 00 02 00 00       	and    $0x200,%eax
801052ab:	85 c0                	test   %eax,%eax
801052ad:	74 0d                	je     801052bc <sched+0x7c>
    panic("sched interruptible");
801052af:	83 ec 0c             	sub    $0xc,%esp
801052b2:	68 ba 99 10 80       	push   $0x801099ba
801052b7:	e8 aa b2 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801052bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052c2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    #ifdef CS333_P2
    proc -> cpu_ticks_total += (ticks - proc -> cpu_ticks_in);
801052cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052d8:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
801052de:	8b 1d 80 6b 11 80    	mov    0x80116b80,%ebx
801052e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052eb:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
801052f1:	29 d3                	sub    %edx,%ebx
801052f3:	89 da                	mov    %ebx,%edx
801052f5:	01 ca                	add    %ecx,%edx
801052f7:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    #endif
  swtch(&proc->context, cpu->scheduler);
801052fd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105303:	8b 40 04             	mov    0x4(%eax),%eax
80105306:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010530d:	83 c2 1c             	add    $0x1c,%edx
80105310:	83 ec 08             	sub    $0x8,%esp
80105313:	50                   	push   %eax
80105314:	52                   	push   %edx
80105315:	e8 ef 0f 00 00       	call   80106309 <swtch>
8010531a:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010531d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105323:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105326:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
8010532c:	90                   	nop
8010532d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105330:	c9                   	leave  
80105331:	c3                   	ret    

80105332 <yield>:
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105332:	55                   	push   %ebp
80105333:	89 e5                	mov    %esp,%ebp
80105335:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105338:	83 ec 0c             	sub    $0xc,%esp
8010533b:	68 80 39 11 80       	push   $0x80113980
80105340:	e8 ed 0a 00 00       	call   80105e32 <acquire>
80105345:	83 c4 10             	add    $0x10,%esp

  #ifdef CS333_P3P4

  assertStateRunning(proc);
80105348:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010534e:	83 ec 0c             	sub    $0xc,%esp
80105351:	50                   	push   %eax
80105352:	e8 0a f2 ff ff       	call   80104561 <assertStateRunning>
80105357:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.running, proc);
8010535a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105360:	83 ec 08             	sub    $0x8,%esp
80105363:	50                   	push   %eax
80105364:	68 64 63 11 80       	push   $0x80116364
80105369:	e8 5c f3 ff ff       	call   801046ca <removeFromStateList>
8010536e:	83 c4 10             	add    $0x10,%esp

  proc->state = RUNNABLE;
80105371:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105377:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListHead(&ptable.pLists.ready, proc);
8010537e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105384:	83 ec 08             	sub    $0x8,%esp
80105387:	50                   	push   %eax
80105388:	68 54 63 11 80       	push   $0x80116354
8010538d:	e8 99 f2 ff ff       	call   8010462b <addToStateListHead>
80105392:	83 c4 10             	add    $0x10,%esp

	cprintf("768\n");
80105395:	83 ec 0c             	sub    $0xc,%esp
80105398:	68 ce 99 10 80       	push   $0x801099ce
8010539d:	e8 24 b0 ff ff       	call   801003c6 <cprintf>
801053a2:	83 c4 10             	add    $0x10,%esp
  #endif
  sched();
801053a5:	e8 96 fe ff ff       	call   80105240 <sched>
  release(&ptable.lock);
801053aa:	83 ec 0c             	sub    $0xc,%esp
801053ad:	68 80 39 11 80       	push   $0x80113980
801053b2:	e8 e2 0a 00 00       	call   80105e99 <release>
801053b7:	83 c4 10             	add    $0x10,%esp
}
801053ba:	90                   	nop
801053bb:	c9                   	leave  
801053bc:	c3                   	ret    

801053bd <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801053bd:	55                   	push   %ebp
801053be:	89 e5                	mov    %esp,%ebp
801053c0:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801053c3:	83 ec 0c             	sub    $0xc,%esp
801053c6:	68 80 39 11 80       	push   $0x80113980
801053cb:	e8 c9 0a 00 00       	call   80105e99 <release>
801053d0:	83 c4 10             	add    $0x10,%esp

  if (first) {
801053d3:	a1 20 c0 10 80       	mov    0x8010c020,%eax
801053d8:	85 c0                	test   %eax,%eax
801053da:	74 24                	je     80105400 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801053dc:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801053e3:	00 00 00 
    iinit(ROOTDEV);
801053e6:	83 ec 0c             	sub    $0xc,%esp
801053e9:	6a 01                	push   $0x1
801053eb:	e8 f8 c2 ff ff       	call   801016e8 <iinit>
801053f0:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801053f3:	83 ec 0c             	sub    $0xc,%esp
801053f6:	6a 01                	push   $0x1
801053f8:	e8 dc df ff ff       	call   801033d9 <initlog>
801053fd:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105400:	90                   	nop
80105401:	c9                   	leave  
80105402:	c3                   	ret    

80105403 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80105403:	55                   	push   %ebp
80105404:	89 e5                	mov    %esp,%ebp
80105406:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105409:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010540f:	85 c0                	test   %eax,%eax
80105411:	75 0d                	jne    80105420 <sleep+0x1d>
    panic("sleep");
80105413:	83 ec 0c             	sub    $0xc,%esp
80105416:	68 d3 99 10 80       	push   $0x801099d3
8010541b:	e8 46 b1 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80105420:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105427:	74 24                	je     8010544d <sleep+0x4a>
    acquire(&ptable.lock);
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	68 80 39 11 80       	push   $0x80113980
80105431:	e8 fc 09 00 00       	call   80105e32 <acquire>
80105436:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80105439:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010543d:	74 0e                	je     8010544d <sleep+0x4a>
8010543f:	83 ec 0c             	sub    $0xc,%esp
80105442:	ff 75 0c             	pushl  0xc(%ebp)
80105445:	e8 4f 0a 00 00       	call   80105e99 <release>
8010544a:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
8010544d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105453:	8b 55 08             	mov    0x8(%ebp),%edx
80105456:	89 50 20             	mov    %edx,0x20(%eax)
  #ifdef CS333_P3P4

  assertStateRunning(proc);
80105459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010545f:	83 ec 0c             	sub    $0xc,%esp
80105462:	50                   	push   %eax
80105463:	e8 f9 f0 ff ff       	call   80104561 <assertStateRunning>
80105468:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.running, proc);
8010546b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105471:	83 ec 08             	sub    $0x8,%esp
80105474:	50                   	push   %eax
80105475:	68 64 63 11 80       	push   $0x80116364
8010547a:	e8 4b f2 ff ff       	call   801046ca <removeFromStateList>
8010547f:	83 c4 10             	add    $0x10,%esp

  proc->state = SLEEPING;
80105482:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105488:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  addToStateListHead(&ptable.pLists.sleep, proc);
8010548f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105495:	83 ec 08             	sub    $0x8,%esp
80105498:	50                   	push   %eax
80105499:	68 5c 63 11 80       	push   $0x8011635c
8010549e:	e8 88 f1 ff ff       	call   8010462b <addToStateListHead>
801054a3:	83 c4 10             	add    $0x10,%esp

	cprintf("827\n");
801054a6:	83 ec 0c             	sub    $0xc,%esp
801054a9:	68 d9 99 10 80       	push   $0x801099d9
801054ae:	e8 13 af ff ff       	call   801003c6 <cprintf>
801054b3:	83 c4 10             	add    $0x10,%esp
  #endif
  sched();
801054b6:	e8 85 fd ff ff       	call   80105240 <sched>

  // Tidy up.
  proc->chan = 0;
801054bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
801054c8:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801054cf:	74 24                	je     801054f5 <sleep+0xf2>
    release(&ptable.lock);
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	68 80 39 11 80       	push   $0x80113980
801054d9:	e8 bb 09 00 00       	call   80105e99 <release>
801054de:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
801054e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054e5:	74 0e                	je     801054f5 <sleep+0xf2>
801054e7:	83 ec 0c             	sub    $0xc,%esp
801054ea:	ff 75 0c             	pushl  0xc(%ebp)
801054ed:	e8 40 09 00 00       	call   80105e32 <acquire>
801054f2:	83 c4 10             	add    $0x10,%esp
  }
}
801054f5:	90                   	nop
801054f6:	c9                   	leave  
801054f7:	c3                   	ret    

801054f8 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801054fe:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105505:	eb 6b                	jmp    80105572 <wakeup1+0x7a>
    if(p->state == SLEEPING && p->chan == chan){
80105507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550a:	8b 40 0c             	mov    0xc(%eax),%eax
8010550d:	83 f8 02             	cmp    $0x2,%eax
80105510:	75 59                	jne    8010556b <wakeup1+0x73>
80105512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105515:	8b 40 20             	mov    0x20(%eax),%eax
80105518:	3b 45 08             	cmp    0x8(%ebp),%eax
8010551b:	75 4e                	jne    8010556b <wakeup1+0x73>
      #ifdef CS333_P3P4

      assertStateSleep(p);
8010551d:	83 ec 0c             	sub    $0xc,%esp
80105520:	ff 75 f4             	pushl  -0xc(%ebp)
80105523:	e8 5a f0 ff ff       	call   80104582 <assertStateSleep>
80105528:	83 c4 10             	add    $0x10,%esp

      removeFromStateList(&ptable.pLists.sleep, p);
8010552b:	83 ec 08             	sub    $0x8,%esp
8010552e:	ff 75 f4             	pushl  -0xc(%ebp)
80105531:	68 5c 63 11 80       	push   $0x8011635c
80105536:	e8 8f f1 ff ff       	call   801046ca <removeFromStateList>
8010553b:	83 c4 10             	add    $0x10,%esp

      p->state = RUNNABLE;
8010553e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105541:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      addToStateListHead(&ptable.pLists.ready, p);
80105548:	83 ec 08             	sub    $0x8,%esp
8010554b:	ff 75 f4             	pushl  -0xc(%ebp)
8010554e:	68 54 63 11 80       	push   $0x80116354
80105553:	e8 d3 f0 ff ff       	call   8010462b <addToStateListHead>
80105558:	83 c4 10             	add    $0x10,%esp

	cprintf("871\n");
8010555b:	83 ec 0c             	sub    $0xc,%esp
8010555e:	68 de 99 10 80       	push   $0x801099de
80105563:	e8 5e ae ff ff       	call   801003c6 <cprintf>
80105568:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010556b:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105572:	81 7d f4 54 63 11 80 	cmpl   $0x80116354,-0xc(%ebp)
80105579:	72 8c                	jb     80105507 <wakeup1+0xf>

	cprintf("871\n");
      #endif

    }
}
8010557b:	90                   	nop
8010557c:	c9                   	leave  
8010557d:	c3                   	ret    

8010557e <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010557e:	55                   	push   %ebp
8010557f:	89 e5                	mov    %esp,%ebp
80105581:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105584:	83 ec 0c             	sub    $0xc,%esp
80105587:	68 80 39 11 80       	push   $0x80113980
8010558c:	e8 a1 08 00 00       	call   80105e32 <acquire>
80105591:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	ff 75 08             	pushl  0x8(%ebp)
8010559a:	e8 59 ff ff ff       	call   801054f8 <wakeup1>
8010559f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801055a2:	83 ec 0c             	sub    $0xc,%esp
801055a5:	68 80 39 11 80       	push   $0x80113980
801055aa:	e8 ea 08 00 00       	call   80105e99 <release>
801055af:	83 c4 10             	add    $0x10,%esp
}
801055b2:	90                   	nop
801055b3:	c9                   	leave  
801055b4:	c3                   	ret    

801055b5 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
801055b5:	55                   	push   %ebp
801055b6:	89 e5                	mov    %esp,%ebp
801055b8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801055bb:	83 ec 0c             	sub    $0xc,%esp
801055be:	68 80 39 11 80       	push   $0x80113980
801055c3:	e8 6a 08 00 00       	call   80105e32 <acquire>
801055c8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055cb:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801055d2:	e9 8e 00 00 00       	jmp    80105665 <kill+0xb0>
    if(p->pid == pid){
801055d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055da:	8b 50 10             	mov    0x10(%eax),%edx
801055dd:	8b 45 08             	mov    0x8(%ebp),%eax
801055e0:	39 c2                	cmp    %eax,%edx
801055e2:	75 7a                	jne    8010565e <kill+0xa9>
      p->killed = 1;
801055e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING){
801055ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f1:	8b 40 0c             	mov    0xc(%eax),%eax
801055f4:	83 f8 02             	cmp    $0x2,%eax
801055f7:	75 4e                	jne    80105647 <kill+0x92>
	#ifdef CS333_P3P4

	assertStateSleep(p);
801055f9:	83 ec 0c             	sub    $0xc,%esp
801055fc:	ff 75 f4             	pushl  -0xc(%ebp)
801055ff:	e8 7e ef ff ff       	call   80104582 <assertStateSleep>
80105604:	83 c4 10             	add    $0x10,%esp

	removeFromStateList(&ptable.pLists.sleep, p);
80105607:	83 ec 08             	sub    $0x8,%esp
8010560a:	ff 75 f4             	pushl  -0xc(%ebp)
8010560d:	68 5c 63 11 80       	push   $0x8011635c
80105612:	e8 b3 f0 ff ff       	call   801046ca <removeFromStateList>
80105617:	83 c4 10             	add    $0x10,%esp

        p->state = RUNNABLE;
8010561a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	addToStateListHead(&ptable.pLists.ready, p);
80105624:	83 ec 08             	sub    $0x8,%esp
80105627:	ff 75 f4             	pushl  -0xc(%ebp)
8010562a:	68 54 63 11 80       	push   $0x80116354
8010562f:	e8 f7 ef ff ff       	call   8010462b <addToStateListHead>
80105634:	83 c4 10             	add    $0x10,%esp

	cprintf("931\n");
80105637:	83 ec 0c             	sub    $0xc,%esp
8010563a:	68 e3 99 10 80       	push   $0x801099e3
8010563f:	e8 82 ad ff ff       	call   801003c6 <cprintf>
80105644:	83 c4 10             	add    $0x10,%esp
	#endif
      }
      release(&ptable.lock);
80105647:	83 ec 0c             	sub    $0xc,%esp
8010564a:	68 80 39 11 80       	push   $0x80113980
8010564f:	e8 45 08 00 00       	call   80105e99 <release>
80105654:	83 c4 10             	add    $0x10,%esp
      return 0;
80105657:	b8 00 00 00 00       	mov    $0x0,%eax
8010565c:	eb 29                	jmp    80105687 <kill+0xd2>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010565e:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105665:	81 7d f4 54 63 11 80 	cmpl   $0x80116354,-0xc(%ebp)
8010566c:	0f 82 65 ff ff ff    	jb     801055d7 <kill+0x22>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105672:	83 ec 0c             	sub    $0xc,%esp
80105675:	68 80 39 11 80       	push   $0x80113980
8010567a:	e8 1a 08 00 00       	call   80105e99 <release>
8010567f:	83 c4 10             	add    $0x10,%esp
  return -1;
80105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105687:	c9                   	leave  
80105688:	c3                   	ret    

80105689 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105689:	55                   	push   %ebp
8010568a:	89 e5                	mov    %esp,%ebp
8010568c:	56                   	push   %esi
8010568d:	53                   	push   %ebx
8010568e:	83 ec 50             	sub    $0x50,%esp
  int i, elapsed, milli, cpue, cpum;
  struct proc *p;
  char *state = "???";
80105691:	c7 45 ec 12 9a 10 80 	movl   $0x80109a12,-0x14(%ebp)
    //#ifdef CS333_P1
    //cprintf("PID      State   Name    Elapsed         PCs test\n");
    //#endif

    #ifdef CS333_P2
    cprintf("PID	Name    UID	GID	PPID    Elapsed	CPU	State   Size     PCs\n");
80105698:	83 ec 0c             	sub    $0xc,%esp
8010569b:	68 18 9a 10 80       	push   $0x80109a18
801056a0:	e8 21 ad ff ff       	call   801003c6 <cprintf>
801056a5:	83 c4 10             	add    $0x10,%esp
    #endif


    acquire(&ptable.lock);
801056a8:	83 ec 0c             	sub    $0xc,%esp
801056ab:	68 80 39 11 80       	push   $0x80113980
801056b0:	e8 7d 07 00 00       	call   80105e32 <acquire>
801056b5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056b8:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
801056bf:	e9 60 03 00 00       	jmp    80105a24 <procdump+0x39b>
    if(p->state == UNUSED)
801056c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c7:	8b 40 0c             	mov    0xc(%eax),%eax
801056ca:	85 c0                	test   %eax,%eax
801056cc:	0f 84 4a 03 00 00    	je     80105a1c <procdump+0x393>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801056d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d5:	8b 40 0c             	mov    0xc(%eax),%eax
801056d8:	83 f8 05             	cmp    $0x5,%eax
801056db:	77 21                	ja     801056fe <procdump+0x75>
801056dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e0:	8b 40 0c             	mov    0xc(%eax),%eax
801056e3:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801056ea:	85 c0                	test   %eax,%eax
801056ec:	74 10                	je     801056fe <procdump+0x75>
      state = states[p->state];
801056ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f1:	8b 40 0c             	mov    0xc(%eax),%eax
801056f4:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801056fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //cprintf("%d %s %s", p->pid, state, p->name);
    //cprintf("\n");
    //#endif

    #ifdef CS333_P2
    elapsed = (ticks - p -> start_ticks)/1000;
801056fe:	8b 15 80 6b 11 80    	mov    0x80116b80,%edx
80105704:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105707:	8b 40 7c             	mov    0x7c(%eax),%eax
8010570a:	29 c2                	sub    %eax,%edx
8010570c:	89 d0                	mov    %edx,%eax
8010570e:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105713:	f7 e2                	mul    %edx
80105715:	89 d0                	mov    %edx,%eax
80105717:	c1 e8 06             	shr    $0x6,%eax
8010571a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    milli = (ticks - p -> start_ticks)%1000;
8010571d:	8b 15 80 6b 11 80    	mov    0x80116b80,%edx
80105723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105726:	8b 40 7c             	mov    0x7c(%eax),%eax
80105729:	89 d1                	mov    %edx,%ecx
8010572b:	29 c1                	sub    %eax,%ecx
8010572d:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105732:	89 c8                	mov    %ecx,%eax
80105734:	f7 e2                	mul    %edx
80105736:	89 d0                	mov    %edx,%eax
80105738:	c1 e8 06             	shr    $0x6,%eax
8010573b:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105741:	29 c1                	sub    %eax,%ecx
80105743:	89 c8                	mov    %ecx,%eax
80105745:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cpue = (p -> cpu_ticks_total)/1000;
80105748:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105751:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105756:	f7 e2                	mul    %edx
80105758:	89 d0                	mov    %edx,%eax
8010575a:	c1 e8 06             	shr    $0x6,%eax
8010575d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cpum = (p -> cpu_ticks_total)%1000;
80105760:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105763:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80105769:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010576e:	89 c8                	mov    %ecx,%eax
80105770:	f7 e2                	mul    %edx
80105772:	89 d0                	mov    %edx,%eax
80105774:	c1 e8 06             	shr    $0x6,%eax
80105777:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
8010577d:	29 c1                	sub    %eax,%ecx
8010577f:	89 c8                	mov    %ecx,%eax
80105781:	89 45 dc             	mov    %eax,-0x24(%ebp)

    if(p -> pid == 1){
80105784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105787:	8b 40 10             	mov    0x10(%eax),%eax
8010578a:	83 f8 01             	cmp    $0x1,%eax
8010578d:	0f 85 0c 01 00 00    	jne    8010589f <procdump+0x216>
	cprintf("%d\t%s\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,1,  elapsed);
80105793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105796:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
8010579c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010579f:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801057a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a8:	8d 58 6c             	lea    0x6c(%eax),%ebx
801057ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ae:	8b 40 10             	mov    0x10(%eax),%eax
801057b1:	83 ec 04             	sub    $0x4,%esp
801057b4:	ff 75 e8             	pushl  -0x18(%ebp)
801057b7:	6a 01                	push   $0x1
801057b9:	51                   	push   %ecx
801057ba:	52                   	push   %edx
801057bb:	53                   	push   %ebx
801057bc:	50                   	push   %eax
801057bd:	68 56 9a 10 80       	push   $0x80109a56
801057c2:	e8 ff ab ff ff       	call   801003c6 <cprintf>
801057c7:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
801057ca:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
801057ce:	7f 16                	jg     801057e6 <procdump+0x15d>
	    cprintf("00%d\t%d.", milli, cpue);
801057d0:	83 ec 04             	sub    $0x4,%esp
801057d3:	ff 75 e0             	pushl  -0x20(%ebp)
801057d6:	ff 75 e4             	pushl  -0x1c(%ebp)
801057d9:	68 69 9a 10 80       	push   $0x80109a69
801057de:	e8 e3 ab ff ff       	call   801003c6 <cprintf>
801057e3:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
801057e6:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
801057ea:	7e 1e                	jle    8010580a <procdump+0x181>
801057ec:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801057f0:	7f 18                	jg     8010580a <procdump+0x181>
	    cprintf("0%d\t%d.", milli, cpue);
801057f2:	83 ec 04             	sub    $0x4,%esp
801057f5:	ff 75 e0             	pushl  -0x20(%ebp)
801057f8:	ff 75 e4             	pushl  -0x1c(%ebp)
801057fb:	68 72 9a 10 80       	push   $0x80109a72
80105800:	e8 c1 ab ff ff       	call   801003c6 <cprintf>
80105805:	83 c4 10             	add    $0x10,%esp
80105808:	eb 16                	jmp    80105820 <procdump+0x197>
	else
	    cprintf("%d\t%d.", milli, cpue);
8010580a:	83 ec 04             	sub    $0x4,%esp
8010580d:	ff 75 e0             	pushl  -0x20(%ebp)
80105810:	ff 75 e4             	pushl  -0x1c(%ebp)
80105813:	68 7a 9a 10 80       	push   $0x80109a7a
80105818:	e8 a9 ab ff ff       	call   801003c6 <cprintf>
8010581d:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80105820:	83 7d dc 09          	cmpl   $0x9,-0x24(%ebp)
80105824:	7f 21                	jg     80105847 <procdump+0x1be>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105829:	8b 00                	mov    (%eax),%eax
8010582b:	83 ec 0c             	sub    $0xc,%esp
8010582e:	68 81 9a 10 80       	push   $0x80109a81
80105833:	50                   	push   %eax
80105834:	ff 75 ec             	pushl  -0x14(%ebp)
80105837:	ff 75 dc             	pushl  -0x24(%ebp)
8010583a:	68 83 9a 10 80       	push   $0x80109a83
8010583f:	e8 82 ab ff ff       	call   801003c6 <cprintf>
80105844:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
80105847:	83 7d dc 09          	cmpl   $0x9,-0x24(%ebp)
8010584b:	7e 2c                	jle    80105879 <procdump+0x1f0>
8010584d:	83 7d dc 63          	cmpl   $0x63,-0x24(%ebp)
80105851:	7f 26                	jg     80105879 <procdump+0x1f0>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105856:	8b 00                	mov    (%eax),%eax
80105858:	83 ec 0c             	sub    $0xc,%esp
8010585b:	68 81 9a 10 80       	push   $0x80109a81
80105860:	50                   	push   %eax
80105861:	ff 75 ec             	pushl  -0x14(%ebp)
80105864:	ff 75 dc             	pushl  -0x24(%ebp)
80105867:	68 8f 9a 10 80       	push   $0x80109a8f
8010586c:	e8 55 ab ff ff       	call   801003c6 <cprintf>
80105871:	83 c4 20             	add    $0x20,%esp
80105874:	e9 32 01 00 00       	jmp    801059ab <procdump+0x322>
	else
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587c:	8b 00                	mov    (%eax),%eax
8010587e:	83 ec 0c             	sub    $0xc,%esp
80105881:	68 81 9a 10 80       	push   $0x80109a81
80105886:	50                   	push   %eax
80105887:	ff 75 ec             	pushl  -0x14(%ebp)
8010588a:	ff 75 dc             	pushl  -0x24(%ebp)
8010588d:	68 9a 9a 10 80       	push   $0x80109a9a
80105892:	e8 2f ab ff ff       	call   801003c6 <cprintf>
80105897:	83 c4 20             	add    $0x20,%esp
8010589a:	e9 0c 01 00 00       	jmp    801059ab <procdump+0x322>
	}
    else{
	cprintf("%d\t%s\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid,  elapsed);
8010589f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a2:	8b 40 14             	mov    0x14(%eax),%eax
801058a5:	8b 58 10             	mov    0x10(%eax),%ebx
801058a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ab:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
801058b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b4:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801058ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bd:	8d 70 6c             	lea    0x6c(%eax),%esi
801058c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c3:	8b 40 10             	mov    0x10(%eax),%eax
801058c6:	83 ec 04             	sub    $0x4,%esp
801058c9:	ff 75 e8             	pushl  -0x18(%ebp)
801058cc:	53                   	push   %ebx
801058cd:	51                   	push   %ecx
801058ce:	52                   	push   %edx
801058cf:	56                   	push   %esi
801058d0:	50                   	push   %eax
801058d1:	68 56 9a 10 80       	push   $0x80109a56
801058d6:	e8 eb aa ff ff       	call   801003c6 <cprintf>
801058db:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
801058de:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
801058e2:	7f 16                	jg     801058fa <procdump+0x271>
	    cprintf("00%d\t%d.", milli, cpue);
801058e4:	83 ec 04             	sub    $0x4,%esp
801058e7:	ff 75 e0             	pushl  -0x20(%ebp)
801058ea:	ff 75 e4             	pushl  -0x1c(%ebp)
801058ed:	68 69 9a 10 80       	push   $0x80109a69
801058f2:	e8 cf aa ff ff       	call   801003c6 <cprintf>
801058f7:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
801058fa:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
801058fe:	7e 1e                	jle    8010591e <procdump+0x295>
80105900:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
80105904:	7f 18                	jg     8010591e <procdump+0x295>
	    cprintf("0%d\t%d.", milli, cpue);
80105906:	83 ec 04             	sub    $0x4,%esp
80105909:	ff 75 e0             	pushl  -0x20(%ebp)
8010590c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010590f:	68 72 9a 10 80       	push   $0x80109a72
80105914:	e8 ad aa ff ff       	call   801003c6 <cprintf>
80105919:	83 c4 10             	add    $0x10,%esp
8010591c:	eb 16                	jmp    80105934 <procdump+0x2ab>
	else
	    cprintf("%d\t%d.", milli, cpue);
8010591e:	83 ec 04             	sub    $0x4,%esp
80105921:	ff 75 e0             	pushl  -0x20(%ebp)
80105924:	ff 75 e4             	pushl  -0x1c(%ebp)
80105927:	68 7a 9a 10 80       	push   $0x80109a7a
8010592c:	e8 95 aa ff ff       	call   801003c6 <cprintf>
80105931:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80105934:	83 7d dc 09          	cmpl   $0x9,-0x24(%ebp)
80105938:	7f 21                	jg     8010595b <procdump+0x2d2>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
8010593a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593d:	8b 00                	mov    (%eax),%eax
8010593f:	83 ec 0c             	sub    $0xc,%esp
80105942:	68 81 9a 10 80       	push   $0x80109a81
80105947:	50                   	push   %eax
80105948:	ff 75 ec             	pushl  -0x14(%ebp)
8010594b:	ff 75 dc             	pushl  -0x24(%ebp)
8010594e:	68 83 9a 10 80       	push   $0x80109a83
80105953:	e8 6e aa ff ff       	call   801003c6 <cprintf>
80105958:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
8010595b:	83 7d dc 09          	cmpl   $0x9,-0x24(%ebp)
8010595f:	7e 29                	jle    8010598a <procdump+0x301>
80105961:	83 7d dc 63          	cmpl   $0x63,-0x24(%ebp)
80105965:	7f 23                	jg     8010598a <procdump+0x301>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105967:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596a:	8b 00                	mov    (%eax),%eax
8010596c:	83 ec 0c             	sub    $0xc,%esp
8010596f:	68 81 9a 10 80       	push   $0x80109a81
80105974:	50                   	push   %eax
80105975:	ff 75 ec             	pushl  -0x14(%ebp)
80105978:	ff 75 dc             	pushl  -0x24(%ebp)
8010597b:	68 8f 9a 10 80       	push   $0x80109a8f
80105980:	e8 41 aa ff ff       	call   801003c6 <cprintf>
80105985:	83 c4 20             	add    $0x20,%esp
80105988:	eb 21                	jmp    801059ab <procdump+0x322>
	else
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
8010598a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598d:	8b 00                	mov    (%eax),%eax
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	68 81 9a 10 80       	push   $0x80109a81
80105997:	50                   	push   %eax
80105998:	ff 75 ec             	pushl  -0x14(%ebp)
8010599b:	ff 75 dc             	pushl  -0x24(%ebp)
8010599e:	68 9a 9a 10 80       	push   $0x80109a9a
801059a3:	e8 1e aa ff ff       	call   801003c6 <cprintf>
801059a8:	83 c4 20             	add    $0x20,%esp
    //cprintf("%d\t%s\t%d\t%d\t%d\t%d.%d\t%d.%d\t%s\t%d\t", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid,  elapsed, milli,cpue,cpum, state, p->sz, "\n");

    #endif


    if(p->state == SLEEPING){
801059ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ae:	8b 40 0c             	mov    0xc(%eax),%eax
801059b1:	83 f8 02             	cmp    $0x2,%eax
801059b4:	75 54                	jne    80105a0a <procdump+0x381>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801059b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b9:	8b 40 1c             	mov    0x1c(%eax),%eax
801059bc:	8b 40 0c             	mov    0xc(%eax),%eax
801059bf:	83 c0 08             	add    $0x8,%eax
801059c2:	89 c2                	mov    %eax,%edx
801059c4:	83 ec 08             	sub    $0x8,%esp
801059c7:	8d 45 b4             	lea    -0x4c(%ebp),%eax
801059ca:	50                   	push   %eax
801059cb:	52                   	push   %edx
801059cc:	e8 1a 05 00 00       	call   80105eeb <getcallerpcs>
801059d1:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801059d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801059db:	eb 1c                	jmp    801059f9 <procdump+0x370>
        cprintf(" %p", pc[i]);
801059dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e0:	8b 44 85 b4          	mov    -0x4c(%ebp,%eax,4),%eax
801059e4:	83 ec 08             	sub    $0x8,%esp
801059e7:	50                   	push   %eax
801059e8:	68 a4 9a 10 80       	push   $0x80109aa4
801059ed:	e8 d4 a9 ff ff       	call   801003c6 <cprintf>
801059f2:	83 c4 10             	add    $0x10,%esp
    #endif


    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801059f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801059f9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801059fd:	7f 0b                	jg     80105a0a <procdump+0x381>
801059ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a02:	8b 44 85 b4          	mov    -0x4c(%ebp,%eax,4),%eax
80105a06:	85 c0                	test   %eax,%eax
80105a08:	75 d3                	jne    801059dd <procdump+0x354>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105a0a:	83 ec 0c             	sub    $0xc,%esp
80105a0d:	68 81 9a 10 80       	push   $0x80109a81
80105a12:	e8 af a9 ff ff       	call   801003c6 <cprintf>
80105a17:	83 c4 10             	add    $0x10,%esp
80105a1a:	eb 01                	jmp    80105a1d <procdump+0x394>


    acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105a1c:	90                   	nop
    cprintf("PID	Name    UID	GID	PPID    Elapsed	CPU	State   Size     PCs\n");
    #endif


    acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a1d:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
80105a24:	81 7d f0 54 63 11 80 	cmpl   $0x80116354,-0x10(%ebp)
80105a2b:	0f 82 93 fc ff ff    	jb     801056c4 <procdump+0x3b>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

    cprintf("\n");
80105a31:	83 ec 0c             	sub    $0xc,%esp
80105a34:	68 81 9a 10 80       	push   $0x80109a81
80105a39:	e8 88 a9 ff ff       	call   801003c6 <cprintf>
80105a3e:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80105a41:	83 ec 0c             	sub    $0xc,%esp
80105a44:	68 80 39 11 80       	push   $0x80113980
80105a49:	e8 4b 04 00 00       	call   80105e99 <release>
80105a4e:	83 c4 10             	add    $0x10,%esp
}
80105a51:	90                   	nop
80105a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105a55:	5b                   	pop    %ebx
80105a56:	5e                   	pop    %esi
80105a57:	5d                   	pop    %ebp
80105a58:	c3                   	ret    

80105a59 <getproctable>:
#ifdef CS333_P2
int 
getproctable(uint max, struct uproc* table)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	53                   	push   %ebx
80105a5d:	83 ec 14             	sub    $0x14,%esp
    int i = 0;
80105a60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);
80105a67:	83 ec 0c             	sub    $0xc,%esp
80105a6a:	68 80 39 11 80       	push   $0x80113980
80105a6f:	e8 be 03 00 00       	call   80105e32 <acquire>
80105a74:	83 c4 10             	add    $0x10,%esp

 // for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
 for(i = 0; i < max; ++i)
80105a77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a7e:	e9 66 01 00 00       	jmp    80105be9 <getproctable+0x190>
 {
     p = &ptable.proc[i];
80105a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a86:	69 c0 94 00 00 00    	imul   $0x94,%eax,%eax
80105a8c:	83 c0 30             	add    $0x30,%eax
80105a8f:	05 80 39 11 80       	add    $0x80113980,%eax
80105a94:	83 c0 04             	add    $0x4,%eax
80105a97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(p -> state == RUNNABLE || p -> state == SLEEPING || p -> state == RUNNING)
80105a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9d:	8b 40 0c             	mov    0xc(%eax),%eax
80105aa0:	83 f8 03             	cmp    $0x3,%eax
80105aa3:	74 1a                	je     80105abf <getproctable+0x66>
80105aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa8:	8b 40 0c             	mov    0xc(%eax),%eax
80105aab:	83 f8 02             	cmp    $0x2,%eax
80105aae:	74 0f                	je     80105abf <getproctable+0x66>
80105ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab3:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab6:	83 f8 04             	cmp    $0x4,%eax
80105ab9:	0f 85 26 01 00 00    	jne    80105be5 <getproctable+0x18c>

	cprintf("%d\n", table[i].uid);

	cprintf("%d\n", table[i].gid);*/
	
	table[i].pid = p -> pid;
80105abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac2:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac8:	01 c2                	add    %eax,%edx
80105aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acd:	8b 40 10             	mov    0x10(%eax),%eax
80105ad0:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
80105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad5:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105adb:	01 c2                	add    %eax,%edx
80105add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105ae6:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
80105ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aec:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105aef:	8b 45 0c             	mov    0xc(%ebp),%eax
80105af2:	01 c2                	add    %eax,%edx
80105af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af7:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105afd:	89 42 08             	mov    %eax,0x8(%edx)

	if(p -> pid == 1)
80105b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b03:	8b 40 10             	mov    0x10(%eax),%eax
80105b06:	83 f8 01             	cmp    $0x1,%eax
80105b09:	75 14                	jne    80105b1f <getproctable+0xc6>
	    table[i].ppid = 1;
80105b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0e:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105b11:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b14:	01 d0                	add    %edx,%eax
80105b16:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
80105b1d:	eb 17                	jmp    80105b36 <getproctable+0xdd>
	else
	    table[i].ppid = p -> parent -> pid;
80105b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b22:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105b25:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b28:	01 c2                	add    %eax,%edx
80105b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2d:	8b 40 14             	mov    0x14(%eax),%eax
80105b30:	8b 40 10             	mov    0x10(%eax),%eax
80105b33:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
80105b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b39:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b3f:	01 c2                	add    %eax,%edx
80105b41:	8b 0d 80 6b 11 80    	mov    0x80116b80,%ecx
80105b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4a:	8b 40 7c             	mov    0x7c(%eax),%eax
80105b4d:	29 c1                	sub    %eax,%ecx
80105b4f:	89 c8                	mov    %ecx,%eax
80105b51:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
80105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b57:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b5d:	01 c2                	add    %eax,%edx
80105b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b62:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105b68:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
80105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6e:	8b 40 0c             	mov    0xc(%eax),%eax
80105b71:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105b78:	83 ec 0c             	sub    $0xc,%esp
80105b7b:	50                   	push   %eax
80105b7c:	e8 61 07 00 00       	call   801062e2 <strlen>
80105b81:	83 c4 10             	add    $0x10,%esp
80105b84:	89 c3                	mov    %eax,%ebx
80105b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b89:	8b 40 0c             	mov    0xc(%eax),%eax
80105b8c:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105b93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b96:	6b ca 5c             	imul   $0x5c,%edx,%ecx
80105b99:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b9c:	01 ca                	add    %ecx,%edx
80105b9e:	83 c2 18             	add    $0x18,%edx
80105ba1:	83 ec 04             	sub    $0x4,%esp
80105ba4:	53                   	push   %ebx
80105ba5:	50                   	push   %eax
80105ba6:	52                   	push   %edx
80105ba7:	e8 ec 06 00 00       	call   80106298 <safestrcpy>
80105bac:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
80105baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb2:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bb8:	01 c2                	add    %eax,%edx
80105bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbd:	8b 00                	mov    (%eax),%eax
80105bbf:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
80105bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc5:	8d 50 6c             	lea    0x6c(%eax),%edx
80105bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcb:	6b c8 5c             	imul   $0x5c,%eax,%ecx
80105bce:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd1:	01 c8                	add    %ecx,%eax
80105bd3:	83 c0 3c             	add    $0x3c,%eax
80105bd6:	83 ec 04             	sub    $0x4,%esp
80105bd9:	6a 20                	push   $0x20
80105bdb:	52                   	push   %edx
80105bdc:	50                   	push   %eax
80105bdd:	e8 b6 06 00 00       	call   80106298 <safestrcpy>
80105be2:	83 c4 10             	add    $0x10,%esp
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);

 // for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
 for(i = 0; i < max; ++i)
80105be5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bec:	3b 45 08             	cmp    0x8(%ebp),%eax
80105bef:	0f 82 8e fe ff ff    	jb     80105a83 <getproctable+0x2a>
	safestrcpy(table[i].name,p -> name, STRMAX);

     }
   }
    //release lock
    release(&ptable.lock);
80105bf5:	83 ec 0c             	sub    $0xc,%esp
80105bf8:	68 80 39 11 80       	push   $0x80113980
80105bfd:	e8 97 02 00 00       	call   80105e99 <release>
80105c02:	83 c4 10             	add    $0x10,%esp
    return i;
80105c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105c0b:	c9                   	leave  
80105c0c:	c3                   	ret    

80105c0d <printready>:
#endif

#ifdef CS333_P3P4
void
printready(void){
80105c0d:	55                   	push   %ebp
80105c0e:	89 e5                	mov    %esp,%ebp
80105c10:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80105c13:	83 ec 0c             	sub    $0xc,%esp
80105c16:	68 80 39 11 80       	push   $0x80113980
80105c1b:	e8 12 02 00 00       	call   80105e32 <acquire>
80105c20:	83 c4 10             	add    $0x10,%esp
    cprintf("Ready List Processes:\n");
80105c23:	83 ec 0c             	sub    $0xc,%esp
80105c26:	68 a8 9a 10 80       	push   $0x80109aa8
80105c2b:	e8 96 a7 ff ff       	call   801003c6 <cprintf>
80105c30:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.ready;
80105c33:	a1 54 63 11 80       	mov    0x80116354,%eax
80105c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
80105c3b:	eb 23                	jmp    80105c60 <printready+0x53>
	cprintf("%d ->", current -> pid);
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	8b 40 10             	mov    0x10(%eax),%eax
80105c43:	83 ec 08             	sub    $0x8,%esp
80105c46:	50                   	push   %eax
80105c47:	68 bf 9a 10 80       	push   $0x80109abf
80105c4c:	e8 75 a7 ff ff       	call   801003c6 <cprintf>
80105c51:	83 c4 10             	add    $0x10,%esp
	current = current -> next;
80105c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c57:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
printready(void){

    acquire(&ptable.lock);
    cprintf("Ready List Processes:\n");
    struct proc * current = ptable.pLists.ready;
    while(current){
80105c60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c64:	75 d7                	jne    80105c3d <printready+0x30>
	cprintf("%d ->", current -> pid);
	current = current -> next;
    }

    release(&ptable.lock);
80105c66:	83 ec 0c             	sub    $0xc,%esp
80105c69:	68 80 39 11 80       	push   $0x80113980
80105c6e:	e8 26 02 00 00       	call   80105e99 <release>
80105c73:	83 c4 10             	add    $0x10,%esp
}
80105c76:	90                   	nop
80105c77:	c9                   	leave  
80105c78:	c3                   	ret    

80105c79 <printfree>:
void
printfree(void){
80105c79:	55                   	push   %ebp
80105c7a:	89 e5                	mov    %esp,%ebp
80105c7c:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80105c7f:	83 ec 0c             	sub    $0xc,%esp
80105c82:	68 80 39 11 80       	push   $0x80113980
80105c87:	e8 a6 01 00 00       	call   80105e32 <acquire>
80105c8c:	83 c4 10             	add    $0x10,%esp
    int free = 0;
80105c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cprintf("Free list size: %d", free);
80105c96:	83 ec 08             	sub    $0x8,%esp
80105c99:	ff 75 f4             	pushl  -0xc(%ebp)
80105c9c:	68 c5 9a 10 80       	push   $0x80109ac5
80105ca1:	e8 20 a7 ff ff       	call   801003c6 <cprintf>
80105ca6:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.free;
80105ca9:	a1 58 63 11 80       	mov    0x80116358,%eax
80105cae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(current){
80105cb1:	eb 10                	jmp    80105cc3 <printfree+0x4a>
	++free;
80105cb3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	current = current -> next;
80105cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cba:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    acquire(&ptable.lock);
    int free = 0;
    cprintf("Free list size: %d", free);
    struct proc * current = ptable.pLists.free;
    while(current){
80105cc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cc7:	75 ea                	jne    80105cb3 <printfree+0x3a>
	++free;
	current = current -> next;
    }

    release(&ptable.lock);
80105cc9:	83 ec 0c             	sub    $0xc,%esp
80105ccc:	68 80 39 11 80       	push   $0x80113980
80105cd1:	e8 c3 01 00 00       	call   80105e99 <release>
80105cd6:	83 c4 10             	add    $0x10,%esp
}
80105cd9:	90                   	nop
80105cda:	c9                   	leave  
80105cdb:	c3                   	ret    

80105cdc <printsleep>:
void
printsleep(void){
80105cdc:	55                   	push   %ebp
80105cdd:	89 e5                	mov    %esp,%ebp
80105cdf:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80105ce2:	83 ec 0c             	sub    $0xc,%esp
80105ce5:	68 80 39 11 80       	push   $0x80113980
80105cea:	e8 43 01 00 00       	call   80105e32 <acquire>
80105cef:	83 c4 10             	add    $0x10,%esp
    cprintf("Sleep List Processes:\n");
80105cf2:	83 ec 0c             	sub    $0xc,%esp
80105cf5:	68 d8 9a 10 80       	push   $0x80109ad8
80105cfa:	e8 c7 a6 ff ff       	call   801003c6 <cprintf>
80105cff:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.sleep;
80105d02:	a1 5c 63 11 80       	mov    0x8011635c,%eax
80105d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
80105d0a:	eb 23                	jmp    80105d2f <printsleep+0x53>
	cprintf("%d ->", current -> pid);
80105d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0f:	8b 40 10             	mov    0x10(%eax),%eax
80105d12:	83 ec 08             	sub    $0x8,%esp
80105d15:	50                   	push   %eax
80105d16:	68 bf 9a 10 80       	push   $0x80109abf
80105d1b:	e8 a6 a6 ff ff       	call   801003c6 <cprintf>
80105d20:	83 c4 10             	add    $0x10,%esp
	current = current -> next;
80105d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d26:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
printsleep(void){

    acquire(&ptable.lock);
    cprintf("Sleep List Processes:\n");
    struct proc * current = ptable.pLists.sleep;
    while(current){
80105d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d33:	75 d7                	jne    80105d0c <printsleep+0x30>
	cprintf("%d ->", current -> pid);
	current = current -> next;
    }

    release(&ptable.lock);
80105d35:	83 ec 0c             	sub    $0xc,%esp
80105d38:	68 80 39 11 80       	push   $0x80113980
80105d3d:	e8 57 01 00 00       	call   80105e99 <release>
80105d42:	83 c4 10             	add    $0x10,%esp
}
80105d45:	90                   	nop
80105d46:	c9                   	leave  
80105d47:	c3                   	ret    

80105d48 <printzombie>:
void
printzombie(void){
80105d48:	55                   	push   %ebp
80105d49:	89 e5                	mov    %esp,%ebp
80105d4b:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80105d4e:	83 ec 0c             	sub    $0xc,%esp
80105d51:	68 80 39 11 80       	push   $0x80113980
80105d56:	e8 d7 00 00 00       	call   80105e32 <acquire>
80105d5b:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.sleep;
80105d5e:	a1 5c 63 11 80       	mov    0x8011635c,%eax
80105d63:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Zombie List Processes:\n");
80105d66:	83 ec 0c             	sub    $0xc,%esp
80105d69:	68 ef 9a 10 80       	push   $0x80109aef
80105d6e:	e8 53 a6 ff ff       	call   801003c6 <cprintf>
80105d73:	83 c4 10             	add    $0x10,%esp
    while(current){
80105d76:	eb 47                	jmp    80105dbf <printzombie+0x77>
    if(current -> pid == 1)
80105d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7b:	8b 40 10             	mov    0x10(%eax),%eax
80105d7e:	83 f8 01             	cmp    $0x1,%eax
80105d81:	75 1b                	jne    80105d9e <printzombie+0x56>
	cprintf("(PID%d, PPID%d) -> ",current -> pid, 1);
80105d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d86:	8b 40 10             	mov    0x10(%eax),%eax
80105d89:	83 ec 04             	sub    $0x4,%esp
80105d8c:	6a 01                	push   $0x1
80105d8e:	50                   	push   %eax
80105d8f:	68 07 9b 10 80       	push   $0x80109b07
80105d94:	e8 2d a6 ff ff       	call   801003c6 <cprintf>
80105d99:	83 c4 10             	add    $0x10,%esp
80105d9c:	eb 21                	jmp    80105dbf <printzombie+0x77>
    else
	cprintf("(PID%d, PPID%d) -> ",current -> pid, current -> parent -> pid);
80105d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da1:	8b 40 14             	mov    0x14(%eax),%eax
80105da4:	8b 50 10             	mov    0x10(%eax),%edx
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	8b 40 10             	mov    0x10(%eax),%eax
80105dad:	83 ec 04             	sub    $0x4,%esp
80105db0:	52                   	push   %edx
80105db1:	50                   	push   %eax
80105db2:	68 07 9b 10 80       	push   $0x80109b07
80105db7:	e8 0a a6 ff ff       	call   801003c6 <cprintf>
80105dbc:	83 c4 10             	add    $0x10,%esp
printzombie(void){

    acquire(&ptable.lock);
    struct proc * current = ptable.pLists.sleep;
    cprintf("Zombie List Processes:\n");
    while(current){
80105dbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc3:	75 b3                	jne    80105d78 <printzombie+0x30>
    if(current -> pid == 1)
	cprintf("(PID%d, PPID%d) -> ",current -> pid, 1);
    else
	cprintf("(PID%d, PPID%d) -> ",current -> pid, current -> parent -> pid);
    }
    release(&ptable.lock);
80105dc5:	83 ec 0c             	sub    $0xc,%esp
80105dc8:	68 80 39 11 80       	push   $0x80113980
80105dcd:	e8 c7 00 00 00       	call   80105e99 <release>
80105dd2:	83 c4 10             	add    $0x10,%esp
}
80105dd5:	90                   	nop
80105dd6:	c9                   	leave  
80105dd7:	c3                   	ret    

80105dd8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105dd8:	55                   	push   %ebp
80105dd9:	89 e5                	mov    %esp,%ebp
80105ddb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105dde:	9c                   	pushf  
80105ddf:	58                   	pop    %eax
80105de0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105de3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105de6:	c9                   	leave  
80105de7:	c3                   	ret    

80105de8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105de8:	55                   	push   %ebp
80105de9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105deb:	fa                   	cli    
}
80105dec:	90                   	nop
80105ded:	5d                   	pop    %ebp
80105dee:	c3                   	ret    

80105def <sti>:

static inline void
sti(void)
{
80105def:	55                   	push   %ebp
80105df0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105df2:	fb                   	sti    
}
80105df3:	90                   	nop
80105df4:	5d                   	pop    %ebp
80105df5:	c3                   	ret    

80105df6 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105df6:	55                   	push   %ebp
80105df7:	89 e5                	mov    %esp,%ebp
80105df9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105dfc:	8b 55 08             	mov    0x8(%ebp),%edx
80105dff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e05:	f0 87 02             	lock xchg %eax,(%edx)
80105e08:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105e0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e0e:	c9                   	leave  
80105e0f:	c3                   	ret    

80105e10 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105e10:	55                   	push   %ebp
80105e11:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105e13:	8b 45 08             	mov    0x8(%ebp),%eax
80105e16:	8b 55 0c             	mov    0xc(%ebp),%edx
80105e19:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105e1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105e25:	8b 45 08             	mov    0x8(%ebp),%eax
80105e28:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105e2f:	90                   	nop
80105e30:	5d                   	pop    %ebp
80105e31:	c3                   	ret    

80105e32 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105e32:	55                   	push   %ebp
80105e33:	89 e5                	mov    %esp,%ebp
80105e35:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105e38:	e8 52 01 00 00       	call   80105f8f <pushcli>
  if(holding(lk))
80105e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105e40:	83 ec 0c             	sub    $0xc,%esp
80105e43:	50                   	push   %eax
80105e44:	e8 1c 01 00 00       	call   80105f65 <holding>
80105e49:	83 c4 10             	add    $0x10,%esp
80105e4c:	85 c0                	test   %eax,%eax
80105e4e:	74 0d                	je     80105e5d <acquire+0x2b>
    panic("acquire");
80105e50:	83 ec 0c             	sub    $0xc,%esp
80105e53:	68 1b 9b 10 80       	push   $0x80109b1b
80105e58:	e8 09 a7 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105e5d:	90                   	nop
80105e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e61:	83 ec 08             	sub    $0x8,%esp
80105e64:	6a 01                	push   $0x1
80105e66:	50                   	push   %eax
80105e67:	e8 8a ff ff ff       	call   80105df6 <xchg>
80105e6c:	83 c4 10             	add    $0x10,%esp
80105e6f:	85 c0                	test   %eax,%eax
80105e71:	75 eb                	jne    80105e5e <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105e73:	8b 45 08             	mov    0x8(%ebp),%eax
80105e76:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105e7d:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105e80:	8b 45 08             	mov    0x8(%ebp),%eax
80105e83:	83 c0 0c             	add    $0xc,%eax
80105e86:	83 ec 08             	sub    $0x8,%esp
80105e89:	50                   	push   %eax
80105e8a:	8d 45 08             	lea    0x8(%ebp),%eax
80105e8d:	50                   	push   %eax
80105e8e:	e8 58 00 00 00       	call   80105eeb <getcallerpcs>
80105e93:	83 c4 10             	add    $0x10,%esp
}
80105e96:	90                   	nop
80105e97:	c9                   	leave  
80105e98:	c3                   	ret    

80105e99 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105e99:	55                   	push   %ebp
80105e9a:	89 e5                	mov    %esp,%ebp
80105e9c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105e9f:	83 ec 0c             	sub    $0xc,%esp
80105ea2:	ff 75 08             	pushl  0x8(%ebp)
80105ea5:	e8 bb 00 00 00       	call   80105f65 <holding>
80105eaa:	83 c4 10             	add    $0x10,%esp
80105ead:	85 c0                	test   %eax,%eax
80105eaf:	75 0d                	jne    80105ebe <release+0x25>
    panic("release");
80105eb1:	83 ec 0c             	sub    $0xc,%esp
80105eb4:	68 23 9b 10 80       	push   $0x80109b23
80105eb9:	e8 a8 a6 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80105ecb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ed5:	83 ec 08             	sub    $0x8,%esp
80105ed8:	6a 00                	push   $0x0
80105eda:	50                   	push   %eax
80105edb:	e8 16 ff ff ff       	call   80105df6 <xchg>
80105ee0:	83 c4 10             	add    $0x10,%esp

  popcli();
80105ee3:	e8 ec 00 00 00       	call   80105fd4 <popcli>
}
80105ee8:	90                   	nop
80105ee9:	c9                   	leave  
80105eea:	c3                   	ret    

80105eeb <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105eeb:	55                   	push   %ebp
80105eec:	89 e5                	mov    %esp,%ebp
80105eee:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ef4:	83 e8 08             	sub    $0x8,%eax
80105ef7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105efa:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105f01:	eb 38                	jmp    80105f3b <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105f03:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105f07:	74 53                	je     80105f5c <getcallerpcs+0x71>
80105f09:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105f10:	76 4a                	jbe    80105f5c <getcallerpcs+0x71>
80105f12:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105f16:	74 44                	je     80105f5c <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105f18:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f25:	01 c2                	add    %eax,%edx
80105f27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f2a:	8b 40 04             	mov    0x4(%eax),%eax
80105f2d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105f2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f32:	8b 00                	mov    (%eax),%eax
80105f34:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105f37:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105f3b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105f3f:	7e c2                	jle    80105f03 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105f41:	eb 19                	jmp    80105f5c <getcallerpcs+0x71>
    pcs[i] = 0;
80105f43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f46:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f50:	01 d0                	add    %edx,%eax
80105f52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105f58:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105f5c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105f60:	7e e1                	jle    80105f43 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105f62:	90                   	nop
80105f63:	c9                   	leave  
80105f64:	c3                   	ret    

80105f65 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105f65:	55                   	push   %ebp
80105f66:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105f68:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6b:	8b 00                	mov    (%eax),%eax
80105f6d:	85 c0                	test   %eax,%eax
80105f6f:	74 17                	je     80105f88 <holding+0x23>
80105f71:	8b 45 08             	mov    0x8(%ebp),%eax
80105f74:	8b 50 08             	mov    0x8(%eax),%edx
80105f77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f7d:	39 c2                	cmp    %eax,%edx
80105f7f:	75 07                	jne    80105f88 <holding+0x23>
80105f81:	b8 01 00 00 00       	mov    $0x1,%eax
80105f86:	eb 05                	jmp    80105f8d <holding+0x28>
80105f88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f8d:	5d                   	pop    %ebp
80105f8e:	c3                   	ret    

80105f8f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105f8f:	55                   	push   %ebp
80105f90:	89 e5                	mov    %esp,%ebp
80105f92:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105f95:	e8 3e fe ff ff       	call   80105dd8 <readeflags>
80105f9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105f9d:	e8 46 fe ff ff       	call   80105de8 <cli>
  if(cpu->ncli++ == 0)
80105fa2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105fa9:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105faf:	8d 48 01             	lea    0x1(%eax),%ecx
80105fb2:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105fb8:	85 c0                	test   %eax,%eax
80105fba:	75 15                	jne    80105fd1 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105fbc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105fc2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105fc5:	81 e2 00 02 00 00    	and    $0x200,%edx
80105fcb:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105fd1:	90                   	nop
80105fd2:	c9                   	leave  
80105fd3:	c3                   	ret    

80105fd4 <popcli>:

void
popcli(void)
{
80105fd4:	55                   	push   %ebp
80105fd5:	89 e5                	mov    %esp,%ebp
80105fd7:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105fda:	e8 f9 fd ff ff       	call   80105dd8 <readeflags>
80105fdf:	25 00 02 00 00       	and    $0x200,%eax
80105fe4:	85 c0                	test   %eax,%eax
80105fe6:	74 0d                	je     80105ff5 <popcli+0x21>
    panic("popcli - interruptible");
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	68 2b 9b 10 80       	push   $0x80109b2b
80105ff0:	e8 71 a5 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105ff5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ffb:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106001:	83 ea 01             	sub    $0x1,%edx
80106004:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010600a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106010:	85 c0                	test   %eax,%eax
80106012:	79 0d                	jns    80106021 <popcli+0x4d>
    panic("popcli");
80106014:	83 ec 0c             	sub    $0xc,%esp
80106017:	68 42 9b 10 80       	push   $0x80109b42
8010601c:	e8 45 a5 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106021:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106027:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010602d:	85 c0                	test   %eax,%eax
8010602f:	75 15                	jne    80106046 <popcli+0x72>
80106031:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106037:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010603d:	85 c0                	test   %eax,%eax
8010603f:	74 05                	je     80106046 <popcli+0x72>
    sti();
80106041:	e8 a9 fd ff ff       	call   80105def <sti>
}
80106046:	90                   	nop
80106047:	c9                   	leave  
80106048:	c3                   	ret    

80106049 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106049:	55                   	push   %ebp
8010604a:	89 e5                	mov    %esp,%ebp
8010604c:	57                   	push   %edi
8010604d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010604e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106051:	8b 55 10             	mov    0x10(%ebp),%edx
80106054:	8b 45 0c             	mov    0xc(%ebp),%eax
80106057:	89 cb                	mov    %ecx,%ebx
80106059:	89 df                	mov    %ebx,%edi
8010605b:	89 d1                	mov    %edx,%ecx
8010605d:	fc                   	cld    
8010605e:	f3 aa                	rep stos %al,%es:(%edi)
80106060:	89 ca                	mov    %ecx,%edx
80106062:	89 fb                	mov    %edi,%ebx
80106064:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106067:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010606a:	90                   	nop
8010606b:	5b                   	pop    %ebx
8010606c:	5f                   	pop    %edi
8010606d:	5d                   	pop    %ebp
8010606e:	c3                   	ret    

8010606f <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010606f:	55                   	push   %ebp
80106070:	89 e5                	mov    %esp,%ebp
80106072:	57                   	push   %edi
80106073:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106074:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106077:	8b 55 10             	mov    0x10(%ebp),%edx
8010607a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010607d:	89 cb                	mov    %ecx,%ebx
8010607f:	89 df                	mov    %ebx,%edi
80106081:	89 d1                	mov    %edx,%ecx
80106083:	fc                   	cld    
80106084:	f3 ab                	rep stos %eax,%es:(%edi)
80106086:	89 ca                	mov    %ecx,%edx
80106088:	89 fb                	mov    %edi,%ebx
8010608a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010608d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106090:	90                   	nop
80106091:	5b                   	pop    %ebx
80106092:	5f                   	pop    %edi
80106093:	5d                   	pop    %ebp
80106094:	c3                   	ret    

80106095 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106095:	55                   	push   %ebp
80106096:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106098:	8b 45 08             	mov    0x8(%ebp),%eax
8010609b:	83 e0 03             	and    $0x3,%eax
8010609e:	85 c0                	test   %eax,%eax
801060a0:	75 43                	jne    801060e5 <memset+0x50>
801060a2:	8b 45 10             	mov    0x10(%ebp),%eax
801060a5:	83 e0 03             	and    $0x3,%eax
801060a8:	85 c0                	test   %eax,%eax
801060aa:	75 39                	jne    801060e5 <memset+0x50>
    c &= 0xFF;
801060ac:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801060b3:	8b 45 10             	mov    0x10(%ebp),%eax
801060b6:	c1 e8 02             	shr    $0x2,%eax
801060b9:	89 c1                	mov    %eax,%ecx
801060bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801060be:	c1 e0 18             	shl    $0x18,%eax
801060c1:	89 c2                	mov    %eax,%edx
801060c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060c6:	c1 e0 10             	shl    $0x10,%eax
801060c9:	09 c2                	or     %eax,%edx
801060cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ce:	c1 e0 08             	shl    $0x8,%eax
801060d1:	09 d0                	or     %edx,%eax
801060d3:	0b 45 0c             	or     0xc(%ebp),%eax
801060d6:	51                   	push   %ecx
801060d7:	50                   	push   %eax
801060d8:	ff 75 08             	pushl  0x8(%ebp)
801060db:	e8 8f ff ff ff       	call   8010606f <stosl>
801060e0:	83 c4 0c             	add    $0xc,%esp
801060e3:	eb 12                	jmp    801060f7 <memset+0x62>
  } else
    stosb(dst, c, n);
801060e5:	8b 45 10             	mov    0x10(%ebp),%eax
801060e8:	50                   	push   %eax
801060e9:	ff 75 0c             	pushl  0xc(%ebp)
801060ec:	ff 75 08             	pushl  0x8(%ebp)
801060ef:	e8 55 ff ff ff       	call   80106049 <stosb>
801060f4:	83 c4 0c             	add    $0xc,%esp
  return dst;
801060f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801060fa:	c9                   	leave  
801060fb:	c3                   	ret    

801060fc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801060fc:	55                   	push   %ebp
801060fd:	89 e5                	mov    %esp,%ebp
801060ff:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106102:	8b 45 08             	mov    0x8(%ebp),%eax
80106105:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106108:	8b 45 0c             	mov    0xc(%ebp),%eax
8010610b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010610e:	eb 30                	jmp    80106140 <memcmp+0x44>
    if(*s1 != *s2)
80106110:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106113:	0f b6 10             	movzbl (%eax),%edx
80106116:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106119:	0f b6 00             	movzbl (%eax),%eax
8010611c:	38 c2                	cmp    %al,%dl
8010611e:	74 18                	je     80106138 <memcmp+0x3c>
      return *s1 - *s2;
80106120:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106123:	0f b6 00             	movzbl (%eax),%eax
80106126:	0f b6 d0             	movzbl %al,%edx
80106129:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010612c:	0f b6 00             	movzbl (%eax),%eax
8010612f:	0f b6 c0             	movzbl %al,%eax
80106132:	29 c2                	sub    %eax,%edx
80106134:	89 d0                	mov    %edx,%eax
80106136:	eb 1a                	jmp    80106152 <memcmp+0x56>
    s1++, s2++;
80106138:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010613c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106140:	8b 45 10             	mov    0x10(%ebp),%eax
80106143:	8d 50 ff             	lea    -0x1(%eax),%edx
80106146:	89 55 10             	mov    %edx,0x10(%ebp)
80106149:	85 c0                	test   %eax,%eax
8010614b:	75 c3                	jne    80106110 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010614d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106152:	c9                   	leave  
80106153:	c3                   	ret    

80106154 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106154:	55                   	push   %ebp
80106155:	89 e5                	mov    %esp,%ebp
80106157:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010615a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010615d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106160:	8b 45 08             	mov    0x8(%ebp),%eax
80106163:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106166:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106169:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010616c:	73 54                	jae    801061c2 <memmove+0x6e>
8010616e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106171:	8b 45 10             	mov    0x10(%ebp),%eax
80106174:	01 d0                	add    %edx,%eax
80106176:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106179:	76 47                	jbe    801061c2 <memmove+0x6e>
    s += n;
8010617b:	8b 45 10             	mov    0x10(%ebp),%eax
8010617e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106181:	8b 45 10             	mov    0x10(%ebp),%eax
80106184:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106187:	eb 13                	jmp    8010619c <memmove+0x48>
      *--d = *--s;
80106189:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010618d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106191:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106194:	0f b6 10             	movzbl (%eax),%edx
80106197:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010619a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010619c:	8b 45 10             	mov    0x10(%ebp),%eax
8010619f:	8d 50 ff             	lea    -0x1(%eax),%edx
801061a2:	89 55 10             	mov    %edx,0x10(%ebp)
801061a5:	85 c0                	test   %eax,%eax
801061a7:	75 e0                	jne    80106189 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801061a9:	eb 24                	jmp    801061cf <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801061ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
801061ae:	8d 50 01             	lea    0x1(%eax),%edx
801061b1:	89 55 f8             	mov    %edx,-0x8(%ebp)
801061b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061b7:	8d 4a 01             	lea    0x1(%edx),%ecx
801061ba:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801061bd:	0f b6 12             	movzbl (%edx),%edx
801061c0:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801061c2:	8b 45 10             	mov    0x10(%ebp),%eax
801061c5:	8d 50 ff             	lea    -0x1(%eax),%edx
801061c8:	89 55 10             	mov    %edx,0x10(%ebp)
801061cb:	85 c0                	test   %eax,%eax
801061cd:	75 dc                	jne    801061ab <memmove+0x57>
      *d++ = *s++;

  return dst;
801061cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801061d2:	c9                   	leave  
801061d3:	c3                   	ret    

801061d4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801061d4:	55                   	push   %ebp
801061d5:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801061d7:	ff 75 10             	pushl  0x10(%ebp)
801061da:	ff 75 0c             	pushl  0xc(%ebp)
801061dd:	ff 75 08             	pushl  0x8(%ebp)
801061e0:	e8 6f ff ff ff       	call   80106154 <memmove>
801061e5:	83 c4 0c             	add    $0xc,%esp
}
801061e8:	c9                   	leave  
801061e9:	c3                   	ret    

801061ea <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801061ea:	55                   	push   %ebp
801061eb:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801061ed:	eb 0c                	jmp    801061fb <strncmp+0x11>
    n--, p++, q++;
801061ef:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801061f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801061f7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801061fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801061ff:	74 1a                	je     8010621b <strncmp+0x31>
80106201:	8b 45 08             	mov    0x8(%ebp),%eax
80106204:	0f b6 00             	movzbl (%eax),%eax
80106207:	84 c0                	test   %al,%al
80106209:	74 10                	je     8010621b <strncmp+0x31>
8010620b:	8b 45 08             	mov    0x8(%ebp),%eax
8010620e:	0f b6 10             	movzbl (%eax),%edx
80106211:	8b 45 0c             	mov    0xc(%ebp),%eax
80106214:	0f b6 00             	movzbl (%eax),%eax
80106217:	38 c2                	cmp    %al,%dl
80106219:	74 d4                	je     801061ef <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010621b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010621f:	75 07                	jne    80106228 <strncmp+0x3e>
    return 0;
80106221:	b8 00 00 00 00       	mov    $0x0,%eax
80106226:	eb 16                	jmp    8010623e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106228:	8b 45 08             	mov    0x8(%ebp),%eax
8010622b:	0f b6 00             	movzbl (%eax),%eax
8010622e:	0f b6 d0             	movzbl %al,%edx
80106231:	8b 45 0c             	mov    0xc(%ebp),%eax
80106234:	0f b6 00             	movzbl (%eax),%eax
80106237:	0f b6 c0             	movzbl %al,%eax
8010623a:	29 c2                	sub    %eax,%edx
8010623c:	89 d0                	mov    %edx,%eax
}
8010623e:	5d                   	pop    %ebp
8010623f:	c3                   	ret    

80106240 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106240:	55                   	push   %ebp
80106241:	89 e5                	mov    %esp,%ebp
80106243:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106246:	8b 45 08             	mov    0x8(%ebp),%eax
80106249:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010624c:	90                   	nop
8010624d:	8b 45 10             	mov    0x10(%ebp),%eax
80106250:	8d 50 ff             	lea    -0x1(%eax),%edx
80106253:	89 55 10             	mov    %edx,0x10(%ebp)
80106256:	85 c0                	test   %eax,%eax
80106258:	7e 2c                	jle    80106286 <strncpy+0x46>
8010625a:	8b 45 08             	mov    0x8(%ebp),%eax
8010625d:	8d 50 01             	lea    0x1(%eax),%edx
80106260:	89 55 08             	mov    %edx,0x8(%ebp)
80106263:	8b 55 0c             	mov    0xc(%ebp),%edx
80106266:	8d 4a 01             	lea    0x1(%edx),%ecx
80106269:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010626c:	0f b6 12             	movzbl (%edx),%edx
8010626f:	88 10                	mov    %dl,(%eax)
80106271:	0f b6 00             	movzbl (%eax),%eax
80106274:	84 c0                	test   %al,%al
80106276:	75 d5                	jne    8010624d <strncpy+0xd>
    ;
  while(n-- > 0)
80106278:	eb 0c                	jmp    80106286 <strncpy+0x46>
    *s++ = 0;
8010627a:	8b 45 08             	mov    0x8(%ebp),%eax
8010627d:	8d 50 01             	lea    0x1(%eax),%edx
80106280:	89 55 08             	mov    %edx,0x8(%ebp)
80106283:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106286:	8b 45 10             	mov    0x10(%ebp),%eax
80106289:	8d 50 ff             	lea    -0x1(%eax),%edx
8010628c:	89 55 10             	mov    %edx,0x10(%ebp)
8010628f:	85 c0                	test   %eax,%eax
80106291:	7f e7                	jg     8010627a <strncpy+0x3a>
    *s++ = 0;
  return os;
80106293:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106296:	c9                   	leave  
80106297:	c3                   	ret    

80106298 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106298:	55                   	push   %ebp
80106299:	89 e5                	mov    %esp,%ebp
8010629b:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010629e:	8b 45 08             	mov    0x8(%ebp),%eax
801062a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801062a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062a8:	7f 05                	jg     801062af <safestrcpy+0x17>
    return os;
801062aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062ad:	eb 31                	jmp    801062e0 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801062af:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801062b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062b7:	7e 1e                	jle    801062d7 <safestrcpy+0x3f>
801062b9:	8b 45 08             	mov    0x8(%ebp),%eax
801062bc:	8d 50 01             	lea    0x1(%eax),%edx
801062bf:	89 55 08             	mov    %edx,0x8(%ebp)
801062c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801062c5:	8d 4a 01             	lea    0x1(%edx),%ecx
801062c8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801062cb:	0f b6 12             	movzbl (%edx),%edx
801062ce:	88 10                	mov    %dl,(%eax)
801062d0:	0f b6 00             	movzbl (%eax),%eax
801062d3:	84 c0                	test   %al,%al
801062d5:	75 d8                	jne    801062af <safestrcpy+0x17>
    ;
  *s = 0;
801062d7:	8b 45 08             	mov    0x8(%ebp),%eax
801062da:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801062dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062e0:	c9                   	leave  
801062e1:	c3                   	ret    

801062e2 <strlen>:

int
strlen(const char *s)
{
801062e2:	55                   	push   %ebp
801062e3:	89 e5                	mov    %esp,%ebp
801062e5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801062e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062ef:	eb 04                	jmp    801062f5 <strlen+0x13>
801062f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062f8:	8b 45 08             	mov    0x8(%ebp),%eax
801062fb:	01 d0                	add    %edx,%eax
801062fd:	0f b6 00             	movzbl (%eax),%eax
80106300:	84 c0                	test   %al,%al
80106302:	75 ed                	jne    801062f1 <strlen+0xf>
    ;
  return n;
80106304:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106307:	c9                   	leave  
80106308:	c3                   	ret    

80106309 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106309:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010630d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106311:	55                   	push   %ebp
  pushl %ebx
80106312:	53                   	push   %ebx
  pushl %esi
80106313:	56                   	push   %esi
  pushl %edi
80106314:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106315:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106317:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106319:	5f                   	pop    %edi
  popl %esi
8010631a:	5e                   	pop    %esi
  popl %ebx
8010631b:	5b                   	pop    %ebx
  popl %ebp
8010631c:	5d                   	pop    %ebp
  ret
8010631d:	c3                   	ret    

8010631e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010631e:	55                   	push   %ebp
8010631f:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106321:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106327:	8b 00                	mov    (%eax),%eax
80106329:	3b 45 08             	cmp    0x8(%ebp),%eax
8010632c:	76 12                	jbe    80106340 <fetchint+0x22>
8010632e:	8b 45 08             	mov    0x8(%ebp),%eax
80106331:	8d 50 04             	lea    0x4(%eax),%edx
80106334:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010633a:	8b 00                	mov    (%eax),%eax
8010633c:	39 c2                	cmp    %eax,%edx
8010633e:	76 07                	jbe    80106347 <fetchint+0x29>
    return -1;
80106340:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106345:	eb 0f                	jmp    80106356 <fetchint+0x38>
  *ip = *(int*)(addr);
80106347:	8b 45 08             	mov    0x8(%ebp),%eax
8010634a:	8b 10                	mov    (%eax),%edx
8010634c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010634f:	89 10                	mov    %edx,(%eax)
  return 0;
80106351:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106356:	5d                   	pop    %ebp
80106357:	c3                   	ret    

80106358 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106358:	55                   	push   %ebp
80106359:	89 e5                	mov    %esp,%ebp
8010635b:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010635e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106364:	8b 00                	mov    (%eax),%eax
80106366:	3b 45 08             	cmp    0x8(%ebp),%eax
80106369:	77 07                	ja     80106372 <fetchstr+0x1a>
    return -1;
8010636b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106370:	eb 46                	jmp    801063b8 <fetchstr+0x60>
  *pp = (char*)addr;
80106372:	8b 55 08             	mov    0x8(%ebp),%edx
80106375:	8b 45 0c             	mov    0xc(%ebp),%eax
80106378:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010637a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106380:	8b 00                	mov    (%eax),%eax
80106382:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106385:	8b 45 0c             	mov    0xc(%ebp),%eax
80106388:	8b 00                	mov    (%eax),%eax
8010638a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010638d:	eb 1c                	jmp    801063ab <fetchstr+0x53>
    if(*s == 0)
8010638f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106392:	0f b6 00             	movzbl (%eax),%eax
80106395:	84 c0                	test   %al,%al
80106397:	75 0e                	jne    801063a7 <fetchstr+0x4f>
      return s - *pp;
80106399:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010639c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010639f:	8b 00                	mov    (%eax),%eax
801063a1:	29 c2                	sub    %eax,%edx
801063a3:	89 d0                	mov    %edx,%eax
801063a5:	eb 11                	jmp    801063b8 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801063a7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801063ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801063ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801063b1:	72 dc                	jb     8010638f <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801063b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801063b8:	c9                   	leave  
801063b9:	c3                   	ret    

801063ba <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801063ba:	55                   	push   %ebp
801063bb:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801063bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063c3:	8b 40 18             	mov    0x18(%eax),%eax
801063c6:	8b 40 44             	mov    0x44(%eax),%eax
801063c9:	8b 55 08             	mov    0x8(%ebp),%edx
801063cc:	c1 e2 02             	shl    $0x2,%edx
801063cf:	01 d0                	add    %edx,%eax
801063d1:	83 c0 04             	add    $0x4,%eax
801063d4:	ff 75 0c             	pushl  0xc(%ebp)
801063d7:	50                   	push   %eax
801063d8:	e8 41 ff ff ff       	call   8010631e <fetchint>
801063dd:	83 c4 08             	add    $0x8,%esp
}
801063e0:	c9                   	leave  
801063e1:	c3                   	ret    

801063e2 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801063e2:	55                   	push   %ebp
801063e3:	89 e5                	mov    %esp,%ebp
801063e5:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801063e8:	8d 45 fc             	lea    -0x4(%ebp),%eax
801063eb:	50                   	push   %eax
801063ec:	ff 75 08             	pushl  0x8(%ebp)
801063ef:	e8 c6 ff ff ff       	call   801063ba <argint>
801063f4:	83 c4 08             	add    $0x8,%esp
801063f7:	85 c0                	test   %eax,%eax
801063f9:	79 07                	jns    80106402 <argptr+0x20>
    return -1;
801063fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106400:	eb 3b                	jmp    8010643d <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106402:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106408:	8b 00                	mov    (%eax),%eax
8010640a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010640d:	39 d0                	cmp    %edx,%eax
8010640f:	76 16                	jbe    80106427 <argptr+0x45>
80106411:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106414:	89 c2                	mov    %eax,%edx
80106416:	8b 45 10             	mov    0x10(%ebp),%eax
80106419:	01 c2                	add    %eax,%edx
8010641b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106421:	8b 00                	mov    (%eax),%eax
80106423:	39 c2                	cmp    %eax,%edx
80106425:	76 07                	jbe    8010642e <argptr+0x4c>
    return -1;
80106427:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642c:	eb 0f                	jmp    8010643d <argptr+0x5b>
  *pp = (char*)i;
8010642e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106431:	89 c2                	mov    %eax,%edx
80106433:	8b 45 0c             	mov    0xc(%ebp),%eax
80106436:	89 10                	mov    %edx,(%eax)
  return 0;
80106438:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010643d:	c9                   	leave  
8010643e:	c3                   	ret    

8010643f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010643f:	55                   	push   %ebp
80106440:	89 e5                	mov    %esp,%ebp
80106442:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106445:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106448:	50                   	push   %eax
80106449:	ff 75 08             	pushl  0x8(%ebp)
8010644c:	e8 69 ff ff ff       	call   801063ba <argint>
80106451:	83 c4 08             	add    $0x8,%esp
80106454:	85 c0                	test   %eax,%eax
80106456:	79 07                	jns    8010645f <argstr+0x20>
    return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	eb 0f                	jmp    8010646e <argstr+0x2f>
  return fetchstr(addr, pp);
8010645f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106462:	ff 75 0c             	pushl  0xc(%ebp)
80106465:	50                   	push   %eax
80106466:	e8 ed fe ff ff       	call   80106358 <fetchstr>
8010646b:	83 c4 08             	add    $0x8,%esp
}
8010646e:	c9                   	leave  
8010646f:	c3                   	ret    

80106470 <syscall>:
// put data structure for printing out system call invocation information here

#endif
void
syscall(void)
{
80106470:	55                   	push   %ebp
80106471:	89 e5                	mov    %esp,%ebp
80106473:	53                   	push   %ebx
80106474:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106477:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010647d:	8b 40 18             	mov    0x18(%eax),%eax
80106480:	8b 40 1c             	mov    0x1c(%eax),%eax
80106483:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106486:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010648a:	7e 30                	jle    801064bc <syscall+0x4c>
8010648c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648f:	83 f8 1c             	cmp    $0x1c,%eax
80106492:	77 28                	ja     801064bc <syscall+0x4c>
80106494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106497:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010649e:	85 c0                	test   %eax,%eax
801064a0:	74 1a                	je     801064bc <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801064a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064a8:	8b 58 18             	mov    0x18(%eax),%ebx
801064ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ae:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801064b5:	ff d0                	call   *%eax
801064b7:	89 43 1c             	mov    %eax,0x1c(%ebx)
801064ba:	eb 34                	jmp    801064f0 <syscall+0x80>
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801064bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064c2:	8d 50 6c             	lea    0x6c(%eax),%edx
801064c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
#ifdef PRINT_SYSCALLS
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801064cb:	8b 40 10             	mov    0x10(%eax),%eax
801064ce:	ff 75 f4             	pushl  -0xc(%ebp)
801064d1:	52                   	push   %edx
801064d2:	50                   	push   %eax
801064d3:	68 49 9b 10 80       	push   $0x80109b49
801064d8:	e8 e9 9e ff ff       	call   801003c6 <cprintf>
801064dd:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801064e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064e6:	8b 40 18             	mov    0x18(%eax),%eax
801064e9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801064f0:	90                   	nop
801064f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801064f4:	c9                   	leave  
801064f5:	c3                   	ret    

801064f6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801064f6:	55                   	push   %ebp
801064f7:	89 e5                	mov    %esp,%ebp
801064f9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801064fc:	83 ec 08             	sub    $0x8,%esp
801064ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106502:	50                   	push   %eax
80106503:	ff 75 08             	pushl  0x8(%ebp)
80106506:	e8 af fe ff ff       	call   801063ba <argint>
8010650b:	83 c4 10             	add    $0x10,%esp
8010650e:	85 c0                	test   %eax,%eax
80106510:	79 07                	jns    80106519 <argfd+0x23>
    return -1;
80106512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106517:	eb 50                	jmp    80106569 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651c:	85 c0                	test   %eax,%eax
8010651e:	78 21                	js     80106541 <argfd+0x4b>
80106520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106523:	83 f8 0f             	cmp    $0xf,%eax
80106526:	7f 19                	jg     80106541 <argfd+0x4b>
80106528:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106531:	83 c2 08             	add    $0x8,%edx
80106534:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106538:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010653b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010653f:	75 07                	jne    80106548 <argfd+0x52>
    return -1;
80106541:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106546:	eb 21                	jmp    80106569 <argfd+0x73>
  if(pfd)
80106548:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010654c:	74 08                	je     80106556 <argfd+0x60>
    *pfd = fd;
8010654e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106551:	8b 45 0c             	mov    0xc(%ebp),%eax
80106554:	89 10                	mov    %edx,(%eax)
  if(pf)
80106556:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010655a:	74 08                	je     80106564 <argfd+0x6e>
    *pf = f;
8010655c:	8b 45 10             	mov    0x10(%ebp),%eax
8010655f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106562:	89 10                	mov    %edx,(%eax)
  return 0;
80106564:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106569:	c9                   	leave  
8010656a:	c3                   	ret    

8010656b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010656b:	55                   	push   %ebp
8010656c:	89 e5                	mov    %esp,%ebp
8010656e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106571:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106578:	eb 30                	jmp    801065aa <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010657a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106580:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106583:	83 c2 08             	add    $0x8,%edx
80106586:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010658a:	85 c0                	test   %eax,%eax
8010658c:	75 18                	jne    801065a6 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010658e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106594:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106597:	8d 4a 08             	lea    0x8(%edx),%ecx
8010659a:	8b 55 08             	mov    0x8(%ebp),%edx
8010659d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801065a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801065a4:	eb 0f                	jmp    801065b5 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801065a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801065aa:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801065ae:	7e ca                	jle    8010657a <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801065b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065b5:	c9                   	leave  
801065b6:	c3                   	ret    

801065b7 <sys_dup>:

int
sys_dup(void)
{
801065b7:	55                   	push   %ebp
801065b8:	89 e5                	mov    %esp,%ebp
801065ba:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801065bd:	83 ec 04             	sub    $0x4,%esp
801065c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065c3:	50                   	push   %eax
801065c4:	6a 00                	push   $0x0
801065c6:	6a 00                	push   $0x0
801065c8:	e8 29 ff ff ff       	call   801064f6 <argfd>
801065cd:	83 c4 10             	add    $0x10,%esp
801065d0:	85 c0                	test   %eax,%eax
801065d2:	79 07                	jns    801065db <sys_dup+0x24>
    return -1;
801065d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d9:	eb 31                	jmp    8010660c <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801065db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065de:	83 ec 0c             	sub    $0xc,%esp
801065e1:	50                   	push   %eax
801065e2:	e8 84 ff ff ff       	call   8010656b <fdalloc>
801065e7:	83 c4 10             	add    $0x10,%esp
801065ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065f1:	79 07                	jns    801065fa <sys_dup+0x43>
    return -1;
801065f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f8:	eb 12                	jmp    8010660c <sys_dup+0x55>
  filedup(f);
801065fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fd:	83 ec 0c             	sub    $0xc,%esp
80106600:	50                   	push   %eax
80106601:	e8 a4 aa ff ff       	call   801010aa <filedup>
80106606:	83 c4 10             	add    $0x10,%esp
  return fd;
80106609:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010660c:	c9                   	leave  
8010660d:	c3                   	ret    

8010660e <sys_read>:

int
sys_read(void)
{
8010660e:	55                   	push   %ebp
8010660f:	89 e5                	mov    %esp,%ebp
80106611:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106614:	83 ec 04             	sub    $0x4,%esp
80106617:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010661a:	50                   	push   %eax
8010661b:	6a 00                	push   $0x0
8010661d:	6a 00                	push   $0x0
8010661f:	e8 d2 fe ff ff       	call   801064f6 <argfd>
80106624:	83 c4 10             	add    $0x10,%esp
80106627:	85 c0                	test   %eax,%eax
80106629:	78 2e                	js     80106659 <sys_read+0x4b>
8010662b:	83 ec 08             	sub    $0x8,%esp
8010662e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106631:	50                   	push   %eax
80106632:	6a 02                	push   $0x2
80106634:	e8 81 fd ff ff       	call   801063ba <argint>
80106639:	83 c4 10             	add    $0x10,%esp
8010663c:	85 c0                	test   %eax,%eax
8010663e:	78 19                	js     80106659 <sys_read+0x4b>
80106640:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106643:	83 ec 04             	sub    $0x4,%esp
80106646:	50                   	push   %eax
80106647:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010664a:	50                   	push   %eax
8010664b:	6a 01                	push   $0x1
8010664d:	e8 90 fd ff ff       	call   801063e2 <argptr>
80106652:	83 c4 10             	add    $0x10,%esp
80106655:	85 c0                	test   %eax,%eax
80106657:	79 07                	jns    80106660 <sys_read+0x52>
    return -1;
80106659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665e:	eb 17                	jmp    80106677 <sys_read+0x69>
  return fileread(f, p, n);
80106660:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106663:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106669:	83 ec 04             	sub    $0x4,%esp
8010666c:	51                   	push   %ecx
8010666d:	52                   	push   %edx
8010666e:	50                   	push   %eax
8010666f:	e8 c6 ab ff ff       	call   8010123a <fileread>
80106674:	83 c4 10             	add    $0x10,%esp
}
80106677:	c9                   	leave  
80106678:	c3                   	ret    

80106679 <sys_write>:

int
sys_write(void)
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010667f:	83 ec 04             	sub    $0x4,%esp
80106682:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106685:	50                   	push   %eax
80106686:	6a 00                	push   $0x0
80106688:	6a 00                	push   $0x0
8010668a:	e8 67 fe ff ff       	call   801064f6 <argfd>
8010668f:	83 c4 10             	add    $0x10,%esp
80106692:	85 c0                	test   %eax,%eax
80106694:	78 2e                	js     801066c4 <sys_write+0x4b>
80106696:	83 ec 08             	sub    $0x8,%esp
80106699:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010669c:	50                   	push   %eax
8010669d:	6a 02                	push   $0x2
8010669f:	e8 16 fd ff ff       	call   801063ba <argint>
801066a4:	83 c4 10             	add    $0x10,%esp
801066a7:	85 c0                	test   %eax,%eax
801066a9:	78 19                	js     801066c4 <sys_write+0x4b>
801066ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ae:	83 ec 04             	sub    $0x4,%esp
801066b1:	50                   	push   %eax
801066b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066b5:	50                   	push   %eax
801066b6:	6a 01                	push   $0x1
801066b8:	e8 25 fd ff ff       	call   801063e2 <argptr>
801066bd:	83 c4 10             	add    $0x10,%esp
801066c0:	85 c0                	test   %eax,%eax
801066c2:	79 07                	jns    801066cb <sys_write+0x52>
    return -1;
801066c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c9:	eb 17                	jmp    801066e2 <sys_write+0x69>
  return filewrite(f, p, n);
801066cb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801066ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
801066d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d4:	83 ec 04             	sub    $0x4,%esp
801066d7:	51                   	push   %ecx
801066d8:	52                   	push   %edx
801066d9:	50                   	push   %eax
801066da:	e8 13 ac ff ff       	call   801012f2 <filewrite>
801066df:	83 c4 10             	add    $0x10,%esp
}
801066e2:	c9                   	leave  
801066e3:	c3                   	ret    

801066e4 <sys_close>:

int
sys_close(void)
{
801066e4:	55                   	push   %ebp
801066e5:	89 e5                	mov    %esp,%ebp
801066e7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801066ea:	83 ec 04             	sub    $0x4,%esp
801066ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066f0:	50                   	push   %eax
801066f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066f4:	50                   	push   %eax
801066f5:	6a 00                	push   $0x0
801066f7:	e8 fa fd ff ff       	call   801064f6 <argfd>
801066fc:	83 c4 10             	add    $0x10,%esp
801066ff:	85 c0                	test   %eax,%eax
80106701:	79 07                	jns    8010670a <sys_close+0x26>
    return -1;
80106703:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106708:	eb 28                	jmp    80106732 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010670a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106710:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106713:	83 c2 08             	add    $0x8,%edx
80106716:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010671d:	00 
  fileclose(f);
8010671e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106721:	83 ec 0c             	sub    $0xc,%esp
80106724:	50                   	push   %eax
80106725:	e8 d1 a9 ff ff       	call   801010fb <fileclose>
8010672a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010672d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106732:	c9                   	leave  
80106733:	c3                   	ret    

80106734 <sys_fstat>:

int
sys_fstat(void)
{
80106734:	55                   	push   %ebp
80106735:	89 e5                	mov    %esp,%ebp
80106737:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010673a:	83 ec 04             	sub    $0x4,%esp
8010673d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106740:	50                   	push   %eax
80106741:	6a 00                	push   $0x0
80106743:	6a 00                	push   $0x0
80106745:	e8 ac fd ff ff       	call   801064f6 <argfd>
8010674a:	83 c4 10             	add    $0x10,%esp
8010674d:	85 c0                	test   %eax,%eax
8010674f:	78 17                	js     80106768 <sys_fstat+0x34>
80106751:	83 ec 04             	sub    $0x4,%esp
80106754:	6a 14                	push   $0x14
80106756:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106759:	50                   	push   %eax
8010675a:	6a 01                	push   $0x1
8010675c:	e8 81 fc ff ff       	call   801063e2 <argptr>
80106761:	83 c4 10             	add    $0x10,%esp
80106764:	85 c0                	test   %eax,%eax
80106766:	79 07                	jns    8010676f <sys_fstat+0x3b>
    return -1;
80106768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676d:	eb 13                	jmp    80106782 <sys_fstat+0x4e>
  return filestat(f, st);
8010676f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106775:	83 ec 08             	sub    $0x8,%esp
80106778:	52                   	push   %edx
80106779:	50                   	push   %eax
8010677a:	e8 64 aa ff ff       	call   801011e3 <filestat>
8010677f:	83 c4 10             	add    $0x10,%esp
}
80106782:	c9                   	leave  
80106783:	c3                   	ret    

80106784 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106784:	55                   	push   %ebp
80106785:	89 e5                	mov    %esp,%ebp
80106787:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010678a:	83 ec 08             	sub    $0x8,%esp
8010678d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106790:	50                   	push   %eax
80106791:	6a 00                	push   $0x0
80106793:	e8 a7 fc ff ff       	call   8010643f <argstr>
80106798:	83 c4 10             	add    $0x10,%esp
8010679b:	85 c0                	test   %eax,%eax
8010679d:	78 15                	js     801067b4 <sys_link+0x30>
8010679f:	83 ec 08             	sub    $0x8,%esp
801067a2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801067a5:	50                   	push   %eax
801067a6:	6a 01                	push   $0x1
801067a8:	e8 92 fc ff ff       	call   8010643f <argstr>
801067ad:	83 c4 10             	add    $0x10,%esp
801067b0:	85 c0                	test   %eax,%eax
801067b2:	79 0a                	jns    801067be <sys_link+0x3a>
    return -1;
801067b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b9:	e9 68 01 00 00       	jmp    80106926 <sys_link+0x1a2>

  begin_op();
801067be:	e8 34 ce ff ff       	call   801035f7 <begin_op>
  if((ip = namei(old)) == 0){
801067c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801067c6:	83 ec 0c             	sub    $0xc,%esp
801067c9:	50                   	push   %eax
801067ca:	e8 03 be ff ff       	call   801025d2 <namei>
801067cf:	83 c4 10             	add    $0x10,%esp
801067d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d9:	75 0f                	jne    801067ea <sys_link+0x66>
    end_op();
801067db:	e8 a3 ce ff ff       	call   80103683 <end_op>
    return -1;
801067e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e5:	e9 3c 01 00 00       	jmp    80106926 <sys_link+0x1a2>
  }

  ilock(ip);
801067ea:	83 ec 0c             	sub    $0xc,%esp
801067ed:	ff 75 f4             	pushl  -0xc(%ebp)
801067f0:	e8 1f b2 ff ff       	call   80101a14 <ilock>
801067f5:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801067f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067ff:	66 83 f8 01          	cmp    $0x1,%ax
80106803:	75 1d                	jne    80106822 <sys_link+0x9e>
    iunlockput(ip);
80106805:	83 ec 0c             	sub    $0xc,%esp
80106808:	ff 75 f4             	pushl  -0xc(%ebp)
8010680b:	e8 c4 b4 ff ff       	call   80101cd4 <iunlockput>
80106810:	83 c4 10             	add    $0x10,%esp
    end_op();
80106813:	e8 6b ce ff ff       	call   80103683 <end_op>
    return -1;
80106818:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010681d:	e9 04 01 00 00       	jmp    80106926 <sys_link+0x1a2>
  }

  ip->nlink++;
80106822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106825:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106829:	83 c0 01             	add    $0x1,%eax
8010682c:	89 c2                	mov    %eax,%edx
8010682e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106831:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106835:	83 ec 0c             	sub    $0xc,%esp
80106838:	ff 75 f4             	pushl  -0xc(%ebp)
8010683b:	e8 fa af ff ff       	call   8010183a <iupdate>
80106840:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106843:	83 ec 0c             	sub    $0xc,%esp
80106846:	ff 75 f4             	pushl  -0xc(%ebp)
80106849:	e8 24 b3 ff ff       	call   80101b72 <iunlock>
8010684e:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106851:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106854:	83 ec 08             	sub    $0x8,%esp
80106857:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010685a:	52                   	push   %edx
8010685b:	50                   	push   %eax
8010685c:	e8 8d bd ff ff       	call   801025ee <nameiparent>
80106861:	83 c4 10             	add    $0x10,%esp
80106864:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106867:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010686b:	74 71                	je     801068de <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010686d:	83 ec 0c             	sub    $0xc,%esp
80106870:	ff 75 f0             	pushl  -0x10(%ebp)
80106873:	e8 9c b1 ff ff       	call   80101a14 <ilock>
80106878:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010687b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687e:	8b 10                	mov    (%eax),%edx
80106880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106883:	8b 00                	mov    (%eax),%eax
80106885:	39 c2                	cmp    %eax,%edx
80106887:	75 1d                	jne    801068a6 <sys_link+0x122>
80106889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688c:	8b 40 04             	mov    0x4(%eax),%eax
8010688f:	83 ec 04             	sub    $0x4,%esp
80106892:	50                   	push   %eax
80106893:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106896:	50                   	push   %eax
80106897:	ff 75 f0             	pushl  -0x10(%ebp)
8010689a:	e8 97 ba ff ff       	call   80102336 <dirlink>
8010689f:	83 c4 10             	add    $0x10,%esp
801068a2:	85 c0                	test   %eax,%eax
801068a4:	79 10                	jns    801068b6 <sys_link+0x132>
    iunlockput(dp);
801068a6:	83 ec 0c             	sub    $0xc,%esp
801068a9:	ff 75 f0             	pushl  -0x10(%ebp)
801068ac:	e8 23 b4 ff ff       	call   80101cd4 <iunlockput>
801068b1:	83 c4 10             	add    $0x10,%esp
    goto bad;
801068b4:	eb 29                	jmp    801068df <sys_link+0x15b>
  }
  iunlockput(dp);
801068b6:	83 ec 0c             	sub    $0xc,%esp
801068b9:	ff 75 f0             	pushl  -0x10(%ebp)
801068bc:	e8 13 b4 ff ff       	call   80101cd4 <iunlockput>
801068c1:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801068c4:	83 ec 0c             	sub    $0xc,%esp
801068c7:	ff 75 f4             	pushl  -0xc(%ebp)
801068ca:	e8 15 b3 ff ff       	call   80101be4 <iput>
801068cf:	83 c4 10             	add    $0x10,%esp

  end_op();
801068d2:	e8 ac cd ff ff       	call   80103683 <end_op>

  return 0;
801068d7:	b8 00 00 00 00       	mov    $0x0,%eax
801068dc:	eb 48                	jmp    80106926 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801068de:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801068df:	83 ec 0c             	sub    $0xc,%esp
801068e2:	ff 75 f4             	pushl  -0xc(%ebp)
801068e5:	e8 2a b1 ff ff       	call   80101a14 <ilock>
801068ea:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801068ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068f4:	83 e8 01             	sub    $0x1,%eax
801068f7:	89 c2                	mov    %eax,%edx
801068f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106900:	83 ec 0c             	sub    $0xc,%esp
80106903:	ff 75 f4             	pushl  -0xc(%ebp)
80106906:	e8 2f af ff ff       	call   8010183a <iupdate>
8010690b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010690e:	83 ec 0c             	sub    $0xc,%esp
80106911:	ff 75 f4             	pushl  -0xc(%ebp)
80106914:	e8 bb b3 ff ff       	call   80101cd4 <iunlockput>
80106919:	83 c4 10             	add    $0x10,%esp
  end_op();
8010691c:	e8 62 cd ff ff       	call   80103683 <end_op>
  return -1;
80106921:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106926:	c9                   	leave  
80106927:	c3                   	ret    

80106928 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106928:	55                   	push   %ebp
80106929:	89 e5                	mov    %esp,%ebp
8010692b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010692e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106935:	eb 40                	jmp    80106977 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693a:	6a 10                	push   $0x10
8010693c:	50                   	push   %eax
8010693d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106940:	50                   	push   %eax
80106941:	ff 75 08             	pushl  0x8(%ebp)
80106944:	e8 39 b6 ff ff       	call   80101f82 <readi>
80106949:	83 c4 10             	add    $0x10,%esp
8010694c:	83 f8 10             	cmp    $0x10,%eax
8010694f:	74 0d                	je     8010695e <isdirempty+0x36>
      panic("isdirempty: readi");
80106951:	83 ec 0c             	sub    $0xc,%esp
80106954:	68 65 9b 10 80       	push   $0x80109b65
80106959:	e8 08 9c ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010695e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106962:	66 85 c0             	test   %ax,%ax
80106965:	74 07                	je     8010696e <isdirempty+0x46>
      return 0;
80106967:	b8 00 00 00 00       	mov    $0x0,%eax
8010696c:	eb 1b                	jmp    80106989 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010696e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106971:	83 c0 10             	add    $0x10,%eax
80106974:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106977:	8b 45 08             	mov    0x8(%ebp),%eax
8010697a:	8b 50 18             	mov    0x18(%eax),%edx
8010697d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106980:	39 c2                	cmp    %eax,%edx
80106982:	77 b3                	ja     80106937 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106984:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106989:	c9                   	leave  
8010698a:	c3                   	ret    

8010698b <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010698b:	55                   	push   %ebp
8010698c:	89 e5                	mov    %esp,%ebp
8010698e:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106991:	83 ec 08             	sub    $0x8,%esp
80106994:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106997:	50                   	push   %eax
80106998:	6a 00                	push   $0x0
8010699a:	e8 a0 fa ff ff       	call   8010643f <argstr>
8010699f:	83 c4 10             	add    $0x10,%esp
801069a2:	85 c0                	test   %eax,%eax
801069a4:	79 0a                	jns    801069b0 <sys_unlink+0x25>
    return -1;
801069a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ab:	e9 bc 01 00 00       	jmp    80106b6c <sys_unlink+0x1e1>

  begin_op();
801069b0:	e8 42 cc ff ff       	call   801035f7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801069b5:	8b 45 cc             	mov    -0x34(%ebp),%eax
801069b8:	83 ec 08             	sub    $0x8,%esp
801069bb:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801069be:	52                   	push   %edx
801069bf:	50                   	push   %eax
801069c0:	e8 29 bc ff ff       	call   801025ee <nameiparent>
801069c5:	83 c4 10             	add    $0x10,%esp
801069c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069cf:	75 0f                	jne    801069e0 <sys_unlink+0x55>
    end_op();
801069d1:	e8 ad cc ff ff       	call   80103683 <end_op>
    return -1;
801069d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069db:	e9 8c 01 00 00       	jmp    80106b6c <sys_unlink+0x1e1>
  }

  ilock(dp);
801069e0:	83 ec 0c             	sub    $0xc,%esp
801069e3:	ff 75 f4             	pushl  -0xc(%ebp)
801069e6:	e8 29 b0 ff ff       	call   80101a14 <ilock>
801069eb:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801069ee:	83 ec 08             	sub    $0x8,%esp
801069f1:	68 77 9b 10 80       	push   $0x80109b77
801069f6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801069f9:	50                   	push   %eax
801069fa:	e8 62 b8 ff ff       	call   80102261 <namecmp>
801069ff:	83 c4 10             	add    $0x10,%esp
80106a02:	85 c0                	test   %eax,%eax
80106a04:	0f 84 4a 01 00 00    	je     80106b54 <sys_unlink+0x1c9>
80106a0a:	83 ec 08             	sub    $0x8,%esp
80106a0d:	68 79 9b 10 80       	push   $0x80109b79
80106a12:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106a15:	50                   	push   %eax
80106a16:	e8 46 b8 ff ff       	call   80102261 <namecmp>
80106a1b:	83 c4 10             	add    $0x10,%esp
80106a1e:	85 c0                	test   %eax,%eax
80106a20:	0f 84 2e 01 00 00    	je     80106b54 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106a26:	83 ec 04             	sub    $0x4,%esp
80106a29:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106a2c:	50                   	push   %eax
80106a2d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106a30:	50                   	push   %eax
80106a31:	ff 75 f4             	pushl  -0xc(%ebp)
80106a34:	e8 43 b8 ff ff       	call   8010227c <dirlookup>
80106a39:	83 c4 10             	add    $0x10,%esp
80106a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a43:	0f 84 0a 01 00 00    	je     80106b53 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106a49:	83 ec 0c             	sub    $0xc,%esp
80106a4c:	ff 75 f0             	pushl  -0x10(%ebp)
80106a4f:	e8 c0 af ff ff       	call   80101a14 <ilock>
80106a54:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a5a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a5e:	66 85 c0             	test   %ax,%ax
80106a61:	7f 0d                	jg     80106a70 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106a63:	83 ec 0c             	sub    $0xc,%esp
80106a66:	68 7c 9b 10 80       	push   $0x80109b7c
80106a6b:	e8 f6 9a ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a73:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a77:	66 83 f8 01          	cmp    $0x1,%ax
80106a7b:	75 25                	jne    80106aa2 <sys_unlink+0x117>
80106a7d:	83 ec 0c             	sub    $0xc,%esp
80106a80:	ff 75 f0             	pushl  -0x10(%ebp)
80106a83:	e8 a0 fe ff ff       	call   80106928 <isdirempty>
80106a88:	83 c4 10             	add    $0x10,%esp
80106a8b:	85 c0                	test   %eax,%eax
80106a8d:	75 13                	jne    80106aa2 <sys_unlink+0x117>
    iunlockput(ip);
80106a8f:	83 ec 0c             	sub    $0xc,%esp
80106a92:	ff 75 f0             	pushl  -0x10(%ebp)
80106a95:	e8 3a b2 ff ff       	call   80101cd4 <iunlockput>
80106a9a:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106a9d:	e9 b2 00 00 00       	jmp    80106b54 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106aa2:	83 ec 04             	sub    $0x4,%esp
80106aa5:	6a 10                	push   $0x10
80106aa7:	6a 00                	push   $0x0
80106aa9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106aac:	50                   	push   %eax
80106aad:	e8 e3 f5 ff ff       	call   80106095 <memset>
80106ab2:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106ab5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106ab8:	6a 10                	push   $0x10
80106aba:	50                   	push   %eax
80106abb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106abe:	50                   	push   %eax
80106abf:	ff 75 f4             	pushl  -0xc(%ebp)
80106ac2:	e8 12 b6 ff ff       	call   801020d9 <writei>
80106ac7:	83 c4 10             	add    $0x10,%esp
80106aca:	83 f8 10             	cmp    $0x10,%eax
80106acd:	74 0d                	je     80106adc <sys_unlink+0x151>
    panic("unlink: writei");
80106acf:	83 ec 0c             	sub    $0xc,%esp
80106ad2:	68 8e 9b 10 80       	push   $0x80109b8e
80106ad7:	e8 8a 9a ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106adf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106ae3:	66 83 f8 01          	cmp    $0x1,%ax
80106ae7:	75 21                	jne    80106b0a <sys_unlink+0x17f>
    dp->nlink--;
80106ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aec:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106af0:	83 e8 01             	sub    $0x1,%eax
80106af3:	89 c2                	mov    %eax,%edx
80106af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106afc:	83 ec 0c             	sub    $0xc,%esp
80106aff:	ff 75 f4             	pushl  -0xc(%ebp)
80106b02:	e8 33 ad ff ff       	call   8010183a <iupdate>
80106b07:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106b0a:	83 ec 0c             	sub    $0xc,%esp
80106b0d:	ff 75 f4             	pushl  -0xc(%ebp)
80106b10:	e8 bf b1 ff ff       	call   80101cd4 <iunlockput>
80106b15:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b1b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b1f:	83 e8 01             	sub    $0x1,%eax
80106b22:	89 c2                	mov    %eax,%edx
80106b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b27:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106b2b:	83 ec 0c             	sub    $0xc,%esp
80106b2e:	ff 75 f0             	pushl  -0x10(%ebp)
80106b31:	e8 04 ad ff ff       	call   8010183a <iupdate>
80106b36:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106b39:	83 ec 0c             	sub    $0xc,%esp
80106b3c:	ff 75 f0             	pushl  -0x10(%ebp)
80106b3f:	e8 90 b1 ff ff       	call   80101cd4 <iunlockput>
80106b44:	83 c4 10             	add    $0x10,%esp

  end_op();
80106b47:	e8 37 cb ff ff       	call   80103683 <end_op>

  return 0;
80106b4c:	b8 00 00 00 00       	mov    $0x0,%eax
80106b51:	eb 19                	jmp    80106b6c <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106b53:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106b54:	83 ec 0c             	sub    $0xc,%esp
80106b57:	ff 75 f4             	pushl  -0xc(%ebp)
80106b5a:	e8 75 b1 ff ff       	call   80101cd4 <iunlockput>
80106b5f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106b62:	e8 1c cb ff ff       	call   80103683 <end_op>
  return -1;
80106b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106b6c:	c9                   	leave  
80106b6d:	c3                   	ret    

80106b6e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106b6e:	55                   	push   %ebp
80106b6f:	89 e5                	mov    %esp,%ebp
80106b71:	83 ec 38             	sub    $0x38,%esp
80106b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106b77:	8b 55 10             	mov    0x10(%ebp),%edx
80106b7a:	8b 45 14             	mov    0x14(%ebp),%eax
80106b7d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106b81:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106b85:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106b89:	83 ec 08             	sub    $0x8,%esp
80106b8c:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b8f:	50                   	push   %eax
80106b90:	ff 75 08             	pushl  0x8(%ebp)
80106b93:	e8 56 ba ff ff       	call   801025ee <nameiparent>
80106b98:	83 c4 10             	add    $0x10,%esp
80106b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ba2:	75 0a                	jne    80106bae <create+0x40>
    return 0;
80106ba4:	b8 00 00 00 00       	mov    $0x0,%eax
80106ba9:	e9 90 01 00 00       	jmp    80106d3e <create+0x1d0>
  ilock(dp);
80106bae:	83 ec 0c             	sub    $0xc,%esp
80106bb1:	ff 75 f4             	pushl  -0xc(%ebp)
80106bb4:	e8 5b ae ff ff       	call   80101a14 <ilock>
80106bb9:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106bbc:	83 ec 04             	sub    $0x4,%esp
80106bbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106bc2:	50                   	push   %eax
80106bc3:	8d 45 de             	lea    -0x22(%ebp),%eax
80106bc6:	50                   	push   %eax
80106bc7:	ff 75 f4             	pushl  -0xc(%ebp)
80106bca:	e8 ad b6 ff ff       	call   8010227c <dirlookup>
80106bcf:	83 c4 10             	add    $0x10,%esp
80106bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bd9:	74 50                	je     80106c2b <create+0xbd>
    iunlockput(dp);
80106bdb:	83 ec 0c             	sub    $0xc,%esp
80106bde:	ff 75 f4             	pushl  -0xc(%ebp)
80106be1:	e8 ee b0 ff ff       	call   80101cd4 <iunlockput>
80106be6:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106be9:	83 ec 0c             	sub    $0xc,%esp
80106bec:	ff 75 f0             	pushl  -0x10(%ebp)
80106bef:	e8 20 ae ff ff       	call   80101a14 <ilock>
80106bf4:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106bf7:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106bfc:	75 15                	jne    80106c13 <create+0xa5>
80106bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c01:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c05:	66 83 f8 02          	cmp    $0x2,%ax
80106c09:	75 08                	jne    80106c13 <create+0xa5>
      return ip;
80106c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c0e:	e9 2b 01 00 00       	jmp    80106d3e <create+0x1d0>
    iunlockput(ip);
80106c13:	83 ec 0c             	sub    $0xc,%esp
80106c16:	ff 75 f0             	pushl  -0x10(%ebp)
80106c19:	e8 b6 b0 ff ff       	call   80101cd4 <iunlockput>
80106c1e:	83 c4 10             	add    $0x10,%esp
    return 0;
80106c21:	b8 00 00 00 00       	mov    $0x0,%eax
80106c26:	e9 13 01 00 00       	jmp    80106d3e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106c2b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c32:	8b 00                	mov    (%eax),%eax
80106c34:	83 ec 08             	sub    $0x8,%esp
80106c37:	52                   	push   %edx
80106c38:	50                   	push   %eax
80106c39:	e8 25 ab ff ff       	call   80101763 <ialloc>
80106c3e:	83 c4 10             	add    $0x10,%esp
80106c41:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c48:	75 0d                	jne    80106c57 <create+0xe9>
    panic("create: ialloc");
80106c4a:	83 ec 0c             	sub    $0xc,%esp
80106c4d:	68 9d 9b 10 80       	push   $0x80109b9d
80106c52:	e8 0f 99 ff ff       	call   80100566 <panic>

  ilock(ip);
80106c57:	83 ec 0c             	sub    $0xc,%esp
80106c5a:	ff 75 f0             	pushl  -0x10(%ebp)
80106c5d:	e8 b2 ad ff ff       	call   80101a14 <ilock>
80106c62:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c68:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106c6c:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c73:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106c77:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c7e:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106c84:	83 ec 0c             	sub    $0xc,%esp
80106c87:	ff 75 f0             	pushl  -0x10(%ebp)
80106c8a:	e8 ab ab ff ff       	call   8010183a <iupdate>
80106c8f:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106c92:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106c97:	75 6a                	jne    80106d03 <create+0x195>
    dp->nlink++;  // for ".."
80106c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c9c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ca0:	83 c0 01             	add    $0x1,%eax
80106ca3:	89 c2                	mov    %eax,%edx
80106ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106cac:	83 ec 0c             	sub    $0xc,%esp
80106caf:	ff 75 f4             	pushl  -0xc(%ebp)
80106cb2:	e8 83 ab ff ff       	call   8010183a <iupdate>
80106cb7:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cbd:	8b 40 04             	mov    0x4(%eax),%eax
80106cc0:	83 ec 04             	sub    $0x4,%esp
80106cc3:	50                   	push   %eax
80106cc4:	68 77 9b 10 80       	push   $0x80109b77
80106cc9:	ff 75 f0             	pushl  -0x10(%ebp)
80106ccc:	e8 65 b6 ff ff       	call   80102336 <dirlink>
80106cd1:	83 c4 10             	add    $0x10,%esp
80106cd4:	85 c0                	test   %eax,%eax
80106cd6:	78 1e                	js     80106cf6 <create+0x188>
80106cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cdb:	8b 40 04             	mov    0x4(%eax),%eax
80106cde:	83 ec 04             	sub    $0x4,%esp
80106ce1:	50                   	push   %eax
80106ce2:	68 79 9b 10 80       	push   $0x80109b79
80106ce7:	ff 75 f0             	pushl  -0x10(%ebp)
80106cea:	e8 47 b6 ff ff       	call   80102336 <dirlink>
80106cef:	83 c4 10             	add    $0x10,%esp
80106cf2:	85 c0                	test   %eax,%eax
80106cf4:	79 0d                	jns    80106d03 <create+0x195>
      panic("create dots");
80106cf6:	83 ec 0c             	sub    $0xc,%esp
80106cf9:	68 ac 9b 10 80       	push   $0x80109bac
80106cfe:	e8 63 98 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d06:	8b 40 04             	mov    0x4(%eax),%eax
80106d09:	83 ec 04             	sub    $0x4,%esp
80106d0c:	50                   	push   %eax
80106d0d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106d10:	50                   	push   %eax
80106d11:	ff 75 f4             	pushl  -0xc(%ebp)
80106d14:	e8 1d b6 ff ff       	call   80102336 <dirlink>
80106d19:	83 c4 10             	add    $0x10,%esp
80106d1c:	85 c0                	test   %eax,%eax
80106d1e:	79 0d                	jns    80106d2d <create+0x1bf>
    panic("create: dirlink");
80106d20:	83 ec 0c             	sub    $0xc,%esp
80106d23:	68 b8 9b 10 80       	push   $0x80109bb8
80106d28:	e8 39 98 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106d2d:	83 ec 0c             	sub    $0xc,%esp
80106d30:	ff 75 f4             	pushl  -0xc(%ebp)
80106d33:	e8 9c af ff ff       	call   80101cd4 <iunlockput>
80106d38:	83 c4 10             	add    $0x10,%esp

  return ip;
80106d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106d3e:	c9                   	leave  
80106d3f:	c3                   	ret    

80106d40 <sys_open>:

int
sys_open(void)
{
80106d40:	55                   	push   %ebp
80106d41:	89 e5                	mov    %esp,%ebp
80106d43:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106d46:	83 ec 08             	sub    $0x8,%esp
80106d49:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d4c:	50                   	push   %eax
80106d4d:	6a 00                	push   $0x0
80106d4f:	e8 eb f6 ff ff       	call   8010643f <argstr>
80106d54:	83 c4 10             	add    $0x10,%esp
80106d57:	85 c0                	test   %eax,%eax
80106d59:	78 15                	js     80106d70 <sys_open+0x30>
80106d5b:	83 ec 08             	sub    $0x8,%esp
80106d5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d61:	50                   	push   %eax
80106d62:	6a 01                	push   $0x1
80106d64:	e8 51 f6 ff ff       	call   801063ba <argint>
80106d69:	83 c4 10             	add    $0x10,%esp
80106d6c:	85 c0                	test   %eax,%eax
80106d6e:	79 0a                	jns    80106d7a <sys_open+0x3a>
    return -1;
80106d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d75:	e9 61 01 00 00       	jmp    80106edb <sys_open+0x19b>

  begin_op();
80106d7a:	e8 78 c8 ff ff       	call   801035f7 <begin_op>

  if(omode & O_CREATE){
80106d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d82:	25 00 02 00 00       	and    $0x200,%eax
80106d87:	85 c0                	test   %eax,%eax
80106d89:	74 2a                	je     80106db5 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106d8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d8e:	6a 00                	push   $0x0
80106d90:	6a 00                	push   $0x0
80106d92:	6a 02                	push   $0x2
80106d94:	50                   	push   %eax
80106d95:	e8 d4 fd ff ff       	call   80106b6e <create>
80106d9a:	83 c4 10             	add    $0x10,%esp
80106d9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106da0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106da4:	75 75                	jne    80106e1b <sys_open+0xdb>
      end_op();
80106da6:	e8 d8 c8 ff ff       	call   80103683 <end_op>
      return -1;
80106dab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db0:	e9 26 01 00 00       	jmp    80106edb <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106db5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106db8:	83 ec 0c             	sub    $0xc,%esp
80106dbb:	50                   	push   %eax
80106dbc:	e8 11 b8 ff ff       	call   801025d2 <namei>
80106dc1:	83 c4 10             	add    $0x10,%esp
80106dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106dc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106dcb:	75 0f                	jne    80106ddc <sys_open+0x9c>
      end_op();
80106dcd:	e8 b1 c8 ff ff       	call   80103683 <end_op>
      return -1;
80106dd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd7:	e9 ff 00 00 00       	jmp    80106edb <sys_open+0x19b>
    }
    ilock(ip);
80106ddc:	83 ec 0c             	sub    $0xc,%esp
80106ddf:	ff 75 f4             	pushl  -0xc(%ebp)
80106de2:	e8 2d ac ff ff       	call   80101a14 <ilock>
80106de7:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ded:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106df1:	66 83 f8 01          	cmp    $0x1,%ax
80106df5:	75 24                	jne    80106e1b <sys_open+0xdb>
80106df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dfa:	85 c0                	test   %eax,%eax
80106dfc:	74 1d                	je     80106e1b <sys_open+0xdb>
      iunlockput(ip);
80106dfe:	83 ec 0c             	sub    $0xc,%esp
80106e01:	ff 75 f4             	pushl  -0xc(%ebp)
80106e04:	e8 cb ae ff ff       	call   80101cd4 <iunlockput>
80106e09:	83 c4 10             	add    $0x10,%esp
      end_op();
80106e0c:	e8 72 c8 ff ff       	call   80103683 <end_op>
      return -1;
80106e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e16:	e9 c0 00 00 00       	jmp    80106edb <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106e1b:	e8 1d a2 ff ff       	call   8010103d <filealloc>
80106e20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e27:	74 17                	je     80106e40 <sys_open+0x100>
80106e29:	83 ec 0c             	sub    $0xc,%esp
80106e2c:	ff 75 f0             	pushl  -0x10(%ebp)
80106e2f:	e8 37 f7 ff ff       	call   8010656b <fdalloc>
80106e34:	83 c4 10             	add    $0x10,%esp
80106e37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106e3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106e3e:	79 2e                	jns    80106e6e <sys_open+0x12e>
    if(f)
80106e40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e44:	74 0e                	je     80106e54 <sys_open+0x114>
      fileclose(f);
80106e46:	83 ec 0c             	sub    $0xc,%esp
80106e49:	ff 75 f0             	pushl  -0x10(%ebp)
80106e4c:	e8 aa a2 ff ff       	call   801010fb <fileclose>
80106e51:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106e54:	83 ec 0c             	sub    $0xc,%esp
80106e57:	ff 75 f4             	pushl  -0xc(%ebp)
80106e5a:	e8 75 ae ff ff       	call   80101cd4 <iunlockput>
80106e5f:	83 c4 10             	add    $0x10,%esp
    end_op();
80106e62:	e8 1c c8 ff ff       	call   80103683 <end_op>
    return -1;
80106e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e6c:	eb 6d                	jmp    80106edb <sys_open+0x19b>
  }
  iunlock(ip);
80106e6e:	83 ec 0c             	sub    $0xc,%esp
80106e71:	ff 75 f4             	pushl  -0xc(%ebp)
80106e74:	e8 f9 ac ff ff       	call   80101b72 <iunlock>
80106e79:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e7c:	e8 02 c8 ff ff       	call   80103683 <end_op>

  f->type = FD_INODE;
80106e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e84:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e90:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e96:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ea0:	83 e0 01             	and    $0x1,%eax
80106ea3:	85 c0                	test   %eax,%eax
80106ea5:	0f 94 c0             	sete   %al
80106ea8:	89 c2                	mov    %eax,%edx
80106eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ead:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106eb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106eb3:	83 e0 01             	and    $0x1,%eax
80106eb6:	85 c0                	test   %eax,%eax
80106eb8:	75 0a                	jne    80106ec4 <sys_open+0x184>
80106eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ebd:	83 e0 02             	and    $0x2,%eax
80106ec0:	85 c0                	test   %eax,%eax
80106ec2:	74 07                	je     80106ecb <sys_open+0x18b>
80106ec4:	b8 01 00 00 00       	mov    $0x1,%eax
80106ec9:	eb 05                	jmp    80106ed0 <sys_open+0x190>
80106ecb:	b8 00 00 00 00       	mov    $0x0,%eax
80106ed0:	89 c2                	mov    %eax,%edx
80106ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ed5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106edb:	c9                   	leave  
80106edc:	c3                   	ret    

80106edd <sys_mkdir>:

int
sys_mkdir(void)
{
80106edd:	55                   	push   %ebp
80106ede:	89 e5                	mov    %esp,%ebp
80106ee0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106ee3:	e8 0f c7 ff ff       	call   801035f7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106ee8:	83 ec 08             	sub    $0x8,%esp
80106eeb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106eee:	50                   	push   %eax
80106eef:	6a 00                	push   $0x0
80106ef1:	e8 49 f5 ff ff       	call   8010643f <argstr>
80106ef6:	83 c4 10             	add    $0x10,%esp
80106ef9:	85 c0                	test   %eax,%eax
80106efb:	78 1b                	js     80106f18 <sys_mkdir+0x3b>
80106efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f00:	6a 00                	push   $0x0
80106f02:	6a 00                	push   $0x0
80106f04:	6a 01                	push   $0x1
80106f06:	50                   	push   %eax
80106f07:	e8 62 fc ff ff       	call   80106b6e <create>
80106f0c:	83 c4 10             	add    $0x10,%esp
80106f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f16:	75 0c                	jne    80106f24 <sys_mkdir+0x47>
    end_op();
80106f18:	e8 66 c7 ff ff       	call   80103683 <end_op>
    return -1;
80106f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f22:	eb 18                	jmp    80106f3c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106f24:	83 ec 0c             	sub    $0xc,%esp
80106f27:	ff 75 f4             	pushl  -0xc(%ebp)
80106f2a:	e8 a5 ad ff ff       	call   80101cd4 <iunlockput>
80106f2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106f32:	e8 4c c7 ff ff       	call   80103683 <end_op>
  return 0;
80106f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f3c:	c9                   	leave  
80106f3d:	c3                   	ret    

80106f3e <sys_mknod>:

int
sys_mknod(void)
{
80106f3e:	55                   	push   %ebp
80106f3f:	89 e5                	mov    %esp,%ebp
80106f41:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106f44:	e8 ae c6 ff ff       	call   801035f7 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106f49:	83 ec 08             	sub    $0x8,%esp
80106f4c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f4f:	50                   	push   %eax
80106f50:	6a 00                	push   $0x0
80106f52:	e8 e8 f4 ff ff       	call   8010643f <argstr>
80106f57:	83 c4 10             	add    $0x10,%esp
80106f5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f61:	78 4f                	js     80106fb2 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106f63:	83 ec 08             	sub    $0x8,%esp
80106f66:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f69:	50                   	push   %eax
80106f6a:	6a 01                	push   $0x1
80106f6c:	e8 49 f4 ff ff       	call   801063ba <argint>
80106f71:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106f74:	85 c0                	test   %eax,%eax
80106f76:	78 3a                	js     80106fb2 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106f78:	83 ec 08             	sub    $0x8,%esp
80106f7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f7e:	50                   	push   %eax
80106f7f:	6a 02                	push   $0x2
80106f81:	e8 34 f4 ff ff       	call   801063ba <argint>
80106f86:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106f89:	85 c0                	test   %eax,%eax
80106f8b:	78 25                	js     80106fb2 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f90:	0f bf c8             	movswl %ax,%ecx
80106f93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f96:	0f bf d0             	movswl %ax,%edx
80106f99:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106f9c:	51                   	push   %ecx
80106f9d:	52                   	push   %edx
80106f9e:	6a 03                	push   $0x3
80106fa0:	50                   	push   %eax
80106fa1:	e8 c8 fb ff ff       	call   80106b6e <create>
80106fa6:	83 c4 10             	add    $0x10,%esp
80106fa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106fac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106fb0:	75 0c                	jne    80106fbe <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106fb2:	e8 cc c6 ff ff       	call   80103683 <end_op>
    return -1;
80106fb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fbc:	eb 18                	jmp    80106fd6 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106fbe:	83 ec 0c             	sub    $0xc,%esp
80106fc1:	ff 75 f0             	pushl  -0x10(%ebp)
80106fc4:	e8 0b ad ff ff       	call   80101cd4 <iunlockput>
80106fc9:	83 c4 10             	add    $0x10,%esp
  end_op();
80106fcc:	e8 b2 c6 ff ff       	call   80103683 <end_op>
  return 0;
80106fd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fd6:	c9                   	leave  
80106fd7:	c3                   	ret    

80106fd8 <sys_chdir>:

int
sys_chdir(void)
{
80106fd8:	55                   	push   %ebp
80106fd9:	89 e5                	mov    %esp,%ebp
80106fdb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106fde:	e8 14 c6 ff ff       	call   801035f7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106fe3:	83 ec 08             	sub    $0x8,%esp
80106fe6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fe9:	50                   	push   %eax
80106fea:	6a 00                	push   $0x0
80106fec:	e8 4e f4 ff ff       	call   8010643f <argstr>
80106ff1:	83 c4 10             	add    $0x10,%esp
80106ff4:	85 c0                	test   %eax,%eax
80106ff6:	78 18                	js     80107010 <sys_chdir+0x38>
80106ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ffb:	83 ec 0c             	sub    $0xc,%esp
80106ffe:	50                   	push   %eax
80106fff:	e8 ce b5 ff ff       	call   801025d2 <namei>
80107004:	83 c4 10             	add    $0x10,%esp
80107007:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010700a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010700e:	75 0c                	jne    8010701c <sys_chdir+0x44>
    end_op();
80107010:	e8 6e c6 ff ff       	call   80103683 <end_op>
    return -1;
80107015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701a:	eb 6e                	jmp    8010708a <sys_chdir+0xb2>
  }
  ilock(ip);
8010701c:	83 ec 0c             	sub    $0xc,%esp
8010701f:	ff 75 f4             	pushl  -0xc(%ebp)
80107022:	e8 ed a9 ff ff       	call   80101a14 <ilock>
80107027:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010702a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107031:	66 83 f8 01          	cmp    $0x1,%ax
80107035:	74 1a                	je     80107051 <sys_chdir+0x79>
    iunlockput(ip);
80107037:	83 ec 0c             	sub    $0xc,%esp
8010703a:	ff 75 f4             	pushl  -0xc(%ebp)
8010703d:	e8 92 ac ff ff       	call   80101cd4 <iunlockput>
80107042:	83 c4 10             	add    $0x10,%esp
    end_op();
80107045:	e8 39 c6 ff ff       	call   80103683 <end_op>
    return -1;
8010704a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010704f:	eb 39                	jmp    8010708a <sys_chdir+0xb2>
  }
  iunlock(ip);
80107051:	83 ec 0c             	sub    $0xc,%esp
80107054:	ff 75 f4             	pushl  -0xc(%ebp)
80107057:	e8 16 ab ff ff       	call   80101b72 <iunlock>
8010705c:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
8010705f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107065:	8b 40 68             	mov    0x68(%eax),%eax
80107068:	83 ec 0c             	sub    $0xc,%esp
8010706b:	50                   	push   %eax
8010706c:	e8 73 ab ff ff       	call   80101be4 <iput>
80107071:	83 c4 10             	add    $0x10,%esp
  end_op();
80107074:	e8 0a c6 ff ff       	call   80103683 <end_op>
  proc->cwd = ip;
80107079:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010707f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107082:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107085:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010708a:	c9                   	leave  
8010708b:	c3                   	ret    

8010708c <sys_exec>:

int
sys_exec(void)
{
8010708c:	55                   	push   %ebp
8010708d:	89 e5                	mov    %esp,%ebp
8010708f:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107095:	83 ec 08             	sub    $0x8,%esp
80107098:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010709b:	50                   	push   %eax
8010709c:	6a 00                	push   $0x0
8010709e:	e8 9c f3 ff ff       	call   8010643f <argstr>
801070a3:	83 c4 10             	add    $0x10,%esp
801070a6:	85 c0                	test   %eax,%eax
801070a8:	78 18                	js     801070c2 <sys_exec+0x36>
801070aa:	83 ec 08             	sub    $0x8,%esp
801070ad:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801070b3:	50                   	push   %eax
801070b4:	6a 01                	push   $0x1
801070b6:	e8 ff f2 ff ff       	call   801063ba <argint>
801070bb:	83 c4 10             	add    $0x10,%esp
801070be:	85 c0                	test   %eax,%eax
801070c0:	79 0a                	jns    801070cc <sys_exec+0x40>
    return -1;
801070c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c7:	e9 c6 00 00 00       	jmp    80107192 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801070cc:	83 ec 04             	sub    $0x4,%esp
801070cf:	68 80 00 00 00       	push   $0x80
801070d4:	6a 00                	push   $0x0
801070d6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801070dc:	50                   	push   %eax
801070dd:	e8 b3 ef ff ff       	call   80106095 <memset>
801070e2:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801070e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801070ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ef:	83 f8 1f             	cmp    $0x1f,%eax
801070f2:	76 0a                	jbe    801070fe <sys_exec+0x72>
      return -1;
801070f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f9:	e9 94 00 00 00       	jmp    80107192 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801070fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107101:	c1 e0 02             	shl    $0x2,%eax
80107104:	89 c2                	mov    %eax,%edx
80107106:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010710c:	01 c2                	add    %eax,%edx
8010710e:	83 ec 08             	sub    $0x8,%esp
80107111:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107117:	50                   	push   %eax
80107118:	52                   	push   %edx
80107119:	e8 00 f2 ff ff       	call   8010631e <fetchint>
8010711e:	83 c4 10             	add    $0x10,%esp
80107121:	85 c0                	test   %eax,%eax
80107123:	79 07                	jns    8010712c <sys_exec+0xa0>
      return -1;
80107125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010712a:	eb 66                	jmp    80107192 <sys_exec+0x106>
    if(uarg == 0){
8010712c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107132:	85 c0                	test   %eax,%eax
80107134:	75 27                	jne    8010715d <sys_exec+0xd1>
      argv[i] = 0;
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107140:	00 00 00 00 
      break;
80107144:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107148:	83 ec 08             	sub    $0x8,%esp
8010714b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107151:	52                   	push   %edx
80107152:	50                   	push   %eax
80107153:	e8 c3 9a ff ff       	call   80100c1b <exec>
80107158:	83 c4 10             	add    $0x10,%esp
8010715b:	eb 35                	jmp    80107192 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010715d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107163:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107166:	c1 e2 02             	shl    $0x2,%edx
80107169:	01 c2                	add    %eax,%edx
8010716b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107171:	83 ec 08             	sub    $0x8,%esp
80107174:	52                   	push   %edx
80107175:	50                   	push   %eax
80107176:	e8 dd f1 ff ff       	call   80106358 <fetchstr>
8010717b:	83 c4 10             	add    $0x10,%esp
8010717e:	85 c0                	test   %eax,%eax
80107180:	79 07                	jns    80107189 <sys_exec+0xfd>
      return -1;
80107182:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107187:	eb 09                	jmp    80107192 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107189:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010718d:	e9 5a ff ff ff       	jmp    801070ec <sys_exec+0x60>
  return exec(path, argv);
}
80107192:	c9                   	leave  
80107193:	c3                   	ret    

80107194 <sys_pipe>:

int
sys_pipe(void)
{
80107194:	55                   	push   %ebp
80107195:	89 e5                	mov    %esp,%ebp
80107197:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010719a:	83 ec 04             	sub    $0x4,%esp
8010719d:	6a 08                	push   $0x8
8010719f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801071a2:	50                   	push   %eax
801071a3:	6a 00                	push   $0x0
801071a5:	e8 38 f2 ff ff       	call   801063e2 <argptr>
801071aa:	83 c4 10             	add    $0x10,%esp
801071ad:	85 c0                	test   %eax,%eax
801071af:	79 0a                	jns    801071bb <sys_pipe+0x27>
    return -1;
801071b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071b6:	e9 af 00 00 00       	jmp    8010726a <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801071bb:	83 ec 08             	sub    $0x8,%esp
801071be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801071c1:	50                   	push   %eax
801071c2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801071c5:	50                   	push   %eax
801071c6:	e8 20 cf ff ff       	call   801040eb <pipealloc>
801071cb:	83 c4 10             	add    $0x10,%esp
801071ce:	85 c0                	test   %eax,%eax
801071d0:	79 0a                	jns    801071dc <sys_pipe+0x48>
    return -1;
801071d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071d7:	e9 8e 00 00 00       	jmp    8010726a <sys_pipe+0xd6>
  fd0 = -1;
801071dc:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801071e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071e6:	83 ec 0c             	sub    $0xc,%esp
801071e9:	50                   	push   %eax
801071ea:	e8 7c f3 ff ff       	call   8010656b <fdalloc>
801071ef:	83 c4 10             	add    $0x10,%esp
801071f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071f9:	78 18                	js     80107213 <sys_pipe+0x7f>
801071fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071fe:	83 ec 0c             	sub    $0xc,%esp
80107201:	50                   	push   %eax
80107202:	e8 64 f3 ff ff       	call   8010656b <fdalloc>
80107207:	83 c4 10             	add    $0x10,%esp
8010720a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010720d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107211:	79 3f                	jns    80107252 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107213:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107217:	78 14                	js     8010722d <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107219:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010721f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107222:	83 c2 08             	add    $0x8,%edx
80107225:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010722c:	00 
    fileclose(rf);
8010722d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107230:	83 ec 0c             	sub    $0xc,%esp
80107233:	50                   	push   %eax
80107234:	e8 c2 9e ff ff       	call   801010fb <fileclose>
80107239:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010723c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010723f:	83 ec 0c             	sub    $0xc,%esp
80107242:	50                   	push   %eax
80107243:	e8 b3 9e ff ff       	call   801010fb <fileclose>
80107248:	83 c4 10             	add    $0x10,%esp
    return -1;
8010724b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107250:	eb 18                	jmp    8010726a <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107252:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107255:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107258:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010725a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010725d:	8d 50 04             	lea    0x4(%eax),%edx
80107260:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107263:	89 02                	mov    %eax,(%edx)
  return 0;
80107265:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010726a:	c9                   	leave  
8010726b:	c3                   	ret    

8010726c <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
8010726c:	55                   	push   %ebp
8010726d:	89 e5                	mov    %esp,%ebp
8010726f:	83 ec 08             	sub    $0x8,%esp
80107272:	8b 55 08             	mov    0x8(%ebp),%edx
80107275:	8b 45 0c             	mov    0xc(%ebp),%eax
80107278:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010727c:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107280:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107284:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107288:	66 ef                	out    %ax,(%dx)
}
8010728a:	90                   	nop
8010728b:	c9                   	leave  
8010728c:	c3                   	ret    

8010728d <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
8010728d:	55                   	push   %ebp
8010728e:	89 e5                	mov    %esp,%ebp
80107290:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107293:	e8 5d d9 ff ff       	call   80104bf5 <fork>
}
80107298:	c9                   	leave  
80107299:	c3                   	ret    

8010729a <sys_exit>:

int
sys_exit(void)
{
8010729a:	55                   	push   %ebp
8010729b:	89 e5                	mov    %esp,%ebp
8010729d:	83 ec 08             	sub    $0x8,%esp
  exit();
801072a0:	e8 b7 db ff ff       	call   80104e5c <exit>
  return 0;  // not reached
801072a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072aa:	c9                   	leave  
801072ab:	c3                   	ret    

801072ac <sys_wait>:

int
sys_wait(void)
{
801072ac:	55                   	push   %ebp
801072ad:	89 e5                	mov    %esp,%ebp
801072af:	83 ec 08             	sub    $0x8,%esp
  return wait();
801072b2:	e8 24 dd ff ff       	call   80104fdb <wait>
}
801072b7:	c9                   	leave  
801072b8:	c3                   	ret    

801072b9 <sys_kill>:

int
sys_kill(void)
{
801072b9:	55                   	push   %ebp
801072ba:	89 e5                	mov    %esp,%ebp
801072bc:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801072bf:	83 ec 08             	sub    $0x8,%esp
801072c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072c5:	50                   	push   %eax
801072c6:	6a 00                	push   $0x0
801072c8:	e8 ed f0 ff ff       	call   801063ba <argint>
801072cd:	83 c4 10             	add    $0x10,%esp
801072d0:	85 c0                	test   %eax,%eax
801072d2:	79 07                	jns    801072db <sys_kill+0x22>
    return -1;
801072d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072d9:	eb 0f                	jmp    801072ea <sys_kill+0x31>
  return kill(pid);
801072db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072de:	83 ec 0c             	sub    $0xc,%esp
801072e1:	50                   	push   %eax
801072e2:	e8 ce e2 ff ff       	call   801055b5 <kill>
801072e7:	83 c4 10             	add    $0x10,%esp
}
801072ea:	c9                   	leave  
801072eb:	c3                   	ret    

801072ec <sys_getpid>:

int
sys_getpid(void)
{
801072ec:	55                   	push   %ebp
801072ed:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801072ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072f5:	8b 40 10             	mov    0x10(%eax),%eax
}
801072f8:	5d                   	pop    %ebp
801072f9:	c3                   	ret    

801072fa <sys_sbrk>:

int
sys_sbrk(void)
{
801072fa:	55                   	push   %ebp
801072fb:	89 e5                	mov    %esp,%ebp
801072fd:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107300:	83 ec 08             	sub    $0x8,%esp
80107303:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107306:	50                   	push   %eax
80107307:	6a 00                	push   $0x0
80107309:	e8 ac f0 ff ff       	call   801063ba <argint>
8010730e:	83 c4 10             	add    $0x10,%esp
80107311:	85 c0                	test   %eax,%eax
80107313:	79 07                	jns    8010731c <sys_sbrk+0x22>
    return -1;
80107315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010731a:	eb 28                	jmp    80107344 <sys_sbrk+0x4a>
  addr = proc->sz;
8010731c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107322:	8b 00                	mov    (%eax),%eax
80107324:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107327:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010732a:	83 ec 0c             	sub    $0xc,%esp
8010732d:	50                   	push   %eax
8010732e:	e8 1f d8 ff ff       	call   80104b52 <growproc>
80107333:	83 c4 10             	add    $0x10,%esp
80107336:	85 c0                	test   %eax,%eax
80107338:	79 07                	jns    80107341 <sys_sbrk+0x47>
    return -1;
8010733a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010733f:	eb 03                	jmp    80107344 <sys_sbrk+0x4a>
  return addr;
80107341:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107344:	c9                   	leave  
80107345:	c3                   	ret    

80107346 <sys_sleep>:

int
sys_sleep(void)
{
80107346:	55                   	push   %ebp
80107347:	89 e5                	mov    %esp,%ebp
80107349:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010734c:	83 ec 08             	sub    $0x8,%esp
8010734f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107352:	50                   	push   %eax
80107353:	6a 00                	push   $0x0
80107355:	e8 60 f0 ff ff       	call   801063ba <argint>
8010735a:	83 c4 10             	add    $0x10,%esp
8010735d:	85 c0                	test   %eax,%eax
8010735f:	79 07                	jns    80107368 <sys_sleep+0x22>
    return -1;
80107361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107366:	eb 44                	jmp    801073ac <sys_sleep+0x66>
  ticks0 = ticks;
80107368:	a1 80 6b 11 80       	mov    0x80116b80,%eax
8010736d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107370:	eb 26                	jmp    80107398 <sys_sleep+0x52>
    if(proc->killed){
80107372:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107378:	8b 40 24             	mov    0x24(%eax),%eax
8010737b:	85 c0                	test   %eax,%eax
8010737d:	74 07                	je     80107386 <sys_sleep+0x40>
      return -1;
8010737f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107384:	eb 26                	jmp    801073ac <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107386:	83 ec 08             	sub    $0x8,%esp
80107389:	6a 00                	push   $0x0
8010738b:	68 80 6b 11 80       	push   $0x80116b80
80107390:	e8 6e e0 ff ff       	call   80105403 <sleep>
80107395:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107398:	a1 80 6b 11 80       	mov    0x80116b80,%eax
8010739d:	2b 45 f4             	sub    -0xc(%ebp),%eax
801073a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073a3:	39 d0                	cmp    %edx,%eax
801073a5:	72 cb                	jb     80107372 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
801073a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073ac:	c9                   	leave  
801073ad:	c3                   	ret    

801073ae <sys_date>:
#ifdef CS333_P1
int
sys_date(void)
{
801073ae:	55                   	push   %ebp
801073af:	89 e5                	mov    %esp,%ebp
801073b1:	83 ec 18             	sub    $0x18,%esp
    struct rtcdate *d;
   
    if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
801073b4:	83 ec 04             	sub    $0x4,%esp
801073b7:	6a 18                	push   $0x18
801073b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073bc:	50                   	push   %eax
801073bd:	6a 00                	push   $0x0
801073bf:	e8 1e f0 ff ff       	call   801063e2 <argptr>
801073c4:	83 c4 10             	add    $0x10,%esp
801073c7:	85 c0                	test   %eax,%eax
801073c9:	79 07                	jns    801073d2 <sys_date+0x24>
	return -1;
801073cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d0:	eb 14                	jmp    801073e6 <sys_date+0x38>

    cmostime(d);
801073d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d5:	83 ec 0c             	sub    $0xc,%esp
801073d8:	50                   	push   %eax
801073d9:	e8 94 be ff ff       	call   80103272 <cmostime>
801073de:	83 c4 10             	add    $0x10,%esp
    return 0;
801073e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073e6:	c9                   	leave  
801073e7:	c3                   	ret    

801073e8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
801073e8:	55                   	push   %ebp
801073e9:	89 e5                	mov    %esp,%ebp
801073eb:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
801073ee:	a1 80 6b 11 80       	mov    0x80116b80,%eax
801073f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
801073f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801073f9:	c9                   	leave  
801073fa:	c3                   	ret    

801073fb <sys_halt>:

//Turn of the computer
int
sys_halt(void){
801073fb:	55                   	push   %ebp
801073fc:	89 e5                	mov    %esp,%ebp
801073fe:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107401:	83 ec 0c             	sub    $0xc,%esp
80107404:	68 c8 9b 10 80       	push   $0x80109bc8
80107409:	e8 b8 8f ff ff       	call   801003c6 <cprintf>
8010740e:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107411:	83 ec 08             	sub    $0x8,%esp
80107414:	68 00 20 00 00       	push   $0x2000
80107419:	68 04 06 00 00       	push   $0x604
8010741e:	e8 49 fe ff ff       	call   8010726c <outw>
80107423:	83 c4 10             	add    $0x10,%esp
  return 0;
80107426:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010742b:	c9                   	leave  
8010742c:	c3                   	ret    

8010742d <sys_getuid>:

#ifdef CS333_P2
int 
sys_getuid(void)
{
8010742d:	55                   	push   %ebp
8010742e:	89 e5                	mov    %esp,%ebp
    return proc -> uid;
80107430:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107436:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
8010743c:	5d                   	pop    %ebp
8010743d:	c3                   	ret    

8010743e <sys_getgid>:

int 
sys_getgid(void)
{
8010743e:	55                   	push   %ebp
8010743f:	89 e5                	mov    %esp,%ebp
    return proc -> gid;
80107441:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107447:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
8010744d:	5d                   	pop    %ebp
8010744e:	c3                   	ret    

8010744f <sys_getppid>:

int 
sys_getppid(void)
{
8010744f:	55                   	push   %ebp
80107450:	89 e5                	mov    %esp,%ebp
    if(proc -> parent)
80107452:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107458:	8b 40 14             	mov    0x14(%eax),%eax
8010745b:	85 c0                	test   %eax,%eax
8010745d:	74 0e                	je     8010746d <sys_getppid+0x1e>
	return proc -> parent -> pid;
8010745f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107465:	8b 40 14             	mov    0x14(%eax),%eax
80107468:	8b 40 10             	mov    0x10(%eax),%eax
8010746b:	eb 05                	jmp    80107472 <sys_getppid+0x23>
    else
	return 1;
8010746d:	b8 01 00 00 00       	mov    $0x1,%eax
}
80107472:	5d                   	pop    %ebp
80107473:	c3                   	ret    

80107474 <sys_setuid>:

int 
sys_setuid(void)
{
80107474:	55                   	push   %ebp
80107475:	89 e5                	mov    %esp,%ebp
80107477:	83 ec 18             	sub    $0x18,%esp
    int uid;

    if(argint(0, &uid) < 0)
8010747a:	83 ec 08             	sub    $0x8,%esp
8010747d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107480:	50                   	push   %eax
80107481:	6a 00                	push   $0x0
80107483:	e8 32 ef ff ff       	call   801063ba <argint>
80107488:	83 c4 10             	add    $0x10,%esp
8010748b:	85 c0                	test   %eax,%eax
8010748d:	79 07                	jns    80107496 <sys_setuid+0x22>
	return -1;
8010748f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107494:	eb 2d                	jmp    801074c3 <sys_setuid+0x4f>
    if(uid > 32767 || uid < 0)
80107496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107499:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
8010749e:	7f 07                	jg     801074a7 <sys_setuid+0x33>
801074a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a3:	85 c0                	test   %eax,%eax
801074a5:	79 07                	jns    801074ae <sys_setuid+0x3a>
	return -1;
801074a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074ac:	eb 15                	jmp    801074c3 <sys_setuid+0x4f>
    else
	return proc -> uid = uid;
801074ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801074b7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
801074bd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801074c3:	c9                   	leave  
801074c4:	c3                   	ret    

801074c5 <sys_setgid>:

int 
sys_setgid(void)
{
801074c5:	55                   	push   %ebp
801074c6:	89 e5                	mov    %esp,%ebp
801074c8:	83 ec 18             	sub    $0x18,%esp
    int gid;

    if(argint(0, &gid) < 0)
801074cb:	83 ec 08             	sub    $0x8,%esp
801074ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801074d1:	50                   	push   %eax
801074d2:	6a 00                	push   $0x0
801074d4:	e8 e1 ee ff ff       	call   801063ba <argint>
801074d9:	83 c4 10             	add    $0x10,%esp
801074dc:	85 c0                	test   %eax,%eax
801074de:	79 07                	jns    801074e7 <sys_setgid+0x22>
	return -1;
801074e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074e5:	eb 2d                	jmp    80107514 <sys_setgid+0x4f>
    if(gid > 32767 || gid < 0)
801074e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ea:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801074ef:	7f 07                	jg     801074f8 <sys_setgid+0x33>
801074f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f4:	85 c0                	test   %eax,%eax
801074f6:	79 07                	jns    801074ff <sys_setgid+0x3a>
	return -1;
801074f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074fd:	eb 15                	jmp    80107514 <sys_setgid+0x4f>
    else
	return proc -> gid = gid;
801074ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107505:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107508:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
8010750e:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80107514:	c9                   	leave  
80107515:	c3                   	ret    

80107516 <sys_getprocs>:

int
sys_getprocs(void)
{
80107516:	55                   	push   %ebp
80107517:	89 e5                	mov    %esp,%ebp
80107519:	83 ec 18             	sub    $0x18,%esp
    int num;
    struct uproc *procarray;

    if(argint(0, &num) < 0)
8010751c:	83 ec 08             	sub    $0x8,%esp
8010751f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107522:	50                   	push   %eax
80107523:	6a 00                	push   $0x0
80107525:	e8 90 ee ff ff       	call   801063ba <argint>
8010752a:	83 c4 10             	add    $0x10,%esp
8010752d:	85 c0                	test   %eax,%eax
8010752f:	79 07                	jns    80107538 <sys_getprocs+0x22>
	return -1;
80107531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107536:	eb 36                	jmp    8010756e <sys_getprocs+0x58>
    
    if(argptr(1, (void*)&procarray, sizeof(struct uproc)) < 0)
80107538:	83 ec 04             	sub    $0x4,%esp
8010753b:	6a 5c                	push   $0x5c
8010753d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107540:	50                   	push   %eax
80107541:	6a 01                	push   $0x1
80107543:	e8 9a ee ff ff       	call   801063e2 <argptr>
80107548:	83 c4 10             	add    $0x10,%esp
8010754b:	85 c0                	test   %eax,%eax
8010754d:	79 07                	jns    80107556 <sys_getprocs+0x40>
	return -1;
8010754f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107554:	eb 18                	jmp    8010756e <sys_getprocs+0x58>

   getproctable(num, procarray);
80107556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107559:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010755c:	83 ec 08             	sub    $0x8,%esp
8010755f:	50                   	push   %eax
80107560:	52                   	push   %edx
80107561:	e8 f3 e4 ff ff       	call   80105a59 <getproctable>
80107566:	83 c4 10             	add    $0x10,%esp
   return 1;
80107569:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010756e:	c9                   	leave  
8010756f:	c3                   	ret    

80107570 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107570:	55                   	push   %ebp
80107571:	89 e5                	mov    %esp,%ebp
80107573:	83 ec 08             	sub    $0x8,%esp
80107576:	8b 55 08             	mov    0x8(%ebp),%edx
80107579:	8b 45 0c             	mov    0xc(%ebp),%eax
8010757c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107580:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107583:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107587:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010758b:	ee                   	out    %al,(%dx)
}
8010758c:	90                   	nop
8010758d:	c9                   	leave  
8010758e:	c3                   	ret    

8010758f <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010758f:	55                   	push   %ebp
80107590:	89 e5                	mov    %esp,%ebp
80107592:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107595:	6a 34                	push   $0x34
80107597:	6a 43                	push   $0x43
80107599:	e8 d2 ff ff ff       	call   80107570 <outb>
8010759e:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
801075a1:	68 a9 00 00 00       	push   $0xa9
801075a6:	6a 40                	push   $0x40
801075a8:	e8 c3 ff ff ff       	call   80107570 <outb>
801075ad:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
801075b0:	6a 04                	push   $0x4
801075b2:	6a 40                	push   $0x40
801075b4:	e8 b7 ff ff ff       	call   80107570 <outb>
801075b9:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801075bc:	83 ec 0c             	sub    $0xc,%esp
801075bf:	6a 00                	push   $0x0
801075c1:	e8 0f ca ff ff       	call   80103fd5 <picenable>
801075c6:	83 c4 10             	add    $0x10,%esp
}
801075c9:	90                   	nop
801075ca:	c9                   	leave  
801075cb:	c3                   	ret    

801075cc <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801075cc:	1e                   	push   %ds
  pushl %es
801075cd:	06                   	push   %es
  pushl %fs
801075ce:	0f a0                	push   %fs
  pushl %gs
801075d0:	0f a8                	push   %gs
  pushal
801075d2:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801075d3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801075d7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801075d9:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801075db:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801075df:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801075e1:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801075e3:	54                   	push   %esp
  call trap
801075e4:	e8 ce 01 00 00       	call   801077b7 <trap>
  addl $4, %esp
801075e9:	83 c4 04             	add    $0x4,%esp

801075ec <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801075ec:	61                   	popa   
  popl %gs
801075ed:	0f a9                	pop    %gs
  popl %fs
801075ef:	0f a1                	pop    %fs
  popl %es
801075f1:	07                   	pop    %es
  popl %ds
801075f2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801075f3:	83 c4 08             	add    $0x8,%esp
  iret
801075f6:	cf                   	iret   

801075f7 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
801075f7:	55                   	push   %ebp
801075f8:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
801075fa:	8b 45 08             	mov    0x8(%ebp),%eax
801075fd:	f0 ff 00             	lock incl (%eax)
}
80107600:	90                   	nop
80107601:	5d                   	pop    %ebp
80107602:	c3                   	ret    

80107603 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107603:	55                   	push   %ebp
80107604:	89 e5                	mov    %esp,%ebp
80107606:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107609:	8b 45 0c             	mov    0xc(%ebp),%eax
8010760c:	83 e8 01             	sub    $0x1,%eax
8010760f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107613:	8b 45 08             	mov    0x8(%ebp),%eax
80107616:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010761a:	8b 45 08             	mov    0x8(%ebp),%eax
8010761d:	c1 e8 10             	shr    $0x10,%eax
80107620:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107624:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107627:	0f 01 18             	lidtl  (%eax)
}
8010762a:	90                   	nop
8010762b:	c9                   	leave  
8010762c:	c3                   	ret    

8010762d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010762d:	55                   	push   %ebp
8010762e:	89 e5                	mov    %esp,%ebp
80107630:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107633:	0f 20 d0             	mov    %cr2,%eax
80107636:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107639:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010763c:	c9                   	leave  
8010763d:	c3                   	ret    

8010763e <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
8010763e:	55                   	push   %ebp
8010763f:	89 e5                	mov    %esp,%ebp
80107641:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
80107644:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010764b:	e9 c3 00 00 00       	jmp    80107713 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107650:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107653:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
8010765a:	89 c2                	mov    %eax,%edx
8010765c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010765f:	66 89 14 c5 80 63 11 	mov    %dx,-0x7fee9c80(,%eax,8)
80107666:	80 
80107667:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010766a:	66 c7 04 c5 82 63 11 	movw   $0x8,-0x7fee9c7e(,%eax,8)
80107671:	80 08 00 
80107674:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107677:	0f b6 14 c5 84 63 11 	movzbl -0x7fee9c7c(,%eax,8),%edx
8010767e:	80 
8010767f:	83 e2 e0             	and    $0xffffffe0,%edx
80107682:	88 14 c5 84 63 11 80 	mov    %dl,-0x7fee9c7c(,%eax,8)
80107689:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010768c:	0f b6 14 c5 84 63 11 	movzbl -0x7fee9c7c(,%eax,8),%edx
80107693:	80 
80107694:	83 e2 1f             	and    $0x1f,%edx
80107697:	88 14 c5 84 63 11 80 	mov    %dl,-0x7fee9c7c(,%eax,8)
8010769e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076a1:	0f b6 14 c5 85 63 11 	movzbl -0x7fee9c7b(,%eax,8),%edx
801076a8:	80 
801076a9:	83 e2 f0             	and    $0xfffffff0,%edx
801076ac:	83 ca 0e             	or     $0xe,%edx
801076af:	88 14 c5 85 63 11 80 	mov    %dl,-0x7fee9c7b(,%eax,8)
801076b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076b9:	0f b6 14 c5 85 63 11 	movzbl -0x7fee9c7b(,%eax,8),%edx
801076c0:	80 
801076c1:	83 e2 ef             	and    $0xffffffef,%edx
801076c4:	88 14 c5 85 63 11 80 	mov    %dl,-0x7fee9c7b(,%eax,8)
801076cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076ce:	0f b6 14 c5 85 63 11 	movzbl -0x7fee9c7b(,%eax,8),%edx
801076d5:	80 
801076d6:	83 e2 9f             	and    $0xffffff9f,%edx
801076d9:	88 14 c5 85 63 11 80 	mov    %dl,-0x7fee9c7b(,%eax,8)
801076e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076e3:	0f b6 14 c5 85 63 11 	movzbl -0x7fee9c7b(,%eax,8),%edx
801076ea:	80 
801076eb:	83 ca 80             	or     $0xffffff80,%edx
801076ee:	88 14 c5 85 63 11 80 	mov    %dl,-0x7fee9c7b(,%eax,8)
801076f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076f8:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
801076ff:	c1 e8 10             	shr    $0x10,%eax
80107702:	89 c2                	mov    %eax,%edx
80107704:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107707:	66 89 14 c5 86 63 11 	mov    %dx,-0x7fee9c7a(,%eax,8)
8010770e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010770f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107713:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
8010771a:	0f 8e 30 ff ff ff    	jle    80107650 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107720:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
80107725:	66 a3 80 65 11 80    	mov    %ax,0x80116580
8010772b:	66 c7 05 82 65 11 80 	movw   $0x8,0x80116582
80107732:	08 00 
80107734:	0f b6 05 84 65 11 80 	movzbl 0x80116584,%eax
8010773b:	83 e0 e0             	and    $0xffffffe0,%eax
8010773e:	a2 84 65 11 80       	mov    %al,0x80116584
80107743:	0f b6 05 84 65 11 80 	movzbl 0x80116584,%eax
8010774a:	83 e0 1f             	and    $0x1f,%eax
8010774d:	a2 84 65 11 80       	mov    %al,0x80116584
80107752:	0f b6 05 85 65 11 80 	movzbl 0x80116585,%eax
80107759:	83 c8 0f             	or     $0xf,%eax
8010775c:	a2 85 65 11 80       	mov    %al,0x80116585
80107761:	0f b6 05 85 65 11 80 	movzbl 0x80116585,%eax
80107768:	83 e0 ef             	and    $0xffffffef,%eax
8010776b:	a2 85 65 11 80       	mov    %al,0x80116585
80107770:	0f b6 05 85 65 11 80 	movzbl 0x80116585,%eax
80107777:	83 c8 60             	or     $0x60,%eax
8010777a:	a2 85 65 11 80       	mov    %al,0x80116585
8010777f:	0f b6 05 85 65 11 80 	movzbl 0x80116585,%eax
80107786:	83 c8 80             	or     $0xffffff80,%eax
80107789:	a2 85 65 11 80       	mov    %al,0x80116585
8010778e:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
80107793:	c1 e8 10             	shr    $0x10,%eax
80107796:	66 a3 86 65 11 80    	mov    %ax,0x80116586
  
}
8010779c:	90                   	nop
8010779d:	c9                   	leave  
8010779e:	c3                   	ret    

8010779f <idtinit>:

void
idtinit(void)
{
8010779f:	55                   	push   %ebp
801077a0:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801077a2:	68 00 08 00 00       	push   $0x800
801077a7:	68 80 63 11 80       	push   $0x80116380
801077ac:	e8 52 fe ff ff       	call   80107603 <lidt>
801077b1:	83 c4 08             	add    $0x8,%esp
}
801077b4:	90                   	nop
801077b5:	c9                   	leave  
801077b6:	c3                   	ret    

801077b7 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801077b7:	55                   	push   %ebp
801077b8:	89 e5                	mov    %esp,%ebp
801077ba:	57                   	push   %edi
801077bb:	56                   	push   %esi
801077bc:	53                   	push   %ebx
801077bd:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801077c0:	8b 45 08             	mov    0x8(%ebp),%eax
801077c3:	8b 40 30             	mov    0x30(%eax),%eax
801077c6:	83 f8 40             	cmp    $0x40,%eax
801077c9:	75 3e                	jne    80107809 <trap+0x52>
    if(proc->killed)
801077cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077d1:	8b 40 24             	mov    0x24(%eax),%eax
801077d4:	85 c0                	test   %eax,%eax
801077d6:	74 05                	je     801077dd <trap+0x26>
      exit();
801077d8:	e8 7f d6 ff ff       	call   80104e5c <exit>
    proc->tf = tf;
801077dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077e3:	8b 55 08             	mov    0x8(%ebp),%edx
801077e6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801077e9:	e8 82 ec ff ff       	call   80106470 <syscall>
    if(proc->killed)
801077ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077f4:	8b 40 24             	mov    0x24(%eax),%eax
801077f7:	85 c0                	test   %eax,%eax
801077f9:	0f 84 21 02 00 00    	je     80107a20 <trap+0x269>
      exit();
801077ff:	e8 58 d6 ff ff       	call   80104e5c <exit>
    return;
80107804:	e9 17 02 00 00       	jmp    80107a20 <trap+0x269>
  }

  switch(tf->trapno){
80107809:	8b 45 08             	mov    0x8(%ebp),%eax
8010780c:	8b 40 30             	mov    0x30(%eax),%eax
8010780f:	83 e8 20             	sub    $0x20,%eax
80107812:	83 f8 1f             	cmp    $0x1f,%eax
80107815:	0f 87 a3 00 00 00    	ja     801078be <trap+0x107>
8010781b:	8b 04 85 7c 9c 10 80 	mov    -0x7fef6384(,%eax,4),%eax
80107822:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80107824:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010782a:	0f b6 00             	movzbl (%eax),%eax
8010782d:	84 c0                	test   %al,%al
8010782f:	75 20                	jne    80107851 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
80107831:	83 ec 0c             	sub    $0xc,%esp
80107834:	68 80 6b 11 80       	push   $0x80116b80
80107839:	e8 b9 fd ff ff       	call   801075f7 <atom_inc>
8010783e:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
80107841:	83 ec 0c             	sub    $0xc,%esp
80107844:	68 80 6b 11 80       	push   $0x80116b80
80107849:	e8 30 dd ff ff       	call   8010557e <wakeup>
8010784e:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107851:	e8 79 b8 ff ff       	call   801030cf <lapiceoi>
    break;
80107856:	e9 1c 01 00 00       	jmp    80107977 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010785b:	e8 82 b0 ff ff       	call   801028e2 <ideintr>
    lapiceoi();
80107860:	e8 6a b8 ff ff       	call   801030cf <lapiceoi>
    break;
80107865:	e9 0d 01 00 00       	jmp    80107977 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010786a:	e8 62 b6 ff ff       	call   80102ed1 <kbdintr>
    lapiceoi();
8010786f:	e8 5b b8 ff ff       	call   801030cf <lapiceoi>
    break;
80107874:	e9 fe 00 00 00       	jmp    80107977 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107879:	e8 83 03 00 00       	call   80107c01 <uartintr>
    lapiceoi();
8010787e:	e8 4c b8 ff ff       	call   801030cf <lapiceoi>
    break;
80107883:	e9 ef 00 00 00       	jmp    80107977 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107888:	8b 45 08             	mov    0x8(%ebp),%eax
8010788b:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010788e:	8b 45 08             	mov    0x8(%ebp),%eax
80107891:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107895:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107898:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010789e:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801078a1:	0f b6 c0             	movzbl %al,%eax
801078a4:	51                   	push   %ecx
801078a5:	52                   	push   %edx
801078a6:	50                   	push   %eax
801078a7:	68 dc 9b 10 80       	push   $0x80109bdc
801078ac:	e8 15 8b ff ff       	call   801003c6 <cprintf>
801078b1:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801078b4:	e8 16 b8 ff ff       	call   801030cf <lapiceoi>
    break;
801078b9:	e9 b9 00 00 00       	jmp    80107977 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801078be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078c4:	85 c0                	test   %eax,%eax
801078c6:	74 11                	je     801078d9 <trap+0x122>
801078c8:	8b 45 08             	mov    0x8(%ebp),%eax
801078cb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078cf:	0f b7 c0             	movzwl %ax,%eax
801078d2:	83 e0 03             	and    $0x3,%eax
801078d5:	85 c0                	test   %eax,%eax
801078d7:	75 40                	jne    80107919 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801078d9:	e8 4f fd ff ff       	call   8010762d <rcr2>
801078de:	89 c3                	mov    %eax,%ebx
801078e0:	8b 45 08             	mov    0x8(%ebp),%eax
801078e3:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801078e6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078ec:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801078ef:	0f b6 d0             	movzbl %al,%edx
801078f2:	8b 45 08             	mov    0x8(%ebp),%eax
801078f5:	8b 40 30             	mov    0x30(%eax),%eax
801078f8:	83 ec 0c             	sub    $0xc,%esp
801078fb:	53                   	push   %ebx
801078fc:	51                   	push   %ecx
801078fd:	52                   	push   %edx
801078fe:	50                   	push   %eax
801078ff:	68 00 9c 10 80       	push   $0x80109c00
80107904:	e8 bd 8a ff ff       	call   801003c6 <cprintf>
80107909:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010790c:	83 ec 0c             	sub    $0xc,%esp
8010790f:	68 32 9c 10 80       	push   $0x80109c32
80107914:	e8 4d 8c ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107919:	e8 0f fd ff ff       	call   8010762d <rcr2>
8010791e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107921:	8b 45 08             	mov    0x8(%ebp),%eax
80107924:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107927:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010792d:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107930:	0f b6 d8             	movzbl %al,%ebx
80107933:	8b 45 08             	mov    0x8(%ebp),%eax
80107936:	8b 48 34             	mov    0x34(%eax),%ecx
80107939:	8b 45 08             	mov    0x8(%ebp),%eax
8010793c:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010793f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107945:	8d 78 6c             	lea    0x6c(%eax),%edi
80107948:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010794e:	8b 40 10             	mov    0x10(%eax),%eax
80107951:	ff 75 e4             	pushl  -0x1c(%ebp)
80107954:	56                   	push   %esi
80107955:	53                   	push   %ebx
80107956:	51                   	push   %ecx
80107957:	52                   	push   %edx
80107958:	57                   	push   %edi
80107959:	50                   	push   %eax
8010795a:	68 38 9c 10 80       	push   $0x80109c38
8010795f:	e8 62 8a ff ff       	call   801003c6 <cprintf>
80107964:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107967:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010796d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107974:	eb 01                	jmp    80107977 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107976:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107977:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010797d:	85 c0                	test   %eax,%eax
8010797f:	74 24                	je     801079a5 <trap+0x1ee>
80107981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107987:	8b 40 24             	mov    0x24(%eax),%eax
8010798a:	85 c0                	test   %eax,%eax
8010798c:	74 17                	je     801079a5 <trap+0x1ee>
8010798e:	8b 45 08             	mov    0x8(%ebp),%eax
80107991:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107995:	0f b7 c0             	movzwl %ax,%eax
80107998:	83 e0 03             	and    $0x3,%eax
8010799b:	83 f8 03             	cmp    $0x3,%eax
8010799e:	75 05                	jne    801079a5 <trap+0x1ee>
    exit();
801079a0:	e8 b7 d4 ff ff       	call   80104e5c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
801079a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801079ab:	85 c0                	test   %eax,%eax
801079ad:	74 41                	je     801079f0 <trap+0x239>
801079af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801079b5:	8b 40 0c             	mov    0xc(%eax),%eax
801079b8:	83 f8 04             	cmp    $0x4,%eax
801079bb:	75 33                	jne    801079f0 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801079bd:	8b 45 08             	mov    0x8(%ebp),%eax
801079c0:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
801079c3:	83 f8 20             	cmp    $0x20,%eax
801079c6:	75 28                	jne    801079f0 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801079c8:	8b 0d 80 6b 11 80    	mov    0x80116b80,%ecx
801079ce:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801079d3:	89 c8                	mov    %ecx,%eax
801079d5:	f7 e2                	mul    %edx
801079d7:	c1 ea 03             	shr    $0x3,%edx
801079da:	89 d0                	mov    %edx,%eax
801079dc:	c1 e0 02             	shl    $0x2,%eax
801079df:	01 d0                	add    %edx,%eax
801079e1:	01 c0                	add    %eax,%eax
801079e3:	29 c1                	sub    %eax,%ecx
801079e5:	89 ca                	mov    %ecx,%edx
801079e7:	85 d2                	test   %edx,%edx
801079e9:	75 05                	jne    801079f0 <trap+0x239>
    yield();
801079eb:	e8 42 d9 ff ff       	call   80105332 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801079f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801079f6:	85 c0                	test   %eax,%eax
801079f8:	74 27                	je     80107a21 <trap+0x26a>
801079fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a00:	8b 40 24             	mov    0x24(%eax),%eax
80107a03:	85 c0                	test   %eax,%eax
80107a05:	74 1a                	je     80107a21 <trap+0x26a>
80107a07:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107a0e:	0f b7 c0             	movzwl %ax,%eax
80107a11:	83 e0 03             	and    $0x3,%eax
80107a14:	83 f8 03             	cmp    $0x3,%eax
80107a17:	75 08                	jne    80107a21 <trap+0x26a>
    exit();
80107a19:	e8 3e d4 ff ff       	call   80104e5c <exit>
80107a1e:	eb 01                	jmp    80107a21 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107a20:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a24:	5b                   	pop    %ebx
80107a25:	5e                   	pop    %esi
80107a26:	5f                   	pop    %edi
80107a27:	5d                   	pop    %ebp
80107a28:	c3                   	ret    

80107a29 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80107a29:	55                   	push   %ebp
80107a2a:	89 e5                	mov    %esp,%ebp
80107a2c:	83 ec 14             	sub    $0x14,%esp
80107a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a32:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107a36:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107a3a:	89 c2                	mov    %eax,%edx
80107a3c:	ec                   	in     (%dx),%al
80107a3d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107a40:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107a44:	c9                   	leave  
80107a45:	c3                   	ret    

80107a46 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107a46:	55                   	push   %ebp
80107a47:	89 e5                	mov    %esp,%ebp
80107a49:	83 ec 08             	sub    $0x8,%esp
80107a4c:	8b 55 08             	mov    0x8(%ebp),%edx
80107a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a52:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107a56:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107a59:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107a5d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107a61:	ee                   	out    %al,(%dx)
}
80107a62:	90                   	nop
80107a63:	c9                   	leave  
80107a64:	c3                   	ret    

80107a65 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107a65:	55                   	push   %ebp
80107a66:	89 e5                	mov    %esp,%ebp
80107a68:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107a6b:	6a 00                	push   $0x0
80107a6d:	68 fa 03 00 00       	push   $0x3fa
80107a72:	e8 cf ff ff ff       	call   80107a46 <outb>
80107a77:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107a7a:	68 80 00 00 00       	push   $0x80
80107a7f:	68 fb 03 00 00       	push   $0x3fb
80107a84:	e8 bd ff ff ff       	call   80107a46 <outb>
80107a89:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107a8c:	6a 0c                	push   $0xc
80107a8e:	68 f8 03 00 00       	push   $0x3f8
80107a93:	e8 ae ff ff ff       	call   80107a46 <outb>
80107a98:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107a9b:	6a 00                	push   $0x0
80107a9d:	68 f9 03 00 00       	push   $0x3f9
80107aa2:	e8 9f ff ff ff       	call   80107a46 <outb>
80107aa7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107aaa:	6a 03                	push   $0x3
80107aac:	68 fb 03 00 00       	push   $0x3fb
80107ab1:	e8 90 ff ff ff       	call   80107a46 <outb>
80107ab6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107ab9:	6a 00                	push   $0x0
80107abb:	68 fc 03 00 00       	push   $0x3fc
80107ac0:	e8 81 ff ff ff       	call   80107a46 <outb>
80107ac5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107ac8:	6a 01                	push   $0x1
80107aca:	68 f9 03 00 00       	push   $0x3f9
80107acf:	e8 72 ff ff ff       	call   80107a46 <outb>
80107ad4:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107ad7:	68 fd 03 00 00       	push   $0x3fd
80107adc:	e8 48 ff ff ff       	call   80107a29 <inb>
80107ae1:	83 c4 04             	add    $0x4,%esp
80107ae4:	3c ff                	cmp    $0xff,%al
80107ae6:	74 6e                	je     80107b56 <uartinit+0xf1>
    return;
  uart = 1;
80107ae8:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107aef:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107af2:	68 fa 03 00 00       	push   $0x3fa
80107af7:	e8 2d ff ff ff       	call   80107a29 <inb>
80107afc:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107aff:	68 f8 03 00 00       	push   $0x3f8
80107b04:	e8 20 ff ff ff       	call   80107a29 <inb>
80107b09:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107b0c:	83 ec 0c             	sub    $0xc,%esp
80107b0f:	6a 04                	push   $0x4
80107b11:	e8 bf c4 ff ff       	call   80103fd5 <picenable>
80107b16:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107b19:	83 ec 08             	sub    $0x8,%esp
80107b1c:	6a 00                	push   $0x0
80107b1e:	6a 04                	push   $0x4
80107b20:	e8 5f b0 ff ff       	call   80102b84 <ioapicenable>
80107b25:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107b28:	c7 45 f4 fc 9c 10 80 	movl   $0x80109cfc,-0xc(%ebp)
80107b2f:	eb 19                	jmp    80107b4a <uartinit+0xe5>
    uartputc(*p);
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	0f b6 00             	movzbl (%eax),%eax
80107b37:	0f be c0             	movsbl %al,%eax
80107b3a:	83 ec 0c             	sub    $0xc,%esp
80107b3d:	50                   	push   %eax
80107b3e:	e8 16 00 00 00       	call   80107b59 <uartputc>
80107b43:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107b46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4d:	0f b6 00             	movzbl (%eax),%eax
80107b50:	84 c0                	test   %al,%al
80107b52:	75 dd                	jne    80107b31 <uartinit+0xcc>
80107b54:	eb 01                	jmp    80107b57 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107b56:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107b57:	c9                   	leave  
80107b58:	c3                   	ret    

80107b59 <uartputc>:

void
uartputc(int c)
{
80107b59:	55                   	push   %ebp
80107b5a:	89 e5                	mov    %esp,%ebp
80107b5c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107b5f:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107b64:	85 c0                	test   %eax,%eax
80107b66:	74 53                	je     80107bbb <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b6f:	eb 11                	jmp    80107b82 <uartputc+0x29>
    microdelay(10);
80107b71:	83 ec 0c             	sub    $0xc,%esp
80107b74:	6a 0a                	push   $0xa
80107b76:	e8 6f b5 ff ff       	call   801030ea <microdelay>
80107b7b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b82:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b86:	7f 1a                	jg     80107ba2 <uartputc+0x49>
80107b88:	83 ec 0c             	sub    $0xc,%esp
80107b8b:	68 fd 03 00 00       	push   $0x3fd
80107b90:	e8 94 fe ff ff       	call   80107a29 <inb>
80107b95:	83 c4 10             	add    $0x10,%esp
80107b98:	0f b6 c0             	movzbl %al,%eax
80107b9b:	83 e0 20             	and    $0x20,%eax
80107b9e:	85 c0                	test   %eax,%eax
80107ba0:	74 cf                	je     80107b71 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba5:	0f b6 c0             	movzbl %al,%eax
80107ba8:	83 ec 08             	sub    $0x8,%esp
80107bab:	50                   	push   %eax
80107bac:	68 f8 03 00 00       	push   $0x3f8
80107bb1:	e8 90 fe ff ff       	call   80107a46 <outb>
80107bb6:	83 c4 10             	add    $0x10,%esp
80107bb9:	eb 01                	jmp    80107bbc <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107bbb:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107bbc:	c9                   	leave  
80107bbd:	c3                   	ret    

80107bbe <uartgetc>:

static int
uartgetc(void)
{
80107bbe:	55                   	push   %ebp
80107bbf:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107bc1:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107bc6:	85 c0                	test   %eax,%eax
80107bc8:	75 07                	jne    80107bd1 <uartgetc+0x13>
    return -1;
80107bca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bcf:	eb 2e                	jmp    80107bff <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107bd1:	68 fd 03 00 00       	push   $0x3fd
80107bd6:	e8 4e fe ff ff       	call   80107a29 <inb>
80107bdb:	83 c4 04             	add    $0x4,%esp
80107bde:	0f b6 c0             	movzbl %al,%eax
80107be1:	83 e0 01             	and    $0x1,%eax
80107be4:	85 c0                	test   %eax,%eax
80107be6:	75 07                	jne    80107bef <uartgetc+0x31>
    return -1;
80107be8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bed:	eb 10                	jmp    80107bff <uartgetc+0x41>
  return inb(COM1+0);
80107bef:	68 f8 03 00 00       	push   $0x3f8
80107bf4:	e8 30 fe ff ff       	call   80107a29 <inb>
80107bf9:	83 c4 04             	add    $0x4,%esp
80107bfc:	0f b6 c0             	movzbl %al,%eax
}
80107bff:	c9                   	leave  
80107c00:	c3                   	ret    

80107c01 <uartintr>:

void
uartintr(void)
{
80107c01:	55                   	push   %ebp
80107c02:	89 e5                	mov    %esp,%ebp
80107c04:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107c07:	83 ec 0c             	sub    $0xc,%esp
80107c0a:	68 be 7b 10 80       	push   $0x80107bbe
80107c0f:	e8 e5 8b ff ff       	call   801007f9 <consoleintr>
80107c14:	83 c4 10             	add    $0x10,%esp
}
80107c17:	90                   	nop
80107c18:	c9                   	leave  
80107c19:	c3                   	ret    

80107c1a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $0
80107c1c:	6a 00                	push   $0x0
  jmp alltraps
80107c1e:	e9 a9 f9 ff ff       	jmp    801075cc <alltraps>

80107c23 <vector1>:
.globl vector1
vector1:
  pushl $0
80107c23:	6a 00                	push   $0x0
  pushl $1
80107c25:	6a 01                	push   $0x1
  jmp alltraps
80107c27:	e9 a0 f9 ff ff       	jmp    801075cc <alltraps>

80107c2c <vector2>:
.globl vector2
vector2:
  pushl $0
80107c2c:	6a 00                	push   $0x0
  pushl $2
80107c2e:	6a 02                	push   $0x2
  jmp alltraps
80107c30:	e9 97 f9 ff ff       	jmp    801075cc <alltraps>

80107c35 <vector3>:
.globl vector3
vector3:
  pushl $0
80107c35:	6a 00                	push   $0x0
  pushl $3
80107c37:	6a 03                	push   $0x3
  jmp alltraps
80107c39:	e9 8e f9 ff ff       	jmp    801075cc <alltraps>

80107c3e <vector4>:
.globl vector4
vector4:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $4
80107c40:	6a 04                	push   $0x4
  jmp alltraps
80107c42:	e9 85 f9 ff ff       	jmp    801075cc <alltraps>

80107c47 <vector5>:
.globl vector5
vector5:
  pushl $0
80107c47:	6a 00                	push   $0x0
  pushl $5
80107c49:	6a 05                	push   $0x5
  jmp alltraps
80107c4b:	e9 7c f9 ff ff       	jmp    801075cc <alltraps>

80107c50 <vector6>:
.globl vector6
vector6:
  pushl $0
80107c50:	6a 00                	push   $0x0
  pushl $6
80107c52:	6a 06                	push   $0x6
  jmp alltraps
80107c54:	e9 73 f9 ff ff       	jmp    801075cc <alltraps>

80107c59 <vector7>:
.globl vector7
vector7:
  pushl $0
80107c59:	6a 00                	push   $0x0
  pushl $7
80107c5b:	6a 07                	push   $0x7
  jmp alltraps
80107c5d:	e9 6a f9 ff ff       	jmp    801075cc <alltraps>

80107c62 <vector8>:
.globl vector8
vector8:
  pushl $8
80107c62:	6a 08                	push   $0x8
  jmp alltraps
80107c64:	e9 63 f9 ff ff       	jmp    801075cc <alltraps>

80107c69 <vector9>:
.globl vector9
vector9:
  pushl $0
80107c69:	6a 00                	push   $0x0
  pushl $9
80107c6b:	6a 09                	push   $0x9
  jmp alltraps
80107c6d:	e9 5a f9 ff ff       	jmp    801075cc <alltraps>

80107c72 <vector10>:
.globl vector10
vector10:
  pushl $10
80107c72:	6a 0a                	push   $0xa
  jmp alltraps
80107c74:	e9 53 f9 ff ff       	jmp    801075cc <alltraps>

80107c79 <vector11>:
.globl vector11
vector11:
  pushl $11
80107c79:	6a 0b                	push   $0xb
  jmp alltraps
80107c7b:	e9 4c f9 ff ff       	jmp    801075cc <alltraps>

80107c80 <vector12>:
.globl vector12
vector12:
  pushl $12
80107c80:	6a 0c                	push   $0xc
  jmp alltraps
80107c82:	e9 45 f9 ff ff       	jmp    801075cc <alltraps>

80107c87 <vector13>:
.globl vector13
vector13:
  pushl $13
80107c87:	6a 0d                	push   $0xd
  jmp alltraps
80107c89:	e9 3e f9 ff ff       	jmp    801075cc <alltraps>

80107c8e <vector14>:
.globl vector14
vector14:
  pushl $14
80107c8e:	6a 0e                	push   $0xe
  jmp alltraps
80107c90:	e9 37 f9 ff ff       	jmp    801075cc <alltraps>

80107c95 <vector15>:
.globl vector15
vector15:
  pushl $0
80107c95:	6a 00                	push   $0x0
  pushl $15
80107c97:	6a 0f                	push   $0xf
  jmp alltraps
80107c99:	e9 2e f9 ff ff       	jmp    801075cc <alltraps>

80107c9e <vector16>:
.globl vector16
vector16:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $16
80107ca0:	6a 10                	push   $0x10
  jmp alltraps
80107ca2:	e9 25 f9 ff ff       	jmp    801075cc <alltraps>

80107ca7 <vector17>:
.globl vector17
vector17:
  pushl $17
80107ca7:	6a 11                	push   $0x11
  jmp alltraps
80107ca9:	e9 1e f9 ff ff       	jmp    801075cc <alltraps>

80107cae <vector18>:
.globl vector18
vector18:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $18
80107cb0:	6a 12                	push   $0x12
  jmp alltraps
80107cb2:	e9 15 f9 ff ff       	jmp    801075cc <alltraps>

80107cb7 <vector19>:
.globl vector19
vector19:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $19
80107cb9:	6a 13                	push   $0x13
  jmp alltraps
80107cbb:	e9 0c f9 ff ff       	jmp    801075cc <alltraps>

80107cc0 <vector20>:
.globl vector20
vector20:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $20
80107cc2:	6a 14                	push   $0x14
  jmp alltraps
80107cc4:	e9 03 f9 ff ff       	jmp    801075cc <alltraps>

80107cc9 <vector21>:
.globl vector21
vector21:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $21
80107ccb:	6a 15                	push   $0x15
  jmp alltraps
80107ccd:	e9 fa f8 ff ff       	jmp    801075cc <alltraps>

80107cd2 <vector22>:
.globl vector22
vector22:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $22
80107cd4:	6a 16                	push   $0x16
  jmp alltraps
80107cd6:	e9 f1 f8 ff ff       	jmp    801075cc <alltraps>

80107cdb <vector23>:
.globl vector23
vector23:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $23
80107cdd:	6a 17                	push   $0x17
  jmp alltraps
80107cdf:	e9 e8 f8 ff ff       	jmp    801075cc <alltraps>

80107ce4 <vector24>:
.globl vector24
vector24:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $24
80107ce6:	6a 18                	push   $0x18
  jmp alltraps
80107ce8:	e9 df f8 ff ff       	jmp    801075cc <alltraps>

80107ced <vector25>:
.globl vector25
vector25:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $25
80107cef:	6a 19                	push   $0x19
  jmp alltraps
80107cf1:	e9 d6 f8 ff ff       	jmp    801075cc <alltraps>

80107cf6 <vector26>:
.globl vector26
vector26:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $26
80107cf8:	6a 1a                	push   $0x1a
  jmp alltraps
80107cfa:	e9 cd f8 ff ff       	jmp    801075cc <alltraps>

80107cff <vector27>:
.globl vector27
vector27:
  pushl $0
80107cff:	6a 00                	push   $0x0
  pushl $27
80107d01:	6a 1b                	push   $0x1b
  jmp alltraps
80107d03:	e9 c4 f8 ff ff       	jmp    801075cc <alltraps>

80107d08 <vector28>:
.globl vector28
vector28:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $28
80107d0a:	6a 1c                	push   $0x1c
  jmp alltraps
80107d0c:	e9 bb f8 ff ff       	jmp    801075cc <alltraps>

80107d11 <vector29>:
.globl vector29
vector29:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $29
80107d13:	6a 1d                	push   $0x1d
  jmp alltraps
80107d15:	e9 b2 f8 ff ff       	jmp    801075cc <alltraps>

80107d1a <vector30>:
.globl vector30
vector30:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $30
80107d1c:	6a 1e                	push   $0x1e
  jmp alltraps
80107d1e:	e9 a9 f8 ff ff       	jmp    801075cc <alltraps>

80107d23 <vector31>:
.globl vector31
vector31:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $31
80107d25:	6a 1f                	push   $0x1f
  jmp alltraps
80107d27:	e9 a0 f8 ff ff       	jmp    801075cc <alltraps>

80107d2c <vector32>:
.globl vector32
vector32:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $32
80107d2e:	6a 20                	push   $0x20
  jmp alltraps
80107d30:	e9 97 f8 ff ff       	jmp    801075cc <alltraps>

80107d35 <vector33>:
.globl vector33
vector33:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $33
80107d37:	6a 21                	push   $0x21
  jmp alltraps
80107d39:	e9 8e f8 ff ff       	jmp    801075cc <alltraps>

80107d3e <vector34>:
.globl vector34
vector34:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $34
80107d40:	6a 22                	push   $0x22
  jmp alltraps
80107d42:	e9 85 f8 ff ff       	jmp    801075cc <alltraps>

80107d47 <vector35>:
.globl vector35
vector35:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $35
80107d49:	6a 23                	push   $0x23
  jmp alltraps
80107d4b:	e9 7c f8 ff ff       	jmp    801075cc <alltraps>

80107d50 <vector36>:
.globl vector36
vector36:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $36
80107d52:	6a 24                	push   $0x24
  jmp alltraps
80107d54:	e9 73 f8 ff ff       	jmp    801075cc <alltraps>

80107d59 <vector37>:
.globl vector37
vector37:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $37
80107d5b:	6a 25                	push   $0x25
  jmp alltraps
80107d5d:	e9 6a f8 ff ff       	jmp    801075cc <alltraps>

80107d62 <vector38>:
.globl vector38
vector38:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $38
80107d64:	6a 26                	push   $0x26
  jmp alltraps
80107d66:	e9 61 f8 ff ff       	jmp    801075cc <alltraps>

80107d6b <vector39>:
.globl vector39
vector39:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $39
80107d6d:	6a 27                	push   $0x27
  jmp alltraps
80107d6f:	e9 58 f8 ff ff       	jmp    801075cc <alltraps>

80107d74 <vector40>:
.globl vector40
vector40:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $40
80107d76:	6a 28                	push   $0x28
  jmp alltraps
80107d78:	e9 4f f8 ff ff       	jmp    801075cc <alltraps>

80107d7d <vector41>:
.globl vector41
vector41:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $41
80107d7f:	6a 29                	push   $0x29
  jmp alltraps
80107d81:	e9 46 f8 ff ff       	jmp    801075cc <alltraps>

80107d86 <vector42>:
.globl vector42
vector42:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $42
80107d88:	6a 2a                	push   $0x2a
  jmp alltraps
80107d8a:	e9 3d f8 ff ff       	jmp    801075cc <alltraps>

80107d8f <vector43>:
.globl vector43
vector43:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $43
80107d91:	6a 2b                	push   $0x2b
  jmp alltraps
80107d93:	e9 34 f8 ff ff       	jmp    801075cc <alltraps>

80107d98 <vector44>:
.globl vector44
vector44:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $44
80107d9a:	6a 2c                	push   $0x2c
  jmp alltraps
80107d9c:	e9 2b f8 ff ff       	jmp    801075cc <alltraps>

80107da1 <vector45>:
.globl vector45
vector45:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $45
80107da3:	6a 2d                	push   $0x2d
  jmp alltraps
80107da5:	e9 22 f8 ff ff       	jmp    801075cc <alltraps>

80107daa <vector46>:
.globl vector46
vector46:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $46
80107dac:	6a 2e                	push   $0x2e
  jmp alltraps
80107dae:	e9 19 f8 ff ff       	jmp    801075cc <alltraps>

80107db3 <vector47>:
.globl vector47
vector47:
  pushl $0
80107db3:	6a 00                	push   $0x0
  pushl $47
80107db5:	6a 2f                	push   $0x2f
  jmp alltraps
80107db7:	e9 10 f8 ff ff       	jmp    801075cc <alltraps>

80107dbc <vector48>:
.globl vector48
vector48:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $48
80107dbe:	6a 30                	push   $0x30
  jmp alltraps
80107dc0:	e9 07 f8 ff ff       	jmp    801075cc <alltraps>

80107dc5 <vector49>:
.globl vector49
vector49:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $49
80107dc7:	6a 31                	push   $0x31
  jmp alltraps
80107dc9:	e9 fe f7 ff ff       	jmp    801075cc <alltraps>

80107dce <vector50>:
.globl vector50
vector50:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $50
80107dd0:	6a 32                	push   $0x32
  jmp alltraps
80107dd2:	e9 f5 f7 ff ff       	jmp    801075cc <alltraps>

80107dd7 <vector51>:
.globl vector51
vector51:
  pushl $0
80107dd7:	6a 00                	push   $0x0
  pushl $51
80107dd9:	6a 33                	push   $0x33
  jmp alltraps
80107ddb:	e9 ec f7 ff ff       	jmp    801075cc <alltraps>

80107de0 <vector52>:
.globl vector52
vector52:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $52
80107de2:	6a 34                	push   $0x34
  jmp alltraps
80107de4:	e9 e3 f7 ff ff       	jmp    801075cc <alltraps>

80107de9 <vector53>:
.globl vector53
vector53:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $53
80107deb:	6a 35                	push   $0x35
  jmp alltraps
80107ded:	e9 da f7 ff ff       	jmp    801075cc <alltraps>

80107df2 <vector54>:
.globl vector54
vector54:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $54
80107df4:	6a 36                	push   $0x36
  jmp alltraps
80107df6:	e9 d1 f7 ff ff       	jmp    801075cc <alltraps>

80107dfb <vector55>:
.globl vector55
vector55:
  pushl $0
80107dfb:	6a 00                	push   $0x0
  pushl $55
80107dfd:	6a 37                	push   $0x37
  jmp alltraps
80107dff:	e9 c8 f7 ff ff       	jmp    801075cc <alltraps>

80107e04 <vector56>:
.globl vector56
vector56:
  pushl $0
80107e04:	6a 00                	push   $0x0
  pushl $56
80107e06:	6a 38                	push   $0x38
  jmp alltraps
80107e08:	e9 bf f7 ff ff       	jmp    801075cc <alltraps>

80107e0d <vector57>:
.globl vector57
vector57:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $57
80107e0f:	6a 39                	push   $0x39
  jmp alltraps
80107e11:	e9 b6 f7 ff ff       	jmp    801075cc <alltraps>

80107e16 <vector58>:
.globl vector58
vector58:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $58
80107e18:	6a 3a                	push   $0x3a
  jmp alltraps
80107e1a:	e9 ad f7 ff ff       	jmp    801075cc <alltraps>

80107e1f <vector59>:
.globl vector59
vector59:
  pushl $0
80107e1f:	6a 00                	push   $0x0
  pushl $59
80107e21:	6a 3b                	push   $0x3b
  jmp alltraps
80107e23:	e9 a4 f7 ff ff       	jmp    801075cc <alltraps>

80107e28 <vector60>:
.globl vector60
vector60:
  pushl $0
80107e28:	6a 00                	push   $0x0
  pushl $60
80107e2a:	6a 3c                	push   $0x3c
  jmp alltraps
80107e2c:	e9 9b f7 ff ff       	jmp    801075cc <alltraps>

80107e31 <vector61>:
.globl vector61
vector61:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $61
80107e33:	6a 3d                	push   $0x3d
  jmp alltraps
80107e35:	e9 92 f7 ff ff       	jmp    801075cc <alltraps>

80107e3a <vector62>:
.globl vector62
vector62:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $62
80107e3c:	6a 3e                	push   $0x3e
  jmp alltraps
80107e3e:	e9 89 f7 ff ff       	jmp    801075cc <alltraps>

80107e43 <vector63>:
.globl vector63
vector63:
  pushl $0
80107e43:	6a 00                	push   $0x0
  pushl $63
80107e45:	6a 3f                	push   $0x3f
  jmp alltraps
80107e47:	e9 80 f7 ff ff       	jmp    801075cc <alltraps>

80107e4c <vector64>:
.globl vector64
vector64:
  pushl $0
80107e4c:	6a 00                	push   $0x0
  pushl $64
80107e4e:	6a 40                	push   $0x40
  jmp alltraps
80107e50:	e9 77 f7 ff ff       	jmp    801075cc <alltraps>

80107e55 <vector65>:
.globl vector65
vector65:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $65
80107e57:	6a 41                	push   $0x41
  jmp alltraps
80107e59:	e9 6e f7 ff ff       	jmp    801075cc <alltraps>

80107e5e <vector66>:
.globl vector66
vector66:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $66
80107e60:	6a 42                	push   $0x42
  jmp alltraps
80107e62:	e9 65 f7 ff ff       	jmp    801075cc <alltraps>

80107e67 <vector67>:
.globl vector67
vector67:
  pushl $0
80107e67:	6a 00                	push   $0x0
  pushl $67
80107e69:	6a 43                	push   $0x43
  jmp alltraps
80107e6b:	e9 5c f7 ff ff       	jmp    801075cc <alltraps>

80107e70 <vector68>:
.globl vector68
vector68:
  pushl $0
80107e70:	6a 00                	push   $0x0
  pushl $68
80107e72:	6a 44                	push   $0x44
  jmp alltraps
80107e74:	e9 53 f7 ff ff       	jmp    801075cc <alltraps>

80107e79 <vector69>:
.globl vector69
vector69:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $69
80107e7b:	6a 45                	push   $0x45
  jmp alltraps
80107e7d:	e9 4a f7 ff ff       	jmp    801075cc <alltraps>

80107e82 <vector70>:
.globl vector70
vector70:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $70
80107e84:	6a 46                	push   $0x46
  jmp alltraps
80107e86:	e9 41 f7 ff ff       	jmp    801075cc <alltraps>

80107e8b <vector71>:
.globl vector71
vector71:
  pushl $0
80107e8b:	6a 00                	push   $0x0
  pushl $71
80107e8d:	6a 47                	push   $0x47
  jmp alltraps
80107e8f:	e9 38 f7 ff ff       	jmp    801075cc <alltraps>

80107e94 <vector72>:
.globl vector72
vector72:
  pushl $0
80107e94:	6a 00                	push   $0x0
  pushl $72
80107e96:	6a 48                	push   $0x48
  jmp alltraps
80107e98:	e9 2f f7 ff ff       	jmp    801075cc <alltraps>

80107e9d <vector73>:
.globl vector73
vector73:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $73
80107e9f:	6a 49                	push   $0x49
  jmp alltraps
80107ea1:	e9 26 f7 ff ff       	jmp    801075cc <alltraps>

80107ea6 <vector74>:
.globl vector74
vector74:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $74
80107ea8:	6a 4a                	push   $0x4a
  jmp alltraps
80107eaa:	e9 1d f7 ff ff       	jmp    801075cc <alltraps>

80107eaf <vector75>:
.globl vector75
vector75:
  pushl $0
80107eaf:	6a 00                	push   $0x0
  pushl $75
80107eb1:	6a 4b                	push   $0x4b
  jmp alltraps
80107eb3:	e9 14 f7 ff ff       	jmp    801075cc <alltraps>

80107eb8 <vector76>:
.globl vector76
vector76:
  pushl $0
80107eb8:	6a 00                	push   $0x0
  pushl $76
80107eba:	6a 4c                	push   $0x4c
  jmp alltraps
80107ebc:	e9 0b f7 ff ff       	jmp    801075cc <alltraps>

80107ec1 <vector77>:
.globl vector77
vector77:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $77
80107ec3:	6a 4d                	push   $0x4d
  jmp alltraps
80107ec5:	e9 02 f7 ff ff       	jmp    801075cc <alltraps>

80107eca <vector78>:
.globl vector78
vector78:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $78
80107ecc:	6a 4e                	push   $0x4e
  jmp alltraps
80107ece:	e9 f9 f6 ff ff       	jmp    801075cc <alltraps>

80107ed3 <vector79>:
.globl vector79
vector79:
  pushl $0
80107ed3:	6a 00                	push   $0x0
  pushl $79
80107ed5:	6a 4f                	push   $0x4f
  jmp alltraps
80107ed7:	e9 f0 f6 ff ff       	jmp    801075cc <alltraps>

80107edc <vector80>:
.globl vector80
vector80:
  pushl $0
80107edc:	6a 00                	push   $0x0
  pushl $80
80107ede:	6a 50                	push   $0x50
  jmp alltraps
80107ee0:	e9 e7 f6 ff ff       	jmp    801075cc <alltraps>

80107ee5 <vector81>:
.globl vector81
vector81:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $81
80107ee7:	6a 51                	push   $0x51
  jmp alltraps
80107ee9:	e9 de f6 ff ff       	jmp    801075cc <alltraps>

80107eee <vector82>:
.globl vector82
vector82:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $82
80107ef0:	6a 52                	push   $0x52
  jmp alltraps
80107ef2:	e9 d5 f6 ff ff       	jmp    801075cc <alltraps>

80107ef7 <vector83>:
.globl vector83
vector83:
  pushl $0
80107ef7:	6a 00                	push   $0x0
  pushl $83
80107ef9:	6a 53                	push   $0x53
  jmp alltraps
80107efb:	e9 cc f6 ff ff       	jmp    801075cc <alltraps>

80107f00 <vector84>:
.globl vector84
vector84:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $84
80107f02:	6a 54                	push   $0x54
  jmp alltraps
80107f04:	e9 c3 f6 ff ff       	jmp    801075cc <alltraps>

80107f09 <vector85>:
.globl vector85
vector85:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $85
80107f0b:	6a 55                	push   $0x55
  jmp alltraps
80107f0d:	e9 ba f6 ff ff       	jmp    801075cc <alltraps>

80107f12 <vector86>:
.globl vector86
vector86:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $86
80107f14:	6a 56                	push   $0x56
  jmp alltraps
80107f16:	e9 b1 f6 ff ff       	jmp    801075cc <alltraps>

80107f1b <vector87>:
.globl vector87
vector87:
  pushl $0
80107f1b:	6a 00                	push   $0x0
  pushl $87
80107f1d:	6a 57                	push   $0x57
  jmp alltraps
80107f1f:	e9 a8 f6 ff ff       	jmp    801075cc <alltraps>

80107f24 <vector88>:
.globl vector88
vector88:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $88
80107f26:	6a 58                	push   $0x58
  jmp alltraps
80107f28:	e9 9f f6 ff ff       	jmp    801075cc <alltraps>

80107f2d <vector89>:
.globl vector89
vector89:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $89
80107f2f:	6a 59                	push   $0x59
  jmp alltraps
80107f31:	e9 96 f6 ff ff       	jmp    801075cc <alltraps>

80107f36 <vector90>:
.globl vector90
vector90:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $90
80107f38:	6a 5a                	push   $0x5a
  jmp alltraps
80107f3a:	e9 8d f6 ff ff       	jmp    801075cc <alltraps>

80107f3f <vector91>:
.globl vector91
vector91:
  pushl $0
80107f3f:	6a 00                	push   $0x0
  pushl $91
80107f41:	6a 5b                	push   $0x5b
  jmp alltraps
80107f43:	e9 84 f6 ff ff       	jmp    801075cc <alltraps>

80107f48 <vector92>:
.globl vector92
vector92:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $92
80107f4a:	6a 5c                	push   $0x5c
  jmp alltraps
80107f4c:	e9 7b f6 ff ff       	jmp    801075cc <alltraps>

80107f51 <vector93>:
.globl vector93
vector93:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $93
80107f53:	6a 5d                	push   $0x5d
  jmp alltraps
80107f55:	e9 72 f6 ff ff       	jmp    801075cc <alltraps>

80107f5a <vector94>:
.globl vector94
vector94:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $94
80107f5c:	6a 5e                	push   $0x5e
  jmp alltraps
80107f5e:	e9 69 f6 ff ff       	jmp    801075cc <alltraps>

80107f63 <vector95>:
.globl vector95
vector95:
  pushl $0
80107f63:	6a 00                	push   $0x0
  pushl $95
80107f65:	6a 5f                	push   $0x5f
  jmp alltraps
80107f67:	e9 60 f6 ff ff       	jmp    801075cc <alltraps>

80107f6c <vector96>:
.globl vector96
vector96:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $96
80107f6e:	6a 60                	push   $0x60
  jmp alltraps
80107f70:	e9 57 f6 ff ff       	jmp    801075cc <alltraps>

80107f75 <vector97>:
.globl vector97
vector97:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $97
80107f77:	6a 61                	push   $0x61
  jmp alltraps
80107f79:	e9 4e f6 ff ff       	jmp    801075cc <alltraps>

80107f7e <vector98>:
.globl vector98
vector98:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $98
80107f80:	6a 62                	push   $0x62
  jmp alltraps
80107f82:	e9 45 f6 ff ff       	jmp    801075cc <alltraps>

80107f87 <vector99>:
.globl vector99
vector99:
  pushl $0
80107f87:	6a 00                	push   $0x0
  pushl $99
80107f89:	6a 63                	push   $0x63
  jmp alltraps
80107f8b:	e9 3c f6 ff ff       	jmp    801075cc <alltraps>

80107f90 <vector100>:
.globl vector100
vector100:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $100
80107f92:	6a 64                	push   $0x64
  jmp alltraps
80107f94:	e9 33 f6 ff ff       	jmp    801075cc <alltraps>

80107f99 <vector101>:
.globl vector101
vector101:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $101
80107f9b:	6a 65                	push   $0x65
  jmp alltraps
80107f9d:	e9 2a f6 ff ff       	jmp    801075cc <alltraps>

80107fa2 <vector102>:
.globl vector102
vector102:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $102
80107fa4:	6a 66                	push   $0x66
  jmp alltraps
80107fa6:	e9 21 f6 ff ff       	jmp    801075cc <alltraps>

80107fab <vector103>:
.globl vector103
vector103:
  pushl $0
80107fab:	6a 00                	push   $0x0
  pushl $103
80107fad:	6a 67                	push   $0x67
  jmp alltraps
80107faf:	e9 18 f6 ff ff       	jmp    801075cc <alltraps>

80107fb4 <vector104>:
.globl vector104
vector104:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $104
80107fb6:	6a 68                	push   $0x68
  jmp alltraps
80107fb8:	e9 0f f6 ff ff       	jmp    801075cc <alltraps>

80107fbd <vector105>:
.globl vector105
vector105:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $105
80107fbf:	6a 69                	push   $0x69
  jmp alltraps
80107fc1:	e9 06 f6 ff ff       	jmp    801075cc <alltraps>

80107fc6 <vector106>:
.globl vector106
vector106:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $106
80107fc8:	6a 6a                	push   $0x6a
  jmp alltraps
80107fca:	e9 fd f5 ff ff       	jmp    801075cc <alltraps>

80107fcf <vector107>:
.globl vector107
vector107:
  pushl $0
80107fcf:	6a 00                	push   $0x0
  pushl $107
80107fd1:	6a 6b                	push   $0x6b
  jmp alltraps
80107fd3:	e9 f4 f5 ff ff       	jmp    801075cc <alltraps>

80107fd8 <vector108>:
.globl vector108
vector108:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $108
80107fda:	6a 6c                	push   $0x6c
  jmp alltraps
80107fdc:	e9 eb f5 ff ff       	jmp    801075cc <alltraps>

80107fe1 <vector109>:
.globl vector109
vector109:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $109
80107fe3:	6a 6d                	push   $0x6d
  jmp alltraps
80107fe5:	e9 e2 f5 ff ff       	jmp    801075cc <alltraps>

80107fea <vector110>:
.globl vector110
vector110:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $110
80107fec:	6a 6e                	push   $0x6e
  jmp alltraps
80107fee:	e9 d9 f5 ff ff       	jmp    801075cc <alltraps>

80107ff3 <vector111>:
.globl vector111
vector111:
  pushl $0
80107ff3:	6a 00                	push   $0x0
  pushl $111
80107ff5:	6a 6f                	push   $0x6f
  jmp alltraps
80107ff7:	e9 d0 f5 ff ff       	jmp    801075cc <alltraps>

80107ffc <vector112>:
.globl vector112
vector112:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $112
80107ffe:	6a 70                	push   $0x70
  jmp alltraps
80108000:	e9 c7 f5 ff ff       	jmp    801075cc <alltraps>

80108005 <vector113>:
.globl vector113
vector113:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $113
80108007:	6a 71                	push   $0x71
  jmp alltraps
80108009:	e9 be f5 ff ff       	jmp    801075cc <alltraps>

8010800e <vector114>:
.globl vector114
vector114:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $114
80108010:	6a 72                	push   $0x72
  jmp alltraps
80108012:	e9 b5 f5 ff ff       	jmp    801075cc <alltraps>

80108017 <vector115>:
.globl vector115
vector115:
  pushl $0
80108017:	6a 00                	push   $0x0
  pushl $115
80108019:	6a 73                	push   $0x73
  jmp alltraps
8010801b:	e9 ac f5 ff ff       	jmp    801075cc <alltraps>

80108020 <vector116>:
.globl vector116
vector116:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $116
80108022:	6a 74                	push   $0x74
  jmp alltraps
80108024:	e9 a3 f5 ff ff       	jmp    801075cc <alltraps>

80108029 <vector117>:
.globl vector117
vector117:
  pushl $0
80108029:	6a 00                	push   $0x0
  pushl $117
8010802b:	6a 75                	push   $0x75
  jmp alltraps
8010802d:	e9 9a f5 ff ff       	jmp    801075cc <alltraps>

80108032 <vector118>:
.globl vector118
vector118:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $118
80108034:	6a 76                	push   $0x76
  jmp alltraps
80108036:	e9 91 f5 ff ff       	jmp    801075cc <alltraps>

8010803b <vector119>:
.globl vector119
vector119:
  pushl $0
8010803b:	6a 00                	push   $0x0
  pushl $119
8010803d:	6a 77                	push   $0x77
  jmp alltraps
8010803f:	e9 88 f5 ff ff       	jmp    801075cc <alltraps>

80108044 <vector120>:
.globl vector120
vector120:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $120
80108046:	6a 78                	push   $0x78
  jmp alltraps
80108048:	e9 7f f5 ff ff       	jmp    801075cc <alltraps>

8010804d <vector121>:
.globl vector121
vector121:
  pushl $0
8010804d:	6a 00                	push   $0x0
  pushl $121
8010804f:	6a 79                	push   $0x79
  jmp alltraps
80108051:	e9 76 f5 ff ff       	jmp    801075cc <alltraps>

80108056 <vector122>:
.globl vector122
vector122:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $122
80108058:	6a 7a                	push   $0x7a
  jmp alltraps
8010805a:	e9 6d f5 ff ff       	jmp    801075cc <alltraps>

8010805f <vector123>:
.globl vector123
vector123:
  pushl $0
8010805f:	6a 00                	push   $0x0
  pushl $123
80108061:	6a 7b                	push   $0x7b
  jmp alltraps
80108063:	e9 64 f5 ff ff       	jmp    801075cc <alltraps>

80108068 <vector124>:
.globl vector124
vector124:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $124
8010806a:	6a 7c                	push   $0x7c
  jmp alltraps
8010806c:	e9 5b f5 ff ff       	jmp    801075cc <alltraps>

80108071 <vector125>:
.globl vector125
vector125:
  pushl $0
80108071:	6a 00                	push   $0x0
  pushl $125
80108073:	6a 7d                	push   $0x7d
  jmp alltraps
80108075:	e9 52 f5 ff ff       	jmp    801075cc <alltraps>

8010807a <vector126>:
.globl vector126
vector126:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $126
8010807c:	6a 7e                	push   $0x7e
  jmp alltraps
8010807e:	e9 49 f5 ff ff       	jmp    801075cc <alltraps>

80108083 <vector127>:
.globl vector127
vector127:
  pushl $0
80108083:	6a 00                	push   $0x0
  pushl $127
80108085:	6a 7f                	push   $0x7f
  jmp alltraps
80108087:	e9 40 f5 ff ff       	jmp    801075cc <alltraps>

8010808c <vector128>:
.globl vector128
vector128:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $128
8010808e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108093:	e9 34 f5 ff ff       	jmp    801075cc <alltraps>

80108098 <vector129>:
.globl vector129
vector129:
  pushl $0
80108098:	6a 00                	push   $0x0
  pushl $129
8010809a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010809f:	e9 28 f5 ff ff       	jmp    801075cc <alltraps>

801080a4 <vector130>:
.globl vector130
vector130:
  pushl $0
801080a4:	6a 00                	push   $0x0
  pushl $130
801080a6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801080ab:	e9 1c f5 ff ff       	jmp    801075cc <alltraps>

801080b0 <vector131>:
.globl vector131
vector131:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $131
801080b2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801080b7:	e9 10 f5 ff ff       	jmp    801075cc <alltraps>

801080bc <vector132>:
.globl vector132
vector132:
  pushl $0
801080bc:	6a 00                	push   $0x0
  pushl $132
801080be:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801080c3:	e9 04 f5 ff ff       	jmp    801075cc <alltraps>

801080c8 <vector133>:
.globl vector133
vector133:
  pushl $0
801080c8:	6a 00                	push   $0x0
  pushl $133
801080ca:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801080cf:	e9 f8 f4 ff ff       	jmp    801075cc <alltraps>

801080d4 <vector134>:
.globl vector134
vector134:
  pushl $0
801080d4:	6a 00                	push   $0x0
  pushl $134
801080d6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801080db:	e9 ec f4 ff ff       	jmp    801075cc <alltraps>

801080e0 <vector135>:
.globl vector135
vector135:
  pushl $0
801080e0:	6a 00                	push   $0x0
  pushl $135
801080e2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801080e7:	e9 e0 f4 ff ff       	jmp    801075cc <alltraps>

801080ec <vector136>:
.globl vector136
vector136:
  pushl $0
801080ec:	6a 00                	push   $0x0
  pushl $136
801080ee:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801080f3:	e9 d4 f4 ff ff       	jmp    801075cc <alltraps>

801080f8 <vector137>:
.globl vector137
vector137:
  pushl $0
801080f8:	6a 00                	push   $0x0
  pushl $137
801080fa:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801080ff:	e9 c8 f4 ff ff       	jmp    801075cc <alltraps>

80108104 <vector138>:
.globl vector138
vector138:
  pushl $0
80108104:	6a 00                	push   $0x0
  pushl $138
80108106:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010810b:	e9 bc f4 ff ff       	jmp    801075cc <alltraps>

80108110 <vector139>:
.globl vector139
vector139:
  pushl $0
80108110:	6a 00                	push   $0x0
  pushl $139
80108112:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108117:	e9 b0 f4 ff ff       	jmp    801075cc <alltraps>

8010811c <vector140>:
.globl vector140
vector140:
  pushl $0
8010811c:	6a 00                	push   $0x0
  pushl $140
8010811e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108123:	e9 a4 f4 ff ff       	jmp    801075cc <alltraps>

80108128 <vector141>:
.globl vector141
vector141:
  pushl $0
80108128:	6a 00                	push   $0x0
  pushl $141
8010812a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010812f:	e9 98 f4 ff ff       	jmp    801075cc <alltraps>

80108134 <vector142>:
.globl vector142
vector142:
  pushl $0
80108134:	6a 00                	push   $0x0
  pushl $142
80108136:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010813b:	e9 8c f4 ff ff       	jmp    801075cc <alltraps>

80108140 <vector143>:
.globl vector143
vector143:
  pushl $0
80108140:	6a 00                	push   $0x0
  pushl $143
80108142:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108147:	e9 80 f4 ff ff       	jmp    801075cc <alltraps>

8010814c <vector144>:
.globl vector144
vector144:
  pushl $0
8010814c:	6a 00                	push   $0x0
  pushl $144
8010814e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108153:	e9 74 f4 ff ff       	jmp    801075cc <alltraps>

80108158 <vector145>:
.globl vector145
vector145:
  pushl $0
80108158:	6a 00                	push   $0x0
  pushl $145
8010815a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010815f:	e9 68 f4 ff ff       	jmp    801075cc <alltraps>

80108164 <vector146>:
.globl vector146
vector146:
  pushl $0
80108164:	6a 00                	push   $0x0
  pushl $146
80108166:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010816b:	e9 5c f4 ff ff       	jmp    801075cc <alltraps>

80108170 <vector147>:
.globl vector147
vector147:
  pushl $0
80108170:	6a 00                	push   $0x0
  pushl $147
80108172:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108177:	e9 50 f4 ff ff       	jmp    801075cc <alltraps>

8010817c <vector148>:
.globl vector148
vector148:
  pushl $0
8010817c:	6a 00                	push   $0x0
  pushl $148
8010817e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108183:	e9 44 f4 ff ff       	jmp    801075cc <alltraps>

80108188 <vector149>:
.globl vector149
vector149:
  pushl $0
80108188:	6a 00                	push   $0x0
  pushl $149
8010818a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010818f:	e9 38 f4 ff ff       	jmp    801075cc <alltraps>

80108194 <vector150>:
.globl vector150
vector150:
  pushl $0
80108194:	6a 00                	push   $0x0
  pushl $150
80108196:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010819b:	e9 2c f4 ff ff       	jmp    801075cc <alltraps>

801081a0 <vector151>:
.globl vector151
vector151:
  pushl $0
801081a0:	6a 00                	push   $0x0
  pushl $151
801081a2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801081a7:	e9 20 f4 ff ff       	jmp    801075cc <alltraps>

801081ac <vector152>:
.globl vector152
vector152:
  pushl $0
801081ac:	6a 00                	push   $0x0
  pushl $152
801081ae:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801081b3:	e9 14 f4 ff ff       	jmp    801075cc <alltraps>

801081b8 <vector153>:
.globl vector153
vector153:
  pushl $0
801081b8:	6a 00                	push   $0x0
  pushl $153
801081ba:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801081bf:	e9 08 f4 ff ff       	jmp    801075cc <alltraps>

801081c4 <vector154>:
.globl vector154
vector154:
  pushl $0
801081c4:	6a 00                	push   $0x0
  pushl $154
801081c6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801081cb:	e9 fc f3 ff ff       	jmp    801075cc <alltraps>

801081d0 <vector155>:
.globl vector155
vector155:
  pushl $0
801081d0:	6a 00                	push   $0x0
  pushl $155
801081d2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801081d7:	e9 f0 f3 ff ff       	jmp    801075cc <alltraps>

801081dc <vector156>:
.globl vector156
vector156:
  pushl $0
801081dc:	6a 00                	push   $0x0
  pushl $156
801081de:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801081e3:	e9 e4 f3 ff ff       	jmp    801075cc <alltraps>

801081e8 <vector157>:
.globl vector157
vector157:
  pushl $0
801081e8:	6a 00                	push   $0x0
  pushl $157
801081ea:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801081ef:	e9 d8 f3 ff ff       	jmp    801075cc <alltraps>

801081f4 <vector158>:
.globl vector158
vector158:
  pushl $0
801081f4:	6a 00                	push   $0x0
  pushl $158
801081f6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801081fb:	e9 cc f3 ff ff       	jmp    801075cc <alltraps>

80108200 <vector159>:
.globl vector159
vector159:
  pushl $0
80108200:	6a 00                	push   $0x0
  pushl $159
80108202:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108207:	e9 c0 f3 ff ff       	jmp    801075cc <alltraps>

8010820c <vector160>:
.globl vector160
vector160:
  pushl $0
8010820c:	6a 00                	push   $0x0
  pushl $160
8010820e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108213:	e9 b4 f3 ff ff       	jmp    801075cc <alltraps>

80108218 <vector161>:
.globl vector161
vector161:
  pushl $0
80108218:	6a 00                	push   $0x0
  pushl $161
8010821a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010821f:	e9 a8 f3 ff ff       	jmp    801075cc <alltraps>

80108224 <vector162>:
.globl vector162
vector162:
  pushl $0
80108224:	6a 00                	push   $0x0
  pushl $162
80108226:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010822b:	e9 9c f3 ff ff       	jmp    801075cc <alltraps>

80108230 <vector163>:
.globl vector163
vector163:
  pushl $0
80108230:	6a 00                	push   $0x0
  pushl $163
80108232:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108237:	e9 90 f3 ff ff       	jmp    801075cc <alltraps>

8010823c <vector164>:
.globl vector164
vector164:
  pushl $0
8010823c:	6a 00                	push   $0x0
  pushl $164
8010823e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108243:	e9 84 f3 ff ff       	jmp    801075cc <alltraps>

80108248 <vector165>:
.globl vector165
vector165:
  pushl $0
80108248:	6a 00                	push   $0x0
  pushl $165
8010824a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010824f:	e9 78 f3 ff ff       	jmp    801075cc <alltraps>

80108254 <vector166>:
.globl vector166
vector166:
  pushl $0
80108254:	6a 00                	push   $0x0
  pushl $166
80108256:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010825b:	e9 6c f3 ff ff       	jmp    801075cc <alltraps>

80108260 <vector167>:
.globl vector167
vector167:
  pushl $0
80108260:	6a 00                	push   $0x0
  pushl $167
80108262:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108267:	e9 60 f3 ff ff       	jmp    801075cc <alltraps>

8010826c <vector168>:
.globl vector168
vector168:
  pushl $0
8010826c:	6a 00                	push   $0x0
  pushl $168
8010826e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108273:	e9 54 f3 ff ff       	jmp    801075cc <alltraps>

80108278 <vector169>:
.globl vector169
vector169:
  pushl $0
80108278:	6a 00                	push   $0x0
  pushl $169
8010827a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010827f:	e9 48 f3 ff ff       	jmp    801075cc <alltraps>

80108284 <vector170>:
.globl vector170
vector170:
  pushl $0
80108284:	6a 00                	push   $0x0
  pushl $170
80108286:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010828b:	e9 3c f3 ff ff       	jmp    801075cc <alltraps>

80108290 <vector171>:
.globl vector171
vector171:
  pushl $0
80108290:	6a 00                	push   $0x0
  pushl $171
80108292:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108297:	e9 30 f3 ff ff       	jmp    801075cc <alltraps>

8010829c <vector172>:
.globl vector172
vector172:
  pushl $0
8010829c:	6a 00                	push   $0x0
  pushl $172
8010829e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801082a3:	e9 24 f3 ff ff       	jmp    801075cc <alltraps>

801082a8 <vector173>:
.globl vector173
vector173:
  pushl $0
801082a8:	6a 00                	push   $0x0
  pushl $173
801082aa:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801082af:	e9 18 f3 ff ff       	jmp    801075cc <alltraps>

801082b4 <vector174>:
.globl vector174
vector174:
  pushl $0
801082b4:	6a 00                	push   $0x0
  pushl $174
801082b6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801082bb:	e9 0c f3 ff ff       	jmp    801075cc <alltraps>

801082c0 <vector175>:
.globl vector175
vector175:
  pushl $0
801082c0:	6a 00                	push   $0x0
  pushl $175
801082c2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801082c7:	e9 00 f3 ff ff       	jmp    801075cc <alltraps>

801082cc <vector176>:
.globl vector176
vector176:
  pushl $0
801082cc:	6a 00                	push   $0x0
  pushl $176
801082ce:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801082d3:	e9 f4 f2 ff ff       	jmp    801075cc <alltraps>

801082d8 <vector177>:
.globl vector177
vector177:
  pushl $0
801082d8:	6a 00                	push   $0x0
  pushl $177
801082da:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801082df:	e9 e8 f2 ff ff       	jmp    801075cc <alltraps>

801082e4 <vector178>:
.globl vector178
vector178:
  pushl $0
801082e4:	6a 00                	push   $0x0
  pushl $178
801082e6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801082eb:	e9 dc f2 ff ff       	jmp    801075cc <alltraps>

801082f0 <vector179>:
.globl vector179
vector179:
  pushl $0
801082f0:	6a 00                	push   $0x0
  pushl $179
801082f2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801082f7:	e9 d0 f2 ff ff       	jmp    801075cc <alltraps>

801082fc <vector180>:
.globl vector180
vector180:
  pushl $0
801082fc:	6a 00                	push   $0x0
  pushl $180
801082fe:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108303:	e9 c4 f2 ff ff       	jmp    801075cc <alltraps>

80108308 <vector181>:
.globl vector181
vector181:
  pushl $0
80108308:	6a 00                	push   $0x0
  pushl $181
8010830a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010830f:	e9 b8 f2 ff ff       	jmp    801075cc <alltraps>

80108314 <vector182>:
.globl vector182
vector182:
  pushl $0
80108314:	6a 00                	push   $0x0
  pushl $182
80108316:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010831b:	e9 ac f2 ff ff       	jmp    801075cc <alltraps>

80108320 <vector183>:
.globl vector183
vector183:
  pushl $0
80108320:	6a 00                	push   $0x0
  pushl $183
80108322:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108327:	e9 a0 f2 ff ff       	jmp    801075cc <alltraps>

8010832c <vector184>:
.globl vector184
vector184:
  pushl $0
8010832c:	6a 00                	push   $0x0
  pushl $184
8010832e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108333:	e9 94 f2 ff ff       	jmp    801075cc <alltraps>

80108338 <vector185>:
.globl vector185
vector185:
  pushl $0
80108338:	6a 00                	push   $0x0
  pushl $185
8010833a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010833f:	e9 88 f2 ff ff       	jmp    801075cc <alltraps>

80108344 <vector186>:
.globl vector186
vector186:
  pushl $0
80108344:	6a 00                	push   $0x0
  pushl $186
80108346:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010834b:	e9 7c f2 ff ff       	jmp    801075cc <alltraps>

80108350 <vector187>:
.globl vector187
vector187:
  pushl $0
80108350:	6a 00                	push   $0x0
  pushl $187
80108352:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108357:	e9 70 f2 ff ff       	jmp    801075cc <alltraps>

8010835c <vector188>:
.globl vector188
vector188:
  pushl $0
8010835c:	6a 00                	push   $0x0
  pushl $188
8010835e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108363:	e9 64 f2 ff ff       	jmp    801075cc <alltraps>

80108368 <vector189>:
.globl vector189
vector189:
  pushl $0
80108368:	6a 00                	push   $0x0
  pushl $189
8010836a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010836f:	e9 58 f2 ff ff       	jmp    801075cc <alltraps>

80108374 <vector190>:
.globl vector190
vector190:
  pushl $0
80108374:	6a 00                	push   $0x0
  pushl $190
80108376:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010837b:	e9 4c f2 ff ff       	jmp    801075cc <alltraps>

80108380 <vector191>:
.globl vector191
vector191:
  pushl $0
80108380:	6a 00                	push   $0x0
  pushl $191
80108382:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108387:	e9 40 f2 ff ff       	jmp    801075cc <alltraps>

8010838c <vector192>:
.globl vector192
vector192:
  pushl $0
8010838c:	6a 00                	push   $0x0
  pushl $192
8010838e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108393:	e9 34 f2 ff ff       	jmp    801075cc <alltraps>

80108398 <vector193>:
.globl vector193
vector193:
  pushl $0
80108398:	6a 00                	push   $0x0
  pushl $193
8010839a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010839f:	e9 28 f2 ff ff       	jmp    801075cc <alltraps>

801083a4 <vector194>:
.globl vector194
vector194:
  pushl $0
801083a4:	6a 00                	push   $0x0
  pushl $194
801083a6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801083ab:	e9 1c f2 ff ff       	jmp    801075cc <alltraps>

801083b0 <vector195>:
.globl vector195
vector195:
  pushl $0
801083b0:	6a 00                	push   $0x0
  pushl $195
801083b2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801083b7:	e9 10 f2 ff ff       	jmp    801075cc <alltraps>

801083bc <vector196>:
.globl vector196
vector196:
  pushl $0
801083bc:	6a 00                	push   $0x0
  pushl $196
801083be:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801083c3:	e9 04 f2 ff ff       	jmp    801075cc <alltraps>

801083c8 <vector197>:
.globl vector197
vector197:
  pushl $0
801083c8:	6a 00                	push   $0x0
  pushl $197
801083ca:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801083cf:	e9 f8 f1 ff ff       	jmp    801075cc <alltraps>

801083d4 <vector198>:
.globl vector198
vector198:
  pushl $0
801083d4:	6a 00                	push   $0x0
  pushl $198
801083d6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801083db:	e9 ec f1 ff ff       	jmp    801075cc <alltraps>

801083e0 <vector199>:
.globl vector199
vector199:
  pushl $0
801083e0:	6a 00                	push   $0x0
  pushl $199
801083e2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801083e7:	e9 e0 f1 ff ff       	jmp    801075cc <alltraps>

801083ec <vector200>:
.globl vector200
vector200:
  pushl $0
801083ec:	6a 00                	push   $0x0
  pushl $200
801083ee:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801083f3:	e9 d4 f1 ff ff       	jmp    801075cc <alltraps>

801083f8 <vector201>:
.globl vector201
vector201:
  pushl $0
801083f8:	6a 00                	push   $0x0
  pushl $201
801083fa:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801083ff:	e9 c8 f1 ff ff       	jmp    801075cc <alltraps>

80108404 <vector202>:
.globl vector202
vector202:
  pushl $0
80108404:	6a 00                	push   $0x0
  pushl $202
80108406:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010840b:	e9 bc f1 ff ff       	jmp    801075cc <alltraps>

80108410 <vector203>:
.globl vector203
vector203:
  pushl $0
80108410:	6a 00                	push   $0x0
  pushl $203
80108412:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108417:	e9 b0 f1 ff ff       	jmp    801075cc <alltraps>

8010841c <vector204>:
.globl vector204
vector204:
  pushl $0
8010841c:	6a 00                	push   $0x0
  pushl $204
8010841e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108423:	e9 a4 f1 ff ff       	jmp    801075cc <alltraps>

80108428 <vector205>:
.globl vector205
vector205:
  pushl $0
80108428:	6a 00                	push   $0x0
  pushl $205
8010842a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010842f:	e9 98 f1 ff ff       	jmp    801075cc <alltraps>

80108434 <vector206>:
.globl vector206
vector206:
  pushl $0
80108434:	6a 00                	push   $0x0
  pushl $206
80108436:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010843b:	e9 8c f1 ff ff       	jmp    801075cc <alltraps>

80108440 <vector207>:
.globl vector207
vector207:
  pushl $0
80108440:	6a 00                	push   $0x0
  pushl $207
80108442:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108447:	e9 80 f1 ff ff       	jmp    801075cc <alltraps>

8010844c <vector208>:
.globl vector208
vector208:
  pushl $0
8010844c:	6a 00                	push   $0x0
  pushl $208
8010844e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108453:	e9 74 f1 ff ff       	jmp    801075cc <alltraps>

80108458 <vector209>:
.globl vector209
vector209:
  pushl $0
80108458:	6a 00                	push   $0x0
  pushl $209
8010845a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010845f:	e9 68 f1 ff ff       	jmp    801075cc <alltraps>

80108464 <vector210>:
.globl vector210
vector210:
  pushl $0
80108464:	6a 00                	push   $0x0
  pushl $210
80108466:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010846b:	e9 5c f1 ff ff       	jmp    801075cc <alltraps>

80108470 <vector211>:
.globl vector211
vector211:
  pushl $0
80108470:	6a 00                	push   $0x0
  pushl $211
80108472:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108477:	e9 50 f1 ff ff       	jmp    801075cc <alltraps>

8010847c <vector212>:
.globl vector212
vector212:
  pushl $0
8010847c:	6a 00                	push   $0x0
  pushl $212
8010847e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108483:	e9 44 f1 ff ff       	jmp    801075cc <alltraps>

80108488 <vector213>:
.globl vector213
vector213:
  pushl $0
80108488:	6a 00                	push   $0x0
  pushl $213
8010848a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010848f:	e9 38 f1 ff ff       	jmp    801075cc <alltraps>

80108494 <vector214>:
.globl vector214
vector214:
  pushl $0
80108494:	6a 00                	push   $0x0
  pushl $214
80108496:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010849b:	e9 2c f1 ff ff       	jmp    801075cc <alltraps>

801084a0 <vector215>:
.globl vector215
vector215:
  pushl $0
801084a0:	6a 00                	push   $0x0
  pushl $215
801084a2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801084a7:	e9 20 f1 ff ff       	jmp    801075cc <alltraps>

801084ac <vector216>:
.globl vector216
vector216:
  pushl $0
801084ac:	6a 00                	push   $0x0
  pushl $216
801084ae:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801084b3:	e9 14 f1 ff ff       	jmp    801075cc <alltraps>

801084b8 <vector217>:
.globl vector217
vector217:
  pushl $0
801084b8:	6a 00                	push   $0x0
  pushl $217
801084ba:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801084bf:	e9 08 f1 ff ff       	jmp    801075cc <alltraps>

801084c4 <vector218>:
.globl vector218
vector218:
  pushl $0
801084c4:	6a 00                	push   $0x0
  pushl $218
801084c6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801084cb:	e9 fc f0 ff ff       	jmp    801075cc <alltraps>

801084d0 <vector219>:
.globl vector219
vector219:
  pushl $0
801084d0:	6a 00                	push   $0x0
  pushl $219
801084d2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801084d7:	e9 f0 f0 ff ff       	jmp    801075cc <alltraps>

801084dc <vector220>:
.globl vector220
vector220:
  pushl $0
801084dc:	6a 00                	push   $0x0
  pushl $220
801084de:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801084e3:	e9 e4 f0 ff ff       	jmp    801075cc <alltraps>

801084e8 <vector221>:
.globl vector221
vector221:
  pushl $0
801084e8:	6a 00                	push   $0x0
  pushl $221
801084ea:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801084ef:	e9 d8 f0 ff ff       	jmp    801075cc <alltraps>

801084f4 <vector222>:
.globl vector222
vector222:
  pushl $0
801084f4:	6a 00                	push   $0x0
  pushl $222
801084f6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801084fb:	e9 cc f0 ff ff       	jmp    801075cc <alltraps>

80108500 <vector223>:
.globl vector223
vector223:
  pushl $0
80108500:	6a 00                	push   $0x0
  pushl $223
80108502:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108507:	e9 c0 f0 ff ff       	jmp    801075cc <alltraps>

8010850c <vector224>:
.globl vector224
vector224:
  pushl $0
8010850c:	6a 00                	push   $0x0
  pushl $224
8010850e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108513:	e9 b4 f0 ff ff       	jmp    801075cc <alltraps>

80108518 <vector225>:
.globl vector225
vector225:
  pushl $0
80108518:	6a 00                	push   $0x0
  pushl $225
8010851a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010851f:	e9 a8 f0 ff ff       	jmp    801075cc <alltraps>

80108524 <vector226>:
.globl vector226
vector226:
  pushl $0
80108524:	6a 00                	push   $0x0
  pushl $226
80108526:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010852b:	e9 9c f0 ff ff       	jmp    801075cc <alltraps>

80108530 <vector227>:
.globl vector227
vector227:
  pushl $0
80108530:	6a 00                	push   $0x0
  pushl $227
80108532:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108537:	e9 90 f0 ff ff       	jmp    801075cc <alltraps>

8010853c <vector228>:
.globl vector228
vector228:
  pushl $0
8010853c:	6a 00                	push   $0x0
  pushl $228
8010853e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108543:	e9 84 f0 ff ff       	jmp    801075cc <alltraps>

80108548 <vector229>:
.globl vector229
vector229:
  pushl $0
80108548:	6a 00                	push   $0x0
  pushl $229
8010854a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010854f:	e9 78 f0 ff ff       	jmp    801075cc <alltraps>

80108554 <vector230>:
.globl vector230
vector230:
  pushl $0
80108554:	6a 00                	push   $0x0
  pushl $230
80108556:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010855b:	e9 6c f0 ff ff       	jmp    801075cc <alltraps>

80108560 <vector231>:
.globl vector231
vector231:
  pushl $0
80108560:	6a 00                	push   $0x0
  pushl $231
80108562:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108567:	e9 60 f0 ff ff       	jmp    801075cc <alltraps>

8010856c <vector232>:
.globl vector232
vector232:
  pushl $0
8010856c:	6a 00                	push   $0x0
  pushl $232
8010856e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108573:	e9 54 f0 ff ff       	jmp    801075cc <alltraps>

80108578 <vector233>:
.globl vector233
vector233:
  pushl $0
80108578:	6a 00                	push   $0x0
  pushl $233
8010857a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010857f:	e9 48 f0 ff ff       	jmp    801075cc <alltraps>

80108584 <vector234>:
.globl vector234
vector234:
  pushl $0
80108584:	6a 00                	push   $0x0
  pushl $234
80108586:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010858b:	e9 3c f0 ff ff       	jmp    801075cc <alltraps>

80108590 <vector235>:
.globl vector235
vector235:
  pushl $0
80108590:	6a 00                	push   $0x0
  pushl $235
80108592:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108597:	e9 30 f0 ff ff       	jmp    801075cc <alltraps>

8010859c <vector236>:
.globl vector236
vector236:
  pushl $0
8010859c:	6a 00                	push   $0x0
  pushl $236
8010859e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801085a3:	e9 24 f0 ff ff       	jmp    801075cc <alltraps>

801085a8 <vector237>:
.globl vector237
vector237:
  pushl $0
801085a8:	6a 00                	push   $0x0
  pushl $237
801085aa:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801085af:	e9 18 f0 ff ff       	jmp    801075cc <alltraps>

801085b4 <vector238>:
.globl vector238
vector238:
  pushl $0
801085b4:	6a 00                	push   $0x0
  pushl $238
801085b6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801085bb:	e9 0c f0 ff ff       	jmp    801075cc <alltraps>

801085c0 <vector239>:
.globl vector239
vector239:
  pushl $0
801085c0:	6a 00                	push   $0x0
  pushl $239
801085c2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801085c7:	e9 00 f0 ff ff       	jmp    801075cc <alltraps>

801085cc <vector240>:
.globl vector240
vector240:
  pushl $0
801085cc:	6a 00                	push   $0x0
  pushl $240
801085ce:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801085d3:	e9 f4 ef ff ff       	jmp    801075cc <alltraps>

801085d8 <vector241>:
.globl vector241
vector241:
  pushl $0
801085d8:	6a 00                	push   $0x0
  pushl $241
801085da:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801085df:	e9 e8 ef ff ff       	jmp    801075cc <alltraps>

801085e4 <vector242>:
.globl vector242
vector242:
  pushl $0
801085e4:	6a 00                	push   $0x0
  pushl $242
801085e6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801085eb:	e9 dc ef ff ff       	jmp    801075cc <alltraps>

801085f0 <vector243>:
.globl vector243
vector243:
  pushl $0
801085f0:	6a 00                	push   $0x0
  pushl $243
801085f2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801085f7:	e9 d0 ef ff ff       	jmp    801075cc <alltraps>

801085fc <vector244>:
.globl vector244
vector244:
  pushl $0
801085fc:	6a 00                	push   $0x0
  pushl $244
801085fe:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108603:	e9 c4 ef ff ff       	jmp    801075cc <alltraps>

80108608 <vector245>:
.globl vector245
vector245:
  pushl $0
80108608:	6a 00                	push   $0x0
  pushl $245
8010860a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010860f:	e9 b8 ef ff ff       	jmp    801075cc <alltraps>

80108614 <vector246>:
.globl vector246
vector246:
  pushl $0
80108614:	6a 00                	push   $0x0
  pushl $246
80108616:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010861b:	e9 ac ef ff ff       	jmp    801075cc <alltraps>

80108620 <vector247>:
.globl vector247
vector247:
  pushl $0
80108620:	6a 00                	push   $0x0
  pushl $247
80108622:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108627:	e9 a0 ef ff ff       	jmp    801075cc <alltraps>

8010862c <vector248>:
.globl vector248
vector248:
  pushl $0
8010862c:	6a 00                	push   $0x0
  pushl $248
8010862e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108633:	e9 94 ef ff ff       	jmp    801075cc <alltraps>

80108638 <vector249>:
.globl vector249
vector249:
  pushl $0
80108638:	6a 00                	push   $0x0
  pushl $249
8010863a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010863f:	e9 88 ef ff ff       	jmp    801075cc <alltraps>

80108644 <vector250>:
.globl vector250
vector250:
  pushl $0
80108644:	6a 00                	push   $0x0
  pushl $250
80108646:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010864b:	e9 7c ef ff ff       	jmp    801075cc <alltraps>

80108650 <vector251>:
.globl vector251
vector251:
  pushl $0
80108650:	6a 00                	push   $0x0
  pushl $251
80108652:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108657:	e9 70 ef ff ff       	jmp    801075cc <alltraps>

8010865c <vector252>:
.globl vector252
vector252:
  pushl $0
8010865c:	6a 00                	push   $0x0
  pushl $252
8010865e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108663:	e9 64 ef ff ff       	jmp    801075cc <alltraps>

80108668 <vector253>:
.globl vector253
vector253:
  pushl $0
80108668:	6a 00                	push   $0x0
  pushl $253
8010866a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010866f:	e9 58 ef ff ff       	jmp    801075cc <alltraps>

80108674 <vector254>:
.globl vector254
vector254:
  pushl $0
80108674:	6a 00                	push   $0x0
  pushl $254
80108676:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010867b:	e9 4c ef ff ff       	jmp    801075cc <alltraps>

80108680 <vector255>:
.globl vector255
vector255:
  pushl $0
80108680:	6a 00                	push   $0x0
  pushl $255
80108682:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108687:	e9 40 ef ff ff       	jmp    801075cc <alltraps>

8010868c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010868c:	55                   	push   %ebp
8010868d:	89 e5                	mov    %esp,%ebp
8010868f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108692:	8b 45 0c             	mov    0xc(%ebp),%eax
80108695:	83 e8 01             	sub    $0x1,%eax
80108698:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010869c:	8b 45 08             	mov    0x8(%ebp),%eax
8010869f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801086a3:	8b 45 08             	mov    0x8(%ebp),%eax
801086a6:	c1 e8 10             	shr    $0x10,%eax
801086a9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801086ad:	8d 45 fa             	lea    -0x6(%ebp),%eax
801086b0:	0f 01 10             	lgdtl  (%eax)
}
801086b3:	90                   	nop
801086b4:	c9                   	leave  
801086b5:	c3                   	ret    

801086b6 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801086b6:	55                   	push   %ebp
801086b7:	89 e5                	mov    %esp,%ebp
801086b9:	83 ec 04             	sub    $0x4,%esp
801086bc:	8b 45 08             	mov    0x8(%ebp),%eax
801086bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801086c3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801086c7:	0f 00 d8             	ltr    %ax
}
801086ca:	90                   	nop
801086cb:	c9                   	leave  
801086cc:	c3                   	ret    

801086cd <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801086cd:	55                   	push   %ebp
801086ce:	89 e5                	mov    %esp,%ebp
801086d0:	83 ec 04             	sub    $0x4,%esp
801086d3:	8b 45 08             	mov    0x8(%ebp),%eax
801086d6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801086da:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801086de:	8e e8                	mov    %eax,%gs
}
801086e0:	90                   	nop
801086e1:	c9                   	leave  
801086e2:	c3                   	ret    

801086e3 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801086e3:	55                   	push   %ebp
801086e4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801086e6:	8b 45 08             	mov    0x8(%ebp),%eax
801086e9:	0f 22 d8             	mov    %eax,%cr3
}
801086ec:	90                   	nop
801086ed:	5d                   	pop    %ebp
801086ee:	c3                   	ret    

801086ef <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801086ef:	55                   	push   %ebp
801086f0:	89 e5                	mov    %esp,%ebp
801086f2:	8b 45 08             	mov    0x8(%ebp),%eax
801086f5:	05 00 00 00 80       	add    $0x80000000,%eax
801086fa:	5d                   	pop    %ebp
801086fb:	c3                   	ret    

801086fc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801086fc:	55                   	push   %ebp
801086fd:	89 e5                	mov    %esp,%ebp
801086ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108702:	05 00 00 00 80       	add    $0x80000000,%eax
80108707:	5d                   	pop    %ebp
80108708:	c3                   	ret    

80108709 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108709:	55                   	push   %ebp
8010870a:	89 e5                	mov    %esp,%ebp
8010870c:	53                   	push   %ebx
8010870d:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108710:	e8 61 a9 ff ff       	call   80103076 <cpunum>
80108715:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010871b:	05 80 33 11 80       	add    $0x80113380,%eax
80108720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108726:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010872c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108738:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010873c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108743:	83 e2 f0             	and    $0xfffffff0,%edx
80108746:	83 ca 0a             	or     $0xa,%edx
80108749:	88 50 7d             	mov    %dl,0x7d(%eax)
8010874c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108753:	83 ca 10             	or     $0x10,%edx
80108756:	88 50 7d             	mov    %dl,0x7d(%eax)
80108759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108760:	83 e2 9f             	and    $0xffffff9f,%edx
80108763:	88 50 7d             	mov    %dl,0x7d(%eax)
80108766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108769:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010876d:	83 ca 80             	or     $0xffffff80,%edx
80108770:	88 50 7d             	mov    %dl,0x7d(%eax)
80108773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108776:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010877a:	83 ca 0f             	or     $0xf,%edx
8010877d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108787:	83 e2 ef             	and    $0xffffffef,%edx
8010878a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010878d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108790:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108794:	83 e2 df             	and    $0xffffffdf,%edx
80108797:	88 50 7e             	mov    %dl,0x7e(%eax)
8010879a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801087a1:	83 ca 40             	or     $0x40,%edx
801087a4:	88 50 7e             	mov    %dl,0x7e(%eax)
801087a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087aa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801087ae:	83 ca 80             	or     $0xffffff80,%edx
801087b1:	88 50 7e             	mov    %dl,0x7e(%eax)
801087b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801087bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087be:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801087c5:	ff ff 
801087c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ca:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801087d1:	00 00 
801087d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801087dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087e7:	83 e2 f0             	and    $0xfffffff0,%edx
801087ea:	83 ca 02             	or     $0x2,%edx
801087ed:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087fd:	83 ca 10             	or     $0x10,%edx
80108800:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108809:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108810:	83 e2 9f             	and    $0xffffff9f,%edx
80108813:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108823:	83 ca 80             	or     $0xffffff80,%edx
80108826:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108836:	83 ca 0f             	or     $0xf,%edx
80108839:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010883f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108842:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108849:	83 e2 ef             	and    $0xffffffef,%edx
8010884c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108855:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010885c:	83 e2 df             	and    $0xffffffdf,%edx
8010885f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108868:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010886f:	83 ca 40             	or     $0x40,%edx
80108872:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108882:	83 ca 80             	or     $0xffffff80,%edx
80108885:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010888b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108898:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010889f:	ff ff 
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801088ab:	00 00 
801088ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801088b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ba:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088c1:	83 e2 f0             	and    $0xfffffff0,%edx
801088c4:	83 ca 0a             	or     $0xa,%edx
801088c7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088d7:	83 ca 10             	or     $0x10,%edx
801088da:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088ea:	83 ca 60             	or     $0x60,%edx
801088ed:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088fd:	83 ca 80             	or     $0xffffff80,%edx
80108900:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108909:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108910:	83 ca 0f             	or     $0xf,%edx
80108913:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108923:	83 e2 ef             	and    $0xffffffef,%edx
80108926:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010892c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108936:	83 e2 df             	and    $0xffffffdf,%edx
80108939:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010893f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108942:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108949:	83 ca 40             	or     $0x40,%edx
8010894c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108955:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010895c:	83 ca 80             	or     $0xffffff80,%edx
8010895f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108968:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010896f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108972:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108979:	ff ff 
8010897b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108985:	00 00 
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108994:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010899b:	83 e2 f0             	and    $0xfffffff0,%edx
8010899e:	83 ca 02             	or     $0x2,%edx
801089a1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801089a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089aa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801089b1:	83 ca 10             	or     $0x10,%edx
801089b4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801089ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801089c4:	83 ca 60             	or     $0x60,%edx
801089c7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801089cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801089d7:	83 ca 80             	or     $0xffffff80,%edx
801089da:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801089e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089ea:	83 ca 0f             	or     $0xf,%edx
801089ed:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089fd:	83 e2 ef             	and    $0xffffffef,%edx
80108a00:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a09:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108a10:	83 e2 df             	and    $0xffffffdf,%edx
80108a13:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108a23:	83 ca 40             	or     $0x40,%edx
80108a26:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108a36:	83 ca 80             	or     $0xffffff80,%edx
80108a39:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a42:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4c:	05 b4 00 00 00       	add    $0xb4,%eax
80108a51:	89 c3                	mov    %eax,%ebx
80108a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a56:	05 b4 00 00 00       	add    $0xb4,%eax
80108a5b:	c1 e8 10             	shr    $0x10,%eax
80108a5e:	89 c2                	mov    %eax,%edx
80108a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a63:	05 b4 00 00 00       	add    $0xb4,%eax
80108a68:	c1 e8 18             	shr    $0x18,%eax
80108a6b:	89 c1                	mov    %eax,%ecx
80108a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a70:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108a77:	00 00 
80108a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a86:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a96:	83 e2 f0             	and    $0xfffffff0,%edx
80108a99:	83 ca 02             	or     $0x2,%edx
80108a9c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108aac:	83 ca 10             	or     $0x10,%edx
80108aaf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108abf:	83 e2 9f             	and    $0xffffff9f,%edx
80108ac2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108ad2:	83 ca 80             	or     $0xffffff80,%edx
80108ad5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ade:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ae5:	83 e2 f0             	and    $0xfffffff0,%edx
80108ae8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108af8:	83 e2 ef             	and    $0xffffffef,%edx
80108afb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b04:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108b0b:	83 e2 df             	and    $0xffffffdf,%edx
80108b0e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b17:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108b1e:	83 ca 40             	or     $0x40,%edx
80108b21:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108b31:	83 ca 80             	or     $0xffffff80,%edx
80108b34:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b3d:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b46:	83 c0 70             	add    $0x70,%eax
80108b49:	83 ec 08             	sub    $0x8,%esp
80108b4c:	6a 38                	push   $0x38
80108b4e:	50                   	push   %eax
80108b4f:	e8 38 fb ff ff       	call   8010868c <lgdt>
80108b54:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108b57:	83 ec 0c             	sub    $0xc,%esp
80108b5a:	6a 18                	push   $0x18
80108b5c:	e8 6c fb ff ff       	call   801086cd <loadgs>
80108b61:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b67:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108b6d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108b74:	00 00 00 00 
}
80108b78:	90                   	nop
80108b79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b7c:	c9                   	leave  
80108b7d:	c3                   	ret    

80108b7e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108b7e:	55                   	push   %ebp
80108b7f:	89 e5                	mov    %esp,%ebp
80108b81:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108b84:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b87:	c1 e8 16             	shr    $0x16,%eax
80108b8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b91:	8b 45 08             	mov    0x8(%ebp),%eax
80108b94:	01 d0                	add    %edx,%eax
80108b96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b9c:	8b 00                	mov    (%eax),%eax
80108b9e:	83 e0 01             	and    $0x1,%eax
80108ba1:	85 c0                	test   %eax,%eax
80108ba3:	74 18                	je     80108bbd <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba8:	8b 00                	mov    (%eax),%eax
80108baa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108baf:	50                   	push   %eax
80108bb0:	e8 47 fb ff ff       	call   801086fc <p2v>
80108bb5:	83 c4 04             	add    $0x4,%esp
80108bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108bbb:	eb 48                	jmp    80108c05 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108bbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108bc1:	74 0e                	je     80108bd1 <walkpgdir+0x53>
80108bc3:	e8 48 a1 ff ff       	call   80102d10 <kalloc>
80108bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108bcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108bcf:	75 07                	jne    80108bd8 <walkpgdir+0x5a>
      return 0;
80108bd1:	b8 00 00 00 00       	mov    $0x0,%eax
80108bd6:	eb 44                	jmp    80108c1c <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108bd8:	83 ec 04             	sub    $0x4,%esp
80108bdb:	68 00 10 00 00       	push   $0x1000
80108be0:	6a 00                	push   $0x0
80108be2:	ff 75 f4             	pushl  -0xc(%ebp)
80108be5:	e8 ab d4 ff ff       	call   80106095 <memset>
80108bea:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108bed:	83 ec 0c             	sub    $0xc,%esp
80108bf0:	ff 75 f4             	pushl  -0xc(%ebp)
80108bf3:	e8 f7 fa ff ff       	call   801086ef <v2p>
80108bf8:	83 c4 10             	add    $0x10,%esp
80108bfb:	83 c8 07             	or     $0x7,%eax
80108bfe:	89 c2                	mov    %eax,%edx
80108c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c03:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108c05:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c08:	c1 e8 0c             	shr    $0xc,%eax
80108c0b:	25 ff 03 00 00       	and    $0x3ff,%eax
80108c10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1a:	01 d0                	add    %edx,%eax
}
80108c1c:	c9                   	leave  
80108c1d:	c3                   	ret    

80108c1e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108c1e:	55                   	push   %ebp
80108c1f:	89 e5                	mov    %esp,%ebp
80108c21:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108c24:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c32:	8b 45 10             	mov    0x10(%ebp),%eax
80108c35:	01 d0                	add    %edx,%eax
80108c37:	83 e8 01             	sub    $0x1,%eax
80108c3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108c42:	83 ec 04             	sub    $0x4,%esp
80108c45:	6a 01                	push   $0x1
80108c47:	ff 75 f4             	pushl  -0xc(%ebp)
80108c4a:	ff 75 08             	pushl  0x8(%ebp)
80108c4d:	e8 2c ff ff ff       	call   80108b7e <walkpgdir>
80108c52:	83 c4 10             	add    $0x10,%esp
80108c55:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c5c:	75 07                	jne    80108c65 <mappages+0x47>
      return -1;
80108c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c63:	eb 47                	jmp    80108cac <mappages+0x8e>
    if(*pte & PTE_P)
80108c65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c68:	8b 00                	mov    (%eax),%eax
80108c6a:	83 e0 01             	and    $0x1,%eax
80108c6d:	85 c0                	test   %eax,%eax
80108c6f:	74 0d                	je     80108c7e <mappages+0x60>
      panic("remap");
80108c71:	83 ec 0c             	sub    $0xc,%esp
80108c74:	68 04 9d 10 80       	push   $0x80109d04
80108c79:	e8 e8 78 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108c7e:	8b 45 18             	mov    0x18(%ebp),%eax
80108c81:	0b 45 14             	or     0x14(%ebp),%eax
80108c84:	83 c8 01             	or     $0x1,%eax
80108c87:	89 c2                	mov    %eax,%edx
80108c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c8c:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c91:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c94:	74 10                	je     80108ca6 <mappages+0x88>
      break;
    a += PGSIZE;
80108c96:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108c9d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108ca4:	eb 9c                	jmp    80108c42 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108ca6:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cac:	c9                   	leave  
80108cad:	c3                   	ret    

80108cae <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108cae:	55                   	push   %ebp
80108caf:	89 e5                	mov    %esp,%ebp
80108cb1:	53                   	push   %ebx
80108cb2:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108cb5:	e8 56 a0 ff ff       	call   80102d10 <kalloc>
80108cba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108cbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108cc1:	75 0a                	jne    80108ccd <setupkvm+0x1f>
    return 0;
80108cc3:	b8 00 00 00 00       	mov    $0x0,%eax
80108cc8:	e9 8e 00 00 00       	jmp    80108d5b <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108ccd:	83 ec 04             	sub    $0x4,%esp
80108cd0:	68 00 10 00 00       	push   $0x1000
80108cd5:	6a 00                	push   $0x0
80108cd7:	ff 75 f0             	pushl  -0x10(%ebp)
80108cda:	e8 b6 d3 ff ff       	call   80106095 <memset>
80108cdf:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108ce2:	83 ec 0c             	sub    $0xc,%esp
80108ce5:	68 00 00 00 0e       	push   $0xe000000
80108cea:	e8 0d fa ff ff       	call   801086fc <p2v>
80108cef:	83 c4 10             	add    $0x10,%esp
80108cf2:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108cf7:	76 0d                	jbe    80108d06 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108cf9:	83 ec 0c             	sub    $0xc,%esp
80108cfc:	68 0a 9d 10 80       	push   $0x80109d0a
80108d01:	e8 60 78 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108d06:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108d0d:	eb 40                	jmp    80108d4f <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d12:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d18:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1e:	8b 58 08             	mov    0x8(%eax),%ebx
80108d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d24:	8b 40 04             	mov    0x4(%eax),%eax
80108d27:	29 c3                	sub    %eax,%ebx
80108d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2c:	8b 00                	mov    (%eax),%eax
80108d2e:	83 ec 0c             	sub    $0xc,%esp
80108d31:	51                   	push   %ecx
80108d32:	52                   	push   %edx
80108d33:	53                   	push   %ebx
80108d34:	50                   	push   %eax
80108d35:	ff 75 f0             	pushl  -0x10(%ebp)
80108d38:	e8 e1 fe ff ff       	call   80108c1e <mappages>
80108d3d:	83 c4 20             	add    $0x20,%esp
80108d40:	85 c0                	test   %eax,%eax
80108d42:	79 07                	jns    80108d4b <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108d44:	b8 00 00 00 00       	mov    $0x0,%eax
80108d49:	eb 10                	jmp    80108d5b <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108d4b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108d4f:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108d56:	72 b7                	jb     80108d0f <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108d5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d5e:	c9                   	leave  
80108d5f:	c3                   	ret    

80108d60 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108d60:	55                   	push   %ebp
80108d61:	89 e5                	mov    %esp,%ebp
80108d63:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108d66:	e8 43 ff ff ff       	call   80108cae <setupkvm>
80108d6b:	a3 d8 6b 11 80       	mov    %eax,0x80116bd8
  switchkvm();
80108d70:	e8 03 00 00 00       	call   80108d78 <switchkvm>
}
80108d75:	90                   	nop
80108d76:	c9                   	leave  
80108d77:	c3                   	ret    

80108d78 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108d78:	55                   	push   %ebp
80108d79:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108d7b:	a1 d8 6b 11 80       	mov    0x80116bd8,%eax
80108d80:	50                   	push   %eax
80108d81:	e8 69 f9 ff ff       	call   801086ef <v2p>
80108d86:	83 c4 04             	add    $0x4,%esp
80108d89:	50                   	push   %eax
80108d8a:	e8 54 f9 ff ff       	call   801086e3 <lcr3>
80108d8f:	83 c4 04             	add    $0x4,%esp
}
80108d92:	90                   	nop
80108d93:	c9                   	leave  
80108d94:	c3                   	ret    

80108d95 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108d95:	55                   	push   %ebp
80108d96:	89 e5                	mov    %esp,%ebp
80108d98:	56                   	push   %esi
80108d99:	53                   	push   %ebx
  pushcli();
80108d9a:	e8 f0 d1 ff ff       	call   80105f8f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108d9f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108da5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108dac:	83 c2 08             	add    $0x8,%edx
80108daf:	89 d6                	mov    %edx,%esi
80108db1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108db8:	83 c2 08             	add    $0x8,%edx
80108dbb:	c1 ea 10             	shr    $0x10,%edx
80108dbe:	89 d3                	mov    %edx,%ebx
80108dc0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108dc7:	83 c2 08             	add    $0x8,%edx
80108dca:	c1 ea 18             	shr    $0x18,%edx
80108dcd:	89 d1                	mov    %edx,%ecx
80108dcf:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108dd6:	67 00 
80108dd8:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108ddf:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108de5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108dec:	83 e2 f0             	and    $0xfffffff0,%edx
80108def:	83 ca 09             	or     $0x9,%edx
80108df2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108df8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108dff:	83 ca 10             	or     $0x10,%edx
80108e02:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108e08:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e0f:	83 e2 9f             	and    $0xffffff9f,%edx
80108e12:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108e18:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e1f:	83 ca 80             	or     $0xffffff80,%edx
80108e22:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108e28:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e2f:	83 e2 f0             	and    $0xfffffff0,%edx
80108e32:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e38:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e3f:	83 e2 ef             	and    $0xffffffef,%edx
80108e42:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e48:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e4f:	83 e2 df             	and    $0xffffffdf,%edx
80108e52:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e58:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e5f:	83 ca 40             	or     $0x40,%edx
80108e62:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e68:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e6f:	83 e2 7f             	and    $0x7f,%edx
80108e72:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e78:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108e7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e84:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e8b:	83 e2 ef             	and    $0xffffffef,%edx
80108e8e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108e94:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e9a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108ea0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ea6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ead:	8b 52 08             	mov    0x8(%edx),%edx
80108eb0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108eb6:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108eb9:	83 ec 0c             	sub    $0xc,%esp
80108ebc:	6a 30                	push   $0x30
80108ebe:	e8 f3 f7 ff ff       	call   801086b6 <ltr>
80108ec3:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec9:	8b 40 04             	mov    0x4(%eax),%eax
80108ecc:	85 c0                	test   %eax,%eax
80108ece:	75 0d                	jne    80108edd <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108ed0:	83 ec 0c             	sub    $0xc,%esp
80108ed3:	68 1b 9d 10 80       	push   $0x80109d1b
80108ed8:	e8 89 76 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108edd:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee0:	8b 40 04             	mov    0x4(%eax),%eax
80108ee3:	83 ec 0c             	sub    $0xc,%esp
80108ee6:	50                   	push   %eax
80108ee7:	e8 03 f8 ff ff       	call   801086ef <v2p>
80108eec:	83 c4 10             	add    $0x10,%esp
80108eef:	83 ec 0c             	sub    $0xc,%esp
80108ef2:	50                   	push   %eax
80108ef3:	e8 eb f7 ff ff       	call   801086e3 <lcr3>
80108ef8:	83 c4 10             	add    $0x10,%esp
  popcli();
80108efb:	e8 d4 d0 ff ff       	call   80105fd4 <popcli>
}
80108f00:	90                   	nop
80108f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108f04:	5b                   	pop    %ebx
80108f05:	5e                   	pop    %esi
80108f06:	5d                   	pop    %ebp
80108f07:	c3                   	ret    

80108f08 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108f08:	55                   	push   %ebp
80108f09:	89 e5                	mov    %esp,%ebp
80108f0b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108f0e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108f15:	76 0d                	jbe    80108f24 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108f17:	83 ec 0c             	sub    $0xc,%esp
80108f1a:	68 2f 9d 10 80       	push   $0x80109d2f
80108f1f:	e8 42 76 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108f24:	e8 e7 9d ff ff       	call   80102d10 <kalloc>
80108f29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108f2c:	83 ec 04             	sub    $0x4,%esp
80108f2f:	68 00 10 00 00       	push   $0x1000
80108f34:	6a 00                	push   $0x0
80108f36:	ff 75 f4             	pushl  -0xc(%ebp)
80108f39:	e8 57 d1 ff ff       	call   80106095 <memset>
80108f3e:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108f41:	83 ec 0c             	sub    $0xc,%esp
80108f44:	ff 75 f4             	pushl  -0xc(%ebp)
80108f47:	e8 a3 f7 ff ff       	call   801086ef <v2p>
80108f4c:	83 c4 10             	add    $0x10,%esp
80108f4f:	83 ec 0c             	sub    $0xc,%esp
80108f52:	6a 06                	push   $0x6
80108f54:	50                   	push   %eax
80108f55:	68 00 10 00 00       	push   $0x1000
80108f5a:	6a 00                	push   $0x0
80108f5c:	ff 75 08             	pushl  0x8(%ebp)
80108f5f:	e8 ba fc ff ff       	call   80108c1e <mappages>
80108f64:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108f67:	83 ec 04             	sub    $0x4,%esp
80108f6a:	ff 75 10             	pushl  0x10(%ebp)
80108f6d:	ff 75 0c             	pushl  0xc(%ebp)
80108f70:	ff 75 f4             	pushl  -0xc(%ebp)
80108f73:	e8 dc d1 ff ff       	call   80106154 <memmove>
80108f78:	83 c4 10             	add    $0x10,%esp
}
80108f7b:	90                   	nop
80108f7c:	c9                   	leave  
80108f7d:	c3                   	ret    

80108f7e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108f7e:	55                   	push   %ebp
80108f7f:	89 e5                	mov    %esp,%ebp
80108f81:	53                   	push   %ebx
80108f82:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108f85:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f88:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f8d:	85 c0                	test   %eax,%eax
80108f8f:	74 0d                	je     80108f9e <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108f91:	83 ec 0c             	sub    $0xc,%esp
80108f94:	68 4c 9d 10 80       	push   $0x80109d4c
80108f99:	e8 c8 75 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108f9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fa5:	e9 95 00 00 00       	jmp    8010903f <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108faa:	8b 55 0c             	mov    0xc(%ebp),%edx
80108fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb0:	01 d0                	add    %edx,%eax
80108fb2:	83 ec 04             	sub    $0x4,%esp
80108fb5:	6a 00                	push   $0x0
80108fb7:	50                   	push   %eax
80108fb8:	ff 75 08             	pushl  0x8(%ebp)
80108fbb:	e8 be fb ff ff       	call   80108b7e <walkpgdir>
80108fc0:	83 c4 10             	add    $0x10,%esp
80108fc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108fc6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108fca:	75 0d                	jne    80108fd9 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108fcc:	83 ec 0c             	sub    $0xc,%esp
80108fcf:	68 6f 9d 10 80       	push   $0x80109d6f
80108fd4:	e8 8d 75 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108fd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fdc:	8b 00                	mov    (%eax),%eax
80108fde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fe3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108fe6:	8b 45 18             	mov    0x18(%ebp),%eax
80108fe9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108fec:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108ff1:	77 0b                	ja     80108ffe <loaduvm+0x80>
      n = sz - i;
80108ff3:	8b 45 18             	mov    0x18(%ebp),%eax
80108ff6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108ff9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ffc:	eb 07                	jmp    80109005 <loaduvm+0x87>
    else
      n = PGSIZE;
80108ffe:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109005:	8b 55 14             	mov    0x14(%ebp),%edx
80109008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010900e:	83 ec 0c             	sub    $0xc,%esp
80109011:	ff 75 e8             	pushl  -0x18(%ebp)
80109014:	e8 e3 f6 ff ff       	call   801086fc <p2v>
80109019:	83 c4 10             	add    $0x10,%esp
8010901c:	ff 75 f0             	pushl  -0x10(%ebp)
8010901f:	53                   	push   %ebx
80109020:	50                   	push   %eax
80109021:	ff 75 10             	pushl  0x10(%ebp)
80109024:	e8 59 8f ff ff       	call   80101f82 <readi>
80109029:	83 c4 10             	add    $0x10,%esp
8010902c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010902f:	74 07                	je     80109038 <loaduvm+0xba>
      return -1;
80109031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109036:	eb 18                	jmp    80109050 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109038:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010903f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109042:	3b 45 18             	cmp    0x18(%ebp),%eax
80109045:	0f 82 5f ff ff ff    	jb     80108faa <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010904b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109053:	c9                   	leave  
80109054:	c3                   	ret    

80109055 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109055:	55                   	push   %ebp
80109056:	89 e5                	mov    %esp,%ebp
80109058:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010905b:	8b 45 10             	mov    0x10(%ebp),%eax
8010905e:	85 c0                	test   %eax,%eax
80109060:	79 0a                	jns    8010906c <allocuvm+0x17>
    return 0;
80109062:	b8 00 00 00 00       	mov    $0x0,%eax
80109067:	e9 b0 00 00 00       	jmp    8010911c <allocuvm+0xc7>
  if(newsz < oldsz)
8010906c:	8b 45 10             	mov    0x10(%ebp),%eax
8010906f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109072:	73 08                	jae    8010907c <allocuvm+0x27>
    return oldsz;
80109074:	8b 45 0c             	mov    0xc(%ebp),%eax
80109077:	e9 a0 00 00 00       	jmp    8010911c <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010907c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010907f:	05 ff 0f 00 00       	add    $0xfff,%eax
80109084:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109089:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010908c:	eb 7f                	jmp    8010910d <allocuvm+0xb8>
    mem = kalloc();
8010908e:	e8 7d 9c ff ff       	call   80102d10 <kalloc>
80109093:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109096:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010909a:	75 2b                	jne    801090c7 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
8010909c:	83 ec 0c             	sub    $0xc,%esp
8010909f:	68 8d 9d 10 80       	push   $0x80109d8d
801090a4:	e8 1d 73 ff ff       	call   801003c6 <cprintf>
801090a9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801090ac:	83 ec 04             	sub    $0x4,%esp
801090af:	ff 75 0c             	pushl  0xc(%ebp)
801090b2:	ff 75 10             	pushl  0x10(%ebp)
801090b5:	ff 75 08             	pushl  0x8(%ebp)
801090b8:	e8 61 00 00 00       	call   8010911e <deallocuvm>
801090bd:	83 c4 10             	add    $0x10,%esp
      return 0;
801090c0:	b8 00 00 00 00       	mov    $0x0,%eax
801090c5:	eb 55                	jmp    8010911c <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801090c7:	83 ec 04             	sub    $0x4,%esp
801090ca:	68 00 10 00 00       	push   $0x1000
801090cf:	6a 00                	push   $0x0
801090d1:	ff 75 f0             	pushl  -0x10(%ebp)
801090d4:	e8 bc cf ff ff       	call   80106095 <memset>
801090d9:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801090dc:	83 ec 0c             	sub    $0xc,%esp
801090df:	ff 75 f0             	pushl  -0x10(%ebp)
801090e2:	e8 08 f6 ff ff       	call   801086ef <v2p>
801090e7:	83 c4 10             	add    $0x10,%esp
801090ea:	89 c2                	mov    %eax,%edx
801090ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ef:	83 ec 0c             	sub    $0xc,%esp
801090f2:	6a 06                	push   $0x6
801090f4:	52                   	push   %edx
801090f5:	68 00 10 00 00       	push   $0x1000
801090fa:	50                   	push   %eax
801090fb:	ff 75 08             	pushl  0x8(%ebp)
801090fe:	e8 1b fb ff ff       	call   80108c1e <mappages>
80109103:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109106:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010910d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109110:	3b 45 10             	cmp    0x10(%ebp),%eax
80109113:	0f 82 75 ff ff ff    	jb     8010908e <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109119:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010911c:	c9                   	leave  
8010911d:	c3                   	ret    

8010911e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010911e:	55                   	push   %ebp
8010911f:	89 e5                	mov    %esp,%ebp
80109121:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109124:	8b 45 10             	mov    0x10(%ebp),%eax
80109127:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010912a:	72 08                	jb     80109134 <deallocuvm+0x16>
    return oldsz;
8010912c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010912f:	e9 a5 00 00 00       	jmp    801091d9 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109134:	8b 45 10             	mov    0x10(%ebp),%eax
80109137:	05 ff 0f 00 00       	add    $0xfff,%eax
8010913c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109141:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109144:	e9 81 00 00 00       	jmp    801091ca <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914c:	83 ec 04             	sub    $0x4,%esp
8010914f:	6a 00                	push   $0x0
80109151:	50                   	push   %eax
80109152:	ff 75 08             	pushl  0x8(%ebp)
80109155:	e8 24 fa ff ff       	call   80108b7e <walkpgdir>
8010915a:	83 c4 10             	add    $0x10,%esp
8010915d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109160:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109164:	75 09                	jne    8010916f <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109166:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010916d:	eb 54                	jmp    801091c3 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010916f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109172:	8b 00                	mov    (%eax),%eax
80109174:	83 e0 01             	and    $0x1,%eax
80109177:	85 c0                	test   %eax,%eax
80109179:	74 48                	je     801091c3 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010917b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010917e:	8b 00                	mov    (%eax),%eax
80109180:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109185:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109188:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010918c:	75 0d                	jne    8010919b <deallocuvm+0x7d>
        panic("kfree");
8010918e:	83 ec 0c             	sub    $0xc,%esp
80109191:	68 a5 9d 10 80       	push   $0x80109da5
80109196:	e8 cb 73 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010919b:	83 ec 0c             	sub    $0xc,%esp
8010919e:	ff 75 ec             	pushl  -0x14(%ebp)
801091a1:	e8 56 f5 ff ff       	call   801086fc <p2v>
801091a6:	83 c4 10             	add    $0x10,%esp
801091a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801091ac:	83 ec 0c             	sub    $0xc,%esp
801091af:	ff 75 e8             	pushl  -0x18(%ebp)
801091b2:	e8 bc 9a ff ff       	call   80102c73 <kfree>
801091b7:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801091ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801091c3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801091ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091d0:	0f 82 73 ff ff ff    	jb     80109149 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801091d6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801091d9:	c9                   	leave  
801091da:	c3                   	ret    

801091db <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801091db:	55                   	push   %ebp
801091dc:	89 e5                	mov    %esp,%ebp
801091de:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801091e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801091e5:	75 0d                	jne    801091f4 <freevm+0x19>
    panic("freevm: no pgdir");
801091e7:	83 ec 0c             	sub    $0xc,%esp
801091ea:	68 ab 9d 10 80       	push   $0x80109dab
801091ef:	e8 72 73 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801091f4:	83 ec 04             	sub    $0x4,%esp
801091f7:	6a 00                	push   $0x0
801091f9:	68 00 00 00 80       	push   $0x80000000
801091fe:	ff 75 08             	pushl  0x8(%ebp)
80109201:	e8 18 ff ff ff       	call   8010911e <deallocuvm>
80109206:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109209:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109210:	eb 4f                	jmp    80109261 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109215:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010921c:	8b 45 08             	mov    0x8(%ebp),%eax
8010921f:	01 d0                	add    %edx,%eax
80109221:	8b 00                	mov    (%eax),%eax
80109223:	83 e0 01             	and    $0x1,%eax
80109226:	85 c0                	test   %eax,%eax
80109228:	74 33                	je     8010925d <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010922a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010922d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109234:	8b 45 08             	mov    0x8(%ebp),%eax
80109237:	01 d0                	add    %edx,%eax
80109239:	8b 00                	mov    (%eax),%eax
8010923b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109240:	83 ec 0c             	sub    $0xc,%esp
80109243:	50                   	push   %eax
80109244:	e8 b3 f4 ff ff       	call   801086fc <p2v>
80109249:	83 c4 10             	add    $0x10,%esp
8010924c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010924f:	83 ec 0c             	sub    $0xc,%esp
80109252:	ff 75 f0             	pushl  -0x10(%ebp)
80109255:	e8 19 9a ff ff       	call   80102c73 <kfree>
8010925a:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010925d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109261:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109268:	76 a8                	jbe    80109212 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010926a:	83 ec 0c             	sub    $0xc,%esp
8010926d:	ff 75 08             	pushl  0x8(%ebp)
80109270:	e8 fe 99 ff ff       	call   80102c73 <kfree>
80109275:	83 c4 10             	add    $0x10,%esp
}
80109278:	90                   	nop
80109279:	c9                   	leave  
8010927a:	c3                   	ret    

8010927b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010927b:	55                   	push   %ebp
8010927c:	89 e5                	mov    %esp,%ebp
8010927e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109281:	83 ec 04             	sub    $0x4,%esp
80109284:	6a 00                	push   $0x0
80109286:	ff 75 0c             	pushl  0xc(%ebp)
80109289:	ff 75 08             	pushl  0x8(%ebp)
8010928c:	e8 ed f8 ff ff       	call   80108b7e <walkpgdir>
80109291:	83 c4 10             	add    $0x10,%esp
80109294:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109297:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010929b:	75 0d                	jne    801092aa <clearpteu+0x2f>
    panic("clearpteu");
8010929d:	83 ec 0c             	sub    $0xc,%esp
801092a0:	68 bc 9d 10 80       	push   $0x80109dbc
801092a5:	e8 bc 72 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801092aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ad:	8b 00                	mov    (%eax),%eax
801092af:	83 e0 fb             	and    $0xfffffffb,%eax
801092b2:	89 c2                	mov    %eax,%edx
801092b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b7:	89 10                	mov    %edx,(%eax)
}
801092b9:	90                   	nop
801092ba:	c9                   	leave  
801092bb:	c3                   	ret    

801092bc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801092bc:	55                   	push   %ebp
801092bd:	89 e5                	mov    %esp,%ebp
801092bf:	53                   	push   %ebx
801092c0:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801092c3:	e8 e6 f9 ff ff       	call   80108cae <setupkvm>
801092c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801092cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801092cf:	75 0a                	jne    801092db <copyuvm+0x1f>
    return 0;
801092d1:	b8 00 00 00 00       	mov    $0x0,%eax
801092d6:	e9 f8 00 00 00       	jmp    801093d3 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801092db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092e2:	e9 c4 00 00 00       	jmp    801093ab <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801092e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ea:	83 ec 04             	sub    $0x4,%esp
801092ed:	6a 00                	push   $0x0
801092ef:	50                   	push   %eax
801092f0:	ff 75 08             	pushl  0x8(%ebp)
801092f3:	e8 86 f8 ff ff       	call   80108b7e <walkpgdir>
801092f8:	83 c4 10             	add    $0x10,%esp
801092fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801092fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109302:	75 0d                	jne    80109311 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109304:	83 ec 0c             	sub    $0xc,%esp
80109307:	68 c6 9d 10 80       	push   $0x80109dc6
8010930c:	e8 55 72 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109314:	8b 00                	mov    (%eax),%eax
80109316:	83 e0 01             	and    $0x1,%eax
80109319:	85 c0                	test   %eax,%eax
8010931b:	75 0d                	jne    8010932a <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010931d:	83 ec 0c             	sub    $0xc,%esp
80109320:	68 e0 9d 10 80       	push   $0x80109de0
80109325:	e8 3c 72 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010932a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010932d:	8b 00                	mov    (%eax),%eax
8010932f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109334:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109337:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010933a:	8b 00                	mov    (%eax),%eax
8010933c:	25 ff 0f 00 00       	and    $0xfff,%eax
80109341:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109344:	e8 c7 99 ff ff       	call   80102d10 <kalloc>
80109349:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010934c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109350:	74 6a                	je     801093bc <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109352:	83 ec 0c             	sub    $0xc,%esp
80109355:	ff 75 e8             	pushl  -0x18(%ebp)
80109358:	e8 9f f3 ff ff       	call   801086fc <p2v>
8010935d:	83 c4 10             	add    $0x10,%esp
80109360:	83 ec 04             	sub    $0x4,%esp
80109363:	68 00 10 00 00       	push   $0x1000
80109368:	50                   	push   %eax
80109369:	ff 75 e0             	pushl  -0x20(%ebp)
8010936c:	e8 e3 cd ff ff       	call   80106154 <memmove>
80109371:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109374:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109377:	83 ec 0c             	sub    $0xc,%esp
8010937a:	ff 75 e0             	pushl  -0x20(%ebp)
8010937d:	e8 6d f3 ff ff       	call   801086ef <v2p>
80109382:	83 c4 10             	add    $0x10,%esp
80109385:	89 c2                	mov    %eax,%edx
80109387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938a:	83 ec 0c             	sub    $0xc,%esp
8010938d:	53                   	push   %ebx
8010938e:	52                   	push   %edx
8010938f:	68 00 10 00 00       	push   $0x1000
80109394:	50                   	push   %eax
80109395:	ff 75 f0             	pushl  -0x10(%ebp)
80109398:	e8 81 f8 ff ff       	call   80108c1e <mappages>
8010939d:	83 c4 20             	add    $0x20,%esp
801093a0:	85 c0                	test   %eax,%eax
801093a2:	78 1b                	js     801093bf <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801093a4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801093ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801093b1:	0f 82 30 ff ff ff    	jb     801092e7 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801093b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ba:	eb 17                	jmp    801093d3 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801093bc:	90                   	nop
801093bd:	eb 01                	jmp    801093c0 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801093bf:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801093c0:	83 ec 0c             	sub    $0xc,%esp
801093c3:	ff 75 f0             	pushl  -0x10(%ebp)
801093c6:	e8 10 fe ff ff       	call   801091db <freevm>
801093cb:	83 c4 10             	add    $0x10,%esp
  return 0;
801093ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801093d6:	c9                   	leave  
801093d7:	c3                   	ret    

801093d8 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801093d8:	55                   	push   %ebp
801093d9:	89 e5                	mov    %esp,%ebp
801093db:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801093de:	83 ec 04             	sub    $0x4,%esp
801093e1:	6a 00                	push   $0x0
801093e3:	ff 75 0c             	pushl  0xc(%ebp)
801093e6:	ff 75 08             	pushl  0x8(%ebp)
801093e9:	e8 90 f7 ff ff       	call   80108b7e <walkpgdir>
801093ee:	83 c4 10             	add    $0x10,%esp
801093f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801093f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f7:	8b 00                	mov    (%eax),%eax
801093f9:	83 e0 01             	and    $0x1,%eax
801093fc:	85 c0                	test   %eax,%eax
801093fe:	75 07                	jne    80109407 <uva2ka+0x2f>
    return 0;
80109400:	b8 00 00 00 00       	mov    $0x0,%eax
80109405:	eb 29                	jmp    80109430 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010940a:	8b 00                	mov    (%eax),%eax
8010940c:	83 e0 04             	and    $0x4,%eax
8010940f:	85 c0                	test   %eax,%eax
80109411:	75 07                	jne    8010941a <uva2ka+0x42>
    return 0;
80109413:	b8 00 00 00 00       	mov    $0x0,%eax
80109418:	eb 16                	jmp    80109430 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010941a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010941d:	8b 00                	mov    (%eax),%eax
8010941f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109424:	83 ec 0c             	sub    $0xc,%esp
80109427:	50                   	push   %eax
80109428:	e8 cf f2 ff ff       	call   801086fc <p2v>
8010942d:	83 c4 10             	add    $0x10,%esp
}
80109430:	c9                   	leave  
80109431:	c3                   	ret    

80109432 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109432:	55                   	push   %ebp
80109433:	89 e5                	mov    %esp,%ebp
80109435:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109438:	8b 45 10             	mov    0x10(%ebp),%eax
8010943b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010943e:	eb 7f                	jmp    801094bf <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109440:	8b 45 0c             	mov    0xc(%ebp),%eax
80109443:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109448:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010944b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010944e:	83 ec 08             	sub    $0x8,%esp
80109451:	50                   	push   %eax
80109452:	ff 75 08             	pushl  0x8(%ebp)
80109455:	e8 7e ff ff ff       	call   801093d8 <uva2ka>
8010945a:	83 c4 10             	add    $0x10,%esp
8010945d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109460:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109464:	75 07                	jne    8010946d <copyout+0x3b>
      return -1;
80109466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010946b:	eb 61                	jmp    801094ce <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010946d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109470:	2b 45 0c             	sub    0xc(%ebp),%eax
80109473:	05 00 10 00 00       	add    $0x1000,%eax
80109478:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010947b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010947e:	3b 45 14             	cmp    0x14(%ebp),%eax
80109481:	76 06                	jbe    80109489 <copyout+0x57>
      n = len;
80109483:	8b 45 14             	mov    0x14(%ebp),%eax
80109486:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109489:	8b 45 0c             	mov    0xc(%ebp),%eax
8010948c:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010948f:	89 c2                	mov    %eax,%edx
80109491:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109494:	01 d0                	add    %edx,%eax
80109496:	83 ec 04             	sub    $0x4,%esp
80109499:	ff 75 f0             	pushl  -0x10(%ebp)
8010949c:	ff 75 f4             	pushl  -0xc(%ebp)
8010949f:	50                   	push   %eax
801094a0:	e8 af cc ff ff       	call   80106154 <memmove>
801094a5:	83 c4 10             	add    $0x10,%esp
    len -= n;
801094a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ab:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801094ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801094b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094b7:	05 00 10 00 00       	add    $0x1000,%eax
801094bc:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801094bf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801094c3:	0f 85 77 ff ff ff    	jne    80109440 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801094c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801094ce:	c9                   	leave  
801094cf:	c3                   	ret    
