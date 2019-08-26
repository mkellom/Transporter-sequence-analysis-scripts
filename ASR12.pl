$clade=$ARGV[0];
$fasta=$ARGV[1];
($name,$ext)=split(/\./,$fasta,2);
system("mkdir /home/mkellom/data/run/DHM/raxml_output_${clade}");
system("mkdir /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft");
system("perl /home/mkellom/scripts/Fasta_name_cut.pl ${fasta}");
open(OUTFILE,">/home/mkellom/scripts/mkellom.ASR1_mafft12.job");
print OUTFILE "#!/bin/bash
#PBS -l nodes=1:ppn=12
#PBS -M mkellom\@ucsb.edu
#PBS -m a
cd \$PBS_O_WORKDIR
NODE_LIST=`cat \$PBS_NODEFILE `
echo \$NODE_LIST
source ~/.bashrc
mafft --maxiterate 1000 --localpair --thread 12 ${name}.cut.${ext} > /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/$clade.mafft
/sw/csc/raxml/raxmlHPC-PTHREADS-SSE3 -p 12087 -x 12087 -# 1000 -f a -k -m PROTGAMMAAUTO -s /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/$clade.mafft -n mafft_${clade}.raxml -w /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft -T 12
perl /home/mkellom/scripts/aln2nexus.pl /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/$clade.mafft /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/RAxML_info.mafft_${clade}.raxml
iqtree -s /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/$clade.mafft -m TEST -nt AUTO -alrt 10000 -pre /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/$clade.mafft
/sw/openmpi-2.1.2/bin/mpirun -np 8 mb-mpi /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/$clade.mafft.mbatch > raxml_output_${clade}/mafft/mb_log_mafft.txt
#mkdir /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/ancestral
#perl /home/mkellom/software/FastML.v3.1/www/fastml/FastML_Wrapper.pl --MSA_File /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/subtree_${clade}_centroids.mafft --seqType aa --outDIR /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/ancestral -Tree /home/mkellom/data/run/DHM/raxml_output_${clade}/mafft/RAxML_bestTree.mafft_${clade}.raxml --SubMatrix LG --indelReconstruction BOTH --optimizeBL no --UseGamma yes  --indelCutoff 0.5 --jointReconstruction yes";
close OUTFILE;
system("qsub /home/mkellom/scripts/mkellom.ASR1_mafft12.job");
