#!/usr/bin/env python

import numpy as np
import netCDF4 as nc
import os

infile = 'salt.txt'
outfile = 'salt.nc'

cmd = 'grep "maximum S" mom.out > S_log'
os.system(cmd)
cmd = 'cut -c 23-40 S_log > salt.txt'
os.system(cmd)

salt = np.loadtxt(infile, dtype='f4')
salt = salt[::4] # subsample every 2nd day only

f = nc.Dataset(outfile,'w')
f.history = 'convert_nc4.py'
f.createDimension('t', 0)

s_o = f.createVariable('salt', 'f4', ('t'))
s_o[:] = salt[:]
f.close()

