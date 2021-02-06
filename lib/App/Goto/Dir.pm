use v5.18;
use warnings;
use File::Spec;
use YAML;
use App::Goto::Dir::Data;
use App::Goto::Dir::Parser;
use App::Goto::Dir::Formater;
use App::Goto::Dir::Help;

package App::Goto::Dir;
our $VERSION = 0.4;

my $file = "goto_dir_config.yml";

sub new {
    my $config = YAML::LoadFile($file);
    my $data = App::Goto::Dir::Data->new( $config );
    App::Goto::Dir::Parser::init($config);
    bless { config => $config, data => $data};
}


1;
