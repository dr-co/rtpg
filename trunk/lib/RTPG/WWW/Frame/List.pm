use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::List

=head1 DESCRIPTION

Class for manage List frame

=cut

package RTPG::WWW::Frame::List;

use RTPG;
use RTPG::WWW::Config;

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(action current debug do);
    $opts{hash} = {};
    $opts{hash} = { map { $_ => 'checked' } cfg->get('hash[]') }
        if cfg->get('hash[]');

    $opts{do} ||= 'refresh';

    # If priority command then get priority level
    if($opts{do} =~ m/^(off|low|normal|high)$/i)
    {
        $opts{param} = RTPG::torrent_priority_num( $opts{do} );
        $opts{do}       = 'priority';
    }


    # Get RTPG object
    my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));

    {{
        last if $opts{do} eq 'refresh';
        my $error;

        # Check exists current
        ($opts{list}, $error) = $rtpg->torrents_list;
        $opts{error} ||= $error;
        unless( grep {$_->{hash} eq $opts{current}} @{ $opts{list} } )
        {
            # Drop current if not in list
            cfg->set('current', '');
            $opts{current} = '';
        }

        # Skip if not checked
        last if !('HASH' eq ref $opts{hash} and %{$opts{hash}}) and
                ! $opts{current};
        # Get command name
        my $command = $opts{do};
        # Get torrents hash from checked torrents or current torrent
        my @torrents = keys %{ $opts{hash} };
        push @torrents, $opts{current} unless @torrents;

        $rtpg->$command( $_, $opts{param} ) for @torrents;

        # If "delete" command drop current value
        cfg->set('current', $opts{current} = '') if $command eq 'delete';

    }}

    # Get list
    ($opts{list}, $opts{error}) = $rtpg->torrents_list( $opts{action} );

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
