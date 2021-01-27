use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parser;

my %command = (add =>'a', delete =>'d', name =>'n', move =>'m', remove =>  'r', sort =>'s',
              list =>'l', undo =>'<', redo =>'>', last =>'_', back => '-', help =>'h');

# - : >
sub eval_command {
    my ($string) = @_;

}

1;
