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
            'delete' => [0, 0,       1], #    1 - n-1 arg required?
          'undelete' => [0, 0, 0,    0], #    n - last arg is slurp
            'remove' => [0, 0,       1],
              'move' => [0, 0, 1,    0],
              'copy' => [0, 0, 1,    0],
              'name' => [0, 0, 0,    0],
            'script' => [0, 0, 1,    0],
               'dir' => [0, 0, 1,    0],
             'redir' => [0, 1, 0, 1, 0],
              'goto' => [0, 1,       0],
              'help' => [3, 0       -1],
              'sort' => [6],             # no args, just 6 options
              'list' => [0, 0,       1],
        'list-lists' =>  0,
      'list-special' =>  0,
          'add-list' => [0, 1,       0],
       'delete-list' => [0, 1,       0],
         'name-list' => [0, 1, 1,    0],
     'describe-list' => [0, 1, 1,    0],
);
my %command_argument = ( 'add' => [qw/path entry_name target/],
                        delete => ['source'],
                      undelete => ['list_elems', 'reg_target'],
                        remove => ['reg_source'],
                          move => ['reg_source', 'target'],
                          copy => ['source',  'reg_target'],
                          name => ['entry', 'named_entry'],
                           dir => ['entry', 'path'],
                         redir => ['path', '<<', 'path'],
                        script => ['entry', 'text'],
                          help => ['command'],
                    'add-list' => ['list_name'],
                 'delete-list' => ['list_name'],
                   'name-list' => ['list_name', 'list_name'],
               'describe-list' => ['list_name', 'text'],
);

my $sig = { short_command => '-', entry_name => ':',
                     help => '?', entry_position => '^',
                     file => '<', special_entry => '+', special_list => '@', };
my $rule = {
    ws    => '\s*',
    pos   => '-?\d+',
    name  => '[a-zA-Z]\w*',
    text  => '\'(?<text_content>.*(?<!\\))\'',
};

