echo ####### RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso #######

# Run cleanup script at start
bash scripts/cleanup.sh 2>> log/errors.log

set -e

echo -e "Downloading required files...\n"
mkdir -p data


# Download and extract required genomes

for url in $(grep '^data' data/urls | cut -d$'\t' -f2 | sort -u)
do
        bash scripts/download.sh $url data yes 2>> log/errors.log
done


# Download, extract and filter decontaminants database

url=$(grep '^contaminants' data/urls | cut -d$'\t' -f2)
bash scripts/download.sh $url res yes filt 2>> log/errors.log


# STAR Index building

echo -e "\nBuilding contaminants database index...\n"

if [ ! "$(ls -A "res/contaminants_idx" 2>> log/errors.log)" ]
then
        # Build contaminants index
        bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
else
        echo -e "Contaminants database index already exists, skipping\n\n"
fi

mkdir -p out && mkdir -p out/merged

for sid in $(find data -name *.fastq -exec basename {} \; | cut -d"-" -f1 | sort -u)
do
        echo -e "Merging $sid sample files together...\n"
        # Merge the samples into a single file
        bash scripts/merge_fastqs.sh data out/merged $sid
done


# Cutadapt trimming step

echo -e "\nRemoving adapters...\n"

if [ ! "$(ls -A "out/trimmed" 2>> log/errors.log)" ] 
then
        mkdir -p out/trimmed && trimDir="out/trimmed"
        mkdir -p log/cutadapt && trimLog="log/cutadapt"
        for sid in $(find out/merged/ -name \* -type f)
        do
                basenameSid=$(basename $sid .fastq)
                echo -e "\nRemoving adapters from ${basenameSid}\n"
                # Run cutadapt for all merged files
                cutadapt \
                        -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
                        -o $trimDir/${basenameSid}_trimmed.fastq.gz $sid > $trimLog/$basenameSid.log
        	echo
	done
else
        echo -e "Adapters already trimmed, skipping trimming\n" 
fi


# STAR alignment step

echo -e "\nAligning reads to contaminants. Outputing non-aligned reads...\n"

if [ ! "$(ls -A "out/star" 2>> log/errors.log)" ] 
then
        mkdir -p out/star/$basenameSid && starDir="out/star"
        for trimSid in $(find $trimDir -name \* -type f)
        do
                basenameSid=$(basename $trimSid .fastq.gz | cut -d"_" -f-2)
                STAR \
                        --runThreadN 6 --genomeDir res/contaminants_idx \
                        --outReadsUnmapped Fastx --readFilesIn $trimSid \
                        --readFilesCommand gunzip -c --outFileNamePrefix $starDir/$basenameSid/
        	echo
	done
else
        echo -e "Alignament already performed, skipping alingment\n"
fi


# Saving common log

echo -e "\nSaving a common log with information on trimming and alignment results...\n"

echo -e "\nCommon log input as of $(date +'%x                %H:%M:%S')" >> pipeline.log
echo -e "___________________________________________________________\n">> pipeline.log

for basenameSid in $(find out/trimmed -name \* -type f -exec basename {} .fastq.gz \; | cut -d"_" -f-2)
do
        echo -e "$basenameSid STAR analysis\n" | sed $'s/^/\t /' >> pipeline.log
        grep -E 'Uniquely mapped reads %|% of reads mapped to too many loci|% of reads mapped to multiple loci' \
		out/star/$basenameSid/Log.final.out | \
		awk -v OFS=' ' '{$1=$1}1' | sed $'s/^/\t\t- /;s/ |/:/g' | column -t -s: -o$'\t\t' >> pipeline.log
	echo >> pipeline.log
	
	echo -e "$basenameSid cutadapt analysis\n" | sed $'s/^/\t/' >> pipeline.log
        grep -E 'Reads with adapters|Total basepairs' log/cutadapt/$basenameSid.log | \
		awk -v OFS=' ' '{$1=$1}1' | sed $'s/^/\t\t- /' | column -t -s: -o$'\t\t\t' >> pipeline.log
        echo -e "\n\n" >> pipeline.log
done

echo -e "\nCommon log saved in /pipeline.log\n" 

echo -e "\n############ Pipeline finished at $(date +'%H:%M:%S') ##############\n"
