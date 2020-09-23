use v5.18;
use warnings;
use File::Spec;

package App::Goto::Dir::Data::Entry;

########################################################################

sub new {
	my ($pkg, $dir, $name) = @_;
	my $now = time;
	bless { name => $name//'', cmd =>[], compact_dir => _compact_home_dir($dir), full_dir => _expand_home_dir($dir),  
		    creation_time => _format_time_stamp($now), creation_stamp => $now, visit_time => 0, visit_stamp => 0, visits => 0 }	
}
sub clone   { $_[0]->restate($_[0]->state) }
sub restate { bless $_[1] if ref $_[1] eq 'HASH' }
sub state   { return { map {$_ => $_[0]->{$_}} keys %{$_[0]} } }

########################################################################

sub name           { $_[0]->{'name'} }
sub dir            { $_[0]->{'compact_dir'} }
sub full_dir       { $_[0]->{'full_dir'} }
sub creation_time  { $_[0]->{'creation_time'} }
sub creation_stamp { $_[0]->{'creation_stamp'} }
sub visit_stamp    { $_[0]->{'visit_stamp'} }
sub visit_time     { $_[0]->{'visit_time'} }
sub visit_count    { $_[0]->{'visits'} }

########################################################################

sub rename { $_[0]->{'name'} = $_[1] }
sub visit {
	my ($self) = @_;
	my $now = time;
	$self->{'visits'}++;
	$self->{'visit_stamp'} = $now;
	$self->{'visit_time'} = _format_time_stamp($now);
	$self->{'full_dir'};
}

########################################################################

sub _compact_home_dir { (index($_[0], $ENV{'HOME'}) == 0) ? '~/' . substr( $_[0], length($ENV{'HOME'}) + 1 ) : $_[0] }
sub _expand_home_dir  { (substr($_[0], 0, 1) eq '~') ? File::Spec->catfile( $ENV{'HOME'}, substr($_[0], 2) ) : $_[0] }

sub _format_time_stamp { # sortable time stamp
	my @t = localtime shift;
	sprintf "%02d.%02d.%4s  %02d:%02d:%02d", $t[3], $t[4], 1900+$t[5], $t[2], $t[1], $t[0];
}

########################################################################

1;