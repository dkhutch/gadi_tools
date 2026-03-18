#!/bin/bash
#PBS -P y99
#PBS -q copyq
#PBS -l walltime=10:00:00
#PBS -l ncpus=1
#PBS -l mem=1GB
#PBS -l storage=gdata/hh5+scratch/y99
#PBS -l wd
#PBS -j oe

odir=CM2.1_PI
rsync -av $odir z3382649@cyclone.ccrc.unsw.edu.au:/srv/ccrc/PaleoDH/z3382649/archive > out_$odir
