#!/usr/bin/perl

=head1 NAME

extract_po.pl - script for extraction strings for *.po files

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

use Getopt::Std;
use Carp;

sub usage()
{
    print <<endusage;
usage: $0 [OPTIONS] [input_file [output_file.po] ]

OPTIONS:
    -h          - this helpscreen

    -o tag      - the open tag (default: '<gt>')
    -c tag      - the close tag (default: '</gt>')

    -s          - collapse spaces
    -e          - erase endspaces
    -b          - erase beginspaces

    -w width    - width of msg lines (default: 75)

    -n          - do not print po-header
    -f          - print '#, fuzzy' before each msgid

    -q          - don`t show warnings

PS: script works in utf-8 charset

endusage
    exit;
}

sub get_po_header()
{
    return <<endpoheader;
# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL\@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: rtpg\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: \\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n"
"Last-Translator: FULL NAME <EMAIL\@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL\@li.org>\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"

endpoheader
}

sub message_text($$)
{
    my ($message, $width)=@_;
    croak "undefined text" unless defined $message;
    croak "unknown line width" unless $width;

    for ($message)
    {
        s/\\/\\\\/g;
        s/"/\\"/g;
        s/\n/\\n/gs;
        s/\r/\\r/gs;
    }
    my @items=split /(\s+)/s, $message;

    my ($result, $line)=('', '');

    for (@items)
    {
        if (length($line)+length($_)>$width and length($line))
        {
            $result .= '"' . $line . '"' . "\n";
            $line = $_;
            next;
        }

        $line .= $_;
    }

    $result .= '"' . $line . '"' . "\n" if length $line;
    return $result;
}

getopts('hfnqo:c:sebw:', \my %opts) or usage;
usage if $opts{h};
my ($open_tag, $close_tag, $width, $quite)=
(
    $opts{o}||'<gt>',
    $opts{c}||'</gt>',
    $opts{w}||75,
    $opts{q}||0,
);

my ($input, $output);

my $input_name;
if (defined $ARGV[0])
{
    $input_name=$ARGV[0];
    open $input, '<', $input_name
        or die "Can not open (read) file $input_name: $!\n";
}
else {	$input=\*STDIN; $input_name='STDIN'; }


my $input_data;
{ local $/; $input_data=<$input>; }

my @items=$input_data=~/\Q$open_tag\E(.*?)\Q$close_tag\E/gs;
unless( @items )
{
    die "Can not found any parts for translation in $input_name\n"
        unless $quite;
    exit 0;
}

if ($ARGV[1])
{
    open $output, '>', $ARGV[1]
        or die "Can not open (write) file $ARGV[1]: $!\n";
}
else
{
    $output=\*STDOUT;
}

my $no=0;

print $output get_po_header unless $opts{n};

my %printed;
for (@items)
{
    $no++;
    s/\s+/ /gs if $opts{s};
    s/^\s+//mg if $opts{b};
    s/\s+$//mg if $opts{e};

    next if $printed{$_}; $printed{$_}=1;

    print $output "#: $input_name: translate part: #$no\n";
    print $output "#, fuzzy\n" if $opts{f};
    print $output "msgid \"\"\n";
    print $output message_text($_, $width);
    print $output "msgstr \"\"\n\"\"\n\n";
}
