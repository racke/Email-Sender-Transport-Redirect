#perl

use strict;
use warnings;
use Test::More tests => 7;
use Email::Sender::Transport::Redirect::Recipients;

{
    my $str = 'pippo@example.com';
    my $rec = Email::Sender::Transport::Redirect::Recipients->new($str);
    is $rec->to, $str, "to is $str";
    is_deeply $rec->exclude, [], "No exclusion";
}

{
    my %hash = (to => 'pippo@example.com', exclude => ['racke@example.com', '*@linuxia.de']);
    my $rec = Email::Sender::Transport::Redirect::Recipients->new(\%hash);
    foreach my $f (qw/to exclude/) {
        is_deeply $rec->$f, $hash{$f}, "$f is ok";
    }
}

{
    my @dummy = ('racke@example.com', '*@linuxia.de');
    my $rec = eval { Email::Sender::Transport::Redirect::Recipients->new(@dummy) };
    ok !$rec, "Bad arguments trigger an exception: $@";
}

{
    my @dummy = ('racke@example.com', '*@linuxia.de');
    my $rec = eval { Email::Sender::Transport::Redirect::Recipients->new(\@dummy) };
    ok !$rec, "Bad arguments trigger an exception: $@";
}


{
    my %hash = (to => 'pippo@example.com', exclude => ['racke@example.com', '*@linuxia.de'],
                dummy => 'adfa');
    my $rec = eval { Email::Sender::Transport::Redirect::Recipients->new(\%hash) };
    ok !$rec, "Extra arguments trigger an exception: $@";
}
