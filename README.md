# App-Dir-Goto

DISCLAIMER: not implemented are: create/delete/rename list, negative indicies


  Command line tool gt (short for goto) changes the working dir like cd.
  It remembers a set of directories you can address by number or name.

  &lt;pos> stands for a position number and &lt;name&gt; for name 
  of dir entry. &lt;p/n> means one of both (a path identifier).

  To optionally address a subdir just write &lt;p/n>/sub/dir.
  Use 'gt &lt;pos&gt;' or 'gt &lt;name&gt;' or just 'gt' to open interactive mode.
  There you type commands that will be completed by &lt;Enter&gt;.
  Command arguments can be separated by [,:-&gt;] (mostly optional).
  Please press just &lt;Enter&gt; to exit the interactive mode.

- - -

In order to call this tool in your shell (e.g. under the command gt), you need to add an entry in you bashrc:

function gt() { perl ~/../../goto/goto.pl "$@" cd $(cat ~/../../goto/last_choice) }

- - -

All commands can be configured, these are my suggestions.


## commands for managing list entries:
                
- &lt;pos&gt; ............ go to directory listed on position (in [])
- : &lt;name &gt; .......... go to dir listed under name (right beside <pos>)
- _ ................ go to dir gone to last time
- a[&lt;pos&gt;[:&lt;name&gt;]]. add current dir on <pos> (default -1) as <name>
- d[&lt;p/n&gt;] ......... delete dir entry (default -1)
- n&lt;pos&gt;:&lt;name&gt; .... add Name to directory (max. 5 alphanumeric char.)
- n&lt;p/n&gt; ........... delete dir entry name
- m&lt;p/n&gt;:&lt;newpos&gt; .. move dir to new position in same list
- m&lt;p/n&gt;:&lt;ln&gt;[:<np&gt;] move to pos <np> on diff. list named ln
- l ................ display menu with of lists
- l:&lt;listname&gt; ..... select which list to display (current/archive)
- s:p|n|v .......... sort list by Position (default), Name, Visit count,
- s:l|c|d .......... by time of Last visit, time of Creation, Dir path
- &lt; ................ undo last command
- &gt; ................ redo - revert previously made undo
- h ................ long help
- h:txt ............ overview text
- h:cmd ............ display list of commands
-  &lt;Enter&gt; .......... exit

## commands for managing lists:

-  &lt;pos&gt; ............ switch to dir list named on <pos>
- : &lt;name&gt; .......... switch to dir list with <name>
- a &lt;listname&gt; ...... create a new list
- d &lt;p/n &gt; ........... delete list (has to be empty)
- n &lt;p/n &gt;:&lt;name&gt; .... rename dir list

