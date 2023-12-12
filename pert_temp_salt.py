#!/usr/bin/env python
import numpy as np
import netCDF4 as nc
import os

infile = 'ocean_temp_salt.res.nc'
outfile = 'new_temp_salt.nc'

cmd = f'cp {infile} {outfile}'
os.system(cmd)

f = nc.Dataset(outfile,'r+')
atts = f.__dict__
atts['history'] = 'pert_temp_salt.py'
f.setncatts(atts)

temp =  f.variables['temp']
data = temp[:]
data[0,0,50,50] += 0.01
temp[:] = data[:]

f.close()
