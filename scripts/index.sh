#### INDEX SCRIPT ####

contaminants=$1
outdir=$2

echo -e "\n### Default number of threads set to 8, please modify as required###\n"

STAR 	--runThreadN 8 --runMode genomeGenerate --genomeDir $outdir \
	--genomeFastaFiles $contaminants --genomeSAindexNbases 9
echo
