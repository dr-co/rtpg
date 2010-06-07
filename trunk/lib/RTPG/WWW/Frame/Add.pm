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
        } elsif ( !__PACKAGE__->_check_if_bencoded($fh) ) {
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
                error       => $error,
                torrent     => $opts{file},
                type        => 'file',
            };
        }
    }

    my $self = bless \%opts, $class;
}


=head2 _check_if_bencoded

private function. returns FALSE if input data isn't torrent file.
It will be rewritten if L<Convert::Bencode> is added into Debian.

=cut

sub _check_if_bencoded {
    my ($self, $data) = @_;

    return undef unless defined $data;

    # input data is FILE object
    if (ref $data) {
        local $/;
        binmode $data;
        my $d = <$data>;
        seek $data, 0, 0; # reseek for next using
        return $self->_check_if_bencoded($d);
    }

    # TRUE if recurse call is detected
    my $req_call = (caller 0)[3] ~~ (caller 1)[3];

    # bencode parser
    for (my $i = 0; $i < length $data; $i++) {
        my $ss = substr $data, $i;
        # integers
        if ($ss =~ /^(i-?\d+e)/) {
            $i += -1 + length $1;
            next;
        }
        # strings
        if ($ss =~ /^(\d+):/) {
            my $nl = $1 + 1 + length $1;
            return undef if $nl >= length $ss;
            $i += $nl - 1;
            next;
        }
        # lists and hashes
        if ($ss =~ /^([ld])/) {
            return undef unless 2 < length $ss;
            $ss = substr $ss, 1;
            my $r = $self->_check_if_bencoded($ss);
            return undef unless defined $r;
            return undef if $i + $r + 1 >= length $data;
            return undef unless 'e' eq substr $data, $i + $r + 1, 1;
            $i += $r + 2 - 1;
            next;
        }

        return $i if $req_call;
        return undef;
    }
    return length $data;
}


1;
