import numpy as np
import netCDF4 as nc

f = nc.Dataset('ocean_temp_salt.res.nc','r+')
hist = f.history[:]
hist = 'perturb_ts.py \n ' + hist
f.setncattr('history', hist)

temp = f.variables['temp']
tdata = temp[:]
# tdata[tdata < 0.] = 0.
tdata[:] = 10.
temp[:] = tdata[:]

salt = f.variables['salt']
sdata = salt[:]
sdata[:] = 34.7
salt[:] = sdata[:]

f.close()