requires 'perl', 'v5.10.1';

requires 'Catmandu', '>= 0.94';
requires 'Catmandu::SRU', '>= 0.032';
requires 'Moo', '>= 1.0';
requires 'Readonly', '>= 1.0';
requires 'XML::LibXML::Reader', '>= 2.0';

on 'test', sub {
  requires 'Test::Exception', '0.32';
  requires 'Test::More', '1.001003';
  requires 'Test::Warn', 0;
  requires 'Test::Pod', 0;
  requires 'Software::License','0.103010';
};