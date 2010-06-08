#!/usr/bin/perl

=head1 NAME

index.cgi - controller script

=head1 DEBUG

For debug use addresses with debug parameter. For example:

    http://my_page/index.cgi?show=list&debug=1
    etc.

then you can see all variables for templates.

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

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use File::Spec;
use Fcntl qw(:flock);

our $VERSION = "0.2.5";
our $PROJECT_NAME = "rtpg";

use lib qw(../lib);
use RTPG::WWW::Config;
use RTPG::WWW::Template;
use RTPG::WWW::Locale;
use RTPG;

# Only one client can follow then ##############################################
flock DATA, LOCK_EX;

# Get params ###################################################################
my %params = (version => $VERSION);
$params{show} = cfg->get('show') || 'index';

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

# IF some actions then redirect ################################################


# Files for this page ##########################################################
for (qw(current default))
{
    if( -f cfg->{dir}{skin}{$_} .'/'. $params{show} .'.css' )
    {
        push @{ cfg->{url}{skin}{css} },
            cfg->{url}{skin}{$_} .'/'. $params{show} .'.css';
        last;
    }
}

for (qw(current default))
{
    if( -f cfg->{dir}{skin}{$_} .'/'. $params{show} .'.js' )
    {
        push @{ cfg->{url}{skin}{js} },
            cfg->{url}{skin}{$_} .'/'. $params{show} .'.js';
        last;
    }
}

# For some frame type add some resources
if(    $params{show} eq 'panel' )
{
    push @{ cfg->{url}{skin}{js} }, 'index.cgi?show=string&';
}
elsif( $params{show} eq 'prop' )
{
    for (qw(current default))
    {
        if( -f cfg->{dir}{skin}{$_} .'/prop.'. $params{data}{prop} .'.css' )
        {
            push @{ cfg->{url}{skin}{css} },
                cfg->{url}{skin}{$_} .'/prop.'. $params{data}{prop} .'.css';
            last;
        }
    }

    for (qw(current default))
    {
        if( -f cfg->{dir}{skin}{$_} .'/prop.'. $params{data}{prop} .'.js' )
        {
            push @{ cfg->{url}{skin}{js} },
                cfg->{url}{skin}{$_} .'/prop.'. $params{data}{prop} .'.js';
            last;
        }
    }

    push @{ cfg->{url}{skin}{js} }, 'js/jquery.treetable.min.js';
}
elsif( $params{show} eq 'list' )
{
    push @{ cfg->{url}{skin}{js} }, 'js/jquery.tablesorter.min.js';
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

__DATA__
lock area
