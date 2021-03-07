use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Parse;

my ($config, $data);
my %command_tr = ( 'del' => 'delete',
                 'undel' => 'undelete',
                   'rem' => 'remove',
                    'rm' => 'remove',
                    'mv' => 'move',
                    'cp' => 'copy',
              'del-list' => 'delete-list',
            'descr-list' => 'describe-list',
);
my %command = ('add' => [0, 0, 0, 0, 0], # i: 0 - has option ;
            'delete' => [0, 0,       1], #    1 -s lurp arg
          'undelete' => [0, 0, 0,    0], #    2..n - arg required?
            'remove' => [0, 0,       1],
              'move' => [0, 0, 1,    0],
              'copy' => [0, 0, 1,    0],
              'name' => [0, 0, 0,    0],
            'script' => [0, 0, 1,    0],
               'dir' => [0, 0, 1,    0],
             'redir' => [0, 1, 0, 1, 0],
              'goto' => [0, 1,       0],
              'last' =>  0,
          'previous' =>  0,              # no args no options
              'help' => [3,         -1],
              'sort' => [6],             # no args, just 6 options
              'list' => [0, 0,       1],
          'add-list' => [0, 1,       0],
       'delete-list' => [0, 1,       0],
         'name-list' => [0, 1, 1,    0],
     'describe-list' => [0, 1, 1,    0],
        'list-lists' =>  0,
      'list-special' =>  0,
);
my %command_argument = ( 'add' => [qw/path entry_name reg_target/],
                        delete => ['source', 'list_target'],
                      undelete => ['list_elems', 'reg_target'],
                        remove => ['source'],
                          move => ['source', 'target'],
                          copy => ['entry',  'reg_target'],
                          name => ['source', 'entry_name'],
                           dir => ['source', 'path'],
                         redir => ['path', '<<', 'path'],
                        script => ['source', 'text'],
                          help => ['command'],
                    'add-list' => ['list_name'],
                 'delete-list' => ['list_name'],
                   'name-list' => ['list_name', 'list_name'],
               'describe-list' => ['list_name', 'text'],
);

my $sig = { short_command => '-', entry_name => ':',
                     help => '?', entry_position => '^',
                     file => '<', special_entry => '+', special_list => '@', };
my $ws    = '\s*';
my $pos   = '-?\d+';
my $name  = '[a-zA-Z]\w*';

my $text  = '\'(?<text_content>.*(?<!\\))\'';
my $dir   = '(?<dir>[/\~][^'.$sig->{entry_name}.' ]*)';
my $file  = '(?:'.$sig->{file}.'?'.$dir.'|'.$sig->{'file'}.$text.')';
my $list_name       = '(?:(?<special_list>'.$sig->{'special_list'}.')?(?<listname>'.$name.'))';
my $entry_name      = '(?:'.$sig->{'entry_name'}.'(?<entry_name>'.$name.'))';
my $reg_list_name   = '(?<list_name>'.$name.')';
my $special_entry   = '(?:'.$sig->{special_entry}.'(?<special>$name))';
my $entry_name_adr  = '(?:(?:'.$list_name.'?'.$sig->{entry_name}.')?(?<entry_name>'.$name.'))';
my $entry_pos_adr   = '(?:(?:'.$list_name.'?'.$sig->{entry_position}.')?(?<entry_pos>'.$pos.'))';
my $entry_pos_group = '';
my $reg_name_adr    = '(?:(?:'.$reg_list_name.'?'.$sig->{entry_name}.')?(?<entry_name>'.$name.'))';
my $reg_pos_adr     = '(?:(?:'.$reg_list_name.'?'.$sig->{entry_position}.')?(?<entrypos>'.$pos.'))';
my $reg_pos_group   = '';
my $reg_target      = $reg_name_adr.'|'.$reg_pos_adr;
my $list_target     = '';

my $list_elem = "(?:$sig->{entry_position}?$pos)|(?:$sig->{entry_name}?$name)";
my $list_elems = "(?:$sig->{entry_position}?$pos)|(?:$sig->{entry_position}?(?:$pos)?..(?:$pos)?)|(?:$sig->{entry_name}?$name)";
my $entry      = '(?:'.$special_entry.'|'.$entry_name_adr.'|'.$entry_pos_adr.')'; # any entries
my $source     = "(?:(?:$special_entry)|(?:$entry_name_adr)|(?:$entry_pos_adr)|(?:  (?:$list_name?$sig->{entry_position})?$pos?..$pos)?  ))"; # one or more el of normal list
my $target     = '|'; #one full addr
my $path       = $entry.'?(?:'.$text.'|'.$dir.')';
my $command    = '';

sub init {
    ($config, $data)  = @_;
    $sig = { map {$_ => quotemeta $config->{'syntax'}{'sigil'}{$_}} keys %{$config->{'syntax'}{'sigil'}}};
    say $sig->{entry_name};
    say $entry_name;
    say ":der" =~ $entry_name;
    say defined $+{entry_name};
}

sub is_dir {
    my ($dir) = @_;
    return 0 unless defined $dir and $dir;
    substr($dir, 0, 1) =~ m|[/\\~]|;
}
sub is_name {
    my ($name) = @_;
    return 0 unless defined $name and $name;
    return 0 if $name =~ /\W/;
    return 0 if substr($name,0,1) =~ /[\d_]/;
    1;
}
sub is_position { defined $_[0] and $_[0] =~ /^-?+\d$/ }

