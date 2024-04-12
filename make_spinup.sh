#!/bin/bash
#PBS -P y99
#PBS -q normal
#PBS -l walltime=04:00:00
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe
#PBS -N fw9_2

for x in output2*; do
echo $x
cd $x
if [ ! -f ocean_spinup.nc ]; then
ncks -x -v dzt,rho_dzt,dzu,dst,u,v,rho,wt,tx_trans,tx_trans_gm,tx_trans_rho,tx_trans_rho_gm ocean_year.nc ocean_spinup.nc
fi
if [ ! -f atmos_year.nc ]; then
../../../scripts/mon2ann.py atmos_month.nc atmos_year.nc
fi
if [ ! -f ice_year.nc ]; then
../../../scripts/mon2ann.py ice_month.nc ice_year.nc
fi
if [ ! -f land_year.nc ]; then
../../../scripts/mon2ann.py land_month.nc land_year.nc
fi
if [ -f mom.out ]; then
gzip mom.out mom.err
fi
cd ..
done
