echo ####### RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso #######
echo -e "\n\n\n############ Pipeline started at $(date +'%H:%M:%S') ##############\n\n\n"


# Run cleanup script at start
bash scripts/cleanup.sh 2>> log/errors.log

# Stop execution when having a non-zero status and trap errors giving line number
set -e
trap 'echo Error at about $LINENO' ERR

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

# Merge part samples in whole 
for sid in $(find data -name *.fastq -exec basename {} \; | cut -d"-" -f1 | sort -u)
do
        echo -e "Merging $sid sample files together...\n"
        # Merge the samples into a single file
        bash scripts/merge_fastqs.sh data out/merged $sid
done


# Cutadapt trimming step

echo -e "\nRemoving adapters..."

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
                        -o $trimDir/${basenameSid}_trimmed.fastq $sid > $trimLog/$basenameSid.log
        	echo
	done
else
        echo -e "Adapters already trimmed, skipping trimming\n" 
fi


# STAR alignment step

echo -e "\nAligning reads to contaminants. Outputing non-aligned reads...\n"
echo -e "\n### Default number of threads set to 6, please modify if neccessary ###\n" 

if [ ! "$(ls -A "out/star" 2>> log/errors.log)" ] 
then
        mkdir -p out/star/$basenameSid && starDir="out/star"
        for trimSid in $(find $trimDir -name \* -type f)
        do
                basenameSid=$(basename $trimSid .fastq | cut -d"_" -f-2)
                STAR \
                        --runThreadN 6 --genomeDir res/contaminants_idx \
                        --outReadsUnmapped Fastx --readFilesIn $trimSid \
                        --outFileNamePrefix $starDir/$basenameSid/
        	echo
	done
else
        echo -e "Alignament already performed, skipping alingment\n"
fi


# Saving common log

bash scripts/commonlog.sh

echo -e "\n\n\n############ Pipeline finished at $(date +'%H:%M:%S') ##############\n"
