#!/usr/bin/perl

use warnings;
use strict;

use utf8;
use open qw(:std :utf8);

use RTPG;
use RPC::XML::Client;
use Data::Dumper;

$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;
$Data::Dumper::Useqq = 1;
$Data::Dumper::Deepcopy = 1;
$Data::Dumper::Maxdepth = 0;


# my $rtpg=new RTPG(url   => 'http://rtpg.dhome.lan/RPC2');
my $rtpg=new RTPG(url   => '10.255.1.1:5000');

print Dumper $rtpg->torrents_list();

