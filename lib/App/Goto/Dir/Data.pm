use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use YAML;
use File::Spec;
use App::Goto::Dir::Data::List;

package App::Goto::Dir::Data;

#### de- constructors ##################################################
sub new {
    my ($pkg, $config) = @_;
    return unless ref $config eq 'HASH';
    my $file = $config->{'file'}{'data'};
    my $sls = $config->{'syntax'}{'sigil'}{'special_list'};
    my %sl_name = map { $_ => $sls.$config->{'list'}{'special_name'}{$_} } keys %{$config->{'list'}{'special_name'}};
    my %sl_desc = map { $sl_name{$_} => $config->{'list'}{'special_description'}{$_}} keys %sl_name;
    my $data = (-r $file) ? YAML::LoadFile($file)
                          : { list => { description => [%sl_desc, 'use'=> 'projects currently worked on', 'idle'=> 'dormant or put back projects'],
                                        current => 'use', sorted_by => 'position', } , entry => [],
                              visits => {last_dir => '',last_subdir => '', previous_dir => '', previous_subdir => ''},  history => [0],  };

    $data->{'entry'} = [ grep { $_->overdue() < $config->{'list'}{'deprecate_bin'} } # scrap long deleted
                         map  { App::Goto::Dir::Data::Entry->restate($_)           } @{ $data->{'entry'} }  ];

    map { $_->add_to_list( $sl_name{'stale'}, -1 ) unless $_->get_list_pos( $sl_name{'stale'}) or -d $_->full_dir } @{ $data->{'entry'} };
    map { $_->remove_from_list( $sl_name{'stale'} ) if $_->get_list_pos( $sl_name{'stale'}) and -d $_->full_dir } @{ $data->{'entry'} };
    map { $_->remove_from_list( $sl_name{'new'} ) if $_->age() > $config->{'list'}{'deprecate_new'} } @{ $data->{'entry'} };

    my %sln_tr; # special list name translator
    for my $list_name (keys %{$data->{'list'}{'description'}}){
        next if substr($list_name, 0, 1) =~ /\w/ or substr($list_name, 0, 1) eq $sls;
        my $new_name = $sls . substr($list_name, 1);
        $data->{'list'}{'description'}{$new_name} = $data->{'list'}{'description'}{$list_name};
        delete $data->{'list'}{'description'}{$list_name};
        $sln_tr{ $list_name } = $new_name;
    }

    my %list;
    for my $entry (@{ $data->{'entry'}}){
        for my $list_name ($entry->member_of_lists) {
            if (exists $sln_tr{$list_name}){
                $list{ $sln_tr{ $list_name } }[ $entry->get_list_pos($list_name) ] = $entry;
                $entry->remove_from_list($list_name);
            } else {
                $list{$list_name}[ $entry->get_list_pos($list_name) ] = $entry;
            }
        }
    }

    for my $list_name (keys %list) { # create lists with entries
        new_list( $data, $list_name, $data->{'list'}{'description'}{$list_name}, $config->{'entry'}, grep {ref $_} @{$list{$list_name}} );
    }
    for my $list_name (values %sl_name, keys %{$data->{'list'}{'description'}}) { # create empty lists too
        next if exists $data->{'list_object'}{ $list_name };
        new_list( $data, $list_name, $data->{'list'}{'description'}{$list_name}, $config->{'entry'} );
    }
    $data->{'special_list'} = \%sl_name;
    $data->{'config'} = $config;
    bless $data;
}

sub write {
    my ($self, $config) = @_;
    my $state                = { map { $_ => $self->{$_}} qw/visits list/ }; # history ?
    $state->{'entry'}         = [ map { $_->state } $self->get_special_lists('all')->all_entries ];
    $state->{'list'}{'description'} = { map {$_->get_name => $_->get_description} values %{ $self->{'list_object'} } };
    $state->{'list'}{'current'} = $config->{'list'}{'default_name'} if  $config->{'list'}{'start_with'} eq 'default';

    rename $config->{'file'}{'data'}, $config->{'file'}{'backup'};
    YAML::DumpFile( $config->{'file'}{'data'}, $state );
    open my $FH, '>', $config->{'file'}{'return'};
    print $FH File::Spec->catdir( $self->{'visits'}{'last_dir'}, $self->{'visits'}{'last_subdir'});
}

