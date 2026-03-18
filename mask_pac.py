#!/home/x_davhu/python_env/bin/python
import numpy as np
import netCDF4 as nc
import os

f = nc.Dataset('../pac_mask.nc','r')
pmask = f.variables['mask'][:]
f.close()

infile = 'ocean_year.nc'
outfile = 'T_pac.nc'

os.system('ncks -O -v area_t,temp,salt,age_global %s %s' % (infile, outfile) )

f = nc.Dataset(outfile, 'r+')
hist = f.history[:]
f.history = 'mask_pac.py \n ' + hist

temp = f.variables['temp']
salt = f.variables['salt']
age = f.variables['age_global']
tdata = temp[:]
sdata = salt[:]
adata = age[:]

nt, nz, ny, nx = temp.shape

pmask = np.reshape(pmask, (1,1,ny,nx) )
pmask = np.tile(pmask, (nt,nz,1,1) )

tdata.mask[pmask!=1] = True
sdata.mask[pmask!=1] = True
adata.mask[pmask!=1] = True

temp[:] = tdata
salt[:] = sdata
age[:] = adata

f.close()


