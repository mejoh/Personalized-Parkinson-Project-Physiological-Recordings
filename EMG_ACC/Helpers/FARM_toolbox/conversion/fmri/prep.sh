#!/bin/bash

echo this is study: $1
echo preparing subject: $2
study=$1
subject=$2



# knfMount=`pwd|sed 's/\(^.*\)Onderzoek.*/\1/'`

knfMount=`pwd|sed 's/\(^.*\)[ITO][Cen][Tmd].*/\1/'`
echo $knfMount

baseDir=$knfMount"Onderzoek/fMRI/"$study"/"
echo $baseDir


tmp=$knfMount"ICT/Software/mltoolboxes/emgfmri/conversion/fmri/"
scriptDir=`echo $tmp|sed 's/\\//\\\\\//g'`
echo $scriptDir

cat $baseDir"ruw/"$2"/files.txt"

# anders gaat sed zeuren... allemaal /'s, terwijl / ook de s/a/b/ truuk nog werkt.
cat $baseDir"ruw/"$subject"/files.txt"|sed s/.$/\ \ $study\ \ $scriptDir/ |grep ^REC|awk '{print $8 "do_rec2analyze.sh " $2 " " $3 " " $4 " " $7 " " $8}'|sh


cat $baseDir"ruw/"$subject"/files.txt"|sed s/.$/\ \ $study\ \ $scriptDir/ |grep ^t1|awk '{print $8 "do_t1.sh " $2 " " $3 " " $4 " " $7 " " $8}'|sh


