#### CLEANUP SCRIPT ####

if [ $# -eq 1 ]
then
	removedebris=$1
else
	echo "Would you like to remove any remaining files from previous runs? Y/n"
	read removedebris
fi

if [ $removedebris == "Y" ]
then
        find data/* res/* out/* log/* ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -rf {} \; # Cleanse old data excluding gitkeeps, urls and scripts
fi


