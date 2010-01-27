#!/usr/bin/perl

use utf8;
package RTPG;
use Carp;
use RTPG::Direct;
use RPC::XML::Client;
use RPC::XML;

# use Data::Dumper;

# $Data::Dumper::Indent = 1;
# $Data::Dumper::Terse = 1;
# $Data::Dumper::Useqq = 1;
# $Data::Dumper::Deepcopy = 1;
# $Data::Dumper::Maxdepth = 0;

my $SIZE_BY_CHUNKS_LIMIT=1024**3;

=head1 NAME

RTPG - is a module for accessing to rtorrent's SCGI functions.

=head1 VERSION

0.3

=cut

our $VERSION=0.7;

=head1 SYNOPSIS

 use RTPG;
 
 # standard variant
 my $h = new RTPG(url=>'http://localhost/RPC2');
 
 # direct connection to rtorrent
 my $h = new RTPG(url=>'localhost:5000');
 my $h = new RTPG(url=>'/path/to/socket.rtorrent'); 

 # arrayref and error (standard version)
 my ($tlist, $error)=$h->torrents_list;

 # arrayref (died version)
 my $tlist=$h->torrents_list;
 
 for (@$tlist)
 {
     my $file_list=$h->file_list($_->{hash});
     ..
 }


 # direct commands by RPC
 my $list_methods=$h->rpc_command('system.listMethods');
 my ($list_methods, $error)=$h->rpc_command('system.listMethods');

 # system information (library versions, etc)
 my $hashref=$h->system_information;
 my ($hashref, $error)=$h->system_information;

=head1 METHODS


=head2 new

The constructor. It receives the next options:

=over

=item B<url>

is an address of rtorrent's SCGI (direct) or rtorrent's RPC (standard).

=back
=cut

