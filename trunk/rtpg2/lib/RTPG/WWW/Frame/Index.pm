use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Index

=cut

package RTPG::WWW::Frame::Index;
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
    $opts{$_} = cfg->get($_) for qw(locale debug);

    if( $opts{debug} )
    {
        $opts{methods} =
            [ RTPG->new(url => cfg->get('rpc_uri'))->_get_list_methods ];
        DieDumper \%opts;
    }

    my $self = bless \%opts, $class;

    return $self;
}

1;
