##### DOWNLOAD SCRIPT ####

if ["$#" -eq 2]; then
	downloadurl=$1
	directoryurl=$2 # may be better to set this before if statement?
	echo "Downloading genomes..."
	mkdir -p data
	# find . ! -name 'file.txt' -type f -exec rm -f {} + # removed until further rework
	wget -P ${directoryurl} ${downloadurl}
	echo
	if ["$#" -eq 3]; then
		echo "Decompressing downloaded genomes..."
		gunzip -kr ${directoryurl}
	else 
		echo "Skipping genome decompression."
	fi

# Case 3 args:
# downloadurl=$1, directoryurl=$2, decompressurl=$3, filter=$4
	
else
	echo "Usage: $0 <sampleid>"
	exit 1
fi


# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
