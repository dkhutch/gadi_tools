#!/usr/bin/env python
import numpy as np
import netCDF4 as nc
import os
import argparse 

parser = argparse.ArgumentParser()
parser.add_argument("infile", help='3D MOC input file, often called moc.nc')
parser.add_argument("outfile", help='1D MOC index file, often called moc_idx.nc')
args = parser.parse_args()

assert os.path.exists(args.infile), 'Input file %s does not exist' % args.infile
assert not os.path.exists(args.outfile), 'Output file %s already exists' % args.outfile

f = nc.Dataset(args.infile,'r')
moc = f.variables['moc'][:]
time = f.variables['time'][:]
f.close()

nmask = np.ones(moc.shape, 'bool')
smask = np.ones(moc.shape, 'bool')
eqmask = np.ones(moc.shape, 'bool')

yi1 = 51
yi2 = 139

nmask[:, 30:, yi2:] = False
smask[:, 30:, :yi1] = False
eqmask[:, :30, yi1:yi2] = False

moc_n = np.ma.masked_array(moc, nmask)
moc_s = np.ma.masked_array(moc, smask)
moc_eq = np.ma.masked_array(moc, eqmask)


moc_n = np.max(moc_n, 2)
moc_n = np.max(moc_n, 1)

moc_s = np.min(moc_s, 2)
moc_s = np.min(moc_s, 1)

moc_eq_n = np.max(moc_eq, 2)
moc_eq_n = np.max(moc_eq_n, 1)

moc_eq_s = np.min(moc_eq, 2)
moc_eq_s = np.min(moc_eq_s, 1)


nt = time.shape[0]

f = nc.Dataset(args.outfile,'w')
f.history = 'moc_idx_cm2.1.py \n '

f.createDimension('time',0)

t = f.createVariable('time','f4',('time'))
t[:] = time[:]

moc_n_o = f.createVariable('moc_n','f4',('time'))
moc_n_o[:] = moc_n[:]
moc_n_o.units = 'Sv'

moc_s_o = f.createVariable('moc_s','f4',('time'))
moc_s_o[:] = moc_s[:]
moc_s_o.units = 'Sv'

moc_eq_n_o = f.createVariable('moc_eq_n','f4',('time'))
moc_eq_n_o[:] = moc_eq_n[:]
moc_eq_n_o.units = 'Sv'

moc_eq_s_o = f.createVariable('moc_eq_s','f4',('time'))
moc_eq_s_o[:] = moc_eq_s[:]
moc_eq_s_o.units = 'Sv'

f.close()
