#!/bin/bash

script=`readlink -e $0`
#scriptpath=`dirname $script`
scriptpath="/home/dmitry/Code/elastic_network/scripts"

num_proc=1
trajectory=0
eigens=0
points=0
user_config=$scriptpath/config.yaml
global_config=$scriptpath/global_config.yaml

function usage()
{
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  -n [num]  Number of processes.
  -t        Perform trajectory task.
  -e        Calculate eigenvalues and plot spectra.
  -p        Calculate 3 optimal points.

  -u        User config path.
  -g        Global config path.

EOF
}

while getopts "n:u:g:tep" opt
do
  case "$opt" in
    n) num_proc=$OPTARG;;
    u) user_config=$OPTARG;;
    g) global_config=$OPTARG;;
    t) trajectory=1;;
    e) eigens=1;;
    p) points=1;;
    \:) usage; exit;;
    \?) usage; exit;;
  esac
done

ls_command="find . -maxdepth 1 -type d"

#TODO: need to extract from mkfiles/default_defs.mk
export LD_LIBRARY_PATH=/usr/local/lib:$scriptpath/../core/last/obj:$LD_LIBRARY_PATH

if (( $eigens == 1 )); then
  dirs_before=`eval $ls_command`
  $scriptpath/../applications/eigen_spectra/obj/eigens.exe -u $user_config -g $global_config
  dirs_after=`eval $ls_command`
  results_dir=`diff <(echo "$dirs_before") <(echo "$dirs_after") | grep "^>" | sed -e "s/^>\s*//" | grep "results_*"`
  $scriptpath/plot_spectra.sh -i $results_dir/eigens.txt -o $results_dir/eigen_spectra.png
  exit
fi

if (( $points == 1 )); then
  $scriptpath/../applications/optimal_nodes/obj/optimal_nodes.exe -u $user_config -g $global_config
  exit
fi

function row_to_label()
{
  case $1 in
    "1") return 12;;
    "2") return 13;;
    "3") return 23;;
    *) return 0;;
  esac
}

function setup_plotter_impl()
{
  output_file=$1
  row_to_label $2
  x_label=$?
  row_to_label $3
  y_label=$?
  > plotter.gnu
  echo "set terminal png enhanced size 1280, 1024" >> plotter.gnu
  echo "set output \"$output_file\"" >> plotter.gnu
  echo "set style data lines" >> plotter.gnu
  echo "set style line 5 lt rgb \"blue\" lw 1 pt 6" >> plotter.gnu
  echo "set grid x" >> plotter.gnu
  echo "set grid y" >> plotter.gnu
  echo "set xlabel \"{/Symbol D}u_{$x_label}/u_{$x_label}^{(0)}\"" >> plotter.gnu
  echo "set ylabel \"{/Symbol D}u_{$y_label}/u_{$y_label}^{(0)}\"" >> plotter.gnu
  echo "set label at 0,0,0 \"\" point pointtype 7 pointsize 1 lc rgb \"red\" front" >> plotter.gnu
}

function setup_2d_plotter()
{
  trajectories=$1
  setup_plotter_impl $2 $3 $4
  echo "plot for [file in \"$trajectories\"] file using $3:$4 with lines notitle ls 5" >> plotter.gnu
  gnuplot plotter.gnu
}

function setup_3d_plotter()
{
  trajectories=$1
  setup_plotter_impl $2 1 2
  row_to_label 3
  z_label=$?
  echo "set grid z" >> plotter.gnu
  echo "set zlabel \"{/Symbol D}u_{$z_label}/u_{$z_label}^{(0)}\"" >> plotter.gnu
  echo "splot for [file in \"$trajectories\"] file using 1:2:3 with lines notitle ls 5" >> plotter.gnu
  gnuplot plotter.gnu
}

if (( $trajectory == 1 )); then

  dirs_before=`eval $ls_command`

  comm="$scriptpath/../applications/trajectory/obj/trajectory.exe -u $user_config -g $global_config"

  result=0

  if (( $num_proc > 1 )); then
    mpirun -np $num_proc $comm
    result=$?
  else
    eval $comm
    result=$?
  fi

  if (( $result == 0 )); then
    dirs_after=`eval $ls_command`
    results_dir=`diff <(echo "$dirs_before") <(echo "$dirs_after") | grep "^>" | sed -e "s/^>\s*//" | grep "results_*"`
    trajectory_files=`find $results_dir -name "trajectory.txt" | tr '\n' ' '`

    if [ -z "$trajectory_files" ]; then
      echo "No trajectory files found."
      exit
    fi

    touch plotter.gnu
    setup_3d_plotter "$trajectory_files" "$results_dir/trajectory.png"
    setup_2d_plotter "$trajectory_files" "$results_dir/u12_u13.png" 1 2
    setup_2d_plotter "$trajectory_files" "$results_dir/u12_u23.png" 1 3
    setup_2d_plotter "$trajectory_files" "$results_dir/u13_u23.png" 2 3
    rm -f plotter.gnu
  fi
fi
