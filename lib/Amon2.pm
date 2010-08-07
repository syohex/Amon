package Amon2;
use strict;
use warnings;
use 5.008001;
use Amon2::Container;
use UNIVERSAL::require;

our $VERSION = '0.44';
{
    our $_context;
    sub context { $_context }
    sub set_context { $_context = $_[1] }
}

sub import {
    my $class = shift;

    strict->import;
    warnings->import;

    if (@_>0 && shift eq '-base') {
        my $caller = caller(0);
        my %args = @_;

        no strict 'refs';
        unshift @{"${caller}::ISA"}, 'Amon2::Base';

        my $base_dir = Amon2::Util::base_dir($caller);
        *{"${caller}::base_dir"} = sub { $base_dir };

        *{"${caller}::base_name"} = sub { $caller };

        if (my $config_loader = $args{config_loader_class}) {
            $config_loader->use or die $@;
            *{"${caller}::config_loader_class"} = sub { $config_loader };
        }
    }
}

package Amon2::Base;
use parent 'Amon2::Container';

sub new {
    my $class = shift;
    if ($class->can('config_loader_class')) {
        unshift @_, 'config' => $class->config_loader_class->load();
    }
    $class->SUPER::new(@_);
}

# for CLI
sub bootstrap {
    my $class = shift;
    my $self = $class->new(@_);
    Amon2->set_context($self);
    return $self;
}

# -------------------------------------------------------------------------
# shortcut for your laziness

sub logger {
    my ($self) = @_;
    $self->get("Logger");
}

sub db {
    my $self = shift;
    $self->get(join('::', "DB", @_));
}

1;
__END__

=head1 NAME

Amon2 - lightweight web application framework

=head1 SYNOPSIS

    $ amon-setup.pl MyApp

=head1 Point

    Fast
    Easy to use

=head1 CLASS METHODS

=over 4

=item my $c = Amon2->context();

Get the context object.

=item Amon2->set_context($c)

Set your context object(INTERNAL USE ONLY).

=back

=head1 AUTHOR

Tokuhiro Matsuno

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

