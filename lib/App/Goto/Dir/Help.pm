use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Help;

my %text = ( overview => \&overview,
             basics   => \&basics,
             commands => \&commands,
             install  => \&install,
             settings => \&settings,
             version  => \&version,
              '--add' => \&add,
           '--delete' => \&delete,
           '--remove' => \&remove,
             '--move' => \&move,
             '--copy' => \&copy,
             '--name' => \&name,
              '--dir' => \&dir,
             '--edit' => \&edit,
             '--list' => \&list,
             '--sort' => \&sort,
       '--list-lists' => \&llists,
     '--list-special' => \&lspecial,
         '--list-add' => \&ladd,
      '--list-delete' => \&ldelete,
        '--list-name' => \&lname,
 '--list-description' => \&ldescription,
             '--help' => \&help,
);
sub overview {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'help'};
    my $opt = $config->{'syntax'}{'option_shortcut'}{'help'};
    <<EOT;

  Introduction to gt
 --------------------

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

    gt [$sig->{entry_name}]<name>           calling <dir> entry by name
    gt [$sig->{entry_position}]<pos>            calling <dir> entry by position
    gt <list>$sig->{entry_position}<pos>        calling <dir> entry from any list

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


 SPECIAL ENTRIES:

  $sig->{special_entry}last                   destination of last gt call (with subdir)
  $sig->{special_entry}prev[ious]             destination of second last gt call (with subdir)
  $sig->{special_entry}new                    <dir> of most recently created entry
  $sig->{special_entry}add|del|[re]move|copy  every command has special entry with same name,
                           an alias to the entry touched by the command most recently

 SPECIAL LISTS:

  $sig->{special_list}all                    entries from all lists, even $sig->{special_list}bin
  $sig->{special_list}new                    newly created entries (configure how old, --help=settings)
  $sig->{special_list}bin                    deleted entries (scrapped after configured period)
  $sig->{special_list}stale                  entries with defunct (not existing) directories
  $sig->{special_list}special                content of all special entries