sub eval_command {
    my (@token) = @_;
    my @comands = ();
    for my $token (@token){
        my $cmd;
        if (length $token == 1){
            if ($token =~ /\W/){
                (push @comands, ['last']   ), next if $token eq $config->{'syntax'}{'special_entry'}{'last'};
                (push @comands, ['previous']),next if $token eq $config->{'syntax'}{'special_entry'}{'previous'};
                return " ! there is no special shortcut named '$token'" unless defined $cmd;
            }
        }
        (push @comands, ['goto-pos', $data->get_current_list_name, $token]),        next if is_position( $token);
        (push @comands, ['goto-name',$data->get_special_list_names('all'), $token]),next if is_name( $token);
        my $short_cmd = substr($token, 1, 1);
        if (substr($token,0,1) eq $config->{'syntax'}{'sigil'}{'command'} and $short_cmd =~ /\w/){
            my $cmd = $App::Goto::Dir::Config::command_shortcut{ $short_cmd };
            if (length($token) > 3 and substr($token, 2,1) eq '-'){
                my $lshort_cmd = substr($token,1,3);
                my $cmdl = $App::Goto::Dir::Config::command_shortcut{ $lshort_cmd };
                ($short_cmd, $cmd) = ($lshort_cmd, $cmdl) if defined $cmdl;
            }
            return " ! there is no command shortcut $config->{'syntax'}{'sigil'}{'command'}$short_cmd, please check --help=commands or -hc" unless defined $cmd;
            if (exists $config->{'syntax'}{'option_shortcut'}{$cmd} and length $token > length($short_cmd) + 1) {
                my $opt = substr( (length($short_cmd) + 1), 1);
                return " ! command shortcut $config->{'syntax'}{'sigil'}{'command'}$short_cmd ($cmd) has not option, please check --help $config->{'syntax'}{'sigil'}{'command'}$short_cmd "
                    unless defined $App::Goto::Dir::Config::option_shortcut{$cmd}{$opt};
                $token = "--$cmd=$opt";
            }
            unshift @token, substr($token, 2);
            $token = "--$cmd";
        }
        if ( substr($token,0,2) eq '--' ){
            my $cmd_name = substr $token, 2;
            my @opt = split '=', $cmd_name;
            if (@opt > 1){
                $opt[0] = $command_tr{ $opt[0] } if exists $command_tr{ $opt[0] };
                return " ! there is no command '$opt[0]', please check --help=commands or -hc" unless exists $command{ $opt[0] };
                return " ! only one command option (--command=option) is allowed" if @opt > 2;
                return " ! command '$opt[0]' has no options" unless exists $config->{'syntax'}{'option_shortcut'}{$opt[0]};
                return " ! command '$opt[0]' has no option '$opt[1]' (partial optio names allowed if they identify option)"
                    unless exists $App::Goto::Dir::Config::option_name{$opt[0]}{$opt[1]};
                $opt[1] = $App::Goto::Dir::Config::option_name{$opt[0]}{$opt[1]};
                push @comands, \@opt;
                # exception help with cmd args
                next;
            }
            $cmd_name = $command_tr{$cmd_name} if exists $command_tr{$cmd_name};
            return " ! there is no command '$cmd', please check --help=commands or -hc" unless exists $command{$cmd_name};

            # double name (ltm)
            # parse args
        } else {
            # compound adress
            # split on : -> call with list name if name
            # split on ^ -> call with list name if name
            # error
        }
        #push @comands, $cmd;
    }
    #my @cmd = split  "-", join ' ', @parts;
    \@comands;
}

sub run_command {

}

1;

__END__

|goto-last|      = $spec->{last}
|goto-previous|  = $spec->{previous}
|goto|           = <entry>
|add|            = <path>?<ws><name><ws>$sig->{target_entry}<ws><target>
|delete|         = <source>
|undelete|       = <list_elems><ws>$sig->{target_entry}<ws><target>
|remove|         = <source>
|move|           = <source><ws>$sig->{target_entry}<ws><target>
|copy|           = <source><ws>$sig->{target_entry}<ws><target>
|redir|          = <path><ws>>><ws><path>
|dir|            = <target><ws>(<dir>|<text>)
|name|           = <target><ws>($sig->{entry_name}<name>)?
|script|         = <target><ws>(<text>|$sig->{file}<file>)
|help|           = (=opt|@cmd)?
|sort|           = (=opt|sopt)?
|list|           = <list_name>+
|list-special|   = //
|list-lists|     = //
|list-add|       = <name> <ws>$sig->{target_entry}<text>
|list-delete|    = <name>
|list-name|      = <list_name><ws>[ $sig->{entry_name}]<list_name>
|list-description| = <list_name><ws><text>

$fmt1 = '(?<y>\d\d\d\d)-(?<m>\d\d)-(?<d>\d\d)';
$fmt2 = '(?<m>\d\d)/(?<d>\d\d)/(?<y>\d\d\d\d)';
$fmt3 = '(?<d>\d\d)\.(?<m>\d\d)\.(?<y>\d\d\d\d)';
for my $d (qw(2006-10-21 15.01.2007 10/31/2005)) {
    if ( $d =~ m{$fmt1|$fmt2|$fmt3} ){
        print "day=$+{d} month=$+{m} year=$+{y}\n";
    }
}  $+[n]
