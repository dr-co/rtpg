#!/usr/bin/perl

use warnings;
use strict;

use utf8;
use open qw(:std :utf8);

use RPC::XML;
use Data::Dumper;

my $request=new RPC::XML::request('system.listMethods');
print $request->as_string;
