package Call::Context;

=encoding utf-8

=head1 NAME

Call::Context - Sanity-check calling context

=head1 SYNOPSIS

    use Call::Context;

    #Will die() if the context is not list.
    Call::Context::must_be_list();

=head1 DISCUSSION

If your function only expects to return a list, then a call in some other
context is, by definition, an error. The problem is that, depending on how
the function is written, it may actually do something expected in testing, but
then in production act differently.

Call C<must_be_list()> at the top of any function that returns a list to ensure
that no one gets bitten by the unexpected.

=head1 REPOSITORY

https://github.com/FGasper/p5-Call-Context

=cut

use strict;
use warnings;

our $VERSION = 0.01;

my $_OVERLOADED_X;

sub must_be_list {
    return if (caller 1)[5];    #wantarray

    $_OVERLOADED_X ||= eval q{
        package Call::Context::X;
        use overload ( q<""> => \\&_spew );
        1;
    };

    die Call::Context::X->_new();
}

#----------------------------------------------------------------------

package Call::Context::X;

#Not to be instantiated except from Call::Context!

sub _new {
    my ($class) = @_;

    my ($sub, $ctx) = (caller 2)[3, 5];
    my (undef, $cfilename, $cline, $csub) = caller 3;

    $ctx = defined($ctx) ? 'scalar' : 'void';

    return bless \"$sub called in non-list ($ctx) context from $csub (line $cline of $cfilename)", $class;
}

sub _spew { ${ $_[0] } }

1;
