
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
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
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
80100028:	bc 70 e6 10 80       	mov    $0x8010e670,%esp

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
8010003d:	68 d8 a1 10 80       	push   $0x8010a1d8
80100042:	68 80 e6 10 80       	push   $0x8010e680
80100047:	e8 29 6a 00 00       	call   80106a75 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 25 11 80 84 	movl   $0x80112584,0x80112590
80100056:	25 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 25 11 80 84 	movl   $0x80112584,0x80112594
80100060:	25 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 e6 10 80 	movl   $0x8010e6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 25 11 80    	mov    0x80112594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 25 11 80 	movl   $0x80112584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 25 11 80       	mov    0x80112594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 25 11 80       	mov    %eax,0x80112594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 25 11 80       	mov    $0x80112584,%eax
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
801000bc:	68 80 e6 10 80       	push   $0x8010e680
801000c1:	e8 d1 69 00 00       	call   80106a97 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 25 11 80       	mov    0x80112594,%eax
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
80100107:	68 80 e6 10 80       	push   $0x8010e680
8010010c:	e8 ed 69 00 00       	call   80106afe <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 e6 10 80       	push   $0x8010e680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 56 56 00 00       	call   80105782 <sleep>
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
8010013a:	81 7d f4 84 25 11 80 	cmpl   $0x80112584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 25 11 80       	mov    0x80112590,%eax
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
80100183:	68 80 e6 10 80       	push   $0x8010e680
80100188:	e8 71 69 00 00       	call   80106afe <release>
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
8010019e:	81 7d f4 84 25 11 80 	cmpl   $0x80112584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 df a1 10 80       	push   $0x8010a1df
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
80100204:	68 f0 a1 10 80       	push   $0x8010a1f0
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
80100243:	68 f7 a1 10 80       	push   $0x8010a1f7
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 e6 10 80       	push   $0x8010e680
80100255:	e8 3d 68 00 00       	call   80106a97 <acquire>
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
8010027b:	8b 15 94 25 11 80    	mov    0x80112594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 25 11 80 	movl   $0x80112584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 25 11 80       	mov    0x80112594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 25 11 80       	mov    %eax,0x80112594

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
801002b9:	e8 d4 56 00 00       	call   80105992 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 e6 10 80       	push   $0x8010e680
801002c9:	e8 30 68 00 00       	call   80106afe <release>
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
80100365:	0f b6 80 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%eax
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
801003cc:	a1 14 d6 10 80       	mov    0x8010d614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 d5 10 80       	push   $0x8010d5e0
801003e2:	e8 b0 66 00 00       	call   80106a97 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 fe a1 10 80       	push   $0x8010a1fe
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
801004cd:	c7 45 ec 07 a2 10 80 	movl   $0x8010a207,-0x14(%ebp)
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
80100556:	68 e0 d5 10 80       	push   $0x8010d5e0
8010055b:	e8 9e 65 00 00       	call   80106afe <release>
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
80100571:	c7 05 14 d6 10 80 00 	movl   $0x0,0x8010d614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 0e a2 10 80       	push   $0x8010a20e
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
801005aa:	68 1d a2 10 80       	push   $0x8010a21d
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 89 65 00 00       	call   80106b50 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 1f a2 10 80       	push   $0x8010a21f
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
801005f5:	c7 05 c0 d5 10 80 01 	movl   $0x1,0x8010d5c0
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
80100699:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
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
801006ca:	68 23 a2 10 80       	push   $0x8010a223
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 bd 66 00 00       	call   80106db9 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 d4 65 00 00       	call   80106cfa <memset>
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
8010077e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
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
80100798:	a1 c0 d5 10 80       	mov    0x8010d5c0,%eax
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
801007b6:	e8 a5 80 00 00       	call   80108860 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 98 80 00 00       	call   80108860 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 8b 80 00 00       	call   80108860 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 7b 80 00 00       	call   80108860 <uartputc>
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

#ifdef CS333_P3P4
  int doprintready  = 0;
80100806:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int doprintfree   = 0;
8010080d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int doprintsleep  = 0;
80100814:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  int doprintzombie = 0;
8010081b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

#endif


  acquire(&cons.lock);
80100822:	83 ec 0c             	sub    $0xc,%esp
80100825:	68 e0 d5 10 80       	push   $0x8010d5e0
8010082a:	e8 68 62 00 00       	call   80106a97 <acquire>
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
8010089b:	a1 28 28 11 80       	mov    0x80112828,%eax
801008a0:	83 e8 01             	sub    $0x1,%eax
801008a3:	a3 28 28 11 80       	mov    %eax,0x80112828
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
801008b8:	8b 15 28 28 11 80    	mov    0x80112828,%edx
801008be:	a1 24 28 11 80       	mov    0x80112824,%eax
801008c3:	39 c2                	cmp    %eax,%edx
801008c5:	0f 84 12 01 00 00    	je     801009dd <consoleintr+0x1e4>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008cb:	a1 28 28 11 80       	mov    0x80112828,%eax
801008d0:	83 e8 01             	sub    $0x1,%eax
801008d3:	83 e0 7f             	and    $0x7f,%eax
801008d6:	0f b6 80 a0 27 11 80 	movzbl -0x7feed860(%eax),%eax
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
801008e6:	8b 15 28 28 11 80    	mov    0x80112828,%edx
801008ec:	a1 24 28 11 80       	mov    0x80112824,%eax
801008f1:	39 c2                	cmp    %eax,%edx
801008f3:	0f 84 e4 00 00 00    	je     801009dd <consoleintr+0x1e4>
        input.e--;
801008f9:	a1 28 28 11 80       	mov    0x80112828,%eax
801008fe:	83 e8 01             	sub    $0x1,%eax
80100901:	a3 28 28 11 80       	mov    %eax,0x80112828
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
80100955:	8b 15 28 28 11 80    	mov    0x80112828,%edx
8010095b:	a1 20 28 11 80       	mov    0x80112820,%eax
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
8010097c:	a1 28 28 11 80       	mov    0x80112828,%eax
80100981:	8d 50 01             	lea    0x1(%eax),%edx
80100984:	89 15 28 28 11 80    	mov    %edx,0x80112828
8010098a:	83 e0 7f             	and    $0x7f,%eax
8010098d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100990:	88 90 a0 27 11 80    	mov    %dl,-0x7feed860(%eax)
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
801009b0:	a1 28 28 11 80       	mov    0x80112828,%eax
801009b5:	8b 15 20 28 11 80    	mov    0x80112820,%edx
801009bb:	83 ea 80             	sub    $0xffffff80,%edx
801009be:	39 d0                	cmp    %edx,%eax
801009c0:	75 1a                	jne    801009dc <consoleintr+0x1e3>
          input.w = input.e;
801009c2:	a1 28 28 11 80       	mov    0x80112828,%eax
801009c7:	a3 24 28 11 80       	mov    %eax,0x80112824
          wakeup(&input.r);
801009cc:	83 ec 0c             	sub    $0xc,%esp
801009cf:	68 20 28 11 80       	push   $0x80112820
801009d4:	e8 b9 4f 00 00       	call   80105992 <wakeup>
801009d9:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009dc:	90                   	nop

#endif


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
801009f2:	68 e0 d5 10 80       	push   $0x8010d5e0
801009f7:	e8 02 61 00 00       	call   80106afe <release>
801009fc:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a03:	74 05                	je     80100a0a <consoleintr+0x211>
    procdump();  // now call procdump() wo. cons.lock held
80100a05:	e8 de 51 00 00       	call   80105be8 <procdump>
  }

#ifdef CS333_P3P4
  if(doprintready)
80100a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a0e:	74 05                	je     80100a15 <consoleintr+0x21c>
      printready();
80100a10:	e8 56 5b 00 00       	call   8010656b <printready>
  if(doprintfree)
80100a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a19:	74 05                	je     80100a20 <consoleintr+0x227>
      printfree();
80100a1b:	e8 26 5c 00 00       	call   80106646 <printfree>
  if(doprintsleep)
80100a20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a24:	74 05                	je     80100a2b <consoleintr+0x232>
      printsleep();
80100a26:	e8 8e 5c 00 00       	call   801066b9 <printsleep>
  if(doprintzombie)
80100a2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2f:	74 05                	je     80100a36 <consoleintr+0x23d>
      printzombie();
80100a31:	e8 32 5d 00 00       	call   80106768 <printzombie>

#endif
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
80100a56:	68 e0 d5 10 80       	push   $0x8010d5e0
80100a5b:	e8 37 60 00 00       	call   80106a97 <acquire>
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
80100a78:	68 e0 d5 10 80       	push   $0x8010d5e0
80100a7d:	e8 7c 60 00 00       	call   80106afe <release>
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
80100aa0:	68 e0 d5 10 80       	push   $0x8010d5e0
80100aa5:	68 20 28 11 80       	push   $0x80112820
80100aaa:	e8 d3 4c 00 00       	call   80105782 <sleep>
80100aaf:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100ab2:	8b 15 20 28 11 80    	mov    0x80112820,%edx
80100ab8:	a1 24 28 11 80       	mov    0x80112824,%eax
80100abd:	39 c2                	cmp    %eax,%edx
80100abf:	74 a7                	je     80100a68 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ac1:	a1 20 28 11 80       	mov    0x80112820,%eax
80100ac6:	8d 50 01             	lea    0x1(%eax),%edx
80100ac9:	89 15 20 28 11 80    	mov    %edx,0x80112820
80100acf:	83 e0 7f             	and    $0x7f,%eax
80100ad2:	0f b6 80 a0 27 11 80 	movzbl -0x7feed860(%eax),%eax
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
80100aed:	a1 20 28 11 80       	mov    0x80112820,%eax
80100af2:	83 e8 01             	sub    $0x1,%eax
80100af5:	a3 20 28 11 80       	mov    %eax,0x80112820
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
80100b23:	68 e0 d5 10 80       	push   $0x8010d5e0
80100b28:	e8 d1 5f 00 00       	call   80106afe <release>
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
80100b61:	68 e0 d5 10 80       	push   $0x8010d5e0
80100b66:	e8 2c 5f 00 00       	call   80106a97 <acquire>
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
80100ba3:	68 e0 d5 10 80       	push   $0x8010d5e0
80100ba8:	e8 51 5f 00 00       	call   80106afe <release>
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
80100bcc:	68 36 a2 10 80       	push   $0x8010a236
80100bd1:	68 e0 d5 10 80       	push   $0x8010d5e0
80100bd6:	e8 9a 5e 00 00       	call   80106a75 <initlock>
80100bdb:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bde:	c7 05 ec 31 11 80 4a 	movl   $0x80100b4a,0x801131ec
80100be5:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100be8:	c7 05 e8 31 11 80 39 	movl   $0x80100a39,0x801131e8
80100bef:	0a 10 80 
  cons.locking = 1;
80100bf2:	c7 05 14 d6 10 80 01 	movl   $0x1,0x8010d614
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
80100c94:	e8 1c 8d 00 00       	call   801099b5 <setupkvm>
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
80100d1a:	e8 3d 90 00 00       	call   80109d5c <allocuvm>
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
80100d4d:	e8 33 8f 00 00       	call   80109c85 <loaduvm>
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
80100dbc:	e8 9b 8f 00 00       	call   80109d5c <allocuvm>
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
80100de0:	e8 9d 91 00 00       	call   80109f82 <clearpteu>
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
80100e19:	e8 29 61 00 00       	call   80106f47 <strlen>
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
80100e46:	e8 fc 60 00 00       	call   80106f47 <strlen>
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
80100e6c:	e8 c8 92 00 00       	call   8010a139 <copyout>
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
80100f08:	e8 2c 92 00 00       	call   8010a139 <copyout>
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
80100f59:	e8 9f 5f 00 00       	call   80106efd <safestrcpy>
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
80100faf:	e8 e8 8a 00 00       	call   80109a9c <switchuvm>
80100fb4:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fb7:	83 ec 0c             	sub    $0xc,%esp
80100fba:	ff 75 d0             	pushl  -0x30(%ebp)
80100fbd:	e8 20 8f 00 00       	call   80109ee2 <freevm>
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
80100ff7:	e8 e6 8e 00 00       	call   80109ee2 <freevm>
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
80101028:	68 3e a2 10 80       	push   $0x8010a23e
8010102d:	68 40 28 11 80       	push   $0x80112840
80101032:	e8 3e 5a 00 00       	call   80106a75 <initlock>
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
80101046:	68 40 28 11 80       	push   $0x80112840
8010104b:	e8 47 5a 00 00       	call   80106a97 <acquire>
80101050:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101053:	c7 45 f4 74 28 11 80 	movl   $0x80112874,-0xc(%ebp)
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
80101073:	68 40 28 11 80       	push   $0x80112840
80101078:	e8 81 5a 00 00       	call   80106afe <release>
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
80101089:	b8 d4 31 11 80       	mov    $0x801131d4,%eax
8010108e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101091:	72 c9                	jb     8010105c <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101093:	83 ec 0c             	sub    $0xc,%esp
80101096:	68 40 28 11 80       	push   $0x80112840
8010109b:	e8 5e 5a 00 00       	call   80106afe <release>
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
801010b3:	68 40 28 11 80       	push   $0x80112840
801010b8:	e8 da 59 00 00       	call   80106a97 <acquire>
801010bd:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	8b 40 04             	mov    0x4(%eax),%eax
801010c6:	85 c0                	test   %eax,%eax
801010c8:	7f 0d                	jg     801010d7 <filedup+0x2d>
    panic("filedup");
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 45 a2 10 80       	push   $0x8010a245
801010d2:	e8 8f f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	8d 50 01             	lea    0x1(%eax),%edx
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
801010e3:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010e6:	83 ec 0c             	sub    $0xc,%esp
801010e9:	68 40 28 11 80       	push   $0x80112840
801010ee:	e8 0b 5a 00 00       	call   80106afe <release>
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
80101104:	68 40 28 11 80       	push   $0x80112840
80101109:	e8 89 59 00 00       	call   80106a97 <acquire>
8010110e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101111:	8b 45 08             	mov    0x8(%ebp),%eax
80101114:	8b 40 04             	mov    0x4(%eax),%eax
80101117:	85 c0                	test   %eax,%eax
80101119:	7f 0d                	jg     80101128 <fileclose+0x2d>
    panic("fileclose");
8010111b:	83 ec 0c             	sub    $0xc,%esp
8010111e:	68 4d a2 10 80       	push   $0x8010a24d
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
80101144:	68 40 28 11 80       	push   $0x80112840
80101149:	e8 b0 59 00 00       	call   80106afe <release>
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
80101192:	68 40 28 11 80       	push   $0x80112840
80101197:	e8 62 59 00 00       	call   80106afe <release>
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
801012e6:	68 57 a2 10 80       	push   $0x8010a257
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
801013e9:	68 60 a2 10 80       	push   $0x8010a260
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
8010141f:	68 70 a2 10 80       	push   $0x8010a270
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
80101457:	e8 5d 59 00 00       	call   80106db9 <memmove>
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
8010149d:	e8 58 58 00 00       	call   80106cfa <memset>
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
801014f0:	a1 58 32 11 80       	mov    0x80113258,%eax
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
801015ce:	a1 40 32 11 80       	mov    0x80113240,%eax
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
801015f0:	8b 15 40 32 11 80    	mov    0x80113240,%edx
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
80101604:	68 7c a2 10 80       	push   $0x8010a27c
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
80101619:	68 40 32 11 80       	push   $0x80113240
8010161e:	ff 75 08             	pushl  0x8(%ebp)
80101621:	e8 08 fe ff ff       	call   8010142e <readsb>
80101626:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010162c:	c1 e8 0c             	shr    $0xc,%eax
8010162f:	89 c2                	mov    %eax,%edx
80101631:	a1 58 32 11 80       	mov    0x80113258,%eax
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
80101697:	68 92 a2 10 80       	push   $0x8010a292
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
801016f4:	68 a5 a2 10 80       	push   $0x8010a2a5
801016f9:	68 60 32 11 80       	push   $0x80113260
801016fe:	e8 72 53 00 00       	call   80106a75 <initlock>
80101703:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101706:	83 ec 08             	sub    $0x8,%esp
80101709:	68 40 32 11 80       	push   $0x80113240
8010170e:	ff 75 08             	pushl  0x8(%ebp)
80101711:	e8 18 fd ff ff       	call   8010142e <readsb>
80101716:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101719:	a1 58 32 11 80       	mov    0x80113258,%eax
8010171e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101721:	8b 3d 54 32 11 80    	mov    0x80113254,%edi
80101727:	8b 35 50 32 11 80    	mov    0x80113250,%esi
8010172d:	8b 1d 4c 32 11 80    	mov    0x8011324c,%ebx
80101733:	8b 0d 48 32 11 80    	mov    0x80113248,%ecx
80101739:	8b 15 44 32 11 80    	mov    0x80113244,%edx
8010173f:	a1 40 32 11 80       	mov    0x80113240,%eax
80101744:	ff 75 e4             	pushl  -0x1c(%ebp)
80101747:	57                   	push   %edi
80101748:	56                   	push   %esi
80101749:	53                   	push   %ebx
8010174a:	51                   	push   %ecx
8010174b:	52                   	push   %edx
8010174c:	50                   	push   %eax
8010174d:	68 ac a2 10 80       	push   $0x8010a2ac
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
80101784:	a1 54 32 11 80       	mov    0x80113254,%eax
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
801017c6:	e8 2f 55 00 00       	call   80106cfa <memset>
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
8010181a:	8b 15 48 32 11 80    	mov    0x80113248,%edx
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
8010182e:	68 ff a2 10 80       	push   $0x8010a2ff
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
8010184b:	a1 54 32 11 80       	mov    0x80113254,%eax
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
801018d4:	e8 e0 54 00 00       	call   80106db9 <memmove>
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
80101904:	68 60 32 11 80       	push   $0x80113260
80101909:	e8 89 51 00 00       	call   80106a97 <acquire>
8010190e:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101911:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101918:	c7 45 f4 94 32 11 80 	movl   $0x80113294,-0xc(%ebp)
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
80101952:	68 60 32 11 80       	push   $0x80113260
80101957:	e8 a2 51 00 00       	call   80106afe <release>
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
8010197e:	81 7d f4 34 42 11 80 	cmpl   $0x80114234,-0xc(%ebp)
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
80101990:	68 11 a3 10 80       	push   $0x8010a311
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
801019c8:	68 60 32 11 80       	push   $0x80113260
801019cd:	e8 2c 51 00 00       	call   80106afe <release>
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
801019e3:	68 60 32 11 80       	push   $0x80113260
801019e8:	e8 aa 50 00 00       	call   80106a97 <acquire>
801019ed:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019f0:	8b 45 08             	mov    0x8(%ebp),%eax
801019f3:	8b 40 08             	mov    0x8(%eax),%eax
801019f6:	8d 50 01             	lea    0x1(%eax),%edx
801019f9:	8b 45 08             	mov    0x8(%ebp),%eax
801019fc:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019ff:	83 ec 0c             	sub    $0xc,%esp
80101a02:	68 60 32 11 80       	push   $0x80113260
80101a07:	e8 f2 50 00 00       	call   80106afe <release>
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
80101a2d:	68 21 a3 10 80       	push   $0x8010a321
80101a32:	e8 2f eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a37:	83 ec 0c             	sub    $0xc,%esp
80101a3a:	68 60 32 11 80       	push   $0x80113260
80101a3f:	e8 53 50 00 00       	call   80106a97 <acquire>
80101a44:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a47:	eb 13                	jmp    80101a5c <ilock+0x48>
    sleep(ip, &icache.lock);
80101a49:	83 ec 08             	sub    $0x8,%esp
80101a4c:	68 60 32 11 80       	push   $0x80113260
80101a51:	ff 75 08             	pushl  0x8(%ebp)
80101a54:	e8 29 3d 00 00       	call   80105782 <sleep>
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
80101a7d:	68 60 32 11 80       	push   $0x80113260
80101a82:	e8 77 50 00 00       	call   80106afe <release>
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
80101aa6:	a1 54 32 11 80       	mov    0x80113254,%eax
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
80101b2f:	e8 85 52 00 00       	call   80106db9 <memmove>
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
80101b65:	68 27 a3 10 80       	push   $0x8010a327
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
80101b98:	68 36 a3 10 80       	push   $0x8010a336
80101b9d:	e8 c4 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101ba2:	83 ec 0c             	sub    $0xc,%esp
80101ba5:	68 60 32 11 80       	push   $0x80113260
80101baa:	e8 e8 4e 00 00       	call   80106a97 <acquire>
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
80101bc9:	e8 c4 3d 00 00       	call   80105992 <wakeup>
80101bce:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bd1:	83 ec 0c             	sub    $0xc,%esp
80101bd4:	68 60 32 11 80       	push   $0x80113260
80101bd9:	e8 20 4f 00 00       	call   80106afe <release>
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
80101bed:	68 60 32 11 80       	push   $0x80113260
80101bf2:	e8 a0 4e 00 00       	call   80106a97 <acquire>
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
80101c3a:	68 3e a3 10 80       	push   $0x8010a33e
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
80101c58:	68 60 32 11 80       	push   $0x80113260
80101c5d:	e8 9c 4e 00 00       	call   80106afe <release>
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
80101c8d:	68 60 32 11 80       	push   $0x80113260
80101c92:	e8 00 4e 00 00       	call   80106a97 <acquire>
80101c97:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ca4:	83 ec 0c             	sub    $0xc,%esp
80101ca7:	ff 75 08             	pushl  0x8(%ebp)
80101caa:	e8 e3 3c 00 00       	call   80105992 <wakeup>
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
80101cc4:	68 60 32 11 80       	push   $0x80113260
80101cc9:	e8 30 4e 00 00       	call   80106afe <release>
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
80101e09:	68 48 a3 10 80       	push   $0x8010a348
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
80101fb6:	8b 04 c5 e0 31 11 80 	mov    -0x7feece20(,%eax,8),%eax
80101fbd:	85 c0                	test   %eax,%eax
80101fbf:	75 0a                	jne    80101fcb <readi+0x49>
      return -1;
80101fc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fc6:	e9 0c 01 00 00       	jmp    801020d7 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd2:	98                   	cwtl   
80101fd3:	8b 04 c5 e0 31 11 80 	mov    -0x7feece20(,%eax,8),%eax
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
801020a0:	e8 14 4d 00 00       	call   80106db9 <memmove>
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
8010210d:	8b 04 c5 e4 31 11 80 	mov    -0x7feece1c(,%eax,8),%eax
80102114:	85 c0                	test   %eax,%eax
80102116:	75 0a                	jne    80102122 <writei+0x49>
      return -1;
80102118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010211d:	e9 3d 01 00 00       	jmp    8010225f <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102122:	8b 45 08             	mov    0x8(%ebp),%eax
80102125:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102129:	98                   	cwtl   
8010212a:	8b 04 c5 e4 31 11 80 	mov    -0x7feece1c(,%eax,8),%eax
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
801021f2:	e8 c2 4b 00 00       	call   80106db9 <memmove>
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
80102272:	e8 d8 4b 00 00       	call   80106e4f <strncmp>
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
80102292:	68 5b a3 10 80       	push   $0x8010a35b
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
801022c1:	68 6d a3 10 80       	push   $0x8010a36d
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
80102396:	68 6d a3 10 80       	push   $0x8010a36d
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
801023d1:	e8 cf 4a 00 00       	call   80106ea5 <strncpy>
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
801023fd:	68 7a a3 10 80       	push   $0x8010a37a
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
80102473:	e8 41 49 00 00       	call   80106db9 <memmove>
80102478:	83 c4 10             	add    $0x10,%esp
8010247b:	eb 26                	jmp    801024a3 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010247d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102480:	83 ec 04             	sub    $0x4,%esp
80102483:	50                   	push   %eax
80102484:	ff 75 f4             	pushl  -0xc(%ebp)
80102487:	ff 75 0c             	pushl  0xc(%ebp)
8010248a:	e8 2a 49 00 00       	call   80106db9 <memmove>
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
801026df:	68 82 a3 10 80       	push   $0x8010a382
801026e4:	68 20 d6 10 80       	push   $0x8010d620
801026e9:	e8 87 43 00 00       	call   80106a75 <initlock>
801026ee:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026f1:	83 ec 0c             	sub    $0xc,%esp
801026f4:	6a 0e                	push   $0xe
801026f6:	e8 da 18 00 00       	call   80103fd5 <picenable>
801026fb:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026fe:	a1 60 49 11 80       	mov    0x80114960,%eax
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
80102753:	c7 05 58 d6 10 80 01 	movl   $0x1,0x8010d658
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
80102793:	68 86 a3 10 80       	push   $0x8010a386
80102798:	e8 c9 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
8010279d:	8b 45 08             	mov    0x8(%ebp),%eax
801027a0:	8b 40 08             	mov    0x8(%eax),%eax
801027a3:	3d cf 07 00 00       	cmp    $0x7cf,%eax
801027a8:	76 0d                	jbe    801027b7 <idestart+0x33>
    panic("incorrect blockno");
801027aa:	83 ec 0c             	sub    $0xc,%esp
801027ad:	68 8f a3 10 80       	push   $0x8010a38f
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
801027d6:	68 86 a3 10 80       	push   $0x8010a386
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
801028eb:	68 20 d6 10 80       	push   $0x8010d620
801028f0:	e8 a2 41 00 00       	call   80106a97 <acquire>
801028f5:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028f8:	a1 54 d6 10 80       	mov    0x8010d654,%eax
801028fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102900:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102904:	75 15                	jne    8010291b <ideintr+0x39>
    release(&idelock);
80102906:	83 ec 0c             	sub    $0xc,%esp
80102909:	68 20 d6 10 80       	push   $0x8010d620
8010290e:	e8 eb 41 00 00       	call   80106afe <release>
80102913:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102916:	e9 9a 00 00 00       	jmp    801029b5 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010291b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291e:	8b 40 14             	mov    0x14(%eax),%eax
80102921:	a3 54 d6 10 80       	mov    %eax,0x8010d654

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
80102983:	e8 0a 30 00 00       	call   80105992 <wakeup>
80102988:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010298b:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102990:	85 c0                	test   %eax,%eax
80102992:	74 11                	je     801029a5 <ideintr+0xc3>
    idestart(idequeue);
80102994:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102999:	83 ec 0c             	sub    $0xc,%esp
8010299c:	50                   	push   %eax
8010299d:	e8 e2 fd ff ff       	call   80102784 <idestart>
801029a2:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	68 20 d6 10 80       	push   $0x8010d620
801029ad:	e8 4c 41 00 00       	call   80106afe <release>
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
801029cc:	68 a1 a3 10 80       	push   $0x8010a3a1
801029d1:	e8 90 db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029d6:	8b 45 08             	mov    0x8(%ebp),%eax
801029d9:	8b 00                	mov    (%eax),%eax
801029db:	83 e0 06             	and    $0x6,%eax
801029de:	83 f8 02             	cmp    $0x2,%eax
801029e1:	75 0d                	jne    801029f0 <iderw+0x39>
    panic("iderw: nothing to do");
801029e3:	83 ec 0c             	sub    $0xc,%esp
801029e6:	68 b5 a3 10 80       	push   $0x8010a3b5
801029eb:	e8 76 db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029f0:	8b 45 08             	mov    0x8(%ebp),%eax
801029f3:	8b 40 04             	mov    0x4(%eax),%eax
801029f6:	85 c0                	test   %eax,%eax
801029f8:	74 16                	je     80102a10 <iderw+0x59>
801029fa:	a1 58 d6 10 80       	mov    0x8010d658,%eax
801029ff:	85 c0                	test   %eax,%eax
80102a01:	75 0d                	jne    80102a10 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102a03:	83 ec 0c             	sub    $0xc,%esp
80102a06:	68 ca a3 10 80       	push   $0x8010a3ca
80102a0b:	e8 56 db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a10:	83 ec 0c             	sub    $0xc,%esp
80102a13:	68 20 d6 10 80       	push   $0x8010d620
80102a18:	e8 7a 40 00 00       	call   80106a97 <acquire>
80102a1d:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a20:	8b 45 08             	mov    0x8(%ebp),%eax
80102a23:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a2a:	c7 45 f4 54 d6 10 80 	movl   $0x8010d654,-0xc(%ebp)
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
80102a4f:	a1 54 d6 10 80       	mov    0x8010d654,%eax
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
80102a6c:	68 20 d6 10 80       	push   $0x8010d620
80102a71:	ff 75 08             	pushl  0x8(%ebp)
80102a74:	e8 09 2d 00 00       	call   80105782 <sleep>
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
80102a8c:	68 20 d6 10 80       	push   $0x8010d620
80102a91:	e8 68 40 00 00       	call   80106afe <release>
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
80102a9f:	a1 34 42 11 80       	mov    0x80114234,%eax
80102aa4:	8b 55 08             	mov    0x8(%ebp),%edx
80102aa7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102aa9:	a1 34 42 11 80       	mov    0x80114234,%eax
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
80102ab6:	a1 34 42 11 80       	mov    0x80114234,%eax
80102abb:	8b 55 08             	mov    0x8(%ebp),%edx
80102abe:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ac0:	a1 34 42 11 80       	mov    0x80114234,%eax
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
80102ad4:	a1 64 43 11 80       	mov    0x80114364,%eax
80102ad9:	85 c0                	test   %eax,%eax
80102adb:	0f 84 a0 00 00 00    	je     80102b81 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ae1:	c7 05 34 42 11 80 00 	movl   $0xfec00000,0x80114234
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
80102b10:	0f b6 05 60 43 11 80 	movzbl 0x80114360,%eax
80102b17:	0f b6 c0             	movzbl %al,%eax
80102b1a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b1d:	74 10                	je     80102b2f <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b1f:	83 ec 0c             	sub    $0xc,%esp
80102b22:	68 e8 a3 10 80       	push   $0x8010a3e8
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
80102b87:	a1 64 43 11 80       	mov    0x80114364,%eax
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
80102be2:	68 1a a4 10 80       	push   $0x8010a41a
80102be7:	68 40 42 11 80       	push   $0x80114240
80102bec:	e8 84 3e 00 00       	call   80106a75 <initlock>
80102bf1:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102bf4:	c7 05 74 42 11 80 00 	movl   $0x0,0x80114274
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
80102c29:	c7 05 74 42 11 80 01 	movl   $0x1,0x80114274
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
80102c85:	81 7d 08 3c 79 11 80 	cmpl   $0x8011793c,0x8(%ebp)
80102c8c:	72 12                	jb     80102ca0 <kfree+0x2d>
80102c8e:	ff 75 08             	pushl  0x8(%ebp)
80102c91:	e8 36 ff ff ff       	call   80102bcc <v2p>
80102c96:	83 c4 04             	add    $0x4,%esp
80102c99:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c9e:	76 0d                	jbe    80102cad <kfree+0x3a>
    panic("kfree");
80102ca0:	83 ec 0c             	sub    $0xc,%esp
80102ca3:	68 1f a4 10 80       	push   $0x8010a41f
80102ca8:	e8 b9 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cad:	83 ec 04             	sub    $0x4,%esp
80102cb0:	68 00 10 00 00       	push   $0x1000
80102cb5:	6a 01                	push   $0x1
80102cb7:	ff 75 08             	pushl  0x8(%ebp)
80102cba:	e8 3b 40 00 00       	call   80106cfa <memset>
80102cbf:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cc2:	a1 74 42 11 80       	mov    0x80114274,%eax
80102cc7:	85 c0                	test   %eax,%eax
80102cc9:	74 10                	je     80102cdb <kfree+0x68>
    acquire(&kmem.lock);
80102ccb:	83 ec 0c             	sub    $0xc,%esp
80102cce:	68 40 42 11 80       	push   $0x80114240
80102cd3:	e8 bf 3d 00 00       	call   80106a97 <acquire>
80102cd8:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ce1:	8b 15 78 42 11 80    	mov    0x80114278,%edx
80102ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cea:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cef:	a3 78 42 11 80       	mov    %eax,0x80114278
  if(kmem.use_lock)
80102cf4:	a1 74 42 11 80       	mov    0x80114274,%eax
80102cf9:	85 c0                	test   %eax,%eax
80102cfb:	74 10                	je     80102d0d <kfree+0x9a>
    release(&kmem.lock);
80102cfd:	83 ec 0c             	sub    $0xc,%esp
80102d00:	68 40 42 11 80       	push   $0x80114240
80102d05:	e8 f4 3d 00 00       	call   80106afe <release>
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
80102d16:	a1 74 42 11 80       	mov    0x80114274,%eax
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 10                	je     80102d2f <kalloc+0x1f>
    acquire(&kmem.lock);
80102d1f:	83 ec 0c             	sub    $0xc,%esp
80102d22:	68 40 42 11 80       	push   $0x80114240
80102d27:	e8 6b 3d 00 00       	call   80106a97 <acquire>
80102d2c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d2f:	a1 78 42 11 80       	mov    0x80114278,%eax
80102d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d3b:	74 0a                	je     80102d47 <kalloc+0x37>
    kmem.freelist = r->next;
80102d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d40:	8b 00                	mov    (%eax),%eax
80102d42:	a3 78 42 11 80       	mov    %eax,0x80114278
  if(kmem.use_lock)
80102d47:	a1 74 42 11 80       	mov    0x80114274,%eax
80102d4c:	85 c0                	test   %eax,%eax
80102d4e:	74 10                	je     80102d60 <kalloc+0x50>
    release(&kmem.lock);
80102d50:	83 ec 0c             	sub    $0xc,%esp
80102d53:	68 40 42 11 80       	push   $0x80114240
80102d58:	e8 a1 3d 00 00       	call   80106afe <release>
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
80102dc5:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102dca:	83 c8 40             	or     $0x40,%eax
80102dcd:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
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
80102de8:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
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
80102e05:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102e0a:	0f b6 00             	movzbl (%eax),%eax
80102e0d:	83 c8 40             	or     $0x40,%eax
80102e10:	0f b6 c0             	movzbl %al,%eax
80102e13:	f7 d0                	not    %eax
80102e15:	89 c2                	mov    %eax,%edx
80102e17:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e1c:	21 d0                	and    %edx,%eax
80102e1e:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
    return 0;
80102e23:	b8 00 00 00 00       	mov    $0x0,%eax
80102e28:	e9 a2 00 00 00       	jmp    80102ecf <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e2d:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e32:	83 e0 40             	and    $0x40,%eax
80102e35:	85 c0                	test   %eax,%eax
80102e37:	74 14                	je     80102e4d <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e39:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e40:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e45:	83 e0 bf             	and    $0xffffffbf,%eax
80102e48:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  }

  shift |= shiftcode[data];
80102e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e50:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102e55:	0f b6 00             	movzbl (%eax),%eax
80102e58:	0f b6 d0             	movzbl %al,%edx
80102e5b:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e60:	09 d0                	or     %edx,%eax
80102e62:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  shift ^= togglecode[data];
80102e67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e6a:	05 20 b1 10 80       	add    $0x8010b120,%eax
80102e6f:	0f b6 00             	movzbl (%eax),%eax
80102e72:	0f b6 d0             	movzbl %al,%edx
80102e75:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e7a:	31 d0                	xor    %edx,%eax
80102e7c:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e81:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102e86:	83 e0 03             	and    $0x3,%eax
80102e89:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80102e90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e93:	01 d0                	add    %edx,%eax
80102e95:	0f b6 00             	movzbl (%eax),%eax
80102e98:	0f b6 c0             	movzbl %al,%eax
80102e9b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e9e:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
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
80102f39:	a1 7c 42 11 80       	mov    0x8011427c,%eax
80102f3e:	8b 55 08             	mov    0x8(%ebp),%edx
80102f41:	c1 e2 02             	shl    $0x2,%edx
80102f44:	01 c2                	add    %eax,%edx
80102f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f49:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f4b:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
80102f5b:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
80102fce:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
80103050:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
8010308a:	a1 60 d6 10 80       	mov    0x8010d660,%eax
8010308f:	8d 50 01             	lea    0x1(%eax),%edx
80103092:	89 15 60 d6 10 80    	mov    %edx,0x8010d660
80103098:	85 c0                	test   %eax,%eax
8010309a:	75 14                	jne    801030b0 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010309c:	8b 45 04             	mov    0x4(%ebp),%eax
8010309f:	83 ec 08             	sub    $0x8,%esp
801030a2:	50                   	push   %eax
801030a3:	68 28 a4 10 80       	push   $0x8010a428
801030a8:	e8 19 d3 ff ff       	call   801003c6 <cprintf>
801030ad:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801030b0:	a1 7c 42 11 80       	mov    0x8011427c,%eax
801030b5:	85 c0                	test   %eax,%eax
801030b7:	74 0f                	je     801030c8 <cpunum+0x52>
    return lapic[ID]>>24;
801030b9:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
801030d2:	a1 7c 42 11 80       	mov    0x8011427c,%eax
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
801032ce:	e8 8e 3a 00 00       	call   80106d61 <memcmp>
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
801033e2:	68 54 a4 10 80       	push   $0x8010a454
801033e7:	68 80 42 11 80       	push   $0x80114280
801033ec:	e8 84 36 00 00       	call   80106a75 <initlock>
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
80103409:	a3 b4 42 11 80       	mov    %eax,0x801142b4
  log.size = sb.nlog;
8010340e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103411:	a3 b8 42 11 80       	mov    %eax,0x801142b8
  log.dev = dev;
80103416:	8b 45 08             	mov    0x8(%ebp),%eax
80103419:	a3 c4 42 11 80       	mov    %eax,0x801142c4
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
80103438:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
8010343e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103441:	01 d0                	add    %edx,%eax
80103443:	83 c0 01             	add    $0x1,%eax
80103446:	89 c2                	mov    %eax,%edx
80103448:	a1 c4 42 11 80       	mov    0x801142c4,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	52                   	push   %edx
80103451:	50                   	push   %eax
80103452:	e8 5f cd ff ff       	call   801001b6 <bread>
80103457:	83 c4 10             	add    $0x10,%esp
8010345a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010345d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103460:	83 c0 10             	add    $0x10,%eax
80103463:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
8010346a:	89 c2                	mov    %eax,%edx
8010346c:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
80103497:	e8 1d 39 00 00       	call   80106db9 <memmove>
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
801034cd:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801034e4:	a1 b4 42 11 80       	mov    0x801142b4,%eax
801034e9:	89 c2                	mov    %eax,%edx
801034eb:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
8010350e:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  for (i = 0; i < log.lh.n; i++) {
80103513:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010351a:	eb 1b                	jmp    80103537 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010351c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103522:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103526:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103529:	83 c2 10             	add    $0x10,%edx
8010352c:	89 04 95 8c 42 11 80 	mov    %eax,-0x7feebd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103533:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103537:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
80103558:	a1 b4 42 11 80       	mov    0x801142b4,%eax
8010355d:	89 c2                	mov    %eax,%edx
8010355f:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
8010357d:	8b 15 c8 42 11 80    	mov    0x801142c8,%edx
80103583:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103586:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103588:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010358f:	eb 1b                	jmp    801035ac <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103594:	83 c0 10             	add    $0x10,%eax
80103597:	8b 0c 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%ecx
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
801035ac:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801035e5:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
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
80103600:	68 80 42 11 80       	push   $0x80114280
80103605:	e8 8d 34 00 00       	call   80106a97 <acquire>
8010360a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010360d:	a1 c0 42 11 80       	mov    0x801142c0,%eax
80103612:	85 c0                	test   %eax,%eax
80103614:	74 17                	je     8010362d <begin_op+0x36>
      sleep(&log, &log.lock);
80103616:	83 ec 08             	sub    $0x8,%esp
80103619:	68 80 42 11 80       	push   $0x80114280
8010361e:	68 80 42 11 80       	push   $0x80114280
80103623:	e8 5a 21 00 00       	call   80105782 <sleep>
80103628:	83 c4 10             	add    $0x10,%esp
8010362b:	eb e0                	jmp    8010360d <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010362d:	8b 0d c8 42 11 80    	mov    0x801142c8,%ecx
80103633:	a1 bc 42 11 80       	mov    0x801142bc,%eax
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
8010364e:	68 80 42 11 80       	push   $0x80114280
80103653:	68 80 42 11 80       	push   $0x80114280
80103658:	e8 25 21 00 00       	call   80105782 <sleep>
8010365d:	83 c4 10             	add    $0x10,%esp
80103660:	eb ab                	jmp    8010360d <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103662:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103667:	83 c0 01             	add    $0x1,%eax
8010366a:	a3 bc 42 11 80       	mov    %eax,0x801142bc
      release(&log.lock);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	68 80 42 11 80       	push   $0x80114280
80103677:	e8 82 34 00 00       	call   80106afe <release>
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
80103693:	68 80 42 11 80       	push   $0x80114280
80103698:	e8 fa 33 00 00       	call   80106a97 <acquire>
8010369d:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801036a0:	a1 bc 42 11 80       	mov    0x801142bc,%eax
801036a5:	83 e8 01             	sub    $0x1,%eax
801036a8:	a3 bc 42 11 80       	mov    %eax,0x801142bc
  if(log.committing)
801036ad:	a1 c0 42 11 80       	mov    0x801142c0,%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	74 0d                	je     801036c3 <end_op+0x40>
    panic("log.committing");
801036b6:	83 ec 0c             	sub    $0xc,%esp
801036b9:	68 58 a4 10 80       	push   $0x8010a458
801036be:	e8 a3 ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036c3:	a1 bc 42 11 80       	mov    0x801142bc,%eax
801036c8:	85 c0                	test   %eax,%eax
801036ca:	75 13                	jne    801036df <end_op+0x5c>
    do_commit = 1;
801036cc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036d3:	c7 05 c0 42 11 80 01 	movl   $0x1,0x801142c0
801036da:	00 00 00 
801036dd:	eb 10                	jmp    801036ef <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036df:	83 ec 0c             	sub    $0xc,%esp
801036e2:	68 80 42 11 80       	push   $0x80114280
801036e7:	e8 a6 22 00 00       	call   80105992 <wakeup>
801036ec:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	68 80 42 11 80       	push   $0x80114280
801036f7:	e8 02 34 00 00       	call   80106afe <release>
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
8010370d:	68 80 42 11 80       	push   $0x80114280
80103712:	e8 80 33 00 00       	call   80106a97 <acquire>
80103717:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010371a:	c7 05 c0 42 11 80 00 	movl   $0x0,0x801142c0
80103721:	00 00 00 
    wakeup(&log);
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	68 80 42 11 80       	push   $0x80114280
8010372c:	e8 61 22 00 00       	call   80105992 <wakeup>
80103731:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103734:	83 ec 0c             	sub    $0xc,%esp
80103737:	68 80 42 11 80       	push   $0x80114280
8010373c:	e8 bd 33 00 00       	call   80106afe <release>
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
80103759:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
8010375f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103762:	01 d0                	add    %edx,%eax
80103764:	83 c0 01             	add    $0x1,%eax
80103767:	89 c2                	mov    %eax,%edx
80103769:	a1 c4 42 11 80       	mov    0x801142c4,%eax
8010376e:	83 ec 08             	sub    $0x8,%esp
80103771:	52                   	push   %edx
80103772:	50                   	push   %eax
80103773:	e8 3e ca ff ff       	call   801001b6 <bread>
80103778:	83 c4 10             	add    $0x10,%esp
8010377b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010377e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103781:	83 c0 10             	add    $0x10,%eax
80103784:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
8010378b:	89 c2                	mov    %eax,%edx
8010378d:	a1 c4 42 11 80       	mov    0x801142c4,%eax
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
801037b8:	e8 fc 35 00 00       	call   80106db9 <memmove>
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
801037ee:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
80103805:	a1 c8 42 11 80       	mov    0x801142c8,%eax
8010380a:	85 c0                	test   %eax,%eax
8010380c:	7e 1e                	jle    8010382c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010380e:	e8 34 ff ff ff       	call   80103747 <write_log>
    write_head();    // Write header to disk -- the real commit
80103813:	e8 3a fd ff ff       	call   80103552 <write_head>
    install_trans(); // Now install writes to home locations
80103818:	e8 09 fc ff ff       	call   80103426 <install_trans>
    log.lh.n = 0; 
8010381d:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
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
80103835:	a1 c8 42 11 80       	mov    0x801142c8,%eax
8010383a:	83 f8 1d             	cmp    $0x1d,%eax
8010383d:	7f 12                	jg     80103851 <log_write+0x22>
8010383f:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103844:	8b 15 b8 42 11 80    	mov    0x801142b8,%edx
8010384a:	83 ea 01             	sub    $0x1,%edx
8010384d:	39 d0                	cmp    %edx,%eax
8010384f:	7c 0d                	jl     8010385e <log_write+0x2f>
    panic("too big a transaction");
80103851:	83 ec 0c             	sub    $0xc,%esp
80103854:	68 67 a4 10 80       	push   $0x8010a467
80103859:	e8 08 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010385e:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103863:	85 c0                	test   %eax,%eax
80103865:	7f 0d                	jg     80103874 <log_write+0x45>
    panic("log_write outside of trans");
80103867:	83 ec 0c             	sub    $0xc,%esp
8010386a:	68 7d a4 10 80       	push   $0x8010a47d
8010386f:	e8 f2 cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103874:	83 ec 0c             	sub    $0xc,%esp
80103877:	68 80 42 11 80       	push   $0x80114280
8010387c:	e8 16 32 00 00       	call   80106a97 <acquire>
80103881:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103884:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010388b:	eb 1d                	jmp    801038aa <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010388d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103890:	83 c0 10             	add    $0x10,%eax
80103893:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
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
801038aa:	a1 c8 42 11 80       	mov    0x801142c8,%eax
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
801038c5:	89 14 85 8c 42 11 80 	mov    %edx,-0x7feebd74(,%eax,4)
  if (i == log.lh.n)
801038cc:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801038d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038d4:	75 0d                	jne    801038e3 <log_write+0xb4>
    log.lh.n++;
801038d6:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801038db:	83 c0 01             	add    $0x1,%eax
801038de:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  b->flags |= B_DIRTY; // prevent eviction
801038e3:	8b 45 08             	mov    0x8(%ebp),%eax
801038e6:	8b 00                	mov    (%eax),%eax
801038e8:	83 c8 04             	or     $0x4,%eax
801038eb:	89 c2                	mov    %eax,%edx
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038f2:	83 ec 0c             	sub    $0xc,%esp
801038f5:	68 80 42 11 80       	push   $0x80114280
801038fa:	e8 ff 31 00 00       	call   80106afe <release>
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
80103952:	68 3c 79 11 80       	push   $0x8011793c
80103957:	e8 7d f2 ff ff       	call   80102bd9 <kinit1>
8010395c:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010395f:	e8 03 61 00 00       	call   80109a67 <kvmalloc>
  mpinit();        // collect info about this machine
80103964:	e8 43 04 00 00       	call   80103dac <mpinit>
  lapicinit();
80103969:	e8 ea f5 ff ff       	call   80102f58 <lapicinit>
  seginit();       // set up segments
8010396e:	e8 9d 5a 00 00       	call   80109410 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103973:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103979:	0f b6 00             	movzbl (%eax),%eax
8010397c:	0f b6 c0             	movzbl %al,%eax
8010397f:	83 ec 08             	sub    $0x8,%esp
80103982:	50                   	push   %eax
80103983:	68 98 a4 10 80       	push   $0x8010a498
80103988:	e8 39 ca ff ff       	call   801003c6 <cprintf>
8010398d:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103990:	e8 6d 06 00 00       	call   80104002 <picinit>
  ioapicinit();    // another interrupt controller
80103995:	e8 34 f1 ff ff       	call   80102ace <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010399a:	e8 24 d2 ff ff       	call   80100bc3 <consoleinit>
  uartinit();      // serial port
8010399f:	e8 c8 4d 00 00       	call   8010876c <uartinit>
  pinit();         // process table
801039a4:	e8 d0 0d 00 00       	call   80104779 <pinit>
  tvinit();        // trap vectors
801039a9:	e8 97 49 00 00       	call   80108345 <tvinit>
  binit();         // buffer cache
801039ae:	e8 81 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039b3:	e8 67 d6 ff ff       	call   8010101f <fileinit>
  ideinit();       // disk
801039b8:	e8 19 ed ff ff       	call   801026d6 <ideinit>
  if(!ismp)
801039bd:	a1 64 43 11 80       	mov    0x80114364,%eax
801039c2:	85 c0                	test   %eax,%eax
801039c4:	75 05                	jne    801039cb <main+0x92>
    timerinit();   // uniprocessor timer
801039c6:	e8 cb 48 00 00       	call   80108296 <timerinit>
  startothers();   // start other processors
801039cb:	e8 7f 00 00 00       	call   80103a4f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039d0:	83 ec 08             	sub    $0x8,%esp
801039d3:	68 00 00 00 8e       	push   $0x8e000000
801039d8:	68 00 00 40 80       	push   $0x80400000
801039dd:	e8 30 f2 ff ff       	call   80102c12 <kinit2>
801039e2:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039e5:	e8 2a 0f 00 00       	call   80104914 <userinit>
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
801039f5:	e8 85 60 00 00       	call   80109a7f <switchkvm>
  seginit();
801039fa:	e8 11 5a 00 00       	call   80109410 <seginit>
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
80103a1f:	68 af a4 10 80       	push   $0x8010a4af
80103a24:	e8 9d c9 ff ff       	call   801003c6 <cprintf>
80103a29:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a2c:	e8 75 4a 00 00       	call   801084a6 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a31:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a37:	05 a8 00 00 00       	add    $0xa8,%eax
80103a3c:	83 ec 08             	sub    $0x8,%esp
80103a3f:	6a 01                	push   $0x1
80103a41:	50                   	push   %eax
80103a42:	e8 d8 fe ff ff       	call   8010391f <xchg>
80103a47:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a4a:	e8 c7 18 00 00       	call   80105316 <scheduler>

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
80103a6f:	68 2c d5 10 80       	push   $0x8010d52c
80103a74:	ff 75 f0             	pushl  -0x10(%ebp)
80103a77:	e8 3d 33 00 00       	call   80106db9 <memmove>
80103a7c:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a7f:	c7 45 f4 80 43 11 80 	movl   $0x80114380,-0xc(%ebp)
80103a86:	e9 90 00 00 00       	jmp    80103b1b <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a8b:	e8 e6 f5 ff ff       	call   80103076 <cpunum>
80103a90:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a96:	05 80 43 11 80       	add    $0x80114380,%eax
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
80103ace:	68 00 c0 10 80       	push   $0x8010c000
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
80103b1b:	a1 60 49 11 80       	mov    0x80114960,%eax
80103b20:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b26:	05 80 43 11 80       	add    $0x80114380,%eax
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
80103b86:	a1 64 d6 10 80       	mov    0x8010d664,%eax
80103b8b:	89 c2                	mov    %eax,%edx
80103b8d:	b8 80 43 11 80       	mov    $0x80114380,%eax
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
80103c05:	68 c0 a4 10 80       	push   $0x8010a4c0
80103c0a:	ff 75 f4             	pushl  -0xc(%ebp)
80103c0d:	e8 4f 31 00 00       	call   80106d61 <memcmp>
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
80103d43:	68 c5 a4 10 80       	push   $0x8010a4c5
80103d48:	ff 75 f0             	pushl  -0x10(%ebp)
80103d4b:	e8 11 30 00 00       	call   80106d61 <memcmp>
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
80103db2:	c7 05 64 d6 10 80 80 	movl   $0x80114380,0x8010d664
80103db9:	43 11 80 
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
80103dd8:	c7 05 64 43 11 80 01 	movl   $0x1,0x80114364
80103ddf:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de5:	8b 40 24             	mov    0x24(%eax),%eax
80103de8:	a3 7c 42 11 80       	mov    %eax,0x8011427c
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
80103e1f:	8b 04 85 08 a5 10 80 	mov    -0x7fef5af8(,%eax,4),%eax
80103e26:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e31:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e35:	0f b6 d0             	movzbl %al,%edx
80103e38:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e3d:	39 c2                	cmp    %eax,%edx
80103e3f:	74 2b                	je     80103e6c <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e44:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e48:	0f b6 d0             	movzbl %al,%edx
80103e4b:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e50:	83 ec 04             	sub    $0x4,%esp
80103e53:	52                   	push   %edx
80103e54:	50                   	push   %eax
80103e55:	68 ca a4 10 80       	push   $0x8010a4ca
80103e5a:	e8 67 c5 ff ff       	call   801003c6 <cprintf>
80103e5f:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e62:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
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
80103e7d:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e82:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e88:	05 80 43 11 80       	add    $0x80114380,%eax
80103e8d:	a3 64 d6 10 80       	mov    %eax,0x8010d664
      cpus[ncpu].id = ncpu;
80103e92:	a1 60 49 11 80       	mov    0x80114960,%eax
80103e97:	8b 15 60 49 11 80    	mov    0x80114960,%edx
80103e9d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ea3:	05 80 43 11 80       	add    $0x80114380,%eax
80103ea8:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103eaa:	a1 60 49 11 80       	mov    0x80114960,%eax
80103eaf:	83 c0 01             	add    $0x1,%eax
80103eb2:	a3 60 49 11 80       	mov    %eax,0x80114960
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
80103eca:	a2 60 43 11 80       	mov    %al,0x80114360
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
80103ee8:	68 e8 a4 10 80       	push   $0x8010a4e8
80103eed:	e8 d4 c4 ff ff       	call   801003c6 <cprintf>
80103ef2:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103ef5:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
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
80103f0b:	a1 64 43 11 80       	mov    0x80114364,%eax
80103f10:	85 c0                	test   %eax,%eax
80103f12:	75 1d                	jne    80103f31 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f14:	c7 05 60 49 11 80 01 	movl   $0x1,0x80114960
80103f1b:	00 00 00 
    lapic = 0;
80103f1e:	c7 05 7c 42 11 80 00 	movl   $0x0,0x8011427c
80103f25:	00 00 00 
    ioapicid = 0;
80103f28:	c6 05 60 43 11 80 00 	movb   $0x0,0x80114360
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
80103fa1:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
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
80103fea:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
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
801040c8:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801040cf:	66 83 f8 ff          	cmp    $0xffff,%ax
801040d3:	74 13                	je     801040e8 <picinit+0xe6>
    picsetmask(irqmask);
801040d5:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
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
80104189:	68 1c a5 10 80       	push   $0x8010a51c
8010418e:	50                   	push   %eax
8010418f:	e8 e1 28 00 00       	call   80106a75 <initlock>
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
8010424b:	e8 47 28 00 00       	call   80106a97 <acquire>
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
80104272:	e8 1b 17 00 00       	call   80105992 <wakeup>
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
80104295:	e8 f8 16 00 00       	call   80105992 <wakeup>
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
801042be:	e8 3b 28 00 00       	call   80106afe <release>
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
801042dd:	e8 1c 28 00 00       	call   80106afe <release>
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
801042f5:	e8 9d 27 00 00       	call   80106a97 <acquire>
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
8010432a:	e8 cf 27 00 00       	call   80106afe <release>
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
80104348:	e8 45 16 00 00       	call   80105992 <wakeup>
8010434d:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104350:	8b 45 08             	mov    0x8(%ebp),%eax
80104353:	8b 55 08             	mov    0x8(%ebp),%edx
80104356:	81 c2 38 02 00 00    	add    $0x238,%edx
8010435c:	83 ec 08             	sub    $0x8,%esp
8010435f:	50                   	push   %eax
80104360:	52                   	push   %edx
80104361:	e8 1c 14 00 00       	call   80105782 <sleep>
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
801043ca:	e8 c3 15 00 00       	call   80105992 <wakeup>
801043cf:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043d2:	8b 45 08             	mov    0x8(%ebp),%eax
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	50                   	push   %eax
801043d9:	e8 20 27 00 00       	call   80106afe <release>
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
801043f4:	e8 9e 26 00 00       	call   80106a97 <acquire>
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
80104412:	e8 e7 26 00 00       	call   80106afe <release>
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
80104435:	e8 48 13 00 00       	call   80105782 <sleep>
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
801044c9:	e8 c4 14 00 00       	call   80105992 <wakeup>
801044ce:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044d1:	8b 45 08             	mov    0x8(%ebp),%eax
801044d4:	83 ec 0c             	sub    $0xc,%esp
801044d7:	50                   	push   %eax
801044d8:	e8 21 26 00 00       	call   80106afe <release>
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

#ifdef CS333_P3P4
//Helper functions

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
80104512:	68 24 a5 10 80       	push   $0x8010a524
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
80104533:	68 43 a5 10 80       	push   $0x8010a543
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
80104554:	68 61 a5 10 80       	push   $0x8010a561
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
80104575:	68 80 a5 10 80       	push   $0x8010a580
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
80104596:	68 a0 a5 10 80       	push   $0x8010a5a0
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
801045b7:	68 c0 a5 10 80       	push   $0x8010a5c0
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
801045c7:	83 ec 18             	sub    $0x18,%esp
    if(!holding(&ptable.lock)){
801045ca:	83 ec 0c             	sub    $0xc,%esp
801045cd:	68 80 49 11 80       	push   $0x80114980
801045d2:	e8 f3 25 00 00       	call   80106bca <holding>
801045d7:	83 c4 10             	add    $0x10,%esp
801045da:	85 c0                	test   %eax,%eax
801045dc:	75 0d                	jne    801045eb <addToStateListEnd+0x27>
	panic("Not holding the lock!");
801045de:	83 ec 0c             	sub    $0xc,%esp
801045e1:	68 e0 a5 10 80       	push   $0x8010a5e0
801045e6:	e8 7b bf ff ff       	call   80100566 <panic>
    }

    struct proc *current = *sList;
801045eb:	8b 45 08             	mov    0x8(%ebp),%eax
801045ee:	8b 00                	mov    (%eax),%eax
801045f0:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(!current){
801045f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045f7:	75 28                	jne    80104621 <addToStateListEnd+0x5d>
	*sList = p;
801045f9:	8b 45 08             	mov    0x8(%ebp),%eax
801045fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801045ff:	89 10                	mov    %edx,(%eax)
	p -> next = 0;
80104601:	8b 45 0c             	mov    0xc(%ebp),%eax
80104604:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010460b:	00 00 00 
	return 0;
8010460e:	b8 00 00 00 00       	mov    $0x0,%eax
80104613:	eb 37                	jmp    8010464c <addToStateListEnd+0x88>
    }
    while(current -> next)
	current = current -> next;
80104615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104618:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010461e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!current){
	*sList = p;
	p -> next = 0;
	return 0;
    }
    while(current -> next)
80104621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104624:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010462a:	85 c0                	test   %eax,%eax
8010462c:	75 e7                	jne    80104615 <addToStateListEnd+0x51>
	current = current -> next;
    
    current -> next = p;
8010462e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104631:	8b 55 0c             	mov    0xc(%ebp),%edx
80104634:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)

    p -> next = 0;
8010463a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010463d:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104644:	00 00 00 

    return 0;
80104647:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010464c:	c9                   	leave  
8010464d:	c3                   	ret    

8010464e <removeFromStateListHead>:

static int
removeFromStateListHead(struct proc** sList, struct proc* p){
8010464e:	55                   	push   %ebp
8010464f:	89 e5                	mov    %esp,%ebp
80104651:	83 ec 18             	sub    $0x18,%esp
    if(!holding(&ptable.lock)){
80104654:	83 ec 0c             	sub    $0xc,%esp
80104657:	68 80 49 11 80       	push   $0x80114980
8010465c:	e8 69 25 00 00       	call   80106bca <holding>
80104661:	83 c4 10             	add    $0x10,%esp
80104664:	85 c0                	test   %eax,%eax
80104666:	75 0d                	jne    80104675 <removeFromStateListHead+0x27>
	panic("Not holding the lock!");
80104668:	83 ec 0c             	sub    $0xc,%esp
8010466b:	68 e0 a5 10 80       	push   $0x8010a5e0
80104670:	e8 f1 be ff ff       	call   80100566 <panic>
    }

    if(!sList){
80104675:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104679:	75 07                	jne    80104682 <removeFromStateListHead+0x34>
	return -1;
8010467b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104680:	eb 28                	jmp    801046aa <removeFromStateListHead+0x5c>
    }
    
    struct proc* head = *sList;
80104682:	8b 45 08             	mov    0x8(%ebp),%eax
80104685:	8b 00                	mov    (%eax),%eax
80104687:	89 45 f4             	mov    %eax,-0xc(%ebp)

    *sList = head -> next;
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104693:	8b 45 08             	mov    0x8(%ebp),%eax
80104696:	89 10                	mov    %edx,(%eax)
    p -> next = 0;
80104698:	8b 45 0c             	mov    0xc(%ebp),%eax
8010469b:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801046a2:	00 00 00 

    return 0;
801046a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046aa:	c9                   	leave  
801046ab:	c3                   	ret    

801046ac <removeFromStateList>:

static int
removeFromStateList(struct proc** sList, struct proc* p){
801046ac:	55                   	push   %ebp
801046ad:	89 e5                	mov    %esp,%ebp
801046af:	83 ec 18             	sub    $0x18,%esp
    
    if(!holding(&ptable.lock)){
801046b2:	83 ec 0c             	sub    $0xc,%esp
801046b5:	68 80 49 11 80       	push   $0x80114980
801046ba:	e8 0b 25 00 00       	call   80106bca <holding>
801046bf:	83 c4 10             	add    $0x10,%esp
801046c2:	85 c0                	test   %eax,%eax
801046c4:	75 0d                	jne    801046d3 <removeFromStateList+0x27>
	panic("Not holding the lock!");
801046c6:	83 ec 0c             	sub    $0xc,%esp
801046c9:	68 e0 a5 10 80       	push   $0x8010a5e0
801046ce:	e8 93 be ff ff       	call   80100566 <panic>
    }
    struct proc *current = *sList;
801046d3:	8b 45 08             	mov    0x8(%ebp),%eax
801046d6:	8b 00                	mov    (%eax),%eax
801046d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc *previous = *sList;
801046db:	8b 45 08             	mov    0x8(%ebp),%eax
801046de:	8b 00                	mov    (%eax),%eax
801046e0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if(*sList == 0)
801046e3:	8b 45 08             	mov    0x8(%ebp),%eax
801046e6:	8b 00                	mov    (%eax),%eax
801046e8:	85 c0                	test   %eax,%eax
801046ea:	75 0a                	jne    801046f6 <removeFromStateList+0x4a>
	return -1;
801046ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f1:	e9 81 00 00 00       	jmp    80104777 <removeFromStateList+0xcb>

    if(*sList == p){
801046f6:	8b 45 08             	mov    0x8(%ebp),%eax
801046f9:	8b 00                	mov    (%eax),%eax
801046fb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801046fe:	75 36                	jne    80104736 <removeFromStateList+0x8a>
	*sList = (*sList) -> next;
80104700:	8b 45 08             	mov    0x8(%ebp),%eax
80104703:	8b 00                	mov    (%eax),%eax
80104705:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
8010470b:	8b 45 08             	mov    0x8(%ebp),%eax
8010470e:	89 10                	mov    %edx,(%eax)
	p -> next = 0;
80104710:	8b 45 0c             	mov    0xc(%ebp),%eax
80104713:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010471a:	00 00 00 
	return 0;
8010471d:	b8 00 00 00 00       	mov    $0x0,%eax
80104722:	eb 53                	jmp    80104777 <removeFromStateList+0xcb>
    }
    while(current != 0 && current != p) {
	previous = current;
80104724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104727:	89 45 f0             	mov    %eax,-0x10(%ebp)
	current = current -> next;
8010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104733:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(*sList == p){
	*sList = (*sList) -> next;
	p -> next = 0;
	return 0;
    }
    while(current != 0 && current != p) {
80104736:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010473a:	74 08                	je     80104744 <removeFromStateList+0x98>
8010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104742:	75 e0                	jne    80104724 <removeFromStateList+0x78>
	previous = current;
	current = current -> next;
    }

    if(current == p){
80104744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104747:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010474a:	75 26                	jne    80104772 <removeFromStateList+0xc6>
	previous -> next = current -> next;
8010474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474f:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104758:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	p -> next = 0;
8010475e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104761:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104768:	00 00 00 
    }
    else
	return -1;

    return 0;
8010476b:	b8 00 00 00 00       	mov    $0x0,%eax
80104770:	eb 05                	jmp    80104777 <removeFromStateList+0xcb>
    if(current == p){
	previous -> next = current -> next;
	p -> next = 0;
    }
    else
	return -1;
80104772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

    return 0;

    
}
80104777:	c9                   	leave  
80104778:	c3                   	ret    

80104779 <pinit>:

#endif

void
pinit(void)
{
80104779:	55                   	push   %ebp
8010477a:	89 e5                	mov    %esp,%ebp
8010477c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010477f:	83 ec 08             	sub    $0x8,%esp
80104782:	68 f6 a5 10 80       	push   $0x8010a5f6
80104787:	68 80 49 11 80       	push   $0x80114980
8010478c:	e8 e4 22 00 00       	call   80106a75 <initlock>
80104791:	83 c4 10             	add    $0x10,%esp
}
80104794:	90                   	nop
80104795:	c9                   	leave  
80104796:	c3                   	ret    

80104797 <allocproc>:
}

#else
static struct proc*
allocproc(void)
{
80104797:	55                   	push   %ebp
80104798:	89 e5                	mov    %esp,%ebp
8010479a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010479d:	83 ec 0c             	sub    $0xc,%esp
801047a0:	68 80 49 11 80       	push   $0x80114980
801047a5:	e8 ed 22 00 00       	call   80106a97 <acquire>
801047aa:	83 c4 10             	add    $0x10,%esp

  p = ptable.pLists.free;
801047ad:	a1 c8 70 11 80       	mov    0x801170c8,%eax
801047b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p){
801047b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047b9:	75 1a                	jne    801047d5 <allocproc+0x3e>
    release(&ptable.lock);
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	68 80 49 11 80       	push   $0x80114980
801047c3:	e8 36 23 00 00       	call   80106afe <release>
801047c8:	83 c4 10             	add    $0x10,%esp
    return 0;
801047cb:	b8 00 00 00 00       	mov    $0x0,%eax
801047d0:	e9 3d 01 00 00       	jmp    80104912 <allocproc+0x17b>
  }

  assertStateFree(p);
801047d5:	83 ec 0c             	sub    $0xc,%esp
801047d8:	ff 75 f4             	pushl  -0xc(%ebp)
801047db:	e8 1f fd ff ff       	call   801044ff <assertStateFree>
801047e0:	83 c4 10             	add    $0x10,%esp

  removeFromStateListHead(&ptable.pLists.free, p);
801047e3:	83 ec 08             	sub    $0x8,%esp
801047e6:	ff 75 f4             	pushl  -0xc(%ebp)
801047e9:	68 c8 70 11 80       	push   $0x801170c8
801047ee:	e8 5b fe ff ff       	call   8010464e <removeFromStateListHead>
801047f3:	83 c4 10             	add    $0x10,%esp

  p->state = EMBRYO;
801047f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f9:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  addToStateListEnd(&ptable.pLists.embryo, p);
80104800:	83 ec 08             	sub    $0x8,%esp
80104803:	ff 75 f4             	pushl  -0xc(%ebp)
80104806:	68 d8 70 11 80       	push   $0x801170d8
8010480b:	e8 b4 fd ff ff       	call   801045c4 <addToStateListEnd>
80104810:	83 c4 10             	add    $0x10,%esp

  p->pid = nextpid++;
80104813:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104818:	8d 50 01             	lea    0x1(%eax),%edx
8010481b:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104821:	89 c2                	mov    %eax,%edx
80104823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104826:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
80104829:	83 ec 0c             	sub    $0xc,%esp
8010482c:	68 80 49 11 80       	push   $0x80114980
80104831:	e8 c8 22 00 00       	call   80106afe <release>
80104836:	83 c4 10             	add    $0x10,%esp
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104839:	e8 d2 e4 ff ff       	call   80102d10 <kalloc>
8010483e:	89 c2                	mov    %eax,%edx
80104840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104843:	89 50 08             	mov    %edx,0x8(%eax)
80104846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104849:	8b 40 08             	mov    0x8(%eax),%eax
8010484c:	85 c0                	test   %eax,%eax
8010484e:	75 65                	jne    801048b5 <allocproc+0x11e>

  acquire(&ptable.lock);
80104850:	83 ec 0c             	sub    $0xc,%esp
80104853:	68 80 49 11 80       	push   $0x80114980
80104858:	e8 3a 22 00 00       	call   80106a97 <acquire>
8010485d:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104860:	83 ec 0c             	sub    $0xc,%esp
80104863:	ff 75 f4             	pushl  -0xc(%ebp)
80104866:	e8 d5 fc ff ff       	call   80104540 <assertStateEmbryo>
8010486b:	83 c4 10             	add    $0x10,%esp
  removeFromStateListHead(&ptable.pLists.embryo, p);
8010486e:	83 ec 08             	sub    $0x8,%esp
80104871:	ff 75 f4             	pushl  -0xc(%ebp)
80104874:	68 d8 70 11 80       	push   $0x801170d8
80104879:	e8 d0 fd ff ff       	call   8010464e <removeFromStateListHead>
8010487e:	83 c4 10             	add    $0x10,%esp

  p->state = UNUSED;
80104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104884:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  addToStateListEnd(&ptable.pLists.free, p);
8010488b:	83 ec 08             	sub    $0x8,%esp
8010488e:	ff 75 f4             	pushl  -0xc(%ebp)
80104891:	68 c8 70 11 80       	push   $0x801170c8
80104896:	e8 29 fd ff ff       	call   801045c4 <addToStateListEnd>
8010489b:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
8010489e:	83 ec 0c             	sub    $0xc,%esp
801048a1:	68 80 49 11 80       	push   $0x80114980
801048a6:	e8 53 22 00 00       	call   80106afe <release>
801048ab:	83 c4 10             	add    $0x10,%esp

    return 0;
801048ae:	b8 00 00 00 00       	mov    $0x0,%eax
801048b3:	eb 5d                	jmp    80104912 <allocproc+0x17b>
  }
  sp = p->kstack + KSTACKSIZE;
801048b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b8:	8b 40 08             	mov    0x8(%eax),%eax
801048bb:	05 00 10 00 00       	add    $0x1000,%eax
801048c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801048c3:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048cd:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801048d0:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801048d4:	ba f3 82 10 80       	mov    $0x801082f3,%edx
801048d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048dc:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801048de:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801048e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048e8:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801048eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801048f1:	83 ec 04             	sub    $0x4,%esp
801048f4:	6a 14                	push   $0x14
801048f6:	6a 00                	push   $0x0
801048f8:	50                   	push   %eax
801048f9:	e8 fc 23 00 00       	call   80106cfa <memset>
801048fe:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104904:	8b 40 1c             	mov    0x1c(%eax),%eax
80104907:	ba 3c 57 10 80       	mov    $0x8010573c,%edx
8010490c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010490f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104912:	c9                   	leave  
80104913:	c3                   	ret    

80104914 <userinit>:
// Return 0 on success, -1 on failure.

#else
void
userinit(void)
{
80104914:	55                   	push   %ebp
80104915:	89 e5                	mov    %esp,%ebp
80104917:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  for(int i = 0; i < MAX+1; ++i)
8010491a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104921:	eb 17                	jmp    8010493a <userinit+0x26>
    ptable.pLists.ready[i] = 0;
80104923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104926:	05 cc 09 00 00       	add    $0x9cc,%eax
8010492b:	c7 04 85 84 49 11 80 	movl   $0x0,-0x7feeb67c(,%eax,4)
80104932:	00 00 00 00 
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  for(int i = 0; i < MAX+1; ++i)
80104936:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010493a:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010493e:	7e e3                	jle    80104923 <userinit+0xf>
    ptable.pLists.ready[i] = 0;

  ptable.pLists.free = 0;
80104940:	c7 05 c8 70 11 80 00 	movl   $0x0,0x801170c8
80104947:	00 00 00 
  ptable.pLists.sleep = 0;
8010494a:	c7 05 cc 70 11 80 00 	movl   $0x0,0x801170cc
80104951:	00 00 00 
  ptable.pLists.zombie = 0;
80104954:	c7 05 d0 70 11 80 00 	movl   $0x0,0x801170d0
8010495b:	00 00 00 
  ptable.pLists.running = 0;
8010495e:	c7 05 d4 70 11 80 00 	movl   $0x0,0x801170d4
80104965:	00 00 00 
  ptable.pLists.embryo = 0;
80104968:	c7 05 d8 70 11 80 00 	movl   $0x0,0x801170d8
8010496f:	00 00 00 

  acquire(&ptable.lock);
80104972:	83 ec 0c             	sub    $0xc,%esp
80104975:	68 80 49 11 80       	push   $0x80114980
8010497a:	e8 18 21 00 00       	call   80106a97 <acquire>
8010497f:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < NPROC; i++){
80104982:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104989:	eb 51                	jmp    801049dc <userinit+0xc8>
    addToStateListEnd(&ptable.pLists.free, &ptable.proc[i]);
8010498b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498e:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104994:	83 c0 30             	add    $0x30,%eax
80104997:	05 80 49 11 80       	add    $0x80114980,%eax
8010499c:	83 c0 04             	add    $0x4,%eax
8010499f:	83 ec 08             	sub    $0x8,%esp
801049a2:	50                   	push   %eax
801049a3:	68 c8 70 11 80       	push   $0x801170c8
801049a8:	e8 17 fc ff ff       	call   801045c4 <addToStateListEnd>
801049ad:	83 c4 10             	add    $0x10,%esp
    ptable.proc[i].priority = 0;
801049b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b3:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
801049b9:	05 48 4a 11 80       	add    $0x80114a48,%eax
801049be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    ptable.proc[i].budget = BUDGET;
801049c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c7:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
801049cd:	05 4c 4a 11 80       	add    $0x80114a4c,%eax
801049d2:	c7 00 88 13 00 00    	movl   $0x1388,(%eax)
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  acquire(&ptable.lock);
  for(int i = 0; i < NPROC; i++){
801049d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049dc:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801049e0:	7e a9                	jle    8010498b <userinit+0x77>
    addToStateListEnd(&ptable.pLists.free, &ptable.proc[i]);
    ptable.proc[i].priority = 0;
    ptable.proc[i].budget = BUDGET;
  }
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
801049e2:	a1 e0 78 11 80       	mov    0x801178e0,%eax
801049e7:	05 88 13 00 00       	add    $0x1388,%eax
801049ec:	a3 dc 70 11 80       	mov    %eax,0x801170dc

  release(&ptable.lock);
801049f1:	83 ec 0c             	sub    $0xc,%esp
801049f4:	68 80 49 11 80       	push   $0x80114980
801049f9:	e8 00 21 00 00       	call   80106afe <release>
801049fe:	83 c4 10             	add    $0x10,%esp


  p = allocproc();
80104a01:	e8 91 fd ff ff       	call   80104797 <allocproc>
80104a06:	89 45 ec             	mov    %eax,-0x14(%ebp)

  initproc = p;
80104a09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a0c:	a3 68 d6 10 80       	mov    %eax,0x8010d668
  if((p->pgdir = setupkvm()) == 0)
80104a11:	e8 9f 4f 00 00       	call   801099b5 <setupkvm>
80104a16:	89 c2                	mov    %eax,%edx
80104a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1b:	89 50 04             	mov    %edx,0x4(%eax)
80104a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a21:	8b 40 04             	mov    0x4(%eax),%eax
80104a24:	85 c0                	test   %eax,%eax
80104a26:	75 0d                	jne    80104a35 <userinit+0x121>
    panic("userinit: out of memory?");
80104a28:	83 ec 0c             	sub    $0xc,%esp
80104a2b:	68 fd a5 10 80       	push   $0x8010a5fd
80104a30:	e8 31 bb ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104a35:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a3d:	8b 40 04             	mov    0x4(%eax),%eax
80104a40:	83 ec 04             	sub    $0x4,%esp
80104a43:	52                   	push   %edx
80104a44:	68 00 d5 10 80       	push   $0x8010d500
80104a49:	50                   	push   %eax
80104a4a:	e8 c0 51 00 00       	call   80109c0f <inituvm>
80104a4f:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104a52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a55:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a5e:	8b 40 18             	mov    0x18(%eax),%eax
80104a61:	83 ec 04             	sub    $0x4,%esp
80104a64:	6a 4c                	push   $0x4c
80104a66:	6a 00                	push   $0x0
80104a68:	50                   	push   %eax
80104a69:	e8 8c 22 00 00       	call   80106cfa <memset>
80104a6e:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a74:	8b 40 18             	mov    0x18(%eax),%eax
80104a77:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a80:	8b 40 18             	mov    0x18(%eax),%eax
80104a83:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8c:	8b 40 18             	mov    0x18(%eax),%eax
80104a8f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104a92:	8b 52 18             	mov    0x18(%edx),%edx
80104a95:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104a99:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104a9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa0:	8b 40 18             	mov    0x18(%eax),%eax
80104aa3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104aa6:	8b 52 18             	mov    0x18(%edx),%edx
80104aa9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104aad:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104ab1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab4:	8b 40 18             	mov    0x18(%eax),%eax
80104ab7:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104abe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac1:	8b 40 18             	mov    0x18(%eax),%eax
80104ac4:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ace:	8b 40 18             	mov    0x18(%eax),%eax
80104ad1:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104adb:	83 c0 6c             	add    $0x6c,%eax
80104ade:	83 ec 04             	sub    $0x4,%esp
80104ae1:	6a 10                	push   $0x10
80104ae3:	68 16 a6 10 80       	push   $0x8010a616
80104ae8:	50                   	push   %eax
80104ae9:	e8 0f 24 00 00       	call   80106efd <safestrcpy>
80104aee:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	68 1f a6 10 80       	push   $0x8010a61f
80104af9:	e8 d4 da ff ff       	call   801025d2 <namei>
80104afe:	83 c4 10             	add    $0x10,%esp
80104b01:	89 c2                	mov    %eax,%edx
80104b03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b06:	89 50 68             	mov    %edx,0x68(%eax)

  acquire(&ptable.lock);
80104b09:	83 ec 0c             	sub    $0xc,%esp
80104b0c:	68 80 49 11 80       	push   $0x80114980
80104b11:	e8 81 1f 00 00       	call   80106a97 <acquire>
80104b16:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	ff 75 ec             	pushl  -0x14(%ebp)
80104b1f:	e8 1c fa ff ff       	call   80104540 <assertStateEmbryo>
80104b24:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.embryo, p);
80104b27:	83 ec 08             	sub    $0x8,%esp
80104b2a:	ff 75 ec             	pushl  -0x14(%ebp)
80104b2d:	68 d8 70 11 80       	push   $0x801170d8
80104b32:	e8 75 fb ff ff       	call   801046ac <removeFromStateList>
80104b37:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNABLE;
80104b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b3d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[0], p);
80104b44:	83 ec 08             	sub    $0x8,%esp
80104b47:	ff 75 ec             	pushl  -0x14(%ebp)
80104b4a:	68 b4 70 11 80       	push   $0x801170b4
80104b4f:	e8 70 fa ff ff       	call   801045c4 <addToStateListEnd>
80104b54:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104b57:	83 ec 0c             	sub    $0xc,%esp
80104b5a:	68 80 49 11 80       	push   $0x80114980
80104b5f:	e8 9a 1f 00 00       	call   80106afe <release>
80104b64:	83 c4 10             	add    $0x10,%esp


}
80104b67:	90                   	nop
80104b68:	c9                   	leave  
80104b69:	c3                   	ret    

80104b6a <growproc>:
#endif
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104b6a:	55                   	push   %ebp
80104b6b:	89 e5                	mov    %esp,%ebp
80104b6d:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104b70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b76:	8b 00                	mov    (%eax),%eax
80104b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104b7b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b7f:	7e 31                	jle    80104bb2 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104b81:	8b 55 08             	mov    0x8(%ebp),%edx
80104b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b87:	01 c2                	add    %eax,%edx
80104b89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8f:	8b 40 04             	mov    0x4(%eax),%eax
80104b92:	83 ec 04             	sub    $0x4,%esp
80104b95:	52                   	push   %edx
80104b96:	ff 75 f4             	pushl  -0xc(%ebp)
80104b99:	50                   	push   %eax
80104b9a:	e8 bd 51 00 00       	call   80109d5c <allocuvm>
80104b9f:	83 c4 10             	add    $0x10,%esp
80104ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ba5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ba9:	75 3e                	jne    80104be9 <growproc+0x7f>
      return -1;
80104bab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb0:	eb 59                	jmp    80104c0b <growproc+0xa1>
  } else if(n < 0){
80104bb2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104bb6:	79 31                	jns    80104be9 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104bb8:	8b 55 08             	mov    0x8(%ebp),%edx
80104bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbe:	01 c2                	add    %eax,%edx
80104bc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc6:	8b 40 04             	mov    0x4(%eax),%eax
80104bc9:	83 ec 04             	sub    $0x4,%esp
80104bcc:	52                   	push   %edx
80104bcd:	ff 75 f4             	pushl  -0xc(%ebp)
80104bd0:	50                   	push   %eax
80104bd1:	e8 4f 52 00 00       	call   80109e25 <deallocuvm>
80104bd6:	83 c4 10             	add    $0x10,%esp
80104bd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bdc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104be0:	75 07                	jne    80104be9 <growproc+0x7f>
      return -1;
80104be2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104be7:	eb 22                	jmp    80104c0b <growproc+0xa1>
  }
  proc->sz = sz;
80104be9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bf2:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104bf4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bfa:	83 ec 0c             	sub    $0xc,%esp
80104bfd:	50                   	push   %eax
80104bfe:	e8 99 4e 00 00       	call   80109a9c <switchuvm>
80104c03:	83 c4 10             	add    $0x10,%esp
  return 0;
80104c06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c0b:	c9                   	leave  
80104c0c:	c3                   	ret    

80104c0d <fork>:

#else

int
fork(void)
{
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
80104c10:	57                   	push   %edi
80104c11:	56                   	push   %esi
80104c12:	53                   	push   %ebx
80104c13:	83 ec 1c             	sub    $0x1c,%esp

  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104c16:	e8 7c fb ff ff       	call   80104797 <allocproc>
80104c1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104c1e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104c22:	75 0a                	jne    80104c2e <fork+0x21>
    return -1;
80104c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c29:	e9 09 02 00 00       	jmp    80104e37 <fork+0x22a>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104c2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c34:	8b 10                	mov    (%eax),%edx
80104c36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c3c:	8b 40 04             	mov    0x4(%eax),%eax
80104c3f:	83 ec 08             	sub    $0x8,%esp
80104c42:	52                   	push   %edx
80104c43:	50                   	push   %eax
80104c44:	e8 7a 53 00 00       	call   80109fc3 <copyuvm>
80104c49:	83 c4 10             	add    $0x10,%esp
80104c4c:	89 c2                	mov    %eax,%edx
80104c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c51:	89 50 04             	mov    %edx,0x4(%eax)
80104c54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c57:	8b 40 04             	mov    0x4(%eax),%eax
80104c5a:	85 c0                	test   %eax,%eax
80104c5c:	0f 85 84 00 00 00    	jne    80104ce6 <fork+0xd9>
    kfree(np->kstack);
80104c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c65:	8b 40 08             	mov    0x8(%eax),%eax
80104c68:	83 ec 0c             	sub    $0xc,%esp
80104c6b:	50                   	push   %eax
80104c6c:	e8 02 e0 ff ff       	call   80102c73 <kfree>
80104c71:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104c74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  assertStateZombie(np); 
80104c7e:	83 ec 0c             	sub    $0xc,%esp
80104c81:	ff 75 e0             	pushl  -0x20(%ebp)
80104c84:	e8 96 f8 ff ff       	call   8010451f <assertStateZombie>
80104c89:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.zombie, np);
80104c8c:	83 ec 08             	sub    $0x8,%esp
80104c8f:	ff 75 e0             	pushl  -0x20(%ebp)
80104c92:	68 d0 70 11 80       	push   $0x801170d0
80104c97:	e8 10 fa ff ff       	call   801046ac <removeFromStateList>
80104c9c:	83 c4 10             	add    $0x10,%esp

  np->state = UNUSED;
80104c9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ca2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  cprintf("\nZOMBIE -> UNUSED\n");
80104ca9:	83 ec 0c             	sub    $0xc,%esp
80104cac:	68 21 a6 10 80       	push   $0x8010a621
80104cb1:	e8 10 b7 ff ff       	call   801003c6 <cprintf>
80104cb6:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.free, np);
80104cb9:	83 ec 08             	sub    $0x8,%esp
80104cbc:	ff 75 e0             	pushl  -0x20(%ebp)
80104cbf:	68 c8 70 11 80       	push   $0x801170c8
80104cc4:	e8 fb f8 ff ff       	call   801045c4 <addToStateListEnd>
80104cc9:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104ccc:	83 ec 0c             	sub    $0xc,%esp
80104ccf:	68 80 49 11 80       	push   $0x80114980
80104cd4:	e8 25 1e 00 00       	call   80106afe <release>
80104cd9:	83 c4 10             	add    $0x10,%esp

    return -1;
80104cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce1:	e9 51 01 00 00       	jmp    80104e37 <fork+0x22a>
  }
  np->sz = proc->sz;
80104ce6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cec:	8b 10                	mov    (%eax),%edx
80104cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cf1:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104cf3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cfd:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d03:	8b 50 18             	mov    0x18(%eax),%edx
80104d06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d0c:	8b 40 18             	mov    0x18(%eax),%eax
80104d0f:	89 c3                	mov    %eax,%ebx
80104d11:	b8 13 00 00 00       	mov    $0x13,%eax
80104d16:	89 d7                	mov    %edx,%edi
80104d18:	89 de                	mov    %ebx,%esi
80104d1a:	89 c1                	mov    %eax,%ecx
80104d1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)



  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104d1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d21:	8b 40 18             	mov    0x18(%eax),%eax
80104d24:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104d2b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104d32:	eb 43                	jmp    80104d77 <fork+0x16a>
    if(proc->ofile[i])
80104d34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d3d:	83 c2 08             	add    $0x8,%edx
80104d40:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d44:	85 c0                	test   %eax,%eax
80104d46:	74 2b                	je     80104d73 <fork+0x166>
      np->ofile[i] = filedup(proc->ofile[i]);
80104d48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d4e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d51:	83 c2 08             	add    $0x8,%edx
80104d54:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d58:	83 ec 0c             	sub    $0xc,%esp
80104d5b:	50                   	push   %eax
80104d5c:	e8 49 c3 ff ff       	call   801010aa <filedup>
80104d61:	83 c4 10             	add    $0x10,%esp
80104d64:	89 c1                	mov    %eax,%ecx
80104d66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d6c:	83 c2 08             	add    $0x8,%edx
80104d6f:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104d73:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104d77:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104d7b:	7e b7                	jle    80104d34 <fork+0x127>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104d7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d83:	8b 40 68             	mov    0x68(%eax),%eax
80104d86:	83 ec 0c             	sub    $0xc,%esp
80104d89:	50                   	push   %eax
80104d8a:	e8 4b cc ff ff       	call   801019da <idup>
80104d8f:	83 c4 10             	add    $0x10,%esp
80104d92:	89 c2                	mov    %eax,%edx
80104d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d97:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104d9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da0:	8d 50 6c             	lea    0x6c(%eax),%edx
80104da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104da6:	83 c0 6c             	add    $0x6c,%eax
80104da9:	83 ec 04             	sub    $0x4,%esp
80104dac:	6a 10                	push   $0x10
80104dae:	52                   	push   %edx
80104daf:	50                   	push   %eax
80104db0:	e8 48 21 00 00       	call   80106efd <safestrcpy>
80104db5:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104db8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dbb:	8b 40 10             	mov    0x10(%eax),%eax
80104dbe:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.


  acquire(&ptable.lock);
80104dc1:	83 ec 0c             	sub    $0xc,%esp
80104dc4:	68 80 49 11 80       	push   $0x80114980
80104dc9:	e8 c9 1c 00 00       	call   80106a97 <acquire>
80104dce:	83 c4 10             	add    $0x10,%esp
  assertStateEmbryo(np);
80104dd1:	83 ec 0c             	sub    $0xc,%esp
80104dd4:	ff 75 e0             	pushl  -0x20(%ebp)
80104dd7:	e8 64 f7 ff ff       	call   80104540 <assertStateEmbryo>
80104ddc:	83 c4 10             	add    $0x10,%esp

  removeFromStateListHead(&ptable.pLists.embryo, np);
80104ddf:	83 ec 08             	sub    $0x8,%esp
80104de2:	ff 75 e0             	pushl  -0x20(%ebp)
80104de5:	68 d8 70 11 80       	push   $0x801170d8
80104dea:	e8 5f f8 ff ff       	call   8010464e <removeFromStateListHead>
80104def:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104df5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[np -> priority], np);	//Change to priority queue
80104dfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dff:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80104e05:	05 cc 09 00 00       	add    $0x9cc,%eax
80104e0a:	c1 e0 02             	shl    $0x2,%eax
80104e0d:	05 80 49 11 80       	add    $0x80114980,%eax
80104e12:	83 c0 04             	add    $0x4,%eax
80104e15:	83 ec 08             	sub    $0x8,%esp
80104e18:	ff 75 e0             	pushl  -0x20(%ebp)
80104e1b:	50                   	push   %eax
80104e1c:	e8 a3 f7 ff ff       	call   801045c4 <addToStateListEnd>
80104e21:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104e24:	83 ec 0c             	sub    $0xc,%esp
80104e27:	68 80 49 11 80       	push   $0x80114980
80104e2c:	e8 cd 1c 00 00       	call   80106afe <release>
80104e31:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104e34:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e3a:	5b                   	pop    %ebx
80104e3b:	5e                   	pop    %esi
80104e3c:	5f                   	pop    %edi
80104e3d:	5d                   	pop    %ebp
80104e3e:	c3                   	ret    

80104e3f <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104e3f:	55                   	push   %ebp
80104e40:	89 e5                	mov    %esp,%ebp
80104e42:	83 ec 18             	sub    $0x18,%esp

  struct proc *p;
  int fd;

  if(proc == initproc)
80104e45:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e4c:	a1 68 d6 10 80       	mov    0x8010d668,%eax
80104e51:	39 c2                	cmp    %eax,%edx
80104e53:	75 0d                	jne    80104e62 <exit+0x23>
    panic("init exiting");
80104e55:	83 ec 0c             	sub    $0xc,%esp
80104e58:	68 34 a6 10 80       	push   $0x8010a634
80104e5d:	e8 04 b7 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104e62:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104e69:	eb 48                	jmp    80104eb3 <exit+0x74>
    if(proc->ofile[fd]){
80104e6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e71:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e74:	83 c2 08             	add    $0x8,%edx
80104e77:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e7b:	85 c0                	test   %eax,%eax
80104e7d:	74 30                	je     80104eaf <exit+0x70>
      fileclose(proc->ofile[fd]);
80104e7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e85:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e88:	83 c2 08             	add    $0x8,%edx
80104e8b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e8f:	83 ec 0c             	sub    $0xc,%esp
80104e92:	50                   	push   %eax
80104e93:	e8 63 c2 ff ff       	call   801010fb <fileclose>
80104e98:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ea4:	83 c2 08             	add    $0x8,%edx
80104ea7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104eae:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104eaf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104eb3:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104eb7:	7e b2                	jle    80104e6b <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104eb9:	e8 39 e7 ff ff       	call   801035f7 <begin_op>
  iput(proc->cwd);
80104ebe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ec4:	8b 40 68             	mov    0x68(%eax),%eax
80104ec7:	83 ec 0c             	sub    $0xc,%esp
80104eca:	50                   	push   %eax
80104ecb:	e8 14 cd ff ff       	call   80101be4 <iput>
80104ed0:	83 c4 10             	add    $0x10,%esp
  end_op();
80104ed3:	e8 ab e7 ff ff       	call   80103683 <end_op>
  proc->cwd = 0;
80104ed8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ede:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104ee5:	83 ec 0c             	sub    $0xc,%esp
80104ee8:	68 80 49 11 80       	push   $0x80114980
80104eed:	e8 a5 1b 00 00       	call   80106a97 <acquire>
80104ef2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104ef5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104efb:	8b 40 14             	mov    0x14(%eax),%eax
80104efe:	83 ec 0c             	sub    $0xc,%esp
80104f01:	50                   	push   %eax
80104f02:	e8 f0 09 00 00       	call   801058f7 <wakeup1>
80104f07:	83 c4 10             	add    $0x10,%esp
  int found = 0;
80104f0a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  // Pass abandoned children to init.



  p = ptable.pLists.running;
80104f11:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80104f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p && !found){
80104f19:	eb 2f                	jmp    80104f4a <exit+0x10b>
    if(p->parent == proc){
80104f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1e:	8b 50 14             	mov    0x14(%eax),%edx
80104f21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f27:	39 c2                	cmp    %eax,%edx
80104f29:	75 13                	jne    80104f3e <exit+0xff>
      found = 1;
80104f2b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      p->parent = initproc;
80104f32:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3b:	89 50 14             	mov    %edx,0x14(%eax)
    }
    p = p -> next;
80104f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f41:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // Pass abandoned children to init.



  p = ptable.pLists.running;
  while(p && !found){
80104f4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f4e:	74 06                	je     80104f56 <exit+0x117>
80104f50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104f54:	74 c5                	je     80104f1b <exit+0xdc>
      found = 1;
      p->parent = initproc;
    }
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
80104f56:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80104f5d:	eb 53                	jmp    80104fb2 <exit+0x173>
      p = ptable.pLists.ready[i];	//Change to priority queue
80104f5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f62:	05 cc 09 00 00       	add    $0x9cc,%eax
80104f67:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80104f6e:	89 45 f4             	mov    %eax,-0xc(%ebp)

      while(p && !found){
80104f71:	eb 2f                	jmp    80104fa2 <exit+0x163>
	if(p->parent == proc){
80104f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f76:	8b 50 14             	mov    0x14(%eax),%edx
80104f79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f7f:	39 c2                	cmp    %eax,%edx
80104f81:	75 13                	jne    80104f96 <exit+0x157>

	  found = 1;
80104f83:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
80104f8a:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f93:	89 50 14             	mov    %edx,0x14(%eax)
	}
	p = p -> next;
80104f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f99:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
      p = ptable.pLists.ready[i];	//Change to priority queue

      while(p && !found){
80104fa2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fa6:	74 06                	je     80104fae <exit+0x16f>
80104fa8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104fac:	74 c5                	je     80104f73 <exit+0x134>
      found = 1;
      p->parent = initproc;
    }
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
80104fae:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104fb2:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
80104fb6:	7e a7                	jle    80104f5f <exit+0x120>
	}
	p = p -> next;
      }
  }
  
      p = ptable.pLists.sleep;
80104fb8:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80104fbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while(p && !found){
80104fc0:	eb 2f                	jmp    80104ff1 <exit+0x1b2>
	if(p->parent == proc){
80104fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc5:	8b 50 14             	mov    0x14(%eax),%edx
80104fc8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fce:	39 c2                	cmp    %eax,%edx
80104fd0:	75 13                	jne    80104fe5 <exit+0x1a6>
	  found = 1;
80104fd2:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
80104fd9:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80104fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe2:	89 50 14             	mov    %edx,0x14(%eax)
	}
	p = p -> next;
80104fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104fee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	p = p -> next;
      }
  }
  
      p = ptable.pLists.sleep;
      while(p && !found){
80104ff1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ff5:	74 06                	je     80104ffd <exit+0x1be>
80104ff7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104ffb:	74 c5                	je     80104fc2 <exit+0x183>
	  found = 1;
	  p->parent = initproc;
	}
	p = p -> next;
      }
      p = ptable.pLists.zombie;
80104ffd:	a1 d0 70 11 80       	mov    0x801170d0,%eax
80105002:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while(p && !found){
80105005:	eb 40                	jmp    80105047 <exit+0x208>
	if(p->parent == proc){
80105007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500a:	8b 50 14             	mov    0x14(%eax),%edx
8010500d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105013:	39 c2                	cmp    %eax,%edx
80105015:	75 24                	jne    8010503b <exit+0x1fc>

	  found = 1;
80105017:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
8010501e:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80105024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105027:	89 50 14             	mov    %edx,0x14(%eax)
	  wakeup1(initproc);
8010502a:	a1 68 d6 10 80       	mov    0x8010d668,%eax
8010502f:	83 ec 0c             	sub    $0xc,%esp
80105032:	50                   	push   %eax
80105033:	e8 bf 08 00 00       	call   801058f7 <wakeup1>
80105038:	83 c4 10             	add    $0x10,%esp

	}
	p = p -> next;
8010503b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105044:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  p->parent = initproc;
	}
	p = p -> next;
      }
      p = ptable.pLists.zombie;
      while(p && !found){
80105047:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010504b:	74 06                	je     80105053 <exit+0x214>
8010504d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105051:	74 b4                	je     80105007 <exit+0x1c8>
	}
	p = p -> next;
      }

  // Jump into the scheduler, never to return.
  assertStateRunning(proc);
80105053:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105059:	83 ec 0c             	sub    $0xc,%esp
8010505c:	50                   	push   %eax
8010505d:	e8 ff f4 ff ff       	call   80104561 <assertStateRunning>
80105062:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.running, proc);
80105065:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010506b:	83 ec 08             	sub    $0x8,%esp
8010506e:	50                   	push   %eax
8010506f:	68 d4 70 11 80       	push   $0x801170d4
80105074:	e8 33 f6 ff ff       	call   801046ac <removeFromStateList>
80105079:	83 c4 10             	add    $0x10,%esp

  proc -> state = ZOMBIE;
8010507c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105082:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
 
  assertStateZombie(proc);
80105089:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508f:	83 ec 0c             	sub    $0xc,%esp
80105092:	50                   	push   %eax
80105093:	e8 87 f4 ff ff       	call   8010451f <assertStateZombie>
80105098:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.zombie, proc);
8010509b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a1:	83 ec 08             	sub    $0x8,%esp
801050a4:	50                   	push   %eax
801050a5:	68 d0 70 11 80       	push   $0x801170d0
801050aa:	e8 15 f5 ff ff       	call   801045c4 <addToStateListEnd>
801050af:	83 c4 10             	add    $0x10,%esp

  sched();
801050b2:	e8 b5 04 00 00       	call   8010556c <sched>
  panic("zombie exit");
801050b7:	83 ec 0c             	sub    $0xc,%esp
801050ba:	68 41 a6 10 80       	push   $0x8010a641
801050bf:	e8 a2 b4 ff ff       	call   80100566 <panic>

801050c4 <wait>:
  }
}
#else
int
wait(void)
{
801050c4:	55                   	push   %ebp
801050c5:	89 e5                	mov    %esp,%ebp
801050c7:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  int havekids, pid;
  acquire(&ptable.lock);
801050ca:	83 ec 0c             	sub    $0xc,%esp
801050cd:	68 80 49 11 80       	push   $0x80114980
801050d2:	e8 c0 19 00 00       	call   80106a97 <acquire>
801050d7:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801050da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    int found = 0;
801050e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

     p = ptable.pLists.zombie;
801050e8:	a1 d0 70 11 80       	mov    0x801170d0,%eax
801050ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
     while(p && !found){
801050f0:	e9 e0 00 00 00       	jmp    801051d5 <wait+0x111>
       if(p->parent == proc){
801050f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f8:	8b 50 14             	mov    0x14(%eax),%edx
801050fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105101:	39 c2                	cmp    %eax,%edx
80105103:	0f 85 c0 00 00 00    	jne    801051c9 <wait+0x105>
	 found = 1;
80105109:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	 havekids = 1;
80105110:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	 pid = p->pid;
80105117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511a:	8b 40 10             	mov    0x10(%eax),%eax
8010511d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	 kfree(p->kstack);
80105120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105123:	8b 40 08             	mov    0x8(%eax),%eax
80105126:	83 ec 0c             	sub    $0xc,%esp
80105129:	50                   	push   %eax
8010512a:	e8 44 db ff ff       	call   80102c73 <kfree>
8010512f:	83 c4 10             	add    $0x10,%esp
	 p->kstack = 0;
80105132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105135:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	 freevm(p->pgdir);
8010513c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513f:	8b 40 04             	mov    0x4(%eax),%eax
80105142:	83 ec 0c             	sub    $0xc,%esp
80105145:	50                   	push   %eax
80105146:	e8 97 4d 00 00       	call   80109ee2 <freevm>
8010514b:	83 c4 10             	add    $0x10,%esp

	 assertStateZombie(p);
8010514e:	83 ec 0c             	sub    $0xc,%esp
80105151:	ff 75 f4             	pushl  -0xc(%ebp)
80105154:	e8 c6 f3 ff ff       	call   8010451f <assertStateZombie>
80105159:	83 c4 10             	add    $0x10,%esp

	 removeFromStateList(&ptable.pLists.zombie, p);
8010515c:	83 ec 08             	sub    $0x8,%esp
8010515f:	ff 75 f4             	pushl  -0xc(%ebp)
80105162:	68 d0 70 11 80       	push   $0x801170d0
80105167:	e8 40 f5 ff ff       	call   801046ac <removeFromStateList>
8010516c:	83 c4 10             	add    $0x10,%esp

	 p->state = UNUSED;
8010516f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105172:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	 addToStateListEnd(&ptable.pLists.free, p);
80105179:	83 ec 08             	sub    $0x8,%esp
8010517c:	ff 75 f4             	pushl  -0xc(%ebp)
8010517f:	68 c8 70 11 80       	push   $0x801170c8
80105184:	e8 3b f4 ff ff       	call   801045c4 <addToStateListEnd>
80105189:	83 c4 10             	add    $0x10,%esp

	 p->pid = 0;
8010518c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
	 p->parent = 0;
80105196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105199:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	 p->name[0] = 0;
801051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a3:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
	 p->killed = 0;
801051a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051aa:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
	 release(&ptable.lock);
801051b1:	83 ec 0c             	sub    $0xc,%esp
801051b4:	68 80 49 11 80       	push   $0x80114980
801051b9:	e8 40 19 00 00       	call   80106afe <release>
801051be:	83 c4 10             	add    $0x10,%esp
	 return pid;
801051c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801051c4:	e9 4b 01 00 00       	jmp    80105314 <wait+0x250>

       }
       p = p -> next;
801051c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // Scan through table looking for zombie children.
    havekids = 0;
    int found = 0;

     p = ptable.pLists.zombie;
     while(p && !found){
801051d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051d9:	74 0a                	je     801051e5 <wait+0x121>
801051db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801051df:	0f 84 10 ff ff ff    	je     801050f5 <wait+0x31>
	 return pid;

       }
       p = p -> next;
     }
    p = ptable.pLists.running;
801051e5:	a1 d4 70 11 80       	mov    0x801170d4,%eax
801051ea:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while(p && !found){
801051ed:	eb 2a                	jmp    80105219 <wait+0x155>
      if(p->parent == proc){
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	8b 50 14             	mov    0x14(%eax),%edx
801051f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051fb:	39 c2                	cmp    %eax,%edx
801051fd:	75 0e                	jne    8010520d <wait+0x149>
	found = 1;
801051ff:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	havekids = 1;
80105206:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      }
      p = p -> next;
8010520d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105210:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105216:	89 45 f4             	mov    %eax,-0xc(%ebp)
       }
       p = p -> next;
     }
    p = ptable.pLists.running;

    while(p && !found){
80105219:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010521d:	74 06                	je     80105225 <wait+0x161>
8010521f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105223:	74 ca                	je     801051ef <wait+0x12b>
	found = 1;
	havekids = 1;
      }
      p = p -> next;
    }
    if(!found){
80105225:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105229:	75 5d                	jne    80105288 <wait+0x1c4>
      for(int i = 0; i < MAX+1; ++i){	
8010522b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80105232:	eb 4e                	jmp    80105282 <wait+0x1be>
	p = ptable.pLists.ready[i];	//Change to priority queue
80105234:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105237:	05 cc 09 00 00       	add    $0x9cc,%eax
8010523c:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105243:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while(p && !found){
80105246:	eb 2a                	jmp    80105272 <wait+0x1ae>
	  if(p->parent == proc){
80105248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524b:	8b 50 14             	mov    0x14(%eax),%edx
8010524e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105254:	39 c2                	cmp    %eax,%edx
80105256:	75 0e                	jne    80105266 <wait+0x1a2>
	    found = 1;
80105258:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	    havekids = 1;
8010525f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	   }
	   p = p -> next;
80105266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105269:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010526f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      p = p -> next;
    }
    if(!found){
      for(int i = 0; i < MAX+1; ++i){	
	p = ptable.pLists.ready[i];	//Change to priority queue
	while(p && !found){
80105272:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105276:	74 06                	je     8010527e <wait+0x1ba>
80105278:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010527c:	74 ca                	je     80105248 <wait+0x184>
	havekids = 1;
      }
      p = p -> next;
    }
    if(!found){
      for(int i = 0; i < MAX+1; ++i){	
8010527e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80105282:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
80105286:	7e ac                	jle    80105234 <wait+0x170>
	   }
	   p = p -> next;
	}
      }
     }
     if(!found){
80105288:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010528c:	75 40                	jne    801052ce <wait+0x20a>
	 p = ptable.pLists.sleep;
8010528e:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80105293:	89 45 f4             	mov    %eax,-0xc(%ebp)
	 while(p && !found){
80105296:	eb 2a                	jmp    801052c2 <wait+0x1fe>
	   if(p->parent == proc){
80105298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529b:	8b 50 14             	mov    0x14(%eax),%edx
8010529e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052a4:	39 c2                	cmp    %eax,%edx
801052a6:	75 0e                	jne    801052b6 <wait+0x1f2>
	     found = 1;
801052a8:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	     havekids = 1;
801052af:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	   }
	   p = p -> next;
801052b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801052bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
      }
     }
     if(!found){
	 p = ptable.pLists.sleep;
	 while(p && !found){
801052c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052c6:	74 06                	je     801052ce <wait+0x20a>
801052c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801052cc:	74 ca                	je     80105298 <wait+0x1d4>
	 }
     }


    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801052ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052d2:	74 0d                	je     801052e1 <wait+0x21d>
801052d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052da:	8b 40 24             	mov    0x24(%eax),%eax
801052dd:	85 c0                	test   %eax,%eax
801052df:	74 17                	je     801052f8 <wait+0x234>
      release(&ptable.lock);
801052e1:	83 ec 0c             	sub    $0xc,%esp
801052e4:	68 80 49 11 80       	push   $0x80114980
801052e9:	e8 10 18 00 00       	call   80106afe <release>
801052ee:	83 c4 10             	add    $0x10,%esp
      return -1;
801052f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f6:	eb 1c                	jmp    80105314 <wait+0x250>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801052f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052fe:	83 ec 08             	sub    $0x8,%esp
80105301:	68 80 49 11 80       	push   $0x80114980
80105306:	50                   	push   %eax
80105307:	e8 76 04 00 00       	call   80105782 <sleep>
8010530c:	83 c4 10             	add    $0x10,%esp
  }
8010530f:	e9 c6 fd ff ff       	jmp    801050da <wait+0x16>

}
80105314:	c9                   	leave  
80105315:	c3                   	ret    

80105316 <scheduler>:
}

#else
void
scheduler(void)
{
80105316:	55                   	push   %ebp
80105317:	89 e5                	mov    %esp,%ebp
80105319:	83 ec 18             	sub    $0x18,%esp
    struct proc *p;
      int idle;  // for checking if processor is idle
      for(;;){
	// Enable interrupts on this processor.
	sti();
8010531c:	e8 d7 f1 ff ff       	call   801044f8 <sti>

	idle = 1;  // assume idle unless we schedule a process
80105321:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)

	acquire(&ptable.lock);
80105328:	83 ec 0c             	sub    $0xc,%esp
8010532b:	68 80 49 11 80       	push   $0x80114980
80105330:	e8 62 17 00 00       	call   80106a97 <acquire>
80105335:	83 c4 10             	add    $0x10,%esp

	  if(ticks >= ptable.PromoteAtTime){
80105338:	8b 15 dc 70 11 80    	mov    0x801170dc,%edx
8010533e:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80105343:	39 c2                	cmp    %eax,%edx
80105345:	0f 87 2c 01 00 00    	ja     80105477 <scheduler+0x161>
	      for(int i = 1; i < MAX+1; ++i){
8010534b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
80105352:	e9 8b 00 00 00       	jmp    801053e2 <scheduler+0xcc>
		 do{ 
		      p = ptable.pLists.ready[i];
80105357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535a:	05 cc 09 00 00       	add    $0x9cc,%eax
8010535f:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105366:	89 45 f4             	mov    %eax,-0xc(%ebp)
		      if(p){
80105369:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010536d:	74 65                	je     801053d4 <scheduler+0xbe>
			  removeFromStateList(&ptable.pLists.ready[p -> priority], p);
8010536f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105372:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105378:	05 cc 09 00 00       	add    $0x9cc,%eax
8010537d:	c1 e0 02             	shl    $0x2,%eax
80105380:	05 80 49 11 80       	add    $0x80114980,%eax
80105385:	83 c0 04             	add    $0x4,%eax
80105388:	83 ec 08             	sub    $0x8,%esp
8010538b:	ff 75 f4             	pushl  -0xc(%ebp)
8010538e:	50                   	push   %eax
8010538f:	e8 18 f3 ff ff       	call   801046ac <removeFromStateList>
80105394:	83 c4 10             	add    $0x10,%esp
			  --(p -> priority);
80105397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801053a0:	8d 50 ff             	lea    -0x1(%eax),%edx
801053a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a6:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801053b5:	05 cc 09 00 00       	add    $0x9cc,%eax
801053ba:	c1 e0 02             	shl    $0x2,%eax
801053bd:	05 80 49 11 80       	add    $0x80114980,%eax
801053c2:	83 c0 04             	add    $0x4,%eax
801053c5:	83 ec 08             	sub    $0x8,%esp
801053c8:	ff 75 f4             	pushl  -0xc(%ebp)
801053cb:	50                   	push   %eax
801053cc:	e8 f3 f1 ff ff       	call   801045c4 <addToStateListEnd>
801053d1:	83 c4 10             	add    $0x10,%esp
		      }
		  }while(p);
801053d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053d8:	0f 85 79 ff ff ff    	jne    80105357 <scheduler+0x41>
	idle = 1;  // assume idle unless we schedule a process

	acquire(&ptable.lock);

	  if(ticks >= ptable.PromoteAtTime){
	      for(int i = 1; i < MAX+1; ++i){
801053de:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801053e2:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801053e6:	0f 8e 6b ff ff ff    	jle    80105357 <scheduler+0x41>
			  --(p -> priority);
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
		      }
		  }while(p);
	      }
	      p = ptable.pLists.sleep;
801053ec:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801053f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      while(p){
801053f4:	eb 2e                	jmp    80105424 <scheduler+0x10e>
		  if(p -> priority > 0)
801053f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f9:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801053ff:	85 c0                	test   %eax,%eax
80105401:	74 15                	je     80105418 <scheduler+0x102>
		    --(p -> priority);
80105403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105406:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010540c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010540f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105412:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		  p = p -> next;
80105418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105421:	89 45 f4             	mov    %eax,-0xc(%ebp)
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
		      }
		  }while(p);
	      }
	      p = ptable.pLists.sleep;
	      while(p){
80105424:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105428:	75 cc                	jne    801053f6 <scheduler+0xe0>
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }
	      p = ptable.pLists.running;
8010542a:	a1 d4 70 11 80       	mov    0x801170d4,%eax
8010542f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      while(p){
80105432:	eb 2e                	jmp    80105462 <scheduler+0x14c>
		  if(p -> priority > 0)
80105434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105437:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010543d:	85 c0                	test   %eax,%eax
8010543f:	74 15                	je     80105456 <scheduler+0x140>
		    --(p -> priority);
80105441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105444:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010544a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010544d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105450:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		  p = p -> next;
80105456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105459:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010545f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }
	      p = ptable.pLists.running;
	      while(p){
80105462:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105466:	75 cc                	jne    80105434 <scheduler+0x11e>
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }

	      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
80105468:	a1 e0 78 11 80       	mov    0x801178e0,%eax
8010546d:	05 88 13 00 00       	add    $0x1388,%eax
80105472:	a3 dc 70 11 80       	mov    %eax,0x801170dc
	  }
	for(int i = 0; i < MAX+1; ++i){
80105477:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010547e:	eb 1c                	jmp    8010549c <scheduler+0x186>
	    p = ptable.pLists.ready[i];
80105480:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105483:	05 cc 09 00 00       	add    $0x9cc,%eax
80105488:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010548f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    if(p){
80105492:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105496:	75 0c                	jne    801054a4 <scheduler+0x18e>
		  p = p -> next;
	      }

	      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
	  }
	for(int i = 0; i < MAX+1; ++i){
80105498:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010549c:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
801054a0:	7e de                	jle    80105480 <scheduler+0x16a>
801054a2:	eb 01                	jmp    801054a5 <scheduler+0x18f>
	    p = ptable.pLists.ready[i];
	    if(p){
		break;
801054a4:	90                   	nop
	    }
	}

	if(p){		      
801054a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054a9:	0f 84 9d 00 00 00    	je     8010554c <scheduler+0x236>
	  assertStateReady(p);
801054af:	83 ec 0c             	sub    $0xc,%esp
801054b2:	ff 75 f4             	pushl  -0xc(%ebp)
801054b5:	e8 e9 f0 ff ff       	call   801045a3 <assertStateReady>
801054ba:	83 c4 10             	add    $0x10,%esp

	  removeFromStateListHead(&ptable.pLists.ready[p -> priority], p);
801054bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c0:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801054c6:	05 cc 09 00 00       	add    $0x9cc,%eax
801054cb:	c1 e0 02             	shl    $0x2,%eax
801054ce:	05 80 49 11 80       	add    $0x80114980,%eax
801054d3:	83 c0 04             	add    $0x4,%eax
801054d6:	83 ec 08             	sub    $0x8,%esp
801054d9:	ff 75 f4             	pushl  -0xc(%ebp)
801054dc:	50                   	push   %eax
801054dd:	e8 6c f1 ff ff       	call   8010464e <removeFromStateListHead>
801054e2:	83 c4 10             	add    $0x10,%esp
	  idle = 0;  // not idle this timeslice
801054e5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	  proc = p;
801054ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ef:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
801054f5:	83 ec 0c             	sub    $0xc,%esp
801054f8:	ff 75 f4             	pushl  -0xc(%ebp)
801054fb:	e8 9c 45 00 00       	call   80109a9c <switchuvm>
80105500:	83 c4 10             	add    $0x10,%esp

	  proc -> state = RUNNING;
80105503:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105509:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  addToStateListEnd(&ptable.pLists.running, proc);
80105510:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105516:	83 ec 08             	sub    $0x8,%esp
80105519:	50                   	push   %eax
8010551a:	68 d4 70 11 80       	push   $0x801170d4
8010551f:	e8 a0 f0 ff ff       	call   801045c4 <addToStateListEnd>
80105524:	83 c4 10             	add    $0x10,%esp
	  swtch(&cpu->scheduler, proc->context);
80105527:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105530:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105537:	83 c2 04             	add    $0x4,%edx
8010553a:	83 ec 08             	sub    $0x8,%esp
8010553d:	50                   	push   %eax
8010553e:	52                   	push   %edx
8010553f:	e8 2a 1a 00 00       	call   80106f6e <swtch>
80105544:	83 c4 10             	add    $0x10,%esp
	  switchkvm();
80105547:	e8 33 45 00 00       	call   80109a7f <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.

	  
	}
	proc = 0;
8010554c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105553:	00 00 00 00 

	release(&ptable.lock);
80105557:	83 ec 0c             	sub    $0xc,%esp
8010555a:	68 80 49 11 80       	push   $0x80114980
8010555f:	e8 9a 15 00 00       	call   80106afe <release>
80105564:	83 c4 10             	add    $0x10,%esp
      }
80105567:	e9 b0 fd ff ff       	jmp    8010531c <scheduler+0x6>

8010556c <sched>:

}
#else
void
sched(void)
{
8010556c:	55                   	push   %ebp
8010556d:	89 e5                	mov    %esp,%ebp
8010556f:	83 ec 18             	sub    $0x18,%esp
    int intena;

  if(!holding(&ptable.lock))
80105572:	83 ec 0c             	sub    $0xc,%esp
80105575:	68 80 49 11 80       	push   $0x80114980
8010557a:	e8 4b 16 00 00       	call   80106bca <holding>
8010557f:	83 c4 10             	add    $0x10,%esp
80105582:	85 c0                	test   %eax,%eax
80105584:	75 0d                	jne    80105593 <sched+0x27>
    panic("sched ptable.lock");
80105586:	83 ec 0c             	sub    $0xc,%esp
80105589:	68 4d a6 10 80       	push   $0x8010a64d
8010558e:	e8 d3 af ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105593:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105599:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010559f:	83 f8 01             	cmp    $0x1,%eax
801055a2:	74 0d                	je     801055b1 <sched+0x45>
    panic("sched locks");
801055a4:	83 ec 0c             	sub    $0xc,%esp
801055a7:	68 5f a6 10 80       	push   $0x8010a65f
801055ac:	e8 b5 af ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801055b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b7:	8b 40 0c             	mov    0xc(%eax),%eax
801055ba:	83 f8 04             	cmp    $0x4,%eax
801055bd:	75 0d                	jne    801055cc <sched+0x60>
    panic("sched running");
801055bf:	83 ec 0c             	sub    $0xc,%esp
801055c2:	68 6b a6 10 80       	push   $0x8010a66b
801055c7:	e8 9a af ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801055cc:	e8 17 ef ff ff       	call   801044e8 <readeflags>
801055d1:	25 00 02 00 00       	and    $0x200,%eax
801055d6:	85 c0                	test   %eax,%eax
801055d8:	74 0d                	je     801055e7 <sched+0x7b>
    panic("sched interruptible");
801055da:	83 ec 0c             	sub    $0xc,%esp
801055dd:	68 79 a6 10 80       	push   $0x8010a679
801055e2:	e8 7f af ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801055e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055ed:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801055f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //cprintf("Descheduled a process\n");
  swtch(&proc->context, cpu->scheduler);
801055f6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055fc:	8b 40 04             	mov    0x4(%eax),%eax
801055ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105606:	83 c2 1c             	add    $0x1c,%edx
80105609:	83 ec 08             	sub    $0x8,%esp
8010560c:	50                   	push   %eax
8010560d:	52                   	push   %edx
8010560e:	e8 5b 19 00 00       	call   80106f6e <swtch>
80105613:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80105616:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010561c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010561f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
80105625:	90                   	nop
80105626:	c9                   	leave  
80105627:	c3                   	ret    

80105628 <yield>:

#else
// Give up the CPU for one scheduling round.
void
yield(void)
{
80105628:	55                   	push   %ebp
80105629:	89 e5                	mov    %esp,%ebp
8010562b:	53                   	push   %ebx
8010562c:	83 ec 04             	sub    $0x4,%esp
  //struct proc* p = proc;  
  acquire(&ptable.lock);  //DOC: yieldlock
8010562f:	83 ec 0c             	sub    $0xc,%esp
80105632:	68 80 49 11 80       	push   $0x80114980
80105637:	e8 5b 14 00 00       	call   80106a97 <acquire>
8010563c:	83 c4 10             	add    $0x10,%esp

  assertStateRunning(proc);
8010563f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105645:	83 ec 0c             	sub    $0xc,%esp
80105648:	50                   	push   %eax
80105649:	e8 13 ef ff ff       	call   80104561 <assertStateRunning>
8010564e:	83 c4 10             	add    $0x10,%esp
  proc -> budget = proc -> budget - (ticks - proc -> cpu_ticks_in);
80105651:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105657:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010565e:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105664:	89 d3                	mov    %edx,%ebx
80105666:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010566d:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
80105673:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105679:	29 d1                	sub    %edx,%ecx
8010567b:	89 ca                	mov    %ecx,%edx
8010567d:	01 da                	add    %ebx,%edx
8010567f:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)

  if(proc -> budget <= 0){
80105685:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010568b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105691:	85 c0                	test   %eax,%eax
80105693:	7f 36                	jg     801056cb <yield+0xa3>
      if(proc -> priority < MAX)
80105695:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010569b:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801056a1:	83 f8 03             	cmp    $0x3,%eax
801056a4:	77 15                	ja     801056bb <yield+0x93>
	++(proc -> priority);
801056a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ac:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
801056b2:	83 c2 01             	add    $0x1,%edx
801056b5:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    proc -> budget = BUDGET;
801056bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c1:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
801056c8:	13 00 00 
  }

  removeFromStateList(&ptable.pLists.running, proc);
801056cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d1:	83 ec 08             	sub    $0x8,%esp
801056d4:	50                   	push   %eax
801056d5:	68 d4 70 11 80       	push   $0x801170d4
801056da:	e8 cd ef ff ff       	call   801046ac <removeFromStateList>
801056df:	83 c4 10             	add    $0x10,%esp
  
  proc->state = RUNNABLE;
801056e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[proc -> priority], proc);	//Change to priority queue
801056ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801056fc:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
80105702:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
80105708:	c1 e2 02             	shl    $0x2,%edx
8010570b:	81 c2 80 49 11 80    	add    $0x80114980,%edx
80105711:	83 c2 04             	add    $0x4,%edx
80105714:	83 ec 08             	sub    $0x8,%esp
80105717:	50                   	push   %eax
80105718:	52                   	push   %edx
80105719:	e8 a6 ee ff ff       	call   801045c4 <addToStateListEnd>
8010571e:	83 c4 10             	add    $0x10,%esp


  sched();
80105721:	e8 46 fe ff ff       	call   8010556c <sched>
  release(&ptable.lock);
80105726:	83 ec 0c             	sub    $0xc,%esp
80105729:	68 80 49 11 80       	push   $0x80114980
8010572e:	e8 cb 13 00 00       	call   80106afe <release>
80105733:	83 c4 10             	add    $0x10,%esp

}
80105736:	90                   	nop
80105737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010573a:	c9                   	leave  
8010573b:	c3                   	ret    

8010573c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010573c:	55                   	push   %ebp
8010573d:	89 e5                	mov    %esp,%ebp
8010573f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105742:	83 ec 0c             	sub    $0xc,%esp
80105745:	68 80 49 11 80       	push   $0x80114980
8010574a:	e8 af 13 00 00       	call   80106afe <release>
8010574f:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105752:	a1 20 d0 10 80       	mov    0x8010d020,%eax
80105757:	85 c0                	test   %eax,%eax
80105759:	74 24                	je     8010577f <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010575b:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
80105762:	00 00 00 
    iinit(ROOTDEV);
80105765:	83 ec 0c             	sub    $0xc,%esp
80105768:	6a 01                	push   $0x1
8010576a:	e8 79 bf ff ff       	call   801016e8 <iinit>
8010576f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105772:	83 ec 0c             	sub    $0xc,%esp
80105775:	6a 01                	push   $0x1
80105777:	e8 5d dc ff ff       	call   801033d9 <initlog>
8010577c:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
8010577f:	90                   	nop
80105780:	c9                   	leave  
80105781:	c3                   	ret    

80105782 <sleep>:

#else

void
sleep(void *chan, struct spinlock *lk)
{
80105782:	55                   	push   %ebp
80105783:	89 e5                	mov    %esp,%ebp
80105785:	53                   	push   %ebx
80105786:	83 ec 04             	sub    $0x4,%esp
  if(proc == 0)
80105789:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010578f:	85 c0                	test   %eax,%eax
80105791:	75 0d                	jne    801057a0 <sleep+0x1e>
    panic("sleep");
80105793:	83 ec 0c             	sub    $0xc,%esp
80105796:	68 8d a6 10 80       	push   $0x8010a68d
8010579b:	e8 c6 ad ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801057a0:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801057a7:	74 24                	je     801057cd <sleep+0x4b>
    acquire(&ptable.lock);
801057a9:	83 ec 0c             	sub    $0xc,%esp
801057ac:	68 80 49 11 80       	push   $0x80114980
801057b1:	e8 e1 12 00 00       	call   80106a97 <acquire>
801057b6:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801057b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057bd:	74 0e                	je     801057cd <sleep+0x4b>
801057bf:	83 ec 0c             	sub    $0xc,%esp
801057c2:	ff 75 0c             	pushl  0xc(%ebp)
801057c5:	e8 34 13 00 00       	call   80106afe <release>
801057ca:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801057cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057d3:	8b 55 08             	mov    0x8(%ebp),%edx
801057d6:	89 50 20             	mov    %edx,0x20(%eax)
  //struct proc *p = proc;
  assertStateRunning(proc);
801057d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057df:	83 ec 0c             	sub    $0xc,%esp
801057e2:	50                   	push   %eax
801057e3:	e8 79 ed ff ff       	call   80104561 <assertStateRunning>
801057e8:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.running, proc);
801057eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f1:	83 ec 08             	sub    $0x8,%esp
801057f4:	50                   	push   %eax
801057f5:	68 d4 70 11 80       	push   $0x801170d4
801057fa:	e8 ad ee ff ff       	call   801046ac <removeFromStateList>
801057ff:	83 c4 10             	add    $0x10,%esp
  proc -> state = SLEEPING;
80105802:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105808:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  assertStateSleep(proc);
8010580f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105815:	83 ec 0c             	sub    $0xc,%esp
80105818:	50                   	push   %eax
80105819:	e8 64 ed ff ff       	call   80104582 <assertStateSleep>
8010581e:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.sleep, proc);
80105821:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105827:	83 ec 08             	sub    $0x8,%esp
8010582a:	50                   	push   %eax
8010582b:	68 cc 70 11 80       	push   $0x801170cc
80105830:	e8 8f ed ff ff       	call   801045c4 <addToStateListEnd>
80105835:	83 c4 10             	add    $0x10,%esp
  proc -> budget = proc -> budget - (ticks - proc -> cpu_ticks_in);
80105838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010583e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105845:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010584b:	89 d3                	mov    %edx,%ebx
8010584d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105854:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
8010585a:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105860:	29 d1                	sub    %edx,%ecx
80105862:	89 ca                	mov    %ecx,%edx
80105864:	01 da                	add    %ebx,%edx
80105866:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc -> budget <= 0){
8010586c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105872:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105878:	85 c0                	test   %eax,%eax
8010587a:	7f 36                	jg     801058b2 <sleep+0x130>
      if(proc -> priority < MAX)
8010587c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105882:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105888:	83 f8 03             	cmp    $0x3,%eax
8010588b:	77 15                	ja     801058a2 <sleep+0x120>
	++(proc -> priority);
8010588d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105893:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105899:	83 c2 01             	add    $0x1,%edx
8010589c:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    proc -> budget = BUDGET;
801058a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a8:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
801058af:	13 00 00 
  }
  sched();
801058b2:	e8 b5 fc ff ff       	call   8010556c <sched>

  // Tidy up.
  proc->chan = 0;
801058b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058bd:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
801058c4:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801058cb:	74 24                	je     801058f1 <sleep+0x16f>
    release(&ptable.lock);
801058cd:	83 ec 0c             	sub    $0xc,%esp
801058d0:	68 80 49 11 80       	push   $0x80114980
801058d5:	e8 24 12 00 00       	call   80106afe <release>
801058da:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
801058dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058e1:	74 0e                	je     801058f1 <sleep+0x16f>
801058e3:	83 ec 0c             	sub    $0xc,%esp
801058e6:	ff 75 0c             	pushl  0xc(%ebp)
801058e9:	e8 a9 11 00 00       	call   80106a97 <acquire>
801058ee:	83 c4 10             	add    $0x10,%esp
  }
}
801058f1:	90                   	nop
801058f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801058f5:	c9                   	leave  
801058f6:	c3                   	ret    

801058f7 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
801058f7:	55                   	push   %ebp
801058f8:	89 e5                	mov    %esp,%ebp
801058fa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  struct proc *sleeper = ptable.pLists.sleep;
801058fd:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80105902:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(sleeper){
80105905:	eb 7e                	jmp    80105985 <wakeup1+0x8e>
    if(sleeper -> chan == chan){
80105907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590a:	8b 40 20             	mov    0x20(%eax),%eax
8010590d:	3b 45 08             	cmp    0x8(%ebp),%eax
80105910:	75 67                	jne    80105979 <wakeup1+0x82>
      p = sleeper;
80105912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105915:	89 45 f0             	mov    %eax,-0x10(%ebp)
      sleeper = sleeper -> next;
80105918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
      assertStateSleep(p);
80105924:	83 ec 0c             	sub    $0xc,%esp
80105927:	ff 75 f0             	pushl  -0x10(%ebp)
8010592a:	e8 53 ec ff ff       	call   80104582 <assertStateSleep>
8010592f:	83 c4 10             	add    $0x10,%esp
      removeFromStateList(&ptable.pLists.sleep, p);
80105932:	83 ec 08             	sub    $0x8,%esp
80105935:	ff 75 f0             	pushl  -0x10(%ebp)
80105938:	68 cc 70 11 80       	push   $0x801170cc
8010593d:	e8 6a ed ff ff       	call   801046ac <removeFromStateList>
80105942:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNABLE;
80105945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105948:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      addToStateListEnd(&ptable.pLists.ready[p -> priority], p);	//Change to priority queue
8010594f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105952:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105958:	05 cc 09 00 00       	add    $0x9cc,%eax
8010595d:	c1 e0 02             	shl    $0x2,%eax
80105960:	05 80 49 11 80       	add    $0x80114980,%eax
80105965:	83 c0 04             	add    $0x4,%eax
80105968:	83 ec 08             	sub    $0x8,%esp
8010596b:	ff 75 f0             	pushl  -0x10(%ebp)
8010596e:	50                   	push   %eax
8010596f:	e8 50 ec ff ff       	call   801045c4 <addToStateListEnd>
80105974:	83 c4 10             	add    $0x10,%esp
80105977:	eb 0c                	jmp    80105985 <wakeup1+0x8e>

    }
    else
      sleeper = sleeper -> next;
80105979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105982:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;

  struct proc *sleeper = ptable.pLists.sleep;

  while(sleeper){
80105985:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105989:	0f 85 78 ff ff ff    	jne    80105907 <wakeup1+0x10>
    }
    else
      sleeper = sleeper -> next;
  }
  
}
8010598f:	90                   	nop
80105990:	c9                   	leave  
80105991:	c3                   	ret    

80105992 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105992:	55                   	push   %ebp
80105993:	89 e5                	mov    %esp,%ebp
80105995:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105998:	83 ec 0c             	sub    $0xc,%esp
8010599b:	68 80 49 11 80       	push   $0x80114980
801059a0:	e8 f2 10 00 00       	call   80106a97 <acquire>
801059a5:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801059a8:	83 ec 0c             	sub    $0xc,%esp
801059ab:	ff 75 08             	pushl  0x8(%ebp)
801059ae:	e8 44 ff ff ff       	call   801058f7 <wakeup1>
801059b3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801059b6:	83 ec 0c             	sub    $0xc,%esp
801059b9:	68 80 49 11 80       	push   $0x80114980
801059be:	e8 3b 11 00 00       	call   80106afe <release>
801059c3:	83 c4 10             	add    $0x10,%esp
}
801059c6:	90                   	nop
801059c7:	c9                   	leave  
801059c8:	c3                   	ret    

801059c9 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
801059c9:	55                   	push   %ebp
801059ca:	89 e5                	mov    %esp,%ebp
801059cc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int found = 0;
801059cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  acquire(&ptable.lock);
801059d6:	83 ec 0c             	sub    $0xc,%esp
801059d9:	68 80 49 11 80       	push   $0x80114980
801059de:	e8 b4 10 00 00       	call   80106a97 <acquire>
801059e3:	83 c4 10             	add    $0x10,%esp
  while(!found){
801059e6:	e9 dc 01 00 00       	jmp    80105bc7 <kill+0x1fe>

    for(int i = 0; i < MAX+1; ++i){
801059eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801059f2:	eb 68                	jmp    80105a5c <kill+0x93>
	p = ptable.pLists.ready[i];		//Change to priority queue
801059f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f7:	05 cc 09 00 00       	add    $0x9cc,%eax
801059fc:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105a03:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while(p && !found){
80105a06:	eb 44                	jmp    80105a4c <kill+0x83>
	    if(p->pid == pid){
80105a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0b:	8b 50 10             	mov    0x10(%eax),%edx
80105a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a11:	39 c2                	cmp    %eax,%edx
80105a13:	75 2b                	jne    80105a40 <kill+0x77>
	      found = 1;
80105a15:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	      p->killed = 1;
80105a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	      release(&ptable.lock);
80105a26:	83 ec 0c             	sub    $0xc,%esp
80105a29:	68 80 49 11 80       	push   $0x80114980
80105a2e:	e8 cb 10 00 00       	call   80106afe <release>
80105a33:	83 c4 10             	add    $0x10,%esp
	      return 0;
80105a36:	b8 00 00 00 00       	mov    $0x0,%eax
80105a3b:	e9 a6 01 00 00       	jmp    80105be6 <kill+0x21d>
	    }

	    p = p -> next;
80105a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a43:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(!found){

    for(int i = 0; i < MAX+1; ++i){
	p = ptable.pLists.ready[i];		//Change to priority queue

	while(p && !found){
80105a4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a50:	74 06                	je     80105a58 <kill+0x8f>
80105a52:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105a56:	74 b0                	je     80105a08 <kill+0x3f>
  struct proc *p;
  int found = 0;
  acquire(&ptable.lock);
  while(!found){

    for(int i = 0; i < MAX+1; ++i){
80105a58:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105a5c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80105a60:	7e 92                	jle    801059f4 <kill+0x2b>

	    p = p -> next;
	}
    }

    p = ptable.pLists.running;
80105a62:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80105a67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105a6a:	eb 44                	jmp    80105ab0 <kill+0xe7>
	if(p->pid == pid){
80105a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6f:	8b 50 10             	mov    0x10(%eax),%edx
80105a72:	8b 45 08             	mov    0x8(%ebp),%eax
80105a75:	39 c2                	cmp    %eax,%edx
80105a77:	75 2b                	jne    80105aa4 <kill+0xdb>
	  found = 1;
80105a79:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a83:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	  release(&ptable.lock);
80105a8a:	83 ec 0c             	sub    $0xc,%esp
80105a8d:	68 80 49 11 80       	push   $0x80114980
80105a92:	e8 67 10 00 00       	call   80106afe <release>
80105a97:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105a9a:	b8 00 00 00 00       	mov    $0x0,%eax
80105a9f:	e9 42 01 00 00       	jmp    80105be6 <kill+0x21d>
	}
	p = p -> next;
80105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105aad:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    p = p -> next;
	}
    }

    p = ptable.pLists.running;
    while(p && !found){
80105ab0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab4:	74 06                	je     80105abc <kill+0xf3>
80105ab6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105aba:	74 b0                	je     80105a6c <kill+0xa3>
	  return 0;
	}
	p = p -> next;
    }

    p = ptable.pLists.embryo;
80105abc:	a1 d8 70 11 80       	mov    0x801170d8,%eax
80105ac1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105ac4:	eb 44                	jmp    80105b0a <kill+0x141>
	if(p->pid == pid){
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	8b 50 10             	mov    0x10(%eax),%edx
80105acc:	8b 45 08             	mov    0x8(%ebp),%eax
80105acf:	39 c2                	cmp    %eax,%edx
80105ad1:	75 2b                	jne    80105afe <kill+0x135>
	  found = 1;
80105ad3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105add:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
          release(&ptable.lock);
80105ae4:	83 ec 0c             	sub    $0xc,%esp
80105ae7:	68 80 49 11 80       	push   $0x80114980
80105aec:	e8 0d 10 00 00       	call   80106afe <release>
80105af1:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105af4:	b8 00 00 00 00       	mov    $0x0,%eax
80105af9:	e9 e8 00 00 00       	jmp    80105be6 <kill+0x21d>
	}
	p = p -> next;
80105afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b01:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b07:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	p = p -> next;
    }

    p = ptable.pLists.embryo;
    while(p && !found){
80105b0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b0e:	74 06                	je     80105b16 <kill+0x14d>
80105b10:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b14:	74 b0                	je     80105ac6 <kill+0xfd>
	  return 0;
	}
	p = p -> next;
    }

    p = ptable.pLists.sleep;
80105b16:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80105b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105b1e:	e9 94 00 00 00       	jmp    80105bb7 <kill+0x1ee>
	if(p->pid == pid){
80105b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b26:	8b 50 10             	mov    0x10(%eax),%edx
80105b29:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2c:	39 c2                	cmp    %eax,%edx
80105b2e:	75 7b                	jne    80105bab <kill+0x1e2>
	  found = 1;
80105b30:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	  assertStateSleep(p);
80105b41:	83 ec 0c             	sub    $0xc,%esp
80105b44:	ff 75 f4             	pushl  -0xc(%ebp)
80105b47:	e8 36 ea ff ff       	call   80104582 <assertStateSleep>
80105b4c:	83 c4 10             	add    $0x10,%esp
	  removeFromStateList(&ptable.pLists.sleep, p);
80105b4f:	83 ec 08             	sub    $0x8,%esp
80105b52:	ff 75 f4             	pushl  -0xc(%ebp)
80105b55:	68 cc 70 11 80       	push   $0x801170cc
80105b5a:	e8 4d eb ff ff       	call   801046ac <removeFromStateList>
80105b5f:	83 c4 10             	add    $0x10,%esp
	  p->state = RUNNABLE;
80105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b65:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);	//Change to priority queue
80105b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6f:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105b75:	05 cc 09 00 00       	add    $0x9cc,%eax
80105b7a:	c1 e0 02             	shl    $0x2,%eax
80105b7d:	05 80 49 11 80       	add    $0x80114980,%eax
80105b82:	83 c0 04             	add    $0x4,%eax
80105b85:	83 ec 08             	sub    $0x8,%esp
80105b88:	ff 75 f4             	pushl  -0xc(%ebp)
80105b8b:	50                   	push   %eax
80105b8c:	e8 33 ea ff ff       	call   801045c4 <addToStateListEnd>
80105b91:	83 c4 10             	add    $0x10,%esp

	  release(&ptable.lock);
80105b94:	83 ec 0c             	sub    $0xc,%esp
80105b97:	68 80 49 11 80       	push   $0x80114980
80105b9c:	e8 5d 0f 00 00       	call   80106afe <release>
80105ba1:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105ba4:	b8 00 00 00 00       	mov    $0x0,%eax
80105ba9:	eb 3b                	jmp    80105be6 <kill+0x21d>

	}
	p = p -> next;
80105bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bae:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	p = p -> next;
    }

    p = ptable.pLists.sleep;
    while(p && !found){
80105bb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bbb:	74 0a                	je     80105bc7 <kill+0x1fe>
80105bbd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105bc1:	0f 84 5c ff ff ff    	je     80105b23 <kill+0x15a>
kill(int pid)
{
  struct proc *p;
  int found = 0;
  acquire(&ptable.lock);
  while(!found){
80105bc7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105bcb:	0f 84 1a fe ff ff    	je     801059eb <kill+0x22>
	}
	p = p -> next;
    }
  }

  release(&ptable.lock);
80105bd1:	83 ec 0c             	sub    $0xc,%esp
80105bd4:	68 80 49 11 80       	push   $0x80114980
80105bd9:	e8 20 0f 00 00       	call   80106afe <release>
80105bde:	83 c4 10             	add    $0x10,%esp
  return -1;
80105be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  

}
80105be6:	c9                   	leave  
80105be7:	c3                   	ret    

80105be8 <procdump>:
    release(&ptable.lock);
}
#else
void
procdump(void)
{
80105be8:	55                   	push   %ebp
80105be9:	89 e5                	mov    %esp,%ebp
80105beb:	57                   	push   %edi
80105bec:	56                   	push   %esi
80105bed:	53                   	push   %ebx
80105bee:	83 ec 5c             	sub    $0x5c,%esp
  int i;
  struct proc *p;
  uint pc[10];
  
    cprintf("PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
80105bf1:	83 ec 0c             	sub    $0xc,%esp
80105bf4:	68 c0 a6 10 80       	push   $0x8010a6c0
80105bf9:	e8 c8 a7 ff ff       	call   801003c6 <cprintf>
80105bfe:	83 c4 10             	add    $0x10,%esp


    acquire(&ptable.lock);
80105c01:	83 ec 0c             	sub    $0xc,%esp
80105c04:	68 80 49 11 80       	push   $0x80114980
80105c09:	e8 89 0e 00 00       	call   80106a97 <acquire>
80105c0e:	83 c4 10             	add    $0x10,%esp

    char *state = "???";
80105c11:	c7 45 dc f8 a6 10 80 	movl   $0x8010a6f8,-0x24(%ebp)
    while(0)
80105c18:	90                   	nop
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105c19:	c7 45 e0 b4 49 11 80 	movl   $0x801149b4,-0x20(%ebp)
80105c20:	e9 7f 03 00 00       	jmp    80105fa4 <procdump+0x3bc>
    if(p->state == UNUSED)
80105c25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c28:	8b 40 0c             	mov    0xc(%eax),%eax
80105c2b:	85 c0                	test   %eax,%eax
80105c2d:	0f 84 69 03 00 00    	je     80105f9c <procdump+0x3b4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105c33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c36:	8b 40 0c             	mov    0xc(%eax),%eax
80105c39:	83 f8 05             	cmp    $0x5,%eax
80105c3c:	77 21                	ja     80105c5f <procdump+0x77>
80105c3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c41:	8b 40 0c             	mov    0xc(%eax),%eax
80105c44:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105c4b:	85 c0                	test   %eax,%eax
80105c4d:	74 10                	je     80105c5f <procdump+0x77>
      state = states[p->state];
80105c4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c52:	8b 40 0c             	mov    0xc(%eax),%eax
80105c55:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105c5c:	89 45 dc             	mov    %eax,-0x24(%ebp)

    int  elapsed, milli, cpue, cpum;

    elapsed = (ticks - p -> start_ticks)/1000;
80105c5f:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c68:	8b 40 7c             	mov    0x7c(%eax),%eax
80105c6b:	29 c2                	sub    %eax,%edx
80105c6d:	89 d0                	mov    %edx,%eax
80105c6f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105c74:	f7 e2                	mul    %edx
80105c76:	89 d0                	mov    %edx,%eax
80105c78:	c1 e8 06             	shr    $0x6,%eax
80105c7b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    milli = (ticks - p -> start_ticks)%1000;
80105c7e:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105c84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105c87:	8b 40 7c             	mov    0x7c(%eax),%eax
80105c8a:	89 d1                	mov    %edx,%ecx
80105c8c:	29 c1                	sub    %eax,%ecx
80105c8e:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105c93:	89 c8                	mov    %ecx,%eax
80105c95:	f7 e2                	mul    %edx
80105c97:	89 d0                	mov    %edx,%eax
80105c99:	c1 e8 06             	shr    $0x6,%eax
80105c9c:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105ca2:	29 c1                	sub    %eax,%ecx
80105ca4:	89 c8                	mov    %ecx,%eax
80105ca6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cpue = (p -> cpu_ticks_total)/1000;
80105ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105cac:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105cb2:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105cb7:	f7 e2                	mul    %edx
80105cb9:	89 d0                	mov    %edx,%eax
80105cbb:	c1 e8 06             	shr    $0x6,%eax
80105cbe:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cpum = (p -> cpu_ticks_total)%1000;
80105cc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105cc4:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80105cca:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105ccf:	89 c8                	mov    %ecx,%eax
80105cd1:	f7 e2                	mul    %edx
80105cd3:	89 d0                	mov    %edx,%eax
80105cd5:	c1 e8 06             	shr    $0x6,%eax
80105cd8:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105cde:	29 c1                	sub    %eax,%ecx
80105ce0:	89 c8                	mov    %ecx,%eax
80105ce2:	89 45 cc             	mov    %eax,-0x34(%ebp)

    if(p -> pid == 1){
80105ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ce8:	8b 40 10             	mov    0x10(%eax),%eax
80105ceb:	83 f8 01             	cmp    $0x1,%eax
80105cee:	0f 85 1c 01 00 00    	jne    80105e10 <procdump+0x228>
	cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,1,p -> priority, elapsed);
80105cf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105cf7:	8b 98 94 00 00 00    	mov    0x94(%eax),%ebx
80105cfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105d00:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105d06:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105d09:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105d12:	8d 70 6c             	lea    0x6c(%eax),%esi
80105d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105d18:	8b 40 10             	mov    0x10(%eax),%eax
80105d1b:	ff 75 d8             	pushl  -0x28(%ebp)
80105d1e:	53                   	push   %ebx
80105d1f:	6a 01                	push   $0x1
80105d21:	51                   	push   %ecx
80105d22:	52                   	push   %edx
80105d23:	56                   	push   %esi
80105d24:	50                   	push   %eax
80105d25:	68 fc a6 10 80       	push   $0x8010a6fc
80105d2a:	e8 97 a6 ff ff       	call   801003c6 <cprintf>
80105d2f:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
80105d32:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105d36:	7f 16                	jg     80105d4e <procdump+0x166>
	    cprintf("00%d\t%d.", milli, cpue);
80105d38:	83 ec 04             	sub    $0x4,%esp
80105d3b:	ff 75 d0             	pushl  -0x30(%ebp)
80105d3e:	ff 75 d4             	pushl  -0x2c(%ebp)
80105d41:	68 12 a7 10 80       	push   $0x8010a712
80105d46:	e8 7b a6 ff ff       	call   801003c6 <cprintf>
80105d4b:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
80105d4e:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105d52:	7e 1c                	jle    80105d70 <procdump+0x188>
80105d54:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
80105d58:	7f 16                	jg     80105d70 <procdump+0x188>
	    cprintf("0%d\t%d.", milli, cpue);
80105d5a:	83 ec 04             	sub    $0x4,%esp
80105d5d:	ff 75 d0             	pushl  -0x30(%ebp)
80105d60:	ff 75 d4             	pushl  -0x2c(%ebp)
80105d63:	68 1b a7 10 80       	push   $0x8010a71b
80105d68:	e8 59 a6 ff ff       	call   801003c6 <cprintf>
80105d6d:	83 c4 10             	add    $0x10,%esp
	if(milli > 100)
80105d70:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
80105d74:	7e 16                	jle    80105d8c <procdump+0x1a4>
	    cprintf("%d\t%d.", milli, cpue);
80105d76:	83 ec 04             	sub    $0x4,%esp
80105d79:	ff 75 d0             	pushl  -0x30(%ebp)
80105d7c:	ff 75 d4             	pushl  -0x2c(%ebp)
80105d7f:	68 23 a7 10 80       	push   $0x8010a723
80105d84:	e8 3d a6 ff ff       	call   801003c6 <cprintf>
80105d89:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80105d8c:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105d90:	7f 21                	jg     80105db3 <procdump+0x1cb>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105d95:	8b 00                	mov    (%eax),%eax
80105d97:	83 ec 0c             	sub    $0xc,%esp
80105d9a:	68 2a a7 10 80       	push   $0x8010a72a
80105d9f:	50                   	push   %eax
80105da0:	ff 75 dc             	pushl  -0x24(%ebp)
80105da3:	ff 75 cc             	pushl  -0x34(%ebp)
80105da6:	68 2c a7 10 80       	push   $0x8010a72c
80105dab:	e8 16 a6 ff ff       	call   801003c6 <cprintf>
80105db0:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
80105db3:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105db7:	7e 27                	jle    80105de0 <procdump+0x1f8>
80105db9:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
80105dbd:	7f 21                	jg     80105de0 <procdump+0x1f8>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105dbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105dc2:	8b 00                	mov    (%eax),%eax
80105dc4:	83 ec 0c             	sub    $0xc,%esp
80105dc7:	68 2a a7 10 80       	push   $0x8010a72a
80105dcc:	50                   	push   %eax
80105dcd:	ff 75 dc             	pushl  -0x24(%ebp)
80105dd0:	ff 75 cc             	pushl  -0x34(%ebp)
80105dd3:	68 38 a7 10 80       	push   $0x8010a738
80105dd8:	e8 e9 a5 ff ff       	call   801003c6 <cprintf>
80105ddd:	83 c4 20             	add    $0x20,%esp
	if(cpum > 100)
80105de0:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
80105de4:	0f 8e 41 01 00 00    	jle    80105f2b <procdump+0x343>
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105dea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ded:	8b 00                	mov    (%eax),%eax
80105def:	83 ec 0c             	sub    $0xc,%esp
80105df2:	68 2a a7 10 80       	push   $0x8010a72a
80105df7:	50                   	push   %eax
80105df8:	ff 75 dc             	pushl  -0x24(%ebp)
80105dfb:	ff 75 cc             	pushl  -0x34(%ebp)
80105dfe:	68 43 a7 10 80       	push   $0x8010a743
80105e03:	e8 be a5 ff ff       	call   801003c6 <cprintf>
80105e08:	83 c4 20             	add    $0x20,%esp
80105e0b:	e9 1b 01 00 00       	jmp    80105f2b <procdump+0x343>
    }
    else{
	cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid, p -> priority, elapsed);
80105e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e13:	8b b0 94 00 00 00    	mov    0x94(%eax),%esi
80105e19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e1c:	8b 40 14             	mov    0x14(%eax),%eax
80105e1f:	8b 58 10             	mov    0x10(%eax),%ebx
80105e22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e25:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e2e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e37:	8d 78 6c             	lea    0x6c(%eax),%edi
80105e3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e3d:	8b 40 10             	mov    0x10(%eax),%eax
80105e40:	ff 75 d8             	pushl  -0x28(%ebp)
80105e43:	56                   	push   %esi
80105e44:	53                   	push   %ebx
80105e45:	51                   	push   %ecx
80105e46:	52                   	push   %edx
80105e47:	57                   	push   %edi
80105e48:	50                   	push   %eax
80105e49:	68 fc a6 10 80       	push   $0x8010a6fc
80105e4e:	e8 73 a5 ff ff       	call   801003c6 <cprintf>
80105e53:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
80105e56:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105e5a:	7f 16                	jg     80105e72 <procdump+0x28a>
	    cprintf("00%d\t%d.", milli, cpue);
80105e5c:	83 ec 04             	sub    $0x4,%esp
80105e5f:	ff 75 d0             	pushl  -0x30(%ebp)
80105e62:	ff 75 d4             	pushl  -0x2c(%ebp)
80105e65:	68 12 a7 10 80       	push   $0x8010a712
80105e6a:	e8 57 a5 ff ff       	call   801003c6 <cprintf>
80105e6f:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
80105e72:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105e76:	7e 1c                	jle    80105e94 <procdump+0x2ac>
80105e78:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
80105e7c:	7f 16                	jg     80105e94 <procdump+0x2ac>
	    cprintf("0%d\t%d.", milli, cpue);
80105e7e:	83 ec 04             	sub    $0x4,%esp
80105e81:	ff 75 d0             	pushl  -0x30(%ebp)
80105e84:	ff 75 d4             	pushl  -0x2c(%ebp)
80105e87:	68 1b a7 10 80       	push   $0x8010a71b
80105e8c:	e8 35 a5 ff ff       	call   801003c6 <cprintf>
80105e91:	83 c4 10             	add    $0x10,%esp
	if(milli > 100)
80105e94:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
80105e98:	7e 16                	jle    80105eb0 <procdump+0x2c8>
	    cprintf("%d\t%d.", milli, cpue);
80105e9a:	83 ec 04             	sub    $0x4,%esp
80105e9d:	ff 75 d0             	pushl  -0x30(%ebp)
80105ea0:	ff 75 d4             	pushl  -0x2c(%ebp)
80105ea3:	68 23 a7 10 80       	push   $0x8010a723
80105ea8:	e8 19 a5 ff ff       	call   801003c6 <cprintf>
80105ead:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80105eb0:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105eb4:	7f 21                	jg     80105ed7 <procdump+0x2ef>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105eb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105eb9:	8b 00                	mov    (%eax),%eax
80105ebb:	83 ec 0c             	sub    $0xc,%esp
80105ebe:	68 2a a7 10 80       	push   $0x8010a72a
80105ec3:	50                   	push   %eax
80105ec4:	ff 75 dc             	pushl  -0x24(%ebp)
80105ec7:	ff 75 cc             	pushl  -0x34(%ebp)
80105eca:	68 2c a7 10 80       	push   $0x8010a72c
80105ecf:	e8 f2 a4 ff ff       	call   801003c6 <cprintf>
80105ed4:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
80105ed7:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105edb:	7e 27                	jle    80105f04 <procdump+0x31c>
80105edd:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
80105ee1:	7f 21                	jg     80105f04 <procdump+0x31c>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ee6:	8b 00                	mov    (%eax),%eax
80105ee8:	83 ec 0c             	sub    $0xc,%esp
80105eeb:	68 2a a7 10 80       	push   $0x8010a72a
80105ef0:	50                   	push   %eax
80105ef1:	ff 75 dc             	pushl  -0x24(%ebp)
80105ef4:	ff 75 cc             	pushl  -0x34(%ebp)
80105ef7:	68 38 a7 10 80       	push   $0x8010a738
80105efc:	e8 c5 a4 ff ff       	call   801003c6 <cprintf>
80105f01:	83 c4 20             	add    $0x20,%esp
	if(cpum > 100)
80105f04:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
80105f08:	7e 21                	jle    80105f2b <procdump+0x343>
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f0d:	8b 00                	mov    (%eax),%eax
80105f0f:	83 ec 0c             	sub    $0xc,%esp
80105f12:	68 2a a7 10 80       	push   $0x8010a72a
80105f17:	50                   	push   %eax
80105f18:	ff 75 dc             	pushl  -0x24(%ebp)
80105f1b:	ff 75 cc             	pushl  -0x34(%ebp)
80105f1e:	68 43 a7 10 80       	push   $0x8010a743
80105f23:	e8 9e a4 ff ff       	call   801003c6 <cprintf>
80105f28:	83 c4 20             	add    $0x20,%esp
    }
    if(p->state == SLEEPING){
80105f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f2e:	8b 40 0c             	mov    0xc(%eax),%eax
80105f31:	83 f8 02             	cmp    $0x2,%eax
80105f34:	75 54                	jne    80105f8a <procdump+0x3a2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105f36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f39:	8b 40 1c             	mov    0x1c(%eax),%eax
80105f3c:	8b 40 0c             	mov    0xc(%eax),%eax
80105f3f:	83 c0 08             	add    $0x8,%eax
80105f42:	89 c2                	mov    %eax,%edx
80105f44:	83 ec 08             	sub    $0x8,%esp
80105f47:	8d 45 a4             	lea    -0x5c(%ebp),%eax
80105f4a:	50                   	push   %eax
80105f4b:	52                   	push   %edx
80105f4c:	e8 ff 0b 00 00       	call   80106b50 <getcallerpcs>
80105f51:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105f54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105f5b:	eb 1c                	jmp    80105f79 <procdump+0x391>
        cprintf(" %p", pc[i]);
80105f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f60:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
80105f64:	83 ec 08             	sub    $0x8,%esp
80105f67:	50                   	push   %eax
80105f68:	68 4d a7 10 80       	push   $0x8010a74d
80105f6d:	e8 54 a4 ff ff       	call   801003c6 <cprintf>
80105f72:	83 c4 10             	add    $0x10,%esp
	if(cpum > 100)
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105f75:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105f79:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
80105f7d:	7f 0b                	jg     80105f8a <procdump+0x3a2>
80105f7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f82:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
80105f86:	85 c0                	test   %eax,%eax
80105f88:	75 d3                	jne    80105f5d <procdump+0x375>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105f8a:	83 ec 0c             	sub    $0xc,%esp
80105f8d:	68 2a a7 10 80       	push   $0x8010a72a
80105f92:	e8 2f a4 ff ff       	call   801003c6 <cprintf>
80105f97:	83 c4 10             	add    $0x10,%esp
80105f9a:	eb 01                	jmp    80105f9d <procdump+0x3b5>
    while(0)
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105f9c:	90                   	nop

    char *state = "???";
    while(0)
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105f9d:	81 45 e0 9c 00 00 00 	addl   $0x9c,-0x20(%ebp)
80105fa4:	81 7d e0 b4 70 11 80 	cmpl   $0x801170b4,-0x20(%ebp)
80105fab:	0f 82 74 fc ff ff    	jb     80105c25 <procdump+0x3d>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

    cprintf("\n");
80105fb1:	83 ec 0c             	sub    $0xc,%esp
80105fb4:	68 2a a7 10 80       	push   $0x8010a72a
80105fb9:	e8 08 a4 ff ff       	call   801003c6 <cprintf>
80105fbe:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80105fc1:	83 ec 0c             	sub    $0xc,%esp
80105fc4:	68 80 49 11 80       	push   $0x80114980
80105fc9:	e8 30 0b 00 00       	call   80106afe <release>
80105fce:	83 c4 10             	add    $0x10,%esp
}
80105fd1:	90                   	nop
80105fd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105fd5:	5b                   	pop    %ebx
80105fd6:	5e                   	pop    %esi
80105fd7:	5f                   	pop    %edi
80105fd8:	5d                   	pop    %ebp
80105fd9:	c3                   	ret    

80105fda <getproctable>:
}

#else
int 
getproctable(uint max, struct uproc* table)
{
80105fda:	55                   	push   %ebp
80105fdb:	89 e5                	mov    %esp,%ebp
80105fdd:	53                   	push   %ebx
80105fde:	83 ec 14             	sub    $0x14,%esp
    int i = 0;
80105fe1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	68 80 49 11 80       	push   $0x80114980
80105ff0:	e8 a2 0a 00 00       	call   80106a97 <acquire>
80105ff5:	83 c4 10             	add    $0x10,%esp

    for(int j = 0; j < MAX+1; ++j){
80105ff8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105fff:	e9 ca 01 00 00       	jmp    801061ce <getproctable+0x1f4>
	p = ptable.pLists.ready[j];
80106004:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106007:	05 cc 09 00 00       	add    $0x9cc,%eax
8010600c:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106013:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(p){	
80106016:	e9 a5 01 00 00       	jmp    801061c0 <getproctable+0x1e6>
	    table[i].pid = p -> pid;
8010601b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010601e:	89 d0                	mov    %edx,%eax
80106020:	01 c0                	add    %eax,%eax
80106022:	01 d0                	add    %edx,%eax
80106024:	c1 e0 05             	shl    $0x5,%eax
80106027:	89 c2                	mov    %eax,%edx
80106029:	8b 45 0c             	mov    0xc(%ebp),%eax
8010602c:	01 c2                	add    %eax,%edx
8010602e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106031:	8b 40 10             	mov    0x10(%eax),%eax
80106034:	89 02                	mov    %eax,(%edx)
	    table[i].uid = p -> uid;
80106036:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106039:	89 d0                	mov    %edx,%eax
8010603b:	01 c0                	add    %eax,%eax
8010603d:	01 d0                	add    %edx,%eax
8010603f:	c1 e0 05             	shl    $0x5,%eax
80106042:	89 c2                	mov    %eax,%edx
80106044:	8b 45 0c             	mov    0xc(%ebp),%eax
80106047:	01 c2                	add    %eax,%edx
80106049:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106052:	89 42 04             	mov    %eax,0x4(%edx)
	    table[i].gid = p -> gid;
80106055:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106058:	89 d0                	mov    %edx,%eax
8010605a:	01 c0                	add    %eax,%eax
8010605c:	01 d0                	add    %edx,%eax
8010605e:	c1 e0 05             	shl    $0x5,%eax
80106061:	89 c2                	mov    %eax,%edx
80106063:	8b 45 0c             	mov    0xc(%ebp),%eax
80106066:	01 c2                	add    %eax,%edx
80106068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106071:	89 42 08             	mov    %eax,0x8(%edx)
	    table[i].priority = p -> priority;
80106074:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106077:	89 d0                	mov    %edx,%eax
80106079:	01 c0                	add    %eax,%eax
8010607b:	01 d0                	add    %edx,%eax
8010607d:	c1 e0 05             	shl    $0x5,%eax
80106080:	89 c2                	mov    %eax,%edx
80106082:	8b 45 0c             	mov    0xc(%ebp),%eax
80106085:	01 c2                	add    %eax,%edx
80106087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106090:	89 42 5c             	mov    %eax,0x5c(%edx)

	    if(p -> pid == 1)
80106093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106096:	8b 40 10             	mov    0x10(%eax),%eax
80106099:	83 f8 01             	cmp    $0x1,%eax
8010609c:	75 1c                	jne    801060ba <getproctable+0xe0>
		table[i].ppid = 1;
8010609e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060a1:	89 d0                	mov    %edx,%eax
801060a3:	01 c0                	add    %eax,%eax
801060a5:	01 d0                	add    %edx,%eax
801060a7:	c1 e0 05             	shl    $0x5,%eax
801060aa:	89 c2                	mov    %eax,%edx
801060ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801060af:	01 d0                	add    %edx,%eax
801060b1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
801060b8:	eb 1f                	jmp    801060d9 <getproctable+0xff>
	    else
		table[i].ppid = p -> parent -> pid;
801060ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060bd:	89 d0                	mov    %edx,%eax
801060bf:	01 c0                	add    %eax,%eax
801060c1:	01 d0                	add    %edx,%eax
801060c3:	c1 e0 05             	shl    $0x5,%eax
801060c6:	89 c2                	mov    %eax,%edx
801060c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801060cb:	01 c2                	add    %eax,%edx
801060cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d0:	8b 40 14             	mov    0x14(%eax),%eax
801060d3:	8b 40 10             	mov    0x10(%eax),%eax
801060d6:	89 42 0c             	mov    %eax,0xc(%edx)
		
	    table[i].elapsed_ticks = ticks - (p -> start_ticks);
801060d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060dc:	89 d0                	mov    %edx,%eax
801060de:	01 c0                	add    %eax,%eax
801060e0:	01 d0                	add    %edx,%eax
801060e2:	c1 e0 05             	shl    $0x5,%eax
801060e5:	89 c2                	mov    %eax,%edx
801060e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ea:	01 c2                	add    %eax,%edx
801060ec:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
801060f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f5:	8b 40 7c             	mov    0x7c(%eax),%eax
801060f8:	29 c1                	sub    %eax,%ecx
801060fa:	89 c8                	mov    %ecx,%eax
801060fc:	89 42 10             	mov    %eax,0x10(%edx)

	    table[i].CPU_total_ticks = p -> cpu_ticks_total;
801060ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106102:	89 d0                	mov    %edx,%eax
80106104:	01 c0                	add    %eax,%eax
80106106:	01 d0                	add    %edx,%eax
80106108:	c1 e0 05             	shl    $0x5,%eax
8010610b:	89 c2                	mov    %eax,%edx
8010610d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106110:	01 c2                	add    %eax,%edx
80106112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106115:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010611b:	89 42 14             	mov    %eax,0x14(%edx)

	    safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
8010611e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106121:	8b 40 0c             	mov    0xc(%eax),%eax
80106124:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
8010612b:	83 ec 0c             	sub    $0xc,%esp
8010612e:	50                   	push   %eax
8010612f:	e8 13 0e 00 00       	call   80106f47 <strlen>
80106134:	83 c4 10             	add    $0x10,%esp
80106137:	89 c3                	mov    %eax,%ebx
80106139:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613c:	8b 40 0c             	mov    0xc(%eax),%eax
8010613f:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
80106146:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106149:	89 d0                	mov    %edx,%eax
8010614b:	01 c0                	add    %eax,%eax
8010614d:	01 d0                	add    %edx,%eax
8010614f:	c1 e0 05             	shl    $0x5,%eax
80106152:	89 c2                	mov    %eax,%edx
80106154:	8b 45 0c             	mov    0xc(%ebp),%eax
80106157:	01 d0                	add    %edx,%eax
80106159:	83 c0 18             	add    $0x18,%eax
8010615c:	83 ec 04             	sub    $0x4,%esp
8010615f:	53                   	push   %ebx
80106160:	51                   	push   %ecx
80106161:	50                   	push   %eax
80106162:	e8 96 0d 00 00       	call   80106efd <safestrcpy>
80106167:	83 c4 10             	add    $0x10,%esp

	    table[i].size = p -> sz;
8010616a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010616d:	89 d0                	mov    %edx,%eax
8010616f:	01 c0                	add    %eax,%eax
80106171:	01 d0                	add    %edx,%eax
80106173:	c1 e0 05             	shl    $0x5,%eax
80106176:	89 c2                	mov    %eax,%edx
80106178:	8b 45 0c             	mov    0xc(%ebp),%eax
8010617b:	01 c2                	add    %eax,%edx
8010617d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106180:	8b 00                	mov    (%eax),%eax
80106182:	89 42 38             	mov    %eax,0x38(%edx)

	    safestrcpy(table[i].name,p -> name, STRMAX);
80106185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106188:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010618b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010618e:	89 d0                	mov    %edx,%eax
80106190:	01 c0                	add    %eax,%eax
80106192:	01 d0                	add    %edx,%eax
80106194:	c1 e0 05             	shl    $0x5,%eax
80106197:	89 c2                	mov    %eax,%edx
80106199:	8b 45 0c             	mov    0xc(%ebp),%eax
8010619c:	01 d0                	add    %edx,%eax
8010619e:	83 c0 3c             	add    $0x3c,%eax
801061a1:	83 ec 04             	sub    $0x4,%esp
801061a4:	6a 20                	push   $0x20
801061a6:	51                   	push   %ecx
801061a7:	50                   	push   %eax
801061a8:	e8 50 0d 00 00       	call   80106efd <safestrcpy>
801061ad:	83 c4 10             	add    $0x10,%esp
	    p = p -> next;
801061b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801061b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    ++i;
801061bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    //acquire lock
    acquire(&ptable.lock);

    for(int j = 0; j < MAX+1; ++j){
	p = ptable.pLists.ready[j];
	while(p){	
801061c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c4:	0f 85 51 fe ff ff    	jne    8010601b <getproctable+0x41>
    int i = 0;
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);

    for(int j = 0; j < MAX+1; ++j){
801061ca:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801061ce:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
801061d2:	0f 8e 2c fe ff ff    	jle    80106004 <getproctable+0x2a>
	    safestrcpy(table[i].name,p -> name, STRMAX);
	    p = p -> next;
	    ++i;
	}
    }
    p = ptable.pLists.sleep;
801061d8:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801061dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(p){	
801061e0:	e9 a5 01 00 00       	jmp    8010638a <getproctable+0x3b0>
	table[i].pid = p -> pid;
801061e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061e8:	89 d0                	mov    %edx,%eax
801061ea:	01 c0                	add    %eax,%eax
801061ec:	01 d0                	add    %edx,%eax
801061ee:	c1 e0 05             	shl    $0x5,%eax
801061f1:	89 c2                	mov    %eax,%edx
801061f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801061f6:	01 c2                	add    %eax,%edx
801061f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fb:	8b 40 10             	mov    0x10(%eax),%eax
801061fe:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
80106200:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106203:	89 d0                	mov    %edx,%eax
80106205:	01 c0                	add    %eax,%eax
80106207:	01 d0                	add    %edx,%eax
80106209:	c1 e0 05             	shl    $0x5,%eax
8010620c:	89 c2                	mov    %eax,%edx
8010620e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106211:	01 c2                	add    %eax,%edx
80106213:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106216:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010621c:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
8010621f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106222:	89 d0                	mov    %edx,%eax
80106224:	01 c0                	add    %eax,%eax
80106226:	01 d0                	add    %edx,%eax
80106228:	c1 e0 05             	shl    $0x5,%eax
8010622b:	89 c2                	mov    %eax,%edx
8010622d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106230:	01 c2                	add    %eax,%edx
80106232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106235:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010623b:	89 42 08             	mov    %eax,0x8(%edx)
	table[i].priority = p -> priority;
8010623e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106241:	89 d0                	mov    %edx,%eax
80106243:	01 c0                	add    %eax,%eax
80106245:	01 d0                	add    %edx,%eax
80106247:	c1 e0 05             	shl    $0x5,%eax
8010624a:	89 c2                	mov    %eax,%edx
8010624c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010624f:	01 c2                	add    %eax,%edx
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010625a:	89 42 5c             	mov    %eax,0x5c(%edx)

	if(p -> pid == 1)
8010625d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106260:	8b 40 10             	mov    0x10(%eax),%eax
80106263:	83 f8 01             	cmp    $0x1,%eax
80106266:	75 1c                	jne    80106284 <getproctable+0x2aa>
	    table[i].ppid = 1;
80106268:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010626b:	89 d0                	mov    %edx,%eax
8010626d:	01 c0                	add    %eax,%eax
8010626f:	01 d0                	add    %edx,%eax
80106271:	c1 e0 05             	shl    $0x5,%eax
80106274:	89 c2                	mov    %eax,%edx
80106276:	8b 45 0c             	mov    0xc(%ebp),%eax
80106279:	01 d0                	add    %edx,%eax
8010627b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
80106282:	eb 1f                	jmp    801062a3 <getproctable+0x2c9>
	else
	    table[i].ppid = p -> parent -> pid;
80106284:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106287:	89 d0                	mov    %edx,%eax
80106289:	01 c0                	add    %eax,%eax
8010628b:	01 d0                	add    %edx,%eax
8010628d:	c1 e0 05             	shl    $0x5,%eax
80106290:	89 c2                	mov    %eax,%edx
80106292:	8b 45 0c             	mov    0xc(%ebp),%eax
80106295:	01 c2                	add    %eax,%edx
80106297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629a:	8b 40 14             	mov    0x14(%eax),%eax
8010629d:	8b 40 10             	mov    0x10(%eax),%eax
801062a0:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
801062a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062a6:	89 d0                	mov    %edx,%eax
801062a8:	01 c0                	add    %eax,%eax
801062aa:	01 d0                	add    %edx,%eax
801062ac:	c1 e0 05             	shl    $0x5,%eax
801062af:	89 c2                	mov    %eax,%edx
801062b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801062b4:	01 c2                	add    %eax,%edx
801062b6:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
801062bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bf:	8b 40 7c             	mov    0x7c(%eax),%eax
801062c2:	29 c1                	sub    %eax,%ecx
801062c4:	89 c8                	mov    %ecx,%eax
801062c6:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
801062c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062cc:	89 d0                	mov    %edx,%eax
801062ce:	01 c0                	add    %eax,%eax
801062d0:	01 d0                	add    %edx,%eax
801062d2:	c1 e0 05             	shl    $0x5,%eax
801062d5:	89 c2                	mov    %eax,%edx
801062d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801062da:	01 c2                	add    %eax,%edx
801062dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062df:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801062e5:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
801062e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062eb:	8b 40 0c             	mov    0xc(%eax),%eax
801062ee:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801062f5:	83 ec 0c             	sub    $0xc,%esp
801062f8:	50                   	push   %eax
801062f9:	e8 49 0c 00 00       	call   80106f47 <strlen>
801062fe:	83 c4 10             	add    $0x10,%esp
80106301:	89 c3                	mov    %eax,%ebx
80106303:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106306:	8b 40 0c             	mov    0xc(%eax),%eax
80106309:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
80106310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106313:	89 d0                	mov    %edx,%eax
80106315:	01 c0                	add    %eax,%eax
80106317:	01 d0                	add    %edx,%eax
80106319:	c1 e0 05             	shl    $0x5,%eax
8010631c:	89 c2                	mov    %eax,%edx
8010631e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106321:	01 d0                	add    %edx,%eax
80106323:	83 c0 18             	add    $0x18,%eax
80106326:	83 ec 04             	sub    $0x4,%esp
80106329:	53                   	push   %ebx
8010632a:	51                   	push   %ecx
8010632b:	50                   	push   %eax
8010632c:	e8 cc 0b 00 00       	call   80106efd <safestrcpy>
80106331:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
80106334:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106337:	89 d0                	mov    %edx,%eax
80106339:	01 c0                	add    %eax,%eax
8010633b:	01 d0                	add    %edx,%eax
8010633d:	c1 e0 05             	shl    $0x5,%eax
80106340:	89 c2                	mov    %eax,%edx
80106342:	8b 45 0c             	mov    0xc(%ebp),%eax
80106345:	01 c2                	add    %eax,%edx
80106347:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634a:	8b 00                	mov    (%eax),%eax
8010634c:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
8010634f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106352:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106355:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106358:	89 d0                	mov    %edx,%eax
8010635a:	01 c0                	add    %eax,%eax
8010635c:	01 d0                	add    %edx,%eax
8010635e:	c1 e0 05             	shl    $0x5,%eax
80106361:	89 c2                	mov    %eax,%edx
80106363:	8b 45 0c             	mov    0xc(%ebp),%eax
80106366:	01 d0                	add    %edx,%eax
80106368:	83 c0 3c             	add    $0x3c,%eax
8010636b:	83 ec 04             	sub    $0x4,%esp
8010636e:	6a 20                	push   $0x20
80106370:	51                   	push   %ecx
80106371:	50                   	push   %eax
80106372:	e8 86 0b 00 00       	call   80106efd <safestrcpy>
80106377:	83 c4 10             	add    $0x10,%esp
	p = p -> next;
8010637a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106383:	89 45 f0             	mov    %eax,-0x10(%ebp)
	++i;
80106386:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	    p = p -> next;
	    ++i;
	}
    }
    p = ptable.pLists.sleep;
    while(p){	
8010638a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010638e:	0f 85 51 fe ff ff    	jne    801061e5 <getproctable+0x20b>
	safestrcpy(table[i].name,p -> name, STRMAX);
	p = p -> next;
	++i;
    }

    p = ptable.pLists.running;
80106394:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80106399:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(p){	
8010639c:	e9 a5 01 00 00       	jmp    80106546 <getproctable+0x56c>
	table[i].pid = p -> pid;
801063a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063a4:	89 d0                	mov    %edx,%eax
801063a6:	01 c0                	add    %eax,%eax
801063a8:	01 d0                	add    %edx,%eax
801063aa:	c1 e0 05             	shl    $0x5,%eax
801063ad:	89 c2                	mov    %eax,%edx
801063af:	8b 45 0c             	mov    0xc(%ebp),%eax
801063b2:	01 c2                	add    %eax,%edx
801063b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b7:	8b 40 10             	mov    0x10(%eax),%eax
801063ba:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
801063bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063bf:	89 d0                	mov    %edx,%eax
801063c1:	01 c0                	add    %eax,%eax
801063c3:	01 d0                	add    %edx,%eax
801063c5:	c1 e0 05             	shl    $0x5,%eax
801063c8:	89 c2                	mov    %eax,%edx
801063ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801063cd:	01 c2                	add    %eax,%edx
801063cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801063d8:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
801063db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063de:	89 d0                	mov    %edx,%eax
801063e0:	01 c0                	add    %eax,%eax
801063e2:	01 d0                	add    %edx,%eax
801063e4:	c1 e0 05             	shl    $0x5,%eax
801063e7:	89 c2                	mov    %eax,%edx
801063e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801063ec:	01 c2                	add    %eax,%edx
801063ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f1:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801063f7:	89 42 08             	mov    %eax,0x8(%edx)
	table[i].priority = p -> priority;
801063fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063fd:	89 d0                	mov    %edx,%eax
801063ff:	01 c0                	add    %eax,%eax
80106401:	01 d0                	add    %edx,%eax
80106403:	c1 e0 05             	shl    $0x5,%eax
80106406:	89 c2                	mov    %eax,%edx
80106408:	8b 45 0c             	mov    0xc(%ebp),%eax
8010640b:	01 c2                	add    %eax,%edx
8010640d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106410:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106416:	89 42 5c             	mov    %eax,0x5c(%edx)

	if(p -> pid == 1)
80106419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641c:	8b 40 10             	mov    0x10(%eax),%eax
8010641f:	83 f8 01             	cmp    $0x1,%eax
80106422:	75 1c                	jne    80106440 <getproctable+0x466>
	    table[i].ppid = 1;
80106424:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106427:	89 d0                	mov    %edx,%eax
80106429:	01 c0                	add    %eax,%eax
8010642b:	01 d0                	add    %edx,%eax
8010642d:	c1 e0 05             	shl    $0x5,%eax
80106430:	89 c2                	mov    %eax,%edx
80106432:	8b 45 0c             	mov    0xc(%ebp),%eax
80106435:	01 d0                	add    %edx,%eax
80106437:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
8010643e:	eb 1f                	jmp    8010645f <getproctable+0x485>
	else
	    table[i].ppid = p -> parent -> pid;
80106440:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106443:	89 d0                	mov    %edx,%eax
80106445:	01 c0                	add    %eax,%eax
80106447:	01 d0                	add    %edx,%eax
80106449:	c1 e0 05             	shl    $0x5,%eax
8010644c:	89 c2                	mov    %eax,%edx
8010644e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106451:	01 c2                	add    %eax,%edx
80106453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106456:	8b 40 14             	mov    0x14(%eax),%eax
80106459:	8b 40 10             	mov    0x10(%eax),%eax
8010645c:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
8010645f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106462:	89 d0                	mov    %edx,%eax
80106464:	01 c0                	add    %eax,%eax
80106466:	01 d0                	add    %edx,%eax
80106468:	c1 e0 05             	shl    $0x5,%eax
8010646b:	89 c2                	mov    %eax,%edx
8010646d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106470:	01 c2                	add    %eax,%edx
80106472:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
80106478:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647b:	8b 40 7c             	mov    0x7c(%eax),%eax
8010647e:	29 c1                	sub    %eax,%ecx
80106480:	89 c8                	mov    %ecx,%eax
80106482:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
80106485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106488:	89 d0                	mov    %edx,%eax
8010648a:	01 c0                	add    %eax,%eax
8010648c:	01 d0                	add    %edx,%eax
8010648e:	c1 e0 05             	shl    $0x5,%eax
80106491:	89 c2                	mov    %eax,%edx
80106493:	8b 45 0c             	mov    0xc(%ebp),%eax
80106496:	01 c2                	add    %eax,%edx
80106498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801064a1:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
801064a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a7:	8b 40 0c             	mov    0xc(%eax),%eax
801064aa:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801064b1:	83 ec 0c             	sub    $0xc,%esp
801064b4:	50                   	push   %eax
801064b5:	e8 8d 0a 00 00       	call   80106f47 <strlen>
801064ba:	83 c4 10             	add    $0x10,%esp
801064bd:	89 c3                	mov    %eax,%ebx
801064bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c2:	8b 40 0c             	mov    0xc(%eax),%eax
801064c5:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
801064cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064cf:	89 d0                	mov    %edx,%eax
801064d1:	01 c0                	add    %eax,%eax
801064d3:	01 d0                	add    %edx,%eax
801064d5:	c1 e0 05             	shl    $0x5,%eax
801064d8:	89 c2                	mov    %eax,%edx
801064da:	8b 45 0c             	mov    0xc(%ebp),%eax
801064dd:	01 d0                	add    %edx,%eax
801064df:	83 c0 18             	add    $0x18,%eax
801064e2:	83 ec 04             	sub    $0x4,%esp
801064e5:	53                   	push   %ebx
801064e6:	51                   	push   %ecx
801064e7:	50                   	push   %eax
801064e8:	e8 10 0a 00 00       	call   80106efd <safestrcpy>
801064ed:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
801064f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064f3:	89 d0                	mov    %edx,%eax
801064f5:	01 c0                	add    %eax,%eax
801064f7:	01 d0                	add    %edx,%eax
801064f9:	c1 e0 05             	shl    $0x5,%eax
801064fc:	89 c2                	mov    %eax,%edx
801064fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80106501:	01 c2                	add    %eax,%edx
80106503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106506:	8b 00                	mov    (%eax),%eax
80106508:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
8010650b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650e:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106511:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106514:	89 d0                	mov    %edx,%eax
80106516:	01 c0                	add    %eax,%eax
80106518:	01 d0                	add    %edx,%eax
8010651a:	c1 e0 05             	shl    $0x5,%eax
8010651d:	89 c2                	mov    %eax,%edx
8010651f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106522:	01 d0                	add    %edx,%eax
80106524:	83 c0 3c             	add    $0x3c,%eax
80106527:	83 ec 04             	sub    $0x4,%esp
8010652a:	6a 20                	push   $0x20
8010652c:	51                   	push   %ecx
8010652d:	50                   	push   %eax
8010652e:	e8 ca 09 00 00       	call   80106efd <safestrcpy>
80106533:	83 c4 10             	add    $0x10,%esp
	p = p -> next;
80106536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106539:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010653f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	++i;
80106542:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	p = p -> next;
	++i;
    }

    p = ptable.pLists.running;
    while(p){	
80106546:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010654a:	0f 85 51 fe ff ff    	jne    801063a1 <getproctable+0x3c7>
	++i;
    }

   
    //release lock
    release(&ptable.lock);
80106550:	83 ec 0c             	sub    $0xc,%esp
80106553:	68 80 49 11 80       	push   $0x80114980
80106558:	e8 a1 05 00 00       	call   80106afe <release>
8010655d:	83 c4 10             	add    $0x10,%esp
    return i +1;
80106560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106563:	83 c0 01             	add    $0x1,%eax
}
80106566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106569:	c9                   	leave  
8010656a:	c3                   	ret    

8010656b <printready>:


#endif
#ifdef CS333_P3P4
void
printready(void){
8010656b:	55                   	push   %ebp
8010656c:	89 e5                	mov    %esp,%ebp
8010656e:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106571:	83 ec 0c             	sub    $0xc,%esp
80106574:	68 80 49 11 80       	push   $0x80114980
80106579:	e8 19 05 00 00       	call   80106a97 <acquire>
8010657e:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.ready[0];
80106581:	a1 b4 70 11 80       	mov    0x801170b4,%eax
80106586:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Ready List Processes:\n\n");
80106589:	83 ec 0c             	sub    $0xc,%esp
8010658c:	68 51 a7 10 80       	push   $0x8010a751
80106591:	e8 30 9e ff ff       	call   801003c6 <cprintf>
80106596:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < MAX+1; ++i){
80106599:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801065a0:	e9 84 00 00 00       	jmp    80106629 <printready+0xbe>
	current = ptable.pLists.ready[i];
801065a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a8:	05 cc 09 00 00       	add    $0x9cc,%eax
801065ad:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
801065b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("%d:",i);
801065b7:	83 ec 08             	sub    $0x8,%esp
801065ba:	ff 75 f0             	pushl  -0x10(%ebp)
801065bd:	68 69 a7 10 80       	push   $0x8010a769
801065c2:	e8 ff 9d ff ff       	call   801003c6 <cprintf>
801065c7:	83 c4 10             	add    $0x10,%esp

	if(!current)
801065ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065ce:	75 3f                	jne    8010660f <printready+0xa4>
	    cprintf("No Ready Processes\n");
801065d0:	83 ec 0c             	sub    $0xc,%esp
801065d3:	68 6d a7 10 80       	push   $0x8010a76d
801065d8:	e8 e9 9d ff ff       	call   801003c6 <cprintf>
801065dd:	83 c4 10             	add    $0x10,%esp

	while(current){
801065e0:	eb 2d                	jmp    8010660f <printready+0xa4>
	    cprintf("(%d, %d) -> ", current -> pid, current -> budget);
801065e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e5:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
801065eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ee:	8b 40 10             	mov    0x10(%eax),%eax
801065f1:	83 ec 04             	sub    $0x4,%esp
801065f4:	52                   	push   %edx
801065f5:	50                   	push   %eax
801065f6:	68 81 a7 10 80       	push   $0x8010a781
801065fb:	e8 c6 9d ff ff       	call   801003c6 <cprintf>
80106600:	83 c4 10             	add    $0x10,%esp
	    current = current -> next;
80106603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106606:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010660c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("%d:",i);

	if(!current)
	    cprintf("No Ready Processes\n");

	while(current){
8010660f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106613:	75 cd                	jne    801065e2 <printready+0x77>
	    cprintf("(%d, %d) -> ", current -> pid, current -> budget);
	    current = current -> next;
	}
	cprintf("\n");
80106615:	83 ec 0c             	sub    $0xc,%esp
80106618:	68 2a a7 10 80       	push   $0x8010a72a
8010661d:	e8 a4 9d ff ff       	call   801003c6 <cprintf>
80106622:	83 c4 10             	add    $0x10,%esp
printready(void){

    acquire(&ptable.lock);
    struct proc * current = ptable.pLists.ready[0];
    cprintf("Ready List Processes:\n\n");
    for(int i = 0; i < MAX+1; ++i){
80106625:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106629:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010662d:	0f 8e 72 ff ff ff    	jle    801065a5 <printready+0x3a>
	    current = current -> next;
	}
	cprintf("\n");

    }
    release(&ptable.lock);
80106633:	83 ec 0c             	sub    $0xc,%esp
80106636:	68 80 49 11 80       	push   $0x80114980
8010663b:	e8 be 04 00 00       	call   80106afe <release>
80106640:	83 c4 10             	add    $0x10,%esp
}
80106643:	90                   	nop
80106644:	c9                   	leave  
80106645:	c3                   	ret    

80106646 <printfree>:
void
printfree(void){
80106646:	55                   	push   %ebp
80106647:	89 e5                	mov    %esp,%ebp
80106649:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
8010664c:	83 ec 0c             	sub    $0xc,%esp
8010664f:	68 80 49 11 80       	push   $0x80114980
80106654:	e8 3e 04 00 00       	call   80106a97 <acquire>
80106659:	83 c4 10             	add    $0x10,%esp
    int freeprocs = 0;
8010665c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc * current = ptable.pLists.free;
80106663:	a1 c8 70 11 80       	mov    0x801170c8,%eax
80106668:	89 45 f0             	mov    %eax,-0x10(%ebp)

    while(current){
8010666b:	eb 10                	jmp    8010667d <printfree+0x37>
	++freeprocs;
8010666d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	current = current -> next;
80106671:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106674:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010667a:	89 45 f0             	mov    %eax,-0x10(%ebp)

    acquire(&ptable.lock);
    int freeprocs = 0;
    struct proc * current = ptable.pLists.free;

    while(current){
8010667d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106681:	75 ea                	jne    8010666d <printfree+0x27>
	++freeprocs;
	current = current -> next;
    }

    cprintf("Free list size: %d\n", freeprocs);
80106683:	83 ec 08             	sub    $0x8,%esp
80106686:	ff 75 f4             	pushl  -0xc(%ebp)
80106689:	68 8e a7 10 80       	push   $0x8010a78e
8010668e:	e8 33 9d ff ff       	call   801003c6 <cprintf>
80106693:	83 c4 10             	add    $0x10,%esp
    
    cprintf("\n");
80106696:	83 ec 0c             	sub    $0xc,%esp
80106699:	68 2a a7 10 80       	push   $0x8010a72a
8010669e:	e8 23 9d ff ff       	call   801003c6 <cprintf>
801066a3:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
801066a6:	83 ec 0c             	sub    $0xc,%esp
801066a9:	68 80 49 11 80       	push   $0x80114980
801066ae:	e8 4b 04 00 00       	call   80106afe <release>
801066b3:	83 c4 10             	add    $0x10,%esp
}
801066b6:	90                   	nop
801066b7:	c9                   	leave  
801066b8:	c3                   	ret    

801066b9 <printsleep>:
void
printsleep(void){
801066b9:	55                   	push   %ebp
801066ba:	89 e5                	mov    %esp,%ebp
801066bc:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
801066bf:	83 ec 0c             	sub    $0xc,%esp
801066c2:	68 80 49 11 80       	push   $0x80114980
801066c7:	e8 cb 03 00 00       	call   80106a97 <acquire>
801066cc:	83 c4 10             	add    $0x10,%esp
    cprintf("Sleep List Processes:\n");
801066cf:	83 ec 0c             	sub    $0xc,%esp
801066d2:	68 a2 a7 10 80       	push   $0x8010a7a2
801066d7:	e8 ea 9c ff ff       	call   801003c6 <cprintf>
801066dc:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.sleep;
801066df:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801066e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!current)
801066e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066eb:	75 52                	jne    8010673f <printsleep+0x86>
	cprintf("No Sleeping Processes\n");
801066ed:	83 ec 0c             	sub    $0xc,%esp
801066f0:	68 b9 a7 10 80       	push   $0x8010a7b9
801066f5:	e8 cc 9c ff ff       	call   801003c6 <cprintf>
801066fa:	83 c4 10             	add    $0x10,%esp

    while(current){
801066fd:	eb 40                	jmp    8010673f <printsleep+0x86>
	cprintf("%d", current -> pid);
801066ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106702:	8b 40 10             	mov    0x10(%eax),%eax
80106705:	83 ec 08             	sub    $0x8,%esp
80106708:	50                   	push   %eax
80106709:	68 d0 a7 10 80       	push   $0x8010a7d0
8010670e:	e8 b3 9c ff ff       	call   801003c6 <cprintf>
80106713:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
80106716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106719:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010671f:	85 c0                	test   %eax,%eax
80106721:	74 10                	je     80106733 <printsleep+0x7a>
	    cprintf(" -> ");
80106723:	83 ec 0c             	sub    $0xc,%esp
80106726:	68 d3 a7 10 80       	push   $0x8010a7d3
8010672b:	e8 96 9c ff ff       	call   801003c6 <cprintf>
80106730:	83 c4 10             	add    $0x10,%esp
	current = current -> next;
80106733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106736:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010673c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Sleep List Processes:\n");
    struct proc * current = ptable.pLists.sleep;
    if(!current)
	cprintf("No Sleeping Processes\n");

    while(current){
8010673f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106743:	75 ba                	jne    801066ff <printsleep+0x46>
	if(current -> next)
	    cprintf(" -> ");
	current = current -> next;
    }

    cprintf("\n\n");
80106745:	83 ec 0c             	sub    $0xc,%esp
80106748:	68 d8 a7 10 80       	push   $0x8010a7d8
8010674d:	e8 74 9c ff ff       	call   801003c6 <cprintf>
80106752:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80106755:	83 ec 0c             	sub    $0xc,%esp
80106758:	68 80 49 11 80       	push   $0x80114980
8010675d:	e8 9c 03 00 00       	call   80106afe <release>
80106762:	83 c4 10             	add    $0x10,%esp
}
80106765:	90                   	nop
80106766:	c9                   	leave  
80106767:	c3                   	ret    

80106768 <printzombie>:
void
printzombie(void){
80106768:	55                   	push   %ebp
80106769:	89 e5                	mov    %esp,%ebp
8010676b:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
8010676e:	83 ec 0c             	sub    $0xc,%esp
80106771:	68 80 49 11 80       	push   $0x80114980
80106776:	e8 1c 03 00 00       	call   80106a97 <acquire>
8010677b:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.zombie;
8010677e:	a1 d0 70 11 80       	mov    0x801170d0,%eax
80106783:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Zombie List Processes:\n");
80106786:	83 ec 0c             	sub    $0xc,%esp
80106789:	68 db a7 10 80       	push   $0x8010a7db
8010678e:	e8 33 9c ff ff       	call   801003c6 <cprintf>
80106793:	83 c4 10             	add    $0x10,%esp
    if(!current)
80106796:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010679a:	0f 85 a2 00 00 00    	jne    80106842 <printzombie+0xda>
	cprintf("No Zombie Processes\n");
801067a0:	83 ec 0c             	sub    $0xc,%esp
801067a3:	68 f3 a7 10 80       	push   $0x8010a7f3
801067a8:	e8 19 9c ff ff       	call   801003c6 <cprintf>
801067ad:	83 c4 10             	add    $0x10,%esp

    while(current){
801067b0:	e9 8d 00 00 00       	jmp    80106842 <printzombie+0xda>
    if(current -> pid == 1){
801067b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b8:	8b 40 10             	mov    0x10(%eax),%eax
801067bb:	83 f8 01             	cmp    $0x1,%eax
801067be:	75 38                	jne    801067f8 <printzombie+0x90>
	cprintf("(PID%d, PPID%d)",current -> pid, 1);
801067c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c3:	8b 40 10             	mov    0x10(%eax),%eax
801067c6:	83 ec 04             	sub    $0x4,%esp
801067c9:	6a 01                	push   $0x1
801067cb:	50                   	push   %eax
801067cc:	68 08 a8 10 80       	push   $0x8010a808
801067d1:	e8 f0 9b ff ff       	call   801003c6 <cprintf>
801067d6:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
801067d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067dc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067e2:	85 c0                	test   %eax,%eax
801067e4:	74 50                	je     80106836 <printzombie+0xce>
	    cprintf(" -> ");
801067e6:	83 ec 0c             	sub    $0xc,%esp
801067e9:	68 d3 a7 10 80       	push   $0x8010a7d3
801067ee:	e8 d3 9b ff ff       	call   801003c6 <cprintf>
801067f3:	83 c4 10             	add    $0x10,%esp
801067f6:	eb 3e                	jmp    80106836 <printzombie+0xce>
    }
    else{
	cprintf("(PID%d, PPID%d)",current -> pid, current -> parent -> pid);
801067f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fb:	8b 40 14             	mov    0x14(%eax),%eax
801067fe:	8b 50 10             	mov    0x10(%eax),%edx
80106801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106804:	8b 40 10             	mov    0x10(%eax),%eax
80106807:	83 ec 04             	sub    $0x4,%esp
8010680a:	52                   	push   %edx
8010680b:	50                   	push   %eax
8010680c:	68 08 a8 10 80       	push   $0x8010a808
80106811:	e8 b0 9b ff ff       	call   801003c6 <cprintf>
80106816:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
80106819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106822:	85 c0                	test   %eax,%eax
80106824:	74 10                	je     80106836 <printzombie+0xce>
	    cprintf(" -> ");
80106826:	83 ec 0c             	sub    $0xc,%esp
80106829:	68 d3 a7 10 80       	push   $0x8010a7d3
8010682e:	e8 93 9b ff ff       	call   801003c6 <cprintf>
80106833:	83 c4 10             	add    $0x10,%esp
    }
    current = current -> next;	
80106836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106839:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010683f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc * current = ptable.pLists.zombie;
    cprintf("Zombie List Processes:\n");
    if(!current)
	cprintf("No Zombie Processes\n");

    while(current){
80106842:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106846:	0f 85 69 ff ff ff    	jne    801067b5 <printzombie+0x4d>
	if(current -> next)
	    cprintf(" -> ");
    }
    current = current -> next;	
    }
    cprintf("\n\n");
8010684c:	83 ec 0c             	sub    $0xc,%esp
8010684f:	68 d8 a7 10 80       	push   $0x8010a7d8
80106854:	e8 6d 9b ff ff       	call   801003c6 <cprintf>
80106859:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
8010685c:	83 ec 0c             	sub    $0xc,%esp
8010685f:	68 80 49 11 80       	push   $0x80114980
80106864:	e8 95 02 00 00       	call   80106afe <release>
80106869:	83 c4 10             	add    $0x10,%esp
}
8010686c:	90                   	nop
8010686d:	c9                   	leave  
8010686e:	c3                   	ret    

8010686f <setpriority>:
int 
setpriority(int pid, int priority){
8010686f:	55                   	push   %ebp
80106870:	89 e5                	mov    %esp,%ebp
80106872:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106875:	83 ec 0c             	sub    $0xc,%esp
80106878:	68 80 49 11 80       	push   $0x80114980
8010687d:	e8 15 02 00 00       	call   80106a97 <acquire>
80106882:	83 c4 10             	add    $0x10,%esp

    if(priority < 0 || priority > MAX)
80106885:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106889:	78 06                	js     80106891 <setpriority+0x22>
8010688b:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
8010688f:	7e 0a                	jle    8010689b <setpriority+0x2c>
	return -2;
80106891:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
80106896:	e9 a0 01 00 00       	jmp    80106a3b <setpriority+0x1cc>
    if(pid < 1)
8010689b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010689f:	7f 0a                	jg     801068ab <setpriority+0x3c>
	return -3;
801068a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
801068a6:	e9 90 01 00 00       	jmp    80106a3b <setpriority+0x1cc>

    struct proc * current = ptable.pLists.ready[0];
801068ab:	a1 b4 70 11 80       	mov    0x801170b4,%eax
801068b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i = 0; i < MAX+1; ++i){
801068b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801068ba:	e9 bb 00 00 00       	jmp    8010697a <setpriority+0x10b>
	current = ptable.pLists.ready[i];
801068bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c2:	05 cc 09 00 00       	add    $0x9cc,%eax
801068c7:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
801068ce:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while(current){
801068d1:	e9 96 00 00 00       	jmp    8010696c <setpriority+0xfd>
	    if(current -> pid == pid){
801068d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d9:	8b 50 10             	mov    0x10(%eax),%edx
801068dc:	8b 45 08             	mov    0x8(%ebp),%eax
801068df:	39 c2                	cmp    %eax,%edx
801068e1:	75 7d                	jne    80106960 <setpriority+0xf1>
		current -> priority = priority;
801068e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801068e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e9:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		current -> budget = BUDGET; 
801068ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f2:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
801068f9:	13 00 00 
		removeFromStateList(&ptable.pLists.ready[i], current);
801068fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ff:	05 cc 09 00 00       	add    $0x9cc,%eax
80106904:	c1 e0 02             	shl    $0x2,%eax
80106907:	05 80 49 11 80       	add    $0x80114980,%eax
8010690c:	83 c0 04             	add    $0x4,%eax
8010690f:	83 ec 08             	sub    $0x8,%esp
80106912:	ff 75 f4             	pushl  -0xc(%ebp)
80106915:	50                   	push   %eax
80106916:	e8 91 dd ff ff       	call   801046ac <removeFromStateList>
8010691b:	83 c4 10             	add    $0x10,%esp
		addToStateListEnd(&ptable.pLists.ready[current -> priority], current);
8010691e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106921:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106927:	05 cc 09 00 00       	add    $0x9cc,%eax
8010692c:	c1 e0 02             	shl    $0x2,%eax
8010692f:	05 80 49 11 80       	add    $0x80114980,%eax
80106934:	83 c0 04             	add    $0x4,%eax
80106937:	83 ec 08             	sub    $0x8,%esp
8010693a:	ff 75 f4             	pushl  -0xc(%ebp)
8010693d:	50                   	push   %eax
8010693e:	e8 81 dc ff ff       	call   801045c4 <addToStateListEnd>
80106943:	83 c4 10             	add    $0x10,%esp
		release(&ptable.lock);
80106946:	83 ec 0c             	sub    $0xc,%esp
80106949:	68 80 49 11 80       	push   $0x80114980
8010694e:	e8 ab 01 00 00       	call   80106afe <release>
80106953:	83 c4 10             	add    $0x10,%esp
		return 0;
80106956:	b8 00 00 00 00       	mov    $0x0,%eax
8010695b:	e9 db 00 00 00       	jmp    80106a3b <setpriority+0x1cc>
	    }
	    current = current -> next;
80106960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106963:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106969:	89 45 f4             	mov    %eax,-0xc(%ebp)

    struct proc * current = ptable.pLists.ready[0];
    for(int i = 0; i < MAX+1; ++i){
	current = ptable.pLists.ready[i];

	while(current){
8010696c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106970:	0f 85 60 ff ff ff    	jne    801068d6 <setpriority+0x67>
	return -2;
    if(pid < 1)
	return -3;

    struct proc * current = ptable.pLists.ready[0];
    for(int i = 0; i < MAX+1; ++i){
80106976:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010697a:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010697e:	0f 8e 3b ff ff ff    	jle    801068bf <setpriority+0x50>
		return 0;
	    }
	    current = current -> next;
	}
    }
    current = ptable.pLists.sleep;
80106984:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80106989:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
8010698c:	eb 49                	jmp    801069d7 <setpriority+0x168>
	if(current -> pid == pid){
8010698e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106991:	8b 50 10             	mov    0x10(%eax),%edx
80106994:	8b 45 08             	mov    0x8(%ebp),%eax
80106997:	39 c2                	cmp    %eax,%edx
80106999:	75 30                	jne    801069cb <setpriority+0x15c>
	    current -> priority = priority;
8010699b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010699e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a1:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
	    current -> budget = BUDGET; 
801069a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069aa:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
801069b1:	13 00 00 
	    release(&ptable.lock);
801069b4:	83 ec 0c             	sub    $0xc,%esp
801069b7:	68 80 49 11 80       	push   $0x80114980
801069bc:	e8 3d 01 00 00       	call   80106afe <release>
801069c1:	83 c4 10             	add    $0x10,%esp
	    return 0;
801069c4:	b8 00 00 00 00       	mov    $0x0,%eax
801069c9:	eb 70                	jmp    80106a3b <setpriority+0x1cc>
	}
	current = current -> next;
801069cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ce:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801069d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    }
	    current = current -> next;
	}
    }
    current = ptable.pLists.sleep;
    while(current){
801069d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069db:	75 b1                	jne    8010698e <setpriority+0x11f>
	    release(&ptable.lock);
	    return 0;
	}
	current = current -> next;
    }
    current = ptable.pLists.running;
801069dd:	a1 d4 70 11 80       	mov    0x801170d4,%eax
801069e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
801069e5:	eb 49                	jmp    80106a30 <setpriority+0x1c1>
	if(current -> pid == pid){
801069e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ea:	8b 50 10             	mov    0x10(%eax),%edx
801069ed:	8b 45 08             	mov    0x8(%ebp),%eax
801069f0:	39 c2                	cmp    %eax,%edx
801069f2:	75 30                	jne    80106a24 <setpriority+0x1b5>
	    current -> priority = priority;
801069f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801069f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069fa:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
	    current -> budget = BUDGET; 
80106a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a03:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106a0a:	13 00 00 
	    release(&ptable.lock);
80106a0d:	83 ec 0c             	sub    $0xc,%esp
80106a10:	68 80 49 11 80       	push   $0x80114980
80106a15:	e8 e4 00 00 00       	call   80106afe <release>
80106a1a:	83 c4 10             	add    $0x10,%esp
	    return 0;
80106a1d:	b8 00 00 00 00       	mov    $0x0,%eax
80106a22:	eb 17                	jmp    80106a3b <setpriority+0x1cc>
	}
	current = current -> next;
80106a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a27:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    return 0;
	}
	current = current -> next;
    }
    current = ptable.pLists.running;
    while(current){
80106a30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a34:	75 b1                	jne    801069e7 <setpriority+0x178>
	    return 0;
	}
	current = current -> next;
    }

    return -1;
80106a36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106a3b:	c9                   	leave  
80106a3c:	c3                   	ret    

80106a3d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80106a3d:	55                   	push   %ebp
80106a3e:	89 e5                	mov    %esp,%ebp
80106a40:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106a43:	9c                   	pushf  
80106a44:	58                   	pop    %eax
80106a45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106a48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a4b:	c9                   	leave  
80106a4c:	c3                   	ret    

80106a4d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80106a4d:	55                   	push   %ebp
80106a4e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80106a50:	fa                   	cli    
}
80106a51:	90                   	nop
80106a52:	5d                   	pop    %ebp
80106a53:	c3                   	ret    

80106a54 <sti>:

static inline void
sti(void)
{
80106a54:	55                   	push   %ebp
80106a55:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106a57:	fb                   	sti    
}
80106a58:	90                   	nop
80106a59:	5d                   	pop    %ebp
80106a5a:	c3                   	ret    

80106a5b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106a5b:	55                   	push   %ebp
80106a5c:	89 e5                	mov    %esp,%ebp
80106a5e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80106a61:	8b 55 08             	mov    0x8(%ebp),%edx
80106a64:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106a6a:	f0 87 02             	lock xchg %eax,(%edx)
80106a6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80106a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a73:	c9                   	leave  
80106a74:	c3                   	ret    

80106a75 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80106a75:	55                   	push   %ebp
80106a76:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80106a78:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80106a7e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80106a81:	8b 45 08             	mov    0x8(%ebp),%eax
80106a84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80106a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106a8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106a94:	90                   	nop
80106a95:	5d                   	pop    %ebp
80106a96:	c3                   	ret    

80106a97 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106a97:	55                   	push   %ebp
80106a98:	89 e5                	mov    %esp,%ebp
80106a9a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80106a9d:	e8 52 01 00 00       	call   80106bf4 <pushcli>
  if(holding(lk))
80106aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa5:	83 ec 0c             	sub    $0xc,%esp
80106aa8:	50                   	push   %eax
80106aa9:	e8 1c 01 00 00       	call   80106bca <holding>
80106aae:	83 c4 10             	add    $0x10,%esp
80106ab1:	85 c0                	test   %eax,%eax
80106ab3:	74 0d                	je     80106ac2 <acquire+0x2b>
    panic("acquire");
80106ab5:	83 ec 0c             	sub    $0xc,%esp
80106ab8:	68 18 a8 10 80       	push   $0x8010a818
80106abd:	e8 a4 9a ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80106ac2:	90                   	nop
80106ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac6:	83 ec 08             	sub    $0x8,%esp
80106ac9:	6a 01                	push   $0x1
80106acb:	50                   	push   %eax
80106acc:	e8 8a ff ff ff       	call   80106a5b <xchg>
80106ad1:	83 c4 10             	add    $0x10,%esp
80106ad4:	85 c0                	test   %eax,%eax
80106ad6:	75 eb                	jne    80106ac3 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80106ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80106adb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ae2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80106ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae8:	83 c0 0c             	add    $0xc,%eax
80106aeb:	83 ec 08             	sub    $0x8,%esp
80106aee:	50                   	push   %eax
80106aef:	8d 45 08             	lea    0x8(%ebp),%eax
80106af2:	50                   	push   %eax
80106af3:	e8 58 00 00 00       	call   80106b50 <getcallerpcs>
80106af8:	83 c4 10             	add    $0x10,%esp
}
80106afb:	90                   	nop
80106afc:	c9                   	leave  
80106afd:	c3                   	ret    

80106afe <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80106afe:	55                   	push   %ebp
80106aff:	89 e5                	mov    %esp,%ebp
80106b01:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80106b04:	83 ec 0c             	sub    $0xc,%esp
80106b07:	ff 75 08             	pushl  0x8(%ebp)
80106b0a:	e8 bb 00 00 00       	call   80106bca <holding>
80106b0f:	83 c4 10             	add    $0x10,%esp
80106b12:	85 c0                	test   %eax,%eax
80106b14:	75 0d                	jne    80106b23 <release+0x25>
    panic("release");
80106b16:	83 ec 0c             	sub    $0xc,%esp
80106b19:	68 20 a8 10 80       	push   $0x8010a820
80106b1e:	e8 43 9a ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80106b23:	8b 45 08             	mov    0x8(%ebp),%eax
80106b26:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80106b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b30:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106b37:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3a:	83 ec 08             	sub    $0x8,%esp
80106b3d:	6a 00                	push   $0x0
80106b3f:	50                   	push   %eax
80106b40:	e8 16 ff ff ff       	call   80106a5b <xchg>
80106b45:	83 c4 10             	add    $0x10,%esp

  popcli();
80106b48:	e8 ec 00 00 00       	call   80106c39 <popcli>
}
80106b4d:	90                   	nop
80106b4e:	c9                   	leave  
80106b4f:	c3                   	ret    

80106b50 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80106b50:	55                   	push   %ebp
80106b51:	89 e5                	mov    %esp,%ebp
80106b53:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106b56:	8b 45 08             	mov    0x8(%ebp),%eax
80106b59:	83 e8 08             	sub    $0x8,%eax
80106b5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80106b5f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106b66:	eb 38                	jmp    80106ba0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106b68:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106b6c:	74 53                	je     80106bc1 <getcallerpcs+0x71>
80106b6e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106b75:	76 4a                	jbe    80106bc1 <getcallerpcs+0x71>
80106b77:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106b7b:	74 44                	je     80106bc1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80106b7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b87:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b8a:	01 c2                	add    %eax,%edx
80106b8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b8f:	8b 40 04             	mov    0x4(%eax),%eax
80106b92:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106b94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b97:	8b 00                	mov    (%eax),%eax
80106b99:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106b9c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106ba0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106ba4:	7e c2                	jle    80106b68 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106ba6:	eb 19                	jmp    80106bc1 <getcallerpcs+0x71>
    pcs[i] = 0;
80106ba8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bb5:	01 d0                	add    %edx,%eax
80106bb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106bbd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106bc1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106bc5:	7e e1                	jle    80106ba8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106bc7:	90                   	nop
80106bc8:	c9                   	leave  
80106bc9:	c3                   	ret    

80106bca <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106bca:	55                   	push   %ebp
80106bcb:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80106bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd0:	8b 00                	mov    (%eax),%eax
80106bd2:	85 c0                	test   %eax,%eax
80106bd4:	74 17                	je     80106bed <holding+0x23>
80106bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd9:	8b 50 08             	mov    0x8(%eax),%edx
80106bdc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106be2:	39 c2                	cmp    %eax,%edx
80106be4:	75 07                	jne    80106bed <holding+0x23>
80106be6:	b8 01 00 00 00       	mov    $0x1,%eax
80106beb:	eb 05                	jmp    80106bf2 <holding+0x28>
80106bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bf2:	5d                   	pop    %ebp
80106bf3:	c3                   	ret    

80106bf4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106bf4:	55                   	push   %ebp
80106bf5:	89 e5                	mov    %esp,%ebp
80106bf7:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106bfa:	e8 3e fe ff ff       	call   80106a3d <readeflags>
80106bff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80106c02:	e8 46 fe ff ff       	call   80106a4d <cli>
  if(cpu->ncli++ == 0)
80106c07:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c0e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106c14:	8d 48 01             	lea    0x1(%eax),%ecx
80106c17:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80106c1d:	85 c0                	test   %eax,%eax
80106c1f:	75 15                	jne    80106c36 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80106c21:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c27:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106c2a:	81 e2 00 02 00 00    	and    $0x200,%edx
80106c30:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106c36:	90                   	nop
80106c37:	c9                   	leave  
80106c38:	c3                   	ret    

80106c39 <popcli>:

void
popcli(void)
{
80106c39:	55                   	push   %ebp
80106c3a:	89 e5                	mov    %esp,%ebp
80106c3c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106c3f:	e8 f9 fd ff ff       	call   80106a3d <readeflags>
80106c44:	25 00 02 00 00       	and    $0x200,%eax
80106c49:	85 c0                	test   %eax,%eax
80106c4b:	74 0d                	je     80106c5a <popcli+0x21>
    panic("popcli - interruptible");
80106c4d:	83 ec 0c             	sub    $0xc,%esp
80106c50:	68 28 a8 10 80       	push   $0x8010a828
80106c55:	e8 0c 99 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106c5a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c60:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106c66:	83 ea 01             	sub    $0x1,%edx
80106c69:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106c6f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106c75:	85 c0                	test   %eax,%eax
80106c77:	79 0d                	jns    80106c86 <popcli+0x4d>
    panic("popcli");
80106c79:	83 ec 0c             	sub    $0xc,%esp
80106c7c:	68 3f a8 10 80       	push   $0x8010a83f
80106c81:	e8 e0 98 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106c86:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c8c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106c92:	85 c0                	test   %eax,%eax
80106c94:	75 15                	jne    80106cab <popcli+0x72>
80106c96:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c9c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106ca2:	85 c0                	test   %eax,%eax
80106ca4:	74 05                	je     80106cab <popcli+0x72>
    sti();
80106ca6:	e8 a9 fd ff ff       	call   80106a54 <sti>
}
80106cab:	90                   	nop
80106cac:	c9                   	leave  
80106cad:	c3                   	ret    

80106cae <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106cae:	55                   	push   %ebp
80106caf:	89 e5                	mov    %esp,%ebp
80106cb1:	57                   	push   %edi
80106cb2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106cb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106cb6:	8b 55 10             	mov    0x10(%ebp),%edx
80106cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cbc:	89 cb                	mov    %ecx,%ebx
80106cbe:	89 df                	mov    %ebx,%edi
80106cc0:	89 d1                	mov    %edx,%ecx
80106cc2:	fc                   	cld    
80106cc3:	f3 aa                	rep stos %al,%es:(%edi)
80106cc5:	89 ca                	mov    %ecx,%edx
80106cc7:	89 fb                	mov    %edi,%ebx
80106cc9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106ccc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106ccf:	90                   	nop
80106cd0:	5b                   	pop    %ebx
80106cd1:	5f                   	pop    %edi
80106cd2:	5d                   	pop    %ebp
80106cd3:	c3                   	ret    

80106cd4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106cd4:	55                   	push   %ebp
80106cd5:	89 e5                	mov    %esp,%ebp
80106cd7:	57                   	push   %edi
80106cd8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106cdc:	8b 55 10             	mov    0x10(%ebp),%edx
80106cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ce2:	89 cb                	mov    %ecx,%ebx
80106ce4:	89 df                	mov    %ebx,%edi
80106ce6:	89 d1                	mov    %edx,%ecx
80106ce8:	fc                   	cld    
80106ce9:	f3 ab                	rep stos %eax,%es:(%edi)
80106ceb:	89 ca                	mov    %ecx,%edx
80106ced:	89 fb                	mov    %edi,%ebx
80106cef:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106cf2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106cf5:	90                   	nop
80106cf6:	5b                   	pop    %ebx
80106cf7:	5f                   	pop    %edi
80106cf8:	5d                   	pop    %ebp
80106cf9:	c3                   	ret    

80106cfa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106cfa:	55                   	push   %ebp
80106cfb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80106d00:	83 e0 03             	and    $0x3,%eax
80106d03:	85 c0                	test   %eax,%eax
80106d05:	75 43                	jne    80106d4a <memset+0x50>
80106d07:	8b 45 10             	mov    0x10(%ebp),%eax
80106d0a:	83 e0 03             	and    $0x3,%eax
80106d0d:	85 c0                	test   %eax,%eax
80106d0f:	75 39                	jne    80106d4a <memset+0x50>
    c &= 0xFF;
80106d11:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106d18:	8b 45 10             	mov    0x10(%ebp),%eax
80106d1b:	c1 e8 02             	shr    $0x2,%eax
80106d1e:	89 c1                	mov    %eax,%ecx
80106d20:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d23:	c1 e0 18             	shl    $0x18,%eax
80106d26:	89 c2                	mov    %eax,%edx
80106d28:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d2b:	c1 e0 10             	shl    $0x10,%eax
80106d2e:	09 c2                	or     %eax,%edx
80106d30:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d33:	c1 e0 08             	shl    $0x8,%eax
80106d36:	09 d0                	or     %edx,%eax
80106d38:	0b 45 0c             	or     0xc(%ebp),%eax
80106d3b:	51                   	push   %ecx
80106d3c:	50                   	push   %eax
80106d3d:	ff 75 08             	pushl  0x8(%ebp)
80106d40:	e8 8f ff ff ff       	call   80106cd4 <stosl>
80106d45:	83 c4 0c             	add    $0xc,%esp
80106d48:	eb 12                	jmp    80106d5c <memset+0x62>
  } else
    stosb(dst, c, n);
80106d4a:	8b 45 10             	mov    0x10(%ebp),%eax
80106d4d:	50                   	push   %eax
80106d4e:	ff 75 0c             	pushl  0xc(%ebp)
80106d51:	ff 75 08             	pushl  0x8(%ebp)
80106d54:	e8 55 ff ff ff       	call   80106cae <stosb>
80106d59:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106d5c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106d5f:	c9                   	leave  
80106d60:	c3                   	ret    

80106d61 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106d61:	55                   	push   %ebp
80106d62:	89 e5                	mov    %esp,%ebp
80106d64:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106d67:	8b 45 08             	mov    0x8(%ebp),%eax
80106d6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d70:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106d73:	eb 30                	jmp    80106da5 <memcmp+0x44>
    if(*s1 != *s2)
80106d75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d78:	0f b6 10             	movzbl (%eax),%edx
80106d7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d7e:	0f b6 00             	movzbl (%eax),%eax
80106d81:	38 c2                	cmp    %al,%dl
80106d83:	74 18                	je     80106d9d <memcmp+0x3c>
      return *s1 - *s2;
80106d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d88:	0f b6 00             	movzbl (%eax),%eax
80106d8b:	0f b6 d0             	movzbl %al,%edx
80106d8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d91:	0f b6 00             	movzbl (%eax),%eax
80106d94:	0f b6 c0             	movzbl %al,%eax
80106d97:	29 c2                	sub    %eax,%edx
80106d99:	89 d0                	mov    %edx,%eax
80106d9b:	eb 1a                	jmp    80106db7 <memcmp+0x56>
    s1++, s2++;
80106d9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106da1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106da5:	8b 45 10             	mov    0x10(%ebp),%eax
80106da8:	8d 50 ff             	lea    -0x1(%eax),%edx
80106dab:	89 55 10             	mov    %edx,0x10(%ebp)
80106dae:	85 c0                	test   %eax,%eax
80106db0:	75 c3                	jne    80106d75 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106db2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106db7:	c9                   	leave  
80106db8:	c3                   	ret    

80106db9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106db9:	55                   	push   %ebp
80106dba:	89 e5                	mov    %esp,%ebp
80106dbc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106dce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106dd1:	73 54                	jae    80106e27 <memmove+0x6e>
80106dd3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106dd6:	8b 45 10             	mov    0x10(%ebp),%eax
80106dd9:	01 d0                	add    %edx,%eax
80106ddb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106dde:	76 47                	jbe    80106e27 <memmove+0x6e>
    s += n;
80106de0:	8b 45 10             	mov    0x10(%ebp),%eax
80106de3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106de6:	8b 45 10             	mov    0x10(%ebp),%eax
80106de9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106dec:	eb 13                	jmp    80106e01 <memmove+0x48>
      *--d = *--s;
80106dee:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106df2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106df6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106df9:	0f b6 10             	movzbl (%eax),%edx
80106dfc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106dff:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106e01:	8b 45 10             	mov    0x10(%ebp),%eax
80106e04:	8d 50 ff             	lea    -0x1(%eax),%edx
80106e07:	89 55 10             	mov    %edx,0x10(%ebp)
80106e0a:	85 c0                	test   %eax,%eax
80106e0c:	75 e0                	jne    80106dee <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106e0e:	eb 24                	jmp    80106e34 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106e10:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106e13:	8d 50 01             	lea    0x1(%eax),%edx
80106e16:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106e19:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e1c:	8d 4a 01             	lea    0x1(%edx),%ecx
80106e1f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106e22:	0f b6 12             	movzbl (%edx),%edx
80106e25:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106e27:	8b 45 10             	mov    0x10(%ebp),%eax
80106e2a:	8d 50 ff             	lea    -0x1(%eax),%edx
80106e2d:	89 55 10             	mov    %edx,0x10(%ebp)
80106e30:	85 c0                	test   %eax,%eax
80106e32:	75 dc                	jne    80106e10 <memmove+0x57>
      *d++ = *s++;

  return dst;
80106e34:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106e37:	c9                   	leave  
80106e38:	c3                   	ret    

80106e39 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106e39:	55                   	push   %ebp
80106e3a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106e3c:	ff 75 10             	pushl  0x10(%ebp)
80106e3f:	ff 75 0c             	pushl  0xc(%ebp)
80106e42:	ff 75 08             	pushl  0x8(%ebp)
80106e45:	e8 6f ff ff ff       	call   80106db9 <memmove>
80106e4a:	83 c4 0c             	add    $0xc,%esp
}
80106e4d:	c9                   	leave  
80106e4e:	c3                   	ret    

80106e4f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106e4f:	55                   	push   %ebp
80106e50:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106e52:	eb 0c                	jmp    80106e60 <strncmp+0x11>
    n--, p++, q++;
80106e54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106e58:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106e5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106e60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106e64:	74 1a                	je     80106e80 <strncmp+0x31>
80106e66:	8b 45 08             	mov    0x8(%ebp),%eax
80106e69:	0f b6 00             	movzbl (%eax),%eax
80106e6c:	84 c0                	test   %al,%al
80106e6e:	74 10                	je     80106e80 <strncmp+0x31>
80106e70:	8b 45 08             	mov    0x8(%ebp),%eax
80106e73:	0f b6 10             	movzbl (%eax),%edx
80106e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e79:	0f b6 00             	movzbl (%eax),%eax
80106e7c:	38 c2                	cmp    %al,%dl
80106e7e:	74 d4                	je     80106e54 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106e80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106e84:	75 07                	jne    80106e8d <strncmp+0x3e>
    return 0;
80106e86:	b8 00 00 00 00       	mov    $0x0,%eax
80106e8b:	eb 16                	jmp    80106ea3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e90:	0f b6 00             	movzbl (%eax),%eax
80106e93:	0f b6 d0             	movzbl %al,%edx
80106e96:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e99:	0f b6 00             	movzbl (%eax),%eax
80106e9c:	0f b6 c0             	movzbl %al,%eax
80106e9f:	29 c2                	sub    %eax,%edx
80106ea1:	89 d0                	mov    %edx,%eax
}
80106ea3:	5d                   	pop    %ebp
80106ea4:	c3                   	ret    

80106ea5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106ea5:	55                   	push   %ebp
80106ea6:	89 e5                	mov    %esp,%ebp
80106ea8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106eab:	8b 45 08             	mov    0x8(%ebp),%eax
80106eae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106eb1:	90                   	nop
80106eb2:	8b 45 10             	mov    0x10(%ebp),%eax
80106eb5:	8d 50 ff             	lea    -0x1(%eax),%edx
80106eb8:	89 55 10             	mov    %edx,0x10(%ebp)
80106ebb:	85 c0                	test   %eax,%eax
80106ebd:	7e 2c                	jle    80106eeb <strncpy+0x46>
80106ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec2:	8d 50 01             	lea    0x1(%eax),%edx
80106ec5:	89 55 08             	mov    %edx,0x8(%ebp)
80106ec8:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ecb:	8d 4a 01             	lea    0x1(%edx),%ecx
80106ece:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106ed1:	0f b6 12             	movzbl (%edx),%edx
80106ed4:	88 10                	mov    %dl,(%eax)
80106ed6:	0f b6 00             	movzbl (%eax),%eax
80106ed9:	84 c0                	test   %al,%al
80106edb:	75 d5                	jne    80106eb2 <strncpy+0xd>
    ;
  while(n-- > 0)
80106edd:	eb 0c                	jmp    80106eeb <strncpy+0x46>
    *s++ = 0;
80106edf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee2:	8d 50 01             	lea    0x1(%eax),%edx
80106ee5:	89 55 08             	mov    %edx,0x8(%ebp)
80106ee8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106eeb:	8b 45 10             	mov    0x10(%ebp),%eax
80106eee:	8d 50 ff             	lea    -0x1(%eax),%edx
80106ef1:	89 55 10             	mov    %edx,0x10(%ebp)
80106ef4:	85 c0                	test   %eax,%eax
80106ef6:	7f e7                	jg     80106edf <strncpy+0x3a>
    *s++ = 0;
  return os;
80106ef8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106efb:	c9                   	leave  
80106efc:	c3                   	ret    

80106efd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106efd:	55                   	push   %ebp
80106efe:	89 e5                	mov    %esp,%ebp
80106f00:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106f03:	8b 45 08             	mov    0x8(%ebp),%eax
80106f06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106f09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f0d:	7f 05                	jg     80106f14 <safestrcpy+0x17>
    return os;
80106f0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f12:	eb 31                	jmp    80106f45 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106f14:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106f1c:	7e 1e                	jle    80106f3c <safestrcpy+0x3f>
80106f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f21:	8d 50 01             	lea    0x1(%eax),%edx
80106f24:	89 55 08             	mov    %edx,0x8(%ebp)
80106f27:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f2a:	8d 4a 01             	lea    0x1(%edx),%ecx
80106f2d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106f30:	0f b6 12             	movzbl (%edx),%edx
80106f33:	88 10                	mov    %dl,(%eax)
80106f35:	0f b6 00             	movzbl (%eax),%eax
80106f38:	84 c0                	test   %al,%al
80106f3a:	75 d8                	jne    80106f14 <safestrcpy+0x17>
    ;
  *s = 0;
80106f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f3f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f45:	c9                   	leave  
80106f46:	c3                   	ret    

80106f47 <strlen>:

int
strlen(const char *s)
{
80106f47:	55                   	push   %ebp
80106f48:	89 e5                	mov    %esp,%ebp
80106f4a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106f4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106f54:	eb 04                	jmp    80106f5a <strlen+0x13>
80106f56:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106f5a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f60:	01 d0                	add    %edx,%eax
80106f62:	0f b6 00             	movzbl (%eax),%eax
80106f65:	84 c0                	test   %al,%al
80106f67:	75 ed                	jne    80106f56 <strlen+0xf>
    ;
  return n;
80106f69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f6c:	c9                   	leave  
80106f6d:	c3                   	ret    

80106f6e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106f6e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106f72:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106f76:	55                   	push   %ebp
  pushl %ebx
80106f77:	53                   	push   %ebx
  pushl %esi
80106f78:	56                   	push   %esi
  pushl %edi
80106f79:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106f7a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106f7c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106f7e:	5f                   	pop    %edi
  popl %esi
80106f7f:	5e                   	pop    %esi
  popl %ebx
80106f80:	5b                   	pop    %ebx
  popl %ebp
80106f81:	5d                   	pop    %ebp
  ret
80106f82:	c3                   	ret    

80106f83 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106f83:	55                   	push   %ebp
80106f84:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106f86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f8c:	8b 00                	mov    (%eax),%eax
80106f8e:	3b 45 08             	cmp    0x8(%ebp),%eax
80106f91:	76 12                	jbe    80106fa5 <fetchint+0x22>
80106f93:	8b 45 08             	mov    0x8(%ebp),%eax
80106f96:	8d 50 04             	lea    0x4(%eax),%edx
80106f99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f9f:	8b 00                	mov    (%eax),%eax
80106fa1:	39 c2                	cmp    %eax,%edx
80106fa3:	76 07                	jbe    80106fac <fetchint+0x29>
    return -1;
80106fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106faa:	eb 0f                	jmp    80106fbb <fetchint+0x38>
  *ip = *(int*)(addr);
80106fac:	8b 45 08             	mov    0x8(%ebp),%eax
80106faf:	8b 10                	mov    (%eax),%edx
80106fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fb4:	89 10                	mov    %edx,(%eax)
  return 0;
80106fb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fbb:	5d                   	pop    %ebp
80106fbc:	c3                   	ret    

80106fbd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106fbd:	55                   	push   %ebp
80106fbe:	89 e5                	mov    %esp,%ebp
80106fc0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106fc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc9:	8b 00                	mov    (%eax),%eax
80106fcb:	3b 45 08             	cmp    0x8(%ebp),%eax
80106fce:	77 07                	ja     80106fd7 <fetchstr+0x1a>
    return -1;
80106fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fd5:	eb 46                	jmp    8010701d <fetchstr+0x60>
  *pp = (char*)addr;
80106fd7:	8b 55 08             	mov    0x8(%ebp),%edx
80106fda:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fdd:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106fdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fe5:	8b 00                	mov    (%eax),%eax
80106fe7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106fea:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fed:	8b 00                	mov    (%eax),%eax
80106fef:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106ff2:	eb 1c                	jmp    80107010 <fetchstr+0x53>
    if(*s == 0)
80106ff4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ff7:	0f b6 00             	movzbl (%eax),%eax
80106ffa:	84 c0                	test   %al,%al
80106ffc:	75 0e                	jne    8010700c <fetchstr+0x4f>
      return s - *pp;
80106ffe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107001:	8b 45 0c             	mov    0xc(%ebp),%eax
80107004:	8b 00                	mov    (%eax),%eax
80107006:	29 c2                	sub    %eax,%edx
80107008:	89 d0                	mov    %edx,%eax
8010700a:	eb 11                	jmp    8010701d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010700c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107010:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107013:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80107016:	72 dc                	jb     80106ff4 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80107018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010701d:	c9                   	leave  
8010701e:	c3                   	ret    

8010701f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010701f:	55                   	push   %ebp
80107020:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80107022:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107028:	8b 40 18             	mov    0x18(%eax),%eax
8010702b:	8b 40 44             	mov    0x44(%eax),%eax
8010702e:	8b 55 08             	mov    0x8(%ebp),%edx
80107031:	c1 e2 02             	shl    $0x2,%edx
80107034:	01 d0                	add    %edx,%eax
80107036:	83 c0 04             	add    $0x4,%eax
80107039:	ff 75 0c             	pushl  0xc(%ebp)
8010703c:	50                   	push   %eax
8010703d:	e8 41 ff ff ff       	call   80106f83 <fetchint>
80107042:	83 c4 08             	add    $0x8,%esp
}
80107045:	c9                   	leave  
80107046:	c3                   	ret    

80107047 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80107047:	55                   	push   %ebp
80107048:	89 e5                	mov    %esp,%ebp
8010704a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010704d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80107050:	50                   	push   %eax
80107051:	ff 75 08             	pushl  0x8(%ebp)
80107054:	e8 c6 ff ff ff       	call   8010701f <argint>
80107059:	83 c4 08             	add    $0x8,%esp
8010705c:	85 c0                	test   %eax,%eax
8010705e:	79 07                	jns    80107067 <argptr+0x20>
    return -1;
80107060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107065:	eb 3b                	jmp    801070a2 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80107067:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010706d:	8b 00                	mov    (%eax),%eax
8010706f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107072:	39 d0                	cmp    %edx,%eax
80107074:	76 16                	jbe    8010708c <argptr+0x45>
80107076:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107079:	89 c2                	mov    %eax,%edx
8010707b:	8b 45 10             	mov    0x10(%ebp),%eax
8010707e:	01 c2                	add    %eax,%edx
80107080:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107086:	8b 00                	mov    (%eax),%eax
80107088:	39 c2                	cmp    %eax,%edx
8010708a:	76 07                	jbe    80107093 <argptr+0x4c>
    return -1;
8010708c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107091:	eb 0f                	jmp    801070a2 <argptr+0x5b>
  *pp = (char*)i;
80107093:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107096:	89 c2                	mov    %eax,%edx
80107098:	8b 45 0c             	mov    0xc(%ebp),%eax
8010709b:	89 10                	mov    %edx,(%eax)
  return 0;
8010709d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070a2:	c9                   	leave  
801070a3:	c3                   	ret    

801070a4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801070a4:	55                   	push   %ebp
801070a5:	89 e5                	mov    %esp,%ebp
801070a7:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801070aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
801070ad:	50                   	push   %eax
801070ae:	ff 75 08             	pushl  0x8(%ebp)
801070b1:	e8 69 ff ff ff       	call   8010701f <argint>
801070b6:	83 c4 08             	add    $0x8,%esp
801070b9:	85 c0                	test   %eax,%eax
801070bb:	79 07                	jns    801070c4 <argstr+0x20>
    return -1;
801070bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c2:	eb 0f                	jmp    801070d3 <argstr+0x2f>
  return fetchstr(addr, pp);
801070c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801070c7:	ff 75 0c             	pushl  0xc(%ebp)
801070ca:	50                   	push   %eax
801070cb:	e8 ed fe ff ff       	call   80106fbd <fetchstr>
801070d0:	83 c4 08             	add    $0x8,%esp
}
801070d3:	c9                   	leave  
801070d4:	c3                   	ret    

801070d5 <syscall>:
// put data structure for printing out system call invocation information here

#endif
void
syscall(void)
{
801070d5:	55                   	push   %ebp
801070d6:	89 e5                	mov    %esp,%ebp
801070d8:	53                   	push   %ebx
801070d9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801070dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070e2:	8b 40 18             	mov    0x18(%eax),%eax
801070e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801070e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801070eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070ef:	7e 30                	jle    80107121 <syscall+0x4c>
801070f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f4:	83 f8 1c             	cmp    $0x1c,%eax
801070f7:	77 28                	ja     80107121 <syscall+0x4c>
801070f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fc:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80107103:	85 c0                	test   %eax,%eax
80107105:	74 1a                	je     80107121 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80107107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010710d:	8b 58 18             	mov    0x18(%eax),%ebx
80107110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107113:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
8010711a:	ff d0                	call   *%eax
8010711c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010711f:	eb 34                	jmp    80107155 <syscall+0x80>
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80107121:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107127:	8d 50 6c             	lea    0x6c(%eax),%edx
8010712a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
#ifdef PRINT_SYSCALLS
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80107130:	8b 40 10             	mov    0x10(%eax),%eax
80107133:	ff 75 f4             	pushl  -0xc(%ebp)
80107136:	52                   	push   %edx
80107137:	50                   	push   %eax
80107138:	68 46 a8 10 80       	push   $0x8010a846
8010713d:	e8 84 92 ff ff       	call   801003c6 <cprintf>
80107142:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80107145:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010714b:	8b 40 18             	mov    0x18(%eax),%eax
8010714e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80107155:	90                   	nop
80107156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107159:	c9                   	leave  
8010715a:	c3                   	ret    

8010715b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010715b:	55                   	push   %ebp
8010715c:	89 e5                	mov    %esp,%ebp
8010715e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80107161:	83 ec 08             	sub    $0x8,%esp
80107164:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107167:	50                   	push   %eax
80107168:	ff 75 08             	pushl  0x8(%ebp)
8010716b:	e8 af fe ff ff       	call   8010701f <argint>
80107170:	83 c4 10             	add    $0x10,%esp
80107173:	85 c0                	test   %eax,%eax
80107175:	79 07                	jns    8010717e <argfd+0x23>
    return -1;
80107177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010717c:	eb 50                	jmp    801071ce <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010717e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107181:	85 c0                	test   %eax,%eax
80107183:	78 21                	js     801071a6 <argfd+0x4b>
80107185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107188:	83 f8 0f             	cmp    $0xf,%eax
8010718b:	7f 19                	jg     801071a6 <argfd+0x4b>
8010718d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107193:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107196:	83 c2 08             	add    $0x8,%edx
80107199:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010719d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071a4:	75 07                	jne    801071ad <argfd+0x52>
    return -1;
801071a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ab:	eb 21                	jmp    801071ce <argfd+0x73>
  if(pfd)
801071ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801071b1:	74 08                	je     801071bb <argfd+0x60>
    *pfd = fd;
801071b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801071b9:	89 10                	mov    %edx,(%eax)
  if(pf)
801071bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071bf:	74 08                	je     801071c9 <argfd+0x6e>
    *pf = f;
801071c1:	8b 45 10             	mov    0x10(%ebp),%eax
801071c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071c7:	89 10                	mov    %edx,(%eax)
  return 0;
801071c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071ce:	c9                   	leave  
801071cf:	c3                   	ret    

801071d0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801071d0:	55                   	push   %ebp
801071d1:	89 e5                	mov    %esp,%ebp
801071d3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801071d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801071dd:	eb 30                	jmp    8010720f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801071df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801071e8:	83 c2 08             	add    $0x8,%edx
801071eb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801071ef:	85 c0                	test   %eax,%eax
801071f1:	75 18                	jne    8010720b <fdalloc+0x3b>
      proc->ofile[fd] = f;
801071f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801071fc:	8d 4a 08             	lea    0x8(%edx),%ecx
801071ff:	8b 55 08             	mov    0x8(%ebp),%edx
80107202:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80107206:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107209:	eb 0f                	jmp    8010721a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010720b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010720f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80107213:	7e ca                	jle    801071df <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80107215:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010721a:	c9                   	leave  
8010721b:	c3                   	ret    

8010721c <sys_dup>:

int
sys_dup(void)
{
8010721c:	55                   	push   %ebp
8010721d:	89 e5                	mov    %esp,%ebp
8010721f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80107222:	83 ec 04             	sub    $0x4,%esp
80107225:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107228:	50                   	push   %eax
80107229:	6a 00                	push   $0x0
8010722b:	6a 00                	push   $0x0
8010722d:	e8 29 ff ff ff       	call   8010715b <argfd>
80107232:	83 c4 10             	add    $0x10,%esp
80107235:	85 c0                	test   %eax,%eax
80107237:	79 07                	jns    80107240 <sys_dup+0x24>
    return -1;
80107239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010723e:	eb 31                	jmp    80107271 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80107240:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107243:	83 ec 0c             	sub    $0xc,%esp
80107246:	50                   	push   %eax
80107247:	e8 84 ff ff ff       	call   801071d0 <fdalloc>
8010724c:	83 c4 10             	add    $0x10,%esp
8010724f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107252:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107256:	79 07                	jns    8010725f <sys_dup+0x43>
    return -1;
80107258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010725d:	eb 12                	jmp    80107271 <sys_dup+0x55>
  filedup(f);
8010725f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107262:	83 ec 0c             	sub    $0xc,%esp
80107265:	50                   	push   %eax
80107266:	e8 3f 9e ff ff       	call   801010aa <filedup>
8010726b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010726e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107271:	c9                   	leave  
80107272:	c3                   	ret    

80107273 <sys_read>:

int
sys_read(void)
{
80107273:	55                   	push   %ebp
80107274:	89 e5                	mov    %esp,%ebp
80107276:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107279:	83 ec 04             	sub    $0x4,%esp
8010727c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010727f:	50                   	push   %eax
80107280:	6a 00                	push   $0x0
80107282:	6a 00                	push   $0x0
80107284:	e8 d2 fe ff ff       	call   8010715b <argfd>
80107289:	83 c4 10             	add    $0x10,%esp
8010728c:	85 c0                	test   %eax,%eax
8010728e:	78 2e                	js     801072be <sys_read+0x4b>
80107290:	83 ec 08             	sub    $0x8,%esp
80107293:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107296:	50                   	push   %eax
80107297:	6a 02                	push   $0x2
80107299:	e8 81 fd ff ff       	call   8010701f <argint>
8010729e:	83 c4 10             	add    $0x10,%esp
801072a1:	85 c0                	test   %eax,%eax
801072a3:	78 19                	js     801072be <sys_read+0x4b>
801072a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072a8:	83 ec 04             	sub    $0x4,%esp
801072ab:	50                   	push   %eax
801072ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
801072af:	50                   	push   %eax
801072b0:	6a 01                	push   $0x1
801072b2:	e8 90 fd ff ff       	call   80107047 <argptr>
801072b7:	83 c4 10             	add    $0x10,%esp
801072ba:	85 c0                	test   %eax,%eax
801072bc:	79 07                	jns    801072c5 <sys_read+0x52>
    return -1;
801072be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072c3:	eb 17                	jmp    801072dc <sys_read+0x69>
  return fileread(f, p, n);
801072c5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801072c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801072cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ce:	83 ec 04             	sub    $0x4,%esp
801072d1:	51                   	push   %ecx
801072d2:	52                   	push   %edx
801072d3:	50                   	push   %eax
801072d4:	e8 61 9f ff ff       	call   8010123a <fileread>
801072d9:	83 c4 10             	add    $0x10,%esp
}
801072dc:	c9                   	leave  
801072dd:	c3                   	ret    

801072de <sys_write>:

int
sys_write(void)
{
801072de:	55                   	push   %ebp
801072df:	89 e5                	mov    %esp,%ebp
801072e1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801072e4:	83 ec 04             	sub    $0x4,%esp
801072e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072ea:	50                   	push   %eax
801072eb:	6a 00                	push   $0x0
801072ed:	6a 00                	push   $0x0
801072ef:	e8 67 fe ff ff       	call   8010715b <argfd>
801072f4:	83 c4 10             	add    $0x10,%esp
801072f7:	85 c0                	test   %eax,%eax
801072f9:	78 2e                	js     80107329 <sys_write+0x4b>
801072fb:	83 ec 08             	sub    $0x8,%esp
801072fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107301:	50                   	push   %eax
80107302:	6a 02                	push   $0x2
80107304:	e8 16 fd ff ff       	call   8010701f <argint>
80107309:	83 c4 10             	add    $0x10,%esp
8010730c:	85 c0                	test   %eax,%eax
8010730e:	78 19                	js     80107329 <sys_write+0x4b>
80107310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107313:	83 ec 04             	sub    $0x4,%esp
80107316:	50                   	push   %eax
80107317:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010731a:	50                   	push   %eax
8010731b:	6a 01                	push   $0x1
8010731d:	e8 25 fd ff ff       	call   80107047 <argptr>
80107322:	83 c4 10             	add    $0x10,%esp
80107325:	85 c0                	test   %eax,%eax
80107327:	79 07                	jns    80107330 <sys_write+0x52>
    return -1;
80107329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010732e:	eb 17                	jmp    80107347 <sys_write+0x69>
  return filewrite(f, p, n);
80107330:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107333:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107339:	83 ec 04             	sub    $0x4,%esp
8010733c:	51                   	push   %ecx
8010733d:	52                   	push   %edx
8010733e:	50                   	push   %eax
8010733f:	e8 ae 9f ff ff       	call   801012f2 <filewrite>
80107344:	83 c4 10             	add    $0x10,%esp
}
80107347:	c9                   	leave  
80107348:	c3                   	ret    

80107349 <sys_close>:

int
sys_close(void)
{
80107349:	55                   	push   %ebp
8010734a:	89 e5                	mov    %esp,%ebp
8010734c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010734f:	83 ec 04             	sub    $0x4,%esp
80107352:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107355:	50                   	push   %eax
80107356:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107359:	50                   	push   %eax
8010735a:	6a 00                	push   $0x0
8010735c:	e8 fa fd ff ff       	call   8010715b <argfd>
80107361:	83 c4 10             	add    $0x10,%esp
80107364:	85 c0                	test   %eax,%eax
80107366:	79 07                	jns    8010736f <sys_close+0x26>
    return -1;
80107368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010736d:	eb 28                	jmp    80107397 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010736f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107375:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107378:	83 c2 08             	add    $0x8,%edx
8010737b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107382:	00 
  fileclose(f);
80107383:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107386:	83 ec 0c             	sub    $0xc,%esp
80107389:	50                   	push   %eax
8010738a:	e8 6c 9d ff ff       	call   801010fb <fileclose>
8010738f:	83 c4 10             	add    $0x10,%esp
  return 0;
80107392:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107397:	c9                   	leave  
80107398:	c3                   	ret    

80107399 <sys_fstat>:

int
sys_fstat(void)
{
80107399:	55                   	push   %ebp
8010739a:	89 e5                	mov    %esp,%ebp
8010739c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010739f:	83 ec 04             	sub    $0x4,%esp
801073a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073a5:	50                   	push   %eax
801073a6:	6a 00                	push   $0x0
801073a8:	6a 00                	push   $0x0
801073aa:	e8 ac fd ff ff       	call   8010715b <argfd>
801073af:	83 c4 10             	add    $0x10,%esp
801073b2:	85 c0                	test   %eax,%eax
801073b4:	78 17                	js     801073cd <sys_fstat+0x34>
801073b6:	83 ec 04             	sub    $0x4,%esp
801073b9:	6a 14                	push   $0x14
801073bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073be:	50                   	push   %eax
801073bf:	6a 01                	push   $0x1
801073c1:	e8 81 fc ff ff       	call   80107047 <argptr>
801073c6:	83 c4 10             	add    $0x10,%esp
801073c9:	85 c0                	test   %eax,%eax
801073cb:	79 07                	jns    801073d4 <sys_fstat+0x3b>
    return -1;
801073cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d2:	eb 13                	jmp    801073e7 <sys_fstat+0x4e>
  return filestat(f, st);
801073d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073da:	83 ec 08             	sub    $0x8,%esp
801073dd:	52                   	push   %edx
801073de:	50                   	push   %eax
801073df:	e8 ff 9d ff ff       	call   801011e3 <filestat>
801073e4:	83 c4 10             	add    $0x10,%esp
}
801073e7:	c9                   	leave  
801073e8:	c3                   	ret    

801073e9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801073e9:	55                   	push   %ebp
801073ea:	89 e5                	mov    %esp,%ebp
801073ec:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801073ef:	83 ec 08             	sub    $0x8,%esp
801073f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801073f5:	50                   	push   %eax
801073f6:	6a 00                	push   $0x0
801073f8:	e8 a7 fc ff ff       	call   801070a4 <argstr>
801073fd:	83 c4 10             	add    $0x10,%esp
80107400:	85 c0                	test   %eax,%eax
80107402:	78 15                	js     80107419 <sys_link+0x30>
80107404:	83 ec 08             	sub    $0x8,%esp
80107407:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010740a:	50                   	push   %eax
8010740b:	6a 01                	push   $0x1
8010740d:	e8 92 fc ff ff       	call   801070a4 <argstr>
80107412:	83 c4 10             	add    $0x10,%esp
80107415:	85 c0                	test   %eax,%eax
80107417:	79 0a                	jns    80107423 <sys_link+0x3a>
    return -1;
80107419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010741e:	e9 68 01 00 00       	jmp    8010758b <sys_link+0x1a2>

  begin_op();
80107423:	e8 cf c1 ff ff       	call   801035f7 <begin_op>
  if((ip = namei(old)) == 0){
80107428:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010742b:	83 ec 0c             	sub    $0xc,%esp
8010742e:	50                   	push   %eax
8010742f:	e8 9e b1 ff ff       	call   801025d2 <namei>
80107434:	83 c4 10             	add    $0x10,%esp
80107437:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010743a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010743e:	75 0f                	jne    8010744f <sys_link+0x66>
    end_op();
80107440:	e8 3e c2 ff ff       	call   80103683 <end_op>
    return -1;
80107445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010744a:	e9 3c 01 00 00       	jmp    8010758b <sys_link+0x1a2>
  }

  ilock(ip);
8010744f:	83 ec 0c             	sub    $0xc,%esp
80107452:	ff 75 f4             	pushl  -0xc(%ebp)
80107455:	e8 ba a5 ff ff       	call   80101a14 <ilock>
8010745a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010745d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107460:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107464:	66 83 f8 01          	cmp    $0x1,%ax
80107468:	75 1d                	jne    80107487 <sys_link+0x9e>
    iunlockput(ip);
8010746a:	83 ec 0c             	sub    $0xc,%esp
8010746d:	ff 75 f4             	pushl  -0xc(%ebp)
80107470:	e8 5f a8 ff ff       	call   80101cd4 <iunlockput>
80107475:	83 c4 10             	add    $0x10,%esp
    end_op();
80107478:	e8 06 c2 ff ff       	call   80103683 <end_op>
    return -1;
8010747d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107482:	e9 04 01 00 00       	jmp    8010758b <sys_link+0x1a2>
  }

  ip->nlink++;
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010748e:	83 c0 01             	add    $0x1,%eax
80107491:	89 c2                	mov    %eax,%edx
80107493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107496:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010749a:	83 ec 0c             	sub    $0xc,%esp
8010749d:	ff 75 f4             	pushl  -0xc(%ebp)
801074a0:	e8 95 a3 ff ff       	call   8010183a <iupdate>
801074a5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801074a8:	83 ec 0c             	sub    $0xc,%esp
801074ab:	ff 75 f4             	pushl  -0xc(%ebp)
801074ae:	e8 bf a6 ff ff       	call   80101b72 <iunlock>
801074b3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801074b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801074b9:	83 ec 08             	sub    $0x8,%esp
801074bc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801074bf:	52                   	push   %edx
801074c0:	50                   	push   %eax
801074c1:	e8 28 b1 ff ff       	call   801025ee <nameiparent>
801074c6:	83 c4 10             	add    $0x10,%esp
801074c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801074cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801074d0:	74 71                	je     80107543 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801074d2:	83 ec 0c             	sub    $0xc,%esp
801074d5:	ff 75 f0             	pushl  -0x10(%ebp)
801074d8:	e8 37 a5 ff ff       	call   80101a14 <ilock>
801074dd:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801074e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074e3:	8b 10                	mov    (%eax),%edx
801074e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e8:	8b 00                	mov    (%eax),%eax
801074ea:	39 c2                	cmp    %eax,%edx
801074ec:	75 1d                	jne    8010750b <sys_link+0x122>
801074ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f1:	8b 40 04             	mov    0x4(%eax),%eax
801074f4:	83 ec 04             	sub    $0x4,%esp
801074f7:	50                   	push   %eax
801074f8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801074fb:	50                   	push   %eax
801074fc:	ff 75 f0             	pushl  -0x10(%ebp)
801074ff:	e8 32 ae ff ff       	call   80102336 <dirlink>
80107504:	83 c4 10             	add    $0x10,%esp
80107507:	85 c0                	test   %eax,%eax
80107509:	79 10                	jns    8010751b <sys_link+0x132>
    iunlockput(dp);
8010750b:	83 ec 0c             	sub    $0xc,%esp
8010750e:	ff 75 f0             	pushl  -0x10(%ebp)
80107511:	e8 be a7 ff ff       	call   80101cd4 <iunlockput>
80107516:	83 c4 10             	add    $0x10,%esp
    goto bad;
80107519:	eb 29                	jmp    80107544 <sys_link+0x15b>
  }
  iunlockput(dp);
8010751b:	83 ec 0c             	sub    $0xc,%esp
8010751e:	ff 75 f0             	pushl  -0x10(%ebp)
80107521:	e8 ae a7 ff ff       	call   80101cd4 <iunlockput>
80107526:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80107529:	83 ec 0c             	sub    $0xc,%esp
8010752c:	ff 75 f4             	pushl  -0xc(%ebp)
8010752f:	e8 b0 a6 ff ff       	call   80101be4 <iput>
80107534:	83 c4 10             	add    $0x10,%esp

  end_op();
80107537:	e8 47 c1 ff ff       	call   80103683 <end_op>

  return 0;
8010753c:	b8 00 00 00 00       	mov    $0x0,%eax
80107541:	eb 48                	jmp    8010758b <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80107543:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80107544:	83 ec 0c             	sub    $0xc,%esp
80107547:	ff 75 f4             	pushl  -0xc(%ebp)
8010754a:	e8 c5 a4 ff ff       	call   80101a14 <ilock>
8010754f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107559:	83 e8 01             	sub    $0x1,%eax
8010755c:	89 c2                	mov    %eax,%edx
8010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107561:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107565:	83 ec 0c             	sub    $0xc,%esp
80107568:	ff 75 f4             	pushl  -0xc(%ebp)
8010756b:	e8 ca a2 ff ff       	call   8010183a <iupdate>
80107570:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80107573:	83 ec 0c             	sub    $0xc,%esp
80107576:	ff 75 f4             	pushl  -0xc(%ebp)
80107579:	e8 56 a7 ff ff       	call   80101cd4 <iunlockput>
8010757e:	83 c4 10             	add    $0x10,%esp
  end_op();
80107581:	e8 fd c0 ff ff       	call   80103683 <end_op>
  return -1;
80107586:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010758b:	c9                   	leave  
8010758c:	c3                   	ret    

8010758d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010758d:	55                   	push   %ebp
8010758e:	89 e5                	mov    %esp,%ebp
80107590:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80107593:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010759a:	eb 40                	jmp    801075dc <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010759c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759f:	6a 10                	push   $0x10
801075a1:	50                   	push   %eax
801075a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801075a5:	50                   	push   %eax
801075a6:	ff 75 08             	pushl  0x8(%ebp)
801075a9:	e8 d4 a9 ff ff       	call   80101f82 <readi>
801075ae:	83 c4 10             	add    $0x10,%esp
801075b1:	83 f8 10             	cmp    $0x10,%eax
801075b4:	74 0d                	je     801075c3 <isdirempty+0x36>
      panic("isdirempty: readi");
801075b6:	83 ec 0c             	sub    $0xc,%esp
801075b9:	68 62 a8 10 80       	push   $0x8010a862
801075be:	e8 a3 8f ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801075c3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801075c7:	66 85 c0             	test   %ax,%ax
801075ca:	74 07                	je     801075d3 <isdirempty+0x46>
      return 0;
801075cc:	b8 00 00 00 00       	mov    $0x0,%eax
801075d1:	eb 1b                	jmp    801075ee <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801075d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d6:	83 c0 10             	add    $0x10,%eax
801075d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075dc:	8b 45 08             	mov    0x8(%ebp),%eax
801075df:	8b 50 18             	mov    0x18(%eax),%edx
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	39 c2                	cmp    %eax,%edx
801075e7:	77 b3                	ja     8010759c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801075e9:	b8 01 00 00 00       	mov    $0x1,%eax
}
801075ee:	c9                   	leave  
801075ef:	c3                   	ret    

801075f0 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801075f0:	55                   	push   %ebp
801075f1:	89 e5                	mov    %esp,%ebp
801075f3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801075f6:	83 ec 08             	sub    $0x8,%esp
801075f9:	8d 45 cc             	lea    -0x34(%ebp),%eax
801075fc:	50                   	push   %eax
801075fd:	6a 00                	push   $0x0
801075ff:	e8 a0 fa ff ff       	call   801070a4 <argstr>
80107604:	83 c4 10             	add    $0x10,%esp
80107607:	85 c0                	test   %eax,%eax
80107609:	79 0a                	jns    80107615 <sys_unlink+0x25>
    return -1;
8010760b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107610:	e9 bc 01 00 00       	jmp    801077d1 <sys_unlink+0x1e1>

  begin_op();
80107615:	e8 dd bf ff ff       	call   801035f7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010761a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010761d:	83 ec 08             	sub    $0x8,%esp
80107620:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80107623:	52                   	push   %edx
80107624:	50                   	push   %eax
80107625:	e8 c4 af ff ff       	call   801025ee <nameiparent>
8010762a:	83 c4 10             	add    $0x10,%esp
8010762d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107630:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107634:	75 0f                	jne    80107645 <sys_unlink+0x55>
    end_op();
80107636:	e8 48 c0 ff ff       	call   80103683 <end_op>
    return -1;
8010763b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107640:	e9 8c 01 00 00       	jmp    801077d1 <sys_unlink+0x1e1>
  }

  ilock(dp);
80107645:	83 ec 0c             	sub    $0xc,%esp
80107648:	ff 75 f4             	pushl  -0xc(%ebp)
8010764b:	e8 c4 a3 ff ff       	call   80101a14 <ilock>
80107650:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80107653:	83 ec 08             	sub    $0x8,%esp
80107656:	68 74 a8 10 80       	push   $0x8010a874
8010765b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010765e:	50                   	push   %eax
8010765f:	e8 fd ab ff ff       	call   80102261 <namecmp>
80107664:	83 c4 10             	add    $0x10,%esp
80107667:	85 c0                	test   %eax,%eax
80107669:	0f 84 4a 01 00 00    	je     801077b9 <sys_unlink+0x1c9>
8010766f:	83 ec 08             	sub    $0x8,%esp
80107672:	68 76 a8 10 80       	push   $0x8010a876
80107677:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010767a:	50                   	push   %eax
8010767b:	e8 e1 ab ff ff       	call   80102261 <namecmp>
80107680:	83 c4 10             	add    $0x10,%esp
80107683:	85 c0                	test   %eax,%eax
80107685:	0f 84 2e 01 00 00    	je     801077b9 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010768b:	83 ec 04             	sub    $0x4,%esp
8010768e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80107691:	50                   	push   %eax
80107692:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107695:	50                   	push   %eax
80107696:	ff 75 f4             	pushl  -0xc(%ebp)
80107699:	e8 de ab ff ff       	call   8010227c <dirlookup>
8010769e:	83 c4 10             	add    $0x10,%esp
801076a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076a8:	0f 84 0a 01 00 00    	je     801077b8 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801076ae:	83 ec 0c             	sub    $0xc,%esp
801076b1:	ff 75 f0             	pushl  -0x10(%ebp)
801076b4:	e8 5b a3 ff ff       	call   80101a14 <ilock>
801076b9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801076bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076bf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076c3:	66 85 c0             	test   %ax,%ax
801076c6:	7f 0d                	jg     801076d5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801076c8:	83 ec 0c             	sub    $0xc,%esp
801076cb:	68 79 a8 10 80       	push   $0x8010a879
801076d0:	e8 91 8e ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801076d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076d8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801076dc:	66 83 f8 01          	cmp    $0x1,%ax
801076e0:	75 25                	jne    80107707 <sys_unlink+0x117>
801076e2:	83 ec 0c             	sub    $0xc,%esp
801076e5:	ff 75 f0             	pushl  -0x10(%ebp)
801076e8:	e8 a0 fe ff ff       	call   8010758d <isdirempty>
801076ed:	83 c4 10             	add    $0x10,%esp
801076f0:	85 c0                	test   %eax,%eax
801076f2:	75 13                	jne    80107707 <sys_unlink+0x117>
    iunlockput(ip);
801076f4:	83 ec 0c             	sub    $0xc,%esp
801076f7:	ff 75 f0             	pushl  -0x10(%ebp)
801076fa:	e8 d5 a5 ff ff       	call   80101cd4 <iunlockput>
801076ff:	83 c4 10             	add    $0x10,%esp
    goto bad;
80107702:	e9 b2 00 00 00       	jmp    801077b9 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80107707:	83 ec 04             	sub    $0x4,%esp
8010770a:	6a 10                	push   $0x10
8010770c:	6a 00                	push   $0x0
8010770e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107711:	50                   	push   %eax
80107712:	e8 e3 f5 ff ff       	call   80106cfa <memset>
80107717:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010771a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010771d:	6a 10                	push   $0x10
8010771f:	50                   	push   %eax
80107720:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107723:	50                   	push   %eax
80107724:	ff 75 f4             	pushl  -0xc(%ebp)
80107727:	e8 ad a9 ff ff       	call   801020d9 <writei>
8010772c:	83 c4 10             	add    $0x10,%esp
8010772f:	83 f8 10             	cmp    $0x10,%eax
80107732:	74 0d                	je     80107741 <sys_unlink+0x151>
    panic("unlink: writei");
80107734:	83 ec 0c             	sub    $0xc,%esp
80107737:	68 8b a8 10 80       	push   $0x8010a88b
8010773c:	e8 25 8e ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80107741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107744:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107748:	66 83 f8 01          	cmp    $0x1,%ax
8010774c:	75 21                	jne    8010776f <sys_unlink+0x17f>
    dp->nlink--;
8010774e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107751:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107755:	83 e8 01             	sub    $0x1,%eax
80107758:	89 c2                	mov    %eax,%edx
8010775a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107761:	83 ec 0c             	sub    $0xc,%esp
80107764:	ff 75 f4             	pushl  -0xc(%ebp)
80107767:	e8 ce a0 ff ff       	call   8010183a <iupdate>
8010776c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010776f:	83 ec 0c             	sub    $0xc,%esp
80107772:	ff 75 f4             	pushl  -0xc(%ebp)
80107775:	e8 5a a5 ff ff       	call   80101cd4 <iunlockput>
8010777a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010777d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107780:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107784:	83 e8 01             	sub    $0x1,%eax
80107787:	89 c2                	mov    %eax,%edx
80107789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010778c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107790:	83 ec 0c             	sub    $0xc,%esp
80107793:	ff 75 f0             	pushl  -0x10(%ebp)
80107796:	e8 9f a0 ff ff       	call   8010183a <iupdate>
8010779b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010779e:	83 ec 0c             	sub    $0xc,%esp
801077a1:	ff 75 f0             	pushl  -0x10(%ebp)
801077a4:	e8 2b a5 ff ff       	call   80101cd4 <iunlockput>
801077a9:	83 c4 10             	add    $0x10,%esp

  end_op();
801077ac:	e8 d2 be ff ff       	call   80103683 <end_op>

  return 0;
801077b1:	b8 00 00 00 00       	mov    $0x0,%eax
801077b6:	eb 19                	jmp    801077d1 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801077b8:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801077b9:	83 ec 0c             	sub    $0xc,%esp
801077bc:	ff 75 f4             	pushl  -0xc(%ebp)
801077bf:	e8 10 a5 ff ff       	call   80101cd4 <iunlockput>
801077c4:	83 c4 10             	add    $0x10,%esp
  end_op();
801077c7:	e8 b7 be ff ff       	call   80103683 <end_op>
  return -1;
801077cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801077d1:	c9                   	leave  
801077d2:	c3                   	ret    

801077d3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801077d3:	55                   	push   %ebp
801077d4:	89 e5                	mov    %esp,%ebp
801077d6:	83 ec 38             	sub    $0x38,%esp
801077d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801077dc:	8b 55 10             	mov    0x10(%ebp),%edx
801077df:	8b 45 14             	mov    0x14(%ebp),%eax
801077e2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801077e6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801077ea:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801077ee:	83 ec 08             	sub    $0x8,%esp
801077f1:	8d 45 de             	lea    -0x22(%ebp),%eax
801077f4:	50                   	push   %eax
801077f5:	ff 75 08             	pushl  0x8(%ebp)
801077f8:	e8 f1 ad ff ff       	call   801025ee <nameiparent>
801077fd:	83 c4 10             	add    $0x10,%esp
80107800:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107803:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107807:	75 0a                	jne    80107813 <create+0x40>
    return 0;
80107809:	b8 00 00 00 00       	mov    $0x0,%eax
8010780e:	e9 90 01 00 00       	jmp    801079a3 <create+0x1d0>
  ilock(dp);
80107813:	83 ec 0c             	sub    $0xc,%esp
80107816:	ff 75 f4             	pushl  -0xc(%ebp)
80107819:	e8 f6 a1 ff ff       	call   80101a14 <ilock>
8010781e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80107821:	83 ec 04             	sub    $0x4,%esp
80107824:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107827:	50                   	push   %eax
80107828:	8d 45 de             	lea    -0x22(%ebp),%eax
8010782b:	50                   	push   %eax
8010782c:	ff 75 f4             	pushl  -0xc(%ebp)
8010782f:	e8 48 aa ff ff       	call   8010227c <dirlookup>
80107834:	83 c4 10             	add    $0x10,%esp
80107837:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010783a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010783e:	74 50                	je     80107890 <create+0xbd>
    iunlockput(dp);
80107840:	83 ec 0c             	sub    $0xc,%esp
80107843:	ff 75 f4             	pushl  -0xc(%ebp)
80107846:	e8 89 a4 ff ff       	call   80101cd4 <iunlockput>
8010784b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010784e:	83 ec 0c             	sub    $0xc,%esp
80107851:	ff 75 f0             	pushl  -0x10(%ebp)
80107854:	e8 bb a1 ff ff       	call   80101a14 <ilock>
80107859:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010785c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80107861:	75 15                	jne    80107878 <create+0xa5>
80107863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107866:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010786a:	66 83 f8 02          	cmp    $0x2,%ax
8010786e:	75 08                	jne    80107878 <create+0xa5>
      return ip;
80107870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107873:	e9 2b 01 00 00       	jmp    801079a3 <create+0x1d0>
    iunlockput(ip);
80107878:	83 ec 0c             	sub    $0xc,%esp
8010787b:	ff 75 f0             	pushl  -0x10(%ebp)
8010787e:	e8 51 a4 ff ff       	call   80101cd4 <iunlockput>
80107883:	83 c4 10             	add    $0x10,%esp
    return 0;
80107886:	b8 00 00 00 00       	mov    $0x0,%eax
8010788b:	e9 13 01 00 00       	jmp    801079a3 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80107890:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107897:	8b 00                	mov    (%eax),%eax
80107899:	83 ec 08             	sub    $0x8,%esp
8010789c:	52                   	push   %edx
8010789d:	50                   	push   %eax
8010789e:	e8 c0 9e ff ff       	call   80101763 <ialloc>
801078a3:	83 c4 10             	add    $0x10,%esp
801078a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078ad:	75 0d                	jne    801078bc <create+0xe9>
    panic("create: ialloc");
801078af:	83 ec 0c             	sub    $0xc,%esp
801078b2:	68 9a a8 10 80       	push   $0x8010a89a
801078b7:	e8 aa 8c ff ff       	call   80100566 <panic>

  ilock(ip);
801078bc:	83 ec 0c             	sub    $0xc,%esp
801078bf:	ff 75 f0             	pushl  -0x10(%ebp)
801078c2:	e8 4d a1 ff ff       	call   80101a14 <ilock>
801078c7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801078ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078cd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801078d1:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801078d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801078dc:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801078e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e3:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801078e9:	83 ec 0c             	sub    $0xc,%esp
801078ec:	ff 75 f0             	pushl  -0x10(%ebp)
801078ef:	e8 46 9f ff ff       	call   8010183a <iupdate>
801078f4:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801078f7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801078fc:	75 6a                	jne    80107968 <create+0x195>
    dp->nlink++;  // for ".."
801078fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107901:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107905:	83 c0 01             	add    $0x1,%eax
80107908:	89 c2                	mov    %eax,%edx
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107911:	83 ec 0c             	sub    $0xc,%esp
80107914:	ff 75 f4             	pushl  -0xc(%ebp)
80107917:	e8 1e 9f ff ff       	call   8010183a <iupdate>
8010791c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010791f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107922:	8b 40 04             	mov    0x4(%eax),%eax
80107925:	83 ec 04             	sub    $0x4,%esp
80107928:	50                   	push   %eax
80107929:	68 74 a8 10 80       	push   $0x8010a874
8010792e:	ff 75 f0             	pushl  -0x10(%ebp)
80107931:	e8 00 aa ff ff       	call   80102336 <dirlink>
80107936:	83 c4 10             	add    $0x10,%esp
80107939:	85 c0                	test   %eax,%eax
8010793b:	78 1e                	js     8010795b <create+0x188>
8010793d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107940:	8b 40 04             	mov    0x4(%eax),%eax
80107943:	83 ec 04             	sub    $0x4,%esp
80107946:	50                   	push   %eax
80107947:	68 76 a8 10 80       	push   $0x8010a876
8010794c:	ff 75 f0             	pushl  -0x10(%ebp)
8010794f:	e8 e2 a9 ff ff       	call   80102336 <dirlink>
80107954:	83 c4 10             	add    $0x10,%esp
80107957:	85 c0                	test   %eax,%eax
80107959:	79 0d                	jns    80107968 <create+0x195>
      panic("create dots");
8010795b:	83 ec 0c             	sub    $0xc,%esp
8010795e:	68 a9 a8 10 80       	push   $0x8010a8a9
80107963:	e8 fe 8b ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80107968:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010796b:	8b 40 04             	mov    0x4(%eax),%eax
8010796e:	83 ec 04             	sub    $0x4,%esp
80107971:	50                   	push   %eax
80107972:	8d 45 de             	lea    -0x22(%ebp),%eax
80107975:	50                   	push   %eax
80107976:	ff 75 f4             	pushl  -0xc(%ebp)
80107979:	e8 b8 a9 ff ff       	call   80102336 <dirlink>
8010797e:	83 c4 10             	add    $0x10,%esp
80107981:	85 c0                	test   %eax,%eax
80107983:	79 0d                	jns    80107992 <create+0x1bf>
    panic("create: dirlink");
80107985:	83 ec 0c             	sub    $0xc,%esp
80107988:	68 b5 a8 10 80       	push   $0x8010a8b5
8010798d:	e8 d4 8b ff ff       	call   80100566 <panic>

  iunlockput(dp);
80107992:	83 ec 0c             	sub    $0xc,%esp
80107995:	ff 75 f4             	pushl  -0xc(%ebp)
80107998:	e8 37 a3 ff ff       	call   80101cd4 <iunlockput>
8010799d:	83 c4 10             	add    $0x10,%esp

  return ip;
801079a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801079a3:	c9                   	leave  
801079a4:	c3                   	ret    

801079a5 <sys_open>:

int
sys_open(void)
{
801079a5:	55                   	push   %ebp
801079a6:	89 e5                	mov    %esp,%ebp
801079a8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801079ab:	83 ec 08             	sub    $0x8,%esp
801079ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
801079b1:	50                   	push   %eax
801079b2:	6a 00                	push   $0x0
801079b4:	e8 eb f6 ff ff       	call   801070a4 <argstr>
801079b9:	83 c4 10             	add    $0x10,%esp
801079bc:	85 c0                	test   %eax,%eax
801079be:	78 15                	js     801079d5 <sys_open+0x30>
801079c0:	83 ec 08             	sub    $0x8,%esp
801079c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801079c6:	50                   	push   %eax
801079c7:	6a 01                	push   $0x1
801079c9:	e8 51 f6 ff ff       	call   8010701f <argint>
801079ce:	83 c4 10             	add    $0x10,%esp
801079d1:	85 c0                	test   %eax,%eax
801079d3:	79 0a                	jns    801079df <sys_open+0x3a>
    return -1;
801079d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079da:	e9 61 01 00 00       	jmp    80107b40 <sys_open+0x19b>

  begin_op();
801079df:	e8 13 bc ff ff       	call   801035f7 <begin_op>

  if(omode & O_CREATE){
801079e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079e7:	25 00 02 00 00       	and    $0x200,%eax
801079ec:	85 c0                	test   %eax,%eax
801079ee:	74 2a                	je     80107a1a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801079f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801079f3:	6a 00                	push   $0x0
801079f5:	6a 00                	push   $0x0
801079f7:	6a 02                	push   $0x2
801079f9:	50                   	push   %eax
801079fa:	e8 d4 fd ff ff       	call   801077d3 <create>
801079ff:	83 c4 10             	add    $0x10,%esp
80107a02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80107a05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a09:	75 75                	jne    80107a80 <sys_open+0xdb>
      end_op();
80107a0b:	e8 73 bc ff ff       	call   80103683 <end_op>
      return -1;
80107a10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a15:	e9 26 01 00 00       	jmp    80107b40 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80107a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a1d:	83 ec 0c             	sub    $0xc,%esp
80107a20:	50                   	push   %eax
80107a21:	e8 ac ab ff ff       	call   801025d2 <namei>
80107a26:	83 c4 10             	add    $0x10,%esp
80107a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a30:	75 0f                	jne    80107a41 <sys_open+0x9c>
      end_op();
80107a32:	e8 4c bc ff ff       	call   80103683 <end_op>
      return -1;
80107a37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a3c:	e9 ff 00 00 00       	jmp    80107b40 <sys_open+0x19b>
    }
    ilock(ip);
80107a41:	83 ec 0c             	sub    $0xc,%esp
80107a44:	ff 75 f4             	pushl  -0xc(%ebp)
80107a47:	e8 c8 9f ff ff       	call   80101a14 <ilock>
80107a4c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80107a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a52:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107a56:	66 83 f8 01          	cmp    $0x1,%ax
80107a5a:	75 24                	jne    80107a80 <sys_open+0xdb>
80107a5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107a5f:	85 c0                	test   %eax,%eax
80107a61:	74 1d                	je     80107a80 <sys_open+0xdb>
      iunlockput(ip);
80107a63:	83 ec 0c             	sub    $0xc,%esp
80107a66:	ff 75 f4             	pushl  -0xc(%ebp)
80107a69:	e8 66 a2 ff ff       	call   80101cd4 <iunlockput>
80107a6e:	83 c4 10             	add    $0x10,%esp
      end_op();
80107a71:	e8 0d bc ff ff       	call   80103683 <end_op>
      return -1;
80107a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a7b:	e9 c0 00 00 00       	jmp    80107b40 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80107a80:	e8 b8 95 ff ff       	call   8010103d <filealloc>
80107a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a8c:	74 17                	je     80107aa5 <sys_open+0x100>
80107a8e:	83 ec 0c             	sub    $0xc,%esp
80107a91:	ff 75 f0             	pushl  -0x10(%ebp)
80107a94:	e8 37 f7 ff ff       	call   801071d0 <fdalloc>
80107a99:	83 c4 10             	add    $0x10,%esp
80107a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107aa3:	79 2e                	jns    80107ad3 <sys_open+0x12e>
    if(f)
80107aa5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107aa9:	74 0e                	je     80107ab9 <sys_open+0x114>
      fileclose(f);
80107aab:	83 ec 0c             	sub    $0xc,%esp
80107aae:	ff 75 f0             	pushl  -0x10(%ebp)
80107ab1:	e8 45 96 ff ff       	call   801010fb <fileclose>
80107ab6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107ab9:	83 ec 0c             	sub    $0xc,%esp
80107abc:	ff 75 f4             	pushl  -0xc(%ebp)
80107abf:	e8 10 a2 ff ff       	call   80101cd4 <iunlockput>
80107ac4:	83 c4 10             	add    $0x10,%esp
    end_op();
80107ac7:	e8 b7 bb ff ff       	call   80103683 <end_op>
    return -1;
80107acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ad1:	eb 6d                	jmp    80107b40 <sys_open+0x19b>
  }
  iunlock(ip);
80107ad3:	83 ec 0c             	sub    $0xc,%esp
80107ad6:	ff 75 f4             	pushl  -0xc(%ebp)
80107ad9:	e8 94 a0 ff ff       	call   80101b72 <iunlock>
80107ade:	83 c4 10             	add    $0x10,%esp
  end_op();
80107ae1:	e8 9d bb ff ff       	call   80103683 <end_op>

  f->type = FD_INODE;
80107ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ae9:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80107aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107af5:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80107af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107afb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80107b02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107b05:	83 e0 01             	and    $0x1,%eax
80107b08:	85 c0                	test   %eax,%eax
80107b0a:	0f 94 c0             	sete   %al
80107b0d:	89 c2                	mov    %eax,%edx
80107b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b12:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80107b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107b18:	83 e0 01             	and    $0x1,%eax
80107b1b:	85 c0                	test   %eax,%eax
80107b1d:	75 0a                	jne    80107b29 <sys_open+0x184>
80107b1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107b22:	83 e0 02             	and    $0x2,%eax
80107b25:	85 c0                	test   %eax,%eax
80107b27:	74 07                	je     80107b30 <sys_open+0x18b>
80107b29:	b8 01 00 00 00       	mov    $0x1,%eax
80107b2e:	eb 05                	jmp    80107b35 <sys_open+0x190>
80107b30:	b8 00 00 00 00       	mov    $0x0,%eax
80107b35:	89 c2                	mov    %eax,%edx
80107b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b3a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80107b3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107b40:	c9                   	leave  
80107b41:	c3                   	ret    

80107b42 <sys_mkdir>:

int
sys_mkdir(void)
{
80107b42:	55                   	push   %ebp
80107b43:	89 e5                	mov    %esp,%ebp
80107b45:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107b48:	e8 aa ba ff ff       	call   801035f7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80107b4d:	83 ec 08             	sub    $0x8,%esp
80107b50:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107b53:	50                   	push   %eax
80107b54:	6a 00                	push   $0x0
80107b56:	e8 49 f5 ff ff       	call   801070a4 <argstr>
80107b5b:	83 c4 10             	add    $0x10,%esp
80107b5e:	85 c0                	test   %eax,%eax
80107b60:	78 1b                	js     80107b7d <sys_mkdir+0x3b>
80107b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b65:	6a 00                	push   $0x0
80107b67:	6a 00                	push   $0x0
80107b69:	6a 01                	push   $0x1
80107b6b:	50                   	push   %eax
80107b6c:	e8 62 fc ff ff       	call   801077d3 <create>
80107b71:	83 c4 10             	add    $0x10,%esp
80107b74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b7b:	75 0c                	jne    80107b89 <sys_mkdir+0x47>
    end_op();
80107b7d:	e8 01 bb ff ff       	call   80103683 <end_op>
    return -1;
80107b82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b87:	eb 18                	jmp    80107ba1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107b89:	83 ec 0c             	sub    $0xc,%esp
80107b8c:	ff 75 f4             	pushl  -0xc(%ebp)
80107b8f:	e8 40 a1 ff ff       	call   80101cd4 <iunlockput>
80107b94:	83 c4 10             	add    $0x10,%esp
  end_op();
80107b97:	e8 e7 ba ff ff       	call   80103683 <end_op>
  return 0;
80107b9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ba1:	c9                   	leave  
80107ba2:	c3                   	ret    

80107ba3 <sys_mknod>:

int
sys_mknod(void)
{
80107ba3:	55                   	push   %ebp
80107ba4:	89 e5                	mov    %esp,%ebp
80107ba6:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107ba9:	e8 49 ba ff ff       	call   801035f7 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80107bae:	83 ec 08             	sub    $0x8,%esp
80107bb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107bb4:	50                   	push   %eax
80107bb5:	6a 00                	push   $0x0
80107bb7:	e8 e8 f4 ff ff       	call   801070a4 <argstr>
80107bbc:	83 c4 10             	add    $0x10,%esp
80107bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bc6:	78 4f                	js     80107c17 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107bc8:	83 ec 08             	sub    $0x8,%esp
80107bcb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107bce:	50                   	push   %eax
80107bcf:	6a 01                	push   $0x1
80107bd1:	e8 49 f4 ff ff       	call   8010701f <argint>
80107bd6:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80107bd9:	85 c0                	test   %eax,%eax
80107bdb:	78 3a                	js     80107c17 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107bdd:	83 ec 08             	sub    $0x8,%esp
80107be0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107be3:	50                   	push   %eax
80107be4:	6a 02                	push   $0x2
80107be6:	e8 34 f4 ff ff       	call   8010701f <argint>
80107beb:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80107bee:	85 c0                	test   %eax,%eax
80107bf0:	78 25                	js     80107c17 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80107bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107bf5:	0f bf c8             	movswl %ax,%ecx
80107bf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107bfb:	0f bf d0             	movswl %ax,%edx
80107bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107c01:	51                   	push   %ecx
80107c02:	52                   	push   %edx
80107c03:	6a 03                	push   $0x3
80107c05:	50                   	push   %eax
80107c06:	e8 c8 fb ff ff       	call   801077d3 <create>
80107c0b:	83 c4 10             	add    $0x10,%esp
80107c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c15:	75 0c                	jne    80107c23 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80107c17:	e8 67 ba ff ff       	call   80103683 <end_op>
    return -1;
80107c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c21:	eb 18                	jmp    80107c3b <sys_mknod+0x98>
  }
  iunlockput(ip);
80107c23:	83 ec 0c             	sub    $0xc,%esp
80107c26:	ff 75 f0             	pushl  -0x10(%ebp)
80107c29:	e8 a6 a0 ff ff       	call   80101cd4 <iunlockput>
80107c2e:	83 c4 10             	add    $0x10,%esp
  end_op();
80107c31:	e8 4d ba ff ff       	call   80103683 <end_op>
  return 0;
80107c36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c3b:	c9                   	leave  
80107c3c:	c3                   	ret    

80107c3d <sys_chdir>:

int
sys_chdir(void)
{
80107c3d:	55                   	push   %ebp
80107c3e:	89 e5                	mov    %esp,%ebp
80107c40:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107c43:	e8 af b9 ff ff       	call   801035f7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107c48:	83 ec 08             	sub    $0x8,%esp
80107c4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107c4e:	50                   	push   %eax
80107c4f:	6a 00                	push   $0x0
80107c51:	e8 4e f4 ff ff       	call   801070a4 <argstr>
80107c56:	83 c4 10             	add    $0x10,%esp
80107c59:	85 c0                	test   %eax,%eax
80107c5b:	78 18                	js     80107c75 <sys_chdir+0x38>
80107c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c60:	83 ec 0c             	sub    $0xc,%esp
80107c63:	50                   	push   %eax
80107c64:	e8 69 a9 ff ff       	call   801025d2 <namei>
80107c69:	83 c4 10             	add    $0x10,%esp
80107c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c73:	75 0c                	jne    80107c81 <sys_chdir+0x44>
    end_op();
80107c75:	e8 09 ba ff ff       	call   80103683 <end_op>
    return -1;
80107c7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c7f:	eb 6e                	jmp    80107cef <sys_chdir+0xb2>
  }
  ilock(ip);
80107c81:	83 ec 0c             	sub    $0xc,%esp
80107c84:	ff 75 f4             	pushl  -0xc(%ebp)
80107c87:	e8 88 9d ff ff       	call   80101a14 <ilock>
80107c8c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107c96:	66 83 f8 01          	cmp    $0x1,%ax
80107c9a:	74 1a                	je     80107cb6 <sys_chdir+0x79>
    iunlockput(ip);
80107c9c:	83 ec 0c             	sub    $0xc,%esp
80107c9f:	ff 75 f4             	pushl  -0xc(%ebp)
80107ca2:	e8 2d a0 ff ff       	call   80101cd4 <iunlockput>
80107ca7:	83 c4 10             	add    $0x10,%esp
    end_op();
80107caa:	e8 d4 b9 ff ff       	call   80103683 <end_op>
    return -1;
80107caf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cb4:	eb 39                	jmp    80107cef <sys_chdir+0xb2>
  }
  iunlock(ip);
80107cb6:	83 ec 0c             	sub    $0xc,%esp
80107cb9:	ff 75 f4             	pushl  -0xc(%ebp)
80107cbc:	e8 b1 9e ff ff       	call   80101b72 <iunlock>
80107cc1:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107cc4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107cca:	8b 40 68             	mov    0x68(%eax),%eax
80107ccd:	83 ec 0c             	sub    $0xc,%esp
80107cd0:	50                   	push   %eax
80107cd1:	e8 0e 9f ff ff       	call   80101be4 <iput>
80107cd6:	83 c4 10             	add    $0x10,%esp
  end_op();
80107cd9:	e8 a5 b9 ff ff       	call   80103683 <end_op>
  proc->cwd = ip;
80107cde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ce7:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cef:	c9                   	leave  
80107cf0:	c3                   	ret    

80107cf1 <sys_exec>:

int
sys_exec(void)
{
80107cf1:	55                   	push   %ebp
80107cf2:	89 e5                	mov    %esp,%ebp
80107cf4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107cfa:	83 ec 08             	sub    $0x8,%esp
80107cfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d00:	50                   	push   %eax
80107d01:	6a 00                	push   $0x0
80107d03:	e8 9c f3 ff ff       	call   801070a4 <argstr>
80107d08:	83 c4 10             	add    $0x10,%esp
80107d0b:	85 c0                	test   %eax,%eax
80107d0d:	78 18                	js     80107d27 <sys_exec+0x36>
80107d0f:	83 ec 08             	sub    $0x8,%esp
80107d12:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107d18:	50                   	push   %eax
80107d19:	6a 01                	push   $0x1
80107d1b:	e8 ff f2 ff ff       	call   8010701f <argint>
80107d20:	83 c4 10             	add    $0x10,%esp
80107d23:	85 c0                	test   %eax,%eax
80107d25:	79 0a                	jns    80107d31 <sys_exec+0x40>
    return -1;
80107d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d2c:	e9 c6 00 00 00       	jmp    80107df7 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107d31:	83 ec 04             	sub    $0x4,%esp
80107d34:	68 80 00 00 00       	push   $0x80
80107d39:	6a 00                	push   $0x0
80107d3b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107d41:	50                   	push   %eax
80107d42:	e8 b3 ef ff ff       	call   80106cfa <memset>
80107d47:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107d4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d54:	83 f8 1f             	cmp    $0x1f,%eax
80107d57:	76 0a                	jbe    80107d63 <sys_exec+0x72>
      return -1;
80107d59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d5e:	e9 94 00 00 00       	jmp    80107df7 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d66:	c1 e0 02             	shl    $0x2,%eax
80107d69:	89 c2                	mov    %eax,%edx
80107d6b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107d71:	01 c2                	add    %eax,%edx
80107d73:	83 ec 08             	sub    $0x8,%esp
80107d76:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107d7c:	50                   	push   %eax
80107d7d:	52                   	push   %edx
80107d7e:	e8 00 f2 ff ff       	call   80106f83 <fetchint>
80107d83:	83 c4 10             	add    $0x10,%esp
80107d86:	85 c0                	test   %eax,%eax
80107d88:	79 07                	jns    80107d91 <sys_exec+0xa0>
      return -1;
80107d8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d8f:	eb 66                	jmp    80107df7 <sys_exec+0x106>
    if(uarg == 0){
80107d91:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107d97:	85 c0                	test   %eax,%eax
80107d99:	75 27                	jne    80107dc2 <sys_exec+0xd1>
      argv[i] = 0;
80107d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107da5:	00 00 00 00 
      break;
80107da9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107daa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dad:	83 ec 08             	sub    $0x8,%esp
80107db0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107db6:	52                   	push   %edx
80107db7:	50                   	push   %eax
80107db8:	e8 5e 8e ff ff       	call   80100c1b <exec>
80107dbd:	83 c4 10             	add    $0x10,%esp
80107dc0:	eb 35                	jmp    80107df7 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107dc2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107dc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107dcb:	c1 e2 02             	shl    $0x2,%edx
80107dce:	01 c2                	add    %eax,%edx
80107dd0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107dd6:	83 ec 08             	sub    $0x8,%esp
80107dd9:	52                   	push   %edx
80107dda:	50                   	push   %eax
80107ddb:	e8 dd f1 ff ff       	call   80106fbd <fetchstr>
80107de0:	83 c4 10             	add    $0x10,%esp
80107de3:	85 c0                	test   %eax,%eax
80107de5:	79 07                	jns    80107dee <sys_exec+0xfd>
      return -1;
80107de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dec:	eb 09                	jmp    80107df7 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107dee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107df2:	e9 5a ff ff ff       	jmp    80107d51 <sys_exec+0x60>
  return exec(path, argv);
}
80107df7:	c9                   	leave  
80107df8:	c3                   	ret    

80107df9 <sys_pipe>:

int
sys_pipe(void)
{
80107df9:	55                   	push   %ebp
80107dfa:	89 e5                	mov    %esp,%ebp
80107dfc:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107dff:	83 ec 04             	sub    $0x4,%esp
80107e02:	6a 08                	push   $0x8
80107e04:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107e07:	50                   	push   %eax
80107e08:	6a 00                	push   $0x0
80107e0a:	e8 38 f2 ff ff       	call   80107047 <argptr>
80107e0f:	83 c4 10             	add    $0x10,%esp
80107e12:	85 c0                	test   %eax,%eax
80107e14:	79 0a                	jns    80107e20 <sys_pipe+0x27>
    return -1;
80107e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e1b:	e9 af 00 00 00       	jmp    80107ecf <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80107e20:	83 ec 08             	sub    $0x8,%esp
80107e23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107e26:	50                   	push   %eax
80107e27:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107e2a:	50                   	push   %eax
80107e2b:	e8 bb c2 ff ff       	call   801040eb <pipealloc>
80107e30:	83 c4 10             	add    $0x10,%esp
80107e33:	85 c0                	test   %eax,%eax
80107e35:	79 0a                	jns    80107e41 <sys_pipe+0x48>
    return -1;
80107e37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e3c:	e9 8e 00 00 00       	jmp    80107ecf <sys_pipe+0xd6>
  fd0 = -1;
80107e41:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107e48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e4b:	83 ec 0c             	sub    $0xc,%esp
80107e4e:	50                   	push   %eax
80107e4f:	e8 7c f3 ff ff       	call   801071d0 <fdalloc>
80107e54:	83 c4 10             	add    $0x10,%esp
80107e57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e5e:	78 18                	js     80107e78 <sys_pipe+0x7f>
80107e60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e63:	83 ec 0c             	sub    $0xc,%esp
80107e66:	50                   	push   %eax
80107e67:	e8 64 f3 ff ff       	call   801071d0 <fdalloc>
80107e6c:	83 c4 10             	add    $0x10,%esp
80107e6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e76:	79 3f                	jns    80107eb7 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107e78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e7c:	78 14                	js     80107e92 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107e7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107e84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e87:	83 c2 08             	add    $0x8,%edx
80107e8a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107e91:	00 
    fileclose(rf);
80107e92:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e95:	83 ec 0c             	sub    $0xc,%esp
80107e98:	50                   	push   %eax
80107e99:	e8 5d 92 ff ff       	call   801010fb <fileclose>
80107e9e:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ea4:	83 ec 0c             	sub    $0xc,%esp
80107ea7:	50                   	push   %eax
80107ea8:	e8 4e 92 ff ff       	call   801010fb <fileclose>
80107ead:	83 c4 10             	add    $0x10,%esp
    return -1;
80107eb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eb5:	eb 18                	jmp    80107ecf <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107eb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ebd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec2:	8d 50 04             	lea    0x4(%eax),%edx
80107ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec8:	89 02                	mov    %eax,(%edx)
  return 0;
80107eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ecf:	c9                   	leave  
80107ed0:	c3                   	ret    

80107ed1 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107ed1:	55                   	push   %ebp
80107ed2:	89 e5                	mov    %esp,%ebp
80107ed4:	83 ec 08             	sub    $0x8,%esp
80107ed7:	8b 55 08             	mov    0x8(%ebp),%edx
80107eda:	8b 45 0c             	mov    0xc(%ebp),%eax
80107edd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107ee1:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107ee5:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107ee9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107eed:	66 ef                	out    %ax,(%dx)
}
80107eef:	90                   	nop
80107ef0:	c9                   	leave  
80107ef1:	c3                   	ret    

80107ef2 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107ef2:	55                   	push   %ebp
80107ef3:	89 e5                	mov    %esp,%ebp
80107ef5:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107ef8:	e8 10 cd ff ff       	call   80104c0d <fork>
}
80107efd:	c9                   	leave  
80107efe:	c3                   	ret    

80107eff <sys_exit>:

int
sys_exit(void)
{
80107eff:	55                   	push   %ebp
80107f00:	89 e5                	mov    %esp,%ebp
80107f02:	83 ec 08             	sub    $0x8,%esp
  exit();
80107f05:	e8 35 cf ff ff       	call   80104e3f <exit>
  return 0;  // not reached
80107f0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f0f:	c9                   	leave  
80107f10:	c3                   	ret    

80107f11 <sys_wait>:

int
sys_wait(void)
{
80107f11:	55                   	push   %ebp
80107f12:	89 e5                	mov    %esp,%ebp
80107f14:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107f17:	e8 a8 d1 ff ff       	call   801050c4 <wait>
}
80107f1c:	c9                   	leave  
80107f1d:	c3                   	ret    

80107f1e <sys_kill>:

int
sys_kill(void)
{
80107f1e:	55                   	push   %ebp
80107f1f:	89 e5                	mov    %esp,%ebp
80107f21:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107f24:	83 ec 08             	sub    $0x8,%esp
80107f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107f2a:	50                   	push   %eax
80107f2b:	6a 00                	push   $0x0
80107f2d:	e8 ed f0 ff ff       	call   8010701f <argint>
80107f32:	83 c4 10             	add    $0x10,%esp
80107f35:	85 c0                	test   %eax,%eax
80107f37:	79 07                	jns    80107f40 <sys_kill+0x22>
    return -1;
80107f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f3e:	eb 0f                	jmp    80107f4f <sys_kill+0x31>
  return kill(pid);
80107f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f43:	83 ec 0c             	sub    $0xc,%esp
80107f46:	50                   	push   %eax
80107f47:	e8 7d da ff ff       	call   801059c9 <kill>
80107f4c:	83 c4 10             	add    $0x10,%esp
}
80107f4f:	c9                   	leave  
80107f50:	c3                   	ret    

80107f51 <sys_getpid>:

int
sys_getpid(void)
{
80107f51:	55                   	push   %ebp
80107f52:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107f54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f5a:	8b 40 10             	mov    0x10(%eax),%eax
}
80107f5d:	5d                   	pop    %ebp
80107f5e:	c3                   	ret    

80107f5f <sys_sbrk>:

int
sys_sbrk(void)
{
80107f5f:	55                   	push   %ebp
80107f60:	89 e5                	mov    %esp,%ebp
80107f62:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107f65:	83 ec 08             	sub    $0x8,%esp
80107f68:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f6b:	50                   	push   %eax
80107f6c:	6a 00                	push   $0x0
80107f6e:	e8 ac f0 ff ff       	call   8010701f <argint>
80107f73:	83 c4 10             	add    $0x10,%esp
80107f76:	85 c0                	test   %eax,%eax
80107f78:	79 07                	jns    80107f81 <sys_sbrk+0x22>
    return -1;
80107f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f7f:	eb 28                	jmp    80107fa9 <sys_sbrk+0x4a>
  addr = proc->sz;
80107f81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f87:	8b 00                	mov    (%eax),%eax
80107f89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8f:	83 ec 0c             	sub    $0xc,%esp
80107f92:	50                   	push   %eax
80107f93:	e8 d2 cb ff ff       	call   80104b6a <growproc>
80107f98:	83 c4 10             	add    $0x10,%esp
80107f9b:	85 c0                	test   %eax,%eax
80107f9d:	79 07                	jns    80107fa6 <sys_sbrk+0x47>
    return -1;
80107f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fa4:	eb 03                	jmp    80107fa9 <sys_sbrk+0x4a>
  return addr;
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax

    cprintf("Implement this");
}
80107fa9:	c9                   	leave  
80107faa:	c3                   	ret    

80107fab <sys_sleep>:
int
sys_sleep(void)
{
80107fab:	55                   	push   %ebp
80107fac:	89 e5                	mov    %esp,%ebp
80107fae:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107fb1:	83 ec 08             	sub    $0x8,%esp
80107fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107fb7:	50                   	push   %eax
80107fb8:	6a 00                	push   $0x0
80107fba:	e8 60 f0 ff ff       	call   8010701f <argint>
80107fbf:	83 c4 10             	add    $0x10,%esp
80107fc2:	85 c0                	test   %eax,%eax
80107fc4:	79 07                	jns    80107fcd <sys_sleep+0x22>
    return -1;
80107fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fcb:	eb 44                	jmp    80108011 <sys_sleep+0x66>
  ticks0 = ticks;
80107fcd:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80107fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107fd5:	eb 26                	jmp    80107ffd <sys_sleep+0x52>
    if(proc->killed){
80107fd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107fdd:	8b 40 24             	mov    0x24(%eax),%eax
80107fe0:	85 c0                	test   %eax,%eax
80107fe2:	74 07                	je     80107feb <sys_sleep+0x40>
      return -1;
80107fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fe9:	eb 26                	jmp    80108011 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107feb:	83 ec 08             	sub    $0x8,%esp
80107fee:	6a 00                	push   $0x0
80107ff0:	68 e0 78 11 80       	push   $0x801178e0
80107ff5:	e8 88 d7 ff ff       	call   80105782 <sleep>
80107ffa:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107ffd:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80108002:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108005:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108008:	39 d0                	cmp    %edx,%eax
8010800a:	72 cb                	jb     80107fd7 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
8010800c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108011:	c9                   	leave  
80108012:	c3                   	ret    

80108013 <sys_date>:
#ifdef CS333_P1
int
sys_date(void)
{
80108013:	55                   	push   %ebp
80108014:	89 e5                	mov    %esp,%ebp
80108016:	83 ec 18             	sub    $0x18,%esp
    struct rtcdate *d;
   
    if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80108019:	83 ec 04             	sub    $0x4,%esp
8010801c:	6a 18                	push   $0x18
8010801e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108021:	50                   	push   %eax
80108022:	6a 00                	push   $0x0
80108024:	e8 1e f0 ff ff       	call   80107047 <argptr>
80108029:	83 c4 10             	add    $0x10,%esp
8010802c:	85 c0                	test   %eax,%eax
8010802e:	79 07                	jns    80108037 <sys_date+0x24>
	return -1;
80108030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108035:	eb 14                	jmp    8010804b <sys_date+0x38>

    cmostime(d);
80108037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803a:	83 ec 0c             	sub    $0xc,%esp
8010803d:	50                   	push   %eax
8010803e:	e8 2f b2 ff ff       	call   80103272 <cmostime>
80108043:	83 c4 10             	add    $0x10,%esp
    return 0;
80108046:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010804b:	c9                   	leave  
8010804c:	c3                   	ret    

8010804d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
8010804d:	55                   	push   %ebp
8010804e:	89 e5                	mov    %esp,%ebp
80108050:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
80108053:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80108058:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
8010805b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010805e:	c9                   	leave  
8010805f:	c3                   	ret    

80108060 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80108060:	55                   	push   %ebp
80108061:	89 e5                	mov    %esp,%ebp
80108063:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80108066:	83 ec 0c             	sub    $0xc,%esp
80108069:	68 c8 a8 10 80       	push   $0x8010a8c8
8010806e:	e8 53 83 ff ff       	call   801003c6 <cprintf>
80108073:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80108076:	83 ec 08             	sub    $0x8,%esp
80108079:	68 00 20 00 00       	push   $0x2000
8010807e:	68 04 06 00 00       	push   $0x604
80108083:	e8 49 fe ff ff       	call   80107ed1 <outw>
80108088:	83 c4 10             	add    $0x10,%esp
  return 0;
8010808b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108090:	c9                   	leave  
80108091:	c3                   	ret    

80108092 <sys_getuid>:

#ifdef CS333_P2
int 
sys_getuid(void)
{
80108092:	55                   	push   %ebp
80108093:	89 e5                	mov    %esp,%ebp
    return proc -> uid;
80108095:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010809b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801080a1:	5d                   	pop    %ebp
801080a2:	c3                   	ret    

801080a3 <sys_getgid>:

int 
sys_getgid(void)
{
801080a3:	55                   	push   %ebp
801080a4:	89 e5                	mov    %esp,%ebp
    return proc -> gid;
801080a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801080ac:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801080b2:	5d                   	pop    %ebp
801080b3:	c3                   	ret    

801080b4 <sys_getppid>:

int 
sys_getppid(void)
{
801080b4:	55                   	push   %ebp
801080b5:	89 e5                	mov    %esp,%ebp
    if(proc -> parent)
801080b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801080bd:	8b 40 14             	mov    0x14(%eax),%eax
801080c0:	85 c0                	test   %eax,%eax
801080c2:	74 0e                	je     801080d2 <sys_getppid+0x1e>
	return proc -> parent -> pid;
801080c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801080ca:	8b 40 14             	mov    0x14(%eax),%eax
801080cd:	8b 40 10             	mov    0x10(%eax),%eax
801080d0:	eb 05                	jmp    801080d7 <sys_getppid+0x23>
    else
	return 1;
801080d2:	b8 01 00 00 00       	mov    $0x1,%eax
}
801080d7:	5d                   	pop    %ebp
801080d8:	c3                   	ret    

801080d9 <sys_setuid>:

int 
sys_setuid(void)
{
801080d9:	55                   	push   %ebp
801080da:	89 e5                	mov    %esp,%ebp
801080dc:	83 ec 18             	sub    $0x18,%esp
    int uid;

    if(argint(0, &uid) < 0)
801080df:	83 ec 08             	sub    $0x8,%esp
801080e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801080e5:	50                   	push   %eax
801080e6:	6a 00                	push   $0x0
801080e8:	e8 32 ef ff ff       	call   8010701f <argint>
801080ed:	83 c4 10             	add    $0x10,%esp
801080f0:	85 c0                	test   %eax,%eax
801080f2:	79 07                	jns    801080fb <sys_setuid+0x22>
	return -1;
801080f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080f9:	eb 2d                	jmp    80108128 <sys_setuid+0x4f>
    if(uid > 32767 || uid < 0)
801080fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fe:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108103:	7f 07                	jg     8010810c <sys_setuid+0x33>
80108105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108108:	85 c0                	test   %eax,%eax
8010810a:	79 07                	jns    80108113 <sys_setuid+0x3a>
	return -1;
8010810c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108111:	eb 15                	jmp    80108128 <sys_setuid+0x4f>
    else
	return proc -> uid = uid;
80108113:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108119:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010811c:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
80108122:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80108128:	c9                   	leave  
80108129:	c3                   	ret    

8010812a <sys_setgid>:

int 
sys_setgid(void)
{
8010812a:	55                   	push   %ebp
8010812b:	89 e5                	mov    %esp,%ebp
8010812d:	83 ec 18             	sub    $0x18,%esp
    int gid;

    if(argint(0, &gid) < 0)
80108130:	83 ec 08             	sub    $0x8,%esp
80108133:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108136:	50                   	push   %eax
80108137:	6a 00                	push   $0x0
80108139:	e8 e1 ee ff ff       	call   8010701f <argint>
8010813e:	83 c4 10             	add    $0x10,%esp
80108141:	85 c0                	test   %eax,%eax
80108143:	79 07                	jns    8010814c <sys_setgid+0x22>
	return -1;
80108145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010814a:	eb 2d                	jmp    80108179 <sys_setgid+0x4f>
    if(gid > 32767 || gid < 0)
8010814c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814f:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108154:	7f 07                	jg     8010815d <sys_setgid+0x33>
80108156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108159:	85 c0                	test   %eax,%eax
8010815b:	79 07                	jns    80108164 <sys_setgid+0x3a>
	return -1;
8010815d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108162:	eb 15                	jmp    80108179 <sys_setgid+0x4f>
    else
	return proc -> gid = gid;
80108164:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010816a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010816d:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
80108173:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80108179:	c9                   	leave  
8010817a:	c3                   	ret    

8010817b <sys_getprocs>:

int
sys_getprocs(void)
{
8010817b:	55                   	push   %ebp
8010817c:	89 e5                	mov    %esp,%ebp
8010817e:	83 ec 18             	sub    $0x18,%esp
    int num;
    struct uproc *procarray;

    if(argint(0, &num) < 0)
80108181:	83 ec 08             	sub    $0x8,%esp
80108184:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108187:	50                   	push   %eax
80108188:	6a 00                	push   $0x0
8010818a:	e8 90 ee ff ff       	call   8010701f <argint>
8010818f:	83 c4 10             	add    $0x10,%esp
80108192:	85 c0                	test   %eax,%eax
80108194:	79 07                	jns    8010819d <sys_getprocs+0x22>
	return -1;
80108196:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010819b:	eb 36                	jmp    801081d3 <sys_getprocs+0x58>
    
    if(argptr(1, (void*)&procarray, sizeof(struct uproc)) < 0)
8010819d:	83 ec 04             	sub    $0x4,%esp
801081a0:	6a 60                	push   $0x60
801081a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801081a5:	50                   	push   %eax
801081a6:	6a 01                	push   $0x1
801081a8:	e8 9a ee ff ff       	call   80107047 <argptr>
801081ad:	83 c4 10             	add    $0x10,%esp
801081b0:	85 c0                	test   %eax,%eax
801081b2:	79 07                	jns    801081bb <sys_getprocs+0x40>
	return -1;
801081b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081b9:	eb 18                	jmp    801081d3 <sys_getprocs+0x58>

   getproctable(num, procarray);
801081bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081c1:	83 ec 08             	sub    $0x8,%esp
801081c4:	50                   	push   %eax
801081c5:	52                   	push   %edx
801081c6:	e8 0f de ff ff       	call   80105fda <getproctable>
801081cb:	83 c4 10             	add    $0x10,%esp
   return 1;
801081ce:	b8 01 00 00 00       	mov    $0x1,%eax
}
801081d3:	c9                   	leave  
801081d4:	c3                   	ret    

801081d5 <sys_setpriority>:
#endif
#ifdef CS333_P3P4
int
sys_setpriority(void)
{
801081d5:	55                   	push   %ebp
801081d6:	89 e5                	mov    %esp,%ebp
801081d8:	83 ec 18             	sub    $0x18,%esp
    int pid, prio;

    if(argint(0, &pid) < 0)
801081db:	83 ec 08             	sub    $0x8,%esp
801081de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801081e1:	50                   	push   %eax
801081e2:	6a 00                	push   $0x0
801081e4:	e8 36 ee ff ff       	call   8010701f <argint>
801081e9:	83 c4 10             	add    $0x10,%esp
801081ec:	85 c0                	test   %eax,%eax
801081ee:	79 07                	jns    801081f7 <sys_setpriority+0x22>
	return -1;
801081f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081f5:	eb 7e                	jmp    80108275 <sys_setpriority+0xa0>

    if(argint(1, &prio) < 0)
801081f7:	83 ec 08             	sub    $0x8,%esp
801081fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801081fd:	50                   	push   %eax
801081fe:	6a 01                	push   $0x1
80108200:	e8 1a ee ff ff       	call   8010701f <argint>
80108205:	83 c4 10             	add    $0x10,%esp
80108208:	85 c0                	test   %eax,%eax
8010820a:	79 07                	jns    80108213 <sys_setpriority+0x3e>
	return -1;
8010820c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108211:	eb 62                	jmp    80108275 <sys_setpriority+0xa0>
    
    if(prio < 0 || prio > MAX){
80108213:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108216:	85 c0                	test   %eax,%eax
80108218:	78 08                	js     80108222 <sys_setpriority+0x4d>
8010821a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010821d:	83 f8 04             	cmp    $0x4,%eax
80108220:	7e 1d                	jle    8010823f <sys_setpriority+0x6a>
	cprintf("\nPriority: %d out of bounds, enter a value between 0 and %d\n", prio, MAX);
80108222:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108225:	83 ec 04             	sub    $0x4,%esp
80108228:	6a 04                	push   $0x4
8010822a:	50                   	push   %eax
8010822b:	68 dc a8 10 80       	push   $0x8010a8dc
80108230:	e8 91 81 ff ff       	call   801003c6 <cprintf>
80108235:	83 c4 10             	add    $0x10,%esp
	return -2;
80108238:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
8010823d:	eb 36                	jmp    80108275 <sys_setpriority+0xa0>
    }
	
    if(pid < 1){
8010823f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108242:	85 c0                	test   %eax,%eax
80108244:	7f 17                	jg     8010825d <sys_setpriority+0x88>
	cprintf("\nInvalid PID\n");
80108246:	83 ec 0c             	sub    $0xc,%esp
80108249:	68 19 a9 10 80       	push   $0x8010a919
8010824e:	e8 73 81 ff ff       	call   801003c6 <cprintf>
80108253:	83 c4 10             	add    $0x10,%esp
	return -3;
80108256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
8010825b:	eb 18                	jmp    80108275 <sys_setpriority+0xa0>
    }

    setpriority(pid, prio);
8010825d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108263:	83 ec 08             	sub    $0x8,%esp
80108266:	52                   	push   %edx
80108267:	50                   	push   %eax
80108268:	e8 02 e6 ff ff       	call   8010686f <setpriority>
8010826d:	83 c4 10             	add    $0x10,%esp

    return 1;
80108270:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108275:	c9                   	leave  
80108276:	c3                   	ret    

80108277 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80108277:	55                   	push   %ebp
80108278:	89 e5                	mov    %esp,%ebp
8010827a:	83 ec 08             	sub    $0x8,%esp
8010827d:	8b 55 08             	mov    0x8(%ebp),%edx
80108280:	8b 45 0c             	mov    0xc(%ebp),%eax
80108283:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108287:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010828a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010828e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108292:	ee                   	out    %al,(%dx)
}
80108293:	90                   	nop
80108294:	c9                   	leave  
80108295:	c3                   	ret    

80108296 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80108296:	55                   	push   %ebp
80108297:	89 e5                	mov    %esp,%ebp
80108299:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010829c:	6a 34                	push   $0x34
8010829e:	6a 43                	push   $0x43
801082a0:	e8 d2 ff ff ff       	call   80108277 <outb>
801082a5:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
801082a8:	68 a9 00 00 00       	push   $0xa9
801082ad:	6a 40                	push   $0x40
801082af:	e8 c3 ff ff ff       	call   80108277 <outb>
801082b4:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
801082b7:	6a 04                	push   $0x4
801082b9:	6a 40                	push   $0x40
801082bb:	e8 b7 ff ff ff       	call   80108277 <outb>
801082c0:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801082c3:	83 ec 0c             	sub    $0xc,%esp
801082c6:	6a 00                	push   $0x0
801082c8:	e8 08 bd ff ff       	call   80103fd5 <picenable>
801082cd:	83 c4 10             	add    $0x10,%esp
}
801082d0:	90                   	nop
801082d1:	c9                   	leave  
801082d2:	c3                   	ret    

801082d3 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801082d3:	1e                   	push   %ds
  pushl %es
801082d4:	06                   	push   %es
  pushl %fs
801082d5:	0f a0                	push   %fs
  pushl %gs
801082d7:	0f a8                	push   %gs
  pushal
801082d9:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801082da:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801082de:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801082e0:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801082e2:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801082e6:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801082e8:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801082ea:	54                   	push   %esp
  call trap
801082eb:	e8 ce 01 00 00       	call   801084be <trap>
  addl $4, %esp
801082f0:	83 c4 04             	add    $0x4,%esp

801082f3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801082f3:	61                   	popa   
  popl %gs
801082f4:	0f a9                	pop    %gs
  popl %fs
801082f6:	0f a1                	pop    %fs
  popl %es
801082f8:	07                   	pop    %es
  popl %ds
801082f9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801082fa:	83 c4 08             	add    $0x8,%esp
  iret
801082fd:	cf                   	iret   

801082fe <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
801082fe:	55                   	push   %ebp
801082ff:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108301:	8b 45 08             	mov    0x8(%ebp),%eax
80108304:	f0 ff 00             	lock incl (%eax)
}
80108307:	90                   	nop
80108308:	5d                   	pop    %ebp
80108309:	c3                   	ret    

8010830a <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010830a:	55                   	push   %ebp
8010830b:	89 e5                	mov    %esp,%ebp
8010830d:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108310:	8b 45 0c             	mov    0xc(%ebp),%eax
80108313:	83 e8 01             	sub    $0x1,%eax
80108316:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010831a:	8b 45 08             	mov    0x8(%ebp),%eax
8010831d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108321:	8b 45 08             	mov    0x8(%ebp),%eax
80108324:	c1 e8 10             	shr    $0x10,%eax
80108327:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010832b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010832e:	0f 01 18             	lidtl  (%eax)
}
80108331:	90                   	nop
80108332:	c9                   	leave  
80108333:	c3                   	ret    

80108334 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80108334:	55                   	push   %ebp
80108335:	89 e5                	mov    %esp,%ebp
80108337:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010833a:	0f 20 d0             	mov    %cr2,%eax
8010833d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80108340:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108343:	c9                   	leave  
80108344:	c3                   	ret    

80108345 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
80108345:	55                   	push   %ebp
80108346:	89 e5                	mov    %esp,%ebp
80108348:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
8010834b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108352:	e9 c3 00 00 00       	jmp    8010841a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80108357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010835a:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
80108361:	89 c2                	mov    %eax,%edx
80108363:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108366:	66 89 14 c5 e0 70 11 	mov    %dx,-0x7fee8f20(,%eax,8)
8010836d:	80 
8010836e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108371:	66 c7 04 c5 e2 70 11 	movw   $0x8,-0x7fee8f1e(,%eax,8)
80108378:	80 08 00 
8010837b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010837e:	0f b6 14 c5 e4 70 11 	movzbl -0x7fee8f1c(,%eax,8),%edx
80108385:	80 
80108386:	83 e2 e0             	and    $0xffffffe0,%edx
80108389:	88 14 c5 e4 70 11 80 	mov    %dl,-0x7fee8f1c(,%eax,8)
80108390:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108393:	0f b6 14 c5 e4 70 11 	movzbl -0x7fee8f1c(,%eax,8),%edx
8010839a:	80 
8010839b:	83 e2 1f             	and    $0x1f,%edx
8010839e:	88 14 c5 e4 70 11 80 	mov    %dl,-0x7fee8f1c(,%eax,8)
801083a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083a8:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
801083af:	80 
801083b0:	83 e2 f0             	and    $0xfffffff0,%edx
801083b3:	83 ca 0e             	or     $0xe,%edx
801083b6:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
801083bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083c0:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
801083c7:	80 
801083c8:	83 e2 ef             	and    $0xffffffef,%edx
801083cb:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
801083d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083d5:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
801083dc:	80 
801083dd:	83 e2 9f             	and    $0xffffff9f,%edx
801083e0:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
801083e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083ea:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
801083f1:	80 
801083f2:	83 ca 80             	or     $0xffffff80,%edx
801083f5:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
801083fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083ff:	8b 04 85 b4 d0 10 80 	mov    -0x7fef2f4c(,%eax,4),%eax
80108406:	c1 e8 10             	shr    $0x10,%eax
80108409:	89 c2                	mov    %eax,%edx
8010840b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010840e:	66 89 14 c5 e6 70 11 	mov    %dx,-0x7fee8f1a(,%eax,8)
80108415:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80108416:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010841a:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108421:	0f 8e 30 ff ff ff    	jle    80108357 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80108427:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
8010842c:	66 a3 e0 72 11 80    	mov    %ax,0x801172e0
80108432:	66 c7 05 e2 72 11 80 	movw   $0x8,0x801172e2
80108439:	08 00 
8010843b:	0f b6 05 e4 72 11 80 	movzbl 0x801172e4,%eax
80108442:	83 e0 e0             	and    $0xffffffe0,%eax
80108445:	a2 e4 72 11 80       	mov    %al,0x801172e4
8010844a:	0f b6 05 e4 72 11 80 	movzbl 0x801172e4,%eax
80108451:	83 e0 1f             	and    $0x1f,%eax
80108454:	a2 e4 72 11 80       	mov    %al,0x801172e4
80108459:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
80108460:	83 c8 0f             	or     $0xf,%eax
80108463:	a2 e5 72 11 80       	mov    %al,0x801172e5
80108468:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
8010846f:	83 e0 ef             	and    $0xffffffef,%eax
80108472:	a2 e5 72 11 80       	mov    %al,0x801172e5
80108477:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
8010847e:	83 c8 60             	or     $0x60,%eax
80108481:	a2 e5 72 11 80       	mov    %al,0x801172e5
80108486:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
8010848d:	83 c8 80             	or     $0xffffff80,%eax
80108490:	a2 e5 72 11 80       	mov    %al,0x801172e5
80108495:	a1 b4 d1 10 80       	mov    0x8010d1b4,%eax
8010849a:	c1 e8 10             	shr    $0x10,%eax
8010849d:	66 a3 e6 72 11 80    	mov    %ax,0x801172e6
  
}
801084a3:	90                   	nop
801084a4:	c9                   	leave  
801084a5:	c3                   	ret    

801084a6 <idtinit>:

void
idtinit(void)
{
801084a6:	55                   	push   %ebp
801084a7:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801084a9:	68 00 08 00 00       	push   $0x800
801084ae:	68 e0 70 11 80       	push   $0x801170e0
801084b3:	e8 52 fe ff ff       	call   8010830a <lidt>
801084b8:	83 c4 08             	add    $0x8,%esp
}
801084bb:	90                   	nop
801084bc:	c9                   	leave  
801084bd:	c3                   	ret    

801084be <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801084be:	55                   	push   %ebp
801084bf:	89 e5                	mov    %esp,%ebp
801084c1:	57                   	push   %edi
801084c2:	56                   	push   %esi
801084c3:	53                   	push   %ebx
801084c4:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801084c7:	8b 45 08             	mov    0x8(%ebp),%eax
801084ca:	8b 40 30             	mov    0x30(%eax),%eax
801084cd:	83 f8 40             	cmp    $0x40,%eax
801084d0:	75 3e                	jne    80108510 <trap+0x52>
    if(proc->killed)
801084d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084d8:	8b 40 24             	mov    0x24(%eax),%eax
801084db:	85 c0                	test   %eax,%eax
801084dd:	74 05                	je     801084e4 <trap+0x26>
      exit();
801084df:	e8 5b c9 ff ff       	call   80104e3f <exit>
    proc->tf = tf;
801084e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084ea:	8b 55 08             	mov    0x8(%ebp),%edx
801084ed:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801084f0:	e8 e0 eb ff ff       	call   801070d5 <syscall>
    if(proc->killed)
801084f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084fb:	8b 40 24             	mov    0x24(%eax),%eax
801084fe:	85 c0                	test   %eax,%eax
80108500:	0f 84 21 02 00 00    	je     80108727 <trap+0x269>
      exit();
80108506:	e8 34 c9 ff ff       	call   80104e3f <exit>
    return;
8010850b:	e9 17 02 00 00       	jmp    80108727 <trap+0x269>
  }

  switch(tf->trapno){
80108510:	8b 45 08             	mov    0x8(%ebp),%eax
80108513:	8b 40 30             	mov    0x30(%eax),%eax
80108516:	83 e8 20             	sub    $0x20,%eax
80108519:	83 f8 1f             	cmp    $0x1f,%eax
8010851c:	0f 87 a3 00 00 00    	ja     801085c5 <trap+0x107>
80108522:	8b 04 85 c8 a9 10 80 	mov    -0x7fef5638(,%eax,4),%eax
80108529:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
8010852b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108531:	0f b6 00             	movzbl (%eax),%eax
80108534:	84 c0                	test   %al,%al
80108536:	75 20                	jne    80108558 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
80108538:	83 ec 0c             	sub    $0xc,%esp
8010853b:	68 e0 78 11 80       	push   $0x801178e0
80108540:	e8 b9 fd ff ff       	call   801082fe <atom_inc>
80108545:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
80108548:	83 ec 0c             	sub    $0xc,%esp
8010854b:	68 e0 78 11 80       	push   $0x801178e0
80108550:	e8 3d d4 ff ff       	call   80105992 <wakeup>
80108555:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80108558:	e8 72 ab ff ff       	call   801030cf <lapiceoi>
    break;
8010855d:	e9 1c 01 00 00       	jmp    8010867e <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80108562:	e8 7b a3 ff ff       	call   801028e2 <ideintr>
    lapiceoi();
80108567:	e8 63 ab ff ff       	call   801030cf <lapiceoi>
    break;
8010856c:	e9 0d 01 00 00       	jmp    8010867e <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80108571:	e8 5b a9 ff ff       	call   80102ed1 <kbdintr>
    lapiceoi();
80108576:	e8 54 ab ff ff       	call   801030cf <lapiceoi>
    break;
8010857b:	e9 fe 00 00 00       	jmp    8010867e <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80108580:	e8 83 03 00 00       	call   80108908 <uartintr>
    lapiceoi();
80108585:	e8 45 ab ff ff       	call   801030cf <lapiceoi>
    break;
8010858a:	e9 ef 00 00 00       	jmp    8010867e <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010858f:	8b 45 08             	mov    0x8(%ebp),%eax
80108592:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80108595:	8b 45 08             	mov    0x8(%ebp),%eax
80108598:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010859c:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010859f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085a5:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801085a8:	0f b6 c0             	movzbl %al,%eax
801085ab:	51                   	push   %ecx
801085ac:	52                   	push   %edx
801085ad:	50                   	push   %eax
801085ae:	68 28 a9 10 80       	push   $0x8010a928
801085b3:	e8 0e 7e ff ff       	call   801003c6 <cprintf>
801085b8:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801085bb:	e8 0f ab ff ff       	call   801030cf <lapiceoi>
    break;
801085c0:	e9 b9 00 00 00       	jmp    8010867e <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801085c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085cb:	85 c0                	test   %eax,%eax
801085cd:	74 11                	je     801085e0 <trap+0x122>
801085cf:	8b 45 08             	mov    0x8(%ebp),%eax
801085d2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801085d6:	0f b7 c0             	movzwl %ax,%eax
801085d9:	83 e0 03             	and    $0x3,%eax
801085dc:	85 c0                	test   %eax,%eax
801085de:	75 40                	jne    80108620 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801085e0:	e8 4f fd ff ff       	call   80108334 <rcr2>
801085e5:	89 c3                	mov    %eax,%ebx
801085e7:	8b 45 08             	mov    0x8(%ebp),%eax
801085ea:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801085ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085f3:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801085f6:	0f b6 d0             	movzbl %al,%edx
801085f9:	8b 45 08             	mov    0x8(%ebp),%eax
801085fc:	8b 40 30             	mov    0x30(%eax),%eax
801085ff:	83 ec 0c             	sub    $0xc,%esp
80108602:	53                   	push   %ebx
80108603:	51                   	push   %ecx
80108604:	52                   	push   %edx
80108605:	50                   	push   %eax
80108606:	68 4c a9 10 80       	push   $0x8010a94c
8010860b:	e8 b6 7d ff ff       	call   801003c6 <cprintf>
80108610:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80108613:	83 ec 0c             	sub    $0xc,%esp
80108616:	68 7e a9 10 80       	push   $0x8010a97e
8010861b:	e8 46 7f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108620:	e8 0f fd ff ff       	call   80108334 <rcr2>
80108625:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108628:	8b 45 08             	mov    0x8(%ebp),%eax
8010862b:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010862e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108634:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108637:	0f b6 d8             	movzbl %al,%ebx
8010863a:	8b 45 08             	mov    0x8(%ebp),%eax
8010863d:	8b 48 34             	mov    0x34(%eax),%ecx
80108640:	8b 45 08             	mov    0x8(%ebp),%eax
80108643:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010864c:	8d 78 6c             	lea    0x6c(%eax),%edi
8010864f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108655:	8b 40 10             	mov    0x10(%eax),%eax
80108658:	ff 75 e4             	pushl  -0x1c(%ebp)
8010865b:	56                   	push   %esi
8010865c:	53                   	push   %ebx
8010865d:	51                   	push   %ecx
8010865e:	52                   	push   %edx
8010865f:	57                   	push   %edi
80108660:	50                   	push   %eax
80108661:	68 84 a9 10 80       	push   $0x8010a984
80108666:	e8 5b 7d ff ff       	call   801003c6 <cprintf>
8010866b:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010866e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108674:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010867b:	eb 01                	jmp    8010867e <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010867d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010867e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108684:	85 c0                	test   %eax,%eax
80108686:	74 24                	je     801086ac <trap+0x1ee>
80108688:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010868e:	8b 40 24             	mov    0x24(%eax),%eax
80108691:	85 c0                	test   %eax,%eax
80108693:	74 17                	je     801086ac <trap+0x1ee>
80108695:	8b 45 08             	mov    0x8(%ebp),%eax
80108698:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010869c:	0f b7 c0             	movzwl %ax,%eax
8010869f:	83 e0 03             	and    $0x3,%eax
801086a2:	83 f8 03             	cmp    $0x3,%eax
801086a5:	75 05                	jne    801086ac <trap+0x1ee>
    exit();
801086a7:	e8 93 c7 ff ff       	call   80104e3f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
801086ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086b2:	85 c0                	test   %eax,%eax
801086b4:	74 41                	je     801086f7 <trap+0x239>
801086b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086bc:	8b 40 0c             	mov    0xc(%eax),%eax
801086bf:	83 f8 04             	cmp    $0x4,%eax
801086c2:	75 33                	jne    801086f7 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801086c4:	8b 45 08             	mov    0x8(%ebp),%eax
801086c7:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
801086ca:	83 f8 20             	cmp    $0x20,%eax
801086cd:	75 28                	jne    801086f7 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801086cf:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
801086d5:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801086da:	89 c8                	mov    %ecx,%eax
801086dc:	f7 e2                	mul    %edx
801086de:	c1 ea 03             	shr    $0x3,%edx
801086e1:	89 d0                	mov    %edx,%eax
801086e3:	c1 e0 02             	shl    $0x2,%eax
801086e6:	01 d0                	add    %edx,%eax
801086e8:	01 c0                	add    %eax,%eax
801086ea:	29 c1                	sub    %eax,%ecx
801086ec:	89 ca                	mov    %ecx,%edx
801086ee:	85 d2                	test   %edx,%edx
801086f0:	75 05                	jne    801086f7 <trap+0x239>
    yield();
801086f2:	e8 31 cf ff ff       	call   80105628 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801086f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086fd:	85 c0                	test   %eax,%eax
801086ff:	74 27                	je     80108728 <trap+0x26a>
80108701:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108707:	8b 40 24             	mov    0x24(%eax),%eax
8010870a:	85 c0                	test   %eax,%eax
8010870c:	74 1a                	je     80108728 <trap+0x26a>
8010870e:	8b 45 08             	mov    0x8(%ebp),%eax
80108711:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108715:	0f b7 c0             	movzwl %ax,%eax
80108718:	83 e0 03             	and    $0x3,%eax
8010871b:	83 f8 03             	cmp    $0x3,%eax
8010871e:	75 08                	jne    80108728 <trap+0x26a>
    exit();
80108720:	e8 1a c7 ff ff       	call   80104e3f <exit>
80108725:	eb 01                	jmp    80108728 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80108727:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80108728:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010872b:	5b                   	pop    %ebx
8010872c:	5e                   	pop    %esi
8010872d:	5f                   	pop    %edi
8010872e:	5d                   	pop    %ebp
8010872f:	c3                   	ret    

80108730 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108730:	55                   	push   %ebp
80108731:	89 e5                	mov    %esp,%ebp
80108733:	83 ec 14             	sub    $0x14,%esp
80108736:	8b 45 08             	mov    0x8(%ebp),%eax
80108739:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010873d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108741:	89 c2                	mov    %eax,%edx
80108743:	ec                   	in     (%dx),%al
80108744:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108747:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010874b:	c9                   	leave  
8010874c:	c3                   	ret    

8010874d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010874d:	55                   	push   %ebp
8010874e:	89 e5                	mov    %esp,%ebp
80108750:	83 ec 08             	sub    $0x8,%esp
80108753:	8b 55 08             	mov    0x8(%ebp),%edx
80108756:	8b 45 0c             	mov    0xc(%ebp),%eax
80108759:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010875d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108760:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108764:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108768:	ee                   	out    %al,(%dx)
}
80108769:	90                   	nop
8010876a:	c9                   	leave  
8010876b:	c3                   	ret    

8010876c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010876c:	55                   	push   %ebp
8010876d:	89 e5                	mov    %esp,%ebp
8010876f:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80108772:	6a 00                	push   $0x0
80108774:	68 fa 03 00 00       	push   $0x3fa
80108779:	e8 cf ff ff ff       	call   8010874d <outb>
8010877e:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108781:	68 80 00 00 00       	push   $0x80
80108786:	68 fb 03 00 00       	push   $0x3fb
8010878b:	e8 bd ff ff ff       	call   8010874d <outb>
80108790:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108793:	6a 0c                	push   $0xc
80108795:	68 f8 03 00 00       	push   $0x3f8
8010879a:	e8 ae ff ff ff       	call   8010874d <outb>
8010879f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801087a2:	6a 00                	push   $0x0
801087a4:	68 f9 03 00 00       	push   $0x3f9
801087a9:	e8 9f ff ff ff       	call   8010874d <outb>
801087ae:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801087b1:	6a 03                	push   $0x3
801087b3:	68 fb 03 00 00       	push   $0x3fb
801087b8:	e8 90 ff ff ff       	call   8010874d <outb>
801087bd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801087c0:	6a 00                	push   $0x0
801087c2:	68 fc 03 00 00       	push   $0x3fc
801087c7:	e8 81 ff ff ff       	call   8010874d <outb>
801087cc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801087cf:	6a 01                	push   $0x1
801087d1:	68 f9 03 00 00       	push   $0x3f9
801087d6:	e8 72 ff ff ff       	call   8010874d <outb>
801087db:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801087de:	68 fd 03 00 00       	push   $0x3fd
801087e3:	e8 48 ff ff ff       	call   80108730 <inb>
801087e8:	83 c4 04             	add    $0x4,%esp
801087eb:	3c ff                	cmp    $0xff,%al
801087ed:	74 6e                	je     8010885d <uartinit+0xf1>
    return;
  uart = 1;
801087ef:	c7 05 6c d6 10 80 01 	movl   $0x1,0x8010d66c
801087f6:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801087f9:	68 fa 03 00 00       	push   $0x3fa
801087fe:	e8 2d ff ff ff       	call   80108730 <inb>
80108803:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80108806:	68 f8 03 00 00       	push   $0x3f8
8010880b:	e8 20 ff ff ff       	call   80108730 <inb>
80108810:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80108813:	83 ec 0c             	sub    $0xc,%esp
80108816:	6a 04                	push   $0x4
80108818:	e8 b8 b7 ff ff       	call   80103fd5 <picenable>
8010881d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108820:	83 ec 08             	sub    $0x8,%esp
80108823:	6a 00                	push   $0x0
80108825:	6a 04                	push   $0x4
80108827:	e8 58 a3 ff ff       	call   80102b84 <ioapicenable>
8010882c:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010882f:	c7 45 f4 48 aa 10 80 	movl   $0x8010aa48,-0xc(%ebp)
80108836:	eb 19                	jmp    80108851 <uartinit+0xe5>
    uartputc(*p);
80108838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883b:	0f b6 00             	movzbl (%eax),%eax
8010883e:	0f be c0             	movsbl %al,%eax
80108841:	83 ec 0c             	sub    $0xc,%esp
80108844:	50                   	push   %eax
80108845:	e8 16 00 00 00       	call   80108860 <uartputc>
8010884a:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010884d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108854:	0f b6 00             	movzbl (%eax),%eax
80108857:	84 c0                	test   %al,%al
80108859:	75 dd                	jne    80108838 <uartinit+0xcc>
8010885b:	eb 01                	jmp    8010885e <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010885d:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010885e:	c9                   	leave  
8010885f:	c3                   	ret    

80108860 <uartputc>:

void
uartputc(int c)
{
80108860:	55                   	push   %ebp
80108861:	89 e5                	mov    %esp,%ebp
80108863:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80108866:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
8010886b:	85 c0                	test   %eax,%eax
8010886d:	74 53                	je     801088c2 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010886f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108876:	eb 11                	jmp    80108889 <uartputc+0x29>
    microdelay(10);
80108878:	83 ec 0c             	sub    $0xc,%esp
8010887b:	6a 0a                	push   $0xa
8010887d:	e8 68 a8 ff ff       	call   801030ea <microdelay>
80108882:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80108885:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108889:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010888d:	7f 1a                	jg     801088a9 <uartputc+0x49>
8010888f:	83 ec 0c             	sub    $0xc,%esp
80108892:	68 fd 03 00 00       	push   $0x3fd
80108897:	e8 94 fe ff ff       	call   80108730 <inb>
8010889c:	83 c4 10             	add    $0x10,%esp
8010889f:	0f b6 c0             	movzbl %al,%eax
801088a2:	83 e0 20             	and    $0x20,%eax
801088a5:	85 c0                	test   %eax,%eax
801088a7:	74 cf                	je     80108878 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801088a9:	8b 45 08             	mov    0x8(%ebp),%eax
801088ac:	0f b6 c0             	movzbl %al,%eax
801088af:	83 ec 08             	sub    $0x8,%esp
801088b2:	50                   	push   %eax
801088b3:	68 f8 03 00 00       	push   $0x3f8
801088b8:	e8 90 fe ff ff       	call   8010874d <outb>
801088bd:	83 c4 10             	add    $0x10,%esp
801088c0:	eb 01                	jmp    801088c3 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801088c2:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801088c3:	c9                   	leave  
801088c4:	c3                   	ret    

801088c5 <uartgetc>:

static int
uartgetc(void)
{
801088c5:	55                   	push   %ebp
801088c6:	89 e5                	mov    %esp,%ebp
  if(!uart)
801088c8:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
801088cd:	85 c0                	test   %eax,%eax
801088cf:	75 07                	jne    801088d8 <uartgetc+0x13>
    return -1;
801088d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088d6:	eb 2e                	jmp    80108906 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801088d8:	68 fd 03 00 00       	push   $0x3fd
801088dd:	e8 4e fe ff ff       	call   80108730 <inb>
801088e2:	83 c4 04             	add    $0x4,%esp
801088e5:	0f b6 c0             	movzbl %al,%eax
801088e8:	83 e0 01             	and    $0x1,%eax
801088eb:	85 c0                	test   %eax,%eax
801088ed:	75 07                	jne    801088f6 <uartgetc+0x31>
    return -1;
801088ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088f4:	eb 10                	jmp    80108906 <uartgetc+0x41>
  return inb(COM1+0);
801088f6:	68 f8 03 00 00       	push   $0x3f8
801088fb:	e8 30 fe ff ff       	call   80108730 <inb>
80108900:	83 c4 04             	add    $0x4,%esp
80108903:	0f b6 c0             	movzbl %al,%eax
}
80108906:	c9                   	leave  
80108907:	c3                   	ret    

80108908 <uartintr>:

void
uartintr(void)
{
80108908:	55                   	push   %ebp
80108909:	89 e5                	mov    %esp,%ebp
8010890b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010890e:	83 ec 0c             	sub    $0xc,%esp
80108911:	68 c5 88 10 80       	push   $0x801088c5
80108916:	e8 de 7e ff ff       	call   801007f9 <consoleintr>
8010891b:	83 c4 10             	add    $0x10,%esp
}
8010891e:	90                   	nop
8010891f:	c9                   	leave  
80108920:	c3                   	ret    

80108921 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108921:	6a 00                	push   $0x0
  pushl $0
80108923:	6a 00                	push   $0x0
  jmp alltraps
80108925:	e9 a9 f9 ff ff       	jmp    801082d3 <alltraps>

8010892a <vector1>:
.globl vector1
vector1:
  pushl $0
8010892a:	6a 00                	push   $0x0
  pushl $1
8010892c:	6a 01                	push   $0x1
  jmp alltraps
8010892e:	e9 a0 f9 ff ff       	jmp    801082d3 <alltraps>

80108933 <vector2>:
.globl vector2
vector2:
  pushl $0
80108933:	6a 00                	push   $0x0
  pushl $2
80108935:	6a 02                	push   $0x2
  jmp alltraps
80108937:	e9 97 f9 ff ff       	jmp    801082d3 <alltraps>

8010893c <vector3>:
.globl vector3
vector3:
  pushl $0
8010893c:	6a 00                	push   $0x0
  pushl $3
8010893e:	6a 03                	push   $0x3
  jmp alltraps
80108940:	e9 8e f9 ff ff       	jmp    801082d3 <alltraps>

80108945 <vector4>:
.globl vector4
vector4:
  pushl $0
80108945:	6a 00                	push   $0x0
  pushl $4
80108947:	6a 04                	push   $0x4
  jmp alltraps
80108949:	e9 85 f9 ff ff       	jmp    801082d3 <alltraps>

8010894e <vector5>:
.globl vector5
vector5:
  pushl $0
8010894e:	6a 00                	push   $0x0
  pushl $5
80108950:	6a 05                	push   $0x5
  jmp alltraps
80108952:	e9 7c f9 ff ff       	jmp    801082d3 <alltraps>

80108957 <vector6>:
.globl vector6
vector6:
  pushl $0
80108957:	6a 00                	push   $0x0
  pushl $6
80108959:	6a 06                	push   $0x6
  jmp alltraps
8010895b:	e9 73 f9 ff ff       	jmp    801082d3 <alltraps>

80108960 <vector7>:
.globl vector7
vector7:
  pushl $0
80108960:	6a 00                	push   $0x0
  pushl $7
80108962:	6a 07                	push   $0x7
  jmp alltraps
80108964:	e9 6a f9 ff ff       	jmp    801082d3 <alltraps>

80108969 <vector8>:
.globl vector8
vector8:
  pushl $8
80108969:	6a 08                	push   $0x8
  jmp alltraps
8010896b:	e9 63 f9 ff ff       	jmp    801082d3 <alltraps>

80108970 <vector9>:
.globl vector9
vector9:
  pushl $0
80108970:	6a 00                	push   $0x0
  pushl $9
80108972:	6a 09                	push   $0x9
  jmp alltraps
80108974:	e9 5a f9 ff ff       	jmp    801082d3 <alltraps>

80108979 <vector10>:
.globl vector10
vector10:
  pushl $10
80108979:	6a 0a                	push   $0xa
  jmp alltraps
8010897b:	e9 53 f9 ff ff       	jmp    801082d3 <alltraps>

80108980 <vector11>:
.globl vector11
vector11:
  pushl $11
80108980:	6a 0b                	push   $0xb
  jmp alltraps
80108982:	e9 4c f9 ff ff       	jmp    801082d3 <alltraps>

80108987 <vector12>:
.globl vector12
vector12:
  pushl $12
80108987:	6a 0c                	push   $0xc
  jmp alltraps
80108989:	e9 45 f9 ff ff       	jmp    801082d3 <alltraps>

8010898e <vector13>:
.globl vector13
vector13:
  pushl $13
8010898e:	6a 0d                	push   $0xd
  jmp alltraps
80108990:	e9 3e f9 ff ff       	jmp    801082d3 <alltraps>

80108995 <vector14>:
.globl vector14
vector14:
  pushl $14
80108995:	6a 0e                	push   $0xe
  jmp alltraps
80108997:	e9 37 f9 ff ff       	jmp    801082d3 <alltraps>

8010899c <vector15>:
.globl vector15
vector15:
  pushl $0
8010899c:	6a 00                	push   $0x0
  pushl $15
8010899e:	6a 0f                	push   $0xf
  jmp alltraps
801089a0:	e9 2e f9 ff ff       	jmp    801082d3 <alltraps>

801089a5 <vector16>:
.globl vector16
vector16:
  pushl $0
801089a5:	6a 00                	push   $0x0
  pushl $16
801089a7:	6a 10                	push   $0x10
  jmp alltraps
801089a9:	e9 25 f9 ff ff       	jmp    801082d3 <alltraps>

801089ae <vector17>:
.globl vector17
vector17:
  pushl $17
801089ae:	6a 11                	push   $0x11
  jmp alltraps
801089b0:	e9 1e f9 ff ff       	jmp    801082d3 <alltraps>

801089b5 <vector18>:
.globl vector18
vector18:
  pushl $0
801089b5:	6a 00                	push   $0x0
  pushl $18
801089b7:	6a 12                	push   $0x12
  jmp alltraps
801089b9:	e9 15 f9 ff ff       	jmp    801082d3 <alltraps>

801089be <vector19>:
.globl vector19
vector19:
  pushl $0
801089be:	6a 00                	push   $0x0
  pushl $19
801089c0:	6a 13                	push   $0x13
  jmp alltraps
801089c2:	e9 0c f9 ff ff       	jmp    801082d3 <alltraps>

801089c7 <vector20>:
.globl vector20
vector20:
  pushl $0
801089c7:	6a 00                	push   $0x0
  pushl $20
801089c9:	6a 14                	push   $0x14
  jmp alltraps
801089cb:	e9 03 f9 ff ff       	jmp    801082d3 <alltraps>

801089d0 <vector21>:
.globl vector21
vector21:
  pushl $0
801089d0:	6a 00                	push   $0x0
  pushl $21
801089d2:	6a 15                	push   $0x15
  jmp alltraps
801089d4:	e9 fa f8 ff ff       	jmp    801082d3 <alltraps>

801089d9 <vector22>:
.globl vector22
vector22:
  pushl $0
801089d9:	6a 00                	push   $0x0
  pushl $22
801089db:	6a 16                	push   $0x16
  jmp alltraps
801089dd:	e9 f1 f8 ff ff       	jmp    801082d3 <alltraps>

801089e2 <vector23>:
.globl vector23
vector23:
  pushl $0
801089e2:	6a 00                	push   $0x0
  pushl $23
801089e4:	6a 17                	push   $0x17
  jmp alltraps
801089e6:	e9 e8 f8 ff ff       	jmp    801082d3 <alltraps>

801089eb <vector24>:
.globl vector24
vector24:
  pushl $0
801089eb:	6a 00                	push   $0x0
  pushl $24
801089ed:	6a 18                	push   $0x18
  jmp alltraps
801089ef:	e9 df f8 ff ff       	jmp    801082d3 <alltraps>

801089f4 <vector25>:
.globl vector25
vector25:
  pushl $0
801089f4:	6a 00                	push   $0x0
  pushl $25
801089f6:	6a 19                	push   $0x19
  jmp alltraps
801089f8:	e9 d6 f8 ff ff       	jmp    801082d3 <alltraps>

801089fd <vector26>:
.globl vector26
vector26:
  pushl $0
801089fd:	6a 00                	push   $0x0
  pushl $26
801089ff:	6a 1a                	push   $0x1a
  jmp alltraps
80108a01:	e9 cd f8 ff ff       	jmp    801082d3 <alltraps>

80108a06 <vector27>:
.globl vector27
vector27:
  pushl $0
80108a06:	6a 00                	push   $0x0
  pushl $27
80108a08:	6a 1b                	push   $0x1b
  jmp alltraps
80108a0a:	e9 c4 f8 ff ff       	jmp    801082d3 <alltraps>

80108a0f <vector28>:
.globl vector28
vector28:
  pushl $0
80108a0f:	6a 00                	push   $0x0
  pushl $28
80108a11:	6a 1c                	push   $0x1c
  jmp alltraps
80108a13:	e9 bb f8 ff ff       	jmp    801082d3 <alltraps>

80108a18 <vector29>:
.globl vector29
vector29:
  pushl $0
80108a18:	6a 00                	push   $0x0
  pushl $29
80108a1a:	6a 1d                	push   $0x1d
  jmp alltraps
80108a1c:	e9 b2 f8 ff ff       	jmp    801082d3 <alltraps>

80108a21 <vector30>:
.globl vector30
vector30:
  pushl $0
80108a21:	6a 00                	push   $0x0
  pushl $30
80108a23:	6a 1e                	push   $0x1e
  jmp alltraps
80108a25:	e9 a9 f8 ff ff       	jmp    801082d3 <alltraps>

80108a2a <vector31>:
.globl vector31
vector31:
  pushl $0
80108a2a:	6a 00                	push   $0x0
  pushl $31
80108a2c:	6a 1f                	push   $0x1f
  jmp alltraps
80108a2e:	e9 a0 f8 ff ff       	jmp    801082d3 <alltraps>

80108a33 <vector32>:
.globl vector32
vector32:
  pushl $0
80108a33:	6a 00                	push   $0x0
  pushl $32
80108a35:	6a 20                	push   $0x20
  jmp alltraps
80108a37:	e9 97 f8 ff ff       	jmp    801082d3 <alltraps>

80108a3c <vector33>:
.globl vector33
vector33:
  pushl $0
80108a3c:	6a 00                	push   $0x0
  pushl $33
80108a3e:	6a 21                	push   $0x21
  jmp alltraps
80108a40:	e9 8e f8 ff ff       	jmp    801082d3 <alltraps>

80108a45 <vector34>:
.globl vector34
vector34:
  pushl $0
80108a45:	6a 00                	push   $0x0
  pushl $34
80108a47:	6a 22                	push   $0x22
  jmp alltraps
80108a49:	e9 85 f8 ff ff       	jmp    801082d3 <alltraps>

80108a4e <vector35>:
.globl vector35
vector35:
  pushl $0
80108a4e:	6a 00                	push   $0x0
  pushl $35
80108a50:	6a 23                	push   $0x23
  jmp alltraps
80108a52:	e9 7c f8 ff ff       	jmp    801082d3 <alltraps>

80108a57 <vector36>:
.globl vector36
vector36:
  pushl $0
80108a57:	6a 00                	push   $0x0
  pushl $36
80108a59:	6a 24                	push   $0x24
  jmp alltraps
80108a5b:	e9 73 f8 ff ff       	jmp    801082d3 <alltraps>

80108a60 <vector37>:
.globl vector37
vector37:
  pushl $0
80108a60:	6a 00                	push   $0x0
  pushl $37
80108a62:	6a 25                	push   $0x25
  jmp alltraps
80108a64:	e9 6a f8 ff ff       	jmp    801082d3 <alltraps>

80108a69 <vector38>:
.globl vector38
vector38:
  pushl $0
80108a69:	6a 00                	push   $0x0
  pushl $38
80108a6b:	6a 26                	push   $0x26
  jmp alltraps
80108a6d:	e9 61 f8 ff ff       	jmp    801082d3 <alltraps>

80108a72 <vector39>:
.globl vector39
vector39:
  pushl $0
80108a72:	6a 00                	push   $0x0
  pushl $39
80108a74:	6a 27                	push   $0x27
  jmp alltraps
80108a76:	e9 58 f8 ff ff       	jmp    801082d3 <alltraps>

80108a7b <vector40>:
.globl vector40
vector40:
  pushl $0
80108a7b:	6a 00                	push   $0x0
  pushl $40
80108a7d:	6a 28                	push   $0x28
  jmp alltraps
80108a7f:	e9 4f f8 ff ff       	jmp    801082d3 <alltraps>

80108a84 <vector41>:
.globl vector41
vector41:
  pushl $0
80108a84:	6a 00                	push   $0x0
  pushl $41
80108a86:	6a 29                	push   $0x29
  jmp alltraps
80108a88:	e9 46 f8 ff ff       	jmp    801082d3 <alltraps>

80108a8d <vector42>:
.globl vector42
vector42:
  pushl $0
80108a8d:	6a 00                	push   $0x0
  pushl $42
80108a8f:	6a 2a                	push   $0x2a
  jmp alltraps
80108a91:	e9 3d f8 ff ff       	jmp    801082d3 <alltraps>

80108a96 <vector43>:
.globl vector43
vector43:
  pushl $0
80108a96:	6a 00                	push   $0x0
  pushl $43
80108a98:	6a 2b                	push   $0x2b
  jmp alltraps
80108a9a:	e9 34 f8 ff ff       	jmp    801082d3 <alltraps>

80108a9f <vector44>:
.globl vector44
vector44:
  pushl $0
80108a9f:	6a 00                	push   $0x0
  pushl $44
80108aa1:	6a 2c                	push   $0x2c
  jmp alltraps
80108aa3:	e9 2b f8 ff ff       	jmp    801082d3 <alltraps>

80108aa8 <vector45>:
.globl vector45
vector45:
  pushl $0
80108aa8:	6a 00                	push   $0x0
  pushl $45
80108aaa:	6a 2d                	push   $0x2d
  jmp alltraps
80108aac:	e9 22 f8 ff ff       	jmp    801082d3 <alltraps>

80108ab1 <vector46>:
.globl vector46
vector46:
  pushl $0
80108ab1:	6a 00                	push   $0x0
  pushl $46
80108ab3:	6a 2e                	push   $0x2e
  jmp alltraps
80108ab5:	e9 19 f8 ff ff       	jmp    801082d3 <alltraps>

80108aba <vector47>:
.globl vector47
vector47:
  pushl $0
80108aba:	6a 00                	push   $0x0
  pushl $47
80108abc:	6a 2f                	push   $0x2f
  jmp alltraps
80108abe:	e9 10 f8 ff ff       	jmp    801082d3 <alltraps>

80108ac3 <vector48>:
.globl vector48
vector48:
  pushl $0
80108ac3:	6a 00                	push   $0x0
  pushl $48
80108ac5:	6a 30                	push   $0x30
  jmp alltraps
80108ac7:	e9 07 f8 ff ff       	jmp    801082d3 <alltraps>

80108acc <vector49>:
.globl vector49
vector49:
  pushl $0
80108acc:	6a 00                	push   $0x0
  pushl $49
80108ace:	6a 31                	push   $0x31
  jmp alltraps
80108ad0:	e9 fe f7 ff ff       	jmp    801082d3 <alltraps>

80108ad5 <vector50>:
.globl vector50
vector50:
  pushl $0
80108ad5:	6a 00                	push   $0x0
  pushl $50
80108ad7:	6a 32                	push   $0x32
  jmp alltraps
80108ad9:	e9 f5 f7 ff ff       	jmp    801082d3 <alltraps>

80108ade <vector51>:
.globl vector51
vector51:
  pushl $0
80108ade:	6a 00                	push   $0x0
  pushl $51
80108ae0:	6a 33                	push   $0x33
  jmp alltraps
80108ae2:	e9 ec f7 ff ff       	jmp    801082d3 <alltraps>

80108ae7 <vector52>:
.globl vector52
vector52:
  pushl $0
80108ae7:	6a 00                	push   $0x0
  pushl $52
80108ae9:	6a 34                	push   $0x34
  jmp alltraps
80108aeb:	e9 e3 f7 ff ff       	jmp    801082d3 <alltraps>

80108af0 <vector53>:
.globl vector53
vector53:
  pushl $0
80108af0:	6a 00                	push   $0x0
  pushl $53
80108af2:	6a 35                	push   $0x35
  jmp alltraps
80108af4:	e9 da f7 ff ff       	jmp    801082d3 <alltraps>

80108af9 <vector54>:
.globl vector54
vector54:
  pushl $0
80108af9:	6a 00                	push   $0x0
  pushl $54
80108afb:	6a 36                	push   $0x36
  jmp alltraps
80108afd:	e9 d1 f7 ff ff       	jmp    801082d3 <alltraps>

80108b02 <vector55>:
.globl vector55
vector55:
  pushl $0
80108b02:	6a 00                	push   $0x0
  pushl $55
80108b04:	6a 37                	push   $0x37
  jmp alltraps
80108b06:	e9 c8 f7 ff ff       	jmp    801082d3 <alltraps>

80108b0b <vector56>:
.globl vector56
vector56:
  pushl $0
80108b0b:	6a 00                	push   $0x0
  pushl $56
80108b0d:	6a 38                	push   $0x38
  jmp alltraps
80108b0f:	e9 bf f7 ff ff       	jmp    801082d3 <alltraps>

80108b14 <vector57>:
.globl vector57
vector57:
  pushl $0
80108b14:	6a 00                	push   $0x0
  pushl $57
80108b16:	6a 39                	push   $0x39
  jmp alltraps
80108b18:	e9 b6 f7 ff ff       	jmp    801082d3 <alltraps>

80108b1d <vector58>:
.globl vector58
vector58:
  pushl $0
80108b1d:	6a 00                	push   $0x0
  pushl $58
80108b1f:	6a 3a                	push   $0x3a
  jmp alltraps
80108b21:	e9 ad f7 ff ff       	jmp    801082d3 <alltraps>

80108b26 <vector59>:
.globl vector59
vector59:
  pushl $0
80108b26:	6a 00                	push   $0x0
  pushl $59
80108b28:	6a 3b                	push   $0x3b
  jmp alltraps
80108b2a:	e9 a4 f7 ff ff       	jmp    801082d3 <alltraps>

80108b2f <vector60>:
.globl vector60
vector60:
  pushl $0
80108b2f:	6a 00                	push   $0x0
  pushl $60
80108b31:	6a 3c                	push   $0x3c
  jmp alltraps
80108b33:	e9 9b f7 ff ff       	jmp    801082d3 <alltraps>

80108b38 <vector61>:
.globl vector61
vector61:
  pushl $0
80108b38:	6a 00                	push   $0x0
  pushl $61
80108b3a:	6a 3d                	push   $0x3d
  jmp alltraps
80108b3c:	e9 92 f7 ff ff       	jmp    801082d3 <alltraps>

80108b41 <vector62>:
.globl vector62
vector62:
  pushl $0
80108b41:	6a 00                	push   $0x0
  pushl $62
80108b43:	6a 3e                	push   $0x3e
  jmp alltraps
80108b45:	e9 89 f7 ff ff       	jmp    801082d3 <alltraps>

80108b4a <vector63>:
.globl vector63
vector63:
  pushl $0
80108b4a:	6a 00                	push   $0x0
  pushl $63
80108b4c:	6a 3f                	push   $0x3f
  jmp alltraps
80108b4e:	e9 80 f7 ff ff       	jmp    801082d3 <alltraps>

80108b53 <vector64>:
.globl vector64
vector64:
  pushl $0
80108b53:	6a 00                	push   $0x0
  pushl $64
80108b55:	6a 40                	push   $0x40
  jmp alltraps
80108b57:	e9 77 f7 ff ff       	jmp    801082d3 <alltraps>

80108b5c <vector65>:
.globl vector65
vector65:
  pushl $0
80108b5c:	6a 00                	push   $0x0
  pushl $65
80108b5e:	6a 41                	push   $0x41
  jmp alltraps
80108b60:	e9 6e f7 ff ff       	jmp    801082d3 <alltraps>

80108b65 <vector66>:
.globl vector66
vector66:
  pushl $0
80108b65:	6a 00                	push   $0x0
  pushl $66
80108b67:	6a 42                	push   $0x42
  jmp alltraps
80108b69:	e9 65 f7 ff ff       	jmp    801082d3 <alltraps>

80108b6e <vector67>:
.globl vector67
vector67:
  pushl $0
80108b6e:	6a 00                	push   $0x0
  pushl $67
80108b70:	6a 43                	push   $0x43
  jmp alltraps
80108b72:	e9 5c f7 ff ff       	jmp    801082d3 <alltraps>

80108b77 <vector68>:
.globl vector68
vector68:
  pushl $0
80108b77:	6a 00                	push   $0x0
  pushl $68
80108b79:	6a 44                	push   $0x44
  jmp alltraps
80108b7b:	e9 53 f7 ff ff       	jmp    801082d3 <alltraps>

80108b80 <vector69>:
.globl vector69
vector69:
  pushl $0
80108b80:	6a 00                	push   $0x0
  pushl $69
80108b82:	6a 45                	push   $0x45
  jmp alltraps
80108b84:	e9 4a f7 ff ff       	jmp    801082d3 <alltraps>

80108b89 <vector70>:
.globl vector70
vector70:
  pushl $0
80108b89:	6a 00                	push   $0x0
  pushl $70
80108b8b:	6a 46                	push   $0x46
  jmp alltraps
80108b8d:	e9 41 f7 ff ff       	jmp    801082d3 <alltraps>

80108b92 <vector71>:
.globl vector71
vector71:
  pushl $0
80108b92:	6a 00                	push   $0x0
  pushl $71
80108b94:	6a 47                	push   $0x47
  jmp alltraps
80108b96:	e9 38 f7 ff ff       	jmp    801082d3 <alltraps>

80108b9b <vector72>:
.globl vector72
vector72:
  pushl $0
80108b9b:	6a 00                	push   $0x0
  pushl $72
80108b9d:	6a 48                	push   $0x48
  jmp alltraps
80108b9f:	e9 2f f7 ff ff       	jmp    801082d3 <alltraps>

80108ba4 <vector73>:
.globl vector73
vector73:
  pushl $0
80108ba4:	6a 00                	push   $0x0
  pushl $73
80108ba6:	6a 49                	push   $0x49
  jmp alltraps
80108ba8:	e9 26 f7 ff ff       	jmp    801082d3 <alltraps>

80108bad <vector74>:
.globl vector74
vector74:
  pushl $0
80108bad:	6a 00                	push   $0x0
  pushl $74
80108baf:	6a 4a                	push   $0x4a
  jmp alltraps
80108bb1:	e9 1d f7 ff ff       	jmp    801082d3 <alltraps>

80108bb6 <vector75>:
.globl vector75
vector75:
  pushl $0
80108bb6:	6a 00                	push   $0x0
  pushl $75
80108bb8:	6a 4b                	push   $0x4b
  jmp alltraps
80108bba:	e9 14 f7 ff ff       	jmp    801082d3 <alltraps>

80108bbf <vector76>:
.globl vector76
vector76:
  pushl $0
80108bbf:	6a 00                	push   $0x0
  pushl $76
80108bc1:	6a 4c                	push   $0x4c
  jmp alltraps
80108bc3:	e9 0b f7 ff ff       	jmp    801082d3 <alltraps>

80108bc8 <vector77>:
.globl vector77
vector77:
  pushl $0
80108bc8:	6a 00                	push   $0x0
  pushl $77
80108bca:	6a 4d                	push   $0x4d
  jmp alltraps
80108bcc:	e9 02 f7 ff ff       	jmp    801082d3 <alltraps>

80108bd1 <vector78>:
.globl vector78
vector78:
  pushl $0
80108bd1:	6a 00                	push   $0x0
  pushl $78
80108bd3:	6a 4e                	push   $0x4e
  jmp alltraps
80108bd5:	e9 f9 f6 ff ff       	jmp    801082d3 <alltraps>

80108bda <vector79>:
.globl vector79
vector79:
  pushl $0
80108bda:	6a 00                	push   $0x0
  pushl $79
80108bdc:	6a 4f                	push   $0x4f
  jmp alltraps
80108bde:	e9 f0 f6 ff ff       	jmp    801082d3 <alltraps>

80108be3 <vector80>:
.globl vector80
vector80:
  pushl $0
80108be3:	6a 00                	push   $0x0
  pushl $80
80108be5:	6a 50                	push   $0x50
  jmp alltraps
80108be7:	e9 e7 f6 ff ff       	jmp    801082d3 <alltraps>

80108bec <vector81>:
.globl vector81
vector81:
  pushl $0
80108bec:	6a 00                	push   $0x0
  pushl $81
80108bee:	6a 51                	push   $0x51
  jmp alltraps
80108bf0:	e9 de f6 ff ff       	jmp    801082d3 <alltraps>

80108bf5 <vector82>:
.globl vector82
vector82:
  pushl $0
80108bf5:	6a 00                	push   $0x0
  pushl $82
80108bf7:	6a 52                	push   $0x52
  jmp alltraps
80108bf9:	e9 d5 f6 ff ff       	jmp    801082d3 <alltraps>

80108bfe <vector83>:
.globl vector83
vector83:
  pushl $0
80108bfe:	6a 00                	push   $0x0
  pushl $83
80108c00:	6a 53                	push   $0x53
  jmp alltraps
80108c02:	e9 cc f6 ff ff       	jmp    801082d3 <alltraps>

80108c07 <vector84>:
.globl vector84
vector84:
  pushl $0
80108c07:	6a 00                	push   $0x0
  pushl $84
80108c09:	6a 54                	push   $0x54
  jmp alltraps
80108c0b:	e9 c3 f6 ff ff       	jmp    801082d3 <alltraps>

80108c10 <vector85>:
.globl vector85
vector85:
  pushl $0
80108c10:	6a 00                	push   $0x0
  pushl $85
80108c12:	6a 55                	push   $0x55
  jmp alltraps
80108c14:	e9 ba f6 ff ff       	jmp    801082d3 <alltraps>

80108c19 <vector86>:
.globl vector86
vector86:
  pushl $0
80108c19:	6a 00                	push   $0x0
  pushl $86
80108c1b:	6a 56                	push   $0x56
  jmp alltraps
80108c1d:	e9 b1 f6 ff ff       	jmp    801082d3 <alltraps>

80108c22 <vector87>:
.globl vector87
vector87:
  pushl $0
80108c22:	6a 00                	push   $0x0
  pushl $87
80108c24:	6a 57                	push   $0x57
  jmp alltraps
80108c26:	e9 a8 f6 ff ff       	jmp    801082d3 <alltraps>

80108c2b <vector88>:
.globl vector88
vector88:
  pushl $0
80108c2b:	6a 00                	push   $0x0
  pushl $88
80108c2d:	6a 58                	push   $0x58
  jmp alltraps
80108c2f:	e9 9f f6 ff ff       	jmp    801082d3 <alltraps>

80108c34 <vector89>:
.globl vector89
vector89:
  pushl $0
80108c34:	6a 00                	push   $0x0
  pushl $89
80108c36:	6a 59                	push   $0x59
  jmp alltraps
80108c38:	e9 96 f6 ff ff       	jmp    801082d3 <alltraps>

80108c3d <vector90>:
.globl vector90
vector90:
  pushl $0
80108c3d:	6a 00                	push   $0x0
  pushl $90
80108c3f:	6a 5a                	push   $0x5a
  jmp alltraps
80108c41:	e9 8d f6 ff ff       	jmp    801082d3 <alltraps>

80108c46 <vector91>:
.globl vector91
vector91:
  pushl $0
80108c46:	6a 00                	push   $0x0
  pushl $91
80108c48:	6a 5b                	push   $0x5b
  jmp alltraps
80108c4a:	e9 84 f6 ff ff       	jmp    801082d3 <alltraps>

80108c4f <vector92>:
.globl vector92
vector92:
  pushl $0
80108c4f:	6a 00                	push   $0x0
  pushl $92
80108c51:	6a 5c                	push   $0x5c
  jmp alltraps
80108c53:	e9 7b f6 ff ff       	jmp    801082d3 <alltraps>

80108c58 <vector93>:
.globl vector93
vector93:
  pushl $0
80108c58:	6a 00                	push   $0x0
  pushl $93
80108c5a:	6a 5d                	push   $0x5d
  jmp alltraps
80108c5c:	e9 72 f6 ff ff       	jmp    801082d3 <alltraps>

80108c61 <vector94>:
.globl vector94
vector94:
  pushl $0
80108c61:	6a 00                	push   $0x0
  pushl $94
80108c63:	6a 5e                	push   $0x5e
  jmp alltraps
80108c65:	e9 69 f6 ff ff       	jmp    801082d3 <alltraps>

80108c6a <vector95>:
.globl vector95
vector95:
  pushl $0
80108c6a:	6a 00                	push   $0x0
  pushl $95
80108c6c:	6a 5f                	push   $0x5f
  jmp alltraps
80108c6e:	e9 60 f6 ff ff       	jmp    801082d3 <alltraps>

80108c73 <vector96>:
.globl vector96
vector96:
  pushl $0
80108c73:	6a 00                	push   $0x0
  pushl $96
80108c75:	6a 60                	push   $0x60
  jmp alltraps
80108c77:	e9 57 f6 ff ff       	jmp    801082d3 <alltraps>

80108c7c <vector97>:
.globl vector97
vector97:
  pushl $0
80108c7c:	6a 00                	push   $0x0
  pushl $97
80108c7e:	6a 61                	push   $0x61
  jmp alltraps
80108c80:	e9 4e f6 ff ff       	jmp    801082d3 <alltraps>

80108c85 <vector98>:
.globl vector98
vector98:
  pushl $0
80108c85:	6a 00                	push   $0x0
  pushl $98
80108c87:	6a 62                	push   $0x62
  jmp alltraps
80108c89:	e9 45 f6 ff ff       	jmp    801082d3 <alltraps>

80108c8e <vector99>:
.globl vector99
vector99:
  pushl $0
80108c8e:	6a 00                	push   $0x0
  pushl $99
80108c90:	6a 63                	push   $0x63
  jmp alltraps
80108c92:	e9 3c f6 ff ff       	jmp    801082d3 <alltraps>

80108c97 <vector100>:
.globl vector100
vector100:
  pushl $0
80108c97:	6a 00                	push   $0x0
  pushl $100
80108c99:	6a 64                	push   $0x64
  jmp alltraps
80108c9b:	e9 33 f6 ff ff       	jmp    801082d3 <alltraps>

80108ca0 <vector101>:
.globl vector101
vector101:
  pushl $0
80108ca0:	6a 00                	push   $0x0
  pushl $101
80108ca2:	6a 65                	push   $0x65
  jmp alltraps
80108ca4:	e9 2a f6 ff ff       	jmp    801082d3 <alltraps>

80108ca9 <vector102>:
.globl vector102
vector102:
  pushl $0
80108ca9:	6a 00                	push   $0x0
  pushl $102
80108cab:	6a 66                	push   $0x66
  jmp alltraps
80108cad:	e9 21 f6 ff ff       	jmp    801082d3 <alltraps>

80108cb2 <vector103>:
.globl vector103
vector103:
  pushl $0
80108cb2:	6a 00                	push   $0x0
  pushl $103
80108cb4:	6a 67                	push   $0x67
  jmp alltraps
80108cb6:	e9 18 f6 ff ff       	jmp    801082d3 <alltraps>

80108cbb <vector104>:
.globl vector104
vector104:
  pushl $0
80108cbb:	6a 00                	push   $0x0
  pushl $104
80108cbd:	6a 68                	push   $0x68
  jmp alltraps
80108cbf:	e9 0f f6 ff ff       	jmp    801082d3 <alltraps>

80108cc4 <vector105>:
.globl vector105
vector105:
  pushl $0
80108cc4:	6a 00                	push   $0x0
  pushl $105
80108cc6:	6a 69                	push   $0x69
  jmp alltraps
80108cc8:	e9 06 f6 ff ff       	jmp    801082d3 <alltraps>

80108ccd <vector106>:
.globl vector106
vector106:
  pushl $0
80108ccd:	6a 00                	push   $0x0
  pushl $106
80108ccf:	6a 6a                	push   $0x6a
  jmp alltraps
80108cd1:	e9 fd f5 ff ff       	jmp    801082d3 <alltraps>

80108cd6 <vector107>:
.globl vector107
vector107:
  pushl $0
80108cd6:	6a 00                	push   $0x0
  pushl $107
80108cd8:	6a 6b                	push   $0x6b
  jmp alltraps
80108cda:	e9 f4 f5 ff ff       	jmp    801082d3 <alltraps>

80108cdf <vector108>:
.globl vector108
vector108:
  pushl $0
80108cdf:	6a 00                	push   $0x0
  pushl $108
80108ce1:	6a 6c                	push   $0x6c
  jmp alltraps
80108ce3:	e9 eb f5 ff ff       	jmp    801082d3 <alltraps>

80108ce8 <vector109>:
.globl vector109
vector109:
  pushl $0
80108ce8:	6a 00                	push   $0x0
  pushl $109
80108cea:	6a 6d                	push   $0x6d
  jmp alltraps
80108cec:	e9 e2 f5 ff ff       	jmp    801082d3 <alltraps>

80108cf1 <vector110>:
.globl vector110
vector110:
  pushl $0
80108cf1:	6a 00                	push   $0x0
  pushl $110
80108cf3:	6a 6e                	push   $0x6e
  jmp alltraps
80108cf5:	e9 d9 f5 ff ff       	jmp    801082d3 <alltraps>

80108cfa <vector111>:
.globl vector111
vector111:
  pushl $0
80108cfa:	6a 00                	push   $0x0
  pushl $111
80108cfc:	6a 6f                	push   $0x6f
  jmp alltraps
80108cfe:	e9 d0 f5 ff ff       	jmp    801082d3 <alltraps>

80108d03 <vector112>:
.globl vector112
vector112:
  pushl $0
80108d03:	6a 00                	push   $0x0
  pushl $112
80108d05:	6a 70                	push   $0x70
  jmp alltraps
80108d07:	e9 c7 f5 ff ff       	jmp    801082d3 <alltraps>

80108d0c <vector113>:
.globl vector113
vector113:
  pushl $0
80108d0c:	6a 00                	push   $0x0
  pushl $113
80108d0e:	6a 71                	push   $0x71
  jmp alltraps
80108d10:	e9 be f5 ff ff       	jmp    801082d3 <alltraps>

80108d15 <vector114>:
.globl vector114
vector114:
  pushl $0
80108d15:	6a 00                	push   $0x0
  pushl $114
80108d17:	6a 72                	push   $0x72
  jmp alltraps
80108d19:	e9 b5 f5 ff ff       	jmp    801082d3 <alltraps>

80108d1e <vector115>:
.globl vector115
vector115:
  pushl $0
80108d1e:	6a 00                	push   $0x0
  pushl $115
80108d20:	6a 73                	push   $0x73
  jmp alltraps
80108d22:	e9 ac f5 ff ff       	jmp    801082d3 <alltraps>

80108d27 <vector116>:
.globl vector116
vector116:
  pushl $0
80108d27:	6a 00                	push   $0x0
  pushl $116
80108d29:	6a 74                	push   $0x74
  jmp alltraps
80108d2b:	e9 a3 f5 ff ff       	jmp    801082d3 <alltraps>

80108d30 <vector117>:
.globl vector117
vector117:
  pushl $0
80108d30:	6a 00                	push   $0x0
  pushl $117
80108d32:	6a 75                	push   $0x75
  jmp alltraps
80108d34:	e9 9a f5 ff ff       	jmp    801082d3 <alltraps>

80108d39 <vector118>:
.globl vector118
vector118:
  pushl $0
80108d39:	6a 00                	push   $0x0
  pushl $118
80108d3b:	6a 76                	push   $0x76
  jmp alltraps
80108d3d:	e9 91 f5 ff ff       	jmp    801082d3 <alltraps>

80108d42 <vector119>:
.globl vector119
vector119:
  pushl $0
80108d42:	6a 00                	push   $0x0
  pushl $119
80108d44:	6a 77                	push   $0x77
  jmp alltraps
80108d46:	e9 88 f5 ff ff       	jmp    801082d3 <alltraps>

80108d4b <vector120>:
.globl vector120
vector120:
  pushl $0
80108d4b:	6a 00                	push   $0x0
  pushl $120
80108d4d:	6a 78                	push   $0x78
  jmp alltraps
80108d4f:	e9 7f f5 ff ff       	jmp    801082d3 <alltraps>

80108d54 <vector121>:
.globl vector121
vector121:
  pushl $0
80108d54:	6a 00                	push   $0x0
  pushl $121
80108d56:	6a 79                	push   $0x79
  jmp alltraps
80108d58:	e9 76 f5 ff ff       	jmp    801082d3 <alltraps>

80108d5d <vector122>:
.globl vector122
vector122:
  pushl $0
80108d5d:	6a 00                	push   $0x0
  pushl $122
80108d5f:	6a 7a                	push   $0x7a
  jmp alltraps
80108d61:	e9 6d f5 ff ff       	jmp    801082d3 <alltraps>

80108d66 <vector123>:
.globl vector123
vector123:
  pushl $0
80108d66:	6a 00                	push   $0x0
  pushl $123
80108d68:	6a 7b                	push   $0x7b
  jmp alltraps
80108d6a:	e9 64 f5 ff ff       	jmp    801082d3 <alltraps>

80108d6f <vector124>:
.globl vector124
vector124:
  pushl $0
80108d6f:	6a 00                	push   $0x0
  pushl $124
80108d71:	6a 7c                	push   $0x7c
  jmp alltraps
80108d73:	e9 5b f5 ff ff       	jmp    801082d3 <alltraps>

80108d78 <vector125>:
.globl vector125
vector125:
  pushl $0
80108d78:	6a 00                	push   $0x0
  pushl $125
80108d7a:	6a 7d                	push   $0x7d
  jmp alltraps
80108d7c:	e9 52 f5 ff ff       	jmp    801082d3 <alltraps>

80108d81 <vector126>:
.globl vector126
vector126:
  pushl $0
80108d81:	6a 00                	push   $0x0
  pushl $126
80108d83:	6a 7e                	push   $0x7e
  jmp alltraps
80108d85:	e9 49 f5 ff ff       	jmp    801082d3 <alltraps>

80108d8a <vector127>:
.globl vector127
vector127:
  pushl $0
80108d8a:	6a 00                	push   $0x0
  pushl $127
80108d8c:	6a 7f                	push   $0x7f
  jmp alltraps
80108d8e:	e9 40 f5 ff ff       	jmp    801082d3 <alltraps>

80108d93 <vector128>:
.globl vector128
vector128:
  pushl $0
80108d93:	6a 00                	push   $0x0
  pushl $128
80108d95:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108d9a:	e9 34 f5 ff ff       	jmp    801082d3 <alltraps>

80108d9f <vector129>:
.globl vector129
vector129:
  pushl $0
80108d9f:	6a 00                	push   $0x0
  pushl $129
80108da1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108da6:	e9 28 f5 ff ff       	jmp    801082d3 <alltraps>

80108dab <vector130>:
.globl vector130
vector130:
  pushl $0
80108dab:	6a 00                	push   $0x0
  pushl $130
80108dad:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108db2:	e9 1c f5 ff ff       	jmp    801082d3 <alltraps>

80108db7 <vector131>:
.globl vector131
vector131:
  pushl $0
80108db7:	6a 00                	push   $0x0
  pushl $131
80108db9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108dbe:	e9 10 f5 ff ff       	jmp    801082d3 <alltraps>

80108dc3 <vector132>:
.globl vector132
vector132:
  pushl $0
80108dc3:	6a 00                	push   $0x0
  pushl $132
80108dc5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108dca:	e9 04 f5 ff ff       	jmp    801082d3 <alltraps>

80108dcf <vector133>:
.globl vector133
vector133:
  pushl $0
80108dcf:	6a 00                	push   $0x0
  pushl $133
80108dd1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108dd6:	e9 f8 f4 ff ff       	jmp    801082d3 <alltraps>

80108ddb <vector134>:
.globl vector134
vector134:
  pushl $0
80108ddb:	6a 00                	push   $0x0
  pushl $134
80108ddd:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108de2:	e9 ec f4 ff ff       	jmp    801082d3 <alltraps>

80108de7 <vector135>:
.globl vector135
vector135:
  pushl $0
80108de7:	6a 00                	push   $0x0
  pushl $135
80108de9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108dee:	e9 e0 f4 ff ff       	jmp    801082d3 <alltraps>

80108df3 <vector136>:
.globl vector136
vector136:
  pushl $0
80108df3:	6a 00                	push   $0x0
  pushl $136
80108df5:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108dfa:	e9 d4 f4 ff ff       	jmp    801082d3 <alltraps>

80108dff <vector137>:
.globl vector137
vector137:
  pushl $0
80108dff:	6a 00                	push   $0x0
  pushl $137
80108e01:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108e06:	e9 c8 f4 ff ff       	jmp    801082d3 <alltraps>

80108e0b <vector138>:
.globl vector138
vector138:
  pushl $0
80108e0b:	6a 00                	push   $0x0
  pushl $138
80108e0d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108e12:	e9 bc f4 ff ff       	jmp    801082d3 <alltraps>

80108e17 <vector139>:
.globl vector139
vector139:
  pushl $0
80108e17:	6a 00                	push   $0x0
  pushl $139
80108e19:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108e1e:	e9 b0 f4 ff ff       	jmp    801082d3 <alltraps>

80108e23 <vector140>:
.globl vector140
vector140:
  pushl $0
80108e23:	6a 00                	push   $0x0
  pushl $140
80108e25:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108e2a:	e9 a4 f4 ff ff       	jmp    801082d3 <alltraps>

80108e2f <vector141>:
.globl vector141
vector141:
  pushl $0
80108e2f:	6a 00                	push   $0x0
  pushl $141
80108e31:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108e36:	e9 98 f4 ff ff       	jmp    801082d3 <alltraps>

80108e3b <vector142>:
.globl vector142
vector142:
  pushl $0
80108e3b:	6a 00                	push   $0x0
  pushl $142
80108e3d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108e42:	e9 8c f4 ff ff       	jmp    801082d3 <alltraps>

80108e47 <vector143>:
.globl vector143
vector143:
  pushl $0
80108e47:	6a 00                	push   $0x0
  pushl $143
80108e49:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108e4e:	e9 80 f4 ff ff       	jmp    801082d3 <alltraps>

80108e53 <vector144>:
.globl vector144
vector144:
  pushl $0
80108e53:	6a 00                	push   $0x0
  pushl $144
80108e55:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108e5a:	e9 74 f4 ff ff       	jmp    801082d3 <alltraps>

80108e5f <vector145>:
.globl vector145
vector145:
  pushl $0
80108e5f:	6a 00                	push   $0x0
  pushl $145
80108e61:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108e66:	e9 68 f4 ff ff       	jmp    801082d3 <alltraps>

80108e6b <vector146>:
.globl vector146
vector146:
  pushl $0
80108e6b:	6a 00                	push   $0x0
  pushl $146
80108e6d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108e72:	e9 5c f4 ff ff       	jmp    801082d3 <alltraps>

80108e77 <vector147>:
.globl vector147
vector147:
  pushl $0
80108e77:	6a 00                	push   $0x0
  pushl $147
80108e79:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108e7e:	e9 50 f4 ff ff       	jmp    801082d3 <alltraps>

80108e83 <vector148>:
.globl vector148
vector148:
  pushl $0
80108e83:	6a 00                	push   $0x0
  pushl $148
80108e85:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108e8a:	e9 44 f4 ff ff       	jmp    801082d3 <alltraps>

80108e8f <vector149>:
.globl vector149
vector149:
  pushl $0
80108e8f:	6a 00                	push   $0x0
  pushl $149
80108e91:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108e96:	e9 38 f4 ff ff       	jmp    801082d3 <alltraps>

80108e9b <vector150>:
.globl vector150
vector150:
  pushl $0
80108e9b:	6a 00                	push   $0x0
  pushl $150
80108e9d:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108ea2:	e9 2c f4 ff ff       	jmp    801082d3 <alltraps>

80108ea7 <vector151>:
.globl vector151
vector151:
  pushl $0
80108ea7:	6a 00                	push   $0x0
  pushl $151
80108ea9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108eae:	e9 20 f4 ff ff       	jmp    801082d3 <alltraps>

80108eb3 <vector152>:
.globl vector152
vector152:
  pushl $0
80108eb3:	6a 00                	push   $0x0
  pushl $152
80108eb5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108eba:	e9 14 f4 ff ff       	jmp    801082d3 <alltraps>

80108ebf <vector153>:
.globl vector153
vector153:
  pushl $0
80108ebf:	6a 00                	push   $0x0
  pushl $153
80108ec1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108ec6:	e9 08 f4 ff ff       	jmp    801082d3 <alltraps>

80108ecb <vector154>:
.globl vector154
vector154:
  pushl $0
80108ecb:	6a 00                	push   $0x0
  pushl $154
80108ecd:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108ed2:	e9 fc f3 ff ff       	jmp    801082d3 <alltraps>

80108ed7 <vector155>:
.globl vector155
vector155:
  pushl $0
80108ed7:	6a 00                	push   $0x0
  pushl $155
80108ed9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108ede:	e9 f0 f3 ff ff       	jmp    801082d3 <alltraps>

80108ee3 <vector156>:
.globl vector156
vector156:
  pushl $0
80108ee3:	6a 00                	push   $0x0
  pushl $156
80108ee5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108eea:	e9 e4 f3 ff ff       	jmp    801082d3 <alltraps>

80108eef <vector157>:
.globl vector157
vector157:
  pushl $0
80108eef:	6a 00                	push   $0x0
  pushl $157
80108ef1:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108ef6:	e9 d8 f3 ff ff       	jmp    801082d3 <alltraps>

80108efb <vector158>:
.globl vector158
vector158:
  pushl $0
80108efb:	6a 00                	push   $0x0
  pushl $158
80108efd:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108f02:	e9 cc f3 ff ff       	jmp    801082d3 <alltraps>

80108f07 <vector159>:
.globl vector159
vector159:
  pushl $0
80108f07:	6a 00                	push   $0x0
  pushl $159
80108f09:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108f0e:	e9 c0 f3 ff ff       	jmp    801082d3 <alltraps>

80108f13 <vector160>:
.globl vector160
vector160:
  pushl $0
80108f13:	6a 00                	push   $0x0
  pushl $160
80108f15:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108f1a:	e9 b4 f3 ff ff       	jmp    801082d3 <alltraps>

80108f1f <vector161>:
.globl vector161
vector161:
  pushl $0
80108f1f:	6a 00                	push   $0x0
  pushl $161
80108f21:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108f26:	e9 a8 f3 ff ff       	jmp    801082d3 <alltraps>

80108f2b <vector162>:
.globl vector162
vector162:
  pushl $0
80108f2b:	6a 00                	push   $0x0
  pushl $162
80108f2d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108f32:	e9 9c f3 ff ff       	jmp    801082d3 <alltraps>

80108f37 <vector163>:
.globl vector163
vector163:
  pushl $0
80108f37:	6a 00                	push   $0x0
  pushl $163
80108f39:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108f3e:	e9 90 f3 ff ff       	jmp    801082d3 <alltraps>

80108f43 <vector164>:
.globl vector164
vector164:
  pushl $0
80108f43:	6a 00                	push   $0x0
  pushl $164
80108f45:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108f4a:	e9 84 f3 ff ff       	jmp    801082d3 <alltraps>

80108f4f <vector165>:
.globl vector165
vector165:
  pushl $0
80108f4f:	6a 00                	push   $0x0
  pushl $165
80108f51:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108f56:	e9 78 f3 ff ff       	jmp    801082d3 <alltraps>

80108f5b <vector166>:
.globl vector166
vector166:
  pushl $0
80108f5b:	6a 00                	push   $0x0
  pushl $166
80108f5d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108f62:	e9 6c f3 ff ff       	jmp    801082d3 <alltraps>

80108f67 <vector167>:
.globl vector167
vector167:
  pushl $0
80108f67:	6a 00                	push   $0x0
  pushl $167
80108f69:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108f6e:	e9 60 f3 ff ff       	jmp    801082d3 <alltraps>

80108f73 <vector168>:
.globl vector168
vector168:
  pushl $0
80108f73:	6a 00                	push   $0x0
  pushl $168
80108f75:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108f7a:	e9 54 f3 ff ff       	jmp    801082d3 <alltraps>

80108f7f <vector169>:
.globl vector169
vector169:
  pushl $0
80108f7f:	6a 00                	push   $0x0
  pushl $169
80108f81:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108f86:	e9 48 f3 ff ff       	jmp    801082d3 <alltraps>

80108f8b <vector170>:
.globl vector170
vector170:
  pushl $0
80108f8b:	6a 00                	push   $0x0
  pushl $170
80108f8d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108f92:	e9 3c f3 ff ff       	jmp    801082d3 <alltraps>

80108f97 <vector171>:
.globl vector171
vector171:
  pushl $0
80108f97:	6a 00                	push   $0x0
  pushl $171
80108f99:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108f9e:	e9 30 f3 ff ff       	jmp    801082d3 <alltraps>

80108fa3 <vector172>:
.globl vector172
vector172:
  pushl $0
80108fa3:	6a 00                	push   $0x0
  pushl $172
80108fa5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108faa:	e9 24 f3 ff ff       	jmp    801082d3 <alltraps>

80108faf <vector173>:
.globl vector173
vector173:
  pushl $0
80108faf:	6a 00                	push   $0x0
  pushl $173
80108fb1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108fb6:	e9 18 f3 ff ff       	jmp    801082d3 <alltraps>

80108fbb <vector174>:
.globl vector174
vector174:
  pushl $0
80108fbb:	6a 00                	push   $0x0
  pushl $174
80108fbd:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108fc2:	e9 0c f3 ff ff       	jmp    801082d3 <alltraps>

80108fc7 <vector175>:
.globl vector175
vector175:
  pushl $0
80108fc7:	6a 00                	push   $0x0
  pushl $175
80108fc9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108fce:	e9 00 f3 ff ff       	jmp    801082d3 <alltraps>

80108fd3 <vector176>:
.globl vector176
vector176:
  pushl $0
80108fd3:	6a 00                	push   $0x0
  pushl $176
80108fd5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108fda:	e9 f4 f2 ff ff       	jmp    801082d3 <alltraps>

80108fdf <vector177>:
.globl vector177
vector177:
  pushl $0
80108fdf:	6a 00                	push   $0x0
  pushl $177
80108fe1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108fe6:	e9 e8 f2 ff ff       	jmp    801082d3 <alltraps>

80108feb <vector178>:
.globl vector178
vector178:
  pushl $0
80108feb:	6a 00                	push   $0x0
  pushl $178
80108fed:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108ff2:	e9 dc f2 ff ff       	jmp    801082d3 <alltraps>

80108ff7 <vector179>:
.globl vector179
vector179:
  pushl $0
80108ff7:	6a 00                	push   $0x0
  pushl $179
80108ff9:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108ffe:	e9 d0 f2 ff ff       	jmp    801082d3 <alltraps>

80109003 <vector180>:
.globl vector180
vector180:
  pushl $0
80109003:	6a 00                	push   $0x0
  pushl $180
80109005:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010900a:	e9 c4 f2 ff ff       	jmp    801082d3 <alltraps>

8010900f <vector181>:
.globl vector181
vector181:
  pushl $0
8010900f:	6a 00                	push   $0x0
  pushl $181
80109011:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80109016:	e9 b8 f2 ff ff       	jmp    801082d3 <alltraps>

8010901b <vector182>:
.globl vector182
vector182:
  pushl $0
8010901b:	6a 00                	push   $0x0
  pushl $182
8010901d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80109022:	e9 ac f2 ff ff       	jmp    801082d3 <alltraps>

80109027 <vector183>:
.globl vector183
vector183:
  pushl $0
80109027:	6a 00                	push   $0x0
  pushl $183
80109029:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010902e:	e9 a0 f2 ff ff       	jmp    801082d3 <alltraps>

80109033 <vector184>:
.globl vector184
vector184:
  pushl $0
80109033:	6a 00                	push   $0x0
  pushl $184
80109035:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010903a:	e9 94 f2 ff ff       	jmp    801082d3 <alltraps>

8010903f <vector185>:
.globl vector185
vector185:
  pushl $0
8010903f:	6a 00                	push   $0x0
  pushl $185
80109041:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80109046:	e9 88 f2 ff ff       	jmp    801082d3 <alltraps>

8010904b <vector186>:
.globl vector186
vector186:
  pushl $0
8010904b:	6a 00                	push   $0x0
  pushl $186
8010904d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80109052:	e9 7c f2 ff ff       	jmp    801082d3 <alltraps>

80109057 <vector187>:
.globl vector187
vector187:
  pushl $0
80109057:	6a 00                	push   $0x0
  pushl $187
80109059:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010905e:	e9 70 f2 ff ff       	jmp    801082d3 <alltraps>

80109063 <vector188>:
.globl vector188
vector188:
  pushl $0
80109063:	6a 00                	push   $0x0
  pushl $188
80109065:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010906a:	e9 64 f2 ff ff       	jmp    801082d3 <alltraps>

8010906f <vector189>:
.globl vector189
vector189:
  pushl $0
8010906f:	6a 00                	push   $0x0
  pushl $189
80109071:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80109076:	e9 58 f2 ff ff       	jmp    801082d3 <alltraps>

8010907b <vector190>:
.globl vector190
vector190:
  pushl $0
8010907b:	6a 00                	push   $0x0
  pushl $190
8010907d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80109082:	e9 4c f2 ff ff       	jmp    801082d3 <alltraps>

80109087 <vector191>:
.globl vector191
vector191:
  pushl $0
80109087:	6a 00                	push   $0x0
  pushl $191
80109089:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010908e:	e9 40 f2 ff ff       	jmp    801082d3 <alltraps>

80109093 <vector192>:
.globl vector192
vector192:
  pushl $0
80109093:	6a 00                	push   $0x0
  pushl $192
80109095:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010909a:	e9 34 f2 ff ff       	jmp    801082d3 <alltraps>

8010909f <vector193>:
.globl vector193
vector193:
  pushl $0
8010909f:	6a 00                	push   $0x0
  pushl $193
801090a1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801090a6:	e9 28 f2 ff ff       	jmp    801082d3 <alltraps>

801090ab <vector194>:
.globl vector194
vector194:
  pushl $0
801090ab:	6a 00                	push   $0x0
  pushl $194
801090ad:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801090b2:	e9 1c f2 ff ff       	jmp    801082d3 <alltraps>

801090b7 <vector195>:
.globl vector195
vector195:
  pushl $0
801090b7:	6a 00                	push   $0x0
  pushl $195
801090b9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801090be:	e9 10 f2 ff ff       	jmp    801082d3 <alltraps>

801090c3 <vector196>:
.globl vector196
vector196:
  pushl $0
801090c3:	6a 00                	push   $0x0
  pushl $196
801090c5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801090ca:	e9 04 f2 ff ff       	jmp    801082d3 <alltraps>

801090cf <vector197>:
.globl vector197
vector197:
  pushl $0
801090cf:	6a 00                	push   $0x0
  pushl $197
801090d1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801090d6:	e9 f8 f1 ff ff       	jmp    801082d3 <alltraps>

801090db <vector198>:
.globl vector198
vector198:
  pushl $0
801090db:	6a 00                	push   $0x0
  pushl $198
801090dd:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801090e2:	e9 ec f1 ff ff       	jmp    801082d3 <alltraps>

801090e7 <vector199>:
.globl vector199
vector199:
  pushl $0
801090e7:	6a 00                	push   $0x0
  pushl $199
801090e9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801090ee:	e9 e0 f1 ff ff       	jmp    801082d3 <alltraps>

801090f3 <vector200>:
.globl vector200
vector200:
  pushl $0
801090f3:	6a 00                	push   $0x0
  pushl $200
801090f5:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801090fa:	e9 d4 f1 ff ff       	jmp    801082d3 <alltraps>

801090ff <vector201>:
.globl vector201
vector201:
  pushl $0
801090ff:	6a 00                	push   $0x0
  pushl $201
80109101:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80109106:	e9 c8 f1 ff ff       	jmp    801082d3 <alltraps>

8010910b <vector202>:
.globl vector202
vector202:
  pushl $0
8010910b:	6a 00                	push   $0x0
  pushl $202
8010910d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80109112:	e9 bc f1 ff ff       	jmp    801082d3 <alltraps>

80109117 <vector203>:
.globl vector203
vector203:
  pushl $0
80109117:	6a 00                	push   $0x0
  pushl $203
80109119:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010911e:	e9 b0 f1 ff ff       	jmp    801082d3 <alltraps>

80109123 <vector204>:
.globl vector204
vector204:
  pushl $0
80109123:	6a 00                	push   $0x0
  pushl $204
80109125:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010912a:	e9 a4 f1 ff ff       	jmp    801082d3 <alltraps>

8010912f <vector205>:
.globl vector205
vector205:
  pushl $0
8010912f:	6a 00                	push   $0x0
  pushl $205
80109131:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80109136:	e9 98 f1 ff ff       	jmp    801082d3 <alltraps>

8010913b <vector206>:
.globl vector206
vector206:
  pushl $0
8010913b:	6a 00                	push   $0x0
  pushl $206
8010913d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80109142:	e9 8c f1 ff ff       	jmp    801082d3 <alltraps>

80109147 <vector207>:
.globl vector207
vector207:
  pushl $0
80109147:	6a 00                	push   $0x0
  pushl $207
80109149:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010914e:	e9 80 f1 ff ff       	jmp    801082d3 <alltraps>

80109153 <vector208>:
.globl vector208
vector208:
  pushl $0
80109153:	6a 00                	push   $0x0
  pushl $208
80109155:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010915a:	e9 74 f1 ff ff       	jmp    801082d3 <alltraps>

8010915f <vector209>:
.globl vector209
vector209:
  pushl $0
8010915f:	6a 00                	push   $0x0
  pushl $209
80109161:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80109166:	e9 68 f1 ff ff       	jmp    801082d3 <alltraps>

8010916b <vector210>:
.globl vector210
vector210:
  pushl $0
8010916b:	6a 00                	push   $0x0
  pushl $210
8010916d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80109172:	e9 5c f1 ff ff       	jmp    801082d3 <alltraps>

80109177 <vector211>:
.globl vector211
vector211:
  pushl $0
80109177:	6a 00                	push   $0x0
  pushl $211
80109179:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010917e:	e9 50 f1 ff ff       	jmp    801082d3 <alltraps>

80109183 <vector212>:
.globl vector212
vector212:
  pushl $0
80109183:	6a 00                	push   $0x0
  pushl $212
80109185:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010918a:	e9 44 f1 ff ff       	jmp    801082d3 <alltraps>

8010918f <vector213>:
.globl vector213
vector213:
  pushl $0
8010918f:	6a 00                	push   $0x0
  pushl $213
80109191:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80109196:	e9 38 f1 ff ff       	jmp    801082d3 <alltraps>

8010919b <vector214>:
.globl vector214
vector214:
  pushl $0
8010919b:	6a 00                	push   $0x0
  pushl $214
8010919d:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801091a2:	e9 2c f1 ff ff       	jmp    801082d3 <alltraps>

801091a7 <vector215>:
.globl vector215
vector215:
  pushl $0
801091a7:	6a 00                	push   $0x0
  pushl $215
801091a9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801091ae:	e9 20 f1 ff ff       	jmp    801082d3 <alltraps>

801091b3 <vector216>:
.globl vector216
vector216:
  pushl $0
801091b3:	6a 00                	push   $0x0
  pushl $216
801091b5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801091ba:	e9 14 f1 ff ff       	jmp    801082d3 <alltraps>

801091bf <vector217>:
.globl vector217
vector217:
  pushl $0
801091bf:	6a 00                	push   $0x0
  pushl $217
801091c1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801091c6:	e9 08 f1 ff ff       	jmp    801082d3 <alltraps>

801091cb <vector218>:
.globl vector218
vector218:
  pushl $0
801091cb:	6a 00                	push   $0x0
  pushl $218
801091cd:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801091d2:	e9 fc f0 ff ff       	jmp    801082d3 <alltraps>

801091d7 <vector219>:
.globl vector219
vector219:
  pushl $0
801091d7:	6a 00                	push   $0x0
  pushl $219
801091d9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801091de:	e9 f0 f0 ff ff       	jmp    801082d3 <alltraps>

801091e3 <vector220>:
.globl vector220
vector220:
  pushl $0
801091e3:	6a 00                	push   $0x0
  pushl $220
801091e5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801091ea:	e9 e4 f0 ff ff       	jmp    801082d3 <alltraps>

801091ef <vector221>:
.globl vector221
vector221:
  pushl $0
801091ef:	6a 00                	push   $0x0
  pushl $221
801091f1:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801091f6:	e9 d8 f0 ff ff       	jmp    801082d3 <alltraps>

801091fb <vector222>:
.globl vector222
vector222:
  pushl $0
801091fb:	6a 00                	push   $0x0
  pushl $222
801091fd:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80109202:	e9 cc f0 ff ff       	jmp    801082d3 <alltraps>

80109207 <vector223>:
.globl vector223
vector223:
  pushl $0
80109207:	6a 00                	push   $0x0
  pushl $223
80109209:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010920e:	e9 c0 f0 ff ff       	jmp    801082d3 <alltraps>

80109213 <vector224>:
.globl vector224
vector224:
  pushl $0
80109213:	6a 00                	push   $0x0
  pushl $224
80109215:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010921a:	e9 b4 f0 ff ff       	jmp    801082d3 <alltraps>

8010921f <vector225>:
.globl vector225
vector225:
  pushl $0
8010921f:	6a 00                	push   $0x0
  pushl $225
80109221:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80109226:	e9 a8 f0 ff ff       	jmp    801082d3 <alltraps>

8010922b <vector226>:
.globl vector226
vector226:
  pushl $0
8010922b:	6a 00                	push   $0x0
  pushl $226
8010922d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80109232:	e9 9c f0 ff ff       	jmp    801082d3 <alltraps>

80109237 <vector227>:
.globl vector227
vector227:
  pushl $0
80109237:	6a 00                	push   $0x0
  pushl $227
80109239:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010923e:	e9 90 f0 ff ff       	jmp    801082d3 <alltraps>

80109243 <vector228>:
.globl vector228
vector228:
  pushl $0
80109243:	6a 00                	push   $0x0
  pushl $228
80109245:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010924a:	e9 84 f0 ff ff       	jmp    801082d3 <alltraps>

8010924f <vector229>:
.globl vector229
vector229:
  pushl $0
8010924f:	6a 00                	push   $0x0
  pushl $229
80109251:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80109256:	e9 78 f0 ff ff       	jmp    801082d3 <alltraps>

8010925b <vector230>:
.globl vector230
vector230:
  pushl $0
8010925b:	6a 00                	push   $0x0
  pushl $230
8010925d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80109262:	e9 6c f0 ff ff       	jmp    801082d3 <alltraps>

80109267 <vector231>:
.globl vector231
vector231:
  pushl $0
80109267:	6a 00                	push   $0x0
  pushl $231
80109269:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010926e:	e9 60 f0 ff ff       	jmp    801082d3 <alltraps>

80109273 <vector232>:
.globl vector232
vector232:
  pushl $0
80109273:	6a 00                	push   $0x0
  pushl $232
80109275:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010927a:	e9 54 f0 ff ff       	jmp    801082d3 <alltraps>

8010927f <vector233>:
.globl vector233
vector233:
  pushl $0
8010927f:	6a 00                	push   $0x0
  pushl $233
80109281:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80109286:	e9 48 f0 ff ff       	jmp    801082d3 <alltraps>

8010928b <vector234>:
.globl vector234
vector234:
  pushl $0
8010928b:	6a 00                	push   $0x0
  pushl $234
8010928d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80109292:	e9 3c f0 ff ff       	jmp    801082d3 <alltraps>

80109297 <vector235>:
.globl vector235
vector235:
  pushl $0
80109297:	6a 00                	push   $0x0
  pushl $235
80109299:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010929e:	e9 30 f0 ff ff       	jmp    801082d3 <alltraps>

801092a3 <vector236>:
.globl vector236
vector236:
  pushl $0
801092a3:	6a 00                	push   $0x0
  pushl $236
801092a5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801092aa:	e9 24 f0 ff ff       	jmp    801082d3 <alltraps>

801092af <vector237>:
.globl vector237
vector237:
  pushl $0
801092af:	6a 00                	push   $0x0
  pushl $237
801092b1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801092b6:	e9 18 f0 ff ff       	jmp    801082d3 <alltraps>

801092bb <vector238>:
.globl vector238
vector238:
  pushl $0
801092bb:	6a 00                	push   $0x0
  pushl $238
801092bd:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801092c2:	e9 0c f0 ff ff       	jmp    801082d3 <alltraps>

801092c7 <vector239>:
.globl vector239
vector239:
  pushl $0
801092c7:	6a 00                	push   $0x0
  pushl $239
801092c9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801092ce:	e9 00 f0 ff ff       	jmp    801082d3 <alltraps>

801092d3 <vector240>:
.globl vector240
vector240:
  pushl $0
801092d3:	6a 00                	push   $0x0
  pushl $240
801092d5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801092da:	e9 f4 ef ff ff       	jmp    801082d3 <alltraps>

801092df <vector241>:
.globl vector241
vector241:
  pushl $0
801092df:	6a 00                	push   $0x0
  pushl $241
801092e1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801092e6:	e9 e8 ef ff ff       	jmp    801082d3 <alltraps>

801092eb <vector242>:
.globl vector242
vector242:
  pushl $0
801092eb:	6a 00                	push   $0x0
  pushl $242
801092ed:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801092f2:	e9 dc ef ff ff       	jmp    801082d3 <alltraps>

801092f7 <vector243>:
.globl vector243
vector243:
  pushl $0
801092f7:	6a 00                	push   $0x0
  pushl $243
801092f9:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801092fe:	e9 d0 ef ff ff       	jmp    801082d3 <alltraps>

80109303 <vector244>:
.globl vector244
vector244:
  pushl $0
80109303:	6a 00                	push   $0x0
  pushl $244
80109305:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010930a:	e9 c4 ef ff ff       	jmp    801082d3 <alltraps>

8010930f <vector245>:
.globl vector245
vector245:
  pushl $0
8010930f:	6a 00                	push   $0x0
  pushl $245
80109311:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80109316:	e9 b8 ef ff ff       	jmp    801082d3 <alltraps>

8010931b <vector246>:
.globl vector246
vector246:
  pushl $0
8010931b:	6a 00                	push   $0x0
  pushl $246
8010931d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109322:	e9 ac ef ff ff       	jmp    801082d3 <alltraps>

80109327 <vector247>:
.globl vector247
vector247:
  pushl $0
80109327:	6a 00                	push   $0x0
  pushl $247
80109329:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010932e:	e9 a0 ef ff ff       	jmp    801082d3 <alltraps>

80109333 <vector248>:
.globl vector248
vector248:
  pushl $0
80109333:	6a 00                	push   $0x0
  pushl $248
80109335:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010933a:	e9 94 ef ff ff       	jmp    801082d3 <alltraps>

8010933f <vector249>:
.globl vector249
vector249:
  pushl $0
8010933f:	6a 00                	push   $0x0
  pushl $249
80109341:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80109346:	e9 88 ef ff ff       	jmp    801082d3 <alltraps>

8010934b <vector250>:
.globl vector250
vector250:
  pushl $0
8010934b:	6a 00                	push   $0x0
  pushl $250
8010934d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80109352:	e9 7c ef ff ff       	jmp    801082d3 <alltraps>

80109357 <vector251>:
.globl vector251
vector251:
  pushl $0
80109357:	6a 00                	push   $0x0
  pushl $251
80109359:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010935e:	e9 70 ef ff ff       	jmp    801082d3 <alltraps>

80109363 <vector252>:
.globl vector252
vector252:
  pushl $0
80109363:	6a 00                	push   $0x0
  pushl $252
80109365:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010936a:	e9 64 ef ff ff       	jmp    801082d3 <alltraps>

8010936f <vector253>:
.globl vector253
vector253:
  pushl $0
8010936f:	6a 00                	push   $0x0
  pushl $253
80109371:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80109376:	e9 58 ef ff ff       	jmp    801082d3 <alltraps>

8010937b <vector254>:
.globl vector254
vector254:
  pushl $0
8010937b:	6a 00                	push   $0x0
  pushl $254
8010937d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80109382:	e9 4c ef ff ff       	jmp    801082d3 <alltraps>

80109387 <vector255>:
.globl vector255
vector255:
  pushl $0
80109387:	6a 00                	push   $0x0
  pushl $255
80109389:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010938e:	e9 40 ef ff ff       	jmp    801082d3 <alltraps>

80109393 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80109393:	55                   	push   %ebp
80109394:	89 e5                	mov    %esp,%ebp
80109396:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80109399:	8b 45 0c             	mov    0xc(%ebp),%eax
8010939c:	83 e8 01             	sub    $0x1,%eax
8010939f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801093a3:	8b 45 08             	mov    0x8(%ebp),%eax
801093a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801093aa:	8b 45 08             	mov    0x8(%ebp),%eax
801093ad:	c1 e8 10             	shr    $0x10,%eax
801093b0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801093b4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801093b7:	0f 01 10             	lgdtl  (%eax)
}
801093ba:	90                   	nop
801093bb:	c9                   	leave  
801093bc:	c3                   	ret    

801093bd <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801093bd:	55                   	push   %ebp
801093be:	89 e5                	mov    %esp,%ebp
801093c0:	83 ec 04             	sub    $0x4,%esp
801093c3:	8b 45 08             	mov    0x8(%ebp),%eax
801093c6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801093ca:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801093ce:	0f 00 d8             	ltr    %ax
}
801093d1:	90                   	nop
801093d2:	c9                   	leave  
801093d3:	c3                   	ret    

801093d4 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801093d4:	55                   	push   %ebp
801093d5:	89 e5                	mov    %esp,%ebp
801093d7:	83 ec 04             	sub    $0x4,%esp
801093da:	8b 45 08             	mov    0x8(%ebp),%eax
801093dd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801093e1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801093e5:	8e e8                	mov    %eax,%gs
}
801093e7:	90                   	nop
801093e8:	c9                   	leave  
801093e9:	c3                   	ret    

801093ea <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801093ea:	55                   	push   %ebp
801093eb:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801093ed:	8b 45 08             	mov    0x8(%ebp),%eax
801093f0:	0f 22 d8             	mov    %eax,%cr3
}
801093f3:	90                   	nop
801093f4:	5d                   	pop    %ebp
801093f5:	c3                   	ret    

801093f6 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801093f6:	55                   	push   %ebp
801093f7:	89 e5                	mov    %esp,%ebp
801093f9:	8b 45 08             	mov    0x8(%ebp),%eax
801093fc:	05 00 00 00 80       	add    $0x80000000,%eax
80109401:	5d                   	pop    %ebp
80109402:	c3                   	ret    

80109403 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80109403:	55                   	push   %ebp
80109404:	89 e5                	mov    %esp,%ebp
80109406:	8b 45 08             	mov    0x8(%ebp),%eax
80109409:	05 00 00 00 80       	add    $0x80000000,%eax
8010940e:	5d                   	pop    %ebp
8010940f:	c3                   	ret    

80109410 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80109410:	55                   	push   %ebp
80109411:	89 e5                	mov    %esp,%ebp
80109413:	53                   	push   %ebx
80109414:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80109417:	e8 5a 9c ff ff       	call   80103076 <cpunum>
8010941c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109422:	05 80 43 11 80       	add    $0x80114380,%eax
80109427:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010942a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80109433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109436:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010943c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80109443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109446:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010944a:	83 e2 f0             	and    $0xfffffff0,%edx
8010944d:	83 ca 0a             	or     $0xa,%edx
80109450:	88 50 7d             	mov    %dl,0x7d(%eax)
80109453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109456:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010945a:	83 ca 10             	or     $0x10,%edx
8010945d:	88 50 7d             	mov    %dl,0x7d(%eax)
80109460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109463:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109467:	83 e2 9f             	and    $0xffffff9f,%edx
8010946a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010946d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109470:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109474:	83 ca 80             	or     $0xffffff80,%edx
80109477:	88 50 7d             	mov    %dl,0x7d(%eax)
8010947a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010947d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109481:	83 ca 0f             	or     $0xf,%edx
80109484:	88 50 7e             	mov    %dl,0x7e(%eax)
80109487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010948e:	83 e2 ef             	and    $0xffffffef,%edx
80109491:	88 50 7e             	mov    %dl,0x7e(%eax)
80109494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109497:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010949b:	83 e2 df             	and    $0xffffffdf,%edx
8010949e:	88 50 7e             	mov    %dl,0x7e(%eax)
801094a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801094a8:	83 ca 40             	or     $0x40,%edx
801094ab:	88 50 7e             	mov    %dl,0x7e(%eax)
801094ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801094b5:	83 ca 80             	or     $0xffffff80,%edx
801094b8:	88 50 7e             	mov    %dl,0x7e(%eax)
801094bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094be:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801094c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c5:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801094cc:	ff ff 
801094ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d1:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801094d8:	00 00 
801094da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094dd:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801094e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801094ee:	83 e2 f0             	and    $0xfffffff0,%edx
801094f1:	83 ca 02             	or     $0x2,%edx
801094f4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801094fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109504:	83 ca 10             	or     $0x10,%edx
80109507:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010950d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109510:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109517:	83 e2 9f             	and    $0xffffff9f,%edx
8010951a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109523:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010952a:	83 ca 80             	or     $0xffffff80,%edx
8010952d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109536:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010953d:	83 ca 0f             	or     $0xf,%edx
80109540:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109549:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109550:	83 e2 ef             	and    $0xffffffef,%edx
80109553:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109563:	83 e2 df             	and    $0xffffffdf,%edx
80109566:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010956c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010956f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109576:	83 ca 40             	or     $0x40,%edx
80109579:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010957f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109582:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109589:	83 ca 80             	or     $0xffffff80,%edx
8010958c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109595:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010959c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010959f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801095a6:	ff ff 
801095a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ab:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801095b2:	00 00 
801095b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b7:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801095be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801095c8:	83 e2 f0             	and    $0xfffffff0,%edx
801095cb:	83 ca 0a             	or     $0xa,%edx
801095ce:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801095d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801095de:	83 ca 10             	or     $0x10,%edx
801095e1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801095e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ea:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801095f1:	83 ca 60             	or     $0x60,%edx
801095f4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801095fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109604:	83 ca 80             	or     $0xffffff80,%edx
80109607:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010960d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109610:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109617:	83 ca 0f             	or     $0xf,%edx
8010961a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109623:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010962a:	83 e2 ef             	and    $0xffffffef,%edx
8010962d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109636:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010963d:	83 e2 df             	and    $0xffffffdf,%edx
80109640:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109649:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109650:	83 ca 40             	or     $0x40,%edx
80109653:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010965c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109663:	83 ca 80             	or     $0xffffff80,%edx
80109666:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010966c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966f:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80109676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109679:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80109680:	ff ff 
80109682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109685:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010968c:	00 00 
8010968e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109691:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80109698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801096a2:	83 e2 f0             	and    $0xfffffff0,%edx
801096a5:	83 ca 02             	or     $0x2,%edx
801096a8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801096ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801096b8:	83 ca 10             	or     $0x10,%edx
801096bb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801096c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801096cb:	83 ca 60             	or     $0x60,%edx
801096ce:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801096d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801096de:	83 ca 80             	or     $0xffffff80,%edx
801096e1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801096f1:	83 ca 0f             	or     $0xf,%edx
801096f4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801096fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096fd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109704:	83 e2 ef             	and    $0xffffffef,%edx
80109707:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010970d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109710:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109717:	83 e2 df             	and    $0xffffffdf,%edx
8010971a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109723:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010972a:	83 ca 40             	or     $0x40,%edx
8010972d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109736:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010973d:	83 ca 80             	or     $0xffffff80,%edx
80109740:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109749:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80109750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109753:	05 b4 00 00 00       	add    $0xb4,%eax
80109758:	89 c3                	mov    %eax,%ebx
8010975a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975d:	05 b4 00 00 00       	add    $0xb4,%eax
80109762:	c1 e8 10             	shr    $0x10,%eax
80109765:	89 c2                	mov    %eax,%edx
80109767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010976a:	05 b4 00 00 00       	add    $0xb4,%eax
8010976f:	c1 e8 18             	shr    $0x18,%eax
80109772:	89 c1                	mov    %eax,%ecx
80109774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109777:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010977e:	00 00 
80109780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109783:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010978a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978d:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80109793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109796:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010979d:	83 e2 f0             	and    $0xfffffff0,%edx
801097a0:	83 ca 02             	or     $0x2,%edx
801097a3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801097a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ac:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801097b3:	83 ca 10             	or     $0x10,%edx
801097b6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801097bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097bf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801097c6:	83 e2 9f             	and    $0xffffff9f,%edx
801097c9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801097cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801097d9:	83 ca 80             	or     $0xffffff80,%edx
801097dc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801097e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801097ec:	83 e2 f0             	and    $0xfffffff0,%edx
801097ef:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801097f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801097ff:	83 e2 ef             	and    $0xffffffef,%edx
80109802:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010980b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109812:	83 e2 df             	and    $0xffffffdf,%edx
80109815:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010981b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109825:	83 ca 40             	or     $0x40,%edx
80109828:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010982e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109831:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109838:	83 ca 80             	or     $0xffffff80,%edx
8010983b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109844:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010984a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984d:	83 c0 70             	add    $0x70,%eax
80109850:	83 ec 08             	sub    $0x8,%esp
80109853:	6a 38                	push   $0x38
80109855:	50                   	push   %eax
80109856:	e8 38 fb ff ff       	call   80109393 <lgdt>
8010985b:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
8010985e:	83 ec 0c             	sub    $0xc,%esp
80109861:	6a 18                	push   $0x18
80109863:	e8 6c fb ff ff       	call   801093d4 <loadgs>
80109868:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
8010986b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010986e:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80109874:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010987b:	00 00 00 00 
}
8010987f:	90                   	nop
80109880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109883:	c9                   	leave  
80109884:	c3                   	ret    

80109885 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80109885:	55                   	push   %ebp
80109886:	89 e5                	mov    %esp,%ebp
80109888:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010988b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010988e:	c1 e8 16             	shr    $0x16,%eax
80109891:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109898:	8b 45 08             	mov    0x8(%ebp),%eax
8010989b:	01 d0                	add    %edx,%eax
8010989d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801098a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a3:	8b 00                	mov    (%eax),%eax
801098a5:	83 e0 01             	and    $0x1,%eax
801098a8:	85 c0                	test   %eax,%eax
801098aa:	74 18                	je     801098c4 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801098ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098af:	8b 00                	mov    (%eax),%eax
801098b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801098b6:	50                   	push   %eax
801098b7:	e8 47 fb ff ff       	call   80109403 <p2v>
801098bc:	83 c4 04             	add    $0x4,%esp
801098bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801098c2:	eb 48                	jmp    8010990c <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801098c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801098c8:	74 0e                	je     801098d8 <walkpgdir+0x53>
801098ca:	e8 41 94 ff ff       	call   80102d10 <kalloc>
801098cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801098d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801098d6:	75 07                	jne    801098df <walkpgdir+0x5a>
      return 0;
801098d8:	b8 00 00 00 00       	mov    $0x0,%eax
801098dd:	eb 44                	jmp    80109923 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801098df:	83 ec 04             	sub    $0x4,%esp
801098e2:	68 00 10 00 00       	push   $0x1000
801098e7:	6a 00                	push   $0x0
801098e9:	ff 75 f4             	pushl  -0xc(%ebp)
801098ec:	e8 09 d4 ff ff       	call   80106cfa <memset>
801098f1:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801098f4:	83 ec 0c             	sub    $0xc,%esp
801098f7:	ff 75 f4             	pushl  -0xc(%ebp)
801098fa:	e8 f7 fa ff ff       	call   801093f6 <v2p>
801098ff:	83 c4 10             	add    $0x10,%esp
80109902:	83 c8 07             	or     $0x7,%eax
80109905:	89 c2                	mov    %eax,%edx
80109907:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010990a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010990c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010990f:	c1 e8 0c             	shr    $0xc,%eax
80109912:	25 ff 03 00 00       	and    $0x3ff,%eax
80109917:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010991e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109921:	01 d0                	add    %edx,%eax
}
80109923:	c9                   	leave  
80109924:	c3                   	ret    

80109925 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80109925:	55                   	push   %ebp
80109926:	89 e5                	mov    %esp,%ebp
80109928:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010992b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010992e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109933:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80109936:	8b 55 0c             	mov    0xc(%ebp),%edx
80109939:	8b 45 10             	mov    0x10(%ebp),%eax
8010993c:	01 d0                	add    %edx,%eax
8010993e:	83 e8 01             	sub    $0x1,%eax
80109941:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109946:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80109949:	83 ec 04             	sub    $0x4,%esp
8010994c:	6a 01                	push   $0x1
8010994e:	ff 75 f4             	pushl  -0xc(%ebp)
80109951:	ff 75 08             	pushl  0x8(%ebp)
80109954:	e8 2c ff ff ff       	call   80109885 <walkpgdir>
80109959:	83 c4 10             	add    $0x10,%esp
8010995c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010995f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109963:	75 07                	jne    8010996c <mappages+0x47>
      return -1;
80109965:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010996a:	eb 47                	jmp    801099b3 <mappages+0x8e>
    if(*pte & PTE_P)
8010996c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010996f:	8b 00                	mov    (%eax),%eax
80109971:	83 e0 01             	and    $0x1,%eax
80109974:	85 c0                	test   %eax,%eax
80109976:	74 0d                	je     80109985 <mappages+0x60>
      panic("remap");
80109978:	83 ec 0c             	sub    $0xc,%esp
8010997b:	68 50 aa 10 80       	push   $0x8010aa50
80109980:	e8 e1 6b ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80109985:	8b 45 18             	mov    0x18(%ebp),%eax
80109988:	0b 45 14             	or     0x14(%ebp),%eax
8010998b:	83 c8 01             	or     $0x1,%eax
8010998e:	89 c2                	mov    %eax,%edx
80109990:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109993:	89 10                	mov    %edx,(%eax)
    if(a == last)
80109995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109998:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010999b:	74 10                	je     801099ad <mappages+0x88>
      break;
    a += PGSIZE;
8010999d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801099a4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801099ab:	eb 9c                	jmp    80109949 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801099ad:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801099ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801099b3:	c9                   	leave  
801099b4:	c3                   	ret    

801099b5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801099b5:	55                   	push   %ebp
801099b6:	89 e5                	mov    %esp,%ebp
801099b8:	53                   	push   %ebx
801099b9:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801099bc:	e8 4f 93 ff ff       	call   80102d10 <kalloc>
801099c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801099c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801099c8:	75 0a                	jne    801099d4 <setupkvm+0x1f>
    return 0;
801099ca:	b8 00 00 00 00       	mov    $0x0,%eax
801099cf:	e9 8e 00 00 00       	jmp    80109a62 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
801099d4:	83 ec 04             	sub    $0x4,%esp
801099d7:	68 00 10 00 00       	push   $0x1000
801099dc:	6a 00                	push   $0x0
801099de:	ff 75 f0             	pushl  -0x10(%ebp)
801099e1:	e8 14 d3 ff ff       	call   80106cfa <memset>
801099e6:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801099e9:	83 ec 0c             	sub    $0xc,%esp
801099ec:	68 00 00 00 0e       	push   $0xe000000
801099f1:	e8 0d fa ff ff       	call   80109403 <p2v>
801099f6:	83 c4 10             	add    $0x10,%esp
801099f9:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801099fe:	76 0d                	jbe    80109a0d <setupkvm+0x58>
    panic("PHYSTOP too high");
80109a00:	83 ec 0c             	sub    $0xc,%esp
80109a03:	68 56 aa 10 80       	push   $0x8010aa56
80109a08:	e8 59 6b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109a0d:	c7 45 f4 c0 d4 10 80 	movl   $0x8010d4c0,-0xc(%ebp)
80109a14:	eb 40                	jmp    80109a56 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a19:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1f:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a25:	8b 58 08             	mov    0x8(%eax),%ebx
80109a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a2b:	8b 40 04             	mov    0x4(%eax),%eax
80109a2e:	29 c3                	sub    %eax,%ebx
80109a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a33:	8b 00                	mov    (%eax),%eax
80109a35:	83 ec 0c             	sub    $0xc,%esp
80109a38:	51                   	push   %ecx
80109a39:	52                   	push   %edx
80109a3a:	53                   	push   %ebx
80109a3b:	50                   	push   %eax
80109a3c:	ff 75 f0             	pushl  -0x10(%ebp)
80109a3f:	e8 e1 fe ff ff       	call   80109925 <mappages>
80109a44:	83 c4 20             	add    $0x20,%esp
80109a47:	85 c0                	test   %eax,%eax
80109a49:	79 07                	jns    80109a52 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80109a4b:	b8 00 00 00 00       	mov    $0x0,%eax
80109a50:	eb 10                	jmp    80109a62 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109a52:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80109a56:	81 7d f4 00 d5 10 80 	cmpl   $0x8010d500,-0xc(%ebp)
80109a5d:	72 b7                	jb     80109a16 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80109a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a65:	c9                   	leave  
80109a66:	c3                   	ret    

80109a67 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80109a67:	55                   	push   %ebp
80109a68:	89 e5                	mov    %esp,%ebp
80109a6a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80109a6d:	e8 43 ff ff ff       	call   801099b5 <setupkvm>
80109a72:	a3 38 79 11 80       	mov    %eax,0x80117938
  switchkvm();
80109a77:	e8 03 00 00 00       	call   80109a7f <switchkvm>
}
80109a7c:	90                   	nop
80109a7d:	c9                   	leave  
80109a7e:	c3                   	ret    

80109a7f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80109a7f:	55                   	push   %ebp
80109a80:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80109a82:	a1 38 79 11 80       	mov    0x80117938,%eax
80109a87:	50                   	push   %eax
80109a88:	e8 69 f9 ff ff       	call   801093f6 <v2p>
80109a8d:	83 c4 04             	add    $0x4,%esp
80109a90:	50                   	push   %eax
80109a91:	e8 54 f9 ff ff       	call   801093ea <lcr3>
80109a96:	83 c4 04             	add    $0x4,%esp
}
80109a99:	90                   	nop
80109a9a:	c9                   	leave  
80109a9b:	c3                   	ret    

80109a9c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80109a9c:	55                   	push   %ebp
80109a9d:	89 e5                	mov    %esp,%ebp
80109a9f:	56                   	push   %esi
80109aa0:	53                   	push   %ebx
  pushcli();
80109aa1:	e8 4e d1 ff ff       	call   80106bf4 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80109aa6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109aac:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109ab3:	83 c2 08             	add    $0x8,%edx
80109ab6:	89 d6                	mov    %edx,%esi
80109ab8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109abf:	83 c2 08             	add    $0x8,%edx
80109ac2:	c1 ea 10             	shr    $0x10,%edx
80109ac5:	89 d3                	mov    %edx,%ebx
80109ac7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109ace:	83 c2 08             	add    $0x8,%edx
80109ad1:	c1 ea 18             	shr    $0x18,%edx
80109ad4:	89 d1                	mov    %edx,%ecx
80109ad6:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109add:	67 00 
80109adf:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80109ae6:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109aec:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109af3:	83 e2 f0             	and    $0xfffffff0,%edx
80109af6:	83 ca 09             	or     $0x9,%edx
80109af9:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109aff:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b06:	83 ca 10             	or     $0x10,%edx
80109b09:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b0f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b16:	83 e2 9f             	and    $0xffffff9f,%edx
80109b19:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b1f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b26:	83 ca 80             	or     $0xffffff80,%edx
80109b29:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b2f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109b36:	83 e2 f0             	and    $0xfffffff0,%edx
80109b39:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109b3f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109b46:	83 e2 ef             	and    $0xffffffef,%edx
80109b49:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109b4f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109b56:	83 e2 df             	and    $0xffffffdf,%edx
80109b59:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109b5f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109b66:	83 ca 40             	or     $0x40,%edx
80109b69:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109b6f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109b76:	83 e2 7f             	and    $0x7f,%edx
80109b79:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109b7f:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80109b85:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109b8b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b92:	83 e2 ef             	and    $0xffffffef,%edx
80109b95:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109b9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109ba1:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80109ba7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109bad:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109bb4:	8b 52 08             	mov    0x8(%edx),%edx
80109bb7:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109bbd:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109bc0:	83 ec 0c             	sub    $0xc,%esp
80109bc3:	6a 30                	push   $0x30
80109bc5:	e8 f3 f7 ff ff       	call   801093bd <ltr>
80109bca:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd0:	8b 40 04             	mov    0x4(%eax),%eax
80109bd3:	85 c0                	test   %eax,%eax
80109bd5:	75 0d                	jne    80109be4 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80109bd7:	83 ec 0c             	sub    $0xc,%esp
80109bda:	68 67 aa 10 80       	push   $0x8010aa67
80109bdf:	e8 82 69 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80109be4:	8b 45 08             	mov    0x8(%ebp),%eax
80109be7:	8b 40 04             	mov    0x4(%eax),%eax
80109bea:	83 ec 0c             	sub    $0xc,%esp
80109bed:	50                   	push   %eax
80109bee:	e8 03 f8 ff ff       	call   801093f6 <v2p>
80109bf3:	83 c4 10             	add    $0x10,%esp
80109bf6:	83 ec 0c             	sub    $0xc,%esp
80109bf9:	50                   	push   %eax
80109bfa:	e8 eb f7 ff ff       	call   801093ea <lcr3>
80109bff:	83 c4 10             	add    $0x10,%esp
  popcli();
80109c02:	e8 32 d0 ff ff       	call   80106c39 <popcli>
}
80109c07:	90                   	nop
80109c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109c0b:	5b                   	pop    %ebx
80109c0c:	5e                   	pop    %esi
80109c0d:	5d                   	pop    %ebp
80109c0e:	c3                   	ret    

80109c0f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109c0f:	55                   	push   %ebp
80109c10:	89 e5                	mov    %esp,%ebp
80109c12:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80109c15:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109c1c:	76 0d                	jbe    80109c2b <inituvm+0x1c>
    panic("inituvm: more than a page");
80109c1e:	83 ec 0c             	sub    $0xc,%esp
80109c21:	68 7b aa 10 80       	push   $0x8010aa7b
80109c26:	e8 3b 69 ff ff       	call   80100566 <panic>
  mem = kalloc();
80109c2b:	e8 e0 90 ff ff       	call   80102d10 <kalloc>
80109c30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80109c33:	83 ec 04             	sub    $0x4,%esp
80109c36:	68 00 10 00 00       	push   $0x1000
80109c3b:	6a 00                	push   $0x0
80109c3d:	ff 75 f4             	pushl  -0xc(%ebp)
80109c40:	e8 b5 d0 ff ff       	call   80106cfa <memset>
80109c45:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109c48:	83 ec 0c             	sub    $0xc,%esp
80109c4b:	ff 75 f4             	pushl  -0xc(%ebp)
80109c4e:	e8 a3 f7 ff ff       	call   801093f6 <v2p>
80109c53:	83 c4 10             	add    $0x10,%esp
80109c56:	83 ec 0c             	sub    $0xc,%esp
80109c59:	6a 06                	push   $0x6
80109c5b:	50                   	push   %eax
80109c5c:	68 00 10 00 00       	push   $0x1000
80109c61:	6a 00                	push   $0x0
80109c63:	ff 75 08             	pushl  0x8(%ebp)
80109c66:	e8 ba fc ff ff       	call   80109925 <mappages>
80109c6b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80109c6e:	83 ec 04             	sub    $0x4,%esp
80109c71:	ff 75 10             	pushl  0x10(%ebp)
80109c74:	ff 75 0c             	pushl  0xc(%ebp)
80109c77:	ff 75 f4             	pushl  -0xc(%ebp)
80109c7a:	e8 3a d1 ff ff       	call   80106db9 <memmove>
80109c7f:	83 c4 10             	add    $0x10,%esp
}
80109c82:	90                   	nop
80109c83:	c9                   	leave  
80109c84:	c3                   	ret    

80109c85 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80109c85:	55                   	push   %ebp
80109c86:	89 e5                	mov    %esp,%ebp
80109c88:	53                   	push   %ebx
80109c89:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80109c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c8f:	25 ff 0f 00 00       	and    $0xfff,%eax
80109c94:	85 c0                	test   %eax,%eax
80109c96:	74 0d                	je     80109ca5 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80109c98:	83 ec 0c             	sub    $0xc,%esp
80109c9b:	68 98 aa 10 80       	push   $0x8010aa98
80109ca0:	e8 c1 68 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80109ca5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109cac:	e9 95 00 00 00       	jmp    80109d46 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
80109cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb7:	01 d0                	add    %edx,%eax
80109cb9:	83 ec 04             	sub    $0x4,%esp
80109cbc:	6a 00                	push   $0x0
80109cbe:	50                   	push   %eax
80109cbf:	ff 75 08             	pushl  0x8(%ebp)
80109cc2:	e8 be fb ff ff       	call   80109885 <walkpgdir>
80109cc7:	83 c4 10             	add    $0x10,%esp
80109cca:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109ccd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109cd1:	75 0d                	jne    80109ce0 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109cd3:	83 ec 0c             	sub    $0xc,%esp
80109cd6:	68 bb aa 10 80       	push   $0x8010aabb
80109cdb:	e8 86 68 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ce3:	8b 00                	mov    (%eax),%eax
80109ce5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109cea:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109ced:	8b 45 18             	mov    0x18(%ebp),%eax
80109cf0:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109cf3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109cf8:	77 0b                	ja     80109d05 <loaduvm+0x80>
      n = sz - i;
80109cfa:	8b 45 18             	mov    0x18(%ebp),%eax
80109cfd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109d00:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109d03:	eb 07                	jmp    80109d0c <loaduvm+0x87>
    else
      n = PGSIZE;
80109d05:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109d0c:	8b 55 14             	mov    0x14(%ebp),%edx
80109d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d12:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109d15:	83 ec 0c             	sub    $0xc,%esp
80109d18:	ff 75 e8             	pushl  -0x18(%ebp)
80109d1b:	e8 e3 f6 ff ff       	call   80109403 <p2v>
80109d20:	83 c4 10             	add    $0x10,%esp
80109d23:	ff 75 f0             	pushl  -0x10(%ebp)
80109d26:	53                   	push   %ebx
80109d27:	50                   	push   %eax
80109d28:	ff 75 10             	pushl  0x10(%ebp)
80109d2b:	e8 52 82 ff ff       	call   80101f82 <readi>
80109d30:	83 c4 10             	add    $0x10,%esp
80109d33:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109d36:	74 07                	je     80109d3f <loaduvm+0xba>
      return -1;
80109d38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109d3d:	eb 18                	jmp    80109d57 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109d3f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d49:	3b 45 18             	cmp    0x18(%ebp),%eax
80109d4c:	0f 82 5f ff ff ff    	jb     80109cb1 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109d52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109d57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d5a:	c9                   	leave  
80109d5b:	c3                   	ret    

80109d5c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109d5c:	55                   	push   %ebp
80109d5d:	89 e5                	mov    %esp,%ebp
80109d5f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109d62:	8b 45 10             	mov    0x10(%ebp),%eax
80109d65:	85 c0                	test   %eax,%eax
80109d67:	79 0a                	jns    80109d73 <allocuvm+0x17>
    return 0;
80109d69:	b8 00 00 00 00       	mov    $0x0,%eax
80109d6e:	e9 b0 00 00 00       	jmp    80109e23 <allocuvm+0xc7>
  if(newsz < oldsz)
80109d73:	8b 45 10             	mov    0x10(%ebp),%eax
80109d76:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109d79:	73 08                	jae    80109d83 <allocuvm+0x27>
    return oldsz;
80109d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d7e:	e9 a0 00 00 00       	jmp    80109e23 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109d83:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d86:	05 ff 0f 00 00       	add    $0xfff,%eax
80109d8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109d93:	eb 7f                	jmp    80109e14 <allocuvm+0xb8>
    mem = kalloc();
80109d95:	e8 76 8f ff ff       	call   80102d10 <kalloc>
80109d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109d9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109da1:	75 2b                	jne    80109dce <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109da3:	83 ec 0c             	sub    $0xc,%esp
80109da6:	68 d9 aa 10 80       	push   $0x8010aad9
80109dab:	e8 16 66 ff ff       	call   801003c6 <cprintf>
80109db0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109db3:	83 ec 04             	sub    $0x4,%esp
80109db6:	ff 75 0c             	pushl  0xc(%ebp)
80109db9:	ff 75 10             	pushl  0x10(%ebp)
80109dbc:	ff 75 08             	pushl  0x8(%ebp)
80109dbf:	e8 61 00 00 00       	call   80109e25 <deallocuvm>
80109dc4:	83 c4 10             	add    $0x10,%esp
      return 0;
80109dc7:	b8 00 00 00 00       	mov    $0x0,%eax
80109dcc:	eb 55                	jmp    80109e23 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109dce:	83 ec 04             	sub    $0x4,%esp
80109dd1:	68 00 10 00 00       	push   $0x1000
80109dd6:	6a 00                	push   $0x0
80109dd8:	ff 75 f0             	pushl  -0x10(%ebp)
80109ddb:	e8 1a cf ff ff       	call   80106cfa <memset>
80109de0:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109de3:	83 ec 0c             	sub    $0xc,%esp
80109de6:	ff 75 f0             	pushl  -0x10(%ebp)
80109de9:	e8 08 f6 ff ff       	call   801093f6 <v2p>
80109dee:	83 c4 10             	add    $0x10,%esp
80109df1:	89 c2                	mov    %eax,%edx
80109df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109df6:	83 ec 0c             	sub    $0xc,%esp
80109df9:	6a 06                	push   $0x6
80109dfb:	52                   	push   %edx
80109dfc:	68 00 10 00 00       	push   $0x1000
80109e01:	50                   	push   %eax
80109e02:	ff 75 08             	pushl  0x8(%ebp)
80109e05:	e8 1b fb ff ff       	call   80109925 <mappages>
80109e0a:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109e0d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e17:	3b 45 10             	cmp    0x10(%ebp),%eax
80109e1a:	0f 82 75 ff ff ff    	jb     80109d95 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109e20:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109e23:	c9                   	leave  
80109e24:	c3                   	ret    

80109e25 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109e25:	55                   	push   %ebp
80109e26:	89 e5                	mov    %esp,%ebp
80109e28:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109e2b:	8b 45 10             	mov    0x10(%ebp),%eax
80109e2e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e31:	72 08                	jb     80109e3b <deallocuvm+0x16>
    return oldsz;
80109e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e36:	e9 a5 00 00 00       	jmp    80109ee0 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109e3b:	8b 45 10             	mov    0x10(%ebp),%eax
80109e3e:	05 ff 0f 00 00       	add    $0xfff,%eax
80109e43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109e4b:	e9 81 00 00 00       	jmp    80109ed1 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e53:	83 ec 04             	sub    $0x4,%esp
80109e56:	6a 00                	push   $0x0
80109e58:	50                   	push   %eax
80109e59:	ff 75 08             	pushl  0x8(%ebp)
80109e5c:	e8 24 fa ff ff       	call   80109885 <walkpgdir>
80109e61:	83 c4 10             	add    $0x10,%esp
80109e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109e67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109e6b:	75 09                	jne    80109e76 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109e6d:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109e74:	eb 54                	jmp    80109eca <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e79:	8b 00                	mov    (%eax),%eax
80109e7b:	83 e0 01             	and    $0x1,%eax
80109e7e:	85 c0                	test   %eax,%eax
80109e80:	74 48                	je     80109eca <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e85:	8b 00                	mov    (%eax),%eax
80109e87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109e8f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109e93:	75 0d                	jne    80109ea2 <deallocuvm+0x7d>
        panic("kfree");
80109e95:	83 ec 0c             	sub    $0xc,%esp
80109e98:	68 f1 aa 10 80       	push   $0x8010aaf1
80109e9d:	e8 c4 66 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109ea2:	83 ec 0c             	sub    $0xc,%esp
80109ea5:	ff 75 ec             	pushl  -0x14(%ebp)
80109ea8:	e8 56 f5 ff ff       	call   80109403 <p2v>
80109ead:	83 c4 10             	add    $0x10,%esp
80109eb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109eb3:	83 ec 0c             	sub    $0xc,%esp
80109eb6:	ff 75 e8             	pushl  -0x18(%ebp)
80109eb9:	e8 b5 8d ff ff       	call   80102c73 <kfree>
80109ebe:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ec4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109eca:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109ed7:	0f 82 73 ff ff ff    	jb     80109e50 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109edd:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109ee0:	c9                   	leave  
80109ee1:	c3                   	ret    

80109ee2 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109ee2:	55                   	push   %ebp
80109ee3:	89 e5                	mov    %esp,%ebp
80109ee5:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109ee8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109eec:	75 0d                	jne    80109efb <freevm+0x19>
    panic("freevm: no pgdir");
80109eee:	83 ec 0c             	sub    $0xc,%esp
80109ef1:	68 f7 aa 10 80       	push   $0x8010aaf7
80109ef6:	e8 6b 66 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109efb:	83 ec 04             	sub    $0x4,%esp
80109efe:	6a 00                	push   $0x0
80109f00:	68 00 00 00 80       	push   $0x80000000
80109f05:	ff 75 08             	pushl  0x8(%ebp)
80109f08:	e8 18 ff ff ff       	call   80109e25 <deallocuvm>
80109f0d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109f10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109f17:	eb 4f                	jmp    80109f68 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109f23:	8b 45 08             	mov    0x8(%ebp),%eax
80109f26:	01 d0                	add    %edx,%eax
80109f28:	8b 00                	mov    (%eax),%eax
80109f2a:	83 e0 01             	and    $0x1,%eax
80109f2d:	85 c0                	test   %eax,%eax
80109f2f:	74 33                	je     80109f64 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f3e:	01 d0                	add    %edx,%eax
80109f40:	8b 00                	mov    (%eax),%eax
80109f42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f47:	83 ec 0c             	sub    $0xc,%esp
80109f4a:	50                   	push   %eax
80109f4b:	e8 b3 f4 ff ff       	call   80109403 <p2v>
80109f50:	83 c4 10             	add    $0x10,%esp
80109f53:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109f56:	83 ec 0c             	sub    $0xc,%esp
80109f59:	ff 75 f0             	pushl  -0x10(%ebp)
80109f5c:	e8 12 8d ff ff       	call   80102c73 <kfree>
80109f61:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109f64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109f68:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109f6f:	76 a8                	jbe    80109f19 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109f71:	83 ec 0c             	sub    $0xc,%esp
80109f74:	ff 75 08             	pushl  0x8(%ebp)
80109f77:	e8 f7 8c ff ff       	call   80102c73 <kfree>
80109f7c:	83 c4 10             	add    $0x10,%esp
}
80109f7f:	90                   	nop
80109f80:	c9                   	leave  
80109f81:	c3                   	ret    

80109f82 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109f82:	55                   	push   %ebp
80109f83:	89 e5                	mov    %esp,%ebp
80109f85:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109f88:	83 ec 04             	sub    $0x4,%esp
80109f8b:	6a 00                	push   $0x0
80109f8d:	ff 75 0c             	pushl  0xc(%ebp)
80109f90:	ff 75 08             	pushl  0x8(%ebp)
80109f93:	e8 ed f8 ff ff       	call   80109885 <walkpgdir>
80109f98:	83 c4 10             	add    $0x10,%esp
80109f9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109f9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109fa2:	75 0d                	jne    80109fb1 <clearpteu+0x2f>
    panic("clearpteu");
80109fa4:	83 ec 0c             	sub    $0xc,%esp
80109fa7:	68 08 ab 10 80       	push   $0x8010ab08
80109fac:	e8 b5 65 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb4:	8b 00                	mov    (%eax),%eax
80109fb6:	83 e0 fb             	and    $0xfffffffb,%eax
80109fb9:	89 c2                	mov    %eax,%edx
80109fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fbe:	89 10                	mov    %edx,(%eax)
}
80109fc0:	90                   	nop
80109fc1:	c9                   	leave  
80109fc2:	c3                   	ret    

80109fc3 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109fc3:	55                   	push   %ebp
80109fc4:	89 e5                	mov    %esp,%ebp
80109fc6:	53                   	push   %ebx
80109fc7:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109fca:	e8 e6 f9 ff ff       	call   801099b5 <setupkvm>
80109fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109fd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109fd6:	75 0a                	jne    80109fe2 <copyuvm+0x1f>
    return 0;
80109fd8:	b8 00 00 00 00       	mov    $0x0,%eax
80109fdd:	e9 f8 00 00 00       	jmp    8010a0da <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109fe2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109fe9:	e9 c4 00 00 00       	jmp    8010a0b2 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff1:	83 ec 04             	sub    $0x4,%esp
80109ff4:	6a 00                	push   $0x0
80109ff6:	50                   	push   %eax
80109ff7:	ff 75 08             	pushl  0x8(%ebp)
80109ffa:	e8 86 f8 ff ff       	call   80109885 <walkpgdir>
80109fff:	83 c4 10             	add    $0x10,%esp
8010a002:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a005:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a009:	75 0d                	jne    8010a018 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010a00b:	83 ec 0c             	sub    $0xc,%esp
8010a00e:	68 12 ab 10 80       	push   $0x8010ab12
8010a013:	e8 4e 65 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010a018:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a01b:	8b 00                	mov    (%eax),%eax
8010a01d:	83 e0 01             	and    $0x1,%eax
8010a020:	85 c0                	test   %eax,%eax
8010a022:	75 0d                	jne    8010a031 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010a024:	83 ec 0c             	sub    $0xc,%esp
8010a027:	68 2c ab 10 80       	push   $0x8010ab2c
8010a02c:	e8 35 65 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010a031:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a034:	8b 00                	mov    (%eax),%eax
8010a036:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a03b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010a03e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a041:	8b 00                	mov    (%eax),%eax
8010a043:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a048:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010a04b:	e8 c0 8c ff ff       	call   80102d10 <kalloc>
8010a050:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010a053:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010a057:	74 6a                	je     8010a0c3 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010a059:	83 ec 0c             	sub    $0xc,%esp
8010a05c:	ff 75 e8             	pushl  -0x18(%ebp)
8010a05f:	e8 9f f3 ff ff       	call   80109403 <p2v>
8010a064:	83 c4 10             	add    $0x10,%esp
8010a067:	83 ec 04             	sub    $0x4,%esp
8010a06a:	68 00 10 00 00       	push   $0x1000
8010a06f:	50                   	push   %eax
8010a070:	ff 75 e0             	pushl  -0x20(%ebp)
8010a073:	e8 41 cd ff ff       	call   80106db9 <memmove>
8010a078:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010a07b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010a07e:	83 ec 0c             	sub    $0xc,%esp
8010a081:	ff 75 e0             	pushl  -0x20(%ebp)
8010a084:	e8 6d f3 ff ff       	call   801093f6 <v2p>
8010a089:	83 c4 10             	add    $0x10,%esp
8010a08c:	89 c2                	mov    %eax,%edx
8010a08e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a091:	83 ec 0c             	sub    $0xc,%esp
8010a094:	53                   	push   %ebx
8010a095:	52                   	push   %edx
8010a096:	68 00 10 00 00       	push   $0x1000
8010a09b:	50                   	push   %eax
8010a09c:	ff 75 f0             	pushl  -0x10(%ebp)
8010a09f:	e8 81 f8 ff ff       	call   80109925 <mappages>
8010a0a4:	83 c4 20             	add    $0x20,%esp
8010a0a7:	85 c0                	test   %eax,%eax
8010a0a9:	78 1b                	js     8010a0c6 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010a0ab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a0b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0b5:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a0b8:	0f 82 30 ff ff ff    	jb     80109fee <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010a0be:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0c1:	eb 17                	jmp    8010a0da <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010a0c3:	90                   	nop
8010a0c4:	eb 01                	jmp    8010a0c7 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010a0c6:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010a0c7:	83 ec 0c             	sub    $0xc,%esp
8010a0ca:	ff 75 f0             	pushl  -0x10(%ebp)
8010a0cd:	e8 10 fe ff ff       	call   80109ee2 <freevm>
8010a0d2:	83 c4 10             	add    $0x10,%esp
  return 0;
8010a0d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a0da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a0dd:	c9                   	leave  
8010a0de:	c3                   	ret    

8010a0df <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010a0df:	55                   	push   %ebp
8010a0e0:	89 e5                	mov    %esp,%ebp
8010a0e2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a0e5:	83 ec 04             	sub    $0x4,%esp
8010a0e8:	6a 00                	push   $0x0
8010a0ea:	ff 75 0c             	pushl  0xc(%ebp)
8010a0ed:	ff 75 08             	pushl  0x8(%ebp)
8010a0f0:	e8 90 f7 ff ff       	call   80109885 <walkpgdir>
8010a0f5:	83 c4 10             	add    $0x10,%esp
8010a0f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a0fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0fe:	8b 00                	mov    (%eax),%eax
8010a100:	83 e0 01             	and    $0x1,%eax
8010a103:	85 c0                	test   %eax,%eax
8010a105:	75 07                	jne    8010a10e <uva2ka+0x2f>
    return 0;
8010a107:	b8 00 00 00 00       	mov    $0x0,%eax
8010a10c:	eb 29                	jmp    8010a137 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a10e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a111:	8b 00                	mov    (%eax),%eax
8010a113:	83 e0 04             	and    $0x4,%eax
8010a116:	85 c0                	test   %eax,%eax
8010a118:	75 07                	jne    8010a121 <uva2ka+0x42>
    return 0;
8010a11a:	b8 00 00 00 00       	mov    $0x0,%eax
8010a11f:	eb 16                	jmp    8010a137 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a121:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a124:	8b 00                	mov    (%eax),%eax
8010a126:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a12b:	83 ec 0c             	sub    $0xc,%esp
8010a12e:	50                   	push   %eax
8010a12f:	e8 cf f2 ff ff       	call   80109403 <p2v>
8010a134:	83 c4 10             	add    $0x10,%esp
}
8010a137:	c9                   	leave  
8010a138:	c3                   	ret    

8010a139 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a139:	55                   	push   %ebp
8010a13a:	89 e5                	mov    %esp,%ebp
8010a13c:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a13f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a142:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a145:	eb 7f                	jmp    8010a1c6 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a147:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a14a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a14f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a152:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a155:	83 ec 08             	sub    $0x8,%esp
8010a158:	50                   	push   %eax
8010a159:	ff 75 08             	pushl  0x8(%ebp)
8010a15c:	e8 7e ff ff ff       	call   8010a0df <uva2ka>
8010a161:	83 c4 10             	add    $0x10,%esp
8010a164:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a167:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a16b:	75 07                	jne    8010a174 <copyout+0x3b>
      return -1;
8010a16d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a172:	eb 61                	jmp    8010a1d5 <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a174:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a177:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a17a:	05 00 10 00 00       	add    $0x1000,%eax
8010a17f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a182:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a185:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a188:	76 06                	jbe    8010a190 <copyout+0x57>
      n = len;
8010a18a:	8b 45 14             	mov    0x14(%ebp),%eax
8010a18d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a190:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a193:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a196:	89 c2                	mov    %eax,%edx
8010a198:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a19b:	01 d0                	add    %edx,%eax
8010a19d:	83 ec 04             	sub    $0x4,%esp
8010a1a0:	ff 75 f0             	pushl  -0x10(%ebp)
8010a1a3:	ff 75 f4             	pushl  -0xc(%ebp)
8010a1a6:	50                   	push   %eax
8010a1a7:	e8 0d cc ff ff       	call   80106db9 <memmove>
8010a1ac:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a1af:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b2:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a1b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b8:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a1bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1be:	05 00 10 00 00       	add    $0x1000,%eax
8010a1c3:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a1c6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a1ca:	0f 85 77 ff ff ff    	jne    8010a147 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a1d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a1d5:	c9                   	leave  
8010a1d6:	c3                   	ret    
