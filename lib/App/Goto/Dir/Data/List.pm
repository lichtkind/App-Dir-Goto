use v5.18;
use warnings;
use File::Spec;
use App::Goto::Dir::Data::Entry;

package App::Goto::Dir::Data::List; # index: 1 .. count
########################################################################
sub new { bless { elems => [], pos_by_name => {}, pos_by_dir => {} } }
sub state   { [map { $_->state } @{$_[0]->{'elems'}}] }
sub restate {
    my ($pkg, $list) = @_;
    return unless ref $list eq 'ARRAY';
    my $self = { elems => [ map {App::Goto::Dir::Data::Entry->restate($_)} @$list] };
    refresh_reverse_hashes( $self );
    bless $self
}
sub refresh_reverse_hashes {
    my ($self) = @_;
    $self->{'pos_by_name'} = {};
    $self->{'pos_by_dir'} = {};
    for my $pos (1 .. @{$self->{'elems'}}){
        my $el = $self->{'elems'}[$pos-1];
        $self->{'pos_by_dir'}{ $el->full_dir } = $pos;
        $self->{'pos_by_name'}{ $el->name } = $pos if $el->name;
    }
}
sub configure {
    my ($self, $config) = @_;
    return unless ref $config eq 'HASH';
    $self->{'config'}{ $_ } = $config->{ $_ } for keys %$config;
    $self;
}
########################################################################
sub insert_entry {
    my ($self, $entry, $pos) = @_;
    return "need an App::Goto::Dir::Data::Entry object as argument!" unless ref $entry eq 'App::Goto::Dir::Data::Entry';
    $pos = $self->{'config'}{'position_of_new_entry'} unless defined $pos;
    return "'$pos' is an illegal list position" unless $self->is_new_pos($pos);
    $pos = @{$self->{'elems'}} + 2 + $pos if $pos < 0;
    my $dir_pos = $self->pos_from_dir( $entry->full_dir );
    if ($dir_pos){
        return 'path '.$entry->full_dir.' is already stored in this list' if $self->{'config'}{'prefer_in_dir_conflict'} eq 'old';
        return $self->move_entry($dir_pos, $pos);
    }
    if ($entry->name and exists $self->{'pos_by_name'}{ $entry->name }){
        if ($self->{'config'}{'prefer_in_name_conflict'} eq 'new')  { $self->unname_entry( $entry->name ) }
        else                                                        { $entry->rename('') }
    }
    splice @{$self->{'elems'}}, $pos-1, 0, $entry;
    $self->refresh_reverse_hashes();
    $entry;
}
sub delete_entry {
    my ($self, $ID) = @_;
    my $pos = ref $ID ? $self->pos_from_dir( $ID->full_dir ) : $self->pos_from_ID( $ID );
    return "'".$ID->full_dir."' is not dir in the list" if ref $ID and not $pos;
    return "'$ID' is not a valid dir name or position of the current list" if not $pos;
    my $entry = splice @{$self->{'elems'}}, $pos-1, 1;
    $self->refresh_reverse_hashes();
    $entry;
}
########################################################################
sub move_entry {
    my ($self, $from, $to) = @_;
    my $from_pos = $self->pos_from_ID( $from );
    my $to_pos = $self->pos_from_ID( $to );
    return "'$from' is not a valid dir name or position of the current list" if not $from_pos;
    return "'$to' is not a valid target name or position of the current list" if not $to_pos;
    my $entry = splice @{$self->{'elems'}}, $from_pos-1, 1;
    splice @{$self->{'elems'}}, $to_pos-1, 0, $entry;
    $self->refresh_reverse_hashes();
    $entry;
}

sub rename_entry {
    my ($self, $ID, $newname) = @_;
    my $pos = $self->pos_from_ID($ID);
    $newname //= '';
    return "'$ID' is not a valid dir name or position of the current list" if not $pos;
    my $name_pos = $self->pos_from_ID( $newname );
    return "entry name $newname is already taken and config does not allow delete name of other entry"
            if $name_pos and $self->{'config'}{'prefer_in_name_conflict'} ne 'new';
    my $entry = $self->{'elems'}[$pos-1];
    my $old_name = $entry->name;
    $entry->rename( $newname );
    $self->unname_entry( $newname );
    $self->{'pos_by_name'}{ $newname } = $pos if $newname;
    $old_name;
}
sub unname_entry {
    my ($self, $name) = @_;
    return unless defined $name and exists $self->{'pos_by_name'}{ $name };
    $self->{'elems'}[ delete( $self->{'pos_by_name'}{ $name } ) -1 ]->rename('');
}

sub redirect_entry { # cd
    my ($self, $ID, $new_dir) = @_;
    my $pos = $self->pos_from_ID($ID);
    return "'$ID' is not a valid dir name or position of the current list" if not $pos;
    return "path missing" unless defined $new_dir;
    $new_dir = App::Goto::Dir::Data::Entry::_expand_home_dir( $new_dir );
    return "path missing" unless defined $new_dir;
    my $dir_pos = $self->pos_from_dir( $new_dir );
    return "path $new_dir is already stored in this list" if $dir_pos and $self->{'config'}{'prefer_in_dir_conflict'} eq 'old';
    my $entry = $self->{'elems'}[$pos-1];
    my $old_dir = $entry->full_dir;
    $entry->redirect( $new_dir );
    $self->delete_entry($dir_pos) if $dir_pos;
    $self->refresh_reverse_hashes();
    $old_dir;
}
########################################################################
sub get_entry {
    my ($self, $ID) = @_;
    my $pos = $self->pos_from_ID($ID);
    return "'$ID' is not a valid dir name or position of the current list" if not $pos;
    $self->{'elems'}[$pos-1];
}

sub all_entry { @{$_[0]->{'elems'}} }
sub count     { int @{$_[0]->{'elems'}} }
########################################################################
sub pos_from_ID {
    my ($self, $ID) = @_;
    return 0 unless defined $ID;
    if ($ID =~ /-?\d+/){
        $ID = @{$self->{'elems'}} + $ID + 1 if $ID < 0;
        return $ID if $self->is_pos($ID);
    } else { return $self->{'pos_by_name'}{ $ID } if exists $self->{'pos_by_name'}{ $ID } }
    0;
}
sub pos_from_dir {
    my ($self, $dir) = @_;
    exists $self->{'pos_by_dir'}{ $dir } ? $self->{'pos_by_dir'}{ $dir } : 0;
}
sub is_pos     { $_[1] == int $_[1] and (($_[1] > 0 and $_[1] <=  @{$_[0]->{'elems'}})
                                      or ($_[1] < 0 and $_[1] >= -@{$_[0]->{'elems'}})) }
sub is_new_pos { $_[1] == int $_[1] and (($_[1] > 0 and $_[1] <=  @{$_[0]->{'elems'}}+1)
                                      or ($_[1] < 0 and $_[1] <= -@{$_[0]->{'elems'}}-1)) }
1;
