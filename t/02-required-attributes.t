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
    package Foo::FruitPicker;
    use MooseX::Capsule;

    interface qw(
        pick
        picked
    );
    implementation qw(Foo::FruitPicker::Role);
}

my $p = Foo::FruitPicker->new(quota => 3);
$p->pick for 1 .. 3;
is($p->picked, 3, 'picked');
$p->pick;
is($p->picked, 3, 'quota enforced');
done_testing;
