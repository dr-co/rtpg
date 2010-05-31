use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Config configuration module.

=cut
package RTPG::WWW::Config;
use base qw(Exporter);

use CGI;
$CGI::DISABLE_UPLOADS = 0;
$CGI::POST_MAX = 67108864; #64Mb
$CGI::PRIVATE_TEMPFILES = 1;
$CGI::CLOSE_UPLOAD_FILES = 0;
$CGI::HEADERS_ONCE = 0;

use File::Basename;
use File::Spec;

our @EXPORT = qw(cfg DieDumper Dumper);

################################################################################
# This section contains some paths for use in this program
# Edit this for some OS
# I think no any place to change. If it`s wrong, please inform me.
# (Except config file)
################################################################################
use constant RTPG_SYSTEM_CONFIG_PATH  => '/etc/rtpg/rtpg.conf';
use constant RTPG_CONFIG_PATH         => '~/.rtpg/rtpg.conf';
################################################################################

=head2 cfg

Get cached config object

=cut

sub cfg
{
    our $config;

    # Cache config
    return $config if $config;
    $config = RTPG::WWW::Config->new;
    return $config;
}

sub new
{
    my $class = shift;
    my %opts;

    $opts{dir}{config} = [
        RTPG_SYSTEM_CONFIG_PATH,
        RTPG_CONFIG_PATH,
    ];
    # Redefining config path from server options.
    $opts{dir}{config} = [ $ENV{RTPG_CONFIG} ] if $ENV{RTPG_CONFIG};

    $opts{title} = "RTPG";

    $opts{dir}{base} = File::Spec->rel2abs( dirname(__FILE__) . '/../../..' );
    # Make clean basedir
    while( $opts{dir}{base} =~ s{(?:/[^\./]+/\.\.)}{}g ) {;}

    # Other dirs
    $opts{dir}{templates}   = $opts{dir}{base}      . '/templates';
    $opts{dir}{po}          = $opts{dir}{base}      . '/po';

    # Absolute resources dirs
    $opts{dir}{htdocs}      = $opts{dir}{base}      . '/htdocs';
    $opts{dir}{css}         = $opts{dir}{htdocs}    . '/css';
    $opts{dir}{img}         = $opts{dir}{htdocs}    . '/img';
    $opts{dir}{js}          = $opts{dir}{htdocs}    . '/js';

    # Relative resource urls
    $opts{url}{base}        = $ENV{SCRIPT_NAME};
    $opts{url}{base}        =~ s{/[^/]*$}{/};
    $opts{url}{base}        = $ENV{SERVER_NAME} . $opts{url}{base};

    my $self = bless \%opts, $class;

    my ($browser_locale) = $ENV{HTTP_ACCEPT_LANGUAGE} =~ m/^(\w+)/;

    # Set parameters by default, even it not declared in config file
    $self->set('action',     'default' ) unless $self->get('action');
    $self->set('locale',     $self->get('locale') || $browser_locale || 'en' );
    $self->set('horizontal', '150,*' )   unless $self->get('horizontal');
    $self->set('vertical',   '*,300' )   unless $self->get('vertical');

    # Load params from file
    $self->load_from_files;

    # Get skin files path
    $self->{dir}{skin}{files}   = $opts{dir}{htdocs} . '/skins';

    # Get current skin and check for skin available
    my $skin = $self->get('skin');
    unless( $self->get('skin') ~~ @{[ keys %{$self->skins} ]} )
    {
        $skin = 'default';
        $self->set('skin', $skin);
    }

    # Get over skin files path
    $self->{dir}{skin}{current} = $self->{dir}{skin}{files} . '/' . $skin;
    $self->{dir}{skin}{base}    = $self->{dir}{templates}   . '/' . $skin;
    $self->{dir}{skin}{default} = $self->{dir}{templates}   . '/default';
    # Get over skin files url
    $self->{url}{skin}{current}    = 'skins/' . $skin;
    $self->{url}{skin}{default} = 'skins/default';
    $self->{url}{skin}{panel}   = $self->{url}{skin}{current} . '/panel';
    $self->{url}{skin}{status}  = $self->{url}{skin}{current} . '/status';
    $self->{url}{skin}{mime}    = $self->{url}{skin}{current} . '/mimetypes';

    # Init parameters from current value to cookie
    # It`s need for first time start to init all default cookie
    $self->set($_, $self->get($_)) for qw(refresh skin);

    return $self;
}

