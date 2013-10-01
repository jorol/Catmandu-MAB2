Catmandu::MAB2 - Catmandu modules for working with MAB2 data.

# Installation

Install the latest distribution from CPAN:

    cpanm Catmandu::MAB2

Install the latest developer version from GitHub:

    cpanm git@github.com:jorol/Catmandu-MAB2.git@devel

# Contribution

For bug reports and feature requests use <https://github.com/jorol/Catmandu-MAB2/issues>.

For contributions to the source code create a fork or use the `devel` branch. The master
branch should only contain merged and stashed changes to appear in Changelog.

Dist::Zilla and build requirements can be installed this way:

    cpan Dist::Zilla
    dzil authordeps | cpanm

Build and test your current state this way:

    dzil build
    dzil test 
    dzil smoke --release --author # test more


