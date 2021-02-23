use v5.18;
use warnings;
use File::Spec;
use YAML;

package App::Goto::Dir::Config;

our $default = {
          file => {              data => 'places.yml',
                               backup => 'places.bak.yml',
                               return => 'last_choice',
                  },
         entry => {   name_length_max => 5,
                     position_default => -1,
              prefer_in_name_conflict => 'new',
               prefer_in_dir_conflict => 'new',
                             move_dir => 1,
                  },
          list => {     deprecate_new => 1209600,
                        deprecate_bin => 1209600,
                           start_with => 'current',
                         name_default => 'use',
                         name_length_max => 6,
                         special_name => {
                                        all => 'all',
                                        bin => 'bin',
                                        new => 'new',
                                      stale => 'stale',
                                      named => 'named',
                             },
                  special_description => {
                                        all => 'all entries, even deleted ones',
                                        bin => 'recycling bin of deleted entries',
                                        new => 'recently created entries',
                                      stale => 'entries with not existing directories',
                                      named => 'entries with names',
                             },
                            sorted_by => 'current',
                         sort_default => 'position',
                  },
          syntax => {           sigil => {
                                    command => '-',
                                 entry_name => ':',
                                       help => '?',
                             entry_position => '^',
                               target_entry => '>',
                              special_entry => '+',
                               special_list => '@',
                                },
                        special_entry => {
                                       last => '_',
                                   previous => '-',
                                },
                     command_shortcut => {
                                        add => 'a',
                                     delete => 'd',
                                   undelete => 'u',
                                     remove => 'r',
                                       move => 'm',
                                       copy => 'c',
                                        dir => 'D',
                                      redir => 'R',
                                       edit => 'E',
                                       name => 'N',
                                       sort => 's',
                                       list => 'l',
                             'list-special' => 'l-s',
                               'list-lists' => 'l-l',
                                 'list-add' => 'l-a',
                              'list-delete' => 'l-d',
                                'list-name' => 'l-n',
                         'list-description' => 'l-D',
                                       help => 'h',
                                },
                      option_shortcut => {
                                        sort => {
                                           created => 'c',
                                               dir => 'D',
                                      'last_visit' => 'l',
                                          position => 'p',
                                              name => 'n',
                                            visits => 'v',
                                        },
                                        help => {
                                            basics => 'b',
                                          commands => 'c',
                                           install => 'i',
                                          settings => 's',
                                        },
                                },
                  },
};

our $file = "goto_dir_config.yml";
our $dfile = "goto_dir_config_default.yml";
our $loaded;

sub load {
    __PACKAGE__->reset unless -r $file;
    $loaded = YAML::LoadFile($file);
}

sub reset {
    YAML::DumpFile( $file, $default );
    YAML::DumpFile( $dfile, $default );
}

sub save {
    $loaded = shift if ref $_[0] eq 'HASH';
    YAML::DumpFile( $file, $loaded );
}

1;