sub load_from_files
{
    my ($self) = @_;

    # Set default params
    $self->{param} = {};

    # Flag successful loaded
    my $loaded = 'no';

    # Loading: first default config, next over users config
    for my $config ( @{$self->{dir}{config}} )
    {
        # Get abcoulete path
        ($config) = glob $config;

        # Next if file not exists
        next unless -f $config;

        # Open config file
        open my $file, '<', $config
            or warn sprintf('Can`t read config file %s : %s', $config, $!);
        next unless $file;

        # Read and parse file. Next hash write over previus configuration hash
        %{ $self->{param} } = (
            %{ $self->{param} },
            (
                map{ split m/\s*=\s*/, $_, 2 }
                grep m/=/,
                map { s/#\s.*//; s/^\s*#.*//; s/\s+$//; s/^\s+//; $_ } <$file>
            )
        );

        # Close file and mark successful loaded
        close $file;
        $loaded = 'yes';
    }

    # Exit if no one config exists
    die 'Config file not exists' unless $loaded eq 'yes';

    # Replace by old parameters from RTPG 0.1.x version
    if( exists $self->{param}{refresh_timeout} )
    {
        $self->{param}{refresh} = $self->{param}{refresh_timeout};
        delete $self->{param}{refresh_timeout};
    }
    if( exists $self->{param}{current_skin} )
    {
        $self->{param}{skin} = $self->{param}{current_skin};
        delete $self->{param}{current_skin};
    }

    return 1;
}


=head2 get $name

Get parameter by $name.

=cut

sub get
{
    my ($self, $name) = @_;
    return (CGI::param($name))
        if defined CGI::param($name)     and wantarray;
    return (CGI::cookie($name))
        if defined CGI::cookie($name)    and wantarray;
    return ($self->{param}{$name})
        if defined $self->{param}{$name} and wantarray;

    return CGI::param($name)     // CGI::cookie($name) //
           $self->{param}{$name} // '';
}

=head2 upload $name

Get uploaded file handle

=cut

sub upload
{
    my ($self, $name) = @_;
    return CGI::upload($name);
}

=head2 upload $name

Get uploaded file info

=cut

sub upload_info
{
    my ($self, $name) = @_;
    return CGI::uploadInfo(CGI::upload($name));
}

=head2 set $name, $value

Set new $value for parameter by $name.

=cut

sub set
{
    my ($self, $name, $value) = @_;

    # Permanent set new state into cookies
    push @{ $self->{cookies} },
        CGI::cookie(-name => $name, -value => $value, -expires => '+2y')
            unless $value eq CGI::cookie($name);

    $self->{param}{$name} = $value;
}

=head2 cookies

Get cookies to response

=cut

sub cookies { return shift->{cookies}; }

=head2 skins

Get list of available skins

=cut

sub skins
{
    my ($self) = @_;

    # Cache
    return $self->{skins} if $self->{skins};

    # Get paths to skins
    my @paths = glob sprintf( '%s/*', $self->{dir}{skin}{files});

    # Get skins titles
    my %skins;
    for my $path ( @paths )
    {
        # Get name as last part of path
        my ($name) = $path =~ m|^.*/(.*?)$|;
        # Set fullpath
        my $file = sprintf '%s/%s/title.txt', $self->{dir}{skin}{files}, $name;
        # Get title from file if file accessible
        my $title;
        if( -f $file and -r _ and -s _ )
        {
            $title = `cat $file`;
            s/^\s+//, s/\s+$//, s/[^\w\s.,)(]//g for $title;
        }
        # Set skin description
        $skins{$name} = $title || ucfirst( lc $name );
    }

    $self->{skins} = \%skins;
    return $self->{skins};
}

=head2 is_collapse

Return true if html collapse enabled

=cut

sub is_collapse
{
    return ( shift->get('collapse') =~ m/^(yes|on|enable)$/i) ?1 :0;
}

=head2 is_geo_ip

Return true if geo_ip enabled

=cut
sub is_geo_ip
{
    return ( shift->get('geo_ip') =~ m/^(yes|on|enable)$/i) ?1 :0;
}

=head2 DieDumper

Print all params and die

=cut

sub DieDumper
{
    require Data::Dumper;
    $Data::Dumper::Indent = 1;
    $Data::Dumper::Terse = 1;
    $Data::Dumper::Useqq = 1;
    $Data::Dumper::Deepcopy = 1;
    $Data::Dumper::Maxdepth = 0;
    my $dump = Data::Dumper->Dump([@_]);
    $dump=~s/(\\x\{[\da-fA-F]+\})/eval "qq{$1}"/eg;
    die $dump;
}

=head2 Dumper

Get all params description

=cut

sub Dumper
{
    require Data::Dumper;
    $Data::Dumper::Indent = 1;
    $Data::Dumper::Terse = 1;
    $Data::Dumper::Useqq = 1;
    $Data::Dumper::Deepcopy = 1;
    $Data::Dumper::Maxdepth = 0;
    my $dump = Data::Dumper->Dump([@_]);

    return $dump;
}

1;
