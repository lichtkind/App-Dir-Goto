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


  For overview of more help topics use --help help or -$config->{syntax}{command_shortcut}{help} $config->{syntax}{command_shortcut}{help}
EOT
}
sub install{ <<EOT,

   How to install and maintain App::Goto::Dir :
  --------------------------------------------

   App::Goto::Dir is a perl module, that requires perl 5.18 and and the YAML module.
   It installs the script goto.pl which is not fully usable out of the box,
   since it can not change the current working directory (cwd) of a shell.
   In order to achieve that, you have to add to the shellrc the line:

   function gt() { perl ~/../goto.pl \\\$@ cd \$\\(cat ~/../last_choice) }

   Replace gt with the name you want to call the app with.
   ~/.. is of course the placeholder for the directory App::Goto::Dir is installed into.
   There should be three files that are very important:

   last_choice      This file is the interface between the script and the shell.
                    Its name can be configured (change shellrc line accordingly).

   places.yml       This file contains all the user data (directories and lists).
                    There is a backup with places.bak.yml (both names configurable).

   goto_dir_config.yml  Contains configuration (settings), it's name is fixed.
                        Defaults are in goto_dir_config_default.yml.

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

  --add <path>[:<name>] [> <ID>]  add directory <path> under <name> to a list (-$sc->{add})
  --del[ete] [<ID>]               delete dir entry from all lists  (-$sc->{delete})
  --rem[ove] [<ID>]               remove dir entry from chosen lists (-$sc->{remove})
  --move [<IDa>] > <IDb>          move dir entry <IDa> to (position of) <IDb> (-$sc->{move})
  --copy [<IDa>] > <IDb>          copy entry <IDa> to (position of) <IDb> (-$sc->{copy})

  --name [<ID>] [:<name>]         (re-, un-) name entry (-$sc->{name})
  --path [<ID>] <path>            change directory of entry (-$sc->{path})
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
  ---------------------------

  Just edit the YAML file goto_dir_config.yml.
  Default settings can be recovered from goto_dir_config_default.yml.

  file:                               file names
    data:                               current state of dir entry store
    backup: places.bak.yml              state after seconad last usage
    return: last_choice                 directory gone to last time
                                          (communication channel with shell)
  list:                               properties of entry lists
    deprecate_new: 1209600              seconds an entry stays in special list new
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
    default_position: -1                when list position is omitted take this
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
    my $d = $config->{'list'}{'deprecate_new'} / 86400;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'add'};
    <<EOT;

   gt --add      create a new entry
  ----------------------------------

    Creates a new <path> (directory) entry and stores it in one list at a certain position (<lpos>).
    The entry will also appear in special lists '$lname->{all}' and '$lname->{new}' and will remain
    in '$lname->{new}' for $d days (to be configured via key entry.deprecate_new in goto_dir_config.yml).
    If <path> is already stored in any list, entry.prefer_in_dir_conflict decides if new or old entry is kept.
    If <name> is already used by any entry, entry.prefer_in_name_conflict decides if new or old entry will keep it.


 Full Syntax:

  --add  <path>[:<name>] [> <entryID>]    long command name
   -$sc<path>[:<name>] [> <entryID>]        short alias


 Examples:

  --add /project/dir         adding the directory into current list on default position with no name

   -$sc/path:p                 adding path into same place but under the name 'p'

  --add /path:p > [#]3       adding named path to current list on third position

  --add /path > good#4       adding unnamed path to list named 'good' on fourth position

  --add /path > good:s       adding unnamed path to list 'good' on position of entry named 's'


    Space (' ') is after '#' and ':' not allowed, but after --add required.
    Space around: '>', before '#', ':' and after '-$sc' is optional.
    If <path> contains <Space> (' ') or ':', it has to be set in single quotes ('/a path').
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub delete {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    my $d = $config->{'list'}{'deprecate_bin'} / 86400;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'delete'};
     <<EOT;

   gt --delete      delete entry from store
  ------------------------------------------

    Deletes a specified <path> entry from all lists except the special lists '$lname->{all}' and '$lname->{bin}'.
    The entry will also moved be to the special list '$lname->{bin}' and scrapped fully after $d days.
    This duration may be configured via the config entry: entry.deprecate_bin in goto_dir_config.yml.


 Full Syntax:

  --delete  [<entryID>]      long command name
  --del  [<entryID>]         shorter alias
   -$sc\[<entryID>]             short alias


 Examples:

  --delete                   removing entry on default position ($config->{'entry'}{'default_position'}) of current list from all lists

  --del [#]<pos>             deleting entry on chosen position of current list

  --del <list>#<pos>         deleting entry on chosen position of list named <list>

   -$sc\[:]fm                   deleting entry named fm


    Space (' ') is after '#' and ':' not allowed, but after --del[ete] required.
    Space before '#', ':' and after '-$sc' is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position can be negative, counting from the last position.
EOT
}
sub remove {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'remove'};
    my $arg = 'good:ll';
    <<EOT;

   gt --remove      remove entry from list
  -----------------------------------------

    Removes a specified <path> entry from a list.
    Special lists '$lname->{new}', '$lname->{all}' and '$lname->{bin}' will not respond.


 Full Syntax:

  --remove  [<entryID>]      long command name
  --rm  [<entryID>]          shorter alias
   -$sc\[<entryID>]             short alias


 Examples:

  --remove                   removing entry on default position ($config->{'entry'}{'default_position'}) of current list

  --rm -1                    removing entry from last position of current list

  --rm good#4                removing entry from fourth position of list named good

  --rm :ll                   removing entry named 'll' from current list

   -$sc$arg                 removing entry 'll' from list named good


    Space (' ') is after '#' and ':' not allowed, but after --remove or --rm required.
    Space before '#' or ':' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub move {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'move'};
    my $arg = '2>-1';
    <<EOT;

   gt --move      move entry from one to another list
  ----------------------------------------------------

    Removes a specified <path> entry from a list and inserts it into another list.
    Entries can not be moved into and out of the special lists '$lname->{new}' and '$lname->{all}',
    but can be moved inside these lists to change their position.
    Use the command --delete to move an entry out of all lists, but '$lname->{all}'
    and move them into the special list '$lname->{bin}'. But use --move as the official
    "undelete" to move them out of '$lname->{bin}' into a regular list.


 Full Syntax:

  --move  [<sourceID>] > <targetID>    long command name
  --mv  [<sourceID>] > <targetID>      shorter alias
   -$sc\[<sourceID>] > <targetID>         short alias


 Examples:

  --move > idle#3            moving entry from default position ($config->{'entry'}{'default_position'}) of current list
                             to third position of list named 'idle'

   -$sc$arg                    moving entry from second to last position in current list

  --mv good#4 > better#2     moving entry from fourth position of list 'good' to second pos. of 'better'

  --mv rr > good             moving entry in current list named 'rr' to default position of list 'good'

  --mv meak:rr > great:d     moving entry 'rr' in list 'meak' to position of entry 'd' in list 'great'


    Space (' ') is after '#' and ':' not allowed, but after --move or --mv required.
    Space before '#' or ':', around '>' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub copy {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'copy'};
    my $arg = '2>-1';
    <<EOT;

   gt --copy      copy entry from one to another list
  ----------------------------------------------------

    Find a <path> entry and insert it into another list.
    Target can't be the special list '$lname->{new}', '$lname->{all}' and '$lname->{bin}'.
    If entry is already list element, the config key entry.prefer_in_dir_conflict in goto_dir_config.yml
    decides if new or old entry is kept.


 Full Syntax:

  --copy  [<sourceID>] > <targetID>    long command name
  --cp  [<sourceID>] > <targetID>      shorter alias
   -$sc\[<sourceID>] > <targetID>         short alias


 Examples:

  --copy > idle#3            copying from default position ($config->{'entry'}{'default_position'}) of current list to third position of list 'idle'

   -$sc$arg                    copying entry from second to last position in current list (produces conflict!)

  --cp all#4 > better#2      copying entry from fourth position of list 'all' to second pos. of 'better'

  --cp rr > good             copying entry named 'rr' (of any list) to default position of list 'good'

  --cp :rr > great:d         copying entry 'rr' to position of entry 'd' in list 'great'


    Space (' ') is after '#' and ':' not allowed, but after --copy or --cp required.
    Space before '#' or ':', around '>' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub name {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'name'};
    my $arg = 'mi:fa';
    <<EOT;

   gt --name      change entry name
  ----------------------------------

    Find a <path> entry and change its unique name (applies to all entries holding same path).
    If <name> is omitted, it defaults to an empty string, which results in deleting the entry name.
    If <name> is already used by another entry, the config key entry.prefer_in_name_conflict in goto_dir_config.yml
    decides, if the new (this) or old (other) entry will keep it.


 Full Syntax:

  --name  [<entryID>] [:<name>]    long command name
   -$sc\[<entryID>] [:<name>]         short alias


 Examples:

  --name                     delete name of entry on default position ($config->{'entry'}{'default_position'}) of current list

  --name :do                 set name of default entry to 'do'

  --name idle#3:re           give entry on third position of list 'idle' the name 're'

   -$sc$arg                   rename entry 'mi' to 'fa'

  --name sol                 delete name of entry 'sol'


    Space (' ') is after '#' and ':' not allowed, but after --name required.
    Space before '#' or ':'  and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub path {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'path'};
    <<EOT;

   gt --path      change path of entry
  -------------------------------------

    Find an entry and change its unique <path> - the directory the program switches into, when entry is selected.
    If <path> is already stored in any other entry, the config key entry.prefer_in_dir_conflict in goto_dir_config.yml
    decides, if new (this) or old (other) entry is kept.


 Full Syntax:

  --path  [<entryID>] <path>    long command name
   -$sc\[<entryID>] <path>         short alias


 Examples:

  --path ~/perl/project      set path of default entry ($config->{'entry'}{'default_position'}) in current list to '~/perl/project'

  --path :sol /usr/bin       set path of entry named 'sol' to /usr/bin

  --path idle#3 /bin/da      set path of third entry in list 'idle' to /bin/da

   -$sc/usr/temp               change <path> of default entry in current list


    Space (' ') is after '#' and ':' not allowed, but after --path required.
    Space before '#' or ':'  and after -$sc is optional.
    If <path> contains <Space> (' ') or ':', it has to be set in single quotes ('/a path').
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub edit {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'edit'};
    <<EOT;

   gt --edit      change landing script
  --------------------------------------

    Find an entry and change its <code> property - a snippet of perl code that is run,
    after switching into the entries <path>. It's output will be displayed.


 Full Syntax:

  --edit  [<entryID>] '<code>'    long command name
   -$sc\[<entryID>] '<code>'         short alias


 Examples:

  --edit 'say "dance"'       set code of default entry ($config->{'entry'}{'default_position'}) in current list to 'say "dance"'

  --edit :sol 'say "gg"'     set landing script code of entry bamed 'sol' to 'say "gg"'

  --edit idle#3 'say f2()'   set code of third entry in list 'idle' to 'say f2()'

   -$sc\'say 99'                change <code> of default entry in current list to 'say 99'


    Space (' ') is after '#' and ':' not allowed, but after --path required.
    Space before '#' or ':'  and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter like list names.
    List position may be negative, counting from the last position.
EOT
}
sub list {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list'};
    <<EOT;

   gt --list      display list of entries
  ----------------------------------------

    Set the name of the current list, that will be displayed immediately.
    When running the gt REPL shell (open via gt without any arguments), the current list
    will be displayed after each command. There you need --list only to switch the shown list.
    When calling gt with arguments you need --list to get any (or several) lists displayed.
    All commands regarding lists start with --list-.. but are separate commands.


 Full Syntax:

  --list  [<listname>]    long command name
   -$sc\[<listname>]         short alias


 Examples:

    gt --list a --list b       display list named 'a' and 'b' in the shell


    List names contain only word character (A-Z,a-z,0-9,_) and start with a letter.
EOT
}
sub sort {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'sort'};
    my $opt = $config->{'syntax'}{'option_shortcut'}{'sort'};
    <<EOT;

   gt --sort      set list sorting criterion
  -------------------------------------------

    Selecting the sorting criterion used by --list to display any <path> entry list.
    The default criterion ($config->{list}{default_sort}) is set by the config key: list.default_sort in goto_dir_config.yml.
    If the key: list.sorted_by ($config->{list}{sorted_by}) is set to 'current', than the set criterion is remembered.
    Otherwise it will fall back to default, when the program shuts down.
    Calling --sort without an option also triggers that fallback.
    Starting the option with '!' means: reversed order.
    Like the command itself, every option has a short version too.


  --sort              -$sc        set to default criterion ($config->{list}{default_sort})
  --sort=position     -$sc$opt->{position}       obey user defined positional ordering of list
  --sort=path         -$sc$opt->{path}       alphanumeric ordering of paths
  --sort=name         -$sc$opt->{name}       alphanumeric ordering of entry names, unnamed last
  --sort=visits       -$sc$opt->{visits}       number of visits, most visited first
  --sort=last_visit   -$sc$opt->{last_visit}       time of last visit, the very last first
  --sort=created      -$sc$opt->{created}       time of creation, oldest first
  --sort=!created     -$sc!$opt->{created}      time of creation, newest first
