use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use YAML;
use App::Goto::Dir::Data::List;

package App::Goto::Dir::Data;

#### de- constructors ##################################################

sub new {
    my ($pkg, $config) = @_;
    return unless ref $config eq 'HASH';
    my $file = $config->{'file'}{'data'};
    my $lname = $config->{'list_name'};
    my $data = (-r $file) ? YAML::LoadFile($file)
                          : { entries => [], lists => [ keys %{$lname}], current_list => $lname->{'use'},
                              sorted_by => 'position', last_choice => '', history => [0]};

    my $now = App::Goto::Dir::Data::Entry::_now();
    @{ $data->{'entries'}} = #map  { $_->remove_from_list( $lname->{'new'} ) if $_->age($now) > $config->{'entry'}{'deprecate_new'}; say $_; $_ }
                             #grep { $_->overdue($now) < $config->{'entry'}{'deprecate_bin'} }
                             map  { App::Goto::Dir::Data::Entry->restate($_)}                  @{ $data->{'entries'} };
    my %list;
    for my $entry (@{ $data->{'entries'}}){
        for my $list_name ($entry->member_of_lists) {
            $list{$list_name}[ $entry->get_list_pos($list_name) ] = $entry;
        }
    }
    for my $list_name (keys %list) {
        $data->{'list'}{ $list_name } =
            App::Goto::Dir::Data::List->new( $list_name, $config->{'entry'}, grep {ref $_} @{$list{$list_name}} );
    }
    for my $list_name (keys %$lname) {
        next if exists $data->{'list'}{ $list_name };
        $data->{'list'}{ $list_name } = App::Goto::Dir::Data::List->new( $list_name, $config->{'entry'} );
    }
    $data->{'config'} = $config;
    bless $data;
}
sub write {
    my ($self, $dir) = @_;
    $dir //= $self->{'last_choice'};
    my $all_list = $self->{'list'}{ $self->{'config'}{'list_name'}{'all'} };
    my $pos = $all_list->pos_from_dir($dir);
    if ($pos){
        my $entry = $all_list->get_entry( $pos );
        $dir = $entry->visit() if ref $entry;
        $self->{'last_choice'} = $dir;
    } else { say "Warning! directory: '$dir' could not be found" }

    my $state = { map { $_ => $self->{$_}} qw/lists current_list sorted_by last_choice/ }; # history
    $state->{'entries'} = [ map { $_->state } $all_list->all_entries ];

    rename $self->{'config'}{'file'}{'data'}, $self->{'config'}{'file'}{'backup'};
    YAML::DumpFile( $self->{'config'}{'file'}{'data'}, $state );
    open my $FH, '>', $self->{'config'}{'file'}{'return'};
    print $FH $self->{'last_choice'};
    $self->{'last_choice'};
}

#### list API ###########################################################

sub change_current_list {
    my ($self, $new_list) = @_;
    return 0 unless defined $new_list and exists $self->{'list'}{$new_list};
    $self->{'current_list'} = $new_list;
}
sub get_current_list      {        $_[0]->{'list'}{ $_[0]->{'current_list'} } }
sub get_current_list_name {                         $_[0]->{'current_list'}   }
sub get_all_list_name     { keys %{$_[0]->{'list'}}                           }

########################################################################

sub new_entry {
    my ($self, $dir, $name, $list_pos, $list_name) = @_;
    return 'Data::new_entry misses first required argument: a valid path' unless defined $dir;
    return "entry name name $name is too long, max chars are ".$self->{'config'}{'entry'}{'max_name_length'}
        if defined $name and length($name) > $self->{'config'}{'entry'}{'max_name_length'};
    return "entry list with name '$list_name' does not exist" if defined $list_name and not exists $self->{'list'}{ $list_name };
    my $entry = App::Goto::Dir::Data::Entry->new($dir, $name);
    $list_name //= $self->get_current_list_name;
    my $list     = $self->{'list'}{ $list_name };
    return "unknown list name: $list_name" unless ref $list;
    my ($all_entry, $new_entry) = @{$self->{'list'}}{ @{$self->{'config'}{'list_name'}}{'all', 'new'} };
    my $ret = $all_entry->insert_entry( $entry, $list eq $all_entry ? $list_pos : undef ); # sorting out names too
    return $ret unless ref $ret; # return error msg: could not inserted becasue not allowed overwrite entry with same dir
    $new_entry->insert_entry( $entry, $list eq $new_entry ? $list_pos : undef );
    $list->insert_entry( $entry, $list_pos ) unless $list eq $all_entry or $list eq $new_entry;
    $entry;
}

