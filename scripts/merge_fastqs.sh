#### SAMPLE MERGE SCRIPT ####

sampledir=$1
outdir=$2
sampleid=$3
cat $sampledir/${sampleid}-* >> ${outdir}/${sampleid}
