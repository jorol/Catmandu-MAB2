package Catmandu::Importer::SRU::Parser::mabxml;

#ABSTRACT: Package transforms SRU responses into Catmandu MAB2
#VERSION

use Moo;
use MAB2::Parser::XML;
use Encode;

sub parse {
    my ( $self, $record ) = @_;

    my $xml = $record->{recordData};
    my $parser = MAB2::Parser::XML->new( $xml ); 
    return $parser->next();
}

=head1 SYNOPSIS

    my %attrs = (
        base => 'http://sru.gbv.de/gvk',
        query => '1940-5758',
        recordSchema => 'mabxml' ,
        parser => 'mabxml' ,
    );

    my $importer = Catmandu::Importer::SRU->new(%attrs);

=head1 DESCRIPTION

Each mabxml response will be transformed into the format defined by 
L<Catmandu::Importer::PICA>

=cut

1;
