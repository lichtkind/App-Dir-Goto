use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use File::Spec;
use YAML;
use App::Goto::Dir::Command;
use App::Goto::Dir::Config;
use App::Goto::Dir::Data;
use App::Goto::Dir::Format;
use App::Goto::Dir::Help;
use App::Goto::Dir::Parser;

package App::Goto::Dir;
our $VERSION = 0.4;

my $file = "goto_dir_config.yml";

sub new {
    my $config = App::Goto::Dir::Config::load();
    my $data = App::Goto::Dir::Data->new( $config );
    App::Goto::Dir::Parser::init( $config );
    App::Goto::Dir::Command::init( $config, $data );
    bless { config => $config, data => $data};
}

sub exit {
    my $self = shift;
    $self->{'data'}->write( $self->{'config'} );
    App::Goto::Dir::Config::save( $self->{'config'} );
}



1;
