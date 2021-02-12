use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Help;

my %option = ( overview => \&overview,
               basics   => \&basics,
               commands => \&commands,
               install  => \&install,
               settings => \&settings,
               version  => \&version,
);
sub overview {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'help'};
    my $opt = $config->{'syntax'}{'option_shortcut'}{'help'};
    <<EOT;

   Overview of gt
  ----------------

  Command line tool gt (short for goto) changes the working dir like cd,
  to a user managed set of locations. This frees from memorizing and
  writing long dir path's. But it's also a lightweight tool for tracking
  activities and supporting work in the shell.

  It has two modes of operation: shell and REPL. The first is the normal
  usage via parameters as described by documentation. The second mode
  is called just with 'gt' and accepts the same commands and replies
  with same outputs as the first mode. The only difference: REPL mode
  displays after each batch of commands the content of the current list
  until the user calls a directory or just presses <Enter>. In that case
  it returns to the directory it was called from. In both modes several
  commands can be fired at once.

  To learn more about how to switch the working dir with gt type:

    gt --help=basics    or    gt -$sc$opt->{basics}

  And to see all the commands to manage the stored locations type:

    gt --help=commands    or    gt -$sc$opt->{commands}

  gt can not work out of the box, since no program can change the
  current working directory of the shell by itself. Please read also

    gt --help=install    or    gt -$sc$opt->{install}

  There are many ways to configure gt to your liking:

    gt --help=settings    or    gt -$sc$opt->{settings}

