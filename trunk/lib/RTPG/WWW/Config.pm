use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 NAME

RTPG::WWW::Config configuration module.

=cut
package RTPG::WWW::Config;
use base qw(Exporter);

use CGI;
use File::Basename;
use File::Spec;

our @EXPORT = qw(cfg DieDumper Dumper);

###############################################################################
# This section contains some paths for use in this program
# Edit this for some OS
# I think no any place to change. If it`s wrong, please inform me.
# (Except config file)
################################################################################
#use constant RTPG_SYSTEM_CONFIG_PATH  => '/etc/rtpg/rtpg.conf';
#use constant RTPG_CONFIG_PATH         => '~/.rtpg/rtpg.conf';
use constant RTPG_SYSTEM_CONFIG_PATH  => '/home/rubin/workspace/rtpg2/trunk/config/rtpg.conf';
use constant RTPG_CONFIG_PATH         => '/home/rubin/workspace/rtpg2/trunk/config/rtpg.conf';
###############################################################################

=head2 cfg

Get cached config object

=cut
my $config;
sub cfg
{
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

    $opts{title} = "RTPG";

    # Проверка на локальность пользователя
    $opts{user}{ip} = $ENV{REMOTE_ADDR};
    $opts{user}{local} =
        ( $opts{user}{ip} =~ m/^(10\.|172\.16\.|192\.168\.|127\.0\.)/ ) ?1 :0;

    # Переменные окружения
    $opts{env} = \%ENV;

    $opts{dir}{base} = File::Spec->rel2abs( dirname(__FILE__) . '/../../..' );
    # Удалим лишние вход/выход из поддиректорий
    while( $opts{dir}{base} =~ s{(?:/[^\./]+/\.\.)}{}g ) {;}

    # Другие директории
    $opts{dir}{templates}   = $opts{dir}{base}      . '/templates';
#    $opts{dir}{cache}       = $opts{dir}{base}      . '/cache';
    $opts{dir}{po}          = $opts{dir}{base}      . '/po';

    # Абсолютные пути к ресурсам
    $opts{dir}{htdocs}      = $opts{dir}{base}      . '/htdocs';
    $opts{dir}{css}         = $opts{dir}{htdocs}    . '/css';
    $opts{dir}{img}         = $opts{dir}{htdocs}    . '/img';
    $opts{dir}{js}          = $opts{dir}{htdocs}    . '/js';

    # относительные пути к ресурсам
    $opts{url}{base}        = $ENV{SERVER_NAME};
#    $opts{url}{css} =      $opts{url}{base} . '/css';
#    $opts{url}{img} =      $opts{url}{base} . '/img';
#    $opts{url}{js} =       $opts{url}{base} . '/js';

    my $self = bless \%opts, $class;

    my ($browser_locale) = $ENV{HTTP_ACCEPT_LANGUAGE} =~ m/^(\w+)/;

    # Set parameters by default, even it not declared in config file
#    $self->set('prop',    'info'    )   unless $self->get('prop');
    $self->set('action',  'default' )   unless $self->get('action');
    $self->set('locale',  $self->get('locale') || $browser_locale || 'en' );
#    $self->set('skin',    'default' )   unless $self->get('skin');
#    $self->set('refresh', 60        )   unless defined $self->get('refresh');
#    $self->set('collapse','yes'     )   unless $self->get('collapse');
#    $self->set('geo_ip',  'yes'     )   unless $self->get('geo_ip');

    # Load params from file
    $self->load_from_files;

    # Get skin files path
    $self->{dir}{skin}{files}   = $opts{dir}{htdocs} . '/skins';
    $self->{dir}{skin}{current} = $self->{dir}{skin}{files} . '/' .
                                  $self->get('skin');
    $self->{dir}{skin}{base}    = $self->{dir}{templates} . '/' .
                                  $self->get('skin');
    $self->{url}{skin}{base} = 'skins/' . $self->get('skin');

    # Init parameters from current value to cookie
    # It`s need for first time start to init all default cookie
    $self->set($_, $self->get($_)) for qw(refresh skin prop);

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

    return 1;
}


=head2 get $name

Get parameter by $name.

=cut

sub get
{
    my ($self, $name) = @_;
    my $value = CGI::param($name)       // CGI::cookie($name)   //
                $self->{param}{$name}   // '';

    return $value;
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

Get list of aviable skins

=cut

sub skins
{
    my ($self) = @_;

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
            s/^\s+//, s/\s+$//, s/[^\w\s.,]//g for $title;
        }
        # Set skin description
        $skins{$name} = $title || ucfirst( lc $name );
    }

    return \%skins;
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
    # юникодные символы преобразуем в них самих
    # вметсто \x{уродство}
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
