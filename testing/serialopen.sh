#!/bin/bash

echo > testing.log

i=0
while [ $i -le 100 ]
do
   echo "----------------------" $i >> testing.log
   time matlab -batch "F=inst.CelestronFocuser('11_1_1'); F.connect" >> testing.log
   ((i++))
done
