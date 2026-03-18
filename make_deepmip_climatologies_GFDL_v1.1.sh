#!/bin/ksh

set -xe

data_dir="/export/triassic/array-01/dh17104/GFDL_55Ma"
deepmip_dir="/export/triassic/array-01/dh17104/deepmip_database"

exp_list="c1 c2 c3 c4 c6 pic"

family="GFDL"
version="v1.0"
NC_TITLE="GFDL_model_output_for_DeepMIP_experiments_following_the_DeepMIP_naming_convention_(last_100_model_years)"

sel_vars=1
copy_files=0

for exp in ${exp_list}; do

  if [ "${exp}" == "pic" ]; then
    experiment="piControl"
    model="GFDL_CM2.1"
  elif [ "${exp}" == "c1" ]; then
    experiment="deepmip_sens_1xCO2"
    model="GFDL_CM2.1"
  elif [ "${exp}" == "c2" ]; then
    experiment="deepmip_sens_2xCO2"
    model="GFDL_CM2.1"
  elif [ "${exp}" == "c3" ]; then
    experiment="deepmip_stand_3xCO2"
    model="GFDL_CM2.1"
  elif [ "${exp}" == "c4" ]; then
    experiment="deepmip_sens_4xCO2"
    model="GFDL_CM2.1"
  elif [ "${exp}" == "c6" ]; then
    experiment="deepmip_stand_6xCO2"
    model="GFDL_CM2.1"
  fi 

  path_out=${deepmip_dir}/${family}/${model}/${experiment}/${version}

  ### select individual fields and rename variables
  if [ ${sel_vars} -eq 1 ]; then
  
    if [ -d ${path_out} ]; then
      rm -r ${path_out}
    fi
    mkdir -p ${path_out}

    cd ${data_dir}/${exp}

