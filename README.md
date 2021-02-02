
# App-Goto-Dir

- - -

DISCLAIMER: program is in rebuild and does currently not work at all

- - -

  Command line tool gt (short for goto) changes the working dir like cd,
  to a set of stored locations you don't have to write as a full path.
  These dir's are organized by lists, and can be adressed via their
  list position (&lt;pos>), or with an user given short name (&lt;name>).
  &lt;ID> (dir entry identifier) means &lt;pos> or &lt;name>.

  Use 'gt &lt;ID>' to switch dir or open the interactive mode via 'gt' and
  select the dir then. Both ways can also be used to administer lists.
  Syntax and output of all commands will be the same and you can write
  several commands in sequence.

  For instance to add \~/code/perl/goto under the name "gg" do either type
  'gt -add \~/code/perl/goto:gg' or open interactive mode via 'gt'
  and write '-add \~/code/perl/goto:gg' there. Then just press &lt;Enter>
  again to exit the interactive mode.

  Every command has a long name and a configurable shortcut.
  It is usually the first letter of the full name.
  Our example : '-a\~/code/perl/goto:gg'.
  Parameters like sorting criteria have shortcuts too.

  In order to makte gt operational, add to the shellrc the following line:
  function gt() { perl ~/../goto.pl \$@ cd $\(cat ~/../last_choice) }

  Please check ~/../goto_dir_config.yml for further configuration options.


## syntax rules:

- `<dir> . . . directory path, starts with / or ~/, in quotes ('') when containing \W beside /,
 . . . . . . . . defaults to path (cwd) goto is called from`
- `<name>. . . name of an dir entry, (only word character \w), first char has to be a letter`
- `<lname> . . name of a list, defaults to current list when omitted`
- `<pos> . . . list position, first is 1, last is -1 (default), second last -2`
- `<lpos>. . . = <pos> or #<pos> or <lname>#<pos> position in list (default is current list)`
- `<ID>. . . . = <name> or :<name> or <lpos> (entry identifier)`
- `--. . . . . starting characters of any command in long form (--add)`
- `- . . . . . starting character of any command in short form (-add)`
- `# . . . . . (read number) separates <lname> and <pos> in full adress of an entry`
- `: . . . . . precedes, separates <name>,  (see -add, -name)`
- `> . . . . . separates a source (left) and its destination (right) (see -add, -move, -copy)`
- `<Space> . . ' ' has to separate long commands and data, is allowed around > and after :`

## commands for changing directory:

- `<name>. . . . . . . . . go to dir with <name> (right beside <pos> in list)`
- `<pos> . . . . . . . . . go to dir listed on <pos> (in []) of current list`
- `<lname>#<pos> . . . . . go to directory at <pos> in list <lname>`
- `<ID>/sub/dir. . . . . . go to subdirectory of a stored dir`
- `--last. . . . . . . . . go to dir gone to last time (in short: '_')`
- `--previous. . . . . . . go to dir gone previously (short '-', like cd-)`
- `<Enter> . . . . . . . .  exit interactive mode and stay in current dir`

## commands to display lists and help:

- `--list . . . . . . . . . display current list (not needed in interactive) (short -l)`
- `--list <lname> . . . . . set <lname> as current list and display it (-1)`
- `--list-lists . . . . . . display available list names (long for -l-l)`
- `--sort=position. . . . . sort displayed list by position (default) (-s, -sp)`
- `--sort=name. . . . . . . change sorting criterion to <name> (-sn)`
- `--sort=visits. . . . . . sort by number of times gone to dir (-sv)`
- `--sort=last_visit. . . . sort by time of last visit (earlier first, -sl)`
- `--sort=created . . . . . sort by time of dir entry creation (-sc)`
- `--sort=dir . . . . . . . sort by dir path (-sd, -sort=d)`
- `--help . . . . . . . . . long help = intro text + commands overview (-h)`
- `--help=usage . . . . . . intro text (short -hu)`
- `--help=commands. . . . . display list of commands (-hc)`
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

# planned features


