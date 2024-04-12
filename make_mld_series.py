import numpy as np 
import xarray as xr 
import netCDF4 as nc
import matplotlib.pyplot as plt

t0 = 0
t1 = 0

basedir = '/scratch/y99/dkh157/mom/archive/a15_c3/'

for i in range(t0, t1+1):
    fname = basedir + 'output%03d/' % i + 'ocean_month.nc'
    f = nc.Dataset(fname)
    mld = f.variables['mld'][:]
    sst = f.variables['sst'][:]
    time = f.variables['time'][:]
    mld_feb = mld[1::12,:,:]
    sst_feb = sst[1::12,:,:]
    time_feb = time[1::12]

    
    