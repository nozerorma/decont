echo ####### RNA DECONTAMINATION PIPELINE by Miguel Ramón Alonso #######

# Download all the files specified in data/filenames
# Allow uncompression

echo "Downloading required files..."
echo
mkdir -p data
find data ! -name 'urls' -type f -exec rm -f {} res/* \; # cleanse data and res directories excluding urls file 

for url in $(grep https data/urls | sort -u) # set 
do
	bash scripts/download.sh $url data yes
done

# Download the contaminants fasta file, uncompress it, and filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes filt #dont really like that much, check for alts


# Index the contaminants file
echo "Building contaminants index..."
echo
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# Merge the samples into a single file
#for sid in $(<list_of_sample_ids>) #TODO
#do
 #   bash scripts/merge_fastqs.sh data out/merged $sid
#done

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
