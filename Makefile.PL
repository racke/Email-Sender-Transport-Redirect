use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Email::Sender::Transport::Redirect',
    AUTHOR              => q{Stefan Hornburg (Racke) <racke@linuxia.de>},
    VERSION_FROM        => 'lib/Email/Sender/Transport/Redirect.pm',
    ABSTRACT_FROM       => 'lib/Email/Sender/Transport/Redirect.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},

    META_MERGE => {
        resources => {
            repository => 'https://github.com/racke/Email-Sender-Transport-Redirect',
        },
    },

    PREREQ_PM => {
        'Test::More' => 0,
        'Moo' => "1.000008",
        'MooX::Types::MooseLike' => "0.15",
        'Email::Sender' => "1.300000",
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Email-Sender-Transport-Redirect-*' },
);
