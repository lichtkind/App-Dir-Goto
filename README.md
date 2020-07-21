
# App-Goto-Dir

- - -

DISCLAIMER: program is in rebuild and does currently not work at all

- - -

  Command line tool gt (short for goto) changes the working dir like cd,
  to a set of stored locations you don't have to write as a full path.
  These dir's are organized by lists, and can be adressed via their
  list position (&lt;pos>), or an user given name (&lt;name>).
  &lt;ID> (identifier) means &lt;pos> or &lt;name>.

  To optionally address a subdir just write &lt;ID>/sub/dir.
  Use 'gt &lt;ID>' to switch dir or open the interactive mode via 'gt' and
  select the dir there. Both ways can also used to administer gt lists.

  For instance to add the dir \~/code/perl/goto under the name gd either
  write 'gt -add gd:\~/code/perl/goto' or open interactive mode vaia 'gt'
  and type '-add gd:\~/code/perl/goto' there. The output will be the same in both
  cases. Just press &lt;Enter> to exit the interactive mode.

  Every command has a long name and a configurable shortcut.
  It is usually the first letter of the full name. 
  Sorting criteria have shortcuts too.
  
  In order to makte gt operational, the shellrc have to contain the line:

  function gt() { perl ~/../goto.pl \$@ cd $\(cat ~/../last_choice) }

## syntax rules:


&lt;dir> means a valid directory (start with / or ~/), defaults to the directory gt is called from

&lt;name> name of an dir entry, only word character (\w), first character has to be a letter

&lt;lname> name of a list, defaults to current list when omitted

&lt;pos> list position, starts with 1, defaults to -1, negative position count from last &lt;pos>

&lt;ID> = &lt;name> or &lt;pos> or &lt;lname>:&lt;pos> (entry identifier)

: separates a value pair and should be omitted, when one value is omitted

&gt; separates two value pairs and when missing is assumed as if written after the command


## commands for changing directory:

- `<name>. . . . . . . . . go to dir with <name> (right beside <pos> in list)`
- `<pos> . . . . . . . . . go to dir listed on <pos> (in []) of current list`
- `<lname>:<pos> . . . . . go to directory at <pos> in list named <lname>`
- `<ID>/sub/dir. . . . . . go to subdirectory of a stored dir`
- `_  . . . . . . . . . . . go to dir gone to last time`
- `-  . . . . . . . . . . . go to dir gone previously (like cd-)`
- `<Enter> . . . . . . . .  exit interactive mode and stay in current dir`

## commands to display lists and help:
- `-list . . . . . . . . . display current list (not needed in interactive)`
- `-list <lname> . . . . . set <lname> as current list and display it`
- `-list <lpos>. . . . . . switch to list on <lpos> in the list of lists`
- `-list-list. . . . . . . display available list names (long for -l-l)`
- `-sort position. . . . . sort current list by position (default a.k.a. -sort)`
- `-sort name. . . . . . . change sorting criterion to <name> (long for -sn)`
- `-sort visits. . . . . . sort by number of times gone to dir (a.k.a. -sv)`
- `-sort last_visit. . . . sort by time of last visit (earlier first)`
- `-sort created . . . . . sort by time of dir entry creation (a.k.a -screated)`
- `-sort dir . . . . . . . sort by dir path (a.k.a. -sort:d)`
- `-help . . . . . . . . . long help = overview text + commands`
- `-help txt . . . . . . . overview text`
- `-help cmd . . . . . . . display list of commands`
- `-help <command> . . . . detailed help for one command`

## commands for managing list entries:

                
- `-add <name>:<dir> > <ID> . add <dir> under <name> on <pos> as defined by <ID>`
- `-del <ID>. . . . . . . . . delete directory entry as defined by <ID>`
- `-name <name> > <ID>. . . . (re-)name entry, resolve conflict like configured`
- `-name <ID> . . . . . . . . delete name of entry`
- `-move <IDa> > <IDb>. . . . move entry from a to b`
- `-copy  <IDa> > <IDb>. . . . copy entry a to position b`
- `<. . . . . . . . . . . . . undo last command`
- `>. . . . . . . . . . . . . redo - revert previously made undo`



## commands for managing lists:

- `-add-list <lname>. . . . . create a new list`
- `-del-list <ID> . . . . . .  delete list (has to be empty)`
- `-name-list <old> > <new> . rename list`


