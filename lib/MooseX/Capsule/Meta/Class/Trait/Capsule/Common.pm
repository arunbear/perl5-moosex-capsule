package MooseX::Capsule::Meta::Class::Trait::Capsule::Common;

use 5.006;
use Moose::Role;
 
our $VERSION = 0.001_001;

has interface_role => (
    is  => 'rw',
    writer => 'set_interface_role',
    isa    => 'RoleName',
    predicate => 'has_interface_role',
);

has interface_metarole => (
    is  => 'rw',
    writer => 'set_interface_metarole',
    isa    => 'Moose::Meta::Role',
    predicate => 'has_interface_metarole',
);
 
has implementation => (
    is  => 'rw',
    writer => 'set_implementation',
    isa    => 'ArrayRef[RoleName]',
    predicate => 'has_implementation',
);

sub validate_interface {
    my ($self) = @_;

    my $interface = $self->interface_role
      or return;

    my $metarole = Class::MOP::class_of($interface);

    if ( $metarole->get_attribute_list ) {
        Moose->throw_error("Attributes not permitted in interface role");
    }

    my @methods = $metarole->get_method_list;
    unless (scalar @methods == 1 && $methods[0] eq 'meta') {
        Moose->throw_error("Methods not permitted in interface role");
    }
}

before 'add_role' => sub  {
    my $self = shift;
    my $role = shift;

    my $name = $role->name;

    if ($self->is_interface_role($name)) {
        return;
    }
    if ($self->allow_non_interface_role($name)) {
        return;
    }
    $self->no_roles_in_interface($name);
};

sub is_interface_role {
    my ($self, $name) = @_;

    my $interface_metarole = $self->interface_metarole;
    my $interface_role = $self->interface_role || ($interface_metarole && $interface_metarole->name);
    if ($interface_role && $interface_role eq $name) {
        return 1;
    }
}

sub no_roles_in_interface {
    my ($self, $name) = @_;
    Moose->throw_error("Roles not permitted in interface: $name");
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
