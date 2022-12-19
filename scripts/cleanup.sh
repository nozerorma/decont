#### CLEANUP SCRIPT ####

echo -e "\nRunning cleanup script...\n"
echo -e "\n	###### Please, make sure you are runnning this script either from the main pipeline script or from the WD ($ bash scripts/cleanup.sh). ######\n
		        ###### DO NOT RUN IT FROM ANY OTHER PLACE, ELSE NO RESPONSABILITY WILL BE TAKEN FOR ANY DAMAGE IT MAY CAUSE ######\n"

# Rollback funciton commented out as it may no be recommended in some cases
# if [ $# -eq 1 ] 
# then
	# Works mainly as rollback script when certain situations do not comply
	# debris=$1
	# if [[ "${debris}" = *[Yy]* ]]
	# then
		# echo -e "\nCleaning everything up...\n"
		# find data log out res -mindepth 1 ! \( -name 'urls' -o -name '.gitkeep' -o -name '*.log' \) -exec rm -rf {} \; 
		# Exclude gitkeeps, urls, scripts and logs 
	# fi

# Works both as standalone cleanup script and interactive startup cleanup script

# else
        echo -e "Would you like to remove any remaining files from previous runs? <Y>/<n>\n"
        read debris
        echo
	
	if [[ ${debris} = *[Yy]* ]]
        then
                # Cleanup selectively
	
		echo -e "Which files would you like to remove? <data> <log> <out> <res>\n \
			Note that desired directories must be input manually and separated by spaces.\n \
			ie. data out res \n \
			Git integrity, urls and directory structure will be preserved.\n"
				
                read cleandebris
                expectedinput="data log out res"
		echo
		
		if [[ "$expectedinput" == *"$cleandebris"* ]]
		then
			echo -e "Cleaning up $cleandebris\n"
                        find $cleandebris -mindepth 1 ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -rf {} \; 2> log/cleanup_err.log 
               	else
			echo -e "No cleanup performed\n"
		fi
	else
		echo -e "No cleanup performed\n\n"
	fi
# fi
