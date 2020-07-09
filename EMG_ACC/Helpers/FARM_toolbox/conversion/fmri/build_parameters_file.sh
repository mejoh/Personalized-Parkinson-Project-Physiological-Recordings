#!/bin/bash
# maak een 'parameters' file...
echo making parameters file...
touch parameters

parFile=$1

# de tr
tr=`head -n 50 $parFile |grep "Repetition time"|awk '{print $6/1000}'`

# het aantal slices... uit de parfile!
nslices=`head -n 50 $parFile |grep "slices"|awk '{print $7}'`

# elaborate truuks om achter het # volumes te komen.
# nslices + 2 aan einde van deregels... (1 lege regel +
# === END OF DATA DESCRIPTION FILE ===============================================
#
# en pak daar de 1e regel van. Onhafhankelijk van het # extra slices daarbovenop geeft dit het totaal aantal COMPLETE volumes.

next2last=`tail -n 4 $parFile|head -n 1|awk '{print $1}'`
last=`tail -n 3 $parFile|head -n 1|awk '{print $1}'`
 
# IF last two numbers in column # 1 are the same:
if [ $next2last -eq $last ]; then
 nvols=`tail -n 3 $parFile|head -n 1|awk '{print $3}'`
fi

if [ $next2last -ne $last ];then

 # IF last two numbers in column # 3 are different:
 tmp=`echo $nslices|awk '{print $1+2}'`
 tmp2=`echo "tail -n "$tmp" "$parFile"|head -n 1"|sh`
 nvols=`echo $tmp2|awk '{print $3}'`
fi



# de voxel dimension.. hierbij maakt het niet uit of het uit een extragenous onzin-regel komt.
dimx=`tail -n 5 $parFile|head -n 1|awk '{print $29}'`
dimy=`tail -n 5 $parFile|head -n 1|awk '{print $30}'`
dimz=`tail -n 5 $parFile|head -n 1|awk '{print $23}'`

# make the parameters file...
rm -f parameters
touch parameters
echo $tr >> parameters
echo $nslices >> parameters
echo $nvols >> parameters
echo $dimx >> parameters
echo $dimy >> parameters
echo $dimz >> parameters
cat parameters
