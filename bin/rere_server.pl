#!/usr/bin/env perl

package ReRe::Runner;

use strict;
use warnings;

#VERSION

use Plack::Loader;
use FindBin qw($Bin);
my $path_app = "$Bin/../psgi/rere.psgi";
exit unless -r $path_app;
require Plack::Runner;

my $app = Plack::Util::load_psgi $path_app;

my $runner = Plack::Runner->new;
$runner->parse_options(@ARGV);
$runner->run($app);

