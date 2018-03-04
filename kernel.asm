
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
80100015:	b8 00 d0 10 00       	mov    $0x10d000,%eax
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
80100028:	bc 70 f6 10 80       	mov    $0x8010f670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f0 3b 10 80       	mov    $0x80103bf0,%eax
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
8010003d:	68 28 a6 10 80       	push   $0x8010a628
80100042:	68 80 f6 10 80       	push   $0x8010f680
80100047:	e8 e0 6c 00 00       	call   80106d2c <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 35 11 80 84 	movl   $0x80113584,0x80113590
80100056:	35 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 35 11 80 84 	movl   $0x80113584,0x80113594
80100060:	35 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 f6 10 80 	movl   $0x8010f6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 35 11 80    	mov    0x80113594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 35 11 80 	movl   $0x80113584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 35 11 80       	mov    0x80113594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 35 11 80       	mov    %eax,0x80113594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 35 11 80       	mov    $0x80113584,%eax
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
801000bc:	68 80 f6 10 80       	push   $0x8010f680
801000c1:	e8 88 6c 00 00       	call   80106d4e <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 35 11 80       	mov    0x80113594,%eax
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
80100107:	68 80 f6 10 80       	push   $0x8010f680
8010010c:	e8 a4 6c 00 00       	call   80106db5 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 f6 10 80       	push   $0x8010f680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 0d 59 00 00       	call   80105a39 <sleep>
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
8010013a:	81 7d f4 84 35 11 80 	cmpl   $0x80113584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 35 11 80       	mov    0x80113590,%eax
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
80100183:	68 80 f6 10 80       	push   $0x8010f680
80100188:	e8 28 6c 00 00       	call   80106db5 <release>
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
8010019e:	81 7d f4 84 35 11 80 	cmpl   $0x80113584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 2f a6 10 80       	push   $0x8010a62f
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
801001e2:	e8 87 2a 00 00       	call   80102c6e <iderw>
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
80100204:	68 40 a6 10 80       	push   $0x8010a640
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
80100223:	e8 46 2a 00 00       	call   80102c6e <iderw>
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
80100243:	68 47 a6 10 80       	push   $0x8010a647
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 f6 10 80       	push   $0x8010f680
80100255:	e8 f4 6a 00 00       	call   80106d4e <acquire>
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
8010027b:	8b 15 94 35 11 80    	mov    0x80113594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 35 11 80 	movl   $0x80113584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 35 11 80       	mov    0x80113594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 35 11 80       	mov    %eax,0x80113594

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
801002b9:	e8 8b 59 00 00       	call   80105c49 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 f6 10 80       	push   $0x8010f680
801002c9:	e8 e7 6a 00 00       	call   80106db5 <release>
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
80100365:	0f b6 80 04 c0 10 80 	movzbl -0x7fef3ffc(%eax),%eax
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
801003cc:	a1 14 e6 10 80       	mov    0x8010e614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 e5 10 80       	push   $0x8010e5e0
801003e2:	e8 67 69 00 00       	call   80106d4e <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 4e a6 10 80       	push   $0x8010a64e
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
801004cd:	c7 45 ec 57 a6 10 80 	movl   $0x8010a657,-0x14(%ebp)
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
80100556:	68 e0 e5 10 80       	push   $0x8010e5e0
8010055b:	e8 55 68 00 00       	call   80106db5 <release>
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
80100571:	c7 05 14 e6 10 80 00 	movl   $0x0,0x8010e614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 5e a6 10 80       	push   $0x8010a65e
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
801005aa:	68 6d a6 10 80       	push   $0x8010a66d
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 40 68 00 00       	call   80106e07 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 6f a6 10 80       	push   $0x8010a66f
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
801005f5:	c7 05 c0 e5 10 80 01 	movl   $0x1,0x8010e5c0
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
80100699:	8b 0d 00 c0 10 80    	mov    0x8010c000,%ecx
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
801006ca:	68 73 a6 10 80       	push   $0x8010a673
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 74 69 00 00       	call   80107070 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 8b 68 00 00       	call   80106fb1 <memset>
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
8010077e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
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
80100798:	a1 c0 e5 10 80       	mov    0x8010e5c0,%eax
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
801007b6:	e8 f4 84 00 00       	call   80108caf <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 e7 84 00 00       	call   80108caf <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 da 84 00 00       	call   80108caf <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 ca 84 00 00       	call   80108caf <uartputc>
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
80100825:	68 e0 e5 10 80       	push   $0x8010e5e0
8010082a:	e8 1f 65 00 00       	call   80106d4e <acquire>
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
8010089b:	a1 28 38 11 80       	mov    0x80113828,%eax
801008a0:	83 e8 01             	sub    $0x1,%eax
801008a3:	a3 28 38 11 80       	mov    %eax,0x80113828
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
801008b8:	8b 15 28 38 11 80    	mov    0x80113828,%edx
801008be:	a1 24 38 11 80       	mov    0x80113824,%eax
801008c3:	39 c2                	cmp    %eax,%edx
801008c5:	0f 84 12 01 00 00    	je     801009dd <consoleintr+0x1e4>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008cb:	a1 28 38 11 80       	mov    0x80113828,%eax
801008d0:	83 e8 01             	sub    $0x1,%eax
801008d3:	83 e0 7f             	and    $0x7f,%eax
801008d6:	0f b6 80 a0 37 11 80 	movzbl -0x7feec860(%eax),%eax
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
801008e6:	8b 15 28 38 11 80    	mov    0x80113828,%edx
801008ec:	a1 24 38 11 80       	mov    0x80113824,%eax
801008f1:	39 c2                	cmp    %eax,%edx
801008f3:	0f 84 e4 00 00 00    	je     801009dd <consoleintr+0x1e4>
        input.e--;
801008f9:	a1 28 38 11 80       	mov    0x80113828,%eax
801008fe:	83 e8 01             	sub    $0x1,%eax
80100901:	a3 28 38 11 80       	mov    %eax,0x80113828
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
80100955:	8b 15 28 38 11 80    	mov    0x80113828,%edx
8010095b:	a1 20 38 11 80       	mov    0x80113820,%eax
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
8010097c:	a1 28 38 11 80       	mov    0x80113828,%eax
80100981:	8d 50 01             	lea    0x1(%eax),%edx
80100984:	89 15 28 38 11 80    	mov    %edx,0x80113828
8010098a:	83 e0 7f             	and    $0x7f,%eax
8010098d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100990:	88 90 a0 37 11 80    	mov    %dl,-0x7feec860(%eax)
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
801009b0:	a1 28 38 11 80       	mov    0x80113828,%eax
801009b5:	8b 15 20 38 11 80    	mov    0x80113820,%edx
801009bb:	83 ea 80             	sub    $0xffffff80,%edx
801009be:	39 d0                	cmp    %edx,%eax
801009c0:	75 1a                	jne    801009dc <consoleintr+0x1e3>
          input.w = input.e;
801009c2:	a1 28 38 11 80       	mov    0x80113828,%eax
801009c7:	a3 24 38 11 80       	mov    %eax,0x80113824
          wakeup(&input.r);
801009cc:	83 ec 0c             	sub    $0xc,%esp
801009cf:	68 20 38 11 80       	push   $0x80113820
801009d4:	e8 70 52 00 00       	call   80105c49 <wakeup>
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
801009f2:	68 e0 e5 10 80       	push   $0x8010e5e0
801009f7:	e8 b9 63 00 00       	call   80106db5 <release>
801009fc:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a03:	74 05                	je     80100a0a <consoleintr+0x211>
    procdump();  // now call procdump() wo. cons.lock held
80100a05:	e8 95 54 00 00       	call   80105e9f <procdump>
  }

#ifdef CS333_P3P4
  if(doprintready)
80100a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a0e:	74 05                	je     80100a15 <consoleintr+0x21c>
      printready();
80100a10:	e8 0d 5e 00 00       	call   80106822 <printready>
  if(doprintfree)
80100a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a19:	74 05                	je     80100a20 <consoleintr+0x227>
      printfree();
80100a1b:	e8 dd 5e 00 00       	call   801068fd <printfree>
  if(doprintsleep)
80100a20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a24:	74 05                	je     80100a2b <consoleintr+0x232>
      printsleep();
80100a26:	e8 45 5f 00 00       	call   80106970 <printsleep>
  if(doprintzombie)
80100a2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2f:	74 05                	je     80100a36 <consoleintr+0x23d>
      printzombie();
80100a31:	e8 e9 5f 00 00       	call   80106a1f <printzombie>

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
80100a45:	e8 16 12 00 00       	call   80101c60 <iunlock>
80100a4a:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a4d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a53:	83 ec 0c             	sub    $0xc,%esp
80100a56:	68 e0 e5 10 80       	push   $0x8010e5e0
80100a5b:	e8 ee 62 00 00       	call   80106d4e <acquire>
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
80100a78:	68 e0 e5 10 80       	push   $0x8010e5e0
80100a7d:	e8 33 63 00 00       	call   80106db5 <release>
80100a82:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a85:	83 ec 0c             	sub    $0xc,%esp
80100a88:	ff 75 08             	pushl  0x8(%ebp)
80100a8b:	e8 4a 10 00 00       	call   80101ada <ilock>
80100a90:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a98:	e9 ab 00 00 00       	jmp    80100b48 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a9d:	83 ec 08             	sub    $0x8,%esp
80100aa0:	68 e0 e5 10 80       	push   $0x8010e5e0
80100aa5:	68 20 38 11 80       	push   $0x80113820
80100aaa:	e8 8a 4f 00 00       	call   80105a39 <sleep>
80100aaf:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100ab2:	8b 15 20 38 11 80    	mov    0x80113820,%edx
80100ab8:	a1 24 38 11 80       	mov    0x80113824,%eax
80100abd:	39 c2                	cmp    %eax,%edx
80100abf:	74 a7                	je     80100a68 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ac1:	a1 20 38 11 80       	mov    0x80113820,%eax
80100ac6:	8d 50 01             	lea    0x1(%eax),%edx
80100ac9:	89 15 20 38 11 80    	mov    %edx,0x80113820
80100acf:	83 e0 7f             	and    $0x7f,%eax
80100ad2:	0f b6 80 a0 37 11 80 	movzbl -0x7feec860(%eax),%eax
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
80100aed:	a1 20 38 11 80       	mov    0x80113820,%eax
80100af2:	83 e8 01             	sub    $0x1,%eax
80100af5:	a3 20 38 11 80       	mov    %eax,0x80113820
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
80100b23:	68 e0 e5 10 80       	push   $0x8010e5e0
80100b28:	e8 88 62 00 00       	call   80106db5 <release>
80100b2d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b30:	83 ec 0c             	sub    $0xc,%esp
80100b33:	ff 75 08             	pushl  0x8(%ebp)
80100b36:	e8 9f 0f 00 00       	call   80101ada <ilock>
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
80100b56:	e8 05 11 00 00       	call   80101c60 <iunlock>
80100b5b:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b5e:	83 ec 0c             	sub    $0xc,%esp
80100b61:	68 e0 e5 10 80       	push   $0x8010e5e0
80100b66:	e8 e3 61 00 00       	call   80106d4e <acquire>
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
80100ba3:	68 e0 e5 10 80       	push   $0x8010e5e0
80100ba8:	e8 08 62 00 00       	call   80106db5 <release>
80100bad:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 08             	pushl  0x8(%ebp)
80100bb6:	e8 1f 0f 00 00       	call   80101ada <ilock>
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
80100bcc:	68 86 a6 10 80       	push   $0x8010a686
80100bd1:	68 e0 e5 10 80       	push   $0x8010e5e0
80100bd6:	e8 51 61 00 00       	call   80106d2c <initlock>
80100bdb:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bde:	c7 05 ec 41 11 80 4a 	movl   $0x80100b4a,0x801141ec
80100be5:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100be8:	c7 05 e8 41 11 80 39 	movl   $0x80100a39,0x801141e8
80100bef:	0a 10 80 
  cons.locking = 1;
80100bf2:	c7 05 14 e6 10 80 01 	movl   $0x1,0x8010e614
80100bf9:	00 00 00 

  picenable(IRQ_KBD);
80100bfc:	83 ec 0c             	sub    $0xc,%esp
80100bff:	6a 01                	push   $0x1
80100c01:	e8 86 36 00 00       	call   8010428c <picenable>
80100c06:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100c09:	83 ec 08             	sub    $0x8,%esp
80100c0c:	6a 00                	push   $0x0
80100c0e:	6a 01                	push   $0x1
80100c10:	e8 26 22 00 00       	call   80102e3b <ioapicenable>
80100c15:	83 c4 10             	add    $0x10,%esp
}
80100c18:	90                   	nop
80100c19:	c9                   	leave  
80100c1a:	c3                   	ret    

80100c1b <exec>:
#include "elf.h"
#include "stat.h"

int
exec(char *path, char **argv)
{
80100c1b:	55                   	push   %ebp
80100c1c:	89 e5                	mov    %esp,%ebp
80100c1e:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c24:	e8 85 2c 00 00       	call   801038ae <begin_op>
  if((ip = namei(path)) == 0){
80100c29:	83 ec 0c             	sub    $0xc,%esp
80100c2c:	ff 75 08             	pushl  0x8(%ebp)
80100c2f:	e8 b4 1a 00 00       	call   801026e8 <namei>
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c3e:	75 0f                	jne    80100c4f <exec+0x34>
    end_op();
80100c40:	e8 f5 2c 00 00       	call   8010393a <end_op>
    return -1;
80100c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c4a:	e9 50 04 00 00       	jmp    8010109f <exec+0x484>
  }


  ilock(ip);
80100c4f:	83 ec 0c             	sub    $0xc,%esp
80100c52:	ff 75 d8             	pushl  -0x28(%ebp)
80100c55:	e8 80 0e 00 00       	call   80101ada <ilock>
80100c5a:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P5
  struct stat st;
  stati(ip, &st);
80100c5d:	83 ec 08             	sub    $0x8,%esp
80100c60:	8d 85 d0 fe ff ff    	lea    -0x130(%ebp),%eax
80100c66:	50                   	push   %eax
80100c67:	ff 75 d8             	pushl  -0x28(%ebp)
80100c6a:	e8 bb 13 00 00       	call   8010202a <stati>
80100c6f:	83 c4 10             	add    $0x10,%esp
  if(st.mode.flags.u_x == 1 || st.mode.flags.g_x == 1 || st.mode.flags.o_x == 1){
80100c72:	0f b6 85 e8 fe ff ff 	movzbl -0x118(%ebp),%eax
80100c79:	83 e0 40             	and    $0x40,%eax
80100c7c:	84 c0                	test   %al,%al
80100c7e:	75 1c                	jne    80100c9c <exec+0x81>
80100c80:	0f b6 85 e8 fe ff ff 	movzbl -0x118(%ebp),%eax
80100c87:	83 e0 08             	and    $0x8,%eax
80100c8a:	84 c0                	test   %al,%al
80100c8c:	75 0e                	jne    80100c9c <exec+0x81>
80100c8e:	0f b6 85 e8 fe ff ff 	movzbl -0x118(%ebp),%eax
80100c95:	83 e0 01             	and    $0x1,%eax
80100c98:	84 c0                	test   %al,%al
80100c9a:	74 26                	je     80100cc2 <exec+0xa7>
    if(st.mode.flags.setuid == 1)
80100c9c:	0f b6 85 e9 fe ff ff 	movzbl -0x117(%ebp),%eax
80100ca3:	83 e0 02             	and    $0x2,%eax
80100ca6:	84 c0                	test   %al,%al
80100ca8:	74 35                	je     80100cdf <exec+0xc4>
      proc -> uid = st.uid;
80100caa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cb0:	0f b7 95 e4 fe ff ff 	movzwl -0x11c(%ebp),%edx
80100cb7:	0f b7 d2             	movzwl %dx,%edx
80100cba:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

#ifdef CS333_P5
  struct stat st;
  stati(ip, &st);
  if(st.mode.flags.u_x == 1 || st.mode.flags.g_x == 1 || st.mode.flags.o_x == 1){
    if(st.mode.flags.setuid == 1)
80100cc0:	eb 1d                	jmp    80100cdf <exec+0xc4>
      proc -> uid = st.uid;
  }
  else{
    iunlock(ip);
80100cc2:	83 ec 0c             	sub    $0xc,%esp
80100cc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc8:	e8 93 0f 00 00       	call   80101c60 <iunlock>
80100ccd:	83 c4 10             	add    $0x10,%esp
    end_op();
80100cd0:	e8 65 2c 00 00       	call   8010393a <end_op>
    return -1;
80100cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cda:	e9 c0 03 00 00       	jmp    8010109f <exec+0x484>
  }
#endif

  pgdir = 0;
80100cdf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100ce6:	6a 34                	push   $0x34
80100ce8:	6a 00                	push   $0x0
80100cea:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100cf0:	50                   	push   %eax
80100cf1:	ff 75 d8             	pushl  -0x28(%ebp)
80100cf4:	e8 9f 13 00 00       	call   80102098 <readi>
80100cf9:	83 c4 10             	add    $0x10,%esp
80100cfc:	83 f8 33             	cmp    $0x33,%eax
80100cff:	0f 86 49 03 00 00    	jbe    8010104e <exec+0x433>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100d05:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100d0b:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d10:	0f 85 3b 03 00 00    	jne    80101051 <exec+0x436>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100d16:	e8 e9 90 00 00       	call   80109e04 <setupkvm>
80100d1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d1e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d22:	0f 84 2c 03 00 00    	je     80101054 <exec+0x439>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d28:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d2f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d36:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100d3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d3f:	e9 ab 00 00 00       	jmp    80100def <exec+0x1d4>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d47:	6a 20                	push   $0x20
80100d49:	50                   	push   %eax
80100d4a:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100d50:	50                   	push   %eax
80100d51:	ff 75 d8             	pushl  -0x28(%ebp)
80100d54:	e8 3f 13 00 00       	call   80102098 <readi>
80100d59:	83 c4 10             	add    $0x10,%esp
80100d5c:	83 f8 20             	cmp    $0x20,%eax
80100d5f:	0f 85 f2 02 00 00    	jne    80101057 <exec+0x43c>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d65:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d6b:	83 f8 01             	cmp    $0x1,%eax
80100d6e:	75 71                	jne    80100de1 <exec+0x1c6>
      continue;
    if(ph.memsz < ph.filesz)
80100d70:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100d76:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d7c:	39 c2                	cmp    %eax,%edx
80100d7e:	0f 82 d6 02 00 00    	jb     8010105a <exec+0x43f>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d84:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d8a:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100d90:	01 d0                	add    %edx,%eax
80100d92:	83 ec 04             	sub    $0x4,%esp
80100d95:	50                   	push   %eax
80100d96:	ff 75 e0             	pushl  -0x20(%ebp)
80100d99:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d9c:	e8 0a 94 00 00       	call   8010a1ab <allocuvm>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100da7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dab:	0f 84 ac 02 00 00    	je     8010105d <exec+0x442>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100db1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100db7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dbd:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100dc3:	83 ec 0c             	sub    $0xc,%esp
80100dc6:	52                   	push   %edx
80100dc7:	50                   	push   %eax
80100dc8:	ff 75 d8             	pushl  -0x28(%ebp)
80100dcb:	51                   	push   %ecx
80100dcc:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dcf:	e8 00 93 00 00       	call   8010a0d4 <loaduvm>
80100dd4:	83 c4 20             	add    $0x20,%esp
80100dd7:	85 c0                	test   %eax,%eax
80100dd9:	0f 88 81 02 00 00    	js     80101060 <exec+0x445>
80100ddf:	eb 01                	jmp    80100de2 <exec+0x1c7>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100de1:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100de2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100de6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100de9:	83 c0 20             	add    $0x20,%eax
80100dec:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100def:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100df6:	0f b7 c0             	movzwl %ax,%eax
80100df9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100dfc:	0f 8f 42 ff ff ff    	jg     80100d44 <exec+0x129>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e02:	83 ec 0c             	sub    $0xc,%esp
80100e05:	ff 75 d8             	pushl  -0x28(%ebp)
80100e08:	e8 b5 0f 00 00       	call   80101dc2 <iunlockput>
80100e0d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e10:	e8 25 2b 00 00       	call   8010393a <end_op>
  ip = 0;
80100e15:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e1f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e2f:	05 00 20 00 00       	add    $0x2000,%eax
80100e34:	83 ec 04             	sub    $0x4,%esp
80100e37:	50                   	push   %eax
80100e38:	ff 75 e0             	pushl  -0x20(%ebp)
80100e3b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e3e:	e8 68 93 00 00       	call   8010a1ab <allocuvm>
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e4d:	0f 84 10 02 00 00    	je     80101063 <exec+0x448>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e56:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e5b:	83 ec 08             	sub    $0x8,%esp
80100e5e:	50                   	push   %eax
80100e5f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e62:	e8 6a 95 00 00       	call   8010a3d1 <clearpteu>
80100e67:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e6d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e77:	e9 96 00 00 00       	jmp    80100f12 <exec+0x2f7>
    if(argc >= MAXARG)
80100e7c:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e80:	0f 87 e0 01 00 00    	ja     80101066 <exec+0x44b>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e90:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e93:	01 d0                	add    %edx,%eax
80100e95:	8b 00                	mov    (%eax),%eax
80100e97:	83 ec 0c             	sub    $0xc,%esp
80100e9a:	50                   	push   %eax
80100e9b:	e8 5e 63 00 00       	call   801071fe <strlen>
80100ea0:	83 c4 10             	add    $0x10,%esp
80100ea3:	89 c2                	mov    %eax,%edx
80100ea5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ea8:	29 d0                	sub    %edx,%eax
80100eaa:	83 e8 01             	sub    $0x1,%eax
80100ead:	83 e0 fc             	and    $0xfffffffc,%eax
80100eb0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100eb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec0:	01 d0                	add    %edx,%eax
80100ec2:	8b 00                	mov    (%eax),%eax
80100ec4:	83 ec 0c             	sub    $0xc,%esp
80100ec7:	50                   	push   %eax
80100ec8:	e8 31 63 00 00       	call   801071fe <strlen>
80100ecd:	83 c4 10             	add    $0x10,%esp
80100ed0:	83 c0 01             	add    $0x1,%eax
80100ed3:	89 c1                	mov    %eax,%ecx
80100ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100edf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ee2:	01 d0                	add    %edx,%eax
80100ee4:	8b 00                	mov    (%eax),%eax
80100ee6:	51                   	push   %ecx
80100ee7:	50                   	push   %eax
80100ee8:	ff 75 dc             	pushl  -0x24(%ebp)
80100eeb:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eee:	e8 95 96 00 00       	call   8010a588 <copyout>
80100ef3:	83 c4 10             	add    $0x10,%esp
80100ef6:	85 c0                	test   %eax,%eax
80100ef8:	0f 88 6b 01 00 00    	js     80101069 <exec+0x44e>
      goto bad;
    ustack[3+argc] = sp;
80100efe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f01:	8d 50 03             	lea    0x3(%eax),%edx
80100f04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f07:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f0e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f1f:	01 d0                	add    %edx,%eax
80100f21:	8b 00                	mov    (%eax),%eax
80100f23:	85 c0                	test   %eax,%eax
80100f25:	0f 85 51 ff ff ff    	jne    80100e7c <exec+0x261>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2e:	83 c0 03             	add    $0x3,%eax
80100f31:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100f38:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f3c:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100f43:	ff ff ff 
  ustack[1] = argc;
80100f46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f49:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f52:	83 c0 01             	add    $0x1,%eax
80100f55:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f5f:	29 d0                	sub    %edx,%eax
80100f61:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100f67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f6a:	83 c0 04             	add    $0x4,%eax
80100f6d:	c1 e0 02             	shl    $0x2,%eax
80100f70:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f76:	83 c0 04             	add    $0x4,%eax
80100f79:	c1 e0 02             	shl    $0x2,%eax
80100f7c:	50                   	push   %eax
80100f7d:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100f83:	50                   	push   %eax
80100f84:	ff 75 dc             	pushl  -0x24(%ebp)
80100f87:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f8a:	e8 f9 95 00 00       	call   8010a588 <copyout>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	85 c0                	test   %eax,%eax
80100f94:	0f 88 d2 00 00 00    	js     8010106c <exec+0x451>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fa6:	eb 17                	jmp    80100fbf <exec+0x3a4>
    if(*s == '/')
80100fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fab:	0f b6 00             	movzbl (%eax),%eax
80100fae:	3c 2f                	cmp    $0x2f,%al
80100fb0:	75 09                	jne    80100fbb <exec+0x3a0>
      last = s+1;
80100fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb5:	83 c0 01             	add    $0x1,%eax
80100fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fbb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc2:	0f b6 00             	movzbl (%eax),%eax
80100fc5:	84 c0                	test   %al,%al
80100fc7:	75 df                	jne    80100fa8 <exec+0x38d>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100fc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fcf:	83 c0 6c             	add    $0x6c,%eax
80100fd2:	83 ec 04             	sub    $0x4,%esp
80100fd5:	6a 10                	push   $0x10
80100fd7:	ff 75 f0             	pushl  -0x10(%ebp)
80100fda:	50                   	push   %eax
80100fdb:	e8 d4 61 00 00       	call   801071b4 <safestrcpy>
80100fe0:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100fe3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fe9:	8b 40 04             	mov    0x4(%eax),%eax
80100fec:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100fef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ff5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ff8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ffb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101001:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101004:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80101006:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010100c:	8b 40 18             	mov    0x18(%eax),%eax
8010100f:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80101015:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80101018:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010101e:	8b 40 18             	mov    0x18(%eax),%eax
80101021:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101024:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80101027:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	50                   	push   %eax
80101031:	e8 b5 8e 00 00       	call   80109eeb <switchuvm>
80101036:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101039:	83 ec 0c             	sub    $0xc,%esp
8010103c:	ff 75 d0             	pushl  -0x30(%ebp)
8010103f:	e8 ed 92 00 00       	call   8010a331 <freevm>
80101044:	83 c4 10             	add    $0x10,%esp
  return 0;
80101047:	b8 00 00 00 00       	mov    $0x0,%eax
8010104c:	eb 51                	jmp    8010109f <exec+0x484>

  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010104e:	90                   	nop
8010104f:	eb 1c                	jmp    8010106d <exec+0x452>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101051:	90                   	nop
80101052:	eb 19                	jmp    8010106d <exec+0x452>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80101054:	90                   	nop
80101055:	eb 16                	jmp    8010106d <exec+0x452>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101057:	90                   	nop
80101058:	eb 13                	jmp    8010106d <exec+0x452>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010105a:	90                   	nop
8010105b:	eb 10                	jmp    8010106d <exec+0x452>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010105d:	90                   	nop
8010105e:	eb 0d                	jmp    8010106d <exec+0x452>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101060:	90                   	nop
80101061:	eb 0a                	jmp    8010106d <exec+0x452>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101063:	90                   	nop
80101064:	eb 07                	jmp    8010106d <exec+0x452>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101066:	90                   	nop
80101067:	eb 04                	jmp    8010106d <exec+0x452>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101069:	90                   	nop
8010106a:	eb 01                	jmp    8010106d <exec+0x452>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010106c:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010106d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101071:	74 0e                	je     80101081 <exec+0x466>
    freevm(pgdir);
80101073:	83 ec 0c             	sub    $0xc,%esp
80101076:	ff 75 d4             	pushl  -0x2c(%ebp)
80101079:	e8 b3 92 00 00       	call   8010a331 <freevm>
8010107e:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101081:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101085:	74 13                	je     8010109a <exec+0x47f>
    iunlockput(ip);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	ff 75 d8             	pushl  -0x28(%ebp)
8010108d:	e8 30 0d 00 00       	call   80101dc2 <iunlockput>
80101092:	83 c4 10             	add    $0x10,%esp
    end_op();
80101095:	e8 a0 28 00 00       	call   8010393a <end_op>
  }
  return -1;
8010109a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010109f:	c9                   	leave  
801010a0:	c3                   	ret    

801010a1 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010a1:	55                   	push   %ebp
801010a2:	89 e5                	mov    %esp,%ebp
801010a4:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010a7:	83 ec 08             	sub    $0x8,%esp
801010aa:	68 8e a6 10 80       	push   $0x8010a68e
801010af:	68 40 38 11 80       	push   $0x80113840
801010b4:	e8 73 5c 00 00       	call   80106d2c <initlock>
801010b9:	83 c4 10             	add    $0x10,%esp
}
801010bc:	90                   	nop
801010bd:	c9                   	leave  
801010be:	c3                   	ret    

801010bf <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010bf:	55                   	push   %ebp
801010c0:	89 e5                	mov    %esp,%ebp
801010c2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 40 38 11 80       	push   $0x80113840
801010cd:	e8 7c 5c 00 00       	call   80106d4e <acquire>
801010d2:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010d5:	c7 45 f4 74 38 11 80 	movl   $0x80113874,-0xc(%ebp)
801010dc:	eb 2d                	jmp    8010110b <filealloc+0x4c>
    if(f->ref == 0){
801010de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010e1:	8b 40 04             	mov    0x4(%eax),%eax
801010e4:	85 c0                	test   %eax,%eax
801010e6:	75 1f                	jne    80101107 <filealloc+0x48>
      f->ref = 1;
801010e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010eb:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010f2:	83 ec 0c             	sub    $0xc,%esp
801010f5:	68 40 38 11 80       	push   $0x80113840
801010fa:	e8 b6 5c 00 00       	call   80106db5 <release>
801010ff:	83 c4 10             	add    $0x10,%esp
      return f;
80101102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101105:	eb 23                	jmp    8010112a <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101107:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010110b:	b8 d4 41 11 80       	mov    $0x801141d4,%eax
80101110:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101113:	72 c9                	jb     801010de <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101115:	83 ec 0c             	sub    $0xc,%esp
80101118:	68 40 38 11 80       	push   $0x80113840
8010111d:	e8 93 5c 00 00       	call   80106db5 <release>
80101122:	83 c4 10             	add    $0x10,%esp
  return 0;
80101125:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010112a:	c9                   	leave  
8010112b:	c3                   	ret    

8010112c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010112c:	55                   	push   %ebp
8010112d:	89 e5                	mov    %esp,%ebp
8010112f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101132:	83 ec 0c             	sub    $0xc,%esp
80101135:	68 40 38 11 80       	push   $0x80113840
8010113a:	e8 0f 5c 00 00       	call   80106d4e <acquire>
8010113f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101142:	8b 45 08             	mov    0x8(%ebp),%eax
80101145:	8b 40 04             	mov    0x4(%eax),%eax
80101148:	85 c0                	test   %eax,%eax
8010114a:	7f 0d                	jg     80101159 <filedup+0x2d>
    panic("filedup");
8010114c:	83 ec 0c             	sub    $0xc,%esp
8010114f:	68 95 a6 10 80       	push   $0x8010a695
80101154:	e8 0d f4 ff ff       	call   80100566 <panic>
  f->ref++;
80101159:	8b 45 08             	mov    0x8(%ebp),%eax
8010115c:	8b 40 04             	mov    0x4(%eax),%eax
8010115f:	8d 50 01             	lea    0x1(%eax),%edx
80101162:	8b 45 08             	mov    0x8(%ebp),%eax
80101165:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101168:	83 ec 0c             	sub    $0xc,%esp
8010116b:	68 40 38 11 80       	push   $0x80113840
80101170:	e8 40 5c 00 00       	call   80106db5 <release>
80101175:	83 c4 10             	add    $0x10,%esp
  return f;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010117b:	c9                   	leave  
8010117c:	c3                   	ret    

8010117d <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010117d:	55                   	push   %ebp
8010117e:	89 e5                	mov    %esp,%ebp
80101180:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101183:	83 ec 0c             	sub    $0xc,%esp
80101186:	68 40 38 11 80       	push   $0x80113840
8010118b:	e8 be 5b 00 00       	call   80106d4e <acquire>
80101190:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 04             	mov    0x4(%eax),%eax
80101199:	85 c0                	test   %eax,%eax
8010119b:	7f 0d                	jg     801011aa <fileclose+0x2d>
    panic("fileclose");
8010119d:	83 ec 0c             	sub    $0xc,%esp
801011a0:	68 9d a6 10 80       	push   $0x8010a69d
801011a5:	e8 bc f3 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
801011aa:	8b 45 08             	mov    0x8(%ebp),%eax
801011ad:	8b 40 04             	mov    0x4(%eax),%eax
801011b0:	8d 50 ff             	lea    -0x1(%eax),%edx
801011b3:	8b 45 08             	mov    0x8(%ebp),%eax
801011b6:	89 50 04             	mov    %edx,0x4(%eax)
801011b9:	8b 45 08             	mov    0x8(%ebp),%eax
801011bc:	8b 40 04             	mov    0x4(%eax),%eax
801011bf:	85 c0                	test   %eax,%eax
801011c1:	7e 15                	jle    801011d8 <fileclose+0x5b>
    release(&ftable.lock);
801011c3:	83 ec 0c             	sub    $0xc,%esp
801011c6:	68 40 38 11 80       	push   $0x80113840
801011cb:	e8 e5 5b 00 00       	call   80106db5 <release>
801011d0:	83 c4 10             	add    $0x10,%esp
801011d3:	e9 8b 00 00 00       	jmp    80101263 <fileclose+0xe6>
    return;
  }
  ff = *f;
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 10                	mov    (%eax),%edx
801011dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011e0:	8b 50 04             	mov    0x4(%eax),%edx
801011e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011e6:	8b 50 08             	mov    0x8(%eax),%edx
801011e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011ec:	8b 50 0c             	mov    0xc(%eax),%edx
801011ef:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011f2:	8b 50 10             	mov    0x10(%eax),%edx
801011f5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011f8:	8b 40 14             	mov    0x14(%eax),%eax
801011fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101201:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101208:	8b 45 08             	mov    0x8(%ebp),%eax
8010120b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101211:	83 ec 0c             	sub    $0xc,%esp
80101214:	68 40 38 11 80       	push   $0x80113840
80101219:	e8 97 5b 00 00       	call   80106db5 <release>
8010121e:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101221:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101224:	83 f8 01             	cmp    $0x1,%eax
80101227:	75 19                	jne    80101242 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101229:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010122d:	0f be d0             	movsbl %al,%edx
80101230:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101233:	83 ec 08             	sub    $0x8,%esp
80101236:	52                   	push   %edx
80101237:	50                   	push   %eax
80101238:	e8 b8 32 00 00       	call   801044f5 <pipeclose>
8010123d:	83 c4 10             	add    $0x10,%esp
80101240:	eb 21                	jmp    80101263 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101242:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101245:	83 f8 02             	cmp    $0x2,%eax
80101248:	75 19                	jne    80101263 <fileclose+0xe6>
    begin_op();
8010124a:	e8 5f 26 00 00       	call   801038ae <begin_op>
    iput(ff.ip);
8010124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101252:	83 ec 0c             	sub    $0xc,%esp
80101255:	50                   	push   %eax
80101256:	e8 77 0a 00 00       	call   80101cd2 <iput>
8010125b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010125e:	e8 d7 26 00 00       	call   8010393a <end_op>
  }
}
80101263:	c9                   	leave  
80101264:	c3                   	ret    

80101265 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101265:	55                   	push   %ebp
80101266:	89 e5                	mov    %esp,%ebp
80101268:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010126b:	8b 45 08             	mov    0x8(%ebp),%eax
8010126e:	8b 00                	mov    (%eax),%eax
80101270:	83 f8 02             	cmp    $0x2,%eax
80101273:	75 40                	jne    801012b5 <filestat+0x50>
    ilock(f->ip);
80101275:	8b 45 08             	mov    0x8(%ebp),%eax
80101278:	8b 40 10             	mov    0x10(%eax),%eax
8010127b:	83 ec 0c             	sub    $0xc,%esp
8010127e:	50                   	push   %eax
8010127f:	e8 56 08 00 00       	call   80101ada <ilock>
80101284:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101287:	8b 45 08             	mov    0x8(%ebp),%eax
8010128a:	8b 40 10             	mov    0x10(%eax),%eax
8010128d:	83 ec 08             	sub    $0x8,%esp
80101290:	ff 75 0c             	pushl  0xc(%ebp)
80101293:	50                   	push   %eax
80101294:	e8 91 0d 00 00       	call   8010202a <stati>
80101299:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	8b 40 10             	mov    0x10(%eax),%eax
801012a2:	83 ec 0c             	sub    $0xc,%esp
801012a5:	50                   	push   %eax
801012a6:	e8 b5 09 00 00       	call   80101c60 <iunlock>
801012ab:	83 c4 10             	add    $0x10,%esp
    return 0;
801012ae:	b8 00 00 00 00       	mov    $0x0,%eax
801012b3:	eb 05                	jmp    801012ba <filestat+0x55>
  }
  return -1;
801012b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012ba:	c9                   	leave  
801012bb:	c3                   	ret    

801012bc <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012bc:	55                   	push   %ebp
801012bd:	89 e5                	mov    %esp,%ebp
801012bf:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012c9:	84 c0                	test   %al,%al
801012cb:	75 0a                	jne    801012d7 <fileread+0x1b>
    return -1;
801012cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d2:	e9 9b 00 00 00       	jmp    80101372 <fileread+0xb6>
  if(f->type == FD_PIPE)
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 00                	mov    (%eax),%eax
801012dc:	83 f8 01             	cmp    $0x1,%eax
801012df:	75 1a                	jne    801012fb <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801012e1:	8b 45 08             	mov    0x8(%ebp),%eax
801012e4:	8b 40 0c             	mov    0xc(%eax),%eax
801012e7:	83 ec 04             	sub    $0x4,%esp
801012ea:	ff 75 10             	pushl  0x10(%ebp)
801012ed:	ff 75 0c             	pushl  0xc(%ebp)
801012f0:	50                   	push   %eax
801012f1:	e8 a7 33 00 00       	call   8010469d <piperead>
801012f6:	83 c4 10             	add    $0x10,%esp
801012f9:	eb 77                	jmp    80101372 <fileread+0xb6>
  if(f->type == FD_INODE){
801012fb:	8b 45 08             	mov    0x8(%ebp),%eax
801012fe:	8b 00                	mov    (%eax),%eax
80101300:	83 f8 02             	cmp    $0x2,%eax
80101303:	75 60                	jne    80101365 <fileread+0xa9>
    ilock(f->ip);
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 40 10             	mov    0x10(%eax),%eax
8010130b:	83 ec 0c             	sub    $0xc,%esp
8010130e:	50                   	push   %eax
8010130f:	e8 c6 07 00 00       	call   80101ada <ilock>
80101314:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101317:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010131a:	8b 45 08             	mov    0x8(%ebp),%eax
8010131d:	8b 50 14             	mov    0x14(%eax),%edx
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 40 10             	mov    0x10(%eax),%eax
80101326:	51                   	push   %ecx
80101327:	52                   	push   %edx
80101328:	ff 75 0c             	pushl  0xc(%ebp)
8010132b:	50                   	push   %eax
8010132c:	e8 67 0d 00 00       	call   80102098 <readi>
80101331:	83 c4 10             	add    $0x10,%esp
80101334:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101337:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010133b:	7e 11                	jle    8010134e <fileread+0x92>
      f->off += r;
8010133d:	8b 45 08             	mov    0x8(%ebp),%eax
80101340:	8b 50 14             	mov    0x14(%eax),%edx
80101343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101346:	01 c2                	add    %eax,%edx
80101348:	8b 45 08             	mov    0x8(%ebp),%eax
8010134b:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010134e:	8b 45 08             	mov    0x8(%ebp),%eax
80101351:	8b 40 10             	mov    0x10(%eax),%eax
80101354:	83 ec 0c             	sub    $0xc,%esp
80101357:	50                   	push   %eax
80101358:	e8 03 09 00 00       	call   80101c60 <iunlock>
8010135d:	83 c4 10             	add    $0x10,%esp
    return r;
80101360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101363:	eb 0d                	jmp    80101372 <fileread+0xb6>
  }
  panic("fileread");
80101365:	83 ec 0c             	sub    $0xc,%esp
80101368:	68 a7 a6 10 80       	push   $0x8010a6a7
8010136d:	e8 f4 f1 ff ff       	call   80100566 <panic>
}
80101372:	c9                   	leave  
80101373:	c3                   	ret    

80101374 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101374:	55                   	push   %ebp
80101375:	89 e5                	mov    %esp,%ebp
80101377:	53                   	push   %ebx
80101378:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010137b:	8b 45 08             	mov    0x8(%ebp),%eax
8010137e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101382:	84 c0                	test   %al,%al
80101384:	75 0a                	jne    80101390 <filewrite+0x1c>
    return -1;
80101386:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010138b:	e9 1b 01 00 00       	jmp    801014ab <filewrite+0x137>
  if(f->type == FD_PIPE)
80101390:	8b 45 08             	mov    0x8(%ebp),%eax
80101393:	8b 00                	mov    (%eax),%eax
80101395:	83 f8 01             	cmp    $0x1,%eax
80101398:	75 1d                	jne    801013b7 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010139a:	8b 45 08             	mov    0x8(%ebp),%eax
8010139d:	8b 40 0c             	mov    0xc(%eax),%eax
801013a0:	83 ec 04             	sub    $0x4,%esp
801013a3:	ff 75 10             	pushl  0x10(%ebp)
801013a6:	ff 75 0c             	pushl  0xc(%ebp)
801013a9:	50                   	push   %eax
801013aa:	e8 f0 31 00 00       	call   8010459f <pipewrite>
801013af:	83 c4 10             	add    $0x10,%esp
801013b2:	e9 f4 00 00 00       	jmp    801014ab <filewrite+0x137>
  if(f->type == FD_INODE){
801013b7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ba:	8b 00                	mov    (%eax),%eax
801013bc:	83 f8 02             	cmp    $0x2,%eax
801013bf:	0f 85 d9 00 00 00    	jne    8010149e <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013c5:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013d3:	e9 a3 00 00 00       	jmp    8010147b <filewrite+0x107>
      int n1 = n - i;
801013d8:	8b 45 10             	mov    0x10(%ebp),%eax
801013db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013de:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013e4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013e7:	7e 06                	jle    801013ef <filewrite+0x7b>
        n1 = max;
801013e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013ec:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013ef:	e8 ba 24 00 00       	call   801038ae <begin_op>
      ilock(f->ip);
801013f4:	8b 45 08             	mov    0x8(%ebp),%eax
801013f7:	8b 40 10             	mov    0x10(%eax),%eax
801013fa:	83 ec 0c             	sub    $0xc,%esp
801013fd:	50                   	push   %eax
801013fe:	e8 d7 06 00 00       	call   80101ada <ilock>
80101403:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101406:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101409:	8b 45 08             	mov    0x8(%ebp),%eax
8010140c:	8b 50 14             	mov    0x14(%eax),%edx
8010140f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101412:	8b 45 0c             	mov    0xc(%ebp),%eax
80101415:	01 c3                	add    %eax,%ebx
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	8b 40 10             	mov    0x10(%eax),%eax
8010141d:	51                   	push   %ecx
8010141e:	52                   	push   %edx
8010141f:	53                   	push   %ebx
80101420:	50                   	push   %eax
80101421:	e8 c9 0d 00 00       	call   801021ef <writei>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010142c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101430:	7e 11                	jle    80101443 <filewrite+0xcf>
        f->off += r;
80101432:	8b 45 08             	mov    0x8(%ebp),%eax
80101435:	8b 50 14             	mov    0x14(%eax),%edx
80101438:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010143b:	01 c2                	add    %eax,%edx
8010143d:	8b 45 08             	mov    0x8(%ebp),%eax
80101440:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101443:	8b 45 08             	mov    0x8(%ebp),%eax
80101446:	8b 40 10             	mov    0x10(%eax),%eax
80101449:	83 ec 0c             	sub    $0xc,%esp
8010144c:	50                   	push   %eax
8010144d:	e8 0e 08 00 00       	call   80101c60 <iunlock>
80101452:	83 c4 10             	add    $0x10,%esp
      end_op();
80101455:	e8 e0 24 00 00       	call   8010393a <end_op>

      if(r < 0)
8010145a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010145e:	78 29                	js     80101489 <filewrite+0x115>
        break;
      if(r != n1)
80101460:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101463:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101466:	74 0d                	je     80101475 <filewrite+0x101>
        panic("short filewrite");
80101468:	83 ec 0c             	sub    $0xc,%esp
8010146b:	68 b0 a6 10 80       	push   $0x8010a6b0
80101470:	e8 f1 f0 ff ff       	call   80100566 <panic>
      i += r;
80101475:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101478:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010147e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101481:	0f 8c 51 ff ff ff    	jl     801013d8 <filewrite+0x64>
80101487:	eb 01                	jmp    8010148a <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101489:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010148a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101490:	75 05                	jne    80101497 <filewrite+0x123>
80101492:	8b 45 10             	mov    0x10(%ebp),%eax
80101495:	eb 14                	jmp    801014ab <filewrite+0x137>
80101497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010149c:	eb 0d                	jmp    801014ab <filewrite+0x137>
  }
  panic("filewrite");
8010149e:	83 ec 0c             	sub    $0xc,%esp
801014a1:	68 c0 a6 10 80       	push   $0x8010a6c0
801014a6:	e8 bb f0 ff ff       	call   80100566 <panic>
}
801014ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014ae:	c9                   	leave  
801014af:	c3                   	ret    

801014b0 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014b0:	55                   	push   %ebp
801014b1:	89 e5                	mov    %esp,%ebp
801014b3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801014b6:	8b 45 08             	mov    0x8(%ebp),%eax
801014b9:	83 ec 08             	sub    $0x8,%esp
801014bc:	6a 01                	push   $0x1
801014be:	50                   	push   %eax
801014bf:	e8 f2 ec ff ff       	call   801001b6 <bread>
801014c4:	83 c4 10             	add    $0x10,%esp
801014c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014cd:	83 c0 18             	add    $0x18,%eax
801014d0:	83 ec 04             	sub    $0x4,%esp
801014d3:	6a 1c                	push   $0x1c
801014d5:	50                   	push   %eax
801014d6:	ff 75 0c             	pushl  0xc(%ebp)
801014d9:	e8 92 5b 00 00       	call   80107070 <memmove>
801014de:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014e1:	83 ec 0c             	sub    $0xc,%esp
801014e4:	ff 75 f4             	pushl  -0xc(%ebp)
801014e7:	e8 42 ed ff ff       	call   8010022e <brelse>
801014ec:	83 c4 10             	add    $0x10,%esp
}
801014ef:	90                   	nop
801014f0:	c9                   	leave  
801014f1:	c3                   	ret    

801014f2 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014f2:	55                   	push   %ebp
801014f3:	89 e5                	mov    %esp,%ebp
801014f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801014f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801014fb:	8b 45 08             	mov    0x8(%ebp),%eax
801014fe:	83 ec 08             	sub    $0x8,%esp
80101501:	52                   	push   %edx
80101502:	50                   	push   %eax
80101503:	e8 ae ec ff ff       	call   801001b6 <bread>
80101508:	83 c4 10             	add    $0x10,%esp
8010150b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101511:	83 c0 18             	add    $0x18,%eax
80101514:	83 ec 04             	sub    $0x4,%esp
80101517:	68 00 02 00 00       	push   $0x200
8010151c:	6a 00                	push   $0x0
8010151e:	50                   	push   %eax
8010151f:	e8 8d 5a 00 00       	call   80106fb1 <memset>
80101524:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101527:	83 ec 0c             	sub    $0xc,%esp
8010152a:	ff 75 f4             	pushl  -0xc(%ebp)
8010152d:	e8 b4 25 00 00       	call   80103ae6 <log_write>
80101532:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101535:	83 ec 0c             	sub    $0xc,%esp
80101538:	ff 75 f4             	pushl  -0xc(%ebp)
8010153b:	e8 ee ec ff ff       	call   8010022e <brelse>
80101540:	83 c4 10             	add    $0x10,%esp
}
80101543:	90                   	nop
80101544:	c9                   	leave  
80101545:	c3                   	ret    

80101546 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101546:	55                   	push   %ebp
80101547:	89 e5                	mov    %esp,%ebp
80101549:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010154c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101553:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010155a:	e9 13 01 00 00       	jmp    80101672 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010155f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101562:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101568:	85 c0                	test   %eax,%eax
8010156a:	0f 48 c2             	cmovs  %edx,%eax
8010156d:	c1 f8 0c             	sar    $0xc,%eax
80101570:	89 c2                	mov    %eax,%edx
80101572:	a1 58 42 11 80       	mov    0x80114258,%eax
80101577:	01 d0                	add    %edx,%eax
80101579:	83 ec 08             	sub    $0x8,%esp
8010157c:	50                   	push   %eax
8010157d:	ff 75 08             	pushl  0x8(%ebp)
80101580:	e8 31 ec ff ff       	call   801001b6 <bread>
80101585:	83 c4 10             	add    $0x10,%esp
80101588:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010158b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101592:	e9 a6 00 00 00       	jmp    8010163d <balloc+0xf7>
      m = 1 << (bi % 8);
80101597:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159a:	99                   	cltd   
8010159b:	c1 ea 1d             	shr    $0x1d,%edx
8010159e:	01 d0                	add    %edx,%eax
801015a0:	83 e0 07             	and    $0x7,%eax
801015a3:	29 d0                	sub    %edx,%eax
801015a5:	ba 01 00 00 00       	mov    $0x1,%edx
801015aa:	89 c1                	mov    %eax,%ecx
801015ac:	d3 e2                	shl    %cl,%edx
801015ae:	89 d0                	mov    %edx,%eax
801015b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b6:	8d 50 07             	lea    0x7(%eax),%edx
801015b9:	85 c0                	test   %eax,%eax
801015bb:	0f 48 c2             	cmovs  %edx,%eax
801015be:	c1 f8 03             	sar    $0x3,%eax
801015c1:	89 c2                	mov    %eax,%edx
801015c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015c6:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015cb:	0f b6 c0             	movzbl %al,%eax
801015ce:	23 45 e8             	and    -0x18(%ebp),%eax
801015d1:	85 c0                	test   %eax,%eax
801015d3:	75 64                	jne    80101639 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801015d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d8:	8d 50 07             	lea    0x7(%eax),%edx
801015db:	85 c0                	test   %eax,%eax
801015dd:	0f 48 c2             	cmovs  %edx,%eax
801015e0:	c1 f8 03             	sar    $0x3,%eax
801015e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015e6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015eb:	89 d1                	mov    %edx,%ecx
801015ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015f0:	09 ca                	or     %ecx,%edx
801015f2:	89 d1                	mov    %edx,%ecx
801015f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801015fb:	83 ec 0c             	sub    $0xc,%esp
801015fe:	ff 75 ec             	pushl  -0x14(%ebp)
80101601:	e8 e0 24 00 00       	call   80103ae6 <log_write>
80101606:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101609:	83 ec 0c             	sub    $0xc,%esp
8010160c:	ff 75 ec             	pushl  -0x14(%ebp)
8010160f:	e8 1a ec ff ff       	call   8010022e <brelse>
80101614:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101617:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161d:	01 c2                	add    %eax,%edx
8010161f:	8b 45 08             	mov    0x8(%ebp),%eax
80101622:	83 ec 08             	sub    $0x8,%esp
80101625:	52                   	push   %edx
80101626:	50                   	push   %eax
80101627:	e8 c6 fe ff ff       	call   801014f2 <bzero>
8010162c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010162f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	01 d0                	add    %edx,%eax
80101637:	eb 57                	jmp    80101690 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101639:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010163d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101644:	7f 17                	jg     8010165d <balloc+0x117>
80101646:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164c:	01 d0                	add    %edx,%eax
8010164e:	89 c2                	mov    %eax,%edx
80101650:	a1 40 42 11 80       	mov    0x80114240,%eax
80101655:	39 c2                	cmp    %eax,%edx
80101657:	0f 82 3a ff ff ff    	jb     80101597 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010165d:	83 ec 0c             	sub    $0xc,%esp
80101660:	ff 75 ec             	pushl  -0x14(%ebp)
80101663:	e8 c6 eb ff ff       	call   8010022e <brelse>
80101668:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010166b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101672:	8b 15 40 42 11 80    	mov    0x80114240,%edx
80101678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 87 dc fe ff ff    	ja     8010155f <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	83 ec 0c             	sub    $0xc,%esp
80101686:	68 cc a6 10 80       	push   $0x8010a6cc
8010168b:	e8 d6 ee ff ff       	call   80100566 <panic>
}
80101690:	c9                   	leave  
80101691:	c3                   	ret    

80101692 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101692:	55                   	push   %ebp
80101693:	89 e5                	mov    %esp,%ebp
80101695:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101698:	83 ec 08             	sub    $0x8,%esp
8010169b:	68 40 42 11 80       	push   $0x80114240
801016a0:	ff 75 08             	pushl  0x8(%ebp)
801016a3:	e8 08 fe ff ff       	call   801014b0 <readsb>
801016a8:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801016ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ae:	c1 e8 0c             	shr    $0xc,%eax
801016b1:	89 c2                	mov    %eax,%edx
801016b3:	a1 58 42 11 80       	mov    0x80114258,%eax
801016b8:	01 c2                	add    %eax,%edx
801016ba:	8b 45 08             	mov    0x8(%ebp),%eax
801016bd:	83 ec 08             	sub    $0x8,%esp
801016c0:	52                   	push   %edx
801016c1:	50                   	push   %eax
801016c2:	e8 ef ea ff ff       	call   801001b6 <bread>
801016c7:	83 c4 10             	add    $0x10,%esp
801016ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801016d0:	25 ff 0f 00 00       	and    $0xfff,%eax
801016d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016db:	99                   	cltd   
801016dc:	c1 ea 1d             	shr    $0x1d,%edx
801016df:	01 d0                	add    %edx,%eax
801016e1:	83 e0 07             	and    $0x7,%eax
801016e4:	29 d0                	sub    %edx,%eax
801016e6:	ba 01 00 00 00       	mov    $0x1,%edx
801016eb:	89 c1                	mov    %eax,%ecx
801016ed:	d3 e2                	shl    %cl,%edx
801016ef:	89 d0                	mov    %edx,%eax
801016f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f7:	8d 50 07             	lea    0x7(%eax),%edx
801016fa:	85 c0                	test   %eax,%eax
801016fc:	0f 48 c2             	cmovs  %edx,%eax
801016ff:	c1 f8 03             	sar    $0x3,%eax
80101702:	89 c2                	mov    %eax,%edx
80101704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101707:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010170c:	0f b6 c0             	movzbl %al,%eax
8010170f:	23 45 ec             	and    -0x14(%ebp),%eax
80101712:	85 c0                	test   %eax,%eax
80101714:	75 0d                	jne    80101723 <bfree+0x91>
    panic("freeing free block");
80101716:	83 ec 0c             	sub    $0xc,%esp
80101719:	68 e2 a6 10 80       	push   $0x8010a6e2
8010171e:	e8 43 ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101726:	8d 50 07             	lea    0x7(%eax),%edx
80101729:	85 c0                	test   %eax,%eax
8010172b:	0f 48 c2             	cmovs  %edx,%eax
8010172e:	c1 f8 03             	sar    $0x3,%eax
80101731:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101734:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101739:	89 d1                	mov    %edx,%ecx
8010173b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010173e:	f7 d2                	not    %edx
80101740:	21 ca                	and    %ecx,%edx
80101742:	89 d1                	mov    %edx,%ecx
80101744:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101747:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010174b:	83 ec 0c             	sub    $0xc,%esp
8010174e:	ff 75 f4             	pushl  -0xc(%ebp)
80101751:	e8 90 23 00 00       	call   80103ae6 <log_write>
80101756:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101759:	83 ec 0c             	sub    $0xc,%esp
8010175c:	ff 75 f4             	pushl  -0xc(%ebp)
8010175f:	e8 ca ea ff ff       	call   8010022e <brelse>
80101764:	83 c4 10             	add    $0x10,%esp
}
80101767:	90                   	nop
80101768:	c9                   	leave  
80101769:	c3                   	ret    

8010176a <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010176a:	55                   	push   %ebp
8010176b:	89 e5                	mov    %esp,%ebp
8010176d:	57                   	push   %edi
8010176e:	56                   	push   %esi
8010176f:	53                   	push   %ebx
80101770:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101773:	83 ec 08             	sub    $0x8,%esp
80101776:	68 f5 a6 10 80       	push   $0x8010a6f5
8010177b:	68 60 42 11 80       	push   $0x80114260
80101780:	e8 a7 55 00 00       	call   80106d2c <initlock>
80101785:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101788:	83 ec 08             	sub    $0x8,%esp
8010178b:	68 40 42 11 80       	push   $0x80114240
80101790:	ff 75 08             	pushl  0x8(%ebp)
80101793:	e8 18 fd ff ff       	call   801014b0 <readsb>
80101798:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010179b:	a1 58 42 11 80       	mov    0x80114258,%eax
801017a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801017a3:	8b 3d 54 42 11 80    	mov    0x80114254,%edi
801017a9:	8b 35 50 42 11 80    	mov    0x80114250,%esi
801017af:	8b 1d 4c 42 11 80    	mov    0x8011424c,%ebx
801017b5:	8b 0d 48 42 11 80    	mov    0x80114248,%ecx
801017bb:	8b 15 44 42 11 80    	mov    0x80114244,%edx
801017c1:	a1 40 42 11 80       	mov    0x80114240,%eax
801017c6:	ff 75 e4             	pushl  -0x1c(%ebp)
801017c9:	57                   	push   %edi
801017ca:	56                   	push   %esi
801017cb:	53                   	push   %ebx
801017cc:	51                   	push   %ecx
801017cd:	52                   	push   %edx
801017ce:	50                   	push   %eax
801017cf:	68 fc a6 10 80       	push   $0x8010a6fc
801017d4:	e8 ed eb ff ff       	call   801003c6 <cprintf>
801017d9:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801017dc:	90                   	nop
801017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017e0:	5b                   	pop    %ebx
801017e1:	5e                   	pop    %esi
801017e2:	5f                   	pop    %edi
801017e3:	5d                   	pop    %ebp
801017e4:	c3                   	ret    

801017e5 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801017e5:	55                   	push   %ebp
801017e6:	89 e5                	mov    %esp,%ebp
801017e8:	83 ec 28             	sub    $0x28,%esp
801017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801017ee:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017f9:	e9 ba 00 00 00       	jmp    801018b8 <ialloc+0xd3>
    bp = bread(dev, IBLOCK(inum, sb));
801017fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101801:	c1 e8 03             	shr    $0x3,%eax
80101804:	89 c2                	mov    %eax,%edx
80101806:	a1 54 42 11 80       	mov    0x80114254,%eax
8010180b:	01 d0                	add    %edx,%eax
8010180d:	83 ec 08             	sub    $0x8,%esp
80101810:	50                   	push   %eax
80101811:	ff 75 08             	pushl  0x8(%ebp)
80101814:	e8 9d e9 ff ff       	call   801001b6 <bread>
80101819:	83 c4 10             	add    $0x10,%esp
8010181c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010181f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101822:	8d 50 18             	lea    0x18(%eax),%edx
80101825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101828:	83 e0 07             	and    $0x7,%eax
8010182b:	c1 e0 06             	shl    $0x6,%eax
8010182e:	01 d0                	add    %edx,%eax
80101830:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101833:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101836:	0f b7 00             	movzwl (%eax),%eax
80101839:	66 85 c0             	test   %ax,%ax
8010183c:	75 68                	jne    801018a6 <ialloc+0xc1>
      #ifdef CS333_P5
      dip->uid = UIDGID;
8010183e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101841:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
      dip->gid = UIDGID;
80101847:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010184a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
      dip->mode.asInt = MODE;
80101850:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101853:	c7 40 0c ed 01 00 00 	movl   $0x1ed,0xc(%eax)
      #endif
      memset(dip, 0, sizeof(*dip));
8010185a:	83 ec 04             	sub    $0x4,%esp
8010185d:	6a 40                	push   $0x40
8010185f:	6a 00                	push   $0x0
80101861:	ff 75 ec             	pushl  -0x14(%ebp)
80101864:	e8 48 57 00 00       	call   80106fb1 <memset>
80101869:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010186c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010186f:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101873:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101876:	83 ec 0c             	sub    $0xc,%esp
80101879:	ff 75 f0             	pushl  -0x10(%ebp)
8010187c:	e8 65 22 00 00       	call   80103ae6 <log_write>
80101881:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	ff 75 f0             	pushl  -0x10(%ebp)
8010188a:	e8 9f e9 ff ff       	call   8010022e <brelse>
8010188f:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101895:	83 ec 08             	sub    $0x8,%esp
80101898:	50                   	push   %eax
80101899:	ff 75 08             	pushl  0x8(%ebp)
8010189c:	e8 20 01 00 00       	call   801019c1 <iget>
801018a1:	83 c4 10             	add    $0x10,%esp
801018a4:	eb 30                	jmp    801018d6 <ialloc+0xf1>
    }
    brelse(bp);
801018a6:	83 ec 0c             	sub    $0xc,%esp
801018a9:	ff 75 f0             	pushl  -0x10(%ebp)
801018ac:	e8 7d e9 ff ff       	call   8010022e <brelse>
801018b1:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018b8:	8b 15 48 42 11 80    	mov    0x80114248,%edx
801018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c1:	39 c2                	cmp    %eax,%edx
801018c3:	0f 87 35 ff ff ff    	ja     801017fe <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018c9:	83 ec 0c             	sub    $0xc,%esp
801018cc:	68 4f a7 10 80       	push   $0x8010a74f
801018d1:	e8 90 ec ff ff       	call   80100566 <panic>
}
801018d6:	c9                   	leave  
801018d7:	c3                   	ret    

801018d8 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801018d8:	55                   	push   %ebp
801018d9:	89 e5                	mov    %esp,%ebp
801018db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018de:	8b 45 08             	mov    0x8(%ebp),%eax
801018e1:	8b 40 04             	mov    0x4(%eax),%eax
801018e4:	c1 e8 03             	shr    $0x3,%eax
801018e7:	89 c2                	mov    %eax,%edx
801018e9:	a1 54 42 11 80       	mov    0x80114254,%eax
801018ee:	01 c2                	add    %eax,%edx
801018f0:	8b 45 08             	mov    0x8(%ebp),%eax
801018f3:	8b 00                	mov    (%eax),%eax
801018f5:	83 ec 08             	sub    $0x8,%esp
801018f8:	52                   	push   %edx
801018f9:	50                   	push   %eax
801018fa:	e8 b7 e8 ff ff       	call   801001b6 <bread>
801018ff:	83 c4 10             	add    $0x10,%esp
80101902:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101908:	8d 50 18             	lea    0x18(%eax),%edx
8010190b:	8b 45 08             	mov    0x8(%ebp),%eax
8010190e:	8b 40 04             	mov    0x4(%eax),%eax
80101911:	83 e0 07             	and    $0x7,%eax
80101914:	c1 e0 06             	shl    $0x6,%eax
80101917:	01 d0                	add    %edx,%eax
80101919:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010191c:	8b 45 08             	mov    0x8(%ebp),%eax
8010191f:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101926:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101933:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101937:	8b 45 08             	mov    0x8(%ebp),%eax
8010193a:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101941:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010194c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	8b 50 20             	mov    0x20(%eax),%edx
80101959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195c:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  dip->uid = ip->uid;
8010195f:	8b 45 08             	mov    0x8(%ebp),%eax
80101962:	0f b7 50 18          	movzwl 0x18(%eax),%edx
80101966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101969:	66 89 50 08          	mov    %dx,0x8(%eax)
  dip->gid = ip->gid;
8010196d:	8b 45 08             	mov    0x8(%ebp),%eax
80101970:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
80101974:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101977:	66 89 50 0a          	mov    %dx,0xa(%eax)
  dip->mode.asInt = ip->mode.asInt;
8010197b:	8b 45 08             	mov    0x8(%ebp),%eax
8010197e:	8b 50 1c             	mov    0x1c(%eax),%edx
80101981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101984:	89 50 0c             	mov    %edx,0xc(%eax)
#endif
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101987:	8b 45 08             	mov    0x8(%ebp),%eax
8010198a:	8d 50 24             	lea    0x24(%eax),%edx
8010198d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101990:	83 c0 14             	add    $0x14,%eax
80101993:	83 ec 04             	sub    $0x4,%esp
80101996:	6a 2c                	push   $0x2c
80101998:	52                   	push   %edx
80101999:	50                   	push   %eax
8010199a:	e8 d1 56 00 00       	call   80107070 <memmove>
8010199f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019a2:	83 ec 0c             	sub    $0xc,%esp
801019a5:	ff 75 f4             	pushl  -0xc(%ebp)
801019a8:	e8 39 21 00 00       	call   80103ae6 <log_write>
801019ad:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	ff 75 f4             	pushl  -0xc(%ebp)
801019b6:	e8 73 e8 ff ff       	call   8010022e <brelse>
801019bb:	83 c4 10             	add    $0x10,%esp
}
801019be:	90                   	nop
801019bf:	c9                   	leave  
801019c0:	c3                   	ret    

801019c1 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019c1:	55                   	push   %ebp
801019c2:	89 e5                	mov    %esp,%ebp
801019c4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019c7:	83 ec 0c             	sub    $0xc,%esp
801019ca:	68 60 42 11 80       	push   $0x80114260
801019cf:	e8 7a 53 00 00       	call   80106d4e <acquire>
801019d4:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019de:	c7 45 f4 94 42 11 80 	movl   $0x80114294,-0xc(%ebp)
801019e5:	eb 5d                	jmp    80101a44 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ea:	8b 40 08             	mov    0x8(%eax),%eax
801019ed:	85 c0                	test   %eax,%eax
801019ef:	7e 39                	jle    80101a2a <iget+0x69>
801019f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f4:	8b 00                	mov    (%eax),%eax
801019f6:	3b 45 08             	cmp    0x8(%ebp),%eax
801019f9:	75 2f                	jne    80101a2a <iget+0x69>
801019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fe:	8b 40 04             	mov    0x4(%eax),%eax
80101a01:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a04:	75 24                	jne    80101a2a <iget+0x69>
      ip->ref++;
80101a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a09:	8b 40 08             	mov    0x8(%eax),%eax
80101a0c:	8d 50 01             	lea    0x1(%eax),%edx
80101a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a12:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a15:	83 ec 0c             	sub    $0xc,%esp
80101a18:	68 60 42 11 80       	push   $0x80114260
80101a1d:	e8 93 53 00 00       	call   80106db5 <release>
80101a22:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a28:	eb 74                	jmp    80101a9e <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a2e:	75 10                	jne    80101a40 <iget+0x7f>
80101a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a33:	8b 40 08             	mov    0x8(%eax),%eax
80101a36:	85 c0                	test   %eax,%eax
80101a38:	75 06                	jne    80101a40 <iget+0x7f>
      empty = ip;
80101a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a40:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101a44:	81 7d f4 34 52 11 80 	cmpl   $0x80115234,-0xc(%ebp)
80101a4b:	72 9a                	jb     801019e7 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a51:	75 0d                	jne    80101a60 <iget+0x9f>
    panic("iget: no inodes");
80101a53:	83 ec 0c             	sub    $0xc,%esp
80101a56:	68 61 a7 10 80       	push   $0x8010a761
80101a5b:	e8 06 eb ff ff       	call   80100566 <panic>

  ip = empty;
80101a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a69:	8b 55 08             	mov    0x8(%ebp),%edx
80101a6c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a71:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a74:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a84:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101a8b:	83 ec 0c             	sub    $0xc,%esp
80101a8e:	68 60 42 11 80       	push   $0x80114260
80101a93:	e8 1d 53 00 00       	call   80106db5 <release>
80101a98:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a9e:	c9                   	leave  
80101a9f:	c3                   	ret    

80101aa0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101aa0:	55                   	push   %ebp
80101aa1:	89 e5                	mov    %esp,%ebp
80101aa3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aa6:	83 ec 0c             	sub    $0xc,%esp
80101aa9:	68 60 42 11 80       	push   $0x80114260
80101aae:	e8 9b 52 00 00       	call   80106d4e <acquire>
80101ab3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab9:	8b 40 08             	mov    0x8(%eax),%eax
80101abc:	8d 50 01             	lea    0x1(%eax),%edx
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ac5:	83 ec 0c             	sub    $0xc,%esp
80101ac8:	68 60 42 11 80       	push   $0x80114260
80101acd:	e8 e3 52 00 00       	call   80106db5 <release>
80101ad2:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ad8:	c9                   	leave  
80101ad9:	c3                   	ret    

80101ada <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ada:	55                   	push   %ebp
80101adb:	89 e5                	mov    %esp,%ebp
80101add:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ae0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ae4:	74 0a                	je     80101af0 <ilock+0x16>
80101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae9:	8b 40 08             	mov    0x8(%eax),%eax
80101aec:	85 c0                	test   %eax,%eax
80101aee:	7f 0d                	jg     80101afd <ilock+0x23>
    panic("ilock");
80101af0:	83 ec 0c             	sub    $0xc,%esp
80101af3:	68 71 a7 10 80       	push   $0x8010a771
80101af8:	e8 69 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101afd:	83 ec 0c             	sub    $0xc,%esp
80101b00:	68 60 42 11 80       	push   $0x80114260
80101b05:	e8 44 52 00 00       	call   80106d4e <acquire>
80101b0a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101b0d:	eb 13                	jmp    80101b22 <ilock+0x48>
    sleep(ip, &icache.lock);
80101b0f:	83 ec 08             	sub    $0x8,%esp
80101b12:	68 60 42 11 80       	push   $0x80114260
80101b17:	ff 75 08             	pushl  0x8(%ebp)
80101b1a:	e8 1a 3f 00 00       	call   80105a39 <sleep>
80101b1f:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	8b 40 0c             	mov    0xc(%eax),%eax
80101b28:	83 e0 01             	and    $0x1,%eax
80101b2b:	85 c0                	test   %eax,%eax
80101b2d:	75 e0                	jne    80101b0f <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b32:	8b 40 0c             	mov    0xc(%eax),%eax
80101b35:	83 c8 01             	or     $0x1,%eax
80101b38:	89 c2                	mov    %eax,%edx
80101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3d:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101b40:	83 ec 0c             	sub    $0xc,%esp
80101b43:	68 60 42 11 80       	push   $0x80114260
80101b48:	e8 68 52 00 00       	call   80106db5 <release>
80101b4d:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 0c             	mov    0xc(%eax),%eax
80101b56:	83 e0 02             	and    $0x2,%eax
80101b59:	85 c0                	test   %eax,%eax
80101b5b:	0f 85 fc 00 00 00    	jne    80101c5d <ilock+0x183>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	8b 40 04             	mov    0x4(%eax),%eax
80101b67:	c1 e8 03             	shr    $0x3,%eax
80101b6a:	89 c2                	mov    %eax,%edx
80101b6c:	a1 54 42 11 80       	mov    0x80114254,%eax
80101b71:	01 c2                	add    %eax,%edx
80101b73:	8b 45 08             	mov    0x8(%ebp),%eax
80101b76:	8b 00                	mov    (%eax),%eax
80101b78:	83 ec 08             	sub    $0x8,%esp
80101b7b:	52                   	push   %edx
80101b7c:	50                   	push   %eax
80101b7d:	e8 34 e6 ff ff       	call   801001b6 <bread>
80101b82:	83 c4 10             	add    $0x10,%esp
80101b85:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8b:	8d 50 18             	lea    0x18(%eax),%edx
80101b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b91:	8b 40 04             	mov    0x4(%eax),%eax
80101b94:	83 e0 07             	and    $0x7,%eax
80101b97:	c1 e0 06             	shl    $0x6,%eax
80101b9a:	01 d0                	add    %edx,%eax
80101b9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba2:	0f b7 10             	movzwl (%eax),%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101baf:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb6:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bbd:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc4:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcb:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd2:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd9:	8b 50 10             	mov    0x10(%eax),%edx
80101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdf:	89 50 20             	mov    %edx,0x20(%eax)
#ifdef CS333_P5
    ip->uid = dip->uid;
80101be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be5:	0f b7 50 08          	movzwl 0x8(%eax),%edx
80101be9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bec:	66 89 50 18          	mov    %dx,0x18(%eax)
    ip->gid = dip->gid;
80101bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf3:	0f b7 50 0a          	movzwl 0xa(%eax),%edx
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	66 89 50 1a          	mov    %dx,0x1a(%eax)
    ip->mode.asInt = dip->mode.asInt;
80101bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c01:	8b 50 0c             	mov    0xc(%eax),%edx
80101c04:	8b 45 08             	mov    0x8(%ebp),%eax
80101c07:	89 50 1c             	mov    %edx,0x1c(%eax)
#endif
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0d:	8d 50 14             	lea    0x14(%eax),%edx
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	83 c0 24             	add    $0x24,%eax
80101c16:	83 ec 04             	sub    $0x4,%esp
80101c19:	6a 2c                	push   $0x2c
80101c1b:	52                   	push   %edx
80101c1c:	50                   	push   %eax
80101c1d:	e8 4e 54 00 00       	call   80107070 <memmove>
80101c22:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c25:	83 ec 0c             	sub    $0xc,%esp
80101c28:	ff 75 f4             	pushl  -0xc(%ebp)
80101c2b:	e8 fe e5 ff ff       	call   8010022e <brelse>
80101c30:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	8b 40 0c             	mov    0xc(%eax),%eax
80101c39:	83 c8 02             	or     $0x2,%eax
80101c3c:	89 c2                	mov    %eax,%edx
80101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c41:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101c44:	8b 45 08             	mov    0x8(%ebp),%eax
80101c47:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101c4b:	66 85 c0             	test   %ax,%ax
80101c4e:	75 0d                	jne    80101c5d <ilock+0x183>
      panic("ilock: no type");
80101c50:	83 ec 0c             	sub    $0xc,%esp
80101c53:	68 77 a7 10 80       	push   $0x8010a777
80101c58:	e8 09 e9 ff ff       	call   80100566 <panic>
  }
}
80101c5d:	90                   	nop
80101c5e:	c9                   	leave  
80101c5f:	c3                   	ret    

80101c60 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c60:	55                   	push   %ebp
80101c61:	89 e5                	mov    %esp,%ebp
80101c63:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101c66:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c6a:	74 17                	je     80101c83 <iunlock+0x23>
80101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6f:	8b 40 0c             	mov    0xc(%eax),%eax
80101c72:	83 e0 01             	and    $0x1,%eax
80101c75:	85 c0                	test   %eax,%eax
80101c77:	74 0a                	je     80101c83 <iunlock+0x23>
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	8b 40 08             	mov    0x8(%eax),%eax
80101c7f:	85 c0                	test   %eax,%eax
80101c81:	7f 0d                	jg     80101c90 <iunlock+0x30>
    panic("iunlock");
80101c83:	83 ec 0c             	sub    $0xc,%esp
80101c86:	68 86 a7 10 80       	push   $0x8010a786
80101c8b:	e8 d6 e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c90:	83 ec 0c             	sub    $0xc,%esp
80101c93:	68 60 42 11 80       	push   $0x80114260
80101c98:	e8 b1 50 00 00       	call   80106d4e <acquire>
80101c9d:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	8b 40 0c             	mov    0xc(%eax),%eax
80101ca6:	83 e0 fe             	and    $0xfffffffe,%eax
80101ca9:	89 c2                	mov    %eax,%edx
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101cb1:	83 ec 0c             	sub    $0xc,%esp
80101cb4:	ff 75 08             	pushl  0x8(%ebp)
80101cb7:	e8 8d 3f 00 00       	call   80105c49 <wakeup>
80101cbc:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101cbf:	83 ec 0c             	sub    $0xc,%esp
80101cc2:	68 60 42 11 80       	push   $0x80114260
80101cc7:	e8 e9 50 00 00       	call   80106db5 <release>
80101ccc:	83 c4 10             	add    $0x10,%esp
}
80101ccf:	90                   	nop
80101cd0:	c9                   	leave  
80101cd1:	c3                   	ret    

80101cd2 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cd2:	55                   	push   %ebp
80101cd3:	89 e5                	mov    %esp,%ebp
80101cd5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101cd8:	83 ec 0c             	sub    $0xc,%esp
80101cdb:	68 60 42 11 80       	push   $0x80114260
80101ce0:	e8 69 50 00 00       	call   80106d4e <acquire>
80101ce5:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ceb:	8b 40 08             	mov    0x8(%eax),%eax
80101cee:	83 f8 01             	cmp    $0x1,%eax
80101cf1:	0f 85 a9 00 00 00    	jne    80101da0 <iput+0xce>
80101cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfa:	8b 40 0c             	mov    0xc(%eax),%eax
80101cfd:	83 e0 02             	and    $0x2,%eax
80101d00:	85 c0                	test   %eax,%eax
80101d02:	0f 84 98 00 00 00    	je     80101da0 <iput+0xce>
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d0f:	66 85 c0             	test   %ax,%ax
80101d12:	0f 85 88 00 00 00    	jne    80101da0 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 40 0c             	mov    0xc(%eax),%eax
80101d1e:	83 e0 01             	and    $0x1,%eax
80101d21:	85 c0                	test   %eax,%eax
80101d23:	74 0d                	je     80101d32 <iput+0x60>
      panic("iput busy");
80101d25:	83 ec 0c             	sub    $0xc,%esp
80101d28:	68 8e a7 10 80       	push   $0x8010a78e
80101d2d:	e8 34 e8 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101d32:	8b 45 08             	mov    0x8(%ebp),%eax
80101d35:	8b 40 0c             	mov    0xc(%eax),%eax
80101d38:	83 c8 01             	or     $0x1,%eax
80101d3b:	89 c2                	mov    %eax,%edx
80101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d40:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d43:	83 ec 0c             	sub    $0xc,%esp
80101d46:	68 60 42 11 80       	push   $0x80114260
80101d4b:	e8 65 50 00 00       	call   80106db5 <release>
80101d50:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101d53:	83 ec 0c             	sub    $0xc,%esp
80101d56:	ff 75 08             	pushl  0x8(%ebp)
80101d59:	e8 a8 01 00 00       	call   80101f06 <itrunc>
80101d5e:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101d61:	8b 45 08             	mov    0x8(%ebp),%eax
80101d64:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101d6a:	83 ec 0c             	sub    $0xc,%esp
80101d6d:	ff 75 08             	pushl  0x8(%ebp)
80101d70:	e8 63 fb ff ff       	call   801018d8 <iupdate>
80101d75:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	68 60 42 11 80       	push   $0x80114260
80101d80:	e8 c9 4f 00 00       	call   80106d4e <acquire>
80101d85:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101d92:	83 ec 0c             	sub    $0xc,%esp
80101d95:	ff 75 08             	pushl  0x8(%ebp)
80101d98:	e8 ac 3e 00 00       	call   80105c49 <wakeup>
80101d9d:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	8b 40 08             	mov    0x8(%eax),%eax
80101da6:	8d 50 ff             	lea    -0x1(%eax),%edx
80101da9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dac:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101daf:	83 ec 0c             	sub    $0xc,%esp
80101db2:	68 60 42 11 80       	push   $0x80114260
80101db7:	e8 f9 4f 00 00       	call   80106db5 <release>
80101dbc:	83 c4 10             	add    $0x10,%esp
}
80101dbf:	90                   	nop
80101dc0:	c9                   	leave  
80101dc1:	c3                   	ret    

80101dc2 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dc2:	55                   	push   %ebp
80101dc3:	89 e5                	mov    %esp,%ebp
80101dc5:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101dc8:	83 ec 0c             	sub    $0xc,%esp
80101dcb:	ff 75 08             	pushl  0x8(%ebp)
80101dce:	e8 8d fe ff ff       	call   80101c60 <iunlock>
80101dd3:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 08             	pushl  0x8(%ebp)
80101ddc:	e8 f1 fe ff ff       	call   80101cd2 <iput>
80101de1:	83 c4 10             	add    $0x10,%esp
}
80101de4:	90                   	nop
80101de5:	c9                   	leave  
80101de6:	c3                   	ret    

80101de7 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101de7:	55                   	push   %ebp
80101de8:	89 e5                	mov    %esp,%ebp
80101dea:	53                   	push   %ebx
80101deb:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101dee:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
80101df2:	77 42                	ja     80101e36 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dfa:	83 c2 08             	add    $0x8,%edx
80101dfd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e08:	75 24                	jne    80101e2e <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	8b 00                	mov    (%eax),%eax
80101e0f:	83 ec 0c             	sub    $0xc,%esp
80101e12:	50                   	push   %eax
80101e13:	e8 2e f7 ff ff       	call   80101546 <balloc>
80101e18:	83 c4 10             	add    $0x10,%esp
80101e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e21:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e24:	8d 4a 08             	lea    0x8(%edx),%ecx
80101e27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e2a:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
    return addr;
80101e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e31:	e9 cb 00 00 00       	jmp    80101f01 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101e36:	83 6d 0c 0a          	subl   $0xa,0xc(%ebp)

  if(bn < NINDIRECT){
80101e3a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e3e:	0f 87 b0 00 00 00    	ja     80101ef4 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e51:	75 1d                	jne    80101e70 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e53:	8b 45 08             	mov    0x8(%ebp),%eax
80101e56:	8b 00                	mov    (%eax),%eax
80101e58:	83 ec 0c             	sub    $0xc,%esp
80101e5b:	50                   	push   %eax
80101e5c:	e8 e5 f6 ff ff       	call   80101546 <balloc>
80101e61:	83 c4 10             	add    $0x10,%esp
80101e64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6d:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	8b 00                	mov    (%eax),%eax
80101e75:	83 ec 08             	sub    $0x8,%esp
80101e78:	ff 75 f4             	pushl  -0xc(%ebp)
80101e7b:	50                   	push   %eax
80101e7c:	e8 35 e3 ff ff       	call   801001b6 <bread>
80101e81:	83 c4 10             	add    $0x10,%esp
80101e84:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8a:	83 c0 18             	add    $0x18,%eax
80101e8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e90:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e9d:	01 d0                	add    %edx,%eax
80101e9f:	8b 00                	mov    (%eax),%eax
80101ea1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ea4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ea8:	75 37                	jne    80101ee1 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ead:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb7:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	8b 00                	mov    (%eax),%eax
80101ebf:	83 ec 0c             	sub    $0xc,%esp
80101ec2:	50                   	push   %eax
80101ec3:	e8 7e f6 ff ff       	call   80101546 <balloc>
80101ec8:	83 c4 10             	add    $0x10,%esp
80101ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed1:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ed3:	83 ec 0c             	sub    $0xc,%esp
80101ed6:	ff 75 f0             	pushl  -0x10(%ebp)
80101ed9:	e8 08 1c 00 00       	call   80103ae6 <log_write>
80101ede:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ee1:	83 ec 0c             	sub    $0xc,%esp
80101ee4:	ff 75 f0             	pushl  -0x10(%ebp)
80101ee7:	e8 42 e3 ff ff       	call   8010022e <brelse>
80101eec:	83 c4 10             	add    $0x10,%esp
    return addr;
80101eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef2:	eb 0d                	jmp    80101f01 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101ef4:	83 ec 0c             	sub    $0xc,%esp
80101ef7:	68 98 a7 10 80       	push   $0x8010a798
80101efc:	e8 65 e6 ff ff       	call   80100566 <panic>
}
80101f01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f04:	c9                   	leave  
80101f05:	c3                   	ret    

80101f06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f13:	eb 45                	jmp    80101f5a <itrunc+0x54>
    if(ip->addrs[i]){
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f1b:	83 c2 08             	add    $0x8,%edx
80101f1e:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101f22:	85 c0                	test   %eax,%eax
80101f24:	74 30                	je     80101f56 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101f26:	8b 45 08             	mov    0x8(%ebp),%eax
80101f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f2c:	83 c2 08             	add    $0x8,%edx
80101f2f:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101f33:	8b 55 08             	mov    0x8(%ebp),%edx
80101f36:	8b 12                	mov    (%edx),%edx
80101f38:	83 ec 08             	sub    $0x8,%esp
80101f3b:	50                   	push   %eax
80101f3c:	52                   	push   %edx
80101f3d:	e8 50 f7 ff ff       	call   80101692 <bfree>
80101f42:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f4b:	83 c2 08             	add    $0x8,%edx
80101f4e:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
80101f55:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f5a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80101f5e:	7e b5                	jle    80101f15 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f66:	85 c0                	test   %eax,%eax
80101f68:	0f 84 a1 00 00 00    	je     8010200f <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f71:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f74:	8b 45 08             	mov    0x8(%ebp),%eax
80101f77:	8b 00                	mov    (%eax),%eax
80101f79:	83 ec 08             	sub    $0x8,%esp
80101f7c:	52                   	push   %edx
80101f7d:	50                   	push   %eax
80101f7e:	e8 33 e2 ff ff       	call   801001b6 <bread>
80101f83:	83 c4 10             	add    $0x10,%esp
80101f86:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f8c:	83 c0 18             	add    $0x18,%eax
80101f8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f92:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f99:	eb 3c                	jmp    80101fd7 <itrunc+0xd1>
      if(a[j])
80101f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fa8:	01 d0                	add    %edx,%eax
80101faa:	8b 00                	mov    (%eax),%eax
80101fac:	85 c0                	test   %eax,%eax
80101fae:	74 23                	je     80101fd3 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fbd:	01 d0                	add    %edx,%eax
80101fbf:	8b 00                	mov    (%eax),%eax
80101fc1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc4:	8b 12                	mov    (%edx),%edx
80101fc6:	83 ec 08             	sub    $0x8,%esp
80101fc9:	50                   	push   %eax
80101fca:	52                   	push   %edx
80101fcb:	e8 c2 f6 ff ff       	call   80101692 <bfree>
80101fd0:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fd3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fda:	83 f8 7f             	cmp    $0x7f,%eax
80101fdd:	76 bc                	jbe    80101f9b <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101fdf:	83 ec 0c             	sub    $0xc,%esp
80101fe2:	ff 75 ec             	pushl  -0x14(%ebp)
80101fe5:	e8 44 e2 ff ff       	call   8010022e <brelse>
80101fea:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fed:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ff3:	8b 55 08             	mov    0x8(%ebp),%edx
80101ff6:	8b 12                	mov    (%edx),%edx
80101ff8:	83 ec 08             	sub    $0x8,%esp
80101ffb:	50                   	push   %eax
80101ffc:	52                   	push   %edx
80101ffd:	e8 90 f6 ff ff       	call   80101692 <bfree>
80102002:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  iupdate(ip);
80102019:	83 ec 0c             	sub    $0xc,%esp
8010201c:	ff 75 08             	pushl  0x8(%ebp)
8010201f:	e8 b4 f8 ff ff       	call   801018d8 <iupdate>
80102024:	83 c4 10             	add    $0x10,%esp
}
80102027:	90                   	nop
80102028:	c9                   	leave  
80102029:	c3                   	ret    

8010202a <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
8010202a:	55                   	push   %ebp
8010202b:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010202d:	8b 45 08             	mov    0x8(%ebp),%eax
80102030:	8b 00                	mov    (%eax),%eax
80102032:	89 c2                	mov    %eax,%edx
80102034:	8b 45 0c             	mov    0xc(%ebp),%eax
80102037:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010203a:	8b 45 08             	mov    0x8(%ebp),%eax
8010203d:	8b 50 04             	mov    0x4(%eax),%edx
80102040:	8b 45 0c             	mov    0xc(%ebp),%eax
80102043:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010204d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102050:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102053:	8b 45 08             	mov    0x8(%ebp),%eax
80102056:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010205a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205d:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	8b 50 20             	mov    0x20(%eax),%edx
80102067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206a:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  st->uid = ip->uid;
8010206d:	8b 45 08             	mov    0x8(%ebp),%eax
80102070:	0f b7 50 18          	movzwl 0x18(%eax),%edx
80102074:	8b 45 0c             	mov    0xc(%ebp),%eax
80102077:	66 89 50 14          	mov    %dx,0x14(%eax)
  st->gid = ip->gid;
8010207b:	8b 45 08             	mov    0x8(%ebp),%eax
8010207e:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
80102082:	8b 45 0c             	mov    0xc(%ebp),%eax
80102085:	66 89 50 16          	mov    %dx,0x16(%eax)
  st->mode.asInt = ip->mode.asInt;
80102089:	8b 45 08             	mov    0x8(%ebp),%eax
8010208c:	8b 50 1c             	mov    0x1c(%eax),%edx
8010208f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102092:	89 50 18             	mov    %edx,0x18(%eax)
#endif
}
80102095:	90                   	nop
80102096:	5d                   	pop    %ebp
80102097:	c3                   	ret    

80102098 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102098:	55                   	push   %ebp
80102099:	89 e5                	mov    %esp,%ebp
8010209b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020a5:	66 83 f8 03          	cmp    $0x3,%ax
801020a9:	75 5c                	jne    80102107 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020ab:	8b 45 08             	mov    0x8(%ebp),%eax
801020ae:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020b2:	66 85 c0             	test   %ax,%ax
801020b5:	78 20                	js     801020d7 <readi+0x3f>
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020be:	66 83 f8 09          	cmp    $0x9,%ax
801020c2:	7f 13                	jg     801020d7 <readi+0x3f>
801020c4:	8b 45 08             	mov    0x8(%ebp),%eax
801020c7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020cb:	98                   	cwtl   
801020cc:	8b 04 c5 e0 41 11 80 	mov    -0x7feebe20(,%eax,8),%eax
801020d3:	85 c0                	test   %eax,%eax
801020d5:	75 0a                	jne    801020e1 <readi+0x49>
      return -1;
801020d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020dc:	e9 0c 01 00 00       	jmp    801021ed <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
801020e1:	8b 45 08             	mov    0x8(%ebp),%eax
801020e4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e8:	98                   	cwtl   
801020e9:	8b 04 c5 e0 41 11 80 	mov    -0x7feebe20(,%eax,8),%eax
801020f0:	8b 55 14             	mov    0x14(%ebp),%edx
801020f3:	83 ec 04             	sub    $0x4,%esp
801020f6:	52                   	push   %edx
801020f7:	ff 75 0c             	pushl  0xc(%ebp)
801020fa:	ff 75 08             	pushl  0x8(%ebp)
801020fd:	ff d0                	call   *%eax
801020ff:	83 c4 10             	add    $0x10,%esp
80102102:	e9 e6 00 00 00       	jmp    801021ed <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102107:	8b 45 08             	mov    0x8(%ebp),%eax
8010210a:	8b 40 20             	mov    0x20(%eax),%eax
8010210d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102110:	72 0d                	jb     8010211f <readi+0x87>
80102112:	8b 55 10             	mov    0x10(%ebp),%edx
80102115:	8b 45 14             	mov    0x14(%ebp),%eax
80102118:	01 d0                	add    %edx,%eax
8010211a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010211d:	73 0a                	jae    80102129 <readi+0x91>
    return -1;
8010211f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102124:	e9 c4 00 00 00       	jmp    801021ed <readi+0x155>
  if(off + n > ip->size)
80102129:	8b 55 10             	mov    0x10(%ebp),%edx
8010212c:	8b 45 14             	mov    0x14(%ebp),%eax
8010212f:	01 c2                	add    %eax,%edx
80102131:	8b 45 08             	mov    0x8(%ebp),%eax
80102134:	8b 40 20             	mov    0x20(%eax),%eax
80102137:	39 c2                	cmp    %eax,%edx
80102139:	76 0c                	jbe    80102147 <readi+0xaf>
    n = ip->size - off;
8010213b:	8b 45 08             	mov    0x8(%ebp),%eax
8010213e:	8b 40 20             	mov    0x20(%eax),%eax
80102141:	2b 45 10             	sub    0x10(%ebp),%eax
80102144:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102147:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010214e:	e9 8b 00 00 00       	jmp    801021de <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102153:	8b 45 10             	mov    0x10(%ebp),%eax
80102156:	c1 e8 09             	shr    $0x9,%eax
80102159:	83 ec 08             	sub    $0x8,%esp
8010215c:	50                   	push   %eax
8010215d:	ff 75 08             	pushl  0x8(%ebp)
80102160:	e8 82 fc ff ff       	call   80101de7 <bmap>
80102165:	83 c4 10             	add    $0x10,%esp
80102168:	89 c2                	mov    %eax,%edx
8010216a:	8b 45 08             	mov    0x8(%ebp),%eax
8010216d:	8b 00                	mov    (%eax),%eax
8010216f:	83 ec 08             	sub    $0x8,%esp
80102172:	52                   	push   %edx
80102173:	50                   	push   %eax
80102174:	e8 3d e0 ff ff       	call   801001b6 <bread>
80102179:	83 c4 10             	add    $0x10,%esp
8010217c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010217f:	8b 45 10             	mov    0x10(%ebp),%eax
80102182:	25 ff 01 00 00       	and    $0x1ff,%eax
80102187:	ba 00 02 00 00       	mov    $0x200,%edx
8010218c:	29 c2                	sub    %eax,%edx
8010218e:	8b 45 14             	mov    0x14(%ebp),%eax
80102191:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102194:	39 c2                	cmp    %eax,%edx
80102196:	0f 46 c2             	cmovbe %edx,%eax
80102199:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010219c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010219f:	8d 50 18             	lea    0x18(%eax),%edx
801021a2:	8b 45 10             	mov    0x10(%ebp),%eax
801021a5:	25 ff 01 00 00       	and    $0x1ff,%eax
801021aa:	01 d0                	add    %edx,%eax
801021ac:	83 ec 04             	sub    $0x4,%esp
801021af:	ff 75 ec             	pushl  -0x14(%ebp)
801021b2:	50                   	push   %eax
801021b3:	ff 75 0c             	pushl  0xc(%ebp)
801021b6:	e8 b5 4e 00 00       	call   80107070 <memmove>
801021bb:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021be:	83 ec 0c             	sub    $0xc,%esp
801021c1:	ff 75 f0             	pushl  -0x10(%ebp)
801021c4:	e8 65 e0 ff ff       	call   8010022e <brelse>
801021c9:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021cf:	01 45 f4             	add    %eax,-0xc(%ebp)
801021d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d5:	01 45 10             	add    %eax,0x10(%ebp)
801021d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021db:	01 45 0c             	add    %eax,0xc(%ebp)
801021de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021e1:	3b 45 14             	cmp    0x14(%ebp),%eax
801021e4:	0f 82 69 ff ff ff    	jb     80102153 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801021ea:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021ed:	c9                   	leave  
801021ee:	c3                   	ret    

801021ef <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021ef:	55                   	push   %ebp
801021f0:	89 e5                	mov    %esp,%ebp
801021f2:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021f5:	8b 45 08             	mov    0x8(%ebp),%eax
801021f8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021fc:	66 83 f8 03          	cmp    $0x3,%ax
80102200:	75 5c                	jne    8010225e <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102202:	8b 45 08             	mov    0x8(%ebp),%eax
80102205:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102209:	66 85 c0             	test   %ax,%ax
8010220c:	78 20                	js     8010222e <writei+0x3f>
8010220e:	8b 45 08             	mov    0x8(%ebp),%eax
80102211:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102215:	66 83 f8 09          	cmp    $0x9,%ax
80102219:	7f 13                	jg     8010222e <writei+0x3f>
8010221b:	8b 45 08             	mov    0x8(%ebp),%eax
8010221e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102222:	98                   	cwtl   
80102223:	8b 04 c5 e4 41 11 80 	mov    -0x7feebe1c(,%eax,8),%eax
8010222a:	85 c0                	test   %eax,%eax
8010222c:	75 0a                	jne    80102238 <writei+0x49>
      return -1;
8010222e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102233:	e9 3d 01 00 00       	jmp    80102375 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102238:	8b 45 08             	mov    0x8(%ebp),%eax
8010223b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010223f:	98                   	cwtl   
80102240:	8b 04 c5 e4 41 11 80 	mov    -0x7feebe1c(,%eax,8),%eax
80102247:	8b 55 14             	mov    0x14(%ebp),%edx
8010224a:	83 ec 04             	sub    $0x4,%esp
8010224d:	52                   	push   %edx
8010224e:	ff 75 0c             	pushl  0xc(%ebp)
80102251:	ff 75 08             	pushl  0x8(%ebp)
80102254:	ff d0                	call   *%eax
80102256:	83 c4 10             	add    $0x10,%esp
80102259:	e9 17 01 00 00       	jmp    80102375 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010225e:	8b 45 08             	mov    0x8(%ebp),%eax
80102261:	8b 40 20             	mov    0x20(%eax),%eax
80102264:	3b 45 10             	cmp    0x10(%ebp),%eax
80102267:	72 0d                	jb     80102276 <writei+0x87>
80102269:	8b 55 10             	mov    0x10(%ebp),%edx
8010226c:	8b 45 14             	mov    0x14(%ebp),%eax
8010226f:	01 d0                	add    %edx,%eax
80102271:	3b 45 10             	cmp    0x10(%ebp),%eax
80102274:	73 0a                	jae    80102280 <writei+0x91>
    return -1;
80102276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010227b:	e9 f5 00 00 00       	jmp    80102375 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102280:	8b 55 10             	mov    0x10(%ebp),%edx
80102283:	8b 45 14             	mov    0x14(%ebp),%eax
80102286:	01 d0                	add    %edx,%eax
80102288:	3d 00 14 01 00       	cmp    $0x11400,%eax
8010228d:	76 0a                	jbe    80102299 <writei+0xaa>
    return -1;
8010228f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102294:	e9 dc 00 00 00       	jmp    80102375 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102299:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a0:	e9 99 00 00 00       	jmp    8010233e <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022a5:	8b 45 10             	mov    0x10(%ebp),%eax
801022a8:	c1 e8 09             	shr    $0x9,%eax
801022ab:	83 ec 08             	sub    $0x8,%esp
801022ae:	50                   	push   %eax
801022af:	ff 75 08             	pushl  0x8(%ebp)
801022b2:	e8 30 fb ff ff       	call   80101de7 <bmap>
801022b7:	83 c4 10             	add    $0x10,%esp
801022ba:	89 c2                	mov    %eax,%edx
801022bc:	8b 45 08             	mov    0x8(%ebp),%eax
801022bf:	8b 00                	mov    (%eax),%eax
801022c1:	83 ec 08             	sub    $0x8,%esp
801022c4:	52                   	push   %edx
801022c5:	50                   	push   %eax
801022c6:	e8 eb de ff ff       	call   801001b6 <bread>
801022cb:	83 c4 10             	add    $0x10,%esp
801022ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022d1:	8b 45 10             	mov    0x10(%ebp),%eax
801022d4:	25 ff 01 00 00       	and    $0x1ff,%eax
801022d9:	ba 00 02 00 00       	mov    $0x200,%edx
801022de:	29 c2                	sub    %eax,%edx
801022e0:	8b 45 14             	mov    0x14(%ebp),%eax
801022e3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022e6:	39 c2                	cmp    %eax,%edx
801022e8:	0f 46 c2             	cmovbe %edx,%eax
801022eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022f1:	8d 50 18             	lea    0x18(%eax),%edx
801022f4:	8b 45 10             	mov    0x10(%ebp),%eax
801022f7:	25 ff 01 00 00       	and    $0x1ff,%eax
801022fc:	01 d0                	add    %edx,%eax
801022fe:	83 ec 04             	sub    $0x4,%esp
80102301:	ff 75 ec             	pushl  -0x14(%ebp)
80102304:	ff 75 0c             	pushl  0xc(%ebp)
80102307:	50                   	push   %eax
80102308:	e8 63 4d 00 00       	call   80107070 <memmove>
8010230d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102310:	83 ec 0c             	sub    $0xc,%esp
80102313:	ff 75 f0             	pushl  -0x10(%ebp)
80102316:	e8 cb 17 00 00       	call   80103ae6 <log_write>
8010231b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010231e:	83 ec 0c             	sub    $0xc,%esp
80102321:	ff 75 f0             	pushl  -0x10(%ebp)
80102324:	e8 05 df ff ff       	call   8010022e <brelse>
80102329:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010232c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010232f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102332:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102335:	01 45 10             	add    %eax,0x10(%ebp)
80102338:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233b:	01 45 0c             	add    %eax,0xc(%ebp)
8010233e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102341:	3b 45 14             	cmp    0x14(%ebp),%eax
80102344:	0f 82 5b ff ff ff    	jb     801022a5 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010234a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010234e:	74 22                	je     80102372 <writei+0x183>
80102350:	8b 45 08             	mov    0x8(%ebp),%eax
80102353:	8b 40 20             	mov    0x20(%eax),%eax
80102356:	3b 45 10             	cmp    0x10(%ebp),%eax
80102359:	73 17                	jae    80102372 <writei+0x183>
    ip->size = off;
8010235b:	8b 45 08             	mov    0x8(%ebp),%eax
8010235e:	8b 55 10             	mov    0x10(%ebp),%edx
80102361:	89 50 20             	mov    %edx,0x20(%eax)
    iupdate(ip);
80102364:	83 ec 0c             	sub    $0xc,%esp
80102367:	ff 75 08             	pushl  0x8(%ebp)
8010236a:	e8 69 f5 ff ff       	call   801018d8 <iupdate>
8010236f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102372:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102375:	c9                   	leave  
80102376:	c3                   	ret    

80102377 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102377:	55                   	push   %ebp
80102378:	89 e5                	mov    %esp,%ebp
8010237a:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010237d:	83 ec 04             	sub    $0x4,%esp
80102380:	6a 0e                	push   $0xe
80102382:	ff 75 0c             	pushl  0xc(%ebp)
80102385:	ff 75 08             	pushl  0x8(%ebp)
80102388:	e8 79 4d 00 00       	call   80107106 <strncmp>
8010238d:	83 c4 10             	add    $0x10,%esp
}
80102390:	c9                   	leave  
80102391:	c3                   	ret    

80102392 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102392:	55                   	push   %ebp
80102393:	89 e5                	mov    %esp,%ebp
80102395:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102398:	8b 45 08             	mov    0x8(%ebp),%eax
8010239b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010239f:	66 83 f8 01          	cmp    $0x1,%ax
801023a3:	74 0d                	je     801023b2 <dirlookup+0x20>
    panic("dirlookup not DIR");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 ab a7 10 80       	push   $0x8010a7ab
801023ad:	e8 b4 e1 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b9:	eb 7b                	jmp    80102436 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023bb:	6a 10                	push   $0x10
801023bd:	ff 75 f4             	pushl  -0xc(%ebp)
801023c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c3:	50                   	push   %eax
801023c4:	ff 75 08             	pushl  0x8(%ebp)
801023c7:	e8 cc fc ff ff       	call   80102098 <readi>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	83 f8 10             	cmp    $0x10,%eax
801023d2:	74 0d                	je     801023e1 <dirlookup+0x4f>
      panic("dirlink read");
801023d4:	83 ec 0c             	sub    $0xc,%esp
801023d7:	68 bd a7 10 80       	push   $0x8010a7bd
801023dc:	e8 85 e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801023e1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023e5:	66 85 c0             	test   %ax,%ax
801023e8:	74 47                	je     80102431 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801023ea:	83 ec 08             	sub    $0x8,%esp
801023ed:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f0:	83 c0 02             	add    $0x2,%eax
801023f3:	50                   	push   %eax
801023f4:	ff 75 0c             	pushl  0xc(%ebp)
801023f7:	e8 7b ff ff ff       	call   80102377 <namecmp>
801023fc:	83 c4 10             	add    $0x10,%esp
801023ff:	85 c0                	test   %eax,%eax
80102401:	75 2f                	jne    80102432 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102403:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102407:	74 08                	je     80102411 <dirlookup+0x7f>
        *poff = off;
80102409:	8b 45 10             	mov    0x10(%ebp),%eax
8010240c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010240f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102411:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102415:	0f b7 c0             	movzwl %ax,%eax
80102418:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	8b 00                	mov    (%eax),%eax
80102420:	83 ec 08             	sub    $0x8,%esp
80102423:	ff 75 f0             	pushl  -0x10(%ebp)
80102426:	50                   	push   %eax
80102427:	e8 95 f5 ff ff       	call   801019c1 <iget>
8010242c:	83 c4 10             	add    $0x10,%esp
8010242f:	eb 19                	jmp    8010244a <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102431:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102432:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102436:	8b 45 08             	mov    0x8(%ebp),%eax
80102439:	8b 40 20             	mov    0x20(%eax),%eax
8010243c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010243f:	0f 87 76 ff ff ff    	ja     801023bb <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102445:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010244a:	c9                   	leave  
8010244b:	c3                   	ret    

8010244c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010244c:	55                   	push   %ebp
8010244d:	89 e5                	mov    %esp,%ebp
8010244f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102452:	83 ec 04             	sub    $0x4,%esp
80102455:	6a 00                	push   $0x0
80102457:	ff 75 0c             	pushl  0xc(%ebp)
8010245a:	ff 75 08             	pushl  0x8(%ebp)
8010245d:	e8 30 ff ff ff       	call   80102392 <dirlookup>
80102462:	83 c4 10             	add    $0x10,%esp
80102465:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102468:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010246c:	74 18                	je     80102486 <dirlink+0x3a>
    iput(ip);
8010246e:	83 ec 0c             	sub    $0xc,%esp
80102471:	ff 75 f0             	pushl  -0x10(%ebp)
80102474:	e8 59 f8 ff ff       	call   80101cd2 <iput>
80102479:	83 c4 10             	add    $0x10,%esp
    return -1;
8010247c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102481:	e9 9c 00 00 00       	jmp    80102522 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102486:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010248d:	eb 39                	jmp    801024c8 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010248f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102492:	6a 10                	push   $0x10
80102494:	50                   	push   %eax
80102495:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102498:	50                   	push   %eax
80102499:	ff 75 08             	pushl  0x8(%ebp)
8010249c:	e8 f7 fb ff ff       	call   80102098 <readi>
801024a1:	83 c4 10             	add    $0x10,%esp
801024a4:	83 f8 10             	cmp    $0x10,%eax
801024a7:	74 0d                	je     801024b6 <dirlink+0x6a>
      panic("dirlink read");
801024a9:	83 ec 0c             	sub    $0xc,%esp
801024ac:	68 bd a7 10 80       	push   $0x8010a7bd
801024b1:	e8 b0 e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801024b6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024ba:	66 85 c0             	test   %ax,%ax
801024bd:	74 18                	je     801024d7 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c2:	83 c0 10             	add    $0x10,%eax
801024c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024c8:	8b 45 08             	mov    0x8(%ebp),%eax
801024cb:	8b 50 20             	mov    0x20(%eax),%edx
801024ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d1:	39 c2                	cmp    %eax,%edx
801024d3:	77 ba                	ja     8010248f <dirlink+0x43>
801024d5:	eb 01                	jmp    801024d8 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801024d7:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024d8:	83 ec 04             	sub    $0x4,%esp
801024db:	6a 0e                	push   $0xe
801024dd:	ff 75 0c             	pushl  0xc(%ebp)
801024e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024e3:	83 c0 02             	add    $0x2,%eax
801024e6:	50                   	push   %eax
801024e7:	e8 70 4c 00 00       	call   8010715c <strncpy>
801024ec:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024ef:	8b 45 10             	mov    0x10(%ebp),%eax
801024f2:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f9:	6a 10                	push   $0x10
801024fb:	50                   	push   %eax
801024fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024ff:	50                   	push   %eax
80102500:	ff 75 08             	pushl  0x8(%ebp)
80102503:	e8 e7 fc ff ff       	call   801021ef <writei>
80102508:	83 c4 10             	add    $0x10,%esp
8010250b:	83 f8 10             	cmp    $0x10,%eax
8010250e:	74 0d                	je     8010251d <dirlink+0xd1>
    panic("dirlink");
80102510:	83 ec 0c             	sub    $0xc,%esp
80102513:	68 ca a7 10 80       	push   $0x8010a7ca
80102518:	e8 49 e0 ff ff       	call   80100566 <panic>
  
  return 0;
8010251d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102522:	c9                   	leave  
80102523:	c3                   	ret    

80102524 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102524:	55                   	push   %ebp
80102525:	89 e5                	mov    %esp,%ebp
80102527:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010252a:	eb 04                	jmp    80102530 <skipelem+0xc>
    path++;
8010252c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102530:	8b 45 08             	mov    0x8(%ebp),%eax
80102533:	0f b6 00             	movzbl (%eax),%eax
80102536:	3c 2f                	cmp    $0x2f,%al
80102538:	74 f2                	je     8010252c <skipelem+0x8>
    path++;
  if(*path == 0)
8010253a:	8b 45 08             	mov    0x8(%ebp),%eax
8010253d:	0f b6 00             	movzbl (%eax),%eax
80102540:	84 c0                	test   %al,%al
80102542:	75 07                	jne    8010254b <skipelem+0x27>
    return 0;
80102544:	b8 00 00 00 00       	mov    $0x0,%eax
80102549:	eb 7b                	jmp    801025c6 <skipelem+0xa2>
  s = path;
8010254b:	8b 45 08             	mov    0x8(%ebp),%eax
8010254e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102551:	eb 04                	jmp    80102557 <skipelem+0x33>
    path++;
80102553:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102557:	8b 45 08             	mov    0x8(%ebp),%eax
8010255a:	0f b6 00             	movzbl (%eax),%eax
8010255d:	3c 2f                	cmp    $0x2f,%al
8010255f:	74 0a                	je     8010256b <skipelem+0x47>
80102561:	8b 45 08             	mov    0x8(%ebp),%eax
80102564:	0f b6 00             	movzbl (%eax),%eax
80102567:	84 c0                	test   %al,%al
80102569:	75 e8                	jne    80102553 <skipelem+0x2f>
    path++;
  len = path - s;
8010256b:	8b 55 08             	mov    0x8(%ebp),%edx
8010256e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102571:	29 c2                	sub    %eax,%edx
80102573:	89 d0                	mov    %edx,%eax
80102575:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102578:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010257c:	7e 15                	jle    80102593 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010257e:	83 ec 04             	sub    $0x4,%esp
80102581:	6a 0e                	push   $0xe
80102583:	ff 75 f4             	pushl  -0xc(%ebp)
80102586:	ff 75 0c             	pushl  0xc(%ebp)
80102589:	e8 e2 4a 00 00       	call   80107070 <memmove>
8010258e:	83 c4 10             	add    $0x10,%esp
80102591:	eb 26                	jmp    801025b9 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102596:	83 ec 04             	sub    $0x4,%esp
80102599:	50                   	push   %eax
8010259a:	ff 75 f4             	pushl  -0xc(%ebp)
8010259d:	ff 75 0c             	pushl  0xc(%ebp)
801025a0:	e8 cb 4a 00 00       	call   80107070 <memmove>
801025a5:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801025a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801025ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ae:	01 d0                	add    %edx,%eax
801025b0:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025b3:	eb 04                	jmp    801025b9 <skipelem+0x95>
    path++;
801025b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025b9:	8b 45 08             	mov    0x8(%ebp),%eax
801025bc:	0f b6 00             	movzbl (%eax),%eax
801025bf:	3c 2f                	cmp    $0x2f,%al
801025c1:	74 f2                	je     801025b5 <skipelem+0x91>
    path++;
  return path;
801025c3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025c6:	c9                   	leave  
801025c7:	c3                   	ret    

801025c8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025c8:	55                   	push   %ebp
801025c9:	89 e5                	mov    %esp,%ebp
801025cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025ce:	8b 45 08             	mov    0x8(%ebp),%eax
801025d1:	0f b6 00             	movzbl (%eax),%eax
801025d4:	3c 2f                	cmp    $0x2f,%al
801025d6:	75 17                	jne    801025ef <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801025d8:	83 ec 08             	sub    $0x8,%esp
801025db:	6a 01                	push   $0x1
801025dd:	6a 01                	push   $0x1
801025df:	e8 dd f3 ff ff       	call   801019c1 <iget>
801025e4:	83 c4 10             	add    $0x10,%esp
801025e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025ea:	e9 bb 00 00 00       	jmp    801026aa <namex+0xe2>
  else
    ip = idup(proc->cwd);
801025ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801025f5:	8b 40 68             	mov    0x68(%eax),%eax
801025f8:	83 ec 0c             	sub    $0xc,%esp
801025fb:	50                   	push   %eax
801025fc:	e8 9f f4 ff ff       	call   80101aa0 <idup>
80102601:	83 c4 10             	add    $0x10,%esp
80102604:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102607:	e9 9e 00 00 00       	jmp    801026aa <namex+0xe2>
    ilock(ip);
8010260c:	83 ec 0c             	sub    $0xc,%esp
8010260f:	ff 75 f4             	pushl  -0xc(%ebp)
80102612:	e8 c3 f4 ff ff       	call   80101ada <ilock>
80102617:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010261a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102621:	66 83 f8 01          	cmp    $0x1,%ax
80102625:	74 18                	je     8010263f <namex+0x77>
      iunlockput(ip);
80102627:	83 ec 0c             	sub    $0xc,%esp
8010262a:	ff 75 f4             	pushl  -0xc(%ebp)
8010262d:	e8 90 f7 ff ff       	call   80101dc2 <iunlockput>
80102632:	83 c4 10             	add    $0x10,%esp
      return 0;
80102635:	b8 00 00 00 00       	mov    $0x0,%eax
8010263a:	e9 a7 00 00 00       	jmp    801026e6 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010263f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102643:	74 20                	je     80102665 <namex+0x9d>
80102645:	8b 45 08             	mov    0x8(%ebp),%eax
80102648:	0f b6 00             	movzbl (%eax),%eax
8010264b:	84 c0                	test   %al,%al
8010264d:	75 16                	jne    80102665 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010264f:	83 ec 0c             	sub    $0xc,%esp
80102652:	ff 75 f4             	pushl  -0xc(%ebp)
80102655:	e8 06 f6 ff ff       	call   80101c60 <iunlock>
8010265a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010265d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102660:	e9 81 00 00 00       	jmp    801026e6 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102665:	83 ec 04             	sub    $0x4,%esp
80102668:	6a 00                	push   $0x0
8010266a:	ff 75 10             	pushl  0x10(%ebp)
8010266d:	ff 75 f4             	pushl  -0xc(%ebp)
80102670:	e8 1d fd ff ff       	call   80102392 <dirlookup>
80102675:	83 c4 10             	add    $0x10,%esp
80102678:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010267b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010267f:	75 15                	jne    80102696 <namex+0xce>
      iunlockput(ip);
80102681:	83 ec 0c             	sub    $0xc,%esp
80102684:	ff 75 f4             	pushl  -0xc(%ebp)
80102687:	e8 36 f7 ff ff       	call   80101dc2 <iunlockput>
8010268c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010268f:	b8 00 00 00 00       	mov    $0x0,%eax
80102694:	eb 50                	jmp    801026e6 <namex+0x11e>
    }
    iunlockput(ip);
80102696:	83 ec 0c             	sub    $0xc,%esp
80102699:	ff 75 f4             	pushl  -0xc(%ebp)
8010269c:	e8 21 f7 ff ff       	call   80101dc2 <iunlockput>
801026a1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801026a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 10             	pushl  0x10(%ebp)
801026b0:	ff 75 08             	pushl  0x8(%ebp)
801026b3:	e8 6c fe ff ff       	call   80102524 <skipelem>
801026b8:	83 c4 10             	add    $0x10,%esp
801026bb:	89 45 08             	mov    %eax,0x8(%ebp)
801026be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c2:	0f 85 44 ff ff ff    	jne    8010260c <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801026c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026cc:	74 15                	je     801026e3 <namex+0x11b>
    iput(ip);
801026ce:	83 ec 0c             	sub    $0xc,%esp
801026d1:	ff 75 f4             	pushl  -0xc(%ebp)
801026d4:	e8 f9 f5 ff ff       	call   80101cd2 <iput>
801026d9:	83 c4 10             	add    $0x10,%esp
    return 0;
801026dc:	b8 00 00 00 00       	mov    $0x0,%eax
801026e1:	eb 03                	jmp    801026e6 <namex+0x11e>
  }
  return ip;
801026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026e6:	c9                   	leave  
801026e7:	c3                   	ret    

801026e8 <namei>:

struct inode*
namei(char *path)
{
801026e8:	55                   	push   %ebp
801026e9:	89 e5                	mov    %esp,%ebp
801026eb:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026ee:	83 ec 04             	sub    $0x4,%esp
801026f1:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026f4:	50                   	push   %eax
801026f5:	6a 00                	push   $0x0
801026f7:	ff 75 08             	pushl  0x8(%ebp)
801026fa:	e8 c9 fe ff ff       	call   801025c8 <namex>
801026ff:	83 c4 10             	add    $0x10,%esp
}
80102702:	c9                   	leave  
80102703:	c3                   	ret    

80102704 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102704:	55                   	push   %ebp
80102705:	89 e5                	mov    %esp,%ebp
80102707:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010270a:	83 ec 04             	sub    $0x4,%esp
8010270d:	ff 75 0c             	pushl  0xc(%ebp)
80102710:	6a 01                	push   $0x1
80102712:	ff 75 08             	pushl  0x8(%ebp)
80102715:	e8 ae fe ff ff       	call   801025c8 <namex>
8010271a:	83 c4 10             	add    $0x10,%esp
}
8010271d:	c9                   	leave  
8010271e:	c3                   	ret    

8010271f <chmod>:
#ifdef CS333_P5
int
chmod(char * pathname, int mode){
8010271f:	55                   	push   %ebp
80102720:	89 e5                	mov    %esp,%ebp
80102722:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;

    begin_op();
80102725:	e8 84 11 00 00       	call   801038ae <begin_op>
    ip = namei(pathname);
8010272a:	83 ec 0c             	sub    $0xc,%esp
8010272d:	ff 75 08             	pushl  0x8(%ebp)
80102730:	e8 b3 ff ff ff       	call   801026e8 <namei>
80102735:	83 c4 10             	add    $0x10,%esp
80102738:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip){
8010273b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010273f:	74 4d                	je     8010278e <chmod+0x6f>
	ilock(ip);
80102741:	83 ec 0c             	sub    $0xc,%esp
80102744:	ff 75 f4             	pushl  -0xc(%ebp)
80102747:	e8 8e f3 ff ff       	call   80101ada <ilock>
8010274c:	83 c4 10             	add    $0x10,%esp
	ip->mode.asInt = mode;
8010274f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102755:	89 50 1c             	mov    %edx,0x1c(%eax)
	iupdate(ip);
80102758:	83 ec 0c             	sub    $0xc,%esp
8010275b:	ff 75 f4             	pushl  -0xc(%ebp)
8010275e:	e8 75 f1 ff ff       	call   801018d8 <iupdate>
80102763:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
80102766:	83 ec 0c             	sub    $0xc,%esp
80102769:	ff 75 f4             	pushl  -0xc(%ebp)
8010276c:	e8 ef f4 ff ff       	call   80101c60 <iunlock>
80102771:	83 c4 10             	add    $0x10,%esp
	iput(ip);
80102774:	83 ec 0c             	sub    $0xc,%esp
80102777:	ff 75 f4             	pushl  -0xc(%ebp)
8010277a:	e8 53 f5 ff ff       	call   80101cd2 <iput>
8010277f:	83 c4 10             	add    $0x10,%esp
	end_op();
80102782:	e8 b3 11 00 00       	call   8010393a <end_op>
	end_op();
	return -1;
    }


    return 0;
80102787:	b8 00 00 00 00       	mov    $0x0,%eax
8010278c:	eb 18                	jmp    801027a6 <chmod+0x87>
	iunlock(ip);
	iput(ip);
	end_op();
    }
    else{
	iunlock(ip);
8010278e:	83 ec 0c             	sub    $0xc,%esp
80102791:	ff 75 f4             	pushl  -0xc(%ebp)
80102794:	e8 c7 f4 ff ff       	call   80101c60 <iunlock>
80102799:	83 c4 10             	add    $0x10,%esp
	end_op();
8010279c:	e8 99 11 00 00       	call   8010393a <end_op>
	return -1;
801027a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }


    return 0;
}
801027a6:	c9                   	leave  
801027a7:	c3                   	ret    

801027a8 <chown>:

int 
chown(char * pathname, int owner){
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;

    begin_op();
801027ae:	e8 fb 10 00 00       	call   801038ae <begin_op>
    ip = namei(pathname);
801027b3:	83 ec 0c             	sub    $0xc,%esp
801027b6:	ff 75 08             	pushl  0x8(%ebp)
801027b9:	e8 2a ff ff ff       	call   801026e8 <namei>
801027be:	83 c4 10             	add    $0x10,%esp
801027c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip){
801027c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c8:	74 50                	je     8010281a <chown+0x72>
	ilock(ip);
801027ca:	83 ec 0c             	sub    $0xc,%esp
801027cd:	ff 75 f4             	pushl  -0xc(%ebp)
801027d0:	e8 05 f3 ff ff       	call   80101ada <ilock>
801027d5:	83 c4 10             	add    $0x10,%esp
	ip-> uid = owner;
801027d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801027db:	89 c2                	mov    %eax,%edx
801027dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e0:	66 89 50 18          	mov    %dx,0x18(%eax)
	iupdate(ip);
801027e4:	83 ec 0c             	sub    $0xc,%esp
801027e7:	ff 75 f4             	pushl  -0xc(%ebp)
801027ea:	e8 e9 f0 ff ff       	call   801018d8 <iupdate>
801027ef:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
801027f2:	83 ec 0c             	sub    $0xc,%esp
801027f5:	ff 75 f4             	pushl  -0xc(%ebp)
801027f8:	e8 63 f4 ff ff       	call   80101c60 <iunlock>
801027fd:	83 c4 10             	add    $0x10,%esp
	iput(ip);
80102800:	83 ec 0c             	sub    $0xc,%esp
80102803:	ff 75 f4             	pushl  -0xc(%ebp)
80102806:	e8 c7 f4 ff ff       	call   80101cd2 <iput>
8010280b:	83 c4 10             	add    $0x10,%esp
	end_op();
8010280e:	e8 27 11 00 00       	call   8010393a <end_op>
	iunlock(ip);
	end_op();
	return -1;
    }

    return 0;
80102813:	b8 00 00 00 00       	mov    $0x0,%eax
80102818:	eb 18                	jmp    80102832 <chown+0x8a>
	iunlock(ip);
	iput(ip);
	end_op();
    }
    else{
	iunlock(ip);
8010281a:	83 ec 0c             	sub    $0xc,%esp
8010281d:	ff 75 f4             	pushl  -0xc(%ebp)
80102820:	e8 3b f4 ff ff       	call   80101c60 <iunlock>
80102825:	83 c4 10             	add    $0x10,%esp
	end_op();
80102828:	e8 0d 11 00 00       	call   8010393a <end_op>
	return -1;
8010282d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    return 0;
}
80102832:	c9                   	leave  
80102833:	c3                   	ret    

80102834 <chgrp>:

int
chgrp(char * pathname, int group){
80102834:	55                   	push   %ebp
80102835:	89 e5                	mov    %esp,%ebp
80102837:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;

    begin_op();
8010283a:	e8 6f 10 00 00       	call   801038ae <begin_op>
    ip = namei(pathname);
8010283f:	83 ec 0c             	sub    $0xc,%esp
80102842:	ff 75 08             	pushl  0x8(%ebp)
80102845:	e8 9e fe ff ff       	call   801026e8 <namei>
8010284a:	83 c4 10             	add    $0x10,%esp
8010284d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip){
80102850:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102854:	74 50                	je     801028a6 <chgrp+0x72>
	ilock(ip);
80102856:	83 ec 0c             	sub    $0xc,%esp
80102859:	ff 75 f4             	pushl  -0xc(%ebp)
8010285c:	e8 79 f2 ff ff       	call   80101ada <ilock>
80102861:	83 c4 10             	add    $0x10,%esp
	ip-> gid = group;
80102864:	8b 45 0c             	mov    0xc(%ebp),%eax
80102867:	89 c2                	mov    %eax,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	66 89 50 1a          	mov    %dx,0x1a(%eax)
	iupdate(ip);
80102870:	83 ec 0c             	sub    $0xc,%esp
80102873:	ff 75 f4             	pushl  -0xc(%ebp)
80102876:	e8 5d f0 ff ff       	call   801018d8 <iupdate>
8010287b:	83 c4 10             	add    $0x10,%esp
	iunlock(ip);
8010287e:	83 ec 0c             	sub    $0xc,%esp
80102881:	ff 75 f4             	pushl  -0xc(%ebp)
80102884:	e8 d7 f3 ff ff       	call   80101c60 <iunlock>
80102889:	83 c4 10             	add    $0x10,%esp
	iput(ip);
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	ff 75 f4             	pushl  -0xc(%ebp)
80102892:	e8 3b f4 ff ff       	call   80101cd2 <iput>
80102897:	83 c4 10             	add    $0x10,%esp
	end_op();
8010289a:	e8 9b 10 00 00       	call   8010393a <end_op>
	iunlock(ip);
	end_op();
	return -1;
    }

    return 0;
8010289f:	b8 00 00 00 00       	mov    $0x0,%eax
801028a4:	eb 18                	jmp    801028be <chgrp+0x8a>
	iunlock(ip);
	iput(ip);
	end_op();
    }
    else{
	iunlock(ip);
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	ff 75 f4             	pushl  -0xc(%ebp)
801028ac:	e8 af f3 ff ff       	call   80101c60 <iunlock>
801028b1:	83 c4 10             	add    $0x10,%esp
	end_op();
801028b4:	e8 81 10 00 00       	call   8010393a <end_op>
	return -1;
801028b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    return 0;
}
801028be:	c9                   	leave  
801028bf:	c3                   	ret    

801028c0 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801028c0:	55                   	push   %ebp
801028c1:	89 e5                	mov    %esp,%ebp
801028c3:	83 ec 14             	sub    $0x14,%esp
801028c6:	8b 45 08             	mov    0x8(%ebp),%eax
801028c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028cd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028d1:	89 c2                	mov    %eax,%edx
801028d3:	ec                   	in     (%dx),%al
801028d4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801028d7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801028db:	c9                   	leave  
801028dc:	c3                   	ret    

801028dd <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801028dd:	55                   	push   %ebp
801028de:	89 e5                	mov    %esp,%ebp
801028e0:	57                   	push   %edi
801028e1:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801028e2:	8b 55 08             	mov    0x8(%ebp),%edx
801028e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801028e8:	8b 45 10             	mov    0x10(%ebp),%eax
801028eb:	89 cb                	mov    %ecx,%ebx
801028ed:	89 df                	mov    %ebx,%edi
801028ef:	89 c1                	mov    %eax,%ecx
801028f1:	fc                   	cld    
801028f2:	f3 6d                	rep insl (%dx),%es:(%edi)
801028f4:	89 c8                	mov    %ecx,%eax
801028f6:	89 fb                	mov    %edi,%ebx
801028f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801028fb:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801028fe:	90                   	nop
801028ff:	5b                   	pop    %ebx
80102900:	5f                   	pop    %edi
80102901:	5d                   	pop    %ebp
80102902:	c3                   	ret    

80102903 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102903:	55                   	push   %ebp
80102904:	89 e5                	mov    %esp,%ebp
80102906:	83 ec 08             	sub    $0x8,%esp
80102909:	8b 55 08             	mov    0x8(%ebp),%edx
8010290c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010290f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102913:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102916:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010291a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010291e:	ee                   	out    %al,(%dx)
}
8010291f:	90                   	nop
80102920:	c9                   	leave  
80102921:	c3                   	ret    

80102922 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102922:	55                   	push   %ebp
80102923:	89 e5                	mov    %esp,%ebp
80102925:	56                   	push   %esi
80102926:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102927:	8b 55 08             	mov    0x8(%ebp),%edx
8010292a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010292d:	8b 45 10             	mov    0x10(%ebp),%eax
80102930:	89 cb                	mov    %ecx,%ebx
80102932:	89 de                	mov    %ebx,%esi
80102934:	89 c1                	mov    %eax,%ecx
80102936:	fc                   	cld    
80102937:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102939:	89 c8                	mov    %ecx,%eax
8010293b:	89 f3                	mov    %esi,%ebx
8010293d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102940:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102943:	90                   	nop
80102944:	5b                   	pop    %ebx
80102945:	5e                   	pop    %esi
80102946:	5d                   	pop    %ebp
80102947:	c3                   	ret    

80102948 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102948:	55                   	push   %ebp
80102949:	89 e5                	mov    %esp,%ebp
8010294b:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010294e:	90                   	nop
8010294f:	68 f7 01 00 00       	push   $0x1f7
80102954:	e8 67 ff ff ff       	call   801028c0 <inb>
80102959:	83 c4 04             	add    $0x4,%esp
8010295c:	0f b6 c0             	movzbl %al,%eax
8010295f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102962:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102965:	25 c0 00 00 00       	and    $0xc0,%eax
8010296a:	83 f8 40             	cmp    $0x40,%eax
8010296d:	75 e0                	jne    8010294f <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010296f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102973:	74 11                	je     80102986 <idewait+0x3e>
80102975:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102978:	83 e0 21             	and    $0x21,%eax
8010297b:	85 c0                	test   %eax,%eax
8010297d:	74 07                	je     80102986 <idewait+0x3e>
    return -1;
8010297f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102984:	eb 05                	jmp    8010298b <idewait+0x43>
  return 0;
80102986:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010298b:	c9                   	leave  
8010298c:	c3                   	ret    

8010298d <ideinit>:

void
ideinit(void)
{
8010298d:	55                   	push   %ebp
8010298e:	89 e5                	mov    %esp,%ebp
80102990:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102993:	83 ec 08             	sub    $0x8,%esp
80102996:	68 d2 a7 10 80       	push   $0x8010a7d2
8010299b:	68 20 e6 10 80       	push   $0x8010e620
801029a0:	e8 87 43 00 00       	call   80106d2c <initlock>
801029a5:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801029a8:	83 ec 0c             	sub    $0xc,%esp
801029ab:	6a 0e                	push   $0xe
801029ad:	e8 da 18 00 00       	call   8010428c <picenable>
801029b2:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801029b5:	a1 60 59 11 80       	mov    0x80115960,%eax
801029ba:	83 e8 01             	sub    $0x1,%eax
801029bd:	83 ec 08             	sub    $0x8,%esp
801029c0:	50                   	push   %eax
801029c1:	6a 0e                	push   $0xe
801029c3:	e8 73 04 00 00       	call   80102e3b <ioapicenable>
801029c8:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801029cb:	83 ec 0c             	sub    $0xc,%esp
801029ce:	6a 00                	push   $0x0
801029d0:	e8 73 ff ff ff       	call   80102948 <idewait>
801029d5:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801029d8:	83 ec 08             	sub    $0x8,%esp
801029db:	68 f0 00 00 00       	push   $0xf0
801029e0:	68 f6 01 00 00       	push   $0x1f6
801029e5:	e8 19 ff ff ff       	call   80102903 <outb>
801029ea:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801029ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029f4:	eb 24                	jmp    80102a1a <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801029f6:	83 ec 0c             	sub    $0xc,%esp
801029f9:	68 f7 01 00 00       	push   $0x1f7
801029fe:	e8 bd fe ff ff       	call   801028c0 <inb>
80102a03:	83 c4 10             	add    $0x10,%esp
80102a06:	84 c0                	test   %al,%al
80102a08:	74 0c                	je     80102a16 <ideinit+0x89>
      havedisk1 = 1;
80102a0a:	c7 05 58 e6 10 80 01 	movl   $0x1,0x8010e658
80102a11:	00 00 00 
      break;
80102a14:	eb 0d                	jmp    80102a23 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102a16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a1a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102a21:	7e d3                	jle    801029f6 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102a23:	83 ec 08             	sub    $0x8,%esp
80102a26:	68 e0 00 00 00       	push   $0xe0
80102a2b:	68 f6 01 00 00       	push   $0x1f6
80102a30:	e8 ce fe ff ff       	call   80102903 <outb>
80102a35:	83 c4 10             	add    $0x10,%esp
}
80102a38:	90                   	nop
80102a39:	c9                   	leave  
80102a3a:	c3                   	ret    

80102a3b <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102a3b:	55                   	push   %ebp
80102a3c:	89 e5                	mov    %esp,%ebp
80102a3e:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102a41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102a45:	75 0d                	jne    80102a54 <idestart+0x19>
    panic("idestart");
80102a47:	83 ec 0c             	sub    $0xc,%esp
80102a4a:	68 d6 a7 10 80       	push   $0x8010a7d6
80102a4f:	e8 12 db ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102a54:	8b 45 08             	mov    0x8(%ebp),%eax
80102a57:	8b 40 08             	mov    0x8(%eax),%eax
80102a5a:	3d cf 07 00 00       	cmp    $0x7cf,%eax
80102a5f:	76 0d                	jbe    80102a6e <idestart+0x33>
    panic("incorrect blockno");
80102a61:	83 ec 0c             	sub    $0xc,%esp
80102a64:	68 df a7 10 80       	push   $0x8010a7df
80102a69:	e8 f8 da ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102a6e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102a75:	8b 45 08             	mov    0x8(%ebp),%eax
80102a78:	8b 50 08             	mov    0x8(%eax),%edx
80102a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7e:	0f af c2             	imul   %edx,%eax
80102a81:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102a84:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102a88:	7e 0d                	jle    80102a97 <idestart+0x5c>
80102a8a:	83 ec 0c             	sub    $0xc,%esp
80102a8d:	68 d6 a7 10 80       	push   $0x8010a7d6
80102a92:	e8 cf da ff ff       	call   80100566 <panic>
  
  idewait(0);
80102a97:	83 ec 0c             	sub    $0xc,%esp
80102a9a:	6a 00                	push   $0x0
80102a9c:	e8 a7 fe ff ff       	call   80102948 <idewait>
80102aa1:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102aa4:	83 ec 08             	sub    $0x8,%esp
80102aa7:	6a 00                	push   $0x0
80102aa9:	68 f6 03 00 00       	push   $0x3f6
80102aae:	e8 50 fe ff ff       	call   80102903 <outb>
80102ab3:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab9:	0f b6 c0             	movzbl %al,%eax
80102abc:	83 ec 08             	sub    $0x8,%esp
80102abf:	50                   	push   %eax
80102ac0:	68 f2 01 00 00       	push   $0x1f2
80102ac5:	e8 39 fe ff ff       	call   80102903 <outb>
80102aca:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ad0:	0f b6 c0             	movzbl %al,%eax
80102ad3:	83 ec 08             	sub    $0x8,%esp
80102ad6:	50                   	push   %eax
80102ad7:	68 f3 01 00 00       	push   $0x1f3
80102adc:	e8 22 fe ff ff       	call   80102903 <outb>
80102ae1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ae7:	c1 f8 08             	sar    $0x8,%eax
80102aea:	0f b6 c0             	movzbl %al,%eax
80102aed:	83 ec 08             	sub    $0x8,%esp
80102af0:	50                   	push   %eax
80102af1:	68 f4 01 00 00       	push   $0x1f4
80102af6:	e8 08 fe ff ff       	call   80102903 <outb>
80102afb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b01:	c1 f8 10             	sar    $0x10,%eax
80102b04:	0f b6 c0             	movzbl %al,%eax
80102b07:	83 ec 08             	sub    $0x8,%esp
80102b0a:	50                   	push   %eax
80102b0b:	68 f5 01 00 00       	push   $0x1f5
80102b10:	e8 ee fd ff ff       	call   80102903 <outb>
80102b15:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102b18:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1b:	8b 40 04             	mov    0x4(%eax),%eax
80102b1e:	83 e0 01             	and    $0x1,%eax
80102b21:	c1 e0 04             	shl    $0x4,%eax
80102b24:	89 c2                	mov    %eax,%edx
80102b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b29:	c1 f8 18             	sar    $0x18,%eax
80102b2c:	83 e0 0f             	and    $0xf,%eax
80102b2f:	09 d0                	or     %edx,%eax
80102b31:	83 c8 e0             	or     $0xffffffe0,%eax
80102b34:	0f b6 c0             	movzbl %al,%eax
80102b37:	83 ec 08             	sub    $0x8,%esp
80102b3a:	50                   	push   %eax
80102b3b:	68 f6 01 00 00       	push   $0x1f6
80102b40:	e8 be fd ff ff       	call   80102903 <outb>
80102b45:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102b48:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4b:	8b 00                	mov    (%eax),%eax
80102b4d:	83 e0 04             	and    $0x4,%eax
80102b50:	85 c0                	test   %eax,%eax
80102b52:	74 30                	je     80102b84 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102b54:	83 ec 08             	sub    $0x8,%esp
80102b57:	6a 30                	push   $0x30
80102b59:	68 f7 01 00 00       	push   $0x1f7
80102b5e:	e8 a0 fd ff ff       	call   80102903 <outb>
80102b63:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102b66:	8b 45 08             	mov    0x8(%ebp),%eax
80102b69:	83 c0 18             	add    $0x18,%eax
80102b6c:	83 ec 04             	sub    $0x4,%esp
80102b6f:	68 80 00 00 00       	push   $0x80
80102b74:	50                   	push   %eax
80102b75:	68 f0 01 00 00       	push   $0x1f0
80102b7a:	e8 a3 fd ff ff       	call   80102922 <outsl>
80102b7f:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102b82:	eb 12                	jmp    80102b96 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102b84:	83 ec 08             	sub    $0x8,%esp
80102b87:	6a 20                	push   $0x20
80102b89:	68 f7 01 00 00       	push   $0x1f7
80102b8e:	e8 70 fd ff ff       	call   80102903 <outb>
80102b93:	83 c4 10             	add    $0x10,%esp
  }
}
80102b96:	90                   	nop
80102b97:	c9                   	leave  
80102b98:	c3                   	ret    

80102b99 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102b99:	55                   	push   %ebp
80102b9a:	89 e5                	mov    %esp,%ebp
80102b9c:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102b9f:	83 ec 0c             	sub    $0xc,%esp
80102ba2:	68 20 e6 10 80       	push   $0x8010e620
80102ba7:	e8 a2 41 00 00       	call   80106d4e <acquire>
80102bac:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102baf:	a1 54 e6 10 80       	mov    0x8010e654,%eax
80102bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102bb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bbb:	75 15                	jne    80102bd2 <ideintr+0x39>
    release(&idelock);
80102bbd:	83 ec 0c             	sub    $0xc,%esp
80102bc0:	68 20 e6 10 80       	push   $0x8010e620
80102bc5:	e8 eb 41 00 00       	call   80106db5 <release>
80102bca:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102bcd:	e9 9a 00 00 00       	jmp    80102c6c <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd5:	8b 40 14             	mov    0x14(%eax),%eax
80102bd8:	a3 54 e6 10 80       	mov    %eax,0x8010e654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be0:	8b 00                	mov    (%eax),%eax
80102be2:	83 e0 04             	and    $0x4,%eax
80102be5:	85 c0                	test   %eax,%eax
80102be7:	75 2d                	jne    80102c16 <ideintr+0x7d>
80102be9:	83 ec 0c             	sub    $0xc,%esp
80102bec:	6a 01                	push   $0x1
80102bee:	e8 55 fd ff ff       	call   80102948 <idewait>
80102bf3:	83 c4 10             	add    $0x10,%esp
80102bf6:	85 c0                	test   %eax,%eax
80102bf8:	78 1c                	js     80102c16 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bfd:	83 c0 18             	add    $0x18,%eax
80102c00:	83 ec 04             	sub    $0x4,%esp
80102c03:	68 80 00 00 00       	push   $0x80
80102c08:	50                   	push   %eax
80102c09:	68 f0 01 00 00       	push   $0x1f0
80102c0e:	e8 ca fc ff ff       	call   801028dd <insl>
80102c13:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c19:	8b 00                	mov    (%eax),%eax
80102c1b:	83 c8 02             	or     $0x2,%eax
80102c1e:	89 c2                	mov    %eax,%edx
80102c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c23:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c28:	8b 00                	mov    (%eax),%eax
80102c2a:	83 e0 fb             	and    $0xfffffffb,%eax
80102c2d:	89 c2                	mov    %eax,%edx
80102c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c32:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102c34:	83 ec 0c             	sub    $0xc,%esp
80102c37:	ff 75 f4             	pushl  -0xc(%ebp)
80102c3a:	e8 0a 30 00 00       	call   80105c49 <wakeup>
80102c3f:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102c42:	a1 54 e6 10 80       	mov    0x8010e654,%eax
80102c47:	85 c0                	test   %eax,%eax
80102c49:	74 11                	je     80102c5c <ideintr+0xc3>
    idestart(idequeue);
80102c4b:	a1 54 e6 10 80       	mov    0x8010e654,%eax
80102c50:	83 ec 0c             	sub    $0xc,%esp
80102c53:	50                   	push   %eax
80102c54:	e8 e2 fd ff ff       	call   80102a3b <idestart>
80102c59:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102c5c:	83 ec 0c             	sub    $0xc,%esp
80102c5f:	68 20 e6 10 80       	push   $0x8010e620
80102c64:	e8 4c 41 00 00       	call   80106db5 <release>
80102c69:	83 c4 10             	add    $0x10,%esp
}
80102c6c:	c9                   	leave  
80102c6d:	c3                   	ret    

80102c6e <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102c6e:	55                   	push   %ebp
80102c6f:	89 e5                	mov    %esp,%ebp
80102c71:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102c74:	8b 45 08             	mov    0x8(%ebp),%eax
80102c77:	8b 00                	mov    (%eax),%eax
80102c79:	83 e0 01             	and    $0x1,%eax
80102c7c:	85 c0                	test   %eax,%eax
80102c7e:	75 0d                	jne    80102c8d <iderw+0x1f>
    panic("iderw: buf not busy");
80102c80:	83 ec 0c             	sub    $0xc,%esp
80102c83:	68 f1 a7 10 80       	push   $0x8010a7f1
80102c88:	e8 d9 d8 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c90:	8b 00                	mov    (%eax),%eax
80102c92:	83 e0 06             	and    $0x6,%eax
80102c95:	83 f8 02             	cmp    $0x2,%eax
80102c98:	75 0d                	jne    80102ca7 <iderw+0x39>
    panic("iderw: nothing to do");
80102c9a:	83 ec 0c             	sub    $0xc,%esp
80102c9d:	68 05 a8 10 80       	push   $0x8010a805
80102ca2:	e8 bf d8 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80102caa:	8b 40 04             	mov    0x4(%eax),%eax
80102cad:	85 c0                	test   %eax,%eax
80102caf:	74 16                	je     80102cc7 <iderw+0x59>
80102cb1:	a1 58 e6 10 80       	mov    0x8010e658,%eax
80102cb6:	85 c0                	test   %eax,%eax
80102cb8:	75 0d                	jne    80102cc7 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102cba:	83 ec 0c             	sub    $0xc,%esp
80102cbd:	68 1a a8 10 80       	push   $0x8010a81a
80102cc2:	e8 9f d8 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102cc7:	83 ec 0c             	sub    $0xc,%esp
80102cca:	68 20 e6 10 80       	push   $0x8010e620
80102ccf:	e8 7a 40 00 00       	call   80106d4e <acquire>
80102cd4:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102cda:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102ce1:	c7 45 f4 54 e6 10 80 	movl   $0x8010e654,-0xc(%ebp)
80102ce8:	eb 0b                	jmp    80102cf5 <iderw+0x87>
80102cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ced:	8b 00                	mov    (%eax),%eax
80102cef:	83 c0 14             	add    $0x14,%eax
80102cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf8:	8b 00                	mov    (%eax),%eax
80102cfa:	85 c0                	test   %eax,%eax
80102cfc:	75 ec                	jne    80102cea <iderw+0x7c>
    ;
  *pp = b;
80102cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d01:	8b 55 08             	mov    0x8(%ebp),%edx
80102d04:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102d06:	a1 54 e6 10 80       	mov    0x8010e654,%eax
80102d0b:	3b 45 08             	cmp    0x8(%ebp),%eax
80102d0e:	75 23                	jne    80102d33 <iderw+0xc5>
    idestart(b);
80102d10:	83 ec 0c             	sub    $0xc,%esp
80102d13:	ff 75 08             	pushl  0x8(%ebp)
80102d16:	e8 20 fd ff ff       	call   80102a3b <idestart>
80102d1b:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d1e:	eb 13                	jmp    80102d33 <iderw+0xc5>
    sleep(b, &idelock);
80102d20:	83 ec 08             	sub    $0x8,%esp
80102d23:	68 20 e6 10 80       	push   $0x8010e620
80102d28:	ff 75 08             	pushl  0x8(%ebp)
80102d2b:	e8 09 2d 00 00       	call   80105a39 <sleep>
80102d30:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d33:	8b 45 08             	mov    0x8(%ebp),%eax
80102d36:	8b 00                	mov    (%eax),%eax
80102d38:	83 e0 06             	and    $0x6,%eax
80102d3b:	83 f8 02             	cmp    $0x2,%eax
80102d3e:	75 e0                	jne    80102d20 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102d40:	83 ec 0c             	sub    $0xc,%esp
80102d43:	68 20 e6 10 80       	push   $0x8010e620
80102d48:	e8 68 40 00 00       	call   80106db5 <release>
80102d4d:	83 c4 10             	add    $0x10,%esp
}
80102d50:	90                   	nop
80102d51:	c9                   	leave  
80102d52:	c3                   	ret    

80102d53 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102d53:	55                   	push   %ebp
80102d54:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102d56:	a1 34 52 11 80       	mov    0x80115234,%eax
80102d5b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d5e:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102d60:	a1 34 52 11 80       	mov    0x80115234,%eax
80102d65:	8b 40 10             	mov    0x10(%eax),%eax
}
80102d68:	5d                   	pop    %ebp
80102d69:	c3                   	ret    

80102d6a <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102d6a:	55                   	push   %ebp
80102d6b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102d6d:	a1 34 52 11 80       	mov    0x80115234,%eax
80102d72:	8b 55 08             	mov    0x8(%ebp),%edx
80102d75:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102d77:	a1 34 52 11 80       	mov    0x80115234,%eax
80102d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102d7f:	89 50 10             	mov    %edx,0x10(%eax)
}
80102d82:	90                   	nop
80102d83:	5d                   	pop    %ebp
80102d84:	c3                   	ret    

80102d85 <ioapicinit>:

void
ioapicinit(void)
{
80102d85:	55                   	push   %ebp
80102d86:	89 e5                	mov    %esp,%ebp
80102d88:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102d8b:	a1 64 53 11 80       	mov    0x80115364,%eax
80102d90:	85 c0                	test   %eax,%eax
80102d92:	0f 84 a0 00 00 00    	je     80102e38 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102d98:	c7 05 34 52 11 80 00 	movl   $0xfec00000,0x80115234
80102d9f:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102da2:	6a 01                	push   $0x1
80102da4:	e8 aa ff ff ff       	call   80102d53 <ioapicread>
80102da9:	83 c4 04             	add    $0x4,%esp
80102dac:	c1 e8 10             	shr    $0x10,%eax
80102daf:	25 ff 00 00 00       	and    $0xff,%eax
80102db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102db7:	6a 00                	push   $0x0
80102db9:	e8 95 ff ff ff       	call   80102d53 <ioapicread>
80102dbe:	83 c4 04             	add    $0x4,%esp
80102dc1:	c1 e8 18             	shr    $0x18,%eax
80102dc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102dc7:	0f b6 05 60 53 11 80 	movzbl 0x80115360,%eax
80102dce:	0f b6 c0             	movzbl %al,%eax
80102dd1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102dd4:	74 10                	je     80102de6 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102dd6:	83 ec 0c             	sub    $0xc,%esp
80102dd9:	68 38 a8 10 80       	push   $0x8010a838
80102dde:	e8 e3 d5 ff ff       	call   801003c6 <cprintf>
80102de3:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102de6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ded:	eb 3f                	jmp    80102e2e <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102df2:	83 c0 20             	add    $0x20,%eax
80102df5:	0d 00 00 01 00       	or     $0x10000,%eax
80102dfa:	89 c2                	mov    %eax,%edx
80102dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dff:	83 c0 08             	add    $0x8,%eax
80102e02:	01 c0                	add    %eax,%eax
80102e04:	83 ec 08             	sub    $0x8,%esp
80102e07:	52                   	push   %edx
80102e08:	50                   	push   %eax
80102e09:	e8 5c ff ff ff       	call   80102d6a <ioapicwrite>
80102e0e:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e14:	83 c0 08             	add    $0x8,%eax
80102e17:	01 c0                	add    %eax,%eax
80102e19:	83 c0 01             	add    $0x1,%eax
80102e1c:	83 ec 08             	sub    $0x8,%esp
80102e1f:	6a 00                	push   $0x0
80102e21:	50                   	push   %eax
80102e22:	e8 43 ff ff ff       	call   80102d6a <ioapicwrite>
80102e27:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e31:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102e34:	7e b9                	jle    80102def <ioapicinit+0x6a>
80102e36:	eb 01                	jmp    80102e39 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102e38:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102e39:	c9                   	leave  
80102e3a:	c3                   	ret    

80102e3b <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102e3b:	55                   	push   %ebp
80102e3c:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102e3e:	a1 64 53 11 80       	mov    0x80115364,%eax
80102e43:	85 c0                	test   %eax,%eax
80102e45:	74 39                	je     80102e80 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102e47:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4a:	83 c0 20             	add    $0x20,%eax
80102e4d:	89 c2                	mov    %eax,%edx
80102e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e52:	83 c0 08             	add    $0x8,%eax
80102e55:	01 c0                	add    %eax,%eax
80102e57:	52                   	push   %edx
80102e58:	50                   	push   %eax
80102e59:	e8 0c ff ff ff       	call   80102d6a <ioapicwrite>
80102e5e:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e64:	c1 e0 18             	shl    $0x18,%eax
80102e67:	89 c2                	mov    %eax,%edx
80102e69:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6c:	83 c0 08             	add    $0x8,%eax
80102e6f:	01 c0                	add    %eax,%eax
80102e71:	83 c0 01             	add    $0x1,%eax
80102e74:	52                   	push   %edx
80102e75:	50                   	push   %eax
80102e76:	e8 ef fe ff ff       	call   80102d6a <ioapicwrite>
80102e7b:	83 c4 08             	add    $0x8,%esp
80102e7e:	eb 01                	jmp    80102e81 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102e80:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102e81:	c9                   	leave  
80102e82:	c3                   	ret    

80102e83 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102e83:	55                   	push   %ebp
80102e84:	89 e5                	mov    %esp,%ebp
80102e86:	8b 45 08             	mov    0x8(%ebp),%eax
80102e89:	05 00 00 00 80       	add    $0x80000000,%eax
80102e8e:	5d                   	pop    %ebp
80102e8f:	c3                   	ret    

80102e90 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102e90:	55                   	push   %ebp
80102e91:	89 e5                	mov    %esp,%ebp
80102e93:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102e96:	83 ec 08             	sub    $0x8,%esp
80102e99:	68 6a a8 10 80       	push   $0x8010a86a
80102e9e:	68 40 52 11 80       	push   $0x80115240
80102ea3:	e8 84 3e 00 00       	call   80106d2c <initlock>
80102ea8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102eab:	c7 05 74 52 11 80 00 	movl   $0x0,0x80115274
80102eb2:	00 00 00 
  freerange(vstart, vend);
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	ff 75 0c             	pushl  0xc(%ebp)
80102ebb:	ff 75 08             	pushl  0x8(%ebp)
80102ebe:	e8 2a 00 00 00       	call   80102eed <freerange>
80102ec3:	83 c4 10             	add    $0x10,%esp
}
80102ec6:	90                   	nop
80102ec7:	c9                   	leave  
80102ec8:	c3                   	ret    

80102ec9 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ec9:	55                   	push   %ebp
80102eca:	89 e5                	mov    %esp,%ebp
80102ecc:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102ecf:	83 ec 08             	sub    $0x8,%esp
80102ed2:	ff 75 0c             	pushl  0xc(%ebp)
80102ed5:	ff 75 08             	pushl  0x8(%ebp)
80102ed8:	e8 10 00 00 00       	call   80102eed <freerange>
80102edd:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ee0:	c7 05 74 52 11 80 01 	movl   $0x1,0x80115274
80102ee7:	00 00 00 
}
80102eea:	90                   	nop
80102eeb:	c9                   	leave  
80102eec:	c3                   	ret    

80102eed <freerange>:

void
freerange(void *vstart, void *vend)
{
80102eed:	55                   	push   %ebp
80102eee:	89 e5                	mov    %esp,%ebp
80102ef0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef6:	05 ff 0f 00 00       	add    $0xfff,%eax
80102efb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f03:	eb 15                	jmp    80102f1a <freerange+0x2d>
    kfree(p);
80102f05:	83 ec 0c             	sub    $0xc,%esp
80102f08:	ff 75 f4             	pushl  -0xc(%ebp)
80102f0b:	e8 1a 00 00 00       	call   80102f2a <kfree>
80102f10:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f13:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f1d:	05 00 10 00 00       	add    $0x1000,%eax
80102f22:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102f25:	76 de                	jbe    80102f05 <freerange+0x18>
    kfree(p);
}
80102f27:	90                   	nop
80102f28:	c9                   	leave  
80102f29:	c3                   	ret    

80102f2a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102f2a:	55                   	push   %ebp
80102f2b:	89 e5                	mov    %esp,%ebp
80102f2d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102f30:	8b 45 08             	mov    0x8(%ebp),%eax
80102f33:	25 ff 0f 00 00       	and    $0xfff,%eax
80102f38:	85 c0                	test   %eax,%eax
80102f3a:	75 1b                	jne    80102f57 <kfree+0x2d>
80102f3c:	81 7d 08 3c 89 11 80 	cmpl   $0x8011893c,0x8(%ebp)
80102f43:	72 12                	jb     80102f57 <kfree+0x2d>
80102f45:	ff 75 08             	pushl  0x8(%ebp)
80102f48:	e8 36 ff ff ff       	call   80102e83 <v2p>
80102f4d:	83 c4 04             	add    $0x4,%esp
80102f50:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102f55:	76 0d                	jbe    80102f64 <kfree+0x3a>
    panic("kfree");
80102f57:	83 ec 0c             	sub    $0xc,%esp
80102f5a:	68 6f a8 10 80       	push   $0x8010a86f
80102f5f:	e8 02 d6 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102f64:	83 ec 04             	sub    $0x4,%esp
80102f67:	68 00 10 00 00       	push   $0x1000
80102f6c:	6a 01                	push   $0x1
80102f6e:	ff 75 08             	pushl  0x8(%ebp)
80102f71:	e8 3b 40 00 00       	call   80106fb1 <memset>
80102f76:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102f79:	a1 74 52 11 80       	mov    0x80115274,%eax
80102f7e:	85 c0                	test   %eax,%eax
80102f80:	74 10                	je     80102f92 <kfree+0x68>
    acquire(&kmem.lock);
80102f82:	83 ec 0c             	sub    $0xc,%esp
80102f85:	68 40 52 11 80       	push   $0x80115240
80102f8a:	e8 bf 3d 00 00       	call   80106d4e <acquire>
80102f8f:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102f92:	8b 45 08             	mov    0x8(%ebp),%eax
80102f95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102f98:	8b 15 78 52 11 80    	mov    0x80115278,%edx
80102f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa6:	a3 78 52 11 80       	mov    %eax,0x80115278
  if(kmem.use_lock)
80102fab:	a1 74 52 11 80       	mov    0x80115274,%eax
80102fb0:	85 c0                	test   %eax,%eax
80102fb2:	74 10                	je     80102fc4 <kfree+0x9a>
    release(&kmem.lock);
80102fb4:	83 ec 0c             	sub    $0xc,%esp
80102fb7:	68 40 52 11 80       	push   $0x80115240
80102fbc:	e8 f4 3d 00 00       	call   80106db5 <release>
80102fc1:	83 c4 10             	add    $0x10,%esp
}
80102fc4:	90                   	nop
80102fc5:	c9                   	leave  
80102fc6:	c3                   	ret    

80102fc7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102fc7:	55                   	push   %ebp
80102fc8:	89 e5                	mov    %esp,%ebp
80102fca:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102fcd:	a1 74 52 11 80       	mov    0x80115274,%eax
80102fd2:	85 c0                	test   %eax,%eax
80102fd4:	74 10                	je     80102fe6 <kalloc+0x1f>
    acquire(&kmem.lock);
80102fd6:	83 ec 0c             	sub    $0xc,%esp
80102fd9:	68 40 52 11 80       	push   $0x80115240
80102fde:	e8 6b 3d 00 00       	call   80106d4e <acquire>
80102fe3:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102fe6:	a1 78 52 11 80       	mov    0x80115278,%eax
80102feb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102fee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ff2:	74 0a                	je     80102ffe <kalloc+0x37>
    kmem.freelist = r->next;
80102ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ff7:	8b 00                	mov    (%eax),%eax
80102ff9:	a3 78 52 11 80       	mov    %eax,0x80115278
  if(kmem.use_lock)
80102ffe:	a1 74 52 11 80       	mov    0x80115274,%eax
80103003:	85 c0                	test   %eax,%eax
80103005:	74 10                	je     80103017 <kalloc+0x50>
    release(&kmem.lock);
80103007:	83 ec 0c             	sub    $0xc,%esp
8010300a:	68 40 52 11 80       	push   $0x80115240
8010300f:	e8 a1 3d 00 00       	call   80106db5 <release>
80103014:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80103017:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010301a:	c9                   	leave  
8010301b:	c3                   	ret    

8010301c <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 14             	sub    $0x14,%esp
80103022:	8b 45 08             	mov    0x8(%ebp),%eax
80103025:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103029:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010302d:	89 c2                	mov    %eax,%edx
8010302f:	ec                   	in     (%dx),%al
80103030:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103033:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103037:	c9                   	leave  
80103038:	c3                   	ret    

80103039 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103039:	55                   	push   %ebp
8010303a:	89 e5                	mov    %esp,%ebp
8010303c:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010303f:	6a 64                	push   $0x64
80103041:	e8 d6 ff ff ff       	call   8010301c <inb>
80103046:	83 c4 04             	add    $0x4,%esp
80103049:	0f b6 c0             	movzbl %al,%eax
8010304c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010304f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103052:	83 e0 01             	and    $0x1,%eax
80103055:	85 c0                	test   %eax,%eax
80103057:	75 0a                	jne    80103063 <kbdgetc+0x2a>
    return -1;
80103059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010305e:	e9 23 01 00 00       	jmp    80103186 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103063:	6a 60                	push   $0x60
80103065:	e8 b2 ff ff ff       	call   8010301c <inb>
8010306a:	83 c4 04             	add    $0x4,%esp
8010306d:	0f b6 c0             	movzbl %al,%eax
80103070:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103073:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010307a:	75 17                	jne    80103093 <kbdgetc+0x5a>
    shift |= E0ESC;
8010307c:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80103081:	83 c8 40             	or     $0x40,%eax
80103084:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
    return 0;
80103089:	b8 00 00 00 00       	mov    $0x0,%eax
8010308e:	e9 f3 00 00 00       	jmp    80103186 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103093:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103096:	25 80 00 00 00       	and    $0x80,%eax
8010309b:	85 c0                	test   %eax,%eax
8010309d:	74 45                	je     801030e4 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010309f:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
801030a4:	83 e0 40             	and    $0x40,%eax
801030a7:	85 c0                	test   %eax,%eax
801030a9:	75 08                	jne    801030b3 <kbdgetc+0x7a>
801030ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030ae:	83 e0 7f             	and    $0x7f,%eax
801030b1:	eb 03                	jmp    801030b6 <kbdgetc+0x7d>
801030b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801030b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030bc:	05 20 c0 10 80       	add    $0x8010c020,%eax
801030c1:	0f b6 00             	movzbl (%eax),%eax
801030c4:	83 c8 40             	or     $0x40,%eax
801030c7:	0f b6 c0             	movzbl %al,%eax
801030ca:	f7 d0                	not    %eax
801030cc:	89 c2                	mov    %eax,%edx
801030ce:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
801030d3:	21 d0                	and    %edx,%eax
801030d5:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
    return 0;
801030da:	b8 00 00 00 00       	mov    $0x0,%eax
801030df:	e9 a2 00 00 00       	jmp    80103186 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801030e4:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
801030e9:	83 e0 40             	and    $0x40,%eax
801030ec:	85 c0                	test   %eax,%eax
801030ee:	74 14                	je     80103104 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801030f0:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801030f7:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
801030fc:	83 e0 bf             	and    $0xffffffbf,%eax
801030ff:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
  }

  shift |= shiftcode[data];
80103104:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103107:	05 20 c0 10 80       	add    $0x8010c020,%eax
8010310c:	0f b6 00             	movzbl (%eax),%eax
8010310f:	0f b6 d0             	movzbl %al,%edx
80103112:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80103117:	09 d0                	or     %edx,%eax
80103119:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
  shift ^= togglecode[data];
8010311e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103121:	05 20 c1 10 80       	add    $0x8010c120,%eax
80103126:	0f b6 00             	movzbl (%eax),%eax
80103129:	0f b6 d0             	movzbl %al,%edx
8010312c:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
80103131:	31 d0                	xor    %edx,%eax
80103133:	a3 5c e6 10 80       	mov    %eax,0x8010e65c
  c = charcode[shift & (CTL | SHIFT)][data];
80103138:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
8010313d:	83 e0 03             	and    $0x3,%eax
80103140:	8b 14 85 20 c5 10 80 	mov    -0x7fef3ae0(,%eax,4),%edx
80103147:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010314a:	01 d0                	add    %edx,%eax
8010314c:	0f b6 00             	movzbl (%eax),%eax
8010314f:	0f b6 c0             	movzbl %al,%eax
80103152:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103155:	a1 5c e6 10 80       	mov    0x8010e65c,%eax
8010315a:	83 e0 08             	and    $0x8,%eax
8010315d:	85 c0                	test   %eax,%eax
8010315f:	74 22                	je     80103183 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103161:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103165:	76 0c                	jbe    80103173 <kbdgetc+0x13a>
80103167:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010316b:	77 06                	ja     80103173 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010316d:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103171:	eb 10                	jmp    80103183 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103173:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103177:	76 0a                	jbe    80103183 <kbdgetc+0x14a>
80103179:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010317d:	77 04                	ja     80103183 <kbdgetc+0x14a>
      c += 'a' - 'A';
8010317f:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103183:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103186:	c9                   	leave  
80103187:	c3                   	ret    

80103188 <kbdintr>:

void
kbdintr(void)
{
80103188:	55                   	push   %ebp
80103189:	89 e5                	mov    %esp,%ebp
8010318b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010318e:	83 ec 0c             	sub    $0xc,%esp
80103191:	68 39 30 10 80       	push   $0x80103039
80103196:	e8 5e d6 ff ff       	call   801007f9 <consoleintr>
8010319b:	83 c4 10             	add    $0x10,%esp
}
8010319e:	90                   	nop
8010319f:	c9                   	leave  
801031a0:	c3                   	ret    

801031a1 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801031a1:	55                   	push   %ebp
801031a2:	89 e5                	mov    %esp,%ebp
801031a4:	83 ec 14             	sub    $0x14,%esp
801031a7:	8b 45 08             	mov    0x8(%ebp),%eax
801031aa:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801031ae:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801031b2:	89 c2                	mov    %eax,%edx
801031b4:	ec                   	in     (%dx),%al
801031b5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801031b8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801031bc:	c9                   	leave  
801031bd:	c3                   	ret    

801031be <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031be:	55                   	push   %ebp
801031bf:	89 e5                	mov    %esp,%ebp
801031c1:	83 ec 08             	sub    $0x8,%esp
801031c4:	8b 55 08             	mov    0x8(%ebp),%edx
801031c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ca:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801031ce:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801031d1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801031d5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801031d9:	ee                   	out    %al,(%dx)
}
801031da:	90                   	nop
801031db:	c9                   	leave  
801031dc:	c3                   	ret    

801031dd <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801031dd:	55                   	push   %ebp
801031de:	89 e5                	mov    %esp,%ebp
801031e0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031e3:	9c                   	pushf  
801031e4:	58                   	pop    %eax
801031e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801031e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801031eb:	c9                   	leave  
801031ec:	c3                   	ret    

801031ed <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801031ed:	55                   	push   %ebp
801031ee:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801031f0:	a1 7c 52 11 80       	mov    0x8011527c,%eax
801031f5:	8b 55 08             	mov    0x8(%ebp),%edx
801031f8:	c1 e2 02             	shl    $0x2,%edx
801031fb:	01 c2                	add    %eax,%edx
801031fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103200:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103202:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80103207:	83 c0 20             	add    $0x20,%eax
8010320a:	8b 00                	mov    (%eax),%eax
}
8010320c:	90                   	nop
8010320d:	5d                   	pop    %ebp
8010320e:	c3                   	ret    

8010320f <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
8010320f:	55                   	push   %ebp
80103210:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80103212:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80103217:	85 c0                	test   %eax,%eax
80103219:	0f 84 0b 01 00 00    	je     8010332a <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010321f:	68 3f 01 00 00       	push   $0x13f
80103224:	6a 3c                	push   $0x3c
80103226:	e8 c2 ff ff ff       	call   801031ed <lapicw>
8010322b:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010322e:	6a 0b                	push   $0xb
80103230:	68 f8 00 00 00       	push   $0xf8
80103235:	e8 b3 ff ff ff       	call   801031ed <lapicw>
8010323a:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010323d:	68 20 00 02 00       	push   $0x20020
80103242:	68 c8 00 00 00       	push   $0xc8
80103247:	e8 a1 ff ff ff       	call   801031ed <lapicw>
8010324c:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
8010324f:	68 40 42 0f 00       	push   $0xf4240
80103254:	68 e0 00 00 00       	push   $0xe0
80103259:	e8 8f ff ff ff       	call   801031ed <lapicw>
8010325e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103261:	68 00 00 01 00       	push   $0x10000
80103266:	68 d4 00 00 00       	push   $0xd4
8010326b:	e8 7d ff ff ff       	call   801031ed <lapicw>
80103270:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103273:	68 00 00 01 00       	push   $0x10000
80103278:	68 d8 00 00 00       	push   $0xd8
8010327d:	e8 6b ff ff ff       	call   801031ed <lapicw>
80103282:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103285:	a1 7c 52 11 80       	mov    0x8011527c,%eax
8010328a:	83 c0 30             	add    $0x30,%eax
8010328d:	8b 00                	mov    (%eax),%eax
8010328f:	c1 e8 10             	shr    $0x10,%eax
80103292:	0f b6 c0             	movzbl %al,%eax
80103295:	83 f8 03             	cmp    $0x3,%eax
80103298:	76 12                	jbe    801032ac <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010329a:	68 00 00 01 00       	push   $0x10000
8010329f:	68 d0 00 00 00       	push   $0xd0
801032a4:	e8 44 ff ff ff       	call   801031ed <lapicw>
801032a9:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801032ac:	6a 33                	push   $0x33
801032ae:	68 dc 00 00 00       	push   $0xdc
801032b3:	e8 35 ff ff ff       	call   801031ed <lapicw>
801032b8:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801032bb:	6a 00                	push   $0x0
801032bd:	68 a0 00 00 00       	push   $0xa0
801032c2:	e8 26 ff ff ff       	call   801031ed <lapicw>
801032c7:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
801032ca:	6a 00                	push   $0x0
801032cc:	68 a0 00 00 00       	push   $0xa0
801032d1:	e8 17 ff ff ff       	call   801031ed <lapicw>
801032d6:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801032d9:	6a 00                	push   $0x0
801032db:	6a 2c                	push   $0x2c
801032dd:	e8 0b ff ff ff       	call   801031ed <lapicw>
801032e2:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801032e5:	6a 00                	push   $0x0
801032e7:	68 c4 00 00 00       	push   $0xc4
801032ec:	e8 fc fe ff ff       	call   801031ed <lapicw>
801032f1:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801032f4:	68 00 85 08 00       	push   $0x88500
801032f9:	68 c0 00 00 00       	push   $0xc0
801032fe:	e8 ea fe ff ff       	call   801031ed <lapicw>
80103303:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103306:	90                   	nop
80103307:	a1 7c 52 11 80       	mov    0x8011527c,%eax
8010330c:	05 00 03 00 00       	add    $0x300,%eax
80103311:	8b 00                	mov    (%eax),%eax
80103313:	25 00 10 00 00       	and    $0x1000,%eax
80103318:	85 c0                	test   %eax,%eax
8010331a:	75 eb                	jne    80103307 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010331c:	6a 00                	push   $0x0
8010331e:	6a 20                	push   $0x20
80103320:	e8 c8 fe ff ff       	call   801031ed <lapicw>
80103325:	83 c4 08             	add    $0x8,%esp
80103328:	eb 01                	jmp    8010332b <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010332a:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010332b:	c9                   	leave  
8010332c:	c3                   	ret    

8010332d <cpunum>:

int
cpunum(void)
{
8010332d:	55                   	push   %ebp
8010332e:	89 e5                	mov    %esp,%ebp
80103330:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103333:	e8 a5 fe ff ff       	call   801031dd <readeflags>
80103338:	25 00 02 00 00       	and    $0x200,%eax
8010333d:	85 c0                	test   %eax,%eax
8010333f:	74 26                	je     80103367 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103341:	a1 60 e6 10 80       	mov    0x8010e660,%eax
80103346:	8d 50 01             	lea    0x1(%eax),%edx
80103349:	89 15 60 e6 10 80    	mov    %edx,0x8010e660
8010334f:	85 c0                	test   %eax,%eax
80103351:	75 14                	jne    80103367 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103353:	8b 45 04             	mov    0x4(%ebp),%eax
80103356:	83 ec 08             	sub    $0x8,%esp
80103359:	50                   	push   %eax
8010335a:	68 78 a8 10 80       	push   $0x8010a878
8010335f:	e8 62 d0 ff ff       	call   801003c6 <cprintf>
80103364:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103367:	a1 7c 52 11 80       	mov    0x8011527c,%eax
8010336c:	85 c0                	test   %eax,%eax
8010336e:	74 0f                	je     8010337f <cpunum+0x52>
    return lapic[ID]>>24;
80103370:	a1 7c 52 11 80       	mov    0x8011527c,%eax
80103375:	83 c0 20             	add    $0x20,%eax
80103378:	8b 00                	mov    (%eax),%eax
8010337a:	c1 e8 18             	shr    $0x18,%eax
8010337d:	eb 05                	jmp    80103384 <cpunum+0x57>
  return 0;
8010337f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103384:	c9                   	leave  
80103385:	c3                   	ret    

80103386 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103386:	55                   	push   %ebp
80103387:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103389:	a1 7c 52 11 80       	mov    0x8011527c,%eax
8010338e:	85 c0                	test   %eax,%eax
80103390:	74 0c                	je     8010339e <lapiceoi+0x18>
    lapicw(EOI, 0);
80103392:	6a 00                	push   $0x0
80103394:	6a 2c                	push   $0x2c
80103396:	e8 52 fe ff ff       	call   801031ed <lapicw>
8010339b:	83 c4 08             	add    $0x8,%esp
}
8010339e:	90                   	nop
8010339f:	c9                   	leave  
801033a0:	c3                   	ret    

801033a1 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033a1:	55                   	push   %ebp
801033a2:	89 e5                	mov    %esp,%ebp
}
801033a4:	90                   	nop
801033a5:	5d                   	pop    %ebp
801033a6:	c3                   	ret    

801033a7 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033a7:	55                   	push   %ebp
801033a8:	89 e5                	mov    %esp,%ebp
801033aa:	83 ec 14             	sub    $0x14,%esp
801033ad:	8b 45 08             	mov    0x8(%ebp),%eax
801033b0:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033b3:	6a 0f                	push   $0xf
801033b5:	6a 70                	push   $0x70
801033b7:	e8 02 fe ff ff       	call   801031be <outb>
801033bc:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801033bf:	6a 0a                	push   $0xa
801033c1:	6a 71                	push   $0x71
801033c3:	e8 f6 fd ff ff       	call   801031be <outb>
801033c8:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801033cb:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801033d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801033d5:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801033da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801033dd:	83 c0 02             	add    $0x2,%eax
801033e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801033e3:	c1 ea 04             	shr    $0x4,%edx
801033e6:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801033e9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801033ed:	c1 e0 18             	shl    $0x18,%eax
801033f0:	50                   	push   %eax
801033f1:	68 c4 00 00 00       	push   $0xc4
801033f6:	e8 f2 fd ff ff       	call   801031ed <lapicw>
801033fb:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801033fe:	68 00 c5 00 00       	push   $0xc500
80103403:	68 c0 00 00 00       	push   $0xc0
80103408:	e8 e0 fd ff ff       	call   801031ed <lapicw>
8010340d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103410:	68 c8 00 00 00       	push   $0xc8
80103415:	e8 87 ff ff ff       	call   801033a1 <microdelay>
8010341a:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010341d:	68 00 85 00 00       	push   $0x8500
80103422:	68 c0 00 00 00       	push   $0xc0
80103427:	e8 c1 fd ff ff       	call   801031ed <lapicw>
8010342c:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010342f:	6a 64                	push   $0x64
80103431:	e8 6b ff ff ff       	call   801033a1 <microdelay>
80103436:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103439:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103440:	eb 3d                	jmp    8010347f <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103442:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103446:	c1 e0 18             	shl    $0x18,%eax
80103449:	50                   	push   %eax
8010344a:	68 c4 00 00 00       	push   $0xc4
8010344f:	e8 99 fd ff ff       	call   801031ed <lapicw>
80103454:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103457:	8b 45 0c             	mov    0xc(%ebp),%eax
8010345a:	c1 e8 0c             	shr    $0xc,%eax
8010345d:	80 cc 06             	or     $0x6,%ah
80103460:	50                   	push   %eax
80103461:	68 c0 00 00 00       	push   $0xc0
80103466:	e8 82 fd ff ff       	call   801031ed <lapicw>
8010346b:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010346e:	68 c8 00 00 00       	push   $0xc8
80103473:	e8 29 ff ff ff       	call   801033a1 <microdelay>
80103478:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010347b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010347f:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103483:	7e bd                	jle    80103442 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103485:	90                   	nop
80103486:	c9                   	leave  
80103487:	c3                   	ret    

80103488 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103488:	55                   	push   %ebp
80103489:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010348b:	8b 45 08             	mov    0x8(%ebp),%eax
8010348e:	0f b6 c0             	movzbl %al,%eax
80103491:	50                   	push   %eax
80103492:	6a 70                	push   $0x70
80103494:	e8 25 fd ff ff       	call   801031be <outb>
80103499:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010349c:	68 c8 00 00 00       	push   $0xc8
801034a1:	e8 fb fe ff ff       	call   801033a1 <microdelay>
801034a6:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801034a9:	6a 71                	push   $0x71
801034ab:	e8 f1 fc ff ff       	call   801031a1 <inb>
801034b0:	83 c4 04             	add    $0x4,%esp
801034b3:	0f b6 c0             	movzbl %al,%eax
}
801034b6:	c9                   	leave  
801034b7:	c3                   	ret    

801034b8 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801034b8:	55                   	push   %ebp
801034b9:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801034bb:	6a 00                	push   $0x0
801034bd:	e8 c6 ff ff ff       	call   80103488 <cmos_read>
801034c2:	83 c4 04             	add    $0x4,%esp
801034c5:	89 c2                	mov    %eax,%edx
801034c7:	8b 45 08             	mov    0x8(%ebp),%eax
801034ca:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801034cc:	6a 02                	push   $0x2
801034ce:	e8 b5 ff ff ff       	call   80103488 <cmos_read>
801034d3:	83 c4 04             	add    $0x4,%esp
801034d6:	89 c2                	mov    %eax,%edx
801034d8:	8b 45 08             	mov    0x8(%ebp),%eax
801034db:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801034de:	6a 04                	push   $0x4
801034e0:	e8 a3 ff ff ff       	call   80103488 <cmos_read>
801034e5:	83 c4 04             	add    $0x4,%esp
801034e8:	89 c2                	mov    %eax,%edx
801034ea:	8b 45 08             	mov    0x8(%ebp),%eax
801034ed:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801034f0:	6a 07                	push   $0x7
801034f2:	e8 91 ff ff ff       	call   80103488 <cmos_read>
801034f7:	83 c4 04             	add    $0x4,%esp
801034fa:	89 c2                	mov    %eax,%edx
801034fc:	8b 45 08             	mov    0x8(%ebp),%eax
801034ff:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103502:	6a 08                	push   $0x8
80103504:	e8 7f ff ff ff       	call   80103488 <cmos_read>
80103509:	83 c4 04             	add    $0x4,%esp
8010350c:	89 c2                	mov    %eax,%edx
8010350e:	8b 45 08             	mov    0x8(%ebp),%eax
80103511:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103514:	6a 09                	push   $0x9
80103516:	e8 6d ff ff ff       	call   80103488 <cmos_read>
8010351b:	83 c4 04             	add    $0x4,%esp
8010351e:	89 c2                	mov    %eax,%edx
80103520:	8b 45 08             	mov    0x8(%ebp),%eax
80103523:	89 50 14             	mov    %edx,0x14(%eax)
}
80103526:	90                   	nop
80103527:	c9                   	leave  
80103528:	c3                   	ret    

80103529 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103529:	55                   	push   %ebp
8010352a:	89 e5                	mov    %esp,%ebp
8010352c:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010352f:	6a 0b                	push   $0xb
80103531:	e8 52 ff ff ff       	call   80103488 <cmos_read>
80103536:	83 c4 04             	add    $0x4,%esp
80103539:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010353c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010353f:	83 e0 04             	and    $0x4,%eax
80103542:	85 c0                	test   %eax,%eax
80103544:	0f 94 c0             	sete   %al
80103547:	0f b6 c0             	movzbl %al,%eax
8010354a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010354d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103550:	50                   	push   %eax
80103551:	e8 62 ff ff ff       	call   801034b8 <fill_rtcdate>
80103556:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103559:	6a 0a                	push   $0xa
8010355b:	e8 28 ff ff ff       	call   80103488 <cmos_read>
80103560:	83 c4 04             	add    $0x4,%esp
80103563:	25 80 00 00 00       	and    $0x80,%eax
80103568:	85 c0                	test   %eax,%eax
8010356a:	75 27                	jne    80103593 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010356c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010356f:	50                   	push   %eax
80103570:	e8 43 ff ff ff       	call   801034b8 <fill_rtcdate>
80103575:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103578:	83 ec 04             	sub    $0x4,%esp
8010357b:	6a 18                	push   $0x18
8010357d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103580:	50                   	push   %eax
80103581:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103584:	50                   	push   %eax
80103585:	e8 8e 3a 00 00       	call   80107018 <memcmp>
8010358a:	83 c4 10             	add    $0x10,%esp
8010358d:	85 c0                	test   %eax,%eax
8010358f:	74 05                	je     80103596 <cmostime+0x6d>
80103591:	eb ba                	jmp    8010354d <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103593:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103594:	eb b7                	jmp    8010354d <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103596:	90                   	nop
  }

  // convert
  if (bcd) {
80103597:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010359b:	0f 84 b4 00 00 00    	je     80103655 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035a4:	c1 e8 04             	shr    $0x4,%eax
801035a7:	89 c2                	mov    %eax,%edx
801035a9:	89 d0                	mov    %edx,%eax
801035ab:	c1 e0 02             	shl    $0x2,%eax
801035ae:	01 d0                	add    %edx,%eax
801035b0:	01 c0                	add    %eax,%eax
801035b2:	89 c2                	mov    %eax,%edx
801035b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035b7:	83 e0 0f             	and    $0xf,%eax
801035ba:	01 d0                	add    %edx,%eax
801035bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801035bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035c2:	c1 e8 04             	shr    $0x4,%eax
801035c5:	89 c2                	mov    %eax,%edx
801035c7:	89 d0                	mov    %edx,%eax
801035c9:	c1 e0 02             	shl    $0x2,%eax
801035cc:	01 d0                	add    %edx,%eax
801035ce:	01 c0                	add    %eax,%eax
801035d0:	89 c2                	mov    %eax,%edx
801035d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035d5:	83 e0 0f             	and    $0xf,%eax
801035d8:	01 d0                	add    %edx,%eax
801035da:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801035dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801035e0:	c1 e8 04             	shr    $0x4,%eax
801035e3:	89 c2                	mov    %eax,%edx
801035e5:	89 d0                	mov    %edx,%eax
801035e7:	c1 e0 02             	shl    $0x2,%eax
801035ea:	01 d0                	add    %edx,%eax
801035ec:	01 c0                	add    %eax,%eax
801035ee:	89 c2                	mov    %eax,%edx
801035f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801035f3:	83 e0 0f             	and    $0xf,%eax
801035f6:	01 d0                	add    %edx,%eax
801035f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801035fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801035fe:	c1 e8 04             	shr    $0x4,%eax
80103601:	89 c2                	mov    %eax,%edx
80103603:	89 d0                	mov    %edx,%eax
80103605:	c1 e0 02             	shl    $0x2,%eax
80103608:	01 d0                	add    %edx,%eax
8010360a:	01 c0                	add    %eax,%eax
8010360c:	89 c2                	mov    %eax,%edx
8010360e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103611:	83 e0 0f             	and    $0xf,%eax
80103614:	01 d0                	add    %edx,%eax
80103616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103619:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010361c:	c1 e8 04             	shr    $0x4,%eax
8010361f:	89 c2                	mov    %eax,%edx
80103621:	89 d0                	mov    %edx,%eax
80103623:	c1 e0 02             	shl    $0x2,%eax
80103626:	01 d0                	add    %edx,%eax
80103628:	01 c0                	add    %eax,%eax
8010362a:	89 c2                	mov    %eax,%edx
8010362c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010362f:	83 e0 0f             	and    $0xf,%eax
80103632:	01 d0                	add    %edx,%eax
80103634:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103637:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010363a:	c1 e8 04             	shr    $0x4,%eax
8010363d:	89 c2                	mov    %eax,%edx
8010363f:	89 d0                	mov    %edx,%eax
80103641:	c1 e0 02             	shl    $0x2,%eax
80103644:	01 d0                	add    %edx,%eax
80103646:	01 c0                	add    %eax,%eax
80103648:	89 c2                	mov    %eax,%edx
8010364a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010364d:	83 e0 0f             	and    $0xf,%eax
80103650:	01 d0                	add    %edx,%eax
80103652:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103655:	8b 45 08             	mov    0x8(%ebp),%eax
80103658:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010365b:	89 10                	mov    %edx,(%eax)
8010365d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103660:	89 50 04             	mov    %edx,0x4(%eax)
80103663:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103666:	89 50 08             	mov    %edx,0x8(%eax)
80103669:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010366c:	89 50 0c             	mov    %edx,0xc(%eax)
8010366f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103672:	89 50 10             	mov    %edx,0x10(%eax)
80103675:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103678:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010367b:	8b 45 08             	mov    0x8(%ebp),%eax
8010367e:	8b 40 14             	mov    0x14(%eax),%eax
80103681:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103687:	8b 45 08             	mov    0x8(%ebp),%eax
8010368a:	89 50 14             	mov    %edx,0x14(%eax)
}
8010368d:	90                   	nop
8010368e:	c9                   	leave  
8010368f:	c3                   	ret    

80103690 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103690:	55                   	push   %ebp
80103691:	89 e5                	mov    %esp,%ebp
80103693:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103696:	83 ec 08             	sub    $0x8,%esp
80103699:	68 a4 a8 10 80       	push   $0x8010a8a4
8010369e:	68 80 52 11 80       	push   $0x80115280
801036a3:	e8 84 36 00 00       	call   80106d2c <initlock>
801036a8:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801036ab:	83 ec 08             	sub    $0x8,%esp
801036ae:	8d 45 dc             	lea    -0x24(%ebp),%eax
801036b1:	50                   	push   %eax
801036b2:	ff 75 08             	pushl  0x8(%ebp)
801036b5:	e8 f6 dd ff ff       	call   801014b0 <readsb>
801036ba:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801036bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036c0:	a3 b4 52 11 80       	mov    %eax,0x801152b4
  log.size = sb.nlog;
801036c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801036c8:	a3 b8 52 11 80       	mov    %eax,0x801152b8
  log.dev = dev;
801036cd:	8b 45 08             	mov    0x8(%ebp),%eax
801036d0:	a3 c4 52 11 80       	mov    %eax,0x801152c4
  recover_from_log();
801036d5:	e8 b2 01 00 00       	call   8010388c <recover_from_log>
}
801036da:	90                   	nop
801036db:	c9                   	leave  
801036dc:	c3                   	ret    

801036dd <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801036dd:	55                   	push   %ebp
801036de:	89 e5                	mov    %esp,%ebp
801036e0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036ea:	e9 95 00 00 00       	jmp    80103784 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801036ef:	8b 15 b4 52 11 80    	mov    0x801152b4,%edx
801036f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036f8:	01 d0                	add    %edx,%eax
801036fa:	83 c0 01             	add    $0x1,%eax
801036fd:	89 c2                	mov    %eax,%edx
801036ff:	a1 c4 52 11 80       	mov    0x801152c4,%eax
80103704:	83 ec 08             	sub    $0x8,%esp
80103707:	52                   	push   %edx
80103708:	50                   	push   %eax
80103709:	e8 a8 ca ff ff       	call   801001b6 <bread>
8010370e:	83 c4 10             	add    $0x10,%esp
80103711:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103717:	83 c0 10             	add    $0x10,%eax
8010371a:	8b 04 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%eax
80103721:	89 c2                	mov    %eax,%edx
80103723:	a1 c4 52 11 80       	mov    0x801152c4,%eax
80103728:	83 ec 08             	sub    $0x8,%esp
8010372b:	52                   	push   %edx
8010372c:	50                   	push   %eax
8010372d:	e8 84 ca ff ff       	call   801001b6 <bread>
80103732:	83 c4 10             	add    $0x10,%esp
80103735:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010373b:	8d 50 18             	lea    0x18(%eax),%edx
8010373e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103741:	83 c0 18             	add    $0x18,%eax
80103744:	83 ec 04             	sub    $0x4,%esp
80103747:	68 00 02 00 00       	push   $0x200
8010374c:	52                   	push   %edx
8010374d:	50                   	push   %eax
8010374e:	e8 1d 39 00 00       	call   80107070 <memmove>
80103753:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103756:	83 ec 0c             	sub    $0xc,%esp
80103759:	ff 75 ec             	pushl  -0x14(%ebp)
8010375c:	e8 8e ca ff ff       	call   801001ef <bwrite>
80103761:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103764:	83 ec 0c             	sub    $0xc,%esp
80103767:	ff 75 f0             	pushl  -0x10(%ebp)
8010376a:	e8 bf ca ff ff       	call   8010022e <brelse>
8010376f:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103772:	83 ec 0c             	sub    $0xc,%esp
80103775:	ff 75 ec             	pushl  -0x14(%ebp)
80103778:	e8 b1 ca ff ff       	call   8010022e <brelse>
8010377d:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103780:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103784:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103789:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010378c:	0f 8f 5d ff ff ff    	jg     801036ef <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103792:	90                   	nop
80103793:	c9                   	leave  
80103794:	c3                   	ret    

80103795 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103795:	55                   	push   %ebp
80103796:	89 e5                	mov    %esp,%ebp
80103798:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010379b:	a1 b4 52 11 80       	mov    0x801152b4,%eax
801037a0:	89 c2                	mov    %eax,%edx
801037a2:	a1 c4 52 11 80       	mov    0x801152c4,%eax
801037a7:	83 ec 08             	sub    $0x8,%esp
801037aa:	52                   	push   %edx
801037ab:	50                   	push   %eax
801037ac:	e8 05 ca ff ff       	call   801001b6 <bread>
801037b1:	83 c4 10             	add    $0x10,%esp
801037b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801037b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ba:	83 c0 18             	add    $0x18,%eax
801037bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037c3:	8b 00                	mov    (%eax),%eax
801037c5:	a3 c8 52 11 80       	mov    %eax,0x801152c8
  for (i = 0; i < log.lh.n; i++) {
801037ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037d1:	eb 1b                	jmp    801037ee <read_head+0x59>
    log.lh.block[i] = lh->block[i];
801037d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037d9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801037dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037e0:	83 c2 10             	add    $0x10,%edx
801037e3:	89 04 95 8c 52 11 80 	mov    %eax,-0x7feead74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801037ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037ee:	a1 c8 52 11 80       	mov    0x801152c8,%eax
801037f3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037f6:	7f db                	jg     801037d3 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801037f8:	83 ec 0c             	sub    $0xc,%esp
801037fb:	ff 75 f0             	pushl  -0x10(%ebp)
801037fe:	e8 2b ca ff ff       	call   8010022e <brelse>
80103803:	83 c4 10             	add    $0x10,%esp
}
80103806:	90                   	nop
80103807:	c9                   	leave  
80103808:	c3                   	ret    

80103809 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103809:	55                   	push   %ebp
8010380a:	89 e5                	mov    %esp,%ebp
8010380c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010380f:	a1 b4 52 11 80       	mov    0x801152b4,%eax
80103814:	89 c2                	mov    %eax,%edx
80103816:	a1 c4 52 11 80       	mov    0x801152c4,%eax
8010381b:	83 ec 08             	sub    $0x8,%esp
8010381e:	52                   	push   %edx
8010381f:	50                   	push   %eax
80103820:	e8 91 c9 ff ff       	call   801001b6 <bread>
80103825:	83 c4 10             	add    $0x10,%esp
80103828:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010382b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010382e:	83 c0 18             	add    $0x18,%eax
80103831:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103834:	8b 15 c8 52 11 80    	mov    0x801152c8,%edx
8010383a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010383d:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010383f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103846:	eb 1b                	jmp    80103863 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384b:	83 c0 10             	add    $0x10,%eax
8010384e:	8b 0c 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%ecx
80103855:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103858:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010385b:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010385f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103863:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103868:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010386b:	7f db                	jg     80103848 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010386d:	83 ec 0c             	sub    $0xc,%esp
80103870:	ff 75 f0             	pushl  -0x10(%ebp)
80103873:	e8 77 c9 ff ff       	call   801001ef <bwrite>
80103878:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010387b:	83 ec 0c             	sub    $0xc,%esp
8010387e:	ff 75 f0             	pushl  -0x10(%ebp)
80103881:	e8 a8 c9 ff ff       	call   8010022e <brelse>
80103886:	83 c4 10             	add    $0x10,%esp
}
80103889:	90                   	nop
8010388a:	c9                   	leave  
8010388b:	c3                   	ret    

8010388c <recover_from_log>:

static void
recover_from_log(void)
{
8010388c:	55                   	push   %ebp
8010388d:	89 e5                	mov    %esp,%ebp
8010388f:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103892:	e8 fe fe ff ff       	call   80103795 <read_head>
  install_trans(); // if committed, copy from log to disk
80103897:	e8 41 fe ff ff       	call   801036dd <install_trans>
  log.lh.n = 0;
8010389c:	c7 05 c8 52 11 80 00 	movl   $0x0,0x801152c8
801038a3:	00 00 00 
  write_head(); // clear the log
801038a6:	e8 5e ff ff ff       	call   80103809 <write_head>
}
801038ab:	90                   	nop
801038ac:	c9                   	leave  
801038ad:	c3                   	ret    

801038ae <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801038ae:	55                   	push   %ebp
801038af:	89 e5                	mov    %esp,%ebp
801038b1:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801038b4:	83 ec 0c             	sub    $0xc,%esp
801038b7:	68 80 52 11 80       	push   $0x80115280
801038bc:	e8 8d 34 00 00       	call   80106d4e <acquire>
801038c1:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801038c4:	a1 c0 52 11 80       	mov    0x801152c0,%eax
801038c9:	85 c0                	test   %eax,%eax
801038cb:	74 17                	je     801038e4 <begin_op+0x36>
      sleep(&log, &log.lock);
801038cd:	83 ec 08             	sub    $0x8,%esp
801038d0:	68 80 52 11 80       	push   $0x80115280
801038d5:	68 80 52 11 80       	push   $0x80115280
801038da:	e8 5a 21 00 00       	call   80105a39 <sleep>
801038df:	83 c4 10             	add    $0x10,%esp
801038e2:	eb e0                	jmp    801038c4 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801038e4:	8b 0d c8 52 11 80    	mov    0x801152c8,%ecx
801038ea:	a1 bc 52 11 80       	mov    0x801152bc,%eax
801038ef:	8d 50 01             	lea    0x1(%eax),%edx
801038f2:	89 d0                	mov    %edx,%eax
801038f4:	c1 e0 02             	shl    $0x2,%eax
801038f7:	01 d0                	add    %edx,%eax
801038f9:	01 c0                	add    %eax,%eax
801038fb:	01 c8                	add    %ecx,%eax
801038fd:	83 f8 1e             	cmp    $0x1e,%eax
80103900:	7e 17                	jle    80103919 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103902:	83 ec 08             	sub    $0x8,%esp
80103905:	68 80 52 11 80       	push   $0x80115280
8010390a:	68 80 52 11 80       	push   $0x80115280
8010390f:	e8 25 21 00 00       	call   80105a39 <sleep>
80103914:	83 c4 10             	add    $0x10,%esp
80103917:	eb ab                	jmp    801038c4 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103919:	a1 bc 52 11 80       	mov    0x801152bc,%eax
8010391e:	83 c0 01             	add    $0x1,%eax
80103921:	a3 bc 52 11 80       	mov    %eax,0x801152bc
      release(&log.lock);
80103926:	83 ec 0c             	sub    $0xc,%esp
80103929:	68 80 52 11 80       	push   $0x80115280
8010392e:	e8 82 34 00 00       	call   80106db5 <release>
80103933:	83 c4 10             	add    $0x10,%esp
      break;
80103936:	90                   	nop
    }
  }
}
80103937:	90                   	nop
80103938:	c9                   	leave  
80103939:	c3                   	ret    

8010393a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010393a:	55                   	push   %ebp
8010393b:	89 e5                	mov    %esp,%ebp
8010393d:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103940:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103947:	83 ec 0c             	sub    $0xc,%esp
8010394a:	68 80 52 11 80       	push   $0x80115280
8010394f:	e8 fa 33 00 00       	call   80106d4e <acquire>
80103954:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103957:	a1 bc 52 11 80       	mov    0x801152bc,%eax
8010395c:	83 e8 01             	sub    $0x1,%eax
8010395f:	a3 bc 52 11 80       	mov    %eax,0x801152bc
  if(log.committing)
80103964:	a1 c0 52 11 80       	mov    0x801152c0,%eax
80103969:	85 c0                	test   %eax,%eax
8010396b:	74 0d                	je     8010397a <end_op+0x40>
    panic("log.committing");
8010396d:	83 ec 0c             	sub    $0xc,%esp
80103970:	68 a8 a8 10 80       	push   $0x8010a8a8
80103975:	e8 ec cb ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
8010397a:	a1 bc 52 11 80       	mov    0x801152bc,%eax
8010397f:	85 c0                	test   %eax,%eax
80103981:	75 13                	jne    80103996 <end_op+0x5c>
    do_commit = 1;
80103983:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010398a:	c7 05 c0 52 11 80 01 	movl   $0x1,0x801152c0
80103991:	00 00 00 
80103994:	eb 10                	jmp    801039a6 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103996:	83 ec 0c             	sub    $0xc,%esp
80103999:	68 80 52 11 80       	push   $0x80115280
8010399e:	e8 a6 22 00 00       	call   80105c49 <wakeup>
801039a3:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801039a6:	83 ec 0c             	sub    $0xc,%esp
801039a9:	68 80 52 11 80       	push   $0x80115280
801039ae:	e8 02 34 00 00       	call   80106db5 <release>
801039b3:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801039b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801039ba:	74 3f                	je     801039fb <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801039bc:	e8 f5 00 00 00       	call   80103ab6 <commit>
    acquire(&log.lock);
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	68 80 52 11 80       	push   $0x80115280
801039c9:	e8 80 33 00 00       	call   80106d4e <acquire>
801039ce:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801039d1:	c7 05 c0 52 11 80 00 	movl   $0x0,0x801152c0
801039d8:	00 00 00 
    wakeup(&log);
801039db:	83 ec 0c             	sub    $0xc,%esp
801039de:	68 80 52 11 80       	push   $0x80115280
801039e3:	e8 61 22 00 00       	call   80105c49 <wakeup>
801039e8:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801039eb:	83 ec 0c             	sub    $0xc,%esp
801039ee:	68 80 52 11 80       	push   $0x80115280
801039f3:	e8 bd 33 00 00       	call   80106db5 <release>
801039f8:	83 c4 10             	add    $0x10,%esp
  }
}
801039fb:	90                   	nop
801039fc:	c9                   	leave  
801039fd:	c3                   	ret    

801039fe <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801039fe:	55                   	push   %ebp
801039ff:	89 e5                	mov    %esp,%ebp
80103a01:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a0b:	e9 95 00 00 00       	jmp    80103aa5 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103a10:	8b 15 b4 52 11 80    	mov    0x801152b4,%edx
80103a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a19:	01 d0                	add    %edx,%eax
80103a1b:	83 c0 01             	add    $0x1,%eax
80103a1e:	89 c2                	mov    %eax,%edx
80103a20:	a1 c4 52 11 80       	mov    0x801152c4,%eax
80103a25:	83 ec 08             	sub    $0x8,%esp
80103a28:	52                   	push   %edx
80103a29:	50                   	push   %eax
80103a2a:	e8 87 c7 ff ff       	call   801001b6 <bread>
80103a2f:	83 c4 10             	add    $0x10,%esp
80103a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a38:	83 c0 10             	add    $0x10,%eax
80103a3b:	8b 04 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%eax
80103a42:	89 c2                	mov    %eax,%edx
80103a44:	a1 c4 52 11 80       	mov    0x801152c4,%eax
80103a49:	83 ec 08             	sub    $0x8,%esp
80103a4c:	52                   	push   %edx
80103a4d:	50                   	push   %eax
80103a4e:	e8 63 c7 ff ff       	call   801001b6 <bread>
80103a53:	83 c4 10             	add    $0x10,%esp
80103a56:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a5c:	8d 50 18             	lea    0x18(%eax),%edx
80103a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a62:	83 c0 18             	add    $0x18,%eax
80103a65:	83 ec 04             	sub    $0x4,%esp
80103a68:	68 00 02 00 00       	push   $0x200
80103a6d:	52                   	push   %edx
80103a6e:	50                   	push   %eax
80103a6f:	e8 fc 35 00 00       	call   80107070 <memmove>
80103a74:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103a77:	83 ec 0c             	sub    $0xc,%esp
80103a7a:	ff 75 f0             	pushl  -0x10(%ebp)
80103a7d:	e8 6d c7 ff ff       	call   801001ef <bwrite>
80103a82:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103a85:	83 ec 0c             	sub    $0xc,%esp
80103a88:	ff 75 ec             	pushl  -0x14(%ebp)
80103a8b:	e8 9e c7 ff ff       	call   8010022e <brelse>
80103a90:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103a93:	83 ec 0c             	sub    $0xc,%esp
80103a96:	ff 75 f0             	pushl  -0x10(%ebp)
80103a99:	e8 90 c7 ff ff       	call   8010022e <brelse>
80103a9e:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103aa1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103aa5:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103aaa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aad:	0f 8f 5d ff ff ff    	jg     80103a10 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103ab3:	90                   	nop
80103ab4:	c9                   	leave  
80103ab5:	c3                   	ret    

80103ab6 <commit>:

static void
commit()
{
80103ab6:	55                   	push   %ebp
80103ab7:	89 e5                	mov    %esp,%ebp
80103ab9:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103abc:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103ac1:	85 c0                	test   %eax,%eax
80103ac3:	7e 1e                	jle    80103ae3 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103ac5:	e8 34 ff ff ff       	call   801039fe <write_log>
    write_head();    // Write header to disk -- the real commit
80103aca:	e8 3a fd ff ff       	call   80103809 <write_head>
    install_trans(); // Now install writes to home locations
80103acf:	e8 09 fc ff ff       	call   801036dd <install_trans>
    log.lh.n = 0; 
80103ad4:	c7 05 c8 52 11 80 00 	movl   $0x0,0x801152c8
80103adb:	00 00 00 
    write_head();    // Erase the transaction from the log
80103ade:	e8 26 fd ff ff       	call   80103809 <write_head>
  }
}
80103ae3:	90                   	nop
80103ae4:	c9                   	leave  
80103ae5:	c3                   	ret    

80103ae6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103ae6:	55                   	push   %ebp
80103ae7:	89 e5                	mov    %esp,%ebp
80103ae9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103aec:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103af1:	83 f8 1d             	cmp    $0x1d,%eax
80103af4:	7f 12                	jg     80103b08 <log_write+0x22>
80103af6:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103afb:	8b 15 b8 52 11 80    	mov    0x801152b8,%edx
80103b01:	83 ea 01             	sub    $0x1,%edx
80103b04:	39 d0                	cmp    %edx,%eax
80103b06:	7c 0d                	jl     80103b15 <log_write+0x2f>
    panic("too big a transaction");
80103b08:	83 ec 0c             	sub    $0xc,%esp
80103b0b:	68 b7 a8 10 80       	push   $0x8010a8b7
80103b10:	e8 51 ca ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103b15:	a1 bc 52 11 80       	mov    0x801152bc,%eax
80103b1a:	85 c0                	test   %eax,%eax
80103b1c:	7f 0d                	jg     80103b2b <log_write+0x45>
    panic("log_write outside of trans");
80103b1e:	83 ec 0c             	sub    $0xc,%esp
80103b21:	68 cd a8 10 80       	push   $0x8010a8cd
80103b26:	e8 3b ca ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103b2b:	83 ec 0c             	sub    $0xc,%esp
80103b2e:	68 80 52 11 80       	push   $0x80115280
80103b33:	e8 16 32 00 00       	call   80106d4e <acquire>
80103b38:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103b3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b42:	eb 1d                	jmp    80103b61 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b47:	83 c0 10             	add    $0x10,%eax
80103b4a:	8b 04 85 8c 52 11 80 	mov    -0x7feead74(,%eax,4),%eax
80103b51:	89 c2                	mov    %eax,%edx
80103b53:	8b 45 08             	mov    0x8(%ebp),%eax
80103b56:	8b 40 08             	mov    0x8(%eax),%eax
80103b59:	39 c2                	cmp    %eax,%edx
80103b5b:	74 10                	je     80103b6d <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103b5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b61:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103b66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b69:	7f d9                	jg     80103b44 <log_write+0x5e>
80103b6b:	eb 01                	jmp    80103b6e <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103b6d:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b71:	8b 40 08             	mov    0x8(%eax),%eax
80103b74:	89 c2                	mov    %eax,%edx
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	83 c0 10             	add    $0x10,%eax
80103b7c:	89 14 85 8c 52 11 80 	mov    %edx,-0x7feead74(,%eax,4)
  if (i == log.lh.n)
80103b83:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103b88:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b8b:	75 0d                	jne    80103b9a <log_write+0xb4>
    log.lh.n++;
80103b8d:	a1 c8 52 11 80       	mov    0x801152c8,%eax
80103b92:	83 c0 01             	add    $0x1,%eax
80103b95:	a3 c8 52 11 80       	mov    %eax,0x801152c8
  b->flags |= B_DIRTY; // prevent eviction
80103b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b9d:	8b 00                	mov    (%eax),%eax
80103b9f:	83 c8 04             	or     $0x4,%eax
80103ba2:	89 c2                	mov    %eax,%edx
80103ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba7:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103ba9:	83 ec 0c             	sub    $0xc,%esp
80103bac:	68 80 52 11 80       	push   $0x80115280
80103bb1:	e8 ff 31 00 00       	call   80106db5 <release>
80103bb6:	83 c4 10             	add    $0x10,%esp
}
80103bb9:	90                   	nop
80103bba:	c9                   	leave  
80103bbb:	c3                   	ret    

80103bbc <v2p>:
80103bbc:	55                   	push   %ebp
80103bbd:	89 e5                	mov    %esp,%ebp
80103bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc2:	05 00 00 00 80       	add    $0x80000000,%eax
80103bc7:	5d                   	pop    %ebp
80103bc8:	c3                   	ret    

80103bc9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103bc9:	55                   	push   %ebp
80103bca:	89 e5                	mov    %esp,%ebp
80103bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcf:	05 00 00 00 80       	add    $0x80000000,%eax
80103bd4:	5d                   	pop    %ebp
80103bd5:	c3                   	ret    

80103bd6 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103bd6:	55                   	push   %ebp
80103bd7:	89 e5                	mov    %esp,%ebp
80103bd9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103bdc:	8b 55 08             	mov    0x8(%ebp),%edx
80103bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103be2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103be5:	f0 87 02             	lock xchg %eax,(%edx)
80103be8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103beb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103bee:	c9                   	leave  
80103bef:	c3                   	ret    

80103bf0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103bf0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103bf4:	83 e4 f0             	and    $0xfffffff0,%esp
80103bf7:	ff 71 fc             	pushl  -0x4(%ecx)
80103bfa:	55                   	push   %ebp
80103bfb:	89 e5                	mov    %esp,%ebp
80103bfd:	51                   	push   %ecx
80103bfe:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103c01:	83 ec 08             	sub    $0x8,%esp
80103c04:	68 00 00 40 80       	push   $0x80400000
80103c09:	68 3c 89 11 80       	push   $0x8011893c
80103c0e:	e8 7d f2 ff ff       	call   80102e90 <kinit1>
80103c13:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103c16:	e8 9b 62 00 00       	call   80109eb6 <kvmalloc>
  mpinit();        // collect info about this machine
80103c1b:	e8 43 04 00 00       	call   80104063 <mpinit>
  lapicinit();
80103c20:	e8 ea f5 ff ff       	call   8010320f <lapicinit>
  seginit();       // set up segments
80103c25:	e8 35 5c 00 00       	call   8010985f <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103c2a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c30:	0f b6 00             	movzbl (%eax),%eax
80103c33:	0f b6 c0             	movzbl %al,%eax
80103c36:	83 ec 08             	sub    $0x8,%esp
80103c39:	50                   	push   %eax
80103c3a:	68 e8 a8 10 80       	push   $0x8010a8e8
80103c3f:	e8 82 c7 ff ff       	call   801003c6 <cprintf>
80103c44:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103c47:	e8 6d 06 00 00       	call   801042b9 <picinit>
  ioapicinit();    // another interrupt controller
80103c4c:	e8 34 f1 ff ff       	call   80102d85 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103c51:	e8 6d cf ff ff       	call   80100bc3 <consoleinit>
  uartinit();      // serial port
80103c56:	e8 60 4f 00 00       	call   80108bbb <uartinit>
  pinit();         // process table
80103c5b:	e8 d0 0d 00 00       	call   80104a30 <pinit>
  tvinit();        // trap vectors
80103c60:	e8 2f 4b 00 00       	call   80108794 <tvinit>
  binit();         // buffer cache
80103c65:	e8 ca c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103c6a:	e8 32 d4 ff ff       	call   801010a1 <fileinit>
  ideinit();       // disk
80103c6f:	e8 19 ed ff ff       	call   8010298d <ideinit>
  if(!ismp)
80103c74:	a1 64 53 11 80       	mov    0x80115364,%eax
80103c79:	85 c0                	test   %eax,%eax
80103c7b:	75 05                	jne    80103c82 <main+0x92>
    timerinit();   // uniprocessor timer
80103c7d:	e8 63 4a 00 00       	call   801086e5 <timerinit>
  startothers();   // start other processors
80103c82:	e8 7f 00 00 00       	call   80103d06 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103c87:	83 ec 08             	sub    $0x8,%esp
80103c8a:	68 00 00 00 8e       	push   $0x8e000000
80103c8f:	68 00 00 40 80       	push   $0x80400000
80103c94:	e8 30 f2 ff ff       	call   80102ec9 <kinit2>
80103c99:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103c9c:	e8 2a 0f 00 00       	call   80104bcb <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103ca1:	e8 1a 00 00 00       	call   80103cc0 <mpmain>

80103ca6 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103ca6:	55                   	push   %ebp
80103ca7:	89 e5                	mov    %esp,%ebp
80103ca9:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103cac:	e8 1d 62 00 00       	call   80109ece <switchkvm>
  seginit();
80103cb1:	e8 a9 5b 00 00       	call   8010985f <seginit>
  lapicinit();
80103cb6:	e8 54 f5 ff ff       	call   8010320f <lapicinit>
  mpmain();
80103cbb:	e8 00 00 00 00       	call   80103cc0 <mpmain>

80103cc0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103cc0:	55                   	push   %ebp
80103cc1:	89 e5                	mov    %esp,%ebp
80103cc3:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103cc6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103ccc:	0f b6 00             	movzbl (%eax),%eax
80103ccf:	0f b6 c0             	movzbl %al,%eax
80103cd2:	83 ec 08             	sub    $0x8,%esp
80103cd5:	50                   	push   %eax
80103cd6:	68 ff a8 10 80       	push   $0x8010a8ff
80103cdb:	e8 e6 c6 ff ff       	call   801003c6 <cprintf>
80103ce0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103ce3:	e8 0d 4c 00 00       	call   801088f5 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103ce8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103cee:	05 a8 00 00 00       	add    $0xa8,%eax
80103cf3:	83 ec 08             	sub    $0x8,%esp
80103cf6:	6a 01                	push   $0x1
80103cf8:	50                   	push   %eax
80103cf9:	e8 d8 fe ff ff       	call   80103bd6 <xchg>
80103cfe:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103d01:	e8 c7 18 00 00       	call   801055cd <scheduler>

80103d06 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103d06:	55                   	push   %ebp
80103d07:	89 e5                	mov    %esp,%ebp
80103d09:	53                   	push   %ebx
80103d0a:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103d0d:	68 00 70 00 00       	push   $0x7000
80103d12:	e8 b2 fe ff ff       	call   80103bc9 <p2v>
80103d17:	83 c4 04             	add    $0x4,%esp
80103d1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103d1d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103d22:	83 ec 04             	sub    $0x4,%esp
80103d25:	50                   	push   %eax
80103d26:	68 2c e5 10 80       	push   $0x8010e52c
80103d2b:	ff 75 f0             	pushl  -0x10(%ebp)
80103d2e:	e8 3d 33 00 00       	call   80107070 <memmove>
80103d33:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103d36:	c7 45 f4 80 53 11 80 	movl   $0x80115380,-0xc(%ebp)
80103d3d:	e9 90 00 00 00       	jmp    80103dd2 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103d42:	e8 e6 f5 ff ff       	call   8010332d <cpunum>
80103d47:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d4d:	05 80 53 11 80       	add    $0x80115380,%eax
80103d52:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d55:	74 73                	je     80103dca <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103d57:	e8 6b f2 ff ff       	call   80102fc7 <kalloc>
80103d5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d62:	83 e8 04             	sub    $0x4,%eax
80103d65:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d68:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103d6e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d73:	83 e8 08             	sub    $0x8,%eax
80103d76:	c7 00 a6 3c 10 80    	movl   $0x80103ca6,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103d82:	83 ec 0c             	sub    $0xc,%esp
80103d85:	68 00 d0 10 80       	push   $0x8010d000
80103d8a:	e8 2d fe ff ff       	call   80103bbc <v2p>
80103d8f:	83 c4 10             	add    $0x10,%esp
80103d92:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103d94:	83 ec 0c             	sub    $0xc,%esp
80103d97:	ff 75 f0             	pushl  -0x10(%ebp)
80103d9a:	e8 1d fe ff ff       	call   80103bbc <v2p>
80103d9f:	83 c4 10             	add    $0x10,%esp
80103da2:	89 c2                	mov    %eax,%edx
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	0f b6 00             	movzbl (%eax),%eax
80103daa:	0f b6 c0             	movzbl %al,%eax
80103dad:	83 ec 08             	sub    $0x8,%esp
80103db0:	52                   	push   %edx
80103db1:	50                   	push   %eax
80103db2:	e8 f0 f5 ff ff       	call   801033a7 <lapicstartap>
80103db7:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103dba:	90                   	nop
80103dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbe:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	74 f3                	je     80103dbb <startothers+0xb5>
80103dc8:	eb 01                	jmp    80103dcb <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103dca:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103dcb:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103dd2:	a1 60 59 11 80       	mov    0x80115960,%eax
80103dd7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ddd:	05 80 53 11 80       	add    $0x80115380,%eax
80103de2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103de5:	0f 87 57 ff ff ff    	ja     80103d42 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103deb:	90                   	nop
80103dec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103def:	c9                   	leave  
80103df0:	c3                   	ret    

80103df1 <p2v>:
80103df1:	55                   	push   %ebp
80103df2:	89 e5                	mov    %esp,%ebp
80103df4:	8b 45 08             	mov    0x8(%ebp),%eax
80103df7:	05 00 00 00 80       	add    $0x80000000,%eax
80103dfc:	5d                   	pop    %ebp
80103dfd:	c3                   	ret    

80103dfe <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103dfe:	55                   	push   %ebp
80103dff:	89 e5                	mov    %esp,%ebp
80103e01:	83 ec 14             	sub    $0x14,%esp
80103e04:	8b 45 08             	mov    0x8(%ebp),%eax
80103e07:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103e0b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103e0f:	89 c2                	mov    %eax,%edx
80103e11:	ec                   	in     (%dx),%al
80103e12:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103e15:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103e19:	c9                   	leave  
80103e1a:	c3                   	ret    

80103e1b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e1b:	55                   	push   %ebp
80103e1c:	89 e5                	mov    %esp,%ebp
80103e1e:	83 ec 08             	sub    $0x8,%esp
80103e21:	8b 55 08             	mov    0x8(%ebp),%edx
80103e24:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e27:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e2b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e2e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e32:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e36:	ee                   	out    %al,(%dx)
}
80103e37:	90                   	nop
80103e38:	c9                   	leave  
80103e39:	c3                   	ret    

80103e3a <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103e3a:	55                   	push   %ebp
80103e3b:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103e3d:	a1 64 e6 10 80       	mov    0x8010e664,%eax
80103e42:	89 c2                	mov    %eax,%edx
80103e44:	b8 80 53 11 80       	mov    $0x80115380,%eax
80103e49:	29 c2                	sub    %eax,%edx
80103e4b:	89 d0                	mov    %edx,%eax
80103e4d:	c1 f8 02             	sar    $0x2,%eax
80103e50:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103e56:	5d                   	pop    %ebp
80103e57:	c3                   	ret    

80103e58 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103e58:	55                   	push   %ebp
80103e59:	89 e5                	mov    %esp,%ebp
80103e5b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103e5e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103e65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103e6c:	eb 15                	jmp    80103e83 <sum+0x2b>
    sum += addr[i];
80103e6e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e71:	8b 45 08             	mov    0x8(%ebp),%eax
80103e74:	01 d0                	add    %edx,%eax
80103e76:	0f b6 00             	movzbl (%eax),%eax
80103e79:	0f b6 c0             	movzbl %al,%eax
80103e7c:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103e7f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103e86:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103e89:	7c e3                	jl     80103e6e <sum+0x16>
    sum += addr[i];
  return sum;
80103e8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103e8e:	c9                   	leave  
80103e8f:	c3                   	ret    

80103e90 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103e90:	55                   	push   %ebp
80103e91:	89 e5                	mov    %esp,%ebp
80103e93:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103e96:	ff 75 08             	pushl  0x8(%ebp)
80103e99:	e8 53 ff ff ff       	call   80103df1 <p2v>
80103e9e:	83 c4 04             	add    $0x4,%esp
80103ea1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eaa:	01 d0                	add    %edx,%eax
80103eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eb5:	eb 36                	jmp    80103eed <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103eb7:	83 ec 04             	sub    $0x4,%esp
80103eba:	6a 04                	push   $0x4
80103ebc:	68 10 a9 10 80       	push   $0x8010a910
80103ec1:	ff 75 f4             	pushl  -0xc(%ebp)
80103ec4:	e8 4f 31 00 00       	call   80107018 <memcmp>
80103ec9:	83 c4 10             	add    $0x10,%esp
80103ecc:	85 c0                	test   %eax,%eax
80103ece:	75 19                	jne    80103ee9 <mpsearch1+0x59>
80103ed0:	83 ec 08             	sub    $0x8,%esp
80103ed3:	6a 10                	push   $0x10
80103ed5:	ff 75 f4             	pushl  -0xc(%ebp)
80103ed8:	e8 7b ff ff ff       	call   80103e58 <sum>
80103edd:	83 c4 10             	add    $0x10,%esp
80103ee0:	84 c0                	test   %al,%al
80103ee2:	75 05                	jne    80103ee9 <mpsearch1+0x59>
      return (struct mp*)p;
80103ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee7:	eb 11                	jmp    80103efa <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ee9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ef3:	72 c2                	jb     80103eb7 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103efa:	c9                   	leave  
80103efb:	c3                   	ret    

80103efc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103efc:	55                   	push   %ebp
80103efd:	89 e5                	mov    %esp,%ebp
80103eff:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103f02:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0c:	83 c0 0f             	add    $0xf,%eax
80103f0f:	0f b6 00             	movzbl (%eax),%eax
80103f12:	0f b6 c0             	movzbl %al,%eax
80103f15:	c1 e0 08             	shl    $0x8,%eax
80103f18:	89 c2                	mov    %eax,%edx
80103f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1d:	83 c0 0e             	add    $0xe,%eax
80103f20:	0f b6 00             	movzbl (%eax),%eax
80103f23:	0f b6 c0             	movzbl %al,%eax
80103f26:	09 d0                	or     %edx,%eax
80103f28:	c1 e0 04             	shl    $0x4,%eax
80103f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103f2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f32:	74 21                	je     80103f55 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103f34:	83 ec 08             	sub    $0x8,%esp
80103f37:	68 00 04 00 00       	push   $0x400
80103f3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103f3f:	e8 4c ff ff ff       	call   80103e90 <mpsearch1>
80103f44:	83 c4 10             	add    $0x10,%esp
80103f47:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f4a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f4e:	74 51                	je     80103fa1 <mpsearch+0xa5>
      return mp;
80103f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f53:	eb 61                	jmp    80103fb6 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f58:	83 c0 14             	add    $0x14,%eax
80103f5b:	0f b6 00             	movzbl (%eax),%eax
80103f5e:	0f b6 c0             	movzbl %al,%eax
80103f61:	c1 e0 08             	shl    $0x8,%eax
80103f64:	89 c2                	mov    %eax,%edx
80103f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f69:	83 c0 13             	add    $0x13,%eax
80103f6c:	0f b6 00             	movzbl (%eax),%eax
80103f6f:	0f b6 c0             	movzbl %al,%eax
80103f72:	09 d0                	or     %edx,%eax
80103f74:	c1 e0 0a             	shl    $0xa,%eax
80103f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f7d:	2d 00 04 00 00       	sub    $0x400,%eax
80103f82:	83 ec 08             	sub    $0x8,%esp
80103f85:	68 00 04 00 00       	push   $0x400
80103f8a:	50                   	push   %eax
80103f8b:	e8 00 ff ff ff       	call   80103e90 <mpsearch1>
80103f90:	83 c4 10             	add    $0x10,%esp
80103f93:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f96:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f9a:	74 05                	je     80103fa1 <mpsearch+0xa5>
      return mp;
80103f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f9f:	eb 15                	jmp    80103fb6 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103fa1:	83 ec 08             	sub    $0x8,%esp
80103fa4:	68 00 00 01 00       	push   $0x10000
80103fa9:	68 00 00 0f 00       	push   $0xf0000
80103fae:	e8 dd fe ff ff       	call   80103e90 <mpsearch1>
80103fb3:	83 c4 10             	add    $0x10,%esp
}
80103fb6:	c9                   	leave  
80103fb7:	c3                   	ret    

80103fb8 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103fb8:	55                   	push   %ebp
80103fb9:	89 e5                	mov    %esp,%ebp
80103fbb:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103fbe:	e8 39 ff ff ff       	call   80103efc <mpsearch>
80103fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fca:	74 0a                	je     80103fd6 <mpconfig+0x1e>
80103fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcf:	8b 40 04             	mov    0x4(%eax),%eax
80103fd2:	85 c0                	test   %eax,%eax
80103fd4:	75 0a                	jne    80103fe0 <mpconfig+0x28>
    return 0;
80103fd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103fdb:	e9 81 00 00 00       	jmp    80104061 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe3:	8b 40 04             	mov    0x4(%eax),%eax
80103fe6:	83 ec 0c             	sub    $0xc,%esp
80103fe9:	50                   	push   %eax
80103fea:	e8 02 fe ff ff       	call   80103df1 <p2v>
80103fef:	83 c4 10             	add    $0x10,%esp
80103ff2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103ff5:	83 ec 04             	sub    $0x4,%esp
80103ff8:	6a 04                	push   $0x4
80103ffa:	68 15 a9 10 80       	push   $0x8010a915
80103fff:	ff 75 f0             	pushl  -0x10(%ebp)
80104002:	e8 11 30 00 00       	call   80107018 <memcmp>
80104007:	83 c4 10             	add    $0x10,%esp
8010400a:	85 c0                	test   %eax,%eax
8010400c:	74 07                	je     80104015 <mpconfig+0x5d>
    return 0;
8010400e:	b8 00 00 00 00       	mov    $0x0,%eax
80104013:	eb 4c                	jmp    80104061 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80104015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104018:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010401c:	3c 01                	cmp    $0x1,%al
8010401e:	74 12                	je     80104032 <mpconfig+0x7a>
80104020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104023:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104027:	3c 04                	cmp    $0x4,%al
80104029:	74 07                	je     80104032 <mpconfig+0x7a>
    return 0;
8010402b:	b8 00 00 00 00       	mov    $0x0,%eax
80104030:	eb 2f                	jmp    80104061 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104035:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104039:	0f b7 c0             	movzwl %ax,%eax
8010403c:	83 ec 08             	sub    $0x8,%esp
8010403f:	50                   	push   %eax
80104040:	ff 75 f0             	pushl  -0x10(%ebp)
80104043:	e8 10 fe ff ff       	call   80103e58 <sum>
80104048:	83 c4 10             	add    $0x10,%esp
8010404b:	84 c0                	test   %al,%al
8010404d:	74 07                	je     80104056 <mpconfig+0x9e>
    return 0;
8010404f:	b8 00 00 00 00       	mov    $0x0,%eax
80104054:	eb 0b                	jmp    80104061 <mpconfig+0xa9>
  *pmp = mp;
80104056:	8b 45 08             	mov    0x8(%ebp),%eax
80104059:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405c:	89 10                	mov    %edx,(%eax)
  return conf;
8010405e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104061:	c9                   	leave  
80104062:	c3                   	ret    

80104063 <mpinit>:

void
mpinit(void)
{
80104063:	55                   	push   %ebp
80104064:	89 e5                	mov    %esp,%ebp
80104066:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104069:	c7 05 64 e6 10 80 80 	movl   $0x80115380,0x8010e664
80104070:	53 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104073:	83 ec 0c             	sub    $0xc,%esp
80104076:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104079:	50                   	push   %eax
8010407a:	e8 39 ff ff ff       	call   80103fb8 <mpconfig>
8010407f:	83 c4 10             	add    $0x10,%esp
80104082:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104085:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104089:	0f 84 96 01 00 00    	je     80104225 <mpinit+0x1c2>
    return;
  ismp = 1;
8010408f:	c7 05 64 53 11 80 01 	movl   $0x1,0x80115364
80104096:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010409c:	8b 40 24             	mov    0x24(%eax),%eax
8010409f:	a3 7c 52 11 80       	mov    %eax,0x8011527c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801040a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040a7:	83 c0 2c             	add    $0x2c,%eax
801040aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040b0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801040b4:	0f b7 d0             	movzwl %ax,%edx
801040b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040ba:	01 d0                	add    %edx,%eax
801040bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801040bf:	e9 f2 00 00 00       	jmp    801041b6 <mpinit+0x153>
    switch(*p){
801040c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c7:	0f b6 00             	movzbl (%eax),%eax
801040ca:	0f b6 c0             	movzbl %al,%eax
801040cd:	83 f8 04             	cmp    $0x4,%eax
801040d0:	0f 87 bc 00 00 00    	ja     80104192 <mpinit+0x12f>
801040d6:	8b 04 85 58 a9 10 80 	mov    -0x7fef56a8(,%eax,4),%eax
801040dd:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801040df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801040e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040e8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040ec:	0f b6 d0             	movzbl %al,%edx
801040ef:	a1 60 59 11 80       	mov    0x80115960,%eax
801040f4:	39 c2                	cmp    %eax,%edx
801040f6:	74 2b                	je     80104123 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801040f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040fb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040ff:	0f b6 d0             	movzbl %al,%edx
80104102:	a1 60 59 11 80       	mov    0x80115960,%eax
80104107:	83 ec 04             	sub    $0x4,%esp
8010410a:	52                   	push   %edx
8010410b:	50                   	push   %eax
8010410c:	68 1a a9 10 80       	push   $0x8010a91a
80104111:	e8 b0 c2 ff ff       	call   801003c6 <cprintf>
80104116:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80104119:	c7 05 64 53 11 80 00 	movl   $0x0,0x80115364
80104120:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104123:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104126:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010412a:	0f b6 c0             	movzbl %al,%eax
8010412d:	83 e0 02             	and    $0x2,%eax
80104130:	85 c0                	test   %eax,%eax
80104132:	74 15                	je     80104149 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104134:	a1 60 59 11 80       	mov    0x80115960,%eax
80104139:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010413f:	05 80 53 11 80       	add    $0x80115380,%eax
80104144:	a3 64 e6 10 80       	mov    %eax,0x8010e664
      cpus[ncpu].id = ncpu;
80104149:	a1 60 59 11 80       	mov    0x80115960,%eax
8010414e:	8b 15 60 59 11 80    	mov    0x80115960,%edx
80104154:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010415a:	05 80 53 11 80       	add    $0x80115380,%eax
8010415f:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104161:	a1 60 59 11 80       	mov    0x80115960,%eax
80104166:	83 c0 01             	add    $0x1,%eax
80104169:	a3 60 59 11 80       	mov    %eax,0x80115960
      p += sizeof(struct mpproc);
8010416e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104172:	eb 42                	jmp    801041b6 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010417a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010417d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104181:	a2 60 53 11 80       	mov    %al,0x80115360
      p += sizeof(struct mpioapic);
80104186:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010418a:	eb 2a                	jmp    801041b6 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010418c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104190:	eb 24                	jmp    801041b6 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104195:	0f b6 00             	movzbl (%eax),%eax
80104198:	0f b6 c0             	movzbl %al,%eax
8010419b:	83 ec 08             	sub    $0x8,%esp
8010419e:	50                   	push   %eax
8010419f:	68 38 a9 10 80       	push   $0x8010a938
801041a4:	e8 1d c2 ff ff       	call   801003c6 <cprintf>
801041a9:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
801041ac:	c7 05 64 53 11 80 00 	movl   $0x0,0x80115364
801041b3:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801041b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801041bc:	0f 82 02 ff ff ff    	jb     801040c4 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801041c2:	a1 64 53 11 80       	mov    0x80115364,%eax
801041c7:	85 c0                	test   %eax,%eax
801041c9:	75 1d                	jne    801041e8 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801041cb:	c7 05 60 59 11 80 01 	movl   $0x1,0x80115960
801041d2:	00 00 00 
    lapic = 0;
801041d5:	c7 05 7c 52 11 80 00 	movl   $0x0,0x8011527c
801041dc:	00 00 00 
    ioapicid = 0;
801041df:	c6 05 60 53 11 80 00 	movb   $0x0,0x80115360
    return;
801041e6:	eb 3e                	jmp    80104226 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801041e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801041eb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801041ef:	84 c0                	test   %al,%al
801041f1:	74 33                	je     80104226 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801041f3:	83 ec 08             	sub    $0x8,%esp
801041f6:	6a 70                	push   $0x70
801041f8:	6a 22                	push   $0x22
801041fa:	e8 1c fc ff ff       	call   80103e1b <outb>
801041ff:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104202:	83 ec 0c             	sub    $0xc,%esp
80104205:	6a 23                	push   $0x23
80104207:	e8 f2 fb ff ff       	call   80103dfe <inb>
8010420c:	83 c4 10             	add    $0x10,%esp
8010420f:	83 c8 01             	or     $0x1,%eax
80104212:	0f b6 c0             	movzbl %al,%eax
80104215:	83 ec 08             	sub    $0x8,%esp
80104218:	50                   	push   %eax
80104219:	6a 23                	push   $0x23
8010421b:	e8 fb fb ff ff       	call   80103e1b <outb>
80104220:	83 c4 10             	add    $0x10,%esp
80104223:	eb 01                	jmp    80104226 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104225:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104226:	c9                   	leave  
80104227:	c3                   	ret    

80104228 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104228:	55                   	push   %ebp
80104229:	89 e5                	mov    %esp,%ebp
8010422b:	83 ec 08             	sub    $0x8,%esp
8010422e:	8b 55 08             	mov    0x8(%ebp),%edx
80104231:	8b 45 0c             	mov    0xc(%ebp),%eax
80104234:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104238:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010423b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010423f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104243:	ee                   	out    %al,(%dx)
}
80104244:	90                   	nop
80104245:	c9                   	leave  
80104246:	c3                   	ret    

80104247 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104247:	55                   	push   %ebp
80104248:	89 e5                	mov    %esp,%ebp
8010424a:	83 ec 04             	sub    $0x4,%esp
8010424d:	8b 45 08             	mov    0x8(%ebp),%eax
80104250:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104254:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104258:	66 a3 00 e0 10 80    	mov    %ax,0x8010e000
  outb(IO_PIC1+1, mask);
8010425e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104262:	0f b6 c0             	movzbl %al,%eax
80104265:	50                   	push   %eax
80104266:	6a 21                	push   $0x21
80104268:	e8 bb ff ff ff       	call   80104228 <outb>
8010426d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104270:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104274:	66 c1 e8 08          	shr    $0x8,%ax
80104278:	0f b6 c0             	movzbl %al,%eax
8010427b:	50                   	push   %eax
8010427c:	68 a1 00 00 00       	push   $0xa1
80104281:	e8 a2 ff ff ff       	call   80104228 <outb>
80104286:	83 c4 08             	add    $0x8,%esp
}
80104289:	90                   	nop
8010428a:	c9                   	leave  
8010428b:	c3                   	ret    

8010428c <picenable>:

void
picenable(int irq)
{
8010428c:	55                   	push   %ebp
8010428d:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010428f:	8b 45 08             	mov    0x8(%ebp),%eax
80104292:	ba 01 00 00 00       	mov    $0x1,%edx
80104297:	89 c1                	mov    %eax,%ecx
80104299:	d3 e2                	shl    %cl,%edx
8010429b:	89 d0                	mov    %edx,%eax
8010429d:	f7 d0                	not    %eax
8010429f:	89 c2                	mov    %eax,%edx
801042a1:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
801042a8:	21 d0                	and    %edx,%eax
801042aa:	0f b7 c0             	movzwl %ax,%eax
801042ad:	50                   	push   %eax
801042ae:	e8 94 ff ff ff       	call   80104247 <picsetmask>
801042b3:	83 c4 04             	add    $0x4,%esp
}
801042b6:	90                   	nop
801042b7:	c9                   	leave  
801042b8:	c3                   	ret    

801042b9 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801042b9:	55                   	push   %ebp
801042ba:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801042bc:	68 ff 00 00 00       	push   $0xff
801042c1:	6a 21                	push   $0x21
801042c3:	e8 60 ff ff ff       	call   80104228 <outb>
801042c8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801042cb:	68 ff 00 00 00       	push   $0xff
801042d0:	68 a1 00 00 00       	push   $0xa1
801042d5:	e8 4e ff ff ff       	call   80104228 <outb>
801042da:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801042dd:	6a 11                	push   $0x11
801042df:	6a 20                	push   $0x20
801042e1:	e8 42 ff ff ff       	call   80104228 <outb>
801042e6:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801042e9:	6a 20                	push   $0x20
801042eb:	6a 21                	push   $0x21
801042ed:	e8 36 ff ff ff       	call   80104228 <outb>
801042f2:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801042f5:	6a 04                	push   $0x4
801042f7:	6a 21                	push   $0x21
801042f9:	e8 2a ff ff ff       	call   80104228 <outb>
801042fe:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104301:	6a 03                	push   $0x3
80104303:	6a 21                	push   $0x21
80104305:	e8 1e ff ff ff       	call   80104228 <outb>
8010430a:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
8010430d:	6a 11                	push   $0x11
8010430f:	68 a0 00 00 00       	push   $0xa0
80104314:	e8 0f ff ff ff       	call   80104228 <outb>
80104319:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010431c:	6a 28                	push   $0x28
8010431e:	68 a1 00 00 00       	push   $0xa1
80104323:	e8 00 ff ff ff       	call   80104228 <outb>
80104328:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010432b:	6a 02                	push   $0x2
8010432d:	68 a1 00 00 00       	push   $0xa1
80104332:	e8 f1 fe ff ff       	call   80104228 <outb>
80104337:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010433a:	6a 03                	push   $0x3
8010433c:	68 a1 00 00 00       	push   $0xa1
80104341:	e8 e2 fe ff ff       	call   80104228 <outb>
80104346:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104349:	6a 68                	push   $0x68
8010434b:	6a 20                	push   $0x20
8010434d:	e8 d6 fe ff ff       	call   80104228 <outb>
80104352:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104355:	6a 0a                	push   $0xa
80104357:	6a 20                	push   $0x20
80104359:	e8 ca fe ff ff       	call   80104228 <outb>
8010435e:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104361:	6a 68                	push   $0x68
80104363:	68 a0 00 00 00       	push   $0xa0
80104368:	e8 bb fe ff ff       	call   80104228 <outb>
8010436d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104370:	6a 0a                	push   $0xa
80104372:	68 a0 00 00 00       	push   $0xa0
80104377:	e8 ac fe ff ff       	call   80104228 <outb>
8010437c:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010437f:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80104386:	66 83 f8 ff          	cmp    $0xffff,%ax
8010438a:	74 13                	je     8010439f <picinit+0xe6>
    picsetmask(irqmask);
8010438c:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80104393:	0f b7 c0             	movzwl %ax,%eax
80104396:	50                   	push   %eax
80104397:	e8 ab fe ff ff       	call   80104247 <picsetmask>
8010439c:	83 c4 04             	add    $0x4,%esp
}
8010439f:	90                   	nop
801043a0:	c9                   	leave  
801043a1:	c3                   	ret    

801043a2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801043a2:	55                   	push   %ebp
801043a3:	89 e5                	mov    %esp,%ebp
801043a5:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801043a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801043af:	8b 45 0c             	mov    0xc(%ebp),%eax
801043b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801043b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801043bb:	8b 10                	mov    (%eax),%edx
801043bd:	8b 45 08             	mov    0x8(%ebp),%eax
801043c0:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801043c2:	e8 f8 cc ff ff       	call   801010bf <filealloc>
801043c7:	89 c2                	mov    %eax,%edx
801043c9:	8b 45 08             	mov    0x8(%ebp),%eax
801043cc:	89 10                	mov    %edx,(%eax)
801043ce:	8b 45 08             	mov    0x8(%ebp),%eax
801043d1:	8b 00                	mov    (%eax),%eax
801043d3:	85 c0                	test   %eax,%eax
801043d5:	0f 84 cb 00 00 00    	je     801044a6 <pipealloc+0x104>
801043db:	e8 df cc ff ff       	call   801010bf <filealloc>
801043e0:	89 c2                	mov    %eax,%edx
801043e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e5:	89 10                	mov    %edx,(%eax)
801043e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801043ea:	8b 00                	mov    (%eax),%eax
801043ec:	85 c0                	test   %eax,%eax
801043ee:	0f 84 b2 00 00 00    	je     801044a6 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801043f4:	e8 ce eb ff ff       	call   80102fc7 <kalloc>
801043f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104400:	0f 84 9f 00 00 00    	je     801044a5 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104409:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104410:	00 00 00 
  p->writeopen = 1;
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010441d:	00 00 00 
  p->nwrite = 0;
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104423:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010442a:	00 00 00 
  p->nread = 0;
8010442d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104430:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104437:	00 00 00 
  initlock(&p->lock, "pipe");
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	83 ec 08             	sub    $0x8,%esp
80104440:	68 6c a9 10 80       	push   $0x8010a96c
80104445:	50                   	push   %eax
80104446:	e8 e1 28 00 00       	call   80106d2c <initlock>
8010444b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010444e:	8b 45 08             	mov    0x8(%ebp),%eax
80104451:	8b 00                	mov    (%eax),%eax
80104453:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104459:	8b 45 08             	mov    0x8(%ebp),%eax
8010445c:	8b 00                	mov    (%eax),%eax
8010445e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104462:	8b 45 08             	mov    0x8(%ebp),%eax
80104465:	8b 00                	mov    (%eax),%eax
80104467:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010446b:	8b 45 08             	mov    0x8(%ebp),%eax
8010446e:	8b 00                	mov    (%eax),%eax
80104470:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104473:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104476:	8b 45 0c             	mov    0xc(%ebp),%eax
80104479:	8b 00                	mov    (%eax),%eax
8010447b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104481:	8b 45 0c             	mov    0xc(%ebp),%eax
80104484:	8b 00                	mov    (%eax),%eax
80104486:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010448a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010448d:	8b 00                	mov    (%eax),%eax
8010448f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104493:	8b 45 0c             	mov    0xc(%ebp),%eax
80104496:	8b 00                	mov    (%eax),%eax
80104498:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449b:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010449e:	b8 00 00 00 00       	mov    $0x0,%eax
801044a3:	eb 4e                	jmp    801044f3 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801044a5:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801044a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044aa:	74 0e                	je     801044ba <pipealloc+0x118>
    kfree((char*)p);
801044ac:	83 ec 0c             	sub    $0xc,%esp
801044af:	ff 75 f4             	pushl  -0xc(%ebp)
801044b2:	e8 73 ea ff ff       	call   80102f2a <kfree>
801044b7:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801044ba:	8b 45 08             	mov    0x8(%ebp),%eax
801044bd:	8b 00                	mov    (%eax),%eax
801044bf:	85 c0                	test   %eax,%eax
801044c1:	74 11                	je     801044d4 <pipealloc+0x132>
    fileclose(*f0);
801044c3:	8b 45 08             	mov    0x8(%ebp),%eax
801044c6:	8b 00                	mov    (%eax),%eax
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	50                   	push   %eax
801044cc:	e8 ac cc ff ff       	call   8010117d <fileclose>
801044d1:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801044d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801044d7:	8b 00                	mov    (%eax),%eax
801044d9:	85 c0                	test   %eax,%eax
801044db:	74 11                	je     801044ee <pipealloc+0x14c>
    fileclose(*f1);
801044dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801044e0:	8b 00                	mov    (%eax),%eax
801044e2:	83 ec 0c             	sub    $0xc,%esp
801044e5:	50                   	push   %eax
801044e6:	e8 92 cc ff ff       	call   8010117d <fileclose>
801044eb:	83 c4 10             	add    $0x10,%esp
  return -1;
801044ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044f3:	c9                   	leave  
801044f4:	c3                   	ret    

801044f5 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801044f5:	55                   	push   %ebp
801044f6:	89 e5                	mov    %esp,%ebp
801044f8:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801044fb:	8b 45 08             	mov    0x8(%ebp),%eax
801044fe:	83 ec 0c             	sub    $0xc,%esp
80104501:	50                   	push   %eax
80104502:	e8 47 28 00 00       	call   80106d4e <acquire>
80104507:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010450a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010450e:	74 23                	je     80104533 <pipeclose+0x3e>
    p->writeopen = 0;
80104510:	8b 45 08             	mov    0x8(%ebp),%eax
80104513:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010451a:	00 00 00 
    wakeup(&p->nread);
8010451d:	8b 45 08             	mov    0x8(%ebp),%eax
80104520:	05 34 02 00 00       	add    $0x234,%eax
80104525:	83 ec 0c             	sub    $0xc,%esp
80104528:	50                   	push   %eax
80104529:	e8 1b 17 00 00       	call   80105c49 <wakeup>
8010452e:	83 c4 10             	add    $0x10,%esp
80104531:	eb 21                	jmp    80104554 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104533:	8b 45 08             	mov    0x8(%ebp),%eax
80104536:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010453d:	00 00 00 
    wakeup(&p->nwrite);
80104540:	8b 45 08             	mov    0x8(%ebp),%eax
80104543:	05 38 02 00 00       	add    $0x238,%eax
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	50                   	push   %eax
8010454c:	e8 f8 16 00 00       	call   80105c49 <wakeup>
80104551:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104554:	8b 45 08             	mov    0x8(%ebp),%eax
80104557:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010455d:	85 c0                	test   %eax,%eax
8010455f:	75 2c                	jne    8010458d <pipeclose+0x98>
80104561:	8b 45 08             	mov    0x8(%ebp),%eax
80104564:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010456a:	85 c0                	test   %eax,%eax
8010456c:	75 1f                	jne    8010458d <pipeclose+0x98>
    release(&p->lock);
8010456e:	8b 45 08             	mov    0x8(%ebp),%eax
80104571:	83 ec 0c             	sub    $0xc,%esp
80104574:	50                   	push   %eax
80104575:	e8 3b 28 00 00       	call   80106db5 <release>
8010457a:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010457d:	83 ec 0c             	sub    $0xc,%esp
80104580:	ff 75 08             	pushl  0x8(%ebp)
80104583:	e8 a2 e9 ff ff       	call   80102f2a <kfree>
80104588:	83 c4 10             	add    $0x10,%esp
8010458b:	eb 0f                	jmp    8010459c <pipeclose+0xa7>
  } else
    release(&p->lock);
8010458d:	8b 45 08             	mov    0x8(%ebp),%eax
80104590:	83 ec 0c             	sub    $0xc,%esp
80104593:	50                   	push   %eax
80104594:	e8 1c 28 00 00       	call   80106db5 <release>
80104599:	83 c4 10             	add    $0x10,%esp
}
8010459c:	90                   	nop
8010459d:	c9                   	leave  
8010459e:	c3                   	ret    

8010459f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010459f:	55                   	push   %ebp
801045a0:	89 e5                	mov    %esp,%ebp
801045a2:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801045a5:	8b 45 08             	mov    0x8(%ebp),%eax
801045a8:	83 ec 0c             	sub    $0xc,%esp
801045ab:	50                   	push   %eax
801045ac:	e8 9d 27 00 00       	call   80106d4e <acquire>
801045b1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801045b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801045bb:	e9 ad 00 00 00       	jmp    8010466d <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801045c0:	8b 45 08             	mov    0x8(%ebp),%eax
801045c3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801045c9:	85 c0                	test   %eax,%eax
801045cb:	74 0d                	je     801045da <pipewrite+0x3b>
801045cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d3:	8b 40 24             	mov    0x24(%eax),%eax
801045d6:	85 c0                	test   %eax,%eax
801045d8:	74 19                	je     801045f3 <pipewrite+0x54>
        release(&p->lock);
801045da:	8b 45 08             	mov    0x8(%ebp),%eax
801045dd:	83 ec 0c             	sub    $0xc,%esp
801045e0:	50                   	push   %eax
801045e1:	e8 cf 27 00 00       	call   80106db5 <release>
801045e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801045e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ee:	e9 a8 00 00 00       	jmp    8010469b <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801045f3:	8b 45 08             	mov    0x8(%ebp),%eax
801045f6:	05 34 02 00 00       	add    $0x234,%eax
801045fb:	83 ec 0c             	sub    $0xc,%esp
801045fe:	50                   	push   %eax
801045ff:	e8 45 16 00 00       	call   80105c49 <wakeup>
80104604:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104607:	8b 45 08             	mov    0x8(%ebp),%eax
8010460a:	8b 55 08             	mov    0x8(%ebp),%edx
8010460d:	81 c2 38 02 00 00    	add    $0x238,%edx
80104613:	83 ec 08             	sub    $0x8,%esp
80104616:	50                   	push   %eax
80104617:	52                   	push   %edx
80104618:	e8 1c 14 00 00       	call   80105a39 <sleep>
8010461d:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104620:	8b 45 08             	mov    0x8(%ebp),%eax
80104623:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104629:	8b 45 08             	mov    0x8(%ebp),%eax
8010462c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104632:	05 00 02 00 00       	add    $0x200,%eax
80104637:	39 c2                	cmp    %eax,%edx
80104639:	74 85                	je     801045c0 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010463b:	8b 45 08             	mov    0x8(%ebp),%eax
8010463e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104644:	8d 48 01             	lea    0x1(%eax),%ecx
80104647:	8b 55 08             	mov    0x8(%ebp),%edx
8010464a:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104650:	25 ff 01 00 00       	and    $0x1ff,%eax
80104655:	89 c1                	mov    %eax,%ecx
80104657:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010465a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010465d:	01 d0                	add    %edx,%eax
8010465f:	0f b6 10             	movzbl (%eax),%edx
80104662:	8b 45 08             	mov    0x8(%ebp),%eax
80104665:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104669:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010466d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104670:	3b 45 10             	cmp    0x10(%ebp),%eax
80104673:	7c ab                	jl     80104620 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104675:	8b 45 08             	mov    0x8(%ebp),%eax
80104678:	05 34 02 00 00       	add    $0x234,%eax
8010467d:	83 ec 0c             	sub    $0xc,%esp
80104680:	50                   	push   %eax
80104681:	e8 c3 15 00 00       	call   80105c49 <wakeup>
80104686:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104689:	8b 45 08             	mov    0x8(%ebp),%eax
8010468c:	83 ec 0c             	sub    $0xc,%esp
8010468f:	50                   	push   %eax
80104690:	e8 20 27 00 00       	call   80106db5 <release>
80104695:	83 c4 10             	add    $0x10,%esp
  return n;
80104698:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010469b:	c9                   	leave  
8010469c:	c3                   	ret    

8010469d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010469d:	55                   	push   %ebp
8010469e:	89 e5                	mov    %esp,%ebp
801046a0:	53                   	push   %ebx
801046a1:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801046a4:	8b 45 08             	mov    0x8(%ebp),%eax
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	50                   	push   %eax
801046ab:	e8 9e 26 00 00       	call   80106d4e <acquire>
801046b0:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801046b3:	eb 3f                	jmp    801046f4 <piperead+0x57>
    if(proc->killed){
801046b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bb:	8b 40 24             	mov    0x24(%eax),%eax
801046be:	85 c0                	test   %eax,%eax
801046c0:	74 19                	je     801046db <piperead+0x3e>
      release(&p->lock);
801046c2:	8b 45 08             	mov    0x8(%ebp),%eax
801046c5:	83 ec 0c             	sub    $0xc,%esp
801046c8:	50                   	push   %eax
801046c9:	e8 e7 26 00 00       	call   80106db5 <release>
801046ce:	83 c4 10             	add    $0x10,%esp
      return -1;
801046d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d6:	e9 bf 00 00 00       	jmp    8010479a <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801046db:	8b 45 08             	mov    0x8(%ebp),%eax
801046de:	8b 55 08             	mov    0x8(%ebp),%edx
801046e1:	81 c2 34 02 00 00    	add    $0x234,%edx
801046e7:	83 ec 08             	sub    $0x8,%esp
801046ea:	50                   	push   %eax
801046eb:	52                   	push   %edx
801046ec:	e8 48 13 00 00       	call   80105a39 <sleep>
801046f1:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801046f4:	8b 45 08             	mov    0x8(%ebp),%eax
801046f7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801046fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104700:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104706:	39 c2                	cmp    %eax,%edx
80104708:	75 0d                	jne    80104717 <piperead+0x7a>
8010470a:	8b 45 08             	mov    0x8(%ebp),%eax
8010470d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104713:	85 c0                	test   %eax,%eax
80104715:	75 9e                	jne    801046b5 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104717:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010471e:	eb 49                	jmp    80104769 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104720:	8b 45 08             	mov    0x8(%ebp),%eax
80104723:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104729:	8b 45 08             	mov    0x8(%ebp),%eax
8010472c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104732:	39 c2                	cmp    %eax,%edx
80104734:	74 3d                	je     80104773 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104736:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104739:	8b 45 0c             	mov    0xc(%ebp),%eax
8010473c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010473f:	8b 45 08             	mov    0x8(%ebp),%eax
80104742:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104748:	8d 48 01             	lea    0x1(%eax),%ecx
8010474b:	8b 55 08             	mov    0x8(%ebp),%edx
8010474e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104754:	25 ff 01 00 00       	and    $0x1ff,%eax
80104759:	89 c2                	mov    %eax,%edx
8010475b:	8b 45 08             	mov    0x8(%ebp),%eax
8010475e:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104763:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104765:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010476f:	7c af                	jl     80104720 <piperead+0x83>
80104771:	eb 01                	jmp    80104774 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104773:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104774:	8b 45 08             	mov    0x8(%ebp),%eax
80104777:	05 38 02 00 00       	add    $0x238,%eax
8010477c:	83 ec 0c             	sub    $0xc,%esp
8010477f:	50                   	push   %eax
80104780:	e8 c4 14 00 00       	call   80105c49 <wakeup>
80104785:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104788:	8b 45 08             	mov    0x8(%ebp),%eax
8010478b:	83 ec 0c             	sub    $0xc,%esp
8010478e:	50                   	push   %eax
8010478f:	e8 21 26 00 00       	call   80106db5 <release>
80104794:	83 c4 10             	add    $0x10,%esp
  return i;
80104797:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010479a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010479d:	c9                   	leave  
8010479e:	c3                   	ret    

8010479f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010479f:	55                   	push   %ebp
801047a0:	89 e5                	mov    %esp,%ebp
801047a2:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047a5:	9c                   	pushf  
801047a6:	58                   	pop    %eax
801047a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047ad:	c9                   	leave  
801047ae:	c3                   	ret    

801047af <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801047af:	55                   	push   %ebp
801047b0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801047b2:	fb                   	sti    
}
801047b3:	90                   	nop
801047b4:	5d                   	pop    %ebp
801047b5:	c3                   	ret    

801047b6 <assertStateFree>:

#ifdef CS333_P3P4
//Helper functions

static void
assertStateFree(struct proc* p){
801047b6:	55                   	push   %ebp
801047b7:	89 e5                	mov    %esp,%ebp
801047b9:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != UNUSED)
801047bc:	8b 45 08             	mov    0x8(%ebp),%eax
801047bf:	8b 40 0c             	mov    0xc(%eax),%eax
801047c2:	85 c0                	test   %eax,%eax
801047c4:	74 0d                	je     801047d3 <assertStateFree+0x1d>
	panic("Process not in an UNUSED state");
801047c6:	83 ec 0c             	sub    $0xc,%esp
801047c9:	68 74 a9 10 80       	push   $0x8010a974
801047ce:	e8 93 bd ff ff       	call   80100566 <panic>
}
801047d3:	90                   	nop
801047d4:	c9                   	leave  
801047d5:	c3                   	ret    

801047d6 <assertStateZombie>:
static void
assertStateZombie(struct proc* p){
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
801047d9:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != ZOMBIE)
801047dc:	8b 45 08             	mov    0x8(%ebp),%eax
801047df:	8b 40 0c             	mov    0xc(%eax),%eax
801047e2:	83 f8 05             	cmp    $0x5,%eax
801047e5:	74 0d                	je     801047f4 <assertStateZombie+0x1e>
	panic("Process not in a ZOMBIE state");
801047e7:	83 ec 0c             	sub    $0xc,%esp
801047ea:	68 93 a9 10 80       	push   $0x8010a993
801047ef:	e8 72 bd ff ff       	call   80100566 <panic>
}
801047f4:	90                   	nop
801047f5:	c9                   	leave  
801047f6:	c3                   	ret    

801047f7 <assertStateEmbryo>:
static void
assertStateEmbryo(struct proc* p){
801047f7:	55                   	push   %ebp
801047f8:	89 e5                	mov    %esp,%ebp
801047fa:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != EMBRYO)
801047fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104800:	8b 40 0c             	mov    0xc(%eax),%eax
80104803:	83 f8 01             	cmp    $0x1,%eax
80104806:	74 0d                	je     80104815 <assertStateEmbryo+0x1e>
	panic("Process not in a EMBRYO state");
80104808:	83 ec 0c             	sub    $0xc,%esp
8010480b:	68 b1 a9 10 80       	push   $0x8010a9b1
80104810:	e8 51 bd ff ff       	call   80100566 <panic>
}
80104815:	90                   	nop
80104816:	c9                   	leave  
80104817:	c3                   	ret    

80104818 <assertStateRunning>:
static void
assertStateRunning(struct proc* p){
80104818:	55                   	push   %ebp
80104819:	89 e5                	mov    %esp,%ebp
8010481b:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != RUNNING)
8010481e:	8b 45 08             	mov    0x8(%ebp),%eax
80104821:	8b 40 0c             	mov    0xc(%eax),%eax
80104824:	83 f8 04             	cmp    $0x4,%eax
80104827:	74 0d                	je     80104836 <assertStateRunning+0x1e>
	panic("Process not in a RUNNING state");
80104829:	83 ec 0c             	sub    $0xc,%esp
8010482c:	68 d0 a9 10 80       	push   $0x8010a9d0
80104831:	e8 30 bd ff ff       	call   80100566 <panic>
}
80104836:	90                   	nop
80104837:	c9                   	leave  
80104838:	c3                   	ret    

80104839 <assertStateSleep>:
static void
assertStateSleep(struct proc* p){
80104839:	55                   	push   %ebp
8010483a:	89 e5                	mov    %esp,%ebp
8010483c:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != SLEEPING)
8010483f:	8b 45 08             	mov    0x8(%ebp),%eax
80104842:	8b 40 0c             	mov    0xc(%eax),%eax
80104845:	83 f8 02             	cmp    $0x2,%eax
80104848:	74 0d                	je     80104857 <assertStateSleep+0x1e>
	panic("Process not in a SLEEPING state");
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	68 f0 a9 10 80       	push   $0x8010a9f0
80104852:	e8 0f bd ff ff       	call   80100566 <panic>
}
80104857:	90                   	nop
80104858:	c9                   	leave  
80104859:	c3                   	ret    

8010485a <assertStateReady>:
static void
assertStateReady(struct proc* p){
8010485a:	55                   	push   %ebp
8010485b:	89 e5                	mov    %esp,%ebp
8010485d:	83 ec 08             	sub    $0x8,%esp
    if(p -> state != RUNNABLE)
80104860:	8b 45 08             	mov    0x8(%ebp),%eax
80104863:	8b 40 0c             	mov    0xc(%eax),%eax
80104866:	83 f8 03             	cmp    $0x3,%eax
80104869:	74 0d                	je     80104878 <assertStateReady+0x1e>
	panic("Process not in a RUNNABLE state");
8010486b:	83 ec 0c             	sub    $0xc,%esp
8010486e:	68 10 aa 10 80       	push   $0x8010aa10
80104873:	e8 ee bc ff ff       	call   80100566 <panic>
}
80104878:	90                   	nop
80104879:	c9                   	leave  
8010487a:	c3                   	ret    

8010487b <addToStateListEnd>:


static int
addToStateListEnd(struct proc** sList, struct proc* p){
8010487b:	55                   	push   %ebp
8010487c:	89 e5                	mov    %esp,%ebp
8010487e:	83 ec 18             	sub    $0x18,%esp
    if(!holding(&ptable.lock)){
80104881:	83 ec 0c             	sub    $0xc,%esp
80104884:	68 80 59 11 80       	push   $0x80115980
80104889:	e8 f3 25 00 00       	call   80106e81 <holding>
8010488e:	83 c4 10             	add    $0x10,%esp
80104891:	85 c0                	test   %eax,%eax
80104893:	75 0d                	jne    801048a2 <addToStateListEnd+0x27>
	panic("Not holding the lock!");
80104895:	83 ec 0c             	sub    $0xc,%esp
80104898:	68 30 aa 10 80       	push   $0x8010aa30
8010489d:	e8 c4 bc ff ff       	call   80100566 <panic>
    }

    struct proc *current = *sList;
801048a2:	8b 45 08             	mov    0x8(%ebp),%eax
801048a5:	8b 00                	mov    (%eax),%eax
801048a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(!current){
801048aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048ae:	75 28                	jne    801048d8 <addToStateListEnd+0x5d>
	*sList = p;
801048b0:	8b 45 08             	mov    0x8(%ebp),%eax
801048b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801048b6:	89 10                	mov    %edx,(%eax)
	p -> next = 0;
801048b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801048bb:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801048c2:	00 00 00 
	return 0;
801048c5:	b8 00 00 00 00       	mov    $0x0,%eax
801048ca:	eb 37                	jmp    80104903 <addToStateListEnd+0x88>
    }
    while(current -> next)
	current = current -> next;
801048cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cf:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801048d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!current){
	*sList = p;
	p -> next = 0;
	return 0;
    }
    while(current -> next)
801048d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048db:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801048e1:	85 c0                	test   %eax,%eax
801048e3:	75 e7                	jne    801048cc <addToStateListEnd+0x51>
	current = current -> next;
    
    current -> next = p;
801048e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801048eb:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)

    p -> next = 0;
801048f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801048f4:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801048fb:	00 00 00 

    return 0;
801048fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104903:	c9                   	leave  
80104904:	c3                   	ret    

80104905 <removeFromStateListHead>:

static int
removeFromStateListHead(struct proc** sList, struct proc* p){
80104905:	55                   	push   %ebp
80104906:	89 e5                	mov    %esp,%ebp
80104908:	83 ec 18             	sub    $0x18,%esp
    if(!holding(&ptable.lock)){
8010490b:	83 ec 0c             	sub    $0xc,%esp
8010490e:	68 80 59 11 80       	push   $0x80115980
80104913:	e8 69 25 00 00       	call   80106e81 <holding>
80104918:	83 c4 10             	add    $0x10,%esp
8010491b:	85 c0                	test   %eax,%eax
8010491d:	75 0d                	jne    8010492c <removeFromStateListHead+0x27>
	panic("Not holding the lock!");
8010491f:	83 ec 0c             	sub    $0xc,%esp
80104922:	68 30 aa 10 80       	push   $0x8010aa30
80104927:	e8 3a bc ff ff       	call   80100566 <panic>
    }

    if(!sList){
8010492c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104930:	75 07                	jne    80104939 <removeFromStateListHead+0x34>
	return -1;
80104932:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104937:	eb 28                	jmp    80104961 <removeFromStateListHead+0x5c>
    }
    
    struct proc* head = *sList;
80104939:	8b 45 08             	mov    0x8(%ebp),%eax
8010493c:	8b 00                	mov    (%eax),%eax
8010493e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    *sList = head -> next;
80104941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104944:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
8010494a:	8b 45 08             	mov    0x8(%ebp),%eax
8010494d:	89 10                	mov    %edx,(%eax)
    p -> next = 0;
8010494f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104952:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104959:	00 00 00 

    return 0;
8010495c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104961:	c9                   	leave  
80104962:	c3                   	ret    

80104963 <removeFromStateList>:

static int
removeFromStateList(struct proc** sList, struct proc* p){
80104963:	55                   	push   %ebp
80104964:	89 e5                	mov    %esp,%ebp
80104966:	83 ec 18             	sub    $0x18,%esp
    
    if(!holding(&ptable.lock)){
80104969:	83 ec 0c             	sub    $0xc,%esp
8010496c:	68 80 59 11 80       	push   $0x80115980
80104971:	e8 0b 25 00 00       	call   80106e81 <holding>
80104976:	83 c4 10             	add    $0x10,%esp
80104979:	85 c0                	test   %eax,%eax
8010497b:	75 0d                	jne    8010498a <removeFromStateList+0x27>
	panic("Not holding the lock!");
8010497d:	83 ec 0c             	sub    $0xc,%esp
80104980:	68 30 aa 10 80       	push   $0x8010aa30
80104985:	e8 dc bb ff ff       	call   80100566 <panic>
    }
    struct proc *current = *sList;
8010498a:	8b 45 08             	mov    0x8(%ebp),%eax
8010498d:	8b 00                	mov    (%eax),%eax
8010498f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc *previous = *sList;
80104992:	8b 45 08             	mov    0x8(%ebp),%eax
80104995:	8b 00                	mov    (%eax),%eax
80104997:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if(*sList == 0)
8010499a:	8b 45 08             	mov    0x8(%ebp),%eax
8010499d:	8b 00                	mov    (%eax),%eax
8010499f:	85 c0                	test   %eax,%eax
801049a1:	75 0a                	jne    801049ad <removeFromStateList+0x4a>
	return -1;
801049a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049a8:	e9 81 00 00 00       	jmp    80104a2e <removeFromStateList+0xcb>

    if(*sList == p){
801049ad:	8b 45 08             	mov    0x8(%ebp),%eax
801049b0:	8b 00                	mov    (%eax),%eax
801049b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801049b5:	75 36                	jne    801049ed <removeFromStateList+0x8a>
	*sList = (*sList) -> next;
801049b7:	8b 45 08             	mov    0x8(%ebp),%eax
801049ba:	8b 00                	mov    (%eax),%eax
801049bc:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801049c2:	8b 45 08             	mov    0x8(%ebp),%eax
801049c5:	89 10                	mov    %edx,(%eax)
	p -> next = 0;
801049c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801049ca:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801049d1:	00 00 00 
	return 0;
801049d4:	b8 00 00 00 00       	mov    $0x0,%eax
801049d9:	eb 53                	jmp    80104a2e <removeFromStateList+0xcb>
    }
    while(current != 0 && current != p) {
	previous = current;
801049db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049de:	89 45 f0             	mov    %eax,-0x10(%ebp)
	current = current -> next;
801049e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e4:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801049ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(*sList == p){
	*sList = (*sList) -> next;
	p -> next = 0;
	return 0;
    }
    while(current != 0 && current != p) {
801049ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049f1:	74 08                	je     801049fb <removeFromStateList+0x98>
801049f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801049f9:	75 e0                	jne    801049db <removeFromStateList+0x78>
	previous = current;
	current = current -> next;
    }

    if(current == p){
801049fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104a01:	75 26                	jne    80104a29 <removeFromStateList+0xc6>
	previous -> next = current -> next;
80104a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a06:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a0f:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	p -> next = 0;
80104a15:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a18:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104a1f:	00 00 00 
    }
    else
	return -1;

    return 0;
80104a22:	b8 00 00 00 00       	mov    $0x0,%eax
80104a27:	eb 05                	jmp    80104a2e <removeFromStateList+0xcb>
    if(current == p){
	previous -> next = current -> next;
	p -> next = 0;
    }
    else
	return -1;
80104a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

    return 0;

    
}
80104a2e:	c9                   	leave  
80104a2f:	c3                   	ret    

80104a30 <pinit>:

#endif

void
pinit(void)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104a36:	83 ec 08             	sub    $0x8,%esp
80104a39:	68 46 aa 10 80       	push   $0x8010aa46
80104a3e:	68 80 59 11 80       	push   $0x80115980
80104a43:	e8 e4 22 00 00       	call   80106d2c <initlock>
80104a48:	83 c4 10             	add    $0x10,%esp
}
80104a4b:	90                   	nop
80104a4c:	c9                   	leave  
80104a4d:	c3                   	ret    

80104a4e <allocproc>:
}

#else
static struct proc*
allocproc(void)
{
80104a4e:	55                   	push   %ebp
80104a4f:	89 e5                	mov    %esp,%ebp
80104a51:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104a54:	83 ec 0c             	sub    $0xc,%esp
80104a57:	68 80 59 11 80       	push   $0x80115980
80104a5c:	e8 ed 22 00 00       	call   80106d4e <acquire>
80104a61:	83 c4 10             	add    $0x10,%esp

  p = ptable.pLists.free;
80104a64:	a1 c8 80 11 80       	mov    0x801180c8,%eax
80104a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p){
80104a6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a70:	75 1a                	jne    80104a8c <allocproc+0x3e>
    release(&ptable.lock);
80104a72:	83 ec 0c             	sub    $0xc,%esp
80104a75:	68 80 59 11 80       	push   $0x80115980
80104a7a:	e8 36 23 00 00       	call   80106db5 <release>
80104a7f:	83 c4 10             	add    $0x10,%esp
    return 0;
80104a82:	b8 00 00 00 00       	mov    $0x0,%eax
80104a87:	e9 3d 01 00 00       	jmp    80104bc9 <allocproc+0x17b>
  }

  assertStateFree(p);
80104a8c:	83 ec 0c             	sub    $0xc,%esp
80104a8f:	ff 75 f4             	pushl  -0xc(%ebp)
80104a92:	e8 1f fd ff ff       	call   801047b6 <assertStateFree>
80104a97:	83 c4 10             	add    $0x10,%esp

  removeFromStateListHead(&ptable.pLists.free, p);
80104a9a:	83 ec 08             	sub    $0x8,%esp
80104a9d:	ff 75 f4             	pushl  -0xc(%ebp)
80104aa0:	68 c8 80 11 80       	push   $0x801180c8
80104aa5:	e8 5b fe ff ff       	call   80104905 <removeFromStateListHead>
80104aaa:	83 c4 10             	add    $0x10,%esp

  p->state = EMBRYO;
80104aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  addToStateListEnd(&ptable.pLists.embryo, p);
80104ab7:	83 ec 08             	sub    $0x8,%esp
80104aba:	ff 75 f4             	pushl  -0xc(%ebp)
80104abd:	68 d8 80 11 80       	push   $0x801180d8
80104ac2:	e8 b4 fd ff ff       	call   8010487b <addToStateListEnd>
80104ac7:	83 c4 10             	add    $0x10,%esp

  p->pid = nextpid++;
80104aca:	a1 04 e0 10 80       	mov    0x8010e004,%eax
80104acf:	8d 50 01             	lea    0x1(%eax),%edx
80104ad2:	89 15 04 e0 10 80    	mov    %edx,0x8010e004
80104ad8:	89 c2                	mov    %eax,%edx
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
80104ae0:	83 ec 0c             	sub    $0xc,%esp
80104ae3:	68 80 59 11 80       	push   $0x80115980
80104ae8:	e8 c8 22 00 00       	call   80106db5 <release>
80104aed:	83 c4 10             	add    $0x10,%esp
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104af0:	e8 d2 e4 ff ff       	call   80102fc7 <kalloc>
80104af5:	89 c2                	mov    %eax,%edx
80104af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afa:	89 50 08             	mov    %edx,0x8(%eax)
80104afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b00:	8b 40 08             	mov    0x8(%eax),%eax
80104b03:	85 c0                	test   %eax,%eax
80104b05:	75 65                	jne    80104b6c <allocproc+0x11e>

  acquire(&ptable.lock);
80104b07:	83 ec 0c             	sub    $0xc,%esp
80104b0a:	68 80 59 11 80       	push   $0x80115980
80104b0f:	e8 3a 22 00 00       	call   80106d4e <acquire>
80104b14:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104b17:	83 ec 0c             	sub    $0xc,%esp
80104b1a:	ff 75 f4             	pushl  -0xc(%ebp)
80104b1d:	e8 d5 fc ff ff       	call   801047f7 <assertStateEmbryo>
80104b22:	83 c4 10             	add    $0x10,%esp
  removeFromStateListHead(&ptable.pLists.embryo, p);
80104b25:	83 ec 08             	sub    $0x8,%esp
80104b28:	ff 75 f4             	pushl  -0xc(%ebp)
80104b2b:	68 d8 80 11 80       	push   $0x801180d8
80104b30:	e8 d0 fd ff ff       	call   80104905 <removeFromStateListHead>
80104b35:	83 c4 10             	add    $0x10,%esp

  p->state = UNUSED;
80104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  addToStateListEnd(&ptable.pLists.free, p);
80104b42:	83 ec 08             	sub    $0x8,%esp
80104b45:	ff 75 f4             	pushl  -0xc(%ebp)
80104b48:	68 c8 80 11 80       	push   $0x801180c8
80104b4d:	e8 29 fd ff ff       	call   8010487b <addToStateListEnd>
80104b52:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104b55:	83 ec 0c             	sub    $0xc,%esp
80104b58:	68 80 59 11 80       	push   $0x80115980
80104b5d:	e8 53 22 00 00       	call   80106db5 <release>
80104b62:	83 c4 10             	add    $0x10,%esp

    return 0;
80104b65:	b8 00 00 00 00       	mov    $0x0,%eax
80104b6a:	eb 5d                	jmp    80104bc9 <allocproc+0x17b>
  }
  sp = p->kstack + KSTACKSIZE;
80104b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6f:	8b 40 08             	mov    0x8(%eax),%eax
80104b72:	05 00 10 00 00       	add    $0x1000,%eax
80104b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104b7a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b84:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104b87:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104b8b:	ba 42 87 10 80       	mov    $0x80108742,%edx
80104b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b93:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104b95:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b9f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ba8:	83 ec 04             	sub    $0x4,%esp
80104bab:	6a 14                	push   $0x14
80104bad:	6a 00                	push   $0x0
80104baf:	50                   	push   %eax
80104bb0:	e8 fc 23 00 00       	call   80106fb1 <memset>
80104bb5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbb:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bbe:	ba f3 59 10 80       	mov    $0x801059f3,%edx
80104bc3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bc9:	c9                   	leave  
80104bca:	c3                   	ret    

80104bcb <userinit>:
// Return 0 on success, -1 on failure.

#else
void
userinit(void)
{
80104bcb:	55                   	push   %ebp
80104bcc:	89 e5                	mov    %esp,%ebp
80104bce:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  for(int i = 0; i < MAX+1; ++i)
80104bd1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bd8:	eb 17                	jmp    80104bf1 <userinit+0x26>
    ptable.pLists.ready[i] = 0;
80104bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdd:	05 cc 09 00 00       	add    $0x9cc,%eax
80104be2:	c7 04 85 84 59 11 80 	movl   $0x0,-0x7feea67c(,%eax,4)
80104be9:	00 00 00 00 
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  for(int i = 0; i < MAX+1; ++i)
80104bed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bf1:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80104bf5:	7e e3                	jle    80104bda <userinit+0xf>
    ptable.pLists.ready[i] = 0;

  ptable.pLists.free = 0;
80104bf7:	c7 05 c8 80 11 80 00 	movl   $0x0,0x801180c8
80104bfe:	00 00 00 
  ptable.pLists.sleep = 0;
80104c01:	c7 05 cc 80 11 80 00 	movl   $0x0,0x801180cc
80104c08:	00 00 00 
  ptable.pLists.zombie = 0;
80104c0b:	c7 05 d0 80 11 80 00 	movl   $0x0,0x801180d0
80104c12:	00 00 00 
  ptable.pLists.running = 0;
80104c15:	c7 05 d4 80 11 80 00 	movl   $0x0,0x801180d4
80104c1c:	00 00 00 
  ptable.pLists.embryo = 0;
80104c1f:	c7 05 d8 80 11 80 00 	movl   $0x0,0x801180d8
80104c26:	00 00 00 

  acquire(&ptable.lock);
80104c29:	83 ec 0c             	sub    $0xc,%esp
80104c2c:	68 80 59 11 80       	push   $0x80115980
80104c31:	e8 18 21 00 00       	call   80106d4e <acquire>
80104c36:	83 c4 10             	add    $0x10,%esp
  for(int i = 0; i < NPROC; i++){
80104c39:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104c40:	eb 51                	jmp    80104c93 <userinit+0xc8>
    addToStateListEnd(&ptable.pLists.free, &ptable.proc[i]);
80104c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c45:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104c4b:	83 c0 30             	add    $0x30,%eax
80104c4e:	05 80 59 11 80       	add    $0x80115980,%eax
80104c53:	83 c0 04             	add    $0x4,%eax
80104c56:	83 ec 08             	sub    $0x8,%esp
80104c59:	50                   	push   %eax
80104c5a:	68 c8 80 11 80       	push   $0x801180c8
80104c5f:	e8 17 fc ff ff       	call   8010487b <addToStateListEnd>
80104c64:	83 c4 10             	add    $0x10,%esp
    ptable.proc[i].priority = 0;
80104c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c6a:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104c70:	05 48 5a 11 80       	add    $0x80115a48,%eax
80104c75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    ptable.proc[i].budget = BUDGET;
80104c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7e:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80104c84:	05 4c 5a 11 80       	add    $0x80115a4c,%eax
80104c89:	c7 00 88 13 00 00    	movl   $0x1388,(%eax)
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  acquire(&ptable.lock);
  for(int i = 0; i < NPROC; i++){
80104c8f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104c93:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104c97:	7e a9                	jle    80104c42 <userinit+0x77>
    addToStateListEnd(&ptable.pLists.free, &ptable.proc[i]);
    ptable.proc[i].priority = 0;
    ptable.proc[i].budget = BUDGET;
  }
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
80104c99:	a1 e0 88 11 80       	mov    0x801188e0,%eax
80104c9e:	05 88 13 00 00       	add    $0x1388,%eax
80104ca3:	a3 dc 80 11 80       	mov    %eax,0x801180dc

  release(&ptable.lock);
80104ca8:	83 ec 0c             	sub    $0xc,%esp
80104cab:	68 80 59 11 80       	push   $0x80115980
80104cb0:	e8 00 21 00 00       	call   80106db5 <release>
80104cb5:	83 c4 10             	add    $0x10,%esp


  p = allocproc();
80104cb8:	e8 91 fd ff ff       	call   80104a4e <allocproc>
80104cbd:	89 45 ec             	mov    %eax,-0x14(%ebp)

  initproc = p;
80104cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cc3:	a3 68 e6 10 80       	mov    %eax,0x8010e668
  if((p->pgdir = setupkvm()) == 0)
80104cc8:	e8 37 51 00 00       	call   80109e04 <setupkvm>
80104ccd:	89 c2                	mov    %eax,%edx
80104ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cd2:	89 50 04             	mov    %edx,0x4(%eax)
80104cd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cd8:	8b 40 04             	mov    0x4(%eax),%eax
80104cdb:	85 c0                	test   %eax,%eax
80104cdd:	75 0d                	jne    80104cec <userinit+0x121>
    panic("userinit: out of memory?");
80104cdf:	83 ec 0c             	sub    $0xc,%esp
80104ce2:	68 4d aa 10 80       	push   $0x8010aa4d
80104ce7:	e8 7a b8 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104cec:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104cf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cf4:	8b 40 04             	mov    0x4(%eax),%eax
80104cf7:	83 ec 04             	sub    $0x4,%esp
80104cfa:	52                   	push   %edx
80104cfb:	68 00 e5 10 80       	push   $0x8010e500
80104d00:	50                   	push   %eax
80104d01:	e8 58 53 00 00       	call   8010a05e <inituvm>
80104d06:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104d09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d0c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104d12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d15:	8b 40 18             	mov    0x18(%eax),%eax
80104d18:	83 ec 04             	sub    $0x4,%esp
80104d1b:	6a 4c                	push   $0x4c
80104d1d:	6a 00                	push   $0x0
80104d1f:	50                   	push   %eax
80104d20:	e8 8c 22 00 00       	call   80106fb1 <memset>
80104d25:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d2b:	8b 40 18             	mov    0x18(%eax),%eax
80104d2e:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d37:	8b 40 18             	mov    0x18(%eax),%eax
80104d3a:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104d40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d43:	8b 40 18             	mov    0x18(%eax),%eax
80104d46:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d49:	8b 52 18             	mov    0x18(%edx),%edx
80104d4c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104d50:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104d54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d57:	8b 40 18             	mov    0x18(%eax),%eax
80104d5a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d5d:	8b 52 18             	mov    0x18(%edx),%edx
80104d60:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104d64:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d6b:	8b 40 18             	mov    0x18(%eax),%eax
80104d6e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104d75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d78:	8b 40 18             	mov    0x18(%eax),%eax
80104d7b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d85:	8b 40 18             	mov    0x18(%eax),%eax
80104d88:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104d8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d92:	83 c0 6c             	add    $0x6c,%eax
80104d95:	83 ec 04             	sub    $0x4,%esp
80104d98:	6a 10                	push   $0x10
80104d9a:	68 66 aa 10 80       	push   $0x8010aa66
80104d9f:	50                   	push   %eax
80104da0:	e8 0f 24 00 00       	call   801071b4 <safestrcpy>
80104da5:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104da8:	83 ec 0c             	sub    $0xc,%esp
80104dab:	68 6f aa 10 80       	push   $0x8010aa6f
80104db0:	e8 33 d9 ff ff       	call   801026e8 <namei>
80104db5:	83 c4 10             	add    $0x10,%esp
80104db8:	89 c2                	mov    %eax,%edx
80104dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104dbd:	89 50 68             	mov    %edx,0x68(%eax)

  acquire(&ptable.lock);
80104dc0:	83 ec 0c             	sub    $0xc,%esp
80104dc3:	68 80 59 11 80       	push   $0x80115980
80104dc8:	e8 81 1f 00 00       	call   80106d4e <acquire>
80104dcd:	83 c4 10             	add    $0x10,%esp

  assertStateEmbryo(p);
80104dd0:	83 ec 0c             	sub    $0xc,%esp
80104dd3:	ff 75 ec             	pushl  -0x14(%ebp)
80104dd6:	e8 1c fa ff ff       	call   801047f7 <assertStateEmbryo>
80104ddb:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.embryo, p);
80104dde:	83 ec 08             	sub    $0x8,%esp
80104de1:	ff 75 ec             	pushl  -0x14(%ebp)
80104de4:	68 d8 80 11 80       	push   $0x801180d8
80104de9:	e8 75 fb ff ff       	call   80104963 <removeFromStateList>
80104dee:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNABLE;
80104df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104df4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[0], p);
80104dfb:	83 ec 08             	sub    $0x8,%esp
80104dfe:	ff 75 ec             	pushl  -0x14(%ebp)
80104e01:	68 b4 80 11 80       	push   $0x801180b4
80104e06:	e8 70 fa ff ff       	call   8010487b <addToStateListEnd>
80104e0b:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104e0e:	83 ec 0c             	sub    $0xc,%esp
80104e11:	68 80 59 11 80       	push   $0x80115980
80104e16:	e8 9a 1f 00 00       	call   80106db5 <release>
80104e1b:	83 c4 10             	add    $0x10,%esp


}
80104e1e:	90                   	nop
80104e1f:	c9                   	leave  
80104e20:	c3                   	ret    

80104e21 <growproc>:
#endif
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104e21:	55                   	push   %ebp
80104e22:	89 e5                	mov    %esp,%ebp
80104e24:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104e27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e2d:	8b 00                	mov    (%eax),%eax
80104e2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104e36:	7e 31                	jle    80104e69 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104e38:	8b 55 08             	mov    0x8(%ebp),%edx
80104e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3e:	01 c2                	add    %eax,%edx
80104e40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e46:	8b 40 04             	mov    0x4(%eax),%eax
80104e49:	83 ec 04             	sub    $0x4,%esp
80104e4c:	52                   	push   %edx
80104e4d:	ff 75 f4             	pushl  -0xc(%ebp)
80104e50:	50                   	push   %eax
80104e51:	e8 55 53 00 00       	call   8010a1ab <allocuvm>
80104e56:	83 c4 10             	add    $0x10,%esp
80104e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e60:	75 3e                	jne    80104ea0 <growproc+0x7f>
      return -1;
80104e62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e67:	eb 59                	jmp    80104ec2 <growproc+0xa1>
  } else if(n < 0){
80104e69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104e6d:	79 31                	jns    80104ea0 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104e6f:	8b 55 08             	mov    0x8(%ebp),%edx
80104e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e75:	01 c2                	add    %eax,%edx
80104e77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7d:	8b 40 04             	mov    0x4(%eax),%eax
80104e80:	83 ec 04             	sub    $0x4,%esp
80104e83:	52                   	push   %edx
80104e84:	ff 75 f4             	pushl  -0xc(%ebp)
80104e87:	50                   	push   %eax
80104e88:	e8 e7 53 00 00       	call   8010a274 <deallocuvm>
80104e8d:	83 c4 10             	add    $0x10,%esp
80104e90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e97:	75 07                	jne    80104ea0 <growproc+0x7f>
      return -1;
80104e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e9e:	eb 22                	jmp    80104ec2 <growproc+0xa1>
  }
  proc->sz = sz;
80104ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea9:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eb1:	83 ec 0c             	sub    $0xc,%esp
80104eb4:	50                   	push   %eax
80104eb5:	e8 31 50 00 00       	call   80109eeb <switchuvm>
80104eba:	83 c4 10             	add    $0x10,%esp
  return 0;
80104ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ec2:	c9                   	leave  
80104ec3:	c3                   	ret    

80104ec4 <fork>:

#else

int
fork(void)
{
80104ec4:	55                   	push   %ebp
80104ec5:	89 e5                	mov    %esp,%ebp
80104ec7:	57                   	push   %edi
80104ec8:	56                   	push   %esi
80104ec9:	53                   	push   %ebx
80104eca:	83 ec 1c             	sub    $0x1c,%esp

  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104ecd:	e8 7c fb ff ff       	call   80104a4e <allocproc>
80104ed2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104ed5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104ed9:	75 0a                	jne    80104ee5 <fork+0x21>
    return -1;
80104edb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee0:	e9 09 02 00 00       	jmp    801050ee <fork+0x22a>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104ee5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eeb:	8b 10                	mov    (%eax),%edx
80104eed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef3:	8b 40 04             	mov    0x4(%eax),%eax
80104ef6:	83 ec 08             	sub    $0x8,%esp
80104ef9:	52                   	push   %edx
80104efa:	50                   	push   %eax
80104efb:	e8 12 55 00 00       	call   8010a412 <copyuvm>
80104f00:	83 c4 10             	add    $0x10,%esp
80104f03:	89 c2                	mov    %eax,%edx
80104f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f08:	89 50 04             	mov    %edx,0x4(%eax)
80104f0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f0e:	8b 40 04             	mov    0x4(%eax),%eax
80104f11:	85 c0                	test   %eax,%eax
80104f13:	0f 85 84 00 00 00    	jne    80104f9d <fork+0xd9>
    kfree(np->kstack);
80104f19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f1c:	8b 40 08             	mov    0x8(%eax),%eax
80104f1f:	83 ec 0c             	sub    $0xc,%esp
80104f22:	50                   	push   %eax
80104f23:	e8 02 e0 ff ff       	call   80102f2a <kfree>
80104f28:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f2e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  assertStateZombie(np); 
80104f35:	83 ec 0c             	sub    $0xc,%esp
80104f38:	ff 75 e0             	pushl  -0x20(%ebp)
80104f3b:	e8 96 f8 ff ff       	call   801047d6 <assertStateZombie>
80104f40:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.zombie, np);
80104f43:	83 ec 08             	sub    $0x8,%esp
80104f46:	ff 75 e0             	pushl  -0x20(%ebp)
80104f49:	68 d0 80 11 80       	push   $0x801180d0
80104f4e:	e8 10 fa ff ff       	call   80104963 <removeFromStateList>
80104f53:	83 c4 10             	add    $0x10,%esp

  np->state = UNUSED;
80104f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f59:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  cprintf("\nZOMBIE -> UNUSED\n");
80104f60:	83 ec 0c             	sub    $0xc,%esp
80104f63:	68 71 aa 10 80       	push   $0x8010aa71
80104f68:	e8 59 b4 ff ff       	call   801003c6 <cprintf>
80104f6d:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.free, np);
80104f70:	83 ec 08             	sub    $0x8,%esp
80104f73:	ff 75 e0             	pushl  -0x20(%ebp)
80104f76:	68 c8 80 11 80       	push   $0x801180c8
80104f7b:	e8 fb f8 ff ff       	call   8010487b <addToStateListEnd>
80104f80:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80104f83:	83 ec 0c             	sub    $0xc,%esp
80104f86:	68 80 59 11 80       	push   $0x80115980
80104f8b:	e8 25 1e 00 00       	call   80106db5 <release>
80104f90:	83 c4 10             	add    $0x10,%esp

    return -1;
80104f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f98:	e9 51 01 00 00       	jmp    801050ee <fork+0x22a>
  }
  np->sz = proc->sz;
80104f9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa3:	8b 10                	mov    (%eax),%edx
80104fa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104faa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fb4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104fb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fba:	8b 50 18             	mov    0x18(%eax),%edx
80104fbd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc3:	8b 40 18             	mov    0x18(%eax),%eax
80104fc6:	89 c3                	mov    %eax,%ebx
80104fc8:	b8 13 00 00 00       	mov    $0x13,%eax
80104fcd:	89 d7                	mov    %edx,%edi
80104fcf:	89 de                	mov    %ebx,%esi
80104fd1:	89 c1                	mov    %eax,%ecx
80104fd3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)



  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104fd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd8:	8b 40 18             	mov    0x18(%eax),%eax
80104fdb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104fe2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104fe9:	eb 43                	jmp    8010502e <fork+0x16a>
    if(proc->ofile[i])
80104feb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ff4:	83 c2 08             	add    $0x8,%edx
80104ff7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ffb:	85 c0                	test   %eax,%eax
80104ffd:	74 2b                	je     8010502a <fork+0x166>
      np->ofile[i] = filedup(proc->ofile[i]);
80104fff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105005:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105008:	83 c2 08             	add    $0x8,%edx
8010500b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010500f:	83 ec 0c             	sub    $0xc,%esp
80105012:	50                   	push   %eax
80105013:	e8 14 c1 ff ff       	call   8010112c <filedup>
80105018:	83 c4 10             	add    $0x10,%esp
8010501b:	89 c1                	mov    %eax,%ecx
8010501d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105020:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105023:	83 c2 08             	add    $0x8,%edx
80105026:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010502a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010502e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105032:	7e b7                	jle    80104feb <fork+0x127>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105034:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010503a:	8b 40 68             	mov    0x68(%eax),%eax
8010503d:	83 ec 0c             	sub    $0xc,%esp
80105040:	50                   	push   %eax
80105041:	e8 5a ca ff ff       	call   80101aa0 <idup>
80105046:	83 c4 10             	add    $0x10,%esp
80105049:	89 c2                	mov    %eax,%edx
8010504b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010504e:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80105051:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105057:	8d 50 6c             	lea    0x6c(%eax),%edx
8010505a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010505d:	83 c0 6c             	add    $0x6c,%eax
80105060:	83 ec 04             	sub    $0x4,%esp
80105063:	6a 10                	push   $0x10
80105065:	52                   	push   %edx
80105066:	50                   	push   %eax
80105067:	e8 48 21 00 00       	call   801071b4 <safestrcpy>
8010506c:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
8010506f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105072:	8b 40 10             	mov    0x10(%eax),%eax
80105075:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.


  acquire(&ptable.lock);
80105078:	83 ec 0c             	sub    $0xc,%esp
8010507b:	68 80 59 11 80       	push   $0x80115980
80105080:	e8 c9 1c 00 00       	call   80106d4e <acquire>
80105085:	83 c4 10             	add    $0x10,%esp
  assertStateEmbryo(np);
80105088:	83 ec 0c             	sub    $0xc,%esp
8010508b:	ff 75 e0             	pushl  -0x20(%ebp)
8010508e:	e8 64 f7 ff ff       	call   801047f7 <assertStateEmbryo>
80105093:	83 c4 10             	add    $0x10,%esp

  removeFromStateListHead(&ptable.pLists.embryo, np);
80105096:	83 ec 08             	sub    $0x8,%esp
80105099:	ff 75 e0             	pushl  -0x20(%ebp)
8010509c:	68 d8 80 11 80       	push   $0x801180d8
801050a1:	e8 5f f8 ff ff       	call   80104905 <removeFromStateListHead>
801050a6:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801050a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050ac:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[np -> priority], np);	//Change to priority queue
801050b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050b6:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801050bc:	05 cc 09 00 00       	add    $0x9cc,%eax
801050c1:	c1 e0 02             	shl    $0x2,%eax
801050c4:	05 80 59 11 80       	add    $0x80115980,%eax
801050c9:	83 c0 04             	add    $0x4,%eax
801050cc:	83 ec 08             	sub    $0x8,%esp
801050cf:	ff 75 e0             	pushl  -0x20(%ebp)
801050d2:	50                   	push   %eax
801050d3:	e8 a3 f7 ff ff       	call   8010487b <addToStateListEnd>
801050d8:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
801050db:	83 ec 0c             	sub    $0xc,%esp
801050de:	68 80 59 11 80       	push   $0x80115980
801050e3:	e8 cd 1c 00 00       	call   80106db5 <release>
801050e8:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801050eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801050ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050f1:	5b                   	pop    %ebx
801050f2:	5e                   	pop    %esi
801050f3:	5f                   	pop    %edi
801050f4:	5d                   	pop    %ebp
801050f5:	c3                   	ret    

801050f6 <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
801050f6:	55                   	push   %ebp
801050f7:	89 e5                	mov    %esp,%ebp
801050f9:	83 ec 18             	sub    $0x18,%esp

  struct proc *p;
  int fd;

  if(proc == initproc)
801050fc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105103:	a1 68 e6 10 80       	mov    0x8010e668,%eax
80105108:	39 c2                	cmp    %eax,%edx
8010510a:	75 0d                	jne    80105119 <exit+0x23>
    panic("init exiting");
8010510c:	83 ec 0c             	sub    $0xc,%esp
8010510f:	68 84 aa 10 80       	push   $0x8010aa84
80105114:	e8 4d b4 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105119:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105120:	eb 48                	jmp    8010516a <exit+0x74>
    if(proc->ofile[fd]){
80105122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105128:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010512b:	83 c2 08             	add    $0x8,%edx
8010512e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105132:	85 c0                	test   %eax,%eax
80105134:	74 30                	je     80105166 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105136:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010513f:	83 c2 08             	add    $0x8,%edx
80105142:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105146:	83 ec 0c             	sub    $0xc,%esp
80105149:	50                   	push   %eax
8010514a:	e8 2e c0 ff ff       	call   8010117d <fileclose>
8010514f:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80105152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105158:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010515b:	83 c2 08             	add    $0x8,%edx
8010515e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105165:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105166:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010516a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010516e:	7e b2                	jle    80105122 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80105170:	e8 39 e7 ff ff       	call   801038ae <begin_op>
  iput(proc->cwd);
80105175:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010517b:	8b 40 68             	mov    0x68(%eax),%eax
8010517e:	83 ec 0c             	sub    $0xc,%esp
80105181:	50                   	push   %eax
80105182:	e8 4b cb ff ff       	call   80101cd2 <iput>
80105187:	83 c4 10             	add    $0x10,%esp
  end_op();
8010518a:	e8 ab e7 ff ff       	call   8010393a <end_op>
  proc->cwd = 0;
8010518f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105195:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010519c:	83 ec 0c             	sub    $0xc,%esp
8010519f:	68 80 59 11 80       	push   $0x80115980
801051a4:	e8 a5 1b 00 00       	call   80106d4e <acquire>
801051a9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801051ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b2:	8b 40 14             	mov    0x14(%eax),%eax
801051b5:	83 ec 0c             	sub    $0xc,%esp
801051b8:	50                   	push   %eax
801051b9:	e8 f0 09 00 00       	call   80105bae <wakeup1>
801051be:	83 c4 10             	add    $0x10,%esp
  int found = 0;
801051c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  // Pass abandoned children to init.



  p = ptable.pLists.running;
801051c8:	a1 d4 80 11 80       	mov    0x801180d4,%eax
801051cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(p && !found){
801051d0:	eb 2f                	jmp    80105201 <exit+0x10b>
    if(p->parent == proc){
801051d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d5:	8b 50 14             	mov    0x14(%eax),%edx
801051d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051de:	39 c2                	cmp    %eax,%edx
801051e0:	75 13                	jne    801051f5 <exit+0xff>
      found = 1;
801051e2:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      p->parent = initproc;
801051e9:	8b 15 68 e6 10 80    	mov    0x8010e668,%edx
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	89 50 14             	mov    %edx,0x14(%eax)
    }
    p = p -> next;
801051f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // Pass abandoned children to init.



  p = ptable.pLists.running;
  while(p && !found){
80105201:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105205:	74 06                	je     8010520d <exit+0x117>
80105207:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010520b:	74 c5                	je     801051d2 <exit+0xdc>
      found = 1;
      p->parent = initproc;
    }
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
8010520d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80105214:	eb 53                	jmp    80105269 <exit+0x173>
      p = ptable.pLists.ready[i];	//Change to priority queue
80105216:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105219:	05 cc 09 00 00       	add    $0x9cc,%eax
8010521e:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
80105225:	89 45 f4             	mov    %eax,-0xc(%ebp)

      while(p && !found){
80105228:	eb 2f                	jmp    80105259 <exit+0x163>
	if(p->parent == proc){
8010522a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010522d:	8b 50 14             	mov    0x14(%eax),%edx
80105230:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105236:	39 c2                	cmp    %eax,%edx
80105238:	75 13                	jne    8010524d <exit+0x157>

	  found = 1;
8010523a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
80105241:	8b 15 68 e6 10 80    	mov    0x8010e668,%edx
80105247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524a:	89 50 14             	mov    %edx,0x14(%eax)
	}
	p = p -> next;
8010524d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105250:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105256:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
      p = ptable.pLists.ready[i];	//Change to priority queue

      while(p && !found){
80105259:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010525d:	74 06                	je     80105265 <exit+0x16f>
8010525f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105263:	74 c5                	je     8010522a <exit+0x134>
      found = 1;
      p->parent = initproc;
    }
    p = p -> next;
  }
  for(int i = 0; i < MAX+1; ++i){
80105265:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80105269:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
8010526d:	7e a7                	jle    80105216 <exit+0x120>
	}
	p = p -> next;
      }
  }
  
      p = ptable.pLists.sleep;
8010526f:	a1 cc 80 11 80       	mov    0x801180cc,%eax
80105274:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while(p && !found){
80105277:	eb 2f                	jmp    801052a8 <exit+0x1b2>
	if(p->parent == proc){
80105279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527c:	8b 50 14             	mov    0x14(%eax),%edx
8010527f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105285:	39 c2                	cmp    %eax,%edx
80105287:	75 13                	jne    8010529c <exit+0x1a6>
	  found = 1;
80105289:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
80105290:	8b 15 68 e6 10 80    	mov    0x8010e668,%edx
80105296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105299:	89 50 14             	mov    %edx,0x14(%eax)
	}
	p = p -> next;
8010529c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801052a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	p = p -> next;
      }
  }
  
      p = ptable.pLists.sleep;
      while(p && !found){
801052a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052ac:	74 06                	je     801052b4 <exit+0x1be>
801052ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801052b2:	74 c5                	je     80105279 <exit+0x183>
	  found = 1;
	  p->parent = initproc;
	}
	p = p -> next;
      }
      p = ptable.pLists.zombie;
801052b4:	a1 d0 80 11 80       	mov    0x801180d0,%eax
801052b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while(p && !found){
801052bc:	eb 40                	jmp    801052fe <exit+0x208>
	if(p->parent == proc){
801052be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c1:	8b 50 14             	mov    0x14(%eax),%edx
801052c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ca:	39 c2                	cmp    %eax,%edx
801052cc:	75 24                	jne    801052f2 <exit+0x1fc>

	  found = 1;
801052ce:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->parent = initproc;
801052d5:	8b 15 68 e6 10 80    	mov    0x8010e668,%edx
801052db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052de:	89 50 14             	mov    %edx,0x14(%eax)
	  wakeup1(initproc);
801052e1:	a1 68 e6 10 80       	mov    0x8010e668,%eax
801052e6:	83 ec 0c             	sub    $0xc,%esp
801052e9:	50                   	push   %eax
801052ea:	e8 bf 08 00 00       	call   80105bae <wakeup1>
801052ef:	83 c4 10             	add    $0x10,%esp

	}
	p = p -> next;
801052f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f5:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801052fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  p->parent = initproc;
	}
	p = p -> next;
      }
      p = ptable.pLists.zombie;
      while(p && !found){
801052fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105302:	74 06                	je     8010530a <exit+0x214>
80105304:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105308:	74 b4                	je     801052be <exit+0x1c8>
	}
	p = p -> next;
      }

  // Jump into the scheduler, never to return.
  assertStateRunning(proc);
8010530a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105310:	83 ec 0c             	sub    $0xc,%esp
80105313:	50                   	push   %eax
80105314:	e8 ff f4 ff ff       	call   80104818 <assertStateRunning>
80105319:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.running, proc);
8010531c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105322:	83 ec 08             	sub    $0x8,%esp
80105325:	50                   	push   %eax
80105326:	68 d4 80 11 80       	push   $0x801180d4
8010532b:	e8 33 f6 ff ff       	call   80104963 <removeFromStateList>
80105330:	83 c4 10             	add    $0x10,%esp

  proc -> state = ZOMBIE;
80105333:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105339:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
 
  assertStateZombie(proc);
80105340:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105346:	83 ec 0c             	sub    $0xc,%esp
80105349:	50                   	push   %eax
8010534a:	e8 87 f4 ff ff       	call   801047d6 <assertStateZombie>
8010534f:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.zombie, proc);
80105352:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105358:	83 ec 08             	sub    $0x8,%esp
8010535b:	50                   	push   %eax
8010535c:	68 d0 80 11 80       	push   $0x801180d0
80105361:	e8 15 f5 ff ff       	call   8010487b <addToStateListEnd>
80105366:	83 c4 10             	add    $0x10,%esp

  sched();
80105369:	e8 b5 04 00 00       	call   80105823 <sched>
  panic("zombie exit");
8010536e:	83 ec 0c             	sub    $0xc,%esp
80105371:	68 91 aa 10 80       	push   $0x8010aa91
80105376:	e8 eb b1 ff ff       	call   80100566 <panic>

8010537b <wait>:
  }
}
#else
int
wait(void)
{
8010537b:	55                   	push   %ebp
8010537c:	89 e5                	mov    %esp,%ebp
8010537e:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  int havekids, pid;
  acquire(&ptable.lock);
80105381:	83 ec 0c             	sub    $0xc,%esp
80105384:	68 80 59 11 80       	push   $0x80115980
80105389:	e8 c0 19 00 00       	call   80106d4e <acquire>
8010538e:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105391:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    int found = 0;
80105398:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

     p = ptable.pLists.zombie;
8010539f:	a1 d0 80 11 80       	mov    0x801180d0,%eax
801053a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     while(p && !found){
801053a7:	e9 e0 00 00 00       	jmp    8010548c <wait+0x111>
       if(p->parent == proc){
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	8b 50 14             	mov    0x14(%eax),%edx
801053b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b8:	39 c2                	cmp    %eax,%edx
801053ba:	0f 85 c0 00 00 00    	jne    80105480 <wait+0x105>
	 found = 1;
801053c0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	 havekids = 1;
801053c7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	 pid = p->pid;
801053ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d1:	8b 40 10             	mov    0x10(%eax),%eax
801053d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	 kfree(p->kstack);
801053d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053da:	8b 40 08             	mov    0x8(%eax),%eax
801053dd:	83 ec 0c             	sub    $0xc,%esp
801053e0:	50                   	push   %eax
801053e1:	e8 44 db ff ff       	call   80102f2a <kfree>
801053e6:	83 c4 10             	add    $0x10,%esp
	 p->kstack = 0;
801053e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	 freevm(p->pgdir);
801053f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f6:	8b 40 04             	mov    0x4(%eax),%eax
801053f9:	83 ec 0c             	sub    $0xc,%esp
801053fc:	50                   	push   %eax
801053fd:	e8 2f 4f 00 00       	call   8010a331 <freevm>
80105402:	83 c4 10             	add    $0x10,%esp

	 assertStateZombie(p);
80105405:	83 ec 0c             	sub    $0xc,%esp
80105408:	ff 75 f4             	pushl  -0xc(%ebp)
8010540b:	e8 c6 f3 ff ff       	call   801047d6 <assertStateZombie>
80105410:	83 c4 10             	add    $0x10,%esp

	 removeFromStateList(&ptable.pLists.zombie, p);
80105413:	83 ec 08             	sub    $0x8,%esp
80105416:	ff 75 f4             	pushl  -0xc(%ebp)
80105419:	68 d0 80 11 80       	push   $0x801180d0
8010541e:	e8 40 f5 ff ff       	call   80104963 <removeFromStateList>
80105423:	83 c4 10             	add    $0x10,%esp

	 p->state = UNUSED;
80105426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105429:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	 addToStateListEnd(&ptable.pLists.free, p);
80105430:	83 ec 08             	sub    $0x8,%esp
80105433:	ff 75 f4             	pushl  -0xc(%ebp)
80105436:	68 c8 80 11 80       	push   $0x801180c8
8010543b:	e8 3b f4 ff ff       	call   8010487b <addToStateListEnd>
80105440:	83 c4 10             	add    $0x10,%esp

	 p->pid = 0;
80105443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105446:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
	 p->parent = 0;
8010544d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105450:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	 p->name[0] = 0;
80105457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010545a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
	 p->killed = 0;
8010545e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105461:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
	 release(&ptable.lock);
80105468:	83 ec 0c             	sub    $0xc,%esp
8010546b:	68 80 59 11 80       	push   $0x80115980
80105470:	e8 40 19 00 00       	call   80106db5 <release>
80105475:	83 c4 10             	add    $0x10,%esp
	 return pid;
80105478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010547b:	e9 4b 01 00 00       	jmp    801055cb <wait+0x250>

       }
       p = p -> next;
80105480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105483:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105489:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // Scan through table looking for zombie children.
    havekids = 0;
    int found = 0;

     p = ptable.pLists.zombie;
     while(p && !found){
8010548c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105490:	74 0a                	je     8010549c <wait+0x121>
80105492:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105496:	0f 84 10 ff ff ff    	je     801053ac <wait+0x31>
	 return pid;

       }
       p = p -> next;
     }
    p = ptable.pLists.running;
8010549c:	a1 d4 80 11 80       	mov    0x801180d4,%eax
801054a1:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while(p && !found){
801054a4:	eb 2a                	jmp    801054d0 <wait+0x155>
      if(p->parent == proc){
801054a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a9:	8b 50 14             	mov    0x14(%eax),%edx
801054ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b2:	39 c2                	cmp    %eax,%edx
801054b4:	75 0e                	jne    801054c4 <wait+0x149>
	found = 1;
801054b6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	havekids = 1;
801054bd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      }
      p = p -> next;
801054c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c7:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801054cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
       }
       p = p -> next;
     }
    p = ptable.pLists.running;

    while(p && !found){
801054d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054d4:	74 06                	je     801054dc <wait+0x161>
801054d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801054da:	74 ca                	je     801054a6 <wait+0x12b>
	found = 1;
	havekids = 1;
      }
      p = p -> next;
    }
    if(!found){
801054dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801054e0:	75 5d                	jne    8010553f <wait+0x1c4>
      for(int i = 0; i < MAX+1; ++i){	
801054e2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
801054e9:	eb 4e                	jmp    80105539 <wait+0x1be>
	p = ptable.pLists.ready[i];	//Change to priority queue
801054eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801054ee:	05 cc 09 00 00       	add    $0x9cc,%eax
801054f3:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
801054fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while(p && !found){
801054fd:	eb 2a                	jmp    80105529 <wait+0x1ae>
	  if(p->parent == proc){
801054ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105502:	8b 50 14             	mov    0x14(%eax),%edx
80105505:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010550b:	39 c2                	cmp    %eax,%edx
8010550d:	75 0e                	jne    8010551d <wait+0x1a2>
	    found = 1;
8010550f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	    havekids = 1;
80105516:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	   }
	   p = p -> next;
8010551d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105520:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105526:	89 45 f4             	mov    %eax,-0xc(%ebp)
      p = p -> next;
    }
    if(!found){
      for(int i = 0; i < MAX+1; ++i){	
	p = ptable.pLists.ready[i];	//Change to priority queue
	while(p && !found){
80105529:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010552d:	74 06                	je     80105535 <wait+0x1ba>
8010552f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105533:	74 ca                	je     801054ff <wait+0x184>
	havekids = 1;
      }
      p = p -> next;
    }
    if(!found){
      for(int i = 0; i < MAX+1; ++i){	
80105535:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80105539:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
8010553d:	7e ac                	jle    801054eb <wait+0x170>
	   }
	   p = p -> next;
	}
      }
     }
     if(!found){
8010553f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105543:	75 40                	jne    80105585 <wait+0x20a>
	 p = ptable.pLists.sleep;
80105545:	a1 cc 80 11 80       	mov    0x801180cc,%eax
8010554a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	 while(p && !found){
8010554d:	eb 2a                	jmp    80105579 <wait+0x1fe>
	   if(p->parent == proc){
8010554f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105552:	8b 50 14             	mov    0x14(%eax),%edx
80105555:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010555b:	39 c2                	cmp    %eax,%edx
8010555d:	75 0e                	jne    8010556d <wait+0x1f2>
	     found = 1;
8010555f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	     havekids = 1;
80105566:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	   }
	   p = p -> next;
8010556d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105570:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105576:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
      }
     }
     if(!found){
	 p = ptable.pLists.sleep;
	 while(p && !found){
80105579:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010557d:	74 06                	je     80105585 <wait+0x20a>
8010557f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105583:	74 ca                	je     8010554f <wait+0x1d4>
	 }
     }


    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105585:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105589:	74 0d                	je     80105598 <wait+0x21d>
8010558b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105591:	8b 40 24             	mov    0x24(%eax),%eax
80105594:	85 c0                	test   %eax,%eax
80105596:	74 17                	je     801055af <wait+0x234>
      release(&ptable.lock);
80105598:	83 ec 0c             	sub    $0xc,%esp
8010559b:	68 80 59 11 80       	push   $0x80115980
801055a0:	e8 10 18 00 00       	call   80106db5 <release>
801055a5:	83 c4 10             	add    $0x10,%esp
      return -1;
801055a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ad:	eb 1c                	jmp    801055cb <wait+0x250>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801055af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b5:	83 ec 08             	sub    $0x8,%esp
801055b8:	68 80 59 11 80       	push   $0x80115980
801055bd:	50                   	push   %eax
801055be:	e8 76 04 00 00       	call   80105a39 <sleep>
801055c3:	83 c4 10             	add    $0x10,%esp
  }
801055c6:	e9 c6 fd ff ff       	jmp    80105391 <wait+0x16>

}
801055cb:	c9                   	leave  
801055cc:	c3                   	ret    

801055cd <scheduler>:
}

#else
void
scheduler(void)
{
801055cd:	55                   	push   %ebp
801055ce:	89 e5                	mov    %esp,%ebp
801055d0:	83 ec 18             	sub    $0x18,%esp
    struct proc *p;
      int idle;  // for checking if processor is idle
      for(;;){
	// Enable interrupts on this processor.
	sti();
801055d3:	e8 d7 f1 ff ff       	call   801047af <sti>

	idle = 1;  // assume idle unless we schedule a process
801055d8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)

	acquire(&ptable.lock);
801055df:	83 ec 0c             	sub    $0xc,%esp
801055e2:	68 80 59 11 80       	push   $0x80115980
801055e7:	e8 62 17 00 00       	call   80106d4e <acquire>
801055ec:	83 c4 10             	add    $0x10,%esp

	  if(ticks >= ptable.PromoteAtTime){
801055ef:	8b 15 dc 80 11 80    	mov    0x801180dc,%edx
801055f5:	a1 e0 88 11 80       	mov    0x801188e0,%eax
801055fa:	39 c2                	cmp    %eax,%edx
801055fc:	0f 87 2c 01 00 00    	ja     8010572e <scheduler+0x161>
	      for(int i = 1; i < MAX+1; ++i){
80105602:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
80105609:	e9 8b 00 00 00       	jmp    80105699 <scheduler+0xcc>
		 do{ 
		      p = ptable.pLists.ready[i];
8010560e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105611:	05 cc 09 00 00       	add    $0x9cc,%eax
80105616:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
8010561d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		      if(p){
80105620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105624:	74 65                	je     8010568b <scheduler+0xbe>
			  removeFromStateList(&ptable.pLists.ready[p -> priority], p);
80105626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105629:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010562f:	05 cc 09 00 00       	add    $0x9cc,%eax
80105634:	c1 e0 02             	shl    $0x2,%eax
80105637:	05 80 59 11 80       	add    $0x80115980,%eax
8010563c:	83 c0 04             	add    $0x4,%eax
8010563f:	83 ec 08             	sub    $0x8,%esp
80105642:	ff 75 f4             	pushl  -0xc(%ebp)
80105645:	50                   	push   %eax
80105646:	e8 18 f3 ff ff       	call   80104963 <removeFromStateList>
8010564b:	83 c4 10             	add    $0x10,%esp
			  --(p -> priority);
8010564e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105651:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105657:	8d 50 ff             	lea    -0x1(%eax),%edx
8010565a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565d:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
80105663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105666:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010566c:	05 cc 09 00 00       	add    $0x9cc,%eax
80105671:	c1 e0 02             	shl    $0x2,%eax
80105674:	05 80 59 11 80       	add    $0x80115980,%eax
80105679:	83 c0 04             	add    $0x4,%eax
8010567c:	83 ec 08             	sub    $0x8,%esp
8010567f:	ff 75 f4             	pushl  -0xc(%ebp)
80105682:	50                   	push   %eax
80105683:	e8 f3 f1 ff ff       	call   8010487b <addToStateListEnd>
80105688:	83 c4 10             	add    $0x10,%esp
		      }
		  }while(p);
8010568b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010568f:	0f 85 79 ff ff ff    	jne    8010560e <scheduler+0x41>
	idle = 1;  // assume idle unless we schedule a process

	acquire(&ptable.lock);

	  if(ticks >= ptable.PromoteAtTime){
	      for(int i = 1; i < MAX+1; ++i){
80105695:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105699:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010569d:	0f 8e 6b ff ff ff    	jle    8010560e <scheduler+0x41>
			  --(p -> priority);
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
		      }
		  }while(p);
	      }
	      p = ptable.pLists.sleep;
801056a3:	a1 cc 80 11 80       	mov    0x801180cc,%eax
801056a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      while(p){
801056ab:	eb 2e                	jmp    801056db <scheduler+0x10e>
		  if(p -> priority > 0)
801056ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b0:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801056b6:	85 c0                	test   %eax,%eax
801056b8:	74 15                	je     801056cf <scheduler+0x102>
		    --(p -> priority);
801056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bd:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801056c3:	8d 50 ff             	lea    -0x1(%eax),%edx
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		  p = p -> next;
801056cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801056d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
			  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);
		      }
		  }while(p);
	      }
	      p = ptable.pLists.sleep;
	      while(p){
801056db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056df:	75 cc                	jne    801056ad <scheduler+0xe0>
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }
	      p = ptable.pLists.running;
801056e1:	a1 d4 80 11 80       	mov    0x801180d4,%eax
801056e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      while(p){
801056e9:	eb 2e                	jmp    80105719 <scheduler+0x14c>
		  if(p -> priority > 0)
801056eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ee:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801056f4:	85 c0                	test   %eax,%eax
801056f6:	74 15                	je     8010570d <scheduler+0x140>
		    --(p -> priority);
801056f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fb:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105701:	8d 50 ff             	lea    -0x1(%eax),%edx
80105704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105707:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		  p = p -> next;
8010570d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105710:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105716:	89 45 f4             	mov    %eax,-0xc(%ebp)
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }
	      p = ptable.pLists.running;
	      while(p){
80105719:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010571d:	75 cc                	jne    801056eb <scheduler+0x11e>
		  if(p -> priority > 0)
		    --(p -> priority);
		  p = p -> next;
	      }

	      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
8010571f:	a1 e0 88 11 80       	mov    0x801188e0,%eax
80105724:	05 88 13 00 00       	add    $0x1388,%eax
80105729:	a3 dc 80 11 80       	mov    %eax,0x801180dc
	  }
	for(int i = 0; i < MAX+1; ++i){
8010572e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105735:	eb 1c                	jmp    80105753 <scheduler+0x186>
	    p = ptable.pLists.ready[i];
80105737:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010573a:	05 cc 09 00 00       	add    $0x9cc,%eax
8010573f:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
80105746:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    if(p){
80105749:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010574d:	75 0c                	jne    8010575b <scheduler+0x18e>
		  p = p -> next;
	      }

	      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
	  }
	for(int i = 0; i < MAX+1; ++i){
8010574f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105753:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80105757:	7e de                	jle    80105737 <scheduler+0x16a>
80105759:	eb 01                	jmp    8010575c <scheduler+0x18f>
	    p = ptable.pLists.ready[i];
	    if(p){
		break;
8010575b:	90                   	nop
	    }
	}

	if(p){		      
8010575c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105760:	0f 84 9d 00 00 00    	je     80105803 <scheduler+0x236>
	  assertStateReady(p);
80105766:	83 ec 0c             	sub    $0xc,%esp
80105769:	ff 75 f4             	pushl  -0xc(%ebp)
8010576c:	e8 e9 f0 ff ff       	call   8010485a <assertStateReady>
80105771:	83 c4 10             	add    $0x10,%esp

	  removeFromStateListHead(&ptable.pLists.ready[p -> priority], p);
80105774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105777:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010577d:	05 cc 09 00 00       	add    $0x9cc,%eax
80105782:	c1 e0 02             	shl    $0x2,%eax
80105785:	05 80 59 11 80       	add    $0x80115980,%eax
8010578a:	83 c0 04             	add    $0x4,%eax
8010578d:	83 ec 08             	sub    $0x8,%esp
80105790:	ff 75 f4             	pushl  -0xc(%ebp)
80105793:	50                   	push   %eax
80105794:	e8 6c f1 ff ff       	call   80104905 <removeFromStateListHead>
80105799:	83 c4 10             	add    $0x10,%esp
	  idle = 0;  // not idle this timeslice
8010579c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	  proc = p;
801057a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a6:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
801057ac:	83 ec 0c             	sub    $0xc,%esp
801057af:	ff 75 f4             	pushl  -0xc(%ebp)
801057b2:	e8 34 47 00 00       	call   80109eeb <switchuvm>
801057b7:	83 c4 10             	add    $0x10,%esp

	  proc -> state = RUNNING;
801057ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c0:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  addToStateListEnd(&ptable.pLists.running, proc);
801057c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057cd:	83 ec 08             	sub    $0x8,%esp
801057d0:	50                   	push   %eax
801057d1:	68 d4 80 11 80       	push   $0x801180d4
801057d6:	e8 a0 f0 ff ff       	call   8010487b <addToStateListEnd>
801057db:	83 c4 10             	add    $0x10,%esp
	  swtch(&cpu->scheduler, proc->context);
801057de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e4:	8b 40 1c             	mov    0x1c(%eax),%eax
801057e7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801057ee:	83 c2 04             	add    $0x4,%edx
801057f1:	83 ec 08             	sub    $0x8,%esp
801057f4:	50                   	push   %eax
801057f5:	52                   	push   %edx
801057f6:	e8 2a 1a 00 00       	call   80107225 <swtch>
801057fb:	83 c4 10             	add    $0x10,%esp
	  switchkvm();
801057fe:	e8 cb 46 00 00       	call   80109ece <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.

	  
	}
	proc = 0;
80105803:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010580a:	00 00 00 00 

	release(&ptable.lock);
8010580e:	83 ec 0c             	sub    $0xc,%esp
80105811:	68 80 59 11 80       	push   $0x80115980
80105816:	e8 9a 15 00 00       	call   80106db5 <release>
8010581b:	83 c4 10             	add    $0x10,%esp
      }
8010581e:	e9 b0 fd ff ff       	jmp    801055d3 <scheduler+0x6>

80105823 <sched>:

}
#else
void
sched(void)
{
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	83 ec 18             	sub    $0x18,%esp
    int intena;

  if(!holding(&ptable.lock))
80105829:	83 ec 0c             	sub    $0xc,%esp
8010582c:	68 80 59 11 80       	push   $0x80115980
80105831:	e8 4b 16 00 00       	call   80106e81 <holding>
80105836:	83 c4 10             	add    $0x10,%esp
80105839:	85 c0                	test   %eax,%eax
8010583b:	75 0d                	jne    8010584a <sched+0x27>
    panic("sched ptable.lock");
8010583d:	83 ec 0c             	sub    $0xc,%esp
80105840:	68 9d aa 10 80       	push   $0x8010aa9d
80105845:	e8 1c ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010584a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105850:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105856:	83 f8 01             	cmp    $0x1,%eax
80105859:	74 0d                	je     80105868 <sched+0x45>
    panic("sched locks");
8010585b:	83 ec 0c             	sub    $0xc,%esp
8010585e:	68 af aa 10 80       	push   $0x8010aaaf
80105863:	e8 fe ac ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105868:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010586e:	8b 40 0c             	mov    0xc(%eax),%eax
80105871:	83 f8 04             	cmp    $0x4,%eax
80105874:	75 0d                	jne    80105883 <sched+0x60>
    panic("sched running");
80105876:	83 ec 0c             	sub    $0xc,%esp
80105879:	68 bb aa 10 80       	push   $0x8010aabb
8010587e:	e8 e3 ac ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105883:	e8 17 ef ff ff       	call   8010479f <readeflags>
80105888:	25 00 02 00 00       	and    $0x200,%eax
8010588d:	85 c0                	test   %eax,%eax
8010588f:	74 0d                	je     8010589e <sched+0x7b>
    panic("sched interruptible");
80105891:	83 ec 0c             	sub    $0xc,%esp
80105894:	68 c9 aa 10 80       	push   $0x8010aac9
80105899:	e8 c8 ac ff ff       	call   80100566 <panic>
  intena = cpu->intena;
8010589e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801058a4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801058aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //cprintf("Descheduled a process\n");
  swtch(&proc->context, cpu->scheduler);
801058ad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801058b3:	8b 40 04             	mov    0x4(%eax),%eax
801058b6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801058bd:	83 c2 1c             	add    $0x1c,%edx
801058c0:	83 ec 08             	sub    $0x8,%esp
801058c3:	50                   	push   %eax
801058c4:	52                   	push   %edx
801058c5:	e8 5b 19 00 00       	call   80107225 <swtch>
801058ca:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801058cd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801058d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058d6:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
801058dc:	90                   	nop
801058dd:	c9                   	leave  
801058de:	c3                   	ret    

801058df <yield>:

#else
// Give up the CPU for one scheduling round.
void
yield(void)
{
801058df:	55                   	push   %ebp
801058e0:	89 e5                	mov    %esp,%ebp
801058e2:	53                   	push   %ebx
801058e3:	83 ec 04             	sub    $0x4,%esp
  //struct proc* p = proc;  
  acquire(&ptable.lock);  //DOC: yieldlock
801058e6:	83 ec 0c             	sub    $0xc,%esp
801058e9:	68 80 59 11 80       	push   $0x80115980
801058ee:	e8 5b 14 00 00       	call   80106d4e <acquire>
801058f3:	83 c4 10             	add    $0x10,%esp

  assertStateRunning(proc);
801058f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058fc:	83 ec 0c             	sub    $0xc,%esp
801058ff:	50                   	push   %eax
80105900:	e8 13 ef ff ff       	call   80104818 <assertStateRunning>
80105905:	83 c4 10             	add    $0x10,%esp
  proc -> budget = proc -> budget - (ticks - proc -> cpu_ticks_in);
80105908:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010590e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105915:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
8010591b:	89 d3                	mov    %edx,%ebx
8010591d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105924:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
8010592a:	8b 15 e0 88 11 80    	mov    0x801188e0,%edx
80105930:	29 d1                	sub    %edx,%ecx
80105932:	89 ca                	mov    %ecx,%edx
80105934:	01 da                	add    %ebx,%edx
80105936:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)

  if(proc -> budget <= 0){
8010593c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105942:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105948:	85 c0                	test   %eax,%eax
8010594a:	7f 36                	jg     80105982 <yield+0xa3>
      if(proc -> priority < MAX)
8010594c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105952:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105958:	83 f8 03             	cmp    $0x3,%eax
8010595b:	77 15                	ja     80105972 <yield+0x93>
	++(proc -> priority);
8010595d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105963:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105969:	83 c2 01             	add    $0x1,%edx
8010596c:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    proc -> budget = BUDGET;
80105972:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105978:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
8010597f:	13 00 00 
  }

  removeFromStateList(&ptable.pLists.running, proc);
80105982:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105988:	83 ec 08             	sub    $0x8,%esp
8010598b:	50                   	push   %eax
8010598c:	68 d4 80 11 80       	push   $0x801180d4
80105991:	e8 cd ef ff ff       	call   80104963 <removeFromStateList>
80105996:	83 c4 10             	add    $0x10,%esp
  
  proc->state = RUNNABLE;
80105999:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  addToStateListEnd(&ptable.pLists.ready[proc -> priority], proc);	//Change to priority queue
801059a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ac:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801059b3:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
801059b9:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
801059bf:	c1 e2 02             	shl    $0x2,%edx
801059c2:	81 c2 80 59 11 80    	add    $0x80115980,%edx
801059c8:	83 c2 04             	add    $0x4,%edx
801059cb:	83 ec 08             	sub    $0x8,%esp
801059ce:	50                   	push   %eax
801059cf:	52                   	push   %edx
801059d0:	e8 a6 ee ff ff       	call   8010487b <addToStateListEnd>
801059d5:	83 c4 10             	add    $0x10,%esp


  sched();
801059d8:	e8 46 fe ff ff       	call   80105823 <sched>
  release(&ptable.lock);
801059dd:	83 ec 0c             	sub    $0xc,%esp
801059e0:	68 80 59 11 80       	push   $0x80115980
801059e5:	e8 cb 13 00 00       	call   80106db5 <release>
801059ea:	83 c4 10             	add    $0x10,%esp

}
801059ed:	90                   	nop
801059ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801059f1:	c9                   	leave  
801059f2:	c3                   	ret    

801059f3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801059f3:	55                   	push   %ebp
801059f4:	89 e5                	mov    %esp,%ebp
801059f6:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801059f9:	83 ec 0c             	sub    $0xc,%esp
801059fc:	68 80 59 11 80       	push   $0x80115980
80105a01:	e8 af 13 00 00       	call   80106db5 <release>
80105a06:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105a09:	a1 20 e0 10 80       	mov    0x8010e020,%eax
80105a0e:	85 c0                	test   %eax,%eax
80105a10:	74 24                	je     80105a36 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105a12:	c7 05 20 e0 10 80 00 	movl   $0x0,0x8010e020
80105a19:	00 00 00 
    iinit(ROOTDEV);
80105a1c:	83 ec 0c             	sub    $0xc,%esp
80105a1f:	6a 01                	push   $0x1
80105a21:	e8 44 bd ff ff       	call   8010176a <iinit>
80105a26:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105a29:	83 ec 0c             	sub    $0xc,%esp
80105a2c:	6a 01                	push   $0x1
80105a2e:	e8 5d dc ff ff       	call   80103690 <initlog>
80105a33:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105a36:	90                   	nop
80105a37:	c9                   	leave  
80105a38:	c3                   	ret    

80105a39 <sleep>:

#else

void
sleep(void *chan, struct spinlock *lk)
{
80105a39:	55                   	push   %ebp
80105a3a:	89 e5                	mov    %esp,%ebp
80105a3c:	53                   	push   %ebx
80105a3d:	83 ec 04             	sub    $0x4,%esp
  if(proc == 0)
80105a40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a46:	85 c0                	test   %eax,%eax
80105a48:	75 0d                	jne    80105a57 <sleep+0x1e>
    panic("sleep");
80105a4a:	83 ec 0c             	sub    $0xc,%esp
80105a4d:	68 dd aa 10 80       	push   $0x8010aadd
80105a52:	e8 0f ab ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80105a57:	81 7d 0c 80 59 11 80 	cmpl   $0x80115980,0xc(%ebp)
80105a5e:	74 24                	je     80105a84 <sleep+0x4b>
    acquire(&ptable.lock);
80105a60:	83 ec 0c             	sub    $0xc,%esp
80105a63:	68 80 59 11 80       	push   $0x80115980
80105a68:	e8 e1 12 00 00       	call   80106d4e <acquire>
80105a6d:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80105a70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a74:	74 0e                	je     80105a84 <sleep+0x4b>
80105a76:	83 ec 0c             	sub    $0xc,%esp
80105a79:	ff 75 0c             	pushl  0xc(%ebp)
80105a7c:	e8 34 13 00 00       	call   80106db5 <release>
80105a81:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105a84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a8a:	8b 55 08             	mov    0x8(%ebp),%edx
80105a8d:	89 50 20             	mov    %edx,0x20(%eax)
  //struct proc *p = proc;
  assertStateRunning(proc);
80105a90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a96:	83 ec 0c             	sub    $0xc,%esp
80105a99:	50                   	push   %eax
80105a9a:	e8 79 ed ff ff       	call   80104818 <assertStateRunning>
80105a9f:	83 c4 10             	add    $0x10,%esp

  removeFromStateList(&ptable.pLists.running, proc);
80105aa2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aa8:	83 ec 08             	sub    $0x8,%esp
80105aab:	50                   	push   %eax
80105aac:	68 d4 80 11 80       	push   $0x801180d4
80105ab1:	e8 ad ee ff ff       	call   80104963 <removeFromStateList>
80105ab6:	83 c4 10             	add    $0x10,%esp
  proc -> state = SLEEPING;
80105ab9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105abf:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  assertStateSleep(proc);
80105ac6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105acc:	83 ec 0c             	sub    $0xc,%esp
80105acf:	50                   	push   %eax
80105ad0:	e8 64 ed ff ff       	call   80104839 <assertStateSleep>
80105ad5:	83 c4 10             	add    $0x10,%esp
  addToStateListEnd(&ptable.pLists.sleep, proc);
80105ad8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ade:	83 ec 08             	sub    $0x8,%esp
80105ae1:	50                   	push   %eax
80105ae2:	68 cc 80 11 80       	push   $0x801180cc
80105ae7:	e8 8f ed ff ff       	call   8010487b <addToStateListEnd>
80105aec:	83 c4 10             	add    $0x10,%esp
  proc -> budget = proc -> budget - (ticks - proc -> cpu_ticks_in);
80105aef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105af5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105afc:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105b02:	89 d3                	mov    %edx,%ebx
80105b04:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105b0b:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
80105b11:	8b 15 e0 88 11 80    	mov    0x801188e0,%edx
80105b17:	29 d1                	sub    %edx,%ecx
80105b19:	89 ca                	mov    %ecx,%edx
80105b1b:	01 da                	add    %ebx,%edx
80105b1d:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc -> budget <= 0){
80105b23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b29:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105b2f:	85 c0                	test   %eax,%eax
80105b31:	7f 36                	jg     80105b69 <sleep+0x130>
      if(proc -> priority < MAX)
80105b33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b39:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105b3f:	83 f8 03             	cmp    $0x3,%eax
80105b42:	77 15                	ja     80105b59 <sleep+0x120>
	++(proc -> priority);
80105b44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b4a:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105b50:	83 c2 01             	add    $0x1,%edx
80105b53:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    proc -> budget = BUDGET;
80105b59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b5f:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80105b66:	13 00 00 
  }
  sched();
80105b69:	e8 b5 fc ff ff       	call   80105823 <sched>

  // Tidy up.
  proc->chan = 0;
80105b6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b74:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
80105b7b:	81 7d 0c 80 59 11 80 	cmpl   $0x80115980,0xc(%ebp)
80105b82:	74 24                	je     80105ba8 <sleep+0x16f>
    release(&ptable.lock);
80105b84:	83 ec 0c             	sub    $0xc,%esp
80105b87:	68 80 59 11 80       	push   $0x80115980
80105b8c:	e8 24 12 00 00       	call   80106db5 <release>
80105b91:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105b94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b98:	74 0e                	je     80105ba8 <sleep+0x16f>
80105b9a:	83 ec 0c             	sub    $0xc,%esp
80105b9d:	ff 75 0c             	pushl  0xc(%ebp)
80105ba0:	e8 a9 11 00 00       	call   80106d4e <acquire>
80105ba5:	83 c4 10             	add    $0x10,%esp
  }
}
80105ba8:	90                   	nop
80105ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105bac:	c9                   	leave  
80105bad:	c3                   	ret    

80105bae <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
80105bae:	55                   	push   %ebp
80105baf:	89 e5                	mov    %esp,%ebp
80105bb1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  struct proc *sleeper = ptable.pLists.sleep;
80105bb4:	a1 cc 80 11 80       	mov    0x801180cc,%eax
80105bb9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(sleeper){
80105bbc:	eb 7e                	jmp    80105c3c <wakeup1+0x8e>
    if(sleeper -> chan == chan){
80105bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc1:	8b 40 20             	mov    0x20(%eax),%eax
80105bc4:	3b 45 08             	cmp    0x8(%ebp),%eax
80105bc7:	75 67                	jne    80105c30 <wakeup1+0x82>
      p = sleeper;
80105bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      sleeper = sleeper -> next;
80105bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      assertStateSleep(p);
80105bdb:	83 ec 0c             	sub    $0xc,%esp
80105bde:	ff 75 f0             	pushl  -0x10(%ebp)
80105be1:	e8 53 ec ff ff       	call   80104839 <assertStateSleep>
80105be6:	83 c4 10             	add    $0x10,%esp
      removeFromStateList(&ptable.pLists.sleep, p);
80105be9:	83 ec 08             	sub    $0x8,%esp
80105bec:	ff 75 f0             	pushl  -0x10(%ebp)
80105bef:	68 cc 80 11 80       	push   $0x801180cc
80105bf4:	e8 6a ed ff ff       	call   80104963 <removeFromStateList>
80105bf9:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNABLE;
80105bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      addToStateListEnd(&ptable.pLists.ready[p -> priority], p);	//Change to priority queue
80105c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c09:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105c0f:	05 cc 09 00 00       	add    $0x9cc,%eax
80105c14:	c1 e0 02             	shl    $0x2,%eax
80105c17:	05 80 59 11 80       	add    $0x80115980,%eax
80105c1c:	83 c0 04             	add    $0x4,%eax
80105c1f:	83 ec 08             	sub    $0x8,%esp
80105c22:	ff 75 f0             	pushl  -0x10(%ebp)
80105c25:	50                   	push   %eax
80105c26:	e8 50 ec ff ff       	call   8010487b <addToStateListEnd>
80105c2b:	83 c4 10             	add    $0x10,%esp
80105c2e:	eb 0c                	jmp    80105c3c <wakeup1+0x8e>

    }
    else
      sleeper = sleeper -> next;
80105c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c33:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *p;

  struct proc *sleeper = ptable.pLists.sleep;

  while(sleeper){
80105c3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c40:	0f 85 78 ff ff ff    	jne    80105bbe <wakeup1+0x10>
    }
    else
      sleeper = sleeper -> next;
  }
  
}
80105c46:	90                   	nop
80105c47:	c9                   	leave  
80105c48:	c3                   	ret    

80105c49 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105c49:	55                   	push   %ebp
80105c4a:	89 e5                	mov    %esp,%ebp
80105c4c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105c4f:	83 ec 0c             	sub    $0xc,%esp
80105c52:	68 80 59 11 80       	push   $0x80115980
80105c57:	e8 f2 10 00 00       	call   80106d4e <acquire>
80105c5c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105c5f:	83 ec 0c             	sub    $0xc,%esp
80105c62:	ff 75 08             	pushl  0x8(%ebp)
80105c65:	e8 44 ff ff ff       	call   80105bae <wakeup1>
80105c6a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105c6d:	83 ec 0c             	sub    $0xc,%esp
80105c70:	68 80 59 11 80       	push   $0x80115980
80105c75:	e8 3b 11 00 00       	call   80106db5 <release>
80105c7a:	83 c4 10             	add    $0x10,%esp
}
80105c7d:	90                   	nop
80105c7e:	c9                   	leave  
80105c7f:	c3                   	ret    

80105c80 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105c80:	55                   	push   %ebp
80105c81:	89 e5                	mov    %esp,%ebp
80105c83:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int found = 0;
80105c86:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  acquire(&ptable.lock);
80105c8d:	83 ec 0c             	sub    $0xc,%esp
80105c90:	68 80 59 11 80       	push   $0x80115980
80105c95:	e8 b4 10 00 00       	call   80106d4e <acquire>
80105c9a:	83 c4 10             	add    $0x10,%esp
  while(!found){
80105c9d:	e9 dc 01 00 00       	jmp    80105e7e <kill+0x1fe>

    for(int i = 0; i < MAX+1; ++i){
80105ca2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105ca9:	eb 68                	jmp    80105d13 <kill+0x93>
	p = ptable.pLists.ready[i];		//Change to priority queue
80105cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cae:	05 cc 09 00 00       	add    $0x9cc,%eax
80105cb3:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
80105cba:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while(p && !found){
80105cbd:	eb 44                	jmp    80105d03 <kill+0x83>
	    if(p->pid == pid){
80105cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc2:	8b 50 10             	mov    0x10(%eax),%edx
80105cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc8:	39 c2                	cmp    %eax,%edx
80105cca:	75 2b                	jne    80105cf7 <kill+0x77>
	      found = 1;
80105ccc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	      p->killed = 1;
80105cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	      release(&ptable.lock);
80105cdd:	83 ec 0c             	sub    $0xc,%esp
80105ce0:	68 80 59 11 80       	push   $0x80115980
80105ce5:	e8 cb 10 00 00       	call   80106db5 <release>
80105cea:	83 c4 10             	add    $0x10,%esp
	      return 0;
80105ced:	b8 00 00 00 00       	mov    $0x0,%eax
80105cf2:	e9 a6 01 00 00       	jmp    80105e9d <kill+0x21d>
	    }

	    p = p -> next;
80105cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfa:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(!found){

    for(int i = 0; i < MAX+1; ++i){
	p = ptable.pLists.ready[i];		//Change to priority queue

	while(p && !found){
80105d03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d07:	74 06                	je     80105d0f <kill+0x8f>
80105d09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d0d:	74 b0                	je     80105cbf <kill+0x3f>
  struct proc *p;
  int found = 0;
  acquire(&ptable.lock);
  while(!found){

    for(int i = 0; i < MAX+1; ++i){
80105d0f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105d13:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80105d17:	7e 92                	jle    80105cab <kill+0x2b>

	    p = p -> next;
	}
    }

    p = ptable.pLists.running;
80105d19:	a1 d4 80 11 80       	mov    0x801180d4,%eax
80105d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105d21:	eb 44                	jmp    80105d67 <kill+0xe7>
	if(p->pid == pid){
80105d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d26:	8b 50 10             	mov    0x10(%eax),%edx
80105d29:	8b 45 08             	mov    0x8(%ebp),%eax
80105d2c:	39 c2                	cmp    %eax,%edx
80105d2e:	75 2b                	jne    80105d5b <kill+0xdb>
	  found = 1;
80105d30:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	  release(&ptable.lock);
80105d41:	83 ec 0c             	sub    $0xc,%esp
80105d44:	68 80 59 11 80       	push   $0x80115980
80105d49:	e8 67 10 00 00       	call   80106db5 <release>
80105d4e:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105d51:	b8 00 00 00 00       	mov    $0x0,%eax
80105d56:	e9 42 01 00 00       	jmp    80105e9d <kill+0x21d>
	}
	p = p -> next;
80105d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    p = p -> next;
	}
    }

    p = ptable.pLists.running;
    while(p && !found){
80105d67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d6b:	74 06                	je     80105d73 <kill+0xf3>
80105d6d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d71:	74 b0                	je     80105d23 <kill+0xa3>
	  return 0;
	}
	p = p -> next;
    }

    p = ptable.pLists.embryo;
80105d73:	a1 d8 80 11 80       	mov    0x801180d8,%eax
80105d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105d7b:	eb 44                	jmp    80105dc1 <kill+0x141>
	if(p->pid == pid){
80105d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d80:	8b 50 10             	mov    0x10(%eax),%edx
80105d83:	8b 45 08             	mov    0x8(%ebp),%eax
80105d86:	39 c2                	cmp    %eax,%edx
80105d88:	75 2b                	jne    80105db5 <kill+0x135>
	  found = 1;
80105d8a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d94:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
          release(&ptable.lock);
80105d9b:	83 ec 0c             	sub    $0xc,%esp
80105d9e:	68 80 59 11 80       	push   $0x80115980
80105da3:	e8 0d 10 00 00       	call   80106db5 <release>
80105da8:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105dab:	b8 00 00 00 00       	mov    $0x0,%eax
80105db0:	e9 e8 00 00 00       	jmp    80105e9d <kill+0x21d>
	}
	p = p -> next;
80105db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	p = p -> next;
    }

    p = ptable.pLists.embryo;
    while(p && !found){
80105dc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc5:	74 06                	je     80105dcd <kill+0x14d>
80105dc7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105dcb:	74 b0                	je     80105d7d <kill+0xfd>
	  return 0;
	}
	p = p -> next;
    }

    p = ptable.pLists.sleep;
80105dcd:	a1 cc 80 11 80       	mov    0x801180cc,%eax
80105dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p && !found){
80105dd5:	e9 94 00 00 00       	jmp    80105e6e <kill+0x1ee>
	if(p->pid == pid){
80105dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddd:	8b 50 10             	mov    0x10(%eax),%edx
80105de0:	8b 45 08             	mov    0x8(%ebp),%eax
80105de3:	39 c2                	cmp    %eax,%edx
80105de5:	75 7b                	jne    80105e62 <kill+0x1e2>
	  found = 1;
80105de7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
	  p->killed = 1;
80105dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	  assertStateSleep(p);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfe:	e8 36 ea ff ff       	call   80104839 <assertStateSleep>
80105e03:	83 c4 10             	add    $0x10,%esp
	  removeFromStateList(&ptable.pLists.sleep, p);
80105e06:	83 ec 08             	sub    $0x8,%esp
80105e09:	ff 75 f4             	pushl  -0xc(%ebp)
80105e0c:	68 cc 80 11 80       	push   $0x801180cc
80105e11:	e8 4d eb ff ff       	call   80104963 <removeFromStateList>
80105e16:	83 c4 10             	add    $0x10,%esp
	  p->state = RUNNABLE;
80105e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	  addToStateListEnd(&ptable.pLists.ready[p -> priority], p);	//Change to priority queue
80105e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e26:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105e2c:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e31:	c1 e0 02             	shl    $0x2,%eax
80105e34:	05 80 59 11 80       	add    $0x80115980,%eax
80105e39:	83 c0 04             	add    $0x4,%eax
80105e3c:	83 ec 08             	sub    $0x8,%esp
80105e3f:	ff 75 f4             	pushl  -0xc(%ebp)
80105e42:	50                   	push   %eax
80105e43:	e8 33 ea ff ff       	call   8010487b <addToStateListEnd>
80105e48:	83 c4 10             	add    $0x10,%esp

	  release(&ptable.lock);
80105e4b:	83 ec 0c             	sub    $0xc,%esp
80105e4e:	68 80 59 11 80       	push   $0x80115980
80105e53:	e8 5d 0f 00 00       	call   80106db5 <release>
80105e58:	83 c4 10             	add    $0x10,%esp
	  return 0;
80105e5b:	b8 00 00 00 00       	mov    $0x0,%eax
80105e60:	eb 3b                	jmp    80105e9d <kill+0x21d>

	}
	p = p -> next;
80105e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e65:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	p = p -> next;
    }

    p = ptable.pLists.sleep;
    while(p && !found){
80105e6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e72:	74 0a                	je     80105e7e <kill+0x1fe>
80105e74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e78:	0f 84 5c ff ff ff    	je     80105dda <kill+0x15a>
kill(int pid)
{
  struct proc *p;
  int found = 0;
  acquire(&ptable.lock);
  while(!found){
80105e7e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e82:	0f 84 1a fe ff ff    	je     80105ca2 <kill+0x22>
	}
	p = p -> next;
    }
  }

  release(&ptable.lock);
80105e88:	83 ec 0c             	sub    $0xc,%esp
80105e8b:	68 80 59 11 80       	push   $0x80115980
80105e90:	e8 20 0f 00 00       	call   80106db5 <release>
80105e95:	83 c4 10             	add    $0x10,%esp
  return -1;
80105e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  

}
80105e9d:	c9                   	leave  
80105e9e:	c3                   	ret    

80105e9f <procdump>:
    release(&ptable.lock);
}
#else
void
procdump(void)
{
80105e9f:	55                   	push   %ebp
80105ea0:	89 e5                	mov    %esp,%ebp
80105ea2:	57                   	push   %edi
80105ea3:	56                   	push   %esi
80105ea4:	53                   	push   %ebx
80105ea5:	83 ec 5c             	sub    $0x5c,%esp
  int i;
  struct proc *p;
  uint pc[10];
  
    cprintf("PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\t PCs\n");
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	68 10 ab 10 80       	push   $0x8010ab10
80105eb0:	e8 11 a5 ff ff       	call   801003c6 <cprintf>
80105eb5:	83 c4 10             	add    $0x10,%esp


    acquire(&ptable.lock);
80105eb8:	83 ec 0c             	sub    $0xc,%esp
80105ebb:	68 80 59 11 80       	push   $0x80115980
80105ec0:	e8 89 0e 00 00       	call   80106d4e <acquire>
80105ec5:	83 c4 10             	add    $0x10,%esp

    char *state = "???";
80105ec8:	c7 45 dc 48 ab 10 80 	movl   $0x8010ab48,-0x24(%ebp)
    while(0)
80105ecf:	90                   	nop
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105ed0:	c7 45 e0 b4 59 11 80 	movl   $0x801159b4,-0x20(%ebp)
80105ed7:	e9 7f 03 00 00       	jmp    8010625b <procdump+0x3bc>
    if(p->state == UNUSED)
80105edc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105edf:	8b 40 0c             	mov    0xc(%eax),%eax
80105ee2:	85 c0                	test   %eax,%eax
80105ee4:	0f 84 69 03 00 00    	je     80106253 <procdump+0x3b4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105eed:	8b 40 0c             	mov    0xc(%eax),%eax
80105ef0:	83 f8 05             	cmp    $0x5,%eax
80105ef3:	77 21                	ja     80105f16 <procdump+0x77>
80105ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ef8:	8b 40 0c             	mov    0xc(%eax),%eax
80105efb:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
80105f02:	85 c0                	test   %eax,%eax
80105f04:	74 10                	je     80105f16 <procdump+0x77>
      state = states[p->state];
80105f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f09:	8b 40 0c             	mov    0xc(%eax),%eax
80105f0c:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
80105f13:	89 45 dc             	mov    %eax,-0x24(%ebp)

    int  elapsed, milli, cpue, cpum;

    elapsed = (ticks - p -> start_ticks)/1000;
80105f16:	8b 15 e0 88 11 80    	mov    0x801188e0,%edx
80105f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f1f:	8b 40 7c             	mov    0x7c(%eax),%eax
80105f22:	29 c2                	sub    %eax,%edx
80105f24:	89 d0                	mov    %edx,%eax
80105f26:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105f2b:	f7 e2                	mul    %edx
80105f2d:	89 d0                	mov    %edx,%eax
80105f2f:	c1 e8 06             	shr    $0x6,%eax
80105f32:	89 45 d8             	mov    %eax,-0x28(%ebp)
    milli = (ticks - p -> start_ticks)%1000;
80105f35:	8b 15 e0 88 11 80    	mov    0x801188e0,%edx
80105f3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f3e:	8b 40 7c             	mov    0x7c(%eax),%eax
80105f41:	89 d1                	mov    %edx,%ecx
80105f43:	29 c1                	sub    %eax,%ecx
80105f45:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105f4a:	89 c8                	mov    %ecx,%eax
80105f4c:	f7 e2                	mul    %edx
80105f4e:	89 d0                	mov    %edx,%eax
80105f50:	c1 e8 06             	shr    $0x6,%eax
80105f53:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105f59:	29 c1                	sub    %eax,%ecx
80105f5b:	89 c8                	mov    %ecx,%eax
80105f5d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cpue = (p -> cpu_ticks_total)/1000;
80105f60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f63:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105f69:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105f6e:	f7 e2                	mul    %edx
80105f70:	89 d0                	mov    %edx,%eax
80105f72:	c1 e8 06             	shr    $0x6,%eax
80105f75:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cpum = (p -> cpu_ticks_total)%1000;
80105f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f7b:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80105f81:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105f86:	89 c8                	mov    %ecx,%eax
80105f88:	f7 e2                	mul    %edx
80105f8a:	89 d0                	mov    %edx,%eax
80105f8c:	c1 e8 06             	shr    $0x6,%eax
80105f8f:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105f95:	29 c1                	sub    %eax,%ecx
80105f97:	89 c8                	mov    %ecx,%eax
80105f99:	89 45 cc             	mov    %eax,-0x34(%ebp)

    if(p -> pid == 1){
80105f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f9f:	8b 40 10             	mov    0x10(%eax),%eax
80105fa2:	83 f8 01             	cmp    $0x1,%eax
80105fa5:	0f 85 1c 01 00 00    	jne    801060c7 <procdump+0x228>
	cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,1,p -> priority, elapsed);
80105fab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fae:	8b 98 94 00 00 00    	mov    0x94(%eax),%ebx
80105fb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fb7:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fc0:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fc9:	8d 70 6c             	lea    0x6c(%eax),%esi
80105fcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fcf:	8b 40 10             	mov    0x10(%eax),%eax
80105fd2:	ff 75 d8             	pushl  -0x28(%ebp)
80105fd5:	53                   	push   %ebx
80105fd6:	6a 01                	push   $0x1
80105fd8:	51                   	push   %ecx
80105fd9:	52                   	push   %edx
80105fda:	56                   	push   %esi
80105fdb:	50                   	push   %eax
80105fdc:	68 4c ab 10 80       	push   $0x8010ab4c
80105fe1:	e8 e0 a3 ff ff       	call   801003c6 <cprintf>
80105fe6:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
80105fe9:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80105fed:	7f 16                	jg     80106005 <procdump+0x166>
	    cprintf("00%d\t%d.", milli, cpue);
80105fef:	83 ec 04             	sub    $0x4,%esp
80105ff2:	ff 75 d0             	pushl  -0x30(%ebp)
80105ff5:	ff 75 d4             	pushl  -0x2c(%ebp)
80105ff8:	68 62 ab 10 80       	push   $0x8010ab62
80105ffd:	e8 c4 a3 ff ff       	call   801003c6 <cprintf>
80106002:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
80106005:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80106009:	7e 1c                	jle    80106027 <procdump+0x188>
8010600b:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
8010600f:	7f 16                	jg     80106027 <procdump+0x188>
	    cprintf("0%d\t%d.", milli, cpue);
80106011:	83 ec 04             	sub    $0x4,%esp
80106014:	ff 75 d0             	pushl  -0x30(%ebp)
80106017:	ff 75 d4             	pushl  -0x2c(%ebp)
8010601a:	68 6b ab 10 80       	push   $0x8010ab6b
8010601f:	e8 a2 a3 ff ff       	call   801003c6 <cprintf>
80106024:	83 c4 10             	add    $0x10,%esp
	if(milli > 100)
80106027:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
8010602b:	7e 16                	jle    80106043 <procdump+0x1a4>
	    cprintf("%d\t%d.", milli, cpue);
8010602d:	83 ec 04             	sub    $0x4,%esp
80106030:	ff 75 d0             	pushl  -0x30(%ebp)
80106033:	ff 75 d4             	pushl  -0x2c(%ebp)
80106036:	68 73 ab 10 80       	push   $0x8010ab73
8010603b:	e8 86 a3 ff ff       	call   801003c6 <cprintf>
80106040:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80106043:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80106047:	7f 21                	jg     8010606a <procdump+0x1cb>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80106049:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010604c:	8b 00                	mov    (%eax),%eax
8010604e:	83 ec 0c             	sub    $0xc,%esp
80106051:	68 7a ab 10 80       	push   $0x8010ab7a
80106056:	50                   	push   %eax
80106057:	ff 75 dc             	pushl  -0x24(%ebp)
8010605a:	ff 75 cc             	pushl  -0x34(%ebp)
8010605d:	68 7c ab 10 80       	push   $0x8010ab7c
80106062:	e8 5f a3 ff ff       	call   801003c6 <cprintf>
80106067:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
8010606a:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
8010606e:	7e 27                	jle    80106097 <procdump+0x1f8>
80106070:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
80106074:	7f 21                	jg     80106097 <procdump+0x1f8>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
80106076:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106079:	8b 00                	mov    (%eax),%eax
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	68 7a ab 10 80       	push   $0x8010ab7a
80106083:	50                   	push   %eax
80106084:	ff 75 dc             	pushl  -0x24(%ebp)
80106087:	ff 75 cc             	pushl  -0x34(%ebp)
8010608a:	68 88 ab 10 80       	push   $0x8010ab88
8010608f:	e8 32 a3 ff ff       	call   801003c6 <cprintf>
80106094:	83 c4 20             	add    $0x20,%esp
	if(cpum > 100)
80106097:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
8010609b:	0f 8e 41 01 00 00    	jle    801061e2 <procdump+0x343>
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
801060a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060a4:	8b 00                	mov    (%eax),%eax
801060a6:	83 ec 0c             	sub    $0xc,%esp
801060a9:	68 7a ab 10 80       	push   $0x8010ab7a
801060ae:	50                   	push   %eax
801060af:	ff 75 dc             	pushl  -0x24(%ebp)
801060b2:	ff 75 cc             	pushl  -0x34(%ebp)
801060b5:	68 93 ab 10 80       	push   $0x8010ab93
801060ba:	e8 07 a3 ff ff       	call   801003c6 <cprintf>
801060bf:	83 c4 20             	add    $0x20,%esp
801060c2:	e9 1b 01 00 00       	jmp    801061e2 <procdump+0x343>
    }
    else{
	cprintf("%d\t%s\t%d\t%d\t%d\t%d\t%d.", p -> pid, p -> name, p -> uid, p -> gid ,p -> parent -> pid, p -> priority, elapsed);
801060c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060ca:	8b b0 94 00 00 00    	mov    0x94(%eax),%esi
801060d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060d3:	8b 40 14             	mov    0x14(%eax),%eax
801060d6:	8b 58 10             	mov    0x10(%eax),%ebx
801060d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060dc:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
801060e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060e5:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801060eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060ee:	8d 78 6c             	lea    0x6c(%eax),%edi
801060f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060f4:	8b 40 10             	mov    0x10(%eax),%eax
801060f7:	ff 75 d8             	pushl  -0x28(%ebp)
801060fa:	56                   	push   %esi
801060fb:	53                   	push   %ebx
801060fc:	51                   	push   %ecx
801060fd:	52                   	push   %edx
801060fe:	57                   	push   %edi
801060ff:	50                   	push   %eax
80106100:	68 4c ab 10 80       	push   $0x8010ab4c
80106105:	e8 bc a2 ff ff       	call   801003c6 <cprintf>
8010610a:	83 c4 20             	add    $0x20,%esp
	if(milli < 10)
8010610d:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
80106111:	7f 16                	jg     80106129 <procdump+0x28a>
	    cprintf("00%d\t%d.", milli, cpue);
80106113:	83 ec 04             	sub    $0x4,%esp
80106116:	ff 75 d0             	pushl  -0x30(%ebp)
80106119:	ff 75 d4             	pushl  -0x2c(%ebp)
8010611c:	68 62 ab 10 80       	push   $0x8010ab62
80106121:	e8 a0 a2 ff ff       	call   801003c6 <cprintf>
80106126:	83 c4 10             	add    $0x10,%esp
	if(milli > 9 && milli < 100)
80106129:	83 7d d4 09          	cmpl   $0x9,-0x2c(%ebp)
8010612d:	7e 1c                	jle    8010614b <procdump+0x2ac>
8010612f:	83 7d d4 63          	cmpl   $0x63,-0x2c(%ebp)
80106133:	7f 16                	jg     8010614b <procdump+0x2ac>
	    cprintf("0%d\t%d.", milli, cpue);
80106135:	83 ec 04             	sub    $0x4,%esp
80106138:	ff 75 d0             	pushl  -0x30(%ebp)
8010613b:	ff 75 d4             	pushl  -0x2c(%ebp)
8010613e:	68 6b ab 10 80       	push   $0x8010ab6b
80106143:	e8 7e a2 ff ff       	call   801003c6 <cprintf>
80106148:	83 c4 10             	add    $0x10,%esp
	if(milli > 100)
8010614b:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
8010614f:	7e 16                	jle    80106167 <procdump+0x2c8>
	    cprintf("%d\t%d.", milli, cpue);
80106151:	83 ec 04             	sub    $0x4,%esp
80106154:	ff 75 d0             	pushl  -0x30(%ebp)
80106157:	ff 75 d4             	pushl  -0x2c(%ebp)
8010615a:	68 73 ab 10 80       	push   $0x8010ab73
8010615f:	e8 62 a2 ff ff       	call   801003c6 <cprintf>
80106164:	83 c4 10             	add    $0x10,%esp

	if(cpum < 10)
80106167:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
8010616b:	7f 21                	jg     8010618e <procdump+0x2ef>
	    cprintf("00%d\t%s\t%d\t", cpum, state, p->sz, "\n");
8010616d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106170:	8b 00                	mov    (%eax),%eax
80106172:	83 ec 0c             	sub    $0xc,%esp
80106175:	68 7a ab 10 80       	push   $0x8010ab7a
8010617a:	50                   	push   %eax
8010617b:	ff 75 dc             	pushl  -0x24(%ebp)
8010617e:	ff 75 cc             	pushl  -0x34(%ebp)
80106181:	68 7c ab 10 80       	push   $0x8010ab7c
80106186:	e8 3b a2 ff ff       	call   801003c6 <cprintf>
8010618b:	83 c4 20             	add    $0x20,%esp
	if(cpum > 9 && cpum < 100)
8010618e:	83 7d cc 09          	cmpl   $0x9,-0x34(%ebp)
80106192:	7e 27                	jle    801061bb <procdump+0x31c>
80106194:	83 7d cc 63          	cmpl   $0x63,-0x34(%ebp)
80106198:	7f 21                	jg     801061bb <procdump+0x31c>
	    cprintf("0%d\t%s\t%d\t", cpum, state, p->sz, "\n");
8010619a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010619d:	8b 00                	mov    (%eax),%eax
8010619f:	83 ec 0c             	sub    $0xc,%esp
801061a2:	68 7a ab 10 80       	push   $0x8010ab7a
801061a7:	50                   	push   %eax
801061a8:	ff 75 dc             	pushl  -0x24(%ebp)
801061ab:	ff 75 cc             	pushl  -0x34(%ebp)
801061ae:	68 88 ab 10 80       	push   $0x8010ab88
801061b3:	e8 0e a2 ff ff       	call   801003c6 <cprintf>
801061b8:	83 c4 20             	add    $0x20,%esp
	if(cpum > 100)
801061bb:	83 7d cc 64          	cmpl   $0x64,-0x34(%ebp)
801061bf:	7e 21                	jle    801061e2 <procdump+0x343>
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
801061c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801061c4:	8b 00                	mov    (%eax),%eax
801061c6:	83 ec 0c             	sub    $0xc,%esp
801061c9:	68 7a ab 10 80       	push   $0x8010ab7a
801061ce:	50                   	push   %eax
801061cf:	ff 75 dc             	pushl  -0x24(%ebp)
801061d2:	ff 75 cc             	pushl  -0x34(%ebp)
801061d5:	68 93 ab 10 80       	push   $0x8010ab93
801061da:	e8 e7 a1 ff ff       	call   801003c6 <cprintf>
801061df:	83 c4 20             	add    $0x20,%esp
    }
    if(p->state == SLEEPING){
801061e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801061e5:	8b 40 0c             	mov    0xc(%eax),%eax
801061e8:	83 f8 02             	cmp    $0x2,%eax
801061eb:	75 54                	jne    80106241 <procdump+0x3a2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801061ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801061f0:	8b 40 1c             	mov    0x1c(%eax),%eax
801061f3:	8b 40 0c             	mov    0xc(%eax),%eax
801061f6:	83 c0 08             	add    $0x8,%eax
801061f9:	89 c2                	mov    %eax,%edx
801061fb:	83 ec 08             	sub    $0x8,%esp
801061fe:	8d 45 a4             	lea    -0x5c(%ebp),%eax
80106201:	50                   	push   %eax
80106202:	52                   	push   %edx
80106203:	e8 ff 0b 00 00       	call   80106e07 <getcallerpcs>
80106208:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010620b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106212:	eb 1c                	jmp    80106230 <procdump+0x391>
        cprintf(" %p", pc[i]);
80106214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106217:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
8010621b:	83 ec 08             	sub    $0x8,%esp
8010621e:	50                   	push   %eax
8010621f:	68 9d ab 10 80       	push   $0x8010ab9d
80106224:	e8 9d a1 ff ff       	call   801003c6 <cprintf>
80106229:	83 c4 10             	add    $0x10,%esp
	if(cpum > 100)
	    cprintf("%d\t%s\t%d\t", cpum, state, p->sz, "\n");
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010622c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80106230:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
80106234:	7f 0b                	jg     80106241 <procdump+0x3a2>
80106236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106239:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
8010623d:	85 c0                	test   %eax,%eax
8010623f:	75 d3                	jne    80106214 <procdump+0x375>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80106241:	83 ec 0c             	sub    $0xc,%esp
80106244:	68 7a ab 10 80       	push   $0x8010ab7a
80106249:	e8 78 a1 ff ff       	call   801003c6 <cprintf>
8010624e:	83 c4 10             	add    $0x10,%esp
80106251:	eb 01                	jmp    80106254 <procdump+0x3b5>
    while(0)
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80106253:	90                   	nop

    char *state = "???";
    while(0)
	cprintf("%d", state);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80106254:	81 45 e0 9c 00 00 00 	addl   $0x9c,-0x20(%ebp)
8010625b:	81 7d e0 b4 80 11 80 	cmpl   $0x801180b4,-0x20(%ebp)
80106262:	0f 82 74 fc ff ff    	jb     80105edc <procdump+0x3d>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

    cprintf("\n");
80106268:	83 ec 0c             	sub    $0xc,%esp
8010626b:	68 7a ab 10 80       	push   $0x8010ab7a
80106270:	e8 51 a1 ff ff       	call   801003c6 <cprintf>
80106275:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80106278:	83 ec 0c             	sub    $0xc,%esp
8010627b:	68 80 59 11 80       	push   $0x80115980
80106280:	e8 30 0b 00 00       	call   80106db5 <release>
80106285:	83 c4 10             	add    $0x10,%esp
}
80106288:	90                   	nop
80106289:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010628c:	5b                   	pop    %ebx
8010628d:	5e                   	pop    %esi
8010628e:	5f                   	pop    %edi
8010628f:	5d                   	pop    %ebp
80106290:	c3                   	ret    

80106291 <getproctable>:
}

#else
int 
getproctable(uint max, struct uproc* table)
{
80106291:	55                   	push   %ebp
80106292:	89 e5                	mov    %esp,%ebp
80106294:	53                   	push   %ebx
80106295:	83 ec 14             	sub    $0x14,%esp
    int i = 0;
80106298:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);
8010629f:	83 ec 0c             	sub    $0xc,%esp
801062a2:	68 80 59 11 80       	push   $0x80115980
801062a7:	e8 a2 0a 00 00       	call   80106d4e <acquire>
801062ac:	83 c4 10             	add    $0x10,%esp

    for(int j = 0; j < MAX+1; ++j){
801062af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801062b6:	e9 ca 01 00 00       	jmp    80106485 <getproctable+0x1f4>
	p = ptable.pLists.ready[j];
801062bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062be:	05 cc 09 00 00       	add    $0x9cc,%eax
801062c3:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
801062ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(p){	
801062cd:	e9 a5 01 00 00       	jmp    80106477 <getproctable+0x1e6>
	    table[i].pid = p -> pid;
801062d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062d5:	89 d0                	mov    %edx,%eax
801062d7:	01 c0                	add    %eax,%eax
801062d9:	01 d0                	add    %edx,%eax
801062db:	c1 e0 05             	shl    $0x5,%eax
801062de:	89 c2                	mov    %eax,%edx
801062e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801062e3:	01 c2                	add    %eax,%edx
801062e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e8:	8b 40 10             	mov    0x10(%eax),%eax
801062eb:	89 02                	mov    %eax,(%edx)
	    table[i].uid = p -> uid;
801062ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062f0:	89 d0                	mov    %edx,%eax
801062f2:	01 c0                	add    %eax,%eax
801062f4:	01 d0                	add    %edx,%eax
801062f6:	c1 e0 05             	shl    $0x5,%eax
801062f9:	89 c2                	mov    %eax,%edx
801062fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801062fe:	01 c2                	add    %eax,%edx
80106300:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106303:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106309:	89 42 04             	mov    %eax,0x4(%edx)
	    table[i].gid = p -> gid;
8010630c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010630f:	89 d0                	mov    %edx,%eax
80106311:	01 c0                	add    %eax,%eax
80106313:	01 d0                	add    %edx,%eax
80106315:	c1 e0 05             	shl    $0x5,%eax
80106318:	89 c2                	mov    %eax,%edx
8010631a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010631d:	01 c2                	add    %eax,%edx
8010631f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106322:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106328:	89 42 08             	mov    %eax,0x8(%edx)
	    table[i].priority = p -> priority;
8010632b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010632e:	89 d0                	mov    %edx,%eax
80106330:	01 c0                	add    %eax,%eax
80106332:	01 d0                	add    %edx,%eax
80106334:	c1 e0 05             	shl    $0x5,%eax
80106337:	89 c2                	mov    %eax,%edx
80106339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010633c:	01 c2                	add    %eax,%edx
8010633e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106341:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106347:	89 42 5c             	mov    %eax,0x5c(%edx)

	    if(p -> pid == 1)
8010634a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634d:	8b 40 10             	mov    0x10(%eax),%eax
80106350:	83 f8 01             	cmp    $0x1,%eax
80106353:	75 1c                	jne    80106371 <getproctable+0xe0>
		table[i].ppid = 1;
80106355:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106358:	89 d0                	mov    %edx,%eax
8010635a:	01 c0                	add    %eax,%eax
8010635c:	01 d0                	add    %edx,%eax
8010635e:	c1 e0 05             	shl    $0x5,%eax
80106361:	89 c2                	mov    %eax,%edx
80106363:	8b 45 0c             	mov    0xc(%ebp),%eax
80106366:	01 d0                	add    %edx,%eax
80106368:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
8010636f:	eb 1f                	jmp    80106390 <getproctable+0xff>
	    else
		table[i].ppid = p -> parent -> pid;
80106371:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106374:	89 d0                	mov    %edx,%eax
80106376:	01 c0                	add    %eax,%eax
80106378:	01 d0                	add    %edx,%eax
8010637a:	c1 e0 05             	shl    $0x5,%eax
8010637d:	89 c2                	mov    %eax,%edx
8010637f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106382:	01 c2                	add    %eax,%edx
80106384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106387:	8b 40 14             	mov    0x14(%eax),%eax
8010638a:	8b 40 10             	mov    0x10(%eax),%eax
8010638d:	89 42 0c             	mov    %eax,0xc(%edx)
		
	    table[i].elapsed_ticks = ticks - (p -> start_ticks);
80106390:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106393:	89 d0                	mov    %edx,%eax
80106395:	01 c0                	add    %eax,%eax
80106397:	01 d0                	add    %edx,%eax
80106399:	c1 e0 05             	shl    $0x5,%eax
8010639c:	89 c2                	mov    %eax,%edx
8010639e:	8b 45 0c             	mov    0xc(%ebp),%eax
801063a1:	01 c2                	add    %eax,%edx
801063a3:	8b 0d e0 88 11 80    	mov    0x801188e0,%ecx
801063a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ac:	8b 40 7c             	mov    0x7c(%eax),%eax
801063af:	29 c1                	sub    %eax,%ecx
801063b1:	89 c8                	mov    %ecx,%eax
801063b3:	89 42 10             	mov    %eax,0x10(%edx)

	    table[i].CPU_total_ticks = p -> cpu_ticks_total;
801063b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063b9:	89 d0                	mov    %edx,%eax
801063bb:	01 c0                	add    %eax,%eax
801063bd:	01 d0                	add    %edx,%eax
801063bf:	c1 e0 05             	shl    $0x5,%eax
801063c2:	89 c2                	mov    %eax,%edx
801063c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801063c7:	01 c2                	add    %eax,%edx
801063c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cc:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801063d2:	89 42 14             	mov    %eax,0x14(%edx)

	    safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
801063d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d8:	8b 40 0c             	mov    0xc(%eax),%eax
801063db:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
801063e2:	83 ec 0c             	sub    $0xc,%esp
801063e5:	50                   	push   %eax
801063e6:	e8 13 0e 00 00       	call   801071fe <strlen>
801063eb:	83 c4 10             	add    $0x10,%esp
801063ee:	89 c3                	mov    %eax,%ebx
801063f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f3:	8b 40 0c             	mov    0xc(%eax),%eax
801063f6:	8b 0c 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%ecx
801063fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106400:	89 d0                	mov    %edx,%eax
80106402:	01 c0                	add    %eax,%eax
80106404:	01 d0                	add    %edx,%eax
80106406:	c1 e0 05             	shl    $0x5,%eax
80106409:	89 c2                	mov    %eax,%edx
8010640b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010640e:	01 d0                	add    %edx,%eax
80106410:	83 c0 18             	add    $0x18,%eax
80106413:	83 ec 04             	sub    $0x4,%esp
80106416:	53                   	push   %ebx
80106417:	51                   	push   %ecx
80106418:	50                   	push   %eax
80106419:	e8 96 0d 00 00       	call   801071b4 <safestrcpy>
8010641e:	83 c4 10             	add    $0x10,%esp

	    table[i].size = p -> sz;
80106421:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106424:	89 d0                	mov    %edx,%eax
80106426:	01 c0                	add    %eax,%eax
80106428:	01 d0                	add    %edx,%eax
8010642a:	c1 e0 05             	shl    $0x5,%eax
8010642d:	89 c2                	mov    %eax,%edx
8010642f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106432:	01 c2                	add    %eax,%edx
80106434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106437:	8b 00                	mov    (%eax),%eax
80106439:	89 42 38             	mov    %eax,0x38(%edx)

	    safestrcpy(table[i].name,p -> name, STRMAX);
8010643c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106442:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106445:	89 d0                	mov    %edx,%eax
80106447:	01 c0                	add    %eax,%eax
80106449:	01 d0                	add    %edx,%eax
8010644b:	c1 e0 05             	shl    $0x5,%eax
8010644e:	89 c2                	mov    %eax,%edx
80106450:	8b 45 0c             	mov    0xc(%ebp),%eax
80106453:	01 d0                	add    %edx,%eax
80106455:	83 c0 3c             	add    $0x3c,%eax
80106458:	83 ec 04             	sub    $0x4,%esp
8010645b:	6a 20                	push   $0x20
8010645d:	51                   	push   %ecx
8010645e:	50                   	push   %eax
8010645f:	e8 50 0d 00 00       	call   801071b4 <safestrcpy>
80106464:	83 c4 10             	add    $0x10,%esp
	    p = p -> next;
80106467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646a:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106470:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    ++i;
80106473:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    //acquire lock
    acquire(&ptable.lock);

    for(int j = 0; j < MAX+1; ++j){
	p = ptable.pLists.ready[j];
	while(p){	
80106477:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010647b:	0f 85 51 fe ff ff    	jne    801062d2 <getproctable+0x41>
    int i = 0;
    struct proc *p;
    //acquire lock
    acquire(&ptable.lock);

    for(int j = 0; j < MAX+1; ++j){
80106481:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80106485:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80106489:	0f 8e 2c fe ff ff    	jle    801062bb <getproctable+0x2a>
	    safestrcpy(table[i].name,p -> name, STRMAX);
	    p = p -> next;
	    ++i;
	}
    }
    p = ptable.pLists.sleep;
8010648f:	a1 cc 80 11 80       	mov    0x801180cc,%eax
80106494:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(p){	
80106497:	e9 a5 01 00 00       	jmp    80106641 <getproctable+0x3b0>
	table[i].pid = p -> pid;
8010649c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010649f:	89 d0                	mov    %edx,%eax
801064a1:	01 c0                	add    %eax,%eax
801064a3:	01 d0                	add    %edx,%eax
801064a5:	c1 e0 05             	shl    $0x5,%eax
801064a8:	89 c2                	mov    %eax,%edx
801064aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801064ad:	01 c2                	add    %eax,%edx
801064af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b2:	8b 40 10             	mov    0x10(%eax),%eax
801064b5:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
801064b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ba:	89 d0                	mov    %edx,%eax
801064bc:	01 c0                	add    %eax,%eax
801064be:	01 d0                	add    %edx,%eax
801064c0:	c1 e0 05             	shl    $0x5,%eax
801064c3:	89 c2                	mov    %eax,%edx
801064c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801064c8:	01 c2                	add    %eax,%edx
801064ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801064d3:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
801064d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064d9:	89 d0                	mov    %edx,%eax
801064db:	01 c0                	add    %eax,%eax
801064dd:	01 d0                	add    %edx,%eax
801064df:	c1 e0 05             	shl    $0x5,%eax
801064e2:	89 c2                	mov    %eax,%edx
801064e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801064e7:	01 c2                	add    %eax,%edx
801064e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ec:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801064f2:	89 42 08             	mov    %eax,0x8(%edx)
	table[i].priority = p -> priority;
801064f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064f8:	89 d0                	mov    %edx,%eax
801064fa:	01 c0                	add    %eax,%eax
801064fc:	01 d0                	add    %edx,%eax
801064fe:	c1 e0 05             	shl    $0x5,%eax
80106501:	89 c2                	mov    %eax,%edx
80106503:	8b 45 0c             	mov    0xc(%ebp),%eax
80106506:	01 c2                	add    %eax,%edx
80106508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650b:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106511:	89 42 5c             	mov    %eax,0x5c(%edx)

	if(p -> pid == 1)
80106514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106517:	8b 40 10             	mov    0x10(%eax),%eax
8010651a:	83 f8 01             	cmp    $0x1,%eax
8010651d:	75 1c                	jne    8010653b <getproctable+0x2aa>
	    table[i].ppid = 1;
8010651f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106522:	89 d0                	mov    %edx,%eax
80106524:	01 c0                	add    %eax,%eax
80106526:	01 d0                	add    %edx,%eax
80106528:	c1 e0 05             	shl    $0x5,%eax
8010652b:	89 c2                	mov    %eax,%edx
8010652d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106530:	01 d0                	add    %edx,%eax
80106532:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
80106539:	eb 1f                	jmp    8010655a <getproctable+0x2c9>
	else
	    table[i].ppid = p -> parent -> pid;
8010653b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010653e:	89 d0                	mov    %edx,%eax
80106540:	01 c0                	add    %eax,%eax
80106542:	01 d0                	add    %edx,%eax
80106544:	c1 e0 05             	shl    $0x5,%eax
80106547:	89 c2                	mov    %eax,%edx
80106549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010654c:	01 c2                	add    %eax,%edx
8010654e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106551:	8b 40 14             	mov    0x14(%eax),%eax
80106554:	8b 40 10             	mov    0x10(%eax),%eax
80106557:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
8010655a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010655d:	89 d0                	mov    %edx,%eax
8010655f:	01 c0                	add    %eax,%eax
80106561:	01 d0                	add    %edx,%eax
80106563:	c1 e0 05             	shl    $0x5,%eax
80106566:	89 c2                	mov    %eax,%edx
80106568:	8b 45 0c             	mov    0xc(%ebp),%eax
8010656b:	01 c2                	add    %eax,%edx
8010656d:	8b 0d e0 88 11 80    	mov    0x801188e0,%ecx
80106573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106576:	8b 40 7c             	mov    0x7c(%eax),%eax
80106579:	29 c1                	sub    %eax,%ecx
8010657b:	89 c8                	mov    %ecx,%eax
8010657d:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
80106580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106583:	89 d0                	mov    %edx,%eax
80106585:	01 c0                	add    %eax,%eax
80106587:	01 d0                	add    %edx,%eax
80106589:	c1 e0 05             	shl    $0x5,%eax
8010658c:	89 c2                	mov    %eax,%edx
8010658e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106591:	01 c2                	add    %eax,%edx
80106593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106596:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010659c:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
8010659f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a2:	8b 40 0c             	mov    0xc(%eax),%eax
801065a5:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
801065ac:	83 ec 0c             	sub    $0xc,%esp
801065af:	50                   	push   %eax
801065b0:	e8 49 0c 00 00       	call   801071fe <strlen>
801065b5:	83 c4 10             	add    $0x10,%esp
801065b8:	89 c3                	mov    %eax,%ebx
801065ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065bd:	8b 40 0c             	mov    0xc(%eax),%eax
801065c0:	8b 0c 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%ecx
801065c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065ca:	89 d0                	mov    %edx,%eax
801065cc:	01 c0                	add    %eax,%eax
801065ce:	01 d0                	add    %edx,%eax
801065d0:	c1 e0 05             	shl    $0x5,%eax
801065d3:	89 c2                	mov    %eax,%edx
801065d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801065d8:	01 d0                	add    %edx,%eax
801065da:	83 c0 18             	add    $0x18,%eax
801065dd:	83 ec 04             	sub    $0x4,%esp
801065e0:	53                   	push   %ebx
801065e1:	51                   	push   %ecx
801065e2:	50                   	push   %eax
801065e3:	e8 cc 0b 00 00       	call   801071b4 <safestrcpy>
801065e8:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
801065eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065ee:	89 d0                	mov    %edx,%eax
801065f0:	01 c0                	add    %eax,%eax
801065f2:	01 d0                	add    %edx,%eax
801065f4:	c1 e0 05             	shl    $0x5,%eax
801065f7:	89 c2                	mov    %eax,%edx
801065f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801065fc:	01 c2                	add    %eax,%edx
801065fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106601:	8b 00                	mov    (%eax),%eax
80106603:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
80106606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106609:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010660c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010660f:	89 d0                	mov    %edx,%eax
80106611:	01 c0                	add    %eax,%eax
80106613:	01 d0                	add    %edx,%eax
80106615:	c1 e0 05             	shl    $0x5,%eax
80106618:	89 c2                	mov    %eax,%edx
8010661a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010661d:	01 d0                	add    %edx,%eax
8010661f:	83 c0 3c             	add    $0x3c,%eax
80106622:	83 ec 04             	sub    $0x4,%esp
80106625:	6a 20                	push   $0x20
80106627:	51                   	push   %ecx
80106628:	50                   	push   %eax
80106629:	e8 86 0b 00 00       	call   801071b4 <safestrcpy>
8010662e:	83 c4 10             	add    $0x10,%esp
	p = p -> next;
80106631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106634:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010663a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	++i;
8010663d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	    p = p -> next;
	    ++i;
	}
    }
    p = ptable.pLists.sleep;
    while(p){	
80106641:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106645:	0f 85 51 fe ff ff    	jne    8010649c <getproctable+0x20b>
	safestrcpy(table[i].name,p -> name, STRMAX);
	p = p -> next;
	++i;
    }

    p = ptable.pLists.running;
8010664b:	a1 d4 80 11 80       	mov    0x801180d4,%eax
80106650:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(p){	
80106653:	e9 a5 01 00 00       	jmp    801067fd <getproctable+0x56c>
	table[i].pid = p -> pid;
80106658:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010665b:	89 d0                	mov    %edx,%eax
8010665d:	01 c0                	add    %eax,%eax
8010665f:	01 d0                	add    %edx,%eax
80106661:	c1 e0 05             	shl    $0x5,%eax
80106664:	89 c2                	mov    %eax,%edx
80106666:	8b 45 0c             	mov    0xc(%ebp),%eax
80106669:	01 c2                	add    %eax,%edx
8010666b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010666e:	8b 40 10             	mov    0x10(%eax),%eax
80106671:	89 02                	mov    %eax,(%edx)
	table[i].uid = p -> uid;
80106673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106676:	89 d0                	mov    %edx,%eax
80106678:	01 c0                	add    %eax,%eax
8010667a:	01 d0                	add    %edx,%eax
8010667c:	c1 e0 05             	shl    $0x5,%eax
8010667f:	89 c2                	mov    %eax,%edx
80106681:	8b 45 0c             	mov    0xc(%ebp),%eax
80106684:	01 c2                	add    %eax,%edx
80106686:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106689:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010668f:	89 42 04             	mov    %eax,0x4(%edx)
	table[i].gid = p -> gid;
80106692:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106695:	89 d0                	mov    %edx,%eax
80106697:	01 c0                	add    %eax,%eax
80106699:	01 d0                	add    %edx,%eax
8010669b:	c1 e0 05             	shl    $0x5,%eax
8010669e:	89 c2                	mov    %eax,%edx
801066a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801066a3:	01 c2                	add    %eax,%edx
801066a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066a8:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801066ae:	89 42 08             	mov    %eax,0x8(%edx)
	table[i].priority = p -> priority;
801066b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066b4:	89 d0                	mov    %edx,%eax
801066b6:	01 c0                	add    %eax,%eax
801066b8:	01 d0                	add    %edx,%eax
801066ba:	c1 e0 05             	shl    $0x5,%eax
801066bd:	89 c2                	mov    %eax,%edx
801066bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801066c2:	01 c2                	add    %eax,%edx
801066c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c7:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801066cd:	89 42 5c             	mov    %eax,0x5c(%edx)

	if(p -> pid == 1)
801066d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d3:	8b 40 10             	mov    0x10(%eax),%eax
801066d6:	83 f8 01             	cmp    $0x1,%eax
801066d9:	75 1c                	jne    801066f7 <getproctable+0x466>
	    table[i].ppid = 1;
801066db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066de:	89 d0                	mov    %edx,%eax
801066e0:	01 c0                	add    %eax,%eax
801066e2:	01 d0                	add    %edx,%eax
801066e4:	c1 e0 05             	shl    $0x5,%eax
801066e7:	89 c2                	mov    %eax,%edx
801066e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801066ec:	01 d0                	add    %edx,%eax
801066ee:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
801066f5:	eb 1f                	jmp    80106716 <getproctable+0x485>
	else
	    table[i].ppid = p -> parent -> pid;
801066f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066fa:	89 d0                	mov    %edx,%eax
801066fc:	01 c0                	add    %eax,%eax
801066fe:	01 d0                	add    %edx,%eax
80106700:	c1 e0 05             	shl    $0x5,%eax
80106703:	89 c2                	mov    %eax,%edx
80106705:	8b 45 0c             	mov    0xc(%ebp),%eax
80106708:	01 c2                	add    %eax,%edx
8010670a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670d:	8b 40 14             	mov    0x14(%eax),%eax
80106710:	8b 40 10             	mov    0x10(%eax),%eax
80106713:	89 42 0c             	mov    %eax,0xc(%edx)
	    
	table[i].elapsed_ticks = ticks - (p -> start_ticks);
80106716:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106719:	89 d0                	mov    %edx,%eax
8010671b:	01 c0                	add    %eax,%eax
8010671d:	01 d0                	add    %edx,%eax
8010671f:	c1 e0 05             	shl    $0x5,%eax
80106722:	89 c2                	mov    %eax,%edx
80106724:	8b 45 0c             	mov    0xc(%ebp),%eax
80106727:	01 c2                	add    %eax,%edx
80106729:	8b 0d e0 88 11 80    	mov    0x801188e0,%ecx
8010672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106732:	8b 40 7c             	mov    0x7c(%eax),%eax
80106735:	29 c1                	sub    %eax,%ecx
80106737:	89 c8                	mov    %ecx,%eax
80106739:	89 42 10             	mov    %eax,0x10(%edx)

	table[i].CPU_total_ticks = p -> cpu_ticks_total;
8010673c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010673f:	89 d0                	mov    %edx,%eax
80106741:	01 c0                	add    %eax,%eax
80106743:	01 d0                	add    %edx,%eax
80106745:	c1 e0 05             	shl    $0x5,%eax
80106748:	89 c2                	mov    %eax,%edx
8010674a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010674d:	01 c2                	add    %eax,%edx
8010674f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106752:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106758:	89 42 14             	mov    %eax,0x14(%edx)

	safestrcpy(table[i].state, states[p->state],strlen(states[p->state]) );
8010675b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010675e:	8b 40 0c             	mov    0xc(%eax),%eax
80106761:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
80106768:	83 ec 0c             	sub    $0xc,%esp
8010676b:	50                   	push   %eax
8010676c:	e8 8d 0a 00 00       	call   801071fe <strlen>
80106771:	83 c4 10             	add    $0x10,%esp
80106774:	89 c3                	mov    %eax,%ebx
80106776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106779:	8b 40 0c             	mov    0xc(%eax),%eax
8010677c:	8b 0c 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%ecx
80106783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106786:	89 d0                	mov    %edx,%eax
80106788:	01 c0                	add    %eax,%eax
8010678a:	01 d0                	add    %edx,%eax
8010678c:	c1 e0 05             	shl    $0x5,%eax
8010678f:	89 c2                	mov    %eax,%edx
80106791:	8b 45 0c             	mov    0xc(%ebp),%eax
80106794:	01 d0                	add    %edx,%eax
80106796:	83 c0 18             	add    $0x18,%eax
80106799:	83 ec 04             	sub    $0x4,%esp
8010679c:	53                   	push   %ebx
8010679d:	51                   	push   %ecx
8010679e:	50                   	push   %eax
8010679f:	e8 10 0a 00 00       	call   801071b4 <safestrcpy>
801067a4:	83 c4 10             	add    $0x10,%esp

	table[i].size = p -> sz;
801067a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067aa:	89 d0                	mov    %edx,%eax
801067ac:	01 c0                	add    %eax,%eax
801067ae:	01 d0                	add    %edx,%eax
801067b0:	c1 e0 05             	shl    $0x5,%eax
801067b3:	89 c2                	mov    %eax,%edx
801067b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801067b8:	01 c2                	add    %eax,%edx
801067ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067bd:	8b 00                	mov    (%eax),%eax
801067bf:	89 42 38             	mov    %eax,0x38(%edx)

	safestrcpy(table[i].name,p -> name, STRMAX);
801067c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c5:	8d 48 6c             	lea    0x6c(%eax),%ecx
801067c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067cb:	89 d0                	mov    %edx,%eax
801067cd:	01 c0                	add    %eax,%eax
801067cf:	01 d0                	add    %edx,%eax
801067d1:	c1 e0 05             	shl    $0x5,%eax
801067d4:	89 c2                	mov    %eax,%edx
801067d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801067d9:	01 d0                	add    %edx,%eax
801067db:	83 c0 3c             	add    $0x3c,%eax
801067de:	83 ec 04             	sub    $0x4,%esp
801067e1:	6a 20                	push   $0x20
801067e3:	51                   	push   %ecx
801067e4:	50                   	push   %eax
801067e5:	e8 ca 09 00 00       	call   801071b4 <safestrcpy>
801067ea:	83 c4 10             	add    $0x10,%esp
	p = p -> next;
801067ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801067f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	++i;
801067f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	p = p -> next;
	++i;
    }

    p = ptable.pLists.running;
    while(p){	
801067fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106801:	0f 85 51 fe ff ff    	jne    80106658 <getproctable+0x3c7>
	++i;
    }

   
    //release lock
    release(&ptable.lock);
80106807:	83 ec 0c             	sub    $0xc,%esp
8010680a:	68 80 59 11 80       	push   $0x80115980
8010680f:	e8 a1 05 00 00       	call   80106db5 <release>
80106814:	83 c4 10             	add    $0x10,%esp
    return i +1;
80106817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681a:	83 c0 01             	add    $0x1,%eax
}
8010681d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106820:	c9                   	leave  
80106821:	c3                   	ret    

80106822 <printready>:


#endif
#ifdef CS333_P3P4
void
printready(void){
80106822:	55                   	push   %ebp
80106823:	89 e5                	mov    %esp,%ebp
80106825:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106828:	83 ec 0c             	sub    $0xc,%esp
8010682b:	68 80 59 11 80       	push   $0x80115980
80106830:	e8 19 05 00 00       	call   80106d4e <acquire>
80106835:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.ready[0];
80106838:	a1 b4 80 11 80       	mov    0x801180b4,%eax
8010683d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Ready List Processes:\n\n");
80106840:	83 ec 0c             	sub    $0xc,%esp
80106843:	68 a1 ab 10 80       	push   $0x8010aba1
80106848:	e8 79 9b ff ff       	call   801003c6 <cprintf>
8010684d:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < MAX+1; ++i){
80106850:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106857:	e9 84 00 00 00       	jmp    801068e0 <printready+0xbe>
	current = ptable.pLists.ready[i];
8010685c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685f:	05 cc 09 00 00       	add    $0x9cc,%eax
80106864:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
8010686b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("%d:",i);
8010686e:	83 ec 08             	sub    $0x8,%esp
80106871:	ff 75 f0             	pushl  -0x10(%ebp)
80106874:	68 b9 ab 10 80       	push   $0x8010abb9
80106879:	e8 48 9b ff ff       	call   801003c6 <cprintf>
8010687e:	83 c4 10             	add    $0x10,%esp

	if(!current)
80106881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106885:	75 3f                	jne    801068c6 <printready+0xa4>
	    cprintf("No Ready Processes\n");
80106887:	83 ec 0c             	sub    $0xc,%esp
8010688a:	68 bd ab 10 80       	push   $0x8010abbd
8010688f:	e8 32 9b ff ff       	call   801003c6 <cprintf>
80106894:	83 c4 10             	add    $0x10,%esp

	while(current){
80106897:	eb 2d                	jmp    801068c6 <printready+0xa4>
	    cprintf("(%d, %d) -> ", current -> pid, current -> budget);
80106899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689c:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
801068a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a5:	8b 40 10             	mov    0x10(%eax),%eax
801068a8:	83 ec 04             	sub    $0x4,%esp
801068ab:	52                   	push   %edx
801068ac:	50                   	push   %eax
801068ad:	68 d1 ab 10 80       	push   $0x8010abd1
801068b2:	e8 0f 9b ff ff       	call   801003c6 <cprintf>
801068b7:	83 c4 10             	add    $0x10,%esp
	    current = current -> next;
801068ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068bd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801068c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("%d:",i);

	if(!current)
	    cprintf("No Ready Processes\n");

	while(current){
801068c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068ca:	75 cd                	jne    80106899 <printready+0x77>
	    cprintf("(%d, %d) -> ", current -> pid, current -> budget);
	    current = current -> next;
	}
	cprintf("\n");
801068cc:	83 ec 0c             	sub    $0xc,%esp
801068cf:	68 7a ab 10 80       	push   $0x8010ab7a
801068d4:	e8 ed 9a ff ff       	call   801003c6 <cprintf>
801068d9:	83 c4 10             	add    $0x10,%esp
printready(void){

    acquire(&ptable.lock);
    struct proc * current = ptable.pLists.ready[0];
    cprintf("Ready List Processes:\n\n");
    for(int i = 0; i < MAX+1; ++i){
801068dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801068e0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801068e4:	0f 8e 72 ff ff ff    	jle    8010685c <printready+0x3a>
	    current = current -> next;
	}
	cprintf("\n");

    }
    release(&ptable.lock);
801068ea:	83 ec 0c             	sub    $0xc,%esp
801068ed:	68 80 59 11 80       	push   $0x80115980
801068f2:	e8 be 04 00 00       	call   80106db5 <release>
801068f7:	83 c4 10             	add    $0x10,%esp
}
801068fa:	90                   	nop
801068fb:	c9                   	leave  
801068fc:	c3                   	ret    

801068fd <printfree>:
void
printfree(void){
801068fd:	55                   	push   %ebp
801068fe:	89 e5                	mov    %esp,%ebp
80106900:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106903:	83 ec 0c             	sub    $0xc,%esp
80106906:	68 80 59 11 80       	push   $0x80115980
8010690b:	e8 3e 04 00 00       	call   80106d4e <acquire>
80106910:	83 c4 10             	add    $0x10,%esp
    int freeprocs = 0;
80106913:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct proc * current = ptable.pLists.free;
8010691a:	a1 c8 80 11 80       	mov    0x801180c8,%eax
8010691f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    while(current){
80106922:	eb 10                	jmp    80106934 <printfree+0x37>
	++freeprocs;
80106924:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	current = current -> next;
80106928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010692b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106931:	89 45 f0             	mov    %eax,-0x10(%ebp)

    acquire(&ptable.lock);
    int freeprocs = 0;
    struct proc * current = ptable.pLists.free;

    while(current){
80106934:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106938:	75 ea                	jne    80106924 <printfree+0x27>
	++freeprocs;
	current = current -> next;
    }

    cprintf("Free list size: %d\n", freeprocs);
8010693a:	83 ec 08             	sub    $0x8,%esp
8010693d:	ff 75 f4             	pushl  -0xc(%ebp)
80106940:	68 de ab 10 80       	push   $0x8010abde
80106945:	e8 7c 9a ff ff       	call   801003c6 <cprintf>
8010694a:	83 c4 10             	add    $0x10,%esp
    
    cprintf("\n");
8010694d:	83 ec 0c             	sub    $0xc,%esp
80106950:	68 7a ab 10 80       	push   $0x8010ab7a
80106955:	e8 6c 9a ff ff       	call   801003c6 <cprintf>
8010695a:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
8010695d:	83 ec 0c             	sub    $0xc,%esp
80106960:	68 80 59 11 80       	push   $0x80115980
80106965:	e8 4b 04 00 00       	call   80106db5 <release>
8010696a:	83 c4 10             	add    $0x10,%esp
}
8010696d:	90                   	nop
8010696e:	c9                   	leave  
8010696f:	c3                   	ret    

80106970 <printsleep>:
void
printsleep(void){
80106970:	55                   	push   %ebp
80106971:	89 e5                	mov    %esp,%ebp
80106973:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106976:	83 ec 0c             	sub    $0xc,%esp
80106979:	68 80 59 11 80       	push   $0x80115980
8010697e:	e8 cb 03 00 00       	call   80106d4e <acquire>
80106983:	83 c4 10             	add    $0x10,%esp
    cprintf("Sleep List Processes:\n");
80106986:	83 ec 0c             	sub    $0xc,%esp
80106989:	68 f2 ab 10 80       	push   $0x8010abf2
8010698e:	e8 33 9a ff ff       	call   801003c6 <cprintf>
80106993:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.sleep;
80106996:	a1 cc 80 11 80       	mov    0x801180cc,%eax
8010699b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!current)
8010699e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069a2:	75 52                	jne    801069f6 <printsleep+0x86>
	cprintf("No Sleeping Processes\n");
801069a4:	83 ec 0c             	sub    $0xc,%esp
801069a7:	68 09 ac 10 80       	push   $0x8010ac09
801069ac:	e8 15 9a ff ff       	call   801003c6 <cprintf>
801069b1:	83 c4 10             	add    $0x10,%esp

    while(current){
801069b4:	eb 40                	jmp    801069f6 <printsleep+0x86>
	cprintf("%d", current -> pid);
801069b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b9:	8b 40 10             	mov    0x10(%eax),%eax
801069bc:	83 ec 08             	sub    $0x8,%esp
801069bf:	50                   	push   %eax
801069c0:	68 20 ac 10 80       	push   $0x8010ac20
801069c5:	e8 fc 99 ff ff       	call   801003c6 <cprintf>
801069ca:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
801069cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801069d6:	85 c0                	test   %eax,%eax
801069d8:	74 10                	je     801069ea <printsleep+0x7a>
	    cprintf(" -> ");
801069da:	83 ec 0c             	sub    $0xc,%esp
801069dd:	68 23 ac 10 80       	push   $0x8010ac23
801069e2:	e8 df 99 ff ff       	call   801003c6 <cprintf>
801069e7:	83 c4 10             	add    $0x10,%esp
	current = current -> next;
801069ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ed:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801069f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Sleep List Processes:\n");
    struct proc * current = ptable.pLists.sleep;
    if(!current)
	cprintf("No Sleeping Processes\n");

    while(current){
801069f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069fa:	75 ba                	jne    801069b6 <printsleep+0x46>
	if(current -> next)
	    cprintf(" -> ");
	current = current -> next;
    }

    cprintf("\n\n");
801069fc:	83 ec 0c             	sub    $0xc,%esp
801069ff:	68 28 ac 10 80       	push   $0x8010ac28
80106a04:	e8 bd 99 ff ff       	call   801003c6 <cprintf>
80106a09:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80106a0c:	83 ec 0c             	sub    $0xc,%esp
80106a0f:	68 80 59 11 80       	push   $0x80115980
80106a14:	e8 9c 03 00 00       	call   80106db5 <release>
80106a19:	83 c4 10             	add    $0x10,%esp
}
80106a1c:	90                   	nop
80106a1d:	c9                   	leave  
80106a1e:	c3                   	ret    

80106a1f <printzombie>:
void
printzombie(void){
80106a1f:	55                   	push   %ebp
80106a20:	89 e5                	mov    %esp,%ebp
80106a22:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106a25:	83 ec 0c             	sub    $0xc,%esp
80106a28:	68 80 59 11 80       	push   $0x80115980
80106a2d:	e8 1c 03 00 00       	call   80106d4e <acquire>
80106a32:	83 c4 10             	add    $0x10,%esp
    struct proc * current = ptable.pLists.zombie;
80106a35:	a1 d0 80 11 80       	mov    0x801180d0,%eax
80106a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("Zombie List Processes:\n");
80106a3d:	83 ec 0c             	sub    $0xc,%esp
80106a40:	68 2b ac 10 80       	push   $0x8010ac2b
80106a45:	e8 7c 99 ff ff       	call   801003c6 <cprintf>
80106a4a:	83 c4 10             	add    $0x10,%esp
    if(!current)
80106a4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a51:	0f 85 a2 00 00 00    	jne    80106af9 <printzombie+0xda>
	cprintf("No Zombie Processes\n");
80106a57:	83 ec 0c             	sub    $0xc,%esp
80106a5a:	68 43 ac 10 80       	push   $0x8010ac43
80106a5f:	e8 62 99 ff ff       	call   801003c6 <cprintf>
80106a64:	83 c4 10             	add    $0x10,%esp

    while(current){
80106a67:	e9 8d 00 00 00       	jmp    80106af9 <printzombie+0xda>
    if(current -> pid == 1){
80106a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6f:	8b 40 10             	mov    0x10(%eax),%eax
80106a72:	83 f8 01             	cmp    $0x1,%eax
80106a75:	75 38                	jne    80106aaf <printzombie+0x90>
	cprintf("(PID%d, PPID%d)",current -> pid, 1);
80106a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7a:	8b 40 10             	mov    0x10(%eax),%eax
80106a7d:	83 ec 04             	sub    $0x4,%esp
80106a80:	6a 01                	push   $0x1
80106a82:	50                   	push   %eax
80106a83:	68 58 ac 10 80       	push   $0x8010ac58
80106a88:	e8 39 99 ff ff       	call   801003c6 <cprintf>
80106a8d:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
80106a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a93:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106a99:	85 c0                	test   %eax,%eax
80106a9b:	74 50                	je     80106aed <printzombie+0xce>
	    cprintf(" -> ");
80106a9d:	83 ec 0c             	sub    $0xc,%esp
80106aa0:	68 23 ac 10 80       	push   $0x8010ac23
80106aa5:	e8 1c 99 ff ff       	call   801003c6 <cprintf>
80106aaa:	83 c4 10             	add    $0x10,%esp
80106aad:	eb 3e                	jmp    80106aed <printzombie+0xce>
    }
    else{
	cprintf("(PID%d, PPID%d)",current -> pid, current -> parent -> pid);
80106aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab2:	8b 40 14             	mov    0x14(%eax),%eax
80106ab5:	8b 50 10             	mov    0x10(%eax),%edx
80106ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106abb:	8b 40 10             	mov    0x10(%eax),%eax
80106abe:	83 ec 04             	sub    $0x4,%esp
80106ac1:	52                   	push   %edx
80106ac2:	50                   	push   %eax
80106ac3:	68 58 ac 10 80       	push   $0x8010ac58
80106ac8:	e8 f9 98 ff ff       	call   801003c6 <cprintf>
80106acd:	83 c4 10             	add    $0x10,%esp
	if(current -> next)
80106ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106ad9:	85 c0                	test   %eax,%eax
80106adb:	74 10                	je     80106aed <printzombie+0xce>
	    cprintf(" -> ");
80106add:	83 ec 0c             	sub    $0xc,%esp
80106ae0:	68 23 ac 10 80       	push   $0x8010ac23
80106ae5:	e8 dc 98 ff ff       	call   801003c6 <cprintf>
80106aea:	83 c4 10             	add    $0x10,%esp
    }
    current = current -> next;	
80106aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106af6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc * current = ptable.pLists.zombie;
    cprintf("Zombie List Processes:\n");
    if(!current)
	cprintf("No Zombie Processes\n");

    while(current){
80106af9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106afd:	0f 85 69 ff ff ff    	jne    80106a6c <printzombie+0x4d>
	if(current -> next)
	    cprintf(" -> ");
    }
    current = current -> next;	
    }
    cprintf("\n\n");
80106b03:	83 ec 0c             	sub    $0xc,%esp
80106b06:	68 28 ac 10 80       	push   $0x8010ac28
80106b0b:	e8 b6 98 ff ff       	call   801003c6 <cprintf>
80106b10:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80106b13:	83 ec 0c             	sub    $0xc,%esp
80106b16:	68 80 59 11 80       	push   $0x80115980
80106b1b:	e8 95 02 00 00       	call   80106db5 <release>
80106b20:	83 c4 10             	add    $0x10,%esp
}
80106b23:	90                   	nop
80106b24:	c9                   	leave  
80106b25:	c3                   	ret    

80106b26 <setpriority>:
int 
setpriority(int pid, int priority){
80106b26:	55                   	push   %ebp
80106b27:	89 e5                	mov    %esp,%ebp
80106b29:	83 ec 18             	sub    $0x18,%esp

    acquire(&ptable.lock);
80106b2c:	83 ec 0c             	sub    $0xc,%esp
80106b2f:	68 80 59 11 80       	push   $0x80115980
80106b34:	e8 15 02 00 00       	call   80106d4e <acquire>
80106b39:	83 c4 10             	add    $0x10,%esp

    if(priority < 0 || priority > MAX)
80106b3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106b40:	78 06                	js     80106b48 <setpriority+0x22>
80106b42:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
80106b46:	7e 0a                	jle    80106b52 <setpriority+0x2c>
	return -2;
80106b48:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
80106b4d:	e9 a0 01 00 00       	jmp    80106cf2 <setpriority+0x1cc>
    if(pid < 1)
80106b52:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106b56:	7f 0a                	jg     80106b62 <setpriority+0x3c>
	return -3;
80106b58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
80106b5d:	e9 90 01 00 00       	jmp    80106cf2 <setpriority+0x1cc>

    struct proc * current = ptable.pLists.ready[0];
80106b62:	a1 b4 80 11 80       	mov    0x801180b4,%eax
80106b67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i = 0; i < MAX+1; ++i){
80106b6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106b71:	e9 bb 00 00 00       	jmp    80106c31 <setpriority+0x10b>
	current = ptable.pLists.ready[i];
80106b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b79:	05 cc 09 00 00       	add    $0x9cc,%eax
80106b7e:	8b 04 85 84 59 11 80 	mov    -0x7feea67c(,%eax,4),%eax
80106b85:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while(current){
80106b88:	e9 96 00 00 00       	jmp    80106c23 <setpriority+0xfd>
	    if(current -> pid == pid){
80106b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b90:	8b 50 10             	mov    0x10(%eax),%edx
80106b93:	8b 45 08             	mov    0x8(%ebp),%eax
80106b96:	39 c2                	cmp    %eax,%edx
80106b98:	75 7d                	jne    80106c17 <setpriority+0xf1>
		current -> priority = priority;
80106b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba0:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
		current -> budget = BUDGET; 
80106ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba9:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106bb0:	13 00 00 
		removeFromStateList(&ptable.pLists.ready[i], current);
80106bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb6:	05 cc 09 00 00       	add    $0x9cc,%eax
80106bbb:	c1 e0 02             	shl    $0x2,%eax
80106bbe:	05 80 59 11 80       	add    $0x80115980,%eax
80106bc3:	83 c0 04             	add    $0x4,%eax
80106bc6:	83 ec 08             	sub    $0x8,%esp
80106bc9:	ff 75 f4             	pushl  -0xc(%ebp)
80106bcc:	50                   	push   %eax
80106bcd:	e8 91 dd ff ff       	call   80104963 <removeFromStateList>
80106bd2:	83 c4 10             	add    $0x10,%esp
		addToStateListEnd(&ptable.pLists.ready[current -> priority], current);
80106bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd8:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106bde:	05 cc 09 00 00       	add    $0x9cc,%eax
80106be3:	c1 e0 02             	shl    $0x2,%eax
80106be6:	05 80 59 11 80       	add    $0x80115980,%eax
80106beb:	83 c0 04             	add    $0x4,%eax
80106bee:	83 ec 08             	sub    $0x8,%esp
80106bf1:	ff 75 f4             	pushl  -0xc(%ebp)
80106bf4:	50                   	push   %eax
80106bf5:	e8 81 dc ff ff       	call   8010487b <addToStateListEnd>
80106bfa:	83 c4 10             	add    $0x10,%esp
		release(&ptable.lock);
80106bfd:	83 ec 0c             	sub    $0xc,%esp
80106c00:	68 80 59 11 80       	push   $0x80115980
80106c05:	e8 ab 01 00 00       	call   80106db5 <release>
80106c0a:	83 c4 10             	add    $0x10,%esp
		return 0;
80106c0d:	b8 00 00 00 00       	mov    $0x0,%eax
80106c12:	e9 db 00 00 00       	jmp    80106cf2 <setpriority+0x1cc>
	    }
	    current = current -> next;
80106c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1a:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106c20:	89 45 f4             	mov    %eax,-0xc(%ebp)

    struct proc * current = ptable.pLists.ready[0];
    for(int i = 0; i < MAX+1; ++i){
	current = ptable.pLists.ready[i];

	while(current){
80106c23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c27:	0f 85 60 ff ff ff    	jne    80106b8d <setpriority+0x67>
	return -2;
    if(pid < 1)
	return -3;

    struct proc * current = ptable.pLists.ready[0];
    for(int i = 0; i < MAX+1; ++i){
80106c2d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106c31:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80106c35:	0f 8e 3b ff ff ff    	jle    80106b76 <setpriority+0x50>
		return 0;
	    }
	    current = current -> next;
	}
    }
    current = ptable.pLists.sleep;
80106c3b:	a1 cc 80 11 80       	mov    0x801180cc,%eax
80106c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
80106c43:	eb 49                	jmp    80106c8e <setpriority+0x168>
	if(current -> pid == pid){
80106c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c48:	8b 50 10             	mov    0x10(%eax),%edx
80106c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c4e:	39 c2                	cmp    %eax,%edx
80106c50:	75 30                	jne    80106c82 <setpriority+0x15c>
	    current -> priority = priority;
80106c52:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c58:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
	    current -> budget = BUDGET; 
80106c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c61:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106c68:	13 00 00 
	    release(&ptable.lock);
80106c6b:	83 ec 0c             	sub    $0xc,%esp
80106c6e:	68 80 59 11 80       	push   $0x80115980
80106c73:	e8 3d 01 00 00       	call   80106db5 <release>
80106c78:	83 c4 10             	add    $0x10,%esp
	    return 0;
80106c7b:	b8 00 00 00 00       	mov    $0x0,%eax
80106c80:	eb 70                	jmp    80106cf2 <setpriority+0x1cc>
	}
	current = current -> next;
80106c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c85:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    }
	    current = current -> next;
	}
    }
    current = ptable.pLists.sleep;
    while(current){
80106c8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c92:	75 b1                	jne    80106c45 <setpriority+0x11f>
	    release(&ptable.lock);
	    return 0;
	}
	current = current -> next;
    }
    current = ptable.pLists.running;
80106c94:	a1 d4 80 11 80       	mov    0x801180d4,%eax
80106c99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current){
80106c9c:	eb 49                	jmp    80106ce7 <setpriority+0x1c1>
	if(current -> pid == pid){
80106c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca1:	8b 50 10             	mov    0x10(%eax),%edx
80106ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca7:	39 c2                	cmp    %eax,%edx
80106ca9:	75 30                	jne    80106cdb <setpriority+0x1b5>
	    current -> priority = priority;
80106cab:	8b 55 0c             	mov    0xc(%ebp),%edx
80106cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cb1:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
	    current -> budget = BUDGET; 
80106cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cba:	c7 80 98 00 00 00 88 	movl   $0x1388,0x98(%eax)
80106cc1:	13 00 00 
	    release(&ptable.lock);
80106cc4:	83 ec 0c             	sub    $0xc,%esp
80106cc7:	68 80 59 11 80       	push   $0x80115980
80106ccc:	e8 e4 00 00 00       	call   80106db5 <release>
80106cd1:	83 c4 10             	add    $0x10,%esp
	    return 0;
80106cd4:	b8 00 00 00 00       	mov    $0x0,%eax
80106cd9:	eb 17                	jmp    80106cf2 <setpriority+0x1cc>
	}
	current = current -> next;
80106cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cde:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    return 0;
	}
	current = current -> next;
    }
    current = ptable.pLists.running;
    while(current){
80106ce7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ceb:	75 b1                	jne    80106c9e <setpriority+0x178>
	    return 0;
	}
	current = current -> next;
    }

    return -1;
80106ced:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106cf2:	c9                   	leave  
80106cf3:	c3                   	ret    

80106cf4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80106cf4:	55                   	push   %ebp
80106cf5:	89 e5                	mov    %esp,%ebp
80106cf7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106cfa:	9c                   	pushf  
80106cfb:	58                   	pop    %eax
80106cfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80106cff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d02:	c9                   	leave  
80106d03:	c3                   	ret    

80106d04 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80106d04:	55                   	push   %ebp
80106d05:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80106d07:	fa                   	cli    
}
80106d08:	90                   	nop
80106d09:	5d                   	pop    %ebp
80106d0a:	c3                   	ret    

80106d0b <sti>:

static inline void
sti(void)
{
80106d0b:	55                   	push   %ebp
80106d0c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80106d0e:	fb                   	sti    
}
80106d0f:	90                   	nop
80106d10:	5d                   	pop    %ebp
80106d11:	c3                   	ret    

80106d12 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80106d12:	55                   	push   %ebp
80106d13:	89 e5                	mov    %esp,%ebp
80106d15:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80106d18:	8b 55 08             	mov    0x8(%ebp),%edx
80106d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106d21:	f0 87 02             	lock xchg %eax,(%edx)
80106d24:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80106d27:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d2a:	c9                   	leave  
80106d2b:	c3                   	ret    

80106d2c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80106d2c:	55                   	push   %ebp
80106d2d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80106d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d32:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d35:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80106d38:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80106d41:	8b 45 08             	mov    0x8(%ebp),%eax
80106d44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106d4b:	90                   	nop
80106d4c:	5d                   	pop    %ebp
80106d4d:	c3                   	ret    

80106d4e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106d4e:	55                   	push   %ebp
80106d4f:	89 e5                	mov    %esp,%ebp
80106d51:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80106d54:	e8 52 01 00 00       	call   80106eab <pushcli>
  if(holding(lk))
80106d59:	8b 45 08             	mov    0x8(%ebp),%eax
80106d5c:	83 ec 0c             	sub    $0xc,%esp
80106d5f:	50                   	push   %eax
80106d60:	e8 1c 01 00 00       	call   80106e81 <holding>
80106d65:	83 c4 10             	add    $0x10,%esp
80106d68:	85 c0                	test   %eax,%eax
80106d6a:	74 0d                	je     80106d79 <acquire+0x2b>
    panic("acquire");
80106d6c:	83 ec 0c             	sub    $0xc,%esp
80106d6f:	68 68 ac 10 80       	push   $0x8010ac68
80106d74:	e8 ed 97 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80106d79:	90                   	nop
80106d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7d:	83 ec 08             	sub    $0x8,%esp
80106d80:	6a 01                	push   $0x1
80106d82:	50                   	push   %eax
80106d83:	e8 8a ff ff ff       	call   80106d12 <xchg>
80106d88:	83 c4 10             	add    $0x10,%esp
80106d8b:	85 c0                	test   %eax,%eax
80106d8d:	75 eb                	jne    80106d7a <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80106d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d92:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106d99:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80106d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d9f:	83 c0 0c             	add    $0xc,%eax
80106da2:	83 ec 08             	sub    $0x8,%esp
80106da5:	50                   	push   %eax
80106da6:	8d 45 08             	lea    0x8(%ebp),%eax
80106da9:	50                   	push   %eax
80106daa:	e8 58 00 00 00       	call   80106e07 <getcallerpcs>
80106daf:	83 c4 10             	add    $0x10,%esp
}
80106db2:	90                   	nop
80106db3:	c9                   	leave  
80106db4:	c3                   	ret    

80106db5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80106db5:	55                   	push   %ebp
80106db6:	89 e5                	mov    %esp,%ebp
80106db8:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80106dbb:	83 ec 0c             	sub    $0xc,%esp
80106dbe:	ff 75 08             	pushl  0x8(%ebp)
80106dc1:	e8 bb 00 00 00       	call   80106e81 <holding>
80106dc6:	83 c4 10             	add    $0x10,%esp
80106dc9:	85 c0                	test   %eax,%eax
80106dcb:	75 0d                	jne    80106dda <release+0x25>
    panic("release");
80106dcd:	83 ec 0c             	sub    $0xc,%esp
80106dd0:	68 70 ac 10 80       	push   $0x8010ac70
80106dd5:	e8 8c 97 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80106dda:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80106de4:	8b 45 08             	mov    0x8(%ebp),%eax
80106de7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106dee:	8b 45 08             	mov    0x8(%ebp),%eax
80106df1:	83 ec 08             	sub    $0x8,%esp
80106df4:	6a 00                	push   $0x0
80106df6:	50                   	push   %eax
80106df7:	e8 16 ff ff ff       	call   80106d12 <xchg>
80106dfc:	83 c4 10             	add    $0x10,%esp

  popcli();
80106dff:	e8 ec 00 00 00       	call   80106ef0 <popcli>
}
80106e04:	90                   	nop
80106e05:	c9                   	leave  
80106e06:	c3                   	ret    

80106e07 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80106e07:	55                   	push   %ebp
80106e08:	89 e5                	mov    %esp,%ebp
80106e0a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e10:	83 e8 08             	sub    $0x8,%eax
80106e13:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80106e16:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106e1d:	eb 38                	jmp    80106e57 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106e1f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106e23:	74 53                	je     80106e78 <getcallerpcs+0x71>
80106e25:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106e2c:	76 4a                	jbe    80106e78 <getcallerpcs+0x71>
80106e2e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106e32:	74 44                	je     80106e78 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80106e34:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106e37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e41:	01 c2                	add    %eax,%edx
80106e43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e46:	8b 40 04             	mov    0x4(%eax),%eax
80106e49:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106e4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e4e:	8b 00                	mov    (%eax),%eax
80106e50:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106e53:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106e57:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106e5b:	7e c2                	jle    80106e1f <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106e5d:	eb 19                	jmp    80106e78 <getcallerpcs+0x71>
    pcs[i] = 0;
80106e5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106e62:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e69:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e6c:	01 d0                	add    %edx,%eax
80106e6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106e74:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106e78:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106e7c:	7e e1                	jle    80106e5f <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106e7e:	90                   	nop
80106e7f:	c9                   	leave  
80106e80:	c3                   	ret    

80106e81 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106e81:	55                   	push   %ebp
80106e82:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80106e84:	8b 45 08             	mov    0x8(%ebp),%eax
80106e87:	8b 00                	mov    (%eax),%eax
80106e89:	85 c0                	test   %eax,%eax
80106e8b:	74 17                	je     80106ea4 <holding+0x23>
80106e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e90:	8b 50 08             	mov    0x8(%eax),%edx
80106e93:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e99:	39 c2                	cmp    %eax,%edx
80106e9b:	75 07                	jne    80106ea4 <holding+0x23>
80106e9d:	b8 01 00 00 00       	mov    $0x1,%eax
80106ea2:	eb 05                	jmp    80106ea9 <holding+0x28>
80106ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ea9:	5d                   	pop    %ebp
80106eaa:	c3                   	ret    

80106eab <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106eab:	55                   	push   %ebp
80106eac:	89 e5                	mov    %esp,%ebp
80106eae:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106eb1:	e8 3e fe ff ff       	call   80106cf4 <readeflags>
80106eb6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80106eb9:	e8 46 fe ff ff       	call   80106d04 <cli>
  if(cpu->ncli++ == 0)
80106ebe:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ec5:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106ecb:	8d 48 01             	lea    0x1(%eax),%ecx
80106ece:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80106ed4:	85 c0                	test   %eax,%eax
80106ed6:	75 15                	jne    80106eed <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80106ed8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ede:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ee1:	81 e2 00 02 00 00    	and    $0x200,%edx
80106ee7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106eed:	90                   	nop
80106eee:	c9                   	leave  
80106eef:	c3                   	ret    

80106ef0 <popcli>:

void
popcli(void)
{
80106ef0:	55                   	push   %ebp
80106ef1:	89 e5                	mov    %esp,%ebp
80106ef3:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106ef6:	e8 f9 fd ff ff       	call   80106cf4 <readeflags>
80106efb:	25 00 02 00 00       	and    $0x200,%eax
80106f00:	85 c0                	test   %eax,%eax
80106f02:	74 0d                	je     80106f11 <popcli+0x21>
    panic("popcli - interruptible");
80106f04:	83 ec 0c             	sub    $0xc,%esp
80106f07:	68 78 ac 10 80       	push   $0x8010ac78
80106f0c:	e8 55 96 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106f11:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f17:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106f1d:	83 ea 01             	sub    $0x1,%edx
80106f20:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106f26:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106f2c:	85 c0                	test   %eax,%eax
80106f2e:	79 0d                	jns    80106f3d <popcli+0x4d>
    panic("popcli");
80106f30:	83 ec 0c             	sub    $0xc,%esp
80106f33:	68 8f ac 10 80       	push   $0x8010ac8f
80106f38:	e8 29 96 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106f3d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f43:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106f49:	85 c0                	test   %eax,%eax
80106f4b:	75 15                	jne    80106f62 <popcli+0x72>
80106f4d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f53:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106f59:	85 c0                	test   %eax,%eax
80106f5b:	74 05                	je     80106f62 <popcli+0x72>
    sti();
80106f5d:	e8 a9 fd ff ff       	call   80106d0b <sti>
}
80106f62:	90                   	nop
80106f63:	c9                   	leave  
80106f64:	c3                   	ret    

80106f65 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106f65:	55                   	push   %ebp
80106f66:	89 e5                	mov    %esp,%ebp
80106f68:	57                   	push   %edi
80106f69:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106f6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106f6d:	8b 55 10             	mov    0x10(%ebp),%edx
80106f70:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f73:	89 cb                	mov    %ecx,%ebx
80106f75:	89 df                	mov    %ebx,%edi
80106f77:	89 d1                	mov    %edx,%ecx
80106f79:	fc                   	cld    
80106f7a:	f3 aa                	rep stos %al,%es:(%edi)
80106f7c:	89 ca                	mov    %ecx,%edx
80106f7e:	89 fb                	mov    %edi,%ebx
80106f80:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106f83:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106f86:	90                   	nop
80106f87:	5b                   	pop    %ebx
80106f88:	5f                   	pop    %edi
80106f89:	5d                   	pop    %ebp
80106f8a:	c3                   	ret    

80106f8b <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106f8b:	55                   	push   %ebp
80106f8c:	89 e5                	mov    %esp,%ebp
80106f8e:	57                   	push   %edi
80106f8f:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106f93:	8b 55 10             	mov    0x10(%ebp),%edx
80106f96:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f99:	89 cb                	mov    %ecx,%ebx
80106f9b:	89 df                	mov    %ebx,%edi
80106f9d:	89 d1                	mov    %edx,%ecx
80106f9f:	fc                   	cld    
80106fa0:	f3 ab                	rep stos %eax,%es:(%edi)
80106fa2:	89 ca                	mov    %ecx,%edx
80106fa4:	89 fb                	mov    %edi,%ebx
80106fa6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106fa9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106fac:	90                   	nop
80106fad:	5b                   	pop    %ebx
80106fae:	5f                   	pop    %edi
80106faf:	5d                   	pop    %ebp
80106fb0:	c3                   	ret    

80106fb1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106fb1:	55                   	push   %ebp
80106fb2:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb7:	83 e0 03             	and    $0x3,%eax
80106fba:	85 c0                	test   %eax,%eax
80106fbc:	75 43                	jne    80107001 <memset+0x50>
80106fbe:	8b 45 10             	mov    0x10(%ebp),%eax
80106fc1:	83 e0 03             	and    $0x3,%eax
80106fc4:	85 c0                	test   %eax,%eax
80106fc6:	75 39                	jne    80107001 <memset+0x50>
    c &= 0xFF;
80106fc8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106fcf:	8b 45 10             	mov    0x10(%ebp),%eax
80106fd2:	c1 e8 02             	shr    $0x2,%eax
80106fd5:	89 c1                	mov    %eax,%ecx
80106fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fda:	c1 e0 18             	shl    $0x18,%eax
80106fdd:	89 c2                	mov    %eax,%edx
80106fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fe2:	c1 e0 10             	shl    $0x10,%eax
80106fe5:	09 c2                	or     %eax,%edx
80106fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fea:	c1 e0 08             	shl    $0x8,%eax
80106fed:	09 d0                	or     %edx,%eax
80106fef:	0b 45 0c             	or     0xc(%ebp),%eax
80106ff2:	51                   	push   %ecx
80106ff3:	50                   	push   %eax
80106ff4:	ff 75 08             	pushl  0x8(%ebp)
80106ff7:	e8 8f ff ff ff       	call   80106f8b <stosl>
80106ffc:	83 c4 0c             	add    $0xc,%esp
80106fff:	eb 12                	jmp    80107013 <memset+0x62>
  } else
    stosb(dst, c, n);
80107001:	8b 45 10             	mov    0x10(%ebp),%eax
80107004:	50                   	push   %eax
80107005:	ff 75 0c             	pushl  0xc(%ebp)
80107008:	ff 75 08             	pushl  0x8(%ebp)
8010700b:	e8 55 ff ff ff       	call   80106f65 <stosb>
80107010:	83 c4 0c             	add    $0xc,%esp
  return dst;
80107013:	8b 45 08             	mov    0x8(%ebp),%eax
}
80107016:	c9                   	leave  
80107017:	c3                   	ret    

80107018 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80107018:	55                   	push   %ebp
80107019:	89 e5                	mov    %esp,%ebp
8010701b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010701e:	8b 45 08             	mov    0x8(%ebp),%eax
80107021:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80107024:	8b 45 0c             	mov    0xc(%ebp),%eax
80107027:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010702a:	eb 30                	jmp    8010705c <memcmp+0x44>
    if(*s1 != *s2)
8010702c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010702f:	0f b6 10             	movzbl (%eax),%edx
80107032:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107035:	0f b6 00             	movzbl (%eax),%eax
80107038:	38 c2                	cmp    %al,%dl
8010703a:	74 18                	je     80107054 <memcmp+0x3c>
      return *s1 - *s2;
8010703c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010703f:	0f b6 00             	movzbl (%eax),%eax
80107042:	0f b6 d0             	movzbl %al,%edx
80107045:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107048:	0f b6 00             	movzbl (%eax),%eax
8010704b:	0f b6 c0             	movzbl %al,%eax
8010704e:	29 c2                	sub    %eax,%edx
80107050:	89 d0                	mov    %edx,%eax
80107052:	eb 1a                	jmp    8010706e <memcmp+0x56>
    s1++, s2++;
80107054:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107058:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010705c:	8b 45 10             	mov    0x10(%ebp),%eax
8010705f:	8d 50 ff             	lea    -0x1(%eax),%edx
80107062:	89 55 10             	mov    %edx,0x10(%ebp)
80107065:	85 c0                	test   %eax,%eax
80107067:	75 c3                	jne    8010702c <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80107069:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010706e:	c9                   	leave  
8010706f:	c3                   	ret    

80107070 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80107070:	55                   	push   %ebp
80107071:	89 e5                	mov    %esp,%ebp
80107073:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80107076:	8b 45 0c             	mov    0xc(%ebp),%eax
80107079:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010707c:	8b 45 08             	mov    0x8(%ebp),%eax
8010707f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80107082:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107085:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80107088:	73 54                	jae    801070de <memmove+0x6e>
8010708a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010708d:	8b 45 10             	mov    0x10(%ebp),%eax
80107090:	01 d0                	add    %edx,%eax
80107092:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80107095:	76 47                	jbe    801070de <memmove+0x6e>
    s += n;
80107097:	8b 45 10             	mov    0x10(%ebp),%eax
8010709a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010709d:	8b 45 10             	mov    0x10(%ebp),%eax
801070a0:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801070a3:	eb 13                	jmp    801070b8 <memmove+0x48>
      *--d = *--s;
801070a5:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801070a9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801070ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801070b0:	0f b6 10             	movzbl (%eax),%edx
801070b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801070b6:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801070b8:	8b 45 10             	mov    0x10(%ebp),%eax
801070bb:	8d 50 ff             	lea    -0x1(%eax),%edx
801070be:	89 55 10             	mov    %edx,0x10(%ebp)
801070c1:	85 c0                	test   %eax,%eax
801070c3:	75 e0                	jne    801070a5 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801070c5:	eb 24                	jmp    801070eb <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801070c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801070ca:	8d 50 01             	lea    0x1(%eax),%edx
801070cd:	89 55 f8             	mov    %edx,-0x8(%ebp)
801070d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801070d3:	8d 4a 01             	lea    0x1(%edx),%ecx
801070d6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801070d9:	0f b6 12             	movzbl (%edx),%edx
801070dc:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801070de:	8b 45 10             	mov    0x10(%ebp),%eax
801070e1:	8d 50 ff             	lea    -0x1(%eax),%edx
801070e4:	89 55 10             	mov    %edx,0x10(%ebp)
801070e7:	85 c0                	test   %eax,%eax
801070e9:	75 dc                	jne    801070c7 <memmove+0x57>
      *d++ = *s++;

  return dst;
801070eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801070ee:	c9                   	leave  
801070ef:	c3                   	ret    

801070f0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801070f0:	55                   	push   %ebp
801070f1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801070f3:	ff 75 10             	pushl  0x10(%ebp)
801070f6:	ff 75 0c             	pushl  0xc(%ebp)
801070f9:	ff 75 08             	pushl  0x8(%ebp)
801070fc:	e8 6f ff ff ff       	call   80107070 <memmove>
80107101:	83 c4 0c             	add    $0xc,%esp
}
80107104:	c9                   	leave  
80107105:	c3                   	ret    

80107106 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80107106:	55                   	push   %ebp
80107107:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80107109:	eb 0c                	jmp    80107117 <strncmp+0x11>
    n--, p++, q++;
8010710b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010710f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80107113:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80107117:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010711b:	74 1a                	je     80107137 <strncmp+0x31>
8010711d:	8b 45 08             	mov    0x8(%ebp),%eax
80107120:	0f b6 00             	movzbl (%eax),%eax
80107123:	84 c0                	test   %al,%al
80107125:	74 10                	je     80107137 <strncmp+0x31>
80107127:	8b 45 08             	mov    0x8(%ebp),%eax
8010712a:	0f b6 10             	movzbl (%eax),%edx
8010712d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107130:	0f b6 00             	movzbl (%eax),%eax
80107133:	38 c2                	cmp    %al,%dl
80107135:	74 d4                	je     8010710b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80107137:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010713b:	75 07                	jne    80107144 <strncmp+0x3e>
    return 0;
8010713d:	b8 00 00 00 00       	mov    $0x0,%eax
80107142:	eb 16                	jmp    8010715a <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80107144:	8b 45 08             	mov    0x8(%ebp),%eax
80107147:	0f b6 00             	movzbl (%eax),%eax
8010714a:	0f b6 d0             	movzbl %al,%edx
8010714d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107150:	0f b6 00             	movzbl (%eax),%eax
80107153:	0f b6 c0             	movzbl %al,%eax
80107156:	29 c2                	sub    %eax,%edx
80107158:	89 d0                	mov    %edx,%eax
}
8010715a:	5d                   	pop    %ebp
8010715b:	c3                   	ret    

8010715c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010715c:	55                   	push   %ebp
8010715d:	89 e5                	mov    %esp,%ebp
8010715f:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80107162:	8b 45 08             	mov    0x8(%ebp),%eax
80107165:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80107168:	90                   	nop
80107169:	8b 45 10             	mov    0x10(%ebp),%eax
8010716c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010716f:	89 55 10             	mov    %edx,0x10(%ebp)
80107172:	85 c0                	test   %eax,%eax
80107174:	7e 2c                	jle    801071a2 <strncpy+0x46>
80107176:	8b 45 08             	mov    0x8(%ebp),%eax
80107179:	8d 50 01             	lea    0x1(%eax),%edx
8010717c:	89 55 08             	mov    %edx,0x8(%ebp)
8010717f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107182:	8d 4a 01             	lea    0x1(%edx),%ecx
80107185:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80107188:	0f b6 12             	movzbl (%edx),%edx
8010718b:	88 10                	mov    %dl,(%eax)
8010718d:	0f b6 00             	movzbl (%eax),%eax
80107190:	84 c0                	test   %al,%al
80107192:	75 d5                	jne    80107169 <strncpy+0xd>
    ;
  while(n-- > 0)
80107194:	eb 0c                	jmp    801071a2 <strncpy+0x46>
    *s++ = 0;
80107196:	8b 45 08             	mov    0x8(%ebp),%eax
80107199:	8d 50 01             	lea    0x1(%eax),%edx
8010719c:	89 55 08             	mov    %edx,0x8(%ebp)
8010719f:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801071a2:	8b 45 10             	mov    0x10(%ebp),%eax
801071a5:	8d 50 ff             	lea    -0x1(%eax),%edx
801071a8:	89 55 10             	mov    %edx,0x10(%ebp)
801071ab:	85 c0                	test   %eax,%eax
801071ad:	7f e7                	jg     80107196 <strncpy+0x3a>
    *s++ = 0;
  return os;
801071af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801071b2:	c9                   	leave  
801071b3:	c3                   	ret    

801071b4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801071b4:	55                   	push   %ebp
801071b5:	89 e5                	mov    %esp,%ebp
801071b7:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801071ba:	8b 45 08             	mov    0x8(%ebp),%eax
801071bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801071c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071c4:	7f 05                	jg     801071cb <safestrcpy+0x17>
    return os;
801071c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801071c9:	eb 31                	jmp    801071fc <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801071cb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801071cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071d3:	7e 1e                	jle    801071f3 <safestrcpy+0x3f>
801071d5:	8b 45 08             	mov    0x8(%ebp),%eax
801071d8:	8d 50 01             	lea    0x1(%eax),%edx
801071db:	89 55 08             	mov    %edx,0x8(%ebp)
801071de:	8b 55 0c             	mov    0xc(%ebp),%edx
801071e1:	8d 4a 01             	lea    0x1(%edx),%ecx
801071e4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801071e7:	0f b6 12             	movzbl (%edx),%edx
801071ea:	88 10                	mov    %dl,(%eax)
801071ec:	0f b6 00             	movzbl (%eax),%eax
801071ef:	84 c0                	test   %al,%al
801071f1:	75 d8                	jne    801071cb <safestrcpy+0x17>
    ;
  *s = 0;
801071f3:	8b 45 08             	mov    0x8(%ebp),%eax
801071f6:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801071f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801071fc:	c9                   	leave  
801071fd:	c3                   	ret    

801071fe <strlen>:

int
strlen(const char *s)
{
801071fe:	55                   	push   %ebp
801071ff:	89 e5                	mov    %esp,%ebp
80107201:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80107204:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010720b:	eb 04                	jmp    80107211 <strlen+0x13>
8010720d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107211:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107214:	8b 45 08             	mov    0x8(%ebp),%eax
80107217:	01 d0                	add    %edx,%eax
80107219:	0f b6 00             	movzbl (%eax),%eax
8010721c:	84 c0                	test   %al,%al
8010721e:	75 ed                	jne    8010720d <strlen+0xf>
    ;
  return n;
80107220:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107223:	c9                   	leave  
80107224:	c3                   	ret    

80107225 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80107225:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80107229:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010722d:	55                   	push   %ebp
  pushl %ebx
8010722e:	53                   	push   %ebx
  pushl %esi
8010722f:	56                   	push   %esi
  pushl %edi
80107230:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80107231:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80107233:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80107235:	5f                   	pop    %edi
  popl %esi
80107236:	5e                   	pop    %esi
  popl %ebx
80107237:	5b                   	pop    %ebx
  popl %ebp
80107238:	5d                   	pop    %ebp
  ret
80107239:	c3                   	ret    

8010723a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010723a:	55                   	push   %ebp
8010723b:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010723d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107243:	8b 00                	mov    (%eax),%eax
80107245:	3b 45 08             	cmp    0x8(%ebp),%eax
80107248:	76 12                	jbe    8010725c <fetchint+0x22>
8010724a:	8b 45 08             	mov    0x8(%ebp),%eax
8010724d:	8d 50 04             	lea    0x4(%eax),%edx
80107250:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107256:	8b 00                	mov    (%eax),%eax
80107258:	39 c2                	cmp    %eax,%edx
8010725a:	76 07                	jbe    80107263 <fetchint+0x29>
    return -1;
8010725c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107261:	eb 0f                	jmp    80107272 <fetchint+0x38>
  *ip = *(int*)(addr);
80107263:	8b 45 08             	mov    0x8(%ebp),%eax
80107266:	8b 10                	mov    (%eax),%edx
80107268:	8b 45 0c             	mov    0xc(%ebp),%eax
8010726b:	89 10                	mov    %edx,(%eax)
  return 0;
8010726d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107272:	5d                   	pop    %ebp
80107273:	c3                   	ret    

80107274 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80107274:	55                   	push   %ebp
80107275:	89 e5                	mov    %esp,%ebp
80107277:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010727a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107280:	8b 00                	mov    (%eax),%eax
80107282:	3b 45 08             	cmp    0x8(%ebp),%eax
80107285:	77 07                	ja     8010728e <fetchstr+0x1a>
    return -1;
80107287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010728c:	eb 46                	jmp    801072d4 <fetchstr+0x60>
  *pp = (char*)addr;
8010728e:	8b 55 08             	mov    0x8(%ebp),%edx
80107291:	8b 45 0c             	mov    0xc(%ebp),%eax
80107294:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80107296:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010729c:	8b 00                	mov    (%eax),%eax
8010729e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801072a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801072a4:	8b 00                	mov    (%eax),%eax
801072a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
801072a9:	eb 1c                	jmp    801072c7 <fetchstr+0x53>
    if(*s == 0)
801072ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801072ae:	0f b6 00             	movzbl (%eax),%eax
801072b1:	84 c0                	test   %al,%al
801072b3:	75 0e                	jne    801072c3 <fetchstr+0x4f>
      return s - *pp;
801072b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801072b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801072bb:	8b 00                	mov    (%eax),%eax
801072bd:	29 c2                	sub    %eax,%edx
801072bf:	89 d0                	mov    %edx,%eax
801072c1:	eb 11                	jmp    801072d4 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801072c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801072c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801072ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801072cd:	72 dc                	jb     801072ab <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801072cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801072d4:	c9                   	leave  
801072d5:	c3                   	ret    

801072d6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801072d6:	55                   	push   %ebp
801072d7:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801072d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072df:	8b 40 18             	mov    0x18(%eax),%eax
801072e2:	8b 40 44             	mov    0x44(%eax),%eax
801072e5:	8b 55 08             	mov    0x8(%ebp),%edx
801072e8:	c1 e2 02             	shl    $0x2,%edx
801072eb:	01 d0                	add    %edx,%eax
801072ed:	83 c0 04             	add    $0x4,%eax
801072f0:	ff 75 0c             	pushl  0xc(%ebp)
801072f3:	50                   	push   %eax
801072f4:	e8 41 ff ff ff       	call   8010723a <fetchint>
801072f9:	83 c4 08             	add    $0x8,%esp
}
801072fc:	c9                   	leave  
801072fd:	c3                   	ret    

801072fe <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801072fe:	55                   	push   %ebp
801072ff:	89 e5                	mov    %esp,%ebp
80107301:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80107304:	8d 45 fc             	lea    -0x4(%ebp),%eax
80107307:	50                   	push   %eax
80107308:	ff 75 08             	pushl  0x8(%ebp)
8010730b:	e8 c6 ff ff ff       	call   801072d6 <argint>
80107310:	83 c4 08             	add    $0x8,%esp
80107313:	85 c0                	test   %eax,%eax
80107315:	79 07                	jns    8010731e <argptr+0x20>
    return -1;
80107317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010731c:	eb 3b                	jmp    80107359 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010731e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107324:	8b 00                	mov    (%eax),%eax
80107326:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107329:	39 d0                	cmp    %edx,%eax
8010732b:	76 16                	jbe    80107343 <argptr+0x45>
8010732d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107330:	89 c2                	mov    %eax,%edx
80107332:	8b 45 10             	mov    0x10(%ebp),%eax
80107335:	01 c2                	add    %eax,%edx
80107337:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010733d:	8b 00                	mov    (%eax),%eax
8010733f:	39 c2                	cmp    %eax,%edx
80107341:	76 07                	jbe    8010734a <argptr+0x4c>
    return -1;
80107343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107348:	eb 0f                	jmp    80107359 <argptr+0x5b>
  *pp = (char*)i;
8010734a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010734d:	89 c2                	mov    %eax,%edx
8010734f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107352:	89 10                	mov    %edx,(%eax)
  return 0;
80107354:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107359:	c9                   	leave  
8010735a:	c3                   	ret    

8010735b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010735b:	55                   	push   %ebp
8010735c:	89 e5                	mov    %esp,%ebp
8010735e:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80107361:	8d 45 fc             	lea    -0x4(%ebp),%eax
80107364:	50                   	push   %eax
80107365:	ff 75 08             	pushl  0x8(%ebp)
80107368:	e8 69 ff ff ff       	call   801072d6 <argint>
8010736d:	83 c4 08             	add    $0x8,%esp
80107370:	85 c0                	test   %eax,%eax
80107372:	79 07                	jns    8010737b <argstr+0x20>
    return -1;
80107374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107379:	eb 0f                	jmp    8010738a <argstr+0x2f>
  return fetchstr(addr, pp);
8010737b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010737e:	ff 75 0c             	pushl  0xc(%ebp)
80107381:	50                   	push   %eax
80107382:	e8 ed fe ff ff       	call   80107274 <fetchstr>
80107387:	83 c4 08             	add    $0x8,%esp
}
8010738a:	c9                   	leave  
8010738b:	c3                   	ret    

8010738c <syscall>:
// put data structure for printing out system call invocation information here

#endif
void
syscall(void)
{
8010738c:	55                   	push   %ebp
8010738d:	89 e5                	mov    %esp,%ebp
8010738f:	53                   	push   %ebx
80107390:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80107393:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107399:	8b 40 18             	mov    0x18(%eax),%eax
8010739c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010739f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801073a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801073a6:	7e 30                	jle    801073d8 <syscall+0x4c>
801073a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ab:	83 f8 1e             	cmp    $0x1e,%eax
801073ae:	77 28                	ja     801073d8 <syscall+0x4c>
801073b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b3:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
801073ba:	85 c0                	test   %eax,%eax
801073bc:	74 1a                	je     801073d8 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801073be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c4:	8b 58 18             	mov    0x18(%eax),%ebx
801073c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ca:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
801073d1:	ff d0                	call   *%eax
801073d3:	89 43 1c             	mov    %eax,0x1c(%ebx)
801073d6:	eb 34                	jmp    8010740c <syscall+0x80>
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801073d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073de:	8d 50 6c             	lea    0x6c(%eax),%edx
801073e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
#ifdef PRINT_SYSCALLS
    cprintf("\n %s-> %d \n", syscallnames[num], num); 
#endif
    // some code goes here
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801073e7:	8b 40 10             	mov    0x10(%eax),%eax
801073ea:	ff 75 f4             	pushl  -0xc(%ebp)
801073ed:	52                   	push   %edx
801073ee:	50                   	push   %eax
801073ef:	68 96 ac 10 80       	push   $0x8010ac96
801073f4:	e8 cd 8f ff ff       	call   801003c6 <cprintf>
801073f9:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801073fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107402:	8b 40 18             	mov    0x18(%eax),%eax
80107405:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010740c:	90                   	nop
8010740d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107410:	c9                   	leave  
80107411:	c3                   	ret    

80107412 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80107412:	55                   	push   %ebp
80107413:	89 e5                	mov    %esp,%ebp
80107415:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80107418:	83 ec 08             	sub    $0x8,%esp
8010741b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010741e:	50                   	push   %eax
8010741f:	ff 75 08             	pushl  0x8(%ebp)
80107422:	e8 af fe ff ff       	call   801072d6 <argint>
80107427:	83 c4 10             	add    $0x10,%esp
8010742a:	85 c0                	test   %eax,%eax
8010742c:	79 07                	jns    80107435 <argfd+0x23>
    return -1;
8010742e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107433:	eb 50                	jmp    80107485 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80107435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107438:	85 c0                	test   %eax,%eax
8010743a:	78 21                	js     8010745d <argfd+0x4b>
8010743c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010743f:	83 f8 0f             	cmp    $0xf,%eax
80107442:	7f 19                	jg     8010745d <argfd+0x4b>
80107444:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010744a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010744d:	83 c2 08             	add    $0x8,%edx
80107450:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80107454:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107457:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010745b:	75 07                	jne    80107464 <argfd+0x52>
    return -1;
8010745d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107462:	eb 21                	jmp    80107485 <argfd+0x73>
  if(pfd)
80107464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80107468:	74 08                	je     80107472 <argfd+0x60>
    *pfd = fd;
8010746a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010746d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107470:	89 10                	mov    %edx,(%eax)
  if(pf)
80107472:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107476:	74 08                	je     80107480 <argfd+0x6e>
    *pf = f;
80107478:	8b 45 10             	mov    0x10(%ebp),%eax
8010747b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010747e:	89 10                	mov    %edx,(%eax)
  return 0;
80107480:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107485:	c9                   	leave  
80107486:	c3                   	ret    

80107487 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80107487:	55                   	push   %ebp
80107488:	89 e5                	mov    %esp,%ebp
8010748a:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010748d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107494:	eb 30                	jmp    801074c6 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80107496:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010749c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010749f:	83 c2 08             	add    $0x8,%edx
801074a2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801074a6:	85 c0                	test   %eax,%eax
801074a8:	75 18                	jne    801074c2 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801074aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801074b3:	8d 4a 08             	lea    0x8(%edx),%ecx
801074b6:	8b 55 08             	mov    0x8(%ebp),%edx
801074b9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801074bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074c0:	eb 0f                	jmp    801074d1 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801074c2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801074c6:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801074ca:	7e ca                	jle    80107496 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801074cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801074d1:	c9                   	leave  
801074d2:	c3                   	ret    

801074d3 <sys_dup>:

int
sys_dup(void)
{
801074d3:	55                   	push   %ebp
801074d4:	89 e5                	mov    %esp,%ebp
801074d6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801074d9:	83 ec 04             	sub    $0x4,%esp
801074dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801074df:	50                   	push   %eax
801074e0:	6a 00                	push   $0x0
801074e2:	6a 00                	push   $0x0
801074e4:	e8 29 ff ff ff       	call   80107412 <argfd>
801074e9:	83 c4 10             	add    $0x10,%esp
801074ec:	85 c0                	test   %eax,%eax
801074ee:	79 07                	jns    801074f7 <sys_dup+0x24>
    return -1;
801074f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074f5:	eb 31                	jmp    80107528 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801074f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074fa:	83 ec 0c             	sub    $0xc,%esp
801074fd:	50                   	push   %eax
801074fe:	e8 84 ff ff ff       	call   80107487 <fdalloc>
80107503:	83 c4 10             	add    $0x10,%esp
80107506:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107509:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010750d:	79 07                	jns    80107516 <sys_dup+0x43>
    return -1;
8010750f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107514:	eb 12                	jmp    80107528 <sys_dup+0x55>
  filedup(f);
80107516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107519:	83 ec 0c             	sub    $0xc,%esp
8010751c:	50                   	push   %eax
8010751d:	e8 0a 9c ff ff       	call   8010112c <filedup>
80107522:	83 c4 10             	add    $0x10,%esp
  return fd;
80107525:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107528:	c9                   	leave  
80107529:	c3                   	ret    

8010752a <sys_read>:

int
sys_read(void)
{
8010752a:	55                   	push   %ebp
8010752b:	89 e5                	mov    %esp,%ebp
8010752d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107530:	83 ec 04             	sub    $0x4,%esp
80107533:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107536:	50                   	push   %eax
80107537:	6a 00                	push   $0x0
80107539:	6a 00                	push   $0x0
8010753b:	e8 d2 fe ff ff       	call   80107412 <argfd>
80107540:	83 c4 10             	add    $0x10,%esp
80107543:	85 c0                	test   %eax,%eax
80107545:	78 2e                	js     80107575 <sys_read+0x4b>
80107547:	83 ec 08             	sub    $0x8,%esp
8010754a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010754d:	50                   	push   %eax
8010754e:	6a 02                	push   $0x2
80107550:	e8 81 fd ff ff       	call   801072d6 <argint>
80107555:	83 c4 10             	add    $0x10,%esp
80107558:	85 c0                	test   %eax,%eax
8010755a:	78 19                	js     80107575 <sys_read+0x4b>
8010755c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010755f:	83 ec 04             	sub    $0x4,%esp
80107562:	50                   	push   %eax
80107563:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107566:	50                   	push   %eax
80107567:	6a 01                	push   $0x1
80107569:	e8 90 fd ff ff       	call   801072fe <argptr>
8010756e:	83 c4 10             	add    $0x10,%esp
80107571:	85 c0                	test   %eax,%eax
80107573:	79 07                	jns    8010757c <sys_read+0x52>
    return -1;
80107575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010757a:	eb 17                	jmp    80107593 <sys_read+0x69>
  return fileread(f, p, n);
8010757c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010757f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107585:	83 ec 04             	sub    $0x4,%esp
80107588:	51                   	push   %ecx
80107589:	52                   	push   %edx
8010758a:	50                   	push   %eax
8010758b:	e8 2c 9d ff ff       	call   801012bc <fileread>
80107590:	83 c4 10             	add    $0x10,%esp
}
80107593:	c9                   	leave  
80107594:	c3                   	ret    

80107595 <sys_write>:

int
sys_write(void)
{
80107595:	55                   	push   %ebp
80107596:	89 e5                	mov    %esp,%ebp
80107598:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010759b:	83 ec 04             	sub    $0x4,%esp
8010759e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801075a1:	50                   	push   %eax
801075a2:	6a 00                	push   $0x0
801075a4:	6a 00                	push   $0x0
801075a6:	e8 67 fe ff ff       	call   80107412 <argfd>
801075ab:	83 c4 10             	add    $0x10,%esp
801075ae:	85 c0                	test   %eax,%eax
801075b0:	78 2e                	js     801075e0 <sys_write+0x4b>
801075b2:	83 ec 08             	sub    $0x8,%esp
801075b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801075b8:	50                   	push   %eax
801075b9:	6a 02                	push   $0x2
801075bb:	e8 16 fd ff ff       	call   801072d6 <argint>
801075c0:	83 c4 10             	add    $0x10,%esp
801075c3:	85 c0                	test   %eax,%eax
801075c5:	78 19                	js     801075e0 <sys_write+0x4b>
801075c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075ca:	83 ec 04             	sub    $0x4,%esp
801075cd:	50                   	push   %eax
801075ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
801075d1:	50                   	push   %eax
801075d2:	6a 01                	push   $0x1
801075d4:	e8 25 fd ff ff       	call   801072fe <argptr>
801075d9:	83 c4 10             	add    $0x10,%esp
801075dc:	85 c0                	test   %eax,%eax
801075de:	79 07                	jns    801075e7 <sys_write+0x52>
    return -1;
801075e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075e5:	eb 17                	jmp    801075fe <sys_write+0x69>
  return filewrite(f, p, n);
801075e7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801075ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
801075ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f0:	83 ec 04             	sub    $0x4,%esp
801075f3:	51                   	push   %ecx
801075f4:	52                   	push   %edx
801075f5:	50                   	push   %eax
801075f6:	e8 79 9d ff ff       	call   80101374 <filewrite>
801075fb:	83 c4 10             	add    $0x10,%esp
}
801075fe:	c9                   	leave  
801075ff:	c3                   	ret    

80107600 <sys_close>:

int
sys_close(void)
{
80107600:	55                   	push   %ebp
80107601:	89 e5                	mov    %esp,%ebp
80107603:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80107606:	83 ec 04             	sub    $0x4,%esp
80107609:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010760c:	50                   	push   %eax
8010760d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107610:	50                   	push   %eax
80107611:	6a 00                	push   $0x0
80107613:	e8 fa fd ff ff       	call   80107412 <argfd>
80107618:	83 c4 10             	add    $0x10,%esp
8010761b:	85 c0                	test   %eax,%eax
8010761d:	79 07                	jns    80107626 <sys_close+0x26>
    return -1;
8010761f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107624:	eb 28                	jmp    8010764e <sys_close+0x4e>
  proc->ofile[fd] = 0;
80107626:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010762c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010762f:	83 c2 08             	add    $0x8,%edx
80107632:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107639:	00 
  fileclose(f);
8010763a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010763d:	83 ec 0c             	sub    $0xc,%esp
80107640:	50                   	push   %eax
80107641:	e8 37 9b ff ff       	call   8010117d <fileclose>
80107646:	83 c4 10             	add    $0x10,%esp
  return 0;
80107649:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010764e:	c9                   	leave  
8010764f:	c3                   	ret    

80107650 <sys_fstat>:

int
sys_fstat(void)
{
80107650:	55                   	push   %ebp
80107651:	89 e5                	mov    %esp,%ebp
80107653:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80107656:	83 ec 04             	sub    $0x4,%esp
80107659:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010765c:	50                   	push   %eax
8010765d:	6a 00                	push   $0x0
8010765f:	6a 00                	push   $0x0
80107661:	e8 ac fd ff ff       	call   80107412 <argfd>
80107666:	83 c4 10             	add    $0x10,%esp
80107669:	85 c0                	test   %eax,%eax
8010766b:	78 17                	js     80107684 <sys_fstat+0x34>
8010766d:	83 ec 04             	sub    $0x4,%esp
80107670:	6a 1c                	push   $0x1c
80107672:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107675:	50                   	push   %eax
80107676:	6a 01                	push   $0x1
80107678:	e8 81 fc ff ff       	call   801072fe <argptr>
8010767d:	83 c4 10             	add    $0x10,%esp
80107680:	85 c0                	test   %eax,%eax
80107682:	79 07                	jns    8010768b <sys_fstat+0x3b>
    return -1;
80107684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107689:	eb 13                	jmp    8010769e <sys_fstat+0x4e>
  return filestat(f, st);
8010768b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010768e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107691:	83 ec 08             	sub    $0x8,%esp
80107694:	52                   	push   %edx
80107695:	50                   	push   %eax
80107696:	e8 ca 9b ff ff       	call   80101265 <filestat>
8010769b:	83 c4 10             	add    $0x10,%esp
}
8010769e:	c9                   	leave  
8010769f:	c3                   	ret    

801076a0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801076a0:	55                   	push   %ebp
801076a1:	89 e5                	mov    %esp,%ebp
801076a3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801076a6:	83 ec 08             	sub    $0x8,%esp
801076a9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801076ac:	50                   	push   %eax
801076ad:	6a 00                	push   $0x0
801076af:	e8 a7 fc ff ff       	call   8010735b <argstr>
801076b4:	83 c4 10             	add    $0x10,%esp
801076b7:	85 c0                	test   %eax,%eax
801076b9:	78 15                	js     801076d0 <sys_link+0x30>
801076bb:	83 ec 08             	sub    $0x8,%esp
801076be:	8d 45 dc             	lea    -0x24(%ebp),%eax
801076c1:	50                   	push   %eax
801076c2:	6a 01                	push   $0x1
801076c4:	e8 92 fc ff ff       	call   8010735b <argstr>
801076c9:	83 c4 10             	add    $0x10,%esp
801076cc:	85 c0                	test   %eax,%eax
801076ce:	79 0a                	jns    801076da <sys_link+0x3a>
    return -1;
801076d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076d5:	e9 68 01 00 00       	jmp    80107842 <sys_link+0x1a2>

  begin_op();
801076da:	e8 cf c1 ff ff       	call   801038ae <begin_op>
  if((ip = namei(old)) == 0){
801076df:	8b 45 d8             	mov    -0x28(%ebp),%eax
801076e2:	83 ec 0c             	sub    $0xc,%esp
801076e5:	50                   	push   %eax
801076e6:	e8 fd af ff ff       	call   801026e8 <namei>
801076eb:	83 c4 10             	add    $0x10,%esp
801076ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076f5:	75 0f                	jne    80107706 <sys_link+0x66>
    end_op();
801076f7:	e8 3e c2 ff ff       	call   8010393a <end_op>
    return -1;
801076fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107701:	e9 3c 01 00 00       	jmp    80107842 <sys_link+0x1a2>
  }

  ilock(ip);
80107706:	83 ec 0c             	sub    $0xc,%esp
80107709:	ff 75 f4             	pushl  -0xc(%ebp)
8010770c:	e8 c9 a3 ff ff       	call   80101ada <ilock>
80107711:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80107714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107717:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010771b:	66 83 f8 01          	cmp    $0x1,%ax
8010771f:	75 1d                	jne    8010773e <sys_link+0x9e>
    iunlockput(ip);
80107721:	83 ec 0c             	sub    $0xc,%esp
80107724:	ff 75 f4             	pushl  -0xc(%ebp)
80107727:	e8 96 a6 ff ff       	call   80101dc2 <iunlockput>
8010772c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010772f:	e8 06 c2 ff ff       	call   8010393a <end_op>
    return -1;
80107734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107739:	e9 04 01 00 00       	jmp    80107842 <sys_link+0x1a2>
  }

  ip->nlink++;
8010773e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107741:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107745:	83 c0 01             	add    $0x1,%eax
80107748:	89 c2                	mov    %eax,%edx
8010774a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107751:	83 ec 0c             	sub    $0xc,%esp
80107754:	ff 75 f4             	pushl  -0xc(%ebp)
80107757:	e8 7c a1 ff ff       	call   801018d8 <iupdate>
8010775c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010775f:	83 ec 0c             	sub    $0xc,%esp
80107762:	ff 75 f4             	pushl  -0xc(%ebp)
80107765:	e8 f6 a4 ff ff       	call   80101c60 <iunlock>
8010776a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010776d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107770:	83 ec 08             	sub    $0x8,%esp
80107773:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80107776:	52                   	push   %edx
80107777:	50                   	push   %eax
80107778:	e8 87 af ff ff       	call   80102704 <nameiparent>
8010777d:	83 c4 10             	add    $0x10,%esp
80107780:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107783:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107787:	74 71                	je     801077fa <sys_link+0x15a>
    goto bad;
  ilock(dp);
80107789:	83 ec 0c             	sub    $0xc,%esp
8010778c:	ff 75 f0             	pushl  -0x10(%ebp)
8010778f:	e8 46 a3 ff ff       	call   80101ada <ilock>
80107794:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80107797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010779a:	8b 10                	mov    (%eax),%edx
8010779c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779f:	8b 00                	mov    (%eax),%eax
801077a1:	39 c2                	cmp    %eax,%edx
801077a3:	75 1d                	jne    801077c2 <sys_link+0x122>
801077a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a8:	8b 40 04             	mov    0x4(%eax),%eax
801077ab:	83 ec 04             	sub    $0x4,%esp
801077ae:	50                   	push   %eax
801077af:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801077b2:	50                   	push   %eax
801077b3:	ff 75 f0             	pushl  -0x10(%ebp)
801077b6:	e8 91 ac ff ff       	call   8010244c <dirlink>
801077bb:	83 c4 10             	add    $0x10,%esp
801077be:	85 c0                	test   %eax,%eax
801077c0:	79 10                	jns    801077d2 <sys_link+0x132>
    iunlockput(dp);
801077c2:	83 ec 0c             	sub    $0xc,%esp
801077c5:	ff 75 f0             	pushl  -0x10(%ebp)
801077c8:	e8 f5 a5 ff ff       	call   80101dc2 <iunlockput>
801077cd:	83 c4 10             	add    $0x10,%esp
    goto bad;
801077d0:	eb 29                	jmp    801077fb <sys_link+0x15b>
  }
  iunlockput(dp);
801077d2:	83 ec 0c             	sub    $0xc,%esp
801077d5:	ff 75 f0             	pushl  -0x10(%ebp)
801077d8:	e8 e5 a5 ff ff       	call   80101dc2 <iunlockput>
801077dd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801077e0:	83 ec 0c             	sub    $0xc,%esp
801077e3:	ff 75 f4             	pushl  -0xc(%ebp)
801077e6:	e8 e7 a4 ff ff       	call   80101cd2 <iput>
801077eb:	83 c4 10             	add    $0x10,%esp

  end_op();
801077ee:	e8 47 c1 ff ff       	call   8010393a <end_op>

  return 0;
801077f3:	b8 00 00 00 00       	mov    $0x0,%eax
801077f8:	eb 48                	jmp    80107842 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801077fa:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801077fb:	83 ec 0c             	sub    $0xc,%esp
801077fe:	ff 75 f4             	pushl  -0xc(%ebp)
80107801:	e8 d4 a2 ff ff       	call   80101ada <ilock>
80107806:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80107809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107810:	83 e8 01             	sub    $0x1,%eax
80107813:	89 c2                	mov    %eax,%edx
80107815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107818:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010781c:	83 ec 0c             	sub    $0xc,%esp
8010781f:	ff 75 f4             	pushl  -0xc(%ebp)
80107822:	e8 b1 a0 ff ff       	call   801018d8 <iupdate>
80107827:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010782a:	83 ec 0c             	sub    $0xc,%esp
8010782d:	ff 75 f4             	pushl  -0xc(%ebp)
80107830:	e8 8d a5 ff ff       	call   80101dc2 <iunlockput>
80107835:	83 c4 10             	add    $0x10,%esp
  end_op();
80107838:	e8 fd c0 ff ff       	call   8010393a <end_op>
  return -1;
8010783d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107842:	c9                   	leave  
80107843:	c3                   	ret    

80107844 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80107844:	55                   	push   %ebp
80107845:	89 e5                	mov    %esp,%ebp
80107847:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010784a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80107851:	eb 40                	jmp    80107893 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	6a 10                	push   $0x10
80107858:	50                   	push   %eax
80107859:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010785c:	50                   	push   %eax
8010785d:	ff 75 08             	pushl  0x8(%ebp)
80107860:	e8 33 a8 ff ff       	call   80102098 <readi>
80107865:	83 c4 10             	add    $0x10,%esp
80107868:	83 f8 10             	cmp    $0x10,%eax
8010786b:	74 0d                	je     8010787a <isdirempty+0x36>
      panic("isdirempty: readi");
8010786d:	83 ec 0c             	sub    $0xc,%esp
80107870:	68 b4 ac 10 80       	push   $0x8010acb4
80107875:	e8 ec 8c ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010787a:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010787e:	66 85 c0             	test   %ax,%ax
80107881:	74 07                	je     8010788a <isdirempty+0x46>
      return 0;
80107883:	b8 00 00 00 00       	mov    $0x0,%eax
80107888:	eb 1b                	jmp    801078a5 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	83 c0 10             	add    $0x10,%eax
80107890:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107893:	8b 45 08             	mov    0x8(%ebp),%eax
80107896:	8b 50 20             	mov    0x20(%eax),%edx
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	39 c2                	cmp    %eax,%edx
8010789e:	77 b3                	ja     80107853 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801078a0:	b8 01 00 00 00       	mov    $0x1,%eax
}
801078a5:	c9                   	leave  
801078a6:	c3                   	ret    

801078a7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801078a7:	55                   	push   %ebp
801078a8:	89 e5                	mov    %esp,%ebp
801078aa:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801078ad:	83 ec 08             	sub    $0x8,%esp
801078b0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801078b3:	50                   	push   %eax
801078b4:	6a 00                	push   $0x0
801078b6:	e8 a0 fa ff ff       	call   8010735b <argstr>
801078bb:	83 c4 10             	add    $0x10,%esp
801078be:	85 c0                	test   %eax,%eax
801078c0:	79 0a                	jns    801078cc <sys_unlink+0x25>
    return -1;
801078c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078c7:	e9 bc 01 00 00       	jmp    80107a88 <sys_unlink+0x1e1>

  begin_op();
801078cc:	e8 dd bf ff ff       	call   801038ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801078d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801078d4:	83 ec 08             	sub    $0x8,%esp
801078d7:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801078da:	52                   	push   %edx
801078db:	50                   	push   %eax
801078dc:	e8 23 ae ff ff       	call   80102704 <nameiparent>
801078e1:	83 c4 10             	add    $0x10,%esp
801078e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078eb:	75 0f                	jne    801078fc <sys_unlink+0x55>
    end_op();
801078ed:	e8 48 c0 ff ff       	call   8010393a <end_op>
    return -1;
801078f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078f7:	e9 8c 01 00 00       	jmp    80107a88 <sys_unlink+0x1e1>
  }

  ilock(dp);
801078fc:	83 ec 0c             	sub    $0xc,%esp
801078ff:	ff 75 f4             	pushl  -0xc(%ebp)
80107902:	e8 d3 a1 ff ff       	call   80101ada <ilock>
80107907:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010790a:	83 ec 08             	sub    $0x8,%esp
8010790d:	68 c6 ac 10 80       	push   $0x8010acc6
80107912:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107915:	50                   	push   %eax
80107916:	e8 5c aa ff ff       	call   80102377 <namecmp>
8010791b:	83 c4 10             	add    $0x10,%esp
8010791e:	85 c0                	test   %eax,%eax
80107920:	0f 84 4a 01 00 00    	je     80107a70 <sys_unlink+0x1c9>
80107926:	83 ec 08             	sub    $0x8,%esp
80107929:	68 c8 ac 10 80       	push   $0x8010acc8
8010792e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107931:	50                   	push   %eax
80107932:	e8 40 aa ff ff       	call   80102377 <namecmp>
80107937:	83 c4 10             	add    $0x10,%esp
8010793a:	85 c0                	test   %eax,%eax
8010793c:	0f 84 2e 01 00 00    	je     80107a70 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80107942:	83 ec 04             	sub    $0x4,%esp
80107945:	8d 45 c8             	lea    -0x38(%ebp),%eax
80107948:	50                   	push   %eax
80107949:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010794c:	50                   	push   %eax
8010794d:	ff 75 f4             	pushl  -0xc(%ebp)
80107950:	e8 3d aa ff ff       	call   80102392 <dirlookup>
80107955:	83 c4 10             	add    $0x10,%esp
80107958:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010795b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010795f:	0f 84 0a 01 00 00    	je     80107a6f <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80107965:	83 ec 0c             	sub    $0xc,%esp
80107968:	ff 75 f0             	pushl  -0x10(%ebp)
8010796b:	e8 6a a1 ff ff       	call   80101ada <ilock>
80107970:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80107973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107976:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010797a:	66 85 c0             	test   %ax,%ax
8010797d:	7f 0d                	jg     8010798c <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010797f:	83 ec 0c             	sub    $0xc,%esp
80107982:	68 cb ac 10 80       	push   $0x8010accb
80107987:	e8 da 8b ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010798c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010798f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107993:	66 83 f8 01          	cmp    $0x1,%ax
80107997:	75 25                	jne    801079be <sys_unlink+0x117>
80107999:	83 ec 0c             	sub    $0xc,%esp
8010799c:	ff 75 f0             	pushl  -0x10(%ebp)
8010799f:	e8 a0 fe ff ff       	call   80107844 <isdirempty>
801079a4:	83 c4 10             	add    $0x10,%esp
801079a7:	85 c0                	test   %eax,%eax
801079a9:	75 13                	jne    801079be <sys_unlink+0x117>
    iunlockput(ip);
801079ab:	83 ec 0c             	sub    $0xc,%esp
801079ae:	ff 75 f0             	pushl  -0x10(%ebp)
801079b1:	e8 0c a4 ff ff       	call   80101dc2 <iunlockput>
801079b6:	83 c4 10             	add    $0x10,%esp
    goto bad;
801079b9:	e9 b2 00 00 00       	jmp    80107a70 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801079be:	83 ec 04             	sub    $0x4,%esp
801079c1:	6a 10                	push   $0x10
801079c3:	6a 00                	push   $0x0
801079c5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801079c8:	50                   	push   %eax
801079c9:	e8 e3 f5 ff ff       	call   80106fb1 <memset>
801079ce:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801079d1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801079d4:	6a 10                	push   $0x10
801079d6:	50                   	push   %eax
801079d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801079da:	50                   	push   %eax
801079db:	ff 75 f4             	pushl  -0xc(%ebp)
801079de:	e8 0c a8 ff ff       	call   801021ef <writei>
801079e3:	83 c4 10             	add    $0x10,%esp
801079e6:	83 f8 10             	cmp    $0x10,%eax
801079e9:	74 0d                	je     801079f8 <sys_unlink+0x151>
    panic("unlink: writei");
801079eb:	83 ec 0c             	sub    $0xc,%esp
801079ee:	68 dd ac 10 80       	push   $0x8010acdd
801079f3:	e8 6e 8b ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801079f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079fb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801079ff:	66 83 f8 01          	cmp    $0x1,%ax
80107a03:	75 21                	jne    80107a26 <sys_unlink+0x17f>
    dp->nlink--;
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107a0c:	83 e8 01             	sub    $0x1,%eax
80107a0f:	89 c2                	mov    %eax,%edx
80107a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a14:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107a18:	83 ec 0c             	sub    $0xc,%esp
80107a1b:	ff 75 f4             	pushl  -0xc(%ebp)
80107a1e:	e8 b5 9e ff ff       	call   801018d8 <iupdate>
80107a23:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80107a26:	83 ec 0c             	sub    $0xc,%esp
80107a29:	ff 75 f4             	pushl  -0xc(%ebp)
80107a2c:	e8 91 a3 ff ff       	call   80101dc2 <iunlockput>
80107a31:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80107a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a37:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107a3b:	83 e8 01             	sub    $0x1,%eax
80107a3e:	89 c2                	mov    %eax,%edx
80107a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a43:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107a47:	83 ec 0c             	sub    $0xc,%esp
80107a4a:	ff 75 f0             	pushl  -0x10(%ebp)
80107a4d:	e8 86 9e ff ff       	call   801018d8 <iupdate>
80107a52:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80107a55:	83 ec 0c             	sub    $0xc,%esp
80107a58:	ff 75 f0             	pushl  -0x10(%ebp)
80107a5b:	e8 62 a3 ff ff       	call   80101dc2 <iunlockput>
80107a60:	83 c4 10             	add    $0x10,%esp

  end_op();
80107a63:	e8 d2 be ff ff       	call   8010393a <end_op>

  return 0;
80107a68:	b8 00 00 00 00       	mov    $0x0,%eax
80107a6d:	eb 19                	jmp    80107a88 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80107a6f:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80107a70:	83 ec 0c             	sub    $0xc,%esp
80107a73:	ff 75 f4             	pushl  -0xc(%ebp)
80107a76:	e8 47 a3 ff ff       	call   80101dc2 <iunlockput>
80107a7b:	83 c4 10             	add    $0x10,%esp
  end_op();
80107a7e:	e8 b7 be ff ff       	call   8010393a <end_op>
  return -1;
80107a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107a88:	c9                   	leave  
80107a89:	c3                   	ret    

80107a8a <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80107a8a:	55                   	push   %ebp
80107a8b:	89 e5                	mov    %esp,%ebp
80107a8d:	83 ec 38             	sub    $0x38,%esp
80107a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80107a93:	8b 55 10             	mov    0x10(%ebp),%edx
80107a96:	8b 45 14             	mov    0x14(%ebp),%eax
80107a99:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80107a9d:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80107aa1:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80107aa5:	83 ec 08             	sub    $0x8,%esp
80107aa8:	8d 45 de             	lea    -0x22(%ebp),%eax
80107aab:	50                   	push   %eax
80107aac:	ff 75 08             	pushl  0x8(%ebp)
80107aaf:	e8 50 ac ff ff       	call   80102704 <nameiparent>
80107ab4:	83 c4 10             	add    $0x10,%esp
80107ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107abe:	75 0a                	jne    80107aca <create+0x40>
    return 0;
80107ac0:	b8 00 00 00 00       	mov    $0x0,%eax
80107ac5:	e9 90 01 00 00       	jmp    80107c5a <create+0x1d0>
  ilock(dp);
80107aca:	83 ec 0c             	sub    $0xc,%esp
80107acd:	ff 75 f4             	pushl  -0xc(%ebp)
80107ad0:	e8 05 a0 ff ff       	call   80101ada <ilock>
80107ad5:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80107ad8:	83 ec 04             	sub    $0x4,%esp
80107adb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107ade:	50                   	push   %eax
80107adf:	8d 45 de             	lea    -0x22(%ebp),%eax
80107ae2:	50                   	push   %eax
80107ae3:	ff 75 f4             	pushl  -0xc(%ebp)
80107ae6:	e8 a7 a8 ff ff       	call   80102392 <dirlookup>
80107aeb:	83 c4 10             	add    $0x10,%esp
80107aee:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107af1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107af5:	74 50                	je     80107b47 <create+0xbd>
    iunlockput(dp);
80107af7:	83 ec 0c             	sub    $0xc,%esp
80107afa:	ff 75 f4             	pushl  -0xc(%ebp)
80107afd:	e8 c0 a2 ff ff       	call   80101dc2 <iunlockput>
80107b02:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80107b05:	83 ec 0c             	sub    $0xc,%esp
80107b08:	ff 75 f0             	pushl  -0x10(%ebp)
80107b0b:	e8 ca 9f ff ff       	call   80101ada <ilock>
80107b10:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80107b13:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80107b18:	75 15                	jne    80107b2f <create+0xa5>
80107b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b1d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107b21:	66 83 f8 02          	cmp    $0x2,%ax
80107b25:	75 08                	jne    80107b2f <create+0xa5>
      return ip;
80107b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b2a:	e9 2b 01 00 00       	jmp    80107c5a <create+0x1d0>
    iunlockput(ip);
80107b2f:	83 ec 0c             	sub    $0xc,%esp
80107b32:	ff 75 f0             	pushl  -0x10(%ebp)
80107b35:	e8 88 a2 ff ff       	call   80101dc2 <iunlockput>
80107b3a:	83 c4 10             	add    $0x10,%esp
    return 0;
80107b3d:	b8 00 00 00 00       	mov    $0x0,%eax
80107b42:	e9 13 01 00 00       	jmp    80107c5a <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80107b47:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4e:	8b 00                	mov    (%eax),%eax
80107b50:	83 ec 08             	sub    $0x8,%esp
80107b53:	52                   	push   %edx
80107b54:	50                   	push   %eax
80107b55:	e8 8b 9c ff ff       	call   801017e5 <ialloc>
80107b5a:	83 c4 10             	add    $0x10,%esp
80107b5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b64:	75 0d                	jne    80107b73 <create+0xe9>
    panic("create: ialloc");
80107b66:	83 ec 0c             	sub    $0xc,%esp
80107b69:	68 ec ac 10 80       	push   $0x8010acec
80107b6e:	e8 f3 89 ff ff       	call   80100566 <panic>

  ilock(ip);
80107b73:	83 ec 0c             	sub    $0xc,%esp
80107b76:	ff 75 f0             	pushl  -0x10(%ebp)
80107b79:	e8 5c 9f ff ff       	call   80101ada <ilock>
80107b7e:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80107b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b84:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80107b88:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80107b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b8f:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80107b93:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80107b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b9a:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80107ba0:	83 ec 0c             	sub    $0xc,%esp
80107ba3:	ff 75 f0             	pushl  -0x10(%ebp)
80107ba6:	e8 2d 9d ff ff       	call   801018d8 <iupdate>
80107bab:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80107bae:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80107bb3:	75 6a                	jne    80107c1f <create+0x195>
    dp->nlink++;  // for ".."
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107bbc:	83 c0 01             	add    $0x1,%eax
80107bbf:	89 c2                	mov    %eax,%edx
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107bc8:	83 ec 0c             	sub    $0xc,%esp
80107bcb:	ff 75 f4             	pushl  -0xc(%ebp)
80107bce:	e8 05 9d ff ff       	call   801018d8 <iupdate>
80107bd3:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80107bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd9:	8b 40 04             	mov    0x4(%eax),%eax
80107bdc:	83 ec 04             	sub    $0x4,%esp
80107bdf:	50                   	push   %eax
80107be0:	68 c6 ac 10 80       	push   $0x8010acc6
80107be5:	ff 75 f0             	pushl  -0x10(%ebp)
80107be8:	e8 5f a8 ff ff       	call   8010244c <dirlink>
80107bed:	83 c4 10             	add    $0x10,%esp
80107bf0:	85 c0                	test   %eax,%eax
80107bf2:	78 1e                	js     80107c12 <create+0x188>
80107bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf7:	8b 40 04             	mov    0x4(%eax),%eax
80107bfa:	83 ec 04             	sub    $0x4,%esp
80107bfd:	50                   	push   %eax
80107bfe:	68 c8 ac 10 80       	push   $0x8010acc8
80107c03:	ff 75 f0             	pushl  -0x10(%ebp)
80107c06:	e8 41 a8 ff ff       	call   8010244c <dirlink>
80107c0b:	83 c4 10             	add    $0x10,%esp
80107c0e:	85 c0                	test   %eax,%eax
80107c10:	79 0d                	jns    80107c1f <create+0x195>
      panic("create dots");
80107c12:	83 ec 0c             	sub    $0xc,%esp
80107c15:	68 fb ac 10 80       	push   $0x8010acfb
80107c1a:	e8 47 89 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80107c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c22:	8b 40 04             	mov    0x4(%eax),%eax
80107c25:	83 ec 04             	sub    $0x4,%esp
80107c28:	50                   	push   %eax
80107c29:	8d 45 de             	lea    -0x22(%ebp),%eax
80107c2c:	50                   	push   %eax
80107c2d:	ff 75 f4             	pushl  -0xc(%ebp)
80107c30:	e8 17 a8 ff ff       	call   8010244c <dirlink>
80107c35:	83 c4 10             	add    $0x10,%esp
80107c38:	85 c0                	test   %eax,%eax
80107c3a:	79 0d                	jns    80107c49 <create+0x1bf>
    panic("create: dirlink");
80107c3c:	83 ec 0c             	sub    $0xc,%esp
80107c3f:	68 07 ad 10 80       	push   $0x8010ad07
80107c44:	e8 1d 89 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80107c49:	83 ec 0c             	sub    $0xc,%esp
80107c4c:	ff 75 f4             	pushl  -0xc(%ebp)
80107c4f:	e8 6e a1 ff ff       	call   80101dc2 <iunlockput>
80107c54:	83 c4 10             	add    $0x10,%esp

  return ip;
80107c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c5a:	c9                   	leave  
80107c5b:	c3                   	ret    

80107c5c <sys_open>:

int
sys_open(void)
{
80107c5c:	55                   	push   %ebp
80107c5d:	89 e5                	mov    %esp,%ebp
80107c5f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80107c62:	83 ec 08             	sub    $0x8,%esp
80107c65:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107c68:	50                   	push   %eax
80107c69:	6a 00                	push   $0x0
80107c6b:	e8 eb f6 ff ff       	call   8010735b <argstr>
80107c70:	83 c4 10             	add    $0x10,%esp
80107c73:	85 c0                	test   %eax,%eax
80107c75:	78 15                	js     80107c8c <sys_open+0x30>
80107c77:	83 ec 08             	sub    $0x8,%esp
80107c7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107c7d:	50                   	push   %eax
80107c7e:	6a 01                	push   $0x1
80107c80:	e8 51 f6 ff ff       	call   801072d6 <argint>
80107c85:	83 c4 10             	add    $0x10,%esp
80107c88:	85 c0                	test   %eax,%eax
80107c8a:	79 0a                	jns    80107c96 <sys_open+0x3a>
    return -1;
80107c8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c91:	e9 61 01 00 00       	jmp    80107df7 <sys_open+0x19b>

  begin_op();
80107c96:	e8 13 bc ff ff       	call   801038ae <begin_op>

  if(omode & O_CREATE){
80107c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c9e:	25 00 02 00 00       	and    $0x200,%eax
80107ca3:	85 c0                	test   %eax,%eax
80107ca5:	74 2a                	je     80107cd1 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80107ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107caa:	6a 00                	push   $0x0
80107cac:	6a 00                	push   $0x0
80107cae:	6a 02                	push   $0x2
80107cb0:	50                   	push   %eax
80107cb1:	e8 d4 fd ff ff       	call   80107a8a <create>
80107cb6:	83 c4 10             	add    $0x10,%esp
80107cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80107cbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cc0:	75 75                	jne    80107d37 <sys_open+0xdb>
      end_op();
80107cc2:	e8 73 bc ff ff       	call   8010393a <end_op>
      return -1;
80107cc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ccc:	e9 26 01 00 00       	jmp    80107df7 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80107cd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cd4:	83 ec 0c             	sub    $0xc,%esp
80107cd7:	50                   	push   %eax
80107cd8:	e8 0b aa ff ff       	call   801026e8 <namei>
80107cdd:	83 c4 10             	add    $0x10,%esp
80107ce0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ce3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ce7:	75 0f                	jne    80107cf8 <sys_open+0x9c>
      end_op();
80107ce9:	e8 4c bc ff ff       	call   8010393a <end_op>
      return -1;
80107cee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cf3:	e9 ff 00 00 00       	jmp    80107df7 <sys_open+0x19b>
    }
    ilock(ip);
80107cf8:	83 ec 0c             	sub    $0xc,%esp
80107cfb:	ff 75 f4             	pushl  -0xc(%ebp)
80107cfe:	e8 d7 9d ff ff       	call   80101ada <ilock>
80107d03:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107d0d:	66 83 f8 01          	cmp    $0x1,%ax
80107d11:	75 24                	jne    80107d37 <sys_open+0xdb>
80107d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d16:	85 c0                	test   %eax,%eax
80107d18:	74 1d                	je     80107d37 <sys_open+0xdb>
      iunlockput(ip);
80107d1a:	83 ec 0c             	sub    $0xc,%esp
80107d1d:	ff 75 f4             	pushl  -0xc(%ebp)
80107d20:	e8 9d a0 ff ff       	call   80101dc2 <iunlockput>
80107d25:	83 c4 10             	add    $0x10,%esp
      end_op();
80107d28:	e8 0d bc ff ff       	call   8010393a <end_op>
      return -1;
80107d2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d32:	e9 c0 00 00 00       	jmp    80107df7 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80107d37:	e8 83 93 ff ff       	call   801010bf <filealloc>
80107d3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d43:	74 17                	je     80107d5c <sys_open+0x100>
80107d45:	83 ec 0c             	sub    $0xc,%esp
80107d48:	ff 75 f0             	pushl  -0x10(%ebp)
80107d4b:	e8 37 f7 ff ff       	call   80107487 <fdalloc>
80107d50:	83 c4 10             	add    $0x10,%esp
80107d53:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d56:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d5a:	79 2e                	jns    80107d8a <sys_open+0x12e>
    if(f)
80107d5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d60:	74 0e                	je     80107d70 <sys_open+0x114>
      fileclose(f);
80107d62:	83 ec 0c             	sub    $0xc,%esp
80107d65:	ff 75 f0             	pushl  -0x10(%ebp)
80107d68:	e8 10 94 ff ff       	call   8010117d <fileclose>
80107d6d:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107d70:	83 ec 0c             	sub    $0xc,%esp
80107d73:	ff 75 f4             	pushl  -0xc(%ebp)
80107d76:	e8 47 a0 ff ff       	call   80101dc2 <iunlockput>
80107d7b:	83 c4 10             	add    $0x10,%esp
    end_op();
80107d7e:	e8 b7 bb ff ff       	call   8010393a <end_op>
    return -1;
80107d83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d88:	eb 6d                	jmp    80107df7 <sys_open+0x19b>
  }
  iunlock(ip);
80107d8a:	83 ec 0c             	sub    $0xc,%esp
80107d8d:	ff 75 f4             	pushl  -0xc(%ebp)
80107d90:	e8 cb 9e ff ff       	call   80101c60 <iunlock>
80107d95:	83 c4 10             	add    $0x10,%esp
  end_op();
80107d98:	e8 9d bb ff ff       	call   8010393a <end_op>

  f->type = FD_INODE;
80107d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107da0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80107da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107dac:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80107daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107db2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80107db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107dbc:	83 e0 01             	and    $0x1,%eax
80107dbf:	85 c0                	test   %eax,%eax
80107dc1:	0f 94 c0             	sete   %al
80107dc4:	89 c2                	mov    %eax,%edx
80107dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dc9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80107dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107dcf:	83 e0 01             	and    $0x1,%eax
80107dd2:	85 c0                	test   %eax,%eax
80107dd4:	75 0a                	jne    80107de0 <sys_open+0x184>
80107dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107dd9:	83 e0 02             	and    $0x2,%eax
80107ddc:	85 c0                	test   %eax,%eax
80107dde:	74 07                	je     80107de7 <sys_open+0x18b>
80107de0:	b8 01 00 00 00       	mov    $0x1,%eax
80107de5:	eb 05                	jmp    80107dec <sys_open+0x190>
80107de7:	b8 00 00 00 00       	mov    $0x0,%eax
80107dec:	89 c2                	mov    %eax,%edx
80107dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df1:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80107df4:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107df7:	c9                   	leave  
80107df8:	c3                   	ret    

80107df9 <sys_mkdir>:

int
sys_mkdir(void)
{
80107df9:	55                   	push   %ebp
80107dfa:	89 e5                	mov    %esp,%ebp
80107dfc:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107dff:	e8 aa ba ff ff       	call   801038ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80107e04:	83 ec 08             	sub    $0x8,%esp
80107e07:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107e0a:	50                   	push   %eax
80107e0b:	6a 00                	push   $0x0
80107e0d:	e8 49 f5 ff ff       	call   8010735b <argstr>
80107e12:	83 c4 10             	add    $0x10,%esp
80107e15:	85 c0                	test   %eax,%eax
80107e17:	78 1b                	js     80107e34 <sys_mkdir+0x3b>
80107e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e1c:	6a 00                	push   $0x0
80107e1e:	6a 00                	push   $0x0
80107e20:	6a 01                	push   $0x1
80107e22:	50                   	push   %eax
80107e23:	e8 62 fc ff ff       	call   80107a8a <create>
80107e28:	83 c4 10             	add    $0x10,%esp
80107e2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e32:	75 0c                	jne    80107e40 <sys_mkdir+0x47>
    end_op();
80107e34:	e8 01 bb ff ff       	call   8010393a <end_op>
    return -1;
80107e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e3e:	eb 18                	jmp    80107e58 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107e40:	83 ec 0c             	sub    $0xc,%esp
80107e43:	ff 75 f4             	pushl  -0xc(%ebp)
80107e46:	e8 77 9f ff ff       	call   80101dc2 <iunlockput>
80107e4b:	83 c4 10             	add    $0x10,%esp
  end_op();
80107e4e:	e8 e7 ba ff ff       	call   8010393a <end_op>
  return 0;
80107e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e58:	c9                   	leave  
80107e59:	c3                   	ret    

80107e5a <sys_mknod>:

int
sys_mknod(void)
{
80107e5a:	55                   	push   %ebp
80107e5b:	89 e5                	mov    %esp,%ebp
80107e5d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107e60:	e8 49 ba ff ff       	call   801038ae <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80107e65:	83 ec 08             	sub    $0x8,%esp
80107e68:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107e6b:	50                   	push   %eax
80107e6c:	6a 00                	push   $0x0
80107e6e:	e8 e8 f4 ff ff       	call   8010735b <argstr>
80107e73:	83 c4 10             	add    $0x10,%esp
80107e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e7d:	78 4f                	js     80107ece <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107e7f:	83 ec 08             	sub    $0x8,%esp
80107e82:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107e85:	50                   	push   %eax
80107e86:	6a 01                	push   $0x1
80107e88:	e8 49 f4 ff ff       	call   801072d6 <argint>
80107e8d:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80107e90:	85 c0                	test   %eax,%eax
80107e92:	78 3a                	js     80107ece <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107e94:	83 ec 08             	sub    $0x8,%esp
80107e97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107e9a:	50                   	push   %eax
80107e9b:	6a 02                	push   $0x2
80107e9d:	e8 34 f4 ff ff       	call   801072d6 <argint>
80107ea2:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80107ea5:	85 c0                	test   %eax,%eax
80107ea7:	78 25                	js     80107ece <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80107ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107eac:	0f bf c8             	movswl %ax,%ecx
80107eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107eb2:	0f bf d0             	movswl %ax,%edx
80107eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107eb8:	51                   	push   %ecx
80107eb9:	52                   	push   %edx
80107eba:	6a 03                	push   $0x3
80107ebc:	50                   	push   %eax
80107ebd:	e8 c8 fb ff ff       	call   80107a8a <create>
80107ec2:	83 c4 10             	add    $0x10,%esp
80107ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ec8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ecc:	75 0c                	jne    80107eda <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80107ece:	e8 67 ba ff ff       	call   8010393a <end_op>
    return -1;
80107ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ed8:	eb 18                	jmp    80107ef2 <sys_mknod+0x98>
  }
  iunlockput(ip);
80107eda:	83 ec 0c             	sub    $0xc,%esp
80107edd:	ff 75 f0             	pushl  -0x10(%ebp)
80107ee0:	e8 dd 9e ff ff       	call   80101dc2 <iunlockput>
80107ee5:	83 c4 10             	add    $0x10,%esp
  end_op();
80107ee8:	e8 4d ba ff ff       	call   8010393a <end_op>
  return 0;
80107eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ef2:	c9                   	leave  
80107ef3:	c3                   	ret    

80107ef4 <sys_chdir>:

int
sys_chdir(void)
{
80107ef4:	55                   	push   %ebp
80107ef5:	89 e5                	mov    %esp,%ebp
80107ef7:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107efa:	e8 af b9 ff ff       	call   801038ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107eff:	83 ec 08             	sub    $0x8,%esp
80107f02:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f05:	50                   	push   %eax
80107f06:	6a 00                	push   $0x0
80107f08:	e8 4e f4 ff ff       	call   8010735b <argstr>
80107f0d:	83 c4 10             	add    $0x10,%esp
80107f10:	85 c0                	test   %eax,%eax
80107f12:	78 18                	js     80107f2c <sys_chdir+0x38>
80107f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f17:	83 ec 0c             	sub    $0xc,%esp
80107f1a:	50                   	push   %eax
80107f1b:	e8 c8 a7 ff ff       	call   801026e8 <namei>
80107f20:	83 c4 10             	add    $0x10,%esp
80107f23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f2a:	75 0c                	jne    80107f38 <sys_chdir+0x44>
    end_op();
80107f2c:	e8 09 ba ff ff       	call   8010393a <end_op>
    return -1;
80107f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f36:	eb 6e                	jmp    80107fa6 <sys_chdir+0xb2>
  }
  ilock(ip);
80107f38:	83 ec 0c             	sub    $0xc,%esp
80107f3b:	ff 75 f4             	pushl  -0xc(%ebp)
80107f3e:	e8 97 9b ff ff       	call   80101ada <ilock>
80107f43:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f49:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107f4d:	66 83 f8 01          	cmp    $0x1,%ax
80107f51:	74 1a                	je     80107f6d <sys_chdir+0x79>
    iunlockput(ip);
80107f53:	83 ec 0c             	sub    $0xc,%esp
80107f56:	ff 75 f4             	pushl  -0xc(%ebp)
80107f59:	e8 64 9e ff ff       	call   80101dc2 <iunlockput>
80107f5e:	83 c4 10             	add    $0x10,%esp
    end_op();
80107f61:	e8 d4 b9 ff ff       	call   8010393a <end_op>
    return -1;
80107f66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f6b:	eb 39                	jmp    80107fa6 <sys_chdir+0xb2>
  }
  iunlock(ip);
80107f6d:	83 ec 0c             	sub    $0xc,%esp
80107f70:	ff 75 f4             	pushl  -0xc(%ebp)
80107f73:	e8 e8 9c ff ff       	call   80101c60 <iunlock>
80107f78:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107f7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f81:	8b 40 68             	mov    0x68(%eax),%eax
80107f84:	83 ec 0c             	sub    $0xc,%esp
80107f87:	50                   	push   %eax
80107f88:	e8 45 9d ff ff       	call   80101cd2 <iput>
80107f8d:	83 c4 10             	add    $0x10,%esp
  end_op();
80107f90:	e8 a5 b9 ff ff       	call   8010393a <end_op>
  proc->cwd = ip;
80107f95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f9e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107fa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fa6:	c9                   	leave  
80107fa7:	c3                   	ret    

80107fa8 <sys_exec>:

int
sys_exec(void)
{
80107fa8:	55                   	push   %ebp
80107fa9:	89 e5                	mov    %esp,%ebp
80107fab:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107fb1:	83 ec 08             	sub    $0x8,%esp
80107fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107fb7:	50                   	push   %eax
80107fb8:	6a 00                	push   $0x0
80107fba:	e8 9c f3 ff ff       	call   8010735b <argstr>
80107fbf:	83 c4 10             	add    $0x10,%esp
80107fc2:	85 c0                	test   %eax,%eax
80107fc4:	78 18                	js     80107fde <sys_exec+0x36>
80107fc6:	83 ec 08             	sub    $0x8,%esp
80107fc9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107fcf:	50                   	push   %eax
80107fd0:	6a 01                	push   $0x1
80107fd2:	e8 ff f2 ff ff       	call   801072d6 <argint>
80107fd7:	83 c4 10             	add    $0x10,%esp
80107fda:	85 c0                	test   %eax,%eax
80107fdc:	79 0a                	jns    80107fe8 <sys_exec+0x40>
    return -1;
80107fde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fe3:	e9 c6 00 00 00       	jmp    801080ae <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107fe8:	83 ec 04             	sub    $0x4,%esp
80107feb:	68 80 00 00 00       	push   $0x80
80107ff0:	6a 00                	push   $0x0
80107ff2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107ff8:	50                   	push   %eax
80107ff9:	e8 b3 ef ff ff       	call   80106fb1 <memset>
80107ffe:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80108001:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80108008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800b:	83 f8 1f             	cmp    $0x1f,%eax
8010800e:	76 0a                	jbe    8010801a <sys_exec+0x72>
      return -1;
80108010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108015:	e9 94 00 00 00       	jmp    801080ae <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010801a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801d:	c1 e0 02             	shl    $0x2,%eax
80108020:	89 c2                	mov    %eax,%edx
80108022:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80108028:	01 c2                	add    %eax,%edx
8010802a:	83 ec 08             	sub    $0x8,%esp
8010802d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80108033:	50                   	push   %eax
80108034:	52                   	push   %edx
80108035:	e8 00 f2 ff ff       	call   8010723a <fetchint>
8010803a:	83 c4 10             	add    $0x10,%esp
8010803d:	85 c0                	test   %eax,%eax
8010803f:	79 07                	jns    80108048 <sys_exec+0xa0>
      return -1;
80108041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108046:	eb 66                	jmp    801080ae <sys_exec+0x106>
    if(uarg == 0){
80108048:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010804e:	85 c0                	test   %eax,%eax
80108050:	75 27                	jne    80108079 <sys_exec+0xd1>
      argv[i] = 0;
80108052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108055:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010805c:	00 00 00 00 
      break;
80108060:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80108061:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108064:	83 ec 08             	sub    $0x8,%esp
80108067:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010806d:	52                   	push   %edx
8010806e:	50                   	push   %eax
8010806f:	e8 a7 8b ff ff       	call   80100c1b <exec>
80108074:	83 c4 10             	add    $0x10,%esp
80108077:	eb 35                	jmp    801080ae <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80108079:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010807f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108082:	c1 e2 02             	shl    $0x2,%edx
80108085:	01 c2                	add    %eax,%edx
80108087:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010808d:	83 ec 08             	sub    $0x8,%esp
80108090:	52                   	push   %edx
80108091:	50                   	push   %eax
80108092:	e8 dd f1 ff ff       	call   80107274 <fetchstr>
80108097:	83 c4 10             	add    $0x10,%esp
8010809a:	85 c0                	test   %eax,%eax
8010809c:	79 07                	jns    801080a5 <sys_exec+0xfd>
      return -1;
8010809e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080a3:	eb 09                	jmp    801080ae <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801080a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801080a9:	e9 5a ff ff ff       	jmp    80108008 <sys_exec+0x60>
  return exec(path, argv);
}
801080ae:	c9                   	leave  
801080af:	c3                   	ret    

801080b0 <sys_pipe>:

int
sys_pipe(void)
{
801080b0:	55                   	push   %ebp
801080b1:	89 e5                	mov    %esp,%ebp
801080b3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801080b6:	83 ec 04             	sub    $0x4,%esp
801080b9:	6a 08                	push   $0x8
801080bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801080be:	50                   	push   %eax
801080bf:	6a 00                	push   $0x0
801080c1:	e8 38 f2 ff ff       	call   801072fe <argptr>
801080c6:	83 c4 10             	add    $0x10,%esp
801080c9:	85 c0                	test   %eax,%eax
801080cb:	79 0a                	jns    801080d7 <sys_pipe+0x27>
    return -1;
801080cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080d2:	e9 af 00 00 00       	jmp    80108186 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801080d7:	83 ec 08             	sub    $0x8,%esp
801080da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801080dd:	50                   	push   %eax
801080de:	8d 45 e8             	lea    -0x18(%ebp),%eax
801080e1:	50                   	push   %eax
801080e2:	e8 bb c2 ff ff       	call   801043a2 <pipealloc>
801080e7:	83 c4 10             	add    $0x10,%esp
801080ea:	85 c0                	test   %eax,%eax
801080ec:	79 0a                	jns    801080f8 <sys_pipe+0x48>
    return -1;
801080ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080f3:	e9 8e 00 00 00       	jmp    80108186 <sys_pipe+0xd6>
  fd0 = -1;
801080f8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801080ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108102:	83 ec 0c             	sub    $0xc,%esp
80108105:	50                   	push   %eax
80108106:	e8 7c f3 ff ff       	call   80107487 <fdalloc>
8010810b:	83 c4 10             	add    $0x10,%esp
8010810e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108111:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108115:	78 18                	js     8010812f <sys_pipe+0x7f>
80108117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010811a:	83 ec 0c             	sub    $0xc,%esp
8010811d:	50                   	push   %eax
8010811e:	e8 64 f3 ff ff       	call   80107487 <fdalloc>
80108123:	83 c4 10             	add    $0x10,%esp
80108126:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108129:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010812d:	79 3f                	jns    8010816e <sys_pipe+0xbe>
    if(fd0 >= 0)
8010812f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108133:	78 14                	js     80108149 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80108135:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010813b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010813e:	83 c2 08             	add    $0x8,%edx
80108141:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80108148:	00 
    fileclose(rf);
80108149:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010814c:	83 ec 0c             	sub    $0xc,%esp
8010814f:	50                   	push   %eax
80108150:	e8 28 90 ff ff       	call   8010117d <fileclose>
80108155:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80108158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010815b:	83 ec 0c             	sub    $0xc,%esp
8010815e:	50                   	push   %eax
8010815f:	e8 19 90 ff ff       	call   8010117d <fileclose>
80108164:	83 c4 10             	add    $0x10,%esp
    return -1;
80108167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010816c:	eb 18                	jmp    80108186 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
8010816e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108171:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108174:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80108176:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108179:	8d 50 04             	lea    0x4(%eax),%edx
8010817c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010817f:	89 02                	mov    %eax,(%edx)
  return 0;
80108181:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108186:	c9                   	leave  
80108187:	c3                   	ret    

80108188 <sys_chmod>:

#ifdef CS333_P5
int
sys_chmod(void)
{
80108188:	55                   	push   %ebp
80108189:	89 e5                	mov    %esp,%ebp
8010818b:	83 ec 18             	sub    $0x18,%esp
    char *path;
    int mod;
    if(argstr(0, &path) < 0 || argint(1, &mod) < 0)
8010818e:	83 ec 08             	sub    $0x8,%esp
80108191:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108194:	50                   	push   %eax
80108195:	6a 00                	push   $0x0
80108197:	e8 bf f1 ff ff       	call   8010735b <argstr>
8010819c:	83 c4 10             	add    $0x10,%esp
8010819f:	85 c0                	test   %eax,%eax
801081a1:	78 15                	js     801081b8 <sys_chmod+0x30>
801081a3:	83 ec 08             	sub    $0x8,%esp
801081a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801081a9:	50                   	push   %eax
801081aa:	6a 01                	push   $0x1
801081ac:	e8 25 f1 ff ff       	call   801072d6 <argint>
801081b1:	83 c4 10             	add    $0x10,%esp
801081b4:	85 c0                	test   %eax,%eax
801081b6:	79 07                	jns    801081bf <sys_chmod+0x37>
	return -1;
801081b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081bd:	eb 4f                	jmp    8010820e <sys_chmod+0x86>

    if(mod < 0000 || mod > 01777){
801081bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c2:	85 c0                	test   %eax,%eax
801081c4:	78 0a                	js     801081d0 <sys_chmod+0x48>
801081c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
801081ce:	7e 17                	jle    801081e7 <sys_chmod+0x5f>
	cprintf("\nPlease enter mode between 0000 and 01777\n");
801081d0:	83 ec 0c             	sub    $0xc,%esp
801081d3:	68 18 ad 10 80       	push   $0x8010ad18
801081d8:	e8 e9 81 ff ff       	call   801003c6 <cprintf>
801081dd:	83 c4 10             	add    $0x10,%esp
	return -1;
801081e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081e5:	eb 27                	jmp    8010820e <sys_chmod+0x86>
    }

    cprintf("%d", mod);
801081e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ea:	83 ec 08             	sub    $0x8,%esp
801081ed:	50                   	push   %eax
801081ee:	68 43 ad 10 80       	push   $0x8010ad43
801081f3:	e8 ce 81 ff ff       	call   801003c6 <cprintf>
801081f8:	83 c4 10             	add    $0x10,%esp
    return chmod(path, mod);
801081fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801081fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108201:	83 ec 08             	sub    $0x8,%esp
80108204:	52                   	push   %edx
80108205:	50                   	push   %eax
80108206:	e8 14 a5 ff ff       	call   8010271f <chmod>
8010820b:	83 c4 10             	add    $0x10,%esp

}
8010820e:	c9                   	leave  
8010820f:	c3                   	ret    

80108210 <sys_chown>:

int
sys_chown(void)
{
80108210:	55                   	push   %ebp
80108211:	89 e5                	mov    %esp,%ebp
80108213:	83 ec 18             	sub    $0x18,%esp
    char *path;
    int own;
    if(argstr(0, &path) < 0 || argint(1, &own) < 0)
80108216:	83 ec 08             	sub    $0x8,%esp
80108219:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010821c:	50                   	push   %eax
8010821d:	6a 00                	push   $0x0
8010821f:	e8 37 f1 ff ff       	call   8010735b <argstr>
80108224:	83 c4 10             	add    $0x10,%esp
80108227:	85 c0                	test   %eax,%eax
80108229:	78 15                	js     80108240 <sys_chown+0x30>
8010822b:	83 ec 08             	sub    $0x8,%esp
8010822e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80108231:	50                   	push   %eax
80108232:	6a 01                	push   $0x1
80108234:	e8 9d f0 ff ff       	call   801072d6 <argint>
80108239:	83 c4 10             	add    $0x10,%esp
8010823c:	85 c0                	test   %eax,%eax
8010823e:	79 07                	jns    80108247 <sys_chown+0x37>
	return -1;
80108240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108245:	eb 4f                	jmp    80108296 <sys_chown+0x86>

    if(own < 0 || own > 32767){
80108247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010824a:	85 c0                	test   %eax,%eax
8010824c:	78 0a                	js     80108258 <sys_chown+0x48>
8010824e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108251:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108256:	7e 17                	jle    8010826f <sys_chown+0x5f>
	cprintf("\nPlease enter a UID between 0 and 32767\n");
80108258:	83 ec 0c             	sub    $0xc,%esp
8010825b:	68 48 ad 10 80       	push   $0x8010ad48
80108260:	e8 61 81 ff ff       	call   801003c6 <cprintf>
80108265:	83 c4 10             	add    $0x10,%esp
	return -1;
80108268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010826d:	eb 27                	jmp    80108296 <sys_chown+0x86>
    }

    cprintf("%d", own);
8010826f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108272:	83 ec 08             	sub    $0x8,%esp
80108275:	50                   	push   %eax
80108276:	68 43 ad 10 80       	push   $0x8010ad43
8010827b:	e8 46 81 ff ff       	call   801003c6 <cprintf>
80108280:	83 c4 10             	add    $0x10,%esp

    return chown(path, own);
80108283:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108289:	83 ec 08             	sub    $0x8,%esp
8010828c:	52                   	push   %edx
8010828d:	50                   	push   %eax
8010828e:	e8 15 a5 ff ff       	call   801027a8 <chown>
80108293:	83 c4 10             	add    $0x10,%esp
}
80108296:	c9                   	leave  
80108297:	c3                   	ret    

80108298 <sys_chgrp>:

int
sys_chgrp(void)
{
80108298:	55                   	push   %ebp
80108299:	89 e5                	mov    %esp,%ebp
8010829b:	83 ec 18             	sub    $0x18,%esp
    char *path;
    int grp;
    if(argstr(0, &path) < 0 || argint(1, &grp) < 0)
8010829e:	83 ec 08             	sub    $0x8,%esp
801082a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801082a4:	50                   	push   %eax
801082a5:	6a 00                	push   $0x0
801082a7:	e8 af f0 ff ff       	call   8010735b <argstr>
801082ac:	83 c4 10             	add    $0x10,%esp
801082af:	85 c0                	test   %eax,%eax
801082b1:	78 15                	js     801082c8 <sys_chgrp+0x30>
801082b3:	83 ec 08             	sub    $0x8,%esp
801082b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801082b9:	50                   	push   %eax
801082ba:	6a 01                	push   $0x1
801082bc:	e8 15 f0 ff ff       	call   801072d6 <argint>
801082c1:	83 c4 10             	add    $0x10,%esp
801082c4:	85 c0                	test   %eax,%eax
801082c6:	79 07                	jns    801082cf <sys_chgrp+0x37>
	return -1;
801082c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082cd:	eb 4f                	jmp    8010831e <sys_chgrp+0x86>

    if(grp < 0 || grp > 32767){
801082cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d2:	85 c0                	test   %eax,%eax
801082d4:	78 0a                	js     801082e0 <sys_chgrp+0x48>
801082d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d9:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801082de:	7e 17                	jle    801082f7 <sys_chgrp+0x5f>
	cprintf("\nPlease enter a GID between 0 and 32767\n");
801082e0:	83 ec 0c             	sub    $0xc,%esp
801082e3:	68 74 ad 10 80       	push   $0x8010ad74
801082e8:	e8 d9 80 ff ff       	call   801003c6 <cprintf>
801082ed:	83 c4 10             	add    $0x10,%esp
	return -1;
801082f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082f5:	eb 27                	jmp    8010831e <sys_chgrp+0x86>
    }

    cprintf("%d", grp);
801082f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082fa:	83 ec 08             	sub    $0x8,%esp
801082fd:	50                   	push   %eax
801082fe:	68 43 ad 10 80       	push   $0x8010ad43
80108303:	e8 be 80 ff ff       	call   801003c6 <cprintf>
80108308:	83 c4 10             	add    $0x10,%esp
    return chgrp(path, grp);
8010830b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010830e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108311:	83 ec 08             	sub    $0x8,%esp
80108314:	52                   	push   %edx
80108315:	50                   	push   %eax
80108316:	e8 19 a5 ff ff       	call   80102834 <chgrp>
8010831b:	83 c4 10             	add    $0x10,%esp

}
8010831e:	c9                   	leave  
8010831f:	c3                   	ret    

80108320 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80108320:	55                   	push   %ebp
80108321:	89 e5                	mov    %esp,%ebp
80108323:	83 ec 08             	sub    $0x8,%esp
80108326:	8b 55 08             	mov    0x8(%ebp),%edx
80108329:	8b 45 0c             	mov    0xc(%ebp),%eax
8010832c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108330:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108334:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80108338:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010833c:	66 ef                	out    %ax,(%dx)
}
8010833e:	90                   	nop
8010833f:	c9                   	leave  
80108340:	c3                   	ret    

80108341 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80108341:	55                   	push   %ebp
80108342:	89 e5                	mov    %esp,%ebp
80108344:	83 ec 08             	sub    $0x8,%esp
  return fork();
80108347:	e8 78 cb ff ff       	call   80104ec4 <fork>
}
8010834c:	c9                   	leave  
8010834d:	c3                   	ret    

8010834e <sys_exit>:

int
sys_exit(void)
{
8010834e:	55                   	push   %ebp
8010834f:	89 e5                	mov    %esp,%ebp
80108351:	83 ec 08             	sub    $0x8,%esp
  exit();
80108354:	e8 9d cd ff ff       	call   801050f6 <exit>
  return 0;  // not reached
80108359:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010835e:	c9                   	leave  
8010835f:	c3                   	ret    

80108360 <sys_wait>:

int
sys_wait(void)
{
80108360:	55                   	push   %ebp
80108361:	89 e5                	mov    %esp,%ebp
80108363:	83 ec 08             	sub    $0x8,%esp
  return wait();
80108366:	e8 10 d0 ff ff       	call   8010537b <wait>
}
8010836b:	c9                   	leave  
8010836c:	c3                   	ret    

8010836d <sys_kill>:

int
sys_kill(void)
{
8010836d:	55                   	push   %ebp
8010836e:	89 e5                	mov    %esp,%ebp
80108370:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80108373:	83 ec 08             	sub    $0x8,%esp
80108376:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108379:	50                   	push   %eax
8010837a:	6a 00                	push   $0x0
8010837c:	e8 55 ef ff ff       	call   801072d6 <argint>
80108381:	83 c4 10             	add    $0x10,%esp
80108384:	85 c0                	test   %eax,%eax
80108386:	79 07                	jns    8010838f <sys_kill+0x22>
    return -1;
80108388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010838d:	eb 0f                	jmp    8010839e <sys_kill+0x31>
  return kill(pid);
8010838f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108392:	83 ec 0c             	sub    $0xc,%esp
80108395:	50                   	push   %eax
80108396:	e8 e5 d8 ff ff       	call   80105c80 <kill>
8010839b:	83 c4 10             	add    $0x10,%esp
}
8010839e:	c9                   	leave  
8010839f:	c3                   	ret    

801083a0 <sys_getpid>:

int
sys_getpid(void)
{
801083a0:	55                   	push   %ebp
801083a1:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801083a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083a9:	8b 40 10             	mov    0x10(%eax),%eax
}
801083ac:	5d                   	pop    %ebp
801083ad:	c3                   	ret    

801083ae <sys_sbrk>:

int
sys_sbrk(void)
{
801083ae:	55                   	push   %ebp
801083af:	89 e5                	mov    %esp,%ebp
801083b1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801083b4:	83 ec 08             	sub    $0x8,%esp
801083b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801083ba:	50                   	push   %eax
801083bb:	6a 00                	push   $0x0
801083bd:	e8 14 ef ff ff       	call   801072d6 <argint>
801083c2:	83 c4 10             	add    $0x10,%esp
801083c5:	85 c0                	test   %eax,%eax
801083c7:	79 07                	jns    801083d0 <sys_sbrk+0x22>
    return -1;
801083c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083ce:	eb 28                	jmp    801083f8 <sys_sbrk+0x4a>
  addr = proc->sz;
801083d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083d6:	8b 00                	mov    (%eax),%eax
801083d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801083db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083de:	83 ec 0c             	sub    $0xc,%esp
801083e1:	50                   	push   %eax
801083e2:	e8 3a ca ff ff       	call   80104e21 <growproc>
801083e7:	83 c4 10             	add    $0x10,%esp
801083ea:	85 c0                	test   %eax,%eax
801083ec:	79 07                	jns    801083f5 <sys_sbrk+0x47>
    return -1;
801083ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083f3:	eb 03                	jmp    801083f8 <sys_sbrk+0x4a>
  return addr;
801083f5:	8b 45 f4             	mov    -0xc(%ebp),%eax

    cprintf("Implement this");
}
801083f8:	c9                   	leave  
801083f9:	c3                   	ret    

801083fa <sys_sleep>:
int
sys_sleep(void)
{
801083fa:	55                   	push   %ebp
801083fb:	89 e5                	mov    %esp,%ebp
801083fd:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80108400:	83 ec 08             	sub    $0x8,%esp
80108403:	8d 45 f0             	lea    -0x10(%ebp),%eax
80108406:	50                   	push   %eax
80108407:	6a 00                	push   $0x0
80108409:	e8 c8 ee ff ff       	call   801072d6 <argint>
8010840e:	83 c4 10             	add    $0x10,%esp
80108411:	85 c0                	test   %eax,%eax
80108413:	79 07                	jns    8010841c <sys_sleep+0x22>
    return -1;
80108415:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010841a:	eb 44                	jmp    80108460 <sys_sleep+0x66>
  ticks0 = ticks;
8010841c:	a1 e0 88 11 80       	mov    0x801188e0,%eax
80108421:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80108424:	eb 26                	jmp    8010844c <sys_sleep+0x52>
    if(proc->killed){
80108426:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010842c:	8b 40 24             	mov    0x24(%eax),%eax
8010842f:	85 c0                	test   %eax,%eax
80108431:	74 07                	je     8010843a <sys_sleep+0x40>
      return -1;
80108433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108438:	eb 26                	jmp    80108460 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
8010843a:	83 ec 08             	sub    $0x8,%esp
8010843d:	6a 00                	push   $0x0
8010843f:	68 e0 88 11 80       	push   $0x801188e0
80108444:	e8 f0 d5 ff ff       	call   80105a39 <sleep>
80108449:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010844c:	a1 e0 88 11 80       	mov    0x801188e0,%eax
80108451:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108454:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108457:	39 d0                	cmp    %edx,%eax
80108459:	72 cb                	jb     80108426 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
8010845b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108460:	c9                   	leave  
80108461:	c3                   	ret    

80108462 <sys_date>:
#ifdef CS333_P1
int
sys_date(void)
{
80108462:	55                   	push   %ebp
80108463:	89 e5                	mov    %esp,%ebp
80108465:	83 ec 18             	sub    $0x18,%esp
    struct rtcdate *d;
   
    if(argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80108468:	83 ec 04             	sub    $0x4,%esp
8010846b:	6a 18                	push   $0x18
8010846d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108470:	50                   	push   %eax
80108471:	6a 00                	push   $0x0
80108473:	e8 86 ee ff ff       	call   801072fe <argptr>
80108478:	83 c4 10             	add    $0x10,%esp
8010847b:	85 c0                	test   %eax,%eax
8010847d:	79 07                	jns    80108486 <sys_date+0x24>
	return -1;
8010847f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108484:	eb 14                	jmp    8010849a <sys_date+0x38>

    cmostime(d);
80108486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108489:	83 ec 0c             	sub    $0xc,%esp
8010848c:	50                   	push   %eax
8010848d:	e8 97 b0 ff ff       	call   80103529 <cmostime>
80108492:	83 c4 10             	add    $0x10,%esp
    return 0;
80108495:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010849a:	c9                   	leave  
8010849b:	c3                   	ret    

8010849c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
8010849c:	55                   	push   %ebp
8010849d:	89 e5                	mov    %esp,%ebp
8010849f:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
801084a2:	a1 e0 88 11 80       	mov    0x801188e0,%eax
801084a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
801084aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801084ad:	c9                   	leave  
801084ae:	c3                   	ret    

801084af <sys_halt>:

//Turn of the computer
int
sys_halt(void){
801084af:	55                   	push   %ebp
801084b0:	89 e5                	mov    %esp,%ebp
801084b2:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
801084b5:	83 ec 0c             	sub    $0xc,%esp
801084b8:	68 a0 ad 10 80       	push   $0x8010ada0
801084bd:	e8 04 7f ff ff       	call   801003c6 <cprintf>
801084c2:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
801084c5:	83 ec 08             	sub    $0x8,%esp
801084c8:	68 00 20 00 00       	push   $0x2000
801084cd:	68 04 06 00 00       	push   $0x604
801084d2:	e8 49 fe ff ff       	call   80108320 <outw>
801084d7:	83 c4 10             	add    $0x10,%esp
  return 0;
801084da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084df:	c9                   	leave  
801084e0:	c3                   	ret    

801084e1 <sys_getuid>:

#ifdef CS333_P2
int 
sys_getuid(void)
{
801084e1:	55                   	push   %ebp
801084e2:	89 e5                	mov    %esp,%ebp
    return proc -> uid;
801084e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084ea:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801084f0:	5d                   	pop    %ebp
801084f1:	c3                   	ret    

801084f2 <sys_getgid>:

int 
sys_getgid(void)
{
801084f2:	55                   	push   %ebp
801084f3:	89 e5                	mov    %esp,%ebp
    return proc -> gid;
801084f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084fb:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80108501:	5d                   	pop    %ebp
80108502:	c3                   	ret    

80108503 <sys_getppid>:

int 
sys_getppid(void)
{
80108503:	55                   	push   %ebp
80108504:	89 e5                	mov    %esp,%ebp
    if(proc -> parent)
80108506:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010850c:	8b 40 14             	mov    0x14(%eax),%eax
8010850f:	85 c0                	test   %eax,%eax
80108511:	74 0e                	je     80108521 <sys_getppid+0x1e>
	return proc -> parent -> pid;
80108513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108519:	8b 40 14             	mov    0x14(%eax),%eax
8010851c:	8b 40 10             	mov    0x10(%eax),%eax
8010851f:	eb 05                	jmp    80108526 <sys_getppid+0x23>
    else
	return 1;
80108521:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108526:	5d                   	pop    %ebp
80108527:	c3                   	ret    

80108528 <sys_setuid>:

int 
sys_setuid(void)
{
80108528:	55                   	push   %ebp
80108529:	89 e5                	mov    %esp,%ebp
8010852b:	83 ec 18             	sub    $0x18,%esp
    int uid;

    if(argint(0, &uid) < 0)
8010852e:	83 ec 08             	sub    $0x8,%esp
80108531:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108534:	50                   	push   %eax
80108535:	6a 00                	push   $0x0
80108537:	e8 9a ed ff ff       	call   801072d6 <argint>
8010853c:	83 c4 10             	add    $0x10,%esp
8010853f:	85 c0                	test   %eax,%eax
80108541:	79 07                	jns    8010854a <sys_setuid+0x22>
	return -1;
80108543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108548:	eb 2d                	jmp    80108577 <sys_setuid+0x4f>
    if(uid > 32767 || uid < 0)
8010854a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854d:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108552:	7f 07                	jg     8010855b <sys_setuid+0x33>
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	85 c0                	test   %eax,%eax
80108559:	79 07                	jns    80108562 <sys_setuid+0x3a>
	return -1;
8010855b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108560:	eb 15                	jmp    80108577 <sys_setuid+0x4f>
    else
	return proc -> uid = uid;
80108562:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108568:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010856b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
80108571:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80108577:	c9                   	leave  
80108578:	c3                   	ret    

80108579 <sys_setgid>:

int 
sys_setgid(void)
{
80108579:	55                   	push   %ebp
8010857a:	89 e5                	mov    %esp,%ebp
8010857c:	83 ec 18             	sub    $0x18,%esp
    int gid;

    if(argint(0, &gid) < 0)
8010857f:	83 ec 08             	sub    $0x8,%esp
80108582:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108585:	50                   	push   %eax
80108586:	6a 00                	push   $0x0
80108588:	e8 49 ed ff ff       	call   801072d6 <argint>
8010858d:	83 c4 10             	add    $0x10,%esp
80108590:	85 c0                	test   %eax,%eax
80108592:	79 07                	jns    8010859b <sys_setgid+0x22>
	return -1;
80108594:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108599:	eb 2d                	jmp    801085c8 <sys_setgid+0x4f>
    if(gid > 32767 || gid < 0)
8010859b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859e:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801085a3:	7f 07                	jg     801085ac <sys_setgid+0x33>
801085a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a8:	85 c0                	test   %eax,%eax
801085aa:	79 07                	jns    801085b3 <sys_setgid+0x3a>
	return -1;
801085ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085b1:	eb 15                	jmp    801085c8 <sys_setgid+0x4f>
    else
	return proc -> gid = gid;
801085b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085bc:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
801085c2:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801085c8:	c9                   	leave  
801085c9:	c3                   	ret    

801085ca <sys_getprocs>:

int
sys_getprocs(void)
{
801085ca:	55                   	push   %ebp
801085cb:	89 e5                	mov    %esp,%ebp
801085cd:	83 ec 18             	sub    $0x18,%esp
    int num;
    struct uproc *procarray;

    if(argint(0, &num) < 0)
801085d0:	83 ec 08             	sub    $0x8,%esp
801085d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801085d6:	50                   	push   %eax
801085d7:	6a 00                	push   $0x0
801085d9:	e8 f8 ec ff ff       	call   801072d6 <argint>
801085de:	83 c4 10             	add    $0x10,%esp
801085e1:	85 c0                	test   %eax,%eax
801085e3:	79 07                	jns    801085ec <sys_getprocs+0x22>
	return -1;
801085e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085ea:	eb 36                	jmp    80108622 <sys_getprocs+0x58>
    
    if(argptr(1, (void*)&procarray, sizeof(struct uproc)) < 0)
801085ec:	83 ec 04             	sub    $0x4,%esp
801085ef:	6a 60                	push   $0x60
801085f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801085f4:	50                   	push   %eax
801085f5:	6a 01                	push   $0x1
801085f7:	e8 02 ed ff ff       	call   801072fe <argptr>
801085fc:	83 c4 10             	add    $0x10,%esp
801085ff:	85 c0                	test   %eax,%eax
80108601:	79 07                	jns    8010860a <sys_getprocs+0x40>
	return -1;
80108603:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108608:	eb 18                	jmp    80108622 <sys_getprocs+0x58>

   getproctable(num, procarray);
8010860a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010860d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108610:	83 ec 08             	sub    $0x8,%esp
80108613:	50                   	push   %eax
80108614:	52                   	push   %edx
80108615:	e8 77 dc ff ff       	call   80106291 <getproctable>
8010861a:	83 c4 10             	add    $0x10,%esp
   return 1;
8010861d:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108622:	c9                   	leave  
80108623:	c3                   	ret    

80108624 <sys_setpriority>:
#endif
#ifdef CS333_P3P4
int
sys_setpriority(void)
{
80108624:	55                   	push   %ebp
80108625:	89 e5                	mov    %esp,%ebp
80108627:	83 ec 18             	sub    $0x18,%esp
    int pid, prio;

    if(argint(0, &pid) < 0)
8010862a:	83 ec 08             	sub    $0x8,%esp
8010862d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108630:	50                   	push   %eax
80108631:	6a 00                	push   $0x0
80108633:	e8 9e ec ff ff       	call   801072d6 <argint>
80108638:	83 c4 10             	add    $0x10,%esp
8010863b:	85 c0                	test   %eax,%eax
8010863d:	79 07                	jns    80108646 <sys_setpriority+0x22>
	return -1;
8010863f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108644:	eb 7e                	jmp    801086c4 <sys_setpriority+0xa0>

    if(argint(1, &prio) < 0)
80108646:	83 ec 08             	sub    $0x8,%esp
80108649:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010864c:	50                   	push   %eax
8010864d:	6a 01                	push   $0x1
8010864f:	e8 82 ec ff ff       	call   801072d6 <argint>
80108654:	83 c4 10             	add    $0x10,%esp
80108657:	85 c0                	test   %eax,%eax
80108659:	79 07                	jns    80108662 <sys_setpriority+0x3e>
	return -1;
8010865b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108660:	eb 62                	jmp    801086c4 <sys_setpriority+0xa0>
    
    if(prio < 0 || prio > MAX){
80108662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108665:	85 c0                	test   %eax,%eax
80108667:	78 08                	js     80108671 <sys_setpriority+0x4d>
80108669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010866c:	83 f8 04             	cmp    $0x4,%eax
8010866f:	7e 1d                	jle    8010868e <sys_setpriority+0x6a>
	cprintf("\nPriority: %d out of bounds, enter a value between 0 and %d\n", prio, MAX);
80108671:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108674:	83 ec 04             	sub    $0x4,%esp
80108677:	6a 04                	push   $0x4
80108679:	50                   	push   %eax
8010867a:	68 b4 ad 10 80       	push   $0x8010adb4
8010867f:	e8 42 7d ff ff       	call   801003c6 <cprintf>
80108684:	83 c4 10             	add    $0x10,%esp
	return -2;
80108687:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
8010868c:	eb 36                	jmp    801086c4 <sys_setpriority+0xa0>
    }
	
    if(pid < 1){
8010868e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108691:	85 c0                	test   %eax,%eax
80108693:	7f 17                	jg     801086ac <sys_setpriority+0x88>
	cprintf("\nInvalid PID\n");
80108695:	83 ec 0c             	sub    $0xc,%esp
80108698:	68 f1 ad 10 80       	push   $0x8010adf1
8010869d:	e8 24 7d ff ff       	call   801003c6 <cprintf>
801086a2:	83 c4 10             	add    $0x10,%esp
	return -3;
801086a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
801086aa:	eb 18                	jmp    801086c4 <sys_setpriority+0xa0>
    }

    setpriority(pid, prio);
801086ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b2:	83 ec 08             	sub    $0x8,%esp
801086b5:	52                   	push   %edx
801086b6:	50                   	push   %eax
801086b7:	e8 6a e4 ff ff       	call   80106b26 <setpriority>
801086bc:	83 c4 10             	add    $0x10,%esp

    return 1;
801086bf:	b8 01 00 00 00       	mov    $0x1,%eax
}
801086c4:	c9                   	leave  
801086c5:	c3                   	ret    

801086c6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801086c6:	55                   	push   %ebp
801086c7:	89 e5                	mov    %esp,%ebp
801086c9:	83 ec 08             	sub    $0x8,%esp
801086cc:	8b 55 08             	mov    0x8(%ebp),%edx
801086cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801086d6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801086d9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801086dd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801086e1:	ee                   	out    %al,(%dx)
}
801086e2:	90                   	nop
801086e3:	c9                   	leave  
801086e4:	c3                   	ret    

801086e5 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801086e5:	55                   	push   %ebp
801086e6:	89 e5                	mov    %esp,%ebp
801086e8:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801086eb:	6a 34                	push   $0x34
801086ed:	6a 43                	push   $0x43
801086ef:	e8 d2 ff ff ff       	call   801086c6 <outb>
801086f4:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
801086f7:	68 a9 00 00 00       	push   $0xa9
801086fc:	6a 40                	push   $0x40
801086fe:	e8 c3 ff ff ff       	call   801086c6 <outb>
80108703:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80108706:	6a 04                	push   $0x4
80108708:	6a 40                	push   $0x40
8010870a:	e8 b7 ff ff ff       	call   801086c6 <outb>
8010870f:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80108712:	83 ec 0c             	sub    $0xc,%esp
80108715:	6a 00                	push   $0x0
80108717:	e8 70 bb ff ff       	call   8010428c <picenable>
8010871c:	83 c4 10             	add    $0x10,%esp
}
8010871f:	90                   	nop
80108720:	c9                   	leave  
80108721:	c3                   	ret    

80108722 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80108722:	1e                   	push   %ds
  pushl %es
80108723:	06                   	push   %es
  pushl %fs
80108724:	0f a0                	push   %fs
  pushl %gs
80108726:	0f a8                	push   %gs
  pushal
80108728:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80108729:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010872d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010872f:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80108731:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80108735:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80108737:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80108739:	54                   	push   %esp
  call trap
8010873a:	e8 ce 01 00 00       	call   8010890d <trap>
  addl $4, %esp
8010873f:	83 c4 04             	add    $0x4,%esp

80108742 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80108742:	61                   	popa   
  popl %gs
80108743:	0f a9                	pop    %gs
  popl %fs
80108745:	0f a1                	pop    %fs
  popl %es
80108747:	07                   	pop    %es
  popl %ds
80108748:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80108749:	83 c4 08             	add    $0x8,%esp
  iret
8010874c:	cf                   	iret   

8010874d <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
8010874d:	55                   	push   %ebp
8010874e:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108750:	8b 45 08             	mov    0x8(%ebp),%eax
80108753:	f0 ff 00             	lock incl (%eax)
}
80108756:	90                   	nop
80108757:	5d                   	pop    %ebp
80108758:	c3                   	ret    

80108759 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80108759:	55                   	push   %ebp
8010875a:	89 e5                	mov    %esp,%ebp
8010875c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010875f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108762:	83 e8 01             	sub    $0x1,%eax
80108765:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108769:	8b 45 08             	mov    0x8(%ebp),%eax
8010876c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108770:	8b 45 08             	mov    0x8(%ebp),%eax
80108773:	c1 e8 10             	shr    $0x10,%eax
80108776:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010877a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010877d:	0f 01 18             	lidtl  (%eax)
}
80108780:	90                   	nop
80108781:	c9                   	leave  
80108782:	c3                   	ret    

80108783 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80108783:	55                   	push   %ebp
80108784:	89 e5                	mov    %esp,%ebp
80108786:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80108789:	0f 20 d0             	mov    %cr2,%eax
8010878c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010878f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108792:	c9                   	leave  
80108793:	c3                   	ret    

80108794 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
80108794:	55                   	push   %ebp
80108795:	89 e5                	mov    %esp,%ebp
80108797:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
8010879a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801087a1:	e9 c3 00 00 00       	jmp    80108869 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801087a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087a9:	8b 04 85 bc e0 10 80 	mov    -0x7fef1f44(,%eax,4),%eax
801087b0:	89 c2                	mov    %eax,%edx
801087b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087b5:	66 89 14 c5 e0 80 11 	mov    %dx,-0x7fee7f20(,%eax,8)
801087bc:	80 
801087bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087c0:	66 c7 04 c5 e2 80 11 	movw   $0x8,-0x7fee7f1e(,%eax,8)
801087c7:	80 08 00 
801087ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087cd:	0f b6 14 c5 e4 80 11 	movzbl -0x7fee7f1c(,%eax,8),%edx
801087d4:	80 
801087d5:	83 e2 e0             	and    $0xffffffe0,%edx
801087d8:	88 14 c5 e4 80 11 80 	mov    %dl,-0x7fee7f1c(,%eax,8)
801087df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087e2:	0f b6 14 c5 e4 80 11 	movzbl -0x7fee7f1c(,%eax,8),%edx
801087e9:	80 
801087ea:	83 e2 1f             	and    $0x1f,%edx
801087ed:	88 14 c5 e4 80 11 80 	mov    %dl,-0x7fee7f1c(,%eax,8)
801087f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087f7:	0f b6 14 c5 e5 80 11 	movzbl -0x7fee7f1b(,%eax,8),%edx
801087fe:	80 
801087ff:	83 e2 f0             	and    $0xfffffff0,%edx
80108802:	83 ca 0e             	or     $0xe,%edx
80108805:	88 14 c5 e5 80 11 80 	mov    %dl,-0x7fee7f1b(,%eax,8)
8010880c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010880f:	0f b6 14 c5 e5 80 11 	movzbl -0x7fee7f1b(,%eax,8),%edx
80108816:	80 
80108817:	83 e2 ef             	and    $0xffffffef,%edx
8010881a:	88 14 c5 e5 80 11 80 	mov    %dl,-0x7fee7f1b(,%eax,8)
80108821:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108824:	0f b6 14 c5 e5 80 11 	movzbl -0x7fee7f1b(,%eax,8),%edx
8010882b:	80 
8010882c:	83 e2 9f             	and    $0xffffff9f,%edx
8010882f:	88 14 c5 e5 80 11 80 	mov    %dl,-0x7fee7f1b(,%eax,8)
80108836:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108839:	0f b6 14 c5 e5 80 11 	movzbl -0x7fee7f1b(,%eax,8),%edx
80108840:	80 
80108841:	83 ca 80             	or     $0xffffff80,%edx
80108844:	88 14 c5 e5 80 11 80 	mov    %dl,-0x7fee7f1b(,%eax,8)
8010884b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010884e:	8b 04 85 bc e0 10 80 	mov    -0x7fef1f44(,%eax,4),%eax
80108855:	c1 e8 10             	shr    $0x10,%eax
80108858:	89 c2                	mov    %eax,%edx
8010885a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010885d:	66 89 14 c5 e6 80 11 	mov    %dx,-0x7fee7f1a(,%eax,8)
80108864:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80108865:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80108869:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108870:	0f 8e 30 ff ff ff    	jle    801087a6 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80108876:	a1 bc e1 10 80       	mov    0x8010e1bc,%eax
8010887b:	66 a3 e0 82 11 80    	mov    %ax,0x801182e0
80108881:	66 c7 05 e2 82 11 80 	movw   $0x8,0x801182e2
80108888:	08 00 
8010888a:	0f b6 05 e4 82 11 80 	movzbl 0x801182e4,%eax
80108891:	83 e0 e0             	and    $0xffffffe0,%eax
80108894:	a2 e4 82 11 80       	mov    %al,0x801182e4
80108899:	0f b6 05 e4 82 11 80 	movzbl 0x801182e4,%eax
801088a0:	83 e0 1f             	and    $0x1f,%eax
801088a3:	a2 e4 82 11 80       	mov    %al,0x801182e4
801088a8:	0f b6 05 e5 82 11 80 	movzbl 0x801182e5,%eax
801088af:	83 c8 0f             	or     $0xf,%eax
801088b2:	a2 e5 82 11 80       	mov    %al,0x801182e5
801088b7:	0f b6 05 e5 82 11 80 	movzbl 0x801182e5,%eax
801088be:	83 e0 ef             	and    $0xffffffef,%eax
801088c1:	a2 e5 82 11 80       	mov    %al,0x801182e5
801088c6:	0f b6 05 e5 82 11 80 	movzbl 0x801182e5,%eax
801088cd:	83 c8 60             	or     $0x60,%eax
801088d0:	a2 e5 82 11 80       	mov    %al,0x801182e5
801088d5:	0f b6 05 e5 82 11 80 	movzbl 0x801182e5,%eax
801088dc:	83 c8 80             	or     $0xffffff80,%eax
801088df:	a2 e5 82 11 80       	mov    %al,0x801182e5
801088e4:	a1 bc e1 10 80       	mov    0x8010e1bc,%eax
801088e9:	c1 e8 10             	shr    $0x10,%eax
801088ec:	66 a3 e6 82 11 80    	mov    %ax,0x801182e6
  
}
801088f2:	90                   	nop
801088f3:	c9                   	leave  
801088f4:	c3                   	ret    

801088f5 <idtinit>:

void
idtinit(void)
{
801088f5:	55                   	push   %ebp
801088f6:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801088f8:	68 00 08 00 00       	push   $0x800
801088fd:	68 e0 80 11 80       	push   $0x801180e0
80108902:	e8 52 fe ff ff       	call   80108759 <lidt>
80108907:	83 c4 08             	add    $0x8,%esp
}
8010890a:	90                   	nop
8010890b:	c9                   	leave  
8010890c:	c3                   	ret    

8010890d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010890d:	55                   	push   %ebp
8010890e:	89 e5                	mov    %esp,%ebp
80108910:	57                   	push   %edi
80108911:	56                   	push   %esi
80108912:	53                   	push   %ebx
80108913:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80108916:	8b 45 08             	mov    0x8(%ebp),%eax
80108919:	8b 40 30             	mov    0x30(%eax),%eax
8010891c:	83 f8 40             	cmp    $0x40,%eax
8010891f:	75 3e                	jne    8010895f <trap+0x52>
    if(proc->killed)
80108921:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108927:	8b 40 24             	mov    0x24(%eax),%eax
8010892a:	85 c0                	test   %eax,%eax
8010892c:	74 05                	je     80108933 <trap+0x26>
      exit();
8010892e:	e8 c3 c7 ff ff       	call   801050f6 <exit>
    proc->tf = tf;
80108933:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108939:	8b 55 08             	mov    0x8(%ebp),%edx
8010893c:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010893f:	e8 48 ea ff ff       	call   8010738c <syscall>
    if(proc->killed)
80108944:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010894a:	8b 40 24             	mov    0x24(%eax),%eax
8010894d:	85 c0                	test   %eax,%eax
8010894f:	0f 84 21 02 00 00    	je     80108b76 <trap+0x269>
      exit();
80108955:	e8 9c c7 ff ff       	call   801050f6 <exit>
    return;
8010895a:	e9 17 02 00 00       	jmp    80108b76 <trap+0x269>
  }

  switch(tf->trapno){
8010895f:	8b 45 08             	mov    0x8(%ebp),%eax
80108962:	8b 40 30             	mov    0x30(%eax),%eax
80108965:	83 e8 20             	sub    $0x20,%eax
80108968:	83 f8 1f             	cmp    $0x1f,%eax
8010896b:	0f 87 a3 00 00 00    	ja     80108a14 <trap+0x107>
80108971:	8b 04 85 a0 ae 10 80 	mov    -0x7fef5160(,%eax,4),%eax
80108978:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
8010897a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108980:	0f b6 00             	movzbl (%eax),%eax
80108983:	84 c0                	test   %al,%al
80108985:	75 20                	jne    801089a7 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
80108987:	83 ec 0c             	sub    $0xc,%esp
8010898a:	68 e0 88 11 80       	push   $0x801188e0
8010898f:	e8 b9 fd ff ff       	call   8010874d <atom_inc>
80108994:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
80108997:	83 ec 0c             	sub    $0xc,%esp
8010899a:	68 e0 88 11 80       	push   $0x801188e0
8010899f:	e8 a5 d2 ff ff       	call   80105c49 <wakeup>
801089a4:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801089a7:	e8 da a9 ff ff       	call   80103386 <lapiceoi>
    break;
801089ac:	e9 1c 01 00 00       	jmp    80108acd <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801089b1:	e8 e3 a1 ff ff       	call   80102b99 <ideintr>
    lapiceoi();
801089b6:	e8 cb a9 ff ff       	call   80103386 <lapiceoi>
    break;
801089bb:	e9 0d 01 00 00       	jmp    80108acd <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801089c0:	e8 c3 a7 ff ff       	call   80103188 <kbdintr>
    lapiceoi();
801089c5:	e8 bc a9 ff ff       	call   80103386 <lapiceoi>
    break;
801089ca:	e9 fe 00 00 00       	jmp    80108acd <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801089cf:	e8 83 03 00 00       	call   80108d57 <uartintr>
    lapiceoi();
801089d4:	e8 ad a9 ff ff       	call   80103386 <lapiceoi>
    break;
801089d9:	e9 ef 00 00 00       	jmp    80108acd <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801089de:	8b 45 08             	mov    0x8(%ebp),%eax
801089e1:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801089e4:	8b 45 08             	mov    0x8(%ebp),%eax
801089e7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801089eb:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801089ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801089f4:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801089f7:	0f b6 c0             	movzbl %al,%eax
801089fa:	51                   	push   %ecx
801089fb:	52                   	push   %edx
801089fc:	50                   	push   %eax
801089fd:	68 00 ae 10 80       	push   $0x8010ae00
80108a02:	e8 bf 79 ff ff       	call   801003c6 <cprintf>
80108a07:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80108a0a:	e8 77 a9 ff ff       	call   80103386 <lapiceoi>
    break;
80108a0f:	e9 b9 00 00 00       	jmp    80108acd <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80108a14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a1a:	85 c0                	test   %eax,%eax
80108a1c:	74 11                	je     80108a2f <trap+0x122>
80108a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a21:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108a25:	0f b7 c0             	movzwl %ax,%eax
80108a28:	83 e0 03             	and    $0x3,%eax
80108a2b:	85 c0                	test   %eax,%eax
80108a2d:	75 40                	jne    80108a6f <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108a2f:	e8 4f fd ff ff       	call   80108783 <rcr2>
80108a34:	89 c3                	mov    %eax,%ebx
80108a36:	8b 45 08             	mov    0x8(%ebp),%eax
80108a39:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80108a3c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108a42:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108a45:	0f b6 d0             	movzbl %al,%edx
80108a48:	8b 45 08             	mov    0x8(%ebp),%eax
80108a4b:	8b 40 30             	mov    0x30(%eax),%eax
80108a4e:	83 ec 0c             	sub    $0xc,%esp
80108a51:	53                   	push   %ebx
80108a52:	51                   	push   %ecx
80108a53:	52                   	push   %edx
80108a54:	50                   	push   %eax
80108a55:	68 24 ae 10 80       	push   $0x8010ae24
80108a5a:	e8 67 79 ff ff       	call   801003c6 <cprintf>
80108a5f:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80108a62:	83 ec 0c             	sub    $0xc,%esp
80108a65:	68 56 ae 10 80       	push   $0x8010ae56
80108a6a:	e8 f7 7a ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108a6f:	e8 0f fd ff ff       	call   80108783 <rcr2>
80108a74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108a77:	8b 45 08             	mov    0x8(%ebp),%eax
80108a7a:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108a7d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108a83:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108a86:	0f b6 d8             	movzbl %al,%ebx
80108a89:	8b 45 08             	mov    0x8(%ebp),%eax
80108a8c:	8b 48 34             	mov    0x34(%eax),%ecx
80108a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80108a92:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108a95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a9b:	8d 78 6c             	lea    0x6c(%eax),%edi
80108a9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108aa4:	8b 40 10             	mov    0x10(%eax),%eax
80108aa7:	ff 75 e4             	pushl  -0x1c(%ebp)
80108aaa:	56                   	push   %esi
80108aab:	53                   	push   %ebx
80108aac:	51                   	push   %ecx
80108aad:	52                   	push   %edx
80108aae:	57                   	push   %edi
80108aaf:	50                   	push   %eax
80108ab0:	68 5c ae 10 80       	push   $0x8010ae5c
80108ab5:	e8 0c 79 ff ff       	call   801003c6 <cprintf>
80108aba:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80108abd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ac3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80108aca:	eb 01                	jmp    80108acd <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80108acc:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80108acd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ad3:	85 c0                	test   %eax,%eax
80108ad5:	74 24                	je     80108afb <trap+0x1ee>
80108ad7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108add:	8b 40 24             	mov    0x24(%eax),%eax
80108ae0:	85 c0                	test   %eax,%eax
80108ae2:	74 17                	je     80108afb <trap+0x1ee>
80108ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108aeb:	0f b7 c0             	movzwl %ax,%eax
80108aee:	83 e0 03             	and    $0x3,%eax
80108af1:	83 f8 03             	cmp    $0x3,%eax
80108af4:	75 05                	jne    80108afb <trap+0x1ee>
    exit();
80108af6:	e8 fb c5 ff ff       	call   801050f6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108afb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b01:	85 c0                	test   %eax,%eax
80108b03:	74 41                	je     80108b46 <trap+0x239>
80108b05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80108b0e:	83 f8 04             	cmp    $0x4,%eax
80108b11:	75 33                	jne    80108b46 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108b13:	8b 45 08             	mov    0x8(%ebp),%eax
80108b16:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108b19:	83 f8 20             	cmp    $0x20,%eax
80108b1c:	75 28                	jne    80108b46 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108b1e:	8b 0d e0 88 11 80    	mov    0x801188e0,%ecx
80108b24:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80108b29:	89 c8                	mov    %ecx,%eax
80108b2b:	f7 e2                	mul    %edx
80108b2d:	c1 ea 03             	shr    $0x3,%edx
80108b30:	89 d0                	mov    %edx,%eax
80108b32:	c1 e0 02             	shl    $0x2,%eax
80108b35:	01 d0                	add    %edx,%eax
80108b37:	01 c0                	add    %eax,%eax
80108b39:	29 c1                	sub    %eax,%ecx
80108b3b:	89 ca                	mov    %ecx,%edx
80108b3d:	85 d2                	test   %edx,%edx
80108b3f:	75 05                	jne    80108b46 <trap+0x239>
    yield();
80108b41:	e8 99 cd ff ff       	call   801058df <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80108b46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b4c:	85 c0                	test   %eax,%eax
80108b4e:	74 27                	je     80108b77 <trap+0x26a>
80108b50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b56:	8b 40 24             	mov    0x24(%eax),%eax
80108b59:	85 c0                	test   %eax,%eax
80108b5b:	74 1a                	je     80108b77 <trap+0x26a>
80108b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80108b60:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108b64:	0f b7 c0             	movzwl %ax,%eax
80108b67:	83 e0 03             	and    $0x3,%eax
80108b6a:	83 f8 03             	cmp    $0x3,%eax
80108b6d:	75 08                	jne    80108b77 <trap+0x26a>
    exit();
80108b6f:	e8 82 c5 ff ff       	call   801050f6 <exit>
80108b74:	eb 01                	jmp    80108b77 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80108b76:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80108b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108b7a:	5b                   	pop    %ebx
80108b7b:	5e                   	pop    %esi
80108b7c:	5f                   	pop    %edi
80108b7d:	5d                   	pop    %ebp
80108b7e:	c3                   	ret    

80108b7f <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108b7f:	55                   	push   %ebp
80108b80:	89 e5                	mov    %esp,%ebp
80108b82:	83 ec 14             	sub    $0x14,%esp
80108b85:	8b 45 08             	mov    0x8(%ebp),%eax
80108b88:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108b8c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108b90:	89 c2                	mov    %eax,%edx
80108b92:	ec                   	in     (%dx),%al
80108b93:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108b96:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108b9a:	c9                   	leave  
80108b9b:	c3                   	ret    

80108b9c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80108b9c:	55                   	push   %ebp
80108b9d:	89 e5                	mov    %esp,%ebp
80108b9f:	83 ec 08             	sub    $0x8,%esp
80108ba2:	8b 55 08             	mov    0x8(%ebp),%edx
80108ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108bac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108baf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108bb3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108bb7:	ee                   	out    %al,(%dx)
}
80108bb8:	90                   	nop
80108bb9:	c9                   	leave  
80108bba:	c3                   	ret    

80108bbb <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80108bbb:	55                   	push   %ebp
80108bbc:	89 e5                	mov    %esp,%ebp
80108bbe:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80108bc1:	6a 00                	push   $0x0
80108bc3:	68 fa 03 00 00       	push   $0x3fa
80108bc8:	e8 cf ff ff ff       	call   80108b9c <outb>
80108bcd:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108bd0:	68 80 00 00 00       	push   $0x80
80108bd5:	68 fb 03 00 00       	push   $0x3fb
80108bda:	e8 bd ff ff ff       	call   80108b9c <outb>
80108bdf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108be2:	6a 0c                	push   $0xc
80108be4:	68 f8 03 00 00       	push   $0x3f8
80108be9:	e8 ae ff ff ff       	call   80108b9c <outb>
80108bee:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108bf1:	6a 00                	push   $0x0
80108bf3:	68 f9 03 00 00       	push   $0x3f9
80108bf8:	e8 9f ff ff ff       	call   80108b9c <outb>
80108bfd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108c00:	6a 03                	push   $0x3
80108c02:	68 fb 03 00 00       	push   $0x3fb
80108c07:	e8 90 ff ff ff       	call   80108b9c <outb>
80108c0c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108c0f:	6a 00                	push   $0x0
80108c11:	68 fc 03 00 00       	push   $0x3fc
80108c16:	e8 81 ff ff ff       	call   80108b9c <outb>
80108c1b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80108c1e:	6a 01                	push   $0x1
80108c20:	68 f9 03 00 00       	push   $0x3f9
80108c25:	e8 72 ff ff ff       	call   80108b9c <outb>
80108c2a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80108c2d:	68 fd 03 00 00       	push   $0x3fd
80108c32:	e8 48 ff ff ff       	call   80108b7f <inb>
80108c37:	83 c4 04             	add    $0x4,%esp
80108c3a:	3c ff                	cmp    $0xff,%al
80108c3c:	74 6e                	je     80108cac <uartinit+0xf1>
    return;
  uart = 1;
80108c3e:	c7 05 6c e6 10 80 01 	movl   $0x1,0x8010e66c
80108c45:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80108c48:	68 fa 03 00 00       	push   $0x3fa
80108c4d:	e8 2d ff ff ff       	call   80108b7f <inb>
80108c52:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80108c55:	68 f8 03 00 00       	push   $0x3f8
80108c5a:	e8 20 ff ff ff       	call   80108b7f <inb>
80108c5f:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80108c62:	83 ec 0c             	sub    $0xc,%esp
80108c65:	6a 04                	push   $0x4
80108c67:	e8 20 b6 ff ff       	call   8010428c <picenable>
80108c6c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108c6f:	83 ec 08             	sub    $0x8,%esp
80108c72:	6a 00                	push   $0x0
80108c74:	6a 04                	push   $0x4
80108c76:	e8 c0 a1 ff ff       	call   80102e3b <ioapicenable>
80108c7b:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108c7e:	c7 45 f4 20 af 10 80 	movl   $0x8010af20,-0xc(%ebp)
80108c85:	eb 19                	jmp    80108ca0 <uartinit+0xe5>
    uartputc(*p);
80108c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8a:	0f b6 00             	movzbl (%eax),%eax
80108c8d:	0f be c0             	movsbl %al,%eax
80108c90:	83 ec 0c             	sub    $0xc,%esp
80108c93:	50                   	push   %eax
80108c94:	e8 16 00 00 00       	call   80108caf <uartputc>
80108c99:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108c9c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca3:	0f b6 00             	movzbl (%eax),%eax
80108ca6:	84 c0                	test   %al,%al
80108ca8:	75 dd                	jne    80108c87 <uartinit+0xcc>
80108caa:	eb 01                	jmp    80108cad <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80108cac:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80108cad:	c9                   	leave  
80108cae:	c3                   	ret    

80108caf <uartputc>:

void
uartputc(int c)
{
80108caf:	55                   	push   %ebp
80108cb0:	89 e5                	mov    %esp,%ebp
80108cb2:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80108cb5:	a1 6c e6 10 80       	mov    0x8010e66c,%eax
80108cba:	85 c0                	test   %eax,%eax
80108cbc:	74 53                	je     80108d11 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80108cbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cc5:	eb 11                	jmp    80108cd8 <uartputc+0x29>
    microdelay(10);
80108cc7:	83 ec 0c             	sub    $0xc,%esp
80108cca:	6a 0a                	push   $0xa
80108ccc:	e8 d0 a6 ff ff       	call   801033a1 <microdelay>
80108cd1:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80108cd4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108cd8:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108cdc:	7f 1a                	jg     80108cf8 <uartputc+0x49>
80108cde:	83 ec 0c             	sub    $0xc,%esp
80108ce1:	68 fd 03 00 00       	push   $0x3fd
80108ce6:	e8 94 fe ff ff       	call   80108b7f <inb>
80108ceb:	83 c4 10             	add    $0x10,%esp
80108cee:	0f b6 c0             	movzbl %al,%eax
80108cf1:	83 e0 20             	and    $0x20,%eax
80108cf4:	85 c0                	test   %eax,%eax
80108cf6:	74 cf                	je     80108cc7 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80108cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80108cfb:	0f b6 c0             	movzbl %al,%eax
80108cfe:	83 ec 08             	sub    $0x8,%esp
80108d01:	50                   	push   %eax
80108d02:	68 f8 03 00 00       	push   $0x3f8
80108d07:	e8 90 fe ff ff       	call   80108b9c <outb>
80108d0c:	83 c4 10             	add    $0x10,%esp
80108d0f:	eb 01                	jmp    80108d12 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80108d11:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80108d12:	c9                   	leave  
80108d13:	c3                   	ret    

80108d14 <uartgetc>:

static int
uartgetc(void)
{
80108d14:	55                   	push   %ebp
80108d15:	89 e5                	mov    %esp,%ebp
  if(!uart)
80108d17:	a1 6c e6 10 80       	mov    0x8010e66c,%eax
80108d1c:	85 c0                	test   %eax,%eax
80108d1e:	75 07                	jne    80108d27 <uartgetc+0x13>
    return -1;
80108d20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d25:	eb 2e                	jmp    80108d55 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80108d27:	68 fd 03 00 00       	push   $0x3fd
80108d2c:	e8 4e fe ff ff       	call   80108b7f <inb>
80108d31:	83 c4 04             	add    $0x4,%esp
80108d34:	0f b6 c0             	movzbl %al,%eax
80108d37:	83 e0 01             	and    $0x1,%eax
80108d3a:	85 c0                	test   %eax,%eax
80108d3c:	75 07                	jne    80108d45 <uartgetc+0x31>
    return -1;
80108d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d43:	eb 10                	jmp    80108d55 <uartgetc+0x41>
  return inb(COM1+0);
80108d45:	68 f8 03 00 00       	push   $0x3f8
80108d4a:	e8 30 fe ff ff       	call   80108b7f <inb>
80108d4f:	83 c4 04             	add    $0x4,%esp
80108d52:	0f b6 c0             	movzbl %al,%eax
}
80108d55:	c9                   	leave  
80108d56:	c3                   	ret    

80108d57 <uartintr>:

void
uartintr(void)
{
80108d57:	55                   	push   %ebp
80108d58:	89 e5                	mov    %esp,%ebp
80108d5a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108d5d:	83 ec 0c             	sub    $0xc,%esp
80108d60:	68 14 8d 10 80       	push   $0x80108d14
80108d65:	e8 8f 7a ff ff       	call   801007f9 <consoleintr>
80108d6a:	83 c4 10             	add    $0x10,%esp
}
80108d6d:	90                   	nop
80108d6e:	c9                   	leave  
80108d6f:	c3                   	ret    

80108d70 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108d70:	6a 00                	push   $0x0
  pushl $0
80108d72:	6a 00                	push   $0x0
  jmp alltraps
80108d74:	e9 a9 f9 ff ff       	jmp    80108722 <alltraps>

80108d79 <vector1>:
.globl vector1
vector1:
  pushl $0
80108d79:	6a 00                	push   $0x0
  pushl $1
80108d7b:	6a 01                	push   $0x1
  jmp alltraps
80108d7d:	e9 a0 f9 ff ff       	jmp    80108722 <alltraps>

80108d82 <vector2>:
.globl vector2
vector2:
  pushl $0
80108d82:	6a 00                	push   $0x0
  pushl $2
80108d84:	6a 02                	push   $0x2
  jmp alltraps
80108d86:	e9 97 f9 ff ff       	jmp    80108722 <alltraps>

80108d8b <vector3>:
.globl vector3
vector3:
  pushl $0
80108d8b:	6a 00                	push   $0x0
  pushl $3
80108d8d:	6a 03                	push   $0x3
  jmp alltraps
80108d8f:	e9 8e f9 ff ff       	jmp    80108722 <alltraps>

80108d94 <vector4>:
.globl vector4
vector4:
  pushl $0
80108d94:	6a 00                	push   $0x0
  pushl $4
80108d96:	6a 04                	push   $0x4
  jmp alltraps
80108d98:	e9 85 f9 ff ff       	jmp    80108722 <alltraps>

80108d9d <vector5>:
.globl vector5
vector5:
  pushl $0
80108d9d:	6a 00                	push   $0x0
  pushl $5
80108d9f:	6a 05                	push   $0x5
  jmp alltraps
80108da1:	e9 7c f9 ff ff       	jmp    80108722 <alltraps>

80108da6 <vector6>:
.globl vector6
vector6:
  pushl $0
80108da6:	6a 00                	push   $0x0
  pushl $6
80108da8:	6a 06                	push   $0x6
  jmp alltraps
80108daa:	e9 73 f9 ff ff       	jmp    80108722 <alltraps>

80108daf <vector7>:
.globl vector7
vector7:
  pushl $0
80108daf:	6a 00                	push   $0x0
  pushl $7
80108db1:	6a 07                	push   $0x7
  jmp alltraps
80108db3:	e9 6a f9 ff ff       	jmp    80108722 <alltraps>

80108db8 <vector8>:
.globl vector8
vector8:
  pushl $8
80108db8:	6a 08                	push   $0x8
  jmp alltraps
80108dba:	e9 63 f9 ff ff       	jmp    80108722 <alltraps>

80108dbf <vector9>:
.globl vector9
vector9:
  pushl $0
80108dbf:	6a 00                	push   $0x0
  pushl $9
80108dc1:	6a 09                	push   $0x9
  jmp alltraps
80108dc3:	e9 5a f9 ff ff       	jmp    80108722 <alltraps>

80108dc8 <vector10>:
.globl vector10
vector10:
  pushl $10
80108dc8:	6a 0a                	push   $0xa
  jmp alltraps
80108dca:	e9 53 f9 ff ff       	jmp    80108722 <alltraps>

80108dcf <vector11>:
.globl vector11
vector11:
  pushl $11
80108dcf:	6a 0b                	push   $0xb
  jmp alltraps
80108dd1:	e9 4c f9 ff ff       	jmp    80108722 <alltraps>

80108dd6 <vector12>:
.globl vector12
vector12:
  pushl $12
80108dd6:	6a 0c                	push   $0xc
  jmp alltraps
80108dd8:	e9 45 f9 ff ff       	jmp    80108722 <alltraps>

80108ddd <vector13>:
.globl vector13
vector13:
  pushl $13
80108ddd:	6a 0d                	push   $0xd
  jmp alltraps
80108ddf:	e9 3e f9 ff ff       	jmp    80108722 <alltraps>

80108de4 <vector14>:
.globl vector14
vector14:
  pushl $14
80108de4:	6a 0e                	push   $0xe
  jmp alltraps
80108de6:	e9 37 f9 ff ff       	jmp    80108722 <alltraps>

80108deb <vector15>:
.globl vector15
vector15:
  pushl $0
80108deb:	6a 00                	push   $0x0
  pushl $15
80108ded:	6a 0f                	push   $0xf
  jmp alltraps
80108def:	e9 2e f9 ff ff       	jmp    80108722 <alltraps>

80108df4 <vector16>:
.globl vector16
vector16:
  pushl $0
80108df4:	6a 00                	push   $0x0
  pushl $16
80108df6:	6a 10                	push   $0x10
  jmp alltraps
80108df8:	e9 25 f9 ff ff       	jmp    80108722 <alltraps>

80108dfd <vector17>:
.globl vector17
vector17:
  pushl $17
80108dfd:	6a 11                	push   $0x11
  jmp alltraps
80108dff:	e9 1e f9 ff ff       	jmp    80108722 <alltraps>

80108e04 <vector18>:
.globl vector18
vector18:
  pushl $0
80108e04:	6a 00                	push   $0x0
  pushl $18
80108e06:	6a 12                	push   $0x12
  jmp alltraps
80108e08:	e9 15 f9 ff ff       	jmp    80108722 <alltraps>

80108e0d <vector19>:
.globl vector19
vector19:
  pushl $0
80108e0d:	6a 00                	push   $0x0
  pushl $19
80108e0f:	6a 13                	push   $0x13
  jmp alltraps
80108e11:	e9 0c f9 ff ff       	jmp    80108722 <alltraps>

80108e16 <vector20>:
.globl vector20
vector20:
  pushl $0
80108e16:	6a 00                	push   $0x0
  pushl $20
80108e18:	6a 14                	push   $0x14
  jmp alltraps
80108e1a:	e9 03 f9 ff ff       	jmp    80108722 <alltraps>

80108e1f <vector21>:
.globl vector21
vector21:
  pushl $0
80108e1f:	6a 00                	push   $0x0
  pushl $21
80108e21:	6a 15                	push   $0x15
  jmp alltraps
80108e23:	e9 fa f8 ff ff       	jmp    80108722 <alltraps>

80108e28 <vector22>:
.globl vector22
vector22:
  pushl $0
80108e28:	6a 00                	push   $0x0
  pushl $22
80108e2a:	6a 16                	push   $0x16
  jmp alltraps
80108e2c:	e9 f1 f8 ff ff       	jmp    80108722 <alltraps>

80108e31 <vector23>:
.globl vector23
vector23:
  pushl $0
80108e31:	6a 00                	push   $0x0
  pushl $23
80108e33:	6a 17                	push   $0x17
  jmp alltraps
80108e35:	e9 e8 f8 ff ff       	jmp    80108722 <alltraps>

80108e3a <vector24>:
.globl vector24
vector24:
  pushl $0
80108e3a:	6a 00                	push   $0x0
  pushl $24
80108e3c:	6a 18                	push   $0x18
  jmp alltraps
80108e3e:	e9 df f8 ff ff       	jmp    80108722 <alltraps>

80108e43 <vector25>:
.globl vector25
vector25:
  pushl $0
80108e43:	6a 00                	push   $0x0
  pushl $25
80108e45:	6a 19                	push   $0x19
  jmp alltraps
80108e47:	e9 d6 f8 ff ff       	jmp    80108722 <alltraps>

80108e4c <vector26>:
.globl vector26
vector26:
  pushl $0
80108e4c:	6a 00                	push   $0x0
  pushl $26
80108e4e:	6a 1a                	push   $0x1a
  jmp alltraps
80108e50:	e9 cd f8 ff ff       	jmp    80108722 <alltraps>

80108e55 <vector27>:
.globl vector27
vector27:
  pushl $0
80108e55:	6a 00                	push   $0x0
  pushl $27
80108e57:	6a 1b                	push   $0x1b
  jmp alltraps
80108e59:	e9 c4 f8 ff ff       	jmp    80108722 <alltraps>

80108e5e <vector28>:
.globl vector28
vector28:
  pushl $0
80108e5e:	6a 00                	push   $0x0
  pushl $28
80108e60:	6a 1c                	push   $0x1c
  jmp alltraps
80108e62:	e9 bb f8 ff ff       	jmp    80108722 <alltraps>

80108e67 <vector29>:
.globl vector29
vector29:
  pushl $0
80108e67:	6a 00                	push   $0x0
  pushl $29
80108e69:	6a 1d                	push   $0x1d
  jmp alltraps
80108e6b:	e9 b2 f8 ff ff       	jmp    80108722 <alltraps>

80108e70 <vector30>:
.globl vector30
vector30:
  pushl $0
80108e70:	6a 00                	push   $0x0
  pushl $30
80108e72:	6a 1e                	push   $0x1e
  jmp alltraps
80108e74:	e9 a9 f8 ff ff       	jmp    80108722 <alltraps>

80108e79 <vector31>:
.globl vector31
vector31:
  pushl $0
80108e79:	6a 00                	push   $0x0
  pushl $31
80108e7b:	6a 1f                	push   $0x1f
  jmp alltraps
80108e7d:	e9 a0 f8 ff ff       	jmp    80108722 <alltraps>

80108e82 <vector32>:
.globl vector32
vector32:
  pushl $0
80108e82:	6a 00                	push   $0x0
  pushl $32
80108e84:	6a 20                	push   $0x20
  jmp alltraps
80108e86:	e9 97 f8 ff ff       	jmp    80108722 <alltraps>

80108e8b <vector33>:
.globl vector33
vector33:
  pushl $0
80108e8b:	6a 00                	push   $0x0
  pushl $33
80108e8d:	6a 21                	push   $0x21
  jmp alltraps
80108e8f:	e9 8e f8 ff ff       	jmp    80108722 <alltraps>

80108e94 <vector34>:
.globl vector34
vector34:
  pushl $0
80108e94:	6a 00                	push   $0x0
  pushl $34
80108e96:	6a 22                	push   $0x22
  jmp alltraps
80108e98:	e9 85 f8 ff ff       	jmp    80108722 <alltraps>

80108e9d <vector35>:
.globl vector35
vector35:
  pushl $0
80108e9d:	6a 00                	push   $0x0
  pushl $35
80108e9f:	6a 23                	push   $0x23
  jmp alltraps
80108ea1:	e9 7c f8 ff ff       	jmp    80108722 <alltraps>

80108ea6 <vector36>:
.globl vector36
vector36:
  pushl $0
80108ea6:	6a 00                	push   $0x0
  pushl $36
80108ea8:	6a 24                	push   $0x24
  jmp alltraps
80108eaa:	e9 73 f8 ff ff       	jmp    80108722 <alltraps>

80108eaf <vector37>:
.globl vector37
vector37:
  pushl $0
80108eaf:	6a 00                	push   $0x0
  pushl $37
80108eb1:	6a 25                	push   $0x25
  jmp alltraps
80108eb3:	e9 6a f8 ff ff       	jmp    80108722 <alltraps>

80108eb8 <vector38>:
.globl vector38
vector38:
  pushl $0
80108eb8:	6a 00                	push   $0x0
  pushl $38
80108eba:	6a 26                	push   $0x26
  jmp alltraps
80108ebc:	e9 61 f8 ff ff       	jmp    80108722 <alltraps>

80108ec1 <vector39>:
.globl vector39
vector39:
  pushl $0
80108ec1:	6a 00                	push   $0x0
  pushl $39
80108ec3:	6a 27                	push   $0x27
  jmp alltraps
80108ec5:	e9 58 f8 ff ff       	jmp    80108722 <alltraps>

80108eca <vector40>:
.globl vector40
vector40:
  pushl $0
80108eca:	6a 00                	push   $0x0
  pushl $40
80108ecc:	6a 28                	push   $0x28
  jmp alltraps
80108ece:	e9 4f f8 ff ff       	jmp    80108722 <alltraps>

80108ed3 <vector41>:
.globl vector41
vector41:
  pushl $0
80108ed3:	6a 00                	push   $0x0
  pushl $41
80108ed5:	6a 29                	push   $0x29
  jmp alltraps
80108ed7:	e9 46 f8 ff ff       	jmp    80108722 <alltraps>

80108edc <vector42>:
.globl vector42
vector42:
  pushl $0
80108edc:	6a 00                	push   $0x0
  pushl $42
80108ede:	6a 2a                	push   $0x2a
  jmp alltraps
80108ee0:	e9 3d f8 ff ff       	jmp    80108722 <alltraps>

80108ee5 <vector43>:
.globl vector43
vector43:
  pushl $0
80108ee5:	6a 00                	push   $0x0
  pushl $43
80108ee7:	6a 2b                	push   $0x2b
  jmp alltraps
80108ee9:	e9 34 f8 ff ff       	jmp    80108722 <alltraps>

80108eee <vector44>:
.globl vector44
vector44:
  pushl $0
80108eee:	6a 00                	push   $0x0
  pushl $44
80108ef0:	6a 2c                	push   $0x2c
  jmp alltraps
80108ef2:	e9 2b f8 ff ff       	jmp    80108722 <alltraps>

80108ef7 <vector45>:
.globl vector45
vector45:
  pushl $0
80108ef7:	6a 00                	push   $0x0
  pushl $45
80108ef9:	6a 2d                	push   $0x2d
  jmp alltraps
80108efb:	e9 22 f8 ff ff       	jmp    80108722 <alltraps>

80108f00 <vector46>:
.globl vector46
vector46:
  pushl $0
80108f00:	6a 00                	push   $0x0
  pushl $46
80108f02:	6a 2e                	push   $0x2e
  jmp alltraps
80108f04:	e9 19 f8 ff ff       	jmp    80108722 <alltraps>

80108f09 <vector47>:
.globl vector47
vector47:
  pushl $0
80108f09:	6a 00                	push   $0x0
  pushl $47
80108f0b:	6a 2f                	push   $0x2f
  jmp alltraps
80108f0d:	e9 10 f8 ff ff       	jmp    80108722 <alltraps>

80108f12 <vector48>:
.globl vector48
vector48:
  pushl $0
80108f12:	6a 00                	push   $0x0
  pushl $48
80108f14:	6a 30                	push   $0x30
  jmp alltraps
80108f16:	e9 07 f8 ff ff       	jmp    80108722 <alltraps>

80108f1b <vector49>:
.globl vector49
vector49:
  pushl $0
80108f1b:	6a 00                	push   $0x0
  pushl $49
80108f1d:	6a 31                	push   $0x31
  jmp alltraps
80108f1f:	e9 fe f7 ff ff       	jmp    80108722 <alltraps>

80108f24 <vector50>:
.globl vector50
vector50:
  pushl $0
80108f24:	6a 00                	push   $0x0
  pushl $50
80108f26:	6a 32                	push   $0x32
  jmp alltraps
80108f28:	e9 f5 f7 ff ff       	jmp    80108722 <alltraps>

80108f2d <vector51>:
.globl vector51
vector51:
  pushl $0
80108f2d:	6a 00                	push   $0x0
  pushl $51
80108f2f:	6a 33                	push   $0x33
  jmp alltraps
80108f31:	e9 ec f7 ff ff       	jmp    80108722 <alltraps>

80108f36 <vector52>:
.globl vector52
vector52:
  pushl $0
80108f36:	6a 00                	push   $0x0
  pushl $52
80108f38:	6a 34                	push   $0x34
  jmp alltraps
80108f3a:	e9 e3 f7 ff ff       	jmp    80108722 <alltraps>

80108f3f <vector53>:
.globl vector53
vector53:
  pushl $0
80108f3f:	6a 00                	push   $0x0
  pushl $53
80108f41:	6a 35                	push   $0x35
  jmp alltraps
80108f43:	e9 da f7 ff ff       	jmp    80108722 <alltraps>

80108f48 <vector54>:
.globl vector54
vector54:
  pushl $0
80108f48:	6a 00                	push   $0x0
  pushl $54
80108f4a:	6a 36                	push   $0x36
  jmp alltraps
80108f4c:	e9 d1 f7 ff ff       	jmp    80108722 <alltraps>

80108f51 <vector55>:
.globl vector55
vector55:
  pushl $0
80108f51:	6a 00                	push   $0x0
  pushl $55
80108f53:	6a 37                	push   $0x37
  jmp alltraps
80108f55:	e9 c8 f7 ff ff       	jmp    80108722 <alltraps>

80108f5a <vector56>:
.globl vector56
vector56:
  pushl $0
80108f5a:	6a 00                	push   $0x0
  pushl $56
80108f5c:	6a 38                	push   $0x38
  jmp alltraps
80108f5e:	e9 bf f7 ff ff       	jmp    80108722 <alltraps>

80108f63 <vector57>:
.globl vector57
vector57:
  pushl $0
80108f63:	6a 00                	push   $0x0
  pushl $57
80108f65:	6a 39                	push   $0x39
  jmp alltraps
80108f67:	e9 b6 f7 ff ff       	jmp    80108722 <alltraps>

80108f6c <vector58>:
.globl vector58
vector58:
  pushl $0
80108f6c:	6a 00                	push   $0x0
  pushl $58
80108f6e:	6a 3a                	push   $0x3a
  jmp alltraps
80108f70:	e9 ad f7 ff ff       	jmp    80108722 <alltraps>

80108f75 <vector59>:
.globl vector59
vector59:
  pushl $0
80108f75:	6a 00                	push   $0x0
  pushl $59
80108f77:	6a 3b                	push   $0x3b
  jmp alltraps
80108f79:	e9 a4 f7 ff ff       	jmp    80108722 <alltraps>

80108f7e <vector60>:
.globl vector60
vector60:
  pushl $0
80108f7e:	6a 00                	push   $0x0
  pushl $60
80108f80:	6a 3c                	push   $0x3c
  jmp alltraps
80108f82:	e9 9b f7 ff ff       	jmp    80108722 <alltraps>

80108f87 <vector61>:
.globl vector61
vector61:
  pushl $0
80108f87:	6a 00                	push   $0x0
  pushl $61
80108f89:	6a 3d                	push   $0x3d
  jmp alltraps
80108f8b:	e9 92 f7 ff ff       	jmp    80108722 <alltraps>

80108f90 <vector62>:
.globl vector62
vector62:
  pushl $0
80108f90:	6a 00                	push   $0x0
  pushl $62
80108f92:	6a 3e                	push   $0x3e
  jmp alltraps
80108f94:	e9 89 f7 ff ff       	jmp    80108722 <alltraps>

80108f99 <vector63>:
.globl vector63
vector63:
  pushl $0
80108f99:	6a 00                	push   $0x0
  pushl $63
80108f9b:	6a 3f                	push   $0x3f
  jmp alltraps
80108f9d:	e9 80 f7 ff ff       	jmp    80108722 <alltraps>

80108fa2 <vector64>:
.globl vector64
vector64:
  pushl $0
80108fa2:	6a 00                	push   $0x0
  pushl $64
80108fa4:	6a 40                	push   $0x40
  jmp alltraps
80108fa6:	e9 77 f7 ff ff       	jmp    80108722 <alltraps>

80108fab <vector65>:
.globl vector65
vector65:
  pushl $0
80108fab:	6a 00                	push   $0x0
  pushl $65
80108fad:	6a 41                	push   $0x41
  jmp alltraps
80108faf:	e9 6e f7 ff ff       	jmp    80108722 <alltraps>

80108fb4 <vector66>:
.globl vector66
vector66:
  pushl $0
80108fb4:	6a 00                	push   $0x0
  pushl $66
80108fb6:	6a 42                	push   $0x42
  jmp alltraps
80108fb8:	e9 65 f7 ff ff       	jmp    80108722 <alltraps>

80108fbd <vector67>:
.globl vector67
vector67:
  pushl $0
80108fbd:	6a 00                	push   $0x0
  pushl $67
80108fbf:	6a 43                	push   $0x43
  jmp alltraps
80108fc1:	e9 5c f7 ff ff       	jmp    80108722 <alltraps>

80108fc6 <vector68>:
.globl vector68
vector68:
  pushl $0
80108fc6:	6a 00                	push   $0x0
  pushl $68
80108fc8:	6a 44                	push   $0x44
  jmp alltraps
80108fca:	e9 53 f7 ff ff       	jmp    80108722 <alltraps>

80108fcf <vector69>:
.globl vector69
vector69:
  pushl $0
80108fcf:	6a 00                	push   $0x0
  pushl $69
80108fd1:	6a 45                	push   $0x45
  jmp alltraps
80108fd3:	e9 4a f7 ff ff       	jmp    80108722 <alltraps>

80108fd8 <vector70>:
.globl vector70
vector70:
  pushl $0
80108fd8:	6a 00                	push   $0x0
  pushl $70
80108fda:	6a 46                	push   $0x46
  jmp alltraps
80108fdc:	e9 41 f7 ff ff       	jmp    80108722 <alltraps>

80108fe1 <vector71>:
.globl vector71
vector71:
  pushl $0
80108fe1:	6a 00                	push   $0x0
  pushl $71
80108fe3:	6a 47                	push   $0x47
  jmp alltraps
80108fe5:	e9 38 f7 ff ff       	jmp    80108722 <alltraps>

80108fea <vector72>:
.globl vector72
vector72:
  pushl $0
80108fea:	6a 00                	push   $0x0
  pushl $72
80108fec:	6a 48                	push   $0x48
  jmp alltraps
80108fee:	e9 2f f7 ff ff       	jmp    80108722 <alltraps>

80108ff3 <vector73>:
.globl vector73
vector73:
  pushl $0
80108ff3:	6a 00                	push   $0x0
  pushl $73
80108ff5:	6a 49                	push   $0x49
  jmp alltraps
80108ff7:	e9 26 f7 ff ff       	jmp    80108722 <alltraps>

80108ffc <vector74>:
.globl vector74
vector74:
  pushl $0
80108ffc:	6a 00                	push   $0x0
  pushl $74
80108ffe:	6a 4a                	push   $0x4a
  jmp alltraps
80109000:	e9 1d f7 ff ff       	jmp    80108722 <alltraps>

80109005 <vector75>:
.globl vector75
vector75:
  pushl $0
80109005:	6a 00                	push   $0x0
  pushl $75
80109007:	6a 4b                	push   $0x4b
  jmp alltraps
80109009:	e9 14 f7 ff ff       	jmp    80108722 <alltraps>

8010900e <vector76>:
.globl vector76
vector76:
  pushl $0
8010900e:	6a 00                	push   $0x0
  pushl $76
80109010:	6a 4c                	push   $0x4c
  jmp alltraps
80109012:	e9 0b f7 ff ff       	jmp    80108722 <alltraps>

80109017 <vector77>:
.globl vector77
vector77:
  pushl $0
80109017:	6a 00                	push   $0x0
  pushl $77
80109019:	6a 4d                	push   $0x4d
  jmp alltraps
8010901b:	e9 02 f7 ff ff       	jmp    80108722 <alltraps>

80109020 <vector78>:
.globl vector78
vector78:
  pushl $0
80109020:	6a 00                	push   $0x0
  pushl $78
80109022:	6a 4e                	push   $0x4e
  jmp alltraps
80109024:	e9 f9 f6 ff ff       	jmp    80108722 <alltraps>

80109029 <vector79>:
.globl vector79
vector79:
  pushl $0
80109029:	6a 00                	push   $0x0
  pushl $79
8010902b:	6a 4f                	push   $0x4f
  jmp alltraps
8010902d:	e9 f0 f6 ff ff       	jmp    80108722 <alltraps>

80109032 <vector80>:
.globl vector80
vector80:
  pushl $0
80109032:	6a 00                	push   $0x0
  pushl $80
80109034:	6a 50                	push   $0x50
  jmp alltraps
80109036:	e9 e7 f6 ff ff       	jmp    80108722 <alltraps>

8010903b <vector81>:
.globl vector81
vector81:
  pushl $0
8010903b:	6a 00                	push   $0x0
  pushl $81
8010903d:	6a 51                	push   $0x51
  jmp alltraps
8010903f:	e9 de f6 ff ff       	jmp    80108722 <alltraps>

80109044 <vector82>:
.globl vector82
vector82:
  pushl $0
80109044:	6a 00                	push   $0x0
  pushl $82
80109046:	6a 52                	push   $0x52
  jmp alltraps
80109048:	e9 d5 f6 ff ff       	jmp    80108722 <alltraps>

8010904d <vector83>:
.globl vector83
vector83:
  pushl $0
8010904d:	6a 00                	push   $0x0
  pushl $83
8010904f:	6a 53                	push   $0x53
  jmp alltraps
80109051:	e9 cc f6 ff ff       	jmp    80108722 <alltraps>

80109056 <vector84>:
.globl vector84
vector84:
  pushl $0
80109056:	6a 00                	push   $0x0
  pushl $84
80109058:	6a 54                	push   $0x54
  jmp alltraps
8010905a:	e9 c3 f6 ff ff       	jmp    80108722 <alltraps>

8010905f <vector85>:
.globl vector85
vector85:
  pushl $0
8010905f:	6a 00                	push   $0x0
  pushl $85
80109061:	6a 55                	push   $0x55
  jmp alltraps
80109063:	e9 ba f6 ff ff       	jmp    80108722 <alltraps>

80109068 <vector86>:
.globl vector86
vector86:
  pushl $0
80109068:	6a 00                	push   $0x0
  pushl $86
8010906a:	6a 56                	push   $0x56
  jmp alltraps
8010906c:	e9 b1 f6 ff ff       	jmp    80108722 <alltraps>

80109071 <vector87>:
.globl vector87
vector87:
  pushl $0
80109071:	6a 00                	push   $0x0
  pushl $87
80109073:	6a 57                	push   $0x57
  jmp alltraps
80109075:	e9 a8 f6 ff ff       	jmp    80108722 <alltraps>

8010907a <vector88>:
.globl vector88
vector88:
  pushl $0
8010907a:	6a 00                	push   $0x0
  pushl $88
8010907c:	6a 58                	push   $0x58
  jmp alltraps
8010907e:	e9 9f f6 ff ff       	jmp    80108722 <alltraps>

80109083 <vector89>:
.globl vector89
vector89:
  pushl $0
80109083:	6a 00                	push   $0x0
  pushl $89
80109085:	6a 59                	push   $0x59
  jmp alltraps
80109087:	e9 96 f6 ff ff       	jmp    80108722 <alltraps>

8010908c <vector90>:
.globl vector90
vector90:
  pushl $0
8010908c:	6a 00                	push   $0x0
  pushl $90
8010908e:	6a 5a                	push   $0x5a
  jmp alltraps
80109090:	e9 8d f6 ff ff       	jmp    80108722 <alltraps>

80109095 <vector91>:
.globl vector91
vector91:
  pushl $0
80109095:	6a 00                	push   $0x0
  pushl $91
80109097:	6a 5b                	push   $0x5b
  jmp alltraps
80109099:	e9 84 f6 ff ff       	jmp    80108722 <alltraps>

8010909e <vector92>:
.globl vector92
vector92:
  pushl $0
8010909e:	6a 00                	push   $0x0
  pushl $92
801090a0:	6a 5c                	push   $0x5c
  jmp alltraps
801090a2:	e9 7b f6 ff ff       	jmp    80108722 <alltraps>

801090a7 <vector93>:
.globl vector93
vector93:
  pushl $0
801090a7:	6a 00                	push   $0x0
  pushl $93
801090a9:	6a 5d                	push   $0x5d
  jmp alltraps
801090ab:	e9 72 f6 ff ff       	jmp    80108722 <alltraps>

801090b0 <vector94>:
.globl vector94
vector94:
  pushl $0
801090b0:	6a 00                	push   $0x0
  pushl $94
801090b2:	6a 5e                	push   $0x5e
  jmp alltraps
801090b4:	e9 69 f6 ff ff       	jmp    80108722 <alltraps>

801090b9 <vector95>:
.globl vector95
vector95:
  pushl $0
801090b9:	6a 00                	push   $0x0
  pushl $95
801090bb:	6a 5f                	push   $0x5f
  jmp alltraps
801090bd:	e9 60 f6 ff ff       	jmp    80108722 <alltraps>

801090c2 <vector96>:
.globl vector96
vector96:
  pushl $0
801090c2:	6a 00                	push   $0x0
  pushl $96
801090c4:	6a 60                	push   $0x60
  jmp alltraps
801090c6:	e9 57 f6 ff ff       	jmp    80108722 <alltraps>

801090cb <vector97>:
.globl vector97
vector97:
  pushl $0
801090cb:	6a 00                	push   $0x0
  pushl $97
801090cd:	6a 61                	push   $0x61
  jmp alltraps
801090cf:	e9 4e f6 ff ff       	jmp    80108722 <alltraps>

801090d4 <vector98>:
.globl vector98
vector98:
  pushl $0
801090d4:	6a 00                	push   $0x0
  pushl $98
801090d6:	6a 62                	push   $0x62
  jmp alltraps
801090d8:	e9 45 f6 ff ff       	jmp    80108722 <alltraps>

801090dd <vector99>:
.globl vector99
vector99:
  pushl $0
801090dd:	6a 00                	push   $0x0
  pushl $99
801090df:	6a 63                	push   $0x63
  jmp alltraps
801090e1:	e9 3c f6 ff ff       	jmp    80108722 <alltraps>

801090e6 <vector100>:
.globl vector100
vector100:
  pushl $0
801090e6:	6a 00                	push   $0x0
  pushl $100
801090e8:	6a 64                	push   $0x64
  jmp alltraps
801090ea:	e9 33 f6 ff ff       	jmp    80108722 <alltraps>

801090ef <vector101>:
.globl vector101
vector101:
  pushl $0
801090ef:	6a 00                	push   $0x0
  pushl $101
801090f1:	6a 65                	push   $0x65
  jmp alltraps
801090f3:	e9 2a f6 ff ff       	jmp    80108722 <alltraps>

801090f8 <vector102>:
.globl vector102
vector102:
  pushl $0
801090f8:	6a 00                	push   $0x0
  pushl $102
801090fa:	6a 66                	push   $0x66
  jmp alltraps
801090fc:	e9 21 f6 ff ff       	jmp    80108722 <alltraps>

80109101 <vector103>:
.globl vector103
vector103:
  pushl $0
80109101:	6a 00                	push   $0x0
  pushl $103
80109103:	6a 67                	push   $0x67
  jmp alltraps
80109105:	e9 18 f6 ff ff       	jmp    80108722 <alltraps>

8010910a <vector104>:
.globl vector104
vector104:
  pushl $0
8010910a:	6a 00                	push   $0x0
  pushl $104
8010910c:	6a 68                	push   $0x68
  jmp alltraps
8010910e:	e9 0f f6 ff ff       	jmp    80108722 <alltraps>

80109113 <vector105>:
.globl vector105
vector105:
  pushl $0
80109113:	6a 00                	push   $0x0
  pushl $105
80109115:	6a 69                	push   $0x69
  jmp alltraps
80109117:	e9 06 f6 ff ff       	jmp    80108722 <alltraps>

8010911c <vector106>:
.globl vector106
vector106:
  pushl $0
8010911c:	6a 00                	push   $0x0
  pushl $106
8010911e:	6a 6a                	push   $0x6a
  jmp alltraps
80109120:	e9 fd f5 ff ff       	jmp    80108722 <alltraps>

80109125 <vector107>:
.globl vector107
vector107:
  pushl $0
80109125:	6a 00                	push   $0x0
  pushl $107
80109127:	6a 6b                	push   $0x6b
  jmp alltraps
80109129:	e9 f4 f5 ff ff       	jmp    80108722 <alltraps>

8010912e <vector108>:
.globl vector108
vector108:
  pushl $0
8010912e:	6a 00                	push   $0x0
  pushl $108
80109130:	6a 6c                	push   $0x6c
  jmp alltraps
80109132:	e9 eb f5 ff ff       	jmp    80108722 <alltraps>

80109137 <vector109>:
.globl vector109
vector109:
  pushl $0
80109137:	6a 00                	push   $0x0
  pushl $109
80109139:	6a 6d                	push   $0x6d
  jmp alltraps
8010913b:	e9 e2 f5 ff ff       	jmp    80108722 <alltraps>

80109140 <vector110>:
.globl vector110
vector110:
  pushl $0
80109140:	6a 00                	push   $0x0
  pushl $110
80109142:	6a 6e                	push   $0x6e
  jmp alltraps
80109144:	e9 d9 f5 ff ff       	jmp    80108722 <alltraps>

80109149 <vector111>:
.globl vector111
vector111:
  pushl $0
80109149:	6a 00                	push   $0x0
  pushl $111
8010914b:	6a 6f                	push   $0x6f
  jmp alltraps
8010914d:	e9 d0 f5 ff ff       	jmp    80108722 <alltraps>

80109152 <vector112>:
.globl vector112
vector112:
  pushl $0
80109152:	6a 00                	push   $0x0
  pushl $112
80109154:	6a 70                	push   $0x70
  jmp alltraps
80109156:	e9 c7 f5 ff ff       	jmp    80108722 <alltraps>

8010915b <vector113>:
.globl vector113
vector113:
  pushl $0
8010915b:	6a 00                	push   $0x0
  pushl $113
8010915d:	6a 71                	push   $0x71
  jmp alltraps
8010915f:	e9 be f5 ff ff       	jmp    80108722 <alltraps>

80109164 <vector114>:
.globl vector114
vector114:
  pushl $0
80109164:	6a 00                	push   $0x0
  pushl $114
80109166:	6a 72                	push   $0x72
  jmp alltraps
80109168:	e9 b5 f5 ff ff       	jmp    80108722 <alltraps>

8010916d <vector115>:
.globl vector115
vector115:
  pushl $0
8010916d:	6a 00                	push   $0x0
  pushl $115
8010916f:	6a 73                	push   $0x73
  jmp alltraps
80109171:	e9 ac f5 ff ff       	jmp    80108722 <alltraps>

80109176 <vector116>:
.globl vector116
vector116:
  pushl $0
80109176:	6a 00                	push   $0x0
  pushl $116
80109178:	6a 74                	push   $0x74
  jmp alltraps
8010917a:	e9 a3 f5 ff ff       	jmp    80108722 <alltraps>

8010917f <vector117>:
.globl vector117
vector117:
  pushl $0
8010917f:	6a 00                	push   $0x0
  pushl $117
80109181:	6a 75                	push   $0x75
  jmp alltraps
80109183:	e9 9a f5 ff ff       	jmp    80108722 <alltraps>

80109188 <vector118>:
.globl vector118
vector118:
  pushl $0
80109188:	6a 00                	push   $0x0
  pushl $118
8010918a:	6a 76                	push   $0x76
  jmp alltraps
8010918c:	e9 91 f5 ff ff       	jmp    80108722 <alltraps>

80109191 <vector119>:
.globl vector119
vector119:
  pushl $0
80109191:	6a 00                	push   $0x0
  pushl $119
80109193:	6a 77                	push   $0x77
  jmp alltraps
80109195:	e9 88 f5 ff ff       	jmp    80108722 <alltraps>

8010919a <vector120>:
.globl vector120
vector120:
  pushl $0
8010919a:	6a 00                	push   $0x0
  pushl $120
8010919c:	6a 78                	push   $0x78
  jmp alltraps
8010919e:	e9 7f f5 ff ff       	jmp    80108722 <alltraps>

801091a3 <vector121>:
.globl vector121
vector121:
  pushl $0
801091a3:	6a 00                	push   $0x0
  pushl $121
801091a5:	6a 79                	push   $0x79
  jmp alltraps
801091a7:	e9 76 f5 ff ff       	jmp    80108722 <alltraps>

801091ac <vector122>:
.globl vector122
vector122:
  pushl $0
801091ac:	6a 00                	push   $0x0
  pushl $122
801091ae:	6a 7a                	push   $0x7a
  jmp alltraps
801091b0:	e9 6d f5 ff ff       	jmp    80108722 <alltraps>

801091b5 <vector123>:
.globl vector123
vector123:
  pushl $0
801091b5:	6a 00                	push   $0x0
  pushl $123
801091b7:	6a 7b                	push   $0x7b
  jmp alltraps
801091b9:	e9 64 f5 ff ff       	jmp    80108722 <alltraps>

801091be <vector124>:
.globl vector124
vector124:
  pushl $0
801091be:	6a 00                	push   $0x0
  pushl $124
801091c0:	6a 7c                	push   $0x7c
  jmp alltraps
801091c2:	e9 5b f5 ff ff       	jmp    80108722 <alltraps>

801091c7 <vector125>:
.globl vector125
vector125:
  pushl $0
801091c7:	6a 00                	push   $0x0
  pushl $125
801091c9:	6a 7d                	push   $0x7d
  jmp alltraps
801091cb:	e9 52 f5 ff ff       	jmp    80108722 <alltraps>

801091d0 <vector126>:
.globl vector126
vector126:
  pushl $0
801091d0:	6a 00                	push   $0x0
  pushl $126
801091d2:	6a 7e                	push   $0x7e
  jmp alltraps
801091d4:	e9 49 f5 ff ff       	jmp    80108722 <alltraps>

801091d9 <vector127>:
.globl vector127
vector127:
  pushl $0
801091d9:	6a 00                	push   $0x0
  pushl $127
801091db:	6a 7f                	push   $0x7f
  jmp alltraps
801091dd:	e9 40 f5 ff ff       	jmp    80108722 <alltraps>

801091e2 <vector128>:
.globl vector128
vector128:
  pushl $0
801091e2:	6a 00                	push   $0x0
  pushl $128
801091e4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801091e9:	e9 34 f5 ff ff       	jmp    80108722 <alltraps>

801091ee <vector129>:
.globl vector129
vector129:
  pushl $0
801091ee:	6a 00                	push   $0x0
  pushl $129
801091f0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801091f5:	e9 28 f5 ff ff       	jmp    80108722 <alltraps>

801091fa <vector130>:
.globl vector130
vector130:
  pushl $0
801091fa:	6a 00                	push   $0x0
  pushl $130
801091fc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80109201:	e9 1c f5 ff ff       	jmp    80108722 <alltraps>

80109206 <vector131>:
.globl vector131
vector131:
  pushl $0
80109206:	6a 00                	push   $0x0
  pushl $131
80109208:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010920d:	e9 10 f5 ff ff       	jmp    80108722 <alltraps>

80109212 <vector132>:
.globl vector132
vector132:
  pushl $0
80109212:	6a 00                	push   $0x0
  pushl $132
80109214:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80109219:	e9 04 f5 ff ff       	jmp    80108722 <alltraps>

8010921e <vector133>:
.globl vector133
vector133:
  pushl $0
8010921e:	6a 00                	push   $0x0
  pushl $133
80109220:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80109225:	e9 f8 f4 ff ff       	jmp    80108722 <alltraps>

8010922a <vector134>:
.globl vector134
vector134:
  pushl $0
8010922a:	6a 00                	push   $0x0
  pushl $134
8010922c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80109231:	e9 ec f4 ff ff       	jmp    80108722 <alltraps>

80109236 <vector135>:
.globl vector135
vector135:
  pushl $0
80109236:	6a 00                	push   $0x0
  pushl $135
80109238:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010923d:	e9 e0 f4 ff ff       	jmp    80108722 <alltraps>

80109242 <vector136>:
.globl vector136
vector136:
  pushl $0
80109242:	6a 00                	push   $0x0
  pushl $136
80109244:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80109249:	e9 d4 f4 ff ff       	jmp    80108722 <alltraps>

8010924e <vector137>:
.globl vector137
vector137:
  pushl $0
8010924e:	6a 00                	push   $0x0
  pushl $137
80109250:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80109255:	e9 c8 f4 ff ff       	jmp    80108722 <alltraps>

8010925a <vector138>:
.globl vector138
vector138:
  pushl $0
8010925a:	6a 00                	push   $0x0
  pushl $138
8010925c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80109261:	e9 bc f4 ff ff       	jmp    80108722 <alltraps>

80109266 <vector139>:
.globl vector139
vector139:
  pushl $0
80109266:	6a 00                	push   $0x0
  pushl $139
80109268:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010926d:	e9 b0 f4 ff ff       	jmp    80108722 <alltraps>

80109272 <vector140>:
.globl vector140
vector140:
  pushl $0
80109272:	6a 00                	push   $0x0
  pushl $140
80109274:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80109279:	e9 a4 f4 ff ff       	jmp    80108722 <alltraps>

8010927e <vector141>:
.globl vector141
vector141:
  pushl $0
8010927e:	6a 00                	push   $0x0
  pushl $141
80109280:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80109285:	e9 98 f4 ff ff       	jmp    80108722 <alltraps>

8010928a <vector142>:
.globl vector142
vector142:
  pushl $0
8010928a:	6a 00                	push   $0x0
  pushl $142
8010928c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80109291:	e9 8c f4 ff ff       	jmp    80108722 <alltraps>

80109296 <vector143>:
.globl vector143
vector143:
  pushl $0
80109296:	6a 00                	push   $0x0
  pushl $143
80109298:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010929d:	e9 80 f4 ff ff       	jmp    80108722 <alltraps>

801092a2 <vector144>:
.globl vector144
vector144:
  pushl $0
801092a2:	6a 00                	push   $0x0
  pushl $144
801092a4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801092a9:	e9 74 f4 ff ff       	jmp    80108722 <alltraps>

801092ae <vector145>:
.globl vector145
vector145:
  pushl $0
801092ae:	6a 00                	push   $0x0
  pushl $145
801092b0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801092b5:	e9 68 f4 ff ff       	jmp    80108722 <alltraps>

801092ba <vector146>:
.globl vector146
vector146:
  pushl $0
801092ba:	6a 00                	push   $0x0
  pushl $146
801092bc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801092c1:	e9 5c f4 ff ff       	jmp    80108722 <alltraps>

801092c6 <vector147>:
.globl vector147
vector147:
  pushl $0
801092c6:	6a 00                	push   $0x0
  pushl $147
801092c8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801092cd:	e9 50 f4 ff ff       	jmp    80108722 <alltraps>

801092d2 <vector148>:
.globl vector148
vector148:
  pushl $0
801092d2:	6a 00                	push   $0x0
  pushl $148
801092d4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801092d9:	e9 44 f4 ff ff       	jmp    80108722 <alltraps>

801092de <vector149>:
.globl vector149
vector149:
  pushl $0
801092de:	6a 00                	push   $0x0
  pushl $149
801092e0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801092e5:	e9 38 f4 ff ff       	jmp    80108722 <alltraps>

801092ea <vector150>:
.globl vector150
vector150:
  pushl $0
801092ea:	6a 00                	push   $0x0
  pushl $150
801092ec:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801092f1:	e9 2c f4 ff ff       	jmp    80108722 <alltraps>

801092f6 <vector151>:
.globl vector151
vector151:
  pushl $0
801092f6:	6a 00                	push   $0x0
  pushl $151
801092f8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801092fd:	e9 20 f4 ff ff       	jmp    80108722 <alltraps>

80109302 <vector152>:
.globl vector152
vector152:
  pushl $0
80109302:	6a 00                	push   $0x0
  pushl $152
80109304:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80109309:	e9 14 f4 ff ff       	jmp    80108722 <alltraps>

8010930e <vector153>:
.globl vector153
vector153:
  pushl $0
8010930e:	6a 00                	push   $0x0
  pushl $153
80109310:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80109315:	e9 08 f4 ff ff       	jmp    80108722 <alltraps>

8010931a <vector154>:
.globl vector154
vector154:
  pushl $0
8010931a:	6a 00                	push   $0x0
  pushl $154
8010931c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80109321:	e9 fc f3 ff ff       	jmp    80108722 <alltraps>

80109326 <vector155>:
.globl vector155
vector155:
  pushl $0
80109326:	6a 00                	push   $0x0
  pushl $155
80109328:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010932d:	e9 f0 f3 ff ff       	jmp    80108722 <alltraps>

80109332 <vector156>:
.globl vector156
vector156:
  pushl $0
80109332:	6a 00                	push   $0x0
  pushl $156
80109334:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80109339:	e9 e4 f3 ff ff       	jmp    80108722 <alltraps>

8010933e <vector157>:
.globl vector157
vector157:
  pushl $0
8010933e:	6a 00                	push   $0x0
  pushl $157
80109340:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80109345:	e9 d8 f3 ff ff       	jmp    80108722 <alltraps>

8010934a <vector158>:
.globl vector158
vector158:
  pushl $0
8010934a:	6a 00                	push   $0x0
  pushl $158
8010934c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80109351:	e9 cc f3 ff ff       	jmp    80108722 <alltraps>

80109356 <vector159>:
.globl vector159
vector159:
  pushl $0
80109356:	6a 00                	push   $0x0
  pushl $159
80109358:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010935d:	e9 c0 f3 ff ff       	jmp    80108722 <alltraps>

80109362 <vector160>:
.globl vector160
vector160:
  pushl $0
80109362:	6a 00                	push   $0x0
  pushl $160
80109364:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80109369:	e9 b4 f3 ff ff       	jmp    80108722 <alltraps>

8010936e <vector161>:
.globl vector161
vector161:
  pushl $0
8010936e:	6a 00                	push   $0x0
  pushl $161
80109370:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80109375:	e9 a8 f3 ff ff       	jmp    80108722 <alltraps>

8010937a <vector162>:
.globl vector162
vector162:
  pushl $0
8010937a:	6a 00                	push   $0x0
  pushl $162
8010937c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80109381:	e9 9c f3 ff ff       	jmp    80108722 <alltraps>

80109386 <vector163>:
.globl vector163
vector163:
  pushl $0
80109386:	6a 00                	push   $0x0
  pushl $163
80109388:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010938d:	e9 90 f3 ff ff       	jmp    80108722 <alltraps>

80109392 <vector164>:
.globl vector164
vector164:
  pushl $0
80109392:	6a 00                	push   $0x0
  pushl $164
80109394:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80109399:	e9 84 f3 ff ff       	jmp    80108722 <alltraps>

8010939e <vector165>:
.globl vector165
vector165:
  pushl $0
8010939e:	6a 00                	push   $0x0
  pushl $165
801093a0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801093a5:	e9 78 f3 ff ff       	jmp    80108722 <alltraps>

801093aa <vector166>:
.globl vector166
vector166:
  pushl $0
801093aa:	6a 00                	push   $0x0
  pushl $166
801093ac:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801093b1:	e9 6c f3 ff ff       	jmp    80108722 <alltraps>

801093b6 <vector167>:
.globl vector167
vector167:
  pushl $0
801093b6:	6a 00                	push   $0x0
  pushl $167
801093b8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801093bd:	e9 60 f3 ff ff       	jmp    80108722 <alltraps>

801093c2 <vector168>:
.globl vector168
vector168:
  pushl $0
801093c2:	6a 00                	push   $0x0
  pushl $168
801093c4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801093c9:	e9 54 f3 ff ff       	jmp    80108722 <alltraps>

801093ce <vector169>:
.globl vector169
vector169:
  pushl $0
801093ce:	6a 00                	push   $0x0
  pushl $169
801093d0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801093d5:	e9 48 f3 ff ff       	jmp    80108722 <alltraps>

801093da <vector170>:
.globl vector170
vector170:
  pushl $0
801093da:	6a 00                	push   $0x0
  pushl $170
801093dc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801093e1:	e9 3c f3 ff ff       	jmp    80108722 <alltraps>

801093e6 <vector171>:
.globl vector171
vector171:
  pushl $0
801093e6:	6a 00                	push   $0x0
  pushl $171
801093e8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801093ed:	e9 30 f3 ff ff       	jmp    80108722 <alltraps>

801093f2 <vector172>:
.globl vector172
vector172:
  pushl $0
801093f2:	6a 00                	push   $0x0
  pushl $172
801093f4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801093f9:	e9 24 f3 ff ff       	jmp    80108722 <alltraps>

801093fe <vector173>:
.globl vector173
vector173:
  pushl $0
801093fe:	6a 00                	push   $0x0
  pushl $173
80109400:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80109405:	e9 18 f3 ff ff       	jmp    80108722 <alltraps>

8010940a <vector174>:
.globl vector174
vector174:
  pushl $0
8010940a:	6a 00                	push   $0x0
  pushl $174
8010940c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80109411:	e9 0c f3 ff ff       	jmp    80108722 <alltraps>

80109416 <vector175>:
.globl vector175
vector175:
  pushl $0
80109416:	6a 00                	push   $0x0
  pushl $175
80109418:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010941d:	e9 00 f3 ff ff       	jmp    80108722 <alltraps>

80109422 <vector176>:
.globl vector176
vector176:
  pushl $0
80109422:	6a 00                	push   $0x0
  pushl $176
80109424:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80109429:	e9 f4 f2 ff ff       	jmp    80108722 <alltraps>

8010942e <vector177>:
.globl vector177
vector177:
  pushl $0
8010942e:	6a 00                	push   $0x0
  pushl $177
80109430:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80109435:	e9 e8 f2 ff ff       	jmp    80108722 <alltraps>

8010943a <vector178>:
.globl vector178
vector178:
  pushl $0
8010943a:	6a 00                	push   $0x0
  pushl $178
8010943c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80109441:	e9 dc f2 ff ff       	jmp    80108722 <alltraps>

80109446 <vector179>:
.globl vector179
vector179:
  pushl $0
80109446:	6a 00                	push   $0x0
  pushl $179
80109448:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010944d:	e9 d0 f2 ff ff       	jmp    80108722 <alltraps>

80109452 <vector180>:
.globl vector180
vector180:
  pushl $0
80109452:	6a 00                	push   $0x0
  pushl $180
80109454:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80109459:	e9 c4 f2 ff ff       	jmp    80108722 <alltraps>

8010945e <vector181>:
.globl vector181
vector181:
  pushl $0
8010945e:	6a 00                	push   $0x0
  pushl $181
80109460:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80109465:	e9 b8 f2 ff ff       	jmp    80108722 <alltraps>

8010946a <vector182>:
.globl vector182
vector182:
  pushl $0
8010946a:	6a 00                	push   $0x0
  pushl $182
8010946c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80109471:	e9 ac f2 ff ff       	jmp    80108722 <alltraps>

80109476 <vector183>:
.globl vector183
vector183:
  pushl $0
80109476:	6a 00                	push   $0x0
  pushl $183
80109478:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010947d:	e9 a0 f2 ff ff       	jmp    80108722 <alltraps>

80109482 <vector184>:
.globl vector184
vector184:
  pushl $0
80109482:	6a 00                	push   $0x0
  pushl $184
80109484:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80109489:	e9 94 f2 ff ff       	jmp    80108722 <alltraps>

8010948e <vector185>:
.globl vector185
vector185:
  pushl $0
8010948e:	6a 00                	push   $0x0
  pushl $185
80109490:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80109495:	e9 88 f2 ff ff       	jmp    80108722 <alltraps>

8010949a <vector186>:
.globl vector186
vector186:
  pushl $0
8010949a:	6a 00                	push   $0x0
  pushl $186
8010949c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801094a1:	e9 7c f2 ff ff       	jmp    80108722 <alltraps>

801094a6 <vector187>:
.globl vector187
vector187:
  pushl $0
801094a6:	6a 00                	push   $0x0
  pushl $187
801094a8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801094ad:	e9 70 f2 ff ff       	jmp    80108722 <alltraps>

801094b2 <vector188>:
.globl vector188
vector188:
  pushl $0
801094b2:	6a 00                	push   $0x0
  pushl $188
801094b4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801094b9:	e9 64 f2 ff ff       	jmp    80108722 <alltraps>

801094be <vector189>:
.globl vector189
vector189:
  pushl $0
801094be:	6a 00                	push   $0x0
  pushl $189
801094c0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801094c5:	e9 58 f2 ff ff       	jmp    80108722 <alltraps>

801094ca <vector190>:
.globl vector190
vector190:
  pushl $0
801094ca:	6a 00                	push   $0x0
  pushl $190
801094cc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801094d1:	e9 4c f2 ff ff       	jmp    80108722 <alltraps>

801094d6 <vector191>:
.globl vector191
vector191:
  pushl $0
801094d6:	6a 00                	push   $0x0
  pushl $191
801094d8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801094dd:	e9 40 f2 ff ff       	jmp    80108722 <alltraps>

801094e2 <vector192>:
.globl vector192
vector192:
  pushl $0
801094e2:	6a 00                	push   $0x0
  pushl $192
801094e4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801094e9:	e9 34 f2 ff ff       	jmp    80108722 <alltraps>

801094ee <vector193>:
.globl vector193
vector193:
  pushl $0
801094ee:	6a 00                	push   $0x0
  pushl $193
801094f0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801094f5:	e9 28 f2 ff ff       	jmp    80108722 <alltraps>

801094fa <vector194>:
.globl vector194
vector194:
  pushl $0
801094fa:	6a 00                	push   $0x0
  pushl $194
801094fc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80109501:	e9 1c f2 ff ff       	jmp    80108722 <alltraps>

80109506 <vector195>:
.globl vector195
vector195:
  pushl $0
80109506:	6a 00                	push   $0x0
  pushl $195
80109508:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010950d:	e9 10 f2 ff ff       	jmp    80108722 <alltraps>

80109512 <vector196>:
.globl vector196
vector196:
  pushl $0
80109512:	6a 00                	push   $0x0
  pushl $196
80109514:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80109519:	e9 04 f2 ff ff       	jmp    80108722 <alltraps>

8010951e <vector197>:
.globl vector197
vector197:
  pushl $0
8010951e:	6a 00                	push   $0x0
  pushl $197
80109520:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80109525:	e9 f8 f1 ff ff       	jmp    80108722 <alltraps>

8010952a <vector198>:
.globl vector198
vector198:
  pushl $0
8010952a:	6a 00                	push   $0x0
  pushl $198
8010952c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80109531:	e9 ec f1 ff ff       	jmp    80108722 <alltraps>

80109536 <vector199>:
.globl vector199
vector199:
  pushl $0
80109536:	6a 00                	push   $0x0
  pushl $199
80109538:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010953d:	e9 e0 f1 ff ff       	jmp    80108722 <alltraps>

80109542 <vector200>:
.globl vector200
vector200:
  pushl $0
80109542:	6a 00                	push   $0x0
  pushl $200
80109544:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80109549:	e9 d4 f1 ff ff       	jmp    80108722 <alltraps>

8010954e <vector201>:
.globl vector201
vector201:
  pushl $0
8010954e:	6a 00                	push   $0x0
  pushl $201
80109550:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80109555:	e9 c8 f1 ff ff       	jmp    80108722 <alltraps>

8010955a <vector202>:
.globl vector202
vector202:
  pushl $0
8010955a:	6a 00                	push   $0x0
  pushl $202
8010955c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80109561:	e9 bc f1 ff ff       	jmp    80108722 <alltraps>

80109566 <vector203>:
.globl vector203
vector203:
  pushl $0
80109566:	6a 00                	push   $0x0
  pushl $203
80109568:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010956d:	e9 b0 f1 ff ff       	jmp    80108722 <alltraps>

80109572 <vector204>:
.globl vector204
vector204:
  pushl $0
80109572:	6a 00                	push   $0x0
  pushl $204
80109574:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80109579:	e9 a4 f1 ff ff       	jmp    80108722 <alltraps>

8010957e <vector205>:
.globl vector205
vector205:
  pushl $0
8010957e:	6a 00                	push   $0x0
  pushl $205
80109580:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80109585:	e9 98 f1 ff ff       	jmp    80108722 <alltraps>

8010958a <vector206>:
.globl vector206
vector206:
  pushl $0
8010958a:	6a 00                	push   $0x0
  pushl $206
8010958c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80109591:	e9 8c f1 ff ff       	jmp    80108722 <alltraps>

80109596 <vector207>:
.globl vector207
vector207:
  pushl $0
80109596:	6a 00                	push   $0x0
  pushl $207
80109598:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010959d:	e9 80 f1 ff ff       	jmp    80108722 <alltraps>

801095a2 <vector208>:
.globl vector208
vector208:
  pushl $0
801095a2:	6a 00                	push   $0x0
  pushl $208
801095a4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801095a9:	e9 74 f1 ff ff       	jmp    80108722 <alltraps>

801095ae <vector209>:
.globl vector209
vector209:
  pushl $0
801095ae:	6a 00                	push   $0x0
  pushl $209
801095b0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801095b5:	e9 68 f1 ff ff       	jmp    80108722 <alltraps>

801095ba <vector210>:
.globl vector210
vector210:
  pushl $0
801095ba:	6a 00                	push   $0x0
  pushl $210
801095bc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801095c1:	e9 5c f1 ff ff       	jmp    80108722 <alltraps>

801095c6 <vector211>:
.globl vector211
vector211:
  pushl $0
801095c6:	6a 00                	push   $0x0
  pushl $211
801095c8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801095cd:	e9 50 f1 ff ff       	jmp    80108722 <alltraps>

801095d2 <vector212>:
.globl vector212
vector212:
  pushl $0
801095d2:	6a 00                	push   $0x0
  pushl $212
801095d4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801095d9:	e9 44 f1 ff ff       	jmp    80108722 <alltraps>

801095de <vector213>:
.globl vector213
vector213:
  pushl $0
801095de:	6a 00                	push   $0x0
  pushl $213
801095e0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801095e5:	e9 38 f1 ff ff       	jmp    80108722 <alltraps>

801095ea <vector214>:
.globl vector214
vector214:
  pushl $0
801095ea:	6a 00                	push   $0x0
  pushl $214
801095ec:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801095f1:	e9 2c f1 ff ff       	jmp    80108722 <alltraps>

801095f6 <vector215>:
.globl vector215
vector215:
  pushl $0
801095f6:	6a 00                	push   $0x0
  pushl $215
801095f8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801095fd:	e9 20 f1 ff ff       	jmp    80108722 <alltraps>

80109602 <vector216>:
.globl vector216
vector216:
  pushl $0
80109602:	6a 00                	push   $0x0
  pushl $216
80109604:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80109609:	e9 14 f1 ff ff       	jmp    80108722 <alltraps>

8010960e <vector217>:
.globl vector217
vector217:
  pushl $0
8010960e:	6a 00                	push   $0x0
  pushl $217
80109610:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80109615:	e9 08 f1 ff ff       	jmp    80108722 <alltraps>

8010961a <vector218>:
.globl vector218
vector218:
  pushl $0
8010961a:	6a 00                	push   $0x0
  pushl $218
8010961c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80109621:	e9 fc f0 ff ff       	jmp    80108722 <alltraps>

80109626 <vector219>:
.globl vector219
vector219:
  pushl $0
80109626:	6a 00                	push   $0x0
  pushl $219
80109628:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010962d:	e9 f0 f0 ff ff       	jmp    80108722 <alltraps>

80109632 <vector220>:
.globl vector220
vector220:
  pushl $0
80109632:	6a 00                	push   $0x0
  pushl $220
80109634:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80109639:	e9 e4 f0 ff ff       	jmp    80108722 <alltraps>

8010963e <vector221>:
.globl vector221
vector221:
  pushl $0
8010963e:	6a 00                	push   $0x0
  pushl $221
80109640:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80109645:	e9 d8 f0 ff ff       	jmp    80108722 <alltraps>

8010964a <vector222>:
.globl vector222
vector222:
  pushl $0
8010964a:	6a 00                	push   $0x0
  pushl $222
8010964c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80109651:	e9 cc f0 ff ff       	jmp    80108722 <alltraps>

80109656 <vector223>:
.globl vector223
vector223:
  pushl $0
80109656:	6a 00                	push   $0x0
  pushl $223
80109658:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010965d:	e9 c0 f0 ff ff       	jmp    80108722 <alltraps>

80109662 <vector224>:
.globl vector224
vector224:
  pushl $0
80109662:	6a 00                	push   $0x0
  pushl $224
80109664:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80109669:	e9 b4 f0 ff ff       	jmp    80108722 <alltraps>

8010966e <vector225>:
.globl vector225
vector225:
  pushl $0
8010966e:	6a 00                	push   $0x0
  pushl $225
80109670:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80109675:	e9 a8 f0 ff ff       	jmp    80108722 <alltraps>

8010967a <vector226>:
.globl vector226
vector226:
  pushl $0
8010967a:	6a 00                	push   $0x0
  pushl $226
8010967c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80109681:	e9 9c f0 ff ff       	jmp    80108722 <alltraps>

80109686 <vector227>:
.globl vector227
vector227:
  pushl $0
80109686:	6a 00                	push   $0x0
  pushl $227
80109688:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010968d:	e9 90 f0 ff ff       	jmp    80108722 <alltraps>

80109692 <vector228>:
.globl vector228
vector228:
  pushl $0
80109692:	6a 00                	push   $0x0
  pushl $228
80109694:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80109699:	e9 84 f0 ff ff       	jmp    80108722 <alltraps>

8010969e <vector229>:
.globl vector229
vector229:
  pushl $0
8010969e:	6a 00                	push   $0x0
  pushl $229
801096a0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801096a5:	e9 78 f0 ff ff       	jmp    80108722 <alltraps>

801096aa <vector230>:
.globl vector230
vector230:
  pushl $0
801096aa:	6a 00                	push   $0x0
  pushl $230
801096ac:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801096b1:	e9 6c f0 ff ff       	jmp    80108722 <alltraps>

801096b6 <vector231>:
.globl vector231
vector231:
  pushl $0
801096b6:	6a 00                	push   $0x0
  pushl $231
801096b8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801096bd:	e9 60 f0 ff ff       	jmp    80108722 <alltraps>

801096c2 <vector232>:
.globl vector232
vector232:
  pushl $0
801096c2:	6a 00                	push   $0x0
  pushl $232
801096c4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801096c9:	e9 54 f0 ff ff       	jmp    80108722 <alltraps>

801096ce <vector233>:
.globl vector233
vector233:
  pushl $0
801096ce:	6a 00                	push   $0x0
  pushl $233
801096d0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801096d5:	e9 48 f0 ff ff       	jmp    80108722 <alltraps>

801096da <vector234>:
.globl vector234
vector234:
  pushl $0
801096da:	6a 00                	push   $0x0
  pushl $234
801096dc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801096e1:	e9 3c f0 ff ff       	jmp    80108722 <alltraps>

801096e6 <vector235>:
.globl vector235
vector235:
  pushl $0
801096e6:	6a 00                	push   $0x0
  pushl $235
801096e8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801096ed:	e9 30 f0 ff ff       	jmp    80108722 <alltraps>

801096f2 <vector236>:
.globl vector236
vector236:
  pushl $0
801096f2:	6a 00                	push   $0x0
  pushl $236
801096f4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801096f9:	e9 24 f0 ff ff       	jmp    80108722 <alltraps>

801096fe <vector237>:
.globl vector237
vector237:
  pushl $0
801096fe:	6a 00                	push   $0x0
  pushl $237
80109700:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80109705:	e9 18 f0 ff ff       	jmp    80108722 <alltraps>

8010970a <vector238>:
.globl vector238
vector238:
  pushl $0
8010970a:	6a 00                	push   $0x0
  pushl $238
8010970c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80109711:	e9 0c f0 ff ff       	jmp    80108722 <alltraps>

80109716 <vector239>:
.globl vector239
vector239:
  pushl $0
80109716:	6a 00                	push   $0x0
  pushl $239
80109718:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010971d:	e9 00 f0 ff ff       	jmp    80108722 <alltraps>

80109722 <vector240>:
.globl vector240
vector240:
  pushl $0
80109722:	6a 00                	push   $0x0
  pushl $240
80109724:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80109729:	e9 f4 ef ff ff       	jmp    80108722 <alltraps>

8010972e <vector241>:
.globl vector241
vector241:
  pushl $0
8010972e:	6a 00                	push   $0x0
  pushl $241
80109730:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80109735:	e9 e8 ef ff ff       	jmp    80108722 <alltraps>

8010973a <vector242>:
.globl vector242
vector242:
  pushl $0
8010973a:	6a 00                	push   $0x0
  pushl $242
8010973c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80109741:	e9 dc ef ff ff       	jmp    80108722 <alltraps>

80109746 <vector243>:
.globl vector243
vector243:
  pushl $0
80109746:	6a 00                	push   $0x0
  pushl $243
80109748:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010974d:	e9 d0 ef ff ff       	jmp    80108722 <alltraps>

80109752 <vector244>:
.globl vector244
vector244:
  pushl $0
80109752:	6a 00                	push   $0x0
  pushl $244
80109754:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80109759:	e9 c4 ef ff ff       	jmp    80108722 <alltraps>

8010975e <vector245>:
.globl vector245
vector245:
  pushl $0
8010975e:	6a 00                	push   $0x0
  pushl $245
80109760:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80109765:	e9 b8 ef ff ff       	jmp    80108722 <alltraps>

8010976a <vector246>:
.globl vector246
vector246:
  pushl $0
8010976a:	6a 00                	push   $0x0
  pushl $246
8010976c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109771:	e9 ac ef ff ff       	jmp    80108722 <alltraps>

80109776 <vector247>:
.globl vector247
vector247:
  pushl $0
80109776:	6a 00                	push   $0x0
  pushl $247
80109778:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010977d:	e9 a0 ef ff ff       	jmp    80108722 <alltraps>

80109782 <vector248>:
.globl vector248
vector248:
  pushl $0
80109782:	6a 00                	push   $0x0
  pushl $248
80109784:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80109789:	e9 94 ef ff ff       	jmp    80108722 <alltraps>

8010978e <vector249>:
.globl vector249
vector249:
  pushl $0
8010978e:	6a 00                	push   $0x0
  pushl $249
80109790:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80109795:	e9 88 ef ff ff       	jmp    80108722 <alltraps>

8010979a <vector250>:
.globl vector250
vector250:
  pushl $0
8010979a:	6a 00                	push   $0x0
  pushl $250
8010979c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801097a1:	e9 7c ef ff ff       	jmp    80108722 <alltraps>

801097a6 <vector251>:
.globl vector251
vector251:
  pushl $0
801097a6:	6a 00                	push   $0x0
  pushl $251
801097a8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801097ad:	e9 70 ef ff ff       	jmp    80108722 <alltraps>

801097b2 <vector252>:
.globl vector252
vector252:
  pushl $0
801097b2:	6a 00                	push   $0x0
  pushl $252
801097b4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801097b9:	e9 64 ef ff ff       	jmp    80108722 <alltraps>

801097be <vector253>:
.globl vector253
vector253:
  pushl $0
801097be:	6a 00                	push   $0x0
  pushl $253
801097c0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801097c5:	e9 58 ef ff ff       	jmp    80108722 <alltraps>

801097ca <vector254>:
.globl vector254
vector254:
  pushl $0
801097ca:	6a 00                	push   $0x0
  pushl $254
801097cc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801097d1:	e9 4c ef ff ff       	jmp    80108722 <alltraps>

801097d6 <vector255>:
.globl vector255
vector255:
  pushl $0
801097d6:	6a 00                	push   $0x0
  pushl $255
801097d8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801097dd:	e9 40 ef ff ff       	jmp    80108722 <alltraps>

801097e2 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801097e2:	55                   	push   %ebp
801097e3:	89 e5                	mov    %esp,%ebp
801097e5:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801097e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801097eb:	83 e8 01             	sub    $0x1,%eax
801097ee:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801097f2:	8b 45 08             	mov    0x8(%ebp),%eax
801097f5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801097f9:	8b 45 08             	mov    0x8(%ebp),%eax
801097fc:	c1 e8 10             	shr    $0x10,%eax
801097ff:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80109803:	8d 45 fa             	lea    -0x6(%ebp),%eax
80109806:	0f 01 10             	lgdtl  (%eax)
}
80109809:	90                   	nop
8010980a:	c9                   	leave  
8010980b:	c3                   	ret    

8010980c <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010980c:	55                   	push   %ebp
8010980d:	89 e5                	mov    %esp,%ebp
8010980f:	83 ec 04             	sub    $0x4,%esp
80109812:	8b 45 08             	mov    0x8(%ebp),%eax
80109815:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80109819:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010981d:	0f 00 d8             	ltr    %ax
}
80109820:	90                   	nop
80109821:	c9                   	leave  
80109822:	c3                   	ret    

80109823 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80109823:	55                   	push   %ebp
80109824:	89 e5                	mov    %esp,%ebp
80109826:	83 ec 04             	sub    $0x4,%esp
80109829:	8b 45 08             	mov    0x8(%ebp),%eax
8010982c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80109830:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109834:	8e e8                	mov    %eax,%gs
}
80109836:	90                   	nop
80109837:	c9                   	leave  
80109838:	c3                   	ret    

80109839 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80109839:	55                   	push   %ebp
8010983a:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010983c:	8b 45 08             	mov    0x8(%ebp),%eax
8010983f:	0f 22 d8             	mov    %eax,%cr3
}
80109842:	90                   	nop
80109843:	5d                   	pop    %ebp
80109844:	c3                   	ret    

80109845 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80109845:	55                   	push   %ebp
80109846:	89 e5                	mov    %esp,%ebp
80109848:	8b 45 08             	mov    0x8(%ebp),%eax
8010984b:	05 00 00 00 80       	add    $0x80000000,%eax
80109850:	5d                   	pop    %ebp
80109851:	c3                   	ret    

80109852 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80109852:	55                   	push   %ebp
80109853:	89 e5                	mov    %esp,%ebp
80109855:	8b 45 08             	mov    0x8(%ebp),%eax
80109858:	05 00 00 00 80       	add    $0x80000000,%eax
8010985d:	5d                   	pop    %ebp
8010985e:	c3                   	ret    

8010985f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010985f:	55                   	push   %ebp
80109860:	89 e5                	mov    %esp,%ebp
80109862:	53                   	push   %ebx
80109863:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80109866:	e8 c2 9a ff ff       	call   8010332d <cpunum>
8010986b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109871:	05 80 53 11 80       	add    $0x80115380,%eax
80109876:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80109879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987c:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80109882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109885:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010988b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988e:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80109892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109895:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109899:	83 e2 f0             	and    $0xfffffff0,%edx
8010989c:	83 ca 0a             	or     $0xa,%edx
8010989f:	88 50 7d             	mov    %dl,0x7d(%eax)
801098a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801098a9:	83 ca 10             	or     $0x10,%edx
801098ac:	88 50 7d             	mov    %dl,0x7d(%eax)
801098af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801098b6:	83 e2 9f             	and    $0xffffff9f,%edx
801098b9:	88 50 7d             	mov    %dl,0x7d(%eax)
801098bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098bf:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801098c3:	83 ca 80             	or     $0xffffff80,%edx
801098c6:	88 50 7d             	mov    %dl,0x7d(%eax)
801098c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098cc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801098d0:	83 ca 0f             	or     $0xf,%edx
801098d3:	88 50 7e             	mov    %dl,0x7e(%eax)
801098d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801098dd:	83 e2 ef             	and    $0xffffffef,%edx
801098e0:	88 50 7e             	mov    %dl,0x7e(%eax)
801098e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801098ea:	83 e2 df             	and    $0xffffffdf,%edx
801098ed:	88 50 7e             	mov    %dl,0x7e(%eax)
801098f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801098f7:	83 ca 40             	or     $0x40,%edx
801098fa:	88 50 7e             	mov    %dl,0x7e(%eax)
801098fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109900:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109904:	83 ca 80             	or     $0xffffff80,%edx
80109907:	88 50 7e             	mov    %dl,0x7e(%eax)
8010990a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010990d:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80109911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109914:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010991b:	ff ff 
8010991d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109920:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80109927:	00 00 
80109929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992c:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80109933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109936:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010993d:	83 e2 f0             	and    $0xfffffff0,%edx
80109940:	83 ca 02             	or     $0x2,%edx
80109943:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010994c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109953:	83 ca 10             	or     $0x10,%edx
80109956:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010995c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010995f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109966:	83 e2 9f             	and    $0xffffff9f,%edx
80109969:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010996f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109972:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109979:	83 ca 80             	or     $0xffffff80,%edx
8010997c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109985:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010998c:	83 ca 0f             	or     $0xf,%edx
8010998f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109998:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010999f:	83 e2 ef             	and    $0xffffffef,%edx
801099a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801099a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ab:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801099b2:	83 e2 df             	and    $0xffffffdf,%edx
801099b5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801099bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099be:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801099c5:	83 ca 40             	or     $0x40,%edx
801099c8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801099ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801099d8:	83 ca 80             	or     $0xffffff80,%edx
801099db:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801099e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e4:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801099eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ee:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801099f5:	ff ff 
801099f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fa:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80109a01:	00 00 
80109a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a06:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80109a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a10:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109a17:	83 e2 f0             	and    $0xfffffff0,%edx
80109a1a:	83 ca 0a             	or     $0xa,%edx
80109a1d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a26:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109a2d:	83 ca 10             	or     $0x10,%edx
80109a30:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a39:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109a40:	83 ca 60             	or     $0x60,%edx
80109a43:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a4c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109a53:	83 ca 80             	or     $0xffffff80,%edx
80109a56:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109a66:	83 ca 0f             	or     $0xf,%edx
80109a69:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a72:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109a79:	83 e2 ef             	and    $0xffffffef,%edx
80109a7c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a85:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109a8c:	83 e2 df             	and    $0xffffffdf,%edx
80109a8f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a98:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109a9f:	83 ca 40             	or     $0x40,%edx
80109aa2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aab:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109ab2:	83 ca 80             	or     $0xffffff80,%edx
80109ab5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109abe:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80109ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac8:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80109acf:	ff ff 
80109ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad4:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80109adb:	00 00 
80109add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae0:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80109ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aea:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109af1:	83 e2 f0             	and    $0xfffffff0,%edx
80109af4:	83 ca 02             	or     $0x2,%edx
80109af7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109b07:	83 ca 10             	or     $0x10,%edx
80109b0a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b13:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109b1a:	83 ca 60             	or     $0x60,%edx
80109b1d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b26:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109b2d:	83 ca 80             	or     $0xffffff80,%edx
80109b30:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b39:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109b40:	83 ca 0f             	or     $0xf,%edx
80109b43:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109b53:	83 e2 ef             	and    $0xffffffef,%edx
80109b56:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109b66:	83 e2 df             	and    $0xffffffdf,%edx
80109b69:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b72:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109b79:	83 ca 40             	or     $0x40,%edx
80109b7c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b85:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109b8c:	83 ca 80             	or     $0xffffff80,%edx
80109b8f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b98:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80109b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba2:	05 b4 00 00 00       	add    $0xb4,%eax
80109ba7:	89 c3                	mov    %eax,%ebx
80109ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bac:	05 b4 00 00 00       	add    $0xb4,%eax
80109bb1:	c1 e8 10             	shr    $0x10,%eax
80109bb4:	89 c2                	mov    %eax,%edx
80109bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb9:	05 b4 00 00 00       	add    $0xb4,%eax
80109bbe:	c1 e8 18             	shr    $0x18,%eax
80109bc1:	89 c1                	mov    %eax,%ecx
80109bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bc6:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80109bcd:	00 00 
80109bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd2:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80109bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bdc:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80109be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109be5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109bec:	83 e2 f0             	and    $0xfffffff0,%edx
80109bef:	83 ca 02             	or     $0x2,%edx
80109bf2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bfb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109c02:	83 ca 10             	or     $0x10,%edx
80109c05:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c0e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109c15:	83 e2 9f             	and    $0xffffff9f,%edx
80109c18:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c21:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109c28:	83 ca 80             	or     $0xffffff80,%edx
80109c2b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c34:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109c3b:	83 e2 f0             	and    $0xfffffff0,%edx
80109c3e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c47:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109c4e:	83 e2 ef             	and    $0xffffffef,%edx
80109c51:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c5a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109c61:	83 e2 df             	and    $0xffffffdf,%edx
80109c64:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c6d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109c74:	83 ca 40             	or     $0x40,%edx
80109c77:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c80:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109c87:	83 ca 80             	or     $0xffffff80,%edx
80109c8a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c93:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80109c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c9c:	83 c0 70             	add    $0x70,%eax
80109c9f:	83 ec 08             	sub    $0x8,%esp
80109ca2:	6a 38                	push   $0x38
80109ca4:	50                   	push   %eax
80109ca5:	e8 38 fb ff ff       	call   801097e2 <lgdt>
80109caa:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80109cad:	83 ec 0c             	sub    $0xc,%esp
80109cb0:	6a 18                	push   $0x18
80109cb2:	e8 6c fb ff ff       	call   80109823 <loadgs>
80109cb7:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80109cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cbd:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80109cc3:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80109cca:	00 00 00 00 
}
80109cce:	90                   	nop
80109ccf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109cd2:	c9                   	leave  
80109cd3:	c3                   	ret    

80109cd4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80109cd4:	55                   	push   %ebp
80109cd5:	89 e5                	mov    %esp,%ebp
80109cd7:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80109cda:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cdd:	c1 e8 16             	shr    $0x16,%eax
80109ce0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80109cea:	01 d0                	add    %edx,%eax
80109cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80109cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf2:	8b 00                	mov    (%eax),%eax
80109cf4:	83 e0 01             	and    $0x1,%eax
80109cf7:	85 c0                	test   %eax,%eax
80109cf9:	74 18                	je     80109d13 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80109cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cfe:	8b 00                	mov    (%eax),%eax
80109d00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d05:	50                   	push   %eax
80109d06:	e8 47 fb ff ff       	call   80109852 <p2v>
80109d0b:	83 c4 04             	add    $0x4,%esp
80109d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109d11:	eb 48                	jmp    80109d5b <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80109d13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80109d17:	74 0e                	je     80109d27 <walkpgdir+0x53>
80109d19:	e8 a9 92 ff ff       	call   80102fc7 <kalloc>
80109d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109d21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109d25:	75 07                	jne    80109d2e <walkpgdir+0x5a>
      return 0;
80109d27:	b8 00 00 00 00       	mov    $0x0,%eax
80109d2c:	eb 44                	jmp    80109d72 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80109d2e:	83 ec 04             	sub    $0x4,%esp
80109d31:	68 00 10 00 00       	push   $0x1000
80109d36:	6a 00                	push   $0x0
80109d38:	ff 75 f4             	pushl  -0xc(%ebp)
80109d3b:	e8 71 d2 ff ff       	call   80106fb1 <memset>
80109d40:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80109d43:	83 ec 0c             	sub    $0xc,%esp
80109d46:	ff 75 f4             	pushl  -0xc(%ebp)
80109d49:	e8 f7 fa ff ff       	call   80109845 <v2p>
80109d4e:	83 c4 10             	add    $0x10,%esp
80109d51:	83 c8 07             	or     $0x7,%eax
80109d54:	89 c2                	mov    %eax,%edx
80109d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d59:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d5e:	c1 e8 0c             	shr    $0xc,%eax
80109d61:	25 ff 03 00 00       	and    $0x3ff,%eax
80109d66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d70:	01 d0                	add    %edx,%eax
}
80109d72:	c9                   	leave  
80109d73:	c3                   	ret    

80109d74 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80109d74:	55                   	push   %ebp
80109d75:	89 e5                	mov    %esp,%ebp
80109d77:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80109d85:	8b 55 0c             	mov    0xc(%ebp),%edx
80109d88:	8b 45 10             	mov    0x10(%ebp),%eax
80109d8b:	01 d0                	add    %edx,%eax
80109d8d:	83 e8 01             	sub    $0x1,%eax
80109d90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80109d98:	83 ec 04             	sub    $0x4,%esp
80109d9b:	6a 01                	push   $0x1
80109d9d:	ff 75 f4             	pushl  -0xc(%ebp)
80109da0:	ff 75 08             	pushl  0x8(%ebp)
80109da3:	e8 2c ff ff ff       	call   80109cd4 <walkpgdir>
80109da8:	83 c4 10             	add    $0x10,%esp
80109dab:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109dae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109db2:	75 07                	jne    80109dbb <mappages+0x47>
      return -1;
80109db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109db9:	eb 47                	jmp    80109e02 <mappages+0x8e>
    if(*pte & PTE_P)
80109dbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dbe:	8b 00                	mov    (%eax),%eax
80109dc0:	83 e0 01             	and    $0x1,%eax
80109dc3:	85 c0                	test   %eax,%eax
80109dc5:	74 0d                	je     80109dd4 <mappages+0x60>
      panic("remap");
80109dc7:	83 ec 0c             	sub    $0xc,%esp
80109dca:	68 28 af 10 80       	push   $0x8010af28
80109dcf:	e8 92 67 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80109dd4:	8b 45 18             	mov    0x18(%ebp),%eax
80109dd7:	0b 45 14             	or     0x14(%ebp),%eax
80109dda:	83 c8 01             	or     $0x1,%eax
80109ddd:	89 c2                	mov    %eax,%edx
80109ddf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109de2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80109de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109dea:	74 10                	je     80109dfc <mappages+0x88>
      break;
    a += PGSIZE;
80109dec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80109df3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80109dfa:	eb 9c                	jmp    80109d98 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80109dfc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80109dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109e02:	c9                   	leave  
80109e03:	c3                   	ret    

80109e04 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80109e04:	55                   	push   %ebp
80109e05:	89 e5                	mov    %esp,%ebp
80109e07:	53                   	push   %ebx
80109e08:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80109e0b:	e8 b7 91 ff ff       	call   80102fc7 <kalloc>
80109e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109e13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109e17:	75 0a                	jne    80109e23 <setupkvm+0x1f>
    return 0;
80109e19:	b8 00 00 00 00       	mov    $0x0,%eax
80109e1e:	e9 8e 00 00 00       	jmp    80109eb1 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80109e23:	83 ec 04             	sub    $0x4,%esp
80109e26:	68 00 10 00 00       	push   $0x1000
80109e2b:	6a 00                	push   $0x0
80109e2d:	ff 75 f0             	pushl  -0x10(%ebp)
80109e30:	e8 7c d1 ff ff       	call   80106fb1 <memset>
80109e35:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80109e38:	83 ec 0c             	sub    $0xc,%esp
80109e3b:	68 00 00 00 0e       	push   $0xe000000
80109e40:	e8 0d fa ff ff       	call   80109852 <p2v>
80109e45:	83 c4 10             	add    $0x10,%esp
80109e48:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109e4d:	76 0d                	jbe    80109e5c <setupkvm+0x58>
    panic("PHYSTOP too high");
80109e4f:	83 ec 0c             	sub    $0xc,%esp
80109e52:	68 2e af 10 80       	push   $0x8010af2e
80109e57:	e8 0a 67 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109e5c:	c7 45 f4 c0 e4 10 80 	movl   $0x8010e4c0,-0xc(%ebp)
80109e63:	eb 40                	jmp    80109ea5 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e68:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e6e:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e74:	8b 58 08             	mov    0x8(%eax),%ebx
80109e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e7a:	8b 40 04             	mov    0x4(%eax),%eax
80109e7d:	29 c3                	sub    %eax,%ebx
80109e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e82:	8b 00                	mov    (%eax),%eax
80109e84:	83 ec 0c             	sub    $0xc,%esp
80109e87:	51                   	push   %ecx
80109e88:	52                   	push   %edx
80109e89:	53                   	push   %ebx
80109e8a:	50                   	push   %eax
80109e8b:	ff 75 f0             	pushl  -0x10(%ebp)
80109e8e:	e8 e1 fe ff ff       	call   80109d74 <mappages>
80109e93:	83 c4 20             	add    $0x20,%esp
80109e96:	85 c0                	test   %eax,%eax
80109e98:	79 07                	jns    80109ea1 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80109e9a:	b8 00 00 00 00       	mov    $0x0,%eax
80109e9f:	eb 10                	jmp    80109eb1 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109ea1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80109ea5:	81 7d f4 00 e5 10 80 	cmpl   $0x8010e500,-0xc(%ebp)
80109eac:	72 b7                	jb     80109e65 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80109eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109eb4:	c9                   	leave  
80109eb5:	c3                   	ret    

80109eb6 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80109eb6:	55                   	push   %ebp
80109eb7:	89 e5                	mov    %esp,%ebp
80109eb9:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80109ebc:	e8 43 ff ff ff       	call   80109e04 <setupkvm>
80109ec1:	a3 38 89 11 80       	mov    %eax,0x80118938
  switchkvm();
80109ec6:	e8 03 00 00 00       	call   80109ece <switchkvm>
}
80109ecb:	90                   	nop
80109ecc:	c9                   	leave  
80109ecd:	c3                   	ret    

80109ece <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80109ece:	55                   	push   %ebp
80109ecf:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80109ed1:	a1 38 89 11 80       	mov    0x80118938,%eax
80109ed6:	50                   	push   %eax
80109ed7:	e8 69 f9 ff ff       	call   80109845 <v2p>
80109edc:	83 c4 04             	add    $0x4,%esp
80109edf:	50                   	push   %eax
80109ee0:	e8 54 f9 ff ff       	call   80109839 <lcr3>
80109ee5:	83 c4 04             	add    $0x4,%esp
}
80109ee8:	90                   	nop
80109ee9:	c9                   	leave  
80109eea:	c3                   	ret    

80109eeb <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80109eeb:	55                   	push   %ebp
80109eec:	89 e5                	mov    %esp,%ebp
80109eee:	56                   	push   %esi
80109eef:	53                   	push   %ebx
  pushcli();
80109ef0:	e8 b6 cf ff ff       	call   80106eab <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80109ef5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109efb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109f02:	83 c2 08             	add    $0x8,%edx
80109f05:	89 d6                	mov    %edx,%esi
80109f07:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109f0e:	83 c2 08             	add    $0x8,%edx
80109f11:	c1 ea 10             	shr    $0x10,%edx
80109f14:	89 d3                	mov    %edx,%ebx
80109f16:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109f1d:	83 c2 08             	add    $0x8,%edx
80109f20:	c1 ea 18             	shr    $0x18,%edx
80109f23:	89 d1                	mov    %edx,%ecx
80109f25:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109f2c:	67 00 
80109f2e:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80109f35:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109f3b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109f42:	83 e2 f0             	and    $0xfffffff0,%edx
80109f45:	83 ca 09             	or     $0x9,%edx
80109f48:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109f4e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109f55:	83 ca 10             	or     $0x10,%edx
80109f58:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109f5e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109f65:	83 e2 9f             	and    $0xffffff9f,%edx
80109f68:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109f6e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109f75:	83 ca 80             	or     $0xffffff80,%edx
80109f78:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109f7e:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109f85:	83 e2 f0             	and    $0xfffffff0,%edx
80109f88:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109f8e:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109f95:	83 e2 ef             	and    $0xffffffef,%edx
80109f98:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109f9e:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109fa5:	83 e2 df             	and    $0xffffffdf,%edx
80109fa8:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109fae:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109fb5:	83 ca 40             	or     $0x40,%edx
80109fb8:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109fbe:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109fc5:	83 e2 7f             	and    $0x7f,%edx
80109fc8:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109fce:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80109fd4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109fda:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109fe1:	83 e2 ef             	and    $0xffffffef,%edx
80109fe4:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109fea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109ff0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80109ff6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109ffc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a003:	8b 52 08             	mov    0x8(%edx),%edx
8010a006:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010a00c:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010a00f:	83 ec 0c             	sub    $0xc,%esp
8010a012:	6a 30                	push   $0x30
8010a014:	e8 f3 f7 ff ff       	call   8010980c <ltr>
8010a019:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
8010a01c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a01f:	8b 40 04             	mov    0x4(%eax),%eax
8010a022:	85 c0                	test   %eax,%eax
8010a024:	75 0d                	jne    8010a033 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
8010a026:	83 ec 0c             	sub    $0xc,%esp
8010a029:	68 3f af 10 80       	push   $0x8010af3f
8010a02e:	e8 33 65 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010a033:	8b 45 08             	mov    0x8(%ebp),%eax
8010a036:	8b 40 04             	mov    0x4(%eax),%eax
8010a039:	83 ec 0c             	sub    $0xc,%esp
8010a03c:	50                   	push   %eax
8010a03d:	e8 03 f8 ff ff       	call   80109845 <v2p>
8010a042:	83 c4 10             	add    $0x10,%esp
8010a045:	83 ec 0c             	sub    $0xc,%esp
8010a048:	50                   	push   %eax
8010a049:	e8 eb f7 ff ff       	call   80109839 <lcr3>
8010a04e:	83 c4 10             	add    $0x10,%esp
  popcli();
8010a051:	e8 9a ce ff ff       	call   80106ef0 <popcli>
}
8010a056:	90                   	nop
8010a057:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010a05a:	5b                   	pop    %ebx
8010a05b:	5e                   	pop    %esi
8010a05c:	5d                   	pop    %ebp
8010a05d:	c3                   	ret    

8010a05e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010a05e:	55                   	push   %ebp
8010a05f:	89 e5                	mov    %esp,%ebp
8010a061:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010a064:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010a06b:	76 0d                	jbe    8010a07a <inituvm+0x1c>
    panic("inituvm: more than a page");
8010a06d:	83 ec 0c             	sub    $0xc,%esp
8010a070:	68 53 af 10 80       	push   $0x8010af53
8010a075:	e8 ec 64 ff ff       	call   80100566 <panic>
  mem = kalloc();
8010a07a:	e8 48 8f ff ff       	call   80102fc7 <kalloc>
8010a07f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010a082:	83 ec 04             	sub    $0x4,%esp
8010a085:	68 00 10 00 00       	push   $0x1000
8010a08a:	6a 00                	push   $0x0
8010a08c:	ff 75 f4             	pushl  -0xc(%ebp)
8010a08f:	e8 1d cf ff ff       	call   80106fb1 <memset>
8010a094:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010a097:	83 ec 0c             	sub    $0xc,%esp
8010a09a:	ff 75 f4             	pushl  -0xc(%ebp)
8010a09d:	e8 a3 f7 ff ff       	call   80109845 <v2p>
8010a0a2:	83 c4 10             	add    $0x10,%esp
8010a0a5:	83 ec 0c             	sub    $0xc,%esp
8010a0a8:	6a 06                	push   $0x6
8010a0aa:	50                   	push   %eax
8010a0ab:	68 00 10 00 00       	push   $0x1000
8010a0b0:	6a 00                	push   $0x0
8010a0b2:	ff 75 08             	pushl  0x8(%ebp)
8010a0b5:	e8 ba fc ff ff       	call   80109d74 <mappages>
8010a0ba:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010a0bd:	83 ec 04             	sub    $0x4,%esp
8010a0c0:	ff 75 10             	pushl  0x10(%ebp)
8010a0c3:	ff 75 0c             	pushl  0xc(%ebp)
8010a0c6:	ff 75 f4             	pushl  -0xc(%ebp)
8010a0c9:	e8 a2 cf ff ff       	call   80107070 <memmove>
8010a0ce:	83 c4 10             	add    $0x10,%esp
}
8010a0d1:	90                   	nop
8010a0d2:	c9                   	leave  
8010a0d3:	c3                   	ret    

8010a0d4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010a0d4:	55                   	push   %ebp
8010a0d5:	89 e5                	mov    %esp,%ebp
8010a0d7:	53                   	push   %ebx
8010a0d8:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010a0db:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0de:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a0e3:	85 c0                	test   %eax,%eax
8010a0e5:	74 0d                	je     8010a0f4 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010a0e7:	83 ec 0c             	sub    $0xc,%esp
8010a0ea:	68 70 af 10 80       	push   $0x8010af70
8010a0ef:	e8 72 64 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010a0f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a0fb:	e9 95 00 00 00       	jmp    8010a195 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010a100:	8b 55 0c             	mov    0xc(%ebp),%edx
8010a103:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a106:	01 d0                	add    %edx,%eax
8010a108:	83 ec 04             	sub    $0x4,%esp
8010a10b:	6a 00                	push   $0x0
8010a10d:	50                   	push   %eax
8010a10e:	ff 75 08             	pushl  0x8(%ebp)
8010a111:	e8 be fb ff ff       	call   80109cd4 <walkpgdir>
8010a116:	83 c4 10             	add    $0x10,%esp
8010a119:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a11c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a120:	75 0d                	jne    8010a12f <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010a122:	83 ec 0c             	sub    $0xc,%esp
8010a125:	68 93 af 10 80       	push   $0x8010af93
8010a12a:	e8 37 64 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010a12f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a132:	8b 00                	mov    (%eax),%eax
8010a134:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a139:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010a13c:	8b 45 18             	mov    0x18(%ebp),%eax
8010a13f:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010a142:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010a147:	77 0b                	ja     8010a154 <loaduvm+0x80>
      n = sz - i;
8010a149:	8b 45 18             	mov    0x18(%ebp),%eax
8010a14c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010a14f:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010a152:	eb 07                	jmp    8010a15b <loaduvm+0x87>
    else
      n = PGSIZE;
8010a154:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010a15b:	8b 55 14             	mov    0x14(%ebp),%edx
8010a15e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a161:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010a164:	83 ec 0c             	sub    $0xc,%esp
8010a167:	ff 75 e8             	pushl  -0x18(%ebp)
8010a16a:	e8 e3 f6 ff ff       	call   80109852 <p2v>
8010a16f:	83 c4 10             	add    $0x10,%esp
8010a172:	ff 75 f0             	pushl  -0x10(%ebp)
8010a175:	53                   	push   %ebx
8010a176:	50                   	push   %eax
8010a177:	ff 75 10             	pushl  0x10(%ebp)
8010a17a:	e8 19 7f ff ff       	call   80102098 <readi>
8010a17f:	83 c4 10             	add    $0x10,%esp
8010a182:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010a185:	74 07                	je     8010a18e <loaduvm+0xba>
      return -1;
8010a187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a18c:	eb 18                	jmp    8010a1a6 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010a18e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a195:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a198:	3b 45 18             	cmp    0x18(%ebp),%eax
8010a19b:	0f 82 5f ff ff ff    	jb     8010a100 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010a1a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a1a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a1a9:	c9                   	leave  
8010a1aa:	c3                   	ret    

8010a1ab <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010a1ab:	55                   	push   %ebp
8010a1ac:	89 e5                	mov    %esp,%ebp
8010a1ae:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010a1b1:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1b4:	85 c0                	test   %eax,%eax
8010a1b6:	79 0a                	jns    8010a1c2 <allocuvm+0x17>
    return 0;
8010a1b8:	b8 00 00 00 00       	mov    $0x0,%eax
8010a1bd:	e9 b0 00 00 00       	jmp    8010a272 <allocuvm+0xc7>
  if(newsz < oldsz)
8010a1c2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1c5:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a1c8:	73 08                	jae    8010a1d2 <allocuvm+0x27>
    return oldsz;
8010a1ca:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1cd:	e9 a0 00 00 00       	jmp    8010a272 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010a1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1d5:	05 ff 0f 00 00       	add    $0xfff,%eax
8010a1da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a1df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010a1e2:	eb 7f                	jmp    8010a263 <allocuvm+0xb8>
    mem = kalloc();
8010a1e4:	e8 de 8d ff ff       	call   80102fc7 <kalloc>
8010a1e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010a1ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a1f0:	75 2b                	jne    8010a21d <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
8010a1f2:	83 ec 0c             	sub    $0xc,%esp
8010a1f5:	68 b1 af 10 80       	push   $0x8010afb1
8010a1fa:	e8 c7 61 ff ff       	call   801003c6 <cprintf>
8010a1ff:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010a202:	83 ec 04             	sub    $0x4,%esp
8010a205:	ff 75 0c             	pushl  0xc(%ebp)
8010a208:	ff 75 10             	pushl  0x10(%ebp)
8010a20b:	ff 75 08             	pushl  0x8(%ebp)
8010a20e:	e8 61 00 00 00       	call   8010a274 <deallocuvm>
8010a213:	83 c4 10             	add    $0x10,%esp
      return 0;
8010a216:	b8 00 00 00 00       	mov    $0x0,%eax
8010a21b:	eb 55                	jmp    8010a272 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
8010a21d:	83 ec 04             	sub    $0x4,%esp
8010a220:	68 00 10 00 00       	push   $0x1000
8010a225:	6a 00                	push   $0x0
8010a227:	ff 75 f0             	pushl  -0x10(%ebp)
8010a22a:	e8 82 cd ff ff       	call   80106fb1 <memset>
8010a22f:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010a232:	83 ec 0c             	sub    $0xc,%esp
8010a235:	ff 75 f0             	pushl  -0x10(%ebp)
8010a238:	e8 08 f6 ff ff       	call   80109845 <v2p>
8010a23d:	83 c4 10             	add    $0x10,%esp
8010a240:	89 c2                	mov    %eax,%edx
8010a242:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a245:	83 ec 0c             	sub    $0xc,%esp
8010a248:	6a 06                	push   $0x6
8010a24a:	52                   	push   %edx
8010a24b:	68 00 10 00 00       	push   $0x1000
8010a250:	50                   	push   %eax
8010a251:	ff 75 08             	pushl  0x8(%ebp)
8010a254:	e8 1b fb ff ff       	call   80109d74 <mappages>
8010a259:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010a25c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a263:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a266:	3b 45 10             	cmp    0x10(%ebp),%eax
8010a269:	0f 82 75 ff ff ff    	jb     8010a1e4 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010a26f:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010a272:	c9                   	leave  
8010a273:	c3                   	ret    

8010a274 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010a274:	55                   	push   %ebp
8010a275:	89 e5                	mov    %esp,%ebp
8010a277:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010a27a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a27d:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a280:	72 08                	jb     8010a28a <deallocuvm+0x16>
    return oldsz;
8010a282:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a285:	e9 a5 00 00 00       	jmp    8010a32f <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
8010a28a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a28d:	05 ff 0f 00 00       	add    $0xfff,%eax
8010a292:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a297:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010a29a:	e9 81 00 00 00       	jmp    8010a320 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010a29f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2a2:	83 ec 04             	sub    $0x4,%esp
8010a2a5:	6a 00                	push   $0x0
8010a2a7:	50                   	push   %eax
8010a2a8:	ff 75 08             	pushl  0x8(%ebp)
8010a2ab:	e8 24 fa ff ff       	call   80109cd4 <walkpgdir>
8010a2b0:	83 c4 10             	add    $0x10,%esp
8010a2b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010a2b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a2ba:	75 09                	jne    8010a2c5 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010a2bc:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010a2c3:	eb 54                	jmp    8010a319 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010a2c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2c8:	8b 00                	mov    (%eax),%eax
8010a2ca:	83 e0 01             	and    $0x1,%eax
8010a2cd:	85 c0                	test   %eax,%eax
8010a2cf:	74 48                	je     8010a319 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010a2d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2d4:	8b 00                	mov    (%eax),%eax
8010a2d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a2db:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010a2de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a2e2:	75 0d                	jne    8010a2f1 <deallocuvm+0x7d>
        panic("kfree");
8010a2e4:	83 ec 0c             	sub    $0xc,%esp
8010a2e7:	68 c9 af 10 80       	push   $0x8010afc9
8010a2ec:	e8 75 62 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010a2f1:	83 ec 0c             	sub    $0xc,%esp
8010a2f4:	ff 75 ec             	pushl  -0x14(%ebp)
8010a2f7:	e8 56 f5 ff ff       	call   80109852 <p2v>
8010a2fc:	83 c4 10             	add    $0x10,%esp
8010a2ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010a302:	83 ec 0c             	sub    $0xc,%esp
8010a305:	ff 75 e8             	pushl  -0x18(%ebp)
8010a308:	e8 1d 8c ff ff       	call   80102f2a <kfree>
8010a30d:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010a310:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a313:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010a319:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a320:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a323:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a326:	0f 82 73 ff ff ff    	jb     8010a29f <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010a32c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010a32f:	c9                   	leave  
8010a330:	c3                   	ret    

8010a331 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010a331:	55                   	push   %ebp
8010a332:	89 e5                	mov    %esp,%ebp
8010a334:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010a337:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010a33b:	75 0d                	jne    8010a34a <freevm+0x19>
    panic("freevm: no pgdir");
8010a33d:	83 ec 0c             	sub    $0xc,%esp
8010a340:	68 cf af 10 80       	push   $0x8010afcf
8010a345:	e8 1c 62 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010a34a:	83 ec 04             	sub    $0x4,%esp
8010a34d:	6a 00                	push   $0x0
8010a34f:	68 00 00 00 80       	push   $0x80000000
8010a354:	ff 75 08             	pushl  0x8(%ebp)
8010a357:	e8 18 ff ff ff       	call   8010a274 <deallocuvm>
8010a35c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010a35f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a366:	eb 4f                	jmp    8010a3b7 <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010a368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a36b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a372:	8b 45 08             	mov    0x8(%ebp),%eax
8010a375:	01 d0                	add    %edx,%eax
8010a377:	8b 00                	mov    (%eax),%eax
8010a379:	83 e0 01             	and    $0x1,%eax
8010a37c:	85 c0                	test   %eax,%eax
8010a37e:	74 33                	je     8010a3b3 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010a380:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a383:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a38a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a38d:	01 d0                	add    %edx,%eax
8010a38f:	8b 00                	mov    (%eax),%eax
8010a391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a396:	83 ec 0c             	sub    $0xc,%esp
8010a399:	50                   	push   %eax
8010a39a:	e8 b3 f4 ff ff       	call   80109852 <p2v>
8010a39f:	83 c4 10             	add    $0x10,%esp
8010a3a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010a3a5:	83 ec 0c             	sub    $0xc,%esp
8010a3a8:	ff 75 f0             	pushl  -0x10(%ebp)
8010a3ab:	e8 7a 8b ff ff       	call   80102f2a <kfree>
8010a3b0:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010a3b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a3b7:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010a3be:	76 a8                	jbe    8010a368 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010a3c0:	83 ec 0c             	sub    $0xc,%esp
8010a3c3:	ff 75 08             	pushl  0x8(%ebp)
8010a3c6:	e8 5f 8b ff ff       	call   80102f2a <kfree>
8010a3cb:	83 c4 10             	add    $0x10,%esp
}
8010a3ce:	90                   	nop
8010a3cf:	c9                   	leave  
8010a3d0:	c3                   	ret    

8010a3d1 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010a3d1:	55                   	push   %ebp
8010a3d2:	89 e5                	mov    %esp,%ebp
8010a3d4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a3d7:	83 ec 04             	sub    $0x4,%esp
8010a3da:	6a 00                	push   $0x0
8010a3dc:	ff 75 0c             	pushl  0xc(%ebp)
8010a3df:	ff 75 08             	pushl  0x8(%ebp)
8010a3e2:	e8 ed f8 ff ff       	call   80109cd4 <walkpgdir>
8010a3e7:	83 c4 10             	add    $0x10,%esp
8010a3ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010a3ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010a3f1:	75 0d                	jne    8010a400 <clearpteu+0x2f>
    panic("clearpteu");
8010a3f3:	83 ec 0c             	sub    $0xc,%esp
8010a3f6:	68 e0 af 10 80       	push   $0x8010afe0
8010a3fb:	e8 66 61 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010a400:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a403:	8b 00                	mov    (%eax),%eax
8010a405:	83 e0 fb             	and    $0xfffffffb,%eax
8010a408:	89 c2                	mov    %eax,%edx
8010a40a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a40d:	89 10                	mov    %edx,(%eax)
}
8010a40f:	90                   	nop
8010a410:	c9                   	leave  
8010a411:	c3                   	ret    

8010a412 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010a412:	55                   	push   %ebp
8010a413:	89 e5                	mov    %esp,%ebp
8010a415:	53                   	push   %ebx
8010a416:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010a419:	e8 e6 f9 ff ff       	call   80109e04 <setupkvm>
8010a41e:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010a421:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a425:	75 0a                	jne    8010a431 <copyuvm+0x1f>
    return 0;
8010a427:	b8 00 00 00 00       	mov    $0x0,%eax
8010a42c:	e9 f8 00 00 00       	jmp    8010a529 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010a431:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a438:	e9 c4 00 00 00       	jmp    8010a501 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010a43d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a440:	83 ec 04             	sub    $0x4,%esp
8010a443:	6a 00                	push   $0x0
8010a445:	50                   	push   %eax
8010a446:	ff 75 08             	pushl  0x8(%ebp)
8010a449:	e8 86 f8 ff ff       	call   80109cd4 <walkpgdir>
8010a44e:	83 c4 10             	add    $0x10,%esp
8010a451:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a454:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a458:	75 0d                	jne    8010a467 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010a45a:	83 ec 0c             	sub    $0xc,%esp
8010a45d:	68 ea af 10 80       	push   $0x8010afea
8010a462:	e8 ff 60 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010a467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a46a:	8b 00                	mov    (%eax),%eax
8010a46c:	83 e0 01             	and    $0x1,%eax
8010a46f:	85 c0                	test   %eax,%eax
8010a471:	75 0d                	jne    8010a480 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010a473:	83 ec 0c             	sub    $0xc,%esp
8010a476:	68 04 b0 10 80       	push   $0x8010b004
8010a47b:	e8 e6 60 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010a480:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a483:	8b 00                	mov    (%eax),%eax
8010a485:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a48a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010a48d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a490:	8b 00                	mov    (%eax),%eax
8010a492:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a497:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010a49a:	e8 28 8b ff ff       	call   80102fc7 <kalloc>
8010a49f:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010a4a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010a4a6:	74 6a                	je     8010a512 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010a4a8:	83 ec 0c             	sub    $0xc,%esp
8010a4ab:	ff 75 e8             	pushl  -0x18(%ebp)
8010a4ae:	e8 9f f3 ff ff       	call   80109852 <p2v>
8010a4b3:	83 c4 10             	add    $0x10,%esp
8010a4b6:	83 ec 04             	sub    $0x4,%esp
8010a4b9:	68 00 10 00 00       	push   $0x1000
8010a4be:	50                   	push   %eax
8010a4bf:	ff 75 e0             	pushl  -0x20(%ebp)
8010a4c2:	e8 a9 cb ff ff       	call   80107070 <memmove>
8010a4c7:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010a4ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010a4cd:	83 ec 0c             	sub    $0xc,%esp
8010a4d0:	ff 75 e0             	pushl  -0x20(%ebp)
8010a4d3:	e8 6d f3 ff ff       	call   80109845 <v2p>
8010a4d8:	83 c4 10             	add    $0x10,%esp
8010a4db:	89 c2                	mov    %eax,%edx
8010a4dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4e0:	83 ec 0c             	sub    $0xc,%esp
8010a4e3:	53                   	push   %ebx
8010a4e4:	52                   	push   %edx
8010a4e5:	68 00 10 00 00       	push   $0x1000
8010a4ea:	50                   	push   %eax
8010a4eb:	ff 75 f0             	pushl  -0x10(%ebp)
8010a4ee:	e8 81 f8 ff ff       	call   80109d74 <mappages>
8010a4f3:	83 c4 20             	add    $0x20,%esp
8010a4f6:	85 c0                	test   %eax,%eax
8010a4f8:	78 1b                	js     8010a515 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010a4fa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a501:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a504:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a507:	0f 82 30 ff ff ff    	jb     8010a43d <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010a50d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a510:	eb 17                	jmp    8010a529 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010a512:	90                   	nop
8010a513:	eb 01                	jmp    8010a516 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010a515:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010a516:	83 ec 0c             	sub    $0xc,%esp
8010a519:	ff 75 f0             	pushl  -0x10(%ebp)
8010a51c:	e8 10 fe ff ff       	call   8010a331 <freevm>
8010a521:	83 c4 10             	add    $0x10,%esp
  return 0;
8010a524:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a529:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a52c:	c9                   	leave  
8010a52d:	c3                   	ret    

8010a52e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010a52e:	55                   	push   %ebp
8010a52f:	89 e5                	mov    %esp,%ebp
8010a531:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a534:	83 ec 04             	sub    $0x4,%esp
8010a537:	6a 00                	push   $0x0
8010a539:	ff 75 0c             	pushl  0xc(%ebp)
8010a53c:	ff 75 08             	pushl  0x8(%ebp)
8010a53f:	e8 90 f7 ff ff       	call   80109cd4 <walkpgdir>
8010a544:	83 c4 10             	add    $0x10,%esp
8010a547:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a54a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a54d:	8b 00                	mov    (%eax),%eax
8010a54f:	83 e0 01             	and    $0x1,%eax
8010a552:	85 c0                	test   %eax,%eax
8010a554:	75 07                	jne    8010a55d <uva2ka+0x2f>
    return 0;
8010a556:	b8 00 00 00 00       	mov    $0x0,%eax
8010a55b:	eb 29                	jmp    8010a586 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a55d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a560:	8b 00                	mov    (%eax),%eax
8010a562:	83 e0 04             	and    $0x4,%eax
8010a565:	85 c0                	test   %eax,%eax
8010a567:	75 07                	jne    8010a570 <uva2ka+0x42>
    return 0;
8010a569:	b8 00 00 00 00       	mov    $0x0,%eax
8010a56e:	eb 16                	jmp    8010a586 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a570:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a573:	8b 00                	mov    (%eax),%eax
8010a575:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a57a:	83 ec 0c             	sub    $0xc,%esp
8010a57d:	50                   	push   %eax
8010a57e:	e8 cf f2 ff ff       	call   80109852 <p2v>
8010a583:	83 c4 10             	add    $0x10,%esp
}
8010a586:	c9                   	leave  
8010a587:	c3                   	ret    

8010a588 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a588:	55                   	push   %ebp
8010a589:	89 e5                	mov    %esp,%ebp
8010a58b:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a58e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a591:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a594:	eb 7f                	jmp    8010a615 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a596:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a599:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a59e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a5a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5a4:	83 ec 08             	sub    $0x8,%esp
8010a5a7:	50                   	push   %eax
8010a5a8:	ff 75 08             	pushl  0x8(%ebp)
8010a5ab:	e8 7e ff ff ff       	call   8010a52e <uva2ka>
8010a5b0:	83 c4 10             	add    $0x10,%esp
8010a5b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a5b6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a5ba:	75 07                	jne    8010a5c3 <copyout+0x3b>
      return -1;
8010a5bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a5c1:	eb 61                	jmp    8010a624 <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a5c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5c6:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a5c9:	05 00 10 00 00       	add    $0x1000,%eax
8010a5ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a5d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5d4:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a5d7:	76 06                	jbe    8010a5df <copyout+0x57>
      n = len;
8010a5d9:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a5df:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5e2:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a5e5:	89 c2                	mov    %eax,%edx
8010a5e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5ea:	01 d0                	add    %edx,%eax
8010a5ec:	83 ec 04             	sub    $0x4,%esp
8010a5ef:	ff 75 f0             	pushl  -0x10(%ebp)
8010a5f2:	ff 75 f4             	pushl  -0xc(%ebp)
8010a5f5:	50                   	push   %eax
8010a5f6:	e8 75 ca ff ff       	call   80107070 <memmove>
8010a5fb:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a5fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a601:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a604:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a607:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a60a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a60d:	05 00 10 00 00       	add    $0x1000,%eax
8010a612:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a615:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a619:	0f 85 77 ff ff ff    	jne    8010a596 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a61f:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a624:	c9                   	leave  
8010a625:	c3                   	ret    
