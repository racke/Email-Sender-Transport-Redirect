package Email::Sender::Transport::Redirect::Recipients;

use strict;
use warnings;
use Moo;
use Email::Valid;
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

has excludes_regexps => (is => 'lazy', isa => ArrayRef);

sub _build_excludes_regexps {
    my $self = shift;
    my @out;
    foreach my $exclusion (@{$self->exclude}) {
        if ($exclusion =~ m/\*/) {
            my $re = $exclusion;
            # http://blogs.perl.org/users/mauke/2015/08/converting-glob-patterns-to-regular-expressions.html
            $re =~ s{(\W)}{
                $1 eq '?' ? '.' :
                $1 eq '*' ? '.*' :
                '\\' . $1
              }eg;
            push @out, qr{$re};
        }
        elsif (my $address = Email::Valid->address($exclusion)) {
            push @out, qr{\Q$address\E};
        }
        else {
            die "Exclusion contains an invalid string: $exclusion, nor a wildcard, nor a valid address: $exclusion";
        }
    }
    return \@out;
}



sub replace {
    my ($self, $mail) = @_;
    if ($mail) {
        if (my @exclusions = @{$self->excludes_regexps}) {
            if (my $address = Email::Valid->address($mail)) {
                my $real = $address . ''; # stringify
                foreach my $re (@exclusions) {
                    if ($real =~ m/\A$re\z/) {
                        return $real;
                    }
                }
            }
        }
    }
    # fall back
    return $self->to;
}

1;
