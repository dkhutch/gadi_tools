#!/usr/bin/env bash
#PBS -P y99
#PBS -q express
#PBS -l walltime=00:20:00
#PBS -l ncpus=1
#PBS -l mem=2GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe

exp='fw4'
yrs='29'
ncrcat -v sst,sss,mld output${yrs}*/ocean_month.nc sst_all.nc
av_mon.py sst_all.nc sst_${exp}.nc
ncap2 -s 'month[$time]={31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.}' sst_${exp}.nc sst_ann_${exp}.nc
ncrcat -v t_ref output${yrs}*/atmos_month.nc sat_all.nc
av_mon.py sat_all.nc sat_${exp}.nc
ncap2 -s 'month[$time]={31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.}' sat_${exp}.nc sat_ann_${exp}.nc
ncrcat -v u_ref,v_ref output${yrs}*/atmos_month.nc uv_all.nc
av_mon.py uv_all.nc uv_${exp}.nc
ncap2 -s 'month[$time]={31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.}' uv_${exp}.nc uv_ann_${exp}.nc
ncrcat -v EXT,HI output${yrs}*/ice_month.nc ice_all.nc
av_mon.py ice_all.nc ice_${exp}.nc
ncap2 -s 'month[$time]={31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.}' ice_${exp}.nc ice_ann_${exp}.nc
ncrcat -v u_surf,v_surf output${yrs}*/ocean_month.nc uv_surf_all.nc
av_mon.py uv_surf_all.nc uv_surf_${exp}.nc
ncap2 -s 'month[$time]={31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.}' uv_surf_${exp}.nc uv_surf_ann_${exp}.nc
ncra -v temp,salt,age_global output${yrs}*/ocean_year.nc TSAge_${exp}.nc
ncra output${yrs}*/moc.nc moc_${exp}.nc
ncwa -O -a time TSAge_${exp}.nc TSAge_${exp}.nc
ncwa -O -a time moc_${exp}.nc moc_${exp}.nc 
ncwa -O -a time -w month sat_ann_${exp}.nc sat_ann_${exp}.nc
ncwa -O -a time -w month sst_ann_${exp}.nc sst_ann_${exp}.nc
ncwa -O -a time -w month uv_ann_${exp}.nc uv_ann_${exp}.nc
ncwa -O -a time -w month ice_ann_${exp}.nc ice_ann_${exp}.nc 
ncwa -O -a time -w month uv_surf_ann_${exp}.nc uv_surf_ann_${exp}.nc 
mv ice_ann_${exp}.nc ice_${exp}.nc moc_${exp}.nc sat_ann_${exp}.nc sat_${exp}.nc sst_ann_${exp}.nc sst_${exp}.nc TSAge_${exp}.nc uv_ann_${exp}.nc uv_${exp}.nc uv_surf_ann_${exp}.nc uv_surf_${exp}.nc ../../transfer/

rm *_all.nc