EOT
}
sub install{
    my $config = shift;
  <<EOT,

  How to install and maintain gt
 --------------------------------

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
                       If one of these two files is missing, it will be created
                       at the next program start containing the defaults.
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

  display commands:

  -$sc->{help} --help[=$hopt| <command>]     topic or command specific help texts
  -$sc->{sort} --sort=$sopt              set sorting criterion of list display
  -$sc->{list}  --list [<listname>]            change current list and display it
  -$sc->{'list-special'} --list-special                display all special entries

  commands to manage lists:

  -$sc->{'list-lists'} --list-lists                  display available list names
  -$sc->{'list-add'} --list-add <name> ? <Desc.>   create a new list
  -$sc->{'list-delete'} --list-del[ete] <name>        delete list with <listname> (has to be empty)
  -$sc->{'list-name'} --list-name <name>:<newname>  rename list, conflicts not allowed
  -$sc->{'list-description'} --list-description <name>?<D> change list description

  commands to manage list entries:

  -$sc->{add} --add <dir>[:<name>] [> <ID>]   add directory <dir> under <name> to a list
  -$sc->{delete} --del[ete] [<ID>]               delete dir entries from all regular lists
  -$sc->{remove} --rem[ove] [<ID>]               remove dir entries from a chosen lists
  -$sc->{move} --move [<IDa>] > <IDb>          move dir entry <IDa> to (position of) <IDb>
  -$sc->{copy} --copy [<IDa>] > <IDb>          copy entry <IDa> to (position of) <IDb>

  commands to modify entries:

  -$sc->{dir} --dir [<ID>] <dir>              change directory of one or more entries
  -$sc->{name} --name [<ID>] [:<name>]         (re-, un-) name entry
  -$sc->{edit} --edit [<ID>] '<code>'          edit project landing script
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
    name_default: use                   name of default list
    special_name:                     setting personal names to special lists
      all:                              contains every entry (deleted too)
      bin:                              contains only deleted, not yet scrapped
      idle:                             dormant projects
      new:                              only newly created entries
      named:                            entries with a shortcut name
    special_description:              description texts of special lists
    sorted_by: (current|default)      sorting criterion of list on app start
    sort_default: position            default sorting criterion
  entry:                              properties of entry lists
    max_name_length: 5                  maximal entry name length
    position_default: -1                when list position is omitted take this
    prefer_in_name_conflict: (new|old)  How resolve name conflict (one entry looses it) ?
    prefer_in_dir_conflict: (new|old)   Create a new entry with already use dir or del old ?
  syntax:                             syntax of command line interface
    sigil:                              special character that start a kind of input
      command: '-'                        first char of short command
      entry_name: ':'                     separator for entry name
      entry_position: '^'                 separator for list position
      target_entry: '>'                   separator between source and target
      special_entry: '+'                  first char of special entry name like '+last'
      special_list: '@'                   first char of special list name like '\@all'
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

sub add {
    my $config = shift;
    my $lname = $config->{'list'}{'special_name'};
    my $d = $config->{'list'}{'deprecate_new'} / 86400;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'add'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

  gt --add      create a new entry
 ----------------------------------

    Creates a new entry to store the directory <dir> in a list named <list> at a position <pos>
    and maybe also under a name <name>. The entry will also appear in special lists $sig->{special_list}$lname->{all} and $sig->{special_list}$lname->{new}
    and will remain in $sig->{special_list}$lname->{new} for $d days (to be configured via key entry.deprecate_new in goto_dir_config.yml).
    If <dir> is already stored in any list, entry.prefer_in_dir_conflict decides if new or old entry is kept.
    If <name> is already used by any entry, entry.prefer_in_name_conflict decides if new or old entry will keep it.
    If <dir>  is omitted, it defaults to the directory gt is called from. <name> defaults to the empty (no) name.
    A missing <entryID> defaults to the default position ($config->{'entry'}{position_default}) in the current list.

 USAGE:

  --add  [<dir>] [$sig->{entry_name}<name>] [> <entryID>]    long command name
   -$sc\[<dir>] [$sig->{entry_name}<name>] [> <entryID>]        short alias


 EXAMPLES:

  --add /project/dir         add the directory into current list on default position with no name
   -$sc/path$sig->{entry_name}p                 add path into same place but under the name 'p'
  --add /path$sig->{entry_name}p $sig->{target_entry} [$sig->{entry_position}]3       add named path to current list on third position
  --add /path $sig->{target_entry} good$sig->{entry_position}4       add unnamed path to list named 'good' on fourth position
  --add /path $sig->{target_entry} good$sig->{entry_name}s       add unnamed path to list 'good' on position of entry named 's'
  --add good$sig->{entry_position}2/sub/dir:gg    add subdirectory of entry nr.2 in list 'good' under name 'gg' at default pos.

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --add required.
    Space before '$sig->{entry_position}' and '$sig->{entry_name}', around: '$sig->{target_entry}' and after '-$sc' is optional.
    <dir> has to start with '/', '\\' or '~'. If <dir> contains space (' '), '$sig->{target_entry}' or '$sig->{entry_name}',
    it has to be set in single quotes ('/a path').
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub delete {
    my $config = shift;
    my $lname = $config->{'list'}{'special_name'};
    my $d = $config->{'list'}{'deprecate_bin'} / 86400;
    my $sig = $config->{'syntax'}{'sigil'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'delete'};
     <<EOT;

  gt --delete      delete entry from store
 ------------------------------------------

    Deletes a specified <dir> entry from all lists except the special lists $sig->{special_list}$lname->{all} and $sig->{special_list}$lname->{bin}.
    The entry will also moved be to the special list $sig->{special_list}$lname->{bin} and scrapped fully after $d days.
    This duration may be configured via the config entry: entry.deprecate_bin in goto_dir_config.yml.
    Use --move to undelete entries.

 USAGE:

  --delete  [<entryID>]      long command name
  --del  [<entryID>]         shorter alias
   -$sc\[<entryID>]             short alias


 EXAMPLES:

  --delete                   removing entry on default position ($config->{'entry'}{'position_default'}) of current list from all lists
  --del [$sig->{entry_position}]2                 delete second entry of current list
  --del idle$sig->{entry_position}-2              delete second last entry of list 'idle'
  --del good$sig->{entry_position}1..3            delete first, second and third entry of list named 'good'
  --del good$sig->{entry_position}..              delete all entries list 'good'
  --del $sig->{special_entry}new                 deleting a previosly created entry
   -$sc\[$sig->{entry_name}]fm$sig->{entry_name}pm                delete entry named 'fm' and entry named 'pm'

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --del[ete] required.
    Space before '$sig->{entry_position}', '$sig->{entry_name}' and after '-$sc' is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position can be negative, counting from the last position.
EOT
}
sub remove {
    my $config = shift;
    my $lname = $config->{'list'}{'special_name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'remove'};
    my $sig = $config->{'syntax'}{'sigil'};
    my $arg = "good$sig->{entry_name}ll";
    <<EOT;

  gt --remove      remove entry from list
 -----------------------------------------

    Removes one or more <dir> entries from a regular list.
    Special lists like $sig->{special_list}$lname->{new}, $sig->{special_list}$lname->{all}, $sig->{special_list}$lname->{stale} and $sig->{special_list}$lname->{bin} will not respond.

 USAGE:

  --remove  [<entryID>]      long command name
  --rm  [<entryID>]          shorter alias
   -$sc\[<entryID>]             short alias


 EXAMPLES:

  --remove                   remove entry on default position ($config->{'entry'}{'position_default'}) of current list
  --rm [$sig->{entry_position}]-1                 remove entry from last position of current list
  --rm good$sig->{entry_position}4                remove entry from fourth position of list named 'good'
  --rm good$sig->{entry_position}4..              remove entries from second to last position of list 'good'
  --rm good$sig->{entry_position}..               remove all entries from list named 'good'
  --rm $sig->{entry_name}ll $sig->{entry_name}gg               remove entries named 'll' and 'gg' from current list
   -$sc$arg$sig->{entry_name}gg              remove entries 'll' and 'gg' from list named 'good'

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --remove or --rm required.
    Space before '$sig->{entry_position}' or '$sig->{entry_name}' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub move {
    my $config = shift;
    my $lname = $config->{'list'}{'special_name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'move'};
    my $sig = $config->{'syntax'}{'sigil'};
    my $arg = "2$sig->{target_entry}-1";
    <<EOT;

  gt --move      move entry from one to another list
 ----------------------------------------------------

    Removes a specified entry from a list in any case and inserts it into another list.
    If source and target list are the same, it only changes it's position in list.
    Entries can not be moved into and out of the special lists like $sig->{special_list}$lname->{new} and $sig->{special_list}$lname->{all}.
    Only exception: they can be moved out of $sig->{special_list}$lname->{bin} to undelete entries.
    Use the command --delete to move an entry out of all regular lists into $sig->{special_list}$lname->{bin}.

 USAGE:

  --move  [<sourceID>] $sig->{target_entry} <targetID>    long command name
  --mv  [<sourceID>] $sig->{target_entry} <targetID>      shorter alias
   -$sc\[<sourceID>] $sig->{target_entry} <targetID>         short alias


 EXAMPLES:

  --move > idle$sig->{entry_position}3            move from default position ($config->{'entry'}{'position_default'}) of current list to third pos. of list 'idle'
   -$sc$arg                    move entry from second to last position in current list
  --mv good$sig->{entry_position}4 $sig->{target_entry} better$sig->{entry_position}2     move entry from fourth position of list 'good' to second pos. of 'better'
  --mv good$sig->{entry_position}..5 $sig->{target_entry} better$sig->{entry_position}2   move entries 1 to 5 of list 'good' to second pos. of 'better'
  --mv good$sig->{entry_position}.. $sig->{target_entry} better$sig->{entry_position}2    move all entries in list 'good' to second pos. of 'better'
  --mv rr $sig->{target_entry} good             move entry in current list named 'rr' to default position of list 'good'
  --mv meak$sig->{entry_name}rr $sig->{target_entry} great$sig->{entry_name}d     move entry 'rr' in list 'meak' to position of entry 'd' in list 'great'
  --move $sig->{special_entry}delete > great     undelete the most recently deleted entry and move it into list 'great'

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --move or --mv required.
    Space before '$sig->{entry_position}' or '$sig->{entry_name}', around '$sig->{target_entry}' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub copy {
    my $config = shift;
    my $lname = $config->{'list'}{'special_name'};
    my $sc = $config->{'syntax'}{'command_shortcut'}{'copy'};
    my $sig = $config->{'syntax'}{'sigil'};
    my $arg = "2$sig->{target_entry}-1";
    <<EOT;

  gt --copy      copy entry from one to another list
 ----------------------------------------------------

    Insert an entries into a regular list, but not a special list like $sig->{special_list}$lname->{new}, $sig->{special_list}$lname->{all} and $sig->{special_list}$lname->{bin}.
    If entry is already list element, the config key entry.prefer_in_dir_conflict
    in goto_dir_config.yml decides if new or old entry is kept.

 USAGE:

  --copy  [<sourceID>] $sig->{target_entry} <targetID>    long command name
  --cp  [<sourceID>] $sig->{target_entry} <targetID>      shorter alias
   -$sc\[<sourceID>] $sig->{target_entry} <targetID>         short alias


 EXAMPLES:

  --copy $sig->{target_entry} idle$sig->{entry_position}3            copy from default position ($config->{'entry'}{'position_default'}) of current list to third position of 'idle'
   -$sc$arg                    copy from second to last position in current list (produces dir_conflict!)
  --cp all$sig->{entry_position}4 $sig->{target_entry} better$sig->{entry_position}2      copy entry from fourth position of list 'all' to second pos. of 'better'
  --cp all$sig->{entry_position}..4 $sig->{target_entry} better$sig->{entry_position}2    copy first four entries of list 'all' to second pos. of 'better'
  --cp $sig->{special_list}stale$sig->{entry_position}.. $sig->{target_entry} weird     copy all entries of special list '$sig->{special_list}stale' to default position of 'weird'
  --cp $sig->{special_entry}move $sig->{target_entry} idle$sig->{entry_position}3        copy recently moved entry to third pos. of list 'idle'
  --cp rr $sig->{target_entry} good             copy entry named 'rr' (of any list) to default position of list 'good'
  --cp $sig->{entry_name}rr $sig->{target_entry} great$sig->{entry_name}d         copy entry 'rr' to position of entry 'd' in list 'great'

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --copy or --cp required.
    Space before '$sig->{entry_position}' or '$sig->{entry_name}', around '$sig->{target_entry}' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub name {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'name'};
    my $sig = $config->{'syntax'}{'sigil'};
    my $arg = "mi$sig->{entry_name}fa";
    <<EOT;

  gt --name      change entry name
 ----------------------------------

    Find a <dir> entry and change its unique name (applies to all entries holding same path).
    If <name> is omitted, it defaults to an empty string, which results in deleting the entry name.
    If <name> is already used by another entry, the config key entry.prefer_in_name_conflict in goto_dir_config.yml
    decides, if the new (this) or old (other) entry will keep it.

 USAGE:

  --name  [<entryID>] [$sig->{entry_name}<name>]    long command name
   -$sc\[<entryID>] [$sig->{entry_name}<name>]         short alias


 EXAMPLES:

  --name                     delete name of entry on default position ($config->{'entry'}{'position_default'}) of current list
  --name $sig->{entry_name}do                 set name of default entry to 'do'
  --name idle$sig->{entry_position}3$sig->{entry_name}re           give entry on third position of list 'idle' the name 're'
   -$sc$arg                   rename entry 'mi' to 'fa'
  --name sol                 delete name of entry 'sol'

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --name required.
    Space before '$sig->{entry_position}' or '$sig->{entry_name}' and after -$sc is optional.
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub dir {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'dir'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

  gt --dir      change dir path of entry
 ----------------------------------------

    Change <dir> of one or more entries. gt switches into <dir>, when entry is selected.
    If <dir> is already stored in any other entry, the config key entry.prefer_in_dir_conflict
    in goto_dir_config.yml decides, if this ('new') or  the other ('old') entry is kept.

 USAGE:

  --dir  [<entryID> | <old_dir> >>] <dir>    long command name
   -$sc\[<entryID> | <old_dir>>>]<dir>          short alias


 EXAMPLES:

  --dir ~/perl/project            set path of default entry ($config->{'entry'}{'position_default'}) in current list to '~/perl/project'
   -$sc/usr/temp                    change <dir> of default entry in current list to '/usr/temp'
  --dir $sig->{entry_name}sol /usr/bin             set path of entry named 'sol' to /usr/bin
  --dir idle$sig->{entry_position}3 /bin/da            set path of third entry in list 'idle' to /bin/da
  --dir /code/purl >> /code/perl  replace '/code/purl' with '/code/perl' in every entry <dir>

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --dir required.
    Space before '$sig->{entry_position}' or '$sig->{entry_name}', around '>>'  and after -$sc is optional.
    <dir> has to start with '/', '\\' or '~'. If <dir> contains space (' '), '$sig->{target_entry}' or '$sig->{entry_name}',
    it has to be set in single quotes ('/a path').
    Entry names are globally unique (over all lists). Like list names, they contain only
    word character (A-Z,a-z,0-9,_) and have to start with a letter.
    List position may be negative, counting from the last position.
EOT
}
sub edit {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'edit'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

  gt --edit      change landing script
 --------------------------------------

    Find an entry and change its <code> property - a snippet of perl code that is run,
    after switching into the entries <dir>. It's output will be displayed.

 USAGE:

  --edit  [<entryID>] '<code>'    long command name
   -$sc\[<entryID>] '<code>'         short alias


 EXAMPLES:

  --edit 'say "dance"'       set code of default entry ($config->{'entry'}{'position_default'}) in current list to 'say "dance"'
  --edit $sig->{entry_name}sol 'say "gg"'     set landing script code of entry bamed 'sol' to 'say "gg"'
  --edit idle$sig->{entry_position}3 'say f2()'   set code of third entry in list 'idle' to 'say f2()'
   -$sc\'say 99'                change <code> of default entry in current list to 'say 99'

    Space (' ') is after '$sig->{entry_position}' and '$sig->{entry_name}' not allowed, but after --path required.
    Space before '$sig->{entry_position}' or '$sig->{entry_name}' and after -$sc is optional.
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

 USAGE:

  --list  [<listname>]    long command name
   -$sc\[<listname>]         short alias


 EXAMPLES:

    gt --list a b         display list named 'a' and 'b' and set current list to 'b'

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

    Set the sorting criterion applied at the next use of --list (displays an entry list).
    After the list is displayed, the criterion switches back to default,
    unless the config key: list.sorted_by ($config->{list}{sorted_by}) is set to 'current'.
    The default criterion ($config->{list}{sort_default}) is set by the config key: list.sort_default.
    Calling --sort without an option also resets the criterion to default.
    Putting a '!' in front of the criterion means: reversed order.
    Every option has a short alias.

 USAGE:

   -$sc   --sort                  set to default criterion ($config->{list}{sort_default})
   -$sc$opt->{position}  --sort=position         obey user defined positional ordering of list
   -$sc$opt->{dir}  --sort=dir              alphanumeric ordering of directories
   -$sc$opt->{name}  --sort=name             alphanumeric ordering of entry names, unnamed last
   -$sc$opt->{visits}  --sort=visits           number of visits, most visited first
   -$sc$opt->{last_visit}  --sort=last_visit       time of last visit, the very last first
   -$sc$opt->{created}  --sort=created          time of creation, oldest first
   -$sc!$opt->{created} --sort=!created         time of creation, newest first
EOT

}
sub lspecial {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-special'};
    <<EOT;

  gt --list-special      all list names
 ---------------------------------------

    Display overview with all special entries and their directory.

 USAGE:

  --list-special    long command name
   -$sc             short alias
EOT
}
sub llists {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-lists'};
    <<EOT;

  gt --list-lists      all list names
 -------------------------------------

    Display overview with all list names. The special ones are marked with '$config->{syntax}{sigil}{special_list}' and their function.

 USAGE:

  --list-lists    long command name
   -$sc           short alias
EOT
}
sub ladd {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-add'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

  gt --list-add      create a list
 ----------------------------------

    Create a new empty regular list for path entries. It's mandatory <name> can't be taken by another list.
    It also needs a description text (in single quotes).

 USAGE:

  --list-add  <name> [$sig->{help}] <description>    long command name
   -$sc<name>[$sig->{help}]<description>             short alias


 EXAMPLES:

  --list-add  bear 'only the best entries'    creates a new list named 'bear'

    Space (' ') after --list-add is required, but after -$sc optional.
    List names have to be unique, contain only word character (A-Za-z0-9_) and start with a letter.
EOT
}
sub ldelete {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-delete'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

   gt --list-delete      remove an empty list
  --------------------------------------------

    Deletes an empty, not special (user created) list. There is no undelete, but --list-add.
    To emty a list use --move <name>$sig->{entry_position}.. $sig->{target_entry} <targetID> or --remove <name>$sig->{entry_position}.. (or --delete).

 USAGE:

  --list-delete  <name>    long command name
  --list-del  <name>       shorter alias
   -$sc<name>              short alias

    Space (' ') after --list-delete and --list-del is required, but after -$sc optional.
    List names have to be unique, contain only word character (A-Za-z0-9_) and start with a letter.
EOT
}
sub lname {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-name'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

  gt --list-name      rename a list
 -----------------------------------

    Change name of any list, even the special ones (start with $sig->{special_list}). Does not work when <newname> is taken.

 USAGE:

  --list-name  <oldname> : <newname>    long command name
   -$sc<oldname> : <newname>            short alias


    Space (' ') after --list-name is required, but after -$sc and around '$sig->{entry_name}' optional.
    List names have to be unique, contain only word character (A-Za-z0-9_) and start with a letter.
EOT
}
sub ldescription {
    my $config = shift;
    my $sc = $config->{'syntax'}{'command_shortcut'}{'list-description'};
    my $sig = $config->{'syntax'}{'sigil'};
    <<EOT;

  gt --list-description      change description of list
 -------------------------------------------------------

    Change description text of a list, even the special ones (start with $sig->{special_list}). Does not work when <newname> is taken.

 USAGE:

  --list-description  <name> [$sig->{help}] '<description>'    long command name
   -$sc<name>[$sig->{help}]'<description>'                     short alias


    Space (' ') after --list-name is required, but after -$sc and around '$sig->{help}' optional.
    List names have to be unique, contain only word character (A-Za-z0-9_) and start with a letter.
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

  --help=basics     -$sc$opt->{basics}        how to change directory, special lists and entries
  --help=commands   -$sc$opt->{commands}        list of all commands (cheat sheet)
  --help=install    -$sc$opt->{install}        how to install and maintain the program
  --help=settings   -$sc$opt->{settings}        how to configure the program

  --help <command>  -$sc<cmd>    detailed explanation of one <command> (e.g. --add)
                               command shortcut (<cmd>) may be used instead (e.g. -$config->{'syntax'}{'command_shortcut'}{'add'})
                               Space before <command> is needed, but not before <cmd>.
EOT
}

sub text {
    my ($config, $ID) = @_;
    (defined $ID and defined $text{$ID}) ? $text{$ID}( $config ) : overview( $config );
}

1;
