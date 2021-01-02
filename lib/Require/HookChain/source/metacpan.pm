package Require::HookChain::source::metacpan;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;
use Log::ger;

use Require::Hook::Source::MetaCPAN;

sub new {
    my ($class, $die) = @_;
    $die = 1 unless defined $die;
    bless { die => $die }, $class;
}

sub Require::HookChain::source::metacpan::INC {
    my ($self, $r) = @_;

    my $filename = $r->filename;

    # safety, in case we are not called by Require::HookChain
    return () unless ref $r;

    if (defined $r->src) {
        log_trace "[RHC:source::metacpan] source code already defined for $filename, declining";
        return;
    }

    my $rh = Require::Hook::Source::MetaCPAN->new(die => $self->{die});
    my $res = Require::Hook::Source::MetaCPAN::INC($rh, $filename);
    return unless $res;
    $r->src($$res);
}

1;
# ABSTRACT: Prepend a piece of code to module source

=for Pod::Coverage .+

=head1 SYNOPSIS

In Perl code:

 use Require::HookChain 'source::metacpan';
 use Ask; # will retrieve from MetaCPAN, even if it's installed

On the command-line:

 # will retrieve from MetaCPAN if Ask is not installed
 % perl -MRHC=-end,1,source::metacpan -MAsk -E...


=head1 DESCRIPTION


=head1 SEE ALSO

L<Require::HookChain>

L<Require::Hook::MetaCPAN>
