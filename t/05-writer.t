use strict;
use Test::More;
use MAB2::Writer::RAW;
use MAB2::Writer::XML;

use File::Temp qw(tempfile);
use IO::File;
use Encode qw(encode);

my ($fh, $filename) = tempfile();
my $writer = MAB2::Writer::XML->new( fh => $fh );

my @mab_records = (

    [
      ['001', ' ', '_', '47918-4'],
      ['406', 'b', 'j', '1983'],
    ],
    {
      record => [
        ['406', 'a', j => '1990', k => '2000']
      ]
    }
);

foreach my $record (@mab_records) {
    $writer->write($record);
}

# ToDo: Catmandu::Exporter::MAB2::commit
$writer->end();

close($fh);

my $out = do { local (@ARGV,$/)=$filename; <> };

is $out, <<'MABXML';
<?xml version="1.0" encoding="UTF-8"?>
<datei xmlns="http://www.ddb.de/professionell/mabxml/mabxml-1.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ddb.de/professionell/mabxml/mabxml-1.xsd http://www.d-nb.de/standardisierung/formate/mabxml-1.xsd">
<datensatz typ="h" status="n" mabVersion="M2.0">
<feld nr="001" ind=" ">47918-4</feld>
<feld nr="406" ind="b">
    <uf code="j">1983</uf>
</feld>
</datensatz>
<datensatz typ="h" status="n" mabVersion="M2.0">
<feld nr="406" ind="a">
    <uf code="j">1990</uf>
    <uf code="k">2000</uf>
</feld>
</datensatz>
</datei>
MABXML

($fh, $filename) = tempfile();
$writer = MAB2::Writer::RAW->new( fh => $fh );

foreach my $record (@mab_records) {
    $writer->write($record);
}

close($fh);

$out = do { local (@ARGV,$/)=$filename; <> };

is $out, <<'MABRAW';
99999nM2.01200024      h001 47918-4406bj1983
99999nM2.01200024      h406aj1990k2000
MABRAW

($fh, $filename) = tempfile();

$writer = MAB2::Writer::RAW->new( file => $filename );

foreach my $record (@mab_records) {
    $writer->write($record);
}
$writer->close_fh();

$out = do { local (@ARGV,$/)=$filename; <> };

is $out, <<'MABRAW';
99999nM2.01200024      h001 47918-4406bj1983
99999nM2.01200024      h406aj1990k2000
MABRAW

done_testing;
