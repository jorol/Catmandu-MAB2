package MAB2::Writer::XML;

#ABSTRACT: MAB2 XML format serializer
#VERSION

# ToDo: xml_escape

use strict;
use Moo;
with 'MAB2::Writer::Handle';

sub BUILD {
    my ($self) = @_;
}

sub start {
    my ($self) = @_;

    print { $self->fh } "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print { $self->fh }
        "<datei xmlns=\"http://www.ddb.de/professionell/mabxml/mabxml-1.xsd\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.ddb.de/professionell/mabxml/mabxml-1.xsd http://www.d-nb.de/standardisierung/formate/mabxml-1.xsd\">\n";
}

sub _write_record {
    my ( $self, $record ) = @_;
    my $fh = $self->fh;

    if ( $record->[0][0] eq 'LDR' ) {
        my $leader = shift( @{$record} );
        my ( $status, $typ ) = ( $1, $2 )
            if $leader->[3] =~ /^\d{5}(\w)M2\.0\d*\s*(\w)$/;
        print $fh
            "<datensatz typ=\"$typ\" status=\"$status\" mabVersion=\"M2.0\">\n";
    }
    else {
        # default to typ and status
        print $fh "<datensatz typ=\"h\" status=\"n\" mabVersion=\"M2.0\">\n";
    }

    foreach my $field (@$record) {

        if ( $field->[2] eq '_' ) {
            print $fh
                "<feld nr=\"$field->[0]\" ind=\"$field->[1]\">$field->[3]</feld>\n";
        }
        else {
            print $fh "<feld nr=\"$field->[0]\" ind=\"$field->[1]\">\n";
            for ( my $i = 2; $i < scalar @$field; $i += 2 ) {
                my $value = $field->[ $i + 1 ];
                print $fh "    <uf code=\"$field->[$i]\">$value</uf>\n";
            }
            print $fh "</feld>\n";
        }
    }
    print $fh "</datensatz>\n";
}

sub end {
    my ($self) = @_;

    print { $self->fh } "</datei>\n";
}

1;
