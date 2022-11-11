#### INDEX SCRIPT ####

# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

contaminants=$1
outdir=$2

STAR 	--runThreadN 6 --runMode genomeGenerate --genomeDir ${outdir} \
	--genomeFastaFiles ${contaminants} --genomeSAindexNbases 9
echo
