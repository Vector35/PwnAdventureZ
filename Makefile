CA65 = cc65/bin/ca65
LD65 = cc65/bin/ld65

OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
INC = $(wildcard *.inc)
CHR = $(wildcard *.chr)

PwnAdventureZ.nes: $(OBJS) Makefile mapper0.cfg
	$(LD65) -C mapper0.cfg -o $@ $(OBJS) -vm --mapfile PwnAdventureZ.map
	python usage.py

$(CA65) $(LD65):
	cd cc65; make ca65 ld65

%.o: %.asm Makefile $(CA65) $(LD65) $(CHR) $(INC)
	$(CA65) -o $@ -t nes -U $<

clean:
	rm -f PwnAdventureZ.nes
	rm -f PwnAdventureZ.map
	rm -f *.o

