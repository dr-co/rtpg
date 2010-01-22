#!/usr/bin/perl

=head1 index.cgi

This is controller script

=cut

use warnings;
use strict;
use utf8;
use open ':utf8';
use lib qw(lib ../lib ../);

our $VERSION = "0.2.0";

use CGI::Carp qw(fatalsToBrowser);
use RTPG::Config;
use RTPG::Template;
use RTPG::Locale;

my %params;

# Get page name ################################################################
my $show = CGI::param('show') || 'index';
$show =~ s/\.cgi.*//g;

# Load module and get data #####################################################
if( $show ne 'index' )
{
    my $module = 'RTPG::Frame::' . ucfirst lc $show;
    eval "require $module";
    if( $@ )
    {
        $show = 'error';
        $params{error} = { message => $@, status => 503 };
    }

    $params{data} = $module->get;
}

# Files for this page ##########################################################
my ($css, $js) = (
    cfg->{url}{skin}{base} . '/' . $show . '.css',
    cfg->{url}{skin}{base} . '/' . $show . '.js',
);
cfg->{url}{skin}{css} = $css if -f $css;
cfg->{url}{skin}{js}  = $js if -f $js;

# Output #######################################################################
my $template = RTPG::Template->new;
$template->process( $show . '.tt.html', \%params );
