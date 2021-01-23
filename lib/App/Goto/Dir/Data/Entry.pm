use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Data::Entry;

########################################################################

sub new {
    my ($pkg, $dir, $name) = @_;
    # return "directory $dir does not exist" unless -d $dir;
    my $now = _now();
    bless { name => $name//'', cmd =>[], compact_dir => _compact_home_dir($dir), full_dir => _expand_home_dir($dir),
            creation_time => _format_time_stamp($now), creation_stamp => $now,
            visit_time   => 0,  visit_stamp => 0, visits => 0,
            delete_time => 0, delete_stamp => 0,  }
}
sub clone   { $_[0]->restate($_[0]->state) }
sub restate { bless $_[1] if ref $_[1] eq 'HASH' }
sub state   { return { map {$_ => ref $_[0]->{$_} ? [@{$_[0]->{$_}}] : $_[0]->{$_}} keys %{$_[0]} } }

########################################################################

sub name           { $_[0]->{'name'} }
sub dir            { $_[0]->{'compact_dir'} }
sub full_dir       { $_[0]->{'full_dir'} }
sub age            { defined $_[1] ? ($_[1] - $_[0]->{'creation_stamp'}) : time - $_[0]->{'creation_stamp'} }
sub overdue        { not $_[0]->{'delete_stamp'} ? 0 : (defined $_[1]) ? ($_[1] - $_[0]->{'delete_stamp'}) : time - $_[0]->{'delete_stamp'} }
sub creation_time  { $_[0]->{'creation_time'} }
sub creation_stamp { $_[0]->{'creation_stamp'} }
sub delete_stamp   { $_[0]->{'delete_stamp'} }
sub delete_time    { $_[0]->{'delete_time'} }
sub visit_stamp    { $_[0]->{'visit_stamp'} }
sub visit_time     { $_[0]->{'visit_time'} }
sub visit_count    { $_[0]->{'visits'} }
sub ID             { $_[0]->{'creation_stamp'}.$_[0]->{'full_dir'} }

########################################################################

sub rename   { $_[0]->{'name'} = $_[1] }
sub redirect {
    my ($self, $dir) = @_;
    $self->{'compact_dir'} = _compact_home_dir( $dir );
    $self->{'full_dir'} = _expand_home_dir( $dir );
}
sub visit {
    my ($self) = @_;
    my $now = _now();
    $self->{'visits'}++;
    $self->{'visit_stamp'} = $now;
    $self->{'visit_time'} = _format_time_stamp($now);
    $self->{'full_dir'};
}
sub delete {
    my ($self) = @_;
    my $now = _now();
    $self->{'delete_stamp'} = $now;
    $self->{'delete_time'} = _format_time_stamp($now);
}
sub undelete {
    my ($self) = @_;
    $self->{'delete_stamp'} = 0;
    $self->{'delete_time'} = 0;
}

########################################################################

sub _compact_home_dir { (index($_[0], $ENV{'HOME'}) == 0) ? '~/' . substr( $_[0], length($ENV{'HOME'}) + 1 ) : $_[0] }
sub _expand_home_dir  { (substr($_[0], 0, 1) eq '~') ? File::Spec->catfile( $ENV{'HOME'}, substr($_[0], 2) ) : $_[0] }

sub _format_time_stamp { # sortable time stamp
    my @t = localtime shift;
    sprintf "%02d.%02d.%4s  %02d:%02d:%02d", $t[3], $t[4]+1, 1900+$t[5], $t[2], $t[1], $t[0];
}
sub _now { time }
########################################################################

1;
