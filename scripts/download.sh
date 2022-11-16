#### DOWNLOAD SCRIPT ####

if [ "$#" -eq 3 ] || [ "$#" -eq 4 ] && [ "$3" == "yes" ] # Download and decompress required files	
then
	downloadurl=$1
	directoryurl=$2
	sampleid=$(basename $downloadurl)
        echo -e "Downloading $sampleid ...\n"
	wget -nc -O $directoryurl/$sampleid $downloadurl 
	
	echo -e "Veryfing download integrity...\n" # md5sum verification
	cd $directoryurl
	curl ${downloadurl}.md5 | md5sum -c --ignore-missing > verifiedmd5.tmp
	if grep OK *.tmp 
	then
        	echo -e "Download integrity verified\n"
        	rm *.tmp
        	cd ..
	else
		echo -e "Download integrity could not be verified. Aborting...\n"
		cd ..
		# Rollback function commented out as it may not be recommendable. See cleanup.sh.
		# bash scripts/cleanup.sh Y
		echo -e "\n############ Pipeline failed at $(date +'%H:%M:%S') ##############\n"
		exit 1
	fi
	
	echo -e "Extracting $sampleid ...\n"
	gunzip -fk $directoryurl/$sampleid 
	
	if [ "$4" == "filt" ] # Filter small nuclear sequences
	then
		echo -e "\nRemoving small nuclear sequences from contaminants database...\n"
		sampleid=$(basename $downloadurl .gz)
		mv $directoryurl/$sampleid $directoryurl/unfiltered_$sampleid
		grep -vwE "small nuclear" $directoryurl/unfiltered_$sampleid > $directoryurl/$sampleid	
	fi

else
	echo -e "\nUsage: $0 <directoryurl> <downloadurl> <compression> <filter>\n"
	exit 1
fi
