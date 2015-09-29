#!/bin/bash
mapname=$1
if [ ! -f $mapname ]
then
	echo $mapname must be a file
	return 1
else
	if ! grep 'Exports list by name' $mapname >/dev/null
	then
		echo $mapname is not a valid map file
		return 1
	fi
fi
romname=`echo $mapname|sed 's/\.map/\.nes/'`

echo Creating $romname.ram.nl
tr '\n' '|' < $mapname |sed 's/.*Exports list by name:|---------------------|//g;s/||.*//g' \
|tr '|' '\n'|awk '{print "$"substr($2,3,4)"#"$1"#\n""$"substr($5,3,4)"#"$4"#"}' \
|grep -v '^\$\#\#$'|sort > $romname.ram.nl

for digit in {0..7}
	do 	
		echo Creating $romname.$digit.nl
		cp $romname.ram.nl $romname.$digit.nl
	done
