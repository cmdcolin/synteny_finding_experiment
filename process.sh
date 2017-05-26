#!/usr/bin/env bash

diamond makedb --in $1 -d target_db
diamond blastp -d target_db --query $2 -o output.m8

cut -f2 output.m8|perl process.pl|grep NW_|grep 2,3,4,5,6>genomic_locs.txt
LC_ALL=C sort -k5,5 genomic_locs.txt > genomic_locs.sort.txt
cat $3 | awk '$3 ~ /mRNA/' | sed -e 's/ID=\(.*\);Parent=.*/\1/' > mrnas.txt
LC_ALL=C sort -k9,9 mrnas.txt > mrnas.sort.txt

LC_ALL=C sort -k1,1 output.m8 > output.sort.m8
join -1 9 -2 1 -t $'\t' mrnas.txt output.sort.m8 > output.joined.m8
LC_ALL=C sort -k2,2 output.joined.m8 > output.sort.m8
join -1 5 -2 2 -t $'\t' genomic_locs.txt output.sort.m8 > output.joined.m8

