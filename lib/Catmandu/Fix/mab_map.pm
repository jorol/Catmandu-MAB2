package Catmandu::Fix::mab_map;

# ABSTRACT: copy mab values of one field to a new field
# VERSION

use Catmandu::Sane;
use Catmandu::Util qw(:is :data);
use Data::Dumper;
use Moo;

has path  => ( is => 'ro', required => 1 );
has key   => ( is => 'ro', required => 1 );
has mpath => ( is => 'ro', required => 1 );
has opts  => ( is => 'ro' );

around BUILDARGS => sub {
    my ( $orig, $class, $mpath, $path, %opts ) = @_;
    my ( $p, $key ) = parse_data_path($path) if defined $path && length $path;
    $orig->(
        $class,
        path  => $p,
        key   => $key,
        mpath => $mpath,
        opts  => \%opts
    );
};

sub fix {
    my ( $self, $data ) = @_;

    my $path  = $self->path;
    my $key   = $self->key;
    my $mpath = $self->mpath;
    my $opts  = $self->opts || {};
    $opts->{-join} = '' unless $opts->{-join};

    my $mab_pointer = $opts->{-record} || 'record';
    my $mab = $data->{$mab_pointer};

    my $fields = mab_field( $mab, $mpath );

    return $data if !@{$fields};

    for my $field (@$fields) {
        my $field_value = mab_subfield( $field, $mpath );

        next if is_empty($field_value);

        $field_value = [ $opts->{-value} ] if defined $opts->{-value};
        $field_value = join $opts->{-join}, @$field_value
            if defined $opts->{-join};
        $field_value = create_path( $opts->{-in}, $field_value )
            if defined $opts->{-in};
        $field_value = path_substr( $mpath, $field_value )
            unless index( $mpath, '/' ) == -1;

        my $match
            = [ grep ref, data_at( $path, $data, key => $key, create => 1 ) ]
            ->[0];

        if ( is_array_ref($match) ) {
            if ( is_integer($key) ) {
                $match->[$key] = $field_value;
            }
            else {
                push @{$match}, $field_value;
            }
        }
        else {
            if ( exists $match->{$key} ) {
                $match->{$key} .= $opts->{-join} . $field_value;
            }
            else {
                $match->{$key} = $field_value;
            }
        }
    }
    $data;
}

sub is_empty {
    my ($ref) = shift;
    for (@$ref) {
        return 0 if defined $_;
    }
    return 1;
}

sub path_substr {
    my ( $path, $value ) = @_;
    return $value unless is_string($value);
    if ( $path =~ /\/(\d+)(-(\d+))?/ ) {
        my $from = $1;
        my $to = defined $3 ? $3 - $from + 1 : 0;
        return substr( $value, $from, $to );
    }
    return $value;
}

sub create_path {
    my ( $path, $value ) = @_;
    my ( $p, $key, $guard ) = parse_data_path($path);
    my $leaf  = {};
    my $match = [
        grep ref,
        data_at( $p, $leaf, key => $key, guard => $guard, create => 1 )
    ]->[0];
    $match->{$key} = $value;
    $leaf;
}

# Parse a mab_path into parts
# 245[a]abd  - field=245, ind=a, subfields = a,d,d
# 008/33-35    - field=008 from index 33 to 35
sub parse_mab_path {
    my $path = shift;

    # more than 1 indicator allowed:
    if ( $path =~ /(\S{3})(\[(.+)\])?([_a-z0-9]+)?(\/(\d+)(-(\d+))?)?/ ) {
        my $field    = $1;
        my $ind      = $3;
        my $subfield = $4 ? "[$4]" : "[A-Za-z0-9_]";
        my $from     = $6;
        my $to       = $8;
        return {
            field    => $field,
            ind      => $ind,
            subfield => $subfield,
            from     => $from,
            to       => $to
        };
    }
    else {
        return {};
    }
}

# Given a Catmandu::Importer::MAB item return for each matching field the
# array of subfields
# Usage: mab_field($data,'245');
sub mab_field {
    my ( $mab_item, $path ) = @_;
    my $mab_path = parse_mab_path($path);
    my @results  = ();

    my $field = $mab_path->{field};
    $field =~ s/\*/./g;

    for (@$mab_item) {
        my ( $tag, $ind, @subfields ) = @$_;
        if ( $tag =~ /$field/ ) {
            if ( $mab_path->{ind} ) {
                push( @results, \@subfields ) if $mab_path->{ind} =~ /$ind/;
            }
            else {
                push( @results, \@subfields );
            }

        }
    }
    return \@results;
}

# Given a subarray of Catmandu::Importer::MAB subfields return all
# the subfields that match the $subfield regex
# Usage: mab_subfield($subfields,'[a]');
sub mab_subfield {
    my ( $subfields, $path ) = @_;
    my $mab_path = &parse_mab_path($path);
    my $regex    = $mab_path->{subfield};

    my @results = ();

    for ( my $i = 0; $i < @$subfields; $i += 2 ) {
        my $code = $subfields->[$i];
        my $val  = $subfields->[ $i + 1 ];
        push( @results, $val ) if $code =~ /$regex/;
    }
    return \@results;
}

1;

=head1 SYNOPSIS

    # Copy all 245 subfields into the my.title hash
    mab_map('245','my.title');

    # Copy the 245-$a$b$c subfields into the my.title hash
    mab_map('245abc','my.title');

    # Copy the 100 subfields into the my.authors array
    mab_map('100','my.authors.$append');
    
    # Add the 710 subfields into the my.authors array
    mab_map('710','my.authors.$append');

    # Copy the 600-$x subfields into the my.subjects array while packing each into a genre.text hash
    mab_map('600x','my.subjects.$append', -in => 'genre.text');

    # Copy the 008 characters 35-35 into the my.language hash
    mab_map('008_/35-35','my.language');

    # Copy all the 600 fields into a my.stringy hash joining them by '; '
    mab_map('600','my.stringy', -join => '; ');

    # When 024 field exists create the my.has024 hash with value 'found'
    mab_map('024','my.has024', -value => 'found');

    # Do the same examples now with the fields in 'record2'
    mab_map('245','my.title', -record => 'record2');

=head1 SEE ALSO

L<Catmandu::Fix>, L<Catmandu::Introduction>;

=cut
