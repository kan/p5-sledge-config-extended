package Sledge::Config::Extended;

use strict;
use warnings;
use utf8;
use base qw(Sledge::Config);

our $VERSION = '0.01';

use Path::Class;

sub new {
    my $class       = shift;
    my $config_name = shift;
    my $config_file = shift;

    my $config_base;
    if ($config_name =~ /^([^_]+)_/) {
        $config_base = $1;
    }

    my $conf = {};
    if ( -d $config_file ) {
        dir($config_file)->recurse(
            callback => sub {
                my ($filename) = @_;
                warn $filename;
                return unless -f $filename;

                my $c = $class->_load_file($config_base, $config_name, $filename);
                while ( my ($key, $val) = each %$c ) {
                    $conf->{$key} = $val;
                }
            }
        );
    } elsif ( -f $config_file ) {
        $conf = $class->_load_file($config_base, $config_name, $config_file);
    } else {
        die "$config_file can't find";
    }

    bless $conf, $class;
}

sub _load_file {
    my ($class, $config_base, $config_name, $filename) = @_;

    my $config_data = file($filename)->slurp;
    # replace string __ENV:(.+)__
    $config_data =~ s{__ENV:(.+?)__}{ $ENV{$1} }ge;

    my $conf = $class->_load($config_data);

    my %config;
    if ($config_base) {
        %config = (
            %{$conf->{common}},
            %{$conf->{$config_base}},
            $conf->{$config_name} ? %{$conf->{$config_name}} : (),
        );
    } else {
        %config = (
            %{$conf->{common}},
            $conf->{$config_name} ? %{$conf->{$config_name}} : (),
        );
    }

    # case sensitive hash
    %config = map { lc($_) => $config{$_} } keys %config
        unless $class->case_sensitive;

    return \%config;
}

sub _load {
    my ($class, $config_data) = @_;

    eval { require YAML::Syck; };
    if( $@ ) {
        require YAML;
        return YAML::Load( $config_data );
    } else {
        return YAML::Syck::Load( $config_data );
    }
}

1;
__END__

=head1 NAME

Sledge::Config::YAML - The configuration file of Sledge can be written by using YAML.

=head1 SYNOPSIS

   package Your::Config;
   use basei qw(Sledge::Config::YAML);

   sub new {
       my $class = shift;

       $class->SUPER::new($ENV{SLEDGE_CONFIG_NAME}, $ENV{SLEDGE_CONFIG_FILE});
   }

   ----
   config.yaml

   ---
   common:
     datasource:
       - dbi:mysql:dbname
       - user
       - pass
     tmpl_path: /usr/local/proj/template
     info_addr: proj@example.com

   develop:
     datasource:
       - dbi:mysql:proj
       - dev_user
       - dev_pass
     session_servers:
       - 127.0.0.1:XXXXX
     cache_servers  :
       - 127.0.0.1:XXXXX
     tmpl_path: __ENV:HOME__/project/template/proj

   develop_kan:
     host: proj.dev.example.com
     validator_message_file: /path/to/dev_conf/message.yaml
     info_addr: kan@example.com


=head1 DESCRIPTION

The configuration file of Sledge can be written by using YAML.

=head1 METHODS

=head2 new

You can use syntax `__ENV:(.+)__`. It's replaced with environment variable.

=head1 AUTHOR

KAN Fushihara E<lt>kan at mobilefactory.jpE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 THANKS TO

   Tokuhiro Matsuno

=head1 SEE ALSO

L<Sledge::Config>

=cut

