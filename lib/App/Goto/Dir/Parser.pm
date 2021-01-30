use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parser;

my %alias = ( rem => 'remove', del => 'delete', );


my %cmd_shortcut = (add =>'a', delete =>'d', copy => 'c', move =>'m', remove =>  'r', name =>'n', bend => 'b',
                   sort =>'s', list =>'l', undo =>'<', redo =>'>', 'goto-last' =>'_', 'goto-previous' => '-', help =>'h');

my %so_shortcut = ( created => 'c',   dir => 'd',  last_visit => 'l', position => 'p',  name => 'n',  visits => 'v',     default => 'position',);

my (%command_sc, %search_option_sc);

# - : ,
sub init {
    my ($config)  = @_;
    %cmd_shortcut  = %{ $config->{'syntax'}{'command_shortcut'}};
    %command_sc     = map { $_ => $command{$_} } values %cmd_shortcut;
    %so_shortcut     = %{ $config->{'syntax'}{'search_option'}};
    %search_option_sc = map { $_ => $search_option{$_} } grep {$_ ne 'position'} values %so_shortcut;

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
    bend : b
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
