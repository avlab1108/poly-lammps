#!/bin/bash

IN_FILE="in.txt.template"
CHAIN_FILE="chain.dat"

for i in {0..25}
do
  for j in {1..4}
  do
    FOLD="run-$(($i*4 + $j))"
    echo "folder = $FOLD"
    if [ ! -d "$FOLD" ]; then
      mkdir $FOLD
      sed "s/\<randomSeed\>/$RANDOM/g" $IN_FILE > in.txt
      cp in.txt $FOLD 
      cp $CHAIN_FILE $FOLD 
      cd $FOLD
      lmp_mpi < in.txt > execute.log 2>&1 &   
      cd ..
    fi
  done
  wait
done
