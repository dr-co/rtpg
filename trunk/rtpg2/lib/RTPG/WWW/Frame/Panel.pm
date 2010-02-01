use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Frame::Panel

=cut

package RTPG::WWW::Frame::Panel;
use RTPG::WWW::Config;

=head2 get

Get params

=cut

sub get
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(locale refresh skin debug);

    # If debug option aviable die with first list item
    DieDumper \%opts if $opts{debug};

    my $self = bless \%opts, $class;

    return $self;
}

1;
