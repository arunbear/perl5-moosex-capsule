#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

{
    package Foo::Role1;
    use Moose::Role;

    sub foo { 1 }
}

{
    package Foo::Role2;
    use Moose::Role;

    has 'bar' => (
        is => 'rw', 
        writer => 'set_bar',
        default => 2,
    );
}

{
    package Foo;
    use MooseX::Capsule::Barbed;

    interface qw(
        foo
        bar
    );
    implementation qw(Foo::Role1 Foo::Role2);
}

my $s = Foo->new;
is($s->foo, 1, 'method from 1st role');
is($s->bar, 2, 'method from 2nd role');
done_testing;
