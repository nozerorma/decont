#### CLEANUP SCRIPT ####

if [ $# -eq 1 ]
then
        debris=$1
        if [ $debris == "Y" ]
        then
                echo "Cleaning everything up..."
                find data/* log/* out/* res/* ! \( -name 'urls' -o -name '.gitkeep' -o -name '*.log' \) -exec rm -f {} \; # Exclude gitkeeps, urls, scripts and logs
        fi
else
        echo "Would you like to remove any remaining files from previous runs? Y/n"
        read debris
        echo
        if [ $debris == "Y" ]
        then
                echo "Which files would you like to remove? data log out res"
                read debris
                find $debris/* ! \( -name 'urls' -o -name '.gitkeep' \) -exec rm -f {} \; # Cleanse selectively
        fi
fi

