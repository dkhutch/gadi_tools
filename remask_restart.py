#!/usr/bin/env python

import numpy as np 
import netCDF4 as nc 
import sys
import argparse

parser = argparse.ArgumentParser(description="Add mask to restart file using temperature variable from output")
parser.add_argument("-i","--input", help="restart file with no mask", required=True)
parser.add_argument("-o","--output", help="restart file with mask added", required=True)
parser.add_argument("-m","--mask", help="output file with temp variable to extract mask", required=True)
parser.add_argument("-v","--varmask", default="temp", help="specify variable if not using temperature")

args = parser.parse_args()

ncfile_i = nc.Dataset(args.input, 'r')
ncfile_o = nc.Dataset(args.output, 'w')
ncfile_m = nc.Dataset(args.mask, 'r')

temp = ncfile_m.variables[args.varmask][:]
tmask = temp.mask[0,:,:,:]
if len(tmask.shape) == 3:
    tmask = tmask[np.newaxis, :, :, :]

glob_atts = ncfile_i.__dict__
newhist = f'remask_restart.py -i {args.input} -o {args.output} -m {args.mask} \n'
if 'history' in glob_atts:
    glob_atts['history'] = newhist + glob_atts['history']
else:
    glob_atts['history'] = newhist
ncfile_o.setncatts(glob_atts)

for dimname,dim in ncfile_i.dimensions.items():
    ncfile_o.createDimension(dimname,len(dim))

varnames = ncfile_i.variables.keys()

for varname in varnames:
    print(varname)
    ncvar = ncfile_i.variables[varname]
    data = ncvar[:] 

    if hasattr(ncvar, '_FillValue'):
        FillValue = ncvar._FillValue
    elif len(data.shape) > 1:
        FillValue = -1.0e20
    else:
        FillValue = None

    if len(data.shape) > 1:
        data.mask = tmask
    
    var = ncfile_o.createVariable(varname, ncvar.dtype, ncvar.dimensions, fill_value=FillValue,
          zlib=True, complevel=5)

    attdict = ncvar.__dict__ 
    # remove the fillvalue attribute and others we don't want
    for rematt in ['_FillValue','time_avg_info','missing_value','cell_methods','standard_name']:
        if rematt in attdict: 
            del attdict[rematt]
    var.setncatts(attdict)

    var[:] = data[:]    
