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
    my $lname = $config->{'list'}{'name'};
    my $data = (-r $file) ? YAML::LoadFile($file)
                          : { entry => [],  list => { name => [ keys %{$lname}], current => $lname->{'use'}, sorted_by => 'position', } ,
                              visits => {last_dir => '',last_subdir => '', previous_dir => '', previous_subdir => ''},  history => [0],};

    @{ $data->{'entry'}} = map  { $_->remove_from_list( $lname->{'new'} ) if $_->age() > $config->{'list'}{'deprecate_new'}; $_ }
                           grep { $_->overdue() < $config->{'list'}{'deprecate_bin'} }
                           map  { App::Goto::Dir::Data::Entry->restate($_)}                  @{ $data->{'entry'} };
    my %list;
    for my $entry (@{ $data->{'entry'}}){
        for my $list_name ($entry->member_of_lists) {
            $list{$list_name}[ $entry->get_list_pos($list_name) ] = $entry;
        }
    }
    for my $list_name (keys %list) {
        $data->{'list_object'}{ $list_name } = App::Goto::Dir::Data::List->new( $list_name, $config->{'entry'}, grep {ref $_} @{$list{$list_name}} );
    }
    for my $list_name (keys %$lname, @{$data->{'lists'}}) { # empty lists
        next if exists $data->{'list_object'}{ $list_name };
        $data->{'list_object'}{ $list_name } = App::Goto::Dir::Data::List->new( $list_name, $config->{'entry'} );
    }
    $data->{'config'} = $config;
    bless $data;
}

sub write {
    my ($self) = @_;
    my $state                = { map { $_ => $self->{$_}} qw/visits list/ }; # history ?
    $state->{'entry'}         = [ map { $_->state } $self->{'list_object'}{ $self->{'config'}{'list'}{'name'}{'all'} }->all_entries ];
    $state->{'list'}{'name'}   = [ keys %{ $self->{'list_object'} } ];
    $state->{'list'}{'current'} = $self->{'config'}{'list'}{'default_name'} if  $self->{'config'}{'list'}{'start_with'} eq 'default';

    rename $self->{'config'}{'file'}{'data'}, $self->{'config'}{'file'}{'backup'};
    YAML::DumpFile( $self->{'config'}{'file'}{'data'}, $state );
    open my $FH, '>', $self->{'config'}{'file'}{'return'};
    print $FH File::Spec->catdir( $self->{'visits'}{'last_dir'}, $self->{'visits'}{'last_subdir'});
}

#### list API ###########################################################
sub add_list {
    my ($self, $list_name) = @_;
    return 'need a list name' unless defined $list_name;
    return "list '$list_name' does not exist" unless $self->list_exists( $list_name );
    $self->{'list_object'}{ $list_name } = App::Goto::Dir::Data::List->new( $list_name, $self->{'config'}{'entry'} );
}
sub remove_list {
    my ($self, $list_name) = @_;
    return 'need a list name' unless defined $list_name;
    return "list '$list_name' already exists" if $self->list_exists( $list_name );
    return "can not delete special list $list_name" if $list_name ~~ [@{$self->{'config'}{'list'}{'name'}}{qw/new bin all/}];
    return "can not delete none empty list $list_name" if $self->{'list_object'}{ $list_name }->count();
    delete $self->{'list_object'}{ $list_name };
}
sub change_current_list {
    my ($self, $new_list) = @_;
    return 0 unless $self->list_exists( $new_list );
    $self->{'list'}{'current'} = $new_list;
}
sub get_current_list      {        $_[0]->{'list_object'}{ $_[0]->{'list'}{'current'} } }
sub get_current_list_name {                                $_[0]->{'list'}{'current'}   }
sub get_all_list_name     { keys %{$_[0]->{'list_object'}}                              }
sub get_list              { $_[0]->{'list_object'}{$_[1]} if exists $_[0]->{'list_object'}{$_[1]} }
sub get_special_lists     { my $self = shift; @{$self->{'list_object'}}{ @{$self->{'config'}{'list'}{'name'}}{@_} } }
sub get_special_list_names{ my $self = shift; @{$self->{'config'}{'list'}{'name'}}{@_} }
sub list_exists           { defined $_[1] and exists $_[0]->{'list_object'}{$_[1]}      }

#### entry API #########################################################
sub new_entry {
    my ($self, $dir, $name, $list_name, $list_pos) = @_;
    return 'Data::new_entry misses first required argument: a valid path' unless defined $dir;
    return "entry name name $name is too long, max chars are ".$self->{'config'}{'entry'}{'max_name_length'}
        if defined $name and length($name) > $self->{'config'}{'entry'}{'max_name_length'};
    $list_name //= $self->get_current_list_name;
    return "entry list with name '$list_name' does not exist" unless $self->list_exists( $list_name );
    my $entry = App::Goto::Dir::Data::Entry->new($dir, $name);
    my $list     = $self->get_list( $list_name );
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
    my $special_list_names = [$self->get_special_list_names(qw/new bin all/)];
    return "can not move entries from special lists: new, bin and all" if $from_list_name ~~ $special_list_names;
    return "can not move entries to special lists: new, bin and all" if $to_list_name ~~ $special_list_names;
    my $entry = $from_list->remove_entry( $from_ID );
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

sub rename_entry { # delete name when name arg omitted
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
    my ($entry, $list) = $self->get_entry( $list_name, $entry_ID );
    return $entry unless ref $entry;
    $entry->visit();
    ($self->{'visits'}{'previous_dir'},$self->{'visits'}{'previous_subdir'}) =
        ($self->{'visits'}{'last_dir'},$self->{'visits'}{'last_subdir'});
    my $dir = $self->{'visits'}{'last_dir'} = $entry->full_dir();
    $self->{'visits'}{'last_subdir'} = defined $sub_dir ? $sub_dir : '';
    $entry, $list;
}
sub visit_last_entry {
    $_[0]->visit_entry( $_[0]->{'config'}{'list'}{'name'}{'all'}, $_[0]->{'visits'}{'last_dir'}, $_[0]->{'visits'}{'last_subdir'} );
}
sub visit_previous_entry {
    $_[0]->visit_entry( $_[0]->{'config'}{'list'}{'name'}{'all'}, $_[0]->{'visits'}{'previous_dir'}, $_[0]->{'visits'}{'previous_subdir'} );
}

########################################################################
sub undo         { my ($self) = @_; } # TODO
sub redo         { my ($self) = @_; }

1;
