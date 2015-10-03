CA65 = cc65/bin/ca65
LD65 = cc65/bin/ld65

OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
INC = $(wildcard *.inc)
CHR = $(wildcard *.chr)

PwnAdventureZ.nes: $(OBJS) flagemu.o mapper1.o Makefile mapper1.cfg PwnAdventureZ_prg.bin PwnAdventureZ_mapper2.nes
	$(LD65) -C mapper1.cfg -o $@ $(OBJS) flagemu.o mapper1.o -vm --mapfile PwnAdventureZ.map
	md5 -q PwnAdventureZ.map | xxd -r -p | dd of=PwnAdventureZ.nes bs=1 seek=131078 count=4 conv=notrunc
	python usage.py
	python tools/map2nl.py PwnAdventureZ.map

PwnAdventureZ_prg.bin: $(OBJS) flagreal.o mapper1.o Makefile mapper1.cfg
	$(LD65) -C mapper1.cfg -o PwnAdventureZ_physical.nes $(OBJS) flagreal.o mapper1.o -vm --mapfile PwnAdventureZ.map
	md5 -q PwnAdventureZ.map | xxd -r -p | dd of=PwnAdventureZ_physical.nes bs=1 seek=131078 count=4 conv=notrunc
	dd if=PwnAdventureZ_physical.nes of=PwnAdventureZ_prg.bin bs=1 skip=16
	dd if=PwnAdventureZ_physical.nes of=PwnAdventureZ_prg.bin bs=1 skip=16 seek=131072 conv=notrunc

PwnAdventureZ_mapper2.nes: $(OBJS) flagemu.o mapper2.o Makefile mapper2.cfg PwnAdventureZ_mapper2_prg.bin
	$(LD65) -C mapper2.cfg -o $@ $(OBJS) flagemu.o mapper2.o -vm --mapfile PwnAdventureZ_mapper2.map
	md5 -q PwnAdventureZ_mapper2.map | xxd -r -p | dd of=PwnAdventureZ_mapper2.nes bs=1 seek=131078 count=4 conv=notrunc
	python tools/map2nl.py PwnAdventureZ_mapper2.map

PwnAdventureZ_mapper2_prg.bin: $(OBJS) flagreal.o mapper2.o Makefile mapper2.cfg
	$(LD65) -C mapper2.cfg -o PwnAdventureZ_mapper2_physical.nes $(OBJS) flagreal.o mapper2.o -vm --mapfile PwnAdventureZ_mapper2.map
	md5 -q PwnAdventureZ_mapper2.map | xxd -r -p | dd of=PwnAdventureZ_mapper2_physical.nes bs=1 seek=131078 count=4 conv=notrunc
	dd if=PwnAdventureZ_mapper2_physical.nes of=PwnAdventureZ_mapper2_prg.bin bs=1 skip=16

$(CA65) $(LD65):
	cd cc65; make ca65 ld65

%.o: %.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<

flagreal.o: flag/flagreal.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<
flagemu.o: flag/flagemu.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<

mapper1.o: mapper/mapper1.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<
mapper2.o: mapper/mapper2.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<

clean:
	rm -f PwnAdventureZ.nes
	rm -f PwnAdventureZ.map
	rm -f PwnAdventureZ_physical.nes
	rm -f PwnAdventureZ_prg.bin
	rm -f PwnAdventureZ_mapper2.nes
	rm -f PwnAdventureZ_mapper2.map
	rm -f PwnAdventureZ_mapper2_physical.nes
	rm -f PwnAdventureZ_mapper2_prg.bin
	rm -f *.o *.nl
