#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

{
    package Foo::Set::Implementation;
    use Moose::Role;

    has 'store' => (
        is => 'ro',
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
}

{
    package Foo::Set;
    use MooseX::Capsule;

    implementation 'Foo::Set::Implementation';
}

my $s = Foo::Set->new;
isa_ok($s, 'Foo::Set');
ok(! $s->can('is_empty'), 'no is_empty method');
is_deeply([qw/meta/], [$s->meta->get_method_list], 'method_list');

done_testing;
