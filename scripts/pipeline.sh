# Header design credits to @AnandamidaCBD
echo
echo
echo -e "					#####################################################################################"
echo -e "					#####################################################################################"
echo -e "					################ RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso ################"
echo -e "					#####################################################################################"
echo -e "					#####################################################################################"
echo -e "					########################### Pipeline started at $(date +'%H:%M:%S') ############################"
echo -e "					#####################################################################################"
echo -e "					#####################################################################################"
echo
echo

# Run cleanup script at start
bash scripts/cleanup.sh

# Stop execution when having a non-zero status and trap errors giving line number
set -e
trap 'echo Error at about $LINENO' ERR # credits to @NoeRzPz

# Download and extract required genomes

echo -e "Downloading required files...\n"
mkdir -p data

for url in $(grep '^data' data/urls | cut -d$'\t' -f2 | sort -u)
do
        bash scripts/download.sh $url data yes 2>> log/download_errors.log
done

# Download, extract and filter decontaminants database

url=$(grep '^contaminants' data/urls | cut -d$'\t' -f2)
bash scripts/download.sh $url res yes filt 2>> log/download_errors.log

# STAR Index building

echo -e "\nBuilding contaminants database index with STAR...\n"

if [ -d res/contaminants_idx ] # verify if file already exists, credits to @Josemamd13
then
        echo -e "Contaminants database index already exists, skipping index building.\n\n"
else
	# Build contaminants index
        bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
fi

# Merge part samples in whole 

mkdir -p out && mkdir -p out/merged

for sid in $(find data -name *.fastq -exec basename {} \; | cut -d"-" -f1 | sort -u)
do
        echo -e "Merging $sid sample files together..."
        # Merge the samples into a single file
        bash scripts/merge_fastqs.sh data out/merged $sid
done

# Cutadapt trimming step

echo -e "\nRunning cutadapt...\n"

mkdir -p out/trimmed && trimDir="out/trimmed"
mkdir -p log/cutadapt && trimLog="log/cutadapt"

for mergedSid in $(find out/merged/ -name \* -type f)
do
	baseMergedSid=$(basename $mergedSid .fastq)
        echo -e "Removing adapters from sample ${baseMergedSid}..."
        
	if [ -f $trimDir/${baseMergedSid}_trimmed.fastq ]
	then
		echo -e "Sample $baseMergedSid has already been trimmed, skipping trimming.\n"  
		
	else
		# Run cutadapt for all merged files
        	cutadapt \
        		-m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
                	-o $trimDir/${baseMergedSid}_trimmed.fastq $mergedSid > $trimLog/$baseMergedSid.log
        	echo -e "Sample $baseMergedSid trimmed.\n"
	fi
done


# STAR alignment step

echo -e "\nAligning reads to contaminants with STAR. Outputing non-aligned reads...\n"
starDir="out/star"

for trimSid in $(find $trimDir -name \* -type f)
do
	baseAlignSid=$(basename $trimSid.fastq | cut -d"_" -f-2)
	bash scripts/align.sh $trimSid $baseAlignSid $starDir
done

# Saving common log

bash scripts/commonlog.sh

echo -e "\n\n############ Pipeline finished at $(date +'%H:%M:%S') ##############\n"
