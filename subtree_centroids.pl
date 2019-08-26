#!usr/bin/perl
use List::MoreUtils qw(uniq);
$start=$ARGV[0];
$stop=$ARGV[1];
$subtree=$ARGV[2];
open(FILE,"</home/mkellom/data/run/DHM/Depth_DHM/100_positions.txt");
@lines=<FILE>;
close FILE;
chomp @lines;
foreach $line (@lines){
	($amt,$beg,$end,$tag)=split(/ /,$line,4);
	$tag=~s/^.//;
	($number,$tag)=split(/_/,$tag,2);
	$pos_hash{$beg}=$number;
}
open(FILE,"<$subtree");
@lines=<FILE>;
close FILE;
$single=join('',@lines);
@fastas=split(/>/,$single);
shift @fastas;
chomp @fastas;
foreach $fasta (@fastas){
	($number,$info)=split(/_/,$fasta,2);
	$fasta_hash{$number}="$info";
}
for($i=$start;$i<=$stop-1;$i++){
	for($j=90;$j>=90;$j--){
		open(FILE,"/home/mkellom/data/run/DHM/Depth_DHM/$j.txt");
		@lines=<FILE>;
		close FILE;
		foreach $line (@lines){
			chomp $line;
			($amt,$beg,$end,$heat)=split(/ /,$line,4);
			if ($i==$beg){
				$reps{$heat}{$beg}="$beg $end";
				for($k=$beg;$k<=$end-1;$k++){
					$fasta=$fasta_hash{$pos_hash{$k}};
					$reps{$heat}{$beg}.="\n>$fasta";
				}
				push(@heats,$heat);
				push(@begs,$beg);
				$i=$end-1;
				$j=0;
				last;
			}
		}
	}
}
@heats=uniq(@heats);
foreach $heat (sort{$a<=>$b}@heats){
	$shallow++;
	next if ($heaters=~/,$heat,/);
	last if ($shallow>5);
	foreach $beg (@begs){
		next if ($reps{$heat}{$beg}!~/>/);
		open(OUTFILE,">>subtree_MGII_reps90.txt");
		print OUTFILE "\#$heat\n$reps{$heat}{$beg}\n\n";
		close OUTFILE;
	}
	$heaters.=",$heat,";
}
@heats=uniq(@heats);
foreach $heat (sort{$b<=>$a}@heats){
	$deep++;
	next if ($heaters=~/,$heat,/);
	last if ($deep>5);
	foreach $beg (@begs){
		next if ($reps{$heat}{$beg}!~/>/);
		open(OUTFILE,">>subtree_MGII_reps90.txt");
		print OUTFILE "\#$heat\n$reps{$heat}{$beg}\n\n";
		close OUTFILE;
	}
	$heaters.=",$heat,";
}