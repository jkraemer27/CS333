
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
8010002d:	b8 44 3b 10 80       	mov    $0x80103b44,%eax
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
8010003d:	68 7c a5 10 80       	push   $0x8010a57c
80100042:	68 80 e6 10 80       	push   $0x8010e680
80100047:	e8 34 6c 00 00       	call   80106c80 <initlock>
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
801000c1:	e8 dc 6b 00 00       	call   80106ca2 <acquire>
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
8010010c:	e8 f8 6b 00 00       	call   80106d09 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 e6 10 80       	push   $0x8010e680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 61 58 00 00       	call   8010598d <sleep>
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
80100188:	e8 7c 6b 00 00       	call   80106d09 <release>
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
801001aa:	68 83 a5 10 80       	push   $0x8010a583
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
801001e2:	e8 db 29 00 00       	call   80102bc2 <iderw>
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
80100204:	68 94 a5 10 80       	push   $0x8010a594
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
80100223:	e8 9a 29 00 00       	call   80102bc2 <iderw>
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
80100243:	68 9b a5 10 80       	push   $0x8010a59b
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 e6 10 80       	push   $0x8010e680
80100255:	e8 48 6a 00 00       	call   80106ca2 <acquire>
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
801002b9:	e8 df 58 00 00       	call   80105b9d <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 e6 10 80       	push   $0x8010e680
801002c9:	e8 3b 6a 00 00       	call   80106d09 <release>
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
801003e2:	e8 bb 68 00 00       	call   80106ca2 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 a2 a5 10 80       	push   $0x8010a5a2
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
801004cd:	c7 45 ec ab a5 10 80 	movl   $0x8010a5ab,-0x14(%ebp)
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
8010055b:	e8 a9 67 00 00       	call   80106d09 <release>
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
8010058b:	68 b2 a5 10 80       	push   $0x8010a5b2
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
801005aa:	68 c1 a5 10 80       	push   $0x8010a5c1
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 94 67 00 00       	call   80106d5b <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 c3 a5 10 80       	push   $0x8010a5c3
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
801006ca:	68 c7 a5 10 80       	push   $0x8010a5c7
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
801006f7:	e8 c8 68 00 00       	call   80106fc4 <memmove>
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
80100721:	e8 df 67 00 00       	call   80106f05 <memset>
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
801007b6:	e8 48 84 00 00       	call   80108c03 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 3b 84 00 00       	call   80108c03 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 2e 84 00 00       	call   80108c03 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 1e 84 00 00       	call   80108c03 <uartputc>
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
8010082a:	e8 73 64 00 00       	call   80106ca2 <acquire>
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
801009d4:	e8 c4 51 00 00       	call   80105b9d <wakeup>
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
801009f7:	e8 0d 63 00 00       	call   80106d09 <release>
801009fc:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a03:	74 05                	je     80100a0a <consoleintr+0x211>
    procdump();  // now call procdump() wo. cons.lock held
80100a05:	e8 e9 53 00 00       	call   80105df3 <procdump>
  }

#ifdef CS333_P3P4
  if(doprintready)
80100a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a0e:	74 05                	je     80100a15 <consoleintr+0x21c>
      printready();
80100a10:	e8 61 5d 00 00       	call   80106776 <printready>
  if(doprintfree)
80100a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a19:	74 05                	je     80100a20 <consoleintr+0x227>
      printfree();
80100a1b:	e8 31 5e 00 00       	call   80106851 <printfree>
  if(doprintsleep)
80100a20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a24:	74 05                	je     80100a2b <consoleintr+0x232>
      printsleep();
80100a26:	e8 99 5e 00 00       	call   801068c4 <printsleep>
  if(doprintzombie)
80100a2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2f:	74 05                	je     80100a36 <consoleintr+0x23d>
      printzombie();
80100a31:	e8 3d 5f 00 00       	call   80106973 <printzombie>

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
80100a45:	e8 94 11 00 00       	call   80101bde <iunlock>
80100a4a:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a4d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a53:	83 ec 0c             	sub    $0xc,%esp
80100a56:	68 e0 d5 10 80       	push   $0x8010d5e0
80100a5b:	e8 42 62 00 00       	call   80106ca2 <acquire>
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
80100a7d:	e8 87 62 00 00       	call   80106d09 <release>
80100a82:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a85:	83 ec 0c             	sub    $0xc,%esp
80100a88:	ff 75 08             	pushl  0x8(%ebp)
80100a8b:	e8 c8 0f 00 00       	call   80101a58 <ilock>
80100a90:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a98:	e9 ab 00 00 00       	jmp    80100b48 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a9d:	83 ec 08             	sub    $0x8,%esp
80100aa0:	68 e0 d5 10 80       	push   $0x8010d5e0
80100aa5:	68 20 28 11 80       	push   $0x80112820
80100aaa:	e8 de 4e 00 00       	call   8010598d <sleep>
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
80100b28:	e8 dc 61 00 00       	call   80106d09 <release>
80100b2d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b30:	83 ec 0c             	sub    $0xc,%esp
80100b33:	ff 75 08             	pushl  0x8(%ebp)
80100b36:	e8 1d 0f 00 00       	call   80101a58 <ilock>
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
80100b56:	e8 83 10 00 00       	call   80101bde <iunlock>
80100b5b:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b5e:	83 ec 0c             	sub    $0xc,%esp
80100b61:	68 e0 d5 10 80       	push   $0x8010d5e0
80100b66:	e8 37 61 00 00       	call   80106ca2 <acquire>
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
80100ba8:	e8 5c 61 00 00       	call   80106d09 <release>
80100bad:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 08             	pushl  0x8(%ebp)
80100bb6:	e8 9d 0e 00 00       	call   80101a58 <ilock>
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
80100bcc:	68 da a5 10 80       	push   $0x8010a5da
80100bd1:	68 e0 d5 10 80       	push   $0x8010d5e0
80100bd6:	e8 a5 60 00 00       	call   80106c80 <initlock>
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
80100c01:	e8 da 35 00 00       	call   801041e0 <picenable>
80100c06:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100c09:	83 ec 08             	sub    $0x8,%esp
80100c0c:	6a 00                	push   $0x0
80100c0e:	6a 01                	push   $0x1
80100c10:	e8 7a 21 00 00       	call   80102d8f <ioapicenable>
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
80100c24:	e8 d9 2b 00 00       	call   80103802 <begin_op>
  if((ip = namei(path)) == 0){
80100c29:	83 ec 0c             	sub    $0xc,%esp
80100c2c:	ff 75 08             	pushl  0x8(%ebp)
80100c2f:	e8 32 1a 00 00       	call   80102666 <namei>
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c3e:	75 0f                	jne    80100c4f <exec+0x34>
    end_op();
80100c40:	e8 49 2c 00 00       	call   8010388e <end_op>
    return -1;
80100c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c4a:	e9 ce 03 00 00       	jmp    8010101d <exec+0x402>
  }
  ilock(ip);
80100c4f:	83 ec 0c             	sub    $0xc,%esp
80100c52:	ff 75 d8             	pushl  -0x28(%ebp)
80100c55:	e8 fe 0d 00 00       	call   80101a58 <ilock>
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
80100c72:	e8 9f 13 00 00       	call   80102016 <readi>
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
80100c94:	e8 bf 90 00 00       	call   80109d58 <setupkvm>
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
80100cd2:	e8 3f 13 00 00       	call   80102016 <readi>
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
80100d1a:	e8 e0 93 00 00       	call   8010a0ff <allocuvm>
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
80100d4d:	e8 d6 92 00 00       	call   8010a028 <loaduvm>
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
80100d86:	e8 b5 0f 00 00       	call   80101d40 <iunlockput>
80100d8b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d8e:	e8 fb 2a 00 00       	call   8010388e <end_op>
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
80100dbc:	e8 3e 93 00 00       	call   8010a0ff <allocuvm>
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
80100de0:	e8 40 95 00 00       	call   8010a325 <clearpteu>
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
80100e19:	e8 34 63 00 00       	call   80107152 <strlen>
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
80100e46:	e8 07 63 00 00       	call   80107152 <strlen>
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
80100e6c:	e8 6b 96 00 00       	call   8010a4dc <copyout>
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
80100f08:	e8 cf 95 00 00       	call   8010a4dc <copyout>
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
80100f59:	e8 aa 61 00 00       	call   80107108 <safestrcpy>
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
80100faf:	e8 8b 8e 00 00       	call   80109e3f <switchuvm>
80100fb4:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fb7:	83 ec 0c             	sub    $0xc,%esp
80100fba:	ff 75 d0             	pushl  -0x30(%ebp)
80100fbd:	e8 c3 92 00 00       	call   8010a285 <freevm>
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
80100ff7:	e8 89 92 00 00       	call   8010a285 <freevm>
80100ffc:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101003:	74 13                	je     80101018 <exec+0x3fd>
    iunlockput(ip);
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	ff 75 d8             	pushl  -0x28(%ebp)
8010100b:	e8 30 0d 00 00       	call   80101d40 <iunlockput>
80101010:	83 c4 10             	add    $0x10,%esp
    end_op();
80101013:	e8 76 28 00 00       	call   8010388e <end_op>
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
80101028:	68 e2 a5 10 80       	push   $0x8010a5e2
8010102d:	68 40 28 11 80       	push   $0x80112840
80101032:	e8 49 5c 00 00       	call   80106c80 <initlock>
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
8010104b:	e8 52 5c 00 00       	call   80106ca2 <acquire>
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
80101078:	e8 8c 5c 00 00       	call   80106d09 <release>
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
8010109b:	e8 69 5c 00 00       	call   80106d09 <release>
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
801010b8:	e8 e5 5b 00 00       	call   80106ca2 <acquire>
801010bd:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	8b 40 04             	mov    0x4(%eax),%eax
801010c6:	85 c0                	test   %eax,%eax
801010c8:	7f 0d                	jg     801010d7 <filedup+0x2d>
    panic("filedup");
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 e9 a5 10 80       	push   $0x8010a5e9
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
801010ee:	e8 16 5c 00 00       	call   80106d09 <release>
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
80101109:	e8 94 5b 00 00       	call   80106ca2 <acquire>
8010110e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101111:	8b 45 08             	mov    0x8(%ebp),%eax
80101114:	8b 40 04             	mov    0x4(%eax),%eax
80101117:	85 c0                	test   %eax,%eax
80101119:	7f 0d                	jg     80101128 <fileclose+0x2d>
    panic("fileclose");
8010111b:	83 ec 0c             	sub    $0xc,%esp
8010111e:	68 f1 a5 10 80       	push   $0x8010a5f1
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
80101149:	e8 bb 5b 00 00       	call   80106d09 <release>
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
80101197:	e8 6d 5b 00 00       	call   80106d09 <release>
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
801011b6:	e8 8e 32 00 00       	call   80104449 <pipeclose>
801011bb:	83 c4 10             	add    $0x10,%esp
801011be:	eb 21                	jmp    801011e1 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c3:	83 f8 02             	cmp    $0x2,%eax
801011c6:	75 19                	jne    801011e1 <fileclose+0xe6>
    begin_op();
801011c8:	e8 35 26 00 00       	call   80103802 <begin_op>
    iput(ff.ip);
801011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011d0:	83 ec 0c             	sub    $0xc,%esp
801011d3:	50                   	push   %eax
801011d4:	e8 77 0a 00 00       	call   80101c50 <iput>
801011d9:	83 c4 10             	add    $0x10,%esp
    end_op();
801011dc:	e8 ad 26 00 00       	call   8010388e <end_op>
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
801011fd:	e8 56 08 00 00       	call   80101a58 <ilock>
80101202:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101205:	8b 45 08             	mov    0x8(%ebp),%eax
80101208:	8b 40 10             	mov    0x10(%eax),%eax
8010120b:	83 ec 08             	sub    $0x8,%esp
8010120e:	ff 75 0c             	pushl  0xc(%ebp)
80101211:	50                   	push   %eax
80101212:	e8 91 0d 00 00       	call   80101fa8 <stati>
80101217:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 40 10             	mov    0x10(%eax),%eax
80101220:	83 ec 0c             	sub    $0xc,%esp
80101223:	50                   	push   %eax
80101224:	e8 b5 09 00 00       	call   80101bde <iunlock>
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
8010126f:	e8 7d 33 00 00       	call   801045f1 <piperead>
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
8010128d:	e8 c6 07 00 00       	call   80101a58 <ilock>
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
801012aa:	e8 67 0d 00 00       	call   80102016 <readi>
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
801012d6:	e8 03 09 00 00       	call   80101bde <iunlock>
801012db:	83 c4 10             	add    $0x10,%esp
    return r;
801012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e1:	eb 0d                	jmp    801012f0 <fileread+0xb6>
  }
  panic("fileread");
801012e3:	83 ec 0c             	sub    $0xc,%esp
801012e6:	68 fb a5 10 80       	push   $0x8010a5fb
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
80101328:	e8 c6 31 00 00       	call   801044f3 <pipewrite>
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
8010136d:	e8 90 24 00 00       	call   80103802 <begin_op>
      ilock(f->ip);
80101372:	8b 45 08             	mov    0x8(%ebp),%eax
80101375:	8b 40 10             	mov    0x10(%eax),%eax
80101378:	83 ec 0c             	sub    $0xc,%esp
8010137b:	50                   	push   %eax
8010137c:	e8 d7 06 00 00       	call   80101a58 <ilock>
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
8010139f:	e8 c9 0d 00 00       	call   8010216d <writei>
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
801013cb:	e8 0e 08 00 00       	call   80101bde <iunlock>
801013d0:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d3:	e8 b6 24 00 00       	call   8010388e <end_op>

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
801013e9:	68 04 a6 10 80       	push   $0x8010a604
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
8010141f:	68 14 a6 10 80       	push   $0x8010a614
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
80101457:	e8 68 5b 00 00       	call   80106fc4 <memmove>
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
8010149d:	e8 63 5a 00 00       	call   80106f05 <memset>
801014a2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014a5:	83 ec 0c             	sub    $0xc,%esp
801014a8:	ff 75 f4             	pushl  -0xc(%ebp)
801014ab:	e8 8a 25 00 00       	call   80103a3a <log_write>
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
8010157f:	e8 b6 24 00 00       	call   80103a3a <log_write>
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
80101604:	68 20 a6 10 80       	push   $0x8010a620
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
80101697:	68 36 a6 10 80       	push   $0x8010a636
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
801016cf:	e8 66 23 00 00       	call   80103a3a <log_write>
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
801016f4:	68 49 a6 10 80       	push   $0x8010a649
801016f9:	68 60 32 11 80       	push   $0x80113260
801016fe:	e8 7d 55 00 00       	call   80106c80 <initlock>
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
8010174d:	68 50 a6 10 80       	push   $0x8010a650
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
80101777:	e9 ba 00 00 00       	jmp    80101836 <ialloc+0xd3>
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
801017ba:	75 68                	jne    80101824 <ialloc+0xc1>
      #ifdef CS333_P5
      dip->uid = UIDGID;
801017bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017bf:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
      dip->gid = UIDGID;
801017c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
      dip->mode.asInt = MODE;
801017ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d1:	c7 40 0c ed 01 00 00 	movl   $0x1ed,0xc(%eax)
      #endif
      memset(dip, 0, sizeof(*dip));
801017d8:	83 ec 04             	sub    $0x4,%esp
801017db:	6a 40                	push   $0x40
801017dd:	6a 00                	push   $0x0
801017df:	ff 75 ec             	pushl  -0x14(%ebp)
801017e2:	e8 1e 57 00 00       	call   80106f05 <memset>
801017e7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ed:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017f1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017f4:	83 ec 0c             	sub    $0xc,%esp
801017f7:	ff 75 f0             	pushl  -0x10(%ebp)
801017fa:	e8 3b 22 00 00       	call   80103a3a <log_write>
801017ff:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101802:	83 ec 0c             	sub    $0xc,%esp
80101805:	ff 75 f0             	pushl  -0x10(%ebp)
80101808:	e8 21 ea ff ff       	call   8010022e <brelse>
8010180d:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101813:	83 ec 08             	sub    $0x8,%esp
80101816:	50                   	push   %eax
80101817:	ff 75 08             	pushl  0x8(%ebp)
8010181a:	e8 20 01 00 00       	call   8010193f <iget>
8010181f:	83 c4 10             	add    $0x10,%esp
80101822:	eb 30                	jmp    80101854 <ialloc+0xf1>
    }
    brelse(bp);
80101824:	83 ec 0c             	sub    $0xc,%esp
80101827:	ff 75 f0             	pushl  -0x10(%ebp)
8010182a:	e8 ff e9 ff ff       	call   8010022e <brelse>
8010182f:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101832:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101836:	8b 15 48 32 11 80    	mov    0x80113248,%edx
8010183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183f:	39 c2                	cmp    %eax,%edx
80101841:	0f 87 35 ff ff ff    	ja     8010177c <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101847:	83 ec 0c             	sub    $0xc,%esp
8010184a:	68 a3 a6 10 80       	push   $0x8010a6a3
8010184f:	e8 12 ed ff ff       	call   80100566 <panic>
}
80101854:	c9                   	leave  
80101855:	c3                   	ret    

80101856 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101856:	55                   	push   %ebp
80101857:	89 e5                	mov    %esp,%ebp
80101859:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010185c:	8b 45 08             	mov    0x8(%ebp),%eax
8010185f:	8b 40 04             	mov    0x4(%eax),%eax
80101862:	c1 e8 03             	shr    $0x3,%eax
80101865:	89 c2                	mov    %eax,%edx
80101867:	a1 54 32 11 80       	mov    0x80113254,%eax
8010186c:	01 c2                	add    %eax,%edx
8010186e:	8b 45 08             	mov    0x8(%ebp),%eax
80101871:	8b 00                	mov    (%eax),%eax
80101873:	83 ec 08             	sub    $0x8,%esp
80101876:	52                   	push   %edx
80101877:	50                   	push   %eax
80101878:	e8 39 e9 ff ff       	call   801001b6 <bread>
8010187d:	83 c4 10             	add    $0x10,%esp
80101880:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	8d 50 18             	lea    0x18(%eax),%edx
80101889:	8b 45 08             	mov    0x8(%ebp),%eax
8010188c:	8b 40 04             	mov    0x4(%eax),%eax
8010188f:	83 e0 07             	and    $0x7,%eax
80101892:	c1 e0 06             	shl    $0x6,%eax
80101895:	01 d0                	add    %edx,%eax
80101897:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010189a:	8b 45 08             	mov    0x8(%ebp),%eax
8010189d:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801018a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a4:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018a7:	8b 45 08             	mov    0x8(%ebp),%eax
801018aa:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b1:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018b5:	8b 45 08             	mov    0x8(%ebp),%eax
801018b8:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801018bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018bf:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cd:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018d1:	8b 45 08             	mov    0x8(%ebp),%eax
801018d4:	8b 50 20             	mov    0x20(%eax),%edx
801018d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018da:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  dip->uid = ip->uid;
801018dd:	8b 45 08             	mov    0x8(%ebp),%eax
801018e0:	0f b7 50 18          	movzwl 0x18(%eax),%edx
801018e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e7:	66 89 50 08          	mov    %dx,0x8(%eax)
  dip->gid = ip->gid;
801018eb:	8b 45 08             	mov    0x8(%ebp),%eax
801018ee:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
801018f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f5:	66 89 50 0a          	mov    %dx,0xa(%eax)
  dip->mode.asInt = ip->mode.asInt;
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8b 50 1c             	mov    0x1c(%eax),%edx
801018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101902:	89 50 0c             	mov    %edx,0xc(%eax)
#endif
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101905:	8b 45 08             	mov    0x8(%ebp),%eax
80101908:	8d 50 24             	lea    0x24(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	83 c0 14             	add    $0x14,%eax
80101911:	83 ec 04             	sub    $0x4,%esp
80101914:	6a 2c                	push   $0x2c
80101916:	52                   	push   %edx
80101917:	50                   	push   %eax
80101918:	e8 a7 56 00 00       	call   80106fc4 <memmove>
8010191d:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101920:	83 ec 0c             	sub    $0xc,%esp
80101923:	ff 75 f4             	pushl  -0xc(%ebp)
80101926:	e8 0f 21 00 00       	call   80103a3a <log_write>
8010192b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010192e:	83 ec 0c             	sub    $0xc,%esp
80101931:	ff 75 f4             	pushl  -0xc(%ebp)
80101934:	e8 f5 e8 ff ff       	call   8010022e <brelse>
80101939:	83 c4 10             	add    $0x10,%esp
}
8010193c:	90                   	nop
8010193d:	c9                   	leave  
8010193e:	c3                   	ret    

8010193f <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010193f:	55                   	push   %ebp
80101940:	89 e5                	mov    %esp,%ebp
80101942:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101945:	83 ec 0c             	sub    $0xc,%esp
80101948:	68 60 32 11 80       	push   $0x80113260
8010194d:	e8 50 53 00 00       	call   80106ca2 <acquire>
80101952:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101955:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010195c:	c7 45 f4 94 32 11 80 	movl   $0x80113294,-0xc(%ebp)
80101963:	eb 5d                	jmp    801019c2 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101968:	8b 40 08             	mov    0x8(%eax),%eax
8010196b:	85 c0                	test   %eax,%eax
8010196d:	7e 39                	jle    801019a8 <iget+0x69>
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	8b 00                	mov    (%eax),%eax
80101974:	3b 45 08             	cmp    0x8(%ebp),%eax
80101977:	75 2f                	jne    801019a8 <iget+0x69>
80101979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197c:	8b 40 04             	mov    0x4(%eax),%eax
8010197f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101982:	75 24                	jne    801019a8 <iget+0x69>
      ip->ref++;
80101984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101987:	8b 40 08             	mov    0x8(%eax),%eax
8010198a:	8d 50 01             	lea    0x1(%eax),%edx
8010198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101990:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101993:	83 ec 0c             	sub    $0xc,%esp
80101996:	68 60 32 11 80       	push   $0x80113260
8010199b:	e8 69 53 00 00       	call   80106d09 <release>
801019a0:	83 c4 10             	add    $0x10,%esp
      return ip;
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	eb 74                	jmp    80101a1c <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ac:	75 10                	jne    801019be <iget+0x7f>
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	8b 40 08             	mov    0x8(%eax),%eax
801019b4:	85 c0                	test   %eax,%eax
801019b6:	75 06                	jne    801019be <iget+0x7f>
      empty = ip;
801019b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019be:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801019c2:	81 7d f4 34 42 11 80 	cmpl   $0x80114234,-0xc(%ebp)
801019c9:	72 9a                	jb     80101965 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019cf:	75 0d                	jne    801019de <iget+0x9f>
    panic("iget: no inodes");
801019d1:	83 ec 0c             	sub    $0xc,%esp
801019d4:	68 b5 a6 10 80       	push   $0x8010a6b5
801019d9:	e8 88 eb ff ff       	call   80100566 <panic>

  ip = empty;
801019de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e7:	8b 55 08             	mov    0x8(%ebp),%edx
801019ea:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801019f2:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a02:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101a09:	83 ec 0c             	sub    $0xc,%esp
80101a0c:	68 60 32 11 80       	push   $0x80113260
80101a11:	e8 f3 52 00 00       	call   80106d09 <release>
80101a16:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a1c:	c9                   	leave  
80101a1d:	c3                   	ret    

80101a1e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a1e:	55                   	push   %ebp
80101a1f:	89 e5                	mov    %esp,%ebp
80101a21:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a24:	83 ec 0c             	sub    $0xc,%esp
80101a27:	68 60 32 11 80       	push   $0x80113260
80101a2c:	e8 71 52 00 00       	call   80106ca2 <acquire>
80101a31:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8b 40 08             	mov    0x8(%eax),%eax
80101a3a:	8d 50 01             	lea    0x1(%eax),%edx
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a43:	83 ec 0c             	sub    $0xc,%esp
80101a46:	68 60 32 11 80       	push   $0x80113260
80101a4b:	e8 b9 52 00 00       	call   80106d09 <release>
80101a50:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a53:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a56:	c9                   	leave  
80101a57:	c3                   	ret    

80101a58 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a58:	55                   	push   %ebp
80101a59:	89 e5                	mov    %esp,%ebp
80101a5b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a5e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a62:	74 0a                	je     80101a6e <ilock+0x16>
80101a64:	8b 45 08             	mov    0x8(%ebp),%eax
80101a67:	8b 40 08             	mov    0x8(%eax),%eax
80101a6a:	85 c0                	test   %eax,%eax
80101a6c:	7f 0d                	jg     80101a7b <ilock+0x23>
    panic("ilock");
80101a6e:	83 ec 0c             	sub    $0xc,%esp
80101a71:	68 c5 a6 10 80       	push   $0x8010a6c5
80101a76:	e8 eb ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a7b:	83 ec 0c             	sub    $0xc,%esp
80101a7e:	68 60 32 11 80       	push   $0x80113260
80101a83:	e8 1a 52 00 00       	call   80106ca2 <acquire>
80101a88:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a8b:	eb 13                	jmp    80101aa0 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a8d:	83 ec 08             	sub    $0x8,%esp
80101a90:	68 60 32 11 80       	push   $0x80113260
80101a95:	ff 75 08             	pushl  0x8(%ebp)
80101a98:	e8 f0 3e 00 00       	call   8010598d <sleep>
80101a9d:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa6:	83 e0 01             	and    $0x1,%eax
80101aa9:	85 c0                	test   %eax,%eax
80101aab:	75 e0                	jne    80101a8d <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab3:	83 c8 01             	or     $0x1,%eax
80101ab6:	89 c2                	mov    %eax,%edx
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101abe:	83 ec 0c             	sub    $0xc,%esp
80101ac1:	68 60 32 11 80       	push   $0x80113260
80101ac6:	e8 3e 52 00 00       	call   80106d09 <release>
80101acb:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad4:	83 e0 02             	and    $0x2,%eax
80101ad7:	85 c0                	test   %eax,%eax
80101ad9:	0f 85 fc 00 00 00    	jne    80101bdb <ilock+0x183>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	8b 40 04             	mov    0x4(%eax),%eax
80101ae5:	c1 e8 03             	shr    $0x3,%eax
80101ae8:	89 c2                	mov    %eax,%edx
80101aea:	a1 54 32 11 80       	mov    0x80113254,%eax
80101aef:	01 c2                	add    %eax,%edx
80101af1:	8b 45 08             	mov    0x8(%ebp),%eax
80101af4:	8b 00                	mov    (%eax),%eax
80101af6:	83 ec 08             	sub    $0x8,%esp
80101af9:	52                   	push   %edx
80101afa:	50                   	push   %eax
80101afb:	e8 b6 e6 ff ff       	call   801001b6 <bread>
80101b00:	83 c4 10             	add    $0x10,%esp
80101b03:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b09:	8d 50 18             	lea    0x18(%eax),%edx
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	8b 40 04             	mov    0x4(%eax),%eax
80101b12:	83 e0 07             	and    $0x7,%eax
80101b15:	c1 e0 06             	shl    $0x6,%eax
80101b18:	01 d0                	add    %edx,%eax
80101b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b20:	0f b7 10             	movzwl (%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b42:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b49:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b50:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b57:	8b 50 10             	mov    0x10(%eax),%edx
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	89 50 20             	mov    %edx,0x20(%eax)
#ifdef CS333_P5
    ip->uid = dip->uid;
80101b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b63:	0f b7 50 08          	movzwl 0x8(%eax),%edx
80101b67:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6a:	66 89 50 18          	mov    %dx,0x18(%eax)
    ip->gid = dip->gid;
80101b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b71:	0f b7 50 0a          	movzwl 0xa(%eax),%edx
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	66 89 50 1a          	mov    %dx,0x1a(%eax)
    ip->mode.asInt = dip->mode.asInt;
80101b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b7f:	8b 50 0c             	mov    0xc(%eax),%edx
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	89 50 1c             	mov    %edx,0x1c(%eax)
#endif
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8b:	8d 50 14             	lea    0x14(%eax),%edx
80101b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b91:	83 c0 24             	add    $0x24,%eax
80101b94:	83 ec 04             	sub    $0x4,%esp
80101b97:	6a 2c                	push   $0x2c
80101b99:	52                   	push   %edx
80101b9a:	50                   	push   %eax
80101b9b:	e8 24 54 00 00       	call   80106fc4 <memmove>
80101ba0:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ba3:	83 ec 0c             	sub    $0xc,%esp
80101ba6:	ff 75 f4             	pushl  -0xc(%ebp)
80101ba9:	e8 80 e6 ff ff       	call   8010022e <brelse>
80101bae:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb4:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb7:	83 c8 02             	or     $0x2,%eax
80101bba:	89 c2                	mov    %eax,%edx
80101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbf:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101bc9:	66 85 c0             	test   %ax,%ax
80101bcc:	75 0d                	jne    80101bdb <ilock+0x183>
      panic("ilock: no type");
80101bce:	83 ec 0c             	sub    $0xc,%esp
80101bd1:	68 cb a6 10 80       	push   $0x8010a6cb
80101bd6:	e8 8b e9 ff ff       	call   80100566 <panic>
  }
}
80101bdb:	90                   	nop
80101bdc:	c9                   	leave  
80101bdd:	c3                   	ret    

80101bde <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bde:	55                   	push   %ebp
80101bdf:	89 e5                	mov    %esp,%ebp
80101be1:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101be4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101be8:	74 17                	je     80101c01 <iunlock+0x23>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 0c             	mov    0xc(%eax),%eax
80101bf0:	83 e0 01             	and    $0x1,%eax
80101bf3:	85 c0                	test   %eax,%eax
80101bf5:	74 0a                	je     80101c01 <iunlock+0x23>
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	8b 40 08             	mov    0x8(%eax),%eax
80101bfd:	85 c0                	test   %eax,%eax
80101bff:	7f 0d                	jg     80101c0e <iunlock+0x30>
    panic("iunlock");
80101c01:	83 ec 0c             	sub    $0xc,%esp
80101c04:	68 da a6 10 80       	push   $0x8010a6da
80101c09:	e8 58 e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c0e:	83 ec 0c             	sub    $0xc,%esp
80101c11:	68 60 32 11 80       	push   $0x80113260
80101c16:	e8 87 50 00 00       	call   80106ca2 <acquire>
80101c1b:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c21:	8b 40 0c             	mov    0xc(%eax),%eax
80101c24:	83 e0 fe             	and    $0xfffffffe,%eax
80101c27:	89 c2                	mov    %eax,%edx
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	pushl  0x8(%ebp)
80101c35:	e8 63 3f 00 00       	call   80105b9d <wakeup>
80101c3a:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101c3d:	83 ec 0c             	sub    $0xc,%esp
80101c40:	68 60 32 11 80       	push   $0x80113260
80101c45:	e8 bf 50 00 00       	call   80106d09 <release>
80101c4a:	83 c4 10             	add    $0x10,%esp
}
80101c4d:	90                   	nop
80101c4e:	c9                   	leave  
80101c4f:	c3                   	ret    

80101c50 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c50:	55                   	push   %ebp
80101c51:	89 e5                	mov    %esp,%ebp
80101c53:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101c56:	83 ec 0c             	sub    $0xc,%esp
80101c59:	68 60 32 11 80       	push   $0x80113260
80101c5e:	e8 3f 50 00 00       	call   80106ca2 <acquire>
80101c63:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101c66:	8b 45 08             	mov    0x8(%ebp),%eax
80101c69:	8b 40 08             	mov    0x8(%eax),%eax
80101c6c:	83 f8 01             	cmp    $0x1,%eax
80101c6f:	0f 85 a9 00 00 00    	jne    80101d1e <iput+0xce>
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	8b 40 0c             	mov    0xc(%eax),%eax
80101c7b:	83 e0 02             	and    $0x2,%eax
80101c7e:	85 c0                	test   %eax,%eax
80101c80:	0f 84 98 00 00 00    	je     80101d1e <iput+0xce>
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c8d:	66 85 c0             	test   %ax,%ax
80101c90:	0f 85 88 00 00 00    	jne    80101d1e <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 40 0c             	mov    0xc(%eax),%eax
80101c9c:	83 e0 01             	and    $0x1,%eax
80101c9f:	85 c0                	test   %eax,%eax
80101ca1:	74 0d                	je     80101cb0 <iput+0x60>
      panic("iput busy");
80101ca3:	83 ec 0c             	sub    $0xc,%esp
80101ca6:	68 e2 a6 10 80       	push   $0x8010a6e2
80101cab:	e8 b6 e8 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb3:	8b 40 0c             	mov    0xc(%eax),%eax
80101cb6:	83 c8 01             	or     $0x1,%eax
80101cb9:	89 c2                	mov    %eax,%edx
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101cc1:	83 ec 0c             	sub    $0xc,%esp
80101cc4:	68 60 32 11 80       	push   $0x80113260
80101cc9:	e8 3b 50 00 00       	call   80106d09 <release>
80101cce:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	ff 75 08             	pushl  0x8(%ebp)
80101cd7:	e8 a8 01 00 00       	call   80101e84 <itrunc>
80101cdc:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ce8:	83 ec 0c             	sub    $0xc,%esp
80101ceb:	ff 75 08             	pushl  0x8(%ebp)
80101cee:	e8 63 fb ff ff       	call   80101856 <iupdate>
80101cf3:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101cf6:	83 ec 0c             	sub    $0xc,%esp
80101cf9:	68 60 32 11 80       	push   $0x80113260
80101cfe:	e8 9f 4f 00 00       	call   80106ca2 <acquire>
80101d03:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101d10:	83 ec 0c             	sub    $0xc,%esp
80101d13:	ff 75 08             	pushl  0x8(%ebp)
80101d16:	e8 82 3e 00 00       	call   80105b9d <wakeup>
80101d1b:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d21:	8b 40 08             	mov    0x8(%eax),%eax
80101d24:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d2d:	83 ec 0c             	sub    $0xc,%esp
80101d30:	68 60 32 11 80       	push   $0x80113260
80101d35:	e8 cf 4f 00 00       	call   80106d09 <release>
80101d3a:	83 c4 10             	add    $0x10,%esp
}
80101d3d:	90                   	nop
80101d3e:	c9                   	leave  
80101d3f:	c3                   	ret    

80101d40 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d40:	55                   	push   %ebp
80101d41:	89 e5                	mov    %esp,%ebp
80101d43:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 08             	pushl  0x8(%ebp)
80101d4c:	e8 8d fe ff ff       	call   80101bde <iunlock>
80101d51:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d54:	83 ec 0c             	sub    $0xc,%esp
80101d57:	ff 75 08             	pushl  0x8(%ebp)
80101d5a:	e8 f1 fe ff ff       	call   80101c50 <iput>
80101d5f:	83 c4 10             	add    $0x10,%esp
}
80101d62:	90                   	nop
80101d63:	c9                   	leave  
80101d64:	c3                   	ret    

80101d65 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d65:	55                   	push   %ebp
80101d66:	89 e5                	mov    %esp,%ebp
80101d68:	53                   	push   %ebx
80101d69:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d6c:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
80101d70:	77 42                	ja     80101db4 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d78:	83 c2 08             	add    $0x8,%edx
80101d7b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d86:	75 24                	jne    80101dac <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 00                	mov    (%eax),%eax
80101d8d:	83 ec 0c             	sub    $0xc,%esp
80101d90:	50                   	push   %eax
80101d91:	e8 2e f7 ff ff       	call   801014c4 <balloc>
80101d96:	83 c4 10             	add    $0x10,%esp
80101d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101da2:	8d 4a 08             	lea    0x8(%edx),%ecx
80101da5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da8:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
    return addr;
80101dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101daf:	e9 cb 00 00 00       	jmp    80101e7f <bmap+0x11a>
  }
  bn -= NDIRECT;
80101db4:	83 6d 0c 0a          	subl   $0xa,0xc(%ebp)

  if(bn < NINDIRECT){
80101db8:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101dbc:	0f 87 b0 00 00 00    	ja     80101e72 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dcf:	75 1d                	jne    80101dee <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	8b 00                	mov    (%eax),%eax
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	50                   	push   %eax
80101dda:	e8 e5 f6 ff ff       	call   801014c4 <balloc>
80101ddf:	83 c4 10             	add    $0x10,%esp
80101de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de5:	8b 45 08             	mov    0x8(%ebp),%eax
80101de8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101deb:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101dee:	8b 45 08             	mov    0x8(%ebp),%eax
80101df1:	8b 00                	mov    (%eax),%eax
80101df3:	83 ec 08             	sub    $0x8,%esp
80101df6:	ff 75 f4             	pushl  -0xc(%ebp)
80101df9:	50                   	push   %eax
80101dfa:	e8 b7 e3 ff ff       	call   801001b6 <bread>
80101dff:	83 c4 10             	add    $0x10,%esp
80101e02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e08:	83 c0 18             	add    $0x18,%eax
80101e0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e11:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e1b:	01 d0                	add    %edx,%eax
80101e1d:	8b 00                	mov    (%eax),%eax
80101e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e26:	75 37                	jne    80101e5f <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e35:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101e38:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3b:	8b 00                	mov    (%eax),%eax
80101e3d:	83 ec 0c             	sub    $0xc,%esp
80101e40:	50                   	push   %eax
80101e41:	e8 7e f6 ff ff       	call   801014c4 <balloc>
80101e46:	83 c4 10             	add    $0x10,%esp
80101e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e4f:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101e51:	83 ec 0c             	sub    $0xc,%esp
80101e54:	ff 75 f0             	pushl  -0x10(%ebp)
80101e57:	e8 de 1b 00 00       	call   80103a3a <log_write>
80101e5c:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e5f:	83 ec 0c             	sub    $0xc,%esp
80101e62:	ff 75 f0             	pushl  -0x10(%ebp)
80101e65:	e8 c4 e3 ff ff       	call   8010022e <brelse>
80101e6a:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e70:	eb 0d                	jmp    80101e7f <bmap+0x11a>
  }

  panic("bmap: out of range");
80101e72:	83 ec 0c             	sub    $0xc,%esp
80101e75:	68 ec a6 10 80       	push   $0x8010a6ec
80101e7a:	e8 e7 e6 ff ff       	call   80100566 <panic>
}
80101e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e82:	c9                   	leave  
80101e83:	c3                   	ret    

80101e84 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e84:	55                   	push   %ebp
80101e85:	89 e5                	mov    %esp,%ebp
80101e87:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e91:	eb 45                	jmp    80101ed8 <itrunc+0x54>
    if(ip->addrs[i]){
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e99:	83 c2 08             	add    $0x8,%edx
80101e9c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101ea0:	85 c0                	test   %eax,%eax
80101ea2:	74 30                	je     80101ed4 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eaa:	83 c2 08             	add    $0x8,%edx
80101ead:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101eb1:	8b 55 08             	mov    0x8(%ebp),%edx
80101eb4:	8b 12                	mov    (%edx),%edx
80101eb6:	83 ec 08             	sub    $0x8,%esp
80101eb9:	50                   	push   %eax
80101eba:	52                   	push   %edx
80101ebb:	e8 50 f7 ff ff       	call   80101610 <bfree>
80101ec0:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ec9:	83 c2 08             	add    $0x8,%edx
80101ecc:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
80101ed3:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ed4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ed8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80101edc:	7e b5                	jle    80101e93 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ee4:	85 c0                	test   %eax,%eax
80101ee6:	0f 84 a1 00 00 00    	je     80101f8d <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101eec:	8b 45 08             	mov    0x8(%ebp),%eax
80101eef:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef5:	8b 00                	mov    (%eax),%eax
80101ef7:	83 ec 08             	sub    $0x8,%esp
80101efa:	52                   	push   %edx
80101efb:	50                   	push   %eax
80101efc:	e8 b5 e2 ff ff       	call   801001b6 <bread>
80101f01:	83 c4 10             	add    $0x10,%esp
80101f04:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f0a:	83 c0 18             	add    $0x18,%eax
80101f0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f10:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f17:	eb 3c                	jmp    80101f55 <itrunc+0xd1>
      if(a[j])
80101f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f26:	01 d0                	add    %edx,%eax
80101f28:	8b 00                	mov    (%eax),%eax
80101f2a:	85 c0                	test   %eax,%eax
80101f2c:	74 23                	je     80101f51 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f38:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f3b:	01 d0                	add    %edx,%eax
80101f3d:	8b 00                	mov    (%eax),%eax
80101f3f:	8b 55 08             	mov    0x8(%ebp),%edx
80101f42:	8b 12                	mov    (%edx),%edx
80101f44:	83 ec 08             	sub    $0x8,%esp
80101f47:	50                   	push   %eax
80101f48:	52                   	push   %edx
80101f49:	e8 c2 f6 ff ff       	call   80101610 <bfree>
80101f4e:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101f51:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f58:	83 f8 7f             	cmp    $0x7f,%eax
80101f5b:	76 bc                	jbe    80101f19 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101f5d:	83 ec 0c             	sub    $0xc,%esp
80101f60:	ff 75 ec             	pushl  -0x14(%ebp)
80101f63:	e8 c6 e2 ff ff       	call   8010022e <brelse>
80101f68:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f71:	8b 55 08             	mov    0x8(%ebp),%edx
80101f74:	8b 12                	mov    (%edx),%edx
80101f76:	83 ec 08             	sub    $0x8,%esp
80101f79:	50                   	push   %eax
80101f7a:	52                   	push   %edx
80101f7b:	e8 90 f6 ff ff       	call   80101610 <bfree>
80101f80:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  iupdate(ip);
80101f97:	83 ec 0c             	sub    $0xc,%esp
80101f9a:	ff 75 08             	pushl  0x8(%ebp)
80101f9d:	e8 b4 f8 ff ff       	call   80101856 <iupdate>
80101fa2:	83 c4 10             	add    $0x10,%esp
}
80101fa5:	90                   	nop
80101fa6:	c9                   	leave  
80101fa7:	c3                   	ret    

80101fa8 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101fa8:	55                   	push   %ebp
80101fa9:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	8b 00                	mov    (%eax),%eax
80101fb0:	89 c2                	mov    %eax,%edx
80101fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbb:	8b 50 04             	mov    0x4(%eax),%edx
80101fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fc1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fce:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fdb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe2:	8b 50 20             	mov    0x20(%eax),%edx
80101fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fe8:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  st->uid = ip->uid;
80101feb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fee:	0f b7 50 18          	movzwl 0x18(%eax),%edx
80101ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff5:	66 89 50 14          	mov    %dx,0x14(%eax)
  st->gid = ip->gid;
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
80102000:	8b 45 0c             	mov    0xc(%ebp),%eax
80102003:	66 89 50 16          	mov    %dx,0x16(%eax)
  st->mode.asInt = ip->mode.asInt;
80102007:	8b 45 08             	mov    0x8(%ebp),%eax
8010200a:	8b 50 1c             	mov    0x1c(%eax),%edx
8010200d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102010:	89 50 18             	mov    %edx,0x18(%eax)
#endif
}
80102013:	90                   	nop
80102014:	5d                   	pop    %ebp
80102015:	c3                   	ret    

80102016 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102016:	55                   	push   %ebp
80102017:	89 e5                	mov    %esp,%ebp
80102019:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010201c:	8b 45 08             	mov    0x8(%ebp),%eax
8010201f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102023:	66 83 f8 03          	cmp    $0x3,%ax
80102027:	75 5c                	jne    80102085 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102029:	8b 45 08             	mov    0x8(%ebp),%eax
8010202c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102030:	66 85 c0             	test   %ax,%ax
80102033:	78 20                	js     80102055 <readi+0x3f>
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010203c:	66 83 f8 09          	cmp    $0x9,%ax
80102040:	7f 13                	jg     80102055 <readi+0x3f>
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102049:	98                   	cwtl   
8010204a:	8b 04 c5 e0 31 11 80 	mov    -0x7feece20(,%eax,8),%eax
80102051:	85 c0                	test   %eax,%eax
80102053:	75 0a                	jne    8010205f <readi+0x49>
      return -1;
80102055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010205a:	e9 0c 01 00 00       	jmp    8010216b <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102066:	98                   	cwtl   
80102067:	8b 04 c5 e0 31 11 80 	mov    -0x7feece20(,%eax,8),%eax
8010206e:	8b 55 14             	mov    0x14(%ebp),%edx
80102071:	83 ec 04             	sub    $0x4,%esp
80102074:	52                   	push   %edx
80102075:	ff 75 0c             	pushl  0xc(%ebp)
80102078:	ff 75 08             	pushl  0x8(%ebp)
8010207b:	ff d0                	call   *%eax
8010207d:	83 c4 10             	add    $0x10,%esp
80102080:	e9 e6 00 00 00       	jmp    8010216b <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102085:	8b 45 08             	mov    0x8(%ebp),%eax
80102088:	8b 40 20             	mov    0x20(%eax),%eax
8010208b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010208e:	72 0d                	jb     8010209d <readi+0x87>
80102090:	8b 55 10             	mov    0x10(%ebp),%edx
80102093:	8b 45 14             	mov    0x14(%ebp),%eax
80102096:	01 d0                	add    %edx,%eax
80102098:	3b 45 10             	cmp    0x10(%ebp),%eax
8010209b:	73 0a                	jae    801020a7 <readi+0x91>
    return -1;
8010209d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a2:	e9 c4 00 00 00       	jmp    8010216b <readi+0x155>
  if(off + n > ip->size)
801020a7:	8b 55 10             	mov    0x10(%ebp),%edx
801020aa:	8b 45 14             	mov    0x14(%ebp),%eax
801020ad:	01 c2                	add    %eax,%edx
801020af:	8b 45 08             	mov    0x8(%ebp),%eax
801020b2:	8b 40 20             	mov    0x20(%eax),%eax
801020b5:	39 c2                	cmp    %eax,%edx
801020b7:	76 0c                	jbe    801020c5 <readi+0xaf>
    n = ip->size - off;
801020b9:	8b 45 08             	mov    0x8(%ebp),%eax
801020bc:	8b 40 20             	mov    0x20(%eax),%eax
801020bf:	2b 45 10             	sub    0x10(%ebp),%eax
801020c2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020cc:	e9 8b 00 00 00       	jmp    8010215c <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020d1:	8b 45 10             	mov    0x10(%ebp),%eax
801020d4:	c1 e8 09             	shr    $0x9,%eax
801020d7:	83 ec 08             	sub    $0x8,%esp
801020da:	50                   	push   %eax
801020db:	ff 75 08             	pushl  0x8(%ebp)
801020de:	e8 82 fc ff ff       	call   80101d65 <bmap>
801020e3:	83 c4 10             	add    $0x10,%esp
801020e6:	89 c2                	mov    %eax,%edx
801020e8:	8b 45 08             	mov    0x8(%ebp),%eax
801020eb:	8b 00                	mov    (%eax),%eax
801020ed:	83 ec 08             	sub    $0x8,%esp
801020f0:	52                   	push   %edx
801020f1:	50                   	push   %eax
801020f2:	e8 bf e0 ff ff       	call   801001b6 <bread>
801020f7:	83 c4 10             	add    $0x10,%esp
801020fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102100:	25 ff 01 00 00       	and    $0x1ff,%eax
80102105:	ba 00 02 00 00       	mov    $0x200,%edx
8010210a:	29 c2                	sub    %eax,%edx
8010210c:	8b 45 14             	mov    0x14(%ebp),%eax
8010210f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102112:	39 c2                	cmp    %eax,%edx
80102114:	0f 46 c2             	cmovbe %edx,%eax
80102117:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010211a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211d:	8d 50 18             	lea    0x18(%eax),%edx
80102120:	8b 45 10             	mov    0x10(%ebp),%eax
80102123:	25 ff 01 00 00       	and    $0x1ff,%eax
80102128:	01 d0                	add    %edx,%eax
8010212a:	83 ec 04             	sub    $0x4,%esp
8010212d:	ff 75 ec             	pushl  -0x14(%ebp)
80102130:	50                   	push   %eax
80102131:	ff 75 0c             	pushl  0xc(%ebp)
80102134:	e8 8b 4e 00 00       	call   80106fc4 <memmove>
80102139:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010213c:	83 ec 0c             	sub    $0xc,%esp
8010213f:	ff 75 f0             	pushl  -0x10(%ebp)
80102142:	e8 e7 e0 ff ff       	call   8010022e <brelse>
80102147:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010214a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010214d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102150:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102153:	01 45 10             	add    %eax,0x10(%ebp)
80102156:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102159:	01 45 0c             	add    %eax,0xc(%ebp)
8010215c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010215f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102162:	0f 82 69 ff ff ff    	jb     801020d1 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102168:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010216b:	c9                   	leave  
8010216c:	c3                   	ret    

8010216d <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010216d:	55                   	push   %ebp
8010216e:	89 e5                	mov    %esp,%ebp
80102170:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102173:	8b 45 08             	mov    0x8(%ebp),%eax
80102176:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010217a:	66 83 f8 03          	cmp    $0x3,%ax
8010217e:	75 5c                	jne    801021dc <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102187:	66 85 c0             	test   %ax,%ax
8010218a:	78 20                	js     801021ac <writei+0x3f>
8010218c:	8b 45 08             	mov    0x8(%ebp),%eax
8010218f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102193:	66 83 f8 09          	cmp    $0x9,%ax
80102197:	7f 13                	jg     801021ac <writei+0x3f>
80102199:	8b 45 08             	mov    0x8(%ebp),%eax
8010219c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021a0:	98                   	cwtl   
801021a1:	8b 04 c5 e4 31 11 80 	mov    -0x7feece1c(,%eax,8),%eax
801021a8:	85 c0                	test   %eax,%eax
801021aa:	75 0a                	jne    801021b6 <writei+0x49>
      return -1;
801021ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021b1:	e9 3d 01 00 00       	jmp    801022f3 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
801021b6:	8b 45 08             	mov    0x8(%ebp),%eax
801021b9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021bd:	98                   	cwtl   
801021be:	8b 04 c5 e4 31 11 80 	mov    -0x7feece1c(,%eax,8),%eax
801021c5:	8b 55 14             	mov    0x14(%ebp),%edx
801021c8:	83 ec 04             	sub    $0x4,%esp
801021cb:	52                   	push   %edx
801021cc:	ff 75 0c             	pushl  0xc(%ebp)
801021cf:	ff 75 08             	pushl  0x8(%ebp)
801021d2:	ff d0                	call   *%eax
801021d4:	83 c4 10             	add    $0x10,%esp
801021d7:	e9 17 01 00 00       	jmp    801022f3 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801021dc:	8b 45 08             	mov    0x8(%ebp),%eax
801021df:	8b 40 20             	mov    0x20(%eax),%eax
801021e2:	3b 45 10             	cmp    0x10(%ebp),%eax
801021e5:	72 0d                	jb     801021f4 <writei+0x87>
801021e7:	8b 55 10             	mov    0x10(%ebp),%edx
801021ea:	8b 45 14             	mov    0x14(%ebp),%eax
801021ed:	01 d0                	add    %edx,%eax
801021ef:	3b 45 10             	cmp    0x10(%ebp),%eax
801021f2:	73 0a                	jae    801021fe <writei+0x91>
    return -1;
801021f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021f9:	e9 f5 00 00 00       	jmp    801022f3 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801021fe:	8b 55 10             	mov    0x10(%ebp),%edx
80102201:	8b 45 14             	mov    0x14(%ebp),%eax
80102204:	01 d0                	add    %edx,%eax
80102206:	3d 00 14 01 00       	cmp    $0x11400,%eax
8010220b:	76 0a                	jbe    80102217 <writei+0xaa>
    return -1;
8010220d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102212:	e9 dc 00 00 00       	jmp    801022f3 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102217:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010221e:	e9 99 00 00 00       	jmp    801022bc <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102223:	8b 45 10             	mov    0x10(%ebp),%eax
80102226:	c1 e8 09             	shr    $0x9,%eax
80102229:	83 ec 08             	sub    $0x8,%esp
8010222c:	50                   	push   %eax
8010222d:	ff 75 08             	pushl  0x8(%ebp)
80102230:	e8 30 fb ff ff       	call   80101d65 <bmap>
80102235:	83 c4 10             	add    $0x10,%esp
80102238:	89 c2                	mov    %eax,%edx
8010223a:	8b 45 08             	mov    0x8(%ebp),%eax
8010223d:	8b 00                	mov    (%eax),%eax
8010223f:	83 ec 08             	sub    $0x8,%esp
80102242:	52                   	push   %edx
80102243:	50                   	push   %eax
80102244:	e8 6d df ff ff       	call   801001b6 <bread>
80102249:	83 c4 10             	add    $0x10,%esp
8010224c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010224f:	8b 45 10             	mov    0x10(%ebp),%eax
80102252:	25 ff 01 00 00       	and    $0x1ff,%eax
80102257:	ba 00 02 00 00       	mov    $0x200,%edx
8010225c:	29 c2                	sub    %eax,%edx
8010225e:	8b 45 14             	mov    0x14(%ebp),%eax
80102261:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102264:	39 c2                	cmp    %eax,%edx
80102266:	0f 46 c2             	cmovbe %edx,%eax
80102269:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010226c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010226f:	8d 50 18             	lea    0x18(%eax),%edx
80102272:	8b 45 10             	mov    0x10(%ebp),%eax
80102275:	25 ff 01 00 00       	and    $0x1ff,%eax
8010227a:	01 d0                	add    %edx,%eax
8010227c:	83 ec 04             	sub    $0x4,%esp
8010227f:	ff 75 ec             	pushl  -0x14(%ebp)
80102282:	ff 75 0c             	pushl  0xc(%ebp)
80102285:	50                   	push   %eax
80102286:	e8 39 4d 00 00       	call   80106fc4 <memmove>
8010228b:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010228e:	83 ec 0c             	sub    $0xc,%esp
80102291:	ff 75 f0             	pushl  -0x10(%ebp)
80102294:	e8 a1 17 00 00       	call   80103a3a <log_write>
80102299:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010229c:	83 ec 0c             	sub    $0xc,%esp
8010229f:	ff 75 f0             	pushl  -0x10(%ebp)
801022a2:	e8 87 df ff ff       	call   8010022e <brelse>
801022a7:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022ad:	01 45 f4             	add    %eax,-0xc(%ebp)
801022b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b3:	01 45 10             	add    %eax,0x10(%ebp)
801022b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b9:	01 45 0c             	add    %eax,0xc(%ebp)
801022bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bf:	3b 45 14             	cmp    0x14(%ebp),%eax
801022c2:	0f 82 5b ff ff ff    	jb     80102223 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801022c8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022cc:	74 22                	je     801022f0 <writei+0x183>
801022ce:	8b 45 08             	mov    0x8(%ebp),%eax
801022d1:	8b 40 20             	mov    0x20(%eax),%eax
801022d4:	3b 45 10             	cmp    0x10(%ebp),%eax
801022d7:	73 17                	jae    801022f0 <writei+0x183>
    ip->size = off;
801022d9:	8b 45 08             	mov    0x8(%ebp),%eax
801022dc:	8b 55 10             	mov    0x10(%ebp),%edx
801022df:	89 50 20             	mov    %edx,0x20(%eax)
    iupdate(ip);
801022e2:	83 ec 0c             	sub    $0xc,%esp
801022e5:	ff 75 08             	pushl  0x8(%ebp)
801022e8:	e8 69 f5 ff ff       	call   80101856 <iupdate>
801022ed:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022f0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022f3:	c9                   	leave  
801022f4:	c3                   	ret    

801022f5 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022f5:	55                   	push   %ebp
801022f6:	89 e5                	mov    %esp,%ebp
801022f8:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022fb:	83 ec 04             	sub    $0x4,%esp
801022fe:	6a 0e                	push   $0xe
80102300:	ff 75 0c             	pushl  0xc(%ebp)
80102303:	ff 75 08             	pushl  0x8(%ebp)
80102306:	e8 4f 4d 00 00       	call   8010705a <strncmp>
8010230b:	83 c4 10             	add    $0x10,%esp
}
8010230e:	c9                   	leave  
8010230f:	c3                   	ret    

80102310 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102310:	55                   	push   %ebp
80102311:	89 e5                	mov    %esp,%ebp
80102313:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102316:	8b 45 08             	mov    0x8(%ebp),%eax
80102319:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010231d:	66 83 f8 01          	cmp    $0x1,%ax
80102321:	74 0d                	je     80102330 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102323:	83 ec 0c             	sub    $0xc,%esp
80102326:	68 ff a6 10 80       	push   $0x8010a6ff
8010232b:	e8 36 e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102330:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102337:	eb 7b                	jmp    801023b4 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102339:	6a 10                	push   $0x10
8010233b:	ff 75 f4             	pushl  -0xc(%ebp)
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	pushl  0x8(%ebp)
80102345:	e8 cc fc ff ff       	call   80102016 <readi>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlookup+0x4f>
      panic("dirlink read");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 11 a7 10 80       	push   $0x8010a711
8010235a:	e8 07 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010235f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102363:	66 85 c0             	test   %ax,%ax
80102366:	74 47                	je     801023af <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102368:	83 ec 08             	sub    $0x8,%esp
8010236b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010236e:	83 c0 02             	add    $0x2,%eax
80102371:	50                   	push   %eax
80102372:	ff 75 0c             	pushl  0xc(%ebp)
80102375:	e8 7b ff ff ff       	call   801022f5 <namecmp>
8010237a:	83 c4 10             	add    $0x10,%esp
8010237d:	85 c0                	test   %eax,%eax
8010237f:	75 2f                	jne    801023b0 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102381:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102385:	74 08                	je     8010238f <dirlookup+0x7f>
        *poff = off;
80102387:	8b 45 10             	mov    0x10(%ebp),%eax
8010238a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010238d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010238f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102393:	0f b7 c0             	movzwl %ax,%eax
80102396:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	8b 00                	mov    (%eax),%eax
8010239e:	83 ec 08             	sub    $0x8,%esp
801023a1:	ff 75 f0             	pushl  -0x10(%ebp)
801023a4:	50                   	push   %eax
801023a5:	e8 95 f5 ff ff       	call   8010193f <iget>
801023aa:	83 c4 10             	add    $0x10,%esp
801023ad:	eb 19                	jmp    801023c8 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
801023af:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801023b0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023b4:	8b 45 08             	mov    0x8(%ebp),%eax
801023b7:	8b 40 20             	mov    0x20(%eax),%eax
801023ba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801023bd:	0f 87 76 ff ff ff    	ja     80102339 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801023c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023c8:	c9                   	leave  
801023c9:	c3                   	ret    

801023ca <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023ca:	55                   	push   %ebp
801023cb:	89 e5                	mov    %esp,%ebp
801023cd:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023d0:	83 ec 04             	sub    $0x4,%esp
801023d3:	6a 00                	push   $0x0
801023d5:	ff 75 0c             	pushl  0xc(%ebp)
801023d8:	ff 75 08             	pushl  0x8(%ebp)
801023db:	e8 30 ff ff ff       	call   80102310 <dirlookup>
801023e0:	83 c4 10             	add    $0x10,%esp
801023e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023ea:	74 18                	je     80102404 <dirlink+0x3a>
    iput(ip);
801023ec:	83 ec 0c             	sub    $0xc,%esp
801023ef:	ff 75 f0             	pushl  -0x10(%ebp)
801023f2:	e8 59 f8 ff ff       	call   80101c50 <iput>
801023f7:	83 c4 10             	add    $0x10,%esp
    return -1;
801023fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ff:	e9 9c 00 00 00       	jmp    801024a0 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010240b:	eb 39                	jmp    80102446 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010240d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102410:	6a 10                	push   $0x10
80102412:	50                   	push   %eax
80102413:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102416:	50                   	push   %eax
80102417:	ff 75 08             	pushl  0x8(%ebp)
8010241a:	e8 f7 fb ff ff       	call   80102016 <readi>
8010241f:	83 c4 10             	add    $0x10,%esp
80102422:	83 f8 10             	cmp    $0x10,%eax
80102425:	74 0d                	je     80102434 <dirlink+0x6a>
      panic("dirlink read");
80102427:	83 ec 0c             	sub    $0xc,%esp
8010242a:	68 11 a7 10 80       	push   $0x8010a711
8010242f:	e8 32 e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102434:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102438:	66 85 c0             	test   %ax,%ax
8010243b:	74 18                	je     80102455 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010243d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102440:	83 c0 10             	add    $0x10,%eax
80102443:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102446:	8b 45 08             	mov    0x8(%ebp),%eax
80102449:	8b 50 20             	mov    0x20(%eax),%edx
8010244c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244f:	39 c2                	cmp    %eax,%edx
80102451:	77 ba                	ja     8010240d <dirlink+0x43>
80102453:	eb 01                	jmp    80102456 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102455:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102456:	83 ec 04             	sub    $0x4,%esp
80102459:	6a 0e                	push   $0xe
8010245b:	ff 75 0c             	pushl  0xc(%ebp)
8010245e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102461:	83 c0 02             	add    $0x2,%eax
80102464:	50                   	push   %eax
80102465:	e8 46 4c 00 00       	call   801070b0 <strncpy>
8010246a:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010246d:	8b 45 10             	mov    0x10(%ebp),%eax
80102470:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102477:	6a 10                	push   $0x10
80102479:	50                   	push   %eax
8010247a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010247d:	50                   	push   %eax
8010247e:	ff 75 08             	pushl  0x8(%ebp)
80102481:	e8 e7 fc ff ff       	call   8010216d <writei>
80102486:	83 c4 10             	add    $0x10,%esp
80102489:	83 f8 10             	cmp    $0x10,%eax
8010248c:	74 0d                	je     8010249b <dirlink+0xd1>
    panic("dirlink");
8010248e:	83 ec 0c             	sub    $0xc,%esp
80102491:	68 1e a7 10 80       	push   $0x8010a71e
80102496:	e8 cb e0 ff ff       	call   80100566 <panic>
  
  return 0;
8010249b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024a0:	c9                   	leave  
801024a1:	c3                   	ret    

801024a2 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024a2:	55                   	push   %ebp
801024a3:	89 e5                	mov    %esp,%ebp
801024a5:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024a8:	eb 04                	jmp    801024ae <skipelem+0xc>
    path++;
801024aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801024ae:	8b 45 08             	mov    0x8(%ebp),%eax
801024b1:	0f b6 00             	movzbl (%eax),%eax
801024b4:	3c 2f                	cmp    $0x2f,%al
801024b6:	74 f2                	je     801024aa <skipelem+0x8>
    path++;
  if(*path == 0)
801024b8:	8b 45 08             	mov    0x8(%ebp),%eax
801024bb:	0f b6 00             	movzbl (%eax),%eax
801024be:	84 c0                	test   %al,%al
801024c0:	75 07                	jne    801024c9 <skipelem+0x27>
    return 0;
801024c2:	b8 00 00 00 00       	mov    $0x0,%eax
801024c7:	eb 7b                	jmp    80102544 <skipelem+0xa2>
  s = path;
801024c9:	8b 45 08             	mov    0x8(%ebp),%eax
801024cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024cf:	eb 04                	jmp    801024d5 <skipelem+0x33>
    path++;
801024d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801024d5:	8b 45 08             	mov    0x8(%ebp),%eax
801024d8:	0f b6 00             	movzbl (%eax),%eax
801024db:	3c 2f                	cmp    $0x2f,%al
801024dd:	74 0a                	je     801024e9 <skipelem+0x47>
801024df:	8b 45 08             	mov    0x8(%ebp),%eax
801024e2:	0f b6 00             	movzbl (%eax),%eax
801024e5:	84 c0                	test   %al,%al
801024e7:	75 e8                	jne    801024d1 <skipelem+0x2f>
    path++;
  len = path - s;
801024e9:	8b 55 08             	mov    0x8(%ebp),%edx
801024ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ef:	29 c2                	sub    %eax,%edx
801024f1:	89 d0                	mov    %edx,%eax
801024f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024f6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024fa:	7e 15                	jle    80102511 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024fc:	83 ec 04             	sub    $0x4,%esp
801024ff:	6a 0e                	push   $0xe
80102501:	ff 75 f4             	pushl  -0xc(%ebp)
80102504:	ff 75 0c             	pushl  0xc(%ebp)
80102507:	e8 b8 4a 00 00       	call   80106fc4 <memmove>
8010250c:	83 c4 10             	add    $0x10,%esp
8010250f:	eb 26                	jmp    80102537 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102514:	83 ec 04             	sub    $0x4,%esp
80102517:	50                   	push   %eax
80102518:	ff 75 f4             	pushl  -0xc(%ebp)
8010251b:	ff 75 0c             	pushl  0xc(%ebp)
8010251e:	e8 a1 4a 00 00       	call   80106fc4 <memmove>
80102523:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102526:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102529:	8b 45 0c             	mov    0xc(%ebp),%eax
8010252c:	01 d0                	add    %edx,%eax
8010252e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102531:	eb 04                	jmp    80102537 <skipelem+0x95>
    path++;
80102533:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102537:	8b 45 08             	mov    0x8(%ebp),%eax
8010253a:	0f b6 00             	movzbl (%eax),%eax
8010253d:	3c 2f                	cmp    $0x2f,%al
8010253f:	74 f2                	je     80102533 <skipelem+0x91>
    path++;
  return path;
80102541:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102544:	c9                   	leave  
80102545:	c3                   	ret    

80102546 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102546:	55                   	push   %ebp
80102547:	89 e5                	mov    %esp,%ebp
80102549:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010254c:	8b 45 08             	mov    0x8(%ebp),%eax
8010254f:	0f b6 00             	movzbl (%eax),%eax
80102552:	3c 2f                	cmp    $0x2f,%al
80102554:	75 17                	jne    8010256d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102556:	83 ec 08             	sub    $0x8,%esp
80102559:	6a 01                	push   $0x1
8010255b:	6a 01                	push   $0x1
8010255d:	e8 dd f3 ff ff       	call   8010193f <iget>
80102562:	83 c4 10             	add    $0x10,%esp
80102565:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102568:	e9 bb 00 00 00       	jmp    80102628 <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010256d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102573:	8b 40 68             	mov    0x68(%eax),%eax
80102576:	83 ec 0c             	sub    $0xc,%esp
80102579:	50                   	push   %eax
8010257a:	e8 9f f4 ff ff       	call   80101a1e <idup>
8010257f:	83 c4 10             	add    $0x10,%esp
80102582:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102585:	e9 9e 00 00 00       	jmp    80102628 <namex+0xe2>
    ilock(ip);
8010258a:	83 ec 0c             	sub    $0xc,%esp
8010258d:	ff 75 f4             	pushl  -0xc(%ebp)
80102590:	e8 c3 f4 ff ff       	call   80101a58 <ilock>
80102595:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010259b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010259f:	66 83 f8 01          	cmp    $0x1,%ax
801025a3:	74 18                	je     801025bd <namex+0x77>
      iunlockput(ip);
801025a5:	83 ec 0c             	sub    $0xc,%esp
801025a8:	ff 75 f4             	pushl  -0xc(%ebp)
801025ab:	e8 90 f7 ff ff       	call   80101d40 <iunlockput>
801025b0:	83 c4 10             	add    $0x10,%esp
      return 0;
801025b3:	b8 00 00 00 00       	mov    $0x0,%eax
801025b8:	e9 a7 00 00 00       	jmp    80102664 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
801025bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025c1:	74 20                	je     801025e3 <namex+0x9d>
801025c3:	8b 45 08             	mov    0x8(%ebp),%eax
801025c6:	0f b6 00             	movzbl (%eax),%eax
801025c9:	84 c0                	test   %al,%al
801025cb:	75 16                	jne    801025e3 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801025cd:	83 ec 0c             	sub    $0xc,%esp
801025d0:	ff 75 f4             	pushl  -0xc(%ebp)
801025d3:	e8 06 f6 ff ff       	call   80101bde <iunlock>
801025d8:	83 c4 10             	add    $0x10,%esp
      return ip;
801025db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025de:	e9 81 00 00 00       	jmp    80102664 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025e3:	83 ec 04             	sub    $0x4,%esp
801025e6:	6a 00                	push   $0x0
801025e8:	ff 75 10             	pushl  0x10(%ebp)
801025eb:	ff 75 f4             	pushl  -0xc(%ebp)
801025ee:	e8 1d fd ff ff       	call   80102310 <dirlookup>
801025f3:	83 c4 10             	add    $0x10,%esp
801025f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025fd:	75 15                	jne    80102614 <namex+0xce>
      iunlockput(ip);
801025ff:	83 ec 0c             	sub    $0xc,%esp
80102602:	ff 75 f4             	pushl  -0xc(%ebp)
80102605:	e8 36 f7 ff ff       	call   80101d40 <iunlockput>
8010260a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010260d:	b8 00 00 00 00       	mov    $0x0,%eax
80102612:	eb 50                	jmp    80102664 <namex+0x11e>
    }
    iunlockput(ip);
80102614:	83 ec 0c             	sub    $0xc,%esp
80102617:	ff 75 f4             	pushl  -0xc(%ebp)
8010261a:	e8 21 f7 ff ff       	call   80101d40 <iunlockput>
8010261f:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102625:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102628:	83 ec 08             	sub    $0x8,%esp
8010262b:	ff 75 10             	pushl  0x10(%ebp)
8010262e:	ff 75 08             	pushl  0x8(%ebp)
80102631:	e8 6c fe ff ff       	call   801024a2 <skipelem>
80102636:	83 c4 10             	add    $0x10,%esp
80102639:	89 45 08             	mov    %eax,0x8(%ebp)
8010263c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102640:	0f 85 44 ff ff ff    	jne    8010258a <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102646:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010264a:	74 15                	je     80102661 <namex+0x11b>
    iput(ip);
8010264c:	83 ec 0c             	sub    $0xc,%esp
8010264f:	ff 75 f4             	pushl  -0xc(%ebp)
80102652:	e8 f9 f5 ff ff       	call   80101c50 <iput>
80102657:	83 c4 10             	add    $0x10,%esp
    return 0;
8010265a:	b8 00 00 00 00       	mov    $0x0,%eax
8010265f:	eb 03                	jmp    80102664 <namex+0x11e>
  }
  return ip;
80102661:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102664:	c9                   	leave  
80102665:	c3                   	ret    

80102666 <namei>:

struct inode*
namei(char *path)
{
80102666:	55                   	push   %ebp
80102667:	89 e5                	mov    %esp,%ebp
80102669:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010266c:	83 ec 04             	sub    $0x4,%esp
8010266f:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102672:	50                   	push   %eax
80102673:	6a 00                	push   $0x0
80102675:	ff 75 08             	pushl  0x8(%ebp)
80102678:	e8 c9 fe ff ff       	call   80102546 <namex>
8010267d:	83 c4 10             	add    $0x10,%esp
}
80102680:	c9                   	leave  
80102681:	c3                   	ret    

80102682 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102682:	55                   	push   %ebp
80102683:	89 e5                	mov    %esp,%ebp
80102685:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102688:	83 ec 04             	sub    $0x4,%esp
8010268b:	ff 75 0c             	pushl  0xc(%ebp)
8010268e:	6a 01                	push   $0x1
80102690:	ff 75 08             	pushl  0x8(%ebp)
80102693:	e8 ae fe ff ff       	call   80102546 <namex>
80102698:	83 c4 10             	add    $0x10,%esp
}
8010269b:	c9                   	leave  
8010269c:	c3                   	ret    

8010269d <chmod>:
#ifdef CS333_P5
int
chmod(char * pathname, int mode){
8010269d:	55                   	push   %ebp
8010269e:	89 e5                	mov    %esp,%ebp
801026a0:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;

    begin_op();
801026a3:	e8 5a 11 00 00       	call   80103802 <begin_op>
    ip = namei(pathname);
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	ff 75 08             	pushl  0x8(%ebp)
801026ae:	e8 b3 ff ff ff       	call   80102666 <namei>
801026b3:	83 c4 10             	add    $0x10,%esp
801026b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip){
801026b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026bd:	74 4d                	je     8010270c <chmod+0x6f>
	ilock(ip);
801026bf:	83 ec 0c             	sub    $0xc,%esp
801026c2:	ff 75 f4             	pushl  -0xc(%ebp)
801026c5:	e8 8e f3 ff ff       	call   80101a58 <ilock>
801026ca:	83 c4 10             	add    $0x10,%esp
	ip->mode.asInt = mode;
801026cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801026d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d3:	89 50 1c             	mov    %edx,0x1c(%eax)
	iupdate(ip);
801026d6:	83 ec 0c             	sub    $0xc,%esp
801026d9:	ff 75 f4             	pushl  -0xc(%ebp)
801026dc:	e8 75 f1 ff ff       	call   80101856 <iupdate>
801026e1:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
801026e4:	83 ec 0c             	sub    $0xc,%esp
801026e7:	ff 75 f4             	pushl  -0xc(%ebp)
801026ea:	e8 ef f4 ff ff       	call   80101bde <iunlock>
801026ef:	83 c4 10             	add    $0x10,%esp
	iput(ip);
801026f2:	83 ec 0c             	sub    $0xc,%esp
801026f5:	ff 75 f4             	pushl  -0xc(%ebp)
801026f8:	e8 53 f5 ff ff       	call   80101c50 <iput>
801026fd:	83 c4 10             	add    $0x10,%esp
	end_op();
80102700:	e8 89 11 00 00       	call   8010388e <end_op>
	end_op();
	return -1;
    }


    return 0;
80102705:	b8 00 00 00 00       	mov    $0x0,%eax
8010270a:	eb 0a                	jmp    80102716 <chmod+0x79>
	iunlock(ip);
	iput(ip);
	end_op();
    }
    else{
	end_op();
8010270c:	e8 7d 11 00 00       	call   8010388e <end_op>
	return -1;
80102711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }


    return 0;
}
80102716:	c9                   	leave  
80102717:	c3                   	ret    

80102718 <chown>:

int 
chown(char * pathname, int owner){
80102718:	55                   	push   %ebp
80102719:	89 e5                	mov    %esp,%ebp
8010271b:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;

    begin_op();
8010271e:	e8 df 10 00 00       	call   80103802 <begin_op>
    ip = namei(pathname);
80102723:	83 ec 0c             	sub    $0xc,%esp
80102726:	ff 75 08             	pushl  0x8(%ebp)
80102729:	e8 38 ff ff ff       	call   80102666 <namei>
8010272e:	83 c4 10             	add    $0x10,%esp
80102731:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip){
80102734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102738:	74 50                	je     8010278a <chown+0x72>
	ilock(ip);
8010273a:	83 ec 0c             	sub    $0xc,%esp
8010273d:	ff 75 f4             	pushl  -0xc(%ebp)
80102740:	e8 13 f3 ff ff       	call   80101a58 <ilock>
80102745:	83 c4 10             	add    $0x10,%esp
	ip-> uid = owner;
80102748:	8b 45 0c             	mov    0xc(%ebp),%eax
8010274b:	89 c2                	mov    %eax,%edx
8010274d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102750:	66 89 50 18          	mov    %dx,0x18(%eax)
	iupdate(ip);
80102754:	83 ec 0c             	sub    $0xc,%esp
80102757:	ff 75 f4             	pushl  -0xc(%ebp)
8010275a:	e8 f7 f0 ff ff       	call   80101856 <iupdate>
8010275f:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
80102762:	83 ec 0c             	sub    $0xc,%esp
80102765:	ff 75 f4             	pushl  -0xc(%ebp)
80102768:	e8 71 f4 ff ff       	call   80101bde <iunlock>
8010276d:	83 c4 10             	add    $0x10,%esp
	iput(ip);
80102770:	83 ec 0c             	sub    $0xc,%esp
80102773:	ff 75 f4             	pushl  -0xc(%ebp)
80102776:	e8 d5 f4 ff ff       	call   80101c50 <iput>
8010277b:	83 c4 10             	add    $0x10,%esp
	end_op();
8010277e:	e8 0b 11 00 00       	call   8010388e <end_op>
    else{
	end_op();
	return -1;
    }

    return 0;
80102783:	b8 00 00 00 00       	mov    $0x0,%eax
80102788:	eb 0a                	jmp    80102794 <chown+0x7c>
	iunlock(ip);
	iput(ip);
	end_op();
    }
    else{
	end_op();
8010278a:	e8 ff 10 00 00       	call   8010388e <end_op>
	return -1;
8010278f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    return 0;
}
80102794:	c9                   	leave  
80102795:	c3                   	ret    

80102796 <chgrp>:

int
chgrp(char * pathname, int group){
80102796:	55                   	push   %ebp
80102797:	89 e5                	mov    %esp,%ebp
80102799:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;

    begin_op();
8010279c:	e8 61 10 00 00       	call   80103802 <begin_op>
    ip = namei(pathname);
801027a1:	83 ec 0c             	sub    $0xc,%esp
801027a4:	ff 75 08             	pushl  0x8(%ebp)
801027a7:	e8 ba fe ff ff       	call   80102666 <namei>
801027ac:	83 c4 10             	add    $0x10,%esp
801027af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip){
801027b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b6:	74 50                	je     80102808 <chgrp+0x72>
	ilock(ip);
801027b8:	83 ec 0c             	sub    $0xc,%esp
801027bb:	ff 75 f4             	pushl  -0xc(%ebp)
801027be:	e8 95 f2 ff ff       	call   80101a58 <ilock>
801027c3:	83 c4 10             	add    $0x10,%esp
	ip-> gid = group;
801027c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801027c9:	89 c2                	mov    %eax,%edx
801027cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ce:	66 89 50 1a          	mov    %dx,0x1a(%eax)
	iupdate(ip);
801027d2:	83 ec 0c             	sub    $0xc,%esp
801027d5:	ff 75 f4             	pushl  -0xc(%ebp)
801027d8:	e8 79 f0 ff ff       	call   80101856 <iupdate>
801027dd:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	ff 75 f4             	pushl  -0xc(%ebp)
801027e6:	e8 f3 f3 ff ff       	call   80101bde <iunlock>
801027eb:	83 c4 10             	add    $0x10,%esp
	iput(ip);
801027ee:	83 ec 0c             	sub    $0xc,%esp
801027f1:	ff 75 f4             	pushl  -0xc(%ebp)
801027f4:	e8 57 f4 ff ff       	call   80101c50 <iput>
801027f9:	83 c4 10             	add    $0x10,%esp
	end_op();
801027fc:	e8 8d 10 00 00       	call   8010388e <end_op>
    else{
	end_op();
	return -1;
    }

    return 0;
80102801:	b8 00 00 00 00       	mov    $0x0,%eax
80102806:	eb 0a                	jmp    80102812 <chgrp+0x7c>
	iunlock(ip);
	iput(ip);
	end_op();
    }
    else{
	end_op();
80102808:	e8 81 10 00 00       	call   8010388e <end_op>
	return -1;
8010280d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    return 0;
}
80102812:	c9                   	leave  
80102813:	c3                   	ret    

80102814 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102814:	55                   	push   %ebp
80102815:	89 e5                	mov    %esp,%ebp
80102817:	83 ec 14             	sub    $0x14,%esp
8010281a:	8b 45 08             	mov    0x8(%ebp),%eax
8010281d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102821:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102825:	89 c2                	mov    %eax,%edx
80102827:	ec                   	in     (%dx),%al
80102828:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010282b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010282f:	c9                   	leave  
80102830:	c3                   	ret    

80102831 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102831:	55                   	push   %ebp
80102832:	89 e5                	mov    %esp,%ebp
80102834:	57                   	push   %edi
80102835:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102836:	8b 55 08             	mov    0x8(%ebp),%edx
80102839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010283c:	8b 45 10             	mov    0x10(%ebp),%eax
8010283f:	89 cb                	mov    %ecx,%ebx
80102841:	89 df                	mov    %ebx,%edi
80102843:	89 c1                	mov    %eax,%ecx
80102845:	fc                   	cld    
80102846:	f3 6d                	rep insl (%dx),%es:(%edi)
80102848:	89 c8                	mov    %ecx,%eax
8010284a:	89 fb                	mov    %edi,%ebx
8010284c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010284f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102852:	90                   	nop
80102853:	5b                   	pop    %ebx
80102854:	5f                   	pop    %edi
80102855:	5d                   	pop    %ebp
80102856:	c3                   	ret    

80102857 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102857:	55                   	push   %ebp
80102858:	89 e5                	mov    %esp,%ebp
8010285a:	83 ec 08             	sub    $0x8,%esp
8010285d:	8b 55 08             	mov    0x8(%ebp),%edx
80102860:	8b 45 0c             	mov    0xc(%ebp),%eax
80102863:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102867:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010286a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010286e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102872:	ee                   	out    %al,(%dx)
}
80102873:	90                   	nop
80102874:	c9                   	leave  
80102875:	c3                   	ret    

80102876 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102876:	55                   	push   %ebp
80102877:	89 e5                	mov    %esp,%ebp
80102879:	56                   	push   %esi
8010287a:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010287b:	8b 55 08             	mov    0x8(%ebp),%edx
8010287e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102881:	8b 45 10             	mov    0x10(%ebp),%eax
80102884:	89 cb                	mov    %ecx,%ebx
80102886:	89 de                	mov    %ebx,%esi
80102888:	89 c1                	mov    %eax,%ecx
8010288a:	fc                   	cld    
8010288b:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010288d:	89 c8                	mov    %ecx,%eax
8010288f:	89 f3                	mov    %esi,%ebx
80102891:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102894:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102897:	90                   	nop
80102898:	5b                   	pop    %ebx
80102899:	5e                   	pop    %esi
8010289a:	5d                   	pop    %ebp
8010289b:	c3                   	ret    

8010289c <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010289c:	55                   	push   %ebp
8010289d:	89 e5                	mov    %esp,%ebp
8010289f:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801028a2:	90                   	nop
801028a3:	68 f7 01 00 00       	push   $0x1f7
801028a8:	e8 67 ff ff ff       	call   80102814 <inb>
801028ad:	83 c4 04             	add    $0x4,%esp
801028b0:	0f b6 c0             	movzbl %al,%eax
801028b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801028b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028b9:	25 c0 00 00 00       	and    $0xc0,%eax
801028be:	83 f8 40             	cmp    $0x40,%eax
801028c1:	75 e0                	jne    801028a3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801028c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028c7:	74 11                	je     801028da <idewait+0x3e>
801028c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028cc:	83 e0 21             	and    $0x21,%eax
801028cf:	85 c0                	test   %eax,%eax
801028d1:	74 07                	je     801028da <idewait+0x3e>
    return -1;
801028d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801028d8:	eb 05                	jmp    801028df <idewait+0x43>
  return 0;
801028da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028df:	c9                   	leave  
801028e0:	c3                   	ret    

801028e1 <ideinit>:

void
ideinit(void)
{
801028e1:	55                   	push   %ebp
801028e2:	89 e5                	mov    %esp,%ebp
801028e4:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801028e7:	83 ec 08             	sub    $0x8,%esp
801028ea:	68 26 a7 10 80       	push   $0x8010a726
801028ef:	68 20 d6 10 80       	push   $0x8010d620
801028f4:	e8 87 43 00 00       	call   80106c80 <initlock>
801028f9:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801028fc:	83 ec 0c             	sub    $0xc,%esp
801028ff:	6a 0e                	push   $0xe
80102901:	e8 da 18 00 00       	call   801041e0 <picenable>
80102906:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102909:	a1 60 49 11 80       	mov    0x80114960,%eax
8010290e:	83 e8 01             	sub    $0x1,%eax
80102911:	83 ec 08             	sub    $0x8,%esp
80102914:	50                   	push   %eax
80102915:	6a 0e                	push   $0xe
80102917:	e8 73 04 00 00       	call   80102d8f <ioapicenable>
8010291c:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	6a 00                	push   $0x0
80102924:	e8 73 ff ff ff       	call   8010289c <idewait>
80102929:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010292c:	83 ec 08             	sub    $0x8,%esp
8010292f:	68 f0 00 00 00       	push   $0xf0
80102934:	68 f6 01 00 00       	push   $0x1f6
80102939:	e8 19 ff ff ff       	call   80102857 <outb>
8010293e:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102948:	eb 24                	jmp    8010296e <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010294a:	83 ec 0c             	sub    $0xc,%esp
8010294d:	68 f7 01 00 00       	push   $0x1f7
80102952:	e8 bd fe ff ff       	call   80102814 <inb>
80102957:	83 c4 10             	add    $0x10,%esp
8010295a:	84 c0                	test   %al,%al
8010295c:	74 0c                	je     8010296a <ideinit+0x89>
      havedisk1 = 1;
8010295e:	c7 05 58 d6 10 80 01 	movl   $0x1,0x8010d658
80102965:	00 00 00 
      break;
80102968:	eb 0d                	jmp    80102977 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010296a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010296e:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102975:	7e d3                	jle    8010294a <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102977:	83 ec 08             	sub    $0x8,%esp
8010297a:	68 e0 00 00 00       	push   $0xe0
8010297f:	68 f6 01 00 00       	push   $0x1f6
80102984:	e8 ce fe ff ff       	call   80102857 <outb>
80102989:	83 c4 10             	add    $0x10,%esp
}
8010298c:	90                   	nop
8010298d:	c9                   	leave  
8010298e:	c3                   	ret    

8010298f <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010298f:	55                   	push   %ebp
80102990:	89 e5                	mov    %esp,%ebp
80102992:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102995:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102999:	75 0d                	jne    801029a8 <idestart+0x19>
    panic("idestart");
8010299b:	83 ec 0c             	sub    $0xc,%esp
8010299e:	68 2a a7 10 80       	push   $0x8010a72a
801029a3:	e8 be db ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801029a8:	8b 45 08             	mov    0x8(%ebp),%eax
801029ab:	8b 40 08             	mov    0x8(%eax),%eax
801029ae:	3d cf 07 00 00       	cmp    $0x7cf,%eax
801029b3:	76 0d                	jbe    801029c2 <idestart+0x33>
    panic("incorrect blockno");
801029b5:	83 ec 0c             	sub    $0xc,%esp
801029b8:	68 33 a7 10 80       	push   $0x8010a733
801029bd:	e8 a4 db ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801029c2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801029c9:	8b 45 08             	mov    0x8(%ebp),%eax
801029cc:	8b 50 08             	mov    0x8(%eax),%edx
801029cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d2:	0f af c2             	imul   %edx,%eax
801029d5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
801029d8:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801029dc:	7e 0d                	jle    801029eb <idestart+0x5c>
801029de:	83 ec 0c             	sub    $0xc,%esp
801029e1:	68 2a a7 10 80       	push   $0x8010a72a
801029e6:	e8 7b db ff ff       	call   80100566 <panic>
  
  idewait(0);
801029eb:	83 ec 0c             	sub    $0xc,%esp
801029ee:	6a 00                	push   $0x0
801029f0:	e8 a7 fe ff ff       	call   8010289c <idewait>
801029f5:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801029f8:	83 ec 08             	sub    $0x8,%esp
801029fb:	6a 00                	push   $0x0
801029fd:	68 f6 03 00 00       	push   $0x3f6
80102a02:	e8 50 fe ff ff       	call   80102857 <outb>
80102a07:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0d:	0f b6 c0             	movzbl %al,%eax
80102a10:	83 ec 08             	sub    $0x8,%esp
80102a13:	50                   	push   %eax
80102a14:	68 f2 01 00 00       	push   $0x1f2
80102a19:	e8 39 fe ff ff       	call   80102857 <outb>
80102a1e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a24:	0f b6 c0             	movzbl %al,%eax
80102a27:	83 ec 08             	sub    $0x8,%esp
80102a2a:	50                   	push   %eax
80102a2b:	68 f3 01 00 00       	push   $0x1f3
80102a30:	e8 22 fe ff ff       	call   80102857 <outb>
80102a35:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a3b:	c1 f8 08             	sar    $0x8,%eax
80102a3e:	0f b6 c0             	movzbl %al,%eax
80102a41:	83 ec 08             	sub    $0x8,%esp
80102a44:	50                   	push   %eax
80102a45:	68 f4 01 00 00       	push   $0x1f4
80102a4a:	e8 08 fe ff ff       	call   80102857 <outb>
80102a4f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a55:	c1 f8 10             	sar    $0x10,%eax
80102a58:	0f b6 c0             	movzbl %al,%eax
80102a5b:	83 ec 08             	sub    $0x8,%esp
80102a5e:	50                   	push   %eax
80102a5f:	68 f5 01 00 00       	push   $0x1f5
80102a64:	e8 ee fd ff ff       	call   80102857 <outb>
80102a69:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6f:	8b 40 04             	mov    0x4(%eax),%eax
80102a72:	83 e0 01             	and    $0x1,%eax
80102a75:	c1 e0 04             	shl    $0x4,%eax
80102a78:	89 c2                	mov    %eax,%edx
80102a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a7d:	c1 f8 18             	sar    $0x18,%eax
80102a80:	83 e0 0f             	and    $0xf,%eax
80102a83:	09 d0                	or     %edx,%eax
80102a85:	83 c8 e0             	or     $0xffffffe0,%eax
80102a88:	0f b6 c0             	movzbl %al,%eax
80102a8b:	83 ec 08             	sub    $0x8,%esp
80102a8e:	50                   	push   %eax
80102a8f:	68 f6 01 00 00       	push   $0x1f6
80102a94:	e8 be fd ff ff       	call   80102857 <outb>
80102a99:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9f:	8b 00                	mov    (%eax),%eax
80102aa1:	83 e0 04             	and    $0x4,%eax
80102aa4:	85 c0                	test   %eax,%eax
80102aa6:	74 30                	je     80102ad8 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102aa8:	83 ec 08             	sub    $0x8,%esp
80102aab:	6a 30                	push   $0x30
80102aad:	68 f7 01 00 00       	push   $0x1f7
80102ab2:	e8 a0 fd ff ff       	call   80102857 <outb>
80102ab7:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102aba:	8b 45 08             	mov    0x8(%ebp),%eax
80102abd:	83 c0 18             	add    $0x18,%eax
80102ac0:	83 ec 04             	sub    $0x4,%esp
80102ac3:	68 80 00 00 00       	push   $0x80
80102ac8:	50                   	push   %eax
80102ac9:	68 f0 01 00 00       	push   $0x1f0
80102ace:	e8 a3 fd ff ff       	call   80102876 <outsl>
80102ad3:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102ad6:	eb 12                	jmp    80102aea <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102ad8:	83 ec 08             	sub    $0x8,%esp
80102adb:	6a 20                	push   $0x20
80102add:	68 f7 01 00 00       	push   $0x1f7
80102ae2:	e8 70 fd ff ff       	call   80102857 <outb>
80102ae7:	83 c4 10             	add    $0x10,%esp
  }
}
80102aea:	90                   	nop
80102aeb:	c9                   	leave  
80102aec:	c3                   	ret    

80102aed <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102aed:	55                   	push   %ebp
80102aee:	89 e5                	mov    %esp,%ebp
80102af0:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102af3:	83 ec 0c             	sub    $0xc,%esp
80102af6:	68 20 d6 10 80       	push   $0x8010d620
80102afb:	e8 a2 41 00 00       	call   80106ca2 <acquire>
80102b00:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102b03:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b0f:	75 15                	jne    80102b26 <ideintr+0x39>
    release(&idelock);
80102b11:	83 ec 0c             	sub    $0xc,%esp
80102b14:	68 20 d6 10 80       	push   $0x8010d620
80102b19:	e8 eb 41 00 00       	call   80106d09 <release>
80102b1e:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102b21:	e9 9a 00 00 00       	jmp    80102bc0 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b29:	8b 40 14             	mov    0x14(%eax),%eax
80102b2c:	a3 54 d6 10 80       	mov    %eax,0x8010d654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b34:	8b 00                	mov    (%eax),%eax
80102b36:	83 e0 04             	and    $0x4,%eax
80102b39:	85 c0                	test   %eax,%eax
80102b3b:	75 2d                	jne    80102b6a <ideintr+0x7d>
80102b3d:	83 ec 0c             	sub    $0xc,%esp
80102b40:	6a 01                	push   $0x1
80102b42:	e8 55 fd ff ff       	call   8010289c <idewait>
80102b47:	83 c4 10             	add    $0x10,%esp
80102b4a:	85 c0                	test   %eax,%eax
80102b4c:	78 1c                	js     80102b6a <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b51:	83 c0 18             	add    $0x18,%eax
80102b54:	83 ec 04             	sub    $0x4,%esp
80102b57:	68 80 00 00 00       	push   $0x80
80102b5c:	50                   	push   %eax
80102b5d:	68 f0 01 00 00       	push   $0x1f0
80102b62:	e8 ca fc ff ff       	call   80102831 <insl>
80102b67:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6d:	8b 00                	mov    (%eax),%eax
80102b6f:	83 c8 02             	or     $0x2,%eax
80102b72:	89 c2                	mov    %eax,%edx
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7c:	8b 00                	mov    (%eax),%eax
80102b7e:	83 e0 fb             	and    $0xfffffffb,%eax
80102b81:	89 c2                	mov    %eax,%edx
80102b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b86:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102b88:	83 ec 0c             	sub    $0xc,%esp
80102b8b:	ff 75 f4             	pushl  -0xc(%ebp)
80102b8e:	e8 0a 30 00 00       	call   80105b9d <wakeup>
80102b93:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102b96:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102b9b:	85 c0                	test   %eax,%eax
80102b9d:	74 11                	je     80102bb0 <ideintr+0xc3>
    idestart(idequeue);
80102b9f:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102ba4:	83 ec 0c             	sub    $0xc,%esp
80102ba7:	50                   	push   %eax
80102ba8:	e8 e2 fd ff ff       	call   8010298f <idestart>
80102bad:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102bb0:	83 ec 0c             	sub    $0xc,%esp
80102bb3:	68 20 d6 10 80       	push   $0x8010d620
80102bb8:	e8 4c 41 00 00       	call   80106d09 <release>
80102bbd:	83 c4 10             	add    $0x10,%esp
}
80102bc0:	c9                   	leave  
80102bc1:	c3                   	ret    

80102bc2 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102bc2:	55                   	push   %ebp
80102bc3:	89 e5                	mov    %esp,%ebp
80102bc5:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcb:	8b 00                	mov    (%eax),%eax
80102bcd:	83 e0 01             	and    $0x1,%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	75 0d                	jne    80102be1 <iderw+0x1f>
    panic("iderw: buf not busy");
80102bd4:	83 ec 0c             	sub    $0xc,%esp
80102bd7:	68 45 a7 10 80       	push   $0x8010a745
80102bdc:	e8 85 d9 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102be1:	8b 45 08             	mov    0x8(%ebp),%eax
80102be4:	8b 00                	mov    (%eax),%eax
80102be6:	83 e0 06             	and    $0x6,%eax
80102be9:	83 f8 02             	cmp    $0x2,%eax
80102bec:	75 0d                	jne    80102bfb <iderw+0x39>
    panic("iderw: nothing to do");
80102bee:	83 ec 0c             	sub    $0xc,%esp
80102bf1:	68 59 a7 10 80       	push   $0x8010a759
80102bf6:	e8 6b d9 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfe:	8b 40 04             	mov    0x4(%eax),%eax
80102c01:	85 c0                	test   %eax,%eax
80102c03:	74 16                	je     80102c1b <iderw+0x59>
80102c05:	a1 58 d6 10 80       	mov    0x8010d658,%eax
80102c0a:	85 c0                	test   %eax,%eax
80102c0c:	75 0d                	jne    80102c1b <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102c0e:	83 ec 0c             	sub    $0xc,%esp
80102c11:	68 6e a7 10 80       	push   $0x8010a76e
80102c16:	e8 4b d9 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102c1b:	83 ec 0c             	sub    $0xc,%esp
80102c1e:	68 20 d6 10 80       	push   $0x8010d620
80102c23:	e8 7a 40 00 00       	call   80106ca2 <acquire>
80102c28:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102c35:	c7 45 f4 54 d6 10 80 	movl   $0x8010d654,-0xc(%ebp)
80102c3c:	eb 0b                	jmp    80102c49 <iderw+0x87>
80102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c41:	8b 00                	mov    (%eax),%eax
80102c43:	83 c0 14             	add    $0x14,%eax
80102c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4c:	8b 00                	mov    (%eax),%eax
80102c4e:	85 c0                	test   %eax,%eax
80102c50:	75 ec                	jne    80102c3e <iderw+0x7c>
    ;
  *pp = b;
80102c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c55:	8b 55 08             	mov    0x8(%ebp),%edx
80102c58:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102c5a:	a1 54 d6 10 80       	mov    0x8010d654,%eax
80102c5f:	3b 45 08             	cmp    0x8(%ebp),%eax
80102c62:	75 23                	jne    80102c87 <iderw+0xc5>
    idestart(b);
80102c64:	83 ec 0c             	sub    $0xc,%esp
80102c67:	ff 75 08             	pushl  0x8(%ebp)
80102c6a:	e8 20 fd ff ff       	call   8010298f <idestart>
80102c6f:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c72:	eb 13                	jmp    80102c87 <iderw+0xc5>
    sleep(b, &idelock);
80102c74:	83 ec 08             	sub    $0x8,%esp
80102c77:	68 20 d6 10 80       	push   $0x8010d620
80102c7c:	ff 75 08             	pushl  0x8(%ebp)
80102c7f:	e8 09 2d 00 00       	call   8010598d <sleep>
80102c84:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c87:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8a:	8b 00                	mov    (%eax),%eax
80102c8c:	83 e0 06             	and    $0x6,%eax
80102c8f:	83 f8 02             	cmp    $0x2,%eax
80102c92:	75 e0                	jne    80102c74 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102c94:	83 ec 0c             	sub    $0xc,%esp
80102c97:	68 20 d6 10 80       	push   $0x8010d620
80102c9c:	e8 68 40 00 00       	call   80106d09 <release>
80102ca1:	83 c4 10             	add    $0x10,%esp
}
80102ca4:	90                   	nop
80102ca5:	c9                   	leave  
80102ca6:	c3                   	ret    

80102ca7 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ca7:	55                   	push   %ebp
80102ca8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102caa:	a1 34 42 11 80       	mov    0x80114234,%eax
80102caf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb2:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102cb4:	a1 34 42 11 80       	mov    0x80114234,%eax
80102cb9:	8b 40 10             	mov    0x10(%eax),%eax
}
80102cbc:	5d                   	pop    %ebp
80102cbd:	c3                   	ret    

80102cbe <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102cbe:	55                   	push   %ebp
80102cbf:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102cc1:	a1 34 42 11 80       	mov    0x80114234,%eax
80102cc6:	8b 55 08             	mov    0x8(%ebp),%edx
80102cc9:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ccb:	a1 34 42 11 80       	mov    0x80114234,%eax
80102cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
80102cd3:	89 50 10             	mov    %edx,0x10(%eax)
}
80102cd6:	90                   	nop
80102cd7:	5d                   	pop    %ebp
80102cd8:	c3                   	ret    

80102cd9 <ioapicinit>:

void
ioapicinit(void)
{
80102cd9:	55                   	push   %ebp
80102cda:	89 e5                	mov    %esp,%ebp
80102cdc:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102cdf:	a1 64 43 11 80       	mov    0x80114364,%eax
80102ce4:	85 c0                	test   %eax,%eax
80102ce6:	0f 84 a0 00 00 00    	je     80102d8c <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102cec:	c7 05 34 42 11 80 00 	movl   $0xfec00000,0x80114234
80102cf3:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102cf6:	6a 01                	push   $0x1
80102cf8:	e8 aa ff ff ff       	call   80102ca7 <ioapicread>
80102cfd:	83 c4 04             	add    $0x4,%esp
80102d00:	c1 e8 10             	shr    $0x10,%eax
80102d03:	25 ff 00 00 00       	and    $0xff,%eax
80102d08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102d0b:	6a 00                	push   $0x0
80102d0d:	e8 95 ff ff ff       	call   80102ca7 <ioapicread>
80102d12:	83 c4 04             	add    $0x4,%esp
80102d15:	c1 e8 18             	shr    $0x18,%eax
80102d18:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102d1b:	0f b6 05 60 43 11 80 	movzbl 0x80114360,%eax
80102d22:	0f b6 c0             	movzbl %al,%eax
80102d25:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102d28:	74 10                	je     80102d3a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102d2a:	83 ec 0c             	sub    $0xc,%esp
80102d2d:	68 8c a7 10 80       	push   $0x8010a78c
80102d32:	e8 8f d6 ff ff       	call   801003c6 <cprintf>
80102d37:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102d41:	eb 3f                	jmp    80102d82 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d46:	83 c0 20             	add    $0x20,%eax
80102d49:	0d 00 00 01 00       	or     $0x10000,%eax
80102d4e:	89 c2                	mov    %eax,%edx
80102d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d53:	83 c0 08             	add    $0x8,%eax
80102d56:	01 c0                	add    %eax,%eax
80102d58:	83 ec 08             	sub    $0x8,%esp
80102d5b:	52                   	push   %edx
80102d5c:	50                   	push   %eax
80102d5d:	e8 5c ff ff ff       	call   80102cbe <ioapicwrite>
80102d62:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d68:	83 c0 08             	add    $0x8,%eax
80102d6b:	01 c0                	add    %eax,%eax
80102d6d:	83 c0 01             	add    $0x1,%eax
80102d70:	83 ec 08             	sub    $0x8,%esp
80102d73:	6a 00                	push   $0x0
80102d75:	50                   	push   %eax
80102d76:	e8 43 ff ff ff       	call   80102cbe <ioapicwrite>
80102d7b:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d85:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102d88:	7e b9                	jle    80102d43 <ioapicinit+0x6a>
80102d8a:	eb 01                	jmp    80102d8d <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102d8c:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102d8d:	c9                   	leave  
80102d8e:	c3                   	ret    

80102d8f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102d8f:	55                   	push   %ebp
80102d90:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102d92:	a1 64 43 11 80       	mov    0x80114364,%eax
80102d97:	85 c0                	test   %eax,%eax
80102d99:	74 39                	je     80102dd4 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	83 c0 20             	add    $0x20,%eax
80102da1:	89 c2                	mov    %eax,%edx
80102da3:	8b 45 08             	mov    0x8(%ebp),%eax
80102da6:	83 c0 08             	add    $0x8,%eax
80102da9:	01 c0                	add    %eax,%eax
80102dab:	52                   	push   %edx
80102dac:	50                   	push   %eax
80102dad:	e8 0c ff ff ff       	call   80102cbe <ioapicwrite>
80102db2:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102db8:	c1 e0 18             	shl    $0x18,%eax
80102dbb:	89 c2                	mov    %eax,%edx
80102dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc0:	83 c0 08             	add    $0x8,%eax
80102dc3:	01 c0                	add    %eax,%eax
80102dc5:	83 c0 01             	add    $0x1,%eax
80102dc8:	52                   	push   %edx
80102dc9:	50                   	push   %eax
80102dca:	e8 ef fe ff ff       	call   80102cbe <ioapicwrite>
80102dcf:	83 c4 08             	add    $0x8,%esp
80102dd2:	eb 01                	jmp    80102dd5 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102dd4:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102dd5:	c9                   	leave  
80102dd6:	c3                   	ret    

80102dd7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	8b 45 08             	mov    0x8(%ebp),%eax
80102ddd:	05 00 00 00 80       	add    $0x80000000,%eax
80102de2:	5d                   	pop    %ebp
80102de3:	c3                   	ret    

80102de4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102de4:	55                   	push   %ebp
80102de5:	89 e5                	mov    %esp,%ebp
80102de7:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102dea:	83 ec 08             	sub    $0x8,%esp
80102ded:	68 be a7 10 80       	push   $0x8010a7be
80102df2:	68 40 42 11 80       	push   $0x80114240
80102df7:	e8 84 3e 00 00       	call   80106c80 <initlock>
80102dfc:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102dff:	c7 05 74 42 11 80 00 	movl   $0x0,0x80114274
80102e06:	00 00 00 
  freerange(vstart, vend);
80102e09:	83 ec 08             	sub    $0x8,%esp
80102e0c:	ff 75 0c             	pushl  0xc(%ebp)
80102e0f:	ff 75 08             	pushl  0x8(%ebp)
80102e12:	e8 2a 00 00 00       	call   80102e41 <freerange>
80102e17:	83 c4 10             	add    $0x10,%esp
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	ff 75 0c             	pushl  0xc(%ebp)
80102e29:	ff 75 08             	pushl  0x8(%ebp)
80102e2c:	e8 10 00 00 00       	call   80102e41 <freerange>
80102e31:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102e34:	c7 05 74 42 11 80 01 	movl   $0x1,0x80114274
80102e3b:	00 00 00 
}
80102e3e:	90                   	nop
80102e3f:	c9                   	leave  
80102e40:	c3                   	ret    

80102e41 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102e41:	55                   	push   %ebp
80102e42:	89 e5                	mov    %esp,%ebp
80102e44:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102e47:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102e4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e57:	eb 15                	jmp    80102e6e <freerange+0x2d>
    kfree(p);
80102e59:	83 ec 0c             	sub    $0xc,%esp
80102e5c:	ff 75 f4             	pushl  -0xc(%ebp)
80102e5f:	e8 1a 00 00 00       	call   80102e7e <kfree>
80102e64:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e67:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e71:	05 00 10 00 00       	add    $0x1000,%eax
80102e76:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102e79:	76 de                	jbe    80102e59 <freerange+0x18>
    kfree(p);
}
80102e7b:	90                   	nop
80102e7c:	c9                   	leave  
80102e7d:	c3                   	ret    

80102e7e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102e7e:	55                   	push   %ebp
80102e7f:	89 e5                	mov    %esp,%ebp
80102e81:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102e84:	8b 45 08             	mov    0x8(%ebp),%eax
80102e87:	25 ff 0f 00 00       	and    $0xfff,%eax
80102e8c:	85 c0                	test   %eax,%eax
80102e8e:	75 1b                	jne    80102eab <kfree+0x2d>
80102e90:	81 7d 08 3c 79 11 80 	cmpl   $0x8011793c,0x8(%ebp)
80102e97:	72 12                	jb     80102eab <kfree+0x2d>
80102e99:	ff 75 08             	pushl  0x8(%ebp)
80102e9c:	e8 36 ff ff ff       	call   80102dd7 <v2p>
80102ea1:	83 c4 04             	add    $0x4,%esp
80102ea4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ea9:	76 0d                	jbe    80102eb8 <kfree+0x3a>
    panic("kfree");
80102eab:	83 ec 0c             	sub    $0xc,%esp
80102eae:	68 c3 a7 10 80       	push   $0x8010a7c3
80102eb3:	e8 ae d6 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102eb8:	83 ec 04             	sub    $0x4,%esp
80102ebb:	68 00 10 00 00       	push   $0x1000
80102ec0:	6a 01                	push   $0x1
80102ec2:	ff 75 08             	pushl  0x8(%ebp)
80102ec5:	e8 3b 40 00 00       	call   80106f05 <memset>
80102eca:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102ecd:	a1 74 42 11 80       	mov    0x80114274,%eax
80102ed2:	85 c0                	test   %eax,%eax
80102ed4:	74 10                	je     80102ee6 <kfree+0x68>
    acquire(&kmem.lock);
80102ed6:	83 ec 0c             	sub    $0xc,%esp
80102ed9:	68 40 42 11 80       	push   $0x80114240
80102ede:	e8 bf 3d 00 00       	call   80106ca2 <acquire>
80102ee3:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102eec:	8b 15 78 42 11 80    	mov    0x80114278,%edx
80102ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ef5:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102efa:	a3 78 42 11 80       	mov    %eax,0x80114278
  if(kmem.use_lock)
80102eff:	a1 74 42 11 80       	mov    0x80114274,%eax
80102f04:	85 c0                	test   %eax,%eax
80102f06:	74 10                	je     80102f18 <kfree+0x9a>
    release(&kmem.lock);
80102f08:	83 ec 0c             	sub    $0xc,%esp
80102f0b:	68 40 42 11 80       	push   $0x80114240
80102f10:	e8 f4 3d 00 00       	call   80106d09 <release>
80102f15:	83 c4 10             	add    $0x10,%esp
}
80102f18:	90                   	nop
80102f19:	c9                   	leave  
80102f1a:	c3                   	ret    

80102f1b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102f1b:	55                   	push   %ebp
80102f1c:	89 e5                	mov    %esp,%ebp
80102f1e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102f21:	a1 74 42 11 80       	mov    0x80114274,%eax
80102f26:	85 c0                	test   %eax,%eax
80102f28:	74 10                	je     80102f3a <kalloc+0x1f>
    acquire(&kmem.lock);
80102f2a:	83 ec 0c             	sub    $0xc,%esp
80102f2d:	68 40 42 11 80       	push   $0x80114240
80102f32:	e8 6b 3d 00 00       	call   80106ca2 <acquire>
80102f37:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102f3a:	a1 78 42 11 80       	mov    0x80114278,%eax
80102f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102f42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f46:	74 0a                	je     80102f52 <kalloc+0x37>
    kmem.freelist = r->next;
80102f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f4b:	8b 00                	mov    (%eax),%eax
80102f4d:	a3 78 42 11 80       	mov    %eax,0x80114278
  if(kmem.use_lock)
80102f52:	a1 74 42 11 80       	mov    0x80114274,%eax
80102f57:	85 c0                	test   %eax,%eax
80102f59:	74 10                	je     80102f6b <kalloc+0x50>
    release(&kmem.lock);
80102f5b:	83 ec 0c             	sub    $0xc,%esp
80102f5e:	68 40 42 11 80       	push   $0x80114240
80102f63:	e8 a1 3d 00 00       	call   80106d09 <release>
80102f68:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102f6e:	c9                   	leave  
80102f6f:	c3                   	ret    

80102f70 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102f70:	55                   	push   %ebp
80102f71:	89 e5                	mov    %esp,%ebp
80102f73:	83 ec 14             	sub    $0x14,%esp
80102f76:	8b 45 08             	mov    0x8(%ebp),%eax
80102f79:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f7d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f81:	89 c2                	mov    %eax,%edx
80102f83:	ec                   	in     (%dx),%al
80102f84:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f87:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f8b:	c9                   	leave  
80102f8c:	c3                   	ret    

80102f8d <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102f8d:	55                   	push   %ebp
80102f8e:	89 e5                	mov    %esp,%ebp
80102f90:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102f93:	6a 64                	push   $0x64
80102f95:	e8 d6 ff ff ff       	call   80102f70 <inb>
80102f9a:	83 c4 04             	add    $0x4,%esp
80102f9d:	0f b6 c0             	movzbl %al,%eax
80102fa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa6:	83 e0 01             	and    $0x1,%eax
80102fa9:	85 c0                	test   %eax,%eax
80102fab:	75 0a                	jne    80102fb7 <kbdgetc+0x2a>
    return -1;
80102fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fb2:	e9 23 01 00 00       	jmp    801030da <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102fb7:	6a 60                	push   $0x60
80102fb9:	e8 b2 ff ff ff       	call   80102f70 <inb>
80102fbe:	83 c4 04             	add    $0x4,%esp
80102fc1:	0f b6 c0             	movzbl %al,%eax
80102fc4:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102fc7:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102fce:	75 17                	jne    80102fe7 <kbdgetc+0x5a>
    shift |= E0ESC;
80102fd0:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102fd5:	83 c8 40             	or     $0x40,%eax
80102fd8:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
    return 0;
80102fdd:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe2:	e9 f3 00 00 00       	jmp    801030da <kbdgetc+0x14d>
  } else if(data & 0x80){
80102fe7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fea:	25 80 00 00 00       	and    $0x80,%eax
80102fef:	85 c0                	test   %eax,%eax
80102ff1:	74 45                	je     80103038 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ff3:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80102ff8:	83 e0 40             	and    $0x40,%eax
80102ffb:	85 c0                	test   %eax,%eax
80102ffd:	75 08                	jne    80103007 <kbdgetc+0x7a>
80102fff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103002:	83 e0 7f             	and    $0x7f,%eax
80103005:	eb 03                	jmp    8010300a <kbdgetc+0x7d>
80103007:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010300a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010300d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103010:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103015:	0f b6 00             	movzbl (%eax),%eax
80103018:	83 c8 40             	or     $0x40,%eax
8010301b:	0f b6 c0             	movzbl %al,%eax
8010301e:	f7 d0                	not    %eax
80103020:	89 c2                	mov    %eax,%edx
80103022:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80103027:	21 d0                	and    %edx,%eax
80103029:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
    return 0;
8010302e:	b8 00 00 00 00       	mov    $0x0,%eax
80103033:	e9 a2 00 00 00       	jmp    801030da <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103038:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
8010303d:	83 e0 40             	and    $0x40,%eax
80103040:	85 c0                	test   %eax,%eax
80103042:	74 14                	je     80103058 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103044:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010304b:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80103050:	83 e0 bf             	and    $0xffffffbf,%eax
80103053:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  }

  shift |= shiftcode[data];
80103058:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010305b:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103060:	0f b6 00             	movzbl (%eax),%eax
80103063:	0f b6 d0             	movzbl %al,%edx
80103066:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
8010306b:	09 d0                	or     %edx,%eax
8010306d:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  shift ^= togglecode[data];
80103072:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103075:	05 20 b1 10 80       	add    $0x8010b120,%eax
8010307a:	0f b6 00             	movzbl (%eax),%eax
8010307d:	0f b6 d0             	movzbl %al,%edx
80103080:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80103085:	31 d0                	xor    %edx,%eax
80103087:	a3 5c d6 10 80       	mov    %eax,0x8010d65c
  c = charcode[shift & (CTL | SHIFT)][data];
8010308c:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
80103091:	83 e0 03             	and    $0x3,%eax
80103094:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
8010309b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010309e:	01 d0                	add    %edx,%eax
801030a0:	0f b6 00             	movzbl (%eax),%eax
801030a3:	0f b6 c0             	movzbl %al,%eax
801030a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801030a9:	a1 5c d6 10 80       	mov    0x8010d65c,%eax
801030ae:	83 e0 08             	and    $0x8,%eax
801030b1:	85 c0                	test   %eax,%eax
801030b3:	74 22                	je     801030d7 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801030b5:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801030b9:	76 0c                	jbe    801030c7 <kbdgetc+0x13a>
801030bb:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801030bf:	77 06                	ja     801030c7 <kbdgetc+0x13a>
      c += 'A' - 'a';
801030c1:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801030c5:	eb 10                	jmp    801030d7 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801030c7:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801030cb:	76 0a                	jbe    801030d7 <kbdgetc+0x14a>
801030cd:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801030d1:	77 04                	ja     801030d7 <kbdgetc+0x14a>
      c += 'a' - 'A';
801030d3:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801030d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801030da:	c9                   	leave  
801030db:	c3                   	ret    

801030dc <kbdintr>:

void
kbdintr(void)
{
801030dc:	55                   	push   %ebp
801030dd:	89 e5                	mov    %esp,%ebp
801030df:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801030e2:	83 ec 0c             	sub    $0xc,%esp
801030e5:	68 8d 2f 10 80       	push   $0x80102f8d
801030ea:	e8 0a d7 ff ff       	call   801007f9 <consoleintr>
801030ef:	83 c4 10             	add    $0x10,%esp
}
801030f2:	90                   	nop
801030f3:	c9                   	leave  
801030f4:	c3                   	ret    

801030f5 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
801030f8:	83 ec 14             	sub    $0x14,%esp
801030fb:	8b 45 08             	mov    0x8(%ebp),%eax
801030fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103102:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103106:	89 c2                	mov    %eax,%edx
80103108:	ec                   	in     (%dx),%al
80103109:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010310c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103110:	c9                   	leave  
80103111:	c3                   	ret    

80103112 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103112:	55                   	push   %ebp
80103113:	89 e5                	mov    %esp,%ebp
80103115:	83 ec 08             	sub    $0x8,%esp
80103118:	8b 55 08             	mov    0x8(%ebp),%edx
8010311b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010311e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103122:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103125:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103129:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010312d:	ee                   	out    %al,(%dx)
}
8010312e:	90                   	nop
8010312f:	c9                   	leave  
80103130:	c3                   	ret    

80103131 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103131:	55                   	push   %ebp
80103132:	89 e5                	mov    %esp,%ebp
80103134:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103137:	9c                   	pushf  
80103138:	58                   	pop    %eax
80103139:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010313c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010313f:	c9                   	leave  
80103140:	c3                   	ret    

80103141 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103141:	55                   	push   %ebp
80103142:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103144:	a1 7c 42 11 80       	mov    0x8011427c,%eax
80103149:	8b 55 08             	mov    0x8(%ebp),%edx
8010314c:	c1 e2 02             	shl    $0x2,%edx
8010314f:	01 c2                	add    %eax,%edx
80103151:	8b 45 0c             	mov    0xc(%ebp),%eax
80103154:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103156:	a1 7c 42 11 80       	mov    0x8011427c,%eax
8010315b:	83 c0 20             	add    $0x20,%eax
8010315e:	8b 00                	mov    (%eax),%eax
}
80103160:	90                   	nop
80103161:	5d                   	pop    %ebp
80103162:	c3                   	ret    

80103163 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80103163:	55                   	push   %ebp
80103164:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80103166:	a1 7c 42 11 80       	mov    0x8011427c,%eax
8010316b:	85 c0                	test   %eax,%eax
8010316d:	0f 84 0b 01 00 00    	je     8010327e <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103173:	68 3f 01 00 00       	push   $0x13f
80103178:	6a 3c                	push   $0x3c
8010317a:	e8 c2 ff ff ff       	call   80103141 <lapicw>
8010317f:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103182:	6a 0b                	push   $0xb
80103184:	68 f8 00 00 00       	push   $0xf8
80103189:	e8 b3 ff ff ff       	call   80103141 <lapicw>
8010318e:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103191:	68 20 00 02 00       	push   $0x20020
80103196:	68 c8 00 00 00       	push   $0xc8
8010319b:	e8 a1 ff ff ff       	call   80103141 <lapicw>
801031a0:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
801031a3:	68 40 42 0f 00       	push   $0xf4240
801031a8:	68 e0 00 00 00       	push   $0xe0
801031ad:	e8 8f ff ff ff       	call   80103141 <lapicw>
801031b2:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801031b5:	68 00 00 01 00       	push   $0x10000
801031ba:	68 d4 00 00 00       	push   $0xd4
801031bf:	e8 7d ff ff ff       	call   80103141 <lapicw>
801031c4:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801031c7:	68 00 00 01 00       	push   $0x10000
801031cc:	68 d8 00 00 00       	push   $0xd8
801031d1:	e8 6b ff ff ff       	call   80103141 <lapicw>
801031d6:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801031d9:	a1 7c 42 11 80       	mov    0x8011427c,%eax
801031de:	83 c0 30             	add    $0x30,%eax
801031e1:	8b 00                	mov    (%eax),%eax
801031e3:	c1 e8 10             	shr    $0x10,%eax
801031e6:	0f b6 c0             	movzbl %al,%eax
801031e9:	83 f8 03             	cmp    $0x3,%eax
801031ec:	76 12                	jbe    80103200 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
801031ee:	68 00 00 01 00       	push   $0x10000
801031f3:	68 d0 00 00 00       	push   $0xd0
801031f8:	e8 44 ff ff ff       	call   80103141 <lapicw>
801031fd:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103200:	6a 33                	push   $0x33
80103202:	68 dc 00 00 00       	push   $0xdc
80103207:	e8 35 ff ff ff       	call   80103141 <lapicw>
8010320c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010320f:	6a 00                	push   $0x0
80103211:	68 a0 00 00 00       	push   $0xa0
80103216:	e8 26 ff ff ff       	call   80103141 <lapicw>
8010321b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010321e:	6a 00                	push   $0x0
80103220:	68 a0 00 00 00       	push   $0xa0
80103225:	e8 17 ff ff ff       	call   80103141 <lapicw>
8010322a:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010322d:	6a 00                	push   $0x0
8010322f:	6a 2c                	push   $0x2c
80103231:	e8 0b ff ff ff       	call   80103141 <lapicw>
80103236:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103239:	6a 00                	push   $0x0
8010323b:	68 c4 00 00 00       	push   $0xc4
80103240:	e8 fc fe ff ff       	call   80103141 <lapicw>
80103245:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103248:	68 00 85 08 00       	push   $0x88500
8010324d:	68 c0 00 00 00       	push   $0xc0
80103252:	e8 ea fe ff ff       	call   80103141 <lapicw>
80103257:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010325a:	90                   	nop
8010325b:	a1 7c 42 11 80       	mov    0x8011427c,%eax
80103260:	05 00 03 00 00       	add    $0x300,%eax
80103265:	8b 00                	mov    (%eax),%eax
80103267:	25 00 10 00 00       	and    $0x1000,%eax
8010326c:	85 c0                	test   %eax,%eax
8010326e:	75 eb                	jne    8010325b <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103270:	6a 00                	push   $0x0
80103272:	6a 20                	push   $0x20
80103274:	e8 c8 fe ff ff       	call   80103141 <lapicw>
80103279:	83 c4 08             	add    $0x8,%esp
8010327c:	eb 01                	jmp    8010327f <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010327e:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010327f:	c9                   	leave  
80103280:	c3                   	ret    

80103281 <cpunum>:

int
cpunum(void)
{
80103281:	55                   	push   %ebp
80103282:	89 e5                	mov    %esp,%ebp
80103284:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103287:	e8 a5 fe ff ff       	call   80103131 <readeflags>
8010328c:	25 00 02 00 00       	and    $0x200,%eax
80103291:	85 c0                	test   %eax,%eax
80103293:	74 26                	je     801032bb <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103295:	a1 60 d6 10 80       	mov    0x8010d660,%eax
8010329a:	8d 50 01             	lea    0x1(%eax),%edx
8010329d:	89 15 60 d6 10 80    	mov    %edx,0x8010d660
801032a3:	85 c0                	test   %eax,%eax
801032a5:	75 14                	jne    801032bb <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801032a7:	8b 45 04             	mov    0x4(%ebp),%eax
801032aa:	83 ec 08             	sub    $0x8,%esp
801032ad:	50                   	push   %eax
801032ae:	68 cc a7 10 80       	push   $0x8010a7cc
801032b3:	e8 0e d1 ff ff       	call   801003c6 <cprintf>
801032b8:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801032bb:	a1 7c 42 11 80       	mov    0x8011427c,%eax
801032c0:	85 c0                	test   %eax,%eax
801032c2:	74 0f                	je     801032d3 <cpunum+0x52>
    return lapic[ID]>>24;
801032c4:	a1 7c 42 11 80       	mov    0x8011427c,%eax
801032c9:	83 c0 20             	add    $0x20,%eax
801032cc:	8b 00                	mov    (%eax),%eax
801032ce:	c1 e8 18             	shr    $0x18,%eax
801032d1:	eb 05                	jmp    801032d8 <cpunum+0x57>
  return 0;
801032d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801032d8:	c9                   	leave  
801032d9:	c3                   	ret    

801032da <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801032da:	55                   	push   %ebp
801032db:	89 e5                	mov    %esp,%ebp
  if(lapic)
801032dd:	a1 7c 42 11 80       	mov    0x8011427c,%eax
801032e2:	85 c0                	test   %eax,%eax
801032e4:	74 0c                	je     801032f2 <lapiceoi+0x18>
    lapicw(EOI, 0);
801032e6:	6a 00                	push   $0x0
801032e8:	6a 2c                	push   $0x2c
801032ea:	e8 52 fe ff ff       	call   80103141 <lapicw>
801032ef:	83 c4 08             	add    $0x8,%esp
}
801032f2:	90                   	nop
801032f3:	c9                   	leave  
801032f4:	c3                   	ret    

801032f5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801032f5:	55                   	push   %ebp
801032f6:	89 e5                	mov    %esp,%ebp
}
801032f8:	90                   	nop
801032f9:	5d                   	pop    %ebp
801032fa:	c3                   	ret    

801032fb <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801032fb:	55                   	push   %ebp
801032fc:	89 e5                	mov    %esp,%ebp
801032fe:	83 ec 14             	sub    $0x14,%esp
80103301:	8b 45 08             	mov    0x8(%ebp),%eax
80103304:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103307:	6a 0f                	push   $0xf
80103309:	6a 70                	push   $0x70
8010330b:	e8 02 fe ff ff       	call   80103112 <outb>
80103310:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103313:	6a 0a                	push   $0xa
80103315:	6a 71                	push   $0x71
80103317:	e8 f6 fd ff ff       	call   80103112 <outb>
8010331c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010331f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103326:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103329:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010332e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103331:	83 c0 02             	add    $0x2,%eax
80103334:	8b 55 0c             	mov    0xc(%ebp),%edx
80103337:	c1 ea 04             	shr    $0x4,%edx
8010333a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010333d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103341:	c1 e0 18             	shl    $0x18,%eax
80103344:	50                   	push   %eax
80103345:	68 c4 00 00 00       	push   $0xc4
8010334a:	e8 f2 fd ff ff       	call   80103141 <lapicw>
8010334f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103352:	68 00 c5 00 00       	push   $0xc500
80103357:	68 c0 00 00 00       	push   $0xc0
8010335c:	e8 e0 fd ff ff       	call   80103141 <lapicw>
80103361:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103364:	68 c8 00 00 00       	push   $0xc8
80103369:	e8 87 ff ff ff       	call   801032f5 <microdelay>
8010336e:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103371:	68 00 85 00 00       	push   $0x8500
80103376:	68 c0 00 00 00       	push   $0xc0
8010337b:	e8 c1 fd ff ff       	call   80103141 <lapicw>
80103380:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103383:	6a 64                	push   $0x64
80103385:	e8 6b ff ff ff       	call   801032f5 <microdelay>
8010338a:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010338d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103394:	eb 3d                	jmp    801033d3 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103396:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010339a:	c1 e0 18             	shl    $0x18,%eax
8010339d:	50                   	push   %eax
8010339e:	68 c4 00 00 00       	push   $0xc4
801033a3:	e8 99 fd ff ff       	call   80103141 <lapicw>
801033a8:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801033ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801033ae:	c1 e8 0c             	shr    $0xc,%eax
801033b1:	80 cc 06             	or     $0x6,%ah
801033b4:	50                   	push   %eax
801033b5:	68 c0 00 00 00       	push   $0xc0
801033ba:	e8 82 fd ff ff       	call   80103141 <lapicw>
801033bf:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801033c2:	68 c8 00 00 00       	push   $0xc8
801033c7:	e8 29 ff ff ff       	call   801032f5 <microdelay>
801033cc:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801033cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801033d3:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801033d7:	7e bd                	jle    80103396 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801033d9:	90                   	nop
801033da:	c9                   	leave  
801033db:	c3                   	ret    

801033dc <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801033dc:	55                   	push   %ebp
801033dd:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801033df:	8b 45 08             	mov    0x8(%ebp),%eax
801033e2:	0f b6 c0             	movzbl %al,%eax
801033e5:	50                   	push   %eax
801033e6:	6a 70                	push   $0x70
801033e8:	e8 25 fd ff ff       	call   80103112 <outb>
801033ed:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801033f0:	68 c8 00 00 00       	push   $0xc8
801033f5:	e8 fb fe ff ff       	call   801032f5 <microdelay>
801033fa:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801033fd:	6a 71                	push   $0x71
801033ff:	e8 f1 fc ff ff       	call   801030f5 <inb>
80103404:	83 c4 04             	add    $0x4,%esp
80103407:	0f b6 c0             	movzbl %al,%eax
}
8010340a:	c9                   	leave  
8010340b:	c3                   	ret    

8010340c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010340c:	55                   	push   %ebp
8010340d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010340f:	6a 00                	push   $0x0
80103411:	e8 c6 ff ff ff       	call   801033dc <cmos_read>
80103416:	83 c4 04             	add    $0x4,%esp
80103419:	89 c2                	mov    %eax,%edx
8010341b:	8b 45 08             	mov    0x8(%ebp),%eax
8010341e:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103420:	6a 02                	push   $0x2
80103422:	e8 b5 ff ff ff       	call   801033dc <cmos_read>
80103427:	83 c4 04             	add    $0x4,%esp
8010342a:	89 c2                	mov    %eax,%edx
8010342c:	8b 45 08             	mov    0x8(%ebp),%eax
8010342f:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103432:	6a 04                	push   $0x4
80103434:	e8 a3 ff ff ff       	call   801033dc <cmos_read>
80103439:	83 c4 04             	add    $0x4,%esp
8010343c:	89 c2                	mov    %eax,%edx
8010343e:	8b 45 08             	mov    0x8(%ebp),%eax
80103441:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103444:	6a 07                	push   $0x7
80103446:	e8 91 ff ff ff       	call   801033dc <cmos_read>
8010344b:	83 c4 04             	add    $0x4,%esp
8010344e:	89 c2                	mov    %eax,%edx
80103450:	8b 45 08             	mov    0x8(%ebp),%eax
80103453:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103456:	6a 08                	push   $0x8
80103458:	e8 7f ff ff ff       	call   801033dc <cmos_read>
8010345d:	83 c4 04             	add    $0x4,%esp
80103460:	89 c2                	mov    %eax,%edx
80103462:	8b 45 08             	mov    0x8(%ebp),%eax
80103465:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103468:	6a 09                	push   $0x9
8010346a:	e8 6d ff ff ff       	call   801033dc <cmos_read>
8010346f:	83 c4 04             	add    $0x4,%esp
80103472:	89 c2                	mov    %eax,%edx
80103474:	8b 45 08             	mov    0x8(%ebp),%eax
80103477:	89 50 14             	mov    %edx,0x14(%eax)
}
8010347a:	90                   	nop
8010347b:	c9                   	leave  
8010347c:	c3                   	ret    

8010347d <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010347d:	55                   	push   %ebp
8010347e:	89 e5                	mov    %esp,%ebp
80103480:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103483:	6a 0b                	push   $0xb
80103485:	e8 52 ff ff ff       	call   801033dc <cmos_read>
8010348a:	83 c4 04             	add    $0x4,%esp
8010348d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103493:	83 e0 04             	and    $0x4,%eax
80103496:	85 c0                	test   %eax,%eax
80103498:	0f 94 c0             	sete   %al
8010349b:	0f b6 c0             	movzbl %al,%eax
8010349e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801034a1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801034a4:	50                   	push   %eax
801034a5:	e8 62 ff ff ff       	call   8010340c <fill_rtcdate>
801034aa:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801034ad:	6a 0a                	push   $0xa
801034af:	e8 28 ff ff ff       	call   801033dc <cmos_read>
801034b4:	83 c4 04             	add    $0x4,%esp
801034b7:	25 80 00 00 00       	and    $0x80,%eax
801034bc:	85 c0                	test   %eax,%eax
801034be:	75 27                	jne    801034e7 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801034c0:	8d 45 c0             	lea    -0x40(%ebp),%eax
801034c3:	50                   	push   %eax
801034c4:	e8 43 ff ff ff       	call   8010340c <fill_rtcdate>
801034c9:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801034cc:	83 ec 04             	sub    $0x4,%esp
801034cf:	6a 18                	push   $0x18
801034d1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801034d4:	50                   	push   %eax
801034d5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801034d8:	50                   	push   %eax
801034d9:	e8 8e 3a 00 00       	call   80106f6c <memcmp>
801034de:	83 c4 10             	add    $0x10,%esp
801034e1:	85 c0                	test   %eax,%eax
801034e3:	74 05                	je     801034ea <cmostime+0x6d>
801034e5:	eb ba                	jmp    801034a1 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801034e7:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801034e8:	eb b7                	jmp    801034a1 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801034ea:	90                   	nop
  }

  // convert
  if (bcd) {
801034eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801034ef:	0f 84 b4 00 00 00    	je     801035a9 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801034f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801034f8:	c1 e8 04             	shr    $0x4,%eax
801034fb:	89 c2                	mov    %eax,%edx
801034fd:	89 d0                	mov    %edx,%eax
801034ff:	c1 e0 02             	shl    $0x2,%eax
80103502:	01 d0                	add    %edx,%eax
80103504:	01 c0                	add    %eax,%eax
80103506:	89 c2                	mov    %eax,%edx
80103508:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010350b:	83 e0 0f             	and    $0xf,%eax
8010350e:	01 d0                	add    %edx,%eax
80103510:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103513:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103516:	c1 e8 04             	shr    $0x4,%eax
80103519:	89 c2                	mov    %eax,%edx
8010351b:	89 d0                	mov    %edx,%eax
8010351d:	c1 e0 02             	shl    $0x2,%eax
80103520:	01 d0                	add    %edx,%eax
80103522:	01 c0                	add    %eax,%eax
80103524:	89 c2                	mov    %eax,%edx
80103526:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103529:	83 e0 0f             	and    $0xf,%eax
8010352c:	01 d0                	add    %edx,%eax
8010352e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103531:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103534:	c1 e8 04             	shr    $0x4,%eax
80103537:	89 c2                	mov    %eax,%edx
80103539:	89 d0                	mov    %edx,%eax
8010353b:	c1 e0 02             	shl    $0x2,%eax
8010353e:	01 d0                	add    %edx,%eax
80103540:	01 c0                	add    %eax,%eax
80103542:	89 c2                	mov    %eax,%edx
80103544:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103547:	83 e0 0f             	and    $0xf,%eax
8010354a:	01 d0                	add    %edx,%eax
8010354c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010354f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103552:	c1 e8 04             	shr    $0x4,%eax
80103555:	89 c2                	mov    %eax,%edx
80103557:	89 d0                	mov    %edx,%eax
80103559:	c1 e0 02             	shl    $0x2,%eax
8010355c:	01 d0                	add    %edx,%eax
8010355e:	01 c0                	add    %eax,%eax
80103560:	89 c2                	mov    %eax,%edx
80103562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103565:	83 e0 0f             	and    $0xf,%eax
80103568:	01 d0                	add    %edx,%eax
8010356a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010356d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103570:	c1 e8 04             	shr    $0x4,%eax
80103573:	89 c2                	mov    %eax,%edx
80103575:	89 d0                	mov    %edx,%eax
80103577:	c1 e0 02             	shl    $0x2,%eax
8010357a:	01 d0                	add    %edx,%eax
8010357c:	01 c0                	add    %eax,%eax
8010357e:	89 c2                	mov    %eax,%edx
80103580:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103583:	83 e0 0f             	and    $0xf,%eax
80103586:	01 d0                	add    %edx,%eax
80103588:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010358b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010358e:	c1 e8 04             	shr    $0x4,%eax
80103591:	89 c2                	mov    %eax,%edx
80103593:	89 d0                	mov    %edx,%eax
80103595:	c1 e0 02             	shl    $0x2,%eax
80103598:	01 d0                	add    %edx,%eax
8010359a:	01 c0                	add    %eax,%eax
8010359c:	89 c2                	mov    %eax,%edx
8010359e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a1:	83 e0 0f             	and    $0xf,%eax
801035a4:	01 d0                	add    %edx,%eax
801035a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801035a9:	8b 45 08             	mov    0x8(%ebp),%eax
801035ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
801035af:	89 10                	mov    %edx,(%eax)
801035b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801035b4:	89 50 04             	mov    %edx,0x4(%eax)
801035b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801035ba:	89 50 08             	mov    %edx,0x8(%eax)
801035bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035c0:	89 50 0c             	mov    %edx,0xc(%eax)
801035c3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801035c6:	89 50 10             	mov    %edx,0x10(%eax)
801035c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801035cc:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801035cf:	8b 45 08             	mov    0x8(%ebp),%eax
801035d2:	8b 40 14             	mov    0x14(%eax),%eax
801035d5:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801035db:	8b 45 08             	mov    0x8(%ebp),%eax
801035de:	89 50 14             	mov    %edx,0x14(%eax)
}
801035e1:	90                   	nop
801035e2:	c9                   	leave  
801035e3:	c3                   	ret    

801035e4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801035e4:	55                   	push   %ebp
801035e5:	89 e5                	mov    %esp,%ebp
801035e7:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801035ea:	83 ec 08             	sub    $0x8,%esp
801035ed:	68 f8 a7 10 80       	push   $0x8010a7f8
801035f2:	68 80 42 11 80       	push   $0x80114280
801035f7:	e8 84 36 00 00       	call   80106c80 <initlock>
801035fc:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801035ff:	83 ec 08             	sub    $0x8,%esp
80103602:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103605:	50                   	push   %eax
80103606:	ff 75 08             	pushl  0x8(%ebp)
80103609:	e8 20 de ff ff       	call   8010142e <readsb>
8010360e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103611:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103614:	a3 b4 42 11 80       	mov    %eax,0x801142b4
  log.size = sb.nlog;
80103619:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010361c:	a3 b8 42 11 80       	mov    %eax,0x801142b8
  log.dev = dev;
80103621:	8b 45 08             	mov    0x8(%ebp),%eax
80103624:	a3 c4 42 11 80       	mov    %eax,0x801142c4
  recover_from_log();
80103629:	e8 b2 01 00 00       	call   801037e0 <recover_from_log>
}
8010362e:	90                   	nop
8010362f:	c9                   	leave  
80103630:	c3                   	ret    

80103631 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103631:	55                   	push   %ebp
80103632:	89 e5                	mov    %esp,%ebp
80103634:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103637:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010363e:	e9 95 00 00 00       	jmp    801036d8 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103643:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
80103649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364c:	01 d0                	add    %edx,%eax
8010364e:	83 c0 01             	add    $0x1,%eax
80103651:	89 c2                	mov    %eax,%edx
80103653:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103658:	83 ec 08             	sub    $0x8,%esp
8010365b:	52                   	push   %edx
8010365c:	50                   	push   %eax
8010365d:	e8 54 cb ff ff       	call   801001b6 <bread>
80103662:	83 c4 10             	add    $0x10,%esp
80103665:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010366b:	83 c0 10             	add    $0x10,%eax
8010366e:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
80103675:	89 c2                	mov    %eax,%edx
80103677:	a1 c4 42 11 80       	mov    0x801142c4,%eax
8010367c:	83 ec 08             	sub    $0x8,%esp
8010367f:	52                   	push   %edx
80103680:	50                   	push   %eax
80103681:	e8 30 cb ff ff       	call   801001b6 <bread>
80103686:	83 c4 10             	add    $0x10,%esp
80103689:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010368c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010368f:	8d 50 18             	lea    0x18(%eax),%edx
80103692:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103695:	83 c0 18             	add    $0x18,%eax
80103698:	83 ec 04             	sub    $0x4,%esp
8010369b:	68 00 02 00 00       	push   $0x200
801036a0:	52                   	push   %edx
801036a1:	50                   	push   %eax
801036a2:	e8 1d 39 00 00       	call   80106fc4 <memmove>
801036a7:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801036aa:	83 ec 0c             	sub    $0xc,%esp
801036ad:	ff 75 ec             	pushl  -0x14(%ebp)
801036b0:	e8 3a cb ff ff       	call   801001ef <bwrite>
801036b5:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801036b8:	83 ec 0c             	sub    $0xc,%esp
801036bb:	ff 75 f0             	pushl  -0x10(%ebp)
801036be:	e8 6b cb ff ff       	call   8010022e <brelse>
801036c3:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801036c6:	83 ec 0c             	sub    $0xc,%esp
801036c9:	ff 75 ec             	pushl  -0x14(%ebp)
801036cc:	e8 5d cb ff ff       	call   8010022e <brelse>
801036d1:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036d8:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801036dd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036e0:	0f 8f 5d ff ff ff    	jg     80103643 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801036e6:	90                   	nop
801036e7:	c9                   	leave  
801036e8:	c3                   	ret    

801036e9 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801036e9:	55                   	push   %ebp
801036ea:	89 e5                	mov    %esp,%ebp
801036ec:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801036ef:	a1 b4 42 11 80       	mov    0x801142b4,%eax
801036f4:	89 c2                	mov    %eax,%edx
801036f6:	a1 c4 42 11 80       	mov    0x801142c4,%eax
801036fb:	83 ec 08             	sub    $0x8,%esp
801036fe:	52                   	push   %edx
801036ff:	50                   	push   %eax
80103700:	e8 b1 ca ff ff       	call   801001b6 <bread>
80103705:	83 c4 10             	add    $0x10,%esp
80103708:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010370b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010370e:	83 c0 18             	add    $0x18,%eax
80103711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103714:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103717:	8b 00                	mov    (%eax),%eax
80103719:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  for (i = 0; i < log.lh.n; i++) {
8010371e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103725:	eb 1b                	jmp    80103742 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010372a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010372d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103731:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103734:	83 c2 10             	add    $0x10,%edx
80103737:	89 04 95 8c 42 11 80 	mov    %eax,-0x7feebd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010373e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103742:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103747:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010374a:	7f db                	jg     80103727 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010374c:	83 ec 0c             	sub    $0xc,%esp
8010374f:	ff 75 f0             	pushl  -0x10(%ebp)
80103752:	e8 d7 ca ff ff       	call   8010022e <brelse>
80103757:	83 c4 10             	add    $0x10,%esp
}
8010375a:	90                   	nop
8010375b:	c9                   	leave  
8010375c:	c3                   	ret    

8010375d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010375d:	55                   	push   %ebp
8010375e:	89 e5                	mov    %esp,%ebp
80103760:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103763:	a1 b4 42 11 80       	mov    0x801142b4,%eax
80103768:	89 c2                	mov    %eax,%edx
8010376a:	a1 c4 42 11 80       	mov    0x801142c4,%eax
8010376f:	83 ec 08             	sub    $0x8,%esp
80103772:	52                   	push   %edx
80103773:	50                   	push   %eax
80103774:	e8 3d ca ff ff       	call   801001b6 <bread>
80103779:	83 c4 10             	add    $0x10,%esp
8010377c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010377f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103782:	83 c0 18             	add    $0x18,%eax
80103785:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103788:	8b 15 c8 42 11 80    	mov    0x801142c8,%edx
8010378e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103791:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103793:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010379a:	eb 1b                	jmp    801037b7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010379c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010379f:	83 c0 10             	add    $0x10,%eax
801037a2:	8b 0c 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%ecx
801037a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037af:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801037b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037b7:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801037bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037bf:	7f db                	jg     8010379c <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801037c1:	83 ec 0c             	sub    $0xc,%esp
801037c4:	ff 75 f0             	pushl  -0x10(%ebp)
801037c7:	e8 23 ca ff ff       	call   801001ef <bwrite>
801037cc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801037cf:	83 ec 0c             	sub    $0xc,%esp
801037d2:	ff 75 f0             	pushl  -0x10(%ebp)
801037d5:	e8 54 ca ff ff       	call   8010022e <brelse>
801037da:	83 c4 10             	add    $0x10,%esp
}
801037dd:	90                   	nop
801037de:	c9                   	leave  
801037df:	c3                   	ret    

801037e0 <recover_from_log>:

static void
recover_from_log(void)
{
801037e0:	55                   	push   %ebp
801037e1:	89 e5                	mov    %esp,%ebp
801037e3:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801037e6:	e8 fe fe ff ff       	call   801036e9 <read_head>
  install_trans(); // if committed, copy from log to disk
801037eb:	e8 41 fe ff ff       	call   80103631 <install_trans>
  log.lh.n = 0;
801037f0:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
801037f7:	00 00 00 
  write_head(); // clear the log
801037fa:	e8 5e ff ff ff       	call   8010375d <write_head>
}
801037ff:	90                   	nop
80103800:	c9                   	leave  
80103801:	c3                   	ret    

80103802 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103802:	55                   	push   %ebp
80103803:	89 e5                	mov    %esp,%ebp
80103805:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103808:	83 ec 0c             	sub    $0xc,%esp
8010380b:	68 80 42 11 80       	push   $0x80114280
80103810:	e8 8d 34 00 00       	call   80106ca2 <acquire>
80103815:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103818:	a1 c0 42 11 80       	mov    0x801142c0,%eax
8010381d:	85 c0                	test   %eax,%eax
8010381f:	74 17                	je     80103838 <begin_op+0x36>
      sleep(&log, &log.lock);
80103821:	83 ec 08             	sub    $0x8,%esp
80103824:	68 80 42 11 80       	push   $0x80114280
80103829:	68 80 42 11 80       	push   $0x80114280
8010382e:	e8 5a 21 00 00       	call   8010598d <sleep>
80103833:	83 c4 10             	add    $0x10,%esp
80103836:	eb e0                	jmp    80103818 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103838:	8b 0d c8 42 11 80    	mov    0x801142c8,%ecx
8010383e:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103843:	8d 50 01             	lea    0x1(%eax),%edx
80103846:	89 d0                	mov    %edx,%eax
80103848:	c1 e0 02             	shl    $0x2,%eax
8010384b:	01 d0                	add    %edx,%eax
8010384d:	01 c0                	add    %eax,%eax
8010384f:	01 c8                	add    %ecx,%eax
80103851:	83 f8 1e             	cmp    $0x1e,%eax
80103854:	7e 17                	jle    8010386d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103856:	83 ec 08             	sub    $0x8,%esp
80103859:	68 80 42 11 80       	push   $0x80114280
8010385e:	68 80 42 11 80       	push   $0x80114280
80103863:	e8 25 21 00 00       	call   8010598d <sleep>
80103868:	83 c4 10             	add    $0x10,%esp
8010386b:	eb ab                	jmp    80103818 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010386d:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103872:	83 c0 01             	add    $0x1,%eax
80103875:	a3 bc 42 11 80       	mov    %eax,0x801142bc
      release(&log.lock);
8010387a:	83 ec 0c             	sub    $0xc,%esp
8010387d:	68 80 42 11 80       	push   $0x80114280
80103882:	e8 82 34 00 00       	call   80106d09 <release>
80103887:	83 c4 10             	add    $0x10,%esp
      break;
8010388a:	90                   	nop
    }
  }
}
8010388b:	90                   	nop
8010388c:	c9                   	leave  
8010388d:	c3                   	ret    

8010388e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010388e:	55                   	push   %ebp
8010388f:	89 e5                	mov    %esp,%ebp
80103891:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103894:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010389b:	83 ec 0c             	sub    $0xc,%esp
8010389e:	68 80 42 11 80       	push   $0x80114280
801038a3:	e8 fa 33 00 00       	call   80106ca2 <acquire>
801038a8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801038ab:	a1 bc 42 11 80       	mov    0x801142bc,%eax
801038b0:	83 e8 01             	sub    $0x1,%eax
801038b3:	a3 bc 42 11 80       	mov    %eax,0x801142bc
  if(log.committing)
801038b8:	a1 c0 42 11 80       	mov    0x801142c0,%eax
801038bd:	85 c0                	test   %eax,%eax
801038bf:	74 0d                	je     801038ce <end_op+0x40>
    panic("log.committing");
801038c1:	83 ec 0c             	sub    $0xc,%esp
801038c4:	68 fc a7 10 80       	push   $0x8010a7fc
801038c9:	e8 98 cc ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801038ce:	a1 bc 42 11 80       	mov    0x801142bc,%eax
801038d3:	85 c0                	test   %eax,%eax
801038d5:	75 13                	jne    801038ea <end_op+0x5c>
    do_commit = 1;
801038d7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801038de:	c7 05 c0 42 11 80 01 	movl   $0x1,0x801142c0
801038e5:	00 00 00 
801038e8:	eb 10                	jmp    801038fa <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	68 80 42 11 80       	push   $0x80114280
801038f2:	e8 a6 22 00 00       	call   80105b9d <wakeup>
801038f7:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801038fa:	83 ec 0c             	sub    $0xc,%esp
801038fd:	68 80 42 11 80       	push   $0x80114280
80103902:	e8 02 34 00 00       	call   80106d09 <release>
80103907:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010390a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010390e:	74 3f                	je     8010394f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103910:	e8 f5 00 00 00       	call   80103a0a <commit>
    acquire(&log.lock);
80103915:	83 ec 0c             	sub    $0xc,%esp
80103918:	68 80 42 11 80       	push   $0x80114280
8010391d:	e8 80 33 00 00       	call   80106ca2 <acquire>
80103922:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103925:	c7 05 c0 42 11 80 00 	movl   $0x0,0x801142c0
8010392c:	00 00 00 
    wakeup(&log);
8010392f:	83 ec 0c             	sub    $0xc,%esp
80103932:	68 80 42 11 80       	push   $0x80114280
80103937:	e8 61 22 00 00       	call   80105b9d <wakeup>
8010393c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	68 80 42 11 80       	push   $0x80114280
80103947:	e8 bd 33 00 00       	call   80106d09 <release>
8010394c:	83 c4 10             	add    $0x10,%esp
  }
}
8010394f:	90                   	nop
80103950:	c9                   	leave  
80103951:	c3                   	ret    

80103952 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
80103955:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103958:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010395f:	e9 95 00 00 00       	jmp    801039f9 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103964:	8b 15 b4 42 11 80    	mov    0x801142b4,%edx
8010396a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010396d:	01 d0                	add    %edx,%eax
8010396f:	83 c0 01             	add    $0x1,%eax
80103972:	89 c2                	mov    %eax,%edx
80103974:	a1 c4 42 11 80       	mov    0x801142c4,%eax
80103979:	83 ec 08             	sub    $0x8,%esp
8010397c:	52                   	push   %edx
8010397d:	50                   	push   %eax
8010397e:	e8 33 c8 ff ff       	call   801001b6 <bread>
80103983:	83 c4 10             	add    $0x10,%esp
80103986:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010398c:	83 c0 10             	add    $0x10,%eax
8010398f:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
80103996:	89 c2                	mov    %eax,%edx
80103998:	a1 c4 42 11 80       	mov    0x801142c4,%eax
8010399d:	83 ec 08             	sub    $0x8,%esp
801039a0:	52                   	push   %edx
801039a1:	50                   	push   %eax
801039a2:	e8 0f c8 ff ff       	call   801001b6 <bread>
801039a7:	83 c4 10             	add    $0x10,%esp
801039aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801039ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039b0:	8d 50 18             	lea    0x18(%eax),%edx
801039b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b6:	83 c0 18             	add    $0x18,%eax
801039b9:	83 ec 04             	sub    $0x4,%esp
801039bc:	68 00 02 00 00       	push   $0x200
801039c1:	52                   	push   %edx
801039c2:	50                   	push   %eax
801039c3:	e8 fc 35 00 00       	call   80106fc4 <memmove>
801039c8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801039cb:	83 ec 0c             	sub    $0xc,%esp
801039ce:	ff 75 f0             	pushl  -0x10(%ebp)
801039d1:	e8 19 c8 ff ff       	call   801001ef <bwrite>
801039d6:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801039d9:	83 ec 0c             	sub    $0xc,%esp
801039dc:	ff 75 ec             	pushl  -0x14(%ebp)
801039df:	e8 4a c8 ff ff       	call   8010022e <brelse>
801039e4:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801039e7:	83 ec 0c             	sub    $0xc,%esp
801039ea:	ff 75 f0             	pushl  -0x10(%ebp)
801039ed:	e8 3c c8 ff ff       	call   8010022e <brelse>
801039f2:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039f9:	a1 c8 42 11 80       	mov    0x801142c8,%eax
801039fe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a01:	0f 8f 5d ff ff ff    	jg     80103964 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103a07:	90                   	nop
80103a08:	c9                   	leave  
80103a09:	c3                   	ret    

80103a0a <commit>:

static void
commit()
{
80103a0a:	55                   	push   %ebp
80103a0b:	89 e5                	mov    %esp,%ebp
80103a0d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103a10:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103a15:	85 c0                	test   %eax,%eax
80103a17:	7e 1e                	jle    80103a37 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103a19:	e8 34 ff ff ff       	call   80103952 <write_log>
    write_head();    // Write header to disk -- the real commit
80103a1e:	e8 3a fd ff ff       	call   8010375d <write_head>
    install_trans(); // Now install writes to home locations
80103a23:	e8 09 fc ff ff       	call   80103631 <install_trans>
    log.lh.n = 0; 
80103a28:	c7 05 c8 42 11 80 00 	movl   $0x0,0x801142c8
80103a2f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103a32:	e8 26 fd ff ff       	call   8010375d <write_head>
  }
}
80103a37:	90                   	nop
80103a38:	c9                   	leave  
80103a39:	c3                   	ret    

80103a3a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103a3a:	55                   	push   %ebp
80103a3b:	89 e5                	mov    %esp,%ebp
80103a3d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103a40:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103a45:	83 f8 1d             	cmp    $0x1d,%eax
80103a48:	7f 12                	jg     80103a5c <log_write+0x22>
80103a4a:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103a4f:	8b 15 b8 42 11 80    	mov    0x801142b8,%edx
80103a55:	83 ea 01             	sub    $0x1,%edx
80103a58:	39 d0                	cmp    %edx,%eax
80103a5a:	7c 0d                	jl     80103a69 <log_write+0x2f>
    panic("too big a transaction");
80103a5c:	83 ec 0c             	sub    $0xc,%esp
80103a5f:	68 0b a8 10 80       	push   $0x8010a80b
80103a64:	e8 fd ca ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103a69:	a1 bc 42 11 80       	mov    0x801142bc,%eax
80103a6e:	85 c0                	test   %eax,%eax
80103a70:	7f 0d                	jg     80103a7f <log_write+0x45>
    panic("log_write outside of trans");
80103a72:	83 ec 0c             	sub    $0xc,%esp
80103a75:	68 21 a8 10 80       	push   $0x8010a821
80103a7a:	e8 e7 ca ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103a7f:	83 ec 0c             	sub    $0xc,%esp
80103a82:	68 80 42 11 80       	push   $0x80114280
80103a87:	e8 16 32 00 00       	call   80106ca2 <acquire>
80103a8c:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103a8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a96:	eb 1d                	jmp    80103ab5 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9b:	83 c0 10             	add    $0x10,%eax
80103a9e:	8b 04 85 8c 42 11 80 	mov    -0x7feebd74(,%eax,4),%eax
80103aa5:	89 c2                	mov    %eax,%edx
80103aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80103aaa:	8b 40 08             	mov    0x8(%eax),%eax
80103aad:	39 c2                	cmp    %eax,%edx
80103aaf:	74 10                	je     80103ac1 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103ab1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ab5:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103aba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103abd:	7f d9                	jg     80103a98 <log_write+0x5e>
80103abf:	eb 01                	jmp    80103ac2 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103ac1:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac5:	8b 40 08             	mov    0x8(%eax),%eax
80103ac8:	89 c2                	mov    %eax,%edx
80103aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acd:	83 c0 10             	add    $0x10,%eax
80103ad0:	89 14 85 8c 42 11 80 	mov    %edx,-0x7feebd74(,%eax,4)
  if (i == log.lh.n)
80103ad7:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103adc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103adf:	75 0d                	jne    80103aee <log_write+0xb4>
    log.lh.n++;
80103ae1:	a1 c8 42 11 80       	mov    0x801142c8,%eax
80103ae6:	83 c0 01             	add    $0x1,%eax
80103ae9:	a3 c8 42 11 80       	mov    %eax,0x801142c8
  b->flags |= B_DIRTY; // prevent eviction
80103aee:	8b 45 08             	mov    0x8(%ebp),%eax
80103af1:	8b 00                	mov    (%eax),%eax
80103af3:	83 c8 04             	or     $0x4,%eax
80103af6:	89 c2                	mov    %eax,%edx
80103af8:	8b 45 08             	mov    0x8(%ebp),%eax
80103afb:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103afd:	83 ec 0c             	sub    $0xc,%esp
80103b00:	68 80 42 11 80       	push   $0x80114280
80103b05:	e8 ff 31 00 00       	call   80106d09 <release>
80103b0a:	83 c4 10             	add    $0x10,%esp
}
80103b0d:	90                   	nop
80103b0e:	c9                   	leave  
80103b0f:	c3                   	ret    

80103b10 <v2p>:
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
80103b13:	8b 45 08             	mov    0x8(%ebp),%eax
80103b16:	05 00 00 00 80       	add    $0x80000000,%eax
80103b1b:	5d                   	pop    %ebp
80103b1c:	c3                   	ret    

80103b1d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103b1d:	55                   	push   %ebp
80103b1e:	89 e5                	mov    %esp,%ebp
80103b20:	8b 45 08             	mov    0x8(%ebp),%eax
80103b23:	05 00 00 00 80       	add    $0x80000000,%eax
80103b28:	5d                   	pop    %ebp
80103b29:	c3                   	ret    

80103b2a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103b2a:	55                   	push   %ebp
80103b2b:	89 e5                	mov    %esp,%ebp
80103b2d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b30:	8b 55 08             	mov    0x8(%ebp),%edx
80103b33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103b39:	f0 87 02             	lock xchg %eax,(%edx)
80103b3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103b3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b42:	c9                   	leave  
80103b43:	c3                   	ret    

80103b44 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103b44:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103b48:	83 e4 f0             	and    $0xfffffff0,%esp
80103b4b:	ff 71 fc             	pushl  -0x4(%ecx)
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	51                   	push   %ecx
80103b52:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103b55:	83 ec 08             	sub    $0x8,%esp
80103b58:	68 00 00 40 80       	push   $0x80400000
80103b5d:	68 3c 79 11 80       	push   $0x8011793c
80103b62:	e8 7d f2 ff ff       	call   80102de4 <kinit1>
80103b67:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103b6a:	e8 9b 62 00 00       	call   80109e0a <kvmalloc>
  mpinit();        // collect info about this machine
80103b6f:	e8 43 04 00 00       	call   80103fb7 <mpinit>
  lapicinit();
80103b74:	e8 ea f5 ff ff       	call   80103163 <lapicinit>
  seginit();       // set up segments
80103b79:	e8 35 5c 00 00       	call   801097b3 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103b7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103b84:	0f b6 00             	movzbl (%eax),%eax
80103b87:	0f b6 c0             	movzbl %al,%eax
80103b8a:	83 ec 08             	sub    $0x8,%esp
80103b8d:	50                   	push   %eax
80103b8e:	68 3c a8 10 80       	push   $0x8010a83c
80103b93:	e8 2e c8 ff ff       	call   801003c6 <cprintf>
80103b98:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103b9b:	e8 6d 06 00 00       	call   8010420d <picinit>
  ioapicinit();    // another interrupt controller
80103ba0:	e8 34 f1 ff ff       	call   80102cd9 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103ba5:	e8 19 d0 ff ff       	call   80100bc3 <consoleinit>
  uartinit();      // serial port
80103baa:	e8 60 4f 00 00       	call   80108b0f <uartinit>
  pinit();         // process table
80103baf:	e8 d0 0d 00 00       	call   80104984 <pinit>
  tvinit();        // trap vectors
80103bb4:	e8 2f 4b 00 00       	call   801086e8 <tvinit>
  binit();         // buffer cache
80103bb9:	e8 76 c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103bbe:	e8 5c d4 ff ff       	call   8010101f <fileinit>
  ideinit();       // disk
80103bc3:	e8 19 ed ff ff       	call   801028e1 <ideinit>
  if(!ismp)
80103bc8:	a1 64 43 11 80       	mov    0x80114364,%eax
80103bcd:	85 c0                	test   %eax,%eax
80103bcf:	75 05                	jne    80103bd6 <main+0x92>
    timerinit();   // uniprocessor timer
80103bd1:	e8 63 4a 00 00       	call   80108639 <timerinit>
  startothers();   // start other processors
80103bd6:	e8 7f 00 00 00       	call   80103c5a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103bdb:	83 ec 08             	sub    $0x8,%esp
80103bde:	68 00 00 00 8e       	push   $0x8e000000
80103be3:	68 00 00 40 80       	push   $0x80400000
80103be8:	e8 30 f2 ff ff       	call   80102e1d <kinit2>
80103bed:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103bf0:	e8 2a 0f 00 00       	call   80104b1f <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103bf5:	e8 1a 00 00 00       	call   80103c14 <mpmain>

80103bfa <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103bfa:	55                   	push   %ebp
80103bfb:	89 e5                	mov    %esp,%ebp
80103bfd:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103c00:	e8 1d 62 00 00       	call   80109e22 <switchkvm>
  seginit();
80103c05:	e8 a9 5b 00 00       	call   801097b3 <seginit>
  lapicinit();
80103c0a:	e8 54 f5 ff ff       	call   80103163 <lapicinit>
  mpmain();
80103c0f:	e8 00 00 00 00       	call   80103c14 <mpmain>

80103c14 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103c14:	55                   	push   %ebp
80103c15:	89 e5                	mov    %esp,%ebp
80103c17:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103c1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c20:	0f b6 00             	movzbl (%eax),%eax
80103c23:	0f b6 c0             	movzbl %al,%eax
80103c26:	83 ec 08             	sub    $0x8,%esp
80103c29:	50                   	push   %eax
80103c2a:	68 53 a8 10 80       	push   $0x8010a853
80103c2f:	e8 92 c7 ff ff       	call   801003c6 <cprintf>
80103c34:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103c37:	e8 0d 4c 00 00       	call   80108849 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103c3c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c42:	05 a8 00 00 00       	add    $0xa8,%eax
80103c47:	83 ec 08             	sub    $0x8,%esp
80103c4a:	6a 01                	push   $0x1
80103c4c:	50                   	push   %eax
80103c4d:	e8 d8 fe ff ff       	call   80103b2a <xchg>
80103c52:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103c55:	e8 c7 18 00 00       	call   80105521 <scheduler>

80103c5a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c5a:	55                   	push   %ebp
80103c5b:	89 e5                	mov    %esp,%ebp
80103c5d:	53                   	push   %ebx
80103c5e:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103c61:	68 00 70 00 00       	push   $0x7000
80103c66:	e8 b2 fe ff ff       	call   80103b1d <p2v>
80103c6b:	83 c4 04             	add    $0x4,%esp
80103c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c71:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c76:	83 ec 04             	sub    $0x4,%esp
80103c79:	50                   	push   %eax
80103c7a:	68 2c d5 10 80       	push   $0x8010d52c
80103c7f:	ff 75 f0             	pushl  -0x10(%ebp)
80103c82:	e8 3d 33 00 00       	call   80106fc4 <memmove>
80103c87:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103c8a:	c7 45 f4 80 43 11 80 	movl   $0x80114380,-0xc(%ebp)
80103c91:	e9 90 00 00 00       	jmp    80103d26 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103c96:	e8 e6 f5 ff ff       	call   80103281 <cpunum>
80103c9b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ca1:	05 80 43 11 80       	add    $0x80114380,%eax
80103ca6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ca9:	74 73                	je     80103d1e <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103cab:	e8 6b f2 ff ff       	call   80102f1b <kalloc>
80103cb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb6:	83 e8 04             	sub    $0x4,%eax
80103cb9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103cbc:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103cc2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc7:	83 e8 08             	sub    $0x8,%eax
80103cca:	c7 00 fa 3b 10 80    	movl   $0x80103bfa,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd3:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103cd6:	83 ec 0c             	sub    $0xc,%esp
80103cd9:	68 00 c0 10 80       	push   $0x8010c000
80103cde:	e8 2d fe ff ff       	call   80103b10 <v2p>
80103ce3:	83 c4 10             	add    $0x10,%esp
80103ce6:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103ce8:	83 ec 0c             	sub    $0xc,%esp
80103ceb:	ff 75 f0             	pushl  -0x10(%ebp)
80103cee:	e8 1d fe ff ff       	call   80103b10 <v2p>
80103cf3:	83 c4 10             	add    $0x10,%esp
80103cf6:	89 c2                	mov    %eax,%edx
80103cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfb:	0f b6 00             	movzbl (%eax),%eax
80103cfe:	0f b6 c0             	movzbl %al,%eax
80103d01:	83 ec 08             	sub    $0x8,%esp
80103d04:	52                   	push   %edx
80103d05:	50                   	push   %eax
80103d06:	e8 f0 f5 ff ff       	call   801032fb <lapicstartap>
80103d0b:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103d0e:	90                   	nop
80103d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d12:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103d18:	85 c0                	test   %eax,%eax
80103d1a:	74 f3                	je     80103d0f <startothers+0xb5>
80103d1c:	eb 01                	jmp    80103d1f <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103d1e:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103d1f:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103d26:	a1 60 49 11 80       	mov    0x80114960,%eax
80103d2b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d31:	05 80 43 11 80       	add    $0x80114380,%eax
80103d36:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d39:	0f 87 57 ff ff ff    	ja     80103c96 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103d3f:	90                   	nop
80103d40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d43:	c9                   	leave  
80103d44:	c3                   	ret    

80103d45 <p2v>:
80103d45:	55                   	push   %ebp
80103d46:	89 e5                	mov    %esp,%ebp
80103d48:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4b:	05 00 00 00 80       	add    $0x80000000,%eax
80103d50:	5d                   	pop    %ebp
80103d51:	c3                   	ret    

80103d52 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103d52:	55                   	push   %ebp
80103d53:	89 e5                	mov    %esp,%ebp
80103d55:	83 ec 14             	sub    $0x14,%esp
80103d58:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d5f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103d63:	89 c2                	mov    %eax,%edx
80103d65:	ec                   	in     (%dx),%al
80103d66:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103d69:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103d6d:	c9                   	leave  
80103d6e:	c3                   	ret    

80103d6f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d6f:	55                   	push   %ebp
80103d70:	89 e5                	mov    %esp,%ebp
80103d72:	83 ec 08             	sub    $0x8,%esp
80103d75:	8b 55 08             	mov    0x8(%ebp),%edx
80103d78:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d7b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d7f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d82:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d86:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d8a:	ee                   	out    %al,(%dx)
}
80103d8b:	90                   	nop
80103d8c:	c9                   	leave  
80103d8d:	c3                   	ret    

80103d8e <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103d8e:	55                   	push   %ebp
80103d8f:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103d91:	a1 64 d6 10 80       	mov    0x8010d664,%eax
80103d96:	89 c2                	mov    %eax,%edx
80103d98:	b8 80 43 11 80       	mov    $0x80114380,%eax
80103d9d:	29 c2                	sub    %eax,%edx
80103d9f:	89 d0                	mov    %edx,%eax
80103da1:	c1 f8 02             	sar    $0x2,%eax
80103da4:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103daa:	5d                   	pop    %ebp
80103dab:	c3                   	ret    

80103dac <sum>:

static uchar
sum(uchar *addr, int len)
{
80103dac:	55                   	push   %ebp
80103dad:	89 e5                	mov    %esp,%ebp
80103daf:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103db2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103db9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103dc0:	eb 15                	jmp    80103dd7 <sum+0x2b>
    sum += addr[i];
80103dc2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc8:	01 d0                	add    %edx,%eax
80103dca:	0f b6 00             	movzbl (%eax),%eax
80103dcd:	0f b6 c0             	movzbl %al,%eax
80103dd0:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103dd3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103dd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dda:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ddd:	7c e3                	jl     80103dc2 <sum+0x16>
    sum += addr[i];
  return sum;
80103ddf:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103de2:	c9                   	leave  
80103de3:	c3                   	ret    

80103de4 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103de4:	55                   	push   %ebp
80103de5:	89 e5                	mov    %esp,%ebp
80103de7:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103dea:	ff 75 08             	pushl  0x8(%ebp)
80103ded:	e8 53 ff ff ff       	call   80103d45 <p2v>
80103df2:	83 c4 04             	add    $0x4,%esp
80103df5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103df8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfe:	01 d0                	add    %edx,%eax
80103e00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e09:	eb 36                	jmp    80103e41 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103e0b:	83 ec 04             	sub    $0x4,%esp
80103e0e:	6a 04                	push   $0x4
80103e10:	68 64 a8 10 80       	push   $0x8010a864
80103e15:	ff 75 f4             	pushl  -0xc(%ebp)
80103e18:	e8 4f 31 00 00       	call   80106f6c <memcmp>
80103e1d:	83 c4 10             	add    $0x10,%esp
80103e20:	85 c0                	test   %eax,%eax
80103e22:	75 19                	jne    80103e3d <mpsearch1+0x59>
80103e24:	83 ec 08             	sub    $0x8,%esp
80103e27:	6a 10                	push   $0x10
80103e29:	ff 75 f4             	pushl  -0xc(%ebp)
80103e2c:	e8 7b ff ff ff       	call   80103dac <sum>
80103e31:	83 c4 10             	add    $0x10,%esp
80103e34:	84 c0                	test   %al,%al
80103e36:	75 05                	jne    80103e3d <mpsearch1+0x59>
      return (struct mp*)p;
80103e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3b:	eb 11                	jmp    80103e4e <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e3d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e44:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e47:	72 c2                	jb     80103e0b <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e4e:	c9                   	leave  
80103e4f:	c3                   	ret    

80103e50 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e50:	55                   	push   %ebp
80103e51:	89 e5                	mov    %esp,%ebp
80103e53:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e56:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e60:	83 c0 0f             	add    $0xf,%eax
80103e63:	0f b6 00             	movzbl (%eax),%eax
80103e66:	0f b6 c0             	movzbl %al,%eax
80103e69:	c1 e0 08             	shl    $0x8,%eax
80103e6c:	89 c2                	mov    %eax,%edx
80103e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e71:	83 c0 0e             	add    $0xe,%eax
80103e74:	0f b6 00             	movzbl (%eax),%eax
80103e77:	0f b6 c0             	movzbl %al,%eax
80103e7a:	09 d0                	or     %edx,%eax
80103e7c:	c1 e0 04             	shl    $0x4,%eax
80103e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e86:	74 21                	je     80103ea9 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103e88:	83 ec 08             	sub    $0x8,%esp
80103e8b:	68 00 04 00 00       	push   $0x400
80103e90:	ff 75 f0             	pushl  -0x10(%ebp)
80103e93:	e8 4c ff ff ff       	call   80103de4 <mpsearch1>
80103e98:	83 c4 10             	add    $0x10,%esp
80103e9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e9e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ea2:	74 51                	je     80103ef5 <mpsearch+0xa5>
      return mp;
80103ea4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ea7:	eb 61                	jmp    80103f0a <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eac:	83 c0 14             	add    $0x14,%eax
80103eaf:	0f b6 00             	movzbl (%eax),%eax
80103eb2:	0f b6 c0             	movzbl %al,%eax
80103eb5:	c1 e0 08             	shl    $0x8,%eax
80103eb8:	89 c2                	mov    %eax,%edx
80103eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ebd:	83 c0 13             	add    $0x13,%eax
80103ec0:	0f b6 00             	movzbl (%eax),%eax
80103ec3:	0f b6 c0             	movzbl %al,%eax
80103ec6:	09 d0                	or     %edx,%eax
80103ec8:	c1 e0 0a             	shl    $0xa,%eax
80103ecb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ed1:	2d 00 04 00 00       	sub    $0x400,%eax
80103ed6:	83 ec 08             	sub    $0x8,%esp
80103ed9:	68 00 04 00 00       	push   $0x400
80103ede:	50                   	push   %eax
80103edf:	e8 00 ff ff ff       	call   80103de4 <mpsearch1>
80103ee4:	83 c4 10             	add    $0x10,%esp
80103ee7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103eea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103eee:	74 05                	je     80103ef5 <mpsearch+0xa5>
      return mp;
80103ef0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef3:	eb 15                	jmp    80103f0a <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ef5:	83 ec 08             	sub    $0x8,%esp
80103ef8:	68 00 00 01 00       	push   $0x10000
80103efd:	68 00 00 0f 00       	push   $0xf0000
80103f02:	e8 dd fe ff ff       	call   80103de4 <mpsearch1>
80103f07:	83 c4 10             	add    $0x10,%esp
}
80103f0a:	c9                   	leave  
80103f0b:	c3                   	ret    

80103f0c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103f0c:	55                   	push   %ebp
80103f0d:	89 e5                	mov    %esp,%ebp
80103f0f:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103f12:	e8 39 ff ff ff       	call   80103e50 <mpsearch>
80103f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f1e:	74 0a                	je     80103f2a <mpconfig+0x1e>
80103f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f23:	8b 40 04             	mov    0x4(%eax),%eax
80103f26:	85 c0                	test   %eax,%eax
80103f28:	75 0a                	jne    80103f34 <mpconfig+0x28>
    return 0;
80103f2a:	b8 00 00 00 00       	mov    $0x0,%eax
80103f2f:	e9 81 00 00 00       	jmp    80103fb5 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f37:	8b 40 04             	mov    0x4(%eax),%eax
80103f3a:	83 ec 0c             	sub    $0xc,%esp
80103f3d:	50                   	push   %eax
80103f3e:	e8 02 fe ff ff       	call   80103d45 <p2v>
80103f43:	83 c4 10             	add    $0x10,%esp
80103f46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f49:	83 ec 04             	sub    $0x4,%esp
80103f4c:	6a 04                	push   $0x4
80103f4e:	68 69 a8 10 80       	push   $0x8010a869
80103f53:	ff 75 f0             	pushl  -0x10(%ebp)
80103f56:	e8 11 30 00 00       	call   80106f6c <memcmp>
80103f5b:	83 c4 10             	add    $0x10,%esp
80103f5e:	85 c0                	test   %eax,%eax
80103f60:	74 07                	je     80103f69 <mpconfig+0x5d>
    return 0;
80103f62:	b8 00 00 00 00       	mov    $0x0,%eax
80103f67:	eb 4c                	jmp    80103fb5 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f6c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f70:	3c 01                	cmp    $0x1,%al
80103f72:	74 12                	je     80103f86 <mpconfig+0x7a>
80103f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f77:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f7b:	3c 04                	cmp    $0x4,%al
80103f7d:	74 07                	je     80103f86 <mpconfig+0x7a>
    return 0;
80103f7f:	b8 00 00 00 00       	mov    $0x0,%eax
80103f84:	eb 2f                	jmp    80103fb5 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f89:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103f8d:	0f b7 c0             	movzwl %ax,%eax
80103f90:	83 ec 08             	sub    $0x8,%esp
80103f93:	50                   	push   %eax
80103f94:	ff 75 f0             	pushl  -0x10(%ebp)
80103f97:	e8 10 fe ff ff       	call   80103dac <sum>
80103f9c:	83 c4 10             	add    $0x10,%esp
80103f9f:	84 c0                	test   %al,%al
80103fa1:	74 07                	je     80103faa <mpconfig+0x9e>
    return 0;
80103fa3:	b8 00 00 00 00       	mov    $0x0,%eax
80103fa8:	eb 0b                	jmp    80103fb5 <mpconfig+0xa9>
  *pmp = mp;
80103faa:	8b 45 08             	mov    0x8(%ebp),%eax
80103fad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fb0:	89 10                	mov    %edx,(%eax)
  return conf;
80103fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103fb5:	c9                   	leave  
80103fb6:	c3                   	ret    

80103fb7 <mpinit>:

void
mpinit(void)
{
80103fb7:	55                   	push   %ebp
80103fb8:	89 e5                	mov    %esp,%ebp
80103fba:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103fbd:	c7 05 64 d6 10 80 80 	movl   $0x80114380,0x8010d664
80103fc4:	43 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103fc7:	83 ec 0c             	sub    $0xc,%esp
80103fca:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103fcd:	50                   	push   %eax
80103fce:	e8 39 ff ff ff       	call   80103f0c <mpconfig>
80103fd3:	83 c4 10             	add    $0x10,%esp
80103fd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103fd9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fdd:	0f 84 96 01 00 00    	je     80104179 <mpinit+0x1c2>
    return;
  ismp = 1;
80103fe3:	c7 05 64 43 11 80 01 	movl   $0x1,0x80114364
80103fea:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ff0:	8b 40 24             	mov    0x24(%eax),%eax
80103ff3:	a3 7c 42 11 80       	mov    %eax,0x8011427c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ffb:	83 c0 2c             	add    $0x2c,%eax
80103ffe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104004:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104008:	0f b7 d0             	movzwl %ax,%edx
8010400b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010400e:	01 d0                	add    %edx,%eax
80104010:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104013:	e9 f2 00 00 00       	jmp    8010410a <mpinit+0x153>
    switch(*p){
80104018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401b:	0f b6 00             	movzbl (%eax),%eax
8010401e:	0f b6 c0             	movzbl %al,%eax
80104021:	83 f8 04             	cmp    $0x4,%eax
80104024:	0f 87 bc 00 00 00    	ja     801040e6 <mpinit+0x12f>
8010402a:	8b 04 85 ac a8 10 80 	mov    -0x7fef5754(,%eax,4),%eax
80104031:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104036:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104039:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010403c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104040:	0f b6 d0             	movzbl %al,%edx
80104043:	a1 60 49 11 80       	mov    0x80114960,%eax
80104048:	39 c2                	cmp    %eax,%edx
8010404a:	74 2b                	je     80104077 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
8010404c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010404f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104053:	0f b6 d0             	movzbl %al,%edx
80104056:	a1 60 49 11 80       	mov    0x80114960,%eax
8010405b:	83 ec 04             	sub    $0x4,%esp
8010405e:	52                   	push   %edx
8010405f:	50                   	push   %eax
80104060:	68 6e a8 10 80       	push   $0x8010a86e
80104065:	e8 5c c3 ff ff       	call   801003c6 <cprintf>
8010406a:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
8010406d:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
80104074:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104077:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010407a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010407e:	0f b6 c0             	movzbl %al,%eax
80104081:	83 e0 02             	and    $0x2,%eax
80104084:	85 c0                	test   %eax,%eax
80104086:	74 15                	je     8010409d <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104088:	a1 60 49 11 80       	mov    0x80114960,%eax
8010408d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104093:	05 80 43 11 80       	add    $0x80114380,%eax
80104098:	a3 64 d6 10 80       	mov    %eax,0x8010d664
      cpus[ncpu].id = ncpu;
8010409d:	a1 60 49 11 80       	mov    0x80114960,%eax
801040a2:	8b 15 60 49 11 80    	mov    0x80114960,%edx
801040a8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801040ae:	05 80 43 11 80       	add    $0x80114380,%eax
801040b3:	88 10                	mov    %dl,(%eax)
      ncpu++;
801040b5:	a1 60 49 11 80       	mov    0x80114960,%eax
801040ba:	83 c0 01             	add    $0x1,%eax
801040bd:	a3 60 49 11 80       	mov    %eax,0x80114960
      p += sizeof(struct mpproc);
801040c2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801040c6:	eb 42                	jmp    8010410a <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801040ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801040d1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040d5:	a2 60 43 11 80       	mov    %al,0x80114360
      p += sizeof(struct mpioapic);
801040da:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040de:	eb 2a                	jmp    8010410a <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801040e0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040e4:	eb 24                	jmp    8010410a <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801040e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e9:	0f b6 00             	movzbl (%eax),%eax
801040ec:	0f b6 c0             	movzbl %al,%eax
801040ef:	83 ec 08             	sub    $0x8,%esp
801040f2:	50                   	push   %eax
801040f3:	68 8c a8 10 80       	push   $0x8010a88c
801040f8:	e8 c9 c2 ff ff       	call   801003c6 <cprintf>
801040fd:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104100:	c7 05 64 43 11 80 00 	movl   $0x0,0x80114364
80104107:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010410a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104110:	0f 82 02 ff ff ff    	jb     80104018 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104116:	a1 64 43 11 80       	mov    0x80114364,%eax
8010411b:	85 c0                	test   %eax,%eax
8010411d:	75 1d                	jne    8010413c <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
8010411f:	c7 05 60 49 11 80 01 	movl   $0x1,0x80114960
80104126:	00 00 00 
    lapic = 0;
80104129:	c7 05 7c 42 11 80 00 	movl   $0x0,0x8011427c
80104130:	00 00 00 
    ioapicid = 0;
80104133:	c6 05 60 43 11 80 00 	movb   $0x0,0x80114360
    return;
8010413a:	eb 3e                	jmp    8010417a <mpinit+0x1c3>
  }

  if(mp->imcrp){
8010413c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010413f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104143:	84 c0                	test   %al,%al
80104145:	74 33                	je     8010417a <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104147:	83 ec 08             	sub    $0x8,%esp
8010414a:	6a 70                	push   $0x70
8010414c:	6a 22                	push   $0x22
8010414e:	e8 1c fc ff ff       	call   80103d6f <outb>
80104153:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104156:	83 ec 0c             	sub    $0xc,%esp
80104159:	6a 23                	push   $0x23
8010415b:	e8 f2 fb ff ff       	call   80103d52 <inb>
80104160:	83 c4 10             	add    $0x10,%esp
80104163:	83 c8 01             	or     $0x1,%eax
80104166:	0f b6 c0             	movzbl %al,%eax
80104169:	83 ec 08             	sub    $0x8,%esp
8010416c:	50                   	push   %eax
8010416d:	6a 23                	push   $0x23
8010416f:	e8 fb fb ff ff       	call   80103d6f <outb>
80104174:	83 c4 10             	add    $0x10,%esp
80104177:	eb 01                	jmp    8010417a <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104179:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010417a:	c9                   	leave  
8010417b:	c3                   	ret    

8010417c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010417c:	55                   	push   %ebp
8010417d:	89 e5                	mov    %esp,%ebp
8010417f:	83 ec 08             	sub    $0x8,%esp
80104182:	8b 55 08             	mov    0x8(%ebp),%edx
80104185:	8b 45 0c             	mov    0xc(%ebp),%eax
80104188:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010418c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010418f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104193:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104197:	ee                   	out    %al,(%dx)
}
80104198:	90                   	nop
80104199:	c9                   	leave  
8010419a:	c3                   	ret    

8010419b <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
8010419b:	55                   	push   %ebp
8010419c:	89 e5                	mov    %esp,%ebp
8010419e:	83 ec 04             	sub    $0x4,%esp
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801041a8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041ac:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
801041b2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041b6:	0f b6 c0             	movzbl %al,%eax
801041b9:	50                   	push   %eax
801041ba:	6a 21                	push   $0x21
801041bc:	e8 bb ff ff ff       	call   8010417c <outb>
801041c1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
801041c4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041c8:	66 c1 e8 08          	shr    $0x8,%ax
801041cc:	0f b6 c0             	movzbl %al,%eax
801041cf:	50                   	push   %eax
801041d0:	68 a1 00 00 00       	push   $0xa1
801041d5:	e8 a2 ff ff ff       	call   8010417c <outb>
801041da:	83 c4 08             	add    $0x8,%esp
}
801041dd:	90                   	nop
801041de:	c9                   	leave  
801041df:	c3                   	ret    

801041e0 <picenable>:

void
picenable(int irq)
{
801041e0:	55                   	push   %ebp
801041e1:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
801041e3:	8b 45 08             	mov    0x8(%ebp),%eax
801041e6:	ba 01 00 00 00       	mov    $0x1,%edx
801041eb:	89 c1                	mov    %eax,%ecx
801041ed:	d3 e2                	shl    %cl,%edx
801041ef:	89 d0                	mov    %edx,%eax
801041f1:	f7 d0                	not    %eax
801041f3:	89 c2                	mov    %eax,%edx
801041f5:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801041fc:	21 d0                	and    %edx,%eax
801041fe:	0f b7 c0             	movzwl %ax,%eax
80104201:	50                   	push   %eax
80104202:	e8 94 ff ff ff       	call   8010419b <picsetmask>
80104207:	83 c4 04             	add    $0x4,%esp
}
8010420a:	90                   	nop
8010420b:	c9                   	leave  
8010420c:	c3                   	ret    

8010420d <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010420d:	55                   	push   %ebp
8010420e:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104210:	68 ff 00 00 00       	push   $0xff
80104215:	6a 21                	push   $0x21
80104217:	e8 60 ff ff ff       	call   8010417c <outb>
8010421c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010421f:	68 ff 00 00 00       	push   $0xff
80104224:	68 a1 00 00 00       	push   $0xa1
80104229:	e8 4e ff ff ff       	call   8010417c <outb>
8010422e:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104231:	6a 11                	push   $0x11
80104233:	6a 20                	push   $0x20
80104235:	e8 42 ff ff ff       	call   8010417c <outb>
8010423a:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010423d:	6a 20                	push   $0x20
8010423f:	6a 21                	push   $0x21
80104241:	e8 36 ff ff ff       	call   8010417c <outb>
80104246:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104249:	6a 04                	push   $0x4
8010424b:	6a 21                	push   $0x21
8010424d:	e8 2a ff ff ff       	call   8010417c <outb>
80104252:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104255:	6a 03                	push   $0x3
80104257:	6a 21                	push   $0x21
80104259:	e8 1e ff ff ff       	call   8010417c <outb>
8010425e:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104261:	6a 11                	push   $0x11
80104263:	68 a0 00 00 00       	push   $0xa0
80104268:	e8 0f ff ff ff       	call   8010417c <outb>
8010426d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104270:	6a 28                	push   $0x28
80104272:	68 a1 00 00 00       	push   $0xa1
80104277:	e8 00 ff ff ff       	call   8010417c <outb>
8010427c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010427f:	6a 02                	push   $0x2
80104281:	68 a1 00 00 00       	push   $0xa1
80104286:	e8 f1 fe ff ff       	call   8010417c <outb>
8010428b:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010428e:	6a 03                	push   $0x3
80104290:	68 a1 00 00 00       	push   $0xa1
80104295:	e8 e2 fe ff ff       	call   8010417c <outb>
8010429a:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010429d:	6a 68                	push   $0x68
8010429f:	6a 20                	push   $0x20
801042a1:	e8 d6 fe ff ff       	call   8010417c <outb>
801042a6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801042a9:	6a 0a                	push   $0xa
801042ab:	6a 20                	push   $0x20
801042ad:	e8 ca fe ff ff       	call   8010417c <outb>
801042b2:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801042b5:	6a 68                	push   $0x68
801042b7:	68 a0 00 00 00       	push   $0xa0
801042bc:	e8 bb fe ff ff       	call   8010417c <outb>
801042c1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801042c4:	6a 0a                	push   $0xa
801042c6:	68 a0 00 00 00       	push   $0xa0
801042cb:	e8 ac fe ff ff       	call   8010417c <outb>
801042d0:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801042d3:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801042da:	66 83 f8 ff          	cmp    $0xffff,%ax
801042de:	74 13                	je     801042f3 <picinit+0xe6>
    picsetmask(irqmask);
801042e0:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801042e7:	0f b7 c0             	movzwl %ax,%eax
801042ea:	50                   	push   %eax
801042eb:	e8 ab fe ff ff       	call   8010419b <picsetmask>
801042f0:	83 c4 04             	add    $0x4,%esp
}
801042f3:	90                   	nop
801042f4:	c9                   	leave  
801042f5:	c3                   	ret    

801042f6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801042f6:	55                   	push   %ebp
801042f7:	89 e5                	mov    %esp,%ebp
801042f9:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801042fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104303:	8b 45 0c             	mov    0xc(%ebp),%eax
80104306:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010430c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010430f:	8b 10                	mov    (%eax),%edx
80104311:	8b 45 08             	mov    0x8(%ebp),%eax
80104314:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104316:	e8 22 cd ff ff       	call   8010103d <filealloc>
8010431b:	89 c2                	mov    %eax,%edx
8010431d:	8b 45 08             	mov    0x8(%ebp),%eax
80104320:	89 10                	mov    %edx,(%eax)
80104322:	8b 45 08             	mov    0x8(%ebp),%eax
80104325:	8b 00                	mov    (%eax),%eax
80104327:	85 c0                	test   %eax,%eax
80104329:	0f 84 cb 00 00 00    	je     801043fa <pipealloc+0x104>
8010432f:	e8 09 cd ff ff       	call   8010103d <filealloc>
80104334:	89 c2                	mov    %eax,%edx
80104336:	8b 45 0c             	mov    0xc(%ebp),%eax
80104339:	89 10                	mov    %edx,(%eax)
8010433b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010433e:	8b 00                	mov    (%eax),%eax
80104340:	85 c0                	test   %eax,%eax
80104342:	0f 84 b2 00 00 00    	je     801043fa <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104348:	e8 ce eb ff ff       	call   80102f1b <kalloc>
8010434d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104350:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104354:	0f 84 9f 00 00 00    	je     801043f9 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010435a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435d:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104364:	00 00 00 
  p->writeopen = 1;
80104367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436a:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104371:	00 00 00 
  p->nwrite = 0;
80104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104377:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010437e:	00 00 00 
  p->nread = 0;
80104381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104384:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010438b:	00 00 00 
  initlock(&p->lock, "pipe");
8010438e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104391:	83 ec 08             	sub    $0x8,%esp
80104394:	68 c0 a8 10 80       	push   $0x8010a8c0
80104399:	50                   	push   %eax
8010439a:	e8 e1 28 00 00       	call   80106c80 <initlock>
8010439f:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801043a2:	8b 45 08             	mov    0x8(%ebp),%eax
801043a5:	8b 00                	mov    (%eax),%eax
801043a7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801043ad:	8b 45 08             	mov    0x8(%ebp),%eax
801043b0:	8b 00                	mov    (%eax),%eax
801043b2:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801043b6:	8b 45 08             	mov    0x8(%ebp),%eax
801043b9:	8b 00                	mov    (%eax),%eax
801043bb:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801043bf:	8b 45 08             	mov    0x8(%ebp),%eax
801043c2:	8b 00                	mov    (%eax),%eax
801043c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043c7:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801043ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801043cd:	8b 00                	mov    (%eax),%eax
801043cf:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801043d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801043d8:	8b 00                	mov    (%eax),%eax
801043da:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801043de:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e1:	8b 00                	mov    (%eax),%eax
801043e3:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801043e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801043ea:	8b 00                	mov    (%eax),%eax
801043ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ef:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801043f2:	b8 00 00 00 00       	mov    $0x0,%eax
801043f7:	eb 4e                	jmp    80104447 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801043f9:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801043fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043fe:	74 0e                	je     8010440e <pipealloc+0x118>
    kfree((char*)p);
80104400:	83 ec 0c             	sub    $0xc,%esp
80104403:	ff 75 f4             	pushl  -0xc(%ebp)
80104406:	e8 73 ea ff ff       	call   80102e7e <kfree>
8010440b:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010440e:	8b 45 08             	mov    0x8(%ebp),%eax
80104411:	8b 00                	mov    (%eax),%eax
80104413:	85 c0                	test   %eax,%eax
80104415:	74 11                	je     80104428 <pipealloc+0x132>
    fileclose(*f0);
80104417:	8b 45 08             	mov    0x8(%ebp),%eax
8010441a:	8b 00                	mov    (%eax),%eax
8010441c:	83 ec 0c             	sub    $0xc,%esp
8010441f:	50                   	push   %eax
80104420:	e8 d6 cc ff ff       	call   801010fb <fileclose>
80104425:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104428:	8b 45 0c             	mov    0xc(%ebp),%eax
8010442b:	8b 00                	mov    (%eax),%eax
8010442d:	85 c0                	test   %eax,%eax
8010442f:	74 11                	je     80104442 <pipealloc+0x14c>
    fileclose(*f1);
80104431:	8b 45 0c             	mov    0xc(%ebp),%eax
80104434:	8b 00                	mov    (%eax),%eax
80104436:	83 ec 0c             	sub    $0xc,%esp
80104439:	50                   	push   %eax
8010443a:	e8 bc cc ff ff       	call   801010fb <fileclose>
8010443f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104442:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104447:	c9                   	leave  
80104448:	c3                   	ret    

80104449 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104449:	55                   	push   %ebp
8010444a:	89 e5                	mov    %esp,%ebp
8010444c:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010444f:	8b 45 08             	mov    0x8(%ebp),%eax
80104452:	83 ec 0c             	sub    $0xc,%esp
80104455:	50                   	push   %eax
80104456:	e8 47 28 00 00       	call   80106ca2 <acquire>
8010445b:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010445e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104462:	74 23                	je     80104487 <pipeclose+0x3e>
    p->writeopen = 0;
80104464:	8b 45 08             	mov    0x8(%ebp),%eax
80104467:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010446e:	00 00 00 
    wakeup(&p->nread);
80104471:	8b 45 08             	mov    0x8(%ebp),%eax
80104474:	05 34 02 00 00       	add    $0x234,%eax
80104479:	83 ec 0c             	sub    $0xc,%esp
8010447c:	50                   	push   %eax
8010447d:	e8 1b 17 00 00       	call   80105b9d <wakeup>
80104482:	83 c4 10             	add    $0x10,%esp
80104485:	eb 21                	jmp    801044a8 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104487:	8b 45 08             	mov    0x8(%ebp),%eax
8010448a:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104491:	00 00 00 
    wakeup(&p->nwrite);
80104494:	8b 45 08             	mov    0x8(%ebp),%eax
80104497:	05 38 02 00 00       	add    $0x238,%eax
8010449c:	83 ec 0c             	sub    $0xc,%esp
8010449f:	50                   	push   %eax
801044a0:	e8 f8 16 00 00       	call   80105b9d <wakeup>
801044a5:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801044a8:	8b 45 08             	mov    0x8(%ebp),%eax
801044ab:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801044b1:	85 c0                	test   %eax,%eax
801044b3:	75 2c                	jne    801044e1 <pipeclose+0x98>
801044b5:	8b 45 08             	mov    0x8(%ebp),%eax
801044b8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801044be:	85 c0                	test   %eax,%eax
801044c0:	75 1f                	jne    801044e1 <pipeclose+0x98>
    release(&p->lock);
801044c2:	8b 45 08             	mov    0x8(%ebp),%eax
801044c5:	83 ec 0c             	sub    $0xc,%esp
801044c8:	50                   	push   %eax
801044c9:	e8 3b 28 00 00       	call   80106d09 <release>
801044ce:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801044d1:	83 ec 0c             	sub    $0xc,%esp
801044d4:	ff 75 08             	pushl  0x8(%ebp)
801044d7:	e8 a2 e9 ff ff       	call   80102e7e <kfree>
801044dc:	83 c4 10             	add    $0x10,%esp
801044df:	eb 0f                	jmp    801044f0 <pipeclose+0xa7>
  } else
    release(&p->lock);
801044e1:	8b 45 08             	mov    0x8(%ebp),%eax
801044e4:	83 ec 0c             	sub    $0xc,%esp
801044e7:	50                   	push   %eax
801044e8:	e8 1c 28 00 00       	call   80106d09 <release>
801044ed:	83 c4 10             	add    $0x10,%esp
}
801044f0:	90                   	nop
801044f1:	c9                   	leave  
801044f2:	c3                   	ret    

801044f3 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801044f3:	55                   	push   %ebp
801044f4:	89 e5                	mov    %esp,%ebp
801044f6:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801044f9:	8b 45 08             	mov    0x8(%ebp),%eax
801044fc:	83 ec 0c             	sub    $0xc,%esp
801044ff:	50                   	push   %eax
80104500:	e8 9d 27 00 00       	call   80106ca2 <acquire>
80104505:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104508:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010450f:	e9 ad 00 00 00       	jmp    801045c1 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104514:	8b 45 08             	mov    0x8(%ebp),%eax
80104517:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010451d:	85 c0                	test   %eax,%eax
8010451f:	74 0d                	je     8010452e <pipewrite+0x3b>
80104521:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104527:	8b 40 24             	mov    0x24(%eax),%eax
8010452a:	85 c0                	test   %eax,%eax
8010452c:	74 19                	je     80104547 <pipewrite+0x54>
        release(&p->lock);
8010452e:	8b 45 08             	mov    0x8(%ebp),%eax
80104531:	83 ec 0c             	sub    $0xc,%esp
80104534:	50                   	push   %eax
80104535:	e8 cf 27 00 00       	call   80106d09 <release>
8010453a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010453d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104542:	e9 a8 00 00 00       	jmp    801045ef <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104547:	8b 45 08             	mov    0x8(%ebp),%eax
8010454a:	05 34 02 00 00       	add    $0x234,%eax
8010454f:	83 ec 0c             	sub    $0xc,%esp
80104552:	50                   	push   %eax
80104553:	e8 45 16 00 00       	call   80105b9d <wakeup>
80104558:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010455b:	8b 45 08             	mov    0x8(%ebp),%eax
8010455e:	8b 55 08             	mov    0x8(%ebp),%edx
80104561:	81 c2 38 02 00 00    	add    $0x238,%edx
80104567:	83 ec 08             	sub    $0x8,%esp
8010456a:	50                   	push   %eax
8010456b:	52                   	push   %edx
8010456c:	e8 1c 14 00 00       	call   8010598d <sleep>
80104571:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104574:	8b 45 08             	mov    0x8(%ebp),%eax
80104577:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010457d:	8b 45 08             	mov    0x8(%ebp),%eax
80104580:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104586:	05 00 02 00 00       	add    $0x200,%eax
8010458b:	39 c2                	cmp    %eax,%edx
8010458d:	74 85                	je     80104514 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010458f:	8b 45 08             	mov    0x8(%ebp),%eax
80104592:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104598:	8d 48 01             	lea    0x1(%eax),%ecx
8010459b:	8b 55 08             	mov    0x8(%ebp),%edx
8010459e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801045a4:	25 ff 01 00 00       	and    $0x1ff,%eax
801045a9:	89 c1                	mov    %eax,%ecx
801045ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801045b1:	01 d0                	add    %edx,%eax
801045b3:	0f b6 10             	movzbl (%eax),%edx
801045b6:	8b 45 08             	mov    0x8(%ebp),%eax
801045b9:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801045bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c4:	3b 45 10             	cmp    0x10(%ebp),%eax
801045c7:	7c ab                	jl     80104574 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801045c9:	8b 45 08             	mov    0x8(%ebp),%eax
801045cc:	05 34 02 00 00       	add    $0x234,%eax
801045d1:	83 ec 0c             	sub    $0xc,%esp
801045d4:	50                   	push   %eax
801045d5:	e8 c3 15 00 00       	call   80105b9d <wakeup>
801045da:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801045dd:	8b 45 08             	mov    0x8(%ebp),%eax
801045e0:	83 ec 0c             	sub    $0xc,%esp
801045e3:	50                   	push   %eax
801045e4:	e8 20 27 00 00       	call   80106d09 <release>
801045e9:	83 c4 10             	add    $0x10,%esp
  return n;
801045ec:	8b 45 10             	mov    0x10(%ebp),%eax
}
801045ef:	c9                   	leave  
801045f0:	c3                   	ret    

801045f1 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801045f1:	55                   	push   %ebp
801045f2:	89 e5                	mov    %esp,%ebp
801045f4:	53                   	push   %ebx
801045f5:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801045f8:	8b 45 08             	mov    0x8(%ebp),%eax
801045fb:	83 ec 0c             	sub    $0xc,%esp
801045fe:	50                   	push   %eax
801045ff:	e8 9e 26 00 00       	call   80106ca2 <acquire>
80104604:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104607:	eb 3f                	jmp    80104648 <piperead+0x57>
    if(proc->killed){
80104609:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460f:	8b 40 24             	mov    0x24(%eax),%eax
80104612:	85 c0                	test   %eax,%eax
80104614:	74 19                	je     8010462f <piperead+0x3e>
      release(&p->lock);
80104616:	8b 45 08             	mov    0x8(%ebp),%eax
80104619:	83 ec 0c             	sub    $0xc,%esp
8010461c:	50                   	push   %eax
8010461d:	e8 e7 26 00 00       	call   80106d09 <release>
80104622:	83 c4 10             	add    $0x10,%esp
      return -1;
80104625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462a:	e9 bf 00 00 00       	jmp    801046ee <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010462f:	8b 45 08             	mov    0x8(%ebp),%eax
80104632:	8b 55 08             	mov    0x8(%ebp),%edx
80104635:	81 c2 34 02 00 00    	add    $0x234,%edx
8010463b:	83 ec 08             	sub    $0x8,%esp
8010463e:	50                   	push   %eax
8010463f:	52                   	push   %edx
80104640:	e8 48 13 00 00       	call   8010598d <sleep>
80104645:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104648:	8b 45 08             	mov    0x8(%ebp),%eax
8010464b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104651:	8b 45 08             	mov    0x8(%ebp),%eax
80104654:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010465a:	39 c2                	cmp    %eax,%edx
8010465c:	75 0d                	jne    8010466b <piperead+0x7a>
8010465e:	8b 45 08             	mov    0x8(%ebp),%eax
80104661:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104667:	85 c0                	test   %eax,%eax
80104669:	75 9e                	jne    80104609 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010466b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104672:	eb 49                	jmp    801046bd <piperead+0xcc>
    if(p->nread == p->nwrite)
80104674:	8b 45 08             	mov    0x8(%ebp),%eax
80104677:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010467d:	8b 45 08             	mov    0x8(%ebp),%eax
80104680:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104686:	39 c2                	cmp    %eax,%edx
80104688:	74 3d                	je     801046c7 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010468a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010468d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104690:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104693:	8b 45 08             	mov    0x8(%ebp),%eax
80104696:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010469c:	8d 48 01             	lea    0x1(%eax),%ecx
8010469f:	8b 55 08             	mov    0x8(%ebp),%edx
801046a2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801046a8:	25 ff 01 00 00       	and    $0x1ff,%eax
801046ad:	89 c2                	mov    %eax,%edx
801046af:	8b 45 08             	mov    0x8(%ebp),%eax
801046b2:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801046b7:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801046b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801046c3:	7c af                	jl     80104674 <piperead+0x83>
801046c5:	eb 01                	jmp    801046c8 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801046c7:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801046c8:	8b 45 08             	mov    0x8(%ebp),%eax
801046cb:	05 38 02 00 00       	add    $0x238,%eax
801046d0:	83 ec 0c             	sub    $0xc,%esp
801046d3:	50                   	push   %eax
801046d4:	e8 c4 14 00 00       	call   80105b9d <wakeup>
801046d9:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801046dc:	8b 45 08             	mov    0x8(%ebp),%eax
801046df:	83 ec 0c             	sub    $0xc,%esp
801046e2:	50                   	push   %eax
801046e3:	e8 21 26 00 00       	call   80106d09 <release>
801046e8:	83 c4 10             	add    $0x10,%esp
  return i;
801046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046f1:	c9                   	leave  
801046f2:	c3                   	ret    

801046f3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801046f3:	55                   	push   %ebp
801046f4:	89 e5                	mov    %esp,%ebp
801046f6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046f9:	9c                   	pushf  
801046fa:	58                   	pop    %eax
801046fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104701:	c9                   	leave  
80104702:	c3                   	ret    

80104703 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104703:	55                   	push   %ebp
80104704:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104706:	fb                   	sti    
}
80104707:	90                   	nop
80104708:	5d                   	pop    %ebp
80104709:	c3                   	ret    

8010470a <assertStateFree>:

#ifdef CS333_P3P4
//Helper functions

static void
assertStateFree(struct proc* p){
8010470a:	55                   	push   %ebp
8010470b:	89 e5                	mov    %esp,%ebp
8010470d:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != UNUSED)
80104710:	8b 45 08             	mov    0x8(%ebp),%eax
80104713:	8b 40 0c             	mov    0xc(%eax),%eax
80104716:	85 c0                	test   %eax,%eax
80104718:	74 0d                	je     80104727 <assertStateFree+0x1d>
	panic("Process not in an UNUSED state");
8010471a:	83 ec 0c             	sub    $0xc,%esp
8010471d:	68 c8 a8 10 80       	push   $0x8010a8c8
80104722:	e8 3f be ff ff       	call   80100566 <panic>
}
80104727:	90                   	nop
80104728:	c9                   	leave  
80104729:	c3                   	ret    

8010472a <assertStateZombie>:
static void
assertStateZombie(struct proc* p){
8010472a:	55                   	push   %ebp
8010472b:	89 e5                	mov    %esp,%ebp
8010472d:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != ZOMBIE)
80104730:	8b 45 08             	mov    0x8(%ebp),%eax
80104733:	8b 40 0c             	mov    0xc(%eax),%eax
80104736:	83 f8 05             	cmp    $0x5,%eax
80104739:	74 0d                	je     80104748 <assertStateZombie+0x1e>
	panic("Process not in a ZOMBIE state");
8010473b:	83 ec 0c             	sub    $0xc,%esp
8010473e:	68 e7 a8 10 80       	push   $0x8010a8e7
80104743:	e8 1e be ff ff       	call   80100566 <panic>
}
80104748:	90                   	nop
80104749:	c9                   	leave  
8010474a:	c3                   	ret    

8010474b <assertStateEmbryo>:
static void
assertStateEmbryo(struct proc* p){
8010474b:	55                   	push   %ebp
8010474c:	89 e5                	mov    %esp,%ebp
8010474e:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != EMBRYO)
80104751:	8b 45 08             	mov    0x8(%ebp),%eax
80104754:	8b 40 0c             	mov    0xc(%eax),%eax
80104757:	83 f8 01             	cmp    $0x1,%eax
8010475a:	74 0d                	je     80104769 <assertStateEmbryo+0x1e>
	panic("Process not in a EMBRYO state");
8010475c:	83 ec 0c             	sub    $0xc,%esp
8010475f:	68 05 a9 10 80       	push   $0x8010a905
80104764:	e8 fd bd ff ff       	call   80100566 <panic>
}
80104769:	90                   	nop
8010476a:	c9                   	leave  
8010476b:	c3                   	ret    

8010476c <assertStateRunning>:
static void
assertStateRunning(struct proc* p){
8010476c:	55                   	push   %ebp
8010476d:	89 e5                	mov    %esp,%ebp
8010476f:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != RUNNING)
80104772:	8b 45 08             	mov    0x8(%ebp),%eax
80104775:	8b 40 0c             	mov    0xc(%eax),%eax
80104778:	83 f8 04             	cmp    $0x4,%eax
8010477b:	74 0d                	je     8010478a <assertStateRunning+0x1e>
	panic("Process not in a RUNNING state");
8010477d:	83 ec 0c             	sub    $0xc,%esp
80104780:	68 24 a9 10 80       	push   $0x8010a924
80104785:	e8 dc bd ff ff       	call   80100566 <panic>
}
8010478a:	90                   	nop
8010478b:	c9                   	leave  
8010478c:	c3                   	ret    

8010478d <assertStateSleep>:
static void
assertStateSleep(struct proc* p){
8010478d:	55                   	push   %ebp
8010478e:	89 e5                	mov    %esp,%ebp
80104790:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != SLEEPING)
80104793:	8b 45 08             	mov    0x8(%ebp),%eax
80104796:	8b 40 0c             	mov    0xc(%eax),%eax
80104799:	83 f8 02             	cmp    $0x2,%eax
8010479c:	74 0d                	je     801047ab <assertStateSleep+0x1e>
	panic("Process not in a SLEEPING state");
8010479e:	83 ec 0c             	sub    $0xc,%esp
801047a1:	68 44 a9 10 80       	push   $0x8010a944
801047a6:	e8 bb bd ff ff       	call   80100566 <panic>
}
801047ab:	90                   	nop
801047ac:	c9                   	leave  
801047ad:	c3                   	ret    

801047ae <assertStateReady>:
static void
assertStateReady(struct proc* p){
801047ae:	55                   	push   %ebp
801047af:	89 e5                	mov    %esp,%ebp
801047b1:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != RUNNABLE)
801047b4:	8b 45 08             	mov    0x8(%ebp),%eax
801047b7:	8b 40 0c             	mov    0xc(%eax),%eax
801047ba:	83 f8 03             	cmp    $0x3,%eax
801047bd:	74 0d                	je     801047cc <assertStateReady+0x1e>
	panic("Process not in a RUNNABLE state");
801047bf:	83 ec 0c             	sub    $0xc,%esp
801047c2:	68 64 a9 10 80       	push   $0x8010a964
801047c7:	e8 9a bd ff ff       	call   80100566 <panic>
}
801047cc:	90                   	nop
801047cd:	c9                   	leave  
801047ce:	c3                   	ret    

801047cf <addToStateListEnd>:


static int
addToStateListEnd(struct proc** sList, struct proc* p){
801047cf:	55                   	push   %ebp
801047d0:	89 e5                	mov    %esp,%ebp
801047d2:	83 ec 18             	sub    $0x18,%esp
    if(!holding(&ptable.lock)){
801047d5:	83 ec 0c             	sub    $0xc,%esp
801047d8:	68 80 49 11 80       	push   $0x80114980
801047dd:	e8 f3 25 00 00       	call   80106dd5 <holding>
801047e2:	83 c4 10             	add    $0x10,%esp
801047e5:	85 c0                	test   %eax,%eax
801047e7:	75 0d                	jne    801047f6 <addToStateListEnd+0x27>
	panic("Not holding the lock!");
801047e9:	83 ec 0c             	sub    $0xc,%esp
801047ec:	68 84 a9 10 80       	push   $0x8010a984
801047f1:	e8 70 bd ff ff       	call   80100566 <panic>
    }

    struct proc *current = *sList;
801047f6:	8b 45 08             	mov    0x8(%ebp),%eax
801047f9:	8b 00                	mov    (%eax),%eax
801047fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(!current){
801047fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104802:	75 28                	jne    8010482c <addToStateListEnd+0x5d>
	*sList = p;
80104804:	8b 45 08             	mov    0x8(%ebp),%eax
80104807:	8b 55 0c             	mov    0xc(%ebp),%edx
8010480a:	89 10                	mov    %edx,(%eax)
	p -> next = 0;
8010480c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010480f:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104816:	00 00 00 
	return 0;
80104819:	b8 00 00 00 00       	mov    $0x0,%eax
8010481e:	eb 37                	jmp    80104857 <addToStateListEnd+0x88>
    }
    while(current -> next)
	current = current -> next;
80104820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104823:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104829:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!current){
	*sList = p;
	p -> next = 0;
	return 0;
    }
    while(current -> next)
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104835:	85 c0                	test   %eax,%eax
80104837:	75 e7                	jne    80104820 <addToStateListEnd+0x51>
	current = current -> next;
    
    current -> next = p;
80104839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010483f:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)

    p -> next = 0;
80104845:	8b 45 0c             	mov    0xc(%ebp),%eax
80104848:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010484f:	00 00 00 

    return 0;
80104852:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104857:	c9                   	leave  
80104858:	c3                   	ret    

80104859 <removeFromStateListHead>:

static int
removeFromStateListHead(struct proc** sList, struct proc* p){
80104859:	55                   	push   %ebp
8010485a:	89 e5                	mov    %esp,%ebp
8010485c:	83 ec 18             	sub    $0x18,%esp
    if(!holding(&ptable.lock)){
8010485f:	83 ec 0c             	sub    $0xc,%esp
80104862:	68 80 49 11 80       	push   $0x80114980
80104867:	e8 69 25 00 00       	call   80106dd5 <holding>
8010486c:	83 c4 10             	add    $0x10,%esp
8010486f:	85 c0                	test   %eax,%eax
80104871:	75 0d                	jne    80104880 <removeFromStateListHead+0x27>
	panic("Not holding the lock!");
80104873:	83 ec 0c             	sub    $0xc,%esp
80104876:	68 84 a9 10 80       	push   $0x8010a984
8010487b:	e8 e6 bc ff ff       	call   80100566 <panic>
    }

    if(!sList){
80104880:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104884:	75 07                	jne    8010488d <removeFromStateListHead+0x34>
	return -1;
80104886:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010488b:	eb 28                	jmp    801048b5 <removeFromStateListHead+0x5c>
    }
    
    struct proc* head = *sList;
8010488d:	8b 45 08             	mov    0x8(%ebp),%eax
80104890:	8b 00                	mov    (%eax),%eax
80104892:	89 45 f4             	mov    %eax,-0xc(%ebp)

    *sList = head -> next;
80104895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104898:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
8010489e:	8b 45 08             	mov    0x8(%ebp),%eax
801048a1:	89 10                	mov    %edx,(%eax)
    p -> next = 0;
801048a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801048a6:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801048ad:	00 00 00 

    return 0;
801048b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048b5:	c9                   	leave  
801048b6:	c3                   	ret    

801048b7 <removeFromStateList>:

static int
removeFromStateList(struct proc** sList, struct proc* p){
801048b7:	55                   	push   %ebp
801048b8:	89 e5                	mov    %esp,%ebp
801048ba:	83 ec 18             	sub    $0x18,%esp
    
    if(!holding(&ptable.lock)){
801048bd:	83 ec 0c             	sub    $0xc,%esp
801048c0:	68 80 49 11 80       	push   $0x80114980
801048c5:	e8 0b 25 00 00       	call   80106dd5 <holding>
801048ca:	83 c4 10             	add    $0x10,%esp
801048cd:	85 c0                	test   %eax,%eax
801048cf:	75 0d                	jne    801048de <removeFromStateList+0x27>
	panic("Not holding the lock!");
801048d1:	83 ec 0c             	sub    $0xc,%esp
801048d4:	68 84 a9 10 80       	push   $0x8010a984
801048d9:	e8 88 bc ff ff       	call   80100566 <panic>
    }
    struct proc *current = *sList;
801048de:	8b 45 08             	mov    0x8(%ebp),%eax
801048e1:	8b 00                	mov    (%eax),%eax
801048e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc *previous = *sList;
801048e6:	8b 45 08             	mov    0x8(%ebp),%eax
801048e9:	8b 00                	mov    (%eax),%eax
801048eb:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if(*sList == 0)
801048ee:	8b 45 08             	mov    0x8(%ebp),%eax
801048f1:	8b 00                	mov    (%eax),%eax
801048f3:	85 c0                	test   %eax,%eax
801048f5:	75 0a                	jne    80104901 <removeFromStateList+0x4a>
	return -1;
801048f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fc:	e9 81 00 00 00       	jmp    80104982 <removeFromStateList+0xcb>

    if(*sList == p){
80104901:	8b 45 08             	mov    0x8(%ebp),%eax
80104904:	8b 00                	mov    (%eax),%eax
80104906:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104909:	75 36                	jne    80104941 <removeFromStateList+0x8a>
	*sList = (*sList) -> next;
8010490b:	8b 45 08             	mov    0x8(%ebp),%eax
8010490e:	8b 00                	mov    (%eax),%eax
80104910:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104916:	8b 45 08             	mov    0x8(%ebp),%eax
80104919:	89 10                	mov    %edx,(%eax)
	p -> next = 0;
8010491b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010491e:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104925:	00 00 00 
	return 0;
80104928:	b8 00 00 00 00       	mov    $0x0,%eax
8010492d:	eb 53                	jmp    80104982 <removeFromStateList+0xcb>
    }
    while(current != 0 && current != p) {
	previous = current;
8010492f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104932:	89 45 f0             	mov    %eax,-0x10(%ebp)
	current = current -> next;
80104935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104938:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010493e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(*sList == p){
	*sList = (*sList) -> next;
	p -> next = 0;
	return 0;
    }
    while(current != 0 && current != p) {
80104941:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104945:	74 08                	je     8010494f <removeFromStateList+0x98>
80104947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010494d:	75 e0                	jne    8010492f <removeFromStateList+0x78>
	previous = current;
	current = current -> next;
    }

    if(current == p){
8010494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104952:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104955:	75 26                	jne    8010497d <removeFromStateList+0xc6>
	previous -> next = current -> next;
80104957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495a:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104963:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	p -> next = 0;
80104969:	8b 45 0c             	mov    0xc(%ebp),%eax
8010496c:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104973:	00 00 00 
    }
    else
	return -1;

    return 0;
80104976:	b8 00 00 00 00       	mov    $0x0,%eax
8010497b:	eb 05                	jmp    80104982 <removeFromStateList+0xcb>
    if(current == p){
	previous -> next = current -> next;
	p -> next = 0;
    }
    else
	return -1;
8010497d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

    return 0;

    
}
80104982:	c9                   	leave  
80104983:	c3                   	ret    

80104984 <pinit>:

#endif

void
pinit(void)
{
80104984:	55                   	push   %ebp
80104985:	89 e5                	mov    %esp,%ebp
80104987:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010498a:	83 ec 08             	sub    $0x8,%esp
8010498d:	68 9a a9 10 80       	push   $0x8010a99a
80104992:	68 80 49 11 80       	push   $0x80114980
80104997:	e8 e4 22 00 00       	call   80106c80 <initlock>
8010499c:	83 c4 10             	add    $0x10,%esp
}
8010499f:	90                   	nop
801049a0:	c9                   	leave  
801049a1:	c3                   	ret    

801049a2 <allocproc>:
}

#else
static struct proc*
allocproc(void)
{
801049a2:	55                   	push   %ebp
801049a3:	89 e5                	mov    %esp,%ebp
801049a5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	68 80 49 11 80       	push   $0x80114980
801049b0:	e8 ed 22 00 00       	call   80106ca2 <acquire>
801049b5:	83 c4 10             	add    $0x10,%esp

  p = ptable.pLists.free;
801049b8:	a1 c8 70 11 80       	mov    0x801170c8,%eax
801049bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p){
801049c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049c4:	75 1a                	jne    801049e0 <allocproc+0x3e>
    release(&ptable.lock);
801049c6:	83 ec 0c             	sub    $0xc,%esp
801049c9:	68 80 49 11 80       	push   $0x80114980
801049ce:	e8 36 23 00 00       	call   80106d09 <release>
801049d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801049d6:	b8 00 00 00 00       	mov    $0x0,%eax
801049db:	e9 3d 01 00 00       	jmp    80104b1d <allocproc+0x17b>
  }

  assertStateFree(p);
801049e0:	83 ec 0c             	sub    $0xc,%esp
801049e3:	ff 75 f4             	pushl  -0xc(%ebp)
801049e6:	e8 1f fd ff ff       	call   8010470a <assertStateFree>
801049eb:	83 c4 10             	add    $0x10,%esp

  removeFromStateListHead(&ptable.pLists.free, p);
801049ee:	83 ec 08             	sub    $0x8,%esp
801049f1:	ff 75 f4             	pushl  -0xc(%ebp)
801049f4:	68 c8 70 11 80       	push   $0x801170c8
801049f9:	e8 5b fe ff ff       	call   80104859 <removeFromStateListHead>
801049fe:	83 c4 10             	add    $0x10,%esp

  p->state = EMBRYO;
80104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a04:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  addToStateListEnd(&ptable.pLists.embryo, p);
80104a0b:	83 ec 08             	sub    $0x8,%esp
80104a0e:	ff 75 f4             	pushl  -0xc(%ebp)
80104a11:	68 d8 70 11 80       	push   $0x801170d8
80104a16:	e8 b4 fd ff ff       	call   801047cf <addToStateListEnd>
80104a1b:	83 c4 10             	add    $0x10,%esp

  p->pid = nextpid++;
80104a1e:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104a23:	8d 50 01             	lea    0x1(%eax),%edx
80104a26:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104a2c:	89 c2                	mov    %eax,%edx
80104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a31:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
80104a34:	83 ec 0c             	sub    $0xc,%esp
80104a37:	68 80 49 11 80       	push   $0x80114980
80104a3c:	e8 c8 22 00 00       	call   80106d09 <release>
80104a41:	83 c4 10             	add    $0x10,%esp
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104a44:	e8 d2 e4 ff ff       	call   80102f1b <kalloc>
80104a49:	89 c2                	mov    %eax,%edx
80104a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4e:	89 50 08             	mov    %edx,0x8(%eax)
80104a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a54:	8b 40 08             	mov    0x8(%eax),%eax
80104a57:	85 c0                	test   %eax,%eax
80104a59:	75 65                	jne    80104ac0 <allocproc+0x11e>

  acquire(&ptable.lock);
80104a5b:	83 ec 0c             	sub    $0xc,%esp
80104a5e:	68 80 49 11 80       	push   $0x80114980
80104a63:	e8 3a 22 00 00       	call   80106ca2 <acquire>
80104a68:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104a6b:	83 ec 0c             	sub    $0xc,%esp
80104a6e:	ff 75 f4             	pushl  -0xc(%ebp)
80104a71:	e8 d5 fc ff ff       	call   8010474b <assertStateEmbryo>
80104a76:	83 c4 10             	add    $0x10,%esp
  removeFromStateListHead(&ptable.pLists.embryo, p);
80104a79:	83 ec 08             	sub    $0x8,%esp
80104a7c:	ff 75 f4             	pushl  -0xc(%ebp)
80104a7f:	68 d8 70 11 80       	push   $0x801170d8
80104a84:	e8 d0 fd ff ff       	call   80104859 <removeFromStateListHead>
80104a89:	83 c4 10             	add    $0x10,%esp

  p->state = UNUSED;
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  addToStateListEnd(&ptable.pLists.free, p);
80104a96:	83 ec 08             	sub    $0x8,%esp
80104a99:	ff 75 f4             	pushl  -0xc(%ebp)
80104a9c:	68 c8 70 11 80       	push   $0x801170c8
80104aa1:	e8 29 fd ff ff       	call   801047cf <addToStateListEnd>
80104aa6:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104aa9:	83 ec 0c             	sub    $0xc,%esp
80104aac:	68 80 49 11 80       	push   $0x80114980
80104ab1:	e8 53 22 00 00       	call   80106d09 <release>
80104ab6:	83 c4 10             	add    $0x10,%esp

    return 0;
80104ab9:	b8 00 00 00 00       	mov    $0x0,%eax
80104abe:	eb 5d                	jmp    80104b1d <allocproc+0x17b>
  }
  sp = p->kstack + KSTACKSIZE;
80104ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac3:	8b 40 08             	mov    0x8(%eax),%eax
80104ac6:	05 00 10 00 00       	add    $0x1000,%eax
80104acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104ace:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ad8:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104adb:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104adf:	ba 96 86 10 80       	mov    $0x80108696,%edx
80104ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ae7:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104ae9:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104af3:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af9:	8b 40 1c             	mov    0x1c(%eax),%eax
80104afc:	83 ec 04             	sub    $0x4,%esp
80104aff:	6a 14                	push   $0x14
80104b01:	6a 00                	push   $0x0
80104b03:	50                   	push   %eax
80104b04:	e8 fc 23 00 00       	call   80106f05 <memset>
80104b09:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b12:	ba 47 59 10 80       	mov    $0x80105947,%edx
80104b17:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b1d:	c9                   	leave  
80104b1e:	c3                   	ret    

80104b1f <userinit>:
// Return 0 on success, -1 on failure.

#else
void
userinit(void)
{
80104b1f:	55                   	push   %ebp
80104b20:	89 e5                	mov    %esp,%ebp
80104b22:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  for(int i = 0; i < MAX+1; ++i)
80104b25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b2c:	eb 17                	jmp    80104b45 <userinit+0x26>
    ptable.pLists.ready[i] = 0;
80104b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b31:	05 cc 09 00 00       	add    $0x9cc,%eax
80104b36:	c7 04 85 84 49 11 80 	movl   $0x0,-0x7feeb67c(,%eax,4)
80104b3d:	00 00 00 00 
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  for(int i = 0; i < MAX+1; ++i)
80104b41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b45:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80104b49:	7e e3                	jle    80104b2e <userinit+0xf>
    ptable.pLists.ready[i] = 0;

  ptable.pLists.free = 0;
80104b4b:	c7 05 c8 70 11 80 00 	movl   $0x0,0x801170c8
80104b52:	00 00 00 
  ptable.pLists.sleep = 0;
80104b55:	c7 05 cc 70 11 80 00 	movl   $0x0,0x801170cc
80104b5c:	00 00 00 
  ptable.pLists.zombie = 0;
80104b5f:	c7 05 d0 70 11 80 00 	movl   $0x0,0x801170d0
80104b66:	00 00 00 
  ptable.pLists.running = 0;
80104b69:	c7 05 d4 70 11 80 00 	movl   $0x0,0x801170d4
80104b70:	00 00 00 
  ptable.pLists.embryo = 0;
80104b73:	c7 05 d8 70 11 80 00 	movl   $0x0,0x801170d8
80104b7a:	00 00 00 

  acquire(&ptable.lock);
80104b7d:	83 ec 0c             	sub    $0xc,%esp
80104b80:	68 80 49 11 80       	push   $0x80114980
80104b85:	e8 18 21 00 00       	call   80106ca2 <acquire>
80104b8a:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < NPROC; i++){
80104b8d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104b94:	eb 51                	jmp    80104be7 <userinit+0xc8>
    addToStateListEnd(&ptable.pLists.free, &ptable.proc[i]);
80104b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b99:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104b9f:	83 c0 30             	add    $0x30,%eax
80104ba2:	05 80 49 11 80       	add    $0x80114980,%eax
80104ba7:	83 c0 04             	add    $0x4,%eax
80104baa:	83 ec 08             	sub    $0x8,%esp
80104bad:	50                   	push   %eax
80104bae:	68 c8 70 11 80       	push   $0x801170c8
80104bb3:	e8 17 fc ff ff       	call   801047cf <addToStateListEnd>
80104bb8:	83 c4 10             	add    $0x10,%esp
    ptable.proc[i].priority = 0;
80104bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bbe:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104bc4:	05 48 4a 11 80       	add    $0x80114a48,%eax
80104bc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    ptable.proc[i].budget = BUDGET;
80104bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bd2:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104bd8:	05 4c 4a 11 80       	add    $0x80114a4c,%eax
80104bdd:	c7 00 88 13 00 00    	movl   $0x1388,(%eax)
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  acquire(&ptable.lock);
  for(int i = 0; i < NPROC; i++){
80104be3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104be7:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104beb:	7e a9                	jle    80104b96 <userinit+0x77>
    addToStateListEnd(&ptable.pLists.free, &ptable.proc[i]);
    ptable.proc[i].priority = 0;
    ptable.proc[i].budget = BUDGET;
  }
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
80104bed:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80104bf2:	05 88 13 00 00       	add    $0x1388,%eax
80104bf7:	a3 dc 70 11 80       	mov    %eax,0x801170dc

  release(&ptable.lock);
80104bfc:	83 ec 0c             	sub    $0xc,%esp
80104bff:	68 80 49 11 80       	push   $0x80114980
80104c04:	e8 00 21 00 00       	call   80106d09 <release>
80104c09:	83 c4 10             	add    $0x10,%esp


  p = allocproc();
80104c0c:	e8 91 fd ff ff       	call   801049a2 <allocproc>
80104c11:	89 45 ec             	mov    %eax,-0x14(%ebp)

  initproc = p;
80104c14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c17:	a3 68 d6 10 80       	mov    %eax,0x8010d668
  if((p->pgdir = setupkvm()) == 0)
80104c1c:	e8 37 51 00 00       	call   80109d58 <setupkvm>
80104c21:	89 c2                	mov    %eax,%edx
80104c23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c26:	89 50 04             	mov    %edx,0x4(%eax)
80104c29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c2c:	8b 40 04             	mov    0x4(%eax),%eax
80104c2f:	85 c0                	test   %eax,%eax
80104c31:	75 0d                	jne    80104c40 <userinit+0x121>
    panic("userinit: out of memory?");
80104c33:	83 ec 0c             	sub    $0xc,%esp
80104c36:	68 a1 a9 10 80       	push   $0x8010a9a1
80104c3b:	e8 26 b9 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104c40:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c48:	8b 40 04             	mov    0x4(%eax),%eax
80104c4b:	83 ec 04             	sub    $0x4,%esp
80104c4e:	52                   	push   %edx
80104c4f:	68 00 d5 10 80       	push   $0x8010d500
80104c54:	50                   	push   %eax
80104c55:	e8 58 53 00 00       	call   80109fb2 <inituvm>
80104c5a:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c60:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c69:	8b 40 18             	mov    0x18(%eax),%eax
80104c6c:	83 ec 04             	sub    $0x4,%esp
80104c6f:	6a 4c                	push   $0x4c
80104c71:	6a 00                	push   $0x0
80104c73:	50                   	push   %eax
80104c74:	e8 8c 22 00 00       	call   80106f05 <memset>
80104c79:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104c7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c7f:	8b 40 18             	mov    0x18(%eax),%eax
80104c82:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104c88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c8b:	8b 40 18             	mov    0x18(%eax),%eax
80104c8e:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104c94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c97:	8b 40 18             	mov    0x18(%eax),%eax
80104c9a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c9d:	8b 52 18             	mov    0x18(%edx),%edx
80104ca0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ca4:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104ca8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cab:	8b 40 18             	mov    0x18(%eax),%eax
80104cae:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104cb1:	8b 52 18             	mov    0x18(%edx),%edx
80104cb4:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104cb8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104cbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cbf:	8b 40 18             	mov    0x18(%eax),%eax
80104cc2:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104cc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ccc:	8b 40 18             	mov    0x18(%eax),%eax
80104ccf:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cd9:	8b 40 18             	mov    0x18(%eax),%eax
80104cdc:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104ce3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ce6:	83 c0 6c             	add    $0x6c,%eax
80104ce9:	83 ec 04             	sub    $0x4,%esp
80104cec:	6a 10                	push   $0x10
80104cee:	68 ba a9 10 80       	push   $0x8010a9ba
80104cf3:	50                   	push   %eax
80104cf4:	e8 0f 24 00 00       	call   80107108 <safestrcpy>
80104cf9:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104cfc:	83 ec 0c             	sub    $0xc,%esp
80104cff:	68 c3 a9 10 80       	push   $0x8010a9c3
80104d04:	e8 5d d9 ff ff       	call   80102666 <namei>
80104d09:	83 c4 10             	add    $0x10,%esp
80104d0c:	89 c2                	mov    %eax,%edx
80104d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d11:	89 50 68             	mov    %edx,0x68(%eax)

  acquire(&ptable.lock);
80104d14:	83 ec 0c             	sub    $0xc,%esp
80104d17:	68 80 49 11 80       	push   $0x80114980
80104d1c:	e8 81 1f 00 00       	call   80106ca2 <acquire>
80104d21:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104d24:	83 ec 0c             	sub    $0xc,%esp
80104d27:	ff 75 ec             	pushl  -0x14(%ebp)
80104d2a:	e8 1c fa ff ff       	call   8010474b <assertStateEmbryo>
80104d2f:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.embryo, p);
80104d32:	83 ec 08             	sub    $0x8,%esp
80104d35:	ff 75 ec             	pushl  -0x14(%ebp)
80104d38:	68 d8 70 11 80       	push   $0x801170d8
80104d3d:	e8 75 fb ff ff       	call   801048b7 <removeFromStateList>
80104d42:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNABLE;
80104d45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d48:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[0], p);
80104d4f:	83 ec 08             	sub    $0x8,%esp
80104d52:	ff 75 ec             	pushl  -0x14(%ebp)
80104d55:	68 b4 70 11 80       	push   $0x801170b4
80104d5a:	e8 70 fa ff ff       	call   801047cf <addToStateListEnd>
80104d5f:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104d62:	83 ec 0c             	sub    $0xc,%esp
80104d65:	68 80 49 11 80       	push   $0x80114980
80104d6a:	e8 9a 1f 00 00       	call   80106d09 <release>
80104d6f:	83 c4 10             	add    $0x10,%esp


}
80104d72:	90                   	nop
80104d73:	c9                   	leave  
80104d74:	c3                   	ret    

80104d75 <growproc>:
#endif
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104d75:	55                   	push   %ebp
80104d76:	89 e5                	mov    %esp,%ebp
80104d78:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104d7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d81:	8b 00                	mov    (%eax),%eax
80104d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104d86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d8a:	7e 31                	jle    80104dbd <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d8c:	8b 55 08             	mov    0x8(%ebp),%edx
80104d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d92:	01 c2                	add    %eax,%edx
80104d94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d9a:	8b 40 04             	mov    0x4(%eax),%eax
80104d9d:	83 ec 04             	sub    $0x4,%esp
80104da0:	52                   	push   %edx
80104da1:	ff 75 f4             	pushl  -0xc(%ebp)
80104da4:	50                   	push   %eax
80104da5:	e8 55 53 00 00       	call   8010a0ff <allocuvm>
80104daa:	83 c4 10             	add    $0x10,%esp
80104dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104db0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104db4:	75 3e                	jne    80104df4 <growproc+0x7f>
      return -1;
80104db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dbb:	eb 59                	jmp    80104e16 <growproc+0xa1>
  } else if(n < 0){
80104dbd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104dc1:	79 31                	jns    80104df4 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104dc3:	8b 55 08             	mov    0x8(%ebp),%edx
80104dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc9:	01 c2                	add    %eax,%edx
80104dcb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd1:	8b 40 04             	mov    0x4(%eax),%eax
80104dd4:	83 ec 04             	sub    $0x4,%esp
80104dd7:	52                   	push   %edx
80104dd8:	ff 75 f4             	pushl  -0xc(%ebp)
80104ddb:	50                   	push   %eax
80104ddc:	e8 e7 53 00 00       	call   8010a1c8 <deallocuvm>
80104de1:	83 c4 10             	add    $0x10,%esp
80104de4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104de7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104deb:	75 07                	jne    80104df4 <growproc+0x7f>
      return -1;
80104ded:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104df2:	eb 22                	jmp    80104e16 <growproc+0xa1>
  }
  proc->sz = sz;
80104df4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dfd:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104dff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e05:	83 ec 0c             	sub    $0xc,%esp
80104e08:	50                   	push   %eax
80104e09:	e8 31 50 00 00       	call   80109e3f <switchuvm>
80104e0e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e16:	c9                   	leave  
80104e17:	c3                   	ret    

80104e18 <fork>:

#else

int
fork(void)
{
80104e18:	55                   	push   %ebp
80104e19:	89 e5                	mov    %esp,%ebp
80104e1b:	57                   	push   %edi
80104e1c:	56                   	push   %esi
80104e1d:	53                   	push   %ebx
80104e1e:	83 ec 1c             	sub    $0x1c,%esp

  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104e21:	e8 7c fb ff ff       	call   801049a2 <allocproc>
80104e26:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104e29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104e2d:	75 0a                	jne    80104e39 <fork+0x21>
    return -1;
80104e2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e34:	e9 09 02 00 00       	jmp    80105042 <fork+0x22a>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104e39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e3f:	8b 10                	mov    (%eax),%edx
80104e41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e47:	8b 40 04             	mov    0x4(%eax),%eax
80104e4a:	83 ec 08             	sub    $0x8,%esp
80104e4d:	52                   	push   %edx
80104e4e:	50                   	push   %eax
80104e4f:	e8 12 55 00 00       	call   8010a366 <copyuvm>
80104e54:	83 c4 10             	add    $0x10,%esp
80104e57:	89 c2                	mov    %eax,%edx
80104e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e5c:	89 50 04             	mov    %edx,0x4(%eax)
80104e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e62:	8b 40 04             	mov    0x4(%eax),%eax
80104e65:	85 c0                	test   %eax,%eax
80104e67:	0f 85 84 00 00 00    	jne    80104ef1 <fork+0xd9>
    kfree(np->kstack);
80104e6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e70:	8b 40 08             	mov    0x8(%eax),%eax
80104e73:	83 ec 0c             	sub    $0xc,%esp
80104e76:	50                   	push   %eax
80104e77:	e8 02 e0 ff ff       	call   80102e7e <kfree>
80104e7c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  assertStateZombie(np); 
80104e89:	83 ec 0c             	sub    $0xc,%esp
80104e8c:	ff 75 e0             	pushl  -0x20(%ebp)
80104e8f:	e8 96 f8 ff ff       	call   8010472a <assertStateZombie>
80104e94:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.zombie, np);
80104e97:	83 ec 08             	sub    $0x8,%esp
80104e9a:	ff 75 e0             	pushl  -0x20(%ebp)
80104e9d:	68 d0 70 11 80       	push   $0x801170d0
80104ea2:	e8 10 fa ff ff       	call   801048b7 <removeFromStateList>
80104ea7:	83 c4 10             	add    $0x10,%esp

  np->state = UNUSED;
80104eaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ead:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  cprintf("\nZOMBIE -> UNUSED\n");
80104eb4:	83 ec 0c             	sub    $0xc,%esp
80104eb7:	68 c5 a9 10 80       	push   $0x8010a9c5
80104ebc:	e8 05 b5 ff ff       	call   801003c6 <cprintf>
80104ec1:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.free, np);
80104ec4:	83 ec 08             	sub    $0x8,%esp
80104ec7:	ff 75 e0             	pushl  -0x20(%ebp)
80104eca:	68 c8 70 11 80       	push   $0x801170c8
80104ecf:	e8 fb f8 ff ff       	call   801047cf <addToStateListEnd>
80104ed4:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104ed7:	83 ec 0c             	sub    $0xc,%esp
80104eda:	68 80 49 11 80       	push   $0x80114980
80104edf:	e8 25 1e 00 00       	call   80106d09 <release>
80104ee4:	83 c4 10             	add    $0x10,%esp

    return -1;
80104ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eec:	e9 51 01 00 00       	jmp    80105042 <fork+0x22a>
  }
  np->sz = proc->sz;
80104ef1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef7:	8b 10                	mov    (%eax),%edx
80104ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104efc:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104efe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f08:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104f0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f0e:	8b 50 18             	mov    0x18(%eax),%edx
80104f11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f17:	8b 40 18             	mov    0x18(%eax),%eax
80104f1a:	89 c3                	mov    %eax,%ebx
80104f1c:	b8 13 00 00 00       	mov    $0x13,%eax
80104f21:	89 d7                	mov    %edx,%edi
80104f23:	89 de                	mov    %ebx,%esi
80104f25:	89 c1                	mov    %eax,%ecx
80104f27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)



  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f2c:	8b 40 18             	mov    0x18(%eax),%eax
80104f2f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104f36:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104f3d:	eb 43                	jmp    80104f82 <fork+0x16a>
    if(proc->ofile[i])
80104f3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f48:	83 c2 08             	add    $0x8,%edx
80104f4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f4f:	85 c0                	test   %eax,%eax
80104f51:	74 2b                	je     80104f7e <fork+0x166>
      np->ofile[i] = filedup(proc->ofile[i]);
80104f53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f5c:	83 c2 08             	add    $0x8,%edx
80104f5f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f63:	83 ec 0c             	sub    $0xc,%esp
80104f66:	50                   	push   %eax
80104f67:	e8 3e c1 ff ff       	call   801010aa <filedup>
80104f6c:	83 c4 10             	add    $0x10,%esp
80104f6f:	89 c1                	mov    %eax,%ecx
80104f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f74:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f77:	83 c2 08             	add    $0x8,%edx
80104f7a:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104f7e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104f82:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104f86:	7e b7                	jle    80104f3f <fork+0x127>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104f88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f8e:	8b 40 68             	mov    0x68(%eax),%eax
80104f91:	83 ec 0c             	sub    $0xc,%esp
80104f94:	50                   	push   %eax
80104f95:	e8 84 ca ff ff       	call   80101a1e <idup>
80104f9a:	83 c4 10             	add    $0x10,%esp
80104f9d:	89 c2                	mov    %eax,%edx
80104f9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa2:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104fa5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fab:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fb1:	83 c0 6c             	add    $0x6c,%eax
80104fb4:	83 ec 04             	sub    $0x4,%esp
80104fb7:	6a 10                	push   $0x10
80104fb9:	52                   	push   %edx
80104fba:	50                   	push   %eax
80104fbb:	e8 48 21 00 00       	call   80107108 <safestrcpy>
80104fc0:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fc6:	8b 40 10             	mov    0x10(%eax),%eax
80104fc9:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.


  acquire(&ptable.lock);
80104fcc:	83 ec 0c             	sub    $0xc,%esp
80104fcf:	68 80 49 11 80       	push   $0x80114980
80104fd4:	e8 c9 1c 00 00       	call   80106ca2 <acquire>
80104fd9:	83 c4 10             	add    $0x10,%esp
  assertStateEmbryo(np);
80104fdc:	83 ec 0c             	sub    $0xc,%esp
80104fdf:	ff 75 e0             	pushl  -0x20(%ebp)
80104fe2:	e8 64 f7 ff ff       	call   8010474b <assertStateEmbryo>
80104fe7:	83 c4 10             	add    $0x10,%esp

  removeFromStateListHead(&ptable.pLists.embryo, np);
80104fea:	83 ec 08             	sub    $0x8,%esp
80104fed:	ff 75 e0             	pushl  -0x20(%ebp)
80104ff0:	68 d8 70 11 80       	push   $0x801170d8
80104ff5:	e8 5f f8 ff ff       	call   80104859 <removeFromStateListHead>
80104ffa:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105000:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[np -> priority], np);	//Change to priority queue
80105007:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010500a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105010:	05 cc 09 00 00       	add    $0x9cc,%eax
80105015:	c1 e0 02             	shl    $0x2,%eax
80105018:	05 80 49 11 80       	add    $0x80114980,%eax
8010501d:	83 c0 04             	add    $0x4,%eax
80105020:	83 ec 08             	sub    $0x8,%esp
80105023:	ff 75 e0             	pushl  -0x20(%ebp)
80105026:	50                   	push   %eax
80105027:	e8 a3 f7 ff ff       	call   801047cf <addToStateListEnd>
8010502c:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
8010502f:	83 ec 0c             	sub    $0xc,%esp
80105032:	68 80 49 11 80       	push   $0x80114980
80105037:	e8 cd 1c 00 00       	call   80106d09 <release>
8010503c:	83 c4 10             	add    $0x10,%esp
  
  return pid;
8010503f:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105042:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105045:	5b                   	pop    %ebx
80105046:	5e                   	pop    %esi
80105047:	5f                   	pop    %edi
80105048:	5d                   	pop    %ebp
80105049:	c3                   	ret    

8010504a <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
8010504a:	55                   	push   %ebp
8010504b:	89 e5                	mov    %esp,%ebp
8010504d:	83 ec 18             	sub    $0x18,%esp

  struct proc *p;
  int fd;

  if(proc == initproc)
80105050:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105057:	a1 68 d6 10 80       	mov    0x8010d668,%eax
8010505c:	39 c2                	cmp    %eax,%edx
8010505e:	75 0d                	jne    8010506d <exit+0x23>
    panic("init exiting");
80105060:	83 ec 0c             	sub    $0xc,%esp
80105063:	68 d8 a9 10 80       	push   $0x8010a9d8
80105068:	e8 f9 b4 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010506d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105074:	eb 48                	jmp    801050be <exit+0x74>
    if(proc->ofile[fd]){
80105076:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010507c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010507f:	83 c2 08             	add    $0x8,%edx
80105082:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105086:	85 c0                	test   %eax,%eax
80105088:	74 30                	je     801050ba <exit+0x70>
      fileclose(proc->ofile[fd]);
8010508a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105090:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105093:	83 c2 08             	add    $0x8,%edx
80105096:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010509a:	83 ec 0c             	sub    $0xc,%esp
8010509d:	50                   	push   %eax
8010509e:	e8 58 c0 ff ff       	call   801010fb <fileclose>
801050a3:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
801050a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050af:	83 c2 08             	add    $0x8,%edx
801050b2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801050b9:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050ba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801050be:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801050c2:	7e b2                	jle    80105076 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801050c4:	e8 39 e7 ff ff       	call   80103802 <begin_op>
  iput(proc->cwd);
801050c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050cf:	8b 40 68             	mov    0x68(%eax),%eax
801050d2:	83 ec 0c             	sub    $0xc,%esp
801050d5:	50                   	push   %eax
801050d6:	e8 75 cb ff ff       	call   80101c50 <iput>
801050db:	83 c4 10             	add    $0x10,%esp
  end_op();
801050de:	e8 ab e7 ff ff       	call   8010388e <end_op>
  proc->cwd = 0;
801050e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801050f0:	83 ec 0c             	sub    $0xc,%esp
801050f3:	68 80 49 11 80       	push   $0x80114980
801050f8:	e8 a5 1b 00 00       	call   80106ca2 <acquire>
801050fd:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105100:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105106:	8b 40 14             	mov    0x14(%eax),%eax
80105109:	83 ec 0c             	sub    $0xc,%esp
8010510c:	50                   	push   %eax
8010510d:	e8 f0 09 00 00       	call   80105b02 <wakeup1>
80105112:	83 c4 10             	add    $0x10,%esp
  int found = 0;
80105115:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  // Pass abandoned children to init.



  p = ptable.pLists.running;
8010511c:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80105121:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p && !found){
80105124:	eb 2f                	jmp    80105155 <exit+0x10b>
    if(p->parent == proc){
80105126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105129:	8b 50 14             	mov    0x14(%eax),%edx
8010512c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105132:	39 c2                	cmp    %eax,%edx
80105134:	75 13                	jne    80105149 <exit+0xff>
      found = 1;
80105136:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      p->parent = initproc;
8010513d:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
80105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105146:	89 50 14             	mov    %edx,0x14(%eax)
    }
    p = p -> next;
80105149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105152:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // Pass abandoned children to init.



  p = ptable.pLists.running;
  while(p && !found){
80105155:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105159:	74 06                	je     80105161 <exit+0x117>
8010515b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010515f:	74 c5                	je     80105126 <exit+0xdc>
      found = 1;
      p->parent = initproc;
    }
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
80105161:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80105168:	eb 53                	jmp    801051bd <exit+0x173>
      p = ptable.pLists.ready[i];	//Change to priority queue
8010516a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010516d:	05 cc 09 00 00       	add    $0x9cc,%eax
80105172:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105179:	89 45 f4             	mov    %eax,-0xc(%ebp)

      while(p && !found){
8010517c:	eb 2f                	jmp    801051ad <exit+0x163>
	if(p->parent == proc){
8010517e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105181:	8b 50 14             	mov    0x14(%eax),%edx
80105184:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010518a:	39 c2                	cmp    %eax,%edx
8010518c:	75 13                	jne    801051a1 <exit+0x157>

	  found = 1;
8010518e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
80105195:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
8010519b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519e:	89 50 14             	mov    %edx,0x14(%eax)
	}
	p = p -> next;
801051a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a4:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
      p = ptable.pLists.ready[i];	//Change to priority queue

      while(p && !found){
801051ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051b1:	74 06                	je     801051b9 <exit+0x16f>
801051b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801051b7:	74 c5                	je     8010517e <exit+0x134>
      found = 1;
      p->parent = initproc;
    }
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
801051b9:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
801051bd:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
801051c1:	7e a7                	jle    8010516a <exit+0x120>
	}
	p = p -> next;
      }
  }
  
      p = ptable.pLists.sleep;
801051c3:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801051c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while(p && !found){
801051cb:	eb 2f                	jmp    801051fc <exit+0x1b2>
	if(p->parent == proc){
801051cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d0:	8b 50 14             	mov    0x14(%eax),%edx
801051d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d9:	39 c2                	cmp    %eax,%edx
801051db:	75 13                	jne    801051f0 <exit+0x1a6>
	  found = 1;
801051dd:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
801051e4:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
801051ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ed:	89 50 14             	mov    %edx,0x14(%eax)
	}
	p = p -> next;
801051f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	p = p -> next;
      }
  }
  
      p = ptable.pLists.sleep;
      while(p && !found){
801051fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105200:	74 06                	je     80105208 <exit+0x1be>
80105202:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105206:	74 c5                	je     801051cd <exit+0x183>
	  found = 1;
	  p->parent = initproc;
	}
	p = p -> next;
      }
      p = ptable.pLists.zombie;
80105208:	a1 d0 70 11 80       	mov    0x801170d0,%eax
8010520d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while(p && !found){
80105210:	eb 40                	jmp    80105252 <exit+0x208>
	if(p->parent == proc){
80105212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105215:	8b 50 14             	mov    0x14(%eax),%edx
80105218:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010521e:	39 c2                	cmp    %eax,%edx
80105220:	75 24                	jne    80105246 <exit+0x1fc>

	  found = 1;
80105222:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
80105229:	8b 15 68 d6 10 80    	mov    0x8010d668,%edx
8010522f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105232:	89 50 14             	mov    %edx,0x14(%eax)
	  wakeup1(initproc);
80105235:	a1 68 d6 10 80       	mov    0x8010d668,%eax
8010523a:	83 ec 0c             	sub    $0xc,%esp
8010523d:	50                   	push   %eax
8010523e:	e8 bf 08 00 00       	call   80105b02 <wakeup1>
80105243:	83 c4 10             	add    $0x10,%esp

	}
	p = p -> next;
80105246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105249:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010524f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  p->parent = initproc;
	}
	p = p -> next;
      }
      p = ptable.pLists.zombie;
      while(p && !found){
80105252:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105256:	74 06                	je     8010525e <exit+0x214>
80105258:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010525c:	74 b4                	je     80105212 <exit+0x1c8>
	}
	p = p -> next;
      }

  // Jump into the scheduler, never to return.
  assertStateRunning(proc);
8010525e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105264:	83 ec 0c             	sub    $0xc,%esp
80105267:	50                   	push   %eax
80105268:	e8 ff f4 ff ff       	call   8010476c <assertStateRunning>
8010526d:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.running, proc);
80105270:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105276:	83 ec 08             	sub    $0x8,%esp
80105279:	50                   	push   %eax
8010527a:	68 d4 70 11 80       	push   $0x801170d4
8010527f:	e8 33 f6 ff ff       	call   801048b7 <removeFromStateList>
80105284:	83 c4 10             	add    $0x10,%esp

  proc -> state = ZOMBIE;
80105287:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
 
  assertStateZombie(proc);
80105294:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010529a:	83 ec 0c             	sub    $0xc,%esp
8010529d:	50                   	push   %eax
8010529e:	e8 87 f4 ff ff       	call   8010472a <assertStateZombie>
801052a3:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.zombie, proc);
801052a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ac:	83 ec 08             	sub    $0x8,%esp
801052af:	50                   	push   %eax
801052b0:	68 d0 70 11 80       	push   $0x801170d0
801052b5:	e8 15 f5 ff ff       	call   801047cf <addToStateListEnd>
801052ba:	83 c4 10             	add    $0x10,%esp

  sched();
801052bd:	e8 b5 04 00 00       	call   80105777 <sched>
  panic("zombie exit");
801052c2:	83 ec 0c             	sub    $0xc,%esp
801052c5:	68 e5 a9 10 80       	push   $0x8010a9e5
801052ca:	e8 97 b2 ff ff       	call   80100566 <panic>

801052cf <wait>:
  }
}
#else
int
wait(void)
{
801052cf:	55                   	push   %ebp
801052d0:	89 e5                	mov    %esp,%ebp
801052d2:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  int havekids, pid;
  acquire(&ptable.lock);
801052d5:	83 ec 0c             	sub    $0xc,%esp
801052d8:	68 80 49 11 80       	push   $0x80114980
801052dd:	e8 c0 19 00 00       	call   80106ca2 <acquire>
801052e2:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801052e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    int found = 0;
801052ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

     p = ptable.pLists.zombie;
801052f3:	a1 d0 70 11 80       	mov    0x801170d0,%eax
801052f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     while(p && !found){
801052fb:	e9 e0 00 00 00       	jmp    801053e0 <wait+0x111>
       if(p->parent == proc){
80105300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105303:	8b 50 14             	mov    0x14(%eax),%edx
80105306:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010530c:	39 c2                	cmp    %eax,%edx
8010530e:	0f 85 c0 00 00 00    	jne    801053d4 <wait+0x105>
	 found = 1;
80105314:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	 havekids = 1;
8010531b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	 pid = p->pid;
80105322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105325:	8b 40 10             	mov    0x10(%eax),%eax
80105328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	 kfree(p->kstack);
8010532b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532e:	8b 40 08             	mov    0x8(%eax),%eax
80105331:	83 ec 0c             	sub    $0xc,%esp
80105334:	50                   	push   %eax
80105335:	e8 44 db ff ff       	call   80102e7e <kfree>
8010533a:	83 c4 10             	add    $0x10,%esp
	 p->kstack = 0;
8010533d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105340:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	 freevm(p->pgdir);
80105347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534a:	8b 40 04             	mov    0x4(%eax),%eax
8010534d:	83 ec 0c             	sub    $0xc,%esp
80105350:	50                   	push   %eax
80105351:	e8 2f 4f 00 00       	call   8010a285 <freevm>
80105356:	83 c4 10             	add    $0x10,%esp

	 assertStateZombie(p);
80105359:	83 ec 0c             	sub    $0xc,%esp
8010535c:	ff 75 f4             	pushl  -0xc(%ebp)
8010535f:	e8 c6 f3 ff ff       	call   8010472a <assertStateZombie>
80105364:	83 c4 10             	add    $0x10,%esp

	 removeFromStateList(&ptable.pLists.zombie, p);
80105367:	83 ec 08             	sub    $0x8,%esp
8010536a:	ff 75 f4             	pushl  -0xc(%ebp)
8010536d:	68 d0 70 11 80       	push   $0x801170d0
80105372:	e8 40 f5 ff ff       	call   801048b7 <removeFromStateList>
80105377:	83 c4 10             	add    $0x10,%esp

	 p->state = UNUSED;
8010537a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	 addToStateListEnd(&ptable.pLists.free, p);
80105384:	83 ec 08             	sub    $0x8,%esp
80105387:	ff 75 f4             	pushl  -0xc(%ebp)
8010538a:	68 c8 70 11 80       	push   $0x801170c8
8010538f:	e8 3b f4 ff ff       	call   801047cf <addToStateListEnd>
80105394:	83 c4 10             	add    $0x10,%esp

	 p->pid = 0;
80105397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
	 p->parent = 0;
801053a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	 p->name[0] = 0;
801053ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ae:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
	 p->killed = 0;
801053b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
	 release(&ptable.lock);
801053bc:	83 ec 0c             	sub    $0xc,%esp
801053bf:	68 80 49 11 80       	push   $0x80114980
801053c4:	e8 40 19 00 00       	call   80106d09 <release>
801053c9:	83 c4 10             	add    $0x10,%esp
	 return pid;
801053cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801053cf:	e9 4b 01 00 00       	jmp    8010551f <wait+0x250>

       }
       p = p -> next;
801053d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801053dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // Scan through table looking for zombie children.
    havekids = 0;
    int found = 0;

     p = ptable.pLists.zombie;
     while(p && !found){
801053e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053e4:	74 0a                	je     801053f0 <wait+0x121>
801053e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801053ea:	0f 84 10 ff ff ff    	je     80105300 <wait+0x31>
	 return pid;

       }
       p = p -> next;
     }
    p = ptable.pLists.running;
801053f0:	a1 d4 70 11 80       	mov    0x801170d4,%eax
801053f5:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while(p && !found){
801053f8:	eb 2a                	jmp    80105424 <wait+0x155>
      if(p->parent == proc){
801053fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053fd:	8b 50 14             	mov    0x14(%eax),%edx
80105400:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105406:	39 c2                	cmp    %eax,%edx
80105408:	75 0e                	jne    80105418 <wait+0x149>
	found = 1;
8010540a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	havekids = 1;
80105411:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      }
      p = p -> next;
80105418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105421:	89 45 f4             	mov    %eax,-0xc(%ebp)
       }
       p = p -> next;
     }
    p = ptable.pLists.running;

    while(p && !found){
80105424:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105428:	74 06                	je     80105430 <wait+0x161>
8010542a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010542e:	74 ca                	je     801053fa <wait+0x12b>
	found = 1;
	havekids = 1;
      }
      p = p -> next;
    }
    if(!found){
80105430:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105434:	75 5d                	jne    80105493 <wait+0x1c4>
      for(int i = 0; i < MAX+1; ++i){	
80105436:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
8010543d:	eb 4e                	jmp    8010548d <wait+0x1be>
	p = ptable.pLists.ready[i];	//Change to priority queue
8010543f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105442:	05 cc 09 00 00       	add    $0x9cc,%eax
80105447:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010544e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while(p && !found){
80105451:	eb 2a                	jmp    8010547d <wait+0x1ae>
	  if(p->parent == proc){
80105453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105456:	8b 50 14             	mov    0x14(%eax),%edx
80105459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010545f:	39 c2                	cmp    %eax,%edx
80105461:	75 0e                	jne    80105471 <wait+0x1a2>
	    found = 1;
80105463:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	    havekids = 1;
8010546a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	   }
	   p = p -> next;
80105471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105474:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010547a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      p = p -> next;
    }
    if(!found){
      for(int i = 0; i < MAX+1; ++i){	
	p = ptable.pLists.ready[i];	//Change to priority queue
	while(p && !found){
8010547d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105481:	74 06                	je     80105489 <wait+0x1ba>
80105483:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105487:	74 ca                	je     80105453 <wait+0x184>
	havekids = 1;
      }
      p = p -> next;
    }
    if(!found){
      for(int i = 0; i < MAX+1; ++i){	
80105489:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
8010548d:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
80105491:	7e ac                	jle    8010543f <wait+0x170>
	   }
	   p = p -> next;
	}
      }
     }
     if(!found){
80105493:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105497:	75 40                	jne    801054d9 <wait+0x20a>
	 p = ptable.pLists.sleep;
80105499:	a1 cc 70 11 80       	mov    0x801170cc,%eax
8010549e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	 while(p && !found){
801054a1:	eb 2a                	jmp    801054cd <wait+0x1fe>
	   if(p->parent == proc){
801054a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a6:	8b 50 14             	mov    0x14(%eax),%edx
801054a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054af:	39 c2                	cmp    %eax,%edx
801054b1:	75 0e                	jne    801054c1 <wait+0x1f2>
	     found = 1;
801054b3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	     havekids = 1;
801054ba:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	   }
	   p = p -> next;
801054c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c4:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801054ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
      }
     }
     if(!found){
	 p = ptable.pLists.sleep;
	 while(p && !found){
801054cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054d1:	74 06                	je     801054d9 <wait+0x20a>
801054d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801054d7:	74 ca                	je     801054a3 <wait+0x1d4>
	 }
     }


    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801054d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054dd:	74 0d                	je     801054ec <wait+0x21d>
801054df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e5:	8b 40 24             	mov    0x24(%eax),%eax
801054e8:	85 c0                	test   %eax,%eax
801054ea:	74 17                	je     80105503 <wait+0x234>
      release(&ptable.lock);
801054ec:	83 ec 0c             	sub    $0xc,%esp
801054ef:	68 80 49 11 80       	push   $0x80114980
801054f4:	e8 10 18 00 00       	call   80106d09 <release>
801054f9:	83 c4 10             	add    $0x10,%esp
      return -1;
801054fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105501:	eb 1c                	jmp    8010551f <wait+0x250>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105503:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105509:	83 ec 08             	sub    $0x8,%esp
8010550c:	68 80 49 11 80       	push   $0x80114980
80105511:	50                   	push   %eax
80105512:	e8 76 04 00 00       	call   8010598d <sleep>
80105517:	83 c4 10             	add    $0x10,%esp
  }
8010551a:	e9 c6 fd ff ff       	jmp    801052e5 <wait+0x16>

}
8010551f:	c9                   	leave  
80105520:	c3                   	ret    

80105521 <scheduler>:
}

#else
void
scheduler(void)
{
80105521:	55                   	push   %ebp
80105522:	89 e5                	mov    %esp,%ebp
80105524:	83 ec 18             	sub    $0x18,%esp
    struct proc *p;
      int idle;  // for checking if processor is idle
      for(;;){
	// Enable interrupts on this processor.
	sti();
80105527:	e8 d7 f1 ff ff       	call   80104703 <sti>

	idle = 1;  // assume idle unless we schedule a process
8010552c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)

	acquire(&ptable.lock);
80105533:	83 ec 0c             	sub    $0xc,%esp
80105536:	68 80 49 11 80       	push   $0x80114980
8010553b:	e8 62 17 00 00       	call   80106ca2 <acquire>
80105540:	83 c4 10             	add    $0x10,%esp

	  if(ticks >= ptable.PromoteAtTime){
80105543:	8b 15 dc 70 11 80    	mov    0x801170dc,%edx
80105549:	a1 e0 78 11 80       	mov    0x801178e0,%eax
8010554e:	39 c2                	cmp    %eax,%edx
80105550:	0f 87 2c 01 00 00    	ja     80105682 <scheduler+0x161>
	      for(int i = 1; i < MAX+1; ++i){
80105556:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
8010555d:	e9 8b 00 00 00       	jmp    801055ed <scheduler+0xcc>
		 do{ 
		      p = ptable.pLists.ready[i];
80105562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105565:	05 cc 09 00 00       	add    $0x9cc,%eax
8010556a:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105571:	89 45 f4             	mov    %eax,-0xc(%ebp)
		      if(p){
80105574:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105578:	74 65                	je     801055df <scheduler+0xbe>
			  removeFromStateList(&ptable.pLists.ready[p -> priority], p);
8010557a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557d:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105583:	05 cc 09 00 00       	add    $0x9cc,%eax
80105588:	c1 e0 02             	shl    $0x2,%eax
8010558b:	05 80 49 11 80       	add    $0x80114980,%eax
80105590:	83 c0 04             	add    $0x4,%eax
80105593:	83 ec 08             	sub    $0x8,%esp
80105596:	ff 75 f4             	pushl  -0xc(%ebp)
80105599:	50                   	push   %eax
8010559a:	e8 18 f3 ff ff       	call   801048b7 <removeFromStateList>
8010559f:	83 c4 10             	add    $0x10,%esp
			  --(p -> priority);
801055a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a5:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801055ab:	8d 50 ff             	lea    -0x1(%eax),%edx
801055ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b1:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
801055b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ba:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801055c0:	05 cc 09 00 00       	add    $0x9cc,%eax
801055c5:	c1 e0 02             	shl    $0x2,%eax
801055c8:	05 80 49 11 80       	add    $0x80114980,%eax
801055cd:	83 c0 04             	add    $0x4,%eax
801055d0:	83 ec 08             	sub    $0x8,%esp
801055d3:	ff 75 f4             	pushl  -0xc(%ebp)
801055d6:	50                   	push   %eax
801055d7:	e8 f3 f1 ff ff       	call   801047cf <addToStateListEnd>
801055dc:	83 c4 10             	add    $0x10,%esp
		      }
		  }while(p);
801055df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055e3:	0f 85 79 ff ff ff    	jne    80105562 <scheduler+0x41>
	idle = 1;  // assume idle unless we schedule a process

	acquire(&ptable.lock);

	  if(ticks >= ptable.PromoteAtTime){
	      for(int i = 1; i < MAX+1; ++i){
801055e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801055ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801055f1:	0f 8e 6b ff ff ff    	jle    80105562 <scheduler+0x41>
			  --(p -> priority);
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
		      }
		  }while(p);
	      }
	      p = ptable.pLists.sleep;
801055f7:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801055fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      while(p){
801055ff:	eb 2e                	jmp    8010562f <scheduler+0x10e>
		  if(p -> priority > 0)
80105601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105604:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010560a:	85 c0                	test   %eax,%eax
8010560c:	74 15                	je     80105623 <scheduler+0x102>
		    --(p -> priority);
8010560e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105611:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105617:	8d 50 ff             	lea    -0x1(%eax),%edx
8010561a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561d:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		  p = p -> next;
80105623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105626:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010562c:	89 45 f4             	mov    %eax,-0xc(%ebp)
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
		      }
		  }while(p);
	      }
	      p = ptable.pLists.sleep;
	      while(p){
8010562f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105633:	75 cc                	jne    80105601 <scheduler+0xe0>
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }
	      p = ptable.pLists.running;
80105635:	a1 d4 70 11 80       	mov    0x801170d4,%eax
8010563a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      while(p){
8010563d:	eb 2e                	jmp    8010566d <scheduler+0x14c>
		  if(p -> priority > 0)
8010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105642:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105648:	85 c0                	test   %eax,%eax
8010564a:	74 15                	je     80105661 <scheduler+0x140>
		    --(p -> priority);
8010564c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564f:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105655:	8d 50 ff             	lea    -0x1(%eax),%edx
80105658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565b:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		  p = p -> next;
80105661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105664:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010566a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }
	      p = ptable.pLists.running;
	      while(p){
8010566d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105671:	75 cc                	jne    8010563f <scheduler+0x11e>
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }

	      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
80105673:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80105678:	05 88 13 00 00       	add    $0x1388,%eax
8010567d:	a3 dc 70 11 80       	mov    %eax,0x801170dc
	  }
	for(int i = 0; i < MAX+1; ++i){
80105682:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105689:	eb 1c                	jmp    801056a7 <scheduler+0x186>
	    p = ptable.pLists.ready[i];
8010568b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010568e:	05 cc 09 00 00       	add    $0x9cc,%eax
80105693:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010569a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    if(p){
8010569d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a1:	75 0c                	jne    801056af <scheduler+0x18e>
		  p = p -> next;
	      }

	      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
	  }
	for(int i = 0; i < MAX+1; ++i){
801056a3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801056a7:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
801056ab:	7e de                	jle    8010568b <scheduler+0x16a>
801056ad:	eb 01                	jmp    801056b0 <scheduler+0x18f>
	    p = ptable.pLists.ready[i];
	    if(p){
		break;
801056af:	90                   	nop
	    }
	}

	if(p){		      
801056b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056b4:	0f 84 9d 00 00 00    	je     80105757 <scheduler+0x236>
	  assertStateReady(p);
801056ba:	83 ec 0c             	sub    $0xc,%esp
801056bd:	ff 75 f4             	pushl  -0xc(%ebp)
801056c0:	e8 e9 f0 ff ff       	call   801047ae <assertStateReady>
801056c5:	83 c4 10             	add    $0x10,%esp

	  removeFromStateListHead(&ptable.pLists.ready[p -> priority], p);
801056c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cb:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801056d1:	05 cc 09 00 00       	add    $0x9cc,%eax
801056d6:	c1 e0 02             	shl    $0x2,%eax
801056d9:	05 80 49 11 80       	add    $0x80114980,%eax
801056de:	83 c0 04             	add    $0x4,%eax
801056e1:	83 ec 08             	sub    $0x8,%esp
801056e4:	ff 75 f4             	pushl  -0xc(%ebp)
801056e7:	50                   	push   %eax
801056e8:	e8 6c f1 ff ff       	call   80104859 <removeFromStateListHead>
801056ed:	83 c4 10             	add    $0x10,%esp
	  idle = 0;  // not idle this timeslice
801056f0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	  proc = p;
801056f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fa:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80105700:	83 ec 0c             	sub    $0xc,%esp
80105703:	ff 75 f4             	pushl  -0xc(%ebp)
80105706:	e8 34 47 00 00       	call   80109e3f <switchuvm>
8010570b:	83 c4 10             	add    $0x10,%esp

	  proc -> state = RUNNING;
8010570e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105714:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  addToStateListEnd(&ptable.pLists.running, proc);
8010571b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105721:	83 ec 08             	sub    $0x8,%esp
80105724:	50                   	push   %eax
80105725:	68 d4 70 11 80       	push   $0x801170d4
8010572a:	e8 a0 f0 ff ff       	call   801047cf <addToStateListEnd>
8010572f:	83 c4 10             	add    $0x10,%esp
	  swtch(&cpu->scheduler, proc->context);
80105732:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105738:	8b 40 1c             	mov    0x1c(%eax),%eax
8010573b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105742:	83 c2 04             	add    $0x4,%edx
80105745:	83 ec 08             	sub    $0x8,%esp
80105748:	50                   	push   %eax
80105749:	52                   	push   %edx
8010574a:	e8 2a 1a 00 00       	call   80107179 <swtch>
8010574f:	83 c4 10             	add    $0x10,%esp
	  switchkvm();
80105752:	e8 cb 46 00 00       	call   80109e22 <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.

	  
	}
	proc = 0;
80105757:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010575e:	00 00 00 00 

	release(&ptable.lock);
80105762:	83 ec 0c             	sub    $0xc,%esp
80105765:	68 80 49 11 80       	push   $0x80114980
8010576a:	e8 9a 15 00 00       	call   80106d09 <release>
8010576f:	83 c4 10             	add    $0x10,%esp
      }
80105772:	e9 b0 fd ff ff       	jmp    80105527 <scheduler+0x6>

80105777 <sched>:

}
#else
void
sched(void)
{
80105777:	55                   	push   %ebp
80105778:	89 e5                	mov    %esp,%ebp
8010577a:	83 ec 18             	sub    $0x18,%esp
    int intena;

  if(!holding(&ptable.lock))
8010577d:	83 ec 0c             	sub    $0xc,%esp
80105780:	68 80 49 11 80       	push   $0x80114980
80105785:	e8 4b 16 00 00       	call   80106dd5 <holding>
8010578a:	83 c4 10             	add    $0x10,%esp
8010578d:	85 c0                	test   %eax,%eax
8010578f:	75 0d                	jne    8010579e <sched+0x27>
    panic("sched ptable.lock");
80105791:	83 ec 0c             	sub    $0xc,%esp
80105794:	68 f1 a9 10 80       	push   $0x8010a9f1
80105799:	e8 c8 ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010579e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057a4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801057aa:	83 f8 01             	cmp    $0x1,%eax
801057ad:	74 0d                	je     801057bc <sched+0x45>
    panic("sched locks");
801057af:	83 ec 0c             	sub    $0xc,%esp
801057b2:	68 03 aa 10 80       	push   $0x8010aa03
801057b7:	e8 aa ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801057bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c2:	8b 40 0c             	mov    0xc(%eax),%eax
801057c5:	83 f8 04             	cmp    $0x4,%eax
801057c8:	75 0d                	jne    801057d7 <sched+0x60>
    panic("sched running");
801057ca:	83 ec 0c             	sub    $0xc,%esp
801057cd:	68 0f aa 10 80       	push   $0x8010aa0f
801057d2:	e8 8f ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801057d7:	e8 17 ef ff ff       	call   801046f3 <readeflags>
801057dc:	25 00 02 00 00       	and    $0x200,%eax
801057e1:	85 c0                	test   %eax,%eax
801057e3:	74 0d                	je     801057f2 <sched+0x7b>
    panic("sched interruptible");
801057e5:	83 ec 0c             	sub    $0xc,%esp
801057e8:	68 1d aa 10 80       	push   $0x8010aa1d
801057ed:	e8 74 ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057f8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //cprintf("Descheduled a process\n");
  swtch(&proc->context, cpu->scheduler);
80105801:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105807:	8b 40 04             	mov    0x4(%eax),%eax
8010580a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105811:	83 c2 1c             	add    $0x1c,%edx
80105814:	83 ec 08             	sub    $0x8,%esp
80105817:	50                   	push   %eax
80105818:	52                   	push   %edx
80105819:	e8 5b 19 00 00       	call   80107179 <swtch>
8010581e:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80105821:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105827:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010582a:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
80105830:	90                   	nop
80105831:	c9                   	leave  
80105832:	c3                   	ret    

80105833 <yield>:

#else
// Give up the CPU for one scheduling round.
void
yield(void)
{
80105833:	55                   	push   %ebp
80105834:	89 e5                	mov    %esp,%ebp
80105836:	53                   	push   %ebx
80105837:	83 ec 04             	sub    $0x4,%esp
  //struct proc* p = proc;  
  acquire(&ptable.lock);  //DOC: yieldlock
8010583a:	83 ec 0c             	sub    $0xc,%esp
8010583d:	68 80 49 11 80       	push   $0x80114980
80105842:	e8 5b 14 00 00       	call   80106ca2 <acquire>
80105847:	83 c4 10             	add    $0x10,%esp

  assertStateRunning(proc);
8010584a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105850:	83 ec 0c             	sub    $0xc,%esp
80105853:	50                   	push   %eax
80105854:	e8 13 ef ff ff       	call   8010476c <assertStateRunning>
80105859:	83 c4 10             	add    $0x10,%esp
  proc -> budget = proc -> budget - (ticks - proc -> cpu_ticks_in);
8010585c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105862:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105869:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010586f:	89 d3                	mov    %edx,%ebx
80105871:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105878:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
8010587e:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105884:	29 d1                	sub    %edx,%ecx
80105886:	89 ca                	mov    %ecx,%edx
80105888:	01 da                	add    %ebx,%edx
8010588a:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)

  if(proc -> budget <= 0){
80105890:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105896:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010589c:	85 c0                	test   %eax,%eax
8010589e:	7f 36                	jg     801058d6 <yield+0xa3>
      if(proc -> priority < MAX)
801058a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a6:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801058ac:	83 f8 03             	cmp    $0x3,%eax
801058af:	77 15                	ja     801058c6 <yield+0x93>
	++(proc -> priority);
801058b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058b7:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
801058bd:	83 c2 01             	add    $0x1,%edx
801058c0:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    proc -> budget = BUDGET;
801058c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058cc:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
801058d3:	13 00 00 
  }

  removeFromStateList(&ptable.pLists.running, proc);
801058d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058dc:	83 ec 08             	sub    $0x8,%esp
801058df:	50                   	push   %eax
801058e0:	68 d4 70 11 80       	push   $0x801170d4
801058e5:	e8 cd ef ff ff       	call   801048b7 <removeFromStateList>
801058ea:	83 c4 10             	add    $0x10,%esp
  
  proc->state = RUNNABLE;
801058ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[proc -> priority], proc);	//Change to priority queue
801058fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105900:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105907:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
8010590d:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
80105913:	c1 e2 02             	shl    $0x2,%edx
80105916:	81 c2 80 49 11 80    	add    $0x80114980,%edx
8010591c:	83 c2 04             	add    $0x4,%edx
8010591f:	83 ec 08             	sub    $0x8,%esp
80105922:	50                   	push   %eax
80105923:	52                   	push   %edx
80105924:	e8 a6 ee ff ff       	call   801047cf <addToStateListEnd>
80105929:	83 c4 10             	add    $0x10,%esp


  sched();
8010592c:	e8 46 fe ff ff       	call   80105777 <sched>
  release(&ptable.lock);
80105931:	83 ec 0c             	sub    $0xc,%esp
80105934:	68 80 49 11 80       	push   $0x80114980
80105939:	e8 cb 13 00 00       	call   80106d09 <release>
8010593e:	83 c4 10             	add    $0x10,%esp

}
80105941:	90                   	nop
80105942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105945:	c9                   	leave  
80105946:	c3                   	ret    

80105947 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105947:	55                   	push   %ebp
80105948:	89 e5                	mov    %esp,%ebp
8010594a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010594d:	83 ec 0c             	sub    $0xc,%esp
80105950:	68 80 49 11 80       	push   $0x80114980
80105955:	e8 af 13 00 00       	call   80106d09 <release>
8010595a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010595d:	a1 20 d0 10 80       	mov    0x8010d020,%eax
80105962:	85 c0                	test   %eax,%eax
80105964:	74 24                	je     8010598a <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105966:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
8010596d:	00 00 00 
    iinit(ROOTDEV);
80105970:	83 ec 0c             	sub    $0xc,%esp
80105973:	6a 01                	push   $0x1
80105975:	e8 6e bd ff ff       	call   801016e8 <iinit>
8010597a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010597d:	83 ec 0c             	sub    $0xc,%esp
80105980:	6a 01                	push   $0x1
80105982:	e8 5d dc ff ff       	call   801035e4 <initlog>
80105987:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
8010598a:	90                   	nop
8010598b:	c9                   	leave  
8010598c:	c3                   	ret    

8010598d <sleep>:

#else

void
sleep(void *chan, struct spinlock *lk)
{
8010598d:	55                   	push   %ebp
8010598e:	89 e5                	mov    %esp,%ebp
80105990:	53                   	push   %ebx
80105991:	83 ec 04             	sub    $0x4,%esp
  if(proc == 0)
80105994:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599a:	85 c0                	test   %eax,%eax
8010599c:	75 0d                	jne    801059ab <sleep+0x1e>
    panic("sleep");
8010599e:	83 ec 0c             	sub    $0xc,%esp
801059a1:	68 31 aa 10 80       	push   $0x8010aa31
801059a6:	e8 bb ab ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801059ab:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
801059b2:	74 24                	je     801059d8 <sleep+0x4b>
    acquire(&ptable.lock);
801059b4:	83 ec 0c             	sub    $0xc,%esp
801059b7:	68 80 49 11 80       	push   $0x80114980
801059bc:	e8 e1 12 00 00       	call   80106ca2 <acquire>
801059c1:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801059c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059c8:	74 0e                	je     801059d8 <sleep+0x4b>
801059ca:	83 ec 0c             	sub    $0xc,%esp
801059cd:	ff 75 0c             	pushl  0xc(%ebp)
801059d0:	e8 34 13 00 00       	call   80106d09 <release>
801059d5:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801059d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059de:	8b 55 08             	mov    0x8(%ebp),%edx
801059e1:	89 50 20             	mov    %edx,0x20(%eax)
  //struct proc *p = proc;
  assertStateRunning(proc);
801059e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ea:	83 ec 0c             	sub    $0xc,%esp
801059ed:	50                   	push   %eax
801059ee:	e8 79 ed ff ff       	call   8010476c <assertStateRunning>
801059f3:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.running, proc);
801059f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059fc:	83 ec 08             	sub    $0x8,%esp
801059ff:	50                   	push   %eax
80105a00:	68 d4 70 11 80       	push   $0x801170d4
80105a05:	e8 ad ee ff ff       	call   801048b7 <removeFromStateList>
80105a0a:	83 c4 10             	add    $0x10,%esp
  proc -> state = SLEEPING;
80105a0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a13:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  assertStateSleep(proc);
80105a1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a20:	83 ec 0c             	sub    $0xc,%esp
80105a23:	50                   	push   %eax
80105a24:	e8 64 ed ff ff       	call   8010478d <assertStateSleep>
80105a29:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.sleep, proc);
80105a2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a32:	83 ec 08             	sub    $0x8,%esp
80105a35:	50                   	push   %eax
80105a36:	68 cc 70 11 80       	push   $0x801170cc
80105a3b:	e8 8f ed ff ff       	call   801047cf <addToStateListEnd>
80105a40:	83 c4 10             	add    $0x10,%esp
  proc -> budget = proc -> budget - (ticks - proc -> cpu_ticks_in);
80105a43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a49:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105a50:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105a56:	89 d3                	mov    %edx,%ebx
80105a58:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105a5f:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
80105a65:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105a6b:	29 d1                	sub    %edx,%ecx
80105a6d:	89 ca                	mov    %ecx,%edx
80105a6f:	01 da                	add    %ebx,%edx
80105a71:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc -> budget <= 0){
80105a77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a7d:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105a83:	85 c0                	test   %eax,%eax
80105a85:	7f 36                	jg     80105abd <sleep+0x130>
      if(proc -> priority < MAX)
80105a87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a8d:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105a93:	83 f8 03             	cmp    $0x3,%eax
80105a96:	77 15                	ja     80105aad <sleep+0x120>
	++(proc -> priority);
80105a98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a9e:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105aa4:	83 c2 01             	add    $0x1,%edx
80105aa7:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    proc -> budget = BUDGET;
80105aad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ab3:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80105aba:	13 00 00 
  }
  sched();
80105abd:	e8 b5 fc ff ff       	call   80105777 <sched>

  // Tidy up.
  proc->chan = 0;
80105ac2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
80105acf:	81 7d 0c 80 49 11 80 	cmpl   $0x80114980,0xc(%ebp)
80105ad6:	74 24                	je     80105afc <sleep+0x16f>
    release(&ptable.lock);
80105ad8:	83 ec 0c             	sub    $0xc,%esp
80105adb:	68 80 49 11 80       	push   $0x80114980
80105ae0:	e8 24 12 00 00       	call   80106d09 <release>
80105ae5:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105ae8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105aec:	74 0e                	je     80105afc <sleep+0x16f>
80105aee:	83 ec 0c             	sub    $0xc,%esp
80105af1:	ff 75 0c             	pushl  0xc(%ebp)
80105af4:	e8 a9 11 00 00       	call   80106ca2 <acquire>
80105af9:	83 c4 10             	add    $0x10,%esp
  }
}
80105afc:	90                   	nop
80105afd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b00:	c9                   	leave  
80105b01:	c3                   	ret    

80105b02 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
80105b02:	55                   	push   %ebp
80105b03:	89 e5                	mov    %esp,%ebp
80105b05:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  struct proc *sleeper = ptable.pLists.sleep;
80105b08:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80105b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(sleeper){
80105b10:	eb 7e                	jmp    80105b90 <wakeup1+0x8e>
    if(sleeper -> chan == chan){
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	8b 40 20             	mov    0x20(%eax),%eax
80105b18:	3b 45 08             	cmp    0x8(%ebp),%eax
80105b1b:	75 67                	jne    80105b84 <wakeup1+0x82>
      p = sleeper;
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
      sleeper = sleeper -> next;
80105b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b26:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      assertStateSleep(p);
80105b2f:	83 ec 0c             	sub    $0xc,%esp
80105b32:	ff 75 f0             	pushl  -0x10(%ebp)
80105b35:	e8 53 ec ff ff       	call   8010478d <assertStateSleep>
80105b3a:	83 c4 10             	add    $0x10,%esp
      removeFromStateList(&ptable.pLists.sleep, p);
80105b3d:	83 ec 08             	sub    $0x8,%esp
80105b40:	ff 75 f0             	pushl  -0x10(%ebp)
80105b43:	68 cc 70 11 80       	push   $0x801170cc
80105b48:	e8 6a ed ff ff       	call   801048b7 <removeFromStateList>
80105b4d:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNABLE;
80105b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b53:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      addToStateListEnd(&ptable.pLists.ready[p -> priority], p);	//Change to priority queue
80105b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5d:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105b63:	05 cc 09 00 00       	add    $0x9cc,%eax
80105b68:	c1 e0 02             	shl    $0x2,%eax
80105b6b:	05 80 49 11 80       	add    $0x80114980,%eax
80105b70:	83 c0 04             	add    $0x4,%eax
80105b73:	83 ec 08             	sub    $0x8,%esp
80105b76:	ff 75 f0             	pushl  -0x10(%ebp)
80105b79:	50                   	push   %eax
80105b7a:	e8 50 ec ff ff       	call   801047cf <addToStateListEnd>
80105b7f:	83 c4 10             	add    $0x10,%esp
80105b82:	eb 0c                	jmp    80105b90 <wakeup1+0x8e>

    }
    else
      sleeper = sleeper -> next;
80105b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b87:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;

  struct proc *sleeper = ptable.pLists.sleep;

  while(sleeper){
80105b90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b94:	0f 85 78 ff ff ff    	jne    80105b12 <wakeup1+0x10>
    }
    else
      sleeper = sleeper -> next;
  }
  
}
80105b9a:	90                   	nop
80105b9b:	c9                   	leave  
80105b9c:	c3                   	ret    

80105b9d <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105b9d:	55                   	push   %ebp
80105b9e:	89 e5                	mov    %esp,%ebp
80105ba0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105ba3:	83 ec 0c             	sub    $0xc,%esp
80105ba6:	68 80 49 11 80       	push   $0x80114980
80105bab:	e8 f2 10 00 00       	call   80106ca2 <acquire>
80105bb0:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105bb3:	83 ec 0c             	sub    $0xc,%esp
80105bb6:	ff 75 08             	pushl  0x8(%ebp)
80105bb9:	e8 44 ff ff ff       	call   80105b02 <wakeup1>
80105bbe:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105bc1:	83 ec 0c             	sub    $0xc,%esp
80105bc4:	68 80 49 11 80       	push   $0x80114980
80105bc9:	e8 3b 11 00 00       	call   80106d09 <release>
80105bce:	83 c4 10             	add    $0x10,%esp
}
80105bd1:	90                   	nop
80105bd2:	c9                   	leave  
80105bd3:	c3                   	ret    

80105bd4 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105bd4:	55                   	push   %ebp
80105bd5:	89 e5                	mov    %esp,%ebp
80105bd7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int found = 0;
80105bda:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  acquire(&ptable.lock);
80105be1:	83 ec 0c             	sub    $0xc,%esp
80105be4:	68 80 49 11 80       	push   $0x80114980
80105be9:	e8 b4 10 00 00       	call   80106ca2 <acquire>
80105bee:	83 c4 10             	add    $0x10,%esp
  while(!found){
80105bf1:	e9 dc 01 00 00       	jmp    80105dd2 <kill+0x1fe>

    for(int i = 0; i < MAX+1; ++i){
80105bf6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105bfd:	eb 68                	jmp    80105c67 <kill+0x93>
	p = ptable.pLists.ready[i];		//Change to priority queue
80105bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c02:	05 cc 09 00 00       	add    $0x9cc,%eax
80105c07:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80105c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while(p && !found){
80105c11:	eb 44                	jmp    80105c57 <kill+0x83>
	    if(p->pid == pid){
80105c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c16:	8b 50 10             	mov    0x10(%eax),%edx
80105c19:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1c:	39 c2                	cmp    %eax,%edx
80105c1e:	75 2b                	jne    80105c4b <kill+0x77>
	      found = 1;
80105c20:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	      p->killed = 1;
80105c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	      release(&ptable.lock);
80105c31:	83 ec 0c             	sub    $0xc,%esp
80105c34:	68 80 49 11 80       	push   $0x80114980
80105c39:	e8 cb 10 00 00       	call   80106d09 <release>
80105c3e:	83 c4 10             	add    $0x10,%esp
	      return 0;
80105c41:	b8 00 00 00 00       	mov    $0x0,%eax
80105c46:	e9 a6 01 00 00       	jmp    80105df1 <kill+0x21d>
	    }

	    p = p -> next;
80105c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(!found){

    for(int i = 0; i < MAX+1; ++i){
	p = ptable.pLists.ready[i];		//Change to priority queue

	while(p && !found){
80105c57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c5b:	74 06                	je     80105c63 <kill+0x8f>
80105c5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c61:	74 b0                	je     80105c13 <kill+0x3f>
  struct proc *p;
  int found = 0;
  acquire(&ptable.lock);
  while(!found){

    for(int i = 0; i < MAX+1; ++i){
80105c63:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105c67:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80105c6b:	7e 92                	jle    80105bff <kill+0x2b>

	    p = p -> next;
	}
    }

    p = ptable.pLists.running;
80105c6d:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80105c72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105c75:	eb 44                	jmp    80105cbb <kill+0xe7>
	if(p->pid == pid){
80105c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7a:	8b 50 10             	mov    0x10(%eax),%edx
80105c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c80:	39 c2                	cmp    %eax,%edx
80105c82:	75 2b                	jne    80105caf <kill+0xdb>
	  found = 1;
80105c84:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	  release(&ptable.lock);
80105c95:	83 ec 0c             	sub    $0xc,%esp
80105c98:	68 80 49 11 80       	push   $0x80114980
80105c9d:	e8 67 10 00 00       	call   80106d09 <release>
80105ca2:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105ca5:	b8 00 00 00 00       	mov    $0x0,%eax
80105caa:	e9 42 01 00 00       	jmp    80105df1 <kill+0x21d>
	}
	p = p -> next;
80105caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    p = p -> next;
	}
    }

    p = ptable.pLists.running;
    while(p && !found){
80105cbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cbf:	74 06                	je     80105cc7 <kill+0xf3>
80105cc1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105cc5:	74 b0                	je     80105c77 <kill+0xa3>
	  return 0;
	}
	p = p -> next;
    }

    p = ptable.pLists.embryo;
80105cc7:	a1 d8 70 11 80       	mov    0x801170d8,%eax
80105ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105ccf:	eb 44                	jmp    80105d15 <kill+0x141>
	if(p->pid == pid){
80105cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd4:	8b 50 10             	mov    0x10(%eax),%edx
80105cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80105cda:	39 c2                	cmp    %eax,%edx
80105cdc:	75 2b                	jne    80105d09 <kill+0x135>
	  found = 1;
80105cde:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
          release(&ptable.lock);
80105cef:	83 ec 0c             	sub    $0xc,%esp
80105cf2:	68 80 49 11 80       	push   $0x80114980
80105cf7:	e8 0d 10 00 00       	call   80106d09 <release>
80105cfc:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105cff:	b8 00 00 00 00       	mov    $0x0,%eax
80105d04:	e9 e8 00 00 00       	jmp    80105df1 <kill+0x21d>
	}
	p = p -> next;
80105d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	p = p -> next;
    }

    p = ptable.pLists.embryo;
    while(p && !found){
80105d15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d19:	74 06                	je     80105d21 <kill+0x14d>
80105d1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d1f:	74 b0                	je     80105cd1 <kill+0xfd>
	  return 0;
	}
	p = p -> next;
    }

    p = ptable.pLists.sleep;
80105d21:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80105d26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105d29:	e9 94 00 00 00       	jmp    80105dc2 <kill+0x1ee>
	if(p->pid == pid){
80105d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d31:	8b 50 10             	mov    0x10(%eax),%edx
80105d34:	8b 45 08             	mov    0x8(%ebp),%eax
80105d37:	39 c2                	cmp    %eax,%edx
80105d39:	75 7b                	jne    80105db6 <kill+0x1e2>
	  found = 1;
80105d3b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d45:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	  assertStateSleep(p);
80105d4c:	83 ec 0c             	sub    $0xc,%esp
80105d4f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d52:	e8 36 ea ff ff       	call   8010478d <assertStateSleep>
80105d57:	83 c4 10             	add    $0x10,%esp
	  removeFromStateList(&ptable.pLists.sleep, p);
80105d5a:	83 ec 08             	sub    $0x8,%esp
80105d5d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d60:	68 cc 70 11 80       	push   $0x801170cc
80105d65:	e8 4d eb ff ff       	call   801048b7 <removeFromStateList>
80105d6a:	83 c4 10             	add    $0x10,%esp
	  p->state = RUNNABLE;
80105d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d70:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);	//Change to priority queue
80105d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105d80:	05 cc 09 00 00       	add    $0x9cc,%eax
80105d85:	c1 e0 02             	shl    $0x2,%eax
80105d88:	05 80 49 11 80       	add    $0x80114980,%eax
80105d8d:	83 c0 04             	add    $0x4,%eax
80105d90:	83 ec 08             	sub    $0x8,%esp
80105d93:	ff 75 f4             	pushl  -0xc(%ebp)
80105d96:	50                   	push   %eax
80105d97:	e8 33 ea ff ff       	call   801047cf <addToStateListEnd>
80105d9c:	83 c4 10             	add    $0x10,%esp

	  release(&ptable.lock);
80105d9f:	83 ec 0c             	sub    $0xc,%esp
80105da2:	68 80 49 11 80       	push   $0x80114980
80105da7:	e8 5d 0f 00 00       	call   80106d09 <release>
80105dac:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105daf:	b8 00 00 00 00       	mov    $0x0,%eax
80105db4:	eb 3b                	jmp    80105df1 <kill+0x21d>

	}
	p = p -> next;
80105db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	p = p -> next;
    }

    p = ptable.pLists.sleep;
    while(p && !found){
80105dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc6:	74 0a                	je     80105dd2 <kill+0x1fe>
80105dc8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105dcc:	0f 84 5c ff ff ff    	je     80105d2e <kill+0x15a>
kill(int pid)
{
  struct proc *p;
  int found = 0;
  acquire(&ptable.lock);
  while(!found){
80105dd2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105dd6:	0f 84 1a fe ff ff    	je     80105bf6 <kill+0x22>
	}
	p = p -> next;
    }
  }

  release(&ptable.lock);
80105ddc:	83 ec 0c             	sub    $0xc,%esp
80105ddf:	68 80 49 11 80       	push   $0x80114980
80105de4:	e8 20 0f 00 00       	call   80106d09 <release>
80105de9:	83 c4 10             	add    $0x10,%esp
  return -1;
80105dec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  

}
80105df1:	c9                   	leave  
80105df2:	c3                   	ret    

80105df3 <procdump>:
    release(&ptable.lock);
}
#else
void
procdump(void)
{
80105df3:	55                   	push   %ebp
80105df4:	89 e5                	mov    %esp,%ebp
80105df6:	57                   	push   %edi
80105df7:	56                   	push   %esi
80105df8:	53                   	push   %ebx
80105df9:	83 ec 5c             	sub    $0x5c,%esp
  int i;
  struct proc *p;
  uint pc[10];
  
    cprintf("PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
80105dfc:	83 ec 0c             	sub    $0xc,%esp
80105dff:	68 64 aa 10 80       	push   $0x8010aa64
80105e04:	e8 bd a5 ff ff       	call   801003c6 <cprintf>
80105e09:	83 c4 10             	add    $0x10,%esp


    acquire(&ptable.lock);
80105e0c:	83 ec 0c             	sub    $0xc,%esp
80105e0f:	68 80 49 11 80       	push   $0x80114980
80105e14:	e8 89 0e 00 00       	call   80106ca2 <acquire>
80105e19:	83 c4 10             	add    $0x10,%esp

    char *state = "???";
80105e1c:	c7 45 dc 9c aa 10 80 	movl   $0x8010aa9c,-0x24(%ebp)
    while(0)
80105e23:	90                   	nop
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105e24:	c7 45 e0 b4 49 11 80 	movl   $0x801149b4,-0x20(%ebp)
80105e2b:	e9 7f 03 00 00       	jmp    801061af <procdump+0x3bc>
    if(p->state == UNUSED)
80105e30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e33:	8b 40 0c             	mov    0xc(%eax),%eax
80105e36:	85 c0                	test   %eax,%eax
80105e38:	0f 84 69 03 00 00    	je     801061a7 <procdump+0x3b4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105e3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e41:	8b 40 0c             	mov    0xc(%eax),%eax
80105e44:	83 f8 05             	cmp    $0x5,%eax
80105e47:	77 21                	ja     80105e6a <procdump+0x77>
80105e49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e4c:	8b 40 0c             	mov    0xc(%eax),%eax
80105e4f:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105e56:	85 c0                	test   %eax,%eax
80105e58:	74 10                	je     80105e6a <procdump+0x77>
      state = states[p->state];
80105e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e5d:	8b 40 0c             	mov    0xc(%eax),%eax
80105e60:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105e67:	89 45 dc             	mov    %eax,-0x24(%ebp)

    int  elapsed, milli, cpue, cpum;

    elapsed = (ticks - p -> start_ticks)/1000;
80105e6a:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105e70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e73:	8b 40 7c             	mov    0x7c(%eax),%eax
80105e76:	29 c2                	sub    %eax,%edx
80105e78:	89 d0                	mov    %edx,%eax
80105e7a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105e7f:	f7 e2                	mul    %edx
80105e81:	89 d0                	mov    %edx,%eax
80105e83:	c1 e8 06             	shr    $0x6,%eax
80105e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
    milli = (ticks - p -> start_ticks)%1000;
80105e89:	8b 15 e0 78 11 80    	mov    0x801178e0,%edx
80105e8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e92:	8b 40 7c             	mov    0x7c(%eax),%eax
80105e95:	89 d1                	mov    %edx,%ecx
80105e97:	29 c1                	sub    %eax,%ecx
80105e99:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105e9e:	89 c8                	mov    %ecx,%eax
80105ea0:	f7 e2                	mul    %edx
80105ea2:	89 d0                	mov    %edx,%eax
80105ea4:	c1 e8 06             	shr    $0x6,%eax
80105ea7:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105ead:	29 c1                	sub    %eax,%ecx
80105eaf:	89 c8                	mov    %ecx,%eax
80105eb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cpue = (p -> cpu_ticks_total)/1000;
80105eb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105eb7:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105ebd:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105ec2:	f7 e2                	mul    %edx
80105ec4:	89 d0                	mov    %edx,%eax
80105ec6:	c1 e8 06             	shr    $0x6,%eax
80105ec9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cpum = (p -> cpu_ticks_total)%1000;
80105ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ecf:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80105ed5:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105eda:	89 c8                	mov    %ecx,%eax
80105edc:	f7 e2                	mul    %edx
80105ede:	89 d0                	mov    %edx,%eax
80105ee0:	c1 e8 06             	shr    $0x6,%eax
80105ee3:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105ee9:	29 c1                	sub    %eax,%ecx
80105eeb:	89 c8                	mov    %ecx,%eax
80105eed:	89 45 cc             	mov    %eax,-0x34(%ebp)

    if(p -> pid == 1){
80105ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ef3:	8b 40 10             	mov    0x10(%eax),%eax
80105ef6:	83 f8 01             	cmp    $0x1,%eax
80105ef9:	0f 85 1c 01 00 00    	jne    8010601b <procdump+0x228>
	cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,1,p -> priority, elapsed);
80105eff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f02:	8b 98 94 00 00 00    	mov    0x94(%eax),%ebx
80105f08:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f0b:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f14:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105f1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f1d:	8d 70 6c             	lea    0x6c(%eax),%esi
80105f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f23:	8b 40 10             	mov    0x10(%eax),%eax
80105f26:	ff 75 d8             	pushl  -0x28(%ebp)
80105f29:	53                   	push   %ebx
80105f2a:	6a 01                	push   $0x1
80105f2c:	51                   	push   %ecx
80105f2d:	52                   	push   %edx
80105f2e:	56                   	push   %esi
80105f2f:	50                   	push   %eax
80105f30:	68 a0 aa 10 80       	push   $0x8010aaa0
80105f35:	e8 8c a4 ff ff       	call   801003c6 <cprintf>
80105f3a:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
80105f3d:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105f41:	7f 16                	jg     80105f59 <procdump+0x166>
	    cprintf("00%d\t%d.", milli, cpue);
80105f43:	83 ec 04             	sub    $0x4,%esp
80105f46:	ff 75 d0             	pushl  -0x30(%ebp)
80105f49:	ff 75 d4             	pushl  -0x2c(%ebp)
80105f4c:	68 b6 aa 10 80       	push   $0x8010aab6
80105f51:	e8 70 a4 ff ff       	call   801003c6 <cprintf>
80105f56:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
80105f59:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105f5d:	7e 1c                	jle    80105f7b <procdump+0x188>
80105f5f:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
80105f63:	7f 16                	jg     80105f7b <procdump+0x188>
	    cprintf("0%d\t%d.", milli, cpue);
80105f65:	83 ec 04             	sub    $0x4,%esp
80105f68:	ff 75 d0             	pushl  -0x30(%ebp)
80105f6b:	ff 75 d4             	pushl  -0x2c(%ebp)
80105f6e:	68 bf aa 10 80       	push   $0x8010aabf
80105f73:	e8 4e a4 ff ff       	call   801003c6 <cprintf>
80105f78:	83 c4 10             	add    $0x10,%esp
	if(milli > 100)
80105f7b:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
80105f7f:	7e 16                	jle    80105f97 <procdump+0x1a4>
	    cprintf("%d\t%d.", milli, cpue);
80105f81:	83 ec 04             	sub    $0x4,%esp
80105f84:	ff 75 d0             	pushl  -0x30(%ebp)
80105f87:	ff 75 d4             	pushl  -0x2c(%ebp)
80105f8a:	68 c7 aa 10 80       	push   $0x8010aac7
80105f8f:	e8 32 a4 ff ff       	call   801003c6 <cprintf>
80105f94:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80105f97:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105f9b:	7f 21                	jg     80105fbe <procdump+0x1cb>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105f9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fa0:	8b 00                	mov    (%eax),%eax
80105fa2:	83 ec 0c             	sub    $0xc,%esp
80105fa5:	68 ce aa 10 80       	push   $0x8010aace
80105faa:	50                   	push   %eax
80105fab:	ff 75 dc             	pushl  -0x24(%ebp)
80105fae:	ff 75 cc             	pushl  -0x34(%ebp)
80105fb1:	68 d0 aa 10 80       	push   $0x8010aad0
80105fb6:	e8 0b a4 ff ff       	call   801003c6 <cprintf>
80105fbb:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
80105fbe:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80105fc2:	7e 27                	jle    80105feb <procdump+0x1f8>
80105fc4:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
80105fc8:	7f 21                	jg     80105feb <procdump+0x1f8>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fcd:	8b 00                	mov    (%eax),%eax
80105fcf:	83 ec 0c             	sub    $0xc,%esp
80105fd2:	68 ce aa 10 80       	push   $0x8010aace
80105fd7:	50                   	push   %eax
80105fd8:	ff 75 dc             	pushl  -0x24(%ebp)
80105fdb:	ff 75 cc             	pushl  -0x34(%ebp)
80105fde:	68 dc aa 10 80       	push   $0x8010aadc
80105fe3:	e8 de a3 ff ff       	call   801003c6 <cprintf>
80105fe8:	83 c4 20             	add    $0x20,%esp
	if(cpum > 100)
80105feb:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
80105fef:	0f 8e 41 01 00 00    	jle    80106136 <procdump+0x343>
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80105ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ff8:	8b 00                	mov    (%eax),%eax
80105ffa:	83 ec 0c             	sub    $0xc,%esp
80105ffd:	68 ce aa 10 80       	push   $0x8010aace
80106002:	50                   	push   %eax
80106003:	ff 75 dc             	pushl  -0x24(%ebp)
80106006:	ff 75 cc             	pushl  -0x34(%ebp)
80106009:	68 e7 aa 10 80       	push   $0x8010aae7
8010600e:	e8 b3 a3 ff ff       	call   801003c6 <cprintf>
80106013:	83 c4 20             	add    $0x20,%esp
80106016:	e9 1b 01 00 00       	jmp    80106136 <procdump+0x343>
    }
    else{
	cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid, p -> priority, elapsed);
8010601b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010601e:	8b b0 94 00 00 00    	mov    0x94(%eax),%esi
80106024:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106027:	8b 40 14             	mov    0x14(%eax),%eax
8010602a:	8b 58 10             	mov    0x10(%eax),%ebx
8010602d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106030:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80106036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106039:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010603f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106042:	8d 78 6c             	lea    0x6c(%eax),%edi
80106045:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106048:	8b 40 10             	mov    0x10(%eax),%eax
8010604b:	ff 75 d8             	pushl  -0x28(%ebp)
8010604e:	56                   	push   %esi
8010604f:	53                   	push   %ebx
80106050:	51                   	push   %ecx
80106051:	52                   	push   %edx
80106052:	57                   	push   %edi
80106053:	50                   	push   %eax
80106054:	68 a0 aa 10 80       	push   $0x8010aaa0
80106059:	e8 68 a3 ff ff       	call   801003c6 <cprintf>
8010605e:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
80106061:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80106065:	7f 16                	jg     8010607d <procdump+0x28a>
	    cprintf("00%d\t%d.", milli, cpue);
80106067:	83 ec 04             	sub    $0x4,%esp
8010606a:	ff 75 d0             	pushl  -0x30(%ebp)
8010606d:	ff 75 d4             	pushl  -0x2c(%ebp)
80106070:	68 b6 aa 10 80       	push   $0x8010aab6
80106075:	e8 4c a3 ff ff       	call   801003c6 <cprintf>
8010607a:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
8010607d:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80106081:	7e 1c                	jle    8010609f <procdump+0x2ac>
80106083:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
80106087:	7f 16                	jg     8010609f <procdump+0x2ac>
	    cprintf("0%d\t%d.", milli, cpue);
80106089:	83 ec 04             	sub    $0x4,%esp
8010608c:	ff 75 d0             	pushl  -0x30(%ebp)
8010608f:	ff 75 d4             	pushl  -0x2c(%ebp)
80106092:	68 bf aa 10 80       	push   $0x8010aabf
80106097:	e8 2a a3 ff ff       	call   801003c6 <cprintf>
8010609c:	83 c4 10             	add    $0x10,%esp
	if(milli > 100)
8010609f:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
801060a3:	7e 16                	jle    801060bb <procdump+0x2c8>
	    cprintf("%d\t%d.", milli, cpue);
801060a5:	83 ec 04             	sub    $0x4,%esp
801060a8:	ff 75 d0             	pushl  -0x30(%ebp)
801060ab:	ff 75 d4             	pushl  -0x2c(%ebp)
801060ae:	68 c7 aa 10 80       	push   $0x8010aac7
801060b3:	e8 0e a3 ff ff       	call   801003c6 <cprintf>
801060b8:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
801060bb:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
801060bf:	7f 21                	jg     801060e2 <procdump+0x2ef>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
801060c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060c4:	8b 00                	mov    (%eax),%eax
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	68 ce aa 10 80       	push   $0x8010aace
801060ce:	50                   	push   %eax
801060cf:	ff 75 dc             	pushl  -0x24(%ebp)
801060d2:	ff 75 cc             	pushl  -0x34(%ebp)
801060d5:	68 d0 aa 10 80       	push   $0x8010aad0
801060da:	e8 e7 a2 ff ff       	call   801003c6 <cprintf>
801060df:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
801060e2:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
801060e6:	7e 27                	jle    8010610f <procdump+0x31c>
801060e8:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
801060ec:	7f 21                	jg     8010610f <procdump+0x31c>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
801060ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060f1:	8b 00                	mov    (%eax),%eax
801060f3:	83 ec 0c             	sub    $0xc,%esp
801060f6:	68 ce aa 10 80       	push   $0x8010aace
801060fb:	50                   	push   %eax
801060fc:	ff 75 dc             	pushl  -0x24(%ebp)
801060ff:	ff 75 cc             	pushl  -0x34(%ebp)
80106102:	68 dc aa 10 80       	push   $0x8010aadc
80106107:	e8 ba a2 ff ff       	call   801003c6 <cprintf>
8010610c:	83 c4 20             	add    $0x20,%esp
	if(cpum > 100)
8010610f:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
80106113:	7e 21                	jle    80106136 <procdump+0x343>
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80106115:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106118:	8b 00                	mov    (%eax),%eax
8010611a:	83 ec 0c             	sub    $0xc,%esp
8010611d:	68 ce aa 10 80       	push   $0x8010aace
80106122:	50                   	push   %eax
80106123:	ff 75 dc             	pushl  -0x24(%ebp)
80106126:	ff 75 cc             	pushl  -0x34(%ebp)
80106129:	68 e7 aa 10 80       	push   $0x8010aae7
8010612e:	e8 93 a2 ff ff       	call   801003c6 <cprintf>
80106133:	83 c4 20             	add    $0x20,%esp
    }
    if(p->state == SLEEPING){
80106136:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106139:	8b 40 0c             	mov    0xc(%eax),%eax
8010613c:	83 f8 02             	cmp    $0x2,%eax
8010613f:	75 54                	jne    80106195 <procdump+0x3a2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80106141:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106144:	8b 40 1c             	mov    0x1c(%eax),%eax
80106147:	8b 40 0c             	mov    0xc(%eax),%eax
8010614a:	83 c0 08             	add    $0x8,%eax
8010614d:	89 c2                	mov    %eax,%edx
8010614f:	83 ec 08             	sub    $0x8,%esp
80106152:	8d 45 a4             	lea    -0x5c(%ebp),%eax
80106155:	50                   	push   %eax
80106156:	52                   	push   %edx
80106157:	e8 ff 0b 00 00       	call   80106d5b <getcallerpcs>
8010615c:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010615f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106166:	eb 1c                	jmp    80106184 <procdump+0x391>
        cprintf(" %p", pc[i]);
80106168:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616b:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
8010616f:	83 ec 08             	sub    $0x8,%esp
80106172:	50                   	push   %eax
80106173:	68 f1 aa 10 80       	push   $0x8010aaf1
80106178:	e8 49 a2 ff ff       	call   801003c6 <cprintf>
8010617d:	83 c4 10             	add    $0x10,%esp
	if(cpum > 100)
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80106180:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80106184:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
80106188:	7f 0b                	jg     80106195 <procdump+0x3a2>
8010618a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010618d:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
80106191:	85 c0                	test   %eax,%eax
80106193:	75 d3                	jne    80106168 <procdump+0x375>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80106195:	83 ec 0c             	sub    $0xc,%esp
80106198:	68 ce aa 10 80       	push   $0x8010aace
8010619d:	e8 24 a2 ff ff       	call   801003c6 <cprintf>
801061a2:	83 c4 10             	add    $0x10,%esp
801061a5:	eb 01                	jmp    801061a8 <procdump+0x3b5>
    while(0)
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801061a7:	90                   	nop

    char *state = "???";
    while(0)
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801061a8:	81 45 e0 9c 00 00 00 	addl   $0x9c,-0x20(%ebp)
801061af:	81 7d e0 b4 70 11 80 	cmpl   $0x801170b4,-0x20(%ebp)
801061b6:	0f 82 74 fc ff ff    	jb     80105e30 <procdump+0x3d>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

    cprintf("\n");
801061bc:	83 ec 0c             	sub    $0xc,%esp
801061bf:	68 ce aa 10 80       	push   $0x8010aace
801061c4:	e8 fd a1 ff ff       	call   801003c6 <cprintf>
801061c9:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
801061cc:	83 ec 0c             	sub    $0xc,%esp
801061cf:	68 80 49 11 80       	push   $0x80114980
801061d4:	e8 30 0b 00 00       	call   80106d09 <release>
801061d9:	83 c4 10             	add    $0x10,%esp
}
801061dc:	90                   	nop
801061dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061e0:	5b                   	pop    %ebx
801061e1:	5e                   	pop    %esi
801061e2:	5f                   	pop    %edi
801061e3:	5d                   	pop    %ebp
801061e4:	c3                   	ret    

801061e5 <getproctable>:
}

#else
int 
getproctable(uint max, struct uproc* table)
{
801061e5:	55                   	push   %ebp
801061e6:	89 e5                	mov    %esp,%ebp
801061e8:	53                   	push   %ebx
801061e9:	83 ec 14             	sub    $0x14,%esp
    int i = 0;
801061ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);
801061f3:	83 ec 0c             	sub    $0xc,%esp
801061f6:	68 80 49 11 80       	push   $0x80114980
801061fb:	e8 a2 0a 00 00       	call   80106ca2 <acquire>
80106200:	83 c4 10             	add    $0x10,%esp

    for(int j = 0; j < MAX+1; ++j){
80106203:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010620a:	e9 ca 01 00 00       	jmp    801063d9 <getproctable+0x1f4>
	p = ptable.pLists.ready[j];
8010620f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106212:	05 cc 09 00 00       	add    $0x9cc,%eax
80106217:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
8010621e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(p){	
80106221:	e9 a5 01 00 00       	jmp    801063cb <getproctable+0x1e6>
	    table[i].pid = p -> pid;
80106226:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106229:	89 d0                	mov    %edx,%eax
8010622b:	01 c0                	add    %eax,%eax
8010622d:	01 d0                	add    %edx,%eax
8010622f:	c1 e0 05             	shl    $0x5,%eax
80106232:	89 c2                	mov    %eax,%edx
80106234:	8b 45 0c             	mov    0xc(%ebp),%eax
80106237:	01 c2                	add    %eax,%edx
80106239:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623c:	8b 40 10             	mov    0x10(%eax),%eax
8010623f:	89 02                	mov    %eax,(%edx)
	    table[i].uid = p -> uid;
80106241:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106244:	89 d0                	mov    %edx,%eax
80106246:	01 c0                	add    %eax,%eax
80106248:	01 d0                	add    %edx,%eax
8010624a:	c1 e0 05             	shl    $0x5,%eax
8010624d:	89 c2                	mov    %eax,%edx
8010624f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106252:	01 c2                	add    %eax,%edx
80106254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106257:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010625d:	89 42 04             	mov    %eax,0x4(%edx)
	    table[i].gid = p -> gid;
80106260:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106263:	89 d0                	mov    %edx,%eax
80106265:	01 c0                	add    %eax,%eax
80106267:	01 d0                	add    %edx,%eax
80106269:	c1 e0 05             	shl    $0x5,%eax
8010626c:	89 c2                	mov    %eax,%edx
8010626e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106271:	01 c2                	add    %eax,%edx
80106273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106276:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010627c:	89 42 08             	mov    %eax,0x8(%edx)
	    table[i].priority = p -> priority;
8010627f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106282:	89 d0                	mov    %edx,%eax
80106284:	01 c0                	add    %eax,%eax
80106286:	01 d0                	add    %edx,%eax
80106288:	c1 e0 05             	shl    $0x5,%eax
8010628b:	89 c2                	mov    %eax,%edx
8010628d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106290:	01 c2                	add    %eax,%edx
80106292:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106295:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010629b:	89 42 5c             	mov    %eax,0x5c(%edx)

	    if(p -> pid == 1)
8010629e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a1:	8b 40 10             	mov    0x10(%eax),%eax
801062a4:	83 f8 01             	cmp    $0x1,%eax
801062a7:	75 1c                	jne    801062c5 <getproctable+0xe0>
		table[i].ppid = 1;
801062a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062ac:	89 d0                	mov    %edx,%eax
801062ae:	01 c0                	add    %eax,%eax
801062b0:	01 d0                	add    %edx,%eax
801062b2:	c1 e0 05             	shl    $0x5,%eax
801062b5:	89 c2                	mov    %eax,%edx
801062b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801062ba:	01 d0                	add    %edx,%eax
801062bc:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
801062c3:	eb 1f                	jmp    801062e4 <getproctable+0xff>
	    else
		table[i].ppid = p -> parent -> pid;
801062c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c8:	89 d0                	mov    %edx,%eax
801062ca:	01 c0                	add    %eax,%eax
801062cc:	01 d0                	add    %edx,%eax
801062ce:	c1 e0 05             	shl    $0x5,%eax
801062d1:	89 c2                	mov    %eax,%edx
801062d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801062d6:	01 c2                	add    %eax,%edx
801062d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062db:	8b 40 14             	mov    0x14(%eax),%eax
801062de:	8b 40 10             	mov    0x10(%eax),%eax
801062e1:	89 42 0c             	mov    %eax,0xc(%edx)
		
	    table[i].elapsed_ticks = ticks - (p -> start_ticks);
801062e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062e7:	89 d0                	mov    %edx,%eax
801062e9:	01 c0                	add    %eax,%eax
801062eb:	01 d0                	add    %edx,%eax
801062ed:	c1 e0 05             	shl    $0x5,%eax
801062f0:	89 c2                	mov    %eax,%edx
801062f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801062f5:	01 c2                	add    %eax,%edx
801062f7:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
801062fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106300:	8b 40 7c             	mov    0x7c(%eax),%eax
80106303:	29 c1                	sub    %eax,%ecx
80106305:	89 c8                	mov    %ecx,%eax
80106307:	89 42 10             	mov    %eax,0x10(%edx)

	    table[i].CPU_total_ticks = p -> cpu_ticks_total;
8010630a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010630d:	89 d0                	mov    %edx,%eax
8010630f:	01 c0                	add    %eax,%eax
80106311:	01 d0                	add    %edx,%eax
80106313:	c1 e0 05             	shl    $0x5,%eax
80106316:	89 c2                	mov    %eax,%edx
80106318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010631b:	01 c2                	add    %eax,%edx
8010631d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106320:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106326:	89 42 14             	mov    %eax,0x14(%edx)

	    safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
80106329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632c:	8b 40 0c             	mov    0xc(%eax),%eax
8010632f:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80106336:	83 ec 0c             	sub    $0xc,%esp
80106339:	50                   	push   %eax
8010633a:	e8 13 0e 00 00       	call   80107152 <strlen>
8010633f:	83 c4 10             	add    $0x10,%esp
80106342:	89 c3                	mov    %eax,%ebx
80106344:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106347:	8b 40 0c             	mov    0xc(%eax),%eax
8010634a:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
80106351:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106354:	89 d0                	mov    %edx,%eax
80106356:	01 c0                	add    %eax,%eax
80106358:	01 d0                	add    %edx,%eax
8010635a:	c1 e0 05             	shl    $0x5,%eax
8010635d:	89 c2                	mov    %eax,%edx
8010635f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106362:	01 d0                	add    %edx,%eax
80106364:	83 c0 18             	add    $0x18,%eax
80106367:	83 ec 04             	sub    $0x4,%esp
8010636a:	53                   	push   %ebx
8010636b:	51                   	push   %ecx
8010636c:	50                   	push   %eax
8010636d:	e8 96 0d 00 00       	call   80107108 <safestrcpy>
80106372:	83 c4 10             	add    $0x10,%esp

	    table[i].size = p -> sz;
80106375:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106378:	89 d0                	mov    %edx,%eax
8010637a:	01 c0                	add    %eax,%eax
8010637c:	01 d0                	add    %edx,%eax
8010637e:	c1 e0 05             	shl    $0x5,%eax
80106381:	89 c2                	mov    %eax,%edx
80106383:	8b 45 0c             	mov    0xc(%ebp),%eax
80106386:	01 c2                	add    %eax,%edx
80106388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638b:	8b 00                	mov    (%eax),%eax
8010638d:	89 42 38             	mov    %eax,0x38(%edx)

	    safestrcpy(table[i].name,p -> name, STRMAX);
80106390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106393:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106399:	89 d0                	mov    %edx,%eax
8010639b:	01 c0                	add    %eax,%eax
8010639d:	01 d0                	add    %edx,%eax
8010639f:	c1 e0 05             	shl    $0x5,%eax
801063a2:	89 c2                	mov    %eax,%edx
801063a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801063a7:	01 d0                	add    %edx,%eax
801063a9:	83 c0 3c             	add    $0x3c,%eax
801063ac:	83 ec 04             	sub    $0x4,%esp
801063af:	6a 20                	push   $0x20
801063b1:	51                   	push   %ecx
801063b2:	50                   	push   %eax
801063b3:	e8 50 0d 00 00       	call   80107108 <safestrcpy>
801063b8:	83 c4 10             	add    $0x10,%esp
	    p = p -> next;
801063bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063be:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801063c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    ++i;
801063c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    //acquire lock
    acquire(&ptable.lock);

    for(int j = 0; j < MAX+1; ++j){
	p = ptable.pLists.ready[j];
	while(p){	
801063cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063cf:	0f 85 51 fe ff ff    	jne    80106226 <getproctable+0x41>
    int i = 0;
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);

    for(int j = 0; j < MAX+1; ++j){
801063d5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801063d9:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
801063dd:	0f 8e 2c fe ff ff    	jle    8010620f <getproctable+0x2a>
	    safestrcpy(table[i].name,p -> name, STRMAX);
	    p = p -> next;
	    ++i;
	}
    }
    p = ptable.pLists.sleep;
801063e3:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801063e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(p){	
801063eb:	e9 a5 01 00 00       	jmp    80106595 <getproctable+0x3b0>
	table[i].pid = p -> pid;
801063f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063f3:	89 d0                	mov    %edx,%eax
801063f5:	01 c0                	add    %eax,%eax
801063f7:	01 d0                	add    %edx,%eax
801063f9:	c1 e0 05             	shl    $0x5,%eax
801063fc:	89 c2                	mov    %eax,%edx
801063fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80106401:	01 c2                	add    %eax,%edx
80106403:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106406:	8b 40 10             	mov    0x10(%eax),%eax
80106409:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
8010640b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010640e:	89 d0                	mov    %edx,%eax
80106410:	01 c0                	add    %eax,%eax
80106412:	01 d0                	add    %edx,%eax
80106414:	c1 e0 05             	shl    $0x5,%eax
80106417:	89 c2                	mov    %eax,%edx
80106419:	8b 45 0c             	mov    0xc(%ebp),%eax
8010641c:	01 c2                	add    %eax,%edx
8010641e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106421:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106427:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
8010642a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010642d:	89 d0                	mov    %edx,%eax
8010642f:	01 c0                	add    %eax,%eax
80106431:	01 d0                	add    %edx,%eax
80106433:	c1 e0 05             	shl    $0x5,%eax
80106436:	89 c2                	mov    %eax,%edx
80106438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010643b:	01 c2                	add    %eax,%edx
8010643d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106440:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106446:	89 42 08             	mov    %eax,0x8(%edx)
	table[i].priority = p -> priority;
80106449:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010644c:	89 d0                	mov    %edx,%eax
8010644e:	01 c0                	add    %eax,%eax
80106450:	01 d0                	add    %edx,%eax
80106452:	c1 e0 05             	shl    $0x5,%eax
80106455:	89 c2                	mov    %eax,%edx
80106457:	8b 45 0c             	mov    0xc(%ebp),%eax
8010645a:	01 c2                	add    %eax,%edx
8010645c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645f:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106465:	89 42 5c             	mov    %eax,0x5c(%edx)

	if(p -> pid == 1)
80106468:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646b:	8b 40 10             	mov    0x10(%eax),%eax
8010646e:	83 f8 01             	cmp    $0x1,%eax
80106471:	75 1c                	jne    8010648f <getproctable+0x2aa>
	    table[i].ppid = 1;
80106473:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106476:	89 d0                	mov    %edx,%eax
80106478:	01 c0                	add    %eax,%eax
8010647a:	01 d0                	add    %edx,%eax
8010647c:	c1 e0 05             	shl    $0x5,%eax
8010647f:	89 c2                	mov    %eax,%edx
80106481:	8b 45 0c             	mov    0xc(%ebp),%eax
80106484:	01 d0                	add    %edx,%eax
80106486:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
8010648d:	eb 1f                	jmp    801064ae <getproctable+0x2c9>
	else
	    table[i].ppid = p -> parent -> pid;
8010648f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106492:	89 d0                	mov    %edx,%eax
80106494:	01 c0                	add    %eax,%eax
80106496:	01 d0                	add    %edx,%eax
80106498:	c1 e0 05             	shl    $0x5,%eax
8010649b:	89 c2                	mov    %eax,%edx
8010649d:	8b 45 0c             	mov    0xc(%ebp),%eax
801064a0:	01 c2                	add    %eax,%edx
801064a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a5:	8b 40 14             	mov    0x14(%eax),%eax
801064a8:	8b 40 10             	mov    0x10(%eax),%eax
801064ab:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
801064ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064b1:	89 d0                	mov    %edx,%eax
801064b3:	01 c0                	add    %eax,%eax
801064b5:	01 d0                	add    %edx,%eax
801064b7:	c1 e0 05             	shl    $0x5,%eax
801064ba:	89 c2                	mov    %eax,%edx
801064bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801064bf:	01 c2                	add    %eax,%edx
801064c1:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
801064c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ca:	8b 40 7c             	mov    0x7c(%eax),%eax
801064cd:	29 c1                	sub    %eax,%ecx
801064cf:	89 c8                	mov    %ecx,%eax
801064d1:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
801064d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064d7:	89 d0                	mov    %edx,%eax
801064d9:	01 c0                	add    %eax,%eax
801064db:	01 d0                	add    %edx,%eax
801064dd:	c1 e0 05             	shl    $0x5,%eax
801064e0:	89 c2                	mov    %eax,%edx
801064e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801064e5:	01 c2                	add    %eax,%edx
801064e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ea:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801064f0:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
801064f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f6:	8b 40 0c             	mov    0xc(%eax),%eax
801064f9:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80106500:	83 ec 0c             	sub    $0xc,%esp
80106503:	50                   	push   %eax
80106504:	e8 49 0c 00 00       	call   80107152 <strlen>
80106509:	83 c4 10             	add    $0x10,%esp
8010650c:	89 c3                	mov    %eax,%ebx
8010650e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106511:	8b 40 0c             	mov    0xc(%eax),%eax
80106514:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
8010651b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010651e:	89 d0                	mov    %edx,%eax
80106520:	01 c0                	add    %eax,%eax
80106522:	01 d0                	add    %edx,%eax
80106524:	c1 e0 05             	shl    $0x5,%eax
80106527:	89 c2                	mov    %eax,%edx
80106529:	8b 45 0c             	mov    0xc(%ebp),%eax
8010652c:	01 d0                	add    %edx,%eax
8010652e:	83 c0 18             	add    $0x18,%eax
80106531:	83 ec 04             	sub    $0x4,%esp
80106534:	53                   	push   %ebx
80106535:	51                   	push   %ecx
80106536:	50                   	push   %eax
80106537:	e8 cc 0b 00 00       	call   80107108 <safestrcpy>
8010653c:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
8010653f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106542:	89 d0                	mov    %edx,%eax
80106544:	01 c0                	add    %eax,%eax
80106546:	01 d0                	add    %edx,%eax
80106548:	c1 e0 05             	shl    $0x5,%eax
8010654b:	89 c2                	mov    %eax,%edx
8010654d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106550:	01 c2                	add    %eax,%edx
80106552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106555:	8b 00                	mov    (%eax),%eax
80106557:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
8010655a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010655d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106563:	89 d0                	mov    %edx,%eax
80106565:	01 c0                	add    %eax,%eax
80106567:	01 d0                	add    %edx,%eax
80106569:	c1 e0 05             	shl    $0x5,%eax
8010656c:	89 c2                	mov    %eax,%edx
8010656e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106571:	01 d0                	add    %edx,%eax
80106573:	83 c0 3c             	add    $0x3c,%eax
80106576:	83 ec 04             	sub    $0x4,%esp
80106579:	6a 20                	push   $0x20
8010657b:	51                   	push   %ecx
8010657c:	50                   	push   %eax
8010657d:	e8 86 0b 00 00       	call   80107108 <safestrcpy>
80106582:	83 c4 10             	add    $0x10,%esp
	p = p -> next;
80106585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106588:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010658e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	++i;
80106591:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	    p = p -> next;
	    ++i;
	}
    }
    p = ptable.pLists.sleep;
    while(p){	
80106595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106599:	0f 85 51 fe ff ff    	jne    801063f0 <getproctable+0x20b>
	safestrcpy(table[i].name,p -> name, STRMAX);
	p = p -> next;
	++i;
    }

    p = ptable.pLists.running;
8010659f:	a1 d4 70 11 80       	mov    0x801170d4,%eax
801065a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(p){	
801065a7:	e9 a5 01 00 00       	jmp    80106751 <getproctable+0x56c>
	table[i].pid = p -> pid;
801065ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065af:	89 d0                	mov    %edx,%eax
801065b1:	01 c0                	add    %eax,%eax
801065b3:	01 d0                	add    %edx,%eax
801065b5:	c1 e0 05             	shl    $0x5,%eax
801065b8:	89 c2                	mov    %eax,%edx
801065ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801065bd:	01 c2                	add    %eax,%edx
801065bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c2:	8b 40 10             	mov    0x10(%eax),%eax
801065c5:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
801065c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065ca:	89 d0                	mov    %edx,%eax
801065cc:	01 c0                	add    %eax,%eax
801065ce:	01 d0                	add    %edx,%eax
801065d0:	c1 e0 05             	shl    $0x5,%eax
801065d3:	89 c2                	mov    %eax,%edx
801065d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801065d8:	01 c2                	add    %eax,%edx
801065da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065dd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801065e3:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
801065e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065e9:	89 d0                	mov    %edx,%eax
801065eb:	01 c0                	add    %eax,%eax
801065ed:	01 d0                	add    %edx,%eax
801065ef:	c1 e0 05             	shl    $0x5,%eax
801065f2:	89 c2                	mov    %eax,%edx
801065f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801065f7:	01 c2                	add    %eax,%edx
801065f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fc:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106602:	89 42 08             	mov    %eax,0x8(%edx)
	table[i].priority = p -> priority;
80106605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106608:	89 d0                	mov    %edx,%eax
8010660a:	01 c0                	add    %eax,%eax
8010660c:	01 d0                	add    %edx,%eax
8010660e:	c1 e0 05             	shl    $0x5,%eax
80106611:	89 c2                	mov    %eax,%edx
80106613:	8b 45 0c             	mov    0xc(%ebp),%eax
80106616:	01 c2                	add    %eax,%edx
80106618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661b:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106621:	89 42 5c             	mov    %eax,0x5c(%edx)

	if(p -> pid == 1)
80106624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106627:	8b 40 10             	mov    0x10(%eax),%eax
8010662a:	83 f8 01             	cmp    $0x1,%eax
8010662d:	75 1c                	jne    8010664b <getproctable+0x466>
	    table[i].ppid = 1;
8010662f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106632:	89 d0                	mov    %edx,%eax
80106634:	01 c0                	add    %eax,%eax
80106636:	01 d0                	add    %edx,%eax
80106638:	c1 e0 05             	shl    $0x5,%eax
8010663b:	89 c2                	mov    %eax,%edx
8010663d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106640:	01 d0                	add    %edx,%eax
80106642:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
80106649:	eb 1f                	jmp    8010666a <getproctable+0x485>
	else
	    table[i].ppid = p -> parent -> pid;
8010664b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010664e:	89 d0                	mov    %edx,%eax
80106650:	01 c0                	add    %eax,%eax
80106652:	01 d0                	add    %edx,%eax
80106654:	c1 e0 05             	shl    $0x5,%eax
80106657:	89 c2                	mov    %eax,%edx
80106659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010665c:	01 c2                	add    %eax,%edx
8010665e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106661:	8b 40 14             	mov    0x14(%eax),%eax
80106664:	8b 40 10             	mov    0x10(%eax),%eax
80106667:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
8010666a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010666d:	89 d0                	mov    %edx,%eax
8010666f:	01 c0                	add    %eax,%eax
80106671:	01 d0                	add    %edx,%eax
80106673:	c1 e0 05             	shl    $0x5,%eax
80106676:	89 c2                	mov    %eax,%edx
80106678:	8b 45 0c             	mov    0xc(%ebp),%eax
8010667b:	01 c2                	add    %eax,%edx
8010667d:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
80106683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106686:	8b 40 7c             	mov    0x7c(%eax),%eax
80106689:	29 c1                	sub    %eax,%ecx
8010668b:	89 c8                	mov    %ecx,%eax
8010668d:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
80106690:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106693:	89 d0                	mov    %edx,%eax
80106695:	01 c0                	add    %eax,%eax
80106697:	01 d0                	add    %edx,%eax
80106699:	c1 e0 05             	shl    $0x5,%eax
8010669c:	89 c2                	mov    %eax,%edx
8010669e:	8b 45 0c             	mov    0xc(%ebp),%eax
801066a1:	01 c2                	add    %eax,%edx
801066a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066a6:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801066ac:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
801066af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b2:	8b 40 0c             	mov    0xc(%eax),%eax
801066b5:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801066bc:	83 ec 0c             	sub    $0xc,%esp
801066bf:	50                   	push   %eax
801066c0:	e8 8d 0a 00 00       	call   80107152 <strlen>
801066c5:	83 c4 10             	add    $0x10,%esp
801066c8:	89 c3                	mov    %eax,%ebx
801066ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066cd:	8b 40 0c             	mov    0xc(%eax),%eax
801066d0:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
801066d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066da:	89 d0                	mov    %edx,%eax
801066dc:	01 c0                	add    %eax,%eax
801066de:	01 d0                	add    %edx,%eax
801066e0:	c1 e0 05             	shl    $0x5,%eax
801066e3:	89 c2                	mov    %eax,%edx
801066e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801066e8:	01 d0                	add    %edx,%eax
801066ea:	83 c0 18             	add    $0x18,%eax
801066ed:	83 ec 04             	sub    $0x4,%esp
801066f0:	53                   	push   %ebx
801066f1:	51                   	push   %ecx
801066f2:	50                   	push   %eax
801066f3:	e8 10 0a 00 00       	call   80107108 <safestrcpy>
801066f8:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
801066fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066fe:	89 d0                	mov    %edx,%eax
80106700:	01 c0                	add    %eax,%eax
80106702:	01 d0                	add    %edx,%eax
80106704:	c1 e0 05             	shl    $0x5,%eax
80106707:	89 c2                	mov    %eax,%edx
80106709:	8b 45 0c             	mov    0xc(%ebp),%eax
8010670c:	01 c2                	add    %eax,%edx
8010670e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106711:	8b 00                	mov    (%eax),%eax
80106713:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
80106716:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106719:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010671c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010671f:	89 d0                	mov    %edx,%eax
80106721:	01 c0                	add    %eax,%eax
80106723:	01 d0                	add    %edx,%eax
80106725:	c1 e0 05             	shl    $0x5,%eax
80106728:	89 c2                	mov    %eax,%edx
8010672a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010672d:	01 d0                	add    %edx,%eax
8010672f:	83 c0 3c             	add    $0x3c,%eax
80106732:	83 ec 04             	sub    $0x4,%esp
80106735:	6a 20                	push   $0x20
80106737:	51                   	push   %ecx
80106738:	50                   	push   %eax
80106739:	e8 ca 09 00 00       	call   80107108 <safestrcpy>
8010673e:	83 c4 10             	add    $0x10,%esp
	p = p -> next;
80106741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106744:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010674a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	++i;
8010674d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	p = p -> next;
	++i;
    }

    p = ptable.pLists.running;
    while(p){	
80106751:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106755:	0f 85 51 fe ff ff    	jne    801065ac <getproctable+0x3c7>
	++i;
    }

   
    //release lock
    release(&ptable.lock);
8010675b:	83 ec 0c             	sub    $0xc,%esp
8010675e:	68 80 49 11 80       	push   $0x80114980
80106763:	e8 a1 05 00 00       	call   80106d09 <release>
80106768:	83 c4 10             	add    $0x10,%esp
    return i +1;
8010676b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676e:	83 c0 01             	add    $0x1,%eax
}
80106771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106774:	c9                   	leave  
80106775:	c3                   	ret    

80106776 <printready>:


#endif
#ifdef CS333_P3P4
void
printready(void){
80106776:	55                   	push   %ebp
80106777:	89 e5                	mov    %esp,%ebp
80106779:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
8010677c:	83 ec 0c             	sub    $0xc,%esp
8010677f:	68 80 49 11 80       	push   $0x80114980
80106784:	e8 19 05 00 00       	call   80106ca2 <acquire>
80106789:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.ready[0];
8010678c:	a1 b4 70 11 80       	mov    0x801170b4,%eax
80106791:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Ready List Processes:\n\n");
80106794:	83 ec 0c             	sub    $0xc,%esp
80106797:	68 f5 aa 10 80       	push   $0x8010aaf5
8010679c:	e8 25 9c ff ff       	call   801003c6 <cprintf>
801067a1:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < MAX+1; ++i){
801067a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801067ab:	e9 84 00 00 00       	jmp    80106834 <printready+0xbe>
	current = ptable.pLists.ready[i];
801067b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b3:	05 cc 09 00 00       	add    $0x9cc,%eax
801067b8:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
801067bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("%d:",i);
801067c2:	83 ec 08             	sub    $0x8,%esp
801067c5:	ff 75 f0             	pushl  -0x10(%ebp)
801067c8:	68 0d ab 10 80       	push   $0x8010ab0d
801067cd:	e8 f4 9b ff ff       	call   801003c6 <cprintf>
801067d2:	83 c4 10             	add    $0x10,%esp

	if(!current)
801067d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d9:	75 3f                	jne    8010681a <printready+0xa4>
	    cprintf("No Ready Processes\n");
801067db:	83 ec 0c             	sub    $0xc,%esp
801067de:	68 11 ab 10 80       	push   $0x8010ab11
801067e3:	e8 de 9b ff ff       	call   801003c6 <cprintf>
801067e8:	83 c4 10             	add    $0x10,%esp

	while(current){
801067eb:	eb 2d                	jmp    8010681a <printready+0xa4>
	    cprintf("(%d, %d) -> ", current -> pid, current -> budget);
801067ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f0:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
801067f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f9:	8b 40 10             	mov    0x10(%eax),%eax
801067fc:	83 ec 04             	sub    $0x4,%esp
801067ff:	52                   	push   %edx
80106800:	50                   	push   %eax
80106801:	68 25 ab 10 80       	push   $0x8010ab25
80106806:	e8 bb 9b ff ff       	call   801003c6 <cprintf>
8010680b:	83 c4 10             	add    $0x10,%esp
	    current = current -> next;
8010680e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106811:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106817:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("%d:",i);

	if(!current)
	    cprintf("No Ready Processes\n");

	while(current){
8010681a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010681e:	75 cd                	jne    801067ed <printready+0x77>
	    cprintf("(%d, %d) -> ", current -> pid, current -> budget);
	    current = current -> next;
	}
	cprintf("\n");
80106820:	83 ec 0c             	sub    $0xc,%esp
80106823:	68 ce aa 10 80       	push   $0x8010aace
80106828:	e8 99 9b ff ff       	call   801003c6 <cprintf>
8010682d:	83 c4 10             	add    $0x10,%esp
printready(void){

    acquire(&ptable.lock);
    struct proc * current = ptable.pLists.ready[0];
    cprintf("Ready List Processes:\n\n");
    for(int i = 0; i < MAX+1; ++i){
80106830:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106834:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80106838:	0f 8e 72 ff ff ff    	jle    801067b0 <printready+0x3a>
	    current = current -> next;
	}
	cprintf("\n");

    }
    release(&ptable.lock);
8010683e:	83 ec 0c             	sub    $0xc,%esp
80106841:	68 80 49 11 80       	push   $0x80114980
80106846:	e8 be 04 00 00       	call   80106d09 <release>
8010684b:	83 c4 10             	add    $0x10,%esp
}
8010684e:	90                   	nop
8010684f:	c9                   	leave  
80106850:	c3                   	ret    

80106851 <printfree>:
void
printfree(void){
80106851:	55                   	push   %ebp
80106852:	89 e5                	mov    %esp,%ebp
80106854:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106857:	83 ec 0c             	sub    $0xc,%esp
8010685a:	68 80 49 11 80       	push   $0x80114980
8010685f:	e8 3e 04 00 00       	call   80106ca2 <acquire>
80106864:	83 c4 10             	add    $0x10,%esp
    int freeprocs = 0;
80106867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc * current = ptable.pLists.free;
8010686e:	a1 c8 70 11 80       	mov    0x801170c8,%eax
80106873:	89 45 f0             	mov    %eax,-0x10(%ebp)

    while(current){
80106876:	eb 10                	jmp    80106888 <printfree+0x37>
	++freeprocs;
80106878:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	current = current -> next;
8010687c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106885:	89 45 f0             	mov    %eax,-0x10(%ebp)

    acquire(&ptable.lock);
    int freeprocs = 0;
    struct proc * current = ptable.pLists.free;

    while(current){
80106888:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010688c:	75 ea                	jne    80106878 <printfree+0x27>
	++freeprocs;
	current = current -> next;
    }

    cprintf("Free list size: %d\n", freeprocs);
8010688e:	83 ec 08             	sub    $0x8,%esp
80106891:	ff 75 f4             	pushl  -0xc(%ebp)
80106894:	68 32 ab 10 80       	push   $0x8010ab32
80106899:	e8 28 9b ff ff       	call   801003c6 <cprintf>
8010689e:	83 c4 10             	add    $0x10,%esp
    
    cprintf("\n");
801068a1:	83 ec 0c             	sub    $0xc,%esp
801068a4:	68 ce aa 10 80       	push   $0x8010aace
801068a9:	e8 18 9b ff ff       	call   801003c6 <cprintf>
801068ae:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
801068b1:	83 ec 0c             	sub    $0xc,%esp
801068b4:	68 80 49 11 80       	push   $0x80114980
801068b9:	e8 4b 04 00 00       	call   80106d09 <release>
801068be:	83 c4 10             	add    $0x10,%esp
}
801068c1:	90                   	nop
801068c2:	c9                   	leave  
801068c3:	c3                   	ret    

801068c4 <printsleep>:
void
printsleep(void){
801068c4:	55                   	push   %ebp
801068c5:	89 e5                	mov    %esp,%ebp
801068c7:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
801068ca:	83 ec 0c             	sub    $0xc,%esp
801068cd:	68 80 49 11 80       	push   $0x80114980
801068d2:	e8 cb 03 00 00       	call   80106ca2 <acquire>
801068d7:	83 c4 10             	add    $0x10,%esp
    cprintf("Sleep List Processes:\n");
801068da:	83 ec 0c             	sub    $0xc,%esp
801068dd:	68 46 ab 10 80       	push   $0x8010ab46
801068e2:	e8 df 9a ff ff       	call   801003c6 <cprintf>
801068e7:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.sleep;
801068ea:	a1 cc 70 11 80       	mov    0x801170cc,%eax
801068ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!current)
801068f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068f6:	75 52                	jne    8010694a <printsleep+0x86>
	cprintf("No Sleeping Processes\n");
801068f8:	83 ec 0c             	sub    $0xc,%esp
801068fb:	68 5d ab 10 80       	push   $0x8010ab5d
80106900:	e8 c1 9a ff ff       	call   801003c6 <cprintf>
80106905:	83 c4 10             	add    $0x10,%esp

    while(current){
80106908:	eb 40                	jmp    8010694a <printsleep+0x86>
	cprintf("%d", current -> pid);
8010690a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690d:	8b 40 10             	mov    0x10(%eax),%eax
80106910:	83 ec 08             	sub    $0x8,%esp
80106913:	50                   	push   %eax
80106914:	68 74 ab 10 80       	push   $0x8010ab74
80106919:	e8 a8 9a ff ff       	call   801003c6 <cprintf>
8010691e:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
80106921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106924:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010692a:	85 c0                	test   %eax,%eax
8010692c:	74 10                	je     8010693e <printsleep+0x7a>
	    cprintf(" -> ");
8010692e:	83 ec 0c             	sub    $0xc,%esp
80106931:	68 77 ab 10 80       	push   $0x8010ab77
80106936:	e8 8b 9a ff ff       	call   801003c6 <cprintf>
8010693b:	83 c4 10             	add    $0x10,%esp
	current = current -> next;
8010693e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106941:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106947:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Sleep List Processes:\n");
    struct proc * current = ptable.pLists.sleep;
    if(!current)
	cprintf("No Sleeping Processes\n");

    while(current){
8010694a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010694e:	75 ba                	jne    8010690a <printsleep+0x46>
	if(current -> next)
	    cprintf(" -> ");
	current = current -> next;
    }

    cprintf("\n\n");
80106950:	83 ec 0c             	sub    $0xc,%esp
80106953:	68 7c ab 10 80       	push   $0x8010ab7c
80106958:	e8 69 9a ff ff       	call   801003c6 <cprintf>
8010695d:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80106960:	83 ec 0c             	sub    $0xc,%esp
80106963:	68 80 49 11 80       	push   $0x80114980
80106968:	e8 9c 03 00 00       	call   80106d09 <release>
8010696d:	83 c4 10             	add    $0x10,%esp
}
80106970:	90                   	nop
80106971:	c9                   	leave  
80106972:	c3                   	ret    

80106973 <printzombie>:
void
printzombie(void){
80106973:	55                   	push   %ebp
80106974:	89 e5                	mov    %esp,%ebp
80106976:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106979:	83 ec 0c             	sub    $0xc,%esp
8010697c:	68 80 49 11 80       	push   $0x80114980
80106981:	e8 1c 03 00 00       	call   80106ca2 <acquire>
80106986:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.zombie;
80106989:	a1 d0 70 11 80       	mov    0x801170d0,%eax
8010698e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Zombie List Processes:\n");
80106991:	83 ec 0c             	sub    $0xc,%esp
80106994:	68 7f ab 10 80       	push   $0x8010ab7f
80106999:	e8 28 9a ff ff       	call   801003c6 <cprintf>
8010699e:	83 c4 10             	add    $0x10,%esp
    if(!current)
801069a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069a5:	0f 85 a2 00 00 00    	jne    80106a4d <printzombie+0xda>
	cprintf("No Zombie Processes\n");
801069ab:	83 ec 0c             	sub    $0xc,%esp
801069ae:	68 97 ab 10 80       	push   $0x8010ab97
801069b3:	e8 0e 9a ff ff       	call   801003c6 <cprintf>
801069b8:	83 c4 10             	add    $0x10,%esp

    while(current){
801069bb:	e9 8d 00 00 00       	jmp    80106a4d <printzombie+0xda>
    if(current -> pid == 1){
801069c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c3:	8b 40 10             	mov    0x10(%eax),%eax
801069c6:	83 f8 01             	cmp    $0x1,%eax
801069c9:	75 38                	jne    80106a03 <printzombie+0x90>
	cprintf("(PID%d, PPID%d)",current -> pid, 1);
801069cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ce:	8b 40 10             	mov    0x10(%eax),%eax
801069d1:	83 ec 04             	sub    $0x4,%esp
801069d4:	6a 01                	push   $0x1
801069d6:	50                   	push   %eax
801069d7:	68 ac ab 10 80       	push   $0x8010abac
801069dc:	e8 e5 99 ff ff       	call   801003c6 <cprintf>
801069e1:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
801069e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801069ed:	85 c0                	test   %eax,%eax
801069ef:	74 50                	je     80106a41 <printzombie+0xce>
	    cprintf(" -> ");
801069f1:	83 ec 0c             	sub    $0xc,%esp
801069f4:	68 77 ab 10 80       	push   $0x8010ab77
801069f9:	e8 c8 99 ff ff       	call   801003c6 <cprintf>
801069fe:	83 c4 10             	add    $0x10,%esp
80106a01:	eb 3e                	jmp    80106a41 <printzombie+0xce>
    }
    else{
	cprintf("(PID%d, PPID%d)",current -> pid, current -> parent -> pid);
80106a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a06:	8b 40 14             	mov    0x14(%eax),%eax
80106a09:	8b 50 10             	mov    0x10(%eax),%edx
80106a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0f:	8b 40 10             	mov    0x10(%eax),%eax
80106a12:	83 ec 04             	sub    $0x4,%esp
80106a15:	52                   	push   %edx
80106a16:	50                   	push   %eax
80106a17:	68 ac ab 10 80       	push   $0x8010abac
80106a1c:	e8 a5 99 ff ff       	call   801003c6 <cprintf>
80106a21:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
80106a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a27:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106a2d:	85 c0                	test   %eax,%eax
80106a2f:	74 10                	je     80106a41 <printzombie+0xce>
	    cprintf(" -> ");
80106a31:	83 ec 0c             	sub    $0xc,%esp
80106a34:	68 77 ab 10 80       	push   $0x8010ab77
80106a39:	e8 88 99 ff ff       	call   801003c6 <cprintf>
80106a3e:	83 c4 10             	add    $0x10,%esp
    }
    current = current -> next;	
80106a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a44:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc * current = ptable.pLists.zombie;
    cprintf("Zombie List Processes:\n");
    if(!current)
	cprintf("No Zombie Processes\n");

    while(current){
80106a4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a51:	0f 85 69 ff ff ff    	jne    801069c0 <printzombie+0x4d>
	if(current -> next)
	    cprintf(" -> ");
    }
    current = current -> next;	
    }
    cprintf("\n\n");
80106a57:	83 ec 0c             	sub    $0xc,%esp
80106a5a:	68 7c ab 10 80       	push   $0x8010ab7c
80106a5f:	e8 62 99 ff ff       	call   801003c6 <cprintf>
80106a64:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80106a67:	83 ec 0c             	sub    $0xc,%esp
80106a6a:	68 80 49 11 80       	push   $0x80114980
80106a6f:	e8 95 02 00 00       	call   80106d09 <release>
80106a74:	83 c4 10             	add    $0x10,%esp
}
80106a77:	90                   	nop
80106a78:	c9                   	leave  
80106a79:	c3                   	ret    

80106a7a <setpriority>:
int 
setpriority(int pid, int priority){
80106a7a:	55                   	push   %ebp
80106a7b:	89 e5                	mov    %esp,%ebp
80106a7d:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106a80:	83 ec 0c             	sub    $0xc,%esp
80106a83:	68 80 49 11 80       	push   $0x80114980
80106a88:	e8 15 02 00 00       	call   80106ca2 <acquire>
80106a8d:	83 c4 10             	add    $0x10,%esp

    if(priority < 0 || priority > MAX)
80106a90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106a94:	78 06                	js     80106a9c <setpriority+0x22>
80106a96:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
80106a9a:	7e 0a                	jle    80106aa6 <setpriority+0x2c>
	return -2;
80106a9c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
80106aa1:	e9 a0 01 00 00       	jmp    80106c46 <setpriority+0x1cc>
    if(pid < 1)
80106aa6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106aaa:	7f 0a                	jg     80106ab6 <setpriority+0x3c>
	return -3;
80106aac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
80106ab1:	e9 90 01 00 00       	jmp    80106c46 <setpriority+0x1cc>

    struct proc * current = ptable.pLists.ready[0];
80106ab6:	a1 b4 70 11 80       	mov    0x801170b4,%eax
80106abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i = 0; i < MAX+1; ++i){
80106abe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106ac5:	e9 bb 00 00 00       	jmp    80106b85 <setpriority+0x10b>
	current = ptable.pLists.ready[i];
80106aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106acd:	05 cc 09 00 00       	add    $0x9cc,%eax
80106ad2:	8b 04 85 84 49 11 80 	mov    -0x7feeb67c(,%eax,4),%eax
80106ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while(current){
80106adc:	e9 96 00 00 00       	jmp    80106b77 <setpriority+0xfd>
	    if(current -> pid == pid){
80106ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae4:	8b 50 10             	mov    0x10(%eax),%edx
80106ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80106aea:	39 c2                	cmp    %eax,%edx
80106aec:	75 7d                	jne    80106b6b <setpriority+0xf1>
		current -> priority = priority;
80106aee:	8b 55 0c             	mov    0xc(%ebp),%edx
80106af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af4:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		current -> budget = BUDGET; 
80106afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afd:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106b04:	13 00 00 
		removeFromStateList(&ptable.pLists.ready[i], current);
80106b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b0a:	05 cc 09 00 00       	add    $0x9cc,%eax
80106b0f:	c1 e0 02             	shl    $0x2,%eax
80106b12:	05 80 49 11 80       	add    $0x80114980,%eax
80106b17:	83 c0 04             	add    $0x4,%eax
80106b1a:	83 ec 08             	sub    $0x8,%esp
80106b1d:	ff 75 f4             	pushl  -0xc(%ebp)
80106b20:	50                   	push   %eax
80106b21:	e8 91 dd ff ff       	call   801048b7 <removeFromStateList>
80106b26:	83 c4 10             	add    $0x10,%esp
		addToStateListEnd(&ptable.pLists.ready[current -> priority], current);
80106b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2c:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106b32:	05 cc 09 00 00       	add    $0x9cc,%eax
80106b37:	c1 e0 02             	shl    $0x2,%eax
80106b3a:	05 80 49 11 80       	add    $0x80114980,%eax
80106b3f:	83 c0 04             	add    $0x4,%eax
80106b42:	83 ec 08             	sub    $0x8,%esp
80106b45:	ff 75 f4             	pushl  -0xc(%ebp)
80106b48:	50                   	push   %eax
80106b49:	e8 81 dc ff ff       	call   801047cf <addToStateListEnd>
80106b4e:	83 c4 10             	add    $0x10,%esp
		release(&ptable.lock);
80106b51:	83 ec 0c             	sub    $0xc,%esp
80106b54:	68 80 49 11 80       	push   $0x80114980
80106b59:	e8 ab 01 00 00       	call   80106d09 <release>
80106b5e:	83 c4 10             	add    $0x10,%esp
		return 0;
80106b61:	b8 00 00 00 00       	mov    $0x0,%eax
80106b66:	e9 db 00 00 00       	jmp    80106c46 <setpriority+0x1cc>
	    }
	    current = current -> next;
80106b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106b74:	89 45 f4             	mov    %eax,-0xc(%ebp)

    struct proc * current = ptable.pLists.ready[0];
    for(int i = 0; i < MAX+1; ++i){
	current = ptable.pLists.ready[i];

	while(current){
80106b77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b7b:	0f 85 60 ff ff ff    	jne    80106ae1 <setpriority+0x67>
	return -2;
    if(pid < 1)
	return -3;

    struct proc * current = ptable.pLists.ready[0];
    for(int i = 0; i < MAX+1; ++i){
80106b81:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106b85:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80106b89:	0f 8e 3b ff ff ff    	jle    80106aca <setpriority+0x50>
		return 0;
	    }
	    current = current -> next;
	}
    }
    current = ptable.pLists.sleep;
80106b8f:	a1 cc 70 11 80       	mov    0x801170cc,%eax
80106b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
80106b97:	eb 49                	jmp    80106be2 <setpriority+0x168>
	if(current -> pid == pid){
80106b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9c:	8b 50 10             	mov    0x10(%eax),%edx
80106b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba2:	39 c2                	cmp    %eax,%edx
80106ba4:	75 30                	jne    80106bd6 <setpriority+0x15c>
	    current -> priority = priority;
80106ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bac:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
	    current -> budget = BUDGET; 
80106bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb5:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106bbc:	13 00 00 
	    release(&ptable.lock);
80106bbf:	83 ec 0c             	sub    $0xc,%esp
80106bc2:	68 80 49 11 80       	push   $0x80114980
80106bc7:	e8 3d 01 00 00       	call   80106d09 <release>
80106bcc:	83 c4 10             	add    $0x10,%esp
	    return 0;
80106bcf:	b8 00 00 00 00       	mov    $0x0,%eax
80106bd4:	eb 70                	jmp    80106c46 <setpriority+0x1cc>
	}
	current = current -> next;
80106bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    }
	    current = current -> next;
	}
    }
    current = ptable.pLists.sleep;
    while(current){
80106be2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106be6:	75 b1                	jne    80106b99 <setpriority+0x11f>
	    release(&ptable.lock);
	    return 0;
	}
	current = current -> next;
    }
    current = ptable.pLists.running;
80106be8:	a1 d4 70 11 80       	mov    0x801170d4,%eax
80106bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
80106bf0:	eb 49                	jmp    80106c3b <setpriority+0x1c1>
	if(current -> pid == pid){
80106bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf5:	8b 50 10             	mov    0x10(%eax),%edx
80106bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfb:	39 c2                	cmp    %eax,%edx
80106bfd:	75 30                	jne    80106c2f <setpriority+0x1b5>
	    current -> priority = priority;
80106bff:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c05:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
	    current -> budget = BUDGET; 
80106c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0e:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106c15:	13 00 00 
	    release(&ptable.lock);
80106c18:	83 ec 0c             	sub    $0xc,%esp
80106c1b:	68 80 49 11 80       	push   $0x80114980
80106c20:	e8 e4 00 00 00       	call   80106d09 <release>
80106c25:	83 c4 10             	add    $0x10,%esp
	    return 0;
80106c28:	b8 00 00 00 00       	mov    $0x0,%eax
80106c2d:	eb 17                	jmp    80106c46 <setpriority+0x1cc>
	}
	current = current -> next;
80106c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c32:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    return 0;
	}
	current = current -> next;
    }
    current = ptable.pLists.running;
    while(current){
80106c3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c3f:	75 b1                	jne    80106bf2 <setpriority+0x178>
	    return 0;
	}
	current = current -> next;
    }

    return -1;
80106c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106c46:	c9                   	leave  
80106c47:	c3                   	ret    

80106c48 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80106c48:	55                   	push   %ebp
80106c49:	89 e5                	mov    %esp,%ebp
80106c4b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106c4e:	9c                   	pushf  
80106c4f:	58                   	pop    %eax
80106c50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106c53:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106c56:	c9                   	leave  
80106c57:	c3                   	ret    

80106c58 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80106c58:	55                   	push   %ebp
80106c59:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80106c5b:	fa                   	cli    
}
80106c5c:	90                   	nop
80106c5d:	5d                   	pop    %ebp
80106c5e:	c3                   	ret    

80106c5f <sti>:

static inline void
sti(void)
{
80106c5f:	55                   	push   %ebp
80106c60:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106c62:	fb                   	sti    
}
80106c63:	90                   	nop
80106c64:	5d                   	pop    %ebp
80106c65:	c3                   	ret    

80106c66 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106c66:	55                   	push   %ebp
80106c67:	89 e5                	mov    %esp,%ebp
80106c69:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80106c6c:	8b 55 08             	mov    0x8(%ebp),%edx
80106c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106c75:	f0 87 02             	lock xchg %eax,(%edx)
80106c78:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80106c7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106c7e:	c9                   	leave  
80106c7f:	c3                   	ret    

80106c80 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80106c80:	55                   	push   %ebp
80106c81:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80106c83:	8b 45 08             	mov    0x8(%ebp),%eax
80106c86:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c89:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80106c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80106c95:	8b 45 08             	mov    0x8(%ebp),%eax
80106c98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106c9f:	90                   	nop
80106ca0:	5d                   	pop    %ebp
80106ca1:	c3                   	ret    

80106ca2 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106ca2:	55                   	push   %ebp
80106ca3:	89 e5                	mov    %esp,%ebp
80106ca5:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80106ca8:	e8 52 01 00 00       	call   80106dff <pushcli>
  if(holding(lk))
80106cad:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb0:	83 ec 0c             	sub    $0xc,%esp
80106cb3:	50                   	push   %eax
80106cb4:	e8 1c 01 00 00       	call   80106dd5 <holding>
80106cb9:	83 c4 10             	add    $0x10,%esp
80106cbc:	85 c0                	test   %eax,%eax
80106cbe:	74 0d                	je     80106ccd <acquire+0x2b>
    panic("acquire");
80106cc0:	83 ec 0c             	sub    $0xc,%esp
80106cc3:	68 bc ab 10 80       	push   $0x8010abbc
80106cc8:	e8 99 98 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80106ccd:	90                   	nop
80106cce:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd1:	83 ec 08             	sub    $0x8,%esp
80106cd4:	6a 01                	push   $0x1
80106cd6:	50                   	push   %eax
80106cd7:	e8 8a ff ff ff       	call   80106c66 <xchg>
80106cdc:	83 c4 10             	add    $0x10,%esp
80106cdf:	85 c0                	test   %eax,%eax
80106ce1:	75 eb                	jne    80106cce <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80106ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ced:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80106cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf3:	83 c0 0c             	add    $0xc,%eax
80106cf6:	83 ec 08             	sub    $0x8,%esp
80106cf9:	50                   	push   %eax
80106cfa:	8d 45 08             	lea    0x8(%ebp),%eax
80106cfd:	50                   	push   %eax
80106cfe:	e8 58 00 00 00       	call   80106d5b <getcallerpcs>
80106d03:	83 c4 10             	add    $0x10,%esp
}
80106d06:	90                   	nop
80106d07:	c9                   	leave  
80106d08:	c3                   	ret    

80106d09 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80106d09:	55                   	push   %ebp
80106d0a:	89 e5                	mov    %esp,%ebp
80106d0c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80106d0f:	83 ec 0c             	sub    $0xc,%esp
80106d12:	ff 75 08             	pushl  0x8(%ebp)
80106d15:	e8 bb 00 00 00       	call   80106dd5 <holding>
80106d1a:	83 c4 10             	add    $0x10,%esp
80106d1d:	85 c0                	test   %eax,%eax
80106d1f:	75 0d                	jne    80106d2e <release+0x25>
    panic("release");
80106d21:	83 ec 0c             	sub    $0xc,%esp
80106d24:	68 c4 ab 10 80       	push   $0x8010abc4
80106d29:	e8 38 98 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80106d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d31:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80106d38:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106d42:	8b 45 08             	mov    0x8(%ebp),%eax
80106d45:	83 ec 08             	sub    $0x8,%esp
80106d48:	6a 00                	push   $0x0
80106d4a:	50                   	push   %eax
80106d4b:	e8 16 ff ff ff       	call   80106c66 <xchg>
80106d50:	83 c4 10             	add    $0x10,%esp

  popcli();
80106d53:	e8 ec 00 00 00       	call   80106e44 <popcli>
}
80106d58:	90                   	nop
80106d59:	c9                   	leave  
80106d5a:	c3                   	ret    

80106d5b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80106d5b:	55                   	push   %ebp
80106d5c:	89 e5                	mov    %esp,%ebp
80106d5e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106d61:	8b 45 08             	mov    0x8(%ebp),%eax
80106d64:	83 e8 08             	sub    $0x8,%eax
80106d67:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80106d6a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106d71:	eb 38                	jmp    80106dab <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106d73:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106d77:	74 53                	je     80106dcc <getcallerpcs+0x71>
80106d79:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106d80:	76 4a                	jbe    80106dcc <getcallerpcs+0x71>
80106d82:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106d86:	74 44                	je     80106dcc <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80106d88:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106d92:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d95:	01 c2                	add    %eax,%edx
80106d97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d9a:	8b 40 04             	mov    0x4(%eax),%eax
80106d9d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106da2:	8b 00                	mov    (%eax),%eax
80106da4:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106da7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106dab:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106daf:	7e c2                	jle    80106d73 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106db1:	eb 19                	jmp    80106dcc <getcallerpcs+0x71>
    pcs[i] = 0;
80106db3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106db6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dc0:	01 d0                	add    %edx,%eax
80106dc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106dc8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106dcc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106dd0:	7e e1                	jle    80106db3 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106dd2:	90                   	nop
80106dd3:	c9                   	leave  
80106dd4:	c3                   	ret    

80106dd5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106dd5:	55                   	push   %ebp
80106dd6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80106dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddb:	8b 00                	mov    (%eax),%eax
80106ddd:	85 c0                	test   %eax,%eax
80106ddf:	74 17                	je     80106df8 <holding+0x23>
80106de1:	8b 45 08             	mov    0x8(%ebp),%eax
80106de4:	8b 50 08             	mov    0x8(%eax),%edx
80106de7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ded:	39 c2                	cmp    %eax,%edx
80106def:	75 07                	jne    80106df8 <holding+0x23>
80106df1:	b8 01 00 00 00       	mov    $0x1,%eax
80106df6:	eb 05                	jmp    80106dfd <holding+0x28>
80106df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106dfd:	5d                   	pop    %ebp
80106dfe:	c3                   	ret    

80106dff <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106dff:	55                   	push   %ebp
80106e00:	89 e5                	mov    %esp,%ebp
80106e02:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106e05:	e8 3e fe ff ff       	call   80106c48 <readeflags>
80106e0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80106e0d:	e8 46 fe ff ff       	call   80106c58 <cli>
  if(cpu->ncli++ == 0)
80106e12:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106e19:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106e1f:	8d 48 01             	lea    0x1(%eax),%ecx
80106e22:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80106e28:	85 c0                	test   %eax,%eax
80106e2a:	75 15                	jne    80106e41 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80106e2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e32:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e35:	81 e2 00 02 00 00    	and    $0x200,%edx
80106e3b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106e41:	90                   	nop
80106e42:	c9                   	leave  
80106e43:	c3                   	ret    

80106e44 <popcli>:

void
popcli(void)
{
80106e44:	55                   	push   %ebp
80106e45:	89 e5                	mov    %esp,%ebp
80106e47:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106e4a:	e8 f9 fd ff ff       	call   80106c48 <readeflags>
80106e4f:	25 00 02 00 00       	and    $0x200,%eax
80106e54:	85 c0                	test   %eax,%eax
80106e56:	74 0d                	je     80106e65 <popcli+0x21>
    panic("popcli - interruptible");
80106e58:	83 ec 0c             	sub    $0xc,%esp
80106e5b:	68 cc ab 10 80       	push   $0x8010abcc
80106e60:	e8 01 97 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106e65:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e6b:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106e71:	83 ea 01             	sub    $0x1,%edx
80106e74:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106e7a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106e80:	85 c0                	test   %eax,%eax
80106e82:	79 0d                	jns    80106e91 <popcli+0x4d>
    panic("popcli");
80106e84:	83 ec 0c             	sub    $0xc,%esp
80106e87:	68 e3 ab 10 80       	push   $0x8010abe3
80106e8c:	e8 d5 96 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106e91:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e97:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106e9d:	85 c0                	test   %eax,%eax
80106e9f:	75 15                	jne    80106eb6 <popcli+0x72>
80106ea1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ea7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106ead:	85 c0                	test   %eax,%eax
80106eaf:	74 05                	je     80106eb6 <popcli+0x72>
    sti();
80106eb1:	e8 a9 fd ff ff       	call   80106c5f <sti>
}
80106eb6:	90                   	nop
80106eb7:	c9                   	leave  
80106eb8:	c3                   	ret    

80106eb9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106eb9:	55                   	push   %ebp
80106eba:	89 e5                	mov    %esp,%ebp
80106ebc:	57                   	push   %edi
80106ebd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106ebe:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106ec1:	8b 55 10             	mov    0x10(%ebp),%edx
80106ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ec7:	89 cb                	mov    %ecx,%ebx
80106ec9:	89 df                	mov    %ebx,%edi
80106ecb:	89 d1                	mov    %edx,%ecx
80106ecd:	fc                   	cld    
80106ece:	f3 aa                	rep stos %al,%es:(%edi)
80106ed0:	89 ca                	mov    %ecx,%edx
80106ed2:	89 fb                	mov    %edi,%ebx
80106ed4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106ed7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106eda:	90                   	nop
80106edb:	5b                   	pop    %ebx
80106edc:	5f                   	pop    %edi
80106edd:	5d                   	pop    %ebp
80106ede:	c3                   	ret    

80106edf <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106edf:	55                   	push   %ebp
80106ee0:	89 e5                	mov    %esp,%ebp
80106ee2:	57                   	push   %edi
80106ee3:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106ee4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106ee7:	8b 55 10             	mov    0x10(%ebp),%edx
80106eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80106eed:	89 cb                	mov    %ecx,%ebx
80106eef:	89 df                	mov    %ebx,%edi
80106ef1:	89 d1                	mov    %edx,%ecx
80106ef3:	fc                   	cld    
80106ef4:	f3 ab                	rep stos %eax,%es:(%edi)
80106ef6:	89 ca                	mov    %ecx,%edx
80106ef8:	89 fb                	mov    %edi,%ebx
80106efa:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106efd:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106f00:	90                   	nop
80106f01:	5b                   	pop    %ebx
80106f02:	5f                   	pop    %edi
80106f03:	5d                   	pop    %ebp
80106f04:	c3                   	ret    

80106f05 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106f05:	55                   	push   %ebp
80106f06:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106f08:	8b 45 08             	mov    0x8(%ebp),%eax
80106f0b:	83 e0 03             	and    $0x3,%eax
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	75 43                	jne    80106f55 <memset+0x50>
80106f12:	8b 45 10             	mov    0x10(%ebp),%eax
80106f15:	83 e0 03             	and    $0x3,%eax
80106f18:	85 c0                	test   %eax,%eax
80106f1a:	75 39                	jne    80106f55 <memset+0x50>
    c &= 0xFF;
80106f1c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106f23:	8b 45 10             	mov    0x10(%ebp),%eax
80106f26:	c1 e8 02             	shr    $0x2,%eax
80106f29:	89 c1                	mov    %eax,%ecx
80106f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f2e:	c1 e0 18             	shl    $0x18,%eax
80106f31:	89 c2                	mov    %eax,%edx
80106f33:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f36:	c1 e0 10             	shl    $0x10,%eax
80106f39:	09 c2                	or     %eax,%edx
80106f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f3e:	c1 e0 08             	shl    $0x8,%eax
80106f41:	09 d0                	or     %edx,%eax
80106f43:	0b 45 0c             	or     0xc(%ebp),%eax
80106f46:	51                   	push   %ecx
80106f47:	50                   	push   %eax
80106f48:	ff 75 08             	pushl  0x8(%ebp)
80106f4b:	e8 8f ff ff ff       	call   80106edf <stosl>
80106f50:	83 c4 0c             	add    $0xc,%esp
80106f53:	eb 12                	jmp    80106f67 <memset+0x62>
  } else
    stosb(dst, c, n);
80106f55:	8b 45 10             	mov    0x10(%ebp),%eax
80106f58:	50                   	push   %eax
80106f59:	ff 75 0c             	pushl  0xc(%ebp)
80106f5c:	ff 75 08             	pushl  0x8(%ebp)
80106f5f:	e8 55 ff ff ff       	call   80106eb9 <stosb>
80106f64:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106f67:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106f6a:	c9                   	leave  
80106f6b:	c3                   	ret    

80106f6c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106f6c:	55                   	push   %ebp
80106f6d:	89 e5                	mov    %esp,%ebp
80106f6f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106f72:	8b 45 08             	mov    0x8(%ebp),%eax
80106f75:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f7b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106f7e:	eb 30                	jmp    80106fb0 <memcmp+0x44>
    if(*s1 != *s2)
80106f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f83:	0f b6 10             	movzbl (%eax),%edx
80106f86:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106f89:	0f b6 00             	movzbl (%eax),%eax
80106f8c:	38 c2                	cmp    %al,%dl
80106f8e:	74 18                	je     80106fa8 <memcmp+0x3c>
      return *s1 - *s2;
80106f90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f93:	0f b6 00             	movzbl (%eax),%eax
80106f96:	0f b6 d0             	movzbl %al,%edx
80106f99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106f9c:	0f b6 00             	movzbl (%eax),%eax
80106f9f:	0f b6 c0             	movzbl %al,%eax
80106fa2:	29 c2                	sub    %eax,%edx
80106fa4:	89 d0                	mov    %edx,%eax
80106fa6:	eb 1a                	jmp    80106fc2 <memcmp+0x56>
    s1++, s2++;
80106fa8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106fac:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106fb0:	8b 45 10             	mov    0x10(%ebp),%eax
80106fb3:	8d 50 ff             	lea    -0x1(%eax),%edx
80106fb6:	89 55 10             	mov    %edx,0x10(%ebp)
80106fb9:	85 c0                	test   %eax,%eax
80106fbb:	75 c3                	jne    80106f80 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fc2:	c9                   	leave  
80106fc3:	c3                   	ret    

80106fc4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106fc4:	55                   	push   %ebp
80106fc5:	89 e5                	mov    %esp,%ebp
80106fc7:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106fca:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106fd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106fd9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106fdc:	73 54                	jae    80107032 <memmove+0x6e>
80106fde:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fe1:	8b 45 10             	mov    0x10(%ebp),%eax
80106fe4:	01 d0                	add    %edx,%eax
80106fe6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106fe9:	76 47                	jbe    80107032 <memmove+0x6e>
    s += n;
80106feb:	8b 45 10             	mov    0x10(%ebp),%eax
80106fee:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106ff1:	8b 45 10             	mov    0x10(%ebp),%eax
80106ff4:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106ff7:	eb 13                	jmp    8010700c <memmove+0x48>
      *--d = *--s;
80106ff9:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106ffd:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80107001:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107004:	0f b6 10             	movzbl (%eax),%edx
80107007:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010700a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010700c:	8b 45 10             	mov    0x10(%ebp),%eax
8010700f:	8d 50 ff             	lea    -0x1(%eax),%edx
80107012:	89 55 10             	mov    %edx,0x10(%ebp)
80107015:	85 c0                	test   %eax,%eax
80107017:	75 e0                	jne    80106ff9 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80107019:	eb 24                	jmp    8010703f <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010701b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010701e:	8d 50 01             	lea    0x1(%eax),%edx
80107021:	89 55 f8             	mov    %edx,-0x8(%ebp)
80107024:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107027:	8d 4a 01             	lea    0x1(%edx),%ecx
8010702a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010702d:	0f b6 12             	movzbl (%edx),%edx
80107030:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80107032:	8b 45 10             	mov    0x10(%ebp),%eax
80107035:	8d 50 ff             	lea    -0x1(%eax),%edx
80107038:	89 55 10             	mov    %edx,0x10(%ebp)
8010703b:	85 c0                	test   %eax,%eax
8010703d:	75 dc                	jne    8010701b <memmove+0x57>
      *d++ = *s++;

  return dst;
8010703f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80107042:	c9                   	leave  
80107043:	c3                   	ret    

80107044 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80107044:	55                   	push   %ebp
80107045:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80107047:	ff 75 10             	pushl  0x10(%ebp)
8010704a:	ff 75 0c             	pushl  0xc(%ebp)
8010704d:	ff 75 08             	pushl  0x8(%ebp)
80107050:	e8 6f ff ff ff       	call   80106fc4 <memmove>
80107055:	83 c4 0c             	add    $0xc,%esp
}
80107058:	c9                   	leave  
80107059:	c3                   	ret    

8010705a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010705a:	55                   	push   %ebp
8010705b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010705d:	eb 0c                	jmp    8010706b <strncmp+0x11>
    n--, p++, q++;
8010705f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80107063:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80107067:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010706b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010706f:	74 1a                	je     8010708b <strncmp+0x31>
80107071:	8b 45 08             	mov    0x8(%ebp),%eax
80107074:	0f b6 00             	movzbl (%eax),%eax
80107077:	84 c0                	test   %al,%al
80107079:	74 10                	je     8010708b <strncmp+0x31>
8010707b:	8b 45 08             	mov    0x8(%ebp),%eax
8010707e:	0f b6 10             	movzbl (%eax),%edx
80107081:	8b 45 0c             	mov    0xc(%ebp),%eax
80107084:	0f b6 00             	movzbl (%eax),%eax
80107087:	38 c2                	cmp    %al,%dl
80107089:	74 d4                	je     8010705f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010708b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010708f:	75 07                	jne    80107098 <strncmp+0x3e>
    return 0;
80107091:	b8 00 00 00 00       	mov    $0x0,%eax
80107096:	eb 16                	jmp    801070ae <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80107098:	8b 45 08             	mov    0x8(%ebp),%eax
8010709b:	0f b6 00             	movzbl (%eax),%eax
8010709e:	0f b6 d0             	movzbl %al,%edx
801070a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801070a4:	0f b6 00             	movzbl (%eax),%eax
801070a7:	0f b6 c0             	movzbl %al,%eax
801070aa:	29 c2                	sub    %eax,%edx
801070ac:	89 d0                	mov    %edx,%eax
}
801070ae:	5d                   	pop    %ebp
801070af:	c3                   	ret    

801070b0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801070b0:	55                   	push   %ebp
801070b1:	89 e5                	mov    %esp,%ebp
801070b3:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801070b6:	8b 45 08             	mov    0x8(%ebp),%eax
801070b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801070bc:	90                   	nop
801070bd:	8b 45 10             	mov    0x10(%ebp),%eax
801070c0:	8d 50 ff             	lea    -0x1(%eax),%edx
801070c3:	89 55 10             	mov    %edx,0x10(%ebp)
801070c6:	85 c0                	test   %eax,%eax
801070c8:	7e 2c                	jle    801070f6 <strncpy+0x46>
801070ca:	8b 45 08             	mov    0x8(%ebp),%eax
801070cd:	8d 50 01             	lea    0x1(%eax),%edx
801070d0:	89 55 08             	mov    %edx,0x8(%ebp)
801070d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801070d6:	8d 4a 01             	lea    0x1(%edx),%ecx
801070d9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801070dc:	0f b6 12             	movzbl (%edx),%edx
801070df:	88 10                	mov    %dl,(%eax)
801070e1:	0f b6 00             	movzbl (%eax),%eax
801070e4:	84 c0                	test   %al,%al
801070e6:	75 d5                	jne    801070bd <strncpy+0xd>
    ;
  while(n-- > 0)
801070e8:	eb 0c                	jmp    801070f6 <strncpy+0x46>
    *s++ = 0;
801070ea:	8b 45 08             	mov    0x8(%ebp),%eax
801070ed:	8d 50 01             	lea    0x1(%eax),%edx
801070f0:	89 55 08             	mov    %edx,0x8(%ebp)
801070f3:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801070f6:	8b 45 10             	mov    0x10(%ebp),%eax
801070f9:	8d 50 ff             	lea    -0x1(%eax),%edx
801070fc:	89 55 10             	mov    %edx,0x10(%ebp)
801070ff:	85 c0                	test   %eax,%eax
80107101:	7f e7                	jg     801070ea <strncpy+0x3a>
    *s++ = 0;
  return os;
80107103:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107106:	c9                   	leave  
80107107:	c3                   	ret    

80107108 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80107108:	55                   	push   %ebp
80107109:	89 e5                	mov    %esp,%ebp
8010710b:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010710e:	8b 45 08             	mov    0x8(%ebp),%eax
80107111:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80107114:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107118:	7f 05                	jg     8010711f <safestrcpy+0x17>
    return os;
8010711a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010711d:	eb 31                	jmp    80107150 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010711f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80107123:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107127:	7e 1e                	jle    80107147 <safestrcpy+0x3f>
80107129:	8b 45 08             	mov    0x8(%ebp),%eax
8010712c:	8d 50 01             	lea    0x1(%eax),%edx
8010712f:	89 55 08             	mov    %edx,0x8(%ebp)
80107132:	8b 55 0c             	mov    0xc(%ebp),%edx
80107135:	8d 4a 01             	lea    0x1(%edx),%ecx
80107138:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010713b:	0f b6 12             	movzbl (%edx),%edx
8010713e:	88 10                	mov    %dl,(%eax)
80107140:	0f b6 00             	movzbl (%eax),%eax
80107143:	84 c0                	test   %al,%al
80107145:	75 d8                	jne    8010711f <safestrcpy+0x17>
    ;
  *s = 0;
80107147:	8b 45 08             	mov    0x8(%ebp),%eax
8010714a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010714d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107150:	c9                   	leave  
80107151:	c3                   	ret    

80107152 <strlen>:

int
strlen(const char *s)
{
80107152:	55                   	push   %ebp
80107153:	89 e5                	mov    %esp,%ebp
80107155:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80107158:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010715f:	eb 04                	jmp    80107165 <strlen+0x13>
80107161:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107165:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107168:	8b 45 08             	mov    0x8(%ebp),%eax
8010716b:	01 d0                	add    %edx,%eax
8010716d:	0f b6 00             	movzbl (%eax),%eax
80107170:	84 c0                	test   %al,%al
80107172:	75 ed                	jne    80107161 <strlen+0xf>
    ;
  return n;
80107174:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107177:	c9                   	leave  
80107178:	c3                   	ret    

80107179 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80107179:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010717d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80107181:	55                   	push   %ebp
  pushl %ebx
80107182:	53                   	push   %ebx
  pushl %esi
80107183:	56                   	push   %esi
  pushl %edi
80107184:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80107185:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80107187:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80107189:	5f                   	pop    %edi
  popl %esi
8010718a:	5e                   	pop    %esi
  popl %ebx
8010718b:	5b                   	pop    %ebx
  popl %ebp
8010718c:	5d                   	pop    %ebp
  ret
8010718d:	c3                   	ret    

8010718e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010718e:	55                   	push   %ebp
8010718f:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80107191:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107197:	8b 00                	mov    (%eax),%eax
80107199:	3b 45 08             	cmp    0x8(%ebp),%eax
8010719c:	76 12                	jbe    801071b0 <fetchint+0x22>
8010719e:	8b 45 08             	mov    0x8(%ebp),%eax
801071a1:	8d 50 04             	lea    0x4(%eax),%edx
801071a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071aa:	8b 00                	mov    (%eax),%eax
801071ac:	39 c2                	cmp    %eax,%edx
801071ae:	76 07                	jbe    801071b7 <fetchint+0x29>
    return -1;
801071b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071b5:	eb 0f                	jmp    801071c6 <fetchint+0x38>
  *ip = *(int*)(addr);
801071b7:	8b 45 08             	mov    0x8(%ebp),%eax
801071ba:	8b 10                	mov    (%eax),%edx
801071bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801071bf:	89 10                	mov    %edx,(%eax)
  return 0;
801071c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071c6:	5d                   	pop    %ebp
801071c7:	c3                   	ret    

801071c8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801071c8:	55                   	push   %ebp
801071c9:	89 e5                	mov    %esp,%ebp
801071cb:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801071ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071d4:	8b 00                	mov    (%eax),%eax
801071d6:	3b 45 08             	cmp    0x8(%ebp),%eax
801071d9:	77 07                	ja     801071e2 <fetchstr+0x1a>
    return -1;
801071db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e0:	eb 46                	jmp    80107228 <fetchstr+0x60>
  *pp = (char*)addr;
801071e2:	8b 55 08             	mov    0x8(%ebp),%edx
801071e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801071e8:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801071ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071f0:	8b 00                	mov    (%eax),%eax
801071f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801071f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801071f8:	8b 00                	mov    (%eax),%eax
801071fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
801071fd:	eb 1c                	jmp    8010721b <fetchstr+0x53>
    if(*s == 0)
801071ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107202:	0f b6 00             	movzbl (%eax),%eax
80107205:	84 c0                	test   %al,%al
80107207:	75 0e                	jne    80107217 <fetchstr+0x4f>
      return s - *pp;
80107209:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010720c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010720f:	8b 00                	mov    (%eax),%eax
80107211:	29 c2                	sub    %eax,%edx
80107213:	89 d0                	mov    %edx,%eax
80107215:	eb 11                	jmp    80107228 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80107217:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010721b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010721e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80107221:	72 dc                	jb     801071ff <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80107223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107228:	c9                   	leave  
80107229:	c3                   	ret    

8010722a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010722a:	55                   	push   %ebp
8010722b:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010722d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107233:	8b 40 18             	mov    0x18(%eax),%eax
80107236:	8b 40 44             	mov    0x44(%eax),%eax
80107239:	8b 55 08             	mov    0x8(%ebp),%edx
8010723c:	c1 e2 02             	shl    $0x2,%edx
8010723f:	01 d0                	add    %edx,%eax
80107241:	83 c0 04             	add    $0x4,%eax
80107244:	ff 75 0c             	pushl  0xc(%ebp)
80107247:	50                   	push   %eax
80107248:	e8 41 ff ff ff       	call   8010718e <fetchint>
8010724d:	83 c4 08             	add    $0x8,%esp
}
80107250:	c9                   	leave  
80107251:	c3                   	ret    

80107252 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80107252:	55                   	push   %ebp
80107253:	89 e5                	mov    %esp,%ebp
80107255:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80107258:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010725b:	50                   	push   %eax
8010725c:	ff 75 08             	pushl  0x8(%ebp)
8010725f:	e8 c6 ff ff ff       	call   8010722a <argint>
80107264:	83 c4 08             	add    $0x8,%esp
80107267:	85 c0                	test   %eax,%eax
80107269:	79 07                	jns    80107272 <argptr+0x20>
    return -1;
8010726b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107270:	eb 3b                	jmp    801072ad <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80107272:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107278:	8b 00                	mov    (%eax),%eax
8010727a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010727d:	39 d0                	cmp    %edx,%eax
8010727f:	76 16                	jbe    80107297 <argptr+0x45>
80107281:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107284:	89 c2                	mov    %eax,%edx
80107286:	8b 45 10             	mov    0x10(%ebp),%eax
80107289:	01 c2                	add    %eax,%edx
8010728b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107291:	8b 00                	mov    (%eax),%eax
80107293:	39 c2                	cmp    %eax,%edx
80107295:	76 07                	jbe    8010729e <argptr+0x4c>
    return -1;
80107297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010729c:	eb 0f                	jmp    801072ad <argptr+0x5b>
  *pp = (char*)i;
8010729e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801072a1:	89 c2                	mov    %eax,%edx
801072a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801072a6:	89 10                	mov    %edx,(%eax)
  return 0;
801072a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072ad:	c9                   	leave  
801072ae:	c3                   	ret    

801072af <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801072af:	55                   	push   %ebp
801072b0:	89 e5                	mov    %esp,%ebp
801072b2:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801072b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
801072b8:	50                   	push   %eax
801072b9:	ff 75 08             	pushl  0x8(%ebp)
801072bc:	e8 69 ff ff ff       	call   8010722a <argint>
801072c1:	83 c4 08             	add    $0x8,%esp
801072c4:	85 c0                	test   %eax,%eax
801072c6:	79 07                	jns    801072cf <argstr+0x20>
    return -1;
801072c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072cd:	eb 0f                	jmp    801072de <argstr+0x2f>
  return fetchstr(addr, pp);
801072cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801072d2:	ff 75 0c             	pushl  0xc(%ebp)
801072d5:	50                   	push   %eax
801072d6:	e8 ed fe ff ff       	call   801071c8 <fetchstr>
801072db:	83 c4 08             	add    $0x8,%esp
}
801072de:	c9                   	leave  
801072df:	c3                   	ret    

801072e0 <syscall>:
// put data structure for printing out system call invocation information here

#endif
void
syscall(void)
{
801072e0:	55                   	push   %ebp
801072e1:	89 e5                	mov    %esp,%ebp
801072e3:	53                   	push   %ebx
801072e4:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801072e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072ed:	8b 40 18             	mov    0x18(%eax),%eax
801072f0:	8b 40 1c             	mov    0x1c(%eax),%eax
801072f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801072f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072fa:	7e 30                	jle    8010732c <syscall+0x4c>
801072fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ff:	83 f8 1e             	cmp    $0x1e,%eax
80107302:	77 28                	ja     8010732c <syscall+0x4c>
80107304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107307:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
8010730e:	85 c0                	test   %eax,%eax
80107310:	74 1a                	je     8010732c <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80107312:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107318:	8b 58 18             	mov    0x18(%eax),%ebx
8010731b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731e:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80107325:	ff d0                	call   *%eax
80107327:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010732a:	eb 34                	jmp    80107360 <syscall+0x80>
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010732c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107332:	8d 50 6c             	lea    0x6c(%eax),%edx
80107335:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
#ifdef PRINT_SYSCALLS
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010733b:	8b 40 10             	mov    0x10(%eax),%eax
8010733e:	ff 75 f4             	pushl  -0xc(%ebp)
80107341:	52                   	push   %edx
80107342:	50                   	push   %eax
80107343:	68 ea ab 10 80       	push   $0x8010abea
80107348:	e8 79 90 ff ff       	call   801003c6 <cprintf>
8010734d:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80107350:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107356:	8b 40 18             	mov    0x18(%eax),%eax
80107359:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80107360:	90                   	nop
80107361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107364:	c9                   	leave  
80107365:	c3                   	ret    

80107366 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80107366:	55                   	push   %ebp
80107367:	89 e5                	mov    %esp,%ebp
80107369:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010736c:	83 ec 08             	sub    $0x8,%esp
8010736f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107372:	50                   	push   %eax
80107373:	ff 75 08             	pushl  0x8(%ebp)
80107376:	e8 af fe ff ff       	call   8010722a <argint>
8010737b:	83 c4 10             	add    $0x10,%esp
8010737e:	85 c0                	test   %eax,%eax
80107380:	79 07                	jns    80107389 <argfd+0x23>
    return -1;
80107382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107387:	eb 50                	jmp    801073d9 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80107389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010738c:	85 c0                	test   %eax,%eax
8010738e:	78 21                	js     801073b1 <argfd+0x4b>
80107390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107393:	83 f8 0f             	cmp    $0xf,%eax
80107396:	7f 19                	jg     801073b1 <argfd+0x4b>
80107398:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010739e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073a1:	83 c2 08             	add    $0x8,%edx
801073a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801073a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801073af:	75 07                	jne    801073b8 <argfd+0x52>
    return -1;
801073b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073b6:	eb 21                	jmp    801073d9 <argfd+0x73>
  if(pfd)
801073b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801073bc:	74 08                	je     801073c6 <argfd+0x60>
    *pfd = fd;
801073be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801073c4:	89 10                	mov    %edx,(%eax)
  if(pf)
801073c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801073ca:	74 08                	je     801073d4 <argfd+0x6e>
    *pf = f;
801073cc:	8b 45 10             	mov    0x10(%ebp),%eax
801073cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801073d2:	89 10                	mov    %edx,(%eax)
  return 0;
801073d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073d9:	c9                   	leave  
801073da:	c3                   	ret    

801073db <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801073db:	55                   	push   %ebp
801073dc:	89 e5                	mov    %esp,%ebp
801073de:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801073e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801073e8:	eb 30                	jmp    8010741a <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801073ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801073f3:	83 c2 08             	add    $0x8,%edx
801073f6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801073fa:	85 c0                	test   %eax,%eax
801073fc:	75 18                	jne    80107416 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801073fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107404:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107407:	8d 4a 08             	lea    0x8(%edx),%ecx
8010740a:	8b 55 08             	mov    0x8(%ebp),%edx
8010740d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80107411:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107414:	eb 0f                	jmp    80107425 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80107416:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010741a:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010741e:	7e ca                	jle    801073ea <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80107420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107425:	c9                   	leave  
80107426:	c3                   	ret    

80107427 <sys_dup>:

int
sys_dup(void)
{
80107427:	55                   	push   %ebp
80107428:	89 e5                	mov    %esp,%ebp
8010742a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010742d:	83 ec 04             	sub    $0x4,%esp
80107430:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107433:	50                   	push   %eax
80107434:	6a 00                	push   $0x0
80107436:	6a 00                	push   $0x0
80107438:	e8 29 ff ff ff       	call   80107366 <argfd>
8010743d:	83 c4 10             	add    $0x10,%esp
80107440:	85 c0                	test   %eax,%eax
80107442:	79 07                	jns    8010744b <sys_dup+0x24>
    return -1;
80107444:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107449:	eb 31                	jmp    8010747c <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010744b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010744e:	83 ec 0c             	sub    $0xc,%esp
80107451:	50                   	push   %eax
80107452:	e8 84 ff ff ff       	call   801073db <fdalloc>
80107457:	83 c4 10             	add    $0x10,%esp
8010745a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010745d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107461:	79 07                	jns    8010746a <sys_dup+0x43>
    return -1;
80107463:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107468:	eb 12                	jmp    8010747c <sys_dup+0x55>
  filedup(f);
8010746a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010746d:	83 ec 0c             	sub    $0xc,%esp
80107470:	50                   	push   %eax
80107471:	e8 34 9c ff ff       	call   801010aa <filedup>
80107476:	83 c4 10             	add    $0x10,%esp
  return fd;
80107479:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010747c:	c9                   	leave  
8010747d:	c3                   	ret    

8010747e <sys_read>:

int
sys_read(void)
{
8010747e:	55                   	push   %ebp
8010747f:	89 e5                	mov    %esp,%ebp
80107481:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107484:	83 ec 04             	sub    $0x4,%esp
80107487:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010748a:	50                   	push   %eax
8010748b:	6a 00                	push   $0x0
8010748d:	6a 00                	push   $0x0
8010748f:	e8 d2 fe ff ff       	call   80107366 <argfd>
80107494:	83 c4 10             	add    $0x10,%esp
80107497:	85 c0                	test   %eax,%eax
80107499:	78 2e                	js     801074c9 <sys_read+0x4b>
8010749b:	83 ec 08             	sub    $0x8,%esp
8010749e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801074a1:	50                   	push   %eax
801074a2:	6a 02                	push   $0x2
801074a4:	e8 81 fd ff ff       	call   8010722a <argint>
801074a9:	83 c4 10             	add    $0x10,%esp
801074ac:	85 c0                	test   %eax,%eax
801074ae:	78 19                	js     801074c9 <sys_read+0x4b>
801074b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074b3:	83 ec 04             	sub    $0x4,%esp
801074b6:	50                   	push   %eax
801074b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801074ba:	50                   	push   %eax
801074bb:	6a 01                	push   $0x1
801074bd:	e8 90 fd ff ff       	call   80107252 <argptr>
801074c2:	83 c4 10             	add    $0x10,%esp
801074c5:	85 c0                	test   %eax,%eax
801074c7:	79 07                	jns    801074d0 <sys_read+0x52>
    return -1;
801074c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074ce:	eb 17                	jmp    801074e7 <sys_read+0x69>
  return fileread(f, p, n);
801074d0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801074d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801074d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d9:	83 ec 04             	sub    $0x4,%esp
801074dc:	51                   	push   %ecx
801074dd:	52                   	push   %edx
801074de:	50                   	push   %eax
801074df:	e8 56 9d ff ff       	call   8010123a <fileread>
801074e4:	83 c4 10             	add    $0x10,%esp
}
801074e7:	c9                   	leave  
801074e8:	c3                   	ret    

801074e9 <sys_write>:

int
sys_write(void)
{
801074e9:	55                   	push   %ebp
801074ea:	89 e5                	mov    %esp,%ebp
801074ec:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801074ef:	83 ec 04             	sub    $0x4,%esp
801074f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801074f5:	50                   	push   %eax
801074f6:	6a 00                	push   $0x0
801074f8:	6a 00                	push   $0x0
801074fa:	e8 67 fe ff ff       	call   80107366 <argfd>
801074ff:	83 c4 10             	add    $0x10,%esp
80107502:	85 c0                	test   %eax,%eax
80107504:	78 2e                	js     80107534 <sys_write+0x4b>
80107506:	83 ec 08             	sub    $0x8,%esp
80107509:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010750c:	50                   	push   %eax
8010750d:	6a 02                	push   $0x2
8010750f:	e8 16 fd ff ff       	call   8010722a <argint>
80107514:	83 c4 10             	add    $0x10,%esp
80107517:	85 c0                	test   %eax,%eax
80107519:	78 19                	js     80107534 <sys_write+0x4b>
8010751b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010751e:	83 ec 04             	sub    $0x4,%esp
80107521:	50                   	push   %eax
80107522:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107525:	50                   	push   %eax
80107526:	6a 01                	push   $0x1
80107528:	e8 25 fd ff ff       	call   80107252 <argptr>
8010752d:	83 c4 10             	add    $0x10,%esp
80107530:	85 c0                	test   %eax,%eax
80107532:	79 07                	jns    8010753b <sys_write+0x52>
    return -1;
80107534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107539:	eb 17                	jmp    80107552 <sys_write+0x69>
  return filewrite(f, p, n);
8010753b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010753e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107544:	83 ec 04             	sub    $0x4,%esp
80107547:	51                   	push   %ecx
80107548:	52                   	push   %edx
80107549:	50                   	push   %eax
8010754a:	e8 a3 9d ff ff       	call   801012f2 <filewrite>
8010754f:	83 c4 10             	add    $0x10,%esp
}
80107552:	c9                   	leave  
80107553:	c3                   	ret    

80107554 <sys_close>:

int
sys_close(void)
{
80107554:	55                   	push   %ebp
80107555:	89 e5                	mov    %esp,%ebp
80107557:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010755a:	83 ec 04             	sub    $0x4,%esp
8010755d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107560:	50                   	push   %eax
80107561:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107564:	50                   	push   %eax
80107565:	6a 00                	push   $0x0
80107567:	e8 fa fd ff ff       	call   80107366 <argfd>
8010756c:	83 c4 10             	add    $0x10,%esp
8010756f:	85 c0                	test   %eax,%eax
80107571:	79 07                	jns    8010757a <sys_close+0x26>
    return -1;
80107573:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107578:	eb 28                	jmp    801075a2 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010757a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107583:	83 c2 08             	add    $0x8,%edx
80107586:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010758d:	00 
  fileclose(f);
8010758e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107591:	83 ec 0c             	sub    $0xc,%esp
80107594:	50                   	push   %eax
80107595:	e8 61 9b ff ff       	call   801010fb <fileclose>
8010759a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010759d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801075a2:	c9                   	leave  
801075a3:	c3                   	ret    

801075a4 <sys_fstat>:

int
sys_fstat(void)
{
801075a4:	55                   	push   %ebp
801075a5:	89 e5                	mov    %esp,%ebp
801075a7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801075aa:	83 ec 04             	sub    $0x4,%esp
801075ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801075b0:	50                   	push   %eax
801075b1:	6a 00                	push   $0x0
801075b3:	6a 00                	push   $0x0
801075b5:	e8 ac fd ff ff       	call   80107366 <argfd>
801075ba:	83 c4 10             	add    $0x10,%esp
801075bd:	85 c0                	test   %eax,%eax
801075bf:	78 17                	js     801075d8 <sys_fstat+0x34>
801075c1:	83 ec 04             	sub    $0x4,%esp
801075c4:	6a 1c                	push   $0x1c
801075c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801075c9:	50                   	push   %eax
801075ca:	6a 01                	push   $0x1
801075cc:	e8 81 fc ff ff       	call   80107252 <argptr>
801075d1:	83 c4 10             	add    $0x10,%esp
801075d4:	85 c0                	test   %eax,%eax
801075d6:	79 07                	jns    801075df <sys_fstat+0x3b>
    return -1;
801075d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075dd:	eb 13                	jmp    801075f2 <sys_fstat+0x4e>
  return filestat(f, st);
801075df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	83 ec 08             	sub    $0x8,%esp
801075e8:	52                   	push   %edx
801075e9:	50                   	push   %eax
801075ea:	e8 f4 9b ff ff       	call   801011e3 <filestat>
801075ef:	83 c4 10             	add    $0x10,%esp
}
801075f2:	c9                   	leave  
801075f3:	c3                   	ret    

801075f4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801075f4:	55                   	push   %ebp
801075f5:	89 e5                	mov    %esp,%ebp
801075f7:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801075fa:	83 ec 08             	sub    $0x8,%esp
801075fd:	8d 45 d8             	lea    -0x28(%ebp),%eax
80107600:	50                   	push   %eax
80107601:	6a 00                	push   $0x0
80107603:	e8 a7 fc ff ff       	call   801072af <argstr>
80107608:	83 c4 10             	add    $0x10,%esp
8010760b:	85 c0                	test   %eax,%eax
8010760d:	78 15                	js     80107624 <sys_link+0x30>
8010760f:	83 ec 08             	sub    $0x8,%esp
80107612:	8d 45 dc             	lea    -0x24(%ebp),%eax
80107615:	50                   	push   %eax
80107616:	6a 01                	push   $0x1
80107618:	e8 92 fc ff ff       	call   801072af <argstr>
8010761d:	83 c4 10             	add    $0x10,%esp
80107620:	85 c0                	test   %eax,%eax
80107622:	79 0a                	jns    8010762e <sys_link+0x3a>
    return -1;
80107624:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107629:	e9 68 01 00 00       	jmp    80107796 <sys_link+0x1a2>

  begin_op();
8010762e:	e8 cf c1 ff ff       	call   80103802 <begin_op>
  if((ip = namei(old)) == 0){
80107633:	8b 45 d8             	mov    -0x28(%ebp),%eax
80107636:	83 ec 0c             	sub    $0xc,%esp
80107639:	50                   	push   %eax
8010763a:	e8 27 b0 ff ff       	call   80102666 <namei>
8010763f:	83 c4 10             	add    $0x10,%esp
80107642:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107645:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107649:	75 0f                	jne    8010765a <sys_link+0x66>
    end_op();
8010764b:	e8 3e c2 ff ff       	call   8010388e <end_op>
    return -1;
80107650:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107655:	e9 3c 01 00 00       	jmp    80107796 <sys_link+0x1a2>
  }

  ilock(ip);
8010765a:	83 ec 0c             	sub    $0xc,%esp
8010765d:	ff 75 f4             	pushl  -0xc(%ebp)
80107660:	e8 f3 a3 ff ff       	call   80101a58 <ilock>
80107665:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80107668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010766f:	66 83 f8 01          	cmp    $0x1,%ax
80107673:	75 1d                	jne    80107692 <sys_link+0x9e>
    iunlockput(ip);
80107675:	83 ec 0c             	sub    $0xc,%esp
80107678:	ff 75 f4             	pushl  -0xc(%ebp)
8010767b:	e8 c0 a6 ff ff       	call   80101d40 <iunlockput>
80107680:	83 c4 10             	add    $0x10,%esp
    end_op();
80107683:	e8 06 c2 ff ff       	call   8010388e <end_op>
    return -1;
80107688:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010768d:	e9 04 01 00 00       	jmp    80107796 <sys_link+0x1a2>
  }

  ip->nlink++;
80107692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107695:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107699:	83 c0 01             	add    $0x1,%eax
8010769c:	89 c2                	mov    %eax,%edx
8010769e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801076a5:	83 ec 0c             	sub    $0xc,%esp
801076a8:	ff 75 f4             	pushl  -0xc(%ebp)
801076ab:	e8 a6 a1 ff ff       	call   80101856 <iupdate>
801076b0:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801076b3:	83 ec 0c             	sub    $0xc,%esp
801076b6:	ff 75 f4             	pushl  -0xc(%ebp)
801076b9:	e8 20 a5 ff ff       	call   80101bde <iunlock>
801076be:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801076c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801076c4:	83 ec 08             	sub    $0x8,%esp
801076c7:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801076ca:	52                   	push   %edx
801076cb:	50                   	push   %eax
801076cc:	e8 b1 af ff ff       	call   80102682 <nameiparent>
801076d1:	83 c4 10             	add    $0x10,%esp
801076d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076db:	74 71                	je     8010774e <sys_link+0x15a>
    goto bad;
  ilock(dp);
801076dd:	83 ec 0c             	sub    $0xc,%esp
801076e0:	ff 75 f0             	pushl  -0x10(%ebp)
801076e3:	e8 70 a3 ff ff       	call   80101a58 <ilock>
801076e8:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801076eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ee:	8b 10                	mov    (%eax),%edx
801076f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f3:	8b 00                	mov    (%eax),%eax
801076f5:	39 c2                	cmp    %eax,%edx
801076f7:	75 1d                	jne    80107716 <sys_link+0x122>
801076f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fc:	8b 40 04             	mov    0x4(%eax),%eax
801076ff:	83 ec 04             	sub    $0x4,%esp
80107702:	50                   	push   %eax
80107703:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80107706:	50                   	push   %eax
80107707:	ff 75 f0             	pushl  -0x10(%ebp)
8010770a:	e8 bb ac ff ff       	call   801023ca <dirlink>
8010770f:	83 c4 10             	add    $0x10,%esp
80107712:	85 c0                	test   %eax,%eax
80107714:	79 10                	jns    80107726 <sys_link+0x132>
    iunlockput(dp);
80107716:	83 ec 0c             	sub    $0xc,%esp
80107719:	ff 75 f0             	pushl  -0x10(%ebp)
8010771c:	e8 1f a6 ff ff       	call   80101d40 <iunlockput>
80107721:	83 c4 10             	add    $0x10,%esp
    goto bad;
80107724:	eb 29                	jmp    8010774f <sys_link+0x15b>
  }
  iunlockput(dp);
80107726:	83 ec 0c             	sub    $0xc,%esp
80107729:	ff 75 f0             	pushl  -0x10(%ebp)
8010772c:	e8 0f a6 ff ff       	call   80101d40 <iunlockput>
80107731:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80107734:	83 ec 0c             	sub    $0xc,%esp
80107737:	ff 75 f4             	pushl  -0xc(%ebp)
8010773a:	e8 11 a5 ff ff       	call   80101c50 <iput>
8010773f:	83 c4 10             	add    $0x10,%esp

  end_op();
80107742:	e8 47 c1 ff ff       	call   8010388e <end_op>

  return 0;
80107747:	b8 00 00 00 00       	mov    $0x0,%eax
8010774c:	eb 48                	jmp    80107796 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010774e:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
8010774f:	83 ec 0c             	sub    $0xc,%esp
80107752:	ff 75 f4             	pushl  -0xc(%ebp)
80107755:	e8 fe a2 ff ff       	call   80101a58 <ilock>
8010775a:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010775d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107760:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107764:	83 e8 01             	sub    $0x1,%eax
80107767:	89 c2                	mov    %eax,%edx
80107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107770:	83 ec 0c             	sub    $0xc,%esp
80107773:	ff 75 f4             	pushl  -0xc(%ebp)
80107776:	e8 db a0 ff ff       	call   80101856 <iupdate>
8010777b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010777e:	83 ec 0c             	sub    $0xc,%esp
80107781:	ff 75 f4             	pushl  -0xc(%ebp)
80107784:	e8 b7 a5 ff ff       	call   80101d40 <iunlockput>
80107789:	83 c4 10             	add    $0x10,%esp
  end_op();
8010778c:	e8 fd c0 ff ff       	call   8010388e <end_op>
  return -1;
80107791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107796:	c9                   	leave  
80107797:	c3                   	ret    

80107798 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80107798:	55                   	push   %ebp
80107799:	89 e5                	mov    %esp,%ebp
8010779b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010779e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801077a5:	eb 40                	jmp    801077e7 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801077a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077aa:	6a 10                	push   $0x10
801077ac:	50                   	push   %eax
801077ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801077b0:	50                   	push   %eax
801077b1:	ff 75 08             	pushl  0x8(%ebp)
801077b4:	e8 5d a8 ff ff       	call   80102016 <readi>
801077b9:	83 c4 10             	add    $0x10,%esp
801077bc:	83 f8 10             	cmp    $0x10,%eax
801077bf:	74 0d                	je     801077ce <isdirempty+0x36>
      panic("isdirempty: readi");
801077c1:	83 ec 0c             	sub    $0xc,%esp
801077c4:	68 08 ac 10 80       	push   $0x8010ac08
801077c9:	e8 98 8d ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801077ce:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801077d2:	66 85 c0             	test   %ax,%ax
801077d5:	74 07                	je     801077de <isdirempty+0x46>
      return 0;
801077d7:	b8 00 00 00 00       	mov    $0x0,%eax
801077dc:	eb 1b                	jmp    801077f9 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801077de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e1:	83 c0 10             	add    $0x10,%eax
801077e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077e7:	8b 45 08             	mov    0x8(%ebp),%eax
801077ea:	8b 50 20             	mov    0x20(%eax),%edx
801077ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f0:	39 c2                	cmp    %eax,%edx
801077f2:	77 b3                	ja     801077a7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801077f4:	b8 01 00 00 00       	mov    $0x1,%eax
}
801077f9:	c9                   	leave  
801077fa:	c3                   	ret    

801077fb <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801077fb:	55                   	push   %ebp
801077fc:	89 e5                	mov    %esp,%ebp
801077fe:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80107801:	83 ec 08             	sub    $0x8,%esp
80107804:	8d 45 cc             	lea    -0x34(%ebp),%eax
80107807:	50                   	push   %eax
80107808:	6a 00                	push   $0x0
8010780a:	e8 a0 fa ff ff       	call   801072af <argstr>
8010780f:	83 c4 10             	add    $0x10,%esp
80107812:	85 c0                	test   %eax,%eax
80107814:	79 0a                	jns    80107820 <sys_unlink+0x25>
    return -1;
80107816:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010781b:	e9 bc 01 00 00       	jmp    801079dc <sys_unlink+0x1e1>

  begin_op();
80107820:	e8 dd bf ff ff       	call   80103802 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80107825:	8b 45 cc             	mov    -0x34(%ebp),%eax
80107828:	83 ec 08             	sub    $0x8,%esp
8010782b:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010782e:	52                   	push   %edx
8010782f:	50                   	push   %eax
80107830:	e8 4d ae ff ff       	call   80102682 <nameiparent>
80107835:	83 c4 10             	add    $0x10,%esp
80107838:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010783b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010783f:	75 0f                	jne    80107850 <sys_unlink+0x55>
    end_op();
80107841:	e8 48 c0 ff ff       	call   8010388e <end_op>
    return -1;
80107846:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010784b:	e9 8c 01 00 00       	jmp    801079dc <sys_unlink+0x1e1>
  }

  ilock(dp);
80107850:	83 ec 0c             	sub    $0xc,%esp
80107853:	ff 75 f4             	pushl  -0xc(%ebp)
80107856:	e8 fd a1 ff ff       	call   80101a58 <ilock>
8010785b:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010785e:	83 ec 08             	sub    $0x8,%esp
80107861:	68 1a ac 10 80       	push   $0x8010ac1a
80107866:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107869:	50                   	push   %eax
8010786a:	e8 86 aa ff ff       	call   801022f5 <namecmp>
8010786f:	83 c4 10             	add    $0x10,%esp
80107872:	85 c0                	test   %eax,%eax
80107874:	0f 84 4a 01 00 00    	je     801079c4 <sys_unlink+0x1c9>
8010787a:	83 ec 08             	sub    $0x8,%esp
8010787d:	68 1c ac 10 80       	push   $0x8010ac1c
80107882:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107885:	50                   	push   %eax
80107886:	e8 6a aa ff ff       	call   801022f5 <namecmp>
8010788b:	83 c4 10             	add    $0x10,%esp
8010788e:	85 c0                	test   %eax,%eax
80107890:	0f 84 2e 01 00 00    	je     801079c4 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80107896:	83 ec 04             	sub    $0x4,%esp
80107899:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010789c:	50                   	push   %eax
8010789d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801078a0:	50                   	push   %eax
801078a1:	ff 75 f4             	pushl  -0xc(%ebp)
801078a4:	e8 67 aa ff ff       	call   80102310 <dirlookup>
801078a9:	83 c4 10             	add    $0x10,%esp
801078ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078b3:	0f 84 0a 01 00 00    	je     801079c3 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801078b9:	83 ec 0c             	sub    $0xc,%esp
801078bc:	ff 75 f0             	pushl  -0x10(%ebp)
801078bf:	e8 94 a1 ff ff       	call   80101a58 <ilock>
801078c4:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801078c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078ca:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801078ce:	66 85 c0             	test   %ax,%ax
801078d1:	7f 0d                	jg     801078e0 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801078d3:	83 ec 0c             	sub    $0xc,%esp
801078d6:	68 1f ac 10 80       	push   $0x8010ac1f
801078db:	e8 86 8c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801078e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801078e7:	66 83 f8 01          	cmp    $0x1,%ax
801078eb:	75 25                	jne    80107912 <sys_unlink+0x117>
801078ed:	83 ec 0c             	sub    $0xc,%esp
801078f0:	ff 75 f0             	pushl  -0x10(%ebp)
801078f3:	e8 a0 fe ff ff       	call   80107798 <isdirempty>
801078f8:	83 c4 10             	add    $0x10,%esp
801078fb:	85 c0                	test   %eax,%eax
801078fd:	75 13                	jne    80107912 <sys_unlink+0x117>
    iunlockput(ip);
801078ff:	83 ec 0c             	sub    $0xc,%esp
80107902:	ff 75 f0             	pushl  -0x10(%ebp)
80107905:	e8 36 a4 ff ff       	call   80101d40 <iunlockput>
8010790a:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010790d:	e9 b2 00 00 00       	jmp    801079c4 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80107912:	83 ec 04             	sub    $0x4,%esp
80107915:	6a 10                	push   $0x10
80107917:	6a 00                	push   $0x0
80107919:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010791c:	50                   	push   %eax
8010791d:	e8 e3 f5 ff ff       	call   80106f05 <memset>
80107922:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80107925:	8b 45 c8             	mov    -0x38(%ebp),%eax
80107928:	6a 10                	push   $0x10
8010792a:	50                   	push   %eax
8010792b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010792e:	50                   	push   %eax
8010792f:	ff 75 f4             	pushl  -0xc(%ebp)
80107932:	e8 36 a8 ff ff       	call   8010216d <writei>
80107937:	83 c4 10             	add    $0x10,%esp
8010793a:	83 f8 10             	cmp    $0x10,%eax
8010793d:	74 0d                	je     8010794c <sys_unlink+0x151>
    panic("unlink: writei");
8010793f:	83 ec 0c             	sub    $0xc,%esp
80107942:	68 31 ac 10 80       	push   $0x8010ac31
80107947:	e8 1a 8c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010794c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010794f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107953:	66 83 f8 01          	cmp    $0x1,%ax
80107957:	75 21                	jne    8010797a <sys_unlink+0x17f>
    dp->nlink--;
80107959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107960:	83 e8 01             	sub    $0x1,%eax
80107963:	89 c2                	mov    %eax,%edx
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010796c:	83 ec 0c             	sub    $0xc,%esp
8010796f:	ff 75 f4             	pushl  -0xc(%ebp)
80107972:	e8 df 9e ff ff       	call   80101856 <iupdate>
80107977:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010797a:	83 ec 0c             	sub    $0xc,%esp
8010797d:	ff 75 f4             	pushl  -0xc(%ebp)
80107980:	e8 bb a3 ff ff       	call   80101d40 <iunlockput>
80107985:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80107988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010798b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010798f:	83 e8 01             	sub    $0x1,%eax
80107992:	89 c2                	mov    %eax,%edx
80107994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107997:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010799b:	83 ec 0c             	sub    $0xc,%esp
8010799e:	ff 75 f0             	pushl  -0x10(%ebp)
801079a1:	e8 b0 9e ff ff       	call   80101856 <iupdate>
801079a6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801079a9:	83 ec 0c             	sub    $0xc,%esp
801079ac:	ff 75 f0             	pushl  -0x10(%ebp)
801079af:	e8 8c a3 ff ff       	call   80101d40 <iunlockput>
801079b4:	83 c4 10             	add    $0x10,%esp

  end_op();
801079b7:	e8 d2 be ff ff       	call   8010388e <end_op>

  return 0;
801079bc:	b8 00 00 00 00       	mov    $0x0,%eax
801079c1:	eb 19                	jmp    801079dc <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801079c3:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801079c4:	83 ec 0c             	sub    $0xc,%esp
801079c7:	ff 75 f4             	pushl  -0xc(%ebp)
801079ca:	e8 71 a3 ff ff       	call   80101d40 <iunlockput>
801079cf:	83 c4 10             	add    $0x10,%esp
  end_op();
801079d2:	e8 b7 be ff ff       	call   8010388e <end_op>
  return -1;
801079d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801079dc:	c9                   	leave  
801079dd:	c3                   	ret    

801079de <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801079de:	55                   	push   %ebp
801079df:	89 e5                	mov    %esp,%ebp
801079e1:	83 ec 38             	sub    $0x38,%esp
801079e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801079e7:	8b 55 10             	mov    0x10(%ebp),%edx
801079ea:	8b 45 14             	mov    0x14(%ebp),%eax
801079ed:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801079f1:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801079f5:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801079f9:	83 ec 08             	sub    $0x8,%esp
801079fc:	8d 45 de             	lea    -0x22(%ebp),%eax
801079ff:	50                   	push   %eax
80107a00:	ff 75 08             	pushl  0x8(%ebp)
80107a03:	e8 7a ac ff ff       	call   80102682 <nameiparent>
80107a08:	83 c4 10             	add    $0x10,%esp
80107a0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a12:	75 0a                	jne    80107a1e <create+0x40>
    return 0;
80107a14:	b8 00 00 00 00       	mov    $0x0,%eax
80107a19:	e9 90 01 00 00       	jmp    80107bae <create+0x1d0>
  ilock(dp);
80107a1e:	83 ec 0c             	sub    $0xc,%esp
80107a21:	ff 75 f4             	pushl  -0xc(%ebp)
80107a24:	e8 2f a0 ff ff       	call   80101a58 <ilock>
80107a29:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80107a2c:	83 ec 04             	sub    $0x4,%esp
80107a2f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107a32:	50                   	push   %eax
80107a33:	8d 45 de             	lea    -0x22(%ebp),%eax
80107a36:	50                   	push   %eax
80107a37:	ff 75 f4             	pushl  -0xc(%ebp)
80107a3a:	e8 d1 a8 ff ff       	call   80102310 <dirlookup>
80107a3f:	83 c4 10             	add    $0x10,%esp
80107a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a49:	74 50                	je     80107a9b <create+0xbd>
    iunlockput(dp);
80107a4b:	83 ec 0c             	sub    $0xc,%esp
80107a4e:	ff 75 f4             	pushl  -0xc(%ebp)
80107a51:	e8 ea a2 ff ff       	call   80101d40 <iunlockput>
80107a56:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80107a59:	83 ec 0c             	sub    $0xc,%esp
80107a5c:	ff 75 f0             	pushl  -0x10(%ebp)
80107a5f:	e8 f4 9f ff ff       	call   80101a58 <ilock>
80107a64:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80107a67:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80107a6c:	75 15                	jne    80107a83 <create+0xa5>
80107a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107a75:	66 83 f8 02          	cmp    $0x2,%ax
80107a79:	75 08                	jne    80107a83 <create+0xa5>
      return ip;
80107a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a7e:	e9 2b 01 00 00       	jmp    80107bae <create+0x1d0>
    iunlockput(ip);
80107a83:	83 ec 0c             	sub    $0xc,%esp
80107a86:	ff 75 f0             	pushl  -0x10(%ebp)
80107a89:	e8 b2 a2 ff ff       	call   80101d40 <iunlockput>
80107a8e:	83 c4 10             	add    $0x10,%esp
    return 0;
80107a91:	b8 00 00 00 00       	mov    $0x0,%eax
80107a96:	e9 13 01 00 00       	jmp    80107bae <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80107a9b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa2:	8b 00                	mov    (%eax),%eax
80107aa4:	83 ec 08             	sub    $0x8,%esp
80107aa7:	52                   	push   %edx
80107aa8:	50                   	push   %eax
80107aa9:	e8 b5 9c ff ff       	call   80101763 <ialloc>
80107aae:	83 c4 10             	add    $0x10,%esp
80107ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ab4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ab8:	75 0d                	jne    80107ac7 <create+0xe9>
    panic("create: ialloc");
80107aba:	83 ec 0c             	sub    $0xc,%esp
80107abd:	68 40 ac 10 80       	push   $0x8010ac40
80107ac2:	e8 9f 8a ff ff       	call   80100566 <panic>

  ilock(ip);
80107ac7:	83 ec 0c             	sub    $0xc,%esp
80107aca:	ff 75 f0             	pushl  -0x10(%ebp)
80107acd:	e8 86 9f ff ff       	call   80101a58 <ilock>
80107ad2:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80107ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ad8:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80107adc:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80107ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ae3:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80107ae7:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80107aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aee:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80107af4:	83 ec 0c             	sub    $0xc,%esp
80107af7:	ff 75 f0             	pushl  -0x10(%ebp)
80107afa:	e8 57 9d ff ff       	call   80101856 <iupdate>
80107aff:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80107b02:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80107b07:	75 6a                	jne    80107b73 <create+0x195>
    dp->nlink++;  // for ".."
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107b10:	83 c0 01             	add    $0x1,%eax
80107b13:	89 c2                	mov    %eax,%edx
80107b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b18:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107b1c:	83 ec 0c             	sub    $0xc,%esp
80107b1f:	ff 75 f4             	pushl  -0xc(%ebp)
80107b22:	e8 2f 9d ff ff       	call   80101856 <iupdate>
80107b27:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80107b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b2d:	8b 40 04             	mov    0x4(%eax),%eax
80107b30:	83 ec 04             	sub    $0x4,%esp
80107b33:	50                   	push   %eax
80107b34:	68 1a ac 10 80       	push   $0x8010ac1a
80107b39:	ff 75 f0             	pushl  -0x10(%ebp)
80107b3c:	e8 89 a8 ff ff       	call   801023ca <dirlink>
80107b41:	83 c4 10             	add    $0x10,%esp
80107b44:	85 c0                	test   %eax,%eax
80107b46:	78 1e                	js     80107b66 <create+0x188>
80107b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4b:	8b 40 04             	mov    0x4(%eax),%eax
80107b4e:	83 ec 04             	sub    $0x4,%esp
80107b51:	50                   	push   %eax
80107b52:	68 1c ac 10 80       	push   $0x8010ac1c
80107b57:	ff 75 f0             	pushl  -0x10(%ebp)
80107b5a:	e8 6b a8 ff ff       	call   801023ca <dirlink>
80107b5f:	83 c4 10             	add    $0x10,%esp
80107b62:	85 c0                	test   %eax,%eax
80107b64:	79 0d                	jns    80107b73 <create+0x195>
      panic("create dots");
80107b66:	83 ec 0c             	sub    $0xc,%esp
80107b69:	68 4f ac 10 80       	push   $0x8010ac4f
80107b6e:	e8 f3 89 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80107b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b76:	8b 40 04             	mov    0x4(%eax),%eax
80107b79:	83 ec 04             	sub    $0x4,%esp
80107b7c:	50                   	push   %eax
80107b7d:	8d 45 de             	lea    -0x22(%ebp),%eax
80107b80:	50                   	push   %eax
80107b81:	ff 75 f4             	pushl  -0xc(%ebp)
80107b84:	e8 41 a8 ff ff       	call   801023ca <dirlink>
80107b89:	83 c4 10             	add    $0x10,%esp
80107b8c:	85 c0                	test   %eax,%eax
80107b8e:	79 0d                	jns    80107b9d <create+0x1bf>
    panic("create: dirlink");
80107b90:	83 ec 0c             	sub    $0xc,%esp
80107b93:	68 5b ac 10 80       	push   $0x8010ac5b
80107b98:	e8 c9 89 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80107b9d:	83 ec 0c             	sub    $0xc,%esp
80107ba0:	ff 75 f4             	pushl  -0xc(%ebp)
80107ba3:	e8 98 a1 ff ff       	call   80101d40 <iunlockput>
80107ba8:	83 c4 10             	add    $0x10,%esp

  return ip;
80107bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107bae:	c9                   	leave  
80107baf:	c3                   	ret    

80107bb0 <sys_open>:

int
sys_open(void)
{
80107bb0:	55                   	push   %ebp
80107bb1:	89 e5                	mov    %esp,%ebp
80107bb3:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80107bb6:	83 ec 08             	sub    $0x8,%esp
80107bb9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107bbc:	50                   	push   %eax
80107bbd:	6a 00                	push   $0x0
80107bbf:	e8 eb f6 ff ff       	call   801072af <argstr>
80107bc4:	83 c4 10             	add    $0x10,%esp
80107bc7:	85 c0                	test   %eax,%eax
80107bc9:	78 15                	js     80107be0 <sys_open+0x30>
80107bcb:	83 ec 08             	sub    $0x8,%esp
80107bce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107bd1:	50                   	push   %eax
80107bd2:	6a 01                	push   $0x1
80107bd4:	e8 51 f6 ff ff       	call   8010722a <argint>
80107bd9:	83 c4 10             	add    $0x10,%esp
80107bdc:	85 c0                	test   %eax,%eax
80107bde:	79 0a                	jns    80107bea <sys_open+0x3a>
    return -1;
80107be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107be5:	e9 61 01 00 00       	jmp    80107d4b <sys_open+0x19b>

  begin_op();
80107bea:	e8 13 bc ff ff       	call   80103802 <begin_op>

  if(omode & O_CREATE){
80107bef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107bf2:	25 00 02 00 00       	and    $0x200,%eax
80107bf7:	85 c0                	test   %eax,%eax
80107bf9:	74 2a                	je     80107c25 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80107bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107bfe:	6a 00                	push   $0x0
80107c00:	6a 00                	push   $0x0
80107c02:	6a 02                	push   $0x2
80107c04:	50                   	push   %eax
80107c05:	e8 d4 fd ff ff       	call   801079de <create>
80107c0a:	83 c4 10             	add    $0x10,%esp
80107c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80107c10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c14:	75 75                	jne    80107c8b <sys_open+0xdb>
      end_op();
80107c16:	e8 73 bc ff ff       	call   8010388e <end_op>
      return -1;
80107c1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c20:	e9 26 01 00 00       	jmp    80107d4b <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80107c25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c28:	83 ec 0c             	sub    $0xc,%esp
80107c2b:	50                   	push   %eax
80107c2c:	e8 35 aa ff ff       	call   80102666 <namei>
80107c31:	83 c4 10             	add    $0x10,%esp
80107c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c3b:	75 0f                	jne    80107c4c <sys_open+0x9c>
      end_op();
80107c3d:	e8 4c bc ff ff       	call   8010388e <end_op>
      return -1;
80107c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c47:	e9 ff 00 00 00       	jmp    80107d4b <sys_open+0x19b>
    }
    ilock(ip);
80107c4c:	83 ec 0c             	sub    $0xc,%esp
80107c4f:	ff 75 f4             	pushl  -0xc(%ebp)
80107c52:	e8 01 9e ff ff       	call   80101a58 <ilock>
80107c57:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80107c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107c61:	66 83 f8 01          	cmp    $0x1,%ax
80107c65:	75 24                	jne    80107c8b <sys_open+0xdb>
80107c67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c6a:	85 c0                	test   %eax,%eax
80107c6c:	74 1d                	je     80107c8b <sys_open+0xdb>
      iunlockput(ip);
80107c6e:	83 ec 0c             	sub    $0xc,%esp
80107c71:	ff 75 f4             	pushl  -0xc(%ebp)
80107c74:	e8 c7 a0 ff ff       	call   80101d40 <iunlockput>
80107c79:	83 c4 10             	add    $0x10,%esp
      end_op();
80107c7c:	e8 0d bc ff ff       	call   8010388e <end_op>
      return -1;
80107c81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c86:	e9 c0 00 00 00       	jmp    80107d4b <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80107c8b:	e8 ad 93 ff ff       	call   8010103d <filealloc>
80107c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c93:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c97:	74 17                	je     80107cb0 <sys_open+0x100>
80107c99:	83 ec 0c             	sub    $0xc,%esp
80107c9c:	ff 75 f0             	pushl  -0x10(%ebp)
80107c9f:	e8 37 f7 ff ff       	call   801073db <fdalloc>
80107ca4:	83 c4 10             	add    $0x10,%esp
80107ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107caa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cae:	79 2e                	jns    80107cde <sys_open+0x12e>
    if(f)
80107cb0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cb4:	74 0e                	je     80107cc4 <sys_open+0x114>
      fileclose(f);
80107cb6:	83 ec 0c             	sub    $0xc,%esp
80107cb9:	ff 75 f0             	pushl  -0x10(%ebp)
80107cbc:	e8 3a 94 ff ff       	call   801010fb <fileclose>
80107cc1:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107cc4:	83 ec 0c             	sub    $0xc,%esp
80107cc7:	ff 75 f4             	pushl  -0xc(%ebp)
80107cca:	e8 71 a0 ff ff       	call   80101d40 <iunlockput>
80107ccf:	83 c4 10             	add    $0x10,%esp
    end_op();
80107cd2:	e8 b7 bb ff ff       	call   8010388e <end_op>
    return -1;
80107cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cdc:	eb 6d                	jmp    80107d4b <sys_open+0x19b>
  }
  iunlock(ip);
80107cde:	83 ec 0c             	sub    $0xc,%esp
80107ce1:	ff 75 f4             	pushl  -0xc(%ebp)
80107ce4:	e8 f5 9e ff ff       	call   80101bde <iunlock>
80107ce9:	83 c4 10             	add    $0x10,%esp
  end_op();
80107cec:	e8 9d bb ff ff       	call   8010388e <end_op>

  f->type = FD_INODE;
80107cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cf4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80107cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d00:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80107d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d06:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80107d0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d10:	83 e0 01             	and    $0x1,%eax
80107d13:	85 c0                	test   %eax,%eax
80107d15:	0f 94 c0             	sete   %al
80107d18:	89 c2                	mov    %eax,%edx
80107d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d1d:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80107d20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d23:	83 e0 01             	and    $0x1,%eax
80107d26:	85 c0                	test   %eax,%eax
80107d28:	75 0a                	jne    80107d34 <sys_open+0x184>
80107d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d2d:	83 e0 02             	and    $0x2,%eax
80107d30:	85 c0                	test   %eax,%eax
80107d32:	74 07                	je     80107d3b <sys_open+0x18b>
80107d34:	b8 01 00 00 00       	mov    $0x1,%eax
80107d39:	eb 05                	jmp    80107d40 <sys_open+0x190>
80107d3b:	b8 00 00 00 00       	mov    $0x0,%eax
80107d40:	89 c2                	mov    %eax,%edx
80107d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d45:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80107d48:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107d4b:	c9                   	leave  
80107d4c:	c3                   	ret    

80107d4d <sys_mkdir>:

int
sys_mkdir(void)
{
80107d4d:	55                   	push   %ebp
80107d4e:	89 e5                	mov    %esp,%ebp
80107d50:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107d53:	e8 aa ba ff ff       	call   80103802 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80107d58:	83 ec 08             	sub    $0x8,%esp
80107d5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d5e:	50                   	push   %eax
80107d5f:	6a 00                	push   $0x0
80107d61:	e8 49 f5 ff ff       	call   801072af <argstr>
80107d66:	83 c4 10             	add    $0x10,%esp
80107d69:	85 c0                	test   %eax,%eax
80107d6b:	78 1b                	js     80107d88 <sys_mkdir+0x3b>
80107d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d70:	6a 00                	push   $0x0
80107d72:	6a 00                	push   $0x0
80107d74:	6a 01                	push   $0x1
80107d76:	50                   	push   %eax
80107d77:	e8 62 fc ff ff       	call   801079de <create>
80107d7c:	83 c4 10             	add    $0x10,%esp
80107d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d86:	75 0c                	jne    80107d94 <sys_mkdir+0x47>
    end_op();
80107d88:	e8 01 bb ff ff       	call   8010388e <end_op>
    return -1;
80107d8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d92:	eb 18                	jmp    80107dac <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107d94:	83 ec 0c             	sub    $0xc,%esp
80107d97:	ff 75 f4             	pushl  -0xc(%ebp)
80107d9a:	e8 a1 9f ff ff       	call   80101d40 <iunlockput>
80107d9f:	83 c4 10             	add    $0x10,%esp
  end_op();
80107da2:	e8 e7 ba ff ff       	call   8010388e <end_op>
  return 0;
80107da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dac:	c9                   	leave  
80107dad:	c3                   	ret    

80107dae <sys_mknod>:

int
sys_mknod(void)
{
80107dae:	55                   	push   %ebp
80107daf:	89 e5                	mov    %esp,%ebp
80107db1:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107db4:	e8 49 ba ff ff       	call   80103802 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80107db9:	83 ec 08             	sub    $0x8,%esp
80107dbc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107dbf:	50                   	push   %eax
80107dc0:	6a 00                	push   $0x0
80107dc2:	e8 e8 f4 ff ff       	call   801072af <argstr>
80107dc7:	83 c4 10             	add    $0x10,%esp
80107dca:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dcd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107dd1:	78 4f                	js     80107e22 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107dd3:	83 ec 08             	sub    $0x8,%esp
80107dd6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107dd9:	50                   	push   %eax
80107dda:	6a 01                	push   $0x1
80107ddc:	e8 49 f4 ff ff       	call   8010722a <argint>
80107de1:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80107de4:	85 c0                	test   %eax,%eax
80107de6:	78 3a                	js     80107e22 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107de8:	83 ec 08             	sub    $0x8,%esp
80107deb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107dee:	50                   	push   %eax
80107def:	6a 02                	push   $0x2
80107df1:	e8 34 f4 ff ff       	call   8010722a <argint>
80107df6:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80107df9:	85 c0                	test   %eax,%eax
80107dfb:	78 25                	js     80107e22 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80107dfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e00:	0f bf c8             	movswl %ax,%ecx
80107e03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e06:	0f bf d0             	movswl %ax,%edx
80107e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107e0c:	51                   	push   %ecx
80107e0d:	52                   	push   %edx
80107e0e:	6a 03                	push   $0x3
80107e10:	50                   	push   %eax
80107e11:	e8 c8 fb ff ff       	call   801079de <create>
80107e16:	83 c4 10             	add    $0x10,%esp
80107e19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e20:	75 0c                	jne    80107e2e <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80107e22:	e8 67 ba ff ff       	call   8010388e <end_op>
    return -1;
80107e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e2c:	eb 18                	jmp    80107e46 <sys_mknod+0x98>
  }
  iunlockput(ip);
80107e2e:	83 ec 0c             	sub    $0xc,%esp
80107e31:	ff 75 f0             	pushl  -0x10(%ebp)
80107e34:	e8 07 9f ff ff       	call   80101d40 <iunlockput>
80107e39:	83 c4 10             	add    $0x10,%esp
  end_op();
80107e3c:	e8 4d ba ff ff       	call   8010388e <end_op>
  return 0;
80107e41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e46:	c9                   	leave  
80107e47:	c3                   	ret    

80107e48 <sys_chdir>:

int
sys_chdir(void)
{
80107e48:	55                   	push   %ebp
80107e49:	89 e5                	mov    %esp,%ebp
80107e4b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107e4e:	e8 af b9 ff ff       	call   80103802 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107e53:	83 ec 08             	sub    $0x8,%esp
80107e56:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107e59:	50                   	push   %eax
80107e5a:	6a 00                	push   $0x0
80107e5c:	e8 4e f4 ff ff       	call   801072af <argstr>
80107e61:	83 c4 10             	add    $0x10,%esp
80107e64:	85 c0                	test   %eax,%eax
80107e66:	78 18                	js     80107e80 <sys_chdir+0x38>
80107e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e6b:	83 ec 0c             	sub    $0xc,%esp
80107e6e:	50                   	push   %eax
80107e6f:	e8 f2 a7 ff ff       	call   80102666 <namei>
80107e74:	83 c4 10             	add    $0x10,%esp
80107e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e7e:	75 0c                	jne    80107e8c <sys_chdir+0x44>
    end_op();
80107e80:	e8 09 ba ff ff       	call   8010388e <end_op>
    return -1;
80107e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e8a:	eb 6e                	jmp    80107efa <sys_chdir+0xb2>
  }
  ilock(ip);
80107e8c:	83 ec 0c             	sub    $0xc,%esp
80107e8f:	ff 75 f4             	pushl  -0xc(%ebp)
80107e92:	e8 c1 9b ff ff       	call   80101a58 <ilock>
80107e97:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107ea1:	66 83 f8 01          	cmp    $0x1,%ax
80107ea5:	74 1a                	je     80107ec1 <sys_chdir+0x79>
    iunlockput(ip);
80107ea7:	83 ec 0c             	sub    $0xc,%esp
80107eaa:	ff 75 f4             	pushl  -0xc(%ebp)
80107ead:	e8 8e 9e ff ff       	call   80101d40 <iunlockput>
80107eb2:	83 c4 10             	add    $0x10,%esp
    end_op();
80107eb5:	e8 d4 b9 ff ff       	call   8010388e <end_op>
    return -1;
80107eba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ebf:	eb 39                	jmp    80107efa <sys_chdir+0xb2>
  }
  iunlock(ip);
80107ec1:	83 ec 0c             	sub    $0xc,%esp
80107ec4:	ff 75 f4             	pushl  -0xc(%ebp)
80107ec7:	e8 12 9d ff ff       	call   80101bde <iunlock>
80107ecc:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ed5:	8b 40 68             	mov    0x68(%eax),%eax
80107ed8:	83 ec 0c             	sub    $0xc,%esp
80107edb:	50                   	push   %eax
80107edc:	e8 6f 9d ff ff       	call   80101c50 <iput>
80107ee1:	83 c4 10             	add    $0x10,%esp
  end_op();
80107ee4:	e8 a5 b9 ff ff       	call   8010388e <end_op>
  proc->cwd = ip;
80107ee9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107eef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ef2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107efa:	c9                   	leave  
80107efb:	c3                   	ret    

80107efc <sys_exec>:

int
sys_exec(void)
{
80107efc:	55                   	push   %ebp
80107efd:	89 e5                	mov    %esp,%ebp
80107eff:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107f05:	83 ec 08             	sub    $0x8,%esp
80107f08:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f0b:	50                   	push   %eax
80107f0c:	6a 00                	push   $0x0
80107f0e:	e8 9c f3 ff ff       	call   801072af <argstr>
80107f13:	83 c4 10             	add    $0x10,%esp
80107f16:	85 c0                	test   %eax,%eax
80107f18:	78 18                	js     80107f32 <sys_exec+0x36>
80107f1a:	83 ec 08             	sub    $0x8,%esp
80107f1d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107f23:	50                   	push   %eax
80107f24:	6a 01                	push   $0x1
80107f26:	e8 ff f2 ff ff       	call   8010722a <argint>
80107f2b:	83 c4 10             	add    $0x10,%esp
80107f2e:	85 c0                	test   %eax,%eax
80107f30:	79 0a                	jns    80107f3c <sys_exec+0x40>
    return -1;
80107f32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f37:	e9 c6 00 00 00       	jmp    80108002 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107f3c:	83 ec 04             	sub    $0x4,%esp
80107f3f:	68 80 00 00 00       	push   $0x80
80107f44:	6a 00                	push   $0x0
80107f46:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107f4c:	50                   	push   %eax
80107f4d:	e8 b3 ef ff ff       	call   80106f05 <memset>
80107f52:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107f55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5f:	83 f8 1f             	cmp    $0x1f,%eax
80107f62:	76 0a                	jbe    80107f6e <sys_exec+0x72>
      return -1;
80107f64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f69:	e9 94 00 00 00       	jmp    80108002 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f71:	c1 e0 02             	shl    $0x2,%eax
80107f74:	89 c2                	mov    %eax,%edx
80107f76:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107f7c:	01 c2                	add    %eax,%edx
80107f7e:	83 ec 08             	sub    $0x8,%esp
80107f81:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107f87:	50                   	push   %eax
80107f88:	52                   	push   %edx
80107f89:	e8 00 f2 ff ff       	call   8010718e <fetchint>
80107f8e:	83 c4 10             	add    $0x10,%esp
80107f91:	85 c0                	test   %eax,%eax
80107f93:	79 07                	jns    80107f9c <sys_exec+0xa0>
      return -1;
80107f95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f9a:	eb 66                	jmp    80108002 <sys_exec+0x106>
    if(uarg == 0){
80107f9c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107fa2:	85 c0                	test   %eax,%eax
80107fa4:	75 27                	jne    80107fcd <sys_exec+0xd1>
      argv[i] = 0;
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107fb0:	00 00 00 00 
      break;
80107fb4:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb8:	83 ec 08             	sub    $0x8,%esp
80107fbb:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107fc1:	52                   	push   %edx
80107fc2:	50                   	push   %eax
80107fc3:	e8 53 8c ff ff       	call   80100c1b <exec>
80107fc8:	83 c4 10             	add    $0x10,%esp
80107fcb:	eb 35                	jmp    80108002 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107fcd:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107fd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fd6:	c1 e2 02             	shl    $0x2,%edx
80107fd9:	01 c2                	add    %eax,%edx
80107fdb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107fe1:	83 ec 08             	sub    $0x8,%esp
80107fe4:	52                   	push   %edx
80107fe5:	50                   	push   %eax
80107fe6:	e8 dd f1 ff ff       	call   801071c8 <fetchstr>
80107feb:	83 c4 10             	add    $0x10,%esp
80107fee:	85 c0                	test   %eax,%eax
80107ff0:	79 07                	jns    80107ff9 <sys_exec+0xfd>
      return -1;
80107ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ff7:	eb 09                	jmp    80108002 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107ff9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107ffd:	e9 5a ff ff ff       	jmp    80107f5c <sys_exec+0x60>
  return exec(path, argv);
}
80108002:	c9                   	leave  
80108003:	c3                   	ret    

80108004 <sys_pipe>:

int
sys_pipe(void)
{
80108004:	55                   	push   %ebp
80108005:	89 e5                	mov    %esp,%ebp
80108007:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010800a:	83 ec 04             	sub    $0x4,%esp
8010800d:	6a 08                	push   $0x8
8010800f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108012:	50                   	push   %eax
80108013:	6a 00                	push   $0x0
80108015:	e8 38 f2 ff ff       	call   80107252 <argptr>
8010801a:	83 c4 10             	add    $0x10,%esp
8010801d:	85 c0                	test   %eax,%eax
8010801f:	79 0a                	jns    8010802b <sys_pipe+0x27>
    return -1;
80108021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108026:	e9 af 00 00 00       	jmp    801080da <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010802b:	83 ec 08             	sub    $0x8,%esp
8010802e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80108031:	50                   	push   %eax
80108032:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108035:	50                   	push   %eax
80108036:	e8 bb c2 ff ff       	call   801042f6 <pipealloc>
8010803b:	83 c4 10             	add    $0x10,%esp
8010803e:	85 c0                	test   %eax,%eax
80108040:	79 0a                	jns    8010804c <sys_pipe+0x48>
    return -1;
80108042:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108047:	e9 8e 00 00 00       	jmp    801080da <sys_pipe+0xd6>
  fd0 = -1;
8010804c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80108053:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108056:	83 ec 0c             	sub    $0xc,%esp
80108059:	50                   	push   %eax
8010805a:	e8 7c f3 ff ff       	call   801073db <fdalloc>
8010805f:	83 c4 10             	add    $0x10,%esp
80108062:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108065:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108069:	78 18                	js     80108083 <sys_pipe+0x7f>
8010806b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010806e:	83 ec 0c             	sub    $0xc,%esp
80108071:	50                   	push   %eax
80108072:	e8 64 f3 ff ff       	call   801073db <fdalloc>
80108077:	83 c4 10             	add    $0x10,%esp
8010807a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010807d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108081:	79 3f                	jns    801080c2 <sys_pipe+0xbe>
    if(fd0 >= 0)
80108083:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108087:	78 14                	js     8010809d <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80108089:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010808f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108092:	83 c2 08             	add    $0x8,%edx
80108095:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010809c:	00 
    fileclose(rf);
8010809d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080a0:	83 ec 0c             	sub    $0xc,%esp
801080a3:	50                   	push   %eax
801080a4:	e8 52 90 ff ff       	call   801010fb <fileclose>
801080a9:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801080ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080af:	83 ec 0c             	sub    $0xc,%esp
801080b2:	50                   	push   %eax
801080b3:	e8 43 90 ff ff       	call   801010fb <fileclose>
801080b8:	83 c4 10             	add    $0x10,%esp
    return -1;
801080bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080c0:	eb 18                	jmp    801080da <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801080c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080c8:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801080ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080cd:	8d 50 04             	lea    0x4(%eax),%edx
801080d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d3:	89 02                	mov    %eax,(%edx)
  return 0;
801080d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080da:	c9                   	leave  
801080db:	c3                   	ret    

801080dc <sys_chmod>:

#ifdef CS333_P5
int
sys_chmod(void)
{
801080dc:	55                   	push   %ebp
801080dd:	89 e5                	mov    %esp,%ebp
801080df:	83 ec 18             	sub    $0x18,%esp
    char *path;
    int mod;
    if(argstr(0, &path) < 0 || argint(1, &mod) < 0)
801080e2:	83 ec 08             	sub    $0x8,%esp
801080e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801080e8:	50                   	push   %eax
801080e9:	6a 00                	push   $0x0
801080eb:	e8 bf f1 ff ff       	call   801072af <argstr>
801080f0:	83 c4 10             	add    $0x10,%esp
801080f3:	85 c0                	test   %eax,%eax
801080f5:	78 15                	js     8010810c <sys_chmod+0x30>
801080f7:	83 ec 08             	sub    $0x8,%esp
801080fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801080fd:	50                   	push   %eax
801080fe:	6a 01                	push   $0x1
80108100:	e8 25 f1 ff ff       	call   8010722a <argint>
80108105:	83 c4 10             	add    $0x10,%esp
80108108:	85 c0                	test   %eax,%eax
8010810a:	79 07                	jns    80108113 <sys_chmod+0x37>
	return -1;
8010810c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108111:	eb 4f                	jmp    80108162 <sys_chmod+0x86>

    if(mod < 0000 || mod > 1023){
80108113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108116:	85 c0                	test   %eax,%eax
80108118:	78 0a                	js     80108124 <sys_chmod+0x48>
8010811a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010811d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
80108122:	7e 17                	jle    8010813b <sys_chmod+0x5f>
	cprintf("\nPlease enter mode between 0000 and 0755\n");
80108124:	83 ec 0c             	sub    $0xc,%esp
80108127:	68 6c ac 10 80       	push   $0x8010ac6c
8010812c:	e8 95 82 ff ff       	call   801003c6 <cprintf>
80108131:	83 c4 10             	add    $0x10,%esp
	return -1;
80108134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108139:	eb 27                	jmp    80108162 <sys_chmod+0x86>
    }

    cprintf("%d", mod);
8010813b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813e:	83 ec 08             	sub    $0x8,%esp
80108141:	50                   	push   %eax
80108142:	68 96 ac 10 80       	push   $0x8010ac96
80108147:	e8 7a 82 ff ff       	call   801003c6 <cprintf>
8010814c:	83 c4 10             	add    $0x10,%esp
    return chmod(path, mod);
8010814f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108155:	83 ec 08             	sub    $0x8,%esp
80108158:	52                   	push   %edx
80108159:	50                   	push   %eax
8010815a:	e8 3e a5 ff ff       	call   8010269d <chmod>
8010815f:	83 c4 10             	add    $0x10,%esp

}
80108162:	c9                   	leave  
80108163:	c3                   	ret    

80108164 <sys_chown>:

int
sys_chown(void)
{
80108164:	55                   	push   %ebp
80108165:	89 e5                	mov    %esp,%ebp
80108167:	83 ec 18             	sub    $0x18,%esp
    char *path;
    int own;
    if(argstr(0, &path) < 0 || argint(1, &own) < 0)
8010816a:	83 ec 08             	sub    $0x8,%esp
8010816d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108170:	50                   	push   %eax
80108171:	6a 00                	push   $0x0
80108173:	e8 37 f1 ff ff       	call   801072af <argstr>
80108178:	83 c4 10             	add    $0x10,%esp
8010817b:	85 c0                	test   %eax,%eax
8010817d:	78 15                	js     80108194 <sys_chown+0x30>
8010817f:	83 ec 08             	sub    $0x8,%esp
80108182:	8d 45 f0             	lea    -0x10(%ebp),%eax
80108185:	50                   	push   %eax
80108186:	6a 01                	push   $0x1
80108188:	e8 9d f0 ff ff       	call   8010722a <argint>
8010818d:	83 c4 10             	add    $0x10,%esp
80108190:	85 c0                	test   %eax,%eax
80108192:	79 07                	jns    8010819b <sys_chown+0x37>
	return -1;
80108194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108199:	eb 4f                	jmp    801081ea <sys_chown+0x86>

    if(own < 0 || own > 32767){
8010819b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010819e:	85 c0                	test   %eax,%eax
801081a0:	78 0a                	js     801081ac <sys_chown+0x48>
801081a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a5:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801081aa:	7e 17                	jle    801081c3 <sys_chown+0x5f>
	cprintf("\nPlease enter a UID between 0 and 32767\n");
801081ac:	83 ec 0c             	sub    $0xc,%esp
801081af:	68 9c ac 10 80       	push   $0x8010ac9c
801081b4:	e8 0d 82 ff ff       	call   801003c6 <cprintf>
801081b9:	83 c4 10             	add    $0x10,%esp
	return -1;
801081bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081c1:	eb 27                	jmp    801081ea <sys_chown+0x86>
    }

    cprintf("%d", own);
801081c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c6:	83 ec 08             	sub    $0x8,%esp
801081c9:	50                   	push   %eax
801081ca:	68 96 ac 10 80       	push   $0x8010ac96
801081cf:	e8 f2 81 ff ff       	call   801003c6 <cprintf>
801081d4:	83 c4 10             	add    $0x10,%esp

    return chown(path, own);
801081d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	83 ec 08             	sub    $0x8,%esp
801081e0:	52                   	push   %edx
801081e1:	50                   	push   %eax
801081e2:	e8 31 a5 ff ff       	call   80102718 <chown>
801081e7:	83 c4 10             	add    $0x10,%esp
}
801081ea:	c9                   	leave  
801081eb:	c3                   	ret    

801081ec <sys_chgrp>:

int
sys_chgrp(void)
{
801081ec:	55                   	push   %ebp
801081ed:	89 e5                	mov    %esp,%ebp
801081ef:	83 ec 18             	sub    $0x18,%esp
    char *path;
    int grp;
    if(argstr(0, &path) < 0 || argint(1, &grp) < 0)
801081f2:	83 ec 08             	sub    $0x8,%esp
801081f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801081f8:	50                   	push   %eax
801081f9:	6a 00                	push   $0x0
801081fb:	e8 af f0 ff ff       	call   801072af <argstr>
80108200:	83 c4 10             	add    $0x10,%esp
80108203:	85 c0                	test   %eax,%eax
80108205:	78 15                	js     8010821c <sys_chgrp+0x30>
80108207:	83 ec 08             	sub    $0x8,%esp
8010820a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010820d:	50                   	push   %eax
8010820e:	6a 01                	push   $0x1
80108210:	e8 15 f0 ff ff       	call   8010722a <argint>
80108215:	83 c4 10             	add    $0x10,%esp
80108218:	85 c0                	test   %eax,%eax
8010821a:	79 07                	jns    80108223 <sys_chgrp+0x37>
	return -1;
8010821c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108221:	eb 4f                	jmp    80108272 <sys_chgrp+0x86>

    if(grp < 0 || grp > 32767){
80108223:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108226:	85 c0                	test   %eax,%eax
80108228:	78 0a                	js     80108234 <sys_chgrp+0x48>
8010822a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010822d:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108232:	7e 17                	jle    8010824b <sys_chgrp+0x5f>
	cprintf("\nPlease enter a GID between 0 and 32767\n");
80108234:	83 ec 0c             	sub    $0xc,%esp
80108237:	68 c8 ac 10 80       	push   $0x8010acc8
8010823c:	e8 85 81 ff ff       	call   801003c6 <cprintf>
80108241:	83 c4 10             	add    $0x10,%esp
	return -1;
80108244:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108249:	eb 27                	jmp    80108272 <sys_chgrp+0x86>
    }

    cprintf("%d", grp);
8010824b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010824e:	83 ec 08             	sub    $0x8,%esp
80108251:	50                   	push   %eax
80108252:	68 96 ac 10 80       	push   $0x8010ac96
80108257:	e8 6a 81 ff ff       	call   801003c6 <cprintf>
8010825c:	83 c4 10             	add    $0x10,%esp
    return chgrp(path, grp);
8010825f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108265:	83 ec 08             	sub    $0x8,%esp
80108268:	52                   	push   %edx
80108269:	50                   	push   %eax
8010826a:	e8 27 a5 ff ff       	call   80102796 <chgrp>
8010826f:	83 c4 10             	add    $0x10,%esp

}
80108272:	c9                   	leave  
80108273:	c3                   	ret    

80108274 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80108274:	55                   	push   %ebp
80108275:	89 e5                	mov    %esp,%ebp
80108277:	83 ec 08             	sub    $0x8,%esp
8010827a:	8b 55 08             	mov    0x8(%ebp),%edx
8010827d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108280:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108284:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108288:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
8010828c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108290:	66 ef                	out    %ax,(%dx)
}
80108292:	90                   	nop
80108293:	c9                   	leave  
80108294:	c3                   	ret    

80108295 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80108295:	55                   	push   %ebp
80108296:	89 e5                	mov    %esp,%ebp
80108298:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010829b:	e8 78 cb ff ff       	call   80104e18 <fork>
}
801082a0:	c9                   	leave  
801082a1:	c3                   	ret    

801082a2 <sys_exit>:

int
sys_exit(void)
{
801082a2:	55                   	push   %ebp
801082a3:	89 e5                	mov    %esp,%ebp
801082a5:	83 ec 08             	sub    $0x8,%esp
  exit();
801082a8:	e8 9d cd ff ff       	call   8010504a <exit>
  return 0;  // not reached
801082ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082b2:	c9                   	leave  
801082b3:	c3                   	ret    

801082b4 <sys_wait>:

int
sys_wait(void)
{
801082b4:	55                   	push   %ebp
801082b5:	89 e5                	mov    %esp,%ebp
801082b7:	83 ec 08             	sub    $0x8,%esp
  return wait();
801082ba:	e8 10 d0 ff ff       	call   801052cf <wait>
}
801082bf:	c9                   	leave  
801082c0:	c3                   	ret    

801082c1 <sys_kill>:

int
sys_kill(void)
{
801082c1:	55                   	push   %ebp
801082c2:	89 e5                	mov    %esp,%ebp
801082c4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801082c7:	83 ec 08             	sub    $0x8,%esp
801082ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
801082cd:	50                   	push   %eax
801082ce:	6a 00                	push   $0x0
801082d0:	e8 55 ef ff ff       	call   8010722a <argint>
801082d5:	83 c4 10             	add    $0x10,%esp
801082d8:	85 c0                	test   %eax,%eax
801082da:	79 07                	jns    801082e3 <sys_kill+0x22>
    return -1;
801082dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082e1:	eb 0f                	jmp    801082f2 <sys_kill+0x31>
  return kill(pid);
801082e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e6:	83 ec 0c             	sub    $0xc,%esp
801082e9:	50                   	push   %eax
801082ea:	e8 e5 d8 ff ff       	call   80105bd4 <kill>
801082ef:	83 c4 10             	add    $0x10,%esp
}
801082f2:	c9                   	leave  
801082f3:	c3                   	ret    

801082f4 <sys_getpid>:

int
sys_getpid(void)
{
801082f4:	55                   	push   %ebp
801082f5:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801082f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801082fd:	8b 40 10             	mov    0x10(%eax),%eax
}
80108300:	5d                   	pop    %ebp
80108301:	c3                   	ret    

80108302 <sys_sbrk>:

int
sys_sbrk(void)
{
80108302:	55                   	push   %ebp
80108303:	89 e5                	mov    %esp,%ebp
80108305:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80108308:	83 ec 08             	sub    $0x8,%esp
8010830b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010830e:	50                   	push   %eax
8010830f:	6a 00                	push   $0x0
80108311:	e8 14 ef ff ff       	call   8010722a <argint>
80108316:	83 c4 10             	add    $0x10,%esp
80108319:	85 c0                	test   %eax,%eax
8010831b:	79 07                	jns    80108324 <sys_sbrk+0x22>
    return -1;
8010831d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108322:	eb 28                	jmp    8010834c <sys_sbrk+0x4a>
  addr = proc->sz;
80108324:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010832a:	8b 00                	mov    (%eax),%eax
8010832c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010832f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108332:	83 ec 0c             	sub    $0xc,%esp
80108335:	50                   	push   %eax
80108336:	e8 3a ca ff ff       	call   80104d75 <growproc>
8010833b:	83 c4 10             	add    $0x10,%esp
8010833e:	85 c0                	test   %eax,%eax
80108340:	79 07                	jns    80108349 <sys_sbrk+0x47>
    return -1;
80108342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108347:	eb 03                	jmp    8010834c <sys_sbrk+0x4a>
  return addr;
80108349:	8b 45 f4             	mov    -0xc(%ebp),%eax

    cprintf("Implement this");
}
8010834c:	c9                   	leave  
8010834d:	c3                   	ret    

8010834e <sys_sleep>:
int
sys_sleep(void)
{
8010834e:	55                   	push   %ebp
8010834f:	89 e5                	mov    %esp,%ebp
80108351:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80108354:	83 ec 08             	sub    $0x8,%esp
80108357:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010835a:	50                   	push   %eax
8010835b:	6a 00                	push   $0x0
8010835d:	e8 c8 ee ff ff       	call   8010722a <argint>
80108362:	83 c4 10             	add    $0x10,%esp
80108365:	85 c0                	test   %eax,%eax
80108367:	79 07                	jns    80108370 <sys_sleep+0x22>
    return -1;
80108369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010836e:	eb 44                	jmp    801083b4 <sys_sleep+0x66>
  ticks0 = ticks;
80108370:	a1 e0 78 11 80       	mov    0x801178e0,%eax
80108375:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80108378:	eb 26                	jmp    801083a0 <sys_sleep+0x52>
    if(proc->killed){
8010837a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108380:	8b 40 24             	mov    0x24(%eax),%eax
80108383:	85 c0                	test   %eax,%eax
80108385:	74 07                	je     8010838e <sys_sleep+0x40>
      return -1;
80108387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010838c:	eb 26                	jmp    801083b4 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
8010838e:	83 ec 08             	sub    $0x8,%esp
80108391:	6a 00                	push   $0x0
80108393:	68 e0 78 11 80       	push   $0x801178e0
80108398:	e8 f0 d5 ff ff       	call   8010598d <sleep>
8010839d:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801083a0:	a1 e0 78 11 80       	mov    0x801178e0,%eax
801083a5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801083a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083ab:	39 d0                	cmp    %edx,%eax
801083ad:	72 cb                	jb     8010837a <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
801083af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083b4:	c9                   	leave  
801083b5:	c3                   	ret    

801083b6 <sys_date>:
#ifdef CS333_P1
int
sys_date(void)
{
801083b6:	55                   	push   %ebp
801083b7:	89 e5                	mov    %esp,%ebp
801083b9:	83 ec 18             	sub    $0x18,%esp
    struct rtcdate *d;
   
    if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
801083bc:	83 ec 04             	sub    $0x4,%esp
801083bf:	6a 18                	push   $0x18
801083c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801083c4:	50                   	push   %eax
801083c5:	6a 00                	push   $0x0
801083c7:	e8 86 ee ff ff       	call   80107252 <argptr>
801083cc:	83 c4 10             	add    $0x10,%esp
801083cf:	85 c0                	test   %eax,%eax
801083d1:	79 07                	jns    801083da <sys_date+0x24>
	return -1;
801083d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083d8:	eb 14                	jmp    801083ee <sys_date+0x38>

    cmostime(d);
801083da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dd:	83 ec 0c             	sub    $0xc,%esp
801083e0:	50                   	push   %eax
801083e1:	e8 97 b0 ff ff       	call   8010347d <cmostime>
801083e6:	83 c4 10             	add    $0x10,%esp
    return 0;
801083e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083ee:	c9                   	leave  
801083ef:	c3                   	ret    

801083f0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
801083f0:	55                   	push   %ebp
801083f1:	89 e5                	mov    %esp,%ebp
801083f3:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
801083f6:	a1 e0 78 11 80       	mov    0x801178e0,%eax
801083fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
801083fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108401:	c9                   	leave  
80108402:	c3                   	ret    

80108403 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80108403:	55                   	push   %ebp
80108404:	89 e5                	mov    %esp,%ebp
80108406:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80108409:	83 ec 0c             	sub    $0xc,%esp
8010840c:	68 f4 ac 10 80       	push   $0x8010acf4
80108411:	e8 b0 7f ff ff       	call   801003c6 <cprintf>
80108416:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80108419:	83 ec 08             	sub    $0x8,%esp
8010841c:	68 00 20 00 00       	push   $0x2000
80108421:	68 04 06 00 00       	push   $0x604
80108426:	e8 49 fe ff ff       	call   80108274 <outw>
8010842b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010842e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108433:	c9                   	leave  
80108434:	c3                   	ret    

80108435 <sys_getuid>:

#ifdef CS333_P2
int 
sys_getuid(void)
{
80108435:	55                   	push   %ebp
80108436:	89 e5                	mov    %esp,%ebp
    return proc -> uid;
80108438:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010843e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80108444:	5d                   	pop    %ebp
80108445:	c3                   	ret    

80108446 <sys_getgid>:

int 
sys_getgid(void)
{
80108446:	55                   	push   %ebp
80108447:	89 e5                	mov    %esp,%ebp
    return proc -> gid;
80108449:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010844f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80108455:	5d                   	pop    %ebp
80108456:	c3                   	ret    

80108457 <sys_getppid>:

int 
sys_getppid(void)
{
80108457:	55                   	push   %ebp
80108458:	89 e5                	mov    %esp,%ebp
    if(proc -> parent)
8010845a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108460:	8b 40 14             	mov    0x14(%eax),%eax
80108463:	85 c0                	test   %eax,%eax
80108465:	74 0e                	je     80108475 <sys_getppid+0x1e>
	return proc -> parent -> pid;
80108467:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010846d:	8b 40 14             	mov    0x14(%eax),%eax
80108470:	8b 40 10             	mov    0x10(%eax),%eax
80108473:	eb 05                	jmp    8010847a <sys_getppid+0x23>
    else
	return 1;
80108475:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010847a:	5d                   	pop    %ebp
8010847b:	c3                   	ret    

8010847c <sys_setuid>:

int 
sys_setuid(void)
{
8010847c:	55                   	push   %ebp
8010847d:	89 e5                	mov    %esp,%ebp
8010847f:	83 ec 18             	sub    $0x18,%esp
    int uid;

    if(argint(0, &uid) < 0)
80108482:	83 ec 08             	sub    $0x8,%esp
80108485:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108488:	50                   	push   %eax
80108489:	6a 00                	push   $0x0
8010848b:	e8 9a ed ff ff       	call   8010722a <argint>
80108490:	83 c4 10             	add    $0x10,%esp
80108493:	85 c0                	test   %eax,%eax
80108495:	79 07                	jns    8010849e <sys_setuid+0x22>
	return -1;
80108497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010849c:	eb 2d                	jmp    801084cb <sys_setuid+0x4f>
    if(uid > 32767 || uid < 0)
8010849e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a1:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801084a6:	7f 07                	jg     801084af <sys_setuid+0x33>
801084a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ab:	85 c0                	test   %eax,%eax
801084ad:	79 07                	jns    801084b6 <sys_setuid+0x3a>
	return -1;
801084af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084b4:	eb 15                	jmp    801084cb <sys_setuid+0x4f>
    else
	return proc -> uid = uid;
801084b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084bf:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
801084c5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801084cb:	c9                   	leave  
801084cc:	c3                   	ret    

801084cd <sys_setgid>:

int 
sys_setgid(void)
{
801084cd:	55                   	push   %ebp
801084ce:	89 e5                	mov    %esp,%ebp
801084d0:	83 ec 18             	sub    $0x18,%esp
    int gid;

    if(argint(0, &gid) < 0)
801084d3:	83 ec 08             	sub    $0x8,%esp
801084d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801084d9:	50                   	push   %eax
801084da:	6a 00                	push   $0x0
801084dc:	e8 49 ed ff ff       	call   8010722a <argint>
801084e1:	83 c4 10             	add    $0x10,%esp
801084e4:	85 c0                	test   %eax,%eax
801084e6:	79 07                	jns    801084ef <sys_setgid+0x22>
	return -1;
801084e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084ed:	eb 2d                	jmp    8010851c <sys_setgid+0x4f>
    if(gid > 32767 || gid < 0)
801084ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f2:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801084f7:	7f 07                	jg     80108500 <sys_setgid+0x33>
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	85 c0                	test   %eax,%eax
801084fe:	79 07                	jns    80108507 <sys_setgid+0x3a>
	return -1;
80108500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108505:	eb 15                	jmp    8010851c <sys_setgid+0x4f>
    else
	return proc -> gid = gid;
80108507:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010850d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108510:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
80108516:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
8010851c:	c9                   	leave  
8010851d:	c3                   	ret    

8010851e <sys_getprocs>:

int
sys_getprocs(void)
{
8010851e:	55                   	push   %ebp
8010851f:	89 e5                	mov    %esp,%ebp
80108521:	83 ec 18             	sub    $0x18,%esp
    int num;
    struct uproc *procarray;

    if(argint(0, &num) < 0)
80108524:	83 ec 08             	sub    $0x8,%esp
80108527:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010852a:	50                   	push   %eax
8010852b:	6a 00                	push   $0x0
8010852d:	e8 f8 ec ff ff       	call   8010722a <argint>
80108532:	83 c4 10             	add    $0x10,%esp
80108535:	85 c0                	test   %eax,%eax
80108537:	79 07                	jns    80108540 <sys_getprocs+0x22>
	return -1;
80108539:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010853e:	eb 36                	jmp    80108576 <sys_getprocs+0x58>
    
    if(argptr(1, (void*)&procarray, sizeof(struct uproc)) < 0)
80108540:	83 ec 04             	sub    $0x4,%esp
80108543:	6a 60                	push   $0x60
80108545:	8d 45 f0             	lea    -0x10(%ebp),%eax
80108548:	50                   	push   %eax
80108549:	6a 01                	push   $0x1
8010854b:	e8 02 ed ff ff       	call   80107252 <argptr>
80108550:	83 c4 10             	add    $0x10,%esp
80108553:	85 c0                	test   %eax,%eax
80108555:	79 07                	jns    8010855e <sys_getprocs+0x40>
	return -1;
80108557:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010855c:	eb 18                	jmp    80108576 <sys_getprocs+0x58>

   getproctable(num, procarray);
8010855e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108561:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108564:	83 ec 08             	sub    $0x8,%esp
80108567:	50                   	push   %eax
80108568:	52                   	push   %edx
80108569:	e8 77 dc ff ff       	call   801061e5 <getproctable>
8010856e:	83 c4 10             	add    $0x10,%esp
   return 1;
80108571:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108576:	c9                   	leave  
80108577:	c3                   	ret    

80108578 <sys_setpriority>:
#endif
#ifdef CS333_P3P4
int
sys_setpriority(void)
{
80108578:	55                   	push   %ebp
80108579:	89 e5                	mov    %esp,%ebp
8010857b:	83 ec 18             	sub    $0x18,%esp
    int pid, prio;

    if(argint(0, &pid) < 0)
8010857e:	83 ec 08             	sub    $0x8,%esp
80108581:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108584:	50                   	push   %eax
80108585:	6a 00                	push   $0x0
80108587:	e8 9e ec ff ff       	call   8010722a <argint>
8010858c:	83 c4 10             	add    $0x10,%esp
8010858f:	85 c0                	test   %eax,%eax
80108591:	79 07                	jns    8010859a <sys_setpriority+0x22>
	return -1;
80108593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108598:	eb 7e                	jmp    80108618 <sys_setpriority+0xa0>

    if(argint(1, &prio) < 0)
8010859a:	83 ec 08             	sub    $0x8,%esp
8010859d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801085a0:	50                   	push   %eax
801085a1:	6a 01                	push   $0x1
801085a3:	e8 82 ec ff ff       	call   8010722a <argint>
801085a8:	83 c4 10             	add    $0x10,%esp
801085ab:	85 c0                	test   %eax,%eax
801085ad:	79 07                	jns    801085b6 <sys_setpriority+0x3e>
	return -1;
801085af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085b4:	eb 62                	jmp    80108618 <sys_setpriority+0xa0>
    
    if(prio < 0 || prio > MAX){
801085b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b9:	85 c0                	test   %eax,%eax
801085bb:	78 08                	js     801085c5 <sys_setpriority+0x4d>
801085bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c0:	83 f8 04             	cmp    $0x4,%eax
801085c3:	7e 1d                	jle    801085e2 <sys_setpriority+0x6a>
	cprintf("\nPriority: %d out of bounds, enter a value between 0 and %d\n", prio, MAX);
801085c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c8:	83 ec 04             	sub    $0x4,%esp
801085cb:	6a 04                	push   $0x4
801085cd:	50                   	push   %eax
801085ce:	68 08 ad 10 80       	push   $0x8010ad08
801085d3:	e8 ee 7d ff ff       	call   801003c6 <cprintf>
801085d8:	83 c4 10             	add    $0x10,%esp
	return -2;
801085db:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
801085e0:	eb 36                	jmp    80108618 <sys_setpriority+0xa0>
    }
	
    if(pid < 1){
801085e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e5:	85 c0                	test   %eax,%eax
801085e7:	7f 17                	jg     80108600 <sys_setpriority+0x88>
	cprintf("\nInvalid PID\n");
801085e9:	83 ec 0c             	sub    $0xc,%esp
801085ec:	68 45 ad 10 80       	push   $0x8010ad45
801085f1:	e8 d0 7d ff ff       	call   801003c6 <cprintf>
801085f6:	83 c4 10             	add    $0x10,%esp
	return -3;
801085f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
801085fe:	eb 18                	jmp    80108618 <sys_setpriority+0xa0>
    }

    setpriority(pid, prio);
80108600:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108606:	83 ec 08             	sub    $0x8,%esp
80108609:	52                   	push   %edx
8010860a:	50                   	push   %eax
8010860b:	e8 6a e4 ff ff       	call   80106a7a <setpriority>
80108610:	83 c4 10             	add    $0x10,%esp

    return 1;
80108613:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108618:	c9                   	leave  
80108619:	c3                   	ret    

8010861a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010861a:	55                   	push   %ebp
8010861b:	89 e5                	mov    %esp,%ebp
8010861d:	83 ec 08             	sub    $0x8,%esp
80108620:	8b 55 08             	mov    0x8(%ebp),%edx
80108623:	8b 45 0c             	mov    0xc(%ebp),%eax
80108626:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010862a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010862d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108631:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108635:	ee                   	out    %al,(%dx)
}
80108636:	90                   	nop
80108637:	c9                   	leave  
80108638:	c3                   	ret    

80108639 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80108639:	55                   	push   %ebp
8010863a:	89 e5                	mov    %esp,%ebp
8010863c:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010863f:	6a 34                	push   $0x34
80108641:	6a 43                	push   $0x43
80108643:	e8 d2 ff ff ff       	call   8010861a <outb>
80108648:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
8010864b:	68 a9 00 00 00       	push   $0xa9
80108650:	6a 40                	push   $0x40
80108652:	e8 c3 ff ff ff       	call   8010861a <outb>
80108657:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
8010865a:	6a 04                	push   $0x4
8010865c:	6a 40                	push   $0x40
8010865e:	e8 b7 ff ff ff       	call   8010861a <outb>
80108663:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80108666:	83 ec 0c             	sub    $0xc,%esp
80108669:	6a 00                	push   $0x0
8010866b:	e8 70 bb ff ff       	call   801041e0 <picenable>
80108670:	83 c4 10             	add    $0x10,%esp
}
80108673:	90                   	nop
80108674:	c9                   	leave  
80108675:	c3                   	ret    

80108676 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80108676:	1e                   	push   %ds
  pushl %es
80108677:	06                   	push   %es
  pushl %fs
80108678:	0f a0                	push   %fs
  pushl %gs
8010867a:	0f a8                	push   %gs
  pushal
8010867c:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010867d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80108681:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80108683:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80108685:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80108689:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010868b:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010868d:	54                   	push   %esp
  call trap
8010868e:	e8 ce 01 00 00       	call   80108861 <trap>
  addl $4, %esp
80108693:	83 c4 04             	add    $0x4,%esp

80108696 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80108696:	61                   	popa   
  popl %gs
80108697:	0f a9                	pop    %gs
  popl %fs
80108699:	0f a1                	pop    %fs
  popl %es
8010869b:	07                   	pop    %es
  popl %ds
8010869c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010869d:	83 c4 08             	add    $0x8,%esp
  iret
801086a0:	cf                   	iret   

801086a1 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
801086a1:	55                   	push   %ebp
801086a2:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
801086a4:	8b 45 08             	mov    0x8(%ebp),%eax
801086a7:	f0 ff 00             	lock incl (%eax)
}
801086aa:	90                   	nop
801086ab:	5d                   	pop    %ebp
801086ac:	c3                   	ret    

801086ad <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801086ad:	55                   	push   %ebp
801086ae:	89 e5                	mov    %esp,%ebp
801086b0:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801086b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801086b6:	83 e8 01             	sub    $0x1,%eax
801086b9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801086bd:	8b 45 08             	mov    0x8(%ebp),%eax
801086c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801086c4:	8b 45 08             	mov    0x8(%ebp),%eax
801086c7:	c1 e8 10             	shr    $0x10,%eax
801086ca:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801086ce:	8d 45 fa             	lea    -0x6(%ebp),%eax
801086d1:	0f 01 18             	lidtl  (%eax)
}
801086d4:	90                   	nop
801086d5:	c9                   	leave  
801086d6:	c3                   	ret    

801086d7 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801086d7:	55                   	push   %ebp
801086d8:	89 e5                	mov    %esp,%ebp
801086da:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801086dd:	0f 20 d0             	mov    %cr2,%eax
801086e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801086e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801086e6:	c9                   	leave  
801086e7:	c3                   	ret    

801086e8 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801086e8:	55                   	push   %ebp
801086e9:	89 e5                	mov    %esp,%ebp
801086eb:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801086ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801086f5:	e9 c3 00 00 00       	jmp    801087bd <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801086fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086fd:	8b 04 85 bc d0 10 80 	mov    -0x7fef2f44(,%eax,4),%eax
80108704:	89 c2                	mov    %eax,%edx
80108706:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108709:	66 89 14 c5 e0 70 11 	mov    %dx,-0x7fee8f20(,%eax,8)
80108710:	80 
80108711:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108714:	66 c7 04 c5 e2 70 11 	movw   $0x8,-0x7fee8f1e(,%eax,8)
8010871b:	80 08 00 
8010871e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108721:	0f b6 14 c5 e4 70 11 	movzbl -0x7fee8f1c(,%eax,8),%edx
80108728:	80 
80108729:	83 e2 e0             	and    $0xffffffe0,%edx
8010872c:	88 14 c5 e4 70 11 80 	mov    %dl,-0x7fee8f1c(,%eax,8)
80108733:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108736:	0f b6 14 c5 e4 70 11 	movzbl -0x7fee8f1c(,%eax,8),%edx
8010873d:	80 
8010873e:	83 e2 1f             	and    $0x1f,%edx
80108741:	88 14 c5 e4 70 11 80 	mov    %dl,-0x7fee8f1c(,%eax,8)
80108748:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010874b:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
80108752:	80 
80108753:	83 e2 f0             	and    $0xfffffff0,%edx
80108756:	83 ca 0e             	or     $0xe,%edx
80108759:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
80108760:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108763:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
8010876a:	80 
8010876b:	83 e2 ef             	and    $0xffffffef,%edx
8010876e:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
80108775:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108778:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
8010877f:	80 
80108780:	83 e2 9f             	and    $0xffffff9f,%edx
80108783:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
8010878a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010878d:	0f b6 14 c5 e5 70 11 	movzbl -0x7fee8f1b(,%eax,8),%edx
80108794:	80 
80108795:	83 ca 80             	or     $0xffffff80,%edx
80108798:	88 14 c5 e5 70 11 80 	mov    %dl,-0x7fee8f1b(,%eax,8)
8010879f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087a2:	8b 04 85 bc d0 10 80 	mov    -0x7fef2f44(,%eax,4),%eax
801087a9:	c1 e8 10             	shr    $0x10,%eax
801087ac:	89 c2                	mov    %eax,%edx
801087ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087b1:	66 89 14 c5 e6 70 11 	mov    %dx,-0x7fee8f1a(,%eax,8)
801087b8:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801087b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801087bd:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801087c4:	0f 8e 30 ff ff ff    	jle    801086fa <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801087ca:	a1 bc d1 10 80       	mov    0x8010d1bc,%eax
801087cf:	66 a3 e0 72 11 80    	mov    %ax,0x801172e0
801087d5:	66 c7 05 e2 72 11 80 	movw   $0x8,0x801172e2
801087dc:	08 00 
801087de:	0f b6 05 e4 72 11 80 	movzbl 0x801172e4,%eax
801087e5:	83 e0 e0             	and    $0xffffffe0,%eax
801087e8:	a2 e4 72 11 80       	mov    %al,0x801172e4
801087ed:	0f b6 05 e4 72 11 80 	movzbl 0x801172e4,%eax
801087f4:	83 e0 1f             	and    $0x1f,%eax
801087f7:	a2 e4 72 11 80       	mov    %al,0x801172e4
801087fc:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
80108803:	83 c8 0f             	or     $0xf,%eax
80108806:	a2 e5 72 11 80       	mov    %al,0x801172e5
8010880b:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
80108812:	83 e0 ef             	and    $0xffffffef,%eax
80108815:	a2 e5 72 11 80       	mov    %al,0x801172e5
8010881a:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
80108821:	83 c8 60             	or     $0x60,%eax
80108824:	a2 e5 72 11 80       	mov    %al,0x801172e5
80108829:	0f b6 05 e5 72 11 80 	movzbl 0x801172e5,%eax
80108830:	83 c8 80             	or     $0xffffff80,%eax
80108833:	a2 e5 72 11 80       	mov    %al,0x801172e5
80108838:	a1 bc d1 10 80       	mov    0x8010d1bc,%eax
8010883d:	c1 e8 10             	shr    $0x10,%eax
80108840:	66 a3 e6 72 11 80    	mov    %ax,0x801172e6
  
}
80108846:	90                   	nop
80108847:	c9                   	leave  
80108848:	c3                   	ret    

80108849 <idtinit>:

void
idtinit(void)
{
80108849:	55                   	push   %ebp
8010884a:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010884c:	68 00 08 00 00       	push   $0x800
80108851:	68 e0 70 11 80       	push   $0x801170e0
80108856:	e8 52 fe ff ff       	call   801086ad <lidt>
8010885b:	83 c4 08             	add    $0x8,%esp
}
8010885e:	90                   	nop
8010885f:	c9                   	leave  
80108860:	c3                   	ret    

80108861 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80108861:	55                   	push   %ebp
80108862:	89 e5                	mov    %esp,%ebp
80108864:	57                   	push   %edi
80108865:	56                   	push   %esi
80108866:	53                   	push   %ebx
80108867:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010886a:	8b 45 08             	mov    0x8(%ebp),%eax
8010886d:	8b 40 30             	mov    0x30(%eax),%eax
80108870:	83 f8 40             	cmp    $0x40,%eax
80108873:	75 3e                	jne    801088b3 <trap+0x52>
    if(proc->killed)
80108875:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010887b:	8b 40 24             	mov    0x24(%eax),%eax
8010887e:	85 c0                	test   %eax,%eax
80108880:	74 05                	je     80108887 <trap+0x26>
      exit();
80108882:	e8 c3 c7 ff ff       	call   8010504a <exit>
    proc->tf = tf;
80108887:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010888d:	8b 55 08             	mov    0x8(%ebp),%edx
80108890:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80108893:	e8 48 ea ff ff       	call   801072e0 <syscall>
    if(proc->killed)
80108898:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010889e:	8b 40 24             	mov    0x24(%eax),%eax
801088a1:	85 c0                	test   %eax,%eax
801088a3:	0f 84 21 02 00 00    	je     80108aca <trap+0x269>
      exit();
801088a9:	e8 9c c7 ff ff       	call   8010504a <exit>
    return;
801088ae:	e9 17 02 00 00       	jmp    80108aca <trap+0x269>
  }

  switch(tf->trapno){
801088b3:	8b 45 08             	mov    0x8(%ebp),%eax
801088b6:	8b 40 30             	mov    0x30(%eax),%eax
801088b9:	83 e8 20             	sub    $0x20,%eax
801088bc:	83 f8 1f             	cmp    $0x1f,%eax
801088bf:	0f 87 a3 00 00 00    	ja     80108968 <trap+0x107>
801088c5:	8b 04 85 f4 ad 10 80 	mov    -0x7fef520c(,%eax,4),%eax
801088cc:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
801088ce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801088d4:	0f b6 00             	movzbl (%eax),%eax
801088d7:	84 c0                	test   %al,%al
801088d9:	75 20                	jne    801088fb <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
801088db:	83 ec 0c             	sub    $0xc,%esp
801088de:	68 e0 78 11 80       	push   $0x801178e0
801088e3:	e8 b9 fd ff ff       	call   801086a1 <atom_inc>
801088e8:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801088eb:	83 ec 0c             	sub    $0xc,%esp
801088ee:	68 e0 78 11 80       	push   $0x801178e0
801088f3:	e8 a5 d2 ff ff       	call   80105b9d <wakeup>
801088f8:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801088fb:	e8 da a9 ff ff       	call   801032da <lapiceoi>
    break;
80108900:	e9 1c 01 00 00       	jmp    80108a21 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80108905:	e8 e3 a1 ff ff       	call   80102aed <ideintr>
    lapiceoi();
8010890a:	e8 cb a9 ff ff       	call   801032da <lapiceoi>
    break;
8010890f:	e9 0d 01 00 00       	jmp    80108a21 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80108914:	e8 c3 a7 ff ff       	call   801030dc <kbdintr>
    lapiceoi();
80108919:	e8 bc a9 ff ff       	call   801032da <lapiceoi>
    break;
8010891e:	e9 fe 00 00 00       	jmp    80108a21 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80108923:	e8 83 03 00 00       	call   80108cab <uartintr>
    lapiceoi();
80108928:	e8 ad a9 ff ff       	call   801032da <lapiceoi>
    break;
8010892d:	e9 ef 00 00 00       	jmp    80108a21 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80108932:	8b 45 08             	mov    0x8(%ebp),%eax
80108935:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80108938:	8b 45 08             	mov    0x8(%ebp),%eax
8010893b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010893f:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80108942:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108948:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010894b:	0f b6 c0             	movzbl %al,%eax
8010894e:	51                   	push   %ecx
8010894f:	52                   	push   %edx
80108950:	50                   	push   %eax
80108951:	68 54 ad 10 80       	push   $0x8010ad54
80108956:	e8 6b 7a ff ff       	call   801003c6 <cprintf>
8010895b:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010895e:	e8 77 a9 ff ff       	call   801032da <lapiceoi>
    break;
80108963:	e9 b9 00 00 00       	jmp    80108a21 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80108968:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010896e:	85 c0                	test   %eax,%eax
80108970:	74 11                	je     80108983 <trap+0x122>
80108972:	8b 45 08             	mov    0x8(%ebp),%eax
80108975:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108979:	0f b7 c0             	movzwl %ax,%eax
8010897c:	83 e0 03             	and    $0x3,%eax
8010897f:	85 c0                	test   %eax,%eax
80108981:	75 40                	jne    801089c3 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108983:	e8 4f fd ff ff       	call   801086d7 <rcr2>
80108988:	89 c3                	mov    %eax,%ebx
8010898a:	8b 45 08             	mov    0x8(%ebp),%eax
8010898d:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80108990:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108996:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108999:	0f b6 d0             	movzbl %al,%edx
8010899c:	8b 45 08             	mov    0x8(%ebp),%eax
8010899f:	8b 40 30             	mov    0x30(%eax),%eax
801089a2:	83 ec 0c             	sub    $0xc,%esp
801089a5:	53                   	push   %ebx
801089a6:	51                   	push   %ecx
801089a7:	52                   	push   %edx
801089a8:	50                   	push   %eax
801089a9:	68 78 ad 10 80       	push   $0x8010ad78
801089ae:	e8 13 7a ff ff       	call   801003c6 <cprintf>
801089b3:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801089b6:	83 ec 0c             	sub    $0xc,%esp
801089b9:	68 aa ad 10 80       	push   $0x8010adaa
801089be:	e8 a3 7b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801089c3:	e8 0f fd ff ff       	call   801086d7 <rcr2>
801089c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801089cb:	8b 45 08             	mov    0x8(%ebp),%eax
801089ce:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801089d1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801089d7:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801089da:	0f b6 d8             	movzbl %al,%ebx
801089dd:	8b 45 08             	mov    0x8(%ebp),%eax
801089e0:	8b 48 34             	mov    0x34(%eax),%ecx
801089e3:	8b 45 08             	mov    0x8(%ebp),%eax
801089e6:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801089e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801089ef:	8d 78 6c             	lea    0x6c(%eax),%edi
801089f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801089f8:	8b 40 10             	mov    0x10(%eax),%eax
801089fb:	ff 75 e4             	pushl  -0x1c(%ebp)
801089fe:	56                   	push   %esi
801089ff:	53                   	push   %ebx
80108a00:	51                   	push   %ecx
80108a01:	52                   	push   %edx
80108a02:	57                   	push   %edi
80108a03:	50                   	push   %eax
80108a04:	68 b0 ad 10 80       	push   $0x8010adb0
80108a09:	e8 b8 79 ff ff       	call   801003c6 <cprintf>
80108a0e:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80108a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a17:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80108a1e:	eb 01                	jmp    80108a21 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80108a20:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80108a21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a27:	85 c0                	test   %eax,%eax
80108a29:	74 24                	je     80108a4f <trap+0x1ee>
80108a2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a31:	8b 40 24             	mov    0x24(%eax),%eax
80108a34:	85 c0                	test   %eax,%eax
80108a36:	74 17                	je     80108a4f <trap+0x1ee>
80108a38:	8b 45 08             	mov    0x8(%ebp),%eax
80108a3b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108a3f:	0f b7 c0             	movzwl %ax,%eax
80108a42:	83 e0 03             	and    $0x3,%eax
80108a45:	83 f8 03             	cmp    $0x3,%eax
80108a48:	75 05                	jne    80108a4f <trap+0x1ee>
    exit();
80108a4a:	e8 fb c5 ff ff       	call   8010504a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108a4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a55:	85 c0                	test   %eax,%eax
80108a57:	74 41                	je     80108a9a <trap+0x239>
80108a59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a5f:	8b 40 0c             	mov    0xc(%eax),%eax
80108a62:	83 f8 04             	cmp    $0x4,%eax
80108a65:	75 33                	jne    80108a9a <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108a67:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6a:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108a6d:	83 f8 20             	cmp    $0x20,%eax
80108a70:	75 28                	jne    80108a9a <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108a72:	8b 0d e0 78 11 80    	mov    0x801178e0,%ecx
80108a78:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80108a7d:	89 c8                	mov    %ecx,%eax
80108a7f:	f7 e2                	mul    %edx
80108a81:	c1 ea 03             	shr    $0x3,%edx
80108a84:	89 d0                	mov    %edx,%eax
80108a86:	c1 e0 02             	shl    $0x2,%eax
80108a89:	01 d0                	add    %edx,%eax
80108a8b:	01 c0                	add    %eax,%eax
80108a8d:	29 c1                	sub    %eax,%ecx
80108a8f:	89 ca                	mov    %ecx,%edx
80108a91:	85 d2                	test   %edx,%edx
80108a93:	75 05                	jne    80108a9a <trap+0x239>
    yield();
80108a95:	e8 99 cd ff ff       	call   80105833 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80108a9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108aa0:	85 c0                	test   %eax,%eax
80108aa2:	74 27                	je     80108acb <trap+0x26a>
80108aa4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108aaa:	8b 40 24             	mov    0x24(%eax),%eax
80108aad:	85 c0                	test   %eax,%eax
80108aaf:	74 1a                	je     80108acb <trap+0x26a>
80108ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108ab8:	0f b7 c0             	movzwl %ax,%eax
80108abb:	83 e0 03             	and    $0x3,%eax
80108abe:	83 f8 03             	cmp    $0x3,%eax
80108ac1:	75 08                	jne    80108acb <trap+0x26a>
    exit();
80108ac3:	e8 82 c5 ff ff       	call   8010504a <exit>
80108ac8:	eb 01                	jmp    80108acb <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80108aca:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80108acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108ace:	5b                   	pop    %ebx
80108acf:	5e                   	pop    %esi
80108ad0:	5f                   	pop    %edi
80108ad1:	5d                   	pop    %ebp
80108ad2:	c3                   	ret    

80108ad3 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108ad3:	55                   	push   %ebp
80108ad4:	89 e5                	mov    %esp,%ebp
80108ad6:	83 ec 14             	sub    $0x14,%esp
80108ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80108adc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108ae0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108ae4:	89 c2                	mov    %eax,%edx
80108ae6:	ec                   	in     (%dx),%al
80108ae7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108aea:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108aee:	c9                   	leave  
80108aef:	c3                   	ret    

80108af0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80108af0:	55                   	push   %ebp
80108af1:	89 e5                	mov    %esp,%ebp
80108af3:	83 ec 08             	sub    $0x8,%esp
80108af6:	8b 55 08             	mov    0x8(%ebp),%edx
80108af9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108afc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108b00:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108b03:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108b07:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108b0b:	ee                   	out    %al,(%dx)
}
80108b0c:	90                   	nop
80108b0d:	c9                   	leave  
80108b0e:	c3                   	ret    

80108b0f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80108b0f:	55                   	push   %ebp
80108b10:	89 e5                	mov    %esp,%ebp
80108b12:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80108b15:	6a 00                	push   $0x0
80108b17:	68 fa 03 00 00       	push   $0x3fa
80108b1c:	e8 cf ff ff ff       	call   80108af0 <outb>
80108b21:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108b24:	68 80 00 00 00       	push   $0x80
80108b29:	68 fb 03 00 00       	push   $0x3fb
80108b2e:	e8 bd ff ff ff       	call   80108af0 <outb>
80108b33:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108b36:	6a 0c                	push   $0xc
80108b38:	68 f8 03 00 00       	push   $0x3f8
80108b3d:	e8 ae ff ff ff       	call   80108af0 <outb>
80108b42:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108b45:	6a 00                	push   $0x0
80108b47:	68 f9 03 00 00       	push   $0x3f9
80108b4c:	e8 9f ff ff ff       	call   80108af0 <outb>
80108b51:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108b54:	6a 03                	push   $0x3
80108b56:	68 fb 03 00 00       	push   $0x3fb
80108b5b:	e8 90 ff ff ff       	call   80108af0 <outb>
80108b60:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108b63:	6a 00                	push   $0x0
80108b65:	68 fc 03 00 00       	push   $0x3fc
80108b6a:	e8 81 ff ff ff       	call   80108af0 <outb>
80108b6f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80108b72:	6a 01                	push   $0x1
80108b74:	68 f9 03 00 00       	push   $0x3f9
80108b79:	e8 72 ff ff ff       	call   80108af0 <outb>
80108b7e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80108b81:	68 fd 03 00 00       	push   $0x3fd
80108b86:	e8 48 ff ff ff       	call   80108ad3 <inb>
80108b8b:	83 c4 04             	add    $0x4,%esp
80108b8e:	3c ff                	cmp    $0xff,%al
80108b90:	74 6e                	je     80108c00 <uartinit+0xf1>
    return;
  uart = 1;
80108b92:	c7 05 6c d6 10 80 01 	movl   $0x1,0x8010d66c
80108b99:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80108b9c:	68 fa 03 00 00       	push   $0x3fa
80108ba1:	e8 2d ff ff ff       	call   80108ad3 <inb>
80108ba6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80108ba9:	68 f8 03 00 00       	push   $0x3f8
80108bae:	e8 20 ff ff ff       	call   80108ad3 <inb>
80108bb3:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80108bb6:	83 ec 0c             	sub    $0xc,%esp
80108bb9:	6a 04                	push   $0x4
80108bbb:	e8 20 b6 ff ff       	call   801041e0 <picenable>
80108bc0:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108bc3:	83 ec 08             	sub    $0x8,%esp
80108bc6:	6a 00                	push   $0x0
80108bc8:	6a 04                	push   $0x4
80108bca:	e8 c0 a1 ff ff       	call   80102d8f <ioapicenable>
80108bcf:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108bd2:	c7 45 f4 74 ae 10 80 	movl   $0x8010ae74,-0xc(%ebp)
80108bd9:	eb 19                	jmp    80108bf4 <uartinit+0xe5>
    uartputc(*p);
80108bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bde:	0f b6 00             	movzbl (%eax),%eax
80108be1:	0f be c0             	movsbl %al,%eax
80108be4:	83 ec 0c             	sub    $0xc,%esp
80108be7:	50                   	push   %eax
80108be8:	e8 16 00 00 00       	call   80108c03 <uartputc>
80108bed:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108bf0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf7:	0f b6 00             	movzbl (%eax),%eax
80108bfa:	84 c0                	test   %al,%al
80108bfc:	75 dd                	jne    80108bdb <uartinit+0xcc>
80108bfe:	eb 01                	jmp    80108c01 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80108c00:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80108c01:	c9                   	leave  
80108c02:	c3                   	ret    

80108c03 <uartputc>:

void
uartputc(int c)
{
80108c03:	55                   	push   %ebp
80108c04:	89 e5                	mov    %esp,%ebp
80108c06:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80108c09:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
80108c0e:	85 c0                	test   %eax,%eax
80108c10:	74 53                	je     80108c65 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80108c12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c19:	eb 11                	jmp    80108c2c <uartputc+0x29>
    microdelay(10);
80108c1b:	83 ec 0c             	sub    $0xc,%esp
80108c1e:	6a 0a                	push   $0xa
80108c20:	e8 d0 a6 ff ff       	call   801032f5 <microdelay>
80108c25:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80108c28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c2c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108c30:	7f 1a                	jg     80108c4c <uartputc+0x49>
80108c32:	83 ec 0c             	sub    $0xc,%esp
80108c35:	68 fd 03 00 00       	push   $0x3fd
80108c3a:	e8 94 fe ff ff       	call   80108ad3 <inb>
80108c3f:	83 c4 10             	add    $0x10,%esp
80108c42:	0f b6 c0             	movzbl %al,%eax
80108c45:	83 e0 20             	and    $0x20,%eax
80108c48:	85 c0                	test   %eax,%eax
80108c4a:	74 cf                	je     80108c1b <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80108c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4f:	0f b6 c0             	movzbl %al,%eax
80108c52:	83 ec 08             	sub    $0x8,%esp
80108c55:	50                   	push   %eax
80108c56:	68 f8 03 00 00       	push   $0x3f8
80108c5b:	e8 90 fe ff ff       	call   80108af0 <outb>
80108c60:	83 c4 10             	add    $0x10,%esp
80108c63:	eb 01                	jmp    80108c66 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80108c65:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80108c66:	c9                   	leave  
80108c67:	c3                   	ret    

80108c68 <uartgetc>:

static int
uartgetc(void)
{
80108c68:	55                   	push   %ebp
80108c69:	89 e5                	mov    %esp,%ebp
  if(!uart)
80108c6b:	a1 6c d6 10 80       	mov    0x8010d66c,%eax
80108c70:	85 c0                	test   %eax,%eax
80108c72:	75 07                	jne    80108c7b <uartgetc+0x13>
    return -1;
80108c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c79:	eb 2e                	jmp    80108ca9 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80108c7b:	68 fd 03 00 00       	push   $0x3fd
80108c80:	e8 4e fe ff ff       	call   80108ad3 <inb>
80108c85:	83 c4 04             	add    $0x4,%esp
80108c88:	0f b6 c0             	movzbl %al,%eax
80108c8b:	83 e0 01             	and    $0x1,%eax
80108c8e:	85 c0                	test   %eax,%eax
80108c90:	75 07                	jne    80108c99 <uartgetc+0x31>
    return -1;
80108c92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c97:	eb 10                	jmp    80108ca9 <uartgetc+0x41>
  return inb(COM1+0);
80108c99:	68 f8 03 00 00       	push   $0x3f8
80108c9e:	e8 30 fe ff ff       	call   80108ad3 <inb>
80108ca3:	83 c4 04             	add    $0x4,%esp
80108ca6:	0f b6 c0             	movzbl %al,%eax
}
80108ca9:	c9                   	leave  
80108caa:	c3                   	ret    

80108cab <uartintr>:

void
uartintr(void)
{
80108cab:	55                   	push   %ebp
80108cac:	89 e5                	mov    %esp,%ebp
80108cae:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108cb1:	83 ec 0c             	sub    $0xc,%esp
80108cb4:	68 68 8c 10 80       	push   $0x80108c68
80108cb9:	e8 3b 7b ff ff       	call   801007f9 <consoleintr>
80108cbe:	83 c4 10             	add    $0x10,%esp
}
80108cc1:	90                   	nop
80108cc2:	c9                   	leave  
80108cc3:	c3                   	ret    

80108cc4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108cc4:	6a 00                	push   $0x0
  pushl $0
80108cc6:	6a 00                	push   $0x0
  jmp alltraps
80108cc8:	e9 a9 f9 ff ff       	jmp    80108676 <alltraps>

80108ccd <vector1>:
.globl vector1
vector1:
  pushl $0
80108ccd:	6a 00                	push   $0x0
  pushl $1
80108ccf:	6a 01                	push   $0x1
  jmp alltraps
80108cd1:	e9 a0 f9 ff ff       	jmp    80108676 <alltraps>

80108cd6 <vector2>:
.globl vector2
vector2:
  pushl $0
80108cd6:	6a 00                	push   $0x0
  pushl $2
80108cd8:	6a 02                	push   $0x2
  jmp alltraps
80108cda:	e9 97 f9 ff ff       	jmp    80108676 <alltraps>

80108cdf <vector3>:
.globl vector3
vector3:
  pushl $0
80108cdf:	6a 00                	push   $0x0
  pushl $3
80108ce1:	6a 03                	push   $0x3
  jmp alltraps
80108ce3:	e9 8e f9 ff ff       	jmp    80108676 <alltraps>

80108ce8 <vector4>:
.globl vector4
vector4:
  pushl $0
80108ce8:	6a 00                	push   $0x0
  pushl $4
80108cea:	6a 04                	push   $0x4
  jmp alltraps
80108cec:	e9 85 f9 ff ff       	jmp    80108676 <alltraps>

80108cf1 <vector5>:
.globl vector5
vector5:
  pushl $0
80108cf1:	6a 00                	push   $0x0
  pushl $5
80108cf3:	6a 05                	push   $0x5
  jmp alltraps
80108cf5:	e9 7c f9 ff ff       	jmp    80108676 <alltraps>

80108cfa <vector6>:
.globl vector6
vector6:
  pushl $0
80108cfa:	6a 00                	push   $0x0
  pushl $6
80108cfc:	6a 06                	push   $0x6
  jmp alltraps
80108cfe:	e9 73 f9 ff ff       	jmp    80108676 <alltraps>

80108d03 <vector7>:
.globl vector7
vector7:
  pushl $0
80108d03:	6a 00                	push   $0x0
  pushl $7
80108d05:	6a 07                	push   $0x7
  jmp alltraps
80108d07:	e9 6a f9 ff ff       	jmp    80108676 <alltraps>

80108d0c <vector8>:
.globl vector8
vector8:
  pushl $8
80108d0c:	6a 08                	push   $0x8
  jmp alltraps
80108d0e:	e9 63 f9 ff ff       	jmp    80108676 <alltraps>

80108d13 <vector9>:
.globl vector9
vector9:
  pushl $0
80108d13:	6a 00                	push   $0x0
  pushl $9
80108d15:	6a 09                	push   $0x9
  jmp alltraps
80108d17:	e9 5a f9 ff ff       	jmp    80108676 <alltraps>

80108d1c <vector10>:
.globl vector10
vector10:
  pushl $10
80108d1c:	6a 0a                	push   $0xa
  jmp alltraps
80108d1e:	e9 53 f9 ff ff       	jmp    80108676 <alltraps>

80108d23 <vector11>:
.globl vector11
vector11:
  pushl $11
80108d23:	6a 0b                	push   $0xb
  jmp alltraps
80108d25:	e9 4c f9 ff ff       	jmp    80108676 <alltraps>

80108d2a <vector12>:
.globl vector12
vector12:
  pushl $12
80108d2a:	6a 0c                	push   $0xc
  jmp alltraps
80108d2c:	e9 45 f9 ff ff       	jmp    80108676 <alltraps>

80108d31 <vector13>:
.globl vector13
vector13:
  pushl $13
80108d31:	6a 0d                	push   $0xd
  jmp alltraps
80108d33:	e9 3e f9 ff ff       	jmp    80108676 <alltraps>

80108d38 <vector14>:
.globl vector14
vector14:
  pushl $14
80108d38:	6a 0e                	push   $0xe
  jmp alltraps
80108d3a:	e9 37 f9 ff ff       	jmp    80108676 <alltraps>

80108d3f <vector15>:
.globl vector15
vector15:
  pushl $0
80108d3f:	6a 00                	push   $0x0
  pushl $15
80108d41:	6a 0f                	push   $0xf
  jmp alltraps
80108d43:	e9 2e f9 ff ff       	jmp    80108676 <alltraps>

80108d48 <vector16>:
.globl vector16
vector16:
  pushl $0
80108d48:	6a 00                	push   $0x0
  pushl $16
80108d4a:	6a 10                	push   $0x10
  jmp alltraps
80108d4c:	e9 25 f9 ff ff       	jmp    80108676 <alltraps>

80108d51 <vector17>:
.globl vector17
vector17:
  pushl $17
80108d51:	6a 11                	push   $0x11
  jmp alltraps
80108d53:	e9 1e f9 ff ff       	jmp    80108676 <alltraps>

80108d58 <vector18>:
.globl vector18
vector18:
  pushl $0
80108d58:	6a 00                	push   $0x0
  pushl $18
80108d5a:	6a 12                	push   $0x12
  jmp alltraps
80108d5c:	e9 15 f9 ff ff       	jmp    80108676 <alltraps>

80108d61 <vector19>:
.globl vector19
vector19:
  pushl $0
80108d61:	6a 00                	push   $0x0
  pushl $19
80108d63:	6a 13                	push   $0x13
  jmp alltraps
80108d65:	e9 0c f9 ff ff       	jmp    80108676 <alltraps>

80108d6a <vector20>:
.globl vector20
vector20:
  pushl $0
80108d6a:	6a 00                	push   $0x0
  pushl $20
80108d6c:	6a 14                	push   $0x14
  jmp alltraps
80108d6e:	e9 03 f9 ff ff       	jmp    80108676 <alltraps>

80108d73 <vector21>:
.globl vector21
vector21:
  pushl $0
80108d73:	6a 00                	push   $0x0
  pushl $21
80108d75:	6a 15                	push   $0x15
  jmp alltraps
80108d77:	e9 fa f8 ff ff       	jmp    80108676 <alltraps>

80108d7c <vector22>:
.globl vector22
vector22:
  pushl $0
80108d7c:	6a 00                	push   $0x0
  pushl $22
80108d7e:	6a 16                	push   $0x16
  jmp alltraps
80108d80:	e9 f1 f8 ff ff       	jmp    80108676 <alltraps>

80108d85 <vector23>:
.globl vector23
vector23:
  pushl $0
80108d85:	6a 00                	push   $0x0
  pushl $23
80108d87:	6a 17                	push   $0x17
  jmp alltraps
80108d89:	e9 e8 f8 ff ff       	jmp    80108676 <alltraps>

80108d8e <vector24>:
.globl vector24
vector24:
  pushl $0
80108d8e:	6a 00                	push   $0x0
  pushl $24
80108d90:	6a 18                	push   $0x18
  jmp alltraps
80108d92:	e9 df f8 ff ff       	jmp    80108676 <alltraps>

80108d97 <vector25>:
.globl vector25
vector25:
  pushl $0
80108d97:	6a 00                	push   $0x0
  pushl $25
80108d99:	6a 19                	push   $0x19
  jmp alltraps
80108d9b:	e9 d6 f8 ff ff       	jmp    80108676 <alltraps>

80108da0 <vector26>:
.globl vector26
vector26:
  pushl $0
80108da0:	6a 00                	push   $0x0
  pushl $26
80108da2:	6a 1a                	push   $0x1a
  jmp alltraps
80108da4:	e9 cd f8 ff ff       	jmp    80108676 <alltraps>

80108da9 <vector27>:
.globl vector27
vector27:
  pushl $0
80108da9:	6a 00                	push   $0x0
  pushl $27
80108dab:	6a 1b                	push   $0x1b
  jmp alltraps
80108dad:	e9 c4 f8 ff ff       	jmp    80108676 <alltraps>

80108db2 <vector28>:
.globl vector28
vector28:
  pushl $0
80108db2:	6a 00                	push   $0x0
  pushl $28
80108db4:	6a 1c                	push   $0x1c
  jmp alltraps
80108db6:	e9 bb f8 ff ff       	jmp    80108676 <alltraps>

80108dbb <vector29>:
.globl vector29
vector29:
  pushl $0
80108dbb:	6a 00                	push   $0x0
  pushl $29
80108dbd:	6a 1d                	push   $0x1d
  jmp alltraps
80108dbf:	e9 b2 f8 ff ff       	jmp    80108676 <alltraps>

80108dc4 <vector30>:
.globl vector30
vector30:
  pushl $0
80108dc4:	6a 00                	push   $0x0
  pushl $30
80108dc6:	6a 1e                	push   $0x1e
  jmp alltraps
80108dc8:	e9 a9 f8 ff ff       	jmp    80108676 <alltraps>

80108dcd <vector31>:
.globl vector31
vector31:
  pushl $0
80108dcd:	6a 00                	push   $0x0
  pushl $31
80108dcf:	6a 1f                	push   $0x1f
  jmp alltraps
80108dd1:	e9 a0 f8 ff ff       	jmp    80108676 <alltraps>

80108dd6 <vector32>:
.globl vector32
vector32:
  pushl $0
80108dd6:	6a 00                	push   $0x0
  pushl $32
80108dd8:	6a 20                	push   $0x20
  jmp alltraps
80108dda:	e9 97 f8 ff ff       	jmp    80108676 <alltraps>

80108ddf <vector33>:
.globl vector33
vector33:
  pushl $0
80108ddf:	6a 00                	push   $0x0
  pushl $33
80108de1:	6a 21                	push   $0x21
  jmp alltraps
80108de3:	e9 8e f8 ff ff       	jmp    80108676 <alltraps>

80108de8 <vector34>:
.globl vector34
vector34:
  pushl $0
80108de8:	6a 00                	push   $0x0
  pushl $34
80108dea:	6a 22                	push   $0x22
  jmp alltraps
80108dec:	e9 85 f8 ff ff       	jmp    80108676 <alltraps>

80108df1 <vector35>:
.globl vector35
vector35:
  pushl $0
80108df1:	6a 00                	push   $0x0
  pushl $35
80108df3:	6a 23                	push   $0x23
  jmp alltraps
80108df5:	e9 7c f8 ff ff       	jmp    80108676 <alltraps>

80108dfa <vector36>:
.globl vector36
vector36:
  pushl $0
80108dfa:	6a 00                	push   $0x0
  pushl $36
80108dfc:	6a 24                	push   $0x24
  jmp alltraps
80108dfe:	e9 73 f8 ff ff       	jmp    80108676 <alltraps>

80108e03 <vector37>:
.globl vector37
vector37:
  pushl $0
80108e03:	6a 00                	push   $0x0
  pushl $37
80108e05:	6a 25                	push   $0x25
  jmp alltraps
80108e07:	e9 6a f8 ff ff       	jmp    80108676 <alltraps>

80108e0c <vector38>:
.globl vector38
vector38:
  pushl $0
80108e0c:	6a 00                	push   $0x0
  pushl $38
80108e0e:	6a 26                	push   $0x26
  jmp alltraps
80108e10:	e9 61 f8 ff ff       	jmp    80108676 <alltraps>

80108e15 <vector39>:
.globl vector39
vector39:
  pushl $0
80108e15:	6a 00                	push   $0x0
  pushl $39
80108e17:	6a 27                	push   $0x27
  jmp alltraps
80108e19:	e9 58 f8 ff ff       	jmp    80108676 <alltraps>

80108e1e <vector40>:
.globl vector40
vector40:
  pushl $0
80108e1e:	6a 00                	push   $0x0
  pushl $40
80108e20:	6a 28                	push   $0x28
  jmp alltraps
80108e22:	e9 4f f8 ff ff       	jmp    80108676 <alltraps>

80108e27 <vector41>:
.globl vector41
vector41:
  pushl $0
80108e27:	6a 00                	push   $0x0
  pushl $41
80108e29:	6a 29                	push   $0x29
  jmp alltraps
80108e2b:	e9 46 f8 ff ff       	jmp    80108676 <alltraps>

80108e30 <vector42>:
.globl vector42
vector42:
  pushl $0
80108e30:	6a 00                	push   $0x0
  pushl $42
80108e32:	6a 2a                	push   $0x2a
  jmp alltraps
80108e34:	e9 3d f8 ff ff       	jmp    80108676 <alltraps>

80108e39 <vector43>:
.globl vector43
vector43:
  pushl $0
80108e39:	6a 00                	push   $0x0
  pushl $43
80108e3b:	6a 2b                	push   $0x2b
  jmp alltraps
80108e3d:	e9 34 f8 ff ff       	jmp    80108676 <alltraps>

80108e42 <vector44>:
.globl vector44
vector44:
  pushl $0
80108e42:	6a 00                	push   $0x0
  pushl $44
80108e44:	6a 2c                	push   $0x2c
  jmp alltraps
80108e46:	e9 2b f8 ff ff       	jmp    80108676 <alltraps>

80108e4b <vector45>:
.globl vector45
vector45:
  pushl $0
80108e4b:	6a 00                	push   $0x0
  pushl $45
80108e4d:	6a 2d                	push   $0x2d
  jmp alltraps
80108e4f:	e9 22 f8 ff ff       	jmp    80108676 <alltraps>

80108e54 <vector46>:
.globl vector46
vector46:
  pushl $0
80108e54:	6a 00                	push   $0x0
  pushl $46
80108e56:	6a 2e                	push   $0x2e
  jmp alltraps
80108e58:	e9 19 f8 ff ff       	jmp    80108676 <alltraps>

80108e5d <vector47>:
.globl vector47
vector47:
  pushl $0
80108e5d:	6a 00                	push   $0x0
  pushl $47
80108e5f:	6a 2f                	push   $0x2f
  jmp alltraps
80108e61:	e9 10 f8 ff ff       	jmp    80108676 <alltraps>

80108e66 <vector48>:
.globl vector48
vector48:
  pushl $0
80108e66:	6a 00                	push   $0x0
  pushl $48
80108e68:	6a 30                	push   $0x30
  jmp alltraps
80108e6a:	e9 07 f8 ff ff       	jmp    80108676 <alltraps>

80108e6f <vector49>:
.globl vector49
vector49:
  pushl $0
80108e6f:	6a 00                	push   $0x0
  pushl $49
80108e71:	6a 31                	push   $0x31
  jmp alltraps
80108e73:	e9 fe f7 ff ff       	jmp    80108676 <alltraps>

80108e78 <vector50>:
.globl vector50
vector50:
  pushl $0
80108e78:	6a 00                	push   $0x0
  pushl $50
80108e7a:	6a 32                	push   $0x32
  jmp alltraps
80108e7c:	e9 f5 f7 ff ff       	jmp    80108676 <alltraps>

80108e81 <vector51>:
.globl vector51
vector51:
  pushl $0
80108e81:	6a 00                	push   $0x0
  pushl $51
80108e83:	6a 33                	push   $0x33
  jmp alltraps
80108e85:	e9 ec f7 ff ff       	jmp    80108676 <alltraps>

80108e8a <vector52>:
.globl vector52
vector52:
  pushl $0
80108e8a:	6a 00                	push   $0x0
  pushl $52
80108e8c:	6a 34                	push   $0x34
  jmp alltraps
80108e8e:	e9 e3 f7 ff ff       	jmp    80108676 <alltraps>

80108e93 <vector53>:
.globl vector53
vector53:
  pushl $0
80108e93:	6a 00                	push   $0x0
  pushl $53
80108e95:	6a 35                	push   $0x35
  jmp alltraps
80108e97:	e9 da f7 ff ff       	jmp    80108676 <alltraps>

80108e9c <vector54>:
.globl vector54
vector54:
  pushl $0
80108e9c:	6a 00                	push   $0x0
  pushl $54
80108e9e:	6a 36                	push   $0x36
  jmp alltraps
80108ea0:	e9 d1 f7 ff ff       	jmp    80108676 <alltraps>

80108ea5 <vector55>:
.globl vector55
vector55:
  pushl $0
80108ea5:	6a 00                	push   $0x0
  pushl $55
80108ea7:	6a 37                	push   $0x37
  jmp alltraps
80108ea9:	e9 c8 f7 ff ff       	jmp    80108676 <alltraps>

80108eae <vector56>:
.globl vector56
vector56:
  pushl $0
80108eae:	6a 00                	push   $0x0
  pushl $56
80108eb0:	6a 38                	push   $0x38
  jmp alltraps
80108eb2:	e9 bf f7 ff ff       	jmp    80108676 <alltraps>

80108eb7 <vector57>:
.globl vector57
vector57:
  pushl $0
80108eb7:	6a 00                	push   $0x0
  pushl $57
80108eb9:	6a 39                	push   $0x39
  jmp alltraps
80108ebb:	e9 b6 f7 ff ff       	jmp    80108676 <alltraps>

80108ec0 <vector58>:
.globl vector58
vector58:
  pushl $0
80108ec0:	6a 00                	push   $0x0
  pushl $58
80108ec2:	6a 3a                	push   $0x3a
  jmp alltraps
80108ec4:	e9 ad f7 ff ff       	jmp    80108676 <alltraps>

80108ec9 <vector59>:
.globl vector59
vector59:
  pushl $0
80108ec9:	6a 00                	push   $0x0
  pushl $59
80108ecb:	6a 3b                	push   $0x3b
  jmp alltraps
80108ecd:	e9 a4 f7 ff ff       	jmp    80108676 <alltraps>

80108ed2 <vector60>:
.globl vector60
vector60:
  pushl $0
80108ed2:	6a 00                	push   $0x0
  pushl $60
80108ed4:	6a 3c                	push   $0x3c
  jmp alltraps
80108ed6:	e9 9b f7 ff ff       	jmp    80108676 <alltraps>

80108edb <vector61>:
.globl vector61
vector61:
  pushl $0
80108edb:	6a 00                	push   $0x0
  pushl $61
80108edd:	6a 3d                	push   $0x3d
  jmp alltraps
80108edf:	e9 92 f7 ff ff       	jmp    80108676 <alltraps>

80108ee4 <vector62>:
.globl vector62
vector62:
  pushl $0
80108ee4:	6a 00                	push   $0x0
  pushl $62
80108ee6:	6a 3e                	push   $0x3e
  jmp alltraps
80108ee8:	e9 89 f7 ff ff       	jmp    80108676 <alltraps>

80108eed <vector63>:
.globl vector63
vector63:
  pushl $0
80108eed:	6a 00                	push   $0x0
  pushl $63
80108eef:	6a 3f                	push   $0x3f
  jmp alltraps
80108ef1:	e9 80 f7 ff ff       	jmp    80108676 <alltraps>

80108ef6 <vector64>:
.globl vector64
vector64:
  pushl $0
80108ef6:	6a 00                	push   $0x0
  pushl $64
80108ef8:	6a 40                	push   $0x40
  jmp alltraps
80108efa:	e9 77 f7 ff ff       	jmp    80108676 <alltraps>

80108eff <vector65>:
.globl vector65
vector65:
  pushl $0
80108eff:	6a 00                	push   $0x0
  pushl $65
80108f01:	6a 41                	push   $0x41
  jmp alltraps
80108f03:	e9 6e f7 ff ff       	jmp    80108676 <alltraps>

80108f08 <vector66>:
.globl vector66
vector66:
  pushl $0
80108f08:	6a 00                	push   $0x0
  pushl $66
80108f0a:	6a 42                	push   $0x42
  jmp alltraps
80108f0c:	e9 65 f7 ff ff       	jmp    80108676 <alltraps>

80108f11 <vector67>:
.globl vector67
vector67:
  pushl $0
80108f11:	6a 00                	push   $0x0
  pushl $67
80108f13:	6a 43                	push   $0x43
  jmp alltraps
80108f15:	e9 5c f7 ff ff       	jmp    80108676 <alltraps>

80108f1a <vector68>:
.globl vector68
vector68:
  pushl $0
80108f1a:	6a 00                	push   $0x0
  pushl $68
80108f1c:	6a 44                	push   $0x44
  jmp alltraps
80108f1e:	e9 53 f7 ff ff       	jmp    80108676 <alltraps>

80108f23 <vector69>:
.globl vector69
vector69:
  pushl $0
80108f23:	6a 00                	push   $0x0
  pushl $69
80108f25:	6a 45                	push   $0x45
  jmp alltraps
80108f27:	e9 4a f7 ff ff       	jmp    80108676 <alltraps>

80108f2c <vector70>:
.globl vector70
vector70:
  pushl $0
80108f2c:	6a 00                	push   $0x0
  pushl $70
80108f2e:	6a 46                	push   $0x46
  jmp alltraps
80108f30:	e9 41 f7 ff ff       	jmp    80108676 <alltraps>

80108f35 <vector71>:
.globl vector71
vector71:
  pushl $0
80108f35:	6a 00                	push   $0x0
  pushl $71
80108f37:	6a 47                	push   $0x47
  jmp alltraps
80108f39:	e9 38 f7 ff ff       	jmp    80108676 <alltraps>

80108f3e <vector72>:
.globl vector72
vector72:
  pushl $0
80108f3e:	6a 00                	push   $0x0
  pushl $72
80108f40:	6a 48                	push   $0x48
  jmp alltraps
80108f42:	e9 2f f7 ff ff       	jmp    80108676 <alltraps>

80108f47 <vector73>:
.globl vector73
vector73:
  pushl $0
80108f47:	6a 00                	push   $0x0
  pushl $73
80108f49:	6a 49                	push   $0x49
  jmp alltraps
80108f4b:	e9 26 f7 ff ff       	jmp    80108676 <alltraps>

80108f50 <vector74>:
.globl vector74
vector74:
  pushl $0
80108f50:	6a 00                	push   $0x0
  pushl $74
80108f52:	6a 4a                	push   $0x4a
  jmp alltraps
80108f54:	e9 1d f7 ff ff       	jmp    80108676 <alltraps>

80108f59 <vector75>:
.globl vector75
vector75:
  pushl $0
80108f59:	6a 00                	push   $0x0
  pushl $75
80108f5b:	6a 4b                	push   $0x4b
  jmp alltraps
80108f5d:	e9 14 f7 ff ff       	jmp    80108676 <alltraps>

80108f62 <vector76>:
.globl vector76
vector76:
  pushl $0
80108f62:	6a 00                	push   $0x0
  pushl $76
80108f64:	6a 4c                	push   $0x4c
  jmp alltraps
80108f66:	e9 0b f7 ff ff       	jmp    80108676 <alltraps>

80108f6b <vector77>:
.globl vector77
vector77:
  pushl $0
80108f6b:	6a 00                	push   $0x0
  pushl $77
80108f6d:	6a 4d                	push   $0x4d
  jmp alltraps
80108f6f:	e9 02 f7 ff ff       	jmp    80108676 <alltraps>

80108f74 <vector78>:
.globl vector78
vector78:
  pushl $0
80108f74:	6a 00                	push   $0x0
  pushl $78
80108f76:	6a 4e                	push   $0x4e
  jmp alltraps
80108f78:	e9 f9 f6 ff ff       	jmp    80108676 <alltraps>

80108f7d <vector79>:
.globl vector79
vector79:
  pushl $0
80108f7d:	6a 00                	push   $0x0
  pushl $79
80108f7f:	6a 4f                	push   $0x4f
  jmp alltraps
80108f81:	e9 f0 f6 ff ff       	jmp    80108676 <alltraps>

80108f86 <vector80>:
.globl vector80
vector80:
  pushl $0
80108f86:	6a 00                	push   $0x0
  pushl $80
80108f88:	6a 50                	push   $0x50
  jmp alltraps
80108f8a:	e9 e7 f6 ff ff       	jmp    80108676 <alltraps>

80108f8f <vector81>:
.globl vector81
vector81:
  pushl $0
80108f8f:	6a 00                	push   $0x0
  pushl $81
80108f91:	6a 51                	push   $0x51
  jmp alltraps
80108f93:	e9 de f6 ff ff       	jmp    80108676 <alltraps>

80108f98 <vector82>:
.globl vector82
vector82:
  pushl $0
80108f98:	6a 00                	push   $0x0
  pushl $82
80108f9a:	6a 52                	push   $0x52
  jmp alltraps
80108f9c:	e9 d5 f6 ff ff       	jmp    80108676 <alltraps>

80108fa1 <vector83>:
.globl vector83
vector83:
  pushl $0
80108fa1:	6a 00                	push   $0x0
  pushl $83
80108fa3:	6a 53                	push   $0x53
  jmp alltraps
80108fa5:	e9 cc f6 ff ff       	jmp    80108676 <alltraps>

80108faa <vector84>:
.globl vector84
vector84:
  pushl $0
80108faa:	6a 00                	push   $0x0
  pushl $84
80108fac:	6a 54                	push   $0x54
  jmp alltraps
80108fae:	e9 c3 f6 ff ff       	jmp    80108676 <alltraps>

80108fb3 <vector85>:
.globl vector85
vector85:
  pushl $0
80108fb3:	6a 00                	push   $0x0
  pushl $85
80108fb5:	6a 55                	push   $0x55
  jmp alltraps
80108fb7:	e9 ba f6 ff ff       	jmp    80108676 <alltraps>

80108fbc <vector86>:
.globl vector86
vector86:
  pushl $0
80108fbc:	6a 00                	push   $0x0
  pushl $86
80108fbe:	6a 56                	push   $0x56
  jmp alltraps
80108fc0:	e9 b1 f6 ff ff       	jmp    80108676 <alltraps>

80108fc5 <vector87>:
.globl vector87
vector87:
  pushl $0
80108fc5:	6a 00                	push   $0x0
  pushl $87
80108fc7:	6a 57                	push   $0x57
  jmp alltraps
80108fc9:	e9 a8 f6 ff ff       	jmp    80108676 <alltraps>

80108fce <vector88>:
.globl vector88
vector88:
  pushl $0
80108fce:	6a 00                	push   $0x0
  pushl $88
80108fd0:	6a 58                	push   $0x58
  jmp alltraps
80108fd2:	e9 9f f6 ff ff       	jmp    80108676 <alltraps>

80108fd7 <vector89>:
.globl vector89
vector89:
  pushl $0
80108fd7:	6a 00                	push   $0x0
  pushl $89
80108fd9:	6a 59                	push   $0x59
  jmp alltraps
80108fdb:	e9 96 f6 ff ff       	jmp    80108676 <alltraps>

80108fe0 <vector90>:
.globl vector90
vector90:
  pushl $0
80108fe0:	6a 00                	push   $0x0
  pushl $90
80108fe2:	6a 5a                	push   $0x5a
  jmp alltraps
80108fe4:	e9 8d f6 ff ff       	jmp    80108676 <alltraps>

80108fe9 <vector91>:
.globl vector91
vector91:
  pushl $0
80108fe9:	6a 00                	push   $0x0
  pushl $91
80108feb:	6a 5b                	push   $0x5b
  jmp alltraps
80108fed:	e9 84 f6 ff ff       	jmp    80108676 <alltraps>

80108ff2 <vector92>:
.globl vector92
vector92:
  pushl $0
80108ff2:	6a 00                	push   $0x0
  pushl $92
80108ff4:	6a 5c                	push   $0x5c
  jmp alltraps
80108ff6:	e9 7b f6 ff ff       	jmp    80108676 <alltraps>

80108ffb <vector93>:
.globl vector93
vector93:
  pushl $0
80108ffb:	6a 00                	push   $0x0
  pushl $93
80108ffd:	6a 5d                	push   $0x5d
  jmp alltraps
80108fff:	e9 72 f6 ff ff       	jmp    80108676 <alltraps>

80109004 <vector94>:
.globl vector94
vector94:
  pushl $0
80109004:	6a 00                	push   $0x0
  pushl $94
80109006:	6a 5e                	push   $0x5e
  jmp alltraps
80109008:	e9 69 f6 ff ff       	jmp    80108676 <alltraps>

8010900d <vector95>:
.globl vector95
vector95:
  pushl $0
8010900d:	6a 00                	push   $0x0
  pushl $95
8010900f:	6a 5f                	push   $0x5f
  jmp alltraps
80109011:	e9 60 f6 ff ff       	jmp    80108676 <alltraps>

80109016 <vector96>:
.globl vector96
vector96:
  pushl $0
80109016:	6a 00                	push   $0x0
  pushl $96
80109018:	6a 60                	push   $0x60
  jmp alltraps
8010901a:	e9 57 f6 ff ff       	jmp    80108676 <alltraps>

8010901f <vector97>:
.globl vector97
vector97:
  pushl $0
8010901f:	6a 00                	push   $0x0
  pushl $97
80109021:	6a 61                	push   $0x61
  jmp alltraps
80109023:	e9 4e f6 ff ff       	jmp    80108676 <alltraps>

80109028 <vector98>:
.globl vector98
vector98:
  pushl $0
80109028:	6a 00                	push   $0x0
  pushl $98
8010902a:	6a 62                	push   $0x62
  jmp alltraps
8010902c:	e9 45 f6 ff ff       	jmp    80108676 <alltraps>

80109031 <vector99>:
.globl vector99
vector99:
  pushl $0
80109031:	6a 00                	push   $0x0
  pushl $99
80109033:	6a 63                	push   $0x63
  jmp alltraps
80109035:	e9 3c f6 ff ff       	jmp    80108676 <alltraps>

8010903a <vector100>:
.globl vector100
vector100:
  pushl $0
8010903a:	6a 00                	push   $0x0
  pushl $100
8010903c:	6a 64                	push   $0x64
  jmp alltraps
8010903e:	e9 33 f6 ff ff       	jmp    80108676 <alltraps>

80109043 <vector101>:
.globl vector101
vector101:
  pushl $0
80109043:	6a 00                	push   $0x0
  pushl $101
80109045:	6a 65                	push   $0x65
  jmp alltraps
80109047:	e9 2a f6 ff ff       	jmp    80108676 <alltraps>

8010904c <vector102>:
.globl vector102
vector102:
  pushl $0
8010904c:	6a 00                	push   $0x0
  pushl $102
8010904e:	6a 66                	push   $0x66
  jmp alltraps
80109050:	e9 21 f6 ff ff       	jmp    80108676 <alltraps>

80109055 <vector103>:
.globl vector103
vector103:
  pushl $0
80109055:	6a 00                	push   $0x0
  pushl $103
80109057:	6a 67                	push   $0x67
  jmp alltraps
80109059:	e9 18 f6 ff ff       	jmp    80108676 <alltraps>

8010905e <vector104>:
.globl vector104
vector104:
  pushl $0
8010905e:	6a 00                	push   $0x0
  pushl $104
80109060:	6a 68                	push   $0x68
  jmp alltraps
80109062:	e9 0f f6 ff ff       	jmp    80108676 <alltraps>

80109067 <vector105>:
.globl vector105
vector105:
  pushl $0
80109067:	6a 00                	push   $0x0
  pushl $105
80109069:	6a 69                	push   $0x69
  jmp alltraps
8010906b:	e9 06 f6 ff ff       	jmp    80108676 <alltraps>

80109070 <vector106>:
.globl vector106
vector106:
  pushl $0
80109070:	6a 00                	push   $0x0
  pushl $106
80109072:	6a 6a                	push   $0x6a
  jmp alltraps
80109074:	e9 fd f5 ff ff       	jmp    80108676 <alltraps>

80109079 <vector107>:
.globl vector107
vector107:
  pushl $0
80109079:	6a 00                	push   $0x0
  pushl $107
8010907b:	6a 6b                	push   $0x6b
  jmp alltraps
8010907d:	e9 f4 f5 ff ff       	jmp    80108676 <alltraps>

80109082 <vector108>:
.globl vector108
vector108:
  pushl $0
80109082:	6a 00                	push   $0x0
  pushl $108
80109084:	6a 6c                	push   $0x6c
  jmp alltraps
80109086:	e9 eb f5 ff ff       	jmp    80108676 <alltraps>

8010908b <vector109>:
.globl vector109
vector109:
  pushl $0
8010908b:	6a 00                	push   $0x0
  pushl $109
8010908d:	6a 6d                	push   $0x6d
  jmp alltraps
8010908f:	e9 e2 f5 ff ff       	jmp    80108676 <alltraps>

80109094 <vector110>:
.globl vector110
vector110:
  pushl $0
80109094:	6a 00                	push   $0x0
  pushl $110
80109096:	6a 6e                	push   $0x6e
  jmp alltraps
80109098:	e9 d9 f5 ff ff       	jmp    80108676 <alltraps>

8010909d <vector111>:
.globl vector111
vector111:
  pushl $0
8010909d:	6a 00                	push   $0x0
  pushl $111
8010909f:	6a 6f                	push   $0x6f
  jmp alltraps
801090a1:	e9 d0 f5 ff ff       	jmp    80108676 <alltraps>

801090a6 <vector112>:
.globl vector112
vector112:
  pushl $0
801090a6:	6a 00                	push   $0x0
  pushl $112
801090a8:	6a 70                	push   $0x70
  jmp alltraps
801090aa:	e9 c7 f5 ff ff       	jmp    80108676 <alltraps>

801090af <vector113>:
.globl vector113
vector113:
  pushl $0
801090af:	6a 00                	push   $0x0
  pushl $113
801090b1:	6a 71                	push   $0x71
  jmp alltraps
801090b3:	e9 be f5 ff ff       	jmp    80108676 <alltraps>

801090b8 <vector114>:
.globl vector114
vector114:
  pushl $0
801090b8:	6a 00                	push   $0x0
  pushl $114
801090ba:	6a 72                	push   $0x72
  jmp alltraps
801090bc:	e9 b5 f5 ff ff       	jmp    80108676 <alltraps>

801090c1 <vector115>:
.globl vector115
vector115:
  pushl $0
801090c1:	6a 00                	push   $0x0
  pushl $115
801090c3:	6a 73                	push   $0x73
  jmp alltraps
801090c5:	e9 ac f5 ff ff       	jmp    80108676 <alltraps>

801090ca <vector116>:
.globl vector116
vector116:
  pushl $0
801090ca:	6a 00                	push   $0x0
  pushl $116
801090cc:	6a 74                	push   $0x74
  jmp alltraps
801090ce:	e9 a3 f5 ff ff       	jmp    80108676 <alltraps>

801090d3 <vector117>:
.globl vector117
vector117:
  pushl $0
801090d3:	6a 00                	push   $0x0
  pushl $117
801090d5:	6a 75                	push   $0x75
  jmp alltraps
801090d7:	e9 9a f5 ff ff       	jmp    80108676 <alltraps>

801090dc <vector118>:
.globl vector118
vector118:
  pushl $0
801090dc:	6a 00                	push   $0x0
  pushl $118
801090de:	6a 76                	push   $0x76
  jmp alltraps
801090e0:	e9 91 f5 ff ff       	jmp    80108676 <alltraps>

801090e5 <vector119>:
.globl vector119
vector119:
  pushl $0
801090e5:	6a 00                	push   $0x0
  pushl $119
801090e7:	6a 77                	push   $0x77
  jmp alltraps
801090e9:	e9 88 f5 ff ff       	jmp    80108676 <alltraps>

801090ee <vector120>:
.globl vector120
vector120:
  pushl $0
801090ee:	6a 00                	push   $0x0
  pushl $120
801090f0:	6a 78                	push   $0x78
  jmp alltraps
801090f2:	e9 7f f5 ff ff       	jmp    80108676 <alltraps>

801090f7 <vector121>:
.globl vector121
vector121:
  pushl $0
801090f7:	6a 00                	push   $0x0
  pushl $121
801090f9:	6a 79                	push   $0x79
  jmp alltraps
801090fb:	e9 76 f5 ff ff       	jmp    80108676 <alltraps>

80109100 <vector122>:
.globl vector122
vector122:
  pushl $0
80109100:	6a 00                	push   $0x0
  pushl $122
80109102:	6a 7a                	push   $0x7a
  jmp alltraps
80109104:	e9 6d f5 ff ff       	jmp    80108676 <alltraps>

80109109 <vector123>:
.globl vector123
vector123:
  pushl $0
80109109:	6a 00                	push   $0x0
  pushl $123
8010910b:	6a 7b                	push   $0x7b
  jmp alltraps
8010910d:	e9 64 f5 ff ff       	jmp    80108676 <alltraps>

80109112 <vector124>:
.globl vector124
vector124:
  pushl $0
80109112:	6a 00                	push   $0x0
  pushl $124
80109114:	6a 7c                	push   $0x7c
  jmp alltraps
80109116:	e9 5b f5 ff ff       	jmp    80108676 <alltraps>

8010911b <vector125>:
.globl vector125
vector125:
  pushl $0
8010911b:	6a 00                	push   $0x0
  pushl $125
8010911d:	6a 7d                	push   $0x7d
  jmp alltraps
8010911f:	e9 52 f5 ff ff       	jmp    80108676 <alltraps>

80109124 <vector126>:
.globl vector126
vector126:
  pushl $0
80109124:	6a 00                	push   $0x0
  pushl $126
80109126:	6a 7e                	push   $0x7e
  jmp alltraps
80109128:	e9 49 f5 ff ff       	jmp    80108676 <alltraps>

8010912d <vector127>:
.globl vector127
vector127:
  pushl $0
8010912d:	6a 00                	push   $0x0
  pushl $127
8010912f:	6a 7f                	push   $0x7f
  jmp alltraps
80109131:	e9 40 f5 ff ff       	jmp    80108676 <alltraps>

80109136 <vector128>:
.globl vector128
vector128:
  pushl $0
80109136:	6a 00                	push   $0x0
  pushl $128
80109138:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010913d:	e9 34 f5 ff ff       	jmp    80108676 <alltraps>

80109142 <vector129>:
.globl vector129
vector129:
  pushl $0
80109142:	6a 00                	push   $0x0
  pushl $129
80109144:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80109149:	e9 28 f5 ff ff       	jmp    80108676 <alltraps>

8010914e <vector130>:
.globl vector130
vector130:
  pushl $0
8010914e:	6a 00                	push   $0x0
  pushl $130
80109150:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80109155:	e9 1c f5 ff ff       	jmp    80108676 <alltraps>

8010915a <vector131>:
.globl vector131
vector131:
  pushl $0
8010915a:	6a 00                	push   $0x0
  pushl $131
8010915c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80109161:	e9 10 f5 ff ff       	jmp    80108676 <alltraps>

80109166 <vector132>:
.globl vector132
vector132:
  pushl $0
80109166:	6a 00                	push   $0x0
  pushl $132
80109168:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010916d:	e9 04 f5 ff ff       	jmp    80108676 <alltraps>

80109172 <vector133>:
.globl vector133
vector133:
  pushl $0
80109172:	6a 00                	push   $0x0
  pushl $133
80109174:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80109179:	e9 f8 f4 ff ff       	jmp    80108676 <alltraps>

8010917e <vector134>:
.globl vector134
vector134:
  pushl $0
8010917e:	6a 00                	push   $0x0
  pushl $134
80109180:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80109185:	e9 ec f4 ff ff       	jmp    80108676 <alltraps>

8010918a <vector135>:
.globl vector135
vector135:
  pushl $0
8010918a:	6a 00                	push   $0x0
  pushl $135
8010918c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80109191:	e9 e0 f4 ff ff       	jmp    80108676 <alltraps>

80109196 <vector136>:
.globl vector136
vector136:
  pushl $0
80109196:	6a 00                	push   $0x0
  pushl $136
80109198:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010919d:	e9 d4 f4 ff ff       	jmp    80108676 <alltraps>

801091a2 <vector137>:
.globl vector137
vector137:
  pushl $0
801091a2:	6a 00                	push   $0x0
  pushl $137
801091a4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801091a9:	e9 c8 f4 ff ff       	jmp    80108676 <alltraps>

801091ae <vector138>:
.globl vector138
vector138:
  pushl $0
801091ae:	6a 00                	push   $0x0
  pushl $138
801091b0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801091b5:	e9 bc f4 ff ff       	jmp    80108676 <alltraps>

801091ba <vector139>:
.globl vector139
vector139:
  pushl $0
801091ba:	6a 00                	push   $0x0
  pushl $139
801091bc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801091c1:	e9 b0 f4 ff ff       	jmp    80108676 <alltraps>

801091c6 <vector140>:
.globl vector140
vector140:
  pushl $0
801091c6:	6a 00                	push   $0x0
  pushl $140
801091c8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801091cd:	e9 a4 f4 ff ff       	jmp    80108676 <alltraps>

801091d2 <vector141>:
.globl vector141
vector141:
  pushl $0
801091d2:	6a 00                	push   $0x0
  pushl $141
801091d4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801091d9:	e9 98 f4 ff ff       	jmp    80108676 <alltraps>

801091de <vector142>:
.globl vector142
vector142:
  pushl $0
801091de:	6a 00                	push   $0x0
  pushl $142
801091e0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801091e5:	e9 8c f4 ff ff       	jmp    80108676 <alltraps>

801091ea <vector143>:
.globl vector143
vector143:
  pushl $0
801091ea:	6a 00                	push   $0x0
  pushl $143
801091ec:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801091f1:	e9 80 f4 ff ff       	jmp    80108676 <alltraps>

801091f6 <vector144>:
.globl vector144
vector144:
  pushl $0
801091f6:	6a 00                	push   $0x0
  pushl $144
801091f8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801091fd:	e9 74 f4 ff ff       	jmp    80108676 <alltraps>

80109202 <vector145>:
.globl vector145
vector145:
  pushl $0
80109202:	6a 00                	push   $0x0
  pushl $145
80109204:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80109209:	e9 68 f4 ff ff       	jmp    80108676 <alltraps>

8010920e <vector146>:
.globl vector146
vector146:
  pushl $0
8010920e:	6a 00                	push   $0x0
  pushl $146
80109210:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80109215:	e9 5c f4 ff ff       	jmp    80108676 <alltraps>

8010921a <vector147>:
.globl vector147
vector147:
  pushl $0
8010921a:	6a 00                	push   $0x0
  pushl $147
8010921c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80109221:	e9 50 f4 ff ff       	jmp    80108676 <alltraps>

80109226 <vector148>:
.globl vector148
vector148:
  pushl $0
80109226:	6a 00                	push   $0x0
  pushl $148
80109228:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010922d:	e9 44 f4 ff ff       	jmp    80108676 <alltraps>

80109232 <vector149>:
.globl vector149
vector149:
  pushl $0
80109232:	6a 00                	push   $0x0
  pushl $149
80109234:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80109239:	e9 38 f4 ff ff       	jmp    80108676 <alltraps>

8010923e <vector150>:
.globl vector150
vector150:
  pushl $0
8010923e:	6a 00                	push   $0x0
  pushl $150
80109240:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80109245:	e9 2c f4 ff ff       	jmp    80108676 <alltraps>

8010924a <vector151>:
.globl vector151
vector151:
  pushl $0
8010924a:	6a 00                	push   $0x0
  pushl $151
8010924c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80109251:	e9 20 f4 ff ff       	jmp    80108676 <alltraps>

80109256 <vector152>:
.globl vector152
vector152:
  pushl $0
80109256:	6a 00                	push   $0x0
  pushl $152
80109258:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010925d:	e9 14 f4 ff ff       	jmp    80108676 <alltraps>

80109262 <vector153>:
.globl vector153
vector153:
  pushl $0
80109262:	6a 00                	push   $0x0
  pushl $153
80109264:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80109269:	e9 08 f4 ff ff       	jmp    80108676 <alltraps>

8010926e <vector154>:
.globl vector154
vector154:
  pushl $0
8010926e:	6a 00                	push   $0x0
  pushl $154
80109270:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80109275:	e9 fc f3 ff ff       	jmp    80108676 <alltraps>

8010927a <vector155>:
.globl vector155
vector155:
  pushl $0
8010927a:	6a 00                	push   $0x0
  pushl $155
8010927c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80109281:	e9 f0 f3 ff ff       	jmp    80108676 <alltraps>

80109286 <vector156>:
.globl vector156
vector156:
  pushl $0
80109286:	6a 00                	push   $0x0
  pushl $156
80109288:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010928d:	e9 e4 f3 ff ff       	jmp    80108676 <alltraps>

80109292 <vector157>:
.globl vector157
vector157:
  pushl $0
80109292:	6a 00                	push   $0x0
  pushl $157
80109294:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80109299:	e9 d8 f3 ff ff       	jmp    80108676 <alltraps>

8010929e <vector158>:
.globl vector158
vector158:
  pushl $0
8010929e:	6a 00                	push   $0x0
  pushl $158
801092a0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801092a5:	e9 cc f3 ff ff       	jmp    80108676 <alltraps>

801092aa <vector159>:
.globl vector159
vector159:
  pushl $0
801092aa:	6a 00                	push   $0x0
  pushl $159
801092ac:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801092b1:	e9 c0 f3 ff ff       	jmp    80108676 <alltraps>

801092b6 <vector160>:
.globl vector160
vector160:
  pushl $0
801092b6:	6a 00                	push   $0x0
  pushl $160
801092b8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801092bd:	e9 b4 f3 ff ff       	jmp    80108676 <alltraps>

801092c2 <vector161>:
.globl vector161
vector161:
  pushl $0
801092c2:	6a 00                	push   $0x0
  pushl $161
801092c4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801092c9:	e9 a8 f3 ff ff       	jmp    80108676 <alltraps>

801092ce <vector162>:
.globl vector162
vector162:
  pushl $0
801092ce:	6a 00                	push   $0x0
  pushl $162
801092d0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801092d5:	e9 9c f3 ff ff       	jmp    80108676 <alltraps>

801092da <vector163>:
.globl vector163
vector163:
  pushl $0
801092da:	6a 00                	push   $0x0
  pushl $163
801092dc:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801092e1:	e9 90 f3 ff ff       	jmp    80108676 <alltraps>

801092e6 <vector164>:
.globl vector164
vector164:
  pushl $0
801092e6:	6a 00                	push   $0x0
  pushl $164
801092e8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801092ed:	e9 84 f3 ff ff       	jmp    80108676 <alltraps>

801092f2 <vector165>:
.globl vector165
vector165:
  pushl $0
801092f2:	6a 00                	push   $0x0
  pushl $165
801092f4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801092f9:	e9 78 f3 ff ff       	jmp    80108676 <alltraps>

801092fe <vector166>:
.globl vector166
vector166:
  pushl $0
801092fe:	6a 00                	push   $0x0
  pushl $166
80109300:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80109305:	e9 6c f3 ff ff       	jmp    80108676 <alltraps>

8010930a <vector167>:
.globl vector167
vector167:
  pushl $0
8010930a:	6a 00                	push   $0x0
  pushl $167
8010930c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80109311:	e9 60 f3 ff ff       	jmp    80108676 <alltraps>

80109316 <vector168>:
.globl vector168
vector168:
  pushl $0
80109316:	6a 00                	push   $0x0
  pushl $168
80109318:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010931d:	e9 54 f3 ff ff       	jmp    80108676 <alltraps>

80109322 <vector169>:
.globl vector169
vector169:
  pushl $0
80109322:	6a 00                	push   $0x0
  pushl $169
80109324:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80109329:	e9 48 f3 ff ff       	jmp    80108676 <alltraps>

8010932e <vector170>:
.globl vector170
vector170:
  pushl $0
8010932e:	6a 00                	push   $0x0
  pushl $170
80109330:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80109335:	e9 3c f3 ff ff       	jmp    80108676 <alltraps>

8010933a <vector171>:
.globl vector171
vector171:
  pushl $0
8010933a:	6a 00                	push   $0x0
  pushl $171
8010933c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80109341:	e9 30 f3 ff ff       	jmp    80108676 <alltraps>

80109346 <vector172>:
.globl vector172
vector172:
  pushl $0
80109346:	6a 00                	push   $0x0
  pushl $172
80109348:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010934d:	e9 24 f3 ff ff       	jmp    80108676 <alltraps>

80109352 <vector173>:
.globl vector173
vector173:
  pushl $0
80109352:	6a 00                	push   $0x0
  pushl $173
80109354:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80109359:	e9 18 f3 ff ff       	jmp    80108676 <alltraps>

8010935e <vector174>:
.globl vector174
vector174:
  pushl $0
8010935e:	6a 00                	push   $0x0
  pushl $174
80109360:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80109365:	e9 0c f3 ff ff       	jmp    80108676 <alltraps>

8010936a <vector175>:
.globl vector175
vector175:
  pushl $0
8010936a:	6a 00                	push   $0x0
  pushl $175
8010936c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80109371:	e9 00 f3 ff ff       	jmp    80108676 <alltraps>

80109376 <vector176>:
.globl vector176
vector176:
  pushl $0
80109376:	6a 00                	push   $0x0
  pushl $176
80109378:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010937d:	e9 f4 f2 ff ff       	jmp    80108676 <alltraps>

80109382 <vector177>:
.globl vector177
vector177:
  pushl $0
80109382:	6a 00                	push   $0x0
  pushl $177
80109384:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80109389:	e9 e8 f2 ff ff       	jmp    80108676 <alltraps>

8010938e <vector178>:
.globl vector178
vector178:
  pushl $0
8010938e:	6a 00                	push   $0x0
  pushl $178
80109390:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80109395:	e9 dc f2 ff ff       	jmp    80108676 <alltraps>

8010939a <vector179>:
.globl vector179
vector179:
  pushl $0
8010939a:	6a 00                	push   $0x0
  pushl $179
8010939c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801093a1:	e9 d0 f2 ff ff       	jmp    80108676 <alltraps>

801093a6 <vector180>:
.globl vector180
vector180:
  pushl $0
801093a6:	6a 00                	push   $0x0
  pushl $180
801093a8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801093ad:	e9 c4 f2 ff ff       	jmp    80108676 <alltraps>

801093b2 <vector181>:
.globl vector181
vector181:
  pushl $0
801093b2:	6a 00                	push   $0x0
  pushl $181
801093b4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801093b9:	e9 b8 f2 ff ff       	jmp    80108676 <alltraps>

801093be <vector182>:
.globl vector182
vector182:
  pushl $0
801093be:	6a 00                	push   $0x0
  pushl $182
801093c0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801093c5:	e9 ac f2 ff ff       	jmp    80108676 <alltraps>

801093ca <vector183>:
.globl vector183
vector183:
  pushl $0
801093ca:	6a 00                	push   $0x0
  pushl $183
801093cc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801093d1:	e9 a0 f2 ff ff       	jmp    80108676 <alltraps>

801093d6 <vector184>:
.globl vector184
vector184:
  pushl $0
801093d6:	6a 00                	push   $0x0
  pushl $184
801093d8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801093dd:	e9 94 f2 ff ff       	jmp    80108676 <alltraps>

801093e2 <vector185>:
.globl vector185
vector185:
  pushl $0
801093e2:	6a 00                	push   $0x0
  pushl $185
801093e4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801093e9:	e9 88 f2 ff ff       	jmp    80108676 <alltraps>

801093ee <vector186>:
.globl vector186
vector186:
  pushl $0
801093ee:	6a 00                	push   $0x0
  pushl $186
801093f0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801093f5:	e9 7c f2 ff ff       	jmp    80108676 <alltraps>

801093fa <vector187>:
.globl vector187
vector187:
  pushl $0
801093fa:	6a 00                	push   $0x0
  pushl $187
801093fc:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80109401:	e9 70 f2 ff ff       	jmp    80108676 <alltraps>

80109406 <vector188>:
.globl vector188
vector188:
  pushl $0
80109406:	6a 00                	push   $0x0
  pushl $188
80109408:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010940d:	e9 64 f2 ff ff       	jmp    80108676 <alltraps>

80109412 <vector189>:
.globl vector189
vector189:
  pushl $0
80109412:	6a 00                	push   $0x0
  pushl $189
80109414:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80109419:	e9 58 f2 ff ff       	jmp    80108676 <alltraps>

8010941e <vector190>:
.globl vector190
vector190:
  pushl $0
8010941e:	6a 00                	push   $0x0
  pushl $190
80109420:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80109425:	e9 4c f2 ff ff       	jmp    80108676 <alltraps>

8010942a <vector191>:
.globl vector191
vector191:
  pushl $0
8010942a:	6a 00                	push   $0x0
  pushl $191
8010942c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80109431:	e9 40 f2 ff ff       	jmp    80108676 <alltraps>

80109436 <vector192>:
.globl vector192
vector192:
  pushl $0
80109436:	6a 00                	push   $0x0
  pushl $192
80109438:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010943d:	e9 34 f2 ff ff       	jmp    80108676 <alltraps>

80109442 <vector193>:
.globl vector193
vector193:
  pushl $0
80109442:	6a 00                	push   $0x0
  pushl $193
80109444:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80109449:	e9 28 f2 ff ff       	jmp    80108676 <alltraps>

8010944e <vector194>:
.globl vector194
vector194:
  pushl $0
8010944e:	6a 00                	push   $0x0
  pushl $194
80109450:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80109455:	e9 1c f2 ff ff       	jmp    80108676 <alltraps>

8010945a <vector195>:
.globl vector195
vector195:
  pushl $0
8010945a:	6a 00                	push   $0x0
  pushl $195
8010945c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80109461:	e9 10 f2 ff ff       	jmp    80108676 <alltraps>

80109466 <vector196>:
.globl vector196
vector196:
  pushl $0
80109466:	6a 00                	push   $0x0
  pushl $196
80109468:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010946d:	e9 04 f2 ff ff       	jmp    80108676 <alltraps>

80109472 <vector197>:
.globl vector197
vector197:
  pushl $0
80109472:	6a 00                	push   $0x0
  pushl $197
80109474:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80109479:	e9 f8 f1 ff ff       	jmp    80108676 <alltraps>

8010947e <vector198>:
.globl vector198
vector198:
  pushl $0
8010947e:	6a 00                	push   $0x0
  pushl $198
80109480:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80109485:	e9 ec f1 ff ff       	jmp    80108676 <alltraps>

8010948a <vector199>:
.globl vector199
vector199:
  pushl $0
8010948a:	6a 00                	push   $0x0
  pushl $199
8010948c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80109491:	e9 e0 f1 ff ff       	jmp    80108676 <alltraps>

80109496 <vector200>:
.globl vector200
vector200:
  pushl $0
80109496:	6a 00                	push   $0x0
  pushl $200
80109498:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010949d:	e9 d4 f1 ff ff       	jmp    80108676 <alltraps>

801094a2 <vector201>:
.globl vector201
vector201:
  pushl $0
801094a2:	6a 00                	push   $0x0
  pushl $201
801094a4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801094a9:	e9 c8 f1 ff ff       	jmp    80108676 <alltraps>

801094ae <vector202>:
.globl vector202
vector202:
  pushl $0
801094ae:	6a 00                	push   $0x0
  pushl $202
801094b0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801094b5:	e9 bc f1 ff ff       	jmp    80108676 <alltraps>

801094ba <vector203>:
.globl vector203
vector203:
  pushl $0
801094ba:	6a 00                	push   $0x0
  pushl $203
801094bc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801094c1:	e9 b0 f1 ff ff       	jmp    80108676 <alltraps>

801094c6 <vector204>:
.globl vector204
vector204:
  pushl $0
801094c6:	6a 00                	push   $0x0
  pushl $204
801094c8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801094cd:	e9 a4 f1 ff ff       	jmp    80108676 <alltraps>

801094d2 <vector205>:
.globl vector205
vector205:
  pushl $0
801094d2:	6a 00                	push   $0x0
  pushl $205
801094d4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801094d9:	e9 98 f1 ff ff       	jmp    80108676 <alltraps>

801094de <vector206>:
.globl vector206
vector206:
  pushl $0
801094de:	6a 00                	push   $0x0
  pushl $206
801094e0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801094e5:	e9 8c f1 ff ff       	jmp    80108676 <alltraps>

801094ea <vector207>:
.globl vector207
vector207:
  pushl $0
801094ea:	6a 00                	push   $0x0
  pushl $207
801094ec:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801094f1:	e9 80 f1 ff ff       	jmp    80108676 <alltraps>

801094f6 <vector208>:
.globl vector208
vector208:
  pushl $0
801094f6:	6a 00                	push   $0x0
  pushl $208
801094f8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801094fd:	e9 74 f1 ff ff       	jmp    80108676 <alltraps>

80109502 <vector209>:
.globl vector209
vector209:
  pushl $0
80109502:	6a 00                	push   $0x0
  pushl $209
80109504:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80109509:	e9 68 f1 ff ff       	jmp    80108676 <alltraps>

8010950e <vector210>:
.globl vector210
vector210:
  pushl $0
8010950e:	6a 00                	push   $0x0
  pushl $210
80109510:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80109515:	e9 5c f1 ff ff       	jmp    80108676 <alltraps>

8010951a <vector211>:
.globl vector211
vector211:
  pushl $0
8010951a:	6a 00                	push   $0x0
  pushl $211
8010951c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80109521:	e9 50 f1 ff ff       	jmp    80108676 <alltraps>

80109526 <vector212>:
.globl vector212
vector212:
  pushl $0
80109526:	6a 00                	push   $0x0
  pushl $212
80109528:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010952d:	e9 44 f1 ff ff       	jmp    80108676 <alltraps>

80109532 <vector213>:
.globl vector213
vector213:
  pushl $0
80109532:	6a 00                	push   $0x0
  pushl $213
80109534:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80109539:	e9 38 f1 ff ff       	jmp    80108676 <alltraps>

8010953e <vector214>:
.globl vector214
vector214:
  pushl $0
8010953e:	6a 00                	push   $0x0
  pushl $214
80109540:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80109545:	e9 2c f1 ff ff       	jmp    80108676 <alltraps>

8010954a <vector215>:
.globl vector215
vector215:
  pushl $0
8010954a:	6a 00                	push   $0x0
  pushl $215
8010954c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80109551:	e9 20 f1 ff ff       	jmp    80108676 <alltraps>

80109556 <vector216>:
.globl vector216
vector216:
  pushl $0
80109556:	6a 00                	push   $0x0
  pushl $216
80109558:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010955d:	e9 14 f1 ff ff       	jmp    80108676 <alltraps>

80109562 <vector217>:
.globl vector217
vector217:
  pushl $0
80109562:	6a 00                	push   $0x0
  pushl $217
80109564:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80109569:	e9 08 f1 ff ff       	jmp    80108676 <alltraps>

8010956e <vector218>:
.globl vector218
vector218:
  pushl $0
8010956e:	6a 00                	push   $0x0
  pushl $218
80109570:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80109575:	e9 fc f0 ff ff       	jmp    80108676 <alltraps>

8010957a <vector219>:
.globl vector219
vector219:
  pushl $0
8010957a:	6a 00                	push   $0x0
  pushl $219
8010957c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80109581:	e9 f0 f0 ff ff       	jmp    80108676 <alltraps>

80109586 <vector220>:
.globl vector220
vector220:
  pushl $0
80109586:	6a 00                	push   $0x0
  pushl $220
80109588:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010958d:	e9 e4 f0 ff ff       	jmp    80108676 <alltraps>

80109592 <vector221>:
.globl vector221
vector221:
  pushl $0
80109592:	6a 00                	push   $0x0
  pushl $221
80109594:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80109599:	e9 d8 f0 ff ff       	jmp    80108676 <alltraps>

8010959e <vector222>:
.globl vector222
vector222:
  pushl $0
8010959e:	6a 00                	push   $0x0
  pushl $222
801095a0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801095a5:	e9 cc f0 ff ff       	jmp    80108676 <alltraps>

801095aa <vector223>:
.globl vector223
vector223:
  pushl $0
801095aa:	6a 00                	push   $0x0
  pushl $223
801095ac:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801095b1:	e9 c0 f0 ff ff       	jmp    80108676 <alltraps>

801095b6 <vector224>:
.globl vector224
vector224:
  pushl $0
801095b6:	6a 00                	push   $0x0
  pushl $224
801095b8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801095bd:	e9 b4 f0 ff ff       	jmp    80108676 <alltraps>

801095c2 <vector225>:
.globl vector225
vector225:
  pushl $0
801095c2:	6a 00                	push   $0x0
  pushl $225
801095c4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801095c9:	e9 a8 f0 ff ff       	jmp    80108676 <alltraps>

801095ce <vector226>:
.globl vector226
vector226:
  pushl $0
801095ce:	6a 00                	push   $0x0
  pushl $226
801095d0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801095d5:	e9 9c f0 ff ff       	jmp    80108676 <alltraps>

801095da <vector227>:
.globl vector227
vector227:
  pushl $0
801095da:	6a 00                	push   $0x0
  pushl $227
801095dc:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801095e1:	e9 90 f0 ff ff       	jmp    80108676 <alltraps>

801095e6 <vector228>:
.globl vector228
vector228:
  pushl $0
801095e6:	6a 00                	push   $0x0
  pushl $228
801095e8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801095ed:	e9 84 f0 ff ff       	jmp    80108676 <alltraps>

801095f2 <vector229>:
.globl vector229
vector229:
  pushl $0
801095f2:	6a 00                	push   $0x0
  pushl $229
801095f4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801095f9:	e9 78 f0 ff ff       	jmp    80108676 <alltraps>

801095fe <vector230>:
.globl vector230
vector230:
  pushl $0
801095fe:	6a 00                	push   $0x0
  pushl $230
80109600:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80109605:	e9 6c f0 ff ff       	jmp    80108676 <alltraps>

8010960a <vector231>:
.globl vector231
vector231:
  pushl $0
8010960a:	6a 00                	push   $0x0
  pushl $231
8010960c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80109611:	e9 60 f0 ff ff       	jmp    80108676 <alltraps>

80109616 <vector232>:
.globl vector232
vector232:
  pushl $0
80109616:	6a 00                	push   $0x0
  pushl $232
80109618:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010961d:	e9 54 f0 ff ff       	jmp    80108676 <alltraps>

80109622 <vector233>:
.globl vector233
vector233:
  pushl $0
80109622:	6a 00                	push   $0x0
  pushl $233
80109624:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80109629:	e9 48 f0 ff ff       	jmp    80108676 <alltraps>

8010962e <vector234>:
.globl vector234
vector234:
  pushl $0
8010962e:	6a 00                	push   $0x0
  pushl $234
80109630:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80109635:	e9 3c f0 ff ff       	jmp    80108676 <alltraps>

8010963a <vector235>:
.globl vector235
vector235:
  pushl $0
8010963a:	6a 00                	push   $0x0
  pushl $235
8010963c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80109641:	e9 30 f0 ff ff       	jmp    80108676 <alltraps>

80109646 <vector236>:
.globl vector236
vector236:
  pushl $0
80109646:	6a 00                	push   $0x0
  pushl $236
80109648:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010964d:	e9 24 f0 ff ff       	jmp    80108676 <alltraps>

80109652 <vector237>:
.globl vector237
vector237:
  pushl $0
80109652:	6a 00                	push   $0x0
  pushl $237
80109654:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80109659:	e9 18 f0 ff ff       	jmp    80108676 <alltraps>

8010965e <vector238>:
.globl vector238
vector238:
  pushl $0
8010965e:	6a 00                	push   $0x0
  pushl $238
80109660:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80109665:	e9 0c f0 ff ff       	jmp    80108676 <alltraps>

8010966a <vector239>:
.globl vector239
vector239:
  pushl $0
8010966a:	6a 00                	push   $0x0
  pushl $239
8010966c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80109671:	e9 00 f0 ff ff       	jmp    80108676 <alltraps>

80109676 <vector240>:
.globl vector240
vector240:
  pushl $0
80109676:	6a 00                	push   $0x0
  pushl $240
80109678:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010967d:	e9 f4 ef ff ff       	jmp    80108676 <alltraps>

80109682 <vector241>:
.globl vector241
vector241:
  pushl $0
80109682:	6a 00                	push   $0x0
  pushl $241
80109684:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80109689:	e9 e8 ef ff ff       	jmp    80108676 <alltraps>

8010968e <vector242>:
.globl vector242
vector242:
  pushl $0
8010968e:	6a 00                	push   $0x0
  pushl $242
80109690:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80109695:	e9 dc ef ff ff       	jmp    80108676 <alltraps>

8010969a <vector243>:
.globl vector243
vector243:
  pushl $0
8010969a:	6a 00                	push   $0x0
  pushl $243
8010969c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801096a1:	e9 d0 ef ff ff       	jmp    80108676 <alltraps>

801096a6 <vector244>:
.globl vector244
vector244:
  pushl $0
801096a6:	6a 00                	push   $0x0
  pushl $244
801096a8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801096ad:	e9 c4 ef ff ff       	jmp    80108676 <alltraps>

801096b2 <vector245>:
.globl vector245
vector245:
  pushl $0
801096b2:	6a 00                	push   $0x0
  pushl $245
801096b4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801096b9:	e9 b8 ef ff ff       	jmp    80108676 <alltraps>

801096be <vector246>:
.globl vector246
vector246:
  pushl $0
801096be:	6a 00                	push   $0x0
  pushl $246
801096c0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801096c5:	e9 ac ef ff ff       	jmp    80108676 <alltraps>

801096ca <vector247>:
.globl vector247
vector247:
  pushl $0
801096ca:	6a 00                	push   $0x0
  pushl $247
801096cc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801096d1:	e9 a0 ef ff ff       	jmp    80108676 <alltraps>

801096d6 <vector248>:
.globl vector248
vector248:
  pushl $0
801096d6:	6a 00                	push   $0x0
  pushl $248
801096d8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801096dd:	e9 94 ef ff ff       	jmp    80108676 <alltraps>

801096e2 <vector249>:
.globl vector249
vector249:
  pushl $0
801096e2:	6a 00                	push   $0x0
  pushl $249
801096e4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801096e9:	e9 88 ef ff ff       	jmp    80108676 <alltraps>

801096ee <vector250>:
.globl vector250
vector250:
  pushl $0
801096ee:	6a 00                	push   $0x0
  pushl $250
801096f0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801096f5:	e9 7c ef ff ff       	jmp    80108676 <alltraps>

801096fa <vector251>:
.globl vector251
vector251:
  pushl $0
801096fa:	6a 00                	push   $0x0
  pushl $251
801096fc:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80109701:	e9 70 ef ff ff       	jmp    80108676 <alltraps>

80109706 <vector252>:
.globl vector252
vector252:
  pushl $0
80109706:	6a 00                	push   $0x0
  pushl $252
80109708:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010970d:	e9 64 ef ff ff       	jmp    80108676 <alltraps>

80109712 <vector253>:
.globl vector253
vector253:
  pushl $0
80109712:	6a 00                	push   $0x0
  pushl $253
80109714:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80109719:	e9 58 ef ff ff       	jmp    80108676 <alltraps>

8010971e <vector254>:
.globl vector254
vector254:
  pushl $0
8010971e:	6a 00                	push   $0x0
  pushl $254
80109720:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80109725:	e9 4c ef ff ff       	jmp    80108676 <alltraps>

8010972a <vector255>:
.globl vector255
vector255:
  pushl $0
8010972a:	6a 00                	push   $0x0
  pushl $255
8010972c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80109731:	e9 40 ef ff ff       	jmp    80108676 <alltraps>

80109736 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80109736:	55                   	push   %ebp
80109737:	89 e5                	mov    %esp,%ebp
80109739:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010973c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010973f:	83 e8 01             	sub    $0x1,%eax
80109742:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80109746:	8b 45 08             	mov    0x8(%ebp),%eax
80109749:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010974d:	8b 45 08             	mov    0x8(%ebp),%eax
80109750:	c1 e8 10             	shr    $0x10,%eax
80109753:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80109757:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010975a:	0f 01 10             	lgdtl  (%eax)
}
8010975d:	90                   	nop
8010975e:	c9                   	leave  
8010975f:	c3                   	ret    

80109760 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80109760:	55                   	push   %ebp
80109761:	89 e5                	mov    %esp,%ebp
80109763:	83 ec 04             	sub    $0x4,%esp
80109766:	8b 45 08             	mov    0x8(%ebp),%eax
80109769:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010976d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109771:	0f 00 d8             	ltr    %ax
}
80109774:	90                   	nop
80109775:	c9                   	leave  
80109776:	c3                   	ret    

80109777 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80109777:	55                   	push   %ebp
80109778:	89 e5                	mov    %esp,%ebp
8010977a:	83 ec 04             	sub    $0x4,%esp
8010977d:	8b 45 08             	mov    0x8(%ebp),%eax
80109780:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80109784:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109788:	8e e8                	mov    %eax,%gs
}
8010978a:	90                   	nop
8010978b:	c9                   	leave  
8010978c:	c3                   	ret    

8010978d <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010978d:	55                   	push   %ebp
8010978e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80109790:	8b 45 08             	mov    0x8(%ebp),%eax
80109793:	0f 22 d8             	mov    %eax,%cr3
}
80109796:	90                   	nop
80109797:	5d                   	pop    %ebp
80109798:	c3                   	ret    

80109799 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80109799:	55                   	push   %ebp
8010979a:	89 e5                	mov    %esp,%ebp
8010979c:	8b 45 08             	mov    0x8(%ebp),%eax
8010979f:	05 00 00 00 80       	add    $0x80000000,%eax
801097a4:	5d                   	pop    %ebp
801097a5:	c3                   	ret    

801097a6 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801097a6:	55                   	push   %ebp
801097a7:	89 e5                	mov    %esp,%ebp
801097a9:	8b 45 08             	mov    0x8(%ebp),%eax
801097ac:	05 00 00 00 80       	add    $0x80000000,%eax
801097b1:	5d                   	pop    %ebp
801097b2:	c3                   	ret    

801097b3 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801097b3:	55                   	push   %ebp
801097b4:	89 e5                	mov    %esp,%ebp
801097b6:	53                   	push   %ebx
801097b7:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801097ba:	e8 c2 9a ff ff       	call   80103281 <cpunum>
801097bf:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801097c5:	05 80 43 11 80       	add    $0x80114380,%eax
801097ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801097cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801097d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801097df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801097e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801097ed:	83 e2 f0             	and    $0xfffffff0,%edx
801097f0:	83 ca 0a             	or     $0xa,%edx
801097f3:	88 50 7d             	mov    %dl,0x7d(%eax)
801097f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801097fd:	83 ca 10             	or     $0x10,%edx
80109800:	88 50 7d             	mov    %dl,0x7d(%eax)
80109803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109806:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010980a:	83 e2 9f             	and    $0xffffff9f,%edx
8010980d:	88 50 7d             	mov    %dl,0x7d(%eax)
80109810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109813:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109817:	83 ca 80             	or     $0xffffff80,%edx
8010981a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010981d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109820:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109824:	83 ca 0f             	or     $0xf,%edx
80109827:	88 50 7e             	mov    %dl,0x7e(%eax)
8010982a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109831:	83 e2 ef             	and    $0xffffffef,%edx
80109834:	88 50 7e             	mov    %dl,0x7e(%eax)
80109837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010983a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010983e:	83 e2 df             	and    $0xffffffdf,%edx
80109841:	88 50 7e             	mov    %dl,0x7e(%eax)
80109844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109847:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010984b:	83 ca 40             	or     $0x40,%edx
8010984e:	88 50 7e             	mov    %dl,0x7e(%eax)
80109851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109854:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109858:	83 ca 80             	or     $0xffffff80,%edx
8010985b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010985e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109861:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80109865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109868:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010986f:	ff ff 
80109871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109874:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010987b:	00 00 
8010987d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109880:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80109887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109891:	83 e2 f0             	and    $0xfffffff0,%edx
80109894:	83 ca 02             	or     $0x2,%edx
80109897:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010989d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801098a7:	83 ca 10             	or     $0x10,%edx
801098aa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801098b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801098ba:	83 e2 9f             	and    $0xffffff9f,%edx
801098bd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801098c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801098cd:	83 ca 80             	or     $0xffffff80,%edx
801098d0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801098d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801098e0:	83 ca 0f             	or     $0xf,%edx
801098e3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801098e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ec:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801098f3:	83 e2 ef             	and    $0xffffffef,%edx
801098f6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801098fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109906:	83 e2 df             	and    $0xffffffdf,%edx
80109909:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010990f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109912:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109919:	83 ca 40             	or     $0x40,%edx
8010991c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109925:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010992c:	83 ca 80             	or     $0xffffff80,%edx
8010992f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109938:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010993f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109942:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80109949:	ff ff 
8010994b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010994e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80109955:	00 00 
80109957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010995a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80109961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109964:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010996b:	83 e2 f0             	and    $0xfffffff0,%edx
8010996e:	83 ca 0a             	or     $0xa,%edx
80109971:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109981:	83 ca 10             	or     $0x10,%edx
80109984:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010998a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109994:	83 ca 60             	or     $0x60,%edx
80109997:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010999d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801099a7:	83 ca 80             	or     $0xffffff80,%edx
801099aa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801099b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801099ba:	83 ca 0f             	or     $0xf,%edx
801099bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801099c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801099cd:	83 e2 ef             	and    $0xffffffef,%edx
801099d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801099d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801099e0:	83 e2 df             	and    $0xffffffdf,%edx
801099e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801099e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801099f3:	83 ca 40             	or     $0x40,%edx
801099f6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801099fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ff:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109a06:	83 ca 80             	or     $0xffffff80,%edx
80109a09:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a12:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80109a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1c:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80109a23:	ff ff 
80109a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a28:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80109a2f:	00 00 
80109a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a34:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80109a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a3e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109a45:	83 e2 f0             	and    $0xfffffff0,%edx
80109a48:	83 ca 02             	or     $0x2,%edx
80109a4b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a54:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109a5b:	83 ca 10             	or     $0x10,%edx
80109a5e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a67:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109a6e:	83 ca 60             	or     $0x60,%edx
80109a71:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109a81:	83 ca 80             	or     $0xffffff80,%edx
80109a84:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a8d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109a94:	83 ca 0f             	or     $0xf,%edx
80109a97:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109aa7:	83 e2 ef             	and    $0xffffffef,%edx
80109aaa:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109aba:	83 e2 df             	and    $0xffffffdf,%edx
80109abd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109acd:	83 ca 40             	or     $0x40,%edx
80109ad0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109ae0:	83 ca 80             	or     $0xffffff80,%edx
80109ae3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aec:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80109af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af6:	05 b4 00 00 00       	add    $0xb4,%eax
80109afb:	89 c3                	mov    %eax,%ebx
80109afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b00:	05 b4 00 00 00       	add    $0xb4,%eax
80109b05:	c1 e8 10             	shr    $0x10,%eax
80109b08:	89 c2                	mov    %eax,%edx
80109b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b0d:	05 b4 00 00 00       	add    $0xb4,%eax
80109b12:	c1 e8 18             	shr    $0x18,%eax
80109b15:	89 c1                	mov    %eax,%ecx
80109b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b1a:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80109b21:	00 00 
80109b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b26:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80109b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b30:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80109b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b39:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109b40:	83 e2 f0             	and    $0xfffffff0,%edx
80109b43:	83 ca 02             	or     $0x2,%edx
80109b46:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109b56:	83 ca 10             	or     $0x10,%edx
80109b59:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b62:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109b69:	83 e2 9f             	and    $0xffffff9f,%edx
80109b6c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b75:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109b7c:	83 ca 80             	or     $0xffffff80,%edx
80109b7f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b88:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109b8f:	83 e2 f0             	and    $0xfffffff0,%edx
80109b92:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b9b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109ba2:	83 e2 ef             	and    $0xffffffef,%edx
80109ba5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bae:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109bb5:	83 e2 df             	and    $0xffffffdf,%edx
80109bb8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bc1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109bc8:	83 ca 40             	or     $0x40,%edx
80109bcb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109bdb:	83 ca 80             	or     $0xffffff80,%edx
80109bde:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109be7:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80109bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf0:	83 c0 70             	add    $0x70,%eax
80109bf3:	83 ec 08             	sub    $0x8,%esp
80109bf6:	6a 38                	push   $0x38
80109bf8:	50                   	push   %eax
80109bf9:	e8 38 fb ff ff       	call   80109736 <lgdt>
80109bfe:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80109c01:	83 ec 0c             	sub    $0xc,%esp
80109c04:	6a 18                	push   $0x18
80109c06:	e8 6c fb ff ff       	call   80109777 <loadgs>
80109c0b:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80109c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c11:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80109c17:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80109c1e:	00 00 00 00 
}
80109c22:	90                   	nop
80109c23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c26:	c9                   	leave  
80109c27:	c3                   	ret    

80109c28 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80109c28:	55                   	push   %ebp
80109c29:	89 e5                	mov    %esp,%ebp
80109c2b:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80109c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c31:	c1 e8 16             	shr    $0x16,%eax
80109c34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c3e:	01 d0                	add    %edx,%eax
80109c40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80109c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c46:	8b 00                	mov    (%eax),%eax
80109c48:	83 e0 01             	and    $0x1,%eax
80109c4b:	85 c0                	test   %eax,%eax
80109c4d:	74 18                	je     80109c67 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80109c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c52:	8b 00                	mov    (%eax),%eax
80109c54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c59:	50                   	push   %eax
80109c5a:	e8 47 fb ff ff       	call   801097a6 <p2v>
80109c5f:	83 c4 04             	add    $0x4,%esp
80109c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109c65:	eb 48                	jmp    80109caf <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80109c67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80109c6b:	74 0e                	je     80109c7b <walkpgdir+0x53>
80109c6d:	e8 a9 92 ff ff       	call   80102f1b <kalloc>
80109c72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109c75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109c79:	75 07                	jne    80109c82 <walkpgdir+0x5a>
      return 0;
80109c7b:	b8 00 00 00 00       	mov    $0x0,%eax
80109c80:	eb 44                	jmp    80109cc6 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80109c82:	83 ec 04             	sub    $0x4,%esp
80109c85:	68 00 10 00 00       	push   $0x1000
80109c8a:	6a 00                	push   $0x0
80109c8c:	ff 75 f4             	pushl  -0xc(%ebp)
80109c8f:	e8 71 d2 ff ff       	call   80106f05 <memset>
80109c94:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80109c97:	83 ec 0c             	sub    $0xc,%esp
80109c9a:	ff 75 f4             	pushl  -0xc(%ebp)
80109c9d:	e8 f7 fa ff ff       	call   80109799 <v2p>
80109ca2:	83 c4 10             	add    $0x10,%esp
80109ca5:	83 c8 07             	or     $0x7,%eax
80109ca8:	89 c2                	mov    %eax,%edx
80109caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cad:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109caf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cb2:	c1 e8 0c             	shr    $0xc,%eax
80109cb5:	25 ff 03 00 00       	and    $0x3ff,%eax
80109cba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc4:	01 d0                	add    %edx,%eax
}
80109cc6:	c9                   	leave  
80109cc7:	c3                   	ret    

80109cc8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80109cc8:	55                   	push   %ebp
80109cc9:	89 e5                	mov    %esp,%ebp
80109ccb:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109cce:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80109cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
80109cdc:	8b 45 10             	mov    0x10(%ebp),%eax
80109cdf:	01 d0                	add    %edx,%eax
80109ce1:	83 e8 01             	sub    $0x1,%eax
80109ce4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ce9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80109cec:	83 ec 04             	sub    $0x4,%esp
80109cef:	6a 01                	push   $0x1
80109cf1:	ff 75 f4             	pushl  -0xc(%ebp)
80109cf4:	ff 75 08             	pushl  0x8(%ebp)
80109cf7:	e8 2c ff ff ff       	call   80109c28 <walkpgdir>
80109cfc:	83 c4 10             	add    $0x10,%esp
80109cff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109d02:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d06:	75 07                	jne    80109d0f <mappages+0x47>
      return -1;
80109d08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109d0d:	eb 47                	jmp    80109d56 <mappages+0x8e>
    if(*pte & PTE_P)
80109d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d12:	8b 00                	mov    (%eax),%eax
80109d14:	83 e0 01             	and    $0x1,%eax
80109d17:	85 c0                	test   %eax,%eax
80109d19:	74 0d                	je     80109d28 <mappages+0x60>
      panic("remap");
80109d1b:	83 ec 0c             	sub    $0xc,%esp
80109d1e:	68 7c ae 10 80       	push   $0x8010ae7c
80109d23:	e8 3e 68 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80109d28:	8b 45 18             	mov    0x18(%ebp),%eax
80109d2b:	0b 45 14             	or     0x14(%ebp),%eax
80109d2e:	83 c8 01             	or     $0x1,%eax
80109d31:	89 c2                	mov    %eax,%edx
80109d33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d36:	89 10                	mov    %edx,(%eax)
    if(a == last)
80109d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d3b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109d3e:	74 10                	je     80109d50 <mappages+0x88>
      break;
    a += PGSIZE;
80109d40:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80109d47:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80109d4e:	eb 9c                	jmp    80109cec <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80109d50:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80109d51:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109d56:	c9                   	leave  
80109d57:	c3                   	ret    

80109d58 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80109d58:	55                   	push   %ebp
80109d59:	89 e5                	mov    %esp,%ebp
80109d5b:	53                   	push   %ebx
80109d5c:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80109d5f:	e8 b7 91 ff ff       	call   80102f1b <kalloc>
80109d64:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109d67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109d6b:	75 0a                	jne    80109d77 <setupkvm+0x1f>
    return 0;
80109d6d:	b8 00 00 00 00       	mov    $0x0,%eax
80109d72:	e9 8e 00 00 00       	jmp    80109e05 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80109d77:	83 ec 04             	sub    $0x4,%esp
80109d7a:	68 00 10 00 00       	push   $0x1000
80109d7f:	6a 00                	push   $0x0
80109d81:	ff 75 f0             	pushl  -0x10(%ebp)
80109d84:	e8 7c d1 ff ff       	call   80106f05 <memset>
80109d89:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80109d8c:	83 ec 0c             	sub    $0xc,%esp
80109d8f:	68 00 00 00 0e       	push   $0xe000000
80109d94:	e8 0d fa ff ff       	call   801097a6 <p2v>
80109d99:	83 c4 10             	add    $0x10,%esp
80109d9c:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109da1:	76 0d                	jbe    80109db0 <setupkvm+0x58>
    panic("PHYSTOP too high");
80109da3:	83 ec 0c             	sub    $0xc,%esp
80109da6:	68 82 ae 10 80       	push   $0x8010ae82
80109dab:	e8 b6 67 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109db0:	c7 45 f4 c0 d4 10 80 	movl   $0x8010d4c0,-0xc(%ebp)
80109db7:	eb 40                	jmp    80109df9 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dbc:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc2:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc8:	8b 58 08             	mov    0x8(%eax),%ebx
80109dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dce:	8b 40 04             	mov    0x4(%eax),%eax
80109dd1:	29 c3                	sub    %eax,%ebx
80109dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dd6:	8b 00                	mov    (%eax),%eax
80109dd8:	83 ec 0c             	sub    $0xc,%esp
80109ddb:	51                   	push   %ecx
80109ddc:	52                   	push   %edx
80109ddd:	53                   	push   %ebx
80109dde:	50                   	push   %eax
80109ddf:	ff 75 f0             	pushl  -0x10(%ebp)
80109de2:	e8 e1 fe ff ff       	call   80109cc8 <mappages>
80109de7:	83 c4 20             	add    $0x20,%esp
80109dea:	85 c0                	test   %eax,%eax
80109dec:	79 07                	jns    80109df5 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80109dee:	b8 00 00 00 00       	mov    $0x0,%eax
80109df3:	eb 10                	jmp    80109e05 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109df5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80109df9:	81 7d f4 00 d5 10 80 	cmpl   $0x8010d500,-0xc(%ebp)
80109e00:	72 b7                	jb     80109db9 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80109e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e08:	c9                   	leave  
80109e09:	c3                   	ret    

80109e0a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80109e0a:	55                   	push   %ebp
80109e0b:	89 e5                	mov    %esp,%ebp
80109e0d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80109e10:	e8 43 ff ff ff       	call   80109d58 <setupkvm>
80109e15:	a3 38 79 11 80       	mov    %eax,0x80117938
  switchkvm();
80109e1a:	e8 03 00 00 00       	call   80109e22 <switchkvm>
}
80109e1f:	90                   	nop
80109e20:	c9                   	leave  
80109e21:	c3                   	ret    

80109e22 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80109e22:	55                   	push   %ebp
80109e23:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80109e25:	a1 38 79 11 80       	mov    0x80117938,%eax
80109e2a:	50                   	push   %eax
80109e2b:	e8 69 f9 ff ff       	call   80109799 <v2p>
80109e30:	83 c4 04             	add    $0x4,%esp
80109e33:	50                   	push   %eax
80109e34:	e8 54 f9 ff ff       	call   8010978d <lcr3>
80109e39:	83 c4 04             	add    $0x4,%esp
}
80109e3c:	90                   	nop
80109e3d:	c9                   	leave  
80109e3e:	c3                   	ret    

80109e3f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80109e3f:	55                   	push   %ebp
80109e40:	89 e5                	mov    %esp,%ebp
80109e42:	56                   	push   %esi
80109e43:	53                   	push   %ebx
  pushcli();
80109e44:	e8 b6 cf ff ff       	call   80106dff <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80109e49:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109e4f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109e56:	83 c2 08             	add    $0x8,%edx
80109e59:	89 d6                	mov    %edx,%esi
80109e5b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109e62:	83 c2 08             	add    $0x8,%edx
80109e65:	c1 ea 10             	shr    $0x10,%edx
80109e68:	89 d3                	mov    %edx,%ebx
80109e6a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109e71:	83 c2 08             	add    $0x8,%edx
80109e74:	c1 ea 18             	shr    $0x18,%edx
80109e77:	89 d1                	mov    %edx,%ecx
80109e79:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109e80:	67 00 
80109e82:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80109e89:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109e8f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109e96:	83 e2 f0             	and    $0xfffffff0,%edx
80109e99:	83 ca 09             	or     $0x9,%edx
80109e9c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109ea2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109ea9:	83 ca 10             	or     $0x10,%edx
80109eac:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109eb2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109eb9:	83 e2 9f             	and    $0xffffff9f,%edx
80109ebc:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109ec2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109ec9:	83 ca 80             	or     $0xffffff80,%edx
80109ecc:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109ed2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109ed9:	83 e2 f0             	and    $0xfffffff0,%edx
80109edc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109ee2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109ee9:	83 e2 ef             	and    $0xffffffef,%edx
80109eec:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109ef2:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109ef9:	83 e2 df             	and    $0xffffffdf,%edx
80109efc:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109f02:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109f09:	83 ca 40             	or     $0x40,%edx
80109f0c:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109f12:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109f19:	83 e2 7f             	and    $0x7f,%edx
80109f1c:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109f22:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80109f28:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109f2e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109f35:	83 e2 ef             	and    $0xffffffef,%edx
80109f38:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109f3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109f44:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80109f4a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109f50:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109f57:	8b 52 08             	mov    0x8(%edx),%edx
80109f5a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109f60:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109f63:	83 ec 0c             	sub    $0xc,%esp
80109f66:	6a 30                	push   $0x30
80109f68:	e8 f3 f7 ff ff       	call   80109760 <ltr>
80109f6d:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109f70:	8b 45 08             	mov    0x8(%ebp),%eax
80109f73:	8b 40 04             	mov    0x4(%eax),%eax
80109f76:	85 c0                	test   %eax,%eax
80109f78:	75 0d                	jne    80109f87 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80109f7a:	83 ec 0c             	sub    $0xc,%esp
80109f7d:	68 93 ae 10 80       	push   $0x8010ae93
80109f82:	e8 df 65 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80109f87:	8b 45 08             	mov    0x8(%ebp),%eax
80109f8a:	8b 40 04             	mov    0x4(%eax),%eax
80109f8d:	83 ec 0c             	sub    $0xc,%esp
80109f90:	50                   	push   %eax
80109f91:	e8 03 f8 ff ff       	call   80109799 <v2p>
80109f96:	83 c4 10             	add    $0x10,%esp
80109f99:	83 ec 0c             	sub    $0xc,%esp
80109f9c:	50                   	push   %eax
80109f9d:	e8 eb f7 ff ff       	call   8010978d <lcr3>
80109fa2:	83 c4 10             	add    $0x10,%esp
  popcli();
80109fa5:	e8 9a ce ff ff       	call   80106e44 <popcli>
}
80109faa:	90                   	nop
80109fab:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109fae:	5b                   	pop    %ebx
80109faf:	5e                   	pop    %esi
80109fb0:	5d                   	pop    %ebp
80109fb1:	c3                   	ret    

80109fb2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109fb2:	55                   	push   %ebp
80109fb3:	89 e5                	mov    %esp,%ebp
80109fb5:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80109fb8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109fbf:	76 0d                	jbe    80109fce <inituvm+0x1c>
    panic("inituvm: more than a page");
80109fc1:	83 ec 0c             	sub    $0xc,%esp
80109fc4:	68 a7 ae 10 80       	push   $0x8010aea7
80109fc9:	e8 98 65 ff ff       	call   80100566 <panic>
  mem = kalloc();
80109fce:	e8 48 8f ff ff       	call   80102f1b <kalloc>
80109fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80109fd6:	83 ec 04             	sub    $0x4,%esp
80109fd9:	68 00 10 00 00       	push   $0x1000
80109fde:	6a 00                	push   $0x0
80109fe0:	ff 75 f4             	pushl  -0xc(%ebp)
80109fe3:	e8 1d cf ff ff       	call   80106f05 <memset>
80109fe8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109feb:	83 ec 0c             	sub    $0xc,%esp
80109fee:	ff 75 f4             	pushl  -0xc(%ebp)
80109ff1:	e8 a3 f7 ff ff       	call   80109799 <v2p>
80109ff6:	83 c4 10             	add    $0x10,%esp
80109ff9:	83 ec 0c             	sub    $0xc,%esp
80109ffc:	6a 06                	push   $0x6
80109ffe:	50                   	push   %eax
80109fff:	68 00 10 00 00       	push   $0x1000
8010a004:	6a 00                	push   $0x0
8010a006:	ff 75 08             	pushl  0x8(%ebp)
8010a009:	e8 ba fc ff ff       	call   80109cc8 <mappages>
8010a00e:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010a011:	83 ec 04             	sub    $0x4,%esp
8010a014:	ff 75 10             	pushl  0x10(%ebp)
8010a017:	ff 75 0c             	pushl  0xc(%ebp)
8010a01a:	ff 75 f4             	pushl  -0xc(%ebp)
8010a01d:	e8 a2 cf ff ff       	call   80106fc4 <memmove>
8010a022:	83 c4 10             	add    $0x10,%esp
}
8010a025:	90                   	nop
8010a026:	c9                   	leave  
8010a027:	c3                   	ret    

8010a028 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010a028:	55                   	push   %ebp
8010a029:	89 e5                	mov    %esp,%ebp
8010a02b:	53                   	push   %ebx
8010a02c:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010a02f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a032:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a037:	85 c0                	test   %eax,%eax
8010a039:	74 0d                	je     8010a048 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010a03b:	83 ec 0c             	sub    $0xc,%esp
8010a03e:	68 c4 ae 10 80       	push   $0x8010aec4
8010a043:	e8 1e 65 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010a048:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a04f:	e9 95 00 00 00       	jmp    8010a0e9 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010a054:	8b 55 0c             	mov    0xc(%ebp),%edx
8010a057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a05a:	01 d0                	add    %edx,%eax
8010a05c:	83 ec 04             	sub    $0x4,%esp
8010a05f:	6a 00                	push   $0x0
8010a061:	50                   	push   %eax
8010a062:	ff 75 08             	pushl  0x8(%ebp)
8010a065:	e8 be fb ff ff       	call   80109c28 <walkpgdir>
8010a06a:	83 c4 10             	add    $0x10,%esp
8010a06d:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a070:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a074:	75 0d                	jne    8010a083 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010a076:	83 ec 0c             	sub    $0xc,%esp
8010a079:	68 e7 ae 10 80       	push   $0x8010aee7
8010a07e:	e8 e3 64 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010a083:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a086:	8b 00                	mov    (%eax),%eax
8010a088:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a08d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010a090:	8b 45 18             	mov    0x18(%ebp),%eax
8010a093:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010a096:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010a09b:	77 0b                	ja     8010a0a8 <loaduvm+0x80>
      n = sz - i;
8010a09d:	8b 45 18             	mov    0x18(%ebp),%eax
8010a0a0:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010a0a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010a0a6:	eb 07                	jmp    8010a0af <loaduvm+0x87>
    else
      n = PGSIZE;
8010a0a8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010a0af:	8b 55 14             	mov    0x14(%ebp),%edx
8010a0b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0b5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010a0b8:	83 ec 0c             	sub    $0xc,%esp
8010a0bb:	ff 75 e8             	pushl  -0x18(%ebp)
8010a0be:	e8 e3 f6 ff ff       	call   801097a6 <p2v>
8010a0c3:	83 c4 10             	add    $0x10,%esp
8010a0c6:	ff 75 f0             	pushl  -0x10(%ebp)
8010a0c9:	53                   	push   %ebx
8010a0ca:	50                   	push   %eax
8010a0cb:	ff 75 10             	pushl  0x10(%ebp)
8010a0ce:	e8 43 7f ff ff       	call   80102016 <readi>
8010a0d3:	83 c4 10             	add    $0x10,%esp
8010a0d6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010a0d9:	74 07                	je     8010a0e2 <loaduvm+0xba>
      return -1;
8010a0db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a0e0:	eb 18                	jmp    8010a0fa <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010a0e2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a0e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0ec:	3b 45 18             	cmp    0x18(%ebp),%eax
8010a0ef:	0f 82 5f ff ff ff    	jb     8010a054 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010a0f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a0fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a0fd:	c9                   	leave  
8010a0fe:	c3                   	ret    

8010a0ff <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010a0ff:	55                   	push   %ebp
8010a100:	89 e5                	mov    %esp,%ebp
8010a102:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010a105:	8b 45 10             	mov    0x10(%ebp),%eax
8010a108:	85 c0                	test   %eax,%eax
8010a10a:	79 0a                	jns    8010a116 <allocuvm+0x17>
    return 0;
8010a10c:	b8 00 00 00 00       	mov    $0x0,%eax
8010a111:	e9 b0 00 00 00       	jmp    8010a1c6 <allocuvm+0xc7>
  if(newsz < oldsz)
8010a116:	8b 45 10             	mov    0x10(%ebp),%eax
8010a119:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a11c:	73 08                	jae    8010a126 <allocuvm+0x27>
    return oldsz;
8010a11e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a121:	e9 a0 00 00 00       	jmp    8010a1c6 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010a126:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a129:	05 ff 0f 00 00       	add    $0xfff,%eax
8010a12e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a133:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010a136:	eb 7f                	jmp    8010a1b7 <allocuvm+0xb8>
    mem = kalloc();
8010a138:	e8 de 8d ff ff       	call   80102f1b <kalloc>
8010a13d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010a140:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a144:	75 2b                	jne    8010a171 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
8010a146:	83 ec 0c             	sub    $0xc,%esp
8010a149:	68 05 af 10 80       	push   $0x8010af05
8010a14e:	e8 73 62 ff ff       	call   801003c6 <cprintf>
8010a153:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010a156:	83 ec 04             	sub    $0x4,%esp
8010a159:	ff 75 0c             	pushl  0xc(%ebp)
8010a15c:	ff 75 10             	pushl  0x10(%ebp)
8010a15f:	ff 75 08             	pushl  0x8(%ebp)
8010a162:	e8 61 00 00 00       	call   8010a1c8 <deallocuvm>
8010a167:	83 c4 10             	add    $0x10,%esp
      return 0;
8010a16a:	b8 00 00 00 00       	mov    $0x0,%eax
8010a16f:	eb 55                	jmp    8010a1c6 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
8010a171:	83 ec 04             	sub    $0x4,%esp
8010a174:	68 00 10 00 00       	push   $0x1000
8010a179:	6a 00                	push   $0x0
8010a17b:	ff 75 f0             	pushl  -0x10(%ebp)
8010a17e:	e8 82 cd ff ff       	call   80106f05 <memset>
8010a183:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010a186:	83 ec 0c             	sub    $0xc,%esp
8010a189:	ff 75 f0             	pushl  -0x10(%ebp)
8010a18c:	e8 08 f6 ff ff       	call   80109799 <v2p>
8010a191:	83 c4 10             	add    $0x10,%esp
8010a194:	89 c2                	mov    %eax,%edx
8010a196:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a199:	83 ec 0c             	sub    $0xc,%esp
8010a19c:	6a 06                	push   $0x6
8010a19e:	52                   	push   %edx
8010a19f:	68 00 10 00 00       	push   $0x1000
8010a1a4:	50                   	push   %eax
8010a1a5:	ff 75 08             	pushl  0x8(%ebp)
8010a1a8:	e8 1b fb ff ff       	call   80109cc8 <mappages>
8010a1ad:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010a1b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a1b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1ba:	3b 45 10             	cmp    0x10(%ebp),%eax
8010a1bd:	0f 82 75 ff ff ff    	jb     8010a138 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010a1c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010a1c6:	c9                   	leave  
8010a1c7:	c3                   	ret    

8010a1c8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010a1c8:	55                   	push   %ebp
8010a1c9:	89 e5                	mov    %esp,%ebp
8010a1cb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010a1ce:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a1d4:	72 08                	jb     8010a1de <deallocuvm+0x16>
    return oldsz;
8010a1d6:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1d9:	e9 a5 00 00 00       	jmp    8010a283 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
8010a1de:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1e1:	05 ff 0f 00 00       	add    $0xfff,%eax
8010a1e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a1eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010a1ee:	e9 81 00 00 00       	jmp    8010a274 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010a1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1f6:	83 ec 04             	sub    $0x4,%esp
8010a1f9:	6a 00                	push   $0x0
8010a1fb:	50                   	push   %eax
8010a1fc:	ff 75 08             	pushl  0x8(%ebp)
8010a1ff:	e8 24 fa ff ff       	call   80109c28 <walkpgdir>
8010a204:	83 c4 10             	add    $0x10,%esp
8010a207:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010a20a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a20e:	75 09                	jne    8010a219 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010a210:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010a217:	eb 54                	jmp    8010a26d <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010a219:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a21c:	8b 00                	mov    (%eax),%eax
8010a21e:	83 e0 01             	and    $0x1,%eax
8010a221:	85 c0                	test   %eax,%eax
8010a223:	74 48                	je     8010a26d <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010a225:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a228:	8b 00                	mov    (%eax),%eax
8010a22a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a22f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010a232:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a236:	75 0d                	jne    8010a245 <deallocuvm+0x7d>
        panic("kfree");
8010a238:	83 ec 0c             	sub    $0xc,%esp
8010a23b:	68 1d af 10 80       	push   $0x8010af1d
8010a240:	e8 21 63 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010a245:	83 ec 0c             	sub    $0xc,%esp
8010a248:	ff 75 ec             	pushl  -0x14(%ebp)
8010a24b:	e8 56 f5 ff ff       	call   801097a6 <p2v>
8010a250:	83 c4 10             	add    $0x10,%esp
8010a253:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010a256:	83 ec 0c             	sub    $0xc,%esp
8010a259:	ff 75 e8             	pushl  -0x18(%ebp)
8010a25c:	e8 1d 8c ff ff       	call   80102e7e <kfree>
8010a261:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010a264:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a267:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010a26d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a274:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a277:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a27a:	0f 82 73 ff ff ff    	jb     8010a1f3 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010a280:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010a283:	c9                   	leave  
8010a284:	c3                   	ret    

8010a285 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010a285:	55                   	push   %ebp
8010a286:	89 e5                	mov    %esp,%ebp
8010a288:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010a28b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010a28f:	75 0d                	jne    8010a29e <freevm+0x19>
    panic("freevm: no pgdir");
8010a291:	83 ec 0c             	sub    $0xc,%esp
8010a294:	68 23 af 10 80       	push   $0x8010af23
8010a299:	e8 c8 62 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010a29e:	83 ec 04             	sub    $0x4,%esp
8010a2a1:	6a 00                	push   $0x0
8010a2a3:	68 00 00 00 80       	push   $0x80000000
8010a2a8:	ff 75 08             	pushl  0x8(%ebp)
8010a2ab:	e8 18 ff ff ff       	call   8010a1c8 <deallocuvm>
8010a2b0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010a2b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a2ba:	eb 4f                	jmp    8010a30b <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010a2bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a2c6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c9:	01 d0                	add    %edx,%eax
8010a2cb:	8b 00                	mov    (%eax),%eax
8010a2cd:	83 e0 01             	and    $0x1,%eax
8010a2d0:	85 c0                	test   %eax,%eax
8010a2d2:	74 33                	je     8010a307 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010a2d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2d7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a2de:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e1:	01 d0                	add    %edx,%eax
8010a2e3:	8b 00                	mov    (%eax),%eax
8010a2e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a2ea:	83 ec 0c             	sub    $0xc,%esp
8010a2ed:	50                   	push   %eax
8010a2ee:	e8 b3 f4 ff ff       	call   801097a6 <p2v>
8010a2f3:	83 c4 10             	add    $0x10,%esp
8010a2f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010a2f9:	83 ec 0c             	sub    $0xc,%esp
8010a2fc:	ff 75 f0             	pushl  -0x10(%ebp)
8010a2ff:	e8 7a 8b ff ff       	call   80102e7e <kfree>
8010a304:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010a307:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a30b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010a312:	76 a8                	jbe    8010a2bc <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010a314:	83 ec 0c             	sub    $0xc,%esp
8010a317:	ff 75 08             	pushl  0x8(%ebp)
8010a31a:	e8 5f 8b ff ff       	call   80102e7e <kfree>
8010a31f:	83 c4 10             	add    $0x10,%esp
}
8010a322:	90                   	nop
8010a323:	c9                   	leave  
8010a324:	c3                   	ret    

8010a325 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010a325:	55                   	push   %ebp
8010a326:	89 e5                	mov    %esp,%ebp
8010a328:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a32b:	83 ec 04             	sub    $0x4,%esp
8010a32e:	6a 00                	push   $0x0
8010a330:	ff 75 0c             	pushl  0xc(%ebp)
8010a333:	ff 75 08             	pushl  0x8(%ebp)
8010a336:	e8 ed f8 ff ff       	call   80109c28 <walkpgdir>
8010a33b:	83 c4 10             	add    $0x10,%esp
8010a33e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010a341:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010a345:	75 0d                	jne    8010a354 <clearpteu+0x2f>
    panic("clearpteu");
8010a347:	83 ec 0c             	sub    $0xc,%esp
8010a34a:	68 34 af 10 80       	push   $0x8010af34
8010a34f:	e8 12 62 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010a354:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a357:	8b 00                	mov    (%eax),%eax
8010a359:	83 e0 fb             	and    $0xfffffffb,%eax
8010a35c:	89 c2                	mov    %eax,%edx
8010a35e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a361:	89 10                	mov    %edx,(%eax)
}
8010a363:	90                   	nop
8010a364:	c9                   	leave  
8010a365:	c3                   	ret    

8010a366 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010a366:	55                   	push   %ebp
8010a367:	89 e5                	mov    %esp,%ebp
8010a369:	53                   	push   %ebx
8010a36a:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010a36d:	e8 e6 f9 ff ff       	call   80109d58 <setupkvm>
8010a372:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010a375:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a379:	75 0a                	jne    8010a385 <copyuvm+0x1f>
    return 0;
8010a37b:	b8 00 00 00 00       	mov    $0x0,%eax
8010a380:	e9 f8 00 00 00       	jmp    8010a47d <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010a385:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a38c:	e9 c4 00 00 00       	jmp    8010a455 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010a391:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a394:	83 ec 04             	sub    $0x4,%esp
8010a397:	6a 00                	push   $0x0
8010a399:	50                   	push   %eax
8010a39a:	ff 75 08             	pushl  0x8(%ebp)
8010a39d:	e8 86 f8 ff ff       	call   80109c28 <walkpgdir>
8010a3a2:	83 c4 10             	add    $0x10,%esp
8010a3a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a3a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a3ac:	75 0d                	jne    8010a3bb <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010a3ae:	83 ec 0c             	sub    $0xc,%esp
8010a3b1:	68 3e af 10 80       	push   $0x8010af3e
8010a3b6:	e8 ab 61 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010a3bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3be:	8b 00                	mov    (%eax),%eax
8010a3c0:	83 e0 01             	and    $0x1,%eax
8010a3c3:	85 c0                	test   %eax,%eax
8010a3c5:	75 0d                	jne    8010a3d4 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010a3c7:	83 ec 0c             	sub    $0xc,%esp
8010a3ca:	68 58 af 10 80       	push   $0x8010af58
8010a3cf:	e8 92 61 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010a3d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3d7:	8b 00                	mov    (%eax),%eax
8010a3d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a3de:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010a3e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3e4:	8b 00                	mov    (%eax),%eax
8010a3e6:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a3eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010a3ee:	e8 28 8b ff ff       	call   80102f1b <kalloc>
8010a3f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010a3f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010a3fa:	74 6a                	je     8010a466 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010a3fc:	83 ec 0c             	sub    $0xc,%esp
8010a3ff:	ff 75 e8             	pushl  -0x18(%ebp)
8010a402:	e8 9f f3 ff ff       	call   801097a6 <p2v>
8010a407:	83 c4 10             	add    $0x10,%esp
8010a40a:	83 ec 04             	sub    $0x4,%esp
8010a40d:	68 00 10 00 00       	push   $0x1000
8010a412:	50                   	push   %eax
8010a413:	ff 75 e0             	pushl  -0x20(%ebp)
8010a416:	e8 a9 cb ff ff       	call   80106fc4 <memmove>
8010a41b:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010a41e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010a421:	83 ec 0c             	sub    $0xc,%esp
8010a424:	ff 75 e0             	pushl  -0x20(%ebp)
8010a427:	e8 6d f3 ff ff       	call   80109799 <v2p>
8010a42c:	83 c4 10             	add    $0x10,%esp
8010a42f:	89 c2                	mov    %eax,%edx
8010a431:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a434:	83 ec 0c             	sub    $0xc,%esp
8010a437:	53                   	push   %ebx
8010a438:	52                   	push   %edx
8010a439:	68 00 10 00 00       	push   $0x1000
8010a43e:	50                   	push   %eax
8010a43f:	ff 75 f0             	pushl  -0x10(%ebp)
8010a442:	e8 81 f8 ff ff       	call   80109cc8 <mappages>
8010a447:	83 c4 20             	add    $0x20,%esp
8010a44a:	85 c0                	test   %eax,%eax
8010a44c:	78 1b                	js     8010a469 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010a44e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a455:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a458:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a45b:	0f 82 30 ff ff ff    	jb     8010a391 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010a461:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a464:	eb 17                	jmp    8010a47d <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010a466:	90                   	nop
8010a467:	eb 01                	jmp    8010a46a <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010a469:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010a46a:	83 ec 0c             	sub    $0xc,%esp
8010a46d:	ff 75 f0             	pushl  -0x10(%ebp)
8010a470:	e8 10 fe ff ff       	call   8010a285 <freevm>
8010a475:	83 c4 10             	add    $0x10,%esp
  return 0;
8010a478:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a47d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a480:	c9                   	leave  
8010a481:	c3                   	ret    

8010a482 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010a482:	55                   	push   %ebp
8010a483:	89 e5                	mov    %esp,%ebp
8010a485:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a488:	83 ec 04             	sub    $0x4,%esp
8010a48b:	6a 00                	push   $0x0
8010a48d:	ff 75 0c             	pushl  0xc(%ebp)
8010a490:	ff 75 08             	pushl  0x8(%ebp)
8010a493:	e8 90 f7 ff ff       	call   80109c28 <walkpgdir>
8010a498:	83 c4 10             	add    $0x10,%esp
8010a49b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a49e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4a1:	8b 00                	mov    (%eax),%eax
8010a4a3:	83 e0 01             	and    $0x1,%eax
8010a4a6:	85 c0                	test   %eax,%eax
8010a4a8:	75 07                	jne    8010a4b1 <uva2ka+0x2f>
    return 0;
8010a4aa:	b8 00 00 00 00       	mov    $0x0,%eax
8010a4af:	eb 29                	jmp    8010a4da <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a4b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4b4:	8b 00                	mov    (%eax),%eax
8010a4b6:	83 e0 04             	and    $0x4,%eax
8010a4b9:	85 c0                	test   %eax,%eax
8010a4bb:	75 07                	jne    8010a4c4 <uva2ka+0x42>
    return 0;
8010a4bd:	b8 00 00 00 00       	mov    $0x0,%eax
8010a4c2:	eb 16                	jmp    8010a4da <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a4c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4c7:	8b 00                	mov    (%eax),%eax
8010a4c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a4ce:	83 ec 0c             	sub    $0xc,%esp
8010a4d1:	50                   	push   %eax
8010a4d2:	e8 cf f2 ff ff       	call   801097a6 <p2v>
8010a4d7:	83 c4 10             	add    $0x10,%esp
}
8010a4da:	c9                   	leave  
8010a4db:	c3                   	ret    

8010a4dc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a4dc:	55                   	push   %ebp
8010a4dd:	89 e5                	mov    %esp,%ebp
8010a4df:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a4e2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a4e8:	eb 7f                	jmp    8010a569 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a4ea:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a4f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a4f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4f8:	83 ec 08             	sub    $0x8,%esp
8010a4fb:	50                   	push   %eax
8010a4fc:	ff 75 08             	pushl  0x8(%ebp)
8010a4ff:	e8 7e ff ff ff       	call   8010a482 <uva2ka>
8010a504:	83 c4 10             	add    $0x10,%esp
8010a507:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a50a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a50e:	75 07                	jne    8010a517 <copyout+0x3b>
      return -1;
8010a510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a515:	eb 61                	jmp    8010a578 <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a51a:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a51d:	05 00 10 00 00       	add    $0x1000,%eax
8010a522:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a525:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a528:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a52b:	76 06                	jbe    8010a533 <copyout+0x57>
      n = len;
8010a52d:	8b 45 14             	mov    0x14(%ebp),%eax
8010a530:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a533:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a536:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a539:	89 c2                	mov    %eax,%edx
8010a53b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a53e:	01 d0                	add    %edx,%eax
8010a540:	83 ec 04             	sub    $0x4,%esp
8010a543:	ff 75 f0             	pushl  -0x10(%ebp)
8010a546:	ff 75 f4             	pushl  -0xc(%ebp)
8010a549:	50                   	push   %eax
8010a54a:	e8 75 ca ff ff       	call   80106fc4 <memmove>
8010a54f:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a552:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a555:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a558:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a55b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a55e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a561:	05 00 10 00 00       	add    $0x1000,%eax
8010a566:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a569:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a56d:	0f 85 77 ff ff ff    	jne    8010a4ea <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a573:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a578:	c9                   	leave  
8010a579:	c3                   	ret    
