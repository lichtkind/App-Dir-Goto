use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Help;

my %option = ( overview => \&overview,
               basics   => \&basics,
               commands => \&commands,
               install  => \&install,
               settings => \&settings,
);
sub overview { &usage }
sub basics {
    my $config = shift;
    my $us = '-'x length $App::Goto::Dir::VERSION;
    <<EOT;

   General usage of Goto Dir $App::Goto::Dir::VERSION :
  ----------------------------$us

  Command line tool gt (short for goto) changes the working dir like cd,
  to a set of stored locations you don't have to write as a full path.
  These dir's are organized by lists, and can be adressed via their
  list position (<pos>), or with an user given short name (<name>).

  Use 'gt <ID>' to switch dir directly or open the interactive mode via
  'gt' and select the dir then. Both ways you can also administer lists.
  Syntax and output of all commands will be the same and you can write
  several commands in sequence.

  For instance to add \~/code/perl/goto under the name "gg" do either type
  'gt -add \~/code/perl/goto:gg' or open interactive mode via 'gt'
  and write '-add \~/code/perl/goto:gg' there. Then just press <Enter>
  again to exit the interactive mode.

  Every command has a long name and a configurable shortcut.
  It is usually the first letter of the full name.
  Our example : '-a\~/code/perl/goto:gg'.
  Parameters like sorting criteria have shortcuts too.


  For overview of more help topics use --help help or -$config->{syntax}{command_shortcut}{help} $config->{'syntax'}{'command_shortcut'}{'help'}
EOT
}
sub install{ <<EOT,

   How to install App::Goto::Dir :
  -------------------------------

   perl 5.18
   YAML

   goto_dir_config.yml
   places.yml

  In order to makte gt operational, add to the shellrc the following line:
  function gt() { perl ~/../goto.pl \\\$@ cd \$\\(cat ~/../last_choice) }

EOT
}
sub commands {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'};
    my $opt = $config->{'syntax'}{'option_shortcut'};
    my $sopt = join '|', sort values %{$opt->{'sort'}};
    my $hopt = join '|', sort values %{$opt->{'help'}};
    <<EOT;

   Long and short form commands of Goto Dir :
  ------------------------------------------

  --add <dir>[:<name>] [> <lpos>] add directory <dir> under <name> to a list (-$sc->{add})
  --del[ete] [<ID>]               delete dir entry from all lists  (-$sc->{delete})
  --rem[ove] [<ID>]               remove dir entry from chosen lists (-$sc->{remove})
  --move [<IDa>] > <IDb>          move dir entry <IDa> to (position of) <IDb> (-$sc->{move})
  --copy [<IDa>] > <IDb>          copy entry <IDa> to (position of) <IDb> (-$sc->{copy})
  --name [<ID>]:<name>            (re-, un-) name entry (-$sc->{name})
  --path [<ID>] <dir>             change directory of entry (-$sc->{path})
  --edit [<ID>] '<code>'          edit project landing script (-$sc->{edit})

  --sort=$sopt              set sorting criterion of list display (-$sc->{sort})
  --list [<lname>]                change current list and display it (-$sc->{list})
  --list-lists                    display available list names (-$sc->{'list-lists'})
  --list-add <lname>              create a new list (-$sc->{'list-add'})
  --list-del <lname>              delete list of <lname> (has to be empty) (-$sc->{'list-delete'})
  --list-name <lID>:<lname>       rename list, conflicts not allowed (-$sc->{'list-name'})

  --help[=$hopt| <command>]     general or command specific help texts (-$sc->{help})
EOT
}

sub settings{ <<EOT,

   How to configure Goto Dir :
  -----------------------------

  Just edit the YAML file goto_dir_config.yml.
  Default settings can be recovered from goto_dir_config_default.yml.

  file:                               file names
    data:                               current state of dir entry store
    backup: places.bak.yml              state after seconad last usage
    return: last_choice                 directory gone to last time
                                          (communication channel with shell)
  list:                               properties of entry lists
    deprecate_new: 1209600              seconds, an entry stays in special list new
    deprecate_bin: 1209600              seconds a deleted entry will be preserved in list bin
    start_with: (current|default)       name of displayed list on app start
    sorted_by: (current|default)        sorting criterion of list on app start
    default_name: use                   name of default list
    default_sort: position              default sorting criterion
    name:                             setting personal names to special lists
      all:                              contains every entry (deleted too)
      bin:                              contains only deleted, not yet scrapped
      idle:                             dormant projects
      new:                              only newly created entries
      use:                              active projects
  entry:                              properties of entry lists
    max_name_length: 5                  maximal entry name length
    position_of_new_entry: -1           default position of list to insert entry in
    prefer_in_name_conflict: (new|old)  How resolve name conflict (one entry looses it) ?
    prefer_in_dir_conflict: (new|old)   Create a new entry with already use dir or del old ?
  syntax:                             syntax of command line interface
    sigil:                              special character that start a kind of input
      command: '-'                        first char of short command
      entry_name: ':'                     separator for entry name
      entry_position: '#'                 separator for list position
      target_entry: '>'                   separator between source and target
      special_entry: '*'                  first char of special entry name like '*last'
    special_entry:                      short alias of special entries
      last: '_'                           the dir gone to last time
      previous: '-'                       the dir gone to before
      new: '*'                            the dir of last created dir
    command_shortcut:                   short command names (default is first char)
    option_shortcut:                    shortcuts for command options (start with '=')
      help:                               option shortcuts for command 'help'
EOT
}


