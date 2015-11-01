#!/usr/bin/env python
import sys
import os
import re

__description__ = 'used to convert .map files created by CCA65 into .nl files useful for symbolic debugging in FCEUX'
__author__ = 'Jordan Wiens'
__version__ = '0.0.1'
__date__ = '2015-09-28'

def usage():
    print 'usage: %s map-file\n\nProduces rom-file.ram.nl and rom-file.[0-n].nl files' % sys.argv[0]

def main():
	if len(sys.argv) != 2:
		usage()
		sys.exit(1)
	mapfilename = sys.argv[1]
	romfilename = mapfilename.split('.nes')[0]+'.nes'

	try:
		mapfilehandle = open(mapfilename, 'r')
	except:
		print('Error opening map file %s' % mapfilename)
		sys.exit(1)

	'''Segment list'''
	mapfile = mapfilehandle.read(-1).split('\n')
	index = mapfile.index('Segment list:')+4
	segments = []
	while (mapfile[index]!=''):
		line = re.split(r"\s{1,}", mapfile[index].strip())
		segments.append(line)
		index += 1
	
	'''Exports'''
	index = mapfile.index('Exports list by value:')+2
	exports = []
	while (mapfile[index]!=''):
		line = re.split(r"\s{1,}", mapfile[index].strip())
		exports.append([line[1],line[0]])
		if len(line) > 3:
			exports.append([line[4],line[3]])
		index += 1

	ram = open(mapfilename[0:-4] + ".nes.ram.nl","wb")
	bank = []
	for index in xrange(16):
		bank.append(open(mapfilename[0:-4] + ".nes."+str(index)+".nl","wb"))

	for item in exports:
		offset=int(item[0],16)
		name = item[1]
		if (offset & 0xff0000) == 0:
			if (offset < 0x8000):
				output=ram
			else:
				if (offset < 0xc000):
					output=bank[0]
				else:
					output=bank[15]
		else:
			output=bank[(offset & 0xff0000) >> 16]
			offset = offset & 0xffff
		output.write("$%04x#%s#\n" % (offset,name))

	ram.close()
	for item in bank:
		item.close()

if __name__ == '__main__':
    main()
