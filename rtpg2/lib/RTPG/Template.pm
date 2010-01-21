use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 Template

Модуль шаблонов

=cut

package RTPG::Template;
use base qw(Template);
use lib qw(.. ../ lib/);

use CGI;
use RTPG::Config;
use RTPG::Locale;

sub new
{
    my $class = shift;
    my $obj = $class->SUPER::new(
        RELATIVE        => 1,
        ABSOLUTE        => 1,
        RECURSION       => 1,
        INCLUDE_PATH    => cfg()->{dir}{skin}{base} . ':' .
                           cfg()->{dir}{templates},
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

Вывод шаблона

=cut
sub process
{
    my $self = shift;

    # Get output ###############################################################
    my ($header, $output) = ('', '');

    # Get header
    $header = CGI->new->header(
        -charset        => 'utf-8',
        -type           => 'text/html',
        -Cache_Control  => 'no-cache, no-store, max-age=0, must-revalidate',
        -expires        => 'now'
    );

    # Add common params
    push @_, {
            common  => { },
            config  => cfg(),
            gettext => sub{ return RTPG::Locale::gettext(@_) },
        };
    # Get body
    $self->SUPER::process(@_, \$output);

    # Load error page if error
    if( $self->error() )
    {
        # Change to error page
        shift @_;
        unshift @_, 'error.tt.html';

        # Get error message
        my ($message, $status) = ($self->error(), 503);
        # If template not found return 404 status
        $status = 404, $message = RTPG::Locale::gettext('File not found')
            if $message =~ m/^file error - .* not found$/;

        # Add error message
        $_[1]{error} = {
            message => $message,
            status  => $status,
        };

        # Get error page body or error message only if Template not work
        $self->SUPER::process(@_, \$output);
        $output .= $self->error() if $self->error();
    }

    # Output ###################################################################
    print $header;
    print $output;
}

1;