my %command = ( add => \&add,
             delete => \&delete,
             remove => \&remove,
               move => \&move,
               copy => \&copy,
               name => \&name,
               path => \&path,
               edit => \&edit,
               list => \&list,
               sort => \&sort,
       'list-lists' => \&llists,
         'list-add' => \&ladd,
      'list-delete' => \&ldelete,
        'list-name' => \&lname,
               help => \&help,
);
sub add {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    <<EOT;

   gt --add      create a new entry
  ----------------------------------

  --add <dir>[:<name>] [> <lpos>]     full syntax
   -$config->{'syntax'}{'command_shortcut'}{'add'}                                 short alias


  --add /project/dir         Adding the directory into current list on default position
                             under no name - will also appear in special lists '$lname->{new}' and '$lname->{all}'.

  --add /path :name          adding path under a name

  --add /path:name>[#]3      adding named path to current list on third position

  --add /path > good#4       adding unnamed path to list named good on fourth position


    <Space> (' ') around: '>', '#' and ':' is optional.
    If <dir> contains <Space> or ':', it has to be set in single quotes ('/path').

    If this directory is already stored in any list, the config entry: entry.prefer_in_dir_conflict
    in goto_dir_config.yml decides if new or old entry is kept.
    If the chosen name is already used by any entry, the config entry: entry.prefer_in_name_conflict
    in goto_dir_config.yml decides if new or old entry will keep it.
EOT
}
sub delete {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'delete'};
    my $lname = $config->{'list'}{'name'};
     <<EOT;

   gt --delete      delete entry from store
  ------------------------------------------

  --delete [<ID>]            full syntax
  --del                      shorter alias
   -$config->{'syntax'}{'command_shortcut'}{'delete'}                        short alias


  --delete                   Removes in  the directory into current list on default position
                             under no name - will also appear in special lists '$lname->{bin}' and '$lname->{all}'.

  --add /path :name          adding path under a name

  --add /path:name>[#]3      adding named path to current list on third position

  --add /path > good#4       adding unnamed path to list named good on fourth position


  If this directory is already stored in any list, the config entry: entry.prefer_in_dir_conflict
  in goto_dir_config.yml decides if new or old entry is kept.
  If the chosen name is already used by any entry, the config entry: entry.prefer_in_name_conflict
  in goto_dir_config.yml decides if new or old entry will keep it.
EOT
}
sub remove {
    my $config = shift;  <<EOT;
EOT
}
sub move {
    my $config = shift;  <<EOT;
EOT
}
sub copy {
    my $config = shift;  <<EOT;
EOT
}
sub name {
    my $config = shift;  <<EOT;
EOT
}
sub path {
    my $config = shift;  <<EOT;
EOT
}
sub edit {
    my $config = shift;  <<EOT;
EOT
}
sub list {
    my $config = shift;  <<EOT;
EOT
}
sub sort {
    my $config = shift;  <<EOT;
EOT
}
sub llists {
    my $config = shift;  <<EOT;
EOT
}
sub ladd {
    my $config = shift;  <<EOT;
EOT
}
sub ldelete {
    my $config = shift;  <<EOT;
EOT
}
sub lname {
    my $config = shift;  <<EOT;
EOT
}
sub help {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'help'};
    my $opt = $config->{'syntax'}{'option_shortcut'}{'help'};
    <<EOT;

   gt --help      display documentation
  --------------------------------------

  --help            -$sc        overview

  --help=basics     -$sc$opt->{basics}       general, simple (basic) usage
  --help=commands   -$sc$opt->{commands}       list of all commands (cheat sheet)
  --help=install    -$sc$opt->{install}       how to install the app
  --help=settings   -$sc$opt->{settings}       how to configure the program

  --help <command>  -$sc <cmd>  detailed explanation of one command
                              command shortcut may be used
                              <Space> before <cmd> is necessary
EOT
}

