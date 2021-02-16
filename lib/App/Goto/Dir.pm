use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use File::Spec;
use YAML;
use App::Goto::Dir::Command;
use App::Goto::Dir::Config;
use App::Goto::Dir::Data;
use App::Goto::Dir::Formater;
use App::Goto::Dir::Help;
use App::Goto::Dir::Parser;

package App::Goto::Dir;
our $VERSION = 0.4;

my $file = "goto_dir_config.yml";

sub new {
    my $config = App::Goto::Dir::Config::load();
    my $data = App::Goto::Dir::Data->new( $config );
    App::Goto::Dir::Parser::init( $config );
    bless { config => $config, data => $data};
}

sub exit {
    my $self = shift;
    $self->{'data'}->write( $self->{'config'} );
    App::Goto::Dir::Config::save( $self->{'config'} );
}

sub new_entry {
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



1;
