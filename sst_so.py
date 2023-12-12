#!/usr/bin/env python
import numpy as np
import netCDF4 as nc
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input', help='input file with annual temperature field')
parser.add_argument('output', help='output file with Southern Ocean SST')
args = parser.parse_args()

f = nc.Dataset(args.input, 'r')
sst = f.variables['temp'][:,0,:,:]
area = f.variables['area_t'][:]
yt = f.variables['yt_ocean'][:]
xt = f.variables['xt_ocean'][:]
time = f.variables['time'][:]
f.close()

nt, ny, nx = sst.shape

y0 = -59.5
y1 = -44.5

i0 = np.abs(yt - y0).argmin()
i1 = np.abs(yt - y1).argmin()

sst_45_90 = np.zeros(nt)
sst_45_60 = np.zeros(nt)
sst_60_90 = np.zeros(nt)

for i in range(nt):
   tslice = sst[i,:,:]
   sst_45_90[i] = np.ma.average(tslice[:i1,:], weights=area[:i1,:])
   sst_45_60[i] = np.ma.average(tslice[i0:i1,:], weights=area[i0:i1,:])
   sst_60_90[i] = np.ma.average(tslice[:i0,:], weights=area[:i0,:])

fo = nc.Dataset(args.output,'w')
fo.history = 'sst_so.py %s %s\n' % (args.input, args.output)

fo.createDimension('time', 0)

time_o = fo.createVariable('time', 'f8', ('time'))
time_o.units = "days since 0001-01-01 00:00:00" 
time_o.calendar = "NOLEAP" 
time_o[:] = time[:]

t0 = fo.createVariable('sst_45_90', 'f8', ('time'))
t0.units = 'degC'
t0[:] = sst_45_90[:]

t1 = fo.createVariable('sst_45_60', 'f8', ('time'))
t1.units = 'degC'
t1[:] = sst_45_60[:]

t2 = fo.createVariable('sst_60_90', 'f8', ('time'))
t2.units = 'degC'
t2[:] = sst_60_90[:]

fo.close()
