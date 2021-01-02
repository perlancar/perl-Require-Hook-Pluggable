package Require::Hook::Pluggable;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;
use Log::ger;

my $our_hook; $our_hook = sub {
    my ($self, $filename) = @_;

    my $src = $r->src;
    if (defined $src) {
        return \$src;
    } else {
        die "Can't locate $filename in \@INC";
    }
};

sub new {
    my $class = shift;
    my $opts = ref($_[0]) eq 'HASH' ? shift : {};
    my @plugins0 = @_;

    my @plugin_instances;
    my $cur_plugin;
    while (@plugins0) {
        if (defined $cur_plugin) {
            if (ref $plugins[0] eq 'HASH') {
                my $args = shift @plugins0;
                push @plugin_instances, "Require::HookPlugin::$cur_plugin"->new(%$args);
            } else {
                push @plugin_instances, "Require::HookPlugin::$cur_plugin"->new;
            }
            undef $cur_plugin;
        } else {
            $cur_plugin = shift @plugins0;
            my $mod = "Require::HookPlugin::$cur_plugin";
            (my $mod_pm = "$mod.pm") =~ s!::!/!;
            require $mod_pm;
        }
    }
    push @plugin_instances, "Require::HookPlugin::$cur_plugin"->new
        if defined $cur_plugin;
    bless {plugin_instances=>\@plugin_instances}, $class;
}

sub Require::Hook::Pluggable::INC {
    my ($self, $filename) = @_;

    print STDERR __PACKAGE__ . ": entering handler\n" if $self->{debug};

}

1;
# ABSTRACT: Pluggable require hook

=head1 SYNOPSIS

Say you want to create a require hook plugin to prepend some code to the module
source code that is loaded. In your plugin source, in
F<Require/HookPlugin/munge/prepend.pm>:

 package Require::HookPlugin::munge::prepend;

 sub new {
     my ($class, %args) = @_;
     bless \%args, $class;
 }

 sub munge {
     my ($self, $r) = @_;

     return unless defined $r->{src};
     $r->{src} = "$self->{preamble};\n$src";
     return 1; # OK, continue to other plugin
 }

 1;

In a code to use this hook:

 use Require::Hook::Pluggable;
 use lib Require::Hook::Pluggable->new('munge::prepend'=>{preamble=>'use strict;'});


=head1 DESCRIPTION

This module lets you use require hook plugins. As one already understands, Perl
lets you put a coderef or object in C<@INC>. In the case of object, its C<INC>
method will be called by Perl:

 package My::INCHandler;
 sub new { ... }
 sub My::INCHandler::INC {
     my ($self, $filename) = @_;
     ...
 }

The method is passed itself then filename (which is what is passed to
C<require()>) and is expected to return nothing or a list of up to four values:
a scalar reference containing source code, filehandle, reference to subroutine,
optional state for subroutine (more information can be read from the L<perlfunc>
manpage). As soon as the first hook in C<@INC> returns non-empty value then the
search for source code is stopped.

With C<Require::Hook::Pluggable>, you can write logic in a hook plugin instead
of as a hook directly.

To create your own require hook plugin, see example in L</"SYNOPSIS">. First you
create a module under the C<Require::HookPlugin::*> namespace, then create one
or more methods that are supported by Require::Hook::Pluggable.


=head1 SEE ALSO

Modules that try to do roughly the same, in a different way:
L<Require::HookChain>, L<Require::Hook::More>

L<Require::Hook> namespace.
