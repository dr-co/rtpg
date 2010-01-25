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
use RTPG;

my %params = (version => $VERSION);

# Setting up rtorrent ##########################################################
RTPG::rtorrent( url => cfg->get('rpc_uri') );

# Get params ###################################################################
my $show = CGI::param('show') || 'index';
$show =~ s/\.cgi.*//g;

for my $name ( qw(locale refresh skin action current) )
{
    # Get new parameter value
    my $value = CGI::param($name);
    # Set new state if value exists
    cfg->set($name, $value) if $value;
}

# Load module and get data #####################################################
my $module = 'RTPG::Frame::' . ucfirst lc $show;
eval "require $module";
if( $@ )
{
    $show = 'error';
    $params{error} = { message => $@, status => 503 };
}

$params{data} = $module->get;

# Files for this page ##########################################################
my ($css, $js) = (
    cfg->{url}{skin}{base} . '/' . $show . '.css',
    cfg->{url}{skin}{base} . '/' . $show . '.js',
);
cfg->{url}{skin}{css} = $css if -f $css;
cfg->{url}{skin}{js}  = $js  if -f $js;

# Output #######################################################################
my $template = RTPG::Template->new;
$template->process( $show . '.tt.html', \%params );
