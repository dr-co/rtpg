use warnings;
use strict;
use utf8;

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
    ($opts{list}, $opts{error}) = $rtpg->view_list(full => 1);

    # removed duplicates
    @{ $opts{list} } = grep { $_->{name} !~ /^(main|name)$/ } @{ $opts{list} };

    # making action and name
    for (@{ $opts{list} }) {
        $_->{action} = $_->{name};
        $_->{name} = ucfirst $_->{name};
    }

    return bless \%opts, $class;
}

1;
