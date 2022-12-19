#### COMMON LOG SCRIPT ####

echo -e "\nSaving a common log with information on trimming and alignment results...\n"

echo -e "\nCommon log input as of $(date +'%x                %H:%M:%S')" >> pipeline.log
echo -e "___________________________________________________________\n">> pipeline.log

for basenameSid in $(find out/trimmed -name \* -type f -exec basename {} .fastq.gz \; | cut -d"_" -f-2)
do
        # parameter -o not present in bsdmain column ver
        if [[ $(dpkg -S $(which column) | grep bsdmain) == *[bsdmainutils]* ]]
        then
                echo -e "$basenameSid STAR analysis\n" | sed $'s/^/\t /' >> pipeline.log
                grep -E 'reads %|% of reads mapped to (too|multiple)' \
                        out/star/$basenameSid/Log.final.out | \
                        awk -v OFS=' ' '{$1=$1}1' | sed $'s/^/\t\t- /;s/ |/:/g' | column -t -s:  >> pipeline.log
                echo >> pipeline.log
                echo -e "$basenameSid cutadapt analysis\n" | sed $'s/^/\t/' >> pipeline.log
                grep -E 'Reads with adapters|Total basepairs' log/cutadapt/$basenameSid.log | \
                awk -v OFS=' ' '{$1=$1}1' | sed $'s/^/\t\t- /' | column -t -s:  >> pipeline.log
                echo -e "\n\n" >> pipeline.log
        else
                echo -e "$basenameSid STAR analysis\n" | sed $'s/^/\t /' >> pipeline.log
                grep -E 'reads %|% of reads mapped to (too|multiple)' \
                        out/star/$basenameSid/Log.final.out | \
                        awk -v OFS=' ' '{$1=$1}1' | sed $'s/^/\t\t- /;s/ |/:/g' | column -t -s: -o$'\t\t' >> pipeline.log
                echo >> pipeline.log
                echo -e "$basenameSid cutadapt analysis\n" | sed $'s/^/\t/' >> pipeline.log
                grep -E 'Reads with adapters|Total basepairs' log/cutadapt/$basenameSid.log | \
                awk -v OFS=' ' '{$1=$1}1' | sed $'s/^/\t\t- /' | column -t -s: -o$'\t\t\t' >> pipeline.log
                echo -e "\n\n" >> pipeline.log
        fi
done

echo -e "Common log saved in /pipeline.log\n" 

