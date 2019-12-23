include ../Makefile.header

LDFLAGS	+= -Ttext 0

all: bootsect setup

bootsect: bootsect.s
	@$(AS) -o bootsect.o bootsect.s
	@$(LD) $(LDFLAGS) -o bootsect bootsect.o
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary bootsect

setup: setup.o
	@$(LD) $(LDFLAGS) -e startup_32 -s -x -M -o setup setup.o > System.map
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary setup
head.o: head.s
	@$(AS) -o head.o head.s
setup.o: setup.s
	@$(AS) -o setup.o setup.s
clean:
	@rm -f bootsect bootsect.o setup setup.o head.o System.map