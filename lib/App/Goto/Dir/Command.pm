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
   if      ($cmd eq '--help')            { App::Goto::Dir::Help::text(              $config,        $arg[0])}
     elsif ($cmd eq '--sort')            { App::Goto::Dir::Format::set_sort(        $config, $data, @arg )  }
     elsif ($cmd eq '--list')            { App::Goto::Dir::Format::entries(         $config, $data, @arg )  }
     elsif ($cmd eq '--list-special')    { App::Goto::Dir::Format::special_entries( $config, $data       )  }
     elsif ($cmd eq '--list-lists')      { App::Goto::Dir::Format::lists(           $config, $data       )  }
     elsif ($cmd eq '--list-add')        {                         add_list(                        @arg )  }
     elsif ($cmd eq '--list-delete')     {                         delete_list(                     @arg )  }
     elsif ($cmd eq '--list-name')       {                         name_list(                       @arg )  }
     elsif ($cmd eq '--list-description'){                         describe_list(                   @arg )  }
     elsif ($cmd eq '--add')             {                         add_entry(                       @arg )  }
     elsif ($cmd eq '--delete'){
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
    my ($list_name, $decription) = @_;
    return 'need a list name as first argument' unless defined $list_name;
    return 'need the lists description as second  argument' unless defined $decription and $decription;
    return "can not create special lists" if substr ($list_name, 0, 1 ) =~ /\W/;
    return "'$list_name' is not a regular list name (only [A-Za-z0-9_] start with letter)" unless App::Goto::Dir::Parse::is_name($list_name);
    return "list '$list_name' does already exist" if $data->list_exists( $list_name );
    $data->new_list( $list_name, $decription, $config->{'entry'} );
    "created list '$list_name' : '$decription'";
}

sub delete_list {
    my ($list_name) = @_;
    return 'need a list name as first argument' unless defined $list_name;
    return "can not delete special lists" if substr ($list_name, 0, 1 ) =~ /\W/;
    return "list '$list_name' does not exists" unless $data->list_exists( $list_name );
    return "can not delete none empty list $list_name" if $data->get_list( $list_name )->elems();
    my $list = $data->remove_list( $list_name );
    "deleted list '$list_name' : '".$list->get_description."'";
}

sub name_list {
    my ($old_name, $new_name) = @_;

}

sub describe_list {
    my ($list_name, $list_description) = @_;

}

sub add_entry {
    my ($dir, $name, $target) = @_;

}

1;
