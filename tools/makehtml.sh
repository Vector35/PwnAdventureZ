#!/bin/bash
#This is an awful hack that will only work on the same size ROM. Fix later. 
(cat tools/PwnAdventureZ.html.1; xxd -i PwnAdventureZ.nes|tail -n+2|head -n 10924; cat tools/PwnAdventureZ.html.2) > PwnAdventureZ.html
