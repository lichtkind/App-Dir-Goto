use v5.18;
use warnings;
no warnings  qw/experimental::smartmatch/;
use feature qw/switch/;
use File::Spec;


package App::Goto::Dir::Command;

my $data;
my $config;

sub init { ($config, $data) = @_ }

sub run {
   my ($cmd, @arg) = @_;
   if ($cmd eq '--help'){ say App::Goto::Dir::Help::text($config, $arg[0]) }
     elsif ($cmd eq '--sort'){
   } elsif ($cmd eq '--list'){
   } elsif ($cmd eq '--list-special'){ App::Goto::Dir::Format::special_entries( $config, $data ) }
     elsif ($cmd eq '--list-lists')  { App::Goto::Dir::Format::lists( $config, $data )  }
     elsif ($cmd eq '--list-add')    { add_list( $data, @arg ) }
     elsif ($cmd eq '--list-delete') { delete_list( $data, @arg ) }
     elsif ($cmd eq '--list-name')   {  }
     elsif ($cmd eq '--list-description'){
   } elsif ($cmd eq '--add'){
   } elsif ($cmd eq '--delete'){
   } elsif ($cmd eq '--remove'){
   } elsif ($cmd eq '--move'){
   } elsif ($cmd eq '--copy'){
   } elsif ($cmd eq '--dir'){
   } elsif ($cmd eq '--name'){
   } elsif ($cmd eq '--edit'){
   } else {
      # goto dir
   }
}

sub add_list {
    my ($data, $list_name) = @_;
    return 'need a list name' unless defined $list_name;
    return "list '$list_name' does not exist" unless $data->list_exists( $list_name );
    $data->{'list_object'}{ $list_name } = App::Goto::Dir::Data::List->new( $list_name, $config->{'entry'} );
}

sub delete_list {
    my ($data, $list_name) = @_;
    return 'need a list name' unless defined $list_name;
    return "list '$list_name' already exists" if $data->list_exists( $list_name );
    return "can not delete special list $list_name" if substr($list_name, 0, 1) =~ /\W/;
    return "can not delete none empty list $list_name" if $data->{'list_object'}{ $list_name }->count();
    delete $data->{'list_object'}{ $list_name };
}

1;
