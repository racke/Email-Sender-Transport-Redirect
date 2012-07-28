package Email::Sender::Transport::Redirect;
{
    $Email::Sender::Transport::Redirect::VERSION = '0.0001';
}

=head1 NAME

Email::Sender::Transport::Redirect - Intercept all emails and redirect them to a specific address

=head1 VERSION

Version 0.0001

=head1 SYNOPSIS

    $transport_orig = Email::Sender::Transport::Sendmail->new;

    $transport = Email::Sender::Transport::Redirect->new({transport => $transport_orig,
                                                         redirect_address => 'shop@nitesi.com',
                                                         });

=head1 DESCRIPTION

Transport wrapper for Email::Sender which intercepts all emails and redirects
them to a specific address.

This transport changes the C<To> and C<CC> header in the email and
adds a C<X-Intercepted-To> and C<X-Intercepted-CC> header with
the original recipients.

=cut

use Moose;

extends 'Email::Sender::Transport::Wrapper';

has 'redirect_address' => (is => 'ro',
                          required => 1,
                          );

has 'redirect_headers' => (
                           is  => 'ro',
                           isa => 'ArrayRef',
                           auto_deref => 1,
                           default    => sub { [qw/To Cc/] },
);

has 'intercept_prefix' => (
                           is => 'ro',
                           isa => 'Str',
                           default => sub { 'X-Intercepted-'}
                          );

around send_email => sub {
    my ($orig, $self, $email, $env, @rest) = @_;
    my ($email_copy, $env_copy, @values);

    # copy email object to prevent changes in the original object
    $email_copy = ref($email)->new($email->as_string);

    # copy envelope hash reference
    %$env_copy = %$env;

    for my $header ($self->redirect_headers) {
        next unless @values = $email_copy->get_header($header);

        if ($self->intercept_prefix) {
            $email_copy->set_header($self->intercept_prefix . $header,
                                    @values);
        }

        $email_copy->set_header($header);
    }

    $email_copy->set_header('To', $self->redirect_address);
    $env_copy->{to} = [$self->redirect_address];

    return $self->$orig($email_copy, $env_copy, @rest);
};

=head1 AUTHOR

Stefan Hornburg (Racke), C<racke@linuxia.de>

=head1 BUGS

Please report any bugs or feature requests to C<bug-email-sender-transport-redirect at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Email-Sender-Transport-Redirect>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Email::Sender::Transport::Redirect


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Email-Sender-Transport-Redirect>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Email-Sender-Transport-Redirect>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Email-Sender-Transport-Redirect>

=item * Search CPAN

L<http://search.cpan.org/dist/Email-Sender-Transport-Redirect/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to Matt Trout for his help regarding the initial write of this
module on #dancer IRC.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Email::Sender::Transport::Redirect
