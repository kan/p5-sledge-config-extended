package t::Config;
use strict;
use warnings;
use base 'Sledge::Config::Extended';

sub get_file {
    my $self = shift;

    return "./@{[$self->{config_name}]}.yaml";
}

1;
