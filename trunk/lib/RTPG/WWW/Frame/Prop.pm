use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::Prop

=head1 DESCRIPTION

Class for manage Properties frame

=cut

package RTPG::WWW::Frame::Prop;

use Tree::Simple;

use RTPG;
use RTPG::WWW::Config;
use RTPG::WWW::Locale;

# Masks for special tracker url
use constant MASK_TRACKER_DHT       => '^dht://$';
use constant MASK_TRACKER_RETRACKER => '^http://retracker\.local';
# Some part of links for favicon
use constant URL_FAVICON_PROTO  => 'http://';
use constant URL_FAVICON_FILE   => '/favicon.ico';
# Some part of links for wikipedia
use constant URL_WIKI_PROTO     => 'http://';
use constant URL_WIKI_FAVICON   => '.wikipedia.org/favicon.ico';
use constant URL_WIKI_DHT       => '.wikipedia.org/wiki/Distributed_Hash_Table';
use constant URL_WIKI_RETRACKER => '.wikipedia.org/wiki/Retracker';

=head2 new

Get params

=cut

sub new
{
    my ($class, %opts) = @_;

    # Get current state
    $opts{$_} = cfg->get($_) for qw(current prop do);
    $opts{prop} ||= 'info';
    # Get selected files indexes
    my @index = cfg->get('index[]');
    $opts{index} = {};
    $opts{index} = { map {$_ => 'checked'} @index } if @index;
    # Get selected folder indexes
    my @folder = cfg->get('folder[]');
    $opts{folder} = {};
    $opts{folder} = { map { $_ => 'checked' } @folder } if @folder;
    # Get expanded folder indexes
    my @expanded = cfg->get('expanded[]');
    $opts{expanded} = {};
    $opts{expanded} = { map { $_ => 'expanded' } @expanded } if @expanded;

    {
        # Exit if no current selected
        last unless $opts{current};

        # Get RTPG object
        my $rtpg = RTPG->new(url => cfg->get('rpc_uri'));
        my $error;

        # Check exists current
        ($opts{info}, $error) = $rtpg->torrent_info( $opts{current} );
        if( $error )
        {
            # Drop current if not in list
            cfg->set('current', '');
            $opts{current} = '';
            last;
        }

        # Get info by page name
        if( $opts{prop} eq 'info')
        {
            # Count space for future downloads. And set warning flag in no space
            my $need = 0;
            $need += ($_->{size_bytes} - $_->{left_bytes}) for @{ $opts{list} };
            $opts{info}{low_space} = $need - $opts{info}{free_diskspace}
                if $need > $opts{info}{free_diskspace};
        }
        elsif($opts{prop} eq 'peers')
        {
            my ($error);
            ($opts{list}, $error) = $rtpg->peer_list( $opts{current} );
            $opts{error} ||= $error;

            if( cfg->is_geo_ip and eval "require Geo::IPfree" and !$@)
            {
                my $geo = Geo::IPfree->new;
                $geo->Faster;
                ($_->{country_code}, $_->{country_name},) =
                    $geo->LookUp( $_->{address} )
                        for @{ $opts{list} };
            }
        }
        elsif($opts{prop} eq 'files')
        {
            # If priority command then get priority level
            if($opts{do} =~ m/^(off|low|normal|high)$/i)
            {
                $opts{param} = RTPG::file_priority_num( $opts{do} );
                $opts{do}       = 'priority';
            }
            # Set priorities
            if( $opts{do} eq 'priority' and %{ $opts{index} } )
            {
                $rtpg->set_file_priority($opts{current}, $_, $opts{param})
                    for keys %{ $opts{index} };
            }

            ($opts{list}, $opts{error}) = $rtpg->file_list( $opts{current} );

            # Make directory tree
            $opts{tree} = make_tree( \%opts );
        }
        elsif($opts{prop} eq 'trackers')
        {
            ($opts{info}, $opts{error}) = $rtpg->tracker_list( $opts{current} );
            for my $tracker( @{ $opts{info} } )
            {
                if( $tracker->{url} =~ m/${\(MASK_TRACKER_DHT)}/ )
                {
                    $tracker->{tracker} =
                        URL_WIKI_PROTO. cfg->get('locale') .URL_WIKI_DHT;
                    $tracker->{favicon} =
                        URL_WIKI_PROTO. cfg->get('locale') .URL_WIKI_FAVICON;
                }
                elsif( $tracker->{url} =~ m/${\(MASK_TRACKER_RETRACKER)}/ )
                {
                    $tracker->{tracker} =
                        URL_WIKI_PROTO. cfg->get('locale') .URL_WIKI_RETRACKER;
                    $tracker->{favicon} =
                        URL_WIKI_PROTO. cfg->get('locale') .URL_WIKI_FAVICON;
                }
                else
                {
                    # Get second domine
                    my $domain = $tracker->{url};
                    s~^\w+://~~i,
                    s~[/:].*$~~
                        for $domain;
                    $domain = [ split m/\./, $domain ];
                    $domain = join '.',
                        $domain->[$#{$domain} -1], $domain->[$#{$domain}];

                    # Set links on tracker
                    $tracker->{tracker} = URL_FAVICON_PROTO. $domain;
                    $tracker->{favicon} = $tracker->{tracker} .URL_FAVICON_FILE;
                }
            }
        }
        elsif($opts{prop} eq 'chunks')
        {
        }
        elsif($opts{prop} eq 'transfer')
        {
        }
        else
        {
            $opts{error} = RTPG::WWW::Locale::gettext('Unknown property page');
        }
    }

    my $self = bless \%opts, $class;

    return $self;
}

=head2 make_tree $opts

Make directory structure tree from rtorrent info and return it.

=cut

sub make_tree
{
    my ($opts) = @_;

    # Create folders tree
    my $tree = Tree::Simple->new("0", Tree::Simple->ROOT);
    # Index for files operations
    my ($index, $dir_index, $file_index) = (1, 0, 0);

    for my $file ( @{ $opts->{list} } )
    {
        # Get current file components
        my @path        = @{ $file->{path_components} };
        my $filename    = pop @path;
        my $parent      = $tree;

        # Add dirs
        for my $dir (@path)
        {
            # Find dir
            my @chilren = $parent->getAllChildren;
            my ($node) =
                grep { $_->getNodeValue->{name} eq $dir } @chilren;

            # Skip add dir if it`s exists
            if( $node )
            {
                $parent = $node;
                next;
            }

            # Add new dir and set as parent
            my %data = (
                name        => $dir,
                level       => $parent->getDepth + 1,
                type        => 'folder',
                dindex      => $dir_index++,
                index       => $index++,
                parent      => ($parent->isRoot)
                                    ?0
                                    :$parent->getNodeValue->{'index'},
            );
            $node = Tree::Simple->new(\%data);
            $parent->addChild( $node );
            $parent = $node;
        }

        # Add file
        my %data = (
            name        => $filename,
            level       => $parent->getDepth + 1,
            type        => 'file',
            findex      => $file_index++,
            index       => $index++,
            parent      => ($parent->isRoot)
                                ?0
                                :$parent->getNodeValue->{'index'},
            data        => $file,
        );
        $data{complete} = 1 if $file->{percent} eq '100%';
        $data{dlink} = cfg->get('direct_link') . $file->{path}
            if cfg->get('direct_link') and $data{complete} and
               $opts->{info}{complete};
        my $node = Tree::Simple->new(\%data);
        $parent->addChild( $node );
    }

    # Map tree to list
    my @return;
    $tree->traverse( sub{
        my $node = shift;

        # Get folder information from subnodes
        if( $node->getNodeValue->{type} eq 'folder')
        {
            my ($size, $chunks, $count) = 0;
            $node->traverse( sub{
                my $child = shift;
                return unless $child->getNodeValue->{type} eq 'file';

                $size   += $child->getNodeValue->{data}{size_bytes};
                $chunks += $child->getNodeValue->{data}{size_chunks};
                $count++;
            } );
            $node->getNodeValue->{data}{size_bytes}  = $size;
            $node->getNodeValue->{data}{size_chunks} = $chunks;
        }

        push @return, $node->getNodeValue;
    } );

    undef $tree;

    return \@return;
}

1;

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
