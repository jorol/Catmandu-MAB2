package MAB2::Writer::Handle;

# ABSTRACT: Utility class that implements a file and filehandle attribute to write to
# VERSION

use strict;
use Moo::Role;
use Carp qw(croak);
use Encode qw(find_encoding);
use Scalar::Util qw(blessed openhandle);

has encoding => (
    is  => 'rw',
    isa => sub {
        find_encoding($_[0]) or croak "encoding \"$_[0]\" is not a valid encoding";
    },
    default => sub { 'UTF-8' },
);

has file => (
    is  => 'rw',
    isa => sub {
        croak 'expect file!' unless defined $_[0];
    },
    trigger => \&_set_fh,
);

has fh => (
    is  => 'rw',
    isa => sub {
        my $ishandle = eval { fileno( $_[0] ); };
        croak 'expect filehandle or object with method print!'
            unless !$@ and defined $ishandle
            or ( blessed $_[0] && $_[0]->can('print') );
    },
    default => sub { \*STDOUT }
);

has subfield_indicator => (
    is  => 'rw',
    default => sub { qq{\N{INFORMATION SEPARATOR ONE}} }
);

sub _set_fh {
    my ($self) = @_;

    my $encoding = $self->encoding;
    open my $fh, ">:encoding($encoding)", $self->file
        or croak 'could not open file!';
    $self->fh($fh);
}

sub close_fh {
    my ($self) = @_;

    close $self->{fh};
}

sub write {
    my $self = shift;
    my $fh   = $self->fh;

    foreach my $record (@_) {
        $record = $record->{record} if ref $record eq 'HASH';
        $self->_write_record($record);
    }
}

1;
