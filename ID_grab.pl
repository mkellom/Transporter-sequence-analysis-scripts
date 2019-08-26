#!usr/bin/perl
$position_file=$ARGV[0];
$fasta_file=$ARGV[1];
$start=$ARGV[2];
$stop=$ARGV[3];
open(FILE,"<$position_file");
@positions=<FILE>;
close FILE;
open(FILE,"<$fasta_file");
@lines=<FILE>;
close FILE;
$single=join('',@lines);
@fastas=split(/>/,$single);
shift @fastas;
foreach $position (@positions){
	chomp $position;
	($amt,$beg,$end,$tag)=split(/ /,$position,4);
	if ($beg>=$start and $beg<=$stop){
		$tag=~s/>//;
		($tag,$label)=split(/_/,$tag,2);
		push(@tags,$tag);
	}
}
foreach $fasta (@fastas){
	($number,$data)=split(/_/,$fasta,2);
	$fasta_hash{$number}="$fasta";
}
foreach $tag (@tags){
	$fasta=$fasta_hash{$tag};
	open(OUTFILE,">>subtree_MGII.fasta");
	print OUTFILE ">$fasta";
	close OUTFILE;
}