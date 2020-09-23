use v5.18;
use warnings;
use File::Spec;
use App::Goto::Dir::Data::Entry;

package App::Goto::Dir::Data::List;

########################################################################
sub new { bless { elems => [], count => 0, pos_by_name => {}, pos_by_dir => {} } }

sub state   { map { $_->state } @{$_[0]->{'elems'}} }
sub restate {
	my ($self, $list) = @_;
	return unless ref $list eq 'ARRAY';
	$self = {};
	$self->{'elems'} = [ map {$_->restate} @$list];
	$self->{'count'} = @{$self->{'elems'}};
	$self->refresh_reverse_hashes();
	bless $self
}
sub refresh_reverse_hashes {
	my ($self) = @_;
	$self->{'pos_by_name'} = {};
	$self->{'pos_by_dir'} = {};
	for my $pos (0 .. $self->{'count'}-1){
		$self->{'pos_by_name'}{ $self->{'elems'}[$pos]->full_dir } = $pos;
		$self->{'pos_by_dir'}{ $self->{'elems'}[$pos]->name }     = $pos if exists $self->{'elems'}[$pos]{'name'};
	}
}
########################################################################

sub insert_entry {
	my ($self, $dir, $pos, $name) = @_;
	return 'entry list insert misses first required argument: dir' unless defined $dir;
	$dir = App::Goto::Dir::Data::Entry::_expand_home_dir($dir);
	return 'dir already in this list'                            if exists $self->{'pos_by_dir'}{ $dir };
	return 'name is already used in this list' if defined $name and exists $self->{'pos_by_name'}{ $name };
	$pos = $self->{'count'} unless defined $pos and $pos;
	$pos = $self->{'count'} + 1 + $pos if $pos < 0;
    return "'$pos' is an illegal list position" unless $self->is_new_pos($pos);
	$self->{'count'}++;
	my $entry = App::Goto::Dir::Data::Entry->new( $dir, $name );
	splice @{$self->{'elems'}}, $pos, 0, $entry;
	$self->refresh_reverse_hashes();
	$entry;
}

sub move_entry {
	my ($self, $from, $to) = @_;
	my $from_pos = $self->pos_from_ID( $from );
	my $to_pos = $self->pos_from_ID( $to );
	return "'$from' is not a valid dir name or position of the current list" if $from_pos < 0;
	return "'$to' is not a valid target name or position of the current list" if $to_pos < 0;
	my $entry = splice @{$self->{'elems'}}, $from_pos, 1;
	splice @{$self->{'elems'}}, $to_pos, 0, $entry;
	$self->refresh_reverse_hashes();
	$entry;
}
sub pos_from_ID {
	my ($self, $ID) = @_;
	return $self->{'count'}-1 unless defined $ID;
	if ($ID =~ /-?\d+/){
		$ID = $self->{'last'} + $ID if $ID < 0;
		return $ID if $self->is_pos($ID);
	} else { return $self->{'pos_by_name'}{ $ID } if exists $self->{'pos_by_name'}{ $ID } }
	-1;
}
sub is_pos     { $_[1] == int $_[1] and $_[1] > 0 and $_[1] < $_[0]->{'count'} }
sub is_new_pos { $_[1] == int $_[1] and $_[1] > 0 and $_[1] <= $_[0]->{'count'} }


sub rename_entry {
	my ($self, $ID, $newname) = @_;
	my $pos = $self->pos_from_ID($ID);
	return "'$ID' is not a valid dir name or position of the current list" if $pos < 0;
	my $entry = $self->{'elems'}[$pos];
	my $old_name = $entry->name;
	$newname //= '';
	$entry->rename( $newname );
	delete $self->{'pos_by_name'}{ $old_name } if exists $self->{'pos_by_name'}{ $old_name };
	$self->{'pos_by_name'}{ $newname } = $pos if $newname;
	$old_name;
}

sub delete_entry {
	my ($self, $ID) = @_;
	my $pos = $self->pos_from_ID($ID);
	return "'$ID' is not a valid dir name or position of the current list" if $pos < 0;
	my $entry = splice @{$self->{'elems'}}, $pos, 1;
	$self->{'count'}--;
	$self->refresh_reverse_hashes();
	$entry;
}

########################################################################
sub get_entry {
	my ($self, $ID) = @_;
	my $pos = $self->pos_from_ID($ID);
	return "'$ID' is not a valid dir name or position of the current list" if $pos < 0;
	$self->{'elems'}[$pos];
}

sub all_entry { @{$_[0]->{'elems'}} }
########################################################################

1;
