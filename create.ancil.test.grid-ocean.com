#!/bin/csh
#
#
module use /g/data/hh5/public/modules
module unload conda
module load conda/analysis3-unstable


set EXP = no-drake
set DIR = /g/data3/w40/dxd565/access-n48/experiments/$EXP/input/




# ----------- edit ocean grid -> new ancillary file: grid_spec.nc
cd $DIR

# step 1: see: ~gdata/access-n48/david-edit-ocean-grid/ -> creates ocean_grid_esm.access-n48.original.nc
# step 2: Edit the bathymetry (depth_t variable) in ocean_grid_esm.nc
echo 'step 2: Edit the bathymetry (depth_t variable) in ocean_grid_esm.nc'

cat >pscript.py <<EOF
import numpy as np
import netCDF4 as nc

fname = 'ocean_grid_esm.nc'

f = nc.Dataset(fname,'r+')
# hist = f.history[:]
# hist = 'edit_ocean.py \n ' + hist
# f.history = hist[:]

depth = f.variables['depth_t']
data = depth[:]

# change bathymetry: close Drake Passage
data[34:51,214:220] = 0.0

depth[:] = data[:]

EOF
#
# # cp ocean_grid_esm.access-n48.original.nc  ocean_grid_esm.nc
# # cp grid_spec.access-n48.original.nc  ocean_grid_esm.nc
# ncks -O -v zt,zb,grid_x_T,grid_y_T,grid_x_C,grid_y_C,vertex,x_T,y_T,x_vert_T,y_vert_T,area_T,angle_T,ds_00_02_T,ds_20_22_T,ds_02_22_T,ds_00_20_T,ds_00_01_T,ds_01_02_T,ds_02_12_T,ds_12_22_T,ds_21_22_T,ds_20_21_T,ds_10_20_T,ds_00_10_T,ds_01_11_T,ds_11_12_T,ds_11_21_T,ds_10_11_T,ds_01_21_T,ds_10_12_T,x_E,y_E,x_vert_E,y_vert_E,area_E,angle_E,ds_00_02_E,ds_20_22_E,ds_02_22_E,ds_00_20_E,ds_00_01_E,ds_01_02_E,ds_02_12_E,ds_12_22_E,ds_21_22_E,ds_20_21_E,ds_10_20_E,ds_00_10_E,ds_01_11_E,ds_11_12_E,ds_11_21_E,ds_10_11_E,ds_01_21_E,ds_10_12_E,x_N,y_N,x_vert_N,y_vert_N,area_N,angle_N,ds_00_02_N,ds_20_22_N,ds_02_22_N,ds_00_20_N,ds_00_01_N,ds_01_02_N,ds_02_12_N,ds_12_22_N,ds_21_22_N,ds_20_21_N,ds_10_20_N,ds_00_10_N,ds_01_11_N,ds_11_12_N,ds_11_21_N,ds_10_11_N,ds_01_21_N,ds_10_12_N,x_C,y_C,x_vert_C,y_vert_C,area_C,angle_C,ds_00_02_C,ds_20_22_C,ds_02_22_C,ds_00_20_C,ds_00_01_C,ds_01_02_C,ds_02_12_C,ds_12_22_C,ds_21_22_C,ds_20_21_C,ds_10_20_C,ds_00_10_C,ds_01_11_C,ds_11_12_C,ds_11_21_C,ds_10_11_C,ds_01_21_C,ds_10_12_C,depth_t,num_levels,wet grid_spec.access-n48.original.nc ocean_grid_esm.nc
# #
# python ./pscript.py



# step 3:  adjust the land-sea mask variable called "wet", and re-calculate the "num_levels" variable, which specifies how many ocean levels should be at each grid (i,j) location.
echo 'step 3:  adjust the land-sea mask variable called "wet"'
cat >pscript.py <<EOF
import numpy as np
import netCDF4 as nc

fname = 'ocean_grid_esm.nc'

f = nc.Dataset(fname,'r+')
# hist = f.history[:]
# hist = 'remake_wet_levels.py \n ' + hist
# f.history = hist[:]

depth = f.variables['depth_t'][:]
zb = f.variables['zb'][:]
wet = f.variables['wet']
num_levels = f.variables['num_levels']

wet_data = wet[:]
wet_data[depth == 0] = 0
wet_data[depth > 0] = 1
wet[:] = wet_data[:]

level_data = num_levels[:]
ny, nx = depth.shape
nz = zb.shape[0]


for j in range(ny):
    for i in range(nx):
        if depth[j,i] == 0:
            level_data[j,i] = 0
        else:
            if depth[j,i] > 0 and depth[j,i] <= zb[0]:
                level_data[j,i] = 1
            for k in range(1,nz):
                if depth[j,i] > zb[k-1] and depth[j,i] <= zb[k]:
                    level_data[j,i] = k+1

num_levels[:] = level_data[:]

EOF
#
python ./pscript.py


# step 4: re-calculate the exchange grids, and give you a new version of grid_spec.nc
 echo 'step 4: re-calculate the exchange grids' 
/g/data/w40/dxd565/access-n48/david-edit-ocean-grid/tools/make_xgrids -o ocean_grid_esm.nc -a atmos_grid_esm.access-n48.original.nc -l atmos_grid_esm.access-n48.original.nc >fms.out

# create some error messages in fms.out: 
# RMS Atmosphere cell tiling error = 6.87643e-07
# MAX Atmosphere cell tiling error = -3.53519e-05 at (i=104,j=90), (x=258.75,y= 89.00)
# RMS Ocean cell tiling error (atmos/ocean x-cells) = 6.62843e-07
# MAX Ocean cell tiling error (atmos/ocean x-cells) = -4.75397e-05 at (i=158,j=271), (x=-118.87,y= 69.81)
# MAX Ocean cell tiling error (land/ocean runoff) = -4.75397e-05 at (i=158,j=271), (x=-118.87,y= 69.81)
# 
# David: Yep that's fine


# step 5: copy depth_t in grid_spec.nc ->depth in ocean_topog.nc
echo 'step 5: copy depth_t in grid_spec.nc ->depth in ocean_topog.nc'

cat >pscript.py <<EOF
import numpy as np
import netCDF4 as nc

infile   = "grid_spec.nc"
outfile  = "ocean_topog.nc"

# read grid_spec.nc
fin       = nc.Dataset(infile,'r')
depth_new = fin.variables['depth_t'][:]

# read ocean_topog.nc
fout    = nc.Dataset(outfile,'r+')
depth   = fout.variables['depth'][:]

# new bathymetry
depth = np.ma.copy(depth_new)

# write land fraction data
fout.variables['depth'][:] = depth
fout.close()

print('Done!')
EOF
#
cp ocean_topog.original.nc ocean_topog.nc
#
python ./pscript.py


exit
