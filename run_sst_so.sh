#!/bin/bash
#PBS -P y99
#PBS -q normal
#PBS -l walltime=01:00:00
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe

for x in output*; do
cd $x
#if [ ! -f sst_so.nc ]; then
../../../scripts/sst_so.py ocean_year.nc sst_so.nc 
#fi
cd ..
done

ncrcat -O output*/sst_so.nc sst_so_fw9.nc
mv sst_so_fw9.nc ../../transfer