sub init {
    ($config, $data)  = @_;
    $sig = { map {$_ => quotemeta $config->{'syntax'}{'sigil'}{$_}} keys %{$config->{'syntax'}{'sigil'}}};
    my $slist_name = $config->{'list'}{'special_name'};
    my @cmd = (keys %command, keys %command_tr);
    $rule->{'dir'}              = '(?<dir>[/\\\~]\S*)';
    $rule->{'file'}             = '(?:'.$sig->{file}.'?'.$rule->{dir}.'|'.$sig->{file}.$rule->{text}.')';

    $rule->{'reg_list_name'}    = '(?<list_name>'.$rule->{name}.')';
    $rule->{'list_name'}        = '(?:(?<special_list>'.$sig->{special_list}.')?'.$rule->{reg_list_name}.')';
    $rule->{'entry_name'}       = '(?<entry_name>'.$rule->{name}.')';
    $rule->{'entry_pos'}        = '(?<entry_pos>'.$rule->{pos}.')';
    $rule->{'named_entry'}      = '(?:'.$sig->{entry_name}.$rule->{entry_name}.')';
    $rule->{'special_entry'}    = '(?:'.$sig->{special_entry}.'(?<special>'.$rule->{name}.'))';
    $rule->{'name_group'}       = '(?<name_group>(?:'.$sig->{entry_name}.$rule->{name}.')+)';
    $rule->{'pos_group'}        = '(?:(?<start_pos>'.$rule->{pos}.')?\.\.(?<end_pos>'.$rule->{pos}.'))';

    $rule->{'entry_name_adr'}   = '(?:(?:'.$rule->{list_name}.'?'.$sig->{entry_name}.')?'.$rule->{entry_name}.')';
    $rule->{'entry_pos_adr'}    = '(?:(?:'.$rule->{list_name}.'?'.$sig->{entry_position}.')?'.$rule->{entry_pos}.')';
    $rule->{'entry_name_group'} = '(?:'.$rule->{list_name}.'?'.$rule->{name_group}.')';
    $rule->{'entry_pos_group'}  = '(?:(?:'.$rule->{list_name}.'?'.$sig->{entry_position}.')?'.$rule->{pos_group}.')';
    $rule->{'entry'}            = '(?:'.$rule->{special_entry}.'|'.$rule->{entry_name_adr}.'|'.$rule->{entry_pos_adr}.')'; # any single entry
    $rule->{'reg_name_adr'}     = '(?:(?:'.$rule->{reg_list_name}.'?'.$sig->{entry_name}.')?'.$rule->{entry_name}.')';
    $rule->{'reg_pos_adr'}      = '(?:(?:'.$rule->{reg_list_name}.'?'.$sig->{entry_position}.')?'.$rule->{entry_pos}.')';
    $rule->{'reg_name_group'}   = '(?:(?:'.$rule->{reg_list_name}.'?'.$rule->{name_group}.')';
    $rule->{'reg_pos_group'}    = '(?:(?:'.$rule->{reg_list_name}.'?'.$sig->{entry_position}.')?'.$rule->{pos_group}.')';

    $rule->{'list_elem'}        = '(?:'.$sig->{entry_position}.'?'.$rule->{entry_pos}.'|'.$sig->{entry_name}.'?'.$rule->{entry_name}.')';
    $rule->{'list_elems'}       = '(?:'.$rule->{list_elem}.'|'.$sig->{entry_position}.'?'.$rule->{pos_group}.'|'.$rule->{name_group}.')';
    $rule->{'reg_source'}       = $rule->{reg_name_adr}.'|'.$rule->{reg_pos_adr}.'|'.$rule->{reg_name_group}.'|'.$rule->{reg_pos_group};
    $rule->{'reg_target'}       = $rule->{reg_name_adr}.'|'.$rule->{reg_pos_adr};
    $rule->{'source'}           = $rule->{entry_name_adr}.'|'.$rule->{entry_pos_adr}.'|'.$rule->{entry_name_group}.'|'.$rule->{entry_pos_group};
    $rule->{'target'}           = $rule->{entry_name_adr}.'|'.$rule->{entry_pos_adr};
    $rule->{'path'}             = $rule->{entry}.'?(?:'.$rule->{text}.'|'.$rule->{dir}.')';
    $rule->{'command'}          = '(?:--)?(?:'.(join '|',@cmd).')';

    # $config->{'list'}{'special_name'}{'all'}
    #say $sig->{entry_name};
    #say $rule->{entry_name};
    #say ":der" =~ $rule->{entry_name};
    #say $1;
#    say '\\';
#    say '~' =~ $rule->{'dir'};
#    say defined $+{entry_name};
}

sub is_dir      { defined $_[0] and $_[0] =~ '^'.$rule->{'dir'}.'$' }
sub is_name     { defined $_[0] and $_[0] =~ '^'.$rule->{'name'}.'$' }
sub is_position { defined $_[0] and $_[0] =~ '^'.$rule->{'pos'}.'$' }

sub eval_args {
    my (@token) = @_;
    my @comands = ();
    my $sig = $config->{'syntax'}{'sigil'};
    for my $token (@token){
        my $cmd;
        if (length $token == 1){
            if ($token =~ /\W/){
                (push @comands, ['goto', $sig->{'special_entry'}.'last']),next if $token eq $config->{'syntax'}{'special_entry'}{'last'};
                (push @comands, ['goto', $sig->{'special_entry'}.'prev']),next if $token eq $config->{'syntax'}{'special_entry'}{'previous'};
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
            if      ($cmd eq 'add'){
            } elsif ($cmd eq 'delete'){
            } elsif ($cmd eq 'undelete'){
            } elsif ($cmd eq 'remove'){
            } elsif ($cmd eq 'move'){
            } elsif ($cmd eq 'copy'){
            } elsif ($cmd eq 'name'){
            } elsif ($cmd eq 'dir'){
            } elsif ($cmd eq 'redir'){
            } elsif ($cmd eq 'help'){
            } elsif ($cmd eq 'sort'){
            } elsif ($cmd eq 'list'){
            } elsif ($cmd eq 'list-special'){
            } elsif ($cmd eq 'list-lists'){
            } elsif ($cmd eq 'add-list'){
            } elsif ($cmd eq 'delete-list'){
            } elsif ($cmd eq 'name-list'){
            } elsif ($cmd eq 'describe-list'){
            }
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

