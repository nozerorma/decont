echo ####### RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso #######

echo "Would you like to remove any remaining files from previous runs? Y/n"
read removedebris
if [ $removedebris == "Y" ]
then
	find data/* res/* out/* log/* ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -rf {} \; # cleanse old data excluding gitkeeps and urls
fi

echo "Downloading required files..."
echo
mkdir -p data
for url in $(grep 'https' data/urls | grep -v 'contaminants' | sort -u) # Download and extract required genomes
do
	bash scripts/download.sh $url data yes
done
url=$(grep 'contaminants' data/urls)
bash scripts/download.sh $url res yes filt # Download, extract and filter decontaminants database

if [ ! -d res/contaminants_idx ]
then
	echo "Contaminants database index has not been built"
	echo
	echo "Building contaminants database index..."
	echo
	bash scripts/index.sh res/contaminants.fasta res/contaminants_idx # Build contaminants index
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
	bash scripts/merge_fastqs.sh data out/merged $sid # Merge the samples into a single file
done

# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
#     -o <trimmed_file> <input_file> > <log_file>

# TODO: run STAR for all trimmed files
#for fname in out/trimmed/*.fastq.gz
#do
    # you will need to obtain the sample ID from the filename
 #   sid=#TODO
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    #    --outReadsUnmapped Fastx --readFilesIn <input_file> \
    #    --readFilesCommand gunzip -c --outFileNamePrefix <output_directory>
# done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
