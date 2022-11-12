#### DOWNLOAD SCRIPT ####

if [ "$#" -eq 3 ] || [ "$#" -eq 4 ] && [ "$3" == "yes" ] # Download and decompress required files	
then
	downloadurl=$1
	directoryurl=$2
	sampleid=$(basename $downloadurl)
        echo "Downloading $sampleid ..."
	echo
	wget -nc -O $directoryurl/$sampleid $downloadurl 
	echo
	
	echo "Veryfing download integrity..." # md5sum verification
	cd $directoryurl
	curl ${downloadurl}.md5 | md5sum -c --ignore-missing > verifiedmd5.tmp
	echo
	if grep OK *.tmp 
	then
        	echo "Genome integrity verified"
        	echo
        	rm *.tmp
        	cd ..
	else
		echo "Download integrity could not be verified. Aborting..."
		echo
		cd ..
		bash scripts/cleanup.sh Y
		echo "############ Pipeline failed at $(date +'%H:%M:%S') ##############"
		echo
		exit 1
	fi
	
	echo "Extracting $sampleid ..."
	echo
	gunzip -fk $directoryurl/$sampleid 
	echo
	
	if [ "$4" == "filt" ] # Filter small nuclear sequences
	then
		echo "Removing small nuclear sequences from contaminants database..."
		echo
		sampleid=$(basename $downloadurl .gz)
		mv $directoryurl/$sampleid $directoryurl/unfiltered_$sampleid
		grep -vwE "small nuclear" $directoryurl/unfiltered_$sampleid > $directoryurl/$sampleid	
	fi

else
	echo "Usage: $0 <directoryurl> <downloadurl> <compression> <filter>"
	exit 1
fi
