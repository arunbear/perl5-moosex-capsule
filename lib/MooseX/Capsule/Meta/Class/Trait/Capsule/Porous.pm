package MooseX::Capsule::Meta::Class::Trait::Capsule::Porous;

use 5.006;
use Moose::Role;
use Carp qw(cluck);
use List::MoreUtils qw(any);
use Moose::Util qw(apply_all_roles find_meta);

with qw(MooseX::Capsule::Meta::Class::Trait::Capsule::Common);
 
our $VERSION = 0.001_001;

sub combine_roles {
    my ($self) = @_;

    $self->validate_interface();

    apply_all_roles($self->name, @{ $self->implementation });
    apply_all_roles($self->name, $self->find_interface_role);

    # only required attributes can use init_arg
    foreach my $attr ( $self->get_all_attributes ) {
        next if $attr->is_required;
        next unless defined $attr->init_arg;

        $self->remove_init_arg($attr);
        #my $writer = $attr->writer || $attr->accessor;
        #my $name   = $attr->name  ;

        #if ( $writer 
        #     && ! $is_interface_method{$writer} 
        #   ) {
        #    $self->remove_init_arg($attr);
        #}
    }
}

sub allow_non_interface_role {
    my ($self, $name) = @_;

    if ( $name eq join('|' => @{ $self->implementation || [] }) ) {
        return 1;
    }
}

before 'add_attribute' => sub  {
    my $self = shift;
    my $attr = shift;

    my $name = blessed $attr ? $attr->name : $attr;

    # only attributes defined in an implementation are allowed
    foreach my $role ( @{ $self->implementation || [] } ) {
        my $meta = find_meta($role);

        if ( $meta->has_attribute($name) ) {
            return;
        }
    }
    Moose->throw_error("Attribute: $name not permitted in interface");
};

sub remove_init_arg {
    my ($self, $attr) = @_;

    my $name = $attr->name;
    $self->remove_attribute($name);
    $self->add_attribute($attr->clone(name => $name, init_arg => undef));
}

1;

__END__


=head1 NAME



=head1 VERSION

Version 0.001_001



=head1 SYNOPSIS

Quick summary of what the module does.

=head1 AUTHOR

Arun Prasaad, C<< <arunbear at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Arun Prasaad.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
