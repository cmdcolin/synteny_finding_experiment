#!/usr/bin/env bash
export LC_ALL=C

echo "Performing alignments"
[ -f output.m8 ] || diamond makedb --in $1 -d target_db
[ -f output.m8 ] || diamond blastp -d target_db --query $2 -o output.m8

echo "Processing output"
[ -f genomic_locs.txt ] || cut -f2 output.m8|sort |uniq|perl process.pl|grep NW_|cut -f 2,3,4,5,6>genomic_locs.txt
echo "Awking output"
cat $3 | awk '$3 ~ /mRNA/' | sed -e 's/ID=\(.*\);Parent=.*/\1/' > mrnas.txt
wc mrnas.txt
echo "Join 1/2"
join -1 9 -2 1 <(sort -k9,9 mrnas.txt) <(sort -k1,1 output.m8) > output.joined.m8
wc output.joined.m8
echo "Join 2/2"
join -1 5 -2 10 <(cat genomic_locs.txt|sort|uniq|sort -k5,5) <(sort -k10,10 output.joined.m8) > output.joined2.m8
wc output.joined2.m8
awk -v OFS='\t' '{print $2, $7, $15, $16, $17, $18, $3, $4, $10, $11, $23, $24}' output.joined2.m8 > output.blasttab
