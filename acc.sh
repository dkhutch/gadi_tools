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
if [ ! -f acc.nc ]; then
ncks -d xu_ocean,217,217 -d yt_ocean,18,18 -v psiu ocean_year.nc psi0.nc
ncks -d xu_ocean,211,211 -d yt_ocean,26,26 -v psiu ocean_year.nc psi1.nc
ncdiff -v psiu psi0.nc psi1.nc acc.nc
rm psi0.nc psi1.nc
fi
cd ..
done

ncrcat -O output*/acc.nc acc_fw9.nc
mv acc_fw9.nc ../../transfer
