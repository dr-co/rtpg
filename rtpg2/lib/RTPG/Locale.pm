use warnings;
use strict;
use utf8;
use open ':utf8';

=head1 RTPG::Locale

Translate strings use *.po files

=cut

package RTPG::Locale;
use lib qw(.. ../);

use Locale::PO;
use RTPG::Config;

our @EXPORT_OK = qw(po gettext);

our $po;

=head2 po

Translate string

=cut

sub po
{
    # Chache po object
    return $po if $po;
    return $po = RTPG::Locale->new(@_);
}

=head2 new

=cut

sub new
{
    my ($class, %opts) = @_;

    # Set default
    $opts{language} ||= 'en';

    # Get aviable translations
    my @langs = map { m|/(\w*?).po$| } glob sprintf '%s/*.po', cfg()->{dir}{po};
    warn 'No translation files' unless @langs;

    # Check for pod file and drop to default if not exists
    warn sprintf('Language %s not found', uc $opts{language}),
    $opts{language} = 'en'
        unless $opts{language} ~~ @langs;

    my $self = bless \%opts, $class;

    # Reload locale in first time
    $self->locale( $self->locale );

    return $self;
}

=head2 locale

Set or get current language

=cut
sub locale
{
    my ($self, $language) = @_;
    # Return current if not specified
    return $self->{language} unless defined $language;

    # Set and reload if new language set
    $self->{language} = $language || 'en';
    $self->{data}     = Locale::PO->load_file_ashash(
        sprintf '%s/%s.po', cfg()->{dir}{po}, $self->{language});

    return $self->{language};
}

=head2 gettext

Get translated string by untranslated string. Can be used as OOP and functional
style.

=cut
sub gettext
{
    my ($param1, $param2) = @_;

    my ($self, $string);

    # If OOP
    if('RTPG::Locale' eq ref $param1)
    {
        $self = $param1;
        $string = $param2;
    }
    # If functional
    else
    {
        $self = po;
        $string = $param1;
    }

    my $id = '"'.$string.'"';

    # Return translated string if exists
    return $self->{data}{$id}->dequote( $self->{data}{$id}->msgstr ) ||
           $self->{data}{$id}->dequote( $self->{data}{$id}->msgid )  ||
           $string
                if exists $self->{data}{$id};
    # Return input as is
    return $string;
}

1;
