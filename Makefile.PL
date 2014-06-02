use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Catmandu modules for working with MAB2 data.",
  "AUTHOR" => "Johann Rolschewski <rolschewski\@gmail.com>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Catmandu-MAB2",
  "EXE_FILES" => [
    "bin/mab2_convert.pl"
  ],
  "LICENSE" => "perl",
  "NAME" => "Catmandu::MAB2",
  "PREREQ_PM" => {
    "Catmandu" => "0.9103",
    "Catmandu::SRU" => "0.032",
    "Encode" => "2.5",
    "Moo" => "1.0",
    "Readonly" => "1.0",
    "XML::LibXML::Reader" => "2.0"
  },
  "VERSION" => "0.07",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Catmandu" => "0.9103",
  "Catmandu::SRU" => "0.032",
  "Encode" => "2.5",
  "Moo" => "1.0",
  "Readonly" => "1.0",
  "XML::LibXML::Reader" => "2.0"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



