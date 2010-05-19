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

    my $self = bless \%opts, $class;

    return $self;
}

1;
