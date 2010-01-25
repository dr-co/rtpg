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
use RTPG;
use RTPG::Config;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action current);

    $opts{list} = RTPG::rtorrent->torrents_list( $opts{action} );

#    DieDumper $opts{list}->[0];

    my $self = bless \%opts, $class;

    return $self;
}

1;
