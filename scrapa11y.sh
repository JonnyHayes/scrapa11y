#!/bin/bash
# usage call it with script.sh example.com
mkdir wcag2aascripts
chmod 777 wcag2aascripts
mkdir wcagreport
chmod 777 wcagreport
touch urls.out
# scrapes the website to get the url list

DOMAIN_ID=$1
echo $DOMAIN_ID

export PYTHONPATH=/Library/Python/2.7/site-packages:$PYTHONPATH
echo "export PYTHONPATH=/Library/Python/2.7/site-packages:$PYTHONPATH" >> ~/.bashrc
export DOMAIN_ID=$DOMAIN_ID
scrapy runspider spidery.py -a domain=$DOMAIN_ID > urls.out
cat urls.out| grep $DOMAIN_ID |sort |uniq |grep -v '#' |grep -v 'mailto' > wcag2aascripts/urls.txt


# loops  over the list (urls.txt) to generate the pa11y commands,
countdooku=0
while read p; do

if [[ $p == */ ]]
then
countdooku=`expr $countdooku + 1`
echo $p
# a=$p
# countdooku=${a##*/}
eval x=${p////}
eval x=${x//$DOMAIN_ID/}
eval x=${x//http:/}
eval x=${x//https:/}
eval x=${x//www./}
printf '%b\n' "pa11y --reporter csv --ignore \"warning;notice\" $p > wcag2aascripts/'$countdooku'_$x.csv"  >> wcag2aascripts/ply.txt;
printf '%b\n' "pa11y --reporter html --ignore \"warning;notice\" $p > wcag2aascripts/'$countdooku'_$x.html"  >> wcag2aascripts/ply.txt;
fi
done <wcag2aascripts/urls.txt

#not sure this part works so well yet as the pa11y doesnt see to want to add the url to the report
# executes the pa11y commands
while read ply;
do
eval "$ply"
# sleep 3
done <wcag2aascripts/ply.txt

# reads each of the csv file and appends to a new file
OutFileName="wcagreport/report_$(date +%s).csv"                       # Fix the output name
i=0                                       # Reset a counter
for filename in ./wcag2aascripts/*.csv; do
 if [ "$filename"  != "$OutFileName" ] ;      # Avoid recursion
 then
   if [[ $i -eq 0 ]] ; then
      head -1  $filename >   $OutFileName # Copy header if it is the first file
   fi
   tail -n +2  $filename >>  $OutFileName # Append from the 2nd line each file
   i=$(( $i + 1 ))                        # Increase the counter
 fi
done

# rm wcag2aascripts/*
