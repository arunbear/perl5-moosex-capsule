#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

{
    package Foo::Role;
    use Moose::Role;

    sub foo { 'public' }
    sub bar { 'protected' }
}

{
    package Foo::Base;
    use Moose;
    use MooseX::Capsule;

    interface qw(foo);
    protected qw(bar);
    implementation qw(Foo::Role);
}

{
    package Foo::Subclass;
    use Moose;

    extends 'Foo::Base';

    sub baz { $_[0]->bar }
}

my $s = Foo::Subclass->new;
is($s->foo, 'public', 'public method');
is($s->baz, 'protected', 'protected method');

eval { $s->bar };
like($@, qr{Call to bar\(\) not permitted from main}, 'method not allowed');
done_testing;
