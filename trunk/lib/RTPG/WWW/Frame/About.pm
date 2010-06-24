use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::About

=head1 DESCRIPTION

Class for manage About dialog

=cut

package RTPG::WWW::Frame::About;
use RTPG;
use RTPG::WWW::Config;
use RTPG::WWW::Locale qw(gettext);

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    # Get information about system
    ($opts{info}, $opts{error}) = $rtpg->system_information;

    my $self = bless \%opts, $class;
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
