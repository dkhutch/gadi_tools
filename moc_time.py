#!/usr/bin/env python
import numpy as np
import netCDF4 as nc
import sys
import os

assert len(sys.argv)==3, 'Usage: moc.py <infile> <outfile>'
infile = sys.argv[1]
outfile = sys.argv[2]
assert os.path.exists(infile), 'Input file %s not found' % infile
assert not os.path.exists(outfile), 'Output file %s already exists' % outfile

f = nc.Dataset(infile,'r')
time = f.variables['time'][:]
time_units = f.variables['time'].units
ty = f.variables['ty_trans'][:]
ty_rho = f.variables['ty_trans_rho'][:]
ty_gm = f.variables['ty_trans_gm'][:]
ty_rho_gm = f.variables['ty_trans_rho_gm'][:]
yu = f.variables['yu_ocean'][:]
zt = f.variables['st_ocean'][:]
rho = f.variables['potrho'][:]
f.close()

nt = time.shape[0]
ny = yu.shape[0]
nz = zt.shape[0]
nrho = rho.shape[0]

moc = np.cumsum(ty, axis=1) - np.reshape(np.sum(ty, axis=1), (nt,1,ny))
moc_tot = moc + ty_gm
moc_rho = np.cumsum(ty_rho, axis=1) - np.reshape(np.sum(ty_rho, axis=1), (nt,1,ny))
moc_rho_tot = moc_rho + ty_rho_gm

f = nc.Dataset(outfile, 'w')
f.history = ' '.join(sys.argv) + '\n '

f.createDimension('time',0)
f.createDimension('st_ocean', nz)
f.createDimension('yu_ocean', ny)
f.createDimension('potrho', nrho)

to = f.createVariable('time','f4',('time'))
to[:] = time[:]
to.units = time_units

zo = f.createVariable('st_ocean','f4',('st_ocean'))
zo[:] = zt[:]
zo.units = 'metres'

yo = f.createVariable('yu_ocean','f4',('yu_ocean'))
yo[:] = yu[:]
yo.units = 'degrees north'

ro = f.createVariable('potrho','f4',('potrho'))
ro[:] = rho[:]
ro.units = 'kg/m^3'

mot = f.createVariable('moc','f4',('time','st_ocean','yu_ocean'),fill_value=-1.e20)
mot[:] = moc_tot[:]
mot.units = 'Sv'

mo = f.createVariable('moc_mean','f4',('time','st_ocean','yu_ocean'),fill_value=-1.e20)
mo[:] = moc[:]
mo.units = 'Sv'

mog = f.createVariable('moc_gm','f4',('time','st_ocean','yu_ocean'),fill_value=-1.e20)
mog[:] = ty_gm[:]
mog.units = 'Sv'

mort = f.createVariable('moc_rho','f4',('time','potrho','yu_ocean'),fill_value=-1.e20)
mort[:] = moc_rho_tot[:]
mort.units = 'Sv'

mor = f.createVariable('moc_rho_mean','f4',('time','potrho','yu_ocean'),fill_value=-1.e20)
mor[:] = moc_rho[:]
mor.units = 'Sv'

morg = f.createVariable('moc_rho_gm','f4',('time','potrho','yu_ocean'),fill_value=-1.e20)
morg[:] = ty_rho_gm[:]
morg.units = 'Sv'

f.close()
