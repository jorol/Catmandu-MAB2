package Catmandu::Exporter::MAB2;

#ABSTRACT: Package that exports MAB2 data
#VERSION

use Catmandu::Sane;
use MAB2::Writer::RAW;
use MAB2::Writer::XML;
use Moo;

with 'Catmandu::Exporter';

has type            => ( is => 'ro', default => sub {'raw'} );
has xml_declaration => ( is => 'ro', default => sub {0} );
has collection      => ( is => 'ro', default => sub {0} );
has writer          => ( is => 'lazy' );

sub _build_writer {
    my ($self) = @_;

    my $type = lc( $self->{type} );
    if ( $type eq 'raw' ) {
        MAB2::Writer::RAW->new( fh => $self->fh );
    }
    elsif ( $type eq 'xml' ) {
        MAB2::Writer::XML->new(
            fh              => $self->fh,
            xml_declaration => $self->xml_declaration,
            collection      => $self->collection
        );
    }
    else {
        croak("unknown type: $type");
    }
}

sub add {
    my ( $self, $data ) = @_;

    if ( !$self->count ) {
        if ( lc( $self->type ) eq 'xml' ) {
            $self->writer->start();
        }
    }

    $self->writer->write($data);

}

sub commit {
    my ($self) = @_;
    if ( $self->collection ) {
        $self->writer->end();
    }
    $self->writer->close_fh();

}

=head1 NAME

Catmandu::Exporter::MAB2 - serialize parsed MAB2 data
 
=head1 SYNOPSIS
 
    use Catmandu::Exporter::MAB2;
 
    my $exporter = Catmandu::Exporter::MAB2->new(file => "mab2.dat", type => "RAW");
    my $data = {
     record => [
        ...
        [245, '1', 'a', 'Cross-platform Perl /', 'c', 'Eric F. Johnson.'],
        ...
        ],
    };
 
    $exporter->add($data);
    $exporter->commit;
 
 
=head1 METHODS
 
=head2 new(file => $file, %options)
 
Create a new Catmandu MAB2 exports which serializes into a $file. Optionally
provide xml_declaration => 0|1 to in/exclude a XML declaration and, collection => 0|1
to include a MAB2 collection header.
 
=cut

1;
