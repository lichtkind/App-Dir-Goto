use v5.18;
use lib 'lib';
use YAML;
use App::Goto::Dir::Data;

my $file = "goto_dir_config.yml";
my $config = YAML::LoadFile($file);
my $data = App::Goto::Dir::Data->new($config);
#say $data;
$data->write();
#say App::Goto::Dir::Data::Entry::_format_time_stamp(time );
