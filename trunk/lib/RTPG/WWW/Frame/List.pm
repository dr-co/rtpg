use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::List

=cut

package RTPG::WWW::Frame::List;
use CGI;
use RTPG;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action current debug start stop checked );

    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    # Do commands
    $rtpg->start($opts{start})      if $opts{start};
    $rtpg->stop($opts{stop})        if $opts{stop};
    $rtpg->delete($opts{delete})    if $opts{delete};

    # Get list
    ($opts{list}, $opts{error}) = $rtpg->torrents_list( $opts{action} );

    # Split checked string into hash
    $opts{checked} = { map { $_ => 1 } split ';', $opts{checked} };

    my $self = bless \%opts, $class;

    return $self;
}

1;