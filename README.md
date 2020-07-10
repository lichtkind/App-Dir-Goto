
# App-Goto-Dir

- - -

DISCLAIMER: not implemented are: create/delete/rename list, negative indicies

- - -

  Command line tool gt (short for goto) changes the working dir like cd.

  It remembers a set of directories you can address by number or name.

  &lt;pos&gt; stands for a position number and &lt;name&gt; for name 
  of dir entry. 

  &lt;p/n> means one of both (a path identifier). Dir's are organized in several lists.

  To optionally address a subdir just write &lt;p/n>/sub/dir.
  Use 'gt &lt;pos&gt;' or 'gt &lt;name&gt;' or just 'gt' to open interactive mode.
  There you type commands that will be completed by &lt;Enter&gt;.
  Command arguments can be separated by \[,:-&gt;] (mostly optional).
  Please press just &lt;Enter&gt; to exit the interactive mode.

In order to call this tool in your shell (e.g. under the command gt), you need to add an entry in you bashrc:

function gt() { perl ~/../../goto/goto.pl "$@" cd $(cat ~/../../goto/last_choice) }


All commands can be configured, these are my suggestions.
Square brackets embrace optional syntax parts.
In command mode the cursor is &gt; whereas in (managing) list mode &gt;&gt;.

## commands for managing list entries:
                
- `<pos>   .  .  .  .  .  .  .  go to directory listed on position (in [])`
- `:<name> .  .  .  .  .  .  go to dir listed under name (right beside <pos>)`
- `_    .  .  .  .  .  .  .  .  .  go to dir gone to last time`
- `a[<pos>[:<name>]]   .  add current dir on <pos> (default -1) as <name>`
- `d[<p/n>].   .  .  .  .  .  delete dir entry (default -1)`
- `n<pos>:<name> .  .  .  add Name to directory (max. 5 alphanumeric char.)`
- `n<p/n>.  .  .  .  .  .  .  delete dir entry name`
- `m<p/n>:<newpos>  .  . move dir to new position in same list`
- `m<p/n>:<ln>[:<np>].   move to pos <np> on diff. list named <ln>`
- `l .  .  .  .  .  .  .  .  .  display menu with of lists`
- `l:<command>   .  .  .  .  select which list to display or any command for list mode`
- `s:p|n|v .  .  .  .  .  .  sort list by Position (default), Name, Visit count,`
- `s:l|c|d .  .  .  .  .  .  by time of Last visit, time of Creation, Dir path`
- `< .  .  .  .  .  .  .  .  .  undo last command`
- `> .  .  .  .  .  .  .  .  .  redo - revert previously made undo`
- `h .  .  .  .  .  .  .  .  .  long help`
- `h:txt   .  .  .  .  .  .  .  overview text`
- `h:cmd   .  .  .  .  .  .  .  display list of commands`
- `<Enter> .  .  .  .  .  .  exit`

## commands for managing lists:

- `<pos>.  .  .  .  .  .  .  switch to dir list named on &lt;pos&gt;`
- `:<name>.   .  .  .  .  .  switch to dir list with &lt;name&gt;`
- `a <listname> .  .  . create a new list`
- `d <p/n>.   .  .  .  .  .  delete list (has to be empty)`
- `n <p/n>:<name>  .  . rename dir list`