sub new
{
    my ($class, %opts)=@_;
    croak 'XMLRPC url must be defined' unless exists $opts{url};

    # XML::RPC::Client (standard variant)
    if ($opts{url} =~ m{^\w+://})
    {
        my $connect=RPC::XML::Client->new($opts{url});
        unless (ref $connect)
        {
            $!="Error connect to XMLRPC-server: $connect\n";
            return undef;
        }

        return bless {
            standard            =>  1,
            rtorrent_ctl_url    =>  $opts{url},
            connection          =>  $connect
        }, $class;
    }

    my $connect=RTPG::Direct->new(url => $opts{url});
    return bless {
        standard            => 0,
        rtorrent_ctl_url    => $opts{url},
        connection          => $connect,
    };
}

=head2 rpc_command(CMD[,ARGS])

You can use this method for send commands to rtorrent.

=head3 EXAMPLE

 # standard version
 my ($result, $error)=$h->rpc_command('system.listMethods');

 # died version
 my $result=$h->rpc_command('system.listMethods');

=cut
sub rpc_command
{
    my $self=shift;
    my ($cmd, @args)=@_;
    my $resp;

    $resp=$self->{connection}->send_request($cmd, @args);

    if (ref $resp)
    {
        if ('RPC::XML::fault' eq ref $resp)
        {
            my $err_str=sprintf 
                "Fault when execute command: %s\n" .
                "Fault code: %s\n" .
                "Fault text: %s\n",
                join(' ', $cmd, @args),
                $resp->value->{faultString},
                $resp->value->{faultCode};
            die $err_str unless wantarray;
            return (undef, $err_str);
        }
        return $resp->value unless wantarray;
        return $resp->value, '';
    }
    my $err_str=sprintf 
        "Fault when execute command: %s\n" .
        "Fault text: %s\n",
        join(' ', $cmd, @args),
        $resp||'';
    die $err_str unless wantarray;
    return undef, $err_str;
}

=head2 torrents_list([VIEW])

This method returns list of torrents. It is a link to array of hashes.

=head3 EXAMPLE

# standard version
 my ($tlist, $err)=$h->torrents_list;
 my ($tlist, $err)=$h->torrents_list('started');

 # died version
 my $tlist=$h->torrents_list;
 my $tlist=$h->torrents_list('started');

=head3 views variants

=over

=item default

=item name

=item stopped

=item started

=item complete

=item incomplete

=back

=cut

our $exclude_d_mask = qr{^d\.(get_mode|get_custom.*|get_bitfield)$};

sub torrents_list
{
    my ($self, $view)=@_;
    $view||='default';


    my @iary=eval {
        grep !/$exclude_d_mask/,
        grep /^d\.(get_|is_)/, $self->_get_list_methods;
    };

    if ($@)
    {
        return undef, "$@" if wantarray;
        die $@;
    }
    my ($list, $error) =
        $self->rpc_command('d.multicall', $view, map { "$_=" } @iary);

    unless (defined $list)
    {
        die $error unless wantarray;
        return undef, $error;
    }

    for (@$list)
    {
        my %info;
        for my $i (0 .. $#iary)
        {
            my $name=$iary[$i];
            $name =~ s/^..(?:get_)?//;
            $info{$name}=$_->[$i];
        }
        $_ = _normalize_one_torrent_info(\%info);
    }
    return $list unless wantarray;
    return $list, '';
}

=head2 torrent_info(tid)

The method returns the link to hash which contains the information about
the torrent (tid);

=head3 EXAMPLE

 my $tlist = $h->torrents_list;
 my $tinfo_first = $tlist->[0];
 my $tinfo_first_second_time 
    = $h->torrent_info($tlist->[0]{hash});

=head4 NOTE

Hashes B<$tinfo_first> and B<$tinfo_first_second_time> are equal.
This method can use if You know torrent-id and do not know
an other information about the torrent.

 # standard version
 my ($tinfo, $error)=$h->torrent_info($tid);

 # died version
 my $tinfo=$h->torrent_info($tid);
=cut
sub torrent_info
{
    my ($self, $id)=@_;
    my @iary=eval {
        grep !/$exclude_d_mask/,
        grep /^d\.(get_|is_)/, $self->_get_list_methods;
    };
    if ($@)
    {
        return undef, "$@" if wantarray;
        die $@;
    }

    my $info={};

    eval
    {
        for my $cmd (@iary)
        {
            my $name=$cmd;
            $name=~s/^..(?:get_)?//;
            $info->{$name}=$self->rpc_command($cmd, $id);
        }
    };
    if ($@)
    {
        return undef, "$@" if wantarray;
        die $@;
    }
    return _normalize_one_torrent_info($info), '' if wantarray;
    return _normalize_one_torrent_info($info);
}

=head2 file_list(tid)

The method returns the link to array which contains information
about each file that belong to the torrent (tid).

=head3 EXAMPLE

 # standard version
 my ($files, $error)=$h->file_list($tid);
 
 # died version
 my $files=$h->file_list($tid);

=cut

sub file_list
{
    my ($self, $id)=@_;
    croak "TorrentID must be defined!\n" unless $id;
    my @iary=eval {
        grep /^f\.(get|is)/, $self->_get_list_methods;
    };

    if ($@)
    {
        return undef, "$@" if wantarray;
        die $@;
    }
    
    my ($chunk_size, $error)=$self->rpc_command('d.get_chunk_size', $id);
    unless (defined $chunk_size)
    {
        die $error unless wantarray;
        return undef, $error;
    }

    my $list;

    ($list, $error) =
        $self->rpc_command('f.multicall', $id, '', map { "$_=" } @iary);
    unless (defined $list)
    {
        die $error unless wantarray;
        return undef, $error;
    }

    for (@$list)
    {
        my %info;
        for my $i (0 .. $#iary)
        {
            my $name=$iary[$i];
            $name =~ s/^..(?:get_)?//;
            $info{$name}=$_->[$i];
        }
        $_ =  \%info;
        my $size_bytes=1.0*$chunk_size*$_->{size_chunks};
        $_->{size_bytes}=$size_bytes if $size_bytes > $SIZE_BY_CHUNKS_LIMIT;
        $_->{human_size}=_human_size($_->{size_bytes});
        $_->{percent}=_get_percent_string(
            $_->{completed_chunks},
            $_->{size_chunks}
        );
    }
    return $list, '' if wantarray;
    return $list;
}

=head2 set_files_priorities(tid, pri)

This method updates priorities of all files in one torrent

=head3 EXAMPLE
 
 # standard version
 my $error=$h->set_files_priorities($tid, $pri);
 my ($error)=$h->set_files_priorities($tid, $pri);

 # died version
 $h->set_files_priorities($tid, $pri);

=cut
sub set_files_priorities
{
    my ($self, $id, $pri)=@_;
    my ($list, $error) =
        $self->rpc_command('f.multicall', $id, '', "f.set_priority=$pri");
    return $error if defined wantarray;
    die $error if $error;
    return undef;
}

=head2 system_information

The method returns the link to hash about system information. The hash
has the fields:

=over

=item B<client_version>

the version of rtorrent.

=item B<library_version>

the version of librtorrent.

=back

=cut
sub system_information
{
    my $self=shift;

    my $lv;
    my ($rv, $err)=$self->rpc_command('system.client_version');
    ($lv, $err)=$self->rpc_command('system.library_version') if defined $rv;

    unless (defined $lv)
    {
        return undef, $err if wantarray;
        die $err;
    }
    
    my $res=
    {
        client_version      => $rv,
        library_version     => $lv,
    };

    return $res, '' if wantarray;
    return $res;
}

=head1 PRIVATE METHODS

=head2 _get_list_methods

returns list of rtorrent commands

=cut

sub _get_list_methods
{
    my $self=shift;
    return @{ $self->{listMethods} } if $self->{listMethods};
    my $list = $self->rpc_command('system.listMethods');
    return @$list;
}

=head2 _get_percent_string(PART_OF_VALUE,VALUE)

counts percent by pair values

=cut
sub _get_percent_string($$)
{
    my ($part, $full)=@_;
    return undef unless $full;
    return undef unless defined $part;
    return undef if $part<0;
    return undef if $full<0;
    return undef if $part>$full;
    my $percent=$part*100/$full;
    if ($percent<10)
    {
        $percent=sprintf '%1.2f', $percent;
    }
    else
    {
        $percent=sprintf '%1.1f', $percent;
    }
    s/(?<=\.\d)0$//, s/\.00?$// for $percent;
    return "$percent%";
}

=head2 _human_size(NUM)

converts big numbers to small 1024 = 1K, 1024**2 == 1M, etc

=cut
sub _human_size($)
{
    my ($size, $sign)=(shift, 1);
    if ($size<0) { return '>2G'; }
    return 0 unless $size;
    my @suffixes=('', 'K', 'M', 'G', 'T', 'P', 'E');
    my ($limit, $div)=(1024, 1);
    for (@suffixes)
    {
        if ($size<$limit || $_ eq $suffixes[-1])
        {
            $size = $sign*$size/$div;
            if ($size<10)
            {
                $size=sprintf "%1.2f", $size;
            }
            elsif ($size<50)
            {
                $size=sprintf "%1.1f", $size;
            }
            else
            {
                $size=int($size);
            }
            s/(?<=\.\d)0$//, s/\.00?$// for $size;
            return "$size$_";
        }
        $div = $limit;
        $limit *= 1024;
    }
}

=head2 _normalize_one_torrent_info(HASHREF)

=over

=item calculates:

percents, ratio, human_size, human_done,
human_up_total, human_up_rate, human_down_rate

=item fixes:

32bit overflow in libxmlrpc-c3 version < 1.07

=back

=cut

sub _normalize_one_torrent_info($)
{
    my ($info)=@_;

    for ($info)
    {
        $_->{percent} = _get_percent_string(
            $_->{completed_chunks},
            $_->{size_chunks}
        );

        my ($bytes_done, $size_bytes)=
        (
            1.0*$_->{completed_chunks}*$_->{chunk_size},
            1.0*$_->{size_chunks}*$_->{chunk_size}
        );
        $_->{size_bytes}=$size_bytes if $size_bytes>$SIZE_BY_CHUNKS_LIMIT;
        $_->{bytes_done}=$bytes_done if $bytes_done>$SIZE_BY_CHUNKS_LIMIT;
        $_->{up_total}=1.0*$_->{bytes_done}*($_->{ratio}/1000);


        $_->{ratio}=sprintf '%1.2f', $_->{ratio}/1000;
        $_->{ratio}=~s/((\.00)|0)$//;

        $_->{human_size} = _human_size($_->{size_bytes});
        $_->{human_done} = _human_size($_->{bytes_done});
        $_->{human_up_total} = _human_size($_->{up_total});
        $_->{human_up_rate} = _human_size($_->{up_rate});
        $_->{human_down_rate} = _human_size($_->{down_rate});

        for ($_->{human_up_rate}, $_->{human_down_rate})
        {
            next if $_ eq 0;
            $_ .= 'B/s';
        }
    }
    return $info;
}

1;

=head1 AUTHORS

Copyright (C) 2008 Dmitry E. Oboukhov <unera@debian.org>,

Copyright (C) 2008 Nikolaev Roman <rshadow@rambler.ru>

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

