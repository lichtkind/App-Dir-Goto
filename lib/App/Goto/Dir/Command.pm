use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use File::Spec;

package App::Goto::Dir::Command;

my         ($config, $data, $cwd);
sub init { ($config, $data, $cwd) = @_ }
sub run {
   my ($cmd, @arg) = @_;
   if    ($cmd eq '--help')            { App::Goto::Dir::Help::text(              $config,        $arg[0])}
   elsif ($cmd eq '--sort')            { App::Goto::Dir::Format::set_sort(        $config, $data, $arg[0])}
   elsif ($cmd eq '--list')            { App::Goto::Dir::Format::list_entries(    $config, $data, @arg )  }
   elsif ($cmd eq '--list-special')    { App::Goto::Dir::Format::special_entries( $config, $data       )  }
   elsif ($cmd eq '--list-lists')      { App::Goto::Dir::Format::lists(           $config, $data       )  }
   elsif ($cmd eq '--list-add')        {                         add_list(                        @arg )  }
   elsif ($cmd eq '--list-delete')     {                         delete_list(                     @arg )  }
   elsif ($cmd eq '--list-name')       {                         name_list(                       @arg )  }
   elsif ($cmd eq '--list-description'){                         describe_list(                   @arg )  }
   elsif ($cmd eq '--add')             {                         add_entry(                       @arg )  }
   elsif ($cmd eq '--delete')          {                         delete_entry(                    @arg )  }
   elsif ($cmd eq '--undelete')        {                         undelete_entry(                  @arg )  }
   elsif ($cmd eq '--remove')          {                         remove_entry(                    @arg )  }
   elsif ($cmd eq '--move')            {                         move_entry(                      @arg )  }
   elsif ($cmd eq '--copy')            {                         copy_entry(                      @arg )  }
   elsif ($cmd eq '--dir')             {                         dir_entry(                       @arg )  }
   elsif ($cmd eq '--name')            {                         name_entry(                      @arg )  }
   elsif ($cmd eq '--script')          {                         script_entry(                    @arg )  }
   else                                {                         goto_entry(                      @arg )  }
}
#### LIST COMMANDS #####################################################
sub add_list {
    my ($list_name, $decription) = @_;
    return ' ! need an unused list name as first argument' unless defined $list_name;
    return ' ! need the lists description as second  argument' unless defined $decription and $decription;
    return " ! can not create special lists" if substr ($list_name, 0, 1 ) =~ /\W/;
    return " ! '$list_name' is not a regular list name (only [A-Za-z0-9_] start with letter)" unless App::Goto::Dir::Parse::is_name($list_name);
    return " ! list '$list_name' does already exist" if $data->list_exists( $list_name );
    $data->new_list( $list_name, $decription, $config->{'entry'} );
    " - created list '$list_name' : '$decription'";
}
sub delete_list {
    my ($list_name) = @_;
    return ' ! need a name of an existing, regular list as first argument' unless defined $list_name;
    return " ! can not delete special lists" if substr ($list_name, 0, 1 ) =~ /\W/;
    return " ! list '$list_name' does not exists" unless $data->list_exists( $list_name );
    return " ! can not delete none empty list $list_name" if $data->get_list( $list_name )->elems();
    my $list = $data->remove_list( $list_name );
    " - deleted list '$list_name' : '".$list->get_description."'";
}
sub name_list {
    my ($old_name, $new_name) = @_;
    return ' ! need a name of an existing list as first argument' unless defined $old_name;
    return ' ! need an unused list name as second argument' unless defined $new_name;
    my $list = $data->get_list( $old_name );
    return " ! there is no list named '$old_name'" unless ref $list;
    my $sig = $config->{'syntax'}{'sigil'}{'special_list'};
    if (substr ($old_name, 0, 1 ) eq $sig and substr ($new_name, 0, 1 ) eq $sig){
        my $on = substr $old_name, 0, 1;
        my $nn = substr $new_name, 0, 1;
        return " ! '$nn' is not a list name (only [A-Za-z0-9_] start with letter)" unless App::Goto::Dir::Parse::is_name($nn);
        for my $key (keys %{$config->{'list'}{'special_name'}}){
            $config->{'list'}{'special_name'}{$key} = $nn if $config->{'list'}{'special_name'}{$key} eq $on;
        }
    } else {
        return " ! '$new_name' is not a regular list name (only [A-Za-z0-9_] start with letter)" unless App::Goto::Dir::Parse::is_name($new_name);
    }
    $data->change_list_name( $old_name, $new_name );
    " - renamed list '$old_name' to '$new_name'";
}
sub describe_list {
    my ($list_name, $list_description) = @_;
    return ' ! need a list name as first argument' unless defined $list_name;
    return ' ! need a list description as second argument' unless defined $list_description;
    my $list = $data->get_list( $list_name );
    return " ! there is no list named '$list_name'" unless ref $list;
    $list->set_description( $list_description );
    " - set description of list '$list_name': '$list_description'";
}
#### LIST ADMIN COMMANDS ###############################################
sub add_entry {
    my ($dir, $name, $target_list_name, $target_ID) = @_;
    if (ref $dir eq 'ARRAY') {
        return ' ! subdirectory of existing entry is missing' if @$dir < 2;
        return ' ! too many arguments for building a directory to add' if @$dir > 3;
        my $entry;
        if (@$dir == 2){ # [name subdir]
            if (substr( $dir->[0], 0, 1) eq $config->{'syntax'}{'sigil'}{'special_entry'}){
                my $sd = $data->get_special_entry_dir( substr $target_ID, 1 );
                return " ! there is no special entry named '$dir->[0]'" unless ref $sd;
                $dir = File::Spec->catdir( $sd, $dir->[1] );
            } else {
                $entry = $data->get_entry( undef, $dir->[0] );
                return " ! there is no entry named '$dir->[0]'" unless ref $entry;
                $dir = File::Spec->catdir( $entry->full_dir, $dir->[1] );
            }
        } else { # [list pos subdir]
            return " ! there is no list named '$dir->[0]'" unless $data->list_exists( $dir->[0] );
            $entry = $data->get_entry( $dir->[0], $dir->[1] );
            return " ! there is no entry '$dir->[0]' in list '$dir->[1]'" unless ref $entry;
            $dir = File::Spec->catdir( $entry->full_dir, $dir->[2] );
        }
    }
    $dir  //= $cwd;
    $name //= '';
    $target_ID  //= $config->{'entry'}{'position_default'};
    $target_list_name //= App::Goto::Dir::Parse::is_position( $target_ID ) ? $data->get_current_list_name : $data->get_special_list_names('all');
    return " ! '$name' is not an entry name (only [a-zA-Z0-9_] starting with letter)" if $name and not App::Goto::Dir::Parse::is_name($name);
    return " ! entry name '$name' is too long, max length is $config->{entry}{name_length_max} character" if $name and length($name) > $config->{'entry'}{'name_length_max'};
    my $target_list  = $data->get_list( $target_list_name );
    return " ! target list named '$target_list_name' does not exist, check --list-lists" unless ref $target_list;
    my $pos = $target_list->pos_from_ID( $target_ID, 'target' );
    return " ! position or name '$target_ID' does not exist in list '$target_list_name'" unless $pos;
    my $entry = App::Goto::Dir::Data::Entry->new($dir, $name);
    my ($all, $new, $named, $stale) = $data->get_special_lists(qw/all new named stale/);
    ($target_list, $pos) = ($all, $config->{'entry'}{'position_default'}) unless $target_list eq $all or $target_list->is_special;
    my $insert_error = $all->insert_entry( $entry, $target_list eq $all ? $target_ID : undef ); # sorting out names too
    return " ! $insert_error" unless ref $insert_error; # return error msg: could not inserted because not allowed overwrite entry with same dir
    $new->insert_entry( $entry );
    $named->insert_entry( $entry ) if $entry->name;
    $stale->insert_entry( $entry ) unless -d $entry->full_dir;
    $target_list->insert_entry( $entry, $target_ID ) unless $target_list eq $all;
    $data->set_special_entry( 'add', $entry );
    " - added dir '$dir' to list '$target_list_name' on position $pos";
}

sub delete_entry {
    my ($list_name, $entry_ID) = @_; # ID can be [min, max] # range
    $entry_ID  //= $config->{'entry'}{'position_default'};
    $list_name  //= App::Goto::Dir::Parse::is_position( $entry_ID ) ? $data->get_current_list_name : $data->get_special_list_names('all');
    my $list  = $data->get_list( $list_name );
    return " ! list named '$list_name' does not exist, check --list-lists" unless ref $list;
    if (ref $entry_ID eq 'ARRAY'){
        $entry_ID->[0] //= 1;
        $entry_ID->[1] //= -1;
        my $start_pos = $list->pos_from_ID( $entry_ID->[0] );
        my $end_pos = $list->pos_from_ID( $entry_ID->[1] );
        return " ! '$entry_ID->[0]' is not a valid position in list '$list_name'" unless $start_pos;
        return " ! '$entry_ID->[1]' is not a valid position in list '$list_name'" unless $end_pos;
        $entry_ID = [$start_pos .. $end_pos];
    } else { $entry_ID = [$entry_ID] }
    my $ret = '';
    for my $ID (reverse @$entry_ID){
        my $pos = $list->pos_from_ID( $ID );
        return " ! position or name '$entry_ID' does not exist in list '$list_name'" unless $pos;
        my ($entry) = $list->get_entry( $pos );
        my $lnames =  '';
        for my $list_name ($entry->member_of_lists) {
            next unless App::Goto::Dir::Parse::is_name( $list_name ); # ignore special lists
            $data->get_list( $list_name )->remove_entry( $entry->get_list_pos( $list_name ) );
            $lnames .= "$list_name, ";
        }
        chop $lnames;
        chop $lnames;
        my $was_del = $entry->overdue();
        unless ($entry->overdue()){
            $entry->delete();
            my ($bin_list) = $data->get_special_lists('bin');
            $bin_list->insert_entry( $entry );
        }
        my $entry_address = App::Goto::Dir::Parse::is_position( $ID ) ? $list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$pos
                                                                      : $config->{'syntax'}{'sigil'}{'entry_name'}.$ID;
        $ret .= $was_del ? " ! '$entry_address' was already deleted\n"
                         : " - deleted entry '$entry_address' ".App::Goto::Dir::Format::dir($entry->full_dir(), 30)." from lists: $lnames\n";
        $data->set_special_entry( 'del', $entry );
        $data->set_special_entry( 'delete', $entry );
    }
    chomp($ret);
    $ret;
}

sub undelete_entry {
    my ($source_entry_ID, $target_list_name, $target_entry_ID) = @_; # ID can be [min, max] # range
    $source_entry_ID  //= $config->{'entry'}{'position_default'};
    $target_entry_ID  //= $config->{'entry'}{'position_default'};
    $target_list_name //= $data->get_current_list_name;
    my $target_list  = $data->get_list( $target_list_name );
    return " ! target list named '$target_list_name' does not exist, check --list-lists" unless ref $target_list;
    my $target_pos = $target_list->pos_from_ID( $target_entry_ID, 'target' );
    return " ! position or name '$target_entry_ID' does not exist in list '$target_list_name'" unless $target_pos;
    my $target_address = App::Goto::Dir::Parse::is_position($target_entry_ID) ? $target_list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$target_entry_ID
                                                                              : $target_list_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$target_entry_ID;
    my $has_target =  App::Goto::Dir::Parse::is_name( $target_list_name );
    my ($bin) = $data->get_special_lists(qw/bin/);
    if (ref $source_entry_ID eq 'ARRAY'){
        $source_entry_ID->[0] //= 1;
        $source_entry_ID->[1] //= -1;
        my $start_pos = $bin->pos_from_ID( $source_entry_ID->[0] );
        my $end_pos = $bin->pos_from_ID( $source_entry_ID->[1] );
        return " ! '$source_entry_ID->[0]' is not a valid position in list '".$bin->get_name."', check --list ".$bin->get_name unless $start_pos;
        return " ! '$source_entry_ID->[1]' is not a valid position in list '".$bin->get_name."', check --list ".$bin->get_name unless $end_pos;
        $source_entry_ID = [$start_pos .. $end_pos];
    } else {
        return " ! position or name '$source_entry_ID' does not exist in list '".$bin->get_name."', check --list ".$bin->get_name
            unless $bin->pos_from_ID( $source_entry_ID );
        $source_entry_ID = [$source_entry_ID] ;
    }
    my $ret = '';
    for my $ID (reverse @$source_entry_ID){
        my $entry = $bin->remove_entry( $ID );
        $entry->undelete();
        $target_list->insert_entry( $entry, $target_pos ) if $has_target;
        my $src_address = App::Goto::Dir::Parse::is_position( $ID ) ? $bin->get_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$ID
                                                                    : $bin->get_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$ID;
        $ret .= " - undeleted entry '$src_address' ".App::Goto::Dir::Format::dir($entry->full_dir(), 30)
                .($has_target ? " and moved to '$target_address'\n" : "\n");
        $data->set_special_entry( 'undel', $entry );
        $data->set_special_entry( 'undelete', $entry );
    }
    chomp($ret);
    $ret;
}

sub remove_entry {
    my ($list_name, $entry_ID) = @_;  # ID can be [min, max] # range
    $entry_ID  //= $config->{'entry'}{'position_default'};
    $list_name //= $data->get_current_list_name;
    my $list  = $data->get_list( $list_name );
    return " ! list named '$list_name' does not exist, check --list-lists" unless ref $list;
    return " ! list '$list_name' is not regular, check --list-lists" if $list->is_special;
    if (ref $entry_ID eq 'ARRAY'){
        $entry_ID->[0] //= 1;
        $entry_ID->[1] //= -1;
        my $start_pos = $list->pos_from_ID( $entry_ID->[0] );
        my $end_pos = $list->pos_from_ID( $entry_ID->[1] );
        return " ! '$entry_ID->[0]' is not a valid position in list '".$list->get_name."', check --list ".$list->get_name unless $start_pos;
        return " ! '$entry_ID->[1]' is not a valid position in list '".$list->get_name."', check --list ".$list->get_name unless $end_pos;
        $entry_ID = [$start_pos .. $end_pos];
    } else {
        return " ! position or name '$entry_ID' does not exist in list '$list_name'" unless $list->pos_from_ID( $entry_ID );
        $entry_ID = [$entry_ID];
    }
    my $ret = '';
    for my $ID (reverse @$entry_ID){
        my $entry = $list->remove_entry( $ID );
        my $entry_address = App::Goto::Dir::Parse::is_position( $ID ) ? $list->get_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$ID
                                                                      : $list->get_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$ID;
        $ret .= " - removed entry '$entry_address' ".App::Goto::Dir::Format::dir($entry->full_dir(), 30)."\n";
        $data->set_special_entry( $_, $entry ) for qw/move vm/;
    }
    chomp($ret);
    $ret;
}

