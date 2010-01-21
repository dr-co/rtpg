#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ../lib);

use utf8;
use open ':utf8';

use CGI::Carp qw(fatalsToBrowser);
use RTPG::Config;
use RTPG::Template;

# Get page name ################################################################
my $show = CGI::param('show') || 'index';
$show =~ s/\.cgi.*//g;

# Load module and get data #####################################################
if( $show ne 'index' )
{
    my $module = 'RTPG::Frame::' . ucfirst lc $show;
#    require "$module";
}

# Files for this page ##########################################################
my ($css, $js) = (
    cfg()->{url}{skin}{base} . '/' . $show . '.css',
    cfg()->{url}{skin}{base} . '/' . $show . '.js',
);
cfg()->{url}{skin}{css} = $css if -f $css;
cfg()->{url}{skin}{js}  = $js if -f $js;

# Output #######################################################################
my $template = RTPG::Template->new;
$template->process( $show . '.tt.html' );