sub delete_entry { # remove from all lists (-all) & move to bin
    my ($self, $list_name, $entry_ID) = @_;
    return "missing source ID (name or position) of entry to delete" unless defined $entry_ID;
    $list_name //= $self->get_current_list_name;
    my $list = $self->{'list'}{ $list_name };
    return "unknown list name: $list_name" unless ref $list;
    my ($entry, $pos) = $list->get_entry( $entry_ID );
    return "can not delete $entry_ID, it is an unknown entry ID in list $list_name" unless ref $entry;
    my ($all_entry, $bin_entry) = @{$self->{'list'}}{ @{$self->{'config'}{'list_name'}}{'all', 'bin'} };
    for my $list (values %{$self->{'list'}}) {
        next if $list eq $all_entry or $list eq $bin_entry;
        $list->remove_entry( $entry );
    }
    unless ($entry->overdue()){
        $entry->delete();
        $bin_entry->insert_entry( $entry );
    }
    $entry;
}

sub remove_entry { # from one list
    my ($self, $list_name, $entry_ID) = @_;
    return "missing source ID of entry to remove" unless defined $entry_ID;
    $list_name //= $self->get_current_list_name;
    my $list  = $self->{'list'}{ $list_name };
    return "unknown list name: $list_name" unless ref $list;
    return "can not remove entries from special lists: new, bin and all" if $list_name ~~ [@{$self->{'config'}{'list_name'}}{qw/new bin all/}];
    $list->remove_entry( $entry_ID );
}

sub move_entry {
    my ($self, $from_list_name, $from_ID, $to_list_name, $to_ID) = @_;
    return "missing source ID of entry to move" unless defined $from_ID;
    $from_list_name //= $self->get_current_list_name;
    $to_list_name //= $self->get_current_list_name;
    my ($from_list, $to_list)  = @{$self->{'list'}}{ $from_list_name, $to_list_name };
    return "unknown source list name: $from_list_name" unless ref $from_list;
    return "unknown target list name: $to_list_name" unless ref $to_list;
    return "can not move entries to special lists: new, bin and all" if $to_list_name ~~ [@{$self->{'config'}{'list_name'}}{qw/new bin all/}];
    my $entry = $from_list->remove_entry( $from_ID );
    return $entry unless ref $entry;
    $to_list->insert_entry( $entry, $to_ID );
}

sub copy_entry {
    my ($self, $from_list_name, $from_ID, $to_list_name, $to_ID) = @_;
    return "missing source ID of entry to move" unless defined $from_ID;
    $from_list_name //= $self->get_current_list_name;
    $to_list_name //= $self->get_current_list_name;
    my ($from_list, $to_list)  = @{$self->{'list'}}{ $from_list_name, $to_list_name };
    return "unknown source list name: $from_list_name" unless ref $from_list;
    return "unknown target list name: $to_list_name" unless ref $to_list;
    return "can not copy entries to special lists: new, bin and all" if $to_list_name ~~ [@{$self->{'config'}{'list_name'}}{qw/new bin all/}];
    my $entry = $from_list->get_entry( $from_ID );
    return $entry unless ref $entry;
    $to_list->insert_entry( $entry, $to_ID );
}

sub rename_entry { # delete name when name arg omitted
    my ($self, $list_name, $entry_ID, $new_name) = @_;
    return "missing source ID of entry to change its name" unless defined $entry_ID;
    $list_name //= $self->get_current_list_name;
    $new_name //= '';
    my $list  = $self->{'list'}{ $list_name };
    return "unknown list name: $list_name" unless ref $list;
    my $entry = $list->get_entry( $entry_ID );
    return $entry unless ref $entry;
    my $all_entry = $self->{'list'}{ $self->{'config'}{'list_name'}{'all'} };
    my $sibling = $all_entry->get_entry( $new_name );
    if ($new_name and ref $sibling){
        return "name $new_name is already taken" if $self->{'config'}{'entry'}{'prefer_in_name_conflict'} eq 'old';
        $self->rename_entry( $self->{'config'}{'list_name'}{'all'}, $new_name, '');
    }
    $entry->rename( $new_name );
    $self->{'list'}{ $_ }->refresh_reverse_hashes for $entry->member_of_lists;
    $entry;
}

sub redirect_entry   {
    my ($self, $list_name, $entry_ID, $new_dir) = @_;
    return "missing source ID of entry to rename" unless defined $entry_ID;
    return "missing source ID of entry to change dir path" unless defined $new_dir;
    return "directory $new_dir is already used" if ref $self->{'list'}{ $self->{'config'}{'list_name'}{'all'} }->get_entry( $new_dir );
    $list_name //= $self->get_current_list_name;
    my $list  = $self->{'list'}{ $list_name };
    return "unknown list name: $list_name" unless ref $list;
    my $entry = $list->get_entry( $entry_ID );
    return $entry unless ref $entry;
    $entry->redirect($new_dir);
    $self->{'list'}{ $_ }->refresh_reverse_hashes for $entry->member_of_lists;
    $entry;
}

########################################################################
sub undo         {
    my ($self) = @_;
}

sub redo {
    my ($self) = @_;
}
########################################################################

1;
