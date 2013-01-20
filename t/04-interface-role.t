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

{
    package Foo::FruitPicker::RoleInterface;
    use Moose::Role;

    requires qw(pick picked);
}

{
    package Foo::FruitPicker;
    use MooseX::Capsule;

    interface_role 'Foo::FruitPicker::RoleInterface';
    implementation qw(Foo::FruitPicker::Role);
}

my $p = Foo::FruitPicker->new(quota => 3);
ok($p->does('Foo::FruitPicker::RoleInterface'), 'obj does the interface role');
$p->pick for 1 .. 3;
is($p->picked, 3, 'picked');

{
    package Foo::FruitPicker::RoleInterfaceWithAttribute;
    use Moose::Role;

    has 'bar' => (is => 'rw');
    requires qw(pick picked);
}

eval {
    package Foo::FruitPicker2;
    use MooseX::Capsule;

    interface_role 'Foo::FruitPicker::RoleInterfaceWithAttribute';
    implementation qw(Foo::FruitPicker::Role);
};

like($@, qr'Attributes not permitted in interface role', 'no attributes in interface role');

{
    package Foo::FruitPicker::RoleInterfaceWithMethod;
    use Moose::Role;

    requires qw(pick picked);
    sub bar { 42 }
}

eval {
    package Foo::FruitPicker3;
    use MooseX::Capsule;

    interface_role 'Foo::FruitPicker::RoleInterfaceWithMethod';
    implementation qw(Foo::FruitPicker::Role);
};

like($@, qr'Methods not permitted in interface role', 'no methods in interface role');

{
    package Foo::FruitPicker::RoleInterfaceWithMethodUnimplemented;
    use Moose::Role;

    requires qw(pick picked bar);
}

eval {
    package Foo::FruitPicker4;
    use MooseX::Capsule;

    interface_role 'Foo::FruitPicker::RoleInterfaceWithMethodUnimplemented';
    implementation qw(Foo::FruitPicker::Role);
};

like(
    $@, 
    qr|'Foo::FruitPicker::RoleInterfaceWithMethodUnimplemented' requires the method 'bar' to be implemented|, 
    'check interface role against implementation'
);

done_testing;
