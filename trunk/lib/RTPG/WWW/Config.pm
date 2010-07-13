use warnings;
use strict;
use utf8;

=head1 NAME

RTPG::WWW::Config configuration module.

=cut

package RTPG::WWW::Config;
use base qw(Exporter);

use CGI::Simple;
# Set CGI file upload parameters
$CGI::Simple::POST_MAX = 1024000;
$CGI::Simple::DISABLE_UPLOADS = 0;

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

    # Get skin files path
    $opts{dir}{skin}{files}   = $opts{dir}{htdocs} . '/skins';

    my $self = bless \%opts, $class;

    # Load params from file
    $self->load_from_files or die 'Can`t load config file';

    # Load params from cgi
    $self->load_from_cgi or die 'Can`t load cgi params';

    # Get over skin files path
    $self->{dir}{skin}{current} = $self->{dir}{skin}{files} . '/' .
                                  $self->get('skin');
    $self->{dir}{skin}{base}    = $self->{dir}{templates}   . '/' .
                                  $self->get('skin');
    $self->{dir}{skin}{default} = $self->{dir}{templates}   . '/default';
    # Get over skin files url
    $self->{url}{skin}{current}    = 'skins/' . $self->get('skin');
    $self->{url}{skin}{default} = 'skins/default';
    $self->{url}{skin}{panel}   = $self->{url}{skin}{current} . '/panel';
    $self->{url}{skin}{status}  = $self->{url}{skin}{current} . '/status';
    $self->{url}{skin}{mime}    = $self->{url}{skin}{current} . '/mimetypes';

    return $self;
}

=head2 load_from_files

Load params from config file

=cut

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

    # Cast some params to boolean
    (m/^(?:yes|on|enable)$/i) ?$self->{param}{$_} = 1 :$self->{param}{$_} = 1
        for qw(geo_ip collapse);

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

=head2 load_from_cgi

Load params from cookie and post/get

=cut

sub load_from_cgi
{
    my ($self) = @_;

    # Required params. This params stored in cookie.
    my @names = qw(action locale horizontal vertical refresh skin layout
        current prop);

    # Load params from cookie
    for my $name ( @names )
    {
        next unless defined $self->cgi->cookie($name);
        $self->set($name, $self->cgi->cookie($name) );
    }

    # Load params from pos/get
    for my $name ( $self->cgi->param(), @names )
    {
        next unless defined $self->cgi->param($name);
        # Get value
        my $value = ($name =~ m/\[\]$/)
            ? [$self->cgi->param($name)]
            : $self->cgi->param($name);

        # Get clean name
        my ($c_name) = $name =~ m/^(\w+)(?:\[\])?$/;
        # Set persist flag
        my $persist = 0;
        $persist = 1 if $c_name ~~ @names;
        # Save param value
        $self->set($c_name, $value, $persist);
    }

    $self->set('action',     'default', 1) unless $self->get('action');
    $self->set('horizontal', '190,*',   1) unless $self->get('horizontal');
    $self->set('vertical',   '*,300',   1) unless $self->get('vertical');
    $self->set('refresh',    '180',     1) unless $self->get('refresh');
    $self->set('layout',     'default', 1) unless $self->get('layout');

    # Smart get current locale from browser
    my ($browser_locale) = $ENV{HTTP_ACCEPT_LANGUAGE} =~ m/^(\w+)/;
    $self->set('locale', $browser_locale||'en', 1) unless $self->get('locale');

    # Get current skin and check for skin available
    $self->set('skin', 'default', 1)
        unless( $self->get('skin') ~~ @{[ keys %{$self->skins} ]} );

    return 1;
}

=head2 cgi

returns CGI object

=cut

sub cgi
{
    my ($self) = @_;

    return $self->{'_cgi'} if $self->{'_cgi'};
    return $self->{'_cgi'} = new CGI::Simple;
}


=head2 get $name

Get parameter by $name.

=cut

sub get
{
    my ($self, $name) = @_;

    return @{$self->{param}{$name}}
        if wantarray and
           defined $self->{param}{$name} and
           'ARRAY' eq ref $self->{param}{$name};
    return $self->{param}{$name} // '';
}

=head2 upload $name

Get uploaded file handle

=cut

sub upload
{
    my ($self, $name) = @_;
    return $self->cgi->upload($name);
}


=head2 upload_mime_type $name

Get uploaded file mime info

=cut

sub upload_mime_type
{
    my ($self, $name) = @_;
    return $self->cgi->upload_info($self->cgi->param($name), 'mime');
}


=head2 set $name, $value, $persist

Set new $value for parameter by $name. If $persist is TRUE (default: TRUE) then
store param in cookie.

=cut

sub set
{
    my ($self, $name, $value, $persist) = @_;

    my $expires = '+2y';
    $expires = 'now' unless $value;

    # Permanent set new state into cookies
    push @{ $self->{cookies} }, $self->cgi->cookie(
        -name => $name, -value => $value, -expires => $expires)
            if $persist and $value ne $self->cgi->cookie($name);

    $self->{param}{$name} = $value;

    return $value;
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
