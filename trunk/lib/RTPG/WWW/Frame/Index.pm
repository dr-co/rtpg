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
    $opts{$_} = cfg->get($_) for qw(locale);

    $opts{methods} =[ RTPG->new(url => cfg->get('rpc_uri'))->_get_list_methods ]
        if cfg->get('debug');

    my $self = bless \%opts, $class;

    return $self;
}

1;
