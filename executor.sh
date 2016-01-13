#!/bin/bash

IN_FILE="in.txt"
CHAIN_FILE="chain.dat"

for i in {0..25}
do
  for j in {1..4}
  do
    FOLD="run-$(($i*4 + $j))"
    echo "folder = $FOLD"
    mkdir $FOLD
    cp $IN_FILE $FOLD 
    cp $CHAIN_FILE $FOLD 
    cd $FOLD
    lmp_mpi < in.txt > execute.log 2>$1 &   
    cd ..
  done
  wait
done
