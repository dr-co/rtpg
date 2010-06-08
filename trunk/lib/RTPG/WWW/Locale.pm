use warnings;
use strict;
use utf8;

=head1 RTPG::WWW::Locale

Translate strings use *.po files

=cut

package RTPG::WWW::Locale;
use base qw(Exporter);

use Locale::PO;
use Encode qw(is_utf8 decode);

use RTPG::WWW::Config;

our @EXPORT_OK = qw(po gettext);

our $po;

=head2 po

Translate string

=cut

sub po
{
    # Chache po object
    return $po if $po;
    return $po = RTPG::WWW::Locale->new(@_);
}

=head2 new

=cut

sub new
{
    my ($class, %opts) = @_;

    # Set default
    $opts{language} ||= cfg->get('locale');

    # Get available translations
    my @langs = available();
    warn 'No translation files' unless @langs;

    # Check for pod file and drop to default if not exists
    unless ($opts{language} ~~ @langs) {
        warn sprintf('Language %s not found', uc $opts{language});
        $opts{language} = 'en';
    }

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
    if('RTPG::WWW::Locale' eq ref $param1)
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

    # Return translated string if exists or as is
    $string = $self->{data}{$id}->dequote( $self->{data}{$id}->msgstr ) ||
        $self->{data}{$id}->dequote( $self->{data}{$id}->msgid )  ||
        $string
            if exists $self->{data}{$id};
    $string = decode utf8 => $string unless is_utf8 $string;
    return $string;
}

=head2 available

Get available translations

=cut

sub available
{
    # Get available translations
    return map { m|/(\w*?).po$| } glob sprintf '%s/*.po', cfg()->{dir}{po};
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
