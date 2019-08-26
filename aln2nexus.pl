#!usr/bin/perl
$file=$ARGV[0];
$file2=$ARGV[1];
open(FILE,"<$file");
@lines=<FILE>;
close FILE;
foreach $line (@lines){
	if($line=~/>/){
		$output.="\n$line";
	}else{
		$line=~s/\n//g;
		$output.="$line";
	}
}
$output=~s/\n//;
@fastas=split(/>/,$output);
undef $output;
shift @fastas;
chomp @fastas;
$ntax=scalar @fastas;
foreach $fasta (@fastas){
	($taxa,$chars)=split(/\n/,$fasta,2);
	#$taxa=substr $taxa, 0, 99;
	$output.="$taxa\t$chars\n";
}
$nchar=length $chars;
open(OUTFILE,">>$file.nex");
print OUTFILE "#NEXUS\nBEGIN DATA;\ndimensions ntax=$ntax nchar=$nchar;\nformat missing=?\ninterleave=no datatype=PROTEIN gap=- match=.;\n\nmatrix\n$output;\nend;";
close OUTFILE;
open(OUTFILE,">>$file.phylip");
print OUTFILE "$ntax $nchar\n$output";
close OUTFILE;
open(FILE,"<$file2");
@lines=<FILE>;
close FILE;
open(OUTFILE,">>$file.mbatch");
print OUTFILE "begin mrbayes;\n\tset autoclose=yes nowarn=yes;\n\texecute $file.nex;\n\tlset nst=6 rates=invgamma;\n\tprset aamodelpr=fixed(lg);\n\t";
close OUTFILE;
foreach $line (@lines){
	if ($line=~/rate \w <[\-]> \w: /){
		chomp $line;
		($mut,$revmat)=split(/: /,$line,2);
		$revmats.="$revmat,";
	}elsif ($line=~/freq pi\(\w\): /){
		chomp $line;
		($sub,$freq)=split(/: /,$line,2);
		$freqs.="$freq,";
	}elsif ($line=~/alpha:/){
		chomp $line;
		($label,$alpha)=split(/ /,$line,2);
	}
}
chop $revmats;
chop $freqs;
open(OUTFILE,">>$file.mbatch");
print OUTFILE "mcmcp ngen=1000000 nruns=2 nchains=4 samplefreq=100 printfreq=10000 relburnin=yes burninfrac=0.25 file=$file.mb;\n\tmcmc;\n\tsumt;\n\tsump;\nend;";
close OUTFILE;