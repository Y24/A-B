# boot.s 程序
# 首先利用 BIOS 中断把内核代码(head 代码)加载到内存 0x10000 处,然后移动到内存 0 处。
# 最后进入保护模式,并跳转到内存 0(head 代码)开始处继续运行。
.code16
.global _start, begtext, begdata, begbss, endtext, enddata, endbss
	.text
	begtext:
	.data
	begdata:
	.bss
	begbss:
	.text
	.equ BOOTSEG, 0x07c0		# 引导扇区(本程序)被 BIOS 加载到内存 0x7c00 处。
	.equ SYSSEG, 0x1000		# 内核(head)先加载到 0x10000 处,然后移动到 0x0 处。
	.equ SYSLEN, 17		# 内核占用的最大磁盘扇区数。
	.equ READAX, 0x200 + SYSLEN
	# 段间跳转至 0x7c0:go 处。
	# 当本程序刚运行时所有段寄存器值均为 0。
	# 该跳转语句会把 CS 寄存器加载为 0x7c0(原为 0)。
	ljmp    $BOOTSEG, $_start 
_start:
	# 让 DS 和 SS 都指向 0x7c0 段。
	mov %cs,%ax
	mov %ax,%ds
	mov %ax,%ss
	mov %ax,%es
	# 设置临时栈指针。其值需大于程序末端并有一定空间即可。
	mov $0x400,%sp
# 加载内核代码到内存 0x10000 开始处。
# 利用 BIOS 中断 int 0x13 功能 2 从启动盘读取 head 代码。
# DH - 磁头号;DL - 驱动器号;CH - 10 位磁道号低 8 位;
# CL - 位 7、 6 是磁道号高 2 位,位 5-0 起始扇区号(从 1 计)。
# ES:BX - 读入缓冲区位置(0x1000:0x0000)。
# AH - 读扇区功能号;AL - 需读的扇区数(17)。
load_system:
	push %ax
	mov $0x0000,%dx
	mov $0x0002,%cx
	mov $SYSSEG,%ax
	mov %ax,%es
	xor %bx,%bx
	mov $READAX,%ax
	int $0x13
	# 若没有发生错误则跳转继续运行,否则死循环。
	jnc ok_load
die: jmp die
# 把内核代码移动到内存 0 开始处。共移动 8KB 字节(内核长度不超过 8KB)。
ok_load:
# Print some inane message
/*	pop %es
	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$len, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $msg1, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10
*/
	cli # 关中断
	mov $0x00000,%ax
	cld # 'direction'=0, movs moves forward
do_move:
	mov	%ax, %es	# destination segment
	add	$0x1000, %ax
	cmp	$0x3000, %ax
	jz	end_move
	mov	%ax, %ds	# source segment
	sub	%di, %di
	sub	%si, %si
	mov $0x2000, %cx
	rep movsw
	jmp	do_move
end_move:
# 加载 IDT 和 GDT 基地址寄存器 IDTR 和 GDTR。
	mov $BOOTSEG,%ax
	mov %ax,%ds # 让 DS 重新指向 0x7c0 段。
	lidt idt_48 # 加载 IDTR。 6 字节操作数: 2 字节表长度, 4 字节线性基地址。
	lgdt gdt_48 # 加载 GDTR。 6 字节操作数: 2 字节表长度, 4 字节线性基地址。
# 设置控制寄存器 CR0(即机器状态字),进入保护模式。段选择符值 8 对应 GDT 表中第 2 个段描述符。
	mov 0x0001,%ax # 在 CR0 中设置保护模式标志 PE(位 0)。
	lmsw %ax # 然后跳转至段选择符值指定的段中,偏移 0 处。
	ljmp $8,$0 # 注意此时段值已是段选择符。该段的线性基地址是 0。
# 下面是全局描述符表 GDT 的内容。其中包含 3 个段描述符。第 1 个不用,另 2 个是代码和数据段描述符。
gdt: 
	.word 0, 0, 0, 0 # 段描述符 0,不用。每个描述符项占 8 字节。

	.word 0x07ff # 段描述符 1。8Mb - 段限长值=2047 (2048*4096=8MB)。
	.word 0x0000 # 段基地址=0x00000。
	.word 0x9a00 # 是代码段,可读/执行。
	.word 0x00c0 # 段属性颗粒度=4KB,80386。

	.word 0x07ff # 段描述符 2。8Mb - 段限长值=2047 (2048*4096=8MB)。
	.word 0x0000 # 段基地址=0x00000。
	.word 0x9200 # 是数据段,可读写。
	.word 0x00c0 # 段属性颗粒度=4KB,80386。
# 下面分别是 LIDT 和 LGDT 指令的 6 字节操作数。
idt_48: 
	.word 0     # IDT 表长度是 0。
	.word 0,0   # IDT 表的线性基地址也是 0。
gdt_48:
	.word 0x7ff # GDT 表长度是 2048 字节,可容纳 256 个描述符项。
	.word 0x7c00+gdt,0 # GDT 表的线性基地址在 0x7c0 段的偏移 gdt 处。
		
msg1:
	.byte 13,10
	.ascii "Hello  44mefldnvf,v b kernel is loading ****"
	.byte 13,10
	.equ len, . - msg1
	.org 510
boot_flag:
	.word 0xAA55 # 引导扇区有效标志。必须处于引导扇区最后 2 字节处。
	
	.text
	endtext:
	.data
	enddata:
	.bss
	endbss:
