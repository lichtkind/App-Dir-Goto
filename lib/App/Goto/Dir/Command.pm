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
   elsif ($cmd eq '--remove')          {                         remove_entry(                    @arg )  }
   elsif ($cmd eq '--move')            {                         move_entry(                      @arg )  }
   elsif ($cmd eq '--copy')            {                         copy_entry(                      @arg )  }
   elsif ($cmd eq '--dir')             {                         dir_entry(                       @arg )  }
   elsif ($cmd eq '--name')            {                         name_entry(                      @arg )  }
   elsif ($cmd eq '--edit')            {                         edit_entry(                      @arg )  }
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
    my ($dir, $name, $target_list, $target_entry) = @_;
    if (ref $dir eq 'ARRAY') {
        return ' ! subdirectory of existing entry is missing' if @$dir < 2;
        return ' ! too many arguments for building a directory to add' if @$dir > 3;
        my $entry;
        if (@$dir == 2){ # [name subdir]
            if (substr( $dir->[0], 0, 1) eq $config->{'syntax'}{'sigil'}{'special_entry'}){
                my $sd = $data->get_special_entry_dir( substr $target_entry, 1 );
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
    $target_entry  //= $config->{'entry'}{'position_default'};
    $target_list   //= App::Goto::Dir::Parse::is_position( $target_entry ) ? $data->get_current_list_name : $data->get_special_list_names('all');
    return " ! '$name' is not an entry name (only [a-zA-Z0-9_] starting with letter)" if $name and not App::Goto::Dir::Parse::is_name($name);
    return " ! entry name '$name' is too long, max length is $config->{entry}{name_length_max} character" if $name and length($name) > $config->{'entry'}{'name_length_max'};
    my $list  = $data->get_list( $target_list );
    return " ! target list name '$target_list' does not exist, check --list-lists" unless ref $list;
    my $pos = $list->pos_from_ID( $target_entry );
    return " ! position or name '$target_entry' does not exist in list '$target_list'" unless $pos;
    $pos++ if $target_entry < 0;

    my $entry = App::Goto::Dir::Data::Entry->new($dir, $name);
    my ($all_entry, $new_entry) = $data->get_special_lists('all', 'new');
    # INSERT into all on pos???

    my $ret = $all_entry->insert_entry( $entry, $list eq $all_entry ? $target_entry : undef ); # sorting out names too
    return $ret unless ref $ret; # return error msg: could not inserted because not allowed overwrite entry with same dir
    $new_entry->insert_entry( $entry, $list eq $new_entry ? $pos : undef );
    $list->insert_entry( $entry, $target_entry ) unless $list eq $all_entry or $list eq $new_entry;
    $data->set_special_entry( 'add', $new_entry );
    " - added dir '$dir' to list '$target_list' on position $pos";
}

sub delete_entry {
    my ($list_name, $entry_ID) = @_; # ID can be [min, max] # range
    $entry_ID  //= $config->{'entry'}{'position_default'};
    $list_name  //= App::Goto::Dir::Parse::is_position( $entry_ID ) ? $data->get_current_list_name : $data->get_special_list_names('all');
    my $list  = $data->get_list( $list_name );
    return " ! list name '$list_name' does not exist, check --list-lists" unless ref $list;
    if (ref $entry_ID eq 'ARRAY'){
        $entry_ID->[0] //= 1;
        $entry_ID->[1] //= $list->elems;
        return " ! '$entry_ID->[0]' is not a valid position in list '$list_name'" unless $list->pos_from_ID( $entry_ID->[0] );
        return " ! '$entry_ID->[1]' is not a valid position in list '$list_name'" unless $list->pos_from_ID( $entry_ID->[1] );
    } else { $entry_ID = [$entry_ID] }
    my $ret = '';
    for my $ID (@$entry_ID){
        my $pos = $list->pos_from_ID( $entry_ID );
        return " ! position or name '$entry_ID' does not exist in list '$list_name'" unless $pos;
        my $entry = $list->get_entry($pos);
        my $lnames =  '';
        for my $list_name ($entry->member_of_lists) {
            next unless App::Goto::Dir::Parse::is_name( $list_name );
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
        my $entry_adress = App::Goto::Dir::Parse::is_position( $entry_ID ) ? $list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$pos
                                                                           : $config->{'syntax'}{'sigil'}{'entry_name'}.$entry_ID;
        $ret .= $was_del ? " ! '$entry_adress' was already deleted\n" : " - deleted entry '$entry_adress' from lists: $lnames \n";
        $data->set_special_entry( 'del', $entry );
    }
    chomp($ret);
    $ret;
}

sub undelete_entry {
    my ($list_name, $entry_ID) = @_; # ID can be [min, max] # range
    $entry_ID  //= $config->{'entry'}{'position_default'};
    $list_name  //= App::Goto::Dir::Parse::is_position( $entry_ID ) ? $data->get_current_list_name : $data->get_special_list_names('all');
    my $list  = $data->get_list( $list_name );
    return " ! list name '$list_name' does not exist, check --list-lists" unless ref $list;
    if (ref $entry_ID eq 'ARRAY'){
        $entry_ID->[0] //= 1;
        $entry_ID->[1] //= $list->elems;
        return " ! '$entry_ID->[0]' is not a valid position in list '$list_name'" unless $list->pos_from_ID( $entry_ID->[0] );
        return " ! '$entry_ID->[1]' is not a valid position in list '$list_name'" unless $list->pos_from_ID( $entry_ID->[1] );
    } else { $entry_ID = [$entry_ID] }
    my $ret = '';
    for my $ID (@$entry_ID){
        my $pos = $list->pos_from_ID( $entry_ID );
        return " ! position or name '$entry_ID' does not exist in list '$list_name'" unless $pos;
        my $entry = $list->get_entry($pos);
        my $lnames =  '';
        for my $list_name ($entry->member_of_lists) {
            next unless App::Goto::Dir::Parse::is_name( $list_name );
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
        my $entry_adress = App::Goto::Dir::Parse::is_position( $entry_ID ) ? $list_name.$config->{'syntax'}{'sigil'}{'entry_position'}.$pos
                                                                           : $config->{'syntax'}{'sigil'}{'entry_name'}.$entry_ID;
        $ret .= $was_del ? " ! '$entry_adress' was already deleted\n" : " - deleted entry '$entry_adress' from lists: $lnames \n";
        $data->set_special_entry( 'del', $entry );
    }
    chomp($ret);
    $ret;
}

sub remove_entry {
    my ($target_list, $target_entry) = @_;
#        my ($self, $list_name, $entry_ID) = @_;
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
#    return "can not remove entries from special lists: new, bin and all" if $list_name ~~ [$self->get_special_list_names(qw/new bin all/)];
#    $list->remove_entry( $entry_ID );
#    $data->set_special_entry( 'remove', $entry );
}

sub move_entry {
    my ($source_list, $source_entry, $target_list, $target_entry) = @_;
  #  my ($self, $from_list_name, $from_ID, $to_list_name, $to_ID) = @_;
  #  return "missing source ID of entry to move" unless defined $from_ID;
 #   $from_list_name //= $self->get_current_list_name;
#    $to_list_name //= $self->get_current_list_name;
#    my ($from_list, $to_list)  = @{$self->{'list_object'}}{ $from_list_name, $to_list_name };
#    return "unknown source list name: $from_list_name" unless ref $from_list;
#    return "unknown target list name: $to_list_name" unless ref $to_list;
#    if ($from_list_name eq $to_list_name) {
#        return $from_list->move_entry( $from_ID, $to_ID)
#    } else {
#       return "can not move entries from special lists: new, bin and all" if $from_list_name ~~ [$self->get_special_list_names(qw/new all/)];
#       return "can not move entries to special lists: new, bin and all" if $to_list_name ~~ [$self->get_special_list_names(qw/new bin all/)];
#    }
#    my $entry = $from_list->remove_entry( $from_ID );
#    $entry->undelete();
#    return $entry unless ref $entry;
#    $to_list->insert_entry( $entry, $to_ID );
#    $data->set_special_entry( 'move', $entry );
}

sub copy_entry {
    my ($source_list, $source_entry, $target_list, $target_entry) = @_;
#    my ($self, $from_list_name, $from_ID, $to_list_name, $to_ID) = @_;
#    return "missing source ID of entry to move" unless defined $from_ID;
#    $from_list_name //= $self->get_current_list_name;
#    $to_list_name //= $self->get_current_list_name;
#    my ($from_list, $to_list)  = @{$self->{'list_object'}}{ $from_list_name, $to_list_name };
#    return "unknown source list name: $from_list_name" unless ref $from_list;
#    return "unknown target list name: $to_list_name" unless ref $to_list;
#    return "can not copy entries to special lists: new, bin and all" if $to_list_name ~~ [$self->get_special_list_names(qw/new bin all/)];
#    my $entry = $from_list->get_entry( $from_ID );
#    return $entry unless ref $entry;
#    $to_list->insert_entry( $entry, $to_ID );
}

sub dir_entry {
    my ($target, $dir) = @_;
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
    my ($target, $dir) = @_;
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
#    my ($target, $name) = @_;
#    my ($self, $list_name, $entry_ID, $new_name) = @_;
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
#    $new_name //= '';
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

sub edit_entry {
    my ($target, $script) = @_;
#    my ($self, $list_name, $entry_ID, $script) = @_;
#    $script //= '';
#    my ($entry, $list) = $self->get_entry( $entry_ID );
#    return $entry unless ref $entry;
#    my $old_script = $entry->script;
#    ($entry, $old_script);
}

sub goto_entry {
    my ($source, $target) = @_;

}

1;
