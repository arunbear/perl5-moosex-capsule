#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

{
    package Foo::FruitPicker::Role;
    use Moose::Role;
    use Moose::Util::TypeConstraints;

    subtype 'Natural', as 'Int', where { $_ > 0 };
    has 'quota' => (
        is  => 'ro', 
        isa => 'Natural',
        required => 1,
    );

    has 'picked' => (
        traits  => ['Counter'],
        is      => 'ro',
        isa     => 'Num',
        default => 0,
        handles => {
            inc_picked => 'inc',
        },
    );

    sub pick {
        my ($self) = @_;

        if ($self->picked < $self->quota) {
            $self->inc_picked();
        }
    }
}

eval {
    package Foo::FruitPicker;
    use MooseX::Capsule::Barbed;

    has 'foo' => (is => 'rw');

    interface qw(
        pick
        picked
    );
    implementation qw(Foo::FruitPicker::Role);
};

like($@, qr'Attribute: \w+ not permitted in interface', 'no attributes in interface');

{
    package Foo::FruitPicker::RoleWithAttribute;
    use Moose::Role;

    has 'bar' => (is => 'rw');
}

eval {
    package Foo::FruitPicker2;
    use MooseX::Capsule::Barbed;

    with 'Foo::FruitPicker::RoleWithAttribute';

    interface qw(
        pick
        picked
    );
    implementation qw(Foo::FruitPicker::Role);
};

like($@, qr'Attribute: \w+ not permitted in interface', 'no attributes via roles');

{
    package Foo::FruitPicker::RoleWithMethod;
    use Moose::Role;

    sub bar { 42 }
}

eval {
    package Foo::FruitPicker3;
    use MooseX::Capsule::Barbed;

    with 'Foo::FruitPicker::RoleWithMethod';

    interface qw(
        pick
        picked
    );
    implementation qw(Foo::FruitPicker::Role);
};

like($@, qr'Roles not permitted in interface', 'no roles in interface');

{
    package Foo::FruitPicker4;
    use MooseX::Capsule::Barbed;

    interface qw(
        pick
        picked
    );
    implementation qw(Foo::FruitPicker::Role);
}

package main;

my $obj = Foo::FruitPicker4->new(quota => 1);

eval { $obj->meta->add_attribute(test => (is => 'rw')) };
like($@, qr'Attribute: \w+ not permitted in interface', 'no attributes via meta');

done_testing;
