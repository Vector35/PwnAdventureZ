#!/usr/bin/env python
f = open("PwnAdventureZ.map", "r")
seg_list = False

zero_size = 0
ram_size = 0
code_size = 0
fixed_size = 0
data_size = 0
chr_size = 0

for line in f:
	if line.startswith("Segment list"):
		seg_list = True
	elif line.startswith("Exports"):
		seg_list = False
	elif seg_list:
		while True:
			n = line.replace("  ", " ")
			if line == n:
				break
			line = n
		parts = line.split(' ')
		if len(parts) >= 5:
			if parts[0] == "ZEROPAGE":
				zero_size += int(parts[3], 16)
			elif parts[0] == "BSS":
				ram_size += int(parts[3], 16)
			elif parts[0] == "CODE":
				code_size += int(parts[3], 16)
			elif parts[0] == "FIXED":
				fixed_size += int(parts[3], 16)
			elif parts[0] == "DATA":
				data_size += int(parts[3], 16)
			elif parts[0] == "RODATA":
				data_size += int(parts[3], 16)
			elif parts[0][:3] == "CHR":
				chr_size += int(parts[3], 16)

rom_size = code_size + data_size

print "Bank 0:     %5d of %5d bytes  %3d%%  %5d bytes code, %5d bytes data" % (rom_size, 0x4000, int((rom_size * 100.0) / 0x4000), code_size, data_size)
print "Fixed bank: %5d of %5d bytes  %3d%%" % (fixed_size, 0x3ffa, int((fixed_size * 100.0) / 0x3ffa))
print "RAM:        %5d of %5d bytes  %3d%%" % (ram_size, 0x500, int((ram_size * 100.0) / 0x500))
print "Zero page:  %5d of %5d bytes  %3d%%" % (zero_size, 0x100, int((zero_size * 100.0) / 0x600))
print "CHR:        %5d of %5d chars  %3d%%" % (chr_size / 16, 0x1800, int((chr_size * 100.0) / 0x18000))