EOT
}
sub basics {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'help'};
    my $opt = $config->{'syntax'}{'option_shortcut'}{'help'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

   Basic use of gt
  -----------------

  The prime use of gt is changing the working directory of the users shell
  to a <dir>, that is already stored in gt as an entry. Theses entries are
  organized in named lists (<list>) and may have names (<name>) themself.
  Call gt -$sc$opt->{commands} to learn how to administer entries.
  Switch directory by calling gt and identify (with <ID>) an entry:

  gt [:]<name>           calling <dir> entry by name
  gt [#]<pos>            calling <dir> entry by position
  gt <list>#<pos>        calling <dir> entry from any list

  A negative position is counting from the lists last position (-1 = last).
  If <list> is omitted, than gt assumes the current list. List and entry
  names contain only word character (A-Za-z0-9_) and start with a letter.

  There are a number of special <dir> entry names (starting with $sig->{special_entry})
  and names of special lists (starting with $sig->{special_list}) that are listed below.
  They can be used in this function as regular entry and list names.
  No matter the way an entry is identified, the user can attach a path,
  that will be understood as subdirectory of the entry <dir>:

  gt $sig->{special_entry}last/..            go to parent directory of <dir> gone to last time

  The only special case are two short aliases of special entries, that can
  only be used to switch directory (no subdir allowed):

  gt _                   go to destination of last gt call (alias to $sig->{special_entry}last)
  gt -                   as cd -, second last destination (alias to $sig->{special_entry}previous)


 Special Entries:

  $sig->{special_entry}last                  destination of last gt call (with subdir)
  $sig->{special_entry}prev[ious]            destination of second last gt call (with subdir)
  $sig->{special_entry}new                   <dir> of most recently created entry
  $sig->{special_entry}add|del|[re]move|copy every command has special entry with same name,
                         an alias to the entry touched by the command most recently

 Special Lists:

  $sig->{special_list}all                   entries from all lists even $sig->{special_list}bin
  $sig->{special_list}new                   newly created entries (configure how old)
  $sig->{special_list}bin                   deleted entries (can be undeleted, scrapped after period)
  $sig->{special_list}stale                 entries with defunct (not existing) directories

EOT
}
sub install{ <<EOT,

   How to install and maintain App::Goto::Dir
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

   all gt commands in long and short form
  ----------------------------------------

   commands to modify entries:

  --dir [<ID>] <dir>             change directory of entry (-$sc->{dir})
  --name [<ID>] [:<name>]        (re-, un-) name entry (-$sc->{name})
  --edit [<ID>] '<code>'         edit project landing script (-$sc->{edit})

   commands to manage entries:

  --add <dir>[:<name>] [> <ID>]  add directory <dir> under <name> to a list (-$sc->{add})
  --del[ete] [<ID>]              delete dir entry from all lists  (-$sc->{delete})
  --rem[ove] [<ID>]              remove dir entry from chosen lists (-$sc->{remove})
  --move [<IDa>] > <IDb>         move dir entry <IDa> to (position of) <IDb> (-$sc->{move})
  --copy [<IDa>] > <IDb>         copy entry <IDa> to (position of) <IDb> (-$sc->{copy})

   commands to manage entry lists:

  --list [<lname>]               change current list and display it (-$sc->{list})
  --sort=$sopt             set sorting criterion of list display (-$sc->{sort})
  --list-lists                   display available list names (-$sc->{'list-lists'})
  --list-add <lname>             create a new list (-$sc->{'list-add'})
  --list-del <lname>             delete list of <lname> (has to be empty) (-$sc->{'list-delete'})
  --list-name <lID>:<lname>      rename list, conflicts not allowed (-$sc->{'list-name'})

  --help[=$hopt| <command>]    general or command specific help texts (-$sc->{help})
EOT
}

sub settings{ <<EOT,

   How to configure Goto Dir
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
      stale:                            entries with none existing direcories
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
sub version {
    my $config = shift;
    my $us = '-'x length $App::Goto::Dir::VERSION;
    <<EOT;

   App::Goto::Dir $App::Goto::Dir::VERSION
  -----------------$us

  Command line tool gt for long distance directory jumps

  Herbert Breunung 2021

  For more help use gt --help help or gt -$config->{syntax}{command_shortcut}{help} $config->{syntax}{command_shortcut}{help}
EOT
}

my %command = ( add => \&add,
             delete => \&delete,
             remove => \&remove,
               move => \&move,
               copy => \&copy,
               name => \&name,
               dir => \&dir,
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
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

   gt --add      create a new entry
  ----------------------------------

 Full Syntax:

  --add  [<dir>] [:<name>] [> <entryID>]    long command name
   -$sc\[<dir>] [:<name>] [> <entryID>]        short alias

    Creates a new entry to store the directory <dir> in a list named <list> at a position <pos>
    and maybe also under a name <name>. The entry will also appear in special lists $sig->{special_list}$lname->{all} and $sig->{special_list}$lname->{new}
    and will remain in $sig->{special_list}$lname->{new} for $d days (to be configured via key entry.deprecate_new in goto_dir_config.yml).
    If <dir> is already stored in any list, entry.prefer_in_dir_conflict decides if new or old entry is kept.
    If <name> is already used by any entry, entry.prefer_in_name_conflict decides if new or old entry will keep it.
    If <dir>  is omitted, it defaults to the directory gt is called from. <name> defaults to the empty (no) name.
    A missing <entryID> defaults to the default position ($config->{'entry'}{'default_position'}) in the current list.


 Examples:

  --add /project/dir         adding the directory into current list on default position with no name

   -$sc/path:p                 adding path into same place but under the name 'p'

  --add /path:p > [#]3       adding named path to current list on third position

  --add /path > good#4       adding unnamed path to list named 'good' on fourth position

  --add /path > good:s       adding unnamed path to list 'good' on position of entry named 's'

    Space (' ') is after '#' and ':' not allowed, but after --add required.
    Space around: '>', before '#', ':' and after '-$sc' is optional.
    If <dir> contains space (' ') or ':', it has to be set in single quotes ('/a path').
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub delete {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    my $d = $config->{'list'}{'deprecate_bin'} / 86400;
    my $sig = $config->{'syntax'}{'sigil'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'delete'};
     <<EOT;

   gt --delete      delete entry from store
  ------------------------------------------

    Deletes a specified <dir> entry from all lists except the special lists '$lname->{all}' and '$lname->{bin}'.
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

  --del $sig->{special_entry}new                 deleting a previosly created entry

   -$sc\[:]fm                   deleting entry named fm


    Space (' ') is after '#' and ':' not allowed, but after --del[ete] required.
    Space before '#', ':' and after '-$sc' is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
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

    Removes a specified <dir> entry from a list.
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
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub move {
    my $config = shift;
    my $lname = $config->{'list'}{'name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'move'};
    my $sig = $config->{'syntax'}{'sigil'};
    my $arg = '2>-1';
    <<EOT;

   gt --move      move entry from one to another list
  ----------------------------------------------------

    Removes a specified <dir> entry from a list and inserts it into another list.
    If source and target are the same, it only changes the position.
    Entries can not be moved into and out of the special lists '$lname->{new}' and '$lname->{all}'.
    They also can not be moved into, but can be moved out of the special list '$lname->{bin}'.
    Use the command --delete to move an entry out of all regular lists into '$lname->{bin}'.
    But use --move as the official "undelete" to move them out of '$lname->{bin}'.


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

  --move $sig->{special_entry}delete > great     undelete the most recently deleted entry and move it into list 'good'


    Space (' ') is after '#' and ':' not allowed, but after --move or --mv required.
    Space before '#' or ':', around '>' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
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

    Find a <dir> entry and insert it into another list.
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

  --cp *move > idle#3        copying recently moved entry to third pos. of list 'idle'

  --cp rr > good             copying entry named 'rr' (of any list) to default position of list 'good'

  --cp :rr > great:d         copying entry 'rr' to position of entry 'd' in list 'great'


    Space (' ') is after '#' and ':' not allowed, but after --copy or --cp required.
    Space before '#' or ':', around '>' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
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

    Find a <dir> entry and change its unique name (applies to all entries holding same path).
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
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub dir {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'dir'};
    <<EOT;

   gt --dir      change path of entry
  ------------------------------------

    Find an entry and change its unique <dir> - the directory the program switches into, when entry is selected.
    If <dir> is already stored in any other entry, the config key entry.prefer_in_dir_conflict in goto_dir_config.yml
    decides, if new (this) or old (other) entry is kept.


 Full Syntax:

  --dir  [<entryID>] <dir>    long command name
   -$sc\[<entryID>] <dir>        short alias


 Examples:

  --path ~/perl/project      set path of default entry ($config->{'entry'}{'default_position'}) in current list to '~/perl/project'

  --path :sol /usr/bin       set path of entry named 'sol' to /usr/bin

  --path idle#3 /bin/da      set path of third entry in list 'idle' to /bin/da

   -$sc/usr/temp               change <dir> of default entry in current list


    Space (' ') is after '#' and ':' not allowed, but after --path required.
    Space before '#' or ':'  and after -$sc is optional.
    If <dir> contains space (' ') or ':', it has to be set in single quotes ('/a path').
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
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
    after switching into the entries <dir>. It's output will be displayed.


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
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
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

    Selecting the sorting criterion used by --list to display any <dir> entry list.
    The default criterion ($config->{list}{default_sort}) is set by the config key: list.default_sort in goto_dir_config.yml.
    If the key: list.sorted_by ($config->{list}{sorted_by}) is set to 'current', than the set criterion is remembered.
    Otherwise it will fall back to default, when the program shuts down.
    Calling --sort without an option also triggers that fallback.
    Starting the option with '!' means: reversed order.
    Like the command itself, every option has a short version too.


  --sort              -$sc        set to default criterion ($config->{list}{default_sort})
  --sort=position     -$sc$opt->{position}       obey user defined positional ordering of list
  --sort=dir          -$sc$opt->{dir}        alphanumeric ordering of directories
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

