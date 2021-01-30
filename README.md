
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
  Syntax and output of all commands will be the same.

  For instance to add \~/code/perl/goto under the name "gg" do either type
  'gt -add gg:\~/code/perl/goto' or open interactive mode via 'gt'
  and write '-add gd:\~/code/perl/goto' there. Then just press &lt;Enter>
  again to exit the interactive mode.

  Every command has a long name and a configurable shortcut.
  It is usually the first letter of the full name.
  Our example : '-agd:\~/code/perl/goto'.

  Sorting criteria have shortcuts too.

  In order to makte gt operational, add to the shellrc the following line:

  function gt() { perl ~/../goto.pl \$@ cd $\(cat ~/../last_choice) }

  Please check ~/../goto_dir_config.yml for further options.


## syntax rules:
`<dir> . . . directory path, starts with / or ~/, defaults to path goto is called from`

`<name>. . . name of an dir entry, [only word character (\w)], first char has to be a letter`

`<lname> . . name of a list, defaults to current list when omitted`

`<pos> . . . list position, first is 1, last is -1 (default)`

`<ID> . = <name> or <pos> or #<pos> or <lname>#<pos> (entry identifier)`

`- . . . . starting character of any command in long (-add) or short form (-a)`

`# . . . . (read number) separates &lt;lname> and &lt;pos> in full adress of an entry`

`: . . . . follows &lt;name>, to assign it to &lt;dir> (see -add, -name)`

`> . . . . separates an entry (left) and its destination (right) (see -add, -move, -copy)`

`<Space> &nbsp; &nbsp; has to separate long commands and data, is allowed around > and after :`


## commands for changing directory:
- `<name>. . . . . . . . . go to dir with <name> (right beside <pos> in list)`
- `<pos> . . . . . . . . . go to dir listed on <pos> (in []) of current list`
- `<lname>#<pos> . . . . . go to directory at <pos> in list <lname>`
- `<ID>/sub/dir. . . . . . go to subdirectory of a stored dir`
- `_  . . . . . . . . . . . go to dir gone to last time`
- `-  . . . . . . . . . . . go to dir gone previously (like cd-)`
- `<Enter> . . . . . . . .  exit interactive mode and stay in current dir`

## commands to display lists and help:

- `-list . . . . . . . . . display current list (not needed in interactive)`
- `-list <lname> . . . . . set <lname> as current list and display it`
- `-list <lpos>. . . . . . switch to list on <lpos> in the list of lists`
- `-list-list. . . . . . . display available list names (long for -l-l)`
- `-sort position. . . . . sort displayed list by position (default = -sort)`
- `-sort name. . . . . . . change sorting criterion to <name> (long for -sn)`
- `-sort visits. . . . . . sort by number of times gone to dir (a.k.a. -sv)`
- `-sort last_visit. . . . sort by time of last visit (earlier first, -sl)`
- `-sort created . . . . . sort by time of dir entry creation (a.k.a -sc)`
- `-sort dir . . . . . . . sort by dir path (a.k.a. -sort d)`
- `-help . . . . . . . . . long help = intro text + commands overview`
- `-help txt . . . . . . . intro text`
- `-help cmd . . . . . . . display list of commands`
- `-help <command> . . . . detailed help for one command`

## commands for managing list entries:

- `-add <name>:<dir> > <ID> . add <dir> under <name> on <pos> as defined by <ID>`
- `-del <ID>. . . . . . . . . delete directory entry as defined by <ID>`
- `-name <name>:<ID>. . . . . (re-)name entry, resolve conflict like configured`
- `-name <ID> . . . . . . . . delete name of entry`
- `-move <IDa> > <IDb>. . . . move entry a to position (of) b`
- `-copy  <IDa> > <IDb>. . . . copy entry a to position (of) b`
- `<. . . . . . . . . . . . . undo last command`
- `>. . . . . . . . . . . . . redo - revert previously made undo`

## commands for managing lists:

- `-add-list <lname>. . . . . create a new list`
- `-del-list <lID>. . . . . . delete list of <lname> or <lpos> (has to be empty)`
- `-name-list <lID>:<lname> . rename list, conflicts not allowed`
- `-list-list . . . . . . .  . <lname> and <lpos> of available lists (short -l-l)`


