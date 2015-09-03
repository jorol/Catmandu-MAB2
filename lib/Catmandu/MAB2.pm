package Catmandu::MAB2;

#ABSTRACT: Catmandu modules for working with MAB2 data.

our $VERSION = 0.07;

use strict;
use warnings;

=head1 DESCRIPTION
 
Catmandu::MAB2 provides methods to work with MAB2 data within the L<Catmandu>
framework. See L<Catmandu::Introduction> and L<http://librecat.org/> for an
introduction into Catmandu.

=head1 CATMANDU MODULES

=over

=item * L<Catmandu::Importer::MAB2>

=item * L<Catmandu::Exporter::MAB2>

=item * L<Catmandu::Importer::SRU::Parser::mabxml>

=item * L<Catmandu::Fix::mab_map>

=back

=head1 INTERNAL MODULES

Parser and writer for MAB2 data.

=over

=item * L<MAB2::Parser::Disk>

=item * L<MAB2::Parser::RAW>

=item * L<MAB2::Parser::XML>

=item * L<MAB2::Writer::Handle>

=item * L<MAB2::Writer::Disk>

=item * L<MAB2::Writer::RAW>

=item * L<MAB2::Writer::XML>

=back

=cut

1; # End of Catmandu::MAB2