sub move_entry {
    my ($source_list_name, $source_entry_ID, $target_list_name, $target_entry_ID) = @_;
    $source_list_name //= $data->get_current_list_name;
    $source_entry_ID  //= $config->{'entry'}{'position_default'};
    $target_list_name //= $data->get_current_list_name;
    return " ! missing target entry ID (name or position) to which move entries" unless defined $target_entry_ID;
    my $source_list  = $data->get_list( $source_list_name );
    my $target_list  = $data->get_list( $target_list_name );
    return " ! source list named '$source_list_name' does not exist, check --list-lists" unless ref $source_list;
    return " ! target list named '$target_list_name' does not exist, check --list-lists" unless ref $target_list;
    return " ! source list of --move has to be regular or same as target, check --list-lists" if ref $source_list->is_special and $source_list ne $target_list;
    return " ! target list of --move has to be regular or same as source, check --list-lists" if ref $target_list->is_special and $source_list ne $target_list;
    my $target_pos = $target_list->pos_from_ID( $target_entry_ID, 'target' );
    return " ! target position or name '$target_entry_ID' does not exist in list '$target_list_name'" unless $target_pos;
    if (ref $source_entry_ID eq 'ARRAY'){
        $source_entry_ID->[0] //= 1;
        $source_entry_ID->[1] //= -1;
        my $start_pos = $source_list->pos_from_ID( $source_entry_ID->[0] );
        my $end_pos = $source_list->pos_from_ID( $source_entry_ID->[1] );
        return " ! '$source_entry_ID->[0]' is not a valid position in source list '".$source_list->get_name."', check --list ".$source_list->get_name unless $start_pos;
        return " ! '$source_entry_ID->[1]' is not a valid position in source list '".$source_list->get_name."', check --list ".$source_list->get_name unless $end_pos;
        $source_entry_ID = [$start_pos .. $end_pos];
    } else {
        return " ! source position or name '$source_entry_ID' does not exist in list '".$source_list->get_name."', check --list ".$source_list->get_name
            unless $source_list->pos_from_ID( $source_entry_ID );
        $source_entry_ID = [$source_entry_ID] ;
    }
    my $target_address = App::Goto::Dir::Parse::is_position( $target_entry_ID ) ? $target_list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$target_entry_ID
                                                                                : $target_list_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$target_entry_ID;
    my $ret = '';
    for my $ID (reverse @$source_entry_ID){
        my $entry = $source_list->remove_entry( $ID );
        my $insert_error = $target_list->insert_entry( $entry, $target_entry_ID );
        return "$ret ! $insert_error" unless ref $insert_error;
        my $src_address = App::Goto::Dir::Parse::is_position( $ID ) ? $source_list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$ID
                                                                    : $source_list_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$ID;
        $ret .= " - moved entry '$src_address' to '$target_address' ".App::Goto::Dir::Format::dir($entry->full_dir(), 30)."\n";
        $data->set_special_entry( $_, $entry ) for qw/remove rem rm/;
    }
    chomp($ret);
    $ret;
}

