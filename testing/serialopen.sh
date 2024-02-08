#!/bin/bash

echo > testing.log

i=0
while [ $i -le 1000 ]
do
   echo `date` "----------------------" $i | tee -a testing.log
#   time matlab -nosplash -r "datetime, F=inst.CelestronFocuser('11_1_1'); F.connect; F.Status, exit" | tee -a testing.log
   time matlab -nosplash -r "Unit=obs.unitCS('00'); Unit.connect; exit" | tee -a testing.log
   echo $i "exit status: " $? | tee -a testing.log
   ((i++))
done
