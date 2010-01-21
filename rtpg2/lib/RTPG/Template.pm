use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 Template

Модуль шаблонов

=cut

package RTPG::Template;
use base qw(Template);
use lib qw(.. ../ );

use CGI;
use RTPG::Config;

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

    # Получение выдачи #########################################################
    my ($header, $output) = ('', '');

    # Получим заголовок
    $header = CGI->new->header(
        -charset        => 'utf-8',
        -type           => 'text/html',
        -Cache_Control  => 'no-cache, no-store, max-age=0, must-revalidate',
        -expires        => 'now'
    );

    # Добавим стандартные параметры
    push @_, {
            common  => { },
            config  => cfg()
        };
    # Парсинг шаблона
    $self->SUPER::process(@_, \$output);

    # Если была ошибка то выведим соответствующую страницу
    if( $self->error() )
    {
        # Поменяем страницу
        shift @_;
        unshift @_, 'error.tt.html';

        # Добавим сообщение об ошибке
        my ($message, $status) = ($self->error(), 503);
        # Если шаблон не найден (станицы нет) то выведим 404
        $status = 404, $message = 'File not found'
            if $message =~ m/^file error - .* not found$/;

        $_[1]{error} = {
            message => $message,
            status  => $status,
        };

        # Выведим страницу либо просто сообщение если шаблоны совсем не работают
        $self->SUPER::process(@_, \$output);
        $output .= $self->error() if $self->error();
    }

    # Вывод ####################################################################
    print $header;
    print $output;
}

1;