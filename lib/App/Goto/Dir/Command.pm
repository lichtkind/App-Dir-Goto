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
   if ($cmd eq '--help'){ say App::Goto::Dir::Help::text($config, $arg[0]) }
     elsif ($cmd eq '--sort'){
   } elsif ($cmd eq '--list'){
   } elsif ($cmd eq '--list-special'){
   } elsif ($cmd eq '--list-lists'){ App::Goto::Dir::Formater::lists( $config, $data ) }
     elsif ($cmd eq '--list-add'){
   } elsif ($cmd eq '--list-delete'){
   } elsif ($cmd eq '--list-name'){
   } elsif ($cmd eq '--list-description'){
   } elsif ($cmd eq '--add'){
   } elsif ($cmd eq '--delete'){
   } elsif ($cmd eq '--remove'){
   } elsif ($cmd eq '--move'){
   } elsif ($cmd eq '--copy'){
   } elsif ($cmd eq '--dir'){
   } elsif ($cmd eq '--name'){
   } elsif ($cmd eq '--edit'){
   } else {
      # goto dir
   }
}


1;
