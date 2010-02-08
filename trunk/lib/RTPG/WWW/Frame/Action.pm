use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Action

=cut

package RTPG::WWW::Frame::Action;
use CGI;
use RTPG::WWW::Config;
use RTPG::WWW::Locale qw(gettext);
#use RPC::XML::base64;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action upload);

    # Add uploaded file
#    if( $opts{upload} )
#    {
#        my $fh = CGI::upload('upload');
#        unless ($fh)
#        {
#            $opts{error} = gettext('Error upload torrent');
#            last;
#        }
#        local $/;
#
#        my $torrent = RPC::XML::base64->new(<$fh>);
#        ($opts{info}, $opts{error}) =
#            $rtorrent->rpc_command(load_raw => $torrent);
#    }

    my $self = bless \%opts, $class;

    return $self;
}

1;
