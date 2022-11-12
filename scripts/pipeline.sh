echo ####### RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso #######

# Run cleanup script at start
bash scripts/cleanup.sh 2> log/cleanup_err.log 

set -e
echo "Downloading required files..."
echo
mkdir -p data
# Download and extract required genomes
for url in $(grep 'https' data/urls | grep -v 'contaminants' | sort -u)
do
	bash scripts/download.sh $url data yes 2> log/download_err.log 
done

url=$(grep 'contaminants' data/urls)
# Download, extract and filter decontaminants database
bash scripts/download.sh $url res yes filt 2> log/download_err.log

if [ ! -f "res/contaminants_idx/*" ]
then
	echo "Building contaminants database index..."
	echo
	# Build contaminants index
	bash scripts/index.sh res/contaminants.fasta res/contaminants_idx 
else
	echo "Contaminants database index already exists, skipping"
	echo
	echo
fi

mkdir -p out && mkdir -p out/merged
for sid in $(find data -name *.fastq -exec basename {} \; | cut -d"-" -f1 | sort -u)
do
	echo "Merging $sid sample files together..."
	echo
	# Merge the samples into a single file
	bash scripts/merge_fastqs.sh data out/merged $sid  
done
echo "Removing adapters..."
echo
if [ ! -f "out/cutadapt/*" ]  # Not sure about this, may be better to run nonetheless, not same case as index
then	
	mkdir -p out && mkdir -p out/cutadapt && outdir="out/cutadapt"
	mkdir -p log && mkdir -p log/cutadapt && logdir="log/cutadapt"
	for sid in $(find out/merged/ -name \* -type f)
	do	
		basenamesid=$(basename $sid .fastq)
		echo "Removing adapters from ${sid}"	
		# Run cutadapt for all merged files
		cutadapt \
			-m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
			-o $outdir/${basenamesid}_trimmed.fastq.gz $sid > $logdir/$basenamesid.log 
	done
else
	echo "Adapters already trimmed, skipping trimming"	
fi

# run STAR for all trimmed files
#for fname in out/trimmed/*.fastq.gz
#do
    # you will need to obtain the sample ID from the filename
 #   sid=#TODO
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    #    --outReadsUnmapped Fastx --readFilesIn <input_file> \
    #    --readFilesCommand gunzip -c --outFileNamePrefix <output_directory>
# done 

echo
echo "############ Pipeline finished at $(date +'%H:%M:%S') ##############"

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
