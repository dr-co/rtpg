#!/usr/bin/perl

=head1 index.cgi

This is controller script

=cut

use warnings;
use strict;
use utf8;
use open ':utf8';
use lib qw(../lib);

our $VERSION = "0.2.0";

use CGI::Carp qw(fatalsToBrowser);
use RTPG::WWW::Config;
use RTPG::WWW::Template;
use RTPG::WWW::Locale;
use RTPG;

my %params = (version => $VERSION);

# Get params ###################################################################
my $show = CGI::param('show') || 'index';
$show =~ s/\.cgi.*//g;

for my $name ( qw(locale refresh skin action current prop) )
{
    # Get new parameter value
    my $value = CGI::param($name);
    # Set new state if value exists
    cfg->set($name, $value) if $value;
}

# Load module and get data #####################################################
my $module = 'RTPG::WWW::Frame::' . ucfirst lc $show;
eval "require $module";
if( $@ )
{
    $show = 'error';
    $params{error} = { message => $@, status => 503 };
}

$params{data} = $module->get;
if( $params{data}{error} )
{
    $show = 'error';
    $params{error} = { message => $params{data}{error}, status => 503 };
}

# Files for this page ##########################################################
cfg->{url}{skin}{css} = cfg->{url}{skin}{base} . '/' . $show . '.css'
    if -f cfg->{dir}{skin}{current} . '/' . $show . '.css';
cfg->{url}{skin}{js}  = cfg->{url}{skin}{base} . '/' . $show . '.js'
    if -f cfg->{dir}{skin}{current} . '/' . $show . '.js';

# Output #######################################################################
my $template = RTPG::WWW::Template->new;
$template->process( $show . '.tt.html', \%params );
