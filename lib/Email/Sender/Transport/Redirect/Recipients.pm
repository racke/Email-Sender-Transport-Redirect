package Email::Sender::Transport::Redirect::Recipients;

use strict;
use warnings;
use Moo;
use Types::Standard qw/ArrayRef Str/;

has to => (is => 'ro', isa => Str, required => 1);
has exclude => (is => 'ro', isa => ArrayRef[Str], default => sub { [] });

sub BUILDARGS {
    my ($class, @args) = @_;
    die "Only one argument is supported!" unless @args == 1;
    my $arg = shift @args;
    if (my $kind = ref($arg)) {
        if ($kind eq 'HASH') {
            my %hash = %$arg;
            foreach my $k (keys %hash) {
                die "Extra argument $k" unless $k eq 'to' || $k eq 'exclude';
            }
            return \%hash;
        }
        die "Argument must be an hashref with to and exclude keys, you passed a $kind";
    }
    else {
        return { to => $arg };
    }
}

1;
