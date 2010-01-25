use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::

=cut

package RTPG::Frame::Status;
use lib qw(.. ../);
use RTPG;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    $opts{info} = RTPG::rtorrent->system_information;

    my $self = bless \%opts, $class;

    return $self;
}

1;