#### list API ###########################################################
sub new_list {
    my ($self, $list_name, $description, $config, @elems) = @_;
    $self->{'list_object'}{ $list_name } = App::Goto::Dir::Data::List->new( $list_name, $description, $config, @elems );
}
sub remove_list           { delete $_[0]->{'list_object'}{ $_[1] }                          }
sub get_list              { $_[0]->{'list_object'}{$_[1]} if exists $_[0]->{'list_object'}{$_[1]} }
sub list_exists           { defined $_[1] and exists $_[0]->{'list_object'}{$_[1]}          }
sub change_list_name      {
    my ($self, $old_name, $new_name) =  @_;
    return unless $self->list_exists( $old_name ) and not $self->list_exists( $new_name );
    my $list = $self->{'list_object'}{$new_name} = delete $self->{'list_object'}{$old_name};
    $list->set_name( $new_name );
}
sub change_current_list   { $_[0]->{'list'}{'current'} = $_[1] if exists $_[0]->{'list_object'}{$_[1]} }
sub get_current_list      {        $_[0]->{'list_object'}{ $_[0]->{'list'}{'current'} }     }
sub get_current_list_name {                                $_[0]->{'list'}{'current'}       }
sub get_all_list_name     { keys %{$_[0]->{'list_object'}}                                  }
sub get_special_lists     { my $self = shift; @{ $self->{'list_object'}}{ $self->get_special_list_names(@_) } if @_}
sub get_special_list_names{ my $self = shift; @{ $self->{'special_list'}}{ @_ }                }

#### entry API #########################################################
sub add_entry {
    my ($self, $dir, $name, $list_name, $list_pos) = @_;
    return 'Data::new_entry misses first required argument: a valid path' unless defined $dir;
    return "entry name name $name is too long, max chars are ".$self->{'config'}{'entry'}{'name_length_max'}
        if defined $name and length($name) > $self->{'config'}{'entry'}{'name_length_max'};
    $list_name //= $self->get_current_list_name;
    return "entry list with name '$list_name' does not exist" unless $self->list_exists( $list_name );
    my $entry = App::Goto::Dir::Data::Entry->new($dir, $name);
    my $list  = $self->get_list( $list_name );
    my ($all_entry, $new_entry) = $self->get_special_lists('all', 'new');
    my $ret = $all_entry->insert_entry( $entry, $list eq $all_entry ? $list_pos : undef ); # sorting out names too
    return $ret unless ref $ret; # return error msg: could not inserted because not allowed overwrite entry with same dir
    $new_entry->insert_entry( $entry, $list eq $new_entry ? $list_pos : undef );
    $list->insert_entry( $entry, $list_pos ) unless $list eq $all_entry or $list eq $new_entry;
    $entry;
}

sub delete_entry { # remove from all lists (-all) & move to bin
    my ($self, $list_name, $entry_ID) = @_;
    my ($entry, $list) = $self->get_entry( $entry_ID );
    return $entry unless ref $entry;
    my ($all_list, $bin_list) = $self->get_special_lists('all', 'bin');
    for my $list (values %{$self->{'list_object'}}) {
        next if $list eq $all_list or $list eq $bin_list;
        $list->remove_entry( $entry );
    }
    unless ($entry->overdue()){
        $entry->delete();
        $bin_list->insert_entry( $entry );
    }
    $entry;
}

sub remove_entry { # from one list
    my ($self, $list_name, $entry_ID) = @_;
    my ($entry, $list) = $self->get_entry( $entry_ID );
    return $entry unless ref $entry;
    return "can not remove entries from special lists: new, bin and all" if $list_name ~~ [$self->get_special_list_names(qw/new bin all/)];
    $list->remove_entry( $entry_ID );
}

sub move_entry {
    my ($self, $from_list_name, $from_ID, $to_list_name, $to_ID) = @_;
    return "missing source ID of entry to move" unless defined $from_ID;
    $from_list_name //= $self->get_current_list_name;
    $to_list_name //= $self->get_current_list_name;
    my ($from_list, $to_list)  = @{$self->{'list_object'}}{ $from_list_name, $to_list_name };
    return "unknown source list name: $from_list_name" unless ref $from_list;
    return "unknown target list name: $to_list_name" unless ref $to_list;
    if ($from_list_name eq $to_list_name) {
        return $from_list->move_entry( $from_ID, $to_ID)
    } else {
       return "can not move entries from special lists: new, bin and all" if $from_list_name ~~ [$self->get_special_list_names(qw/new all/)];
       return "can not move entries to special lists: new, bin and all" if $to_list_name ~~ [$self->get_special_list_names(qw/new bin all/)];
    }
    my $entry = $from_list->remove_entry( $from_ID );
    $entry->undelete();
    return $entry unless ref $entry;
    $to_list->insert_entry( $entry, $to_ID );
}

