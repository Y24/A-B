include Makefile.header
BOCHS=bochs
LDFLAGS	+= -Ttext 0 -e startup_32
CFLAGS	+= -Iinclude
CPP	+= -Iinclude
all: Image
Image: boot/bootsect boot/setup
	@tools/build.sh boot/bootsect boot/setup bootimage-fd
boot/bootsect: boot/bootsect.s
	@make bootsect -C boot
boot/setup: boot/setup.s
	@make setup -C boot
.c.s:
	@$(CC) $(CFLAGS) -S -o $*.s $<
.s.o:
	@$(AS)  -o $*.o $<
.c.o:
	@$(CC) $(CFLAGS) -c -o $*.o $<
start:
	@${BOCHS} -q -f tools/bochs/bochsrc-fd.bxrc
clean:
	@rm -f bootimage-fd
	@make clean -C boot
