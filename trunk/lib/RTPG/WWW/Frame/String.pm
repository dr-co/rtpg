use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::String

=head1 DESCRIPTION

Class for javascript localization support

=cut

package RTPG::WWW::Frame::String;
use RTPG::WWW::Locale qw(gettext);
=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Strings
    $opts{info} = {
        # Add
        STR_WINDOW_ADD_NAME => gettext('Add new torrent'),
        # Action
        # Index
        # List
        # Panel
        STR_NO_SELECTED     => gettext('No current torrent selected'),
        # Prop
        # Status
    };

    my $self = bless \%opts, $class;

    return $self;
}

1;
