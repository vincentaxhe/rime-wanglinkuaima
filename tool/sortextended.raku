#!/bin/env raku
my $kuaima = @*ARGS[0].IO;
my @common = @*ARGS[1].IO.lines;

my %prior;
my %cizu;
my @cizu;
sub add ($new) {
	my @newtwo = $new.comb.rotor(2 => -1);
	my $flag = False;
	for @newtwo {
		my $two = .join('');
		if defined %cizu{$two} {
			%cizu{$two}.push: $new;
			$flag = True;
			last;
		}
	}
	@cizu.push: $new unless $flag;
}

sub sortgroup(@group) {
	my %hash;
	for @group {
		my $prior = countprior $_;
		%hash{$_} = $prior;
	}
	my @sorted;
	for %hash.sort(*.value) {
		@sorted.push: .key
	}
	return @sorted;
}

sub countprior($string) {
	my $sum;
	for $string.comb {
		defined %prior{$_} or die $_;
		$sum += %prior{$_}
	}
	return $sum
}

for @common.kv -> $i, $j {
	%prior{$j} = $i
}

for $kuaima.lines {
	%cizu{$_}[0] = $_ if .chars == 2;
}

for $kuaima.lines {
	next if .chars == 2;
	add $_;
}
my %cizusort;
for %cizu.keys {
	%cizusort{$_} = countprior $_
}

for %cizusort.sort(*.value) -> $two {
	for sortgroup %cizu{$two.key} {
		.put
	}
}

for sortgroup @cizu {
	.put
}
