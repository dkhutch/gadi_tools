#!/usr/bin/env python
import numpy as np
import netCDF4 as nc
import os

infile = 'bak.ocean_temp_salt.res.nc'
outfile = 'ocean_temp_salt.res.nc'

assert os.path.exists(infile), f'Please create backup file {infile} before running this script'

cmd = f'cp {infile} {outfile}'
os.system(cmd)

f = nc.Dataset(outfile,'r+')
history = f'pert_salt_min.py on {infile} \n'
f.setncattr('history', history)

salt = f.variables['salt']
data = salt[:]

d0 = data == 0
dsave = d0.copy()

salt_min = 5
data[data < salt_min] = salt_min
data[dsave] = 0.
salt[:] = data[:]

f.close()

cmd = f'ncatted -a checksum,.,d,, {outfile}'
os.system(cmd)