##### DOWNLOAD SCRIPT ####

if [ "$#" -eq 3 ] || [ "$#" -eq 4 ] && [ "$3" == "yes" ]	
then
	downloadurl=$1
	directoryurl=$2 # may be better to set this before if statement?
	sampleid=$(basename ${downloadurl})
        echo "Downloading $sampleid ..."
	echo
	wget -O ${directoryurl}/${sampleid} ${downloadurl} 
	echo
	echo "Extracting $sampleid ..."
	echo
	gunzip -vfk ${directoryurl}/${sampleid} 
	echo
	if [ "$4" == "filt" ]
	then
		echo "Removing small nuclear sequences from contaminants database..."
		echo
		sampleid=$(basename ${downloadurl} .gz)
		mv ${directoryurl}/${sampleid} ${directoryurl}/unfiltered_${sampleid}
		grep -vwE "small nuclear" ${directoryurl}/unfiltered_${sampleid} > ${directoryurl}/${sampleid}	
	else
		echo "Skipping contaminants database filtering..."	
		echo
	fi

else
	echo "Usage: $0 <directoryurl> <downloadurl> <compression> <filter>"
	exit 1
fi

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
