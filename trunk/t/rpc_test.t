use Test::More tests => 7;

BEGIN
{
    use_ok('RPC::XML');
    use_ok('RPC::XML::Client');
    use_ok('RTPG');
}

my $url=$ARGV[0]||'http://apache/RPC2';

use RPC::XML;
use RPC::XML::Client;
use RTPG;

my ($h, $tlist, $flist);

sub connect_test()
{
    unless ($h=new RTPG(url=>$url))
    {
        no warnings qw(once);
        diag($RTPG::ERROR);
        return 0;
    }
    return 1;
}

sub read_tlist_test()
{
    return 0 unless $h;
    my $error;
    ($tlist, $error)=$h->torrents_list;
    unless (defined $tlist)
    {
        diag("Error: $error");
        return 0;
    }
    for (@$tlist)
    {
        diag(
            sprintf "torrent: %s, size: %s,\n\thash: %s\n",
            $_->{name},
            $_->{human_size},
            $_->{hash}
        );
    }
    return 1;
}
sub read_file_list()
{
    return 0 unless $h;
    return 0 unless $tlist;
    unless(@$tlist)
    {
        diag('Torrents not found in torrents list');
        return 0;
    }

    my $error;
    ($flist, $error)=$h->file_list($tlist->[0]{hash});
    unless(defined $flist)
    {
        diag("Error: $error");
        return 0;
    }
    diag("Torrent: $tlist->[0]{name}");
    for (@$flist)
    {
        diag(sprintf "  +- %s, done: %5s, size: %s",
            $_->{path},
            $_->{percent},
            $_->{human_size});
    }

    return 1;
}

sub read_one_torrent_test()
{
    return 0 unless $h;
    return 0 unless $tlist;
    unless(@$tlist)
    {
        diag('Torrents not found in torrents list');
        return 0;
    }

    my $id=$tlist->[0]{hash};
    my ($t, $error)=$h->torrent_info($id);
    unless(defined $t)
    {
        diag("Error: $error");
        return 0;
    }
    for (keys %$t)
    {
        diag(sprintf '%15s: %s', $_, $t->{$_});
    }

    return 1;
}

ok(connect_test(), "create connection to $url");
ok(read_tlist_test(), "read torrents list");
ok(read_one_torrent_test(), "read info about first torrent");
ok(read_file_list(), "read filelist for first torrent");