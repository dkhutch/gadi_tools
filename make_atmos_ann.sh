#!/bin/bash
#PBS -P y99
#PBS -q normal
#PBS -l walltime=05:00:00
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe
#PBS -N make_ann

for x in output*; do
cd $x
if [ ! -f atmos_year.nc ]; then
mon2ann.py atmos_month.nc atmos_year.nc
fi
cd ..
done
