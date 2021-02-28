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
              'list-del' => 'list-delete',
            'list-descr' => 'list-description',
);
my %command = ('add' => [0, 0, 0, 0, 0], # i: 0 - option ; 1..n - arg required?
            'delete' => [0, 0],
          'undelete' => [0, 0],
            'remove' => [0, 0],
              'move' => [0, 0, 1],
              'copy' => [0, 0, 1],
              'name' => [0, 0, 0],
               'dir' => [0, 0, 1],
             'redir' => [0, 1, 1],
              'last' => [0],
          'previous' => [0],
              'help' => [3, 0],
              'sort' => [6],
              'list' => [0, 0],
          'list-add' => [0, 1],
       'list-delete' => [0, 1],
         'list-name' => [0, 1, 1],
  'list-description' => [0, 1, 1],
        'list-lists' => [0],
);
my %cmd_argument = ( 'add' => [qw/dir name list entry/],
                    delete => ['list', 'entry'],
                  undelete => ['source', 'target'],
                    remove => ['source'],
                      move => ['source', 'target'],
                      copy => ['source', 'target'],
                      name => ['source', 'name'],
                       dir => ['source', 'dir'],
                     redir => ['dir', '>>', 'dir'],
                    script => ['source', 'text'],
                      help => ['command'],
                'list-add' => ['name'],
             'list-delete' => ['name'],
               'list-name' => ['name', 'name'],
        'list-description' => ['name', 'text'],
);

my $sig = {                   short_command => '-',
                                 entry_name => ':',
                                       help => '?',
                                       file => '<',
                             entry_position => '^',
                               target_entry => '>',
                              special_entry => '+',
                               special_list => '@',
};

sub init {
    ($config, $data)  = @_;
    $sig = { map {$_ => quotemeta $config->{'syntax'}{'sigil'}{$_}} keys %{$config->{'syntax'}{'sigil'}}};
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
        my $short_cmd = substr($token,1,2);
        if (substr($token,0,1) eq $config->{'syntax'}{'sigil'}{'command'} and $short_cmd =~ /\w/){
            my $cmd = $App::Goto::Dir::Config::command_shortcut{ $short_cmd };
            if (length($token) > 3 and substr($token,2,1) eq '-'){
                my $lshort_cmd = substr($token,1,3);
                my $cmdl = $App::Goto::Dir::Config::command_shortcut{ $lshort_cmd };
                ($short_cmd, $cmd) = ($lshort_cmd, $cmdl) if defined $cmdl;

            }
            return " ! there is no command shortcut $config->{'syntax'}{'sigil'}{'command'}$short_cmd, please check --help=commands" unless defined $cmd;
            $token = "--$cmd".substr($token,2);
        }
        if ( substr($token,0,2) eq '--' ){
            # cut --
            # = opt
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

<pos>        = -?\d+
<name>       = [a-zA-Z]\w*
<text>       = '.*(?<!\\)'
<dir>        = [/\~][^$sig->{target_entry}$sig->{entry_name} ]*
<file>       = \S+|<text>
<ws>         = \s*

<list_name>  = $sig->{special_list}?<name>
<special>    = $sig->{special_entry}<name>
<entry_name> = (<list_name>?$sig->{entry_name})?<name>
<entry_pos>  = (<list_name>?$sig->{entry_position})?<pos>
<list_elems> = (sig->{entry_position}?<pos>)|(sig->{entry_position}?<pos>?..<pos>?)|($sig->{entry_name}?<name>)
<entry>      = (<special>|<entry_name>|<entry_pos>)?
<source>     = <entry>|(<list_name>?$sig->{entry_position})?<pos>?..<pos>?
<target>     = <entry>
<path>       = <entry>?(<text>|<dir>)


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
