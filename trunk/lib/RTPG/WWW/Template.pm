use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 Template

Модуль шаблонов

=cut

package RTPG::WWW::Template;
use base qw(Template);

use CGI;
use Encode qw(is_utf8 decode encode);
use RTPG::WWW::Config;
use RTPG::WWW::Locale;

sub new
{
    my $class = shift;

    $Template::Stash::ROOT_OPS->{dump} =
    $Template::Stash::SCALAR_OPS->{dump} =
    $Template::Stash::HASH_OPS->{dump} =
    $Template::Stash::LIST_OPS->{dump} = sub {'###'.Dumper(@_).'###'};
    my $obj = $class->SUPER::new(
        RELATIVE        => 1,
        ABSOLUTE        => 1,
        RECURSION       => 1,
        INCLUDE_PATH    => cfg->{dir}{skin}{base} . ':' .
                           cfg->{dir}{templates},
        PRE_CHOMP       => 1,
        POST_CHOMP      => 1,
        TRIM            => 1,
        WRAPPER         => 'main.tt.html',
#        COMPILE_EXT     => '.ttc',
#        COMPILE_DIR     => cfg()->{dir}{cache},
        @_);

    return $obj;
}

=head2 process

Output template.

=cut

sub process
{
    my ($self, $template, $opts) = @_;

    $opts = {} if !defined $opts or !%$opts;

    # Get output ###############################################################
    my ($header, $output) = ('', '');

    # Get header
    $header = CGI->new->header(
        -charset        => 'utf-8',
        -type           => 'text/html',
        -Cache_Control  => 'no-cache, no-store, max-age=0, must-revalidate',
        -expires        => 'now',
        (cfg->cookies)  ? (-cookie => cfg->cookies)
                        : (),
    );

    # Add common params
    $opts = {
        common  => { },
        config  => cfg(),
        gettext => sub{ return RTPG::WWW::Locale::gettext(@_)   },
        langs   => sub{ return RTPG::WWW::Locale::aviable()     },
        skins   => sub{ return cfg->skins()                     },
        %$opts
    };

    # Get body
    $self->SUPER::process($template, $opts, \$output);

    # Load error page if error
    if( $self->error() )
    {
        # Change to error page
        $template = 'error.tt.html';

        # If template not found return 404 status
        if( $self->error() =~ m/^file error - .* not found$/ )
        {
            $opts->{error} = {
                message => RTPG::WWW::Locale::gettext('File not found'),
                status => 404
            };
        }
        # Get error message
        else
        {
            $opts->{error} = { message => $self->error(), status => 503 };
        }

        # Get error page body or error message only if Template not work
        $self->SUPER::process($template, $opts, \$output);
        $output .= $self->error() if $self->error();
    }

    # Be shure output is utf8
    $output = decode( utf8 => $output ) unless is_utf8 $output;

    # Output ###################################################################
    print $header;
    print $output;
}

1;
