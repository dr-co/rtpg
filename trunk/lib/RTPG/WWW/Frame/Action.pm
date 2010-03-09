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

    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));
    # Get list
    ($opts{list}, $opts{error}) = $rtpg->view_list();

    # Remove dublicate
    my @list = grep { $_ !~ m/^(main|name)$/ } @{ $opts{list} };
    # Clear object list
    $opts{list} = [];

    for my $action ( @list )
    {
        # Set name to show
        my $name = ucfirst $action;
        # Fix name for default action
        $name = 'All' if $name eq 'Default';
        # Get count (don`t beat me =) )
        my ($list, $error) = $rtpg->torrents_list( $action );
        my $count = ($error) ? '?' : scalar @$list;
        # Set names and titles for actions
        push @{ $opts{list} },
            { action => $action, name => $name, count => $count};
    }

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
