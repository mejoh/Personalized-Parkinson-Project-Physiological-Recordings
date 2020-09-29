#!/bin/bash

# $1 is het proefpersoon nummer
# $2 is de taak
# $3 is de recfile
# $4 is de study
# $5 is de scriptDir


ppNummer=$1
taak=$2
recFile=$3
study=$4
scriptDir=$5
#video=$6

# knfMount=`echo $scriptDir|sed 's/\(^.*\)ICT.*/\1/'`
# baseDir=$knfMount"Onderzoek/fMRI/"$study"/"
knfMount=`pwd|sed 's/\(^.*\)Onderzoek.*/\1/'`
baseDir=$knfMount"Onderzoek/fMRI/"$study"/"

hdrFile=${recFile/.REC/".hdr"}
imgFile=${recFile/.REC/".img"}
parFile=${recFile/.REC/".PAR"}


echo cd $baseDir"ruw/"$ppNummer"/parrec/"
cd $baseDir"ruw/"$ppNummer"/parrec/"
pwd


# change parrec to imghdr...
echo ${scriptDir}rec2analyze.pl -s -fsl $recFile
${scriptDir}rec2analyze.pl -s -fsl $recFile

# ... and make the parameters file.
echo ${scriptDir}build_parameters_file.sh $parFile
${scriptDir}build_parameters_file.sh $parFile


# create the directories
# als er geen directory bestaat: session1
# als er session1 al is: session2
# als session2 ook al bestaat: session3

echo mkdir -p $baseDir"pp/"$ppNummer"/"$taak"/fmri"
mkdir -p $baseDir"pp/"$ppNummer"/"$taak"/fmri"


# and move all of the stuff there.
mv $hdrFile $baseDir"pp/"$ppNummer"/"$taak"/fmri/4D.hdr"
mv $imgFile $baseDir"pp/"$ppNummer"/"$taak"/fmri/4D.img"
mv parameters $baseDir"pp/"$ppNummer"/"$taak"/."




