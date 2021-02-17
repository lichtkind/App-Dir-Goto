use v5.18;
use lib 'lib';
use Benchmark;
my $t;
BEGIN { $t = Benchmark->new(); }

use App::Goto::Dir;

my $app = App::Goto::Dir->new();
#my $file = "goto_dir_config.yml";
#my $config = App::Goto::Dir::Config::load();
#my $data = App::Goto::Dir::Data->new( $config );
#App::Goto::Dir::Parser::init( $config );
#$data->add_entry( '~/code/perl/projekt/App-Goto-Dir', 'gt' );
#$data->add_entry( '~/code/perl/projekt', 'p' );
#say $data->delete_entry( 'all', 'p' );
#$data->write( $config );


#App::Goto::Dir::Command::run('--help');
#App::Goto::Dir::Command::run('--help', 'basics');
#App::Goto::Dir::Command::run('--help', 'commands');
#App::Goto::Dir::Command::run('--help', 'install');
#App::Goto::Dir::Command::run('--help', 'version');
#App::Goto::Dir::Command::run('--help', '--add');
#App::Goto::Dir::Command::run('--help', '--delete');
#App::Goto::Dir::Command::run('--help', '--remove');
#App::Goto::Dir::Command::run('--help', '--move');
#App::Goto::Dir::Command::run('--help', '--copy');
#App::Goto::Dir::Command::run('--help', '--name');
#App::Goto::Dir::Command::run('--help', '--dir');
#App::Goto::Dir::Command::run('--help', '--edit');
#App::Goto::Dir::Command::run('--help', '--list');
#App::Goto::Dir::Command::run('--help', '--sort');
#App::Goto::Dir::Command::run('--help', '--list-special');
#App::Goto::Dir::Command::run('--help', '--list-lists');
#App::Goto::Dir::Command::run('--help', '--list-add');
#App::Goto::Dir::Command::run('--help', '--list-delete');
#App::Goto::Dir::Command::run('--help', '--list-name');
#App::Goto::Dir::Command::run('--help', '--list-description');
#App::Goto::Dir::Command::run('--help', '--help');

App::Goto::Dir::Command::run('--list-special');
App::Goto::Dir::Command::run('--list-lists');
App::Goto::Dir::Command::run('--list-add', 'a');
App::Goto::Dir::Command::run('--list-lists');
App::Goto::Dir::Command::run('--list-delete', 'a');
App::Goto::Dir::Command::run('--list-lists');
App::Goto::Dir::Command::run('--list-delete', '@all');
#App::Goto::Dir::Command::run('--sort','position');
#App::Goto::Dir::Command::run('--list','@all', '@new');
#App::Goto::Dir::Config::reset();

say '   run goto test in ', sprintf("%.4f",timediff( Benchmark->new, $t)->[1]), ' sec';


$app->exit();
__END__

all: add copy

#say App::Goto::Dir::Data::Entry::_format_time_stamp(time );
