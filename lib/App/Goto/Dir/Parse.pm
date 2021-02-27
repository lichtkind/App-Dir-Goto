use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parse;

my ($config, $sig);
my %command = ('add' => [0, 0, 0, 0, 0], # i: 0 - option ; 1..n - arg required?
               'del' => 'delete',
            'delete' => [0, 0],
             'undel' => 'undelete',
          'undelete' => [0, 0],
                'rm' => 'remove',
               'rem' => 'remove',
            'remove' => [0, 0],
                'mv' => 'move',
              'move' => [0, 0, 1],
                'cp' => 'copy',
              'copy' => [0, 0, 1],
              'name' => [0, 0, 0],
               'dir' => [0, 0, 1],
             'redir' => [0, 1, 1],
              'last' => [0],
          'previous' => [0],
              'help' => [3, 0],
              'sort' => [6],
              'list' => [0, 0],
          'list-add' => [0, 1],
          'list-del' => 'list-delete',
       'list-delete' => [0, 1],
         'list-name' => [0, 1, 1],
        'list-descr' => 'list-description',
  'list-description' => [0, 1, 1],
        'list-lists' => [0],
);
my %cmd_argument = ( 'add' => [qw/dir name list entry/],
                    delete => ['list', 'entry'],
                  undelete => ['source', 'target'],
                    remove => ['source'],
                      move => ['source', 'target'],
                      copy => ['source', 'target'],
                      name => ['source', 'name'],
                       dir => ['source', 'dir'],
                     redir => ['dir', '>>', 'dir'],
                    script => ['source', 'text'],
                      help => ['command'],
                'list-add' => ['name'],
             'list-delete' => ['name'],
               'list-name' => ['name', 'name'],
        'list-description' => ['name', 'text'],
);
my %cmd_option  = ( list => [qw/add del/],
                    sort => [qw/created dir last_visit position name visits/]
);
my %cmd_shortcut = (  add =>'a', delete =>'d', undelete =>'u',   copy =>'c', move =>'m', remove =>  'r',
                     name =>'N',    dir =>'D',     edir =>'R', script =>'S',
                     'list-add' =>'l-a', 'list-delete' =>'l-d', 'list-lists' =>'l-l', 'list-special' =>'l-s',
                     'list-name' =>'l-N', 'list-description' =>'l-D',
                     sort =>'s',  list =>'l', 'last' =>'_', 'previous' => '-' , help =>'h' ,
                   ); # undo =>'<', redo =>'>',
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
    ($config)  = @_;
    %cmd_shortcut  = %{ $config->{'syntax'}{'command_shortcut'}};
    %command_sc     = map { $cmd_shortcut{$_} => $_ } keys %cmd_shortcut;
    %opt_shortcut     = %{ $config->{'syntax'}{'option_shortcut'}};
# insert default
    for my $opt (keys %opt_shortcut){
        $option_sc{$opt} = { map { $opt_shortcut{$opt}{$_} => $_ } keys %{$opt_shortcut{$opt}} };
    }
    $sig = { map {$_ => quotemeta $config->{'syntax'}{'sigil'}{$_}} keys %{$config->{'syntax'}{'sigil'}}};
}

sub is_dir {
    my ($dir) = @_;
    return 0 unless defined $dir and $dir;
    substr($dir, 0, 1) =~ m|[/\\~]|;
}
sub is_name {
    my ($name) = @_;
    return 0 unless defined $name and $name;
    return 0 if $name =~ /\W/;
    return 0 if substr($name,0,1) =~ /[\d_]/;
    1;
}
sub is_position { defined $_[0] and $_[0] =~ /-?+\d/ }

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

<pos>        = -?\d+
<name>       = [a-zA-Z]\w*
<dir>        = [/\~][^$sig->{target_entry}$sig->{entry_name} ]*
<text>       = '.*(?<!\\)'

<list_name>  = $sig->{special_list}?<name>
<special>    = $sig->{special_entry}<name>
<entry_name> = (<list_name>?$sig->{entry_name})?<name>
<entry_pos>  = (<list_name>?$sig->{entry_position})?<pos>
<entry>      = (<special>|<entry_name>|<entry_pos>)?
<source>     = <entry>|(<list_name>?$sig->{entry_position})?<pos>?..<pos>?
<target>     = <entry>
<path>       = <entry><dir>

                                    command => '-',
                                 entry_name => ':',
                                       help => '?',
                             entry_position => '^',
                               target_entry => '>',
                              special_entry => '+',
                               special_list => '@',


  -h --help[=b|c|i|s| <command>]     topic or command specific help texts
  -s --sort=D|S|c|l|n|p|v            set sorting criterion of list display
  -l  --list [<listname>]            change current list and display it
  -l-s --list-special                display all special entries
  -l-l --list-lists                  display available list names
  -l-a --list-add <name> ? <Desc.>   create a new list
  -l-d --list-del[ete] <name>        delete list with <listname> (has to be empty)
  -l-N --list-name <name>:<newname>  rename list, conflicts not allowed
  -l-D --list-description <name>?<D> change list description
  -a --add <dir>[:<name>] [> <ID>]   add directory <dir> under <name> to a list
  -d --del[ete] [<ID>]               delete dir entries from all regular lists
  -u --undel[ete] [<ID>]             undelete dir entries from bin
  -r --rem[ove] [<ID>]               remove dir entries from a chosen lists
  -m --move [<IDa>] > <IDb>          move dir entry <IDa> to (position of) <IDb>
  -c --copy [<IDa>] > <IDb>          copy entry <IDa> to (position of) <IDb>
  -D --dir [<ID>] <dir>              change directory of one entry
  -R --redir <old_dir> >> <newdir>   change root directory of more entries
  -N --name [<ID>] [:<name>]         (re-, un-) name entry
  -S --script [<ID>] '<code>'        edit project landing script


$fmt1 = '(?<y>\d\d\d\d)-(?<m>\d\d)-(?<d>\d\d)';
$fmt2 = '(?<m>\d\d)/(?<d>\d\d)/(?<y>\d\d\d\d)';
$fmt3 = '(?<d>\d\d)\.(?<m>\d\d)\.(?<y>\d\d\d\d)';
for my $d (qw(2006-10-21 15.01.2007 10/31/2005)) {
    if ( $d =~ m{$fmt1|$fmt2|$fmt3} ){
        print "day=$+{d} month=$+{m} year=$+{y}\n";
    }
}
