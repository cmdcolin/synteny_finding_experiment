#!/usr/bin/env perl
use strict;
use warnings;

sub readNLines {
    my $lines_to_read = shift or die '....';
    my @lines_read;
    while(<>) {
        chomp;
        push( @lines_read, $_ );
        last if @lines_read == $lines_to_read;
    }
    return @lines_read;
}

sub readRecord {
    return join(',',readNLines(50))
}

while (my $lines = readRecord()) {
#    print $lines;
    my $output = `efetch -db protein -id $lines -format ipg|grep -v Start`;
    print $output;
}
