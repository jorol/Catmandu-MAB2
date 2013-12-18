package MAB2::Writer::Disk;

#ABSTRACT: MAB2 Diskette format serializer
#VERSION

use strict;
use Moo;
with 'MAB2::Writer::Handle';

use charnames ':full';
use Readonly;

Readonly my $SUBFIELD_INDICATOR => qq{\N{INFORMATION SEPARATOR ONE}};
Readonly my $END_OF_FIELD       => qq{\n};
Readonly my $END_OF_RECORD      => qq{\n};

=head1 SYNOPSIS

L<MAB2::Writer::Disk> is a MAB2 Diskette serializer.

    use MAB2::Writer::Disk;

    my @mab_records = (

        [
          ['001', ' ', '_', '2415107-5'],
          ['331', ' ', '_', 'Code4Lib journal'],
          ['655', 'e', 'u', 'http://journal.code4lib.org/', 'z', 'kostenfrei'],
          ...
        ],
        {
          record => [
              ['001', ' ', '_', '2415107-5'],
              ['331', ' ', '_', 'Code4Lib journal'],
              ['655', 'e', 'u', 'http://journal.code4lib.org/', 'z', 'kostenfrei'],
              ...
          ]
        }
    );

    $writer = MAB2::Writer::Disk->new( fh => $fh );

    foreach my $record (@mab_records) {
        $writer->write($record);
    }

=head1 SUBROUTINES/METHODS

=head2 new()

=cut

sub BUILD {
    my ($self) = @_;
}

=head2 _write_record()

=cut

sub _write_record {
    my ( $self, $record ) = @_;
    my $fh = $self->fh;

    if ( $record->[0][0] eq 'LDR' ) {
        my $leader = shift( @{$record} );
        print $fh "### ", $leader->[3], $END_OF_FIELD;
    }
    else {
        # set default record leader
        print $fh "### 99999nM2.01200024      h", $END_OF_FIELD;
    }

    foreach my $field (@$record) {

        if ( $field->[2] eq '_' ) {
            print $fh $field->[0], $field->[1], $field->[3], $END_OF_FIELD;
        }
        else {
            print $fh $field->[0], $field->[1];
            for ( my $i = 2; $i < scalar @$field; $i += 2 ) {
                my $subfield_code = $field->[ $i ];
                my $value = $field->[ $i + 1 ];
                print $fh $SUBFIELD_INDICATOR, $subfield_code, $value;
            }
            print $fh $END_OF_FIELD;
        }
    }
    print $fh $END_OF_RECORD;
}

1;