use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::

=cut

package RTPG::Frame::List;
use lib qw(.. ../);
use CGI;
use RTPG::Config;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get parameters
    for my $name ( qw(action) )
    {
        # Get current state
        $opts{$name} = CGI::param($name) || CGI::cookie($name) ||
                        cfg->get($name)  || '';

        # Permanent set new state into cookies
        push @{ $opts{cookies} },
            CGI::cookie(-name => $name, -value => $opts{$name}, -expires => '+2y')
                unless $opts{$name} eq CGI::cookie($name);
    }

    my $self = bless \%opts, $class;

    return $self;
}

1;
