use v5.18;
use lib 'lib';
use Benchmark;
my $t;
BEGIN { $t = Benchmark->new(); }

use App::Goto::Dir;

my $file = "goto_dir_config.yml";
my $config = YAML::LoadFile($file);
my $data = App::Goto::Dir::Data->new( $config );
App::Goto::Dir::Parser::init($config);
 $data->new_entry( '~/code/perl/projekt/App-Goto-Dir', 'gt' );
 $data->new_entry( '~/code/perl/projekt', 'p' );
#say $data->delete_entry( 'all', 'p' );
$data->write();


#say App::Goto::Dir::Help::text( $config );
say App::Goto::Dir::Help::text($config, 'option', 'commands');
say App::Goto::Dir::Help::text($config, 'command', 'add');
say App::Goto::Dir::Help::text($config, 'command', 'delete');

say '   run goto test in ', sprintf("%.4f",timediff( Benchmark->new, $t)->[1]), ' sec';


__END__

all: add copy

#say App::Goto::Dir::Data::Entry::_format_time_stamp(time );
