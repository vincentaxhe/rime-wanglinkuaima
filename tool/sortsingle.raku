#!/bin/env raku
my $dic = @*ARGS[0].IO;
my @common = @*ARGS[1].IO.lines;
my $pinyin = @*ARGS[2].IO;
my %duoyinzi;
for $pinyin.lines {
	next unless /\t/;
	my ($hanzi, $duoyin, $freq) = .split("\t", 3);
	next if $hanzi.chars > 1 or not $freq;
	my $sheng = $duoyin.substr(0,1);
	%duoyinzi{$hanzi}.push: $sheng => $freq;
}
my %duoyinzi1;
for %duoyinzi.kv -> $dz, $duyin {
	# put $dz.raku;
	for $duyin.List {
		my $value = .value.subst('%',);
		%duoyinzi1{$dz}{.key} += $value
	}
}
my %duoyinzi2;
for %duoyinzi1.kv -> $dz, $duyin {
	for $duyin.sort(*.value) {
		%duoyinzi2{$dz} = .key
	}
}

my %kuaima;
for $dic.lines {
	next unless /\t/;
	next if /\tv/;
	my ($dz, $bianma) = .split("\t");
	%kuaima{$dz} //= [];
	getcode %kuaima{$dz}, $bianma;
}
my @duoyinzi;
my %kuaima1;
for %kuaima.kv -> $dz, $bianmalist {
	for $bianmalist.List -> $bianma {
		if $bianmalist.elems == 1 {
			%kuaima1{$dz} = $bianma;
			next
		}
		with %duoyinzi2{$dz} {
			if $_ eq $bianma.substr(0,1) {
				%kuaima1{$dz} = $bianma;
			}
		}
	}
}

my @a = 'a'..'z';
my @b = |@a, ';';
my %mawei;
my @poss = |@a, |(@a X @b), |(@a X @b X @b), |(@a X @b X @b X @b);
for @common -> $dz {
	next unless %kuaima1{$dz};
	my $bianma = %kuaima1{$dz}
	my $flag = False;
	for @poss.kv -> $i, $j {
		next unless $j;
		my $mawei = $j.join('');
		if $bianma ~~ /^$mawei/ {
			$flag = True;
			($dz, $mawei).join("\t").put;
			%mawei{$mawei}.push: $dz;
			if $bianma.chars > $mawei.chars {
				($dz, $bianma).join("\t").put;
				%mawei{$bianma}.push: $dz;
			}
			@poss[$i] = Nil;
			last;
		}
	}
	unless $flag {
		($dz, $bianma).join("\t").put;
		%mawei{$bianma}.push: $dz;
	}

}


sub getcode(@code, $new) {
	if not @code {
		@code[0] = $new
	} elsif $new ~~ /^"@code[*-1]"/ { #这里只能使用引号插入，大括号不会报错但得不到正确的结果
		@code[*-1] = $new
	} else {
		@code.push: $new
	}
}
