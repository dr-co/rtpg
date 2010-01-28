use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Prop

=cut

package RTPG::WWW::Frame::Prop;
use RTPG;
use RTPG::WWW::Config;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(current prop debug);
    ($opts{info}, $opts{error}) = RTPG->new(url => cfg->get('rpc_uri'))->
        torrent_info( $opts{current} )
            if $opts{current};

    # If debug option aviable die with first list item
    DieDumper \%opts if $opts{debug};

    my $self = bless \%opts, $class;

    return $self;
}

1;
