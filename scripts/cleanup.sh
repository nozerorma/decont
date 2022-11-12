#### CLEANUP SCRIPT ####

if [ $# -eq 1 ]
then
        debris=$1
        if [ $debris == "Y" ]
        then
                echo -e "\nCleaning everything up...\n"
                find data/* log/* out/* res/* ! \( -name 'urls' -o -name '.gitkeep' -o -name '*.log' \) -exec rm -f {} \; # Exclude gitkeeps, urls, scripts and logs 
	fi
else
        echo -e "Would you like to remove any remaining files from previous runs? Y/n\n"
        read debris
        if [ $debris == "Y" ]
        then
                echo -e "Which files would you like to remove? data log out res\n"
                read debris
                if [ $debris == "data" ] || [ $debris == "log" ] || [ $debris == "out" ] || [$debris == "res" ]
		then	
			echo -e "Cleaning up $debris\n"
			find $debris/* ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -f {} \; 2> log/cleanup_err.log # Cleanse selectively
        	else
			echo -e "No cleanup performed\n"
		fi
	fi
fi
