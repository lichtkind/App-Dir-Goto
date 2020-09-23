use v5.18;
use warnings;
use YAML;
use App::Goto::Dir::Data::List;

package App::Goto::Dir::Data;

sub new {
    my ($pkg, $file) = @_;
    my $data = (-r $file) ? YAML::LoadFile($file) : {list => {archive =>[], current => [], bin => [], new => []}, sorted_by => 'position', last_choice => {}};
    $data->{'current_list_name'} = 'now';
    $data->{'history'} = [0];
    $data->{'file'} = $file;
    bless $data;
}
sub write {
	my ($self) = @_;
    YAML::DumpFile( $self->{'file'} , {map { $_ => $self->{$_} } qw/list sorted_by last_choice/} );
}

########################################################################

sub add_dir { 
	my ($self, $dir) = @_;	
	$self->{'list'}{$self->{'current_list_name'}}->insert(@_);
	my $entry = {dir => $dir, creation_time => _now(), stamp => time, last_visit => 0, visits => 0};
}

sub name_dir   { 
	my ($self) = shift;
	$self->{'list'}{$self->{'current_list_name'}}->rename_entry(@_);
}
sub delete_dir { 
	my ($self) = shift;
	$self->{'list'}{$self->{'current_list_name'}}->delete_entry(@_);
}
sub move_entry {
	my ($self, $from, $to) = @_;
}


sub undo         { 
	my ($self) = @_;
}

sub redo { 
}



sub display_current_list {
	my ($self, @keys) = @_;
    say "App::Dir::Goto list '$self->{current_list_name}', sorted by '$self->{sorted_by}' (h <Enter> for help):";
#    printf "[%2s] %6s    %s\n", @$_ for $self->{'list'}{$self->{'current_list_name'}}->content($self->{'sorted_by'}, 'position', 'name', 'dir');
}

sub display_list_menu {
	my ($self, @keys) = @_;
}

sub get_dir_from_ID {
	my ($self, $ID) = @_;
}

sub select_dir_path {
	my ($self, $ID, $addon) = @_;
}


sub switch_list {
	my ($self, $ID, $addon) = @_;
}

sub _now { # sortable time stamp
	my @t = localtime;
	sprintf "%4s %02d.%02d. %02d:%02d:%02d", 1900+$t[5], $t[4], $t[3], $t[2], $t[1], $t[0];
}


1;
