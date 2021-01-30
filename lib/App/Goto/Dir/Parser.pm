use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parser;

my %command = (add =>'a', delete =>'d', copy => 'c', move =>'m', remove =>  'r', name =>'n', path => 'p',
              sort =>'s', list =>'l', undo =>'<', redo =>'>', 'goto-last' =>'_', 'goto-previous' => '-', help =>'h');

my %search_option = ( created => 'c',   dir => 'd',  last_visit => 'l',
                      position => 'p',  name => 'n',  visits => 'v',     default => 'position',);

my (%command_sc, %search_option_sc);

# - : ,
sub init {
    my ($config) = @_;
    %command = %{ $config->{'syntax'}{'command_shortcut'}};
    %search_option = %{ $config->{'syntax'}{'search_option'}};
    %command_sc        = map { $_ => $command{$_} } values %command;
    %search_option_sc  = map { $_ => $search_option{$_} } grep {$_ ne 'position'} values %search_option;

}

sub eval_command {
    my (@parts) = @_;

}

sub run_command {

}

1;

__END__

 -add \path
    add: a
    copy: c
    move: m
    remove: r
    delete: d
    name : n
    sort: s
    list: l
    help: h
    'goto-last': '_'
    'goto-previous': '-'
    undo: '<'
    redo: '>'

      search_option:
    created: c
    default: position
    dir: d
    last_visit: l
    position: p
    name: n
    visits: v
