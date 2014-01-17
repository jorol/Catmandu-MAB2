package Catmandu::Importer::MAB2;

# ABSTRACT: Package that imports MAB2 data
# VERSION

use Catmandu::Sane;
use Moo;
use MAB2::Parser::Disk;
use MAB2::Parser::RAW;
use MAB2::Parser::XML;

with 'Catmandu::Importer';

has type => ( is => 'ro', default => sub {'RAW'} );
has id   => ( is => 'ro', default => sub {'001'} );

sub mab_generator {
    my $self = shift;

    my $file;
    my $type = lc($self->type);
    if ( $type eq 'raw' ) {
        $file = MAB2::Parser::RAW->new( $self->fh );
    }
    elsif ( $type eq 'xml' ) {
        $file = MAB2::Parser::XML->new( $self->fh );
    }
    elsif ( $type eq 'disk' ) {
        $file = MAB2::Parser::Disk->new( $self->fh );
    }
    else {
        die "unknown format";
    }

    my $id = $self->id;

    sub {
        my $record = $file->next();
        return unless $record;
        return $record;
    };
}

sub generator {
    my ($self) = @_;
    
    my $type = lc($self->type);
    if ( $type =~ /raw|xml|disk$/ ) {
        return $self->mab_generator;
    }
    else {
        die "need MAB2 RAW or XML data";
    }
}

=head1 NAME

Catmandu::Importer::MAB2 - Package that imports MAB2 data

=head1 SYNOPSIS

    use Catmandu::Importer::MAB2;

    my $importer = Catmandu::Importer::MAB2->new(file => "./t/mab2.dat", type=> "RAW");

    my $n = $importer->each(sub {
        my $hashref = $_[0];
        # ...
    });

=head1 Arguments

=over

=item C<file>

Path to file with MAB2 records.

=item C<fh>

Open filehandle for file with MAB2 records.

=item C<id>

Specify MAB2 field tag to get record identifier from. Default: 001. Optional.

=item C<type>

Specify type of MAB2 records: Disk (Diskette), RAW (Band), XML. Default: RAW. Optional. 

=back

=head1 MAB2

The parsed MAB2 record is a HASH containing two keys '_id' containing the 001 field (or the system
identifier of the record) and 'record' containing an ARRAY of ARRAYs for every field:

 {
  'record' => [
                [
                    '001',
                    ' ',
                    '_',
                    'fol05882032 '
                ],
                [
                    245,
                    'a',
                    'a',
                    'Cross-platform Perl /',
                    'c',
                    'Eric F. Johnson.'
                ],
        ],
  '_id' => 'fol05882032'
 } 

=head1 METHODS

=head2 new(file => $filename | fh => $filehandle [,type => $type, id => $field_tag])

Create a new MAB2 importer for $filename. Use STDIN when no filename is given. 

=head2 count

=head2 each(&callback)

=head2 ...

Every Catmandu::Importer is a Catmandu::Iterable all its methods are inherited. The
Catmandu::Importer::MAB methods are not idempotent: MAB feeds can only be read once.

=head1 SEE ALSO

L<Catmandu::Importer>, L<Catmandu::Iterable>;

=cut

1;
