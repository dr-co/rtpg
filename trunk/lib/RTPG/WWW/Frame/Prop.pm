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
use RTPG::WWW::Locale;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(current prop);

    {
        # Exit if no current selected
        last unless $opts{current};
        # Get RTPG object
        my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

        # Get info by page name
        if( $opts{prop} eq 'info')
        {
            ($opts{info}, $opts{error}) = $rtpg->torrent_info( $opts{current} );
        }
        elsif($opts{prop} eq 'peers')
        {
            my ($error1, $error2);
            ($opts{info}, $error1) = $rtpg->torrent_info( $opts{current} );
            ($opts{list}, $error2) = $rtpg->peer_list( $opts{current} );

            $opts{error} = $error1 || $error2 || '';

            if( cfg->is_geo_ip and eval "require Geo::IPfree" and !$@)
            {
                my $geo = Geo::IPfree->new;
                $geo->Faster;
                ($_->{country_code}, $_->{country_name},) =
                    $geo->LookUp( $_->{address} )
                        for @{ $opts{list} };
            }
        }
        elsif($opts{prop} eq 'files')
        {
            ($opts{info}, $opts{error}) = $rtpg->torrent_info( $opts{current} );
            ($opts{list}, $opts{error}) = $rtpg->file_list( $opts{current} );
        }
        elsif($opts{prop} eq 'trackers')
        {
            ($opts{info}, $opts{error}) = $rtpg->tracker_list( $opts{current} );
        }
        elsif($opts{prop} eq 'chunks')
        {
        }
        elsif($opts{prop} eq 'transfer')
        {
        }
        else
        {
            $opts{error} = RTPG::WWW::Locale::gettext('Unknown property page');
        }
    }

    my $self = bless \%opts, $class;

    return $self;
}

1;
