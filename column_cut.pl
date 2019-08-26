$file=$ARGV[0];
$empty_columns=$ARGV[1];
open(FILE,"<$file");
@lines=<FILE>;
close FILE;
chomp @lines;
foreach $line (@lines){
	if ($line=~/>/){
		$fasta.="\n$line\n"
	}else{
		$fasta.="$line";
	}
}
($name,$ext)=split(/\./,$file,2);
chomp $empty_columns;
@empties=split(/,/,$empty_columns);
foreach $empty (@empties){
	if ($empty=~/\-/){
		($start,$stop)=split(/\-/,$empty);
		for ($i=$start;$i<=$stop;$i++){
			push(@deletes,$i);
		}
	}else{
		push(@deletes,$empty);
	}
}
@fastas=split(/\n/,$fasta);
shift @fastas;
foreach $fasta (@fastas){
	chomp $fasta;
	if ($fasta=~/>/){
		open(OUTFILE,">>$name.cut.fasta");
		print OUTFILE "$fasta\n";
		close OUTFILE;
	}else{
		@positions=split(//,$fasta);
		foreach $delete (@deletes){
			undef $positions[$delete-1];
		}
		@positions=grep{$_ ne ''}@positions;
		$sequence=join('',@positions);
		open(OUTFILE,">>$name.cut.fasta");
		print OUTFILE "$sequence\n";
		close OUTFILE;
	}
}