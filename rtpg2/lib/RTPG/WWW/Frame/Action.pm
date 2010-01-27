use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Action

=cut

package RTPG::WWW::Frame::Action;
use CGI;
use RTPG::WWW::Config;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action);

    my $self = bless \%opts, $class;

    return $self;
}

1;
