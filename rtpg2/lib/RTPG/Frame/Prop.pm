use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::

=cut

package RTPG::Frame::Prop;
use lib qw(.. ../);
use RTPG;
use RTPG::Config;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(current debug);
    ($opts{info}, $opts{error}) = RTPG::rtorrent->torrent_info( $opts{current} );

    # If debug option aviable die with first list item
    DieDumper \%opts if $opts{debug};

    my $self = bless \%opts, $class;

    return $self;
}

1;
