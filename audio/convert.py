#!/usr/bin/env python
import sys
import struct
import subprocess

if len(sys.argv) < 3:
	print "Usage: convert.py <basename> effect|music"

if sys.argv[2] == "effect":
	effect = True
	prefix = "effect_"
elif sys.argv[2] == "music":
	effect = False
	prefix = "music_"
else:
	print "Type is invalid"
	sys.exit(1)

subprocess.call(['node', 'convert.js', sys.argv[1]])

f = open(sys.argv[1] + '.txt', 'r')
values = [-1] * 16

frames = 0
total = 0

data = ""
last = ""

for line in f:
	if len(line.strip()) == 0:
		break
	data += last

	regs = [[int(y, 16) for y in x.split('=')] for x in line.strip().split(' ')]
	changed = {}
	for reg in regs:
		if effect and ((reg[0] & 0xf) < 8):
			continue
		if (reg[1] != values[reg[0] & 0xf]) or ((reg[0] & 3) == 3):
			changed[reg[0] & 0xf] = reg[1]
			values[reg[0] & 0xf] = reg[1]
			total += 1

	mask = 0
	contents = ""
	for i in xrange(0, 16):
		if (i != 9) and (i != 0xd):
			if i in changed:
				mask |= 1 << i
				contents += chr(changed[i])

	if effect:
		last = struct.pack("<B", mask >> 8) + contents
	else:
		last = struct.pack("<H", mask) + contents

	frames += 1

if effect:
	last = chr(ord(last[0]) | 2) + last[1:]
else:
	last = last[0] + chr(ord(last[1]) | 2) + last[2:]
data += last

if effect:
	contents = "VAR " + prefix + sys.argv[1] + "\n"
	for i in xrange(0, len(data)):
		if (i % 16) == 0:
			if i != 0:
				contents += "\n"
			contents += "\t.byte "
		if (i % 16) != 0:
			contents += ", "
		contents += "$%.2x" % ord(data[i])
	contents += "\n"
	open(sys.argv[1] + '.asm', 'w').write(contents)
else:
	pages = "VAR " + prefix + sys.argv[1] + "_ptr\n"
	banks = "VAR " + prefix + sys.argv[1] + "_bank\n"
	contents = ""

	for i in xrange(0, len(data), 0x100):
		pages += "\t.word " + prefix + sys.argv[1] + "_page_%d & $ffff\n" % (i / 0x100)
		banks += "\t.byte ^" + prefix + sys.argv[1] + "_page_%d\n" % (i / 0x100)
		n = 0x100
		if (i + n) > len(data):
			n = len(data) - i
		contents += "\nVAR " + prefix + sys.argv[1] + "_page_%d\n" % (i / 0x100)
		for j in xrange(0, n):
			if (j % 16) == 0:
				if j != 0:
					contents += "\n"
				contents += "\t.byte "
			if (j % 16) != 0:
				contents += ", "
			contents += "$%.2x" % ord(data[i + j])
		contents += "\n"

	open(sys.argv[1] + '.asm', 'w').write(pages + "\n" + banks + "\n" + contents)

