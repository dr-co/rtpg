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

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action current debug);

    ($opts{list}, $opts{error}) = RTPG->new(url => cfg->get('rpc_uri'))->
        torrents_list( $opts{action} );

    # If debug option aviable die with first list item
    DieDumper \%opts if $opts{debug};

    my $self = bless \%opts, $class;

    return $self;
}

1;
