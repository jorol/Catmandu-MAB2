use strict;
use warnings;
use Test::More;

use Catmandu;
use Catmandu::Exporter::MAB2;

my $exporter = Catmandu::Exporter::MAB2->new(file => "./t/mab2.dat", type=> "RAW");

my @records;

my $n = $exporter->each(sub {
    push(@records, $_[0]);
});

use Data::Dumper;

print \@records;