use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parser;

my %cmd_shortcut = (add =>'a', delete =>'d', copy => 'c', move =>'m', remove =>  'r', name =>'n', bend => 'b',
                   sort =>'s', list =>'l', 'goto-last' =>'_', 'goto-previous' => '-', help =>'h'); # undo =>'<', redo =>'>',
my %cmd_alias    = ( rem => 'remove', del => 'delete', );
my %cmd_compund  = (  list => [qw/add del/], sort => [qw/created dir last_visit position name visits/] );

my %arg_shortcut = ( sort => {created => 'c', dir => 'd', last_visit => 'l', position => 'p',  name => 'n',  visits => 'v' });

my (%command_sc, %search_option_sc);

# - : ,
sub init {
    my ($config)  = @_;
    %cmd_shortcut  = %{ $config->{'syntax'}{'command_shortcut'}};
    %command_sc     = map { $_ => $cmd_shortcut{$_} } values %cmd_shortcut;
    %so_shortcut     = %{ $config->{'syntax'}{'search_option'}};
    %search_option_sc = map { $_ => $so_shortcut{$_} } grep {$_ ne 'position'} values %so_shortcut;

}

sub eval_commandy {
    my (@parts) = @_;
    my @cmd = split  "-", join ' ', @parts;
# check with names
# when yes check compunt
# when no check shortcut
# check for goto <ID>

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


