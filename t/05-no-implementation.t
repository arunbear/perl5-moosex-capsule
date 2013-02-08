#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

{
    package Foo::Set;
    use MooseX::Capsule;
}

{
    my $s = Foo::Set->new;
    isa_ok($s, 'Foo::Set');
    ok(! $s->can('add'), 'no add method');
    is_deeply([qw/meta/], [$s->meta->get_method_list], 'method_list');
}

{
    package Foo::Set2;
    use MooseX::Capsule;

    interface qw(
        add
    );
}

{
    my $s = Foo::Set2->new;
    isa_ok($s, 'Foo::Set2');
    ok(! $s->can('add'), 'no add method');
    is_deeply([qw/meta/], [$s->meta->get_method_list], 'method_list');
}

done_testing;
