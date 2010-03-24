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

use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use File::Spec;

our $VERSION = "0.2.0";

use lib qw(../lib);
use RTPG::WWW::Config;
use RTPG::WWW::Template;
use RTPG::WWW::Locale;
use RTPG;

my %params = (version => $VERSION);

# Get params ###################################################################
($params{show}) = $ENV{REQUEST_URI} =~ m{^/?(.*)\.cgi};
$params{show} ||= CGI::param('show') || 'index';

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
if( -f cfg->{dir}{skin}{current} . '/' . $params{show} . '.css' )
{
    cfg->{url}{skin}{css} =
        cfg->{url}{skin}{base} . '/' . $params{show} . '.css';
}
elsif( -f cfg->{dir}{skin}{default} . '/' . $params{show} . '.css' )
{
    cfg->{url}{skin}{css} =
        cfg->{url}{skin}{default} . '/' . $params{show} . '.css';
}

if( -f cfg->{dir}{skin}{current} . '/' . $params{show} . '.js' )
{
    cfg->{url}{skin}{js}  =
        cfg->{url}{skin}{base} . '/' . $params{show} . '.js';
}
elsif( -f cfg->{dir}{skin}{default} . '/' . $params{show} . '.js' )
{
    cfg->{url}{skin}{js}  =
        cfg->{url}{skin}{default} . '/' . $params{show} . '.js';
}

# Output #######################################################################
my ($template, $file);
# Output for js strings
if($params{show} eq 'string')
{
    $template   = RTPG::WWW::Template->new(WRAPPER => undef);
    $file       = $params{show} . '.tt.js';
}
# Output for html
else
{
    $template   = RTPG::WWW::Template->new;
    $file       = $params{show} . '.tt.html';
}
$template->process( $file, \%params );
