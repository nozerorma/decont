##### DOWNLOAD SCRIPT ####

if [ "$#" -eq 3 ] || [ "$#" -eq 4 ] && [ "$3" == "yes" ] # Download and decompress required files	
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
	if [ "$4" == "filt" ] # Filter small nuclear sequences
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
