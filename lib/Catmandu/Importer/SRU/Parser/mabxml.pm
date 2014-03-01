package Catmandu::Importer::SRU::Parser::mabxml;

use Moo;
use MAB2::Parser::XML;
use Encode;

sub parse {
    my ( $self, $record ) = @_;

    my $xml = $record->{recordData};
    my $parser = MAB2::Parser::XML->new( $xml ); 
    my $record_hash = $parser->next();

    return $record_hash;
}

=head1 NAME

  Catmandu::Importer::SRU::Parser::mabxml - Package transforms SRU responses into Catmandu MAB2 

=head1 SYNOPSIS

my %attrs = (
    base => 'http://sru.gbv.de/gvk',
    query => '1940-5758',
    recordSchema => 'mabxml' ,
    parser => 'mabxml' ,
);

my $importer = Catmandu::Importer::SRU->new(%attrs);

=head1 DESCRIPTION

Each mabxml response will be transformed into an format as defined by L<Catmandu::Importer::PICA>

=cut

1;
