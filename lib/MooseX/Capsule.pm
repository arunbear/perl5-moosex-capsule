package MooseX::Capsule;

use 5.006;
use strict;
use Moose ();
use Moose::Exporter;

our $VERSION = 0.001_001;

Moose::Exporter->setup_import_methods(
    with_meta       => [qw/interface interface_role implementation/],
    class_metaroles => {
        class => [ 'MooseX::Capsule::Meta::Class::Trait::Capsule' ],
    },
    also => 'Moose',
);
 
sub interface {
    my $meta = shift;

    my $metarole = Moose::Meta::Role->create_anon_role;
    $metarole->add_required_methods(@_);
    $meta->set_interface_metarole($metarole);

    if ($meta->has_implementation) {
        $meta->add_delegate();
    }
}

sub interface_role {
    my $meta = shift;
    my $role = shift;

    $meta->set_interface_role($role);

    if ($meta->has_implementation) {
        $meta->add_delegate();
    }
}

sub implementation {
    my $meta = shift;

    $meta->set_implementation(\@_);

    if ($meta->has_interface_metarole || $meta->has_interface_role) {
        $meta->add_delegate();
    }
}

1;

__END__

=head1 NAME

MooseX::Capsule - Moose with declarative interfaces and enchanced encapsulation.

=head1 VERSION

Version 0.001_001

=head1 SYNOPSIS

    # A basic Set class

    package Foo::Set;
    use MooseX::Capsule;

    interface qw(
        add
        delete
        exists
        is_empty
        size
    );
    implementation 'Foo::Set::Implementation';

    1;

    # A role that provides its implementation

    package Foo::Set::Implementation;
    use Moose::Role;

    has 'store' => (
        is => 'ro',
        init_arg => undef,
        default => sub { {} },
        traits  => ['Hash'],
        handles => {
            clear  => 'clear',
            delete => 'delete',
            exists => 'exists',
            set    => 'set',
            size   => 'count',
            is_empty => 'is_empty',
        },
    );

    sub add {
        my ($self, $item) = @_;
        $self->set($item => 1);
    }

    1;
    
    # Code that uses the Set class
    # ... Methods declared via interface can be used
    
    my $s = Foo::Set->new;

    $s->add('foo');
    $s->add('bar');
    say $s->size; # 2

    $s->delete('foo');
    say $s->size; # 1

    # ... but methods not declared in the interface cannot
    $s->clear(); # dies

=head1 EXPORTED FUNCTIONS

=head2 interface (@methods)

This function is used to declare the methods that can be called by users of the current class.

Use either interface or interface_role, but not both.

=head2 interface_role ($role)

This function is used to declare an interface role i.e. one containing only required methods, that can be called by users of the current class.

Use either interface or interface_role, but not both.

=head2 implementation (@roles)

This function is used to declare one or more implementation roles that define the attributes and methods providing the functionality of the current class.

=head1 AUTHOR

Arun Prasaad, C<< <arunbear at cpan.org> >>

=head1 SUPPORT

This module is stored in an open L<https://github.com/arunbear/perl5-moosex-capsule>. 
Feel free to fork and contribute!

Please report any bugs through
the web interface at L<https://github.com/arunbear/perl5-moosex-capsule/issues>.

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Capsule

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-Capsule/>

=back

=head1 ACKNOWLEDGEMENTS


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
