#!/usr/bin/perl

=head1 NAME

index.cgi - controller script

=head1 DEBUG

For debug use addresses with debug parameter. For example:

    http://my_page/index.cgi?debug=1
    http://my_page/prop.cgi?debug=1
    http://my_page/list.cgi?debug=1
    etc.

then you can see all variables for templates.

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
$params{show} = CGI::param('show') || 'index';
$params{show} =~ s/\.cgi.*//g;

# Load module and get data #####################################################
my $module = 'RTPG::WWW::Frame::' . ucfirst lc $params{show};
eval "require $module";
if( $@ )
{
    $params{show}   = 'error';
    $params{error}  = { message => $@, status => 503 };
}

$params{data} = $module->new;
if( $params{data}{error} )
{
    $params{show}   = 'error';
    $params{error}  = { message => $params{data}{error}, status => 503 };
}

# If debug option aviable die with params ######################################
DieDumper \%params if cfg->get('debug');

# Files for this page ##########################################################
cfg->{url}{skin}{css} = cfg->{url}{skin}{base} . '/' . $params{show} . '.css'
    if -f cfg->{dir}{skin}{current} . '/' . $params{show} . '.css';
cfg->{url}{skin}{js}  = cfg->{url}{skin}{base} . '/' . $params{show} . '.js'
    if -f cfg->{dir}{skin}{current} . '/' . $params{show} . '.js';

# Output #######################################################################
my $template = RTPG::WWW::Template->new;
$template->process( $params{show} . '.tt.html', \%params );
