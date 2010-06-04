use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Frame::Prop

=cut

package RTPG::WWW::Frame::Prop;

use Tree::Simple;

use RTPG;
use RTPG::WWW::Config;
use RTPG::WWW::Locale;

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

            # Create folders tree
            my $tree = Tree::Simple->new("0", Tree::Simple->ROOT);
            # Index for files operations
            my ($index, $dir_index, $file_index) = (1, 0, 0);


            for my $file ( @{ $opts{list} } )
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

                    my ($node) = grep { $_->getNodeValue->{name} eq $dir } @chilren;

                    # Skip add dir if it`e exists
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
                       $opts{info}{complete};
                my $node = Tree::Simple->new(\%data);
                $parent->addChild( $node );
            }

            # Map tree to list
            $tree->traverse( sub{ push @{$opts{tree}}, shift->getNodeValue; } );
        }
        elsif($opts{prop} eq 'trackers')
        {
            ($opts{info}, $opts{error}) = $rtpg->tracker_list( $opts{current} );
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

1;
