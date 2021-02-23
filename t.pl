use v5.18;
use lib 'lib';
use Benchmark;
use Cwd;
use FindBin;
use File::UserConfig;

my ($t, $cwd);
BEGIN {
    $t = Benchmark->new();
    $cwd = Cwd::cwd();
    chdir $FindBin::Bin;
}
use App::Goto::Dir;
# $configdir = File::UserConfig->configdir;


my $app = App::Goto::Dir->new( $cwd );
#my $file = "goto_dir_config.yml";
#my $config = App::Goto::Dir::Config::load();
#my $data = App::Goto::Dir::Data->new( $config );
#App::Goto::Dir::Parser::init( $config );
#$data->add_entry( '~/code/perl/projekt/App-Goto-Dir', 'gt' );
#$data->add_entry( '~/code/perl/projekt', 'p' );
#say $data->delete_entry( 'all', 'p' );
#$data->write( $config );


#App::Goto::Dir::Command::run('--help');
#say App::Goto::Dir::Command::run('--help', 'basics');
#say App::Goto::Dir::Command::run('--help', 'commands');
#App::Goto::Dir::Command::run('--help', 'install');
#App::Goto::Dir::Command::run('--help', 'version');
say App::Goto::Dir::Command::run('--help', '--add');
#say App::Goto::Dir::Command::run('--help', '--delete');
#say App::Goto::Dir::Command::run('--help', '--undelete');
#App::Goto::Dir::Command::run('--help', '--remove');
#App::Goto::Dir::Command::run('--help', '--move');
#App::Goto::Dir::Command::run('--help', '--copy');
say App::Goto::Dir::Command::run('--help', '--name');
#say App::Goto::Dir::Command::run('--help', '--dir');
say App::Goto::Dir::Command::run('--help', '--redir');
#say App::Goto::Dir::Command::run('--help', '--edit');
#App::Goto::Dir::Command::run('--help', '--list');
#App::Goto::Dir::Command::run('--help', '--sort');
#App::Goto::Dir::Command::run('--help', '--list-special');
#App::Goto::Dir::Command::run('--help', '--list-lists');
#App::Goto::Dir::Command::run('--help', '--list-add');
#App::Goto::Dir::Command::run('--help', '--list-delete');
#App::Goto::Dir::Command::run('--help', '--list-name');
#App::Goto::Dir::Command::run('--help', '--list-description');
#App::Goto::Dir::Command::run('--help', '--help');

#say App::Goto::Dir::Command::run('--list-special');
#say App::Goto::Dir::Command::run('--list-lists');
#say App::Goto::Dir::Command::run('--list-add', 'a', 'test list');
#say App::Goto::Dir::Command::run('--list-add', 'use', 'test list');

#say App::Goto::Dir::Command::run('--list-lists');

#say App::Goto::Dir::Command::run('--list-name', 'a', 'b');
#say App::Goto::Dir::Command::run('--list-lists');
#say App::Goto::Dir::Command::run('--list-delete', 'b');
#say App::Goto::Dir::Command::run('--list-lists');
#say App::Goto::Dir::Command::run('--list-add',  '@all', 'all');
#say App::Goto::Dir::Command::run('--list-delete', '@all');
#App::Goto::Dir::Command::run('--sort','position');
#say App::Goto::Dir::Command::run('--list','@all', '@new');
#App::Goto::Dir::Config::reset();
#say App::Goto::Dir::Command::run('--sort', 'vis');
#say App::Goto::Dir::Command::run('--list', '@all');

say '   run goto test in ', sprintf("%.4f",timediff( Benchmark->new, $t)->[1]), ' sec';


$app->exit();
__END__

all: add copy

#say App::Goto::Dir::Data::Entry::_format_time_stamp(time );