sub text {
    my ($config, $category, $name) = @_;
    return overview( $config ) unless defined $category;
    if    ($category eq 'option') { defined $option{$name} ? $option{$name}( $config ) : "there is no Goto::Dir help topic: '$name'" }
    elsif ($category eq 'command'){ defined $command{$name} ? $command{$name}( $config ) : "there is no Goto::Dir command $name" }
    else                            { overview() }
}
1;

__END__
## syntax rules:
- `<dir> . . . directory path, starts with: '\','/','~' ;  in quotes ('..') when containing ':' or ' '
. . . . . . . . defaults to dir app is called from`

- `<name>. . . name of an dir entry, (start with letter + word character \w), default ''`
- `<lname> . . name of a list, defaults to current list when omitted`
- `<pos> . . . list position, first is 1, last is -1 (default), second last -2`
- `<lpos>. . . = <pos> or #<pos> or <lname>#<pos> position in list (default is current list)`
- `<ID>. . . . = <name> or :<name> or <lpos> (entry identifier)`
- `--. . . . . starting characters of any command in long form (--add)`
- `- . . . . . starting character of any command in short form (-add)`
- `# . . . . . (read number) separates <lname> and <pos> in full adress of an entry`
- `: . . . . . precedes, separates <name>,  (see -add, -name)`
- `> . . . . . separates a source (left) and its destination (right) (see -add, -move, -copy)`
- `<Space> . . ' ' separates long commands and args, allowed around > and before : #`

## commands for changing directory:
- `<name>. . . . . . . . . go to dir with <name> (right beside <pos> in list)`
- `<pos> . . . . . . . . . go to dir listed on <pos> (in []) of current list`
- `<lname>#<pos> . . . . . go to directory at <pos> in list <lname>`
- `<ID>/sub/dir. . . . . . go to subdirectory of a stored dir`
- `*last . . . . . . . . . go to dir gone to last time (in short: '_')`
- `*previous . . . . . . . go to dir gone previously (short '-', like cd -)`
- `*new. . . . . . . . . . go to dir added last (*)`
- `<Enter> . . . . . . . . exit interactive mode and stay in current dir`

## commands to display lists and help:
- `--list . . . . . . . . . display current list (not needed in interactive) (short -l)`
- `--list <lname> . . . . . set <lname> as current list and display it (-l<name>)`
- `--list-lists . . . . . . display available list names (long for -l-l)`
- `--sort=position. . . . . sort displayed list by position (default) (-s, -sp)`
- `--sort=name. . . . . . . change sorting criterion to <name> (-sn)`
- `--sort=visits. . . . . . sort by number of times gone to dir (-sv)`
- `--sort=last_visit. . . . sort by time of last visit (earlier first, -sl)`
- `--sort=created . . . . . sort by time of dir entry creation (-sc)`
- `--sort=dir . . . . . . . sort by dir path (-sd, -sort=d)`
- `--help . . . . . . . . . overview of all help topics (-h)`
- `--help=usage . . . . . . intro text (short -hu)`
- `--help=commands. . . . . display list of commands (-hc)`
- `--help=settings. . . . . display list of commands (-hs)`
- `--help <command> . . . . detailed help for one command (-h<command>)`

## commands for managing list entries:
- `--add <dir>[:<name>] [> <lpos>] add <dir> under <name> and <lpos>, only <dir> is required (-a) .
. . . . . . . . . . . . . . . . .also add to special list "new" for configured time`
- `--del[ete] [<ID>] . . . . . . . delete entry with <ID> in all but special lists: all, bin (-d)
. . . . . . . . . . . . . . . . . .and move to special list "bin", hard delete after configured time`
- `--rem[ove] [<ID>] . . . . . . . remove entry from chosen, but not special lists: all, bin (-r)`
- `--move [<IDa>] > <IDb>. . . . . move entry <IDa> to position (of) <IDb> (-m)`
- `--copy [<IDa>] > <IDb>. . . . . copy entry <IDa> to position (of) <IDb> (-c)`
- `--name [<ID>]:<name>. . . . . . (re-)name entry, resolve conflict like configured (-n)`
- `--name [<ID>] . . . . . . . . . delete name of entry (-n)`
- `--path [<ID>] > <dir> . . . . . change directory of entry with <ID> (-p)`

## commands for managing lists:
- `--list-add <lname> . . . . . create a new list (-l-a)`
- `--list-del <lname> . . . . . delete list of <lname> (has to be empty) (-l-d)`
- `--list-name <lID>:<lname>. . rename list, conflicts not allowed (-l-n)`
- `--list-lists. . . . . . .  . <lname> and <lpos> of available lists (short -l-l)`
