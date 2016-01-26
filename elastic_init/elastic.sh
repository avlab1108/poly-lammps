#!/usr/bin/env bash

CONFIG="/home/dmitry/Code/poly-lammps/elastic_init"
BASE="/run/user/1000/gvfs/smb-share:server=nanomachines,share=modeling/linear/128/globule/LAMMPS"

for i in {0..100}
do
    FOLD="$BASE/run-$i"
    echo "folder = $FOLD"
    if [ -d "$FOLD" ]; then
      cd $FOLD
      cp $CONFIG/* .
      ./run.sh -n 1 -t
    fi
done