sub copy_entry {
    my ($self, $from_list_name, $from_ID, $to_list_name, $to_ID) = @_;
    return "missing source ID of entry to move" unless defined $from_ID;
    $from_list_name //= $self->get_current_list_name;
    $to_list_name //= $self->get_current_list_name;
    my ($from_list, $to_list)  = @{$self->{'list_object'}}{ $from_list_name, $to_list_name };
    return "unknown source list name: $from_list_name" unless ref $from_list;
    return "unknown target list name: $to_list_name" unless ref $to_list;
    return "can not copy entries to special lists: new, bin and all" if $to_list_name ~~ [$self->get_special_list_names(qw/new bin all/)];
    my $entry = $from_list->get_entry( $from_ID );
    return $entry unless ref $entry;
    $to_list->insert_entry( $entry, $to_ID );
}

sub rename_entry { # delete name when name arg omitted observe @named
    my ($self, $list_name, $entry_ID, $new_name) = @_;
    my ($entry, $list) = $self->get_entry( $entry_ID );
    return $entry unless ref $entry;
    $new_name //= '';
    my $all_entry = $self->get_special_lists('all');
    my $sibling = $all_entry->get_entry( $new_name );
    if ($new_name and ref $sibling){
        return "name $new_name is already taken" if $self->{'config'}{'entry'}{'prefer_in_name_conflict'} eq 'old';
        $self->rename_entry( undef, $new_name, '');
    }
    my $old_name = $entry->name;
    $entry->rename( $new_name );
    $self->get_list( $_)->refresh_reverse_hashes for $entry->member_of_lists;
    ($entry, $old_name);
}

sub redirect_entry   {
    my ($self, $list_name, $entry_ID, $new_dir) = @_;
    return "missing source ID of entry to change dir path" unless defined $new_dir;
    return "directory $new_dir is already used" if ref $self->{'list_object'}{ $self->{'config'}{'list'}{'name'}{'all'} }->get_entry( $new_dir );
    my ($entry, $list) = $self->get_entry( $entry_ID );
    return $entry unless ref $entry;
    my $old_dir = $entry->full_dir;
    $entry->redirect($new_dir);
    $self->get_list( $_)->refresh_reverse_hashes for $entry->member_of_lists;
    ($entry, $old_dir);
}

sub edit_entry   {
    my ($self, $list_name, $entry_ID, $script) = @_;
    $script //= '';
    my ($entry, $list) = $self->get_entry( $entry_ID );
    return $entry unless ref $entry;
    my $old_script = $entry->script;
    ($entry, $old_script);
}

sub get_entry {
    my ($self, $list_name, $entry_ID) = @_;
    return "missing ID (list position or name) of dir entry" unless defined $entry_ID;
    $list_name //= $self->get_current_list_name;
    $list_name = $self->get_special_lists('all') if $entry_ID !~ /-?\d+/;
    my $list  = $self->get_list( $list_name );
    return "unknown list name: $list_name" unless ref $list;
    $list->get_entry( $entry_ID ), $list;
}

sub visit_entry {
    my ($self, $list_name, $entry_ID, $sub_dir) = @_;
    $list_name //= $self->{'config'}{'syntax'}{'sigil'}{'special_list'}.$self->{'config'}{'list'}{'name'}{'all'};
    my ($entry, $list) = $self->get_entry( $list_name, $entry_ID );
    return $entry unless ref $entry;
    $entry->visit();
    ($self->{'visits'}{'previous_dir'},$self->{'visits'}{'previous_subdir'}) =
        ($self->{'visits'}{'last_dir'},$self->{'visits'}{'last_subdir'});
    my $dir = $self->{'visits'}{'last_dir'} = $entry->full_dir();
    $self->{'visits'}{'last_subdir'} = defined $sub_dir ? $sub_dir : '';
    $entry, $list;
}
sub visit_last_entry     { $_[0]->visit_entry( undef, $_[0]->{'visits'}{'last_dir'},     $_[0]->{'visits'}{'last_subdir'} ) }
sub visit_previous_entry { $_[0]->visit_entry( undef, $_[0]->{'visits'}{'previous_dir'}, $_[0]->{'visits'}{'previous_subdir'} ) }

sub get_special_dir {
    my ($self, $name) = @_;
    if    ($name eq 'last')     { File::Spec->catdir( $self->{'visits'}{'last_dir'},     $self->{'visits'}{'last_subdir'})  }
    elsif ($name eq 'previous') { File::Spec->catdir( $self->{'visits'}{'previous_dir'}, $self->{'visits'}{'previous_subdir'})  }
    else                        { exists $self->{'special_dir'}{$name} ? $self->{'special_dir'}{$name} :  File::Spec->catdir('') }
}
sub set_special_dir {
    my ($self, $name, $dir) = @_;
    return 'can not set last and previous directory in this way' if $name eq 'last' or $name eq 'previous';
    $self->{'special_dir'}{$name} = $dir;
}

########################################################################
sub undo         { my ($self) = @_; } # TODO
sub redo         { my ($self) = @_; }

1;
