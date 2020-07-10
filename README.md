# App-Dir-Goto

DISCLAIMER: not implemented are: create/delete/rename list, negative indicies


  Command line tool gt (short for goto) changes the working dir like cd.
  It remembers a set of directories you can address by number or name.
  <pos> stands for a position number and <name> for name 
  of dir entry. <p/n> means one of both (a path identifier).
  To optionally address a subdir just write <p/n>/sub/dir.
  Use 'gt <pos>' or 'gt <name>' or just 'gt' to open interactive mode.
  There you type commands that will be completed by <Enter>.
  Command arguments can be separated by [,:->] (mostly optional).
  Please press just <Enter> to exit the interactive mode.

In order to call this tool in your shell (e.g. under the command gt),
you need to add an entry in you bashrc:

function gt() { perl ~/../../goto/goto.pl "$@" cd $(cat ~/../../goto/last_choice) }

  commands for managing list entries:
                
  <pos>              go to directory listed on position (in [])
  :<name>            go to dir listed under name (right beside <pos>)
  $command{'last'}                  go to dir gone to last time
  $command{'add'}\[<pos>\[:<name>\]\]  add current dir on <pos> (default -1) as <name>
  $command{'delete'}\[<p/n>\]           delete dir entry (default -1)
  $command{'name'}<pos>:<name>      add Name to directory (max. 5 alphanumeric char.)
  $command{'name'}<p/n>             delete dir entry name
  $command{'move'}<p/n>:<newpos>    move dir to new position in same list
  $command{'move'}<p/n>:<ln>\[:<np>\] move to pos <np> on diff. list named ln
  $command{'list'}                  display menu with of lists
  $command{'list'}:<listname>       select which list to display (current/archive)
  $command{'sort'}:p|n|v            sort list by Position (default), Name, Visit count,
  $command{'sort'}:l|c|d            by time of Last visit, time of Creation, Dir path
  $command{'undo'}                  undo last command
  $command{'redo'}                  redo - revert previously made undo
  $command{'help'}                  long help
  $command{'help'}:txt              overview text
  $command{'help'}:cmd              display list of commands
  <Enter>            exit

  commands for managing lists:

  <pos>              switch to dir list named on <pos>
  :<name>            switch to dir list with <name>
  $command{'add'}<listname>        create a new list
  $command{'delete'}<p/n>\             delete list (has to be empty)
  $command{'name'}<p/n>:<name>      rename dir list

