#### CLEANUP SCRIPT ####

echo "Would you like to remove any remaining files from previous runs? Y/n"
read removedebris
if [ $removedebris == "Y" ]
then
        find data/* res/* out/* log/* ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -rf {} \; # Cleanse old data excluding gitkeeps, urls and scripts
fi


