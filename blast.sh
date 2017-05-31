#!/usr/bin/env bash

echo "Performing alignments"
[ -f output.m8 ] || makeblastdb -dbtype prot -in $1 -out target_db
[ -f output.m8 ] || blastp -db target_db -query $2 -out output.m8 -num_threads 4

echo "Processing output"
[ -f genomic_locs.txt ] || cut -f2 output.m8|sort|uniq|perl process.pl|grep NW_|cut -f 2,3,4,5,6>genomic_locs.txt
echo "Uniquifying output"
sort genomic_locs.txt|uniq > genomic_locs.uniq.txt
wc genomic_locs.uniq.txt
echo "Sorting output 1/2"
LC_ALL=C sort -k5,5 genomic_locs.uniq.txt > genomic_locs.sort.txt
echo "Awking output"
cat $3 | awk '$3 ~ /mRNA/' | sed -e 's/ID=\(.*\);Parent=.*/\1/' > mrnas.txt
wc mrnas.txt
echo "Sorting output 2/2"
LC_ALL=C sort -k9,9 mrnas.txt > mrnas.sort.txt

echo "Join 1/2"
LC_ALL=C sort -k1,1 output.m8 > output.sort.m8
join -1 9 -2 1 -t $'\t' mrnas.sort.txt output.sort.m8 > output.joined.m8
wc output.joined.m8
echo "Join 2/2"
LC_ALL=C sort -k10,10 output.joined.m8 > output.sort.m8
join -1 5 -2 10 -t $'\t' genomic_locs.sort.txt output.sort.m8 > output.joined.m8
wc output.joined.m8
awk -v OFS='\t' '{print $2, $7, $15, $16, $17, $18, $3, $4, $10, $11, $23, $24}' output.joined.m8 > output.blasttab
