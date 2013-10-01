use strict;
use warnings;
use Test::More;

use MAB2::Parser::XML;
my $parser = MAB2::Parser::XML->new( './t/mab2.xml' );
isa_ok( $parser, 'MAB2::Parser::XML' );
my $record = $parser->next();
ok($record->{_id} eq '47918-4', 'record _id' );
is_deeply($record->{record}->[0], ['001', ' ', '_', '47918-4'], 'first field');
ok($parser->next()->{_id} eq '54251-9', 'next record');

use MAB2::Parser::RAW;
$parser = MAB2::Parser::RAW->new( './t/mab2.dat' );
isa_ok( $parser, 'MAB2::Parser::RAW' );
$record = $parser->next();
ok($record->{_id} eq '47918-4', 'record _id' );
ok($record->{record}->[0][3] eq '02020nM2.01200024      h', 'record leader' );
is_deeply($record->{record}->[1], ['001', ' ', '_', '47918-4'], 'first field');
ok($parser->next()->{_id} eq '54251-9', 'next record');

done_testing();
