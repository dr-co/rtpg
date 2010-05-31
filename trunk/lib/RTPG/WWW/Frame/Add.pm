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
use RTPG::WWW::Locale qw(gettext);

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    map { $opts{$_} = cfg->get($_) // '' } qw(file link);

    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    # Add by links
    if ($opts{link}) {
        if (my @urls = grep /\S/, split /\s+/, $opts{link}) {
            for (@urls) {
                my ($result, $error) = $rtpg->add($_);
                push @{$opts{result}}, {
                    result  => $result,
                    error   => $error,
                    torrent => $_,
                    type    => 'link',
                };
            }
        }
    }

    # Add by uploaded files
    if ($opts{file}) {
        my $fh   = cfg->upload('file');
        my $info = cfg->upload_info('file');

        unless (exists $info->{'Content-Type'}) {
            push @{$opts{result}}, {
                result      => undef,
                error       => gettext('Undefined file type'),
                torrent     => $opts{file},
                type        => 'file',
            }
        } elsif ( $info->{'Content-Type'} ne 'application/x-bittorrent') {
            push @{$opts{result}}, {
                result      => undef,
                error       => gettext('This is not torrent file'),
                torrent     => $opts{file},
                type        => 'file',
            }
        } else {
            my ($result, $error) = $rtpg->add($fh);
            push @{$opts{result}}, {
                result      => $result,
                error       => gettext($error),
                torrent     => $opts{file},
                type        => 'file',
            };
        }
    }

    my $self = bless \%opts, $class;
}

1;
