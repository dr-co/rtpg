use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::

=cut

package RTPG::Frame::Status;
use lib qw(.. ../);

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;

    return $self;
}

1;
