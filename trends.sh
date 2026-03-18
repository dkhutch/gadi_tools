#!/bin/bash
#PBS -P y99
#PBS -q normal
#PBS -l walltime=04:00:00
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe
#PBS -N trend_c3

for x in output*; do
cd $x
if [ ! -f Tcol.nc ]; then
ncwa -O -a xt_ocean,yt_ocean -w area_t -v temp,salt,age_global ocean_year.nc Tcol.nc
fi
if [ ! -f moc_idx.nc ]; then
~/scripts/moc_idx_a15.py moc.nc moc_idx.nc
fi
cd ..
done

ncrcat -O output*/Tcol.nc Tcol_a15_c3.nc
ncrcat -O output*/moc_idx.nc moc_idx_a15_c3.nc
mv Tcol_a15_c3.nc moc_idx_a15_c3.nc ../../transfer
