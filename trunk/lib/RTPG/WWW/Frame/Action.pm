use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::Action

=head1 DESCRIPTION

Class for manage Action frame

=cut

package RTPG::WWW::Frame::Action;
use CGI;
use RTPG::WWW::Config;
use RTPG::WWW::Locale qw(gettext);
#use RPC::XML::base64;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action upload);

    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));
    # Get list
    ($opts{list}, $opts{error}) = $rtpg->view_list(full => 1);

    # removed duplicates
    @{ $opts{list} } = grep { $_->{name} !~ /^(main|name)$/ } @{ $opts{list} };

    # making action and name
    for (@{ $opts{list} }) {
        $_->{action} = $_->{name};
        $_->{name} = ucfirst $_->{name};
    }

    return bless \%opts, $class;
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
