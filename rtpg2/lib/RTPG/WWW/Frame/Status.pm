use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Status

=cut

package RTPG::WWW::Frame::Status;
use RTPG;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    ($opts{info}, $opts{error}) = RTPG->new(url => cfg->get('rpc_uri'))->
        system_information;

    my $self = bless \%opts, $class;

    return $self;
}

1;
