package MAB2::Parser::Disk;

# ABSTRACT: MAB2 RAW format parser
# VERSION

use strict;
use warnings;
use charnames qw< :full >;
use Carp qw(croak);
use Readonly;

Readonly my $END_OF_FIELD       => qq{\n};
Readonly my $END_OF_RECORD      => q{};

=head1 SYNOPSIS

L<MAB2::Parser::Disk> is a parser for MAB2-Diskette records.

L<MAB2::Parser::Disk> expects UTF-8 encoded files as input. Otherwise provide a 
filehande with a specified I/O layer.

Catmandu...

    use MAB2::Parser::Disk;

    my $parser = MAB2::Parser::Disk->new( $filename );

    while ( my $record_hash = $parser->next() ) {
        # do something        
    }

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
        filename   => undef,
        rec_number => 0,
        reader     => undef,
    };

    # check for file or filehandle
    my $ishandle = eval { fileno($file); };
    if ( !$@ && defined $ishandle ) {
        $self->{filename} = scalar $file;
        $self->{reader}   = $file;
    }
    elsif ( -e $file ) {
        open $self->{reader}, '<:encoding(UTF-8)', $file
            or croak "cannot read from file $file\n";
        $self->{filename} = $file;
    }
    else {
        croak "file or filehande $file does not exists";
    }
    return ( bless $self, $class );
}

=head2 next()

Reads the next record from MAB2 Diskette input stream. Returns a Perl hash.

=cut

sub next {
    my $self = shift;
    local $/ = $END_OF_RECORD;
    if ( my $data = $self->{reader}->getline() ) {
        $self->{rec_number}++;
        my $record = _decode($data);

        # get last subfield from 001 as id
        my ($id) = map { $_->[-1] } grep { $_->[0] =~ '001' } @{$record};
        return { _id => $id, record => $record };
    }
    return;
}

=head2 _decode()

Deserialize a MAB2 Diskette record to an array of field arrays.

=cut

sub _decode {
    my $reader = shift;
    chomp($reader);

    my @record;

    my @fields = split($END_OF_FIELD, $reader);

    my $leader = shift @fields;
    if( $leader =~ m/^\N{NUMBER SIGN}{3}\s(\d{5}[cdnpu]M2.0\d{7}\s{6}\w)/xms ){
        push( @record, [ 'LDR', '', '_', $1 ] );
    }
    else{
        croak "record leader not valid: $leader";
    }

    # ToDo: skip faulty fields
    foreach my $field (@fields) {
        croak "incomplete field: \"$field\"" if length($field) <= 4;
        my $tag = substr( $field, 0, 3 );
        my $ind = substr( $field, 3, 1 );
        my $data = substr( $field, 4 );

        # check for a 3-digit numeric tag
        ( $tag =~ m/^[0-9]{3}$/xms ) or croak "Invalid tag: \"$tag\"";

        # check if indicator is an single alphabetic character
        ( $ind =~ m/^[a-z\s]$/xms ) or croak "Invalid indicator: \"$ind\"";

        # check if data contains subfield indicators
        if ( $data =~ m/^\s*(\N{INFORMATION SEPARATOR ONE}|\$)(.*)/ ) {
            my $subfield_indicator = $1;
            my @subfields = split( $subfield_indicator, $2 );
            ( @subfields ) or croak "no subfield data found: \"$tag$ind$data\"";
            push(
                @record,
                [   $tag,
                    $ind,
                    map { substr( $_, 0, 1 ), substr( $_, 1 ) } @subfields
                ]
            );
        }
        else {
            push( @record, [ $tag, $ind, '_', $data ] );
        }
    }
    return \@record;    
}

=cut

1;    # End of MAB2::Parser::Disk
