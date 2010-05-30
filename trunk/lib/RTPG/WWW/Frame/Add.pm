use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::Add

=head1 DESCRIPTION

Class for javascript localization support

=cut

package RTPG::WWW::Frame::Add;
use RTPG;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    $opts{$_} = cfg->get($_) for qw(file link);

    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    # Add new file/links
    if( $opts{link} )
    {
        # Split array of links and add them to download
        $opts{link} = [ grep {m/^\S+$/} split "\r?\n", $opts{link} ];
        ($opts{result}, $opts{error}) = $rtpg->add( $opts{link} );
    }
    elsif( $opts{file} )
    {{
        # Get info about file
        $opts{fh}       = cfg->upload('file');
        $opts{fileinfo} = cfg->upload_info('file');

        # Check for file type present
        $opts{message} = 'Undefined file type',
        last
            unless exists $opts{fileinfo}{'Content-Type'};
        # Check for .torrent file
        $opts{message} = 'This is not torrent file',
        last unless
            $opts{fileinfo}{'Content-Type'} eq 'application/x-bittorrent';

        # Add new torrent download
        ($opts{result}, $opts{error}) = $rtpg->add($opts{fh});
    }}

    # Set source string
    $opts{source}  = ($opts{link}) ?'link' :($opts{file}) ?'file' :'';
    # If no error message and not set result string then set filename
    $opts{result} ||=
        ($opts{link}) ?$opts{link} :($opts{file}) ?$opts{file} :undef
            unless $opts{message};

    my $self = bless \%opts, $class;

    return $self;
}

1;
