#!/usr/bin/perl -w
use v5.20;
use warnings;
use Test::More tests => 11;

BEGIN { unshift @INC, 'lib', '../lib', '.', 't'}
use App::Goto::Dir::Data::Entry;
my $class = 'App::Goto::Dir::Data::Entry';

my $nameless = App::Goto::Dir::Data::Entry->new('dir');
is(ref $nameless, $class,           'created first simple entry');
is($nameless->get_dir, 'dir',       'got back directory');
is($nameless->get_name, '',         'got back name');

my $clone = $nameless->clone();
is(ref $clone, $class,              'clone has right class');
ok($nameless ne $clone,             'clone has different ref');
is($clone->get_dir, 'dir',          'clone has right directory');

my $named = App::Goto::Dir::Data::Entry->new($ENV{'HOME'}.'/dir', 'name');
is(ref $named, $class,              'created named entry');
is($named->get_dir, '~/dir',        'got back compact directory');
is($named->get_full_dir, $ENV{'HOME'}.'/dir', 'got back expanded directory');
is($named->get_name, 'name',        'got back name');
is($named->clone->get_name, 'name', 'got back name from clone');