EOT

}
sub llists {
    my $config = shift;
    <<EOT;

   gt --list-list      all list names
  ------------------------------------

    Display overview with all list names. The special ones are marked with '*' and their function.


 Full Syntax:

  --list-list    long command name
   -$config->{'syntax'}{'command_shortcut'}{'list-list'}          short alias
EOT
}
sub ladd {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-add'};
    <<EOT;

   gt --list-add      create a list
  ----------------------------------

    Create a new and empty list for path entries. It's mandatory name has to be not taken yet.


 Full Syntax:

  --list-add  <name>    long command name
   -$sc<name>           short alias


    Space (' ') after --list-add is required, but after -$sc optional.
    List names have to be unique, contain only word character (A-Z,a-z,0-9,_) and start with a letter.
EOT
}
sub ldelete {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-delete'};
    <<EOT;

   gt --list-delete      remove an empty list
  --------------------------------------------

    Deletes an empty, none special (user created) list.
    There is no undelete, but a --list-add.


 Full Syntax:

  --list-delete  <name>    long command name
  --list-del  <name>       shorter alias
   -$sc<name>              short alias


    Space (' ') after --list-delete and --list-del is required, but after -$sc optional.
    List names have to be unique, contain only word character (A-Z,a-z,0-9,_) and start with a letter.
EOT
}
sub lname {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-name'};
    <<EOT;

   gt --list-name      rename a list
  -----------------------------------

    Change name of any list, even the special ones. Does not work when <newname> is taken.


 Full Syntax:

  --list-name  <oldname> > <newname>    long command name
   -$sc <oldname> > <newname>           short alias


    Space (' ') after --list-name is required, but after -$sc and around '>' optional.
    List names have to be unique, contain only word character (A-Z,a-z,0-9,_) and start with a letter.
EOT
}
sub help {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'help'};
    my $opt = $config->{'syntax'}{'option_shortcut'}{'help'};
    <<EOT;

   gt --help      display documentation
  --------------------------------------

  --help            -$sc         overview

  --help=basics     -$sc$opt->{basics}        general, basic usage
  --help=commands   -$sc$opt->{commands}        list of all commands (cheat sheet)
  --help=install    -$sc$opt->{install}        how to install and maintain the program
  --help=settings   -$sc$opt->{settings}        how to configure the program

  --help <command>  -$sc <cmd>   detailed explanation of one command
                               command shortcut may be used instead <command>=<cmd>
                               Space before <cmd> is necessary here.
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
- `<path> . . . directory path, starts with: '\','/','~' ;  in quotes ('..') when containing ':' or ' '
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

