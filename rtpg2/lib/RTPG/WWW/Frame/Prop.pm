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

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(current prop debug);

    if( $opts{prop} eq 'info')
    {
        ($opts{info}, $opts{error}) = RTPG->new(url => cfg->get('rpc_uri'))->
            torrent_info( $opts{current} )
                if $opts{current};
    }
    elsif($opts{prop} eq 'peers')
    {
        ($opts{info}, $opts{error}) = RTPG->new(url => cfg->get('rpc_uri'))->
            torrent_info( $opts{current} )
                if $opts{current};
    }
    elsif($opts{prop} eq 'files')
    {
        ($opts{info}, $opts{error}) = RTPG->new(url => cfg->get('rpc_uri'))->
            file_list( $opts{current} )
                if $opts{current};
    }
    elsif($opts{prop} eq 'trackers')
    {
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

    # If debug option aviable die with first list item
    DieDumper \%opts if $opts{debug};

    my $self = bless \%opts, $class;

    return $self;
}

1;