sub copy_entry {
    my ($source_list_name, $source_entry_ID, $target_list_name, $target_entry_ID) = @_;
    $source_list_name //= $data->get_current_list_name;
    $source_entry_ID  //= $config->{'entry'}{'position_default'};
    return " ! missing target list (name) to which copy entries"                 unless defined $target_list_name;
    return " ! missing target entry ID (name or position) to which copy entries" unless defined $target_entry_ID;
    return " ! source and target list have to be different" if $source_list_name eq $target_list_name;
    my $source_list  = $data->get_list( $source_list_name );
    my $target_list  = $data->get_list( $target_list_name );
    return " ! source list named '$source_list_name' does not exist, check --list-lists" unless ref $source_list;
    return " ! target list named '$target_list_name' does not exist, check --list-lists" unless ref $target_list;
    return " ! target list of --copy has to be regular, check --list-lists" if ref $target_list->is_special;
    my $target_pos = $target_list->pos_from_ID( $target_entry_ID, 'target' );
    return " ! position or name '$target_entry_ID' does not exist in list '$target_list_name'" unless $target_pos;
    if (ref $source_entry_ID eq 'ARRAY'){
        $source_entry_ID->[0] //= 1;
        $source_entry_ID->[1] //= -1;
        my $start_pos = $source_list->pos_from_ID( $source_entry_ID->[0] );
        my $end_pos = $source_list->pos_from_ID( $source_entry_ID->[1] );
        return " ! '$source_entry_ID->[0]' is not a valid position in source list '".$source_list->get_name."', check --list ".$source_list->get_name unless $start_pos;
        return " ! '$source_entry_ID->[1]' is not a valid position in source list '".$source_list->get_name."', check --list ".$source_list->get_name unless $end_pos;
        $source_entry_ID = [$start_pos .. $end_pos];
    } else {
        return " ! source position or name '$source_entry_ID' does not exist in list '".$source_list->get_name."', check --list ".$source_list->get_name
            unless $source_list->pos_from_ID( $source_entry_ID );
        $source_entry_ID = [$source_entry_ID] ;
    }
    my $target_address = App::Goto::Dir::Parse::is_position( $target_entry_ID ) ? $target_list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$target_entry_ID
                                                                                : $target_list_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$target_entry_ID;
    my $ret = '';
    for my $ID (reverse @$source_entry_ID){
        my $entry = $source_list->get_entry( $ID );
        my $insert_error = $target_list->insert_entry( $entry, $target_entry_ID );
        return "$ret ! $insert_error" unless ref $insert_error;
        my $src_address = App::Goto::Dir::Parse::is_position( $ID ) ? $source_list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$ID
                                                                    : $source_list_name.$config->{'syntax'}{'sigil'}{'entry_name'}.$ID;
        $ret .= " - copied entry '$src_address' to '$target_address' ".App::Goto::Dir::Format::dir($entry->full_dir(), 30)."\n";
        $data->set_special_entry( $_, $entry ) for qw/copy cp/;
    }
    chomp($ret);
    $ret;
}

sub dir_entry {
    my ($list_name, $entry_ID, $dir) = @_;
#    my ($self, $list_name, $entry_ID, $new_dir) = @_;
#    return "missing source ID of entry to change dir path" unless defined $new_dir;
#    return "directory $new_dir is already used" if ref $self->{'list_object'}{ $self->{'config'}{'list'}{'name'}{'all'} }->get_entry( $new_dir );
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
#    my $old_dir = $entry->full_dir;
#    $entry->redirect($new_dir);
#    $self->get_list( $_)->refresh_reverse_hashes for $entry->member_of_lists;
#    ($entry, $old_dir);
}

sub redir_entry {
    my ($old_dir, $new_dir) = @_;
#    my ($self, $list_name, $entry_ID, $new_dir) = @_;
#    return "missing source ID of entry to change dir path" unless defined $new_dir;
#    return "directory $new_dir is already used" if ref $self->{'list_object'}{ $self->{'config'}{'list'}{'name'}{'all'} }->get_entry( $new_dir );
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
#    my $old_dir = $entry->full_dir;
#    $entry->redirect($new_dir);
#    $self->get_list( $_)->refresh_reverse_hashes for $entry->member_of_lists;
#    ($entry, $old_dir);
}
sub name_entry {
    my ($list_name, $entry_ID, $new_name) = @_;
#    my ($self, $list_name, $entry_ID, $new_name) = @_;
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
    $new_name //= '';
#    my $all_entry = $self->get_special_lists('all');
#    my $sibling = $all_entry->get_entry( $new_name );
#    if ($new_name and ref $sibling){
#        return "name $new_name is already taken" if $self->{'config'}{'entry'}{'prefer_in_name_conflict'} eq 'old';
#        $self->rename_entry( undef, $new_name, '');
#    }
#    my $old_name = $entry->name;
#    $entry->rename( $new_name );
#    $self->get_list( $_)->refresh_reverse_hashes for $entry->member_of_lists;
#    ($entry, $old_name);
}

sub script_entry {
    my ($list_name, $entry_ID, $script) = @_;
#    my ($self, $list_name, $entry_ID, $script) = @_;
#    $script //= '';
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
#    my $old_script = $entry->script;
#    ($entry, $old_script);
}

sub goto_entry {
    my ($list_name, $entry_ID, $sub_dir) = @_;

}

1;