: <<'END'
    #2D atmosphere data
    var_list_old="t_ref t_surf tot_cld_amt lwdn_sfc lwup_sfc swdn_sfc swup_sfc swdn_toa swup_toa olr  u_ref v_ref tau_x tau_y ps ucomp vcomp omega lwdn_sfc_clr swdn_sfc_clr swup_sfc_clr swup_toa_clr olr_clr precip  evap    shflx low_cld_amt mid_cld_amt high_cld_amt"
    var_list_new="tas   ts     clt         rlds     rlus     rsds     rsus     rsdt     rsut     rlut uas   vas   tauu  tauv  ps ua    va    wa    rldscs       rsdscs       rsuscs       rsutcs       rlutcs  pr      evspsbl hfss  cll         clm         clh         " 

    long_names=("Near-surface (1.5 m) air temperature" \
                "Surface skin temperature" \
                "Total cloud cover" \
                "Surface downwelling longwave radiation" \
                "Surface upwelling longwave radiation" \
                "Surface downwelling shortwave radiation" \
                "Surface upwelling shortwave radiation" \
                "TOA incident shortwave radiation" \
                "TOA outgoing shortwave radiation" \
                "TOA outgoing longwave radiation" \
                "Near-surface eastward wind" \
                "Near-surface northward wind" \
                "Surface eastward wind stress" \
                "Surface northward wind stress" \
                "Surface pressure" \
                "Eastward wind on model levels" \
                "Northward wind on model levels" \
                "Vertical wind on model levels" \
                "Surface downwelling longwave radiation (clear sky)" \
                "Surface downwelling shortwave radiation (clear sky)" \
                "Surface upwelling shortwave radiation (clear sky)" \
                "TOA outgoing shortwave radiation (clear sky)" \
                "TOA outgoing longwave radiation (clear sky)" \
                "Precipitation" \
                "Total evaporation" \
                "Sensible heat flux (upward)" \
                "Low cloud amount" \
                "Medium cloud amount" \
                "High cloud amount" )

    long_names=( "${long_names[@]// /_}" ) # convert spaces to underscores
    
    num_vars=($var_list_new)    
    if [ ${#long_names[@]} -ne ${#num_vars[@]} ]; then
      echo "wrong variable lists"
      exit
    fi
    
    old_vars=($var_list_old)
        
    count=0
    for var in ${var_list_new}; do
    
      if [ "${var}" == "clt" ] || [ "${var}" == "cll" ] || [ "${var}" == "clm" ] || [ "${var}" == "clh" ]; then # convert from percent to fraction [0,1]
        cdo_command="-divc,100 -chname,${old_vars[count]},$var -selvar,${old_vars[count]} atmos_mon_${exp}.nc"
        nco_command="-O -h -a units,${var},o,c,fraction -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      elif [ "${var}" == "tauu" ] || [ "${var}" == "tauv" ]; then # reverse wind stress direction (because it originates from ocean model)
        cdo_command="-mulc,-1 -chname,${old_vars[count]},$var -selvar,${old_vars[count]} atmos_mon_${exp}.nc"
        nco_command="-O -h -a units,${var},o,c,fraction -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      else
        cdo_command="-chname,${old_vars[count]},$var -selvar,${old_vars[count]} atmos_mon_${exp}.nc"
        nco_command="-O -h -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      fi

      cdo -L ymonmean ${cdo_command} ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc # monthly mean climatology
#      cdo -L ymonstd ${cdo_command} ${path_out}/${model}-${experiment}-${var}-${version}.std.nc # monthly mean standard deviation
      
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc # change attributes
#      ncatted ${nco_command} ${path_out}/${model}-${experiment}-${var}-${version}.std.nc # change attributes
      
      count=$((count+1))
    done
    
    #3D atmosphere data on pressure levels
    var_list_old="cld_amt ucomp vcomp omega temp sphum hght slp"
    var_list_new="cl      uap   vap   wap   ta   hus   zg   psl" 

    long_names=("Cloud cover on pressure levels" \
                "Eastward wind on pressure levels" \
                "Northward wind on pressure levels" \
                "Vertical wind on pressure levels" \
                "Temperature on pressure levels" \
                "Specific humidity on pressure levels" \
                "Geopotential height on pressure levels" \
                "Mean sea-level pressure" )

    long_names=( "${long_names[@]// /_}" ) # convert spaces to underscores
    
    num_vars=($var_list_new)    
    if [ ${#long_names[@]} -ne ${#num_vars[@]} ]; then
      echo "wrong variable lists"
      exit
    fi
    
    old_vars=($var_list_old)
        
    count=0
    for var in ${var_list_new}; do
      if [ "${var}" == "psl" ]; then # convert from percent to fraction [0,1]
        cdo_command="-mulc,100 -chname,${old_vars[count]},$var -selvar,${old_vars[count]} atmos_plevel_${exp}.nc"
        nco_command="-O -h -a units,${var},o,c,Pa -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      else
        cdo_command="-chname,${old_vars[count]},$var -selvar,${old_vars[count]} atmos_plevel_${exp}.nc"
        nco_command="-O -h -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      fi

      cdo -L ymonmean ${cdo_command} ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc # monthly mean climatology
#      cdo -L ymonstd ${cdo_command} ${path_out}/${model}-${experiment}-${var}-${version}.std.nc # monthly mean standard deviation
      
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc # change attributes
#      ncatted ${nco_command} ${path_out}/${model}-${experiment}-${var}-${version}.std.nc # change attributes
      
      count=$((count+1))
    done
    
END          
      #ocean data
#      var_list_old="sst u  v  wt temp   salt mld    psiu     tau_x tau_y eta_t"
#      var_list_new="tos uo vo wo thetao so   mlotst sftbarot tauuo tauvo zos" 
#      var_list_old="sst u  v  wt temp   salt mld    psiu     tau_x tau_y diff_cbt_t visc_cbu wfno"
#      var_list_new="tos uo vo wo thetao so   mlotst sftbarot tauuo tauvo difvto     difvmo   wfno" 
      
      var_list_old="wfno"
      var_list_new="wfno"
      long_names=("Net surface freshwater flux (on ocean grid)") 

: <<'END'     
      long_names=("Sea-surface temperature" \
                  "Eastward velocity on model levels" \
                  "Northward velocity on model levels" \
                  "Vertical velocity on model levels" \
                  "Potential temperature on model levels" \
                  "Salinity on model levels" \
                  "Mixed-layer depth" \
                  "Barotropic streamfunction" \
                  "Surface eastward wind stress (on ocean grid)" \
                  "Surface northward wind stress (on ocean grid)" \
                  "Vertical ocean tracer diffusivity" \
                  "Vertical ocean momentum diffusivity" \
                  "Net surface freshwater flux (on ocean grid)" )
#                  "Sea surface height" )
      long_names=( "${long_names[@]// /_}" ) # convert spaces to underscores
END    
      num_vars=($var_list_new)    
      if [ ${#long_names[@]} -ne ${#num_vars[@]} ]; then
        echo "wrong variable lists"
        exit
      fi
    
      old_vars=($var_list_old)
        
      count=0
      for var in ${var_list_new}; do
        if [ "${var}" == "uo" ] || [ "${var}" == "vo" ] || [ "${var}" == "vo" ]; then # convert ocean currents from m/s to cm/s 
          cdo_command="-mulc,100 -chname,${old_vars[count]},$var -selvar,${old_vars[count]} ocean_mon_${exp}.nc"
          nco_command="-O -h -a units,${var},o,c,cm/s -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a standard_name,${var},d,, -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
        else
          cdo_command="-chname,${old_vars[count]},$var -selvar,${old_vars[count]} ocean_mon_${exp}.nc"
          nco_command="-O -h -a time_avg_info,${var},d,, -a long_name,${var},o,c,${long_names[count]} -a standard_name,${var},d,, -a cell_methods,${var},d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
        fi
        cdo -L ymonmean ${cdo_command} ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc # monthly mean climatology
#        cdo -L ymonstd ${cdo_command} ${path_out}/${model}-${experiment}-${var}-${version}.std.nc # monthly mean standard deviation
      
        ncatted ${nco_command} ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc # change attributes
#        ncatted ${nco_command} ${path_out}/${model}-${experiment}-${var}-${version}.std.nc # change attributes
  
        if [ "${var}" == "tos" ] ; then # remap data to regular 360x180 grid
          cdo remapnn,r360x180 ${path_out}/${model}-${experiment}-${var}-${version}.mean.nc ${path_out}/${model}-${experiment}-${var}-${version}.mean.1x1d.nc # monthly mean data for last 100 years
        fi

        count=$((count+1))
      done

: <<'END'
    #meridional overturning circulation
      cdo -L -chname,moc_mean,sftmyz -selvar,moc_mean ${deepmip_dir}/MOC_GFDL/moc_${exp}.nc ${path_out}/${model}-${experiment}-sftmyz-${version}.mean.nc
      nco_command="-O -h -a time_avg_info,sftmyz,d,, -a long_name,sftmyz,o,c,Global_overturning_streamfunction -a cell_methods,sftmyz,d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-sftmyz-${version}.mean.nc

    #Sea-ice fraction
      cdo -L -chname,EXT,siconc -selvar,EXT ice_mon_${exp}.nc ${path_out}/${model}-${experiment}-siconc-${version}.mean.nc
      nco_command="-O -h -a time_avg_info,siconc,d,, -a long_name,siconc,o,c,Sea-ice_fraction -a cell_methods,siconc,d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-siconc-${version}.mean.nc

    #boundary conditions
    #---land-sea mask
      cdo -L -setmisstoc,0 -chname,lfrac,sftlf -selvar,lfrac land_mon_${exp}.nc ${path_out}/${model}-${experiment}-sftlf-${version}.nc
      nco_command="-O -h -a time_avg_info,sftlf,d,, -a long_name,sftlf,o,c,Land-sea_mask  -a cell_methods,sftlf,d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-sftlf-${version}.nc
    #---orography
      cdo -L -chname,zsurf,orog -selvar,zsurf atmos_mon_${exp}.nc ${path_out}/${model}-${experiment}-orog-${version}.nc
      nco_command="-O -h -a time_avg_info,orog,d,, -a long_name,orog,o,c,Topography -a cell_methods,orog,d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-orog-${version}.nc
    #---bathymetry
      cdo -L -chname,ht,deptho -selvar,ht ocean_ann_${exp}.nc ${path_out}/${model}-${experiment}-deptho-${version}.nc
      nco_command="-O -h -a time_avg_info,deptho,d,, -a long_name,deptho,o,c,Bathymetry -a standard_name,deptho,d,, -a cell_methods,deptho,d,, -a ,global,d,, -a title,global,a,c,${NC_TITLE} -a family,global,a,c,${family} -a model,global,a,c,${model}  -a experiment,global,a,c,${experiment} -a version,global,a,c,${version}"
      ncatted ${nco_command} ${path_out}/${model}-${experiment}-deptho-${version}.nc
END
  fi

  
  ### copy files to eocene
  if [ ${copy_files} -eq 1 ]; then
    
#     if [ -d /export/acrc/DeepMIP_Model_Output_shared/${family}/${model}/${experiment}/${version} ]; then
#       rm -r /export/acrc/DeepMIP_Model_Output_shared/${family}/${model}/${experiment}/${version}
#     fi
#     mkdir -p /export/acrc/DeepMIP_Model_Output_shared/${family}/${model}/${experiment}/${version}
#   
#     cp -p ${deepmip_dir}/${family}/${model}/${experiment}/${version}/*.nc /export/acrc/DeepMIP_Model_Output_shared/${family}/${model}/${experiment}/${version}/
#    cp -p ${deepmip_dir}/${family}/${model}/${experiment}/${version}/*difvto*.nc /export/acrc/DeepMIP_Model_Output_shared/${family}/${model}/${experiment}/${version}/
#    cp -p ${deepmip_dir}/${family}/${model}/${experiment}/${version}/*difvmo*.nc /export/acrc/DeepMIP_Model_Output_shared/${family}/${model}/${experiment}/${version}/
    echo 'nothing to copy'
  fi
 
 
done 
