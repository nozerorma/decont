#### SAMPLE MERGE SCRIPT ####

sampledir=$1
outdir=$2
sampleid=$3
#cat "$sampledir/${sampleid}\*.1.1\*" "$sampledir/${sampleid}\*.1.2\*" > "$outdir/$sampleid"
cat $sampledir/${sampleid}-* >> ${outdir}/${sampleid}



# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).
