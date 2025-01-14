#### ALIGNMENT SCRIPT ####

trimSid=$1
baseAlignSid=$2
starDir=$3

if [ -d $starDir/$baseAlignSid ]
then
	echo -e "Sequence decontamination already performed for $baseAlignSid, skipping alignment.\n"   
else
	echo -e "\n### Default number of threads is set to 8, please modify as required. ###\n" 
        echo -e "Decontaminating sample $baseAlignSid...\n"
	STAR\
        	--runThreadN 8 --genomeDir res/contaminants_idx \
                --outReadsUnmapped Fastx --readFilesIn $trimSid \
                --outFileNamePrefix $starDir/$baseAlignSid/
	echo -e "\nSample $baseAlignSid decontaminated.\n"
fi
