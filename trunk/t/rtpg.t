#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 3;
use Encode qw(decode encode);

use Data::Dumper;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ":utf8";
    binmode $builder->failure_output, ":utf8";
    binmode $builder->todo_output,    ":utf8";

    diag("************* RTPG *************");

    use_ok 'RTPG';
}

my $rtorrent_url = $ARGV[0];
unless ($rtorrent_url) {
    diag "use perl $0 rtorrent_url";
    exit;
}

my $rtorrent = new RTPG(url => $rtorrent_url);


sub check_tarckers
{
    my $test_name = 'check_views';
    my ($tl, $terr) = $rtorrent->torrents_list;
    return fail "$test_name = $terr" if $terr;
    return fail "$test_name - Torrents not found" unless @$tl;

    for (@$tl) {
        my ($r, $e) = $rtorrent->tracker_list($_->{hash});
        return fail "$test_name - $e" if $e;

        for my $t(@$r) {
            next unless $t->{url};
            return ok 1, $test_name if $t->{url} =~ m{^http://};
        }
    }
    fail "$test_name - url not found";
}

sub ckeck_peers
{
    my $test_name = 'check peer list';
    my ($tl, $terr) = $rtorrent->torrents_list;
    return fail "$test_name = $terr" if $terr;
    return fail "$test_name - Torrents not found" unless @$tl;

    for (@$tl) {
        my $id = $_->{hash};
        my ($pl, $err) = $rtorrent->peer_list($id);
        return fail "$test_name - $err" if $err;

        for my $p (@$pl) {
            return ok 1, $test_name
                if ($p->{address} and $p->{address} =~ /^\d+(\.\d+){3}$/);
        }
    }

    fail "$test_name - Peers' addresses not found";
}

check_tarckers;
ckeck_peers;
