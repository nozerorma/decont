#### SAMPLE MERGE SCRIPT ####

sampledir=$1
outdir=$2
sampleid=$3

if [ -e $outdir/$sampleid* ]
then
	echo -e "$sampleid has already been merged, skipping merging.\n"
else
	cat $sampledir/$sampleid-*.fastq > $outdir/$sampleid.fastq
	echo -e "Sample $sampleid merged.\n"
fi
