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

mv $hdrFile t1.hdr
mv $imgFile t1.img


# create the directory
echo mkdir -p $baseDir"pp/"$ppNummer"/t1"
mkdir -p $baseDir"pp/"$ppNummer"/t1"


# and move all of the stuff there.
mv t1.hdr $baseDir"pp/"$ppNummer"/t1/t1.hdr"
mv t1.img $baseDir"pp/"$ppNummer"/t1/t1.img"
