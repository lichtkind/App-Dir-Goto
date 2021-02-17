use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parser;

my %command = ('add' => [0, 0, 0, 0], # 0 option 1st arg required
               'del' => 'delete',
            'delete' => [0, 0],
                'rm' => 'remove',
            'remove' => [0, 0],
                'mv' => 'move',
              'move' => [0, 0, 1],
                'cp' => 'copy',
              'copy' => [0, 0, 1],
              'name' => [0, 0, 0],
              'path' => [0, 0, 1],
              'last' => [0],
          'previous' => [0],
              'help' => [3, 0],
              'sort' => [6],
              'list' => [0, 0],
          'list-add' => [0, 1],
          'list-del' => 'list-delete',
       'list-delete' => [0, 1],
         'list-name' => [0, 1, 1],
         'list-list' => [0],
);
my %cmd_argument = ( 'add' => [qw/dir name target/],
                    delete => ['source'],
                    remove => ['source'],
                      move => ['source', 'target'],
                      copy => ['source', 'target'],
                      name => ['source', 'name'],
                      path => ['source', 'dir'],
                      help => ['command'],
                'list-add' => ['name'],
             'list-delete' => ['name'],
               'list-name' => ['name', 'name'],
);
my %cmd_option  = ( list => [qw/add del/],
                    sort => [qw/created dir last_visit position name visits/]
);
my %cmd_shortcut = (  add =>'a',delete =>'d', copy => 'c', move =>'m', remove =>  'r', name =>'n', path => 'p',
                     sort =>'s',  list =>'l', 'last' =>'_', 'previous' => '-' , help =>'h' ,); # undo =>'<', redo =>'>',
my %opt_shortcut = ( sort => { created => 'c', dir => 'd', last_visit => 'l', position => 'p',  name => 'n',  visits => 'v' },
                     help => {                all => 'a',      usage => 'u', commands => 'c', },
);
my (%command_sc, %option_sc);
my $sigil_command  = '-';
my $sigil_option   = '=';
my $sigil_name     = ':';
my $sigil_position = '#';
my $sigil_enty     = '*';

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

sub is_name {
    my ($name) = @_;

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
path [<ID>] > <dir>
