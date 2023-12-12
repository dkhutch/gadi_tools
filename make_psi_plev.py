#!/usr/bin/env python
from aostools import climate
import argparse
import netCDF4 as nc
import numpy as np

parser = argparse.ArgumentParser(description='convert atmos model (pressure level) output to overturning streamfunction')
parser.add_argument('infile', help='input file on model levels containing vcomp, temp, level, lat')
parser.add_argument('outfile', help='output file containing streamfunction variables')
args = parser.parse_args()

psi, psis = climate.ComputePsi(data=args.infile, pfull='level')

psi = psi * 1.0e-9
psis = psis * 1.0e-9

f = nc.Dataset(args.infile, 'r')
level = f.variables['level'][:]
level_a = f.variables['level'].__dict__
lat = f.variables['lat'][:]
lat_a = f.variables['lat'].__dict__
time = f.variables['time'][:]
time_a = f.variables['time'].__dict__
f.close()

npres = level.shape[0]
nlat = lat.shape[0]

f = nc.Dataset(args.outfile, 'w')
f.history = 'make_psi.py on %s ' % args.infile

f.createDimension('time',0)
f.createDimension('lat', nlat)
f.createDimension('level',npres)

t_o = f.createVariable('time', 'f8', ('time'))
t_o.setncatts(time_a)
t_o[:] = time[:]

p_o = f.createVariable('level','f8', ('level'))
p_o.setncatts(level_a)
p_o[:] = level[:]

lat_o = f.createVariable('lat', 'f8', ('lat'))
lat_o.setncatts(lat_a)
lat_o[:] = lat[:]

psi_o = f.createVariable('psi', 'f4', ('time', 'level', 'lat'), fill_value=-1.e10)
psi_o.units = '10^9 kg/s'
psi_o.long_name = 'Meridional Overturning Streamfunction'
psi_o[:] = psi[:]

psis_o = f.createVariable('psis', 'f4', ('time', 'level', 'lat'), fill_value=-1.e10)
psis_o.units = '10^9 kg/s'
psis_o.long_name = 'Residual Overturning Streamfunction'
psis_o[:] = psis[:]

f.close()
