use v5.18;
use warnings;
use YAML;
use App::Goto::Dir::Data::List;

package App::Goto::Dir::Data;

sub new {
    my ($pkg, $config) = @_;
    return unless ref $config eq 'HASH';
    my $file = $config->{'file'}{'data'};
    my $lname = $config->{'list_name'};
    my $data = (-r $file) ? YAML::LoadFile($file)
                          : {list => { $lname->{'all'} => [], $lname->{'idle'} =>[], $lname->{'use'} => [], $lname->{'bin'} => [],
                                       $lname->{'new'} => []}, sorted_by => 'position', last_choice => '', history => [0]};
    $data->{'current_list'} = $lname->{'start'};
    $data->{'history'} = [0];
    $data->{'file'} = $config->{'file'};

    my $all_entry = $data->{'list'}{ $lname->{'all'} } = App::Goto::Dir::Data::List->restate( $data->{'list'}{ $lname->{'all'} } );
    $all_entry->configure( $config->{'entry'} );
say $lname->{'all'};
say $data->{'list'}{ $lname->{'all'} };
say $all_entry;
    if (ref $all_entry) {
        for my $list_name (keys %{$data->{'list'}}){
            next if $list_name eq $lname->{'all'};
            my $list = App::Goto::Dir::Data::List->new( );
            for my $eldata (@{$data->{'list'}{$list_name}}){
                my $el = App::Goto::Dir::Data::Entry->restate( $eldata );
                $list->insert_entry( $all_entry->get_entry( $all_entry->pos_from_dir( $el->full_dir ) ) );
            }
            $list->configure( $config->{'entry'} );
            $data->{'list'}{$list_name} = $list;
        }
    }
    my $now = App::Goto::Dir::Data::Entry::_now();
    my $new_list = $data->{'list'}{ $lname->{'new'} };
    $new_list->delete_entry($_) for grep { $_->age($now) > $config->{'entry'}{'deprecate_new'} } $new_list->all_entry;
    my @deprecated = grep { $_->overdue($now) > $config->{'entry'}{'deprecate_bin'} } $data->{'list'}{ $lname->{'bin'} }->all_entry;
    for my $list (values %{ $data->{'list'} } ){
        $list->delete_entry( $_ ) for @deprecated;
    }
    $data->{'config'} = $config;
    bless $data;
}
sub write {
    my ($self, $dir) = @_;
    $dir //= $self->{'last_choice'};
    my $pos = $self->{'list'}{'all'}->pos_from_dir($dir);
    if ($pos > -1){
        my $entry = $self->{'list'}{'all'}->get_entry( $pos );
        $dir = $entry->visit() if ref $entry;
        $self->{'last_choice'} = $dir;
    } else { say "Warning! directory $dir could not be found" }

    my $state = {};
    $state->{$_} = $self->{$_} for qw/list current_list sorted_by last_choice/; # history
    $state->{'list'} = { map {$_ => $state->{'list'}{$_}->state } keys %{$state->{'list'}} };

    rename $self->{'file'}{'data'}, $self->{'file'}{'backup'};
    YAML::DumpFile( $self->{'file'}{'data'}, $state );
    open my $FH, '>', $self->{'file'}{'return'};
    print $FH $self->{'last_choice'};
}

########################################################################
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
    my ($self, $dir, $pos, $name, $list) = @_;
    return 'List::new_entry misses first required argument: a valid path' unless defined $dir;
    return "entry name name $name is too long, max chars are ".$self->{'config'}{'entry'}{'max_name_length'}
        if defined $name and length($name) > $self->{'config'}{'entry'}{'max_name_length'};
    $list //= $self->get_current_list;
    my $all = $self->{'list'}{'all'};
    my $entry = App::Goto::Dir::Data::Entry->new( $dir, $name );
# $self->{'config'}{'entry'}{'prefer_in_name_conflict'}
# $self->{'config'}{'entry'}{'change_bin'}
# $self->{'config'}{'entry'}{'change_new'}
# $self->{'config'}{'entry'}{'max_name_length'}
# $self->{'config'}{'list_name'}{'all'}
# $self->{'config'}{'list_name'}{'bin'}
# $self->{'config'}{'list_name'}{'new'}
# $self->{'config'}{'list_name'}{'idle'}
# $self->{'config'}{'list_name'}{'start'}
# $self->{'config'}{'list_name'}{'use'}
    $self->{'list'}{$self->{'current_list_name'}}->insert(@_);

    #$self->insert_entry( $entry, $pos);

}
sub delete_entry {
    my ($self) = shift;
    $self->{'list'}{$self->{'current_list_name'}}->delete_entry(@_);
}
sub hard_delete_entry {
    my ($self) = shift;
    $self->{'list'}{$self->{'current_list_name'}}->delete_entry(@_);
}
sub copy_entry {
    my ($self, $from_list,$ID, $to_list, $pos) = @_;

}
sub move_entry {
    my ($self, $from_list,$ID, $to_list, $pos) = @_;

}
sub get_entry {
    my ($self, $ID) = @_;
    my $entry = ($ID =~ /-?\d+/)? $self->get_current_list->get_entry($ID) : $self->{'all'}->get_entry($ID);
    ref $entry ? $entry : "'$ID' is not a valid dir name or position in current list: ".$self->get_current_list_name;
}
sub rename_entry   {
    my ($self) = shift;
    $self->{'list'}{$self->{'current_list_name'}}->rename_entry(@_);
}
sub redirect_entry   {
    my ($self) = shift;
    $self->{'list'}{$self->{'current_list_name'}}->rename_entry(@_);
}

########################################################################
sub undo         {
    my ($self) = @_;
}

sub redo {
    my ($self) = @_;
}
########################################################################

sub select_dir_path {
    my ($self, $ID, $addon) = @_;
}


1;
