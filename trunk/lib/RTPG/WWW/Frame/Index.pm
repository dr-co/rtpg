use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Index

=cut

package RTPG::WWW::Frame::Index;
use RTPG;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(locale horizontal vertical);

    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    $opts{methods} =[ $rtpg->_get_list_methods ] if cfg->get('debug');

    ($opts{info}, $opts{error}) = $rtpg->system_information;

    my $self = bless \%opts, $class;

    return $self;
}

1;
