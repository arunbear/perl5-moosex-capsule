package MooseX::Capsule::Meta::Class::Trait::Capsule;

use 5.006;
use Moose::Role;
use Moose::Util qw(apply_all_roles);
 
our $VERSION = 0.001_001;

has interface => (
    is  => 'rw',
    writer => 'set_interface',
    isa    => 'ArrayRef[Str]',
    predicate => 'has_interface',
);

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

my $validate_interface = sub {
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
};

sub add_delegate {
    my ($self) = @_;

    $self->$validate_interface();

    my $target_metaclass = Moose::Meta::Class->create_anon_class(roles => $self->implementation); 
    my $interface_role = $self->interface_role || $self->interface_metarole->name;
    apply_all_roles($target_metaclass->name, $interface_role);

    my @constructor_args;
    my @required = grep { $_->is_required } $target_metaclass->get_all_attributes;

    if (@required) {
        $self->add_before_method_modifier(
            BUILDARGS => sub {
                my $class = shift;
                @constructor_args = @_;
            }
        );
    }
    $self->add_attribute(
        "$$:".time() => (
            init_arg => undef,
            handles  => $interface_role,
            default => sub {
                $target_metaclass->new_object(@constructor_args);
            }
        )
    );
    apply_all_roles($self->name, $interface_role);
}

before 'add_role' => sub  {
    my $self = shift;
    my $role = shift;

    my $interface_metarole = $self->interface_metarole;
    my $interface_role = $self->interface_role || ($interface_metarole && $interface_metarole->name);
    if ($interface_role && $interface_role eq $role->name) {
        return;
    }
    Moose->throw_error("Roles not permitted in interface");
};

before 'add_attribute' => sub  {
    my $self = shift;
    my $name = shift;

    if ( $name !~ /^\d+:\d+$/ ) {
        Moose->throw_error("Attributes not permitted in interface");
    }
};

1;

__END__


=head1 NAME

MooseX::Capsule::Meta::Class::Trait::Interface - The great new MooseX::Capsule::Meta::Class::Trait::Interface!

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
