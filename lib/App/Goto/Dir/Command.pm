use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use File::Spec;


package App::Goto::Dir::Command;

my $data;
my $config;

sub init { ($config, $data) = @_ }

sub run {
   my ($cmd, @arg) = @_;
   if ($cmd eq '--help'){
       say App::Goto::Dir::Help::text($config, $arg[0]);
   } elsif ($cmd eq '--list-lists'){

   } elsif ($cmd eq '--list-special'){

   } else {

   }
}


1;
