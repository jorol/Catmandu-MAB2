package Catmandu::Exporter::MAB2;

#ABSTRACT: Package that exports MAB2 data
#VERSION

use Catmandu::Sane;
use MAB2::Writer::Disk;
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
    elsif ( $type eq 'disk' ) {
        MAB2::Writer::Disk->new( fh => $self->fh );
    }
    elsif ( $type eq 'xml' ) {
        MAB2::Writer::XML->new(
            fh              => $self->fh,
            xml_declaration => $self->xml_declaration,
            collection      => $self->collection
        );
    }
    else {
        die "unknown type: $type";
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
 
=head1 Arguments

=over

=item C<file>

Path to file with MAB2 records.

=item C<fh>

Open filehandle for file with MAB2 records.

=item C<type>

Specify type of MAB2 records: Disk (Diskette), RAW (Band), XML. Default: 001. Optional. 

=item C<xml_declaration>

Write XML declaration. Set to 0 or 1. Default: 0. Optional.

=item C<collection>

Wrap records in collection element (<datei>). Set to 0 or 1. Default: 0. Optional.

=back 

=head1 METHODS
 
=head2 new(file => $file | fh => $filehandle [, type => XML, xml-declaration => 1, collection => 1])
 
Create a new Catmandu MAB2 exports which serializes into a $file.
 
=head2 add($data)

Add record to exporter. 

=head2 commit()

Close collection (optional) and filehandle.

=head1 SEE ALSO

L<Catmandu::Exporter>, L<Catmandu::Iterable>.

=cut

1;
