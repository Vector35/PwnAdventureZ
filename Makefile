CA65 = cc65/bin/ca65
LD65 = cc65/bin/ld65

OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
INC = $(wildcard *.inc)
CHR = $(wildcard *.chr)

PwnAdventureZ.nes: $(OBJS) flagemu.o Makefile mapper2.cfg PwnAdventureZ_prg.bin
	$(LD65) -C mapper2.cfg -o $@ $(OBJS) flagemu.o -vm
	python usage.py

PwnAdventureZ_prg.bin: $(OBJS) flagreal.o Makefile mapper2.cfg
	$(LD65) -C mapper2.cfg -o PwnAdventureZ_physical.nes $(OBJS) flagreal.o -vm --mapfile PwnAdventureZ.map
	dd if=PwnAdventureZ_physical.nes of=PwnAdventureZ_prg.bin bs=1 skip=16

$(CA65) $(LD65):
	cd cc65; make ca65 ld65

%.o: %.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<

flagreal.o: flag/flagreal.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<
flagemu.o: flag/flagemu.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<

clean:
	rm -f PwnAdventureZ.nes
	rm -f PwnAdventureZ.map
	rm -f PwnAdventureZ_physical.nes
	rm -f PwnAdventureZ_prg.bin
	rm -f *.o
