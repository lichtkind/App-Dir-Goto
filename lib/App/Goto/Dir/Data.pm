use v5.18;
use warnings;
use YAML;
use App::Goto::Dir::Data::List;

package App::Goto::Dir::Data;

sub new {
    my ($pkg, $config) = @_;
    my $file = $config->{'file'}{'data'};
    my $data = (-r $file) ? YAML::LoadFile($file) : {list => {all => [], idle =>[], now => [], bin => [], new => []}, sorted_by => 'position', last_choice => '', history => [0]};
    $data->{'current_list'} = 'now';
    $data->{'history'} = [0];
    $data->{'file'} = $config->{'file'};
    my $all = $data->{'list'}{'all'} = App::Goto::Dir::Data::List->restate( $data->{'list'}{'all'} );
    if (ref $all) {
		for my $list_name (keys %{$data->{'list'}}){
			next if $list_name eq 'all';
			my $list = App::Goto::Dir::Data::List->new();
			for my $eldata (@{$data->{'list'}{$list_name}}){
				$list->insert_entry( $all->get_entry( $all->pos_from_dir( App::Goto::Dir::Data::Entry->restate( $eldata )->full_dir ) ) );
			}
			$data->{'list'}{$list_name} = $list;
		}
	}
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
	$state->{$_} = $self->{$_} for qw/list current_list sorted_by last_choice history/;
    $state->{'list'} = { map {$_ => $state->{'list'}{$_}->state } keys %{$state->{'list'}} };
    
    rename $self->{'file'}{'data'}, $self->{'file'}{'backup'};
    YAML::DumpFile( $self->{'file'}{'data'}, $state );
    open my $FH, '>', $self->{'file'}{'return'};
    print $FH $self->{'last_choice'};
}

########################################################################
sub change_list {
	my ($self, $new_list) = @_;
	return 0 unless defined $new_list and exists $self->{'list'}{$new_list};
	$self->{'current_list'} = $new_list;
}
sub get_current_list_name {                  $_[0]->{'current_list'}   }
sub get_current_list      { $_[0]->{'list'}{ $_[0]->{'current_list'} } }
########################################################################

sub add_entry { 
	my ($self, $dir) = @_;	
	$self->{'list'}{$self->{'current_list_name'}}->insert(@_);
	my $entry = {dir => $dir, creation_time => _now(), stamp => time, last_visit => 0, visits => 0};
}

sub name_entry   { 
	my ($self) = shift;
	$self->{'list'}{$self->{'current_list_name'}}->rename_entry(@_);
}
sub delete_entry { 
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

__END__

 new
 use
idle
 bin
all 
