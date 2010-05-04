use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::List

=cut

package RTPG::WWW::Frame::List;

use RTPG;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action current debug do);
    $opts{hash} = {};
    $opts{hash} = { map { $_ => 'checked' } cfg->get('hash[]') }
        if cfg->get('hash[]');

    # If priority command then get priority level
    if($opts{do} =~ m/^(off|low|normal|high)$/i)
    {
        $opts{param}    = ($opts{do} eq 'off')    ?0    :
                          ($opts{do} eq 'low')    ?1    :
                          ($opts{do} eq 'normal') ?2    :3;
        $opts{do}       = 'priority';
    }

    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    {{
        my $error;
        # Check exists current
        ($opts{list}, $error) = $rtpg->torrents_list;
        $opts{error} ||= $error;
        unless( grep {$_->{hash} eq $opts{current}} @{ $opts{list} } )
        {
            # Drop current if not in list
            cfg->set('current', '');
            $opts{current} = '';
        }

        # Skip if command not set
        last unless $opts{do};
        # Skip if not checked
        last if !('HASH' eq ref $opts{hash} and %{$opts{hash}}) and
                ! $opts{current};
        # Get command name
        my $command = $opts{do};
        # Get torrents hash from checked torrents or current torrent
        my @torrents = keys %{ $opts{hash} };
        push @torrents, $opts{current} unless @torrents;
        # Do command
        $rtpg->$command( $_, $opts{param} ) for @torrents;
        # If command then drop all cheched cookie
        cfg->set('checked', $opts{hash} = '');
        # If "delete" command drop current value
        cfg->set('current', $opts{current} = '') if $command eq 'delete';
    }}

    # Get list
    ($opts{list}, $opts{error}) = $rtpg->torrents_list( $opts{action} );

    my $self = bless \%opts, $class;

    return $self;
}

1;
