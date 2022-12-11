#### INDEX SCRIPT ####

contaminants=$1
outdir=$2

echo -e "\n### Default thread number set to 6, please modify if neccessary###\n"

STAR 	--runThreadN 6 --runMode genomeGenerate --genomeDir ${outdir} \
	--genomeFastaFiles ${contaminants} --genomeSAindexNbases 9
echo
