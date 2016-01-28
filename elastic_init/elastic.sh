#!/usr/bin/env bash

CONFIG="/home/dmitry/Code/poly-lammps/elastic_init"
BASE="/home/dmitry/NAS/linear/128/globule/LAMMPS"

for i in {1..100}
do
    FOLD="$BASE/run-$i"
    echo "folder = $FOLD"
    if [ -d "$FOLD" ]; then
      cd $FOLD
      cp $CONFIG/* .
      ./run.sh -e
      ./run.sh -n 1 -t
      sleep 10
    fi
done
