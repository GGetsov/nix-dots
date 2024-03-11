#!/usr/bin/env bash

openscad logo.scad -o 0.svg
for (( i=1;i<=16;i++))
do
  FOF1=$(echo "-22.3+${i}" | bc)
  THIC=$((17+i))
  CLIPR=$(echo 91-${i}*1.5 | bc)
  openscad logo.scad -o ${i}.svg -D foff=[${FOF1},-37] -D thick=${THIC} -D clipr=${CLIPR}
done

openscad logo.scad -o 17.svg -D foff=[-4.8,-37] -D thick=34 -D clipr=65.5
openscad logo.scad -o 18.svg -D foff=[-3.3,-37] -D thick=35 -D clipr=64
openscad logo.scad -o 19.svg -D foff=[-1.65,-37] -D thick=36 -D clipr=62
openscad logo.scad -o 20.svg -D foff=[0,-37] -D thick=37 -D clipr=60

for ((i=1;i<=12;i++))
do
  FILE=$((20+i))
  CLIPR=$(echo 60-${i}*2.5 | bc)
  LROT=$((i*5))
  openscad logo.scad -o ${FILE}.svg -D foff=[0,-37] -D thick=37 -D clipr=${CLIPR} -D lrot=${LROT}
done
