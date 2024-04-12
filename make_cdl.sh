#!/bin/bash

fname=test.cdl
lines=`wc -l salt.txt | cut -d " " -f 1`

echo "netcdf test {" > $fname
echo "dimensions:" >> $fname
echo -e "\tt = ${lines} ;" >> $fname
echo "variables:" >> $fname
echo -e "\tfloat salt(t) ;" >> $fname
echo "//" >> $fname
echo "data:" >> $fname
echo "" >> $fname
echo " salt = " >> $fname
ii=0
for x in `cat salt.txt`; do
    ii=$((ii+1))
    if [ $ii -lt $lines ]; then
        echo -n "${x}, " >> $fname
    else
        echo "${x} ;" >> $fname
    fi
done
echo "}" >> $fname
