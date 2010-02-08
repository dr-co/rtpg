use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Panel

=cut

package RTPG::WWW::Frame::Panel;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(locale refresh skin);

    my $self = bless \%opts, $class;

    return $self;
}

1;
