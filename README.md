# App-Dir-Goto

needs entry in you bashrc:

function gt() { perl ~/../../goto/goto.pl "$@" cd $(cat ~/../../goto/last_choice) }
