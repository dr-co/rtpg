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

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action current debug start stop pause
                                    delete checked );
    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    for my $command ( qw(start stop pause delete) )
    {
        # Skip if not checked
        next unless $opts{$command};
        # Split commands string into hash
        $opts{$command} = [ split ',', $opts{$command} ];
        # Skip if not checked
        next unless @{ $opts{$command} };
        # Do command
        $rtpg->$command( $_ ) for @{ $opts{$command} };
        # If command then drop all cheched cookie
        cfg->set('checked', '');
    }

    # Get list
    ($opts{list}, $opts{error}) = $rtpg->torrents_list( $opts{action} );

    # Split checked string into hash
    $opts{checked} = { map { $_ => 1 } split ';', $opts{checked} }
        if $opts{checked};

    my $self = bless \%opts, $class;

    return $self;
}

1;
