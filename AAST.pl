$alignment=$ARGV[0];
$range=$ARGV[1];
$outfile=$ARGV[2];
$choice=$ARGV[3];
($start,$stop)=split(/-/,$range,2);
open(FILE,"<$alignment");
@lines=<FILE>;
close FILE;
$single=join('',@lines);
@fastas=split(/>/,$single);
shift @fastas;
chomp @fastas;
foreach $fasta (@fastas){
	($name,$seq)=split(/\n/,$fasta,2);
	$seq=~s/X/-/g;
	@aas=split(//,$seq);
	$n=0;
	if ($name=~/MES/ or $name=~/SRR(130381[2-9]|130382[0-9]|130383[0-2])/ or $name=~/SRR1303839/ or $name=~/0500m/ or $name=~/0770m/){
		$deep_seqs++;
		foreach $aa (@aas){
			$deep_count{$n}{$aa}++;
			$deep_count{"Overall"}{$aa}++;
			$all_count{$n}{$aa}++;
			$n++;
		}
	}else{
		$shallow_seqs++;
		foreach $aa (@aas){
			$shallow_count{$n}{$aa}++;
			$shallow_count{"Overall"}{$aa}++;
			$all_count{$n}{$aa}++;
			$n++;
		}
	}
	$n=0;
	#if ($name=~/Q4FL24/){
	#	foreach $aa (@aas){
	#		if ($aa!~/-/){
	#			$must_keep.=",$n,";
	#		}
	#		$n++;
	#	}
	#}
}
@residues=qw(R H K D E S T N Q A V M F I L W Y C G P -);
foreach $residue (@residues){
	open(OUTFILE,">>$outfile");
	print OUTFILE ",$residue";
	close OUTFILE;
}
open(OUTFILE,">>$outfile");
print OUTFILE "\nShallow Overall";
close OUTFILE;
foreach $residue (@residues){
	open(OUTFILE,">>$outfile");
	print OUTFILE ",$shallow_count{'Overall'}{$residue}";
	close OUTFILE;
}
open(OUTFILE,">>$outfile");
print OUTFILE "\nDeep Overall";
close OUTFILE;
foreach $residue (@residues){
	open(OUTFILE,">>$outfile");
	print OUTFILE ",$deep_count{'Overall'}{$residue}";
	close OUTFILE;
}
for($position=$start;$position<=$stop;$position++){
	open(OUTFILE,">>$outfile");
	print OUTFILE "\nShallow $position";
	close OUTFILE;
	$count=0;
	foreach $residue (@residues){
		open(OUTFILE,">>$outfile");
		print OUTFILE ",$shallow_count{$position}{$residue}";
		close OUTFILE;
		$count+=$shallow_count{$position}{$residue};
	}
	$count-=$shallow_count{$position}{"-"};
	if ($choice=~/y/i and $count<(0.05*$shallow_seqs)){# and $must_keep!~/,$position,/){
		open(OUTFILE,">>weak_shallow_columns.txt");
		print OUTFILE "$position,";
		close OUTFILE;
	}
	open(OUTFILE,">>$outfile");
	print OUTFILE "\nDeep $position";
	close OUTFILE;
	$count=0;
	foreach $residue (@residues){
		open(OUTFILE,">>$outfile");
		print OUTFILE ",$deep_count{$position}{$residue}";
		close OUTFILE;
		$count+=$deep_count{$position}{$residue};
	}
	$count-=$deep_count{$position}{"-"};
	if ($choice=~/y/i and $count<(0.05*$deep_seqs)){# and $must_keep!~/,$position,/){
		open(OUTFILE,">>weak_deep_columns.txt");
		print OUTFILE "$position,";
		close OUTFILE;
	}
	$count=0;
	foreach $residue (@residues){
		$count+=$all_count{$position}{$residue};
	}
	$count-=$all_count{$position}{"-"};
	if ($choice=~/y/i and $count<(0.05*scalar @fastas)){
		open(OUTFILE,">>weak_columns.txt");
		print OUTFILE "$position,";
		close OUTFILE;
		foreach $residue (@residues){
			$shallow_cuts{$residue}+=$shallow_count{$position}{$residue};
			$deep_cuts{$residue}+=$deep_count{$position}{$residue};
		}
	}
}
if ($choice=~/y/i){
	foreach $residue (@residues){
		open(OUTFILE,">>cut_totals.txt");
		print OUTFILE "Shallow,$residue,$shallow_cuts{$residue}\nDeep,$residue,$deep_cuts{$residue}\n";
		close OUTFILE;
	}
}