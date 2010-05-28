package Dist::Zilla::PluginBundle::DANIELP;
BEGIN {
  $Dist::Zilla::PluginBundle::DANIELP::VERSION = '1.02';
}
use v5.8.1;
use utf8;

use namespace::autoclean;
use Moose;

use Dist::Zilla 2.101040;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use Dist::Zilla::PluginBundle::Git;

has version_regexp => (
    is => 'ro', lazy => 1,
    default => sub { '^release-(\d+\.\d+)$' }
);

has version_tag => (
    is => 'ro', lazy => 1,
    default => sub { 'release-%v' }
);

has skip => (
    is => 'ro', isa => 'ArrayRef', lazy => 1,
    default    => sub { $_[0]->payload->{skip} || [] }
);


sub configure {
    my ($self) = @_;

    # Install the long list of plugins I use for getting stuff released.
    $self->add_plugins(
        # -- distribution version
        [BumpVersionFromGit => {
            first_version   => '1.00',
            version_regexp  => $self->version_regexp
        }],

        # -- fetch and install files
        'GatherDir',
        'ExecDir',
        'ShareDir',

        # -- remove unwanted files
        'PruneCruft',
        'ManifestSkip',

        # -- prerequisites
        [AutoPrereq => { skip => $self->skip }],

        # -- rewrite files
        'PkgVersion',
        'PodVersion',

        # -- dynamic metadata

        # -- tests
        'ReportVersions',
        ['CompileTests' => { fake_home => 1 }],

        'HasVersionTests',
        'MetaTests',
        'MinimumVersionTests',
        'PortabilityTests',
        'SynopsisTests',
        'PodSyntaxTests',
        'UnusedVarsTests',
        'ExtraTests',

        # -- generate various support files
        'MetaConfig',
        'MetaYAML',
        'MetaJSON',
        'License',
        'Readme',
        'MakeMaker',

        ['ChangelogFromGit' => {
            file_name   => 'Changlog',
            wrap_column => 78,
            tag_regexp  => $self->version_regexp
        }],

        # -- pre-release tests and sanity checks
        'Manifest',
        'Git::Check',           # no dirty, dirty, filthy files here, please.
        'TestRelease',          # ensure tests pass before upload
        'ConfirmRelease',

        # -- release
        ['Git::Commit' => {     # store the changes, like changelog.
            commit_msg =>
                'Updated Changes for %v release of %N on %{yyyy-MM-dd}d%n%n%c',
        }],
        ['Git::Tag' => {
            tag_format  => $self->version_tag,
            tag_message =>
                'Tag the %v release of %N on %{yyyy-MM-dd}d',
        }],

        # -- send the distribution elsewhere, when we release.
        'UploadToCPAN'

        # REVISIT: Later, we should push somewhere public. :)
        # ['Git::Push' => { push_to => $self->push_to }],
    );
}

__PACKAGE__->meta->make_immutable;
__END__

=pod

=encoding utf8

=head1 NAME

Dist::Zilla::PluginBundle::DANIELP - (you shouldn't) use Dist::Zilla like DANIELP

=head1 VERSION

version 1.02

=head1 DESCRIPTION

This is the plugin bundle that Daniel uses; it is a bit quirky and probably
not very well suited to use by anyone else.  After all, I am a fairly new CPAN
author, and the last thing you want to do is emulate B<my> public mistakes.

This integrates with the way I use git to manage my software, and applies
automatic tests that I consider reasonable.  For details, see the source;
until I consider my work suitable for someone else to emulate, I don't see
that making it easy is going to help anyone out.

=head1 AUTHORS

=over

=item Daniel Pittman <daniel@rimspace.net>

=item Based on work by Ricardo Signes in L<Dist::Zilla::PluginBundle::RJBS>

=back

=head1 COPYRIGHT AND LICENSE

Based on L<Dist::Zilla::PluginBundle::RJBS>, which is Copyright 2010 by
Ricardo Signes.

Copyright 2010 by Daniel Pittman.

=cut