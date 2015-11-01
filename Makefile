CA65 = cc65/bin/ca65
LD65 = cc65/bin/ld65

OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
INC = $(wildcard *.inc)
CHR = $(wildcard *.chr)

PwnAdventureZ.nes: $(OBJS) flagemu.o Makefile mapper1.cfg PwnAdventureZ_prg.bin
	$(LD65) -C mapper1.cfg -o $@ $(OBJS) flagemu.o -vm --mapfile PwnAdventureZ.map
	md5 -q PwnAdventureZ.map | xxd -r -p | dd of=PwnAdventureZ.nes bs=1 seek=131078 count=4 conv=notrunc
	python usage.py
	python tools/map2nl.py PwnAdventureZ.map
	tools/makehtml.sh
	zip PwnAdventureZ.zip PwnAdventureZ.nes* PwnAdventureZ.map instructions.txt

PwnAdventureZ_prg.bin: $(OBJS) flagreal.o Makefile mapper1.cfg
	$(LD65) -C mapper1.cfg -o PwnAdventureZ_physical.nes $(OBJS) flagreal.o -vm --mapfile PwnAdventureZ.map
	md5 -q PwnAdventureZ.map | xxd -r -p | dd of=PwnAdventureZ_physical.nes bs=1 seek=131078 count=4 conv=notrunc
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
	rm -f PwnAdventureZ.zip 
	rm -f PwnAdventureZ.html
	rm -f PwnAdventureZ.nes
	rm -f PwnAdventureZ.map
	rm -f PwnAdventureZ_physical.nes
	rm -f PwnAdventureZ_prg.bin
	rm -f *.o *.nl
