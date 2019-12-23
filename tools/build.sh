#!/bin/bash
bootsect=$1
setup=$2
bootimage=$3
echo $bootsect
echo $setup
echo $bootimage
# Write bootsect (512 bytes, one sector)
[ ! -f "$bootsect" ] && echo "there is no bootsect binary file there" && exit -1
dd if=$bootsect bs=512 count=1 of=$bootimage > /dev/null

# Write setup(4 * 512bytes, four sectors) 
[ ! -f "$setup" ] && echo "there is no setup binary file there" && exit -1
cat $setup >> $bootimage
