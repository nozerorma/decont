echo ####### RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso #######

# Run cleanup script at start
bash scripts/cleanup.sh 2> log/cleanup_err.log

set -e
echo -e "Downloading required files...\n"
mkdir -p data
# Download and extract required genomes
for url in $(grep 'https' data/urls | grep -v 'contaminants' | sort -u)
do
        bash scripts/download.sh $url data yes 2> log/download_err.log
done

url=$(grep 'contaminants' data/urls)
# Download, extract and filter decontaminants database
bash scripts/download.sh $url res yes filt 2> log/download_err.log

echo -e "Building contaminants database index...\n"
if [ ! "$(ls -A "res/contaminants_idx")" ]
then
        # Build contaminants index
        bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
else
        echo -e "\nContaminants database index already exists, skipping\n\n"
fi

mkdir -p out && mkdir -p out/merged
for sid in $(find data -name *.fastq -exec basename {} \; | cut -d"-" -f1 | sort -u)
do
        echo -e "Merging $sid sample files together...\n"
        # Merge the samples into a single file
        bash scripts/merge_fastqs.sh data out/merged $sid
done

if [ ! "$(ls -A "out/trimmed")" ]
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
        echo -e "\nAdapters already trimmed, skipping trimming\n" 
fi

# run STAR for all trimmed files
echo -e "\n\nAligning reads to contaminants. Outputing non-aligned reads...\n"
if [ ! "$(ls -A "out/star")" ]
then
        mkdir -p out/star/$basenameSid && starDir="out/star"
        for trimSid in $(find $trimDir -name \* -type f)
        do
                basenameSid=$(basename $trimSid .fastq.gz | cut -d"_" -f-2)
                STAR \
                        --runThreadN 4 --genomeDir res/contaminants_idx \
                        --outReadsUnmapped Fastx --readFilesIn $trimSid \
                        --readFilesCommand gunzip -c --outFileNamePrefix $starDir/$basenameSid/
        	echo
	done
else
        echo -e "\nAlignament already performed, skipping alingment\n"
fi

echo -e "\nSaving a common log with information on trimming and alignment results...\n"

# I don't like this approach, search alt
echo -e "\nGlobal log input as of $(date +'%x                %H:%M:%S')\n" >> pipeline.log
echo >> pipeline.log
for basenameSid in $(find out/trimmed -name \* -type f -exec basename {} .fastq.gz \; | cut -d"_" -f-2)
do
        echo -e "$basenameSid STAR analysis\n" >> pipeline.log
        grep 'Uniquely mapped reads %' out/star/$basenameSid/Log.final.out | \
		awk -v OFS=' ' '{$1=$1}1' >> pipeline.log
        grep '% of reads mapped to too many loci' out/star/$basenameSid/Log.final.out | \
		awk -v OFS=' ' '{$1=$1}1' >> pipeline.log
        grep '% of reads mapped to multiple loci' out/star/$basenameSid/Log.final.out | \
		awk -v OFS=' ' '{$1=$1}1' >> pipeline.log
	echo >> pipeline.log
	echo -e "$basenameSid cutadapt analysis\n" >> pipeline.log
        grep 'Reads with adapters' log/cutadapt/$basenameSid.log | \
		awk -v OFS=' ' '{$1=$1}1' >> pipeline.log
        grep 'Total basepairs' log/cutadapt/$basenameSid.log | \
		awk -v OFS=' ' '{$1=$1}1' >> pipeline.log
        echo >> pipeline.log
done


echo -e "\n############ Pipeline finished at $(date +'%H:%M:%S') ##############\n"
