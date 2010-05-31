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
    my ($class) = @_;

    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));
    my ($file, $link) = map { cfg->get($_) // '' } qw(file link);


    my @added;

    if ($link) {
        if (my @urls = grep /\S/, split /\s+/, $link) {
            for (@urls) {
                my ($res, $err) = $rtpg->add($_);
                push @added, {
                    result  => $res,
                    error   => $err,
                    torrent => $_,
                    type    => 'link',
                };
            }
        }
    }

    if ($file) {
        my $fh = cfg->upload('file');
        my $info = cfg->upload_info('file');

        unless (exists $info->{'Content-Type'}) {
            push @added, {
                result      => undef,
                error       => 'Undefined file type',
                torrent     => $file,
                type        => 'file',
            }
        } elsif ( $info->{'Content-Type'} ne 'application/x-bittorrent') {
            push @added, {
                result      => undef,
                error       => 'This is not torrent file',
                torrent     => $file,
                type        => 'file',
            }
        } else {
            my ($res, $err) = $rtpg->add($fh);
            push @added, {
                result      => $res,
                error       => $err,
                torrent     => $file,
                type        => 'file',
            };
        }
    }

    return bless {
        added   => \@added,
    }, $class;
}

1;
