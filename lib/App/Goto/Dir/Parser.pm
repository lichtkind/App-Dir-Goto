use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parser;

my %cmd_shortcut = (add =>'a', delete =>'d', copy => 'c', move =>'m', remove =>  'r', name =>'n', path => 'p',
                   sort =>'s', list =>'l', 'goto-last' =>'_', 'goto-previous' => '-', help =>'h'); # undo =>'<', redo =>'>',
my %cmd_alias    = ( rem => 'remove', del => 'delete', );
my %cmd_compund  = (  list => [qw/add del/], sort => [qw/created dir last_visit position name visits/] );

my %opt_shortcut = ( sort => {created => 'c', dir => 'd', last_visit => 'l', position => 'p',  name => 'n',  visits => 'v' },
                     help => {                all => 'a',      usage => 'u', commands => 'c', },
);
my (%command_sc, %option_sc);

my @command = (qw/add del delete rem remove move copy name bend help goto-last goto-previous list-add list-del list-name list-lists/);
say for @command;

# - : ,
sub init {
    my ($config)  = @_;
    %cmd_shortcut  = %{ $config->{'syntax'}{'command_shortcut'}};
    %command_sc     = map { $cmd_shortcut{$_} => $_ } keys %cmd_shortcut;
    %opt_shortcut     = %{ $config->{'syntax'}{'option_shortcut'}};
# insert default
    for my $opt (keys %opt_shortcut){
        $option_sc{$opt} = { map { $opt_shortcut{$opt}{$_} => $_ } keys %{$opt_shortcut{$opt}} };
    }

}

sub eval_command {
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

add <dir>[:<name>] [> <lpos>]
del[ete] [<ID>]
rem[ove] [<ID>]
move [<IDa>] > <IDb>
copy [<IDa>] > <IDb>
name [<ID>] :<name>
name [<ID>]
bend [<ID>] > <dir>
