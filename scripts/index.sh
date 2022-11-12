#### INDEX SCRIPT ####

contaminants=$1
outdir=$2

STAR 	--runThreadN 6 --runMode genomeGenerate --genomeDir ${outdir} \
	--genomeFastaFiles ${contaminants} --genomeSAindexNbases 9
echo
