package MAB2::Writer::RAW;

#ABSTRACT: MAB2 RAW format serializer
#VERSION

use strict;
use Moo;
with 'MAB2::Writer::Handle';

use charnames ':full';
use Readonly;
Readonly my $SUBFIELD_INDICATOR => qq{\N{INFORMATION SEPARATOR ONE}};
Readonly my $END_OF_FIELD       => qq{\N{INFORMATION SEPARATOR TWO}};
Readonly my $END_OF_RECORD      => qq{\N{INFORMATION SEPARATOR THREE}};

sub BUILD {
    my ($self) = @_;
}

sub _write_record {
    my ( $self, $record ) = @_;
    my $fh = $self->fh;

    if ( $record->[0][0] eq 'LDR' ) {
        my $leader = shift( @{$record} );
        print $fh "$leader";
    }
    else {
        # set default record leader
        print $fh "99999nM2.01200024      h";
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
    print $fh $END_OF_RECORD,"\n";
}

1;
