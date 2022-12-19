#### CLEANUP SCRIPT ####

echo -e "\nRunning cleanup script...\n"
echo -e "\n	###### Please, make sure you are runnning this script either from the main pipeline script or from the WD ($ bash scripts/cleanup.sh). ######\n
		        ###### DO NOT RUN IT FROM ANY OTHER PLACE, ELSE NO RESPONSABILITY WILL BE TAKEN FOR ANY DAMAGE IT MAY CAUSE ######\n\n"

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
while true 
do
	read -r -p "Would you like to remove any remaining files from previous runs? (Y/N): " doCleanup
	case $doCleanup in
		[Yy]* )
    			# Cleanup selectively
	
			echo -e "\n\nWhich directories would you like to clean? Note that desired directories must be input manually and separated by spaces.\n"
			echo -e "ie. data out res\n"
			echo -e "(Git integrity, urls and directory structure will be preserved.)\n"
			
			read -r -p  "Directories to be cleaned (data log out res): " cleandebris
        		expectedinput="data log out res"
			echo
		
			if [[ "$expectedinput" == *"$cleandebris"* ]]
			then
				echo -e "Cleaning up $cleandebris\n"
                		find $cleandebris -mindepth 1 ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -rf {} \; 2> log/cleanup_err.log 
        			echo -e "Done\n"
			else
				echo -e "No cleanup performed.\n\n"
			fi ;
		break ;;
	
		[Nn]* )
			echo -e "No cleanup performed.\n\n" ;
		break ;;
			
		* )
			echo -e "Please, answer Y or N.\n" ;
		;;
	esac
done
# fi
