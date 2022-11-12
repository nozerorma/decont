#### CLEANUP SCRIPT ####

if [ $# -eq 1 ]
then
        debris=$1
        if [[ "${debris}" = *[Yy]* ]]
        then
                echo -e "\nCleaning everything up...\n"
                find data/* log/* out/* res/* -mindepth 1! \( -name 'urls' -o -name '.gitkeep' -o -name '*.log' \) -exec rm -rf {} \; 
		# Exclude gitkeeps, urls, scripts and logs 
	fi
else
        echo -e "Would you like to remove any remaining files from previous runs? Y/n\n"
        read debris
        echo
	if [[ ${debris} = *[Yy]* ]]
        then
                echo -e "Which files would you like to remove? data log out res\n"
                read cleandebris
                expectedinput="data log out res"
		echo
		if [[ "$expectedinput" == *"$cleandebris"* ]]
		then
			echo -e "Cleaning up $cleandebris\n"
                        find $cleandebris -mindepth 1 ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -rf {} \; 2> log/cleanup_err.log 
                        # Cleanse selectively
        	else
			echo -e "No cleanup performed\n"
		fi
	else
		echo -e "No cleanup performed\n"
	fi
fi
