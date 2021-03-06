package MooseX::Capsule::Meta::Class::Trait::Capsule;

use 5.006;
use Moose::Role;
use Moose::Util qw(apply_all_roles);
 
with qw(MooseX::Capsule::Meta::Class::Trait::Capsule::Common);

our $VERSION = 0.001_001;

sub add_delegate {
    my ($self) = @_;

    $self->validate_interface();

    my $target_metaclass = Moose::Meta::Class->create_anon_class(roles => $self->implementation); 
    my $interface_role = $self->find_interface_role;
    apply_all_roles($target_metaclass->name, $interface_role);

    my @constructor_args;
    my %required = map { $_->name => 1 } grep { $_->is_required } $target_metaclass->get_all_attributes;

    if (%required) {
        $self->add_before_method_modifier(
            new => sub {
                my $class = shift;

                if ( $target_metaclass->has_method('BUILDARGS') ) {
                    @constructor_args = @_; # can't guess what BUILDARGS returns
                }
                else {
                    my %arg = @_ == 1 && ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
                    @constructor_args = map { $_ => $arg{$_} } grep { $required{$_} } keys %arg;
                }
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
    apply_all_roles($self->name, $interface_role) if $self->has_interface_role;
}

sub allow_non_interface_role { 0 }

before 'add_attribute' => sub  {
    my $self = shift;
    my $name = shift;

    if ( $name !~ /^\d+:\d+$/ ) {
        Moose->throw_error("Attributes not permitted in interface");
    }
};

before 'superclasses' => sub {
    my ($self, $super) = @_;
    return unless $super;

    Moose->throw_error("Inheritance not permitted");
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
