use v5.18;
use warnings;
use File::Spec;
use App::Goto::Dir::Data::Entry;

package App::Goto::Dir::Data::List;

########################################################################
sub new { bless { elems => [], count => 0, pos_by_name => {}, pos_by_dir => {}, prefer_name => $_[1] // 'new' } }

sub state   { [map { $_->state } @{$_[0]->{'elems'}}] }
sub restate {
    my ($self, $list) = @_;
    return unless ref $list eq 'ARRAY';
    $self = {};
    $self->{'elems'} = [ map {$_->restate} @$list];
    $self->{'count'} = @{$self->{'elems'}};
    refresh_reverse_hashes( $self );
    bless $self
}
sub refresh_reverse_hashes {
    my ($self) = @_;
    $self->{'pos_by_name'} = {};
    for my $pos (0 .. $self->{'count'}-1){
        $self->{'pos_by_name'}{ $self->{'elems'}[$pos]->name } = $pos if $self->{'elems'}[$pos]->name;
    }
}
########################################################################

sub new_entry {
    my ($self, $dir, $pos, $name) = @_;
    return 'List::new_entry misses first required argument: a valid path' unless defined $dir;
    my $entry = App::Goto::Dir::Data::Entry->new( $dir, $name );
    return $entry unless ref $entry;
    $self->insert_entry( $entry, $pos);
}
sub insert_entry { # works as add on default
    my ($self, $entry, $pos) = @_;
    return "need an App::Goto::Dir::Data::Entry object as argument!" unless ref $entry eq 'App::Goto::Dir::Data::Entry';
    #return $entry->name, ' is already used as name in this list' if $entry->name and exists $self->{'pos_by_name'}{ $entry->name };
    return 'path ', $entry->full_dir, ' is already stored in this list' if $self->pos_from_dir( $entry->full_dir ) > -1;
    $pos = $self->{'count'} unless defined $pos;
    $pos = $self->{'count'} + 1 + $pos if $pos < 0;
    return "'$pos' is an illegal list position" unless $self->is_new_pos($pos);
    if ($entry->name){
        if ($self->{'prefer_name'} eq 'new')  { $self->unname_entry( $entry->name ) }
        else                                  { $entry->rename('') if exists $self->{'pos_by_name'}{ $entry->name } }
    }
    splice @{$self->{'elems'}}, $pos, 0, $entry;
    $self->{'count'}++;
    $self->refresh_reverse_hashes();
    $entry;
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

sub rename_entry {
    my ($self, $ID, $newname) = @_;
    my $pos = $self->pos_from_ID($ID);
    $newname //= '';
    return "'$ID' is not a valid dir name or position of the current list" if $pos < 0;
    return "entry name $newname is already taken and config does not allow delete name of other entry"
        if exists $self->{'pos_by_name'}{ $newname } and $self->{'prefer_name'} ne 'new';
    my $entry = $self->{'elems'}[$pos];
    my $old_name = $entry->name;
    $entry->rename( $newname );
    $self->unname_entry( $newname );
    delete $self->{'pos_by_name'}{ $old_name } if exists $self->{'pos_by_name'}{ $old_name };
    $self->{'pos_by_name'}{ $newname } = $pos if $newname;
    $old_name;
}

sub unname_entry {
    my ($self, $name) = @_;
    return unless defined $name and exists $self->{'pos_by_name'}{ $name };
    $self->{'elems'}[ delete $self->{'pos_by_name'}{ $name } ]->rename('');
}

sub redirect_entry {
    my ($self, $ID, $new_dir) = @_;
    my $pos = $self->pos_from_ID($ID);
    return "'$ID' is not a valid dir name or position of the current list" if $pos < 0;
    my $entry = $self->{'elems'}[$pos];
    my $old_dir = $entry->full_dir;
    $entry->redirect( $new_dir );
    $old_dir;
}

sub get_entry {
    my ($self, $ID) = @_;
    my $pos = $self->pos_from_ID($ID);
    return "'$ID' is not a valid dir name or position of the current list" if $pos < 0;
    $self->{'elems'}[$pos];
}

sub all_entry { @{$_[0]->{'elems'}} }
########################################################################
sub pos_from_ID {
    my ($self, $ID) = @_;
    return $self->{'count'}-1 unless defined $ID;
    if ($ID =~ /-?\d+/){
        $ID = $self->{'last'} + $ID if $ID < 0;
        return $ID if $self->is_pos($ID);
    } else { return $self->{'pos_by_name'}{ $ID } if exists $self->{'pos_by_name'}{ $ID } }
    -1;
}
sub pos_from_dir {
    my ($self, $dir) = @_;
    for my $pos (0 .. $#{$self->{'elems'}}){
        return $pos if $dir eq $self->{'elems'}[$pos]->full_dir;
    }
    -1;
}
sub is_pos     { $_[1] == int $_[1] and $_[1] > 0 and $_[1] < $_[0]->{'count'} }
sub is_new_pos { $_[1] == int $_[1] and $_[1] > 0 and $_[1] <= $_[0]->{'count'} }
########################################################################

1;
