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

    has 'secret_sauce' => (is => 'rw');

    sub pick {
        my ($self) = @_;

        if ($self->picked < $self->quota) {
            $self->inc_picked();
        }
    }

    sub sauce_name {
        my ($self) = @_;
        $self->secret_sauce;
    }
}

{
    package Foo::FruitPicker;
    use MooseX::Capsule;

    interface qw(
        pick
        picked
        sauce_name
    );
    implementation qw(Foo::FruitPicker::Role);
}

my $p = Foo::FruitPicker->new(quota => 3);
$p->pick for 1 .. 3;
is($p->picked, 3, 'picked');
$p->pick;
is($p->picked, 3, 'quota enforced');

my $p2 = Foo::FruitPicker->new(quota => 4, picked => 3, secret_sauce => 'bbq');
is($p2->picked, 0, "can't set non required attribute");
is($p2->sauce_name, undef, "can't set internal attribute");

done_testing;
