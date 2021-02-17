use v5.18;
use warnings;

package App::Goto::Dir::Format;

sub lists {
    my ($config, $data) = @_;
    my @l = map { [$_, $_->get_name] } map { $data->get_list($_) } sort $data->get_all_list_name();
    my $c = $data->get_current_list_name();
    my $sig = $config->{'syntax'}{'sigil'}{'special_list'};
    my $nl = $config->{'list'}{'name_length_max'} +1;

    my $ret = "  all list on Goto::Dir (name, elements, description, c = current):\n".
              " -----------------------------------------------------------------\n";
    $ret .= sprintf ("  %-".$nl."s. %s . %02u . %s\n",
             (substr($_->[1], 0, 1) eq $sig ? '' : ' ' ).$_->[1], $_->[1] eq $c ? 'c': '.', $_->[0]->elems, $_->[0]->get_description ) for @l;
    $ret."\n";
}

sub special_entries {
    my ($config, $data) = @_;
    my @l = map { [$_, $_->get_name] } map { $data->get_list($_) } sort $data->get_all_list_name();
    my $c = $data->get_current_list_name();
    my $sig = $config->{'syntax'}{'sigil'}{'special_entry'};
    my $space = '. 'x(3+int($config->{'list'}{'name_length_max'}/2));
    my $ret = "  special entries on Goto::Dir (start with $sig):\n".
              " --------------------------------------------\n";
    $ret .= '  '.$sig.$_.substr($space, length $_).$data->get_special_dir($_)."\n" for qw/last previous add delete remove move copy dir name edit/;
    $ret."\n";
}

sub entries {
    my ($config, $data, $list_name) = @_;
    my $l = $data->get_list($_);
    return say $l unless ref $l;
    say "  all list on App::Goto::Dir (name, elements, description, c = current):";
    say " ----------------------------------------------------------------------";
    say '';
}

sub set_sort {
    my ($config, $data, $criterion) = @_;

}


1;
