use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Help;

sub text {
    my ($category, $name) = @_;

}

my %option = (
    oveview => <<EOT,
EOT

    usage => <<EOT,

   General usage of Goto Dir :
  ---------------------------

  Command line tool gt (short for goto) changes the working dir like cd,
  to a set of stored locations you don't have to write as a full path.
  These dir's are organized by lists, and can be adressed via their
  list position (<pos>), or with an user given short name (<name>).

  Use 'gt <ID>' to switch dir or open the interactive mode via 'gt' and
  select the dir then. Both ways can also be used to administer lists.
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

  In order to makte gt operational, add to the shellrc the following line:
  function gt() { perl ~/../goto.pl \\\$@ cd \$\\(cat ~/../last_choice) }

EOT
    commands => <<EOT,
  Long and short form commands of Goto Dir :
  ----------------------------------------

  --add <dir>[:<name>] [> <lpos>] add directory <dir> under <name> to a list (-a)
  --del[ete] [<ID>]               delete dir entry from all lists  (-d)
  --rem[ove] [<ID>]               remove dir entry from chosen lists (-r)
  --move [<IDa>] > <IDb>          move dir entry <IDa> to (position of) <IDb> (-m)
  --copy [<IDa>] > <IDb>          copy entry <IDa> to (position of) <IDb> (-c)
  --name [<ID>]:<name>            (re-, un-) name entry (-n)
  --path [<ID>] <dir>             change directory of entry  (-p)

  --sort=p|n|v|l|c|d              set sorting criterion of list display (-s)
  --list [<lname>]                change current list and display it (-l)
  --list-lists                    display available list names (long for -l-l)
  --list-add <lname>              create a new list (-l-a)
  --list-del <lname>              delete list of <lname> (has to be empty) (-l-d)
  --list-name <lID>:<lname>       rename list, conflicts not allowed (-l-n)

  --help[=c|s|u| <command>]       general or command specific help texts (-h)

For more detailed
EOT

    settings => <<EOT,
EOT

 );

my %command = (
    add => <<EOT,
EOT
);

say $option{commands};

1;


__END__
## syntax rules:

- `<dir> . . . directory path, starts with: \ / ~ , defaults to dir app is called from
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

file:
  data: places.yml
  backup: places.bak.yml
  return: last_choice
list:
  deprecate_new: 1209600
  deprecate_bin: 1209600
  start_with: current
  sorted_by: default
  default_name: use
  default_sort: position
  name:
    all: all
    bin: bin
    idle: idle
    new: new
    use: use
entry:
  max_name_length: 5
  position_of_new_entry: -1
  prefer_in_name_conflict: new
  prefer_in_dir_conflict: new
syntax:
  argument_separator: ',:-'
  command_shortcut:
    add: a
    copy: c
    delete: d
    move: m
    remove: r
    name : n
    path: p
    sort: s
    list: l
    help: h
    goto-last: '_'
    goto-previous: '-'
    undo: '<'
    redo: '>'
  option_shortcut:
    search:
      created: c
      dir: d
      last_visit: l
      position: p
      name: n
      visits: v
    help:
      all: a
      usage: u
      commands: c
      settings: s

