use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MooseX::Capsule',
    license             => 'Artistic_2_0',
    dist_author         => q{Arun Prasaad <arunbear@cpan.org>},
    dist_version_from   => 'lib/MooseX/Capsule.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Moose' => '2.0401',
    },
    add_to_cleanup     => [ 'MooseX-Capsule-*' ],
    create_makefile_pl => 'traditional',
    meta_merge => {
        resources => {
            homepage   => 'https://github.com/arunbear/perl5-moosex-capsule',
            bugtracker => 'https://github.com/arunbear/perl5-moosex-capsule/issues',
            repository => 'https://github.com/arunbear/perl5-moosex-capsule',
        }
    },
);

$builder->create_build_script();
