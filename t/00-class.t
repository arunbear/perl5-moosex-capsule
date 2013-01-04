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
    use Moose;
    use MooseX::Capsule;

    interface [qw(
        add
        delete
        exists
        is_empty
        size
    )];
    implementation 'Foo::Set::Implementation';
}

diag( "Testing MooseX::Capsule $MooseX::Capsule::VERSION, Perl $], $^X" );

my $s = Foo::Set->new;
ok($s->is_empty, 'is_empty');
ok(! $s->exists('foo'), 'not exists');

$s->add('foo');
ok($s->exists('foo'), 'exists');

$s->add('foo');
$s->add('bar');
is($s->size, 2, 'size');

$s->delete('foo');
is($s->size, 1, 'delete');

eval { $s->clear() };
like($@, qr{Can't locate object method "clear" via package "Foo::Set"}, 'method not exposed');

done_testing;
