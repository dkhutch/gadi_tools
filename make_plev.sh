#!/usr/bin/env bash
#PBS -P y99
#PBS -q express
#PBS -l walltime=00:20:00
#PBS -l ncpus=1
#PBS -l mem=2GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe

exp='sl4'
yrs='29'
for x in output${yrs}* ; do
    cd $x
    plevel.sh -3 -i atmos_month.nc -o atmos_plevel.nc hght slp
    cd ..
done
ncrcat -v temp,hght output29*/atmos_plevel.nc temp_hght.nc
av_mon.py temp_hght.nc temp_hght_${exp}.nc
mv temp_hght_${exp}.nc ../../transfer
