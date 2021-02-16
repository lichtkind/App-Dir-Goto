use v5.18;
use warnings;

package App::Goto::Dir::Formater;

sub lists {
    my ($config, $data) = @_;
    my @l = map { [$_, $_->get_name] } map { $data->get_list($_) } sort $data->get_all_list_name();
    #my @l = map { $data->get_list($_) } sort $data->get_all_list_name();
    my $c = $data->get_current_list_name();
    my $sig = $config->{'syntax'}{'sigil'}{'special_list'};
    say "  all list on App::Goto::Dir (name, elements, description, c = current):";
    say " ----------------------------------------------------------------------";
    say sprintf ("  %-7s . %s . %02u . %s", (substr($_->[1], 0, 1) eq $sig ? '' : ' ' ).$_->[1], $_->[1] eq $c ? 'c': '.', $_->[0]->count, $_->[0]->get_description ) for @l;
    say '';

}

sub entries {

}

1;
