#!/usr/bin/env bash

[ -f output.m8 ] || diamond makedb --in $1 -d target_db
[ -f output.m8 ] || diamond blastp -d target_db --query $2 -o output.m8

echo "Processing output"
[ -f genomics_locs.txt ] || cut -f2 output.m8|perl process.pl|grep NW_|cut -f 2,3,4,5,6>genomic_locs.txt
sort genomic_locs.txt|uniq > genomic_locs.uniq.txt
echo "Sorting output 1/2"
LC_ALL=C sort -k5,5 genomic_locs.uniq.txt > genomic_locs.sort.txt
echo "Awking output"
cat $3 | awk '$3 ~ /mRNA/' | sed -e 's/ID=\(.*\);Parent=.*/\1/' > mrnas.txt
echo "Sorting output 2/2"
LC_ALL=C sort -k9,9 mrnas.txt > mrnas.sort.txt

LC_ALL=C sort -k1,1 output.m8 > output.sort.m8
join -1 9 -2 1 -t $'\t' mrnas.txt output.sort.m8 > output.joined.m8
LC_ALL=C sort -k2,2 output.joined.m8 > output.sort.m8
join -1 5 -2 2 -t $'\t' genomic_locs.sort.txt output.sort.m8 > output.joined.m8

