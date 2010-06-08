use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::Status

=head1 DESCRIPTION

Class for manage Status frame

=cut

package RTPG::WWW::Frame::Status;
use RTPG;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(download_rate upload_rate);

    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    # Do commands
    $rtpg->set_download_rate($opts{download_rate})
        if $opts{download_rate} =~ m/^\d+$/;
    $rtpg->set_upload_rate($opts{upload_rate})
        if $opts{upload_rate} =~ m/^\d+$/;

    my $error;
    # Get information about system
    ($opts{info}, $error) = $rtpg->system_information;
    $opts{error} ||= $error;

    # Get information about rates
    ($opts{rates}, $error) = $rtpg->rates;
    $opts{error} ||= $error;

    # Sum current rates
    ($opts{list}, $error) = $rtpg->torrents_list;
    $opts{error} ||= $error;
    $opts{rates}{current_upload_rate} = 0;
    $opts{rates}{current_download_rate} = 0;
    map {
        $opts{rates}{current_upload_rate}   += $_->{up_rate};
        $opts{rates}{current_download_rate} += $_->{down_rate};
    } @{ $opts{list} };

    my $self = bless \%opts, $class;

    return $self;
}

1;

=head1 AUTHORS

Copyright (C) 2008 Dmitry E. Oboukhov <unera@debian.org>,

Copyright (C) 2008 Roman V. Nikolaev <rshadow@rambler.ru>

=head1 LICENSE

This program is free software: you can redistribute  it  and/or  modify  it
under the terms of the GNU General Public License as published by the  Free
Software Foundation, either version 3 of the License, or (at  your  option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even  the  implied  warranty  of  MERCHANTABILITY  or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public  License  for
more details.

You should have received a copy of the GNU  General  Public  License  along
with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
